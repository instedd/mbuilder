class ContactLogsListing < Listings::Base
  css_class 'graygrad'

  layout filters: :top

  model do
    @application = Application.find(params[:application_id])
    match = "%://#{params[:id]}"
    @application.logs
      .where("message_from LIKE ? or message_to LIKE ?", match, match)
      .order 'created_at DESC'
  end

  scope 'All', :all, default: true
  scope 'No trigger matched', :no_triggers
  scope 'With Errors', :with_errors

  filter :trigger_type

  column :trigger do |log|
    log.trigger.name rescue ''
  end

  column :trigger_type

  column :message_from do |log, message_from|
    message_from.try :without_protocol
  end

  column :message_to do |log, message_to|
    message_to.try :without_protocol
  end

  column :message_body

  column :actions do |log|
    content_tag :ul do
      (log.actions_as_strings.map do |item|
        content_tag :li do
          item[:text]
        end
      end).join.html_safe
    end
  end

  column :created_at do |log, created_at|
    time_ago_in_words(created_at) + " ago"
  end
end
