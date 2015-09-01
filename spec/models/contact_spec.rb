require 'spec_helper'

describe Contact do
  describe "automatic registration" do
    let(:application) { new_application "" }

    def contact(address)
      application.contacts.where(address: address).first
    end

    it "creates a contact for sender" do
      time = Time.new(2015, 9, 1, 15, 33, 0)

      Timecop.freeze(time) do
        accept_message 'sms://1234', 'lorem'
      end

      contact('sms://1234').should_not be_nil
      contact('sms://1234').last_incoming_at.should eq(time)
    end

    it "does not create more than one contact per address" do
      new_trigger do
        message "lorem"
        send_message "{phone_number}", "ipsum"
      end

      accept_message 'sms://1234', 'lorem'
      accept_message 'sms://1234', 'lorem'

      contact('sms://1234').should_not be_nil
      application.contacts.count.should eq(1)
    end

    it "creates a contact for receiver" do
      new_trigger do
        message "lorem"
        send_message "'5678'", "ipsum"
      end

      contact('sms://5678').should be_nil

      time = Time.new(2015, 9, 1, 15, 33, 0)
      Timecop.freeze(time) do
        accept_message 'sms://1234', 'lorem'
      end

      contact('sms://5678').should_not be_nil
      contact('sms://5678').last_outgoing_at.should eq(time)
    end

  end
end
