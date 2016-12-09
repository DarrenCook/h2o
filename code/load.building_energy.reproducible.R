seed = 999

library(h2o)
h2o.init(nthreads = -1)

data <- h2o.importFile("../datasets/ENB2012_data.csv")

factorsList <- c("X6", "X8")
data[,factorsList] <- as.factor(data[,factorsList])

splits <- h2o.splitFrame(data, 0.8, seed = seed)
train <- splits[[1]]
test <- splits[[2]]

x <- c("X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8")
y <- "Y2"  #Or "Y1"

######


numericColumns <- setdiff(colnames(train),c("X6","X8"))
d <- round( h2o.cor(train[,numericColumns]) ,2)
rownames(d) <- colnames(d)
d


#####

#breaks defaults to sturges
# "rice" gives more, thinner bars
# "doane" crashes it
# "fd" gives a square for X1, X7 is chunky, X4 are peaks.
# "scott": the bars always touch, but are of different widths.
# 
# I've added a bit more formatting than described in the book,
# just to get the plot shown in the book.

par(mar=c(5.1, 6.0, 4.1, 2.1))  #Changed 4.1 to 6.0
par(oma=c(1,0,0,0))  #Def was all zeroes
par(mfrow = c(2,5))
#ylim <- c(0,350)
ylim <- NULL
dummy <- lapply(colnames(train), function(col){
  h <- h2o.hist(train[,col], breaks=30, plot = FALSE)
  plot(h, main = col, xlab = "", ylim = ylim,
    ylab = ifelse(col %in% c("X1","X6"), "Frequency", ""),
    cex.lab=2.0, cex.axis=2.0, cex.main=2.5, cex.sub=2.0, cex=2.0
    )
  })


# If curious, here is how it looks on all data
dummy <- lapply(colnames(data), function(col){
  h <- h2o.hist(data[,col], plot = FALSE)
  plot(h, main = col, xlab = "", ylim = ylim)
  })






