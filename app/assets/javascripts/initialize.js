$(document).on('turbolinks:load', function() {
  if (location.pathname) {
    $(".navbar-nav a[href='" + location.pathname + "']").addClass('current');
  }

  var $resultTypesForm = $('.result-types-form');
  var xhr;

  //Add left and right arrow keys to navigate benchmark types
  var $options = $('.result-types-form select.form-control:first option');
  var optsLength = $options.length;
  var $select = $('.result-types-form select.form-control:first');
  var optionIndex = 0;

  function incrementOptionIndex(index, n, increment) {
    //calculated k because of the JavaScript modulo bug
    k = (((index + increment) % n) + n) % n;
    if (k == 0) {
      k = (((k + increment) % n) + n) % n;
    }
    index = k;
    return index;
  };

  $(document).keyup(function(e) {
    $select.children().removeAttr('selected');

    switch(e.which) {
      case 37:  //left
        optionIndex = incrementOptionIndex(optionIndex, optsLength, -1);
        break;

      case 39:  //right
        optionIndex = incrementOptionIndex(optionIndex, optsLength, 1);
        break;

      default:
        return;  //exit this handler for other keys
    }

    $select.children().eq(optionIndex).attr('selected', 'selected');
    $select.val($select.children().eq(optionIndex).val())
    $select.change();
    e.preventDefault();  //prevent the default action (scroll / move caret)
  });

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
