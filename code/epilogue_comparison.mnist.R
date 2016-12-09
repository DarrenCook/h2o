seed = 450

source("load.mnist.R")

###################
# Default models


# Notebook: 
#    user  system elapsed 
#   2.144   0.273 158.834 
# EC2-72:   1.328   0.024 116.902  (was only 20% utilization, but all cores, the whole time)   
system.time(
RFd <- h2o.randomForest(x, y, train, validation_frame = valid, model_id="RF_defaults", seed=seed)
)

# EC2-72:   0.836   0.020  61.250
# EC2-36:    0.920   0.032  64.193 
system.time(
GBMd <- h2o.gbm(x, y, train, validation_frame = valid,  model_id="GBM_defaults", seed=seed)
)

# EC2-72:   0.716   0.024  55.057
system.time(
GLMd <- h2o.glm(x, y, train, validation_frame = valid, model_id = "GLM_defaults", family="multinomial")
)

# EC2-72:  0.620   0.004  34.218 
system.time(
DLd <- h2o.deeplearning(x, y, train, validation_frame = valid, model_id="DL_defaults", seed=seed)
)

######################
# Evaluate default models

pRFd <- h2o.performance(RFd, test)
pGBMd <- h2o.performance(GBMd, test)
pGLMd <- h2o.performance(GLMd, test)
pDLd <- h2o.performance(DLd, test)

#############
# Now load enhanced data

h2o.removeAll()
rm(train, valid, test, x, y)
gc()

source("load.mnist_enhanced.R")

##############
# Default models on the enhanced data

# EC-72:   1.404   0.032 125.916
system.time(
RFe <- h2o.randomForest(x, y, train, validation_frame = valid, model_id="RF_enhanced", seed=seed)
)

# EC-72:   0.936   0.028  75.360 
# EC-36:  
system.time(
GBMe <- h2o.gbm(x, y, train, validation_frame = valid,  model_id="GBM_enhanced", seed=seed)
)

# EC-72:    1.044   0.012  86.923
system.time(
GLMe <- h2o.glm(x, y, train, validation_frame = valid, model_id = "GLM_enhanced", family="multinomial")
)

# EC-72:   0.756   0.012  41.555 
system.time(
DLe <- h2o.deeplearning(x, y, train, validation_frame = valid, model_id="DL_enhanced", seed=seed)
)

#########
# Now the tuned models

# Note different seed
# EC-72:   4.040   0.104 384.790
system.time(
RFt <- h2o.randomForest(x, y, train, validation_frame = valid, model_id = "RF_tuned", seed = 999,
  min_rows = 2,
  mtries = 56,
  col_sample_rate_per_tree = 0.9,
  sample_rate = 0.9,
  max_depth = 40,
  ntrees = 500,
  stopping_tolerance = 0.0001,
  stopping_rounds=3,
  score_tree_interval = 3
  )
)


# EC-72:   7.964   0.148 754.920
#   (Spent most of the time at 50%, all cores (5-10secs at a time). Bursts (4-5s) of a single core at 100%.)
# EC-72, 2nd run:   8.124   0.264 774.116 
# EC-36:   7.364   0.208 717.391
#   (Most of time at 100%, all cores (5-10secs). Bursts (3-4s) of a single core at 100%.)
system.time(
GBMt <- h2o.gbm(x, y, train, validation_frame = valid,  model_id="GBM_tuned", seed=seed,
  #max_depth = 5,  #Default
  #min_rows = 10,  #Default
  sample_rate = 0.95,
  col_sample_rate = 0.8,
  col_sample_rate_per_tree = 0.8,
  learn_rate = 0.01,
  stopping_tolerance = 0.001,
  stopping_rounds=3,
  score_tree_interval = 10,
  ntrees = 400
  )
)

#All attempts to tune GLM failed; default model performed best.

# EC-72:   9.248   0.172 934.719 
# 
# TODO: Ooops, the above timing (and results) were with the strict early-stopping results.
system.time(
DLt <- h2o.deeplearning(x, y, train, validation_frame = valid, model_id="DL_tuned", seed=seed,
  hidden = c(300,400,500,600),
  activation = "RectifierWithDropout",
  l1 = 0.00001,
  input_dropout_ratio = 0.2,
  hidden_dropout_ratios = c(0.1, 0.1, 0.1, 0.1),
  stopping_metric = "misclassification",
  stopping_tolerance = 0.001,   #Was 0.01,
  stopping_rounds = 3,
  epochs = 2000   #Was 500
  )
)


#######
# Now evaluate enhanced and tuned models

pRFe <- h2o.performance(RFe, test)
pRFt <- h2o.performance(RFt, test)
pGBMe <- h2o.performance(GBMe, test)
pGBMt <- h2o.performance(GBMt, test)
pGLMe <- h2o.performance(GLMe, test)
pDLe <- h2o.performance(DLe, test)
pDLt <- h2o.performance(DLt, test)


###
# Now to summarize we have 11 models, and I want to get the MSE and error rate for
# each, on both test and valid sets.
# 

models <- c(RFd, RFe, RFt, GBMd, GBMe, GBMt, GLMd, GLMe, DLd, DLe, DLt)
perfs <- c(pRFd, pRFe, pRFt, pGBMd, pGBMe, pGBMt, pGLMd, pGLMe, pDLd, pDLe, pDLt)

validRes <- sapply(models, function(m){
  c(10000*(1-m@model$validation_metrics@metrics$hit_ratio_table$hit_ratio[1]), m@model$validation_metrics@metrics$MSE)
  })
