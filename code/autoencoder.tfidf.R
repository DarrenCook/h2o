library(h2o)
h2o.init(nthreads = -1)

tfidf <- h2o.importFile("../datasets/movie.tfidf.csv")

m <- h2o.deeplearning(2:564, training_frame = tfidf,
  hidden = c(2), autoencoder = T, activation = "Tanh")
f <- h2o.deepfeatures(m, tfidf, layer = 1)

#Print it
d <- as.matrix(f[1:30,])
labels <- as.vector(tfidf[1:30,1])
plot(d, pch = 17)
text(d, labels, pos = 3)


#Plot for book (1600x1100)
plot(d, cex=1.0, pch=17, xlim=range(d[,1])*1.2, ylim=range(d[,2])*1.05, xlab="",ylab="",cex.lab=1.75, cex.axis=1.75)
text(d,labels = labels,cex=1.75,pos=3, offset = 0.33)

#An alternative way to alter xlim and ylim
plot(d, cex=1.0, pch=17, xlim=range(d[,1])+c(-0.1,0.1), ylim=range(d[,2])+c(-0.02,0.02), xlab="",ylab="",cex.lab=1.75, cex.axis=1.75)
text(d,labels = labels,cex=1.75,pos=3, offset = 0.33)

