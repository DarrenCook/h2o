import os
import h2o
h2o.init(max_mem_size="3G")

path = os.path.dirname(__file__)
train = h2o.import_file( os.path.join(
  path, "../datasets/football.train.csv") )
valid = h2o.import_file( os.path.join(
  path, "../datasets/football.valid.csv") )
test = h2o.import_file( os.path.join(
  path, "../datasets/football.test.csv") )

train["HomeWin"] = (train["FTR"] == "H").asfactor()
valid["HomeWin"] = (valid["FTR"] == "H").asfactor()
test["HomeWin"] = (test["FTR"] == "H").asfactor()

train["ScoreDraw"] = (
  (train["FTHG"] > 0) & (train["FTHG"] == train["FTAG"])
  ).asfactor()
valid["ScoreDraw"] = (
  (valid["FTHG"] > 0) & (valid["FTHG"] == valid["FTAG"])
  ).asfactor()
test["ScoreDraw"] = (
  (test["FTHG"] > 0) & (test["FTHG"] == test["FTAG"])
  ).asfactor()

statFields = [
  "FTHG", "FTAG", "FTR", "HTHG", "HTAG", "HTR",
  "HS", "AS", "HST", "AST", "HF", "AF",
  "HC", "AC", "HY", "AY", "HR", "AR",
  "HomeWin", "ScoreDraw"
  ]
ignoreFields = ["Date", "HomeTeam", "AwayTeam"] + statFields

x = [i for i in train.names if i not in ignoreFields]

xNoOdds = [
  "Div", "HS1", "AS1", "HST1", "AST1",
  "HF1", "AF1", "HC1", "AC1", "HY1", "AY1", "HR1", "AR1",
  "res1H", "res1A", "res5H", "res5A", "res20H", "res20A"
  ]

#y = "FTR"  #3-value multinomial
#y = "ScoreDraw"  #Unbalanced binomial
y = "HomeWin" #Balanced binomial
