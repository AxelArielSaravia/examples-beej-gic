#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main() {
    int pfds[2];
    pipe(pfds);

    if (!fork()) {
//Child process
        close(1);
//make stdout same as pfds[1]
        dup(pfds[1]);
//we do not need this
        close(pfds[0]);
        execlp("ls", "ls", (void*)0);
    } else {
//Parent process
        close(0);
//make stdin same as pfds[0]
        dup(pfds[0]);
//we do not need this
        close(pfds[1]);
        execlp("wc", "wc", "-l", (void*)0);
    }

    return 0;
}
