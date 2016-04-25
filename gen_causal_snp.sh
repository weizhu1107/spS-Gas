#!/bin/bash
BASIS_DIR=$1
num_reg=$2
let prev=$3
let nc=$4

for i in `seq 1 $num_reg`;do
	if [ -f $BASIS_DIR"/h_legend_maf/"$i".txt" ];then
		echo $i
		Rscript $BASIS_DIR/bin/causal_allel.R $BASIS_DIR"/legend_maf/"$i".txt" $BASIS_DIR"/causal_list/"$i".txt" $prev $nc
	fi
done
