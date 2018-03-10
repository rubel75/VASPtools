% This code reads the othut PROCAR_PR and produces the DOS and PR plots
% PR = participation ratio
%
% Oleg Rubel (Jan 2017)

%% User-defined parameters
fname = "PROCAR_PR" % PDOS file
Ef = 6.8735; %6.8945;        % Fermi energy (eV)
Emin = -2;           % Lower energy (eV) bound of the DOS plot
Emax = 2;          % Upper energy (eV) bound of the DOS plot
dE = 0.026;         % Energy bin size (eV)
vol = 14855.15/1000;     % Cell volume (nm^3)


%% Read file POSCAR
if not( exist(fname,"file") )
  msg = ["File " fname " not found"];
  error(msg)
else
  msg = ["File " fname " found"];
  display(msg);
end
fid = fopen (fname);
i = 0;
j = 0;
while (! feof (fid) ) % loop untill the end of file
  txt = fgetl (fid);
  dat = str2num (txt);
  if length(dat) ~= 3 % dummy line check
    txt
    msg = ["It is expected that each line is 3 numners"];
    error(msg);
  end
  i = i + 1;
  if and(dat(1)>Ef+Emin,dat(1)<Ef+Emax) % store only data with Emin < E < Emax
    j = j + 1;
    data(j,:) = dat;
  end
endwhile
fclose (fid);
msg = ["Reading of the file " fname " finished."];
display(msg);
msg = [num2str(i) " lines read and " num2str(j) " lines are selected for processing"];
display(msg);

%% Build weighted histograms
ene = data(:,1);
w = data(:,2);
pr = data(:,3);
ebins = Ef+Emin:dE:Ef+Emax;
nbins = length(ebins)-1;
dos = [];
ebin = [];
prawrg = [];
for k = 1:nbins
  inbin = find (and(ene>=ebins (k), ene<ebins (k+1)));
  ebin = [ebin; (ebins(k) + ebins(k+1))/2 - Ef];
  sumw = sum(w(inbin));
  if sumw > 0
     prawrg = [prawrg; sum(pr(inbin).*w(inbin))/sumw]; % average participation ratio in the bin
  else
     prawrg = [prawrg; 0];
  end
  dos = [dos;sumw];
endfor
dos = dos/(dE*vol);

%% Store results in file
out = [ebin dos prawrg];
fmane_out = [fname "_hist"];
fid_out = fopen(fmane_out, 'w');
fprintf(fid_out,"%f %f %f\n", out');
fclose (fid_out);
msg = ["Results are stored in the file " fmane_out " using this format"];
display(msg);
msg = ["E - Ef (eV)  |  DOS per spin (eV^-1 nm^-3)  |  Participation ratio"];
display(msg);
msg = ["Thanks for using the utility :)"];
display(msg);
