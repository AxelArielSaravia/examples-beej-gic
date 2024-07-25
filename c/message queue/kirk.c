#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
    int msgid = msgget(key, IPC_CREAT | 0644);
    if (msgid == -1) {
        perror("msgget");
        exit(1);
    }
    printf("Enter lines of text:\n");

    struct my_msgbuf buf = { .mtype = 1, };

    while (1) {
        char* s = fgets(buf.mtext, sizeof buf.mtext, stdin);
        if (!s) {
            break;
        }
        int len = strlen(buf.mtext);
        if (buf.mtext[len-1] == '\n') {
            buf.mtext[len-1] = '\0';
        }
        if (msgsnd(msgid, &buf, len, 0) == -1) {
            perror("msgsnd");
        }
    }

    if (msgctl(msgid, IPC_RMID, (void*)0) == -1) {
        perror("msgctl");
        exit(1);
    }
    return 0;
}
