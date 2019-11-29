# Development environment variables

Sys.setenv(
  # REQUIRED:
  # - Consult Patient ID
  SHINYPROXY_USERNAME="2c13a0d0-0f22-11ea-a6a7-e546232dc1c4",
  # - Message Passer Paramters
  MESSAGE_PASSER_PROTOCOL="http://",
  MESSAGE_PASSER_URL="localhost:3005",
  # Not Implemented:
  CURL_CA_BUNDLE="",
  # Study Parameters
  # - start and end time contain the Simualtion Patient Data
  STUDY_START_TIMESTAMP = "2016-12-31 00:00:00",
  STUDY_END_TIMESTAMP = "2020-02-28 00:00:00",
  STUDY_TRIAL_PERIOD_DAYS = "3",
  STUDY_CHATBOT_ACTIVE = "0",
  STUDY_PHQ_DAYS_FREQ = "1", # everyday
  RANDOMIZE_RECOMMENDATIONS = "0",
  USE_SAMPLE_DATA = "0",
  # USE_SAMPLE_DATA = "1",
  # UI - all tabs
  ACTIVE_TABS = "summary,bp,hr,ecg,mood,risk,recommendations,feedback",
  DEBUG_PANEL="1" # enable debug
)

# Load Shiny to run app
library('shiny')

# Shiny Options
# See: https://rdrr.io/cran/shiny/man/shiny-options.html
options(
  shiny.launch.browser = TRUE,
  shiny.trace = TRUE,
  shiny.minified = FALSE # use un-minified shiny.js
)

# install packages
#library('devtools')
#setwd('packages/Consult')
#devtools::install()
#setwd('../..')

# runs app/ directory
# runApp(appDir="app", host="0.0.0.0", port=5369)
runApp("app")
