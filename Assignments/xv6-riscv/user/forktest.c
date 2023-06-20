// Test that fork fails gracefully.
// Tiny executable so that the limit can be filling the proc table.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define N  1000

int main(int argc, char **argv){

  int p1, p2, p3;
  int a;
  int c = 0;
  printf("%s\n", argv[1]);

  p1 = fork();

  if (p1 == 0){
     c += 1;
     p2 = fork();

     if (p2 == 0){
        c += 1;
        p3 = fork();
        if (p3 == 0){
	   c += 1;
        }
     }
  }

  wait(&a);
  printf("%d\n", c);
  exit(0);
} 
