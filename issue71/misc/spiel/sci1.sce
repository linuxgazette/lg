// [1] Read data set_i into N_i-times-2 matrices
set1 = read("l1.ascii", -1, 2);
set2 = read("l2.ascii", -1, 2);
set3 = read("l3.ascii", -1, 2);

// [2] Clear plot window's contents
xbasc();

// [3] Plot data; 1st plot command defines plot area
plot2d(set1(:, 1), set1(:, 2), -1, "011", ..
       rect = [0, 8e-8, 100, 2e-6]);
plot2d(set2(:, 1), set2(:, 2), -2, "000");
plot2d(set3(:, 1), set3(:, 2), -3, "000");

// [4] Define decorations
xtitle(["Comparison of sets", "L1, L2, and L3"], ..
       "Temperature / K", "Voltage / V");
legends(["Set L1   ", "Set L2   ", "Set L3   "], [-1, -2, -3], 2);

// [5] Save plot window's contents to file; convert file to PostScript
xbasimp(0, "sci1.xps");
unix("scilab -save_p sci1.xps.0 Postscript");

// ___cut___

// [6] Dump Scilab graphic window 0 into png-file
unix("./xdumpwindow -geometry 600 ScilabGraphic0 sci1.png");

exit;

