require 'ri_cal_templates/template_handler'

ActionView::Template.register_template_handler :ri_cal, RiCalTemplates::TemplateHandler
