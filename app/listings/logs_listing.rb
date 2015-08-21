class LogsListing < Listings::Base
  css_class 'graygrad'

  layout filters: :top

  model do
    @application = Application.find(params[:application_id])
    @application.logs.order('created_at DESC')
  end

  scope 'All', :all, default: true
  scope 'No trigger matched', :no_triggers
  scope 'With Errors', :with_errors

  filter :trigger_name, title: 'Trigger'
  filter :trigger_type

  column :trigger_name, title: 'Trigger', searchable: true

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

  column '', class: 'right' do |log|
    content_tag :button, 'class' => 'btn btn-lg', 'title' =>'Edit and re-send message', 'onclick' => "$('#logsController').scope().loadMessageInPopup(#{{from: log.message_from.try(:without_protocol), body: log.message_body, actions: log.actions_as_strings}.to_json});$('#logsController').scope().$apply();" do
      content_tag :i, '', 'class' => 'icon-pencil'
    end
  end
end
