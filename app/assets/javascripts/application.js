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
//= require axios
//= require pace/pace
//= require bootstrap-sprockets
//= require daterangepicker/moment
//= require daterangepicker/daterangepicker
//= require vis/vis
//= require AdminLTE

//= require utils
//= require charts/charts
//= require react.init
$(function() {
  $(".singledatetime").daterangepicker({
    singleDatePicker: true,
    timePicker: true,
    locale: {
      format: 'YYYY-MM-DD h:mm A'
    }
  });

  $(document).on("mouseover", ".db-statement", function(e) {
    var statements = $(this).find('.db-statements');

    if(timeline) {
      var span_ids = statements.find(".db-statement-span").map(function(){
        return $(this).data('span-id');
      }).get();
      timeline.setSelection(span_ids);
    }
  });

  $(document).on("mouseout", ".db-statement", function(e) {
    timeline.setSelection([]);
  })

  $(document).on("click", ".statement-link", function(e) {
    e.preventDefault();
    var self = $(this);
    var statements = self.closest(".db-statement").find('.db-statements');

    self.find(".rotate").toggleClass('down');
    statements.slideToggle( 100 );
  });
});
