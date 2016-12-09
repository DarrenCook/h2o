seed = 10

source("football_helper.R")

source("load.football.R")  #seed not used

y = "HomeWin"

###################
# RandomForest and GBM models

# Default models
# Notebook:   0.362   0.028  13.016
# EC2-72:   0.400   0.008  19.722 
system.time(
RFd1 <- h2o.randomForest(x, y, train, validation_frame = valid, model_id="RF_defaults_Odds", seed=seed)
)

# EC2-72:   0.332   0.000  14.496
system.time(
RFd2 <- h2o.randomForest(xNoOdds, y, train, validation_frame = valid, model_id="RF_defaults_NoOdds", seed=seed)
)

#Notebook:   0.326   0.014   6.523 
# EC2-72:   0.324   0.000  10.478
system.time(
GBMd1 <- h2o.gbm(x, y, train, validation_frame = valid,  model_id="GBM_defaults_Odds", seed=seed)
)

# EC2-72:   0.308   0.004   7.445
system.time(
GBMd2 <- h2o.gbm(xNoOdds, y, train, validation_frame = valid,  model_id="GBM_defaults_NoOdds", seed=seed)
)

# Tuned models

# EC2-72:   0.900   0.012  78.224 
system.time(
RFt1 <- h2o.randomForest(x, y, train, validation_frame = valid, model_id="RF_tuned_Odds", seed=seed,
  sample_rate = 0.35,
  min_rows = 60,
  mtries = 5,
  ntrees=500,
  stopping_metric = "AUC",
  stopping_tolerance = 0,
  stopping_rounds = 4
  )
)

#EC2-72:   0.684   0.012  54.928 
system.time(
RFt2 <- h2o.randomForest(xNoOdds, y, train, validation_frame = valid, model_id="RF_tuned_NoOdds", seed=seed,
  sample_rate = 0.35,
  min_rows = 60,
  mtries = 5,
  ntrees=500,
  stopping_metric = "AUC",
  stopping_tolerance = 0,
  stopping_rounds = 4
  )
)

#   0.436   0.020  26.963
system.time(
GBMt1 <- h2o.gbm(x, y, train, validation_frame = valid,  model_id="GBM_tuned_Odds", seed=seed,
  max_depth = 12,
  min_rows = 40,
  sample_rate = 0.9,
  col_sample_rate = 0.95,
  col_sample_rate_per_tree = 0.9,
  learn_rate = 0.01,
  balance_classes = TRUE,
  ntrees = 500,
  stopping_metric = "misclassification",
  stopping_tolerance = 0,
  stopping_rounds = 4,
  score_tree_interval = 10
  )
)

#   0.504   0.016  33.721
system.time(
GBMt2 <- h2o.gbm(xNoOdds, y, train, validation_frame = valid,  model_id="GBM_tuned_NoOdds", seed=seed,
  max_depth = 12,
  min_rows = 40,
  sample_rate = 0.9,
  col_sample_rate = 0.95,
  col_sample_rate_per_tree = 0.9,
  learn_rate = 0.01,
  balance_classes = TRUE,
  ntrees = 500,
  stopping_metric = "misclassification",
  stopping_tolerance = 0,
  stopping_rounds = 4,
  score_tree_interval = 10
  )
)


# Evaluate
pRFd1 <- h2o.performance(RFd1, test)
pRFd2 <- h2o.performance(RFd2, test)
pRFt1 <- h2o.performance(RFt1, test)
pRFt2 <- h2o.performance(RFt2, test)

pGBMd1 <- h2o.performance(GBMd1, test)
pGBMd2 <- h2o.performance(GBMd2, test)
pGBMt1 <- h2o.performance(GBMt1, test)
pGBMt2 <- h2o.performance(GBMt2, test)


##########################
# Switch to data with missing values removed/filled in

h2o.removeAll()
rm(train, valid, test, x, y)
gc()

source("load.football2.R")  #seed not used

y = "HomeWin"


#Special model
# EC-72:   0.240   0.004   1.382 
system.time(
mAvH <- h2o.glm("BbAvH", "HomeWin", train,
  model_id = "GLM_benchmark",
  validation_frame = valid, family="binomial")
)


# Default models
# EC-72:   0.244   0.000   1.347
system.time(
GLMd1 <- h2o.glm(x, y, train, validation_frame = valid, model_id = "GLM_defaults_Odds", family="binomial")
)

# EC-72:   0.232   0.000   1.342 
system.time(
GLMd2 <- h2o.glm(xNoOdds, y, train, validation_frame = valid, model_id = "GLM_defaults_NoOdds", family="binomial")
)

