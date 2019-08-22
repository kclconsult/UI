# CONSULT Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is a module for processing CONSULT data client-side.  It depends on the services.R module.
#


# install.packages("tidyverse")
#  provides functions such as 'read_delim'
library(tidyverse) 

# install.packages("anytime")
# converts POSIX times to strings
library(anytime)

#
# Blood Pressure
#

loadBloodPressureData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads Blood Pressure Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   sample: use sample-data
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
  #     timestamp (String) '%Y-%m-%d %H:%M:%S' formatted timestamp
  

  if(sample) { # Load from sample-data
    bp <- sampleBloodPressureData()
  } else {   # Load from Observation API
    #   Blood pressure code = 8534-9 (https://details.loinc.org/LOINC/85354-9.html)
    bp = getObservations("85354-9", startTimestamp, endTimestamp)
  }
  
  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name | Old Name   | Code      | Details
  # ---------+------------+-----------+-------------------------------
  # hr       | c8867h4    | 8867-4    | Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  # sbp      | c271649006 | 271649006 | Systolic blood pressure (http://bioportal.bioontology.org/ontologies/SNOMEDCT?p=classes&conceptid=271649006)
  # dbp      | c271650006 | 271650006 | Diastolic blood pressure (http://bioportal.bioontology.org/ontologies/SNOMEDCT?p=classes&conceptid=271650006)
  # 

  # from plots-for-dashboard.html
  bp_renamed = plyr::rename(bp, c("c8867h4" = "hr", "c271649006" = "sbp", "c271650006"="dbp"))

  # Create timestamp string for plotting
  bp_renamed$timestamp = paste(bp_renamed$datem, bp_renamed$time)

  return(bp_renamed)
}

sampleBloodPressureData <- function() {
  # Loads Blood Pressure Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  bp = read_delim("sample-data/bp.txt", delim = " ")  
  
  # lower case the column names
  colnames(bp) = tolower(make.names(colnames(bp)))
  
  # Column Names as loaded from bp.txt: 
  #   "c271649006" "c271650006" "c8867h4" "datem" "date.month" "time" "weekday"

  return(bp)
}

alertBloodPressure <- function(sbp, dbp) {
  # Logic for Blood Pressure alert.
  #
  # Args:
  #   sbp: Systolic blood pressure (c271649006)
  #   dbp: Diastolic blood pressure (c271650006)
  #
  # Output:
  #   List of flag colors:
  #     $sbp - Systolic blood pressure flag
  #     $dbp - Diastolic blood pressure flag
  #     $color - Most severe flag color of either
  #   Flag colors are:
  #     "green"     - no alert, normal, no Flag
  #     "orange"    - Amber Flag
  #     "red"       - Red Flag
  #     "doublered" - Double Red Flag

  flag = list()
  
  # Flag levels for Systolic Blood Pressure:
  if(sbp > 179) {
    flag$sbp = "doublered"
  } else if(sbp > 149) {
    flag$sbp = "red"
  } else if(sbp > 134) {
    flag$sbp = "orange"
  } else {
    flag$sbp = "green"
  }

  # Flag levels for Diastolic Blood Pressure:
  if(dbp > 109) {
    flag$dbp = "doublered"
  } else if(dbp > 94) {
    flag$dbp = "red"
  } else if(dbp > 84) {
    flag$dbp = "orange"
  } else {
    flag$dbp = "green"
  }
  
  # For calculating which bp is more severe
  severity = list("green" = 0,
                  "orange" = 1,
                  "red" = 2,
                  "doublered" = 3)
  
  # sbp is more severe
  if(severity[[flag$sbp]] > severity[[flag$dbp]]) {
      flag$color = flag$sbp
  } else { # dbp is more severe or equal
    flag$color = flag$dbp
  }
  
  return(flag)
}

summariseBloodPressure <- function(bp) {
  # Generate a summary for Blood Pressure. 
  
  # sort in descending date, time
  bp_desc = arrange(bp, desc(datem), desc(time))
  
  # Summary is based on the most recent value.
  sbp = bp_desc$sbp[1]
  dbp = bp_desc$dbp[1]
  
  # alert flag
  flag = alertBloodPressure(sbp=sbp, dbp=dbp)
  
  # Return summary values
  list(
    alert     = flag$color,
    status    = paste(sbp, "/", dbp,  "mmHG"),
    timestamp = bp_desc$datem[1] # latest day is the timestamp
  )
}

#
# Heart Rate
#

