namespace :app do
  desc "rebuild contacts from execution logger"
  task :contacts => :environment do
    Application.all.each do |application|
      puts "Contacts of #{application.user.email}/#{application.name}"

      application.logs.order(:created_at).each do |log|

        if log.message_from
          Contact.record_incoming_message_at(application, log.message_from, log.created_at)
        end

        if log.actions
          log.actions.each do |action|
            case action[0]
            when :send_message
              kind, to, body = action
              Contact.record_outgoing_message_at(application, to, log.created_at)
            end
          end
        end
      end
    end
  end

end
