# this file simulates binary outcomes for multiple rounds
# the original report is in the "power_odisha_phas1_diarrhea.Rmd"
# this small .R file just hosts the (multithreaded?) version of the main simulations in that .Rmd
# ... initially we started of with a loop to make it easier to debug, here this loop gets translated into a function

# JULY 20th on Pickering slack:
# Hi Alex, I know your were coordinating with Akanksha to responding to MK, but I think we can play around with the power calcs and add that to the response. I discussed with him and it would like to see the tradeoffs between relying on frequent data collection vs X times the sample size. Would you be able to tell us which is the required NUMBER of villages for the following scenarios (an excel table with all combination would be helpful as a reference)
# 1 data collection at 24 months vs 3 data collections at 12-18-24
# ICC 0.02 and 0.01 (I agree on trying a couple)
# MDE 10% or 20% (MK wants less than 25%, lets give some scenarios to understand what is feasible)
# U5 children per village 30 or 50
# No block randomization (which I think it is the assumption now?)
# Even if you can do those quickly in stata and share the code that is helpful so we can modify things ourselves. Thansks a lot!

rm(list = ls()) # just to make sure we start from scratch and didn't carry over stored values from the notebooks
library(tidyverse); library(future.apply)#; library(parallel)
# some functions to start

#' Logit
#' @param x numeric
#' @return
#' @export
logit <- function(x) log(x/(1-x))

#' Inverse logit
#' @param x numeric
#' @return
#' @export
inv_logit <- function(x) {exp(x)/(1+exp(x))}
# THIS IS JUST plogis()



# takes in vector, calculates mean, rescales by the difference in means (only works for + at this stage because that's the direction the plogis transformation pushes the normal with mean 0)
rescale_pr <- function(x, pr) {
  if(length(pr) > 1) stop("probability to rescale on has to be of length 1")
  rescale_diff <- mean(x) - pr
  #if (rescale_diff < 0) stop("rescale difference has to be greater than 0")
  if (rescale_diff < 0) rescale_diff <- 0 # nothing happens if the rescale is negative bc it was inflated
  new_x <- x - rescale_diff # return new vector of probabilities
  #if (min(new_x) < 0) stop("probabilities cannot be negative")
  # just don't return them in case some probabilities are negative - not the cleanest fix but will not matter on agg
  #if (min(new_x) < 0) {return(x)} else {return(new_x)}
  # yet another iteration: make the VERY few negative probabilities to 0!
  new_x[new_x < 0] <- 0
  return(new_x)
}

nV <- 100 # number of villages
nJ <- 50 # cluster size - COULD bake in variation in cluster size to match a CV
p_diar <- .05

MDEdia <- .2
nrounds <- 3 # how many rounds to you want to collect
ICCval <- .0135 # just for the plugin formula
indiv_sd <- .5 # the standard deviation is mean inflating (pushes up the baseline PR, has to do with the inverse logit) - that's why I decided to rescale
# SD of .5 gives same power as formula for both ICC = 0 and ICC = 0.02
indiv_ar <- .5

clus_sd <- 0.425 # with 1 round: .5 was the value that i initially had to get roughly an ICC of .014, .7 gave .03 but with inflated base rate | .6 gave 0.022 - slightly inflate base rate | .55 gave 0.018 | .575 gave .0208
# .4 gave ICC of 0.01
# SCENARIO ICC 0: clussd: 0 indivsd: .5 ... POWER 59, indivsd: 1, POWER 58
# SCENARIO ICC 0.02 clussd: .575 (to get ICC 0.0202) indivsd: .5 - better go to .1
# SCENARIO ICC 0.01 clussd: .4 individsd: .5 ... POWER 40 (instead of 42 acc to formula) - better go to .425 and indiv sd .1 as above
# VERDICT: AL suggests we settle with .425 and .575 (both indiv sd .1)
# ... for the ICC 0.01 case we overshoot by maybe 0.5 percentage points (i.e. 0.05 in the power output number)
# ... for the ICC 0.02 we undershoot power by c. 3 percentage points

