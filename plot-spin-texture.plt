set terminal postscript eps color enhanced font "Helvetica,16" size 9cm,6.0cm
set output "spin-texture-mx-1.eps"
set encoding utf8 # nice minus
set minussign # nice minus

set xlabel "Wave vector"
set ylabel "Energy (eV)"
set xtics ("{/Symbol \254} L" 121, "{/Symbol G}" 141, "X {/Symbol \256}" 161)
set palette defined (-0.5 "blue", 0 "grey", 0.5 "red")
set cbrange [-0.8:0.8]
plot "spin-texture-band-6.dat" using ($1):($6):($7) with points palette pt 7 title "", \
     "spin-texture-band-8.dat" using ($1):($6):($7) with points palette pt 7 title "", \
     "spin-texture-band-10.dat" using ($1):($6):($7) with points palette pt 7 title ""

set output "spin-texture-mx-2.eps"
plot "spin-texture-band-5.dat" using ($1):($6):($7) with points palette pt 7 title "", \
     "spin-texture-band-7.dat" using ($1):($6):($7) with points palette pt 7 title "", \
     "spin-texture-band-9.dat" using ($1):($6):($7) with points palette pt 7 title ""

set output "spin-texture-my-1.eps"
plot "spin-texture-band-6.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-8.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-10.dat" using ($1):($6):($8) with points palette pt 7 title ""

set output "spin-texture-my-2.eps"
plot "spin-texture-band-5.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-7.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-9.dat" using ($1):($6):($8) with points palette pt 7 title ""

set output "spin-texture-mz-1.eps"
plot "spin-texture-band-6.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-8.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-10.dat" using ($1):($6):($8) with points palette pt 7 title ""

set output "spin-texture-mz-2.eps"
plot "spin-texture-band-5.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-7.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-9.dat" using ($1):($6):($8) with points palette pt 7 title ""

set output "spin-texture-mz-mix.eps"
plot "spin-texture-band-5.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-7.dat" using ($1):($6):($8) with points palette pt 7 title "", \
     "spin-texture-band-10.dat" using ($1):($6):($8) with points palette pt 7 title ""
