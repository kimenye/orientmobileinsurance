$(function(){
    $('.disabled input, .disabled select').prop('disabled', true);

    $('.disabled .button').hide()

    $('.incident_location select').change(function() {
        if (this.value != "Vehicle") {
            $('.theft-questions input, .theft-questions textarea').prop('disabled', true);
            $('.theft-questions input').val('');
        }
        else {
            $('.theft-questions input, .theft-questions textarea').prop('disabled', false);
        }
    });
    
    if ($('.incident_location select').val() != "Vehicle") {
        $('.theft-questions input, .theft-questions textarea').prop('disabled', true);
    }

    $('.new_subscription').on("ajax:success", function(e, data, status, xhr) {        
        $('.email_error_message').addClass('hide').html('');
        $('.thankyou').removeClass('hide');

    });

    $('.new_subscription').on("ajax:error", function(e, data, status, error) {
        $('.email_error_message').removeClass('hide').html("Email " + data.responseJSON.email[0]);
    });


    $('.new_feedback').on("ajax:success", function(e, data, status, xhr) {        
        $('.new_feedback').hide( "fade", { direction: "down" }, "slow", function()  {
            $('.thankyou-feedback').show( "fade", { direction: "down" }, "fast");    
        });
        
    });
});