class StaticProgramExportJob
  require "static_program_export"
  include SuckerPunch::Job


  def perform(conference, locale='en')
    ENV['CONFERENCE'] = conference.acronym
    ENV['CONFERENCE_LOCALE'] = locale
    `rake frab:static_program_export`
    exporter = StaticProgramExport.new(conference, locale)
    exporter.create_tarball
  end

end

