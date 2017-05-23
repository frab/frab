module RiCalTemplates
end

ActionView::Template.register_template_handler :ri_cal, RiCalTemplates::TemplateHandler
