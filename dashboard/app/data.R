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
# Utilities
#

lastData <- function(d, weeks=0, days=0, hours=0) {
  # Returns the last N days of the dataset.

  if (length(d) > 1) {

    # sort in descending date, time
    d_desc = arrange(d, desc(datem), desc(time))

    # filter by the last
    latest_timestamp = as.POSIXct(d_desc$timestamp[1])
    # subtract weeks, days and hours
    from_timestamp = latest_timestamp - as.difftime(weeks, unit="weeks")
    from_timestamp = from_timestamp - as.difftime(days, unit="days")
    from_timestamp = from_timestamp - as.difftime(hours, unit="hours")

    # Using dplyr::filter to select rows between the timestamps
    return(dplyr::filter(d_desc,
                         dplyr::between(as.POSIXct(timestamp),
                                        from_timestamp,
                                        latest_timestamp)))

  } else {
    return(NULL);
  }

}

# Average multiple values present in a single cell (e.g. multiple ECG readings for one second).
averageCell <- function(d, c) {

  average <- unlist(lapply(str_split(d[[c]], " "), function(entry) mean(as.numeric(entry), na.rm=TRUE)))
  average[length(average)] <- mean(average[-length(average)], na.rm=TRUE)
  d[[c]]<- average
  return(d)

}

formatTimestamp <- function(ts) {
  # Formats an R timestamp to the format compatible to Message Passer
  # (i.e. as full timestamp (e.g. 2019-02-26T00:00:00Z).)
  #
  # Returns: compatible timestamp as a character string

  if(typeof(ts) == "double") { # POSIXct type of timestamp (what is returned from Sys.time())
    return(strftime(ts, "%Y-%m-%dT%H:%M:%SZ"))
  } else if(typeof(ts) == "character") {
    return(strftime(strptime(ts, "%Y-%m-%d %H:%M:%S"), "%Y-%m-%dT%H:%M:%SZ"))
  }

  # return what as given, garbage in garbage out
  print(paste("ERROR - formatTimestamp - unrecognised type", typeof(ts)))

}

#
# Blood Pressure
#

loadBloodPressureData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads Blood Pressure Data for the patient.
  #
  # Args:
  #   startTimestamp: start time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
  #   endTimestamp: end time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
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
    bp = getObservations("85354-9", formatTimestamp(startTimestamp), formatTimestamp(endTimestamp))
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
  bp_renamed = plyr::rename(bp, c("c8867h4" = "hr",
                                  "c271649006" = "sbp",
                                  "c271650006"="dbp"))

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

  if (length(bp) > 1) {

    # Generate a summary for Blood Pressure.

    # sort in descending date, time
    bp_desc = arrange(bp, desc(datem), desc(time))

    # Summary is based on the most recent value.
    sbp = bp_desc$sbp[1]
    dbp = bp_desc$dbp[1]

    # alert flag
    flag = alertBloodPressure(sbp=sbp, dbp=dbp)

    # alert text based on flag
    alert_text = ""
    if(flag$color == "green") {
      alert_text = "Normal"
      alert_long_text = ""
    } else if(flag$color == "orange") {
      alert_text = "Slightly high"
      alert_long_text="Your latest blood pressure reading is a bit higher than expected.\n\nThe most helpful way to respond to a slightly high blood pressure is to repeat the readings over one or more weeks. If the slightly high readings persist please contact 111, head to your pharmacy or discuss with your GP. Decisions about changing treatments are usually based on readings taken over several weeks."
    } else if(flag$color == "red") {
      alert_text = "A bit higher than normal"
      alert_long_text = "Your latest blood pressure reading is a bit higher than expected. If you have any concerns contact 111, head to your pharmacy or discuss with your GP."
    } else if(flag$color == "doublered") {
      alert_text = "A bit higher than normal"
      alert_long_text = "Your latest blood pressure reading is a bit higher than expected.\n\nThe most helpful way to respond to a high BP is to repeat the BP reading several times. If it remains at this level, its worth checking with another machine, just to be sure. You can do this by heading to your pharmacy or discussing with your GP."
    }

    if (bp_desc$timestamp[1] < (Sys.time() - as.difftime(24, unit="hours"))) {

      flag$color = "grey"

    }

    # Return summary values
    list(
      alert           = flag$color,
      alert_text      = alert_text,
      alert_long_text = alert_long_text,
      status          = paste(sbp, "/", dbp,  "mmHG"),
      timestamp       = bp_desc$datem[1] # latest day is the timestamp
    )

  }

}

