#!/bin/bash
hap_ref=$1                          ##SNP Reference: Eur.legend
num_reg=$2                          ##Number of regions created
let REGION_LN=$3                    ##Region length
BASIS_DIR=$4
let prev=$5			##prevalence
let nc=$6			##number of causal alleles

REG_DIR=$BASIS_DIR/region                   ##Region file directory
mkdir -p $REG_DIR
LGD_DIR=$BASIS_DIR/legend_maf               ##Legend file directory
mkdir -p $LGD_DIR
mkdir -p $BASIS_DIR/causal_list

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

  echo "LOW_BOUND:"$LOW_BOUND > $REG_DIR/$i.txt
  echo "UP_BOUND:"$UP_BOUND >> $REG_DIR/$i.txt
  
  ./init_legend_dir.py $1 $LOW_BOUND $UP_BOUND $LGD_DIR/$i
done


for i in `seq 1 $num_reg`;do
	if [ -f $LGD_DIR"/"$i".txt" ];then
		echo $i
		Rscript $BASIS_DIR/scripts/causal_allel.R $LGD_DIR"/"$i".txt" $BASIS_DIR"/causal_list/"$i".txt" $prev $nc
	fi
done
