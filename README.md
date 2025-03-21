# AlphaFold on CropDiv HPC
How to run AlphaFold2 on the Crop Diversity HPC.

## Overview
AlphaFold2 is a deep learning system developed by DeepMind that predicts protein structures from amino acid sequences. 

This repository contains instructions and scripts for running AlphaFold2 on the Crop Diversity HPC cluster. 

<br>

## Setup

<h3 align="center"><b>
    These setup steps have already been performed.
</b></h3>

<h4 align="center">
    The full databases and container are located in the shared database directory `/mnt/shared/datasets/databases/alphafold`.
</h4>

### 1. Download Databases
The official AlphaFold database download script requires aria2c, which is not installed on the HPC and requires root access.

Instead, use `download_db.sh` script from the [alphafold_non_docker](https://github.com/kalininalab/alphafold_non_docker/tree/main) repo and update with latest database locations from the official [AlphaFold](https://github.com/google-deepmind/alphafold/blob/main/scripts/) repo.

```bash
bash ./download_db.sh -d /mnt/shared/datasets/databases/alphafold/db -m full_dbs
```

### 2. Download Container
Pull prebuilt AlphaFold 2.3.0 container.
```
apptainer pull docker://uvarc/alphafold:2.3.0
```

<br>

## Running AlphaFold

Submission scripts for the Monomer and Multimer presets can be downloaded from this repo or can be used directly from `/mnt/shared/datasets/databases/alphafold`.

### Monomer Prediction
To run the monomer prediction on the example protein:
```bash
sbatch alphafold_monomer_submit.sh \
    /path/to/alphafold_cropdiv \
    query.fasta \
    /path/to/output/monomer_test_out
```
The output should resemble the [6MRR](https://www.rcsb.org/structure/6MRR) structure.

For predicting the structure of a single protein chain:
```bash
sbatch alphafold_monomer_submit.sh \
    /path/containing/fasta_file \
    single_protein.fasta \
    /path/to/output
```

### Multimer Prediction
To run the multimer prediction on the example proteins:
```bash
sbatch alphafold_multimer_submit.sh \
    /path/to/alphafold_cropdiv \
    multimer_query.fasta \
    /path/to/output/multimer_test_out
```
The output should resemble the [1DGC](https://www.rcsb.org/structure/1DGC) structure.

For predicting the structure of protein complexes:
```bash
sbatch alphafold_multimer_submit.sh \
    /path/containing/fasta_file \
    two_protein.fasta \
    /path/to/output
```

### Input Format

- For monomer predictions, the input FASTA file should contain a single protein sequence.
- For multimer predictions, the input FASTA file should contain two protein sequences.
- **NOTE**: Ensure that any stop indicators (`*` or `X`) are removed from the protein sequences before running. 

### Resource Requirements
AlphaFold requires significant computational resources:

- Monomer predictions: 4-8 CPU cores, 16GB RAM, 1 GPU (recommended)
- Multimer predictions: 4-8 CPU cores, 32GB RAM, 1-2 GPUs (recommended)

### Troubleshooting
Common issues:
- **Out of memory errors**: Increase the memory allocation in the submission script
- **Database connection failures**: Verify the database path is correct 
- **GPU errors**: Make sure to request available GPU resources 

<br>

## AlphaFold Output Files
The `--output_dir` directory will have the following structure:

```
<target_name>/
    features.pkl
    ranked_{0,1,2,3,4}.pdb
    ranking_debug.json
    relax_metrics.json
    relaxed_model_{1,2,3,4,5}.pdb
    result_model_{1,2,3,4,5}.pkl
    timings.json
    unrelaxed_model_{1,2,3,4,5}.pdb
    msas/
        bfd_uniref_hits.a3m
        mgnify_hits.sto
        uniref90_hits.sto
```

Please see the official [AlphaFold](https://github.com/google-deepmind/alphafold/blob/main/README.md#alphafold-output) repo for a full description of all output files.

<br>

---

# AlphaFold Analyser

[AlphaFold Analyser](https://github.com/rj-price/alphafold-analyser) is a command line tool to produce high quality visualisations of protein structures predicted by AlphaFold2. These visualisations allow the user to view the pLDDT of each residue of a protein structure and the predicted alignment error for the entire protein to rapidly infer the quality of a predicted structure. Alphafold analyser can process the results of both multimer and monomer predictions.

![outputs](https://github.com/Orpowell/alphafold-analyser/blob/main/img/outputs.png)

