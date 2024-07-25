//+private file
package fifo

import "core:sys/linux"
import "core:fmt"
import "core:os"

main :: proc() {
    FIFO_NAME :: "../../maid"
    errlno := linux.mknod(
        FIFO_NAME,
        linux.Mode{.IFFIFO, .IWOTH, .IROTH, .IWGRP, .IRGRP, .IWUSR, .IRUSR},
        0
    )

    fmt.println("waiting for writers...\n")
    fh, errno := os.open(FIFO_NAME, os.O_RDONLY)
    if errno != os.ERROR_NONE {
        panic("ERROR bad file descriptor")
    }
    fmt.println("go a writer\n")

    s :[255]byte
    for {
        n, errno := os.read(fh, s[:])
        if errno != os.ERROR_NONE {
            panic("ERROR reading")
        }
        if n <= 0 {
            break
        }
        fmt.printfln("tick: read %d bytes: \"%s\"", n, string(s[:n-1]))

    }
}
