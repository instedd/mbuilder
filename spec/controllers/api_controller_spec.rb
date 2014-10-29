require 'spec_helper'

describe ApiController do
  let(:current_user) { User.make }
  before(:each) { sign_in current_user }

  it "should list external triggers that use oauth of all user's apps" do
    application_1 = current_user.applications.make name: "App 1"
    trigger_1 = application_1.external_triggers.make name: "Trigger", auth_method: :oauth

    application_2 = current_user.applications.make name: "App 2"
    trigger_2 = application_2.external_triggers.make name: "Trigger", auth_method: :oauth

    get :actions
    data = JSON.parse(response.body)
    data.count.should eq(2)
    data[0]["action"].should eq("App 1 - Trigger")
    data[1]["action"].should eq("App 2 - Trigger")
  end

  it "should not list external triggers that donn't use oauth" do
    application_1 = current_user.applications.make name: "App 1"
    trigger_1 = application_1.external_triggers.make name: "Trigger", auth_method: :basic_auth

    get :actions
    data = JSON.parse(response.body)
    data.count.should eq(0)
  end

  # instance_eval_trigger_helper requires an "application in the context"
  context do
    let(:application) { Application.make name: "App Name", user: current_user}

    it "describe external triggers" do
      trigger_with_parameters = new_external_trigger do
        params [:phone, :name]
      end
      trigger_with_parameters.name = "Trigger Name"
      trigger_with_parameters.auth_method = :oauth
      trigger_with_parameters.save!

      get :actions
      description = JSON.parse(response.body)[0].with_indifferent_access

      description[:action].should eq("App Name - Trigger Name")
      description[:method].should eq("POST")
      description[:url].should eq("http://test.host/external/application/#{trigger_with_parameters.application_id}/trigger/Trigger%20Name")
      description[:parameters].should eq([
        {"name" => "phone", "type" => "string"},
        {"name" => "name", "type" => "string"}
      ])
    end
  end

end
