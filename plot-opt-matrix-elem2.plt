set terminal postscript eps color enhanced font "Helvetica,16" size 9cm,6.0cm
set output "matrix-elem2.eps"
set encoding utf8 # nice minus
set minussign # nice minus

set xlabel "Wave vector"
set ylabel "|M_{c,v}|^2 (arb. units)"
set xrange [1:40]
set xtics ("{/Symbol \254} L" 1, "{/Symbol G}" 20, "X {/Symbol \256}" 40)
plot "data5-9.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "lh-c",\
     "data6-9.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "lh-c",\
     "data7-9.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "hh-c",\
     "data8-9.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "hh-c",\
     "data5-10.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "lh-c",\
     "data6-10.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "lh-c",\
     "data7-10.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "hh-c",\
     "data8-10.dat" using ($7**2+$8**2+$9**2+$10**2+$11**2+$12**2) with lp lw 2 title "hh-c"
