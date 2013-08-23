require "spec_helper"

describe Message do
  it "compiles message with single word" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => 'John'},
      ]
    })
    msg.compile.should eq("\\A\\s*register\\s+(\\w+)\\s*\\Z")
  end

  it "compiles message with multiple word" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => 'John Doe'},
        {'kind' => 'text', 'text' => 'as user'},
      ]
    })
    msg.compile.should eq("\\A\\s*register\\s+([\\w\\s]+)\\s+as user\\s*\\Z")
  end

  it "compiles message with integer" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => '1234'},
      ]
    })
    msg.compile.should eq("\\A\\s*register\\s+(\\d+)\\s*\\Z")
  end

  it "compiles message with float" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'pill', 'text' => '1234.56'},
      ]
    })
    msg.compile.should eq("\\A\\s*register\\s+(\\d+\\.\\d+)\\s*\\Z")
  end
end
