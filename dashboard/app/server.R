# CONSULT UI Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the server logic of a Shiny web application.
#

# server function with input and output objects.
# input - references to events and input from the client
# output - references to output objects to update in client
# session - live session object for updating input controls
function(input, output, session) {

    # Set-up UI Configuration from Environment Variables
    # - Debug Panel is shown by default
    if(!DEBUG_PANEL) {
      hide(id="debug-panel")
    }

    # - Active Tabs
    active_tabs = unlist(strsplit(ACTIVE_TABS, split=","))
    # (values refer to the id of tab elements)
    for(t in c("summary",
               "bp",
               "hr",
               "ecg",
               "mood",
               "risk",
               "recommendations",
               "feedback")) {
      if(t %in% active_tabs) { # show tab
        # tab is shown by default
        print(paste("Showing", t, "Tab"))
      } else {
        # hides the "consult-<tab>-tab" in the nav bar
        hide(id=paste("consult-",t,"-tab", sep=""))
        # hides the div containing the tab
        hide(id=t)
        print(paste("hiding", t, "Tab"))
      }
    }

    # Render the Version String
    output$versionString = renderText(paste("v", DASHBOARD_VERSION, sep=""))

    # Store app data in a reactiveValue for reactive refreshing
    data = reactiveValues()

    #
    # Load Datasets and generate statistics
    #
    # - Blood Pressure
    #
    # Simulation BP only available:
    # start: 2017-01-01 00:00:00
    # end:   2017-06-19 00:00:00
    data$BP = loadBloodPressureData(startTimestamp = STUDY_START_TIMESTAMP,
                                    endTimestamp   = STUDY_END_TIMESTAMP,
                                    sample = USE_SAMPLE_DATA)
    # - Heart Rate
    #
    # Simulation HR available:
    # start: 2019-04-04 23:19:39
    # end: 2019-04-09 13:56:13
    data$HR = loadHeartRateData(startTimestamp = STUDY_START_TIMESTAMP,
                                  endTimestamp = STUDY_END_TIMESTAMP,
                                  sample = USE_SAMPLE_DATA)
    # - ECG
    #
    # (Sample) Only one date entry: 2019-08-06 17:27:25
    #
    data$ECG = loadECGData(startTimestamp = STUDY_START_TIMESTAMP,
                             endTimestamp = STUDY_END_TIMESTAMP,
                             sample = USE_SAMPLE_DATA)
    # - Mood
    #
    # Mood Data is available as submitted
    #
    data$Mood = loadMoodData(startTimestamp = STUDY_START_TIMESTAMP,
                               endTimestamp = STUDY_END_TIMESTAMP,
                               sample = USE_SAMPLE_DATA)

    # - Feedback (Clinical Impression)
    #
    # Should be all Clinical Impressions
    #
    data$Feedback = loadClinicalImpressionData(startTimestamp = STUDY_START_TIMESTAMP,
                                               endTimestamp   = STUDY_END_TIMESTAMP,
                                               sample = USE_SAMPLE_DATA)

    # - PHQ (Questionnaire Responses)
    #
    # Questionnaire Responses are available as submitted
    #
    # Note: Questionnaire Responses Data prior to "2019-08-22 00:00:00" is incomplete
    #       and causes load errors with the table!!! ("Error in scan: line 1 did not have 17 elements")
    #       PATCH - get PHQ data according to the STUDY_PHQ_DAYS_FREQ
    data$PHQ = loadPHQData(startTimestamp = STUDY_START_TIMESTAMP, # Temporarily have fixed PHQ9 start time to ensure dashboard load: Sys.time() - as.difftime(as.double(STUDY_PHQ_DAYS_FREQ), units="days"),
                           endTimestamp   = STUDY_END_TIMESTAMP,
                           sample = FALSE)

    ### Summaries
    # Store Summary data in reactiveValues
    summary = reactiveValues()

    observe({ # summarise the BP dataset
      summary$BP = summariseBloodPressure(data$BP)
    })

    observe({ # summarise the HR dataset
      summary$HR = summariseHeartRate(data$HR)
    })

    observe({ # summarise the ECG dataset
      summary$ECG = summariseECG(data$ECG)
    })

    observe({ # summarise the Mood dataset
      summary$Mood = summariseMood(data$Mood)
    })

    observe({ # summarise the PHQ dataset
      summary$PHQ = summarisePHQ(data$PHQ)
    })

    ### Timeline
    # Store the snapshot of data to display on plots in reactiveValues
    timeline = reactiveValues()

    #####
    #
    # Tab: Summary Boxes
    #

    # Event: when Summary Tab is selected
    observeEvent(input$tabSummaryLink, {
      logEvent("TabChanged", "Summary Tab Selected")
    })

    # - Blood Pressure Summary
    output$summaryBP = renderSummaryBox({
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
                 alert = summary$BP$alert,
                 alert_text = summary$BP$alert_text,
                 status = summary$BP$status,
                 timestamp = summary$BP$timestamp,
                 source = "Home")
    })

    # Event: Clicking on the Blood Pressure Summary Box
    observeEvent(input$summaryBP, {
      logEvent("SummaryBoxClicked", "Blood Pressure")
      # change Tab
      runjs("$('#tabBPLink').tab('show');")
    })

    # - Heart Rate Summary
    output$summaryHR = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Heart Rate",
                 image = "images/summary/heartrate.png",
                 alert = summary$HR$connectivity,
                 status = summary$HR$status,
                 timestamp = summary$HR$timestamp,
                 source = "Home")
    })

    # Event: Clicking on the HR Summary Box
    observeEvent(input$summaryHR, {
      logEvent("SummaryBoxClicked", "Heart Rate")
      # change Tab
      runjs("$('#tabHRLink').tab('show');")
    })

    # - ECG Summary
    output$summaryECG = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "ECG",
                 image = "images/summary/ecg.png",
                 alert = summary$ECG$connectivity,
                 status = summary$ECG$status,
                 timestamp = summary$ECG$timestamp,
                 source = "Clinic")
    })

    # Event: Summary Box for ECG is clicked
    observeEvent(input$summaryECG, {
      logEvent("SummaryBoxClicked", "ECG")
      # change Tab
      runjs("$('#tabECGLink').tab('show');")
    })

    # - Mood Summary
    output$summaryMood = renderSummaryBox({
      #from packages/Consult/SummaryBox
      SummaryBox(title = "Mood",
                 # Mood text dictates the summary image:
                 image = mood_img_src(summary$Mood$status),
                 alert = summary$Mood$connectivity,
                 status = "", # don't show the Mood text
                 # status = summary$Mood$status,
                 timestamp = summary$Mood$timestamp,
                 source = "Home")
    })

    # Event: Summary Box for Mood is clicked
    observeEvent(input$summaryMood, {
      logEvent("SummaryBoxClicked", "Mood")
      # change Tab
      runjs("$('#tabMoodLink').tab('show');")
    })

