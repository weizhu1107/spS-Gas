#!/bin/bash
count=0
while read line;do
        ta[$count]=${line##*=}
        count=$(( $count + 1 ))
done < $1

OUT_BASIS_DIR=${ta[1]}	                                ##Basis_directory_for_output
BASIS_DIR=${ta[2]}	                                ##Basis_directory_for_spS-Gas
SN=$3

data_dir=$OUT_BASIS_DIR/impute/$2/$SN

cd $data_dir

if [[ ! -f "impute_assoc.ped" || ! -f "impute_assoc.map" ]];then
	IFS='_' read -a array <<< "$1"
	mp="${array[3]}_${array[4]}_${array[5]}"
	cp $OUT_BASIS_DIR/$mp/1/impute_study.gen.samples ./
	$BASIS_DIR/script/impute_ped.py impute_study.gen.samples
fi

if [ -f "impute_assoc.ped" ];then
	plink --noweb --file impute_assoc --allow-no-sex --logistic --no-sex --no-fid --no-parents
	rm -f plink.nosex &
fi
