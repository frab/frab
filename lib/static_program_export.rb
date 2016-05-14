class StaticProgramExport
  include RakeLogger

  EXPORT_PATH = Rails.root.join('tmp', 'static_export').to_s

  # Export a static html version of the conference program.
  #
  # @param conference [Conference] conference to export
  # @param locale [String] export conference in supported locale
  # @param destination [String] export into this directory
  def initialize(conference, locale = 'en', destination = EXPORT_PATH)
    @conference = conference
    @locale = locale
    @destination = destination || EXPORT_PATH
  end

  # create a tarball from the conference export directory
  def create_tarball
    out_file = tarball_filename
    File.unlink out_file if File.exist? out_file
    system('tar', *['-cpz', '-f', out_file.to_s, '-C', @destination, @conference.acronym].flatten)
    out_file.to_s
  end

  # export the conference to disk
  #
  # only run by rake task, cannot run in the same thread as rails
  def run_export
    fail 'No conference found!' if @conference.nil?

    @asset_paths = []
    @base_directory = File.join(@destination, @conference.acronym)
    @base_url = base_url
    @original_schedule_public = @conference.schedule_public

    @session = ActionDispatch::Integration::Session.new(Frab::Application)
    @session.host = ENV.fetch('FRAB_HOST')
    @session.https! if ENV.fetch('FRAB_PROTOCOL') == 'https'
    ActiveRecord::Base.transaction do
      unlock_schedule unless @original_schedule_public

      setup_directories
      download_pages
      copy_stripped_assets
      create_index_page

      lock_schedule unless @original_schedule_public
    end
  end

  private

  def base_url
    if @conference.program_export_base_url.present?
      base_url = URI.parse(@conference.program_export_base_url).path
      base_url += '/' unless base_url.end_with?('/')
      base_url
    else
      '/'
    end
  end

  def tarball_filename
    File.join(@destination, "#{@conference.acronym}-#{@locale}.tar.gz")
  end

  def setup_directories
    FileUtils.rm_r(@base_directory, secure: true) if File.exist? @base_directory
    FileUtils.mkdir_p(@base_directory)
  end

  def download_pages
    paths = query_paths
    path_prefix = "/#{@conference.acronym}/public"
    path_prefix = "/#{@locale}" + path_prefix unless @locale.nil?
    paths.each { |p| save_response("#{path_prefix}/#{p[:source]}", p[:target]) }
  end

  def copy_stripped_assets
    @asset_paths.uniq.each do |asset_path|
      original_path = File.join(Rails.root, 'public', URI.unescape(asset_path))
      if File.exist? original_path
        new_path = File.join(@base_directory, URI.unescape(asset_path))
        FileUtils.mkdir_p(File.dirname(new_path))
        FileUtils.cp(original_path, new_path)
      else
        warning('?? We might be missing "%s"' % original_path)
      end
    end
  end

  def create_index_page
    schedule_file = File.join(@base_directory, 'schedule.html')
    return unless File.exist? schedule_file
    FileUtils.cp(schedule_file, File.join(@base_directory, 'index.html'))
  end

  def static_query_paths
    [
      { source: 'schedule', target: 'schedule.html' },
      { source: 'events', target: 'events.html' },
      { source: 'speakers', target: 'speakers.html' },
      { source: 'events.json', target: 'events.json' },
      { source: 'speakers.json', target: 'speakers.json' },
      { source: 'schedule/style.css', target: 'style.css' },
      { source: 'schedule.ics', target: 'schedule.ics' },
      { source: 'schedule.xcal', target: 'schedule.xcal' },
      { source: 'schedule.json', target: 'schedule.json' },
      { source: 'schedule.xml', target: 'schedule.xml' }
    ]
  end

  def query_paths
    paths = static_query_paths
    day_index = 0
    @conference.days.each do |_day|
      paths << { source: "schedule/#{day_index}", target: "schedule/#{day_index}.html" }
      paths << { source: "schedule/#{day_index}.pdf", target: "schedule/#{day_index}.pdf" }
      day_index += 1
    end

    @conference.events.is_public.confirmed.scheduled.each do |event|
      paths << { source: "events/#{event.id}", target: "events/#{event.id}.html" }
      paths << { source: "events/#{event.id}.ics", target: "events/#{event.id}.ics" }
    end

    Person.publicly_speaking_at(@conference).confirmed(@conference).each do |speaker|
      paths << { source: "speakers/#{speaker.id}", target: "speakers/#{speaker.id}.html" }
    end
    paths
  end

  def save_response(source, filename)
    status_code = @session.get(source)
    unless status_code == 200
      error('!! Failed to fetch "%s" as "%s" with error code %d' % [source, filename, status_code])
      return
    end

    file_path = File.join(@base_directory, URI.decode(filename))
    FileUtils.mkdir_p(File.dirname(file_path))

    if filename =~ /\.html$/
      document = modify_response_html(filename)
      File.open(file_path, 'w') do |f|
        # FIXME corrupts events and speakers?
        # document.write_html_to(f, encoding: "UTF-8")
        f.puts(document.to_html)
      end
    elsif filename =~ /\.pdf$/
      File.open(file_path, 'wb') do |f|
        f.write(@session.response.body)
      end
    else
      # CSS,...
      File.open(file_path, 'w:utf-8') do |f|
        f.write(@session.response.body.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?'))
      end
    end
  end

  def modify_response_html(_filename)
    document = Nokogiri::HTML(@session.response.body, nil, 'UTF-8')

    # <link>
    document.css('link').each do |link|
      href_attr = link.attributes['href']
      if href_attr.value.index("/#{@conference.acronym}/public/schedule/style.css")
        link.attributes['href'].value = @base_url + 'style.css'
      else
        strip_asset_path(link, 'href') if href_attr
      end
    end

    # <script>
    document.css('script').each do |script|
      strip_asset_path(script, 'src') if script.attributes['src']
    end

    # <img>
    document.css('img').each do |image|
      strip_asset_path(image, 'src')
    end

    # <a>
    document.css('a').each do |link|
      href = link.attributes['href']
      if href and href.value.start_with?('/')
        if href.value =~ /\?\d+$/
          strip_asset_path(link, 'href')
        else
          path = @base_url + strip_path(href.value)
          path += '.html' unless path =~ /\.\w+$/
          href.value = path
        end
      end
    end
    document
  end

  def strip_asset_path(element, attribute)
    path = strip_path(element.attributes[attribute].value)
    @asset_paths << path
    element.attributes[attribute].value = @base_url + path
  end

  def strip_path(path)
    path.gsub(/^\//, '').gsub(/^(?:en|de)?\/?#{@conference.acronym}\/public\//, '').gsub(/\?(?:body=)?\d+$/, '')
  end

  def unlock_schedule
    Conference.paper_trail_off!
    @conference.schedule_public = true
    @conference.save!
  end

  def lock_schedule
    @conference.schedule_public = @original_schedule_public
    @conference.save!
    Conference.paper_trail_on!
  end
end
