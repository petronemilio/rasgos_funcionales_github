#Libraries
library(ggplot2)
library(corrplot)
library(Hmisc)
library(dplyr)
library(stargazer)
library(lme4)
library(relaimpo)
library(rgl)
library(ggstance)
library(vioplot)
library(car)
library(asbio)
library(lavaan)
library(semPlot)
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
traits.db["leng.lam.pet.mean"] <-(
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
traits.db$area <- (traits.db$unit.leaf.leng)^2
plot(log10(traits.db$VD.tip.um)~ log10(traits.db$area))
######
wood_density <- read.csv("data/WD_VDSD.csv")
hist(wood_density$Wood.Density.g.ml)
wood_density$spe <- paste0(wood_density$genus,"_",wood_density$sp)
#calc mean for each sample
wood_density <- aggregate(Wood.Density.g.ml~ spe, wood_density, mean)
#Match bases
matcher <- match(traits.db$species, wood_density$spe)
traits.db$wood.density <- wood_density$Wood.Density.g.ml[matcher]
plot(log10(traits.db$wood.density) ~ log10(traits.db$unit.leaf.leng))
plot(traits.db$wood.density ~ log10(traits.db$unit.leaf.leng))
ggplot(traits.db, aes(x=(log10(unit.leaf.leng)), 
                      y=(log10(wood.density)), label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)

###### Filtering species without data#####
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
                                        "leng.lam.pet.mean", "unit.leaf.leng",
                                        "leaf.presence","wood.density"))
head(traits.db)
#### Checking relations between variables ####
#wooddensity
plot(log10(traits.db$wood.density) ~ log10(traits.db$unit.leaf.leng))
plot(traits.db$wood.density ~ log10(traits.db$unit.leaf.leng))
ggplot(traits.db, aes(x=(log10(unit.leaf.leng)), 
                      y=(log10(wood.density)), label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)
ggplot(traits.db, aes(x=(log10(unit.leaf.leng)), 
                      y=(wood.density), label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)


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
##### Descriptive statistics ####
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
#
rm(numeric_col, descriptive)
#### Models without aphyllus ####
# As aphyllus might be troublesome to deal with in some models
# we made some models without them.
####Creating a temporal database
traits.temp <- traits.db
nlevels(as.factor(traits.db$order))
nlevels(as.factor(traits.db$family))
nlevels(as.factor(traits.db$genus))
nlevels(as.factor(traits.db$species))
table(traits.db$leaf.type)
#check number of species with more than one individual
spp_df <- as.data.frame(sort(table(traits.db$spe), decreasing = TRUE))
as.data.frame(sort(table(spp_df$Freq), decreasing = TRUE))
#
# Group by mean of multiple columns
traits.db <- traits.db %>% group_by(species) %>% 
  summarise(mean_length=mean(unit.leaf.leng),
            leaf.type = unique(leaf.type)) %>%  as.data.frame()
table(traits.db$leaf.type)
#
traits.db <- traits.temp
traits.db <- subset(traits.db, leaf.type != "aphyllous")
#Before running models checkout number of species and samples without aphyllous
traits.db$leaf.type
###### Adjust the models for vdtip #####
lm.vdtip.stl <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))
lm.vdtip.leaf <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng))
lm.vdtip.stlplusleaf <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m) + 
                             log10(traits.db$unit.leaf.leng))
lm.vdtip.stlintleaf <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m) *
                            log10(traits.db$unit.leaf.leng))
#####Check the models
summary(lm.vdtip.stl) #Vdtip ~ stem length
anova(lm.vdtip.stl) 
plot(lm.vdtip.stl)
confint(lm.vdtip.stl)
summary(lm.vdtip.leaf) #vdtip ~ leaf length
anova(lm.vdtip.leaf)
plot(lm.vdtip.leaf)
confint(lm.vdtip.leaf)
plot(lm.vdtip.leaf$residuals)
summary(lm.vdtip.stlplusleaf) #vdtip ~ stem length + leaf length
anova(lm.vdtip.stlplusleaf)
plot(lm.vdtip.stlplusleaf)
confint(lm.vdtip.stlplusleaf)
summary(lm.vdtip.stlintleaf) #vdtip stem length + leaf length + (sl * ll)
anova(lm.vdtip.stlintleaf)
plot(lm.vdtip.stlintleaf)
confint(lm.vdtip.stlintleaf)
##4 models. Now compared the ss
#SS Extra Full SS Regression Reduced SS Regression
anova(lm.vdtip.stl,lm.vdtip.stlintleaf)
anova( lm.vdtip.leaf,lm.vdtip.stl,lm.vdtip.stlplusleaf,lm.vdtip.stlintleaf)
###Calc the relative imporance of the model with interaction
metrics <- calc.relimp(lm.vdtip.stlintleaf, 
                       type = c("lmg")) #check relative importance using the lmg method
