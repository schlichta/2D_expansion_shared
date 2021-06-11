# Thu Apr 22 19:54:14 2021 ------------------------------
## ---------------------------
##
## Script name: 03_Get_Pi_Profile.R
## modified version of "b14_Get_Pi_Profile.R"
## to account for: VCF use, sampling of individuals &
## 5 gen interval between samplings (mid growth phase)
##
## Purpose of script: window genome and calculate Pi
## Date Created: 2021-04-22
## ---------------------------

### LOAD PACKAGES -----------------------------

library("data.table")
library(rlist)


if (Sys.info()[1] == "Linux"){
  source("../../../03_FUNCTIONS_Get_Pi_Profile.R")
} else if (Sys.info()[1] == "Windows"){
  source("link_2_scripts/03_FUNCTIONS_Get_Pi_Profile.R")
}


# -- -- -- -- -- -- -- -- ---
# Command Line Arguments ####
# -- -- -- -- -- -- -- -- ---

args=commandArgs(trailingOnly=TRUE)

founders=as.integer(args[1])        #founders
mig= as.integer(args[2])            #migration
growth = as.integer(args[3])        #growth
inds=as.integer(args[4])            #number of samples
act_demes=as.logical(args[5])       #active demes
old_demes=as.logical(args[6])       # old demes
window_size=as.character(args[7])   # WinSize: small, med, large
rep= as.integer(args[8])            #replicate number

# -- -- -- -- -- - 
# RSTUDIO USE ####
# -- -- -- -- -- -
# 03_Get_Pi_Profile.R $fndr $mig $grwth $n_samp T F large $rep & 
# #___________________________________________
# #founder number||#migration| #gens to growth
# founders= 20; mig= 10; growth=5;
# #___________________________________________
# #replicate
# rep=1
# #number of samples:
# inds=10
# #active demes
# act_demes=TRUE
# # old demes
# old_demes=FALSE
# window_size="large"

# -- -- -- -- -- -
# LOAD INDICE ####
# -- -- -- -- -- -

print(getwd())

#Index file (guide to collect/open/use correct files)

if (Sys.info()[1] == "Linux"){
  ind_path="../../.."
  coord_path="../../.."
} else if (Sys.info()[1] == "Windows"){
  ind_path="."
  coord_path="./link_2_scripts"
}

if (act_demes == T & old_demes == F){
  indice = read.table(sprintf("%s/sampling_active_edge_demes.txt", ind_path), h=F)
} else if (old_demes == T & act_demes == F){
  indice = read.table(sprintf("%s/sampling_old_edge_demes.txt", ind_path), h=F)
}


names(indice) = c("gen", "pop")
names(indice)

win_coord=fread(sprintf("%s/%s_win_coord.csv", coord_path, window_size))
names(win_coord)

# -- -- -- -- -- -- -- -- -- -- -- ---
# Calculate Pi in Sliding windows ####
# -- -- -- -- -- -- -- -- -- -- -- ---

#155
#### fml=data.frame(indice[1:21,])
fml=data.frame(indice[1:nrow(indice),])

bigD=apply(fml, 1, function(x) loop_to_get_Pi(as.numeric(x['gen']), as.numeric(x['pop'])))

final_D=list.rbind(bigD)

if(act_demes == T & old_demes == F){
  write.table(final_D, sprintf("genomic_profile_active_demes_f%s_m%s_g%s_r%s_resamp_%sinds.txt", founders, mig, growth, rep, inds), col.names = T, row.names = F)
} else if (act_demes==F & old_demes==T){
  write.table(final_D, sprintf("genomic_profile_old_demes_f%s_m%s_g%s_r%s_resamp_%sinds.txt", founders, mig, growth, rep, inds), col.names = T, row.names = F)
}


