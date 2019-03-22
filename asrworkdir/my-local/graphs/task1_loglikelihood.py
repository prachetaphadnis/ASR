import matplotlib.pyplot as plt
if __name__ == '__main__':

    totgauss=[1, 10, 100, 1000, 2000, 5000, 10000, 11000, 13000, 15000, 17000, 20000]
    train_likelihood=[-103.54, -103.54, -103.54, -99.61, -98.63, -97.39, -96.35, -96.18, -95.89, -95.62, -95.36, -95.02]
    test_likelihood=[-8.80174, -8.80174, -8.80174, -8.51593, -8.45561, -8.39275, -8.36899, -8.36593, -8.36595, -8.36484, -8.3669, -8.37129]

    fig, axs = plt.subplots(2, 1, constrained_layout=True)
    axs[0].plot(totgauss, train_likelihood, color='orange')
    
    axs[0].set_ylabel('Train log-likelihood')
    fig.suptitle('Train/Test log-likelihood', fontsize=10)

    axs[1].plot(totgauss, test_likelihood)
    axs[1].set_xlabel('Number of Gaussians')
    axs[1].set_ylabel('Test log-likelihood')

    plt.show()
