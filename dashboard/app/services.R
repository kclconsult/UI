# CONSULT Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is a module for abstracting out other CONSULT services.
#

library(httr) # R http lib, see https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html

# install.packages("tidyverse")
#  provides functions such as 'read_delim'
library(tidyverse) 

# install.packages("anytime")
# converts POSIX times to strings
library(anytime)

# Environment Variables Specific to the services

# TODO - remove these
Sys.setenv(MESSAGE_PASSER_PROTOCOL="http://", 
           MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005", 
           SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b", 
           CURL_CA_BUNDLE="")

# - message passer specifics
MP_PROTOCOL = Sys.getenv("MESSAGE_PASSER_PROTOCOL")
MP_HOST = Sys.getenv("MESSAGE_PASSER_URL")
MP_URL = paste(MP_PROTOCOL, MP_HOST, sep = "")

# - certificate authoritys
CA_BUNDLE = Sys.getenv("CURL_CA_BUNDLE")

# - username (also patient ID) provided by SHINYPROXY
USERNAME_PATIENT_ID = Sys.getenv("SHINYPROXY_USERNAME")

#
# Message Passer API 
#
# https://github.kcl.ac.uk/pages/consult/message-passer/
#

effectiveDateTime <- function(t = Sys.time()) {
  # String representation of timestamp for Message Passer API
  #
  # Args:
  #   t - (double) R timestamp, defaults to current time
  #
  # Returns:
  #   String repr of timestamp
  strftime(t, "%Y-%m-%dT%H:%M:%SZ")
}

#
# Observation Data (GET)
#

getObservations <- function(code, startTimestamp, endTimestamp) {
  # Gets Observations for a patient based on codes (i.e. Blood pressure: 85354-9)
  # 
  # GET Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-Observations-GetObservations)
  #
  # Args:
  #   code: The code of the observation being requested (e.g. Blood pressure: 85354-9).
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2020-02-28T00:00:00Z).
  #
  # Returns:
  #   Table of (raw) Observation Data from the Message Passer Service

  # TODO - validate input parameters
  # patientID is valid
  # code is valie
  # startTimestamp < endTimestamp

  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "Observation", 
                      USERNAME_PATIENT_ID, 
                      code,
                      startTimestamp,
                      endTimestamp,
                      sep = "/")
  # DEBUG url
  print(paste("getObservations:", requestUrl))
  
  # Validate URL with Certificate Authority
  # if(!url.exists(requestUrl, cainfo=CA_BUNDLE)) { # invalid
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Read.table handles HTTP GET request
  data <- read.table(requestUrl, header = TRUE)
    
  # Stop measuring call
  end_time = Sys.time()

  # DEBUG timing
  print(end_time - start_time)

  return(data)
}

#
# QuestionnaireResponses Data (GET)
#

getQuestionnaireResponses <- function(startTimestamp, endTimestamp) {
  # Gets QuestionnaireResponses for a patient for a particular time period
  #
  # GET Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-GetQuestionnaireResponses)
  #
  # Args:
  #   startTimestamp: The start time of the range of responses to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of responses to look for, as full timestamp (e.g. 2020-02-28T00:00:00Z).
  #
  # Returns:
  #   Table of (raw) QuestionnaireReponses Data from the Message Passer Service

  # TODO - validate input parameters
  # patientID is valid
  # startTimestamp < endTimestamp

  # Build the Message Passer request URL
  requestUrl <- paste( MP_URL,
                       "QuestionnaireResponse",
                       USERNAME_PATIENT_ID,
                       startTimestamp,
                       endTimestamp,
                       sep = "/" )
  # DEBUG url
  print( paste( "getQuestionnaireResponses:", requestUrl ))

  # Validate URL with Certificate Authority
  # if ( ! url.exists( requestUrl, cainfo=CA_BUNDLE )) { # invalid

  # Start measuring call
  start_time = Sys.time()

  # Read.table handles HTTP GET request
  data <- read.table( requestUrl, header=TRUE )

  # Stop measuring call
  end_time = Sys.time()

  # DEBUG timing
  print( end_time - start_time )

  return( data )
}



#
# QuestionnaireResponses POST
#


validateKeysInList <- function(k, l, context="") {
  # Validates that keys k are present in list l
  #
  # Side-effect, prints warning statement with context string.
  #
  # Returns:
  #    TRUE - if all keys are present, FALSE otherwise
  
  # set of matching question score parameters
  matching = intersect(k, names(l))
  
  # check if all of the questionScores are present
  if(!setequal(k, matching)) {
    warning(paste(context, "-- missing keys:", setdiff(k, matching)))
    return(FALSE)
  }
  return(TRUE)
}

