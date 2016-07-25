var drawSparkline = function(chartClass) {
  $(chartClass).each(function() {
    $this = $(this);

    if($this.length) {
      $this.highcharts({
        chart: {
          animation: false,
          backgroundColor: 'transparent',
          type: 'line',
          margin: [2, 0, 2, 0],
          width: 360,
          height: 40,
          style: {
            overflow: 'visible'
          }
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
          backgroundColor: 'white',
          animation: false,
          borderWidth: 0,
          shadow: false,
          hideDelay: 0,
          padding: 0,
          headerFormat: '',
          positioner: function (w, h, point) {
            return { x: point.plotX - w / 2, y: point.plotY - h };
          }
        },
        series: $this.data('columns'),
        plotOptions: {
          series: {
            animation: false
          }
        }
      });
    }
  })
};
