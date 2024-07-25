#include <stdio.h>
#include <stdlib.h>
#include <sys/msg.h>

struct my_msgbuf {
    long mtype;
    char mtext[200];
};

int main() {
    key_t key = ftok("kirk.c", 'a');
    if (key == -1) {
        perror("ftok");
        exit(1);
    }
    int msqid = msgget(key, 0644);
    if (msqid == -1) {
        perror("msgget");
        exit(1);
    }
    printf("spock: ready to receive messages, captain.\n");

    struct my_msgbuf buf = {0};
    for (;;) {
        if (msgrcv(msqid, &buf, sizeof buf.mtext, 0, 0) == -1) {
            perror("msgrcv");
            exit(1);
        }
        printf("spock: \"%s\"\n", buf.mtext);
    }
    return 0;
}
