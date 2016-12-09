#source("load.building_energy.R")

g <- h2o.grid("randomForest",
  hyper_params = list(
    ntrees = c(50, 100, 120),
    max_depth = c(40, 60),
    min_rows = c(1, 2)
    ),
  x = x, y = y, training_frame = train, nfolds = 10
  )

g_r2 = h2o.getGrid(g@grid_id, sort_by = "r2", decreasing = TRUE)

as.data.frame( h2o.getGrid(g@grid_id, sort_by = "r2", decreasing = TRUE)@summary_table )
