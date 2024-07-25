#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main() {
    char buf[30] = {0};
    int pfds[2] = {0};

    if (pipe(pfds) == -1) {
        perror("pipe");
        exit(1);
    }

    if (!fork()) {
        printf("CHILD: writing to file descriptor #%d\n", pfds[1]);
        int n = write(pfds[1], "test", 5);
        printf("CHILD: exiting\n");
        if (n != 5) {
            exit(1);
        }
        exit(0);
    } else {
        printf("PARENT: reading from file descriptor #%d\n", pfds[0]);
        int n = read(pfds[0], buf, 5);
        printf("PARENT: read \"%s\"\n", buf);
        wait((void*)0);
    }
    return 0;
}
