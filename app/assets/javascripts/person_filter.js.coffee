uniqueId = Math.random().toString(36).substr(2) 

update_filter = (lookup_people_url, filter_box, select_box, display_box, hidden_box) ->
  term = filter_box.value || ""
  $.ajax(
    url: "#{lookup_people_url}.json?cachetag=#{uniqueId}&term=#{term}"
    cache: true,
    dataType: "json",
    success: (data) ->
    
      # Don't replace a name with a "too many" message
      # unless triggered explicitly
      if (data.too_many) && (!(filter_box.value?)) && display_box.text()
        console.log ("skipping")
        return
        
      # Update selection box
      select_box.empty()
      if data.msg || data.too_many
        select_box.append $("<option>").attr("value", "").text(data.msg || data.too_many)
      for person in data.people
        select_box.append $("<option>").attr("value", person.id).text(person.text)
        
      # Pre-select the existing person if possible
      previously_selected_id=hidden_box.attr('value')
      if previously_selected_id
        w = select_box.find("option[value=#{previously_selected_id}]")
        if (w)
          w.attr('selected', true)
          
      # Update the hidden person_id
      selected_id = select_box.find("option:selected").first().val()
      hidden_box.attr("value", selected_id).trigger("change")
      
      # If only one option is available, display it
      # without a selection box
      only_one_option = select_box.children().size() == 1
      if only_one_option
        display_box.text(select_box.text())
        display_box.show()
        select_box.parent().hide()

        display_box.removeClass("accepted")
        display_box.addClass("accepted") if selected_id
      else
        display_box.text('')
        display_box.hide()
        select_box.parent().show()
      return
    error: () ->
      hidden_box.attr("value", "").trigger("change")
      display_box.hide()
      select_box.parent().hide()
  )
  return

window.update_and_attach_person_filter = (url, item) ->
  filter_box = item.find('input#filter')
  select_box = item.find('span#person_select select')
  display_box = item.find('span#display_box')
  hidden_box = item.find('span#person_id input')
  update_filter(url, filter_box, select_box, display_box, hidden_box)
  filter_box.on 'input', ->
    update_filter(url, this, select_box, display_box, hidden_box)
  select_box.on 'change', ->
    hidden_box.attr("value", select_box.val()).trigger("change")
    
true

    
