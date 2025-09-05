#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <random>

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);
    
    int rank, workers;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &workers);
    
    // Initialize random number generator
    std::default_random_engine generator;
    std::uniform_real_distribution<double> distribution(0.0, 1.0);
    generator.seed(rank + 42); // Different seed for each process
    
    // Monte Carlo simulation
    long long worker_count = 0;
    int worker_tests = 10000000;
    double x, y;
    
    for (int i = 0; i < worker_tests; i++) {
        x = distribution(generator);
        y = distribution(generator);
        if (x * x + y * y <= 1.0) {
            worker_count++;
        }
    }
    
    // Gather results from all processes
    long long total_count = 0;
    MPI_Reduce(&worker_count, &total_count, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
    
    if (rank == 0) {
        double pi = 4.0 * (double)total_count / (double)(worker_tests) / (double)(workers);
        printf("pi is approximately %.16f\n", pi);
        printf("Error is %.16f\n", pi - 3.141592653589793);
    }
    
    MPI_Finalize();
    return 0;
}