# EC-72:   0.388   0.004   6.638 
system.time(
DLd1 <- h2o.deeplearning(x, "HomeWin", train, validation_frame = valid, model_id = "DL_defaults_Odds")
)

# EC-72:   0.352   0.000   5.525 
system.time(
DLd2 <- h2o.deeplearning(xNoOdds, "HomeWin", train, validation_frame = valid, model_id = "DL_defaults_NoOdds")
)


# Tuned Models
# No tuned GLM models (identical results to defaults) 


# EC-72:    0.728   0.016  46.709 
system.time(
DLt1 <- h2o.deeplearning(x, "HomeWin", train, validation_frame = valid, model_id = "DL_tuned_Odds",
  replicate_training_data = T,
  balance_classes = T,
  shuffle_training_data = T,

  hidden = c(200,200,200),
  
  activation = "RectifierWithDropout",
  hidden_dropout_ratios = c(0.5, 0.3, 0.3),
  input_dropout_ratio = 0.3,
  l1 = 0.0005,
  l2 = 0.0005,

  stopping_metric = "AUC",
  stopping_tolerance = 0.001,
  stopping_rounds = 4,
  epochs = 2000
  )
)

# EC-72:   0.848   0.008  54.301 
system.time(
DLt2 <- h2o.deeplearning(xNoOdds, "HomeWin", train, validation_frame = valid, model_id = "DL_tuned_NoOdds",
  replicate_training_data = T,
  balance_classes = T,
  shuffle_training_data = T,

  hidden = c(200,200,200),
  
  activation = "RectifierWithDropout",
  hidden_dropout_ratios = c(0.5, 0.3, 0.3),
  input_dropout_ratio = 0.3,
  l1 = 0.0005,
  l2 = 0.0005,

  stopping_metric = "AUC",
  stopping_tolerance = 0.001,
  stopping_rounds = 4,
  epochs = 2000
  )
)


# Evaluate models

pAvH <- h2o.performance(mAvH, test)

pGLMd1 <- h2o.performance(GLMd1, test)
pGLMd2 <- h2o.performance(GLMd2, test)

pDLd1 <- h2o.performance(DLd1, test)
pDLd2 <- h2o.performance(DLd2, test)

pDLt1 <- h2o.performance(DLt1, test)
pDLt2 <- h2o.performance(DLt2, test)


###############
# We now have quite a few models to summarize
# We want the accuracy, and AUC

models <- c(RFd1, RFd2, RFt1, RFt2,  GBMd1, GBMd2, GBMt1, GBMt2, mAvH, GLMd1, GLMd2, DLd1, DLd2, DLt1, DLt2)
perfs <- c(pRFd1, pRFd2, pRFt1, pRFt2,  pGBMd1, pGBMd2, pGBMt1, pGBMt2, pAvH, pGLMd1, pGLMd2, pDLd1, pDLd2, pDLt1, pDLt2)

res <- compareModelsP(models, perfs, c("RFd1", "RFd2", "RFt1", "RFt2",  "GBMd1", "GBMd2", "GBMt1", "GBMt2", "mAvH", "GLMd1", "GLMd2", "DLd1", "DLd2", "DLt1", "DLt2"))