sendQuestionnaireResponses <- function(screening, scores=NULL, difficulty=NULL) {
  # Sends the Questionnaire Response form answers.
  #
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-QuestionnaireResponses-Add
  #
  # Args:
  #   screening: PHQ2 screening responses for Q1 and Q2
  #   scores: (optional) PHQ9 scores for Q1-9
  #   difficulty: (optional) String of PHQ9 Q10 answer
  #
  # Returns:
  #   TRUE if sucessful status code (FALSE otherwise)
  #
  # sklar/21-aug-2019: modified to include PHQ2 scores (yes=1,no=0)
  # added two fields: FeelingDownInitial and LittleInterestInitial
  # note that when sending data here, we have to populate every field,
  #  which is what the database on the backend expects. So use "-" for
  #  scores in PHQ9 if they are not used.
  #
  # chipp/22-aug-2019: PHQ2 ordering of Q1 and Q2 parameters were switched
  # from what is presenting in message passer API documentation.
  # "FeelingDownInitial" question is *before* LittleInterestInitial question

  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "QuestionnaireResponse", 
                      "add",
                      sep = "/")

  # DEBUG url
  print(paste("sendQuestionnaireResponses:", requestUrl))
  
  # POST parameters data structure with default values:
  body = list(
    "subjectReference" = USERNAME_PATIENT_ID, # Patient id
    "effectiveDateTime" = effectiveDateTime() # (optional) Client-side Timestamp of impression
  )

  # PHQ2 Q1-2 Screening Responses
  screeningResponses = c(
    "FeelingDownInitial",     # PHQ2 yes/no for FeelingDown(PHQ2.Q1)
    "LittleInterestInitial"   # PHQ2 yes/no for LittleInterest(PHQ2.Q2)
  )
  
  # PHQ9 Q1-9 Scores parameter names
  questionScores = c(
    "LittleInterest",        # PHQ9 score for LittleInterest (PHQ9.Q1)
    "FeelingDown",           # PHQ9 score for FeelingDown (PHQ9.Q2)
    "TroubleSleeping",       # PHQ9 score for TroubleSleeping (PHQ9.Q3)
    "FeelingTired",          # PHQ9 score for FeelingTired (PHQ9.Q4)
    "BadAppetite",           # PHQ9 score for BadAppetite (PHQ9.Q5)
    "FeelingBadAboutSelf",   # PHQ9 score for FeelingBadAboutSelf (PHQ9.Q6)
    "TroubleConcentrating",  # PHQ9 score for TroubleConcentrating (PHQ9.Q7)
    "MovingSpeaking", 	     # PHQ9 score for MovingSpeaking (PHQ9.Q8)
    "ThoughtsHurting"        # PHQ9 score for ThoughtsHurting (PHQ9.Q9)
  )
  
  # Check the Screening Responses are present
  if(!validateKeysInList(screeningResponses, screening, context="sendQuestionnaireResponses")) {
    return(FALSE)
  }

  # POST for screening (PHQ2) questions
  body = append(body, screening) # append screening 
  
    # Validate and send PHQ9 Form if either screening questions are "y"
  if((screening$LittleInterestInitial == "y") | (screening$FeelingDownInitial == "y")) {
  
    # check if all of the questionScores are present
    if(!validateKeysInList(questionScores, scores, context="sendQuestionnaireResponses")) {
      return(FALSE)
    }
    
    # validate values for questionScores and accumulate TotalScore
    totalScore = 0
    for(p in questionScores) {
      # Question scores are in range
      if(scores[[p]] %in% c("0", "1", "2", "3")) {
        totalScore = totalScore + as.integer(scores[[p]])
      } else { # if(scores[[p]] != "-") {
        warning(paste("sendQuestionnaireResponses -- invalid value range for ", p, "=", scores[[p]]))
        return(FALSE)
      }
    }
    
    # Parameters for POST request:
    body = append(body, scores) # append scores 
    body[["TotalScore"]] = as.character(totalScore)  # sum of all scores for Q1-9

    # For Q10, if totalScore > 0, set "Difficulty"
    if(totalScore > 0) {
      body[["Difficulty"]] = difficulty
    } else { # Difficulty not answered "-"
      body[["Difficulty"]] = "-"
    }
    
  } # else { # Only send the PHQ2 values (and '-' stub values)
    # for(p in questionScores) {
    #   body[[p]] = "-"
    # }
    # body[["TotalScore"]] = "-"
    # body[["Difficulty"]] = "-"
    # }
  

  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json", verbose())
  
  # Stop measuring call
  end_time = Sys.time()
  
  # DEBUG timing
  print(end_time - start_time)
  
  # Request Error handling
  # stop_for_status(resp)
  warn_for_status(resp)
  
  # TRUE if sucessful status code (FALSE otherwise)
  status_code(resp) == 200
}

#
# Mood Observation Data
#