# zero ICC benchmark case has to fit this power:
clusterPower::cpa.binary(nsubjects = 30,
                         #nclusters = 250/2,
                         power = .9,
                         CV = 0,
                         ICC = 0.01,
                         p1 = p_diar,
                         p2 = p_diar * (1-MDEdia),
                         tol = .Machine$double.eps^.5)

# FROM WITOLD ON JULY24th
sums <- function(p, r) {p*(1 - (1-p)^r)/(1 - (1-p))}
n <- 3
2*clusterPower::cpa.binary(nsubjects = 50, # average clustersize
                           CV = 0, # no variation in clustersize assumed
                           power = .90, # desired power
                           ICC = 0.02,
                           p1 = sums(0.05, n), # diarrhea incidence of 5%
                           p2 = sums(0.05, n) * (1 - 0.20)) # MDE of 20%




# run_n gets eliminated here, nV to first (the clustersize)
gen_binary_rounds <- function(nV, MDEdia, nJ, clus_sd, p_diar, nrounds, indiv_sd, indiv_ar) {
  # moved MDE and avg clustersize on 2nd position to have it right for the nested lapply default
  vil <- rep(1:nV, each = nJ) # creating cluster variable
  vil_frame_sim <- data.frame(childid = 1:(nV*nJ), vilid = as.factor(vil))
  # assign treated
  treated <- sample(1:nV, nV/2)
  vil_frame_sim$tr <- ifelse(vil_frame_sim$vilid %in% treated, 1, 0)
  # Original binary vector, split for treated / untreated
  vil_frame_sim$round <- NA
  # replicate frame to match number of rounds
  vil_frame_sim <- bind_rows(replicate(nrounds, vil_frame_sim, simplify = FALSE))
  vil_frame_sim$round <- rep(1:nrounds, each = nV*nJ)
  # MDE reduction
  p_diartr <- p_diar * (1 - MDEdia)
  vil_frame_sim$diarrhea <- NA

  # ----------------------------------------------------------------------------
  # INDIVIDUAL LEVEL probabilities
  # 1st way would be to model the full dataframe rightaway rep(frame, n-period), this would allow model the AR1 process directly in one go ... c(sapply(1:n_obs, function(x) {arima.sim(list(order=c(1,0,0), ar=gamma), n=n_periods
  # 2nd way chosen here:
  # ... expand data period by period (this allowed to explore different ICC sampling strategies in the beginning)
  # ...
  # n_ctr <- nV*nJ/2 # dump later
  # n_tr  <- nV*nJ/2 # dump later
  ## INDIVIDUAL LEVEL EFFECT
  if (nrounds == 1) { # if only one round, we just draw from normal one time
    #indiv_e <- data.frame(err = rnorm(nV*nJ, 0, indiv_sd), round = 1) # individual level error - has to be somewhat small
    vil_frame_sim$err <- rnorm(nV*nJ, 0, indiv_sd) # having the error in the vilframe makes it easier to subset by round below
  } else { # model the AR1 process, replicate the AR1 process over nrounds nobs (i.e. nV*nJ) times
    #vil_frame_sim$err <- c(sapply(1:(nV*nJ), function(x) {arima.sim(list(order=c(1,0,0), ar=indiv_ar), n = nrounds, sd = indiv_sd)}))
    #vil_frame_sim$err <- rnorm(nV*nJ*nrounds, 0, indiv_sd) # just having no autocorr at all to speed up the benchmark
    # ALTERNATIVE: every i gets the same error in every t or (rather round r) 
    # ... this works as expected and kills all the power essentially
    errindiv <- rnorm(nV*nJ, 0, indiv_sd)
    vil_frame_sim$err <- errindiv[vil_frame_sim$childid]
  }
  ## CLUSTER LEVEL EFFECT (to model ICC)
  clust_e <- rnorm(nV, 0, clus_sd) # random effect (.5 gave an ICC of .015-.02)
  b1      <- 1 # keep it 1 if you dont want to scale up
  # add a random effect / cluster component + an error term (can switch off by setting the rnorm 0,0)
  # rewrote to have a logit here and the pr (from the plogis/inv_logit transformation) inside the rbinom
  # ... so that I can introduce an AR1 process easier
  logit_ctr   <- logit(p_diar) + b1*clust_e[vil_frame_sim$vilid[vil_frame_sim$tr == 0]]
  logit_ctr_1 <- logit_ctr + vil_frame_sim$err[vil_frame_sim$round == 1 & vil_frame_sim$tr == 0]
  resc_p_ctr_1 <- rescale_pr(inv_logit(logit_ctr_1), p_diar) # rescale s.t. the mean prob is the correct diar prob, see in the appendix why and how inv_logit inflates the mean of the cluster error
  # treatment probabilities
  logit_tr    <- logit(p_diartr) + b1*clust_e[vil_frame_sim$vilid[vil_frame_sim$tr == 1]]
  logit_tr_1  <- logit_tr + vil_frame_sim$err[vil_frame_sim$round == 1 & vil_frame_sim$tr == 1]
  resc_p_tr_1 <- rescale_pr(inv_logit(logit_tr_1), p_diartr) # rescale s.t. the mean prob is the correct diar prob, see in the appendix why and how inv_logit inflates the mean of the cluster error

  vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
                           vil_frame_sim$round == 1] <- rbinom((nV*nJ)/2, 1, resc_p_ctr_1)# inv_logit(logit_ctr_1))
  vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
                           vil_frame_sim$round == 1] <- rbinom((nV*nJ)/2, 1, resc_p_tr_1)# inv_logit(logit_tr_1))

  # ----------------------------------------------------------------------------
  # POPULATION LEVEL with ICCbinary
  # vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
  #                          vil_frame_sim$round == 1] <- fabricatr::draw_binary_icc(p_diar, clusters = vil_frame_sim$vilid[vil_frame_sim$tr == 0], ICC = ICCval)
  # vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
  #                          vil_frame_sim$round == 1] <- fabricatr::draw_binary_icc(p_diartr, clusters = vil_frame_sim$vilid[vil_frame_sim$tr == 1], ICC = ICCval)

  # ICCBIN APPROACH:
  # vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
  #                          vil_frame_sim$round == 1] <- ICCbin::rcbin(prop = p_diar, prvar = 0, noc = nV, csize = nJ, csvar = 0, rho = ICCval)$y
  # vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
  #                          vil_frame_sim$round == 1] <- ICCbin::rcbin(prop = p_diartr, prvar = 0, noc = nV, csize = nJ, csvar = 0, rho = ICCval)$y

  # ----------------------------------------------------------------------------
  # assign diarrhea cases - "population level", i.e. just 0,1 draws according to the probabilities
  # vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
  #                          vil_frame_sim$round == 1] <- sample(c(0, 1), prob = c(1-p_diar, p_diar), (nV*nJ)/2, replace = TRUE)
  # vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
  #                          vil_frame_sim$round == 1] <- sample(c(0, 1), prob = c(1-p_diartr, p_diartr), (nV*nJ)/2, replace = TRUE)
  
  # CHANGE JULY20th: break out of the loop structure for our current default case of nrounds == 3. This will save a lot of time without having to spend a lot of time rethinking the code
  if(nrounds > 30) {
    # HARDCODED FOR 2 EXTRA ROUNDS:
    # INDIVIDUAL ADDONS (with AR1 now)
    # ROUND 2
    logit_ctr_n <- logit_ctr + vil_frame_sim$err[vil_frame_sim$round == 2 & vil_frame_sim$tr == 0]
    logit_tr_n  <- logit_tr + vil_frame_sim$err[vil_frame_sim$round == 2 & vil_frame_sim$tr == 1]
    # same rescaling as above\
    resc_p_ctr_n <- rescale_pr(inv_logit(logit_ctr_n), p_diar)
    resc_p_tr_n <- rescale_pr(inv_logit(logit_tr_n), p_diartr)
    
    vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
                             vil_frame_sim$round == 2] <- rbinom((nV*nJ)/2, 1, resc_p_ctr_n) #inv_logit(logit_ctr_n))
    vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
                             vil_frame_sim$round == 2] <- rbinom((nV*nJ)/2, 1, resc_p_tr_n) #inv_logit(logit_tr_n))
    # ROUND 3 ... just overwriting the _n from above - no need to keep vector stored
    logit_ctr_n <- logit_ctr + vil_frame_sim$err[vil_frame_sim$round == 3 & vil_frame_sim$tr == 0]
    logit_tr_n  <- logit_tr + vil_frame_sim$err[vil_frame_sim$round == 3 & vil_frame_sim$tr == 1]
    # same rescaling as above\
    resc_p_ctr_n <- rescale_pr(inv_logit(logit_ctr_n), p_diar)
    resc_p_tr_n <- rescale_pr(inv_logit(logit_tr_n), p_diartr)
    
    vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
                             vil_frame_sim$round == 3] <- rbinom((nV*nJ)/2, 1, resc_p_ctr_n) #inv_logit(logit_ctr_n))
    vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
                             vil_frame_sim$round == 3] <- rbinom((nV*nJ)/2, 1, resc_p_tr_n) #inv_logit(logit_tr_n))
  } else if (nrounds > 1) { # this allows me to build on top of the round with an AR process
    for (t in 2:nrounds) {
      # ----------------------------------------------------------------------------
      # POPULATION PLAIN VANILLA
      # vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
      #                      vil_frame_sim$round == t] <- sample(c(0, 1), prob = c(1-p_diar, p_diar), (nV*nJ)/2, replace = TRUE)
      # vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
      #                          vil_frame_sim$round == t] <- sample(c(0, 1), prob = c(1-p_diartr, p_diartr), (nV*nJ)/2, replace = TRUE)
      # ----------------------------------------------------------------------------
      # POPULATION WITH ICC
      # vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
      #                      vil_frame_sim$round == t] <- fabricatr::draw_binary_icc(p_diar, clusters = vil_frame_sim$vilid[vil_frame_sim$tr == 0], ICC = ICCval)
      # vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
      #                      vil_frame_sim$round == t] <- fabricatr::draw_binary_icc(p_diartr, clusters = vil_frame_sim$vilid[vil_frame_sim$tr == 1], ICC = ICCval)
      # ----------------------------------------------------------------------------
      # INDIVIDUAL ADDONS (with AR1 now)
      logit_ctr_n <- logit_ctr + vil_frame_sim$err[vil_frame_sim$round == t & vil_frame_sim$tr == 0]
      logit_tr_n  <- logit_tr + vil_frame_sim$err[vil_frame_sim$round == t & vil_frame_sim$tr == 1]
      # same rescaling as above\
      resc_p_ctr_n <- rescale_pr(inv_logit(logit_ctr_n), p_diar)
      resc_p_tr_n <- rescale_pr(inv_logit(logit_tr_n), p_diartr)

      vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 &
                               vil_frame_sim$round == t] <- rbinom((nV*nJ)/2, 1, resc_p_ctr_n) #inv_logit(logit_ctr_n))
      vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 &
                               vil_frame_sim$round == t] <- rbinom((nV*nJ)/2, 1, resc_p_tr_n) #inv_logit(logit_tr_n))
    }
  }
  # create the container to store results ... tibble so we can bind_rows afterwards
  runframe <- tibble(runid = 1, MDE = MDEdia, nclusters = nV, clusize = nJ,
                         pointest = NA, tstat = NA,
                         pointest1 = NA, tstat1 = NA,
                         pointest2 = NA, tstat2 = NA,
                         cor12 = NA, cor23 = NA, rho_est = NA,
                         meantr = NA, meanctrl = NA,
                         ICC = NA, count_vec = NA,
                         diarh_count = NA, perc_ever_tr = NA, perc_ever_ctr = NA,
                         uniquechild = NA)

  # run the regression, cluster at treatment assignment level to get SEs right
  # ... no block randomization (don't know how much variation we would explain with a block FE as of now anyways)
  i <- 1 # this is a legacy index from the loopy start, quick patch for now
  regobj <- summary(fixest::feols(diarrhea ~ tr | round, data = vil_frame_sim), vcov = ~ vilid + childid)
  runframe$pointest[i] <- regobj$coeftable[1,1] # point estimate
  runframe$tstat[i]    <- regobj$coeftable[1,3] # tstat
  regobj_raw <- fixest::feols(diarrhea ~ tr | round, data = vil_frame_sim)
  regobj     <- summary(regobj_raw)
  runframe$pointest1[i] <- regobj$coeftable[1,1] # point estimate
  runframe$tstat1[i]    <- regobj$coeftable[1,3] # tstat
  # no childid clustering
  regobj <- summary(fixest::feols(diarrhea ~ tr | round, data = vil_frame_sim), vcov = ~ vilid)
  runframe$pointest2[i] <- regobj$coeftable[1,1] # point estimate
  runframe$tstat2[i]    <- regobj$coeftable[1,3] # tstat
  
  # AUTOCORRELATION
  vil_frame_sim$err     <- regobj_raw$residuals
  runframe$rho_est[i]   <- lm(err ~ -1 + lag(err), data = vil_frame_sim)$coefficients[[1]]
  #cat("done with run ", i)
  # some other info
  if (nrounds > 1) {
    runframe$cor12[i] <- cor(vil_frame_sim$diarrhea[vil_frame_sim$round == 1], vil_frame_sim$diarrhea[vil_frame_sim$round == 2])
    runframe$cor23[i] <- cor(vil_frame_sim$diarrhea[vil_frame_sim$round == 2], vil_frame_sim$diarrhea[vil_frame_sim$round == 3])
  }
  # we want to have the means here so we can check if the inflation problem is there or not
  runframe$meantr[i]   <- vil_frame_sim$diarrhea[vil_frame_sim$tr == 1 & vil_frame_sim$round == 1] |> mean()
  runframe$meanctrl[i] <- vil_frame_sim$diarrhea[vil_frame_sim$tr == 0 & vil_frame_sim$round == 1] |> mean()

  # take care of the warning
  #runframe$ICC[i] <- ICC::ICCest(vilid, diarrhea, data = vil_frame_sim)$ICC
  runframe$ICC[i] <- fixest::r2(fixest::feols(diarrhea ~ 0 | vilid, data = vil_frame_sim), "ar2")

  # store the vector of counts so we can check if they are poisson (they are from what I saw)
  diarrh_counts <- vil_frame_sim |> group_by(vilid) |> summarise(diarrh_n = sum(diarrhea))
  runframe$count_vec[i] <- list(diarrh_counts$diarrh_n)
  
  # store the info on diarrhea counts per child
  vil_frame_sim <- vil_frame_sim |> group_by(childid) |> mutate(diarrhea_count = sum(diarrhea, na.rm = T))
  # how many % of children ever got diarrhea?
  vil_frame_sim$diarrhea_ever <- ifelse(vil_frame_sim$diarrhea_count > 0, 1, 0) # assign a 1 if a child ever had diarrhea at some point
  vil_frame_unique       <- vil_frame_sim[!duplicated(vil_frame_sim$childid), ] # do not doublecount the children (you mutated above!!)
  
  # store!
  runframe$diarh_count[i]   <- list(vil_frame_unique$diarrhea_count)
  #runframe$vilid[i]         <- list(vil_frame_unique$vilid) # added 23-11-13
  runframe$perc_ever_tr[i]  <- mean(vil_frame_unique$diarrhea_ever[vil_frame_unique$tr == 1])
  runframe$perc_ever_ctr[i] <- mean(vil_frame_unique$diarrhea_ever[vil_frame_unique$tr == 0])
  runframe$uniquechild[i]   <- nrow(vil_frame_unique) # or just nV*nJ
  
  # 23-11-13 info for WW - comment this out for the runs after, slows down
  # obj <- lme4::glmer(diarrhea_count ~ 0 + (1|vilid), data = vil_frame_unique, family = binomial(link = "logit"))
  # runframe$glmerREsd[i] <- as.data.frame(lme4::VarCorr(obj))$sdcor
  
  return(runframe)
}

