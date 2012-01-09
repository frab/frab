class RatingInput < FormtasticBootstrap::Inputs::HiddenInput
  def to_html
    generic_input_wrapping do
      builder.hidden_field(method, input_html_options) + "<div id=\"my_rating\"></div>".html_safe
    end
  end
end
