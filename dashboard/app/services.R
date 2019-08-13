# CONSULT Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is a module for abstracting out other CONSULT services.
#

# "source exist" braces 
# if(!exists('services_R')) {  
#  services_R<-T

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
# Observation Data
#

getObservations <- function(patientID, code, startTimestamp, endTimestamp) {
  # Gets Observations for a patient based on codes (i.e. Blood pressure: 85354-9)
  # 
  # GET Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-Observations-GetObservations)
  #
  # Args:
  #   patientID: Users unique ID.
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
# QuestionnaireResponses POST
#

sendQuestionnaireResponses <- function(questionaire) {
  # Sends the Questionnaire Response form answers.
  #
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-QuestionnaireResponses-Add

  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "QuestionnaireResponse", 
                      "add",
                      sep = "/")
  
  # Fields for POST request
  # Field 	Type 	Description
  # id 	String 	Resource ID.
  # subjectReference 	String 	Patient ID.
  subjectReference = USERNAME_PATIENT_ID
  # effectiveDateTime 	String 	(Optional) Timestamp of response
  # LittleInterest 	String 	PHQ9 score for LittleInterest
  # FeelingDown 	String 	PHQ9 score for FeelingDown
  # TroubleSleeping 	String 	PHQ9 score for TroubleSleeping
  # FeelingTired 	String 	PHQ9 score for FeelingTired
  # BadAppetite 	String 	PHQ9 score for BadAppetite
  # FeelingBadAboutSelf 	String 	PHQ9 score for FeelingBadAboutSelf
  # TroubleConcentrating 	String 	PHQ9 score for TroubleConcentrating
  # MovingSpeaking 	String 	PHQ9 score for MovingSpeaking
  # Difficulty 	String 	PHQ9 score for Difficulty
  # TotalScore 	String 	Total PHQ9 score
  
  # TODO - validate input parameters
  
  # DEBUG
  print(paste("sendQuestionnaireResponses(subjectReference=", subjectReference,
              ")"))
}

#
# Mood Observation Data
#

sendMoodObservation <- function(recordedEmotion) {
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-Observations-Add
  
  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "Observation", 
                      "add",
                      sep = "/")
  
  # Fields for POST request
  # id 	String 	Resource ID
  # subjectReference 	String 	  Patient ID
  subjectReference = USERNAME_PATIENT_ID
  # effectiveDateTime 	String 	(optional) Timestamp of impression
  # 285854004 	String 	Recorded emotion
  
  # DEBUG
  print(paste("sendMoodObservation(subjectReference=", subjectReference,
              ", 285854004=", recordedEmotion,
              ")"))
}

#
# Clinical Impression Data
#

sendClinicalImpression <- function(note) {
  # POST Request: https://github.kcl.ac.uk/pages/consult/message-passer/#api-ClinicalImpressions
  
  # Build the Message Passer request URL 
  requestUrl <- paste(MP_URL, 
                      "ClinicalImpression", 
                      "add",
                      sep = "/")
  
  # Fields for POST request
  # id 	String 	Resource ID - TODO What is this?
  # note 	String 	 Impression details
  # subjectReference 	String 	  Patient ID
  subjectReference = USERNAME_PATIENT_ID
  # effectiveDateTime 	String 	(optional) TODO Timestamp of impression
  
  print(paste("sendClinicalImpression(subjectReference=", subjectReference,
              ", note=", note,
              ")"))
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

###
# } # services_R exists



