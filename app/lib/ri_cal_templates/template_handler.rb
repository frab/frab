module RiCalTemplates
  class TemplateHandler
    def self.call(template, raw)
      require 'ri_cal'
      "::RiCal.Calendar do |cal|\n" +
        template.source +
        "\n end.to_s"
    end
  end
end
