library(h2o)
h2o.init(nthreads = -1)

data <- h2o.importFolder("../datasets/england/2013-2014/")
betsH <- data[,c( ((1:8)*3)+21, 49, 50)]
betsD <- data[,c( ((1:8)*3)+22, 51, 52)]
betsA <- data[,c( ((1:8)*3)+23, 53, 54)]
abets <- data[,c(56:59, 61:65)]
stats <- data[,c(5:10, 12:23)]
stats[,c("FTR","HTR")] <- as.numeric(stats[,c("FTR","HTR")])
