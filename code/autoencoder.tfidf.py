import os, pandas
h2o.init()

#If next line fails, instead set path to location of datasets.
path = os.path.dirname(__file__)
tfidf = h2o.import_file( os.path.join(
  path, "../datasets/movie.tfidf.csv") )

# This is the minimal model: 563 --> 2 --> 563. It trains in under a second, and gives MSE of 0.037
m = h2o.estimators.deeplearning.H2OAutoEncoderEstimator(
  hidden=[2], seed = 707
  )
m.train(x=range(1,564), training_frame=tfidf)
f = m.deepfeatures(tfidf,layer=0)


# Here is the stacked auto-encoder
m1 = h2o.estimators.deeplearning.H2OAutoEncoderEstimator(
  hidden = [128,64,11,64,128], seed = 707, activation = "Tanh", epochs = 400
  )
m1.train(x = range(1,564), training_frame = tfidf)
f1 = m1.deepfeatures(tfidf, layer = 2)

m2 = h2o.estimators.deeplearning.H2OAutoEncoderEstimator(
  hidden = [2], seed = 707, activation = "Tanh", epochs = 400
  )
m2.train(x = range(0,11), training_frame = f1)
f2 = m2.deepfeatures(f1, layer = 0)

