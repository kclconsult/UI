library(shiny)
library(data.table)
library(DT)
library(plotly)
library(jsonlite)

tabData  <- fread("/home/kai/posture/data/betsy_dummy_data_dfu20180912.csv")
# tabSteps <- fread("/home/kai/posture/data/dummy-data_transformed20180909.csv")
colorList <- c( "#00AA2C", "#85D79B",  "#E70000", "#E78A8C", "#0075B7", "#509ECB")
# patients <- c("Peter User" = "/p1u", "Sally S a" = "/p1sa", "Sally S b" = "/p1sb", "Harry U" = "/p2u", "Harry S a" = "/p2sa", "Harry S b" = "/p2sb")
devices  <- c("Tablet 1" = "631855225", "Liz" = "526968496" , "Kai" = "574621511", "Elizabeth" = "425168183", "Isabel" = "681816550" )

ui <- fluidPage(
  includeCSS("styles.css"),
  
  fluidRow(
    column(9, # style = "margin-top: 25px;", # move button in line with other relements
           titlePanel("DFU Companion for Peter")
    ),
    # column(1, style = "margin-top: 25px;",
    #       actionButton("actChatUser", label = "Start Chat")
    #)
    column(1, style = "margin-top: 25px;",actionButton("actChatSysA", label = "a") ),
    column(1, style = "margin-top: 25px;",actionButton("actChatSysB", label = "b") )
  ),

  tabsetPanel(
           tabPanel("Temperature / Steps",
                    fluidRow( 
                      column(6,
                           sliderInput("inWeeksRange", label = "Week Range", min = 1, max = 12, value = c(11, 12), width = "200%")
                           # label = h3("Weeks Range")
                      )
                    ),
                    plotlyOutput("plotTempBoot") 
          ),
           tabPanel("Boot Usage for a Day",
                    br(),
                    fluidRow( 
                      # column(1 ),
                      column(6,
                             sliderInput("inDay", label = "Select a Day", min = 1, max = 84, value = 82, width = "200%")
                             # label = h3("Weeks Range")
                      )
                    ),
                    fluidRow( 
                      column(5,plotlyOutput("plotStepsDay") )
                    )
           ),
           tabPanel("A", 
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
