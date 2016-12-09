source("load.mnist.R")

m <- h2o.randomForest(x, y, train,
  model_id = "RF_defaults", validation_frame = valid)
