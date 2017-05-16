library(h2o)
h2o.init(nthreads = -1)

datasets <- "https://raw.githubusercontent.com/DarrenCook/h2o/bk/datasets/"
data <- h2o.importFile(paste0(datasets,"iris_wheader.csv"))

data <- data[1:120,]  #Remove 60% of virginica
summary(data$class)  #50/50/20

parts <- h2o.splitFrame(data, 0.8, seed = 77)
train <- parts[[1]]
test <- parts[[2]]
summary(train$class)  #41/41/14
summary(test$class)  #9/9/6

x <- 1:4
y <- 5

m1 <- h2o.randomForest(x, y, train, model_id = "RF_defaults", seed = 1)
h2o.confusionMatrix(m1)

m2 <- h2o.randomForest(x, y, train, model_id = "RF_balanced", seed = 1,
  balance_classes = TRUE
  )
h2o.confusionMatrix(m2)

m3 <- h2o.randomForest(x, y, train, model_id ="RF_class_sampling", seed = 1,
  balance_classes = TRUE,
  class_sampling_factors = c(1, 1, 2.5)
  )
h2o.confusionMatrix(m3)

#TODO: I think this syntax is correct, but the results are always
# identical to m1, whatever values of the weights.

train$weights <- ifelse(train$class == "Iris-virginica", 2.5, 1)
m4 <- h2o.randomForest(x, y, train, model_id ="RF_weights", seed = 1,
  weights_column = "weights"
  )
h2o.confusionMatrix(m4)
