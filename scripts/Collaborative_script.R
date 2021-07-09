#Libraries
library(ggplot2)
library(corrplot)
library(Hmisc)
library(dplyr)
library(stargazer)

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

####Create variables to estimate leaf are from length and with of the blade
traits.db$leng.blade.mean <- (traits.db$min.length.blade + traits.db$max.length.blade)/2
traits.db$width.blade.mean <- (traits.db$min.width.blade + traits.db$max.width.blade)/2
plot(log10(traits.db$leng.blade.mean) ~ log10(traits.db$width.blade.mean))

######Area
traits.db$area <- (traits.db$leng.blade.mean*traits.db$width.blade.mean)
plot(log10(traits.db$VD.tip.um)~ log10(traits.db$area))
###Fast check of the model
lm.vdtip.leafarea <- lm(log10(traits.db$VD.tip.um)~ log10(traits.db$area)) 
summary(lm.vdtip.leafarea)
abline(lm.vdtip.leafarea, col = "red", lwd = 2)
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


#### Checking relations between variables ####

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

# Plotting: Fig. 2

pdf("Results/Figura2.pdf", height = 8, width = 8) # Para guardar en PDF
png("Results/Figura2.png", height = 480, width = 480) # Para guardar en PNG

corrplot(leng.leaf.matrix$r, type="upper", order="hclust", 
         p.mat = leng.leaf.matrix$P, sig.level = 0.05, bg="WHITE",
         tl.col = "black", tl.srt = 45, pch.cex=1, outline=T,
         addCoef.col = T)
dev.off()

rm(leng.leaf.cor, leng.leaf.matrix)

#### Descriptive statistics ####
numeric_col <- select_if(traits.db, is.numeric)
.min <- apply(numeric_col, 2, min, na.rm = TRUE)
.max <- apply(numeric_col, 2, max, na.rm = TRUE)
.mean <- apply(numeric_col, 2, mean, na.rm = TRUE)
.median  <- apply(numeric_col, 2, median, na.rm = TRUE)
.sd <-  apply(numeric_col, 2, sd, na.rm = TRUE)
.var <- apply(numeric_col, 2, var, na.rm = TRUE)
descriptive <- rbind(.min, .max, .mean, .median, .sd, .var)

table1 <- as.data.frame(descriptive[,c(3,2,13,1)])
write.table(table1, "Results/tabla1.csv")


rm(numeric_col, descriptive)
table(traits.db$leaf.type)
#### Models with aphyllus ####
# To compare between different orders of magnitude we transformed into log10.
# As the log10 of 0 is INF, we add +1 (constant) to unit.leaf.leng


##Models without consider stem length
# Stem TIP without consider stem length: r^2: 0.29.
plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng))
lm_vdtip.leaf.log <-lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng+1))
summary(lm_vdtip.leaf.log)
anova(lm_vdtip.leaf.log)
abline(lm_vdtip.leaf.log, col = "red", lwd = 2)


# Stem BASE without consider stem length: r^2: 0.24.
plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng))
lm_vdbase.leaf.log <-lm(log10(traits.db$VD.base.um)
                        ~ log10(traits.db$unit.leaf.leng+1))
summary(lm_vdbase.leaf.log)
anova(lm_vdbase.leaf.log)
abline(lm_vdbase.leaf.log, col = "red", lwd = 2)

## Models considering stem length
# Stem TIP considering stem length
plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))

# Multiplicative model: R^2 = 0.37
lm_vdtip.leaf.log.stem.M <-lm(log10(traits.db$VD.tip.um) ~
                                log10(traits.db$unit.leaf.leng+1) 
                              * log10(traits.db$stem.length.m))
summary(lm_vdtip.leaf.log.stem.M)
anova(lm_vdtip.leaf.log.stem.M)
# As it is proven that a relation betwwen unit.leaf.leng and stem.length.m
# does exist, it is not necessary to create an additive model.

#Aditive Model, not used.
#lm_vdtip.leaf.log.stem <-lm(log10(traits.db$VD.tip.um) ~
#                             log10(traits.db$unit.leaf.leng+1) 
#                          + log10(traits.db$stem.length.m))
#summary(lm_vdtip.leaf.log.stem)
#anova(lm_vdtip.leaf.log.stem)

abline(lm_vdtip.leaf.log.stem.M, col = "red", lwd = 2) # multiplicative model

# Stem BASE considering stem length
plot(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))

# Multiplicative model: r^2:0.64
lm_vdbase.leaf.log.stem.M <-lm(log10(traits.db$VD.base.um) ~
                               log10(traits.db$unit.leaf.leng+1) 
                             * log10(traits.db$stem.length.m))
