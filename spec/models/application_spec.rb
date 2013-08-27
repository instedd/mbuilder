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

  it "accepts message and updates entity with a stored value" do
    add_data "users", {"phone" => "1234", "name" => "John"}
    new_trigger do
      message "register {Name}"
      select_entity "users.phone = implicit phone number"
      store_entity_value "users.name = name"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", {"phone" => "1234", "name" => "Peter"}
  end

  it "accepts message and send message" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name} from {implicit phone number}"
    end
    messages = accept_message "sms://1234", "register Peter"
    messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter from 1234"}])
  end

  it "accepts message and send message with dot" do
    new_trigger do
      message "register {Name}"
      send_message "text 5678", "Hello {name}. Your number is: {implicit phone number}"
    end
    messages = accept_message "sms://1234", "register Peter"
    messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter. Your number is: 1234"}])
  end
end
