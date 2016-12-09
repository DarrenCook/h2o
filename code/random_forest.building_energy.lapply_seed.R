#seed = 999
#source("load.building_energy.R")
#source("makeplot.building_energy_results.R")

seeds <- c(101, 109, 373, 571, 619, 999)

defaultModels <- lapply(seeds, function(seed){
  h2o.randomForest(x, y, train, nfolds = 10, seed = seed)
  })

tunedModels <- lapply(seeds, function(seed){
  h2o.randomForest(x, y, train, nfolds = 10, seed = seed,
    max_depth = 40, ntrees = 200, sample_rate = 0.7,
    mtries = 4, col_sample_rate_per_tree = 0.9,
    stopping_metric = "deviance",
    stopping_tolerance = 0,
    stopping_rounds = 5,
    score_tree_interval = 3)
  })


def <- sapply(defaultModels, h2o.rmse, xval = TRUE)
tuned <- sapply(tunedModels, h2o.rmse, xval = TRUE)

defT <- sapply(defaultModels, h2o.rmse)
tunedT <- sapply(tunedModels, h2o.rmse)

#The box plot on RMSE, cross-validation data
boxplot(c(def,tuned) ~ c(rep(1,6),rep(2,6)) )

#Compare with RMSE on training data
boxplot(c(def,tuned,defT,tunedT) ~ c(rep(1,6),rep(2,6),rep(3,6),rep(4,6)) )

# Here is same example with labels (also showing how to force factor order!)
f <- factor(c(rep("Default Model",6),rep("Tuned Model",6)), c("Default Model","Tuned Model"))
boxplot(c(def,tuned) ~ f, ylim=c(1.75, 1.85), ylab="RMSE")

#Exported as 900x500


#Repeat but with MAE instead of RMSE
def2 <- sapply(defaultModels, h2o.mae, xval = TRUE)
tuned2 <- sapply(tunedModels, h2o.mae, xval = TRUE)

defT2 <- sapply(defaultModels, h2o.mae)
tunedT2 <- sapply(tunedModels, h2o.mae)

boxplot(c(def2,tuned2,defT2,tunedT2) ~ c(rep(5,6),rep(6,6),rep(7,6),rep(8,6)) )

#And both RMSE and MAE
boxplot(c(def,tuned,defT,tunedT,def2,tuned2,defT2,tunedT2) ~ c(rep(1,6),rep(2,6),rep(3,6),rep(4,6),rep(5,6),rep(6,6),rep(7,6),rep(8,6)) )

# Make the results plot
mBest <- tunedModels[[1]]  #Choose first one, arbitrarily
p = h2o.predict(mBest, test, seed = seed)
p

plotBuildingEnergy(p, test, forPrint = T, "../chapters/images/", "randomforest.tuned")

