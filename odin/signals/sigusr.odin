//+private file
package signal

import "core:sys/linux"
import "core:fmt"
import "core:os"
import "core:time"
import "core:sync"

got_usr1: int

sigusr1_handler :: proc(_: linux.Signal) {
    sync.atomic_store(&got_usr1, 1)
}

main :: proc() {
    sa :linux.Sig_Action(byte) = {
        handler = linux.Sig_Handler_Fn(sigusr1_handler)
    }
    sync.atomic_store(&got_usr1, 0)

    errno := linux.rt_sigaction(.SIGUSR1, &sa, &linux.Sig_Action(byte){})
    if errno != .NONE {
        panic("ERROR: sigaction")
    }
    for got_usr1 == 0 {
        fmt.printfln("PID %d: working hard...", linux.getpid())
        time.sleep(time.Second)
    }
    fmt.println("Done in by SIGURS1!")
}
