class Contact < ActiveRecord::Base
  attr_accessible :address
  belongs_to :application

  def self.record_outgoing_message_at(application, address, time)
    contact = application.contacts.find_or_initialize_by_address(address.with_protocol("sms"))
    contact.last_outgoing_at = [contact.last_outgoing_at, time.utc].compact.max
    contact.save!
  end

  def self.record_outgoing_message(application, address)
    record_outgoing_message_at(application, address, Time.now)
  end

  def self.record_incoming_message_at(application, address, time)
    contact = application.contacts.find_or_initialize_by_address(address.with_protocol("sms"))
    contact.last_incoming_at = [contact.last_incoming_at, time.utc].compact.max
    contact.save!
  end

  def self.record_incoming_message(application, address)
    record_incoming_message_at(application, address, Time.now)
  end

end
