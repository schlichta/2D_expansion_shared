#!/bin/bash
#SBATCH --mail-user=$USER@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
###SBATCH --partition=empi,all
#SBATCH --partition=bdw-invest,epyc2
####SBATCH --array=1
#SBATCH --output=./log_allele_count/output_%j_%a.txt
#SBATCH --error=./log_allele_count/error_%j_%a.txt
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=5G

# fnd=${1}
# mig=${2}
# grw=${3}
model=${1}
rep=${SLURM_ARRAY_TASK_ID}

script=02_get_allele_counts_for_pi_calcul.sh

chmod 777 ${script}

# srun --ntasks=1 ${script} ${fnd} ${mig} ${grw} &

printf "\n srun --ntasks=1 ${script} ${model} & \n"
srun --ntasks=1 ${script} ${model} &

wait

printf "\n end of sim TASK ID ${SLURM_ARRAY_TASK_ID} \n"