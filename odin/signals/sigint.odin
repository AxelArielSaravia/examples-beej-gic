//+private file
package signal

import "core:sys/linux"
import "core:os"
import "core:bufio"
import "core:fmt"

sigint_handler :: proc(sig: linux.Signal) {
    msg := "\nAhh! SIGINT!"
    sigmsg := "\nInterrupted Signal\n"
    os.write(0, transmute([]byte)msg)
    os.write(0, transmute([]byte)sigmsg)
    os.exit(0);
}

main :: proc() {
    sa :linux.Sig_Action(byte) = {
        handler = linux.Sig_Handler_Fn(sigint_handler),
    }

    errno := linux.rt_sigaction(.SIGINT, &sa, &linux.Sig_Action(byte){})
    if errno != .NONE {
        panic("ERROR: sigaction")
    }
    fmt.println("Enter a string")

    stream := os.stream_from_handle(os.stdin)
    reader :bufio.Reader
    bufio.reader_init(&reader, stream);

    line, err := bufio.reader_read_string(&reader, '\n')

    if err != .None {
        panic("ERROR: reader reading error")
    }
    fmt.print("You entered:", line)
}
