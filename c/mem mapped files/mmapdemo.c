#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[argc]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: mmapdemo <offset>\n");
        exit(1);
    }
    int fd = open("mmapdemo.c", O_RDONLY);
    if (fd == -1) {
        perror("open");
        exit(1);
    }

    struct stat sbuf = {0};
    if (stat("mmapdemo.c", &sbuf) == -1) {
        perror("stat");
        exit(1);
    }
    off_t offset = atoi(argv[1]);
    if (offset < 0 || offset > sbuf.st_size - 1) {
        fprintf(
            stderr,
            "mmapdemo: offset must be in the range 0-%ld\n",
            sbuf.st_size - 1
        );
        exit(1);
    }
    char* data = mmap(0, sbuf.st_size, PROT_READ, MAP_SHARED, fd, 0);
    if (data == MAP_FAILED) {
        perror("mmap");
        exit(1);
    }
    printf("byte at offset %ld is '%c'\n", offset, data[offset]);
}
