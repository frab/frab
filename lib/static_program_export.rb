class StaticProgramExport

  def initialize(conference)
    @conference = conference
    @session = ActionDispatch::Integration::Session.new(Frab::Application)
    @session.host = 'frab.local'
    @asset_paths = Array.new
    @base_directory = File.join(Rails.root, "tmp", "static_export")
  end

  def run_export
    setup_directories
    path_prefix = "/#{@conference.acronym}/public"
    @session.get("#{path_prefix}/schedule")
    save_response("index.html")
    @conference.days.each do |day|
      @session.get("#{path_prefix}/schedule/#{day}")
      save_response("schedule/#{day}.html")
      @session.get("#{path_prefix}/schedule/#{day}.pdf")
      save_response("schedule/#{day}.pdf")
    end
    @session.get("#{path_prefix}/events")
    save_response("events.html")
    @conference.events.accepted.public.each do |event|
      @session.get("#{path_prefix}/events/#{event.id}")
      save_response("events/#{event.id}.html")
    end
    @session.get("#{path_prefix}/speakers")
    save_response("speakers.html")
    Person.publicly_speaking_at(@conference).each do |speaker|
      @session.get("#{path_prefix}/speakers/#{speaker.id}")
      save_response("speakers/#{speaker.id}.html")
    end
    @session.get("#{path_prefix}/schedule/style.css")
    save_response("style.css")
    @session.get("#{path_prefix}/schedule.ics")
    save_response("schedule.ics")
    @session.get("#{path_prefix}/schedule.xcal")
    save_response("schedule.xcal")
    @session.get("#{path_prefix}/schedule.xml")
    save_response("schedule.xml")
    @asset_paths.uniq.each do |asset_path|
      original_path = File.join(Rails.root, "public", asset_path)
      if File.exist? original_path
        new_path = File.join(@base_directory, asset_path)
        FileUtils.mkdir_p(File.dirname(new_path))
        FileUtils.cp(original_path, new_path)
      end
    end
  end

  private

  def save_response(filename)
    file_path = File.join(@base_directory, filename)
    FileUtils.mkdir_p(File.dirname(file_path))
    if filename =~ /\.html$/
      level = filename.split("/").size - 1
      document = Nokogiri::HTML(@session.response.body, nil, "UTF-8")
      document.css("link").each do |link|
        if link.attributes["href"].value == "/#{@conference.acronym}/public/schedule/style.css"
          link.attributes["href"].value = dots(level) + "style.css"
        else
          strip_asset_path(link, "href", level) if link.attributes["href"]
        end
      end
      document.css("script").each do |script|
        strip_asset_path(script, "src", level) if script.attributes["src"]
      end
      document.css("img").each do |image|
        strip_asset_path(image, "src", level)
      end
      document.css("a").each do |link|
        if link.attributes["href"].value.start_with?("/")
          path = strip_path(link.attributes["href"].value)
          path = "index" if path == "schedule"
          path += ".html" unless path =~ /\.\w+$/
          link.attributes["href"].value = dots(level) + path
        end
      end
      File.open(file_path, "w") do |f| 
        document.write_html_to(f, :encoding => "UTF-8")
      end
    else
      File.open(file_path, "w") do |f| 
        f.write(@session.response.body)
      end
    end
  end

  def strip_asset_path(element, attribute, level = 0)
    path = strip_path(element.attributes[attribute].value)
    @asset_paths << path
    element.attributes[attribute].value = dots(level) + path
  end

  def strip_path(path)
    path.gsub(/^\//, "").gsub(/^#{@conference.acronym}\/public\//, "").gsub(/\?\d+$/, "")
  end

  def dots(level)
    result = (1..level).map{|i| ".."}.join("/")
    result += "/" unless result.blank?
    result
  end

  def setup_directories
    FileUtils.rm_r(@base_directory, :secure => true) if File.exist? @base_directory
    FileUtils.mkdir_p(@base_directory)
  end

end
