rangeSlider = ->
  $('.category-slider').rangeslider(
    polyfill: false
  )
  $(document).on 'cocoon:after-insert', (event, insertedItem) ->
    $(insertedItem).find('input[type="range"]').rangeslider(
      polyfill: false
    )
  $(document).on 'input', '.category-slider', (event) ->
    $('.category-output-' + event.target.getAttribute('category')).html(event.target.value + ' %')
checkbox_click_listener = ->
  $('.classifier-checkbox').on 'change', (event) ->
    box = $(event.currentTarget)
    classifier_id = box.attr('name').replace(/^classifier-checkbox-/, '')
    classifier_remove_link = $('#' + "remove_classifier_#{classifier_id}")

    # trigger the hidden cocoon dynamic links
    if not box.is(':checked')
      classifier_remove_link.trigger('click')
      return

    # if we removed a classifier slider before, unremove it and show it again
    exists = $(".classifier-block-#{classifier_id}")
    if exists.length
      exists.show()
      classifier_remove_link.prev("input[type=hidden]").val(false)
    else
      box.prev('.add_fields').trigger('click')
$ ->
  rangeSlider()
  checkbox_click_listener()
