#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define INF 100

__global__ void floydWarshall(int *graph, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    for (int k = 0; k < n; k++)
    {
        int ik = i * n + k;
        int kj = k * n + j;
        int ij = i * n + j;
        if (graph[ij] > graph[ik] + graph[kj])
            graph[ij] = graph[ik] + graph[kj];
    }
}

int main(void)
{
    int n, i, j;
    printf("Enter the number of vertices: ");
    scanf("%d", &n);
    int *graph = (int *)malloc((long unsigned) n * n * sizeof(int));
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            if (i == j)
                graph[i * n + j] = 0;
            else
                graph[i * n + j] = INF;
        }
    }
    printf("Enter the edges: \n");
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            printf("[%d][%d]: ", i, j);
            scanf("%d", &graph[i * n + j]);
        }
    }
    printf("The original graph is:\n");
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            printf("%d ", graph[i * n + j]);
        }
        printf("\n");
    }

    int *d_graph;
    cudaMalloc((void **)&d_graph, n * n * sizeof(int));
    cudaMemcpy(d_graph, graph, n * n * sizeof(int), cudaMemcpyHostToDevice);

    dim3 blockSize(16, 16);
    dim3 gridSize((n + blockSize.x - 1) / blockSize.x, (n + blockSize.y - 1) / blockSize.y);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    floydWarshall<<<gridSize, blockSize>>>(d_graph, n);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cudaMemcpy(graph, d_graph, n * n * sizeof(int), cudaMemcpyDeviceToHost);

    printf("The shortest path matrix is:\n");
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            printf("%d ", graph[i * n + j]);
        }
        printf("\n");
    }

    printf("Execution time: %f ms\n", milliseconds);

    cudaFree(d_graph);
    free(graph);

    return 0;
}
