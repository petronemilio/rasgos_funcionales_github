#Cargando la base de datos
traits <- read.csv("data/2020-12-02_Base_curso_rasgos.csv",header = TRUE,sep=",")
#Base de datos actualizada al 29-12-20
str(traits)
# Eliminar columnas que no usaremos
data <- traits[,c(1:7,11:21)] 
names(traits) #revisar nombres # Cambiar nombres
colnames(data) <- c("order","family","genus","species.epithet",
                    "stem.length.m", "VD.base.um","VD.tip.um.",
                    "min.length.leaf.cm","max.length.leaf.cm",
                    "min.length.petiole.cm", "max.length.petiole.cm",
                    "min.length.blade.cm","max.lentgh.blade.cm",
                    "min.width.blade.cm","max.width.blade.cm",
                    "leaf.type","length.leaf.cm","width.leaf.cm") 
# Crear columna con los nombres completos de las especies
data["Species"] <- paste(data$genus, data$species.epithet, sep = "_")
# En el último consenso acordamos que el tipo de hoja serviria para discriminar especies que no tuvieran datos
#Subset eliminando aquellas filas que no presentan tipo de hoja. 
data02 <- subset(data, leaf.type == "compound"|
                   leaf.type=="simple")

########## 
#Equipo: Jess-Diego-Belén-EmmanuelMtz 
#exploratory analyses [XXXXXX]
#Checar existencia de outliers y corregir el problema
#tipo de variables que tenemos, que el reconocimiento sea correcto
#análisis de correlación bivariada de todas las variables
#verificar los niveles de los factores, rangos de variación de vars continuas
#datos faltantes, cuántos hay y cómo se están manejando

#####creating final consensus variables
#extraer datos de las dos fuentes y crear una nueva col donde se combinen para tener un único dato de long de hoja
#explorar la variable final de long de hoja final

#####Estadística descriptiva. Equipo: Claudia, Brenda y Angélica, Emmanuel García 
#
#####P1. ¿Qué tanto explica la longitud de la hoja la variación en 
######diámetro  de los vasos en la base de un árbol, con y 
######sin consideració de la altura? [XXXXX]
#nombramos como objetos a las variables
x01<-data02$stem.length.m
x02<-data02$length.leaf.cm
y<-data02$VD.base.um
#plot con Y:diámetro basal, X02:long de hoja, X01:altura
##utilizando un modelo lineal
lm00<-lm(y ~ x02)
summary(lm00)
lm01<-lm(y ~ x02 + x01)
summary(lm01)
#graficamos
par(mfrow = c(1,2))
plot(x02, y)
abline(lm00)
plot(x02 + x01, y)
abline(lm01)

#evaluar la necesidad de transformación de variables
#modelo; ajustarlo
##modelo lineal:
lm00<-lm(log (y) ~ log (x02))
summary(lm00)
lm01<-lm(log (y) ~ log (x02) + log (x01))
summary(lm01)
#graficamos
par(mfrow = c(1,2))
plot(log(x02) ~ log(y))
abline(lm00)
plot(log(x02) + log(x01), log (y))
abline(lm01)

#####Con base en las graficas generadas al cambiar el modelo, se observa un mejor ajuste####

#checar cumplimiento de supuestos en residuos de modelos ajustados
par(mfrow = c(2,2))
plot(lm00)

par(mfrow = c(2,2))
plot(lm01)

#checar si tenemos colinealidad  
cotorro <- data.frame(y, x01, x02)
library(GGally)
ggpairs(cotorro)


######
#Karla, Mariana, Karen, Iván
#####P3. ¿Qué tanto explica la longitud de la hoja la variación en el diámetro  de los vasos en el ápice de un árbol, con y 
#####sin consideración de la altura? [XXXXX]
#plot con Y:diámetro apical, X1:long de hoja, X2:altura
#evaluar la necesidad de transformación de variables
#modelo; ajustarlo
#checar cumplimiento de supuestos en residuos de modelos ajustados
#checar si tenemos colinealidad  
