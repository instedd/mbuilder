class ContactsListing < Listings::Base
  css_class 'graygrad'

  model do
    Contact.where(application_id: params[:application_id])
  end

  column :address, title: 'Phone number', searchable: true do |_,address|
    address.without_protocol
  end

  column :last_incoming_at, title: 'Last incoming message' do |_,value|
    time_ago_in_words(value) + " ago" if value
  end

  column :last_outgoing_at, title: 'Last outgoing message' do |_,value|
    time_ago_in_words(value) + " ago" if value
  end

  column '', class: 'button-column' do |contact|
    if format == :html
      link_to application_contact_path(params[:application_id], contact.address.without_protocol), class: 'btn-icon' do
        content_tag :span, '', 'class' => 'ic-wrapper' do
          content_tag :i, '', 'class' => 'icf-arrow'
        end
      end
    end
  end

  export :csv, :xls

end
