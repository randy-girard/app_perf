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
//= require vanilla-ujs
//= require jQueryUI/jquery-ui
//= require axios
//= require pace/pace
//= require progressive_render
//= require knob/jquery.knob
//= require jvectormap/jquery-jvectormap-1.2.2.min
//= require jvectormap/jquery-jvectormap-world-mill-en
//= require bootstrap
//= require datepicker/bootstrap-datepicker
//= require timepicker/bootstrap-timepicker
//= require daterangepicker/moment
//= require daterangepicker/daterangepicker
//= require morris/morris
//= require sparkline/jquery.sparkline.min
//= require slimScroll/jquery.slimscroll
//= require fastclick/fastclick
//= require vis/vis
//= require AdminLTE

//= require utils
//= require charts/charts
//= require react.init

document.addEventListener("DOMContentLoaded", function() {
  /*$('div[data-remote="true"]').each(function() {
    var self = $(this);
    var url = self.data("url");

    self.after("<div class='overlay'><i class='fa fa-spinner fa-spin'></i></div>");
    self.load(url, function() {
      self.next(".overlay").remove();
    });
  });
  */
})

document.addEventListener('click', function(e) {
  if (e.target.matches('[data-remote-element]')) {
    e.preventDefault();

    var self = $(e.target);
    var url = self.attr("href");
    var remoteElement = self.data("remote-element");
    var element = $(remoteElement);
    var limit = element.data("limit");
    var order = element.data("order");

    var newLimit = self.data("limit");
    if(newLimit)
      limit = newLimit;
    var newOrder = self.data("order");
    if(newOrder)
      order = newOrder;

    element.data("limit", limit);
    element.data("order", order);

    element.after("<div class='overlay'><i class='fa fa-spinner fa-spin'></i></div>");
    $.ajax({
      url: url,
      data: {
        _limit: limit,
        _order: order
      },
    }).success(function(data) {
      element.html(data);
      var newUrl = element.find("table").data("url");
      element.attr("url", newUrl);
    }).done(function() {
      element.next(".overlay").remove();
    });
  }
}, false);

$(function() {
  $(".singledatetime").daterangepicker({
    singleDatePicker: true,
    timePicker: true,
    locale: {
      format: 'YYYY-MM-DD h:mm A'
    }
  });


});
