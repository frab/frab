class DeleteRemovedFiles
  include RakeLogger

  def initialize(conference, days_ago, dry_run = false)
    @conference = conference
    @days_ago = days_ago
    @dry_run = dry_run
  end

  def go!
    log "dry run, won't change anything!" if @dry_run

    versions =PaperTrail::Version.where(event: "destroy").
      where(item_type: "EventAttachment").
      where(['created_at < ?', @days_ago.days.ago])
      
      if @conference
        versions = versions.where(conference_id: @conference.id)
      end
      
      versions.each { |version|
        attachment = version.reify
        path = attachment.attachment.path
        if File.exists?(path)
          begin
            event_details = "event ##{attachment.event.id} #{attachment.event.title}"
          rescue
            event_details = "Unknown event"
          end
          log "Delete from disk #{path} was file #{attachment.attachment_file_name} on #{event_details}"
          File.delete(path) unless @dry_run
        end
      }
  end
end
