class InlineBooleanInput < SimpleForm::Inputs::BooleanInput
  # Render 'inline' boolean control, regardless of the value of config.boolean_style
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    build_check_box(unchecked_value, merged_input_options)
  end
end
