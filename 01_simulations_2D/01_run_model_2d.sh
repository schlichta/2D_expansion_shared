#!/bin/bash
# to run each different model, must copy and paste this file (run_model.sh) and simulation file to the model folder (e.g. /home/.../$USER/fwd_RangeExpansion/c5_e5_l10_i100_5gen)

# in bash $1 is the first argument used in command line when calling the script
printf "\n running model $1 \n"
printf "\n changing to directory $PWD/$1 \n"
printf "\n array/replicate: $2 - $SLURM_ARRAY_TASK_ID \n"

model=${1}
replicate=$SLURM_ARRAY_TASK_ID
nsamps=${3}


cd $PWD/$1

#all params come from here, plus $model
# /storage/homefs/fs19b061/fwd_RangeExpansion/param_files
source ./params_"${model}".sh

# if [ $USER == "schlichta" ]
# then
#    # SIMULATION SCRIPT PATH
#     original="/home/$USER/fwd_RangeExpansion"
#     sim_file="01_1D_range_expansion_all_models.slim"
#     sim_path="/home/$USER/fwd_RangeExpansion/$model"
#     # SIMULATOR PATH
#     slim_path="/home/$USER/bin/build"
# else
    # SIMULATION SCRIPT PATH
    original="${HOME}/2D_fwd_RangeExpansion"
    sim_file="01_2D_expansion.slim"
    sim_path="${HOME}/2D_fwd_RangeExpansion/${model}"
    # SIMULATOR PATH
    slim_path="${HOME}/SLiM34/build"
    treepath="${HOME}/2D_fwd_RangeExpansion/burn_in_tree_files"
# fi

tdir=${TMPDIR}
mkdir -p $sim_path/$replicate
mkdir -p $tdir/$replicate

out_dir="${tdir}/${replicate}/vcf_files"
# mkdir -p $sim_path/$replicate/$out_dir
mkdir -p $out_dir

# mut_dir="${tdir}/${replicate}/mut_files"
# # mkdir -p $sim_path/$replicate/$mut_dir
# mkdir -p $mut_dir

pop_dir="${tdir}/${replicate}/popsizes"
# mkdir -p $sim_path/$replicate/$pop_dir
mkdir -p $pop_dir

burn_pop="burn_in_tree_files"

if [ -d $burn_pop ]; then
    printf "\n folder is already linked \n"
else
    ln -s $treepath $burn_pop
fi


sim_path=$sim_path/$replicate

# cp $original/$sim_file $sim_path/$sim_file

cd $sim_path

# sed -i "s/_burn_in_/$((burn+100))/g" $sim_path/$sim_file
# sed -i "s/_other_gens_/$aftgen/g" $sim_path/$sim_file
# sed -i "s/_end_sim_/$end/g" $sim_path/$sim_file

printf "\n $slim_path/slim -d chrL=$chrL -d mu=$mu -d rho=$rho -d core=$core -d maxN=$maxN -d migr=$mig -d tgrw=$tgrw -d r1=$r1 -d ert1=$ert1 -d burnin=$burn -d out='${out_dir}' -d out_pop='${pop_dir}' -d burn_pop='${burn_pop}' -d replicate=$replicate -d Fndrs=$Fndrs -d nsamps=$nsamps -d mig2p1=${mig2p1} -d grid=${grid} -d side=${side} -M -t -l $sim_path/$sim_file &> $sim_path/grid_end_slim_$replicate.output \n"

# execute simulation
$slim_path/slim -d chrL=$chrL -d mu=$mu -d rho=$rho -d core=$core -d maxN=$maxN -d migr=$mig -d tgrw=$tgrw -d r1=$r1 -d ert1=$ert1 -d burnin=$burn -d "out='${out_dir}'" -d "out_pop='${pop_dir}'" -d "burn_pop='${burn_pop}'" -d replicate=$replicate -d Fndrs=$Fndrs -d nsamps=$nsamps -d mig2p1=${mig2p1} -d grid=${grid} -d side=${side} -M -t -l $sim_path/$sim_file &> $sim_path/grid_end_slim_$replicate.output

gzip $out_dir/*.vcf
gzip $out_dir/*.trees
gzip $mut_dir/*.txt
gzip $pop_dir/*.txt


rsync -arv --progress $tdir/$replicate/* $sim_path