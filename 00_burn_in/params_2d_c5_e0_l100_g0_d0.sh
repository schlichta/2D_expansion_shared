#!/bin/bash

# Parameters for the model (originally model 2)
# MODEL 1 (also used as "control")
model=2d_c5_e0_l100_g0_d0

#length of chromosome; chrL=10000000
chrL=100000000
#mutation rate
mu=1.25e-8
#recombination
rho=1e-8
#number of core demes
core=1
#max pop size
maxN=500
#end of burn-in stage; burn=5000
burn=$((core*5*maxN*10-100))
# #gens after burn_in 
# aftgen=$((burn+1))
# #end simulation; end=500
# end=$((burn+500+100))
# Number of founders
b4gen=$((burn-1))