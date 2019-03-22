import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
if __name__ == '__main__':

    hidden_layers=[2, 4, 6, 8, 10]
    hidden_dimensions=[256, 512, 1024, 2048]
    WER=np.array([[43.58, 41.92, 42.43, 41.79], [41.47, 41.53, 41.53, 40.83], [41.15, 41.02, 40.70, 41.21], [42.75, 41.34, 41.60, 41.66], [43.96, 42.43, 43.58, 43.07]])

    ax = sns.heatmap(WER,annot=True, fmt='.2f')

    ax.set_xticklabels(hidden_layers)
    ax.set_yticklabels(hidden_dimensions)

    for tick in ax.xaxis.get_minor_ticks():
        tick.tick1line.set_markersize(0)
        tick.tick2line.set_markersize(0)
        tick.label1.set_horizontalalignment('center')

    for tick in ax.yaxis.get_minor_ticks():
        tick.tick1line.set_markersize(0)
        tick.tick2line.set_markersize(0)
        tick.label1.set_verticalalignment('center')




    
    ax.set_title("Word Error Rate")
    ax.set_xlabel("Number of hidden layers")
    ax.set_ylabel("Number of hidden dimensions")
    plt.show()
