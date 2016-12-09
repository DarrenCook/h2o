library(h2o)
h2o.init(nthreads = -1)

tfidf <- h2o.importFile("../datasets/movie.tfidf.csv")

m <- h2o.kmeans(tfidf, x = 2:564, k = 5,
  standardize = FALSE, init = "PlusPlus")

p <- h2o.predict(m, tfidf)

tapply(as.vector(tfidf[,1]), as.vector(p$predict), print)
