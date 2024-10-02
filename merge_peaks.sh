#!/usr/bin/env bash

mamba activate deeptools

DIR="macs2"
for i in $(ls -d $DIR/*_1/); do
    NAME=$(basename $i)
    NAME=$(echo $NAME | sed 's/_1$//')
    
    PEAKS1="$DIR/${NAME}_1/${NAME}_1_peaks.broadPeak"
    PEAKS2="$DIR/${NAME}_2/${NAME}_2_peaks.broadPeak"

    bedtools intersect -a $PEAKS1 -b $PEAKS2 > $DIR/${NAME}_merged_peaks.bed
done