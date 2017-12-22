seed = 999

source("load.building_energy.R")
source("makeplot.building_energy_results.R")


###
# For the first grid I wanted to try solver, family and link, but none of those three
# are supported for grids! So, we do it with lapply loops.

solvers=c("IRLSM", "L_BFGS", "COORDINATE_DESCENT_NAIVE", "COORDINATE_DESCENT")
families = c("gaussian", "poisson", "gamma")  #"tweedie" excluded, and "binomial" is meaningless. Left multinomial in deliberately to see what happens... what happens is I get an error: "Multinomial requires a categorical response with at least 3 levels (for 2 class problem use family=binomial"
gaussianLinks = c("identity", "log", "inverse")  #No logit
poissonLinks = c("log")  #"identity" gave assertionError about "likelihoods don't match, 623.404217682865 != 623.4042176828657" (that was with IRLSM, at least). However, apparently only "Only log and identity links are allowed for family=poisson.", so that only leaves us with log. TODO: try identity with other solvers.
gammaLinksA = c("identity", "log", "inverse")  #logit not allowed for gamma
gammaLinks_COORDINATE_DESCENT = c("identity", "log")  #"inverse" gives "likelihoods don't match, 22.960248757111188 != 8.315068614668444" assertion (though only for "COORDINATE_DESCENT" solver - the others seem ok)

system.time(
allGrids <- lapply(solvers, function(solver){
  lapply(families, function(family){

    #if(family=="multinomial")theLinks = c("family_default") #I.e. multinomial only matches to multinomial, but you cannot specify it, so you have to just request the default.
    #else
    if(family=="gaussian")theLinks = gaussianLinks
    else if(family=="poisson")theLinks = poissonLinks
    else{
      if(solver == "COORDINATE_DESCENT")theLinks = gammaLinks_COORDINATE_DESCENT
      else theLinks = gammaLinksA
      }
    
    lapply(theLinks, function(link){
      grid_id = paste("GLM",solver,family,link,sep="_")
      cat("GRID:",grid_id,"\n")
      h2o.grid("glm", grid_id=grid_id,
        hyper_params = list(
          alpha = c(0, 0.1, 0.5, 0.99)   #This is the ratio of L1 and L2 (0.99 is recommended instead of 1.0)
          ),
        x=x, y=y, training_frame=train,
        nfolds = 10,
        lambda_search = TRUE,  #Easier than guessing a lambda
        
        solver = solver,
        family = family,
        link = link,

        max_iterations = 100  #Double the default
        )
      })
    })
  })
)  

#The above took 77 secs

gg = unlist(allGrids)
length(gg)  #27  (and each grid has 4 models)

unlist( lapply(gg, function(g) g@failure_details) )



# grids can be list of h2o.grid objects, or grid id strings
mergeGrids <- function(grids, metric){
if(metric=="mse")decreasing = FALSE
else decreasing = TRUE

d <- do.call(rbind, lapply(grids, function(g){
  if(is.character(g))grid_id = g
  else grid_id = g@grid_id
  dd <- as.data.frame(
    h2o.getGrid(grid_id, sort_by=metric, decreasing = decreasing)
    @summary_table
    )
  dd$model_ids <- NULL
  dd = as.data.frame(lapply(dd,as.numeric))
  dd$grid_id = grid_id
  dd
  }) )

orderBy = d[,metric]
if(decreasing)orderBy = -orderBy
d[order(orderBy),]
}


mergeGrids(gg, "mse")


#####
# Now try a tweedie grid
# Thses 441 models took 661 seconds.

system.time(
g_tweedie <- h2o.grid("glm", grid_id="GLM_IRLSM_tweedie_log",
  hyper_params = list(
    tweedie_variance_power = seq(from=1.0, to=2.0, by=0.05),
    tweedie_link_power = seq(from=0.0, to=1.0, by=0.05)
    ),
  x=x, y=y, training_frame=train,
  nfolds = 10,
  lambda_search = TRUE,  #Easier than guessing a lambda
  
  solver = "IRLSM",
  family = "tweedie",
  link = "family_default",  #I.e. tweedie (specifying tweedie explicitly seems to fail!)
  alpha = 0.5,

  max_iterations = 100  #Double the default
  )
)


###
# A better tweedie analysis script
# Fewer models, wider range.
# 70 models in 95 secs