metrics
boot.vdtip <- boot.relimp(lm.vdtip.stlintleaf, b = 1000, type = "lmg", bty = "perc",level = 0.95,
                          fixed=FALSE) #Calc confidence intervals using bootsrap
eval.vdtip <- booteval.relimp(boot.vdtip, typesel = c("lmg"), level = 0.9,
                              bty = "perc", norank = TRUE) #returns values of the confidence intervals
eval.vdtip
plot(metrics, names.abbrev = 3)#plot relative importance
plot(booteval.relimp(boot.vdtip, typesel = c("lmg"), level = 0.9),
     names.abbrev = 2, bty = "perc")#add confidence intervals
#Do the same for vd-base models
##### VD base models #####
lm.vdbase.stl <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))
lm.vdbase.leaf <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng))
lm.vdbase.stlplusleaf <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m) + 
                              log10(traits.db$unit.leaf.leng))
lm.vdbase.stlintleaf <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m) *
                             log10(traits.db$unit.leaf.leng))
#Checking all created models
summary(lm.vdbase.stl)#vd base ~ stem length
anova(lm.vdbase.stl)
plot(lm.vdbase.stl)
confint(lm.vdbase.stl)
summary(lm.vdbase.leaf) #vd base ~ leaf length
anova(lm.vdbase.leaf)
plot(lm.vdbase.leaf)
confint(lm.vdbase.leaf)
summary(lm.vdbase.stlplusleaf) #vd base ~ leaf length + stem length
anova(lm.vdbase.stlplusleaf)
plot(lm.vdbase.stlplusleaf)
confint(lm.vdbase.stlplusleaf)
summary(lm.vdbase.stlintleaf)#vd base ~ leaf length + stem length +(sl*ll)
rm(lm.vdbase.stlintleaf)#remove model with interaction because int is not significant
#
anova(lm.vdbase.leaf,lm.vdbase.stl,lm.vdbase.stlplusleaf)
###
metrics.base <- calc.relimp(lm.vdbase.stlplusleaf, type = c("lmg"))#relaimpo using lmg method
metrics.base
boot.vdbase <- boot.relimp(lm.vdbase.stlplusleaf, b = 1000, type = "lmg", bty = "perc",level = 0.95)
eval.vdbase <- booteval.relimp(boot.vdbase, typesel = c("lmg"), level = 0.9,
                               bty = "perc", norank = TRUE)
plot(metrics.base, names.abbrev = 3)
plot(booteval.relimp(boot.vdbase, typesel = c("lmg", "pmvd"), level = 0.9),
     names.abbrev = 2, bty = "perc")
####Make plots of relaimpo for both models
pdf("Results/FigureRelimpvdtip.pdf", height = 8, width = 8) # Para guardar en PDF
plot(booteval.relimp(boot.vdtip, typesel ="lmg", level = 0.9),
     names.abbrev = 2, bty = "perc")
dev.off()
pdf("Results/FigureRelimpvdbase.pdf", height = 8, width = 8) # Para guardar en PDF
plot(booteval.relimp(boot.vdbase, typesel = "lmg", level = 0.9),
     bty = "perc")
dev.off()

#### Table 2: models ####
stargazer(lm.vdtip.leaf,lm.vdtip.stl,lm.vdtip.stlplusleaf,
          lm.vdtip.stlintleaf, out = "Results/table2.html")#create tables for vdtip models
stargazer(lm.vdbase.leaf, lm.vdbase.stl, lm.vdbase.stlplusleaf,
          out = "Results/table3.html") #create tables for vdbase models
#### Ploting model results ####
####Trying to perform path analysis
traits.db$VD.base.log <- log10(traits.db$VD.base.um)
traits.db$VD.tip.log <- log10(traits.db$VD.tip.um)
traits.db$stem.length.log <- log10(traits.db$stem.length.m)
traits.db$unit.leaf.leng.log <- log10(traits.db$unit.leaf.leng)

