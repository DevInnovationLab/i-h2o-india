#---------------------------------------------------------------------------- 
# title: "Code for Descriptive Stats for Follow Up Round 1 HH Survey"
# author: "Astha Vohra"
# modified date: "2023-10-12"
#---------------------------------------------------------------------------- 

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

df.temp <- read_dta(paste0(user_path(),"2_deidentified/1_5_Followup_R1_cleaned.dta" ))
df.baseline <- read_xlsx(paste0(user_path(),"99_Preload/Followup_watersource_31 Jan 2024.xlsx"))

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

#create a date variable
df.temp$datetime <- strptime(df.temp$R_FU1_starttime, format = "%Y-%m-%d %H:%M:%S")

df.temp$date <- as.IDate(df.temp$datetime) 

#filter out the testing dates
df.temp <- df.temp %>% filter(date >= as.Date("2024-02-05"))

#------------------------ Keep consented cases ----------------------------------------#

df.temp.consent <- df.temp[which(df.temp$R_FU1_consent==1) ,]


#------------------------ Assign the correct treatment to villages ----------------------------------------#

df.temp.consent <- df.temp.consent %>% mutate(Treatment = ifelse(R_FU1_r_cen_village_name_str %in%
                                                                   c("Birnarayanpur","Nathma", "Badabangi","Naira", "Bichikote", "Karnapadu","Mukundpur", "Tandipur", "Gopi Kankubadi", "Asada"), "T", "C"))


#------------------------ Water Quality Stats ----------------------------------------#

bl <- df.temp.consent

# Displaying chlorine concentration for each village
# Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU1_fc_tap, R_FU1_fc_stored, R_FU1_tc_tap, R_FU1_tc_stored), values_to = "chlorine_concentration", names_to = "chlorine_test_type")
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE) %>% filter( chlorine_concentration != 999.0) 
p1 <- ggplot(data =chlorine) + geom_point(aes(x = chlorine_test_type, y = chlorine_concentration), size = 3) +
  facet_wrap(~ R_FU1_r_cen_village_name_str) + 
  labs(x = "Chlorine Test", y = "Chlorine Concentration (mg/L)") +
  theme_bw() + scale_x_discrete(labels=c("FCl-Stored" , "FCl-Running", "TCl-Stored", "TCl-Running"))+
  theme(axis.title.y = element_text(size = 32), axis.title.x = element_text(size = 32), 
        axis.text.x =  element_text(size = 18, face="bold"), axis.text.y =  element_text(size = 30, face="bold"), 
        strip.text = element_text(size = 40)) 


ggplot2::ggsave( paste0(overleaf(),"Figure/Chlorine-concentration-village_R1.png"), p1,  width = 21, height= 13,dpi=200)




# Displaying chlorine test data for all villages combined
# Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU1_fc_tap, R_FU1_fc_stored, R_FU1_tc_tap, R_FU1_tc_stored), values_to = "chlorine_concentration", names_to = "chlorine_test_type")
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE ) %>% filter(chlorine_concentration != 999.0 ) %>% 
  group_by(chlorine_test_type) %>% 
  mutate(mean_cl = round(mean(chlorine_concentration, na.rm  = T), digits = 2), 
         min_cl = round(min(chlorine_concentration, na.rm  = T),digits = 2), 
         max_cl = round(max(chlorine_concentration, na.rm  = T), digits = 2),
         perc_25 = round(quantile(chlorine_concentration, 0.25),digits = 2), 
         perc_50 = round(quantile(chlorine_concentration, 0.5),digits = 2), 
         perc_75 = round(quantile(chlorine_concentration, 0.75),digits = 2)) %>% 
  ungroup()

chlorine_stats  <- chlorine %>% filter(chlorine_concentration != 999) %>% select(chlorine_test_type, mean_cl, min_cl, perc_25, perc_50, perc_75, max_cl) %>% unique() %>%
  mutate(chlorine_test_type = ifelse(chlorine_test_type == "R_FU1_fc_tap", "Running- Free Cl", ifelse(
    chlorine_test_type == "R_FU1_fc_stored", "Stored- Free Cl", ifelse(
      chlorine_test_type == "R_FU1_tc_tap", "Running- Total Cl", ifelse(
        chlorine_test_type == "R_FU1_tc_stored", "Stored- Total Cl", chlorine_test_type ))))) %>%
  rename("Test Type" = chlorine_test_type,"Mean" = mean_cl, "Min" =  min_cl,  "Q1" = perc_25,  "Q2" = perc_50, "Q3" =perc_75,  "Max" =max_cl ) 
