/* DO NOT MODIFY. This file was compiled Mon, 04 Jul 2011 16:35:45 GMT from
 * /home/dave/projects/frab/app/coffeescripts/public_schedule.coffee
 */

(function() {
  $(function() {
    var column_count, columns_displayable, current_page, page_count, pages_html, steps;
    column_count = $("table.rooms-table th").size();
    columns_displayable = Math.floor(($(window).width() - 95) / 200);
    if (column_count > columns_displayable) {
      $("#conference-rooms").css("overflow", "hidden");
      $("#conference-rooms").css("width", columns_displayable * 200);
      current_page = 1;
      page_count = Math.ceil(column_count / columns_displayable);
      pages_html = "<span id='pages'>( ";
      pages_html += "<span id='current-page'>" + current_page + "</span>";
      pages_html += " / ";
      pages_html += "<span id='page-count'>" + page_count + "</span>";
      pages_html += " )</span>";
      pages_html += "<a class='page-button disabled' href='#' id='previous-page'>&lt;</a> ";
      pages_html += "<a class='page-button' href='#' id='next-page'>&gt;</a> ";
      $('#pagination').append(pages_html);
      $('#pagination').width($("#conference-rooms").width() + $('#time-line').width());
      steps = 200 * columns_displayable;
      $('a#next-page').click(function(event) {
        if (current_page < page_count) {
          $('table.rooms-table').animate({
            'left': "-=" + steps + "px"
          }, "slow");
          current_page += 1;
          $('a#previous-page').removeClass('disabled');
          if (current_page === page_count) {
            $('a#next-page').addClass('disabled');
          }
          $('span#current-page').html(current_page);
          return event.preventDefault();
        }
      });
      return $('a#previous-page').click(function(event) {
        if (current_page > 1) {
          $('table.rooms-table').animate({
            'left': "+=" + steps + "px"
          }, "slow");
          current_page -= 1;
          $('a#next-page').removeClass('disabled');
          if (current_page === 1) {
            $('a#previous-page').addClass('disabled');
          }
          $('span#current-page').html(current_page);
          return event.preventDefault();
        }
      });
    }
  });
}).call(this);
