library(rgl)
library(scatterplot3d)
library(ggstance)
library(vioplot)
library(car)
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
######Modelos y comparación de modelos #####
lm.vdtip.stl <- lm(log10(traits.db$VD.tip.um)~ log10(traits.db$stem.length.m))
summary(lm.vdtip.stl)
anova(lm.vdtip.stl)
confint(lm.vdtip.stl)
lm.vdtip.leaf <-  lm(log10(traits.db$VD.tip.um)~ log10(traits.db$unit.leaf.leng + 1))
summary(lm.vdtip.leaf)
confint(lm.vdtip.leaf)

lm.vdtip.stl.leaf <-  lm(log10(traits.db$VD.tip.um)~ log10(traits.db$stem.length.m)*
                           log10(traits.db$unit.leaf.leng + 1))
summary(lm.vdtip.stl.leaf)
confint(lm.vdtip.stl.leaf)

lm.vdtip.stlplusleaf <-  lm(log10(traits.db$VD.tip.um)~ log10(traits.db$stem.length.m) +
                           log10(traits.db$unit.leaf.leng + 1))
summary(lm.vdtip.stlplusleaf)
confint(lm.vdtip.stl)
##4 models. Now compared the ss
#SS Extra ⫽Full SS Regression ⫺Reduced SS Regression
anova(lm.vdtip.stl,lm.vdtip.stl.leaf)
###
anova(lm.vdtip.stl)
anova(lm.vdtip.stl.leaf)
0.0335/
anova(lm.vdtip.stlplusleaf,lm.vdtip.stl.leaf, lm.vdtip.leaf,lm.vdtip.stl)
####
library(hier.part)
hier.part(traits.db$VD.tip.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu")
rand.hp(traits.db$VD.tip.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu",
        num.reps = 100)$Iprobs
#(SSEreduced - SSEfull) / SSEreduced
anova(lm.vdtip.leaf)
anova(lm.vdtip.stl)
anova(lm.vdtip.stlplusleaf)
6.4691+3.1557
(7.8079-9.6248)/7.8079 #stl
sqrt(18.7569/16.9399) #leaf
library(asbio)
partial.R2(lm.vdtip.leaf, lm.vdtip.stl.leaf)
partial.R2(lm.vdtip.stl, lm.vdtip.stl.leaf)

###
lm.vdbase.stl <- lm(log10(traits.db$VD.base.um)~ log10(traits.db$stem.length.m))
summary(lm.vdbase.stl)
anova(lm.vdbase.stl)
confint(lm.vdbase.stl)
lm.vdbase.leaf <-  lm(log10(traits.db$VD.base.um)~ log10(traits.db$unit.leaf.leng + 1))
summary(lm.vdbase.leaf)
confint(lm.vdbase.leaf)

lm.vdbase.stl.leaf <-  lm(log10(traits.db$VD.base.um)~ log10(traits.db$stem.length.m)*
                           log10(traits.db$unit.leaf.leng + 1))
summary(lm.vdbase.stl.leaf)
confint(lm.vdbase.stl.leaf)

lm.vdbase.stlplusleaf <-  lm(log10(traits.db$VD.base.um)~ log10(traits.db$stem.length.m) +
                              log10(traits.db$unit.leaf.leng + 1))
summary(lm.vdbase.stlplusleaf)
confint(lm.vdbase.stlplusleaf)

partial.R2(lm.vdbase.leaf, lm.vdbase.stl.leaf) #Partial correlations of determination
partial.R2(lm.vdbase.stl, lm.vdbase.stl.leaf) #

###
hier.part(traits.db$VD.base.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu")
rand.hp(traits.db$VD.base.um, traits.db[,c("stem.length.m","unit.leaf.leng")], gof = "Rsqu",
        num.reps = 100)$Iprobs

#####
modelos<-list()
modelos[[1]]<-c("Vdtip ~ Leaf",lm.vdtip.leaf)
modelos[[2]]<-c("Vdtip ~ SL",lm.vdtip.stl)
modelos[[3]]<-c("Vdtip ~ Leaf + SL + (SL*Leaf)",lm.vdtip.stl.leaf)
modelos[[4]]<-c("Vdtip ~ Leaf + SL",lm.vdtip.stlplusleaf)
#Cargar función de aic
f_AIC <- function(modelo, datos){
  n <- nrow(datos)
  mo <- modelo
  df <- mo$df.residual
  k <- n-df
  rss <- sum(mo$residuals**2)
  aic<- n*log(rss/n)+2*k+(2*k*(k+1))/(n-k-1)
  return(aic)
}
#Hacer un vector con los valores del AKA
vector_aka<-vector()
for (i in modelos){
  vector_aka<-c(vector_aka,print(f_AIC(i,traits.db)))
}
#
vector_vacío<-vector()
for (i in 1:4){
  vector_vacío<-c(vector_vacío, paste0("m",i))
}
vector_vacío<-c(vector_vacío[1:4])
#hACER UNA DATA FRAME
valores_aka<-as.data.frame(cbind(vector_vacío,vector_aka))
colnames(valores_aka)<-c("modelo","valor_akaike")
sort(valores_aka$valor_akaike, decreasing = TRUE)
#Model with interaction is the best model
aic_withformula <- c()
aic_withformula <- c(aic_withformula ,AIC(lm.vdtip.leaf))
aic_withformula <- c(aic_withformula , AIC(lm.vdtip.stl))
aic_withformula <- c(aic_withformula , AIC(lm.vdtip.stl.leaf))
aic_withformula <- c(aic_withformula, AIC(lm.vdtip.stlplusleaf))
#bic
bic_withformula <- c()
bic_withformula <- c(bic_withformula ,BIC(lm.vdtip.leaf))
bic_withformula <- c(bic_withformula , BIC(lm.vdtip.stl))
bic_withformula <- c(bic_withformula , BIC(lm.vdtip.stl.leaf))
bic_withformula <- c(bic_withformula, BIC(lm.vdtip.stlplusleaf))

valores_aka <- cbind(valores_aka, aic_withformula, bic_withformula) 
####Vd base
#Model with interaction is the best model
aic_withformula <- c()
aic_withformula <- c(aic_withformula ,AIC(lm.vdbase.leaf))
aic_withformula <- c(aic_withformula , AIC(lm.vdbase.stl))
aic_withformula <- c(aic_withformula , AIC(lm.vdbase.stl.leaf))
aic_withformula <- c(aic_withformula, AIC(lm.vdbase.stlplusleaf))
#bic
bic_withformula <- c()
bic_withformula <- c(bic_withformula ,BIC(lm.vdbase.leaf))
bic_withformula <- c(bic_withformula , BIC(lm.vdbase.stl))
bic_withformula <- c(bic_withformula , BIC(lm.vdbase.stl.leaf))
bic_withformula <- c(bic_withformula, BIC(lm.vdbase.stlplusleaf))
#
cbind(aic_withformula, bic_withformula)
