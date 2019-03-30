library(shiny)
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
                                              choices = list("Day" = "day" , "Month" = "month", "Year" = "year" ),
                                              selected = "day") )
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
                                             choices = list("Week" = "week" , "Month" = "month", "Year" = "year" ),
                                             selected = "week") )
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
bpColClasses <- c(datem="Date", date.month="Date")
messagePasserHostProtocol <- Sys.getenv("MESSAGE_PASSER_PROTOCOL")
messagePasserHost <- Sys.getenv("MESSAGE_PASSER_URL")
messagePasserAddress <- paste(messagePasserHostProtocol, messagePasserHost, "/Observation/", Sys.getenv("SHINYPROXY_USERNAME"), "/85354-9/2016-02-26T00:00:00Z/2020-02-28T00:00:00Z", "", sep="")
bp2<-read.table(messagePasserAddress, header=TRUE, colClasses=bpColClasses) # bp2 table
rownames(bp2) <- 1:nrow(bp2);
daily.c8867h4<-read.csv("data/daily_hr-isabel-table.csv") # daily.c8867h4 table
risk.evidence<-read.csv("data/isabel-secondary-stroke-intervention-risks.csv") # for cates plot

  dashboard.c8867h4<-function(period){
    y_name<-paste("Heart Rate")
    daily.plot.title<-paste("Heart Rate last 24 hours")
    month.plot.title<-paste("Trend for Heart Rate")
    week.plot.title<-paste("Weekday plots for Heart Rate")
    year.plot.title<-paste("Trend over time for Heart Rate")
    ymin<-50
    ymax<-90
    yint<-70
    ymax.day<-120
    labels<-seq(0,72, by=6)
    if (period=="month"){
      print(ggplot(data = bp2, aes(date.month, c8867h4)) + stat_summary(fun.y= mean,  geom = "line")
            +labs(title = month.plot.title, x = "month", y=y_name ) +theme_bw() +ylim(ymin,ymax)
            + geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed" ) +
              scale_x_date( labels = date_format("%Y-%m"), breaks = "1 month"))
    }
    else if (period=="year"){
      print(ggplot(data=bp2, aes_string(bp2$datem, bp2$c8867h4)) + geom_line()) + theme_bw() +ylim(ymin,ymax)+
        geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed" )+
        labs(title = year.plot.title, x="Date", y=y_name)
    }
    else {
      print(ggplot(data=daily.c8867h4, aes(y=c8867h4.day, x=sq, group=1)) + geom_line() + theme_bw()+ ylim(ymin,ymax.day)+
              geom_hline(aes(yintercept =yint),colour="grey", linetype="dashed" ) +
              geom_hline(aes(yintercept =ymax),colour="grey", linetype="dashed" ) +
              geom_vline(aes(xintercept=12), colour="blue", linetype="dashed")  +
              geom_vline(aes(xintercept=24), colour="blue", linetype="dashed")  +
              geom_vline(aes(xintercept=36), colour="blue", linetype="dashed")  +
              geom_vline(aes(xintercept=48), colour="blue", linetype="dashed")  +
              geom_vline(aes(xintercept=60), colour="blue", linetype="dashed")  +
              annotate("text", x=12, y=50, label="12 noon")+
              annotate("text", x=24, y=50, label="4 pm")+
              annotate("text", x=36, y=50, label="6 pm")+
              annotate("text", x=48, y=50, label="midnight")+
              annotate("text", x=60, y=50, label="4 am")+
              theme(axis.text.x = element_blank(), axis.ticks = element_blank()) +
              labs(title=daily.plot.title, x = "time", y="Heart Rate"))
    }
  }

  dashboard.c8867h4.stats<-function(){
    resting.c8867h4<-tail(daily.c8867h4$c8867h4.day, n=1)
    cat(paste("Resting Heart Rate: ", round(resting.c8867h4,1), sep=""))
    mean.c8867h4<-mean(daily.c8867h4$c8867h4.day)
    cat(paste("\nAverage Heart Rate last 24 hours: ", round(mean.c8867h4,1), sep=""))
    mean.c8867h4.year<-mean(head(bp2$c8867h4, n=30))
    cat(paste("\nAverage Heart Rate last month: ", round(mean.c8867h4.year,1), sep=""))
  }