system.time(
g_tweedie4 <- h2o.grid("glm", grid_id="GLM_IRLSM_tweedie4_log",
  hyper_params = list(
    tweedie_variance_power = c(1.0, 1.25, 1.50, 1.75, 2.0, 2.33, 2.67, 3.0, 3.5, 4.0), #NB. 1.0 and 2.0 duplicate
      #tests we've already done (poisson and gamma), *except* they allow us to specify link power.
    tweedie_link_power = c(0, 0.33, 0.67, 1.0, 1.33, 1.67, 2) #NB. Not sure if >1.0 has any meaning?
    #TODO: really want to be specifying random seed here
    ),
  x=x, y=y, training_frame=train,
  nfolds = 10,
  lambda_search = TRUE,  #Easier than guessing a lambda
  
  solver = "IRLSM",
  family = "tweedie",
  link = "family_default",  #I.e. tweedie (specifying tweedie explicitly seems to fail!)
  alpha = 0.5,

  max_iterations = 100  #Double the default
  )
)


# I then ran the above 3 times (different grid ids) (this is until glm lets me build a grid using seed)
# then merged them:  (NB. d is a data frame, not a grid object)

d <- mergeGrids(c("GLM_IRLSM_tweedie2_log","GLM_IRLSM_tweedie3_log","GLM_IRLSM_tweedie4_log"), "mse")
par(mfrow = c(1, 2))
plot(d$tweedie_variance_power, d$mse)
plot(d$tweedie_link_power, d$mse)


#In Mint 17:
#  apt-get install mesa-common-dev libglu1-mesa-dev
#Then in R:
#  install.packages("rgl")
# See also: https://cran.r-project.org/web/packages/rgl/vignettes/rgl.html

par3d(FOV=0) #Make it isometric
plot3d(d$tweedie_link_power, d$tweedie_variance_power, d$mse, col=as.numeric(as.factor(d$grid_id)), size=1.5, type="s")

d2=d[d$mse<12,]  #Keep the best ones (to space out the vertical axis a bit)
par3d(FOV=0);with(d2,plot3d(tweedie_link_power, tweedie_variance_power, mse, col=as.numeric(as.factor(grid_id)), size=1.5, type="s"))
grid3d("z")

d3=d[d$mse<13 & d$tweedie_link_power<1.1,]
par3d(FOV=0);with(d3,plot3d(tweedie_link_power, tweedie_variance_power, mse, col=as.numeric(as.factor(grid_id)), size=1.5, type="s"))
grid3d("z")

#NB. for print, the best might have to be to a mean of the three values? (because three shades of grey won't show very well?)

####
# Narrow the tweedie results down a bit: finer variance and link power changes, and some different alphas
# Also run it 10 times, to get 10 grids (i.e. 10 different cross-validation runs)
# Each grid is making 96 models.
# It took about 16 minutes to make all 10 grids.

system.time(
  g_tweedies <- lapply(1:10, function(ix){
    h2o.grid("glm", grid_id=paste0("GLM_tweedie_alpha",ix),
      hyper_params = list(
        tweedie_variance_power = c(1.25, 1.30, 1.35, 1.40, 1.45, 1.50, 1.55, 1.6),
        tweedie_link_power = c(0, 0.2, 0.33, 0.4),
        alpha = c(0.33, 0.5, 0.67)
        ),
      x=x, y=y, training_frame=train,
      nfolds = 10,
      lambda_search = TRUE,  #Easier than guessing a lambda
      
      solver = "IRLSM",
      family = "tweedie",
      link = "family_default",  #I.e. tweedie (specifying tweedie explicitly seems to fail!)

      max_iterations = 100  #Double the default
      )
  })
)


### 
# Now add some grids for poisson/log, then gaussian/log, just
# a bit of experimentation with interactions, with our best two models from earlier. 
# 4 models in 8.47 seconds
# All are terrible
# Without interactions, it takes 5.3s to do 4 models. And they are way better.

system.time(
g_poisson_log_interactions <- h2o.grid("glm", grid_id = "GLM_poisson_log_interactions",
  hyper_params = list(
    alpha = c(0, 0.1, 0.5, 0.99)   #Same ones we used earlier
    ),
  x=x, y=y, training_frame=train,
  nfolds = 10,
  lambda_search = TRUE,  #Easier than guessing a lambda

  solver = "IRLSM",
  family = "poisson",
  link = "log",
  
  interactions = x,  #All of the first 8 columns
      
  max_iterations = 100  #Double the default
  )
)  


