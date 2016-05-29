
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 1e 33 f0 00 	cmpl   $0x0,0xf0331e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 1e 33 f0    	mov    %esi,0xf0331e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 b4 66 00 00       	call   f0106718 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 e0 6d 10 f0 	movl   $0xf0106de0,(%esp)
f010007d:	e8 04 3f 00 00       	call   f0103f86 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 c5 3e 00 00       	call   f0103f53 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 3f 80 10 f0 	movl   $0xf010803f,(%esp)
f0100095:	e8 ec 3e 00 00       	call   f0103f86 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 a9 08 00 00       	call   f010094f <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 4b 6e 10 f0 	movl   $0xf0106e4b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 31 66 00 00       	call   f0106718 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 57 6e 10 f0 	movl   $0xf0106e57,(%esp)
f01000f2:	e8 8f 3e 00 00       	call   f0103f86 <cprintf>

	lapic_init();
f01000f7:	e8 37 66 00 00       	call   f0106733 <lapic_init>
	env_init_percpu();
f01000fc:	e8 bf 35 00 00       	call   f01036c0 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 9a 3e 00 00       	call   f0103fa0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 0d 66 00 00       	call   f0106718 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 20 33 f0    	add    $0xf0332020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100124:	e8 ae 68 00 00       	call   f01069d7 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();	
	sched_yield();
f0100129:	e8 0c 4c 00 00       	call   f0104d3a <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100135:	b8 08 30 37 f0       	mov    $0xf0373008,%eax
f010013a:	2d 2e 00 33 f0       	sub    $0xf033002e,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 2e 00 33 f0 	movl   $0xf033002e,(%esp)
f0100152:	e8 93 5f 00 00       	call   f01060ea <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 03 05 00 00       	call   f010065f <cons_init>

	//cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
	mem_init();
f010015c:	e8 b8 12 00 00       	call   f0101419 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100161:	e8 84 35 00 00       	call   f01036ea <env_init>
	trap_init();
f0100166:	e8 38 3f 00 00       	call   f01040a3 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010016b:	e8 c0 62 00 00       	call   f0106430 <mp_init>
	lapic_init();
f0100170:	e8 be 65 00 00       	call   f0106733 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100175:	e8 62 3d 00 00       	call   f0103edc <pic_init>
f010017a:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100181:	e8 51 68 00 00       	call   f01069d7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100186:	83 3d 88 1e 33 f0 07 	cmpl   $0x7,0xf0331e88
f010018d:	77 24                	ja     f01001b3 <i386_init+0x85>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010018f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100196:	00 
f0100197:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f010019e:	f0 
f010019f:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01001a6:	00 
f01001a7:	c7 04 24 4b 6e 10 f0 	movl   $0xf0106e4b,(%esp)
f01001ae:	e8 8d fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001b3:	b8 5a 63 10 f0       	mov    $0xf010635a,%eax
f01001b8:	2d e0 62 10 f0       	sub    $0xf01062e0,%eax
f01001bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001c1:	c7 44 24 04 e0 62 10 	movl   $0xf01062e0,0x4(%esp)
f01001c8:	f0 
f01001c9:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001d0:	e8 5f 5f 00 00       	call   f0106134 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001d5:	bb 20 20 33 f0       	mov    $0xf0332020,%ebx
f01001da:	eb 6f                	jmp    f010024b <i386_init+0x11d>
		if (c == cpus + cpunum())  // We've started already.
f01001dc:	e8 37 65 00 00       	call   f0106718 <cpunum>
f01001e1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001e8:	29 c2                	sub    %eax,%edx
f01001ea:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001ed:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f01001f4:	39 c3                	cmp    %eax,%ebx
f01001f6:	74 50                	je     f0100248 <i386_init+0x11a>

static void boot_aps(void);


void
i386_init(void)
f01001f8:	89 d8                	mov    %ebx,%eax
f01001fa:	2d 20 20 33 f0       	sub    $0xf0332020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001ff:	c1 f8 02             	sar    $0x2,%eax
f0100202:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0100205:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0100208:	89 d1                	mov    %edx,%ecx
f010020a:	c1 e1 05             	shl    $0x5,%ecx
f010020d:	29 d1                	sub    %edx,%ecx
f010020f:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100212:	89 d1                	mov    %edx,%ecx
f0100214:	c1 e1 0e             	shl    $0xe,%ecx
f0100217:	29 d1                	sub    %edx,%ecx
f0100219:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f010021c:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100220:	c1 e0 0f             	shl    $0xf,%eax
f0100223:	05 00 30 33 f0       	add    $0xf0333000,%eax
f0100228:	a3 84 1e 33 f0       	mov    %eax,0xf0331e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010022d:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100234:	00 
f0100235:	0f b6 03             	movzbl (%ebx),%eax
f0100238:	89 04 24             	mov    %eax,(%esp)
f010023b:	e8 4c 66 00 00       	call   f010688c <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100240:	8b 43 04             	mov    0x4(%ebx),%eax
f0100243:	83 f8 01             	cmp    $0x1,%eax
f0100246:	75 f8                	jne    f0100240 <i386_init+0x112>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100248:	83 c3 74             	add    $0x74,%ebx
f010024b:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f0100250:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100257:	29 c2                	sub    %eax,%edx
f0100259:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010025c:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0100263:	39 c3                	cmp    %eax,%ebx
f0100265:	0f 82 71 ff ff ff    	jb     f01001dc <i386_init+0xae>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010026b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100272:	00 
f0100273:	c7 04 24 90 e5 31 f0 	movl   $0xf031e590,(%esp)
f010027a:	e8 9b 36 00 00       	call   f010391a <env_create>
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f010027f:	e8 b6 4a 00 00       	call   f0104d3a <sched_yield>

f0100284 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100284:	55                   	push   %ebp
f0100285:	89 e5                	mov    %esp,%ebp
f0100287:	53                   	push   %ebx
f0100288:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010028b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100291:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100295:	8b 45 08             	mov    0x8(%ebp),%eax
f0100298:	89 44 24 04          	mov    %eax,0x4(%esp)
f010029c:	c7 04 24 6d 6e 10 f0 	movl   $0xf0106e6d,(%esp)
f01002a3:	e8 de 3c 00 00       	call   f0103f86 <cprintf>
	vcprintf(fmt, ap);
f01002a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01002af:	89 04 24             	mov    %eax,(%esp)
f01002b2:	e8 9c 3c 00 00       	call   f0103f53 <vcprintf>
	cprintf("\n");
f01002b7:	c7 04 24 3f 80 10 f0 	movl   $0xf010803f,(%esp)
f01002be:	e8 c3 3c 00 00       	call   f0103f86 <cprintf>
	va_end(ap);
}
f01002c3:	83 c4 14             	add    $0x14,%esp
f01002c6:	5b                   	pop    %ebx
f01002c7:	5d                   	pop    %ebp
f01002c8:	c3                   	ret    
f01002c9:	00 00                	add    %al,(%eax)
	...

f01002cc <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002cc:	55                   	push   %ebp
f01002cd:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cf:	ba 84 00 00 00       	mov    $0x84,%edx
f01002d4:	ec                   	in     (%dx),%al
f01002d5:	ec                   	in     (%dx),%al
f01002d6:	ec                   	in     (%dx),%al
f01002d7:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002d8:	5d                   	pop    %ebp
f01002d9:	c3                   	ret    

f01002da <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002da:	55                   	push   %ebp
f01002db:	89 e5                	mov    %esp,%ebp
f01002dd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002e3:	a8 01                	test   $0x1,%al
f01002e5:	74 08                	je     f01002ef <serial_proc_data+0x15>
f01002e7:	b2 f8                	mov    $0xf8,%dl
f01002e9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002ea:	0f b6 c0             	movzbl %al,%eax
f01002ed:	eb 05                	jmp    f01002f4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002f4:	5d                   	pop    %ebp
f01002f5:	c3                   	ret    

f01002f6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002f6:	55                   	push   %ebp
f01002f7:	89 e5                	mov    %esp,%ebp
f01002f9:	53                   	push   %ebx
f01002fa:	83 ec 04             	sub    $0x4,%esp
f01002fd:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002ff:	eb 29                	jmp    f010032a <cons_intr+0x34>
		if (c == 0)
f0100301:	85 c0                	test   %eax,%eax
f0100303:	74 25                	je     f010032a <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100305:	8b 15 24 12 33 f0    	mov    0xf0331224,%edx
f010030b:	88 82 20 10 33 f0    	mov    %al,-0xfccefe0(%edx)
f0100311:	8d 42 01             	lea    0x1(%edx),%eax
f0100314:	a3 24 12 33 f0       	mov    %eax,0xf0331224
		if (cons.wpos == CONSBUFSIZE)
f0100319:	3d 00 02 00 00       	cmp    $0x200,%eax
f010031e:	75 0a                	jne    f010032a <cons_intr+0x34>
			cons.wpos = 0;
f0100320:	c7 05 24 12 33 f0 00 	movl   $0x0,0xf0331224
f0100327:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010032a:	ff d3                	call   *%ebx
f010032c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010032f:	75 d0                	jne    f0100301 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100331:	83 c4 04             	add    $0x4,%esp
f0100334:	5b                   	pop    %ebx
f0100335:	5d                   	pop    %ebp
f0100336:	c3                   	ret    

f0100337 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	57                   	push   %edi
f010033b:	56                   	push   %esi
f010033c:	53                   	push   %ebx
f010033d:	83 ec 2c             	sub    $0x2c,%esp
f0100340:	89 c6                	mov    %eax,%esi
f0100342:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100347:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010034c:	eb 05                	jmp    f0100353 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010034e:	e8 79 ff ff ff       	call   f01002cc <delay>
f0100353:	89 fa                	mov    %edi,%edx
f0100355:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100356:	a8 20                	test   $0x20,%al
f0100358:	75 03                	jne    f010035d <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010035a:	4b                   	dec    %ebx
f010035b:	75 f1                	jne    f010034e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010035d:	89 f2                	mov    %esi,%edx
f010035f:	89 f0                	mov    %esi,%eax
f0100361:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100364:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100369:	ee                   	out    %al,(%dx)
f010036a:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010036f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100374:	eb 05                	jmp    f010037b <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100376:	e8 51 ff ff ff       	call   f01002cc <delay>
f010037b:	89 fa                	mov    %edi,%edx
f010037d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010037e:	84 c0                	test   %al,%al
f0100380:	78 03                	js     f0100385 <cons_putc+0x4e>
f0100382:	4b                   	dec    %ebx
f0100383:	75 f1                	jne    f0100376 <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	ba 78 03 00 00       	mov    $0x378,%edx
f010038a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010038d:	ee                   	out    %al,(%dx)
f010038e:	b2 7a                	mov    $0x7a,%dl
f0100390:	b0 0d                	mov    $0xd,%al
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b0 08                	mov    $0x8,%al
f0100395:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100396:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010039c:	75 06                	jne    f01003a4 <cons_putc+0x6d>
		c |= 0x0700;
f010039e:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003a4:	89 f0                	mov    %esi,%eax
f01003a6:	25 ff 00 00 00       	and    $0xff,%eax
f01003ab:	83 f8 09             	cmp    $0x9,%eax
f01003ae:	74 78                	je     f0100428 <cons_putc+0xf1>
f01003b0:	83 f8 09             	cmp    $0x9,%eax
f01003b3:	7f 0b                	jg     f01003c0 <cons_putc+0x89>
f01003b5:	83 f8 08             	cmp    $0x8,%eax
f01003b8:	0f 85 9e 00 00 00    	jne    f010045c <cons_putc+0x125>
f01003be:	eb 10                	jmp    f01003d0 <cons_putc+0x99>
f01003c0:	83 f8 0a             	cmp    $0xa,%eax
f01003c3:	74 39                	je     f01003fe <cons_putc+0xc7>
f01003c5:	83 f8 0d             	cmp    $0xd,%eax
f01003c8:	0f 85 8e 00 00 00    	jne    f010045c <cons_putc+0x125>
f01003ce:	eb 36                	jmp    f0100406 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003d0:	66 a1 34 12 33 f0    	mov    0xf0331234,%ax
f01003d6:	66 85 c0             	test   %ax,%ax
f01003d9:	0f 84 e2 00 00 00    	je     f01004c1 <cons_putc+0x18a>
			crt_pos--;
f01003df:	48                   	dec    %eax
f01003e0:	66 a3 34 12 33 f0    	mov    %ax,0xf0331234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003e6:	0f b7 c0             	movzwl %ax,%eax
f01003e9:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01003ef:	83 ce 20             	or     $0x20,%esi
f01003f2:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
f01003f8:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01003fc:	eb 78                	jmp    f0100476 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003fe:	66 83 05 34 12 33 f0 	addw   $0x50,0xf0331234
f0100405:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100406:	66 8b 0d 34 12 33 f0 	mov    0xf0331234,%cx
f010040d:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100412:	89 c8                	mov    %ecx,%eax
f0100414:	ba 00 00 00 00       	mov    $0x0,%edx
f0100419:	66 f7 f3             	div    %bx
f010041c:	66 29 d1             	sub    %dx,%cx
f010041f:	66 89 0d 34 12 33 f0 	mov    %cx,0xf0331234
f0100426:	eb 4e                	jmp    f0100476 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100428:	b8 20 00 00 00       	mov    $0x20,%eax
f010042d:	e8 05 ff ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100432:	b8 20 00 00 00       	mov    $0x20,%eax
f0100437:	e8 fb fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f010043c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100441:	e8 f1 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 e7 fe ff ff       	call   f0100337 <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 dd fe ff ff       	call   f0100337 <cons_putc>
f010045a:	eb 1a                	jmp    f0100476 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010045c:	66 a1 34 12 33 f0    	mov    0xf0331234,%ax
f0100462:	0f b7 c8             	movzwl %ax,%ecx
f0100465:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
f010046b:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010046f:	40                   	inc    %eax
f0100470:	66 a3 34 12 33 f0    	mov    %ax,0xf0331234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100476:	66 81 3d 34 12 33 f0 	cmpw   $0x7cf,0xf0331234
f010047d:	cf 07 
f010047f:	76 40                	jbe    f01004c1 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100481:	a1 30 12 33 f0       	mov    0xf0331230,%eax
f0100486:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010048d:	00 
f010048e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100494:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100498:	89 04 24             	mov    %eax,(%esp)
f010049b:	e8 94 5c 00 00       	call   f0106134 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004a0:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a6:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004ab:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b1:	40                   	inc    %eax
f01004b2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004b7:	75 f2                	jne    f01004ab <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004b9:	66 83 2d 34 12 33 f0 	subw   $0x50,0xf0331234
f01004c0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c1:	8b 0d 2c 12 33 f0    	mov    0xf033122c,%ecx
f01004c7:	b0 0e                	mov    $0xe,%al
f01004c9:	89 ca                	mov    %ecx,%edx
f01004cb:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004cc:	66 8b 35 34 12 33 f0 	mov    0xf0331234,%si
f01004d3:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004d6:	89 f0                	mov    %esi,%eax
f01004d8:	66 c1 e8 08          	shr    $0x8,%ax
f01004dc:	89 da                	mov    %ebx,%edx
f01004de:	ee                   	out    %al,(%dx)
f01004df:	b0 0f                	mov    $0xf,%al
f01004e1:	89 ca                	mov    %ecx,%edx
f01004e3:	ee                   	out    %al,(%dx)
f01004e4:	89 f0                	mov    %esi,%eax
f01004e6:	89 da                	mov    %ebx,%edx
f01004e8:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e9:	83 c4 2c             	add    $0x2c,%esp
f01004ec:	5b                   	pop    %ebx
f01004ed:	5e                   	pop    %esi
f01004ee:	5f                   	pop    %edi
f01004ef:	5d                   	pop    %ebp
f01004f0:	c3                   	ret    

f01004f1 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004f1:	55                   	push   %ebp
f01004f2:	89 e5                	mov    %esp,%ebp
f01004f4:	53                   	push   %ebx
f01004f5:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004f8:	ba 64 00 00 00       	mov    $0x64,%edx
f01004fd:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01004fe:	a8 01                	test   $0x1,%al
f0100500:	0f 84 d8 00 00 00    	je     f01005de <kbd_proc_data+0xed>
f0100506:	b2 60                	mov    $0x60,%dl
f0100508:	ec                   	in     (%dx),%al
f0100509:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010050b:	3c e0                	cmp    $0xe0,%al
f010050d:	75 11                	jne    f0100520 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010050f:	83 0d 28 12 33 f0 40 	orl    $0x40,0xf0331228
		return 0;
f0100516:	bb 00 00 00 00       	mov    $0x0,%ebx
f010051b:	e9 c3 00 00 00       	jmp    f01005e3 <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100520:	84 c0                	test   %al,%al
f0100522:	79 33                	jns    f0100557 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100524:	8b 0d 28 12 33 f0    	mov    0xf0331228,%ecx
f010052a:	f6 c1 40             	test   $0x40,%cl
f010052d:	75 05                	jne    f0100534 <kbd_proc_data+0x43>
f010052f:	88 c2                	mov    %al,%dl
f0100531:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100534:	0f b6 d2             	movzbl %dl,%edx
f0100537:	8a 82 c0 6e 10 f0    	mov    -0xfef9140(%edx),%al
f010053d:	83 c8 40             	or     $0x40,%eax
f0100540:	0f b6 c0             	movzbl %al,%eax
f0100543:	f7 d0                	not    %eax
f0100545:	21 c1                	and    %eax,%ecx
f0100547:	89 0d 28 12 33 f0    	mov    %ecx,0xf0331228
		return 0;
f010054d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100552:	e9 8c 00 00 00       	jmp    f01005e3 <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f0100557:	8b 0d 28 12 33 f0    	mov    0xf0331228,%ecx
f010055d:	f6 c1 40             	test   $0x40,%cl
f0100560:	74 0e                	je     f0100570 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100562:	88 c2                	mov    %al,%dl
f0100564:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100567:	83 e1 bf             	and    $0xffffffbf,%ecx
f010056a:	89 0d 28 12 33 f0    	mov    %ecx,0xf0331228
	}

	shift |= shiftcode[data];
f0100570:	0f b6 d2             	movzbl %dl,%edx
f0100573:	0f b6 82 c0 6e 10 f0 	movzbl -0xfef9140(%edx),%eax
f010057a:	0b 05 28 12 33 f0    	or     0xf0331228,%eax
	shift ^= togglecode[data];
f0100580:	0f b6 8a c0 6f 10 f0 	movzbl -0xfef9040(%edx),%ecx
f0100587:	31 c8                	xor    %ecx,%eax
f0100589:	a3 28 12 33 f0       	mov    %eax,0xf0331228

	c = charcode[shift & (CTL | SHIFT)][data];
f010058e:	89 c1                	mov    %eax,%ecx
f0100590:	83 e1 03             	and    $0x3,%ecx
f0100593:	8b 0c 8d c0 70 10 f0 	mov    -0xfef8f40(,%ecx,4),%ecx
f010059a:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010059e:	a8 08                	test   $0x8,%al
f01005a0:	74 18                	je     f01005ba <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005a2:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005a5:	83 fa 19             	cmp    $0x19,%edx
f01005a8:	77 05                	ja     f01005af <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005aa:	83 eb 20             	sub    $0x20,%ebx
f01005ad:	eb 0b                	jmp    f01005ba <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005af:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005b2:	83 fa 19             	cmp    $0x19,%edx
f01005b5:	77 03                	ja     f01005ba <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005b7:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005ba:	f7 d0                	not    %eax
f01005bc:	a8 06                	test   $0x6,%al
f01005be:	75 23                	jne    f01005e3 <kbd_proc_data+0xf2>
f01005c0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005c6:	75 1b                	jne    f01005e3 <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f01005c8:	c7 04 24 87 6e 10 f0 	movl   $0xf0106e87,(%esp)
f01005cf:	e8 b2 39 00 00       	call   f0103f86 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d4:	ba 92 00 00 00       	mov    $0x92,%edx
f01005d9:	b0 03                	mov    $0x3,%al
f01005db:	ee                   	out    %al,(%dx)
f01005dc:	eb 05                	jmp    f01005e3 <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01005de:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005e3:	89 d8                	mov    %ebx,%eax
f01005e5:	83 c4 14             	add    $0x14,%esp
f01005e8:	5b                   	pop    %ebx
f01005e9:	5d                   	pop    %ebp
f01005ea:	c3                   	ret    

f01005eb <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005eb:	55                   	push   %ebp
f01005ec:	89 e5                	mov    %esp,%ebp
f01005ee:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01005f1:	80 3d 00 10 33 f0 00 	cmpb   $0x0,0xf0331000
f01005f8:	74 0a                	je     f0100604 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01005fa:	b8 da 02 10 f0       	mov    $0xf01002da,%eax
f01005ff:	e8 f2 fc ff ff       	call   f01002f6 <cons_intr>
}
f0100604:	c9                   	leave  
f0100605:	c3                   	ret    

f0100606 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100606:	55                   	push   %ebp
f0100607:	89 e5                	mov    %esp,%ebp
f0100609:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010060c:	b8 f1 04 10 f0       	mov    $0xf01004f1,%eax
f0100611:	e8 e0 fc ff ff       	call   f01002f6 <cons_intr>
}
f0100616:	c9                   	leave  
f0100617:	c3                   	ret    

f0100618 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100618:	55                   	push   %ebp
f0100619:	89 e5                	mov    %esp,%ebp
f010061b:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010061e:	e8 c8 ff ff ff       	call   f01005eb <serial_intr>
	kbd_intr();
f0100623:	e8 de ff ff ff       	call   f0100606 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100628:	8b 15 20 12 33 f0    	mov    0xf0331220,%edx
f010062e:	3b 15 24 12 33 f0    	cmp    0xf0331224,%edx
f0100634:	74 22                	je     f0100658 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100636:	0f b6 82 20 10 33 f0 	movzbl -0xfccefe0(%edx),%eax
f010063d:	42                   	inc    %edx
f010063e:	89 15 20 12 33 f0    	mov    %edx,0xf0331220
		if (cons.rpos == CONSBUFSIZE)
f0100644:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010064a:	75 11                	jne    f010065d <cons_getc+0x45>
			cons.rpos = 0;
f010064c:	c7 05 20 12 33 f0 00 	movl   $0x0,0xf0331220
f0100653:	00 00 00 
f0100656:	eb 05                	jmp    f010065d <cons_getc+0x45>
		return c;
	}
	return 0;
f0100658:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010065d:	c9                   	leave  
f010065e:	c3                   	ret    

f010065f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010065f:	55                   	push   %ebp
f0100660:	89 e5                	mov    %esp,%ebp
f0100662:	57                   	push   %edi
f0100663:	56                   	push   %esi
f0100664:	53                   	push   %ebx
f0100665:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100668:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010066f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100676:	5a a5 
	if (*cp != 0xA55A) {
f0100678:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010067e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100682:	74 11                	je     f0100695 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100684:	c7 05 2c 12 33 f0 b4 	movl   $0x3b4,0xf033122c
f010068b:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010068e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100693:	eb 16                	jmp    f01006ab <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100695:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069c:	c7 05 2c 12 33 f0 d4 	movl   $0x3d4,0xf033122c
f01006a3:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006ab:	8b 0d 2c 12 33 f0    	mov    0xf033122c,%ecx
f01006b1:	b0 0e                	mov    $0xe,%al
f01006b3:	89 ca                	mov    %ecx,%edx
f01006b5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b6:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b9:	89 da                	mov    %ebx,%edx
f01006bb:	ec                   	in     (%dx),%al
f01006bc:	0f b6 f8             	movzbl %al,%edi
f01006bf:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c2:	b0 0f                	mov    $0xf,%al
f01006c4:	89 ca                	mov    %ecx,%edx
f01006c6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c7:	89 da                	mov    %ebx,%edx
f01006c9:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ca:	89 35 30 12 33 f0    	mov    %esi,0xf0331230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006d0:	0f b6 d8             	movzbl %al,%ebx
f01006d3:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006d5:	66 89 3d 34 12 33 f0 	mov    %di,0xf0331234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006dc:	e8 25 ff ff ff       	call   f0100606 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006e1:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f01006e8:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ed:	89 04 24             	mov    %eax,(%esp)
f01006f0:	e8 73 37 00 00       	call   f0103e68 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f5:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006fa:	b0 00                	mov    $0x0,%al
f01006fc:	89 da                	mov    %ebx,%edx
f01006fe:	ee                   	out    %al,(%dx)
f01006ff:	b2 fb                	mov    $0xfb,%dl
f0100701:	b0 80                	mov    $0x80,%al
f0100703:	ee                   	out    %al,(%dx)
f0100704:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100709:	b0 0c                	mov    $0xc,%al
f010070b:	89 ca                	mov    %ecx,%edx
f010070d:	ee                   	out    %al,(%dx)
f010070e:	b2 f9                	mov    $0xf9,%dl
f0100710:	b0 00                	mov    $0x0,%al
f0100712:	ee                   	out    %al,(%dx)
f0100713:	b2 fb                	mov    $0xfb,%dl
f0100715:	b0 03                	mov    $0x3,%al
f0100717:	ee                   	out    %al,(%dx)
f0100718:	b2 fc                	mov    $0xfc,%dl
f010071a:	b0 00                	mov    $0x0,%al
f010071c:	ee                   	out    %al,(%dx)
f010071d:	b2 f9                	mov    $0xf9,%dl
f010071f:	b0 01                	mov    $0x1,%al
f0100721:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100722:	b2 fd                	mov    $0xfd,%dl
f0100724:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100725:	3c ff                	cmp    $0xff,%al
f0100727:	0f 95 45 e7          	setne  -0x19(%ebp)
f010072b:	8a 45 e7             	mov    -0x19(%ebp),%al
f010072e:	a2 00 10 33 f0       	mov    %al,0xf0331000
f0100733:	89 da                	mov    %ebx,%edx
f0100735:	ec                   	in     (%dx),%al
f0100736:	89 ca                	mov    %ecx,%edx
f0100738:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100739:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010073d:	75 0c                	jne    f010074b <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f010073f:	c7 04 24 93 6e 10 f0 	movl   $0xf0106e93,(%esp)
f0100746:	e8 3b 38 00 00       	call   f0103f86 <cprintf>
}
f010074b:	83 c4 2c             	add    $0x2c,%esp
f010074e:	5b                   	pop    %ebx
f010074f:	5e                   	pop    %esi
f0100750:	5f                   	pop    %edi
f0100751:	5d                   	pop    %ebp
f0100752:	c3                   	ret    

f0100753 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100753:	55                   	push   %ebp
f0100754:	89 e5                	mov    %esp,%ebp
f0100756:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100759:	8b 45 08             	mov    0x8(%ebp),%eax
f010075c:	e8 d6 fb ff ff       	call   f0100337 <cons_putc>
}
f0100761:	c9                   	leave  
f0100762:	c3                   	ret    

f0100763 <getchar>:

int
getchar(void)
{
f0100763:	55                   	push   %ebp
f0100764:	89 e5                	mov    %esp,%ebp
f0100766:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100769:	e8 aa fe ff ff       	call   f0100618 <cons_getc>
f010076e:	85 c0                	test   %eax,%eax
f0100770:	74 f7                	je     f0100769 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100772:	c9                   	leave  
f0100773:	c3                   	ret    

f0100774 <iscons>:

int
iscons(int fdnum)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100777:	b8 01 00 00 00       	mov    $0x1,%eax
f010077c:	5d                   	pop    %ebp
f010077d:	c3                   	ret    
	...

f0100780 <continue_exec>:

/***** Implementations of basic kernel monitor commands *****/

int
continue_exec(int argc, char **argv, struct Trapframe *tf)
{
f0100780:	55                   	push   %ebp
f0100781:	89 e5                	mov    %esp,%ebp
f0100783:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags &= ~FL_TF;
f0100786:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	    return -1;
}
f010078d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100792:	5d                   	pop    %ebp
f0100793:	c3                   	ret    

f0100794 <single_step>:

int
single_step(int argc, char **argv, struct Trapframe *tf)
{
f0100794:	55                   	push   %ebp
f0100795:	89 e5                	mov    %esp,%ebp
f0100797:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags |= FL_TF;
f010079a:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
		return -1;
}
f01007a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007a6:	5d                   	pop    %ebp
f01007a7:	c3                   	ret    

f01007a8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a8:	55                   	push   %ebp
f01007a9:	89 e5                	mov    %esp,%ebp
f01007ab:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ae:	c7 04 24 d0 70 10 f0 	movl   $0xf01070d0,(%esp)
f01007b5:	e8 cc 37 00 00       	call   f0103f86 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ba:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007c1:	00 
f01007c2:	c7 04 24 b0 71 10 f0 	movl   $0xf01071b0,(%esp)
f01007c9:	e8 b8 37 00 00       	call   f0103f86 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ce:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007d5:	00 
f01007d6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007dd:	f0 
f01007de:	c7 04 24 d8 71 10 f0 	movl   $0xf01071d8,(%esp)
f01007e5:	e8 9c 37 00 00       	call   f0103f86 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ea:	c7 44 24 08 d6 6d 10 	movl   $0x106dd6,0x8(%esp)
f01007f1:	00 
f01007f2:	c7 44 24 04 d6 6d 10 	movl   $0xf0106dd6,0x4(%esp)
f01007f9:	f0 
f01007fa:	c7 04 24 fc 71 10 f0 	movl   $0xf01071fc,(%esp)
f0100801:	e8 80 37 00 00       	call   f0103f86 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100806:	c7 44 24 08 2e 00 33 	movl   $0x33002e,0x8(%esp)
f010080d:	00 
f010080e:	c7 44 24 04 2e 00 33 	movl   $0xf033002e,0x4(%esp)
f0100815:	f0 
f0100816:	c7 04 24 20 72 10 f0 	movl   $0xf0107220,(%esp)
f010081d:	e8 64 37 00 00       	call   f0103f86 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100822:	c7 44 24 08 08 30 37 	movl   $0x373008,0x8(%esp)
f0100829:	00 
f010082a:	c7 44 24 04 08 30 37 	movl   $0xf0373008,0x4(%esp)
f0100831:	f0 
f0100832:	c7 04 24 44 72 10 f0 	movl   $0xf0107244,(%esp)
f0100839:	e8 48 37 00 00       	call   f0103f86 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010083e:	b8 07 34 37 f0       	mov    $0xf0373407,%eax
f0100843:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100848:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084d:	89 c2                	mov    %eax,%edx
f010084f:	85 c0                	test   %eax,%eax
f0100851:	79 06                	jns    f0100859 <mon_kerninfo+0xb1>
f0100853:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100859:	c1 fa 0a             	sar    $0xa,%edx
f010085c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100860:	c7 04 24 68 72 10 f0 	movl   $0xf0107268,(%esp)
f0100867:	e8 1a 37 00 00       	call   f0103f86 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010086c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100871:	c9                   	leave  
f0100872:	c3                   	ret    

f0100873 <mon_help>:
		return -1;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100873:	55                   	push   %ebp
f0100874:	89 e5                	mov    %esp,%ebp
f0100876:	53                   	push   %ebx
f0100877:	83 ec 14             	sub    $0x14,%esp
f010087a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010087f:	8b 83 84 73 10 f0    	mov    -0xfef8c7c(%ebx),%eax
f0100885:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100889:	8b 83 80 73 10 f0    	mov    -0xfef8c80(%ebx),%eax
f010088f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100893:	c7 04 24 e9 70 10 f0 	movl   $0xf01070e9,(%esp)
f010089a:	e8 e7 36 00 00       	call   f0103f86 <cprintf>
f010089f:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008a2:	83 fb 3c             	cmp    $0x3c,%ebx
f01008a5:	75 d8                	jne    f010087f <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ac:	83 c4 14             	add    $0x14,%esp
f01008af:	5b                   	pop    %ebx
f01008b0:	5d                   	pop    %ebp
f01008b1:	c3                   	ret    

f01008b2 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b2:	55                   	push   %ebp
f01008b3:	89 e5                	mov    %esp,%ebp
f01008b5:	57                   	push   %edi
f01008b6:	56                   	push   %esi
f01008b7:	53                   	push   %ebx
f01008b8:	83 ec 6c             	sub    $0x6c,%esp
	// Your code here.
	
	int bt_cnt = 0;
	struct Eipdebuginfo eip_info;
	int* pre_ebp = (int *)read_ebp();
f01008bb:	89 eb                	mov    %ebp,%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
f01008bd:	c7 04 24 f2 70 10 f0 	movl   $0xf01070f2,(%esp)
f01008c4:	e8 bd 36 00 00       	call   f0103f86 <cprintf>
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	int bt_cnt = 0;
f01008c9:	bf 00 00 00 00       	mov    $0x0,%edi
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f01008ce:	eb 71                	jmp    f0100941 <mon_backtrace+0x8f>
		bt_cnt++;
f01008d0:	47                   	inc    %edi
		eip = (int)*(pre_ebp+1);
f01008d1:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip((uintptr_t)eip, &eip_info);
f01008d4:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008db:	89 34 24             	mov    %esi,(%esp)
f01008de:	e8 46 4d 00 00       	call   f0105629 <debuginfo_eip>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
f01008e3:	89 f0                	mov    %esi,%eax
f01008e5:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008e8:	89 44 24 30          	mov    %eax,0x30(%esp)
f01008ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01008ef:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f01008f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01008f6:	89 44 24 28          	mov    %eax,0x28(%esp)
f01008fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01008fd:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100901:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100904:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100908:	8b 43 18             	mov    0x18(%ebx),%eax
f010090b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010090f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100912:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100916:	8b 43 10             	mov    0x10(%ebx),%eax
f0100919:	89 44 24 14          	mov    %eax,0x14(%esp)
f010091d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100920:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100924:	8b 43 08             	mov    0x8(%ebx),%eax
f0100927:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010092b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010092f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100933:	c7 04 24 94 72 10 f0 	movl   $0xf0107294,(%esp)
f010093a:	e8 47 36 00 00       	call   f0103f86 <cprintf>
		
		pre_ebp = (int *)*pre_ebp;
f010093f:	8b 1b                	mov    (%ebx),%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f0100941:	85 db                	test   %ebx,%ebx
f0100943:	75 8b                	jne    f01008d0 <mon_backtrace+0x1e>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
		
		pre_ebp = (int *)*pre_ebp;
	}
	return bt_cnt;
}
f0100945:	89 f8                	mov    %edi,%eax
f0100947:	83 c4 6c             	add    $0x6c,%esp
f010094a:	5b                   	pop    %ebx
f010094b:	5e                   	pop    %esi
f010094c:	5f                   	pop    %edi
f010094d:	5d                   	pop    %ebp
f010094e:	c3                   	ret    

f010094f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010094f:	55                   	push   %ebp
f0100950:	89 e5                	mov    %esp,%ebp
f0100952:	57                   	push   %edi
f0100953:	56                   	push   %esi
f0100954:	53                   	push   %ebx
f0100955:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100958:	c7 04 24 dc 72 10 f0 	movl   $0xf01072dc,(%esp)
f010095f:	e8 22 36 00 00       	call   f0103f86 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100964:	c7 04 24 00 73 10 f0 	movl   $0xf0107300,(%esp)
f010096b:	e8 16 36 00 00       	call   f0103f86 <cprintf>

	if (tf != NULL)
f0100970:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100974:	74 0b                	je     f0100981 <monitor+0x32>
		print_trapframe(tf);
f0100976:	8b 45 08             	mov    0x8(%ebp),%eax
f0100979:	89 04 24             	mov    %eax,(%esp)
f010097c:	e8 09 3c 00 00       	call   f010458a <print_trapframe>
	
	while (1) {
		buf = readline("K> ");
f0100981:	c7 04 24 04 71 10 f0 	movl   $0xf0107104,(%esp)
f0100988:	e8 33 55 00 00       	call   f0105ec0 <readline>
f010098d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010098f:	85 c0                	test   %eax,%eax
f0100991:	74 ee                	je     f0100981 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100993:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010099a:	be 00 00 00 00       	mov    $0x0,%esi
f010099f:	eb 04                	jmp    f01009a5 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009a1:	c6 03 00             	movb   $0x0,(%ebx)
f01009a4:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009a5:	8a 03                	mov    (%ebx),%al
f01009a7:	84 c0                	test   %al,%al
f01009a9:	74 5e                	je     f0100a09 <monitor+0xba>
f01009ab:	0f be c0             	movsbl %al,%eax
f01009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b2:	c7 04 24 08 71 10 f0 	movl   $0xf0107108,(%esp)
f01009b9:	e8 f7 56 00 00       	call   f01060b5 <strchr>
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	75 df                	jne    f01009a1 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01009c2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009c5:	74 42                	je     f0100a09 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009c7:	83 fe 0f             	cmp    $0xf,%esi
f01009ca:	75 16                	jne    f01009e2 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009cc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01009d3:	00 
f01009d4:	c7 04 24 0d 71 10 f0 	movl   $0xf010710d,(%esp)
f01009db:	e8 a6 35 00 00       	call   f0103f86 <cprintf>
f01009e0:	eb 9f                	jmp    f0100981 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01009e2:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009e6:	46                   	inc    %esi
f01009e7:	eb 01                	jmp    f01009ea <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009e9:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ea:	8a 03                	mov    (%ebx),%al
f01009ec:	84 c0                	test   %al,%al
f01009ee:	74 b5                	je     f01009a5 <monitor+0x56>
f01009f0:	0f be c0             	movsbl %al,%eax
f01009f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f7:	c7 04 24 08 71 10 f0 	movl   $0xf0107108,(%esp)
f01009fe:	e8 b2 56 00 00       	call   f01060b5 <strchr>
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	74 e2                	je     f01009e9 <monitor+0x9a>
f0100a07:	eb 9c                	jmp    f01009a5 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100a09:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a10:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a11:	85 f6                	test   %esi,%esi
f0100a13:	0f 84 68 ff ff ff    	je     f0100981 <monitor+0x32>
f0100a19:	bb 80 73 10 f0       	mov    $0xf0107380,%ebx
f0100a1e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a23:	8b 03                	mov    (%ebx),%eax
f0100a25:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a29:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a2c:	89 04 24             	mov    %eax,(%esp)
f0100a2f:	e8 2e 56 00 00       	call   f0106062 <strcmp>
f0100a34:	85 c0                	test   %eax,%eax
f0100a36:	75 24                	jne    f0100a5c <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100a38:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a3b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a3e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a42:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a49:	89 34 24             	mov    %esi,(%esp)
f0100a4c:	ff 14 85 88 73 10 f0 	call   *-0xfef8c78(,%eax,4)
		print_trapframe(tf);
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a53:	85 c0                	test   %eax,%eax
f0100a55:	78 26                	js     f0100a7d <monitor+0x12e>
f0100a57:	e9 25 ff ff ff       	jmp    f0100981 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a5c:	47                   	inc    %edi
f0100a5d:	83 c3 0c             	add    $0xc,%ebx
f0100a60:	83 ff 05             	cmp    $0x5,%edi
f0100a63:	75 be                	jne    f0100a23 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a65:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6c:	c7 04 24 2a 71 10 f0 	movl   $0xf010712a,(%esp)
f0100a73:	e8 0e 35 00 00       	call   f0103f86 <cprintf>
f0100a78:	e9 04 ff ff ff       	jmp    f0100981 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a7d:	83 c4 5c             	add    $0x5c,%esp
f0100a80:	5b                   	pop    %ebx
f0100a81:	5e                   	pop    %esi
f0100a82:	5f                   	pop    %edi
f0100a83:	5d                   	pop    %ebp
f0100a84:	c3                   	ret    
f0100a85:	00 00                	add    %al,(%eax)
	...

f0100a88 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a88:	55                   	push   %ebp
f0100a89:	89 e5                	mov    %esp,%ebp
f0100a8b:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a8e:	89 d1                	mov    %edx,%ecx
f0100a90:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a93:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a96:	a8 01                	test   $0x1,%al
f0100a98:	74 4d                	je     f0100ae7 <check_va2pa+0x5f>
	  return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a9f:	89 c1                	mov    %eax,%ecx
f0100aa1:	c1 e9 0c             	shr    $0xc,%ecx
f0100aa4:	3b 0d 88 1e 33 f0    	cmp    0xf0331e88,%ecx
f0100aaa:	72 20                	jb     f0100acc <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ab0:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0100ab7:	f0 
f0100ab8:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0100abf:	00 
f0100ac0:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100ac7:	e8 74 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100acc:	c1 ea 0c             	shr    $0xc,%edx
f0100acf:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ad5:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100adc:	a8 01                	test   $0x1,%al
f0100ade:	74 0e                	je     f0100aee <check_va2pa+0x66>
	  return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ae0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ae5:	eb 0c                	jmp    f0100af3 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
	  return ~0;
f0100ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100aec:	eb 05                	jmp    f0100af3 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
	  return ~0;
f0100aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100af3:	c9                   	leave  
f0100af4:	c3                   	ret    

f0100af5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100af5:	55                   	push   %ebp
f0100af6:	89 e5                	mov    %esp,%ebp
f0100af8:	53                   	push   %ebx
f0100af9:	83 ec 24             	sub    $0x24,%esp
f0100afc:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100afe:	83 3d 3c 12 33 f0 00 	cmpl   $0x0,0xf033123c
f0100b05:	75 0f                	jne    f0100b16 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b07:	b8 07 40 37 f0       	mov    $0xf0374007,%eax
f0100b0c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b11:	a3 3c 12 33 f0       	mov    %eax,0xf033123c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	// first end is at address 0xf011b970, result is 0xf011c100, use 107KB for kernel 
	if (n > 0) {
f0100b16:	85 d2                	test   %edx,%edx
f0100b18:	74 55                	je     f0100b6f <boot_alloc+0x7a>
		result = nextfree;
f0100b1a:	a1 3c 12 33 f0       	mov    0xf033123c,%eax
		nextfree = ROUNDUP((char *)(nextfree+n), PGSIZE);
f0100b1f:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b26:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b2c:	89 15 3c 12 33 f0    	mov    %edx,0xf033123c
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE ){
f0100b32:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f0100b38:	c1 e1 0c             	shl    $0xc,%ecx
f0100b3b:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100b41:	39 cb                	cmp    %ecx,%ebx
f0100b43:	76 2f                	jbe    f0100b74 <boot_alloc+0x7f>
			panic("Cannot alloc more physical memory. Requested %dK, Available %dK\n", (uint32_t)nextfree/1024, npages*PGSIZE/1024);
f0100b45:	c1 e9 0a             	shr    $0xa,%ecx
f0100b48:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100b4c:	c1 ea 0a             	shr    $0xa,%edx
f0100b4f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b53:	c7 44 24 08 bc 73 10 	movl   $0xf01073bc,0x8(%esp)
f0100b5a:	f0 
f0100b5b:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f0100b62:	00 
f0100b63:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100b6a:	e8 d1 f4 ff ff       	call   f0100040 <_panic>
		}
		return result;
	}
	return nextfree;
f0100b6f:	a1 3c 12 33 f0       	mov    0xf033123c,%eax
}
f0100b74:	83 c4 24             	add    $0x24,%esp
f0100b77:	5b                   	pop    %ebx
f0100b78:	5d                   	pop    %ebp
f0100b79:	c3                   	ret    

f0100b7a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b7a:	55                   	push   %ebp
f0100b7b:	89 e5                	mov    %esp,%ebp
f0100b7d:	56                   	push   %esi
f0100b7e:	53                   	push   %ebx
f0100b7f:	83 ec 10             	sub    $0x10,%esp
f0100b82:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b84:	89 04 24             	mov    %eax,(%esp)
f0100b87:	e8 b4 32 00 00       	call   f0103e40 <mc146818_read>
f0100b8c:	89 c6                	mov    %eax,%esi
f0100b8e:	43                   	inc    %ebx
f0100b8f:	89 1c 24             	mov    %ebx,(%esp)
f0100b92:	e8 a9 32 00 00       	call   f0103e40 <mc146818_read>
f0100b97:	c1 e0 08             	shl    $0x8,%eax
f0100b9a:	09 f0                	or     %esi,%eax
}
f0100b9c:	83 c4 10             	add    $0x10,%esp
f0100b9f:	5b                   	pop    %ebx
f0100ba0:	5e                   	pop    %esi
f0100ba1:	5d                   	pop    %ebp
f0100ba2:	c3                   	ret    

f0100ba3 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ba3:	55                   	push   %ebp
f0100ba4:	89 e5                	mov    %esp,%ebp
f0100ba6:	57                   	push   %edi
f0100ba7:	56                   	push   %esi
f0100ba8:	53                   	push   %ebx
f0100ba9:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bac:	3c 01                	cmp    $0x1,%al
f0100bae:	19 f6                	sbb    %esi,%esi
f0100bb0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100bb6:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100bb7:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0100bbd:	85 d2                	test   %edx,%edx
f0100bbf:	75 1c                	jne    f0100bdd <check_page_free_list+0x3a>
	  panic("'page_free_list' is a null pointer!");
f0100bc1:	c7 44 24 08 00 74 10 	movl   $0xf0107400,0x8(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0100bd0:	00 
f0100bd1:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100bd8:	e8 63 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100bdd:	84 c0                	test   %al,%al
f0100bdf:	74 4b                	je     f0100c2c <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100be1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100be4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100be7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100bea:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bed:	89 d0                	mov    %edx,%eax
f0100bef:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100bf5:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bf8:	c1 e8 16             	shr    $0x16,%eax
f0100bfb:	39 c6                	cmp    %eax,%esi
f0100bfd:	0f 96 c0             	setbe  %al
f0100c00:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c03:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100c07:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c09:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c0d:	8b 12                	mov    (%edx),%edx
f0100c0f:	85 d2                	test   %edx,%edx
f0100c11:	75 da                	jne    f0100bed <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c13:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c1c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c1f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c22:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c24:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c27:	a3 40 12 33 f0       	mov    %eax,0xf0331240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c2c:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
f0100c32:	eb 63                	jmp    f0100c97 <check_page_free_list+0xf4>
f0100c34:	89 d8                	mov    %ebx,%eax
f0100c36:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100c3c:	c1 f8 03             	sar    $0x3,%eax
f0100c3f:	c1 e0 0c             	shl    $0xc,%eax
	  if (PDX(page2pa(pp)) < pdx_limit)
f0100c42:	89 c2                	mov    %eax,%edx
f0100c44:	c1 ea 16             	shr    $0x16,%edx
f0100c47:	39 d6                	cmp    %edx,%esi
f0100c49:	76 4a                	jbe    f0100c95 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c4b:	89 c2                	mov    %eax,%edx
f0100c4d:	c1 ea 0c             	shr    $0xc,%edx
f0100c50:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100c56:	72 20                	jb     f0100c78 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c5c:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0100c63:	f0 
f0100c64:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c6b:	00 
f0100c6c:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0100c73:	e8 c8 f3 ff ff       	call   f0100040 <_panic>
		memset(page2kva(pp), 0x97, 128);
f0100c78:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c7f:	00 
f0100c80:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c87:	00 
	return (void *)(pa + KERNBASE);
f0100c88:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c8d:	89 04 24             	mov    %eax,(%esp)
f0100c90:	e8 55 54 00 00       	call   f01060ea <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c95:	8b 1b                	mov    (%ebx),%ebx
f0100c97:	85 db                	test   %ebx,%ebx
f0100c99:	75 99                	jne    f0100c34 <check_page_free_list+0x91>
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c9b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca0:	e8 50 fe ff ff       	call   f0100af5 <boot_alloc>
f0100ca5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ca8:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cae:	8b 0d 90 1e 33 f0    	mov    0xf0331e90,%ecx
		assert(pp < pages + npages);
f0100cb4:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f0100cb9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cbc:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cbf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cc2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cc5:	be 00 00 00 00       	mov    $0x0,%esi
f0100cca:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ccd:	e9 c4 01 00 00       	jmp    f0100e96 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cd2:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100cd5:	73 24                	jae    f0100cfb <check_page_free_list+0x158>
f0100cd7:	c7 44 24 0c 17 7d 10 	movl   $0xf0107d17,0xc(%esp)
f0100cde:	f0 
f0100cdf:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100ce6:	f0 
f0100ce7:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100cee:	00 
f0100cef:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100cf6:	e8 45 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cfb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cfe:	72 24                	jb     f0100d24 <check_page_free_list+0x181>
f0100d00:	c7 44 24 0c 38 7d 10 	movl   $0xf0107d38,0xc(%esp)
f0100d07:	f0 
f0100d08:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100d0f:	f0 
f0100d10:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100d17:	00 
f0100d18:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100d1f:	e8 1c f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d24:	89 d0                	mov    %edx,%eax
f0100d26:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d29:	a8 07                	test   $0x7,%al
f0100d2b:	74 24                	je     f0100d51 <check_page_free_list+0x1ae>
f0100d2d:	c7 44 24 0c 24 74 10 	movl   $0xf0107424,0xc(%esp)
f0100d34:	f0 
f0100d35:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100d3c:	f0 
f0100d3d:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0100d44:	00 
f0100d45:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100d4c:	e8 ef f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d51:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d54:	c1 e0 0c             	shl    $0xc,%eax
f0100d57:	75 24                	jne    f0100d7d <check_page_free_list+0x1da>
f0100d59:	c7 44 24 0c 4c 7d 10 	movl   $0xf0107d4c,0xc(%esp)
f0100d60:	f0 
f0100d61:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100d68:	f0 
f0100d69:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100d70:	00 
f0100d71:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100d78:	e8 c3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d7d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d82:	75 24                	jne    f0100da8 <check_page_free_list+0x205>
f0100d84:	c7 44 24 0c 5d 7d 10 	movl   $0xf0107d5d,0xc(%esp)
f0100d8b:	f0 
f0100d8c:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100d93:	f0 
f0100d94:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0100d9b:	00 
f0100d9c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100da3:	e8 98 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100da8:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100dad:	75 24                	jne    f0100dd3 <check_page_free_list+0x230>
f0100daf:	c7 44 24 0c 58 74 10 	movl   $0xf0107458,0xc(%esp)
f0100db6:	f0 
f0100db7:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100dbe:	f0 
f0100dbf:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0100dc6:	00 
f0100dc7:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100dce:	e8 6d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dd3:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100dd8:	75 24                	jne    f0100dfe <check_page_free_list+0x25b>
f0100dda:	c7 44 24 0c 76 7d 10 	movl   $0xf0107d76,0xc(%esp)
f0100de1:	f0 
f0100de2:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100de9:	f0 
f0100dea:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0100df1:	00 
f0100df2:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100df9:	e8 42 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dfe:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e03:	76 59                	jbe    f0100e5e <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e05:	89 c1                	mov    %eax,%ecx
f0100e07:	c1 e9 0c             	shr    $0xc,%ecx
f0100e0a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e0d:	77 20                	ja     f0100e2f <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e13:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0100e1a:	f0 
f0100e1b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e22:	00 
f0100e23:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0100e2a:	e8 11 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e2f:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e35:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e38:	76 24                	jbe    f0100e5e <check_page_free_list+0x2bb>
f0100e3a:	c7 44 24 0c 7c 74 10 	movl   $0xf010747c,0xc(%esp)
f0100e41:	f0 
f0100e42:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100e49:	f0 
f0100e4a:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100e51:	00 
f0100e52:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100e59:	e8 e2 f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e5e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e63:	75 24                	jne    f0100e89 <check_page_free_list+0x2e6>
f0100e65:	c7 44 24 0c 90 7d 10 	movl   $0xf0107d90,0xc(%esp)
f0100e6c:	f0 
f0100e6d:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100e74:	f0 
f0100e75:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100e7c:	00 
f0100e7d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100e84:	e8 b7 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100e89:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e8e:	77 03                	ja     f0100e93 <check_page_free_list+0x2f0>
		  ++nfree_basemem;
f0100e90:	46                   	inc    %esi
f0100e91:	eb 01                	jmp    f0100e94 <check_page_free_list+0x2f1>
		else
		  ++nfree_extmem;
f0100e93:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e94:	8b 12                	mov    (%edx),%edx
f0100e96:	85 d2                	test   %edx,%edx
f0100e98:	0f 85 34 fe ff ff    	jne    f0100cd2 <check_page_free_list+0x12f>
		  ++nfree_basemem;
		else
		  ++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e9e:	85 f6                	test   %esi,%esi
f0100ea0:	7f 24                	jg     f0100ec6 <check_page_free_list+0x323>
f0100ea2:	c7 44 24 0c ad 7d 10 	movl   $0xf0107dad,0xc(%esp)
f0100ea9:	f0 
f0100eaa:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100eb1:	f0 
f0100eb2:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100eb9:	00 
f0100eba:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100ec1:	e8 7a f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100ec6:	85 db                	test   %ebx,%ebx
f0100ec8:	7f 24                	jg     f0100eee <check_page_free_list+0x34b>
f0100eca:	c7 44 24 0c bf 7d 10 	movl   $0xf0107dbf,0xc(%esp)
f0100ed1:	f0 
f0100ed2:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100ed9:	f0 
f0100eda:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0100ee1:	00 
f0100ee2:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100ee9:	e8 52 f1 ff ff       	call   f0100040 <_panic>
	
	//cprintf("check_page_free_list() succeeded!\n");
}
f0100eee:	83 c4 4c             	add    $0x4c,%esp
f0100ef1:	5b                   	pop    %ebx
f0100ef2:	5e                   	pop    %esi
f0100ef3:	5f                   	pop    %edi
f0100ef4:	5d                   	pop    %ebp
f0100ef5:	c3                   	ret    

f0100ef6 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ef6:	55                   	push   %ebp
f0100ef7:	89 e5                	mov    %esp,%ebp
f0100ef9:	57                   	push   %edi
f0100efa:	56                   	push   %esi
f0100efb:	53                   	push   %ebx
f0100efc:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	uint32_t num_alloc = ((uint32_t)boot_alloc(0)-KERNBASE)/PGSIZE;
f0100eff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f04:	e8 ec fb ff ff       	call   f0100af5 <boot_alloc>
f0100f09:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f0e:	c1 e8 0c             	shr    $0xc,%eax
	size_t i;

	for(i = 0; i < npages; ++i) {
		if((i == 0)||
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100f11:	8b 0d 38 12 33 f0    	mov    0xf0331238,%ecx
f0100f17:	8d 59 60             	lea    0x60(%ecx),%ebx
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f1a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f1f:	ba 00 00 00 00       	mov    $0x0,%edx
		if((i == 0)||
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
					// alloc by kernel, kernel alloc pages and kern_pgdir on stack
					// num_alloc isn't all pages used, it is just memory used by kernel
					( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc )||(i == MPENTRY_PADDR/PGSIZE)){
f0100f24:	01 d8                	add    %ebx,%eax
f0100f26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f29:	eb 4a                	jmp    f0100f75 <page_init+0x7f>
		if((i == 0)||
f0100f2b:	85 d2                	test   %edx,%edx
f0100f2d:	74 18                	je     f0100f47 <page_init+0x51>
f0100f2f:	39 ca                	cmp    %ecx,%edx
f0100f31:	72 06                	jb     f0100f39 <page_init+0x43>
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100f33:	39 da                	cmp    %ebx,%edx
f0100f35:	72 10                	jb     f0100f47 <page_init+0x51>
f0100f37:	eb 04                	jmp    f0100f3d <page_init+0x47>
f0100f39:	39 da                	cmp    %ebx,%edx
f0100f3b:	72 05                	jb     f0100f42 <page_init+0x4c>
					// alloc by kernel, kernel alloc pages and kern_pgdir on stack
					// num_alloc isn't all pages used, it is just memory used by kernel
					( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc )||(i == MPENTRY_PADDR/PGSIZE)){
f0100f3d:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100f40:	72 05                	jb     f0100f47 <page_init+0x51>
f0100f42:	83 fa 07             	cmp    $0x7,%edx
f0100f45:	75 0e                	jne    f0100f55 <page_init+0x5f>
			pages[i].pp_ref = 1;	
f0100f47:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
f0100f4c:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
f0100f53:	eb 1f                	jmp    f0100f74 <page_init+0x7e>
		}else {
			pages[i].pp_ref = 0;
f0100f55:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100f5c:	8b 35 90 1e 33 f0    	mov    0xf0331e90,%esi
f0100f62:	66 c7 44 06 04 00 00 	movw   $0x0,0x4(%esi,%eax,1)
			pages[i].pp_link = page_free_list;
f0100f69:	89 3c 06             	mov    %edi,(%esi,%eax,1)
			page_free_list = &pages[i];
f0100f6c:	89 c7                	mov    %eax,%edi
f0100f6e:	03 3d 90 1e 33 f0    	add    0xf0331e90,%edi
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f74:	42                   	inc    %edx
f0100f75:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100f7b:	72 ae                	jb     f0100f2b <page_init+0x35>
f0100f7d:	89 3d 40 12 33 f0    	mov    %edi,0xf0331240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100f83:	83 c4 1c             	add    $0x1c,%esp
f0100f86:	5b                   	pop    %ebx
f0100f87:	5e                   	pop    %esi
f0100f88:	5f                   	pop    %edi
f0100f89:	5d                   	pop    %ebp
f0100f8a:	c3                   	ret    

f0100f8b <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f8b:	55                   	push   %ebp
f0100f8c:	89 e5                	mov    %esp,%ebp
f0100f8e:	53                   	push   %ebx
f0100f8f:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo* temp_page;
	if (page_free_list) {
f0100f92:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
f0100f98:	85 db                	test   %ebx,%ebx
f0100f9a:	0f 84 96 00 00 00    	je     f0101036 <page_alloc+0xab>
		temp_page = page_free_list;
		assert(temp_page->pp_ref == 0);
f0100fa0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100fa5:	74 24                	je     f0100fcb <page_alloc+0x40>
f0100fa7:	c7 44 24 0c d0 7d 10 	movl   $0xf0107dd0,0xc(%esp)
f0100fae:	f0 
f0100faf:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0100fb6:	f0 
f0100fb7:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f0100fbe:	00 
f0100fbf:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0100fc6:	e8 75 f0 ff ff       	call   f0100040 <_panic>
		page_free_list = page_free_list->pp_link;
f0100fcb:	8b 03                	mov    (%ebx),%eax
f0100fcd:	a3 40 12 33 f0       	mov    %eax,0xf0331240
		temp_page->pp_link = NULL;
f0100fd2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	} else {
		return NULL;
	} 
	// temp_page is a Pageinfo, i think page2kva is actual page
	if (alloc_flags & ALLOC_ZERO) {
f0100fd8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fdc:	74 58                	je     f0101036 <page_alloc+0xab>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fde:	89 d8                	mov    %ebx,%eax
f0100fe0:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100fe6:	c1 f8 03             	sar    $0x3,%eax
f0100fe9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fec:	89 c2                	mov    %eax,%edx
f0100fee:	c1 ea 0c             	shr    $0xc,%edx
f0100ff1:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100ff7:	72 20                	jb     f0101019 <page_alloc+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ffd:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0101004:	f0 
f0101005:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010100c:	00 
f010100d:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0101014:	e8 27 f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(temp_page), 0, PGSIZE); 
f0101019:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101020:	00 
f0101021:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101028:	00 
	return (void *)(pa + KERNBASE);
f0101029:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010102e:	89 04 24             	mov    %eax,(%esp)
f0101031:	e8 b4 50 00 00       	call   f01060ea <memset>
	}

	return temp_page;
}
f0101036:	89 d8                	mov    %ebx,%eax
f0101038:	83 c4 14             	add    $0x14,%esp
f010103b:	5b                   	pop    %ebx
f010103c:	5d                   	pop    %ebp
f010103d:	c3                   	ret    

f010103e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010103e:	55                   	push   %ebp
f010103f:	89 e5                	mov    %esp,%ebp
f0101041:	83 ec 18             	sub    $0x18,%esp
f0101044:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f0101047:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010104c:	74 1c                	je     f010106a <page_free+0x2c>
		panic("Still using page");
f010104e:	c7 44 24 08 e7 7d 10 	movl   $0xf0107de7,0x8(%esp)
f0101055:	f0 
f0101056:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f010105d:	00 
f010105e:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101065:	e8 d6 ef ff ff       	call   f0100040 <_panic>
	}
	if (pp->pp_link != NULL) {
f010106a:	83 38 00             	cmpl   $0x0,(%eax)
f010106d:	74 1c                	je     f010108b <page_free+0x4d>
		panic("free page still have a link");
f010106f:	c7 44 24 08 f8 7d 10 	movl   $0xf0107df8,0x8(%esp)
f0101076:	f0 
f0101077:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f010107e:	00 
f010107f:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101086:	e8 b5 ef ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f010108b:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0101091:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101093:	a3 40 12 33 f0       	mov    %eax,0xf0331240
}
f0101098:	c9                   	leave  
f0101099:	c3                   	ret    

f010109a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010109a:	55                   	push   %ebp
f010109b:	89 e5                	mov    %esp,%ebp
f010109d:	83 ec 18             	sub    $0x18,%esp
f01010a0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01010a3:	8b 50 04             	mov    0x4(%eax),%edx
f01010a6:	4a                   	dec    %edx
f01010a7:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010ab:	66 85 d2             	test   %dx,%dx
f01010ae:	75 08                	jne    f01010b8 <page_decref+0x1e>
	  page_free(pp);
f01010b0:	89 04 24             	mov    %eax,(%esp)
f01010b3:	e8 86 ff ff ff       	call   f010103e <page_free>
}
f01010b8:	c9                   	leave  
f01010b9:	c3                   	ret    

f01010ba <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010ba:	55                   	push   %ebp
f01010bb:	89 e5                	mov    %esp,%ebp
f01010bd:	57                   	push   %edi
f01010be:	56                   	push   %esi
f01010bf:	53                   	push   %ebx
f01010c0:	83 ec 1c             	sub    $0x1c,%esp
f01010c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pde_t* pgdir_entry = &pgdir[PDX(va)];
f01010c6:	89 fb                	mov    %edi,%ebx
f01010c8:	c1 eb 16             	shr    $0x16,%ebx
f01010cb:	c1 e3 02             	shl    $0x2,%ebx
f01010ce:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pgtb_entry = NULL;
	struct PageInfo * pg = NULL;

	if (!(*pgdir_entry & PTE_P)){
f01010d1:	f6 03 01             	testb  $0x1,(%ebx)
f01010d4:	0f 85 8b 00 00 00    	jne    f0101165 <pgdir_walk+0xab>
		if(create){
f01010da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010de:	0f 84 c7 00 00 00    	je     f01011ab <pgdir_walk+0xf1>
			pg = page_alloc(1);
f01010e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01010eb:	e8 9b fe ff ff       	call   f0100f8b <page_alloc>
f01010f0:	89 c6                	mov    %eax,%esi
			if (!pg) 
f01010f2:	85 c0                	test   %eax,%eax
f01010f4:	0f 84 b8 00 00 00    	je     f01011b2 <pgdir_walk+0xf8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010fa:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0101100:	c1 f8 03             	sar    $0x3,%eax
f0101103:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101106:	89 c2                	mov    %eax,%edx
f0101108:	c1 ea 0c             	shr    $0xc,%edx
f010110b:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0101111:	72 20                	jb     f0101133 <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101113:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101117:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f010111e:	f0 
f010111f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101126:	00 
f0101127:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f010112e:	e8 0d ef ff ff       	call   f0100040 <_panic>
			  return NULL;
			memset(page2kva(pg), 0, PGSIZE);
f0101133:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010113a:	00 
f010113b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101142:	00 
	return (void *)(pa + KERNBASE);
f0101143:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101148:	89 04 24             	mov    %eax,(%esp)
f010114b:	e8 9a 4f 00 00       	call   f01060ea <memset>
			pg->pp_ref += 1;
f0101150:	66 ff 46 04          	incw   0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101154:	2b 35 90 1e 33 f0    	sub    0xf0331e90,%esi
f010115a:	c1 fe 03             	sar    $0x3,%esi
f010115d:	c1 e6 0c             	shl    $0xc,%esi
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
f0101160:	83 ce 07             	or     $0x7,%esi
f0101163:	89 33                	mov    %esi,(%ebx)
		}else{
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
f0101165:	8b 03                	mov    (%ebx),%eax
f0101167:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010116c:	89 c2                	mov    %eax,%edx
f010116e:	c1 ea 0c             	shr    $0xc,%edx
f0101171:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0101177:	72 20                	jb     f0101199 <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101179:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010117d:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0101184:	f0 
f0101185:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f010118c:	00 
f010118d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101194:	e8 a7 ee ff ff       	call   f0100040 <_panic>
	return &pgtb_entry[PTX(va)];
f0101199:	c1 ef 0a             	shr    $0xa,%edi
f010119c:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01011a2:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
f01011a9:	eb 0c                	jmp    f01011b7 <pgdir_walk+0xfd>
			  return NULL;
			memset(page2kva(pg), 0, PGSIZE);
			pg->pp_ref += 1;
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
		}else{
			return NULL;
f01011ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01011b0:	eb 05                	jmp    f01011b7 <pgdir_walk+0xfd>

	if (!(*pgdir_entry & PTE_P)){
		if(create){
			pg = page_alloc(1);
			if (!pg) 
			  return NULL;
f01011b2:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
	return &pgtb_entry[PTX(va)];
}
f01011b7:	83 c4 1c             	add    $0x1c,%esp
f01011ba:	5b                   	pop    %ebx
f01011bb:	5e                   	pop    %esi
f01011bc:	5f                   	pop    %edi
f01011bd:	5d                   	pop    %ebp
f01011be:	c3                   	ret    

f01011bf <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011bf:	55                   	push   %ebp
f01011c0:	89 e5                	mov    %esp,%ebp
f01011c2:	57                   	push   %edi
f01011c3:	56                   	push   %esi
f01011c4:	53                   	push   %ebx
f01011c5:	83 ec 2c             	sub    $0x2c,%esp
f01011c8:	89 c7                	mov    %eax,%edi
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f01011ca:	c1 e9 0c             	shr    $0xc,%ecx
f01011cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01011d0:	89 d3                	mov    %edx,%ebx
f01011d2:	be 00 00 00 00       	mov    $0x0,%esi
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f01011d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011da:	83 c8 01             	or     $0x1,%eax
f01011dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01011e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01011e3:	29 d0                	sub    %edx,%eax
f01011e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f01011e8:	eb 25                	jmp    f010120f <boot_map_region+0x50>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
f01011ea:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011f1:	00 
f01011f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01011f6:	89 3c 24             	mov    %edi,(%esp)
f01011f9:	e8 bc fe ff ff       	call   f01010ba <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01011fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101201:	01 da                	add    %ebx,%edx
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0101203:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101206:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0101208:	46                   	inc    %esi
f0101209:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010120f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101212:	75 d6                	jne    f01011ea <boot_map_region+0x2b>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
	} 
}
f0101214:	83 c4 2c             	add    $0x2c,%esp
f0101217:	5b                   	pop    %ebx
f0101218:	5e                   	pop    %esi
f0101219:	5f                   	pop    %edi
f010121a:	5d                   	pop    %ebp
f010121b:	c3                   	ret    

f010121c <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f0101222:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101229:	00 
f010122a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010122d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101231:	8b 45 08             	mov    0x8(%ebp),%eax
f0101234:	89 04 24             	mov    %eax,(%esp)
f0101237:	e8 7e fe ff ff       	call   f01010ba <pgdir_walk>
	if (pt_entry && *pt_entry&PTE_P) {
f010123c:	85 c0                	test   %eax,%eax
f010123e:	74 3e                	je     f010127e <page_lookup+0x62>
f0101240:	f6 00 01             	testb  $0x1,(%eax)
f0101243:	74 40                	je     f0101285 <page_lookup+0x69>
		*pte_store = pt_entry;
f0101245:	8b 55 10             	mov    0x10(%ebp),%edx
f0101248:	89 02                	mov    %eax,(%edx)
	}else{
		return NULL;
	}
	return pa2page(PTE_ADDR(*pt_entry));
f010124a:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010124c:	c1 e8 0c             	shr    $0xc,%eax
f010124f:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0101255:	72 1c                	jb     f0101273 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101257:	c7 44 24 08 c4 74 10 	movl   $0xf01074c4,0x8(%esp)
f010125e:	f0 
f010125f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101266:	00 
f0101267:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f010126e:	e8 cd ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101273:	c1 e0 03             	shl    $0x3,%eax
f0101276:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f010127c:	eb 0c                	jmp    f010128a <page_lookup+0x6e>
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
	if (pt_entry && *pt_entry&PTE_P) {
		*pte_store = pt_entry;
	}else{
		return NULL;
f010127e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101283:	eb 05                	jmp    f010128a <page_lookup+0x6e>
f0101285:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return pa2page(PTE_ADDR(*pt_entry));
}
f010128a:	c9                   	leave  
f010128b:	c3                   	ret    

f010128c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010128c:	55                   	push   %ebp
f010128d:	89 e5                	mov    %esp,%ebp
f010128f:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101292:	e8 81 54 00 00       	call   f0106718 <cpunum>
f0101297:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010129e:	29 c2                	sub    %eax,%edx
f01012a0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01012a3:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f01012aa:	00 
f01012ab:	74 20                	je     f01012cd <tlb_invalidate+0x41>
f01012ad:	e8 66 54 00 00       	call   f0106718 <cpunum>
f01012b2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01012b9:	29 c2                	sub    %eax,%edx
f01012bb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01012be:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01012c5:	8b 55 08             	mov    0x8(%ebp),%edx
f01012c8:	39 50 60             	cmp    %edx,0x60(%eax)
f01012cb:	75 06                	jne    f01012d3 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012d0:	0f 01 38             	invlpg (%eax)
	  invlpg(va);
}
f01012d3:	c9                   	leave  
f01012d4:	c3                   	ret    

f01012d5 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01012d5:	55                   	push   %ebp
f01012d6:	89 e5                	mov    %esp,%ebp
f01012d8:	56                   	push   %esi
f01012d9:	53                   	push   %ebx
f01012da:	83 ec 20             	sub    $0x20,%esp
f01012dd:	8b 75 08             	mov    0x8(%ebp),%esi
f01012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte_store = NULL;
f01012e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg = page_lookup(pgdir, va, &pte_store); 
f01012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012f5:	89 34 24             	mov    %esi,(%esp)
f01012f8:	e8 1f ff ff ff       	call   f010121c <page_lookup>
	if (!pg) 
f01012fd:	85 c0                	test   %eax,%eax
f01012ff:	74 1d                	je     f010131e <page_remove+0x49>
	  return;
	page_decref(pg);	
f0101301:	89 04 24             	mov    %eax,(%esp)
f0101304:	e8 91 fd ff ff       	call   f010109a <page_decref>
	tlb_invalidate(pgdir, va);
f0101309:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010130d:	89 34 24             	mov    %esi,(%esp)
f0101310:	e8 77 ff ff ff       	call   f010128c <tlb_invalidate>
	*pte_store = 0;
f0101315:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101318:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010131e:	83 c4 20             	add    $0x20,%esp
f0101321:	5b                   	pop    %ebx
f0101322:	5e                   	pop    %esi
f0101323:	5d                   	pop    %ebp
f0101324:	c3                   	ret    

f0101325 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101325:	55                   	push   %ebp
f0101326:	89 e5                	mov    %esp,%ebp
f0101328:	57                   	push   %edi
f0101329:	56                   	push   %esi
f010132a:	53                   	push   %ebx
f010132b:	83 ec 1c             	sub    $0x1c,%esp
f010132e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101331:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f0101334:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010133b:	00 
f010133c:	8b 45 10             	mov    0x10(%ebp),%eax
f010133f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101343:	89 34 24             	mov    %esi,(%esp)
f0101346:	e8 6f fd ff ff       	call   f01010ba <pgdir_walk>
f010134b:	89 c3                	mov    %eax,%ebx
	if (!pg_entry) {
f010134d:	85 c0                	test   %eax,%eax
f010134f:	74 4d                	je     f010139e <page_insert+0x79>
		return -E_NO_MEM;
	} 
	pp->pp_ref++;
f0101351:	66 ff 47 04          	incw   0x4(%edi)
	if (*pg_entry & PTE_P){
f0101355:	f6 00 01             	testb  $0x1,(%eax)
f0101358:	74 1e                	je     f0101378 <page_insert+0x53>
		tlb_invalidate(pgdir, va);
f010135a:	8b 45 10             	mov    0x10(%ebp),%eax
f010135d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101361:	89 34 24             	mov    %esi,(%esp)
f0101364:	e8 23 ff ff ff       	call   f010128c <tlb_invalidate>
		page_remove(pgdir, va);
f0101369:	8b 45 10             	mov    0x10(%ebp),%eax
f010136c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101370:	89 34 24             	mov    %esi,(%esp)
f0101373:	e8 5d ff ff ff       	call   f01012d5 <page_remove>
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
f0101378:	8b 55 14             	mov    0x14(%ebp),%edx
f010137b:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010137e:	2b 3d 90 1e 33 f0    	sub    0xf0331e90,%edi
f0101384:	c1 ff 03             	sar    $0x3,%edi
f0101387:	c1 e7 0c             	shl    $0xc,%edi
f010138a:	09 d7                	or     %edx,%edi
f010138c:	89 3b                	mov    %edi,(%ebx)
	pgdir[PDX(va)] |= perm | PTE_P;	
f010138e:	8b 45 10             	mov    0x10(%ebp),%eax
f0101391:	c1 e8 16             	shr    $0x16,%eax
f0101394:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101397:	b8 00 00 00 00       	mov    $0x0,%eax
f010139c:	eb 05                	jmp    f01013a3 <page_insert+0x7e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
	if (!pg_entry) {
		return -E_NO_MEM;
f010139e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
	pgdir[PDX(va)] |= perm | PTE_P;	
	return 0;
}
f01013a3:	83 c4 1c             	add    $0x1c,%esp
f01013a6:	5b                   	pop    %ebx
f01013a7:	5e                   	pop    %esi
f01013a8:	5f                   	pop    %edi
f01013a9:	5d                   	pop    %ebp
f01013aa:	c3                   	ret    

f01013ab <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013ab:	55                   	push   %ebp
f01013ac:	89 e5                	mov    %esp,%ebp
f01013ae:	56                   	push   %esi
f01013af:	53                   	push   %ebx
f01013b0:	83 ec 10             	sub    $0x10,%esp
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	//panic("mmio_map_region not implemented");
	void* ret = (void*)base;
f01013b3:	8b 1d 00 93 12 f0    	mov    0xf0129300,%ebx
	uint32_t round_size = ROUNDUP(size, PGSIZE); 
f01013b9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013bc:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f01013c2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (base + round_size >= MMIOLIM){
f01013c8:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01013cb:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01013d0:	76 1c                	jbe    f01013ee <mmio_map_region+0x43>
		panic("mmio_map_region: map overflow");
f01013d2:	c7 44 24 08 14 7e 10 	movl   $0xf0107e14,0x8(%esp)
f01013d9:	f0 
f01013da:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f01013e1:	00 
f01013e2:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01013e9:	e8 52 ec ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, round_size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01013ee:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01013f5:	00 
f01013f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f9:	89 04 24             	mov    %eax,(%esp)
f01013fc:	89 f1                	mov    %esi,%ecx
f01013fe:	89 da                	mov    %ebx,%edx
f0101400:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101405:	e8 b5 fd ff ff       	call   f01011bf <boot_map_region>
	base+=round_size;
f010140a:	01 35 00 93 12 f0    	add    %esi,0xf0129300
	return ret;

}
f0101410:	89 d8                	mov    %ebx,%eax
f0101412:	83 c4 10             	add    $0x10,%esp
f0101415:	5b                   	pop    %ebx
f0101416:	5e                   	pop    %esi
f0101417:	5d                   	pop    %ebp
f0101418:	c3                   	ret    

f0101419 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101419:	55                   	push   %ebp
f010141a:	89 e5                	mov    %esp,%ebp
f010141c:	57                   	push   %edi
f010141d:	56                   	push   %esi
f010141e:	53                   	push   %ebx
f010141f:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101422:	b8 15 00 00 00       	mov    $0x15,%eax
f0101427:	e8 4e f7 ff ff       	call   f0100b7a <nvram_read>
f010142c:	c1 e0 0a             	shl    $0xa,%eax
f010142f:	89 c2                	mov    %eax,%edx
f0101431:	85 c0                	test   %eax,%eax
f0101433:	79 06                	jns    f010143b <mem_init+0x22>
f0101435:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010143b:	c1 fa 0c             	sar    $0xc,%edx
f010143e:	89 15 38 12 33 f0    	mov    %edx,0xf0331238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101444:	b8 17 00 00 00       	mov    $0x17,%eax
f0101449:	e8 2c f7 ff ff       	call   f0100b7a <nvram_read>
f010144e:	89 c2                	mov    %eax,%edx
f0101450:	c1 e2 0a             	shl    $0xa,%edx
f0101453:	89 d0                	mov    %edx,%eax
f0101455:	85 d2                	test   %edx,%edx
f0101457:	79 06                	jns    f010145f <mem_init+0x46>
f0101459:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010145f:	c1 f8 0c             	sar    $0xc,%eax
f0101462:	74 0e                	je     f0101472 <mem_init+0x59>
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101464:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010146a:	89 15 88 1e 33 f0    	mov    %edx,0xf0331e88
f0101470:	eb 0c                	jmp    f010147e <mem_init+0x65>
	else
	  npages = npages_basemem;
f0101472:	8b 15 38 12 33 f0    	mov    0xf0331238,%edx
f0101478:	89 15 88 1e 33 f0    	mov    %edx,0xf0331e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
				npages * PGSIZE / 1024,
				npages_basemem * PGSIZE / 1024,
				npages_extmem * PGSIZE / 1024);
f010147e:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101481:	c1 e8 0a             	shr    $0xa,%eax
f0101484:	89 44 24 0c          	mov    %eax,0xc(%esp)
				npages * PGSIZE / 1024,
				npages_basemem * PGSIZE / 1024,
f0101488:	a1 38 12 33 f0       	mov    0xf0331238,%eax
f010148d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101490:	c1 e8 0a             	shr    $0xa,%eax
f0101493:	89 44 24 08          	mov    %eax,0x8(%esp)
				npages * PGSIZE / 1024,
f0101497:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f010149c:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010149f:	c1 e8 0a             	shr    $0xa,%eax
f01014a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014a6:	c7 04 24 e4 74 10 f0 	movl   $0xf01074e4,(%esp)
f01014ad:	e8 d4 2a 00 00       	call   f0103f86 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014b2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014b7:	e8 39 f6 ff ff       	call   f0100af5 <boot_alloc>
f01014bc:	a3 8c 1e 33 f0       	mov    %eax,0xf0331e8c
	memset(kern_pgdir, 0, PGSIZE);
f01014c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014c8:	00 
f01014c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014d0:	00 
f01014d1:	89 04 24             	mov    %eax,(%esp)
f01014d4:	e8 11 4c 00 00       	call   f01060ea <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014d9:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014e3:	77 20                	ja     f0101505 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014e9:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f01014f0:	f0 
f01014f1:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f01014f8:	00 
f01014f9:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101500:	e8 3b eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101505:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010150b:	83 ca 05             	or     $0x5,%edx
f010150e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f0101514:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f0101519:	c1 e0 03             	shl    $0x3,%eax
f010151c:	e8 d4 f5 ff ff       	call   f0100af5 <boot_alloc>
f0101521:	a3 90 1e 33 f0       	mov    %eax,0xf0331e90
	memset(pages, 0, sizeof(struct PageInfo)*npages); 
f0101526:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f010152c:	c1 e2 03             	shl    $0x3,%edx
f010152f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101533:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010153a:	00 
f010153b:	89 04 24             	mov    %eax,(%esp)
f010153e:	e8 a7 4b 00 00       	call   f01060ea <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0101543:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101548:	e8 a8 f5 ff ff       	call   f0100af5 <boot_alloc>
f010154d:	a3 48 12 33 f0       	mov    %eax,0xf0331248
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101552:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101559:	00 
f010155a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101561:	00 
f0101562:	89 04 24             	mov    %eax,(%esp)
f0101565:	e8 80 4b 00 00       	call   f01060ea <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010156a:	e8 87 f9 ff ff       	call   f0100ef6 <page_init>

	check_page_free_list(1);
f010156f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101574:	e8 2a f6 ff ff       	call   f0100ba3 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101579:	83 3d 90 1e 33 f0 00 	cmpl   $0x0,0xf0331e90
f0101580:	75 1c                	jne    f010159e <mem_init+0x185>
	  panic("'pages' is a null pointer!");
f0101582:	c7 44 24 08 32 7e 10 	movl   $0xf0107e32,0x8(%esp)
f0101589:	f0 
f010158a:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0101591:	00 
f0101592:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101599:	e8 a2 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010159e:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f01015a3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015a8:	eb 03                	jmp    f01015ad <mem_init+0x194>
	  ++nfree;
f01015aa:	43                   	inc    %ebx

	if (!pages)
	  panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015ab:	8b 00                	mov    (%eax),%eax
f01015ad:	85 c0                	test   %eax,%eax
f01015af:	75 f9                	jne    f01015aa <mem_init+0x191>
	  ++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015b8:	e8 ce f9 ff ff       	call   f0100f8b <page_alloc>
f01015bd:	89 c6                	mov    %eax,%esi
f01015bf:	85 c0                	test   %eax,%eax
f01015c1:	75 24                	jne    f01015e7 <mem_init+0x1ce>
f01015c3:	c7 44 24 0c 4d 7e 10 	movl   $0xf0107e4d,0xc(%esp)
f01015ca:	f0 
f01015cb:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01015d2:	f0 
f01015d3:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f01015da:	00 
f01015db:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01015e2:	e8 59 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ee:	e8 98 f9 ff ff       	call   f0100f8b <page_alloc>
f01015f3:	89 c7                	mov    %eax,%edi
f01015f5:	85 c0                	test   %eax,%eax
f01015f7:	75 24                	jne    f010161d <mem_init+0x204>
f01015f9:	c7 44 24 0c 63 7e 10 	movl   $0xf0107e63,0xc(%esp)
f0101600:	f0 
f0101601:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101608:	f0 
f0101609:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0101610:	00 
f0101611:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101618:	e8 23 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010161d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101624:	e8 62 f9 ff ff       	call   f0100f8b <page_alloc>
f0101629:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010162c:	85 c0                	test   %eax,%eax
f010162e:	75 24                	jne    f0101654 <mem_init+0x23b>
f0101630:	c7 44 24 0c 79 7e 10 	movl   $0xf0107e79,0xc(%esp)
f0101637:	f0 
f0101638:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010163f:	f0 
f0101640:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101647:	00 
f0101648:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010164f:	e8 ec e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101654:	39 fe                	cmp    %edi,%esi
f0101656:	75 24                	jne    f010167c <mem_init+0x263>
f0101658:	c7 44 24 0c 8f 7e 10 	movl   $0xf0107e8f,0xc(%esp)
f010165f:	f0 
f0101660:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101667:	f0 
f0101668:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f010166f:	00 
f0101670:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101677:	e8 c4 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010167c:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010167f:	74 05                	je     f0101686 <mem_init+0x26d>
f0101681:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101684:	75 24                	jne    f01016aa <mem_init+0x291>
f0101686:	c7 44 24 0c 20 75 10 	movl   $0xf0107520,0xc(%esp)
f010168d:	f0 
f010168e:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101695:	f0 
f0101696:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f010169d:	00 
f010169e:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01016a5:	e8 96 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016aa:	8b 15 90 1e 33 f0    	mov    0xf0331e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016b0:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f01016b5:	c1 e0 0c             	shl    $0xc,%eax
f01016b8:	89 f1                	mov    %esi,%ecx
f01016ba:	29 d1                	sub    %edx,%ecx
f01016bc:	c1 f9 03             	sar    $0x3,%ecx
f01016bf:	c1 e1 0c             	shl    $0xc,%ecx
f01016c2:	39 c1                	cmp    %eax,%ecx
f01016c4:	72 24                	jb     f01016ea <mem_init+0x2d1>
f01016c6:	c7 44 24 0c a1 7e 10 	movl   $0xf0107ea1,0xc(%esp)
f01016cd:	f0 
f01016ce:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01016d5:	f0 
f01016d6:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01016dd:	00 
f01016de:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01016e5:	e8 56 e9 ff ff       	call   f0100040 <_panic>
f01016ea:	89 f9                	mov    %edi,%ecx
f01016ec:	29 d1                	sub    %edx,%ecx
f01016ee:	c1 f9 03             	sar    $0x3,%ecx
f01016f1:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01016f4:	39 c8                	cmp    %ecx,%eax
f01016f6:	77 24                	ja     f010171c <mem_init+0x303>
f01016f8:	c7 44 24 0c be 7e 10 	movl   $0xf0107ebe,0xc(%esp)
f01016ff:	f0 
f0101700:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101707:	f0 
f0101708:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010170f:	00 
f0101710:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101717:	e8 24 e9 ff ff       	call   f0100040 <_panic>
f010171c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010171f:	29 d1                	sub    %edx,%ecx
f0101721:	89 ca                	mov    %ecx,%edx
f0101723:	c1 fa 03             	sar    $0x3,%edx
f0101726:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101729:	39 d0                	cmp    %edx,%eax
f010172b:	77 24                	ja     f0101751 <mem_init+0x338>
f010172d:	c7 44 24 0c db 7e 10 	movl   $0xf0107edb,0xc(%esp)
f0101734:	f0 
f0101735:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010173c:	f0 
f010173d:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0101744:	00 
f0101745:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010174c:	e8 ef e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101751:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f0101756:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101759:	c7 05 40 12 33 f0 00 	movl   $0x0,0xf0331240
f0101760:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101763:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010176a:	e8 1c f8 ff ff       	call   f0100f8b <page_alloc>
f010176f:	85 c0                	test   %eax,%eax
f0101771:	74 24                	je     f0101797 <mem_init+0x37e>
f0101773:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f010177a:	f0 
f010177b:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101782:	f0 
f0101783:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f010178a:	00 
f010178b:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101792:	e8 a9 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101797:	89 34 24             	mov    %esi,(%esp)
f010179a:	e8 9f f8 ff ff       	call   f010103e <page_free>
	page_free(pp1);
f010179f:	89 3c 24             	mov    %edi,(%esp)
f01017a2:	e8 97 f8 ff ff       	call   f010103e <page_free>
	page_free(pp2);
f01017a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017aa:	89 04 24             	mov    %eax,(%esp)
f01017ad:	e8 8c f8 ff ff       	call   f010103e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017b9:	e8 cd f7 ff ff       	call   f0100f8b <page_alloc>
f01017be:	89 c6                	mov    %eax,%esi
f01017c0:	85 c0                	test   %eax,%eax
f01017c2:	75 24                	jne    f01017e8 <mem_init+0x3cf>
f01017c4:	c7 44 24 0c 4d 7e 10 	movl   $0xf0107e4d,0xc(%esp)
f01017cb:	f0 
f01017cc:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01017d3:	f0 
f01017d4:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01017db:	00 
f01017dc:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01017e3:	e8 58 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ef:	e8 97 f7 ff ff       	call   f0100f8b <page_alloc>
f01017f4:	89 c7                	mov    %eax,%edi
f01017f6:	85 c0                	test   %eax,%eax
f01017f8:	75 24                	jne    f010181e <mem_init+0x405>
f01017fa:	c7 44 24 0c 63 7e 10 	movl   $0xf0107e63,0xc(%esp)
f0101801:	f0 
f0101802:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101809:	f0 
f010180a:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101811:	00 
f0101812:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101819:	e8 22 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010181e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101825:	e8 61 f7 ff ff       	call   f0100f8b <page_alloc>
f010182a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010182d:	85 c0                	test   %eax,%eax
f010182f:	75 24                	jne    f0101855 <mem_init+0x43c>
f0101831:	c7 44 24 0c 79 7e 10 	movl   $0xf0107e79,0xc(%esp)
f0101838:	f0 
f0101839:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101840:	f0 
f0101841:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101848:	00 
f0101849:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101850:	e8 eb e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101855:	39 fe                	cmp    %edi,%esi
f0101857:	75 24                	jne    f010187d <mem_init+0x464>
f0101859:	c7 44 24 0c 8f 7e 10 	movl   $0xf0107e8f,0xc(%esp)
f0101860:	f0 
f0101861:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101868:	f0 
f0101869:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0101870:	00 
f0101871:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101878:	e8 c3 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010187d:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101880:	74 05                	je     f0101887 <mem_init+0x46e>
f0101882:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101885:	75 24                	jne    f01018ab <mem_init+0x492>
f0101887:	c7 44 24 0c 20 75 10 	movl   $0xf0107520,0xc(%esp)
f010188e:	f0 
f010188f:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101896:	f0 
f0101897:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f010189e:	00 
f010189f:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01018a6:	e8 95 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01018ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018b2:	e8 d4 f6 ff ff       	call   f0100f8b <page_alloc>
f01018b7:	85 c0                	test   %eax,%eax
f01018b9:	74 24                	je     f01018df <mem_init+0x4c6>
f01018bb:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f01018c2:	f0 
f01018c3:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01018ca:	f0 
f01018cb:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f01018d2:	00 
f01018d3:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01018da:	e8 61 e7 ff ff       	call   f0100040 <_panic>
f01018df:	89 f0                	mov    %esi,%eax
f01018e1:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01018e7:	c1 f8 03             	sar    $0x3,%eax
f01018ea:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018ed:	89 c2                	mov    %eax,%edx
f01018ef:	c1 ea 0c             	shr    $0xc,%edx
f01018f2:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f01018f8:	72 20                	jb     f010191a <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018fe:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0101905:	f0 
f0101906:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010190d:	00 
f010190e:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0101915:	e8 26 e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010191a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101921:	00 
f0101922:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101929:	00 
	return (void *)(pa + KERNBASE);
f010192a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010192f:	89 04 24             	mov    %eax,(%esp)
f0101932:	e8 b3 47 00 00       	call   f01060ea <memset>
	page_free(pp0);
f0101937:	89 34 24             	mov    %esi,(%esp)
f010193a:	e8 ff f6 ff ff       	call   f010103e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010193f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101946:	e8 40 f6 ff ff       	call   f0100f8b <page_alloc>
f010194b:	85 c0                	test   %eax,%eax
f010194d:	75 24                	jne    f0101973 <mem_init+0x55a>
f010194f:	c7 44 24 0c 07 7f 10 	movl   $0xf0107f07,0xc(%esp)
f0101956:	f0 
f0101957:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010195e:	f0 
f010195f:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101966:	00 
f0101967:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010196e:	e8 cd e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101973:	39 c6                	cmp    %eax,%esi
f0101975:	74 24                	je     f010199b <mem_init+0x582>
f0101977:	c7 44 24 0c 25 7f 10 	movl   $0xf0107f25,0xc(%esp)
f010197e:	f0 
f010197f:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101986:	f0 
f0101987:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f010198e:	00 
f010198f:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101996:	e8 a5 e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010199b:	89 f2                	mov    %esi,%edx
f010199d:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01019a3:	c1 fa 03             	sar    $0x3,%edx
f01019a6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019a9:	89 d0                	mov    %edx,%eax
f01019ab:	c1 e8 0c             	shr    $0xc,%eax
f01019ae:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f01019b4:	72 20                	jb     f01019d6 <mem_init+0x5bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01019ba:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f01019c1:	f0 
f01019c2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019c9:	00 
f01019ca:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f01019d1:	e8 6a e6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01019d6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01019dc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
	  assert(c[i] == 0);
f01019e2:	80 38 00             	cmpb   $0x0,(%eax)
f01019e5:	74 24                	je     f0101a0b <mem_init+0x5f2>
f01019e7:	c7 44 24 0c 35 7f 10 	movl   $0xf0107f35,0xc(%esp)
f01019ee:	f0 
f01019ef:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01019f6:	f0 
f01019f7:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01019fe:	00 
f01019ff:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101a06:	e8 35 e6 ff ff       	call   f0100040 <_panic>
f0101a0b:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a0c:	39 d0                	cmp    %edx,%eax
f0101a0e:	75 d2                	jne    f01019e2 <mem_init+0x5c9>
	  assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a10:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a13:	89 15 40 12 33 f0    	mov    %edx,0xf0331240

	// free the pages we took
	page_free(pp0);
f0101a19:	89 34 24             	mov    %esi,(%esp)
f0101a1c:	e8 1d f6 ff ff       	call   f010103e <page_free>
	page_free(pp1);
f0101a21:	89 3c 24             	mov    %edi,(%esp)
f0101a24:	e8 15 f6 ff ff       	call   f010103e <page_free>
	page_free(pp2);
f0101a29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a2c:	89 04 24             	mov    %eax,(%esp)
f0101a2f:	e8 0a f6 ff ff       	call   f010103e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a34:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f0101a39:	eb 03                	jmp    f0101a3e <mem_init+0x625>
	  --nfree;
f0101a3b:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a3c:	8b 00                	mov    (%eax),%eax
f0101a3e:	85 c0                	test   %eax,%eax
f0101a40:	75 f9                	jne    f0101a3b <mem_init+0x622>
	  --nfree;
	assert(nfree == 0);
f0101a42:	85 db                	test   %ebx,%ebx
f0101a44:	74 24                	je     f0101a6a <mem_init+0x651>
f0101a46:	c7 44 24 0c 3f 7f 10 	movl   $0xf0107f3f,0xc(%esp)
f0101a4d:	f0 
f0101a4e:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101a55:	f0 
f0101a56:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101a5d:	00 
f0101a5e:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101a65:	e8 d6 e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a6a:	c7 04 24 40 75 10 f0 	movl   $0xf0107540,(%esp)
f0101a71:	e8 10 25 00 00       	call   f0103f86 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a7d:	e8 09 f5 ff ff       	call   f0100f8b <page_alloc>
f0101a82:	89 c7                	mov    %eax,%edi
f0101a84:	85 c0                	test   %eax,%eax
f0101a86:	75 24                	jne    f0101aac <mem_init+0x693>
f0101a88:	c7 44 24 0c 4d 7e 10 	movl   $0xf0107e4d,0xc(%esp)
f0101a8f:	f0 
f0101a90:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101a97:	f0 
f0101a98:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0101a9f:	00 
f0101aa0:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101aa7:	e8 94 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101aac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ab3:	e8 d3 f4 ff ff       	call   f0100f8b <page_alloc>
f0101ab8:	89 c6                	mov    %eax,%esi
f0101aba:	85 c0                	test   %eax,%eax
f0101abc:	75 24                	jne    f0101ae2 <mem_init+0x6c9>
f0101abe:	c7 44 24 0c 63 7e 10 	movl   $0xf0107e63,0xc(%esp)
f0101ac5:	f0 
f0101ac6:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101acd:	f0 
f0101ace:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101ad5:	00 
f0101ad6:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101add:	e8 5e e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ae2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae9:	e8 9d f4 ff ff       	call   f0100f8b <page_alloc>
f0101aee:	89 c3                	mov    %eax,%ebx
f0101af0:	85 c0                	test   %eax,%eax
f0101af2:	75 24                	jne    f0101b18 <mem_init+0x6ff>
f0101af4:	c7 44 24 0c 79 7e 10 	movl   $0xf0107e79,0xc(%esp)
f0101afb:	f0 
f0101afc:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101b03:	f0 
f0101b04:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101b0b:	00 
f0101b0c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101b13:	e8 28 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b18:	39 f7                	cmp    %esi,%edi
f0101b1a:	75 24                	jne    f0101b40 <mem_init+0x727>
f0101b1c:	c7 44 24 0c 8f 7e 10 	movl   $0xf0107e8f,0xc(%esp)
f0101b23:	f0 
f0101b24:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101b2b:	f0 
f0101b2c:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101b33:	00 
f0101b34:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101b3b:	e8 00 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b40:	39 c6                	cmp    %eax,%esi
f0101b42:	74 04                	je     f0101b48 <mem_init+0x72f>
f0101b44:	39 c7                	cmp    %eax,%edi
f0101b46:	75 24                	jne    f0101b6c <mem_init+0x753>
f0101b48:	c7 44 24 0c 20 75 10 	movl   $0xf0107520,0xc(%esp)
f0101b4f:	f0 
f0101b50:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101b57:	f0 
f0101b58:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101b5f:	00 
f0101b60:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101b67:	e8 d4 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b6c:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0101b72:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101b75:	c7 05 40 12 33 f0 00 	movl   $0x0,0xf0331240
f0101b7c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b86:	e8 00 f4 ff ff       	call   f0100f8b <page_alloc>
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	74 24                	je     f0101bb3 <mem_init+0x79a>
f0101b8f:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f0101b96:	f0 
f0101b97:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101b9e:	f0 
f0101b9f:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101ba6:	00 
f0101ba7:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101bae:	e8 8d e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101bb3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bb6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bc1:	00 
f0101bc2:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101bc7:	89 04 24             	mov    %eax,(%esp)
f0101bca:	e8 4d f6 ff ff       	call   f010121c <page_lookup>
f0101bcf:	85 c0                	test   %eax,%eax
f0101bd1:	74 24                	je     f0101bf7 <mem_init+0x7de>
f0101bd3:	c7 44 24 0c 60 75 10 	movl   $0xf0107560,0xc(%esp)
f0101bda:	f0 
f0101bdb:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101be2:	f0 
f0101be3:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0101bea:	00 
f0101beb:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101bf2:	e8 49 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bf7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bfe:	00 
f0101bff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c06:	00 
f0101c07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c0b:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101c10:	89 04 24             	mov    %eax,(%esp)
f0101c13:	e8 0d f7 ff ff       	call   f0101325 <page_insert>
f0101c18:	85 c0                	test   %eax,%eax
f0101c1a:	78 24                	js     f0101c40 <mem_init+0x827>
f0101c1c:	c7 44 24 0c 98 75 10 	movl   $0xf0107598,0xc(%esp)
f0101c23:	f0 
f0101c24:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101c2b:	f0 
f0101c2c:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101c33:	00 
f0101c34:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101c3b:	e8 00 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c40:	89 3c 24             	mov    %edi,(%esp)
f0101c43:	e8 f6 f3 ff ff       	call   f010103e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c48:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c4f:	00 
f0101c50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c57:	00 
f0101c58:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c5c:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101c61:	89 04 24             	mov    %eax,(%esp)
f0101c64:	e8 bc f6 ff ff       	call   f0101325 <page_insert>
f0101c69:	85 c0                	test   %eax,%eax
f0101c6b:	74 24                	je     f0101c91 <mem_init+0x878>
f0101c6d:	c7 44 24 0c c8 75 10 	movl   $0xf01075c8,0xc(%esp)
f0101c74:	f0 
f0101c75:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101c7c:	f0 
f0101c7d:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101c84:	00 
f0101c85:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101c8c:	e8 af e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c91:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0101c97:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101c9a:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
f0101c9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ca2:	8b 11                	mov    (%ecx),%edx
f0101ca4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101caa:	89 f8                	mov    %edi,%eax
f0101cac:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101caf:	c1 f8 03             	sar    $0x3,%eax
f0101cb2:	c1 e0 0c             	shl    $0xc,%eax
f0101cb5:	39 c2                	cmp    %eax,%edx
f0101cb7:	74 24                	je     f0101cdd <mem_init+0x8c4>
f0101cb9:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f0101cc0:	f0 
f0101cc1:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101cc8:	f0 
f0101cc9:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101cd0:	00 
f0101cd1:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101cd8:	e8 63 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cdd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ce2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ce5:	e8 9e ed ff ff       	call   f0100a88 <check_va2pa>
f0101cea:	89 f2                	mov    %esi,%edx
f0101cec:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101cef:	c1 fa 03             	sar    $0x3,%edx
f0101cf2:	c1 e2 0c             	shl    $0xc,%edx
f0101cf5:	39 d0                	cmp    %edx,%eax
f0101cf7:	74 24                	je     f0101d1d <mem_init+0x904>
f0101cf9:	c7 44 24 0c 20 76 10 	movl   $0xf0107620,0xc(%esp)
f0101d00:	f0 
f0101d01:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101d08:	f0 
f0101d09:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101d10:	00 
f0101d11:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101d18:	e8 23 e3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d1d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d22:	74 24                	je     f0101d48 <mem_init+0x92f>
f0101d24:	c7 44 24 0c 4a 7f 10 	movl   $0xf0107f4a,0xc(%esp)
f0101d2b:	f0 
f0101d2c:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101d33:	f0 
f0101d34:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101d3b:	00 
f0101d3c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101d43:	e8 f8 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d48:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d4d:	74 24                	je     f0101d73 <mem_init+0x95a>
f0101d4f:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f0101d56:	f0 
f0101d57:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101d5e:	f0 
f0101d5f:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101d66:	00 
f0101d67:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101d6e:	e8 cd e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d73:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d7a:	00 
f0101d7b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d82:	00 
f0101d83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d87:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d8a:	89 14 24             	mov    %edx,(%esp)
f0101d8d:	e8 93 f5 ff ff       	call   f0101325 <page_insert>
f0101d92:	85 c0                	test   %eax,%eax
f0101d94:	74 24                	je     f0101dba <mem_init+0x9a1>
f0101d96:	c7 44 24 0c 50 76 10 	movl   $0xf0107650,0xc(%esp)
f0101d9d:	f0 
f0101d9e:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101dad:	00 
f0101dae:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101db5:	e8 86 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dba:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dbf:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101dc4:	e8 bf ec ff ff       	call   f0100a88 <check_va2pa>
f0101dc9:	89 da                	mov    %ebx,%edx
f0101dcb:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101dd1:	c1 fa 03             	sar    $0x3,%edx
f0101dd4:	c1 e2 0c             	shl    $0xc,%edx
f0101dd7:	39 d0                	cmp    %edx,%eax
f0101dd9:	74 24                	je     f0101dff <mem_init+0x9e6>
f0101ddb:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f0101de2:	f0 
f0101de3:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101dea:	f0 
f0101deb:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101df2:	00 
f0101df3:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101dfa:	e8 41 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101dff:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e04:	74 24                	je     f0101e2a <mem_init+0xa11>
f0101e06:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0101e0d:	f0 
f0101e0e:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101e15:	f0 
f0101e16:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101e1d:	00 
f0101e1e:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101e25:	e8 16 e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e2a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e31:	e8 55 f1 ff ff       	call   f0100f8b <page_alloc>
f0101e36:	85 c0                	test   %eax,%eax
f0101e38:	74 24                	je     f0101e5e <mem_init+0xa45>
f0101e3a:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f0101e41:	f0 
f0101e42:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101e49:	f0 
f0101e4a:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101e51:	00 
f0101e52:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101e59:	e8 e2 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e5e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e65:	00 
f0101e66:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e6d:	00 
f0101e6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e72:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101e77:	89 04 24             	mov    %eax,(%esp)
f0101e7a:	e8 a6 f4 ff ff       	call   f0101325 <page_insert>
f0101e7f:	85 c0                	test   %eax,%eax
f0101e81:	74 24                	je     f0101ea7 <mem_init+0xa8e>
f0101e83:	c7 44 24 0c 50 76 10 	movl   $0xf0107650,0xc(%esp)
f0101e8a:	f0 
f0101e8b:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101e92:	f0 
f0101e93:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101e9a:	00 
f0101e9b:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101ea2:	e8 99 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ea7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eac:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101eb1:	e8 d2 eb ff ff       	call   f0100a88 <check_va2pa>
f0101eb6:	89 da                	mov    %ebx,%edx
f0101eb8:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101ebe:	c1 fa 03             	sar    $0x3,%edx
f0101ec1:	c1 e2 0c             	shl    $0xc,%edx
f0101ec4:	39 d0                	cmp    %edx,%eax
f0101ec6:	74 24                	je     f0101eec <mem_init+0xad3>
f0101ec8:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f0101ecf:	f0 
f0101ed0:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101ed7:	f0 
f0101ed8:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101edf:	00 
f0101ee0:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101ee7:	e8 54 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101eec:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ef1:	74 24                	je     f0101f17 <mem_init+0xafe>
f0101ef3:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0101efa:	f0 
f0101efb:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101f02:	f0 
f0101f03:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101f0a:	00 
f0101f0b:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101f12:	e8 29 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f1e:	e8 68 f0 ff ff       	call   f0100f8b <page_alloc>
f0101f23:	85 c0                	test   %eax,%eax
f0101f25:	74 24                	je     f0101f4b <mem_init+0xb32>
f0101f27:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f0101f2e:	f0 
f0101f2f:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101f36:	f0 
f0101f37:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101f3e:	00 
f0101f3f:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101f46:	e8 f5 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f4b:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f0101f51:	8b 02                	mov    (%edx),%eax
f0101f53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f58:	89 c1                	mov    %eax,%ecx
f0101f5a:	c1 e9 0c             	shr    $0xc,%ecx
f0101f5d:	3b 0d 88 1e 33 f0    	cmp    0xf0331e88,%ecx
f0101f63:	72 20                	jb     f0101f85 <mem_init+0xb6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f69:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0101f70:	f0 
f0101f71:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101f78:	00 
f0101f79:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101f80:	e8 bb e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101f85:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f94:	00 
f0101f95:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f9c:	00 
f0101f9d:	89 14 24             	mov    %edx,(%esp)
f0101fa0:	e8 15 f1 ff ff       	call   f01010ba <pgdir_walk>
f0101fa5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101fa8:	83 c2 04             	add    $0x4,%edx
f0101fab:	39 d0                	cmp    %edx,%eax
f0101fad:	74 24                	je     f0101fd3 <mem_init+0xbba>
f0101faf:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f0101fb6:	f0 
f0101fb7:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0101fbe:	f0 
f0101fbf:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101fc6:	00 
f0101fc7:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0101fce:	e8 6d e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101fd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101fda:	00 
f0101fdb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fe2:	00 
f0101fe3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fe7:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101fec:	89 04 24             	mov    %eax,(%esp)
f0101fef:	e8 31 f3 ff ff       	call   f0101325 <page_insert>
f0101ff4:	85 c0                	test   %eax,%eax
f0101ff6:	74 24                	je     f010201c <mem_init+0xc03>
f0101ff8:	c7 44 24 0c fc 76 10 	movl   $0xf01076fc,0xc(%esp)
f0101fff:	f0 
f0102000:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102007:	f0 
f0102008:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010200f:	00 
f0102010:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102017:	e8 24 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010201c:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0102022:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102025:	ba 00 10 00 00       	mov    $0x1000,%edx
f010202a:	89 c8                	mov    %ecx,%eax
f010202c:	e8 57 ea ff ff       	call   f0100a88 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102031:	89 da                	mov    %ebx,%edx
f0102033:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102039:	c1 fa 03             	sar    $0x3,%edx
f010203c:	c1 e2 0c             	shl    $0xc,%edx
f010203f:	39 d0                	cmp    %edx,%eax
f0102041:	74 24                	je     f0102067 <mem_init+0xc4e>
f0102043:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f010204a:	f0 
f010204b:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102052:	f0 
f0102053:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010205a:	00 
f010205b:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102062:	e8 d9 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102067:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010206c:	74 24                	je     f0102092 <mem_init+0xc79>
f010206e:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0102075:	f0 
f0102076:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010207d:	f0 
f010207e:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102085:	00 
f0102086:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010208d:	e8 ae df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102092:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102099:	00 
f010209a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020a1:	00 
f01020a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a5:	89 04 24             	mov    %eax,(%esp)
f01020a8:	e8 0d f0 ff ff       	call   f01010ba <pgdir_walk>
f01020ad:	f6 00 04             	testb  $0x4,(%eax)
f01020b0:	75 24                	jne    f01020d6 <mem_init+0xcbd>
f01020b2:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f01020b9:	f0 
f01020ba:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01020c1:	f0 
f01020c2:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01020c9:	00 
f01020ca:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01020d1:	e8 6a df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020d6:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01020db:	f6 00 04             	testb  $0x4,(%eax)
f01020de:	75 24                	jne    f0102104 <mem_init+0xceb>
f01020e0:	c7 44 24 0c 7d 7f 10 	movl   $0xf0107f7d,0xc(%esp)
f01020e7:	f0 
f01020e8:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01020ef:	f0 
f01020f0:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01020f7:	00 
f01020f8:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01020ff:	e8 3c df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102104:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010210b:	00 
f010210c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102113:	00 
f0102114:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102118:	89 04 24             	mov    %eax,(%esp)
f010211b:	e8 05 f2 ff ff       	call   f0101325 <page_insert>
f0102120:	85 c0                	test   %eax,%eax
f0102122:	74 24                	je     f0102148 <mem_init+0xd2f>
f0102124:	c7 44 24 0c 50 76 10 	movl   $0xf0107650,0xc(%esp)
f010212b:	f0 
f010212c:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102133:	f0 
f0102134:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010213b:	00 
f010213c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102148:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010214f:	00 
f0102150:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102157:	00 
f0102158:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010215d:	89 04 24             	mov    %eax,(%esp)
f0102160:	e8 55 ef ff ff       	call   f01010ba <pgdir_walk>
f0102165:	f6 00 02             	testb  $0x2,(%eax)
f0102168:	75 24                	jne    f010218e <mem_init+0xd75>
f010216a:	c7 44 24 0c 70 77 10 	movl   $0xf0107770,0xc(%esp)
f0102171:	f0 
f0102172:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102179:	f0 
f010217a:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102181:	00 
f0102182:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010218e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102195:	00 
f0102196:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010219d:	00 
f010219e:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01021a3:	89 04 24             	mov    %eax,(%esp)
f01021a6:	e8 0f ef ff ff       	call   f01010ba <pgdir_walk>
f01021ab:	f6 00 04             	testb  $0x4,(%eax)
f01021ae:	74 24                	je     f01021d4 <mem_init+0xdbb>
f01021b0:	c7 44 24 0c a4 77 10 	movl   $0xf01077a4,0xc(%esp)
f01021b7:	f0 
f01021b8:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01021bf:	f0 
f01021c0:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f01021c7:	00 
f01021c8:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01021cf:	e8 6c de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01021d4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021db:	00 
f01021dc:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01021e3:	00 
f01021e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01021e8:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01021ed:	89 04 24             	mov    %eax,(%esp)
f01021f0:	e8 30 f1 ff ff       	call   f0101325 <page_insert>
f01021f5:	85 c0                	test   %eax,%eax
f01021f7:	78 24                	js     f010221d <mem_init+0xe04>
f01021f9:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f0102200:	f0 
f0102201:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102208:	f0 
f0102209:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102210:	00 
f0102211:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102218:	e8 23 de ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010221d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102224:	00 
f0102225:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010222c:	00 
f010222d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102231:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102236:	89 04 24             	mov    %eax,(%esp)
f0102239:	e8 e7 f0 ff ff       	call   f0101325 <page_insert>
f010223e:	85 c0                	test   %eax,%eax
f0102240:	74 24                	je     f0102266 <mem_init+0xe4d>
f0102242:	c7 44 24 0c 14 78 10 	movl   $0xf0107814,0xc(%esp)
f0102249:	f0 
f010224a:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102251:	f0 
f0102252:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102259:	00 
f010225a:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102261:	e8 da dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102266:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010226d:	00 
f010226e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102275:	00 
f0102276:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010227b:	89 04 24             	mov    %eax,(%esp)
f010227e:	e8 37 ee ff ff       	call   f01010ba <pgdir_walk>
f0102283:	f6 00 04             	testb  $0x4,(%eax)
f0102286:	74 24                	je     f01022ac <mem_init+0xe93>
f0102288:	c7 44 24 0c a4 77 10 	movl   $0xf01077a4,0xc(%esp)
f010228f:	f0 
f0102290:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102297:	f0 
f0102298:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f010229f:	00 
f01022a0:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01022a7:	e8 94 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022ac:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01022b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01022b9:	e8 ca e7 ff ff       	call   f0100a88 <check_va2pa>
f01022be:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022c1:	89 f0                	mov    %esi,%eax
f01022c3:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01022c9:	c1 f8 03             	sar    $0x3,%eax
f01022cc:	c1 e0 0c             	shl    $0xc,%eax
f01022cf:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01022d2:	74 24                	je     f01022f8 <mem_init+0xedf>
f01022d4:	c7 44 24 0c 50 78 10 	movl   $0xf0107850,0xc(%esp)
f01022db:	f0 
f01022dc:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01022e3:	f0 
f01022e4:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01022eb:	00 
f01022ec:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01022f3:	e8 48 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022f8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102300:	e8 83 e7 ff ff       	call   f0100a88 <check_va2pa>
f0102305:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102308:	74 24                	je     f010232e <mem_init+0xf15>
f010230a:	c7 44 24 0c 7c 78 10 	movl   $0xf010787c,0xc(%esp)
f0102311:	f0 
f0102312:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102319:	f0 
f010231a:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102321:	00 
f0102322:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102329:	e8 12 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010232e:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102333:	74 24                	je     f0102359 <mem_init+0xf40>
f0102335:	c7 44 24 0c 93 7f 10 	movl   $0xf0107f93,0xc(%esp)
f010233c:	f0 
f010233d:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102344:	f0 
f0102345:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010234c:	00 
f010234d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102354:	e8 e7 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102359:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010235e:	74 24                	je     f0102384 <mem_init+0xf6b>
f0102360:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f0102367:	f0 
f0102368:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010236f:	f0 
f0102370:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102377:	00 
f0102378:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010237f:	e8 bc dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010238b:	e8 fb eb ff ff       	call   f0100f8b <page_alloc>
f0102390:	85 c0                	test   %eax,%eax
f0102392:	74 04                	je     f0102398 <mem_init+0xf7f>
f0102394:	39 c3                	cmp    %eax,%ebx
f0102396:	74 24                	je     f01023bc <mem_init+0xfa3>
f0102398:	c7 44 24 0c ac 78 10 	movl   $0xf01078ac,0xc(%esp)
f010239f:	f0 
f01023a0:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01023a7:	f0 
f01023a8:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01023af:	00 
f01023b0:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01023b7:	e8 84 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01023c3:	00 
f01023c4:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01023c9:	89 04 24             	mov    %eax,(%esp)
f01023cc:	e8 04 ef ff ff       	call   f01012d5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023d1:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f01023d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01023da:	ba 00 00 00 00       	mov    $0x0,%edx
f01023df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023e2:	e8 a1 e6 ff ff       	call   f0100a88 <check_va2pa>
f01023e7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023ea:	74 24                	je     f0102410 <mem_init+0xff7>
f01023ec:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f01023f3:	f0 
f01023f4:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01023fb:	f0 
f01023fc:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102403:	00 
f0102404:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010240b:	e8 30 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102410:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102415:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102418:	e8 6b e6 ff ff       	call   f0100a88 <check_va2pa>
f010241d:	89 f2                	mov    %esi,%edx
f010241f:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102425:	c1 fa 03             	sar    $0x3,%edx
f0102428:	c1 e2 0c             	shl    $0xc,%edx
f010242b:	39 d0                	cmp    %edx,%eax
f010242d:	74 24                	je     f0102453 <mem_init+0x103a>
f010242f:	c7 44 24 0c 7c 78 10 	movl   $0xf010787c,0xc(%esp)
f0102436:	f0 
f0102437:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010243e:	f0 
f010243f:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102446:	00 
f0102447:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010244e:	e8 ed db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102453:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102458:	74 24                	je     f010247e <mem_init+0x1065>
f010245a:	c7 44 24 0c 4a 7f 10 	movl   $0xf0107f4a,0xc(%esp)
f0102461:	f0 
f0102462:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102469:	f0 
f010246a:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102471:	00 
f0102472:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102479:	e8 c2 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010247e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102483:	74 24                	je     f01024a9 <mem_init+0x1090>
f0102485:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f010248c:	f0 
f010248d:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102494:	f0 
f0102495:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f010249c:	00 
f010249d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01024a4:	e8 97 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01024a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01024b0:	00 
f01024b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024b8:	00 
f01024b9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024bd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024c0:	89 0c 24             	mov    %ecx,(%esp)
f01024c3:	e8 5d ee ff ff       	call   f0101325 <page_insert>
f01024c8:	85 c0                	test   %eax,%eax
f01024ca:	74 24                	je     f01024f0 <mem_init+0x10d7>
f01024cc:	c7 44 24 0c f4 78 10 	movl   $0xf01078f4,0xc(%esp)
f01024d3:	f0 
f01024d4:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01024db:	f0 
f01024dc:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01024e3:	00 
f01024e4:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01024eb:	e8 50 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01024f0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024f5:	75 24                	jne    f010251b <mem_init+0x1102>
f01024f7:	c7 44 24 0c b5 7f 10 	movl   $0xf0107fb5,0xc(%esp)
f01024fe:	f0 
f01024ff:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102506:	f0 
f0102507:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010250e:	00 
f010250f:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102516:	e8 25 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010251b:	83 3e 00             	cmpl   $0x0,(%esi)
f010251e:	74 24                	je     f0102544 <mem_init+0x112b>
f0102520:	c7 44 24 0c c1 7f 10 	movl   $0xf0107fc1,0xc(%esp)
f0102527:	f0 
f0102528:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010252f:	f0 
f0102530:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102537:	00 
f0102538:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010253f:	e8 fc da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102544:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010254b:	00 
f010254c:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102551:	89 04 24             	mov    %eax,(%esp)
f0102554:	e8 7c ed ff ff       	call   f01012d5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102559:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010255e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102561:	ba 00 00 00 00       	mov    $0x0,%edx
f0102566:	e8 1d e5 ff ff       	call   f0100a88 <check_va2pa>
f010256b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010256e:	74 24                	je     f0102594 <mem_init+0x117b>
f0102570:	c7 44 24 0c d0 78 10 	movl   $0xf01078d0,0xc(%esp)
f0102577:	f0 
f0102578:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010257f:	f0 
f0102580:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102587:	00 
f0102588:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010258f:	e8 ac da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102594:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102599:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010259c:	e8 e7 e4 ff ff       	call   f0100a88 <check_va2pa>
f01025a1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025a4:	74 24                	je     f01025ca <mem_init+0x11b1>
f01025a6:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f01025ad:	f0 
f01025ae:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01025b5:	f0 
f01025b6:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01025bd:	00 
f01025be:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01025c5:	e8 76 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01025ca:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025cf:	74 24                	je     f01025f5 <mem_init+0x11dc>
f01025d1:	c7 44 24 0c d6 7f 10 	movl   $0xf0107fd6,0xc(%esp)
f01025d8:	f0 
f01025d9:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01025e0:	f0 
f01025e1:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f01025e8:	00 
f01025e9:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01025f0:	e8 4b da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025f5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025fa:	74 24                	je     f0102620 <mem_init+0x1207>
f01025fc:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f0102603:	f0 
f0102604:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010260b:	f0 
f010260c:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102613:	00 
f0102614:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010261b:	e8 20 da ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102627:	e8 5f e9 ff ff       	call   f0100f8b <page_alloc>
f010262c:	85 c0                	test   %eax,%eax
f010262e:	74 04                	je     f0102634 <mem_init+0x121b>
f0102630:	39 c6                	cmp    %eax,%esi
f0102632:	74 24                	je     f0102658 <mem_init+0x123f>
f0102634:	c7 44 24 0c 54 79 10 	movl   $0xf0107954,0xc(%esp)
f010263b:	f0 
f010263c:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102643:	f0 
f0102644:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010264b:	00 
f010264c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102653:	e8 e8 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010265f:	e8 27 e9 ff ff       	call   f0100f8b <page_alloc>
f0102664:	85 c0                	test   %eax,%eax
f0102666:	74 24                	je     f010268c <mem_init+0x1273>
f0102668:	c7 44 24 0c f8 7e 10 	movl   $0xf0107ef8,0xc(%esp)
f010266f:	f0 
f0102670:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102677:	f0 
f0102678:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f010267f:	00 
f0102680:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102687:	e8 b4 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010268c:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102691:	8b 08                	mov    (%eax),%ecx
f0102693:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102699:	89 fa                	mov    %edi,%edx
f010269b:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01026a1:	c1 fa 03             	sar    $0x3,%edx
f01026a4:	c1 e2 0c             	shl    $0xc,%edx
f01026a7:	39 d1                	cmp    %edx,%ecx
f01026a9:	74 24                	je     f01026cf <mem_init+0x12b6>
f01026ab:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f01026b2:	f0 
f01026b3:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01026ba:	f0 
f01026bb:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f01026c2:	00 
f01026c3:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01026ca:	e8 71 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01026cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01026d5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01026da:	74 24                	je     f0102700 <mem_init+0x12e7>
f01026dc:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f01026e3:	f0 
f01026e4:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01026eb:	f0 
f01026ec:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f01026f3:	00 
f01026f4:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01026fb:	e8 40 d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102700:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102706:	89 3c 24             	mov    %edi,(%esp)
f0102709:	e8 30 e9 ff ff       	call   f010103e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010270e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102715:	00 
f0102716:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010271d:	00 
f010271e:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102723:	89 04 24             	mov    %eax,(%esp)
f0102726:	e8 8f e9 ff ff       	call   f01010ba <pgdir_walk>
f010272b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010272e:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0102734:	8b 51 04             	mov    0x4(%ecx),%edx
f0102737:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010273d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102740:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f0102746:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102749:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010274c:	c1 ea 0c             	shr    $0xc,%edx
f010274f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102752:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102755:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102758:	72 23                	jb     f010277d <mem_init+0x1364>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010275a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010275d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102761:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0102768:	f0 
f0102769:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0102770:	00 
f0102771:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102778:	e8 c3 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010277d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102780:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102786:	39 d0                	cmp    %edx,%eax
f0102788:	74 24                	je     f01027ae <mem_init+0x1395>
f010278a:	c7 44 24 0c e7 7f 10 	movl   $0xf0107fe7,0xc(%esp)
f0102791:	f0 
f0102792:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102799:	f0 
f010279a:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01027a1:	00 
f01027a2:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01027a9:	e8 92 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027ae:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01027b5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027bb:	89 f8                	mov    %edi,%eax
f01027bd:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01027c3:	c1 f8 03             	sar    $0x3,%eax
f01027c6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027c9:	89 c1                	mov    %eax,%ecx
f01027cb:	c1 e9 0c             	shr    $0xc,%ecx
f01027ce:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01027d1:	77 20                	ja     f01027f3 <mem_init+0x13da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027d7:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f01027de:	f0 
f01027df:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01027e6:	00 
f01027e7:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f01027ee:	e8 4d d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01027fa:	00 
f01027fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102802:	00 
	return (void *)(pa + KERNBASE);
f0102803:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102808:	89 04 24             	mov    %eax,(%esp)
f010280b:	e8 da 38 00 00       	call   f01060ea <memset>
	page_free(pp0);
f0102810:	89 3c 24             	mov    %edi,(%esp)
f0102813:	e8 26 e8 ff ff       	call   f010103e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102818:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010281f:	00 
f0102820:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102827:	00 
f0102828:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010282d:	89 04 24             	mov    %eax,(%esp)
f0102830:	e8 85 e8 ff ff       	call   f01010ba <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102835:	89 fa                	mov    %edi,%edx
f0102837:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f010283d:	c1 fa 03             	sar    $0x3,%edx
f0102840:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102843:	89 d0                	mov    %edx,%eax
f0102845:	c1 e8 0c             	shr    $0xc,%eax
f0102848:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f010284e:	72 20                	jb     f0102870 <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102850:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102854:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f010285b:	f0 
f010285c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102863:	00 
f0102864:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f010286b:	e8 d0 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102870:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102876:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102879:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
	  assert((ptep[i] & PTE_P) == 0);
f010287f:	f6 00 01             	testb  $0x1,(%eax)
f0102882:	74 24                	je     f01028a8 <mem_init+0x148f>
f0102884:	c7 44 24 0c ff 7f 10 	movl   $0xf0107fff,0xc(%esp)
f010288b:	f0 
f010288c:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102893:	f0 
f0102894:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f010289b:	00 
f010289c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01028a3:	e8 98 d7 ff ff       	call   f0100040 <_panic>
f01028a8:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028ab:	39 d0                	cmp    %edx,%eax
f01028ad:	75 d0                	jne    f010287f <mem_init+0x1466>
	  assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028af:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01028b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028ba:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01028c0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01028c3:	89 0d 40 12 33 f0    	mov    %ecx,0xf0331240

	// free the pages we took
	page_free(pp0);
f01028c9:	89 3c 24             	mov    %edi,(%esp)
f01028cc:	e8 6d e7 ff ff       	call   f010103e <page_free>
	page_free(pp1);
f01028d1:	89 34 24             	mov    %esi,(%esp)
f01028d4:	e8 65 e7 ff ff       	call   f010103e <page_free>
	page_free(pp2);
f01028d9:	89 1c 24             	mov    %ebx,(%esp)
f01028dc:	e8 5d e7 ff ff       	call   f010103e <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01028e1:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01028e8:	00 
f01028e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028f0:	e8 b6 ea ff ff       	call   f01013ab <mmio_map_region>
f01028f5:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01028f7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028fe:	00 
f01028ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102906:	e8 a0 ea ff ff       	call   f01013ab <mmio_map_region>
f010290b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010290d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102913:	76 0d                	jbe    f0102922 <mem_init+0x1509>
f0102915:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010291b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102920:	76 24                	jbe    f0102946 <mem_init+0x152d>
f0102922:	c7 44 24 0c 78 79 10 	movl   $0xf0107978,0xc(%esp)
f0102929:	f0 
f010292a:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102931:	f0 
f0102932:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102939:	00 
f010293a:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102941:	e8 fa d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102946:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010294c:	76 0e                	jbe    f010295c <mem_init+0x1543>
f010294e:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102954:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010295a:	76 24                	jbe    f0102980 <mem_init+0x1567>
f010295c:	c7 44 24 0c a0 79 10 	movl   $0xf01079a0,0xc(%esp)
f0102963:	f0 
f0102964:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010296b:	f0 
f010296c:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102973:	00 
f0102974:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010297b:	e8 c0 d6 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102980:	89 da                	mov    %ebx,%edx
f0102982:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102984:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010298a:	74 24                	je     f01029b0 <mem_init+0x1597>
f010298c:	c7 44 24 0c c8 79 10 	movl   $0xf01079c8,0xc(%esp)
f0102993:	f0 
f0102994:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f010299b:	f0 
f010299c:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f01029a3:	00 
f01029a4:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01029ab:	e8 90 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01029b0:	39 c6                	cmp    %eax,%esi
f01029b2:	73 24                	jae    f01029d8 <mem_init+0x15bf>
f01029b4:	c7 44 24 0c 16 80 10 	movl   $0xf0108016,0xc(%esp)
f01029bb:	f0 
f01029bc:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01029c3:	f0 
f01029c4:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f01029cb:	00 
f01029cc:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01029d3:	e8 68 d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01029d8:	8b 3d 8c 1e 33 f0    	mov    0xf0331e8c,%edi
f01029de:	89 da                	mov    %ebx,%edx
f01029e0:	89 f8                	mov    %edi,%eax
f01029e2:	e8 a1 e0 ff ff       	call   f0100a88 <check_va2pa>
f01029e7:	85 c0                	test   %eax,%eax
f01029e9:	74 24                	je     f0102a0f <mem_init+0x15f6>
f01029eb:	c7 44 24 0c f0 79 10 	movl   $0xf01079f0,0xc(%esp)
f01029f2:	f0 
f01029f3:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01029fa:	f0 
f01029fb:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102a02:	00 
f0102a03:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102a0a:	e8 31 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a0f:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a18:	89 c2                	mov    %eax,%edx
f0102a1a:	89 f8                	mov    %edi,%eax
f0102a1c:	e8 67 e0 ff ff       	call   f0100a88 <check_va2pa>
f0102a21:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a26:	74 24                	je     f0102a4c <mem_init+0x1633>
f0102a28:	c7 44 24 0c 14 7a 10 	movl   $0xf0107a14,0xc(%esp)
f0102a2f:	f0 
f0102a30:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102a37:	f0 
f0102a38:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102a3f:	00 
f0102a40:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102a47:	e8 f4 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a4c:	89 f2                	mov    %esi,%edx
f0102a4e:	89 f8                	mov    %edi,%eax
f0102a50:	e8 33 e0 ff ff       	call   f0100a88 <check_va2pa>
f0102a55:	85 c0                	test   %eax,%eax
f0102a57:	74 24                	je     f0102a7d <mem_init+0x1664>
f0102a59:	c7 44 24 0c 44 7a 10 	movl   $0xf0107a44,0xc(%esp)
f0102a60:	f0 
f0102a61:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102a68:	f0 
f0102a69:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102a70:	00 
f0102a71:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102a78:	e8 c3 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102a7d:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102a83:	89 f8                	mov    %edi,%eax
f0102a85:	e8 fe df ff ff       	call   f0100a88 <check_va2pa>
f0102a8a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a8d:	74 24                	je     f0102ab3 <mem_init+0x169a>
f0102a8f:	c7 44 24 0c 68 7a 10 	movl   $0xf0107a68,0xc(%esp)
f0102a96:	f0 
f0102a97:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102a9e:	f0 
f0102a9f:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102aa6:	00 
f0102aa7:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102aae:	e8 8d d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102ab3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102aba:	00 
f0102abb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102abf:	89 3c 24             	mov    %edi,(%esp)
f0102ac2:	e8 f3 e5 ff ff       	call   f01010ba <pgdir_walk>
f0102ac7:	f6 00 1a             	testb  $0x1a,(%eax)
f0102aca:	75 24                	jne    f0102af0 <mem_init+0x16d7>
f0102acc:	c7 44 24 0c 94 7a 10 	movl   $0xf0107a94,0xc(%esp)
f0102ad3:	f0 
f0102ad4:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102adb:	f0 
f0102adc:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102ae3:	00 
f0102ae4:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102aeb:	e8 50 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102af0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102af7:	00 
f0102af8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102afc:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b01:	89 04 24             	mov    %eax,(%esp)
f0102b04:	e8 b1 e5 ff ff       	call   f01010ba <pgdir_walk>
f0102b09:	f6 00 04             	testb  $0x4,(%eax)
f0102b0c:	74 24                	je     f0102b32 <mem_init+0x1719>
f0102b0e:	c7 44 24 0c d8 7a 10 	movl   $0xf0107ad8,0xc(%esp)
f0102b15:	f0 
f0102b16:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102b1d:	f0 
f0102b1e:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102b25:	00 
f0102b26:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102b2d:	e8 0e d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b32:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b39:	00 
f0102b3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b3e:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b43:	89 04 24             	mov    %eax,(%esp)
f0102b46:	e8 6f e5 ff ff       	call   f01010ba <pgdir_walk>
f0102b4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102b51:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b58:	00 
f0102b59:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b5c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102b60:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b65:	89 04 24             	mov    %eax,(%esp)
f0102b68:	e8 4d e5 ff ff       	call   f01010ba <pgdir_walk>
f0102b6d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102b73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b7a:	00 
f0102b7b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102b7f:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b84:	89 04 24             	mov    %eax,(%esp)
f0102b87:	e8 2e e5 ff ff       	call   f01010ba <pgdir_walk>
f0102b8c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102b92:	c7 04 24 28 80 10 f0 	movl   $0xf0108028,(%esp)
f0102b99:	e8 e8 13 00 00       	call   f0103f86 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U|PTE_P);
f0102b9e:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ba3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ba8:	77 20                	ja     f0102bca <mem_init+0x17b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102baa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bae:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0102bb5:	f0 
f0102bb6:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102bbd:	00 
f0102bbe:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102bc5:	e8 76 d4 ff ff       	call   f0100040 <_panic>
f0102bca:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f0102bd0:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102bd7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102bdd:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102be4:	00 
	return (physaddr_t)kva - KERNBASE;
f0102be5:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bea:	89 04 24             	mov    %eax,(%esp)
f0102bed:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102bf2:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102bf7:	e8 c3 e5 ff ff       	call   f01011bf <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f0102bfc:	a1 48 12 33 f0       	mov    0xf0331248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c01:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c06:	77 20                	ja     f0102c28 <mem_init+0x180f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c0c:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0102c13:	f0 
f0102c14:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102c1b:	00 
f0102c1c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102c23:	e8 18 d4 ff ff       	call   f0100040 <_panic>
f0102c28:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102c2f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c30:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c35:	89 04 24             	mov    %eax,(%esp)
f0102c38:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c3d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c42:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102c47:	e8 73 e5 ff ff       	call   f01011bf <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0, PTE_W);
f0102c4c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c53:	00 
f0102c54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c5b:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102c60:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c65:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102c6a:	e8 50 e5 ff ff       	call   f01011bf <boot_map_region>
f0102c6f:	c7 45 cc 00 30 33 f0 	movl   $0xf0333000,-0x34(%ebp)
f0102c76:	bb 00 30 33 f0       	mov    $0xf0333000,%ebx
f0102c7b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c80:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102c86:	77 20                	ja     f0102ca8 <mem_init+0x188f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c88:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102c8c:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0102c93:	f0 
f0102c94:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
f0102c9b:	00 
f0102c9c:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102ca3:	e8 98 d3 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir, (uint32_t)(KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);	
f0102ca8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102caf:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cb0:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir, (uint32_t)(KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);	
f0102cb6:	89 04 24             	mov    %eax,(%esp)
f0102cb9:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cbe:	89 f2                	mov    %esi,%edx
f0102cc0:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102cc5:	e8 f5 e4 ff ff       	call   f01011bf <boot_map_region>
f0102cca:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102cd0:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
f0102cd6:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102cdc:	75 a2                	jne    f0102c80 <mem_init+0x1867>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102cde:	8b 1d 8c 1e 33 f0    	mov    0xf0331e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ce4:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f0102cea:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102ced:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102cf4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102cfa:	be 00 00 00 00       	mov    $0x0,%esi
f0102cff:	eb 70                	jmp    f0102d71 <mem_init+0x1958>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d01:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d07:	89 d8                	mov    %ebx,%eax
f0102d09:	e8 7a dd ff ff       	call   f0100a88 <check_va2pa>
f0102d0e:	8b 15 90 1e 33 f0    	mov    0xf0331e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d14:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d1a:	77 20                	ja     f0102d3c <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d20:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0102d27:	f0 
f0102d28:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102d2f:	00 
f0102d30:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102d37:	e8 04 d3 ff ff       	call   f0100040 <_panic>
f0102d3c:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d43:	39 d0                	cmp    %edx,%eax
f0102d45:	74 24                	je     f0102d6b <mem_init+0x1952>
f0102d47:	c7 44 24 0c 0c 7b 10 	movl   $0xf0107b0c,0xc(%esp)
f0102d4e:	f0 
f0102d4f:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102d56:	f0 
f0102d57:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102d5e:	00 
f0102d5f:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102d66:	e8 d5 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d6b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d71:	39 f7                	cmp    %esi,%edi
f0102d73:	77 8c                	ja     f0102d01 <mem_init+0x18e8>
f0102d75:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d7a:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d80:	89 d8                	mov    %ebx,%eax
f0102d82:	e8 01 dd ff ff       	call   f0100a88 <check_va2pa>
f0102d87:	8b 15 48 12 33 f0    	mov    0xf0331248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d8d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d93:	77 20                	ja     f0102db5 <mem_init+0x199c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d95:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d99:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0102da0:	f0 
f0102da1:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102da8:	00 
f0102da9:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102db0:	e8 8b d2 ff ff       	call   f0100040 <_panic>
f0102db5:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102dbc:	39 d0                	cmp    %edx,%eax
f0102dbe:	74 24                	je     f0102de4 <mem_init+0x19cb>
f0102dc0:	c7 44 24 0c 40 7b 10 	movl   $0xf0107b40,0xc(%esp)
f0102dc7:	f0 
f0102dc8:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102dcf:	f0 
f0102dd0:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102dd7:	00 
f0102dd8:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102ddf:	e8 5c d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102de4:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102dea:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102df0:	75 88                	jne    f0102d7a <mem_init+0x1961>
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102df2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102df5:	c1 e7 0c             	shl    $0xc,%edi
f0102df8:	be 00 00 00 00       	mov    $0x0,%esi
f0102dfd:	eb 3b                	jmp    f0102e3a <mem_init+0x1a21>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dff:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	  assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e05:	89 d8                	mov    %ebx,%eax
f0102e07:	e8 7c dc ff ff       	call   f0100a88 <check_va2pa>
f0102e0c:	39 c6                	cmp    %eax,%esi
f0102e0e:	74 24                	je     f0102e34 <mem_init+0x1a1b>
f0102e10:	c7 44 24 0c 74 7b 10 	movl   $0xf0107b74,0xc(%esp)
f0102e17:	f0 
f0102e18:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102e1f:	f0 
f0102e20:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102e27:	00 
f0102e28:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102e2f:	e8 0c d2 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e34:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e3a:	39 fe                	cmp    %edi,%esi
f0102e3c:	72 c1                	jb     f0102dff <mem_init+0x19e6>
f0102e3e:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102e43:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e46:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e49:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e4c:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e52:	89 c6                	mov    %eax,%esi
f0102e54:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102e5a:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102e60:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e63:	89 da                	mov    %ebx,%edx
f0102e65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e68:	e8 1b dc ff ff       	call   f0100a88 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e6d:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e74:	77 23                	ja     f0102e99 <mem_init+0x1a80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e76:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102e7d:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0102e84:	f0 
f0102e85:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102e8c:	00 
f0102e8d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102e94:	e8 a7 d1 ff ff       	call   f0100040 <_panic>
f0102e99:	39 f0                	cmp    %esi,%eax
f0102e9b:	74 24                	je     f0102ec1 <mem_init+0x1aa8>
f0102e9d:	c7 44 24 0c 9c 7b 10 	movl   $0xf0107b9c,0xc(%esp)
f0102ea4:	f0 
f0102ea5:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102eac:	f0 
f0102ead:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102eb4:	00 
f0102eb5:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102ebc:	e8 7f d1 ff ff       	call   f0100040 <_panic>
f0102ec1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ec7:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102ecd:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102ed0:	0f 85 55 05 00 00    	jne    f010342b <mem_init+0x2012>
f0102ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102edb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
					  == PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + i) == ~0);
f0102ede:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102ee1:	89 f0                	mov    %esi,%eax
f0102ee3:	e8 a0 db ff ff       	call   f0100a88 <check_va2pa>
f0102ee8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102eeb:	74 24                	je     f0102f11 <mem_init+0x1af8>
f0102eed:	c7 44 24 0c e4 7b 10 	movl   $0xf0107be4,0xc(%esp)
f0102ef4:	f0 
f0102ef5:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102efc:	f0 
f0102efd:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102f04:	00 
f0102f05:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102f0c:	e8 2f d1 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
					  == PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f11:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f17:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f1d:	75 bf                	jne    f0102ede <mem_init+0x1ac5>
f0102f1f:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102f25:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	  assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f2c:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102f32:	0f 85 0e ff ff ff    	jne    f0102e46 <mem_init+0x1a2d>
f0102f38:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f3b:	b8 00 00 00 00       	mov    $0x0,%eax
		  assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f40:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f46:	83 fa 04             	cmp    $0x4,%edx
f0102f49:	77 2e                	ja     f0102f79 <mem_init+0x1b60>
			case PDX(UVPT):
			case PDX(KSTACKTOP-1):
			case PDX(UPAGES):
			case PDX(UENVS):
			case PDX(MMIOBASE):
				assert(pgdir[i] & PTE_P);
f0102f4b:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f4f:	0f 85 aa 00 00 00    	jne    f0102fff <mem_init+0x1be6>
f0102f55:	c7 44 24 0c 41 80 10 	movl   $0xf0108041,0xc(%esp)
f0102f5c:	f0 
f0102f5d:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102f64:	f0 
f0102f65:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0102f6c:	00 
f0102f6d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102f74:	e8 c7 d0 ff ff       	call   f0100040 <_panic>
				break;
			default:
				if (i >= PDX(KERNBASE)) {
f0102f79:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f7e:	76 55                	jbe    f0102fd5 <mem_init+0x1bbc>
					assert(pgdir[i] & PTE_P);
f0102f80:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102f83:	f6 c2 01             	test   $0x1,%dl
f0102f86:	75 24                	jne    f0102fac <mem_init+0x1b93>
f0102f88:	c7 44 24 0c 41 80 10 	movl   $0xf0108041,0xc(%esp)
f0102f8f:	f0 
f0102f90:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102f97:	f0 
f0102f98:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102f9f:	00 
f0102fa0:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102fa7:	e8 94 d0 ff ff       	call   f0100040 <_panic>
					assert(pgdir[i] & PTE_W);
f0102fac:	f6 c2 02             	test   $0x2,%dl
f0102faf:	75 4e                	jne    f0102fff <mem_init+0x1be6>
f0102fb1:	c7 44 24 0c 52 80 10 	movl   $0xf0108052,0xc(%esp)
f0102fb8:	f0 
f0102fb9:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102fc0:	f0 
f0102fc1:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102fc8:	00 
f0102fc9:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102fd0:	e8 6b d0 ff ff       	call   f0100040 <_panic>
				} else
				  assert(pgdir[i] == 0);
f0102fd5:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102fd9:	74 24                	je     f0102fff <mem_init+0x1be6>
f0102fdb:	c7 44 24 0c 63 80 10 	movl   $0xf0108063,0xc(%esp)
f0102fe2:	f0 
f0102fe3:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0102fea:	f0 
f0102feb:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0102ff2:	00 
f0102ff3:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0102ffa:	e8 41 d0 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102fff:	40                   	inc    %eax
f0103000:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103005:	0f 85 35 ff ff ff    	jne    f0102f40 <mem_init+0x1b27>
				} else
				  assert(pgdir[i] == 0);
				break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010300b:	c7 04 24 08 7c 10 f0 	movl   $0xf0107c08,(%esp)
f0103012:	e8 6f 0f 00 00       	call   f0103f86 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103017:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010301c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103021:	77 20                	ja     f0103043 <mem_init+0x1c2a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103023:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103027:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f010302e:	f0 
f010302f:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0103036:	00 
f0103037:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f010303e:	e8 fd cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103043:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103048:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010304b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103050:	e8 4e db ff ff       	call   f0100ba3 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103055:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103058:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010305d:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103060:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103063:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010306a:	e8 1c df ff ff       	call   f0100f8b <page_alloc>
f010306f:	89 c6                	mov    %eax,%esi
f0103071:	85 c0                	test   %eax,%eax
f0103073:	75 24                	jne    f0103099 <mem_init+0x1c80>
f0103075:	c7 44 24 0c 4d 7e 10 	movl   $0xf0107e4d,0xc(%esp)
f010307c:	f0 
f010307d:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0103084:	f0 
f0103085:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f010308c:	00 
f010308d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103094:	e8 a7 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0103099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030a0:	e8 e6 de ff ff       	call   f0100f8b <page_alloc>
f01030a5:	89 c7                	mov    %eax,%edi
f01030a7:	85 c0                	test   %eax,%eax
f01030a9:	75 24                	jne    f01030cf <mem_init+0x1cb6>
f01030ab:	c7 44 24 0c 63 7e 10 	movl   $0xf0107e63,0xc(%esp)
f01030b2:	f0 
f01030b3:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01030ba:	f0 
f01030bb:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f01030c2:	00 
f01030c3:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01030ca:	e8 71 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01030cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030d6:	e8 b0 de ff ff       	call   f0100f8b <page_alloc>
f01030db:	89 c3                	mov    %eax,%ebx
f01030dd:	85 c0                	test   %eax,%eax
f01030df:	75 24                	jne    f0103105 <mem_init+0x1cec>
f01030e1:	c7 44 24 0c 79 7e 10 	movl   $0xf0107e79,0xc(%esp)
f01030e8:	f0 
f01030e9:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01030f0:	f0 
f01030f1:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f01030f8:	00 
f01030f9:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103100:	e8 3b cf ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103105:	89 34 24             	mov    %esi,(%esp)
f0103108:	e8 31 df ff ff       	call   f010103e <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010310d:	89 f8                	mov    %edi,%eax
f010310f:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0103115:	c1 f8 03             	sar    $0x3,%eax
f0103118:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010311b:	89 c2                	mov    %eax,%edx
f010311d:	c1 ea 0c             	shr    $0xc,%edx
f0103120:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0103126:	72 20                	jb     f0103148 <mem_init+0x1d2f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103128:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010312c:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0103133:	f0 
f0103134:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010313b:	00 
f010313c:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0103143:	e8 f8 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103148:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010314f:	00 
f0103150:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103157:	00 
	return (void *)(pa + KERNBASE);
f0103158:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010315d:	89 04 24             	mov    %eax,(%esp)
f0103160:	e8 85 2f 00 00       	call   f01060ea <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103165:	89 d8                	mov    %ebx,%eax
f0103167:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f010316d:	c1 f8 03             	sar    $0x3,%eax
f0103170:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103173:	89 c2                	mov    %eax,%edx
f0103175:	c1 ea 0c             	shr    $0xc,%edx
f0103178:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f010317e:	72 20                	jb     f01031a0 <mem_init+0x1d87>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103180:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103184:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f010318b:	f0 
f010318c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103193:	00 
f0103194:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f010319b:	e8 a0 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031a0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031a7:	00 
f01031a8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031af:	00 
	return (void *)(pa + KERNBASE);
f01031b0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031b5:	89 04 24             	mov    %eax,(%esp)
f01031b8:	e8 2d 2f 00 00       	call   f01060ea <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031bd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01031c4:	00 
f01031c5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031cc:	00 
f01031cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01031d1:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01031d6:	89 04 24             	mov    %eax,(%esp)
f01031d9:	e8 47 e1 ff ff       	call   f0101325 <page_insert>
	assert(pp1->pp_ref == 1);
f01031de:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01031e3:	74 24                	je     f0103209 <mem_init+0x1df0>
f01031e5:	c7 44 24 0c 4a 7f 10 	movl   $0xf0107f4a,0xc(%esp)
f01031ec:	f0 
f01031ed:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01031f4:	f0 
f01031f5:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f01031fc:	00 
f01031fd:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103204:	e8 37 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103209:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103210:	01 01 01 
f0103213:	74 24                	je     f0103239 <mem_init+0x1e20>
f0103215:	c7 44 24 0c 28 7c 10 	movl   $0xf0107c28,0xc(%esp)
f010321c:	f0 
f010321d:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0103224:	f0 
f0103225:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f010322c:	00 
f010322d:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103234:	e8 07 ce ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103239:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103240:	00 
f0103241:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103248:	00 
f0103249:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010324d:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0103252:	89 04 24             	mov    %eax,(%esp)
f0103255:	e8 cb e0 ff ff       	call   f0101325 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010325a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103261:	02 02 02 
f0103264:	74 24                	je     f010328a <mem_init+0x1e71>
f0103266:	c7 44 24 0c 4c 7c 10 	movl   $0xf0107c4c,0xc(%esp)
f010326d:	f0 
f010326e:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0103275:	f0 
f0103276:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f010327d:	00 
f010327e:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103285:	e8 b6 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010328a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010328f:	74 24                	je     f01032b5 <mem_init+0x1e9c>
f0103291:	c7 44 24 0c 6c 7f 10 	movl   $0xf0107f6c,0xc(%esp)
f0103298:	f0 
f0103299:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01032a0:	f0 
f01032a1:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01032a8:	00 
f01032a9:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01032b0:	e8 8b cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01032b5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032ba:	74 24                	je     f01032e0 <mem_init+0x1ec7>
f01032bc:	c7 44 24 0c d6 7f 10 	movl   $0xf0107fd6,0xc(%esp)
f01032c3:	f0 
f01032c4:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01032cb:	f0 
f01032cc:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f01032d3:	00 
f01032d4:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01032db:	e8 60 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01032e0:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01032e7:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01032ea:	89 d8                	mov    %ebx,%eax
f01032ec:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01032f2:	c1 f8 03             	sar    $0x3,%eax
f01032f5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032f8:	89 c2                	mov    %eax,%edx
f01032fa:	c1 ea 0c             	shr    $0xc,%edx
f01032fd:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0103303:	72 20                	jb     f0103325 <mem_init+0x1f0c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103305:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103309:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0103310:	f0 
f0103311:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103318:	00 
f0103319:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0103320:	e8 1b cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103325:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010332c:	03 03 03 
f010332f:	74 24                	je     f0103355 <mem_init+0x1f3c>
f0103331:	c7 44 24 0c 70 7c 10 	movl   $0xf0107c70,0xc(%esp)
f0103338:	f0 
f0103339:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0103340:	f0 
f0103341:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0103348:	00 
f0103349:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103350:	e8 eb cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103355:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010335c:	00 
f010335d:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0103362:	89 04 24             	mov    %eax,(%esp)
f0103365:	e8 6b df ff ff       	call   f01012d5 <page_remove>
	assert(pp2->pp_ref == 0);
f010336a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010336f:	74 24                	je     f0103395 <mem_init+0x1f7c>
f0103371:	c7 44 24 0c a4 7f 10 	movl   $0xf0107fa4,0xc(%esp)
f0103378:	f0 
f0103379:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0103380:	f0 
f0103381:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0103388:	00 
f0103389:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103390:	e8 ab cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103395:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010339a:	8b 08                	mov    (%eax),%ecx
f010339c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033a2:	89 f2                	mov    %esi,%edx
f01033a4:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01033aa:	c1 fa 03             	sar    $0x3,%edx
f01033ad:	c1 e2 0c             	shl    $0xc,%edx
f01033b0:	39 d1                	cmp    %edx,%ecx
f01033b2:	74 24                	je     f01033d8 <mem_init+0x1fbf>
f01033b4:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f01033bb:	f0 
f01033bc:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01033c3:	f0 
f01033c4:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f01033cb:	00 
f01033cc:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f01033d3:	e8 68 cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01033d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01033de:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01033e3:	74 24                	je     f0103409 <mem_init+0x1ff0>
f01033e5:	c7 44 24 0c 5b 7f 10 	movl   $0xf0107f5b,0xc(%esp)
f01033ec:	f0 
f01033ed:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01033f4:	f0 
f01033f5:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f01033fc:	00 
f01033fd:	c7 04 24 fd 7c 10 f0 	movl   $0xf0107cfd,(%esp)
f0103404:	e8 37 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103409:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010340f:	89 34 24             	mov    %esi,(%esp)
f0103412:	e8 27 dc ff ff       	call   f010103e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103417:	c7 04 24 9c 7c 10 f0 	movl   $0xf0107c9c,(%esp)
f010341e:	e8 63 0b 00 00       	call   f0103f86 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103423:	83 c4 3c             	add    $0x3c,%esp
f0103426:	5b                   	pop    %ebx
f0103427:	5e                   	pop    %esi
f0103428:	5f                   	pop    %edi
f0103429:	5d                   	pop    %ebp
f010342a:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010342b:	89 da                	mov    %ebx,%edx
f010342d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103430:	e8 53 d6 ff ff       	call   f0100a88 <check_va2pa>
f0103435:	e9 5f fa ff ff       	jmp    f0102e99 <mem_init+0x1a80>

f010343a <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010343a:	55                   	push   %ebp
f010343b:	89 e5                	mov    %esp,%ebp
f010343d:	57                   	push   %edi
f010343e:	56                   	push   %esi
f010343f:	53                   	push   %ebx
f0103440:	83 ec 1c             	sub    $0x1c,%esp
f0103443:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103446:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.

	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
f0103449:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344c:	a3 44 12 33 f0       	mov    %eax,0xf0331244
	pte_t* pte;	

	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f0103451:	89 c6                	mov    %eax,%esi
f0103453:	03 75 10             	add    0x10(%ebp),%esi
f0103456:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f010345c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0103462:	eb 5e                	jmp    f01034c2 <user_mem_check+0x88>
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
f0103464:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010346b:	00 
f010346c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103471:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103475:	8b 43 60             	mov    0x60(%ebx),%eax
f0103478:	89 04 24             	mov    %eax,(%esp)
f010347b:	e8 3a dc ff ff       	call   f01010ba <pgdir_walk>
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
f0103480:	85 c0                	test   %eax,%eax
f0103482:	74 19                	je     f010349d <user_mem_check+0x63>
f0103484:	8b 00                	mov    (%eax),%eax
f0103486:	89 fa                	mov    %edi,%edx
f0103488:	83 ca 01             	or     $0x1,%edx
f010348b:	09 c2                	or     %eax,%edx
f010348d:	39 d0                	cmp    %edx,%eax
f010348f:	75 0c                	jne    f010349d <user_mem_check+0x63>
f0103491:	a1 44 12 33 f0       	mov    0xf0331244,%eax
f0103496:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010349b:	76 1b                	jbe    f01034b8 <user_mem_check+0x7e>
			if (user_mem_check_addr != start)
f010349d:	a1 44 12 33 f0       	mov    0xf0331244,%eax
f01034a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
f01034a5:	74 2b                	je     f01034d2 <user_mem_check+0x98>
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
f01034a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034ac:	a3 44 12 33 f0       	mov    %eax,0xf0331244
			return -E_FAULT;
f01034b1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034b6:	eb 1f                	jmp    f01034d7 <user_mem_check+0x9d>

	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
	pte_t* pte;	

	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f01034b8:	05 00 10 00 00       	add    $0x1000,%eax
f01034bd:	a3 44 12 33 f0       	mov    %eax,0xf0331244
f01034c2:	a1 44 12 33 f0       	mov    0xf0331244,%eax
f01034c7:	39 c6                	cmp    %eax,%esi
f01034c9:	77 99                	ja     f0103464 <user_mem_check+0x2a>
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
		}
	}

	return 0;
f01034cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01034d0:	eb 05                	jmp    f01034d7 <user_mem_check+0x9d>
	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
			if (user_mem_check_addr != start)
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
f01034d2:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		}
	}

	return 0;
}
f01034d7:	83 c4 1c             	add    $0x1c,%esp
f01034da:	5b                   	pop    %ebx
f01034db:	5e                   	pop    %esi
f01034dc:	5f                   	pop    %edi
f01034dd:	5d                   	pop    %ebp
f01034de:	c3                   	ret    

f01034df <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01034df:	55                   	push   %ebp
f01034e0:	89 e5                	mov    %esp,%ebp
f01034e2:	53                   	push   %ebx
f01034e3:	83 ec 14             	sub    $0x14,%esp
f01034e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01034e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01034ec:	83 c8 04             	or     $0x4,%eax
f01034ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01034f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103501:	89 1c 24             	mov    %ebx,(%esp)
f0103504:	e8 31 ff ff ff       	call   f010343a <user_mem_check>
f0103509:	85 c0                	test   %eax,%eax
f010350b:	79 24                	jns    f0103531 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010350d:	a1 44 12 33 f0       	mov    0xf0331244,%eax
f0103512:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103516:	8b 43 48             	mov    0x48(%ebx),%eax
f0103519:	89 44 24 04          	mov    %eax,0x4(%esp)
f010351d:	c7 04 24 c8 7c 10 f0 	movl   $0xf0107cc8,(%esp)
f0103524:	e8 5d 0a 00 00       	call   f0103f86 <cprintf>
					"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103529:	89 1c 24             	mov    %ebx,(%esp)
f010352c:	e8 8e 07 00 00       	call   f0103cbf <env_destroy>
	}
}
f0103531:	83 c4 14             	add    $0x14,%esp
f0103534:	5b                   	pop    %ebx
f0103535:	5d                   	pop    %ebp
f0103536:	c3                   	ret    
	...

f0103538 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103538:	55                   	push   %ebp
f0103539:	89 e5                	mov    %esp,%ebp
f010353b:	57                   	push   %edi
f010353c:	56                   	push   %esi
f010353d:	53                   	push   %ebx
f010353e:	83 ec 1c             	sub    $0x1c,%esp
f0103541:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
f0103543:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f010354a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010354f:	89 c7                	mov    %eax,%edi
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
f0103551:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0103556:	77 0d                	ja     f0103565 <region_alloc+0x2d>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
f0103558:	89 d3                	mov    %edx,%ebx
f010355a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103560:	e9 89 00 00 00       	jmp    f01035ee <region_alloc+0xb6>
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
f0103565:	c7 44 24 08 74 80 10 	movl   $0xf0108074,0x8(%esp)
f010356c:	f0 
f010356d:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f0103574:	00 
f0103575:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f010357c:	e8 bf ca ff ff       	call   f0100040 <_panic>
	int r;
	for (; min<max; min+=PGSIZE){
		pp = page_alloc(0);	
f0103581:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103588:	e8 fe d9 ff ff       	call   f0100f8b <page_alloc>
		if (!pp) 	
f010358d:	85 c0                	test   %eax,%eax
f010358f:	75 1c                	jne    f01035ad <region_alloc+0x75>
			panic("region_alloc:page alloc failed");
f0103591:	c7 44 24 08 94 80 10 	movl   $0xf0108094,0x8(%esp)
f0103598:	f0 
f0103599:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f01035a0:	00 
f01035a1:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f01035a8:	e8 93 ca ff ff       	call   f0100040 <_panic>
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
f01035ad:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035b4:	00 
f01035b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035bd:	8b 46 60             	mov    0x60(%esi),%eax
f01035c0:	89 04 24             	mov    %eax,(%esp)
f01035c3:	e8 5d dd ff ff       	call   f0101325 <page_insert>
		if (r != 0) 
f01035c8:	85 c0                	test   %eax,%eax
f01035ca:	74 1c                	je     f01035e8 <region_alloc+0xb0>
			panic("region_alloc: page insert failed");
f01035cc:	c7 44 24 08 b4 80 10 	movl   $0xf01080b4,0x8(%esp)
f01035d3:	f0 
f01035d4:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f01035db:	00 
f01035dc:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f01035e3:	e8 58 ca ff ff       	call   f0100040 <_panic>
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
	int r;
	for (; min<max; min+=PGSIZE){
f01035e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035ee:	39 fb                	cmp    %edi,%ebx
f01035f0:	72 8f                	jb     f0103581 <region_alloc+0x49>
			panic("region_alloc:page alloc failed");
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
		if (r != 0) 
			panic("region_alloc: page insert failed");
	}
}
f01035f2:	83 c4 1c             	add    $0x1c,%esp
f01035f5:	5b                   	pop    %ebx
f01035f6:	5e                   	pop    %esi
f01035f7:	5f                   	pop    %edi
f01035f8:	5d                   	pop    %ebp
f01035f9:	c3                   	ret    

f01035fa <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01035fa:	55                   	push   %ebp
f01035fb:	89 e5                	mov    %esp,%ebp
f01035fd:	57                   	push   %edi
f01035fe:	56                   	push   %esi
f01035ff:	53                   	push   %ebx
f0103600:	83 ec 0c             	sub    $0xc,%esp
f0103603:	8b 45 08             	mov    0x8(%ebp),%eax
f0103606:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103609:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010360c:	85 c0                	test   %eax,%eax
f010360e:	75 24                	jne    f0103634 <envid2env+0x3a>
		*env_store = curenv;
f0103610:	e8 03 31 00 00       	call   f0106718 <cpunum>
f0103615:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010361c:	29 c2                	sub    %eax,%edx
f010361e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103621:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103628:	89 06                	mov    %eax,(%esi)
		return 0;
f010362a:	b8 00 00 00 00       	mov    $0x0,%eax
f010362f:	e9 84 00 00 00       	jmp    f01036b8 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103634:	89 c3                	mov    %eax,%ebx
f0103636:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010363c:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103643:	c1 e3 07             	shl    $0x7,%ebx
f0103646:	29 cb                	sub    %ecx,%ebx
f0103648:	03 1d 48 12 33 f0    	add    0xf0331248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010364e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103652:	74 05                	je     f0103659 <envid2env+0x5f>
f0103654:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103657:	74 0d                	je     f0103666 <envid2env+0x6c>
		*env_store = 0;
f0103659:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010365f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103664:	eb 52                	jmp    f01036b8 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103666:	84 d2                	test   %dl,%dl
f0103668:	74 47                	je     f01036b1 <envid2env+0xb7>
f010366a:	e8 a9 30 00 00       	call   f0106718 <cpunum>
f010366f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103676:	29 c2                	sub    %eax,%edx
f0103678:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010367b:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103682:	74 2d                	je     f01036b1 <envid2env+0xb7>
f0103684:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103687:	e8 8c 30 00 00       	call   f0106718 <cpunum>
f010368c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103693:	29 c2                	sub    %eax,%edx
f0103695:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103698:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f010369f:	3b 78 48             	cmp    0x48(%eax),%edi
f01036a2:	74 0d                	je     f01036b1 <envid2env+0xb7>
		*env_store = 0;
f01036a4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036aa:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036af:	eb 07                	jmp    f01036b8 <envid2env+0xbe>
	}

	*env_store = e;
f01036b1:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036b8:	83 c4 0c             	add    $0xc,%esp
f01036bb:	5b                   	pop    %ebx
f01036bc:	5e                   	pop    %esi
f01036bd:	5f                   	pop    %edi
f01036be:	5d                   	pop    %ebp
f01036bf:	c3                   	ret    

f01036c0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036c0:	55                   	push   %ebp
f01036c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036c3:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f01036c8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036cb:	b8 23 00 00 00       	mov    $0x23,%eax
f01036d0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01036d2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01036d4:	b0 10                	mov    $0x10,%al
f01036d6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01036d8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01036da:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01036dc:	ea e3 36 10 f0 08 00 	ljmp   $0x8,$0xf01036e3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01036e3:	b0 00                	mov    $0x0,%al
f01036e5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01036e8:	5d                   	pop    %ebp
f01036e9:	c3                   	ret    

f01036ea <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01036ea:	55                   	push   %ebp
f01036eb:	89 e5                	mov    %esp,%ebp
f01036ed:	56                   	push   %esi
f01036ee:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f01036ef:	8b 35 48 12 33 f0    	mov    0xf0331248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01036f5:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01036fb:	b9 00 00 00 00       	mov    $0x0,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f0103700:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0103705:	eb 02                	jmp    f0103709 <env_init+0x1f>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103707:	89 d9                	mov    %ebx,%ecx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f0103709:	89 c3                	mov    %eax,%ebx
f010370b:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103712:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103719:	89 48 44             	mov    %ecx,0x44(%eax)
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f010371c:	4a                   	dec    %edx
f010371d:	83 e8 7c             	sub    $0x7c,%eax
f0103720:	83 fa ff             	cmp    $0xffffffff,%edx
f0103723:	75 e2                	jne    f0103707 <env_init+0x1d>
f0103725:	89 35 4c 12 33 f0    	mov    %esi,0xf033124c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f010372b:	e8 90 ff ff ff       	call   f01036c0 <env_init_percpu>
}
f0103730:	5b                   	pop    %ebx
f0103731:	5e                   	pop    %esi
f0103732:	5d                   	pop    %ebp
f0103733:	c3                   	ret    

f0103734 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103734:	55                   	push   %ebp
f0103735:	89 e5                	mov    %esp,%ebp
f0103737:	56                   	push   %esi
f0103738:	53                   	push   %ebx
f0103739:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010373c:	8b 1d 4c 12 33 f0    	mov    0xf033124c,%ebx
f0103742:	85 db                	test   %ebx,%ebx
f0103744:	0f 84 bd 01 00 00    	je     f0103907 <env_alloc+0x1d3>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010374a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103751:	e8 35 d8 ff ff       	call   f0100f8b <page_alloc>
f0103756:	89 c6                	mov    %eax,%esi
f0103758:	85 c0                	test   %eax,%eax
f010375a:	0f 84 ae 01 00 00    	je     f010390e <env_alloc+0x1da>
f0103760:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0103766:	c1 f8 03             	sar    $0x3,%eax
f0103769:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010376c:	89 c2                	mov    %eax,%edx
f010376e:	c1 ea 0c             	shr    $0xc,%edx
f0103771:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0103777:	72 20                	jb     f0103799 <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103779:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010377d:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0103784:	f0 
f0103785:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010378c:	00 
f010378d:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0103794:	e8 a7 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103799:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	e->env_pgdir = page2kva(p);
f010379e:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);	
f01037a1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037a8:	00 
f01037a9:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f01037af:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037b3:	89 04 24             	mov    %eax,(%esp)
f01037b6:	e8 e3 29 00 00       	call   f010619e <memcpy>
	p->pp_ref++;
f01037bb:	66 ff 46 04          	incw   0x4(%esi)


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037bf:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037c7:	77 20                	ja     f01037e9 <env_alloc+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037cd:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f01037d4:	f0 
f01037d5:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f01037dc:	00 
f01037dd:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f01037e4:	e8 57 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037e9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01037ef:	83 ca 05             	or     $0x5,%edx
f01037f2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01037f8:	8b 43 48             	mov    0x48(%ebx),%eax
f01037fb:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103800:	89 c1                	mov    %eax,%ecx
f0103802:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103808:	7f 05                	jg     f010380f <env_alloc+0xdb>
		generation = 1 << ENVGENSHIFT;
f010380a:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010380f:	89 d8                	mov    %ebx,%eax
f0103811:	2b 05 48 12 33 f0    	sub    0xf0331248,%eax
f0103817:	c1 f8 02             	sar    $0x2,%eax
f010381a:	89 c6                	mov    %eax,%esi
f010381c:	c1 e6 05             	shl    $0x5,%esi
f010381f:	89 c2                	mov    %eax,%edx
f0103821:	c1 e2 0a             	shl    $0xa,%edx
f0103824:	01 f2                	add    %esi,%edx
f0103826:	01 c2                	add    %eax,%edx
f0103828:	89 d6                	mov    %edx,%esi
f010382a:	c1 e6 0f             	shl    $0xf,%esi
f010382d:	01 f2                	add    %esi,%edx
f010382f:	c1 e2 05             	shl    $0x5,%edx
f0103832:	01 d0                	add    %edx,%eax
f0103834:	f7 d8                	neg    %eax
f0103836:	09 c1                	or     %eax,%ecx
f0103838:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010383b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010383e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103841:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103848:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010384f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103856:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010385d:	00 
f010385e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103865:	00 
f0103866:	89 1c 24             	mov    %ebx,(%esp)
f0103869:	e8 7c 28 00 00       	call   f01060ea <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010386e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103874:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010387a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103880:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103887:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF; 
f010388d:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
		
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103894:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010389b:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010389f:	8b 43 44             	mov    0x44(%ebx),%eax
f01038a2:	a3 4c 12 33 f0       	mov    %eax,0xf033124c
	*newenv_store = e;
f01038a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01038aa:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038ac:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038af:	e8 64 2e 00 00       	call   f0106718 <cpunum>
f01038b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038bb:	29 c2                	sub    %eax,%edx
f01038bd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038c0:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f01038c7:	00 
f01038c8:	74 1d                	je     f01038e7 <env_alloc+0x1b3>
f01038ca:	e8 49 2e 00 00       	call   f0106718 <cpunum>
f01038cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01038d6:	29 c2                	sub    %eax,%edx
f01038d8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01038db:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01038e2:	8b 40 48             	mov    0x48(%eax),%eax
f01038e5:	eb 05                	jmp    f01038ec <env_alloc+0x1b8>
f01038e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01038ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038f4:	c7 04 24 78 81 10 f0 	movl   $0xf0108178,(%esp)
f01038fb:	e8 86 06 00 00       	call   f0103f86 <cprintf>
	return 0;
f0103900:	b8 00 00 00 00       	mov    $0x0,%eax
f0103905:	eb 0c                	jmp    f0103913 <env_alloc+0x1df>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103907:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010390c:	eb 05                	jmp    f0103913 <env_alloc+0x1df>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010390e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103913:	83 c4 10             	add    $0x10,%esp
f0103916:	5b                   	pop    %ebx
f0103917:	5e                   	pop    %esi
f0103918:	5d                   	pop    %ebp
f0103919:	c3                   	ret    

f010391a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010391a:	55                   	push   %ebp
f010391b:	89 e5                	mov    %esp,%ebp
f010391d:	57                   	push   %edi
f010391e:	56                   	push   %esi
f010391f:	53                   	push   %ebx
f0103920:	83 ec 3c             	sub    $0x3c,%esp
f0103923:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env* e;
	int ret = env_alloc(&e, 0);
f0103926:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010392d:	00 
f010392e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103931:	89 04 24             	mov    %eax,(%esp)
f0103934:	e8 fb fd ff ff       	call   f0103734 <env_alloc>
	if (ret == -E_NO_FREE_ENV )
f0103939:	83 f8 fb             	cmp    $0xfffffffb,%eax
f010393c:	75 24                	jne    f0103962 <env_create+0x48>
		panic("env_create:failed no free env %e", ret);
f010393e:	c7 44 24 0c fb ff ff 	movl   $0xfffffffb,0xc(%esp)
f0103945:	ff 
f0103946:	c7 44 24 08 d8 80 10 	movl   $0xf01080d8,0x8(%esp)
f010394d:	f0 
f010394e:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0103955:	00 
f0103956:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f010395d:	e8 de c6 ff ff       	call   f0100040 <_panic>
	if (ret == -E_NO_MEM)
f0103962:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103965:	75 24                	jne    f010398b <env_create+0x71>
		panic("env_create:failed no free mem %e", ret);
f0103967:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f010396e:	ff 
f010396f:	c7 44 24 08 fc 80 10 	movl   $0xf01080fc,0x8(%esp)
f0103976:	f0 
f0103977:	c7 44 24 04 98 01 00 	movl   $0x198,0x4(%esp)
f010397e:	00 
f010397f:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103986:	e8 b5 c6 ff ff       	call   f0100040 <_panic>
	e->env_type = type;
f010398b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010398e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103991:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103994:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103997:	89 42 50             	mov    %eax,0x50(%edx)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf*)binary;  //elf header
	if (elf->e_magic != ELF_MAGIC) 
f010399a:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01039a0:	74 1c                	je     f01039be <env_create+0xa4>
		panic("load_icode: illegal elf header");
f01039a2:	c7 44 24 08 20 81 10 	movl   $0xf0108120,0x8(%esp)
f01039a9:	f0 
f01039aa:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f01039b1:	00 
f01039b2:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f01039b9:	e8 82 c6 ff ff       	call   f0100040 <_panic>
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
f01039be:	89 fb                	mov    %edi,%ebx
f01039c0:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* eph = ph + elf->e_phnum;
f01039c3:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039c7:	c1 e6 05             	shl    $0x5,%esi
f01039ca:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f01039cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039cf:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039d7:	77 20                	ja     f01039f9 <env_create+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039dd:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f01039e4:	f0 
f01039e5:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01039ec:	00 
f01039ed:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f01039f4:	e8 47 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039f9:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039fe:	0f 22 d8             	mov    %eax,%cr3
f0103a01:	eb 71                	jmp    f0103a74 <env_create+0x15a>

	for (; ph < eph; ph++) {
		if(ph->p_type != ELF_PROG_LOAD)
f0103a03:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103a06:	75 69                	jne    f0103a71 <env_create+0x157>
			continue;
		if (ph->p_filesz > ph->p_memsz) 
f0103a08:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103a0b:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103a0e:	76 1c                	jbe    f0103a2c <env_create+0x112>
			panic("load_icode:file size is larger than mem size");
f0103a10:	c7 44 24 08 40 81 10 	movl   $0xf0108140,0x8(%esp)
f0103a17:	f0 
f0103a18:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0103a1f:	00 
f0103a20:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103a27:	e8 14 c6 ff ff       	call   f0100040 <_panic>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
f0103a2c:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a32:	e8 01 fb ff ff       	call   f0103538 <region_alloc>
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103a37:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a3e:	89 f8                	mov    %edi,%eax
f0103a40:	03 43 04             	add    0x4(%ebx),%eax
f0103a43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a47:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a4a:	89 04 24             	mov    %eax,(%esp)
f0103a4d:	e8 e2 26 00 00       	call   f0106134 <memmove>
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
f0103a52:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a55:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a58:	29 c2                	sub    %eax,%edx
f0103a5a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a65:	00 
f0103a66:	03 43 08             	add    0x8(%ebx),%eax
f0103a69:	89 04 24             	mov    %eax,(%esp)
f0103a6c:	e8 79 26 00 00       	call   f01060ea <memset>
		panic("load_icode: illegal elf header");
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
	struct Proghdr* eph = ph + elf->e_phnum;
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++) {
f0103a71:	83 c3 20             	add    $0x20,%ebx
f0103a74:	39 de                	cmp    %ebx,%esi
f0103a76:	77 8b                	ja     f0103a03 <env_create+0xe9>
			panic("load_icode:file size is larger than mem size");
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
	}
	e->env_tf.tf_eip = elf->e_entry; 
f0103a78:	8b 47 18             	mov    0x18(%edi),%eax
f0103a7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a7e:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	//lcr3(PADDR(kern_pgdir));
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);		
f0103a81:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a86:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a8e:	e8 a5 fa ff ff       	call   f0103538 <region_alloc>
		panic("env_create:failed no free env %e", ret);
	if (ret == -E_NO_MEM)
		panic("env_create:failed no free mem %e", ret);
	e->env_type = type;
	load_icode(e, binary);
}
f0103a93:	83 c4 3c             	add    $0x3c,%esp
f0103a96:	5b                   	pop    %ebx
f0103a97:	5e                   	pop    %esi
f0103a98:	5f                   	pop    %edi
f0103a99:	5d                   	pop    %ebp
f0103a9a:	c3                   	ret    

f0103a9b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a9b:	55                   	push   %ebp
f0103a9c:	89 e5                	mov    %esp,%ebp
f0103a9e:	57                   	push   %edi
f0103a9f:	56                   	push   %esi
f0103aa0:	53                   	push   %ebx
f0103aa1:	83 ec 2c             	sub    $0x2c,%esp
f0103aa4:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103aa7:	e8 6c 2c 00 00       	call   f0106718 <cpunum>
f0103aac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ab3:	29 c2                	sub    %eax,%edx
f0103ab5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ab8:	39 3c 85 28 20 33 f0 	cmp    %edi,-0xfccdfd8(,%eax,4)
f0103abf:	75 34                	jne    f0103af5 <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103ac1:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ac6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103acb:	77 20                	ja     f0103aed <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103acd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ad1:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0103ad8:	f0 
f0103ad9:	c7 44 24 04 ab 01 00 	movl   $0x1ab,0x4(%esp)
f0103ae0:	00 
f0103ae1:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103ae8:	e8 53 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103aed:	05 00 00 00 10       	add    $0x10000000,%eax
f0103af2:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103af5:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103af8:	e8 1b 2c 00 00       	call   f0106718 <cpunum>
f0103afd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b04:	29 c2                	sub    %eax,%edx
f0103b06:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b09:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0103b10:	00 
f0103b11:	74 1d                	je     f0103b30 <env_free+0x95>
f0103b13:	e8 00 2c 00 00       	call   f0106718 <cpunum>
f0103b18:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b1f:	29 c2                	sub    %eax,%edx
f0103b21:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b24:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103b2b:	8b 40 48             	mov    0x48(%eax),%eax
f0103b2e:	eb 05                	jmp    f0103b35 <env_free+0x9a>
f0103b30:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103b39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b3d:	c7 04 24 8d 81 10 f0 	movl   $0xf010818d,(%esp)
f0103b44:	e8 3d 04 00 00       	call   f0103f86 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b49:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b53:	c1 e0 02             	shl    $0x2,%eax
f0103b56:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103b59:	8b 47 60             	mov    0x60(%edi),%eax
f0103b5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b5f:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103b62:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b68:	0f 84 b6 00 00 00    	je     f0103c24 <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b6e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b74:	89 f0                	mov    %esi,%eax
f0103b76:	c1 e8 0c             	shr    $0xc,%eax
f0103b79:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b7c:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103b82:	72 20                	jb     f0103ba4 <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b84:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b88:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0103b8f:	f0 
f0103b90:	c7 44 24 04 ba 01 00 	movl   $0x1ba,0x4(%esp)
f0103b97:	00 
f0103b98:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103b9f:	e8 9c c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ba4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103ba7:	c1 e2 16             	shl    $0x16,%edx
f0103baa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bad:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103bb2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103bb9:	01 
f0103bba:	74 17                	je     f0103bd3 <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103bbc:	89 d8                	mov    %ebx,%eax
f0103bbe:	c1 e0 0c             	shl    $0xc,%eax
f0103bc1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bc8:	8b 47 60             	mov    0x60(%edi),%eax
f0103bcb:	89 04 24             	mov    %eax,(%esp)
f0103bce:	e8 02 d7 ff ff       	call   f01012d5 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103bd3:	43                   	inc    %ebx
f0103bd4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103bda:	75 d6                	jne    f0103bb2 <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103bdc:	8b 47 60             	mov    0x60(%edi),%eax
f0103bdf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103be2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103be9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bec:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103bf2:	72 1c                	jb     f0103c10 <env_free+0x175>
		panic("pa2page called with invalid pa");
f0103bf4:	c7 44 24 08 c4 74 10 	movl   $0xf01074c4,0x8(%esp)
f0103bfb:	f0 
f0103bfc:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c03:	00 
f0103c04:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0103c0b:	e8 30 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c10:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103c13:	c1 e0 03             	shl    $0x3,%eax
f0103c16:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
		page_decref(pa2page(pa));
f0103c1c:	89 04 24             	mov    %eax,(%esp)
f0103c1f:	e8 76 d4 ff ff       	call   f010109a <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103c24:	ff 45 e0             	incl   -0x20(%ebp)
f0103c27:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103c2e:	0f 85 1c ff ff ff    	jne    f0103b50 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103c34:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c37:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c3c:	77 20                	ja     f0103c5e <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c42:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0103c49:	f0 
f0103c4a:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f0103c51:	00 
f0103c52:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103c59:	e8 e2 c3 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103c5e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c65:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c6a:	c1 e8 0c             	shr    $0xc,%eax
f0103c6d:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103c73:	72 1c                	jb     f0103c91 <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f0103c75:	c7 44 24 08 c4 74 10 	movl   $0xf01074c4,0x8(%esp)
f0103c7c:	f0 
f0103c7d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c84:	00 
f0103c85:	c7 04 24 09 7d 10 f0 	movl   $0xf0107d09,(%esp)
f0103c8c:	e8 af c3 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c91:	c1 e0 03             	shl    $0x3,%eax
f0103c94:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
	page_decref(pa2page(pa));
f0103c9a:	89 04 24             	mov    %eax,(%esp)
f0103c9d:	e8 f8 d3 ff ff       	call   f010109a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103ca2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103ca9:	a1 4c 12 33 f0       	mov    0xf033124c,%eax
f0103cae:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103cb1:	89 3d 4c 12 33 f0    	mov    %edi,0xf033124c
}
f0103cb7:	83 c4 2c             	add    $0x2c,%esp
f0103cba:	5b                   	pop    %ebx
f0103cbb:	5e                   	pop    %esi
f0103cbc:	5f                   	pop    %edi
f0103cbd:	5d                   	pop    %ebp
f0103cbe:	c3                   	ret    

f0103cbf <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103cbf:	55                   	push   %ebp
f0103cc0:	89 e5                	mov    %esp,%ebp
f0103cc2:	53                   	push   %ebx
f0103cc3:	83 ec 14             	sub    $0x14,%esp
f0103cc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103cc9:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103ccd:	75 23                	jne    f0103cf2 <env_destroy+0x33>
f0103ccf:	e8 44 2a 00 00       	call   f0106718 <cpunum>
f0103cd4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cdb:	29 c2                	sub    %eax,%edx
f0103cdd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ce0:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103ce7:	74 09                	je     f0103cf2 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103ce9:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103cf0:	eb 39                	jmp    f0103d2b <env_destroy+0x6c>
	}

	env_free(e);
f0103cf2:	89 1c 24             	mov    %ebx,(%esp)
f0103cf5:	e8 a1 fd ff ff       	call   f0103a9b <env_free>

	if (curenv == e) {
f0103cfa:	e8 19 2a 00 00       	call   f0106718 <cpunum>
f0103cff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d06:	29 c2                	sub    %eax,%edx
f0103d08:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d0b:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103d12:	75 17                	jne    f0103d2b <env_destroy+0x6c>
		curenv = NULL;
f0103d14:	e8 ff 29 00 00       	call   f0106718 <cpunum>
f0103d19:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1c:	c7 80 28 20 33 f0 00 	movl   $0x0,-0xfccdfd8(%eax)
f0103d23:	00 00 00 
		sched_yield();
f0103d26:	e8 0f 10 00 00       	call   f0104d3a <sched_yield>
	}
}
f0103d2b:	83 c4 14             	add    $0x14,%esp
f0103d2e:	5b                   	pop    %ebx
f0103d2f:	5d                   	pop    %ebp
f0103d30:	c3                   	ret    

f0103d31 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103d31:	55                   	push   %ebp
f0103d32:	89 e5                	mov    %esp,%ebp
f0103d34:	53                   	push   %ebx
f0103d35:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103d38:	e8 db 29 00 00       	call   f0106718 <cpunum>
f0103d3d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d44:	29 c2                	sub    %eax,%edx
f0103d46:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d49:	8b 1c 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%ebx
f0103d50:	e8 c3 29 00 00       	call   f0106718 <cpunum>
f0103d55:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103d58:	8b 65 08             	mov    0x8(%ebp),%esp
f0103d5b:	61                   	popa   
f0103d5c:	07                   	pop    %es
f0103d5d:	1f                   	pop    %ds
f0103d5e:	83 c4 08             	add    $0x8,%esp
f0103d61:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d62:	c7 44 24 08 a3 81 10 	movl   $0xf01081a3,0x8(%esp)
f0103d69:	f0 
f0103d6a:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
f0103d71:	00 
f0103d72:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103d79:	e8 c2 c2 ff ff       	call   f0100040 <_panic>

f0103d7e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d7e:	55                   	push   %ebp
f0103d7f:	89 e5                	mov    %esp,%ebp
f0103d81:	53                   	push   %ebx
f0103d82:	83 ec 14             	sub    $0x14,%esp
f0103d85:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.
	
	//panic("env_run not yet implemented");
	
	if (curenv){
f0103d88:	e8 8b 29 00 00       	call   f0106718 <cpunum>
f0103d8d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d94:	29 c2                	sub    %eax,%edx
f0103d96:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d99:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0103da0:	00 
f0103da1:	74 33                	je     f0103dd6 <env_run+0x58>
		if (curenv->env_status == ENV_RUNNING) 
f0103da3:	e8 70 29 00 00       	call   f0106718 <cpunum>
f0103da8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103daf:	29 c2                	sub    %eax,%edx
f0103db1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103db4:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103dbb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103dbf:	75 15                	jne    f0103dd6 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103dc1:	e8 52 29 00 00       	call   f0106718 <cpunum>
f0103dc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc9:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0103dcf:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	
	curenv = e;
f0103dd6:	e8 3d 29 00 00       	call   f0106718 <cpunum>
f0103ddb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103de2:	29 c2                	sub    %eax,%edx
f0103de4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103de7:	89 1c 85 28 20 33 f0 	mov    %ebx,-0xfccdfd8(,%eax,4)
	e->env_status = ENV_RUNNING;
f0103dee:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103df5:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0103df8:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103dfb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e00:	77 20                	ja     f0103e22 <env_run+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e02:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e06:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0103e0d:	f0 
f0103e0e:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
f0103e15:	00 
f0103e16:	c7 04 24 6d 81 10 f0 	movl   $0xf010816d,(%esp)
f0103e1d:	e8 1e c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e22:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e27:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103e2a:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0103e31:	e8 44 2c 00 00       	call   f0106a7a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103e36:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&(e->env_tf));		
f0103e38:	89 1c 24             	mov    %ebx,(%esp)
f0103e3b:	e8 f1 fe ff ff       	call   f0103d31 <env_pop_tf>

f0103e40 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103e40:	55                   	push   %ebp
f0103e41:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e43:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e48:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103e4c:	b2 71                	mov    $0x71,%dl
f0103e4e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103e4f:	0f b6 c0             	movzbl %al,%eax
}
f0103e52:	5d                   	pop    %ebp
f0103e53:	c3                   	ret    

f0103e54 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103e54:	55                   	push   %ebp
f0103e55:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103e57:	ba 70 00 00 00       	mov    $0x70,%edx
f0103e5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e5f:	ee                   	out    %al,(%dx)
f0103e60:	b2 71                	mov    $0x71,%dl
f0103e62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e65:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e66:	5d                   	pop    %ebp
f0103e67:	c3                   	ret    

f0103e68 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e68:	55                   	push   %ebp
f0103e69:	89 e5                	mov    %esp,%ebp
f0103e6b:	56                   	push   %esi
f0103e6c:	53                   	push   %ebx
f0103e6d:	83 ec 10             	sub    $0x10,%esp
f0103e70:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e73:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e75:	66 a3 a8 93 12 f0    	mov    %ax,0xf01293a8
	if (!didinit)
f0103e7b:	80 3d 50 12 33 f0 00 	cmpb   $0x0,0xf0331250
f0103e82:	74 51                	je     f0103ed5 <irq_setmask_8259A+0x6d>
f0103e84:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e89:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e8a:	89 f0                	mov    %esi,%eax
f0103e8c:	66 c1 e8 08          	shr    $0x8,%ax
f0103e90:	b2 a1                	mov    $0xa1,%dl
f0103e92:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e93:	c7 04 24 af 81 10 f0 	movl   $0xf01081af,(%esp)
f0103e9a:	e8 e7 00 00 00       	call   f0103f86 <cprintf>
	for (i = 0; i < 16; i++)
f0103e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103ea4:	0f b7 f6             	movzwl %si,%esi
f0103ea7:	f7 d6                	not    %esi
f0103ea9:	89 f0                	mov    %esi,%eax
f0103eab:	88 d9                	mov    %bl,%cl
f0103ead:	d3 f8                	sar    %cl,%eax
f0103eaf:	a8 01                	test   $0x1,%al
f0103eb1:	74 10                	je     f0103ec3 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103eb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eb7:	c7 04 24 bf 88 10 f0 	movl   $0xf01088bf,(%esp)
f0103ebe:	e8 c3 00 00 00       	call   f0103f86 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103ec3:	43                   	inc    %ebx
f0103ec4:	83 fb 10             	cmp    $0x10,%ebx
f0103ec7:	75 e0                	jne    f0103ea9 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103ec9:	c7 04 24 3f 80 10 f0 	movl   $0xf010803f,(%esp)
f0103ed0:	e8 b1 00 00 00       	call   f0103f86 <cprintf>
}
f0103ed5:	83 c4 10             	add    $0x10,%esp
f0103ed8:	5b                   	pop    %ebx
f0103ed9:	5e                   	pop    %esi
f0103eda:	5d                   	pop    %ebp
f0103edb:	c3                   	ret    

f0103edc <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103edc:	55                   	push   %ebp
f0103edd:	89 e5                	mov    %esp,%ebp
f0103edf:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103ee2:	c6 05 50 12 33 f0 01 	movb   $0x1,0xf0331250
f0103ee9:	ba 21 00 00 00       	mov    $0x21,%edx
f0103eee:	b0 ff                	mov    $0xff,%al
f0103ef0:	ee                   	out    %al,(%dx)
f0103ef1:	b2 a1                	mov    $0xa1,%dl
f0103ef3:	ee                   	out    %al,(%dx)
f0103ef4:	b2 20                	mov    $0x20,%dl
f0103ef6:	b0 11                	mov    $0x11,%al
f0103ef8:	ee                   	out    %al,(%dx)
f0103ef9:	b2 21                	mov    $0x21,%dl
f0103efb:	b0 20                	mov    $0x20,%al
f0103efd:	ee                   	out    %al,(%dx)
f0103efe:	b0 04                	mov    $0x4,%al
f0103f00:	ee                   	out    %al,(%dx)
f0103f01:	b0 03                	mov    $0x3,%al
f0103f03:	ee                   	out    %al,(%dx)
f0103f04:	b2 a0                	mov    $0xa0,%dl
f0103f06:	b0 11                	mov    $0x11,%al
f0103f08:	ee                   	out    %al,(%dx)
f0103f09:	b2 a1                	mov    $0xa1,%dl
f0103f0b:	b0 28                	mov    $0x28,%al
f0103f0d:	ee                   	out    %al,(%dx)
f0103f0e:	b0 02                	mov    $0x2,%al
f0103f10:	ee                   	out    %al,(%dx)
f0103f11:	b0 01                	mov    $0x1,%al
f0103f13:	ee                   	out    %al,(%dx)
f0103f14:	b2 20                	mov    $0x20,%dl
f0103f16:	b0 68                	mov    $0x68,%al
f0103f18:	ee                   	out    %al,(%dx)
f0103f19:	b0 0a                	mov    $0xa,%al
f0103f1b:	ee                   	out    %al,(%dx)
f0103f1c:	b2 a0                	mov    $0xa0,%dl
f0103f1e:	b0 68                	mov    $0x68,%al
f0103f20:	ee                   	out    %al,(%dx)
f0103f21:	b0 0a                	mov    $0xa,%al
f0103f23:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103f24:	66 a1 a8 93 12 f0    	mov    0xf01293a8,%ax
f0103f2a:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103f2e:	74 0b                	je     f0103f3b <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103f30:	0f b7 c0             	movzwl %ax,%eax
f0103f33:	89 04 24             	mov    %eax,(%esp)
f0103f36:	e8 2d ff ff ff       	call   f0103e68 <irq_setmask_8259A>
}
f0103f3b:	c9                   	leave  
f0103f3c:	c3                   	ret    
f0103f3d:	00 00                	add    %al,(%eax)
	...

f0103f40 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f40:	55                   	push   %ebp
f0103f41:	89 e5                	mov    %esp,%ebp
f0103f43:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f46:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f49:	89 04 24             	mov    %eax,(%esp)
f0103f4c:	e8 02 c8 ff ff       	call   f0100753 <cputchar>
	*cnt++;
}
f0103f51:	c9                   	leave  
f0103f52:	c3                   	ret    

f0103f53 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103f53:	55                   	push   %ebp
f0103f54:	89 e5                	mov    %esp,%ebp
f0103f56:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f63:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f67:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f6a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f75:	c7 04 24 40 3f 10 f0 	movl   $0xf0103f40,(%esp)
f0103f7c:	e8 29 1b 00 00       	call   f0105aaa <vprintfmt>
	return cnt;
}
f0103f81:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f84:	c9                   	leave  
f0103f85:	c3                   	ret    

f0103f86 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f86:	55                   	push   %ebp
f0103f87:	89 e5                	mov    %esp,%ebp
f0103f89:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f8c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f93:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f96:	89 04 24             	mov    %eax,(%esp)
f0103f99:	e8 b5 ff ff ff       	call   f0103f53 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f9e:	c9                   	leave  
f0103f9f:	c3                   	ret    

f0103fa0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103fa0:	55                   	push   %ebp
f0103fa1:	89 e5                	mov    %esp,%ebp
f0103fa3:	57                   	push   %edi
f0103fa4:	56                   	push   %esi
f0103fa5:	53                   	push   %ebx
f0103fa6:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum()*(KSTKSIZE+KSTKGAP);
f0103fa9:	e8 6a 27 00 00       	call   f0106718 <cpunum>
f0103fae:	89 c3                	mov    %eax,%ebx
f0103fb0:	e8 63 27 00 00       	call   f0106718 <cpunum>
f0103fb5:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103fbc:	29 da                	sub    %ebx,%edx
f0103fbe:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103fc1:	f7 d8                	neg    %eax
f0103fc3:	c1 e0 10             	shl    $0x10,%eax
f0103fc6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103fcb:	89 04 95 30 20 33 f0 	mov    %eax,-0xfccdfd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103fd2:	e8 41 27 00 00       	call   f0106718 <cpunum>
f0103fd7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fde:	29 c2                	sub    %eax,%edx
f0103fe0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fe3:	66 c7 04 85 34 20 33 	movw   $0x10,-0xfccdfcc(,%eax,4)
f0103fea:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103fed:	e8 26 27 00 00       	call   f0106718 <cpunum>
f0103ff2:	8d 58 05             	lea    0x5(%eax),%ebx
f0103ff5:	e8 1e 27 00 00       	call   f0106718 <cpunum>
f0103ffa:	89 c6                	mov    %eax,%esi
f0103ffc:	e8 17 27 00 00       	call   f0106718 <cpunum>
f0104001:	89 c7                	mov    %eax,%edi
f0104003:	e8 10 27 00 00       	call   f0106718 <cpunum>
f0104008:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f010400f:	f0 67 00 
f0104012:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0104019:	29 f2                	sub    %esi,%edx
f010401b:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010401e:	8d 14 95 2c 20 33 f0 	lea    -0xfccdfd4(,%edx,4),%edx
f0104025:	66 89 14 dd 42 93 12 	mov    %dx,-0xfed6cbe(,%ebx,8)
f010402c:	f0 
f010402d:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0104034:	29 fa                	sub    %edi,%edx
f0104036:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104039:	8d 14 95 2c 20 33 f0 	lea    -0xfccdfd4(,%edx,4),%edx
f0104040:	c1 ea 10             	shr    $0x10,%edx
f0104043:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f010404a:	c6 04 dd 45 93 12 f0 	movb   $0x99,-0xfed6cbb(,%ebx,8)
f0104051:	99 
f0104052:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f0104059:	40 
f010405a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104061:	29 c2                	sub    %eax,%edx
f0104063:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104066:	8d 04 85 2c 20 33 f0 	lea    -0xfccdfd4(,%eax,4),%eax
f010406d:	c1 e8 18             	shr    $0x18,%eax
f0104070:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
				sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0104077:	e8 9c 26 00 00       	call   f0106718 <cpunum>
f010407c:	80 24 c5 6d 93 12 f0 	andb   $0xef,-0xfed6c93(,%eax,8)
f0104083:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + cpunum()*sizeof(struct Segdesc));
f0104084:	e8 8f 26 00 00       	call   f0106718 <cpunum>
f0104089:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104090:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104093:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f0104098:	0f 01 18             	lidtl  (%eax)
	
	// Load the IDT
	lidt(&idt_pd);
}
f010409b:	83 c4 0c             	add    $0xc,%esp
f010409e:	5b                   	pop    %ebx
f010409f:	5e                   	pop    %esi
f01040a0:	5f                   	pop    %edi
f01040a1:	5d                   	pop    %ebp
f01040a2:	c3                   	ret    

f01040a3 <trap_init>:
}


void
trap_init(void)
{
f01040a3:	55                   	push   %ebp
f01040a4:	89 e5                	mov    %esp,%ebp
f01040a6:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f01040a9:	b8 3c 4b 10 f0       	mov    $0xf0104b3c,%eax
f01040ae:	66 a3 60 12 33 f0    	mov    %ax,0xf0331260
f01040b4:	66 c7 05 62 12 33 f0 	movw   $0x8,0xf0331262
f01040bb:	08 00 
f01040bd:	c6 05 64 12 33 f0 00 	movb   $0x0,0xf0331264
f01040c4:	c6 05 65 12 33 f0 8e 	movb   $0x8e,0xf0331265
f01040cb:	c1 e8 10             	shr    $0x10,%eax
f01040ce:	66 a3 66 12 33 f0    	mov    %ax,0xf0331266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f01040d4:	b8 46 4b 10 f0       	mov    $0xf0104b46,%eax
f01040d9:	66 a3 68 12 33 f0    	mov    %ax,0xf0331268
f01040df:	66 c7 05 6a 12 33 f0 	movw   $0x8,0xf033126a
f01040e6:	08 00 
f01040e8:	c6 05 6c 12 33 f0 00 	movb   $0x0,0xf033126c
f01040ef:	c6 05 6d 12 33 f0 8e 	movb   $0x8e,0xf033126d
f01040f6:	c1 e8 10             	shr    $0x10,%eax
f01040f9:	66 a3 6e 12 33 f0    	mov    %ax,0xf033126e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01040ff:	b8 50 4b 10 f0       	mov    $0xf0104b50,%eax
f0104104:	66 a3 70 12 33 f0    	mov    %ax,0xf0331270
f010410a:	66 c7 05 72 12 33 f0 	movw   $0x8,0xf0331272
f0104111:	08 00 
f0104113:	c6 05 74 12 33 f0 00 	movb   $0x0,0xf0331274
f010411a:	c6 05 75 12 33 f0 8e 	movb   $0x8e,0xf0331275
f0104121:	c1 e8 10             	shr    $0x10,%eax
f0104124:	66 a3 76 12 33 f0    	mov    %ax,0xf0331276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f010412a:	b8 5a 4b 10 f0       	mov    $0xf0104b5a,%eax
f010412f:	66 a3 78 12 33 f0    	mov    %ax,0xf0331278
f0104135:	66 c7 05 7a 12 33 f0 	movw   $0x8,0xf033127a
f010413c:	08 00 
f010413e:	c6 05 7c 12 33 f0 00 	movb   $0x0,0xf033127c
f0104145:	c6 05 7d 12 33 f0 ee 	movb   $0xee,0xf033127d
f010414c:	c1 e8 10             	shr    $0x10,%eax
f010414f:	66 a3 7e 12 33 f0    	mov    %ax,0xf033127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0104155:	b8 64 4b 10 f0       	mov    $0xf0104b64,%eax
f010415a:	66 a3 80 12 33 f0    	mov    %ax,0xf0331280
f0104160:	66 c7 05 82 12 33 f0 	movw   $0x8,0xf0331282
f0104167:	08 00 
f0104169:	c6 05 84 12 33 f0 00 	movb   $0x0,0xf0331284
f0104170:	c6 05 85 12 33 f0 8e 	movb   $0x8e,0xf0331285
f0104177:	c1 e8 10             	shr    $0x10,%eax
f010417a:	66 a3 86 12 33 f0    	mov    %ax,0xf0331286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0104180:	b8 6e 4b 10 f0       	mov    $0xf0104b6e,%eax
f0104185:	66 a3 88 12 33 f0    	mov    %ax,0xf0331288
f010418b:	66 c7 05 8a 12 33 f0 	movw   $0x8,0xf033128a
f0104192:	08 00 
f0104194:	c6 05 8c 12 33 f0 00 	movb   $0x0,0xf033128c
f010419b:	c6 05 8d 12 33 f0 8e 	movb   $0x8e,0xf033128d
f01041a2:	c1 e8 10             	shr    $0x10,%eax
f01041a5:	66 a3 8e 12 33 f0    	mov    %ax,0xf033128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01041ab:	b8 78 4b 10 f0       	mov    $0xf0104b78,%eax
f01041b0:	66 a3 90 12 33 f0    	mov    %ax,0xf0331290
f01041b6:	66 c7 05 92 12 33 f0 	movw   $0x8,0xf0331292
f01041bd:	08 00 
f01041bf:	c6 05 94 12 33 f0 00 	movb   $0x0,0xf0331294
f01041c6:	c6 05 95 12 33 f0 8e 	movb   $0x8e,0xf0331295
f01041cd:	c1 e8 10             	shr    $0x10,%eax
f01041d0:	66 a3 96 12 33 f0    	mov    %ax,0xf0331296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01041d6:	b8 82 4b 10 f0       	mov    $0xf0104b82,%eax
f01041db:	66 a3 98 12 33 f0    	mov    %ax,0xf0331298
f01041e1:	66 c7 05 9a 12 33 f0 	movw   $0x8,0xf033129a
f01041e8:	08 00 
f01041ea:	c6 05 9c 12 33 f0 00 	movb   $0x0,0xf033129c
f01041f1:	c6 05 9d 12 33 f0 8e 	movb   $0x8e,0xf033129d
f01041f8:	c1 e8 10             	shr    $0x10,%eax
f01041fb:	66 a3 9e 12 33 f0    	mov    %ax,0xf033129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0104201:	b8 8c 4b 10 f0       	mov    $0xf0104b8c,%eax
f0104206:	66 a3 a0 12 33 f0    	mov    %ax,0xf03312a0
f010420c:	66 c7 05 a2 12 33 f0 	movw   $0x8,0xf03312a2
f0104213:	08 00 
f0104215:	c6 05 a4 12 33 f0 00 	movb   $0x0,0xf03312a4
f010421c:	c6 05 a5 12 33 f0 8e 	movb   $0x8e,0xf03312a5
f0104223:	c1 e8 10             	shr    $0x10,%eax
f0104226:	66 a3 a6 12 33 f0    	mov    %ax,0xf03312a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f010422c:	b8 94 4b 10 f0       	mov    $0xf0104b94,%eax
f0104231:	66 a3 b0 12 33 f0    	mov    %ax,0xf03312b0
f0104237:	66 c7 05 b2 12 33 f0 	movw   $0x8,0xf03312b2
f010423e:	08 00 
f0104240:	c6 05 b4 12 33 f0 00 	movb   $0x0,0xf03312b4
f0104247:	c6 05 b5 12 33 f0 8e 	movb   $0x8e,0xf03312b5
f010424e:	c1 e8 10             	shr    $0x10,%eax
f0104251:	66 a3 b6 12 33 f0    	mov    %ax,0xf03312b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0104257:	b8 9c 4b 10 f0       	mov    $0xf0104b9c,%eax
f010425c:	66 a3 b8 12 33 f0    	mov    %ax,0xf03312b8
f0104262:	66 c7 05 ba 12 33 f0 	movw   $0x8,0xf03312ba
f0104269:	08 00 
f010426b:	c6 05 bc 12 33 f0 00 	movb   $0x0,0xf03312bc
f0104272:	c6 05 bd 12 33 f0 8e 	movb   $0x8e,0xf03312bd
f0104279:	c1 e8 10             	shr    $0x10,%eax
f010427c:	66 a3 be 12 33 f0    	mov    %ax,0xf03312be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0104282:	b8 a4 4b 10 f0       	mov    $0xf0104ba4,%eax
f0104287:	66 a3 c0 12 33 f0    	mov    %ax,0xf03312c0
f010428d:	66 c7 05 c2 12 33 f0 	movw   $0x8,0xf03312c2
f0104294:	08 00 
f0104296:	c6 05 c4 12 33 f0 00 	movb   $0x0,0xf03312c4
f010429d:	c6 05 c5 12 33 f0 8e 	movb   $0x8e,0xf03312c5
f01042a4:	c1 e8 10             	shr    $0x10,%eax
f01042a7:	66 a3 c6 12 33 f0    	mov    %ax,0xf03312c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01042ad:	b8 ac 4b 10 f0       	mov    $0xf0104bac,%eax
f01042b2:	66 a3 c8 12 33 f0    	mov    %ax,0xf03312c8
f01042b8:	66 c7 05 ca 12 33 f0 	movw   $0x8,0xf03312ca
f01042bf:	08 00 
f01042c1:	c6 05 cc 12 33 f0 00 	movb   $0x0,0xf03312cc
f01042c8:	c6 05 cd 12 33 f0 8e 	movb   $0x8e,0xf03312cd
f01042cf:	c1 e8 10             	shr    $0x10,%eax
f01042d2:	66 a3 ce 12 33 f0    	mov    %ax,0xf03312ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01042d8:	b8 b4 4b 10 f0       	mov    $0xf0104bb4,%eax
f01042dd:	66 a3 d0 12 33 f0    	mov    %ax,0xf03312d0
f01042e3:	66 c7 05 d2 12 33 f0 	movw   $0x8,0xf03312d2
f01042ea:	08 00 
f01042ec:	c6 05 d4 12 33 f0 00 	movb   $0x0,0xf03312d4
f01042f3:	c6 05 d5 12 33 f0 8e 	movb   $0x8e,0xf03312d5
f01042fa:	c1 e8 10             	shr    $0x10,%eax
f01042fd:	66 a3 d6 12 33 f0    	mov    %ax,0xf03312d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0104303:	b8 bc 4b 10 f0       	mov    $0xf0104bbc,%eax
f0104308:	66 a3 e0 12 33 f0    	mov    %ax,0xf03312e0
f010430e:	66 c7 05 e2 12 33 f0 	movw   $0x8,0xf03312e2
f0104315:	08 00 
f0104317:	c6 05 e4 12 33 f0 00 	movb   $0x0,0xf03312e4
f010431e:	c6 05 e5 12 33 f0 8e 	movb   $0x8e,0xf03312e5
f0104325:	c1 e8 10             	shr    $0x10,%eax
f0104328:	66 a3 e6 12 33 f0    	mov    %ax,0xf03312e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f010432e:	b8 c6 4b 10 f0       	mov    $0xf0104bc6,%eax
f0104333:	66 a3 e8 12 33 f0    	mov    %ax,0xf03312e8
f0104339:	66 c7 05 ea 12 33 f0 	movw   $0x8,0xf03312ea
f0104340:	08 00 
f0104342:	c6 05 ec 12 33 f0 00 	movb   $0x0,0xf03312ec
f0104349:	c6 05 ed 12 33 f0 8e 	movb   $0x8e,0xf03312ed
f0104350:	c1 e8 10             	shr    $0x10,%eax
f0104353:	66 a3 ee 12 33 f0    	mov    %ax,0xf03312ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0104359:	b8 ce 4b 10 f0       	mov    $0xf0104bce,%eax
f010435e:	66 a3 f0 12 33 f0    	mov    %ax,0xf03312f0
f0104364:	66 c7 05 f2 12 33 f0 	movw   $0x8,0xf03312f2
f010436b:	08 00 
f010436d:	c6 05 f4 12 33 f0 00 	movb   $0x0,0xf03312f4
f0104374:	c6 05 f5 12 33 f0 8e 	movb   $0x8e,0xf03312f5
f010437b:	c1 e8 10             	shr    $0x10,%eax
f010437e:	66 a3 f6 12 33 f0    	mov    %ax,0xf03312f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0104384:	b8 d8 4b 10 f0       	mov    $0xf0104bd8,%eax
f0104389:	66 a3 f8 12 33 f0    	mov    %ax,0xf03312f8
f010438f:	66 c7 05 fa 12 33 f0 	movw   $0x8,0xf03312fa
f0104396:	08 00 
f0104398:	c6 05 fc 12 33 f0 00 	movb   $0x0,0xf03312fc
f010439f:	c6 05 fd 12 33 f0 8e 	movb   $0x8e,0xf03312fd
f01043a6:	c1 e8 10             	shr    $0x10,%eax
f01043a9:	66 a3 fe 12 33 f0    	mov    %ax,0xf03312fe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01043af:	b8 e2 4b 10 f0       	mov    $0xf0104be2,%eax
f01043b4:	66 a3 e0 13 33 f0    	mov    %ax,0xf03313e0
f01043ba:	66 c7 05 e2 13 33 f0 	movw   $0x8,0xf03313e2
f01043c1:	08 00 
f01043c3:	c6 05 e4 13 33 f0 00 	movb   $0x0,0xf03313e4
f01043ca:	c6 05 e5 13 33 f0 ee 	movb   $0xee,0xf03313e5
f01043d1:	c1 e8 10             	shr    $0x10,%eax
f01043d4:	66 a3 e6 13 33 f0    	mov    %ax,0xf03313e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f01043da:	b8 f8 4b 10 f0       	mov    $0xf0104bf8,%eax
f01043df:	66 a3 60 13 33 f0    	mov    %ax,0xf0331360
f01043e5:	66 c7 05 62 13 33 f0 	movw   $0x8,0xf0331362
f01043ec:	08 00 
f01043ee:	c6 05 64 13 33 f0 00 	movb   $0x0,0xf0331364
f01043f5:	c6 05 65 13 33 f0 8e 	movb   $0x8e,0xf0331365
f01043fc:	c1 e8 10             	shr    $0x10,%eax
f01043ff:	66 a3 66 13 33 f0    	mov    %ax,0xf0331366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f0104405:	b8 02 4c 10 f0       	mov    $0xf0104c02,%eax
f010440a:	66 a3 68 13 33 f0    	mov    %ax,0xf0331368
f0104410:	66 c7 05 6a 13 33 f0 	movw   $0x8,0xf033136a
f0104417:	08 00 
f0104419:	c6 05 6c 13 33 f0 00 	movb   $0x0,0xf033136c
f0104420:	c6 05 6d 13 33 f0 8e 	movb   $0x8e,0xf033136d
f0104427:	c1 e8 10             	shr    $0x10,%eax
f010442a:	66 a3 6e 13 33 f0    	mov    %ax,0xf033136e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f0104430:	b8 0c 4c 10 f0       	mov    $0xf0104c0c,%eax
f0104435:	66 a3 80 13 33 f0    	mov    %ax,0xf0331380
f010443b:	66 c7 05 82 13 33 f0 	movw   $0x8,0xf0331382
f0104442:	08 00 
f0104444:	c6 05 84 13 33 f0 00 	movb   $0x0,0xf0331384
f010444b:	c6 05 85 13 33 f0 8e 	movb   $0x8e,0xf0331385
f0104452:	c1 e8 10             	shr    $0x10,%eax
f0104455:	66 a3 86 13 33 f0    	mov    %ax,0xf0331386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f010445b:	b8 16 4c 10 f0       	mov    $0xf0104c16,%eax
f0104460:	66 a3 98 13 33 f0    	mov    %ax,0xf0331398
f0104466:	66 c7 05 9a 13 33 f0 	movw   $0x8,0xf033139a
f010446d:	08 00 
f010446f:	c6 05 9c 13 33 f0 00 	movb   $0x0,0xf033139c
f0104476:	c6 05 9d 13 33 f0 8e 	movb   $0x8e,0xf033139d
f010447d:	c1 e8 10             	shr    $0x10,%eax
f0104480:	66 a3 9e 13 33 f0    	mov    %ax,0xf033139e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0104486:	b8 20 4c 10 f0       	mov    $0xf0104c20,%eax
f010448b:	66 a3 d0 13 33 f0    	mov    %ax,0xf03313d0
f0104491:	66 c7 05 d2 13 33 f0 	movw   $0x8,0xf03313d2
f0104498:	08 00 
f010449a:	c6 05 d4 13 33 f0 00 	movb   $0x0,0xf03313d4
f01044a1:	c6 05 d5 13 33 f0 8e 	movb   $0x8e,0xf03313d5
f01044a8:	c1 e8 10             	shr    $0x10,%eax
f01044ab:	66 a3 d6 13 33 f0    	mov    %ax,0xf03313d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f01044b1:	b8 2a 4c 10 f0       	mov    $0xf0104c2a,%eax
f01044b6:	66 a3 f8 13 33 f0    	mov    %ax,0xf03313f8
f01044bc:	66 c7 05 fa 13 33 f0 	movw   $0x8,0xf03313fa
f01044c3:	08 00 
f01044c5:	c6 05 fc 13 33 f0 00 	movb   $0x0,0xf03313fc
f01044cc:	c6 05 fd 13 33 f0 8e 	movb   $0x8e,0xf03313fd
f01044d3:	c1 e8 10             	shr    $0x10,%eax
f01044d6:	66 a3 fe 13 33 f0    	mov    %ax,0xf03313fe

	// Per-CPU setup 
	trap_init_percpu();
f01044dc:	e8 bf fa ff ff       	call   f0103fa0 <trap_init_percpu>
}
f01044e1:	c9                   	leave  
f01044e2:	c3                   	ret    

f01044e3 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044e3:	55                   	push   %ebp
f01044e4:	89 e5                	mov    %esp,%ebp
f01044e6:	53                   	push   %ebx
f01044e7:	83 ec 14             	sub    $0x14,%esp
f01044ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044ed:	8b 03                	mov    (%ebx),%eax
f01044ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f3:	c7 04 24 c3 81 10 f0 	movl   $0xf01081c3,(%esp)
f01044fa:	e8 87 fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01044ff:	8b 43 04             	mov    0x4(%ebx),%eax
f0104502:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104506:	c7 04 24 d2 81 10 f0 	movl   $0xf01081d2,(%esp)
f010450d:	e8 74 fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104512:	8b 43 08             	mov    0x8(%ebx),%eax
f0104515:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104519:	c7 04 24 e1 81 10 f0 	movl   $0xf01081e1,(%esp)
f0104520:	e8 61 fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104525:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104528:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452c:	c7 04 24 f0 81 10 f0 	movl   $0xf01081f0,(%esp)
f0104533:	e8 4e fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104538:	8b 43 10             	mov    0x10(%ebx),%eax
f010453b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010453f:	c7 04 24 ff 81 10 f0 	movl   $0xf01081ff,(%esp)
f0104546:	e8 3b fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010454b:	8b 43 14             	mov    0x14(%ebx),%eax
f010454e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104552:	c7 04 24 0e 82 10 f0 	movl   $0xf010820e,(%esp)
f0104559:	e8 28 fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010455e:	8b 43 18             	mov    0x18(%ebx),%eax
f0104561:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104565:	c7 04 24 1d 82 10 f0 	movl   $0xf010821d,(%esp)
f010456c:	e8 15 fa ff ff       	call   f0103f86 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104571:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104574:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104578:	c7 04 24 2c 82 10 f0 	movl   $0xf010822c,(%esp)
f010457f:	e8 02 fa ff ff       	call   f0103f86 <cprintf>
}
f0104584:	83 c4 14             	add    $0x14,%esp
f0104587:	5b                   	pop    %ebx
f0104588:	5d                   	pop    %ebp
f0104589:	c3                   	ret    

f010458a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010458a:	55                   	push   %ebp
f010458b:	89 e5                	mov    %esp,%ebp
f010458d:	53                   	push   %ebx
f010458e:	83 ec 14             	sub    $0x14,%esp
f0104591:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104594:	e8 7f 21 00 00       	call   f0106718 <cpunum>
f0104599:	89 44 24 08          	mov    %eax,0x8(%esp)
f010459d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045a1:	c7 04 24 90 82 10 f0 	movl   $0xf0108290,(%esp)
f01045a8:	e8 d9 f9 ff ff       	call   f0103f86 <cprintf>
	print_regs(&tf->tf_regs);
f01045ad:	89 1c 24             	mov    %ebx,(%esp)
f01045b0:	e8 2e ff ff ff       	call   f01044e3 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045b5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045bd:	c7 04 24 ae 82 10 f0 	movl   $0xf01082ae,(%esp)
f01045c4:	e8 bd f9 ff ff       	call   f0103f86 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045c9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045cd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d1:	c7 04 24 c1 82 10 f0 	movl   $0xf01082c1,(%esp)
f01045d8:	e8 a9 f9 ff ff       	call   f0103f86 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045dd:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045e0:	83 f8 13             	cmp    $0x13,%eax
f01045e3:	77 09                	ja     f01045ee <print_trapframe+0x64>
	  return excnames[trapno];
f01045e5:	8b 14 85 60 85 10 f0 	mov    -0xfef7aa0(,%eax,4),%edx
f01045ec:	eb 20                	jmp    f010460e <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01045ee:	83 f8 30             	cmp    $0x30,%eax
f01045f1:	74 0f                	je     f0104602 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01045f3:	8d 50 e0             	lea    -0x20(%eax),%edx
f01045f6:	83 fa 0f             	cmp    $0xf,%edx
f01045f9:	77 0e                	ja     f0104609 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01045fb:	ba 47 82 10 f0       	mov    $0xf0108247,%edx
f0104600:	eb 0c                	jmp    f010460e <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
	  return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104602:	ba 3b 82 10 f0       	mov    $0xf010823b,%edx
f0104607:	eb 05                	jmp    f010460e <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104609:	ba 5a 82 10 f0       	mov    $0xf010825a,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010460e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104612:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104616:	c7 04 24 d4 82 10 f0 	movl   $0xf01082d4,(%esp)
f010461d:	e8 64 f9 ff ff       	call   f0103f86 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104622:	3b 1d 60 1a 33 f0    	cmp    0xf0331a60,%ebx
f0104628:	75 19                	jne    f0104643 <print_trapframe+0xb9>
f010462a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010462e:	75 13                	jne    f0104643 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104630:	0f 20 d0             	mov    %cr2,%eax
	  cprintf("  cr2  0x%08x\n", rcr2());
f0104633:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104637:	c7 04 24 e6 82 10 f0 	movl   $0xf01082e6,(%esp)
f010463e:	e8 43 f9 ff ff       	call   f0103f86 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104643:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104646:	89 44 24 04          	mov    %eax,0x4(%esp)
f010464a:	c7 04 24 f5 82 10 f0 	movl   $0xf01082f5,(%esp)
f0104651:	e8 30 f9 ff ff       	call   f0103f86 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104656:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010465a:	75 4d                	jne    f01046a9 <print_trapframe+0x11f>
	  cprintf(" [%s, %s, %s]\n",
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
f010465c:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
	  cprintf(" [%s, %s, %s]\n",
f010465f:	a8 01                	test   $0x1,%al
f0104661:	74 07                	je     f010466a <print_trapframe+0xe0>
f0104663:	b9 69 82 10 f0       	mov    $0xf0108269,%ecx
f0104668:	eb 05                	jmp    f010466f <print_trapframe+0xe5>
f010466a:	b9 74 82 10 f0       	mov    $0xf0108274,%ecx
f010466f:	a8 02                	test   $0x2,%al
f0104671:	74 07                	je     f010467a <print_trapframe+0xf0>
f0104673:	ba 80 82 10 f0       	mov    $0xf0108280,%edx
f0104678:	eb 05                	jmp    f010467f <print_trapframe+0xf5>
f010467a:	ba 86 82 10 f0       	mov    $0xf0108286,%edx
f010467f:	a8 04                	test   $0x4,%al
f0104681:	74 07                	je     f010468a <print_trapframe+0x100>
f0104683:	b8 8b 82 10 f0       	mov    $0xf010828b,%eax
f0104688:	eb 05                	jmp    f010468f <print_trapframe+0x105>
f010468a:	b8 de 83 10 f0       	mov    $0xf01083de,%eax
f010468f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104693:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104697:	89 44 24 04          	mov    %eax,0x4(%esp)
f010469b:	c7 04 24 03 83 10 f0 	movl   $0xf0108303,(%esp)
f01046a2:	e8 df f8 ff ff       	call   f0103f86 <cprintf>
f01046a7:	eb 0c                	jmp    f01046b5 <print_trapframe+0x12b>
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
	else
	  cprintf("\n");
f01046a9:	c7 04 24 3f 80 10 f0 	movl   $0xf010803f,(%esp)
f01046b0:	e8 d1 f8 ff ff       	call   f0103f86 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046b5:	8b 43 30             	mov    0x30(%ebx),%eax
f01046b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046bc:	c7 04 24 12 83 10 f0 	movl   $0xf0108312,(%esp)
f01046c3:	e8 be f8 ff ff       	call   f0103f86 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046c8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046d0:	c7 04 24 21 83 10 f0 	movl   $0xf0108321,(%esp)
f01046d7:	e8 aa f8 ff ff       	call   f0103f86 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046dc:	8b 43 38             	mov    0x38(%ebx),%eax
f01046df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e3:	c7 04 24 34 83 10 f0 	movl   $0xf0108334,(%esp)
f01046ea:	e8 97 f8 ff ff       	call   f0103f86 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046ef:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046f3:	74 27                	je     f010471c <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01046f5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046fc:	c7 04 24 43 83 10 f0 	movl   $0xf0108343,(%esp)
f0104703:	e8 7e f8 ff ff       	call   f0103f86 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104708:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010470c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104710:	c7 04 24 52 83 10 f0 	movl   $0xf0108352,(%esp)
f0104717:	e8 6a f8 ff ff       	call   f0103f86 <cprintf>
	}
}
f010471c:	83 c4 14             	add    $0x14,%esp
f010471f:	5b                   	pop    %ebx
f0104720:	5d                   	pop    %ebp
f0104721:	c3                   	ret    

f0104722 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104722:	55                   	push   %ebp
f0104723:	89 e5                	mov    %esp,%ebp
f0104725:	57                   	push   %edi
f0104726:	56                   	push   %esi
f0104727:	53                   	push   %ebx
f0104728:	83 ec 2c             	sub    $0x2c,%esp
f010472b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010472e:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	
	if ((tf->tf_cs & 0x0001) == 0) {
f0104731:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f0104735:	75 1c                	jne    f0104753 <page_fault_handler+0x31>
		panic("page_fault_handler:page fault");
f0104737:	c7 44 24 08 65 83 10 	movl   $0xf0108365,0x8(%esp)
f010473e:	f0 
f010473f:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
f0104746:	00 
f0104747:	c7 04 24 83 83 10 f0 	movl   $0xf0108383,(%esp)
f010474e:	e8 ed b8 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall){
f0104753:	e8 c0 1f 00 00       	call   f0106718 <cpunum>
f0104758:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010475f:	29 c2                	sub    %eax,%edx
f0104761:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104764:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f010476b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010476f:	0f 84 ed 00 00 00    	je     f0104862 <page_fault_handler+0x140>
		struct UTrapframe *utf;
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP-1)
f0104775:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104778:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		else
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
f010477e:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall){
		struct UTrapframe *utf;
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP-1)
f0104785:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010478b:	77 06                	ja     f0104793 <page_fault_handler+0x71>
			utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010478d:	83 e8 38             	sub    $0x38,%eax
f0104790:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		else
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
		user_mem_assert(curenv, (void*)utf, sizeof(struct UTrapframe), PTE_U|PTE_W);
f0104793:	e8 80 1f 00 00       	call   f0106718 <cpunum>
f0104798:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010479f:	00 
f01047a0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f01047a7:	00 
f01047a8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047ab:	89 54 24 04          	mov    %edx,0x4(%esp)
f01047af:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b2:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01047b8:	89 04 24             	mov    %eax,(%esp)
f01047bb:	e8 1f ed ff ff       	call   f01034df <user_mem_assert>
		utf->utf_fault_va = fault_va;
f01047c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047c3:	89 30                	mov    %esi,(%eax)
		utf->utf_regs = tf->tf_regs;
f01047c5:	89 c7                	mov    %eax,%edi
f01047c7:	83 c7 08             	add    $0x8,%edi
f01047ca:	89 de                	mov    %ebx,%esi
f01047cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01047d1:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01047d7:	74 03                	je     f01047dc <page_fault_handler+0xba>
f01047d9:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01047da:	b0 1f                	mov    $0x1f,%al
f01047dc:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01047e2:	74 05                	je     f01047e9 <page_fault_handler+0xc7>
f01047e4:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047e6:	83 e8 02             	sub    $0x2,%eax
f01047e9:	89 c1                	mov    %eax,%ecx
f01047eb:	c1 e9 02             	shr    $0x2,%ecx
f01047ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047f0:	a8 02                	test   $0x2,%al
f01047f2:	74 02                	je     f01047f6 <page_fault_handler+0xd4>
f01047f4:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047f6:	a8 01                	test   $0x1,%al
f01047f8:	74 01                	je     f01047fb <page_fault_handler+0xd9>
f01047fa:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01047fb:	8b 43 30             	mov    0x30(%ebx),%eax
f01047fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104801:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104804:	8b 43 38             	mov    0x38(%ebx),%eax
f0104807:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010480a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010480d:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_err = tf->tf_trapno;
f0104810:	8b 43 28             	mov    0x28(%ebx),%eax
f0104813:	89 42 04             	mov    %eax,0x4(%edx)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104816:	e8 fd 1e 00 00       	call   f0106718 <cpunum>
f010481b:	6b c0 74             	imul   $0x74,%eax,%eax
f010481e:	8b 98 28 20 33 f0    	mov    -0xfccdfd8(%eax),%ebx
f0104824:	e8 ef 1e 00 00       	call   f0106718 <cpunum>
f0104829:	6b c0 74             	imul   $0x74,%eax,%eax
f010482c:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104832:	8b 40 64             	mov    0x64(%eax),%eax
f0104835:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)utf;
f0104838:	e8 db 1e 00 00       	call   f0106718 <cpunum>
f010483d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104840:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104846:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104849:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f010484c:	e8 c7 1e 00 00       	call   f0106718 <cpunum>
f0104851:	6b c0 74             	imul   $0x74,%eax,%eax
f0104854:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f010485a:	89 04 24             	mov    %eax,(%esp)
f010485d:	e8 1c f5 ff ff       	call   f0103d7e <env_run>
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104862:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104865:	e8 ae 1e 00 00       	call   f0106718 <cpunum>
		curenv->env_tf.tf_esp = (uint32_t)utf;
		env_run(curenv);
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010486a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010486e:	89 74 24 08          	mov    %esi,0x8(%esp)
				curenv->env_id, fault_va, tf->tf_eip);
f0104872:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104879:	29 c2                	sub    %eax,%edx
f010487b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010487e:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
		curenv->env_tf.tf_esp = (uint32_t)utf;
		env_run(curenv);
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104885:	8b 40 48             	mov    0x48(%eax),%eax
f0104888:	89 44 24 04          	mov    %eax,0x4(%esp)
f010488c:	c7 04 24 28 85 10 f0 	movl   $0xf0108528,(%esp)
f0104893:	e8 ee f6 ff ff       	call   f0103f86 <cprintf>
				curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104898:	89 1c 24             	mov    %ebx,(%esp)
f010489b:	e8 ea fc ff ff       	call   f010458a <print_trapframe>
	env_destroy(curenv);
f01048a0:	e8 73 1e 00 00       	call   f0106718 <cpunum>
f01048a5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048ac:	29 c2                	sub    %eax,%edx
f01048ae:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048b1:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01048b8:	89 04 24             	mov    %eax,(%esp)
f01048bb:	e8 ff f3 ff ff       	call   f0103cbf <env_destroy>
	}
}
f01048c0:	83 c4 2c             	add    $0x2c,%esp
f01048c3:	5b                   	pop    %ebx
f01048c4:	5e                   	pop    %esi
f01048c5:	5f                   	pop    %edi
f01048c6:	5d                   	pop    %ebp
f01048c7:	c3                   	ret    

f01048c8 <breakpoint_handler>:

void breakpoint_handler(struct Trapframe *tf){
f01048c8:	55                   	push   %ebp
f01048c9:	89 e5                	mov    %esp,%ebp
f01048cb:	83 ec 18             	sub    $0x18,%esp
	monitor(tf);
f01048ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01048d1:	89 04 24             	mov    %eax,(%esp)
f01048d4:	e8 76 c0 ff ff       	call   f010094f <monitor>
}
f01048d9:	c9                   	leave  
f01048da:	c3                   	ret    

f01048db <system_call_handler>:

int32_t system_call_handler(struct Trapframe *tf){
f01048db:	55                   	push   %ebp
f01048dc:	89 e5                	mov    %esp,%ebp
f01048de:	83 ec 28             	sub    $0x28,%esp
f01048e1:	8b 45 08             	mov    0x8(%ebp),%eax
	return syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,\
f01048e4:	8b 50 04             	mov    0x4(%eax),%edx
f01048e7:	89 54 24 14          	mov    %edx,0x14(%esp)
f01048eb:	8b 10                	mov    (%eax),%edx
f01048ed:	89 54 24 10          	mov    %edx,0x10(%esp)
f01048f1:	8b 50 10             	mov    0x10(%eax),%edx
f01048f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01048f8:	8b 50 18             	mov    0x18(%eax),%edx
f01048fb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048ff:	8b 50 14             	mov    0x14(%eax),%edx
f0104902:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104906:	8b 40 1c             	mov    0x1c(%eax),%eax
f0104909:	89 04 24             	mov    %eax,(%esp)
f010490c:	e8 45 05 00 00       	call   f0104e56 <syscall>
				tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);	
}
f0104911:	c9                   	leave  
f0104912:	c3                   	ret    

f0104913 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104913:	55                   	push   %ebp
f0104914:	89 e5                	mov    %esp,%ebp
f0104916:	57                   	push   %edi
f0104917:	56                   	push   %esi
f0104918:	83 ec 10             	sub    $0x10,%esp
f010491b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010491e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010491f:	83 3d 80 1e 33 f0 00 	cmpl   $0x0,0xf0331e80
f0104926:	74 01                	je     f0104929 <trap+0x16>
		asm volatile("hlt");
f0104928:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104929:	e8 ea 1d 00 00       	call   f0106718 <cpunum>
f010492e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104935:	29 c2                	sub    %eax,%edx
f0104937:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010493a:	8d 14 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104941:	b8 01 00 00 00       	mov    $0x1,%eax
f0104946:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010494a:	83 f8 02             	cmp    $0x2,%eax
f010494d:	75 0c                	jne    f010495b <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010494f:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104956:	e8 7c 20 00 00       	call   f01069d7 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010495b:	9c                   	pushf  
f010495c:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010495d:	f6 c4 02             	test   $0x2,%ah
f0104960:	74 24                	je     f0104986 <trap+0x73>
f0104962:	c7 44 24 0c 8f 83 10 	movl   $0xf010838f,0xc(%esp)
f0104969:	f0 
f010496a:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f0104971:	f0 
f0104972:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f0104979:	00 
f010497a:	c7 04 24 83 83 10 f0 	movl   $0xf0108383,(%esp)
f0104981:	e8 ba b6 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104986:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010498a:	83 e0 03             	and    $0x3,%eax
f010498d:	83 f8 03             	cmp    $0x3,%eax
f0104990:	0f 85 a7 00 00 00    	jne    f0104a3d <trap+0x12a>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104996:	e8 7d 1d 00 00       	call   f0106718 <cpunum>
f010499b:	6b c0 74             	imul   $0x74,%eax,%eax
f010499e:	83 b8 28 20 33 f0 00 	cmpl   $0x0,-0xfccdfd8(%eax)
f01049a5:	75 24                	jne    f01049cb <trap+0xb8>
f01049a7:	c7 44 24 0c a8 83 10 	movl   $0xf01083a8,0xc(%esp)
f01049ae:	f0 
f01049af:	c7 44 24 08 23 7d 10 	movl   $0xf0107d23,0x8(%esp)
f01049b6:	f0 
f01049b7:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f01049be:	00 
f01049bf:	c7 04 24 83 83 10 f0 	movl   $0xf0108383,(%esp)
f01049c6:	e8 75 b6 ff ff       	call   f0100040 <_panic>
f01049cb:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f01049d2:	e8 00 20 00 00       	call   f01069d7 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01049d7:	e8 3c 1d 00 00       	call   f0106718 <cpunum>
f01049dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049df:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01049e5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049e9:	75 2d                	jne    f0104a18 <trap+0x105>
			env_free(curenv);
f01049eb:	e8 28 1d 00 00       	call   f0106718 <cpunum>
f01049f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f3:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01049f9:	89 04 24             	mov    %eax,(%esp)
f01049fc:	e8 9a f0 ff ff       	call   f0103a9b <env_free>
			curenv = NULL;
f0104a01:	e8 12 1d 00 00       	call   f0106718 <cpunum>
f0104a06:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a09:	c7 80 28 20 33 f0 00 	movl   $0x0,-0xfccdfd8(%eax)
f0104a10:	00 00 00 
			sched_yield();
f0104a13:	e8 22 03 00 00       	call   f0104d3a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104a18:	e8 fb 1c 00 00       	call   f0106718 <cpunum>
f0104a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a20:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104a26:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a2b:	89 c7                	mov    %eax,%edi
f0104a2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a2f:	e8 e4 1c 00 00       	call   f0106718 <cpunum>
f0104a34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a37:	8b b0 28 20 33 f0    	mov    -0xfccdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104a3d:	89 35 60 1a 33 f0    	mov    %esi,0xf0331a60
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	int32_t ret;

	switch (tf->tf_trapno){
f0104a43:	8b 46 28             	mov    0x28(%esi),%eax
f0104a46:	83 f8 0e             	cmp    $0xe,%eax
f0104a49:	74 1d                	je     f0104a68 <trap+0x155>
f0104a4b:	83 f8 0e             	cmp    $0xe,%eax
f0104a4e:	77 0c                	ja     f0104a5c <trap+0x149>
f0104a50:	83 f8 01             	cmp    $0x1,%eax
f0104a53:	74 2a                	je     f0104a7f <trap+0x16c>
f0104a55:	83 f8 03             	cmp    $0x3,%eax
f0104a58:	75 46                	jne    f0104aa0 <trap+0x18d>
f0104a5a:	eb 19                	jmp    f0104a75 <trap+0x162>
f0104a5c:	83 f8 20             	cmp    $0x20,%eax
f0104a5f:	74 35                	je     f0104a96 <trap+0x183>
f0104a61:	83 f8 30             	cmp    $0x30,%eax
f0104a64:	75 3a                	jne    f0104aa0 <trap+0x18d>
f0104a66:	eb 21                	jmp    f0104a89 <trap+0x176>
		case T_PGFLT:{ //14
			page_fault_handler(tf);
f0104a68:	89 34 24             	mov    %esi,(%esp)
f0104a6b:	e8 b2 fc ff ff       	call   f0104722 <page_fault_handler>
f0104a70:	e9 87 00 00 00       	jmp    f0104afc <trap+0x1e9>
			return;
		}
		case T_BRKPT:{ //3 
			breakpoint_handler(tf);
f0104a75:	89 34 24             	mov    %esi,(%esp)
f0104a78:	e8 4b fe ff ff       	call   f01048c8 <breakpoint_handler>
f0104a7d:	eb 7d                	jmp    f0104afc <trap+0x1e9>
			return;
		}
		case T_DEBUG:{
			breakpoint_handler(tf);
f0104a7f:	89 34 24             	mov    %esi,(%esp)
f0104a82:	e8 41 fe ff ff       	call   f01048c8 <breakpoint_handler>
f0104a87:	eb 73                	jmp    f0104afc <trap+0x1e9>
			return;
		}
		case T_SYSCALL:{
			ret = system_call_handler(tf);
f0104a89:	89 34 24             	mov    %esi,(%esp)
f0104a8c:	e8 4a fe ff ff       	call   f01048db <system_call_handler>
			tf->tf_regs.reg_eax = ret;
f0104a91:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a94:	eb 66                	jmp    f0104afc <trap+0x1e9>
			return;
		}
		case IRQ_OFFSET+IRQ_TIMER:{
			lapic_eoi();
f0104a96:	e8 d4 1d 00 00       	call   f010686f <lapic_eoi>
			sched_yield();
f0104a9b:	e8 9a 02 00 00       	call   f0104d3a <sched_yield>
	}	

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104aa0:	83 f8 27             	cmp    $0x27,%eax
f0104aa3:	75 16                	jne    f0104abb <trap+0x1a8>
		cprintf("Spurious interrupt on irq 7\n");
f0104aa5:	c7 04 24 af 83 10 f0 	movl   $0xf01083af,(%esp)
f0104aac:	e8 d5 f4 ff ff       	call   f0103f86 <cprintf>
		print_trapframe(tf);
f0104ab1:	89 34 24             	mov    %esi,(%esp)
f0104ab4:	e8 d1 fa ff ff       	call   f010458a <print_trapframe>
f0104ab9:	eb 41                	jmp    f0104afc <trap+0x1e9>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104abb:	89 34 24             	mov    %esi,(%esp)
f0104abe:	e8 c7 fa ff ff       	call   f010458a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ac3:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104ac8:	75 1c                	jne    f0104ae6 <trap+0x1d3>
	  panic("unhandled trap in kernel");
f0104aca:	c7 44 24 08 cc 83 10 	movl   $0xf01083cc,0x8(%esp)
f0104ad1:	f0 
f0104ad2:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0104ad9:	00 
f0104ada:	c7 04 24 83 83 10 f0 	movl   $0xf0108383,(%esp)
f0104ae1:	e8 5a b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104ae6:	e8 2d 1c 00 00       	call   f0106718 <cpunum>
f0104aeb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aee:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104af4:	89 04 24             	mov    %eax,(%esp)
f0104af7:	e8 c3 f1 ff ff       	call   f0103cbf <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104afc:	e8 17 1c 00 00       	call   f0106718 <cpunum>
f0104b01:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b04:	83 b8 28 20 33 f0 00 	cmpl   $0x0,-0xfccdfd8(%eax)
f0104b0b:	74 2a                	je     f0104b37 <trap+0x224>
f0104b0d:	e8 06 1c 00 00       	call   f0106718 <cpunum>
f0104b12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b15:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104b1b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b1f:	75 16                	jne    f0104b37 <trap+0x224>
		env_run(curenv);
f0104b21:	e8 f2 1b 00 00       	call   f0106718 <cpunum>
f0104b26:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b29:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104b2f:	89 04 24             	mov    %eax,(%esp)
f0104b32:	e8 47 f2 ff ff       	call   f0103d7e <env_run>
	else
		sched_yield();
f0104b37:	e8 fe 01 00 00       	call   f0104d3a <sched_yield>

f0104b3c <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104b3c:	6a 00                	push   $0x0
f0104b3e:	6a 00                	push   $0x0
f0104b40:	e9 ee 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b45:	90                   	nop

f0104b46 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104b46:	6a 00                	push   $0x0
f0104b48:	6a 01                	push   $0x1
f0104b4a:	e9 e4 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b4f:	90                   	nop

f0104b50 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104b50:	6a 00                	push   $0x0
f0104b52:	6a 02                	push   $0x2
f0104b54:	e9 da 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b59:	90                   	nop

f0104b5a <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104b5a:	6a 00                	push   $0x0
f0104b5c:	6a 03                	push   $0x3
f0104b5e:	e9 d0 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b63:	90                   	nop

f0104b64 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104b64:	6a 00                	push   $0x0
f0104b66:	6a 04                	push   $0x4
f0104b68:	e9 c6 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b6d:	90                   	nop

f0104b6e <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104b6e:	6a 00                	push   $0x0
f0104b70:	6a 05                	push   $0x5
f0104b72:	e9 bc 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b77:	90                   	nop

f0104b78 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104b78:	6a 00                	push   $0x0
f0104b7a:	6a 06                	push   $0x6
f0104b7c:	e9 b2 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b81:	90                   	nop

f0104b82 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104b82:	6a 00                	push   $0x0
f0104b84:	6a 07                	push   $0x7
f0104b86:	e9 a8 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b8b:	90                   	nop

f0104b8c <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104b8c:	6a 08                	push   $0x8
f0104b8e:	e9 a0 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b93:	90                   	nop

f0104b94 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104b94:	6a 0a                	push   $0xa
f0104b96:	e9 98 00 00 00       	jmp    f0104c33 <_alltraps>
f0104b9b:	90                   	nop

f0104b9c <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0104b9c:	6a 0b                	push   $0xb
f0104b9e:	e9 90 00 00 00       	jmp    f0104c33 <_alltraps>
f0104ba3:	90                   	nop

f0104ba4 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104ba4:	6a 0c                	push   $0xc
f0104ba6:	e9 88 00 00 00       	jmp    f0104c33 <_alltraps>
f0104bab:	90                   	nop

f0104bac <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104bac:	6a 0d                	push   $0xd
f0104bae:	e9 80 00 00 00       	jmp    f0104c33 <_alltraps>
f0104bb3:	90                   	nop

f0104bb4 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104bb4:	6a 0e                	push   $0xe
f0104bb6:	e9 78 00 00 00       	jmp    f0104c33 <_alltraps>
f0104bbb:	90                   	nop

f0104bbc <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104bbc:	6a 00                	push   $0x0
f0104bbe:	6a 10                	push   $0x10
f0104bc0:	e9 6e 00 00 00       	jmp    f0104c33 <_alltraps>
f0104bc5:	90                   	nop

f0104bc6 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104bc6:	6a 11                	push   $0x11
f0104bc8:	e9 66 00 00 00       	jmp    f0104c33 <_alltraps>
f0104bcd:	90                   	nop

f0104bce <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104bce:	6a 00                	push   $0x0
f0104bd0:	6a 12                	push   $0x12
f0104bd2:	e9 5c 00 00 00       	jmp    f0104c33 <_alltraps>
f0104bd7:	90                   	nop

f0104bd8 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104bd8:	6a 00                	push   $0x0
f0104bda:	6a 13                	push   $0x13
f0104bdc:	e9 52 00 00 00       	jmp    f0104c33 <_alltraps>
f0104be1:	90                   	nop

f0104be2 <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104be2:	6a 00                	push   $0x0
f0104be4:	6a 30                	push   $0x30
f0104be6:	e9 48 00 00 00       	jmp    f0104c33 <_alltraps>
f0104beb:	90                   	nop

f0104bec <t_default>:
TRAPHANDLER_NOEC(t_default, T_DEFAULT)
f0104bec:	6a 00                	push   $0x0
f0104bee:	68 f4 01 00 00       	push   $0x1f4
f0104bf3:	e9 3b 00 00 00       	jmp    f0104c33 <_alltraps>

f0104bf8 <irq_timer>:
TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET+IRQ_TIMER)
f0104bf8:	6a 00                	push   $0x0
f0104bfa:	6a 20                	push   $0x20
f0104bfc:	e9 32 00 00 00       	jmp    f0104c33 <_alltraps>
f0104c01:	90                   	nop

f0104c02 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET+IRQ_KBD)
f0104c02:	6a 00                	push   $0x0
f0104c04:	6a 21                	push   $0x21
f0104c06:	e9 28 00 00 00       	jmp    f0104c33 <_alltraps>
f0104c0b:	90                   	nop

f0104c0c <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET+IRQ_SERIAL)
f0104c0c:	6a 00                	push   $0x0
f0104c0e:	6a 24                	push   $0x24
f0104c10:	e9 1e 00 00 00       	jmp    f0104c33 <_alltraps>
f0104c15:	90                   	nop

f0104c16 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
f0104c16:	6a 00                	push   $0x0
f0104c18:	6a 27                	push   $0x27
f0104c1a:	e9 14 00 00 00       	jmp    f0104c33 <_alltraps>
f0104c1f:	90                   	nop

f0104c20 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET+IRQ_IDE)
f0104c20:	6a 00                	push   $0x0
f0104c22:	6a 2e                	push   $0x2e
f0104c24:	e9 0a 00 00 00       	jmp    f0104c33 <_alltraps>
f0104c29:	90                   	nop

f0104c2a <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET+IRQ_ERROR)
f0104c2a:	6a 00                	push   $0x0
f0104c2c:	6a 33                	push   $0x33
f0104c2e:	e9 00 00 00 00       	jmp    f0104c33 <_alltraps>

f0104c33 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	pushl %ds
f0104c33:	1e                   	push   %ds
	pushl %es
f0104c34:	06                   	push   %es
	pushal
f0104c35:	60                   	pusha  

	movl $GD_KD,%eax
f0104c36:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104c3b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104c3d:	8e c0                	mov    %eax,%es
	push %esp
f0104c3f:	54                   	push   %esp
	call trap
f0104c40:	e8 ce fc ff ff       	call   f0104913 <trap>
f0104c45:	00 00                	add    %al,(%eax)
	...

f0104c48 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104c48:	55                   	push   %ebp
f0104c49:	89 e5                	mov    %esp,%ebp
f0104c4b:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104c4e:	8b 15 48 12 33 f0    	mov    0xf0331248,%edx
f0104c54:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c57:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104c5c:	8b 0a                	mov    (%edx),%ecx
f0104c5e:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104c5f:	83 f9 02             	cmp    $0x2,%ecx
f0104c62:	76 0d                	jbe    f0104c71 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c64:	40                   	inc    %eax
f0104c65:	83 c2 7c             	add    $0x7c,%edx
f0104c68:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c6d:	75 ed                	jne    f0104c5c <sched_halt+0x14>
f0104c6f:	eb 07                	jmp    f0104c78 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c71:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c76:	75 1a                	jne    f0104c92 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104c78:	c7 04 24 b0 85 10 f0 	movl   $0xf01085b0,(%esp)
f0104c7f:	e8 02 f3 ff ff       	call   f0103f86 <cprintf>
		while (1)
			monitor(NULL);
f0104c84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c8b:	e8 bf bc ff ff       	call   f010094f <monitor>
f0104c90:	eb f2                	jmp    f0104c84 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c92:	e8 81 1a 00 00       	call   f0106718 <cpunum>
f0104c97:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c9e:	29 c2                	sub    %eax,%edx
f0104ca0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ca3:	c7 04 85 28 20 33 f0 	movl   $0x0,-0xfccdfd8(,%eax,4)
f0104caa:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104cae:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104cb3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104cb8:	77 20                	ja     f0104cda <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104cba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104cbe:	c7 44 24 08 04 6e 10 	movl   $0xf0106e04,0x8(%esp)
f0104cc5:	f0 
f0104cc6:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
f0104ccd:	00 
f0104cce:	c7 04 24 d9 85 10 f0 	movl   $0xf01085d9,(%esp)
f0104cd5:	e8 66 b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104cda:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104cdf:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104ce2:	e8 31 1a 00 00       	call   f0106718 <cpunum>
f0104ce7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cee:	29 c2                	sub    %eax,%edx
f0104cf0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cf3:	8d 14 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104cfa:	b8 02 00 00 00       	mov    $0x2,%eax
f0104cff:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104d03:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104d0a:	e8 6b 1d 00 00       	call   f0106a7a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104d0f:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104d11:	e8 02 1a 00 00       	call   f0106718 <cpunum>
f0104d16:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d1d:	29 c2                	sub    %eax,%edx
f0104d1f:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104d22:	8b 04 85 30 20 33 f0 	mov    -0xfccdfd0(,%eax,4),%eax
f0104d29:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104d2e:	89 c4                	mov    %eax,%esp
f0104d30:	6a 00                	push   $0x0
f0104d32:	6a 00                	push   $0x0
f0104d34:	fb                   	sti    
f0104d35:	f4                   	hlt    
f0104d36:	eb fd                	jmp    f0104d35 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104d38:	c9                   	leave  
f0104d39:	c3                   	ret    

f0104d3a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104d3a:	55                   	push   %ebp
f0104d3b:	89 e5                	mov    %esp,%ebp
f0104d3d:	56                   	push   %esi
f0104d3e:	53                   	push   %ebx
f0104d3f:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
f0104d42:	e8 d1 19 00 00       	call   f0106718 <cpunum>
f0104d47:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d4e:	29 c2                	sub    %eax,%edx
f0104d50:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d53:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0104d5a:	00 
f0104d5b:	74 23                	je     f0104d80 <sched_yield+0x46>
f0104d5d:	e8 b6 19 00 00       	call   f0106718 <cpunum>
f0104d62:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d69:	29 c2                	sub    %eax,%edx
f0104d6b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d6e:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104d75:	8b 48 48             	mov    0x48(%eax),%ecx
f0104d78:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104d7e:	eb 05                	jmp    f0104d85 <sched_yield+0x4b>
f0104d80:	b9 00 00 00 00       	mov    $0x0,%ecx
	int nevs = NENV+1;
	while (--nevs){
		i = (i+1)%NENV;
		if (envs[i].env_status == ENV_RUNNABLE)
f0104d85:	8b 1d 48 12 33 f0    	mov    0xf0331248,%ebx
f0104d8b:	ba 00 04 00 00       	mov    $0x400,%edx
	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
	int nevs = NENV+1;
	while (--nevs){
		i = (i+1)%NENV;
f0104d90:	8d 41 01             	lea    0x1(%ecx),%eax
f0104d93:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104d98:	79 07                	jns    f0104da1 <sched_yield+0x67>
f0104d9a:	48                   	dec    %eax
f0104d9b:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104da0:	40                   	inc    %eax
f0104da1:	89 c1                	mov    %eax,%ecx
		if (envs[i].env_status == ENV_RUNNABLE)
f0104da3:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0104daa:	c1 e0 07             	shl    $0x7,%eax
f0104dad:	29 f0                	sub    %esi,%eax
f0104daf:	01 d8                	add    %ebx,%eax
f0104db1:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104db5:	75 08                	jne    f0104dbf <sched_yield+0x85>
			env_run(&envs[i]);
f0104db7:	89 04 24             	mov    %eax,(%esp)
f0104dba:	e8 bf ef ff ff       	call   f0103d7e <env_run>

	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
	int nevs = NENV+1;
	while (--nevs){
f0104dbf:	4a                   	dec    %edx
f0104dc0:	75 ce                	jne    f0104d90 <sched_yield+0x56>
		i = (i+1)%NENV;
		if (envs[i].env_status == ENV_RUNNABLE)
			env_run(&envs[i]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104dc2:	e8 51 19 00 00       	call   f0106718 <cpunum>
f0104dc7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dce:	29 c2                	sub    %eax,%edx
f0104dd0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dd3:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0104dda:	00 
f0104ddb:	74 3e                	je     f0104e1b <sched_yield+0xe1>
f0104ddd:	e8 36 19 00 00       	call   f0106718 <cpunum>
f0104de2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104de9:	29 c2                	sub    %eax,%edx
f0104deb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dee:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104df5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104df9:	75 20                	jne    f0104e1b <sched_yield+0xe1>
		env_run(curenv);
f0104dfb:	e8 18 19 00 00       	call   f0106718 <cpunum>
f0104e00:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e07:	29 c2                	sub    %eax,%edx
f0104e09:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e0c:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104e13:	89 04 24             	mov    %eax,(%esp)
f0104e16:	e8 63 ef ff ff       	call   f0103d7e <env_run>

	// sched_halt never returns
	sched_halt();
f0104e1b:	e8 28 fe ff ff       	call   f0104c48 <sched_halt>
}
f0104e20:	83 c4 10             	add    $0x10,%esp
f0104e23:	5b                   	pop    %ebx
f0104e24:	5e                   	pop    %esi
f0104e25:	5d                   	pop    %ebp
f0104e26:	c3                   	ret    
	...

f0104e28 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104e28:	55                   	push   %ebp
f0104e29:	89 e5                	mov    %esp,%ebp
f0104e2b:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104e2e:	e8 e5 18 00 00       	call   f0106718 <cpunum>
f0104e33:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e3a:	29 c2                	sub    %eax,%edx
f0104e3c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e3f:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104e46:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104e49:	c9                   	leave  
f0104e4a:	c3                   	ret    

f0104e4b <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104e4b:	55                   	push   %ebp
f0104e4c:	89 e5                	mov    %esp,%ebp
f0104e4e:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104e51:	e8 e4 fe ff ff       	call   f0104d3a <sched_yield>

f0104e56 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104e56:	55                   	push   %ebp
f0104e57:	89 e5                	mov    %esp,%ebp
f0104e59:	57                   	push   %edi
f0104e5a:	56                   	push   %esi
f0104e5b:	53                   	push   %ebx
f0104e5c:	83 ec 2c             	sub    $0x2c,%esp
f0104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e62:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e65:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e68:	8b 5d 18             	mov    0x18(%ebp),%ebx
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104e6b:	83 f8 0c             	cmp    $0xc,%eax
f0104e6e:	0f 87 a4 06 00 00    	ja     f0105518 <syscall+0x6c2>
f0104e74:	ff 24 85 64 88 10 f0 	jmp    *-0xfef779c(,%eax,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.

	user_mem_assert(curenv, (void*)s, len, 0); 
f0104e7b:	e8 98 18 00 00       	call   f0106718 <cpunum>
f0104e80:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104e87:	00 
f0104e88:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104e8c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e90:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e97:	29 c2                	sub    %eax,%edx
f0104e99:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e9c:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104ea3:	89 04 24             	mov    %eax,(%esp)
f0104ea6:	e8 34 e6 ff ff       	call   f01034df <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104eab:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104eaf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104eb3:	c7 04 24 e6 85 10 f0 	movl   $0xf01085e6,(%esp)
f0104eba:	e8 c7 f0 ff ff       	call   f0103f86 <cprintf>
	//panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:{
						   sys_cputs((char*)a1, a2);
						   return 0;
f0104ebf:	be 00 00 00 00       	mov    $0x0,%esi
f0104ec4:	e9 5b 06 00 00       	jmp    f0105524 <syscall+0x6ce>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104ec9:	e8 4a b7 ff ff       	call   f0100618 <cons_getc>
f0104ece:	89 c6                	mov    %eax,%esi
		case SYS_cputs:{
						   sys_cputs((char*)a1, a2);
						   return 0;
					   }
		case SYS_cgetc:
					   return sys_cgetc();	
f0104ed0:	e9 4f 06 00 00       	jmp    f0105524 <syscall+0x6ce>
		case SYS_getenvid:
					   return sys_getenvid(); 
f0104ed5:	e8 4e ff ff ff       	call   f0104e28 <sys_getenvid>
f0104eda:	89 c6                	mov    %eax,%esi
f0104edc:	e9 43 06 00 00       	jmp    f0105524 <syscall+0x6ce>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ee1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ee8:	00 
f0104ee9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104eec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ef0:	89 34 24             	mov    %esi,(%esp)
f0104ef3:	e8 02 e7 ff ff       	call   f01035fa <envid2env>
f0104ef8:	89 c6                	mov    %eax,%esi
f0104efa:	85 c0                	test   %eax,%eax
f0104efc:	0f 88 22 06 00 00    	js     f0105524 <syscall+0x6ce>
	  return r;
	if (e == curenv)
f0104f02:	e8 11 18 00 00       	call   f0106718 <cpunum>
f0104f07:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104f0a:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104f11:	29 c1                	sub    %eax,%ecx
f0104f13:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104f16:	39 14 85 28 20 33 f0 	cmp    %edx,-0xfccdfd8(,%eax,4)
f0104f1d:	75 2d                	jne    f0104f4c <syscall+0xf6>
	  cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104f1f:	e8 f4 17 00 00       	call   f0106718 <cpunum>
f0104f24:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f2b:	29 c2                	sub    %eax,%edx
f0104f2d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f30:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104f37:	8b 40 48             	mov    0x48(%eax),%eax
f0104f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f3e:	c7 04 24 eb 85 10 f0 	movl   $0xf01085eb,(%esp)
f0104f45:	e8 3c f0 ff ff       	call   f0103f86 <cprintf>
f0104f4a:	eb 32                	jmp    f0104f7e <syscall+0x128>
	else
	  cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104f4c:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104f4f:	e8 c4 17 00 00       	call   f0106718 <cpunum>
f0104f54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104f58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f5f:	29 c2                	sub    %eax,%edx
f0104f61:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f64:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104f6b:	8b 40 48             	mov    0x48(%eax),%eax
f0104f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f72:	c7 04 24 06 86 10 f0 	movl   $0xf0108606,(%esp)
f0104f79:	e8 08 f0 ff ff       	call   f0103f86 <cprintf>
	env_destroy(e);
f0104f7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f81:	89 04 24             	mov    %eax,(%esp)
f0104f84:	e8 36 ed ff ff       	call   f0103cbf <env_destroy>
	return 0;
f0104f89:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_cgetc:
					   return sys_cgetc();	
		case SYS_getenvid:
					   return sys_getenvid(); 
		case SYS_env_destroy:
					   return sys_env_destroy(a1); 
f0104f8e:	e9 91 05 00 00       	jmp    f0105524 <syscall+0x6ce>
		case SYS_yield:{
						   sys_yield();
f0104f93:	e8 b3 fe ff ff       	call   f0104e4b <sys_yield>

	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");

	struct Env* e;
	int ret = env_alloc(&e, sys_getenvid());
f0104f98:	e8 8b fe ff ff       	call   f0104e28 <sys_getenvid>
f0104f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fa1:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104fa4:	89 04 24             	mov    %eax,(%esp)
f0104fa7:	e8 88 e7 ff ff       	call   f0103734 <env_alloc>
f0104fac:	89 c6                	mov    %eax,%esi
	if (ret < 0){
f0104fae:	85 c0                	test   %eax,%eax
f0104fb0:	79 11                	jns    f0104fc3 <syscall+0x16d>
		cprintf("sys_exofork: env_alloc failed");
f0104fb2:	c7 04 24 1e 86 10 f0 	movl   $0xf010861e,(%esp)
f0104fb9:	e8 c8 ef ff ff       	call   f0103f86 <cprintf>
f0104fbe:	e9 61 05 00 00       	jmp    f0105524 <syscall+0x6ce>
		return ret;
	}
	e->env_status = ENV_NOT_RUNNABLE;
f0104fc3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104fc6:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104fcd:	e8 46 17 00 00       	call   f0106718 <cpunum>
f0104fd2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104fd9:	29 c2                	sub    %eax,%edx
f0104fdb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fde:	8b 34 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%esi
f0104fe5:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104fea:	89 df                	mov    %ebx,%edi
f0104fec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;  //?
f0104fee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ff1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104ff8:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_yield:{
						   sys_yield();
						   return 0;
					   }
		case SYS_exofork:
					   return sys_exofork();
f0104ffb:	e9 24 05 00 00       	jmp    f0105524 <syscall+0x6ce>
	// envid's status.

	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");

	if (status != ENV_RUNNABLE && status!= ENV_NOT_RUNNABLE) {
f0105000:	83 ff 02             	cmp    $0x2,%edi
f0105003:	74 1b                	je     f0105020 <syscall+0x1ca>
f0105005:	83 ff 04             	cmp    $0x4,%edi
f0105008:	74 16                	je     f0105020 <syscall+0x1ca>
		cprintf("sys_env_set_status: wrong status input");
f010500a:	c7 04 24 4c 86 10 f0 	movl   $0xf010864c,(%esp)
f0105011:	e8 70 ef ff ff       	call   f0103f86 <cprintf>
		return -E_INVAL;
f0105016:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010501b:	e9 04 05 00 00       	jmp    f0105524 <syscall+0x6ce>
	}

	struct Env* e;
	int ret = envid2env(envid, &e, true);
f0105020:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105027:	00 
f0105028:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010502b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010502f:	89 34 24             	mov    %esi,(%esp)
f0105032:	e8 c3 e5 ff ff       	call   f01035fa <envid2env>
f0105037:	89 c6                	mov    %eax,%esi
	if (ret < 0) {
f0105039:	85 c0                	test   %eax,%eax
f010503b:	79 11                	jns    f010504e <syscall+0x1f8>
		cprintf("sys_env_set_status: envid2env fail");
f010503d:	c7 04 24 74 86 10 f0 	movl   $0xf0108674,(%esp)
f0105044:	e8 3d ef ff ff       	call   f0103f86 <cprintf>
f0105049:	e9 d6 04 00 00       	jmp    f0105524 <syscall+0x6ce>
		return ret;
	}
	e->env_status = status;
f010504e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105051:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0105054:	be 00 00 00 00       	mov    $0x0,%esi
						   return 0;
					   }
		case SYS_exofork:
					   return sys_exofork();
		case SYS_env_set_status:
					   return sys_env_set_status(a1, a2);
f0105059:	e9 c6 04 00 00       	jmp    f0105524 <syscall+0x6ce>

	// LAB 4: Your code here.
	//panic("sys_page_alloc not implemented");

	//check input validness
	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va){
f010505e:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105064:	77 0f                	ja     f0105075 <syscall+0x21f>
f0105066:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f010506c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105071:	39 c7                	cmp    %eax,%edi
f0105073:	74 16                	je     f010508b <syscall+0x235>
		cprintf("sys_page_alloc: wrong va input");
f0105075:	c7 04 24 98 86 10 f0 	movl   $0xf0108698,(%esp)
f010507c:	e8 05 ef ff ff       	call   f0103f86 <cprintf>
		return -E_INVAL;
f0105081:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105086:	e9 99 04 00 00       	jmp    f0105524 <syscall+0x6ce>
	}

	if((perm & ~PTE_SYSCALL) != 0){
f010508b:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0105092:	74 16                	je     f01050aa <syscall+0x254>
		cprintf("sys_page_alloc: wrong perm input");
f0105094:	c7 04 24 b8 86 10 f0 	movl   $0xf01086b8,(%esp)
f010509b:	e8 e6 ee ff ff       	call   f0103f86 <cprintf>
		return -E_INVAL;
f01050a0:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050a5:	e9 7a 04 00 00       	jmp    f0105524 <syscall+0x6ce>
	}

	struct PageInfo* pp;
	struct Env* e;
	int ret1 = envid2env(envid, &e, 1);
f01050aa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050b1:	00 
f01050b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01050b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b9:	89 34 24             	mov    %esi,(%esp)
f01050bc:	e8 39 e5 ff ff       	call   f01035fa <envid2env>
	if (ret1 < 0) {
f01050c1:	85 c0                	test   %eax,%eax
f01050c3:	79 16                	jns    f01050db <syscall+0x285>
		cprintf("sys_page_alloc: envid2env wrong");
f01050c5:	c7 04 24 dc 86 10 f0 	movl   $0xf01086dc,(%esp)
f01050cc:	e8 b5 ee ff ff       	call   f0103f86 <cprintf>
		return -E_BAD_ENV; 
f01050d1:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01050d6:	e9 49 04 00 00       	jmp    f0105524 <syscall+0x6ce>
	}

	pp = page_alloc(1);
f01050db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01050e2:	e8 a4 be ff ff       	call   f0100f8b <page_alloc>
f01050e7:	89 c3                	mov    %eax,%ebx
	if (pp == NULL) {
f01050e9:	85 c0                	test   %eax,%eax
f01050eb:	75 16                	jne    f0105103 <syscall+0x2ad>
		cprintf("sys_page_alloc: page_alloc failed");
f01050ed:	c7 04 24 fc 86 10 f0 	movl   $0xf01086fc,(%esp)
f01050f4:	e8 8d ee ff ff       	call   f0103f86 <cprintf>
		return -E_NO_MEM;
f01050f9:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01050fe:	e9 21 04 00 00       	jmp    f0105524 <syscall+0x6ce>
	}

	int ret2 = page_insert(e->env_pgdir, pp, va, perm);
f0105103:	8b 45 14             	mov    0x14(%ebp),%eax
f0105106:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010510a:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010510e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105112:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105115:	8b 40 60             	mov    0x60(%eax),%eax
f0105118:	89 04 24             	mov    %eax,(%esp)
f010511b:	e8 05 c2 ff ff       	call   f0101325 <page_insert>
	if (ret2 < 0){
f0105120:	85 c0                	test   %eax,%eax
f0105122:	79 1e                	jns    f0105142 <syscall+0x2ec>
		page_free(pp);
f0105124:	89 1c 24             	mov    %ebx,(%esp)
f0105127:	e8 12 bf ff ff       	call   f010103e <page_free>
		cprintf("sys_page_alloc: page_insert failed");
f010512c:	c7 04 24 20 87 10 f0 	movl   $0xf0108720,(%esp)
f0105133:	e8 4e ee ff ff       	call   f0103f86 <cprintf>
		return -E_NO_MEM;
f0105138:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f010513d:	e9 e2 03 00 00       	jmp    f0105524 <syscall+0x6ce>
	}
	return 0;
f0105142:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_exofork:
					   return sys_exofork();
		case SYS_env_set_status:
					   return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
					   return sys_page_alloc(a1, (void*)a2, a3); 
f0105147:	e9 d8 03 00 00       	jmp    f0105524 <syscall+0x6ce>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE)!=srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE)!=dstva){
f010514c:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105152:	77 26                	ja     f010517a <syscall+0x324>
f0105154:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f010515a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010515f:	39 c7                	cmp    %eax,%edi
f0105161:	75 17                	jne    f010517a <syscall+0x324>
f0105163:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105169:	77 0f                	ja     f010517a <syscall+0x324>
f010516b:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0105171:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105176:	39 c3                	cmp    %eax,%ebx
f0105178:	74 1c                	je     f0105196 <syscall+0x340>
		panic("sys_page_map: invalid srcva | dstva");
f010517a:	c7 44 24 08 44 87 10 	movl   $0xf0108744,0x8(%esp)
f0105181:	f0 
f0105182:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0105189:	00 
f010518a:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f0105191:	e8 aa ae ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	if ((perm & ~PTE_SYSCALL)!=0){
f0105196:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f010519d:	74 1c                	je     f01051bb <syscall+0x365>
		panic("sys_page_map: invalid permission");
f010519f:	c7 44 24 08 68 87 10 	movl   $0xf0108768,0x8(%esp)
f01051a6:	f0 
f01051a7:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
f01051ae:	00 
f01051af:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f01051b6:	e8 85 ae ff ff       	call   f0100040 <_panic>

	pte_t* srcpte;
	struct Env* srcenv;
	struct Env* dstenv; 
	struct PageInfo* pp;
	if ((envid2env(srcenvid, &srcenv, true) < 0) || envid2env(dstenvid, &dstenv, true) < 0)
f01051bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051c2:	00 
f01051c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01051c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ca:	89 34 24             	mov    %esi,(%esp)
f01051cd:	e8 28 e4 ff ff       	call   f01035fa <envid2env>
f01051d2:	85 c0                	test   %eax,%eax
f01051d4:	0f 88 a6 00 00 00    	js     f0105280 <syscall+0x42a>
f01051da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051e1:	00 
f01051e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051e9:	8b 55 14             	mov    0x14(%ebp),%edx
f01051ec:	89 14 24             	mov    %edx,(%esp)
f01051ef:	e8 06 e4 ff ff       	call   f01035fa <envid2env>
f01051f4:	85 c0                	test   %eax,%eax
f01051f6:	0f 88 8e 00 00 00    	js     f010528a <syscall+0x434>
	  return -E_BAD_ENV;
	pp = page_lookup(srcenv->env_pgdir, srcva, &srcpte);	
f01051fc:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01051ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105203:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105207:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010520a:	8b 40 60             	mov    0x60(%eax),%eax
f010520d:	89 04 24             	mov    %eax,(%esp)
f0105210:	e8 07 c0 ff ff       	call   f010121c <page_lookup>
	if (pp == NULL || ((perm&PTE_W) > 0 && (*srcpte&PTE_W) == 0)){
f0105215:	85 c0                	test   %eax,%eax
f0105217:	74 0e                	je     f0105227 <syscall+0x3d1>
f0105219:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010521d:	74 24                	je     f0105243 <syscall+0x3ed>
f010521f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105222:	f6 02 02             	testb  $0x2,(%edx)
f0105225:	75 1c                	jne    f0105243 <syscall+0x3ed>
		panic("sys_page_map: page_lookup failed");
f0105227:	c7 44 24 08 8c 87 10 	movl   $0xf010878c,0x8(%esp)
f010522e:	f0 
f010522f:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0105236:	00 
f0105237:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f010523e:	e8 fd ad ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0){
f0105243:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105246:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010524a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010524e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105255:	8b 40 60             	mov    0x60(%eax),%eax
f0105258:	89 04 24             	mov    %eax,(%esp)
f010525b:	e8 c5 c0 ff ff       	call   f0101325 <page_insert>
f0105260:	85 c0                	test   %eax,%eax
f0105262:	79 30                	jns    f0105294 <syscall+0x43e>
		panic("sys_page_map: page_insert failed");
f0105264:	c7 44 24 08 b0 87 10 	movl   $0xf01087b0,0x8(%esp)
f010526b:	f0 
f010526c:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
f0105273:	00 
f0105274:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f010527b:	e8 c0 ad ff ff       	call   f0100040 <_panic>
	pte_t* srcpte;
	struct Env* srcenv;
	struct Env* dstenv; 
	struct PageInfo* pp;
	if ((envid2env(srcenvid, &srcenv, true) < 0) || envid2env(dstenvid, &dstenv, true) < 0)
	  return -E_BAD_ENV;
f0105280:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105285:	e9 9a 02 00 00       	jmp    f0105524 <syscall+0x6ce>
f010528a:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f010528f:	e9 90 02 00 00       	jmp    f0105524 <syscall+0x6ce>
	}
	if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0){
		panic("sys_page_map: page_insert failed");
		return -E_NO_MEM;
	}
	return 0;
f0105294:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_env_set_status:
					   return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
					   return sys_page_alloc(a1, (void*)a2, a3); 
		case SYS_page_map:
					   return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0105299:	e9 86 02 00 00       	jmp    f0105524 <syscall+0x6ce>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE)!= va)
f010529e:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01052a4:	77 46                	ja     f01052ec <syscall+0x496>
f01052a6:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f01052ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01052b1:	39 c7                	cmp    %eax,%edi
f01052b3:	75 41                	jne    f01052f6 <syscall+0x4a0>
	  return -E_INVAL;
	struct Env* e;
	if (envid2env(envid, &e, true) < 0)
f01052b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052bc:	00 
f01052bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052c4:	89 34 24             	mov    %esi,(%esp)
f01052c7:	e8 2e e3 ff ff       	call   f01035fa <envid2env>
f01052cc:	85 c0                	test   %eax,%eax
f01052ce:	78 30                	js     f0105300 <syscall+0x4aa>
	  return -E_BAD_ENV;
	page_remove(e->env_pgdir, va);
f01052d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01052d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052d7:	8b 40 60             	mov    0x60(%eax),%eax
f01052da:	89 04 24             	mov    %eax,(%esp)
f01052dd:	e8 f3 bf ff ff       	call   f01012d5 <page_remove>
	return 0;
f01052e2:	be 00 00 00 00       	mov    $0x0,%esi
f01052e7:	e9 38 02 00 00       	jmp    f0105524 <syscall+0x6ce>

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE)!= va)
	  return -E_INVAL;
f01052ec:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052f1:	e9 2e 02 00 00       	jmp    f0105524 <syscall+0x6ce>
f01052f6:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052fb:	e9 24 02 00 00       	jmp    f0105524 <syscall+0x6ce>
	struct Env* e;
	if (envid2env(envid, &e, true) < 0)
	  return -E_BAD_ENV;
f0105300:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_alloc:
					   return sys_page_alloc(a1, (void*)a2, a3); 
		case SYS_page_map:
					   return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
					   return sys_page_unmap(a1, (void*)a2);
f0105305:	e9 1a 02 00 00       	jmp    f0105524 <syscall+0x6ce>
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
f010530a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105311:	00 
f0105312:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105315:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105319:	89 34 24             	mov    %esi,(%esp)
f010531c:	e8 d9 e2 ff ff       	call   f01035fa <envid2env>
f0105321:	85 c0                	test   %eax,%eax
f0105323:	78 10                	js     f0105335 <syscall+0x4df>
	  return -E_BAD_ENV;

	e->env_pgfault_upcall = func;
f0105325:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105328:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f010532b:	be 00 00 00 00       	mov    $0x0,%esi
f0105330:	e9 ef 01 00 00       	jmp    f0105524 <syscall+0x6ce>
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
	  return -E_BAD_ENV;
f0105335:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_map:
					   return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
					   return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_pgfault_upcall:
					   return sys_env_set_pgfault_upcall(a1, (void*)a2);		
f010533a:	e9 e5 01 00 00       	jmp    f0105524 <syscall+0x6ce>
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");

	int r;
	struct Env* e;
	if (envid2env(envid, &e, 0) < 0){
f010533f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105346:	00 
f0105347:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010534a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010534e:	89 34 24             	mov    %esi,(%esp)
f0105351:	e8 a4 e2 ff ff       	call   f01035fa <envid2env>
f0105356:	85 c0                	test   %eax,%eax
f0105358:	79 1c                	jns    f0105376 <syscall+0x520>
		panic("sys_ipc_try_send: envid2env failed");
f010535a:	c7 44 24 08 d4 87 10 	movl   $0xf01087d4,0x8(%esp)
f0105361:	f0 
f0105362:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
f0105369:	00 
f010536a:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f0105371:	e8 ca ac ff ff       	call   f0100040 <_panic>
		return -E_BAD_ENV;
	}
	if (e->env_ipc_recving == false) 
f0105376:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105379:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010537d:	0f 84 37 01 00 00    	je     f01054ba <syscall+0x664>
		return -E_IPC_NOT_RECV;
	e->env_ipc_perm = 0;
f0105383:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	if ((uint32_t)srcva < UTOP){
f010538a:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105391:	0f 87 e3 00 00 00    	ja     f010547a <syscall+0x624>
		pte_t* pte; 
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f0105397:	e8 7c 13 00 00       	call   f0106718 <cpunum>
f010539c:	8d 55 e0             	lea    -0x20(%ebp),%edx
f010539f:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053a3:	8b 55 14             	mov    0x14(%ebp),%edx
f01053a6:	89 54 24 04          	mov    %edx,0x4(%esp)
f01053aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01053b1:	29 c2                	sub    %eax,%edx
f01053b3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053b6:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01053bd:	8b 40 60             	mov    0x60(%eax),%eax
f01053c0:	89 04 24             	mov    %eax,(%esp)
f01053c3:	e8 54 be ff ff       	call   f010121c <page_lookup>
		if (pte == NULL)
f01053c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053cb:	85 d2                	test   %edx,%edx
f01053cd:	0f 84 ee 00 00 00    	je     f01054c1 <syscall+0x66b>
			return -E_INVAL;
		if (ROUNDDOWN(srcva, PGSIZE) != srcva || ((perm & ~PTE_SYSCALL) != 0)){
f01053d3:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01053d6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01053dc:	39 4d 14             	cmp    %ecx,0x14(%ebp)
f01053df:	75 08                	jne    f01053e9 <syscall+0x593>
f01053e1:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f01053e7:	74 1c                	je     f0105405 <syscall+0x5af>
			panic("sys_ipc_try_send: srcva failed)");
f01053e9:	c7 44 24 08 f8 87 10 	movl   $0xf01087f8,0x8(%esp)
f01053f0:	f0 
f01053f1:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
f01053f8:	00 
f01053f9:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f0105400:	e8 3b ac ff ff       	call   f0100040 <_panic>
			return -E_INVAL;
		}
		if ((perm&PTE_W) && (*pte&PTE_W)==0){
f0105405:	f6 c3 02             	test   $0x2,%bl
f0105408:	74 21                	je     f010542b <syscall+0x5d5>
f010540a:	f6 02 02             	testb  $0x2,(%edx)
f010540d:	75 1c                	jne    f010542b <syscall+0x5d5>
			panic("sys_ipc_try_send: permission failed");
f010540f:	c7 44 24 08 18 88 10 	movl   $0xf0108818,0x8(%esp)
f0105416:	f0 
f0105417:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f010541e:	00 
f010541f:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f0105426:	e8 15 ac ff ff       	call   f0100040 <_panic>
			return -E_INVAL;
		}
		if ((uint32_t)e->env_ipc_dstva < UTOP){
f010542b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010542e:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105431:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0105437:	77 41                	ja     f010547a <syscall+0x624>
			if((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0){
f0105439:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010543d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105441:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105445:	8b 42 60             	mov    0x60(%edx),%eax
f0105448:	89 04 24             	mov    %eax,(%esp)
f010544b:	e8 d5 be ff ff       	call   f0101325 <page_insert>
f0105450:	85 c0                	test   %eax,%eax
f0105452:	79 20                	jns    f0105474 <syscall+0x61e>
				panic("sys_ipc_try_send: page_insert failed %e", r);
f0105454:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105458:	c7 44 24 08 3c 88 10 	movl   $0xf010883c,0x8(%esp)
f010545f:	f0 
f0105460:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f0105467:	00 
f0105468:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f010546f:	e8 cc ab ff ff       	call   f0100040 <_panic>
				return -E_NO_MEM;
			}
			e->env_ipc_perm = perm;
f0105474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105477:	89 58 78             	mov    %ebx,0x78(%eax)
		}
	}
	e->env_ipc_recving = 0;
f010547a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010547d:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id; 
f0105481:	e8 92 12 00 00       	call   f0106718 <cpunum>
f0105486:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010548d:	29 c2                	sub    %eax,%edx
f010548f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105492:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105499:	8b 40 48             	mov    0x48(%eax),%eax
f010549c:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f010549f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054a2:	89 78 70             	mov    %edi,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f01054a5:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax= 0;
f01054ac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f01054b3:	be 00 00 00 00       	mov    $0x0,%esi
f01054b8:	eb 6a                	jmp    f0105524 <syscall+0x6ce>
	if (envid2env(envid, &e, 0) < 0){
		panic("sys_ipc_try_send: envid2env failed");
		return -E_BAD_ENV;
	}
	if (e->env_ipc_recving == false) 
		return -E_IPC_NOT_RECV;
f01054ba:	be f8 ff ff ff       	mov    $0xfffffff8,%esi
f01054bf:	eb 63                	jmp    f0105524 <syscall+0x6ce>
	e->env_ipc_perm = 0;
	if ((uint32_t)srcva < UTOP){
		pte_t* pte; 
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (pte == NULL)
			return -E_INVAL;
f01054c1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		case SYS_page_unmap:
					   return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_pgfault_upcall:
					   return sys_env_set_pgfault_upcall(a1, (void*)a2);		
		case SYS_ipc_try_send:
					   return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f01054c6:	eb 5c                	jmp    f0105524 <syscall+0x6ce>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");

	if (((uint32_t)dstva < UTOP) && (ROUNDDOWN(dstva, PGSIZE) != dstva))
f01054c8:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01054ce:	77 0b                	ja     f01054db <syscall+0x685>
f01054d0:	89 f0                	mov    %esi,%eax
f01054d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01054d7:	39 c6                	cmp    %eax,%esi
f01054d9:	75 44                	jne    f010551f <syscall+0x6c9>
	  return -E_INVAL;
	curenv->env_ipc_recving = true;
f01054db:	e8 38 12 00 00       	call   f0106718 <cpunum>
f01054e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01054e3:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01054e9:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01054ed:	e8 26 12 00 00       	call   f0106718 <cpunum>
f01054f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01054f5:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01054fb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0105502:	e8 11 12 00 00       	call   f0106718 <cpunum>
f0105507:	6b c0 74             	imul   $0x74,%eax,%eax
f010550a:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0105510:	89 70 6c             	mov    %esi,0x6c(%eax)

	sys_yield();
f0105513:	e8 33 f9 ff ff       	call   f0104e4b <sys_yield>
		case SYS_ipc_try_send:
					   return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
					   return sys_ipc_recv((void*)a1);
		default:
					   return -E_INVAL;
f0105518:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010551d:	eb 05                	jmp    f0105524 <syscall+0x6ce>
		case SYS_env_set_pgfault_upcall:
					   return sys_env_set_pgfault_upcall(a1, (void*)a2);		
		case SYS_ipc_try_send:
					   return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
					   return sys_ipc_recv((void*)a1);
f010551f:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		default:
					   return -E_INVAL;
	}	
}
f0105524:	89 f0                	mov    %esi,%eax
f0105526:	83 c4 2c             	add    $0x2c,%esp
f0105529:	5b                   	pop    %ebx
f010552a:	5e                   	pop    %esi
f010552b:	5f                   	pop    %edi
f010552c:	5d                   	pop    %ebp
f010552d:	c3                   	ret    
	...

f0105530 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105530:	55                   	push   %ebp
f0105531:	89 e5                	mov    %esp,%ebp
f0105533:	57                   	push   %edi
f0105534:	56                   	push   %esi
f0105535:	53                   	push   %ebx
f0105536:	83 ec 14             	sub    $0x14,%esp
f0105539:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010553c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010553f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105542:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105545:	8b 1a                	mov    (%edx),%ebx
f0105547:	8b 01                	mov    (%ecx),%eax
f0105549:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010554c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0105553:	e9 83 00 00 00       	jmp    f01055db <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0105558:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010555b:	01 d8                	add    %ebx,%eax
f010555d:	89 c7                	mov    %eax,%edi
f010555f:	c1 ef 1f             	shr    $0x1f,%edi
f0105562:	01 c7                	add    %eax,%edi
f0105564:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105566:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105569:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010556c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105570:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105572:	eb 01                	jmp    f0105575 <stab_binsearch+0x45>
			m--;
f0105574:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105575:	39 c3                	cmp    %eax,%ebx
f0105577:	7f 1e                	jg     f0105597 <stab_binsearch+0x67>
f0105579:	0f b6 0a             	movzbl (%edx),%ecx
f010557c:	83 ea 0c             	sub    $0xc,%edx
f010557f:	39 f1                	cmp    %esi,%ecx
f0105581:	75 f1                	jne    f0105574 <stab_binsearch+0x44>
f0105583:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105586:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105589:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010558c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105590:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105593:	76 18                	jbe    f01055ad <stab_binsearch+0x7d>
f0105595:	eb 05                	jmp    f010559c <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105597:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010559a:	eb 3f                	jmp    f01055db <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010559c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010559f:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01055a1:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055a4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01055ab:	eb 2e                	jmp    f01055db <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01055ad:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01055b0:	73 15                	jae    f01055c7 <stab_binsearch+0x97>
			*region_right = m - 1;
f01055b2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01055b5:	49                   	dec    %ecx
f01055b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01055b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055bc:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055be:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01055c5:	eb 14                	jmp    f01055db <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01055c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01055ca:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055cd:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f01055cf:	ff 45 0c             	incl   0xc(%ebp)
f01055d2:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01055d4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01055db:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01055de:	0f 8e 74 ff ff ff    	jle    f0105558 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01055e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01055e8:	75 0d                	jne    f01055f7 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01055ea:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055ed:	8b 02                	mov    (%edx),%eax
f01055ef:	48                   	dec    %eax
f01055f0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055f3:	89 01                	mov    %eax,(%ecx)
f01055f5:	eb 2a                	jmp    f0105621 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01055f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055fa:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01055fc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055ff:	8b 0a                	mov    (%edx),%ecx
f0105601:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105604:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0105607:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010560b:	eb 01                	jmp    f010560e <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010560d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010560e:	39 c8                	cmp    %ecx,%eax
f0105610:	7e 0a                	jle    f010561c <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0105612:	0f b6 1a             	movzbl (%edx),%ebx
f0105615:	83 ea 0c             	sub    $0xc,%edx
f0105618:	39 f3                	cmp    %esi,%ebx
f010561a:	75 f1                	jne    f010560d <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f010561c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010561f:	89 02                	mov    %eax,(%edx)
	}
}
f0105621:	83 c4 14             	add    $0x14,%esp
f0105624:	5b                   	pop    %ebx
f0105625:	5e                   	pop    %esi
f0105626:	5f                   	pop    %edi
f0105627:	5d                   	pop    %ebp
f0105628:	c3                   	ret    

f0105629 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105629:	55                   	push   %ebp
f010562a:	89 e5                	mov    %esp,%ebp
f010562c:	57                   	push   %edi
f010562d:	56                   	push   %esi
f010562e:	53                   	push   %ebx
f010562f:	83 ec 5c             	sub    $0x5c,%esp
f0105632:	8b 75 08             	mov    0x8(%ebp),%esi
f0105635:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105638:	c7 03 98 88 10 f0    	movl   $0xf0108898,(%ebx)
	info->eip_line = 0;
f010563e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105645:	c7 43 08 98 88 10 f0 	movl   $0xf0108898,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010564c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105653:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105656:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010565d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105663:	0f 87 df 00 00 00    	ja     f0105748 <debuginfo_eip+0x11f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0105669:	e8 aa 10 00 00       	call   f0106718 <cpunum>
f010566e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105675:	00 
f0105676:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010567d:	00 
f010567e:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105685:	00 
f0105686:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010568d:	29 c2                	sub    %eax,%edx
f010568f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105692:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105699:	89 04 24             	mov    %eax,(%esp)
f010569c:	e8 99 dd ff ff       	call   f010343a <user_mem_check>
f01056a1:	85 c0                	test   %eax,%eax
f01056a3:	0f 88 53 02 00 00    	js     f01058fc <debuginfo_eip+0x2d3>
			return -1;

		stabs = usd->stabs;
f01056a9:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01056af:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01056b2:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01056b8:	a1 08 00 20 00       	mov    0x200008,%eax
f01056bd:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01056c0:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01056c6:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
f01056c9:	e8 4a 10 00 00       	call   f0106718 <cpunum>
f01056ce:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01056d5:	00 
f01056d6:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01056dd:	00 
f01056de:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01056e1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01056e5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056ec:	29 c2                	sub    %eax,%edx
f01056ee:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056f1:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01056f8:	89 04 24             	mov    %eax,(%esp)
f01056fb:	e8 3a dd ff ff       	call   f010343a <user_mem_check>
f0105700:	85 c0                	test   %eax,%eax
f0105702:	0f 88 fb 01 00 00    	js     f0105903 <debuginfo_eip+0x2da>
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
f0105708:	e8 0b 10 00 00       	call   f0106718 <cpunum>
f010570d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105714:	00 
f0105715:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010571c:	00 
f010571d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105720:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105724:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010572b:	29 c2                	sub    %eax,%edx
f010572d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105730:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0105737:	89 04 24             	mov    %eax,(%esp)
f010573a:	e8 fb dc ff ff       	call   f010343a <user_mem_check>
f010573f:	85 c0                	test   %eax,%eax
f0105741:	79 1f                	jns    f0105762 <debuginfo_eip+0x139>
f0105743:	e9 c2 01 00 00       	jmp    f010590a <debuginfo_eip+0x2e1>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105748:	c7 45 c0 50 ed 11 f0 	movl   $0xf011ed50,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010574f:	c7 45 bc 91 41 11 f0 	movl   $0xf0114191,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105756:	bf 90 41 11 f0       	mov    $0xf0114190,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010575b:	c7 45 c4 78 8d 10 f0 	movl   $0xf0108d78,-0x3c(%ebp)
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105762:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105765:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105768:	0f 83 a3 01 00 00    	jae    f0105911 <debuginfo_eip+0x2e8>
f010576e:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105772:	0f 85 a0 01 00 00    	jne    f0105918 <debuginfo_eip+0x2ef>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105778:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010577f:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105782:	c1 ff 02             	sar    $0x2,%edi
f0105785:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0105788:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010578b:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010578e:	89 c2                	mov    %eax,%edx
f0105790:	c1 e2 08             	shl    $0x8,%edx
f0105793:	01 d0                	add    %edx,%eax
f0105795:	89 c2                	mov    %eax,%edx
f0105797:	c1 e2 10             	shl    $0x10,%edx
f010579a:	01 d0                	add    %edx,%eax
f010579c:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f01057a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01057a3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057a7:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01057ae:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01057b1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01057b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01057b7:	e8 74 fd ff ff       	call   f0105530 <stab_binsearch>
	if (lfile == 0)
f01057bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057bf:	85 c0                	test   %eax,%eax
f01057c1:	0f 84 58 01 00 00    	je     f010591f <debuginfo_eip+0x2f6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01057c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01057ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01057d0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057d4:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01057db:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01057de:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01057e1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01057e4:	e8 47 fd ff ff       	call   f0105530 <stab_binsearch>

	if (lfun <= rfun) {
f01057e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01057ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01057ef:	39 d0                	cmp    %edx,%eax
f01057f1:	7f 32                	jg     f0105825 <debuginfo_eip+0x1fc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01057f3:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01057f6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01057f9:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01057fc:	8b 39                	mov    (%ecx),%edi
f01057fe:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105801:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105804:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0105807:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010580a:	73 09                	jae    f0105815 <debuginfo_eip+0x1ec>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010580c:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010580f:	03 7d bc             	add    -0x44(%ebp),%edi
f0105812:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105815:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105818:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010581b:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010581d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105820:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105823:	eb 0f                	jmp    f0105834 <debuginfo_eip+0x20b>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105825:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010582b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010582e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105831:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105834:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010583b:	00 
f010583c:	8b 43 08             	mov    0x8(%ebx),%eax
f010583f:	89 04 24             	mov    %eax,(%esp)
f0105842:	e8 8b 08 00 00       	call   f01060d2 <strfind>
f0105847:	2b 43 08             	sub    0x8(%ebx),%eax
f010584a:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
f010584d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105851:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105858:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010585b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010585e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105861:	e8 ca fc ff ff       	call   f0105530 <stab_binsearch>
	if (lline > rline )
f0105866:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105869:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010586c:	0f 8f b4 00 00 00    	jg     f0105926 <debuginfo_eip+0x2fd>
		return -1;	
	info->eip_line = stabs[rline].n_desc;
f0105872:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105875:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105878:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f010587d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105880:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105883:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105886:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105889:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f010588d:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105890:	eb 04                	jmp    f0105896 <debuginfo_eip+0x26d>
f0105892:	48                   	dec    %eax
f0105893:	83 ea 0c             	sub    $0xc,%edx
f0105896:	89 c7                	mov    %eax,%edi
f0105898:	39 c6                	cmp    %eax,%esi
f010589a:	7f 28                	jg     f01058c4 <debuginfo_eip+0x29b>
	       && stabs[lline].n_type != N_SOL
f010589c:	8a 4a fc             	mov    -0x4(%edx),%cl
f010589f:	80 f9 84             	cmp    $0x84,%cl
f01058a2:	0f 84 99 00 00 00    	je     f0105941 <debuginfo_eip+0x318>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01058a8:	80 f9 64             	cmp    $0x64,%cl
f01058ab:	75 e5                	jne    f0105892 <debuginfo_eip+0x269>
f01058ad:	83 3a 00             	cmpl   $0x0,(%edx)
f01058b0:	74 e0                	je     f0105892 <debuginfo_eip+0x269>
f01058b2:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01058b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01058b8:	e9 8a 00 00 00       	jmp    f0105947 <debuginfo_eip+0x31e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01058bd:	03 45 bc             	add    -0x44(%ebp),%eax
f01058c0:	89 03                	mov    %eax,(%ebx)
f01058c2:	eb 03                	jmp    f01058c7 <debuginfo_eip+0x29e>
f01058c4:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01058c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01058ca:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01058cd:	39 f2                	cmp    %esi,%edx
f01058cf:	7d 5c                	jge    f010592d <debuginfo_eip+0x304>
		for (lline = lfun + 1;
f01058d1:	42                   	inc    %edx
f01058d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01058d5:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01058d7:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01058da:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01058dd:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01058e1:	eb 03                	jmp    f01058e6 <debuginfo_eip+0x2bd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01058e3:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01058e6:	39 f0                	cmp    %esi,%eax
f01058e8:	7d 4a                	jge    f0105934 <debuginfo_eip+0x30b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01058ea:	8a 0a                	mov    (%edx),%cl
f01058ec:	40                   	inc    %eax
f01058ed:	83 c2 0c             	add    $0xc,%edx
f01058f0:	80 f9 a0             	cmp    $0xa0,%cl
f01058f3:	74 ee                	je     f01058e3 <debuginfo_eip+0x2ba>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01058f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01058fa:	eb 3d                	jmp    f0105939 <debuginfo_eip+0x310>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f01058fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105901:	eb 36                	jmp    f0105939 <debuginfo_eip+0x310>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
			return -1;
f0105903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105908:	eb 2f                	jmp    f0105939 <debuginfo_eip+0x310>
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
f010590a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010590f:	eb 28                	jmp    f0105939 <debuginfo_eip+0x310>
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105916:	eb 21                	jmp    f0105939 <debuginfo_eip+0x310>
f0105918:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010591d:	eb 1a                	jmp    f0105939 <debuginfo_eip+0x310>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010591f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105924:	eb 13                	jmp    f0105939 <debuginfo_eip+0x310>
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
	if (lline > rline )
		return -1;	
f0105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010592b:	eb 0c                	jmp    f0105939 <debuginfo_eip+0x310>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010592d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105932:	eb 05                	jmp    f0105939 <debuginfo_eip+0x310>
f0105934:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105939:	83 c4 5c             	add    $0x5c,%esp
f010593c:	5b                   	pop    %ebx
f010593d:	5e                   	pop    %esi
f010593e:	5f                   	pop    %edi
f010593f:	5d                   	pop    %ebp
f0105940:	c3                   	ret    
f0105941:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105944:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105947:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010594a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010594d:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105950:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105953:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105956:	39 d0                	cmp    %edx,%eax
f0105958:	0f 82 5f ff ff ff    	jb     f01058bd <debuginfo_eip+0x294>
f010595e:	e9 64 ff ff ff       	jmp    f01058c7 <debuginfo_eip+0x29e>
	...

f0105964 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105964:	55                   	push   %ebp
f0105965:	89 e5                	mov    %esp,%ebp
f0105967:	57                   	push   %edi
f0105968:	56                   	push   %esi
f0105969:	53                   	push   %ebx
f010596a:	83 ec 3c             	sub    $0x3c,%esp
f010596d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105970:	89 d7                	mov    %edx,%edi
f0105972:	8b 45 08             	mov    0x8(%ebp),%eax
f0105975:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105978:	8b 45 0c             	mov    0xc(%ebp),%eax
f010597b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010597e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105981:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105984:	85 c0                	test   %eax,%eax
f0105986:	75 08                	jne    f0105990 <printnum+0x2c>
f0105988:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010598b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010598e:	77 57                	ja     f01059e7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105990:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105994:	4b                   	dec    %ebx
f0105995:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105999:	8b 45 10             	mov    0x10(%ebp),%eax
f010599c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059a0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01059a4:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01059a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01059af:	00 
f01059b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059b3:	89 04 24             	mov    %eax,(%esp)
f01059b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059bd:	e8 c6 11 00 00       	call   f0106b88 <__udivdi3>
f01059c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01059c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01059ca:	89 04 24             	mov    %eax,(%esp)
f01059cd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01059d1:	89 fa                	mov    %edi,%edx
f01059d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059d6:	e8 89 ff ff ff       	call   f0105964 <printnum>
f01059db:	eb 0f                	jmp    f01059ec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01059dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059e1:	89 34 24             	mov    %esi,(%esp)
f01059e4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01059e7:	4b                   	dec    %ebx
f01059e8:	85 db                	test   %ebx,%ebx
f01059ea:	7f f1                	jg     f01059dd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01059ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01059f4:	8b 45 10             	mov    0x10(%ebp),%eax
f01059f7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01059fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105a02:	00 
f0105a03:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105a06:	89 04 24             	mov    %eax,(%esp)
f0105a09:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a10:	e8 93 12 00 00       	call   f0106ca8 <__umoddi3>
f0105a15:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a19:	0f be 80 a2 88 10 f0 	movsbl -0xfef775e(%eax),%eax
f0105a20:	89 04 24             	mov    %eax,(%esp)
f0105a23:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105a26:	83 c4 3c             	add    $0x3c,%esp
f0105a29:	5b                   	pop    %ebx
f0105a2a:	5e                   	pop    %esi
f0105a2b:	5f                   	pop    %edi
f0105a2c:	5d                   	pop    %ebp
f0105a2d:	c3                   	ret    

f0105a2e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105a2e:	55                   	push   %ebp
f0105a2f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105a31:	83 fa 01             	cmp    $0x1,%edx
f0105a34:	7e 0e                	jle    f0105a44 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105a36:	8b 10                	mov    (%eax),%edx
f0105a38:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105a3b:	89 08                	mov    %ecx,(%eax)
f0105a3d:	8b 02                	mov    (%edx),%eax
f0105a3f:	8b 52 04             	mov    0x4(%edx),%edx
f0105a42:	eb 22                	jmp    f0105a66 <getuint+0x38>
	else if (lflag)
f0105a44:	85 d2                	test   %edx,%edx
f0105a46:	74 10                	je     f0105a58 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105a48:	8b 10                	mov    (%eax),%edx
f0105a4a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a4d:	89 08                	mov    %ecx,(%eax)
f0105a4f:	8b 02                	mov    (%edx),%eax
f0105a51:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a56:	eb 0e                	jmp    f0105a66 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105a58:	8b 10                	mov    (%eax),%edx
f0105a5a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105a5d:	89 08                	mov    %ecx,(%eax)
f0105a5f:	8b 02                	mov    (%edx),%eax
f0105a61:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105a66:	5d                   	pop    %ebp
f0105a67:	c3                   	ret    

f0105a68 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105a68:	55                   	push   %ebp
f0105a69:	89 e5                	mov    %esp,%ebp
f0105a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105a6e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105a71:	8b 10                	mov    (%eax),%edx
f0105a73:	3b 50 04             	cmp    0x4(%eax),%edx
f0105a76:	73 08                	jae    f0105a80 <sprintputch+0x18>
		*b->buf++ = ch;
f0105a78:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a7b:	88 0a                	mov    %cl,(%edx)
f0105a7d:	42                   	inc    %edx
f0105a7e:	89 10                	mov    %edx,(%eax)
}
f0105a80:	5d                   	pop    %ebp
f0105a81:	c3                   	ret    

f0105a82 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105a82:	55                   	push   %ebp
f0105a83:	89 e5                	mov    %esp,%ebp
f0105a85:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105a88:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105a8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a8f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a92:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a96:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aa0:	89 04 24             	mov    %eax,(%esp)
f0105aa3:	e8 02 00 00 00       	call   f0105aaa <vprintfmt>
	va_end(ap);
}
f0105aa8:	c9                   	leave  
f0105aa9:	c3                   	ret    

f0105aaa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105aaa:	55                   	push   %ebp
f0105aab:	89 e5                	mov    %esp,%ebp
f0105aad:	57                   	push   %edi
f0105aae:	56                   	push   %esi
f0105aaf:	53                   	push   %ebx
f0105ab0:	83 ec 4c             	sub    $0x4c,%esp
f0105ab3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ab6:	8b 75 10             	mov    0x10(%ebp),%esi
f0105ab9:	eb 12                	jmp    f0105acd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105abb:	85 c0                	test   %eax,%eax
f0105abd:	0f 84 6b 03 00 00    	je     f0105e2e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105ac3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ac7:	89 04 24             	mov    %eax,(%esp)
f0105aca:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105acd:	0f b6 06             	movzbl (%esi),%eax
f0105ad0:	46                   	inc    %esi
f0105ad1:	83 f8 25             	cmp    $0x25,%eax
f0105ad4:	75 e5                	jne    f0105abb <vprintfmt+0x11>
f0105ad6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105ada:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105ae1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105ae6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105aed:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105af2:	eb 26                	jmp    f0105b1a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105af4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105af7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105afb:	eb 1d                	jmp    f0105b1a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105afd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105b00:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105b04:	eb 14                	jmp    f0105b1a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b06:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105b09:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105b10:	eb 08                	jmp    f0105b1a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105b12:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105b15:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b1a:	0f b6 06             	movzbl (%esi),%eax
f0105b1d:	8d 56 01             	lea    0x1(%esi),%edx
f0105b20:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105b23:	8a 16                	mov    (%esi),%dl
f0105b25:	83 ea 23             	sub    $0x23,%edx
f0105b28:	80 fa 55             	cmp    $0x55,%dl
f0105b2b:	0f 87 e1 02 00 00    	ja     f0105e12 <vprintfmt+0x368>
f0105b31:	0f b6 d2             	movzbl %dl,%edx
f0105b34:	ff 24 95 60 89 10 f0 	jmp    *-0xfef76a0(,%edx,4)
f0105b3b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105b3e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105b43:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105b46:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105b4a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105b4d:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105b50:	83 fa 09             	cmp    $0x9,%edx
f0105b53:	77 2a                	ja     f0105b7f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105b55:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105b56:	eb eb                	jmp    f0105b43 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105b58:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b5b:	8d 50 04             	lea    0x4(%eax),%edx
f0105b5e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b61:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b63:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105b66:	eb 17                	jmp    f0105b7f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105b68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105b6c:	78 98                	js     f0105b06 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b6e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105b71:	eb a7                	jmp    f0105b1a <vprintfmt+0x70>
f0105b73:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105b76:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105b7d:	eb 9b                	jmp    f0105b1a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105b7f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105b83:	79 95                	jns    f0105b1a <vprintfmt+0x70>
f0105b85:	eb 8b                	jmp    f0105b12 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105b87:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b88:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105b8b:	eb 8d                	jmp    f0105b1a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105b8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b90:	8d 50 04             	lea    0x4(%eax),%edx
f0105b93:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b9a:	8b 00                	mov    (%eax),%eax
f0105b9c:	89 04 24             	mov    %eax,(%esp)
f0105b9f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ba2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105ba5:	e9 23 ff ff ff       	jmp    f0105acd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105baa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bad:	8d 50 04             	lea    0x4(%eax),%edx
f0105bb0:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bb3:	8b 00                	mov    (%eax),%eax
f0105bb5:	85 c0                	test   %eax,%eax
f0105bb7:	79 02                	jns    f0105bbb <vprintfmt+0x111>
f0105bb9:	f7 d8                	neg    %eax
f0105bbb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105bbd:	83 f8 09             	cmp    $0x9,%eax
f0105bc0:	7f 0b                	jg     f0105bcd <vprintfmt+0x123>
f0105bc2:	8b 04 85 c0 8a 10 f0 	mov    -0xfef7540(,%eax,4),%eax
f0105bc9:	85 c0                	test   %eax,%eax
f0105bcb:	75 23                	jne    f0105bf0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105bcd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105bd1:	c7 44 24 08 ba 88 10 	movl   $0xf01088ba,0x8(%esp)
f0105bd8:	f0 
f0105bd9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105be0:	89 04 24             	mov    %eax,(%esp)
f0105be3:	e8 9a fe ff ff       	call   f0105a82 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105be8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105beb:	e9 dd fe ff ff       	jmp    f0105acd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105bf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105bf4:	c7 44 24 08 35 7d 10 	movl   $0xf0107d35,0x8(%esp)
f0105bfb:	f0 
f0105bfc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c00:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c03:	89 14 24             	mov    %edx,(%esp)
f0105c06:	e8 77 fe ff ff       	call   f0105a82 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105c0e:	e9 ba fe ff ff       	jmp    f0105acd <vprintfmt+0x23>
f0105c13:	89 f9                	mov    %edi,%ecx
f0105c15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c18:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105c1b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c1e:	8d 50 04             	lea    0x4(%eax),%edx
f0105c21:	89 55 14             	mov    %edx,0x14(%ebp)
f0105c24:	8b 30                	mov    (%eax),%esi
f0105c26:	85 f6                	test   %esi,%esi
f0105c28:	75 05                	jne    f0105c2f <vprintfmt+0x185>
				p = "(null)";
f0105c2a:	be b3 88 10 f0       	mov    $0xf01088b3,%esi
			if (width > 0 && padc != '-')
f0105c2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105c33:	0f 8e 84 00 00 00    	jle    f0105cbd <vprintfmt+0x213>
f0105c39:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105c3d:	74 7e                	je     f0105cbd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c3f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105c43:	89 34 24             	mov    %esi,(%esp)
f0105c46:	e8 53 03 00 00       	call   f0105f9e <strnlen>
f0105c4b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105c4e:	29 c2                	sub    %eax,%edx
f0105c50:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105c53:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105c57:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105c5a:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105c5d:	89 de                	mov    %ebx,%esi
f0105c5f:	89 d3                	mov    %edx,%ebx
f0105c61:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c63:	eb 0b                	jmp    f0105c70 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105c65:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c69:	89 3c 24             	mov    %edi,(%esp)
f0105c6c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c6f:	4b                   	dec    %ebx
f0105c70:	85 db                	test   %ebx,%ebx
f0105c72:	7f f1                	jg     f0105c65 <vprintfmt+0x1bb>
f0105c74:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105c77:	89 f3                	mov    %esi,%ebx
f0105c79:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105c7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c7f:	85 c0                	test   %eax,%eax
f0105c81:	79 05                	jns    f0105c88 <vprintfmt+0x1de>
f0105c83:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105c8b:	29 c2                	sub    %eax,%edx
f0105c8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105c90:	eb 2b                	jmp    f0105cbd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105c92:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c96:	74 18                	je     f0105cb0 <vprintfmt+0x206>
f0105c98:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105c9b:	83 fa 5e             	cmp    $0x5e,%edx
f0105c9e:	76 10                	jbe    f0105cb0 <vprintfmt+0x206>
					putch('?', putdat);
f0105ca0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ca4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105cab:	ff 55 08             	call   *0x8(%ebp)
f0105cae:	eb 0a                	jmp    f0105cba <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105cb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cb4:	89 04 24             	mov    %eax,(%esp)
f0105cb7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105cba:	ff 4d e4             	decl   -0x1c(%ebp)
f0105cbd:	0f be 06             	movsbl (%esi),%eax
f0105cc0:	46                   	inc    %esi
f0105cc1:	85 c0                	test   %eax,%eax
f0105cc3:	74 21                	je     f0105ce6 <vprintfmt+0x23c>
f0105cc5:	85 ff                	test   %edi,%edi
f0105cc7:	78 c9                	js     f0105c92 <vprintfmt+0x1e8>
f0105cc9:	4f                   	dec    %edi
f0105cca:	79 c6                	jns    f0105c92 <vprintfmt+0x1e8>
f0105ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ccf:	89 de                	mov    %ebx,%esi
f0105cd1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105cd4:	eb 18                	jmp    f0105cee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105cda:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105ce1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105ce3:	4b                   	dec    %ebx
f0105ce4:	eb 08                	jmp    f0105cee <vprintfmt+0x244>
f0105ce6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ce9:	89 de                	mov    %ebx,%esi
f0105ceb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105cee:	85 db                	test   %ebx,%ebx
f0105cf0:	7f e4                	jg     f0105cd6 <vprintfmt+0x22c>
f0105cf2:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105cf5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cf7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105cfa:	e9 ce fd ff ff       	jmp    f0105acd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105cff:	83 f9 01             	cmp    $0x1,%ecx
f0105d02:	7e 10                	jle    f0105d14 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0105d04:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d07:	8d 50 08             	lea    0x8(%eax),%edx
f0105d0a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d0d:	8b 30                	mov    (%eax),%esi
f0105d0f:	8b 78 04             	mov    0x4(%eax),%edi
f0105d12:	eb 26                	jmp    f0105d3a <vprintfmt+0x290>
	else if (lflag)
f0105d14:	85 c9                	test   %ecx,%ecx
f0105d16:	74 12                	je     f0105d2a <vprintfmt+0x280>
		return va_arg(*ap, long);
f0105d18:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d1b:	8d 50 04             	lea    0x4(%eax),%edx
f0105d1e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d21:	8b 30                	mov    (%eax),%esi
f0105d23:	89 f7                	mov    %esi,%edi
f0105d25:	c1 ff 1f             	sar    $0x1f,%edi
f0105d28:	eb 10                	jmp    f0105d3a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0105d2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d2d:	8d 50 04             	lea    0x4(%eax),%edx
f0105d30:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d33:	8b 30                	mov    (%eax),%esi
f0105d35:	89 f7                	mov    %esi,%edi
f0105d37:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105d3a:	85 ff                	test   %edi,%edi
f0105d3c:	78 0a                	js     f0105d48 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105d3e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d43:	e9 8c 00 00 00       	jmp    f0105dd4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105d48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d4c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105d53:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105d56:	f7 de                	neg    %esi
f0105d58:	83 d7 00             	adc    $0x0,%edi
f0105d5b:	f7 df                	neg    %edi
			}
			base = 10;
f0105d5d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d62:	eb 70                	jmp    f0105dd4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105d64:	89 ca                	mov    %ecx,%edx
f0105d66:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d69:	e8 c0 fc ff ff       	call   f0105a2e <getuint>
f0105d6e:	89 c6                	mov    %eax,%esi
f0105d70:	89 d7                	mov    %edx,%edi
			base = 10;
f0105d72:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105d77:	eb 5b                	jmp    f0105dd4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
f0105d79:	89 ca                	mov    %ecx,%edx
f0105d7b:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d7e:	e8 ab fc ff ff       	call   f0105a2e <getuint>
f0105d83:	89 c6                	mov    %eax,%esi
f0105d85:	89 d7                	mov    %edx,%edi
			base = 8;
f0105d87:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105d8c:	eb 46                	jmp    f0105dd4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105d8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d92:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105d99:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105d9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105da0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105da7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105daa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dad:	8d 50 04             	lea    0x4(%eax),%edx
f0105db0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105db3:	8b 30                	mov    (%eax),%esi
f0105db5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105dba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105dbf:	eb 13                	jmp    f0105dd4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105dc1:	89 ca                	mov    %ecx,%edx
f0105dc3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105dc6:	e8 63 fc ff ff       	call   f0105a2e <getuint>
f0105dcb:	89 c6                	mov    %eax,%esi
f0105dcd:	89 d7                	mov    %edx,%edi
			base = 16;
f0105dcf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105dd4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105dd8:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105ddc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105ddf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105de3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105de7:	89 34 24             	mov    %esi,(%esp)
f0105dea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dee:	89 da                	mov    %ebx,%edx
f0105df0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105df3:	e8 6c fb ff ff       	call   f0105964 <printnum>
			break;
f0105df8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105dfb:	e9 cd fc ff ff       	jmp    f0105acd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105e00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e04:	89 04 24             	mov    %eax,(%esp)
f0105e07:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e0a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105e0d:	e9 bb fc ff ff       	jmp    f0105acd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105e12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e16:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105e1d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105e20:	eb 01                	jmp    f0105e23 <vprintfmt+0x379>
f0105e22:	4e                   	dec    %esi
f0105e23:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105e27:	75 f9                	jne    f0105e22 <vprintfmt+0x378>
f0105e29:	e9 9f fc ff ff       	jmp    f0105acd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105e2e:	83 c4 4c             	add    $0x4c,%esp
f0105e31:	5b                   	pop    %ebx
f0105e32:	5e                   	pop    %esi
f0105e33:	5f                   	pop    %edi
f0105e34:	5d                   	pop    %ebp
f0105e35:	c3                   	ret    

f0105e36 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105e36:	55                   	push   %ebp
f0105e37:	89 e5                	mov    %esp,%ebp
f0105e39:	83 ec 28             	sub    $0x28,%esp
f0105e3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105e42:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105e45:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105e49:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105e4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105e53:	85 c0                	test   %eax,%eax
f0105e55:	74 30                	je     f0105e87 <vsnprintf+0x51>
f0105e57:	85 d2                	test   %edx,%edx
f0105e59:	7e 33                	jle    f0105e8e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105e5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e62:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e65:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e69:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e70:	c7 04 24 68 5a 10 f0 	movl   $0xf0105a68,(%esp)
f0105e77:	e8 2e fc ff ff       	call   f0105aaa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105e7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105e7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105e85:	eb 0c                	jmp    f0105e93 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105e87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105e8c:	eb 05                	jmp    f0105e93 <vsnprintf+0x5d>
f0105e8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105e93:	c9                   	leave  
f0105e94:	c3                   	ret    

f0105e95 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105e95:	55                   	push   %ebp
f0105e96:	89 e5                	mov    %esp,%ebp
f0105e98:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105e9b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105e9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ea2:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ea5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105eac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105eb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eb3:	89 04 24             	mov    %eax,(%esp)
f0105eb6:	e8 7b ff ff ff       	call   f0105e36 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105ebb:	c9                   	leave  
f0105ebc:	c3                   	ret    
f0105ebd:	00 00                	add    %al,(%eax)
	...

f0105ec0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105ec0:	55                   	push   %ebp
f0105ec1:	89 e5                	mov    %esp,%ebp
f0105ec3:	57                   	push   %edi
f0105ec4:	56                   	push   %esi
f0105ec5:	53                   	push   %ebx
f0105ec6:	83 ec 1c             	sub    $0x1c,%esp
f0105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105ecc:	85 c0                	test   %eax,%eax
f0105ece:	74 10                	je     f0105ee0 <readline+0x20>
		cprintf("%s", prompt);
f0105ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ed4:	c7 04 24 35 7d 10 f0 	movl   $0xf0107d35,(%esp)
f0105edb:	e8 a6 e0 ff ff       	call   f0103f86 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105ee0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105ee7:	e8 88 a8 ff ff       	call   f0100774 <iscons>
f0105eec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105eee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105ef3:	e8 6b a8 ff ff       	call   f0100763 <getchar>
f0105ef8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105efa:	85 c0                	test   %eax,%eax
f0105efc:	79 17                	jns    f0105f15 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105efe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f02:	c7 04 24 e8 8a 10 f0 	movl   $0xf0108ae8,(%esp)
f0105f09:	e8 78 e0 ff ff       	call   f0103f86 <cprintf>
			return NULL;
f0105f0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f13:	eb 69                	jmp    f0105f7e <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105f15:	83 f8 08             	cmp    $0x8,%eax
f0105f18:	74 05                	je     f0105f1f <readline+0x5f>
f0105f1a:	83 f8 7f             	cmp    $0x7f,%eax
f0105f1d:	75 17                	jne    f0105f36 <readline+0x76>
f0105f1f:	85 f6                	test   %esi,%esi
f0105f21:	7e 13                	jle    f0105f36 <readline+0x76>
			if (echoing)
f0105f23:	85 ff                	test   %edi,%edi
f0105f25:	74 0c                	je     f0105f33 <readline+0x73>
				cputchar('\b');
f0105f27:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105f2e:	e8 20 a8 ff ff       	call   f0100753 <cputchar>
			i--;
f0105f33:	4e                   	dec    %esi
f0105f34:	eb bd                	jmp    f0105ef3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105f36:	83 fb 1f             	cmp    $0x1f,%ebx
f0105f39:	7e 1d                	jle    f0105f58 <readline+0x98>
f0105f3b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105f41:	7f 15                	jg     f0105f58 <readline+0x98>
			if (echoing)
f0105f43:	85 ff                	test   %edi,%edi
f0105f45:	74 08                	je     f0105f4f <readline+0x8f>
				cputchar(c);
f0105f47:	89 1c 24             	mov    %ebx,(%esp)
f0105f4a:	e8 04 a8 ff ff       	call   f0100753 <cputchar>
			buf[i++] = c;
f0105f4f:	88 9e 80 1a 33 f0    	mov    %bl,-0xfcce580(%esi)
f0105f55:	46                   	inc    %esi
f0105f56:	eb 9b                	jmp    f0105ef3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105f58:	83 fb 0a             	cmp    $0xa,%ebx
f0105f5b:	74 05                	je     f0105f62 <readline+0xa2>
f0105f5d:	83 fb 0d             	cmp    $0xd,%ebx
f0105f60:	75 91                	jne    f0105ef3 <readline+0x33>
			if (echoing)
f0105f62:	85 ff                	test   %edi,%edi
f0105f64:	74 0c                	je     f0105f72 <readline+0xb2>
				cputchar('\n');
f0105f66:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105f6d:	e8 e1 a7 ff ff       	call   f0100753 <cputchar>
			buf[i] = 0;
f0105f72:	c6 86 80 1a 33 f0 00 	movb   $0x0,-0xfcce580(%esi)
			return buf;
f0105f79:	b8 80 1a 33 f0       	mov    $0xf0331a80,%eax
		}
	}
}
f0105f7e:	83 c4 1c             	add    $0x1c,%esp
f0105f81:	5b                   	pop    %ebx
f0105f82:	5e                   	pop    %esi
f0105f83:	5f                   	pop    %edi
f0105f84:	5d                   	pop    %ebp
f0105f85:	c3                   	ret    
	...

f0105f88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105f88:	55                   	push   %ebp
f0105f89:	89 e5                	mov    %esp,%ebp
f0105f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105f8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f93:	eb 01                	jmp    f0105f96 <strlen+0xe>
		n++;
f0105f95:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105f96:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105f9a:	75 f9                	jne    f0105f95 <strlen+0xd>
		n++;
	return n;
}
f0105f9c:	5d                   	pop    %ebp
f0105f9d:	c3                   	ret    

f0105f9e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105f9e:	55                   	push   %ebp
f0105f9f:	89 e5                	mov    %esp,%ebp
f0105fa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105fa4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105fa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fac:	eb 01                	jmp    f0105faf <strnlen+0x11>
		n++;
f0105fae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105faf:	39 d0                	cmp    %edx,%eax
f0105fb1:	74 06                	je     f0105fb9 <strnlen+0x1b>
f0105fb3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105fb7:	75 f5                	jne    f0105fae <strnlen+0x10>
		n++;
	return n;
}
f0105fb9:	5d                   	pop    %ebp
f0105fba:	c3                   	ret    

f0105fbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105fbb:	55                   	push   %ebp
f0105fbc:	89 e5                	mov    %esp,%ebp
f0105fbe:	53                   	push   %ebx
f0105fbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105fc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105fcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105fd0:	42                   	inc    %edx
f0105fd1:	84 c9                	test   %cl,%cl
f0105fd3:	75 f5                	jne    f0105fca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105fd5:	5b                   	pop    %ebx
f0105fd6:	5d                   	pop    %ebp
f0105fd7:	c3                   	ret    

f0105fd8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105fd8:	55                   	push   %ebp
f0105fd9:	89 e5                	mov    %esp,%ebp
f0105fdb:	53                   	push   %ebx
f0105fdc:	83 ec 08             	sub    $0x8,%esp
f0105fdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105fe2:	89 1c 24             	mov    %ebx,(%esp)
f0105fe5:	e8 9e ff ff ff       	call   f0105f88 <strlen>
	strcpy(dst + len, src);
f0105fea:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fed:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ff1:	01 d8                	add    %ebx,%eax
f0105ff3:	89 04 24             	mov    %eax,(%esp)
f0105ff6:	e8 c0 ff ff ff       	call   f0105fbb <strcpy>
	return dst;
}
f0105ffb:	89 d8                	mov    %ebx,%eax
f0105ffd:	83 c4 08             	add    $0x8,%esp
f0106000:	5b                   	pop    %ebx
f0106001:	5d                   	pop    %ebp
f0106002:	c3                   	ret    

f0106003 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106003:	55                   	push   %ebp
f0106004:	89 e5                	mov    %esp,%ebp
f0106006:	56                   	push   %esi
f0106007:	53                   	push   %ebx
f0106008:	8b 45 08             	mov    0x8(%ebp),%eax
f010600b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010600e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106011:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106016:	eb 0c                	jmp    f0106024 <strncpy+0x21>
		*dst++ = *src;
f0106018:	8a 1a                	mov    (%edx),%bl
f010601a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010601d:	80 3a 01             	cmpb   $0x1,(%edx)
f0106020:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106023:	41                   	inc    %ecx
f0106024:	39 f1                	cmp    %esi,%ecx
f0106026:	75 f0                	jne    f0106018 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106028:	5b                   	pop    %ebx
f0106029:	5e                   	pop    %esi
f010602a:	5d                   	pop    %ebp
f010602b:	c3                   	ret    

f010602c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010602c:	55                   	push   %ebp
f010602d:	89 e5                	mov    %esp,%ebp
f010602f:	56                   	push   %esi
f0106030:	53                   	push   %ebx
f0106031:	8b 75 08             	mov    0x8(%ebp),%esi
f0106034:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106037:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010603a:	85 d2                	test   %edx,%edx
f010603c:	75 0a                	jne    f0106048 <strlcpy+0x1c>
f010603e:	89 f0                	mov    %esi,%eax
f0106040:	eb 1a                	jmp    f010605c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0106042:	88 18                	mov    %bl,(%eax)
f0106044:	40                   	inc    %eax
f0106045:	41                   	inc    %ecx
f0106046:	eb 02                	jmp    f010604a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106048:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010604a:	4a                   	dec    %edx
f010604b:	74 0a                	je     f0106057 <strlcpy+0x2b>
f010604d:	8a 19                	mov    (%ecx),%bl
f010604f:	84 db                	test   %bl,%bl
f0106051:	75 ef                	jne    f0106042 <strlcpy+0x16>
f0106053:	89 c2                	mov    %eax,%edx
f0106055:	eb 02                	jmp    f0106059 <strlcpy+0x2d>
f0106057:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0106059:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f010605c:	29 f0                	sub    %esi,%eax
}
f010605e:	5b                   	pop    %ebx
f010605f:	5e                   	pop    %esi
f0106060:	5d                   	pop    %ebp
f0106061:	c3                   	ret    

f0106062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106062:	55                   	push   %ebp
f0106063:	89 e5                	mov    %esp,%ebp
f0106065:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106068:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010606b:	eb 02                	jmp    f010606f <strcmp+0xd>
		p++, q++;
f010606d:	41                   	inc    %ecx
f010606e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010606f:	8a 01                	mov    (%ecx),%al
f0106071:	84 c0                	test   %al,%al
f0106073:	74 04                	je     f0106079 <strcmp+0x17>
f0106075:	3a 02                	cmp    (%edx),%al
f0106077:	74 f4                	je     f010606d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106079:	0f b6 c0             	movzbl %al,%eax
f010607c:	0f b6 12             	movzbl (%edx),%edx
f010607f:	29 d0                	sub    %edx,%eax
}
f0106081:	5d                   	pop    %ebp
f0106082:	c3                   	ret    

f0106083 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106083:	55                   	push   %ebp
f0106084:	89 e5                	mov    %esp,%ebp
f0106086:	53                   	push   %ebx
f0106087:	8b 45 08             	mov    0x8(%ebp),%eax
f010608a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010608d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0106090:	eb 03                	jmp    f0106095 <strncmp+0x12>
		n--, p++, q++;
f0106092:	4a                   	dec    %edx
f0106093:	40                   	inc    %eax
f0106094:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106095:	85 d2                	test   %edx,%edx
f0106097:	74 14                	je     f01060ad <strncmp+0x2a>
f0106099:	8a 18                	mov    (%eax),%bl
f010609b:	84 db                	test   %bl,%bl
f010609d:	74 04                	je     f01060a3 <strncmp+0x20>
f010609f:	3a 19                	cmp    (%ecx),%bl
f01060a1:	74 ef                	je     f0106092 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01060a3:	0f b6 00             	movzbl (%eax),%eax
f01060a6:	0f b6 11             	movzbl (%ecx),%edx
f01060a9:	29 d0                	sub    %edx,%eax
f01060ab:	eb 05                	jmp    f01060b2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01060ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01060b2:	5b                   	pop    %ebx
f01060b3:	5d                   	pop    %ebp
f01060b4:	c3                   	ret    

f01060b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01060b5:	55                   	push   %ebp
f01060b6:	89 e5                	mov    %esp,%ebp
f01060b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01060bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01060be:	eb 05                	jmp    f01060c5 <strchr+0x10>
		if (*s == c)
f01060c0:	38 ca                	cmp    %cl,%dl
f01060c2:	74 0c                	je     f01060d0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01060c4:	40                   	inc    %eax
f01060c5:	8a 10                	mov    (%eax),%dl
f01060c7:	84 d2                	test   %dl,%dl
f01060c9:	75 f5                	jne    f01060c0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01060cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01060d0:	5d                   	pop    %ebp
f01060d1:	c3                   	ret    

f01060d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01060d2:	55                   	push   %ebp
f01060d3:	89 e5                	mov    %esp,%ebp
f01060d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01060d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01060db:	eb 05                	jmp    f01060e2 <strfind+0x10>
		if (*s == c)
f01060dd:	38 ca                	cmp    %cl,%dl
f01060df:	74 07                	je     f01060e8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01060e1:	40                   	inc    %eax
f01060e2:	8a 10                	mov    (%eax),%dl
f01060e4:	84 d2                	test   %dl,%dl
f01060e6:	75 f5                	jne    f01060dd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01060e8:	5d                   	pop    %ebp
f01060e9:	c3                   	ret    

f01060ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01060ea:	55                   	push   %ebp
f01060eb:	89 e5                	mov    %esp,%ebp
f01060ed:	57                   	push   %edi
f01060ee:	56                   	push   %esi
f01060ef:	53                   	push   %ebx
f01060f0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01060f9:	85 c9                	test   %ecx,%ecx
f01060fb:	74 30                	je     f010612d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01060fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106103:	75 25                	jne    f010612a <memset+0x40>
f0106105:	f6 c1 03             	test   $0x3,%cl
f0106108:	75 20                	jne    f010612a <memset+0x40>
		c &= 0xFF;
f010610a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010610d:	89 d3                	mov    %edx,%ebx
f010610f:	c1 e3 08             	shl    $0x8,%ebx
f0106112:	89 d6                	mov    %edx,%esi
f0106114:	c1 e6 18             	shl    $0x18,%esi
f0106117:	89 d0                	mov    %edx,%eax
f0106119:	c1 e0 10             	shl    $0x10,%eax
f010611c:	09 f0                	or     %esi,%eax
f010611e:	09 d0                	or     %edx,%eax
f0106120:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0106122:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0106125:	fc                   	cld    
f0106126:	f3 ab                	rep stos %eax,%es:(%edi)
f0106128:	eb 03                	jmp    f010612d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010612a:	fc                   	cld    
f010612b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010612d:	89 f8                	mov    %edi,%eax
f010612f:	5b                   	pop    %ebx
f0106130:	5e                   	pop    %esi
f0106131:	5f                   	pop    %edi
f0106132:	5d                   	pop    %ebp
f0106133:	c3                   	ret    

f0106134 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106134:	55                   	push   %ebp
f0106135:	89 e5                	mov    %esp,%ebp
f0106137:	57                   	push   %edi
f0106138:	56                   	push   %esi
f0106139:	8b 45 08             	mov    0x8(%ebp),%eax
f010613c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010613f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106142:	39 c6                	cmp    %eax,%esi
f0106144:	73 34                	jae    f010617a <memmove+0x46>
f0106146:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106149:	39 d0                	cmp    %edx,%eax
f010614b:	73 2d                	jae    f010617a <memmove+0x46>
		s += n;
		d += n;
f010614d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106150:	f6 c2 03             	test   $0x3,%dl
f0106153:	75 1b                	jne    f0106170 <memmove+0x3c>
f0106155:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010615b:	75 13                	jne    f0106170 <memmove+0x3c>
f010615d:	f6 c1 03             	test   $0x3,%cl
f0106160:	75 0e                	jne    f0106170 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106162:	83 ef 04             	sub    $0x4,%edi
f0106165:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106168:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010616b:	fd                   	std    
f010616c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010616e:	eb 07                	jmp    f0106177 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106170:	4f                   	dec    %edi
f0106171:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106174:	fd                   	std    
f0106175:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106177:	fc                   	cld    
f0106178:	eb 20                	jmp    f010619a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010617a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106180:	75 13                	jne    f0106195 <memmove+0x61>
f0106182:	a8 03                	test   $0x3,%al
f0106184:	75 0f                	jne    f0106195 <memmove+0x61>
f0106186:	f6 c1 03             	test   $0x3,%cl
f0106189:	75 0a                	jne    f0106195 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010618b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010618e:	89 c7                	mov    %eax,%edi
f0106190:	fc                   	cld    
f0106191:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106193:	eb 05                	jmp    f010619a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106195:	89 c7                	mov    %eax,%edi
f0106197:	fc                   	cld    
f0106198:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010619a:	5e                   	pop    %esi
f010619b:	5f                   	pop    %edi
f010619c:	5d                   	pop    %ebp
f010619d:	c3                   	ret    

f010619e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010619e:	55                   	push   %ebp
f010619f:	89 e5                	mov    %esp,%ebp
f01061a1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01061a4:	8b 45 10             	mov    0x10(%ebp),%eax
f01061a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01061ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01061ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01061b5:	89 04 24             	mov    %eax,(%esp)
f01061b8:	e8 77 ff ff ff       	call   f0106134 <memmove>
}
f01061bd:	c9                   	leave  
f01061be:	c3                   	ret    

f01061bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01061bf:	55                   	push   %ebp
f01061c0:	89 e5                	mov    %esp,%ebp
f01061c2:	57                   	push   %edi
f01061c3:	56                   	push   %esi
f01061c4:	53                   	push   %ebx
f01061c5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01061c8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01061cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01061ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01061d3:	eb 16                	jmp    f01061eb <memcmp+0x2c>
		if (*s1 != *s2)
f01061d5:	8a 04 17             	mov    (%edi,%edx,1),%al
f01061d8:	42                   	inc    %edx
f01061d9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01061dd:	38 c8                	cmp    %cl,%al
f01061df:	74 0a                	je     f01061eb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01061e1:	0f b6 c0             	movzbl %al,%eax
f01061e4:	0f b6 c9             	movzbl %cl,%ecx
f01061e7:	29 c8                	sub    %ecx,%eax
f01061e9:	eb 09                	jmp    f01061f4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01061eb:	39 da                	cmp    %ebx,%edx
f01061ed:	75 e6                	jne    f01061d5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01061ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01061f4:	5b                   	pop    %ebx
f01061f5:	5e                   	pop    %esi
f01061f6:	5f                   	pop    %edi
f01061f7:	5d                   	pop    %ebp
f01061f8:	c3                   	ret    

f01061f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01061f9:	55                   	push   %ebp
f01061fa:	89 e5                	mov    %esp,%ebp
f01061fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01061ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106202:	89 c2                	mov    %eax,%edx
f0106204:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106207:	eb 05                	jmp    f010620e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106209:	38 08                	cmp    %cl,(%eax)
f010620b:	74 05                	je     f0106212 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010620d:	40                   	inc    %eax
f010620e:	39 d0                	cmp    %edx,%eax
f0106210:	72 f7                	jb     f0106209 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106212:	5d                   	pop    %ebp
f0106213:	c3                   	ret    

f0106214 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106214:	55                   	push   %ebp
f0106215:	89 e5                	mov    %esp,%ebp
f0106217:	57                   	push   %edi
f0106218:	56                   	push   %esi
f0106219:	53                   	push   %ebx
f010621a:	8b 55 08             	mov    0x8(%ebp),%edx
f010621d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106220:	eb 01                	jmp    f0106223 <strtol+0xf>
		s++;
f0106222:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106223:	8a 02                	mov    (%edx),%al
f0106225:	3c 20                	cmp    $0x20,%al
f0106227:	74 f9                	je     f0106222 <strtol+0xe>
f0106229:	3c 09                	cmp    $0x9,%al
f010622b:	74 f5                	je     f0106222 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010622d:	3c 2b                	cmp    $0x2b,%al
f010622f:	75 08                	jne    f0106239 <strtol+0x25>
		s++;
f0106231:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106232:	bf 00 00 00 00       	mov    $0x0,%edi
f0106237:	eb 13                	jmp    f010624c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106239:	3c 2d                	cmp    $0x2d,%al
f010623b:	75 0a                	jne    f0106247 <strtol+0x33>
		s++, neg = 1;
f010623d:	8d 52 01             	lea    0x1(%edx),%edx
f0106240:	bf 01 00 00 00       	mov    $0x1,%edi
f0106245:	eb 05                	jmp    f010624c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106247:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010624c:	85 db                	test   %ebx,%ebx
f010624e:	74 05                	je     f0106255 <strtol+0x41>
f0106250:	83 fb 10             	cmp    $0x10,%ebx
f0106253:	75 28                	jne    f010627d <strtol+0x69>
f0106255:	8a 02                	mov    (%edx),%al
f0106257:	3c 30                	cmp    $0x30,%al
f0106259:	75 10                	jne    f010626b <strtol+0x57>
f010625b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010625f:	75 0a                	jne    f010626b <strtol+0x57>
		s += 2, base = 16;
f0106261:	83 c2 02             	add    $0x2,%edx
f0106264:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106269:	eb 12                	jmp    f010627d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010626b:	85 db                	test   %ebx,%ebx
f010626d:	75 0e                	jne    f010627d <strtol+0x69>
f010626f:	3c 30                	cmp    $0x30,%al
f0106271:	75 05                	jne    f0106278 <strtol+0x64>
		s++, base = 8;
f0106273:	42                   	inc    %edx
f0106274:	b3 08                	mov    $0x8,%bl
f0106276:	eb 05                	jmp    f010627d <strtol+0x69>
	else if (base == 0)
		base = 10;
f0106278:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010627d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106282:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106284:	8a 0a                	mov    (%edx),%cl
f0106286:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106289:	80 fb 09             	cmp    $0x9,%bl
f010628c:	77 08                	ja     f0106296 <strtol+0x82>
			dig = *s - '0';
f010628e:	0f be c9             	movsbl %cl,%ecx
f0106291:	83 e9 30             	sub    $0x30,%ecx
f0106294:	eb 1e                	jmp    f01062b4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0106296:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0106299:	80 fb 19             	cmp    $0x19,%bl
f010629c:	77 08                	ja     f01062a6 <strtol+0x92>
			dig = *s - 'a' + 10;
f010629e:	0f be c9             	movsbl %cl,%ecx
f01062a1:	83 e9 57             	sub    $0x57,%ecx
f01062a4:	eb 0e                	jmp    f01062b4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01062a6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01062a9:	80 fb 19             	cmp    $0x19,%bl
f01062ac:	77 12                	ja     f01062c0 <strtol+0xac>
			dig = *s - 'A' + 10;
f01062ae:	0f be c9             	movsbl %cl,%ecx
f01062b1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01062b4:	39 f1                	cmp    %esi,%ecx
f01062b6:	7d 0c                	jge    f01062c4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01062b8:	42                   	inc    %edx
f01062b9:	0f af c6             	imul   %esi,%eax
f01062bc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01062be:	eb c4                	jmp    f0106284 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01062c0:	89 c1                	mov    %eax,%ecx
f01062c2:	eb 02                	jmp    f01062c6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01062c4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01062c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01062ca:	74 05                	je     f01062d1 <strtol+0xbd>
		*endptr = (char *) s;
f01062cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01062cf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01062d1:	85 ff                	test   %edi,%edi
f01062d3:	74 04                	je     f01062d9 <strtol+0xc5>
f01062d5:	89 c8                	mov    %ecx,%eax
f01062d7:	f7 d8                	neg    %eax
}
f01062d9:	5b                   	pop    %ebx
f01062da:	5e                   	pop    %esi
f01062db:	5f                   	pop    %edi
f01062dc:	5d                   	pop    %ebp
f01062dd:	c3                   	ret    
	...

f01062e0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01062e0:	fa                   	cli    

	xorw    %ax, %ax
f01062e1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01062e3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01062e5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01062e7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01062e9:	0f 01 16             	lgdtl  (%esi)
f01062ec:	74 70                	je     f010635e <sum+0x2>
	movl    %cr0, %eax
f01062ee:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01062f1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01062f5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01062f8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01062fe:	08 00                	or     %al,(%eax)

f0106300 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106300:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106304:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106306:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106308:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010630a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010630e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106310:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106312:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0106317:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010631a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010631d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106322:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106325:	8b 25 84 1e 33 f0    	mov    0xf0331e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010632b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106330:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106335:	ff d0                	call   *%eax

f0106337 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106337:	eb fe                	jmp    f0106337 <spin>
f0106339:	8d 76 00             	lea    0x0(%esi),%esi

f010633c <gdt>:
	...
f0106344:	ff                   	(bad)  
f0106345:	ff 00                	incl   (%eax)
f0106347:	00 00                	add    %al,(%eax)
f0106349:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106350:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106354 <gdtdesc>:
f0106354:	17                   	pop    %ss
f0106355:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010635a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010635a:	90                   	nop
	...

f010635c <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f010635c:	55                   	push   %ebp
f010635d:	89 e5                	mov    %esp,%ebp
f010635f:	56                   	push   %esi
f0106360:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106361:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0106366:	b9 00 00 00 00       	mov    $0x0,%ecx
f010636b:	eb 07                	jmp    f0106374 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f010636d:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106371:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106373:	41                   	inc    %ecx
f0106374:	39 d1                	cmp    %edx,%ecx
f0106376:	7c f5                	jl     f010636d <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106378:	88 d8                	mov    %bl,%al
f010637a:	5b                   	pop    %ebx
f010637b:	5e                   	pop    %esi
f010637c:	5d                   	pop    %ebp
f010637d:	c3                   	ret    

f010637e <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010637e:	55                   	push   %ebp
f010637f:	89 e5                	mov    %esp,%ebp
f0106381:	56                   	push   %esi
f0106382:	53                   	push   %ebx
f0106383:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106386:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f010638c:	89 c3                	mov    %eax,%ebx
f010638e:	c1 eb 0c             	shr    $0xc,%ebx
f0106391:	39 cb                	cmp    %ecx,%ebx
f0106393:	72 20                	jb     f01063b5 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106395:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106399:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f01063a0:	f0 
f01063a1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063a8:	00 
f01063a9:	c7 04 24 85 8c 10 f0 	movl   $0xf0108c85,(%esp)
f01063b0:	e8 8b 9c ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01063b5:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063b8:	89 f2                	mov    %esi,%edx
f01063ba:	c1 ea 0c             	shr    $0xc,%edx
f01063bd:	39 d1                	cmp    %edx,%ecx
f01063bf:	77 20                	ja     f01063e1 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01063c5:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f01063cc:	f0 
f01063cd:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01063d4:	00 
f01063d5:	c7 04 24 85 8c 10 f0 	movl   $0xf0108c85,(%esp)
f01063dc:	e8 5f 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01063e1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01063e7:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01063ed:	eb 2f                	jmp    f010641e <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063ef:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01063f6:	00 
f01063f7:	c7 44 24 04 95 8c 10 	movl   $0xf0108c95,0x4(%esp)
f01063fe:	f0 
f01063ff:	89 1c 24             	mov    %ebx,(%esp)
f0106402:	e8 b8 fd ff ff       	call   f01061bf <memcmp>
f0106407:	85 c0                	test   %eax,%eax
f0106409:	75 10                	jne    f010641b <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f010640b:	ba 10 00 00 00       	mov    $0x10,%edx
f0106410:	89 d8                	mov    %ebx,%eax
f0106412:	e8 45 ff ff ff       	call   f010635c <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106417:	84 c0                	test   %al,%al
f0106419:	74 0c                	je     f0106427 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010641b:	83 c3 10             	add    $0x10,%ebx
f010641e:	39 f3                	cmp    %esi,%ebx
f0106420:	72 cd                	jb     f01063ef <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106422:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106427:	89 d8                	mov    %ebx,%eax
f0106429:	83 c4 10             	add    $0x10,%esp
f010642c:	5b                   	pop    %ebx
f010642d:	5e                   	pop    %esi
f010642e:	5d                   	pop    %ebp
f010642f:	c3                   	ret    

f0106430 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106430:	55                   	push   %ebp
f0106431:	89 e5                	mov    %esp,%ebp
f0106433:	57                   	push   %edi
f0106434:	56                   	push   %esi
f0106435:	53                   	push   %ebx
f0106436:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106439:	c7 05 c0 23 33 f0 20 	movl   $0xf0332020,0xf03323c0
f0106440:	20 33 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106443:	83 3d 88 1e 33 f0 00 	cmpl   $0x0,0xf0331e88
f010644a:	75 24                	jne    f0106470 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010644c:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106453:	00 
f0106454:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f010645b:	f0 
f010645c:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106463:	00 
f0106464:	c7 04 24 85 8c 10 f0 	movl   $0xf0108c85,(%esp)
f010646b:	e8 d0 9b ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106470:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106477:	85 c0                	test   %eax,%eax
f0106479:	74 16                	je     f0106491 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010647b:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010647e:	ba 00 04 00 00       	mov    $0x400,%edx
f0106483:	e8 f6 fe ff ff       	call   f010637e <mpsearch1>
f0106488:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010648b:	85 c0                	test   %eax,%eax
f010648d:	75 3c                	jne    f01064cb <mp_init+0x9b>
f010648f:	eb 20                	jmp    f01064b1 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106491:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106498:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010649b:	2d 00 04 00 00       	sub    $0x400,%eax
f01064a0:	ba 00 04 00 00       	mov    $0x400,%edx
f01064a5:	e8 d4 fe ff ff       	call   f010637e <mpsearch1>
f01064aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01064ad:	85 c0                	test   %eax,%eax
f01064af:	75 1a                	jne    f01064cb <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01064b1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064b6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01064bb:	e8 be fe ff ff       	call   f010637e <mpsearch1>
f01064c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01064c3:	85 c0                	test   %eax,%eax
f01064c5:	0f 84 2c 02 00 00    	je     f01066f7 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01064cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01064ce:	8b 58 04             	mov    0x4(%eax),%ebx
f01064d1:	85 db                	test   %ebx,%ebx
f01064d3:	74 06                	je     f01064db <mp_init+0xab>
f01064d5:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01064d9:	74 11                	je     f01064ec <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01064db:	c7 04 24 f8 8a 10 f0 	movl   $0xf0108af8,(%esp)
f01064e2:	e8 9f da ff ff       	call   f0103f86 <cprintf>
f01064e7:	e9 0b 02 00 00       	jmp    f01066f7 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01064ec:	89 d8                	mov    %ebx,%eax
f01064ee:	c1 e8 0c             	shr    $0xc,%eax
f01064f1:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f01064f7:	72 20                	jb     f0106519 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01064fd:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f0106504:	f0 
f0106505:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010650c:	00 
f010650d:	c7 04 24 85 8c 10 f0 	movl   $0xf0108c85,(%esp)
f0106514:	e8 27 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106519:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010651f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106526:	00 
f0106527:	c7 44 24 04 9a 8c 10 	movl   $0xf0108c9a,0x4(%esp)
f010652e:	f0 
f010652f:	89 1c 24             	mov    %ebx,(%esp)
f0106532:	e8 88 fc ff ff       	call   f01061bf <memcmp>
f0106537:	85 c0                	test   %eax,%eax
f0106539:	74 11                	je     f010654c <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010653b:	c7 04 24 28 8b 10 f0 	movl   $0xf0108b28,(%esp)
f0106542:	e8 3f da ff ff       	call   f0103f86 <cprintf>
f0106547:	e9 ab 01 00 00       	jmp    f01066f7 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010654c:	66 8b 73 04          	mov    0x4(%ebx),%si
f0106550:	0f b7 d6             	movzwl %si,%edx
f0106553:	89 d8                	mov    %ebx,%eax
f0106555:	e8 02 fe ff ff       	call   f010635c <sum>
f010655a:	84 c0                	test   %al,%al
f010655c:	74 11                	je     f010656f <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010655e:	c7 04 24 5c 8b 10 f0 	movl   $0xf0108b5c,(%esp)
f0106565:	e8 1c da ff ff       	call   f0103f86 <cprintf>
f010656a:	e9 88 01 00 00       	jmp    f01066f7 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010656f:	8a 43 06             	mov    0x6(%ebx),%al
f0106572:	3c 01                	cmp    $0x1,%al
f0106574:	74 1c                	je     f0106592 <mp_init+0x162>
f0106576:	3c 04                	cmp    $0x4,%al
f0106578:	74 18                	je     f0106592 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010657a:	0f b6 c0             	movzbl %al,%eax
f010657d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106581:	c7 04 24 80 8b 10 f0 	movl   $0xf0108b80,(%esp)
f0106588:	e8 f9 d9 ff ff       	call   f0103f86 <cprintf>
f010658d:	e9 65 01 00 00       	jmp    f01066f7 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106592:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0106596:	0f b7 c6             	movzwl %si,%eax
f0106599:	01 d8                	add    %ebx,%eax
f010659b:	e8 bc fd ff ff       	call   f010635c <sum>
f01065a0:	02 43 2a             	add    0x2a(%ebx),%al
f01065a3:	84 c0                	test   %al,%al
f01065a5:	74 11                	je     f01065b8 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01065a7:	c7 04 24 a0 8b 10 f0 	movl   $0xf0108ba0,(%esp)
f01065ae:	e8 d3 d9 ff ff       	call   f0103f86 <cprintf>
f01065b3:	e9 3f 01 00 00       	jmp    f01066f7 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01065b8:	85 db                	test   %ebx,%ebx
f01065ba:	0f 84 37 01 00 00    	je     f01066f7 <mp_init+0x2c7>
		return;
	ismp = 1;
f01065c0:	c7 05 00 20 33 f0 01 	movl   $0x1,0xf0332000
f01065c7:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01065ca:	8b 43 24             	mov    0x24(%ebx),%eax
f01065cd:	a3 00 30 37 f0       	mov    %eax,0xf0373000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01065d2:	8d 73 2c             	lea    0x2c(%ebx),%esi
f01065d5:	bf 00 00 00 00       	mov    $0x0,%edi
f01065da:	e9 94 00 00 00       	jmp    f0106673 <mp_init+0x243>
		switch (*p) {
f01065df:	8a 06                	mov    (%esi),%al
f01065e1:	84 c0                	test   %al,%al
f01065e3:	74 06                	je     f01065eb <mp_init+0x1bb>
f01065e5:	3c 04                	cmp    $0x4,%al
f01065e7:	77 68                	ja     f0106651 <mp_init+0x221>
f01065e9:	eb 61                	jmp    f010664c <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01065eb:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01065ef:	74 1d                	je     f010660e <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f01065f1:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f01065f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065fd:	29 c2                	sub    %eax,%edx
f01065ff:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106602:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0106609:	a3 c0 23 33 f0       	mov    %eax,0xf03323c0
			if (ncpu < NCPU) {
f010660e:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f0106613:	83 f8 07             	cmp    $0x7,%eax
f0106616:	7f 1b                	jg     f0106633 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0106618:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010661f:	29 c2                	sub    %eax,%edx
f0106621:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106624:	88 04 95 20 20 33 f0 	mov    %al,-0xfccdfe0(,%edx,4)
				ncpu++;
f010662b:	40                   	inc    %eax
f010662c:	a3 c4 23 33 f0       	mov    %eax,0xf03323c4
f0106631:	eb 14                	jmp    f0106647 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106633:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106637:	89 44 24 04          	mov    %eax,0x4(%esp)
f010663b:	c7 04 24 d0 8b 10 f0 	movl   $0xf0108bd0,(%esp)
f0106642:	e8 3f d9 ff ff       	call   f0103f86 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106647:	83 c6 14             	add    $0x14,%esi
			continue;
f010664a:	eb 26                	jmp    f0106672 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010664c:	83 c6 08             	add    $0x8,%esi
			continue;
f010664f:	eb 21                	jmp    f0106672 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106651:	0f b6 c0             	movzbl %al,%eax
f0106654:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106658:	c7 04 24 f8 8b 10 f0 	movl   $0xf0108bf8,(%esp)
f010665f:	e8 22 d9 ff ff       	call   f0103f86 <cprintf>
			ismp = 0;
f0106664:	c7 05 00 20 33 f0 00 	movl   $0x0,0xf0332000
f010666b:	00 00 00 
			i = conf->entry;
f010666e:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106672:	47                   	inc    %edi
f0106673:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106677:	39 c7                	cmp    %eax,%edi
f0106679:	0f 82 60 ff ff ff    	jb     f01065df <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010667f:	a1 c0 23 33 f0       	mov    0xf03323c0,%eax
f0106684:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010668b:	83 3d 00 20 33 f0 00 	cmpl   $0x0,0xf0332000
f0106692:	75 22                	jne    f01066b6 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106694:	c7 05 c4 23 33 f0 01 	movl   $0x1,0xf03323c4
f010669b:	00 00 00 
		lapicaddr = 0;
f010669e:	c7 05 00 30 37 f0 00 	movl   $0x0,0xf0373000
f01066a5:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01066a8:	c7 04 24 18 8c 10 f0 	movl   $0xf0108c18,(%esp)
f01066af:	e8 d2 d8 ff ff       	call   f0103f86 <cprintf>
		return;
f01066b4:	eb 41                	jmp    f01066f7 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01066b6:	8b 15 c4 23 33 f0    	mov    0xf03323c4,%edx
f01066bc:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066c0:	0f b6 00             	movzbl (%eax),%eax
f01066c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066c7:	c7 04 24 9f 8c 10 f0 	movl   $0xf0108c9f,(%esp)
f01066ce:	e8 b3 d8 ff ff       	call   f0103f86 <cprintf>

	if (mp->imcrp) {
f01066d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01066d6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01066da:	74 1b                	je     f01066f7 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01066dc:	c7 04 24 44 8c 10 f0 	movl   $0xf0108c44,(%esp)
f01066e3:	e8 9e d8 ff ff       	call   f0103f86 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01066e8:	ba 22 00 00 00       	mov    $0x22,%edx
f01066ed:	b0 70                	mov    $0x70,%al
f01066ef:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01066f0:	b2 23                	mov    $0x23,%dl
f01066f2:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01066f3:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01066f6:	ee                   	out    %al,(%dx)
	}
}
f01066f7:	83 c4 2c             	add    $0x2c,%esp
f01066fa:	5b                   	pop    %ebx
f01066fb:	5e                   	pop    %esi
f01066fc:	5f                   	pop    %edi
f01066fd:	5d                   	pop    %ebp
f01066fe:	c3                   	ret    
	...

f0106700 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106700:	55                   	push   %ebp
f0106701:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106703:	c1 e0 02             	shl    $0x2,%eax
f0106706:	03 05 04 30 37 f0    	add    0xf0373004,%eax
f010670c:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010670e:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f0106713:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106716:	5d                   	pop    %ebp
f0106717:	c3                   	ret    

f0106718 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106718:	55                   	push   %ebp
f0106719:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010671b:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f0106720:	85 c0                	test   %eax,%eax
f0106722:	74 08                	je     f010672c <cpunum+0x14>
	  return lapic[ID] >> 24;
f0106724:	8b 40 20             	mov    0x20(%eax),%eax
f0106727:	c1 e8 18             	shr    $0x18,%eax
f010672a:	eb 05                	jmp    f0106731 <cpunum+0x19>
	return 0;
f010672c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106731:	5d                   	pop    %ebp
f0106732:	c3                   	ret    

f0106733 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106733:	55                   	push   %ebp
f0106734:	89 e5                	mov    %esp,%ebp
f0106736:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106739:	a1 00 30 37 f0       	mov    0xf0373000,%eax
f010673e:	85 c0                	test   %eax,%eax
f0106740:	0f 84 27 01 00 00    	je     f010686d <lapic_init+0x13a>
	  return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106746:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010674d:	00 
f010674e:	89 04 24             	mov    %eax,(%esp)
f0106751:	e8 55 ac ff ff       	call   f01013ab <mmio_map_region>
f0106756:	a3 04 30 37 f0       	mov    %eax,0xf0373004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010675b:	ba 27 01 00 00       	mov    $0x127,%edx
f0106760:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106765:	e8 96 ff ff ff       	call   f0106700 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010676a:	ba 0b 00 00 00       	mov    $0xb,%edx
f010676f:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106774:	e8 87 ff ff ff       	call   f0106700 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106779:	ba 20 00 02 00       	mov    $0x20020,%edx
f010677e:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106783:	e8 78 ff ff ff       	call   f0106700 <lapicw>
	lapicw(TICR, 10000000); 
f0106788:	ba 80 96 98 00       	mov    $0x989680,%edx
f010678d:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106792:	e8 69 ff ff ff       	call   f0106700 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106797:	e8 7c ff ff ff       	call   f0106718 <cpunum>
f010679c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067a3:	29 c2                	sub    %eax,%edx
f01067a5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01067a8:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f01067af:	39 05 c0 23 33 f0    	cmp    %eax,0xf03323c0
f01067b5:	74 0f                	je     f01067c6 <lapic_init+0x93>
	  lapicw(LINT0, MASKED);
f01067b7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067bc:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01067c1:	e8 3a ff ff ff       	call   f0106700 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01067c6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067cb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01067d0:	e8 2b ff ff ff       	call   f0106700 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01067d5:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f01067da:	8b 40 30             	mov    0x30(%eax),%eax
f01067dd:	c1 e8 10             	shr    $0x10,%eax
f01067e0:	3c 03                	cmp    $0x3,%al
f01067e2:	76 0f                	jbe    f01067f3 <lapic_init+0xc0>
	  lapicw(PCINT, MASKED);
f01067e4:	ba 00 00 01 00       	mov    $0x10000,%edx
f01067e9:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01067ee:	e8 0d ff ff ff       	call   f0106700 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01067f3:	ba 33 00 00 00       	mov    $0x33,%edx
f01067f8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01067fd:	e8 fe fe ff ff       	call   f0106700 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106802:	ba 00 00 00 00       	mov    $0x0,%edx
f0106807:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010680c:	e8 ef fe ff ff       	call   f0106700 <lapicw>
	lapicw(ESR, 0);
f0106811:	ba 00 00 00 00       	mov    $0x0,%edx
f0106816:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010681b:	e8 e0 fe ff ff       	call   f0106700 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106820:	ba 00 00 00 00       	mov    $0x0,%edx
f0106825:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010682a:	e8 d1 fe ff ff       	call   f0106700 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010682f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106834:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106839:	e8 c2 fe ff ff       	call   f0106700 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010683e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106843:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106848:	e8 b3 fe ff ff       	call   f0106700 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010684d:	8b 15 04 30 37 f0    	mov    0xf0373004,%edx
f0106853:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106859:	f6 c4 10             	test   $0x10,%ah
f010685c:	75 f5                	jne    f0106853 <lapic_init+0x120>
	  ;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010685e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106863:	b8 20 00 00 00       	mov    $0x20,%eax
f0106868:	e8 93 fe ff ff       	call   f0106700 <lapicw>
}
f010686d:	c9                   	leave  
f010686e:	c3                   	ret    

f010686f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010686f:	55                   	push   %ebp
f0106870:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106872:	83 3d 04 30 37 f0 00 	cmpl   $0x0,0xf0373004
f0106879:	74 0f                	je     f010688a <lapic_eoi+0x1b>
	  lapicw(EOI, 0);
f010687b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106880:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106885:	e8 76 fe ff ff       	call   f0106700 <lapicw>
}
f010688a:	5d                   	pop    %ebp
f010688b:	c3                   	ret    

f010688c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010688c:	55                   	push   %ebp
f010688d:	89 e5                	mov    %esp,%ebp
f010688f:	56                   	push   %esi
f0106890:	53                   	push   %ebx
f0106891:	83 ec 10             	sub    $0x10,%esp
f0106894:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106897:	8a 5d 08             	mov    0x8(%ebp),%bl
f010689a:	ba 70 00 00 00       	mov    $0x70,%edx
f010689f:	b0 0f                	mov    $0xf,%al
f01068a1:	ee                   	out    %al,(%dx)
f01068a2:	b2 71                	mov    $0x71,%dl
f01068a4:	b0 0a                	mov    $0xa,%al
f01068a6:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01068a7:	83 3d 88 1e 33 f0 00 	cmpl   $0x0,0xf0331e88
f01068ae:	75 24                	jne    f01068d4 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01068b0:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01068b7:	00 
f01068b8:	c7 44 24 08 28 6e 10 	movl   $0xf0106e28,0x8(%esp)
f01068bf:	f0 
f01068c0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01068c7:	00 
f01068c8:	c7 04 24 bc 8c 10 f0 	movl   $0xf0108cbc,(%esp)
f01068cf:	e8 6c 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01068d4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01068db:	00 00 
	wrv[1] = addr >> 4;
f01068dd:	89 f0                	mov    %esi,%eax
f01068df:	c1 e8 04             	shr    $0x4,%eax
f01068e2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01068e8:	c1 e3 18             	shl    $0x18,%ebx
f01068eb:	89 da                	mov    %ebx,%edx
f01068ed:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068f2:	e8 09 fe ff ff       	call   f0106700 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01068f7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01068fc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106901:	e8 fa fd ff ff       	call   f0106700 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106906:	ba 00 85 00 00       	mov    $0x8500,%edx
f010690b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106910:	e8 eb fd ff ff       	call   f0106700 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106915:	c1 ee 0c             	shr    $0xc,%esi
f0106918:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010691e:	89 da                	mov    %ebx,%edx
f0106920:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106925:	e8 d6 fd ff ff       	call   f0106700 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010692a:	89 f2                	mov    %esi,%edx
f010692c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106931:	e8 ca fd ff ff       	call   f0106700 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106936:	89 da                	mov    %ebx,%edx
f0106938:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010693d:	e8 be fd ff ff       	call   f0106700 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106942:	89 f2                	mov    %esi,%edx
f0106944:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106949:	e8 b2 fd ff ff       	call   f0106700 <lapicw>
		microdelay(200);
	}
}
f010694e:	83 c4 10             	add    $0x10,%esp
f0106951:	5b                   	pop    %ebx
f0106952:	5e                   	pop    %esi
f0106953:	5d                   	pop    %ebp
f0106954:	c3                   	ret    

f0106955 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106955:	55                   	push   %ebp
f0106956:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106958:	8b 55 08             	mov    0x8(%ebp),%edx
f010695b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106961:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106966:	e8 95 fd ff ff       	call   f0106700 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010696b:	8b 15 04 30 37 f0    	mov    0xf0373004,%edx
f0106971:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106977:	f6 c4 10             	test   $0x10,%ah
f010697a:	75 f5                	jne    f0106971 <lapic_ipi+0x1c>
	  ;
}
f010697c:	5d                   	pop    %ebp
f010697d:	c3                   	ret    
	...

f0106980 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106980:	55                   	push   %ebp
f0106981:	89 e5                	mov    %esp,%ebp
f0106983:	53                   	push   %ebx
f0106984:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106987:	83 38 00             	cmpl   $0x0,(%eax)
f010698a:	74 25                	je     f01069b1 <holding+0x31>
f010698c:	8b 58 08             	mov    0x8(%eax),%ebx
f010698f:	e8 84 fd ff ff       	call   f0106718 <cpunum>
f0106994:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010699b:	29 c2                	sub    %eax,%edx
f010699d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069a0:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01069a7:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01069a9:	0f 94 c0             	sete   %al
f01069ac:	0f b6 c0             	movzbl %al,%eax
f01069af:	eb 05                	jmp    f01069b6 <holding+0x36>
f01069b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01069b6:	83 c4 04             	add    $0x4,%esp
f01069b9:	5b                   	pop    %ebx
f01069ba:	5d                   	pop    %ebp
f01069bb:	c3                   	ret    

f01069bc <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01069bc:	55                   	push   %ebp
f01069bd:	89 e5                	mov    %esp,%ebp
f01069bf:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01069c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01069c8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01069cb:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01069ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01069d5:	5d                   	pop    %ebp
f01069d6:	c3                   	ret    

f01069d7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01069d7:	55                   	push   %ebp
f01069d8:	89 e5                	mov    %esp,%ebp
f01069da:	53                   	push   %ebx
f01069db:	83 ec 24             	sub    $0x24,%esp
f01069de:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01069e1:	89 d8                	mov    %ebx,%eax
f01069e3:	e8 98 ff ff ff       	call   f0106980 <holding>
f01069e8:	85 c0                	test   %eax,%eax
f01069ea:	74 30                	je     f0106a1c <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01069ec:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01069ef:	e8 24 fd ff ff       	call   f0106718 <cpunum>
f01069f4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01069f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01069fc:	c7 44 24 08 cc 8c 10 	movl   $0xf0108ccc,0x8(%esp)
f0106a03:	f0 
f0106a04:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106a0b:	00 
f0106a0c:	c7 04 24 30 8d 10 f0 	movl   $0xf0108d30,(%esp)
f0106a13:	e8 28 96 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106a18:	f3 90                	pause  
f0106a1a:	eb 05                	jmp    f0106a21 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106a1c:	ba 01 00 00 00       	mov    $0x1,%edx
f0106a21:	89 d0                	mov    %edx,%eax
f0106a23:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106a26:	85 c0                	test   %eax,%eax
f0106a28:	75 ee                	jne    f0106a18 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106a2a:	e8 e9 fc ff ff       	call   f0106718 <cpunum>
f0106a2f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a36:	29 c2                	sub    %eax,%edx
f0106a38:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a3b:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0106a42:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106a45:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106a48:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106a4a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106a4f:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a55:	76 10                	jbe    f0106a67 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a57:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106a5a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a5d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a5f:	40                   	inc    %eax
f0106a60:	83 f8 0a             	cmp    $0xa,%eax
f0106a63:	75 ea                	jne    f0106a4f <spin_lock+0x78>
f0106a65:	eb 0d                	jmp    f0106a74 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106a67:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106a6e:	40                   	inc    %eax
f0106a6f:	83 f8 09             	cmp    $0x9,%eax
f0106a72:	7e f3                	jle    f0106a67 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106a74:	83 c4 24             	add    $0x24,%esp
f0106a77:	5b                   	pop    %ebx
f0106a78:	5d                   	pop    %ebp
f0106a79:	c3                   	ret    

f0106a7a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106a7a:	55                   	push   %ebp
f0106a7b:	89 e5                	mov    %esp,%ebp
f0106a7d:	57                   	push   %edi
f0106a7e:	56                   	push   %esi
f0106a7f:	53                   	push   %ebx
f0106a80:	83 ec 7c             	sub    $0x7c,%esp
f0106a83:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106a86:	89 d8                	mov    %ebx,%eax
f0106a88:	e8 f3 fe ff ff       	call   f0106980 <holding>
f0106a8d:	85 c0                	test   %eax,%eax
f0106a8f:	0f 85 d3 00 00 00    	jne    f0106b68 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106a95:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106a9c:	00 
f0106a9d:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106aa0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aa4:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106aa7:	89 34 24             	mov    %esi,(%esp)
f0106aaa:	e8 85 f6 ff ff       	call   f0106134 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106aaf:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106ab2:	0f b6 38             	movzbl (%eax),%edi
f0106ab5:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106ab8:	e8 5b fc ff ff       	call   f0106718 <cpunum>
f0106abd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106ac1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ac9:	c7 04 24 f8 8c 10 f0 	movl   $0xf0108cf8,(%esp)
f0106ad0:	e8 b1 d4 ff ff       	call   f0103f86 <cprintf>
f0106ad5:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106ad7:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106ada:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106add:	89 c7                	mov    %eax,%edi
f0106adf:	eb 63                	jmp    f0106b44 <spin_unlock+0xca>
f0106ae1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106ae5:	89 04 24             	mov    %eax,(%esp)
f0106ae8:	e8 3c eb ff ff       	call   f0105629 <debuginfo_eip>
f0106aed:	85 c0                	test   %eax,%eax
f0106aef:	78 39                	js     f0106b2a <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106af1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106af3:	89 c2                	mov    %eax,%edx
f0106af5:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106af8:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106afc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106aff:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106b03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106b06:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106b0a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106b0d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106b11:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106b14:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106b18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b1c:	c7 04 24 40 8d 10 f0 	movl   $0xf0108d40,(%esp)
f0106b23:	e8 5e d4 ff ff       	call   f0103f86 <cprintf>
f0106b28:	eb 12                	jmp    f0106b3c <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106b2a:	8b 06                	mov    (%esi),%eax
f0106b2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106b30:	c7 04 24 57 8d 10 f0 	movl   $0xf0108d57,(%esp)
f0106b37:	e8 4a d4 ff ff       	call   f0103f86 <cprintf>
f0106b3c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b3f:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106b42:	74 08                	je     f0106b4c <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106b44:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106b46:	8b 03                	mov    (%ebx),%eax
f0106b48:	85 c0                	test   %eax,%eax
f0106b4a:	75 95                	jne    f0106ae1 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106b4c:	c7 44 24 08 5f 8d 10 	movl   $0xf0108d5f,0x8(%esp)
f0106b53:	f0 
f0106b54:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106b5b:	00 
f0106b5c:	c7 04 24 30 8d 10 f0 	movl   $0xf0108d30,(%esp)
f0106b63:	e8 d8 94 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106b68:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106b6f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106b76:	b8 00 00 00 00       	mov    $0x0,%eax
f0106b7b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106b7e:	83 c4 7c             	add    $0x7c,%esp
f0106b81:	5b                   	pop    %ebx
f0106b82:	5e                   	pop    %esi
f0106b83:	5f                   	pop    %edi
f0106b84:	5d                   	pop    %ebp
f0106b85:	c3                   	ret    
	...

f0106b88 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0106b88:	55                   	push   %ebp
f0106b89:	57                   	push   %edi
f0106b8a:	56                   	push   %esi
f0106b8b:	83 ec 10             	sub    $0x10,%esp
f0106b8e:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106b92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106b96:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b9a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0106b9e:	89 cd                	mov    %ecx,%ebp
f0106ba0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106ba4:	85 c0                	test   %eax,%eax
f0106ba6:	75 2c                	jne    f0106bd4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0106ba8:	39 f9                	cmp    %edi,%ecx
f0106baa:	77 68                	ja     f0106c14 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106bac:	85 c9                	test   %ecx,%ecx
f0106bae:	75 0b                	jne    f0106bbb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106bb0:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bb5:	31 d2                	xor    %edx,%edx
f0106bb7:	f7 f1                	div    %ecx
f0106bb9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106bbb:	31 d2                	xor    %edx,%edx
f0106bbd:	89 f8                	mov    %edi,%eax
f0106bbf:	f7 f1                	div    %ecx
f0106bc1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106bc3:	89 f0                	mov    %esi,%eax
f0106bc5:	f7 f1                	div    %ecx
f0106bc7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106bc9:	89 f0                	mov    %esi,%eax
f0106bcb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106bcd:	83 c4 10             	add    $0x10,%esp
f0106bd0:	5e                   	pop    %esi
f0106bd1:	5f                   	pop    %edi
f0106bd2:	5d                   	pop    %ebp
f0106bd3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106bd4:	39 f8                	cmp    %edi,%eax
f0106bd6:	77 2c                	ja     f0106c04 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106bd8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0106bdb:	83 f6 1f             	xor    $0x1f,%esi
f0106bde:	75 4c                	jne    f0106c2c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106be0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106be2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106be7:	72 0a                	jb     f0106bf3 <__udivdi3+0x6b>
f0106be9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106bed:	0f 87 ad 00 00 00    	ja     f0106ca0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106bf3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106bf8:	89 f0                	mov    %esi,%eax
f0106bfa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106bfc:	83 c4 10             	add    $0x10,%esp
f0106bff:	5e                   	pop    %esi
f0106c00:	5f                   	pop    %edi
f0106c01:	5d                   	pop    %ebp
f0106c02:	c3                   	ret    
f0106c03:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106c04:	31 ff                	xor    %edi,%edi
f0106c06:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106c08:	89 f0                	mov    %esi,%eax
f0106c0a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106c0c:	83 c4 10             	add    $0x10,%esp
f0106c0f:	5e                   	pop    %esi
f0106c10:	5f                   	pop    %edi
f0106c11:	5d                   	pop    %ebp
f0106c12:	c3                   	ret    
f0106c13:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106c14:	89 fa                	mov    %edi,%edx
f0106c16:	89 f0                	mov    %esi,%eax
f0106c18:	f7 f1                	div    %ecx
f0106c1a:	89 c6                	mov    %eax,%esi
f0106c1c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106c1e:	89 f0                	mov    %esi,%eax
f0106c20:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106c22:	83 c4 10             	add    $0x10,%esp
f0106c25:	5e                   	pop    %esi
f0106c26:	5f                   	pop    %edi
f0106c27:	5d                   	pop    %ebp
f0106c28:	c3                   	ret    
f0106c29:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106c2c:	89 f1                	mov    %esi,%ecx
f0106c2e:	d3 e0                	shl    %cl,%eax
f0106c30:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106c34:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c39:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106c3b:	89 ea                	mov    %ebp,%edx
f0106c3d:	88 c1                	mov    %al,%cl
f0106c3f:	d3 ea                	shr    %cl,%edx
f0106c41:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106c45:	09 ca                	or     %ecx,%edx
f0106c47:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0106c4b:	89 f1                	mov    %esi,%ecx
f0106c4d:	d3 e5                	shl    %cl,%ebp
f0106c4f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0106c53:	89 fd                	mov    %edi,%ebp
f0106c55:	88 c1                	mov    %al,%cl
f0106c57:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0106c59:	89 fa                	mov    %edi,%edx
f0106c5b:	89 f1                	mov    %esi,%ecx
f0106c5d:	d3 e2                	shl    %cl,%edx
f0106c5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106c63:	88 c1                	mov    %al,%cl
f0106c65:	d3 ef                	shr    %cl,%edi
f0106c67:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106c69:	89 f8                	mov    %edi,%eax
f0106c6b:	89 ea                	mov    %ebp,%edx
f0106c6d:	f7 74 24 08          	divl   0x8(%esp)
f0106c71:	89 d1                	mov    %edx,%ecx
f0106c73:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f0106c75:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106c79:	39 d1                	cmp    %edx,%ecx
f0106c7b:	72 17                	jb     f0106c94 <__udivdi3+0x10c>
f0106c7d:	74 09                	je     f0106c88 <__udivdi3+0x100>
f0106c7f:	89 fe                	mov    %edi,%esi
f0106c81:	31 ff                	xor    %edi,%edi
f0106c83:	e9 41 ff ff ff       	jmp    f0106bc9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106c88:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106c8c:	89 f1                	mov    %esi,%ecx
f0106c8e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106c90:	39 c2                	cmp    %eax,%edx
f0106c92:	73 eb                	jae    f0106c7f <__udivdi3+0xf7>
		{
		  q0--;
f0106c94:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106c97:	31 ff                	xor    %edi,%edi
f0106c99:	e9 2b ff ff ff       	jmp    f0106bc9 <__udivdi3+0x41>
f0106c9e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106ca0:	31 f6                	xor    %esi,%esi
f0106ca2:	e9 22 ff ff ff       	jmp    f0106bc9 <__udivdi3+0x41>
	...

f0106ca8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106ca8:	55                   	push   %ebp
f0106ca9:	57                   	push   %edi
f0106caa:	56                   	push   %esi
f0106cab:	83 ec 20             	sub    $0x20,%esp
f0106cae:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106cb2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106cb6:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106cba:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0106cbe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106cc2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106cc6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0106cc8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106cca:	85 ed                	test   %ebp,%ebp
f0106ccc:	75 16                	jne    f0106ce4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0106cce:	39 f1                	cmp    %esi,%ecx
f0106cd0:	0f 86 a6 00 00 00    	jbe    f0106d7c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106cd6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106cd8:	89 d0                	mov    %edx,%eax
f0106cda:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106cdc:	83 c4 20             	add    $0x20,%esp
f0106cdf:	5e                   	pop    %esi
f0106ce0:	5f                   	pop    %edi
f0106ce1:	5d                   	pop    %ebp
f0106ce2:	c3                   	ret    
f0106ce3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106ce4:	39 f5                	cmp    %esi,%ebp
f0106ce6:	0f 87 ac 00 00 00    	ja     f0106d98 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106cec:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0106cef:	83 f0 1f             	xor    $0x1f,%eax
f0106cf2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106cf6:	0f 84 a8 00 00 00    	je     f0106da4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106cfc:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d00:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106d02:	bf 20 00 00 00       	mov    $0x20,%edi
f0106d07:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106d0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d0f:	89 f9                	mov    %edi,%ecx
f0106d11:	d3 e8                	shr    %cl,%eax
f0106d13:	09 e8                	or     %ebp,%eax
f0106d15:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0106d19:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106d1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d21:	d3 e0                	shl    %cl,%eax
f0106d23:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106d27:	89 f2                	mov    %esi,%edx
f0106d29:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106d2b:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d2f:	d3 e0                	shl    %cl,%eax
f0106d31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106d35:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106d39:	89 f9                	mov    %edi,%ecx
f0106d3b:	d3 e8                	shr    %cl,%eax
f0106d3d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106d3f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106d41:	89 f2                	mov    %esi,%edx
f0106d43:	f7 74 24 18          	divl   0x18(%esp)
f0106d47:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106d49:	f7 64 24 0c          	mull   0xc(%esp)
f0106d4d:	89 c5                	mov    %eax,%ebp
f0106d4f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106d51:	39 d6                	cmp    %edx,%esi
f0106d53:	72 67                	jb     f0106dbc <__umoddi3+0x114>
f0106d55:	74 75                	je     f0106dcc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0106d57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106d5b:	29 e8                	sub    %ebp,%eax
f0106d5d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0106d5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d63:	d3 e8                	shr    %cl,%eax
f0106d65:	89 f2                	mov    %esi,%edx
f0106d67:	89 f9                	mov    %edi,%ecx
f0106d69:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0106d6b:	09 d0                	or     %edx,%eax
f0106d6d:	89 f2                	mov    %esi,%edx
f0106d6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d73:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d75:	83 c4 20             	add    $0x20,%esp
f0106d78:	5e                   	pop    %esi
f0106d79:	5f                   	pop    %edi
f0106d7a:	5d                   	pop    %ebp
f0106d7b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106d7c:	85 c9                	test   %ecx,%ecx
f0106d7e:	75 0b                	jne    f0106d8b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106d80:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d85:	31 d2                	xor    %edx,%edx
f0106d87:	f7 f1                	div    %ecx
f0106d89:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106d8b:	89 f0                	mov    %esi,%eax
f0106d8d:	31 d2                	xor    %edx,%edx
f0106d8f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106d91:	89 f8                	mov    %edi,%eax
f0106d93:	e9 3e ff ff ff       	jmp    f0106cd6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0106d98:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d9a:	83 c4 20             	add    $0x20,%esp
f0106d9d:	5e                   	pop    %esi
f0106d9e:	5f                   	pop    %edi
f0106d9f:	5d                   	pop    %ebp
f0106da0:	c3                   	ret    
f0106da1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106da4:	39 f5                	cmp    %esi,%ebp
f0106da6:	72 04                	jb     f0106dac <__umoddi3+0x104>
f0106da8:	39 f9                	cmp    %edi,%ecx
f0106daa:	77 06                	ja     f0106db2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106dac:	89 f2                	mov    %esi,%edx
f0106dae:	29 cf                	sub    %ecx,%edi
f0106db0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0106db2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106db4:	83 c4 20             	add    $0x20,%esp
f0106db7:	5e                   	pop    %esi
f0106db8:	5f                   	pop    %edi
f0106db9:	5d                   	pop    %ebp
f0106dba:	c3                   	ret    
f0106dbb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106dbc:	89 d1                	mov    %edx,%ecx
f0106dbe:	89 c5                	mov    %eax,%ebp
f0106dc0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106dc4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106dc8:	eb 8d                	jmp    f0106d57 <__umoddi3+0xaf>
f0106dca:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106dcc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106dd0:	72 ea                	jb     f0106dbc <__umoddi3+0x114>
f0106dd2:	89 f1                	mov    %esi,%ecx
f0106dd4:	eb 81                	jmp    f0106d57 <__umoddi3+0xaf>
