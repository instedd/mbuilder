class ContactsListing < Listings::Base
  css_class 'graygrad'

  model do
    Contact.where(application_id: params[:application_id])
  end

  column :address, title: 'Phone number' do |_,address|
    address.without_protocol
  end

  column :last_incoming_at, title: 'Last incoming message' do |_,value|
    time_ago_in_words(value) + " ago" if value
  end

  column :last_outgoing_at, title: 'Last outgoing message' do |_,value|
    time_ago_in_words(value) + " ago" if value
  end

  column '', class: 'button-column' do |contact|
    icon_link_to :'icf-arrow', '', application_contact_path(application, contact.address.without_protocol) if format == :html
  end

  export :csv, :xls

end
