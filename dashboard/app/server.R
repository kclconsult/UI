# CONSULT Demonstration Shiny Application
#
# Author: chipp.jansen@kcl.ac.uk
# Date: July 2019
#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#

library(C3)
library(shiny)

# local modules
source("components.R")
source("services.R")

# server function with input and output objects.
# input - references to events and input from the client
# output - references to output objects to update in client
function(input, output) {
    
    #
    # Load Datasets and generate statistics
    #
    # - Blood Pressure
    datasetBP = loadBloodPressureData()
    statsBP = summaryBloodPressureStats(datasetBP) # TODO - maybe stats can be generated in loadX function and combined in dataframe?
    
    # - Heart Rate
    datasetHR = loadHeartRateData()
    statsHR = summaryHeartRateStats(datasetHR)

    # - ECG
    datasetECG = loadECGData()
    statsECG = summaryECGStats(datasetECG)

    #
    # Tab: Summary
    #
    # Select different time-range events (TODO change from actionButtons to tabbed selector)
    observeEvent(input$selectLastFourHours, {
        print("Summary: Last Four Hours")
    })
    
    observeEvent(input$selectLastDay, {
        print("Summary: Last 24 Hours")
    })
    
    observeEvent(input$selectLastMonth, {
        print("Summary: Last Month")
    })

    # Summary Boxes (TODO - make reactive to selectors)
    output$summaryBP = renderSummaryBP()
    output$summaryHR = renderSummaryHR()
    output$summaryECG = renderSummaryECG()
    output$summaryMood = renderSummaryMood()
    output$summaryPain = renderSummaryPain()

    #
    # Tab: Heart Rate (HR)
    #
    output$plotHR = renderC3Timeline({
        C3Timeline(dataset = datasetHR)
    })
    
    #
    # Tab: Blood Pressure (BP)
    #
    output$plotBP = renderC3Timeline({
        C3Timeline(dataset = datasetBP)
    })

    #
    # Tab: ECG
    #
    output$plotECG = renderC3Timeline({
        C3Timeline(dataset = datasetECG)
    })

    #
    # Tab: Risk
    #
    output$plotRisk = renderRisk() # TBD - htmlwidget
  
    #
    # Tab: Recommendations
    #
    output$listRecommendations = renderRecommendations()
  
    #
    # Tab: FAQ
    #
    output$listFAQ = renderFAQ()
  
    #
    # Tab: Medication
    #
    output$summaryMeds = renderSummaryMeds()
  
    #
    # Tab: Mood
    #
    output$selectorMood = renderMood()
  
    #
    # Tab: Feedback
    #
    output$logFeedback = renderFeedback()
 
}

# From Sandbox...

    # Variables defined in this function persist while the server is running.
    # Reactivity can be defined either through using, observeEvent(), or 
    # a reactive() block of code.
    
    # In the order that they are presented on the sandbox page:
    
    # Demonstrating Client-Server Interactivity

    # Action button is clicked event handler
    # times = 0 # track number of times clicked
    # 
    # observeEvent(input$actionBtn, {
    #     print("actionBtn: Button Clicked")
    # 
    #     # <<- is the assignment operator in parent (i.e. global) environments
    #     times <<- times + 1 
    # 
    #     # Render the Button Alert
    #     output$buttonHTML <- renderButtonAlert(times)
    # })
    # 
    # # ---
    # 
    # # Slider value is changed event handler
    # observeEvent(input$sliderX, {
    #     print("sliderX")
    #     print(input$sliderX)
    # 
    #     # Render the Progress Bar
    #     output$sliderProgressHTML <- renderSliderProgress(input$sliderX)
    # })
    # 
    # # Demonstrate Text Input->Output
    # 
    # # Textarea
    # observeEvent(input$exampleText, {
    #     print("exampleText")
    #     print(input$exampleText)
    #     
    #     # Render the Input Text as Reccomendation Text
    #     output$recommendationsText <- renderText(input$exampleText)
    # })
    # 
    # # Demonstrate HTML Widget (C3 Gauge)
    # 
    # # reactive expression that generates a random value for the gauge
    # # https://www.rdocumentation.org/packages/shiny/versions/1.3.2/topics/reactive
    # gaugeValue = reactive({
    #     input$updateBtn # only exists in the expression to make it react the input event
    #     round(runif(1,0,100), 2)
    # })
    # 
    # output$gauge1 <- renderC3Gauge({
    #     # C3Gauge widget
    #     C3Gauge(gaugeValue())
    # })
    # 
    # # Demonstrate HTML Widget (C3 Timeline) with Random Data
    # 
    # # reactive expression for the data
    # timelineData = reactive({
    #     input$refreshDataButton # only exists in the expression to make it react the input event
    # 
    #     # Example Timeline Data ('Time' -> x-axis, any other key's are plotted as lines on y-axis):
    #     # timelineData = data.frame(Time = c("2016-01-01","2016-01-02","2016-01-03"), A=c(1,4,7), B=c(2,5,9))
    #     
    #     # Verify the data by converting to JSON, does this match what the chart expects?
    #     # toJSON(timelineData)
    #     # [{"Time":"2016-01-01","A":1,"B":2},{"Time":"2016-01-02","A":4,"B":5},{"Time":"2016-01-03","A":7,"B":9}] 
    #     
    #     # Random Values
    #     data.frame(Time = c("2016-01-01","2016-01-02","2016-01-03", "2016-01-04","2016-01-05","2016-01-06"),
    #                       A=round(runif(6,0,100), 2),
    #                       B=round(runif(6,0,100), 2),
    #                       C=round(runif(6,0,100), 2))
    # })
    # 
    # output$timeline1 <- renderC3Timeline({
    #     C3Timeline(dataset = timelineData())
    # })
    # 
    # # Demonstrate Sample Data
    # sampleData <- loadSampleTimelineData()
    # step = 1
    # windowSize = 7
    # 
    # # reactive expression for the data
    # sampleTimelineData = reactive({
    #     input$moreDataButton
    #     windowSize <<- windowSize + 1 
    # 
    #     # Show a windowSize data frame at a specific step
    #     #data.frame(Time       = as.vector(sampleData$datem[step:(step+windowSize)]),
    #     #           c27164900  = as.vector(sampleData$c271649006[step:(step+windowSize)]),
    #     #           c271650006 = as.vector(sampleData$c271650006[step:(step+windowSize)]),
    #     #           c8867h4    = as.vector(sampleData$c8867h4[step:(step+windowSize)]))
    # 
    #     # return a slice of data the size of windowSize:
    #     sampleData[step:(step+windowSize),]
    # })
    # 
    # output$timeline2 <- renderC3Timeline({
    #     C3Timeline(dataset = sampleTimelineData())
    # })












