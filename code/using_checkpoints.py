y = "income"
x = ["age", "gender"]

m1 = h2o.H2ODeepLearningEstimator(
  model_id="DL:50x50-5", hidden=[50,50],
  epochs=5
  )
m1.train(x, y, train)

m2 = h2o.H2ODeepLearningEstimator(
  model_id="DL:50x50-15", hidden=[50,50],
  epochs=15, checkpoint="DL:50x50-5"
  )
m2.train(x, y, train)
