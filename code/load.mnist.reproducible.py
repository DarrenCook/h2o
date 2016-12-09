import os
import h2o
h2o.init(max_mem_size="3G")

#If next line fails, instead set path to location of datasets.
path = os.path.dirname(__file__)
train60K = h2o.import_file( os.path.join(
  path, "../datasets/mnist.train.csv.gz") )
test = h2o.import_file( os.path.join(
  path, "../datasets/mnist.test.csv.gz") )

x = range(0, 784)
y = 784

train60K[[y]] = train60K[[y]].asfactor()
test[[y]] = test[[y]].asfactor()

valid, train = train60K.split_frame([0.1675], seed=450)

######

train60K.dim  #60000, 785
train.dim  #50000 785   (if using 1/6th you get more)
valid.dim  #10000 785  (if using 1/6th you get less)

#####



