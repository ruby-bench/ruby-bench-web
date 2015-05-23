$(document).on('page:change', function() {
  if(window.ga) {
    ga('send', 'pageview', window.location.href);
  }
});
