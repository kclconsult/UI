#This script creates Cates plots for different interventions
#the risks associated with the different interventions are in a csv file
#the risks are extracted from:
#Treatment and secondary prevention of stroke: evidence, costs, and effects on individuals and populations - 
#hankey, warlow ,Lancet, 1999
#Isabel Sassoon - July 2018 - CONSULT
#####################################################################

#need to load the evidence data
setwd("/Users/isabelsassoon/Documents/CONSULT/case study june 18")
risk.evidence<-read.csv("secondary-stroke-intervention-risks.csv")

#need to load the required library
library(personograph)

#possible values currently in evidencefor the function: Antiplatelet, Lower BP, Lower Cholesterol, Stop Smoking

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

mycates("Stop Smoking")
mycates("Lower BP")
mycates("Lower Cholesterol")
mycates("Antiplatelet")