require 'spec_helper'

describe ExternalTriggersController do
  let(:application) { new_application "Users: Phone, Name" }
  let(:current_user) { application.user }

  before(:each) { sign_in current_user }

  it "creates an entity" do
    trigger = new_external_trigger do
      params :phone
      create_entity "users.phone = {?phone}"
    end
    post :run, application_id: application.id, trigger_name: trigger.name, phone: 1234, format: :json
    assert_data "users", {"phone" => 1234.0}
  end

  it "creates an entity with timestamp" do
    Timecop.freeze(Time.utc(2013, 9, 17, 6, 0, 0))
    trigger = new_external_trigger do
      params :phone
      create_entity "users.phone = {{received_at}}"
    end
    post :run, application_id: application.id, trigger_name: trigger.name, phone: 1234, format: :json
    assert_data "users", {"phone" => Time.now.strftime("%Y%m%d").to_f}
    Timecop.return
  end

  it "should not run a disabled trigger" do
    trigger = new_external_trigger do
      params :phone
      create_entity "users.phone = {?phone}"
    end

    trigger.enabled = false
    trigger.save!

    post :run, application_id: application.id, trigger_name: trigger.name, phone: 1234, format: :json

    assert_data "users", []
  end
end
