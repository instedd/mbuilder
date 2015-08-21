require "spec_helper"

describe PeriodicTasksController do
  let(:application) {
    new_application("Users: Phone, Name").tap do |app|
      app.time_zone = "Rome"
      app.save!
    end
  }
  let(:current_user) { application.user }
  before(:each) { sign_in current_user }

  before (:each) { Timecop.freeze(Time.utc(2013, 9, 17, 6, 0, 0)) }
  after (:each) { Timecop.return }

  include PeriodicTasksHelper

  it "preserves user choosen time" do
    expect(application.periodic_tasks.count).to eq(0)

    @request.env['RAW_POST_DATA'] = {
      "name"=>"Lorem",
      "enabled"=>true,
      "tables"=>nil,
      "schedule"=>"{\"validations\":null,\"rule_type\":\"IceCube::DailyRule\",\"interval\":1,\"week_start\":0,\"until\":null,\"count\":null}",
      "scheduleTime"=>"16:00:00",
      "actions"=>nil
    }.to_json
    post :create, { application_id: application.id }

    expect(application.periodic_tasks.count).to eq(1)

    pt = application.periodic_tasks.first
    ngpt = periodic_task_to_angular(application, pt)
    ngpt.should include("16:00:00")
  end
end
