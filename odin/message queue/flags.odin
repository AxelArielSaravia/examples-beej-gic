//+private file
package message_queue

import "core:fmt"
import "core:sys/linux"

FLAGS :: bit_set[0..=15;u16]

main :: proc() {
    //000_000_000_000_000b
    //.IPC_CREAT = idx 9 (000_001_000_000_000b)
    //0ob664 (000_000_110_110_100b)

    creat_and_perms :FLAGS = {9,8,7,5,4,2}
    perms :FLAGS = {8,7,5,4,2}

    fmt.println(creat_and_perms)
    fmt.println("val:", transmute(i16)creat_and_perms)
    fmt.printfln("octal: %o\n", transmute(i16)creat_and_perms)

    fmt.println(perms)
    fmt.println("val:", transmute(i16)perms)
    fmt.printfln("octal: %o\n", transmute(i16)perms)

    fmt.println(transmute(linux.IPC_Flags)(i16(0o664)))
    fmt.println(transmute(linux.IPC_Flags)(i16(0o1664)))
}
