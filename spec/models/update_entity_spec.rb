require "spec_helper"

describe "Update entity" do
  let(:application) { new_application "Users: Phone, Name" }

  it "updates entities with a literal value" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "5678", "name" => "Doe"},
    ]
    new_trigger do
      message "rename {Phone}"
      select_entity "users.phone = {phone}"
      store_entity_value "users.name = 'NewName'"
    end
    accept_message 'sms://1234', 'rename 1234'
    assert_data "users", [
      {"phone" => "1234", "name" => "NewName"},
      {"phone" => "1234", "name" => "NewName"},
      {"phone" => "5678", "name" => "Doe"},
    ]
  end

  it "updates one entity with a stored value" do
    add_data "users", [
      {"phone" => "1234", "name" => "John"},
      {"phone" => "5678", "name" => "Doe"},
    ]
    new_trigger do
      message "register {Name}"
      select_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {name}"
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
      select_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {name}"
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
      store_entity_value "users.name = {name}"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => "1234", "name" => "Peter"},
      {"phone" => "5678", "name" => "Peter"},
    ]
  end
end
