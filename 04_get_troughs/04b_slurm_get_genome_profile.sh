#!/bin/bash
#SBATCH --mail-user=fs190b61@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=bdw-invest,epyc2
#SBATCH --mem-per-cpu=10G
#SBATCH --array=1
#SBATCH --output=./log_files/s04b_output_%j_%a.txt
#SBATCH --error=./log_files/s04b_error_%j_%a.txt
#SBATCH --time=05:00:00


if [ $USER == "schlichta" ]
then
    printf "running on CMPG Matrix"
elif [ $USER == "flavia" ]
then
	printf "running on inspiron f5566"
else

	module load GCC
	module load R

fi

level=${1}
model=${2}
samps=${3}
wsize=${4}

script=NEW_04b_plot_results.R

printf "\n Rscript ${script} ${level} ${model} ${samps} T ${wsize} & \n"
Rscript ${script} ${level} ${model} ${samps} T ${wsize} &

wait

printf "\n end of TASK ID ${SLURM_ARRAY_TASK_ID} \n"