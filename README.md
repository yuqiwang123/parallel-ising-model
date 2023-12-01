# Parallel Ising Model Simulation

## MC simulation of Ising Model
<p>Ising model is a well-known model in statistical physics. The 2D Ising model consists of N $\times$ N spins which can be in two states: up(+1) and down(-1).</p>

  ![Ising](https://github.com/yuqiwang123/parallel-ising-model/assets/89886045/c79e1ab2-5a5e-4ca8-b3ef-3baa4345e0f4)

<p>Monte Carlo simulation with Metropolis algorithm is a common way to simulate Ising model. The steps:</p>
<p>
1. Initial a configuration of spins.
2. Choose a spin sequentially or randomly to flip.
3. If the change in energy is negative, we accept this flip.
4. Otherwise, the move is accepted with probability $e^{(-\beta \Delta E)}$, where $\beta$ is the inverse of the temperature of the system and $\Delta E$ is the difference in the energy from the spin flip.
5. Repeat steps 2 to 4.
</p>    
![1*VJuil-iMay2U5LaoYb_vJA](https://github.com/yuqiwang123/parallel-ising-model/assets/89886045/c075f4ec-7904-40f5-bf4d-7b6da531baca)


The downside is the performance. So we want to parallel this process.

## Parallelization
The N $\times$ N model can be divided into blocks which are updated .