summary(lm_vdbase.leaf.log.stem.M)
anova(lm_vdbase.leaf.log.stem.M)
# As it is proven that a relation betwwen unit.leaf.leng and stem.length.m
# does exist, it is not necessary to create an additive model.

#Aditive Model
#lm_vdbase.leaf.log.stem <-lm(log10(traits.db$VD.base.um) ~
#                               log10(traits.db$unit.leaf.leng+1) 
#                             + log10(traits.db$stem.length.m))
#summary(lm_vdbase.leaf.log.stem)
#anova(lm_vdbase.leaf.log.stem)


abline(lm_vdbase.leaf.log.stem.M, col = "red", lwd = 2) # multiplicative model

## Models considering stem length and leaf presence

# TIP

# Plot
plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))
# Multiplicative Not used.
#lm_tip_leaf.presence.M <- lm(log10(traits.db$VD.tip.um) ~
#                           log10(traits.db$unit.leaf.leng+1) 
#                         * log10(traits.db$stem.length.m) * traits.db$leaf.presence)
#summary(lm_leaf.presence.M)
#anova(lm_leaf.presence.M)

# There's no relation between the three variables nor with leaf.presence and
# any other variable

#Additive: R^2: 0.39
lm_tip_leaf.presence <- lm(log10(traits.db$VD.tip.um) ~
                         log10(traits.db$unit.leaf.leng+1) 
                       + log10(traits.db$stem.length.m)+ traits.db$leaf.presence)
summary(lm_leaf.presence)
anova(lm_leaf.presence)
abline(lm_tip_leaf.presence, col = "red", lwd = 2)

# BASE

# Plot
plot(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))
# Multiplicative Not used.
#lm_base_leaf.presence.M <- lm(log10(traits.db$VD.base.um) ~
#                           log10(traits.db$unit.leaf.leng+1) 
#                         * log10(traits.db$stem.length.m) * traits.db$leaf.presence)
#summary(lm_base_leaf.presence.M)
#anova(lm_base_leaf.presence.M)
# There's no relation between the three variables nor with leaf.presence and
# any other variable

#Additive: R^2: 0.64
lm_base_leaf.presence <- lm(log10(traits.db$VD.base.um) ~
                              log10(traits.db$unit.leaf.leng+1) 
                            + log10(traits.db$stem.length.m)+ traits.db$leaf.presence)
summary(lm_base_leaf.presence)
anova(lm_base_leaf.presence)
abline(lm_base_leaf.presence, lwd = 2)


## Models considering stem length and leaf type

# TIP

# Multiplicative Not used.
#lm_tip_leaf.type.M <- lm(log10(traits.db$VD.tip.um) ~
#                           log10(traits.db$unit.leaf.leng+1) 
#                         * log10(traits.db$stem.length.m) * traits.db$leaf.type)
#summary(lm_tip_leaf.type.M)
#anova(lm_tip_leaf.type.M)
# There's no relation between the three variables nor with leaf.type and
# any other variable

#Additive: R^2: 0.39
lm_tip_leaf.type<- lm(log10(traits.db$VD.tip.um) ~
                        log10(traits.db$unit.leaf.leng+1) 
                      + log10(traits.db$stem.length.m)+ traits.db$leaf.type)
summary(lm_tip_leaf.type)
anova(lm_tip_leaf.type)
abline(lm_tip_leaf.type, col = "red", lwd = 2)

# BASE

# Plot
plot(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))
# Multiplicative Not used.
# lm_base_leaf.type.M <- lm(log10(traits.db$VD.base.um) ~
#                           log10(traits.db$unit.leaf.leng+1) 
#                         * log10(traits.db$stem.length.m) * traits.db$leaf.type)
#summary(lm_base_leaf.type.M)
#anova(lm_base_leaf.type.M)
# There's no relation between the three variables nor with leaf.presence and
# any other variable

#Additive: R^2: 0.64
lm_base_leaf.type <- lm(log10(traits.db$VD.base.um) ~
                          log10(traits.db$unit.leaf.leng+1) 
                        + log10(traits.db$stem.length.m)+ traits.db$leaf.type)
summary(lm_base_leaf.type)
anova(lm_base_leaf.type)
abline(lm_base_leaf.type, lwd = 2)

#Note that nor considering leaf presence nor leaf type the r^2 increases.

#### Models without aphyllus ####
# As aphyllus might be troublesome to deal with in some models
# we also made some models without them.

traits.leafy <- subset(traits.db, leaf.type != "aphyllous")

##Models without consider stem length
# Stem TIP without consider stem length: r^2: 0.31.
plot(log10(traits.leafy$VD.tip.um) ~ log10(traits.leafy$unit.leaf.leng))
lm_vdtip.leaf.log.a <-lm(log10(traits.leafy$VD.tip.um) ~ log10(traits.leafy$unit.leaf.leng))
summary(lm_vdtip.leaf.log.a)
anova(lm_vdtip.leaf.log.a)
abline(lm_vdtip.leaf.log.a, col = "red", lwd = 2)


