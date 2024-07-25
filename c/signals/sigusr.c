#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>

volatile sig_atomic_t got_usr1;

void sigusr1_handler(int sig) {
    got_usr1 = 1;
}

int main() {
    struct sigaction sa = {
        .sa_handler = sigusr1_handler,
        .sa_flags = 0,
        .sa_mask = 0,
    };

    got_usr1 = 0;

    if (sigaction(SIGUSR1, &sa, (void*)0) == -1) {
        perror("sigaction");
        exit(1);
    }
    while (!got_usr1) {
        printf("PID %d: working hard...\n", getpid());
        sleep(1);
    }
    printf("Done in by SIGURS1!\n");

    return 0;
}
