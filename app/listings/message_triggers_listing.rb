class MessageTriggersListing < Listings::Base

  model do
    @application = Application.find(params[:application_id])
    @application.message_triggers.order('name')
  end

  sortable false

  column :name

  column 'Sample message' do |trigger|
    (trigger.message.pieces.map {|p|
      if p.kind == "placeholder"
        content_tag :span, p.text, class: 'pill sample'
      else
        h p.text
      end
    }).join(' ').html_safe
  end

  column '', class: 'right' do |trigger|
    [
      link_to("edit", edit_application_message_trigger_path(@application, trigger)),
      link_to("delete", [@application, trigger], method: :delete, confirm: "Are you sure you want to delete the trigger '#{trigger.name}'")
    ].join(' ').html_safe
  end

end
