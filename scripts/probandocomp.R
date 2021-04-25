library(rgl)
library(scatterplot3d)
library(ggstance)
library(vioplot)
library(car)
library(hier.part)
library(asbio)

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
anova(lm.vdtip.stlplusleaf,lm.vdtip.stlintleaf, lm.vdtip.leaf,lm.vdtip.stl)
####
hier.part(traits.db$VD.tip.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu")
rand.hp(traits.db$VD.tip.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu",
        num.reps = 100)$Iprobs
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
###
hier.part(traits.db$VD.base.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu")
rand.hp(traits.db$VD.base.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu",
        num.reps = 100)$Iprobs
#Partial r2
partial.R2(lm.vdbase.leaf, lm.vdbase.stlintleaf)
partial.R2(lm.vdbase.stl, lm.vdbase.stlintleaf)
partial.R2(lm.vdbase.leaf,lm.vdbase.stlplusleaf)
partial.R2(lm.vdbase.stl,lm.vdbase.stlplusleaf)

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
