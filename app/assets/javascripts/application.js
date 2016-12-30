// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jQueryUI/jquery-ui
//= require jquery.turbolinks
//= require chartkick
//= require progressive_render
//= require turbolinks
//= require knob/jquery.knob
//= require jvectormap/jquery-jvectormap-1.2.2.min
//= require jvectormap/jquery-jvectormap-world-mill-en
//= require bootstrap
//= require datepicker/bootstrap-datepicker
//= require daterangepicker/moment
//= require daterangepicker/daterangepicker
//= require morris/morris
//= require sparkline/jquery.sparkline.min
//= require slimScroll/jquery.slimscroll
//= require fastclick/fastclick
//= require flot/jquery.flot
//= require flot/jquery.flot.resize
//= require flot/jquery.flot.categories
//= require flot/jquery.flot.selection
//= require flot/jquery.flot.time
//= require flot/jquery.flot.stack
//= require flot/jquery.flot.fillbetween
//= require flot/jquery.flot.curvedlines
//= require flot/jquery.flot.events
//= require AdminLTE

function updateQueryStringParameter(uri, key, value) {
  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    if(value == "")
      return uri.replace(re, '$1');
    else {
      return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
  }
  else {
    return uri + separator + key + "=" + value;
  }
}

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
    var range = "";
    var data = [];

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
      xaxis: {
        mode: "time",
        timeformat: "%I:%M:%S",
        timezone: "browser"
      },
      yaxis: {
        tickFormatter: function(value, axis) {
            return value + "ms";
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
      $.plot(element, data, options);
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
