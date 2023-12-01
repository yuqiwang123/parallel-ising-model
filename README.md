# Parallel Ising Model Simulation

## MC simulation of Ising Model
<p>Ising model is a well-known model in statistical physics. The 2D Ising model consists of N $\times$ N spins which can be in two states: up(+1) and down(-1).</p>

<img src="https://github.com/yuqiwang123/parallel-ising-model/assets/89886045/c79e1ab2-5a5e-4ca8-b3ef-3baa4345e0f4" width="250"/>

<p>Monte Carlo simulation with Metropolis algorithm is a common way to simulate Ising model. The steps:</p>
<ol>
<li>Initial a configuration of spins.</li>
<li>Choose a spin sequentially or randomly to flip.</li>
<li>If the change in energy is negative, we accept this flip.</li>
<li>Otherwise, the move is accepted with probability $e^{(-\beta \Delta E)}$, where $\beta$ is the inverse of the temperature of the system and $\Delta E$ is the difference in the energy from the spin flip.</li>
<li>Repeat steps 2 to 4.</li>
</ol>    

<img src="https://github.com/yuqiwang123/parallel-ising-model/assets/89886045/c075f4ec-7904-40f5-bf4d-7b6da531baca" alt="drawing" width="500"/>


The downside is the performance. So we want to parallel this process.

## Parallelization
We use checkerboard algorithm to parallel the update process. As the flip of a spin will only be decided by its four adjacent spins, the lattice can be divided into two parts which are shown as white color and black color squares in the figure. The spins of the same color can flip at the same time without updating the opposite color spins, which can help with the parallelization. 

Parallel method: GPU can be used to do the parallization. Divide the square lattice into several strips, and each strip can be updated in a GPU block. Each block also needs the bottom spins in above strip and the top spins in below strip. Also, within each strip the updating of same color spins can also be parallelized and run in different threads.

<img width="413" alt="Screenshot 2023-11-30 at 8 36 59 PM" src="https://github.com/yuqiwang123/parallel-ising-model/assets/89886045/11538cfb-68af-45b1-91c2-2572f6a756fa">
