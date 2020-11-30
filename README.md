# VASPtools
Collection of miscellaneous scripts for VASP. Please read the header of each script for details regarding execution and output.

## outcarf2vesta.sh
This bash script takes OUTCAR file, reades forces acting on each atom and produces a block of *.vesta file with forces set as vectors.

## read_EIGENVAL.m
This is a MatLab script that is designed to preprocess VASP EIGENVAL file and prepare data for plotting a band structure.

## prPROCAR.m
This is an Octave script that computes an inverse participation ratio (IPR) for each DFT eigenstate based on PROCAR and POSCAR files. It is useful to detect localized states, which have a higher IPR than extended states.

## PROCAR_PR2DOS.m
This is an Octave script that is designed to assist with plotting the participation ratio data obtained with prPROCAR.m

## Contact
Please send your comments/suggestions/requests to

Oleg Rubel  
Department of Materials Science and Engineering  
McMaster University  
JHE 359, 1280 Main Street West, Hamilton, Ontario L8S 4L8, Canada  
Email: rubelo@mcmaster.ca  
Web: http://olegrubel.mcmaster.ca
