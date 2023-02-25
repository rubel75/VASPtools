set terminal postscript eps color enhanced font "Helvetica,16" size 9cm,6.0cm
set output "bands.eps"
set encoding utf8 # nice minus
set minussign # nice minus

set xlabel "Wave vector"
set ylabel "Energy (eV)"
set xrange [1:57]
set xtics ("{/Symbol G} {/Symbol \254} R" 1, "R" 29, "R {/Symbol \256} {/Symbol G}+" 57)
set key right center # legend position
plot "data40-42.dat" using ($5) with lp lw 2 title "c2",\
     "data39-41.dat" using ($5) with lp lw 2 title "c1",\
     "data40-42.dat" using ($2) with lp lw 2 title "v1",\
     "data39-42.dat" using ($2) with lp lw 2 title "v2"
