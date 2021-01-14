#Libraries
library(ggplot2)
library(corrplot)
library(Hmisc)
library(dplyr)

# Load data.frame
traits <- read.csv("data/df_traits.csv", header = T)
names(traits) #check names

#### exploratory analyses ####

# Select columns 
traits.db<-traits[c(1:7,11:21)]
names(traits.db) #check names
colnames(traits.db) <- c("order", "family", "genus", "species.epithet", "stem.length.m",
                         "VD.base.um", "VD.tip.um", "min.length.leaf", "max.length.leaf",
                         "min.length.petiole","max.length.petiole","min.length.blade",
                         "max.length.blade", "min.width.blade", "max.width.blade",
                         "leaf.type", "length.leaf.cm", "width.leaf.cm") #new col names

names(traits.db) #check names

# Combine epithet and genus columns to create a species column
traits.db$species <- paste(traits.db$genus, traits.db$species.epithet, sep = "_")
names(traits.db) #check names

# Creating new columns for each different source. 
traits.db["leng.leaf"]<-traits.db[17]  #1) total leaf length
traits.db["leng.leaf.mean"]<-(traits.db[8]+traits.db[9])/2 
  #2) Average leaf length
traits.db["leng.lam.pet.mean"]<-(
  (traits.db[10]+traits.db[11])/2)+((traits.db[12]+traits.db[13])/2) 
  #3) Sum of the averages of blade and petiole
names(traits.db) #check names

# Check the differences between different sources of leaf lenght information 
traits.db$difference1_2 <- abs(traits.db$leng.leaf - traits.db$leng.leaf.mean)
traits.db$difference1_3 <- abs(traits.db$leng.leaf - traits.db$leng.lam.pet.mean)
traits.db$difference2_3 <- abs(traits.db$leng.leaf.mean - traits.db$leng.lam.pet.mean)
names(traits.db) #check names

