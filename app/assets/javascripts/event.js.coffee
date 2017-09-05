rangeSlider = ->
  $('.category-slider').rangeslider(
    polyfill: false
  )
  $(document).on 'cocoon:after-insert', (event, insertedItem) ->
    $(insertedItem).find('input[type="range"]').rangeslider(
      polyfill: false
    )
  $(document).on 'cocoon:after-remove', (event, removedItem) ->
    category = $(removedItem).find('input.category-slider').attr('category')
    $(removedItem).addClass "removed-classifier-#{category}"
  $(document).on 'input', '.category-slider', (event) ->
    $('.category-output-' + event.target.getAttribute('category')).html(event.target.value + ' %')
checkbox_click_listener = ->
  $('.cocoon-checkbox').on 'change', (event) ->
    box = $(event.currentTarget)
    classifier_id = box.attr('name')
    classifier_remove_link = $('#' + "remove_classifier_#{classifier_id}")

    # trigger the hidden cocoon dynamic links
    if not box.is(':checked')
      classifier_remove_link.trigger('click')
      return

    # if we removed a classifier slider before, unremove it and show it again
    exists = $(".removed-classifier-#{classifier_id}")
    if exists.length
      exists.show()
      classifier_remove_link.prev("input[type=hidden]").val(false)
    else
      box.prev('.add_fields').trigger('click')
$ ->
  rangeSlider()
  checkbox_click_listener()
