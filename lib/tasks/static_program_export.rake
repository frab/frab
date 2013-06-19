namespace :frab do

  desc "export program files to tmp/ directory. Optionally set CONFERENCE=acronym to specify which conference to export. Current conference will be exported, when parameter is not set."
  task :static_program_export => :environment do
    if ENV["CONFERENCE"]
      conference = Conference.find_by_acronym(ENV["CONFERENCE"])
    else
      conference = Conference.current
    end
    if ENV["CONFERENCE_LOCALE"]
      locale = ENV["CONFERENCE_LOCALE"]
    else
      locale = nil
    end
    require "static_program_export"
    StaticProgramExport.new(conference, locale).run_export
  end

end
