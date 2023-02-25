#!/bin/bash

flist=`ls POSCAR-*`
echo file list = $flist

for ifile in $flist; do
  echo ifile = $ifile
  inum=`echo $ifile | sed 's/.*-//'`
  echo inum = $inum
  idir=disp-$inum
  echo idir = $idir
  # create directory disp-###
  if [ ! -d "$idir" ]; then
    echo Make directory $idir
    mkdir $idir
  else
    echo Directory $idir already exists
  fi
  # create links
  cd ${idir}
  ln -s ../POSCAR-$inum POSCAR
  ln -s ../POTCAR POTCAR
  ln -s ../INCAR INCAR
  ln -s ../KPOINTS KPOINTS
  ln -s ../sub_vasp_std-intelmpi.sh sub_vasp_std-intelmpi.sh
  sbatch sub_vasp_std-intelmpi.sh
  cd ..
done
