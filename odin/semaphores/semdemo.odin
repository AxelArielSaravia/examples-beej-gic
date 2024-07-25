//+private file
package semaphores

import "core:sys/linux"
import "core:time"
import "core:fmt"
import "core:os"
import "core:io"

//TO_FIX: the op in linux.Sem_Buf struct does not have any way to
//        set the last significant 9 bit for permissions
//This is a linux.Sem_Buf wrapper, must be used as
// transmute(linux.Sem_Buf)<Sembuf>
Sembuf :: struct{
    num: u16,
    op:  i16,
    flg: linux.IPC_Flags,
}

//TO_FIX: there is an error when I use ^linux.Sem_Un directly
//This is a linux.Sem_Un wrapper, must be used as
// transmute(linux.Sem_Un)<Semun>
Semun :: struct #raw_union {
    val :int,
    buf :^linux.Semid_DS,
}

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

sem_init :: proc(key :linux.Key, nsems :i32) -> (linux.Key, linux.Errno) {
    semid, lerrno := linux.semget(
        key,
        nsems,
//TO_FIX: the linux.IPC_Flags bit_set does not have any way to
//        set the last significant 9 bit for permissions
// IPC_CREAT 0b001_000 | IPC_EXCL 0b010_000 | 0o0666
        transmute(linux.IPC_Flags)(i16(0o3666)),
    )
    if lerrno == .EEXIST {
        fmt.println("Some one create the Sem\n");
        ready :bool = false
        semid, lerrno = linux.semget(key, nsems, {})
        if lerrno != .NONE {
            return {}, lerrno
        }
        buf :linux.Semid_DS
        arg :Semun = {buf = &buf}
        MAX_RETRIES :: 10
        for i in 0..<MAX_RETRIES {
            _, lerrno = linux.semctl(
                semid,
                nsems-1,
                .IPC_STAT,
                transmute(^linux.Sem_Un)&arg
            )
            if lerrno != .NONE {
                return {}, lerrno
            }
            fmt.println(buf.otime)
            if buf.otime != 0 {
                ready = true
                break;
            } else {
                time.sleep(time.Second)
            }
        }
        if (!ready) {
            return {}, .ETIME
        }
    } else if lerrno == .NONE {
        sb := Sembuf{op = 1}
        fmt.println("We create the sem")
        fmt.print("Press any to init the sem: ")
        stream_in := os.stream_from_handle(os.stdin)
        _, err := io.read_byte(stream_in)
        if err != nil {
            fmt.panicf("%q ERROR: reading\n", err)
        }

        for i in 0..<nsems {
            sb.num = u16(i)
            lerrno = linux.semop(
                semid,
                {transmute(linux.Sem_Buf) sb}
            )
            if lerrno != .NONE {
                linux.semctl(semid, 0, .IPC_RMID)
                return {}, lerrno
            }
        }
    }

    return semid, lerrno
}

main :: proc() {
    stream_in := os.stream_from_handle(os.stdin)

    key, lerrno := ftok(cstring("semdemo.odin"), 90)
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: ftok\n", lerrno)
    }

    semid :linux.Key
    semid, lerrno = sem_init(key, 1)
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: sem_init\n", lerrno)
    }
    fmt.print("Press any to lock:")
    _, err := io.read_byte(stream_in)
    if err != nil {
        fmt.panicf("%q ERROR: reading\n", err)
    }
    fmt.println("Trying to lock...")

    sb := Sembuf{
        op = -1,
        flg = {.SEM_UNDO}
    }
    lerrno = linux.semop(semid, {transmute(linux.Sem_Buf) sb})
    if lerrno != .NONE {
        fmt.panicf("%q error: linux.semop")
    }
    fmt.println("Locked.")
    fmt.print("Press any to unlock: ")
    _, err = io.read_byte(stream_in)
    if err != nil {
        fmt.panicf("%q ERROR: reading\n", err)
    }
    sb.op = 1

    lerrno = linux.semop(semid, {transmute(linux.Sem_Buf) sb})
    if lerrno != .NONE {
        fmt.panicf("%q error: linux.semop")
    }
    fmt.println("Unlocked.")
}