#####
    #
    # Tab: Heart Rate (HR)
    #

    # Event: when HR Tab is selected
    observeEvent(input$tabHRLink, {
      logEvent("TabChanged", "HR Tab Selected")

      # Refresh the HR data
      data$HR = loadHeartRateData(startTimestamp = STUDY_START_TIMESTAMP,
                                  endTimestamp = STUDY_END_TIMESTAMP,
                                  sample = USE_SAMPLE_DATA)
    })

    # Select different time-range events
    observeEvent(input$selectLastFourHoursHR, {
      logEvent("HRPlot", "Last Four Hours Selected")
      # lastData from data.R
      timeline$HR = lastData(data$HR, hours=4)
    },
    # LastFourHours Button is initially active
    # This makes it runs when the event is initialized (even when the button is not pressed)
    # see -> https://shiny.rstudio.com/reference/shiny/latest/observeEvent.html
    ignoreNULL = FALSE, ignoreInit = FALSE)


    observeEvent(input$selectLastDayHR, {
      logEvent("HRPlot", "Last 24 Hours  Selected")
      timeline$HR = lastData(data$HR, days=1)
    })

    observeEvent(input$selectLastWeekHR, {
      logEvent("HRPlot", "Last Week Selected")
      timeline$HR = lastData(data$HR, weeks=1)
    })

    observeEvent(input$selectLastMonthsHR, {
      logEvent("HRPlot", "Last Month Selected")
      timeline$HR = lastData(data$HR, weeks=4)
    })

    output$plotHR = renderHRTimeline({
        # from packages/Consult/HRTimeline
        HRTimeline(dataset = timeline$HR)
    })

