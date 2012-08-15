

/* Some wicked optimization to address a performance issue in Firefox. */
SimileAjax.Graphics._FontRenderingContext.prototype.computeSize = function(text, className) {
    // className arg is optional
    var el = this._elmt;
    el.innerHTML = text;
    return {width:text.length * 7,height : 15};
};
SimileAjax.Graphics.getWidthHeight = function(el) {
    // RETURNS hash {width:  w, height: h} in pixels

    	return {width:el.innerHTML.length * 7,height:15};

};

Timeline._Band.prototype._moveEther = function(shift) {
  //  this.closeBubble();
    
    // A positive shift means back in time
    // Check that we're not moving beyond Timeline's limits
   // if (!this._timeline.shiftOK(this._index, shift)) {
    //    return; // early return
   // }

    this._viewOffset += shift;
    this._ether.shiftPixels(-shift);
    //if (this._timeline.isHorizontal()) {
        this._div.style.left = this._viewOffset + "px";
    //} else {
    //    this._div.style.top = this._viewOffset + "px";
   // }
    
    if (this._viewOffset > -this._halfViewLength ||
        this._viewOffset < -this._viewLength * (Timeline._Band.SCROLL_MULTIPLES - 1.5)) {
        
        this._recenterDiv();
    } else {
            this._etherPainter.softPaint();
    this._softPaintDecorators();
    this._softPaintEvents();
    }    
    
    this._onChanging();
}

Timeline._Band.prototype._fireOnScroll = function() {
    for (var i = 0,l = this._onScrollListeners.length; i<l;i++) {
        this._onScrollListeners[i](this);
    }
};


Timeline._Band.prototype._onHighlightBandScroll = function() {
        var centerDate = this._syncWithBand.getCenterVisibleDate();
        var centerPixelOffset = this._ether.dateToPixelOffset(centerDate);
        this._moveEther(Math.round(this._halfViewLength - centerPixelOffset));
}; 
Timeline._Band.prototype._softPaintDecorators = function() {};
/* Override the Marker Layout function to take advantage of the style of Timeline we are using */
