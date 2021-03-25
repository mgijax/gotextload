#
#  generateGOText.py
###########################################################################
#
#  Purpose:
#
#      This script will parse the Alliance input file to extract the MGI ID
#      and gene description for each gene. This information is used to
#      create the GO text input file for the note load.
#
#  Usage:
#
#      ${PYTHON} generateGOText.py
#
#  Env Vars:
#
#      INPUT_FILE
#      GOTEXT_FILE
#
#  Inputs:
#
#      - Input file from the Alliance (${INPUT_FILE})
#
#  Outputs:
#
#      - GO text file for the note load (${GOTEXT_FILE})
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  An exception occurred
#
#  Assumes:  Nothing
#
#  Notes:  None
#
###########################################################################

import sys
import os
import re

TAB = '\t'
NL = '\n'

TEXT_HEADER = 'Automated description from the Alliance of Genome Resources (Release 3.2)'
NO_DESC = 'No description available'

inFile = os.environ['INPUT_FILE']
outFile = os.environ['GOTEXT_FILE']

#
# Open input/output files.
#
try:
    fpIn = open(inFile, 'r')
except:
    print('Cannot open input file: ' + inFile)
    sys.exit(1)

try:
    fpOut = open(outFile, 'w')
except:
    print('Cannot open output file: ' + outFile)
    sys.exit(1)

#
# Parse the Alliance input file.
#
line = fpIn.readline()
while line:

    # If the line begins with "MGI:", it must be the MGI ID for the gene.
    # Grab the MGI ID from the first tab-delimited field.
    if line[:4] == 'MGI:':
        tokens = re.split(TAB, line[:-1])
        mgiID = tokens[0]

        # If an MGI ID is found, the next line should be the gene description.
        desc = fpIn.readline()

        # If there is a valid gene description, write the MGI ID and gene
        # description (with HTML markup) to the GO Text file.
        if desc[:-1] != NO_DESC:

            fpOut.write(mgiID + TAB + '<hr><B>' + TEXT_HEADER + '</B><BR><BR>' + desc[:-1] + '<hr>' + NL)

    line = fpIn.readline()

#
# Close input/output files.
#
fpIn.close()
fpOut.close()

sys.exit(0)
