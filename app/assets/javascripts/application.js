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
//= require pace/pace
//= require progressive_render
//= require turbolinks
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
//= require flot/jquery.flot
//= require flot/jquery.flot.resize
//= require flot/jquery.flot.categories
//= require flot/jquery.flot.selection
//= require flot/jquery.flot.time
//= require flot/jquery.flot.stack
//= require flot/jquery.flot.fillbetween
//= require flot/jquery.flot.curvedlines
//= require flot/jquery.flot.navigate
//= require flot/jquery.flot.events
//= require AdminLTE
//= require charts

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
  $(".singledatetime").daterangepicker({
    singleDatePicker: true,
    timePicker: true,
    locale: {
      format: 'YYYY-MM-DD h:mm A'
    }
  });

  $('[data-remote="true"]').each(function() {
    var self = $(this);
    var url = self.data("url");

    self.after("<div class='overlay'><i class='fa fa-spinner fa-spin'></i></div>");
    self.load(url, function() {
      self.next(".overlay").remove();
    });
  });
});
