seed = 450

source("load.mnist.R")

#With 3.10.0.8, on notebook: 2.727   0.387 152.600   (8 cores kept busy)
#   (first time to be using seed)
#   Scored 775 on valid, 0.0627 error on train.  740 on test
#   (the values in the book are 782 on valid, 746 on test, and it took 4 minutes)
system.time(
  m <- h2o.glm(x, y, train, validation_frame = valid,  model_id="GLM_defaults", family="multinomial", seed = seed)
  )

summary(m)

pf = h2o.performance(m, test)

cbind(h2o.hit_ratio_table(m), h2o.hit_ratio_table(m,valid=T), pf@metrics$hit_ratio_table)

#p = h2o.predict(m, test, seed=seed)
#p


#########
#########

# This is results of h2o.performance(m,test)

# Test Set Metrics: 
# =====================
# 
# MSE: (Extract with `h2o.mse`) 0.06812066
# R^2: (Extract with `h2o.r2`) 0.9918761
# Logloss: (Extract with `h2o.logloss`) 0.2712785
# Mean Per-Class Error: 0.07569481
# Null Deviance: (Extract with `h2o.nulldeviance`) 46020.21
# Residual Deviance: (Extract with `h2o.residual_deviance`) 5425.57
# AIC: (Extract with `h2o.aic`) NaN
# Confusion Matrix: Extract with `h2o.confusionMatrix(<model>, <data>)`)
# =========================================================================
# Confusion Matrix: vertical: actual; across: predicted
#           0    1   2    3   4   5   6    7   8    9  Error           Rate
# 0       959    0   2    1   0   7   5    5   1    0 0.0214 =     21 / 980
# 1         0 1113   3    2   0   1   4    2  10    0 0.0194 =   22 / 1,135
# 2         7   10 923   15   9   3  13   10  39    3 0.1056 =  109 / 1,032
# 3         3    1  18  919   0  26   1   11  23    8 0.0901 =   91 / 1,010
# 4         1    1   5    0 917   0  14    6   7   31 0.0662 =     65 / 982
# 5         8    2   1   35  11 774  14   12  30    5 0.1323 =    118 / 892
# 6         8    3   6    1   7  14 914    3   2    0 0.0459 =     44 / 958
# 7         0    9  24    6   6   0   0  951   1   31 0.0749 =   77 / 1,028
# 8         7    7   7   21  10  24  11   10 865   12 0.1119 =    109 / 974
# 9        10    9   1   11  25   5   1   21   7  919 0.0892 =   90 / 1,009
# Totals 1003 1155 990 1011 985 854 977 1031 985 1009 0.0746 = 746 / 10,000
# 
# Hit Ratio Table: Extract with `h2o.hit_ratio_table(<model>, <data>)`
# =======================================================================
# Top-10 Hit Ratios: 
#     k hit_ratio
# 1   1  0.925400
# 2   2  0.970900
# 3   3  0.984600
# 4   4  0.991100
# 5   5  0.995400
# 6   6  0.997300
# 7   7  0.999000
# 8   8  0.999500
# 9   9  1.000000
# 10 10  1.000000



