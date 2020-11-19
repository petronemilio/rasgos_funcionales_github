### EJERCICIO COLECTIVO - CLASE DE RASGOS FUNCIONALES ##
## Equipo ->
## Nombres: Cortéz Castro Ericka Belen
##			Escalante Pasos Jorge Armín
##			Dávila Navarro Diego Emilio


#borrar
rm(list = ls())

#Set working directory#

getwd()
#setwd("C:/Users/diem_/Documents/R/MisProyectos/Manuscrito-colectivo-Vasos&TamañoDeHoja/Data")
#¿Cómo solucionar el problema de las rutas relativas?
#Si haces el proyecto de R y lo inicias en tu Rstudio no hará falta extablecer la 
#ruta absoluta a los archivos. Es mejor proceder de esa forma para compartir scripts 
#con otras personas.

#####
#No olviden comentar sus scripts. Así todos entendemos mejor cómo funciona.
traits.db <- read.csv("data/2020_11_12_Base.csv")
#traits.db <- read.csv("BaseRasgos.csv")

head(traits.db)
names(traits.db)

traits.db <- subset(traits.db[1:21])

str(traits.db)

names(traits.db)
traits.db <- subset(traits.db, select=c("order","family","genus","species",
                                        "StemLengthMeters","VDbase.um..Vessel.diameter.stem.base.micrometers.",
                                        "VDtip.um..Vessel.diameter.stem.tip.micrometers.",
                                        "Min..longitud.total.de.la.hoja..cm.", "Max..longitud.total.de.la.hoja..cm.",
                                        "Min..longitud.del.peciolo..cm.", "Max..longitud.del.peciolo..cm.",
                                        "Min..longitud.de.la.lamina..cm.", "Max..longitud.de.la.lamina..cm.",
                                        "Min..ancho.de.hoja.o.lamina..cm.", "Max..ancho.de.hoja.o.lamina..cm.",
                                        "Tipo.de.hoja..simple.o.compuesta.", "Long.hoja..cm.", "Ancho.hoja..cm."))

names(traits.db)

str(traits.db)

colnames(traits.db) <- c("order", "family", "genus", "species.epithet", "stem.length.m",
                         "VD.base.um", "VD.tip.um", "min.length.leaf", "max.length.leaf",
                         "min.length.petiole","max.length.petiole","min.length.blade",
                         "max.length.blade", "min.width.blade", "max.width.blade",
                         "leaf.type", "length.leaf.cm", "width.leaf.cm")



names(traits.db)
str(traits.db)

summary(traits.db$stem.length.m)
mean(traits.db$stem.length.m, na.rm = TRUE)

##### 
#Está es otra posible sección y se le podría poner algo para saber que pasa aquí.
#Crear columna "species"
traits.db$species <- paste(traits.db$genus, traits.db$species.epithet, sep = "_")
names(traits.db)

#filtrar por dato de hoja

data2 <- subset(traits.db, leaf.type == "compound"|
                  leaf.type=="simple")

#### Quedan 565 especies (son las especies que sí presentan información de tipo de hoja)

names(data2)

#Obtenemos la longitud de hoja a partir de tres fuentes de información:

data2["long.hoja"]<-data2[17]  #1) longitud de hoja "cruda"
data2["long.hoja.mean"]<-(data2[8]+data2[9])/2 #2) promedio de los mínimos y máximos de la longitud de la hoja
data2["long.lam.pet.mean"]<-((data2[12]+data2[13])/2)+((data2[10]+data2[11])/2) #3) promedio de los mínimos y máximos de la lámina + peciolo

names(data2)

#Cuántos datos nos quedan al eliminar NA's, después de hacer un subset para cada metódo

###Pregunta 1.1): ¿Cuántos datos tenemos de la longitud de hoja provenientes de los datos crudos?

#longitud de hoja
long.hoja.crud <- subset(data2, select=c("species", "long.hoja"))
long.hoja.crud <-na.omit(long.hoja.crud)
head(long.hoja.crud)

###*Respuesta 1.1: 222 datos disponibles.

