function read_EIGENVAL

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% read_EIGENVAL is a MatLab script that is designed to preprocess VASP
% EIGENVAL file and prepare data for plotting a band structure.
%
% USAGE: siply run read_EIGENVAL in MatLab enviroment
%
% RECUIRED:
%     + EIGENVAL file
%     + Manualy take reciprocal lattice vectors from OUTCAR file and
%       place them as a G variable below.
%
% OUTPUT:
%     + vasp_bs.csv -- a comma separated file with data written in the
%     following format: dk, kptX, kptY, kptZ, eig1, eig2, ...
%
% (c) Oleg Rubel (last modified 18 Feb 2020)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clear all;

% Take reciprocal lattice vectors from OUTCAR file and place them here
G = [0.159201275  0.000000000 -0.000721245;
     0.000000000  0.290271381  0.000000000;
    -0.000224720  0.000000000  0.050018295];

fid = fopen('EIGENVAL');

i = 0;
while ~feof(fid) % end of file
    line = fgetl(fid);
    i = i+1;
    if i == 6
        dum = str2num(line);
        numk = dum(2);
        nband = dum(3);
    end
    if i == 7
        break;
    end
end
kpt = zeros(numk,3);
eig = zeros(numk,nband);
for j = 1:numk
    line = fgetl(fid);
    dum = str2num(line);
    kpt(j,:) = dum(1:3);
    for k = 1:nband
        line = fgetl(fid);
        dum = str2num(line);
        eig(j,k) = dum(2);
    end
    line = fgetl(fid); % empty line at the end of k-point
end
fclose(fid); % end reading EIGENVAL

% compute length along the k-path
K = zeros(numk,1);
KPATH = coordTransform(kpt,G);
for j = 2 : numk
    B = KPATH(j-1,:) - KPATH(j,:);
    dk = sqrt(dot(B,B));
    K(j) = K(j-1) + dk;
end

% write output file in CSV format
M = [K kpt eig]; % dk, kptX, kptY, kptZ, eig1, eig2, ...
dlmwrite('vasp_bs.csv', M, 'delimiter', ',', 'precision', 9);

% summary
disp('number of k-points')
disp(numk)
disp('number of bands')
disp(nband)
disp('output file = vasp_bs.csv')
disp('format: dk, kptX, kptY, kptZ, eig1, eig2, ...')

% -------------------------------------------------------------------------
function W = coordTransform(V,G)
% transform vector V(:,3) in G(3,3) coord. system -> W(:,3) in Cartesian coordinates
% G vector elements are in columns!
W = zeros(size(V));
for i = 1:size(V,1)
    W(i,:) = G(1,:)*V(i,1) + G(2,:)*V(i,2) + G(3,:)*V(i,3);
end;
