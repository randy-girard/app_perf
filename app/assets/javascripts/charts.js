$(function() {
  function turbolinksSetInterval(intervalFunction, duration) {
    var interval = setInterval(intervalFunction, duration);
    $(document).on('page:before-change', removeInterval);

    function removeInterval() {
      range = "";
      clearInterval(interval);
      $(document).off('page:before-change', removeInterval);
    }
  };

  function updateChart() {
    var element = $(this);
    element.data("paused", false);

    element.bind("plotselecting", function(event) {
      element.data("paused", true);
    });

    element.bind("plotselected", function (event, ranges) {
      var currentUrl = location.href;
      $.each(plot.getXAxes(), function(_, axis) {
        var opts = axis.options;
        opts.min = ranges.xaxis.from / 1000;
        opts.max = ranges.xaxis.to / 1000;
        currentUrl = updateQueryStringParameter(currentUrl, "_past", "");
        currentUrl = updateQueryStringParameter(currentUrl, "_interval", "");
        currentUrl = updateQueryStringParameter(currentUrl, "_st", opts.min);
        currentUrl = updateQueryStringParameter(currentUrl, "_se", opts.max);
      });
      plot.setupGrid();
      plot.draw();
      plot.clearSelection();
      window.location = currentUrl;
    });

    var legend = element.data("legend");
    var duration = element.data("duration");
    var url = element.data("url");
    var unit = element.data("unit");
    var range = "";
    var data = [];

    var types = [{
			eventType: "Deployment",
			color: "black",
      markerSize: 10,
			markerShow: true,
      position: 'TOP',
			lineStyle: 'solid',
			lineWidth: 1
    }];

    var options = {
      series: {
          stack: true,
          shadowSize: 0,
          lines: {
            show: true,
            fill: true,
            lineWidth: 1
          },
          points: { show: false, fill: false },
          curvedLines: {
            apply: true,
            active: true,
            monotonicFit: true
          }
      },
      legend: {
        noColumns: 15,
        container: $(legend)
      },
      events: {
				data: [],
				types: types
			},
      xaxis: {
        mode: "time",
        timeformat: "%I:%M:%S",
        timezone: "browser"
      },
      yaxis: {
        tickFormatter: function(value, axis) {
            return value + unit;
        }
      },
      selection: { mode: "x" },
      grid: {
        borderWidth:0,
        labelMargin:0,
        axisMargin:0,
        minBorderMargin:0
      }
    };

    function onDataReceived(data) {
      chartData = data["data"];
      events = data["events"];
      options['events']['data'] = events;
      $.plot(element, chartData, options);
    }

    function remoteFetchData(element) {
      if(!element.data("paused")) {
        $.ajax({
          url: url,
          type: "GET",
          dataType: "json",
          success: onDataReceived
        });
      }
    }

    function fetchData(element) {
				remoteFetchData(element);
        turbolinksSetInterval(function() {
          remoteFetchData(element)
        }, 5000);
    };

    var plot = $.plot(element, data, options);

    fetchData(element);
  }

  $.ajaxSetup({ cache: false });

  $(".dynamic-chart").each(updateChart);
});
