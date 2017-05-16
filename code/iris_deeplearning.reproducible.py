import h2o
h2o.init()

datasets = "https://raw.githubusercontent.com/DarrenCook/h2o/bk/datasets/"
data = h2o.import_file(datasets + "iris_wheader.csv")
y = "class"
x = data.names
x.remove(y)
train, test = data.split_frame([0.8], seed=99)

m = h2o.estimators.deeplearning.H2ODeepLearningEstimator(seed=99, reproducible=True)
m.train(x, y, train)
p = m.predict(test)

######
# Stats shown in book

"%.5f" % m.mse()

m.confusion_matrix(train)

p.as_data_frame()

p["predict"].cbind(test["class"]).as_data_frame()

