import h2o
h2o.init()

data = h2o.importFolder("../datasets/england/2013-2014/")
betsH = data[ range(23, 45, 3) + [48, 49] ]  #Columns 23, 26, 29, 32, 35, 38, 41, 44, 48, 49
betsD = data[ range(24, 46, 3) + [50, 51] ]
betsA = data[ range(25, 47, 3) + [52, 53] ]
abets = data[ range(55, 59) + range(60, 65) ]
stats = data[ range(4, 10) + range(11, 23) ]
stats[ ["FTR","HTR"] ] = stats[ ["FTR","HTR"] ].asnumeric()  #Un-categorize these two columns
