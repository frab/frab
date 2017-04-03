class StaticProgramExportJob
  require 'static_schedule'
  require 'tempfile'
  include SuckerPunch::Job

  def perform(conference, locale = 'en')
    Dir.mktmpdir('static_export') do |dir|
      Rails.logger.info "Create static export for #{conference} in #{dir}"

      exporter = StaticSchedule::Export.new(conference, locale, dir)
      file = exporter.create_tarball

      unless File.readable?(file)
        Rails.logger.error "Static export failed to create tarball at #{dir}"
        raise StandardError, "Static export failed to create tarball at #{dir}"
      end

      Rails.logger.info "Attach static export tarball #{file}"
      conference_export = ConferenceExport.where(conference_id: conference.id, locale: locale).first_or_create
      conference_export.update_attributes tarball: File.open(file)
    end
  end
end