# This is output of `m`
# 
# Model Details:
# ==============
# 
# H2OMultinomialModel: glm
# Model ID:  GLM_defaults 
# GLM Model: summary
#        family        link                                regularization number_of_predictors_total
# 1 multinomial multinomial Elastic Net (alpha = 0.5, lambda = 3.366E-4 )                       2990
#   number_of_active_predictors number_of_iterations  training_frame
# 1                        2989                   19 RTMP_sid_8f61_7
# 
# Coefficients: glm multinomial coefficients
#       names coefs_class_0 coefs_class_1 coefs_class_2 coefs_class_3 coefs_class_4 coefs_class_5 coefs_class_6
# 1 Intercept     -3.719850     -1.236590     -2.546779     -3.456291     -2.284508     -0.815823     -3.262454
# 2       C13      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 3       C14      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 4       C15      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 5       C16      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
#   coefs_class_7 coefs_class_8 coefs_class_9 std_coefs_class_0 std_coefs_class_1 std_coefs_class_2 std_coefs_class_3
# 1     -1.373704     -5.062427     -3.178263         -6.716239         -9.745480         -4.011245         -3.916723
# 2      0.000000      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 3      0.000000      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 4      0.000000      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 5      0.000000      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
#   std_coefs_class_4 std_coefs_class_5 std_coefs_class_6 std_coefs_class_7 std_coefs_class_8 std_coefs_class_9
# 1         -6.654850         -3.981319         -6.234290         -6.953334         -2.845013         -4.684024
# 2          0.000000          0.000000          0.000000          0.000000          0.000000          0.000000
# 3          0.000000          0.000000          0.000000          0.000000          0.000000          0.000000
# 4          0.000000          0.000000          0.000000          0.000000          0.000000          0.000000
# 5          0.000000          0.000000          0.000000          0.000000          0.000000          0.000000
# 
# ---
#     names coefs_class_0 coefs_class_1 coefs_class_2 coefs_class_3 coefs_class_4 coefs_class_5 coefs_class_6
# 713  C775      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 714  C776      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 715  C777      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 716  C778      0.000000      0.000000      0.000000      0.000000      0.000000     -0.008808      0.000000
# 717  C779      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
# 718  C780      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000      0.000000
#     coefs_class_7 coefs_class_8 coefs_class_9 std_coefs_class_0 std_coefs_class_1 std_coefs_class_2 std_coefs_class_3
# 713      0.000362      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 714      0.006582      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 715      0.000000      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 716      0.000000      0.000000      0.000000          0.000000          0.000000          0.000000          0.000000
# 717     -0.001497      0.000000      0.040629          0.000000          0.000000          0.000000          0.000000
# 718      0.123069      0.000000     -0.097541          0.000000          0.000000          0.000000          0.000000
#     std_coefs_class_4 std_coefs_class_5 std_coefs_class_6 std_coefs_class_7 std_coefs_class_8 std_coefs_class_9
# 713          0.000000          0.000000          0.000000          0.002295          0.000000          0.000000
# 714          0.000000          0.000000          0.000000          0.028323          0.000000          0.000000
# 715          0.000000          0.000000          0.000000          0.000000          0.000000          0.000000
# 716          0.000000         -0.014513          0.000000          0.000000          0.000000          0.000000
# 717          0.000000          0.000000          0.000000         -0.002634          0.000000          0.071498
# 718          0.000000          0.000000          0.000000          0.046727          0.000000         -0.037034
# 
# H2OMultinomialMetrics: glm
# ** Reported on training data. **
# 
# Training Set Metrics: 
# =====================
# 
# Extract training frame with `h2o.getFrame("RTMP_sid_8f61_7")`
# MSE: (Extract with `h2o.mse`) 0.05966173
# R^2: (Extract with `h2o.r2`) 0.9928449
# Logloss: (Extract with `h2o.logloss`) 0.225471
# Mean Per-Class Error: 0.06333588
# Null Deviance: (Extract with `h2o.nulldeviance`) 230103.9
# Residual Deviance: (Extract with `h2o.residual_deviance`) 22547.1
# AIC: (Extract with `h2o.aic`) NaN
# Confusion Matrix: Extract with `h2o.confusionMatrix(<model>,train = TRUE)`)
# =========================================================================
# Confusion Matrix: vertical: actual; across: predicted
#           0    1    2    3    4    5    6    7    8    9  Error             Rate
# 0      4795    1   10    6    6   21   29    3   32    3 0.0226 =    111 / 4,906
# 1         1 5518   29   15    5   16    3   10   36    8 0.0218 =    123 / 5,641
# 2        23   38 4588   60   46   16   36   61  102   13 0.0793 =    395 / 4,983
# 3        12   22   98 4622    7  155   15   37   89   41 0.0934 =    476 / 5,098
# 4         7   18   22    8 4632    6   32   14   22  132 0.0533 =    261 / 4,893
# 5        27   15   32  126   38 4049   65   13   88   28 0.0964 =    432 / 4,481
# 6        24   13   28    1   29   50 4796    2   18    3 0.0338 =    168 / 4,964
# 7         9   24   45   13   36   10    3 4938   12  129 0.0538 =    281 / 5,219
# 8        22   86   47  100   22  103   27   16 4388   54 0.0980 =    477 / 4,865
# 9        16   20    8   64  103   31    3  124   31 4550 0.0808 =    400 / 4,950
# Totals 4936 5755 4907 5015 4924 4457 5009 5218 4818 4961 0.0625 = 3,124 / 50,000
# 
# Hit Ratio Table: Extract with `h2o.hit_ratio_table(<model>,train = TRUE)`
# =======================================================================
# Top-10 Hit Ratios: 
#     k hit_ratio
# 1   1  0.937520
# 2   2  0.976340
# 3   3  0.989000
# 4   4  0.993960
# 5   5  0.996820
# 6   6  0.998180
# 7   7  0.999120
# 8   8  0.999640
# 9   9  0.999880
# 10 10  1.000000
# 
# 
# H2OMultinomialMetrics: glm
# ** Reported on validation data. **
# 
# Validation Set Metrics: 
# =====================
# 
# Extract validation frame with `h2o.getFrame("RTMP_sid_8f61_9")`
# MSE: (Extract with `h2o.mse`) 0.07322647
# R^2: (Extract with `h2o.r2`) 0.9912769
# Logloss: (Extract with `h2o.logloss`) 0.2970408
# Mean Per-Class Error: 0.07795136
# Null Deviance: (Extract with `h2o.nulldeviance`) 46036.49
# Residual Deviance: (Extract with `h2o.residual_deviance`) 5940.815
# AIC: (Extract with `h2o.aic`) NaN
# Confusion Matrix: Extract with `h2o.confusionMatrix(<model>,valid = TRUE)`)
# =========================================================================
# Confusion Matrix: vertical: actual; across: predicted
#           0    1   2    3   4   5   6    7   8    9  Error           Rate
# 0       988    0   5    2   3   4   8    3   2    2 0.0285 =   29 / 1,017
# 1         0 1069   6    2   2   4   0    2  13    3 0.0291 =   32 / 1,101
# 2         4   16 871   13  14   3  20    7  21    6 0.1067 =    104 / 975
# 3         4    4  23  923   2  35   4   10  21    7 0.1065 =  110 / 1,033
# 4         2    6   3    2 882   1   8    2   6   37 0.0706 =     67 / 949
# 5        10    4   2   27  13 836  17    2  21    8 0.1106 =    104 / 940
# 6         7    2   6    0   7  14 912    5   0    1 0.0440 =     42 / 954
# 7         1    2  12    4  12   2   0  975   3   35 0.0679 =   71 / 1,046
# 8         9   19  11   17   6  30   5    2 878    9 0.1095 =    108 / 986
# 9         5    3   3   13  39   1   0   33   9  893 0.1061 =    106 / 999
# Totals 1030 1125 942 1003 980 930 974 1041 974 1001 0.0773 = 773 / 10,000
# 
# Hit Ratio Table: Extract with `h2o.hit_ratio_table(<model>,valid = TRUE)`
# =======================================================================
# Top-10 Hit Ratios: 
#     k hit_ratio
# 1   1  0.922700
# 2   2  0.967500
# 3   3  0.985300
# 4   4  0.991400
# 5   5  0.994600
# 6   6  0.996700
# 7   7  0.998500
# 8   8  0.999100
# 9   9  0.999800
# 10 10  1.000000
# 


