$(document).on('turbolinks:load', function() {
  $('#manual_run_form').submit(function(event) {
    $('#notice').remove();
    $('#wait_alert').removeClass('hidden');
  });
});

