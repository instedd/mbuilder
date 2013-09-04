require "spec_helper"

describe Application do
  let(:application) { new_application("Users: Phone, Name") }

  it "creates entity" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => "1234"}
  end

  it "creates entity with a stored value" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => "1234", "name" => "Peter"}
  end

  it "creates entity with a stored value when value is number" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message 'sms://1234', 'register 5678'
    assert_data "users", {"phone" => "1234", "name" => "5678"}
  end

  it "updates one entity with a stored value" do
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

  it "updates many entities with a stored value" do
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

  it "updates all entities with a stored value" do
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

  it "sends message" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name} from {implicit phone number}"
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter from 1234"}])
  end

  it "sends message with dot" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name}. Your number is: {implicit phone number}"
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter. Your number is: 1234"}])
  end

  it "sends message with quotes" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name}. Your number is: \"{implicit phone number}\""
    end
    ctx = accept_message "sms://1234", "register Peter"
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter. Your number is: \"1234\""}])
  end

  it "sends message to many recipients" do
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
    ctx = accept_message "sms://1234", "alert John with Hello"

    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "The message: Hello"},
      {from: "app://mbuilder", to: "sms://5678", body: "The message: Hello"},
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
      select_entity "users.name = name"
      send_message "text 1111", "The message: {users.phone}"
    end
    ctx = accept_message "sms://1234", "alert John"

    (ctx.messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 1234, 5678"}] ||
     ctx.messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 5678, 1234"}]).should be_true
  end

  it "sends message with many values" do
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
    ctx = accept_message "sms://1234", "alert John"

    (ctx.messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 1234, 5678"}] ||
     ctx.messages == [{from: "app://mbuilder", to: "sms://1111", body: "The message: 5678, 1234"}]).should be_true
  end

  it "filters by many values" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "John"},
      {"phone" => "9012", "name" => "Foo"},
    ]
    add_data "friends", [
      {"from" => "1234", "to" => "1111"},
      {"from" => "1234", "to" => "2222"},
      {"from" => "5678", "to" => "3333"},
    ]
    new_trigger do
      message "alert {Name}"
      select_entity "users.name = name"
      select_entity "friends.from = users.phone"
      send_message "friends.to", "Watch out!"
    end
    ctx = accept_message "sms://9999", "alert John"
    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1111", body: "Watch out!"},
      {from: "app://mbuilder", to: "sms://2222", body: "Watch out!"},
      {from: "app://mbuilder", to: "sms://3333", body: "Watch out!"},
    ]
  end
end
