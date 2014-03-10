class ExternalTriggersListing < Listings::Base

  model do
    @application = Application.find(params[:application_id])
    @application.external_triggers
  end

  sortable false

  column :name

  column '', class: 'right' do |trigger|
    [
      link_to("edit", edit_application_external_trigger_path(@application, trigger)),
      link_to("delete", [@application, trigger], method: :delete, confirm: "Are you sure you want to delete the trigger '#{trigger.name}'")
    ].join(' ').html_safe
  end

end
