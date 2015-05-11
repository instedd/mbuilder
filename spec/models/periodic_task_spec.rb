require "spec_helper"
describe "PeriodicTask" do

  before (:each) { Timecop.freeze(Time.utc(2013, 9, 17, 6, 0, 0)) }
  after (:each) { Timecop.return }
  let(:application) { new_application "Users: Phone, Name" }

  it "should schedule a message for the next calendar occurrence" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "Peter"}
    ]

    new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday)
      send_message "'5678'", "Hello {*name} at {*phone}"
    end

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 20, 6, 0, 0))
    wake_up_event.scheduled_time.should be_near_of(Time.zone.now)
    job.run_at.should be_near_of(Time.zone.now)
  end

  it "should send a delayed message" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "Peter"}
    ]

    new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday)
      send_message "'5678'", "Hello {*name} at {*phone}"
    end

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    context = wake_up_event.perform

    context.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter at 1234", :"mbuilder-application" => application.id}])
  end

  it "should create a delayed entity" do
    new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday)
      create_entity "users.phone = '1234'"
    end

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    wake_up_event.perform

    assert_data "users", {'phone' => 1234.0}
  end

  it "should re-schedule a job when running a message" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "Peter"}
    ]

    new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday), at: (Time.now.utc + 3600)
      send_message "'5678'", "Hello {*name} at {*phone}"
    end

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 20, 7, 0, 0))

    wake_up_event.scheduled_time.should be_near_of(Time.now.utc)
    job.run_at.should be_near_of(Time.now.utc)

    job.delete
    wake_up_event.perform.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter at 1234", :"mbuilder-application" => application.id}])

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 27, 7, 0, 0))

    wake_up_event.scheduled_time.should be_near_of(Time.now.utc)
    job.run_at.should be_near_of(Time.now.utc)

    wake_up_event.perform.messages.should eq([{from: "app://mbuilder", to: "sms://5678", body: "Hello Peter at 1234", :"mbuilder-application" => application.id}])
  end

  it "should re-schedule a job when updating the trigger" do
    add_data "users", [
      {"phone" => 1234.0, "name" => "Peter"}
    ]

    task = new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday), at: (Time.now.utc + 3600)
      send_message "'5678'", "Hello {*name} at {*phone}"
    end

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 20, 7, 0, 0))

    wake_up_event.scheduled_time.should be_near_of(Time.now.utc)
    job.run_at.should be_near_of(Time.now.utc)

    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 18, 5, 0, 0))

    new_schedule = IceCube::Schedule.new(Time.now.utc + 3600)
    new_schedule.add_recurrence_rule IceCube::Rule.weekly.day(:sunday)
    task.schedule = new_schedule

    task.save

    assert_equal 1, Delayed::Job.count
    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)

    Timecop.return
    Timecop.freeze(Time.utc(2013, 9, 22, 6, 0, 0))

    wake_up_event.scheduled_time.should be_near_of(Time.now.utc)
    job.run_at.should be_near_of(Time.now.utc)
  end

  it "should delete job when deleting task" do
    task = new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday)
      create_entity "users.phone = '1234'"
    end

    task.destroy

    Delayed::Job.count.should eq(0)
  end

  it "should not schedule job if disabled" do
    task = new_periodic_task do
      rule IceCube::Rule.daily
    end

    task.enabled = false
    task.save!

    Delayed::Job.count.should eq(0)
  end

  it "should save logs" do
    trigger = new_periodic_task do
      rule IceCube::Rule.daily
    end
    trigger.save!

    job = Delayed::Job.first
    wake_up_event = YAML.load(job.handler)
    wake_up_event.perform

    ExecutionLogger.where(trigger_id: trigger).count.should be(1)
  end
end
