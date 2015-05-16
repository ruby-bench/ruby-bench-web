$(function () {

  var $bannerChart = $('.landing-banner-background');

  if ($bannerChart.length) {

    // TODO: Load this JS script only on landing page.
    function getVariedValue (value, variance, dp) {
      if (dp === undefined) {
        dp = 0;
      }
      var min = value + variance;
      var max = value - variance;
      var divisor = Math.pow(10, dp);
      return Math.round((Math.random() * (max - min) + min) * divisor) / divisor;
    }

    var NUM_POINTS = 50;
    var TRANSPARENT_COLOR = 'rgba(0,0,0,0)';
    var GRAY_COLOR = 'rgba(75,75,75,0.1)';
    var ANIMATION_DURATION = 3000;

    function generateData () {
      // Returns a list of random values. Values do not have real significance.
      var dataPoints = [];
      for (var i = 0; i < NUM_POINTS; i++) {
        dataPoints.push(getVariedValue(10, 6, 0));
      }
      return dataPoints;
    }

    $('.landing-banner-background').highcharts({
      chart: {
        backgroundColor: TRANSPARENT_COLOR,
        showAxes: false
      },
      exporting: {
        enabled: false
      },
      credits: {
        enabled: false
      },
      colors: [GRAY_COLOR],
      yAxis: {
        gridLineWidth: 0,
        labels: {
          enabled: false
        },
        lineWidth: 0,
        plotLines: [{
          color: TRANSPARENT_COLOR,
          value: 0,
          width: 1,
        }],
        title: {
          text: null
        }
      },
      xAxis: {
        labels: {
          enabled: false
        },
        lineWidth: 0,
        tickWidth: 0
      },
      plotOptions: {
        line: {
          animation: {
            duration: ANIMATION_DURATION
          },
          enableMouseTracking: false,
          lineWidth: 5,
          marker: {
            enabled: false
          }
        }
      },
      title: {
        text: null
      },
      legend: {
        enabled: false
      },
      series: [{
        data: generateData()
      }]
    });
  }
});
