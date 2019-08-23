# Development environment variables
Sys.setenv(MESSAGE_PASSER_PROTOCOL="http://", 
           MESSAGE_PASSER_URL="ec2-3-9-227-22.eu-west-2.compute.amazonaws.com:3005", 
           SHINYPROXY_USERNAME="3e2dab80-b847-11e9-8e30-f5388ac63e8b", 
           CURL_CA_BUNDLE="")

library('shiny')

# install packages
library('devtools')
setwd('dashboard/packages/Consult')
devtools::install()
setwd('../..')

# runs app/ directory
runApp(appDir="app", host="0.0.0.0", port=5369)
