class RatingInput < SimpleForm::Inputs::HiddenInput
  def input(_wrapper_options = nil)
    out = ActiveSupport::SafeBuffer.new
    out << @builder.hidden_field("#{attribute_name}").html_safe
    template.raty_for_input('my_rating', '#event_rating_rating', 'event_rating[rating]') { out }
  end
end
