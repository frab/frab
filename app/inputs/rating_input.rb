class RatingInput < SimpleForm::Inputs::Base
  def input(_wrapper_options = nil)
    field_id = input_html_options[:id] || "#{@builder.object_name}_#{attribute_name}"
    current_value = @builder.object.send(attribute_name) || 0

    # Add margin top for spacing after label
    content = template.content_tag(:div, class: 'mt-2') do
      template.render('shared/star_rating', {
        id: field_id,
        name: "#{@builder.object_name}[#{attribute_name}]",
        value: current_value,
        readonly: options[:readonly] || false,
        size: options[:size] || input_html_options[:size] || 'md'
      })
    end

    content.html_safe
  end
end
