var drawn = [];

var drawSparkline = function(chartClass, callback) {
  $charts = $(chartClass);

  $charts = $charts.filter(function(index, chart) {
    $chart = $(chart);
    return $chart.visible(true) && (drawn.indexOf($chart) < 0)
  });

  $charts.each(function() {
    $this = $(this);

    if($this.length) {
      $this.highcharts({
        chart: {
          animation: false,
          backgroundColor: 'transparent',
          type: 'line',
          margin: [2, 0, 2, 0],
          width: 360,
          height: 40
        },
        title: {
          text: ""
        },
        credits: {
          enabled: false
        },
        exporting: {
          enabled: false
        },
        xAxis: {
          labels: {
            enabled: false
          },
          title: {
            text: null
          },
          startOnTick: false,
          endOnTick: false,
          tickPositions: []
        },
        yAxis: {
          endOnTick: false,
          startOnTick: false,
          labels: {
            enabled: false
          },
          title: {
            text: null
          },
          tickPositions: [0]
        },
        legend: {
          enabled: false
        },
        tooltip: {
          animation: false,
          borderWidth: 0,
          shadow: false,
          hideDelay: 0,
          padding: 0,
          shared: true,
          headerFormat: ''
        },
        series: $this.data('columns'),
        plotOptions: {
          series: {
            animation: false
          }
        }
      });

      drawn.push($this);
      if (callback) callback();
    }
  })
};
