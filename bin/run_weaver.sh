#!/usr/bin/bash

BAM=$1
REFDIR=$2
T1000=$3
SEX=$4
NORMAL_COV=$5
THREADS=$6
NNUM=$7

BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export LD_LIBRARY_PATH=${BIN}/../Weaver_SV/lib/:${LD_LIBRARY_PATH}

if [[ "${NNUM}" -eq 1 ]]; then
    SUFF=_num
fi

GAP=${BIN}/../data/GAP_20140416_num
GAPALPHA=${BIN}/../data/GAP_20140416

ARR=(WIG SV SNP)
for K in ${ARR[@]}; do
    echo $K,${ARR}
    perl $BIN/Weaver_pipeline.pl ALL ${K} \
        -f ${REFDIR} \
        -g ${GAPALPHA} -b ${BAM} \
        -k ${T1000} -s ${SEX} >weaver_${K} 2>weaver_${K}_error&
done
wait
CANCER_COV=`cat ${BAM}.coverage`
re='^[0-9]+([.][0-9]+)?$'
if ! [[ ${NORMAL_COV} =~ $re ]] ; then
    NORMAL_COV=0
fi
if ! [[ ${THREADS} =~ $re ]] ; then
    THREADS=8
fi

FASTA=${REFDIR}.fasta
if [ ! -f ${FASTA} ]; then
    FASTA=${REFDIR}.fa
fi

${BIN}/Weaver PLOIDY \
    -f ${FASTA} \
    -s SNP \
    -S ${BAM}.Weaver.GOOD -g ${GAP%$SUFF} \
    -m ${BIN}/../data/wgEncodeCrgMapabilityAlign100mer_number.bd \
    -w ${BAM}.wig -r 1 \
    -t ${CANCER_COV} -n ${NORMAL_COV} \
    -p ${THREADS} >weaver_ploidy 2>weaver_ploidy_error

${BIN}/Weaver LITE \
    -f ${FASTA} \
    -s SNP \
    -S ${BAM}.Weaver.GOOD -g ${GAP%$SUFF} \
    -m ${BIN}/../data/wgEncodeCrgMapabilityAlign100mer_number.bd \
    -w ${BAM}.wig -r 1 \
    -t ${CANCER_COV} -n ${NORMAL_COV} \
    -p  ${THREADS} >weaver_lite 2>weaver_lite_error
