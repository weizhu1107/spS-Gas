#!/bin/bash
BASIS_DIR=$1
num_reg=$2			##number of regions
let prev=$3			##prevalence
let nc=$4			##number of causal alleles
mkdir -p $BASIS_DIR/causal_list

for i in `seq 1 $num_reg`;do
	if [ -f $BASIS_DIR"/legend_maf/"$i".txt" ];then
		echo $i
		Rscript $BASIS_DIR/bin/causal_allel.R $BASIS_DIR"/legend_maf/"$i".txt" $BASIS_DIR"/causal_list/"$i".txt" $prev $nc
	fi
done
