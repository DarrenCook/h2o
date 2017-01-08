############
# Number of training samples we have for each digit

train60K.group_by(y).count().frame

############
# Get the average of each digit

avg = train60K.group_by(y).mean()
avg_pixels = avg.frame[:,1:785].as_data_frame()
sorted_columns = sorted(avg_pixels.columns, key=lambda x: int(x[6:]))
avg_pixels = avg_pixels.reindex_axis(sorted_columns, axis=1)


############
# Print those averages, as a 5x2 grid


import matplotlib
import matplotlib.pyplot as plt
import numpy as np

fig = plt.figure()
fig.set_tight_layout({"pad": .0})  #Remove margin between them
for n in range(10):
    sfig = fig.add_subplot(2, 5, n+1)
    z = avg_pixels.loc[[n]].as_matrix().reshape(28, 28)  #Make a 28x28 numpy
        #matrix from one row of the avg_pixels data frame.
    sfig.matshow(z, cmap = matplotlib.cm.binary)  #The cmap tells it draw in greyscale
    plt.xticks(np.array([]))  #We don't want the axes numbered
    plt.yticks(np.array([]))
plt.show()

