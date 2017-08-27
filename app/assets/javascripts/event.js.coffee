rangeSlider = ->
  $('.category-slider').rangeslider(
    polyfill: false
  )
  $(document).on 'cocoon:after-insert', (event, insertedItem) ->
    console.log('in cocoon after-insert listner')
    $(insertedItem).find('input[type="range"]').rangeslider(
      polyfill: false
    )
checkbox_click_listener = ->
  $('.cocoon-checkbox').on 'change', (event) ->
    # trigger the hidden cocoon dynamic links
    if ($(event.currentTarget).is(':checked'))
      $(event.currentTarget).prev('.add_fields').trigger('click')
    else
      classifier_id = $(event.currentTarget).attr('name')
      classifier_remove_link = $('#' + "remove_classifier_#{classifier_id}") # another idea would be to detect with this $("input[name$='classifier_id]'][value=1]")
      classifier_remove_link.trigger('click')
$ ->
  rangeSlider()
  checkbox_click_listener()
