import os
import h2o
h2o.init()

#If next line fails, instead set path to location of datasets.
path = os.path.dirname(__file__)
fname = os.path.join(path, "../datasets/ENB2012_data.csv")
data = h2o.import_file(fname)

factorsList = ["X6","X8"]
data[factorsList] = data[factorsList].asfactor()

train, test = data.split_frame([0.8])

x = ["X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8"]
y = "Y2"  #Or "Y1"
