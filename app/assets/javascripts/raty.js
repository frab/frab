$(document).ready(function(){
  $('div[data-raty-input="on"]').each(function(){
    var source = $(this).data('source');
    $(this).raty({
      half: true,
      path:        $(this).data('path'),
      starOn:      $(this).data('star-on'),
      starOff:     $(this).data('star-off'),
      starHalf:    $(this).data('star-half'),
      score: $(source).val(),
      scoreName: $(this).data('target')
    })
  });

  $('div[data-raty="on"]').each(function(index) {
    $(this).raty({
      half: true,
      path:        $(this).data('path'),
      starOn:      $(this).data('star-on'),
      starOff:     $(this).data('star-off'),
      starHalf:    $(this).data('star-half'),
      readOnly: true,
      score: $(this).data('rating')
    });
  });
});
