import seaborn as sns
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
if __name__ == '__main__':

    WER_scores= [79.68, 79.68, 79.68, 61.21, 59.04, 56.29, 55.21, 55.59, 56.29, 55.65, 55.59, 56.23]
    totgauss = [1, 10, 100, 1000, 2000, 5000, 10000, 11000, 13000, 15000, 17000, 20000]

    xs = totgauss
    ys = WER_scores

    plt.figure(figsize=(8,6))

    plt.plot(xs, ys, "-o")
    plt.ylim(50, 85)
    plt.title('WER per number of Gaussians')
    plt.xlabel('Number of Gaussians')
    plt.ylabel('Word Error Rate')
    for x, y in zip(xs, ys):
        plt.text(x, y, str(y), color="red", fontsize=8)

    plt.show()
