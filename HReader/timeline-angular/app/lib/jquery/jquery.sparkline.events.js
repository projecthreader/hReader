/**
*
* jquery.sparkline.events.js
*
* v1
* Contact: Mick Thompson (mick@davidmichaelthompson.com)
*
* Generates events for the inline graph lib sparklines
* 
* Compatible with Internet Explorer 6.0+ and modern browsers equipped with the canvas tag
* (Firefox 2.0+, Safari, Opera, etc)
*
* License: New BSD License
* 
* 
* Redistribution and use in source and binary forms, with or without modification, 
* are permitted provided that the following conditions are met:
* 
*     * Redistributions of source code must retain the above copyright notice, 
*       this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright notice, 
*       this list of conditions and the following disclaimer in the documentation 
*       and/or other materials provided with the distribution.
*     * Neither the name of Splunk Inc nor the names of its contributors may 
*       be used to endorse or promote products derived from this software without 
*       specific prior written permission.
* 
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
* SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
* OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
*
*
*Depends on:
*  -jquery.sparkline.js
*
*
*
*Usage:
*
*
*
*/


(function($) {
 

$.fn.sparklineEvents = function (uservalues, options) {
	        var options = $.extend({
	            type : 'line',
	            lineColor : '#00f',
	            fillColor : '#1e42c8',
	            defaultPixelsPerValue : 3,
	            width : 'auto', 
	            height : 'auto',
	            composite : false,
				onClickCallback: undefined,
				onMouseOverCallback: undefined,
				highlightColor: '#1ea6c8',
				selectColor: '#c81e1e'
	        }, options ? options : {});

	        return this.each(function() {
	            var render = function() {
	                var values = (uservalues=='html' || uservalues==undefined) ? $(this).text().split(',') : uservalues;
	                var width = options.width=='auto' ? values.length*options.defaultPixelsPerValue : options.width;
	                if (options.height == 'auto') {
	                    if (!options.composite || !this.vcanvas) {
	                        // must be a better way to get the line height
	                        var tmp = document.createElement('span');
	                        tmp.innerHTML = 'a';
	                        $(this).html(tmp);
	                        height = $(tmp).innerHeight();
	                        $(tmp).remove();
	                    }
	                } else {
	                    height = options.height;
	                }

	                $.fn.sparkline[options.type].call(this, values, options, width, height);
	
					this.options = options;
					this.values = values;
	        		if(options.onClickCallback != undefined){
						$(this).bind("click", function(e){								
							//where am i based on left and bar width and space..
							var theElement = this;
							var positionX = 0;
							while (theElement != null)        
						 	{        
							   positionX += theElement.offsetLeft;
							   theElement = theElement.offsetParent;
							 }
							var totalbarspace = this.options.barWidth+this.options.barSpacing;
							var left =  e.pageX - positionX;
							var element = Math.floor(left / totalbarspace);
							var opts = this.options;
							opts.selectIndex = element;
							
							$.fn.sparkline[this.options.type].call(this, this.values, opts, width, height);
							options.onClickCallback(element, this.values[element]);
						})
					}
					$(this).bind("ouseover", function(e){								
						//where am i based on left and bar width and space..
						var theElement = this;
						var positionX = 0;
						while (theElement != null)        
					 	{        
						   positionX += theElement.offsetLeft;        
						   theElement = theElement.offsetParent;        
						 }
						var totalbarspace = this.options.barWidth+this.options.barSpacing;
						var left = e.pageX - positionX
						var element = Math.floor(left / totalbarspace);
						var opts = this.options;
						opts.highlightIndex = element;
						$.fn.sparkline[this.options.type].call(this, this.values, opts, width, height);
					    if(options.onMouseOverCallback != undefined){
							options.onMouseOverCallback(element, this.values[element]);
						}
					})
			
	    		}
				
	            // jQuery 1.3.0 completely changed the meaning of :hidden :-/
	            if (($(this).html() && $(this).is(':hidden')) || ($.fn.jquery < "1.3.0" && $(this).parents().is(':hidden'))) {
	                pending.push([this, render]);
	            } else {
	                render.call(this);
	            }
	        });
};	    
	



 
})(jQuery);
