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
end
