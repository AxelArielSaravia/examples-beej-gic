#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/sem.h>
#include <stdio.h>
#include <stdlib.h>

typedef union semun semun;
union semun {
    int              val;    /* Value for SETVAL */
    struct semid_ds* buf;    /* Buffer for IPC_STAT, IPC_SET */
    unsigned short*  array;  /* Array for GETALL, SETALL */
    struct seminfo*  __buf;  /* Buffer for IPC_INFO (Linux-specific) */
};


//checks errno if there is an error
int sem_init(key_t key, int nsems) {
    int semid = semget(key, nsems, IPC_CREAT | IPC_EXCL | 0666);
    if (errno == EEXIST) {
        //Already exist
        printf("Some one create the Sem\n");
        _Bool ready = (_Bool)0;
        semid = semget(key, nsems, 0); //get the id
        if (semid < 0) {
            //error
            return semid;
        }

        struct semid_ds buf = {0};
        semun arg = {.buf = &buf};
        #define MAX_RETRIES 10
        for (int i = 0; i < MAX_RETRIES && !ready; i += 1) {
            semctl(semid, nsems-1, IPC_STAT, arg);
            if (buf.sem_otime != 0) {
                ready = (_Bool)1;
                break;
            } else {
                sleep(1);
            }
        }
        if (!ready) {
            errno = ETIME;
            return -1;
        }
    } else if (semid >= 0) {
        //we got it first
        struct sembuf sb = {
            .sem_op = 1
        };
        printf("press any\n");
        getchar();
        for (sb.sem_num = 0; sb.sem_num < nsems; sb.sem_num += 1) {
            //do a semop() to 'free' the semaphores
            //this set the sem_otime gield, as needed below
            if (semop(semid, &sb, 1) == -1) {
                int e = errno;
                semctl(semid, 0, IPC_RMID);//clean up
                errno = e;
                return -1;
            }
        }
    }
    return semid;
}

int main() {
    key_t key = ftok("semdemo.c", 'J');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }

    int semid = sem_init(key, 1);
    if (semid == -1) {
        perror("sem_init");
        exit(1);
    }
    printf("Press any to lock: ");
    getchar();
    printf("Trying to lock...\n");

    struct sembuf sb = {
        .sem_num = 0,
        .sem_op = -1, //allocate resource
        .sem_flg = SEM_UNDO,
    };
    if (semop(semid, &sb, 1) == -1) {
        perror("semop");
        exit(1);
    }
    printf("Locked.\n");
    printf("Press any to unlock: ");
    getchar();

    sb.sem_op = 1; //free resource
    if (semop(semid, &sb, 1) == -1) {
        perror("semop");
        exit(1);
    }

    printf("Unlocked\n");

    return 0;
}
