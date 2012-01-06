/* Enhanced version of band.js
 * Includes code to support touch events on iOS
 * Includes support for band labels
 */

Timeline.createBandInfo = function(params) {
    var theme = ("theme" in params) ? params.theme : Timeline.getDefaultTheme();
    
    var eventSource = ("eventSource" in params) ? params.eventSource : null;
    
    var ether = new Timeline.LinearEther({ 
        centersOn:          ("date" in params) ? params.date : new Date(),
        interval:           SimileAjax.DateTime.gregorianUnitLengths[params.intervalUnit],
        pixelsPerInterval:  params.intervalPixels,
        theme:              theme
    });
    
    var etherPainter = new Timeline.GregorianEtherPainter({
        unit:       params.intervalUnit, 
        multiple:   ("multiple" in params) ? params.multiple : 1,
        theme:      theme,
        align:      ("align" in params) ? params.align : undefined,
        showMarkers: ("showMarkers" in params) ? params.showMarkers : true
    });
    
    var eventPainterParams = {
        showText:   ("showEventText" in params) ? params.showEventText : true,
        direction : ("direction" in params) ? params.direction : Timeline.FORWARD,
        theme:      theme
    };
    // pass in custom parameters for the event painter
    if ("eventPainterParams" in params) {
        for (var prop in params.eventPainterParams) {
            eventPainterParams[prop] = params.eventPainterParams[prop];
        }
    }
    
    if ("trackHeight" in params) {
        eventPainterParams.trackHeight = params.trackHeight;
    }
    if ("trackGap" in params) {
        eventPainterParams.trackGap = params.trackGap;
    }
    
    var layout = ("overview" in params && params.overview) ? "overview" : ("layout" in params ? params.layout : "original");
    var eventPainter;
    if ("eventPainter" in params) {
        eventPainter = new params.eventPainter(eventPainterParams);
    } else {
        switch (layout) {
            case "overview" :
                eventPainter = new Timeline.OverviewEventPainter(eventPainterParams);
                break;
            case "detailed" :
                eventPainter = new Timeline.DetailedEventPainter(eventPainterParams);
                break;
            default:
                eventPainter = new Timeline.OriginalEventPainter(eventPainterParams);
        }
    }
    
    return {   
        width:          params.width,
        eventSource:    eventSource,
        timeZone:       ("timeZone" in params) ? params.timeZone : 0,
        ether:          ether,
        etherPainter:   etherPainter,
        eventPainter:   eventPainter,
        bandLabel:		  ("bandLabel" in params) ? params.bandLabel : "",
        theme:          theme,
        zoomIndex:      ("zoomIndex" in params) ? params.zoomIndex : 0,
        zoomSteps:      ("zoomSteps" in params) ? params.zoomSteps : null
    };
};


/*==================================================
 *  Band
 *==================================================
 */
