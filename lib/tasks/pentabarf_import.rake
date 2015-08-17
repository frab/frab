namespace :pentabarf do
  namespace :import do
    task :default => :all

    task :setup => :environment do
      require "pentabarf_import_helper"
      @import_helper = PentabarfImportHelper.new
    end

    desc "Import conferences"
    task :conferences => :setup do
      @import_helper.import_conferences
    end

    desc "Import tracks"
    task :tracks => :setup do
      @import_helper.import_tracks
    end

    desc "Import rooms"
    task :rooms => :setup do
      @import_helper.import_rooms
    end

    desc "Import people"
    task :people => :setup do
      @import_helper.import_people
    end

    desc "Import accounts"
    task :accounts => :setup do
      @import_helper.import_accounts
    end

    desc "Import languages"
    task :languages => :setup do
      @import_helper.import_languages
    end

    desc "Import events"
    task :events => :setup do
      @import_helper.import_events
    end

    desc "Import event_ratings"
    task :event_ratings => :setup do
      @import_helper.import_event_ratings
    end

    desc "Import event_feedbacks"
    task :event_feedbacks => :setup do
      @import_helper.import_event_feedbacks
    end

    desc "Import event attachments"
    task :event_attachments => :setup do
      @import_helper.import_event_attachments
    end

    desc "Import event_people"
    task :event_people => :setup do
      @import_helper.import_event_people
    end

    desc "Import links"
    task :links => :setup do
      @import_helper.import_links
    end

    desc "Import data from pentabarf"
    task :all => [:setup, :conferences, :tracks, :rooms, :people, :accounts, :languages, :events, :event_feedbacks, :event_ratings, :event_attachments, :event_people, :links]
  end
end
