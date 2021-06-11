#!/bin/bash
#SBATCH --mail-user=$USER@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=bdw-invest,epyc2
######SBATCH --array=1
#SBATCH --output=./log/burnin_output_%j_%a.txt
#SBATCH --error=./log/burnin_error_%j_%a.txt


model=$1

printf "\n node_id: ${SLURM_NODEID} \n"
printf "job_node_list: ${SLURM_JOB_NODELIST} \n"
printf "job_numb_nodes: ${SLURM_JOB_NUM_NODES} \n"
printf "job_partition: ${SLURM_JOB_PARTITION} \n"


#where the script runs from, current $PWD
if [ $USER == "schlichta" ]
then
    fwd_path="/home/$USER/fwd_RangeExpansion"
    git_path="/home/$USER/RangeExpansion"
else
    fwd_path="/storage/homefs/$USER/2D_fwd_RangeExpansion"
    git_path="/storage/homefs/$USER/RangeExpansion"
	module load GCC
	module load R

fi

# models=($mod2 $mod3)
models=($model)

if [ ${SLURM_ARRAY_TASK_ID} == 1 ]
then
    for m in "${models[@]}"; do
        mkdir -p ./$m

        files=("00_run_model.sh" "00_burnin_2D_expansion.slim")

        for f in "${files[@]}"; do
            cp $f $fwd_path/$m/$f
        done

        cp "./param_files/params_${m}.sh" $fwd_path/$m/"params_${m}.sh"

    done
fi    

chmod 777 $fwd_path/*.sh
chmod 777 $fwd_path/*/*.sh

srun --ntasks=1 $fwd_path/$model/00_run_model.sh $(echo $model) ${SLURM_ARRAY_TASK_ID} &

wait


printf "\n end of sim TASK ID ${SLURM_ARRAY_TASK_ID} \n"