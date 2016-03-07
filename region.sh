#!/bin/bash
OUT_DIR="/DataStorage/Backup/xc/ngs/region"
mkdir -p $OUT_DIR
let REGION_LN=100000
hap_ref="/home/xc/ngs/hap_ref"
f=$hap_ref"/chr22_EUR.legend"

for i in `seq 1001 1003`;do
echo $i
cl=`shuf -i 311-308149 -n 1`
mp=`sed -n "$cl p" $f | cut -f2`
mp_n=`sed -n "$cl p" $f | cut -f1`
mp_af=`sed -n "$cl p" $f | cut -f5`
tl=`shuf -i 1-$REGION_LN -n 1`

let LOW_BOUND=$(($mp - $tl))
let UP_BOUND=$(($LOW_BOUND + $REGION_LN - 1))
let LOW_BOUND_L=$(($LOW_BOUND - 500))
let UP_BOUND_R=$(($UP_BOUND + 500))

echo "LOW_BOUND:"$LOW_BOUND > $OUT_DIR/$i.txt
echo "UP_BOUND:"$UP_BOUND >> $OUT_DIR/$i.txt
echo "disease_pos:"$mp >> $OUT_DIR/$i.txt
echo "disease_allele:"$mp_n >> $OUT_DIR/$i.txt
echo "disease_af:"$mp_af >> $OUT_DIR/$i.txt
done
