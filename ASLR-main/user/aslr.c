#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  aslr();
  exec(argv[1], (argv+1));
  exit(0);
}
