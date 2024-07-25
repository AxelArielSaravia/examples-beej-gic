//+private file
package main

import "core:sys/linux"
import "core:os"
import "core:fmt"

main :: proc() {
    pfds :[2]linux.Fd

    errlno := linux.pipe2(&pfds, linux.Open_Flags{})
    if errlno != .NONE {
        panic("ERROR linux pipe2")
    }

    reader := os.Handle(pfds[0])
    writer := os.Handle(pfds[1])

    pid: linux.Pid
    pid, errlno = linux.fork()
    if errlno != .NONE {
        panic("ERROR linux fork")
    }
    if pid == 0 {
        fmt.println("CHILD: writing to file descriptor", writer)
        txt := "test"
        n, errno := os.write(writer, transmute([]byte)txt)
        if errno != os.ERROR_NONE {
            panic("ERROR writer")
        }
        fmt.println("CHILD: exiting")
        if n != len(txt) {
            os.exit(1)
        }
        os.exit(0)
    } else {
        fmt.println("PARENT: reading from file descriptor", reader)

        buf :[30]byte
        n, errno := os.read(reader, buf[:])
        if errno != os.ERROR_NONE {
            panic("ERROR reader")
        }
        fmt.printfln("PARENT: read \"%s\"", string(buf[:]))

        _, errlno := linux.wait4(pid, nil, nil, nil)
        if errno != os.ERROR_NONE {
            panic("ERROR wait")
        }

    }
}