# 
# > 
# > res
# , , RFd1
# 
#             AUC  Accuracy          r2       MSE
# train 0.5578128 0.5643180 -0.01384299 0.2509737
# valid 0.6354173 0.6316306  0.05777022 0.2297385
# test  0.6005557 0.5962672  0.02778322 0.2377066
# 
# , , RFd2
# 
#             AUC  Accuracy          r2       MSE
# train 0.5556452 0.5597484 -0.01108269 0.2502904
# valid 0.5993115 0.6021611  0.02820250 0.2369479
# test  0.5825936 0.5810413  0.01287400 0.2413519
# 
# , , RFt1
# 
#             AUC  Accuracy         r2       MSE
# train 0.6120833 0.5906299 0.03960990 0.2377416
# valid 0.6776242 0.6488212 0.09175050 0.2214533
# test  0.6458442 0.6335953 0.06890693 0.2276518
# 
# , , RFt2
# 
#             AUC  Accuracy         r2       MSE
# train 0.5876959 0.5768475 0.02551999 0.2412296
# valid 0.6269733 0.6134578 0.04481133 0.2328982
# test  0.6157773 0.6011788 0.03609271 0.2356749
# 
# , , GBMd1
# 
#             AUC  Accuracy         r2       MSE
# train 0.6519293 0.6141657 0.07101419 0.2299676
# valid 0.6665935 0.6439096 0.08294183 0.2236011
# test  0.6426835 0.6262279 0.06405014 0.2288393
# 
# , , GBMd2
# 
#             AUC  Accuracy         r2       MSE
# train 0.6326524 0.6010957 0.05496190 0.2339413
# valid 0.6198413 0.6065815 0.04428431 0.2330267
# test  0.6128253 0.6016699 0.03366552 0.2362683
# 
# , , GBMt1
# 
#             AUC  Accuracy         r2       MSE
# train 0.7414469 0.6677253 0.08073457 0.2298163
# valid 0.6630861 0.6493124 0.05929099 0.2293677
# test  0.6359234 0.6222986 0.04976335 0.2323324
# 
# , , GBMt2
# 
#             AUC  Accuracy         r2       MSE
# train 0.7853624 0.7129694 0.10166434 0.2245839
# valid 0.6202460 0.6075639 0.03967306 0.2341511
# test  0.6068210 0.6036346 0.03070171 0.2369930
# 
# , , mAvH
# 
#             AUC  Accuracy         r2       MSE
# train 0.6176452 0.5885220 0.03882664 0.2374444
# valid 0.6750671 0.6498035 0.07733332 0.2249686
# test  0.6499808 0.6335953 0.06159927 0.2294386
# 
# , , GLMd1
# 
#             AUC  Accuracy         r2       MSE
# train 0.6356988 0.6070349 0.05860101 0.2325594
# valid 0.6781693 0.6498035 0.09092422 0.2216548
# test  0.6448906 0.6203340 0.06539578 0.2285103
# 
# , , GLMd2
# 
#             AUC  Accuracy         r2       MSE
# train 0.5949702 0.5824014 0.02887147 0.2399037
# valid 0.6246235 0.6154224 0.04557439 0.2327122
# test  0.6114952 0.6051081 0.03496564 0.2359505
# 
# , , DLd1
# 
#             AUC  Accuracy         r2       MSE
# train 0.6609866 0.6273267 0.08070463 0.2273795
# valid 0.6556251 0.6488212 0.07113494 0.2264799
# test  0.6118983 0.6055992 0.01839864 0.2400011
# 
# , , DLd2
# 
#             AUC  Accuracy         r2       MSE
# train 0.5898321 0.5814468 0.02496896 0.2411652
# valid 0.6250811 0.6100196 0.04207110 0.2335664
# test  0.6128489 0.6085462 0.03329176 0.2363597
# 
# , , DLt1
# 
#             AUC  Accuracy         r2       MSE
# train 0.6347195 0.5960258 0.04648043 0.2383783
# valid 0.6754401 0.6517682 0.08322374 0.2235324
# test  0.6502941 0.6016699 0.05411774 0.2312678
# 
# , , DLt2
# 
#             AUC  Accuracy         r2       MSE
# train 0.5953406 0.5653621 0.00651011 0.2483708
# valid 0.6284990 0.6198428 0.04645408 0.2324977
# test  0.6116955 0.5943026 0.03556268 0.2358045
# 
# > 
# 	