output$plotHR <- renderPlot({ dashboard.c8867h4(period = input$radioHRTimeframe) }  ) # month,year,day
output$printHR <- renderPrint({ dashboard.c8867h4.stats() }  )

dashboard.bp<-function(period){
  y1_name<-paste("Diastolic Blood Pressure")
  y2_name<-paste("Systolic Blood Pressure")
  month.plot.title<-paste("Trend for Diastolic and Sistolic Blood Pressure")
  week.plot.title1<-paste("Weekday plots for Diastolic Blood Pressure")
  week.plot.title2<-paste("Weekday plots for Systolic Blood Pressure")
  year.plot.title<-paste("Trend over time for Diastolic and Sistolic Blood Pressure")
  ymin<-60
  ymax.dia<-100
  ymax<-150
  yint1<-80
  yint2<-120

  if (period=="month"){
    ggplot() +
      stat_summary(data = bp2, aes(x = date.month, y = c271649006), color = "blue", geom = "line") +
      stat_summary(data = bp2, aes(x = date.month, y = c271650006), color = "red", geom = "line") +
      xlab("Dates") +
      ylab("Blood pressure") +
      theme_bw() +
      ggtitle("Systolic and Diastolic Blood Pressure") +
      scale_colour_manual(name='', values = c("SBP"="blue", "DBP"="red"), guide='legend') +
      guides(colour=guide_legend(override.aes = list(linecolour=c(1,1))))
  }
  else if(period=="week"){
    g1<-ggplot(bp2, aes(x=weekday, y=c271650006))+ geom_boxplot() + theme_bw() + ylim(ymin,ymax.dia) +
      geom_hline(aes(yintercept =yint1),colour="#990000", linetype="dashed")+
      labs(title = week.plot.title1, x="Day of the Week", y=y1_name)
    g2<-ggplot(bp2, aes(x=weekday, y=c271649006))+ geom_boxplot() + theme_bw() + ylim(ymin,ymax) +
      geom_hline(aes(yintercept =yint2),colour="#990000", linetype="dashed")+
      labs(title = week.plot.title2, x="Day of the Week", y=y2_name)
    plot_grid(g1,g2,labels = "AUTO")
  }
  else {
    ggplot(bp2, aes(datem))+
      geom_line(aes(y=bp2$c271649006, colour="Systolic"))+
      geom_line(aes(y=bp2$c271650006, colour="Diastolic")) + ggtitle("Blood Pressure History") +
      xlab("Date") + ylab("Measurment")

  }
}

output$plotBP <- renderPlot({ dashboard.bp(period = input$radioBPTimeframe) }  ) # week, month, year


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

