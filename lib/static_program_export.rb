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

    setup
    # @session = ActionDispatch::Integration::Session.new(Frab::Application)
    # @session.host = ENV.fetch('FRAB_HOST')
    # @session.https! if ENV.fetch('FRAB_PROTOCOL') == 'https'

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

  def setup
    @renderer = Public::ScheduleController.renderer.new(
      http_host: ENV.fetch('FRAB_HOST'),
      https: ENV.fetch('FRAB_PROTOCOL') == 'https'
    )
    env = @renderer.instance_variable_get(:@env)
    env['action_dispatch.request.path_parameters'] = {
      conference_acronym: @conference.acronym,
      locale: @locale
    }
  end

  def render(action, assigns, format = :html)
    assigns[:conference] = @conference
    @renderer.render action,
      formats: [format],
      assigns: assigns
  end

  def render_with_template(action, assigns, template, format = :prawn)
    assigns[:conference] = @conference
    @renderer.render action,
      template: template,
      formats: [format],
      assigns: assigns
  end

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
    paths.each { |p|
      puts "Downloading #{p[:target]}"
      save_response(p)
    }
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
      {  action: :style, format: :css, target: 'style.css' },
      {
        action: :events, assigns: { view_model: ScheduleViewModel.new(@conference) },
        target: 'events.html'
      },
      {  action: :events, format: :json, target: 'events.json',
         assigns: { view_model: ScheduleViewModel.new(@conference) },
      },
      # {  action: :speakers, target: 'speakers.html' },
      # {  action: :speakers, format: :json, target: 'speakers.json' },
      # {  action: :index, target: 'schedule.html' },
      # {  action: :index, format: :ics, target: 'schedule.ics' },
      # {  action: :index, format: :xcal, target: 'schedule.xcal' },
      # {  action: :index, format: :json, target: 'schedule.json' },
      {  action: :index, format: :xml, target: 'schedule.xml' }
    ]
  end

  def query_paths
    paths = static_query_paths
    day_index = 1
    @conference.days.each do |day|
      paths << { action: :day, assigns: { day: day }, target: "schedule/#{day_index}.html" }
      paths << {
        action: :day,
        template: 'schedule/custom_pdf.pdf.prawn',
        assigns: {
          day: day,
          layout: CustomPDF::FullPageLayout.new('A4')
        },
        format: :prawn,
        target: "schedule/#{day_index}.pdf"
      }
      day_index += 1
    end

    @conference.events.is_public.confirmed.scheduled.each do |event|
      paths << {
        action: :event,
        assigns: { view_model: ScheduleViewModel.new(@conference).for_event(event.id) },
        target: "events/#{event.id}.html"
      }
      paths << { action: :event, assigns: {
        view_model: ScheduleViewModel.new(@conference).for_event(event.id)
      }, format: :ics, target: "events/#{event.id}.ics" }
    end

    Person.publicly_speaking_at(@conference).confirmed(@conference).each do |speaker|
      paths << {
        action: :speaker,
        assigns: {
          speakers: Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).order(:public_name, :first_name, :last_name)
        },
        target: "speakers/#{speaker.id}.html"
      }
    end
    paths
  end

  def save_response(action:, assigns: {}, target:, format: :html, template: nil)
    filename = target
    if format == :prawn
      response = render_with_template(action, assigns, template, format)
    else
      response = render(action, assigns, format)
    end
    # #unless status_code == 200
    #   #error('!! Failed to fetch "%s" as "%s" with error code %d' % [source, filename, status_code])
    #   #return
    # #end

    file_path = File.join(@base_directory, URI.decode(filename))
    FileUtils.mkdir_p(File.dirname(file_path))

    if filename.match?(/\.html$/)
      document = modify_response_html(response)
      File.open(file_path, 'w') do |f|
        # FIXME corrupts events and speakers?
        # document.write_html_to(f, encoding: "UTF-8")
        f.puts(document.to_html)
      end
    elsif filename.match?(/\.pdf$/)
      File.open(file_path, 'wb') do |f|
        f.write(response)
      end
    else
      # CSS,...
      File.open(file_path, 'w:utf-8') do |f|
        f.write(response.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?'))
      end
    end
  end

  def modify_response_html(body)
    document = Nokogiri::HTML(body, nil, 'UTF-8')

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
        if href.value.match?(/\?\d+$/)
          strip_asset_path(link, 'href')
        else
          path = @base_url + strip_path(href.value)
          path = add_html_ext(path) unless path.match?(/\.\w+$/)
          href.value = path
        end
      end
    end
    document
  end

  def add_html_ext(path)
    uri = URI.parse(path)
    uri.path += '.html'
    uri.to_s
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
