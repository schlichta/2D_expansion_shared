#!/bin/bash
#SBATCH --mail-user=$USER@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=bdw-invest,epyc2
####SBATCH --array=1
#SBATCH --output=./log/SIMULATIONS_output_%j_%a.txt
#SBATCH --error=./log/SIMULATIONS_error_%j_%a.txt
#SBATCH --time=05:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --tmp=5G
prefix="2d_c1_gr30_l100_d100"
model=${prefix}_${1}
nsamps=${2}


#where the script runs from, current $PWD
if [ $USER == "schlichta" ]
then
    fwd_path="/home/$USER/fwd_RangeExpansion"
    git_path="/home/$USER/RangeExpansion"
else
    fwd_path="$HOME/2D_fwd_RangeExpansion"
    git_path="$HOME/RangeExpansion"
	module load GCC
	module load R

fi

models=(${model})


bash_file="01_run_model_2d.sh"
# slim_file="01_2D_expansion.slim"

# for m in "${models[@]}"; do
#     mkdir -p ./$m
    
#     files=(${bash_file} ${slim_file})
    
#     for f in "${files[@]}"; do
#         cp $f $fwd_path/$m/$f
#     done

#     cp ./param_files/"params_${m}.sh" $fwd_path/$m/"params_${m}.sh"

# done


chmod 777 $fwd_path/*.sh
chmod 777 $fwd_path/*/*.sh

srun --ntasks=1 $fwd_path/$model/${bash_file} $model ${SLURM_ARRAY_TASK_ID} ${nsamps} &

wait


printf "\n end of sim TASK ID ${SLURM_ARRAY_TASK_ID} \n"