# indiv .1 - ICC 001 and 002: clus_sd .425 .575
# indiv .5 - .395 .53

indiv_sd <- .1
# replicate the same villagenumber nruns times to check speed and if we are on spot powerwise
# 150 was the original one - no 100, and I said 3 runs without ICC and AR gave 95% and with ICC 0.01 we get roughly 80%
clus_sd <- .425
nrounds <- 1
nruns <- 1000
store <- bind_rows( # first argument of rep is the number of clusters
  lapply(rep(50, nruns), function(nvil)
    gen_binary_rounds(nvil, nJ = 150, p_diar = p_diar, MDEdia = MDEdia, nrounds = nrounds, indiv_sd = indiv_sd, indiv_ar = indiv_ar, clus_sd = clus_sd))
  )
# checks
#store <- replicate(50, gen_binary_rounds(nV = nV, nJ = nJ, p_diar = p_diar, MDEdia = MDEdia, nrounds = 1, indiv_sd = indiv_sd, indiv_ar = indiv_ar, clus_sd = clus_sd)) #|> bind_rows()
store$meanctrl |> mean()
store$meantr |> mean()
store$ICC |> mean()
store$cor12 |> mean()
store$cor23 |> mean()
store$rho_est |> mean()

store$ICC |> summary()
store$glmerREsd |> summary()

