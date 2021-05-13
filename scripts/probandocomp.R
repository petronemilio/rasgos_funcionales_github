library(rgl)
library(scatterplot3d)
library(ggstance)
library(vioplot)
library(car)
library(hier.part)
library(asbio)
library(relaimpo)
######Creating a temporal database and removing aphyllous species#####
traits.temp <- traits.db

traits.db <- subset(traits.db, leaf.type != "aphyllous")

###### Adjust the models for vdtip #####
lm.vdtip.stl <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))
lm.vdtip.leaf <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng))
lm.vdtip.stlplusleaf <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m) + 
                             log10(traits.db$unit.leaf.leng))
lm.vdtip.stlintleaf <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m) *
                            log10(traits.db$unit.leaf.leng))

#####Check the models
summary(lm.vdtip.stl)
anova(lm.vdtip.stl)
plot(lm.vdtip.stl)
confint(lm.vdtip.stl)
#
summary(lm.vdtip.leaf)
anova(lm.vdtip.leaf)
plot(lm.vdtip.leaf)
confint(lm.vdtip.leaf)
plot(lm.vdtip.leaf$residuals)
#
summary(lm.vdtip.stlplusleaf)
anova(lm.vdtip.stlplusleaf)
plot(lm.vdtip.stlplusleaf)
confint(lm.vdtip.stlplusleaf)
#
summary(lm.vdtip.stlintleaf)
anova(lm.vdtip.stlintleaf)
plot(lm.vdtip.stlintleaf)
confint(lm.vdtip.stlintleaf)
##4 models. Now compared the ss
#SS Extra ⫽Full SS Regression ⫺Reduced SS Regression
anova(lm.vdtip.stl,lm.vdtip.stlintleaf)
anova( lm.vdtip.leaf,lm.vdtip.stl,lm.vdtip.stlplusleaf,lm.vdtip.stlintleaf)
####
hier.part(traits.db$VD.tip.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu")
rand.hp(traits.db$VD.tip.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu",
        num.reps = 100)$Iprobs
####

metrics <- calc.relimp(lm.vdtip.stlplusleaf, type = c("lmg","first", "last","betasq", "pratt"),
                       rela = TRUE)
metrics
boot.vdtip <- boot.relimp(lm.vdtip.stlplusleaf, b = 1000, type = "lmg", bty = "perc",level = 0.95)
eval.vdtip <- booteval.relimp(boot.vdtip, typesel = c("lmg", "pmvd"), level = 0.9,
                              bty = "perc", norank = TRUE)
eval.vdtip
plot(metrics, names.abbrev = 3)
plot(booteval.relimp(boot.vdtip, typesel = c("lmg", "pmvd"), level = 0.9),
     names.abbrev = 2, bty = "perc")

#(SSEreduced - SSEfull) / SSEreduced
#Partial r2
partial.R2(lm.vdtip.leaf, lm.vdtip.stlintleaf)
partial.R2(lm.vdtip.stl, lm.vdtip.stlintleaf)
partial.R2(lm.vdtip.leaf,lm.vdtip.stlplusleaf)
partial.R2(lm.vdtip.stl,lm.vdtip.stlplusleaf)

##### VD base models #####
lm.vdbase.stl <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))
lm.vdbase.leaf <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng))
lm.vdbase.stlplusleaf <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m) + 
                             log10(traits.db$unit.leaf.leng))
lm.vdbase.stlintleaf <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m) *
                            log10(traits.db$unit.leaf.leng))
