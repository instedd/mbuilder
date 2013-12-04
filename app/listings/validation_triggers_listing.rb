class ValidationTriggersListing < Listings::Base

  model do
    @application = Application.find(params[:application_id])
    @application.validation_triggers
  end

  sortable false

  column "Column" do |trigger|
    "#{trigger.table_name} #{trigger.field_name}"
  end

  column '', class: 'right' do |trigger|
    [
      link_to("edit", application_validation_trigger_path(@application, trigger.field_guid)),
      link_to("delete", [@application, trigger], method: :delete, confirm: "Are you sure you want to delete the validation trigger for '#{trigger.table_name} #{trigger.field_name}'")
    ].join(' ').html_safe
  end

end