mean(abs(store$tstat) > 1.96) # power
mean(abs(store$tstat1) > 1.96) # power
mean(abs(store$tstat2) > 1.96) # power

# how many do ever get diarrhea
store$perc_ever_tr |> mean()
store$perc_ever_ctr |> mean()
# compare with WW sum of series
sums(.05*(1-MDEdia), nrounds); sums(.05, nrounds)

# counts
store$diarh_count[[11]] |> table() / store$uniquechild[[11]]

# ww sum of series
n <- 3
2*clusterPower::cpa.binary(nsubjects = 50, # average clustersize
                           #nclusters = 230/2,
                           CV = 0, # no variation in clustersize assumed
                           power = .80, # desired power
                           ICC = 0.02,
                           p1 = sums(0.05, n), # diarrhea incidence of 5%
                           p2 = sums(0.05, n) * (1 - 0.20)) # MDE of 20%


clusterPower::cpa.binary(nsubjects = 50,
                         nclusters = 200/2,
                         #power = .9,
                         CV = 0,
                         ICC = 0.01,
                         p1 = p_diar,
                         p2 = p_diar * (1-MDEdia),
                         tol = .Machine$double.eps^.5)

# sum of series formula to simplistic: nclusters 230

# CHECKS for WW 2023 NOVEMBER 13th
# df <- data.frame(vilid = store[1, ]$vilid,
#                  diarh = store[1, ]$diarh_count)
# names(df) <- c("vilid", "diarh")
# df <- df |> group_by(vilid) |> mutate(baseline = mean(diarh))
# df$baseline <- p_diar
# obj <- lme4::glmer(diarh ~ 1 + (1|vilid), data = df, family = binomial(link = "logit"))
# obj |> summary()
# lme4::VarCorr(obj)

