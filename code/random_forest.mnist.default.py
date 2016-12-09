# Run load.mnist.py first

m = h2o.estimators.H2ORandomForestEstimator(model_id="RF_defaults")
m.train(x, y, train, validation_frame=valid)
