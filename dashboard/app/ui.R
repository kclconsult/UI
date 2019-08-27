# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above (if you are working with this in RStudio)
#

library(shiny)
library(shinyjs) # JS add-ons

# Shiny Options
# See: https://rdrr.io/cran/shiny/man/shiny-options.html
options(
  shiny.launch.browser = TRUE,
  shiny.trace = TRUE,
  shiny.minified = FALSE # use un-minified shiny.js
)
        
# local htmlwidgets
library(Consult)

## ui.R ##
#
# Define the HTML template to inject all of the Shiny
# input and output objects into.  
#
# See https://shiny.rstudio.com/articles/templates.html for more info.

# re-usable choices vectors for PHQ9 form
freqChoices = c("Not at all" = "0", 
                "Several days" = "1",
                "More than half the days" = "2",
                "Nearly every day" = "3")

# NOTE on Browser Size:
# 2/3 width: 841 px width, 696 px height
# 1/2 width: 642 px width

htmlTemplate("www/index.html",
  # Version String
  versionString = textOutput("versionString", inline=TRUE),
  
  # NavBar Tab Buttons (actionLinks allow for Shiny reactivity)
  # - 
  # <a href="#summary" data-toggle="tab">Summary</a>
  # Replace Summary with a Home Icon
  # tabSummaryLink = actionLink("tabSummaryLink", "Summary", href = "#summary", `data-toggle` = "tab"),
  tabSummaryLink = actionLink("tabSummaryLink", tags$img(src="images/icons/home-icon.png"), href = "#summary", `data-toggle` = "tab"),
  # <a href="#hr" data-toggle="tab">Heart Rate</a>
  tabHRLink = actionLink("tabHRLink", tags$div(tags$img(src="images/icons/heart-rate-icon.png"), tags$span("HR")), href = "#hr", `data-toggle` = "tab"),
  # <a href="#bp" data-toggle="tab">Blood Pressure</a>
  tabBPLink = actionLink("tabBPLink", tags$div(tags$img(src="images/icons/blood-pressure-icon.png"), tags$span("BP")), href = "#bp", `data-toggle` = "tab"),
  # <a href="#ecg" data-toggle="tab">ECG</a>
  tabECGLink = actionLink("tabECGLink", tags$div(tags$img(src="images/icons/ecg-icon.png"), tags$span("ECG")), href = "#ecg", `data-toggle` = "tab"),
  # <a href="#risk" data-toggle="tab">Risk</a>
  tabRiskLink = actionLink("tabRiskLink", "Risk", href = "#risk", `data-toggle` = "tab"),
  # <a href="#recommendations" data-toggle="tab">Recommendations</a>
  tabRecommendationsLink = actionLink("tabRecommendationsLink", "Tips", href = "#recommendations", `data-toggle` = "tab"),
  # <a href="#mood" data-toggle="tab">Mood</a>
  tabMoodLink = actionLink("tabMoodLink", "Mood", href = "#mood", `data-toggle` = "tab"),
  # <a href="#feedback" data-toggle="tab">Feedback</a>
  tabFeedbackLink = actionLink("tabFeedbackLink", "Feedback", href = "#feedback", `data-toggle` = "tab"),
  
  # Tab: Summary
  # - Selectors as Bootstrip "nav-pills"
  selectLastFourHours = actionLink("selectLastFourHours", "Last 4 Hours", href = "#", `data-toggle` = "pill"),
  selectLastDay = actionLink("selectLastDay", "Last 24 Hours", href = "#", `data-toggle` = "pill"),
  selectLastMonth = actionLink("selectLastMonth", "Last Month", href = "#", `data-toggle` = "pill"),

  # - Summary Boxes
  summaryBP   = SummaryBoxOutput("summaryBP"),
  summaryHR   = SummaryBoxOutput("summaryHR"),
  summaryECG  = SummaryBoxOutput("summaryECG"),
  summaryMood = SummaryBoxOutput("summaryMood"),

  # --- DEBUG Summary Boxes
  debugSelectBPAlertColor = selectInput("debugSelectBPAlertColor", "Select BP Alert", c("", "green", "orange", "red", "doublered")),
  debugSelectBPAlertText = selectInput("debugSelectBPAlertText", "Select BP Text", c("", "Normal", "Slightly high", "A bit higher than normal")),

  # Tab: Heart Rate (HR)
  plotHR = HRTimelineOutput("plotHR"),
  
  # Tab: Blood Pressure (BP)
  alertBP =  htmlOutput("alertBP"),
  plotBP = BPTimelineOutput("plotBP"),
  
  # Tab: ECG
  plotECG = ECGTimelineOutput("plotECG"),

  # Tab: Risk
  stopSmokingIntervention = actionLink("stopSmokingIntervention", "Stop Smoking", href = "#stop-smoking", `data-toggle` = "pill"),
  lowerBPIntervention = actionLink("lowerBPIntervention", "Lower Blood Pressure", href = "#lower-bp", `data-toggle` = "pill"),
  lowerCholesterolIntervention = actionLink("lowerCholesterolIntervention", "Lower Cholesterol", href = "#lower-cholesterol", `data-toggle` = "pill"),
  antiPlateletIntervention = actionLink("antiPlateletIntervention", "Anti-Platelet" , href = "#antiplatelet", `data-toggle` = "pill"),
  
  interventionRiskPlot = imageOutput("interventionRiskPlot", width = "100%", height = "400px"),
  
  # Tab: Recommendations
  listRecommendations = htmlOutput("listRecommendations"),

  # Tab: Mood

  # - Mood Grid Selection Actions
  # Note: uses mood_img_src() (from data.R) to resolve image paths 
  # emotionLinkAfraid = actionLink("emotionLinkAfraid", tags$img(src = mood_img_src("afraid"))),
  # emotionLinkTense = actionLink("emotionLinkTense",   tags$img(src = mood_img_src("tense"))),
  # emotionLinkExcited = actionLink("emotionLinkExcited",       tags$img(src = mood_img_src("excited"))),
  # emotionLinkDelighted = actionLink("emotionLinkDelighted",   tags$img(src = mood_img_src("delighted"))),
  # emotionLinkFrustrated = actionLink("emotionLinkFrustrated", tags$img(src = mood_img_src("frustrated"))),
  # emotionLinkAngry = actionLink("emotionLinkAngry",   tags$img(src = mood_img_src("angry"))),
  # emotionLinkHappy = actionLink("emotionLinkHappy",   tags$img(src = mood_img_src("happy"))),
  # emotionLinkGlad = actionLink("emotionLinkGlad",     tags$img(src = mood_img_src("glad"))),
  # emotionLinkMiserable = actionLink("emotionLinkMiserable", tags$img(src = mood_img_src("miserable"))),
  # emotionLinkSad = actionLink("emotionLinkSad",       tags$img(src = mood_img_src("sad"))),
  # emotionLinkCalm = actionLink("emotionLinkCalm",     tags$img(src = mood_img_src("calm"))),
  # emotionLinkSatisfied = actionLink("emotionLinkSatisfied", tags$img(src = mood_img_src("satisfied"))),
  # emotionLinkGloomy = actionLink("emotionLinkGloomy", tags$img(src = mood_img_src("gloomy"))),
  # emotionLinkTired = actionLink("emotionLinkTired",   tags$img(src = mood_img_src("tired"))),
  # emotionLinkSleepy = actionLink("emotionLinkSleepy", tags$img(src = mood_img_src("sleepy"))),
  # emotionLinkSerene = actionLink("emotionLinkSerene", tags$img(src = mood_img_src("serene"))),
  
  emotionLinkAfraid = htmlOutput("emotionLinkAfraid"),
  emotionLinkTense = htmlOutput("emotionLinkTense"),
  emotionLinkExcited = htmlOutput("emotionLinkExcited"),
  emotionLinkDelighted = htmlOutput("emotionLinkDelighted"),
  emotionLinkFrustrated = htmlOutput("emotionLinkFrustrated"),
  emotionLinkAngry = htmlOutput("emotionLinkAngry"),
  emotionLinkHappy = htmlOutput("emotionLinkHappy"),
  emotionLinkGlad = htmlOutput("emotionLinkGlad"),
  emotionLinkMiserable = htmlOutput("emotionLinkMiserable"),
  emotionLinkSad = htmlOutput("emotionLinkSad"),
  emotionLinkCalm = htmlOutput("emotionLinkCalm"),
  emotionLinkSatisfied = htmlOutput("emotionLinkSatisfied"),
  emotionLinkGloomy = htmlOutput("emotionLinkGloomy"),
  emotionLinkTired = htmlOutput("emotionLinkTired"),
  emotionLinkSleepy = htmlOutput("emotionLinkSleepy"),
  emotionLinkSerene = htmlOutput("emotionLinkSerene"),
  
  # - PHQ2 Form Controls
  # -- radioButtons: https://shiny.rstudio.com/reference/shiny/1.3.2/radioButtons.html
  phq2Q1YesNo = radioButtons("phq2Q1YesNo", NULL, # no label
                             selected = character(0), # initially nothing selected
                             choices = c("Yes" = "y", "No" = "n")),
  phq2Q2YesNo = radioButtons("phq2Q2YesNo", NULL, # no label
                             selected = character(0), # initially nothing selected
                             choices = c("Yes" = "y", "No" = "n")),
  phq2SubmitButton = actionButton("phq2SubmitButton", "Submit"),
  
  # - PHQ9 Form Controls
  # -- radioButtons: https://shiny.rstudio.com/reference/shiny/1.3.2/radioButtons.html
  # Q9 - Scores
  phq9Q1Score = radioButtons("phq9Q1Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q2Score = radioButtons("phq9Q2Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q3Score = radioButtons("phq9Q3Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q4Score = radioButtons("phq9Q4Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q5Score = radioButtons("phq9Q5Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q6Score = radioButtons("phq9Q6Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q7Score = radioButtons("phq9Q7Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q8Score = radioButtons("phq9Q8Score", NULL, selected = character(0), choices = freqChoices),
  phq9Q9Score = radioButtons("phq9Q9Score", NULL, selected = character(0), choices = freqChoices),
  
  # Q10 - Difficulty
  phq9Q10Score = radioButtons("phq9Q10Score", NULL, selected = character(0), 
                              choices = c("Not difficult at all" = "NotDifficult",
                                          "Somewhat difficult"   = "SomewhatDifficult",
                                          "Very difficult"       = "VeryDifficult",
                                          "Extremely difficult"  = "ExtremelyDifficult")),
  phq9SubmitButton = actionButton("phq9SubmitButton", "Submit"),
  
  # Tab: Feedback (Clinical Impressions)
  # - textAreaInput: https://shiny.rstudio.com/reference/shiny/1.3.2/textAreaInput.html
  feedbackTextarea = textAreaInput("feedbackTextarea", 
                                   "Your Feedback",  # NULL - no label
                                   width = "450px",
                                   height = "450px"),

  # - actionButton: https://shiny.rstudio.com/reference/shiny/1.3.2/actionButton.html
  feedbackButton = actionButton("feedbackButton", "Submit Your Feedback"),
  
  # <a class="list-group-item active"><span class="glyphicon glyphicon-exclamation-plus"></span>New Feedback</a>
  newFeedbackButton = actionLink("newFeedbackButton", "New Feedback", class="list-group-item", href = "#newFeedback"),
  
  # renders the rest of the <a /> tags from the previous Feeback
  previousFeedbackList = htmlOutput("previousFeedbackList"),
    
  # for rendering the list of notes and the existing feedbackPanel
  feedbackPanel = htmlOutput("feedbackPanel")
)
