#------------------------------------------------ 
# title: "Code for Descriptive Stats for Baseline HH Survey"
# author: "Astha Vohra"
# modified date: "2023-10-12"
#------------------------------------------------ 

#------------------------ Load the libraries ----------------------------------------#

# load the libraries
library(readxl) 
library(googledrive)
library(googlesheets4)
library(DBI)
library(RSQLite)
library(dplyr)
library(lubridate)
library(haven)
library(expss)
library(stargazer)
library(tidyverse)
library(Hmisc)
library(ggplot2)
library(labelled)

#------------------------ setting user path ----------------------------------------#




user_path <- function() {
  # Return a hardcoded path that depends on the current user, or the current 
  # working directory for an unrecognized user. If the path isn't readable,
  # stop.
  
  user <- Sys.info()["user"]
  
  if (user == "asthavohra") { 
    path = "/Users/asthavohra/Library/CloudStorage/Box-Box/India Water project/2_Pilot/Data/"
  } 
  else if (user=="akitokamei"){
    path = "/Users/akitokamei/Box Sync/India Water project/2_Pilot/Data/"
  } 
  else if (user == ""){
    path = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    path = getwd()
  }
  
  stopifnot(file.exists(path))
  return(path)
}

# set working directory
knitr::opts_knit$set(root.dir = user_path())

# setting github directory
github_path <- function() {
  user <- Sys.info()["user"]
  if (user == "asthavohra") {
    github = "/Users/asthavohra/Documents/GitHub/i-h2o-india/Code/2_Pilot/0_pilot logistics/"
  } 
  else if (user=="akitokamei"){
    github = "/Users/akitokamei/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/i-h2o-india/Code/2_Pilot/0_pilot logistics/"
  } 
  else if (user == "") {
    github = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    github = getwd()
  }
  
  stopifnot(file.exists(github))
  return(github)
}

# setting github directory
overleaf <- function() {
  user <- Sys.info()["user"]
  if (user == "asthavohra") {
    overleaf = "/Users/asthavohra/Dropbox/Apps/Overleaf/Everything document -ILC/"
  } 
  else if (user=="akitokamei"){
    overleaf = "/Users/akitokamei/Library/CloudStorage/Dropbox/Apps/Overleaf/Everything document -ILC/"
  } 
  else if (user == "") {
    overleaf = ""
  } 
  else {
    warning("No path found for current user (", user, ")")
    overleaf = getwd()
  }
  
  stopifnot(file.exists(overleaf))
  return(overleaf)
}

#------------------------ Load the data ----------------------------------------#

df.temp <- read_dta(paste0(user_path(),"2_deidentified/1_2_Followup_cleaned.dta" ))

#------------------------ Apply the labels for variables  ----------------------------------------#

temp.labels <- lapply(df.temp , var_lab)

#create a data with labels
df.label <- as.data.frame(t(as.data.frame(do.call(cbind, temp.labels)))) 
df.label<- tibble::rownames_to_column(df.label) 
df.label <- df.label %>% rename(variable = rowname, label = V1)  
auto_generated_labels <- c(df.label$variable)

#include labels given manually 
df.label.manual <- read_xlsx(paste0(user_path(),"4_other/R_code_HH_Survey_labels.xlsx"))

df.var <- as.data.frame(names(df.temp)) #List of variables in the data

# assign labels to variable that were generated
df.label.manual <- df.label.manual %>% mutate(new_var = ifelse(Variable %in% auto_generated_labels, 0,1)) %>% 
  filter(new_var == 1) %>% select(-new_var) %>% rename(variable = Variable, label = Label)

df.label <- rbind(df.label, df.label.manual)
# create a function that assigns the label to appropriate variable

#------------------------ Keep consented cases ----------------------------------------#

df.temp.consent <- df.temp[which(df.temp$R_FU_consent==1) ,]


#------------------------ Water Quality Stats ----------------------------------------#

bl <- df.temp.consent

