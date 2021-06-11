#!/bin/bash
#SBATCH --mail-user=fs190b61@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=bdw-invest,epyc2
###SBATCH --partition=empi,all
#SBATCH --mem-per-cpu=3G
####SBATCH --array=1
#SBATCH --output=./log_get_pi/output_%j_%a.txt
#SBATCH --error=./log_get_pi/error_%j_%a.txt
#SBATCH --time=02:00:00


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

script=03_Get_Pi_Profile.R
founders=${1}
mig=${2}
growth=${3}
inds=${4}
act_demes=${5}
old_demes=${6}
window_size=${7}
rep=${SLURM_ARRAY_TASK_ID}

cd sim_files/${rep}
printf "\n $1 $2 $3 $4 $5 $6 $7 $rep \n"

sfolder="genomic_profile_${window_size}"
mkdir -p ${sfolder}

ckout=genomic_profile_active_demes_f${founders}_m${mig}_g${growth}_r${rep}_resamp_${inds}inds
if [ -f $ckout.txt.gz ]
	then
	rm ./${sfolder}/$ckout.txt.gz
fi

cd $sfolder

echo $PWD

# ls -l ../../

printf "\n Rscript ../../../${script} ${founders} ${mig} ${growth} ${inds} ${act_demes} ${old_demes} ${window_size} ${rep} & \n" 
Rscript ../../../${script} ${founders} ${mig} ${growth} ${inds} ${act_demes} ${old_demes} ${window_size} ${rep} &

wait

gzip -f ${ckout}.txt

printf "\n end of TASK ID ${SLURM_ARRAY_TASK_ID} \n"