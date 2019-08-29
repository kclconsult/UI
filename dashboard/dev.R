# Development environment variables


Sys.setenv(
  # REQUIRED: 
  # - Consult Patient ID
  SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b", 
  # - Message Passer Paramters
  MESSAGE_PASSER_PROTOCOL="http://", 
  MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005", 
  # Not Implemented:
  CURL_CA_BUNDLE="",
  # Study Parameters
  # STUDY_START_TIMESTAMP = "",
  # STUDY_END_TIMESTAMP = "",
  # STUDY_TRIAL_PERIOD_DAYS = "",
  # STUDY_CHATBOT_ACTIVE = "0",
  PHQ_DAYS_FREQ = "1", # everyday
  #
  RANDOMIZE_RECOMMENDATIONS = "0",
  USE_SAMPLE_DATA = "0",
  # UI
  # ACTIVE_TABS
  DEBUG_PANEL="1"
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
# library('devtools')
# setwd('dashboard/packages/Consult')
# devtools::install()
# setwd('../..')

# runs app/ directory
# runApp(appDir="app", host="0.0.0.0", port=5369)
runApp("app")
