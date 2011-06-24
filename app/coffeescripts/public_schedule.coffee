$ ->
  column_count = $("table.rooms-table th").size()
  columns_displayable = Math.floor(($(window).width() - 95) / 200)
  if column_count > columns_displayable
    $("#conference-rooms").css("overflow", "hidden")
    $("#conference-rooms").css("width", columns_displayable * 200)
    current_page = 1
    page_count = Math.ceil(column_count / columns_displayable)
    pages_html = "<span id='pages'>( "
    pages_html += "<span id='current-page'>" + current_page + "</span>"
    pages_html += " / "
    pages_html += "<span id='page-count'>" + page_count + "</span>"
    pages_html += " )</span>"
    pages_html += "<a class='page-button disabled' href='#' id='previous-page'>&lt;</a> "
    pages_html += "<a class='page-button' href='#' id='next-page'>&gt;</a> "
    $('#pagination').append(pages_html)
    $('#pagination').width($("#conference-rooms").width() + $('#time-line').width())
    steps = 200 * columns_displayable
    $('a#next-page').click (event) ->
      if current_page < page_count
        $('table.rooms-table').animate({'left': "-=" + steps + "px"}, "slow")
        current_page += 1
        $('a#previous-page').removeClass('disabled')
        $('a#next-page').addClass('disabled') if current_page == page_count
        $('span#current-page').html(current_page)
        event.preventDefault()
    $('a#previous-page').click (event) ->
      if current_page > 1
        $('table.rooms-table').animate({'left': "+=" + steps + "px"}, "slow")
        current_page -= 1
        $('a#next-page').removeClass('disabled')
        $('a#previous-page').addClass('disabled') if current_page == 1
        $('span#current-page').html(current_page)
        event.preventDefault()
