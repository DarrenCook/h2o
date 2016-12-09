seed = 999

source("load.building_energy.R")
#source("makeplot.building_energy_results.R")


#On notebook:
#  user  system elapsed 
#  0.207   0.011   4.487
#EC2-36:   0.196   0.000   1.271 
system.time(
RFd <- h2o.randomForest(x, y, train, nfolds=10, model_id="RF_defaults", seed=seed)
)

#EC2-36:     0.244   0.000   7.324 
system.time(
RFt <- h2o.randomForest(x, y, train, nfolds = 10, model_id = "RF_tuned", seed = seed,
    max_depth = 40, ntrees = 200, sample_rate = 0.9,
    mtries = 4, col_sample_rate_per_tree = 0.9,
    score_tree_interval = 10)
)

#Notebook:   0.275   0.006   2.406    0.188   0.011   4.435
#EC2-36:     0.216   0.000   1.281 
system.time(
GBMd <- h2o.gbm(x, y, train, nfolds=10, model_id="GBM_defaults", seed=seed)
)

#Notebook:   0.411   0.040  19.947     0.377   0.033  17.662
#EC2-36:     0.352   0.000  12.430 
system.time(
GBMt <- h2o.gbm(x, y, train, nfolds=10, model_id="GBM_tuned", seed=373,
  #max_depth = 5,  #Default
  min_rows = 1,
  sample_rate = 0.9,
  col_sample_rate = 0.9,
  learn_rate = 0.01,
  ntrees = 1000,
  stopping_tolerance = 0,
  stopping_rounds = 4,
  score_tree_interval = 5
  )
)

#Notebook:   0.202   0.005   1.348 
#EC2-36:    0.216   0.000   1.317 
system.time(
GLMd <- h2o.glm(x, y, train, nfolds=10, model_id="GLM_defaults")  #NB. no seed param
)

#Notebook:   0.201   0.008   3.351 
#EC2-36:     0.244   0.000   1.313 
system.time(
GLMt <- h2o.glm(x, y, train, nfolds = 10, model_id="GLM_tuned",
  tweedie_variance_power = 1.55,
  tweedie_link_power = 0,
  alpha = 0.33,
  lambda_search = TRUE,
      
  solver = "IRLSM",
  family = "tweedie",
  link = "family_default",
  max_iterations = 100
  )
)

#Notebook:   0.403   0.016  10.776     0.304   0.017  10.778
#EC2-36:     0.320   0.000   3.495 
system.time(
DLd <- h2o.deeplearning(x, y, train, nfolds=10, model_id="DL_defaults", seed=seed)
)

#EC2-36:     1.268   0.024  93.871 
# (2.418   0.226 242.316 on notebook)   (1.661   0.145 176.991 )
system.time(
DLt <- h2o.deeplearning(x, y, train, nfolds=10, model_id="DL_tuned", seed=seed,
  activation = "Tanh",
  l2 = 0.00001,  #1e-05
  hidden = c(162,162),
  stopping_metric = "MSE",
  stopping_tolerance = 0.0005,
  stopping_rounds = 5,
  epochs = 2000,
  train_samples_per_iteration = 0,
  score_interval = 3
  )
)


######################

# pRFd <- h2o.performance(RFd, test)
# pRFt <- h2o.performance(RFt, test)
# pGBMd <- h2o.performance(GBMd, test)
# pGBMt <- h2o.performance(GBMt, test)
# pGLMd <- h2o.performance(GLMd, test)
# pGLMt <- h2o.performance(GLMt, test)
# pDLd <- h2o.performance(DLd, test)
# pDLt <- h2o.performance(DLt, test)

res <- sapply(c(RFd, RFt, GBMd, GBMt, GLMd, GLMt, DLd, DLt), function(m){
  p <- h2o.performance(m, test)
  c(h2o.mse(p), as.numeric(m@model$cross_validation_metrics_summary['mse',c('mean','sd')]))
  })

rownames(res) <- c("Test-MSE", "CV-MSE-mean", "CV-MSE-sd")
colnames(res) <- c("RFd", "RFt", "GBMd", "GBMt", "GLMd", "GLMt", "DLd", "DLt")

