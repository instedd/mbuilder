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
    msg.pattern.source.should eq("\\A\\s*register\\s+([^0-9\s]\\S*)\\s+now\\s*\\Z")

    "register Foo now".should match(msg.pattern)
    "register Foo bar now".should_not match(msg.pattern)
  end

  it "compiles message with single word with spaces" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => ' register '},
        {'kind' => 'placeholder', 'text' => 'John'},
        {'kind' => 'text', 'text' => ' now '},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+([^0-9\s]\\S*)\\s+now\\s*\\Z")

    "register  Foo  now".should match(msg.pattern)
    "register  Foo  bar  now".should_not match(msg.pattern)
  end

  it "should initialize pattern correctly for a multi-word with non-break whitespaces text without pills" do
    pieces = [MessagePiece.new("text", "\u00A0count\u00A0all\u00A0users\u00A0", "ce947362-990f-4749-beaa-3878ff9fd94d")]
    message = Message.new('1234', pieces)
    message.pattern.should eq(/\A\s*count\ all\ users\s*\Z/i)
  end

  it "compiles message with single word with non-break whitespaces" do
    # The ending space is the non-breaking space copy and pasted
    # This was being added by the svg pill
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => "\u00A0register "},
        {'kind' => 'placeholder', 'text' => 'John'},
        {'kind' => 'text', 'text' => ' now '},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+([^0-9\s]\\S*)\\s+now\\s*\\Z")

    "register Foo now".should match(msg.pattern)
    "register  Foo  bar now".should_not match(msg.pattern)
  end

  it "compiles message with single word disease code" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'A90'},
        {'kind' => 'text', 'text' => 'now'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(\\S+)\\s+now\\s*\\Z")

    "register B91 now".should match(msg.pattern)
    "register 191 now".should match(msg.pattern)
    "register B91 bar now".should_not match(msg.pattern)
  end

  it "compiles message with single word at the end" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'John'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+([^0-9\s]\\S*)\\s*\\Z")

    "register Foo".should match(msg.pattern)
    "register Foo bar".should_not match(msg.pattern)
    "register 123".should_not match(msg.pattern)
  end

  it "compiles message with multiple word" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'John Doe'},
        {'kind' => 'text', 'text' => 'as user'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(.+?)\\s+as\\ user\\s*\\Z")

    "register Foo as user".should match(msg.pattern)
    "register Foo bar as user".should match(msg.pattern)
    "register 123 456 as user".should match(msg.pattern)
    "register as user".should_not match(msg.pattern)
    "register foo user".should_not match(msg.pattern)
  end

  it "compiles message with integer" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => '1234'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(\\d+)\\s*\\Z")

    "register 1234".should match(msg.pattern)
    "register foo".should_not match(msg.pattern)
    "register f12".should_not match(msg.pattern)
    "register 12f".should_not match(msg.pattern)
  end

  it "compiles message with float" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => '1234.56'},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+(\\d+(?:\\.\\d+)?)\\s*\\Z")

    "register 1234.32".should match(msg.pattern)
    "register 1234".should match(msg.pattern)
    "register foo".should_not match(msg.pattern)
    "register 1foo".should_not match(msg.pattern)
  end

  it "compiles message and escapes text" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => "."},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*\\.\\s*\\Z")

    ".".should match(msg.pattern)
    ",".should_not match(msg.pattern)
  end

  it "compiles message with single word and empty text" do
    msg = Message.from_hash({
      'pieces' => [
        {'kind' => 'text', 'text' => 'register'},
        {'kind' => 'placeholder', 'text' => 'John'},
        {'kind' => 'text', 'text' => ''},
      ]
    })
    msg.pattern.source.should eq("\\A\\s*register\\s+([^0-9\s]\\S*)\\s*\\Z")

    "register Foo".should match(msg.pattern)
    "register Foo bar".should_not match(msg.pattern)
  end
end
