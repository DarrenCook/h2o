# Run load.building_energy.py first

m = h2o.estimators.H2OGradientBoostingEstimator(
  model_id="GBM_defaults", nfolds=10, seed=999
  )
m.train(x, y, train)

m

