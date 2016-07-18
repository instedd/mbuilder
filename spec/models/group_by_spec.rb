require "spec_helper"

describe "Aggregate functions" do
  context "Elasticsearch" do
    let(:application) { new_application "Users: Age, Name, Gender" }

    before(:each) do
      add_data "users", [
        {"age" => 10, "name" => "foo", "gender" => "male"},
        {"age" => 20, "name" => "foo", "gender" => "female"},
        {"age" => 10, "name" => "bar", "gender" => "female"},
        {"age" => 80, "name" => "bar", "gender" => "female"},
      ]
    end

    it "groups by" do
      new_trigger do
        message "foo"
        group_by "users.name"
        send_message "'1111'", "{*total(age)}"
      end
      context = accept_message 'sms://1234', 'foo'
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "90, 30", :"mbuilder-application" => application.id}])
    end

    it "groups by number aggregating text" do
      new_trigger do
        message "foo"
        group_by "users.age"
        send_message "'1111'", "{*count(name)}"
      end
      context = accept_message 'sms://1234', 'foo'
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "2, 1, 1", :"mbuilder-application" => application.id}])
    end

    it "groups by and shows the grouped field" do
      new_trigger do
        message "foo"
        group_by "users.name"
        send_message "'1111'", "{*name}: {*total(age)}"
      end
      context = accept_message 'sms://1234', 'foo'
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "bar, foo: 90, 30", :"mbuilder-application" => application.id}])
    end

    it "shows a grouped field without aggregation" do
      new_trigger do
        message "foo"
        group_by "users.name"
        send_message "'1111'", "{*name}: {*age}"
      end
      context = accept_message 'sms://1234', 'foo'
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "bar, foo: [10, 80], [10, 20]", :"mbuilder-application" => application.id}])
    end

    it "can group by field after creating entity (#334)" do
      new_trigger do
        message "hello"
        create_entity "users.name = {phone_number}"
        group_by "users.name"
      end
      accept_message 'sms://1234', 'hello'
    end
  end

  context "Memory" do
    let(:application) { new_application "Users: Age, Name" }
    let(:context) { MemoryExecutionContext.new(application, TriggerPlaceholderSolver.new, ExecutionLogger.new(application: application)) }

    before(:each) do
      [["foo", "10"], ["foo", "20"], ["bar", "40"], ["bar", "80"]].each do |name, age|
        trigger = new_trigger do
          message "add {#{name}} {#{age}}", from: '1234'
          create_entity "users.name = {#{name.downcase}}"
          store_entity_value "users.age = {#{age}}"
        end
        context.execute trigger
      end
    end

    it "groups by" do
      trigger = new_trigger do
        message "foo"
        group_by "users.name"
        send_message "'1111'", "{*total(age)}"
      end
      context.execute trigger
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "120, 30", :"mbuilder-application" => application.id}])
    end

    it "groups by and shows the grouped field" do
      trigger = new_trigger do
        message "foo"
        group_by "users.name"
        send_message "'1111'", "{*name}: {*total(age)}"
      end
      context.execute trigger
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "bar, foo: 120, 30", :"mbuilder-application" => application.id}])
    end

    it "shows a grouped field without aggregation" do
      trigger = new_trigger do
        message "foo"
        group_by "users.name"
        send_message "'1111'", "{*name}: {*age}"
      end
      context.execute trigger
      context.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "bar, foo: [40, 80], [10, 20]", :"mbuilder-application" => application.id}])
    end
  end
end
