require 'spec_helper'

describe ExternalTriggersController do
  let(:application) { new_application "Users: Phone, Name" }
  let(:current_user) { application.user }

  before(:each) { sign_in current_user }

  it "creates an entity" do
    trigger = new_external_trigger do
      params :phone
      create_entity "users.phone = {phone}"
    end
    post :run, application_id: application.id, trigger_name: trigger.name, phone: 1234, format: :json
    assert_data "users", {"phone" => 1234.0}
  end
end
