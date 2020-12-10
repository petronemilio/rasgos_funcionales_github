
traits <- read.csv("data/2020_11_12_Base.csv")
names(traits) #revisar nombres#
str(traits)

#####exploratory analyses [XXXXXX]
#Checar existencia de outliers y corregir el problema
#tipo de variables que tenemos, que el reconocimiento sea correcto
#análisis de correlación bivariada de todas las variables
#verificar los niveles de los factores, rangos de variación de vars continuas
#datos faltantes, cuántos hay y cómo se están manejando

#####creating final consensus variables
#extraer datos de las dos fuentes y crear una nueva col donde se combinen para tener un único dato de long de hoja
#explorar la variable final de long de hoja final

#####P1. ¿Qué tanto explica la longitud de la hoja la variación en diámetro  de los vasos en la base de un árbol, con y 
#####  sin consideració de la altura? [XXXXX]
#plot con Y:diámetro basal, X1:long de hoja, X2:altura
#evaluar la necesidad de transformación de variables
#modelo; ajustarlo
#checar cumplimiento de supuestos en residuos de modelos ajustados
#checar si tenemos colinealidad  


#####P3. ¿Qué tanto explica la longitud de la hoja la variación en el diámetro  de los vasos en el ápice de un árbol, con y 
#####sin consideración de la altura? [XXXXX]
#plot con Y:diámetro apical, X1:long de hoja, X2:altura
#evaluar la necesidad de transformación de variables
#modelo; ajustarlo
#checar cumplimiento de supuestos en residuos de modelos ajustados
#checar si tenemos colinealidad  
