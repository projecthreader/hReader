rootContext = 'http://127.0.0.1:3000'
patientId = 2

@PopHealth = {
  constructor: (@measures) ->
    @measures ||= {}

  getAvailableMeasures: ->
    $.ajax(
      type: "GET",
      url: "#{rootContext}/measures/available",
      isModified: false,
      dataType: "jsonp",
      #timeout: 5000,
      success: (measures) ->
        PopHealth.pollMeasures(measures)
      error: (jqXHR, textStatus, errorThrown) ->
        PopHealth.showUnreachable()
    )

  pollMeasures: (measures) ->
    for measure in measures
      PopHealth.pollMeasure(measure)

  pollMeasure: (measure, uuid) ->
    # id, sub_id, category, name, description, ipp, denom, numer, denomexcep, 
    url = "#{rootContext}/measures/patient_result/#{patientId}/#{measure['id']}/"
    url += "#{measure['sub_id']}" if measure["sub_id"]?
    url += "?uuid=#{uuid}" if uuid

    $.ajax(
      type: "GET",
      url: url,
      dataType: "jsonp",
      #timeout: 5000,
      success: (data) ->
        if data['completed'] then PopHealth.updateMeasure(data) else PopHealth.pollMeasure(measure, data["uuid"])
      error: (data) ->
        PopHealth.showError(data)
    )

  updateMeasure: (measure) ->
    

  showError: (measure) ->
    alert("There was an error retrieving measure")

  showResult: (measure) ->
    title = $(measure).innerHTML
    $("#more-info").hide()
    $("#more-info").slideDown()

  showUnreachable: (data) ->
    # Show that we cannot connect to the quality measure service
    alert("Service is unreachable")

  filterResults: (criteria) ->
    results = $(".category ul li." + criteria)
    results.slideToggle()
    results.toggleClass('result-filter')

  filterCategory: (categoryHeader) ->
    measures = $(categoryHeader).parent(".category").find("li")
    measures.slideToggle()
    measures.toggleClass('category-filter')
}

$(document).ready ->
  $(".category ul li").on "mouseup", (event) ->
    PopHealth.showResult(event.target)
  $(".category h3").on "mouseup", (event) ->
    PopHealth.filterCategory(event.target)
  $(".pophealth-result-container").on "mouseup", (event) ->
    PopHealth.filterResults(event.target.getAttribute("data-filter-criteria"))

  PopHealth.getAvailableMeasures()