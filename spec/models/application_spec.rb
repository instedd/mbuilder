require "spec_helper"
require "tempfile"

describe Application do
  let(:application) { new_application "Users: Phone, Name" }

  it "exports and imports" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = {phone_number}"
    end
    new_periodic_task do
      rule IceCube::Rule.weekly.day(:friday)
      send_message "'5678'", "Hello {*name} at {*phone}"
    end
    new_validation_trigger('phone') do
      send_message "{phone_number}", "You sent the invalid value '{{invalid_value}}'"
    end

    trigger_with_parameters = new_external_trigger do
      params ['phone', 'name']
      send_message "{phone_number}", "Hello {{name}}!"
    end
    trigger_with_parameters.name = "External hello"
    trigger_with_parameters.auth_method = :oauth

    file = Tempfile.new("app")
    path = file.path

    application.export file

    file.close

    file = File.new(path, "r")

    app2 = Application.make
    app2.import! file

    app2.tables.should eq(application.tables)
    app2.message_triggers.all.should eq(application.message_triggers.all)
    app2.periodic_tasks.all.should eq(application.periodic_tasks.all)
    app2.validation_triggers.all.should eq(application.validation_triggers.all)
    app2.external_triggers.all.should eq(application.external_triggers.all)
  end

  it "exports and imports an empty application" do
    app = Application.make
    hash_app_before = app.to_json

    file = Tempfile.new("app")
    path = file.path
    app.export file
    file.close

    file = File.new(path, "r")

    app.import! file

    app.to_json.should eq(hash_app_before)
  end

  it "rebuilds local tables data" do
    users = application.elastic_record_for application.find_table_by_name('Users')
    users.create [{phone: 234567, name: 'john'},{phone: 234567, name: 'mary'}]

    application.rebuild_local_tables

    users = application.elastic_record_for application.find_table_by_name('Users')
    users.count.should eq(2)
  end
end
