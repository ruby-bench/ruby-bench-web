$(document).on('turbolinks:load', function() {
  $('#commits_run_form').submit(function(event) {
    $('#notice').remove();
    $('#wait_commits_alert').removeClass('hidden');
  });
  
  $('#releases_run_form').submit(function(event) {
    $('#notice').remove();
    $('#wait_releases_alert').removeClass('hidden');
  });
});

