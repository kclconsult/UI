# Isabel Sassoon
# November 2018
# Consult

#This code assumes there are more than 365 data points in order to look ok

library(ggplot2)
library(dplyr)
library(scales)
library(cowplot)


setwd("/Users/isabelsassoon/Documents/CONSULT/case study june 18")

load("demodata.Rdata")
load("daily-hr.Rdata")

dashboard.hr<-function(period){
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
  print(ggplot(data = bp2, aes(date.month, hr)) + stat_summary(fun.y= mean,  geom = "line") 
        +labs(title = month.plot.title, x = "month", y=y_name ) +theme_bw() +ylim(ymin,ymax) 
        + geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed" ) + 
          scale_x_date( labels = date_format("%Y-%m"), breaks = "1 month"))
  } 
  else if (period=="year"){
    print(ggplot(data=bp2, aes_string(bp2$datem, bp2$hr)) + geom_line()) + theme_bw() +ylim(ymin,ymax)+
      geom_hline(aes(yintercept =yint),colour="#990000", linetype="dashed" )+
      labs(title = year.plot.title, x="Date", y=y_name)
  }
  else {
    print(ggplot(data=daily.hr, aes(y=hr.day, x=sq, group=1)) + geom_line() + theme_bw()+ ylim(ymin,ymax.day)+
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

###############################################################

dashboard.hr(period = "month")
dashboard.hr(period = "year")
dashboard.hr(period = "day")

###############################################################
# function for summaries of the heart rate
#needs the daily and monthly HR data sets :
load("demodata.Rdata")
load("daily-hr.Rdata")


dashboard.hr.stats<-function(){
  resting.hr<-tail(daily.hr$hr.day, n=1)
  print(paste("Resting Heart Rate  ", resting.hr, sep=":"))
  mean.hr<-mean(daily.hr$hr.day)
  print(paste("Average Heart Rate last 24 hours ", mean.hr, sep=":"))
  mean.hr.year<-mean(head(bp2$hr, n=30))
  print(paste("Average Heart Rate last month ", mean.hr.year, sep=":"))
  }

dashboard.hr.stats()