# Production environment variables

Sys.setenv(
  # REQUIRED:
  SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b",
  MESSAGE_PASSER_PROTOCOL="http://",
  MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005",

  # Not Implemented:
  CURL_CA_BUNDLE="",

  # Study Parameters

  # (Allow for defaults)
  # Start time Defaults to NOW
  STUDY_START_TIMESTAMP = "2019-09-03 17:07:47 BST", # Temporary start
  # End time Defaults to 17 days from NOW
  STUDY_END_TIMESTAMP = "2020-09-03 17:07:47 BST", # Temporary end

  # Default is 3
  STUDY_TRIAL_PERIOD_DAYS = "3",

  # Disable Chatbot
  STUDY_CHATBOT_ACTIVE = "0",

  # every 21 days
  STUDY_PHQ_DAYS_FREQ = "21",

  # Do not randomize Recommendations
  RANDOMIZE_RECOMMENDATIONS = "0",

  # Use API for data
  USE_SAMPLE_DATA = "0",
  # UI - omit risk and recommendations tabs
  ACTIVE_TABS = "summary,bp,hr,ecg,mood,feedback",

  # No visiable debug panel
  DEBUG_PANEL="0"
)

# Load Shiny to run app
library('shiny')

# install packages
library('devtools')
setwd('dashboard/packages/Consult')
devtools::install()
setwd('../..')

# runs app/ directory
runApp(appDir="app", host="0.0.0.0", port=5369)
