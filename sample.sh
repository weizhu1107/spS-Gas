#!/bin/bash
GOTCLOUD_ROOT="/extra/wzhu3/genotype_imputation/gotcloud"	##Gotcloud installed directory
let REGION_LN=100000                    			##Region length
OUT_BASIS_DIR="/extra/wzhu3/genotype_imputation/Output"		##Basis_directory_for_output
BASIS_DIR="/extra/wzhu3/genotype_imputation"			##Basis_directory_for_spS-Gas

let n_case=0						##Number of cases
let n_control=$1					##Number of controls
let fcov=$2						##Sequencing coverage

SCN="impute_n"$n_control"_c"$f_cov
SN=$3

hap_ref=$BASIS_DIR"/hap_ref"
OS_BIN=$BASIS_DIR"/bin"
OUT_DIR=$OUT_BASIS_DIR"/"$SCN"/"$SN			##Scenario name of $4; serial number of $5
REGION_FL=$OUT_BASIS_DIR"/region/"$SN".txt"		##Region file location

mkdir -p $OUT_DIR
f=$hap_ref"/chr22_EUR.legend"

count=0
while read line;do
        a[$count]=${line##*:}
        count=$(( $count + 1 ))
done < $REGION_FL

causl_l=$causl_l${a[2]}" 1 1.2 1.6"

let LOW_BOUND=${a[0]}
let UP_BOUND=${a[1]}

hapgen2 -m $hap_ref/chr22_combined_b37.txt -l $hap_ref/chr22_EUR.legend -h $hap_ref/chr22_EUR.hap -dl $causl_l -o $OUT_DIR/h -n $n_control $n_case -int $LOW_BOUND $UP_BOUND >$OUT_DIR/debug.txt

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
$OS_BIN/fa_per_subject.py $OUT_DIR/t.fa $OUT_DIR/h.legend $OUT_DIR/h.controls.haps $LOW_BOUND $UP_BOUND $OUT_DIR $OUT_DIR/h.controls.sample

mkdir -p $OUT_DIR/read
mkdir -p $OUT_DIR/glfs
mkdir -p $OUT_DIR/vcfs
touch $OUT_DIR/vcfs/glfIndex.ped
touch $OUT_DIR/bam.index

module load samtools

for i in $OUT_DIR/fasta/*;do
        a=${i##*/}i
        i=${a%.*}
        $OWN_BIN/art_illumina -sam -i $OUT_DIR/fasta/$i.fa -p -l 125 -f $fcov -m 200 -s 10 -o $OUT_DIR/read/$i >> $OUT_DIR/art.log
        $OS_BIN/sam_offset.py $OUT_DIR/read/$i.sam $LOW_BOUND $LN
        samtools view -ubS $OUT_DIR/read/$i.sam | samtools sort - $OUT_DIR/read/$i
        samtools index $OUT_DIR/read/$i".bam"
        BAM_NAME=$OUT_DIR/read/$i".bam"
        rm -f $OUT_DIR/read/$i.sam
        rm -f $OUT_DIR/read/$i[1-2].aln
        rm -f $OUT_DIR/read/$i[1-2].fq
        printf "$i\tALL\t$BAM_NAME\n" >> $OUT_DIR/bam.index

        #$GOTCLOUD_ROOT/bin/samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i".bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | $GOTCLO                UD_ROOT/bin/samtools-hybrid calmd -uAEbr - $OUT_DIR/chr22.fa | $GOTCLOUD_ROOT/bin/bam clipOverlap --in -.ubam --out -.ubam --phoneHo                meThinning 0 | $GOTCLOUD_ROOT/bin/samtools-hybrid pileup -f $OUT_DIR/chr22.fa -g - > $OUT_DIR/glfs/$i".glf"
        $OWN_BIN/samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i".bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | $OWN_BIN/samtools-                hybrid calmd -uAEbr - $OUT_DIR/chr22.fa | $OWN_BIN/bam clipOverlap --in -.ubam --out -.ubam --phoneHomeThinning 0 | $OWN_BIN/samtool                s-hybrid pileup -f $OUT_DIR/chr22.fa -g - > $OUT_DIR/glfs/$i".glf"
#       samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i"_sorted.bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | samtools-hybrid calm                d -uAEbr - $GOTCLOUD_ROOT/ref/human.g1k.v37.fa > $OUT_DIR/read/$i"_sorted_im.bam"
        rm -f $OUT_DIR/read/$i"_sorted.bam"
        rm -f $OUT_DIR/read/$i"_sorted.bam.bai"
        rm -f $OUT_DIR/read/$i".bam"
        rm -f $OUT_DIR/read/$i".bam.bai"
        rm -f $OUT_DIR/fasta/$i".fa"

done

rm -rf $OUT_DIR/fasta

