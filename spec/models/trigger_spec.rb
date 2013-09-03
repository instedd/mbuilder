require "spec_helper"

describe Trigger do
  it "compiles pattern before save" do
    trigger = Trigger.make_unsaved

    message = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => 'John'},
      ]
    })

    trigger.logic = Logic.new(message, [])
    trigger.save!

    trigger.reload
    trigger.pattern.should eq("\\A\\s*register\\s+(.+)\\s*\\Z")
  end
end
