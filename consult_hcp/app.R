#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)
library(DT)
library(plotly)
library(jsonlite)

# csv files had header manually added

bp <- fread("/home/ubuntu/bloodpressure.txt")
hr <- fread("/home/ubuntu/pulse.txt")
ct <- fread("/home/ubuntu/stepcount.txt")
patients <- unique(bp[,pid])
ehr <- unlist(fromJSON("/home/ubuntu/ehr2.json"))
nokia <- fread("/home/ubuntu/nokia.csv")


ui <- fluidPage(
  titlePanel("CONSULT HCP Dashboard"),
  # h2("The mtcars data"),
   selectInput(inputId = "pid",
               label = "Choose a patient:",
               choices = patients ),
  tabsetPanel(
           id = 'dataset',
           tabPanel("Chat", 
                    fluidRow( 
                      tags$iframe(
                        seamless = "seamless", 
                        src = "http://34.253.209.199:57329/shinydocs/consult-demo/chat3.html",
                        # src = "https://forecast.io/embed/#lat=42.3583&lon=-71.0603&name=Downtown Boston", 
                        # src = "https://web.telegram.org/#/im?p=@kclconsultbot",
                        height = 800, width = 1400
                      )
                    )
           ),
           tabPanel("EHR", verbatimTextOutput("ehr_print")),
           tabPanel("BP", plotlyOutput("bp_plot"), DT::dataTableOutput("bp_table")),
           tabPanel("HR", plotlyOutput("hr_plot"), DT::dataTableOutput("hr_table")),
           tabPanel("Step Count", plotlyOutput("ct_plot"), DT::dataTableOutput("ct_table")),
           tabPanel("Nokia Activity", plotlyOutput("nokia_plot"), DT::dataTableOutput("nokia_table"))
  )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # choose columns to display
  # diamonds2 = diamonds[sample(nrow(diamonds), 1000), ]
  output$bp_table <- DT::renderDataTable({
    # DT::datatable(diamonds2[, input$show_vars, drop = FALSE])
    DT::datatable(bp[pid == input$pid ])
  })

  output$bp_plot <- renderPlotly({
    t <- bp[pid == input$pid]
    # plot_ly( t, x = ~seq(1, nrow(t)), y = ~dia , type = 'scatter', mode = 'lines' )# mtcars, x = ~mpg, y = ~wt)
    plot_ly(t, x = ~seq(1, nrow(t))) %>%
      add_trace(y = ~dia, name = 'Diastolic',mode = 'lines') %>%
      add_trace(y = ~sys, name = 'Systolic', mode = 'lines+markers') %>%
      add_trace(y = ~hr, name = 'HR', mode = 'markers')  %>% layout(xaxis = list(title = "x Axis"), yaxis = list(title = "y Axis") )
  })    
  
  # sorted columns are colored now because CSS are attached to them
  output$hr_table <- DT::renderDataTable({
    # DT::datatable(mtcars, options = list(orderClasses = TRUE))
    DT::datatable(hr[pid == input$pid ])
  })
  
  output$hr_plot <- renderPlotly({
    t <- hr[pid == input$pid]
    plot_ly( t, x = ~seq(1, nrow(t)), y = ~hr , type = 'scatter', mode = 'lines' ) %>% layout(xaxis = list(title = "x Axis"), yaxis = list(title = "bpm") )
  }) 
  
  # customize the length drop-down menu; display 5 rows per page by default
  output$ct_table <- DT::renderDataTable({
    # DT::datatable(iris, options = list(lengthMenu = c(5, 30, 50), pageLength = 5))
    DT::datatable(ct[pid == input$pid ])
  })
  
  output$ct_plot <- renderPlotly({
    t <- ct[pid == input$pid]
    plot_ly( t, x = ~seq(1, nrow(t)), y = ~ct , type = 'scatter', mode = 'lines' ) %>% layout(xaxis = list(title = "x Axis"), yaxis = list(title = "Steps") )
  }) 
  
  output$ehr_print <- renderPrint({
    # DT::datatable(diamonds2[, input$show_vars, drop = FALSE])
    sprintf("%s : %s", names(ehr), ehr)
    # paste(names(ehr), ehr, sep = ":", collapse = '\n') 
  })
  
  output$nokia_table <- DT::renderDataTable({
    # DT::datatable(diamonds2[, input$show_vars, drop = FALSE])
    DT::datatable(nokia)
  })
  
  output$nokia_plot <- renderPlotly({
    t <- nokia
    plot_ly( t, x = ~seq(1, nrow(t)), y = ~steps , type = 'scatter', mode = 'lines+markers' )# mtcars, x = ~mpg, y = ~wt)
    #plot_ly(t, x = ~seq(1, nrow(t))) %>%
    #  add_trace(y = ~steps, name = 'Steps',mode = 'lines') %>%
      # add_trace(y = ~sys, name = 'Systolic', mode = 'lines+markers') %>%
      # add_trace(y = ~hr, name = 'HR', mode = 'markers')  %>% 
     # layout(xaxis = list(title = "x Axis"), yaxis = list(title = "y Axis") )
  }) 

}

# Run the application 
shinyApp(ui = ui, server = server)
