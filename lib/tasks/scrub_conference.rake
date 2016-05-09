namespace :frab do
  task default: :scrub_conference

  desc 'scrub personal details for selected conference. A full schedule export is still possible afterwards.'

  task scrub_conference: :environment do |_t, _args|
    unless ENV['acronym']
      puts 'Usage: rake frab:scrub_conference acronym=frabcon12 [dry_run=1]'
      exit
    end
    dry_run = true if ENV['dry_run']

    conference = Conference.find_by_acronym(ENV['acronym'])
    if conference.nil?
      puts "Failed to find conference: #{ENV['acronym']}"
      exit
    end
    require 'conference_scrubber.rb'
    ConferenceScrubber.new(conference, dry_run).scrub!
  end
end
