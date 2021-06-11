# Tue Apr 06 11:34:00 2021 ------------------------------
## ---------------------------
##
## Script name: 04a_get_troughs.R
## previously: 16b of the same name
## Purpose of script:
##
##
## Date Created: 2021-04-23
## ---------------------------

# -- -- -- -- -- -- -- -- -- -- - 
# load libraries & functions ####
# -- -- -- -- -- -- -- -- -- -- -
library(data.table)
library(plyr)

source("./04_FUNCTIONS_get_troughs.R")


ini_div=0.000125

# -- -- -- -- -- 
# cmd inputs ####
# -- -- -- -- --

args=commandArgs(trailingOnly=TRUE)

level_trough = as.numeric(args[1])
model=as.character(args[2])
samps= as.numeric(args[3])
cluster=as.logical(args[4])
window_size=as.character(args[5])

if(!(exists("cluster"))){
  cluster=F
}

# -- -- -- -- -- -- -
# R STUDIO INPUT ####
# -- -- -- -- -- -- -
# ini_div=0.000125
# source("./link_2_scripts/04_FUNCTIONS_get_troughs.R")

# level_trough = 0.1
# model="f20_m10_g5"
# samps=10
# cluster=F
# window_size="large"

# -- -- -- -- -- 
# COLORS ####
# -- -- -- -- --

ver4="#a50f15"
ver3="#cd1319"
ver2="#ea1f26"
ver1="#f16a6e"

roxo="#984ea3"
azul="#2e96dc"
verde="#66a61e"
rosa="#e7298a"

win_basepair = get_window_size(window_size)

# -- -- -- -- -- 
# LOAD DATA ####
# -- -- -- -- --


if (Sys.info()[1] == "Windows"){
  df = fread(sprintf("genomic_profile_%s/genomic_profile_all_reps_%s_samp_%sinds_win_%s.txt.gz", window_size, model, samps, window_size))
  win_coord=fread(sprintf("./link_2_scripts/%s_win_coord.csv", window_size))
  head(win_coord)

}else if (Sys.info()[1] == "Linux"){
  df = fread(sprintf("genomic_profile_%s/genomic_profile_all_reps_%s_samp_%sinds_win_%s.txt.gz", window_size, model, samps, window_size))
  win_coord=fread(sprintf("%s_win_coord.csv", window_size))
  head(win_coord)
}


names(df)=c("gen", "cpop", "rep", "mean_pi_raw", "mean_pi_samp", "w_id")
head(df)
str(df)

df=merge(x=df, y=win_coord, by.x = "w_id", by.y = "id")


# if( model == "f20_m10_g5"){
#   replicates=c(seq(21,30), seq(45,50), seq(55,60))
# } else {
#   replicates=c(seq(1,60))
# }

# replicates=c(seq(1,60))
replicates=unique(df$rep)
used_gens=unique(df$gen)

f_dat=c()
for (r in replicates){
  a=Sys.time()
  
  for (i in used_gens){
    lala=get_summary_of_troughs(df, i, level_trough, r, win_basepair)
    if (!is.null(nrow(lala))){
      f_dat=rbind(f_dat, lala)
    } else {
      next
    }
  }
  b=Sys.time()
  print(paste0("Done: replicate", r, " - ", format(b-a, digits=4)))
  
  
}

write.table(f_dat, sprintf("complete_data_lvl_%s_%s_%sinds_wind_%s.txt", level_trough*100, model, samps, window_size), col.names = T, row.names = F)

tot_dat = ddply(f_dat, .(cpop, rep, gen), summarise, tot_win=sum(n_windows), mean_size=mean(size), tot_tr=mean(tot_tr), chr_tr=sum(size), prop_tr=sum(size)/1e8)


write.table(tot_dat, sprintf("summary_data_lvl_%s_%s_%sinds_win_%s.txt", level_trough*100, model, samps, window_size), col.names = T, row.names = F)

# save.image(sprintf("bkup_image_%s_lvl_%s_%sinds_win_%s.RData",  level_trough*100, model, samps, window_size))

