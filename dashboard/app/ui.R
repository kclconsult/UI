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

htmlTemplate("www/template.html",

  # htmlTemplate takes a mamed arguement list where the arguements are 
  # referenced in the HTML template.  
  #
  # For example:
  #   button = actionButton("actionBtn", "Action"),
  #
  # In template.html, 'button' is inserted in double brackets:
  #    {{ button }}
  #
  # And in the server function, it is referenced through the "actionBtn" id.
  # In this case, since an actionButton is an input, it would be referenced
  # as "input$actionBtn" (as part of the input object)
  #
  # Attributes can be either input controls that need to communcate to the server.
  # Or they can be Output objects, where ther server updates portions of the HTML:
  #
  # Types of output:
  # - dataTableOutput()
  # - imageOutput()
  # - tableOutput()
  # - uiOutput()
  # - htmlOutput()
  # - plotOutput()
  # - textOutput()
  # - verbatimTextOutput()

  # Inputs and Outputs are organised in the order they appear on the page:
  
  # Demonstrating Client-Server Interactivity
  button = actionButton("actionBtn", "Action"),
  buttonHTML = htmlOutput("buttonHTML"),
  # --  
  slider = sliderInput("sliderX", "Slider Input X", 1, 100, 50),
  sliderProgressHTML = htmlOutput("sliderProgressHTML"),
  
  # Demonstrate Text Input->Output
  textarea = textAreaInput("exampleText", "Enter recommendations here"),
  recommendationsText = textOutput("recommendationsText"),
  
  # Demonstrate HTML Widget (C3 Gauge)
  updateButton = actionButton("updateBtn", "Update Gauge"),
  gaugeWidget = C3GaugeOutput("gauge1"),
  
  # Demonstrate HTML Widget (C3 Timeline) with Random Data
  refreshDataButton = actionButton("refreshDataButton", "Refresh Data"),
  timelineWidget = C3TimelineOutput("timeline1"),
  
  # Demonstrate Sample Data
  moreDataButton = actionButton("moreDataButton", "More Data"),
  sampleTimelineWidget = C3TimelineOutput("timeline2")
  
)
