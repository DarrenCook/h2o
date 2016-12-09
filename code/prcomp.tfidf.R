library(h2o)
h2o.init(nthreads=-1)

tfidf <- h2o.importFile("../datasets/movie.tfidf.csv")

#NB. no need to set seed: no random element.
m <- h2o.prcomp(tfidf, 2:564, k=2)
p <- h2o.predict(m, tfidf)

#p2 ends up exactly the same as p
m2 <- h2o.svd(tfidf, 2:564, nv=2)
p2 <- h2o.predict(m2, tfidf)

###
# Now we can plot

d <- as.matrix(p)
plot(d);text(d,labels = as.vector(tfidf[,1]),cex=0.8)

#And to just plot the top-30 movies
labels = as.vector(tfidf[1:30,1])
labels[2]="The Shawshank Redemption               "
labels[22]="                2001: A Space Odyssey"
pos = rep(3,30)
pos[2]=1
pos[9]=1
pos[22]=1
pos[25]=1
plot(d[1:30,],xlim=c(0.24,0.70));text(d[1:30,],labels = labels,cex=0.8, pos=pos)

