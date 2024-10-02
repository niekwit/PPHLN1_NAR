#!/usr/bin/env bash

mkdir -p bed

# Convert GTF to BED
gtf2bed GRCh38_Ensembl_rmsk_TE.gtf > bed/GRCh38_Ensembl_rmsk_TE.bed

# Subset for different TE types
grep 'family_id "L1"' bed/GRCh38_Ensembl_rmsk_TE.bed > bed/GRCh38_Ensembl_rmsk_TE_LINE1s.bed
grep 'class_id "LINE"' bed/GRCh38_Ensembl_rmsk_TE.bed > bed/GRCh38_Ensembl_rmsk_TE_LINEs.bed
grep 'class_id "SINE"' bed/GRCh38_Ensembl_rmsk_TE.bed > bed/GRCh38_Ensembl_rmsk_TE_SINEs.bed
grep 'family_id "Alu"' bed/GRCh38_Ensembl_rmsk_TE.bed > bed/GRCh38_Ensembl_rmsk_TE_Alus.bed
grep 'class_id "LTR"' bed/GRCh38_Ensembl_rmsk_TE.bed > bed/GRCh38_Ensembl_rmsk_TE_ERVs.bed
grep 'class_id "DNA"' bed/GRCh38_Ensembl_rmsk_TE.bed > bed/GRCh38_Ensembl_rmsk_TE_transposons.bed

