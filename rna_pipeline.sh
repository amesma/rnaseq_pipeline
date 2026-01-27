#!/usr/bin/bash

#SRR32884062 is control
#SRR32884053 is cancer cell case

SECONDS = 0

#fastqc
#Raw data file: download into gz and rename

curl.exe -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR328/053/SRR32884053/SRR32884053_1.fastq.gz -o SRR32884053_1.fastq.gz
curl.exe -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR328/053/SRR32884053/SRR32884053_2.fastq.gz -o SRR32884053_2.fastq.gz

#Control cases
#curl.exe -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR328/062/SRR32884062/SRR32884062_1.fastq.gz -o SRR32884062__1.fastq.gz
#curl.exe -L ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR328/062/SRR32884062/SRR32884062_2.fastq.gz -o SRR32884062_2.fastq.gz

#Align reference genome using HISAT2
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M38/GRCm39.genome.fa.gz
gzip -d GRCm39.genome.fa.gz
mv GRCm39.genome.fa genome.fa

#Create annotations in HISAT2 and build reference genome
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M10/gencode.vM10.annotation.gtf.gz
gzip -d gencode.vM10.annotation.gtf.gz
mv gencode.vM10.annotation.gtf genome.gtf
hisat2_extract_splice_sites.py genome.gtf > genome.ss
hisat2_extract_exons.py genome.gtf > genome.exon
hisat2-build genome.fa genome

#Run FASTQC
fastqc data/SRR32884053_1.fastq.gz SRR32884053_2.fastq.gz -o data/

#high quality reads, no need to trim

#bash script for hisat2; align all .fastq.gz files to indexed reference genome to generate .sam files
SAMPLES="SRR32884053"
for SAMPLE in $SAMPLES; do
    hisat2 -x ~/rnaseq_pipeline/data/reference/genome -1 ~/rnaseq_pipeline/data/${SAMPLE}_1.fastq -2 ~/rnaseq_pipeline/data/${SAMPLE}_2.fastq -S ~/rnaseq_pipeline/data/aligned_reads/${SAMPLE}.sam
done

for f in *.sam; do
  samtools sort -@ 11 -o ${f%.*}.bam $f
done;