#  currSteps <- reactive({
#    tabSteps[Day >= (input$inWeeksRange[1]-1)*7+1 & Day <= (input$inWeeksRange[2])*7 ]})
  currData <- reactive({
    t <- tabData[Day >= (input$inWeeksRange[1]-1)*7+1 & Day <= (input$inWeeksRange[2])*7 ]
    t
    })

  output$outWeeksRange <- renderPrint({ input$inWeeksRange })
  output$outView <- renderPrint({ input$inView })
  output$outLocation <- renderPrint({ input$inLocation })
  output$outBootUsage <- renderPrint({ input$inBootUsage })
  output$outPatientId <- renderPrint({ input$inPatientId })
  output$outStepsBootLoc <- DT::renderDataTable({ DT::datatable(currData() ) })

  output$plotTempBoot <- renderPlotly({
    # f <- list( family = "Courier New, monospace", size = 18, color = "#7f7f7f" )
    # titlefont = f,
    xTitle = paste0("Days of Week ", input$inWeeksRange[1], " to Week ", input$inWeeksRange[2])

    xf <- list(title = xTitle, fixedrange=TRUE,
               tickvals=1:84, ticktext=rep(c("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"), times=12, each=1) # Day names instead of numbers
               ) # fixrange: disable zoom
    yf <- list(fixedrange=TRUE)

      pTemp <- plot_ly(currData(), x = ~Day, y = ~tempDiff) %>%
        add_lines(name = ~"Temp Diff") %>%
        layout(yaxis= list(title = "Temperature" , ticksuffix="°C" , tickformat =".1f"),  font = list(size = 14) ) # <br>Difference

      # pSteps <- plot_ly(currData(), x = ~Day, y = ~stepsHomeBooton, name = ~"Home Boot On",
      #                   type = 'bar', marker = list( color = 'blue4') ) %>%
      pSteps <- plot_ly(currData(), x = ~Day ) %>%
        add_bars(y = ~stepsHomeBooton, name = ~"Home Boot On", marker = list( color = colorList[1]) ) %>%
        add_bars(y = ~stepsHomeBootoff, name = ~"Home Boot Off", marker = list( color = colorList[2] ) ) %>%
        add_bars(y = ~stepsWorkBooton, name = ~"Work Boot On", marker = list( color = colorList[3])) %>%
        add_bars(y = ~stepsWorkBootoff, name = ~"Work Boot Off", marker = list( color = colorList[4])) %>%
        add_bars(y = ~stepsElsewhereBooton, name = ~"Out Boot On", marker = list( color = colorList[5])) %>%
        add_bars(y = ~stepsElsewhereBootoff, name = ~"Out Boot Off", marker = list( color = colorList[6]) )  %>%
        layout(yaxis= list(title = "Steps / Day", tickformat ="d"), barmode = 'stack',  font = list(size = 14) )

      p <- subplot(pTemp, pSteps, nrows = 2, shareX = T, titleY=TRUE, heights = c(0.2, 0.8) , margin = 0.06 ) %>%
      layout(legend = list(orientation = 'h', y=-.4 , traceorder="normal", font = list(size = 14) ))  %>%
      config(displayModeBar = F) %>% # Disable toolbar
      layout(xaxis= xf) %>% layout(yaxis= yf) %>%
        layout(autosize = T, height = 500) # modify general height

      p
  })

  output$plotStepsDay <- renderPlotly({
    t <- tabData[Day == (input$inDay)]
    v <- c(t[,stepsHomeBooton],t[,stepsHomeBootoff],t[,stepsWorkBooton],t[,stepsWorkBootoff],t[,stepsElsewhereBooton],t[,stepsElsewhereBootoff])
    l <- c("Home Boot On","Home Boot Off","Work Boot On","Work Boot Off", "Out Boot On","Out Boot Off")
    p <- plot_ly(t,
                 labels = l,
                 values = v,
                 type = 'pie',
                 textposition = 'inside',
                 textinfo = 'label+percent',
                 insidetextfont = list(color = '#FFFFFF'),
                 hoverinfo = 'text',
                 text = ~paste('', v, ' steps'),
                 marker = list(colors = colorList,
                               line = list(color = '#FFFFFF', width = 1)),
                 showlegend = FALSE
                 ) %>%
      config(displayModeBar = F) %>% # Disable toolbar
      layout( title = 'Steps with/without Boot by Location',
              # margin=list(l = 0, r = 0, b = 00, t = 00, pad = 0 ),
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, fixedrange=TRUE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, fixedrange=TRUE),
             autosize = F, width = 500, height = 500
      )
    p
  })



  output$plotECG <- renderPlot({
    rawECG <- read_file("../data/vitalpatch_ecg_data_short-sample.txt")
    tidyECG <- gsub("[0-9]{13},","", rawECG)
    tidyECG <- gsub(",","\n", tidyECG)
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
