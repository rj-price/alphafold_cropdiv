#!/usr/bin/env bash
#SBATCH -J alphafold
#SBATCH --partition=gpu
#SBATCH --gpus=a100:1
#SBATCH --cpus-per-gpu=4
#SBATCH --mem-per-gpu=32G

# INPUT
FastaDir=$1         # Full path
FastaName=$2        # Fasta file name (ie. test.fasta)
OutputDir=$3        # Full path

# ENVIRONMENT VARIABLES
DatabaseDir=/mnt/shared/datasets/databases/alphafold/db
SingularityImage=/mnt/shared/datasets/databases/alphafold/alphafold_2.3.0.sif

# LOGGING
echo "#### Running AlphaFold ####"
echo "Fasta Directory: $FastaDir"
echo "Fasta Name: $FastaName"
echo "Output Directory: $OutputDir"
echo "Database Directory: $DatabaseDir"
echo "Singularity Image: $SingularityImage"
echo "-----------------------------------"

# CHECK FOR INPUTS
if [[ -d $FastaDir && -f $FastaDir/$FastaName && -n $OutputDir ]]; then
    # CREATE OUTPUT FOLDER IF IT DOESN'T EXIST
    if [[ ! -d $OutputDir ]]; then
        mkdir -p "$OutputDir"
    fi

    # RUN ALPHAFOLD
    singularity run \
        --env TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0,OPENMM_CPU_THREADS=8 \
        -B $DatabaseDir:/data \
        -B .:/etc \
        -B $OutputDir:/output \
        -B $FastaDir:/test \
        --pwd /app/alphafold \
        --nv $SingularityImage \
        --fasta_paths /test/$FastaName \
        --output_dir /output \
        --data_dir /data \
        --uniref90_database_path /data/uniref90/uniref90.fasta \
        --mgnify_database_path /data/mgnify/mgy_clusters_2022_05.fa \
        --pdb70_database_path /data/pdb70/pdb70 \
        --template_mmcif_dir /data/pdb_mmcif/mmcif_files \
        --obsolete_pdbs_path /data/pdb_mmcif/obsolete.dat \
        --uniref30_database_path=/data/uniref30/UniRef30_2021_03 \
        --bfd_database_path=/data/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
        --max_template_date=3000-01-01 \
        --model_preset=monomer \
        --db_preset=full_dbs \
        --benchmark=False \
        --use_precomputed_msas=False \
        --num_multimer_predictions_per_model=5 \
        --use_gpu_relax=True

    echo "AlphaFold run completed."
else
    # PRINT ERROR & USAGE MESSAGES
    echo -e "\nERROR: Expected inputs not found. Please provide the full path to the directory containing the FASTA file, the FASTA file name and the full path to an output directory. \n"
    echo -e "Usage: sbatch alphafold_monomer_submit.sh <fasta_directory> <fasta_file> <output_directory> \n"
    exit 1
fi

