if config["bowtie2"]["k_mode"] == 0:
    logger.info(f"Standard Bowtie2 mapping with MAPQ > {config["samtools"]["mapq"]} filtering")
    rule bowtie2_align:
        input:
            sample=["results/trimmed/{sample}_R1.fq.gz",
                    "results/trimmed/{sample}_R2.fq.gz"],
            idx=multiext(
                f"resources/{resources.genome}_{resources.build}_index/index",
                ".1.bt2",
                ".2.bt2",
                ".3.bt2",
                ".4.bt2",
                ".rev.1.bt2",
                ".rev.2.bt2",
            ),
        output:
            temp(f"results/{bowtie2_dir}/{{sample}}.bam"),
        params:
            extra="",
        log:
            f"logs/bowtie2_align/{bowtie2_dir}/{{sample}}.log",
        threads: config["resources"]["mapping"]["cpu"]
        resources: 
            runtime=config["resources"]["mapping"]["time"]
        wrapper:
            f"{wrapper_version}/bio/bowtie2/align"


    rule mapq_filtering:
        input:
            bam=f"results/{bowtie2_dir}/{{sample}}.bam",
        output:
            temp(f"results/{bowtie2_dir}/{{sample}}.filtered.bam"),
        params:
            extra=f"--min-MQ {config['samtools']['mapq']} -f 3",
        threads: config["resources"]["samtools"]["cpu"]
        resources: 
            runtime=config["resources"]["samtools"]["time"]
        log:
            f"logs/mapq_filtering/{bowtie2_dir}/{{sample}}.log"
        wrapper:
            f"{wrapper_version}/bio/samtools/view"
else:
    rule bowtie2_align:
        input:
            sample=["results/trimmed/{sample}_R1.fq.gz",
                    "results/trimmed/{sample}_R2.fq.gz"],
            idx=multiext(
                f"resources/{resources.genome}_{resources.build}_index/index",
                ".1.bt2",
                ".2.bt2",
                ".3.bt2",
                ".4.bt2",
                ".rev.1.bt2",
                ".rev.2.bt2",
            ),
        output:
            temp(f"results/{bowtie2_dir}/{{sample}}.filtered.bam"),
        params:
            extra=f"-k {config["bowtie2"]["k_mode"]}",
        log:
            f"logs/bowtie2_align/{bowtie2_dir}/{{sample}}.log",
        threads: config["resources"]["mapping"]["cpu"]
        resources: 
            runtime=config["resources"]["mapping"]["time"]
        wrapper:
            f"{wrapper_version}/bio/bowtie2/align"

rule remove_blacklisted_regions:
    input:
        left=f"results/{bowtie2_dir}/{{sample}}.filtered.bam",
        right=resources.blacklist,
    output:
        temp(f"results/{bowtie2_dir}/{{sample}}.bl.bam"),
    params:
        extra="-v -nonamecheck",
    threads: config["resources"]["deeptools"]["cpu"]
    resources: 
        runtime=config["resources"]["deeptools"]["time"]
    log:
        f"logs/remove_blacklisted_regions/{bowtie2_dir}/{{sample}}.log"
    wrapper:
        f"{wrapper_version}/bio/bedtools/intersect"


rule sort:
    input:
        f"results/{bowtie2_dir}/{{sample}}.bl.bam",
    output:
        temp(f"results/{bowtie2_dir}/{{sample}}.bl.sorted.bam"),
    params:
        extra="-m 2G",
    threads: config["resources"]["samtools"]["cpu"]
    resources: 
        runtime=config["resources"]["samtools"]["time"]
    log:
        f"logs/sort_bam/{bowtie2_dir}/{{sample}}.log"
    wrapper:
        f"{wrapper_version}/bio/samtools/sort"


rule deduplication:
    input:
        bams=f"results/{bowtie2_dir}/{{sample}}.bl.sorted.bam",
    output:
        bam=f"results/{bowtie2_dir}/{{sample}}.dedup.bam",
        metrics="logs/deduplication/metrics.{sample}.txt",
    params:
        extra="--REMOVE_DUPLICATES true",
    threads: config["resources"]["samtools"]["cpu"]
    resources: 
        runtime=config["resources"]["samtools"]["time"]
    log:
        f"logs/deduplication/{bowtie2_dir}/{{sample}}.log"
    wrapper:
        f"{wrapper_version}/bio/picard/markduplicates"


rule index_dedup:
    input:
        f"results/{bowtie2_dir}/{{sample}}.dedup.bam",
    output:
        f"results/{bowtie2_dir}/{{sample}}.dedup.bam.bai",
    threads: config["resources"]["samtools"]["cpu"]
    resources: 
        runtime=config["resources"]["samtools"]["time"]
    log:
        f"logs/index_bam/{bowtie2_dir}/{{sample}}.log"
    wrapper:
        f"{wrapper_version}/bio/samtools/index"


if config["spike_in"]["apply"]:
    rule downsample:
        input:
            bam=expand(f"results/{bowtie2_dir}/{{sample}}.dedup.bam", sample=SAMPLES),
            bai=expand(f"results/{bowtie2_dir}/{{sample}}.dedup.bam.bai", sample=SAMPLES),
        output:
            bam=expand(f"results/{bowtie2_dir}/{{sample}}.downsampled.bam", sample=SAMPLES),
            bai=expand(f"results/{bowtie2_dir}/{{sample}}.downsampled.bam.bai", sample=SAMPLES),
        threads: config["resources"]["samtools"]["cpu"]
        resources: 
            runtime=config["resources"]["mapping"]["time"]
        log:
            f"logs/downsample/{bowtie2_dir}/downsample.log"
        script:
            "../scripts/downsample.py"
    
    rule index_downsample:
        input:
            f"results/{bowtie2_dir}/{{sample}}.downsampled.bam"
        output:
            f"results/{bowtie2_dir}/{{sample}}.downsampled.bam.bai",
        threads: config["resources"]["samtools"]["cpu"]
        resources: 
            runtime=config["resources"]["samtools"]["time"]
        log:
            f"logs/index_downsample/{bowtie2_dir}/{{sample}}.log"
        wrapper:
            f"{wrapper_version}/bio/samtools/index"


    if not config["spike_in"]["downsample_only"]:
        rule align_to_si_genome:
            input:    
                sample=["results/trimmed/{sample}_R1.fq.gz",
                        "results/trimmed/{sample}_R2.fq.gz"],
                idx=multiext(
                    f"resources/{si_resources.genome}_{si_resources.build}_index/index",
                    ".1.bt2",
                    ".2.bt2",
                    ".3.bt2",
                    ".4.bt2",
                    ".rev.1.bt2",
                    ".rev.2.bt2",
                ),
            output:
                temp(f"results/{bowtie2_dir}/{{sample}}_spike_in.bam"),
            params:
                extra=f"-k {config["bowtie2"]["k_mode"]}",
            log:
                f"logs/bowtie2_align/{bowtie2_dir}/{{sample}}_{si_resources.genome}.log",
            threads: config["resources"]["mapping"]["cpu"]
            resources: 
                runtime=config["resources"]["mapping"]["time"]
            wrapper:
                f"{wrapper_version}/bio/bowtie2/align"


        rule correct_for_spike_in:
            input:
                bam=expand("results/{bowtie2_dir}/{{sample}}.dedup.bam", sample=SAMPLES),
                si_bam=expand(f"results/{bowtie2_dir}/{{sample}}_spike_in.bam", sample=SAMPLES),
            output:
                bam=expand(temp(f"results/{bowtie2_dir}/{{sample}}.corrected.bam"), sample=SAMPLES),