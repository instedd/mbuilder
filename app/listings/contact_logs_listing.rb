class ContactLogsListing < Listings::Base
  css_class 'graygrad'

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

  sortable true

  column :trigger do |log|
    log.trigger.name rescue ''
  end

  column :message_from do |log|
    log.message_from.try :without_protocol
  end

  column :message_to do |log|
    log.message_to.try :without_protocol
  end

  column :message_body

  column 'Actions' do |log|
    content_tag :ul do
      (log.actions_as_strings.map do |item|
        content_tag :li do
          item[:text]
        end
      end).join.html_safe
    end
  end

  column :created_at do |log|
    time_ago_in_words(log.created_at) + " ago"
  end
end
