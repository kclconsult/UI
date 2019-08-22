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

# local modules - move into Consult package
source("version.R")
source("components.R")
source("services.R")
source("data.R")

# server function with input and output objects.
# input - references to events and input from the client
# output - references to output objects to update in client
# session - live session object for updating input controls
function(input, output, session) {
    # Render the Version String
    output$versionString = renderText(paste("v", DASHBOARD_VERSION, sep=""))
  
    SAMPLE_DATA = FALSE
    
    #
    # Load Datasets and generate statistics
    #
    # - Blood Pressure
    #
    # Simulation BP only available:
    # start: 2017-01-01 00:00:00
    # end:   2017-06-19 00:00:00
    datasetBP = loadBloodPressureData(startTimestamp = "2016-12-31T00:00:00Z",
                                      endTimestamp   = "2017-02-01T00:00:00Z", 
                                      sample = SAMPLE_DATA)
    # - Heart Rate
    #
    # Simulation HR available:
    # start: 2019-04-04 23:19:39
    # end: 2019-04-09 13:56:13
    datasetHR = loadHeartRateData(startTimestamp = "2019-04-03T00:00:00Z", 
                                  endTimestamp   = "2020-04-10T00:00:00Z", 
                                  sample = SAMPLE_DATA)
    # - ECG
    # 
    # Only one date entry: 2019-08-06 17:27:25
    #
    datasetECG = loadECGData(startTimestamp = "2019-08-06T00:00:00Z", 
                             endTimestamp   = "2019-08-07T00:00:00Z", 
                             sample = TRUE) # Note: until smaller resolution data, sample for now
    # - Mood
    #
    # Live Moods
    #
    datasetMood = loadMoodData(startTimestamp = "2016-02-26T00:00:00Z", 
                               endTimestamp   = "2020-02-28T00:00:00Z", 
                               sample = SAMPLE_DATA)

    # - Feedback (Clinical Impression)
    #
    # Should be all Clinical Impressions
    #
    datasetFeedback = loadClinicalImpressionData(startTimestamp="2019-08-13T16:26:26Z", 
                                                 endTimestamp="2020-02-28T00:00:00Z",
                                                 sample = SAMPLE_DATA)
    
    #
    # Navbar Tab Changing Events for logging
    # 
    observeEvent(input$tabSummaryLink,         { logEvent("TabChanged", "Summary Tab Selected") })
    observeEvent(input$tabHRLink,              { logEvent("TabChanged", "HR Tab Selected") })
    observeEvent(input$tabBPLink,              { logEvent("TabChanged", "BP Tab Selected") })
    observeEvent(input$tabECGLink,             { logEvent("TabChanged", "ECG Tab Selected") })
    observeEvent(input$tabRiskLink,            { logEvent("TabChanged", "Risk Tab Selected") })
    observeEvent(input$tabRecommendationsLink, { logEvent("TabChanged", "Recommendations Tab Selected") })
    observeEvent(input$tabMoodLink,            { logEvent("TabChanged", "Mood Tab Selected") })
    observeEvent(input$tabFeedbackLink,        { logEvent("TabChanged", "Feedback Tab Selected") })
    
    #
    # Tab: Summary Boxes
    #
    
    # - Blood Pressure Summary
    output$summaryBP = renderSummaryBox({
      # Summarise the BP dataset
      summary = summariseBloodPressure(datasetBP)
      
      # Override alert color from the debug control
      if(input$debugSelectBPAlertColor != "") {
        print(paste("DEBUG BP Alert: ", input$debugSelectBPAlertColor))
        summary$alert = input$debugSelectBPAlertColor
      }
      # Override alert text
      if(input$debugSelectBPAlertText != "") {
        print(paste("DEBUG BP Alert Text: ", input$debugSelectBPAlertText))
        summary$alert_text = input$debugSelectBPAlertText
      }
      
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Blood Pressure",
                 image = "images/summary/bloodpressure.png",
                 alert = summary$alert,
                 alert_text = summary$alert_text,
                 status = summary$status,
                 timestamp = summary$timestamp,
                 source = "Home")
    })
    
    observeEvent(input$summaryBP, {
      logEvent("SummaryBoxClicked", "Blood Pressure")
      # change Tab
      runjs("$('#tabBPLink').tab('show');")
    })
    
    # - Heart Rate Summary
    output$summaryHR = renderSummaryBox({
      # Summarise the HR dataset
      summary = summariseHeartRate(datasetHR)
      
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Heart Rate",
                 image = "images/summary/heartrate.png",
                 alert = "blue",
                 status = summary$status,
                 timestamp = summary$timestamp,
                 source = "Home")
    })
    
    observeEvent(input$summaryHR, {
      logEvent("SummaryBoxClicked", "Heart Rate")
      # change Tab
      runjs("$('#tabHRLink').tab('show');")
    })
    
    # - ECG Summary
    output$summaryECG = renderSummaryBox({
      # Summarise the ECG dataset
      summary = summariseECG(datasetECG)
      
      #from packages/Consult/SummaryBox
      SummaryBox(title = "ECG",
                 image = "images/summary/ecg.png",
                 alert = "blue",
                 status = summary$status,
                 timestamp = summary$timestamp,
                 source = "Clinic")
    })

    observeEvent(input$summaryECG, {
      logEvent("SummaryBoxClicked", "ECG")
      # change Tab
      runjs("$('#tabECGLink').tab('show');")
    })
    
    # - Mood Summary
    output$summaryMood = renderSummaryBox({
      # Summarise the Mood dataset
      summary = summariseMood(datasetMood)
      
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Mood",
                 image = input$debugSelectMoodImage,
                 # Mood options:
                 # image = "images/summary/mood-good.png",
                 # image = "images/summary/mood-meh.png",
                 # image = "images/summary/mood-bad.png",
                 alert = "blue",
                 status = summary$status,
                 timestamp = summary$timestamp,
                 source = "Home")
    })
    
    observeEvent(input$summaryMood, {
      logEvent("SummaryBoxClicked", "Mood")
      # change Tab
      runjs("$('#tabMoodLink').tab('show');")
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
         "icon":"blood-pressure", 
         "heading": "Another recommendation.",
         "body": [
            "Some more details about the recommendation.  It is recommended that you follow this recommendation."
          ]
        },{
         "icon":"mood", 
         "heading": "Another recommendation.",
         "body": [
            "Some more details about the recommendation.  It is recommended that you follow this recommendation."
          ]
        },{
         "icon":"summary", 
         "heading": "Another recommendation.",
         "body": [
            "Some more details about the recommendation.  It is recommended that you follow this recommendation."
          ]
        }]'
      
      # Converted to named-list object from JSON
      fromJSON(recommendationsJSON)
    })
    
    #
    # Tab: Mood
    #
    
    # -- Mood Grid Events
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
    
    # -- PHQ2 Screening Form
    observe({ # Enable Submit button only when both questions are answered
      toggleState(id = "phq2SubmitButton", 
                  condition = is.character(input$phq2Q1YesNo) & is.character(input$phq2Q2YesNo))
    })
    
    # Submit PHQ2 Form
    observeEvent(input$phq2SubmitButton, { 
      logEvent("PHQ2", paste("Submitted Form Q1:", input$phq2Q1YesNo, "Q2:", input$phq2Q2YesNo))
      
      # show PHQ9 form if both Qestion Answers are Yes
      if(input$phq2Q1YesNo == "y" & input$phq2Q2YesNo == "y") { 
        # Shows PHQ9 Tab
        runjs("$('#mood-tabs a[href=\"#phq9\"]').tab('show');")
      } else { 
        # Shows (default) Mood Grid
        runjs("$('#mood-tabs a[href=\"#mood-grid\"]').tab('show');")
      }
      
      # Clear PHQ2 Inputs
      #
      # These *should* clear the radioButtons for the questions, but 
      # bug in JS client does not update values.
      # updateRadioButtons(session, "phq2Q1YesNo", selected = character(0))
      # updateRadioButtons(session, "phq2Q2YesNo", selected = character(0))

      # *FIX* Run JS
      runjs("$('input[name=phq2Q1YesNo]').prop('checked', false);") # clears the radio input visually
      runjs("Shiny.onInputChange('phq2Q1YesNo', null);") # clears the Shiny input$ reactiveVal
      runjs("$('input[name=phq2Q2YesNo]').prop('checked', false);")
      runjs("Shiny.onInputChange('phq2Q2YesNo', null);")
    })

    # -- PHQ9 Questionaire Response
    # Enable Submit button only when either:
    # a. Q1-9 are selected, and if totalScore is 0, Q10 is answered
    # b. Q1-9 are selected and if totalScore > 0
    observe({
      enableQ10 = FALSE
      enableSubmit = FALSE
      q1to9Scores = c(input$phq9Q1Score, 
                      input$phq9Q2Score,
                      input$phq9Q3Score,
                      input$phq9Q4Score,
                      input$phq9Q5Score,
                      input$phq9Q6Score,
                      input$phq9Q7Score,
                      input$phq9Q8Score,
                      input$phq9Q9Score)
      
      # check if Q1-9 have been submitted
      # lapply does not work on NULL values:
      #    q1to9Selected = lapply(q1to9Scores, is.character)
      # instead, write it out:
      q1to9Selected = is.character(input$phq9Q1Score) & 
                      is.character(input$phq9Q2Score) &
                      is.character(input$phq9Q3Score) &
                      is.character(input$phq9Q4Score) &
                      is.character(input$phq9Q5Score) &
                      is.character(input$phq9Q6Score) &
                      is.character(input$phq9Q7Score) &
                      is.character(input$phq9Q8Score) &
                      is.character(input$phq9Q9Score)

      # using set equality to see if Q1-9 has been selected
      if(q1to9Selected) { # all Q1-9 have been selected
        # sum the scores using Map-Reduce
        totalScore = Reduce("+", Map(as.integer, q1to9Scores))

        # decide whether to show Q10
        if(totalScore == 0) { # hide Q10, enabled Submit 
          enableQ10 = FALSE
          enableSubmit = TRUE
        } else { # problems, show Q10
          enableQ10 = TRUE
          # enable Submit once Q10 is answered
          enableSubmit = is.character(input$phq9Q10Score)
        }
      }
      
      # update the UI:
      # - enable/disable Q10
      toggleElement(id="phq9Q10", anim=TRUE, animType="fade", time=0.5, condition = enableQ10)
      
      # - enable/disable submit Button
      toggleState(id = "phq9SubmitButton", condition = enableSubmit)
    })
    
    # Submit PHQ9 Form
    observeEvent(input$phq9SubmitButton,   { 
      logEvent("PHQ9", paste("Submitted Form"))
      sendQuestionnaireResponses(
        screening = list(
          "yesNoLittleInterest" = "Yes", # PHQ2 Yes/No Screening Q1
          "yesNoFeelingDown" = "Yes"     # PHQ2 Yes/No Screening Q1
        ),
        scores = list(
          "LittleInterest"       = input$phq9Q1Score, # PHQ9 score for LittleInterest (Q1)
          "FeelingDown"          = input$phq9Q2Score, # PHQ9 score for FeelingDown (Q2)
          "TroubleSleeping"      = input$phq9Q3Score, # PHQ9 score for TroubleSleeping (Q3)
          "FeelingTired"         = input$phq9Q4Score, # PHQ9 score for FeelingTired (Q4)
          "BadAppetite"          = input$phq9Q5Score, # PHQ9 score for BadAppetite (Q5)
          "FeelingBadAboutSelf"  = input$phq9Q6Score, # PHQ9 score for FeelingBadAboutSelf (Q6)
          "TroubleConcentrating" = input$phq9Q7Score, # PHQ9 score for TroubleConcentrating (Q7)
          "MovingSpeaking"       = input$phq9Q8Score, # PHQ9 score for MovingSpeaking (Q8)
          "ThoughtsHurting"      = input$phq9Q9Score  # PHQ9 score for ThoughtsHurting (Q9)
        ),
        difficulty = input$phq9Q10Score)
      
      # Shows Mood Grid after submitting
      runjs("$('#mood-tabs a[href=\"#mood-grid\"]').tab('show');")
      
      # Clear PHQ9 Inputs
      phq9Radios = c("phq9Q1Score", 
                     "phq9Q2Score",
                     "phq9Q3Score",
                     "phq9Q4Score",
                     "phq9Q5Score",
                     "phq9Q6Score",
                     "phq9Q7Score",
                     "phq9Q8Score",
                     "phq9Q9Score",
                     "phq9Q10Score")
      
      for(id in phq9Radios) {
        # These *should* clear the radioButtons for the questions, but 
        # bug in JS client does not update values.
        # updateRadioButtons(session, id, selected = character(0))

        # *FIX* Run JS
        runjs(paste("$('input[name=",id,"]').prop('checked', false);", sep='')) # clears the radio input visually
        runjs(paste("Shiny.onInputChange('",id,"', null);", sep='')) # clears the Shiny input$ reactiveVal
      }
    })
    
    #
    # Tab: Feedback (Clinical Impression)
    #

    # Initialize Feedback Tab to be showing the "New Feedback" textarea:
    hideElement(id = "previousFeedback")
    showElement(id = "newFeedback")
    
    observeEvent(input$previousFeedback, {
      # Value of the "previousFeedback" input is the `timestamp` of the datasetFeedback
      i = which(datasetFeedback$timestamp == input$previousFeedback) 

      logEvent("Feedback", paste("Load Previous Feedback, datasetFeedback index:", i))

      # Re-render the feedbackPanel
      output$feedbackPanel = renderFeedbackPanel(datasetFeedback$note[i], 
                                                 datasetFeedback$timestamp[i])
      
      # Make sure the Feedback Panel is showing
      showElement(id = "previousFeedback")
      hideElement(id = "newFeedback")
    })
    
    # Render the list of Previous Feedback as a Sidebar
    output$previousFeedbackList = renderPreviousFeedbackList({ datasetFeedback })

    # Event: Patient wants to start to edit new Feedback
    observeEvent(input$newFeedbackButton,   { 
      logEvent("Feedback", "New Feedback") 
      # show the Feedback Text and Button Area
      hideElement(id = "previousFeedback")
      showElement(id = "newFeedback")
    })
    
    # Event: when patient edits in the Feedback Text Area
    observeEvent(input$feedbackTextarea, { 
      logEvent("Feedback", paste("Editing, feedback size: ", nchar(input$feedbackTextarea), "characters")) 
    })
    
    # Event: Patients submits the Feedback
    observeEvent(input$feedbackButton,   { 
      if(nchar(input$feedbackTextarea) > 0) { # only submit Feedback if there is something written
        logEvent("Feedback", paste("Submitting, final feedback size: ", nchar(input$feedbackTextarea), "characters"))
        if(sendClinicalImpression(input$feedbackTextarea)) { # successful submission of feedback
          updateTextAreaInput(session, "feedbackTextarea", value = "") # clear the feedbackTextArea
          # Update the datasetFeedback
          datasetFeedback = loadClinicalImpressionData(startTimestamp="2019-08-13T16:26:26Z", 
                                                       endTimestamp="2020-02-28T00:00:00Z",
                                                       sample = SAMPLE_DATA)
          # ... and re-Render the list of Previous Feedback as a Sidebar 
          # (TODO - use a reactiveValue on datasetFeedback)
          output$previousFeedbackList = renderPreviousFeedbackList({ datasetFeedback })
        }
      } else {
        logEvent("Feedback", "Pressed Submit with empty textarea.")
      }
    })
}