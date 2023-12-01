# Parallel Ising Model Simulation

## Ising Model
Ising model is a well-known model in statistical physics. The 2D Ising model consists of N $\times$ N spins which can be in two states: up(+1) and down(-1). 
![Ising](https://github.com/yuqiwang123/parallel-ising-model/assets/89886045/c79e1ab2-5a5e-4ca8-b3ef-3baa4345e0f4)

Monte Carlo simulation with Metropolis algorithm is a common way to simulate Ising model. The steps:
1. Initial a configuration of spins.
2. Flip a randomly chosen spin.
3. If the change in energy is negative, we accept this flip.
4. Otherwise, the move is accepted with probability $$e^(−β∆E)$$, where β is the inverse of the temperature of the system and ∆E is the difference in the energy from the spin flip.

## Parallelization
The N $\times$ N model can be divided into blocks which are updated .