# Stem BASE without consider stem length: r^2: 0.25.
plot(log10(traits.leafy$VD.base.um) ~ log10(traits.leafy$unit.leaf.leng))
lm_vdbase.leaf.log.a <-lm(log10(traits.leafy$VD.base.um)
                        ~ log10(traits.leafy$unit.leaf.leng))
summary(lm_vdbase.leaf.log.a)
anova(lm_vdbase.leaf.log.a)
abline(lm_vdbase.leaf.log.a, col = "red", lwd = 2)

## Models considering stem length
# Stem TIP considering stem length
plot(log10(traits.leafy$VD.tip.um) ~ log10(traits.leafy$stem.length.m))

# Multiplicative model: R^2 = 0.39
lm_vdtip.leaf.log.stem.M.a <-lm(log10(traits.leafy$VD.tip.um) ~
                                log10(traits.leafy$unit.leaf.leng) 
                              * log10(traits.leafy$stem.length.m))
summary(lm_vdtip.leaf.log.stem.M.a)
anova(lm_vdtip.leaf.log.stem.M.a)
# As it is proven that a relation betwwen unit.leaf.leng and stem.length.m
# does exist, it is not necessary to create an additive model.

#Aditive Model, not used.
#lm_vdtip.leaf.log.stem.a <-lm(log10(traits.leafy$VD.tip.um) ~
#                             log10(traits.leafy$unit.leaf.leng) 
#                          + log10(traits.leafy$stem.length.m))
#summary(lm_vdtip.leaf.log.stem.a)
#anova(lm_vdtip.leaf.log.stem.a)

abline(lm_vdtip.leaf.log.stem.M.a, col = "red", lwd = 2) # multiplicative model

# Stem BASE considering stem length
plot(log10(traits.leafy$VD.base.um) ~ log10(traits.leafy$stem.length.m))

# Multiplicative model Not used.
# lm_vdbase.leaf.log.stem.M.a <-lm(log10(traits.leafy$VD.base.um) ~
#                                 log10(traits.leafy$unit.leaf.leng) 
#                               * log10(traits.leafy$stem.length.m))
#summary(lm_vdbase.leaf.log.stem.M.a)
#anova(lm_vdbase.leaf.log.stem.M.a)
# As it is proven that a relation between unit.leaf.leng and stem.length.m
# don't exist, we make an additive model

#Aditive Model: r^2: 0.64
lm_vdbase.leaf.log.stem.a <-lm(log10(traits.leafy$VD.base.um) ~
                               log10(traits.leafy$unit.leaf.leng) 
                             + log10(traits.leafy$stem.length.m))
summary(lm_vdbase.leaf.log.stem.a)
anova(lm_vdbase.leaf.log.stem.a)


abline(lm_vdbase.leaf.log.stem.M.a, col = "red", lwd = 2) # multiplicative model

## Models considering stem length and leaf type

# TIP

# Multiplicative Not used.
# lm_tip_leaf.type.M.a <- lm(log10(traits.leafy$VD.tip.um) ~
#                          log10(traits.leafy$unit.leaf.leng) 
#                         * log10(traits.leafy$stem.length.m) * traits.leafy$leaf.type)
# summary(lm_tip_leaf.type.M.a)
# anova(lm_tip_leaf.type.M.a)
# There's no relation between the three variables nor with leaf.type and
# any other variable

#Additive not used. 
# lm_tip_leaf.type.a<- lm(log10(traits.leafy$VD.tip.um) ~
#                       log10(traits.leafy$unit.leaf.leng) 
#                     + log10(traits.leafy$stem.length.m)+ traits.leafy$leaf.type)
#summary(lm_tip_leaf.type.a)
#anova(lm_tip_leaf.type.a)
#abline(lm_tip_leaf.type.a, col = "red", lwd = 2)
# The probabily (p-value) of the leaf.type variable to be explained by just randomess is too high 
# to accept the Ha.

# BASE

# Plot
#plot(log10(traits.leafy$VD.base.um) ~ log10(traits.leafy$stem.length.m))
# Multiplicative Not used.
# lm_base_leaf.type.M.a <- lm(log10(traits.leafy$VD.base.um) ~
#                           log10(traits.leafy$unit.leaf.leng) 
#                         * log10(traits.leafy$stem.length.m) * traits.leafy$leaf.type)
#summary(lm_base_leaf.type.M.a)
#anova(lm_base_leaf.type.M.a)
# There's no relation between the three variables nor with leaf.type and
# any other variable

