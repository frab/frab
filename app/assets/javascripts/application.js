//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require cocoon
//= require twitter/bootstrap

$(function() {
  $('.topbar').dropdown();
  $('.alert-message').alert();
  $('a[data-original-title]').popover();
});
