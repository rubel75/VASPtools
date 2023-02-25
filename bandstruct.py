#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Plot VASP band structure with orbital character.

@author: Oleg Rubel
"""

import numpy as np
import os
import sys

def user_input():
    """Editable section where users define their input"""
    erange = [-3, 3] # energy range (eV) relative to the Fermi energy
    krange = [14,None] # range of k points
    atoms = [49,50,51,52,53,54,55,56] # list of atoms for orbital contrubution
    # s  py  pz  px  dxy  dyz  dz2  dxz  dx2-y2  fy3x2  fxyz  fyz2  fz3  fxz2  fzx2  fx3  tot
    # 1  2   3   4    5    6    7    8      9      10    11    12   13    14    15   16   17
    orb = [8] # list of orbitals to include in weights
    xticks={1:"G'", 40:"X'", 79:"G''", 106:"M'", 133:"G'"} # y axis ticks
    readprocar = True # read PROCAR file
    showplots = False

    return erange, krange, atoms, orb, xticks, readprocar, showplots
    # end user_input

def read_EIGENVAL():
    """Read eigenvalues and k points from EIGENVAL file"""
    WorkingDir = os.getcwd()
    print (f'Working directory = {WorkingDir}')
    os.chdir(WorkingDir)
    i = 0 # line counter
    ik = 0 # k point counter
    ie = 0 # eigenvalue counter
    nband = float("inf")
    with open('EIGENVAL') as file:
        print ('Reading EIGENVAL file ...')
        for line in file:
            i += 1
            if i == 6: # 6th line (heading)
                # get number of k points and bands
                lsplit = line.rstrip().split()
                if not(len(lsplit) == 3):
                    raise ValueError(f'lsplit list should have length = 3, while you have {len(lsplit)}. The line is: {line.rstrip()}')
                [dum, numk, nband] = [int(num) for num in lsplit]
                print (f'Number of k points = {numk}')
                print (f'Number of bands = {nband}')
                # allocate arrays
                kpt = np.zeros((numk,3))
                eig = np.zeros((numk,nband))
            elif np.mod(i,nband+2) == 8: # k point line
                ik += 1
                lsplit = line.rstrip().split()
                # the line should contain 'k1 k2 k3 weight'
                if not(len(lsplit) == 4):
                    raise ValueError(f'lsplit list should have length = 4, while you have {len(lsplit)}. The line is: {line.rstrip()}')
                kpti = [float(num) for num in lsplit]
                kpt[ik-1,:] = kpti[0:3] # store k point coordinates (skip weight)
            elif (np.mod(i,nband+2) > 8 and np.mod(i,nband+2) < 8+nband+1) or \
                    (i > 8 and np.mod(i,nband+2) < 7): # eigenvalue line
                ie += 1
                lsplit = line.rstrip().split()
                if not(len(lsplit) == 3):
                    raise ValueError(f'lsplit list should have length = 3, while you have {len(lsplit)}. The line is: {line.rstrip()}')
                iband = np.mod(ie,nband)
                eig[ik-1,iband-1] = float(lsplit[1])

    print (f'Processed {ik} of {numk} k points and {ie} of {numk*nband} eigenvalues')
    if not(ik == numk):
        raise ValueError(f'The number of k points processed {ik} is not equal to {numk} read from heading of EIGENVAL file')
    if not(ie == numk*nband):
        raise ValueError(f'The number of bands processed {ie} is not equal to numk*nband={numk}*{nband}={numk*nband} read from heading of EIGENVAL file')

    return numk, nband, eig, kpt
    # end read_EIGENVAL

def read_PROCAR(atoms, orb):
    """Read PROCAR and compute orbital contribution of individual atoms for 
    fat bands plot"""
    WorkingDir = os.getcwd()
    print (f'Working directory = {WorkingDir}')
    os.chdir(WorkingDir)
    i = 0 # line counter
    ik = 0 # k point counter
    ie = 0 # eigenvalue counter
    iion = 0 # ion counter
    readorbw = False # flag to enable reading of orbital projections
    nband = float("inf")
    with open('PROCAR') as file:
        print ('Reading PROCAR file ...')
        for line in file:
            i += 1
            if i == 2: # 2nd line (heading)
                # get number of k points, bands, ions
                lsplit = line.rstrip().split()
                if not(len(lsplit) == 12):
                    raise ValueError(f'lsplit list should have length = 12, while you have {len(lsplit)}. The line is: {line.rstrip()}')
                numk = int(lsplit[3])
                nband = int(lsplit[7])
                nion = int(lsplit[11])
                print (f'Number of k points = {numk}')
                print (f'Number of bands = {nband}')
                print (f'Number of ions = {nion}')
                if max(atoms) > nion:
                    raise ValueError(f'One of atoms in the list atoms={atoms} exceeds the total number of atoms {nion}')
                # allocate array
                w = np.zeros((numk,nband))
            elif 'k-point' in line: # k point line
                ik += 1
                if ik > 1 and not(ie == nband): # check that all bands are read
                    raise ValueError(f'The number of bands processed {ie} is not equal to {nband} read from heading of PROCAR file')
                elif ik > 1:
                    print(f'    processed {ie} bands of {nband}')
                ie = 0 # reset eigenvalue counter
                print(f'  reading k point {ik} of {numk}')
            elif 'band' in line: # band line
                ie += 1
            elif 'ion' in line: # weights by ion
                readorbw = True
                iion = 0 # reset ion counter
            elif readorbw and iion <= nion:
                iion += 1
                lsplit = line.rstrip().split()
                proj = lsplit[1:]
                if iion == 1: # first ion
                    # get ion and orbital resolved projections
                    nproj = len(proj)
                    wi = np.zeros((nion,nproj)) # allocate
                wi[iion-1,:] = [float(num) for num in proj]
                if iion == nion: # last ion
                    for jion in atoms:
                        for jorb in orb:
                            # add all relevant projections
                            w[ik-1,ie-1] += wi[jion-1,jorb-1]
                    readorbw = False

        if not(ik == numk):
            raise ValueError(f'The number of k points processed {ik} is not equal to {numk} read from heading of PROCAR file')

    return w
    # end read_PROCAR

def read_OUTCAR():
    """Read OUTCAR file and determine reciprocal lattice vectors G (1/Ang) 
    and the Fermi energy (eV)"""
    WorkingDir = os.getcwd()
    print (f'Working directory = {WorkingDir}')
    os.chdir(WorkingDir)
    i = 0 # line counter
    readG = False # flag to enable reading of G vector
    with open('OUTCAR') as file:
        print ('Reading OUTCAR file ...')
        for line in file:
            i += 1
            if ('direct lattice vectors' in line) and \
                    ('reciprocal lattice vectors' in line): # G vector lines
                readG = True
                iG = 0 # G vector lines counter
                G = np.zeros((3,3)) # allocate
            elif readG: # Read G vector
                iG += 1
                lsplit = line.rstrip().split()
                if not(len(lsplit) == 6):
                    raise ValueError(f'The line suppose to split into 6 values, but it does not. Here is the line: {line}')
                # Skip first 3 values. Those are real space lattice parameters
                # Units of G are (1/Ang)
                G[iG-1,:] = [float(num) for num in lsplit[3:]]
                if iG == 3:
                    readG = False # stop reading G matrix
            elif 'E-fermi :' in line: # Fermi energy (eV)
                lsplit = line.rstrip().split()
                efermi = float(lsplit[2])

        print(f'Fermi energy from OUTCAR: {efermi} (eV)')
        print(f'Reciprocal lattice vectors from OUTCAR are (1/Ang):')
        for i in range(3):
            print(f'  G({i+1})=[{G[i,0]}, {G[i,1]}, {G[i,2]}]')

    return G, efermi
    # end read_OUTCAR

def coordTransform(V,G):
    """Transform vector V(:,3) in G(3,3) coord. system -> W(:,3) in Cartesian 
    coordinates"""
    W = np.zeros(np.shape(V))
    for i in range(np.shape(V)[0]):
        W[i,:] = G[0,:]*V[i,0] + G[1,:]*V[i,1] + G[2,:]*V[i,2]

    return W
    # end coordTransform

# MAIN
if __name__=="__main__":
    # Set user parameters
    erange, krange, atoms, orb, xticks, readprocar, showplots = user_input()
    # Check input
    if not(len(erange) == 2):
        raise ValueError(f'erange list should have length = 2, while you have {len(erange)}')
    
    # Print input
    print("User input:")
    print(f'Energy range from {erange[0]} to {erange[1]} (eV) relative to the Fermi energy')
    
    # read OUTCAR
    G, efermi = read_OUTCAR()
    # read eigenvalues and k points from EIGENVAL
    numk, nband, eig, kpt = read_EIGENVAL()
    eig = eig - efermi # subtract Fermi energy
    # crop k points
    if not(krange[0] == None) and krange[1] == None:
        ik1 = krange[0] -1
        kpt = kpt[ik1:]
        eig = eig[ik1:,:]
        numk = numk - ik1
    else:
        raise ValueError(f'This choice of krange={krange} is not implemented')
    
    # convert k point fractional coordinates into Cartesian
    KPATH = coordTransform(kpt,G)
    # compute length along the k-path
    K = np.zeros((numk))
    for i in range(numk-1):
        B = KPATH[i+1,:] - KPATH[i,:]
        dk = np.sqrt(np.dot(B,B))
        K[i+1] = K[i] + dk
    
    # plot simple band structure
    import matplotlib.pyplot as plt
    if max(xticks) > numk:
        raise ValueError(f'The number of k points is {numk} but max(xticks)={max(xticks)}')

    f1 = plt.figure()
    for ie in range(nband):
        if max(eig[:,ie]) > erange[0] and min(eig[:,ie]) < erange[1]:
            plt.plot(K, eig[:,ie], c='black')

    ax = plt.gca()
    ax.set_xlim([min(K), max(K)])
    xticksK = [K[ik-1] for ik in xticks.keys()]
    xticksLabel = list(xticks.values())
    plt.xticks(ticks=xticksK, labels=xticksLabel)
    plt.grid(visible=True, which='major', axis='x')
    ax.set_ylim([erange[0], erange[1]])
    plt.axhline(y=0, color='black', linestyle='--') # line at E = 0
    plt.xlabel("Wave vector")
    plt.ylabel("Energy (eV)")
    if showplots:
        plt.show()
    # save figure
    f1.savefig("band_struct.pdf", bbox_inches='tight')
    print('Figure stored in band_struct.pdf file')

    if not(readprocar):
        sys.exit('Finished without reading PROCAR')

    # plot FAT bands
    f2 = plt.figure()
    # read PROCAR
    weight = read_PROCAR(atoms, orb)
    # crop k points
    if not(krange[0] == None) and krange[1] == None:
        weight = weight[ik1:,:]
    else:
        raise ValueError(f'This choice of krange={krange} is not implemented')

    # plot bandstructure 2
    for ie in range(nband):
        if max(eig[:,ie]) > erange[0] and min(eig[:,ie]) < erange[1]:
            plt.scatter(K,eig[:,ie], s=20*weight[:,ie], c='black', alpha=0.5)

    ax = plt.gca()
    ax.set_xlim([min(K), max(K)])
    xticksK = [K[ik-1] for ik in xticks.keys()]
    xticksLabel = list(xticks.values())
    plt.xticks(ticks=xticksK, labels=xticksLabel)
    plt.grid(visible=True, which='major', axis='x')
    ax.set_ylim([erange[0], erange[1]])
    plt.axhline(y=0, color='black', linestyle='--') # line at E = 0
    plt.xlabel("Wave vector")
    plt.ylabel("Energy (eV)")
    if showplots:
        plt.show()
    # save figure
    f2.savefig("band_struct_fat.pdf", bbox_inches='tight')
    print('Figure stored in band_struct_fat.pdf file')