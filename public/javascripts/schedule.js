/* DO NOT MODIFY. This file was compiled Fri, 10 Jun 2011 14:52:08 GMT from
 * /home/dave/projects/frab/app/coffeescripts/schedule.coffee
 */

(function() {
  var add_event_to_slot, update_event_position;
  update_event_position = function(event) {
    var td;
    td = $(event).parent();
    $(event).css("position", "absolute");
    $(event).css("left", td.offset().left);
    return $(event).css("top", td.offset().top);
  };
  add_event_to_slot = function(event, td) {
    $(event).detach();
    $(td).append($(event));
    return update_event_position(event);
  };
  $(function() {
    var checkbox, event, starting_cell, timeslot, _i, _j, _k, _l, _len, _len2, _len3, _len4, _ref, _ref2, _ref3, _ref4;
    _ref = $("table.room td");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      timeslot = _ref[_i];
      $(timeslot).droppable({
        hoverClass: "event-hover",
        tolerance: "pointer",
        drop: function(event, ui) {
          add_event_to_slot(ui.draggable, this);
          ui.draggable.data("time", $(this).data("time"));
          ui.draggable.data("room", $(this).data("room"));
          return $.ajax({
            url: ui.draggable.data("update-url"),
            data: {
              "event": {
                "start_time": $(this).data("time"),
                "room_id": $(this).parents("table.room").data("room-id")
              }
            },
            type: "PUT",
            dataType: "script",
            success: function() {
              return ui.draggable.effect('highlight');
            }
          });
        }
      });
    }
    _ref2 = $("div.event");
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      event = _ref2[_j];
      if ($(event).data("room") && $(event).data("time")) {
        starting_cell = $("table[data-room='" + $(event).data("room") + "']").find("td[data-time='" + $(event).data("time") + "']");
        add_event_to_slot(event, starting_cell);
      }
      $(event).draggable({
        revert: "invalid",
        opacity: 0.4,
        cursorAt: {
          left: 5,
          top: 5
        }
      });
    }
    _ref3 = $("div.unscheduled-event");
    for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
      event = _ref3[_k];
      $(event).draggable({
        opacity: 0.4,
        cursorAt: {
          left: 5,
          top: 5
        },
        start: function() {
          $(this).removeClass("unscheduled-event");
          $(this).addClass("event");
          return $(this).css("height", $(this).data("height"));
        },
        revert: function(droppable) {
          if (droppable === false) {
            $(this).removeClass("event");
            $(this).css("height", "auto");
            $(this).addClass("unscheduled-event");
            return true;
          } else {
            return false;
          }
        }
      });
    }
    _ref4 = $("input.toggle-room");
    for (_l = 0, _len4 = _ref4.length; _l < _len4; _l++) {
      checkbox = _ref4[_l];
      $(checkbox).attr("checked", true);
      $(checkbox).change(function() {
        var event, _len5, _m, _ref5, _results;
        $("table[data-room='" + $(this).data('room') + "']").toggle();
        _ref5 = $("table.room div.event");
        _results = [];
        for (_m = 0, _len5 = _ref5.length; _m < _len5; _m++) {
          event = _ref5[_m];
          _results.push(update_event_position(event));
        }
        return _results;
      });
    }
    $("a#hide-all-rooms").click(function() {
      $("input.toggle-room").attr("checked", false);
      return $("table.room").hide();
    });
    return $("select#track_select").change(function() {
      return $.ajax({
        url: $(this).parent().attr("action"),
        data: {
          track_id: $(this).val()
        },
        dataType: "html",
        success: function(data) {
          $("div#unscheduled-events").html(data);
          return $("div#unscheduled-events div.event").draggable({
            revert: "invalid",
            opacity: 0.4
          });
        }
      });
    });
  });
}).call(this);
