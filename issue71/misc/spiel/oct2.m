### [1] Define function
function z = f(u, v)
    ## truncated Rosenbrock function
    z = 100.0*(v - u.^2).^2 + (1.0 - u).^2;
    zv = z(:);
    zv(find(zv > 100.0)) = 100.0;
    z = reshape(zv, size(z));
endfunction

### [2] Sample function f()
x = linspace(-3, 3, 40);
y = linspace(-2, 4, 40);
[xx, yy] = meshgrid(x, y);
z_splot = splice_mat(xx, yy, f(xx, yy));

### [3] Reset Gnuplot
graw("reset;");
clearplot;

### [4] Define decorations and viewing direction
gset data style line;
gset title "Rosenbrock Function";
gset xlabel "u";
gset ylabel "v";
gset view 30, 160;
gset hidden;
gset nokey
gset parametric;

### [5] Plot
gsplot z_splot;

### [6] Switch to PostScript output and plot into file
gset terminal push;
gset terminal postscript;
gset output "oct2.eps";
replot;
gset terminal pop;
gset output;
gset noparametric;

system("gzip --best --force oct2.eps");

### ___cut___

### [7] Dump Gnuplot window into png-file
pause(1);
system("./xdumpwindow -geometry 600 -quality 100 Gnuplot oct2.png");

exit(0);
