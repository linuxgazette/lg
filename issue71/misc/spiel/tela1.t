// [1] Read data set_i into N_i-times-2 matrices
set1 = import1("l1.ascii");
set2 = import1("l2.ascii");
set3 = import1("l3.ascii");

// [2] Define plotting function
function do_plot(d1, d2, d3)
{
     hold(on);    // postpone actual plotting until hold(off)

     // render set 1
     plot(d1[:, 1], d1[:, 2],
          "linestyle",  0,
          "markertype", 2,
          "linelabel",  "Set L1",
          // Define decorations
          "toplabel",   "Comparison of sets",
          "subtitle",   "L1, L2, and L3",
          "xlabel",     "Temperature / K",
          "ylabel",     "Voltage / V",
          // Define plot area
          "xmin",       0,
          "xmax",       100,
          "ymin",       8e-8,
          "ymax",       2e-6);
     // render set 2
     plot(d2[:, 1], d2[:, 2],
          "linestyle",  0,
          "markertype", 3,
          "linelabel",  "Set L2");
     // render set 3
     plot(d3[:, 1], d3[:, 2],
          "linestyle",  0,
          "markertype", 4,
          "linelabel",  "Set L3");

     hold(off);    // plot!
};

// [3] Plot to X11 window
do_plot(set1, set2, set3);

// [4] Plot into a postscript file
plotopt("-o tela1.eps -printcmd 'cat' -noxplot -print");
do_plot(set1, set2, set3);

// ___cut___

// [5] Dump PlotMTV window into png-file
pause(1);    // wait for PlotMTV window to show up
system(#("./xdumpwindow 'Plotmtv Program' tela1.png && ",
         "killall plotmtv"));

exit(0);
