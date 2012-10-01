$(function () {


    // Slider
    $('.slider').slider({
        range: true,
        values: [17, 67] });

    $('.sparkline').sparkline('html', {type: 'line',
        lineColor: '#000000',
        fillColor: false,
        lineWidth: 2,
        spotColor: '#000000',
        minSpotColor: '#D60D25',
        maxSpotColor: '#D60D25',
        highlightSpotColor: '#56C4C4',
        highlightLineColor: '#D60D25',
        spotRadius: 4,
        normalRangeColor: '#E0E0DF',
        drawNormalOnTop: false,
        normalRangeMin: 10,
        width: 460,
        normalRangeMax:140} );

    $('.sparkbar').sparkline('html', {type: 'bar', 
        barColor: '#048A82',
        width: 460,
        barWidth: 20} );

});


  var movies = [
  { Name: "The Red Violin", ReleaseYear: "1998", Director: "François Girard" },
  { Name: "Eyes Wide Shut", ReleaseYear: "1999", Director: "Stanley Kubrick" },
  { Name: "The Inheritance", ReleaseYear: "1976", Director: "Mauro Bolognini" }
  ];

var markup = "<tr><td colspan='2'>${Name}</td><td>Released: ${ReleaseYear}</td><td>Director: ${Director}</td></tr>"

/* Compile markup string as a named template */
$.template( "movieTemplate", markup );

/* Render the named template */
$( "#showBtn" ).click( function() {
  $( "#movieList" ).empty();
  $.tmpl( "movieTemplate", movies ).appendTo( "#movieList" );
});
