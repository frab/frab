class RatingInput < SimpleForm::Inputs::HiddenInput
  def input(wrapper_options = nil)
    template.concat super(wrapper_options)
    template.concat ratings_div
  end

  def ratings_div
    template.content_tag(:div, id: 'my_rating') do
    end
  end
end
