#!/bin/bash
# to run each different model, must copy and paste this file (run_model.sh) and simulation file to the model folder (e.g. /home/.../$USER/fwd_RangeExpansion/c5_e5_l10_i100_5gen)

# in bash $1 is the first argument used in command line when calling the script
printf "\n running model $1 \n"
printf "\n changing to directory $PWD/$1 \n"
printf "\n array/replicate: $2 - $SLURM_ARRAY_TASK_ID \n"

model=$1
replicate=$SLURM_ARRAY_TASK_ID
# replicate=$2


cd $PWD/$1

#all params come from here, plus $model
# param_files
source ./params_"${model}".sh

if [ $USER == "schlichta" ]
then
   # SIMULATION SCRIPT PATH
    original="/home/$USER/fwd_RangeExpansion"
    sim_file="00_burnin_1D_expansion.slim"
    sim_path="/home/$USER/fwd_RangeExpansion/$model"
    # SIMULATOR PATH
    slim_path="/home/$USER/bin/build"
else
    # SIMULATION SCRIPT PATH
    original="/storage/homefs/$USER/2D_fwd_RangeExpansion"
    # sim_file="sim_expansion.slim"
    sim_file="00_burnin_2D_expansion.slim"
    sim_path="/storage/homefs/$USER/2D_fwd_RangeExpansion/$model"
    # SIMULATOR PATH
    slim_path="/storage/homefs/$USER/SLiM3/build"
fi

mkdir -p $sim_path/$replicate

out_dir="tree_files"
mkdir -p $sim_path/$replicate/$out_dir

mut_dir="mut_files"
mkdir -p $sim_path/$replicate/$mut_dir

sim_path=$sim_path/$replicate

cp $original/$sim_file $sim_path/$sim_file

cd $sim_path

sed -i "s/_minus_one_/$b4gen/g" $sim_path/$sim_file

printf "\n $slim_path/slim -d chrL=$chrL -d mu=$mu -d rho=$rho -d core=$core -d maxN=$maxN -d burnin=$burn -d out=${out_dir} -d replicate=$replicate -M -t -l $sim_path/$sim_file &> $sim_path/end_slim_$replicate.output \n"
 
execute simulation
$slim_path/slim -d chrL=$chrL -d mu=$mu -d rho=$rho -d core=$core -d maxN=$maxN -d burnin=$burn -d "out='${out_dir}'" -d replicate=$replicate -M -t -l $sim_path/$sim_file &> $sim_path/end_slim_$replicate.output

ln_folder=/storage/homefs/fs19b061/2D_fwd_RangeExpansion/burn_in_tree_files

mkdir -p $ln_folder

file=out_burnin_2D_c1_g${b4gen}_r${replicate}.trees

ln -s ${sim_path}/${replicate}/${out_dir}/${file} ${ln_folder}/${file}