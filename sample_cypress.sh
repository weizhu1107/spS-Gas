#!/bin/bash
GOTCLOUD_ROOT="/home/cxu2/gotcloud"
OS_BIN="/home/cxu2/ngs/bin"
OWN_BIN="/home/cxu2/bin"
let REGION_LN=100000                    			##Region length
OUT_BASIS_DIR="/lustre/project/hdeng2/wzhu/genotype_imputation/Output"		##Basis_directory_for_output
BASIS_DIR="/lustre/project/hdeng2/wzhu/genotype_imputation"			##Basis_directory_for_spS-Gas

let n_case=0						##Number of cases
let n_control=$1					##Number of controls
let fcov=$2						##Sequencing coverage

SCN="impute_n"$n_control"_c"$f_cov
SN=$3

hap_ref=$BASIS_DIR"/1000Genome"
OUT_DIR=$OUT_BASIS_DIR"/"$SCN"/"$SN			##Scenario name of $4; serial number of $5
REGION_FL=$OUT_BASIS_DIR"/region/"$SN".txt"

mkdir -p $OUT_DIR
f=$hap_ref"/chr22_EUR.legend"

LD_LIBRARY_PATH=/home/cxu2/local/lib:/usr/local/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH

count=0
while read line;do
        a[$count]=${line##*:}
        count=$(( $count + 1 ))
done < $REGION_FL

c_ln=0
causl_l=""
causl_l=$causl_l${a[2]}" 1 1.2 1.6"

let LOW_BOUND=${a[0]}
let UP_BOUND=${a[1]}
let LOW_BOUND_L=$(($LOW_BOUND - 500))
let UP_BOUND_R=$(($UP_BOUND + 500))

$OWN_BIN/hapgen2 -m $hap_ref/chr22_combined_b37.txt -l $hap_ref/chr22_EUR.legend -h $hap_ref/chr22_EUR.hap -dl $causl_l -o $OUT_DIR/h -n $n_control $n_case -int $LOW_BOUND $UP_BOUND >$OUT_DIR/debug.txt

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
$OS_BIN/fa_per_subject.py $OUT_DIR/t.fa $OUT_DIR/h.legend $OUT_DIR/h.cases.haps $LOW_BOUND $UP_BOUND $OUT_DIR $OUT_DIR/h.cases.samp              le
$OS_BIN/fa_per_subject.py $OUT_DIR/t.fa $OUT_DIR/h.legend $OUT_DIR/h.controls.haps $LOW_BOUND $UP_BOUND $OUT_DIR $OUT_DIR/h.control              s.sample

mkdir -p $OUT_DIR/read
#touch $OUT_DIR/vcfs/glfIndex.ped
touch $OUT_DIR/bam.index

echo "sim sequencing reads"

mkdir -p $OUT_DIR/glfs
mkdir -p $OUT_DIR/vcfs
touch $OUT_DIR/vcfs/glfIndex.ped
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

        #$GOTCLOUD_ROOT/bin/samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i".bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | $GOTCL              OUD_ROOT/bin/samtools-hybrid calmd -uAEbr - $OUT_DIR/chr22.fa | $GOTCLOUD_ROOT/bin/bam clipOverlap --in -.ubam --out -.ubam --phone              HomeThinning 0 | $GOTCLOUD_ROOT/bin/samtools-hybrid pileup -f $OUT_DIR/chr22.fa -g - > $OUT_DIR/glfs/$i".glf"
        $OWN_BIN/samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i".bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | $OWN_BIN/samtools              -hybrid calmd -uAEbr - $OUT_DIR/chr22.fa | $OWN_BIN/bam clipOverlap --in -.ubam --out -.ubam --phoneHomeThinning 0 | $OWN_BIN/samto              ols-hybrid pileup -f $OUT_DIR/chr22.fa -g - > $OUT_DIR/glfs/$i".glf"
#       samtools-hybrid view -q 20 -F 0x0704 -uh $OUT_DIR/read/$i"_sorted.bam"  $CHR:$LOW_BOUND_L-$UP_BOUND_R | samtools-hybrid cal              md -uAEbr - $GOTCLOUD_ROOT/ref/human.g1k.v37.fa > $OUT_DIR/read/$i"_sorted_im.bam"
        rm -f $OUT_DIR/read/$i"_sorted.bam"
        rm -f $OUT_DIR/read/$i"_sorted.bam.bai"
        rm -f $OUT_DIR/read/$i".bam"
        rm -f $OUT_DIR/read/$i".bam.bai"
        rm -f $OUT_DIR/fasta/$i".fa"

done

rm -rf $OUT_DIR/fasta

let numSamples=$(($n_case+$n_control))
let FILTER_MAX_SAMPLE_DP=1000
FILTER_MIN_SAMPLE_DP=$(echo "$fcov" | bc -l)
FILTER_MIN_NS_FRAC="0.01"
FILTER_MAX_DP=$(($FILTER_MAX_SAMPLE_DP * $numSamples))
FILTER_MIN_DP=$fcov
minNS=`echo $(printf "%.0f" $( echo "$FILTER_MIN_NS_FRAC * $numSamples" | bc))`

rm -f $OUT_DIR/chr22.fa*
perl $GOTCLOUD_ROOT/scripts/imake.pl $OUT_DIR/bam.index $OUT_DIR/vcfs/glfIndex.ped  $OUT_DIR/glfs

$GOTCLOUD_ROOT/src/bin/glfFlex --minMapQuality 30 --minDepth $FILTER_MIN_DP --maxDepth $FILTER_MAX_DP --uniformTsTv --smartFilter -              -ped $OUT_DIR/vcfs/glfIndex.ped -b $OUT_DIR/vcfs/chr22.vcf
cut -f 1-8 $OUT_DIR/vcfs/chr22.vcf > $OUT_DIR/vcfs/chr22.sites.vcf

#zip $OUT_DIR"/glf"  $OUT_DIR/glfs/*
rm -rf $OUT_DIR/glfs

let maxABL=65
let maxCBR=10
let maxLQR=20
let maxSTR=10
let maxSTZ=10
let minFIC=-10
let minSTR=-10
let minSTZ=-10

if [ $numSamples -lt 100 ];then
        let maxABL=70
        let maxCBR=20
        let maxLQR=30
        let maxSTR=20
        let maxSTZ=5
        let minFIC=-20
        let minSTR=-20
        let minSTZ=-5
elif [ $numSamples -lt 1000 ];then
        maxABL=`echo $(printf "%.0f" $( echo "(70 - 65) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + 65" | bc -l))`
        maxCBR=`echo $(printf "%.0f" $( echo "(20 - 10) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + 10" | bc -l))`
        maxLQR=`echo $(printf "%.0f" $( echo "(30 - 20) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + 20" | bc -l))`
        maxSTR=`echo $(printf "%.0f" $( echo "(20 - 10) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + 10" | bc -l))`
        maxSTZ=`echo $(printf "%.0f" $( echo "(5 - 10) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + 10" | bc -l))`
        minFIC=`echo $(printf "%.0f" $( echo "(-20 - -10) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + -10" | bc -l))`
        minSTR=`echo $(printf "%.0f" $( echo "(-20 - -10) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + -10" | bc -l))`
        minSTZ=`echo $(printf "%.0f" $( echo "(-5 - -10) * (l(1000) - l($numSamples)) / (l(1000) - l(100) ) + -10" | bc -l))`
fi

$GOTCLOUD_ROOT/src/bin/vcfCooker --write-vcf --filter --maxDP $FILTER_MAX_DP --minDP $FILTER_MIN_DP --minNS $minNS --maxABL $maxABL               --maxAOI 5 --maxCBR $maxCBR --maxLQR $maxLQR --maxMQ0 10 --maxSTR $maxSTR --maxSTZ $maxSTZ --minFIC $minFIC --minMQ 30 --minQual 3              0 --minSTR $minSTR --minSTZ $minSTZ --winIndel 5 --indelVCF $hap_ref/1kg.pilot_release.merged.indels.sites.hg19.chr22.vcf --out $OU              T_DIR/vcfs/chr22.hardfiltered.sites.vcf --in-vcf $OUT_DIR/vcfs/chr22.sites.vcf

bash -c "set -e -o pipefail; perl $GOTCLOUD_ROOT/scripts/vcfPaste.pl $OUT_DIR/vcfs/chr22.hardfiltered.sites.vcf $OUT_DIR/vcfs/chr22              .vcf | $GOTCLOUD_ROOT/src/bin/bgzip -c > $OUT_DIR/vcfs/chr22.filtered.vcf.gz"
$GOTCLOUD_ROOT/src/bin/tabix -f -pvcf $OUT_DIR/vcfs/chr22.filtered.vcf.gz
bash -c "set -e -o pipefail; zcat $OUT_DIR/vcfs/chr22.filtered.vcf.gz | grep -E \"\sPASS\s|^#\" | $GOTCLOUD_ROOT/src/bin/bgzip -c >               $OUT_DIR/vcfs/chr22.filtered.PASS.vcf.gz"


#       $OS_BIN/sample_v2.sh $1 $2 $3 $4 $5

#beagle
#mkdir --p $OUT_DIR/beagle
#perl $GOTCLOUD_ROOT/scripts/vcf2Beagle.pl --PL --in $OUT_DIR/vcfs/chr22.filtered.PASS.vcf.gz --out $OUT_DIR/beagle/chr22.PASS.gz
#java -Xmx4g -jar $GOTCLOUD_ROOT/bin/beagle.20101226.jar seed=993478 gprobs=true niterations=30 lowmem=true like=$OUT_DIR/beagle/ch              r22.PASS.gz out=$OUT_DIR/beagle/bgl >$OUT_DIR/beagle/bgl.out
#perl $GOTCLOUD_ROOT/scripts/beagle2Vcf.pl --filter --beagle $OUT_DIR/beagle/bgl.chr22.PASS.gz --invcf $OUT_DIR/vcfs/chr22.filtered              .PASS.vcf.gz --outvcf $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf
#$GOTCLOUD_ROOT/bin/bgzip -f $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf
#$GOTCLOUD_ROOT/bin/tabix -f -pvcf $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf.gz

#thunder
#mkdir --p $OUT_DIR/thunder
#$GOTCLOUD_ROOT/bin/thunderVCF -r 8 --phase --dosage --inputPhased --states 200 --weightedStates 150 --shotgun $OUT_DIR/beagle/chr2              2.filtered.PASS.beagled.vcf.gz -o $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder > $OUT_DIR/thunder/chr22.filtered.PASS.beagl              ed.thunder.out
#$GOTCLOUD_ROOT/bin/bgzip -c $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder.vcf.gz > $OUT_DIR/thunder/chr22.filtered.PASS.bea              gled.thunder.vcf.gz
#$GOTCLOUD_ROOT/bin/tabix -f -pvcf $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder.vcf.gz
