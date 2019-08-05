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

# Environment Variables Specific to the services
# - message passer specifics
MP_PROTOCOL = Sys.getenv("MESSAGE_PASSER_PROTOCOL")
MP_HOST = Sys.getenv("MESSAGE_PASSER_URL")

# - certificate authority
CA_BUNDLE = Sys.getenv("CURL_CA_BUNDLE")

# - username (also patient ID) provided by SHINYPROXY
USERNAME_PATIENT_ID = Sys.getenv("SHINYPROXY_USERNAME")

#
# Message Passer API 
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
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #
  # Returns:
  #   Table of (raw) Observation Data from the Message Passer Service

  # TODO - validate input parameters
  
  # Build the request URL (using paste(...sep="") b/c Env varables (i.e. MP_PROTOCOL) are wrapped with '/')
  requestUrl <- paste(MP_PROTOCOL, MP_HOST, "/Observation/", USERNAME_PATIENT_ID, "/", 
                      code, "/",
                      startTimestamp, "/",
                      endTimestamp, "",
                      sep = "")

  # Validate URL with Certificate Authority
  if(url.exists(requestUrl, cainfo=CA_BUNDLE)) { # valid
    # Read.table handles HTTP GET request
    data <- read.table(requestUrl, header = TRUE)
  } else { # invalid
    # TODO - exceptions in R?
    print("Invalid url: ", requestUrl)
  }

  return(data)
}


#
# Blood Pressure
#


loadBloodPressureData <- function(startTimestamp, endTimestamp) {
  # Loads Blood Pressure Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #
  # Returns
  #   Blood Presure Data set with Summary Statistics
  #   Columns:
  #     sbp (Number) Systolic blood pressure      
  #     dbp (Number) Diastolic blood pressure
  #     hr  (Number)  Heart rate
  #     datem: Date???
  #     date.month: Month???
  #     time: Time???
  #     weekday (String) day of the week 
  #
  
  # Load from Observation API
  #   Blood pressure code = 8534-9 (https://details.loinc.org/LOINC/85354-9.html)
  # bp <- getObservations(USERNAME_PATIENT_ID, "8534-9", startTimestamp, endTimestamp)

  # Load from sample-data
  bp <- sampleBloodPressureData()

  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name | Old Name   | Code      | Details
  # ---------+------------+-----------+-------------------------------
  # hr       | c8867h4    | 8867-4    | Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  # sbp      | c271649006 | 271649006 | Systolic blood pressure (http://bioportal.bioontology.org/ontologies/SNOMEDCT?p=classes&conceptid=271649006)
  # dbp      | c271650006 | 271650006 | Diastolic blood pressure (http://bioportal.bioontology.org/ontologies/SNOMEDCT?p=classes&conceptid=271650006)
  # 

  # from plots-for-dashboard.html
  bp_renamed <- bp %>%
    rename(hr = c8867h4, sbp = c271649006, dbp = c271650006) %>%
    arrange(desc(datem))
    
  # Summary Statistics for Blood Pressure
  
  return(bp_renamed)
}

sampleBloodPressureData <- function() {
  # Loads Blood Pressure Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  bp <- read_delim("sample-data/bp.txt", delim = " ")  
  
  # lower case the column names
  colnames(bp) <- tolower(make.names(colnames(bp)))
  
  # Column Names as loaded from bp.txt: 
  #   "c40443h4" "c8867h4" "c82290h8" "datem" "date.month" "time" "weekday"

  return(bp)
}

#
# Heart Rate
#

loadHeartRateData <- function(startTimestamp, endTimestamp) {
  # Loads Heart Rate Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #
  # Returns
  #   Heart Dataset with Summary Statistics contents:
  #     hr.resting (Number) Heart Rate resting 
  #     hr (Number) Heart Rate      
  #     activity.freq (Number) ???
  #     datem: Date???
  #     date.month: Month???
  #     time: Time???
  #     weekday (String) day of the week 
  #
  
  # Load from Observation API
  #  Heart rate code = 8867-4 (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  # hr <- getObservations(USERNAME_PATIENT_ID, "8867-4", startTimestamp, endTimestamp)

  # Load from sample-data
  hr <- sampleHeartRateData()

  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name      | Old Name | Code    | Details
  # --------------+----------+---------+-------------------------------
  # hr            | c8867h4  | 8867-4  | Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  # hr.resting    | c40443h4 | ???     | ??? 
  # activity.freq | c82290h8 | 82290-8 | Activity (https://r.details.loinc.org/LOINC/82290-8.html?sections=Comprehensive)
  # 

  # from plots-for-dashboard.html
  hr_renamed <-hr %>%
    rename(hr = c8867h4, hr.resting = c40443h4, activity.freq = c82290h8)

  # Summary Statistics for Heart Rate
  # from app.R:
  # resting.c8867h4<-tail(hr$c40443h4, n=1)
  # cat(paste("Resting Heart Rate: ", round(resting.c8867h4,1), sep=""))
  # mean.c8867h4<-mean(hr$c8867h4)
  # cat(paste("\nAverage Heart Rate last 24 hours: ", round(mean.c8867h4,1), sep=""))
  # mean.c8867h4.year<-mean(head(hr$c8867h4, n=30))
  # cat(paste("\nAverage Heart Rate last month: ", round(mean.c8867h4.year,1), sep=""))
    
  return(hr_renamed)
}

sampleHeartRateData <- function() {
  # Loads Heart Rate Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  hr <- read_delim("sample-data/hr.txt", delim = " ")  
  
  # lower case the column names
  colnames(hr) <- tolower(make.names(colnames(hr)))
  
  # Column Names as loaded from hr.txt: 
  #   "c40443h4" "c8867h4" "c82290h8" "datem" "date.month" "time" "weekday"

  return(hr)
}

#
# ECG 
#

loadECGData <- function(startTimestamp, endTimestamp) {
  # Loads ECG Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #
  # Returns
  #   ECG Dataset with Summary Statistics contents:
  #     ecg.raw (Number) ???
  #
  
  # Load from Observation API
  #  ECG code = 131328 (???)
  # ecg <- getObservations(USERNAME_PATIENT_ID, "131328", startTimestamp, endTimestamp)

  # Load from sample-data
  ecg <- sampleECGData()

  # TODO - figure out what the actual ECG columns are! 
  
  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name      | Old Name | Code    | Details
  # --------------+----------+---------+-------------------------------
  # ecg.raw       | c131389  | ???      | ???

  # ecg_renamed <-ecg %>%
  #  rename(ecg.raw = c131389)
  
  return(ecg)
}

sampleECGData <- function() {
  # Loads ECG Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  ecg <- read.csv("sample-data/ecg.csv", header=FALSE)  
  
  # No column names in ecg.csv!
  
  return(ecg)
}

#
# EXAMPLES
#

# Example of loading sample timeline data from CSV file
loadSampleTimelineData <- function() {
    sampleData <- read.csv("sample-data/bp.csv", header=TRUE)

    # rename 'datem' column to 'Time'  
    names(sampleData)[names(sampleData) == 'datem'] <- 'Time'

    # only return the columns that we want
    sampleData[,c("Time", "c271649006", "c271650006", "c8867h4")]
}

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