#
# Heart Rate
#

loadHeartRateData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads Heart Rate Data for the patient.
  #
  # Args:
  #   startTimestamp: start time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
  #   endTimestamp: end time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
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
    hr <- getObservations("8867-4", formatTimestamp(startTimestamp), formatTimestamp(endTimestamp))
  }

  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name      | Old Name | Code    | Details
  # --------------+----------+---------+-------------------------------
  # hr            | c8867h4  | 8867-4  | Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  # resting       | c40443h4 | ???     | ???
  # activity      | c82290h8 | 82290-8 | Activity (https://r.details.loinc.org/LOINC/82290-8.html?sections=Comprehensive)
  #

  # from plots-for-dashboard.html
  hr_renamed = plyr::rename(hr, c("c8867h4" = "hr",
                                  "c40443h4" = "resting",
                                  "c82290h8" = "activity"))

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

  if (length(hr) > 1) {

    # Generate a summary for Heart Rate

    # sort in descending date, time
    hr_desc = arrange(hr, desc(datem), desc(time))

    # Summary is based on the most recent value.
    hr = hr_desc$hr[1]

    if (hr_desc$timestamp[1] < (Sys.time() - as.difftime(24, unit="hours"))) {

      connectivity = "grey"

    } else {

      connectivity = "blue"

    }

    # Return summary values
    list(
      status    = paste(hr, " bpm"),
      timestamp = hr_desc$timestamp[1], # latest hr reading
      connectivity = connectivity
    )

  }

}

#
# ECG
#

loadECGData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads ECG Data for the patient.
  #
  # Args:
  #   startTimestamp: start time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
  #   endTimestamp: end time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
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
    ecg_raw <- getObservations("131328", formatTimestamp(startTimestamp), formatTimestamp(endTimestamp))

    # Rename the columns for the FIHR codes to more explainable ones:
    #
    # New Name      | Old Name | Code    | Details
    # --------------+----------+---------+-------------------------------
    # ecg           | c131389  | ???      | ???
    ecg = plyr::rename(ecg_raw, c("c131389" = "ecg"))

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
  colnames(ecg) = c("posixtime", "ecg")

  # timestamp column from "posixtime" - concatenating milliseconds
  ecg$timestamp = paste( anytime(ecg$posixtime / 1000), ecg$posixtime %% 1000, sep=".")

  return(ecg)
}

summariseECG <- function(ecg) {

  # Generate a summary for ECG (number of samples)

  if (length(ecg) > 1) {

    # sort in descending date, time
    ecg_desc = arrange(ecg, desc(timestamp))

    # Summary is based number of samples
    n = length(ecg$ecg)

    if (ecg_desc$timestamp[1] < (Sys.time() - as.difftime(24, unit="hours"))) {

      connectivity = "grey"

    } else {

      connectivity = "blue"

    }

    # "We have a ECG trace data for x% of the time""
    # "There is no ECG or little ECG data collected. Here is a list of what you can we do to collect more readings: reposition patch, connect more often."

    # Return summary values
    list(
      status    = paste(n, "samples"),
      timestamp = ecg_desc$timestamp[1], # latest ecg reading
      n = n,
      connectivity = connectivity
    )

  }

}

#
# Mood Data
#

loadMoodData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads Mood Finding Data (code: "106131003") for the patient.
  #
  # Args:
  #   startTimestamp: start time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
  #   endTimestamp: end time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
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
    mood = getObservations("106131003", formatTimestamp(startTimestamp), formatTimestamp(endTimestamp))
  }

  # Rename the columns for the FIHR codes to more explainable ones:
  #
  # New Name        | Code       | Details
  # ----------------+------------+-------------------------------
  # recordedEmotion | c285854004 | Recorded Emotion

  if ( !is.null(mood) ) {

    # from plots-for-dashboard.html
    mood_renamed = plyr::rename(mood, c("c285854004" = "recordedEmotion"))

    # Create timestamp string column
    mood_renamed$timestamp = paste(mood_renamed$datem, mood_renamed$time, sep=" ")

    # sort in descending date, time
    mood_desc = arrange(mood_renamed, desc(datem), desc(time))

    return(mood_desc)

  } else {
    return(NULL)
  }

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

  if (!is.null(mood)) {

    # Generate a summary for Mood (i.e. the most recent mood)

    # sort in descending date, time
    mood_desc = arrange(mood, desc(datem), desc(time))

    # Summary is based on the most recent value.
    # NOTE: using as.character because R defaults to interpresting
    # the recordedEmotion as a "factor"
    recordedEmotion = as.character(mood_desc$recordedEmotion[1])
    timestamp = mood_desc$timestamp[1] # latest mood reading

    if (mood_desc$timestamp[1] < (Sys.time() - as.difftime(24, unit="hours"))) {

      connectivity = "grey"

    } else {

      connectivity = "blue"

    }

    # Return summary values
    list(
      status = recordedEmotion,
      timestamp = timestamp,
      connectivity = connectivity
    )

  }

}

