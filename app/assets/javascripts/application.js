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
//= require jquery_ujs
//= require foundation/foundation
//= require foundation/foundation.orbit
//= require foundation/foundation.forms
//= require foundation/foundation.abide
//= require foundation/foundation.placeholder
//= require foundation/foundation.section
//= require foundation/foundation.topbar.js
//= require jquery-ui-1.10.3.custom.min
//= require jquery.validate.min
//= require home
//= require foundation.magellan
//= require jquery.smint
//= require chosen.jquery.min

$(function(){ 
	$(document).foundation(); 

	$('.learn-more a').click(function(e) {
		e.preventDefault();
		var goTo =  $('div.insure').offset().top - 30
		$("html, body").animate({ scrollTop: goTo - 30 }, 500);
	});

	$('ul.top-links a, .menu a').click(function(e) {
		var id = $(this)[0].id;
		var goTo = $('div.' + id).offset().top - 30
		$("html, body").animate({ scrollTop: goTo - 30 }, 500);
		e.preventDefault();
	});

	if ($('.jumbo').length > 0) {
		var headerTop = Math.max($('.jumbo').offset().top + 5, 575);
		$(window).scroll(function(){
			if( $(window).scrollTop() > headerTop) 
				$('.logo').addClass('landscape');		
			else
				$('.logo').removeClass('landscape');
		});		
	}

});
