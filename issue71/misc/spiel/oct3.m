### [1] Define function
function z = g(u, v)
    z = exp(u) .* (4.0*u.^2 + 2.0*v.^2 + 4.0*u.*v + 2.0*v + 1.0);
endfunction

### [2] Define weight function for iso-line distances
function y = pow_weight(x, n)
    ## Map interval X onto itself, weight with N-th power.
    d = max(x) - min(x);
    y = d*((x - min(x))/d).^n + min(x);
endfunction

### [3] Sample function g()
x = linspace(-4.5, -0.5, 40);
y = linspace(-1.0, 3.0, 40);
[xx, yy] = meshgrid(x, y);
zz = g(xx, yy);
z_splot = splice_mat(xx, yy, zz);

### [4] Compute iso-line distances
iso_levels = pow_weight(linspace(min(min(zz))*1.01, ...
                                 max(max(zz))*0.99, 12), 3.0);
il_str = sprintf("%f,", iso_levels);
il_str = il_str(1 : length(il_str)-1);    # remove last ","

### [5] Reset Gnuplot
graw("reset;");
clearplot;

### [6] Define decorations and viewing direction
gset data style line;
gset title "Contour Plot of g(u, v)";
gset xlabel "u";
gset ylabel "v";
gset contour base;
gset nosurface;
gset view 0, 0;
eval(sprintf("gset cntrparam levels discrete %s", il_str));
gset parametric;

### [7] Plot
gsplot z_splot;

### [8] Switch to PostScript output and plot into file
gset terminal push;
gset terminal postscript;
gset output "oct3.eps";
replot;
gset terminal pop;
gset output;
gset noparametric;

### ___cut___

### [9] Dump Gnuplot window into png-file
pause(1);
system("./xdumpwindow -geometry 600 Gnuplot oct3.png");

exit(0);
