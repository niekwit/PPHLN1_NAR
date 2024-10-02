#!/usr/bin/env bash

set -e

mamba create -c bioconda -n macs2 macs2=2.2.9.1
mamba activate macs2

### Do some QC first
mamba activate deeptools
# Index bam files
samtools index -M -@ 24 $(ls -1 *.bam | xargs)

# Create fragment size plot
bamPEFragmentSize --maxFragmentLength 5000 -p 24 -b $(ls -1 *_1.bam | xargs) -o bam_fragments_sizes_1.png
bamPEFragmentSize --maxFragmentLength 5000 -p 24 -b $(ls -1 *_2.bam | xargs) -o bam_fragments_sizes_2.png
#NOTE: Quite a few fragments are larger than 1000bp (MACS2 complains about this and crashes)

# Filter out fragments that are longer than 500 bp
# https://accio.github.io/bioinformatics/2020/03/10/filter-bam-by-insert-size.html
mkdir -p filtered
for i in $(ls -1 *.bam); do
    samtools view -h $i | awk 'substr($0,1,1)=="@" || ($9>= 0 && $9<=500) || ($9<=0 && $9>=-500)' | samtools view -b - > filtered/$i
done

# Index filtered bam files
samtools index -M -@ 24 $(ls -1 filtered/*.bam | xargs)

# Create fragment size plot for filtered bam files
bamPEFragmentSize --maxFragmentLength 5000 -p 24 -b $(ls -1 filtered/*_1.bam | xargs) -o bam_filtered_fragments_sizes_1.png
bamPEFragmentSize --maxFragmentLength 5000 -p 24 -b $(ls -1 filtered/*_2.bam | xargs) -o bam_filtered_fragments_sizes_2.png

# Peak calling
mamba activate macs2
mkdir -p macs2

for i in $(ls -1 filtered/*_1.bam); do
    macs2 callpeak -t $i -c filtered/Empty_1.bam -f BAMPE -g hs -n $(basename $i .bam) --broad --broad-cutoff 0.1 --outdir macs2/$(basename $i .bam) 2> macs2/$(basename $i .bam).log
done

for i in $(ls -1 filtered/*_2.bam); do
    macs2 callpeak -t $i -c filtered/Empty_2.bam -f BAMPE -g hs -n $(basename $i .bam) --broad --broad-cutoff 0.1 --outdir macs2/$(basename $i .bam) 2> macs2/$(basename $i .bam).log
done

