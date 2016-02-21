$(document).on('ready page:load', function() {
  if (location.pathname) {
    $(".navbar-nav a[href='" + location.pathname + "']").addClass('current');
  }

  var $resultTypesForm = $('.result-types-form');
  var xhr;

  $('.result-types-form select').change(function (event) {
    var $spinner = $('.spinner');

    // http://stackoverflow.com/questions/4551175/how-to-cancel-abort-jquery-ajax-request
    if (xhr && xhr.readyState !== 4) {
      xhr.abort();
    }

    var organizationName = $resultTypesForm.data('organization-name');
    var repoName = $resultTypesForm.data('repo-name');
    var name = $resultTypesForm.data('name');

    var resultType = $('.result-types-form select').val() || "";
    var benchmarkRunDisplayCount = $('#benchmark_run_display_count').val();

    if (benchmarkRunDisplayCount !== undefined) {
      displayUrlParams = '&display_count=' + benchmarkRunDisplayCount;
    } else {
      displayUrlParams = '';
    }

    xhr = $.ajax({
      url: ['', organizationName, repoName, name].join('/'),
      type: 'GET',
      data: {
        result_type: resultType,
        display_count: benchmarkRunDisplayCount
      },
      dataType: 'script',
      beforeSend: function () {
        $spinner.toggleClass('hide');
        $('#chart-container').empty();
        $('html, body').animate({scrollTop: 0}, 0);

        if (history && history.pushState) {
          var newUrl =  '/' + organizationName +
                        '/' + repoName +
                        '/' + name +
                        '?result_type=' + resultType + displayUrlParams;
          history.pushState(null, '', newUrl);
        }
      },
      complete: function () {
        $spinner.toggleClass('hide');
      }
    });
  });

  drawReleaseChart('.release-chart');
  drawChart('.chart');
});
