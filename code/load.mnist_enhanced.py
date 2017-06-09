import os, pandas, h2o
h2o.init()

#If next line fails, set path to location of datasets.
path = os.path.dirname(__file__)
train = h2o.import_file( os.path.join(
  path, "../datasets/mnist.enhanced_train.csv.gz") )
valid = h2o.import_file( os.path.join(
  path, "../datasets/mnist.enhanced_valid.csv.gz") )
test = h2o.import_file( os.path.join(
  path, "../datasets/mnist.enhanced_test.csv.gz") )

x = range(0,896)
y = 897

train[[y]] = train[[y]].asfactor()
valid[[y]] = valid[[y]].asfactor()
test[[y]] = test[[y]].asfactor()
