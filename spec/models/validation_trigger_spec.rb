require "spec_helper"

describe ValidationTrigger do
  let(:application) { new_application "Users: Phone, Name" }

  before(:each) do
    application.tables.first.fields.first.instance_eval { @valid_values = "1-5" }
    application.save!
  end

  it "fires validation trigger on invalid value on create" do
    new_trigger do
      message "register {Variable}"
      create_entity "users.phone = {variable}"
      send_message "'1234'", "Hello!"
    end

    new_validation_trigger('phone') do
      send_message "{phone_number}", "You sent the invalid value '{{invalid_value}}'"
    end

    ctx = accept_message "sms://5678", "register 6"

    assert_data "users"

    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "You sent the invalid value '6'"}])
  end

  it "fires validation trigger on invalid value on store" do
    new_trigger do
      message "register {Variable}"
      create_entity "users.name = 'Foo'"
      store_entity_value "users.phone = {variable}"
      send_message "'1234'", "Hello!"
    end

    new_validation_trigger('phone') do
      send_message "{phone_number}", "You sent the invalid value '{{invalid_value}}'"
    end

    ctx = accept_message "sms://5678", "register 7"

    assert_data "users"

    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "You sent the invalid value '7'"}])
  end
end