colnames(validRes) <- c("RFd", "RFe", "RFt", "GBMd", "GBMe", "GBMt", "GLMd", "GLMe", "DLd", "DLe", "DLt")
rownames(validRes) <- c("Errors", "MSE")

testRes <- sapply(perfs, function(p){
  c(10000* (1 - p@metrics$hit_ratio_table$hit_ratio[1]), h2o.mse(p) )
  })
colnames(testRes) <- c("RFd", "RFe", "RFt", "GBMd", "GBMe", "GBMt", "GLMd", "GLMe", "DLd", "DLe", "DLt")
rownames(testRes) <- c("Errors", "MSE")

# > validRes
#                 RFd          RFe          RFt         GBMd         GBMe         GBMt        GBMt2         GLMd        GLMe          DLd          DLe          DLt
# Errors 372.00000000 347.00000000 317.00000000 481.00000000 428.00000000 437.00000000 421.00000000 782.00000000 796.0000000 319.00000000 292.00000000 143.00000000
# MSE      0.06932763   0.06370017   0.05220436   0.05097615   0.04351574   0.04727526   0.04697083   0.07342319   0.0742621   0.02709419   0.02591386   0.01294906
# > testRes
#                 RFd          RFe          RFt         GBMd       GBMe         GBMt        GBMt2        GLMd         GLMe          DLd          DLe          DLt
# Errors 327.00000000 331.00000000 306.00000000 445.00000000 410.000000 407.00000000 411.00000000 745.0000000 748.00000000 296.00000000 273.00000000 146.00000000
# MSE      0.06509533   0.06118196   0.05009996   0.04847695   0.041492   0.04482206   0.04467112   0.0681974   0.06876485   0.02556084   0.02422737   0.01312986

# validRes <- structure(c(372, 0.0693276347452652, 347, 0.0637001668517963,
# 316.999999999999, 0.0522043598669394, 481, 0.0509761451793629,
# 427.999999999999, 0.0435157418026423, 437, 0.0472752560792088,
# 421, 0.0469708298205375, 782, 0.0734231937153982, 796, 0.0742620970442057,
# 319, 0.0270941885511264, 292, 0.0259138645936051, 143, 0.0129490578152091
# ), .Dim = c(2L, 12L), .Dimnames = list(c("Errors", "MSE"), c("RFd",
# "RFe", "RFt", "GBMd", "GBMe", "GBMt", "GBMt2", "GLMd", "GLMe",
# "DLd", "DLe", "DLt")))
# 
# testRes <- structure(c(326.999999999999, 0.0650953302243966, 331, 0.0611819625603505,
# 306, 0.0500999566818485, 445, 0.0484769535161, 410, 0.0414919991599427,
# 407, 0.0448220580444926, 411, 0.044671123455719, 745, 0.0681973999307372,
# 748, 0.0687648463625345, 296, 0.0255608373007682, 273, 0.0242273731358803,
# 145.999999999999, 0.0131298566762923), .Dim = c(2L, 12L), .Dimnames = list(
#     c("Errors", "MSE"), c("RFd", "RFe", "RFt", "GBMd", "GBMe",
#     "GBMt", "GBMt2", "GLMd", "GLMe", "DLd", "DLe", "DLt")))
# 

# > round(testRes,3)
#             RFd     RFe     RFt    GBMd    GBMe    GBMt   GBMt2    GLMd    GLMe     DLd     DLe     DLt
# Errors      327     331     306     445     410     407     411     745     748     296     273     146    
# MSE       0.065   0.061   0.050   0.048   0.041   0.045   0.045   0.068   0.069   0.026   0.024   0.013
# > round(validRes,3)
#             RFd     RFe     RFt    GBMd    GBMe    GBMt   GBMt2    GLMd    GLMe     DLd     DLe     DLt
# Errors      372     347     317     481     428     437     421     782     796     319     292     143    
# MSE       0.069   0.064   0.052   0.051   0.044   0.047   0.047   0.073   0.074   0.027   0.026   0.013


#Additional tries of GBM
#validRes <-
#structure(c(483, 0.0500655848737287, 431, 0.0435668096391128, 
#436, 0.0473071947379411), .Dim = 2:3, .Dimnames = list(c("Errors", 
#"MSE"), c("GBMd", "GBMe", "GBMt3")))
#
#testRes <-
# structure(c(449.000000000001, 0.0477868522801932, 404, 0.0415730720779444, 
# 407, 0.0447705939389188), .Dim = 2:3, .Dimnames = list(c("Errors", 
# "MSE"), c("GBMd", "GBMe", "GBMt3")))



timing <- c(117, 126, 385, 61, 75, 755, 774, 55, 87, 34, 42, 935)  #The 774 is GBMt2
RelTime <- timing/max(timing)
res <- rbind(testRes, RelTime=relTiming)
res <- res[,!(colnames(res) %in% "GBMt2")]  #Remove the extra GBMt

par(mfrow=c(1,2))
barplot(res["Errors",], ylab="Test Set Errors, per 10000", main="Model Performance (lower is better)", cex.lab=1.2, cex.axis=1.2, cex.main=1.2, cex.sub=1.2, cex.names=1)
barplot(res["RelTime",], ylab="Relative Time", main="Effort (lower is better)", cex.lab=1.2, cex.axis=1.2, cex.main=1.2, cex.sub=1.2, cex.names=1)

