import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Make a data frame
hlayers=[2,4,6,8,10]
hdim=[256,512,1024,2048]
ttime=[[190,519,600,821],[559,606,745,1363],[625,707,998,2083],[751,811,1296,2802],[843,1016,1494,3971]]


# create a color palette
palette = plt.get_cmap('Set1')

# multiple line plot
num=0

for num in range(len(hlayers)):

    # Find the right spot on the plot
    plt.subplot(5,1, num+1)

    # Plot the lineplot
    plt.plot(hdim, ttime[num], marker='o')

    # Same limits for everybody!


    # Not ticks everywhere
    if num in range(0,4) :
        plt.tick_params(labelbottom=False)

    plt.yticks(np.arange(0,4000, step=800))
    

# Axis title
plt.xlabel("Hidden Dimensions")
#plt.ylabel("Hidden Layers")
plt.text(20, 12000, 'Hidden Layers', ha='center',  va='center', rotation='vertical')

plt.suptitle("Train Time", fontsize=13, fontweight=0, color='black', style='italic')

plt.show()
