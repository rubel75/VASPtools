% Octave program for reading PROCAR file from VASP
% It reads magnetic moments (mx, my, mz) for each DFT eigenstate
% and saves data in stout.dat in the following format:
% ik, iband, kx, ky, kz, eig, mx, my, mz
% 
%
% Oleg Rubel (Mar 2018)

%% User-defined parameters
fname1 = "PROCAR" % PDOS file
fname2 = "POSCAR" % structure file
fname3 = "stout.dat" % output file

%% Read file POSCAR
if not( exist(fname2,"file") )
  msg = ["File " fname2 " not found"];
  error(msg)
else
  msg = ["File " fname2 " found"];
  display(msg);
end
fid = fopen (fname2);
for i=1:7 % read heading
  txt = fgetl (fid);
  if i == 6
    txt = strtrim(txt);
    ionlbl = strsplit(txt) % ion lables
  elseif i == 7
    txt = strtrim(txt);
    ionnum = str2num(txt) % number of ions
  end
end
fclose (fid);
if length(ionlbl) ~= length(ionnum) % check the same number of atoms types
  display(ionnum); display(ionnum);
  msg = ["Number of ion lables is not equal to the number of ion types"];
  error(msg);
end

%% Read file PROCAR
if not( exist(fname1,"file") )
  msg = ["File " fname1 " not found"];
  error(msg)
else
  msg = ["File " fname1 " found"];
  display(msg);
end
kptot = 0;
bntot = 0;
iontot = 0;
fid = fopen (fname1);
fid_out = fopen(fname3, 'w');
display("Reading the header started...");
for i=1:2 % read heading
  txt = fgetl (fid)
  if strfind(txt,"# of k-points:")
    kptot = txt(strfind(txt,"# of k-points:")+14:strfind(txt,"# of bands:")-1);
    kptot = str2num (kptot);
    display("Total number of k-points:"); display(kptot);
  end
  if strfind(txt,"# of bands:")
    bntot = txt(strfind(txt,"# of bands:")+11:strfind(txt,"# of ions:")-1);
    bntot = str2num (bntot);
    display("Number of bands per k-point:"); display(bntot);
  end
  if strfind(txt,"# of ions:")
    iontot = txt(strfind(txt,"# of ions:")+11:end);
    iontot = str2num (iontot);
    display("Number of ions:"); display(iontot);
  end
end
if any([kptot, bntot, iontot] == 0) % check data are resonable
  display([kptot, bntot, iontot]);
  msg = "Error reading the heading. One of the values [kptot, bntot, iontot] not found.";
  error(msg);
elseif iontot ~= sum(ionnum)
  msg = "Error: number of ions in PROCAR does not correspond to the number of ions in POSCAR";
  error(msg);
else
  display("... reading the header done");
end
% reding k-point
kpread = 0;
bnread = 0;
bnbins = int32(linspace(1,bntot*kptot,100)); % 100 bins for weighting bar
mgnm = zeros(kptot,bntot,3); % allocate array for storing magnetic moments (mx, my, mz) for each k-point and band
eigene = zeros(kptot,bntot); % allocate array for energy eigenvalues
while (! feof (fid) ) % loop untill the end of file
  txt = fgetl (fid);
  if strfind(txt,"k-point") % get info about kpoints
    kpread = kpread+1;
    kpcoord = txt(strfind(txt,":")+1:strfind(txt,"weight")-1);
    kpcoord = strrep(kpcoord,"-"," -"); % add white space in gring of the negative
    kpcoord = str2num (kpcoord);
    kpwgt =  txt(strfind(txt,"weight =")+8:end);
    kpwgt = str2num (kpwgt);
    display(["K-point " num2str(kpread) " of " num2str(kptot) ": " num2str(kpcoord) ", weight " num2str(kpwgt)]);
    bnread = 0; % reset number of band read
    if length(kpcoord) ~= 3
       msg = "Error: while reading k-point coordinates. The number of elements is not equal to 3";
       error(msg);
    end
  end
  if strfind(txt,"band") % get eigenvalues
    eig = txt(strfind(txt,"energy")+6:strfind(txt,"# occ.")-1);
    eig = str2num(eig);
    bnread = bnread + 1;
  end
  if strfind(txt,"ion") % get magnetic moments
    txt = strsplit(txt); % remove trailing whitespace
    ncol = length(txt); % determine number of columns
    fskipl(fid,2*iontot+1); % skip orbital projected densities
    txt = fgetl(fid);
    if strfind(txt,"tot") % check if the string contains total magnetic moment
      txt = txt(strfind(txt,"tot")+3:end); % remove 'tot' from the string
 %     txt = strrep(txt,"-"," -") % add white space in gring of the negative
      dat = str2num(txt);
      mx = dat(end); % take last record for the total magnetic moment
    else
      display(txt);
      msg = "Error: the total magnetic moment is not find in above line";
      error(msg);
    end
    fskipl(fid,iontot); % skip atom-projected magnetic moment
    txt = fgetl (fid);
    if strfind(txt,"tot") % check if the string contains total magnetic moment
      txt = txt(strfind(txt,"tot")+3:end); % remove 'tot' from the string
%      txt = strrep(txt,"-"," -"); % add white space in gring of the negative
      dat = str2num(txt);
      my = dat(end); % take last record for the total magnetic moment
    else
      display(txt);
      msg = "Error: the total magnetic moment is not find in above line";
      error(msg);
    end
    fskipl(fid,iontot); % skip atom-projected magnetic moment
    txt = fgetl (fid);
    if strfind(txt,"tot") % check if the string contains total magnetic moment
      txt = txt(strfind(txt,"tot")+3:end); % remove 'tot' from the string
%      txt = strrep(txt,"-"," -"); % add white space in gring of the negative
      dat = str2num(txt);
      mz = dat(end); % take last record for the total magnetic moment
    else
      display(txt);
      msg = "Error: the total magnetic moment is not find in above line";
      error(msg);
    end
    mgnm(kpread,bnread,:) = [mx my mz]; % store magnetic moments
    eigene(kpread,bnread) = eig;
    if any(bnbins==(kpread-1)*bntot+bnread) % update waitbar
      printf(" progress %i%%\n", 100*((kpread-1)*bntot+bnread)/(kptot*bntot));
    end
    fprintf(fid_out,"%i %i %f %f %f %f %f %f %f\n", kpread, bnread, kpcoord, eig, mx, my, mz);
    fskipl(fid,1); % skip one more line (IMPORTANT to avoid reading phases!)
    if (kpread==kptot) && (bnread==bntot) % reading last k-point, last band done
      disp("reading PROCAR done");
      break;
    end
  end
endwhile
disp("closing files");
fclose (fid);
fclose (fid_out);
if kpread < kptot % check that all k-points were read
  msg = ["Read " num2str(kpread) " from total of " num2str(kptot) " k-point"];
  error(msg);
elseif kpread > kptot
  msg = ["Read " num2str(kpread) " from total of " num2str(kptot) " k-point"];
  error(msg);
end
