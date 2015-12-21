require "spec_helper"

describe ExternalTrigger do
  include_examples 'application lifespan', described_class

  let(:application) { Application.make name: "App Name" }
  let(:external_trigger) { ExternalTrigger.make name: "Trigger Name", application: application }

  it "should build url" do
    external_trigger.trigger_run_url.should eq("http://#{Settings.host}/external/application/#{external_trigger.application_id}/trigger/Trigger%20Name")
  end

  it "should generate api decription for basic fields" do
    description = external_trigger.api_action_description
    description[:action].should eq("Trigger Name")
    description[:method].should eq("POST")
    description[:url].should eq("http://#{Settings.host}/external/application/#{external_trigger.application_id}/trigger/Trigger%20Name")
  end

  it "should generate api decription for triggers' parameters" do
    trigger_with_parameters = new_external_trigger do
      params [:phone, :name]
    end

    description = trigger_with_parameters.api_action_description
    description[:parameters].should eq({
      :phone=>{:label=>"Phone", :type=>"string"},
      :name=>{:label=>"Name", :type=>"string"}
    })
  end

  it "should validates paremeters name" do
    trigger = unsaved_external_trigger do
      params [""]
    end

    trigger.should_not be_valid
    trigger.errors.full_messages.first.should eq("Parameter name can't be blank")
  end

  it "should validates paremeters uniqueness" do
    trigger = unsaved_external_trigger do
      params [:a, :a]
    end

    trigger.should_not be_valid
    trigger.errors.full_messages.first.should eq("Parameters name must be unique")
  end

  it 'reports execution to telemetry' do
    InsteddTelemetry.should_receive(:counter_add).with('trigger_execution', {type: 'external'}, 1)

    external_trigger.actions = []
    external_trigger.execute(nil)
  end
end
