#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

uint64 random(int, int);

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
  printf("exec %s: \n", path);
  char *s, *last;
  int i, off;
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  struct secthdr sh;
  struct elfrel reloc;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
  uint64 instr;
  uint64 load_offset;
  int stack_offset;

  begin_op(ROOTDEV);

  // Get en_aslr flag
  int en_aslr = 0;
  en_aslr = myproc()->aslr_var; 
  
  if(en_aslr)
    printf("ASLR Enabled! \n");
  else
    printf("ASLR Disabled!\n");    
  
  if((ip = namei(path)) == 0){
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    goto bad;

  sz = 0;

  if(en_aslr)
    load_offset = random(0, 1000) << 4;
  else load_offset = 0;
  //load_offset = PGROUNDUP(load_offset);
  printf("load offset: 0x%x\n", load_offset);

  // Read in ELF_PROG_LOAD programs into memory
  sz = uvmalloc(pagetable, 0, load_offset);
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph)) {
      printf("exec: readi error\n");
      goto bad;
    }
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz) {
      printf("exec: memsz smaller than filesz error\n");
      goto bad;
    }
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz + load_offset)) == 0) {
      printf("exec: uvmalloc error\n");
      goto bad;
    }
    if(loadseg(pagetable, ph.vaddr + load_offset, ip, ph.off, ph.filesz) < 0) {
      printf("exec: loadseg error\n");
      goto bad;
    }
  }

  // Get Section Headers
  for(i=0, off = elf.shoff; i < elf.shnum; i++, off += elf.shentsize) {
    if (readi(ip, 0, (uint64)&sh, off, elf.shentsize) != elf.shentsize) 
      goto bad;
    
    int nr = (sh.type ^ 4);
    if (!nr) {
      // found section header for relocations
      // read through each relocation
      for (int sectoff = 0, relocnum = 1; sectoff < sh.size; sectoff += sh.entsize, relocnum++) {
        int size = readi(ip, 0, (uint64)&reloc, sh.offset + sectoff, sh.entsize);

        if((reloc.info&0xffffffffL) == 2 || (reloc.info&0xffffffffL) == 3 || (reloc.info&0xffffffffL) == 5){
          if (copyin(pagetable, (char*)&instr, (uint64)reloc.offset + load_offset, 8) != 0)
            goto bad;
          instr += load_offset;
          if (copyout(pagetable, (uint64)reloc.offset + load_offset, (char*)&instr, 8) != 0)
            goto bad;
        }
        
        if (size != sizeof(struct elfrel))
          goto bad;
      }
    }
  }
  iunlockput(ip);
  end_op(ROOTDEV);
  ip = 0;

  p = myproc();
  uint64 oldsz = p->sz;

  // Allocate random number of pages at the next page boundary.
  // Use the last one as the user stack.
  if(en_aslr)
    stack_offset = random(2, 1000);
  else
    stack_offset = 2;
  sz = PGROUNDUP(sz);
  if((sz = uvmalloc(pagetable, sz, sz + stack_offset*PGSIZE)) == 0)
    goto bad;
  uvmclear(pagetable, sz-stack_offset*PGSIZE);
  sp = sz;
  stackbase = sp - PGSIZE;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    if(sp < stackbase)
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;

  // arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->tf->a1 = sp;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));
    
  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  p->tf->epc = elf.entry + load_offset;  // initial program counter = main
  p->tf->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);
  
  printf("sp: 0x%x\n", r_sp());
  printf("epc: 0x%x\n", p->tf->epc);
  if(en_aslr)
    printf("ASLR is enabled hence epc changes with each run of aslr.\n");
  else
    printf("ASLR is disabled hence epc remains constant.\n");
  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    end_op(ROOTDEV);
  }
  return -1;
}

// Load a program segment into pagetable at virtual address va.
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  // get the positive page offset of the va from the beginning of the page
  uint64 first_va = PGROUNDDOWN(va);
  uint64 pg_offset = va - first_va;

  // manually fill the first page, which might not be page aligned
  pa = walkaddr(pagetable, first_va);
  if (pa == 0)
    panic("loadseg: address should exist");
  // fill page with zeroes
  memset((void*)pa, 0, PGSIZE);
  // fill rest of page
  n = (sz < PGSIZE - pg_offset)? sz : PGSIZE - pg_offset;
  if(readi(ip, 0, (uint64)pa + pg_offset, offset, n) != n)
    return -1;
  offset += n;
  sz -= n;

  // use for loop for remaining pages
  for(i = PGSIZE; sz > 0; i += PGSIZE){
    pa = walkaddr(pagetable, first_va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    // zero the page
    memset((void*)pa, 0, PGSIZE);
    // fill the page or until there are no bytes left to write
    n = (sz < PGSIZE)? sz : PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset, n) != n)
      return -1;
    offset += n;
    sz -= n;
  }
  
  return 0;
}
