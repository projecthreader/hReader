'use strict';

/* Directives */
var Timeline = angular.module('Timeline', []);

			Timeline.directive('sparkline', function () {
			  return {
			    restrict: 'E', // the directive restricts it to an element level
			    link: function postLink(scope, iElement, attrs) {
			      scope.$watch('vitals', function (newVal, oldVal) {
			      	if (newVal != null) {
						$(iElement).sparkline('html', { 
							type: 'line',
						    lineColor: '#000000',
						    spotColor: '#000000',
						    minSpotColor: '#d60D26',
						    maxSpotColor: '#d60D26',
						    highlightSpotColor: '#048A82',
							highlightLineColor: '#d60D26',
						    fillColor: false,
						   	lineWidth: 3,
							spotRadius: 5,
						    width: 460,
						    height: 75,
						    drawNormalOnTop: false
					});
				}
			});
		}
	};
});
