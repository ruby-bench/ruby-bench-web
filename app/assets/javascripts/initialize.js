$(document).ready(function() {
  var location_pathname = location.pathname;

  if (location_pathname != '/') {
    $(".top-nav a[href*='" + location.pathname + "']").addClass('current');
  }
})
