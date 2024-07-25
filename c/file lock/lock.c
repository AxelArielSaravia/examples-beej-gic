#include <fcntl.h>
#include <unistd.h>

int main() {
    struct flock fl = {
        .l_type   = F_WRLCK,  //F_RDLCK, F_WRLCK, F_UNLCK
        .l_whence = SEEK_SET, //SEEK_SET, SEEK_CUR, SEEK_END
        .l_start  = 0,        //Offset for l_whence
        .l_len    = 0,        //length, 0 = to EOF
        //.l_pid              //PIF holding lock; F_RDLCK only
    };

    int fd = open("filename", O_WRONLY);
    fcntl(fd, F_SETLKW, &fl); //F_GETLK, F_SETLK, F_SETLKW
    return 0;
}
