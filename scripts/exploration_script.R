####This is an exploration script of the data base Base_Clase_Rasgos.csv

#The first thing we need to do is loading the database.
#Probably is always better to set the working directory in the scripts folders.
setwd("scripts/")

#Then we need to load the database
base_rasgos <- read.csv("../data/Base_Clase_Rasgos.csv")

#What is the structure in the data base
str(base_rasgos)
## Turn variables to factors
base_rasgos$order<- as.factor(base_rasgos$order)
base_rasgos$family <- as.factor(base_rasgos$family)

#How many orders do we have?
order<-c(base_rasgos$order)
order<-factor(order)
length(levels(order))
#We have 56 orders
#How many families do we have?
family<-c(base_rasgos$family)
family<-factor(family)
length(levels(family))
#We have 175 families

#How many species do we have per family?
table(base_rasgos$family)

#Can we sort de table from families with more species to families with less species?
#Make table in decreasing order of species per family
table(base_rasgos$family)

# yes, with sort command
sort(table(base_rasgos$family))

#As default, this table appears in increasing order. Use decreasing=TRUE for inverting order
sort(table(base_rasgos$family), decreasing=TRUE)

## listo...