sendMoodObservation <- function(recordedEmotion) {
  # Add new Patient Mood Finding (code "106131003") Observation resource.
  # 
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-Observations-Add
  #
  # Note: The Observation-Add API is currently hard-coded *only* to submit these Observations.
  # There is no code parameter and "106131003" is assumed.
  # 
  # Args:
  #   recordedEmotion: (String) Recorded emotion 
  #   TODO effectiveDateTime: (Optional) Timestamp of (mood) observation, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #
  # Returns:
  #   TRUE upon sucess (FALSE otherwise)

  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "Observation", 
                      "add",
                      sep = "/")
  # DEBUG url
  print(paste("sendMoodObservation:", requestUrl))
  
  # Parameters for POST request
  body = list("effectiveDateTime" = effectiveDateTime(), # String 	(optional) Timestamp of impression
              "subjectReference" = USERNAME_PATIENT_ID,  # Patient IDs
              "285854004" = recordedEmotion)             # Recorded emotion
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json", verbose())

  # Stop measuring call
  end_time = Sys.time()
  
  # DEBUG timing
  print(end_time - start_time)
  
  # Request Error handling
  # stop_for_status(resp)
  warn_for_status(resp)
  
  # TRUE if sucessful status code (FALSE otherwise)
  status_code(resp) == 200
}

#
# Clinical Impression Data
#

getClinicalImpression <- function(startTimestamp, endTimestamp) {
  # Gets Clinical Impressions for a patient
  # 
  # GET Request:  getClinicalImpression(startTimestamp="2019-08-13T16:26:26Z", endTimestamp="2019-08-15T16:26:26Z")
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2020-02-28T00:00:00Z).
  #
  # Returns:
  #   Table of Clinical Impression Data from the Message Passer Service
  
  # TODO - validate input parameters
  # patientID is valid
  # startTimestamp < endTimestamp
  
  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "ClinicalImpression", 
                      USERNAME_PATIENT_ID, 
                      startTimestamp,
                      endTimestamp,
                      sep = "/")
  # DEBUG url
  print(paste("getClinicalImpression:", requestUrl))
  
  # Validate URL with Certificate Authority
  # if(!url.exists(requestUrl, cainfo=CA_BUNDLE)) { # invalid
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Read.table handles HTTP GET request
  data <- read.table(requestUrl, header = TRUE)
  
  # Stop measuring call
  end_time = Sys.time()
  
  # DEBUG timing
  print(end_time - start_time)
  
  return(data)
}

sendClinicalImpression <- function(note) {
  # Add new ClinicalImpression (e.g. GP notes).
  # 
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-ClinicalImpressions-Add
  #
  # Args:
  #   note: (String) Impression details.
  #   TODO effectiveDateTime: (Optional) Timestamp of (mood) observation, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #
  # Returns:
  #   TRUE upon sucess (FALSE otherwise)
  
  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "ClinicalImpression", 
                      "add",
                      sep = "/")
  # DEBUG url
  print(paste("sendClinicalImpression:", requestUrl))
  
  # Parameters for POST request
  body = list(
    effectiveDateTime = effectiveDateTime(), 	# String 	(optional) Timestamp of impression
    subjectReference = USERNAME_PATIENT_ID,   # Patient IDs
    note = note)                              # Impression details
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json", verbose())
  
  # Stop measuring call
  end_time = Sys.time()
  
  # DEBUG timing
  print(end_time - start_time)
  
  # Request Error handling
  # stop_for_status(resp)
  warn_for_status(resp)
  
  # TRUE if sucessful status code (FALSE otherwise)
  status_code(resp) == 200
}

#
# Logging Service
#

logEvent <- function(eventType, eventData, eventTime = Sys.time()) {
  # Logs a Dashboard event on the server.
  # 
  # POST Request: 
  #
  # Args:
  #   eventType - (String) a string for the eventType
  #   eventData - (String) a string for data to log for the event-type
  #   eventTime - (double) R Sys.time(), defaults to current time
  #
  # Returns:
  #   TRUE upon sucess (FALSE otherwise)

  # DEBUG
  print(paste(eventTime, eventType, eventData, sep=" | "))
  
  return(TRUE) 
  ######################################################################
  
  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "LogEvent", 
                      "add",
                      sep = "/")
  # POST data  
  body <- list("effectiveTimestamp" = effectiveDateTime(eventTime),
               "subjectReference" = USERNAME_PATIENT_ID, # Patient IDs
               "eventType" = eventType,
               "eventData" = eventData)
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json", verbose())
  
  # Stop measuring call
  end_time = Sys.time()
  
  # DEBUG timing
  print(end_time - start_time)
  
  # Request Error handling
  # stop_for_status(resp)
  warn_for_status(resp)
  
  # TRUE if sucessful status code (FALSE otherwise)
  status_code(resp) == 200
}

