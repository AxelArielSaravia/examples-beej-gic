//+private file
package mem_mapped_files

import "core:sys/linux"
import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
    if len(os.args) != 2 {
        fmt.fprintln(os.stderr, "Usage: mmapdemo <offset>")
        os.exit(1)
    }
    fh, errno := os.open("mmapdemo.odin", os.O_RDONLY)
    if errno != os.ERROR_NONE {
        fmt.panicf("%q ERROR: open\n", errno)
    }

    fi :os.File_Info
    fi, errno = os.stat("mmapdemo.odin")
    if errno != os.ERROR_NONE {
        fmt.panicf("%q ERROR: stat\n", errno)
    }

    offset, ok := strconv.parse_uint(os.args[1])
    if !ok {
        fmt.panicf("ERROR: parse fails\n")
    }
    if offset < 0 || offset > uint(fi.size) - 1 {
        fmt.fprintfln(
            os.stderr,
            "mmapdemo: offset mus be in the range 0-%d",
            fi.size - 1
        )
        os.exit(1)
    }

    rp_data, lerrno := linux.mmap(
        addr={},
        size=uint(fi.size),
        prot={.READ},
        flags={.SHARED},
        fd=linux.Fd(fh),
        offset=0
    )
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.mmap\n", lerrno)
    }
    fmt.printfln(
        "byte at offset %d is '%c'",
        offset,
        string(cstring(rp_data))[offset]
    )
}
