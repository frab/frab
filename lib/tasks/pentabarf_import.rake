namespace :pentabarf do
  
  desc "Import data from pentabarf"
  task :import => :environment do
    require "pentabarf_import_helper"
    import_helper = PentabarfImportHelper.new
    import_helper.import_conferences
    import_helper.import_people
    import_helper.import_events
  end

end
