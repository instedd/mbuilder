require "spec_helper"

describe NuntiumController do
  let(:application) { new_application("Users: Phone, Name") }

  before(:each) do
    application.channels.create! name: 'channel_name', pigeon_name: 'pigeon_channel_name'
  end

  it "accepts message and creates entity" do
    new_trigger do
      message "register {Name}"
      create_entity "users.phone = implicit phone number"
    end

    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{Nuntium::Config['incoming_username']}:#{Nuntium::Config['incoming_password']}")

    get :receive_at, channel: 'pigeon_channel_name', from: 'sms://1234', body: 'register Peter'

    assert_data("users", {"phone" => "1234"})
  end
end