# Ordering of the moods in the images/pam-resources/
mood_order = list("afraid" = "1",
                  "tense" = "2",
                  "excited" = "3",
                  "delighted" = "4",
                  "frustrated" = "5",
                  "angry" = "6",
                  "happy" = "7",
                  "glad" = "8",
                  "miserable" = "9",
                  "sad" = "10",
                  "calm" = "11",
                  "satisfied" = "12",
                  "gloomy" = "13",
                  "tired" = "14",
                  "sleepy" = "15",
                  "serene" = "16")

# which of the 3 images for a mood is shown when not randomised
mood_default = list("afraid" = "2",
                    "tense" = "1",
                    "excited" = "3",
                    "delighted" = "2",
                    "frustrated" = "2",
                    "angry" = "2",
                    "happy" = "1",
                    "glad" = "1",
                    "miserable" = "3",
                    "sad" = "3",
                    "calm" = "3",
                    "satisfied" = "2",
                    "gloomy" = "1",
                    "tired" = "3",
                    "sleepy" = "3",
                    "serene" = "2")

mood_img_src <- function(mood, randomise = FALSE, medium_size = FALSE) {
  # Returns the image source for a mood, uses the "images/pam-resources".

  if(!is.null(mood)) {
    # mood *may* take the form "[mood]_[which_image]" (e.g. "angry_3")
    # or just [mood] (e.g. "angry")
    mood_split = strsplit(mood, "_")
    mood = mood_split[[1]][1]
    which_image = mood_split[[1]][2] # will be NA if not specified

    # Get the order the mood is in the grid:
    o = mood_order[[mood]]

    # which of the three mood image options to use:
    if(is.na(which_image)) {
      if(randomise) {
        # randomly choose: "1", "2", or "3"
        which_image = as.character(sample(1:3, 1))
      } else {
        # lookup the default image for a particular mood
        which_image = mood_default[[mood]]
      }
    }

    # Using images/mood/pam-resources/images/[o]_[mood]/[o]_[which].jpg
    paste("images",
          "mood",
          "pam-resources",
          `if`(medium_size, "images-medium", "images"), # `if` is ternary operator in R
          paste(o, mood, sep="_"),
          paste(o, "_", which_image, ".jpg", sep=""),
          sep="/")
  }
}

mood_from_img_src <- function(image_src) {
  # Returns a mood string from an image src.
  #
  # For example:
  #   images/mood/pam-resources/images/1_afriad/1_3.jpg
  # is mapped to:
  #   afraid_3
  # Which specifies the third mood from "afraid"
  s = strsplit(image_src, "/")
  # s -> "1_afraid" -> "afraid
  mood = strsplit(s[[1]][5], "_")[[1]][2]
  # s -> "1_3.jpg" -> "3.jpg" -> 3
  which_image = substring(strsplit(s[[1]][6], "_")[[1]][2], 1, 1)
  # "afraid_3"
  paste(mood, which_image, sep = "_")
}

#
# Questionnaire Response (PHQ) Data
#

loadPHQData <- function(startTimestamp, endTimestamp, sample = FALSE) {
  # Loads PHQ Data for the patient.
  #   sample: use sample-data
  #
  # Returns
  #   Recorded PHQ Dataset for time-period
  #   Columns:
  #     recordedPHQ: String of recorded PHQ questionnaire response data

  # Load from QuestionnaireResponse API
  #
  #if(sample) { # fake sample-data
  #  phq = samplePHQData()
  #} else {
  phq = getQuestionnaireResponses(formatTimestamp(startTimestamp), formatTimestamp(endTimestamp))
  phq$timestamp = paste(phq$datem, phq$time, sep=" ")
  #}
  # The fields returned in the recordedPHQ data column:
  #... call names(phq) to get the field names...
  # ---------------------------------------------------
  # FeelingDownInitial
  # LittleInterestInitial
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

  if (length(phq) > 1) {

    # sort in descending date, time
    phq_desc = arrange(phq, desc(datem), desc(time))
    return(phq)

  } else {
    return(NULL)
  }

}

