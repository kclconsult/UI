library(shiny)
library(RCurl)
library(data.table)
library(DT)
library(plotly)
library(jsonlite)
library(ggplot2)
library(dplyr)
library(scales)
library(cowplot)
library(personograph)
library(tidyverse)
library(shinydashboard)
library(anytime)

colorList <- c( "#00AA2C", "#85D79B",  "#E70000", "#E78A8C", "#0075B7", "#509ECB")

ui <- fluidPage(
  navbarPage( "CONSULT",
    tabPanel("Summary",
      h3("My Health Summary"),
      br(),
      dashboardPage(
        dashboardHeader(title = "Vital Data"),
        dashboardSidebar(disable = TRUE),
        dashboardBody(
          fluidRow(
            valueBoxOutput("boxBP"),
            valueBoxOutput("boxHR"),
            valueBoxOutput("boxECG"),
            valueBoxOutput("boxMood"),
            valueBoxOutput("boxPain")
          )
        )
      )
    ),
    tabPanel("Heartrate",
      h3("Heartrate"),
      br(),
      fluidRow(
        column(1 , "Timeframe: "),
        column(3 , selectInput("radioHRTimeframe", label = NULL, choices = list("Overview" = "overview" ), selected = "overview") )
      ),
      plotOutput("plotHR"),
      br(),
      verbatimTextOutput("printHR")
    ),
    tabPanel("Blood Pressure",
      h3("Blood Pressure"),
      br(),
      fluidRow(
        column(1 , "Timeframe: "),
        column(3 , selectInput("radioBPTimeframe", label = NULL, choices = list("Overview" = "overview" , "Weekly DBP" = "dbp", "Weekly SBP" = "sbp" ), selected = "overview") )
      ),
      plotOutput("plotBP")
    ),
    tabPanel("ECG",
      h3("ECG Monitoring"),
      br(),
      sliderInput("sliderECG", "Observations:", min = 0, max = 5000, value = 0, step = 10, animate = animationOptions( interval = 300, loop = TRUE)
      ),
      plotOutput("plotECG")
    ),
    tabPanel("Risk",
      h3("Predicted Risk of Stroke if You Stop Smoking"),
      br(),
      img(src="predicted-risk-of-stroke-if-you-stop-smoking.png")
    ),
    tabPanel("Recommendation",
      h3("Recommendation"),
      br(),
      p("Consider changing your painkiller; there are two options:"),
      p("Given your medical history and that paracetamol helps with back pain then paracetamol is recommended. It is recommended that you consider 'paracetamol'."),
      p("Given your medical history and that codeine helps with back pain then codeine is recommended.")
    ),
    tabPanel("Chat",
      h3("Start Interactive Chat"),
      br(),
      fluidRow(
        column(2, style = "margin-top: 25px;",actionButton("actChatUser", label = "User Chat") )
      )
    ),
    tabPanel("FAQ",
      h3("FAQs for patients (when they do not use the chat)"),
      br()
    ),
    tabPanel("Feedback",
      h3("Link to feedback questionnaires"),
      br()
    )
  )
)

