import h2o.grid

g = h2o.grid.H2OGridSearch(
  h2o.estimators.H2ORandomForestEstimator(
    nfolds=10
    ),
  hyper_params = {
    "ntrees": [50, 100, 120],
    "max_depth": [40, 60],
    "min_rows": [1, 2]
    }
  )
g.train(x, y, train)
