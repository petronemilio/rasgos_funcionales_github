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


#cargamos librerias
library(ggplot2)
library(corrplot)
library(Hmisc)

#Cargando la base de datos
traits <- read.csv("2020_12_31_Base.csv")
names(traits) #revisar nombres#
str(traits)
#######exploratory analyses ######

##### Equipo de la cajita ->
## Nombres: Cortéz Castro Ericka Belen
##      Hernández Jessica 
##			Escalante Pasos Jorge Armín
##      Martínez  Emmanuel
##			Dávila Navarro Diego Emilio

#Checar existencia de outliers y corregir el problema
#tipo de variables que tenemos, que el reconocimiento sea correcto
#datos faltantes, cuántos hay y cómo se están manejando

#seleccionamos columnas de interes y renombramos
traits.db<-traits[c(1:7,11:21)]
names(traits.db)
str(traits.db)
colnames(traits.db) <- c("order", "family", "genus", "species.epithet", "stem.length.m",
                         "VD.base.um", "VD.tip.um", "min.length.leaf", "max.length.leaf",
                         "min.length.petiole","max.length.petiole","min.length.blade",
                         "max.length.blade", "min.width.blade", "max.width.blade",
                         "leaf.type", "length.leaf.cm", "width.leaf.cm")

names(traits.db)
##verificar los niveles de los factores, rangos de variación de vars continuas
factores<-factor(traits.db$leaf.type)
length(levels(factores))

#combinamos la fila de epiteto y genero
traits.db$species <- paste(traits.db$genus, traits.db$species.epithet, sep = "_")
names(traits.db)

#filtrar por dato de hoja

traits.db <- subset(traits.db, leaf.type == "compound"|
                      leaf.type=="simple")

#Así obtuvimos las columnas de interés (recuerda revisar los numeros de las columnas):#

traits.db["long.hoja"]<-traits.db[17]  #1) longitud de hoja "cruda"
traits.db["long.hoja.mean"]<-(traits.db[8]+traits.db[9])/2 #2) promedio de los mínimos y máximos de la longitud de la hoja
traits.db["long.lam.pet.mean"]<-((traits.db[10]+traits.db[11])/2)+((traits.db[12]+traits.db[13])/2) #3) promedio de los mínimos y máximos de la lámina + peciolo

#Descargamos y revisamos los valores faltantes y corregimos los errores de la base de datos
#a partir de las diferencias entre fuentes de informacion
write.csv(traits.db,"BaseRasgos_30dic2020.csv")

#diferencias cuantitativas entre diferentes fuentes de informacion de las
#longitudes de hoja

traits.db$diferencia12 <- abs(traits.db$long.hoja - traits.db$long.hoja.mean)
traits.db$diferencia13 <- abs(traits.db$long.hoja - traits.db$long.lam.pet.mean)
traits.db$diferencia23 = abs(traits.db$long.hoja.mean - traits.db$long.lam.pet.mean)

#calculamos el valor de mayor diferencia entre fuente 1 y 2
traits.db[order(-traits.db$diferencia12),][1:10,] 

#calculamos el valor de mayor diferencia entre fuente 1 y 3
traits.db[order(-traits.db$diferencia13),][1:10,] 

#Caculamos el valor de mayor diferencia entre fuente 2 y 3
traits.db[order(-traits.db$diferencia23),][1:10,] 

