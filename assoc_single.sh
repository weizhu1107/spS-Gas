#!/bin/bash
count=0
while read line;do
        ta[$count]=${line##*=}
        count=$(( $count + 1 ))
done < $1

OUT_BASIS_DIR=${ta[1]}	                                ##Basis_directory_for_output
BASIS_DIR=${ta[2]}	                                ##Basis_directory_for_spS-Gas
SN=$3

data_dir=$OUT_BASIS_DIR/$2/$SN

cd $data_dir

if [ -f "chr22.vcf" ];then
	vcftools --vcf chr22.vcf --plink
	$BASIS_DIR/script/ped_phetyp.py out.ped
	plink --noweb --file out --allow-no-sex --logistic
	rm -f out.ped
	rm -f out.map
	rm -f plink.nosex
fi
