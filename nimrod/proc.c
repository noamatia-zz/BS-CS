#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
int nextktid = 1;
struct spinlock pid_lock;
struct spinlock ktid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);
static void freekthread(struct kthread *kt);
extern void sigretstart(void);
extern void sigretend(void);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each kthread's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  struct kthread *kt;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
      char *kta = kalloc();
      if(kta == 0)
        panic("kalloc");
      uint64 va = KSTACK(NTHREAD * (int) (p - proc) + (int) (kt - p->kthreads));
      kvmmap(kpgtbl, va, (uint64)kta, PGSIZE, PTE_R | PTE_W);
    }
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  struct kthread *kt;
  
  initlock(&ktid_lock, "nextktid");
  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");
      for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
        initlock(&kt->lock, "kthread");
        kt->kstack = KSTACK(NTHREAD * (int) (p - proc) + (int) (kt - p->kthreads));
      }      
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  struct kthread *kt = mythread();

  if(kt != 0)
    return kt->proc;
  return 0;
}

// Return the current struct kthread *, or zero if none.
struct kthread*
mythread(void) {
  push_off();
  struct cpu *c = mycpu();
  struct kthread *kt = c->kthread;
  pop_off();
  return kt;
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

int
allocktid() {
  int ktid;
  
  acquire(&ktid_lock);
  ktid = nextktid;
  nextktid = nextktid + 1;
  release(&ktid_lock);

  return ktid;
}

// Look in the p->kthreads table for an UNUSED kthread.
// If found, initialize state required to run in the kernel,
// and return with kt->lock held.
// If there are no free kthreads, or a memory allocation fails, return 0.
static struct kthread*
allockthread(struct proc* p){
  struct kthread* kt;

  for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++) {
    acquire(&kt->lock);
    if(kt->state == KT_UNUSED) {
      goto found_kthread;
    } else {
      release(&kt->lock);
    }
  }
  return 0;

found_kthread:
  kt->ktid = allocktid();
  kt->state = KT_USED;
  kt->proc = p;
  kt->trapframe = p->kthreads_trapframes + sizeof(struct trapframe) * (kt - p->kthreads);

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&kt->context, 0, sizeof(kt->context));
  kt->context.ra = (uint64)forkret;
  kt->context.sp = kt->kstack + PGSIZE;

  if((kt->user_trapframe_backup = (struct trapframe *)kalloc()) == 0){
    freekthread(kt);
    release(&kt->lock);
    return 0;
  }

  return kt;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  int i;
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->state == P_UNUSED) {
      goto found_proc;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found_proc:
  p->pid = allocpid();
  p->state = P_USED;

  // Allocate memory for kthreads trapframes.
  if((p->kthreads_trapframes = kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  } 

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  p->pending_signals = 0;
  p->signal_mask = 0;
  p->signal_mask_backup = 0;
  for(i = 0; i < NSIGNAL; i++){
    p->sigactions[i].sa_handler = (void*)SIG_DFL;
    p->sigactions[i].sigmask = 0;
  }

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  int i;
  struct kthread* kt;

  for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++) {
    acquire(&kt->lock);
    freekthread(kt);
    release(&kt->lock);
  }

  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = P_UNUSED;
  p->pending_signals = 0;
  p->signal_mask = 0;
  p-> signal_mask_backup = 0;
  for(i = 0; i < NSIGNAL; i++){
    p->sigactions[i].sa_handler = 0;
    p->sigactions[i].sigmask = 0;
  }
}

