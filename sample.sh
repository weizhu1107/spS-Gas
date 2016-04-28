#!/bin/bash
count=0
while read line;do
        ta[$count]=${line##*=}
        count=$(( $count + 1 ))
done < $1

GOTCLOUD_ROOT=${ta[0]}					##Gotcloud installed directory
hap_ref=${ta[2]}                          		##SNP Reference: Eur.legend
num_reg=${ta[4]}                          		##Number of regions created
let REGION_LN=${ta[5]}                    		##Region length
BASIS_DIR=${ta[1]}					##Basis_directory_for_output
BIN_DIR=${ta[2]}					##Basis_directory_for_bin
let prev=${ta[5]}					##Prevalence
let n_case=${ta[7]}					##Number of cases
let n_control=${ta[8]}					##Number of controls
let nc=${ta[9]}						##Number of causal alleles
let fcov=${ta[10]}					##Sequencing coverage

SCN="SIM_n"$n_case"_c"$fcov
SN=$2

OS_BIN=$BIN_DIR"/script"
OUT_DIR=$BASIS_DIR"/"$SCN"/"$SN			##Scenario name of $4; serial number of $5
REGION_FL=$BASIS_DIR"/region/"$SN".txt"		##Region file location
CAUSAL_FL=$BASIS_DIR"/causal_list/"$SN".txt"		##Causal SNP file location

mkdir -p $OUT_DIR
f=$hap_ref"/chr22_EUR.legend"

count=0
while read line;do
        a[$count]=${line##*:}
        count=$(( $count + 1 ))
done < $REGION_FL

c_ln=0
causl_l=""
while read -a c_dd;do
	if [[ "$c_ln" -gt "0" && "$c_ln" -lt "16" ]];then
		causl_l=$causl_l${c_dd[1]}" 1 "${c_dd[5]}" "${c_dd[6]}" "
	fi
	c_ln=$(( $c_ln + 1 ))
done < $CAUSAL_FL

let LOW_BOUND=${a[0]}
let UP_BOUND=${a[1]}
let LOW_BOUND_L=$(($LOW_BOUND - 500))
let UP_BOUND_R=$(($UP_BOUND + 500))

hapgen2 -m $hap_ref/chr22_combined_b37.txt -l $hap_ref/chr22_EUR.legend -h $hap_ref/chr22_EUR.hap -o $OUT_DIR/h -dl $causl_l -n $n_case $n_control -int $LOW_BOUND $UP_BOUND >$OUT_DIR/debug.txt

echo "hapgen2 completed..."
echo "LOW_BOUND:"$LOW_BOUND > $OUT_DIR/config.txt
echo "UP_BOUND:"$UP_BOUND >> $OUT_DIR/config.txt
echo "n_case:"$n_case >> $OUT_DIR/config.txt
echo "n_control:"$n_control >> $OUT_DIR/config.txt
echo "f_cov:"$fcov >> $OUT_DIR/config.txt

CHR=22
LN=51304566

echo "hap_to_fa"
cp $hap_ref/chr22.fa* $OUT_DIR/
$OS_BIN/hap_to_fa.py $OUT_DIR/chr22.fa $CHR $LOW_BOUND $REGION_LN $OUT_DIR/t.fa

echo "fa_per_subject"
mkdir -p $OUT_DIR/fasta
$OS_BIN/fa_per_subject.py $OUT_DIR/t.fa $OUT_DIR/h.legend $OUT_DIR/h.cases.haps $LOW_BOUND $UP_BOUND $OUT_DIR $OUT_DIR/h.cases.sample
$OS_BIN/fa_per_subject.py $OUT_DIR/t.fa $OUT_DIR/h.legend $OUT_DIR/h.controls.haps $LOW_BOUND $UP_BOUND $OUT_DIR $OUT_DIR/h.controls.sample

mkdir -p $OUT_DIR/read
mkdir -p $OUT_DIR/glfs
mkdir -p $OUT_DIR/vcfs
touch $OUT_DIR/vcfs/glfIndex.ped
touch $OUT_DIR/bam.index

##function for parallel computing
func_S3(){
	LN=$8
	LOW_BOUND=$7
	UP_BOUND_R=$6
	LOW_BOUND_L=$5
	CHR=$4
	GOTCLOUD_ROOT=$3
	OUT_DIR=$2
	fcov=$9
	i=$1
	a=${i##*/}i
	i=${a%.*}
	art_illumina -sam -i $OUT_DIR/fasta/$i.fa -p -l 125 -f $fcov -m 200 -s 10 -o $OUT_DIR/read/$i >> $OUT_DIR/art.log
	$OS_BIN/sam_offset.py $OUT_DIR/read/$i.sam $LOW_BOUND $8
	$GOTCLOUD_ROOT/bin/samtools view -ubS $OUT_DIR/read/$i.sam | $GOTCLOUD_ROOT/bin/samtools sort - $OUT_DIR/read/$i"_sorted"
	$GOTCLOUD_ROOT/bin/samtools index $OUT_DIR/read/$i"_sorted.bam"
	BAM_NAME=$OUT_DIR/read/$i"_sorted.bam"
	rm -f $OUT_DIR/read/$i.sam
	rm -f $OUT_DIR/read/$i[1-2].aln
	rm -f $OUT_DIR/read/$i[1-2].fq
	printf "$i\tALL\t$BAM_NAME\n" >> $OUT_DIR/bam.index
#	$GOTCLOUD_ROOT/bin/samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i"_sorted.bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | $GOTCLOUD_ROOT/bin/samtools-hybrid calmd -uAEbr - $GOTCLOUD_ROOT/ref/human.g1k.v37.fa | $GOTCLOUD_ROOT/bin/bam clipOverlap --in -.ubam --out -.ubam --phoneHomeThinning 0 | $GOTCLOUD_ROOT/bin/samtools-hybrid pileup -f $GOTCLOUD_ROOT/ref/human.g1k.v37.fa -g - > $OUT_DIR/glfs/$i.glf
	$GOTCLOUD_ROOT/bin/samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i"_sorted.bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | $GOTCLOUD_ROOT/bin/samtools-hybrid calmd -uAEbr - $hap_ref/chr22.fa| $GOTCLOUD_ROOT/bin/bam clipOverlap --in -.ubam --out -.ubam --phoneHomeThinning 0 | $GOTCLOUD_ROOT/bin/samtools-hybrid pileup -f $hap_ref/chr22.fa -g - > $OUT_DIR/glfs/$i.glf
	rm -f $OUT_DIR/read/$i"_sorted.bam"
	rm -f $OUT_DIR/read/$i"_sorted.bam.bai"
}

export -f func_S3
echo "sim sequencing reads"
parallel --no-notice -j8 "func_S3 {}" ::: $OUT_DIR/fasta/* ::: $OUT_DIR ::: $GOTCLOUD_ROOT ::: $CHR ::: $LOW_BOUND_L ::: $UP_BOUND_R ::: $LOW_BOUND ::: $LN ::: $fcov

rm -Rf $OUT_DIR/fasta &
