#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    #define S_SIZE 256
    char s[S_SIZE] = {0};

    #define FIFO_NAME "../../maid"
    mknod(FIFO_NAME, S_IFIFO | 0666, 0);

    printf("waiting for readers...\n");
    int fd = open(FIFO_NAME, O_WRONLY);
    if (fd == -1) {
        fprintf(stderr, "Error bad file descriptor");
        return 1;
    }
    printf("got a reader -- type some stuff\n");

    if (!fgets(s, S_SIZE, stdin)) {
        return 1;
    }
    while (!feof(stdin)) {
        int n = write(fd, s, strlen(s));
        if (n == -1) {
            perror("write");
        } else {
            printf("speak: wrote %d bytes\n", n);
        }
        if (!fgets(s, S_SIZE, stdin)) {
            return 1;
        }
    }
    return 0;
}