# 
# res <- structure(c(3.5961525421518, 3.256682, 0.6987585, 3.80185693313163, 
# 3.0514548, 0.69676375, 2.31759363576667, 2.4163144, 0.68766004, 
# 1.63960493553245, 1.1536821, 0.22753969, 9.01325658673804, 10.701883, 
# 1.4936284, 8.90418108496232, 10.155925, 1.9851075, 7.0957873058201, 
# 20.68103, 4.2689986, 0.424768506669719, 4.6607914, 0.63026345
# ), .Dim = c(3L, 8L), .Dimnames = list(c("Test-MSE", "CV-MSE-mean", 
# "CV-MSE-sd"), c("RFd", "RFt", "GBMd", "GBMt", "GLMd", "GLMt", 
# "DLd", "DLt")))
# 

# 
# > DLt
# Model Details:
# ==============
# 
# H2ORegressionModel: deeplearning
# Model ID:  DL_tuned 
# Status of Neuron Layers: predicting Y2, regression, gaussian distribution, Quadratic loss, 29,647 weights/biases, 354.9 KB, 189,375 training samples, mini-batch size 1
#   layer units   type dropout       l1       l2 mean_rate rate_RMS momentum mean_weight weight_RMS mean_bias bias_RMS
# 1     1    18  Input  0.00 %                                                                                        
# 2     2   162   Tanh  0.00 % 0.000000 0.000010  0.361461 0.249316 0.000000    0.002526   0.153483 -0.005445 0.131988
# 3     3   162   Tanh  0.00 % 0.000000 0.000010  0.873032 0.231913 0.000000    0.000295   0.056239  0.004347 0.114767
# 4     4     1 Linear         0.000000 0.000010  0.596012 0.387334 0.000000   -0.002663   0.066678 -0.006027 0.000000
# 
# 
# H2ORegressionMetrics: deeplearning
# ** Reported on training data. **
# Description: Metrics reported on full training frame
# 
# MSE:  0.1275759
# R2 :  0.9986057
# Mean Residual Deviance :  0.1275759
# 
# 
# 
# H2ORegressionMetrics: deeplearning
# ** Reported on cross-validation data. **
# Description: 10-fold cross-validation on training data (Metrics computed for combined holdout predictions)
# 
# MSE:  4.724274
# R2 :  0.9483658
# Mean Residual Deviance :  4.724274
# 
# 
# Cross-Validation Metrics Summary: 
#                         mean          sd cv_1_valid cv_2_valid cv_3_valid cv_4_valid cv_5_valid cv_6_valid cv_7_valid cv_8_valid cv_9_valid cv_10_valid
# mse                4.6607914  0.63026345   3.485608  5.8822336   4.902749  4.1718125    5.18557   5.232349  4.0865335   3.327724  6.0479417   4.2853947
# r2                0.94799805 0.005378522 0.95888406 0.93633235  0.9511391  0.9477789  0.9344027   0.946785 0.95708865  0.9513745  0.9439928  0.95220226
# residual_deviance  4.6607914  0.63026345   3.485608  5.8822336   4.902749  4.1718125    5.18557   5.232349  4.0865335   3.327724  6.0479417   4.2853947
# 

res <- rbind(res,TrainingTime=c(1.3, 7.3, 1.3, 12.4, 1.3, 1.3, 3.5, 93.9 ))
res <- rbind(res,RelTime=res["TrainingTime",]/max(res["TrainingTime",]))

#Saved for book as 1600 x 600
par(mfrow=c(1,2))
barplot(res["Test-MSE",], ylab="MSE", ylim=c(0,10), main="Model Performance (lower is better)", cex.lab=1.2, cex.axis=1.2, cex.main=1.2, cex.sub=1.2, cex.names=1.2)
barplot(res["RelTime",], ylab="Relative Time", main="Effort (lower is better)", cex.lab=1.2, cex.axis=1.2, cex.main=1.2, cex.sub=1.2, cex.names=1.2)
#barplot(res["Test-MSE",]*res["RelTime",], ylab="MSE * RelTime")