##############################

# Here is the same data with 

# Model Details:
# ==============
# 
# H2OMultinomialModel: glm
# Model ID:  GLM_defaults 
# GLM Model: summary
#        family        link                                regularization
# 1 multinomial multinomial Elastic Net (alpha = 0.5, lambda = 3.366E-4 )
#   number_of_predictors_total number_of_active_predictors number_of_iterations
# 1                       7180                        3079                   13
#    training_frame
# 1 RTMP_sid_b22d_9
# 
# Coefficients: glm multinomial coefficients
#       names coefs_class_0 coefs_class_1 coefs_class_2 coefs_class_3
# 1 Intercept     -3.483182     -1.005315     -2.289751     -3.169602
# 2       C13      0.000000      0.000000      0.000000      0.000000
# 3       C14      0.000000      0.000000      0.000000      0.000000
# 4       C15      0.000000      0.000000      0.000000      0.000000
# 5       C16      0.000000      0.000000      0.000000      0.000000
#   coefs_class_4 coefs_class_5 coefs_class_6 coefs_class_7 coefs_class_8
# 1     -2.045254     -0.603919     -3.040074     -1.135512     -4.767534
# 2      0.000000      0.000000      0.000000      0.000000      0.000000
# 3      0.000000      0.000000      0.000000      0.000000      0.000000
# 4      0.000000      0.000000      0.000000      0.000000      0.000000
# 5      0.000000      0.000000      0.000000      0.000000      0.000000
#   coefs_class_9 std_coefs_class_0 std_coefs_class_1 std_coefs_class_2
# 1     -2.942955         -6.689964         -9.715016         -4.000083
# 2      0.000000          0.000000          0.000000          0.000000
# 3      0.000000          0.000000          0.000000          0.000000
# 4      0.000000          0.000000          0.000000          0.000000
# 5      0.000000          0.000000          0.000000          0.000000
#   std_coefs_class_3 std_coefs_class_4 std_coefs_class_5 std_coefs_class_6
# 1         -3.901290         -6.645694         -3.974368         -6.175768
# 2          0.000000          0.000000          0.000000          0.000000
# 3          0.000000          0.000000          0.000000          0.000000
# 4          0.000000          0.000000          0.000000          0.000000
# 5          0.000000          0.000000          0.000000          0.000000
#   std_coefs_class_7 std_coefs_class_8 std_coefs_class_9
# 1         -6.875451         -2.837868         -4.651877
# 2          0.000000          0.000000          0.000000
# 3          0.000000          0.000000          0.000000
# 4          0.000000          0.000000          0.000000
# 5          0.000000          0.000000          0.000000
# 
# ---
#     names coefs_class_0 coefs_class_1 coefs_class_2 coefs_class_3 coefs_class_4
# 713  C775      0.000000      0.000000      0.000000      0.000000      0.000000
# 714  C776      0.000000      0.000000      0.000000      0.000000      0.000000
# 715  C777      0.000000      0.000000      0.000000      0.000000      0.000000
# 716  C778      0.000000      0.000000      0.000000      0.000000      0.000000
# 717  C779      0.000000      0.000000     -0.002424      0.000000      0.000000
# 718  C780      0.000000      0.000000      0.000000      0.000000      0.000000
#     coefs_class_5 coefs_class_6 coefs_class_7 coefs_class_8 coefs_class_9
# 713      0.000000      0.000000      0.000221      0.000000      0.000000
# 714      0.000000      0.000000      0.006821      0.000000      0.000000
# 715     -0.001150      0.000000      0.000037      0.000000      0.000000
# 716     -0.008826      0.000000      0.000000      0.000000      0.000000
# 717      0.000000      0.000000     -0.005517      0.000000      0.036598
# 718      0.000000      0.000000      0.134188      0.000000     -0.089328
#     std_coefs_class_0 std_coefs_class_1 std_coefs_class_2 std_coefs_class_3
# 713          0.000000          0.000000          0.000000          0.000000
# 714          0.000000          0.000000          0.000000          0.000000
# 715          0.000000          0.000000          0.000000          0.000000
# 716          0.000000          0.000000          0.000000          0.000000
# 717          0.000000          0.000000         -0.004265          0.000000
# 718          0.000000          0.000000          0.000000          0.000000
#     std_coefs_class_4 std_coefs_class_5 std_coefs_class_6 std_coefs_class_7
# 713          0.000000          0.000000          0.000000          0.001402
# 714          0.000000          0.000000          0.000000          0.029350
# 715          0.000000         -0.003576          0.000000          0.000114
# 716          0.000000         -0.014543          0.000000          0.000000
# 717          0.000000          0.000000          0.000000         -0.009709
# 718          0.000000          0.000000          0.000000          0.050949
#     std_coefs_class_8 std_coefs_class_9
# 713          0.000000          0.000000
# 714          0.000000          0.000000
# 715          0.000000          0.000000
# 716          0.000000          0.000000
# 717          0.000000          0.064405
# 718          0.000000         -0.033916
# 
# H2OMultinomialMetrics: glm
# ** Reported on training data. **
# 
# Training Set Metrics: 
# =====================
# 
# Extract training frame with `h2o.getFrame("RTMP_sid_b22d_9")`
# MSE: (Extract with `h2o.mse`) 0.05983425
# RMSE: (Extract with `h2o.rmse`) 0.2446104
# Logloss: (Extract with `h2o.logloss`) 0.2261303
# Mean Per-Class Error: 0.06352044
# Null Deviance: (Extract with `h2o.nulldeviance`) 230103.9
# Residual Deviance: (Extract with `h2o.residual_deviance`) 22613.03
# R^2: (Extract with `h2o.r2`) 0.9928242
# AIC: (Extract with `h2o.aic`) NaN
# Confusion Matrix: Extract with `h2o.confusionMatrix(<model>,train = TRUE)`)
# =========================================================================
# Confusion Matrix: vertical: actual; across: predicted
#           0    1    2    3    4    5    6    7    8    9  Error
# 0      4798    1    9    6    7   18   27    3   34    3 0.0220
# 1         1 5518   29   14    6   16    3   10   36    8 0.0218
# 2        23   37 4577   60   47   17   39   64  106   13 0.0815
# 3        12   23   97 4621    7  154   15   39   88   42 0.0936
# 4         8   18   21    8 4631    6   32   15   23  131 0.0535
# 5        27   16   32  122   38 4054   64   13   87   28 0.0953
# 6        24   12   27    0   29   51 4796    3   19    3 0.0338
# 7         9   24   45   14   39   10    2 4934   13  129 0.0546
# 8        22   87   46  100   22  104   27   15 4389   53 0.0978
# 9        16   19    8   66  102   31    3  124   33 4548 0.0812
# Totals 4940 5755 4891 5011 4928 4461 5008 5220 4828 4958 0.0627
#                    Rate
# 0      =    108 / 4,906
# 1      =    123 / 5,641
# 2      =    406 / 4,983
# 3      =    477 / 5,098
# 4      =    262 / 4,893
# 5      =    427 / 4,481
# 6      =    168 / 4,964
# 7      =    285 / 5,219
# 8      =    476 / 4,865
# 9      =    402 / 4,950
# Totals = 3,134 / 50,000
# 
# Hit Ratio Table: Extract with `h2o.hit_ratio_table(<model>,train = TRUE)`
# =======================================================================
# Top-10 Hit Ratios: 
#     k hit_ratio
# 1   1  0.937320
# 2   2  0.976440
# 3   3  0.988920
# 4   4  0.993960
# 5   5  0.996780
# 6   6  0.998120
# 7   7  0.999160
# 8   8  0.999680
# 9   9  0.999880
# 10 10  1.000000
# 
# 
# H2OMultinomialMetrics: glm
# ** Reported on validation data. **
# 
# Validation Set Metrics: 
# =====================
# 
# Extract validation frame with `h2o.getFrame("RTMP_sid_b22d_11")`
# MSE: (Extract with `h2o.mse`) 0.07328921
# RMSE: (Extract with `h2o.rmse`) 0.2707198
# Logloss: (Extract with `h2o.logloss`) 0.2966384
# Mean Per-Class Error: 0.07817355
# Null Deviance: (Extract with `h2o.nulldeviance`) 46036.49
# Residual Deviance: (Extract with `h2o.residual_deviance`) 5932.768
# R^2: (Extract with `h2o.r2`) 0.9912694
# AIC: (Extract with `h2o.aic`) NaN
# Confusion Matrix: Extract with `h2o.confusionMatrix(<model>,valid = TRUE)`)
# =========================================================================
# Confusion Matrix: vertical: actual; across: predicted
#           0    1   2    3   4   5   6    7   8    9  Error           Rate
# 0       990    0   4    2   3   4   8    2   2    2 0.0265 =   27 / 1,017
# 1         0 1069   6    2   2   4   0    2  13    3 0.0291 =   32 / 1,101
# 2         4   19 865   14  14   3  21    7  21    7 0.1128 =    110 / 975
# 3         4    4  23  925   2  33   4   10  21    7 0.1045 =  108 / 1,033
# 4         3    6   3    3 882   1   7    3   6   35 0.0706 =     67 / 949
# 5        10    5   2   26  14 835  17    2  21    8 0.1117 =    105 / 940
# 6         7    2   5    0   7  14 913    5   0    1 0.0430 =     41 / 954
# 7         1    2  12    4  12   1   0  974   3   37 0.0688 =   72 / 1,046
# 8         8   18  11   19   6  28   6    2 878   10 0.1095 =    108 / 986
# 9         5    3   3   12  39   1   0   33   9  894 0.1051 =    105 / 999
# Totals 1032 1128 934 1007 981 924 976 1040 974 1004 0.0775 = 775 / 10,000
# 
# Hit Ratio Table: Extract with `h2o.hit_ratio_table(<model>,valid = TRUE)`
# =======================================================================
# Top-10 Hit Ratios: 
#     k hit_ratio
# 1   1  0.922500
# 2   2  0.967400
# 3   3  0.985100
# 4   4  0.991400
# 5   5  0.994500
# 6   6  0.996600
# 7   7  0.998400
# 8   8  0.999100
# 9   9  0.999800
# 10 10  1.000000
# 
# 
# 
# H2OMultinomialMetrics: glm
# 
# Test Set Metrics: 
# =====================
# 
# MSE: (Extract with `h2o.mse`) 0.06812246
# RMSE: (Extract with `h2o.rmse`) 0.2610028
# Logloss: (Extract with `h2o.logloss`) 0.2709738
# Mean Per-Class Error: 0.07505001
# Null Deviance: (Extract with `h2o.nulldeviance`) 46020.21
# Residual Deviance: (Extract with `h2o.residual_deviance`) 5419.475
# R^2: (Extract with `h2o.r2`) 0.9918759
# AIC: (Extract with `h2o.aic`) NaN
# Confusion Matrix: Extract with `h2o.confusionMatrix(<model>, <data>)`)
# =========================================================================
# Confusion Matrix: vertical: actual; across: predicted
#           0    1   2    3   4   5   6    7   8    9  Error           Rate
# 0       958    0   2    1   0   7   6    5   1    0 0.0224 =     22 / 980
# 1         0 1112   3    2   0   1   4    2  11    0 0.0203 =   23 / 1,135
# 2         7   10 924   14   9   3  14   10  39    2 0.1047 =  108 / 1,032
# 3         3    1  18  919   0  25   2   11  23    8 0.0901 =   91 / 1,010
# 4         1    1   5    0 917   0  14    6   7   31 0.0662 =     65 / 982
# 5         8    2   1   33  11 777  14   11  30    5 0.1289 =    115 / 892
# 6         8    3   6    1   7  14 914    3   2    0 0.0459 =     44 / 958
# 7         0    8  24    6   6   0   0  952   1   31 0.0739 =   76 / 1,028
# 8         7    6   8   21  10  22  11   11 867   11 0.1099 =    107 / 974
# 9        10    9   1   11  25   5   1   20   7  920 0.0882 =   89 / 1,009
# Totals 1002 1152 992 1008 985 854 980 1031 988 1008 0.0740 = 740 / 10,000
# 
# Hit Ratio Table: Extract with `h2o.hit_ratio_table(<model>, <data>)`
# =======================================================================
# Top-10 Hit Ratios: 
#     k hit_ratio
# 1   1  0.926000
# 2   2  0.971100
# 3   3  0.984800
# 4   4  0.990900
# 5   5  0.995500
# 6   6  0.997200
# 7   7  0.998900
# 8   8  0.999600
# 9   9  1.000000
# 10 10  1.000000
# 
# 



