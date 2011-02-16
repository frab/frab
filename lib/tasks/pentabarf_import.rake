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

    desc "Import people"
    task :people => :setup do
      @import_helper.import_people
    end

    desc "Import events"
    task :events => :setup do
      @import_helper.import_events
    end

    desc "Import event_people"
    task :event_people => :setup do
      @import_helper.import_event_people
    end

    desc "Import data from pentabarf"
    task :all => [:setup, :conferences, :people, :events, :event_people]
  end
end
