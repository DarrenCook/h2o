#Run the load.building_energy.py script, to set `train`

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt 

#Make the correlations and download to a Pandas frame
res = train[x].cor(train[y]).as_data_frame()
res.index = x

#res.plot.barh();plt.show() is enough to draw the bar chart.
#All the rest of this code is making it pretty, with labels on each bar.

ax = res.plot.barh(xlim=[-1.1,+1.15])
for p in ax.patches:
  if p.get_x() < 0:
      ax.annotate("-%.2f" % p.get_width(), (p.get_x() -0.05 , p.get_y()), ha="right", va="center", xytext=(5, 10), textcoords='offset points')
  else:        
      ax.annotate("%.2f" % p.get_width(), (p.get_x() + p.get_width() +0.03, p.get_y()), va="center", xytext=(5, 10), textcoords='offset points')

plt.show()
