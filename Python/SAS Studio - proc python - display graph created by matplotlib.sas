proc python;
submit;

import matplotlib.pyplot as plt
import numpy as np

t = np.arange(0.0, 2.0, 0.01)
s = 1 + np.sin(2*np.pi*t)
plt.plot(t, s)

plt.xlabel('time (s)')
plt.ylabel('voltage (mV)')
plt.title('Matplotlib graph (Python) - displayed using proc gslide')
plt.grid(True)
plt.savefig("/tmp/matplotlib-ex1.png")

endsubmit;
run;

proc gslide
   iframe='/tmp/matplotlib-ex1.png'
   imagestyle=fit;
run;