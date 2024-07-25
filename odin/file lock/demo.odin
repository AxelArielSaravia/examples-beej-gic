//+private file
package file_lock

import "core:sys/linux"
import "core:os"
import "core:fmt"

main :: proc() {
    handler, errno := os.open("demo.odin", os.O_RDWR)
    if errno != os.ERROR_NONE {
        panic("ERROR open")
    }
    defer os.close(handler)

    fmt.print("Press ANY KEY to try to get lock: ")

    buf :[1]byte
    _,errno = os.read(os.stdin, buf[:])
    if errno != os.ERROR_NONE {
        panic("ERROR read")
    }
    fmt.print("Try to get look... ")

    fl := linux.FLock{
        type = linux.FLock_Type.WRLCK,
        whence = linux.Seek_Whence.SET,
    }
    if len(os.args) > 1 {
        fl.type = linux.FLock_Type.RDLCK
    }

    errlno := linux.fcntl_setlkw(linux.Fd(handler), .SETLKW, &fl)
    if errlno != .NONE {
        panic("ERROR linux.fcntl")
    }
    fmt.println("got lock")

    fmt.print("Press ANY KEY to release lock: ")

    _,errno = os.read(os.stdin, buf[:])
    if errno != os.ERROR_NONE {
        panic("ERROR read")
    }

    fl.type = linux.FLock_Type.UNLCK
    errlno = linux.fcntl_setlk(linux.Fd(handler), .SETLK, &fl)
    if errlno != .NONE {
        panic("ERROR linux.fcntl")
    }

    fmt.println("Unlocked")
}
