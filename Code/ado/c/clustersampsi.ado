program define clustersampsi,rclass

syntax  [anything] [, mu1(real -1) mu2(real -1) p1(real 0) p2(real 0) r1(real 0) r2(real 0) rho(real -1) cluster_cv(real -1)  m(integer -1) size_cv(real 0) k(integer -1) sd1(real 1) sd2(real 1) beta(real 0.8) alpha(real 0.05) base_correl(real 0) samplesize power binomial rates detectabledifference]

* ALLERTING USER TO INCOMPLETE FUNCTION SPECIFICATION ###############################################################################################################

if("`power'"=="" & "`detectabledifference'"==""){
local samplesize="samplesize"
}

if("`rates'"~=""){
local normal="normal"
}

/*** Redundant Parameters (note: does not pick up redundant parameters which are set at default values)***/
if("`binomial'"~=""){
if(`sd1'!=1 | `sd2'!=1 | `mu1'!=-1 | `mu2'!=-1 | `r1'!=0 | `r2'!=0){
disp in red "Warning: redundant parameters specified: don't need mean or rate parameters for a proportion calculation."
exit 198
}
}
if("`binomial'"==""){
if(`p1'!=0 | `p2'!=0){
disp in red "Warning: redundant parameters specified: don't need proportion parameters for a mean or rate calculation."
exit 198
}
}
if("`rates'"~=""){
if(`sd1'!=1 | `sd2'!=1 | `mu1'!=-1 | `mu2'!=-1| `p1'!=0 | `p2'!=0){
disp in red "Warning: redundant parameters specified: don't need mean or proportion parameters for a rate calculation."
exit 198
}
}
if("`rates'"=="" & "`binomial'"=="" ){
if(`p1'!=0 | `p2'!=0  | `r1'!=0 | `r2'!=0 ){
disp in red "Warning: redundant parameters specified: don't need proportion or rate parameters for a mean calculation."
exit 198
}
}
if (`rho'>=0 & `cluster_cv'>=0) {
	di _n as text "Warning: redundant parameters  specified: only need one of  rho or cluster_cv." 
	exit 198
	}
if("`power'"~=""){
if(`beta'!=0.8){
disp in green "Warning: redundant parameters specified: don't need to specify beta for a power calculation."
exit 198
}
}
if("`samplesize'"~=""){
if(`m'!=-1 & `k'!=-1){
disp in green "Warning: redundant parameters specified: don't need both m and k for a sample size calculation."
exit 198
}
}

if("`detectabledifference'"~=""){
if("`binomial'"==""){
if(`p2'!=0){
disp in green "Warning: redundant parameters specified: don't need p2 for a detectable difference calculation. "
exit 198
}
}
if("`rates'"==""){
if(`r2'!=0){
disp in green "Warning: redundant parameters specified: don't need r2 for a detectable difference calculation."
exit 198
}
}
if("`rates'"!="" & "`binomial'"!=""){
if(`mu2'!=-1){
disp in green "Warning: redundant parameters specified: don't need mu2 for a detectable difference calculation."
exit 198
}
}
}


if("`detectabledifference'"~=""){
if("`binomial'"~=""){
if(`p1'!=0 & `p2'!=0){
disp in green "Warning: redundant parameters specified: don't need both p1 and p2 for a detectable difference calculation."
exit 198
}
}
if("`rates'"~=""){
if(`r1'!=0 & `r2'!=0){
disp in green "Warning: redundant parameters specified: don't need both r


1 and r2 for a detectable difference calculation."
exit 198
}
}
if("`rates'"=="" & "`binomial'"==""){
if(`mu1'!=-1 & `mu2'!=-1){
disp in green "Warning: redundant parameters specified: don't need both mu1 and mu2 for a detectable difference calculation."
exit 198
}
}
}


/*** Parameters out of range ***/
if(`beta'<0 | `beta'>1){
di _n as text "Beta value must be between 0 and 1" 	
exit 198
}
if(`alpha'<0 | `alpha'>1){
di _n as text "Beta value must be between 0 and 1" 	
exit 198
}


if (`rho'<0 & `cluster_cv'<0) {
	di _n as text "Must specify cluster heterogeneity via either intra-cluster correlation (rho)" 
	di _n as text "or coefficient of variation (of outcomes)"
	exit 198
	}
	if `sd1'<0 {
	di _n as text "Standard deviations must be positive"
	exit 198
	}
	if `sd2'<0 {
	di _n as text "Standard deviations must be positive"
	exit 198
	}
	if `r1'<0 {
	di _n as text "Rate must be positive"
	exit 198
	}
	if `r2'<0 {
	di _n as text "Rate must be positive"
	exit 198
	}
	
	if `rho'>1 {
	di _n as text "ICC must be between 0 and 1"
	exit 198
	}
	if `rho'<-1 {
	di _n as text "ICC must be between 0 and 1"
	exit 198
	}
	*EDITED OUT IN JUNE 2014
	*if `cluster_cv'>1 {
	*di _n as text "Cluster coefficient of variation (of outcomes) must be between 0 and 1"
	*exit 198
	*}
	if `cluster_cv'<-1 {
	di _n as text "Cluster coefficient of variation (of outcomes) must be between 0 and 1"
	exit 198
	}
	*EDITED OUT IN JUNE 2014
	*if `size_cv'>1 {
	*di _n as text "Coefficient of variation (of cluster sizes) must be between 0 and 1"
	*exit 198
	*}
	if `size_cv'<0 {
	di _n as text "Coefficient of variation (of cluster sizes) must be between 0 and 1"
	exit 198
	}
	if `base_correl'>1 {
	di _n as text "Correlation must be between 0 and 1"
	exit 198
	}
	if `base_correl'<0 {
	di _n as text "Correlation must be between 0 and 1"
	exit 198
	}
	if `p1'>1 {
	di _n as text "Proportions must be between 0 and 1"
	exit 198
	}
	if `p2'>1 {
	di _n as text "Proportions must be between 0 and 1"
	exit 198
	}
	if `p1'<0 {
	di _n as text "Proportions must be between 0 and 1"
	exit 198
	}
	if `p2'<0 {
	di _n as text "Proportions must be between 0 and 1"
	exit 198
	}
	if `rho'>1 {
	di _n as text "ICC (rho) must be between 0 and 1"
	exit 198
	}
	if `base_correl'>1 {
	di _n as text "Correlation between any baseline measures (or other covariates)" 
	di _n as text "and outcome must be between 0 and 1"
	exit 198
	}
	
	* CV method does not make mathematical sense when mean value is zero
	if(`cluster_cv'>0){
	if("`binomial'"~="" & `p1'==0){
	di _n as text "CV invalid when mean is zero"
	exit 198
	}
	if("`rates'"~="" & `r1'==0){
	di _n as text "CV invalid when mean is zero"
	exit 198
	}
	
	if("`binomial'"=="" & "`rates'"=="" & `mu1'==0){
	di _n as text "CV invalid when mean is zero"
	exit 198
	}
	
	}
