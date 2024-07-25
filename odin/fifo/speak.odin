//+private file
package fifo

import "core:fmt"
import "core:os"
import "core:bufio"
import "core:sys/linux"


main :: proc() {
    FIFO_NAME :: "../../maid"
    linux.mknod(
        FIFO_NAME,
        linux.Mode{.IFFIFO, .IWOTH, .IROTH, .IWGRP, .IRGRP, .IWUSR, .IRUSR},
        0
    )
    fmt.println("waiting for readers...")

    fh, errno := os.open(FIFO_NAME, os.O_WRONLY)
    if errno != os.ERROR_NONE {
        panic("ERROR: bad file descriptor");
    }
    fmt.println("got a reader -- type some stuff")

    stream := os.stream_from_handle(os.stdin);

    reader: bufio.Reader
    bufio.reader_init(&reader, stream);

    for {
        line, rerr := bufio.reader_read_bytes(&reader, '\n');
        if rerr == .EOF {
            break
        } else if rerr != .None {
            panic("ERROR: reading")
        }
        n: int
        n, errno = os.write(fh, line)
        if errno != os.ERROR_NONE {
            panic("ERROR: writing")
        }
        if n == 0 {
            panic("ERROR: no buffer readed")
        }
        fmt.printfln("speak: wrote %d bytes", n)
    }
}
