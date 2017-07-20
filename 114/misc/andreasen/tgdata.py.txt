from scipy import *

data=io.array_import.read_array('tgdata.dat')
plotfile='tgdata.png'

gplt.plot(data[:,0],data[:,1],'title "Weight vs. time" with points')
gplt.xtitle('Time [h]')
gplt.ytitle('Hydrogen release [wt. %]')
gplt.grid("off")
gplt.output(plotfile,'png medium transparent picsize 600 400')  

