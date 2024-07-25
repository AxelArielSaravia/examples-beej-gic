//+private file
package message_queue

import "core:sys/linux"
import "core:fmt"
import "core:strings"

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

My_Msgbuf :: struct{
    type :int,
    tlen :uint,
    text :[200]u8,
}

main :: proc() {
    key, lerrno := ftok(cstring("kirk.odin"), 'a')
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: ftok\n", lerrno)
    }
    fmt.println("key:", key)

    msgid :linux.Key
//TO_FIX: the linux.IPC_Flags bit_set does not have any way to
//        set the last significant 9 bit for permissions
// IPC_CREAT | 0o0666
    msgid, lerrno = linux.msgget(key, transmute(linux.IPC_Flags)(i16(0o666)))
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.msgget\n", lerrno)
    }
    fmt.println("spock: ready to receive messages, captain.")
    buf :My_Msgbuf
    for {
        //_ buff.text writing len
        _, lerrno = linux.msgrcv(
            msgid,
            &buf,
            size_of(uint)+size_of(buf.text),
            0,
            {}
        )
        if lerrno != .NONE {
            fmt.panicf("%q ERROR: linux.msgrcv\n", lerrno)
        }
        fmt.printfln("spock: \"%s\"", buf.text[:buf.tlen])
    }
}