# ---------------------------------------------------------------------------------
# NOW START THE MULTILAYERED runs
# ... we do it in two instances for the ICC (specifying the clus_sd) because the actual ICC value never comes out as 0.01, so it is hard to categorize (without doing something within the lapplies - which is something I want to avoid)
nrounds <- 3
clus_sds <- c(.425, .575)
vilsizes <- c(30, 50)
MDEs <- c(.2, .1)
vilsizevec1 <- seq(500, 1000, by = 100)
vilsizevec <- seq(50, 475, by = 25)
vilsizevec <- c(vilsizevec, vilsizevec1)
nruns <- 1000 # how many iterations per villagesize?
# if you want to switch back to single-threading, remove the "future_" and the ", future.seed = TRUE" at the end of the applies
store <- lapply(rep(vilsizevec, each = nruns), function(nvil) {
           lapply(MDEs, function(MDE) {
             lapply(vilsizes, function(vilsize) {
                gen_binary_rounds(nvil, MDE, vilsize, clus_sd = clus_sds[[1]], p_diar = p_diar, nrounds = nrounds, indiv_sd = indiv_sd, indiv_ar = indiv_ar)
             }) # close inner lapply (vilsizes)
           }) # close middle lapply
         })#, future.seed = TRUE) # close outer lapply - FOR PARALLEL FUTURE function we need future.seed = T
