library(h2o)
h2o.init(nthreads = -1)

datasets <- "https://raw.githubusercontent.com/DarrenCook/h2o/bk/datasets/"
data <- h2o.importFile(paste0(datasets,"iris_wheader.csv"))

data <- data[1:120,]  #Remove 60% of virginica
h2o.summary(data$class)  #50/50/20

parts <- h2o.splitFrame(data, 0.8)
train <- parts[[1]]
test <- parts[[2]]



splits = h2o.splitFrame(d,0.8,c("train","test"), seed=77)
train = splits[[1]]
test = splits[[2]]
summary(train$Species)  #41/41/14
summary(test$Species)  #9/9/6

m1 = h2o.randomForest(1:4, 5, train, model_id ="RF_defaults", seed=1)
h2o.confusionMatrix(m1)

m2 = h2o.randomForest(1:4, 5, train, model_id ="RF_balanced", seed=1,
  balance_classes = TRUE)
h2o.confusionMatrix(m2)

m3 = h2o.randomForest(1:4, 5, train, model_id ="RF_balanced", seed=1,
  balance_classes = TRUE,
  class_sampling_factors = c(1, 1, 2.5)
  )
h2o.confusionMatrix(m3)


