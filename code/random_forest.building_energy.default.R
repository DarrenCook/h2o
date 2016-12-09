source("load.building_energy.R")

m <- h2o.randomForest(x, y, train, nfolds = 10, model_id = "RF_defaults")
summary(m)

h2o.performance(m, test)