# SECOND ICC VALUE
stor1 <- lapply(rep(vilsizevec, each = nruns), function(nvil) {
           lapply(MDEs, function(MDE) {
             lapply(vilsizes, function(vilsize) {
                gen_binary_rounds(nvil, MDE, vilsize, clus_sd = clus_sds[[2]], p_diar = p_diar, nrounds = nrounds, indiv_sd = indiv_sd, indiv_ar = indiv_ar)
             }) # close inner lapply (vilsizes)
           }) # close middle lapply
         })#, future.seed = TRUE) # close outer lapply - FOR PARALLEL FUTURE function we need future.seed = T


store_flat <- purrr::flatten(store) # now with the THIRD layer of applies, we need to flatten out one level because we have lists of list of lists now and we want lists of lists
store <- bind_rows(store_flat)
store$MDE <- as.factor(store$MDE)
# finally, compute power for every run (mutate instead of summarize and then merge with the storeframe)
storesummary <- store |> group_by(nclusters, MDE, clusize) |> summarise(power = mean(abs(tstat) > 1.96),
                                                                        cor12 = mean(cor12))
storesummary$ICC <- 0.01 |> as.factor() # override ICC to have categorical
# DO THAT ALSO SEPARATELY FOR THE SECOND ONE - bit ugly, I know
store_fla1 <- purrr::flatten(stor1) # now with the THIRD layer of applies, we need to flatten out one level because we have lists of list of lists now and we want lists of lists
stor1 <- bind_rows(store_fla1)
stor1$MDE <- as.factor(stor1$MDE)
# finally, compute power for every run (mutate instead of summarize and then merge with the storeframe)
storesummar1 <- stor1 |> group_by(nclusters, MDE, clusize) |> summarise(power = mean(abs(tstat) > 1.96),
                                                                        cor12 = mean(cor12))
