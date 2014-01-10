require "spec_helper"

describe "Foreach" do
  let(:application) { new_application "Users: Phone, Name; Copied: PhoneCopy, NameCopy" }

  it "loops and creates entities" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "John"},
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 5678.0, "name" => "Doe"},
    ]

    new_trigger do
      message "copy {Phone}"
      select_entity "users.phone = {phone}"
      foreach("users") do
        create_entity "copied.phone_copy = *phone"
        store_entity_value "copied.name_copy = *name"
      end
    end

    accept_message 'sms://1234', 'copy 1234'

    assert_data "copied",
      {"phone_copy" => 1234.0, "name_copy" => "John"},
      {"phone_copy" => 1234.0, "name_copy" => "Peter"}
  end
end
