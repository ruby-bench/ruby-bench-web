$(document).ready(function() {
  var locationPathName = location.pathname != '/' ? location.pathname : '/ruby/ruby/releases';
  $(".top-nav a[href='" + locationPathName + "']").addClass('current');

  $(".result-types-form input[type=radio]").change(function(value) {
    var $spinner = $(".spinner");
    var xhr;

    // http://stackoverflow.com/questions/4551175/how-to-cancel-abort-jquery-ajax-request
    if(xhr && xhr.readyState != 4){
      xhr.abort();
    }

    var $resultTypesForm = $(".result-types-form");

    var organizationName = $resultTypesForm.data('organization-name');
    var repoName = $resultTypesForm.data('repo-name');
    var name = $resultTypesForm.data('name')
    var resultType = $(this).val();

    xhr = $.ajax({
      url: "/" + organizationName + "/" + repoName + "/" + name,
      type: 'GET',
      data: { result_type: resultType },
      dataType: 'script',
      beforeSend: function() {
        $spinner.toggleClass('hide');
        $("#chart-container").empty();
        $('html,body').animate({scrollTop:0},0);

        if (history && history.pushState) {
          history.pushState(null, '', "/" + organizationName + "/" + repoName + "/" + name + '?result_type=' + resultType);
        }
      },
      complete: function() {
        $spinner.toggleClass('hide');
      }
    });
  })

  drawReleaseChart(".release-chart");
  drawChart(".chart");

  // Toggles benchmark types panel.
  $('#benchmark-types-form-hide').click(function(e) {
    e.preventDefault();
    $("#benchmark-types-form-container").removeClass().toggleClass('col-xs-0');
    $("#charts-container").removeClass().toggleClass('col-xs-12');
    $("#benchmark-types-form-container .panel").toggleClass('hide');
    $("#benchmark-types-form-show").toggleClass('hide');

    // FIXME: Figure out a way to determine which chart we have to draw
    drawReleaseChart(".release-chart");
    drawChart(".chart");
  })

  $('#benchmark-types-form-show').click(function(e) {
    e.preventDefault();
    $("#benchmark-types-form-container").removeClass().toggleClass('col-xs-4');
    $("#charts-container").removeClass().toggleClass('col-xs-8');
    $("#benchmark-types-form-container .panel").toggleClass('hide');
    $("#benchmark-types-form-show").toggleClass('hide');

    // FIXME: Figure out a way to determine which chart we have to draw
    drawReleaseChart(".release-chart");
    drawChart(".chart");
  })
})
