require "spec_helper"

describe Application do
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
  end

  it "accepts message and creates table" do
    message = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => 'John', 'guid' => 'name'},
      ]
    })

    actions = Action.from_list([
      {'kind' => 'create_table', 'table' => 'users', 'field' => 'phone', 'pill' => {'kind' => 'implicit', 'guid' => 'phone number'}},
    ])

    trigger = application.triggers.make_unsaved
    trigger.logic = Logic.new message, actions
    trigger.save!

    application.accept_message(from: 'sms://1234', body: 'register Peter')

    index = application.tire_index
    index.exists?.should be_true

    results = application.tire_search.perform.results
    results.length.should eq(1)
    result = results[0]
    result.type.should eq("users")
    result.properties["phone"].should eq("1234")
  end
end
