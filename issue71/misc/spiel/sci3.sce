// [1] Define function
function z = g(u, v)
    z = exp(u) .* (4.0*u.^2 + 2.0*v.^2 + 4.0*u.*v + 2.0*v + 1.0)
endfunction

// [2] Define weight function for iso-line distances
function y = pow_weight(x, n)
    // Map interval X onto itself, weight with N-th power.
    d = max(x) - min(x)
    y = d*((x - min(x))/d).^n + min(x)
endfunction

// [3] Define sampling grid for g()
x = linspace(-4.5, -0.5, 40);
y = linspace(-1.0, 3.0, 40);

// [4] Evaluate g() at points defined by X and Y
z = eval3d(g, x, y);

// [5] Compute iso-line distances
iso_levels = pow_weight(linspace(min(z)*1.01, max(z)*0.99, 12), 3.0);

// [6] Clear plot window's contents
xbasc();

// [7] Set format of iso-line annotation and plot
xset("fpf", "%.2f");
contour2d(x, y, z, iso_levels);

// [8] Define decoration
xtitle("Contour Plot of g(u, v)", "u", "v");

// [9] Save plot window's contents to file; convert file to PostScript
xbasimp(0, "sci3.xps");
unix("scilab -save_p sci3.xps.0 Postscript");

// ___cut___

// [10] Dump Scilab graphic window 0 into png-file
unix("./xdumpwindow -geometry 600 ScilabGraphic0 sci3.png");

exit;
