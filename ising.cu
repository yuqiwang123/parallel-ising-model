#include <cuda.h>
#include <curand.h>
#include <stdio.h>
#include <string>
#include <stdlib.h>
#include <fstream>
#include <chrono>

#define N 1000
#define THREADS 100
#define ITERS 50

__global__ void init(signed char* lattice, const float* __restrict__ randvals) {
  long long tid = static_cast<long long>(blockDim.x) * blockIdx.x + threadIdx.x;
  if(tid >= N * N/2) return;
  signed char spin = (randvals[tid] < 0.5f) ? -1 : 1;
  lattice[tid] = spin;
}

__global__ void update(signed char* lattice, bool is_black, 
                       const signed char* __restrict__ op_lattice,
                       const float* __restrict__ randvals) {
  long long tid = static_cast<long long>(blockDim.x) * blockIdx.x + threadIdx.x;
  int i = tid / (N/2), j = tid % (N/2);
  if(i >= N || j >= N/2) return;
  int down = (i + 1 >= N) ? 0 : i + 1;
  int up = (i - 1 < 0) ? N - 1 : i - 1;
  int right = (j + 1 >= N/2) ? 0 : j + 1;
  int left = (j - 1 < 0) ? N/2 - 1 : j - 1;

  int joff;
  if (is_black) {
    joff = (i % 2) ? right : left;
  } else {
    joff = (i % 2) ? left : right;
  }

  signed char sum = op_lattice[down * N/2 + j] + op_lattice[i * N/2 + j] + op_lattice[up * N/2 + j] + op_lattice[i * N/2 + joff];
  signed char spin = lattice[i * N/2 + j];
  float T = 0.1f*2.26918531421f;
  float P = exp(-2.0f * (1.0/T) * sum * spin);
  if (randvals[i*N/2 + j] < P) {
    lattice[i*N/2 + j] = -spin;
  }
}

void output(signed char *lattice_b, signed char *lattice_w) {
  signed char *lattice, *black, *white;
  lattice = (signed char*)malloc(N*N * sizeof(*lattice));
  black = (signed char*)malloc(N*N/2 * sizeof(*black));
  white = (signed char*)malloc(N*N/2 * sizeof(*white));

  cudaMemcpy(black, lattice_b, N*N/2 * sizeof(*lattice_b), cudaMemcpyDeviceToHost);
  cudaMemcpy(white, lattice_w, N*N/2 * sizeof(*lattice_w), cudaMemcpyDeviceToHost);

  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N/2; j++) {
      if (i % 2) {
        lattice[i*N+2*j+1] = black[i*N/2+j];
        lattice[i*N+2*j] = white[i*N/2+j];
      } else {
        lattice[i*N+2*j] = black[i*N/2+j];
        lattice[i*N+2*j+1] = white[i*N/2+j];
      }
    }
  }

  FILE* f = fopen("lattice.txt", "w");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
       fprintf(f, "%i ", (int)lattice[i*N+j]);
       //f << (int)lattice[i*N+j] << " ";
    }
    fprintf(f, "\n");
  }
  fclose(f);

  free(lattice);
  free(black);
  free(white);
}

int main() {
  signed char *lattice_b, *lattice_w;
  cudaMalloc(&lattice_b, N * N/2 * sizeof(*lattice_b));
  cudaMalloc(&lattice_w, N * N/2 * sizeof(*lattice_w));

  curandGenerator_t crd;
  unsigned long long seed = 1111ULL;
  curandCreateGenerator(&crd, CURAND_RNG_PSEUDO_PHILOX4_32_10);
  curandSetPseudoRandomGeneratorSeed(crd, seed);
  float *randvals;
  cudaMalloc(&randvals, N*N/2 * sizeof(*randvals));

  int blocks = (N*N/2 + THREADS - 1)/THREADS;
  curandGenerateUniform(crd, randvals, N*N/2);
  init<<<blocks, THREADS>>>(lattice_b, randvals);
  curandGenerateUniform(crd, randvals, N*N/2);
  init<<<blocks, THREADS>>>(lattice_w, randvals); 
  
  auto start = std::chrono::high_resolution_clock::now();
  for(int i = 0; i < ITERS; i++) {
    curandGenerateUniform(crd, randvals, N*N/2);
    update<<<blocks, THREADS>>>(lattice_b, true, lattice_w, randvals);
    curandGenerateUniform(crd, randvals, N*N/2);
    update<<<blocks, THREADS>>>(lattice_w, false, lattice_b, randvals);    
  }
  cudaDeviceSynchronize();
  auto end = std::chrono::high_resolution_clock::now();
  double time = (double) std::chrono::duration_cast<std::chrono::microseconds>(end-start).count();
  printf("updated time: %fs\n", time * 1e-6);

  //output
  output(lattice_b, lattice_w);
  return 0;	
}
