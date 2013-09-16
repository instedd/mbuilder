require "spec_helper"

describe MemoryExecutionContext do
  let(:application) { new_application "Users: Phone, Name" }

  it "creates entity" do
    trigger = new_trigger do
      message "register {Name}", from: "1234"
      create_entity "users.phone = {phone_number}"
    end

    memory_context = MemoryExecutionContext.new(application)
    memory_context.execute(trigger)

    assert_data "users"

    data = memory_context.data_for("users")
    assert_sets_equal data, [{"phone" => "1234"}]
  end

  it "creates entity and stores value" do
    trigger = new_trigger do
      message "register {John}", from: "1234"
      create_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {john}"
    end

    memory_context = MemoryExecutionContext.new(application)
    memory_context.execute(trigger)

    data = memory_context.data_for("users")
    assert_sets_equal data, [{"phone" => "1234", "name" => "John"}]
  end

  it "creates entity with a literal value" do
    trigger = new_trigger do
      message "register {Name}", from: "1234"
      create_entity "users.phone = 'hello'"
    end

    memory_context = MemoryExecutionContext.new(application)
    memory_context.execute(trigger)

    data = memory_context.data_for("users")
    assert_sets_equal data, [{"phone" => "hello"}]
  end

  it "updates one entity with a stored value" do
    memory_context = MemoryExecutionContext.new(application)

    [["John", "1234"], ["Doe", "5678"]].each do |name, from|
      trigger = new_trigger do
        message "register {#{name}}", from: from
        create_entity "users.phone = {phone_number}"
        store_entity_value "users.name = {#{name.downcase}}"
      end
      memory_context.execute trigger
    end

    trigger = new_trigger do
      message "register {Peter}", from: "1234"
      select_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {peter}"
    end

    memory_context.execute trigger

    data = memory_context.data_for("users")
    assert_sets_equal data, [
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "5678", "name" => "Doe"},
    ]
  end

  it "sends message" do
    trigger = new_trigger do
      message "register {Name}", from: "1234"
      send_message "'5678'", "Hello {{name}} from {{phone_number}}"
    end

    memory_context = MemoryExecutionContext.new(application)
    memory_context.execute(trigger)

    memory_context.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Name from 1234"}])
  end

  it "simulates all triggers execution" do
    new_trigger do
      message "register {Name}", from: "1234"
      create_entity "users.phone = {phone_number}"
    end

    new_trigger do
      message "register {Name}", from: "2345"
      create_entity "users.phone = {phone_number}"
    end

    db = application.simulate_triggers_execution

    db.each do |key, table|
      table.each do |row|
        row.delete "id"
      end
    end
    assert_data "users"

    assert_sets_equal db['users'], [
      {"phone" => "1234"},
      {"phone" => "2345"},
    ]
  end
end
