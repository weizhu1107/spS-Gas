#!/bin/bash
count=0
while read line;do
        a[$count]=${line##*=}
        count=$(( $count + 1 ))
done < $1

num_reg=${a[3]}                          ##Number of regions created
let REGION_LN=${a[4]}                    ##Region length
OUT_BASIS_DIR=${a[1]}			##Basis_directory_for_output
BASIS_DIR=${a[2]}				##Basis_directory_for_bin
prev=${a[5]}				##Prevalence
let nc=${a[8]}				##Number of causal alleles

hap_ref=$BASIS_DIR"/hap_ref"
REG_DIR=$OUT_BASIS_DIR/region                   ##Region file directory
mkdir -p $REG_DIR
LGD_DIR=$OUT_BASIS_DIR/legend_maf               ##Legend file directory
mkdir -p $LGD_DIR
CAL_DIR=$OUT_BASIS_DIR/causal_list
mkdir -p $CAL_DIR

f=$hap_ref"/chr22_EUR.legend"

for i in `seq 1 $num_reg`;do
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

  echo "LOW_BOUND:"$LOW_BOUND > $REG_DIR/$i.txt
  echo "UP_BOUND:"$UP_BOUND >> $REG_DIR/$i.txt
  
  $BASIS_DIR/script/init_legend_dir.py $f $LOW_BOUND $UP_BOUND $LGD_DIR/$i
done


for i in `seq 1 $num_reg`;do
	if [ -f $LGD_DIR"/"$i".txt" ];then
		echo $i
		Rscript $BASIS_DIR/script/causal_allel.R $LGD_DIR"/"$i".txt" $CAL_DIR"/"$i".txt" $prev $nc
	fi
done
