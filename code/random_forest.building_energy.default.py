# Run load.building_energy.py first

m = h2o.estimators.H2ORandomForestEstimator(
  model_id="RF_defaults", nfolds=10
  )
m.train(x, y, train)

m

