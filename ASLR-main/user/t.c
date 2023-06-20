#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int temp() {
	printf("Tester function for ASLR\n");
	return 1;
}

int main()
{
	if(temp() != 1)
		exit(1);

	int fds[2];
  
  	if(pipe(fds) != 0){
    	printf("pipe() failed\n");
    	exit(1);
  	}
  	else printf("pipe() passed\n");

  	int pid = fork();
  	printf("fork() passed : %d\n", pid);

    printf("Congrats! Qemu lives! \n");
    exit(0);
}
