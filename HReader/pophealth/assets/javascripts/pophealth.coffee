$.PopHealth ||= {}

class $.PopHealth
  constructor: (@args) ->

  showResult: (measure) ->
    title = $(measure).innerHTML
    $("#more-info").removeClass("pass fail hidden")

  filterResults: (criteria) ->
    $(".category ul li." + criteria).slideToggle()

popHealth = new $.PopHealth

$(document).ready ->
  $(".category ul li").on "mouseup", (event) ->
    popHealth.showResult(event.target)
  $(".pophealth-result-container").on "mouseup", (event) ->
    popHealth.filterResults(event.target.getAttribute("data-filter-criteria"))

  $.ajax(
    url: 'http://localhost:3000/measures/results/1',
    success: (data) ->
      alert('success!')
    error: (data) ->
      alert('broken!')
  )