#!/bin/bash
hap_ref=$1                          ##SNP Reference: Eur.legend
num_reg=$2                          ##Number of regions created
let REGION_LN=$3                    ##Region length
OUT_DIR=$4                          ##Region file directory
mkdir -p $OUT_DIR


for i in `seq 1 $num_reg`;do
  echo $i
  cl=`shuf -i 311-308149 -n 1`
  mp=`sed -n "$cl p" $hap_ref | cut -f2`
  mp_n=`sed -n "$cl p" $hap_ref | cut -f1`
  mp_af=`sed -n "$cl p" $hap_ref | cut -f5`
  tl=`shuf -i 1-$REGION_LN -n 1`

  let LOW_BOUND=$(($mp - $tl))
  let UP_BOUND=$(($LOW_BOUND + $REGION_LN - 1))
  let LOW_BOUND_L=$(($LOW_BOUND - 500))
  let UP_BOUND_R=$(($UP_BOUND + 500))

  echo "LOW_BOUND:"$LOW_BOUND > $OUT_DIR/$i.txt
  echo "UP_BOUND:"$UP_BOUND >> $OUT_DIR/$i.txt
done
