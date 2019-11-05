namespace :frab do
  task default: :conference_export_attachments

  desc 'export attachments from a frab conference. Optionally set CONFERENCE=acronym to specify which conference to export. Current conference will be exported, when parameter is not set. Optionally set EXPORT_ROOT= to the export destination. tmp/attachments is used as default. The conference data is written to EXPORT_ROOT/conference_acronym/. Attachments are saved as a bunch of achieve files, partitioned by track and attachment type.'
  task conference_export_attachments: :environment do
    conference = if ENV['CONFERENCE']
                   Conference.find_by(acronym: ENV['CONFERENCE'])
                 else
                   Conference.current
                 end
    export_root = ENV['EXPORT_ROOT']
    require 'export_attachments_helper.rb'
    ExportAttachmentsHelper.new(conference, export_root).run_export
  end
end
