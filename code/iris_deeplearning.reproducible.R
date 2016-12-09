library(h2o)
h2o.init(nthreads = -1)

datasets <- "https://raw.githubusercontent.com/DarrenCook/h2obook/master/datasets/"
data <- h2o.importFile(paste0(datasets,"iris_wheader.csv"))
y <- "class"
x <- setdiff(names(data), y)
parts <- h2o.splitFrame(data, 0.8, seed = 99)
train <- parts[[1]]
test <- parts[[2]]

system.time(  #0.248   0.005   1.343
m <- h2o.deeplearning(x, y, train, seed = 99, reproducible = TRUE)
)

system.time(  #0.031   0.002   0.069
p <- h2o.predict(m, test)
)


######

h2o.mse(m)  #0.01097

#TODO: what about mae()

h2o.confusionMatrix(m)

as.data.frame(p)
as.data.frame( h2o.cbind(p$predict, test$class) )
cbind( as.data.frame(p$predict), as.data.frame(test$class) )