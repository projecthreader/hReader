$.PopHealth ||= {}

class $.PopHealth
  constructor: (@args) ->

  showResult: (measure) ->
    title = $(measure).innerHTML
    $("#more-info").hide()
    $("#more-info").slideDown()

  filterResults: (criteria) ->
    results = $(".category ul li." + criteria)
    results.slideToggle()
    results.toggleClass('result-filter')

  filterCategory: (categoryHeader) ->
    measures = $(categoryHeader).parent(".category").find("li")
    measures.slideToggle()
    measures.toggleClass('category-filter')

popHealth = new $.PopHealth

$(document).ready ->
  $(".category ul li").on "mouseup", (event) ->
    popHealth.showResult(event.target)
  $(".category h3").on "mouseup", (event) ->
    popHealth.filterCategory(event.target)
  $(".pophealth-result-container").on "mouseup", (event) ->
    popHealth.filterResults(event.target.getAttribute("data-filter-criteria"))

  # $.ajax(
  #   type: "GET",
  #   url: 'http://127.0.0.1:3000/measures/results/1.json',
  #   isModified: false,
  #   dataType: "jsonp",
  #   data: 
  #     id: 1
  #   success: (data) ->
      
  #   error: (data) ->
      
  # )