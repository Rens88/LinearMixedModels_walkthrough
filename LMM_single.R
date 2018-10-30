## 1) you need to install any packages that you have not yet installed.
## This may yield some version errors, but try to find the best matching version using what Google suggests.
## This code can be used to install the packages (only needs to be done once on your machine)
# install.packages("dplyr")

## 2) To make sure that you don't have any conflicting variables with previous sessions, clear the memory:
rm(list=ls()) #clear memory

## 3), you need to load the packages that you're going to use during this script.
library(lme4)
library(LMERConvenienceFunctions)
library(lmerTest)
library(nlme)
library(multcomp)
library(lsmeans)
library(dplyr)
library(MASS)
library(lattice)
library(Rcmdr)
library(ggplot2)
library(multcompView)
library(R.matlab)
library(bwplot)
library(lawstat)

#--------------------------------------------------
## 4) USER INPUT: Set your working directory with your data. Make sure that you use backslashses (/) instead of forward slashes (\)
setwd("C:/Users/rensm/Dropbox/Public/PostdocLeiden/97 - Rennes continued/Florian")

## To be sure you have the right folder, you can use this line to list the files in the directory:
list.files()

## 5) USER INPUT: Set the file you're reading
data0 <- read.csv("data_for_LMM.csv", header = TRUE)    #data is a "data frame"

# To check whether the data was properly read, you can print the dimensions and the columns
dim(data0)
names(data0)

## OPTIONAL: Use this if you want to exclude certain conditions (for example if you want to exclude Condition 1)
## Note that this overwrites 'data0'.
# data0 <-  data0[data0$ Condition !=1, ] ## UNCOMMENT this line if you want to use it
## To verify that you excluded the right trials, you could reprint the dimensions:
# dim(data0)

## 6) USER INPUT: Load your data in a dataframe. 
## Provide the headername of the dependent variable (headerName_Y) that you want to examine in your model.
## Provide the headername of the independent variable (headerName_Condition) that you want to examine.
## Provide the headername of the column that contains the participant identities (headerName_Participant).
data1 <- data.frame(Y = data0$headerName_Y,
                    Cond = data0$headerName_Condition,
                    Pp = data0$headerName_Participant
                    )

## 7) Set independent variables (as factors)
data1$Pp <- as.factor(data1$Pp)
data1$Cond  <- as.factor(data1$Cond);

#------------------------------------------------
## To get an idea of the shape of your data, you can plot the histograms of any variables of interest (Descriptive stats)
bwplot(Y~Cond, data=data1)
bwplot(Y~Cond:Pp, data=data1)
bwplot(Y~Pp, data=data1)

#----------------------------------------------------
# MODEL SELECTION PART 1: Random effects

## 8) Here, you create the coveriance matrices with and without random effects for specific factors.
cf1 <- corCompSymm(form = ~1|Pp)
vf1 <- varIdent(form = ~1|Cond)

## 9) Here, you create the models with:
## Default Coveriance matrix
fit1_lme0  <- lme(Y ~ Cond, random=~1|Pp ,data = na.omit(data1), method="REML" )
## Symmetrical Coveriance Matrix 
fit1_lme1 <- lme(Y ~ Cond, random=~1|Pp, correlation = cf1 ,data = na.omit(data1), method="REML" )
## Matrix weighted for the effects of Cond
fit1_lme2  <- lme(Y ~Cond, random=~1|Pp , weights = vf1   ,  data = na.omit(data1), method="REML" )
## NB: For more complex models you can extend the time it is allowed to keep computing it by adding ", control = lmeControl(maxIter = 100 , msMaxIter =100, niterEM = 50 )" to the model

## 10) Run this ANOVA for each of the different models.
anova(fit1_lme0 , fit1_lme1, fit1_lme2)

## ****************
## ACTION REQUIRED: Of these models, selected the one with the lowest AIC. If two models lie within 2 AIC of each other, choose the simplest (the one with the fewest df). Change it in all models below.
## Use the selected model (everything after the <- where it was created, e.g.: "lme(Y ~Cond, random=~1|Pp , weights = vf1   ,  data = na.omit(data1), method="REML" )"

#--------------------------------------------------
#MODEL SELECTION PART 2: FIXED EFFECTS (only relevant for LMM_multiple) 
# Here, the fixed effects model is created to make sure no unnecessary factors (and their interactions) are included.

## 11) After change the model (see ACTION REQUIRED above), create the fixed effects model
fit1_lme0_ML  <- lme(Y ~  Cond, random=~1|Pp, weights = vf1, control = lmeControl(maxIter = 100 , msMaxIter =100, niterEM = 50 ) ,data = na.omit(data1), method="ML" )

## 12) Using stepAIC, the model will be reduced to its simplest version (NB: For 1 factor, this should always be the same)
stepAIC(fit1_lme0_ML)

