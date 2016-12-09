library(h2o)
h2o.init(nthreads = -1)

data <- h2o.importFile("../datasets/ENB2012_data.csv")

factorsList <- c("X6", "X8")
data[,factorsList] <- as.factor(data[,factorsList])

splits <- h2o.splitFrame(data, 0.8)
train <- splits[[1]]
test <- splits[[2]]

x <- c("X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8")
y <- "Y2"  #Or "Y1"
