# Install Requirements for running Shiny UI for Consult

R packages you will have to install.  On the R console, run:

  > install.packages("shiny")
  > install.packages("shinyjs")
  > install.packages("htmlwidgets")
  > install.packages("jsonlite")
  > install.packages("httr")
  > install.packages("dplyr")
  > install.packages("tidyverse")
  > install.packages("anytime")
  > install.packages("humanize")
  > install.packages("devtools")

You will have to install the Consult package.  Run in R in the base of the repo:

  > library('devtools')
  > setwd('dashboard/packages/Consult')
  > devtools::install()

# Running the Consult Shiny UI Dashboard

When putting the UI Dashboard into production, edit the Environment variables
in the dashboard/run.R script, and then from the command-line, run:

  $ Rscript dashboard/run.R

In order to develop the UI Dashboard, then edit the dashboard/dev.R script.
You can either run the script from the command-line:

  $ Rscript dashboard/dev.R

Or (more handly) source the dev.R script from the R console in RStudio:
(you need to be in the dashboard directory):

  > source("dev.R")

# Configuration

The Consult Dashboard is configured with these Environment Variables.  They
can be edited in the run.R/dev.R script.  

## Message Passer Connectivity

### MESSAGE_PASSER_PROTOCOL

The URL protocol for the Message Passer.  

    MESSAGE_PASSER_PROTOCOL = "http://"

*REQUIRED* Part of the URL and to avoid defaulting to clear http.  App exits if
not set.

### MESSAGE_PASSER_URL

The hostname/url (minus the protocol) to be used to contact the Message Passer.

    MESSAGE_PASSER_URL = "ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005"

*REQUIRED* Part of the URL and to avoid defaulting to clear http. App exits if
not set.

### CURL_CA_BUNDLE

Used to verify that a URL exists using https://www.rdocumentation.org/packages/RCurl/versions/1.95-4.12/topics/url.exists.  At the moment not implemented.

Unset value: N/A, unimplemented.

## (Consult) Study Patient Set-up

### SHINYPROXY_USERNAME

This it is the Patient ID that is a key used throughout the system to identify
the patient.

Here is the example USERNAME used during development of a simulated patient:

    SHINYPROXY_USERNAME = "3e2dab80-b847-11e9-8e30-f5388ac63e8b"

*REQUIRED* Value, if unset, then dashboard does not start.

### STUDY_START_TIMESTAMP

The date that the Patient that the patient starts using the Consult Dashboard.
This is inclusive of the Trial Period.  

Format is "%Y-%m-%d %H:%M:%S".

Example:
  STUDY_START_TIMESTAMP = "2016-12-31 00:00:00",

Unset value: Will default to the start-time of the Dashboard App.

### STUDY_END_TIMESTAMP

The date that the Patient that the patient starts using the Consult Dashboard.
This is inclusive of the Trial Period.

Format is "%Y-%m-%d %H:%M:%S".

Example:
  STUDY_END_TIMESTAMP = "2020-02-28 00:00:00",

Unset value: {STUDY_START_TIMESTAMP + 17 Days} Will default to 17 Days from the
start-time of the Dashboard App.

### STUDY_TRIAL_PERIOD_DAYS

Length of the trial period in days.  These are always at the beginning of the
study for the patient.

Unset value: "3" Will default to 3 Days.

### STUDY_CHATBOT_ACTIVE

"1" - Chatbot is Active
"0" - Chatbot is not Active

Note that you will have to restart the server in order to switch the chatbot
is active flag.  Alternatively adding more System Environment Variables will
work.

Unset value: "0"

## PHQ 2/9 Form Logic

### STUDY_PHQ_DAYS_FREQ

Days since the previous PHQ form submission that need to elapse before the
next PHQ form is shown on the Mood tab.

Unset value: "21" The form is shown 21 days since the last PHQ form.

## UI Configuration

### DEBUG_PANEL

Show the Debug Panels at the bottom of the Dashboard's Tabs.

  DEBUG_PANEL = "1"

Hide the Debug Panel by specifying a value of "0" or not defining the
environment variable.

Unset value: "0"

### ACTIVE_TABS

Specify the main Tabs that are enabled in the interfaced.  Enabled tabs are shown,
disabled tabs are not shown.

To enable a tab, include it in a comma-separated list.  Note that the order of
the tabs does not matter.

Tab Value | What is it
--------- | ----------
summary | Summary (Home) Tab
bp | Blood Pressure plot
hr | Heart Rate plot
ecg | ECG plot
mood | Mood Grid and PHQ2/9 forms
risk | Risk Graphics  
recommendations | Recommendations (Tips)
feedback | Feedback Tab

Unset value: "summary,bp,hr,ecg,mood,risk,recommendations,feedback"

### RANDOMIZE_RECOMMENDATIONS

If value is "1" , then randomize the order of recommendations.

Unset value: "0"

### USE_SAMPLE_DATA

If value is "1", then load static sample data from the sample-data/ directory
to demonstrate the app.

Unset value: "0"

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
