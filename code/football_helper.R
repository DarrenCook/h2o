compareModels <- function(models, test, labels){
if(missing(labels)){
  if(length(models) == 4)
    labels = c("HomeWin", "HW-NoOdds", "ScoreDraw", "SD-NoOdds")
  else labels = lapply(models,function(m) m@model_id)
  }
  
res <- sapply(models, function (m){
  #The 4 in next few lines ought not to be hard-coded...
  th <- mean(c(m@model$training_metrics@metrics$max_criteria_and_metric_scores[4,'threshold'],
    m@model$validation_metrics@metrics$max_criteria_and_metric_scores[4,'threshold']))
  pf <- h2o.performance(m, test)
  ix <- apply(outer(th,pf@metrics$thresholds_and_metric_scores$threshold,"<="),1,sum)
  if(ix<1)ix=1

  matrix(c(
    h2o.auc(m, TRUE, TRUE), pf@metrics$AUC,
    m@model$training_metrics@metrics$max_criteria_and_metric_scores[4, 'value'],
    m@model$validation_metrics@metrics$max_criteria_and_metric_scores[4, 'value'],
    pf@metrics$thresholds_and_metric_scores[ix, 'accuracy'],
    h2o.r2(m, TRUE, TRUE), pf@metrics$r2,
    h2o.mse(m, TRUE, TRUE), pf@metrics$MSE
    ), ncol=4)
  }, simplify ="array")

dimnames(res)=list(
  c("train","valid","test"),
  c("AUC","Accuracy","r2", "MSE"),
  labels
  )

res
}


# This is a variation to just get the valid numbers out of models. So a 2D matrix returned
# Also just AUC and accuracy
# To get training numbers, change all "validation_metrics" into "training_metrics"
# 
# Note: note used in the end, but I've left it here, as a simpler version of compareModels()
compareModelsV <- function(models, labels){
if(missing(labels)){
  labels = lapply(models,function(m) m@model_id)
  }
  
res <- sapply(models, function (m){
  #The 4 in next few lines ought not to be hard-coded...
  c(
    h2o.auc(m, valid=TRUE),
    m@model$validation_metrics@metrics$max_criteria_and_metric_scores[4, 'value']
    )
  })

dimnames(res)=list(
  c("AUC","Accuracy"),
  labels
  )

res
}


# This takes already-calculated performance objects, but is otherwise
# just like compareModels().
# The entries in models and perfs must be in the same order, therefore.
compareModelsP <- function(models, perfs, labels){
if(missing(labels)){
  labels = lapply(models,function(m) m@model_id)
  }

for(ix in 1:length(models))attr(models[[ix]],"perf") <- perfs[[ix]]

res <- sapply(models, function (m){
  #The 4 in next few lines ought not to be hard-coded...
  th <- mean(c(m@model$training_metrics@metrics$max_criteria_and_metric_scores[4,'threshold'],
    m@model$validation_metrics@metrics$max_criteria_and_metric_scores[4,'threshold']))
  pf <- attr(m,"perf")
  ix <- apply(outer(th,pf@metrics$thresholds_and_metric_scores$threshold,"<="),1,sum)
  if(ix<1)ix=1

  matrix(c(
    h2o.auc(m, TRUE, TRUE), pf@metrics$AUC,
    m@model$training_metrics@metrics$max_criteria_and_metric_scores[4, 'value'],
    m@model$validation_metrics@metrics$max_criteria_and_metric_scores[4, 'value'],
    pf@metrics$thresholds_and_metric_scores[ix, 'accuracy'],
    h2o.r2(m, TRUE, TRUE), pf@metrics$r2,
    h2o.mse(m, TRUE, TRUE), pf@metrics$MSE
    ), ncol=4)
  }, simplify ="array")

dimnames(res)=list(
  c("train","valid","test"),
  c("AUC","Accuracy","r2", "MSE"),
  labels
  )

res
}



#####################################

# This made the chart at the end of the AUC sidebar.
# m1 is 
# Saved as 1600x800
# ---> Now as 1600x1000 (also I've used GLMd1 from the epilogue_comparison.football.R
#   though I suspect that is exactly the same model?)
#   
# @param m1 "GLM_defaults_HomeWin_Odds"
# @param pf h2o.performance(m1,test)
drawThresholdChart = function(m1, pf, ylim=c(0.33,0.67)){
xlim = c(0.0, 1.0) #For everything
#xlim = c(0.05, 0.95)  #Don't need the whole range
xlim = c(-0.01, 1.01) #For when using xaxs="i" !!!
  
par(mfrow=c(3,1))

par(mar = c(2.5,5,1.0,0.5))
plot(
  m1@model$training_metrics@metrics$thresholds_and_metric_scores[,c('threshold','accuracy')],
  ylim=ylim, xlim=xlim, type="l", xlab="",
  xaxs="i", cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5
  )
abline(v=m1@model$training_metrics@metrics$max_criteria_and_metric_scores[4,'threshold'],lwd=2)
text(0.99,0.63,"Training Data", cex=1.7, pos=2) 

plot(
  m1@model$validation_metrics@metrics$thresholds_and_metric_scores[,c('threshold','accuracy')],
  ylim=ylim, xlim=xlim, type="l", xlab="",
  xaxs="i", cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5
  )
abline(v=m1@model$validation_metrics@metrics$max_criteria_and_metric_scores[4,'threshold'],lwd=2)
text(0.99,0.63,"Validation Data", cex=1.7, pos=2)

plot(
  pf@metrics$thresholds_and_metric_scores[,c('threshold','accuracy')],
  ylim=ylim, xlim=xlim, type="l",
  xaxs="i", cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5
  )
abline(v=pf@metrics$max_criteria_and_metric_scores[4,'threshold'], lwd=2)
abline(
  v=mean(c(
    m1@model$training_metrics@metrics$max_criteria_and_metric_scores[4,'threshold'],
    m1@model$validation_metrics@metrics$max_criteria_and_metric_scores[4,'threshold']
    )),
  lty="dotted", lwd=3 )
text(0.99,0.63,"Test Data", cex=1.7, pos=2) 
}