Timeline._Band = function(timeline, bandInfo, index) {
    // Set up the band's object
    
    // Munge params: If autoWidth is on for the Timeline, then ensure that
    // bandInfo.width is an integer     
    if (timeline.autoWidth && typeof bandInfo.width == 'string') {
        bandInfo.width = bandInfo.width.indexOf("%") > -1 ? 0 : parseInt(bandInfo.width);
    }

    this._timeline = timeline;
    this._bandInfo = bandInfo;
    
    this._index = index;
    
    this._locale = ("locale" in bandInfo) ? bandInfo.locale : Timeline.getDefaultLocale();
    this._timeZone = ("timeZone" in bandInfo) ? bandInfo.timeZone : 0;
    this._labeller = ("labeller" in bandInfo) ? bandInfo.labeller : 
        (("createLabeller" in timeline.getUnit()) ?
            timeline.getUnit().createLabeller(this._locale, this._timeZone) :
            new Timeline.GregorianDateLabeller(this._locale, this._timeZone));
    this._theme = bandInfo.theme;
    this._zoomIndex = ("zoomIndex" in bandInfo) ? bandInfo.zoomIndex : 0;
    this._zoomSteps = ("zoomSteps" in bandInfo) ? bandInfo.zoomSteps : null;

    this._dragging = false;

    this._changing = false;
    this._originalScrollSpeed = 5; // pixels
    this._scrollSpeed = this._originalScrollSpeed;
    this._onScrollListeners = [];
    
    var b = this;
    this._syncWithBand = null;
    this._syncWithBandHandler = function(band) {
        b._onHighlightBandScroll();
    };
    this._selectorListener = function(band) {
        b._onHighlightBandScroll();
    };
    
    /*
     *  Install a textbox to capture keyboard events
     */
    var inputDiv = this._timeline.getDocument().createElement("div");
    inputDiv.className = "timeline-band-input";
    this._timeline.addDiv(inputDiv);
    
    this._keyboardInput = document.createElement("input");
    this._keyboardInput.type = "text";
    inputDiv.appendChild(this._keyboardInput);
    SimileAjax.DOM.registerEventWithObject(this._keyboardInput, "keydown", this, "_onKeyDown");
    SimileAjax.DOM.registerEventWithObject(this._keyboardInput, "keyup", this, "_onKeyUp");

    // [mrn]
    /* top, fixed label div for the band */
    if (bandInfo.bandLabel) {
      this._label = this._timeline.getDocument().createElement("div");
      this._label.className = "timeline-band-label-layer";
      this._label.id = "bandLabel_" + this._index;
      var labelText = this._timeline.getDocument().createElement("div");
      labelText.innerHTML = ("bandLabel" in bandInfo) ? bandInfo.bandLabel : "";
      this._label.appendChild(labelText);
      this._timeline.addDiv(this._label);   
    }

    /*
     *  The band's outer most div that slides with respect to the timeline's div
     */
    this._div = this._timeline.getDocument().createElement("div");
    this._div.id = "timeline-band-" + index;
    this._div.className = "timeline-band timeline-band-" + index;
    this._timeline.addDiv(this._div);
    
    SimileAjax.DOM.registerEventWithObject(this._div, "mousedown", this, "_onMouseDown");
    SimileAjax.DOM.registerEventWithObject(this._div, "mousemove", this, "_onMouseMove");
    SimileAjax.DOM.registerEventWithObject(this._div, "mouseup", this, "_onMouseUp");
    SimileAjax.DOM.registerEventWithObject(this._div, "mouseover", this, "_onMouseOver");
    SimileAjax.DOM.registerEventWithObject(this._div, "mouseout", this, "_onMouseOut");
    SimileAjax.DOM.registerEventWithObject(this._div, "dblclick", this, "_onDblClick");
    // Kartik touch fix
    SimileAjax.DOM.registerEventWithObject(this._div,"touchstart",this,"_onTouchStart");
    SimileAjax.DOM.registerEventWithObject(this._div,"touchmove",this,"_onTouchMove");
    if (this._label) {
    	SimileAjax.DOM.registerEventWithObject(this._label, "mousemove", this, "_onMouseMove");
   // 	SimileAjax.DOM.registerEventWithObject(this._label, "mouseover", this, "_onMouseOver");
    }
    var mouseWheel = this._theme!= null ? this._theme.mouseWheel : 'scroll'; // theme is not always defined
    if (mouseWheel === 'zoom' || mouseWheel === 'scroll' || this._zoomSteps) {
        // capture mouse scroll
        if (SimileAjax.Platform.browser.isFirefox) {
            SimileAjax.DOM.registerEventWithObject(this._div, "DOMMouseScroll", this, "_onMouseScroll");
        } else {
            SimileAjax.DOM.registerEventWithObject(this._div, "mousewheel", this, "_onMouseScroll");
        }
    }    
    
    if (this._label) {
    	SimileAjax.DOM.registerEventWithObject(this._label, "mousemove", this, "_onMouseMove");
    	SimileAjax.DOM.registerEventWithObject(this._label, "mouseover", this, "_onMouseOver");
    }
    
    /*
     *  The inner div that contains layers
     */
    this._innerDiv = this._timeline.getDocument().createElement("div");
    this._innerDiv.className = "timeline-band-inner";
    this._div.appendChild(this._innerDiv);
    
    /*
     *  Initialize parts of the band
     */
    this._ether = bandInfo.ether;
    bandInfo.ether.initialize(this, timeline);
        
    this._etherPainter = bandInfo.etherPainter;
    bandInfo.etherPainter.initialize(this, timeline);
    
    this._eventSource = bandInfo.eventSource;
    if (this._eventSource) {
        this._eventListener = {
            onAddMany: function() { b._onAddMany(); },
            onClear:   function() { b._onClear(); }
        }
        this._eventSource.addListener(this._eventListener);
    }
        
    this._eventPainter = bandInfo.eventPainter;
    this._eventTracksNeeded = 0;   // set by painter via updateEventTrackInfo
    this._eventTrackIncrement = 0; 
    bandInfo.eventPainter.initialize(this, timeline);
    
    this._decorators = ("decorators" in bandInfo) ? bandInfo.decorators : [];
    for (var i = 0; i < this._decorators.length; i++) {
        this._decorators[i].initialize(this, timeline);
    }
};

