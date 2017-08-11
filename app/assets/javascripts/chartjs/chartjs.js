//= require chartjs/chartjs.core
//= require chartjs/chartjs.annotations
//= require chartjs/chartjs.zoom
//= require chartjs/chartjs.nodata

Chart.defaults.global.zoom = {
  enabled: true,
  drag: true,
  mode: 'x',
  onChange: function(chart, zoom, center, zoomOptions) {
    //var min = scale.dataMin / 1000 + scale.left;
    //var max = scale.dataMax / 1000 - scale.right;

    console.log(chart);
    console.log(zoom);
    console.log(center);
    console.log(zoomOptions);

    var currentUrl = location.href;
    currentUrl = updateQueryStringParameter(currentUrl, "_past", "");
    currentUrl = updateQueryStringParameter(currentUrl, "_interval", "");
    currentUrl = updateQueryStringParameter(currentUrl, "_st", min);
    currentUrl = updateQueryStringParameter(currentUrl, "_se", max);

    //window.location = currentUrl;
  }
};
