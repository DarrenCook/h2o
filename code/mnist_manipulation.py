############
# Number of training samples we have for each digit

train2.group_by(y).count().frame

############
# Get the average of each digit

avg = train2.group_by(y).mean()
avg_pixels = avg.frame[:,1:785].as_data_frame()
sorted_columns = sorted(avg_pixels.columns, key=lambda x: int(x[6:]))
avg_pixels = avg_pixels.reindex_axis(sorted_columns, axis=1)


############
# Print those averages, as a 5x2 grid


import matplotlib
import matplotlib.pyplot as plt
import numpy as np

fig = plt.figure()
for n in range(10):
    sfig = fig.add_subplot(5, 2, n)
    ax.matshow(z1, cmap = matplotlib.cm.binary)
    plt.xticks(np.array([]))
    plt.yticks(np.array([]))
plt.show()