Timeline._Band.SCROLL_MULTIPLES = 5;

Timeline._Band.prototype.dispose = function() {
    this.closeBubble();
    
    if (this._eventSource) {
        this._eventSource.removeListener(this._eventListener);
        this._eventListener = null;
        this._eventSource = null;
    }
    
    this._timeline = null;
    this._bandInfo = null;
    
    this._labeller = null;
    this._ether = null;
    this._etherPainter = null;
    this._eventPainter = null;
    this._decorators = null;
    
    this._onScrollListeners = null;
    this._syncWithBandHandler = null;
    this._selectorListener = null;
    
    this._div = null;
    this._innerDiv = null;
    this._keyboardInput = null;
};

Timeline._Band.prototype.addOnScrollListener = function(listener) {
    this._onScrollListeners.push(listener);
};

Timeline._Band.prototype.removeOnScrollListener = function(listener) {
    for (var i = 0; i < this._onScrollListeners.length; i++) {
        if (this._onScrollListeners[i] == listener) {
            this._onScrollListeners.splice(i, 1);
            break;
        }
    }
};

Timeline._Band.prototype.setSyncWithBand = function(band, highlight) {
    if (this._syncWithBand) {
        this._syncWithBand.removeOnScrollListener(this._syncWithBandHandler);
    }
    
    this._syncWithBand = band;
    this._syncWithBand.addOnScrollListener(this._syncWithBandHandler);
    this._highlight = highlight;
    this._positionHighlight();
};

Timeline._Band.prototype.getLocale = function() {
    return this._locale;
};

Timeline._Band.prototype.getTimeZone = function() {
    return this._timeZone;
};

Timeline._Band.prototype.getLabeller = function() {
    return this._labeller;
};

Timeline._Band.prototype.getIndex = function() {
    return this._index;
};

Timeline._Band.prototype.getEther = function() {
    return this._ether;
};

Timeline._Band.prototype.getEtherPainter = function() {
    return this._etherPainter;
};

Timeline._Band.prototype.getEventSource = function() {
    return this._eventSource;
};

Timeline._Band.prototype.getEventPainter = function() {
    return this._eventPainter;
};

Timeline._Band.prototype.getTimeline = function() {
    return this._timeline;
};

// Autowidth support
Timeline._Band.prototype.updateEventTrackInfo = function(tracks, increment) {
    this._eventTrackIncrement = increment; // doesn't vary for a specific band

    if (tracks > this._eventTracksNeeded) {
        this._eventTracksNeeded = tracks;
    }
};

// Autowidth support
Timeline._Band.prototype.checkAutoWidth = function() {
    // if a new (larger) width is needed by the band
    // then: a) updates the band's bandInfo.width
    //
    // desiredWidth for the band is 
    //   (number of tracks + margin) * track increment
    if (! this._timeline.autoWidth) {
      return; // early return
    }
    
    var overviewBand = this._eventPainter.getType() == 'overview';
    var margin = overviewBand ? 
       this._theme.event.overviewTrack.autoWidthMargin : 
       this._theme.event.track.autoWidthMargin;
    var desiredWidth = Math.ceil((this._eventTracksNeeded + margin) *
                       this._eventTrackIncrement);
    // add offset amount (additional margin)
    desiredWidth += overviewBand ? this._theme.event.overviewTrack.offset : 
                                   this._theme.event.track.offset;
    var bandInfo = this._bandInfo;
    
    if (desiredWidth != bandInfo.width) {
        bandInfo.width = desiredWidth;
    }
};

Timeline._Band.prototype.layout = function() {
    this.paint();
};