#####
    #
    # Tab: Blood Pressure (BP)
    #

    # Event: when BP Tab is selected
    observeEvent(input$tabBPLink, {
      logEvent("TabChanged", "BP Tab Selected")

      # Refresh BP data
      data$BP = loadBloodPressureData(startTimestamp = STUDY_START_TIMESTAMP,
                                      endTimestamp   = STUDY_END_TIMESTAMP,
                                      sample = USE_SAMPLE_DATA)

      # only render alert when *not* green
      if(!is.null(summary$BP$alert)) {

        if(summary$BP$alert != "green") {
          # Re-renders the Alert Box
          output$alertBP = renderAlertBP(
            alert = summary$BP$alert,
            alert_text = summary$BP$alert_long_text
          )
        }

      }
    })

    # Select different time-range events
    observeEvent(input$selectLastFourHoursBP, {
      logEvent("BPPlot", "Last Four Hours Selected")
      # lastData from data.R
      timeline$BP = lastData(data$BP, hours=4)
    })

    observeEvent(input$selectLastDayBP, {
      logEvent("BPPlot", "Last 24 Hours  Selected")
      timeline$BP = lastData(data$BP, days=1)
    },
    # LastFourHours Button is initially active
    # This makes it runs when the event is initialized (even when the button is not pressed)
    # see -> https://shiny.rstudio.com/reference/shiny/latest/observeEvent.html
    ignoreNULL = FALSE, ignoreInit = FALSE)

    observeEvent(input$selectLastWeekBP, {
      logEvent("BPPlot", "Last Week Selected")
      timeline$BP = lastData(data$BP, weeks=1)
    })

    observeEvent(input$selectLastMonthBP, {
      logEvent("BPPlot", "Last Month Selected")
      timeline$BP = lastData(data$BP, weeks=4)
    })

    output$plotBP = renderBPTimeline({
        # from packages/Consult/BPTimeline
        BPTimeline(dataset = timeline$BP)
    })

#####
    #
    # Tab: ECG
    #

    # Event: when ECG tab is selected
    observeEvent(input$tabECGLink, {
      logEvent("TabChanged", "ECG Tab Selected")

      # Refresh ECG data
      data$ECG = loadECGData(startTimestamp = STUDY_START_TIMESTAMP,
                             endTimestamp = STUDY_END_TIMESTAMP,
                             sample = USE_SAMPLE_DATA)
    })

    output$plotECG = renderECGTimeline({
      # from packages/Consult/ECGTimeline
      ECGTimeline(dataset = averageCell(lastData(data$ECG, weeks=1), "ecg"))
    })

