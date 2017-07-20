// [1] Define function
function z = f(u, v)
    // truncated Rosenbrock function
    z = 100.0*(v - u.^2).^2 + (1.0 - u).^2
    z(find(z > 100)) = 100;
endfunction

// [2] Define sampling grid for f()
x = linspace(-3, 3, 40);
y = linspace(-2, 4, 40);

// [3] Clear plot window's contents
xbasc();

// [4] Plot
fplot3d(x, y, f, 65, 1.5);

// [5] Define decoration
xtitle("Rosenbrock Function", "u", "v");

// [6] Save plot window's contents to file; convert file to PostScript
xbasimp(0, "sci2.xps");
unix("scilab -save_p sci2.xps.0 Postscript; " ..
     + "gzip  --best --force sci2.eps");

// ___cut___

// [7] Dump Scilab graphic window 0 into png-file
unix("./xdumpwindow -geometry 600 ScilabGraphic0 sci2.png");

exit;
