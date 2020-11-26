#cargar todas las librerias que se van a usar
library(dplyr)
library(car)
library(ggplot2)

#traits<- read.csv("2020_10_29_Base.csv") #cargar base de datos#
traits<- read.csv("data/2020_11_12_Base.csv") #cargar base de datos#

names(traits) #revisar nombres#

data<- traits[,c(1:7,11:21)] #seleccion de columnas de la base#

names(data)
#cambiar nombre de columnas#
colnames(data)<-c("order","family","genus","species.epithet",
                  "stem.length.m", "VD.base.um","VD.tip.um.",
                  "min.length.leaf.cm","max.length.leaf.cm",
                  "min.length.petiole.cm", "max.length.petiole.cm",
                  "min.length.blade.cm","max.length.blade.cm",
                  "min.width.blade.cm","max.width.blade.cm",
                  "leaf.type","length.leaf.cm","width.leaf.cm") 

names(data)
# filtrar por tipo de hoja quedan 583 especies#
data2 <- subset(data, leaf.type == "compound"|
                  leaf.type=="simple") 

data2["species"] <- paste(data2$genus,
                          data2$species.epithet,
                          sep = "_") 

####Bien cargada la base y los cambios de nombre en las columnas
calificacion <- 0.25
#Creamos nuevas columnas para los promedios de peciolo, 
#lamina, hoja y la suma de esos promedios para la hoja completa
data3 <- data2 %>% 
  mutate(mean.petiole = (min.length.petiole.cm + max.length.petiole.cm)/2,
         mean.length.blade = (min.length.blade.cm + max.length.blade.cm)/2,
         mean.length.leaf = (min.length.leaf.cm + max.length.leaf.cm)/2,
         mean.width.leaf=(min.width.blade.cm + max.width.blade.cm)/2)%>%
  
  mutate(length.leaf.union = mean.petiole + mean.length.blade)  

# 1. ?Cu?ntos datos tenemos de longitud de hoja provenientes del promedio del 
#minimo y maximo de la longitud total de la hoja?,

mean.lenght.leaf <- select(data3, species, mean.length.leaf) 

filter.mean.lenght.leaf <- filter(mean.lenght.leaf, !is.na(mean.length.leaf)) #quitamos los NA#
dim(filter.mean.lenght.leaf) 
#filtrar por datos de longitud de la hoja quedan 358 de 583#
#Ahora me salen 326. 

# 1. ?Cuantos datos de tenemos de longitud de hoja tenemos provenientes de la
#suma del promedio de la longitud maxima y minima de la lamina y del promedio de
#la longitud maxima y minima del peciolo?, 

length.blad.pet.mean <- select(data3, species, length.leaf.union)

filter.length.blad.pet.mean <-filter(length.blad.pet.mean,
                                     !is.na(length.leaf.union))
dim(filter.length.blad.pet.mean)
#filtrar por datos de la media de la longitud de 
#lamina y peciolo quedan 363 de 583#
#Ahora salen 354
### 1. ?Cuantas especies comparten ambas fuentes de datos?

merge.lenghtleaf.lampetmean <- merge(filter.mean.lenght.leaf, 
                                     filter.length.blad.pet.mean, by="species")

dim(merge.lenghtleaf.lampetmean) 
#filtrar por especies con ambas fuentes de datos quedan 194 especies#
#Ejercicio uno bien resuelto
calificacion <- 2 + calificacion

## 2. ?Cuantas especies tienen un valor unico de longitud de hoja 
#sin maximo y minimo?

data.lenght <- data2$length.leaf.cm[!is.na(data2$length.leaf.cm)]
length(data.lenght) 
#filtrar datos por longitud total de la hoja quedan 233 de 583#

#había que sacar las especies que hasta el momento tienen una sola fuente de info.
#
calificacion <- 1 + calificacion
### 3. ?Cuantas especies tienen informacion sobre el ancho de la hoja?

