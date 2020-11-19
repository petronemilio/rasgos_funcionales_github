# Rasgos funcionales en plantas 2020. Proyecto final 
# Equipo 2: Brenda Hernández, Karla Zarco, Iván Ek

# Script para depuración y exploración de la base de datos

# La utilidad última de este script es la de elegir
# una fuente primaria de datos de hoja para el proyecto final, 
# considerando la concordancia de las diferentes fuerntes y el 
# número de datos.

#### Cargar y manipular datos ####
#Bien anotado!!
#traits <- read.csv("traits_29102020.csv",     # Base de datos hasta el 
#                   header = TRUE, sep = ",")  #29 de octubre.
traits <- read.csv("data/2020_11_12_Base.csv", header = TRUE,sep=",")

data <- traits[,c(1:7,11:21)] # Eliminar columnas que no servirán
colnames(data) <- c("order","family","genus","species.epithet",
                    "stem.length.m", "VD.base.um","VD.tip.um.",
                    "min.length.leaf.cm","max.length.leaf.cm",
                    "min.length.petiole.cm", "max.length.petiole.cm",
                    "min.length.blade.cm","max.lentgh.blade.cm",
                    "min.width.blade.cm","max.width.blade.cm",
                    "leaf.type","length.leaf.cm","width.leaf.cm") # Cambiar nombres

data["Species"] <- paste(data$genus,
                          data$species.epithet,
                          sep = "_") # Crear columna con los nombres
                                     # completos de las especies

data2 <- subset(data, leaf.type == "compound"|
                  leaf.type=="simple") # Subset eliminando aquellas filas que
                                       # que no presentan tipo de hoja. 
                                       # Checar que ninguna de las especies sin tipo de hoja
                                       # presenten datos de medidas de hojas
#### Quedan 583 especies ###A mi me salen 577

#### Ejercicios en clases #####

table(data$order)
hist(data$VD.base.um)
par(mfrow = c(2,3))
boxplot(data2$length.leaf.cm, main = "longitud de hoja")
dotchart(data2$length.leaf.cm)
hist(data2$length.leaf.cm)
boxplot(log(data2$length.leaf.cm), main = "log(longitud de hoja)")
dotchart(log(data2$length.leaf.cm))
hist(log(data2$length.leaf.cm))
data2[order(-data2$length.leaf.cm),][1,] # Nos da los valores mayores 

# Calamus radicalis es la que tiene mayor longitud de hoja

data2[order(data2$length.leaf.cm),][1,] # Nos da los valores menores

# Opción 2. Crear tablas dinámicas

library(reshape)

x <- cast(data2, Species ~ ., fun.aggregate = length,  #Aquí faltó poner algo?
          value = "length.leaf.cm")

# Opción 3. Utilizar función aggregate

y <- aggregate(data2$length.leaf.cm,
          by=list(data2$Species),
          FUN = sum, na.rm= FALSE)

# Ozothamnus hookeri menor longitud de hoja
#Muy bien anotado!puntos extras por ello
calificacion <- 0.25
#### Ejercicios para entregar. Viernes 06/11/2020 ####
# Se obtuvieron Las siguientes variables 

data2["long.hoja"]<-data2[17] # Longitud de la hoja "per se"
data2["long.hoja.mean"]<-(data2[8]+data2[9])/2 # Promedio de máximos y mínimos de la longitud de la hoja
data2["long.lam.pet.mean"]<-((data2[12]+data2[13])/2)+((data2[10]+data2[11])/2) # Suma de los promedios de longitud de lámina de pecíolos

#### Ejercicio 1 ####
# ¿Cuántos datos tenemos de longitud de hoja provenientes del promedio del
# mínimo y máximo de la longitud total de la hoja?

length(na.omit(data2$long.hoja.mean)) # 358 datos  #326 CON BASE DEL 8/11/20

# ¿Cuántos datos de longitud de hoja tenemos provenientes de 
# la suma del promedio de la longitud máxima y mínima de la lámina
# y del promedio de la longitud máxima y mínima del peciolo?

length(na.omit(data2$long.lam.pet.mean)) # 363 datos #354 CON BASE DEL 8/11/20

# ¿Cuántas especies comparten ambas fuentes de datos?

# Creamos una nueva variable que que indique el número de 
# fuentes. Para ello contamos el número de NA´ en cada fila (especie)
# para ambas columnas y se lo restamos a dos(número máximo de fuentes)

data2["fuentes.distintas"] <- 2 - rowSums(is.na(data2[21:22]))
table(data2$fuentes.distintas) # 194 tienen ambas
                               # 56 no tienen ninguna
                               # 333 tienen sólo una de las dos



# Para saber cuántas tuvieron solo una de las dos, podemos 
# contar el número de NA´s en cada columna y restarle 194
# que es el número de de filas que tienen datos de ambas.
# Ejemplo: 

length(na.omit(data2$long.hoja.mean))-194 # 164 tienen sólo la primera
length(na.omit(data2$long.lam.pet.mean))-194 # 169 sólo la segunda

#Buena solución. Para no depender del valor 194 en caso de que la base de datos cambie
# podrían hacer un rowSums(is.na(data2$variable de interés)) y seleccionar las que suman 
# 1.
calificacion <- calificacion + 2
#### Ejercicio 2 ####

# ¿ Cuántas especies tienen un valor único de longitud de hoja?

