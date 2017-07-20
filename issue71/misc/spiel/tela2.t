function v = linspace(a, b; n)
{
    if (isdefined(n)) nn = n else nn = 100;
    v = a + (0 : nn - 1) * (b - a) / (nn - 1) 
};

// [1] Define function
function z = f(u, v)
{
    // truncated Rosenbrock function
    z = 100.0*(v - u^2)^2 + (1.0 - u)^2;
    z[find(z > 100.0)] = 100.0;
};

// [2] Sample function f()
x = linspace(-3.0, 3.0, 40);
y = linspace(-2.0, 4.0, 40);
[xx, yy] = grid(x, y);
zz = f(xx, yy);

// [3] Define plot function
function do_plot(x, y, zz)
{
    mesh(zz,
         "xgrid",       x,
         "ygrid",       y,
         "toplabel",    "Rosenbrock Function",
         "xlabel",      "u",
         "ylabel",      "v",
         "hiddenline",  "true",
         "eyepos.z",    2.0)
};

// [4] Render plot into X11 window
do_plot(x, y, zz);

// [5] Plot into a postscript file
plotopt("-o tela2.eps -printcmd 'cat' -noxplot -print");
do_plot(x, y, zz);
system("gzip --best --force tela2.eps");

// ___cut___

// [6] Dump PlotMTV window into png-file
pause(1);    // wait for PlotMTV window to show up
system(#("./xdumpwindow 'Plotmtv Program' tela2.png && ",
         "killall plotmtv"));

exit(0);
