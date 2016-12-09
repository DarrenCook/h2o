#Run load.football.py or load_football2.py first

m1 = h2o.estimators.H2ORandomForestEstimator(model_id="RF_defaults_Odds")
m1.train(x, y, train, validation_frame=valid)

m2 = h2o.estimators.H2ORandomForestEstimator(model_id="RF_defaults_NoOdds")
m2.train(xNoOdds, y, train, validation_frame=valid)