####
model1 <- '
VD.base.log ~ VD.tip.log + stem.length.log + unit.leaf.leng.log 
VD.tip.log ~ unit.leaf.leng.log + stem.length.log
'
model1.fit <- sem(model1, data=traits.db)
summary(model1.fit,fit.measures=TRUE, rsquare=TRUE,standardized=TRUE)
# Print the standardized coefficients
lavaan::summary(model1.fit, standardized = TRUE)
###
model2 <- '
VD.base.log ~ VD.tip.log + stem.length.log + unit.leaf.leng.log 
VD.tip.log ~ unit.leaf.leng.log 
'
model2.fit <- sem(model2, data=traits.db)
summary(model2.fit,fit.measures=TRUE, rsquare=TRUE)
###
model3 <- '
VD.base.log ~ VD.tip.log + stem.length.log + unit.leaf.leng.log 
VD.tip.log ~ unit.leaf.leng.log 
unit.leaf.leng.log ~ stem.length.log 
'
model3.fit <- sem(model3, data=traits.db)
summary(model3.fit,fit.measures=TRUE, rsquare=TRUE)
#
model4 <- '
VD.base.log ~ VD.tip.log  
VD.tip.log ~ unit.leaf.leng.log + stem.length.log
unit.leaf.leng.log ~ stem.length.log
'
#
model4.fit <- sem(model4, data=traits.db)
summary(model4.fit,fit.measures=TRUE, rsquare=TRUE)

p1<-lavaanPlot::lavaanPlot(model = model1.fit, 
           node_options = list(shape = "box", fontname = "Helvetica"), 
           edge_options = list(color = "grey"), coefs = TRUE, covs = TRUE, stars = "covs")
lavaanPlot::save_png(p1, "Results/pathmodel1.png")
#
p2<- lavaanPlot::lavaanPlot(model = model2.fit, 
           node_options = list(shape = "box", fontname = "Helvetica"), 
           edge_options = list(color = "grey"), coefs = TRUE,covs = TRUE, stars = "covs")
lavaanPlot::save_png(p2, "Results/pathmodel2.png")
#
p3 <- lavaanPlot::lavaanPlot(model = model3.fit, 
           node_options = list(shape = "box", fontname = "Helvetica"), 
           edge_options = list(color = "grey"), coefs = TRUE,covs = TRUE, stars = "covs")
lavaanPlot::save_png(p3, "Results/pathmodel3.png")
#
p4 <- lavaanPlot::lavaanPlot(model = model4.fit, 
                             node_options = list(shape = "box", fontname = "Helvetica"), 
                             edge_options = list(color = "grey"), coefs = TRUE,covs = TRUE, stars = "covs")
lavaanPlot::save_png(p4, "Results/pathmodel4.png")
#significant_paths <- p.values < 0.05

# Plot the path diagram with only significant paths
pdf("Results/sempathsm1.pdf", height = 8, width = 8) 
semPaths(model1.fit,"par",style="lisrel",edge.label.cex=1.5, curvePivot = TRUE,
         sizeMan= 12,curveAdjacent = 'reg')
dev.off()
semPaths(model1.fit,"par",style="lisrel",edge.label.cex=1.5,
         residuals=TRUE,curvePivot = TRUE,thresholds = TRUE,
         sizeMan= 12,curveAdjacent = 'reg')
?semPaths
pdf("Results/sempathsm2.pdf", height = 8, width = 8) 
semPaths(model2.fit,"par",style="lisrel",sizeMan = 12,
         edge.label.cex=1.5, curveAdjacent = 'reg')
dev.off()
pdf("Results/sempathsm3.pdf", height = 8, width = 8) 
semPaths(model3.fit,"par",style = "lisrel",curveAdjacent = 'reg',sizeMan = 12,
         edge.label.cex=1.5, curvePivot = TRUE)
dev.off()
pdf("Results/sempathsm4.pdf", height = 8, width = 8) 
semPaths(model4.fit,"par",style = "lisrel",curveAdjacent = 'reg',sizeMan = 12,
         edge.label.cex=1.5, curvePivot = TRUE)
dev.off()
?semPaths
