# This is a very crude script - there is almost certainly a better way to 
# do this (e.g. create a 3D array from the MNIST data: 60000 x 28 x 28, then
# slice that; alternatively rewrite matsplitter so it operates on a 1D vector
# instead of needing the matrix; etc. etc)
# But it completes in 7 to 10 minutes (estimate), and is a one-off data prep. task,
# so this is fine.

seed = 450

library(h2o)
h2o.init(nthreads=-1, max_mem_size="3G")  #TODO: can we get by with less than 2G? (I've
  #increased to 3G, as random forest grids take up quite a bit of memory)

train2 = h2o.importFile("../datasets/mnist.train.csv.gz")
test = h2o.importFile("../datasets/mnist.test.csv.gz")

d1 = as.data.frame(train2)
d2 = as.data.frame(test)

# ------------
 
# See  http://stackoverflow.com/a/24299527/841830
matsplitter<-function(M, r, c) {
    rg <- (row(M)-1)%/%r+1
    cg <- (col(M)-1)%/%c+1
    rci <- (rg-1)*max(cg) + cg
    N <- prod(dim(M))/r/c
    cv <- unlist(lapply(1:N, function(x) M[rci==x]))
    dim(cv)<-c(r,c,N)
    cv
} 

# -----------------------

#
#
# Note: I originally made 4x4 blobs (averaging 7x7 pixel blocks). But I dropped
#   it, in favour of adding the vertical and horizontal lines. (Just on a hunch - no
#   experiments were tried with the 4x4 blobs.)
process = function(d){
ROWS = nrow(d)
#ROWS = 100  #TEMP - finishes quickly, when testing

res = matrix(0L, nrow = ROWS, ncol= 49 + 36 + 14 + 14)
for(i in 1:ROWS){
  sample = d[i,]
  m = matrix(sample[0:784], nrow=28, byrow=T)

  #z77 = matsplitter(m, 7,7)  #Makes 7x7 matrices (i.e. 16 of them)
  #v4by4 = sapply(1:16, function(n) mean(z77[,,n]) )

  z44 = matsplitter(m, 4,4)
  v7by7 = sapply(1:49, function(n) mean(z44[,,n]) )
  
  z44_off2 = matsplitter(m[3:26,3:26], 4,4)
  v6by6 = sapply(1:36, function(n) mean(z44_off2[,,n]) )

  z282 = matsplitter(m, 28,2)
  v1by14 = sapply(1:14, function(n) mean(z282[,,n]) )  #14 values, one for each 2-pixel columns

  z228 = matsplitter(m, 2,28)
  v14by1 = sapply(1:14, function(n) mean(z228[,,n]) )  #14 values, one for each 2-pixel row

  res[i,] = as.integer(c( v7by7, v6by6, v1by14, v14by1))
  }

res
}

system.time(resTest <- process(d2))  #10000 test rows. took 72.6s (almost all "user") (81s on 2nd try)
system.time(resTrain <- process(d1))   #0.57s to do 100 rows, 6.154s to do 1000 rows
  #So, we're looking at 6-8 mins to do all 60,000 train rows: it took 447 seconds. (507s on 2nd try)


# Now merge new columns in with existing data, and make new csv files.

#NOTE: relative path not supported by exportFile.
#NOTE: direct output to *.gz not supported by exportFile.

resTestH2O = as.h2o(resTest)
enhancedTest = h2o.cbind(resTestH2O, test)  #Put new columns first, so the answer column is still the final one
h2o.exportFile(enhancedTest, "/home/darren/Projects/books/H2O/datasets/mnist.enhanced_test.csv")

resTrainH2O = as.h2o(resTrain)
enhancedTrain2 = h2o.cbind(resTrainH2O, train2)

parts = h2o.splitFrame(enhancedTrain2, 0.1675, seed = get0("seed",ifnotfound = -1) )
valid = parts[[1]]
train = parts[[2]]
rm(parts)

h2o.exportFile(valid, "/home/darren/Projects/books/H2O/datasets/mnist.enhanced_valid.csv")
h2o.exportFile(train, "/home/darren/Projects/books/H2O/datasets/mnist.enhanced_train.csv")

#I then manually edited each file to remove the header row, and then gzip-ed each.


#############
# This is to visualize the mnist data
# 
# It takes a set of mnist samples: it draws the
# first cols*rows entries.
#
# @internal The rev() stuff is a bit wild: I just worked it
#   out by trial and error (i.e. until the image matched the
#   correct answer in the training data!)
drawMNISTSamples = function(d, cols=15, rows=4){
col=grey(255:0/255)  #Colour scheme
len = cols*rows
if(length(d) < len)len=length(d)
par(mfrow = c(rows,cols))  #Fill row-by-row
par(mar=c(0.1,0.1,0.1,0.1))  #Reduce margins, so all are close together
par(pty="s")  #Make box square (also then no need for asp=1 in each plot)
for(ix in 1:len){
  m1 = matrix( as.numeric(d[ix,1:784]), nrow=28)
  m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  image(m2, col=col, axes=F);box()
  }
}



# Like drawMNISTSamples, but it only draws the first "cols"
# entries, and instead has 4 rows, which are the 4x4, 7x7 and 6x6 grids
# which are expected to be found in `res` in that order.
drawMNISTSamplesWithSummaries = function(d, res, cols=10){
col=grey(255:0/255)  #Colour scheme
if(length(d) < cols)cols=length(d)
par(mfcol = c(5,cols))
par(mar=c(0.1,0.1,0.1,0.1))
par(pty="s")  #Make it square (no need for asp=1 in each plot)
for(ix in 1:cols){
  m1 = matrix( as.numeric(d[ix,1:784]), nrow=28)
  m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  image(m2, col=col, axes=F);box()

  #The 4x4 blobs were dropped
  # m1 = matrix( res[ix,1:16], nrow=4)
  # m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  # image(m2, col=col, axes=F);box()

  m1 = matrix( res[ix,(1):(49)], nrow=7)
  m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  image(m2, col=col, axes=F);box()
  
  m1 = matrix( res[ix,(1+49):(49+36)], nrow=6)
  m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  image(m2, col=col, axes=F);box()

  m1 = matrix( res[ix,(1+49+36):(49+36+14)], nrow=14)
  m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  image(m2, col=col, axes=F);box()

  m1 = matrix( res[ix,(1+49+36+14):(49+36+14+14)], nrow=1)
  m2 = as.data.frame(m1);m2=rev(m2);m2=as.matrix(m2)
  image(m2, col=col, axes=F);box()
  }
}


#Image in book was drawMNISTSamplesWithSummaries(d1, resTrain,cols=15)
#  saved to a 1600 x 533 pixel PNG.
#  
#The image at the start of the MNIST section (datasets chapter)
#was done with:  drawMNISTSamples(d1)
#  (1600x700 PNG)
