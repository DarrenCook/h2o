g <- h2o.grid("randomForest",
  search_criteria = list(
   strategy = "RandomDiscrete",
   stopping_metric = "mse",
   stopping_tolerance = 0.001,
   stopping_rounds = 10,
   max_runtime_secs = 120
   ),
  hyper_params = list(
    ntrees = c(50, 100, 150, 200, 250),
    mtries = c(2, 3, 4, 5),
    sample_rate = c(0.5, 0.632, 0.8, 0.95),
    col_sample_rate_per_tree = c(0.5, 0.9, 1.0)
    ),
  x = x, y = y, training_frame = train,
  nfolds = 5, max_depth = 40,
  stopping_metric = "deviance",
  stopping_tolerance = 0,
  stopping_rounds = 4,
  score_tree_interval = 3
  )