###Pregunta 1.2): ¿Cuántos datos tenemos de la longitud de hoja provenientes del 
#promedio del mínimo y máximo de la longitud total de la hoja?

#media long hoja min/max
long.hoja.minmax <- subset(data2, select=c("species", "long.hoja.mean"))
long.hoja.minmax <-na.omit(long.hoja.minmax)
head(long.hoja.minmax)

####*Respuesta 1.2: Provenientes de los mínimos y máximos tenemos 357 datos.*

###Pregunta 1.3) ¿Cuántos datos de longitud de hoja tenemos provenientes de la suma del promedio de la longitud máxima y
#mínima de la lámina y del promedio de la longitud máxima y mínima del peciolo?

#media lámina + peciolo
names(data2)
long.hoja.pet <- subset(data2, select=c("species", "long.lam.pet.mean"))
long.hoja.pet <-na.omit(long.hoja.pet)
head(long.hoja.pet)

###*Respuesta 1.3: Contamos con 363 datos.


###Pregunta 1.4: ¿Cuántas especies comparten las 3 fuentes de datos?#

library(tidyr)
library(Rmisc)
library(dplyr)

#Apply merge step1: -crude & minmax-

merge.mean.minmax <- merge(long.hoja.crud, long.hoja.minmax, by.x = "species", by.y = "species", sort = T)
names(merge.mean.minmax)
head(merge.mean.minmax)

#Apply merge step2: - crude & minmax & petiole-

merge.all <- merge(merge.mean.minmax, long.hoja.pet, by.x = "species", by.y = "species", sort = T)
names(merge.all)
head(merge.all)
tail(merge.all)


count(merge.all)
length(merge.all$species)

###*Respuesta 1.4: En total, las especies que presentan datos para las 3 fuentes son 61.*
#Bien resuelto! Que bien que hicieron el merge de las tres fuentes.
#Hizo falta la combinación de minmax & petiole- pero lo resolvieron bien
#
calificacion <- 2
#Pregunta 2:
#¿Cuántas especies solo tienen un valor único de longitud de hoja?

#Apply merge step1: -crude & minmax-

merge.mean.minmax <- merge(long.hoja.crud, long.hoja.minmax, by.x = "species", by.y = "species", sort = T,
                           all.x = T, all.y = T)
names(merge.mean.minmax)
head(merge.mean.minmax)

#Apply merge step2: -crude, minmax & petiole-

merge.mean.all <-merge (merge.mean.minmax, long.hoja.pet, by.x = "species", by.y = "species", sort = T,
                           all.x = T, all.y = T)
names(merge.mean.all)
head(merge.mean.all)
tail(merge.mean.all)

#podemos añadir una función que cuente el número de resultados 

names(merge.mean.all)

merge.mean.all$na_count <- apply(merge.mean.all, 1, function(x) sum(is.na(x)))
head(merge.mean.all)

#Ahora hacer un subset de las especies que cumplen con el criterio

#Cuantas especies tienen un valor único de longitud?
species.single.measurement <- subset(merge.mean.all, na_count==2)
head(species.single.measurement)
tail(species.single.measurement)
count(species.single.measurement)

#####
###*Respuesta 2: R) Hay 221 especies que presentan un valor único de longitud.

#Su solución da muchos detalles de las especies y sus distitnas fuentes de información.
#Se merecen unas décimas extras.
calificacion <- calificacion + 1.25

#Pregunta 3:
#¿Cuantas especies tienen información sobre el ancho de hoja?
#Aclaración: tenemos dos tipos de fuentes para el ancho de hoja. La primera es la variable "directa" o de datos "crudos",
#la segunda es el cálculo del promedio a partir de los valores mínimos y máximos de ancho. 

count(data2)
names(data2)

#Cuántas especies tienen información sobre ancho de hoja?
length(data2$width.leaf.cm)
length(na.omit(data2$width.leaf.cm))
#*Respuesta 3.1: Hay 209 especies que tienen un dato con la variable "directa" - width.leaf.cm

