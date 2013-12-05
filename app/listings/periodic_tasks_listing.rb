class PeriodicTasksListing < Listings::Base

  model do
    @application = Application.find(params[:application_id])
    @application.periodic_tasks
  end

  sortable false

  column :name

  # Next run at 12:34 (in 3 minutes), last run on Wed 13 12:23 (1 day ago)

  column 'Rext run' do |trigger|
    distance_of_time_in_words(Time.now, trigger.schedule.next_occurrence(Time.now).to_time, true) if trigger.schedule.next_occurrence(Time.now)
  end

  column 'Last run' do |trigger|
    distance_of_time_in_words(Time.now, trigger.schedule.previous_occurrence(Time.now).to_time, true) + ' ago' if trigger.schedule.previous_occurrence(Time.now)
  end

  column '', class: 'right' do |trigger|
    [
      link_to("edit", edit_application_periodic_task_path(@application, trigger)),
      link_to("delete", [@application, trigger], method: :delete, confirm: "Are you sure you want to delete the trigger '#{trigger.name}'")
    ].join(' ').html_safe
  end

end