# Making a plot to check species with unusual values
ggplot(traits.db, aes(x=(log10(leng.leaf)), 
                      y=(log10(leng.lam.pet.mean)), label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)


# Plotting for outliers
dotchart(log10(traits.db$leng.leaf))
dotchart(log10(traits.db$leng.leaf.mean))
dotchart(log10(traits.db$leng.lam.pet.mean))

#### Creating final consensus variable ####

# Making a new col that includes the two principal sources of information

#If there is an NA in long.lam.pet.mean, then print long.hoja.mean; if thats 
#not the case, then print long.lam.pet.mean
traits.db$intermediate <- with(traits.db, ifelse(is.na(leng.lam.pet.mean),
                                                 leng.leaf.mean, leng.lam.pet.mean))
head(traits.db)

# Unite the new column with the last source of information
# If there is an NA in intermediate then print leng.leaf else print intermediate
traits.db$unit.leaf.leng <- with(traits.db, ifelse(!is.na(intermediate),
                                               intermediate, leng.leaf))

## Add new col whit or whitout leaf
traits.db$leaf.presence <- with(traits.db, ifelse(leaf.type != "aphyllous", TRUE, FALSE))


# Filtering species without data
traits.db <- subset(traits.db, !is.na(unit.leaf.leng))

# Restructure the data.frame 
names(traits.db)
traits.db <- subset(traits.db, select=c("order","family","genus","species",
                                        "stem.length.m","VD.base.um",
                                        "VD.tip.um",
                                        "min.length.leaf", "max.length.leaf",
                                        "min.length.petiole", "max.length.petiole",
                                        "min.length.blade", "max.length.blade", 
                                        "leaf.type","leng.leaf", "leng.leaf.mean",
                                        "leng.lam.pet.mean", "unit.leaf.leng", "leaf.presence"))
head(traits.db)

# Check for outliers in the new variable (unit.leaf.leng)
dotchart(traits.db$unit.leaf.leng)
# To compare between different orders of magnitude we transformed into log10. 
dotchart(log10(traits.db$unit.leaf.leng))
hist(log10(traits.db$unit.leaf.leng))

# Bivariate correlation analysis
names(traits.db) #Check names
leng.leaf.cor <-subset(traits.db[, c(5, 6, 7, 18)]) # Select variables of interest

# Correlation matrix
leng.leaf.matrix <- rcorr(as.matrix(leng.leaf.cor))
leng.leaf.matrix$r # Correlation values between variables

# Plotting 

pdf("Results/Figura2.pdf", height = 8, width = 8) # Para guardar en PDF
png("Results/Figura2.png", height = 480, width = 480) # Para guardar en PNG

corrplot(leng.leaf.matrix$r, type="upper", order="hclust", 
         p.mat = leng.leaf.matrix$P, sig.level = 0.05, bg="WHITE",
         tl.col = "black", tl.srt = 45, pch.cex=1, outline=T,
         addCoef.col = T)
dev.off()

#### Descriptive statistics ####
numeric_col <- select_if(traits.db, is.numeric)
.min <- apply(numeric_col, 2, min, na.rm = TRUE)
.max <- apply(numeric_col, 2, max, na.rm = TRUE)
.mean <- apply(numeric_col, 2, mean, na.rm = TRUE)
.median  <- apply(numeric_col, 2, median, na.rm = TRUE)
.sd <-  apply(numeric_col, 2, sd, na.rm = TRUE)
.var <- apply(numeric_col, 2, var, na.rm = TRUE)
descriptive <- rbind(.min, .max, .mean, .median, .sd, .var)

tabla1 <- as.data.frame(descriptive[,c(3,2,13,1)])
write.table(tabla1, "Results/tabla1.csv")

#### Models ####
# To compare between different orders of magnitude we transformed into log10.

#### DISCUSION EN CLASE. ELIMINAR 0'S ####
traits.db <- subset(traits.db, unit.leaf.leng != 0)
# # # - # # # - # # #

# Stem tip without consider stem length
plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng))
lm_vdtip.leaf.log <-lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng))
summary(lm_vdtip.leaf.log)
anova(lm_vdtip.leaf.log)
abline(lm_vdtip.leaf.log, col = "red", lwd = 2)


# Stem base without consider stem length.
plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng))
lm_vdbase.leaf.log <-lm(log10(traits.db$VD.base.um)
                        ~ log10(traits.db$unit.leaf.leng))
summary(lm_vdbase.leaf.log)
anova(lm_vdbase.leaf.log)
abline(lm_vdbase.leaf.log, col = "red", lwd = 2)

# Stem tip considering stem length
plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))

# Multiplicative model 
lm_vdtip.leaf.log.stem.M <-lm(log10(traits.db$VD.tip.um) ~
                                log10(traits.db$unit.leaf.leng) 
                              * log10(traits.db$stem.length.m))
summary(lm_vdtip.leaf.log.stem.M)
anova(lm_vdtip.leaf.log.stem.M)

#Aditive Model
lm_vdtip.leaf.log.stem <-lm(log10(traits.db$VD.tip.um) ~
                              log10(traits.db$unit.leaf.leng) 
                            + log10(traits.db$stem.length.m))
summary(lm_vdtip.leaf.log.stem)
anova(lm_vdtip.leaf.log.stem)

abline(lm_vdtip.leaf.log.stem, col = "red", lwd = 2) ## Hecho con el Modelo aditivo discutir en clase

# Stem base considering stem length
plot(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))

# Multiplicative model
lm_vdbase.leaf.log.stem.M <-lm(log10(traits.db$VD.base.um) ~
                               log10(traits.db$unit.leaf.leng) 
                             * log10(traits.db$stem.length.m))
summary(lm_vdbase.leaf.log.stem.M)
anova(lm_vdbase.leaf.log.stem.M)

#Aditive Model
lm_vdbase.leaf.log.stem <-lm(log10(traits.db$VD.base.um) ~
                               log10(traits.db$unit.leaf.leng) 
                             + log10(traits.db$stem.length.m))
