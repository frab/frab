class RatingInput < FormtasticBootstrap::Inputs::HiddenInput
  def to_html
    builder.hidden_field(method, input_html_options) + "<div id=\"my_rating\"></div>".html_safe
  end
end
