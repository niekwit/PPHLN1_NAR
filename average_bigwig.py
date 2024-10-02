import subprocess
import glob
import os
import re
import logging

os.chdir("/mnt/4TB_SSD/analyses/RIP-seq/2024_Stuart/bigwigs")

# Setup log file
logging.basicConfig(filename="average_bigwig.log",
                    format='%(levelname)s:%(message)s', 
                    level=logging.DEBUG)

# Get all bigwig files and unique sample names
bw_list = glob.glob("*/*.bigwig")
sample_names = [re.sub("_[AB].bigwig$", "", os.path.basename(x)) for x in bw_list]
sample_names = [x.replace(".bigwig", "") for x in sample_names]
sample_names = list(set([re.sub(r"^Norm_PS34_|^Norm_", "", x) for x in sample_names]))

# Create chromosome sizes file from fasta index
fai = "GRCh38_15.fa.fai"
chrom_sizes = "GRCh38_15.chrom.sizes"
with open(fai, "r") as f:
    with open(chrom_sizes, "w") as out:
        for line in f:
            line = line.strip().split("\t")
            out.write(f"{line[0]}\t{line[1]}\n")

# Create average bigwigs for each sample
for sample in sample_names:    
    # Get bigwig files for sample
    sample_files = [x for x in bw_list if sample in x]
    sample_files = " ".join(sample_files)
    
    # Create average wig
    logging.info(f"Creating average wig for {sample}")
    wig = f"{sample}.wig"
    cmd = f"wiggletools write {wig} mean {sample_files}"
    logging.debug(cmd)
    
    subprocess.run(cmd, shell=True)
    
    # Convert wig to bigwig
    logging.info(f"Converting {wig} to bigwig")
    cmd = f"wigToBigWig {wig} {chrom_sizes} {sample}.bigwig"
    logging.debug(cmd)
    
    subprocess.run(cmd, shell=True)
    
    # remove wig file
    os.remove(wig)