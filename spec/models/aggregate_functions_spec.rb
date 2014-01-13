require "spec_helper"

describe "Aggregate functions" do
  let(:application) { new_application "Users: Age" }

  before(:each) do
    add_data "users", [
      {"age" => "10"},
      {"age" => "20"},
      {"age" => "40"},
      {"age" => "80"},
    ]
  end

  it "does list of" do
    new_trigger do
      message "foo"
      send_message "'1111'", "{*age}"
    end
    ctx = accept_message 'sms://1234', 'foo'
    msg = ctx.messages[0]

    found = false
    %w(10 20 40 80).permutation do |perm|
      if msg[:body] == perm.join(", ")
        found = true
        break
      end
    end

    fail "Message was #{msg[:body]}" unless found
  end

  it "does count of" do
    new_trigger do
      message "foo"
      send_message "'1111'", "{*count(age)}"
    end
    ctx = accept_message 'sms://1234', 'foo'
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "4", :"mbuilder-application" => application.id}])
  end

  it "does sum of" do
    new_trigger do
      message "foo"
      send_message "'1111'", "{*total(age)}"
    end
    ctx = accept_message 'sms://1234', 'foo'
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "150", :"mbuilder-application" => application.id}])
  end

  it "does avg of" do
    new_trigger do
      message "foo"
      send_message "'1111'", "{*mean(age)}"
    end
    ctx = accept_message 'sms://1234', 'foo'
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "37.5", :"mbuilder-application" => application.id}])
  end

  it "does max of" do
    new_trigger do
      message "foo"
      send_message "'1111'", "{*max(age)}"
    end
    ctx = accept_message 'sms://1234', 'foo'
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "80", :"mbuilder-application" => application.id}])
  end

  it "does min of" do
    new_trigger do
      message "foo"
      send_message "'1111'", "{*min(age)}"
    end
    ctx = accept_message 'sms://1234', 'foo'
    ctx.messages.should eq([{from: "app://mbuilder", to: "sms://1111", body: "10", :"mbuilder-application" => application.id}])
  end
end
