#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char const*const argv[argc]) {
    struct flock fl = {
        .l_type = F_WRLCK,
        .l_whence = SEEK_SET,
    };
    if (argc > 1) {
        fl.l_type = F_RDLCK;
    }
    int fd = open("demo.c", O_RDWR);
    if (fd == -1) {
        perror("open");
        exit(1);
    }
    printf("Press ANY KEY to try to get lock: ");
    getchar();
    printf("Try to get look... ");

    if (fcntl(fd, F_SETLKW, &fl) == -1) {
        perror("fcntl");
        exit(1);
    }
    printf("got lock\n");
    printf("Press ANY KEY to release lock: ");
    getchar();

    fl.l_type = F_UNLCK;
    if (fcntl(fd, F_SETLK, &fl) == -1) {
        perror("fcntl");
        exit(1);
    }
    printf("Unlocked.\n");
    close(fd);

    return 0;
}
