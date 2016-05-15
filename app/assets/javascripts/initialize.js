$(function() {
  $('.topbar').dropdown();
  $('.alert-message').alert();
  $('a[data-original-title]').popover();
  $('[data-function="toggle"]').click(function(){
    var args = $(this).data("args");
    $(args.target).toggle();
  });
});
