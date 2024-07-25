#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main() {
    int rv = 0;
    pid_t pid = fork();
    switch (pid) {
        case -1: {
            perror("fork");
            exit(1);
        }
        case 0: {
            printf(
                "Child: This is the child process!\n"
                "Child: My PID is %d\n"
                "Child: My parent's PID is %d\n",
                getpid(),
                getppid()
            );
            printf("Child: Enter my exit status (make it small): ");
            scanf("%d", &rv);
            printf("Child: I'm outta here!\n");
            exit(rv);
        }
        default: {
            printf(
                "Parent: This is the parent process!\n"
                "Parent: My PID is %d\n"
                "Parent: My child's PID is %d\n"
                "Parent: I am nor waiting for my child to exit()...\n",
                getpid(),
                pid
            );
            wait(&rv);
            printf(
                "Partent: My child's exit status is: %d\n"
                "Parent: I'm outta here!\n",
                WEXITSTATUS(rv)
            );
        }
    }
    return 0;
}
