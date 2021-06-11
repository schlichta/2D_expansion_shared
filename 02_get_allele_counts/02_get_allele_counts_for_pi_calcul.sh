#!/bin/bash
# found=$1
# mig=$2
# growth=$3
model=$1
rep=${SLURM_ARRAY_TASK_ID}

vcftools="${HOME}/bin/vcftools"

# mod_folder=/gpfs/homefs/iee/fs19b061/fwd_RangeExpansion/1d_c5_e5_l100_d100_f${found}_m${mig}_g${growth}
mod_folder=${HOME}/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model}

wdir=${mod_folder}/sim_files/${rep}/vcf_files

printf "${wdir}\n"

# active demes first...
while read -r line; do
    # "out_gen_25475_p956.vcf.gz"
    gen=$(echo $line | awk -F ' ' '{print $1}')
    pop=$(echo $line | awk -F ' ' '{print $2}')
    infile=$(echo " out_gen_"${gen}"_p"${pop}".vcf.gz")
    freq_file=counts2_p${pop}_gen_${gen}
    out_file=count_size_g${gen}_p${pop}_r${rep}

    printf "\n${gen}\n ${pop}\n ${infile}\n ${freq_file}\n ${out_file} \n"
    
    printf "\n ${vcftools} --gzvcf ${wdir}/${infile} --counts2 --stdout > ${wdir}/${freq_file}.frq.count \n"

    ${vcftools} --gzvcf ${wdir}/"${infile}" --counts2 --stdout > ${wdir}/${freq_file}.frq.count

    sed -i '1d' ${wdir}/$freq_file.frq.count

    if [ -f ${wdir}/$out_file.txt ]; then
        rm ${wdir}/${out_file}.txt
    fi

    # keeping only columns of interest
    cat  ${wdir}/${freq_file}.frq.count | cut -f4,2,6 | paste > ${wdir}/tmp.txt
    # adding columns with pop and gen information at the end of the table
    # final table --> POS, size, allele_count, pop, gen
    sed -i "s/$/\t${pop}/" ${wdir}/tmp.txt
    sed -i "s/$/\t${gen}/" ${wdir}/tmp.txt

    # save temp file as another name (using cat)
    cat ${wdir}/tmp.txt > ${wdir}/${out_file}.txt

    gzip -f ${wdir}/${out_file}.txt
    rm ${wdir}/${freq_file}.frq.count
    rm ${wdir}/tmp.txt


done < ../sampling_active_edge_demes.txt







# - - - - - 

# fdir=/gpfs/homefs/iee/fs19b061/fwd_RangeExpansion/1d_c5_e5_l100_d100_f10_m10_g5/58/vcf_files
# ${vcftools} --gzvcf ${fdir}/out_p106_gen_25500.vcf.gz --freq2 --out ${fdir}/freq_p106_gen_25500

# sed -i 's|{COUNT}|COUNT\tMUT_count|' $out_file

# infile="out_p106_gen_25500.vcf.gz"
# printf "$infile" | awk -F "_p" '{print $2}'| awk -F "_" '{print $1}'
# #106

# printf "$infile" | awk -F "_" '{print $2}'
# #p106

# #?remove 1st line?
# sed -i '1d' ${file}.txt

#names(dt) = c("gen", "pop", "slimID", "POS", "oriGen", "allele_count", "size")
# gen, pop, POS, allele_count, size