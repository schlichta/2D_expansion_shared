# 2D Range expansions

<!-- TOC -->

- [2 D Range expansions](#2-d-range-expansions)
    - [I. Forward simulations](#i-forward-simulations)
        - [a) Models nomenclature](#a-models-nomenclature)
        - [b) Burn in phase](#b-burn-in-phase)
            - [Files](#files)
            - [Folder structure](#folder-structure)
            - [Dispatch sims](#dispatch-sims)
        - [c) Expansion phase](#c-expansion-phase)
            - [Setting up folders](#setting-up-folders)
            - [Dispatch sims](#dispatch-sims)
            - [Output/results](#outputresults)
    - [II. Allele counts](#ii-allele-counts)
        - [a) Set up](#a-set-up)
            - [Files](#files)
            - [Folder organization](#folder-organization)
            - [Input files](#input-files)
        - [b) Dispatch & results](#b-dispatch--results)
            - [On the Cluster](#on-the-cluster)
            - [Output/results](#outputresults)
    - [III. Calculate Pi (Nucleotide diversity)](#iii-calculate-pi-nucleotide-diversity)
        - [a) Set up](#a-set-up)
            - [Files](#files)
            - [Input files](#input-files)
        - [b) Dispatch & results](#b-dispatch--results)
            - [On the cluster](#on-the-cluster)
            - [Output files](#output-files)
        - [c) Concatenate replicate files](#c-concatenate-replicate-files)
            - [Outputfiles](#outputfiles)
    - [IV. Get troughs](#iv-get-troughs)
        - [a) set up](#a-set-up)
            - [Files](#files)
            - [Input files](#input-files)
        - [b) Dispatch & results](#b-dispatch--results)
            - [On the cluster](#on-the-cluster)
            - [Output files](#output-files)
    - [V. Graphing results](#v-graphing-results)
        - [a) Genome profiles](#a-genome-profiles)
            - [Dispatch](#dispatch)
        - [b) Troughs characterization graphs](#b-troughs-characterization-graphs)
            - [Files:](#files)

<!-- /TOC -->

----
&nbsp;
## I. Forward simulations

### a) Models nomenclature

| dimension | # core demes | # of front demes | chr length (Mb) | # length of expansion (demes) | # Founders | migration % | growth time | extra info   |
| --------- | ------------ | ---------------- | --------------- | ----------------------------- | ---------- | ----------- | ----------- | ------------ |
| 2d_       | c1_          | gr30_            | l100_           | d100_                         | f4_        | m10_        | g5_         | mx20_tot_mig |

&nbsp;

### b) Burn in phase

#### Files
- **params_2d_c5_e0_l100_g0_d0.sh**
    - parameters info to run simulation
- **00_run_model.sh**
    - dispatches model 
- **00_burnin_2D_expansion.slim**
    - slim file that defines demographic simulation to run in SLiM
- **00_run_as_slurm_job.sh**
    - sends sim as a SLURM job on cluster (array number == replicate number)
&nbsp;
#### Folder structure
Paste all files into the "mother" folder (where you have differnt models results in different folders) (e.g. `$HOME/2D_fwd_RangeExpansion`)
&nbsp;
#### Dispatch sims

```bash
sbatch --array=1-100 00_run_as_slurm_job.sh 2d_c5_e0_l100_g0_d0
```

[back to top &uarr;](#2d-range-expansions)
&nbsp;
### c) Expansion phase


- **01_run_model_2d.sh**
    - dispatches model 
- **01_2D_expansion.slim**
    - slim file that defines demographic simulation to run in SLiM
- **01_slurm_run_model_2d.sh**
    - dispatches as SLURM job
- **00_slurm_set_up_folder_2d_sims.sh**
    - sets up folders (run b4 the sim!!!)
- **param_** files: under folder param_files in the "mother" folder
    - ex: **params_2d_c1_gr30_l100_d100_f4_m20_g5_mx20_tot_mig.sh**
&nbsp;
#### Setting up folders

```bash
script=00_slurm_set_up_folder_2d_sims.sh
model=f4_m20_g5_mx20_tot_mig
sbatch --array=1-200 ${script} ${model}
```
&nbsp;
#### Dispatch sims

`model`: model name &nbsp;
`n_samps`: number of individuals to be sampled at generation 3 of growth


```bash
model=f4_m20_g5_mx20_tot_mig
n_samps=10
script=01_slurm_run_model_2d.sh

dir=/${HOME}/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model}

cd ${dir}

sbatch --array=1-200 ${script} ${model} ${n_samps}
```
&nbsp;
#### Output/results

**VCF files**
- `model_folder/replicate_folder`
    - `vcf_files/`
        - " out_gen_25003_p6.vcf.gz"
        - ...
        - " out_gen_25498_p996.vcf.gz"
            - VCF files with the number of sampled individuals determined during dispatch

> -  **Note to self**:
>       -  Forgot to fix this issue (there is a blank space at the begining of the vcf file names!!!!)

&nbsp;
**Pop size files**
- `model_folder/replicate_folder`
    - `popsizes/`
        - active_demes_`${rep}`.txt.gz
        - active_demes_oneliner`${rep}`.txt.gz
        - popSizes`${rep}`.txt.gz
        - sampled_edges`${rep}`.txt.gz

> this files are just for checking if the demographic model worked properly...
&nbsp;
**SLiM log file**
- `model_folder/replicate_folder`
    - grid_end_slim_`${rep}`.output
        - log information from SLIM (helps to check migration scheme)

[back to top &uarr;](#2d-range-expansions)

----
&nbsp;
## II. Allele counts

### a) Set up
#### Files

Paste these files inside model folder:
- **02_get_allele_counts_for_pi_calcul.sh**
    - Uses **VCFtools** to obtain allele counts for every VCF file output by the simulations
- **02_slurm_get_allele_counts_for_pi_calcul.sh**
- **sampling_active_edge_demes.txt**
- log folder: **log_allele_counts**
&nbsp;
#### Folder organization
Move all replicate folders to a sub folder named **`sim_files`**: `model_folder/sim_files/replicate_folders`
&nbsp;
#### Input files
- `$model/sim_files/$replicate/out_gen_25498_p996.vcf.gz`
- **sampling_active_edge_demes.txt**: describes which populations and generations were sampled
&nbsp;
### b) Dispatch & results

#### On the Cluster 

```bash
model=f4_m10_g5_mx20_tot_mig
dir=${HOME}/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model}
cd ${dir}
sbatch --array=1-200 02_slurm_get_allele_counts_for_pi_calcul.sh ${model}
cd $HOME
```

&nbsp;
#### Output/results

One file for each sampled generation (total ~ 100 gens, see VCF files output from simulation)
`$model/sim_files/$replicate/vcf_files/count_size_g${gen}_p${pop}_r${rep}.txt.gz`

[back to top &uarr;](#2d-range-expansions)

----
&nbsp;
## III. Calculate Pi (Nucleotide diversity)

### a) Set up
#### Files
- **03_FUNCTIONS_Get_Pi_Profile.R**
    - R function files
- **03_Get_Pi_Profile.R**
    - Main R script
- **03_SLURM_Get_Pi_Profile.sh**
    - Sends analysis as SLURM job
- **03b_SLURM_conCAT_replicate_files.sh**
    - concatenates resulting files (per replicate) into a single file (per model)
&nbsp;
#### Input files

- **`$window_size`**_win_coord.csv
- `count_size_g${gen}_p${pop}_r${rep}.txt.gz`
- `sampling_active_edge_demes.txt`
&nbsp;
### b) Dispatch & results

#### On the cluster
```bash
model=f4_m10_g5_mx20_tot_mig
dir=${HOME}/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model}
cd ${dir}
script=03_SLURM_Get_Pi_Profile.sh
founders=4
migration=10
growth=5
samples=10
active=T
old_demes=F
wsize=med
sbatch --array=2-200 ${script} ${founders} ${migration} ${growth} ${samples} ${active} ${old_demes} ${wsize}
echo "4 10 5 10 T F med"
cd $HOME
```
&nbsp;
#### Output files

- `$model/sim_files/$replicate/`
    - `genomic_profile_$wsize/`
        - `genomic_profile_active_demes_f${founders}_m${mig}_g${growth}_r${rep}_resamp_${inds}inds.txt.gzip`
&nbsp;
### c) Concatenate replicate files

```bash
model=f4_m10_g5_mx20_tot_mig
dir=/storage/homefs/fs19b061/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model}
cd ${dir}
founders=4
migration=10
growth=5
n_samps=10
window_size=med
sbatch 03b_SLURM_conCAT_replicate_files.sh ${founders} ${migration} ${growth} ${n_samps} ${window_size}
echo "4 10 5 10 med"
```
&nbsp;
#### Outputfiles
- `$model/`
    - `genomic_profile_$wsize/`
        -`genomic_profile_all_reps_${model_prefix}_samp_${n_samps}inds_win_${window_size}.txt.gz` 

`model_prefix=f4_m10_g5`; &rarr; `f${founders}_m${migration}_g${growth}` &nbsp; 
instead of `model=f4_m10_g5_mx20_tot_mig`;

[back to top &uarr;](#2d-range-expansions)

-----
&nbsp;
## IV. Get troughs

### a) set up
#### Files

- **04_slurm_get_troughs.sh**
- **04a_get_troughs.R**
- **04_FUNCTIONS_get_troughs.R**

> **Important NOTE**
> initial diversity levels are **hard coded** in the R script!!! --> this value changes IF burn-in time and ancestral population size changes.
> currently: 2500 individuals; 25000 generations of burn-in.
&nbsp;
#### Input files

### b) Dispatch & results

#### On the cluster

```bash
model_prefix=f4_m10_g5
level=0.1
samps=10
wsize=med

dir=/storage/homefs/fs19b061/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model_prefix}_mx20_tot_mig
cd ${dir}

sbatch 04_slurm_get_troughs.sh ${level} ${model_prefix} ${samps} ${wsize}  
```
&nbsp;
#### Output files

- **`summary_data_lvl_${level}_${model_prefix}_${samps}inds_win_${wsize}.txt`**
- **`complete_data_lvl_${level}_${model_prefix}_${samps}inds_wind_${wsize}.txt`**

[back to top &uarr;](#2d-range-expansions)


--------
&nbsp;
## V. Graphing results

Use output from previous step (IV) to run graphing scripts...
This step is generally done interactivelly in work computer (not the cluster as previously), since depending of the results, graphing params have to be adjusted as needed
&nbsp;
### a) Genome profiles
Exception: "Genome profile" &rarr; can be ran in cluster:

- **04b_slurm_get_genome_profile.sh**
- **NEW_04b_plot_results.R**
- **04_FUNCTIONS_get_troughs.R**
&nbsp;
#### Dispatch

```bash
script=04b_slurm_get_genome_profile.sh
level=0.1
model_prefix=f4_m10_g5
samps=10
wsize=med

dir=${HOME}/2D_fwd_RangeExpansion/2d_c1_gr30_l100_d100_${model_prefix}_mx20_tot_mig
cd ${dir}

sbatch ${script} ${level} ${model_prefix} ${samps} ${wsize}

```

<!-- echo "0.1 f20_m10_g5 10 med"
echo "sbatch ${script} 0.1 f20_m10_g5_tot_mig 10 med"
-->

[back to top &uarr;](#2d-range-expansions)
&nbsp;
### b) Troughs characterization graphs

#### Files:
- **04b_plot_different_models_together.R**
- **04c_FUNCTIONS_get_troughs.R**
- **04c_plot_diff_models.R**
- **test_functions.R**


[back to top &uarr;](#2d-range-expansions)
&nbsp;