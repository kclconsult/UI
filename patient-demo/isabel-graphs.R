# Isabel Sassoon
# November 2018
# Consult

#This code assumes there are more than 365 data points in order to look ok

library(ggplot2)
library(dplyr)
library(scales)
library(data.table)


# setwd("/Users/isabelsassoon/Documents/CONSULT/case study june 18")

load("/home/kai/consult/data/isabel20181120demodata.Rdata")

# bp2 <- fread("/home/kai/consult/data/bp2-isabel.csv")

# Problems with loading data: Different structure of DF!
# > bp2 <- fread("/home/kai/consult/data/bp2-isabel.csv")
#   > str(bp2)
# Classes ‘data.table’ and 'data.frame':	375 obs. of  6 variables:
#   $ dia       : int  83 85 75 75 76 70 81 76 70 79 ...
# $ sys       : int  107 96 143 101 138 121 117 133 100 97 ...
# $ hr        : int  58 66 65 63 78 75 68 51 77 74 ...
# $ datem     : chr  "2017-01-01" "2017-01-02" "2017-01-03" "2017-01-04" ...
# $ date.month: chr  "2017-01-01" "2017-01-01" "2017-01-01" "2017-01-01" ...
# $ weekday   : chr  "Sunday" "Monday" "Tuesday" "Wednesday" ...
# - attr(*, ".internal.selfref")=<externalptr> 
#   > rm(list=ls())
# > load("/home/kai/consult/data/isabel20181120demodata.Rdata")
# > str(bp2)
# 'data.frame':	375 obs. of  6 variables:
#   $ dia       : int  83 85 75 75 76 70 81 76 70 79 ...
# $ sys       : int  107 96 143 101 138 121 117 133 100 97 ...
# $ hr        : int  58 66 65 63 78 75 68 51 77 74 ...
# $ datem     : Date, format: "2017-01-01" "2017-01-02" "2017-01-03" "2017-01-04" ...
# $ date.month: Date, format: "2017-01-01" "2017-01-01" "2017-01-01" "2017-01-01" ...
# $ weekday   : Factor w/ 7 levels "Monday","Tuesday",..: 7 1 2 3 4 5 6 7 1 2 ...


##############################################################
#The graphs start from here
#yvar is the measure of interest and can be sys, dia or hr
#period can be: year (which is the default and will be delivered if any other value is used), month or week
#this code assumes that there is a R data set bp2 and it loads it.

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


##############################################################


 dashboard(yvar="sys",period = "month")
# dashboard(yvar="dia", period = "week")
# dashboard(yvar="hr", period = "month")
# dashboard(yvar="hr", period = "other")

##############################################################

