source("load_football_2013_2014.R")

# This is a customized version of the one shown in the R docs.
panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
usr <- par("usr"); on.exit(par(usr))
par(usr = c(0, 1, 0, 1))
r <- cor(x, y, use = "complete.obs")
txt <- format(c(r, 0.123456789), digits = digits)[1]
txt <- paste0(prefix, txt)
if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
text(0.5, 0.5, txt, cex = cex.cor * (r-0.80) *5 )
}

panel.cor2 <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
usr <- par("usr"); on.exit(par(usr))
par(usr = c(0, 1, 0, 1))
#r <- round(cor(x, y, use="complete.obs", method = "pearson"), 2)
r <- round(cor(x, y, use="complete.obs", method = "spearman"), 2)
txt <- format(c(r, 0.123456789), digits = digits)[1]
txt <- paste0(prefix, txt)
if(missing(cex.cor)){
  if(r<0)cex.cor <- 0.8/strwidth(txt)
  else cex.cor <- 0.8/strwidth(paste0("+",txt))  #Allow for lack of minus sign
  }
text(0.5, 0.5, txt, cex = cex.cor * ifelse(abs(r)<0.5,0.5,abs(r)) )
}

panel.cor3 <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
usr <- par("usr"); on.exit(par(usr))
par(usr = c(0, 1, 0, 1))
r <- round(cor(x, y, use="complete.obs", method = "pearson"), 2)
#r <- round(cor(x, y, use="complete.obs", method = "spearman"), 2)
txt <- format(c(r, 0.123456789), digits = digits)[1]
txt <- paste0(prefix, txt)
if(missing(cex.cor)){
  if(r<0)cex.cor <- 0.8/strwidth(txt)
  else cex.cor <- 0.8/strwidth(paste0("+",txt))  #Allow for lack of minus sign
  }
text(0.5, 0.5, txt, cex = cex.cor * (0.4 + abs(r)) )
}


panel.cor4 <- function(x, y, digits = 2, prefix = "", cex.cor, ...)
{
usr <- par("usr"); on.exit(par(usr))
par(usr = c(0, 1, 0, 1))
#r <- round(cor(x, y, use="complete.obs", method = "pearson"), 2)
r <- round(cor(x, y, use="complete.obs", method = "spearman"), 2)
txt <- format(c(r, 0.123456789), digits = digits)[1]
txt <- paste0(prefix, txt)
if(missing(cex.cor)){
  if(r<0)cex.cor <- 0.8/strwidth(txt)
  else cex.cor <- 0.8/strwidth(paste0("+",txt))  #Allow for lack of minus sign
  }
text(0.5, 0.5, txt, cex = cex.cor * ifelse(abs(r)<0.5,0.5,0.75) )
}

#Download data and remove NA rows
d <- as.matrix(betsD)
d <- d[complete.cases(d),]
cor(d)

#Compare the draw-odds
pairs(d, lower.panel = panel.smooth, upper.panel = panel.cor)

#Just show 5, not all 10, to keep it manageable.
#Also lose the x/y labels and tick marks.
pairs(d[,c(3:6,10)], lower.panel = panel.smooth, upper.panel = panel.cor, xaxt = "n", yaxt = "n")

# Check-out the outlier in IWD
d <- as.data.frame(data)
d[which.min(d$IWD), c('B365D', 'BWD', 'IWD', 'LBD', 'PSD', 'WHD', 'SJD', 'VCD')]

#     B365D BWD IWD LBD  PSD WHD SJD VCD
# 398   3.5 3.3 2.1 3.4 3.49 3.1 3.2 3.5

# The abets correlations
d <- as.matrix(abets)
d <- d[complete.cases(d),]
round( cor(d), 2)
round( cor(d, method = "spearman"), 2)
pairs(d, labels = colnames(d), lower.panel = panel.smooth, upper.panel = panel.cor2, xaxt = "n", yaxt = "n")

#Just first 5 columns

pairs(d[,colnames(d)[1:5]], labels = colnames(d), lower.panel = panel.smooth, upper.panel = panel.cor2, xaxt = "n", yaxt = "n")



# And the match statistics
pairs(stats, lower.panel = panel.smooth, upper.panel = panel.cor3)
v <- cor(as.matrix(stats))
summary(v)

#
d <- as.numeric(data[,c("FTR", "BbAvH", "BbAHh")])
round( cor(as.matrix(d), use = "complete.obs"), 3)
round( cor(as.matrix(d), use = "complete.obs", method = "spearman"), 3)

pairs(data[,c("FTR", "BbAvH", "BbAHh")], lower.panel = panel.smooth, upper.panel = panel.cor4)

