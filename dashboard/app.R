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

# tabSteps <- fread("/home/kai/posture/data/dummy-data_transformed20180909.csv")
colorList <- c( "#00AA2C", "#85D79B",  "#E70000", "#E78A8C", "#0075B7", "#509ECB")
# patients <- c("Peter User" = "/p1u", "Sally S a" = "/p1sa", "Sally S b" = "/p1sb", "Harry U" = "/p2u", "Harry S a" = "/p2sa", "Harry S b" = "/p2sb")
devices  <- c("Tablet 1" = "631855225", "Liz" = "526968496" , "Kai" = "574621511", "Elizabeth" = "425168183", "Isabel" = "681816550" )

ui <- fluidPage(
  # includeCSS("styles.css"),

  # fluidRow(
  #   column(9, # style = "margin-top: 25px;", # move button in line with other relements
  #          titlePanel("Your Stroke Companion")
  #   ),
  #   # column(1, style = "margin-top: 25px;",
  #   #       actionButton("actChatUser", label = "Start Chat")
  #   #)
  #   column(1, style = "margin-top: 25px;",actionButton("actChatSysA", label = "a") ),
  #   column(1, style = "margin-top: 25px;",actionButton("actChatSysB", label = "b") )
  # ),

  navbarPage( "CONSULT",  # tabsetPanel(
            tabPanel("Summary",
                     #br(),
                     h3("My Health Summary"),
                     br(),
                     # http://www.ehes.info/rc/tools/EHES_reporting_options_using_R_publish.html !!
                     # img(src="consult_summary_panos_screenshot.png")

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
                    # img(src="consult_demo_heartrate_Screenshot.png")
                    h3("Heartrate"),
                    br(),
                    fluidRow(
                      column(1 , "Timeframe: "),
                      column(3 , selectInput("radioHRTimeframe", label = NULL,
                                              choices = list("Overview" = "overview" ),
                                              selected = "overview") )
                    ),
                    plotOutput("plotHR"),
                    br(),
                    verbatimTextOutput("printHR")
          ),
           tabPanel("Blood Pressure",
                    h3("Blood Pressure"),
                    br(),
                    # fluidRow(
                    #   # column(1 ),
                    #   column(6,
                    #          sliderInput("inDay", label = "Select a Day", min = 1, max = 84, value = 82, width = "200%")
                    #          # label = h3("Weeks Range")
                    #   )
                    # ),
                    # fluidRow(
                    #   column(5,plotlyOutput("plotStepsDay") )
                    # )
                    fluidRow(
                      # column(6,
                      #        sliderInput("inWeeksRange", label = "Week Range", min = 1, max = 12, value = c(11, 12), width = "200%")
                      #        # label = h3("Weeks Range")
                      # )
                      column(1 , "Timeframe: "),
                      column(3 , selectInput("radioBPTimeframe", label = NULL,
                                             choices = list("Overview" = "overview" , "Weekly DBP" = "dbp", "Weekly SBP" = "sbp" ),
                                             selected = "overview") )
                    ),
                    plotOutput("plotBP")

                    # plotlyOutput("plotTempBoot")
           ),
          tabPanel("ECG",
                   h3("ECG Monitoring"),
                   br(),
                   sliderInput("sliderECG", "Observations:",
                               min = 0, max = 5000, value = 0, step = 10, animate = animationOptions( interval = 300, loop = TRUE)
                   ),
                   plotOutput("plotECG")

                   # img(src="Normal_Sinus_Rhythm_Unlabeled.jpg")
                   # Normal_Sinus_Rhythm_Unlabeled.jpg
                   # p("The heart rhythm is irregular. The P wave morphology is abnormal with negative P waves in the inferior leads, an almost negative P wave in lead I and a positive P wave in lead aVR. This indicates a lower left atrial origin. The cycle length of this rhythm is 640 ms (rate slightly lower than 100 beats/min). The wide intervals on the ECG result from a blocked atrial impulse every fourth beat. The block is at the level of the origin of the atrial impulse, i.e. an exit block of the focal impulse. Atrioventricular and ventricular conduction are normal. Repolarisation is abnormal and might be explained by the use of digoxin. Atrial tachycardia with AV block might be seen in the setting of toxic digoxin concentrations but in this case the level of block is not at the atrioventricular junction. So, there is no reason to consider this cause. Electrical cardioversion could bring this abnormal rhythm back to normal sinus rhythm.")
                   # fluidRow(
                   #   # column(1 ),
                   #   column(6,
                   #          sliderInput("inDay", label = "Select a Day", min = 1, max = 84, value = 82, width = "200%")
                   #          # label = h3("Weeks Range")
                   #   )
                   # ),
                   # fluidRow(
                   #   column(5,plotlyOutput("plotStepsDay") )
                   # )
          ),
          tabPanel("Risk",
                   #br(),
                   h3("Predicted Risk of Stroke if You Stop Smoking"),
                   br(),
                   img(src="predicted-risk-of-stroke-if-you-stop-smoking.png")
                   # img(src="cates-plot-stroke-risk-stop-smoking.pdf")
                   # fluidRow(
                   #   # column(1 ),
                   #   column(6,
                   #          sliderInput("inDay", label = "Select a Day", min = 1, max = 84, value = 82, width = "200%")
                   #          # label = h3("Weeks Range")
                   #   )
                   # ),
                   # fluidRow(
                   #   column(5,plotlyOutput("plotStepsDay") )
                   # )
          ),
          tabPanel("Recommendation",
                   h3("Recommendation"),
                   br(),
                   p("Consider changing your painkiller; there are two options:"),
                   p("Given your medical history and that paracetamol helps with back pain then paracetamol is recommended. It is recommended that you consider 'paracetamol'."),
                   p("Given your medical history and that codeine helps with back pain then codeine is recommended.")
                   # fluidRow(
                   #   # column(1 ),
                   #   column(6,
                   #          sliderInput("inDay", label = "Select a Day", min = 1, max = 84, value = 82, width = "200%")
                   #          # label = h3("Weeks Range")
                   #   )
                   # ),
                   # fluidRow(
                   #   column(5,plotlyOutput("plotStepsDay") )
                   # )
          ),
           tabPanel("Chat",
                    h3("Start Interactive Chat"),
                    br(),
                    fluidRow(
                      # column(2, selectInput(inputId = "inPatientId", label = "Patient", choices = patients, width = "100px" ) ),
                      column(2, selectInput(inputId = "inDevice", label = "Device", choices = devices, width = "100px" ) ),
                      column(2, style = "margin-top: 25px;",actionButton("actChatSysA", label = "System Chat A") ),
                      column(2, style = "margin-top: 25px;",actionButton("actChatSysB", label = "System Chat B") ),
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
           # tabPanel("Data",
           #          fluidRow(
           #            column(2, verbatimTextOutput("outWeeksRange")),
           #            column(2, verbatimTextOutput("outView")),
           #            column(2, verbatimTextOutput("outLocation")),
           #            column(2, verbatimTextOutput("outBootUsage")),
           #            column(2, verbatimTextOutput("outPatientId"))
           #          ),
           #          DT::dataTableOutput("outStepsBootLoc")
           # )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  ##-- Isabel Functions --##

  # Isabel data bp2 #
  colClasses <- c(datem="Date", date.month="Date")
  messagePasserHostProtocol <- Sys.getenv("MESSAGE_PASSER_PROTOCOL")
  messagePasserHost <- Sys.getenv("MESSAGE_PASSER_URL")
  hrEndpoint <- paste(messagePasserHostProtocol, messagePasserHost, "/Observation/", Sys.getenv("SHINYPROXY_USERNAME"), "/8867-4/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", "", sep="")

  if ( url.exists(hrEndpoint, cainfo=Sys.getenv("CURL_CA_BUNDLE")) ) {

    hr<-read.table(hrEndpoint, header=TRUE, colClasses=colClasses) # daily.c8867h4 table
    rownames(hr) <- 1:nrow(hr);

    #Data preparation for HR plots
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

    bp<-read.table(bpEndpoint, header=TRUE, colClasses=colClasses) # bp2 table
    #rownames(bp) <- 1:nrow(bp);

    #Data preparation
    #needed if not using the demo data - use it if using withings data
    bp$dt<-as.POSIXct(paste(bp$datem, bp$time), format="%Y-%m-%d %H:%M")

    #data preparation for BP plots
    bp$dt1<-anytime::anytime(bp$dt)
    bp$hr<-bp$c8867h4
    bp$sbp<-bp$c271649006
    bp$dbp<-bp$c271650006

    dashboard.bp<-function(period) {

      if ( period == "overview") {

        #SBP week - uses the bp data set
        #This is the default plot in the BP tab

        ggplot(data=bp, aes(dt1, sbp, color="SBP")) + stat_summary(fun.y=mean, geom = "line") +
          labs(title="Blood Pressure", x="Date and Time of Measurment") + theme_bw() +ylim(70,180) +
         # geom_hline(aes(yintercept =135),colour="#990000", linetype="dashed" ) +
        #  geom_hline(aes(yintercept =85),colour="#990099", linetype="dashed" ) +
          geom_line(aes(x = dt1, y = dbp, color="DBP")) + scale_color_discrete(name="Legend") +
          scale_x_datetime(date_breaks = "12 hour", labels=date_format("%b %d - %H:%M"))+
          theme(axis.text.x = element_text(angle = 25, vjust = 1.0, hjust = 1.0))

      } else if ( period == "dbp") {

        #DBP and SBP side by side boxplots - uses the BP data set
        #this is the plot to use when the user selects "weekly"

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

    output$plotBP <- renderPlot({ dashboard.bp(period = input$radioBPTimeframe) }) # week, month, year

  }

  risk.evidence<-read.csv("sample-data/intervention.csv") # for cates plot
  mycates<-function(interv){
    a<-risk.evidence$tr.risk[risk.evidence$intervention==interv]
    values<-list(stroke=a, none=(1-a))
    values.baseline<-list(stroke=0.07, none=(1-0.07))
    par(mfrow=c(1,2)) #does not work at present version
    personograph(values.baseline, fig.title = "Baseline", fig.cap = "Risk Estimate", draw.legend = T,
                 colors=list(stroke="red", none="blue"),n.icons = 100, icon.style = 2, force.fill = 'most')
    personograph(values, fig.title = paste(interv,"Intervention"),fig.cap = "Risk Estimate", draw.legend = T,
                 colors=list(stroke="red", none="blue"), n.icons = 100, icon.style = 2, force.fill = 'most')
    return(a)
  }
  # mycates("Stop Smoking")
  # mycates("Lower BP")
  # mycates("Lower Cholesterol")
  # mycates("Antiplatelet")


  ##------------------------------##

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
        # theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        scale_y_continuous(name="mV", labels = scales::unit_format(unit = "", scale = 1e-0, sep = "")) +
        scale_x_discrete(name="Observations")
        # labs(title = "National Portfolio Organisations in England", subtitle = "2012 - 2022")
    })

  }

  observeEvent(input$actChatUser, {
    triggerId <- paste(  "/p1u", input$inDevice, sep=" ")  # Replace with dialogueId, e.g. p1u
    cat(triggerId ,file="/home/kai/r_shiny_write/trigger.csv", append=TRUE) # False causes file truncated error in NodeRed
  })

  observeEvent(input$actChatSysA, {
    triggerId <- paste( "/p1sa", input$inDevice, sep=" ")
    cat(triggerId ,file="/home/kai/r_shiny_write/trigger.csv", append=TRUE) # False causes file truncated error in NodeRed
  })

  observeEvent(input$actChatSysB, {
    triggerId <- paste( "/p1sb", input$inDevice, sep=" ")
    cat(triggerId ,file="/home/kai/r_shiny_write/trigger.csv", append=TRUE) # False causes file truncated error in NodeRed
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