#
summary(lm.vdbase.stl)
anova(lm.vdbase.stl)
plot(lm.vdbase.stl)
confint(lm.vdbase.stl)
#
summary(lm.vdbase.leaf)
anova(lm.vdbase.leaf)
plot(lm.vdbase.leaf)
confint(lm.vdbase.leaf)
#
summary(lm.vdbase.stlplusleaf)
anova(lm.vdbase.stlplusleaf)
plot(lm.vdbase.stlplusleaf)
confint(lm.vdbase.stlplusleaf)
#
summary(lm.vdbase.stlintleaf)
anova(lm.vdbase.stlintleaf)
plot(lm.vdbase.stlintleaf)
confint(lm.vdbase.stlintleaf)
#
anova( lm.vdbase.leaf,lm.vdbase.stl,lm.vdbase.stlplusleaf,lm.vdbase.stlintleaf)
###
hier.part(traits.db$VD.base.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu")
rand.hp(traits.db$VD.base.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu",
        num.reps = 100)$Iprobs
?rand.hp
#Partial r2
partial.R2(lm.vdbase.leaf, lm.vdbase.stlintleaf)
partial.R2(lm.vdbase.stl, lm.vdbase.stlintleaf)
partial.R2(lm.vdbase.leaf,lm.vdbase.stlplusleaf)
partial.R2(lm.vdbase.stl,lm.vdbase.stlplusleaf)

metrics.base <- calc.relimp(lm.vdbase.stlplusleaf, type = c("lmg","first", "last","betasq", "pratt"),
                       rela = TRUE)
metrics.base
boot.vdbase <- boot.relimp(lm.vdbase.stlplusleaf, b = 1000, type = "lmg", bty = "perc",level = 0.95)
eval.vdbase <- booteval.relimp(boot.vdbase, typesel = c("lmg", "pmvd"), level = 0.9,
                              bty = "perc", norank = TRUE)
plot(metrics.base, names.abbrev = 3)
plot(booteval.relimp(boot.vdbase, typesel = c("lmg", "pmvd"), level = 0.9),
     names.abbrev = 2, bty = "perc")
eval.vdtip
eval.vdbase
####
pdf("Results/FigureRelimpvdtip.pdf", height = 8, width = 8) # Para guardar en PDF
plot(booteval.relimp(boot.vdtip, typesel ="lmg", level = 0.9),
     names.abbrev = 2, bty = "perc")
dev.off()
pdf("Results/FigureRelimpvdbase.pdf", height = 8, width = 8) # Para guardar en PDF
plot(booteval.relimp(boot.vdbase, typesel = "lmg", level = 0.9),
     bty = "perc")
dev.off()
#####Determine the best model ####
aic_withformula <- c()
aic_withformula <- c(aic_withformula ,AIC(lm.vdtip.leaf))
aic_withformula <- c(aic_withformula , AIC(lm.vdtip.stl))
aic_withformula <- c(aic_withformula , AIC(lm.vdtip.stlintleaf))
aic_withformula <- c(aic_withformula, AIC(lm.vdtip.stlplusleaf))
#bic
bic_withformula <- c()
bic_withformula <- c(bic_withformula ,BIC(lm.vdtip.leaf))
bic_withformula <- c(bic_withformula , BIC(lm.vdtip.stl))
bic_withformula <- c(bic_withformula , BIC(lm.vdtip.stlintleaf))
bic_withformula <- c(bic_withformula, BIC(lm.vdtip.stlplusleaf))

valoresmodels_vdtip <- cbind(aic_withformula, bic_withformula) 
valoresmodels_vdtip
####Vd base
#Model with interaction is the best model
aic_withformula <- c()
aic_withformula <- c(aic_withformula ,AIC(lm.vdbase.leaf))
aic_withformula <- c(aic_withformula , AIC(lm.vdbase.stl))
aic_withformula <- c(aic_withformula , AIC(lm.vdbase.stlintleaf))
aic_withformula <- c(aic_withformula, AIC(lm.vdbase.stlplusleaf))
#bic
bic_withformula <- c()
bic_withformula <- c(bic_withformula ,BIC(lm.vdbase.leaf))
bic_withformula <- c(bic_withformula , BIC(lm.vdbase.stl))
bic_withformula <- c(bic_withformula , BIC(lm.vdbase.stlintleaf))
bic_withformula <- c(bic_withformula, BIC(lm.vdbase.stlplusleaf))
#
valoresmodels_vdbase <- cbind(aic_withformula, bic_withformula)
valoresmodels_vdbase


# Making a plot to check species with unusual values
ggplot(traits.db, aes(x=leng.leaf, y=leng.lam.pet.mean, label=species))+
  geom_point(size=1)+stat_smooth(formula= y~x, method = "lm")+
  geom_text(position = "identity", angle=25, size=2.5, alpha=0.8)

dotchart(traits.db$leng.leaf)
dotchart(traits.db$leng.leaf.mean)
dotchart(traits.db$leng.lam.pet.mean)

scatterplot3d(log10(traits.db$stem.length.m),
       log10(traits.db$VD.tip.um),
       log10(traits.db$unit.leaf.leng+1),
       angle=30, pch=16)
my3ddplot <- scatterplot3d(log10(traits.db$stem.length.m),
                           log10(traits.db$unit.leaf.leng+1),
                           log10(traits.db$VD.tip.um),angle=30, pch=16, type="h")
lm_vdtip.leaf.log.stem.M <-lm(log10(traits.db$VD.tip.um) ~
                                log10(traits.db$unit.leaf.leng+1) 
                              + log10(traits.db$stem.length.m))
my3ddplot$plane3d(lm_vdtip.leaf.log.stem.M)
#Changing axes
my3ddplot.invv <- scatterplot3d(log10(traits.db$unit.leaf.leng+1),  
                                log10(traits.db$stem.length.m),
                                log10(traits.db$VD.tip.um),angle=30, pch=16, type="h")

lm_vdtip.leaf.log.stem.M.inv <-lm(log10(traits.db$VD.tip.um) ~
                                    log10(traits.db$stem.length.m) +
                                    log10(traits.db$unit.leaf.leng+1))
my3ddplot$plane3d(lm_vdtip.leaf.log.stem.M.inv)




#
plot(log10(traits.db$stem.length.m),log10(traits.db$VD.tip.um))
points(log10(traits.db$stem.length.m)[traits.db$leaf.type=="aphyllous"],
       log10(traits.db$VD.tip.um)[traits.db$leaf.type=="aphyllous"], col="blue", pch=19)
points(log10(traits.db$stem.length.m)[traits.db$leng.leaf.mean< 0.6],
       log10(traits.db$VD.tip.um)[traits.db$leng.leaf.mean <0.6], col="blue", pch=19)


plot(log10(traits.db$stem.length.m),log10(traits.db$VD.base.um))
points(log10(traits.db$stem.length.m)[traits.db$leaf.type=="aphyllous"],
       log10(traits.db$VD.base.um)[traits.db$leaf.type=="aphyllous"], col="blue", pch=19)
points(log10(traits.db$stem.length.m)[traits.db$leng.leaf.mean< 0.6],
       log10(traits.db$VD.base.um)[traits.db$leng.leaf.mean <0.6], col="blue", pch=19)
plot(log10(traits.db$stem.length.m),log10(traits.db$leng.leaf.mean))

##### Aphyllous species #####
traits.db <- traits.temp

afilas <- subset(traits.db, traits.db$leaf.type == "aphyllous")

lm.afilas.base<-lm(log10(afilas$VD.base.um)~ log10(afilas$stem.length.m))
summary(lm.afilas.base)

lm.afilas.punta <-lm(log10(afilas$VD.tip.um)~ log10(afilas$stem.length.m))
summary(lm.afilas.punta)

#Running models including the 
lm.vdtip.stl.withafilas <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m))
lm.vdtip.leaf.withafilas <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$unit.leaf.leng+1))
lm.vdtip.stlplusleaf.withafilas <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m)+
                                        log10(traits.db$unit.leaf.leng+1))
lm.vdtip.leafintleaf.withafilas <- lm(log10(traits.db$VD.tip.um) ~ log10(traits.db$stem.length.m)*
                                        log10(traits.db$unit.leaf.leng+1))

####Running models for vdbase
lm.vdbase.stl.withafilas <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m))
lm.vdbase.leaf.withafilas <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$unit.leaf.leng+1))
lm.vdbase.stlplusleaf.withafilas <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m)+
                                        log10(traits.db$unit.leaf.leng+1))
lm.vdbase.leafintleaf.withafilas <- lm(log10(traits.db$VD.base.um) ~ log10(traits.db$stem.length.m)*
                                        log10(traits.db$unit.leaf.leng+1))

######
summary(lm.vdtip.stl.withafilas)
summary(lm.vdtip.leafintleaf.withafilas)
summary(lm.vdtip.stlintleaf)
summary(lm.vdbase.leafintleaf.withafilas)
summary(lm.vdbase.stlintleaf)
