require "spec_helper"

describe "Create entity" do
  let(:application) { new_application "Users: Phone, Name" }

  it "creates entity" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = {phone_number}"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => 1234.0}
  end

  it "creates entity with a stored value" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {name}"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => 1234.0, "name" => "Peter"}
  end

  it "creates entity with a literal value" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = 'hello'"
    end
    accept_message 'sms://1234', 'register Peter'
    assert_data "users", {"phone" => "hello"}
  end

  it "creates entity with a stored value when value is number" do
    new_trigger do
      message "register {1111}"
      create_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {1111}"
    end
    accept_message 'sms://1234', 'register 5678'
    assert_data "users", {"phone" => 1234.0, "name" => 5678.0}
  end
end
