require "spec_helper"

describe ExternalTrigger do
  let(:application) {Application.make name: "App Name"}
  let(:external_trigger) { ExternalTrigger.make name: "Trigger Name", application: application }

  it "should build url" do
    external_trigger.trigger_run_url("test.com").should eq("http://test.com/external/application/#{external_trigger.application_id}/trigger/Trigger%20Name")
  end

  it "should generate api decription for basic fields" do
    description = external_trigger.api_action_description("test.com")
    description[:action].should eq("App Name - Trigger Name")
    description[:method].should eq("POST")
    description[:url].should eq("http://test.com/external/application/#{external_trigger.application_id}/trigger/Trigger%20Name")
  end

  it "should generate api decription for triggers' parameters" do
    trigger_with_parameters = new_external_trigger do
      params [:phone, :name]
    end

    description = trigger_with_parameters.api_action_description("test.com")
    description[:parameters].should eq([
      {:name=>:phone, :type=>"string"},
      {:name=>:name, :type=>"string"}
    ])
  end
end
