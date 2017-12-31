#!/bin/bash

################################################################################
#
# The 'outcarf2vesta.sh' code takes OUTCAR file, reades forces acting on each 
# atom and produces a block of *.vesta file with forces set as vectors
#
# USAGE:
#     outcarf2vesta.sh
#
# RECUIRED:
#     OUTCAR
#
# CREATED:
#     forces-block.vesta
#
# The content of forces-block.vesta should be placed in place of the following 
# lines in the VESTA structure file:
#     VECTR
#      0 0 0 0 0
#     VECTT
#      0 0 0 0 0
#
# (c) Oleg Rubel (last modified 29 Dec 2017)
#
################################################################################

echo 'Begin prep a block of *.vesta file with forces set as vectors...'

# Internal variables
# ~~~~~~~~~~~~~~~~~~
fin='OUTCAR' # name of vasp OUTCAR file
fout='forces-block.vesta' # output file
th=0.2 # vector thickness
col="0 255 254 0" # vector colour

# Check prerequisites
# ~~~~~~~~~~~~~~~~~~~
if [ ! -f $fin ]; then # OUTCAR not present?
    echo "ERROR: File $fin not found! Exit" 1>&2
    exit 1
fi

# Read forces
# ~~~~~~~~~~~
echo "Read number of atoms from $fin file"
natoms=`grep -e 'NIONS =' $fin | cut -d '=' -f 3`
echo "Number of atoms: $natoms"
echo "Read forces from $fin file"
#FOR=`grep -e 'TOTAL-FORCE' -A 1033 $fin | tail -n $natoms`
IFS=$'\r\n' GLOBIGNORE='*' command eval  'FOR=($(grep -e 'TOTAL-FORCE' -A $(($natoms + 1)) $fin | tail -n $natoms))'
echo "Forces are..."
i=0 # ATTENTION: the first array elements is 0
fori=`echo ${FOR[$i]} | cut -d ' ' -f 4-6`
echo "$fori on the first atom"
i=$(($natoms - 1)) # last one is (n-1)
fori=`echo ${FOR[$i]} | cut -d ' ' -f 4-6`
echo "$fori on the last atom" # last one is (n-1)

# Write forces-block.vesta file
echo "Begin writing to $fout"
echo "VECTR" > $fout # start force values [u,v,w,Q] block; Q = 0 for vector starting at atoms
for ((i=0;i < $natoms;i++))
{
    fori=`echo ${FOR[$i]} | cut -d ' ' -f 4-6`
    echo "   $(($i+1)) $fori 0" >> $fout
    echo "     $(($i+1))  0    0    0    0" >> $fout
    echo " 0 0 0 0 0" >> $fout
}
echo " 0 0 0 0 0" >> $fout # ending VECTR block
echo "VECTT" >> $fout # start thickness and color block
for ((i=0;i < $natoms;i++))
{
    echo "   $(($i+1)) $th $col" >> $fout
}
echo " 0 0 0 0 0" >> $fout # ending VECTT block
echo 'The end'
