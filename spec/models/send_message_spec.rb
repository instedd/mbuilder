require "spec_helper"

describe "Send message" do
  let(:application) { new_application "Users: Phone, Name" }

  it "sends message" do
    new_trigger do
      message "register {Name}"
      send_message "'5678'", "Hello {{name}} from {{phone_number}}"
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter from 1234", :"mbuilder-application" => application.id}])
  end

  it "sends message with dot" do
    new_trigger do
      message "register {Name}"
      send_message "'5678'", "Hello {{name}}. Your number is: {{phone_number}}"
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter. Your number is: 1234", :"mbuilder-application" => application.id}])
  end

  it "sends message to phone number" do
    new_trigger do
      message "register {Name}"
      send_message "{phone_number}", "Hello {{name}}. Your number is: {{phone_number}}"
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://1234", body: "Hello Peter. Your number is: 1234", :"mbuilder-application" => application.id}])
  end

  it "sends message with quotes" do
    new_trigger do
      message "register {Name}"
      send_message "'5678'", "Hello {{name}}. Your number is: \"{{phone_number}}\""
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter. Your number is: \"1234\"", :"mbuilder-application" => application.id}])
  end

  it "sends message to many recipients" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "John"},
      {"phone" => "9012", "name" => "Foo"},
    ]
    new_trigger do
      message "alert {Name} with {Message}"
      select_entity "users.name = {name}"
      send_message "*phone", "The message: {{message}}"
    end
    ctx = accept_message "sms://1234", "alert John with Hello"

    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "The message: Hello", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://5678", body: "The message: Hello", :"mbuilder-application" => application.id},
    ]
  end

  it "sends message with many values" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "John"},
      {"phone" => "9012", "name" => "Foo"},
    ]
    new_trigger do
      message "alert {Name}"
      select_entity "users.name = {name}"
      send_message "'1111'", "The message: {*phone}"
    end
    ctx = accept_message "sms://1234", "alert John"

    (ctx.messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 1234, 5678", :"mbuilder-application" => application.id}] ||
     ctx.messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 5678, 1234", :"mbuilder-application" => application.id}]).should be_true
  end

  it "send message filtered by many values" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "John"},
      {"phone" => "9012", "name" => "Foo"},
    ]
    add_table "Friends: From, To"
    add_data "friends", [
      {"from" => "1234", "to" => "1111"},
      {"from" => "1234", "to" => "2222"},
      {"from" => "5678", "to" => "3333"},
    ]
    new_trigger do
      message "alert {Name}"
      select_entity "users.name = {name}"
      select_entity "friends.from = *phone"
      send_message "*to", "Watch out!"
    end
    ctx = accept_message "sms://9999", "alert John"
    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1111", body: "Watch out!", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://2222", body: "Watch out!", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://3333", body: "Watch out!", :"mbuilder-application" => application.id},
    ]
  end

  it "send message filtered by many values on the same table" do
    add_data "users", [
      {"phone" => 1234, "name" => "John"},
      {"phone" => 5678, "name" => "John"},
      {"phone" => 1234, "name" => "Foo"},
    ]
    new_trigger do
      message "alert {Name} {1111}"
      select_entity "users.name = {name}"
      select_entity "users.phone = {1111}"
      send_message "*phone", "Watch out!"
    end
    ctx = accept_message "sms://9999", "alert John 1234"
    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "Watch out!", :"mbuilder-application" => application.id},
    ]
  end

  it "matches more than one trigger" do
    new_trigger do
      message "register {Name}"
      send_message "'5678'", "Hello {{name}} from {{phone_number}}"
    end
    new_trigger do
      message "register {Name}"
      send_message "'1234'", "Hello {{name}} from {{phone_number}}"
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([
      {from: "app://mbuilder", to: "sms://5678", body: "Hello Peter from 1234", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://1234", body: "Hello Peter from 1234", :"mbuilder-application" => application.id},
      ])
  end
end