#Additive: R^2 not used.
#lm_base_leaf.type.a <- lm(log10(traits.leafy$VD.base.um) ~
#                          log10(traits.leafy$unit.leaf.leng) 
#                        + log10(traits.leafy$stem.length.m)+ traits.leafy$leaf.type)
#summary(lm_base_leaf.type.a)
#anova(lm_base_leaf.type.a)
#abline(lm_base_leaf.type.a, lwd = 2)
# The probability that the variability in leaf.type might be explained by randomess is
# to high to reject H0

#### Residuals ####
# Stem TIP without consider stem length
par(mfrow = c(2,2))
plot(lm_vdtip.leaf.log.a)

# Stem BASE without consider stem length
par(mfrow = c(2,2))
plot(lm_vdbase.leaf.log.a)

# Stem TIP considering stem length (Multiplicative)
par(mfrow = c(2,2))
plot(lm_vdtip.leaf.log.stem.M.a)

# Stem BASE considering stem length (Additive)
par(mfrow = c(2,2))
plot(lm_vdbase.leaf.log.stem.a)


dev.off()

#### Table 2: models ####
stargazer(
  lm_vdtip.leaf.log,
  lm_vdbase.leaf.log,
  lm_vdtip.leaf.log.stem.M,
# lm_vdtip.leaf.log.stem,
  lm_vdbase.leaf.log.stem.M,
# lm_vdbase.leaf.log.stem,
# lm_tip_leaf.presence.M,
  lm_tip_leaf.presence,
# lm_base_leaf.presence.M,
  lm_base_leaf.presence,
# lm_tip_leaf.type.M,
  lm_tip_leaf.type,
# lm_base_leaf.type.M,
  lm_base_leaf.type, 
out = "Results/table2.html"
) # This produces an html file that can be open in a web
# browser and copy-pasted in a word document (.doc or .docx)


#### Ploting model results ####

# Ploting models: Fig. 3 

# png("Results/Figura3.png", height = 480, width = 480) # Para guardar en PNG

# par(mfrow = c(2,2))
# plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng+1),
#     xlab = "log10(leaf.length.m)", ylab = "log10(VD.tip.um)")

#abline(lm_vdtip.leaf.log, col = "red", lwd = 2)

#plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng+1),
#     xlab = "log10(leaf.length.m)", ylab = "log10(VD.base.um)")

#abline(lm_vdbase.leaf.log, col = "red", lwd = 2)

#plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng+1),
#     xlab = "log10(leaf.length.m)", ylab = "log10(VD.tip.um)") # Discutir cómo se van a graficar las últimas dos

#abline(0.994, 0.14, col = "black", lwd = 2)
#abline(0.994, 0.054, col = "red", lwd = 2)
#abline(0.994, 0.88, col =  "blue", lwd = 2)

#plot(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng),
#xlab = "log10(leaf.length.m)", ylab = "log10(VD.tip.um)") # Discutir cómo se van a graficar las últimas dos

#abline(0.96, 0.18, col = "black", lwd = 2)
#abline(0.96, 0.13, col = "red", lwd = 2)

#plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng),
#     xlab = "log10(leaf.length.m)", ylab = "log10(VD.base.um)")

#abline(1.41, 0.06, col = "black", lwd = 2)
#abline(1.41, 0.36, col = "red", lwd = 2)
#abline(1.41, 0.04, col =  "blue", lwd = 2)

#plot(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng),
#xlab = "log10(leaf.length.m)", ylab = "log10(VD.base.um)")

#abline(1.39, 0.086, col = "black", lwd = 2)
#abline(1.39, 0.4, col = "red", lwd = 2)
hist(log10(traits.db$VD.base.um))
hist(log10(traits.db$VD.tip.um))
traits.db$widening <- log10(traits.db$VD.base.um)/log10(traits.db$VD.tip.um)
plot(log10(traits.db$widening))
plot(traits.db$widening ~ log10(traits.db$stem.length.m))
plot(log10(traits.db$widening) ~ log10(traits.db$stem.length.m))

lm_widening.stem <- lm(traits.db$widening ~ log10(traits.db$stem.length.m))
summary(lm_widening.stem)

lm_widening.leaf.stem <- lm(log10(traits.db$widening) ~ 
                              log10(traits.db$stem.length.m)* log10(traits.db$unit.leaf.leng+1))
summary(lm_widening.leaf.stem)
plot(log10(traits.db$widening) ~ log10(traits.db$unit.leaf.leng))
plot(traits.db$widening ~ log10(traits.db$unit.leaf.leng))

lm_widening.leaf <- lm(log10(traits.db$widening) ~ log10(traits.db$unit.leaf.leng+1))
summary(lm_widening.leaf)

lm_vdbase.stem <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))
summary(lm_vdbase.stem)
lm_vdtip.stem <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))
summary(lm_vdtip.stem)