loadHeartRateData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads Heart Rate Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp.
  #   sample: use sample-data
  #
  # Returns
  #   Heart Dataset with Summary Statistics contents:
  #     hr.resting (Number) Heart Rate resting 
  #     hr (Number) Heart Rate      
  #     activity.freq (Number) ???
  #     datem: (Date) day as a date
  #     date.month: (Date) month as defined by the first day of the month
  #     time: (Date) time of day
  #     weekday (String) Day of the week 
  #     timestamp (String) '%Y-%m-%d %H:%M:%S' formatted timestamp
  
  if(sample) { # Load from sample-data
    hr <- sampleHeartRateData()
  } else {   # Load from Observation API
    #  Heart rate code = 8867-4 (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
    hr <- getObservations("8867-4", startTimestamp, endTimestamp)
  }
  
  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name      | Old Name | Code    | Details
  # --------------+----------+---------+-------------------------------
  # hr            | c8867h4  | 8867-4  | Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  # hr.resting    | c40443h4 | ???     | ??? 
  # activity.freq | c82290h8 | 82290-8 | Activity (https://r.details.loinc.org/LOINC/82290-8.html?sections=Comprehensive)
  # 

  # from plots-for-dashboard.html
  hr_renamed = plyr::rename(hr, c("c8867h4" = "hr", "c40443h4" = "hr.resting", "c82290h8" = "activity.freq"))

  # Create timestamp string for plotting
  hr_renamed$timestamp = paste(hr_renamed$datem, hr_renamed$time)
  
  return(hr_renamed)
}

sampleHeartRateData <- function() {
  # Loads Heart Rate Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  hr = read_delim("sample-data/hr.txt", delim = " ")  
  
  # lower case the column names
  colnames(hr) = tolower(make.names(colnames(hr)))
  
  # Column Names as loaded from hr.txt: 
  #   "c40443h4" "c8867h4" "c82290h8" "datem" "date.month" "time" "weekday"

  return(hr)
}

summariseHeartRate <- function(hr) {
  # Generate a summary for Heart Rate
  
  # sort in descending date, time
  hr_desc = arrange(hr, desc(datem), desc(time))
  
  # Summary is based on the most recent value.
  hr = hr_desc$hr[1]
  hr.resting = hr_desc$hr.resting[1]
  
  # Return summary values
  list(
    status    = paste(hr, " bpm"),
    timestamp = hr_desc$timestamp[1] # latest hr reading
  )
}

#
# ECG 
#

loadECGData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads ECG Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   sample: Use sample-data
  #
  # Returns
  #   ECG Dataset contents:
  #     ecg.raw mV of the ECG data
  #     datem: (Date) day as a date
  #     date.month: (Date) month as defined by the first day of the month
  #     time: (Date) time of day
  #     weekday (String) Day of the week 
  #     timestamp (String) '%Y-%m-%d %H:%M:%S' formatted timestamp
  
  
  if(sample) { # Load from sample-data
    ecg = sampleECGData()
  } else {   # Load from Observation API
    #  ECG code = 131328 (???)
    ecg_raw <- getObservations("131328", startTimestamp, endTimestamp)

    # Rename the columns for the FIHR codes to more explainable ones:
    #
    # New Name      | Old Name | Code    | Details
    # --------------+----------+---------+-------------------------------
    # ecg.raw       | c131389  | ???      | ???
    ecg = plyr::rename(ecg_raw, c("c131389" = "ecg.raw"))

    # Create timestamp string for plotting
    ecg$timestamp = paste(ecg$datem, ecg$time)
  }
  
  return(ecg)
}

sampleECGData <- function() {
  # Loads ECG Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  ecg_raw = read.csv("sample-data/ecg.csv", header=FALSE)  
  
  # No column names in ecg.csv!
  # Note: Sample ECG data file is so strange!
  # No headers, long rows of what appears to be 2-tuples (unixtime, value)
  
  # un-roll the rows into single vector
  ecg_vector = c(t(ecg_raw))
  
  # re-shape vector into 2 column matrix and then converted to table
  ecg <- data.frame(matrix(ecg_vector, ncol=2, byrow=TRUE))
  
  # remove any NA rows from the data
  ecg <- ecg[complete.cases(ecg),]
  
  # name the columns
  colnames(ecg) = c("posixtime", "ecg.raw")
  
  # timestamp column from "posixtime" - concatenating milliseconds
  ecg$timestamp = paste( anytime(ecg$posixtime / 1000), ecg$posixtime %% 1000, sep=".")
  
  return(ecg)
}

