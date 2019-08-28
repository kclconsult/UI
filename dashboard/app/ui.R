# CONSULT Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the user-interface definition of a Shiny web application. 
#
# The Dashboard is run via either dashboard/run.R or dashboard/dev.R.
# If you are in RStudio, source the dev.R file to run the app:
# 
#   > source("dashaboard/dev.R")
#
# Using the "Run App" button in RStudio will make the Dashboard run,
# but none of the System Environment Variables will be confiured.
#
# Shiny evaluates ui.R *before* server.R.  All supporting code modules
# are sourced from ui.R.
#

library(shiny)
library(shinyjs) # JS add-ons

library(jsonlite)


# Shiny Options
# See: https://rdrr.io/cran/shiny/man/shiny-options.html
# options(
#   shiny.launch.browser = TRUE,
#   shiny.trace = TRUE,
#   shiny.minified = FALSE # use un-minified shiny.js
# )

# local package which provides htmlwidgets.
library(Consult)

# local modules
source("version.R")
source("components.R")
source("services.R")
source("data.R")

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
  antiPlateletIntervention = actionLink("antiPlateletIntervention", "Used Antiplatelet" , href = "#antiplatelet", `data-toggle` = "pill"),
  # - baseline/risk plots
  baselineRiskPlot = imageOutput("baselineRiskPlot", width = "100%", height = "400px"),
  interventionRiskPlot = imageOutput("interventionRiskPlot", width = "100%", height = "400px"),
  
  # Tab: Recommendations
  listRecommendations = htmlOutput("listRecommendations"),

  # Tab: Mood

  # - Mood Grid Selection Actions
  emotionLinkAfraid     = htmlOutput("emotionLinkAfraid"),
  emotionLinkTense      = htmlOutput("emotionLinkTense"),
  emotionLinkExcited    = htmlOutput("emotionLinkExcited"),
  emotionLinkDelighted  = htmlOutput("emotionLinkDelighted"),
  emotionLinkFrustrated = htmlOutput("emotionLinkFrustrated"),
  emotionLinkAngry      = htmlOutput("emotionLinkAngry"),
  emotionLinkHappy      = htmlOutput("emotionLinkHappy"),
  emotionLinkGlad       = htmlOutput("emotionLinkGlad"),
  emotionLinkMiserable  = htmlOutput("emotionLinkMiserable"),
  emotionLinkSad        = htmlOutput("emotionLinkSad"),
  emotionLinkCalm       = htmlOutput("emotionLinkCalm"),
  emotionLinkSatisfied  = htmlOutput("emotionLinkSatisfied"),
  emotionLinkGloomy     = htmlOutput("emotionLinkGloomy"),
  emotionLinkTired      = htmlOutput("emotionLinkTired"),
  emotionLinkSleepy     = htmlOutput("emotionLinkSleepy"),
  emotionLinkSerene     = htmlOutput("emotionLinkSerene"),
  
  # - Selected Mood Display and Confirmations
  selectedMoodImage = imageOutput("selectedMoodImage", width = "auto", height = "auto"),
  selectedMoodImageYesButton =  actionButton("selectedMoodImageYesButton", "Yes", class="btn btn-default btn-lg"),
  selectedMoodImageNoButton =  actionButton("selectedMoodImageNoButton", "No", class="btn btn-danger btn-lg"),
  
  # - PHQ2 Form Controls
  # -- radioButtons: https://shiny.rstudio.com/reference/shiny/1.3.2/radioButtons.html
  phq2Q1YesNo = radioButtons("phq2Q1YesNo", NULL, # no label
                             selected = character(0), # initially nothing selected
                             choices = c("Yes" = "1", "No" = "0")),
  phq2Q2YesNo = radioButtons("phq2Q2YesNo", NULL, # no label
                             selected = character(0), # initially nothing selected
                             choices = c("Yes" = "1", "No" = "0")),
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
  newFeedbackButton = actionButton("newFeedbackButton", "Create New Feedback"),
  
  # renders the rest of the <a /> tags from the previous Feeback
  previousFeedbackList = htmlOutput("previousFeedbackList"),
    
  # for rendering the list of notes and the existing feedbackPanel
  feedbackPanel = htmlOutput("feedbackPanel")
) # ui function
