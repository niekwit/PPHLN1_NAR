mamba create -n gat python=2.7.3 anaconda::numpy=1.4 anaconda::cython=0.14
mamba activate gat
pip install gat

# Create workspace file from indexed fasta
awk -F"\t" '{print $1"\t"0"\t"$2"\t""ws"}' /home/niek/Downloads/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai > gat/GRCh38.genome.bed

### TE
# Create annotations file
awk -F"\t" '{print $1"\t"$2"\t"$3"\tLINE1"}' bed/GRCh38_Ensembl_rmsk_TE_LINE1s.bed > gat/LINE1.bed
awk -F"\t" '{print $1"\t"$2"\t"$3"\tLINE"}' bed/GRCh38_Ensembl_rmsk_TE_LINEs.bed > gat/LINE.bed
awk -F"\t" '{print $1"\t"$2"\t"$3"\tAlu"}' bed/GRCh38_Ensembl_rmsk_TE_Alus.bed > gat/Alu.bed
awk -F"\t" '{print $1"\t"$2"\t"$3"\tERV"}' bed/GRCh38_Ensembl_rmsk_TE_ERVs.bed > gat/ERV.bed
awk -F"\t" '{print $1"\t"$2"\t"$3"\tTransposon"}' bed/GRCh38_Ensembl_rmsk_TE_transposons.bed > gat/Transposon.bed
awk -F"\t" '{print $1"\t"$2"\t"$3"\tSINE"}' bed/GRCh38_Ensembl_rmsk_TE_SINEs.bed > gat/SINE.bed

cat gat/LINE1.bed gat/LINE.bed gat/Alu.bed gat/ERV.bed gat/Transposon.bed gat/SINE.bed > gat/TE.bed
rm gat/LINE1.bed gat/LINE.bed gat/Alu.bed gat/ERV.bed gat/Transposon.bed gat/SINE.bed

gat-run.py --num-threads=36 --segments=gat/FL_merged_peaks.bed --annotations=gat/TE.bed --workspace=gat/GRCh38.genome.bed --ignore-segment-tracks --num-samples=10000 | tee gat/gat_output_TE_PPHLN1_FL.txt | grep -v "#" > gat/gat_formatted_TE_PPHLN1_FL.txt

gat-run.py --num-threads=36 --segments=gat/1_127_merged_peaks.bed --annotations=gat/TE.bed --workspace=gat/GRCh38.genome.bed --ignore-segment-tracks --num-samples=10000 | tee gat/gat_output_TE_PPHLN1_1-127.txt | grep -v "#" > gat/gat_formatted_TE_PPHLN1_1-127.txt



### TASOR and MPP8 sites (Liu et al 2018)
cut -f1,2,3 chip-seq/TASOR.bed | sed 's/$/\tTASOR/' > gat/TASOR_sites.bed
cut -f1,2,3 chip-seq/MPP8.bed | sed 's/$/\tMPP8/' > gat/MPP8_sites.bed
cat gat/MPP8_sites.bed gat/TASOR_sites.bed > gat/MPP8_TASOR_sites.bed

gat-run.py --num-threads=36 --segments=gat/FL_merged_peaks.bed --annotations=gat/MPP8_TASOR_sites.bed --workspace=gat/GRCh38.genome.bed --ignore-segment-tracks --num-samples=10000 | tee gat/gat_output_MPP8_TASOR_PPHLN1_FL.txt | grep -v "#" > gat/gat_formatted_MPP8_TASOR_PPHLN1_FL.txt



### Unique TASOR and unique TASOR2 sites
cut -f1,2,3 bw_cnr_hush2/TASOR2_peaks.bed | sed 's/$/\tTASOR2/' > gat/TASOR2_sites.bed
bedtools intersect -v -a gat/TASOR_sites.bed -b gat/TASOR2_sites.bed | sed 's/$/_unique/' > gat/TASOR_unique.bed
bedtools intersect -v -a gat/TASOR2_sites.bed -b gat/TASOR_sites.bed | sed 's/$/_unique/' > gat/TASOR2_unique.bed
cat gat/TASOR_unique.bed gat/TASOR2_unique.bed > gat/TASOR_TASOR2_unique.bed

gat-run.py --num-threads=36 --segments=gat/FL_merged_peaks.bed --annotations=gat/TASOR_TASOR2_unique.bed --workspace=gat/GRCh38.genome.bed --ignore-segment-tracks --num-samples=10000 | tee gat/gat_output_TASOR_TASOR2_unique_PPHLN1_FL.txt | grep -v "#" > gat/gat_formatted_TASOR_TASOR2_unique_PPHLN1_FL.txt