// free a kthread structure
// kt->lock must be held.
static void
freekthread(struct kthread *kt)
{
  kt->state = KT_UNUSED;
  kt->chan = 0;
  kt->killed = 0;
  kt->xstate = 0;
  kt->ktid = 0;
  if(kt->trapframe)
    kfree((void*)kt->trapframe);
  kt->trapframe = 0;
  if(kt->user_trapframe_backup)
    kfree((void*)kt->user_trapframe_backup);
  kt->user_trapframe_backup = 0;
  kt->name[0] = 0;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->kthreads_trapframes), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  struct kthread* kt;

  p = allocproc();
  kt = allockthread(p);
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  kt->trapframe->epc = 0;      // user program counter
  kt->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  kt->state = KT_RUNNABLE;

  release(&kt->lock);
  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
  struct kthread *kt = mythread(), *nkt;

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // Allocate kthread.
  if((nkt = allockthread(np)) == 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }

  // copy saved user registers.
  *(nkt->trapframe) = *(kt->trapframe);

  // Cause fork to return 0 in the child.
  nkt->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  np->pending_signals = 0;
  np->signal_mask = p->signal_mask;
  for(i = 0; i < NSIGNAL; i++){
    np->sigactions[i].sa_handler = p->sigactions[i].sa_handler;
    np->sigactions[i].sigmask = p->sigactions[i].sigmask;
  }

  release(&np->lock);

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  nkt->state = KT_RUNNABLE;
  release(&nkt->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

int
iskthreadalive(struct kthread *kt)
{
  int isalive;

  acquire(&kt->lock);
  isalive = kt->state != KT_UNUSED && kt->state != KT_ZOMBIE;
  release(&kt->lock);
  return isalive;
}

void
killkthread(struct kthread *kt)
{
  acquire(&kt->lock);
  if(kt->state != KT_UNUSED){
    release(&kt->lock);
    return;
  }
  kt->killed = 1;
  release(&kt->lock);
}

void
wakeupthread(struct kthread *kt)
{
  acquire(&kt->lock);
  if(kt->state == KT_SLEEPING){
    // Wake kthread from sleep().
    kt->state = KT_RUNNABLE;
  }
  release(&kt->lock);
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  int alive_threads = 1;
  struct proc *p = myproc();
  struct kthread *ckt = mythread(), *kt;

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  while(alive_threads){
    alive_threads = 0;
    for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
      if(kt != ckt){
        killkthread(kt);
        wakeupthread(kt);
        if(iskthreadalive(kt))
          alive_threads = 1;
      }
    }   
  }

  kthread_exit(status);

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  
  acquire(&p->lock);
  p->xstate = status;
  p->state = P_ZOMBIE;
  release(&p->lock);

  acquire(&kt->lock);

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == P_ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct kthread *kt;
  struct cpu *c = mycpu();
  
  c->kthread = 0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) {
      if(p->state == P_USED) {
        for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
          acquire(&kt->lock);
          if(kt->state == KT_RUNNABLE){
            // Switch to chosen kthread.  It is the process's job
            // to release its lock and then reacquire it
            // before jumping back to us.
            kt->state = KT_RUNNING;
            c->kthread = kt;
            //TODO switchuvm(p, kt);
            swtch(&c->context, &kt->context);   
            //TODO switchkvm(); 
            c->kthread = 0;    
          }   
          release(&kt->lock);
        }
        // Kthread is done running for now.
        // It should have changed its kt->state before coming back.
         
      }   
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct kthread *kt = mythread();

  if(!holding(&kt->lock))
    panic("sched kt->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(kt->state == KT_RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&kt->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct kthread *kt = mythread();
  acquire(&kt->lock);
  kt->state = KT_RUNNABLE;
  sched();
  release(&kt->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding kt->lock from scheduler.
  release(&mythread()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct kthread *kt = mythread();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&kt->lock);  //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  kt->chan = chan;
  kt->state = KT_SLEEPING;

  sched();

  // Tidy up.
  kt->chan = 0;

  // Reacquire original lock.
  release(&kt->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;
  struct kthread *kt;

  for(p = proc; p < &proc[NPROC]; p++) {
    for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
      if(kt != mythread()){
        acquire(&kt->lock);
        if(kt->state == KT_SLEEPING && kt->chan == chan) {
          kt->state = KT_RUNNABLE;
        }
        release(&kt->lock);
      }
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
//TODO concated kills
int
kill(int pid, int signum)
{
  struct proc *p;

  if(signum < 0 || signum >= NSIGNAL)
    return -1;
  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->pending_signals |= 1 << signum;
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

void
killhandler(void)
{
  struct proc *p = myproc();

  acquire(&p->lock);
  p->killed = 1;
  release(&p->lock);
}

void
stophandler(void)
{
  struct proc *p = myproc();
  int sigcont_founded = 0;

  while(sigcont_founded == 0){
    acquire(&p->lock);
    //TODO sigkill
    if((p->pending_signals & 1 << SIGCONT) == 0){
      release(&p->lock);
      yield();
    }
    else{
      release(&p->lock);
      sigcont_founded = 1;
    }
  }
}

void
conthandler(void){}

void
userspacehandler(int signum)
{
  uint64 length = &sigretend - &sigretstart;
  struct proc *p = myproc();
  struct kthread *kt = mythread();

  acquire(&p->lock);
  acquire(&kt->lock);
  p->signal_mask_backup = p->signal_mask;
  p->signal_mask = p->sigactions[signum].sigmask;
  memmove(kt->user_trapframe_backup, kt->trapframe, sizeof(struct trapframe));
  kt->trapframe->epc = (uint64)p->sigactions[signum].sa_handler;
  kt->trapframe->sp -= length;
  copyout(p->pagetable, kt->trapframe->sp, (char *)&sigretstart, length);
  kt->trapframe->a0 = signum; //TODO why?
  kt->trapframe->ra = kt->trapframe->sp;
  release(&kt->lock);
  release(&p->lock);
}

void
checksignals(void)
{
  int i;
  uint flag, pending_signals, signal_mask;
  void *handler;
  struct proc *p = myproc();

  for(i = 0; i < NSIGNAL; i++){
    acquire(&p->lock);
    pending_signals = p->pending_signals;
    signal_mask = p->signal_mask;
    handler = p->sigactions[i].sa_handler;
    release(&p->lock);
    flag = 1 << i;
    if((pending_signals & flag) && (i == SIGKILL || i == SIGSTOP || !(signal_mask & flag))){
      if(handler != (void *)SIG_IGN){
        if(i == SIGSTOP || handler == (void *)SIGSTOP)
          stophandler();        
        else if(i == SIGCONT || handler == (void *)SIGCONT)
          conthandler();
        else if(i == SIGKILL || handler == (void *)SIGKILL || handler == (void *)SIG_DFL)
          killhandler();
        else{
          acquire(&p->lock);
          p->pending_signals ^= flag;
          release(&p->lock);
          userspacehandler(i); 
          return;
        }
      }
      acquire(&p->lock);
      p->pending_signals ^= flag;
      release(&p->lock);
    }
  }
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [P_UNUSED]    "unused",
  [P_ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == P_UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

uint
sigprocmask(uint sigmask)
{
  uint oldsigmask;
  struct proc *p = myproc();

  acquire(&p->lock);
  oldsigmask = p->signal_mask;
  p->signal_mask = sigmask;
  release(&p->lock);
  return oldsigmask;
}

int
sigaction(int signum, uint64 actaddr, uint64 oldactaddr)
{
  struct proc *p = myproc();
  //TODO acquire?
  if(signum < 0 || signum >= NSIGNAL || signum == SIGKILL || signum == SIGSTOP)
    return -1;
  if(oldactaddr != 0 && copyout(p->pagetable, oldactaddr, (char *)&p->sigactions[signum], sizeof(sigaction)) < 0)
    return -1;
  if(actaddr != 0 && copyin(p->pagetable, (char *)&p->sigactions[signum], actaddr, sizeof(sigaction)) < 0)
    return -1;
  
  return 0;
}

void 
sigret(void)
{
  struct proc *p = myproc();
  struct kthread *kt = mythread();

  acquire(&p->lock);
  acquire(&kt->lock);
  memmove(kt->trapframe, kt->user_trapframe_backup, sizeof(struct trapframe));
  p->signal_mask = p->signal_mask_backup;
  release(&kt->lock);
  release(&p->lock);
}

int
kthread_create (uint64 start_func, uint64 stack)
{
  int ktid;
  struct kthread *kt;
   
  if(start_func == 0 || stack == 0 || (kt = allockthread(myproc())) == 0)
    return -1;
  kt->trapframe->sp = stack + MAX_STACK_SIZE - 16;
  kt->trapframe->epc = start_func;
  ktid = kt->ktid;
  release(&kt->lock);
  return ktid;
}

int
kthread_id(void){
  struct kthread* kt = mythread();

  if(kt == 0)
    return -1;
  return kt->ktid;
}

void
kthread_exit(int status)
{
  int alive_threads = 0;
  struct proc *p = myproc();
  struct kthread *ckt = mythread(), *kt;

  for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
    if(kt != ckt && iskthreadalive(kt)){
      alive_threads = 1;
      break;       
    }
  }

  if(alive_threads == 0)
    exit(status); 

  acquire(&ckt->lock);
  ckt->xstate = status;
  ckt->state = KT_ZOMBIE;
  release(&ckt->lock); 

  for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
    acquire(&kt->lock);
    if(kt->chan == ckt){
      release(&kt->lock); 
      wakeupthread(kt);       
    }
    else
      release(&kt->lock);
  }

  sched();
}

int
kthread_join(int thread_id, uint64 status)
{
  struct proc *p = myproc();
  struct kthread *ckt = mythread(), *kt;

  for(kt = p->kthreads; kt < &p->kthreads[NTHREAD]; kt++){
    acquire(&kt->lock);
    if(kt == ckt && ckt->killed){
      release(&kt->lock);
      return -1;
    }
    else if(kt->ktid == thread_id) {
      goto found_kthread_join;
    } else
      release(&kt->lock);
  }
  return -1;

  found_kthread_join:
  for(;;){
    if(kt->state == KT_ZOMBIE){
      if(status != 0 && copyout(p->pagetable, status, (char *)&kt->xstate, sizeof(kt->xstate)) < 0){
        release(&kt->lock);
        return -1;
      }
      freekthread(kt);
      release(&kt->lock);
      return 0;
    }
    sleep(kt, &kt->lock);
  }
}
