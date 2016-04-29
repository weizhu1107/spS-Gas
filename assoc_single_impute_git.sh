#!/bin/bash
data_dir=/DataStorage2/xc/ngs/impute/$1/$2

cd $data_dir

if [ ! -f "impute_assoc.ped" ];then
	cd /DataStorage2/xc/ngs/impute/$1

	IFS='_' read -a array <<< "$1"
	mp="${array[3]}_${array[4]}_${array[5]}"
	mkdir -p tmp
	cp /DataStorage/Backup/xc/ngs/$mp/1/impute_study.gen.samples tmp/
	/home/xc/ngs/bin/impute_ped.py tmp/impute_study.gen.samples
	cp tmp/impute_assoc.ped $2/
	rm -rf tmp
fi

if [ -f "impute_assoc.ped" ];then
	plink --noweb --file impute_assoc --allow-no-sex --logistic --no-sex --no-fid --no-parents
	#plink --noweb --file impute_assoc --allow-no-sex --assoc --no-sex --no-fid --no-parents
	rm -f plink.nosex &
fi
