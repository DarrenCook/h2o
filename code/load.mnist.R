library(h2o)
h2o.init(nthreads = -1, max_mem_size = "3G")

train60K <- h2o.importFile("../datasets/mnist.train.csv.gz")
test <- h2o.importFile("../datasets/mnist.test.csv.gz")

x <- 1:784
y <- 785

train60K[,y] <- as.factor(train60K[,y])
test[,y] <- as.factor(test[,y])

parts <- h2o.splitFrame(train60K, 1.0/6.0)
valid <- parts[[1]]
train <- parts[[2]]
rm(parts)
