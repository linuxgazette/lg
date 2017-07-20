### [1] Read data set_i into N_i-times-2 matrices
set1 = load("l1.ascii");
set2 = load("l2.ascii");
set3 = load("l3.ascii");

### [2] Reset Gnuplot
graw("reset;");
clearplot;

### [3] Define decorations and plot area
gset title "Comparison of sets L1, L2, and L3";
gset xlabel "Temperature / K";
gset ylabel "Voltage / V";
gset key top left;
gset xrange [0 : 100];
gset yrange [8e-8 : 2e-6];

### [4] Plot data
hold on;
gplot set1 title "Set L1" with points;
gplot set2 title "Set L2" with points;
gplot set3 title "Set L3" with points;
hold off;

### [5] Switch to PostScript output and plot into file
gset terminal push;
gset terminal postscript;
gset output "oct1.eps";
replot;
gset terminal pop;
gset output;

### ___cut___

### [6] Dump Gnuplot window into png-file
pause(1);
system("./xdumpwindow -geometry 600 Gnuplot oct1.png");

exit(0);
