% Octave program for reading PROCAR file from VASP
% It plots the DOS and computes the localization (participation ratio)
%
% Oleg Rubel (Jan 2017)

%% User-defined parameters
fname1 = "PROCAR" % PDOS file
fname2 = "POSCAR" % structure file

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
fid_out = fopen([fname1 "_PR"], 'w');
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
if any([kptot, bntot, iontot] == 0)
  display([kptot, bntot, iontot]);
  msg = "Error reading the heading. One of the values [kptot, bntot, iontot] not found.";
  error(msg);
elseif iontot ~= sum(ionnum)
  msg = "Error: number of ions in PROCAR does not correspond to the number of ions in POSCAR"
  error(msg);
else
  display("... reading the header done");
end
% reding k-point
kpread = 0;
bnread = 0;
bnbins = int32(linspace(1,bntot,100)); % 100 bins for weighting bar
while (! feof (fid) ) % loop untill the end of file
  txt = fgetl (fid);
  if strfind(txt,"k-point") % get info about kpoints
    kpread = kpread+1;
    kpcoord = txt(strfind(txt,":")+1:strfind(txt,"weight")-1);
    kpcoord = str2num (kpcoord);
    kpwgt =  txt(strfind(txt,"weight =")+8:end);
    kpwgt = str2num (kpwgt);
    display(["K-point " num2str(kpread) " of " num2str(kptot) ": " num2str(kpcoord) ", weight " num2str(kpwgt)]);
    bnread = 0; % reset number of band read
  end
  if strfind(txt,"band") % get eigenvalues
    eig = txt(strfind(txt,"energy")+6:strfind(txt,"# occ.")-1);
    eig = str2num (eig);
  end
  if strfind(txt,"ion") % get densities per atoms
    txt = strsplit(txt); % remove trailing whitespace
    ncol = length(txt); % number of columns
    rho = zeros(iontot,ncol);
    for j = 1:iontot
      txt = fgetl (fid);
      txt = str2num(txt);
      rho(j,:) = txt;
    end
    sumrhoj = zeros(1,length(ionnum));
    sum2rhoj = sumrhoj; sumrhoj2 = sumrhoj; prj = sumrhoj;
    for j = 1:length(ionnum) % loop over the same type of ions
      if j == 1
        rhoj = rho(1:ionnum(j),end);
      else
        rhoj = rho(sum(ionnum(1:j-1))+1:sum(ionnum(1:j)),end);
      end
      sumrhoj(j) = sum(rhoj);
      sum2rhoj(j) = (sum(rhoj))^2;
      sumrhoj2(j) = (sum(rhoj.^2));
      if sum2rhoj(j) ~= 0 % else prj = 0
        prj(j) = sumrhoj2(j)/sum2rhoj(j);
      end
    end
    pr = sum(prj.*sumrhoj)/sum(sumrhoj);
    fprintf(fid_out,"%f %f %f\n", eig, kpwgt, pr);
    bnread = bnread + 1;
    if any(bnbins==bnread) % update waitbar
      printf(" progress %d%%\n", 100*bnread/bntot);
    end
  end
endwhile
fclose (fid);
fclose (fid_out);
if kpread < kptot
  msg = ["Read " num2str(kpread) " from total of " num2str(kptot) " k-point"];
  error(msg);
elseif kpread > kptot
  msg = ["Read " num2str(kpread) " from total of " num2str(kptot) " k-point"];
  error(msg);
end
