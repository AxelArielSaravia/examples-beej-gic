//+private file
package message_queue

import "core:sys/linux"
import "core:fmt"
import "core:os"
import "core:bufio"

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
    msgid, lerrno = linux.msgget(key, transmute(linux.IPC_Flags)(i16(0o1666)))
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.msgget\n", lerrno)
    }
    fmt.println("Enter line of text:")
    buf := My_Msgbuf{ type = 1 }

    stream := os.stream_from_handle(os.stdin)
    reader: bufio.Reader
    bufio.reader_init_with_buf(&reader, stream, buf.text[:])


    for {
        line, rerr := bufio.reader_read_bytes(&reader, '\n')
        if rerr == .EOF {
            break
        } else if rerr != .None {
            fmt.panicf("%q ERROR: reading", rerr)
        }

        if line[len(line)-1] == '\n' {
            line = line[:len(line)-1];
        }
        buf.tlen = len(line)
        lerrno = linux.msgsnd(
            msgid,
            &buf,
            size_of(uint)+size_of(buf.text),
            {}
        )
        if lerrno != .NONE {
            fmt.panicf("%q ERROR: linux sending message\n", lerrno)
        }
    }
    _, lerrno = linux.msgctl(msgid, .IPC_RMID, nil)
    if lerrno != .NONE {
        fmt.panicf("%q ERROR: linux.msgctl\n", lerrno)
    }
}
