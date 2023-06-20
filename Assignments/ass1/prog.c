#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
	int i;
	for(i = 1; i<argc; i++){
		printf("%s\n", argv[i]);
	}
	exit(0);
}
