function v = linspace(a, b; n)
{
    if (isdefined(n)) nn = n else nn = 100;
    v = a + (0 : nn - 1) * (b - a) / (nn - 1) 
};

// [1] Define function
function z = g(u, v)
{
    z = exp(u) * (4.0*u^2 + 2.0*v^2 + 4.0*u*v + 2.0*v + 1.0)
};

// [2] Define weight function for iso-line distances
function y = pow_weight(x, n)
{
    // Map interval X onto itself, weight with N-th power.
    d = max(x) - min(x);
    y = d*((x - min(x))/d)^n + min(x)
};

// [3] Sample function f()
x = linspace(-4.5, -0.5, 40);
y = linspace(-1.0, 3.0, 40);
[xx, yy] = grid(x, y);
zz = g(xx, yy);

// [4] Compute iso-line distances
iso_levels = pow_weight(linspace(min(zz)*1.01, max(zz)*0.99, 12), 3.0);
il_str = sformat("``", iso_levels);
il_str = il_str[2 : length(il_str)];

// [5] Define plot function
function do_plot(x, y, zz, iso_levels_str)
{
    contour(zz,
            "xgrid",    x,
            "ygrid",    y,
            "toplabel", "Contour Plot of g(u, v)",
            "xlabel",   "u",
            "ylabel",   "v",
            "contours", iso_levels_str)
};

// [6] Render plot into X11 window
do_plot(x, y, zz, il_str);

// [7] Plot into a postscript file
plotopt("-o tela3.eps -printcmd 'cat' -noxplot -print");
do_plot(x, y, zz, il_str);

// ___cut___

// [8] Dump PlotMTV window into png-file
pause(1);    // wait for PlotMTV window to show up
system(#("./xdumpwindow 'Plotmtv Program' tela3.png && ",
         "killall plotmtv"));

exit(0);
};
