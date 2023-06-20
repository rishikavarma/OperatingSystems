#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/riscv.h"
#include "kernel/fcntl.h"
#include "kernel/spinlock.h"
#include "kernel/sleeplock.h"
#include "kernel/fs.h"
#include "kernel/file.h"
#include "user/user.h"
#include "kernel/processinfo.h"

int main(){
	struct processinfo p;
	get_process_info(&p);
	printf("Process ID -> %d\n", p.pid);
	printf("Process Name -> %s\n",p.name);
	printf("Memory Size -> %l Bytes\n",p.sz);
	exit(0);
}
