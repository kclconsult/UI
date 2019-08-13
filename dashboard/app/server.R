# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#

library(Consult) # install in local directory packages/Consult

library(jsonlite)
library(shiny)

# local modules
source("components.R")
source("services.R")
source("data.R")

# server function with input and output objects.
# input - references to events and input from the client
# output - references to output objects to update in client
function(input, output) {
    
    #
    # Load Datasets and generate statistics
    #
    # - Blood Pressure (default time period)
    datasetBP = loadBloodPressureData(startTimestamp = "2016-02-26T00:00:00Z",
                                      endTimestamp = "2020-02-28T00:00:00Z")
    
    #
    # datasetBP = loadBloodPressureData(startTimestamp = "2017-01-01T00:00:00Z",
    #                                  endTimestamp  =  "2017-02-01T00:00:00Z")
    
    # - Heart Rate
    datasetHR = loadHeartRateData(startTimestamp = "2016-02-26T00:00:00Z", 
                                  endTimestamp = "2020-02-28T00:00:00Z")

    # - ECG
    datasetECG = loadECGData(startTimestamp = "2016-02-26T00:00:00Z", 
                             endTimestamp = "2020-02-28T00:00:00Z")
    
    # - Mood
    # datasetMood = loadMoodData(startTimestamp = "2016-02-26T00:00:00Z", 
    #                           endTimestamp = "2020-02-28T00:00:00Z")
    
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
    # Tab: Summary Boxes
    #
    
    # - Blood Pressure Summary
    output$summaryBP = renderSummaryBox({
      # Summarise the BP dataset
      summary = summariseBP(datasetBP)
      
      # Override alert color from the debug control
      if(input$debugSelectBPAlertColor != "") {
        print(paste("DEBUG BP Alert: ", input$debugSelectBPAlertColor))
        summary$alert = input$debugSelectBPAlertColor
      }
      
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Blood Pressure",
                 image = "images/summary/bloodpressure.png",
                 alert = summary$alert,
                 status = summary$status,
                 timestamp = summary$timestamp,
                 source = "Home")
    })

    # - Heart Rate Summary
    output$summaryHR = renderSummaryBox({
      # Summarise the HR dataset
      summary = summariseHR(datasetHR)
      
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Heart Rate",
                 image = "images/summary/heartrate.png",
                 alert = "blue",
                 status = summary$status,
                 timestamp = summary$timestamp,
                 source = "Home")
    })
    
    # - ECG Summary
    output$summaryECG = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "ECG",
                 image = "images/summary/ecg.png",
                 alert = "blue",
                 status = "Normal",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Clinic")
    })
    
    # - Mood Summary
    output$summaryMood = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Mood",
                 image = input$debugSelectMoodImage,
                 # Mood options:
                 # image = "images/summary/mood-good.png",
                 # image = "images/summary/mood-meh.png",
                 # image = "images/summary/mood-bad.png",
                 alert = "blue",
                 status = "",
                 timestamp = "2019-7-31 12:34:56",
                 source = "Home")
    })
    
    #
    # Tab: Heart Rate (HR)
    #

    # Select different time-range events
    observeEvent(input$selectLastFourHours, {
      print("Summary: Last Four Hours")
    })
    
    observeEvent(input$selectLastDay, {
      print("Summary: Last 24 Hours")
    })
    
    observeEvent(input$selectLastMonth, {
      print("Summary: Last Month")
    })
    
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
    output$interventionRiskPlot = renderImage({
      print(paste("interventionRiskPlot =",  input$selectIntervention))
      # image path is from the selection drop-down
      list(src = normalizePath(paste0("./www/", input$selectIntervention)))
    }, deleteFile = FALSE)
  
    #
    # Tab: Recommendations
    #
    
    output$listRecommendations = renderRecommendations({
      # List of Recommendations are based on a Array of objects representation from JSON:
      recommendationsJSON <- 
      '[
        {
         "icon":"recommendation", 
         "heading": "Consider changing your painkiller; there are two options:",
         "body": [
            "Given your medical history and that paracetamol helps with back pain then paracetamol is recommended. It is recommended that you consider paracetamol.",
            "Given your medical history and that codeine helps with back pain then codeine is recommended."
          ]
        },{
          "icon":"recommendation", 
         "heading": "Another recommendation.",
         "body": [
            "Some more details about the recommendation.  It is recommended that you follow this recommendation."
          ]
        }]'
      
      # Converted to object
      fromJSON(recommendationsJSON)
    })
    
    #
    # Tab: Mood
    #
    observeEvent(input$emotionLinkTired,      { sendMoodObservation("tired") })
    observeEvent(input$emotionLinkTense,      { sendMoodObservation("tense") })
    observeEvent(input$emotionLinkSleepy,     { sendMoodObservation("sleepy") })
    observeEvent(input$emotionLinkSerene,     { sendMoodObservation("serene") })
    observeEvent(input$emotionLinkSatisfied,  { sendMoodObservation("satisfied") })
    observeEvent(input$emotionLinkSad,        { sendMoodObservation("sad") })
    observeEvent(input$emotionLinkMiserable,  { sendMoodObservation("miserable") })
    observeEvent(input$emotionLinkHappy,      { sendMoodObservation("happy") })
    observeEvent(input$emotionLinkGloomy,     { sendMoodObservation("gloomy") })
    observeEvent(input$emotionLinkGlad,       { sendMoodObservation("glad") })
    observeEvent(input$emotionLinkFrustrated, { sendMoodObservation("frustrated") })
    observeEvent(input$emotionLinkExcited,    { sendMoodObservation("excited") })
    observeEvent(input$emotionLinkDelighted,  { sendMoodObservation("delighted") })
    observeEvent(input$emotionLinkCalm,       { sendMoodObservation("calm") })
    observeEvent(input$emotionLinkAngry,      { sendMoodObservation("angry") })
    observeEvent(input$emotionLinkAfraid,     { sendMoodObservation("afraid") })
    
    #
    # Tab: Feedback
    #
    output$logFeedback = renderFeedback()
 
}












