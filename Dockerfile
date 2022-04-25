FROM openanalytics/r-base:4.0.5

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.1 \
    software-properties-common

# system library dependency for the app
RUN apt-get update && apt-get install -y \
    libmpfr-dev \
    libxml2-dev

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# install dependencies of the consult app
RUN R -e "options(timeout=1200); install.packages(c('BH', 'Rmpfr', 'plyr'), repos='https://cloud.r-project.org/')"
RUN R -e "options(timeout=1200); install.packages(c('data.table', 'DT', 'plotly', 'jsonlite', 'ggplot2', 'dplyr', 'scales', 'cowplot', 'personograph', 'tidyverse', 'shinydashboard', 'RCurl', 'anytime', 'shinyjs', 'humanize', 'htmlwidgets', 'httr', 'devtools'), repos='https://cloud.r-project.org/')"

# copy the app to the image
RUN mkdir /root/dashboard
COPY ./dashboard /root/dashboard

RUN R -e "devtools::install('/root/dashboard/packages/Consult')"

COPY ./proxy/certs/consult.crt /root/consult.crt

COPY ./Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/dashboard/app')"]
