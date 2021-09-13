#!/bin/sh
#
#  gotextload.sh
###########################################################################
#
#  Purpose:
#
#      This script serves as a wrapper for the GO text load.
#
#  Usage:
#
#      gotextload.sh
#
#
#  Env Vars:
#
#      See the configuration files
#
#  Inputs:  None
#
#  Outputs:
#
#      - GO text input file for the note load (${GOTEXT_FILE})
#
#      - Log file (${LOGFILE})
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#
#  Assumes:  Nothing
#
#  Implementation:
#
#  Notes:  None
#
###########################################################################

cd `dirname $0`
. ../Configuration

rm -rf ${LOGFILE}
touch ${LOGFILE}

#
# Create a temporary file that will hold the return code from calling the
# Python script. Make sure the file is removed when this script terminates.
#
TMP_RC=/tmp/`basename $0`.$$
trap "rm -f ${TMP_RC}" 0 1 2 15

#
# Make sure the Alliance input file exists, copy it to the input directory
# and unzip it.
#
date >> ${LOGFILE}
echo "Get the Alliance input file" | tee -a ${LOGFILE}
if [ -e ${ZIPFILE_PATH} ]
then
    cp ${ZIPFILE_PATH} ${INPUTDIR}
    cd ${INPUTDIR}
    gunzip -f ${ZIPFILE_NAME}
else
    echo "Missing Alliance input file: ${ZIPFILE_PATH}" | tee -a ${LOGFILE}
    date >> ${LOGFILE}
    exit 1
fi

#
# Get the Alliance release number from the input file.
#
echo "" >> ${LOGFILE}
date >> ${LOGFILE}
echo "Get the Alliance release number from the input file" | tee -a ${LOGFILE}
ALLIANCE_RELEASE=`cat ${INPUT_FILE} | grep "# Alliance Database Version:" | cut -d':' -f2 | sed 's/ //g'`
if [ "${ALLIANCE_RELEASE}" == "" ]
then
    echo "Cannot determine Alliance release number" | tee -a ${LOGFILE}
    date >> ${LOGFILE}
    exit 1
fi

echo "Alliance release number: ${ALLIANCE_RELEASE}" | tee -a ${LOGFILE}
export ALLIANCE_RELEASE

#
# Generate the GO text input file from the Alliance file.
#
echo "" >> ${LOGFILE}
date >> ${LOGFILE}
echo "Generate the GO text input file" | tee -a ${LOGFILE}
{ ${PYTHON} ${GOTEXTLOAD}/bin/generateGOText.py 2>&1; echo $? > ${TMP_RC}; } >> ${LOGFILE}
if [ `cat ${TMP_RC}` -ne 0 ]
then
    echo "GO text input file generation failed" | tee -a ${LOGFILE}
    date >> ${LOGFILE}
    exit 1
fi

#
# Make sure the GO text input file is not empty.
#
echo "" >> ${LOGFILE}
date >> ${LOGFILE}
echo "Verify the GO text input file" | tee -a ${LOGFILE}
if [ ! -s ${GOTEXT_FILE} ]
then
    echo "GO text input file is empty" | tee -a ${LOGFILE}
    date >> ${LOGFILE}
    exit 1
fi

#
# Call the note load for the GO text file.
#
echo "" >> ${LOGFILE}
date >> ${LOGFILE}
echo "Call the note load" | tee -a ${LOGFILE}
{ ${NOTELOAD}/mginoteload.csh ${GOTEXTLOAD}/gotext.config 2>&1; } >> ${LOGFILE}
if [ $? -ne 0 ]
then
    echo "Note load failed" | tee -a ${LOGFILE}
    date >> ${LOGFILE}
    exit 1
fi

echo "" >> ${LOGFILE}
date >> ${LOGFILE}

exit 0