summariseECG <- function(ecg) {
  # Generate a summary for ECG (number of samples)
  
  # sort in descending date, time
  ecg_desc = arrange(ecg, desc(timestamp))
  
  # Summary is based number of samples
  n = length(ecg$ecg.raw)
  
  # Return summary values
  list(
    status    = paste(n, "samples"),
    timestamp = ecg_desc$timestamp[1] # latest ecg reading
  )
}

#
# Mood Data
#

loadMoodData <- function(startTimestamp, endTimestamp, sample) {
  # Loads Mood Finding Data (code: "106131003") for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   sample: use sample-data
  #
  # Returns
  #   Recorded Mood Dataset for time-period
  #   Columns:
  #     recordedEmotion: String of recorded emotion
  #     datem: Day of observation, format: "%Y-%m-%d" 
  #     date.month: First day of the month of the observation, format: "%Y-%m-%d"
  #     time: Time of observation, format: "%H:%M:%S"
  #     weekday (String) day of the week, i.e. "Monday"
  #     timestamp (String) '%Y-%m-%d %H:%M:%S' formatted timestamp
  
  # Load from Observation API
  # 
  if(sample) { # fake sample-data
    mood = sampleMoodData()
  } else {
    # "Mood Finding" code is = "106131003"
    mood = getObservations("106131003", startTimestamp, endTimestamp)
  }
  
  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name        | Code       | Details
  # ----------------+------------+-------------------------------
  # recordedEmotion | c285854004 | Recorded Emotion

  # from plots-for-dashboard.html
  mood_renamed = plyr::rename(mood, c("c285854004" = "recordedEmotion"))
  
  # Create timestamp string column
  mood_renamed$timestamp = paste(mood_renamed$datem, mood_renamed$time, sep=" ")
  
  return(mood_renamed)
}

sampleMoodData <- function() {
  # Loads Mood Data from a txt file located in sample-data/
  # 
  # Returns:
  #   Compatible Data Table with what is returned from Observation API
  
  mood = read_delim("sample-data/mood.txt", delim = " ")  
  
  # lower case the column names
  colnames(mood) = tolower(make.names(colnames(mood)))
  
  # Column Names as loaded from mood.txt: 
  #   "c285854004" "datem" "date.month" "time" "weekday"
  
  return(mood)
}

summariseMood <- function(mood) {
  # Generate a summary for Mood (i.e. the most recent mood)
  
  # sort in descending date, time
  mood_desc = arrange(mood, desc(datem), desc(time))
  
  # Summary is based on the most recent value.
  recordedEmotion = as.character(mood_desc$recordedEmotion[1])
  timestamp = mood_desc$timestamp[1] # latest mood reading

  # Return summary values
  list(
    status    = tools::toTitleCase(recordedEmotion), # capitalises the Emotion
    timestamp = timestamp
  )
}

loadPHQData <- function(startTimestamp, endTimestamp, sample) {
  # Loads PHQ Data for the patient.
  #
  # Args:
  #   startTimestamp: The start time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   endTimestamp: The end time of the range of observations to look for, as full timestamp (e.g. 2019-02-26T00:00:00Z).
  #   sample: use sample-data
  #
  # Returns
  #   Recorded PHQ Dataset for time-period
  #   Columns:
  #     recordedPHQ: String of recorded PHQ questionnaire response data
  #     datem: Day of observation, format: "%Y-%m-%d" 
  #     date.month: First day of the month of the observation, format: "%Y-%m-%d"
  #     time: Time of observation, format: "%H:%M:%S"
  #     weekday (String) day of the week, i.e. "Monday"
  #     timestamp (String) '%Y-%m-%d %H:%M:%S' formatted timestamp
  
  # Load from QuestionnaireResponse API
  # 
  #if(sample) { # fake sample-data
  #  phq = samplePHQData()
  #} else {
  phq = getQuestionnaireResponses( startTimestamp, endTimestamp )
  phq$timestamp = paste( phq$datem, phq$time, sep=" " )
  #}
  # The fields returned in the recordedPHQ data column:
  #... call names(phq) to get the field names...
  # ---------------------------------------------------
  # LittleInterest
  # FeelingDown
  # TroubleSleeping
  # FeelingTired
  # BadAppetite
  # FeelingBadAboutSelf
  # TroubleConcentrating
  # MovingSpeaking
  # ThoughtsHurting
  # Difficulty
  # TotalScore
  # datem
  # date.month
  # time
  # weekday
  return( phq )
}