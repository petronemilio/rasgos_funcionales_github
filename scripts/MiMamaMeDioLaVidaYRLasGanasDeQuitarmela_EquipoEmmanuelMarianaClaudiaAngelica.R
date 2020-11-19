# Librerias necesarias (de ser necesario instalar)
# Para instalar
install.packages('dplyr')
install.packages('ggplot2')
# Para cargar la librerias
library(dplyr)
library(ggplot2)

######
#¿Y cómo cargaron la base?
# Hubiera estado bien empezar desde el principio porque cuándo comparten
# scripts las otras personas podrían no tener la base cargada.
#### No olviden construir scripts que se puedan correr completos. Si yo intento correr este script
#### no jalaría pues no está la base cargada

# Se crearon 4 columnas nuevas
data02 <- subset(data, leaf.type == "compound"| #######¿Dónde está la base cargada y 
                  leaf.type=="simple")          #######los nombres de las columnas?
# Data02 = Base De Datos excluyendo las plantas no determinadas y que no tienen hojas
data02["long.leaf"]<-data02[17] #Columna copiada de length.leaf.cm
data02["long.leaf.mean"]<-(data02[8]+data02[9])/2 # Columna de promedio de 
#longitud de la hoja 
data02["long.lam.pet.mean"]<-((data02[12]+data02[13])/2)+((data02[10]+data02[11])/2) 
# Columna  de la suma del promedio de la longitud del peciolo mas la longitud 
# de la lamina
data02["width.leaf.mean"]<-(data02[14]+data02[15])/2 # Promedio del ancho de la hoja


calificacion <- as.numeric(-0.05)
# Revisamos que las cuatro columnas sean numericas, de haber algun espacio en blanco que
# no cuente como NA, las columnas serian de tipo "caracter"
str(data02)

# Pregunta 1
#¿Cuantos datos tenemos de longitud de hoja provenientes del promedio 
#del minimo y maximo de la longitud total de la hoja?
sum(!is.na(data02$long.leaf.mean))
## 358 #base326

#¿Cuantos datos de longitud de hoja tenemos provenientes de la suma del promedio de la
# longitud maxima y minima de la lamina y del promedio de la longitud maxima y minima 
# del peciolo?
sum(!is.na(data02$long.lam.pet.mean))
## 363 #354

#¿Cuantas especies comparten ambas fuentes de datos?
nrow(subset(data02, !is.na(long.leaf.mean) & !is.na(long.lam.pet.mean)))
## 194
calificacion <- calificacion + 2

#Pregunta 2
#¿Cuantas especies tienen un valor unico de longitud de hoja?
sum(!is.na(data02$long.leaf)) 
## 233                         
calificacion <- calificacion + 1
#Pregunta 3
#¿Cuantas especies tienen informacion sobre el ancho de la hoja?
sum(!is.na(data02$width.leaf.mean)) +
sum(!is.na(data02$width.leaf.cm)) - nrow(subset(data02, !is.na(width.leaf.mean) &
                                                 !is.na(width.leaf.cm)))
## 555
calificacion <- 1 + calificacion
#Pregunta 4
#Para las especies con mas de una fuente de datos, obten ahora una estimacion 
#cuantitativa de cuanto difieren las longitudes de hoja provenientes de ambas 
#fuentes de datos en la pregunta 1 
data02["diff.long1"] <- abs(data02[20]-data02[22])

#¿Cuales son las especies que difieren mas entre las dos fuentes de datos?,
#¿Que tanto difieren?
data02[order(-data02$diff.long),][1:5,c(19,24)] # Las primeras 5 especies 
# 0                   species   diff.long
# 21     Reinhardtia-gracilis    29.250
# 81     Jacaratia-dolichaula    12.149
# 549        Sorbus-aucuparia    10.885
# 573  Myracrodruon-urundeuva    10.000
# 575 Schinopsis-brasiliensis     6.500

calificacion <- calificacion + 2

#Pregunta 5
#Utiliza histogramas y graficos de cajas y bigotes para comparar la distribucion de
#las dos variables.

#Para visualizar la dispersion de la longitud
# Numero de columnas de data02: 
# 21: long.leaf 
# 22: long.leaf.mean
# 20: long.lam.pet.mean

#Creamos tres bases de datos nuevas para formar una unica base de datos de longitud
#posterior: data.long

#Nuevo objeto para tener nombres iguales entre las bases de datos
names.long <- c("long.measure", "long.measure.type", "species")

#1-Base de datos de long.leaf (longitud por valor unico)
long.leaf <- data02[21]
long.leaf["x"] <- "unique value"
long.leaf <- cbind(long.leaf, data02$species)
names(long.leaf) <- names.long

#2-Base de datos de long.leaf.mean (longitud por promedio entre minimos y maximos)
long.mean <- data02[22]
long.mean["x"] <- "mean"
long.mean <- cbind(long.mean, data02$species)
names(long.mean) <- names.long

#3-Base de datos de long.lam.pet.mean (longitud por suma de promedios del minimo y 
#maximo de la lamina y peciolo)
long.lam.pet <- data02[20]
long.lam.pet["x"] <- "petiole plus blade" 
long.lam.pet <- cbind(long.lam.pet, data02$species)
names(long.lam.pet) <- names.long

#Unimos las primeras dos bases de datos. La funcion full_join unira ambas bases por 
#los nombres de las columnas
data.long <- full_join(long.leaf, long.mean)

