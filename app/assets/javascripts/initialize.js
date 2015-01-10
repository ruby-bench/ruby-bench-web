$(document).ready(function() {
  var location_pathname = location.pathname;

  if (location_pathname != '/') {
    $(".top-nav a[href='" + location.pathname + "']").addClass('current');
  }

  var $spinner = $(".spinner");
  var xhr;

  $(".result-types-form input[type=radio]").change(function(value) {
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
})