Timeline._Band.prototype.paint = function() {
    this._etherPainter.paint();
    this._paintDecorators();
    this._paintEvents();
};
Timeline._Band.prototype.paint = function() {
if (parseInt(this._bandInfo.width,10) > 0) {
	if (this._label) this._label.style.display= "block";
	this._div.style.display="block";
	// [mrn] asking the browser to compute offsetHeight is expensive, so we'll do it and cache it for later
	this._div._offsetHeight = this._div.offsetHeight;
    this._etherPainter.paint();
    this._paintDecorators();
    this._paintEvents();
} else {
	this._div.style.display="none";
	if (this._label) this._label.style.display= "none";
	}
};
Timeline._Band.prototype.softLayout = function() {
    this.softPaint();
};

Timeline._Band.prototype.softPaint = function() {
    this._etherPainter.softPaint();
    this._softPaintDecorators();
    this._softPaintEvents();
};

Timeline._Band.prototype.setBandShiftAndWidth = function(shift, width) {
    var inputDiv = this._keyboardInput.parentNode;
    var middle = shift + Math.floor(width / 2);
    if (this._timeline.isHorizontal()) {
        this._div.style.top = shift + "px";
        this._div.style.height = width + "px";
        		// [mrn] add band labels
		if (this._label) {
	        this._label.style.top = shift+1 + "px";
    	    this._label.style.height = width-1 + "px";
        }
        inputDiv.style.top = middle + "px";
        inputDiv.style.left = "-1em";
    } else {
        this._div.style.left = shift + "px";
        this._div.style.width = width + "px";
        
        inputDiv.style.left = middle + "px";
        inputDiv.style.top = "-1em";
    }
};

Timeline._Band.prototype.getViewWidth = function() {
    if (this._timeline.isHorizontal()) {
        return this._div.offsetHeight;
    } else {
        return this._div.offsetWidth;
    }
};

Timeline._Band.prototype.setViewLength = function(length) {
    this._viewLength = length;
    this._recenterDiv();
    this._onChanging();
};

Timeline._Band.prototype.getViewLength = function() {
    return this._viewLength;
};

Timeline._Band.prototype.getTotalViewLength = function() {
    return Timeline._Band.SCROLL_MULTIPLES * this._viewLength;
};

Timeline._Band.prototype.getViewOffset = function() {
    return this._viewOffset;
};

Timeline._Band.prototype.getMinDate = function() {
    return this._ether.pixelOffsetToDate(this._viewOffset);
};

Timeline._Band.prototype.getMaxDate = function() {
    return this._ether.pixelOffsetToDate(this._viewOffset + Timeline._Band.SCROLL_MULTIPLES * this._viewLength);
};

Timeline._Band.prototype.getMinVisibleDate = function() {
    return this._ether.pixelOffsetToDate(0);
};

Timeline._Band.prototype.getMinVisibleDateAfterDelta = function(delta) {
    return this._ether.pixelOffsetToDate(delta);
};

Timeline._Band.prototype.getMaxVisibleDate = function() {
    // Max date currently visible on band
    return this._ether.pixelOffsetToDate(this._viewLength);
};

Timeline._Band.prototype.getMaxVisibleDateAfterDelta = function(delta) {
    // Max date visible on band after delta px view change is applied 
    return this._ether.pixelOffsetToDate(this._viewLength + delta);
};

Timeline._Band.prototype.getCenterVisibleDate = function() {
    return this._ether.pixelOffsetToDate(this._viewLength / 2);
};

Timeline._Band.prototype.setMinVisibleDate = function(date) {
    if (!this._changing) {
        this._moveEther(Math.round(-this._ether.dateToPixelOffset(date)));
    }
};

Timeline._Band.prototype.setMaxVisibleDate = function(date) {
    if (!this._changing) {
        this._moveEther(Math.round(this._viewLength - this._ether.dateToPixelOffset(date)));
    }
};

Timeline._Band.prototype.setCenterVisibleDate = function(date) {
    if (!this._changing) {
        this._moveEther(Math.round(this._viewLength / 2 - this._ether.dateToPixelOffset(date)));
    }
};

Timeline._Band.prototype.dateToPixelOffset = function(date) {
    return this._ether.dateToPixelOffset(date) - this._viewOffset;
};

Timeline._Band.prototype.pixelOffsetToDate = function(pixels) {
    return this._ether.pixelOffsetToDate(pixels + this._viewOffset);
};