#Unimos la ultima base de datos a la union de las dos bases pasadas
data.long <- full_join(data.long, long.lam.pet)

#Como la base de datos tiene muchos NA's los filtramos
data.long <- subset(data.long, !is.na(long.measure))

#Histograma por tipo de origen de los datos
ggplot(data.long, aes(long.measure, fill = long.measure.type))+
    geom_histogram(position = "dodge")

#Boxplot por tipo de origen de los datos
ggplot(data.long, aes(long.measure.type, long.measure))+
  geom_boxplot()

#Revision de diferencias
#Primero crearemos una nueva base de datos de las diferencias
#Creamos un objeto de nombres para homogeneizar 
diff.names <- c("value", "type", "species")

#Creamos una micro base de datos de cada una de las diferencias
#Peciolo + lamina vs media (aqui utilizamos la colmna creada previamente)
diff1 <- data02[24]
diff1["X"] <- "petiole + blade vs mean"
diff1 <- cbind(diff1, data02$species)
names(diff1) <- diff.names

#Peciolo + lamina vs unico valor
data02["diff.long2"] <- abs(data02[21]-data02[22]) # Creamos una nueva columna con 
#los valores de esas diferencias
diff2 <- data02[25]
diff2["X"] <- "unique value vs mean"
diff2 <- cbind(diff2, data02$species)
names(diff2) <- diff.names

#Unico valor vs media
data02["diff.long3"] <- abs(data02[20]-data02[21])
diff3 <- data02[26]
diff3["X"] <- "petiole + blade vs unique value"
diff3 <- cbind(diff3, data02$species)
names(diff3) <- diff.names

#Creacion de la base de datos de las diferencias
data.diff <- full_join(diff1, diff2)
data.diff <- full_join(data.diff, diff3)
data.diff <- subset(data.diff, !is.na(value))

#Grafica boxplot
fig1 <- ggplot(data.diff, aes(type, value))+
  geom_boxplot()

#Grafica logaritmica
fig2 <- ggplot(data.diff, aes(type, log(value)))+
  geom_boxplot()

fig1
fig2

#Buenas gráficas!
calificacion <- calificacion + 1.25
#Pregunta 6
#Utiliza datos transformados logaritmicamente para comparar el ancho y el largo de
#las hojas a partir de un grafico de dispersion ("scatterplot"), ¿Podemos encontrar
#hojas aparentemente demasiado anchas para su longitud?

#Repetimos los mismos pasos que hicismos con las medidas de longitud, ahora con las 
#medidas de anchura

##Numero de columnas de data02: 
#18: width.leaf.cm
#23: width.leaf.mean

#Objeto de nombres iguales
names.width <- c("width.measure", "width.measure.type", "species")

#Base de datos para datos con unico valor
width.unique <- data02[18]
width.unique["x"] <- "width unique value" 
width.unique <- cbind(width.unique, data02$species)
names(width.unique) <- names.width

#Base de datos para datos del promedio del minimo y el maximo del ancho
width.mean <- data02[23]
width.mean["x"] <- "width mean value" 
width.mean <- cbind(width.mean, data02$species)
names(width.mean) <- names.width

#Base de datos de datos del ancho completa
data.width <- full_join(width.mean, width.unique)

#Eliminacion de NA's
data.width <- subset(data.width, !is.na(width.measure))

#Nueva base de datos, union de datos de longitud y anchura.
data03 <- full_join(data.long, data.width, by = "species")

#Grafica de dispersion
ggplot(data03, aes(log(long.measure), log(width.measure), 
                   color = long.measure.type, shape = width.measure.type))+
  geom_point()

calificacion <- calificacion + 1
#Pregunta 7
# ¿Cual crees que deberiamos escoger como nuestra fuente primaria de datos para 
# las especies con mas de una fuente de datos? 

# Al analizar los valores de diferentes fuentes, no se observaron diferencias muy
# grandes entre si, salvo en casos especificos (_Reindhartia gracilis_, _Jacaratia 
# dolichaula_). Sin embargo, consideramos que la fuente primaria de datos debe ser
# aquella que considera los intervalos de peciolo y lamina (intervalo P-L) debido a
# tres factores principales:

 # I) El numero de muestra correspondiente a esta fuente es mayor que el del 
 # resto (363 vs 358 (promedio de la longitud total de la hoja) y 233 (valor unico 
 # de longitud)).
 # II) La mayoria de los datos provienen de una misma fuente, ya sea de la 
 # literatura o directamente de ejemplares de herbario. 
 # III) Las diferencias que tienen los intervalos de peciolo y lamina respecto a
 # las otras dos fuentes son mucho mas pequeñas. Esto puede verse en el conjunto de
 # boxplots generados de las diferencias. En el primer conjunto observamos 
 # las diferencias en outliers y el primer cuartil, donde son menores entre la 
 # fuente de intervalo P-L respecto a la media de longitud total de hoja mientras 
 # que para el valor unico presenta dispersiones con mayores diferencias. En el 
 # segundo conjunto estas diferencias estan transformadas logaritmicamente y
 # observamos que en la comparacion entre la fuente de intervalo P-L respecto a la
 # media de longitud total de hoja las diferencias son menores a 0, en cuanto al
 # valor unico estas diferencias son mayores a 0.
fig1 
fig2

# En especies donde no se cuente con el intervalo P-L como fuente primaria, la media
# de la longitud total de la hoja puede ser considerada.

calificacion <- calificacion + 2

print("Su calificación es:")
print(calificacion)
