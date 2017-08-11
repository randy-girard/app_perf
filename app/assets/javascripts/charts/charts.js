//= require charts/highcharts
// require charts/highcharts.boost
//= require charts/highcharts.no-data-to-display
//= require charts/chartkick

$(function () {
  Highcharts.setOptions({
  	global: {
  		useUTC: false
  	},
    lang: {
      noData: "No data to display."
    },
    plotOptions: {
      series: {
        animation: false
      }
    }
  });

  // General, global event listener
  var globalCallback = function (chart) {
    Highcharts.addEvent(chart, 'selection', function (e) {
      var min = e.xAxis[0].min / 1000;
      var max = e.xAxis[0].max / 1000;

      var currentUrl = location.href;
      currentUrl = updateQueryStringParameter(currentUrl, "_past", "");
      currentUrl = updateQueryStringParameter(currentUrl, "_interval", "");
      currentUrl = updateQueryStringParameter(currentUrl, "_st", min);
      currentUrl = updateQueryStringParameter(currentUrl, "_se", max);

      window.location = currentUrl;
    });
  };

  Highcharts.Chart.prototype.callbacks.push(globalCallback);
});