Timeline._Band.prototype.createLayerDiv = function(zIndex, className) {
    var div = this._timeline.getDocument().createElement("div");
    div.className = "timeline-band-layer" + (typeof className == "string" ? (" " + className) : "");
    div.style.zIndex = zIndex;
    this._innerDiv.appendChild(div);
    
    var innerDiv = this._timeline.getDocument().createElement("div");
    innerDiv.className = "timeline-band-layer-inner";
    if (SimileAjax.Platform.browser.isIE) {
        innerDiv.style.cursor = "move";
    } else {
        innerDiv.style.cursor = "-moz-grab";
    }
    div.appendChild(innerDiv);
    
    return innerDiv;
};

Timeline._Band.prototype.removeLayerDiv = function(div) {
    this._innerDiv.removeChild(div.parentNode);
};

Timeline._Band.prototype.scrollToCenter = function(date, f) {
    var pixelOffset = this._ether.dateToPixelOffset(date);
    if (pixelOffset < -this._viewLength / 2) {
        this.setCenterVisibleDate(this.pixelOffsetToDate(pixelOffset + this._viewLength));
    } else if (pixelOffset > 3 * this._viewLength / 2) {
        this.setCenterVisibleDate(this.pixelOffsetToDate(pixelOffset - this._viewLength));
    }
    this._autoScroll(Math.round(this._viewLength / 2 - this._ether.dateToPixelOffset(date)), f);
};

Timeline._Band.prototype.showBubbleForEvent = function(eventID) {
    var evt = this.getEventSource().getEvent(eventID);
    if (evt) {
        var self = this;
        this.scrollToCenter(evt.getStart(), function() {
            self._eventPainter.showBubble(evt);
        });
    }
};

Timeline._Band.prototype.zoom = function(zoomIn, x, y, target) {
  if (!this._zoomSteps) {
    // zoom disabled
    return;
  }
  
  // shift the x value by our offset
  x += this._viewOffset;

  var zoomDate = this._ether.pixelOffsetToDate(x);
  var netIntervalChange = this._ether.zoom(zoomIn);
  this._etherPainter.zoom(netIntervalChange);

  // shift our zoom date to the far left
  this._moveEther(Math.round(-this._ether.dateToPixelOffset(zoomDate)));
  // then shift it back to where the mouse was
  this._moveEther(x);
};

Timeline._Band.prototype._onMouseDown = function(innerFrame, evt, target) {
    this.closeBubble();
    
    this._timeline._dragging = true;
    this._dragging = true;
    this._dragX = evt.clientX;
    this._dragY = evt.clientY;
};
Timeline._Band.prototype._onMouseOver = function(innerFrame, evt, target) {
		var coords =  SimileAjax.DOM.getEventPageCoordinates(evt);
		this._dragX = coords.x;
		this._dragY = coords.y;
		this._mouseover = true;
  //    this._keyboardInput.focus();
};
Timeline._Band.prototype._onMouseMove = function(innerFrame, evt, target) {
    if (this._timeline._dragging) {
    	var coords =  SimileAjax.DOM.getEventPageCoordinates(evt);
		x= coords.x;
		y = coords.y;
		// Stupid IE fires onmousemove BEFORE onmouseover or onmouseenter
		if (!this._mouseover) {
			var mcoords =  SimileAjax.DOM.getEventPageCoordinates(evt);
			this._dragX = mcoords.x;
			this._dragY = mcoords.y;
			this._mouseover = true;
		}
		var diffX = x - this._dragX;
        var diffY = y - this._dragY;
        this._dragX = x;
        this._dragY = y;

        this._moveEther(this._timeline.isHorizontal() ? diffX : diffY);
        this._positionHighlight();
    }
};

Timeline._Band.prototype._onMouseUp = function(innerFrame, evt, target) {
    this._timeline._dragging = false;
    this._dragging = false;
//    this._keyboardInput.focus();
};

Timeline._Band.prototype._onMouseOut = function(innerFrame, evt, target) {
    var coords = SimileAjax.DOM.getEventRelativeCoordinates(evt, innerFrame);
    coords.x += this._viewOffset;
    if (coords.x < 0 || coords.x > innerFrame.offsetWidth)
    /* turn this check off...allow the mouse to drift off vertically and resume dragging when re-enter the band
     * || coords.y < 0 || coords.y > innerFrame.offsetHeight)
     */
     {
     /* if we comment out this line, then IE will continue to drag the mouse when the user accidentally
      * moves over a bar while dragging and back onto the band. If this line executes, then IE stops the drag
      * when the user moves over a bar and back over the band. This is the default behavior
      */
      this._timeline._dragging = false;
      this._dragging = false;
    }
    this._dragX = 0;
    this._dragY = 0;

    this._mouseover = false;
};

