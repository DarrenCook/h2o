seed = 999

source("load.building_energy.R")
source("makeplot.building_energy_results.R")

#TODO: the seed=seed arg was only added to R API as of 3.8.2.9 (2016-06-09). Once we
#  are running that version, use it, as then the 10-fold CV will become reliable.
m = h2o.glm(x, y, train, nfolds=10, model_id="GLM_defaults")  #NB. no seed param

summary(m)
h2o.performance(m, test)

p = h2o.predict(m, test, seed=seed)
p

plotBuildingEnergy(p, test, forPrint = T, "../chapters/images/", "glm")