#####
    # Tab: Risk
    #

    # Event: when Risk tab is selected
    observeEvent(input$tabRiskLink, {
      logEvent("TabChanged", "Risk Tab Selected")
    })

    # Always render the baseline.png
    output$baselineRiskPlot = renderImage({
      list(src = normalizePath("./www/images/interventions/baseline.png"))
    }, deleteFile = FALSE)

    # Event: when Stop Smoking is selected
    observeEvent(input$stopSmokingIntervention, {
      logEvent("InterventionSelected", "Stop Smoking")
      output$interventionRiskPlot = renderImage({
        list(src = normalizePath("./www/images/interventions/stop-smoking.png"))
      }, deleteFile = FALSE)
    },
    # Initialize the interventionRiskPlot with "Stop Smoking"
    # This makes it runs when the event is initialized (even when the button is not pressed)
    # see -> https://shiny.rstudio.com/reference/shiny/latest/observeEvent.html
    ignoreNULL = FALSE, ignoreInit = FALSE)

    # Event: when Lower Blood Pressure is selected
    observeEvent(input$lowerBPIntervention, {
      logEvent("InterventionSelected", "Lower Blood Pressure")
      output$interventionRiskPlot = renderImage({
        list(src = normalizePath("./www/images/interventions/lower-bp.png"))
      }, deleteFile = FALSE)
    })

    # Event: when Lower Cholesterol is selected
    observeEvent(input$lowerCholesterolIntervention, {
      logEvent("InterventionSelected", "Lower Cholesterol")
      output$interventionRiskPlot = renderImage({
        list(src = normalizePath("./www/images/interventions/lower-cholesterol.png"))
      }, deleteFile = FALSE)
    })

    # Event: when Anti-Platelet is selected
    observeEvent(input$antiPlateletIntervention, {
      logEvent("InterventionSelected", "Anti-Platelet")
      output$interventionRiskPlot = renderImage({
        list(src = normalizePath("./www/images/interventions/antiplatelet.png"))
      }, deleteFile = FALSE)
    })

#####
    #
    # Tab: Tips (Recommendations)
    #

    # Event: when Recommendations Tab is selected
    observeEvent(input$tabRecommendationsLink, {
      logEvent("TabChanged", "Recommendations Tab Selected")

      # Refresh the list of Tips everytime the Recommendations Tab is loaded.
      output$listRecommendations = renderRecommendations({
        # pass a fresh set of Recommendations data along to render
        tips = loadRecommendations()
        if(RANDOMIZE_RECOMMENDATIONS) { # if randomize
          # use dlpyr::sample_frac for randomizing rows in a table
          sample_frac(tips) # returns randomised sample
        } else {
          tips # returns
        }
      })
    })