#crear una nueva columna que calcule el promedio ancho de hoja
data2$width.mean <- (data2$min.width.blade + data2$max.width.blade)/2
data2$width.mean
length(na.omit(data2$width.mean))
#*Respuesta 3.2: Hay 528 especies que tienen información de mínimos y máximos.

#hacer subset de especie y ancho de hoja
data.width <- subset(data2, select=c("species", "width.mean", "width.leaf.cm"))
head(data.width)
data.width$na_count <- apply(data.width, 1, function(x) sum(is.na(x)))
head(data.width)

species.single.measurement <- subset(data.width, na_count==1 | na_count==0)
count(species.single.measurement)
#*Respuesta 3.3: - En total, hay 543 especies que presentan al menos un dato de ancho de hoja*

#Bien!
calificacion <- calificacion + 1

#estimación cuántitativa de cuánto difieren las longitudes de hoja provenientes de ambas fuentes de datos en la pregunta 1. 
#Pregunta 4: 4.1) ¿Cuáles son las especies que difieren más entre las dos fuentes de datos? 4.2) ¿Qué tanto difieren?

#calcular prueba
names(data2)
prueba = subset(data2[19:22])
names(prueba)

prueba$diferencia12 <- abs(prueba$long.hoja - prueba$long.hoja.mean)
prueba$diferencia13 <- abs(prueba$long.hoja - prueba$long.lam.pet.mean)
prueba$diferencia23 = abs(prueba$long.hoja.mean - prueba$long.lam.pet.mean)

#*Respuestas para las preguntas 4.1 y 4.2:

#calculamos el valor de mayor diferencia entre fuente 1 y 2
prueba[order(-prueba$diferencia12),][1:10,] 
#Las espcies que más difieren son:
# Angophora_costata:51.8, Baloskion_tetraphyllum: 20.15 ,  Eucalyptus_coccifera: 16, Salix_lasiolepis:12.925,  Jacaratia_dolichaula: 11.808

#calculamos el valor de mayor diferencia entre fuente 1 y 3
prueba[order(-prueba$diferencia13),][1:10,] 
#Las especies que mas difieren son:
#Angophora_costata: 51.800 , Calatola_costaricensis: 33 , Eucalyptus_coccifera: 16,  Jatropha_mollissima: 14,  Salix_lasiolepis: 12

#Caculamos el valor de mayor diferencia entre fuente 2 y 3
prueba[order(-prueba$diferencia23),][1:10,] 
#La especie de mayor diferencia es Reinhardtia_gracilis con 29.25 cm de diferencia entre fuentes 2 y 3


#Utilizamos histogramas y gráficos de cajas y bigotes para comparar la distribución las dos variables:

par(mfrow = c(1,3))
boxplot(prueba$diferencia12)
boxplot(prueba$diferencia13)
boxplot(prueba$diferencia23)

ggplot(prueba, aes(x=species, y=diferencia13))+geom_boxplot()+theme(axis.text.x = element_text(angle = 90)) + geom_label(label=prueba$species, size=2.5)

dotchart(log(data2$length.leaf.cm))
hist(log(data2$length.leaf.cm))

#Reset plotting parameters:
par(mfrow=c(1,1))
#Exploración cualitativa

#long. hoja directa
hist(data2$long.hoja)
hist(log10(data2$long.hoja))

#long. hoja a partir de minmax
hist(data2$long.hoja.mean)
hist(log10(data2$long.hoja.mean))

#long. hoja lámina más peciolo
hist(data2$long.lam.pet.mean)
hist(log10(data2$long.lam.pet.mean))

#observación:
#visualmente, las variables de minmax y lámina más peciolo se acercan más a una
#distribución normal cuando se transforman en logaritmo

#Hacer una matriz de correlación:
#Nuestra propuesta fue elaborar una matriz de correlación para ver de forma cuantitativa, cuáles son las fuentes que más se parecen 
#entre sí, asumiendo que estas tenderan a presentar un coeficiente de correlación cercano a 1. 

library(Hmisc)
library(corrplot)
library(ggplot2)
names(data2)

long.hoja.cor<-subset(data2[,20:22])

