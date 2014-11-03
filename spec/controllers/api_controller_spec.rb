require 'spec_helper'

describe ApiController do
  let(:current_user) { User.make }
  before(:each) { sign_in current_user }

  it "should list all user's apps" do
    application_1 = current_user.applications.make name: "App 1"

    application_2 = current_user.applications.make name: "App 2"

    get :applications
    data = JSON.parse(response.body)
    data.count.should eq(2)
    data[0]["name"].should eq("App 1")
    data[0]["id"].should eq(application_1.id)
    data[0]["actions"].should eq("http://test.host/api/applications/#{application_1.id}/actions")
    data[1]["name"].should eq("App 2")
  end

  it "should list external triggers that use oauth of the given app" do
    application_1 = current_user.applications.make name: "App 1"
    trigger_1 = application_1.external_triggers.make name: "Trigger1", auth_method: :oauth
    trigger_2 = application_1.external_triggers.make name: "Trigger2", auth_method: :oauth

    application_2 = current_user.applications.make name: "App 2"
    trigger_3 = application_2.external_triggers.make name: "Trigger3", auth_method: :oauth

    get :actions, id: application_1.id
    data = JSON.parse(response.body)
    data.count.should eq(2)
    data[0]["action"].should eq("Trigger1")
    data[1]["action"].should eq("Trigger2")
  end

  it "should not list external triggers that donn't use oauth" do
    application_1 = current_user.applications.make name: "App 1"
    trigger_1 = application_1.external_triggers.make name: "Trigger", auth_method: :basic_auth

    get :actions, id: application_1.id
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

      get :actions, id: application.id
      description = JSON.parse(response.body)[0].with_indifferent_access

      description[:action].should eq("Trigger Name")
      description[:method].should eq("POST")
      description[:id].should eq(trigger_with_parameters.id)
      description[:url].should eq("http://localhost:3000/external/application/#{trigger_with_parameters.application_id}/trigger/Trigger%20Name")
      description[:parameters].should eq({
        "phone" => {"label" => "Phone", "type" => "string"},
        "name" => {"label" => "Name", "type" => "string"}
      })
    end
  end
end
