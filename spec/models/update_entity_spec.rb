require "spec_helper"

describe "Update entity" do
  let(:application) { new_application "Users: Phone, Name; Reports: Key1, Key2, Value, Other" }

  it "updates entities with a literal value" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "John"},
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 5678.0, "name" => "Doe"},
    ]
    new_trigger do
      message "rename {1111}"
      select_entity "users.phone = {1111}"
      store_entity_value "users.name = 'NewName'"
    end
    accept_message 'sms://1234', 'rename 1234'
    assert_data "users", [
      {"phone" => 1234.0, "name" => "NewName"},
      {"phone" => 1234.0, "name" => "NewName"},
      {"phone" => 5678.0, "name" => "Doe"},
    ]
  end

  it "updates one entity with a stored value" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "John"},
      {"phone" => 5678.0, "name" => "Doe"},
    ]
    new_trigger do
      message "register {Name}"
      select_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {name}"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 5678.0, "name" => "Doe"},
    ]
  end

  it "updates many entities with a stored value" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "John"},
      {"phone" => 1234.0, "name" => "Doe"},
      {"phone" => 5678.0, "name" => "Foo"},
    ]
    new_trigger do
      message "register {Name}"
      select_entity "users.phone = {phone_number}"
      store_entity_value "users.name = {name}"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 5678.0, "name" => "Foo"},
    ]
  end

  it "updates all entities with a stored value" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "John"},
      {"phone" => 5678.0, "name" => "Doe"},
    ]
    new_trigger do
      message "register {Name}"
      store_entity_value "users.name = {name}"
    end
    accept_message "sms://1234", "register Peter"
    assert_data "users", [
      {"phone" => 1234.0, "name" => "Peter"},
      {"phone" => 5678.0, "name" => "Peter"},
    ]
  end

  describe "create_or_update store_entity" do
    describe "do not create it no create is selected" do
      before(:each) do
        add_data "users", [
          {"phone" => 1234.0, "name" => "John"}
        ]

        new_trigger do
          message "name {Name}"
          select_entity "users.phone = {phone_number}"
          store_entity_value "users.name = {name}"
        end
      end

      it "should update if matching" do
        accept_message "sms://1234", "name Peter"
        assert_data "users", [
          {"phone" => 1234.0, "name" => "Peter"},
        ]
      end

      it "should not create if no matching" do
        accept_message "sms://5768", "name Peter"
        assert_data "users", [
          {"phone" => 1234.0, "name" => "John"},
        ]
      end
    end

    describe "on single fields" do
      before(:each) do
        add_data "users", [
          {"phone" => 1234.0, "name" => "John"}
        ]

        new_trigger do
          message "name {Name}"
          select_entity "users.phone = {phone_number}"
          store_or_create_entity_value "users.name = {name}"
        end
      end

      it "creates if no entity exists" do
        accept_message "sms://5678", "name Peter"
        assert_data "users", [
          {"phone" => 1234.0, "name" => "John"},
          {"phone" => 5678.0, "name" => "Peter"},
        ]
      end

      it "update if entity exists" do
        accept_message "sms://1234", "name Peter"
        assert_data "users", [
          {"phone" => 1234.0, "name" => "Peter"},
        ]
      end
    end

    describe "with multiple criterias" do
      before(:each) do
        add_data "reports", [
          {"key1" => "Acme", "key2" => 20, "value" => "a", "other" => "b"}
        ]

        new_trigger do
          message "on {acme} and {2222} save {abc} with {def}"
          select_entity "reports.key1 = {acme}"
          select_entity "reports.key2 = {2222}"
          store_or_create_entity_value "reports.value = {abc}"
          store_entity_value "reports.other = {def}"
        end
      end

      it "create if no entity exists" do
        accept_message "sms://1234", "on Contoso and 30 save foo with bar"

        assert_data "reports", [
          {"key1" => "Acme", "key2" => 20, "value" => "a", "other" => "b"},
          {"key1" => "Contoso", "key2" => 30, "value" => "foo", "other" => "bar"}
        ]
      end

      it "update if entity exists" do
        accept_message "sms://1234", "on Acme and 20 save foo with bar"

        assert_data "reports", [
          {"key1" => "Acme", "key2" => 20, "value" => "foo", "other" => "bar"}
        ]
      end
    end

    describe "treat store_or_create_entity_value as store_entity_value if its not the first one" do
      it "should ignore the creation flag" do
        new_trigger do
          message "name {Name}"
          select_entity "users.phone = {phone_number}"
          store_entity_value "users.name = {name}"
          store_or_create_entity_value "users.name = {name}"
        end

        accept_message "sms://1234", "name John"

        assert_data "users", []
      end
    end

  end
end