Timeline._Band.prototype._onMouseScroll = function(innerFrame, evt, target) {
  var now = new Date();
  now = now.getTime();

  if (!this._lastScrollTime || ((now - this._lastScrollTime) > 50)) {
    // limit 1 scroll per 200ms due to FF3 sending multiple events back to back
    this._lastScrollTime = now;

    var delta = 0;
    if (evt.wheelDelta) {
      delta = evt.wheelDelta/120;
    } else if (evt.detail) {
      delta = -evt.detail/3;
    }
    
    // either scroll or zoom
    var mouseWheel = this._theme.mouseWheel;
    
    if (this._zoomSteps || mouseWheel === 'zoom') {
      var loc = SimileAjax.DOM.getEventRelativeCoordinates(evt, innerFrame);
      if (delta != 0) {
        var zoomIn;
        if (delta > 0)
          zoomIn = true;
        if (delta < 0)
          zoomIn = false;
        // call zoom on the timeline so we could zoom multiple bands if desired
        this._timeline.zoom(zoomIn, loc.x, loc.y, innerFrame);
      }
    }
    else if (mouseWheel === 'scroll') {
    	var move_amt = 50 * (delta < 0 ? -1 : 1);
      this._moveEther(move_amt);
    }
  }

  // prevent bubble
  if (evt.stopPropagation) {
    evt.stopPropagation();
  }
  evt.cancelBubble = true;

  // prevent the default action
  if (evt.preventDefault) {
    evt.preventDefault();
  }
  evt.returnValue = false;
};

// added by Kartik touch fixes
Timeline._Band.prototype._onTouchStart=function(D,A,E)
{
    if(A.touches.length == 1)
    {
		var touch = A.changedTouches[0];
		this._dragX=touch.clientX;
		this._dragY=touch.clientY;
    }
}


Timeline._Band.prototype._onTouchMove=function(D,A,E)
{
    if(A.touches.length == 1)
    {
		A.preventDefault();
        var touch = A.changedTouches[0];
		var C=touch.clientX-this._dragX;
        var B=touch.clientY-this._dragY;
        this._dragX=touch.clientX;
        this._dragY=touch.clientY;
        this._moveEther(this._timeline.isHorizontal()?C:B);
		this._positionHighlight();
		this._fireOnScroll();
		this._setSyncWithBandDate();
	} 
};

Timeline._Band.prototype._onDblClick = function(innerFrame, evt, target) {
    var coords = SimileAjax.DOM.getEventRelativeCoordinates(evt, innerFrame);
    var distance = coords.x - (this._viewLength / 2 - this._viewOffset);
    
    this._autoScroll(-distance);
};

Timeline._Band.prototype._onKeyDown = function(keyboardInput, evt, target) {
    if (!this._dragging) {
        switch (evt.keyCode) {
        case 27: // ESC
            break;
        case 37: // left arrow
        case 38: // up arrow
            this._scrollSpeed = Math.min(50, Math.abs(this._scrollSpeed * 1.05));
            this._moveEther(this._scrollSpeed);
            break;
        case 39: // right arrow
        case 40: // down arrow
            this._scrollSpeed = -Math.min(50, Math.abs(this._scrollSpeed * 1.05));
            this._moveEther(this._scrollSpeed);
            break;
        default:
            return true;
        }
        this.closeBubble();
        
        SimileAjax.DOM.cancelEvent(evt);
        return false;
    }
    return true;
};

Timeline._Band.prototype._onKeyUp = function(keyboardInput, evt, target) {
    if (!this._dragging) {
        this._scrollSpeed = this._originalScrollSpeed;
        
        switch (evt.keyCode) {
        case 35: // end
            this.setCenterVisibleDate(this._eventSource.getLatestDate());
            break;
        case 36: // home
            this.setCenterVisibleDate(this._eventSource.getEarliestDate());
            break;
        case 33: // page up
            this._autoScroll(this._timeline.getPixelLength());
            break;
        case 34: // page down
            this._autoScroll(-this._timeline.getPixelLength());
            break;
        default:
            return true;
        }
        
        this.closeBubble();
        
        SimileAjax.DOM.cancelEvent(evt);
        return false;
    }
    return true;
};

