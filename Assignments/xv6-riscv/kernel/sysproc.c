#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "stat.h"
#include "fs.h"
#include "sleeplock.h"
#include "file.h"
#include "fcntl.h"
#include "processinfo.h"
uint64
sys_exit(void)
{
   
  int n;
  if(argint(0, &n) < 0)
    return -1;
   int h=1<<2,i; 
   struct proc *pi = myproc();
	i=pi->tra;
   if((h&i)==h){
	printf("arguments: %d\n",n);
  }
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
	
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
   int h=1<<3,i; 
   struct proc *pi = myproc();
	i=pi->tra;
   if((h&i)==h){
	printf("arguments: %p\n",p);
  }
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;
  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  myproc()->sz=myproc()->sz+n;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  int h=1<<13,i; 
   struct proc *pi = myproc();
	i=pi->tra;
   if((h&i)==h){
	printf("arguments: %d\n",n);
  }
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  int h=1<<6,i; 
   struct proc *pi = myproc();
	i=pi->tra;
   if((h&i)==h){
	printf("arguments: %d\n",pid);
  }
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
uint64
sys_echo_simple(void){
	char buf[100];
	if(argstr(0, buf, 100)<0)return -1;
	int h=1<<22,i; 
	struct proc *pi = myproc();
	i=pi->tra;
	if((h&i)==h){
		printf("arguments: %s\n",buf);
	}
	printf("%s\n", buf);
	return 0;

}
uint64
sys_echo_kernel(void){
	int n;
	uint64 uargv;
	char buf[100];
	if(argaddr(1,&uargv)<0||argint(0, &n)<0)return -1;
	int h=1<<23,i; 
	struct proc *pi = myproc();
	i=pi->tra;
	if((h&i)==h){
		printf("arguments: %d %p\n",n,uargv);
	}
	for(int i=1;i<n;i++){
		fetchstr(uargv-i*16,buf,100);
		printf("%s ", buf);
	}
	printf("\n");
	return 0;

}
uint64
sys_get_process_info(void){
	uint64 uargv;
	if(argaddr(0,&uargv)<0)return -1;
	int h=1<<24,i; 
	struct proc *pi = myproc();
	i=pi->tra;
	if((h&i)==h){
		printf("arguments: %p\n",uargv);
	}
	struct processinfo pf;
	struct proc *p = myproc();
	pf.pid=p->pid;
	pf.sz=p->sz;
	strncpy(pf.name,p->name,16);
	if(copyout(p->pagetable, uargv, (char *)&pf, sizeof(pf)) < 0)return -1;
	return 0;

}
uint64
sys_trace(void){
	int n;
	struct proc*p=myproc();
	if(argint(0, &n)<0)return -1;
	p->tra=n;
	int h=1<<25,i; 
	i=p->tra;
	if((h&i)==h){
		printf("arguments: %d\n",n);
	}
	return 0;
}


