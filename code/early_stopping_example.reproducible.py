import h2o
h2o.init()

datasets = "https://raw.githubusercontent.com/DarrenCook/h2obook/master/datasets/"
data = h2o.import_file(datasets + "iris_wheader.csv")
y = "class"
x = data.names
x.remove(y)
train, valid, test = data.split_frame([0.75,0.15], seed=99)

from h2o.estimators.random_forest import H2ORandomForestEstimator
m = H2ORandomForestEstimator(
  ntrees=100,
  stopping_metric="misclassification",
  stopping_rounds=3,
  stopping_tolerance=0.02,  #2%
  max_runtime_secs=60,
  model_id="RF:stop_test",
  seed=99
  )
m.train(x, y, train, validation_frame=valid)
