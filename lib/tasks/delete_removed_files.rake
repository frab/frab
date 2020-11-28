namespace :frab do
  task default: :delete_removed_files

  desc 'Delete from disks any file attachments which were removed from the events <n> or more days ago. All conferences are affected, unless a conference acronym is provided.'
  task delete_removed_files: :environment do |_t, _args|
    unless ENV['days']
      puts 'Usage: rake frab:delete_removed_files days=20 [acronym=frabcon12] [dry_run=1]'
      exit
    end
    dry_run = true if ENV['dry_run']
    days_ago = ENV['days'].to_i
    if ENV['acronym']
      conference = Conference.find_by(acronym: ENV['acronym'])
      if conference.nil?
        puts "Failed to find conference: #{ENV['acronym']}"
        exit
      end
    else
      conference = nil
    end

    require 'delete_removed_files.rb'
    DeleteRemovedFiles.new(conference, days_ago, dry_run).go!
  end
end
