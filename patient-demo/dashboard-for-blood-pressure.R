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
# This function only produces graphs related to blood pressure (no hr)
# Uses the bp2 data set as starting point
#This should be used to populate the Blood Pressure Tab

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
    stat_summary(data = bp2, aes(x = date.month, y = sys), color = "blue", geom = "line") +
    stat_summary(data = bp2, aes(x = date.month, y = dia), color = "red", geom = "line") +
    xlab("Dates") +
    ylab("Blood pressure") +
    theme_bw() +
    ggtitle("Systolic and Diastolic Blood Pressure") +
    scale_colour_manual(name='', values = c("SBP"="blue", "DBP"="red"), guide='legend') +
    guides(colour=guide_legend(override.aes = list(linecolour=c(1,1))))
}
  else if(period=="week"){
    g1<-ggplot(bp2, aes(x=weekday, y=dia))+ geom_boxplot() + theme_bw() + ylim(ymin,ymax.dia) +
      geom_hline(aes(yintercept =yint1),colour="#990000", linetype="dashed")+ 
      labs(title = week.plot.title1, x="Day of the Week", y=y1_name)
    g2<-ggplot(bp2, aes(x=weekday, y=sys))+ geom_boxplot() + theme_bw() + ylim(ymin,ymax) +
      geom_hline(aes(yintercept =yint2),colour="#990000", linetype="dashed")+ 
      labs(title = week.plot.title2, x="Day of the Week", y=y2_name)
    plot_grid(g1,g2,labels = "AUTO")
}
  else {
  ggplot(bp2, aes(datem))+  
    geom_line(aes(y=bp2$sys, colour="Systolic"))+ 
    geom_line(aes(y=bp2$dia, colour="Diastolic")) + ggtitle("Blood Pressure History") + 
    xlab("Date") + ylab("Measurment")
  
}  
}

#################################################################################

dashboard.bp(period = "month")
dashboard.bp(period="year")
dashboard.bp(period = "week")