# Displaying chlorine concentration for each village
# Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU_fc_tap, R_FU_fc_stored, R_FU_tc_tap, R_FU_tc_stored), values_to = "chlorine_concentration", names_to = "chlorine_test_type")
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE)
p1 <- ggplot(data =chlorine) + geom_point(aes(x = chlorine_test_type, y = chlorine_concentration), size = 3) +
  facet_wrap(~ R_FU_r_cen_village_name_str) +
  labs(x = "Chlorine Test", y = "Chlorine Concentration (mg/L)") +
  theme_bw() + scale_x_discrete(labels=c("FCl-Stored" , "FCl-Running", "TCl-Stored", "TCl-Running"))+
  theme(axis.title.y = element_text(size = 32), axis.title.x = element_text(size = 32), 
        axis.text.x =  element_text(size = 18, face="bold"), axis.text.y =  element_text(size = 30, face="bold"), 
        strip.text = element_text(size = 40)) 


ggplot2::ggsave( paste0(overleaf(),"Figure/Chlorine-concentration-village.png"), p1,  width = 21, height= 13,dpi=200)



# Displaying chlorine test data for all villages combined
# Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU_fc_tap, R_FU_fc_stored, R_FU_tc_tap, R_FU_tc_stored), values_to = "chlorine_concentration", names_to = "chlorine_test_type")
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE) %>% 
  group_by(chlorine_test_type) %>% 
  mutate(mean_cl = round(mean(chlorine_concentration, na.rm  = T), digits = 2), 
         min_cl = round(min(chlorine_concentration, na.rm  = T),digits = 2), 
         max_cl = round(max(chlorine_concentration, na.rm  = T), digits = 2),
         perc_25 = round(quantile(chlorine_concentration, 0.25),digits = 2), 
         perc_50 = round(quantile(chlorine_concentration, 0.5),digits = 2), 
         perc_75 = round(quantile(chlorine_concentration, 0.75),digits = 2)) %>% 
  ungroup()

chlorine_stats  <- chlorine %>% select(chlorine_test_type, mean_cl, min_cl, perc_25, perc_50, perc_75, max_cl) %>% unique() %>%
  mutate(chlorine_test_type = ifelse(chlorine_test_type == "R_FU_fc_tap", "Running- Free Cl", ifelse(
    chlorine_test_type == "R_FU_fc_stored", "Stored- Free Cl", ifelse(
      chlorine_test_type == "R_FU_tc_tap", "Running- Total Cl", ifelse(
        chlorine_test_type == "R_FU_tc_stored", "Stored- Total Cl", chlorine_test_type ))))) %>%
  rename("Test Type" = chlorine_test_type,"Mean" = mean_cl, "Min" =  min_cl,  "Q1" = perc_25,  "Q2" = perc_50, "Q3" =perc_75,  "Max" =max_cl ) 
chlorine_stats <- as.data.table(chlorine_stats)
  
