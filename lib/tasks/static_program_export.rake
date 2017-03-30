namespace :frab do
  desc 'export program files to tmp/ directory. Optionally set CONFERENCE=acronym to specify which conference to export. Current conference will be exported, when parameter is not set.'
  task static_program_export: :environment do
    conference = if ENV['CONFERENCE']
                   Conference.find_by_acronym(ENV['CONFERENCE'])
                 else
                   Conference.current
                 end

    locale ||= ENV['CONFERENCE_LOCALE']
    conference_dir ||= ENV['CONFERENCE_DIR']

    require 'static_schedule'
    StaticSchedule::Export.new(conference, locale, conference_dir).run_export
  end
end
