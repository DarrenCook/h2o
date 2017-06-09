library(h2o)
h2o.init(nthreads = -1)

datasets <- "https://raw.githubusercontent.com/DarrenCook/h2o/bk/datasets/"
data <- h2o.importFile(paste0(datasets,"iris_wheader.csv"))
attr(data,"id") #iris_wheader.hex_sid_a61b_1

data <- data[, 2:5] #Drop column 1. Keep columns 2 to 5 inclusive.
attr(data,"id")  #RTMP_sid_a61b_2

data <- h2o.assign(data, "iris")
attr(data,"id")  #iris

h2o.ls()  #iris_wheader.hex_sid_a61b_1 and iris, no RTMP_sid_a61b_2
h2o.rm("iris_wheader.hex_sid_a61b_1")
h2o.ls()
