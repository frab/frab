class StaticProgramExportJob
  require 'static_program_export'
  require 'tempfile'
  include SuckerPunch::Job

  def perform(conference, locale = 'en')
    Dir.mktmpdir('static_export') do |dir|
      Rails.logger.info "Create static export for #{conference} in #{dir}"

      ENV['CONFERENCE'] = conference.acronym
      ENV['CONFERENCE_LOCALE'] = locale
      ENV['CONFERENCE_DIR'] = dir
      ENV['RAILS_ENV'] = Rails.env
      `rake frab:static_program_export`

      exporter = StaticProgramExport.new(conference, locale, dir)
      file = exporter.create_tarball

      Rails.logger.info "Attach static export tarball #{file}"
      conference_export = ConferenceExport.where(conference_id: conference.id, locale: locale).first_or_create
      conference_export.update_attributes tarball: File.open(file)
    end
  end
end
