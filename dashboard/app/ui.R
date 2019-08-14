# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above (if you are working with this in RStudio)
#

library(shiny)

# local htmlwidgets
library(Consult)

## ui.R ##
#
# Define the HTML template to inject all of the Shiny
# input and output objects into.  
#
# See https://shiny.rstudio.com/articles/templates.html for more info.

htmlTemplate("www/index.html",
  # Version String
  versionString = textOutput("versionString", inline=TRUE),
  
  # NavBar Tab Buttons (actionLinks allow for Shiny reactivity)
  # - 
  # <a href="#summary" data-toggle="tab">Summary</a>
  tabSummaryLink = actionLink("tabSummaryLink", "Summary", href = "#summary", `data-toggle` = "tab"),
  # <a href="#hr" data-toggle="tab">Heart Rate</a>
  tabHRLink = actionLink("tabHRLink", "Heart Rate", href = "#hr", `data-toggle` = "tab"),
  # <a href="#bp" data-toggle="tab">Blood Pressure</a>
  tabBPLink = actionLink("tabBPLink", "Blood Pressure", href = "#bp", `data-toggle` = "tab"),
  # <a href="#ecg" data-toggle="tab">ECG</a>
  tabECGLink = actionLink("tabECGLink", "ECG", href = "#ecg", `data-toggle` = "tab"),
  # <a href="#risk" data-toggle="tab">Risk</a>
  tabRiskLink = actionLink("tabRiskLink", "Risk", href = "#risk", `data-toggle` = "tab"),
  # <a href="#recommendations" data-toggle="tab">Recommendations</a>
  tabRecommendationsLink = actionLink("tabRecommendationsLink", "Recommendations", href = "#recommendations", `data-toggle` = "tab"),
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
  debugSelectMoodImage = selectInput("debugSelectMoodImage", "Select Mood Image", c("good" = "images/summary/mood-good.png", 
                                                                                    "meh"  = "images/summary/mood-meh.png", 
                                                                                    "bad"  = "images/summary/mood-bad.png")),
  
  # Tab: Heart Rate (HR)
  plotHR = HRTimelineOutput("plotHR"),
  
  # Tab: Blood Pressure (BP)
  plotBP = BPTimelineOutput("plotBP"),
  
  # Tab: ECG
  plotECG = ECGTimelineOutput("plotECG"),

  # Tab: Risk
  selectIntervention = selectInput("selectIntervention", "", 
                                   c("Stop Smoking" = "images/interventions/stop-smoking.png", 
                                     "Lower Blood Pressure" = "images/interventions/lower-bp.png", 
                                     "Lower Cholesterol" = "images/interventions/lower-cholesterol.png",
                                     "Anti-Platelet" = "images/interventions/antiplatelet.png")),
  
  interventionRiskPlot = imageOutput("interventionRiskPlot", width = "100%", height = "400px"),
  
  # Tab: Recommendations
  listRecommendations = htmlOutput("listRecommendations"),

  # Tab: Mood
  selectorMood = htmlOutput("selectorMood"),
  # - Mood Selection Actions
  emotionLinkTired = actionLink("emotionLinkTired",
    tags$img(src = "images/emotions/tired.jpg", width = "100%", height = "100%")),
  emotionLinkTense = actionLink("emotionLinkTense",         
    tags$img(src = "images/emotions/tense.jpg", width = "100%", height = "100%")),
  emotionLinkSleepy = actionLink("emotionLinkSleepy",       
    tags$img(src = "images/emotions/sleepy.jpg", width = "100%", height = "100%")),
  emotionLinkSerene = actionLink("emotionLinkSerene",       
    tags$img(src = "images/emotions/serene.jpg", width = "100%", height = "100%")),
  emotionLinkSatisfied = actionLink("emotionLinkSatisfied", 
    tags$img(src = "images/emotions/satisfied.jpg", width = "100%", height = "100%")),
  emotionLinkSad = actionLink("emotionLinkSad",             
    tags$img(src = "images/emotions/sad.jpg", width = "100%", height = "100%")),
  emotionLinkMiserable = actionLink("emotionLinkMiserable", 
    tags$img(src = "images/emotions/miserable.jpg", width = "100%", height = "100%")),
  emotionLinkHappy = actionLink("emotionLinkHappy",         
    tags$img(src = "images/emotions/happy.jpg", width = "100%", height = "100%")),
  emotionLinkGloomy = actionLink("emotionLinkGloomy",         
    tags$img(src = "images/emotions/gloomy.jpg", width = "100%", height = "100%")),
  emotionLinkGlad = actionLink("emotionLinkGlad",             
    tags$img(src = "images/emotions/glad.jpg", width = "100%", height = "100%")),
  emotionLinkFrustrated = actionLink("emotionLinkFrustrated", 
    tags$img(src = "images/emotions/frustrated.jpg", width = "100%", height = "100%")),
  emotionLinkExcited = actionLink("emotionLinkExcited",       
    tags$img(src = "images/emotions/excited.jpg", width = "100%", height = "100%")),
  emotionLinkDelighted = actionLink("emotionLinkDelighted",   
    tags$img(src = "images/emotions/delighted.jpg", width = "100%", height = "100%")),
  emotionLinkCalm = actionLink("emotionLinkCalm",             
    tags$img(src = "images/emotions/calm.jpg", width = "100%", height = "100%")),
  emotionLinkAngry = actionLink("emotionLinkAngry",           
    tags$img(src = "images/emotions/angry.jpg", width = "100%", height = "100%")),
  emotionLinkAfraid = actionLink("emotionLinkAfraid",       
    tags$img(src = "images/emotions/afraid.jpg", width = "100%", height = "100%")),
  
  # Tab: Feedback (Clinical Impressions)
  # - textAreaInput: https://shiny.rstudio.com/reference/shiny/1.3.2/textAreaInput.html
  feedbackTextarea = textAreaInput("feedbackTextarea", 
                                   "Your Feedback",  # NULL - no label
                                   width = "1000px",
                                   height = "400px"),

  # - actionButton: https://shiny.rstudio.com/reference/shiny/1.3.2/actionButton.html
  feedbackButton = actionButton("feedbackButton", "Submit Your Feedback")
)
