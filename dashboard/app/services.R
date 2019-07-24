# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is a module for abstracting out other CONSULT services.
#

library(httr) # R http lib, see https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html

# Loads sample timeline data from CSV file
loadSampleTimelineData <- function() {
    sampleData <- read.csv("sample-data/bp.csv", header=TRUE)

    # rename 'datem' column to Time  
    names(sampleData)[names(sampleData) == 'datem'] <- 'Time'

    # only return the columns that we want
    sampleData[,c("Time", "c271649006", "c271650006", "c8867h4")]
}

# Load data from Services via HTTP
requestData <- function() {
  # query are any attributes as part of the request
  r <- GET("http://httpbin.org/get",
           query = list(key1 = "value1", key2 = "value2"))

  # stop and throw an error if not getting a 200 status request
  stop_for_status(r)
 
  # parse the content of the request
  content(r, "parsed") 
  
  # content will introspect an attempt to "parse" based on the MIME-type:
  #   text/html: xml2::read_html()
  #   text/xml: xml2::read_xml()
  #   text/csv: readr::read_csv()
  #   text/tab-separated-values: readr::read_tsv()
  #   application/json: jsonlite::fromJSON()
  #   application/x-www-form-urlencoded: parse_query
  #   image/jpeg: jpeg::readJPEG()
  #   image/png: png::readPNG()
}