chlorine_stats <- as.data.table(chlorine_stats)

stargazer(chlorine_stats, summary=F, title= "",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_chlorine_stats_HH_Survey_R1.tex"))


p2 <- ggplot(data =chlorine) + geom_point(aes(x = chlorine_test_type, y = chlorine_concentration), size = 3) +
  labs(x = "Chlorine Test", y = "Chlorine Concentration (mg/L)")  + 
  geom_errorbar(aes(x = chlorine_test_type, y = chlorine_concentration, ymin = mean_cl - 1.96*sd(chlorine_concentration)/sqrt(length(chlorine_concentration)),
                    ymax = mean_cl + 1.96*sd(chlorine_concentration)/sqrt(length(chlorine_concentration))), width = 0.2, linewidth = 0.8, color = "red") + 
  theme_bw() +  scale_x_discrete(labels=c("FCl - Stored" , "FCl - Running", "TCl - Stored", "TCl - Running")) +
  theme(axis.title.y = element_text(size = 32), axis.title.x = element_text(size = 32), 
        axis.text.x =  element_text(size = 32, face="bold"), axis.text.y =  element_text(size = 30, face="bold")) 


ggplot2::ggsave( paste0(overleaf(),"Figure/Chlorine-concentration_R1.png"), p2,  width = 22, height= 15,dpi=200)

#-------------Chlorine by Treatment-------------#

# Arranging data so chlorine test data is in one column
chlorine <- bl%>%
  pivot_longer(cols = c(R_FU1_fc_tap, R_FU1_fc_stored, R_FU1_tc_tap, R_FU1_tc_stored), values_to = "chlorine_concentration", names_to = "chlorine_test_type")
#Removing NAs from no respondent being available
chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE ) %>% filter(chlorine_concentration != 999.0 ) %>% 
  group_by(chlorine_test_type, Treatment) %>% 
  mutate(mean_cl = round(mean(chlorine_concentration, na.rm  = T), digits = 2), 
         min_cl = round(min(chlorine_concentration, na.rm  = T),digits = 2), 
         max_cl = round(max(chlorine_concentration, na.rm  = T), digits = 2),
         perc_25 = round(quantile(chlorine_concentration, 0.25),digits = 2), 
         perc_50 = round(quantile(chlorine_concentration, 0.5),digits = 2), 
         perc_75 = round(quantile(chlorine_concentration, 0.75),digits = 2)) %>% 
  ungroup()

chlorine_stats  <- chlorine %>% filter(chlorine_concentration != 999) %>% select(chlorine_test_type,Treatment, mean_cl, min_cl, perc_25, perc_50, perc_75, max_cl) %>% unique() %>%
  mutate(chlorine_test_type = ifelse(chlorine_test_type == "R_FU1_fc_tap", "Running- Free Cl", ifelse(
    chlorine_test_type == "R_FU1_fc_stored", "Stored- Free Cl", ifelse(
      chlorine_test_type == "R_FU1_tc_tap", "Running- Total Cl", ifelse(
        chlorine_test_type == "R_FU1_tc_stored", "Stored- Total Cl", chlorine_test_type ))))) %>%
  rename("Test Type" = chlorine_test_type,"Mean" = mean_cl, "Min" =  min_cl,  "Q1" = perc_25,  "Q2" = perc_50, "Q3" =perc_75,  "Max" =max_cl ) 

chlorine_stats_wide <- chlorine_stats %>% pivot_wider(names_from = Treatment, values_from = c(Mean, Min, Q1, Q2, Q3, Max))

chlorine_stats <- as.data.table(chlorine_stats_wide)

