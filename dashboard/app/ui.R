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

# Define the HTML template to inject all of the Shiny
# input and output objects into.  
#
# See https://shiny.rstudio.com/articles/templates.html for more info.

htmlTemplate("www/index.html",
  # NavBar Tab Buttons (actionLinks allow for Shinky reactivity)
  # TODO -  icon = NULL, ...)
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
  summaryPain = SummaryBoxOutput("summaryPain"),
  
  # Tab: Heart Rate (HR)
  plotHR = HRTimelineOutput("plotHR"),
  
  # Tab: Blood Pressure (BP)
  plotBP = BPTimelineOutput("plotBP"),
  
  # Tab: ECG
  plotECG = ECGTimelineOutput("plotECG"),

  # Tab: Risk
  plotRisk = htmlOutput("plotRisk"), # TBD - htmlwidget
  
  # Tab: Recommendations
  listRecommendations = htmlOutput("listRecommendations"),

  # Tab: Mood
  selectorMood = htmlOutput("selectorMood"),
  
  # Tab: Feedback
  logFeedback = htmlOutput("logFeedback")
)
