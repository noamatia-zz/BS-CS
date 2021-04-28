#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
  if(argc < 3){
    fprintf(2, "usage: trace mask pid...\n");
    exit(1);
  }
  if(trace(atoi(argv[1]), atoi(argv[2])) < 0)
    fprintf(2, "trace: failed to trace\n");
  exit(0);
}