## ****************
## ACTION REQUIRED: Take the last suggested model by stepAIC and copy it in all models below.

# 13) Create the FINAL PREFERRED MODEL:
fit1_lme_Y   <- lme(Y ~  Cond , random=~1|Pp, weights = vf1, control = lmeControl(maxIter = 100 , msMaxIter =100, niterEM = 50 ),data = na.omit(data1), method="REML" )#
# 14) Create final model without weighted covariance matrix (to check its effect)
fit1_lme_Ya  <- lme(Y ~Cond, random=~1|Pp, data = na.omit(data1), method="REML" ) #WITHOUT VARIANCE WEIGHTING OUT OF INTEREST

#--------------------------
#MODEL VALIDATION
## To get an idea of what your model looks like
plot(fit1_lme_Y )
## Compute the residuals of your model WITH corrected matrices
res_fit1_lme_Y <- resid(fit1_lme_Y, type="normalized")
hist(res_fit1_lme_Y)
with(na.omit(data1),plot(Cond, res_fit1_lme_Y))
## Compute the residuals of your model WITHOUT corrected matrices
res_fit1_lme_Ya <- resid(fit1_lme_Ya, type="normalized")
with(na.omit(data1),plot(Cond, res_fit1_lme_Ya))

#########################
## 15) Test whether the corrected coveriance matrices improved the skewness
## Using 'Bartletts' (slightly less reliable than Levene)
dat <- na.omit(data1)
bartlett.test(  as.numeric(res_fit1_lme_Y) , dat$Cond  )
## Using 'Levene' (more reliable, particularly with large datasets)
levene.test(  as.numeric(res_fit1_lme_Y) , dat$Cond  )

## ****************
## ACTION REQUIRED:
## Preferably, both Bartlett's and Levene's are not significant. 
## If only Bartlett's is significant, you may want to choose a different model under 10). 
## If both are signficant (usually, Bartletts is significant when Levene is), you must try to find a different model under 10.
## If there is no suitable model, you may 1) proceed with caution (justified if significant factor is not your main factor) or 2) revert to non-parametric stats, or 3) figure out how to throw some outliers based on the residuals with the ancient code from below.

########## ANCIENT CODE outlier detection #########
## IF nothing works, you may try this (see ACTION REQUIRED comment directly above).
# #CHECK CONDITION TAKING OUT OUTLIERS
# resid.data <- cbind(na.omit(data1),res_fit1_lme_Y )
# names(resid.data)
# # I don't remember what this '4' refers to. A percentage?
# resid.data[resid.data$res_fit1_lme_Y>4,]
# densityplot(~res_fit1_lme_Y|Cond, data = resid.data[resid.data$res_fit1_lme_Y<4,]) #TAKE OUT OUTLIERS
# densityplot(~res_fit1_lme_Y|Cond, data = resid.data) #DONT TAKE OUT OUTLIERS
# #data without outliers:
# data_no_resa = resid.data[resid.data$res_fit1_lme_Y<1,]#TAKE OUT OOUTLIERS
# data_no_res = resid.data#DONT TAKE OUT OUTLIERS
# ## Run the tests again on data without outliers:
# # Variance adjusted: levene = 0.7581
# levene.test(  as.numeric(data_no_resa$res_fit1_lme_Y) , data_no_resa$Cond   ) #variance adjusted (i.e. final model)                 
# # Variance adjusted: levene = 0.9765
# levene.test(  as.numeric(data_no_res$res_fit1_lme_Y) , data_no_res$Cond   ) #variance adjusted (i.e. final model)                 
# library(doBy)
# summaryBy(res_fit1_lme_Y~Cond,data = data_no_resa, FUN = c(mean,sd) )
# summaryBy(res_fit1_lme_Y~Cond,data = data_no_res, FUN = c(mean,sd) )
########## / ANCIENT CODE outlier detection #########

#----------------------------------------------
#----------------------------------------------
#----------------------------------------------
#----------------------------------------------
#----------------------------------------------
#----------------------------------------------

#MODEL EVALUATION & export
## 16) Nearly there... Now you can run the ANOVA which should give you your F statistics which you can report in your paper.
# Note that putting () around your code results in its output being printed
(testingVal <- anova( fit1_lme_Y))

## 17) Create the post-hoc contrasts. First, unload lmerTest (because they both have a version of lsmeans).
detach("package:lmerTest", unload=TRUE) #to stop the lmer version of lsmeans working

## 18) Provide the lsmeans (corrected with your covariance matrix), these can be used as your descriptives.
(lsm <- lsmeans(fit1_lme_Y, ~Cond, data = na.omit(data1) ))

## 19) Group the different occurences of your factor of interst.
(temp1 <- cld(lsm))

## 20) Obtain the specific pairwise posthoc contrasts of each possible comparison (corrected with Tukey HSD). These statistics can be used in your paper.
(temp <- contrast(lsm, method ="pairwise"))