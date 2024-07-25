#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>

void sigint_handler(int sig) {
    char const msg[] = "Ahh ! SIGINT!\n";
    write(0, msg, sizeof msg);
}

int main() {
    char s[200] = {0};

    struct sigaction sa = {
        .sa_handler = sigint_handler,
        .sa_flags = 0, //SA_RESTART: continue to the process and restart the signal
        .sa_mask = 0,
    };

    if (sigaction(SIGINT, &sa, (void*)0) == -1) {
        perror("sigaction");
        exit(1);
    }

    printf("Enter a string: \n");
    if (fgets(s, sizeof s, stdin) == (void*)0) {
        perror("fgets");
    } else {
        printf("You entered: %s\n", s);
    }

    return 0;
}
