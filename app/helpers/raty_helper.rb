module RatyHelper
  def raty_for_input(id, score_input_id, score_name)
    content_tag :div, id: id, class: 'rating', data: {
      'raty-input': 'on',
      source: score_input_id,
      target: score_name
    }.merge(image_data) do
      yield
    end
  end

  def raty_for(id, score)
    content_tag :div, '', id: id, class: 'rating', data: {
      raty: 'on',
      rating: score
    }.merge(image_data)
  end

  private

  def image_data
    {
      path: '',
      'star-on': image_path('raty/star-on.png'),
      'star-off': image_path('raty/star-off.png'),
      'star-half': image_path('raty/star-half.png')
    }
  end
end