storesummar1$ICC <- 0.02 |> as.factor() # override ICC to have categorical

storesummary <- bind_rows(storesummary, storesummar1)



write_rds(storesummary, file = "/Users/alexanderlehner/Library/CloudStorage/GoogleDrive-ax.lehner@gmail.com/My Drive/Uni/Work/[1]DIL/i-h20-india/reports/powerruns_stored/sim_3rounds_allvalues_2ICC2MDE2vilsize_NoAR1_1kruns_finervillagejumps.RDS")
#write_rds(storesummary, file = "reports/powerruns_stored/sim_1round_allvalues_2comparewithformulaoutput.RDS")



ggplot(storesummary, aes(x = nclusters, y = power, 
                       #col = interaction(ICC, MDE, sep = ' - '),
                       col = MDE,
                       #shape = interaction(MDE, ICC, sep = ' - '),
                       shape = ICC,
                       #linetype = interaction(MDE, ICC, sep = ' - '),
                       linetype = MDE,
)) + 
  geom_point() + geom_line() + facet_wrap(~ clusize, nrow = 2, scales = "free") +
  ggtitle("Power for total number of villages, avg size: 30") +
  theme_bw() #+
  #guides(colour = guide_legend(override.aes = list(shape = NA))) +
  #labs(colour="MDE", shape="ICC") +# scale_color_DIL() +
  #scale_x_continuous(name = "Number of villages", limits = seq(50, 900, by = 50)) + 
  #scale_y_continuous(name = "power", limits = seq(0, 1, by = .1), expand = c(0.05,0.1)) # shrink default expansion (0.6 for discrete) 

p