table(data2$fuentes.distintas) # 333 especies tienen sólo un dato

#bien
calificacion <- calificacion + 1
#### Pregunta 3 ####

# ¿Cuántas especies tienen información sobre el ancho de la hoja?

data2["ancho.hoja"]<- (((data2[14])+(data2[15]))/2) # Promedio de máximos y mínimos 
                                                    # del ancho de la hoja

length(na.omit(data2$ancho.hoja)) 

# Tenemos 530 datos de ancho de hoja
# Tenemos una cantidad diferente de máximos y mínimos de ancho de hoja
# lo que indica que algunos datos deben de estar incompletos. 
# Se debe de volver a checar la base

#Bien resuelto
calificacion <- calificacion + 1
#### Ejercicio 4 ####
# ¿Cuáles son las especies que difieren más entre las dos fuentes de datos?
# ¿Qué tanto difieren?
  
data2["unovsdos"]<- (data2[20])-(data2[21]) # Diferencia entre la primera y segunda variable
data2["dosvstres"]<- (data2[21])-(data2[22]) # Diferencia entre la segunda y la tercera variable
data2["unovstres"]<- (data2[20])-(data2[22]) # Dfierencia entre la primera y la tercera variable
#No olviden cambiar par para disponer las gráficas de forma std.
par(mfrow = c(1,1))
plot(data2$unovsdos)
text(x = (1:583), y = data2$unovsdos, labels = data2$Species)
#### Angophora costata difiere por ca. 50 cm, pero parece
#### ser error de captura. Lo mismo sucede con
#### Baloskion tetraphyllum y Eucalyptus coccifera. 
#### Checar en la base

plot(data2$dosvstres)
text(x = (1:583), y = data2$dosvstres, labels = data2$Species)
#### Reinhardtia gracilis es la que más difiere. El error
#### parece deberse a la reconstrucción de la hoja 
#### (medidas de longitud.lámina como longitud.hoja)
#### Jacaratia dolichaula es la segunda que difiere más. 
#### El pecíolo presenta un valor máximo probablemente erróneo
#### Sucede algo similar con Sorbus acuparium
#### Myracrodruom urundeuva difiere mucho por de reconstrucción 
#### (longitud del foliolo se tomó como longitud de la lámina)

plot(data2$unovstres)
text(x = (1:583), y = data2$unovstres, labels = data2$Species)

#### Calatola costaricensis (también Salix lasiolepis) 
#### presenta valores mayores en 
#### longitud "per se" (nota: esta variable en general tiende a
#### sobreestimar las medidas).
#### El promedio de Jatropha mollisima fue sacado únicamente con 
#### los valores máximos del pecíolo y lámina.
#### Para el caso de Eucalyptus coccifera ya se checó en la primera comparación
#### La longitud "per se" de Geissois pruinosa es un promedio
#### obtenido con varias medidas de herbario. 

#Bien resuelto
calificacion <- calificacion + 2
#### Ejercicio 5 ####
# Gráficos de bigotes y e histogramas
par(mfrow = c(1,3))
boxplot(data2[,20], main = "leaf.perse")
boxplot(data2[,21], main = "mean.leaf")
boxplot(data2[,22], main = "mean.leaf+pet")

hist(data2[,20], main = "leaf.perse", breaks = 50)
hist(data2[,21], main = "mean.leaf", breaks = 50)
hist(data2[,22], main = "mean.leaf+pet", breaks = 50)

# Nota: Si no consideramos los errores de captura y otras cosas señaladas
# en el bloque anterior, la diferencia entre las fuentes es baja (de unas 15 unidades).
# Discriminar entre las variables debería de obedecer más al tamaño de la muestra,
# pero, destacamos la necesidad de vover a revisar la base de datos.

calificacion <- calificacion + 1

#### Ejercicio 6 ####
# ¿Podemos encontrar hojas aparentemente demasiado anchas para su longitud?
  
par(mfrow = c(1,3))

plot(log(long.lam.pet.mean) ~ log(ancho.hoja), data = data2)
text(log(data2$ancho.hoja), 
     log(data2$long.lam.pet.mean),
     labels = data2$Species)

plot(long.lam.pet.mean ~ log(ancho.hoja), data = data2)
text(log(data2$ancho.hoja), data2$long.lam.pet.mean,
     labels = data2$Species)
plot(log(long.lam.pet.mean) ~ ancho.hoja, data = data2)
text(data2$ancho.hoja, log(data2$long.lam.pet.mean),
     labels = data2$Species)

# Son pocas las que difieren y es posible que se deba 
# a error de captura y en pocos casos a la reconstrucción 
# del a hoja. Se recomienda revisar cada caso particular
# Por ejemplo: Washingthonia robusta, Brunellia mexicana
# Para el caso de Cecropia obtusifolia, las medidas de 
# longitud de hoja y lámina son las mismas. La última
# debería de ser menor y sumarle el pecíolo.

#Bien resuelto
calificacion <- calificacion + 1
#### Ejercicio 7 ####
# ver: 
# https://docs.google.com/document/d/146ofOVQC01XgLf5-1RJUW2z3YXtsw6bAgNr8eom0zNk/edit?ts=5fa34407

#buenas propuestass
calificacion <- calificacion + 2
#extra por cargar la base
calificacion <- calificacion + 0.25
#
print("Su calificación es:")
print(calificacion)
##Calif final 10.5