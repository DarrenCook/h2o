library(h2o)
h2o.init(nthreads = -1)

datasets <- "https://raw.githubusercontent.com/DarrenCook/h2o/bk/datasets/"
data <- h2o.importFile(paste0(datasets,"iris_wheader.csv"))
y <- "class"
x <- setdiff(names(data), y)
parts <- h2o.splitFrame(data, 0.8)
train <- parts[[1]]
test <- parts[[2]]

m <- h2o.deeplearning(x, y, train)
p <- h2o.predict(m, test)
