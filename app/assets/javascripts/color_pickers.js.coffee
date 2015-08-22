addColorPickers = ->
  $('input.color').ColorPicker(
    onSubmit: (hsb, hex, rgb, el) ->
      $(el).val(hex)
      $(el).ColorPickerHide()
    onBeforeShow: ->
      $(this).ColorPickerSetColor(this.value)
  )
$ ->
  addColorPickers()
