# Strong-Seq

A snakemake workflow to combine Strand-Seq cells with a long-read dataset to create 'pseudo-long' Strand-Seq reads, useful for inversion visualization. 

## Installation

To install, you will need a working version of anaconda and ideally mamba (for speedup).


```
git clone https://github.com/WHops/strong-seq.git
cd strong-seq

mamba create -f conda_env.yml
conda activate strongseq-env
```

## Configure

Edit the config/Snake.config.json to fit your needs. You will need to provide:

- snp_file_dir: the directory which contains phased snps by NYGC, split by chromosomes. (TODO: provide link)
- path_to_sseq_bamdir: the directory where the Strand-Seq bams live
- path_to_longread_bamdir: the directory where the Strand-Seq bams live
- ref_fa: a link to the reference fasta to which StrandSeq and long reads were aligned.

- sample: This is the name of the sample. It has to be present (a) in the snp vcf as a sample, and (b) in the longread bam, which is assumed to be called {sample}.bam

- sseq_cellnames: names of the Strand-Seq cells to enhance, without .bam ending (will be searched for in the sseq_bamdir)

- chromosomes to include

## Running

Once the configuration is set, navigate to the strong-seq folder (or stay there), and run:
```
snakemake --cores [n_cores]
```

The results will appear in the a new folder, /res. 

## Runtime

The approx. runtime for running one Strand-Seq cell is around 30 minutes on 10 cores. 


