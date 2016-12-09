# Take a list of binomial models, and compare them with a number of metrics
# 
# It assumes a validation set was used (rather than cross-validation)
# 
# It computes `th`, which is the average threshold, for max-accuracy,
# of the train and valid data sets. It uses this to choose a score
# from the results on the test set.
# 
# It returns a 3D-array
compareModels <- function(models, test, labels = NULL){
#Use model IDs as default labels, if not given  
if(is.null(labels)){
  labels <- lapply(models, function(m) m@model_id)
  }
  
res <- sapply(models, function (m){
  mcmsT <- m@model$training_metrics@metrics$max_criteria_and_metric_scores
  mcmsV <- m@model$validation_metrics@metrics$max_criteria_and_metric_scores
  maix <- which(mcmsT$metric=="max accuracy")  #4 (at the time of writing)
  th <- mean(mcmsT[maix, 'threshold'],  mcmsV[maix, 'threshold'] )

  pf <- h2o.performance(m, test)
  tms <- pf@metrics$thresholds_and_metric_scores
  ix <- apply(outer(th, tms$threshold, "<="), 1, sum)
  if(ix < 1)ix <- 1  #Use first entry if less than all of them
  
  matrix(c(
    h2o.auc(m, TRUE, TRUE), pf@metrics$AUC,
    mcmsT[maix, 'value'], mcmsV[maix, 'value'], tms[ix, 'accuracy'],
    h2o.logloss(m, TRUE, TRUE), pf@metrics$logloss,
    h2o.mse(m, TRUE, TRUE), pf@metrics$MSE
    ), ncol = 4)
  }, simplify = "array")

dimnames(res) <- list(
  c("train","valid","test"),
  c("AUC","Accuracy","logloss", "MSE"),
  labels
  )

res
}