summarisePHQ <- function(phq) {
  # Generate a summary for Mood (i.e. the most recent mood)

  if (!is.null(phq)) {

    # sort in descending date, time
    phq_desc = arrange(phq, desc(datem), desc(time))

    # Summary is based on the most recent value.
    n = nrow(phq)
    timestamp = phq_desc$timestamp[1] # latest mood reading

    # Return summary values
    list(
      status = paste(n, "PHQ forms submitted"),
      timestamp = timestamp,
      n = n
    )

  } else {
    # Return summary values
    list(
      status = paste(0, "PHQ forms not submitted"),
      timestamp = Sys.time()-9999999999, # Crude early timestamp
      n = 0
    )
  }

}

#
# Recommendation (Tips) Data
#

loadRecommendations <- function(sample=FALSE) {
  # Loads Recommendation (Tips) Data for the patient.
  #   sample: use sample-data
  #
  # Returns
  #   Columns:
  #     icon: String of recorded PHQ questionnaire response data
  #     heading: String of recorded PHQ questionnaire response data
  #     body: String of recorded PHQ questionnaire response data

  if(sample) { # fake sample-data
    tips = sampleRecommendations()
  } else {
    tips = getRecommendations()
  }

  # Any post-processing of Recommendations / Tips

  return(tips)
}

sampleRecommendations <- function() {
  # List of Recommendations are based on a Array of objects representation from JSON
  # This *may* change depending on what the API service ends up being.

  recommendationsJSON <-
    '[
        {
         "image":"bow",
         "title": "Consider changing your painkiller; there are two options:",
         "content": "<p>Given your medical history and that paracetamol helps with back pain then paracetamol is <i>recommended</i>. It is recommended that you consider paracetamol.</p><p>Given your medical history and that codeine helps with back pain then codeine is recommended.</p>"
        },{
         "image":"drop",
         "title": "Another recommendation.",
         "content": "<p>Some more details about the recommendation.  It is recommended that you follow this recommendation.</p>"
        },{
         "image":"smily",
         "title": "Another recommendation.",
         "content": "<p>Some more details about the recommendation.  It is recommended that you follow this recommendation.</p>"
        },{
         "image":"uniform",
         "title": "Another recommendation.",
         "content": "<p>Some more details about the recommendation.  It is recommended that you follow this recommendation.</p>"
        }]'

  # Converted to named-list object from JSON
  fromJSON(recommendationsJSON)
}

#
# Feedback (Clinical Impressions) Data
#

loadClinicalImpressionData <- function(startTimestamp, endTimestamp, sample=FALSE) {
  # Loads patient clinical impressions (feedback)
  #
  # Args:
  #   startTimestamp: start time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
  #   endTimestamp: end time of the range of observations to look for, as POSIXct or timestamp character string "%Y-%m-%d %H:%M:%S"
  #   sample: use sample-data (not implemented yet)
  #
  # Returns
  #   Recorded Clinical Feedback Dataset for time-period
  #   Columns:
  #     note: String of feedback
  #     datem: Day of observation, format: "%Y-%m-%d"
  #     date.month: First day of the month of the observation, format: "%Y-%m-%d"
  #     time: Time of observation, format: "%H:%M:%S"
  #     weekday (String) day of the week, i.e. "Monday"
  #     timestamp (String) '%Y-%m-%d %H:%M:%S' formatted timestamp

  # Load from Clinical Impression API
  #

  if(sample) { # fake sample-data
    fb = sampleClinicalImpressionData()
  } else {
    fb = getClinicalImpression(formatTimestamp(startTimestamp), formatTimestamp(endTimestamp))
  }

  if (length(fb) > 1) {

    # Create timestamp string column
    fb$timestamp = paste(fb$datem, fb$time, sep=" ")

    # sort in descending date, time
    fb_desc = arrange(fb, desc(datem), desc(time))

    return(fb_desc)

  } else {
    return(NULL)
  }

}

sampleClinicalImpressionData <- function() {
  # Loads ClinicalImpression (Feedback) from a txt file located in sample-data/
  #
  # Returns:
  #   Compatible Data Table with what is returned from Clinical Impression API

  fb = read_delim("sample-data/feedback.txt", delim = " ")

  # lower case the column names
  colnames(fb) = tolower(make.names(colnames(fb)))

  # Column Names as loaded from mood.txt:
  #   "note" "datem" "date.month" "time" "weekday"

  return(fb)
}