#####
    #
    # Tab: Mood
    #
    observeEvent( input$tabMoodLink, {
      logEvent( "TabChanged", "Mood Tab Selected" )

      # Time difference units will vary depending on the time difference: Specify "days":
      if (!is.null(summary$Mood$timestamp) & !is.null(summary$PHQ$timestamp)) {

        moodTimeSince = difftime(Sys.time(), summary$Mood$timestamp, units="days")
        phqTimeSince = difftime(Sys.time(), summary$PHQ$timestamp, units="days")

        print(paste( "DEBUG", "time (DAYS) since last phq: ", phqTimeSince, " time since last mood: ", moodTimeSince))

      } else {

        moodTimeSince = 0;
        phqTimeSince = 0;

      }

      # Check if past-due next PHQ Time
      if(phqTimeSince > as.double(STUDY_PHQ_DAYS_FREQ)) {
        # Shows PHQ2 Tab
        runjs("$('#mood-tabs a[href=\"#phq2\"]').tab('show');")
      } else {
        # Shows Mood Tab
        runjs("$('#mood-tabs a[href=\"#mood-grid\"]').tab('show');")
      }
    })

    # -- Mood Grid Events
    output$emotionLinkTired      = renderMoodLink("tired")
    output$emotionLinkTense      = renderMoodLink("tense")
    output$emotionLinkSleepy     = renderMoodLink("sleepy")
    output$emotionLinkSerene     = renderMoodLink("serene")
    output$emotionLinkSatisfied  = renderMoodLink("satisfied")
    output$emotionLinkSad        = renderMoodLink("sad")
    output$emotionLinkMiserable  = renderMoodLink("miserable")
    output$emotionLinkHappy      = renderMoodLink("happy")
    output$emotionLinkGloomy     = renderMoodLink("gloomy")
    output$emotionLinkGlad       = renderMoodLink("glad")
    output$emotionLinkFrustrated = renderMoodLink("frustrated")
    output$emotionLinkExcited    = renderMoodLink("excited")
    output$emotionLinkDelighted  = renderMoodLink("delighted")
    output$emotionLinkCalm       = renderMoodLink("calm")
    output$emotionLinkAngry      = renderMoodLink("angry")
    output$emotionLinkAfraid     = renderMoodLink("afraid")

    # Event: moodObservation is send by the Mood Links
    observeEvent(input$moodObservation, {
      logEvent("MoodGrid", paste("Mood Selected", input$moodObservation))

      # Set the contents of the Selected Mood Image
      output$selectedMoodImage = renderImage({
        img_src = mood_img_src(input$moodObservation, medium_size=TRUE)
        print(img_src)
        filename = normalizePath(file.path('./www', img_src))
        print(filename)
        list(src =  filename)
      }, deleteFile = FALSE)

      # Show the Selected Mood Tab
      runjs("$('#mood-tabs a[href=\"#mood-selected\"]').tab('show');")
    })

    # Event: Patient accepts the selected Mood Image
    observeEvent(input$selectedMoodImageYesButton, {
      logEvent("MoodGrid", "Accepts Selected Mood Image")

      # Sends the current moodObservation
      sendMoodObservation(input$moodObservation)

      # Clear the selected Mood Image
      output$selectedMoodImage = renderImage({
        list(src =  normalizePath(file.path('./www/images/blank.png', img_src)))
      }, deleteFile = FALSE)

      # Return to the Mood Grid
      runjs("$('#mood-tabs a[href=\"#mood-grid\"]').tab('show');")

      # Refresh the Mood Data - so the Summary can be updated
      data$Mood = loadMoodData(startTimestamp = STUDY_START_TIMESTAMP,
                               endTimestamp = STUDY_END_TIMESTAMP,
                               sample = USE_SAMPLE_DATA)
    })

    # Event: Patient rejects selected Mood Image
    observeEvent(input$selectedMoodImageNoButton, {
      logEvent("MoodGrid", "Rejects Selected Mood Image")

      # Clear the selected mood image by displaying a blank image
      output$selectedMoodImage = renderImage({
        list(src =  normalizePath(file.path('./www/images/blank.png')))
      }, deleteFile = FALSE)

      # Return to the Mood Grid
      runjs("$('#mood-tabs a[href=\"#mood-grid\"]').tab('show');")
    })

    # -- PHQ2 Screening Form
    observe({ # Enable Submit button only when both questions are answered
      toggleState(id = "phq2SubmitButton",
                  condition = is.character(input$phq2Q1YesNo) & is.character(input$phq2Q2YesNo))
    })

    # Submit PHQ2 Form
    observeEvent(input$phq2SubmitButton, {
      logEvent("PHQ2", paste("Submitted Form Q1:", input$phq2Q1YesNo, "Q2:", input$phq2Q2YesNo))

      # show PHQ9 form if either Question Answers are Yes
      if(input$phq2Q1YesNo == "1" | input$phq2Q2YesNo == "1") {
        # Shows PHQ9 Tab
        runjs("$('#mood-tabs a[href=\"#phq9\"]').tab('show');")
      } else {
        # Send the PHQ2 reponses only
        sendQuestionnaireResponses(
          screening = list( # NOTE: ordering of these questions are switched in PHQ9!
            "FeelingDownInitial" = input$phq2Q1YesNo,     # PHQ2 Yes/No Screening Q1
            "LittleInterestInitial" = input$phq2Q2YesNo   # PHQ2 Yes/No Screening Q2
          )
        )

        # Shows (default) Mood Grid
        runjs("$('#mood-tabs a[href=\"#mood-grid\"]').tab('show');")

        # Clean-up PHQ2 Form
        phqRadios = c("phq2Q1YesNo",
                      "phq2Q2YesNo")

        for(id in phqRadios) {
          # These *should* clear the radioButtons for the questions, but
          # bug in JS client does not update values.
          # updateRadioButtons(session, id, selected = character(0))

          # *FIX* Run JS
          runjs(paste("$('input[name=",id,"]').prop('checked', false);", sep='')) # clears the radio input visually
          runjs(paste("Shiny.onInputChange('",id,"', null);", sep='')) # clears the Shiny input$ reactiveVal
        }

        # Refresh the PHQ Data
        data$PHQ = loadPHQData(startTimestamp = Sys.time() - as.difftime(as.double(STUDY_PHQ_DAYS_FREQ), units="days"),
                               endTimestamp   = STUDY_END_TIMESTAMP,
                               sample = FALSE)
      }
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
          "FeelingDownInitial"    = input$phq2Q1YesNo, # PHQ2 Yes/No Screening Q1
          "LittleInterestInitial" = input$phq2Q2YesNo  # PHQ2 Yes/No Screening Q2
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

      #
      # Clean-up PHQ 2 and 9 RadioButtons
      #
      phqRadios = c("phq2Q1YesNo",
                    "phq2Q2YesNo",
                    "phq9Q1Score",
                    "phq9Q2Score",
                    "phq9Q3Score",
                    "phq9Q4Score",
                    "phq9Q5Score",
                    "phq9Q6Score",
                    "phq9Q7Score",
                    "phq9Q8Score",
                    "phq9Q9Score",
                    "phq9Q10Score")

      for(id in phqRadios) {
        # These *should* clear the radioButtons for the questions, but
        # bug in JS client does not update values.
        # updateRadioButtons(session, id, selected = character(0))

        # *FIX* Run JS
        runjs(paste("$('input[name=",id,"]').prop('checked', false);", sep='')) # clears the radio input visually
        runjs(paste("Shiny.onInputChange('",id,"', null);", sep='')) # clears the Shiny input$ reactiveVal
      }

      # Refresh the PHQ Data
      data$PHQ = loadPHQData(startTimestamp = STUDY_START_TIMESTAMP, # Temporarily have fixed PHQ9 start time to ensure dashboard load: Sys.time() - as.difftime(as.double(STUDY_PHQ_DAYS_FREQ), units="days"),
                             endTimestamp   = STUDY_END_TIMESTAMP,
                             sample = FALSE)
    })

