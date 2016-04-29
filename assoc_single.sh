#!/bin/bash
data_dir=/DataStorage/Backup/xc/ngs/$1/$2

cd $data_dir

if [ -f "chr22.vcf" ];then
	vcftools --vcf chr22.vcf --plink
	/home/xc/ngs/bin/ped_phetyp.py out.ped
	plink --noweb --file out --allow-no-sex --logistic
	rm -f out.ped
	rm -f out.map
	rm -f plink.nosex
fi