#graficamos para observar aquellas especies que estan mal ingresadas o son grandes
#por naturaleza
ggplot(traits.db, aes(x=(log10(long.hoja)), 
                      y=(log10(long.lam.pet.mean)), label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)

ggplot(traits.db, aes(x=species, y=long.hoja))+
  geom_boxplot()+theme(axis.text.x = element_text(angle = 90)) +
  geom_label(label=traits.db$species, size=2.5)

ggplot(traits.db, aes(x=species, y=long.hoja.mean))+
  geom_boxplot()+theme(axis.text.x = element_text(angle = 90)) +
  geom_label(label=traits.db$species, size=2.5)

ggplot(traits.db, aes(x=species, y=long.lam.pet.mean))+
  geom_boxplot()+theme(axis.text.x = element_text(angle = 90)) + 
  geom_label(label=traits.db$species, size=2.5)

#Graficacom un dotchart para ver la distribucion y asegurarnos que arreglamos 
#los valores extraños
dotchart(log(traits.db$long.hoja))
dotchart(log(traits.db$long.lam.pet.mean))

#####creating final consensus variables####
#extraer datos de las dos fuentes y crear una nueva col donde se combinen para tener un único dato de long de hoja
#explorar la variable final de long de hoja final

#Después de revisada y analizados los valores extraños, realizamos la columna consenso
#hecha en tres pasos
#Primero volvemos a cargar la base de datos pulida
traits.db<-read.csv("data/BaseRasgos_Completa_30dic2020.csv")

#paso 1
#written argument:
#If there is an NA in long.lam.pet.mean, then print long.hoja.mean; if thats 
#not the case, then print long.lam.pet.mean

traits.db$get.flyer <- with(traits.db, ifelse(is.na(long.lam.pet.mean),
                                              long.hoja.mean, long.lam.pet.mean))

head(traits.db)
#paso 2
#written argument:
#If there is an NA in long.lam.pet.mean as well as in long.hoja.mean,
#then print long.hoja, if thats not the case, then print long.lam.pet.mean

traits.db$get.flyer.1 <- with(traits.db, ifelse(is.na(long.lam.pet.mean) &
                                                  is.na(long.hoja.mean),
                                                long.hoja, long.lam.pet.mean))



#paso 3 y final
traits.db$unique_col <- with(traits.db, ifelse(!is.na(get.flyer),
                                               get.flyer, get.flyer.1))

#Organizar nueva base de datos
names(traits.db)
traits.db <- subset(traits.db, select=c("order","family","genus","species",
                                        "stem.length.m","VD.base.um",
                                        "VD.tip.um",
                                        "min.length.leaf", "max.length.leaf",
                                        "min.length.petiole", "max.length.petiole",
                                        "min.length.blade", "max.length.blade", "leaf.type",
                                        "long.hoja", "long.hoja.mean", "long.lam.pet.mean",
                                        "unique_col"))
head(traits.db)

colnames(traits.db) <- c("order","family","genus","species",
                         "stem.length.m","VD.base.um",
                         "VD.tip.um",
                         "min.length.leaf", "max.length.leaf",
                         "min.length.petiole", "max.length.petiole",
                         "min.length.blade", "max.length.blade", "leaf.type",
                         "long.hoja", "long.hoja.mean", "long.lam.pet.mean",
                         "long.hoja.consenso")

#descargamos base depurada y con variable consenso#

write.csv(traits.db, "BaseRasgos_UltraCompleta_30dic2020.csv")

#revisamos los outlayers para comprobar que la revision a los valores extraños
#hayan sido adecuada
dotchart(log10(traits.db$long.hoja.consenso))
hist(log10(traits.db$long.hoja.consenso))

#Funciona - SE OBTIENE BASE PULIDA FINAL

#análisis de correlación bivariada de todas las variables

names(traits.db) #para ver las variables cuantitativas#
long.hoja.cor<-subset(traits.db[, c(5, 6, 7, 18)]) #seleccionar variables de interes#

#realizar matriz de correlación y graficarla#
long.hoj.matrix = rcorr(as.matrix(long.hoja.cor))
long.hoj.matrix$r

corrplot(long.hoj.matrix$r, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)

corrplot(long.hoj.matrix$r, type="upper", order="hclust", 
         p.mat = long.hoj.matrix$P, sig.level = 0.05, bg="WHITE",
         tl.col = "black", tl.srt = 45, pch.cex=2, outline=T, addCoef.col = T)


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


##### Modelo de variación en el diámetro de los conductos del ápice #####
## Karla, Mariana, Karen, Iván ##

###Paso1. Cargar base
base <- read.csv("BaseRasgos_UltraCompleta_30dic2020.csv")

####Paso2. Graficas. Y:diámetro apical, X1:long de hoja, X2:altura
par(mfrow=c(1,3))
plot(VD.tip.um ~ long.hoja.concenso, data=base)
plot(VD.tip.um ~ stem.length.m, data=base)
plot(long.hoja.concenso ~ stem.length.m, data=base)

####Convertir a log. Mantener esta transformación, las gráficas se aprecian mejor así. 
par(mfrow=c(1,3))
plot(log(VD.tip.um) ~ log(long.hoja.concenso), data=base)
plot(log(VD.tip.um) ~ log(stem.length.m), data=base)
plot(log(long.hoja.concenso) ~ log(stem.length.m), data=base)

####P3. ¿Qué tanto explica la longitud de la hoja la variación en el diámetro  de los vasos en el ápice de un árbol, 
#con y sin consideración de la altura?

model1<- lm(log(VD.tip.um) ~ log(long.hoja.concenso), data=base)
summary(model1)
model2<- lm(log(VD.tip.um) ~ log(long.hoja.concenso)+log(stem.length.m), data=base)
summary(model2)
model3<-lm(log(VD.tip.um) ~ log(long.hoja.concenso) * log(stem.length.m), data=base)
summary(model3)

####Checar cumplimiento de supuestos en residuos de modelos ajustados
par(mfrow=c(2,2))
plot(model1)
plot(model2)
plot(model3)