#####
    #
    # Tab: Feedback (Clinical Impression)
    #

    # Event: when Feedback Tab is selected
    observeEvent(input$tabFeedbackLink, {
      logEvent("TabChanged", "Feedback Tab Selected")
    })

    # Initialize Feedback Tab to be showing the "New Feedback" textarea:
    hideElement(id = "previousFeedback")
    showElement(id = "newFeedback")

    observeEvent(input$previousFeedback, {
      # Value of the "previousFeedback" input is the `timestamp` of the data$Feedback
      i = which(data$Feedback$timestamp == input$previousFeedback)

      logEvent("Feedback", paste("Load Previous Feedback, data$Feedback index:", i))

      # Re-render the feedbackPanel
      output$feedbackPanel = renderFeedbackPanel(data$Feedback$note[i],
                                                 data$Feedback$timestamp[i])

      # Make sure the Feedback Panel is showing
      showElement(id = "previousFeedback")
      hideElement(id = "newFeedback")
    })

    # Render the list of Previous Feedback as a Sidebar
    observe({
      output$previousFeedbackList = renderPreviousFeedbackList(data$Feedback)
    })

    # Event: Patient wants to start to edit new Feedback
    observeEvent(input$newFeedbackButton,   {
      logEvent("Feedback", "Create New Feedback")
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
      # Only submit Feedback if there is something written
      n = nchar(input$feedbackTextarea)
      if(n > 0) {
        logEvent("Feedback", paste("Submitting, final feedback size: ", n, "characters"))
        # Successful submission of feedback
        if(sendClinicalImpression(input$feedbackTextarea)) {
          # Clear the feedbackTextArea
          updateTextAreaInput(session, "feedbackTextarea", value = "")
          # Update the data$Feedback
          data$Feedback = loadClinicalImpressionData(startTimestamp = STUDY_START_TIMESTAMP,
                                                     endTimestamp   = STUDY_END_TIMESTAMP,
                                                     sample = USE_SAMPLE_DATA)
        }
      } else { # Log the user pressing submit
        logEvent("Feedback", "Pressed Submit with empty textarea.")
      }
    })
} # server function
