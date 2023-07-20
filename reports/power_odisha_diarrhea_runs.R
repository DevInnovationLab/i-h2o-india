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

MDEdia <- .25
nrounds <- 3 # how many rounds to you want to collect
ICCval <- .0135 # just for the plugin formula
indiv_sd <- .5 # the standard deviation is mean inflating (pushes up the baseline PR, has to do with the inverse logit) - that's why I decided to rescale
# SD of .5 gives same power as formula for both ICC = 0 and ICC = 0.02
indiv_ar <- .5

clus_sd <- 0.4 # with 1 round: .5 was the value that i initially had to get roughly an ICC of .014, .7 gave .03 but with inflated base rate | .6 gave 0.022 - slightly inflate base rate | .55 gave 0.018 | .575 gave .0208
# .4 gave ICC of 0.01
# SCENARIO ICC 0: clussd: 0 indivsd: .5 ... POWER 59, indivsd: 1, POWER 58
# SCENARIO ICC 0.02 clussd: .575 indivsd: .5
# SCENARIO ICC 0.01 clussd: .4 individsd: .5 ... POWER 40 (instead of 32 acc to formula)

# zero ICC benchmark case has to fit this power:
clusterPower::cpa.binary(nsubjects = nJ,
                         nclusters = nV/2,
                         CV = 1,
                         ICC = 0,
                         p1 = p_diar,
                         p2 = p_diar * (1-MDEdia),
                         tol = .Machine$double.eps^.5)


gen_binary_rounds <- function(run_n, nV, nJ, p_diar, MDEdia, nrounds, indiv_sd, indiv_ar, clus_sd) {
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
    vil_frame_sim$err <- c(sapply(1:(nV*nJ), function(x) {arima.sim(list(order=c(1,0,0), ar=indiv_ar), n = nrounds, sd = indiv_sd)}))
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
  if(nrounds > 1) { # this allows me to build on top of the round with an AR process
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
  runframe <- tibble(runid = 1,
                         pointest = NA, tstat = NA,
                         pointest1 = NA, tstat1 = NA,
                         cor12 = NA, cor23 = NA,
                         meantr = NA, meanctrl = NA,
                         ICC = NA, count_vec = NA)

  # run the regression, cluster at treatment assignment level to get SEs right
  # ... no block randomization (don't know how much variation we would explain with a block FE as of now anyways)
  i <- 1 # this is a legacy index from the loopy start, quick patch for now
  regobj <- summary(fixest::feols(diarrhea ~ tr | round, data = vil_frame_sim), vcov = ~ vilid + childid)
  runframe$pointest[i] <- regobj$coeftable[1,1] # point estimate
  runframe$tstat[i]    <- regobj$coeftable[1,3] # tstat
  regobj <- summary(fixest::feols(diarrhea ~ tr | round, data = vil_frame_sim))
  runframe$pointest1[i] <- regobj$coeftable[1,1] # point estimate
  runframe$tstat1[i]    <- regobj$coeftable[1,3] # tstat
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
  return(runframe)
}



store <- bind_rows(lapply(1:100, function(x)
  gen_binary_rounds(x, nV = nV, nJ = nJ, p_diar = p_diar, MDEdia = MDEdia, nrounds = 3, indiv_sd = .5, indiv_ar = .1, clus_sd = clus_sd)))
# checks
store$meanctrl |> mean()
store$ICC |> mean()
mean(abs(store$tstat) > 1.96) # power

