require "spec_helper"

describe Application do
  let(:application) { new_application("Users: Phone, Name") }

  it "accepts message and creates entity" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => "1234"}
  end

  it "accepts message and creates entity with a stored value" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => "1234", "name" => "Peter"}
  end

  it "accepts message and creates entity with a stored value when value is number" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message 'sms://1234', 'register 5678'
    assert_data "users", {"phone" => "1234", "name" => "5678"}
  end

  it "accepts message and updates one entity with a stored value" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "Doe"},
    ]
    new_trigger do
      message "register {Name}"
      select_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "5678", "name" => "Doe"},
    ]
  end

  it "accepts message and updates many entities with a stored value" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "1234", "name" => "Doe"},
      {"phone" => "5678", "name" => "Foo"},
    ]
    new_trigger do
      message "register {Name}"
      select_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "5678", "name" => "Foo"},
    ]
  end

  it "accepts message and updates all entities with a stored value" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "Doe"},
    ]
    new_trigger do
      message "register {Name}"
      store_entity_value "users.name = name"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "5678", "name" => "Peter"},
    ]
  end

  it "accepts message and sends message" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name} from {implicit phone number}"
    end
    messages = accept_message "sms://1234", "register Peter"
    messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter from 1234"}])
  end

  it "accepts message and sends message with dot" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name}. Your number is: {implicit phone number}"
    end
    messages = accept_message "sms://1234", "register Peter"
    messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter. Your number is: 1234"}])
  end

  it "accepts message and sends message to many recipients" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "John"},
      {"phone" => "9012", "name" => "Foo"},
    ]
    new_trigger do
      message "alert {Name} with {Message}"
      select_entity "users.name = name"
      send_message "users.phone", "The message: {message}"
    end
    messages = accept_message "sms://1234", "alert John with Hello"

    assert_sets_equal messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "The message: Hello"},
      {from: "app://mbuilder", to: "sms://5678", body: "The message: Hello"},
    ]
  end

  it "accepts message and sends message with many values" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "John"},
      {"phone" => "9012", "name" => "Foo"},
    ]
    new_trigger do
      message "alert {Name}"
      select_entity "users.name = name"
      send_message "text 1111", "The message: {users.phone}"
    end
    messages = accept_message "sms://1234", "alert John"


    (messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 1234, 5678"}] ||
     messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 5678, 1234"}]).should be_true
  end
end
