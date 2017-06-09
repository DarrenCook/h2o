plotBuildingEnergy = function(p, test, forPrint = FALSE, imagePath = "", imageName = ""){

if(forPrint){
  png(paste0(imagePath,"plot2.building_energy_results.",imageName,".png"),width=1600,height=1200)
  upcol = downcol = closecol = "black"  #For print
  }else{
  upcol="red";downcol="red";closecol="blue"
  }
    
z1 = as.vector(test[,y])
z2 = as.vector(p$predict)
z3 = z2 / z1

cat(nrow(test), "samples: ",sum((z3 <= 0.92))," notably low, ",sum(z3>=1.08)," notably high\n")

if(forPrint){
  z1 = z1[1:75]
  z2 = z2[1:75]
  z3 = z3[1:75]
  cat("On 75 subset: ",sum((z3 <= 0.92))," notably low, ",sum(z3>=1.08)," notably high\n")
  xlim = c(0, 80)
  xaxp = c(0,80,8)
}else{
  xlim = c(0, 150)
  xaxp = c(0,150,15)
  }
    
par(mar=c(5.1,5.1,4.1,3.1))  #Added 1.0 to left and right  (2nd and 4th numbers)

zx = 1:length(z1)
plot(zx, z1, pch=20, ylab="Y2", xlab="index", frame.plot=FALSE, ylim=c(0,50), xlim=xlim, xaxs="i", xaxp = xaxp, yaxs="i", cex=1.8, cex.lab=1.8, cex.axis=1.8, cex.main=1.8, cex.sub=1.8)

if(forPrint){
  grid(nx=8, ny=5)
}else{
  grid(nx=15, ny=5)
  }

ix = (z3 <= 0.92)
points(zx[ix], z2[ix], pch=25, col=upcol,cex=2.8)

ix = (z3 >= 1.08)
points(zx[ix], z2[ix], pch=24, col=downcol,cex=2.8)

ix = (z3 > 0.92 & z3 < 1.08)
points(zx[ix], z2[ix], pch=22, col=closecol,cex=2.5)

if(forPrint)dev.off()
}
