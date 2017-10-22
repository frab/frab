module StaticSchedule
  class ProgramRenderer
    def initialize(conference, locale)
      @conference = conference
      @locale = locale
      @renderer = setup_renderer
    end

    def render(action:, assigns: {}, format: :html)
      @renderer.render action,
        formats: [format],
        assigns: defaults(assigns)
    end

    def render_with_template(action:, assigns:, template:, format: :prawn)
      @renderer.render action,
        template: template,
        formats: [format],
        assigns: defaults(assigns)
    end

    def view_model
      @view_model = ScheduleViewModel.new(@conference)
    end

    def base_url
      base_url = URI.parse(@conference.program_export_base_url).path
      base_url += '/' unless base_url.end_with?('/')
      base_url
    end

    private

    def defaults(assigns)
      assigns[:conference] ||= @conference
      assigns[:view_model] ||= view_model
      assigns
    end

    def setup_renderer
      renderer = Public::ScheduleController.renderer.new(
        http_host: ENV.fetch('FRAB_HOST'),
        https: ENV.fetch('FRAB_PROTOCOL') == 'https'
      )
      env = renderer.instance_variable_get(:@env)
      env['action_dispatch.request.path_parameters'] = {
        conference_acronym: @conference.acronym,
        locale: @locale
      }
      renderer
    end
  end
end
