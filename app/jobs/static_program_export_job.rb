class StaticProgramExportJob
  require "static_program_export"
  include SuckerPunch::Job

  def perform(conference, locale='en')
    ENV['CONFERENCE'] = conference.acronym
    ENV['CONFERENCE_LOCALE'] = locale
    ENV['RAILS_ENV'] = Rails.env
    `rake frab:static_program_export`

    exporter = StaticProgramExport.new(conference, locale)
    file = exporter.create_tarball

    conference_export = ConferenceExport.where(conference_id: conference.id, locale: locale).first_or_create
    conference_export.update_attributes tarball: File.open(file)
  end

end

