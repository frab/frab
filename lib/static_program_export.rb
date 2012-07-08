class StaticProgramExport

  def initialize(conference)
    @conference = conference
    @session = ActionDispatch::Integration::Session.new(Frab::Application)
    @session.host = Settings.host
    @session.https! if Settings['protocol'] == "https"
    @asset_paths = [] 
    @base_directory = File.join(Rails.root, "tmp", "static_export")
    @base_url = @conference.program_export_base_url
    unless @base_url.end_with?('/')
      @base_url += '/'
    end
  end

  def run_export
    setup_directories
    path_prefix = "/#{@conference.acronym}/public"
    paths = [
      { :source => "schedule", :target => "schedule.html" },
      { :source => "events", :target => "events.html" },
      { :source => "speakers", :target => "speakers.html" },
      { :source => "schedule/style.css", :target => "style.css" },
      { :source => "schedule.ics", :target => "schedule.ics" },
      { :source => "schedule.xcal", :target => "schedule.xcal" },
      { :source => "schedule.xml", :target => "schedule.xml" },
      { :source => "schedule.json", :target => "schedule.json" },
    ]
    @conference.days.each do |day|
      paths << { :source => "schedule/#{day}", :target => "schedule/#{day}.html" }
      paths << { :source => "schedule/#{day}.pdf", :target => "schedule/#{day}.pdf" }
    end
    @conference.events.confirmed.public.each do |event|
      paths << { :source => "events/#{event.id}", :target => "events/#{event.id}.html" }
    end
    Person.publicly_speaking_at(@conference).confirmed(@conference).each do |speaker|
      paths << { :source => "speakers/#{speaker.id}", :target => "speakers/#{speaker.id}.html" }
    end

    # write files
    paths.each do |p|
      save_response("#{path_prefix}/#{p[:source]}", p[:target])
    end

    # copy all assets we detected earlier (jquery, ...)
    @asset_paths.uniq.each do |asset_path|
      original_path = File.join(Rails.root, "public", URI.unescape(asset_path))
      if File.exist? original_path
        new_path = File.join(@base_directory, URI.unescape(asset_path))
        FileUtils.mkdir_p(File.dirname(new_path))
        FileUtils.cp(original_path, new_path)
      else
        STDERR.puts '?? We might be missing "%s"' % original_path
      end
    end

    # create index.html
    schedule_file = File.join(@base_directory, 'schedule.html')
    if File.exist?  schedule_file 
      FileUtils.cp(schedule_file, File.join(@base_directory, 'index.html'))
    end
  end

  private

  def save_response(source, filename)
    status_code = @session.get(source)

    unless status_code == 200
      STDERR.puts '!! Failed to fetch "%s" as "%s" with error code %d' % [ source, filename, status_code ]
      return 
    end

    file_path = File.join(@base_directory, URI.decode(filename))
    FileUtils.mkdir_p(File.dirname(file_path))

    if filename =~ /\.html$/
      document = modify_response_html(filename)
      File.open(file_path, "w") do |f|
        f.puts(document.to_html)
      end
    elsif filename =~ /\.pdf$/
      File.open(file_path, "wb") do |f| 
        f.write(@session.response.body)
      end
    else
      # CSS,...
      File.open(file_path, "w:utf-8") do |f| 
        f.write(@session.response.body.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "?"))
      end
    end
  end

  def modify_response_html(filename)
    document = Nokogiri::HTML(@session.response.body, nil, "UTF-8")
    
    # <link>
    document.css("link").each do |link|
      href_attr = link.attributes["href"]
      if href_attr.value.index("/#{@conference.acronym}/public/schedule/style.css")
        link.attributes["href"].value = @base_url + "style.css"
      else
        strip_asset_path(link, "href") if href_attr
      end
    end

    # <script>
    document.css("script").each do |script|
      strip_asset_path(script, "src") if script.attributes["src"]
    end
    
    # <img>
    document.css("img").each do |image|
      strip_asset_path(image, "src")
    end
    
    # <a>
    document.css("a").each do |link|
      if link.attributes["href"].value.start_with?("/")
        if link.attributes["href"].value =~ /\?\d+$/
          strip_asset_path(link, "href")
        else
          path = @base_url + strip_path(link.attributes["href"].value)
          path += ".html" unless path =~ /\.\w+$/
          link.attributes["href"].value = path
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
    path.gsub(/^\//, "").gsub(/^(?:en|de)?\/?#{@conference.acronym}\/public\//, "").gsub(/\?(?:body=)?\d+$/, "")
  end

  def setup_directories
    FileUtils.rm_r(@base_directory, :secure => true) if File.exist? @base_directory
    FileUtils.mkdir_p(@base_directory)
  end
end