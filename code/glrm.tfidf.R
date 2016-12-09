library(h2o)
h2o.init(nthreads=-1)

tfidf <- h2o.importFile("../datasets/movie.tfidf.csv")

m <- h2o.glrm(tfidf, cols=2:564, k=2, seed=707)
X <- h2o.getFrame(m@model$representation_name)

# X is 2 columns, 100 rows.
# NB. the 'Y' is m@model$archetypes, which is 2 rows, 563 columns.
# To get the reconstructed matrix, use h2o.predict(m,tfidf) or h2o.proj_archetypes(m,tfidf)

# Plot
d <- as.matrix(X)
plot(d);text(d,labels = as.vector(tfidf[,1]),cex=0.8)

#And to just plot the top-30 movies
labels = as.vector(tfidf[1:30,1])
labels[30]="Dr.Strangelove"
# labels[22]="                2001: A Space Odyssey"
pos = ifelse(d[1:30,2] < 1.0,1,3)
pos[29]=3
pos[19]=1
plot(d[1:30,],xlim=c(-0.6,1.2));text(d[1:30,],labels = labels,cex=0.8, pos=pos)

#Or with jitter
d2 = jitter(d[1:30,])
plot(d2,xlim=c(-0.6,1.2));text(d2,labels = labels,cex=0.8, pos=pos)

