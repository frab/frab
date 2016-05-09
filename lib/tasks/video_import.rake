namespace :frab do
  task default: :video_import

  desc 'import video urls for a conference from an url'
  task video_import: :environment do |_t, _args|
    unless ENV['url'] and ENV['acronym']
      puts "Usage: rake frab:video_import acronym=frabcon11 url=\"http://example.org/podcast.xml\""
      exit
    end

    conference = Conference.find_by_acronym(ENV['acronym'])
    if conference.nil?
      puts "Failed to find conference: #{ENV['acronym']}"
      exit
    end
    require 'video_import.rb'
    importer = VideoImport.new(conference, ENV['url'])
    importer.import
  end
end
