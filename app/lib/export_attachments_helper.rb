class ExportAttachmentsHelper
  DEBUG = true
  DEFAULT_EXPORT_ROOT = 'tmp/attachments/'.freeze

  def initialize(conference = nil, export_root = nil)
    if conference.nil?
      puts "[!] the conference wasn't found."
      exit
    end

    @export_dir = File.join((export_root or DEFAULT_EXPORT_ROOT), conference.acronym)
    @conference = conference
    @conf_event_attachments = @conference.events.joins(:event_attachments)
  end

  def run_export
    puts ("Deleting all the files in #{@export_dir}.")
    FileUtils.rm_rf @export_dir

    if (@conference.attachment_title_is_freeform)
      export_all_tracks('attachments', @conf_event_attachments)
    else
      @conf_event_attachments.select('event_attachments.title').distinct.pluck('event_attachments.title').each do |attachment_title|
        export_all_tracks(attachment_title, @conf_event_attachments.where('event_attachments.title' => attachment_title))
      end
    end
  end

  def export_all_tracks(subtitle, event_attachments)
    event_attachments.distinct(:track_id).pluck(:track_id).each do |track_id|
      export_one_track subtitle, event_attachments.where(track_id: track_id), Track.find_by(id: track_id)&.name || 'trackless'
    end
  end

  def export_one_track(subtitle, event_attachments, track_name)
    archive_name = File.join(@export_dir, "#{sanitize(track_name)}_#{subtitle}.tgz")
    export_to_archieve event_attachments, archive_name
  end

  def export_to_archieve(event_attachments, archive_name)
    files_hash = event_attachments.
        pluck('id', 'title', 'event_attachments.id').
        map{ |event_id, event_title, event_attachment_id|
             ea = EventAttachment.find(event_attachment_id)
             [ "event#{'%04d' % event_id}_#{sanitize(event_title)}__#{sanitize(ea.attachment_file_name)}", ea.attachment.path ]
        }.reject{ |name, path| path.nil? }.
        to_h

    create_archive(archive_name, files_hash)
  end

  def create_archive(archive_name, files_hash)
    # files_hash: key = filename to be stored in archieve
    #             value = points to existing file with data
    return if files_hash.empty?
    Dir.mktmpdir do |tmpdir|
      puts "Writing attachements onto #{archive_name}"

      files_hash.each do |filename, path|
        FileUtils.cp path, "#{tmpdir}/#{filename}"
      end

      archivedir = File.dirname(archive_name)
      FileUtils.mkdir_p(archivedir) unless File.directory?(archivedir)

      # TODO don't use system
      system('tar', *['-cpz', '-f', archive_name, '-C', tmpdir, '.'])
    end
  end

  def sanitize(s)
    return nil if s.nil?
    s = s.gsub(/\[|\]|\||\?|\{|\}|\/|:/,'').strip
    if s.length > 46
      s=s[0..20] + '...' + s[s.length-20..s.length]
    end
    s
  end
end