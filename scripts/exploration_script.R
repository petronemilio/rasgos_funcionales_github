####This is an exploration script of the data base Base_Clase_Ragos.csv

#The first thing we need to do is loading the database.
#Probably is always better to set the working directory in the scripts folders.
setwd("scripts/")

#Then we need to load the database
base_rasgos <- read.csv("../data/Base_Clase_Rasgos.csv")

#What is the structure in the data base
str(base_rasgos)

#How many orders do we have?
length(levels(base_rasgos$order))
#We have 56 orders
#How many families do we have?
length(levels(base_rasgos$family))
#We have 175 families

#How many species do we have per family?
table(base_rasgos$family)
#Can we sort de table from families with more species to families with less?




