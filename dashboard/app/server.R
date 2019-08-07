# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#

library(Consult) # install in local directory packages/Consult
library(shiny)

# local modules
source("components.R")
source("services.R")

# server function with input and output objects.
# input - references to events and input from the client
# output - references to output objects to update in client
function(input, output) {
    
    #
    # Load Datasets and generate statistics
    #
    # - Blood Pressure (default time period)
    datasetBP = loadBloodPressureData(startTimestamp = "2016-02-26T00:00:00Z", endTimestamp = "2020-02-28T00:00:00Z")
    
    # - Heart Rate
    datasetHR = loadHeartRateData(startTimestamp = "2016-02-26T00:00:00Z", endTimestamp = "2020-02-28T00:00:00Z")

    # - ECG
    datasetECG = loadECGData(startTimestamp = "2016-02-26T00:00:00Z", endTimestamp = "2020-02-28T00:00:00Z")
    
    
    #
    # Navbar Tab Changing Events for logging
    # 
    observeEvent(input$tabSummaryLink, {
      print("Summary Tab Selected")
    })
    
    observeEvent(input$tabHRLink, {
      print("HR Tab Selected")
    })
    
    observeEvent(input$tabBPLink, {
      print("BP Tab Selected")
    })
    
    observeEvent(input$tabECGLink, {
      print("ECG Tab Selected")
    })
    
    observeEvent(input$tabRiskLink, {
      print("Risk Tab Selected")
    })
   
    observeEvent(input$tabRecommendationsLink, {
      print("Recommendations Tab Selected")
    })
    
    observeEvent(input$tabMoodLink, {
      print("Mood Tab Selected")
    })

    observeEvent(input$tabFeedbackLink, {
      print("Feedback Tab Selected")
    })
    
    #
    # Tab: Summary
    #
    # Select different time-range events
    #   (TODO change from actionButtons to tabbed selector)
    observeEvent(input$selectLastFourHours, {
        print("Summary: Last Four Hours")
    })
    
    observeEvent(input$selectLastDay, {
        print("Summary: Last 24 Hours")
    })
    
    observeEvent(input$selectLastMonth, {
        print("Summary: Last Month")
    })

    # Summary Boxes (TODO - make reactive to selectors)
    # - Blood Pressure Summary
    output$summaryBP = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Blood Pressure",
                 alert = "green",
                 status = "135/85 mmHG",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Home")
    })

    # - Heart Rate Summary
    output$summaryHR = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Heart Rate",
                 alert = "green",
                 status = "135 bpm",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Home")
    })
    
    # - ECG Summary
    output$summaryECG = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "ECG",
                 alert = "green",
                 status = "Normal",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Clinic")
    })
    
    # - Mood Summary
    output$summaryMood = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Mood",
                 alert = "orange",
                 status = "",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Home")
    })
    
    # - Pain Summary
    output$summaryPain = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Pain",
                 alert = "red",
                 status = "",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Home")
    })

    #
    # Tab: Heart Rate (HR)
    #
    output$plotHR = renderHRTimeline({
        # from packages/Consult/HRTimeline
        HRTimeline(dataset = datasetHR)
    })
    
    #
    # Tab: Blood Pressure (BP)
    #
    output$plotBP = renderBPTimeline({
        # from packages/Consult/BPTimeline
        BPTimeline(dataset = datasetBP)
    })

    #
    # Tab: ECG
    #
    output$plotECG = renderECGTimeline({
        # from packages/Consult/ECGTimeline
        # NOTE: limiting to last 1000 data-points b/c of the high-resolution
        ECGTimeline(dataset = tail(datasetECG, 1000))
    })

    #
    # Tab: Risk
    #
    output$plotRisk = renderRisk() # TBD - htmlwidget
  
    #
    # Tab: Recommendations
    #
    output$listRecommendations = renderRecommendations()
  
    #
    # Tab: Mood
    #
    observeEvent(input$emotionLinkTired, {
      print("Mood: tired")
      sendMoodObservation("tired")
    })
    
    #
    # Tab: Feedback
    #
    output$logFeedback = renderFeedback()
 
}