#2 matrices: r y p value
long.hoj.matrix = rcorr(as.matrix(long.hoja.cor))
long.hoj.matrix$r

corrplot(long.hoj.matrix$r, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)

corrplot(long.hoj.matrix$r, type="upper", order="hclust", 
         p.mat = long.hoj.matrix$P, sig.level = 0.05, bg="WHITE",
         tl.col = "black", tl.srt = 45, pch.cex=2, outline=T, addCoef.col = T)
		 
## Conclusión a partir del corrplot: "Las fuentes más parecidas entre sí son la longitud de la hoja calculada a partir de mínimos y máximos
                                    # y la longitud de la hoja considerando la lámina y el peciolo. r=0.94
									
## También realizamos algunos scatterplot de variable vs. variable para ver gráficamente la correlación entre las fuentes:
#long.hoja vs long.hoja.mean
data2.naomit <- na.omit(data2)
names(data2)

ggplot(data2, aes(x=log10(long.hoja), y=log10(long.hoja.mean))) +
 geom_point(size=2, shape=10) +  geom_label(label=data2$species, size=2.5) +
 geom_smooth(method="lm", se=TRUE, fullrange=FALSE, level=0.95)
#change geom_label with geom_text to erase white labels behind text

#long.hoja vs long.hoja.pet
names(data2)

ggplot(data2, aes(x=log10(long.hoja), y=log10(long.lam.pet.mean))) +
  geom_point(size=2, shape=10) +  geom_label(label=data2$species, size=2.5) +
  geom_smooth(method="lm", se=TRUE, fullrange=FALSE, level=0.95)                                           

#Hiceron buenas propuestas para detectar diferencias de valores de longitudes de hoja
# entre fuentes. Buenas gráficas!
#Preguinta 4
calificacion <- calificacion + 2
#Pregunta 5
calificacion <- calificacion + 1.25

### Pregunta 6: ¿Podemos encontrar hojas aparentemente demasiado anchas para su longitud?
### Para responder esta pregunta, utilizamos gráficas de tipo scatterplot, que se muestran a continuación:

                                    
#Scatterplot de largo vs ancho de hoja

ggplot(data2, aes(x=log10(long.hoja), y=log10(width.leaf.cm))) +
  geom_point(size=2, shape=10) +  geom_label(label=data2$species, size=2.5) +
  geom_smooth(method="lm", se=TRUE, fullrange=FALSE, level=0.95)

#con variable long.hoja.mean

ggplot(data2, aes(x=log10(long.hoja.mean), y=log10(width.leaf.cm))) +
  geom_point(size=2, shape=10) +  geom_label(label=data2$species, size=2.5) +
  geom_smooth(method="lm", se=TRUE, fullrange=FALSE, level=0.95)

#con variable long.lam.pet.mean

ggplot(data2, aes(x=log10(long.lam.pet.mean), y=log10(width.leaf.cm))) +
  geom_point(size=2, shape=10) +  geom_label(label=data2$species, size=2.5) +
  geom_smooth(method="lm", se=TRUE, fullrange=FALSE, level=0.95)

## *Respuesta 6: A partir de nuestras observaciones no encontramos especies que tuvieran hojas demasiado anchas para su longitud, pero sí
####             el caso contrario, especies que presentan hojas atípicamente largas para su valor de ancho. Un ejemplo es:
####             Pandanus tectorius
calificacion <- calificacion + 1

### Pregunta 7: ¿Cuál crees que deberíamos escoger como nuestra fuente primaria 
#de datos para las especies con más de una fuente de datos? 

##Respuesta 7): 
## Los datos de longitud que más se parecen entre sí son los calculados a partir de la suma de la lámina y peciolo y los obtenidos
# a partir del cálculo de la media de longitud a partir de mínimos y máximos. Sugeriríamos utilizar ambas fuentes para completar 
#el mayor número de datos posible, ya que estas no difieren significativamente entre sí (después de haber pulido nuevamente la base).
calificacion <- calificacion + 2
#
print("Su calificación es:")
print(calificacion)