stargazer(chlorine_stats, summary=F, title= "",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_chlorine_stats_HH_Survey.tex"))

p2 <- ggplot(data =chlorine) + geom_point(aes(x = chlorine_test_type, y = chlorine_concentration), size = 3) +
  labs(x = "Chlorine Test", y = "Chlorine Concentration (mg/L)")  + 
  geom_errorbar(aes(x = chlorine_test_type, y = chlorine_concentration, ymin = mean_cl - 1.96*sd(chlorine_concentration)/sqrt(length(chlorine_concentration)),
                    ymax = mean_cl + 1.96*sd(chlorine_concentration)/sqrt(length(chlorine_concentration))), width = 0.2, linewidth = 0.8, color = "red") + 
  theme_bw() +  scale_x_discrete(labels=c("FCl - Stored" , "FCl - Running", "TCl - Stored", "TCl - Running")) +
  theme(axis.title.y = element_text(size = 32), axis.title.x = element_text(size = 32), 
        axis.text.x =  element_text(size = 32, face="bold"), axis.text.y =  element_text(size = 30, face="bold")) 


ggplot2::ggsave( paste0(overleaf(),"Figure/Chlorine-concentration.png"), p2,  width = 22, height= 15,dpi=200)

#------------------------ Section A: WASH Access ----------------------------------------#


df.wash <- df.temp.consent %>% select(R_FU_water_source_prim, R_FU_water_sec_yn,  R_FU_quant, R_FU_water_treat, R_FU_water_stored)
#assign labels for each

var_lab(df.wash$R_FU_water_source_prim) = "Primary drinking water source?"
val_lab(df.wash$R_FU_water_source_prim) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            ")

var_lab(df.wash$R_FU_water_sec_yn) = "Any other source of drinking water?"
val_lab(df.wash$R_FU_water_sec_yn) = num_lab("
            1 Yes
            2 No
            999 Don't Know
            ")
var_lab(df.wash$R_FU_quant) = "How much drinking water came from primary water source?"
val_lab(df.wash$R_FU_quant) = num_lab("
            1	All of it
            2	Most of it
            3	Half of it
            4	Little of it
            5	None of it
            ")
var_lab(df.wash$R_FU_water_treat) = "Is primary drinking water source treated?"
val_lab(df.wash$R_FU_water_treat) = num_lab("
            1 Yes
            2 No
            999 Don't Know
            ")

var_lab(df.wash$R_FU_water_stored) = "Is the water stored currently in the house treated?"
val_lab(df.wash$R_FU_water_stored) = num_lab("
            1 Yes
            2 No
            999 Don't Know
            ")

df.append <- as.data.frame(matrix(NA, ncol = 3)) 
df.append_var <- as.data.frame(matrix(NA, ncol = 3))  

colnames(df.append) <- c('Var1', 'Freq', 'Prop')
colnames(df.append_var) <- c('Var1', 'Freq', 'Prop')

var_names <- names(df.wash)
for (i in var_names){
  
  df.append_var$Var1 <- i
  df.append <-  rbind(df.append,df.append_var)
  freq_tab <- as.data.frame(table(df.wash[,i]))
  prop_tab <- as.data.frame(prop(table(df.wash[,i])))
  prop_tab <- prop_tab %>% rename(Prop = Freq)
  freq_tab[,1] <- as.character(freq_tab[,1])
  
  df.stat <- merge(freq_tab, prop_tab) 
  colnames(df.stat) <- c("Var1", "Freq", "Prop")
  
  df.append <- rbind(df.append, df.stat)
}
df.append <- df.append %>% mutate(Var1 = ifelse(Var1 == "0", "No", Var1)) %>% 
  mutate(Var1 = ifelse(Var1 == "R_FU_water_source_prim", "Primary drinking water source?", 
                       ifelse(Var1 == "R_FU_water_sec_yn","Any other source of drinking water?", 
                              ifelse(Var1 == "R_FU_quant", "How much drinking water came from primary water source?", 
                                     ifelse(Var1 == "R_FU_water_treat", "Is primary drinking water source treated?", 
                                            ifelse(Var1 == "R_FU_water_stored", 
                                                   "Is the water stored currently in the house treated?", Var1)))))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))

star.out <- stargazer(df.append, summary=F, title= "WASH Section Summary",float=F,rownames = F,
                      covariate.labels=NULL)

star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Wash_HH_Survey.tex"))



#what treatment? 

df.treat <- df.temp.consent %>% filter(R_FU_water_treat == 1| R_FU_water_stored == 1) %>% select(R_FU_water_treat,R_FU_water_stored, R_FU_water_treat_type)
df.treat$R_FU_water_treat_type <- ordered(df.treat$R_FU_water_treat_type,
                                          levels = c(1,2,3,4, -77),
                                          labels = c("Filter the water through a cloth or sieve", 
                                                     "Let the water stand for some time ", 
                                                     "Boil the water", 
                                                     "Add chlorine/ bleaching powder", 
                                                     "Other"))


freq_tab <- table(df.treat$R_FU_water_treat_type)
prop_tab <- as.data.frame(prop(freq_tab))
prop_tab <- prop_tab %>% rename(Prop = Freq)
df.stat <- merge(freq_tab, prop_tab) 

df.stat$Prop <- round(proportions(df.stat$Freq), 2)
df.stat <- df.stat %>% rename("Type of treatment" = Var1)
stargazer(df.stat, summary=F, title= "WASH Section Summary",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_treat_HH_Survey.tex"))

#------------------------ Section B: Government Tap Specific Questions ----------------------------------------#


df.tap<- df.temp.consent %>% select(R_FU_tap_supply_freq, R_FU_tap_function, R_FU_tap_use_future)
#assign labels for each

var_lab(df.tap$R_FU_tap_supply_freq) = "How often is water supplied from government taps?"
val_lab(df.tap$R_FU_tap_supply_freq) = num_lab("
            1	Daily
            2	Few days in a week
            3	Once a week 
            4	Few times in a month
            5	Once a month
            6	No fixed schedule
            -77	Other
            999	Don’t know
            -98	Refused to answer    
            ")
var_lab(df.tap$R_FU_tap_function) = "In the last two weeks, have you not been able to collect water from taps?"
val_lab(df.tap$R_FU_tap_function) = num_lab("
           1 Yes
           2 No
           999 Don't Know    
            ")


var_lab(df.tap$R_FU_tap_use_future) = "How likely to use/continue the government tap for drinking?"
val_lab(df.tap$R_FU_tap_use_future) = num_lab("
           1	Very likely
           2	Somewhat likely
           3	Neither likely nor unlikely
           4	Somewhat Unlikely
           5	Very unlikely
            ") 


df.append <- as.data.frame(matrix(NA, ncol = 3)) 
df.append_var <- as.data.frame(matrix(NA, ncol = 3))  

colnames(df.append) <- c('Var1', 'Freq', 'Prop')
colnames(df.append_var) <- c('Var1', 'Freq', 'Prop')

var_names <- names(df.tap)
for (i in var_names){
  
  df.append_var$Var1 <- i
  df.append <-  rbind(df.append,df.append_var)
  freq_tab <- as.data.frame(table(df.tap[,i]))
  prop_tab <- as.data.frame(prop(table(df.tap[,i])))
  prop_tab <- prop_tab %>% rename(Prop = Freq)
  freq_tab[,1] <- as.character(freq_tab[,1])
  
  df.stat <- merge(freq_tab, prop_tab) 
  colnames(df.stat) <- c("Var1", "Freq", "Prop")
  
  df.append <- rbind(df.append, df.stat)
}
df.append <- df.append %>% mutate(Var1 = ifelse(Var1 == "0", "No", Var1)) %>% 
  mutate(Var1 = ifelse(Var1 == "R_FU_tap_supply_freq", "How often is water supplied from government taps?", 
                       ifelse(Var1 == "R_FU_tap_function",
                              "In the last two weeks, have you not been able to collect water from taps?", 
                              ifelse(Var1 == "R_FU_tap_use_future", 
                                     "How likely to use/continue the government tap for drinking?", 
                                     Var1)))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))




star.out <- stargazer(df.append, summary=F, title= "Tap Section Summary",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Tap_HH_Survey.tex"))


#------------------------ Section C: Chlorine Perceptions Questions ----------------------------------------#

df.cl<- df.temp.consent %>% select(R_FU_tap_taste_satisfied, R_FU_tap_taste_desc,  R_FU_tap_smell, R_FU_tap_color, 
                                   R_FU_tap_trust)
#assign labels for each
var_lab(df.cl$R_FU_tap_taste_satisfied) = "How satisfied are you with the taste of water from government taps?"
val_lab(df.cl$R_FU_tap_taste_satisfied) = num_lab("
            1	Very satisfied
            2	Satisfied
            3	Neither satisfied nor dissatisfied
            4	Dissatisfied
            5	Very dissatisfied
            999	Don’t know    
            ")
var_lab(df.cl$R_FU_tap_taste_desc) = "Describe the taste of water from government taps"
val_lab(df.cl$R_FU_tap_taste_desc) = num_lab("
            1	Good
            2	Medicine or chemical
            3	Metal
            4	Salty
            5	Bleach/chlorine
            999	Don’t know
            -77	Other    
            ") 
var_lab(df.cl$R_FU_tap_smell) = "Describe the smell of water from government taps"
val_lab(df.cl$R_FU_tap_smell) = num_lab("
            1	Good
            2	Medicine or chemical
            3	Metal
            4	Salty
            5	Bleach/chlorine
            999	Don’t know
            -77	Other    
            ")   
var_lab(df.cl$R_FU_tap_color) = "Describe the color of water from government taps"
val_lab(df.cl$R_FU_tap_color) = num_lab("
            1	No problems with the color or look
            2	Muddy/ sandy water
            3	Yellow-ish or reddish water (from iron)
            999	Don’t know
            -77	Other    
            ")   
var_lab(df.cl$R_FU_tap_trust) = "How confident are you in the water from government taps?"
val_lab(df.cl$R_FU_tap_trust) = num_lab("
            1	Very confident
            2	Somewhat confident
            3	Neither confident or not confident
            4	Somewhat not confident
            5	Not confident at all    
            ")   



df.append <- as.data.frame(matrix(NA, ncol = 3)) 
df.append_var <- as.data.frame(matrix(NA, ncol = 3))  

colnames(df.append) <- c('Var1', 'Freq', 'Prop')
colnames(df.append_var) <- c('Var1', 'Freq', 'Prop')

var_names <- names(df.cl)
for (i in var_names){
  
  df.append_var$Var1 <- i
  df.append <-  rbind(df.append,df.append_var)
  freq_tab <- as.data.frame(table(df.cl[,i]))
  prop_tab <- as.data.frame(prop(table(df.cl[,i])))
  prop_tab <- prop_tab %>% rename(Prop = Freq)
  freq_tab[,1] <- as.character(freq_tab[,1])
  
  df.stat <- merge(freq_tab, prop_tab) 
  colnames(df.stat) <- c("Var1", "Freq", "Prop")
  
  df.append <- rbind(df.append, df.stat)
}
df.append <- df.append %>% mutate(Var1 = ifelse(Var1 == "0", "No", Var1)) %>% 
  mutate(Var1 = ifelse(Var1 == "R_FU_tap_taste_satisfied", "How satisfied are you with the taste of water from government taps?", 
                       ifelse(Var1 == "R_FU_tap_taste_desc",
                              "Describe the taste of water from government taps", 
                              ifelse(Var1 == "R_FU_tap_smell", 
                                     "Describe the smell of water from government taps",
                                     ifelse(Var1 == "R_FU_tap_color",
                                            "Describe the color of water from government taps", 
                                            ifelse(Var1 == "R_FU_tap_trust",
                                                   "How confident are you in the water from government taps?", 
                                                   Var1)))))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))



star.out <- stargazer(df.append, summary=F, title= "Chlorine Perceptions Section Summary",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Chlorine_HH_Survey.tex"))


#Create a table on chlorine experience with treatment and drinking chlorinated water:

df.cl.exp<- df.temp.consent %>% select( R_FU_chlorine_yesno, R_FU_chlorine_drank_yesno )
var_lab(df.cl.exp$R_FU_chlorine_yesno) = "Have you ever used chlorine as a method for treating drinking water?"
val_lab(df.cl.exp$R_FU_chlorine_yesno) = num_lab("
           1 Yes
           2 No
           999 Don't Know     
            ")

var_lab(df.cl.exp$R_FU_chlorine_drank_yesno) = "Have you ever drunk water treated with chlorine?"
val_lab(df.cl.exp$R_FU_chlorine_drank_yesno) = num_lab("
           1 Yes
           2 No
           999 Don't Know     
            ")

df.exp <- as.data.frame(matrix(NA, ncol = 3)) 
df.exp_var <- as.data.frame(matrix(NA, ncol = 3))  

colnames(df.exp) <- c('Var1', 'Freq', 'Prop')
colnames(df.exp_var) <- c('Var1', 'Freq', 'Prop')

var_names <- names(df.cl.exp)
for (i in var_names){
  
  df.exp_var$Var1 <- i
  df.exp <-  rbind(df.exp,df.exp_var)
  freq_tab <- as.data.frame(table(df.cl.exp[,i]))
  prop_tab <- as.data.frame(prop(table(df.cl.exp[,i])))
  prop_tab <- prop_tab %>% rename(Prop = Freq)
  freq_tab[,1] <- as.character(freq_tab[,1])
  
  df.stat.exp <- merge(freq_tab, prop_tab) 
  colnames(df.stat.exp) <- c("Var1", "Freq", "Prop")
  
  df.exp <- rbind(df.exp, df.stat.exp)
}
df.exp <- df.exp %>% mutate(Var1 = ifelse(Var1 == "0", "No", Var1)) %>% 
  mutate(Var1 = ifelse(Var1 == "R_FU_chlorine_yesno", "Have you ever used chlorine as a method for treating drinking water?", 
                       ifelse(Var1 == "R_FU_chlorine_drank_yesno",
                              "Have you ever drunk water treated with chlorine?", 
                              Var1))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))


star.out <- stargazer(df.exp, summary=F, title= "Chlorine Experience Summary",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Chlorine_Exp_HH_Survey.tex"))
