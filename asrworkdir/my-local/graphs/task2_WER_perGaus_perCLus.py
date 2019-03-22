import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
if __name__ == '__main__':

    totgauss=[5000, 15000, 20000, 30000]
    clusters=[500, 1000, 1500, 2000, 2500, 5000]
    WER=np.array([[49.46, 48.05, 45.75, 46.20, 46.58, 46.13], [47.92, 45.50, 45.30, 44.92, 45.11, 46.13], [49.20, 47.03, 45.88, 46.26, 46.07, 44.98], [50.29, 48.88, 46.84, 47.48, 47.48, 48.18]])

    ax = sns.heatmap(WER,annot=True, fmt='.2f')

    ax.set_xticklabels(clusters)
    ax.set_yticklabels(totgauss)

    for tick in ax.xaxis.get_minor_ticks():
        tick.tick1line.set_markersize(0)
        tick.tick2line.set_markersize(0)
        tick.label1.set_horizontalalignment('center')

    for tick in ax.yaxis.get_minor_ticks():
        tick.tick1line.set_markersize(0)
        tick.tick2line.set_markersize(0)
        tick.label1.set_verticalalignment('center')




    

    ax.set_title("Word Error Rates")
    ax.set_xlabel("Number of clusters")
    ax.set_ylabel("Number of Gaussians")
    plt.show()
