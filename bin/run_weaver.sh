#!/usr/bin/bash

BAM=$1
REFDIR=$2
T1000=$3
SEX=$4
BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LD_LIBRARY_PATH=${BIN}/../Weaver_SV/lib/:${LD_LIBRARY_PATH}

ARR=(WIG SV SNP)
for K in ${ARR[@]}; do
    echo $K,${ARR}
    perl $BIN/Weaver_pipeline.pl ALL ${K} \
        -f ${REFDIR} \
        -g ${BIN}/../data/GAP_20140416 -b ${BAM} \
        -k ${T1000} -s ${SEX} >weaver_${K} 2>weaver_${K}_error&
done
wait
CANCER_COV=`cat ${BAM}.coverage`
NORMAL_COV=0

FASTA=${REFDIR}.fasta
if [ ! -f ${FASTA} ]; then
    FASTA=${REFDIR}.fa
fi

${BIN}/Weaver PLOIDY \
    -f ${REFDIR}.fasta \
    -s SNP \
    -S ${BAM}.Weaver.GOOD -g ${BIN}/../data/GAP_20140416_num \
    -m ${BIN}/../data/wgEncodeCrgMapabilityAlign100mer_number.bd \
    -w ${BAM}.wig -r 1 \
    -t ${CANCER_COV} -n ${NORMAL_COV} \
    -p 16 >weaver_ploidy 2>weaver_ploidy_error
${BIN}/Weaver LITE \
    -f ${REFDIR}.fasta \
    -s SNP \
    -S ${BAM}.Weaver.GOOD -g ${BIN}/../data/GAP_20140416_num \
    -m ${BIN}/../data/wgEncodeCrgMapabilityAlign100mer_number.bd \
    -w ${BAM}.wig -r 1 \
    -t ${CANCER_COV} -n ${NORMAL_COV} \
    -p 16 >weaver_lite 2>weaver_lite_error
