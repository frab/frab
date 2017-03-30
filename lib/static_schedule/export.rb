module StaticSchedule
  class Export
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
      @renderer = ProgramRenderer.new(@conference, @locale)
      @pages = Pages.new(@renderer, @conference)
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

      ActiveRecord::Base.transaction do
        unlock_schedule unless @original_schedule_public

        setup_directories
        download_pages
        copy_stripped_assets

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
      @pages.all.each do |p|
        filename = p.delete(:target)
        puts "Downloading #{filename}" unless Rails.env.test?
        response = if p[:template]
                     @renderer.render_with_template(p)
                   else
                     @renderer.render(p)
                   end
        save_response(response, filename)
      end
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

    def save_response(response, filename)
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
        elsif href_attr
          strip_asset_path(link, 'href')
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
      path.gsub(%r{^/}, '').gsub(%r{^(?:en|de)?/?#{@conference.acronym}/public/}, '').gsub(/\?(?:body=)?\d+$/, '')
    end

    def unlock_schedule
      Conference.paper_trail.disable
      @conference.schedule_public = true
      @conference.save!
    end

    def lock_schedule
      @conference.schedule_public = @original_schedule_public
      @conference.save!
      Conference.paper_trail.enable
    end
  end
end
