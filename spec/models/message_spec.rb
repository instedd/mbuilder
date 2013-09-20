require "spec_helper"

describe Message do
  it "compiles message with single word" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'John'},
        {'kind' => 'text', 'text' => 'now'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(\\S+)\\s+now\\s*\\Z")
  end

  it "compiles message with single word at the end" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'John'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(.+)\\s*\\Z")
  end

  it "compiles message with multiple word" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'John Doe'},
        {'kind' => 'text', 'text' => 'as user'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(.+)\\s+as\\ user\\s*\\Z")
  end

  it "compiles message with integer" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => '1234'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(\\d+)\\s*\\Z")
  end

  it "compiles message with float" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => '1234.56'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(\\d+\\.\\d+)\\s*\\Z")
  end

  it "compiles message and escapes text" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => "."},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*\\.\\s*\\Z")
  end
end
