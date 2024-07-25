//+private file
package semaphores

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
    key, lerrno := ftok(cstring("semdemo.odin"), 90)
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: ftok\n", lerrno)
    }
    semid :linux.Key
    semid, lerrno = linux.semget(key, 1, {})
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.semget\n")
    }
    _, lerrno = linux.semctl(semid, 0, .IPC_RMID)
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.semget\n")
    }
}
