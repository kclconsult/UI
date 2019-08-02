# CONSULT Dashboard Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is a module for abstracting out other CONSULT services.
#

library(httr) # R http lib, see https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html

# Service Environment Variables
# - message passer specifics
messagePasserHostProtocol = Sys.getenv("MESSAGE_PASSER_PROTOCOL")
messagePasserHost = Sys.getenv("MESSAGE_PASSER_URL")

# - certificate authority
caBundle = Sys.getenv("CURL_CA_BUNDLE")

# - username
consultUserName = Sys.getenv("SHINYPROXY_USERNAME")

#
# Blood Pressure
#

bloodPressureEndpoint <- function(from_datetime = "2016-02-26T00:00:00Z", to_date = "2020-02-28T00:00:00Z") {
   # TODO - validate inputs
  
  # build the BP endpoint
  
  # endpoint <- paste(messagePasserHostProtocol, 
  #                    messagePasserHost, 
  #                    "/Observation/", 
  #                    consultUserName, 
  #                    "/85354-9/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", 
  #                    "", sep="") # 8534-9 = Blood pressure (https://details.loinc.org/LOINC/85354-9.html)

  # validate the URL
  # if ( url.exists(bpEndpoint, cainfo=Sys.getenv("CURL_CA_BUNDLE")) ) { ...
  # TODO - Exceptions in R?
}

loadBloodPressureData <- function() {

    # bp<-read.table(bpEndpoint, header=TRUE, colClasses=colClasses)
    # #rownames(bp) <- 1:nrow(bp);
    # 
    # bp$dt<-as.POSIXct(paste(bp$datem, bp$time), format="%Y-%m-%d %H:%M")
    # 
    # bp$dt1<-anytime::anytime(bp$dt)
    # bp$hr<-bp$c8867h4 # 8867-4 = Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
    # bp$sbp<-bp$c271649006 # 271649006 = Systolic blood pressure (http://bioportal.bioontology.org/ontologies/SNOMEDCT?p=classes&conceptid=271649006)
    # bp$dbp<-bp$c271650006 # 271650006 = Diastolic blood pressure (http://bioportal.bioontology.org/ontologies/SNOMEDCT?p=classes&conceptid=271650006)

  # Stub
  loadSampleTimelineData()
}

summaryBloodPressureStats<- function(bp) { 

}

#
# Heart Rate
#

heartRateEndpoint <- function(from_datetime = "2016-02-26T00:00:00Z", to_date = "2020-02-28T00:00:00Z") {
  # TODO - validate inputs
  
  # build the HR endpoint
  # TODO - is there a better way of building a URL rather than using paste?
  # endpoint <- paste(messagePasserHostProtocol, 
  #                    messagePasserHost, 
  #                    "/Observation/", 
  #                    consultUserName, 
  #                    "/8867-4/", # 8867-4 = Heart rate (https://s.details.loinc.org/LOINC/8867-4.html?sections=Comprehensive)
  #                    from_datetime,
  #                    "/",
  #                    to_date, "", sep="")  

  # validate the URL
  # if(url.exists(hrEndpoint, cainfo=caBundle) ) {
  # 
  # }
  
}

loadHeartRateData <- function() {
  # heartRateEndpoint() # get the endpoint

  # hr<-read.table(hrEndpoint, header=TRUE, colClasses=colClasses)
  #  rownames(hr) <- 1:nrow(hr);

  #  hr$dt<-as.POSIXct(paste(hr$datem, hr$time), format="%Y-%m-%d %H:%M")
  #  hr$freq.mod.activity<-hr$c82290h8 # 82290-8 = activity (https://r.details.loinc.org/LOINC/82290-8.html?sections=Comprehensive)

  # Stub
  loadSampleTimelineData()
}

summaryHeartRateStats = function(hr) {
  # resting.c8867h4<-tail(hr$c40443h4, n=1)
  # cat(paste("Resting Heart Rate: ", round(resting.c8867h4,1), sep=""))
  # mean.c8867h4<-mean(hr$c8867h4)
  # cat(paste("\nAverage Heart Rate last 24 hours: ", round(mean.c8867h4,1), sep=""))
  # mean.c8867h4.year<-mean(head(hr$c8867h4, n=30))
  # cat(paste("\nAverage Heart Rate last month: ", round(mean.c8867h4.year,1), sep=""))
}

#
# ECG 
#

ecgEndpoint <- function(from_datetime = "2016-02-26T00:00:00Z", to_date = "2020-02-28T00:00:00Z") {

  # endpoint <- paste(messagePasserHostProtocol, 
  # messagePasserHost, 
  # "/Observation/", S
  # Sys.getenv("SHINYPROXY_USERNAME"), 
  # "/131328/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", 
  # "", sep="")

  # if ( url.exists(ecgEndpoint, cainfo=Sys.getenv("CURL_CA_BUNDLE")) ) {
}

loadECGData <- function() {
 
  # ecg<-read.table(ecgEndpoint, header=TRUE, colClasses=colClasses)
  #  rownames(ecg) <- 1:nrow(ecg);

  #
  # rawECG <- ecg$c131389
  # tidyECG <- gsub(" ","\n", rawECG)
  
  # Stub
  loadSampleTimelineData()
}

summaryECGStats <- function(ecg) {
  
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
