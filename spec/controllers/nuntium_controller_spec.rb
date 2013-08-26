require "spec_helper"

describe NuntiumController do
  let(:application) { Application.make_unsaved }

  before(:each) do
    application.tables = Table.from_list([
      {
        'name' => 'Users',
        'guid' => 'users',
        'fields' => [
          {'name' => 'Phone', 'guid' => 'phone'},
          {'name' => 'Name', 'guid' => 'name'},
        ]
      }
    ])
    application.save!

    application.channels.create! name: 'channel_name'

    message = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => 'John', 'guid' => 'name'},
      ]
    })

    actions = Action.from_list([
      {'kind' => 'create_entity', 'table' => 'users', 'field' => 'phone', 'pill' => {'kind' => 'implicit', 'guid' => 'phone number'}},
    ])

    trigger = application.triggers.make_unsaved
    trigger.logic = Logic.new message, actions
    trigger.save!
  end

  it "accepts message and creates entity" do
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{Nuntium::Config['incoming_username']}:#{Nuntium::Config['incoming_password']}")

    get :receive_at, channel: 'channel_name', from: 'sms://1234', body: 'register Peter'

    index = application.tire_index
    index.exists?.should be_true

    results = application.tire_search("users").perform.results
    results.length.should eq(1)
    result = results[0]
    result.type.should eq("users")
    result.properties["phone"].should eq("1234")
  end
end
