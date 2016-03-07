#!/bin/bash
for i in `seq 1 1000`;do
	if [ -f "/DataStorage/Backup/xc/ngs/h_legend_maf/"$i".txt" ];then
		echo $i
		Rscript /home/xc/ngs/bin/causal_allel.R $i
	fi
done
