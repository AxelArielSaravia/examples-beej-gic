#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    key_t key = ftok("shmdemo.c", 'R');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }
    int shmid = shmget(key, 0, 0644);
    if (shmid == -1) {
        perror("shmget");
        exit(1);
    }
    if (shmctl(shmid, IPC_RMID, 0) == -1) {
        perror("shmctl");
        exit(1);
    }
    return 0;
}
