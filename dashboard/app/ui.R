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
library(C3)

## ui.R ##

# Define the HTML template to inject all of the Shiny
# input and output objects into.  
#
# See https://shiny.rstudio.com/articles/templates.html for more info.

htmlTemplate("www/index.html",
  # Tab: Summary
  # - time range selectors (TODO change from actionButtons to tabbed selector)
  selectLastFourHours = actionButton("selectLastFourHours", "Last 4 Hours"),
  selectLastDay = actionButton("selectLastDay", "Last 24 Hours"),
  selectLastMonth = actionButton("selectLastMonth", "Last Month"),

  # - summary boxes (TODO widgetize for more custom styling)
  summaryBP = htmlOutput("summaryBP"),
  summaryHR = htmlOutput("summaryHR"),
  summaryECG = htmlOutput("summaryECG"),
  summaryMood = htmlOutput("summaryMood"),
  summaryPain  = htmlOutput("summaryPain"),
  
  # Tab: Heart Rate (HR)
  plotHR = C3TimelineOutput("plotHR"),
  
  # Tab: Blood Pressure (BP)
  plotBP = C3TimelineOutput("plotBP"),
  
  # Tab: ECG
  plotECG = C3TimelineOutput("plotECG"),

  # Tab: Risk
  plotRisk = htmlOutput("summaryBP"), # TBD - htmlwidget
  
  # Tab: Recommendations
  listRecommendations = htmlOutput("listRecommendations"),
  
  # Tab: FAQ
  listFAQ = htmlOutput("listFAQ"),
  
  # Tab: Medication
  summaryMeds = htmlOutput("summaryMeds"),
  
  # Tab: Mood
  selectorMood = htmlOutput("selectorMood"),
  
  # Tab: Feedback
  logFeedback = htmlOutput("logFeedback")
)
