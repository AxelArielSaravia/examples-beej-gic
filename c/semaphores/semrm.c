#include <fcntl.h>
#include <unistd.h>
#include <sys/sem.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    key_t key = ftok("semdemo.c", 'J');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }
    int semid = semget(key, 1, 0);
    if (semid == -1) {
        perror("semget");
        exit(1);
    }

    if (semctl(semid, 0, IPC_RMID, 0) == -1) {
        perror("semctl");
        exit(1);
    }

    return 0;
}