summary(lm_vdbase.leaf.log.stem)
anova(lm_vdbase.leaf.log.stem)
abline(lm_vdbase.leaf.log.stem, col = "red", lwd = 2)


#### Falta poner comandos para generar la tabla 2 (parámetros de los modelos)

# Plotting residuals
par(mfrow = c(2,2))
plot(lm_vdbase.leaf.log)
par(mfrow = c(2,2))
plot(lm_vdbase.leaf.log.stem)

# Plotting residuals
par(mfrow = c(2,2))
plot(lm_vdtip.leaf.log)
par(mfrow = c(2,2))
plot(lm_vdtip.leaf.log.stem)

#### Figura 3 ####

png("Results/Figura3.png", height = 480, width = 480) # Para guardar en PNG

par(mfrow = c(2,2))
plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng),
     xlab = "log10(leaf.length.m)", ylab = "log10(VD.tip.um)")

abline(lm_vdtip.leaf.log, col = "red", lwd = 2)

plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng),
     xlab = "log10(leaf.length.m)", ylab = "log10(VD.base.um)")

abline(lm_vdbase.leaf.log, col = "red", lwd = 2)

plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng),
     xlab = "log10(leaf.length.m)", ylab = "log10(VD.tip.um)") # Discutir cómo se van a graficar las últimas dos

#abline(0.994, 0.14, col = "black", lwd = 2)
#abline(0.994, 0.054, col = "red", lwd = 2)
#abline(0.994, 0.88, col =  "blue", lwd = 2)

#plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng),
     #xlab = "log10(leaf.length.m)", ylab = "log10(VD.tip.um)") # Discutir cómo se van a graficar las últimas dos

#abline(0.96, 0.18, col = "black", lwd = 2)
#abline(0.96, 0.13, col = "red", lwd = 2)

plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng),
     xlab = "log10(leaf.length.m)", ylab = "log10(VD.base.um)")

#abline(1.41, 0.06, col = "black", lwd = 2)
#abline(1.41, 0.36, col = "red", lwd = 2)
#abline(1.41, 0.04, col =  "blue", lwd = 2)

#plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng),
     #xlab = "log10(leaf.length.m)", ylab = "log10(VD.base.um)")

#abline(1.39, 0.086, col = "black", lwd = 2)
#abline(1.39, 0.4, col = "red", lwd = 2)

dev.off()


# Presence leaf
#Lo hicimos pero creemos que NO es informativo, discutir en clase. 
lm_leaf.presence <- lm(log10(traits.db$VD.tip.um) ~
                              log10(traits.db$unit.leaf.leng) 
                            + log10(traits.db$stem.length.m)+ traits.db$leaf.presence)
anova(lm_leaf.presence)
summary(lm_leaf.presence)

lm_leaf.presence.M <- lm(log10(traits.db$VD.tip.um) ~
                         log10(traits.db$unit.leaf.leng) 
                       * log10(traits.db$stem.length.m) * traits.db$leaf.presence)

anova(lm_leaf.presence.M)
summary(lm_leaf.presence.M)


#Type leaf
# Creemos que no es informativo, discutir en clase
traits.db.2 <- subset(traits.db, leaf.type!= "aphyllous")

lm_leaf.type <- lm(log10(traits.db.2$VD.tip.um) ~
                         log10(traits.db.2$unit.leaf.leng) 
                       + log10(traits.db.2$stem.length.m)+ traits.db.2$leaf.type)
anova(lm_leaf.type)
summary(lm_leaf.type)

lm_leaf.type.M <- lm(log10(traits.db.2$VD.tip.um) ~
                       log10(traits.db.2$unit.leaf.leng) 
                     * log10(traits.db.2$stem.length.m) * traits.db.2$leaf.type)

anova(lm_leaf.type.M)
summary(lm_leaf.type.M)


##Fin##
