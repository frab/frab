# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :horizontal do |b|
    b.use :html5
    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input
    end
  end

  config.wrappers :horizontal_string, tag: 'div', class: 'clearfix stringish', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label
    b.use :error, wrap_with: { tag: :span, class: :error }

    # TODO * not shown on password field
    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input
      ba.use :hint, wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'clearfix', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label

    # TODO right align, margin, missing ul<li
    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input
      ba.use :hint, wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.wrappers :check_boxes, tag: 'div', class: 'inputs-list clearfix', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label
    b.use :error, wrap_with: { tag: :span, class: :error }

    b.wrapper tag: 'div', class: 'input' do |ba|
      ba.use :input, wrap_with: { tag: :div, class: 'clearfix' }
      ba.use :hint, wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.default_wrapper = :horizontal_string

  # http://simple-form.plataformatec.com.br/#available-input-types-and-defaults-for-each-column-type
  config.wrapper_mappings = {
    inline_boolean: :horizontal_boolean,
    email: :horizontal_string,
    rating: :horizontal,
    check_boxes: :check_boxes,
    hidden: :horizontal
  }
end

# Work around wrong I18n for user login submit buttons
# https://stackoverflow.com/a/36833400
module DisableDoubleClickOnSimpleForms
  def submit(field, options = {})
    if field.is_a?(Hash)
      field[:data] ||= {}
      field[:data][:disable_with] ||= field[:value] || '...'
    else
      options[:data] ||= {}
      options[:data][:disable_with] ||= options[:value] || '...'
    end
    super(field, options)
  end
end

SimpleForm::FormBuilder.prepend(DisableDoubleClickOnSimpleForms)
