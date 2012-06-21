$.fn.slideShow = function(timeOut) {
	var $elem = this;
	this.children(':gt(0)').hide();
	setInterval(function() {
		$elem.children().eq(0).fadeOut().next().fadeIn().end().appendTo($elem);
	}, timeOut || 5000);
};

$(document).ready(function() {
	$('#slides').slideShow();
});

$('.carousel').carousel({
  interval: 2000
  .carousel('cycle')
})

