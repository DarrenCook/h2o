library(h2o)
h2o.init(nthreads=-1, max_mem_size="3G")

train = h2o.importFile("../datasets/mnist.enhanced_train.csv.gz")
valid = h2o.importFile("../datasets/mnist.enhanced_valid.csv.gz")
test = h2o.importFile("../datasets/mnist.enhanced_test.csv.gz")

x = 1:897
y = 898

train[,y] = as.factor(train[,y])
valid[,y] = as.factor(valid[,y])
test[,y] = as.factor(test[,y])

train=h2o.assign(train,"train")
valid=h2o.assign(valid,"valid")
test=h2o.assign(test,"test")