width.leaf <- select(data3, species, width.leaf.cm)

filter.width <- filter(width.leaf, !is.na(width.leaf.cm))
# sin max y min

dim(filter.width) 
#filtrar por datos de ancho de la hoja quedan 220 de 583#

mean.width.leaf <- select(data3, species, mean.width.leaf)
# con max y min
filter.mean.widthleaf <- filter(mean.width.leaf, 
                                !is.na(data3$mean.width.leaf)) 

dim (filter.mean.widthleaf) 
#filtrar por datos de la media del ancho de la lamina quedan 530 de 583#

merge.width <- merge(filter.width, filter.mean.widthleaf, by="species")

dim(merge.width) 
#filtrar por especies con ambas fuentes de datos quedan 195 especies#
#bien resuelto ancho de hoja
calificacion <- calificacion + 1

### 4. Para las especies con mas de una fuente de datos, 
#4.1 Obten una estimacion cuantitativa de cuanto difieren las 
#longitudes de hoja provenientes de ambas fuentes de datos en la pregunta 1

#estadisticos longitud de la hoja#
summary(merge.lenghtleaf.lampetmean) 
#estadisticos ancho de la hoja#
summary(merge.width) 

##4.2. ?Cuales son las especies que difieren mas entre las dos fuentes de datos?

#especies que difieren entre fuentes de datos#
difference.bwdates <- mutate(merge.lenghtleaf.lampetmean, 
                             difference= mean.length.leaf - length.leaf.union)

difference.bwdates$difference <- round(difference.bwdates$difference, 3)

diff.order <- arrange(difference.bwdates, desc (abs(difference)))

# 4.3 ?Que tanto difieren?

head(diff.order)
#Bien resuelto. 
calificacion <- calificacion + 2

# 5. Utiliza histogramas y graficos de cajas y bigotes para comparar 
#la distribucion de las dos variables

#para poder ver dos graficas a la vez y poder comparar
par(mfrow=c(2,2), dev.off)

#histogramas y graficos de caja y bigotes#
hist(merge.lenghtleaf.lampetmean$mean.length.leaf)

hist(log10(merge.lenghtleaf.lampetmean$mean.length.leaf))

hist(merge.lenghtleaf.lampetmean$length.leaf.union)

hist(log10(merge.lenghtleaf.lampetmean$length.leaf.union))

boxplot(merge.lenghtleaf.lampetmean$mean.length.leaf, 
        merge.lenghtleaf.lampetmean$length.leaf.union)

boxplot(log10(merge.lenghtleaf.lampetmean$mean.length.leaf), 
        log10(merge.lenghtleaf.lampetmean$length.leaf.union))

plot(merge.lenghtleaf.lampetmean$mean.length.leaf, 
     merge.lenghtleaf.lampetmean$length.leaf.union)
par(mfrow=c(1,1), dev.off)
#Después de utilizar la función par no olvides regresar al display original
calificacion <- calificacion + 0.95
# 6. Utiliza datos transformados logaritmicamente para 
#comparar el ancho y el largo de las hojas a partir de un 
#grafico de dispersion (“scatterplot”), 
#¿Podemos encontrar hojas aparentemente demasiado anchas para su longitud?

#grafico de dispersion#
scatterplot(log10(data2$width.leaf.cm) ~ log10(data2$length.leaf.cm))
#Para ver a que especies correspondeb los puntos extraños le ponemos etiquetas
#con ggplot
ggplot(data3, aes(x=(log10(width.leaf.cm)), 
                  y=(log10(length.leaf.cm)), label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)

calificacion <- calificacion + 1.05

#Con respecto a la pregunta 7 proponen una solución, sin embargo no consideran
#tomar el mayor número de fuentes en caso de que solo se tenga una fuente para 
#una especie. 
calificacion <- calificacion + 2
#Calificación 
print("Su calificación es:")
print(calificacion)