# res <- structure(c(0.557812813551739, 0.635417285035282, 0.600555685465451, 
# 0.564318003144654, 0.631630648330059, 0.596267190569745, -0.0138429943936884, 
# 0.0577702240520386, 0.0277832180291357, 0.250973738316028, 0.229738539314256, 
# 0.237706564142454, 0.555645203069955, 0.599311483649344, 0.582593586924026, 
# 0.559748427672956, 0.602161100196464, 0.581041257367387, -0.0110826936834711, 
# 0.0282025016087143, 0.0128740031408446, 0.25029043430155, 0.236947869287027, 
# 0.241351860449696, 0.612083297053008, 0.677624158523989, 0.64584424823117, 
# 0.590629913522013, 0.648821218074656, 0.633595284872299, 0.0396099009802688, 
# 0.0917505009768055, 0.0689069331201745, 0.237741637241206, 0.22145332122259, 
# 0.227651834374009, 0.587695886450851, 0.626973337924102, 0.615777342990736, 
# 0.57684748427673, 0.613457760314342, 0.601178781925344, 0.025519992649445, 
# 0.0448113333482222, 0.0360927075934764, 0.241229551036411, 0.232898232095597, 
# 0.235674897696506, 0.651929259470179, 0.666593451822654, 0.64268349114919, 
# 0.614165683962264, 0.643909626719057, 0.6262278978389, 0.0710141924966166, 
# 0.0829418305534588, 0.0640501421655564, 0.229967600743832, 0.223601089344569, 
# 0.228839317569105, 0.632652443540401, 0.619841321666449, 0.612825263955529, 
# 0.601095715408805, 0.606581532416503, 0.601669941060904, 0.0549618973752213, 
# 0.044284310005691, 0.0336655159116644, 0.233941297398488, 0.233026733206461, 
# 0.236268344966599, 0.741446888452032, 0.663086065038527, 0.635923407756903, 
# 0.667725270055688, 0.649312377210216, 0.62229862475442, 0.0807345673184661, 
# 0.0592909937815935, 0.0497633548868457, 0.229816297361225, 0.229367738661146, 
# 0.23233243060689, 0.785362380359245, 0.620245982088087, 0.606820960155813, 
# 0.712969382506206, 0.607563850687623, 0.603634577603143, 0.101664341249118, 
# 0.0396730599703208, 0.0307017140248258, 0.224583855263061, 0.234151068134714, 
# 0.236992993189489, 0.617645214706671, 0.675067080627352, 0.649980809512956, 
# 0.588521988816684, 0.649803536345776, 0.633595284872299, 0.0388266405525888, 
# 0.0773333187731398, 0.0615992739345913, 0.237444372756881, 0.224968580944844, 
# 0.229438553744773, 0.63569878819633, 0.678169312294949, 0.644890643823574, 
# 0.607034910080097, 0.649803536345776, 0.620333988212181, 0.0586010149915041, 
# 0.0909242210687266, 0.0653957772916692, 0.232559391406579, 0.221654788363613, 
# 0.228510310388454, 0.594970218090569, 0.624623537187204, 0.611495249737796, 
# 0.582401390358168, 0.615422396856582, 0.605108055009823, 0.028871468471462, 
# 0.045574389585022, 0.0349656374831014, 0.239903658136835, 0.232712180423562, 
# 0.235950465829512, 0.660986571017867, 0.655625076677708, 0.611898299298585, 
# 0.62732669282624, 0.648821218074656, 0.605599214145383, 0.0807046337218378, 
# 0.0711349376834387, 0.0183986432111736, 0.22737952512646, 0.226479897031441, 
# 0.240001088447407, 0.589832066713614, 0.625081129962284, 0.612848943733887, 
# 0.581446825636382, 0.610019646365422, 0.608546168958743, 0.024968958592103, 
# 0.0420710972469686, 0.0332917627624602, 0.241165248201417, 0.233566368313905, 
# 0.236359727442794, 0.634719522637443, 0.675440080575904, 0.650294073247474, 
# 0.5960258220698, 0.651768172888016, 0.601669941060904, 0.0464804290909637, 
# 0.0832237396505422, 0.0541177350166669, 0.238378253200585, 0.223532353049202, 
# 0.23126778663157, 0.595340611630951, 0.628498976970963, 0.611695541196401, 
# 0.565362114181965, 0.619842829076621, 0.594302554027505, 0.00651011024084458, 
# 0.0464540800565443, 0.0355626759021681, 0.248370764186257, 0.232497690487948, 
# 0.235804490205671), .Dim = c(3L, 4L, 15L), .Dimnames = list(c("train", 
# "valid", "test"), c("AUC", "Accuracy", "r2", "MSE"), c("RFd1", 
# "RFd2", "RFt1", "RFt2", "GBMd1", "GBMd2", "GBMt1", "GBMt2", "mAvH", 
# "GLMd1", "GLMd2", "DLd1", "DLd2", "DLt1", "DLt2")))



#####
# Plots

#This gives us the numbers, but x1 (with odds) and x2 (no odds) are muddled
#Plus we need to add the two benchmark numbers
v <- res["test","Accuracy",]
imp <- v - 0.573  #The improvement compared to always choosing no-win.
models1 <- c("mAvH", "RFd1", "RFt1", "GBMd1", "GBMt1", "GLMd1", "DLd1", "DLt1")
models2 <- setdiff(names(v), models1)

barplot(v)

#More interesting might be to subtract the "no-win" benchmark.
#That spreads the bars out, and is perhaps the more interesting number?

par(mfrow=c(1,2))
barplot(imp[models1], ylab="Accuracy above simple no-win", main="Model Performance (higher is better)", cex.lab=1.2, cex.axis=1.2, cex.main=1.2, cex.sub=1.2, cex.names=1.2)
barplot(imp[models2])

#This version puts them on the same chart
par(mfrow=c(1,1))
barplot(imp[c(models1,0,models2)], ylab="Accuracy above biggest-class-policy", main="Model Performance (higher is better)", ylim=c(0,0.07), cex.lab=1.3, cex.axis=1.3, cex.main=1.3, cex.sub=1.3, cex.names=1.3)
text(x=5, y=0.067, "With Odds",cex=1.4)
text(x=15, y=0.067, "Without Odds",cex=1.4)

