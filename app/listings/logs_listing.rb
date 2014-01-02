class LogsListing < Listings::Base

  model do
    @application = Application.find(params[:application_id])
    @application.logs.order 'created_at DESC'
  end

  sortable true

  column :trigger do |log|
    log.trigger.name rescue ''
  end

  column :message_from
  column :message_body
  column 'Actions' do |log|
    content_tag :ul do
      (log.actions_as_strings.map do |item|
        content_tag :li do
          item
        end
      end).join.html_safe
    end
  end
  column :created_at
end
