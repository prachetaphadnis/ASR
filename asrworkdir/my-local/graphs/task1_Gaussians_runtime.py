import seaborn as sns
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
if __name__ == '__main__':

    run_time= [285, 285, 305, 347, 395, 471, 554, 579, 611, 649, 708, 763]
    totgauss = [1, 10, 100, 1000, 2000, 5000, 10000, 11000, 13000, 15000, 17000, 20000]

    xs = totgauss
    ys = run_time

    plt.figure(figsize=(8,6))

    plt.plot(xs, ys, "-o")

    plt.title('Train time per number of Gaussians')
    plt.xlabel('Number of Gaussians')
    plt.ylabel('Time(s)')

    plt.show()
