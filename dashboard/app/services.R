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
Sys.setenv(MESSAGE_PASSER_PROTOCOL="http://", 
           MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005", 
           SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b", 
           CURL_CA_BUNDLE="")

# - message passer specifics
MP_PROTOCOL = Sys.getenv("MESSAGE_PASSER_PROTOCOL")
MP_HOST = Sys.getenv("MESSAGE_PASSER_URL")
MP_URL = paste0(MP_PROTOCOL, MP_HOST)

# - certificate authority
CA_BUNDLE = Sys.getenv("CURL_CA_BUNDLE")

# - username (also patient ID) provided by SHINYPROXY
USERNAME_PATIENT_ID = Sys.getenv("SHINYPROXY_USERNAME")

#
# Message Passer API 
#
# https://github.kcl.ac.uk/pages/consult/message-passer/
#

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

getQuestionnaireResponses <- function( startTimestamp, endTimestamp ) {
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

sendQuestionnaireResponses <- function(scores, difficulty) {
  # Sends the Questionnaire Response form answers.
  #
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-QuestionnaireResponses-Add
  #
  # sklar/21-aug-2019: modified to include PHQ2 scores (yes=1,no=0)
  # added two fields: yesNoFeelingDown and yesNoLittleInterest
  # note that when sending data here, we have to populate every field,
  #  which is what the database on the backend expects. So use "-" for
  #  scores in PHQ9 if they are not used.
  #

  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "QuestionnaireResponse", 
                      "add",
                      sep = "/")
  
  # Validate Question Scores
  questionScores = c(
    "yesNoFeelingDown",     # PHQ2 score for FeelingDown (PHQ2.Q1)
    "yesNoLittleInterest",  # PHQ2 score for LittleInterest (PHQ2.Q2)
    "LittleInterest",       # PHQ9 score for LittleInterest (PHQ9.Q1)
    "FeelingDown",          # PHQ9 score for FeelingDown (PHQ9.Q2)
    "TroubleSleeping",      # PHQ9 score for TroubleSleeping (PHQ9.Q3)
    "FeelingTired",         # PHQ9 score for FeelingTired (PHQ9.Q4)
    "BadAppetite",          # PHQ9 score for BadAppetite (PHQ9.Q5)
    "FeelingBadAboutSelf",  # PHQ9 score for FeelingBadAboutSelf (PHQ9.Q6)
    "TroubleConcentrating", # PHQ9 score for TroubleConcentrating (PHQ9.Q7)
    "MovingSpeaking", 	    # PHQ9 score for MovingSpeaking (PHQ9.Q8)
    "ThoughtsHurting"       # PHQ9 score for ThoughtsHurting (PHQ9.Q9)
  )
  
  # set of matching question score parameters
  matching = intersect(questionScores, names(scores))
  
  # check if all of the questionScores are present
  if(!setequal(questionScores, matching)) {
    warning(paste("sendQuestionnaireResponses -- questionScores missing:", setdiff(questionScores, matching)))
    return(FALSE)
  }
  
  # validate values for questionScores and accumulate TotalScore
  totalScore = 0
  for(p in questionScores) {
    # Question scores are in range
    if(scores[[p]] %in% c("0", "1", "2", "3")) {
      totalScore = totalScore + as.integer(scores[[p]])
    } else if(scores[[p]] != "-") {
      warning(paste("sendQuestionnaireResponses -- invalid value range for ", p, "=", scores[[p]]))
      return(FALSE)
    }
  }
  
  # Parameters for POST request
  body = append(list(), scores) # clone the scores
  body[["TotalScore"]] = as.character(totalScore)  # sum of all scores for Q1-9
  body[["subjectReference"]] = USERNAME_PATIENT_ID # Patient id
  # body[["effectiveDateTime" ]] =                 # (optional) Timestamp of impression
  
  # For Q10, if totalScore > 0, set "Difficulty"
  if(totalScore > 0) {
    body[["Difficulty"]] = difficulty
  } else { # Difficulty answer is n/a
    body[["Difficulty"]] = "n/a"
  }
  
  # DEBUG url
  print(paste("sendQuestionnaireResponses:", requestUrl, 
              "subjectReference:",           body$subjectReference,
              "yesNoFeelingDown",            body$yesNoFeelingDown,
              "yesNoLittleInterest",         body$yesNoLittleInterest,
              "LittleInterest",              body$LittleInterest,
              "FeelingDown",                 body$FeelingDown,
              "TroubleSleeping",             body$TroubleSleeping,
              "FeelingTired",                body$FeelingTired,
              "BadAppetite",                 body$BadAppetite,
              "FeelingBadAboutSelf",         body$FeelingBadAboutSelf,
              "TroubleConcentrating",        body$TroubleConcentrating,
              "MovingSpeaking",              body$MovingSpeaking,
              "ThoughtsHurting",             body$ThoughtsHurting,
              "Difficulty",                  body$Difficulty,
              "TotalScore",                  body$TotalScore
        ))
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json")
  
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
  
  # Parameters for POST request
  body = list(# "effectiveDateTime" = "", 	            # String 	(optional) Timestamp of impression
              "subjectReference" = USERNAME_PATIENT_ID, # Patient IDs
              "285854004" = recordedEmotion)            # Recorded emotion)
  
  # DEBUG url
  print(paste("sendMoodObservation:", requestUrl, 
              "subjectReference:",    body$subjectReference,
              "285854004:",           body$`285854004`))
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json")

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

  # Parameters for POST request
  body = list(
    # "effectiveDateTime" = "", 	            # String 	(optional) Timestamp of impression
    "subjectReference" = USERNAME_PATIENT_ID, # Patient IDs
    note = note)                              # Impression details
  
  # DEBUG url
  print(paste("sendClinicalImpression:", requestUrl, 
              "subjectReference:",       body$subjectReference,
              "note:",                   body$note))
  
  # Start measuring call
  start_time = Sys.time() 
  
  # Send the request
  # - using httr - https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html
  # encode = "multipart" does not work, use "form" or "json"
  resp = POST(requestUrl, body = body, encode = "json")
  
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

logEvent <- function(event_type, event_data) {
  e <- list("time" = Sys.time(),
            "type" = event_type,
            "data" = event_data)

  print(paste(e$time, e$type, e$data, sep=" | "))
  
  TRUE # sucess
}

#
# EXAMPLES
#

# Example uf using httr to load data from HTTP Service
requestData <- function() {
  # query are any attributes as part of the request
  r <- GET("http://httpbin.org/get",
           query = list(key1 = "value1", key2 = "value2"))

  # stop and throw an error if not getting a 200 status request
  stop_for_status(r)
 
  # parse the content of the request
  data <- content(r, "parsed") 
  
  # content will introspect an attempt to "parse" based on the MIME-type:
  #   text/html: xml2::read_html()
  #   text/xml: xml2::read_xml()
  #   text/csv: readr::read_csv()
  #   text/tab-separated-values: readr::read_tsv()
  #   application/json: jsonlite::fromJSON()
  #   application/x-www-form-urlencoded: parse_query
  #   image/jpeg: jpeg::readJPEG()
  #   image/png: png::readPNG()
  
  # return the data
  data
}
