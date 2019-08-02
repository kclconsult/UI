# Set-up for running the UI Sandbox

R packages you will have to install.  On the R console, run:

    > install.packages("jsonlite")
    > install.packages("htmlwidgets")
    > install.packages("httr")

Then you will have to install any packages written for this app.

Install the C3 package:

    > setwd("packages/C3")
    > install()

# File Manifest

    packages/  <- contains separate R packages which contain htmlwidgets and other library code
          C3/  <- R package containing htmlwidget for C3 charts
    app/       <- the Shiny application
          ui.R         <- Shiny's ui function definition
          server.R     <- Shiny's server function definition
          components.R <- render functions for reactive HTML blocks of code (defined in R)
          services.R   <- functions to support loading data
          www/
              template.html    <- HTML file loaded by ui.R
              consultStyle.css <- CSS file referenced by template.html
          sample-data/         <- sample CSV files for data that is provided by Consult backend services

# Background

Shiny provides a few different patterns for developing a HTML/JS front-end for use with it's back-end server.

1. Fully R defined UI using ui.R or creating the ui object in app.R. (https://shiny.rstudio.com/articles/html-tags.html
2. Fully-defining the UI with HTML (loading an HTML file from the public www/ directory) (https://shiny.rstudio.com/articles/html-ui.html)
3. Mixed-use of defining the UI with an HTML template, but embedding shiny objects within the HTML template. (https://shiny.rstudio.com/articles/templates.html)

For this demo, I am using option 3 which is a mixed-up use of using HTML to define the page structure while also embedding desired Shiny objects with are interoperable with the Shiny backend.

## Shiny's Reactive Pattern

Shiny follows a reactive pattern. Communication from the UI Client are via "changed value" events, which are observed via functions within the server object (in server.R or app.R).  Shiny communicates back the client by writing to the output object, which then re-rendered a specific portion of the HTML page which that object is responsible for.  More details of this pattern are here (https://shiny.rstudio.com/articles/reactivity-overview.html).

## Sandbox Contents

The structure of the page is defined in app/www/template.html.  Here is an overview for each panel on the page:

### Demonstrating Client-Server Interactivity

Here an actionButton and slider are created using Shiny's components and they demonstrate passing data from the UI to the backend and back again to the UI.

The outputs for both of these controls are defined in components.R as separate render functions.  This shows that one can componentize aspects of the interface into separate functions in the Shiny framework.

### Demonstrate Text Input->Output

This shows passing text data to implement the Recommendations portion of the CONSULT web app.  While it's responsive to typing text in the textarea, the text that shows up could be from a backend Consult Service.

### Demonstrate HTML Widget (C3 Gauge)

This demonstrates creating htmlwidgets with an external javascript library (C3/D3) which allows for better client-side interactivity (https://shiny.rstudio.com/articles/js-build-widget.html)

It also demonstrates how structured data can be passed back to the UI to support the health indicators portion of the CONSULT web app.

### Demonstrate HTML Widget (C3 Timeline) with Random Data

Here a C3 Line graph demonstrates plotting timeline data.

### Demonstrate Sample Data

Here the same C3 widget that was used before is used to plot project sample-data.  The data is loaded on the server from a CSV file, but it could have been consumed from a backend service.

### Integrating the mattermost

To be decided.  Mattermost could be integrated in one of two ways.

1. Take the existing mattermost-webapp (https://github.com/mattermost/mattermost-webapp/tree/master/components) and strip it down to a single chat window with a specific bot (i.e. Connie).

2. Take the mattermost-redux chat client and build up a custom chat JS widget.

# Development Notes

## Defining an R package and htmlwidget

You will need the R package devtools:

    > install.packages("devtools")

Following https://shiny.rstudio.com/articles/js-build-widget.html notes.
In the R Console, change the working directory to the packages dir:

    > setwd("~git/UI-sandbox/packages")

Note: devtools:create no longer exists, usethis package creaated to support these functions (RStudio might open in a new project):

    > library(usethis)
    > create_package("C3")

Navigate to package dir

    > setwd("C3")       

Create widget scaffolding

    > library(htmlwidgets)
    > scaffoldWidget("C3Gauge", edit = FALSE)

    Created boilerplate for widget constructor R/C3Gauge.R
    Created boilerplate for widget dependencies at inst/htmlwidgets/C3Gauge.yaml
    Created boilerplate for widget javascript bindings at inst/htmlwidgets/C3Gauge.js

Edit the files, and then install package before you text it:
    > install()  

## Target Device Size
Samsung Tablet: SM-T585

## Existing UI Dashboard
https://consultproject.co.uk/ui/login

## Chat login
https://consultproject.co.uk/chat/login
