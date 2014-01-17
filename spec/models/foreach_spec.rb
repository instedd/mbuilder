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
      message "copy {1111}"
      select_entity "users.phone = {1111}"
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

  it "loops and selects entities" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "Foo"},
      {"phone" => 1234.0, "name" => "Bar"},
      {"phone" => 5678.0, "name" => "Baz"},
    ]

    add_data "copied", [
      {"phone_copy" => 2345.0, "name_copy" => "Foo"},
      {"phone_copy" => 3456.0, "name_copy" => "Bar"},
    ]

    new_trigger do
      message "filter {1111}"
      select_entity "users.phone = {1111}"
      foreach("users") do
        select_entity "copied.name_copy = *name"
        send_message "*phone_copy", "{*name_copy}"
      end
    end

    ctx = accept_message 'sms://1234', 'filter 1234'

    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://2345", body: "Foo", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://3456", body: "Bar", :"mbuilder-application" => application.id},
    ]
  end
end
