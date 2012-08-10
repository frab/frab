//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery-ui-timepicker-addon
//= require jquery.dateFormat
//= require cocoon
//= require twitter/bootstrap

$(function() {
  $('.topbar').dropdown();
  $('.alert-message').alert();
  $('a[data-original-title]').popover();
});
