#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char **argv) {
        int rc;

        printf("Initializing MPI...\n");

	// Initialize the MPI environment
        rc = MPI_Init (&argc, &argv);
        if (rc != MPI_SUCCESS) {
                fprintf (stderr, "MPI_Init() failed");
                return EXIT_FAILURE;
        }

        printf("MPI Initialized\n");

	// Get the number of processes
        int world_size;
        rc = MPI_Comm_size (MPI_COMM_WORLD, &world_size);
        if (rc != MPI_SUCCESS) {
                fprintf (stderr, "MPI_Comm_size() failed");
                goto exit_with_error;
        }

        printf("Number of processes: %d\n", world_size);

	// Get the rank of the process
        int world_rank;
        rc = MPI_Comm_rank (MPI_COMM_WORLD, &world_rank);
        if (rc != MPI_SUCCESS) {
                fprintf (stderr, "MPI_Comm_rank() failed");
                goto exit_with_error;
        }

        printf("Process rank: %d\n", world_rank);

        // Get the name of the processor
        char processor_name[MPI_MAX_PROCESSOR_NAME];
        int name_len;
        rc = MPI_Get_processor_name(processor_name, &name_len);
        if (rc != MPI_SUCCESS) {
                fprintf (stderr, "MPI_Get_processor_name() failed");
                goto exit_with_error;
        }

        // Print off a hello world message
        printf("Hello world from processor %s, rank %d out of %d processors\n",
               processor_name, world_rank, world_size);


        MPI_Finalize();

        return EXIT_SUCCESS;

 exit_with_error:
        MPI_Finalize();
        return EXIT_FAILURE;
}
