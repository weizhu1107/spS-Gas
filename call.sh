#!/bin/bash
count=0
while read line;do
        ta[$count]=${line##*=}
        count=$(( $count + 1 ))
done < $1

GOTCLOUD_ROOT=${ta[0]}					##Gotcloud installed directory
num_reg=${ta[3]}                          		##Number of regions created
let REGION_LN=${ta[4]}                    		##Region length
OUT_BASIS_DIR=${ta[1]}					##Basis_directory_for_output
BASIS_DIR=${ta[2]}					##Basis_directory_for_bin
let n_case=${ta[6]}					##Number of cases
let n_control=${ta[7]}					##Number of controls
let fcov=${ta[9]}					##Sequencing coverage

SCN="SIM_n"$n_case"_c"$fcov
SN=$2

hap_ref=$BASIS_DIR"/hap_ref"
OS_BIN=$BASIS_DIR"/script"
OUT_DIR=$OUT_BASIS_DIR"/"$SCN"/"$SN
f=$hap_ref"/chr22_EUR.legend"

#read design settings
count=0
while read line;do
        a[$count]=${line##*:}
        count=$(( $count + 1 ))
done < $OUT_DIR/config.txt

LOW_BOUND=${a[0]}
UP_BOUND=${a[1]}
n_case=${a[2]}
n_control=${a[3]}

let LOW_BOUND_L=$(($LOW_BOUND - 500))
let UP_BOUND_R=$(($UP_BOUND + 500))
fcov=${a[4]}

mkdir -p $OUT_DIR/glfs
mkdir -p $OUT_DIR/vcfs
touch $OUT_DIR/vcfs/glfIndex.ped
CHR=22

let numSamples=$(($n_case+$n_control))
let FILTER_MAX_SAMPLE_DP=1000
FILTER_MIN_SAMPLE_DP=$(echo "$fcov" | bc -l)
FILTER_MIN_NS_FRAC="0.01"
FILTER_MAX_DP=$(($FILTER_MAX_SAMPLE_DP * $numSamples))
FILTER_MIN_DP=$FILTER_MIN_SAMPLE_DP
minNS=`echo $(printf "%.0f" $( echo "$FILTER_MIN_NS_FRAC * $numSamples" | bc))`

rm -f $OUT_DIR/chr22.fa*
perl $GOTCLOUD_ROOT/scripts/imake.pl $OUT_DIR/bam.index $OUT_DIR/vcfs/glfIndex.ped  $OUT_DIR/glfs

$GOTCLOUD_ROOT/bin/glfFlex --minMapQuality 30 --minDepth $FILTER_MIN_DP --maxDepth $FILTER_MAX_DP --uniformTsTv --smartFilter --ped $OUT_DIR/vcfs/glfIndex.ped -b $OUT_DIR/vcfs/chr22.vcf
cut -f 1-8 $OUT_DIR/vcfs/chr22.vcf > $OUT_DIR/vcfs/chr22.sites.vcf

rm -f $OUT_DIR/glfs/* &

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

$GOTCLOUD_ROOT/bin/vcfCooker --write-vcf --filter --maxDP $FILTER_MAX_DP --minDP $FILTER_MIN_DP --minNS $minNS --maxABL $maxABL --maxAOI 5 --maxCBR $maxCBR --maxLQR $maxLQR --maxMQ0 10 --maxSTR $maxSTR --maxSTZ $maxSTZ --minFIC $minFIC --minMQ 30 --minQual 30 --minSTR $minSTR --minSTZ $minSTZ --winIndel 5 --indelVCF $hap_ref/1kg.pilot_release.merged.indels.sites.hg19.chr22.vcf --out $OUT_DIR/vcfs/chr22.hardfiltered.sites.vcf --in-vcf $OUT_DIR/vcfs/chr22.sites.vcf

#svm
#perl $GOTCLOUD_ROOT/scripts/run_libsvm.pl --invcf $OUT_DIR/vcfs/chr22.hardfiltered.sites.vcf --out $OUT_DIR/vcfs/chr22.filtered.sites.vcf --pos 100 --neg 100 --svmlearn $GOTCLOUD_ROOT/bin/svm-train --svmclassify $GOTCLOUD_ROOT/bin/svm-predict --bin $GOTCLOUD_ROOT/bin/invNorm --threshold 0 --bfile $GOTCLOUD_ROOT/ref/1000G_omni2.5.b37.sites.PASS.vcf.gz --bfile $GOTCLOUD_ROOT/ref/hapmap_3.3.b37.sites.vcf.gz --checkNA
bash -c "set -e -o pipefail; perl $GOTCLOUD_ROOT/scripts/vcfPaste.pl $OUT_DIR/vcfs/chr22.hardfiltered.sites.vcf $OUT_DIR/vcfs/chr22.vcf | $GOTCLOUD_ROOT/bin/bgzip -c > $OUT_DIR/vcfs/chr22.filtered.vcf.gz"
$GOTCLOUD_ROOT/bin/tabix -f -pvcf $OUT_DIR/vcfs/chr22.filtered.vcf.gz
bash -c "set -e -o pipefail; zcat $OUT_DIR/vcfs/chr22.filtered.vcf.gz | grep -E \"\sPASS\s|^#\" | $GOTCLOUD_ROOT/bin/bgzip -c > $OUT_DIR/vcfs/chr22.filtered.PASS.vcf.gz"

#beagle
#mkdir --p $OUT_DIR/beagle
#perl $GOTCLOUD_ROOT/scripts/vcf2Beagle.pl --PL --in $OUT_DIR/vcfs/chr22.filtered.PASS.vcf.gz --out $OUT_DIR/beagle/chr22.PASS.gz
#java -Xmx4g -jar $GOTCLOUD_ROOT/bin/beagle.20101226.jar seed=993478 gprobs=true niterations=30 lowmem=true like=$OUT_DIR/beagle/chr22.PASS.gz out=$OUT_DIR/beagle/bgl >$OUT_DIR/beagle/bgl.out
#perl $GOTCLOUD_ROOT/scripts/beagle2Vcf.pl --filter --beagle $OUT_DIR/beagle/bgl.chr22.PASS.gz --invcf $OUT_DIR/vcfs/chr22.filtered.PASS.vcf.gz --outvcf $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf
#$GOTCLOUD_ROOT/bin/bgzip -f $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf
#$GOTCLOUD_ROOT/bin/tabix -f -pvcf $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf.gz

#thunder
#mkdir --p $OUT_DIR/thunder
#$GOTCLOUD_ROOT/bin/thunderVCF -r 8 --phase --dosage --inputPhased --states 200 --weightedStates 150 --shotgun $OUT_DIR/beagle/chr22.filtered.PASS.beagled.vcf.gz -o $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder > $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder.out
#$GOTCLOUD_ROOT/bin/bgzip -c $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder.vcf.gz > $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder.vcf.gz
#$GOTCLOUD_ROOT/bin/tabix -f -pvcf $OUT_DIR/thunder/chr22.filtered.PASS.beagled.thunder.vcf.gz