stargazer(chlorine_stats, summary=F, title= "",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_chlorine_stats_treat_HH_Survey_R1.tex"))


# Displaying chlorine concentration for each village by treatment
# Arranging data so chlorine test data is in one column

chlorine <- chlorine%>%
  filter(is.na(chlorine_concentration) == FALSE) %>% filter( chlorine_concentration != 999.0) 
chlorine$test <- paste0(chlorine$chlorine_test_type, "-", chlorine$Treatment)
p3 <- ggplot(data =chlorine) + geom_point(aes(x = test, y = chlorine_concentration, color= Treatment), size = 3) +
  labs(x = "Chlorine Test", y = "Chlorine Concentration (mg/L)")  + 
  geom_errorbar(aes(x = test, y = chlorine_concentration, ymin = mean_cl - 1.96*sd(chlorine_concentration)/sqrt(length(chlorine_concentration)),
                    ymax = mean_cl + 1.96*sd(chlorine_concentration)/sqrt(length(chlorine_concentration))), width = 0.2, linewidth = 0.8, color = "red") + 
  theme_bw() +  scale_x_discrete(labels=c("Control: FCl - Stored", "Treatment: FCl - Stored" ,"Control: FCl - Running", "Treatment: FCl - Running","Control: TCl - Stored", "Treatment: TCl - Stored", "Control: TCl - Running", "Treatment: TCl - Running" )) +
  theme(axis.title.y = element_text(size = 32), axis.title.x = element_text(size = 32), 
        axis.text.x =  element_text(size = 32, face="bold"), axis.text.y =  element_text(size = 30, face="bold")) + coord_flip()


ggplot2::ggsave( paste0(overleaf(),"Figure/Chlorine-concentration_treat_R1.png"), p3,  width = 22, height= 15,dpi=200)

#------------------------ Section A: WASH Access ----------------------------------------#


#-------------Process Baseline variables for WASH-------------#

df.baseline$R_Cen_a13_water_source_sec <- gsub("\\s+", " ", str_trim(df.baseline$R_Cen_a13_water_source_sec))

df.baseline.long <- str_split_fixed(df.baseline$R_Cen_a13_water_source_sec, " ", 2) %>% 
  data.frame() %>% 
  rename(Sec_source_b1 = X1, Sec_source_b2 = X2) %>% 
  cbind(df.baseline, .)


var_lab(df.baseline.long$Sec_source_b1) = "Secondary drinking water source1"
val_lab(df.baseline.long$Sec_source_b1) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")
var_lab(df.baseline.long$Sec_source_b2) = "Secondary drinking water source2"
val_lab(df.baseline.long$Sec_source_b2) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")


df.baseline.long <- df.baseline.long %>% mutate(Prim_source_b = ifelse(R_Cen_a12_water_source_prim == "Government provided household Taps (supply paani)", 1, 
                                                                ifelse(R_Cen_a12_water_source_prim == "Government provided community standpipe",2,
                                                                ifelse(R_Cen_a12_water_source_prim =="Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",3,
                                                                ifelse(R_Cen_a12_water_source_prim == "Manual handpump",4,
                                                                ifelse(R_Cen_a12_water_source_prim == "Covered dug well",5,
                                                                ifelse(R_Cen_a12_water_source_prim == "Directly fetched by surface water",6,
                                                                ifelse(R_Cen_a12_water_source_prim == "Uncovered dug well",7,
                                                                ifelse(R_Cen_a12_water_source_prim == "Private Surface well",8,
                                                                ifelse(R_Cen_a12_water_source_prim == "Borewell operated by electric pump",9,
                                                                ifelse(R_Cen_a12_water_source_prim == "Household tap connections not connected to RWSS/Basudha/JJM tank", 10, -77)))))))))))


var_lab(df.baseline.long$Prim_source_b) = "Primary drinking water source at baseline"
val_lab(df.baseline.long$Prim_source_b) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")  

df.baseline.long <- df.baseline.long %>% rename(unique_id_num = unique_id)
#-------------Process WASH variables-------------#

df.wash <- df.temp.consent %>% select(unique_id_num,R_FU1_water_source_prim, R_FU1_water_sec_yn,
                                      R_FU1_water_source_sec, 
                                      R_FU1_quant, R_FU1_water_treat, R_FU1_water_stored, R_FU1_r_cen_village_name_str,
                                      R_FU1_water_source_main_sec, R_FU1_tap_use_drinking)
#assign labels for each

var_lab(df.wash$R_FU1_water_source_prim) = "Primary drinking water source?"
val_lab(df.wash$R_FU1_water_source_prim) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")
df.wash$R_FU1_water_source_sec <- gsub("\\s+", " ", str_trim(df.wash$R_FU1_water_source_sec))

df.wash.new <- str_split_fixed(df.wash$R_FU1_water_source_sec, " ", 3) %>% 
  data.frame() %>% 
  rename(Sec_source1 = X1, Sec_source2 = X2, Sec_source3 = X3) %>% 
  cbind(df.wash, .)

var_lab(df.wash.new$Sec_source1) = "Secondary drinking water source?"
val_lab(df.wash.new$Sec_source1) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")
var_lab(df.wash.new$Sec_source2) = "Secondary drinking water source?"
val_lab(df.wash.new$Sec_source2) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")

var_lab(df.wash.new$Sec_source3) = "Secondary drinking water source?"
val_lab(df.wash.new$Sec_source3) = num_lab("
            1 Government provided household Taps (supply paani)
            2 Government provided community standpipe    
            3 Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)
            4	Manual handpump
            5	Covered dug well
            6	Directly fetched by surface water
            7	Uncovered dug well
            8	Private Surface well    
            9 Borewell operated by electric pump
            10 Household tap connections not connected to RWSS/Basudha/JJM tank
            -77 Other
            ")
var_lab(df.wash.new$R_FU1_water_sec_yn) = "Any other source of drinking water?"
val_lab(df.wash.new$R_FU1_water_sec_yn) = num_lab("
            1 Yes
            2 No
            999 Don't Know
            ")

#-------------MERGE-------------#

df.combine <- merge(df.wash.new, df.baseline.long, by = "unique_id_num")

# include here people who switched from Primary water to a different primary water source
df.switch <- df.combine %>% filter(R_FU1_water_source_prim != Prim_source_b) %>% select(Prim_source_b,R_FU1_water_source_prim, R_FU1_r_cen_village_name_str )

df.switch$Prim_source_b <- factor(df.switch$Prim_source_b,
                    levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                    labels = c("Government provided household Taps (supply paani)",
                               "Government provided community standpipe",    
                               "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                               "Manual handpump",
                               "Covered dug well",
                               "Directly fetched by surface water",
                               "Uncovered dug well",
                               "Private Surface well",    
                               "Borewell operated by electric pump",
                               "Household tap connections not connected to RWSS/Basudha/JJM tank",
                               "Other"))

df.switch$R_FU1_water_source_prim <- factor(df.switch$R_FU1_water_source_prim,
                                  levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                                  labels = c("Government provided household Taps (supply paani)",
                                             "Government provided community standpipe",    
                                             "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                                             "Manual handpump",
                                             "Covered dug well",
                                             "Directly fetched by surface water",
                                             "Uncovered dug well",
                                             "Private Surface well",    
                                             "Borewell operated by electric pump",
                                             "Household tap connections not connected to RWSS/Basudha/JJM tank",
                                             "Other"))

df.switch <- df.switch %>%
  rename("Follow Up primary source" = R_FU1_water_source_prim, "Baseline primary source" = Prim_source_b, Village = R_FU1_r_cen_village_name_str )
star.out <- stargazer(df.switch, summary=F, title= "WASH Section - Switch out of Government Provided Taps",float=F)

star.out <- stargazer(df.switch, summary=F, title= "Switch in primary water source",float=F,rownames = F,
                      covariate.labels=NULL)

star.out <- sub(" ccc"," |L|L|L|L|", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Switch_HH_Survey_R1.tex"))



df.switch <- df.combine %>%  mutate(Switched = ifelse(R_FU1_water_source_prim != Prim_source_b,1,0)) %>%
  mutate(Switched_from_jjm = ifelse(R_FU1_water_source_prim != Prim_source_b & Prim_source_b == 1 ,1,0)) %>% 
           mutate(Switched_to_jjm = ifelse(R_FU1_water_source_prim != Prim_source_b & R_FU1_water_source_prim == 1 ,1,0)) %>%
                    select(Switched, Switched_from_jjm, Switched_to_jjm) 

df.switch$Switched <- factor(df.switch$Switched,
                                  levels = c(1,0),
                                  labels = c("Yes",
                                             "No") ) 
df.switch$Switched_from_jjm <- factor(df.switch$Switched_from_jjm,
                             levels = c(1,0),
                             labels = c("Yes",
                                        "No") ) 
df.switch$Switched_to_jjm <- factor(df.switch$Switched_to_jjm,
                             levels = c(1,0),
                             labels = c("Yes",
                                        "No") ) 
df.append.switch <- as.data.frame(matrix(NA, ncol = 3)) 
df.append.switch_var <- as.data.frame(matrix(NA, ncol = 3))  

colnames(df.append.switch) <- c('Var1', 'Freq', 'Prop')
colnames(df.append.switch_var) <- c('Var1', 'Freq', 'Prop')

var_names <- names(df.switch)
for (i in var_names){
  
  df.append.switch_var$Var1 <- i
  df.append.switch <-  rbind(df.append.switch,df.append.switch_var)
  freq_tab <- as.data.frame(table(df.switch[,i]))
  prop_tab <- as.data.frame(prop(table(df.switch[,i])))
  prop_tab <- prop_tab %>% rename(Prop = Freq)
  freq_tab[,1] <- as.character(freq_tab[,1])
  
  df.stat <- merge(freq_tab, prop_tab) 
  colnames(df.stat) <- c("Var1", "Freq", "Prop")
  
  df.append.switch <- rbind(df.append.switch, df.stat)
}


star.out <- stargazer(df.append.switch, summary=F, title= "Switch in primary water source",float=F,rownames = F,
                      covariate.labels=NULL)

star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Switch_prop_HH_Survey_R1.tex"))




# include here people who switched from Primary water to a different secondary water source as JJM tap



df.switch.sec <- df.combine %>% filter(Prim_source_b == 1 & 
                                         (Sec_source1 == 1 | Sec_source2 == 1| Sec_source3 == 1)) %>% 
  select(Prim_source_b,R_FU1_water_source_prim, Sec_source1, Sec_source2, Sec_source3, R_FU1_r_cen_village_name_str , R_FU1_tap_use_drinking)


df.switch.sec$Prim_source_b <- factor(df.switch.sec$Prim_source_b,
                                            levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                                            labels = c("Government provided household Taps (supply paani)",
                                                       "Government provided community standpipe",    
                                                       "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                                                       "Manual handpump",
                                                       "Covered dug well",
                                                       "Directly fetched by surface water",
                                                       "Uncovered dug well",
                                                       "Private Surface well",    
                                                       "Borewell operated by electric pump",
                                                       "Household tap connections not connected to RWSS/Basudha/JJM tank",
                                                       "Other"))
df.switch.sec$R_FU1_water_source_prim <- factor(df.switch.sec$R_FU1_water_source_prim,
                                      levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                                      labels = c("Government provided household Taps (supply paani)",
                                                 "Government provided community standpipe",    
                                                 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                                                 "Manual handpump",
                                                 "Covered dug well",
                                                 "Directly fetched by surface water",
                                                 "Uncovered dug well",
                                                 "Private Surface well",    
                                                 "Borewell operated by electric pump",
                                                 "Household tap connections not connected to RWSS/Basudha/JJM tank",
                                                 "Other"))

df.switch.sec$Sec_source1 <- factor(df.switch.sec$Sec_source1,
                                      levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                                      labels = c("Government provided household Taps (supply paani)",
                                                 "Government provided community standpipe",    
                                                 "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                                                 "Manual handpump",
                                                 "Covered dug well",
                                                 "Directly fetched by surface water",
                                                 "Uncovered dug well",
                                                 "Private Surface well",    
                                                 "Borewell operated by electric pump",
                                                 "Household tap connections not connected to RWSS/Basudha/JJM tank",
                                                 "Other"))

df.switch.sec$Sec_source2 <- factor(df.switch.sec$Sec_source2,
                                    levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                                    labels = c("Government provided household Taps (supply paani)",
                                               "Government provided community standpipe",    
                                               "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                                               "Manual handpump",
                                               "Covered dug well",
                                               "Directly fetched by surface water",
                                               "Uncovered dug well",
                                               "Private Surface well",    
                                               "Borewell operated by electric pump",
                                               "Household tap connections not connected to RWSS/Basudha/JJM tank",
                                               "Other"))
df.switch.sec$Sec_source3 <- factor(df.switch.sec$Sec_source3,
                                    levels = c(1,2,3,4,5,6,7,8,9,10,-77),
                                    labels = c("Government provided household Taps (supply paani)",
                                               "Government provided community standpipe",    
                                               "Gram Panchayat/Other Community Standpipe (e.g. solar pump, PVC tank)",
                                               "Manual handpump",
                                               "Covered dug well",
                                               "Directly fetched by surface water",
                                               "Uncovered dug well",
                                               "Private Surface well",    
                                               "Borewell operated by electric pump",
                                               "Household tap connections not connected to RWSS/Basudha/JJM tank",
                                               "Other"))

df.switch.sec$R_FU1_tap_use_drinking <- factor(df.switch.sec$R_FU1_tap_use_drinking,
                                      levels = c(1,2,3,4,-77),
                                      labels = c("Today",
                                                 "Yesterday",    
                                                 "Earlier this week",
                                                 "Earlier this month",
                                                 "Other"))

df.switch.sec <- df.switch.sec %>%
  rename("Follow Up primary source" = R_FU1_water_source_prim, "Baseline primary source" = Prim_source_b, 
         Village = R_FU1_r_cen_village_name_str , "Last time used JJM taps" = R_FU1_tap_use_drinking)
star.out <- stargazer(df.switch.sec, summary=F, title= "WASH Section - Switch to Government Provided Taps as secondary",float=F)

star.out <- sub(" cccccccc"," |L|L|L|L|L|L|L|L|", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Switch_prim_sec_prop_HH_Survey_R1.tex"))

#-------------cooking issue stats-------------#


var_lab(df.temp.consent$R_FU1_cooking_issue) = "Any cooking issue experienced?"
val_lab(df.temp.consent$R_FU1_cooking_issue) = num_lab("
            1 Yes
            2 No
            999 Don't Know
            ")
df.cook <- df.temp.consent %>% select(R_FU1_cooking_issue)
df.append.cook <- as.data.frame(matrix(NA, ncol = 3)) 
df.append.cook_var <- as.data.frame(matrix(NA, ncol = 3))  

colnames(df.append.cook) <- c('Var1', 'Freq', 'Prop')
colnames(df.append.cook_var) <- c('Var1', 'Freq', 'Prop')

var_names <- names(df.cook)
for (i in var_names){
  
  df.append.cook_var$Var1 <- i
  df.append.cook <-  rbind(df.append.cook,df.append.cook_var)
  freq_tab <- as.data.frame(table(df.cook[,i]))
  prop_tab <- as.data.frame(prop(table(df.cook[,i])))
  prop_tab <- prop_tab %>% rename(Prop = Freq)
  freq_tab[,1] <- as.character(freq_tab[,1])
  
  df.stat <- merge(freq_tab, prop_tab) 
  colnames(df.stat) <- c("Var1", "Freq", "Prop")
  
  df.append.cook <- rbind(df.append.cook, df.stat)
}

df.append.cook <- df.append.cook %>% mutate(Var1 = ifelse(Var1 == "R_FU1_cooking_issue", 
                                                          "Any issues in using JJM tap water for cooking? (in 1 month)",
                                                    ifelse(Var1 == "0", "No", Var1 ))) 

star.out <- stargazer(df.append.cook, summary=F, title= "Issue faced in using JJM for cooking",float=F,rownames = F,
                      covariate.labels=NULL)

star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Cooking_prop_HH_Survey_R1.tex"))


df.cooking <- df.temp.consent %>% filter(R_FU1_cooking_issue == 1) %>% select(R_FU1_cooking_issue_reason, R_FU1_r_cen_village_name_str) 

df.cooking$R_FU1_cooking_issue_reason <- gsub("\\s+", " ", str_trim(df.cooking$R_FU1_cooking_issue_reason))

df.cooking <- str_split_fixed(df.cooking$R_FU1_cooking_issue_reason, " ", 2) %>% 
  data.frame() %>% 
  rename(Reason1 = X1, Reason2 = X2) %>% 
  cbind(df.cooking, .)
df.cooking$Reason1 <- factor(df.cooking$Reason1,
                                               levels = c(1,2,3,4,5,-77),
                                               labels = c("Insufficient water supply for cooking",
                                                          "Water has been too muddy/silty to cook with",    
                                                          "Bad taste or smell of the water or prepared food",
                                                          "Fermented rice/pakhala has not cooked properly",
                                                          "Other food has not cooked properly",
                                                          "Other"))
df.cooking$Reason2 <- factor(df.cooking$Reason2,
                             levels = c(1,2,3,4,5,-77),
                             labels = c("Insufficient water supply for cooking",
                                        "Water has been too muddy/silty to cook with",    
                                        "Bad taste or smell of the water or prepared food",
                                        "Fermented rice/pakhala has not cooked properly",
                                        "Other food has not cooked properly",
                                        "Other"))

df.cooking <- df.cooking %>%
  rename("Issues faced in Cooking - reason 1" = Reason1,"Issues faced in Cooking - reason 2" = Reason2,
         Village = R_FU1_r_cen_village_name_str ) %>% select(-R_FU1_cooking_issue_reason)
star.out <- stargazer(df.cooking, summary=F, title= "Issues faced in using JJM for cooking",float=F)

star.out <- sub(" ccc"," |L|L|L|L|", star.out) 
starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Cooking_HH_Survey_R1.tex"))


#-------


df.wash <- df.wash %>% select(R_FU1_water_source_prim,R_FU1_water_sec_yn , R_FU1_quant, R_FU1_water_treat ,R_FU1_water_stored)
var_lab(df.wash$R_FU1_quant) = "How much drinking water came from primary water source?"
val_lab(df.wash$R_FU1_quant) = num_lab("
            1	All of it
            2	Most of it
            3	Half of it
            4	Little of it
            5	None of it
            ")
var_lab(df.wash$R_FU1_water_treat) = "Is primary drinking water source treated?"
val_lab(df.wash$R_FU1_water_treat) = num_lab("
            1 Yes
            2 No
            999 Don't Know
            ")

var_lab(df.wash$R_FU1_water_sec_yn) = "Any other source of drinking water?"
val_lab(df.wash$R_FU1_water_sec_yn) = num_lab("
            1 Yes
            2 No
            ")
var_lab(df.wash$R_FU1_water_stored) = "Is the water stored currently in the house treated?"
val_lab(df.wash$R_FU1_water_stored) = num_lab("
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
df.append <- df.append %>% mutate(Var1 = ifelse(Var1 == "0", "No", ifelse(Var1 == "1", "Yes", Var1))) %>% 
  mutate(Var1 = ifelse(Var1 == "R_FU1_water_source_prim", "Primary drinking water source?", 
                       ifelse(Var1 == "R_FU1_water_sec_yn","Any other source of drinking water?", 
                              ifelse(Var1 == "R_FU1_quant", "How much drinking water came from primary water source?", 
                                     ifelse(Var1 == "R_FU1_water_treat", "Is primary drinking water source treated?", 
                                            ifelse(Var1 == "R_FU1_water_stored", 
                                                   "Is the water stored currently in the house treated?", Var1)))))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))

star.out <- stargazer(df.append, summary=F, title= "WASH Section Summary",float=F,rownames = F,
                      covariate.labels=NULL)

star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Wash_HH_Survey_R1.tex"))



#what treatment? 

df.treat <- df.temp.consent %>% filter(R_FU1_water_treat == 1| R_FU1_water_stored == 1) %>% select(R_FU1_water_treat,R_FU1_water_stored, R_FU1_water_treat_type)
df.treat$R_FU1_water_treat_type <- ordered(df.treat$R_FU1_water_treat_type,
                                          levels = c(1,2,3,4, -77),
                                          labels = c("Filter the water through a cloth or sieve", 
                                                     "Let the water stand for some time ", 
                                                     "Boil the water", 
                                                     "Add chlorine/ bleaching powder", 
                                                     "Other"))


freq_tab <- table(df.treat$R_FU1_water_treat_type)
prop_tab <- as.data.frame(prop(freq_tab))
prop_tab <- prop_tab %>% rename(Prop = Freq)
df.stat <- merge(freq_tab, prop_tab) 

df.stat$Prop <- round(proportions(df.stat$Freq), 2)
df.stat <- df.stat %>% rename("Type of treatment" = Var1)
stargazer(df.stat, summary=F, title= "WASH Section Summary",float=F,rownames = F,
          covariate.labels=NULL, out=paste0(overleaf(),"Table/Table_treat_HH_Survey_R1.tex"))

#------------------------ Section B: Government Tap Specific Questions ----------------------------------------#


df.tap<- df.temp.consent %>% select(R_FU1_tap_supply_freq, R_FU1_tap_function, R_FU1_tap_use_future)
#assign labels for each

var_lab(df.tap$R_FU1_tap_supply_freq) = "How often is water supplied from government taps?"
val_lab(df.tap$R_FU1_tap_supply_freq) = num_lab("
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
var_lab(df.tap$R_FU1_tap_function) = "In the last two weeks, have you not been able to collect water from taps?"
val_lab(df.tap$R_FU1_tap_function) = num_lab("
           1 Yes
           2 No
           999 Don't Know    
            ")


var_lab(df.tap$R_FU1_tap_use_future) = "How likely to use/continue the government tap for drinking?"
val_lab(df.tap$R_FU1_tap_use_future) = num_lab("
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
  mutate(Var1 = ifelse(Var1 == "R_FU1_tap_supply_freq", "How often is water supplied from government taps?", 
                       ifelse(Var1 == "R_FU1_tap_function",
                              "In the last two weeks, have you not been able to collect water from taps?", 
                              ifelse(Var1 == "R_FU1_tap_use_future", 
                                     "How likely to use/continue the government tap for drinking?", 
                                     Var1)))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))




star.out <- stargazer(df.append, summary=F, title= "Tap Section Summary",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Tap_HH_Survey_R1.tex"))


#------------------------ Section C: Chlorine Perceptions Questions ----------------------------------------#

df.cl<- df.temp.consent %>% select(R_FU1_tap_taste_satisfied, 
                                   R_FU1_tap_trust)
#assign labels for each
var_lab(df.cl$R_FU1_tap_taste_satisfied) = "How satisfied are you with the taste of water from government taps?"
val_lab(df.cl$R_FU1_tap_taste_satisfied) = num_lab("
            1	Very satisfied
            2	Satisfied
            3	Neither satisfied nor dissatisfied
            4	Dissatisfied
            5	Very dissatisfied
            999	Don’t know    
            ")



var_lab(df.cl$R_FU1_tap_trust) = "How confident are you in the water from government taps?"
val_lab(df.cl$R_FU1_tap_trust) = num_lab("
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
  mutate(Var1 = ifelse(Var1 == "R_FU1_tap_taste_satisfied", "How satisfied are you with the taste of water from government taps?", 
                       ifelse(Var1 == "R_FU1_tap_taste_desc",
                              "Describe the taste of water from government taps", 
                              ifelse(Var1 == "R_FU1_tap_smell", 
                                     "Describe the smell of water from government taps",
                                     ifelse(Var1 == "R_FU1_tap_color",
                                            "Describe the color of water from government taps", 
                                            ifelse(Var1 == "R_FU1_tap_trust",
                                                   "How confident are you in the water from government taps?", 
                                                   Var1)))))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))



star.out <- stargazer(df.append, summary=F, title= "Chlorine Perceptions Section Summary",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}c{2cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Chlorine_HH_Survey_R1.tex"))


#Create a table on chlorine experience with treatment and drinking chlorinated water:

df.cl.exp<- df.temp.consent %>% select( R_FU1_chlorine_yesno, R_FU1_chlorine_drank_yesno )
var_lab(df.cl.exp$R_FU1_chlorine_yesno) = "Have you ever used chlorine as a method for treating drinking water?"
val_lab(df.cl.exp$R_FU1_chlorine_yesno) = num_lab("
           1 Yes
           2 No
           999 Don't Know     
            ")

var_lab(df.cl.exp$R_FU1_chlorine_drank_yesno) = "Have you ever drunk water treated with chlorine?"
val_lab(df.cl.exp$R_FU1_chlorine_drank_yesno) = num_lab("
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
  mutate(Var1 = ifelse(Var1 == "R_FU1_chlorine_yesno", "Have you ever used chlorine as a method for treating drinking water?", 
                       ifelse(Var1 == "R_FU1_chlorine_drank_yesno",
                              "Have you ever drunk water treated with chlorine?", 
                              Var1))) %>%
  rename(Question = Var1) %>% mutate(Prop = round(Prop, 2))


star.out <- stargazer(df.exp, summary=F, title= "Chlorine Experience Summary",float=F,rownames = F,
                      covariate.labels=NULL)
star.out <- sub(" ccc"," l{5cm}c{2cm}c{2cm}", star.out) 

starpolishr::star_tex_write(star.out,  file =paste0(overleaf(),"Table/Table_Chlorine_Exp_HH_Survey_R1.tex"))
