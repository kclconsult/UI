library(shiny)
library(data.table)
library(DT)
library(plotly)
library(jsonlite)
library(ggplot2)
library(dplyr)
library(scales)

tabData  <- fread("/home/kai/posture/data/betsy_dummy_data_dfu20180912.csv")
# tabSteps <- fread("/home/kai/posture/data/dummy-data_transformed20180909.csv")
colorList <- c( "#00AA2C", "#85D79B",  "#E70000", "#E78A8C", "#0075B7", "#509ECB")
# patients <- c("Peter User" = "/p1u", "Sally S a" = "/p1sa", "Sally S b" = "/p1sb", "Harry U" = "/p2u", "Harry S a" = "/p2sa", "Harry S b" = "/p2sb")
devices  <- c("Tablet 1" = "631855225", "Liz" = "526968496" , "Kai" = "574621511", "Elizabeth" = "425168183", "Isabel" = "681816550" )

# Isabel data bp2 #
load("/home/kai/consult/data/isabel20181120demodata.Rdata")


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

  navbarPage( "Stroke Companion",  # tabsetPanel(
            tabPanel("Summary",
                     br(),
                     h3("Here go the summary traffic lights"),
                     # http://www.ehes.info/rc/tools/EHES_reporting_options_using_R_publish.html !!
                     img(src="consult_demo_overview_Screenshot.png")
              ),
           tabPanel("Heartrate",
                    img(src="consult_demo_heartrate_Screenshot.png")
          ),
           tabPanel("Blood Pressure",
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
                      column(6,
                             sliderInput("inWeeksRange", label = "Week Range", min = 1, max = 12, value = c(11, 12), width = "200%")
                             # label = h3("Weeks Range")
                      )
                    ),
                    plotlyOutput("plotTempBoot") 
           ),
          tabPanel("ECG",
                   br(),
                   h3("Here goes the ECG qualifier"),
                   p("The heart rhythm is irregular. The P wave morphology is abnormal with negative P waves in the inferior leads, an almost negative P wave in lead I and a positive P wave in lead aVR. This indicates a lower left atrial origin. The cycle length of this rhythm is 640 ms (rate slightly lower than 100 beats/min). The wide intervals on the ECG result from a blocked atrial impulse every fourth beat. The block is at the level of the origin of the atrial impulse, i.e. an exit block of the focal impulse. Atrioventricular and ventricular conduction are normal. Repolarisation is abnormal and might be explained by the use of digoxin. Atrial tachycardia with AV block might be seen in the setting of toxic digoxin concentrations but in this case the level of block is not at the atrioventricular junction. So, there is no reason to consider this cause. Electrical cardioversion could bring this abnormal rhythm back to normal sinus rhythm.")
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
                   br(),
                   h3("Here goes the Risk indicator"),
                   img(src="cates-plot-baseline.png"),
                   img(src="cates-plot-no-smoking.png")
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
                   br(),
                   h3("Here goes the recommendation summary"),
                   p("Adjust medication: Increase daily Lisinopril dose from 10 mg to 15 mg.")
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
                    fluidRow( 
                      # column(2, selectInput(inputId = "inPatientId", label = "Patient", choices = patients, width = "100px" ) ),
                      column(2, selectInput(inputId = "inDevice", label = "Device", choices = devices, width = "100px" ) ),
                      column(2, style = "margin-top: 25px;",actionButton("actChatSysA", label = "System Chat A") ),
                      column(2, style = "margin-top: 25px;",actionButton("actChatSysB", label = "System Chat B") ),
                      column(2, style = "margin-top: 25px;",actionButton("actChatUser", label = "User Chat") )
                    )
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
  dashboard<-function(yvar,period){
    #Setting the labels
    if (yvar=="sys"){
      y_name<-paste("Systolic Blood Pressure")
      month.plot.title<-paste("Trend for Systolic Blood Pressure")
      week.plot.title<-paste("Weekday plots for Systolic Blood Pressure")
      year.plot.title<-paste("Trend over time for Systolic Blood Pressure")
      ymin<-90
      ymax<-150
      yint<-140
    }
    else if (yvar=="dia"){
      y_name<-paste("Diastolic Blood Pressure")
      month.plot.title<-paste("Trend for Diastolic Blood Pressure")
      week.plot.title<-paste("Weekday plots for Diastolic Blood Pressure")
      year.plot.title<-paste("Trend over time for Diastolic Blood Pressure")
      ymin<-60
      ymax<-100
      yint<-80
    }
    else {
      y_name<-paste("Heart Rate")
      month.plot.title<-paste("Trend for Heart Rate")
      week.plot.title<-paste("Weekday plots for Heart Rate")
      year.plot.title<-paste("Trend over time for Heart Rate")
      ymin<-50
      ymax<-90
      yint<-70
    }
    #different plots based on selection of time scale 
    if (period=="month"){
      print(ggplot(data = bp2, aes(date.month, get(yvar))) + stat_summary(fun.y= mean,  geom = "line") 
            +labs(title = month.plot.title, x = "month", y=y_name ) +theme_bw() +ylim(ymin,ymax) 
            + geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed" ))
      scale_x_date( labels = date_format("%Y-%m"), breaks = "1 month")
    }
    
    else if (period=="week"){
      print(ggplot(bp2, aes(x=weekday, y=dia )) + geom_boxplot(fill='#999999') + theme_bw() + ylim(ymin,ymax)
            +geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed")+ labs(title = week.plot.title, x="Day of the Week", y=y_name))
    }
    
    else {
      print(ggplot(data=bp2, aes_string(bp2$datem, yvar)) + geom_line()) + theme_bw() +ylim(ymin,ymax)+
        geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed" )+
        labs(title = year.plot.title, x="Date", y=y_name)
    } 
  }
  
  output$plotHRsysMonth <- renderPlot({
  dashboard(yvar="sys",period = "month")
  
  
  
  ##-----##
  
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
}

# Run the application 
shinyApp(ui = ui, server = server)
