# Run load.mnist.reproducible.py first

m = h2o.estimators.H2ORandomForestEstimator(model_id="RF_defaults", seed=450)
%time m.train(x, y, train, validation_frame=valid)