if "`samplesize'"~="" {
	if(`m'==-1 & `k'==-1){
	di _n in red " Sample size calculation requested, user must specify either the"
	di _n in red "number of clusters or average cluster size"
	exit 198
	}
	if(`m'!=-1 & `k'!=-1){
	di _n in red " Sample size calculation requested, yet user specified both average" 
	di _n in red "cluster size and number of clusters!"
	exit 198
	}
	if (`mu2'== `mu1'& "`binomial'"=="" & "`rates'"==""){
	di _n as text "Means must not be identical"
	exit 198
	}
	if (`r2'== `r1' & "`rates'"~=""){
	di _n as text "Rates must not be identical"
	exit 198
	}
	if (`p2'==`p1' & "`binomial'"~="") {
	di _n as text "Proportions must not be identical"
	exit 198
	}
	}


if "`power'"~="" {
	if `k'<0 {
	di _n as text "Power calculation requested, but number of clusters not specified."
	exit 198
	}
	if `m'<0 {
	di _n as text "Power calculation requested, but average cluster size not specified."
	exit 198
	}

	
	
	
	
	
	if("`rates'"~="" ){
	if `r1'< 0{
	di _n as text "Power calculation requested, but difference to be detected not specified."
	exit 198
	}
	if `r2'< 0{
	di _n as text "Power calculation requested, but difference to be detected not specified."
	exit 198
	}
	if `r2'== `r1'{
	di _n as text "Rates must not be identical"
	exit 198
	}
	}
	if "`binomial'"~="" {
	if `p1'<0 {
	di _n as text "Power calculation requested, but difference to be detected not specified."
	exit 198
	}
	if `p2'<0 {
	di _n as text "Power calculation requested, but difference to be detected not specified."
	exit 198
	}
	if `p1'>1 {
	di _n as text "Proportions must be between 0 and 1"
	exit 198
	}
	if `p2'>1 {
	di _n as text "Proportions must be between 0 and 1"
	exit 198
	}
	if `p2'==`p1' {
	di _n as text "Proportions must not be identical"
	exit 198
	}
	}
	}
	
	
if "`detectabledifference'"~="" {
if `k'<0 {
	di _n as text "Detectable difference requested, but number of clusters missing"
	exit 198
	}
	if `m'<0 {
	di _n as text "Detectable difference requested, but average cluster size  missing"
	exit 198
	}
}




* DEFINING COMMON VARIABLES ##################################################################################################################################

