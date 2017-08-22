rangeSlider = ->
  $('.category-slider').rangeslider(
    polyfill: false
  )
  $('fieldset .event_classifiers').on 'cocoon:after-insert', (event, insertedItem) ->
    $(insertedItem).find('input[type="range"]').rangeslider(
      polyfill: false
    )
$ ->
  rangeSlider()
