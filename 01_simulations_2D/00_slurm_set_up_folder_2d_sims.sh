#!/bin/bash
#SBATCH --mail-user=$USER@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=bdw-invest,epyc2
#SBATCH --output=./log/SET_UP_output_%j_%a.txt
#SBATCH --error=./log/SET_UP_error_%j_%a.txt
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=1G
prefix="2d_c1_gr30_l100_d100"
model=${prefix}_${1}
replicate=$SLURM_ARRAY_TASK_ID


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
slim_file="01_2D_expansion.slim"

for m in "${models[@]}"; do
    mkdir -p ./$m
    
    files=(${bash_file} ${slim_file})
    
    for f in "${files[@]}"; do
        cp $f $fwd_path/$m/$f
    done

    cp ./param_files/"params_${m}.sh" $fwd_path/$m/"params_${m}.sh"

done


cd ${model}

#all params come from here, plus $model
# /storage/homefs/fs19b061/fwd_RangeExpansion/param_files
source ./params_"${model}".sh

# SIMULATION SCRIPT PATH
original="${HOME}/2D_fwd_RangeExpansion"
sim_file="01_2D_expansion.slim"
sim_path="${HOME}/2D_fwd_RangeExpansion/${model}"

mkdir -p $sim_path/$replicate

sim_path=$sim_path/$replicate

cp $original/$sim_file $sim_path/$sim_file

cd $sim_path

sed -i "s/_burn_in_/$((burn+100))/g" $sim_path/$sim_file
sed -i "s/_other_gens_/$aftgen/g" $sim_path/$sim_file
sed -i "s/_end_sim_/$end/g" $sim_path/$sim_file


printf "\n end of sim TASK ID ${SLURM_ARRAY_TASK_ID} \n"