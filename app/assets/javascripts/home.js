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
});