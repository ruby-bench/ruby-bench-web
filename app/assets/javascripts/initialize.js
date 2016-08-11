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

    var admin = $resultTypesForm.data('admin');
    var organizationName = $resultTypesForm.data('organization-name');
    var repoName = $resultTypesForm.data('repo-name');
    var name = $resultTypesForm.data('name');

    var resultType = $('.result-types-form select').val() || "";
    var releasesType = $('#admin_releases_type').val();
    var benchmarkRunDisplayCount = $('#benchmark_run_display_count').val();

    if (benchmarkRunDisplayCount !== undefined) {
      displayUrlParams = '&display_count=' + benchmarkRunDisplayCount;
    } else {
      displayUrlParams = '';
    }

    if (releasesType !== undefined) {
      releasesTypeParams = '&releases_type=' + releasesType;
    } else {
      releasesTypeParams = '';
    }

    var url = ['',organizationName, repoName, name].join('/');
    var base_url = location.pathname;
    var newUrl = '/' + organizationName +
                 '/' + repoName +
                 '/' + name +
                 '?result_type=' + resultType + releasesTypeParams + displayUrlParams;

    if (base_url.includes("/admin")) {
      newUrl = '/' + admin + newUrl;
      url = ['', admin, organizationName, repoName, name].join('/');
    }
    xhr = $.ajax({
      url: url,
      type: 'GET',
      data: {
        result_type: resultType,
        releases_type: releasesType,
        display_count: benchmarkRunDisplayCount
      },
      dataType: 'script',
      beforeSend: function () {
        $spinner.toggleClass('hide');
        $('#chart-container').empty();
        $('html, body').animate({scrollTop: 0}, 0);

        if (history && history.pushState) {
          history.pushState(null, '', newUrl);
        }
      },
      complete: function () {
        $spinner.toggleClass('hide');
      }
    });
  });
});
