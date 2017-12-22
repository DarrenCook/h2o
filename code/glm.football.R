seed = 10

# Note that the version 2, with NAs fixed, is used.
source("load.football2.R")  #seed not used
source("football_helper.R")  #For compareModels()

m1 <- h2o.glm(x, "HomeWin", train,
  model_id = "GLM_defaults_HomeWin_Odds",
  validation_frame = valid, family="binomial")
m2 <- h2o.glm(xNoOdds, "HomeWin", train,
  model_id = "GLM_defaults_HomeWin_NoOdds",
  validation_frame = valid, family="binomial")
m3 <- h2o.glm(x, "ScoreDraw", train,
  model_id = "GLM_defaults_ScoreDraw_Odds",
  validation_frame = valid, family="binomial")
m4 <- h2o.glm(xNoOdds, "ScoreDraw", train,
  model_id = "GLM_defaults_ScoreDraw_NoOdds",
  validation_frame = valid, family="binomial")

# summary(m1)
# pf1 <- h2o.performance(m1, test)
# 
# summary(m2)
# pf2 <- h2o.performance(m2, test)
# 
# summary(m3)
# pf3 <- h2o.performance(m3, test)
# 
# summary(m4)
# pf4 <- h2o.performance(m4, test)
# 
#p = h2o.predict(m, test, seed=seed)
#p

#####################

res <- compareModels(c(m1,m2,m3,m4), test)
res

round(res[,"AUC",],3)
round(res[,"Accuracy",],3)
round(res[,"r2",],3)
round(res[,"MSE",],3)

#####################

mAvH <- h2o.glm("BbAvH", "HomeWin", train,
  model_id = "GLM_defaults_HomeWin_BbAvH",
  validation_frame = valid, family="binomial")


mAvD <- h2o.glm("BbAvD", "ScoreDraw", train,
  model_id = "GLM_defaults_ScoreDraw_BbAvD",
  validation_frame = valid, family="binomial")


res <- compareModels(c(mAvH, mAvD), test, c("HomeWin","ScoreDraw"))
round(res[,"AUC",],3)
round(res[,"Accuracy",],3)

