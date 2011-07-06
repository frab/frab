module RiCalTemplates

  class TemplateHandler
    include ActionView::Template::Handlers::Compilable

    def compile(template)
      require "ri_cal"
      "::RiCal.Calendar do |cal|\n" + 
      template.source +
      "\n end.to_s"
    end

  end

end
