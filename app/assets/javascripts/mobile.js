// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui-1.10.3.custom.min
//= require jquery.mobile.tabs
//= require jquery.mobile-1.3.1.min
//= require jquery.validate.min
//= require deviceatlas-1.1.min
//= require cm
//= require ios.detect

$(document).bind('pageinit', function () {
    $('.edit_enquiry').validate();

    $('.buttons [type="submit"]').button('disable');
    $('.tac-checkbox').change(function() {
      if (this.checked) {
          $('.buttons [type="submit"]').button('enable');
      } else {
          $('.buttons [type="submit"]').button('disable');
      }
    });

    $('#enquiry_customer_phone_number').attr('disabled', 'disabled');
});

