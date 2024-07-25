//+private file
package shared_memory

import "core:sys/linux"
import "core:os"
import "core:fmt"
import "core:strings"
import "core:io"

ftok :: proc(path :cstring, id :uint) -> (key :linux.Key, lerrno :linux.Errno) {
    st :linux.Stat
    lerrno = linux.stat(path, &st)
    if lerrno != nil {
        return 0, lerrno
    }
    key = linux.Key(
        (uint(st.ino) & 0xffff) |
        ((uint(st.dev) & 0xff) << 16) |
        ((id & 0xff) << 24)
    )
    return key, .NONE
}

main :: proc() {
    if len(os.args) > 2 {
        fmt.fprintln(os.stderr, "Usage: shmdemo [data_to_write]")
        os.exit(1)
    }
    key, lerrno := ftok("shmdemo.odin", 'R');
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: ftok\n", lerrno)
    }

    SHM_SIZE :: 1024
    shmid :linux.Key

//TO_FIX: the linux.IPC_Flags bit_set does not have any way to
//        set the last significant 9 bit for permissions
// IPC_CREAT 0b001_000 | 0o0644
    shmid, lerrno = linux.shmget(
        key,
        SHM_SIZE,
        transmute(linux.IPC_Flags)(u16(0o1644))
    )
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.shmget\n", lerrno)
    }
    rpdata :rawptr
    rpdata, lerrno = linux.shmat(shmid, nil, {})
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.shmat")
    }


    if len(os.args) == 2 {
        bufdata : []byte = ([^]byte)(rpdata)[:SHM_SIZE]
        indata := transmute([]byte)os.args[1]
        if len(indata) < SHM_SIZE {
            copy(bufdata, indata)
            bufdata[len(os.args[1])] = 0;
        } else {
            copy(bufdata, indata[:SHM_SIZE-1])
        }

        fmt.printfln("writing to segment: \"%s\"", os.args[1])
    } else {
        fmt.printfln("segment contains: \"%s\"", cstring(rpdata))
    }
    lerrno = linux.shmdt(rpdata)
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.shmdt\n", lerrno)
    }
}
