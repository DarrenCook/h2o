seed = 10

source("load.football2.R")  #NB. load version with no missing data

#####

g = h2o.grid("glm", grid_id="GLM_1",
   hyper_params = list(
     alpha = c(0, 0.05, 0.15, 0.5, 0.99)   #This is the ratio of L1 and L2 (0.99 is recommended instead of 1.0)
   ),
   x = x, y = "HomeWin", training_frame = train,
   validation_frame = valid,
   lambda_search = TRUE,  #Easier than guessing a lambda
   
   solver = "IRLSM",
   family = "binomial",
   link = "logit",  #Only choice
   
   balance_classes = TRUE,
   
   stopping_metric = "misclassification",
   stopping_tolerance = 0,
   stopping_rounds = 4,
   max_iterations = 100  #Double the default, rely on early stopping
   )


###

binomialLinks = c("logit", "log")  #Fails - only logit is actually allowed
system.time(
allGrids <- lapply(theLinks, function(link){
  grid_id = paste("GLM",link,sep="_")
  cat("GRID:",grid_id,"\n")
  h2o.grid("glm", grid_id=grid_id,
    hyper_params = list(
      alpha = c(0, 0.5, 0.99)   #This is the ratio of L1 and L2 (0.99 is recommended instead of 1.0)
      ),
    x = x, y = "HomeWin", training_frame = train,
    validation_frame = valid,
    lambda_search = TRUE,  #Easier than guessing a lambda
    
    solver = "IRLSM",
    family = "binomial",
    link = link,
    
    balance_classes = TRUE,
  
    stopping_metric = "misclassification",
    stopping_tolerance = 0,
    stopping_rounds = 4,
    max_iterations = 100  #Double the default, rely on early stopping
    )
  })
)  

##########
# The best model (for Home Win, all columns)
# 
# TODO: it seems the early stopping and balance_classes is not supported in 3.8.2.2
#   So I need to upgrade, or try this on EC2.
system.time(
mb1 <- h2o.glm(x, "HomeWin", train,
  model_id = "GLM_HomeWin_Odds_Best",
  validation_frame = valid, family="binomial",
  
  alpha=0.0, balance_classes=TRUE, lambda_search=TRUE,
  stopping_metric = "misclassification",
  stopping_tolerance = 0,
  stopping_rounds = 4,
  max_iterations = 100
  )
)

# And evaluate it
res <- compareModels(c(mb1), test)
round(res[,"AUC",],3)
round(res[,"Accuracy",],3)
