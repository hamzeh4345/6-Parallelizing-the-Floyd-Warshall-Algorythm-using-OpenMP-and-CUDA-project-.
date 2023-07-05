#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

#define INF 100

void floydWarshall(int *graph, int n)
{
    int i, j, k;
    for (k = 0; k < n; k++)
    {
        #pragma omp parallel for private(i, j)
        for (i = 0; i < n; i++)
        {
            for (j = 0; j < n; j++)
            {
                int ik = i * n + k;
                int kj = k * n + j;
                int ij = i * n + j;
                if (graph[ij] > graph[ik] + graph[kj])
                    graph[ij] = graph[ik] + graph[kj];
            }
        }
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

    clock_t start = clock();
    floydWarshall(graph, n);
    clock_t end = clock();
    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;

    printf("The shortest path matrix is:\n");
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < n; j++)
        {
            printf("%d ", graph[i * n + j]);
        }
        printf("\n");
    }

    printf("Execution time: %f seconds\n", time_spent);

    free(graph);

    return 0;
}
