//+private file
package main

import "core:fmt"
import "core:os"
import "core:sys/linux"

main :: proc() {
    pfds :[2]linux.Fd

    errlno := linux.pipe2(&pfds, linux.Open_Flags{})

    if errlno != .NONE {
        panic("ERROR pipe")
    }
    reader := os.Handle(pfds[0])
    writer := os.Handle(pfds[1])

    fmt.printfln("writing to file descriptor #%p", writer)

    str := "test"
    n, errno := os.write(writer, transmute([]byte)str)
    if errno != os.ERROR_NONE {
        panic("ERROR writing")
    }

    fmt.printfln("reading from file descriptor #%p", reader)
    buf :[30]byte
    n, errno = os.read(reader, buf[:])
    if errno != os.ERROR_NONE {
        panic("ERROR reading")
    }

    fmt.printfln("read \"%s\"", string(buf[:]))
}
