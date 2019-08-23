# Install Requirements for running Shiny UI for Consult

R packages you will have to install.  On the R console, run:

    > install.packages("jsonlite")
    > install.packages("htmlwidgets")
    > install.packages("httr")

Then you will have to install any packages written for this app.

ALSO NEED:
    > install.packages("shinyjs")

# Running the Consult Shiny UI Dashboard

$ Rscript dashboard/run.R

# Configuration

The Consult Dashboard is configured with these Environment Variables.  They
can be edited in the run.R script.

Environment Variables:

MESSAGE_PASSER_PROTOCOL="http://",
MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005",
CURL_CA_BUNDLE=""
SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b",

CONSULT_DEBUG
CONSULT_ACTIVE_TABS
CONSULT_PHQ_DAYS_FREQ

# File Manifest (TODO - NEEDS Updating)

    packages/  <- contains separate R packages which contain htmlwidgets and other library code
          Consult/  <- R package containing htmlwidget for C3 charts
    app/       <- the Shiny application
          ui.R         <- Shiny's ui function definition
          server.R     <- Shiny's server function definition
          components.R <- render functions for reactive HTML blocks of code (defined in R)
          services.R   <- functions to support loading data
          www/
              template.html    <- HTML file loaded by ui.R
              consultStyle.css <- CSS file referenced by template.html
          sample-data/         <- sample CSV files for data that is provided by Consult backend services

# Development Notes

## Defining an R package and htmlwidget

You will need the R package devtools:

    > install.packages("devtools")

Following https://shiny.rstudio.com/articles/js-build-widget.html notes.
In the R Console, change the working directory to the packages dir:

    > setwd("~git/ui/dashboard/packages")

Note: devtools:create no longer exists, usethis package created to support these functions (RStudio might open in a new project):

    > library(usethis)
    > create_package("Consult")

Navigate to package dir

    > setwd("Consult")       

Create widget scaffolding

    > library(htmlwidgets)
    > scaffoldWidget("HRTimeline", edit = FALSE)

    Created boilerplate for widget constructor R/HRTimeline.R
    Created boilerplate for widget dependencies at inst/htmlwidgets/HRTimeline.yaml
    Created boilerplate for widget javascript bindings at inst/htmlwidgets/HRTimeline.js

    > scaffoldWidget("BPTimeline", edit = FALSE)

    Created boilerplate for widget constructor R/BPTimeline.R
    Created boilerplate for widget dependencies at inst/htmlwidgets/BPTimeline.yaml
    Created boilerplate for widget javascript bindings at inst/htmlwidgets/BPTimeline.js

    > scaffoldWidget("ECGTimeline", edit = FALSE)

    Created boilerplate for widget constructor R/ECGTimeline.R
    Created boilerplate for widget dependencies at inst/htmlwidgets/ECGTimeline.yaml
    Created boilerplate for widget javascript bindings at inst/htmlwidgets/ECGTimeline.js

Edit the files, and then install package before you test it:
    > devtools::install()

## Target Device Size
Samsung Tablet: SM-T585

## Existing UI Dashboard
https://consultproject.co.uk/ui/login

## Chat login
https://consultproject.co.uk/chat/login

## Running on server

$ Rscript dashboard/run.R

In dashboard/run.R:

Sys.setenv(MESSAGE_PASSER_PROTOCOL="http://", MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005", SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b", CURL_CA_BUNDLE="")

library(shiny)

library(devtools)
setwd("dashboard/packages/Consult")
devtools::install()

setwd("../..")
runApp(appDir="app", host="0.0.0.0", port=5369)

View at:
http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:5369

Demo Observation Requests

ECG
http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/131328/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z

BP
WORKS: http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/85354-9/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z
http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/85354-9/2017-01-01T00:00:00Z/2017-02-01T00:00:00Z


http://ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005/Observation/3e2dab80-b847-11e9-8e30-f5388ac63e8b/85354-9/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z
