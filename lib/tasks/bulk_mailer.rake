namespace :frab do
  task default: :bulk_mailer

  desc 'sends bulk mails. This action takes two arguments. A file name of a file containing one mail addresses per line and another file with mail content'
  task bulk_mailer: :environment do |_t, _args|
    unless ENV['subject'] and ENV['from'] and ENV['emails'] and ENV['body']
      puts "Usage: rake frab:bulk_mailer subject=\"subject\" from=mail@example.org emails=emails.lst body=body.text.erb"
      exit
    end

    if File.readable?(ENV['emails']) and File.readable?(ENV['body'])
      require 'bulk_mailer.rb'
      BulkMailer.new(ENV['subject'], ENV['from'], ENV['emails'], ENV['body'], ENV['force'])
    else
      puts 'Failed to open files.'
      exit
    end
  end
end
