# CONSULT UI Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: Aug 2019
#
# Loads the System Environment Variables and defines
# unset default values.
#

print("Loading System Environment Variables")
print("------------------------------------")

getEnv <- function(varName, default=NA, required=FALSE, asBool=FALSE) {
  value = Sys.getenv(varName, unset=default)
  if(required) { # *REQUIRED*
    if(is.na(required)) {
      print("****************************************************************************")
      print(paste(varName, " is unset!  Required Env Variable, stopping app!"))
      print("****************************************************************************")
      stopApp() # stops the Shiny App
    }
  }
  print(paste(varName,"=",value))
  if(asBool) { # treat as bool: "1" = TRUE, "0" = FALSE
    if(value == "1") {
      print("-> interpreting as Boolean: TRUE")
      return(TRUE)
    } else if(value == "0") {
      print("-> interpreting as Boolean: FALSE")
      return(FALSE)
    }
  }
  value
}

# Username (also patient ID) provided by SHINYPROXY
# - aka Patient ID
SHINYPROXY_USERNAME = getEnv("SHINYPROXY_USERNAME", required=TRUE)
USERNAME_PATIENT_ID = SHINYPROXY_USERNAME

# Environment Variables Specific to the services

# - protocol
MESSAGE_PASSER_PROTOCOL = getEnv("MESSAGE_PASSER_PROTOCOL", required=TRUE)

# - MESSAGE_PASSER_URL is actually just the HOST name
MESSAGE_PASSER_URL = getEnv("MESSAGE_PASSER_URL", required=TRUE)

# Message Passer complete URL = PROTOCOL + HOST 
MP_URL = paste(MESSAGE_PASSER_PROTOCOL, MESSAGE_PASSER_URL, sep = "")
print(paste("Setting MP_URL =", MP_URL))

# - certificate authority (Not Implemented)
CA_BUNDLE = getEnv("CURL_CA_BUNDLE", default="")

# Study Parameters
STUDY_START_TIMESTAMP = getEnv("STUDY_START_TIMESTAMP", default=Sys.time())
STUDY_END_TIMESTAMP = getEnv("STUDY_END_TIMESTAMP", default=Sys.time() + as.difftime(17, units="days"))
STUDY_TRIAL_PERIOD_DAYS = getEnv("STUDY_TRIAL_PERIOD_DAYS", default="3")
STUDY_CHATBOT_ACTIVE = getEnv("STUDY_CHATBOT_ACTIVE", default="0", asBool=TRUE)
STUDY_PHQ_DAYS_FREQ =  getEnv("STUDY_PHQ_DAYS_FREQ", default="21")

# UI Vars
DEBUG_PANEL = getEnv("DEBUG_PANEL", default="0", asBool=TRUE)
RANDOMIZE_RECOMMENDATIONS =  getEnv("RANDOMIZE_RECOMMENDATIONS", default="0", asBool=TRUE)
USE_SAMPLE_DATA = getEnv("USE_SAMPLE_DATA", default="0", asBool=TRUE)
ACTIVE_TABS = getEnv("ACTIVE_TABS", default="summary,bp,hr,ecg,mood,risk,tips,feedback")

# Done loading
print("------------------------------------")
