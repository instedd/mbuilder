require "spec_helper"

describe "Foreach" do
  let(:application) { new_application "Users: Phone, Name, NameOld; Copied: PhoneCopy, NameCopy" }

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

  it "loops and update entities" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "John"},
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 5678.0, "name" => "Doe", "name_old" => "n/a"},
    ]

    new_trigger do
      message "update {1111}"
      select_entity "users.phone = {1111}"
      foreach("users") do
        store_entity_value "users.name_old = *name"
      end
    end

    accept_message 'sms://1234', 'update 1234'

    assert_data "users",
      {"phone" => 1234.0, "name" => "John", "name_old" => "John"},
      {"phone" => 1234.0, "name" => "Peter", "name_old" => "Peter"},
      {"phone" => 5678.0, "name" => "Doe", "name_old" => "n/a"}
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

  it "loops and selects entities where there's a top select" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "Foo"},
      {"phone" => 1234.0, "name" => "Bar"},
      {"phone" => 5678.0, "name" => "Baz"},
    ]

    add_data "copied", [
      {"phone_copy" => 1234.0, "name_copy" => "Foo"},
      {"phone_copy" => 1234.0, "name_copy" => "Bar"},
    ]

    new_trigger do
      message "filter {1111}"
      select_entity "users.phone = {1111}"
      select_entity "copied.phone_copy = {1111}"
      foreach("users") do
        select_entity "copied.name_copy = *name"
        send_message "*phone_copy", "{*name_copy}"
      end
    end

    ctx = accept_message 'sms://1234', 'filter 1234'

    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "Foo", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://1234", body: "Bar", :"mbuilder-application" => application.id},
    ]
  end

  it "loops with group by" do
    add_data "users", [
      {"phone" => 1234.0, "name" => 1.0},
      {"phone" => 1234.0, "name" => 2.0},
      {"phone" => 5678.0, "name" => 10.0},
    ]

    new_trigger do
      message "iterate"
      group_by "users.phone"
      foreach("users") do
        send_message "*phone", "{*phone} {*total(name)}"
      end
    end

    ctx = accept_message 'sms://1234', 'iterate'

    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "1234 3", :"mbuilder-application" => application.id},
      {from: "app://mbuilder", to: "sms://5678", body: "5678 10", :"mbuilder-application" => application.id},
    ]
  end
end
