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
//= require jquery.turbolinks
//= require foundation
//= require highcharts
//= require highcharts/highcharts-more
//= require chartkick
//= require turbolinks
//= require_tree .

$(function(){
  function turbolinksSetInterval(intervalFunction, duration) {
    var interval = setInterval(intervalFunction, duration);
    $(document).on('page:before-change', removeInterval);

    function removeInterval() {
      clearInterval(interval);
      $(document).off('page:before-change', removeInterval);
    }
  };

  function updateChart() {
    var element = $(this);
    var duration = element.data("duration");
    var url = element.data("url");
    var height = element.data("height");
    element.css("height", height);
    element.css("line-height", height);

    element.load(url);

    turbolinksSetInterval(function() {
      element.load(url);
    }, duration);
  }

  $.ajaxSetup({ cache: false });

  $(document).foundation();

  $(".dynamic-chart").each(updateChart);
});