# Now the same, for gaussian
# 6.2s for 4 models. Same bad results.
system.time(
g_gaussian_log_interactions <- h2o.grid("glm", grid_id = "GLM_gaussian_log_interactions",
  hyper_params = list(
    alpha = c(0, 0.1, 0.5, 0.99)   #Same ones we used earlier
    ),
  x=x, y=y, training_frame=train,
  nfolds = 10,
  lambda_search = TRUE,  #Easier than guessing a lambda

  solver = "IRLSM",
  family = "gaussian",
  link = "log",
  
  interactions = x,  #All of the first 8 columns
      
  max_iterations = 100  #Double the default
  )
)  


 
###
# Now we make the two non-tweedie models (gaussian_log, poisson_log), 10 times,
# with just a few alpha values around 0.5. I expect 0.33 to be better than 0.5 or 0.67,
# so I've gone with 0.2, 0.3, 0.4, 0.5
# 134s for 40 models for gaussian, 113s for 40 models for poisson

system.time(
  g_gaussians <- lapply(1:10, function(ix){
    h2o.grid("glm", grid_id=paste0("GLM_gaussian_alpha",ix),
      hyper_params = list(
        alpha = c(0.2,0.3,0.4,0.5)
        ),
      x=x, y=y, training_frame=train,
      nfolds = 10,
      lambda_search = TRUE,  #Easier than guessing a lambda
      
      solver = "IRLSM",
      family = "gaussian",
      link = "log",

      max_iterations = 100  #Double the default
      )
  })
)

system.time(
  g_poissons <- lapply(1:10, function(ix){
    h2o.grid("glm", grid_id=paste0("GLM_poisson_alpha",ix),
      hyper_params = list(
        alpha = c(0.2,0.3,0.4,0.5)
        ),
      x=x, y=y, training_frame=train,
      nfolds = 10,
      lambda_search = TRUE,  #Easier than guessing a lambda
      
      solver = "IRLSM",
      family = "poisson",
      link = "log",

      max_iterations = 100  #Double the default
      )
  })
)




# TODO NEXT: Make the non-tweedie models, 10 times, with
#   a few values (but only a few this time)
#   Then merge them into the grid.
#   Then try ordering them by a few things (min, max, mean, max-min, sd) and I suspect
#   the same ones will be in the top-5 each time.


grids <- sapply(g_tweedies, function(g) g@grid_id)
dt <- mergeGrids(grids, "mse")
grids <- sapply(g_gaussians, function(g) g@grid_id)
dg <- mergeGrids(grids, "mse")
grids <- sapply(g_poissons, function(g) g@grid_id)
dp <- mergeGrids(grids, "mse")


lapply(c(mean, sd, max, min, function(x){mean(x)+sd(x)}, function(x){max(x)-min(x)}),  function(FUN){
  #This combines the 10 runs, so we end up with 96 rows
  dt2 <- aggregate(dt$mse, dt[,c("tweedie_link_power","tweedie_variance_power","alpha")], FUN)
  dt2 <- dt2[order(dt2$x),]  #MSE got renamed to 'x'
  print(head(dt2))
  
  #Combine 10 runs, so we end up with 4 rows
  dg2 <- aggregate(dg$mse, dg[,c("alpha"), drop=F], FUN)
  dg2 <- dg2[order(dg2$x),]  #MSE got renamed to 'x'
  print(dg2)
  
  #Combine 10 runs, so we end up with 4 rows
  dp2 <- aggregate(dp$mse, dp[,c("alpha"), drop=F], FUN)
  dp2 <- dp2[order(dp2$x),]  #MSE got renamed to 'x'
  print(dp2)
  
  NULL
  })  #End of the FUN lapply




# Other ways are max, min, median, and then max(x)-min(x) and this:
d2 <- aggregate(d$mse, d[,c("tweedie_link_power","tweedie_variance_power","alpha")], function(x) mean(x)+sd(x) );d2[order(d2$x),]



###
# Finally, try h2o.performance on our chosen model.

system.time(
m <- h2o.glm(
  tweedie_variance_power = 1.55,
  tweedie_link_power = 0,
  alpha = 0.33,

  x=x, y=y, training_frame=train,
  nfolds = 10,
  lambda_search = TRUE,
      
  solver = "IRLSM",
  family = "tweedie",
  link = "family_default",

  max_iterations = 100
  )
)