server <- function(input, output) {

  colClasses <- c(datem="Date", date.month="Date")
  messagePasserHostProtocol <- Sys.getenv("MESSAGE_PASSER_PROTOCOL")
  messagePasserHost <- Sys.getenv("MESSAGE_PASSER_URL")
  hrEndpoint <- paste(messagePasserHostProtocol, messagePasserHost, "/Observation/", Sys.getenv("SHINYPROXY_USERNAME"), "/8867-4/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", "", sep="")

  if ( url.exists(hrEndpoint, cainfo=Sys.getenv("CURL_CA_BUNDLE")) ) {

    hr<-read.table(hrEndpoint, header=TRUE, colClasses=colClasses)
    rownames(hr) <- 1:nrow(hr);

    hr$dt<-as.POSIXct(paste(hr$datem, hr$time), format="%Y-%m-%d %H:%M")
    hr$freq.mod.activity<-hr$c82290h8

    dashboard.c8867h4<-function() {

      ggplot(data=hr, aes(dt, c8867h4, color="Heart Rate")) + geom_line(aes(x=dt, y=c8867h4))+
        labs(title="Heart Rate Readings", x="date", y="Heart Rate") + theme_bw() + ylim(45,135) +
        scale_color_discrete(name="Legend") +
        scale_x_datetime(date_breaks = "12 hour", labels=date_format("%b %d - %H:%M"))+
        theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))

    }

    dashboard.c8867h4.stats<-function(){
       resting.c8867h4<-tail(hr$c40443h4, n=1)
       cat(paste("Resting Heart Rate: ", round(resting.c8867h4,1), sep=""))
       mean.c8867h4<-mean(hr$c8867h4)
       cat(paste("\nAverage Heart Rate last 24 hours: ", round(mean.c8867h4,1), sep=""))
       mean.c8867h4.year<-mean(head(hr$c8867h4, n=30))
       cat(paste("\nAverage Heart Rate last month: ", round(mean.c8867h4.year,1), sep=""))
     }

    output$plotHR <- renderPlot({ dashboard.c8867h4() });
    output$printHR <- renderPrint({ dashboard.c8867h4.stats() });

  }

  bpEndpoint <- paste(messagePasserHostProtocol, messagePasserHost, "/Observation/", Sys.getenv("SHINYPROXY_USERNAME"), "/85354-9/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", "", sep="")

  if ( url.exists(bpEndpoint, cainfo=Sys.getenv("CURL_CA_BUNDLE")) ) {

    bp<-read.table(bpEndpoint, header=TRUE, colClasses=colClasses)
    #rownames(bp) <- 1:nrow(bp);

    bp$dt<-as.POSIXct(paste(bp$datem, bp$time), format="%Y-%m-%d %H:%M")

    bp$dt1<-anytime::anytime(bp$dt)
    bp$hr<-bp$c8867h4
    bp$sbp<-bp$c271649006
    bp$dbp<-bp$c271650006

    dashboard.bp<-function(period) {

      if ( period == "overview") {

        ggplot(data=bp, aes(dt1, sbp, color="SBP")) + stat_summary(fun.y=mean, geom = "line") +
          labs(title="Blood Pressure", x="Date and Time of Measurment") + theme_bw() +ylim(70,180) +
          geom_line(aes(x = dt1, y = dbp, color="DBP")) + scale_color_discrete(name="Legend") +
          scale_x_datetime(date_breaks = "12 hour", labels=date_format("%b %d - %H:%M"))+
          theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))

      } else if ( period == "dbp") {

        ggplot(data=bp, aes(x=weekday, y=dbp )) + geom_boxplot(fill='#999999') + theme_bw() + ylim(70,100)+
          geom_hline(aes(yintercept =85),colour="#990000", linetype="dashed")+
          labs(title = "DBP", x="Day of the Week", y="dbp")+
          scale_x_discrete(limits=c("Monday","Tuesday", "Wednesday", "Thursday","Friday", "Saturday", "Sunday"))

      } else if ( period == "sbp") {

        ggplot(data=bp, aes(x=weekday, y=sbp )) + geom_boxplot(fill='#999999') + theme_bw() + ylim(90,180)+
          geom_hline(aes(yintercept =135),colour="#990000", linetype="dashed")+
          labs(title = "SBP", x="Day of the Week", y="sbp")+
          scale_x_discrete(limits=c("Monday","Tuesday", "Wednesday", "Thursday","Friday", "Saturday", "Sunday"))

      }

    }

    output$plotBP <- renderPlot({ dashboard.bp(period = input$radioBPTimeframe) })

  }

  risk.evidence<-read.csv("sample-data/intervention.csv")
  mycates<-function(interv){
    a<-risk.evidence$tr.risk[risk.evidence$intervention==interv]
    values<-list(stroke=a, none=(1-a))
    values.baseline<-list(stroke=0.07, none=(1-0.07))
    par(mfrow=c(1,2))
    personograph(values.baseline, fig.title = "Baseline", fig.cap = "Risk Estimate", draw.legend = T,
                 colors=list(stroke="red", none="blue"),n.icons = 100, icon.style = 2, force.fill = 'most')
    personograph(values, fig.title = paste(interv,"Intervention"),fig.cap = "Risk Estimate", draw.legend = T,
                 colors=list(stroke="red", none="blue"), n.icons = 100, icon.style = 2, force.fill = 'most')
    return(a)
  }

  ecgEndpoint <- paste(messagePasserHostProtocol, messagePasserHost, "/Observation/", Sys.getenv("SHINYPROXY_USERNAME"), "/131328/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", "", sep="")

  if ( url.exists(ecgEndpoint, cainfo=Sys.getenv("CURL_CA_BUNDLE")) ) {

    ecg<-read.table(ecgEndpoint, header=TRUE, colClasses=colClasses)
    rownames(ecg) <- 1:nrow(ecg);

    output$plotECG <- renderPlot({
      rawECG <- ecg$c131389
      tidyECG <- gsub(" ","\n", rawECG)
      ECGtable = read_csv(tidyECG, col_names = F)
      ECGtable <- ECGtable %>% mutate(id = row_number())
      ECGtable %>%
        filter(between(id, input$sliderECG, input$sliderECG + 500 ) ) %>%
        ggplot(aes(x=id, y=X1)) +
        geom_line() +
        theme(
          panel.background = element_rect(fill = NA),
          panel.grid.major = element_line(colour = "grey50"),
          panel.ontop = TRUE
        ) +
        scale_y_continuous(name="mV", labels = scales::unit_format(unit = "", scale = 1e-0, sep = "")) +
        scale_x_discrete(name="Observations")
    })

  }

  observeEvent(input$actChatUser, {
    triggerId <- paste(  "/p1u", input$inDevice, sep=" ")
    cat(triggerId ,file="/home/kai/r_shiny_write/trigger.csv", append=TRUE)
  })

  # Info Boxes
  # https://fontawesome.com/icons?d=gallery&c=emoji&m=free for icons
  output$boxBP <- renderValueBox({
    valueBox(
      "Blood Pressure", paste0("135/85", " mmHg"), icon = icon("thumbs-up"), color = "orange"
    )
  })
  output$boxHR <- renderValueBox({
    valueBox(
      "Heart Rate", paste0(135, " bpm"), icon = icon("thumbs-up"), color = "green"
    )
  })
  output$boxECG <- renderValueBox({
    valueBox(
      "ECG", paste0("Normal", ""), icon = icon("stethoscope"), color = "green"
    )
  })
  output$boxMood <- renderValueBox({
    valueBox(
      "Mood", paste0("Positive", ""), icon = icon("grin-alt"), color = "green"
    )
  })
  output$boxPain <- renderValueBox({
    valueBox(
      "Pain", paste0("4", " on scale of 1 to 5"), icon = icon("ambulance"), color = "red"
    )
  })

}

# Run the application
shinyApp(ui = ui, server = server)
