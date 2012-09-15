//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery-ui
//= require jquery-ui-timepicker-addon
//= require jquery.dateFormat
//= require cocoon

$(function() {
  $('.topbar').dropdown();
  $('.alert-message').alert();
  $('a[data-original-title]').popover();
});
