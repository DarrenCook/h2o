seed = 450

source("load.mnist_enhanced.R")  #Use enhanced data

# The base model
system.time(
m <- h2o.glm(x, y, train, validation_frame = valid,  model_id="GLM_defaults", family="multinomial", seed = seed)
)

#12:41:44 to 12:53:05. I.e. just under 12 minutes
#--> With latest 3.10.0.8, and explicitly setting seed it now uses all 8 cores and finishes in 7.010   1.070 307.419 
#  But same unexciting results: valid=778, 0.0640 on train, test=746
# On 72 cores:  0.684   0.024  49.026   (though most of the time they were 30-50% used)
#   (Exact same results, i.e. same seed works on different machine)

#####
# This version just uses the new columns

system.time(
m113 <- h2o.glm(1:113, y, train, validation_frame = valid,  model_id="GLM_first113", family="multinomial", seed = seed)
)

#With 3.10.0.8,  0.505   0.038  32.964 
#   valid=869, train = 0.0789, test = 792

##########################
# Try a grid
# TODO: try all 4 solvers?
# TODO: consider with and without balance_classes

solvers=c("IRLSM", "L_BFGS", "COORDINATE_DESCENT_NAIVE", "COORDINATE_DESCENT")
system.time(
allGrids <- lapply(solvers, function(solver){
  grid_id = paste("GLM",solver,sep="_")
  cat("GRID:",grid_id,"\n")
  h2o.grid("glm", grid_id=grid_id,
    hyper_params = list(
      alpha = c(0, 0.5, 0.99)   #This is the ratio of L1 and L2 (0.99 is recommended instead of 1.0)
      ),
    x = x, y = y, training_frame = train,
    validation_frame = valid,
    lambda_search = TRUE,  #Easier than guessing a lambda
    
    solver = solver,
    family = "multinomial",

    max_iterations = 100  #Twice the default, but rely on early stopping
    )
  })
)


# grids can be list of h2o.grid objects, or grid id strings
mergeGrids <- function(grids, metric){
if(metric=="mse")decreasing = FALSE
else decreasing = TRUE

d <- do.call(rbind, lapply(grids, function(g){
  if(is.character(g))grid_id = g
  else grid_id = g@grid_id
  dd <- as.data.frame(
    h2o.getGrid(grid_id, sort_by=metric, decreasing = decreasing)
    @summary_table
    )
  dd$model_ids <- NULL
  dd = as.data.frame(lapply(dd,as.numeric))
  dd$grid_id = grid_id
  dd
  }) )

orderBy = d[,metric]
if(decreasing)orderBy = -orderBy
d[order(orderBy),]
}

#############

#I got errors for solvers 3 and 4, so this fails
# mergeGrids(allGrids, "err")

g = mergeGrids(c(allGrids[[1]],allGrids[[2]]), "err")

#The number shown is the error rate of the validation set (matches confusion matrix)
#   alpha    err    grid_id
# 4  0.99 0.8899 GLM_L_BFGS
# 5  0.50 0.8899 GLM_L_BFGS
# 1  0.50 0.4202  GLM_IRLSM
# 2  0.99 0.4093  GLM_IRLSM
# 6  0.00 0.3244 GLM_L_BFGS
# 3  0.00 0.2990  GLM_IRLSM


##########

#A quick follow up, of other low alpha values, but also giving
# it more iterations.

# This took 544s on the 36-core machine. (which is 3-4x quicker than my notebook)
system.time(
g_LA <- h2o.grid("glm", grid_id="GLM_IRLSM_low_alpha",
    hyper_params = list(
      alpha = c(0, 0.01, 0.05, 0.10)
      ),
    x = x, y = y, training_frame = train,
    validation_frame = valid,
    lambda_search = TRUE,  #Easier than guessing a lambda
    
    solver = "IRLSM",
    family = "multinomial",

    max_iterations = 500  #10 times default
    )
)



# TODO: Try again with limited columns? 
# 
# TODO: try on test with the best model





#############################


models <- lapply(do.call(paste0,expand.grid(
  c("GLM_COORDINATE_DESCENT","GLM_IRLSM","GLM_L_BFGS"),
  c("_model_0","_model_1","_model_2")
  )), h2o.getModel)



res <- do.call(rbind,lapply(models,function(m){
data.frame(list(
solver=m@parameters$solver,
alpha=m@allparameters$alpha,
iterations=tail(m@model$scoring_history$iteration,n=1),
MSE=m@model$validation_metrics@metrics$MSE,
logloss=m@model$validation_metrics@metrics$logloss,
error=m@model$validation_metrics@metrics$cm$table$Error[11]
))
}
))


# res <- structure(list(solver = structure(c(1L, 2L, 3L, 1L, 2L, 3L, 1L,
# 2L, 3L), .Label = c("COORDINATE_DESCENT", "IRLSM", "L_BFGS"), class = "factor"),
#     alpha = c(0, 0, 0, 0.5, 0.5, 0.5, 0.99, 0.99, 0.99), iterations = c(100L,
#     100L, 100L, 100L, 100L, 100L, 100L, 100L, 100L), MSE = c(0.077213128626244,
#     0.0748228661752412, 0.0798953419743011, 0.101115610439748,
#     0.101215100034195, 0.809610851771245, 0.100252908503127,
#     0.0978007660797981, 0.809610851771245), logloss = c(0.296694217055394,
#     0.29182629158293, 0.310283429760385, 0.351787218026682, 0.35206410648775,
#     2.30182431785631, 0.349794776680899, 0.343367472088229, 2.30182431785631
#     ), error = c(0.0802, 0.0791, 0.0839, 0.0941, 0.0942, 0.8899,
#     0.0953, 0.0931, 0.8899)), .Names = c("solver", "alpha", "iterations",
# "MSE", "logloss", "error"), row.names = c(NA, 9L), class = "data.frame")
# 
#               solver alpha iterations        MSE   logloss  error
# 1 COORDINATE_DESCENT  0.00        100 0.07721313 0.2966942 0.0802
# 2              IRLSM  0.00        100 0.07482287 0.2918263 0.0791
# 3             L_BFGS  0.00        100 0.07989534 0.3102834 0.0839
# 4 COORDINATE_DESCENT  0.50        100 0.10111561 0.3517872 0.0941
# 5              IRLSM  0.50        100 0.10121510 0.3520641 0.0942
# 6             L_BFGS  0.50        100 0.80961085 2.3018243 0.8899
# 7 COORDINATE_DESCENT  0.99        100 0.10025291 0.3497948 0.0953
# 8              IRLSM  0.99        100 0.09780077 0.3433675 0.0931
# 9             L_BFGS  0.99        100 0.80961085 2.3018243 0.8899


