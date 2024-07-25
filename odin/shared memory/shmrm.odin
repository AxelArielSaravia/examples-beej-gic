//+private file
package shared_memory

import "core:sys/linux"
import "core:fmt"

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
    key, lerrno := ftok("shmdemo.odin", 'R');
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: ftok\n", lerrno)
    }
    shmid :linux.Key
//TO_FIX: the linux.IPC_Flags bit_set does not have any way to
//        set the last significant 9 bit for permissions
// IPC_CREAT 0b001_000 | 0o0644
    shmid, lerrno = linux.shmget(
        key,
        0,
        transmute(linux.IPC_Flags)(u16(0o0644))
    )
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.shmget\n", lerrno)
    }
    lerrno = linux.shmctl_ds(shmid, .IPC_RMID, {})
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.shmctl_ds\n", lerrno)
    }
}
