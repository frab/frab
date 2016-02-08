namespace :frab do
  task default: :conference_export

  desc "export a frab conference. Optionally set CONFERENCE=acronym to specify which conference to export. Current conference will be exported, when paramter is not set. The conference data is written to tmp/frab_export"
  task conference_export: :environment do
    if ENV["CONFERENCE"]
      conference = Conference.find_by_acronym(ENV["CONFERENCE"])
    else
      conference = Conference.current
    end
    require "import_export_helper.rb"
    ImportExportHelper.new(conference).run_export
  end

  desc "import a frab conference. The import will merge the conference with existing data. If the conference already exists, the import won't run. Optionally set FRAB_EXPORT=directory to specify from where to load the exported files."
  task conference_import: :environment do
    if ENV["FRAB_EXPORT"]
      export_path = ENV["FRAB_EXPORT"]
    else
      export_path = "tmp/frab_export"
    end
    require "import_export_helper.rb"
    ImportExportHelper.new.run_import(export_path)
  end
end
