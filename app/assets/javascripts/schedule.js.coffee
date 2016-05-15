# Schedule Editor
update_event_position = (event) ->
  td = $(event).data("slot")
  $(event).css("position", "absolute")
  $(event).css("left", td.offset().left)
  $(event).css("top", td.offset().top)
  return

update_unscheduled_events = (track_id = "") ->
  $.ajax(
    url: $("form#update-track").attr("action"),
    data: {track_id: track_id},
    dataType: "html",
    success: (data) ->
      $("ul#unscheduled-events").html(data)
      return
  )
  return

add_event_to_slot = (event, td, update = true) ->
  event = $(event)
  td = $(td)
  event.data("slot", td)
  td.append($(event))
  update_event_position(event)
  if update
    event.data("time", td.data("time"))
    event.data("room", td.data("room"))
    $.ajax(
      url: event.data("update-url"),
      data: {"event": {"start_time": td.data("time"), "room_id": td.parents("table.room").data("room-id")}},
      type: "PUT",
      dataType: "script",
      success: ->
        event.effect('highlight')
        return
    )
  return

make_draggable = (element) ->
  element.draggable(revert: "invalid", opacity: 0.4, cursorAt: {left: 5, top: 5})
  true

$ ->
  $("body").delegate("div.event", "mouseenter", ->
    event_div = $(this)
    return if event_div.find("a.close").length > 0
    unschedule = $("<a href='#'>×</a>")
    unschedule.addClass("close").addClass("small")
    event_div.prepend(unschedule)
    unschedule.click (click_event) ->
      $.ajax(
        url: event_div.data("update-url"),
        data: {"event": {"start_time": null, "room_id": null}},
        type: "PUT",
        dataType: "script",
        success: ->
          event_div.remove()
          update_unscheduled_events()
          return
      )
      click_event.stopPropagation()
      click_event.preventDefault()
      false
    return
  )
  $("body").delegate("div.event", "mouseleave", ->
    $(this).find("a.close").remove()
    return
  )
  $("body").delegate("div.event", "click", (click_event) ->
    click_event.stopPropagation()
    click_event.preventDefault()
    false
  )

  # Buttons
  for button in $("a.toggle-room")
    $(button).click ->
      current_button = $(this)
      $("table[data-room='" + current_button.data('room') + "']").toggle()
      if current_button.hasClass("success")
        current_button.removeClass("success")
      else
        current_button.addClass("success")
      for event in $("table.room div.event")
        update_event_position(event)
        true
      preventDefault()
      false
    true

  $("a#hide-all-rooms").click ->
    $("a.toggle-room").removeClass("success")
    $("table.room").hide()
    false

  # Track filter
  $("select#track_select").change ->
    update_unscheduled_events($(this).val())
    true

  for timeslot in $("table.room td")
    $(timeslot).droppable(
      hoverClass: "event-hover",
      tolerance: "pointer",
      drop: (event, ui) ->
        add_event_to_slot(ui.draggable, this)
        true
    )
    true

  $("#add-event-modal").modal('hide')
  $("body").delegate("table.room td", "click", (click_event) ->
    td = $(this)
    $("#add-event-modal #current-time").html(td.data("time"))
    $("ul#unscheduled-events").undelegate("click")
    $("ul#unscheduled-events").delegate("li a", "click", (click_event) ->
      li = $(this).parent()
      new_event = $("<div></div>")
      new_event.html(li.children().first().html())
      new_event.addClass("event")
      new_event.attr("id", li.attr("id"))
      new_event.css("height", li.data("height"))
      new_event.data("update-url", li.data("update-url"))
      $("#event-pane").append(new_event)
      add_event_to_slot(new_event, td)
      make_draggable(new_event)
      li.remove()
      $("#add-event-modal").modal('hide')
      click_event.preventDefault()
      false
    )
    $("#add-event-modal").modal('show')
    click_event.stopPropagation()
    false
  )

  for event in $("div.event")
    if $(event).data("room") and $(event).data("time")
      starting_cell = $("table[data-room='" + $(event).data("room") + "']").find("td[data-time='" + $(event).data("time") + "']")
      add_event_to_slot(event, starting_cell, false)
    make_draggable($(event))
    true

  return
