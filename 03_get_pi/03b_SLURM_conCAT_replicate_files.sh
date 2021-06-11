#!/bin/bash
#SBATCH --mail-user=fs190b61@campus.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=bdw-invest,epyc2
####SBATCH --partition=empi,all
#SBATCH --mem-per-cpu=3G
#SBATCH --array=1
#SBATCH --output=./log_get_pi/conCAT_output_%j_%a.txt
#SBATCH --error=./log_get_pi/conCAT_error_%j_%a.txt
#SBATCH --time=01:00:00


founders=${1}
mig=${2}
growth=${3}
inds=${4}
janela=${5}


folder=genomic_profile_${janela}
mkdir -p ${folder}

out_file=genomic_profile_all_reps_f${founders}_m${mig}_g${growth}_samp_${inds}inds_win_${janela}


if [ -f ${out_file}.txt.gz ]
	then
	rm ./${folder}/${out_file}.txt.gz
fi

# genomic_profile_f20_m10_g5_r21.txt.gz
# for rep in "${replicates[@]}"; do
for rep in $(seq 1 200); do
    #      genomic_profile_active_demes_f20_m10_g5_r1_resamp_10inds.txt
    infile=genomic_profile_active_demes_f${founders}_m${mig}_g${growth}_r${rep}_resamp_${inds}inds
    
    if [ -f ./sim_files/${rep}/${folder}/${infile}.txt ]
	then
        gzip -f ./sim_files/${rep}/${folder}/${infile}.txt
    fi
    
    zcat ./sim_files/${rep}/${folder}/${infile}.txt.gz > ./${folder}/tmp.txt
    tail -n +2 ./${folder}/tmp.txt > ./${folder}/tmp2.txt

    cat ./${folder}/tmp2.txt >> ./${folder}/$out_file.txt


done

if [ -f ./${folder}/tmp2.txt ]
then
    rm ./${folder}/tmp2.txt
    rm ./${folder}/tmp.txt
fi

gzip -f ./${folder}/${out_file}.txt