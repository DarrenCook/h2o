import h2o
h2o.init()

tfidf = h2o.import_file("../datasets/movie.tfidf.csv")

from h2o.estimators.kmeans import H2OKMeansEstimator
m = H2OKMeansEstimator(k=5, standardize=False, init="PlusPlus")
m.train(x=range(1,564), training_frame=tfidf)

#Get the group that each movie is in
p = m.predict(tfidf)

#Join that to our movie names, then download it
d = tfidf[0].cbind(p).as_data_frame()
d.columns = ["movie","group"]

#Iterate through and print each group
for ix, g in d.groupby("group"):
    print "---",ix,"---"
    print ', '.join(g["movie"])
