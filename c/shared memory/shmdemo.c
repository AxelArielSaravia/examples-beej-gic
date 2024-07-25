#include <sys/shm.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[argc]) {
    if (argc > 2) {
        fprintf(stderr, "usage: shmdemo [data_to_write]\n");
        exit(1);
    }
    key_t key = ftok("shmdemo.c", 'R');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }
    #define SHM_SIZE 1024
    int shmid = shmget(key, SHM_SIZE, IPC_CREAT | 0644);
    if (shmid == -1) {
        perror("shmget");
        exit(1);
    }
    char* data = shmat(shmid, (void*)0, 0);
    if (data == (void*)(-1)) { //we could use MAP_FAILED
        perror("shmat");
        exit(1);
    }
    if (argc == 2) {
        printf("writing to segment: \"%s\"\n", argv[1]);
        strncpy(data, argv[1], SHM_SIZE);
        data[SHM_SIZE-1] = '\0';
    } else {
        printf("segment contains: \"%s\"\n", data);
    }
    //detach from the segment
    if (shmdt(data) == -1) {
        perror("shmdt");
        exit(1);
    }
    return 0;
}
