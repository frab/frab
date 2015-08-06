$(function() {

  NotificationDefaults = {

    fill: function(options) {
      var id     = options.id;
      var code = $('div#'+id+' select option:selected').text();
      NotificationDefaults._fetch(id, code);
    },

    _fetch: function(id, code) {
      $.ajax({
        type: "GET",
        dataType: "json",
        url: '#{ call_for_papers_default_notifications_path(conference_acronym: @conference.acronym) }',
        data: {'code':code},
        success: function(result){
          var texts = result.notification;
          var topDiv = $('div#'+id);
          var inputs = topDiv.find('input[type=text]');
          $(inputs.get(0)).val(texts.accept_subject);
          $(inputs.get(1)).val(texts.reject_subject);
          inputs = topDiv.find('textarea');
          $(inputs.get(0)).val(texts.accept_body);
          $(inputs.get(1)).val(texts.reject_body);
        }
      });
    },

  };

  $('[data-function="notification-defaults"]').click(function(){
    var uuid = $(this).data("uuid")
    NotificationDefaults.fill({ id: uuid });
    return false;
  });
});