Timeline._Band.prototype._autoScroll = function(distance, f) {
    var b = this;
    var a = SimileAjax.Graphics.createAnimation(
        function(abs, diff) {
            b._moveEther(diff);
        }, 
        0, 
        distance, 
        1000, 
        f
    );
    a.run();
};

Timeline._Band.prototype._moveEther = function(shift) {
    this.closeBubble();
    
    // A positive shift means back in time
    // Check that we're not moving beyond Timeline's limits
    if (!this._timeline.shiftOK(this._index, shift)) {
        return; // early return
    }

    this._viewOffset += shift;
    this._ether.shiftPixels(-shift);
    if (this._timeline.isHorizontal()) {
        this._div.style.left = this._viewOffset + "px";
    } else {
        this._div.style.top = this._viewOffset + "px";
    }
    
    if (this._viewOffset > -this._viewLength * 0.5 ||
        this._viewOffset < -this._viewLength * (Timeline._Band.SCROLL_MULTIPLES - 1.5)) {
        
        this._recenterDiv();
    } else {
        this.softLayout();
    }    
    
    this._onChanging();
}

Timeline._Band.prototype._onChanging = function() {
    this._changing = true;

    this._fireOnScroll();
    this._setSyncWithBandDate();
    
    this._changing = false;
};

Timeline._Band.prototype.busy = function() {
    // Is this band busy changing other bands?
    return(this._changing);
};

Timeline._Band.prototype._fireOnScroll = function() {
    for (var i = 0; i < this._onScrollListeners.length; i++) {
        this._onScrollListeners[i](this);
    }
};

Timeline._Band.prototype._setSyncWithBandDate = function() {
    if (this._syncWithBand) {
        var centerDate = this._ether.pixelOffsetToDate(this.getViewLength() / 2);
        this._syncWithBand.setCenterVisibleDate(centerDate);
    }
};

Timeline._Band.prototype._onHighlightBandScroll = function() {
    if (this._syncWithBand) {
        var centerDate = this._syncWithBand.getCenterVisibleDate();
        var centerPixelOffset = this._ether.dateToPixelOffset(centerDate);
        
        this._moveEther(Math.round(this._viewLength / 2 - centerPixelOffset));
        
        if (this._highlight) {
            this._etherPainter.setHighlight(
                this._syncWithBand.getMinVisibleDate(), 
                this._syncWithBand.getMaxVisibleDate());
        }
    }
};

Timeline._Band.prototype._onAddMany = function() {
    this._paintEvents();
};

Timeline._Band.prototype._onClear = function() {
    this._paintEvents();
};

Timeline._Band.prototype._positionHighlight = function() {
    if (this._syncWithBand) {
        var startDate = this._syncWithBand.getMinVisibleDate();
        var endDate = this._syncWithBand.getMaxVisibleDate();
        
        if (this._highlight) {
            this._etherPainter.setHighlight(startDate, endDate);
        }
    }
};

Timeline._Band.prototype._recenterDiv = function() {
    this._viewOffset = -this._viewLength * (Timeline._Band.SCROLL_MULTIPLES - 1) / 2;
    if (this._timeline.isHorizontal()) {
        this._div.style.left = this._viewOffset + "px";
        this._div.style.width = (Timeline._Band.SCROLL_MULTIPLES * this._viewLength) + "px";
    } else {
        this._div.style.top = this._viewOffset + "px";
        this._div.style.height = (Timeline._Band.SCROLL_MULTIPLES * this._viewLength) + "px";
    }
    this.layout();
};

Timeline._Band.prototype._paintEvents = function() {
    this._eventPainter.paint();
};

Timeline._Band.prototype._softPaintEvents = function() {
    this._eventPainter.softPaint();
};

Timeline._Band.prototype._paintDecorators = function() {
    for (var i = 0; i < this._decorators.length; i++) {
        this._decorators[i].paint();
    }
};

Timeline._Band.prototype._softPaintDecorators = function() {
    for (var i = 0; i < this._decorators.length; i++) {
        this._decorators[i].softPaint();
    }
};

Timeline._Band.prototype.closeBubble = function() {
    SimileAjax.WindowManager.cancelPopups();
};
