# Fri May 21 12:29:57 2021 ------------------------------
## ---------------------------
##
## Script name: 
##
## Purpose of script:
##
##
## Date Created: 2021-05-21
## ---------------------------
## ---------------------------
## Script name: b15_plot_results.R
## (modified b12 of same name)
## ---------------------------

# -- -- -- -- -- -- -- -- -- -- - 
# load libraries & functions ####
# -- -- -- -- -- -- -- -- -- -- -
library(data.table)
library(plyr)

source("./04_FUNCTIONS_get_troughs.R")
# source("b15_FUNCTIONS_get_troughs.R")

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
# model="2d_f20_m10_g5"
# samps=10
# cluster=F
# window_size="med"

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

win_basepair=get_window_size(window_size)

# -- -- -- -- -- 
# LOAD DATA ####
# -- -- -- -- --


if (Sys.info()[1] == "Windows"){
  df = fread(sprintf("./r_%s/genomic_profile_%s/genomic_profile_all_reps_%s_samp_%sinds_win_%s.txt.gz", model, window_size, model, samps, window_size))
  win_coord=fread(sprintf("./link_2_scripts/%s_win_coord.csv", window_size))
  head(win_coord)

}else if (Sys.info()[1] == "Linux"){
 # genomic_profile_all_reps_f20_m10_g5_tot_mig_samp_10inds_win_med.txt.gz
  df = fread(sprintf("genomic_profile_%s/genomic_profile_all_reps_%s_samp_%sinds_win_%s.txt.gz", window_size, model, samps, window_size))
  win_coord=fread(sprintf("%s_win_coord.csv", window_size))
  head(win_coord)
}


names(df)=c("gen", "cpop", "rep", "mean_pi_raw", "mean_pi_samp", "w_id")
head(df)
str(df)

df=merge(x=df, y=win_coord, by.x = "w_id", by.y = "id")


replicates=unique(df$rep)
smp_rep=sample(replicates, 1)
used_gens=unique(df$gen)
pdf(sprintf("genomic_profile_r%s_over_generations_COMPLETE_%s_%sinds_%s.pdf", smp_rep, model, samps, format(Sys.time(), "%d_%b_%Hh_%Mm_%Ss")), width = 16, height = 8.3)

par(mfrow=c(1,1))
for (i in used_gens){
  
  plot_graph_per_gen_complete(i, smp_rep, df, T, .1, 1.50e-4, win_basepair)
}

dev.off()