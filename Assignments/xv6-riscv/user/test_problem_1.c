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
int main(int argc, char *argv[]){
	if(argc<2){
		printf("Error:Insufficient arguments\n");
		exit(0);
	}
	echo_simple(argv[1]);
	exit(0);
}
