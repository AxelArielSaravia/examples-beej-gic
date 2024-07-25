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

    printf("waiting for writers...\n");
    int fd = open(FIFO_NAME, O_RDONLY);
    printf("got a writer\n");

    for (;;) {
        int n = read(fd, s, S_SIZE);
        if (n == -1) {
            perror("read");
        }
        if (n <= 0) {
            break;
        }
        s[n-1] = '\0';
        s[n] = '\0';
        printf("tick: read %d bytes: \"%s\"\n", n, s);
    }
    return 0;
}
