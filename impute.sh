#!/bin/bash
count=0
while read line;do
        ta[$count]=${line##*=}
        count=$(( $count + 1 ))
done < $1

OUT_BASIS_DIR=${ta[1]}	                                ##Basis_directory_for_output
BASIS_DIR=${ta[2]}	                                ##Basis_directory_for_spS-Gas
SN=$4

REGION_FL=$OUT_BASIS_DIR"/region/"$SN".txt"	        ##Region file location

count=0
while read line;do
        a[$count]=${line##*:}
        b[$count]=$line
        count=$(( $count + 1 ))
done < $REGION_FL

let LOW_BOUND=${a[0]}
let UP_BOUND=${a[1]}


if [ -d $OUT_BASIS_DIR/$2/$SN ];then

        echo "Process ref..."

        if [ ! -f $OUT_BASIS_DIR/$2/$SN/impute_ref.gen.gz ];then
                cd $OUT_BASIS_DIR/$2/$SN
                $BASIS_DIR/bin/vcf_to_gen.pl -vcf chr22.vcf -gen impute_ref.gen
        fi

        echo "Process study..."

        if [ ! -f $OUT_BASIS_DIR/$3/$SN/impute_ref.gen.gz ];then
                cd $OUT_BASIS_DIR/$3/$SN
                $BASIS_DIR/bin/vcf_to_gen.pl -vcf chr22.vcf -gen impute_study.gen
        fi

        echo "Imputing..."
        mkdir -p $OUT_BASIS_DIR/impute/$2_$3/$SN
        impute2 -m $BASIS_DIR/hap_ref/chr22_combined_b37.txt -g_ref $OUT_BASIS_DIR/$2/$SN/impute_ref.gen.gz -g $OUT_BASIS_DIR/$3/$SN/impute_study.gen.gz -buffer 1 -int $LOW_BOUND $UP_BOUND -burnin 9 -iter 28 -o $OUT_BASIS_DIR/impute/$2_$3/$SN/impute

fi
