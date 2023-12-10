import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("lattice.txt")
plt.imshow(data)
plt.colorbar()
plt.show()
