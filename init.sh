#!/bin/bash
num_reg=1000                          ##Number of regions created
let REGION_LN=100000                    ##Region length
OUT_BASIS_DIR="/extra/wzhu3/genotype_imputation/Output/"			##Basis_directory_for_output
BASIS_DIR="/extra/wzhu3/genotype_imputation/"				##Basis_directory_for_bin

hap_ref=$BASIS_DIR"/1000Genome"
REG_DIR=$OUT_BASIS_DIR/region                   ##Region file directory
mkdir -p $REG_DIR
LGD_DIR=$OUT_BASIS_DIR/legend_maf               ##Legend file directory
mkdir -p $LGD_DIR


f=$hap_ref"/chr22_EUR.legend"

for i in `seq 1 $num_reg`;do
  echo $i
  cl=`shuf -i 311-308149 -n 1`
  mp=`sed -n "$cl p" $f | cut -f2`
  tl=`shuf -i 1-$REGION_LN -n 1`

  let LOW_BOUND=$(($mp - $tl))
  let UP_BOUND=$(($LOW_BOUND + $REGION_LN - 1))

  echo "LOW_BOUND:"$LOW_BOUND > $REG_DIR/$i.txt
  echo "UP_BOUND:"$UP_BOUND >> $REG_DIR/$i.txt
  echo "Causal_allel:"$mp >> $REG_DIR/$i.txt
  
  $BASIS_DIR/bin/init_legend_dir.py $f $LOW_BOUND $UP_BOUND $LGD_DIR/$i
done
