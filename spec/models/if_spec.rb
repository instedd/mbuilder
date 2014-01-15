require "spec_helper"

describe "If" do
  let(:application) { new_application "Users: Phone, Name" }

  it "executes an action conditionally" do
    new_trigger do
      message "say {Text}"
      iff("{text} == 'hello'") do
        send_message "'1234'", "Hi"
      end
    end

    ctx = accept_message 'sms://1234', 'say hello'

    assert_sets_equal ctx.messages, [
      {from: "app://mbuilder", to: "sms://1234", body: "Hi", :"mbuilder-application" => application.id},
    ]
  end

  it "doesn't execute an action conditionally" do
    new_trigger do
      message "say {Text}"
      iff("{text} == 'hello'") do
        send_message "'1234'", "Hi"
      end
    end

    ctx = accept_message 'sms://1234', 'say bye'

    assert_sets_equal ctx.messages, []
  end

  describe "Operator" do
    let(:op) { Actions::If::Operator }

    it "executes == gives true" do
      op.execute("foo", "==", ["foo"]).should be_true
    end

    it "executes == gives false" do
      op.execute("foo", "==", ["fog"]).should be_false
    end

    it "executes == with numbers gives true" do
      op.execute("20", "==", ["20.0"]).should be_true
    end

    it "executes contains gives true" do
      op.execute("foo bar", "contains", ["oo ba"]).should be_true
    end

    it "executes contains gives false" do
      op.execute("foo bar", "contains", ["oo baz"]).should be_false
    end

    it "executes greater than gives true" do
      op.execute(20, ">", [10]).should be_true
    end

    it "executes greater than gives false" do
      op.execute(20, ">", [20]).should be_false
    end

    it "executes greater than with strings gives true" do
      op.execute("020", ">", ["10"]).should be_true
    end

    it "executes greater than with strings gives false" do
      op.execute("20", ">", ["20"]).should be_false
    end

    it "executes less than gives false" do
      op.execute(20, "<", [10]).should be_false
    end

    it "executes less than gives true" do
      op.execute(10, "<", [20]).should be_true
    end

    it "executes less than with strings gives false" do
      op.execute("020", "<", ["10"]).should be_false
    end

    it "executes less than with strings gives true" do
      op.execute("010", "<", ["20"]).should be_true
    end

    it "executes != gives true" do
      op.execute("foo", "!=", ["fog"]).should be_true
    end

    it "executes == gives false" do
      op.execute("foo", "!=", ["foo"]).should be_false
    end

    it "executes != with numbers gives true" do
      op.execute("20", "!=", ["20.0"]).should be_false
    end

    it "executes between gives true" do
      op.execute("20", "between", ["10", "30"]).should be_true
    end

    it "executes between gives false" do
      op.execute("20", "between", ["25", "30"]).should be_false
    end

    it "executes between gives false (2)" do
      op.execute("20", "between", ["10", "15"]).should be_false
    end

    it "executes not between gives false" do
      op.execute("20", "not between", ["10", "30"]).should be_false
    end

    it "executes not between gives true" do
      op.execute("20", "not between", ["25", "30"]).should be_true
    end

    it "executes not between gives true (2)" do
      op.execute("20", "not between", ["10", "15"]).should be_true
    end
  end
end