local zalpha=-1*invnormal(`alpha'/2)
local base_correl_adj=sqrt(1-`base_correl'^2)  
if "`binomial'"~="" {
local mean1=`p1'
local mean2=`p2'
local sd1original=sqrt(`mean1'*(1-`mean1'))
local sd2original=sqrt(`mean2'*(1-`mean2'))
local sd1=sqrt(`mean1'*(1-`mean1'))*`base_correl_adj'
local sd2=sqrt(`mean2'*(1-`mean2'))*`base_correl_adj'
}

if "`binomial'"=="" {
local mean1=`mu1'
local mean2=`mu2'
local sd1original=`sd1'
local sd2original=`sd2'
local sd1=`sd1'*`base_correl_adj'
local sd2=`sd2'*`base_correl_adj'
}

if "`rates'"~="" {
local sd1original=sqrt(`r1')
local sd2original=sqrt(`r2')
local sd1=sqrt(`r1')*`base_correl_adj'
local sd2=sqrt(`r2')*`base_correl_adj'
local mean1=`r1'
local mean2=`r2'
}

local delta=abs(`mean1'-`mean2')
local ceiladjust=0.00000000000001

****** CV to ICC when cluster sizes vary ##################################################################################################################################
if(`cluster_cv'>=0 & `size_cv'>0){
di _n as text "Varying cluster sizes specified when heterogeneity specified via coefficient of variation (of outcomes):"
di  as text "for varying cluster sizes please specify heterogeneity via the ICC"
exit 198
if("`detectabledifference'"~=""){
local sd2=`sd1'
}
local meanvar=((`sd1'*`sd1')+(`sd2'*`sd2'))/2

if(`cluster_cv'>=0){
local rho=(`cluster_cv'*`cluster_cv'*`mean1'*`mean1')/((`cluster_cv'*`cluster_cv'*`mean1'*`mean1')+(`sd1'*`sd1'*`m'))
local cluster_cv=-0.1
}
display `rho'
di _n as text "Varying cluster sizes specified when heterogeneity specified via coefficient of variation (of outcomes):"
di  as text "using an approximation method to estimate ICC from CV."
}

* POWER FOR FIXED SAMPLE SIZE ######################################################################################################################################################################
	if "`power'"~="" {
	
	/*** Power under individual randomisation ***/
	local tmpsd1=(`sd1'*`sd1')
	local tmpsd2=(`sd2'*`sd2')
	local tmpsdRCT=`tmpsd1'+`tmpsd2'
	local tmp46RCT=(`m'*`k'*`delta'*`delta')/`tmpsdRCT'
	local tmp47RCT=sqrt(`tmp46RCT')
	local tmp48RCT=`tmp47RCT'-`zalpha'
    local powerRCT=normal(`tmp48RCT')
	
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local tmp46=((`k'-1)*`m'*`delta'*`delta')/(`tmpsdRCT'*`vif')
	}
	if(`cluster_cv'>=0){
	local tmpmeansq=1*(`mean1'*`mean1')+(`mean2'*`mean2')
	local tmp43=`cluster_cv'*`cluster_cv'*`tmpmeansq'
	local tmp44=(`tmpsd1'+`tmpsd2')/`m'
	local tmp45=`tmp43'+`tmp44'
	local tmp46=(`k'-1)*`delta'*`delta'/`tmp45'
	}
	local tmp47=sqrt(`tmp46')
	local tmp48=`tmp47'-`zalpha'
    local power=normal(`tmp48')	

	*OUTPUT REPORTING FOR POWER
	disp  in green _continue "Power calculation for a " 
	if "`binomial'"~="" {
	disp in green  "two sample comparison of proportions (using normal approximations)"
	disp in green  "without continuity correction."
	disp in green""
	disp  in green "For the user specified parameters:"
	disp in green ""
	disp in green "p1:" as result %-12.4f  _col(65) `mean1'
	disp in green "p2:" as result %-12.4f  _col(65) `mean2'
	if(`p2'<0.05 | `p2'>0.95 | `p1'<0.05 | `p1'>0.95){
		disp  in green _newline(1) in red "Warning: Normal approximations used close to boundaries might result in proportions out of range"
	}
	}
	if("`binomial'"=="" & "`rates'"==""){
	disp in green  "two sample comparison of means (using normal approximations)."
	disp in green ""
	disp  in green "For the user specified parameters:"
	disp in green ""
	disp  in green "mean 1:" as result %-12.2f _col(65)  `mean1'
	disp  in green "mean 2:" as result %-12.2f  _col(65) `mean2'
	disp  in green "standard deviation 1:" as result %-12.2f  _col(65) `sd1original'
	disp  in green "standard deviation 2:" as result %-12.2f  _col(65) `sd2original'
	}
	if "`rates'"~="" {
	disp in green  "two sample comparison of rates (using normal approximations)."
	disp in green _newline(2) ""
	disp in green ""
	disp  in green  "For the user specified parameters:"
	disp in green ""
	disp  in green "rate 1:" as result %-12.6f _col(65)  `mean1'
	disp  in green "rate 2:" as result %-12.6f  _col(65) `mean2'
	}
	disp  in green "significance level:"  as result %-12.2f  _col(65) `alpha'
	disp  in green "baseline measures adjustment (correlation):" as result %-12.2f _col(65) `base_correl'
	if "`rates'"~="" {
	disp  in green "average person years per cluster:"  as result %-12.0f _col(65) `m'
	}
	if("`rates'"==""){
	disp  in green "average cluster size:"  as result %-12.0f _col(65) `m'
	}
	disp  in green "number of clusters per arm:"  as result %-12.0f _col(65) `k'	
	if(`rho'>=0){
	disp  in green "coefficient of variation (of cluster sizes):"  as result %-12.2f  _col(65) `size_cv'
	disp  in green "intra-cluster correlation (ICC):"  as result %-12.4f _col(65)  `rho'
	}
	if(`cluster_cv'>=0){
	disp  in green "cluster coefficient of variation (of outcomes):"  as result %-12.2f _col(65)  `cluster_cv'
	}
	disp in green ""
	disp  in green   "clustersampsi estimated parameters:"
	disp in green ""
	disp in green "Firstly, assuming individual randomisation:"
	disp  in green "power:"  as result %-12.2f _col(65) `powerRCT'
	disp in green "Then, allowing for cluster randomisation:"
	if(`rho'>=0){
	disp  in green "design effect:"  as result %-12.2f  _col(65) `vif'
	}
	disp  in green "power:"  as result %-12.2f _col(65) `power'
	if (`k'<10) {
	disp  in green _newline(1) in red "Warning: Cluster trials with few clusters are not recommended."
	}
	if ("`binomial'"~="" && `base_correl' >0){
	disp  in green in red "Warning: Formula used to adjust for binary baseline measures is an approximation"
	}
	if(`rho'>=0){
	return local vif=`vif'
	}
	return local power = `power'
	return local powerRCT = `powerRCT'
	}

	* DETECTABLE DIFFERENCE #####################################################################################################################################################################
	
	if "`detectabledifference'"~="" {

	*DETECTABLE DIFFERENCE FOR FIXED SAMPLE SIZE FOR BINARY VARIABLES
	if "`binomial'"~="" {
	local zbeta=invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'	
	
	if(`cluster_cv'>=0){
	*work out DD in RCT (set cv=0):
	local tmpa2=((`k')/(`base_correl_adj'*`base_correl_adj'))/`tmp7'
	local c=(`p1'/`m')-((`p1'*`p1')/`m')-(`tmpa2'*`p1'*`p1')
	local b=(1/`m')+(2*`tmpa2'*`p1')
	local a=0-`tmpa2'-(1/`m')
	local p2tmpneg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2tmppos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2RCTneg=min(1,`p2tmpneg')
	local p2RCTpos=max(0,`p2tmppos')
	local detdiffRCTneg=`p2RCTneg'-`p1'
	local detdiffRCTpos=`p1'-`p2RCTpos'
	*work out DD in CRCT
	local tmpa2=((`k'-1)/(`base_correl_adj'*`base_correl_adj'))/`tmp7'
	local c=(`p1'/`m')-((`p1'*`p1')/`m')+(`cluster_cv'*`cluster_cv'*`p1'*`p1')-(`tmpa2'*`p1'*`p1')
	local b=(1/`m')+(2*`tmpa2'*`p1')
	local a=(`cluster_cv'*`cluster_cv')-`tmpa2'-(1/`m')
	local p2tmpneg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2tmppos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2neg=min(1,`p2tmpneg')
	local p2pos=max(0,`p2tmppos')
	local detdiffneg=`p2neg'-`p1'
	local detdiffpos=`p1'-`p2pos'
	}
	
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local tmpa1=(`m'*(`k'-1)/(`base_correl_adj'*`base_correl_adj'))/(`tmp7'*`vif')
	local a=0-1-`tmpa1'
	local b=1+(2*`mean1'*`tmpa1')
	local c=(`mean1'*(1-`mean1'))-(`mean1'*`mean1'*`tmpa1')
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2neg=`pitmp2neg'
	local p2pos=`pitmp2pos'
	local detdiffneg=`p2neg'-`p1'
	local detdiffpos=`p1'-`p2pos'
	*work out DD in RCT (set vif=1):
	local tmpa1=(`m'*(`k')/(`base_correl_adj'*`base_correl_adj'))/(`tmp7')
	local a=0-1-`tmpa1'
	local b=(2*`mean1'*`tmpa1')+1
	local c=(`mean1'*(1-`mean1'))-(`mean1'*`mean1'*`tmpa1')
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2RCTneg=`pitmp2neg'
	local p2RCTpos=`pitmp2pos'
	local detdiffRCTneg=`p2RCTneg'-`p1'
	local detdiffRCTpos=`p1'-`p2RCTpos'
	}
	*OUTPUT REPORTING FOR DETECTABLE DIFFERENCE FOR PROPORTIONS

	disp  in green _continue "Detectable difference calculation for two sample " 
	disp in green  "comparison of proportions (using normal approximations)"
	disp in green  "without continuity correction."
	disp in green ""
	disp  in green _newline(1) "For the user specified parameters:"
	disp  in green _newline(1) "p1:" as result %-12.2f  _col(65) `mean1' 
	if( `p1'<0.05 | `p1'>0.95){
		disp  in green _newline(1) in red "Warning: Normal approximations used close to boundaries might result in proportions out of range"
	}
	disp  in green "significance level:"  as result %-12.2f  _col(65)`alpha'
	disp  in green "power:"  as result %-12.2f _col(65) `beta'
	disp  in green "baseline measures adjustment (correlation):" as result %-12.2f _col(65) `base_correl'
	if "`rates'"~="" {
	disp  in green "average person years per cluster:"  as result %-12.0f _col(65) `m'
	}
	if("`rates'"==""){
	disp  in green "average cluster size:"  as result %-12.0f _col(65) `m'
	}
	disp  in green "number of clusters per arm:"  as result %-12.0f _col(65) `k'
	disp  in green "coefficient of variation (of cluster sizes):"  as result %-12.2f  _col(65) `size_cv'
	if(`cluster_cv'>=0){
	disp  in green "coefficient of variation (of outcomes):"  as result %-12.2f  _col(65) `cluster_cv'
	}
	if(`rho'>=0){
	disp  in green "intra cluster correlation (ICC):"  as result %-12.4f _col(65) `rho'
	}
	disp in green ""
	disp  in green _newline(1)"clustersampsi estimated parameters:"
	disp in green ""
	disp  in green _newline(1)"Firstly, under individual randomisation:"
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffRCTneg'
	disp  in green "with corresponding p2:" as result %-12.2f  _col(65) `p2RCTneg'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffRCTpos'
	disp  in green "with corresponding p2:" as result %-12.2f  _col(65) `p2RCTpos'	
	disp  in green _newline(1)"Then, allowing for cluster randomisation:"
	disp  in green "design effect:"  as result %-12.2f  _col(65) `vif'
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffneg'
	disp  in green "with corresponding p2:" as result %-12.2f  _col(65) `p2neg'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffpos'
	disp  in green "with corresponding p2:" as result %-12.2f  _col(65) `p2pos'
	if(`p2pos'<0.05 | `p2neg'>0.95){
		disp  in green _newline(1) in red "Warning: Normal approximations used close to boundaries might result in proportions out of range"
	}
	if (`k'<10) {
	disp  in green _newline(1) in red "Warning: Cluster trials with few clusters are not recommended." 
	}
	if ("`binomial'"~="" & `base_correl' >0 ){
	disp  in green _newline(1) in red "Warning: Formula used to adjust for binary baseline is an approximation"
	}
	if(`rho'>=0){
	return local VIF = `vif'
	}
	return local mean_pos = `p2pos'
	return local mean_neg = `p2neg'
	return local DD_pos = `detdiffneg'
	return local DD_neg = `detdiffpos'
	return local mean_posRCT = `p2RCTneg'
	return local mean_negRCT = `p2RCTpos'
	return local DD_posRCT = `detdiffRCTneg'
	return local DD_negRCT = `detdiffRCTpos'
	}
	
	* DETECTABLE DIFFERENCE FOR FIXED SAMPLE SIZE FOR MEANS 
	if "`binomial'"=="" & "`rates'"=="" {
	/*** DD in RCT ***/
	local zbeta=invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'
	local sd2=`sd1'
	local tmpsd=(`sd1'*`sd1')+(`sd2'*`sd2')
	local tmp8=`tmp7'*`tmpsd'
	local tmp9=`k'*`m'
	local detdiffRCT=sqrt(`tmp8'/`tmp9')
	local p2RCTtmpa=`mean1'-`detdiffRCT'
	local p2RCTtmpb=`mean1'+`detdiffRCT'
	if(`cluster_cv'>=0){
	local zbeta=invnormal(`beta')
	local tmpa2=(`k'-1)/`tmp7'
	local c=(`tmpsd'/`m')-(`tmpa2'*`mean1'*`mean1')+(`cluster_cv'*`cluster_cv'*`mean1'*`mean1')
	local b=2*`tmpa2'*`mean1'
	local a=(`cluster_cv'*`cluster_cv')-`tmpa2'
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2tmpa=`pitmp2neg'
	local p2tmpb=`pitmp2pos'
	local detdiffa=max(`p2tmpa',`p2tmpb')-`mean1'
	local detdiffb=`mean1'-min(`p2tmpa',`p2tmpb')
	}
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local detdiff=sqrt((`tmpsd'*`vif'*`tmp7')/((`k'-1)*`m'))
	local p2tmpa=`mean1'-`detdiff'
	local p2tmpb=`mean1'+`detdiff'
	}
	}
	/*** DD for rates ***/
	if "`rates'"~="" {
	/*** DD in RCT ***/
	local zbeta=invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'
	local tmpa=((`k')*`m'/(`base_correl_adj'*`base_correl_adj') )/(`tmp7')
	local c=`mean1'-(`mean1'*`mean1'*`tmpa')
	local b=1+(2*`tmpa'*`mean1')
	local a=-1*`tmpa'
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2RCTtmpa=`pitmp2neg'
	local p2RCTtmpb=`pitmp2pos'
	local detdiffRCTa=max(`p2RCTtmpa',`p2RCTtmpb')-`mean1'
	local detdiffRCTb=`mean1'-min(`p2RCTtmpa',`p2RCTtmpb')
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local tmpa=((`k'-1)*`m' /(`base_correl_adj'*`base_correl_adj'))/(`vif'*`tmp7')
	local c=`mean1'-(`mean1'*`mean1'*`tmpa')
	local b=1+(2*`tmpa'*`mean1')
	local a=-1*`tmpa'
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2tmpa=`pitmp2neg'
	local p2tmpb=`pitmp2pos'
	local detdiffa=max(`p2tmpa',`p2tmpb')-`mean1'
	local detdiffb=`mean1'-min(`p2tmpa',`p2tmpb')
	}
	if(`cluster_cv'>=0){
	local tmpa=((`k'-1)/(`base_correl_adj'*`base_correl_adj'))/(`tmp7')
	local c=(`mean1'/`m')-(`mean1'*`mean1'*`tmpa')+(`cluster_cv'*`cluster_cv'*`mean1'*`mean1')
	local b=(1/`m')+(2*`tmpa'*`mean1')
	local a=(`cluster_cv'*`cluster_cv')-`tmpa'
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2tmpa=`pitmp2neg'
	local p2tmpb=`pitmp2pos'
	local detdiffa=max(`p2tmpa',`p2tmpb')-`mean1'
	local detdiffb=`mean1'-min(`p2tmpa',`p2tmpb')
	}
	}
	if "`binomial'"==""{
	*OUTPUT REPORTING FOR DETECTABLE DIFFERENCE FOR MEANS and rates
	disp  in green _n _continue "Detectable difference calculation for "
	if("`binomial'"==""&"`rates'"==""){
	disp  in green  "two sample comparison of means (using normal approximations)"
	disp  in green  "and assuming equal standard deviations."
	disp in green ""
	disp  in green _newline(1) "For the user specified parameters:"
	disp in green ""
	disp  in green _newline(1) "mean 1:" as result %-12.2f  _col(65) `mean1'
	disp  in green "standard deviation 1:" as result %-12.2f _col(65) `sd1original' 
	}
	if "`rates'"~="" {
	disp in green ""
	disp in green "two sample comparison of rates, using normal approximations."
	disp in green ""
	disp  in green "For the user specified parameters:"
	disp  in green "rate 1:" as result %-12.4f _col(65)  `mean1'
	}
	disp  in green "significance level:"  as result %-12.2f  _col(65)`alpha'
	disp  in green "power:"  as result %-12.2f _col(65) `beta'
	disp  in green "baseline measures adjustment (correlation):" as result %-12.2f _col(65) `base_correl'
	if "`rates'"~="" {
	disp  in green "average person years per cluster:"  as result %-12.0f _col(65) `m'
	}
	if("`rates'"==""){
	disp  in green "average cluster size:"  as result %-12.0f _col(65) `m'
	}
	disp  in green "number of clusters per arm:"  as result %-12.0f _col(65) `k'
	if(`rho'>=0){
	disp  in green "coefficient of variation (of cluster sizes):"  as result %-12.2f  _col(65) `size_cv'
	disp  in green "intra cluster correlation (ICC):"  as result %-12.2f _col(65) `rho'	
	}
	if(`cluster_cv'>=0){
	disp  in green "cluster coefficient of variation (of outcomes):"  as result %-12.2f  _col(65) `cluster_cv'
	}
	disp in green ""
	disp  in green _newline(1)"clustersampsi estimated parameters:"
	disp in green "" 
	disp  in green _newline(1)"Firstly, under individual randomisation:"
	
	if("`binomial'"==""&"`rates'"==""){
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffRCT'
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "corresponding mean 2:" as result %-12.2f  _col(65) `p2RCTtmpb'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "corresponding mean 2:" as result %-12.2f  _col(65) `p2RCTtmpa'
	}
	if("`rates'"~=""){
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "detectable difference:" as result %-12.4f  _col(65) `detdiffRCTa'
	disp  in green "corresponding rate 2:" as result %-12.4f  _col(65) `p2RCTtmpa'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "detectable difference:" as result %-12.4f  _col(65) `detdiffRCTb'
	disp  in green "corresponding rate 2:" as result %-12.4f  _col(65) `p2RCTtmpb'
	}
	disp  in green _newline(1)"Then, allowing for cluster randomisation:"
	if(`rho'>=0){
	disp  in green "design effect:"  as result %-12.2f  _col(65) `vif'
	if("`binomial'"==""&"`rates'"==""){	
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiff'
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpb'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpa'
	disp in green "" 
	disp in red "Note: standard deviations assumed equivalent in both arms."
	}
	if("`rates'"~=""){
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "detectable difference:" as result %-12.4f  _col(65) `detdiffa'
	disp  in green "with corresponding rate 2:" as result %-12.4f  _col(65) `p2tmpa'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "detectable difference:" as result %-12.4f  _col(65) `detdiffb'
	disp  in green "with corresponding rate 2:" as result %-12.4f  _col(65) `p2tmpb'
	}
	}
	if(`cluster_cv'>=0){
	
	if("`binomial'"==""&"`rates'"==""){
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffa'
	disp  in green "with corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpa'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "detectable difference:" as result %-12.2f  _col(65) `detdiffb'
	disp  in green "with corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpb'
	disp in green "" 
	disp in red "Note: standard deviations assumed equivalent in both arms."
	}
	if("`rates'"~=""){
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "detectable difference:" as result %-12.4f  _col(65) `detdiffa'
	disp  in green "with corresponding rate 2:" as result %-12.4f  _col(65) `p2tmpa'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "detectable difference:" as result %-12.4f  _col(65) `detdiffb'
	disp  in green "with corresponding rate 2:" as result %-12.4f  _col(65) `p2tmpb'
	}
	}
	
	if (`k'<10) {
	disp  in red "Warning: Cluster trials with few clusters are not recommended."
	}
	if(`rho'>=0){
	return local DE = `vif'
	if("`binomial'"==""&"`rates'"==""){	
	 return local DD=`detdiff'
	return local mean_neg=`p2tmpa'
	return local mean_pos=`p2tmpb'
	}
	if("`rates'"~=""){
	return local DD_neg=`detdiffb'
	return local mean_neg= `p2tmpb'	
	return local DD_pos= `detdiffa'
	return local mean_pos= `p2tmpa'
	}
	}
	if(`cluster_cv'>=0){
	
	if("`binomial'"==""&"`rates'"==""){
	return local DD_neg=`detdiffb'
	return local mean_neg=`p2tmpb'
	return local DD_pos=`detdiffa'
	return local mean_pos=`p2tmpa'
	
	}
	if("`rates'"~=""){
	return local DD_neg=`detdiffb'
	return local mean_neg=`p2tmpb'
	return local DD_pos=`detdiffa'
	return local  mean_pos=`p2tmpa'
	}
	}
	
	}
	}
	*SAMPLE SIZE - DETERMINING REGUIRED NUMBER OF CLUSTERS ##################################################################################################################################################
	if "`samplesize'" ~="" & `m' >0 {
	local tmpsd1=(`sd1'*`sd1')
	local tmpsd2=(`sd2'*`sd2')
	local tmpsd=`tmpsd1'+`tmpsd2'
	local zbeta=1*invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'
	local tmp8=(`tmp7'*`tmpsd')/(`delta'*`delta')
	local tmpRCT=ceil(`tmp8')
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local clustersperarm=ceil((`vif'*`tmp8'/`m'))+1
	local totalsamplesize=`m'*`clustersperarm'
	}
	if(`cluster_cv'>=0){
	local tmpmeansq=1*(`mean1'*`mean1')+(`mean2'*`mean2')
	local cvif=(`tmp7'*`cluster_cv'*`cluster_cv'*`tmpmeansq')/(`delta'*`delta')
	local clustersperarm=ceil(1+(`tmp8'/`m')+`cvif')
	local totalsamplesize=`clustersperarm'*`m'
	}

	/***Actual power - under clustersperarm ****/
	local tmpsd1=(`sd1'*`sd1')
	local tmpsd2=(`sd2'*`sd2')
	local tmpsdRCT=`tmpsd1'+`tmpsd2'
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local tmp46=((`clustersperarm'-1)*`m'*`delta'*`delta')/(`tmpsdRCT'*`vif')
	}
	if(`cluster_cv'>=0){
	local tmpmeansq=1*(`mean1'*`mean1')+(`mean2'*`mean2')
	local tmp43=`cluster_cv'*`cluster_cv'*`tmpmeansq'
	local tmp44=(`tmpsd1'+`tmpsd2')/`m'
	local tmp45=`tmp43'+`tmp44'
	local tmp46=((`clustersperarm'-1)*`delta'*`delta')/`tmp45'
	}
	local tmp47=sqrt(`tmp46')
	local tmp48=`tmp47'-`zalpha'
    local powerm=normal(`tmp48')
	
	/***Actual power - under clustersperarm -1 ****/
	local tmpsd1=(`sd1'*`sd1')
	local tmpsd2=(`sd2'*`sd2')
	local tmpsdRCT=`tmpsd1'+`tmpsd2'
	if(`rho'>=0){
	local vif=1+((((((`size_cv'*`size_cv')+1)*`m')-1))*`rho')
	local tmp46=((`clustersperarm'-2)*`m'*`delta'*`delta')/(`tmpsdRCT'*`vif')
	}
	if(`cluster_cv'>=0){
	local tmpmeansq=1*(`mean1'*`mean1')+(`mean2'*`mean2')
	local tmp43=`cluster_cv'*`cluster_cv'*`tmpmeansq'
	local tmp44=(`tmpsd1'+`tmpsd2')/`m'
	local tmp45=`tmp43'+`tmp44'
	local tmp46=((`clustersperarm'-2)*`delta'*`delta')/`tmp45'
	}
	local tmp47=sqrt(`tmp46')
	local tmp48=`tmp47'-`zalpha'
    local powermmin1=normal(`tmp48')	
	
	*OUTPUT FOR SAMPLE SIZE - DETERMINING REGUIRED NUMBER OF CLUSTERS
	disp  in green _continue "Sample size calculation determining the " 
	disp in green "number of clusters required, "
	if "`binomial'"~="" {
	disp in green "for a two sample comparison of proportions (using normal approximations)"
	disp in green  "without continuity correction."
	disp in green ""
	disp  in green  "For the user specified parameters:"
	disp in green ""
	disp  in green  "p1:" as result %-12.4f  _col(65) `mean1'
	disp  in green "p2:" as result %-12.4f  _col(65) `mean2'
	if(`p2'<0.05 | `p2'>0.95 | `p1'<0.05 | `p1'>0.95){
		disp  in green _newline(1) in red "Warning: Normal approximations used close to boundaries might result in proportions out of range"
	}
	}
	if ("`binomial'"=="" & "`rates'"=="") {
	disp in green "for a two sample comparison of means (using normal approximations)."
	disp in green ""
	disp  in green   "For the user specified parameters:"
	disp in green ""
	disp  in green  "mean 1:" as result %-12.2f _col(65) `mean1'
	disp  in green "mean 2:" as result %-12.2f  _col(65) `mean2'
	disp  in green "standard deviation 1:" as result %-12.2f  _col(65)  `sd1original'
	disp  in green "standard deviation 2:" as result %-12.2f  _col(65)  `sd2original'
	}
	if ("`rates'"~="") {
	disp in green "for a two sample comparison of rates (using normal approximations)."
	disp in green ""
	disp  in green   "For the user specified parameters:"
	disp in green ""
	disp  in green  "rate 1:" as result %-12.4f _col(65) `mean1'
	disp  in green "rate 2:" as result %-12.4f  _col(65) `mean2'
	}
	disp  in green "significance level:"  as result %-12.2f _col(65)`alpha'
	disp  in green "power:"  as result %-12.2f _col(65)`beta'
	disp  in green "baseline measures adjustment (correlation):" as result %-12.2f _col(65) `base_correl'
	if "`rates'"~="" {
	disp  in green "average person years per cluster:"  as result %-12.0f _col(65) `m'
	}
	if("`rates'"==""){
	disp  in green "average cluster size:"  as result %-12.0f _col(65) `m'
	}
	if(`rho'>=0){
	disp  in green "intra cluster correlation (ICC):"  as result %-12.4f _col(65) `rho'
	disp  in green "coefficient of variation (of cluster sizes):"  as result %-12.2f  _col(65) `size_cv'
	}
	if(`cluster_cv'>=0){
	disp  in green "cluster coefficient of variation (of outcomes):"  as result %-12.2f _col(65) `cluster_cv'
	}
	disp in green ""
	disp  in green  _newline(1) "clustersampsi estimated parameters:"
	disp in green ""
	disp  in green _newline(1)"Firstly, assuming individual randomisation:"
	disp  in green  "sample size per arm:" as result %-12.0f _col(65) `tmpRCT'
	disp  in green _newline(1)"Then, allowing for cluster randomisation:"
	if(`rho'>=0){
	disp  in green "design effect:"  as result %-12.2f _col(65) `vif'
	}
	disp  in green "sample size per arm:"  as result %-12.0f  _col(65) `totalsamplesize'	
	disp  in green "number clusters per arm:" as result %-12.0f _col(65) `clustersperarm'
	disp in green ""
	disp  in green  "Note: sample size per arm required under cluster randomisation is rounded up" 
	disp in green "to a multiple of average cluster size and includes the addition" 
	disp in green "of one extra cluster per arm (to allow for t-distribution)."
	disp in green "To understand sensitivity to these conservative allowances:"
	disp in green "power with m clusters per arm:" as result %-12.2f  _col(65) `powerm'	
	disp in green "power with m-1 clusters per arm:" as result %-12.2f  _col(65) `powermmin1'	
	if (`clustersperarm'<10) {
	disp  in green _newline(1) in red "Warning: Cluster trials with few clusters are not recommended." 
	}
	if ("`binomial'"~="" & `base_correl' >0){
	disp in green "" 
	disp  in green _newline(1) in red "Warning: Formula used to adjust for binary baseline measures is an approximation."
	}
	if(`rho'>=0){
	return local vif=`vif'
	}
	if(`cluster_cv'>=0){
	return local cvif=`cvif'
	}
	return local k =`clustersperarm'
	return local powerm= `powerm'	
	return local powermin1 = `powermmin1'
	}


	*SAMPLE SIZE - DETERMINING REGUIRED NUMBER OF UNITS PER CLUSTER ##########################################################################################################################
	if "`samplesize'" ~="" & `k' >0 {

	*GENERAL OUTPUT FOR SAMPLE SIZE - DETERMINING REGUIRED NUMBER OF UNITS PER CLUSTER
	disp  in green  _newline(1) "Sample size calculation to determine number of observations required per cluster,"
	if "`binomial'"~="" {
	disp in green "for a two sample comparison of proportions (using normal approximations)"
	disp in green  "without continuity correction."
	disp in green ""
	disp  in green  _newline(1) "For the user specified parameters:"
	disp in green ""
	disp  in green  "p1:" as result %-12.4f  _col(65) `mean1' 
 	disp  in green  "p2:" as result %-12.4f  _col(65) `mean2' 
	if(`p2'<0.05 | `p2'>0.95 | `p1'<0.05 | `p1'>0.95){
		disp  in green _newline(1) in red "Warning: Normal approximations used close to boundaries might result in proportions out of range"
	}
	}
	if("`binomial'"=="" & "`rates'"==""){
	disp in green "for a two sample comparison of means (using normal approximations)."
	disp in green ""
	disp  in green  "For the user specified parameters:"
	disp in green ""
	disp  in green  "mean 1:" as result %-12.2f _col(65) `mean1'
	disp  in green  "mean 2:" as result %-12.2f _col(65) `mean2'
	disp  in green "standard deviation 1:" as result %-12.2f _col(65) `sd1original' 
	disp  in green "standard deviation 2:" as result %-12.2f _col(65) `sd2original' 
	}
	if("`rates'"~=""){
	disp in green "for a two sample comparison of rates (using normal approximations)."
	disp in green ""
	disp  in green  "For the user specified parameters:"
	disp in green ""
	disp  in green  "rate 1:" as result %-12.4f _col(65) `mean1'
 	disp  in green  "rate 2:" as result %-12.4f _col(65) `mean2'
	}
	disp  in green "significance level:"  as result %-12.2f  _col(65) `alpha'
	disp  in green "power:"  as result %-12.2f  _col(65) `beta'
	disp  in green "baseline measures adjustment (correlation):" as result %-12.2f _col(65) `base_correl'
	disp  in green "number of clusters available:"  as result %-12.0f  _col(65) `k'
	if `k'<10 {
	disp  in green in red "Cluster trials with few clusters per arm (say less than 10)"
	disp  in green in red "might be infeasible due to small number of randomisation units." 
	}
	if(`rho'>=0){
	disp  in green "intra cluster correlation (ICC):"  as result %-12.4f  _col(65) `rho'
	disp  in green "coefficient of variation (of cluster sizes):"  as result %-12.2f _col(65) `size_cv'
	}
	if(`cluster_cv'>=0){
	disp  in green "cluster coefficient of variation (of outcomes):"  as result %-12.2f  _col(65) `cluster_cv'
	}
	
	*DETERMING IF THERE IS A SUFFICIENT NUMBER OF CLUSTERS
	local tmpsd1=`sd1'*`sd1'
	local tmpsd2=`sd2'*`sd2'
	local tmpsd=(`tmpsd1'+`tmpsd2')
	local zbeta=invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'
	local tmp8=(`tmp7'*`tmpsd')/(`delta'*`delta')
	local tmpRCT=ceil(`tmp8')
	if(`rho'>=0){
	local tmp22=((`size_cv'*`size_cv')+1)*`rho'*`tmp8'
	local tmp23=(`k'-1)-`tmp22'
	local minnoclus=ceil(`tmp22'+1+`ceiladjust')
	}
	if(`cluster_cv'>=0){
	local meansq=(`mean1'*`mean1')+(`mean2'*`mean2')
	local cvif=1*(`base_correl_adj'*`base_correl_adj'*`cluster_cv'*`cluster_cv'*`meansq'*`tmp7')/(`delta'*`delta')
	local tmp23=`k'-1-`cvif'
	local minnoclus=ceil(`cvif'+1+`ceiladjust') 
	}
/****INSUFFICIENT NUMBER OF CLUSTERS - MINIMUM DETECTABLE DIFFERENCE FOR BINARY VARIABLES ***/
	if(`tmp23'<=0){
	if("`binomial'"~=""){
	if(`cluster_cv'>=0){
	local tmpa2=(`k'-1)/(`tmp7'*`cluster_cv'*`cluster_cv'*`base_correl_adj'*`base_correl_adj')
	local a=1-`tmpa2'
	local b=2*`mean1'*`tmpa2'
	local c=(`mean1'*`mean1')-(`mean1'*`mean1'*`tmpa2')
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2neg=`pitmp2neg'
	local p2pos=`pitmp2pos'
	local detdiffneg=`p2neg'-`p1'
	local detdiffpos=`p1'-`p2pos'
	}
	
	if(`rho'>=0){
	local tmpcv=((`size_cv'*`size_cv')+1)*`rho'
	local tmpa1=(`k'-1)/(`tmp7'*`tmpcv'*`base_correl_adj'*`base_correl_adj')	
	local a=0-1-`tmpa1'
	local b=1+(2*`mean1'*`tmpa1')
	local c=(`mean1'*(1-`mean1'))-(`mean1'*`mean1'*`tmpa1')
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')	
	local p2neg=`pitmp2neg'
	local p2pos=`pitmp2pos'
	local detdiffneg=`p2neg'-`p1'
	local detdiffpos=`p1'-`p2pos'
	}
	}
	
	
	*INSUFFICIENT NUMBER OF CLUSTERS - MINIMUM DETECTABLE DIFFERENCE FOR MEANS ######################################################################################################################################
	if("`binomial'"==""){
	if(`cluster_cv'>=0){
	local zbeta=invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'
	local tmpa2=(`k'-1)/(`tmp7'*`cluster_cv'*`cluster_cv'*`base_correl_adj'*`base_correl_adj')
	local c=(`mean1'*`mean1')-(`tmpa2'*`mean1'*`mean1')
	local b=2*`tmpa2'*`mean1'
	local a=1-`tmpa2'
	local pitmp2neg=((-1*`b')-sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local pitmp2pos=((-1*`b')+sqrt((`b'*`b')-(4*`a'*`c')))/(2*`a')
	local p2tmpa=`pitmp2neg'
	local p2tmpb=`pitmp2pos'
	}
	if(`rho'>=0){
	local tmpcv=((`size_cv'*`size_cv')+1)*`rho'
	local zbeta=invnormal(`beta')
	local tmp6=`zbeta'+`zalpha'
	local tmp7=`tmp6'*`tmp6'
	local tmpsd=(`sd1'*`sd1')+(`sd2'*`sd2')
	local tmp8=`tmp7'*`tmpsd'*`tmpcv'
	local tmp9=(`k'-1)
	local detdiff=sqrt(`tmp8'/`tmp9')
	local p2tmpa=`mean1'-`detdiff'
	local p2tmpb=`mean1'+`detdiff'
	}
	}
	*INSUFFICIENT NUMBER OF CLUSTERS - MAXIMUM AVAILABLE POWER #############################################################################################################################################################
	if(`cluster_cv'>=0){
	local tmpa=(`k'-1)*`delta'*`delta'
	local meansq=(`mean1'*`mean1')+(`mean2'*`mean2')
	local tmpc=`base_correl_adj'*`base_correl_adj'*`cluster_cv'*`cluster_cv'*`meansq'
	local tmpd=sqrt(`tmpa'/`tmpc')
	local tmpe=`tmpd'-`zalpha'
	local MAP=normal(`tmpe')
	}
	if(`rho'>=0){
	local tmpcv=((`size_cv'*`size_cv')+1)*`rho'
	local tmpsd=(`sd1'*`sd1')+(`sd2'*`sd2')
	local tmp45=((`k'-1)*`delta'*`delta')/(`tmpsd'*`tmpcv')
	local tmp47=sqrt(`tmp45')
	local tmp48=`tmp47'-`zalpha'
    local MAP=normal(`tmp48')	
	}
	*OUTPUT UNDER AN INSUFFICIENT NUMBER OF CLUSTERS	
	disp in green ""
	disp  in green _newline(1)  "clustersampsi estimated parameters:"
	disp in green ""
	disp in green _newline(1) "The sample size required under individual randomisation is: " as result %-12.0f _col(65) `tmpRCT'
	disp  in green in red "The specified design is infeasible under cluster randomisation."
	disp in green _newline(1) "You could consider one of the following three options:"
	disp  in green "(i) Increase the number of clusters per arm to more than:"  as result %-12.0f _col(65) `minnoclus'
	return local min_k=`minnoclus'
	disp  in green "(ii) Decrease the power to:" as result %-12.2f  _col(65) `MAP'
	
	if "`binomial'"~="" {
	disp  in green "(iii) Increase the difference to be detected. So," 
	disp in green "If, trying to detect an increasing outcome then:"
	disp  in green "decrease the  difference to be detected to:" as result %-12.4f  _col(65) `detdiffneg'
	disp  in green "with corresponding p2:" as result %-12.4f  _col(65) `p2neg'
	disp in green "If, trying to detect a decreasing outcome then:"
	disp  in green "decrease the  difference to be detected to:" as result %-12.4f  _col(65) `detdiffpos'
	disp  in green "with corresponding p2:" as result %-12.4f  _col(65) `p2pos'
	return local mean_neg =`p2pos'
	return local mean_pos=`p2neg'
	return local MDD_neg=`detdiffpos'
	return local MDD_pos=`detdiffneg'
	if(`p2pos'<0.05 | `p2neg'>0.95){
	disp  in red "Warning: normal approximations being used close to the boundary values of 0 or 1!"
	}
	}
	
	if("`binomial'"=="" & "`rates'"=="" & `rho'>0) {
	disp  in green "(iii) Increase the difference to be detected to:" as result %-12.2f  _col(65) `detdiff'
	disp  in green "So, corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpb'
	disp  in green "Alternatively, corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpa'
	return local MDD=`detdiff'
	return local mean_neg=`p2tmpa'
	return local mean_pos=`p2tmpb'
	}
	if("`rates'"~="" & `rho'>0) {
	disp  in green "(iii) Increase the difference to be detected to:" as result %-12.4f  _col(65) `detdiff'
	disp  in green "So, corresponding rate 2:" as result %-12.4f  _col(65) `p2tmpa'
	disp  in green "Alternatively, corresponding rate 2:" as result %-12.4f  _col(65) `p2tmpb'
	return local MDD=`detdiff'
	return local mean_neg=`p2tmpa'
	return local mean_pos=`p2tmpb'
	}
	
	if("`binomial'"=="" & "`rates'"=="" & `cluster_cv'>0) {
	disp  in green "(iii) Increase the difference to be detected:" 
	disp  in green "with corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpa'
	disp  in green "or, alternative mean 2:" as result %-12.2f  _col(65) `p2tmpb'
	return local MDD=`detdiffneg'
	return local mean_neg=`p2tmpa'
	return local mean_pos=`p2tmpb'
	}
	if("`rates'"~="" & `cluster_cv'>0) {
	disp  in green "(iii) Increase the difference to be detected:" 
	disp  in green "with corresponding mean 2:" as result %-12.2f  _col(65) `p2tmpa'
	disp  in green "or, alternative rate 2:" as result %-12.2f  _col(65) `p2tmpb'
	return local MDD=`detdiffneg'
	return local mean_neg=`p2tmpa'
	return local mean_pos=`p2tmpb'
	}
	
	return local MAP=`MAP'
	exit 198
	}
	*SAMPLE SIZE - DETERMINGING NUMBER OF UNITS PER CLUSTER FOR A SUFFICIENT NUMBER OF CLUSTERS ############################################################################################################################
	if `tmp23'>0 {
	if(`rho'>=0){
	local tmprho=((`size_cv'*`size_cv')+1)*`rho'
	local tmp9=`k'-1-(`tmp8'*`tmprho')
	local tmp10=`tmp8'*(1-`tmprho')
	local tmp11=`tmp10'/`tmp9'
	local unitspercluster=ceil(`tmp11')
	local totalsamplesize=`unitspercluster'*`k'
	}
	if(`cluster_cv'>=0){
	local tmpmeansq=1*(`mean1'*`mean1')+(`mean2'*`mean2')
	local tmp10=1*(`base_correl_adj'*`base_correl_adj'*`cluster_cv'*`cluster_cv'*`tmpmeansq'*`tmp6'*`tmp6')/(`delta'*`delta')
	local tmp11=`k'-1-`tmp10'
	local tmp12=`tmp8'/`tmp11'
	local unitspercluster=ceil(`tmp12')
	local totalsamplesize=`unitspercluster'*`k'
	}
	*OUTPUT FOR SAMPLE SIZE - DETERMINGING THE NUMBER OF CLUSTERS FOR A SUFFICIENT NUMBER OF CLUSTERS
	disp in green ""
	disp  in green  _newline(1) "clustersampsi estimated parameters:"
	disp in green ""
	disp in green "Firstly, assuming individual randomisation:"
	disp  in green  "sample size per arm:" as result %-12.0f  _col(65) `tmpRCT'
	disp in green ""
	disp in green "Then, allowing for cluster randomisation:"
	if "`rates'"~="" {
	disp  in green "average person years per cluster required:"  as result %-12.0f _col(65) `unitspercluster'
	}
	if("`rates'"==""){
	disp  in green "average cluster size required:"  as result %-12.0f _col(65) `unitspercluster'
	}
	disp  in green "sample size per arm:"  as result %-12.0f  _col(65)`totalsamplesize'	
	disp in green ""
	disp  in green "Note: sample size per arm required under cluster randomisation is rounded" 
	disp in green "up to a multiple of average cluster size."	
	if ("`binomial'"~="" & `base_correl' >0){
	disp  in green in red "Warning: Formula used to adjust for binary baseline measures is an approximation."
	}
	return local m = `unitspercluster'

	}
	}

end

 
