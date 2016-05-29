
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
f010004b:	83 3d 80 0e 1f f0 00 	cmpl   $0x0,0xf01f0e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 0e 1f f0    	mov    %esi,0xf01f0e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 64 66 00 00       	call   f01066c8 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 a0 6d 10 f0 	movl   $0xf0106da0,(%esp)
f010007d:	e8 a4 3e 00 00       	call   f0103f26 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 65 3e 00 00       	call   f0103ef3 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 ff 7f 10 f0 	movl   $0xf0107fff,(%esp)
f0100095:	e8 8c 3e 00 00       	call   f0103f26 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 dd 08 00 00       	call   f0100983 <monitor>
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
f01000ae:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 0b 6e 10 f0 	movl   $0xf0106e0b,(%esp)
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
f01000e2:	e8 e1 65 00 00       	call   f01066c8 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 17 6e 10 f0 	movl   $0xf0106e17,(%esp)
f01000f2:	e8 2f 3e 00 00       	call   f0103f26 <cprintf>

	lapic_init();
f01000f7:	e8 e7 65 00 00       	call   f01066e3 <lapic_init>
	env_init_percpu();
f01000fc:	e8 f3 35 00 00       	call   f01036f4 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 3a 3e 00 00       	call   f0103f40 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 bd 65 00 00       	call   f01066c8 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 10 1f f0    	add    $0xf01f1020,%edx
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
f0100124:	e8 5e 68 00 00       	call   f0106987 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();	
	sched_yield();
f0100129:	e8 cc 4b 00 00       	call   f0104cfa <sched_yield>

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
f0100135:	b8 08 20 23 f0       	mov    $0xf0232008,%eax
f010013a:	2d 5c ff 1e f0       	sub    $0xf01eff5c,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 5c ff 1e f0 	movl   $0xf01eff5c,(%esp)
f0100152:	e8 43 5f 00 00       	call   f010609a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 1b 05 00 00       	call   f0100677 <cons_init>

	//cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
	mem_init();
f010015c:	e8 ec 12 00 00       	call   f010144d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100161:	e8 b8 35 00 00       	call   f010371e <env_init>
	trap_init();
f0100166:	e8 d8 3e 00 00       	call   f0104043 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010016b:	e8 70 62 00 00       	call   f01063e0 <mp_init>
	lapic_init();
f0100170:	e8 6e 65 00 00       	call   f01066e3 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100175:	e8 02 3d 00 00       	call   f0103e7c <pic_init>
f010017a:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100181:	e8 01 68 00 00       	call   f0106987 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100186:	83 3d 88 0e 1f f0 07 	cmpl   $0x7,0xf01f0e88
f010018d:	77 24                	ja     f01001b3 <i386_init+0x85>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010018f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100196:	00 
f0100197:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f010019e:	f0 
f010019f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f01001a6:	00 
f01001a7:	c7 04 24 0b 6e 10 f0 	movl   $0xf0106e0b,(%esp)
f01001ae:	e8 8d fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001b3:	b8 0a 63 10 f0       	mov    $0xf010630a,%eax
f01001b8:	2d 90 62 10 f0       	sub    $0xf0106290,%eax
f01001bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001c1:	c7 44 24 04 90 62 10 	movl   $0xf0106290,0x4(%esp)
f01001c8:	f0 
f01001c9:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001d0:	e8 0f 5f 00 00       	call   f01060e4 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001d5:	bb 20 10 1f f0       	mov    $0xf01f1020,%ebx
f01001da:	eb 6f                	jmp    f010024b <i386_init+0x11d>
		if (c == cpus + cpunum())  // We've started already.
f01001dc:	e8 e7 64 00 00       	call   f01066c8 <cpunum>
f01001e1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001e8:	29 c2                	sub    %eax,%edx
f01001ea:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001ed:	8d 04 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%eax
f01001f4:	39 c3                	cmp    %eax,%ebx
f01001f6:	74 50                	je     f0100248 <i386_init+0x11a>

static void boot_aps(void);


void
i386_init(void)
f01001f8:	89 d8                	mov    %ebx,%eax
f01001fa:	2d 20 10 1f f0       	sub    $0xf01f1020,%eax
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
f0100223:	05 00 20 1f f0       	add    $0xf01f2000,%eax
f0100228:	a3 84 0e 1f f0       	mov    %eax,0xf01f0e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010022d:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100234:	00 
f0100235:	0f b6 03             	movzbl (%ebx),%eax
f0100238:	89 04 24             	mov    %eax,(%esp)
f010023b:	e8 fc 65 00 00       	call   f010683c <lapic_startap>
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
f010024b:	a1 c4 13 1f f0       	mov    0xf01f13c4,%eax
f0100250:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100257:	29 c2                	sub    %eax,%edx
f0100259:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010025c:	8d 04 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%eax
f0100263:	39 c3                	cmp    %eax,%ebx
f0100265:	0f 82 71 ff ff ff    	jb     f01001dc <i386_init+0xae>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010026b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100272:	00 
f0100273:	c7 04 24 fc 6c 1a f0 	movl   $0xf01a6cfc,(%esp)
f010027a:	e8 7b 36 00 00       	call   f01038fa <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010027f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100286:	00 
f0100287:	c7 04 24 9d 00 1e f0 	movl   $0xf01e009d,(%esp)
f010028e:	e8 67 36 00 00       	call   f01038fa <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100293:	e8 86 03 00 00       	call   f010061e <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f0100298:	e8 5d 4a 00 00       	call   f0104cfa <sched_yield>

f010029d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010029d:	55                   	push   %ebp
f010029e:	89 e5                	mov    %esp,%ebp
f01002a0:	53                   	push   %ebx
f01002a1:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002b5:	c7 04 24 2d 6e 10 f0 	movl   $0xf0106e2d,(%esp)
f01002bc:	e8 65 3c 00 00       	call   f0103f26 <cprintf>
	vcprintf(fmt, ap);
f01002c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002c5:	8b 45 10             	mov    0x10(%ebp),%eax
f01002c8:	89 04 24             	mov    %eax,(%esp)
f01002cb:	e8 23 3c 00 00       	call   f0103ef3 <vcprintf>
	cprintf("\n");
f01002d0:	c7 04 24 ff 7f 10 f0 	movl   $0xf0107fff,(%esp)
f01002d7:	e8 4a 3c 00 00       	call   f0103f26 <cprintf>
	va_end(ap);
}
f01002dc:	83 c4 14             	add    $0x14,%esp
f01002df:	5b                   	pop    %ebx
f01002e0:	5d                   	pop    %ebp
f01002e1:	c3                   	ret    
	...

f01002e4 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e7:	ba 84 00 00 00       	mov    $0x84,%edx
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	ec                   	in     (%dx),%al
f01002ee:	ec                   	in     (%dx),%al
f01002ef:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002f0:	5d                   	pop    %ebp
f01002f1:	c3                   	ret    

f01002f2 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002fa:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002fb:	a8 01                	test   $0x1,%al
f01002fd:	74 08                	je     f0100307 <serial_proc_data+0x15>
f01002ff:	b2 f8                	mov    $0xf8,%dl
f0100301:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100302:	0f b6 c0             	movzbl %al,%eax
f0100305:	eb 05                	jmp    f010030c <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100307:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010030c:	5d                   	pop    %ebp
f010030d:	c3                   	ret    

f010030e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010030e:	55                   	push   %ebp
f010030f:	89 e5                	mov    %esp,%ebp
f0100311:	53                   	push   %ebx
f0100312:	83 ec 04             	sub    $0x4,%esp
f0100315:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100317:	eb 29                	jmp    f0100342 <cons_intr+0x34>
		if (c == 0)
f0100319:	85 c0                	test   %eax,%eax
f010031b:	74 25                	je     f0100342 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010031d:	8b 15 24 02 1f f0    	mov    0xf01f0224,%edx
f0100323:	88 82 20 00 1f f0    	mov    %al,-0xfe0ffe0(%edx)
f0100329:	8d 42 01             	lea    0x1(%edx),%eax
f010032c:	a3 24 02 1f f0       	mov    %eax,0xf01f0224
		if (cons.wpos == CONSBUFSIZE)
f0100331:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100336:	75 0a                	jne    f0100342 <cons_intr+0x34>
			cons.wpos = 0;
f0100338:	c7 05 24 02 1f f0 00 	movl   $0x0,0xf01f0224
f010033f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100342:	ff d3                	call   *%ebx
f0100344:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100347:	75 d0                	jne    f0100319 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100349:	83 c4 04             	add    $0x4,%esp
f010034c:	5b                   	pop    %ebx
f010034d:	5d                   	pop    %ebp
f010034e:	c3                   	ret    

f010034f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034f:	55                   	push   %ebp
f0100350:	89 e5                	mov    %esp,%ebp
f0100352:	57                   	push   %edi
f0100353:	56                   	push   %esi
f0100354:	53                   	push   %ebx
f0100355:	83 ec 2c             	sub    $0x2c,%esp
f0100358:	89 c6                	mov    %eax,%esi
f010035a:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010035f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100364:	eb 05                	jmp    f010036b <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100366:	e8 79 ff ff ff       	call   f01002e4 <delay>
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010036e:	a8 20                	test   $0x20,%al
f0100370:	75 03                	jne    f0100375 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100372:	4b                   	dec    %ebx
f0100373:	75 f1                	jne    f0100366 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100375:	89 f2                	mov    %esi,%edx
f0100377:	89 f0                	mov    %esi,%eax
f0100379:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100381:	ee                   	out    %al,(%dx)
f0100382:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100387:	bf 79 03 00 00       	mov    $0x379,%edi
f010038c:	eb 05                	jmp    f0100393 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f010038e:	e8 51 ff ff ff       	call   f01002e4 <delay>
f0100393:	89 fa                	mov    %edi,%edx
f0100395:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100396:	84 c0                	test   %al,%al
f0100398:	78 03                	js     f010039d <cons_putc+0x4e>
f010039a:	4b                   	dec    %ebx
f010039b:	75 f1                	jne    f010038e <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039d:	ba 78 03 00 00       	mov    $0x378,%edx
f01003a2:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003a5:	ee                   	out    %al,(%dx)
f01003a6:	b2 7a                	mov    $0x7a,%dl
f01003a8:	b0 0d                	mov    $0xd,%al
f01003aa:	ee                   	out    %al,(%dx)
f01003ab:	b0 08                	mov    $0x8,%al
f01003ad:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003ae:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003b4:	75 06                	jne    f01003bc <cons_putc+0x6d>
		c |= 0x0700;
f01003b6:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003bc:	89 f0                	mov    %esi,%eax
f01003be:	25 ff 00 00 00       	and    $0xff,%eax
f01003c3:	83 f8 09             	cmp    $0x9,%eax
f01003c6:	74 78                	je     f0100440 <cons_putc+0xf1>
f01003c8:	83 f8 09             	cmp    $0x9,%eax
f01003cb:	7f 0b                	jg     f01003d8 <cons_putc+0x89>
f01003cd:	83 f8 08             	cmp    $0x8,%eax
f01003d0:	0f 85 9e 00 00 00    	jne    f0100474 <cons_putc+0x125>
f01003d6:	eb 10                	jmp    f01003e8 <cons_putc+0x99>
f01003d8:	83 f8 0a             	cmp    $0xa,%eax
f01003db:	74 39                	je     f0100416 <cons_putc+0xc7>
f01003dd:	83 f8 0d             	cmp    $0xd,%eax
f01003e0:	0f 85 8e 00 00 00    	jne    f0100474 <cons_putc+0x125>
f01003e6:	eb 36                	jmp    f010041e <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003e8:	66 a1 34 02 1f f0    	mov    0xf01f0234,%ax
f01003ee:	66 85 c0             	test   %ax,%ax
f01003f1:	0f 84 e2 00 00 00    	je     f01004d9 <cons_putc+0x18a>
			crt_pos--;
f01003f7:	48                   	dec    %eax
f01003f8:	66 a3 34 02 1f f0    	mov    %ax,0xf01f0234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003fe:	0f b7 c0             	movzwl %ax,%eax
f0100401:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100407:	83 ce 20             	or     $0x20,%esi
f010040a:	8b 15 30 02 1f f0    	mov    0xf01f0230,%edx
f0100410:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100414:	eb 78                	jmp    f010048e <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100416:	66 83 05 34 02 1f f0 	addw   $0x50,0xf01f0234
f010041d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010041e:	66 8b 0d 34 02 1f f0 	mov    0xf01f0234,%cx
f0100425:	bb 50 00 00 00       	mov    $0x50,%ebx
f010042a:	89 c8                	mov    %ecx,%eax
f010042c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100431:	66 f7 f3             	div    %bx
f0100434:	66 29 d1             	sub    %dx,%cx
f0100437:	66 89 0d 34 02 1f f0 	mov    %cx,0xf01f0234
f010043e:	eb 4e                	jmp    f010048e <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100440:	b8 20 00 00 00       	mov    $0x20,%eax
f0100445:	e8 05 ff ff ff       	call   f010034f <cons_putc>
		cons_putc(' ');
f010044a:	b8 20 00 00 00       	mov    $0x20,%eax
f010044f:	e8 fb fe ff ff       	call   f010034f <cons_putc>
		cons_putc(' ');
f0100454:	b8 20 00 00 00       	mov    $0x20,%eax
f0100459:	e8 f1 fe ff ff       	call   f010034f <cons_putc>
		cons_putc(' ');
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 e7 fe ff ff       	call   f010034f <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 dd fe ff ff       	call   f010034f <cons_putc>
f0100472:	eb 1a                	jmp    f010048e <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100474:	66 a1 34 02 1f f0    	mov    0xf01f0234,%ax
f010047a:	0f b7 c8             	movzwl %ax,%ecx
f010047d:	8b 15 30 02 1f f0    	mov    0xf01f0230,%edx
f0100483:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100487:	40                   	inc    %eax
f0100488:	66 a3 34 02 1f f0    	mov    %ax,0xf01f0234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010048e:	66 81 3d 34 02 1f f0 	cmpw   $0x7cf,0xf01f0234
f0100495:	cf 07 
f0100497:	76 40                	jbe    f01004d9 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100499:	a1 30 02 1f f0       	mov    0xf01f0230,%eax
f010049e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004a5:	00 
f01004a6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004ac:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004b0:	89 04 24             	mov    %eax,(%esp)
f01004b3:	e8 2c 5c 00 00       	call   f01060e4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004b8:	8b 15 30 02 1f f0    	mov    0xf01f0230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004be:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004c3:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c9:	40                   	inc    %eax
f01004ca:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004cf:	75 f2                	jne    f01004c3 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004d1:	66 83 2d 34 02 1f f0 	subw   $0x50,0xf01f0234
f01004d8:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004d9:	8b 0d 2c 02 1f f0    	mov    0xf01f022c,%ecx
f01004df:	b0 0e                	mov    $0xe,%al
f01004e1:	89 ca                	mov    %ecx,%edx
f01004e3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004e4:	66 8b 35 34 02 1f f0 	mov    0xf01f0234,%si
f01004eb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004ee:	89 f0                	mov    %esi,%eax
f01004f0:	66 c1 e8 08          	shr    $0x8,%ax
f01004f4:	89 da                	mov    %ebx,%edx
f01004f6:	ee                   	out    %al,(%dx)
f01004f7:	b0 0f                	mov    $0xf,%al
f01004f9:	89 ca                	mov    %ecx,%edx
f01004fb:	ee                   	out    %al,(%dx)
f01004fc:	89 f0                	mov    %esi,%eax
f01004fe:	89 da                	mov    %ebx,%edx
f0100500:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100501:	83 c4 2c             	add    $0x2c,%esp
f0100504:	5b                   	pop    %ebx
f0100505:	5e                   	pop    %esi
f0100506:	5f                   	pop    %edi
f0100507:	5d                   	pop    %ebp
f0100508:	c3                   	ret    

f0100509 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	53                   	push   %ebx
f010050d:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100510:	ba 64 00 00 00       	mov    $0x64,%edx
f0100515:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100516:	a8 01                	test   $0x1,%al
f0100518:	0f 84 d8 00 00 00    	je     f01005f6 <kbd_proc_data+0xed>
f010051e:	b2 60                	mov    $0x60,%dl
f0100520:	ec                   	in     (%dx),%al
f0100521:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100523:	3c e0                	cmp    $0xe0,%al
f0100525:	75 11                	jne    f0100538 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100527:	83 0d 28 02 1f f0 40 	orl    $0x40,0xf01f0228
		return 0;
f010052e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100533:	e9 c3 00 00 00       	jmp    f01005fb <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100538:	84 c0                	test   %al,%al
f010053a:	79 33                	jns    f010056f <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010053c:	8b 0d 28 02 1f f0    	mov    0xf01f0228,%ecx
f0100542:	f6 c1 40             	test   $0x40,%cl
f0100545:	75 05                	jne    f010054c <kbd_proc_data+0x43>
f0100547:	88 c2                	mov    %al,%dl
f0100549:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010054c:	0f b6 d2             	movzbl %dl,%edx
f010054f:	8a 82 80 6e 10 f0    	mov    -0xfef9180(%edx),%al
f0100555:	83 c8 40             	or     $0x40,%eax
f0100558:	0f b6 c0             	movzbl %al,%eax
f010055b:	f7 d0                	not    %eax
f010055d:	21 c1                	and    %eax,%ecx
f010055f:	89 0d 28 02 1f f0    	mov    %ecx,0xf01f0228
		return 0;
f0100565:	bb 00 00 00 00       	mov    $0x0,%ebx
f010056a:	e9 8c 00 00 00       	jmp    f01005fb <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f010056f:	8b 0d 28 02 1f f0    	mov    0xf01f0228,%ecx
f0100575:	f6 c1 40             	test   $0x40,%cl
f0100578:	74 0e                	je     f0100588 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010057a:	88 c2                	mov    %al,%dl
f010057c:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100582:	89 0d 28 02 1f f0    	mov    %ecx,0xf01f0228
	}

	shift |= shiftcode[data];
f0100588:	0f b6 d2             	movzbl %dl,%edx
f010058b:	0f b6 82 80 6e 10 f0 	movzbl -0xfef9180(%edx),%eax
f0100592:	0b 05 28 02 1f f0    	or     0xf01f0228,%eax
	shift ^= togglecode[data];
f0100598:	0f b6 8a 80 6f 10 f0 	movzbl -0xfef9080(%edx),%ecx
f010059f:	31 c8                	xor    %ecx,%eax
f01005a1:	a3 28 02 1f f0       	mov    %eax,0xf01f0228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a6:	89 c1                	mov    %eax,%ecx
f01005a8:	83 e1 03             	and    $0x3,%ecx
f01005ab:	8b 0c 8d 80 70 10 f0 	mov    -0xfef8f80(,%ecx,4),%ecx
f01005b2:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005b6:	a8 08                	test   $0x8,%al
f01005b8:	74 18                	je     f01005d2 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005ba:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005bd:	83 fa 19             	cmp    $0x19,%edx
f01005c0:	77 05                	ja     f01005c7 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005c2:	83 eb 20             	sub    $0x20,%ebx
f01005c5:	eb 0b                	jmp    f01005d2 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005c7:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005ca:	83 fa 19             	cmp    $0x19,%edx
f01005cd:	77 03                	ja     f01005d2 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005cf:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005d2:	f7 d0                	not    %eax
f01005d4:	a8 06                	test   $0x6,%al
f01005d6:	75 23                	jne    f01005fb <kbd_proc_data+0xf2>
f01005d8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005de:	75 1b                	jne    f01005fb <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f01005e0:	c7 04 24 47 6e 10 f0 	movl   $0xf0106e47,(%esp)
f01005e7:	e8 3a 39 00 00       	call   f0103f26 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ec:	ba 92 00 00 00       	mov    $0x92,%edx
f01005f1:	b0 03                	mov    $0x3,%al
f01005f3:	ee                   	out    %al,(%dx)
f01005f4:	eb 05                	jmp    f01005fb <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01005f6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005fb:	89 d8                	mov    %ebx,%eax
f01005fd:	83 c4 14             	add    $0x14,%esp
f0100600:	5b                   	pop    %ebx
f0100601:	5d                   	pop    %ebp
f0100602:	c3                   	ret    

f0100603 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100609:	80 3d 00 00 1f f0 00 	cmpb   $0x0,0xf01f0000
f0100610:	74 0a                	je     f010061c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100612:	b8 f2 02 10 f0       	mov    $0xf01002f2,%eax
f0100617:	e8 f2 fc ff ff       	call   f010030e <cons_intr>
}
f010061c:	c9                   	leave  
f010061d:	c3                   	ret    

f010061e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010061e:	55                   	push   %ebp
f010061f:	89 e5                	mov    %esp,%ebp
f0100621:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100624:	b8 09 05 10 f0       	mov    $0xf0100509,%eax
f0100629:	e8 e0 fc ff ff       	call   f010030e <cons_intr>
}
f010062e:	c9                   	leave  
f010062f:	c3                   	ret    

f0100630 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100636:	e8 c8 ff ff ff       	call   f0100603 <serial_intr>
	kbd_intr();
f010063b:	e8 de ff ff ff       	call   f010061e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100640:	8b 15 20 02 1f f0    	mov    0xf01f0220,%edx
f0100646:	3b 15 24 02 1f f0    	cmp    0xf01f0224,%edx
f010064c:	74 22                	je     f0100670 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010064e:	0f b6 82 20 00 1f f0 	movzbl -0xfe0ffe0(%edx),%eax
f0100655:	42                   	inc    %edx
f0100656:	89 15 20 02 1f f0    	mov    %edx,0xf01f0220
		if (cons.rpos == CONSBUFSIZE)
f010065c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100662:	75 11                	jne    f0100675 <cons_getc+0x45>
			cons.rpos = 0;
f0100664:	c7 05 20 02 1f f0 00 	movl   $0x0,0xf01f0220
f010066b:	00 00 00 
f010066e:	eb 05                	jmp    f0100675 <cons_getc+0x45>
		return c;
	}
	return 0;
f0100670:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100675:	c9                   	leave  
f0100676:	c3                   	ret    

f0100677 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100677:	55                   	push   %ebp
f0100678:	89 e5                	mov    %esp,%ebp
f010067a:	57                   	push   %edi
f010067b:	56                   	push   %esi
f010067c:	53                   	push   %ebx
f010067d:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100680:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100687:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010068e:	5a a5 
	if (*cp != 0xA55A) {
f0100690:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100696:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010069a:	74 11                	je     f01006ad <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010069c:	c7 05 2c 02 1f f0 b4 	movl   $0x3b4,0xf01f022c
f01006a3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006a6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006ab:	eb 16                	jmp    f01006c3 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 05 2c 02 1f f0 d4 	movl   $0x3d4,0xf01f022c
f01006bb:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006c3:	8b 0d 2c 02 1f f0    	mov    0xf01f022c,%ecx
f01006c9:	b0 0e                	mov    $0xe,%al
f01006cb:	89 ca                	mov    %ecx,%edx
f01006cd:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ce:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d1:	89 da                	mov    %ebx,%edx
f01006d3:	ec                   	in     (%dx),%al
f01006d4:	0f b6 f8             	movzbl %al,%edi
f01006d7:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006da:	b0 0f                	mov    $0xf,%al
f01006dc:	89 ca                	mov    %ecx,%edx
f01006de:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006df:	89 da                	mov    %ebx,%edx
f01006e1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e2:	89 35 30 02 1f f0    	mov    %esi,0xf01f0230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006e8:	0f b6 d8             	movzbl %al,%ebx
f01006eb:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006ed:	66 89 3d 34 02 1f f0 	mov    %di,0xf01f0234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f4:	e8 25 ff ff ff       	call   f010061e <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006f9:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f0100700:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100705:	89 04 24             	mov    %eax,(%esp)
f0100708:	e8 fb 36 00 00       	call   f0103e08 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070d:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100712:	b0 00                	mov    $0x0,%al
f0100714:	89 da                	mov    %ebx,%edx
f0100716:	ee                   	out    %al,(%dx)
f0100717:	b2 fb                	mov    $0xfb,%dl
f0100719:	b0 80                	mov    $0x80,%al
f010071b:	ee                   	out    %al,(%dx)
f010071c:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100721:	b0 0c                	mov    $0xc,%al
f0100723:	89 ca                	mov    %ecx,%edx
f0100725:	ee                   	out    %al,(%dx)
f0100726:	b2 f9                	mov    $0xf9,%dl
f0100728:	b0 00                	mov    $0x0,%al
f010072a:	ee                   	out    %al,(%dx)
f010072b:	b2 fb                	mov    $0xfb,%dl
f010072d:	b0 03                	mov    $0x3,%al
f010072f:	ee                   	out    %al,(%dx)
f0100730:	b2 fc                	mov    $0xfc,%dl
f0100732:	b0 00                	mov    $0x0,%al
f0100734:	ee                   	out    %al,(%dx)
f0100735:	b2 f9                	mov    $0xf9,%dl
f0100737:	b0 01                	mov    $0x1,%al
f0100739:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073a:	b2 fd                	mov    $0xfd,%dl
f010073c:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073d:	3c ff                	cmp    $0xff,%al
f010073f:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100743:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100746:	a2 00 00 1f f0       	mov    %al,0xf01f0000
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ec                   	in     (%dx),%al
f010074e:	89 ca                	mov    %ecx,%edx
f0100750:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100751:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100755:	74 1d                	je     f0100774 <cons_init+0xfd>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100757:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f010075e:	25 ef ff 00 00       	and    $0xffef,%eax
f0100763:	89 04 24             	mov    %eax,(%esp)
f0100766:	e8 9d 36 00 00       	call   f0103e08 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010076b:	80 3d 00 00 1f f0 00 	cmpb   $0x0,0xf01f0000
f0100772:	75 0c                	jne    f0100780 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100774:	c7 04 24 53 6e 10 f0 	movl   $0xf0106e53,(%esp)
f010077b:	e8 a6 37 00 00       	call   f0103f26 <cprintf>
}
f0100780:	83 c4 2c             	add    $0x2c,%esp
f0100783:	5b                   	pop    %ebx
f0100784:	5e                   	pop    %esi
f0100785:	5f                   	pop    %edi
f0100786:	5d                   	pop    %ebp
f0100787:	c3                   	ret    

f0100788 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100788:	55                   	push   %ebp
f0100789:	89 e5                	mov    %esp,%ebp
f010078b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010078e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100791:	e8 b9 fb ff ff       	call   f010034f <cons_putc>
}
f0100796:	c9                   	leave  
f0100797:	c3                   	ret    

f0100798 <getchar>:

int
getchar(void)
{
f0100798:	55                   	push   %ebp
f0100799:	89 e5                	mov    %esp,%ebp
f010079b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010079e:	e8 8d fe ff ff       	call   f0100630 <cons_getc>
f01007a3:	85 c0                	test   %eax,%eax
f01007a5:	74 f7                	je     f010079e <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a7:	c9                   	leave  
f01007a8:	c3                   	ret    

f01007a9 <iscons>:

int
iscons(int fdnum)
{
f01007a9:	55                   	push   %ebp
f01007aa:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ac:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b1:	5d                   	pop    %ebp
f01007b2:	c3                   	ret    
	...

f01007b4 <continue_exec>:

/***** Implementations of basic kernel monitor commands *****/

int
continue_exec(int argc, char **argv, struct Trapframe *tf)
{
f01007b4:	55                   	push   %ebp
f01007b5:	89 e5                	mov    %esp,%ebp
f01007b7:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags &= ~FL_TF;
f01007ba:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	    return -1;
}
f01007c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007c6:	5d                   	pop    %ebp
f01007c7:	c3                   	ret    

f01007c8 <single_step>:

int
single_step(int argc, char **argv, struct Trapframe *tf)
{
f01007c8:	55                   	push   %ebp
f01007c9:	89 e5                	mov    %esp,%ebp
f01007cb:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags |= FL_TF;
f01007ce:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
		return -1;
}
f01007d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007da:	5d                   	pop    %ebp
f01007db:	c3                   	ret    

f01007dc <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007e2:	c7 04 24 90 70 10 f0 	movl   $0xf0107090,(%esp)
f01007e9:	e8 38 37 00 00       	call   f0103f26 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ee:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007f5:	00 
f01007f6:	c7 04 24 70 71 10 f0 	movl   $0xf0107170,(%esp)
f01007fd:	e8 24 37 00 00       	call   f0103f26 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100802:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100809:	00 
f010080a:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100811:	f0 
f0100812:	c7 04 24 98 71 10 f0 	movl   $0xf0107198,(%esp)
f0100819:	e8 08 37 00 00       	call   f0103f26 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010081e:	c7 44 24 08 86 6d 10 	movl   $0x106d86,0x8(%esp)
f0100825:	00 
f0100826:	c7 44 24 04 86 6d 10 	movl   $0xf0106d86,0x4(%esp)
f010082d:	f0 
f010082e:	c7 04 24 bc 71 10 f0 	movl   $0xf01071bc,(%esp)
f0100835:	e8 ec 36 00 00       	call   f0103f26 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010083a:	c7 44 24 08 5c ff 1e 	movl   $0x1eff5c,0x8(%esp)
f0100841:	00 
f0100842:	c7 44 24 04 5c ff 1e 	movl   $0xf01eff5c,0x4(%esp)
f0100849:	f0 
f010084a:	c7 04 24 e0 71 10 f0 	movl   $0xf01071e0,(%esp)
f0100851:	e8 d0 36 00 00       	call   f0103f26 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100856:	c7 44 24 08 08 20 23 	movl   $0x232008,0x8(%esp)
f010085d:	00 
f010085e:	c7 44 24 04 08 20 23 	movl   $0xf0232008,0x4(%esp)
f0100865:	f0 
f0100866:	c7 04 24 04 72 10 f0 	movl   $0xf0107204,(%esp)
f010086d:	e8 b4 36 00 00       	call   f0103f26 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100872:	b8 07 24 23 f0       	mov    $0xf0232407,%eax
f0100877:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f010087c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100881:	89 c2                	mov    %eax,%edx
f0100883:	85 c0                	test   %eax,%eax
f0100885:	79 06                	jns    f010088d <mon_kerninfo+0xb1>
f0100887:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010088d:	c1 fa 0a             	sar    $0xa,%edx
f0100890:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100894:	c7 04 24 28 72 10 f0 	movl   $0xf0107228,(%esp)
f010089b:	e8 86 36 00 00       	call   f0103f26 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a5:	c9                   	leave  
f01008a6:	c3                   	ret    

f01008a7 <mon_help>:
		return -1;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008a7:	55                   	push   %ebp
f01008a8:	89 e5                	mov    %esp,%ebp
f01008aa:	53                   	push   %ebx
f01008ab:	83 ec 14             	sub    $0x14,%esp
f01008ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008b3:	8b 83 44 73 10 f0    	mov    -0xfef8cbc(%ebx),%eax
f01008b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008bd:	8b 83 40 73 10 f0    	mov    -0xfef8cc0(%ebx),%eax
f01008c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c7:	c7 04 24 a9 70 10 f0 	movl   $0xf01070a9,(%esp)
f01008ce:	e8 53 36 00 00       	call   f0103f26 <cprintf>
f01008d3:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008d6:	83 fb 3c             	cmp    $0x3c,%ebx
f01008d9:	75 d8                	jne    f01008b3 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008db:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e0:	83 c4 14             	add    $0x14,%esp
f01008e3:	5b                   	pop    %ebx
f01008e4:	5d                   	pop    %ebp
f01008e5:	c3                   	ret    

f01008e6 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e6:	55                   	push   %ebp
f01008e7:	89 e5                	mov    %esp,%ebp
f01008e9:	57                   	push   %edi
f01008ea:	56                   	push   %esi
f01008eb:	53                   	push   %ebx
f01008ec:	83 ec 6c             	sub    $0x6c,%esp
	// Your code here.
	
	int bt_cnt = 0;
	struct Eipdebuginfo eip_info;
	int* pre_ebp = (int *)read_ebp();
f01008ef:	89 eb                	mov    %ebp,%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
f01008f1:	c7 04 24 b2 70 10 f0 	movl   $0xf01070b2,(%esp)
f01008f8:	e8 29 36 00 00       	call   f0103f26 <cprintf>
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	int bt_cnt = 0;
f01008fd:	bf 00 00 00 00       	mov    $0x0,%edi
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f0100902:	eb 71                	jmp    f0100975 <mon_backtrace+0x8f>
		bt_cnt++;
f0100904:	47                   	inc    %edi
		eip = (int)*(pre_ebp+1);
f0100905:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip((uintptr_t)eip, &eip_info);
f0100908:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010090b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090f:	89 34 24             	mov    %esi,(%esp)
f0100912:	e8 b2 4c 00 00       	call   f01055c9 <debuginfo_eip>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
f0100917:	89 f0                	mov    %esi,%eax
f0100919:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010091c:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100920:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100923:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100927:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010092a:	89 44 24 28          	mov    %eax,0x28(%esp)
f010092e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100931:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100935:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100938:	89 44 24 20          	mov    %eax,0x20(%esp)
f010093c:	8b 43 18             	mov    0x18(%ebx),%eax
f010093f:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100943:	8b 43 14             	mov    0x14(%ebx),%eax
f0100946:	89 44 24 18          	mov    %eax,0x18(%esp)
f010094a:	8b 43 10             	mov    0x10(%ebx),%eax
f010094d:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100951:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100954:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100958:	8b 43 08             	mov    0x8(%ebx),%eax
f010095b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010095f:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100963:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100967:	c7 04 24 54 72 10 f0 	movl   $0xf0107254,(%esp)
f010096e:	e8 b3 35 00 00       	call   f0103f26 <cprintf>
		
		pre_ebp = (int *)*pre_ebp;
f0100973:	8b 1b                	mov    (%ebx),%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f0100975:	85 db                	test   %ebx,%ebx
f0100977:	75 8b                	jne    f0100904 <mon_backtrace+0x1e>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
		
		pre_ebp = (int *)*pre_ebp;
	}
	return bt_cnt;
}
f0100979:	89 f8                	mov    %edi,%eax
f010097b:	83 c4 6c             	add    $0x6c,%esp
f010097e:	5b                   	pop    %ebx
f010097f:	5e                   	pop    %esi
f0100980:	5f                   	pop    %edi
f0100981:	5d                   	pop    %ebp
f0100982:	c3                   	ret    

f0100983 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100983:	55                   	push   %ebp
f0100984:	89 e5                	mov    %esp,%ebp
f0100986:	57                   	push   %edi
f0100987:	56                   	push   %esi
f0100988:	53                   	push   %ebx
f0100989:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010098c:	c7 04 24 9c 72 10 f0 	movl   $0xf010729c,(%esp)
f0100993:	e8 8e 35 00 00       	call   f0103f26 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100998:	c7 04 24 c0 72 10 f0 	movl   $0xf01072c0,(%esp)
f010099f:	e8 82 35 00 00       	call   f0103f26 <cprintf>

	if (tf != NULL)
f01009a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009a8:	74 0b                	je     f01009b5 <monitor+0x32>
		print_trapframe(tf);
f01009aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01009ad:	89 04 24             	mov    %eax,(%esp)
f01009b0:	e8 75 3b 00 00       	call   f010452a <print_trapframe>
	
	while (1) {
		buf = readline("K> ");
f01009b5:	c7 04 24 c4 70 10 f0 	movl   $0xf01070c4,(%esp)
f01009bc:	e8 9f 54 00 00       	call   f0105e60 <readline>
f01009c1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009c3:	85 c0                	test   %eax,%eax
f01009c5:	74 ee                	je     f01009b5 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009c7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ce:	be 00 00 00 00       	mov    $0x0,%esi
f01009d3:	eb 04                	jmp    f01009d9 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009d5:	c6 03 00             	movb   $0x0,(%ebx)
f01009d8:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009d9:	8a 03                	mov    (%ebx),%al
f01009db:	84 c0                	test   %al,%al
f01009dd:	74 5e                	je     f0100a3d <monitor+0xba>
f01009df:	0f be c0             	movsbl %al,%eax
f01009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e6:	c7 04 24 c8 70 10 f0 	movl   $0xf01070c8,(%esp)
f01009ed:	e8 73 56 00 00       	call   f0106065 <strchr>
f01009f2:	85 c0                	test   %eax,%eax
f01009f4:	75 df                	jne    f01009d5 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01009f6:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009f9:	74 42                	je     f0100a3d <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009fb:	83 fe 0f             	cmp    $0xf,%esi
f01009fe:	75 16                	jne    f0100a16 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a00:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a07:	00 
f0100a08:	c7 04 24 cd 70 10 f0 	movl   $0xf01070cd,(%esp)
f0100a0f:	e8 12 35 00 00       	call   f0103f26 <cprintf>
f0100a14:	eb 9f                	jmp    f01009b5 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a16:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a1a:	46                   	inc    %esi
f0100a1b:	eb 01                	jmp    f0100a1e <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a1d:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a1e:	8a 03                	mov    (%ebx),%al
f0100a20:	84 c0                	test   %al,%al
f0100a22:	74 b5                	je     f01009d9 <monitor+0x56>
f0100a24:	0f be c0             	movsbl %al,%eax
f0100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2b:	c7 04 24 c8 70 10 f0 	movl   $0xf01070c8,(%esp)
f0100a32:	e8 2e 56 00 00       	call   f0106065 <strchr>
f0100a37:	85 c0                	test   %eax,%eax
f0100a39:	74 e2                	je     f0100a1d <monitor+0x9a>
f0100a3b:	eb 9c                	jmp    f01009d9 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100a3d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a44:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a45:	85 f6                	test   %esi,%esi
f0100a47:	0f 84 68 ff ff ff    	je     f01009b5 <monitor+0x32>
f0100a4d:	bb 40 73 10 f0       	mov    $0xf0107340,%ebx
f0100a52:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a57:	8b 03                	mov    (%ebx),%eax
f0100a59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a5d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a60:	89 04 24             	mov    %eax,(%esp)
f0100a63:	e8 aa 55 00 00       	call   f0106012 <strcmp>
f0100a68:	85 c0                	test   %eax,%eax
f0100a6a:	75 24                	jne    f0100a90 <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100a6c:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a6f:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a72:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a76:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a79:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a7d:	89 34 24             	mov    %esi,(%esp)
f0100a80:	ff 14 85 48 73 10 f0 	call   *-0xfef8cb8(,%eax,4)
		print_trapframe(tf);
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a87:	85 c0                	test   %eax,%eax
f0100a89:	78 26                	js     f0100ab1 <monitor+0x12e>
f0100a8b:	e9 25 ff ff ff       	jmp    f01009b5 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a90:	47                   	inc    %edi
f0100a91:	83 c3 0c             	add    $0xc,%ebx
f0100a94:	83 ff 05             	cmp    $0x5,%edi
f0100a97:	75 be                	jne    f0100a57 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a99:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa0:	c7 04 24 ea 70 10 f0 	movl   $0xf01070ea,(%esp)
f0100aa7:	e8 7a 34 00 00       	call   f0103f26 <cprintf>
f0100aac:	e9 04 ff ff ff       	jmp    f01009b5 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ab1:	83 c4 5c             	add    $0x5c,%esp
f0100ab4:	5b                   	pop    %ebx
f0100ab5:	5e                   	pop    %esi
f0100ab6:	5f                   	pop    %edi
f0100ab7:	5d                   	pop    %ebp
f0100ab8:	c3                   	ret    
f0100ab9:	00 00                	add    %al,(%eax)
	...

f0100abc <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ac2:	89 d1                	mov    %edx,%ecx
f0100ac4:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ac7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100aca:	a8 01                	test   $0x1,%al
f0100acc:	74 4d                	je     f0100b1b <check_va2pa+0x5f>
	  return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ace:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ad3:	89 c1                	mov    %eax,%ecx
f0100ad5:	c1 e9 0c             	shr    $0xc,%ecx
f0100ad8:	3b 0d 88 0e 1f f0    	cmp    0xf01f0e88,%ecx
f0100ade:	72 20                	jb     f0100b00 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ae0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ae4:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0100aeb:	f0 
f0100aec:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0100af3:	00 
f0100af4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100afb:	e8 40 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b00:	c1 ea 0c             	shr    $0xc,%edx
f0100b03:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b09:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b10:	a8 01                	test   $0x1,%al
f0100b12:	74 0e                	je     f0100b22 <check_va2pa+0x66>
	  return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b19:	eb 0c                	jmp    f0100b27 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
	  return ~0;
f0100b1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b20:	eb 05                	jmp    f0100b27 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
	  return ~0;
f0100b22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b27:	c9                   	leave  
f0100b28:	c3                   	ret    

f0100b29 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b29:	55                   	push   %ebp
f0100b2a:	89 e5                	mov    %esp,%ebp
f0100b2c:	53                   	push   %ebx
f0100b2d:	83 ec 24             	sub    $0x24,%esp
f0100b30:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b32:	83 3d 3c 02 1f f0 00 	cmpl   $0x0,0xf01f023c
f0100b39:	75 0f                	jne    f0100b4a <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b3b:	b8 07 30 23 f0       	mov    $0xf0233007,%eax
f0100b40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b45:	a3 3c 02 1f f0       	mov    %eax,0xf01f023c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	// first end is at address 0xf011b970, result is 0xf011c100, use 107KB for kernel 
	if (n > 0) {
f0100b4a:	85 d2                	test   %edx,%edx
f0100b4c:	74 55                	je     f0100ba3 <boot_alloc+0x7a>
		result = nextfree;
f0100b4e:	a1 3c 02 1f f0       	mov    0xf01f023c,%eax
		nextfree = ROUNDUP((char *)(nextfree+n), PGSIZE);
f0100b53:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b5a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b60:	89 15 3c 02 1f f0    	mov    %edx,0xf01f023c
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE ){
f0100b66:	8b 0d 88 0e 1f f0    	mov    0xf01f0e88,%ecx
f0100b6c:	c1 e1 0c             	shl    $0xc,%ecx
f0100b6f:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100b75:	39 cb                	cmp    %ecx,%ebx
f0100b77:	76 2f                	jbe    f0100ba8 <boot_alloc+0x7f>
			panic("Cannot alloc more physical memory. Requested %dK, Available %dK\n", (uint32_t)nextfree/1024, npages*PGSIZE/1024);
f0100b79:	c1 e9 0a             	shr    $0xa,%ecx
f0100b7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100b80:	c1 ea 0a             	shr    $0xa,%edx
f0100b83:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b87:	c7 44 24 08 7c 73 10 	movl   $0xf010737c,0x8(%esp)
f0100b8e:	f0 
f0100b8f:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f0100b96:	00 
f0100b97:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100b9e:	e8 9d f4 ff ff       	call   f0100040 <_panic>
		}
		return result;
	}
	return nextfree;
f0100ba3:	a1 3c 02 1f f0       	mov    0xf01f023c,%eax
}
f0100ba8:	83 c4 24             	add    $0x24,%esp
f0100bab:	5b                   	pop    %ebx
f0100bac:	5d                   	pop    %ebp
f0100bad:	c3                   	ret    

f0100bae <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bae:	55                   	push   %ebp
f0100baf:	89 e5                	mov    %esp,%ebp
f0100bb1:	56                   	push   %esi
f0100bb2:	53                   	push   %ebx
f0100bb3:	83 ec 10             	sub    $0x10,%esp
f0100bb6:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bb8:	89 04 24             	mov    %eax,(%esp)
f0100bbb:	e8 20 32 00 00       	call   f0103de0 <mc146818_read>
f0100bc0:	89 c6                	mov    %eax,%esi
f0100bc2:	43                   	inc    %ebx
f0100bc3:	89 1c 24             	mov    %ebx,(%esp)
f0100bc6:	e8 15 32 00 00       	call   f0103de0 <mc146818_read>
f0100bcb:	c1 e0 08             	shl    $0x8,%eax
f0100bce:	09 f0                	or     %esi,%eax
}
f0100bd0:	83 c4 10             	add    $0x10,%esp
f0100bd3:	5b                   	pop    %ebx
f0100bd4:	5e                   	pop    %esi
f0100bd5:	5d                   	pop    %ebp
f0100bd6:	c3                   	ret    

f0100bd7 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bd7:	55                   	push   %ebp
f0100bd8:	89 e5                	mov    %esp,%ebp
f0100bda:	57                   	push   %edi
f0100bdb:	56                   	push   %esi
f0100bdc:	53                   	push   %ebx
f0100bdd:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be0:	3c 01                	cmp    $0x1,%al
f0100be2:	19 f6                	sbb    %esi,%esi
f0100be4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100bea:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100beb:	8b 15 40 02 1f f0    	mov    0xf01f0240,%edx
f0100bf1:	85 d2                	test   %edx,%edx
f0100bf3:	75 1c                	jne    f0100c11 <check_page_free_list+0x3a>
	  panic("'page_free_list' is a null pointer!");
f0100bf5:	c7 44 24 08 c0 73 10 	movl   $0xf01073c0,0x8(%esp)
f0100bfc:	f0 
f0100bfd:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0100c04:	00 
f0100c05:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100c0c:	e8 2f f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100c11:	84 c0                	test   %al,%al
f0100c13:	74 4b                	je     f0100c60 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c15:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100c18:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c1b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c1e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c21:	89 d0                	mov    %edx,%eax
f0100c23:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f0100c29:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c2c:	c1 e8 16             	shr    $0x16,%eax
f0100c2f:	39 c6                	cmp    %eax,%esi
f0100c31:	0f 96 c0             	setbe  %al
f0100c34:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c37:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100c3b:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c3d:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c41:	8b 12                	mov    (%edx),%edx
f0100c43:	85 d2                	test   %edx,%edx
f0100c45:	75 da                	jne    f0100c21 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c47:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c50:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c56:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c58:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c5b:	a3 40 02 1f f0       	mov    %eax,0xf01f0240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c60:	8b 1d 40 02 1f f0    	mov    0xf01f0240,%ebx
f0100c66:	eb 63                	jmp    f0100ccb <check_page_free_list+0xf4>
f0100c68:	89 d8                	mov    %ebx,%eax
f0100c6a:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f0100c70:	c1 f8 03             	sar    $0x3,%eax
f0100c73:	c1 e0 0c             	shl    $0xc,%eax
	  if (PDX(page2pa(pp)) < pdx_limit)
f0100c76:	89 c2                	mov    %eax,%edx
f0100c78:	c1 ea 16             	shr    $0x16,%edx
f0100c7b:	39 d6                	cmp    %edx,%esi
f0100c7d:	76 4a                	jbe    f0100cc9 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c7f:	89 c2                	mov    %eax,%edx
f0100c81:	c1 ea 0c             	shr    $0xc,%edx
f0100c84:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f0100c8a:	72 20                	jb     f0100cac <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c90:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0100c97:	f0 
f0100c98:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c9f:	00 
f0100ca0:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0100ca7:	e8 94 f3 ff ff       	call   f0100040 <_panic>
		memset(page2kva(pp), 0x97, 128);
f0100cac:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100cb3:	00 
f0100cb4:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100cbb:	00 
	return (void *)(pa + KERNBASE);
f0100cbc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cc1:	89 04 24             	mov    %eax,(%esp)
f0100cc4:	e8 d1 53 00 00       	call   f010609a <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cc9:	8b 1b                	mov    (%ebx),%ebx
f0100ccb:	85 db                	test   %ebx,%ebx
f0100ccd:	75 99                	jne    f0100c68 <check_page_free_list+0x91>
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ccf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cd4:	e8 50 fe ff ff       	call   f0100b29 <boot_alloc>
f0100cd9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cdc:	8b 15 40 02 1f f0    	mov    0xf01f0240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ce2:	8b 0d 90 0e 1f f0    	mov    0xf01f0e90,%ecx
		assert(pp < pages + npages);
f0100ce8:	a1 88 0e 1f f0       	mov    0xf01f0e88,%eax
f0100ced:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cf0:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cf3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cf6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cf9:	be 00 00 00 00       	mov    $0x0,%esi
f0100cfe:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d01:	e9 c4 01 00 00       	jmp    f0100eca <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d06:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100d09:	73 24                	jae    f0100d2f <check_page_free_list+0x158>
f0100d0b:	c7 44 24 0c d7 7c 10 	movl   $0xf0107cd7,0xc(%esp)
f0100d12:	f0 
f0100d13:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100d1a:	f0 
f0100d1b:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100d22:	00 
f0100d23:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100d2a:	e8 11 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d2f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d32:	72 24                	jb     f0100d58 <check_page_free_list+0x181>
f0100d34:	c7 44 24 0c f8 7c 10 	movl   $0xf0107cf8,0xc(%esp)
f0100d3b:	f0 
f0100d3c:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100d43:	f0 
f0100d44:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100d4b:	00 
f0100d4c:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100d53:	e8 e8 f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d58:	89 d0                	mov    %edx,%eax
f0100d5a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d5d:	a8 07                	test   $0x7,%al
f0100d5f:	74 24                	je     f0100d85 <check_page_free_list+0x1ae>
f0100d61:	c7 44 24 0c e4 73 10 	movl   $0xf01073e4,0xc(%esp)
f0100d68:	f0 
f0100d69:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100d70:	f0 
f0100d71:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0100d78:	00 
f0100d79:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100d80:	e8 bb f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d85:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d88:	c1 e0 0c             	shl    $0xc,%eax
f0100d8b:	75 24                	jne    f0100db1 <check_page_free_list+0x1da>
f0100d8d:	c7 44 24 0c 0c 7d 10 	movl   $0xf0107d0c,0xc(%esp)
f0100d94:	f0 
f0100d95:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100d9c:	f0 
f0100d9d:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100da4:	00 
f0100da5:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100dac:	e8 8f f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100db1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100db6:	75 24                	jne    f0100ddc <check_page_free_list+0x205>
f0100db8:	c7 44 24 0c 1d 7d 10 	movl   $0xf0107d1d,0xc(%esp)
f0100dbf:	f0 
f0100dc0:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100dc7:	f0 
f0100dc8:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0100dcf:	00 
f0100dd0:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100dd7:	e8 64 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ddc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100de1:	75 24                	jne    f0100e07 <check_page_free_list+0x230>
f0100de3:	c7 44 24 0c 18 74 10 	movl   $0xf0107418,0xc(%esp)
f0100dea:	f0 
f0100deb:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100df2:	f0 
f0100df3:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0100dfa:	00 
f0100dfb:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100e02:	e8 39 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e07:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e0c:	75 24                	jne    f0100e32 <check_page_free_list+0x25b>
f0100e0e:	c7 44 24 0c 36 7d 10 	movl   $0xf0107d36,0xc(%esp)
f0100e15:	f0 
f0100e16:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100e1d:	f0 
f0100e1e:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0100e25:	00 
f0100e26:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100e2d:	e8 0e f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e32:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e37:	76 59                	jbe    f0100e92 <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e39:	89 c1                	mov    %eax,%ecx
f0100e3b:	c1 e9 0c             	shr    $0xc,%ecx
f0100e3e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e41:	77 20                	ja     f0100e63 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e47:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0100e4e:	f0 
f0100e4f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e56:	00 
f0100e57:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0100e5e:	e8 dd f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e63:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e69:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e6c:	76 24                	jbe    f0100e92 <check_page_free_list+0x2bb>
f0100e6e:	c7 44 24 0c 3c 74 10 	movl   $0xf010743c,0xc(%esp)
f0100e75:	f0 
f0100e76:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100e7d:	f0 
f0100e7e:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100e85:	00 
f0100e86:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100e8d:	e8 ae f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e92:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e97:	75 24                	jne    f0100ebd <check_page_free_list+0x2e6>
f0100e99:	c7 44 24 0c 50 7d 10 	movl   $0xf0107d50,0xc(%esp)
f0100ea0:	f0 
f0100ea1:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100ea8:	f0 
f0100ea9:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100eb0:	00 
f0100eb1:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100eb8:	e8 83 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100ebd:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ec2:	77 03                	ja     f0100ec7 <check_page_free_list+0x2f0>
		  ++nfree_basemem;
f0100ec4:	46                   	inc    %esi
f0100ec5:	eb 01                	jmp    f0100ec8 <check_page_free_list+0x2f1>
		else
		  ++nfree_extmem;
f0100ec7:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ec8:	8b 12                	mov    (%edx),%edx
f0100eca:	85 d2                	test   %edx,%edx
f0100ecc:	0f 85 34 fe ff ff    	jne    f0100d06 <check_page_free_list+0x12f>
		  ++nfree_basemem;
		else
		  ++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ed2:	85 f6                	test   %esi,%esi
f0100ed4:	7f 24                	jg     f0100efa <check_page_free_list+0x323>
f0100ed6:	c7 44 24 0c 6d 7d 10 	movl   $0xf0107d6d,0xc(%esp)
f0100edd:	f0 
f0100ede:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100ee5:	f0 
f0100ee6:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100eed:	00 
f0100eee:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100ef5:	e8 46 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100efa:	85 db                	test   %ebx,%ebx
f0100efc:	7f 24                	jg     f0100f22 <check_page_free_list+0x34b>
f0100efe:	c7 44 24 0c 7f 7d 10 	movl   $0xf0107d7f,0xc(%esp)
f0100f05:	f0 
f0100f06:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100f0d:	f0 
f0100f0e:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0100f15:	00 
f0100f16:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100f1d:	e8 1e f1 ff ff       	call   f0100040 <_panic>
	
	//cprintf("check_page_free_list() succeeded!\n");
}
f0100f22:	83 c4 4c             	add    $0x4c,%esp
f0100f25:	5b                   	pop    %ebx
f0100f26:	5e                   	pop    %esi
f0100f27:	5f                   	pop    %edi
f0100f28:	5d                   	pop    %ebp
f0100f29:	c3                   	ret    

f0100f2a <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f2a:	55                   	push   %ebp
f0100f2b:	89 e5                	mov    %esp,%ebp
f0100f2d:	57                   	push   %edi
f0100f2e:	56                   	push   %esi
f0100f2f:	53                   	push   %ebx
f0100f30:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	uint32_t num_alloc = ((uint32_t)boot_alloc(0)-KERNBASE)/PGSIZE;
f0100f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f38:	e8 ec fb ff ff       	call   f0100b29 <boot_alloc>
f0100f3d:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f42:	c1 e8 0c             	shr    $0xc,%eax
	size_t i;

	for(i = 0; i < npages; ++i) {
		if((i == 0)||
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100f45:	8b 0d 38 02 1f f0    	mov    0xf01f0238,%ecx
f0100f4b:	8d 59 60             	lea    0x60(%ecx),%ebx
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f4e:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f53:	ba 00 00 00 00       	mov    $0x0,%edx
		if((i == 0)||
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
					// alloc by kernel, kernel alloc pages and kern_pgdir on stack
					// num_alloc isn't all pages used, it is just memory used by kernel
					( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc )||(i == MPENTRY_PADDR/PGSIZE)){
f0100f58:	01 d8                	add    %ebx,%eax
f0100f5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f5d:	eb 4a                	jmp    f0100fa9 <page_init+0x7f>
		if((i == 0)||
f0100f5f:	85 d2                	test   %edx,%edx
f0100f61:	74 18                	je     f0100f7b <page_init+0x51>
f0100f63:	39 ca                	cmp    %ecx,%edx
f0100f65:	72 06                	jb     f0100f6d <page_init+0x43>
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100f67:	39 da                	cmp    %ebx,%edx
f0100f69:	72 10                	jb     f0100f7b <page_init+0x51>
f0100f6b:	eb 04                	jmp    f0100f71 <page_init+0x47>
f0100f6d:	39 da                	cmp    %ebx,%edx
f0100f6f:	72 05                	jb     f0100f76 <page_init+0x4c>
					// alloc by kernel, kernel alloc pages and kern_pgdir on stack
					// num_alloc isn't all pages used, it is just memory used by kernel
					( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc )||(i == MPENTRY_PADDR/PGSIZE)){
f0100f71:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100f74:	72 05                	jb     f0100f7b <page_init+0x51>
f0100f76:	83 fa 07             	cmp    $0x7,%edx
f0100f79:	75 0e                	jne    f0100f89 <page_init+0x5f>
			pages[i].pp_ref = 1;	
f0100f7b:	a1 90 0e 1f f0       	mov    0xf01f0e90,%eax
f0100f80:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
f0100f87:	eb 1f                	jmp    f0100fa8 <page_init+0x7e>
		}else {
			pages[i].pp_ref = 0;
f0100f89:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100f90:	8b 35 90 0e 1f f0    	mov    0xf01f0e90,%esi
f0100f96:	66 c7 44 06 04 00 00 	movw   $0x0,0x4(%esi,%eax,1)
			pages[i].pp_link = page_free_list;
f0100f9d:	89 3c 06             	mov    %edi,(%esi,%eax,1)
			page_free_list = &pages[i];
f0100fa0:	89 c7                	mov    %eax,%edi
f0100fa2:	03 3d 90 0e 1f f0    	add    0xf01f0e90,%edi
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100fa8:	42                   	inc    %edx
f0100fa9:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f0100faf:	72 ae                	jb     f0100f5f <page_init+0x35>
f0100fb1:	89 3d 40 02 1f f0    	mov    %edi,0xf01f0240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100fb7:	83 c4 1c             	add    $0x1c,%esp
f0100fba:	5b                   	pop    %ebx
f0100fbb:	5e                   	pop    %esi
f0100fbc:	5f                   	pop    %edi
f0100fbd:	5d                   	pop    %ebp
f0100fbe:	c3                   	ret    

f0100fbf <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fbf:	55                   	push   %ebp
f0100fc0:	89 e5                	mov    %esp,%ebp
f0100fc2:	53                   	push   %ebx
f0100fc3:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo* temp_page;
	if (page_free_list) {
f0100fc6:	8b 1d 40 02 1f f0    	mov    0xf01f0240,%ebx
f0100fcc:	85 db                	test   %ebx,%ebx
f0100fce:	0f 84 96 00 00 00    	je     f010106a <page_alloc+0xab>
		temp_page = page_free_list;
		assert(temp_page->pp_ref == 0);
f0100fd4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100fd9:	74 24                	je     f0100fff <page_alloc+0x40>
f0100fdb:	c7 44 24 0c 90 7d 10 	movl   $0xf0107d90,0xc(%esp)
f0100fe2:	f0 
f0100fe3:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0100fea:	f0 
f0100feb:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f0100ff2:	00 
f0100ff3:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0100ffa:	e8 41 f0 ff ff       	call   f0100040 <_panic>
		page_free_list = page_free_list->pp_link;
f0100fff:	8b 03                	mov    (%ebx),%eax
f0101001:	a3 40 02 1f f0       	mov    %eax,0xf01f0240
		temp_page->pp_link = NULL;
f0101006:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	} else {
		return NULL;
	} 
	// temp_page is a Pageinfo, i think page2kva is actual page
	if (alloc_flags & ALLOC_ZERO) {
f010100c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101010:	74 58                	je     f010106a <page_alloc+0xab>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101012:	89 d8                	mov    %ebx,%eax
f0101014:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f010101a:	c1 f8 03             	sar    $0x3,%eax
f010101d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101020:	89 c2                	mov    %eax,%edx
f0101022:	c1 ea 0c             	shr    $0xc,%edx
f0101025:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f010102b:	72 20                	jb     f010104d <page_alloc+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101031:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0101038:	f0 
f0101039:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101040:	00 
f0101041:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0101048:	e8 f3 ef ff ff       	call   f0100040 <_panic>
		memset(page2kva(temp_page), 0, PGSIZE); 
f010104d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101054:	00 
f0101055:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010105c:	00 
	return (void *)(pa + KERNBASE);
f010105d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101062:	89 04 24             	mov    %eax,(%esp)
f0101065:	e8 30 50 00 00       	call   f010609a <memset>
	}

	return temp_page;
}
f010106a:	89 d8                	mov    %ebx,%eax
f010106c:	83 c4 14             	add    $0x14,%esp
f010106f:	5b                   	pop    %ebx
f0101070:	5d                   	pop    %ebp
f0101071:	c3                   	ret    

f0101072 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101072:	55                   	push   %ebp
f0101073:	89 e5                	mov    %esp,%ebp
f0101075:	83 ec 18             	sub    $0x18,%esp
f0101078:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f010107b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101080:	74 1c                	je     f010109e <page_free+0x2c>
		panic("Still using page");
f0101082:	c7 44 24 08 a7 7d 10 	movl   $0xf0107da7,0x8(%esp)
f0101089:	f0 
f010108a:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0101091:	00 
f0101092:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101099:	e8 a2 ef ff ff       	call   f0100040 <_panic>
	}
	if (pp->pp_link != NULL) {
f010109e:	83 38 00             	cmpl   $0x0,(%eax)
f01010a1:	74 1c                	je     f01010bf <page_free+0x4d>
		panic("free page still have a link");
f01010a3:	c7 44 24 08 b8 7d 10 	movl   $0xf0107db8,0x8(%esp)
f01010aa:	f0 
f01010ab:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f01010b2:	00 
f01010b3:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01010ba:	e8 81 ef ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f01010bf:	8b 15 40 02 1f f0    	mov    0xf01f0240,%edx
f01010c5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010c7:	a3 40 02 1f f0       	mov    %eax,0xf01f0240
}
f01010cc:	c9                   	leave  
f01010cd:	c3                   	ret    

f01010ce <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01010ce:	55                   	push   %ebp
f01010cf:	89 e5                	mov    %esp,%ebp
f01010d1:	83 ec 18             	sub    $0x18,%esp
f01010d4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01010d7:	8b 50 04             	mov    0x4(%eax),%edx
f01010da:	4a                   	dec    %edx
f01010db:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010df:	66 85 d2             	test   %dx,%dx
f01010e2:	75 08                	jne    f01010ec <page_decref+0x1e>
	  page_free(pp);
f01010e4:	89 04 24             	mov    %eax,(%esp)
f01010e7:	e8 86 ff ff ff       	call   f0101072 <page_free>
}
f01010ec:	c9                   	leave  
f01010ed:	c3                   	ret    

f01010ee <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01010ee:	55                   	push   %ebp
f01010ef:	89 e5                	mov    %esp,%ebp
f01010f1:	57                   	push   %edi
f01010f2:	56                   	push   %esi
f01010f3:	53                   	push   %ebx
f01010f4:	83 ec 1c             	sub    $0x1c,%esp
f01010f7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pde_t* pgdir_entry = &pgdir[PDX(va)];
f01010fa:	89 fb                	mov    %edi,%ebx
f01010fc:	c1 eb 16             	shr    $0x16,%ebx
f01010ff:	c1 e3 02             	shl    $0x2,%ebx
f0101102:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pgtb_entry = NULL;
	struct PageInfo * pg = NULL;

	if (!(*pgdir_entry & PTE_P)){
f0101105:	f6 03 01             	testb  $0x1,(%ebx)
f0101108:	0f 85 8b 00 00 00    	jne    f0101199 <pgdir_walk+0xab>
		if(create){
f010110e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101112:	0f 84 c7 00 00 00    	je     f01011df <pgdir_walk+0xf1>
			pg = page_alloc(1);
f0101118:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010111f:	e8 9b fe ff ff       	call   f0100fbf <page_alloc>
f0101124:	89 c6                	mov    %eax,%esi
			if (!pg) 
f0101126:	85 c0                	test   %eax,%eax
f0101128:	0f 84 b8 00 00 00    	je     f01011e6 <pgdir_walk+0xf8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010112e:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f0101134:	c1 f8 03             	sar    $0x3,%eax
f0101137:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010113a:	89 c2                	mov    %eax,%edx
f010113c:	c1 ea 0c             	shr    $0xc,%edx
f010113f:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f0101145:	72 20                	jb     f0101167 <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101147:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010114b:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0101152:	f0 
f0101153:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010115a:	00 
f010115b:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0101162:	e8 d9 ee ff ff       	call   f0100040 <_panic>
			  return NULL;
			memset(page2kva(pg), 0, PGSIZE);
f0101167:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010116e:	00 
f010116f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101176:	00 
	return (void *)(pa + KERNBASE);
f0101177:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010117c:	89 04 24             	mov    %eax,(%esp)
f010117f:	e8 16 4f 00 00       	call   f010609a <memset>
			pg->pp_ref += 1;
f0101184:	66 ff 46 04          	incw   0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101188:	2b 35 90 0e 1f f0    	sub    0xf01f0e90,%esi
f010118e:	c1 fe 03             	sar    $0x3,%esi
f0101191:	c1 e6 0c             	shl    $0xc,%esi
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
f0101194:	83 ce 07             	or     $0x7,%esi
f0101197:	89 33                	mov    %esi,(%ebx)
		}else{
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
f0101199:	8b 03                	mov    (%ebx),%eax
f010119b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011a0:	89 c2                	mov    %eax,%edx
f01011a2:	c1 ea 0c             	shr    $0xc,%edx
f01011a5:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f01011ab:	72 20                	jb     f01011cd <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011b1:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f01011b8:	f0 
f01011b9:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f01011c0:	00 
f01011c1:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01011c8:	e8 73 ee ff ff       	call   f0100040 <_panic>
	return &pgtb_entry[PTX(va)];
f01011cd:	c1 ef 0a             	shr    $0xa,%edi
f01011d0:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01011d6:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
f01011dd:	eb 0c                	jmp    f01011eb <pgdir_walk+0xfd>
			  return NULL;
			memset(page2kva(pg), 0, PGSIZE);
			pg->pp_ref += 1;
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
		}else{
			return NULL;
f01011df:	b8 00 00 00 00       	mov    $0x0,%eax
f01011e4:	eb 05                	jmp    f01011eb <pgdir_walk+0xfd>

	if (!(*pgdir_entry & PTE_P)){
		if(create){
			pg = page_alloc(1);
			if (!pg) 
			  return NULL;
f01011e6:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
	return &pgtb_entry[PTX(va)];
}
f01011eb:	83 c4 1c             	add    $0x1c,%esp
f01011ee:	5b                   	pop    %ebx
f01011ef:	5e                   	pop    %esi
f01011f0:	5f                   	pop    %edi
f01011f1:	5d                   	pop    %ebp
f01011f2:	c3                   	ret    

f01011f3 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011f3:	55                   	push   %ebp
f01011f4:	89 e5                	mov    %esp,%ebp
f01011f6:	57                   	push   %edi
f01011f7:	56                   	push   %esi
f01011f8:	53                   	push   %ebx
f01011f9:	83 ec 2c             	sub    $0x2c,%esp
f01011fc:	89 c7                	mov    %eax,%edi
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f01011fe:	c1 e9 0c             	shr    $0xc,%ecx
f0101201:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101204:	89 d3                	mov    %edx,%ebx
f0101206:	be 00 00 00 00       	mov    $0x0,%esi
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f010120b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010120e:	83 c8 01             	or     $0x1,%eax
f0101211:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101214:	8b 45 08             	mov    0x8(%ebp),%eax
f0101217:	29 d0                	sub    %edx,%eax
f0101219:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f010121c:	eb 25                	jmp    f0101243 <boot_map_region+0x50>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
f010121e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101225:	00 
f0101226:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010122a:	89 3c 24             	mov    %edi,(%esp)
f010122d:	e8 bc fe ff ff       	call   f01010ee <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101232:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101235:	01 da                	add    %ebx,%edx
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0101237:	0b 55 e0             	or     -0x20(%ebp),%edx
f010123a:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f010123c:	46                   	inc    %esi
f010123d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101243:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101246:	75 d6                	jne    f010121e <boot_map_region+0x2b>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
	} 
}
f0101248:	83 c4 2c             	add    $0x2c,%esp
f010124b:	5b                   	pop    %ebx
f010124c:	5e                   	pop    %esi
f010124d:	5f                   	pop    %edi
f010124e:	5d                   	pop    %ebp
f010124f:	c3                   	ret    

f0101250 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101250:	55                   	push   %ebp
f0101251:	89 e5                	mov    %esp,%ebp
f0101253:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f0101256:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010125d:	00 
f010125e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101261:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101265:	8b 45 08             	mov    0x8(%ebp),%eax
f0101268:	89 04 24             	mov    %eax,(%esp)
f010126b:	e8 7e fe ff ff       	call   f01010ee <pgdir_walk>
	if (pt_entry && *pt_entry&PTE_P) {
f0101270:	85 c0                	test   %eax,%eax
f0101272:	74 3e                	je     f01012b2 <page_lookup+0x62>
f0101274:	f6 00 01             	testb  $0x1,(%eax)
f0101277:	74 40                	je     f01012b9 <page_lookup+0x69>
		*pte_store = pt_entry;
f0101279:	8b 55 10             	mov    0x10(%ebp),%edx
f010127c:	89 02                	mov    %eax,(%edx)
	}else{
		return NULL;
	}
	return pa2page(PTE_ADDR(*pt_entry));
f010127e:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101280:	c1 e8 0c             	shr    $0xc,%eax
f0101283:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f0101289:	72 1c                	jb     f01012a7 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f010128b:	c7 44 24 08 84 74 10 	movl   $0xf0107484,0x8(%esp)
f0101292:	f0 
f0101293:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010129a:	00 
f010129b:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f01012a2:	e8 99 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012a7:	c1 e0 03             	shl    $0x3,%eax
f01012aa:	03 05 90 0e 1f f0    	add    0xf01f0e90,%eax
f01012b0:	eb 0c                	jmp    f01012be <page_lookup+0x6e>
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
	if (pt_entry && *pt_entry&PTE_P) {
		*pte_store = pt_entry;
	}else{
		return NULL;
f01012b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b7:	eb 05                	jmp    f01012be <page_lookup+0x6e>
f01012b9:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return pa2page(PTE_ADDR(*pt_entry));
}
f01012be:	c9                   	leave  
f01012bf:	c3                   	ret    

f01012c0 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012c0:	55                   	push   %ebp
f01012c1:	89 e5                	mov    %esp,%ebp
f01012c3:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012c6:	e8 fd 53 00 00       	call   f01066c8 <cpunum>
f01012cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01012d2:	29 c2                	sub    %eax,%edx
f01012d4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01012d7:	83 3c 85 28 10 1f f0 	cmpl   $0x0,-0xfe0efd8(,%eax,4)
f01012de:	00 
f01012df:	74 20                	je     f0101301 <tlb_invalidate+0x41>
f01012e1:	e8 e2 53 00 00       	call   f01066c8 <cpunum>
f01012e6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01012ed:	29 c2                	sub    %eax,%edx
f01012ef:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01012f2:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f01012f9:	8b 55 08             	mov    0x8(%ebp),%edx
f01012fc:	39 50 60             	cmp    %edx,0x60(%eax)
f01012ff:	75 06                	jne    f0101307 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101301:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101304:	0f 01 38             	invlpg (%eax)
	  invlpg(va);
}
f0101307:	c9                   	leave  
f0101308:	c3                   	ret    

f0101309 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101309:	55                   	push   %ebp
f010130a:	89 e5                	mov    %esp,%ebp
f010130c:	56                   	push   %esi
f010130d:	53                   	push   %ebx
f010130e:	83 ec 20             	sub    $0x20,%esp
f0101311:	8b 75 08             	mov    0x8(%ebp),%esi
f0101314:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte_store = NULL;
f0101317:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg = page_lookup(pgdir, va, &pte_store); 
f010131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101321:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101325:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101329:	89 34 24             	mov    %esi,(%esp)
f010132c:	e8 1f ff ff ff       	call   f0101250 <page_lookup>
	if (!pg) 
f0101331:	85 c0                	test   %eax,%eax
f0101333:	74 1d                	je     f0101352 <page_remove+0x49>
	  return;
	page_decref(pg);	
f0101335:	89 04 24             	mov    %eax,(%esp)
f0101338:	e8 91 fd ff ff       	call   f01010ce <page_decref>
	tlb_invalidate(pgdir, va);
f010133d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101341:	89 34 24             	mov    %esi,(%esp)
f0101344:	e8 77 ff ff ff       	call   f01012c0 <tlb_invalidate>
	*pte_store = 0;
f0101349:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010134c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f0101352:	83 c4 20             	add    $0x20,%esp
f0101355:	5b                   	pop    %ebx
f0101356:	5e                   	pop    %esi
f0101357:	5d                   	pop    %ebp
f0101358:	c3                   	ret    

f0101359 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101359:	55                   	push   %ebp
f010135a:	89 e5                	mov    %esp,%ebp
f010135c:	57                   	push   %edi
f010135d:	56                   	push   %esi
f010135e:	53                   	push   %ebx
f010135f:	83 ec 1c             	sub    $0x1c,%esp
f0101362:	8b 75 08             	mov    0x8(%ebp),%esi
f0101365:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f0101368:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010136f:	00 
f0101370:	8b 45 10             	mov    0x10(%ebp),%eax
f0101373:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101377:	89 34 24             	mov    %esi,(%esp)
f010137a:	e8 6f fd ff ff       	call   f01010ee <pgdir_walk>
f010137f:	89 c3                	mov    %eax,%ebx
	if (!pg_entry) {
f0101381:	85 c0                	test   %eax,%eax
f0101383:	74 4d                	je     f01013d2 <page_insert+0x79>
		return -E_NO_MEM;
	} 
	pp->pp_ref++;
f0101385:	66 ff 47 04          	incw   0x4(%edi)
	if (*pg_entry & PTE_P){
f0101389:	f6 00 01             	testb  $0x1,(%eax)
f010138c:	74 1e                	je     f01013ac <page_insert+0x53>
		tlb_invalidate(pgdir, va);
f010138e:	8b 45 10             	mov    0x10(%ebp),%eax
f0101391:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101395:	89 34 24             	mov    %esi,(%esp)
f0101398:	e8 23 ff ff ff       	call   f01012c0 <tlb_invalidate>
		page_remove(pgdir, va);
f010139d:	8b 45 10             	mov    0x10(%ebp),%eax
f01013a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013a4:	89 34 24             	mov    %esi,(%esp)
f01013a7:	e8 5d ff ff ff       	call   f0101309 <page_remove>
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
f01013ac:	8b 55 14             	mov    0x14(%ebp),%edx
f01013af:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013b2:	2b 3d 90 0e 1f f0    	sub    0xf01f0e90,%edi
f01013b8:	c1 ff 03             	sar    $0x3,%edi
f01013bb:	c1 e7 0c             	shl    $0xc,%edi
f01013be:	09 d7                	or     %edx,%edi
f01013c0:	89 3b                	mov    %edi,(%ebx)
	pgdir[PDX(va)] |= perm | PTE_P;	
f01013c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01013c5:	c1 e8 16             	shr    $0x16,%eax
f01013c8:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f01013cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01013d0:	eb 05                	jmp    f01013d7 <page_insert+0x7e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
	if (!pg_entry) {
		return -E_NO_MEM;
f01013d2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
	pgdir[PDX(va)] |= perm | PTE_P;	
	return 0;
}
f01013d7:	83 c4 1c             	add    $0x1c,%esp
f01013da:	5b                   	pop    %ebx
f01013db:	5e                   	pop    %esi
f01013dc:	5f                   	pop    %edi
f01013dd:	5d                   	pop    %ebp
f01013de:	c3                   	ret    

f01013df <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013df:	55                   	push   %ebp
f01013e0:	89 e5                	mov    %esp,%ebp
f01013e2:	56                   	push   %esi
f01013e3:	53                   	push   %ebx
f01013e4:	83 ec 10             	sub    $0x10,%esp
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	//panic("mmio_map_region not implemented");
	void* ret = (void*)base;
f01013e7:	8b 1d 00 93 12 f0    	mov    0xf0129300,%ebx
	uint32_t round_size = ROUNDUP(size, PGSIZE); 
f01013ed:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013f0:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f01013f6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (base + round_size >= MMIOLIM){
f01013fc:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01013ff:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101404:	76 1c                	jbe    f0101422 <mmio_map_region+0x43>
		panic("mmio_map_region: map overflow");
f0101406:	c7 44 24 08 d4 7d 10 	movl   $0xf0107dd4,0x8(%esp)
f010140d:	f0 
f010140e:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0101415:	00 
f0101416:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010141d:	e8 1e ec ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, round_size, pa, PTE_PCD|PTE_PWT|PTE_W);
f0101422:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101429:	00 
f010142a:	8b 45 08             	mov    0x8(%ebp),%eax
f010142d:	89 04 24             	mov    %eax,(%esp)
f0101430:	89 f1                	mov    %esi,%ecx
f0101432:	89 da                	mov    %ebx,%edx
f0101434:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101439:	e8 b5 fd ff ff       	call   f01011f3 <boot_map_region>
	base+=round_size;
f010143e:	01 35 00 93 12 f0    	add    %esi,0xf0129300
	return ret;

}
f0101444:	89 d8                	mov    %ebx,%eax
f0101446:	83 c4 10             	add    $0x10,%esp
f0101449:	5b                   	pop    %ebx
f010144a:	5e                   	pop    %esi
f010144b:	5d                   	pop    %ebp
f010144c:	c3                   	ret    

f010144d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010144d:	55                   	push   %ebp
f010144e:	89 e5                	mov    %esp,%ebp
f0101450:	57                   	push   %edi
f0101451:	56                   	push   %esi
f0101452:	53                   	push   %ebx
f0101453:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101456:	b8 15 00 00 00       	mov    $0x15,%eax
f010145b:	e8 4e f7 ff ff       	call   f0100bae <nvram_read>
f0101460:	c1 e0 0a             	shl    $0xa,%eax
f0101463:	89 c2                	mov    %eax,%edx
f0101465:	85 c0                	test   %eax,%eax
f0101467:	79 06                	jns    f010146f <mem_init+0x22>
f0101469:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010146f:	c1 fa 0c             	sar    $0xc,%edx
f0101472:	89 15 38 02 1f f0    	mov    %edx,0xf01f0238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101478:	b8 17 00 00 00       	mov    $0x17,%eax
f010147d:	e8 2c f7 ff ff       	call   f0100bae <nvram_read>
f0101482:	89 c2                	mov    %eax,%edx
f0101484:	c1 e2 0a             	shl    $0xa,%edx
f0101487:	89 d0                	mov    %edx,%eax
f0101489:	85 d2                	test   %edx,%edx
f010148b:	79 06                	jns    f0101493 <mem_init+0x46>
f010148d:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101493:	c1 f8 0c             	sar    $0xc,%eax
f0101496:	74 0e                	je     f01014a6 <mem_init+0x59>
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101498:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010149e:	89 15 88 0e 1f f0    	mov    %edx,0xf01f0e88
f01014a4:	eb 0c                	jmp    f01014b2 <mem_init+0x65>
	else
	  npages = npages_basemem;
f01014a6:	8b 15 38 02 1f f0    	mov    0xf01f0238,%edx
f01014ac:	89 15 88 0e 1f f0    	mov    %edx,0xf01f0e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
				npages * PGSIZE / 1024,
				npages_basemem * PGSIZE / 1024,
				npages_extmem * PGSIZE / 1024);
f01014b2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014b5:	c1 e8 0a             	shr    $0xa,%eax
f01014b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
				npages * PGSIZE / 1024,
				npages_basemem * PGSIZE / 1024,
f01014bc:	a1 38 02 1f f0       	mov    0xf01f0238,%eax
f01014c1:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014c4:	c1 e8 0a             	shr    $0xa,%eax
f01014c7:	89 44 24 08          	mov    %eax,0x8(%esp)
				npages * PGSIZE / 1024,
f01014cb:	a1 88 0e 1f f0       	mov    0xf01f0e88,%eax
f01014d0:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014d3:	c1 e8 0a             	shr    $0xa,%eax
f01014d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014da:	c7 04 24 a4 74 10 f0 	movl   $0xf01074a4,(%esp)
f01014e1:	e8 40 2a 00 00       	call   f0103f26 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014e6:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014eb:	e8 39 f6 ff ff       	call   f0100b29 <boot_alloc>
f01014f0:	a3 8c 0e 1f f0       	mov    %eax,0xf01f0e8c
	memset(kern_pgdir, 0, PGSIZE);
f01014f5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014fc:	00 
f01014fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101504:	00 
f0101505:	89 04 24             	mov    %eax,(%esp)
f0101508:	e8 8d 4b 00 00       	call   f010609a <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010150d:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101512:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101517:	77 20                	ja     f0101539 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101519:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010151d:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0101524:	f0 
f0101525:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f010152c:	00 
f010152d:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101534:	e8 07 eb ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101539:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010153f:	83 ca 05             	or     $0x5,%edx
f0101542:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f0101548:	a1 88 0e 1f f0       	mov    0xf01f0e88,%eax
f010154d:	c1 e0 03             	shl    $0x3,%eax
f0101550:	e8 d4 f5 ff ff       	call   f0100b29 <boot_alloc>
f0101555:	a3 90 0e 1f f0       	mov    %eax,0xf01f0e90
	memset(pages, 0, sizeof(struct PageInfo)*npages); 
f010155a:	8b 15 88 0e 1f f0    	mov    0xf01f0e88,%edx
f0101560:	c1 e2 03             	shl    $0x3,%edx
f0101563:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101567:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010156e:	00 
f010156f:	89 04 24             	mov    %eax,(%esp)
f0101572:	e8 23 4b 00 00       	call   f010609a <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0101577:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010157c:	e8 a8 f5 ff ff       	call   f0100b29 <boot_alloc>
f0101581:	a3 48 02 1f f0       	mov    %eax,0xf01f0248
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101586:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010158d:	00 
f010158e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101595:	00 
f0101596:	89 04 24             	mov    %eax,(%esp)
f0101599:	e8 fc 4a 00 00       	call   f010609a <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010159e:	e8 87 f9 ff ff       	call   f0100f2a <page_init>

	check_page_free_list(1);
f01015a3:	b8 01 00 00 00       	mov    $0x1,%eax
f01015a8:	e8 2a f6 ff ff       	call   f0100bd7 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015ad:	83 3d 90 0e 1f f0 00 	cmpl   $0x0,0xf01f0e90
f01015b4:	75 1c                	jne    f01015d2 <mem_init+0x185>
	  panic("'pages' is a null pointer!");
f01015b6:	c7 44 24 08 f2 7d 10 	movl   $0xf0107df2,0x8(%esp)
f01015bd:	f0 
f01015be:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f01015c5:	00 
f01015c6:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01015cd:	e8 6e ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015d2:	a1 40 02 1f f0       	mov    0xf01f0240,%eax
f01015d7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015dc:	eb 03                	jmp    f01015e1 <mem_init+0x194>
	  ++nfree;
f01015de:	43                   	inc    %ebx

	if (!pages)
	  panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015df:	8b 00                	mov    (%eax),%eax
f01015e1:	85 c0                	test   %eax,%eax
f01015e3:	75 f9                	jne    f01015de <mem_init+0x191>
	  ++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ec:	e8 ce f9 ff ff       	call   f0100fbf <page_alloc>
f01015f1:	89 c6                	mov    %eax,%esi
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	75 24                	jne    f010161b <mem_init+0x1ce>
f01015f7:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f01015fe:	f0 
f01015ff:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101606:	f0 
f0101607:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010160e:	00 
f010160f:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101616:	e8 25 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010161b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101622:	e8 98 f9 ff ff       	call   f0100fbf <page_alloc>
f0101627:	89 c7                	mov    %eax,%edi
f0101629:	85 c0                	test   %eax,%eax
f010162b:	75 24                	jne    f0101651 <mem_init+0x204>
f010162d:	c7 44 24 0c 23 7e 10 	movl   $0xf0107e23,0xc(%esp)
f0101634:	f0 
f0101635:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010163c:	f0 
f010163d:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0101644:	00 
f0101645:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101651:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101658:	e8 62 f9 ff ff       	call   f0100fbf <page_alloc>
f010165d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101660:	85 c0                	test   %eax,%eax
f0101662:	75 24                	jne    f0101688 <mem_init+0x23b>
f0101664:	c7 44 24 0c 39 7e 10 	movl   $0xf0107e39,0xc(%esp)
f010166b:	f0 
f010166c:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101673:	f0 
f0101674:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f010167b:	00 
f010167c:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101683:	e8 b8 e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101688:	39 fe                	cmp    %edi,%esi
f010168a:	75 24                	jne    f01016b0 <mem_init+0x263>
f010168c:	c7 44 24 0c 4f 7e 10 	movl   $0xf0107e4f,0xc(%esp)
f0101693:	f0 
f0101694:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010169b:	f0 
f010169c:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f01016a3:	00 
f01016a4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01016ab:	e8 90 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016b0:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01016b3:	74 05                	je     f01016ba <mem_init+0x26d>
f01016b5:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01016b8:	75 24                	jne    f01016de <mem_init+0x291>
f01016ba:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f01016c1:	f0 
f01016c2:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01016c9:	f0 
f01016ca:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f01016d1:	00 
f01016d2:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01016d9:	e8 62 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016de:	8b 15 90 0e 1f f0    	mov    0xf01f0e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016e4:	a1 88 0e 1f f0       	mov    0xf01f0e88,%eax
f01016e9:	c1 e0 0c             	shl    $0xc,%eax
f01016ec:	89 f1                	mov    %esi,%ecx
f01016ee:	29 d1                	sub    %edx,%ecx
f01016f0:	c1 f9 03             	sar    $0x3,%ecx
f01016f3:	c1 e1 0c             	shl    $0xc,%ecx
f01016f6:	39 c1                	cmp    %eax,%ecx
f01016f8:	72 24                	jb     f010171e <mem_init+0x2d1>
f01016fa:	c7 44 24 0c 61 7e 10 	movl   $0xf0107e61,0xc(%esp)
f0101701:	f0 
f0101702:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101709:	f0 
f010170a:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101711:	00 
f0101712:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101719:	e8 22 e9 ff ff       	call   f0100040 <_panic>
f010171e:	89 f9                	mov    %edi,%ecx
f0101720:	29 d1                	sub    %edx,%ecx
f0101722:	c1 f9 03             	sar    $0x3,%ecx
f0101725:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101728:	39 c8                	cmp    %ecx,%eax
f010172a:	77 24                	ja     f0101750 <mem_init+0x303>
f010172c:	c7 44 24 0c 7e 7e 10 	movl   $0xf0107e7e,0xc(%esp)
f0101733:	f0 
f0101734:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010173b:	f0 
f010173c:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0101743:	00 
f0101744:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010174b:	e8 f0 e8 ff ff       	call   f0100040 <_panic>
f0101750:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101753:	29 d1                	sub    %edx,%ecx
f0101755:	89 ca                	mov    %ecx,%edx
f0101757:	c1 fa 03             	sar    $0x3,%edx
f010175a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010175d:	39 d0                	cmp    %edx,%eax
f010175f:	77 24                	ja     f0101785 <mem_init+0x338>
f0101761:	c7 44 24 0c 9b 7e 10 	movl   $0xf0107e9b,0xc(%esp)
f0101768:	f0 
f0101769:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101770:	f0 
f0101771:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0101778:	00 
f0101779:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101780:	e8 bb e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101785:	a1 40 02 1f f0       	mov    0xf01f0240,%eax
f010178a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010178d:	c7 05 40 02 1f f0 00 	movl   $0x0,0xf01f0240
f0101794:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101797:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010179e:	e8 1c f8 ff ff       	call   f0100fbf <page_alloc>
f01017a3:	85 c0                	test   %eax,%eax
f01017a5:	74 24                	je     f01017cb <mem_init+0x37e>
f01017a7:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f01017ae:	f0 
f01017af:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01017b6:	f0 
f01017b7:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f01017be:	00 
f01017bf:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01017c6:	e8 75 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01017cb:	89 34 24             	mov    %esi,(%esp)
f01017ce:	e8 9f f8 ff ff       	call   f0101072 <page_free>
	page_free(pp1);
f01017d3:	89 3c 24             	mov    %edi,(%esp)
f01017d6:	e8 97 f8 ff ff       	call   f0101072 <page_free>
	page_free(pp2);
f01017db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017de:	89 04 24             	mov    %eax,(%esp)
f01017e1:	e8 8c f8 ff ff       	call   f0101072 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ed:	e8 cd f7 ff ff       	call   f0100fbf <page_alloc>
f01017f2:	89 c6                	mov    %eax,%esi
f01017f4:	85 c0                	test   %eax,%eax
f01017f6:	75 24                	jne    f010181c <mem_init+0x3cf>
f01017f8:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f01017ff:	f0 
f0101800:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101807:	f0 
f0101808:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f010180f:	00 
f0101810:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101817:	e8 24 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010181c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101823:	e8 97 f7 ff ff       	call   f0100fbf <page_alloc>
f0101828:	89 c7                	mov    %eax,%edi
f010182a:	85 c0                	test   %eax,%eax
f010182c:	75 24                	jne    f0101852 <mem_init+0x405>
f010182e:	c7 44 24 0c 23 7e 10 	movl   $0xf0107e23,0xc(%esp)
f0101835:	f0 
f0101836:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010183d:	f0 
f010183e:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101845:	00 
f0101846:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010184d:	e8 ee e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101852:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101859:	e8 61 f7 ff ff       	call   f0100fbf <page_alloc>
f010185e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101861:	85 c0                	test   %eax,%eax
f0101863:	75 24                	jne    f0101889 <mem_init+0x43c>
f0101865:	c7 44 24 0c 39 7e 10 	movl   $0xf0107e39,0xc(%esp)
f010186c:	f0 
f010186d:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101874:	f0 
f0101875:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f010187c:	00 
f010187d:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101884:	e8 b7 e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101889:	39 fe                	cmp    %edi,%esi
f010188b:	75 24                	jne    f01018b1 <mem_init+0x464>
f010188d:	c7 44 24 0c 4f 7e 10 	movl   $0xf0107e4f,0xc(%esp)
f0101894:	f0 
f0101895:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010189c:	f0 
f010189d:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01018a4:	00 
f01018a5:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01018ac:	e8 8f e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018b1:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018b4:	74 05                	je     f01018bb <mem_init+0x46e>
f01018b6:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018b9:	75 24                	jne    f01018df <mem_init+0x492>
f01018bb:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f01018c2:	f0 
f01018c3:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01018ca:	f0 
f01018cb:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f01018d2:	00 
f01018d3:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01018da:	e8 61 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01018df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018e6:	e8 d4 f6 ff ff       	call   f0100fbf <page_alloc>
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	74 24                	je     f0101913 <mem_init+0x4c6>
f01018ef:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f01018f6:	f0 
f01018f7:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01018fe:	f0 
f01018ff:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101906:	00 
f0101907:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010190e:	e8 2d e7 ff ff       	call   f0100040 <_panic>
f0101913:	89 f0                	mov    %esi,%eax
f0101915:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f010191b:	c1 f8 03             	sar    $0x3,%eax
f010191e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101921:	89 c2                	mov    %eax,%edx
f0101923:	c1 ea 0c             	shr    $0xc,%edx
f0101926:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f010192c:	72 20                	jb     f010194e <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010192e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101932:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0101939:	f0 
f010193a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101941:	00 
f0101942:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0101949:	e8 f2 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010194e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101955:	00 
f0101956:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010195d:	00 
	return (void *)(pa + KERNBASE);
f010195e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101963:	89 04 24             	mov    %eax,(%esp)
f0101966:	e8 2f 47 00 00       	call   f010609a <memset>
	page_free(pp0);
f010196b:	89 34 24             	mov    %esi,(%esp)
f010196e:	e8 ff f6 ff ff       	call   f0101072 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101973:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010197a:	e8 40 f6 ff ff       	call   f0100fbf <page_alloc>
f010197f:	85 c0                	test   %eax,%eax
f0101981:	75 24                	jne    f01019a7 <mem_init+0x55a>
f0101983:	c7 44 24 0c c7 7e 10 	movl   $0xf0107ec7,0xc(%esp)
f010198a:	f0 
f010198b:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101992:	f0 
f0101993:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f010199a:	00 
f010199b:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01019a2:	e8 99 e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019a7:	39 c6                	cmp    %eax,%esi
f01019a9:	74 24                	je     f01019cf <mem_init+0x582>
f01019ab:	c7 44 24 0c e5 7e 10 	movl   $0xf0107ee5,0xc(%esp)
f01019b2:	f0 
f01019b3:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01019ba:	f0 
f01019bb:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01019c2:	00 
f01019c3:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01019ca:	e8 71 e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019cf:	89 f2                	mov    %esi,%edx
f01019d1:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f01019d7:	c1 fa 03             	sar    $0x3,%edx
f01019da:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019dd:	89 d0                	mov    %edx,%eax
f01019df:	c1 e8 0c             	shr    $0xc,%eax
f01019e2:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f01019e8:	72 20                	jb     f0101a0a <mem_init+0x5bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01019ee:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f01019f5:	f0 
f01019f6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019fd:	00 
f01019fe:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0101a05:	e8 36 e6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101a0a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101a10:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
	  assert(c[i] == 0);
f0101a16:	80 38 00             	cmpb   $0x0,(%eax)
f0101a19:	74 24                	je     f0101a3f <mem_init+0x5f2>
f0101a1b:	c7 44 24 0c f5 7e 10 	movl   $0xf0107ef5,0xc(%esp)
f0101a22:	f0 
f0101a23:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101a2a:	f0 
f0101a2b:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101a32:	00 
f0101a33:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101a3a:	e8 01 e6 ff ff       	call   f0100040 <_panic>
f0101a3f:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a40:	39 d0                	cmp    %edx,%eax
f0101a42:	75 d2                	jne    f0101a16 <mem_init+0x5c9>
	  assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a44:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a47:	89 15 40 02 1f f0    	mov    %edx,0xf01f0240

	// free the pages we took
	page_free(pp0);
f0101a4d:	89 34 24             	mov    %esi,(%esp)
f0101a50:	e8 1d f6 ff ff       	call   f0101072 <page_free>
	page_free(pp1);
f0101a55:	89 3c 24             	mov    %edi,(%esp)
f0101a58:	e8 15 f6 ff ff       	call   f0101072 <page_free>
	page_free(pp2);
f0101a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a60:	89 04 24             	mov    %eax,(%esp)
f0101a63:	e8 0a f6 ff ff       	call   f0101072 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a68:	a1 40 02 1f f0       	mov    0xf01f0240,%eax
f0101a6d:	eb 03                	jmp    f0101a72 <mem_init+0x625>
	  --nfree;
f0101a6f:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a70:	8b 00                	mov    (%eax),%eax
f0101a72:	85 c0                	test   %eax,%eax
f0101a74:	75 f9                	jne    f0101a6f <mem_init+0x622>
	  --nfree;
	assert(nfree == 0);
f0101a76:	85 db                	test   %ebx,%ebx
f0101a78:	74 24                	je     f0101a9e <mem_init+0x651>
f0101a7a:	c7 44 24 0c ff 7e 10 	movl   $0xf0107eff,0xc(%esp)
f0101a81:	f0 
f0101a82:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101a89:	f0 
f0101a8a:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101a91:	00 
f0101a92:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101a99:	e8 a2 e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101a9e:	c7 04 24 00 75 10 f0 	movl   $0xf0107500,(%esp)
f0101aa5:	e8 7c 24 00 00       	call   f0103f26 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aaa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ab1:	e8 09 f5 ff ff       	call   f0100fbf <page_alloc>
f0101ab6:	89 c7                	mov    %eax,%edi
f0101ab8:	85 c0                	test   %eax,%eax
f0101aba:	75 24                	jne    f0101ae0 <mem_init+0x693>
f0101abc:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f0101ac3:	f0 
f0101ac4:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101acb:	f0 
f0101acc:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0101ad3:	00 
f0101ad4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101adb:	e8 60 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ae0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae7:	e8 d3 f4 ff ff       	call   f0100fbf <page_alloc>
f0101aec:	89 c6                	mov    %eax,%esi
f0101aee:	85 c0                	test   %eax,%eax
f0101af0:	75 24                	jne    f0101b16 <mem_init+0x6c9>
f0101af2:	c7 44 24 0c 23 7e 10 	movl   $0xf0107e23,0xc(%esp)
f0101af9:	f0 
f0101afa:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101b01:	f0 
f0101b02:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101b09:	00 
f0101b0a:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101b11:	e8 2a e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b1d:	e8 9d f4 ff ff       	call   f0100fbf <page_alloc>
f0101b22:	89 c3                	mov    %eax,%ebx
f0101b24:	85 c0                	test   %eax,%eax
f0101b26:	75 24                	jne    f0101b4c <mem_init+0x6ff>
f0101b28:	c7 44 24 0c 39 7e 10 	movl   $0xf0107e39,0xc(%esp)
f0101b2f:	f0 
f0101b30:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101b37:	f0 
f0101b38:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101b3f:	00 
f0101b40:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101b47:	e8 f4 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b4c:	39 f7                	cmp    %esi,%edi
f0101b4e:	75 24                	jne    f0101b74 <mem_init+0x727>
f0101b50:	c7 44 24 0c 4f 7e 10 	movl   $0xf0107e4f,0xc(%esp)
f0101b57:	f0 
f0101b58:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101b5f:	f0 
f0101b60:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101b67:	00 
f0101b68:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101b6f:	e8 cc e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b74:	39 c6                	cmp    %eax,%esi
f0101b76:	74 04                	je     f0101b7c <mem_init+0x72f>
f0101b78:	39 c7                	cmp    %eax,%edi
f0101b7a:	75 24                	jne    f0101ba0 <mem_init+0x753>
f0101b7c:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f0101b83:	f0 
f0101b84:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101b8b:	f0 
f0101b8c:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101b93:	00 
f0101b94:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101b9b:	e8 a0 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ba0:	8b 15 40 02 1f f0    	mov    0xf01f0240,%edx
f0101ba6:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101ba9:	c7 05 40 02 1f f0 00 	movl   $0x0,0xf01f0240
f0101bb0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bba:	e8 00 f4 ff ff       	call   f0100fbf <page_alloc>
f0101bbf:	85 c0                	test   %eax,%eax
f0101bc1:	74 24                	je     f0101be7 <mem_init+0x79a>
f0101bc3:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f0101bca:	f0 
f0101bcb:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101bd2:	f0 
f0101bd3:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101bda:	00 
f0101bdb:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101be2:	e8 59 e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101be7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bea:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bf5:	00 
f0101bf6:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101bfb:	89 04 24             	mov    %eax,(%esp)
f0101bfe:	e8 4d f6 ff ff       	call   f0101250 <page_lookup>
f0101c03:	85 c0                	test   %eax,%eax
f0101c05:	74 24                	je     f0101c2b <mem_init+0x7de>
f0101c07:	c7 44 24 0c 20 75 10 	movl   $0xf0107520,0xc(%esp)
f0101c0e:	f0 
f0101c0f:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101c16:	f0 
f0101c17:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0101c1e:	00 
f0101c1f:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101c26:	e8 15 e4 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c2b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c32:	00 
f0101c33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c3a:	00 
f0101c3b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c3f:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101c44:	89 04 24             	mov    %eax,(%esp)
f0101c47:	e8 0d f7 ff ff       	call   f0101359 <page_insert>
f0101c4c:	85 c0                	test   %eax,%eax
f0101c4e:	78 24                	js     f0101c74 <mem_init+0x827>
f0101c50:	c7 44 24 0c 58 75 10 	movl   $0xf0107558,0xc(%esp)
f0101c57:	f0 
f0101c58:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101c5f:	f0 
f0101c60:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101c67:	00 
f0101c68:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101c6f:	e8 cc e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c74:	89 3c 24             	mov    %edi,(%esp)
f0101c77:	e8 f6 f3 ff ff       	call   f0101072 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c7c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c83:	00 
f0101c84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c8b:	00 
f0101c8c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c90:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101c95:	89 04 24             	mov    %eax,(%esp)
f0101c98:	e8 bc f6 ff ff       	call   f0101359 <page_insert>
f0101c9d:	85 c0                	test   %eax,%eax
f0101c9f:	74 24                	je     f0101cc5 <mem_init+0x878>
f0101ca1:	c7 44 24 0c 88 75 10 	movl   $0xf0107588,0xc(%esp)
f0101ca8:	f0 
f0101ca9:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101cb0:	f0 
f0101cb1:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101cb8:	00 
f0101cb9:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101cc0:	e8 7b e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cc5:	8b 0d 8c 0e 1f f0    	mov    0xf01f0e8c,%ecx
f0101ccb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cce:	a1 90 0e 1f f0       	mov    0xf01f0e90,%eax
f0101cd3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cd6:	8b 11                	mov    (%ecx),%edx
f0101cd8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101cde:	89 f8                	mov    %edi,%eax
f0101ce0:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101ce3:	c1 f8 03             	sar    $0x3,%eax
f0101ce6:	c1 e0 0c             	shl    $0xc,%eax
f0101ce9:	39 c2                	cmp    %eax,%edx
f0101ceb:	74 24                	je     f0101d11 <mem_init+0x8c4>
f0101ced:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101cfc:	f0 
f0101cfd:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101d04:	00 
f0101d05:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101d0c:	e8 2f e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d11:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d19:	e8 9e ed ff ff       	call   f0100abc <check_va2pa>
f0101d1e:	89 f2                	mov    %esi,%edx
f0101d20:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101d23:	c1 fa 03             	sar    $0x3,%edx
f0101d26:	c1 e2 0c             	shl    $0xc,%edx
f0101d29:	39 d0                	cmp    %edx,%eax
f0101d2b:	74 24                	je     f0101d51 <mem_init+0x904>
f0101d2d:	c7 44 24 0c e0 75 10 	movl   $0xf01075e0,0xc(%esp)
f0101d34:	f0 
f0101d35:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101d3c:	f0 
f0101d3d:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101d44:	00 
f0101d45:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101d4c:	e8 ef e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d51:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d56:	74 24                	je     f0101d7c <mem_init+0x92f>
f0101d58:	c7 44 24 0c 0a 7f 10 	movl   $0xf0107f0a,0xc(%esp)
f0101d5f:	f0 
f0101d60:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101d67:	f0 
f0101d68:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101d6f:	00 
f0101d70:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101d77:	e8 c4 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d7c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d81:	74 24                	je     f0101da7 <mem_init+0x95a>
f0101d83:	c7 44 24 0c 1b 7f 10 	movl   $0xf0107f1b,0xc(%esp)
f0101d8a:	f0 
f0101d8b:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101d92:	f0 
f0101d93:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101d9a:	00 
f0101d9b:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101da2:	e8 99 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101da7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dae:	00 
f0101daf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101db6:	00 
f0101db7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dbb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101dbe:	89 14 24             	mov    %edx,(%esp)
f0101dc1:	e8 93 f5 ff ff       	call   f0101359 <page_insert>
f0101dc6:	85 c0                	test   %eax,%eax
f0101dc8:	74 24                	je     f0101dee <mem_init+0x9a1>
f0101dca:	c7 44 24 0c 10 76 10 	movl   $0xf0107610,0xc(%esp)
f0101dd1:	f0 
f0101dd2:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101dd9:	f0 
f0101dda:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101de1:	00 
f0101de2:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101de9:	e8 52 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dee:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df3:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101df8:	e8 bf ec ff ff       	call   f0100abc <check_va2pa>
f0101dfd:	89 da                	mov    %ebx,%edx
f0101dff:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f0101e05:	c1 fa 03             	sar    $0x3,%edx
f0101e08:	c1 e2 0c             	shl    $0xc,%edx
f0101e0b:	39 d0                	cmp    %edx,%eax
f0101e0d:	74 24                	je     f0101e33 <mem_init+0x9e6>
f0101e0f:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f0101e16:	f0 
f0101e17:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101e1e:	f0 
f0101e1f:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101e26:	00 
f0101e27:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101e2e:	e8 0d e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e33:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e38:	74 24                	je     f0101e5e <mem_init+0xa11>
f0101e3a:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0101e41:	f0 
f0101e42:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101e49:	f0 
f0101e4a:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101e51:	00 
f0101e52:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101e59:	e8 e2 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e65:	e8 55 f1 ff ff       	call   f0100fbf <page_alloc>
f0101e6a:	85 c0                	test   %eax,%eax
f0101e6c:	74 24                	je     f0101e92 <mem_init+0xa45>
f0101e6e:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f0101e75:	f0 
f0101e76:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101e7d:	f0 
f0101e7e:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101e85:	00 
f0101e86:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101e8d:	e8 ae e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e92:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e99:	00 
f0101e9a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ea1:	00 
f0101ea2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ea6:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101eab:	89 04 24             	mov    %eax,(%esp)
f0101eae:	e8 a6 f4 ff ff       	call   f0101359 <page_insert>
f0101eb3:	85 c0                	test   %eax,%eax
f0101eb5:	74 24                	je     f0101edb <mem_init+0xa8e>
f0101eb7:	c7 44 24 0c 10 76 10 	movl   $0xf0107610,0xc(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101ece:	00 
f0101ecf:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101ed6:	e8 65 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101edb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee0:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0101ee5:	e8 d2 eb ff ff       	call   f0100abc <check_va2pa>
f0101eea:	89 da                	mov    %ebx,%edx
f0101eec:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f0101ef2:	c1 fa 03             	sar    $0x3,%edx
f0101ef5:	c1 e2 0c             	shl    $0xc,%edx
f0101ef8:	39 d0                	cmp    %edx,%eax
f0101efa:	74 24                	je     f0101f20 <mem_init+0xad3>
f0101efc:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f0101f03:	f0 
f0101f04:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101f0b:	f0 
f0101f0c:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101f13:	00 
f0101f14:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101f1b:	e8 20 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f20:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f25:	74 24                	je     f0101f4b <mem_init+0xafe>
f0101f27:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f0101f2e:	f0 
f0101f2f:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101f36:	f0 
f0101f37:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101f3e:	00 
f0101f3f:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101f46:	e8 f5 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f52:	e8 68 f0 ff ff       	call   f0100fbf <page_alloc>
f0101f57:	85 c0                	test   %eax,%eax
f0101f59:	74 24                	je     f0101f7f <mem_init+0xb32>
f0101f5b:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f0101f62:	f0 
f0101f63:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101f6a:	f0 
f0101f6b:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101f72:	00 
f0101f73:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101f7a:	e8 c1 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f7f:	8b 15 8c 0e 1f f0    	mov    0xf01f0e8c,%edx
f0101f85:	8b 02                	mov    (%edx),%eax
f0101f87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f8c:	89 c1                	mov    %eax,%ecx
f0101f8e:	c1 e9 0c             	shr    $0xc,%ecx
f0101f91:	3b 0d 88 0e 1f f0    	cmp    0xf01f0e88,%ecx
f0101f97:	72 20                	jb     f0101fb9 <mem_init+0xb6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f9d:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0101fa4:	f0 
f0101fa5:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101fac:	00 
f0101fad:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0101fb4:	e8 87 e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101fb9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fc1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fc8:	00 
f0101fc9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fd0:	00 
f0101fd1:	89 14 24             	mov    %edx,(%esp)
f0101fd4:	e8 15 f1 ff ff       	call   f01010ee <pgdir_walk>
f0101fd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101fdc:	83 c2 04             	add    $0x4,%edx
f0101fdf:	39 d0                	cmp    %edx,%eax
f0101fe1:	74 24                	je     f0102007 <mem_init+0xbba>
f0101fe3:	c7 44 24 0c 7c 76 10 	movl   $0xf010767c,0xc(%esp)
f0101fea:	f0 
f0101feb:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0101ff2:	f0 
f0101ff3:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101ffa:	00 
f0101ffb:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102002:	e8 39 e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102007:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010200e:	00 
f010200f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102016:	00 
f0102017:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010201b:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102020:	89 04 24             	mov    %eax,(%esp)
f0102023:	e8 31 f3 ff ff       	call   f0101359 <page_insert>
f0102028:	85 c0                	test   %eax,%eax
f010202a:	74 24                	je     f0102050 <mem_init+0xc03>
f010202c:	c7 44 24 0c bc 76 10 	movl   $0xf01076bc,0xc(%esp)
f0102033:	f0 
f0102034:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010203b:	f0 
f010203c:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102043:	00 
f0102044:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010204b:	e8 f0 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102050:	8b 0d 8c 0e 1f f0    	mov    0xf01f0e8c,%ecx
f0102056:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102059:	ba 00 10 00 00       	mov    $0x1000,%edx
f010205e:	89 c8                	mov    %ecx,%eax
f0102060:	e8 57 ea ff ff       	call   f0100abc <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102065:	89 da                	mov    %ebx,%edx
f0102067:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f010206d:	c1 fa 03             	sar    $0x3,%edx
f0102070:	c1 e2 0c             	shl    $0xc,%edx
f0102073:	39 d0                	cmp    %edx,%eax
f0102075:	74 24                	je     f010209b <mem_init+0xc4e>
f0102077:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f010207e:	f0 
f010207f:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102086:	f0 
f0102087:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010208e:	00 
f010208f:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102096:	e8 a5 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010209b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020a0:	74 24                	je     f01020c6 <mem_init+0xc79>
f01020a2:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f01020a9:	f0 
f01020aa:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01020b1:	f0 
f01020b2:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f01020b9:	00 
f01020ba:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01020c1:	e8 7a df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020cd:	00 
f01020ce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020d5:	00 
f01020d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020d9:	89 04 24             	mov    %eax,(%esp)
f01020dc:	e8 0d f0 ff ff       	call   f01010ee <pgdir_walk>
f01020e1:	f6 00 04             	testb  $0x4,(%eax)
f01020e4:	75 24                	jne    f010210a <mem_init+0xcbd>
f01020e6:	c7 44 24 0c fc 76 10 	movl   $0xf01076fc,0xc(%esp)
f01020ed:	f0 
f01020ee:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01020fd:	00 
f01020fe:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102105:	e8 36 df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010210a:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f010210f:	f6 00 04             	testb  $0x4,(%eax)
f0102112:	75 24                	jne    f0102138 <mem_init+0xceb>
f0102114:	c7 44 24 0c 3d 7f 10 	movl   $0xf0107f3d,0xc(%esp)
f010211b:	f0 
f010211c:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102123:	f0 
f0102124:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f010212b:	00 
f010212c:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102133:	e8 08 df ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102138:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010213f:	00 
f0102140:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102147:	00 
f0102148:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010214c:	89 04 24             	mov    %eax,(%esp)
f010214f:	e8 05 f2 ff ff       	call   f0101359 <page_insert>
f0102154:	85 c0                	test   %eax,%eax
f0102156:	74 24                	je     f010217c <mem_init+0xd2f>
f0102158:	c7 44 24 0c 10 76 10 	movl   $0xf0107610,0xc(%esp)
f010215f:	f0 
f0102160:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102167:	f0 
f0102168:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010216f:	00 
f0102170:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102177:	e8 c4 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010217c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102183:	00 
f0102184:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010218b:	00 
f010218c:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102191:	89 04 24             	mov    %eax,(%esp)
f0102194:	e8 55 ef ff ff       	call   f01010ee <pgdir_walk>
f0102199:	f6 00 02             	testb  $0x2,(%eax)
f010219c:	75 24                	jne    f01021c2 <mem_init+0xd75>
f010219e:	c7 44 24 0c 30 77 10 	movl   $0xf0107730,0xc(%esp)
f01021a5:	f0 
f01021a6:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01021ad:	f0 
f01021ae:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01021b5:	00 
f01021b6:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01021bd:	e8 7e de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021c9:	00 
f01021ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021d1:	00 
f01021d2:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01021d7:	89 04 24             	mov    %eax,(%esp)
f01021da:	e8 0f ef ff ff       	call   f01010ee <pgdir_walk>
f01021df:	f6 00 04             	testb  $0x4,(%eax)
f01021e2:	74 24                	je     f0102208 <mem_init+0xdbb>
f01021e4:	c7 44 24 0c 64 77 10 	movl   $0xf0107764,0xc(%esp)
f01021eb:	f0 
f01021ec:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01021f3:	f0 
f01021f4:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f01021fb:	00 
f01021fc:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102203:	e8 38 de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102208:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010220f:	00 
f0102210:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102217:	00 
f0102218:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010221c:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102221:	89 04 24             	mov    %eax,(%esp)
f0102224:	e8 30 f1 ff ff       	call   f0101359 <page_insert>
f0102229:	85 c0                	test   %eax,%eax
f010222b:	78 24                	js     f0102251 <mem_init+0xe04>
f010222d:	c7 44 24 0c 9c 77 10 	movl   $0xf010779c,0xc(%esp)
f0102234:	f0 
f0102235:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010223c:	f0 
f010223d:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102244:	00 
f0102245:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010224c:	e8 ef dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102251:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102258:	00 
f0102259:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102260:	00 
f0102261:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102265:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f010226a:	89 04 24             	mov    %eax,(%esp)
f010226d:	e8 e7 f0 ff ff       	call   f0101359 <page_insert>
f0102272:	85 c0                	test   %eax,%eax
f0102274:	74 24                	je     f010229a <mem_init+0xe4d>
f0102276:	c7 44 24 0c d4 77 10 	movl   $0xf01077d4,0xc(%esp)
f010227d:	f0 
f010227e:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102285:	f0 
f0102286:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f010228d:	00 
f010228e:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102295:	e8 a6 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010229a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022a1:	00 
f01022a2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022a9:	00 
f01022aa:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01022af:	89 04 24             	mov    %eax,(%esp)
f01022b2:	e8 37 ee ff ff       	call   f01010ee <pgdir_walk>
f01022b7:	f6 00 04             	testb  $0x4,(%eax)
f01022ba:	74 24                	je     f01022e0 <mem_init+0xe93>
f01022bc:	c7 44 24 0c 64 77 10 	movl   $0xf0107764,0xc(%esp)
f01022c3:	f0 
f01022c4:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01022cb:	f0 
f01022cc:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f01022d3:	00 
f01022d4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01022db:	e8 60 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022e0:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01022e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01022ed:	e8 ca e7 ff ff       	call   f0100abc <check_va2pa>
f01022f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022f5:	89 f0                	mov    %esi,%eax
f01022f7:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f01022fd:	c1 f8 03             	sar    $0x3,%eax
f0102300:	c1 e0 0c             	shl    $0xc,%eax
f0102303:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102306:	74 24                	je     f010232c <mem_init+0xedf>
f0102308:	c7 44 24 0c 10 78 10 	movl   $0xf0107810,0xc(%esp)
f010230f:	f0 
f0102310:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102317:	f0 
f0102318:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f010231f:	00 
f0102320:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102327:	e8 14 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010232c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102331:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102334:	e8 83 e7 ff ff       	call   f0100abc <check_va2pa>
f0102339:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010233c:	74 24                	je     f0102362 <mem_init+0xf15>
f010233e:	c7 44 24 0c 3c 78 10 	movl   $0xf010783c,0xc(%esp)
f0102345:	f0 
f0102346:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010234d:	f0 
f010234e:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102355:	00 
f0102356:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010235d:	e8 de dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102362:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102367:	74 24                	je     f010238d <mem_init+0xf40>
f0102369:	c7 44 24 0c 53 7f 10 	movl   $0xf0107f53,0xc(%esp)
f0102370:	f0 
f0102371:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102378:	f0 
f0102379:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102380:	00 
f0102381:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102388:	e8 b3 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010238d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102392:	74 24                	je     f01023b8 <mem_init+0xf6b>
f0102394:	c7 44 24 0c 64 7f 10 	movl   $0xf0107f64,0xc(%esp)
f010239b:	f0 
f010239c:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01023a3:	f0 
f01023a4:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01023ab:	00 
f01023ac:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01023b3:	e8 88 dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01023b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023bf:	e8 fb eb ff ff       	call   f0100fbf <page_alloc>
f01023c4:	85 c0                	test   %eax,%eax
f01023c6:	74 04                	je     f01023cc <mem_init+0xf7f>
f01023c8:	39 c3                	cmp    %eax,%ebx
f01023ca:	74 24                	je     f01023f0 <mem_init+0xfa3>
f01023cc:	c7 44 24 0c 6c 78 10 	movl   $0xf010786c,0xc(%esp)
f01023d3:	f0 
f01023d4:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01023db:	f0 
f01023dc:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01023e3:	00 
f01023e4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01023eb:	e8 50 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01023f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01023f7:	00 
f01023f8:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01023fd:	89 04 24             	mov    %eax,(%esp)
f0102400:	e8 04 ef ff ff       	call   f0101309 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102405:	8b 15 8c 0e 1f f0    	mov    0xf01f0e8c,%edx
f010240b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010240e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102413:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102416:	e8 a1 e6 ff ff       	call   f0100abc <check_va2pa>
f010241b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010241e:	74 24                	je     f0102444 <mem_init+0xff7>
f0102420:	c7 44 24 0c 90 78 10 	movl   $0xf0107890,0xc(%esp)
f0102427:	f0 
f0102428:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010242f:	f0 
f0102430:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102437:	00 
f0102438:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010243f:	e8 fc db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102444:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102449:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010244c:	e8 6b e6 ff ff       	call   f0100abc <check_va2pa>
f0102451:	89 f2                	mov    %esi,%edx
f0102453:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f0102459:	c1 fa 03             	sar    $0x3,%edx
f010245c:	c1 e2 0c             	shl    $0xc,%edx
f010245f:	39 d0                	cmp    %edx,%eax
f0102461:	74 24                	je     f0102487 <mem_init+0x103a>
f0102463:	c7 44 24 0c 3c 78 10 	movl   $0xf010783c,0xc(%esp)
f010246a:	f0 
f010246b:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102472:	f0 
f0102473:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010247a:	00 
f010247b:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102482:	e8 b9 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102487:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010248c:	74 24                	je     f01024b2 <mem_init+0x1065>
f010248e:	c7 44 24 0c 0a 7f 10 	movl   $0xf0107f0a,0xc(%esp)
f0102495:	f0 
f0102496:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010249d:	f0 
f010249e:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f01024a5:	00 
f01024a6:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01024ad:	e8 8e db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024b2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024b7:	74 24                	je     f01024dd <mem_init+0x1090>
f01024b9:	c7 44 24 0c 64 7f 10 	movl   $0xf0107f64,0xc(%esp)
f01024c0:	f0 
f01024c1:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01024c8:	f0 
f01024c9:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01024d0:	00 
f01024d1:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01024d8:	e8 63 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01024dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01024e4:	00 
f01024e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ec:	00 
f01024ed:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024f1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024f4:	89 0c 24             	mov    %ecx,(%esp)
f01024f7:	e8 5d ee ff ff       	call   f0101359 <page_insert>
f01024fc:	85 c0                	test   %eax,%eax
f01024fe:	74 24                	je     f0102524 <mem_init+0x10d7>
f0102500:	c7 44 24 0c b4 78 10 	movl   $0xf01078b4,0xc(%esp)
f0102507:	f0 
f0102508:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010250f:	f0 
f0102510:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102517:	00 
f0102518:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010251f:	e8 1c db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102524:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102529:	75 24                	jne    f010254f <mem_init+0x1102>
f010252b:	c7 44 24 0c 75 7f 10 	movl   $0xf0107f75,0xc(%esp)
f0102532:	f0 
f0102533:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010253a:	f0 
f010253b:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102542:	00 
f0102543:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010254a:	e8 f1 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010254f:	83 3e 00             	cmpl   $0x0,(%esi)
f0102552:	74 24                	je     f0102578 <mem_init+0x112b>
f0102554:	c7 44 24 0c 81 7f 10 	movl   $0xf0107f81,0xc(%esp)
f010255b:	f0 
f010255c:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102563:	f0 
f0102564:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010256b:	00 
f010256c:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102573:	e8 c8 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102578:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010257f:	00 
f0102580:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102585:	89 04 24             	mov    %eax,(%esp)
f0102588:	e8 7c ed ff ff       	call   f0101309 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010258d:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102592:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102595:	ba 00 00 00 00       	mov    $0x0,%edx
f010259a:	e8 1d e5 ff ff       	call   f0100abc <check_va2pa>
f010259f:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025a2:	74 24                	je     f01025c8 <mem_init+0x117b>
f01025a4:	c7 44 24 0c 90 78 10 	movl   $0xf0107890,0xc(%esp)
f01025ab:	f0 
f01025ac:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01025b3:	f0 
f01025b4:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f01025bb:	00 
f01025bc:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01025c3:	e8 78 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01025c8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025d0:	e8 e7 e4 ff ff       	call   f0100abc <check_va2pa>
f01025d5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025d8:	74 24                	je     f01025fe <mem_init+0x11b1>
f01025da:	c7 44 24 0c ec 78 10 	movl   $0xf01078ec,0xc(%esp)
f01025e1:	f0 
f01025e2:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01025e9:	f0 
f01025ea:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01025f1:	00 
f01025f2:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01025f9:	e8 42 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01025fe:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102603:	74 24                	je     f0102629 <mem_init+0x11dc>
f0102605:	c7 44 24 0c 96 7f 10 	movl   $0xf0107f96,0xc(%esp)
f010260c:	f0 
f010260d:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102614:	f0 
f0102615:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010261c:	00 
f010261d:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102624:	e8 17 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102629:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010262e:	74 24                	je     f0102654 <mem_init+0x1207>
f0102630:	c7 44 24 0c 64 7f 10 	movl   $0xf0107f64,0xc(%esp)
f0102637:	f0 
f0102638:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010263f:	f0 
f0102640:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102647:	00 
f0102648:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010264f:	e8 ec d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010265b:	e8 5f e9 ff ff       	call   f0100fbf <page_alloc>
f0102660:	85 c0                	test   %eax,%eax
f0102662:	74 04                	je     f0102668 <mem_init+0x121b>
f0102664:	39 c6                	cmp    %eax,%esi
f0102666:	74 24                	je     f010268c <mem_init+0x123f>
f0102668:	c7 44 24 0c 14 79 10 	movl   $0xf0107914,0xc(%esp)
f010266f:	f0 
f0102670:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102677:	f0 
f0102678:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010267f:	00 
f0102680:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102687:	e8 b4 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010268c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102693:	e8 27 e9 ff ff       	call   f0100fbf <page_alloc>
f0102698:	85 c0                	test   %eax,%eax
f010269a:	74 24                	je     f01026c0 <mem_init+0x1273>
f010269c:	c7 44 24 0c b8 7e 10 	movl   $0xf0107eb8,0xc(%esp)
f01026a3:	f0 
f01026a4:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01026ab:	f0 
f01026ac:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01026b3:	00 
f01026b4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01026bb:	e8 80 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026c0:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01026c5:	8b 08                	mov    (%eax),%ecx
f01026c7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026cd:	89 fa                	mov    %edi,%edx
f01026cf:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f01026d5:	c1 fa 03             	sar    $0x3,%edx
f01026d8:	c1 e2 0c             	shl    $0xc,%edx
f01026db:	39 d1                	cmp    %edx,%ecx
f01026dd:	74 24                	je     f0102703 <mem_init+0x12b6>
f01026df:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f01026e6:	f0 
f01026e7:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01026ee:	f0 
f01026ef:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f01026f6:	00 
f01026f7:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01026fe:	e8 3d d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102703:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102709:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010270e:	74 24                	je     f0102734 <mem_init+0x12e7>
f0102710:	c7 44 24 0c 1b 7f 10 	movl   $0xf0107f1b,0xc(%esp)
f0102717:	f0 
f0102718:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010271f:	f0 
f0102720:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102727:	00 
f0102728:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010272f:	e8 0c d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102734:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010273a:	89 3c 24             	mov    %edi,(%esp)
f010273d:	e8 30 e9 ff ff       	call   f0101072 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102742:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102749:	00 
f010274a:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102751:	00 
f0102752:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102757:	89 04 24             	mov    %eax,(%esp)
f010275a:	e8 8f e9 ff ff       	call   f01010ee <pgdir_walk>
f010275f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102762:	8b 0d 8c 0e 1f f0    	mov    0xf01f0e8c,%ecx
f0102768:	8b 51 04             	mov    0x4(%ecx),%edx
f010276b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102771:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102774:	8b 15 88 0e 1f f0    	mov    0xf01f0e88,%edx
f010277a:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010277d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102780:	c1 ea 0c             	shr    $0xc,%edx
f0102783:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102786:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102789:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010278c:	72 23                	jb     f01027b1 <mem_init+0x1364>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010278e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102791:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102795:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f010279c:	f0 
f010279d:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f01027a4:	00 
f01027a5:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01027ac:	e8 8f d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01027b4:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01027ba:	39 d0                	cmp    %edx,%eax
f01027bc:	74 24                	je     f01027e2 <mem_init+0x1395>
f01027be:	c7 44 24 0c a7 7f 10 	movl   $0xf0107fa7,0xc(%esp)
f01027c5:	f0 
f01027c6:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01027cd:	f0 
f01027ce:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01027d5:	00 
f01027d6:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01027dd:	e8 5e d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027e2:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01027e9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027ef:	89 f8                	mov    %edi,%eax
f01027f1:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f01027f7:	c1 f8 03             	sar    $0x3,%eax
f01027fa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027fd:	89 c1                	mov    %eax,%ecx
f01027ff:	c1 e9 0c             	shr    $0xc,%ecx
f0102802:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102805:	77 20                	ja     f0102827 <mem_init+0x13da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102807:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010280b:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0102812:	f0 
f0102813:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010281a:	00 
f010281b:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0102822:	e8 19 d8 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102827:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010282e:	00 
f010282f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102836:	00 
	return (void *)(pa + KERNBASE);
f0102837:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010283c:	89 04 24             	mov    %eax,(%esp)
f010283f:	e8 56 38 00 00       	call   f010609a <memset>
	page_free(pp0);
f0102844:	89 3c 24             	mov    %edi,(%esp)
f0102847:	e8 26 e8 ff ff       	call   f0101072 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010284c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102853:	00 
f0102854:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010285b:	00 
f010285c:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102861:	89 04 24             	mov    %eax,(%esp)
f0102864:	e8 85 e8 ff ff       	call   f01010ee <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102869:	89 fa                	mov    %edi,%edx
f010286b:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f0102871:	c1 fa 03             	sar    $0x3,%edx
f0102874:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102877:	89 d0                	mov    %edx,%eax
f0102879:	c1 e8 0c             	shr    $0xc,%eax
f010287c:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f0102882:	72 20                	jb     f01028a4 <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102884:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102888:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f010288f:	f0 
f0102890:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102897:	00 
f0102898:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f010289f:	e8 9c d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01028a4:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01028aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028ad:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
	  assert((ptep[i] & PTE_P) == 0);
f01028b3:	f6 00 01             	testb  $0x1,(%eax)
f01028b6:	74 24                	je     f01028dc <mem_init+0x148f>
f01028b8:	c7 44 24 0c bf 7f 10 	movl   $0xf0107fbf,0xc(%esp)
f01028bf:	f0 
f01028c0:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01028c7:	f0 
f01028c8:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01028cf:	00 
f01028d0:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01028d7:	e8 64 d7 ff ff       	call   f0100040 <_panic>
f01028dc:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028df:	39 d0                	cmp    %edx,%eax
f01028e1:	75 d0                	jne    f01028b3 <mem_init+0x1466>
	  assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028e3:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01028e8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028ee:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01028f4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01028f7:	89 0d 40 02 1f f0    	mov    %ecx,0xf01f0240

	// free the pages we took
	page_free(pp0);
f01028fd:	89 3c 24             	mov    %edi,(%esp)
f0102900:	e8 6d e7 ff ff       	call   f0101072 <page_free>
	page_free(pp1);
f0102905:	89 34 24             	mov    %esi,(%esp)
f0102908:	e8 65 e7 ff ff       	call   f0101072 <page_free>
	page_free(pp2);
f010290d:	89 1c 24             	mov    %ebx,(%esp)
f0102910:	e8 5d e7 ff ff       	call   f0101072 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102915:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f010291c:	00 
f010291d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102924:	e8 b6 ea ff ff       	call   f01013df <mmio_map_region>
f0102929:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010292b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102932:	00 
f0102933:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010293a:	e8 a0 ea ff ff       	call   f01013df <mmio_map_region>
f010293f:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102941:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102947:	76 0d                	jbe    f0102956 <mem_init+0x1509>
f0102949:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010294f:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102954:	76 24                	jbe    f010297a <mem_init+0x152d>
f0102956:	c7 44 24 0c 38 79 10 	movl   $0xf0107938,0xc(%esp)
f010295d:	f0 
f010295e:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102965:	f0 
f0102966:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f010296d:	00 
f010296e:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102975:	e8 c6 d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010297a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102980:	76 0e                	jbe    f0102990 <mem_init+0x1543>
f0102982:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102988:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010298e:	76 24                	jbe    f01029b4 <mem_init+0x1567>
f0102990:	c7 44 24 0c 60 79 10 	movl   $0xf0107960,0xc(%esp)
f0102997:	f0 
f0102998:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010299f:	f0 
f01029a0:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01029a7:	00 
f01029a8:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01029af:	e8 8c d6 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01029b4:	89 da                	mov    %ebx,%edx
f01029b6:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01029b8:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01029be:	74 24                	je     f01029e4 <mem_init+0x1597>
f01029c0:	c7 44 24 0c 88 79 10 	movl   $0xf0107988,0xc(%esp)
f01029c7:	f0 
f01029c8:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f01029d7:	00 
f01029d8:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01029df:	e8 5c d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01029e4:	39 c6                	cmp    %eax,%esi
f01029e6:	73 24                	jae    f0102a0c <mem_init+0x15bf>
f01029e8:	c7 44 24 0c d6 7f 10 	movl   $0xf0107fd6,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a0c:	8b 3d 8c 0e 1f f0    	mov    0xf01f0e8c,%edi
f0102a12:	89 da                	mov    %ebx,%edx
f0102a14:	89 f8                	mov    %edi,%eax
f0102a16:	e8 a1 e0 ff ff       	call   f0100abc <check_va2pa>
f0102a1b:	85 c0                	test   %eax,%eax
f0102a1d:	74 24                	je     f0102a43 <mem_init+0x15f6>
f0102a1f:	c7 44 24 0c b0 79 10 	movl   $0xf01079b0,0xc(%esp)
f0102a26:	f0 
f0102a27:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102a36:	00 
f0102a37:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102a3e:	e8 fd d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a43:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a4c:	89 c2                	mov    %eax,%edx
f0102a4e:	89 f8                	mov    %edi,%eax
f0102a50:	e8 67 e0 ff ff       	call   f0100abc <check_va2pa>
f0102a55:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a5a:	74 24                	je     f0102a80 <mem_init+0x1633>
f0102a5c:	c7 44 24 0c d4 79 10 	movl   $0xf01079d4,0xc(%esp)
f0102a63:	f0 
f0102a64:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102a6b:	f0 
f0102a6c:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102a73:	00 
f0102a74:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102a7b:	e8 c0 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a80:	89 f2                	mov    %esi,%edx
f0102a82:	89 f8                	mov    %edi,%eax
f0102a84:	e8 33 e0 ff ff       	call   f0100abc <check_va2pa>
f0102a89:	85 c0                	test   %eax,%eax
f0102a8b:	74 24                	je     f0102ab1 <mem_init+0x1664>
f0102a8d:	c7 44 24 0c 04 7a 10 	movl   $0xf0107a04,0xc(%esp)
f0102a94:	f0 
f0102a95:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102a9c:	f0 
f0102a9d:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102aa4:	00 
f0102aa5:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102aac:	e8 8f d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102ab1:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ab7:	89 f8                	mov    %edi,%eax
f0102ab9:	e8 fe df ff ff       	call   f0100abc <check_va2pa>
f0102abe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ac1:	74 24                	je     f0102ae7 <mem_init+0x169a>
f0102ac3:	c7 44 24 0c 28 7a 10 	movl   $0xf0107a28,0xc(%esp)
f0102aca:	f0 
f0102acb:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102ad2:	f0 
f0102ad3:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102ada:	00 
f0102adb:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102ae2:	e8 59 d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102ae7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102aee:	00 
f0102aef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102af3:	89 3c 24             	mov    %edi,(%esp)
f0102af6:	e8 f3 e5 ff ff       	call   f01010ee <pgdir_walk>
f0102afb:	f6 00 1a             	testb  $0x1a,(%eax)
f0102afe:	75 24                	jne    f0102b24 <mem_init+0x16d7>
f0102b00:	c7 44 24 0c 54 7a 10 	movl   $0xf0107a54,0xc(%esp)
f0102b07:	f0 
f0102b08:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102b0f:	f0 
f0102b10:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102b17:	00 
f0102b18:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102b1f:	e8 1c d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b2b:	00 
f0102b2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b30:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102b35:	89 04 24             	mov    %eax,(%esp)
f0102b38:	e8 b1 e5 ff ff       	call   f01010ee <pgdir_walk>
f0102b3d:	f6 00 04             	testb  $0x4,(%eax)
f0102b40:	74 24                	je     f0102b66 <mem_init+0x1719>
f0102b42:	c7 44 24 0c 98 7a 10 	movl   $0xf0107a98,0xc(%esp)
f0102b49:	f0 
f0102b4a:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102b51:	f0 
f0102b52:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102b59:	00 
f0102b5a:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102b61:	e8 da d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b6d:	00 
f0102b6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b72:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102b77:	89 04 24             	mov    %eax,(%esp)
f0102b7a:	e8 6f e5 ff ff       	call   f01010ee <pgdir_walk>
f0102b7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102b85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b8c:	00 
f0102b8d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b90:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102b94:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102b99:	89 04 24             	mov    %eax,(%esp)
f0102b9c:	e8 4d e5 ff ff       	call   f01010ee <pgdir_walk>
f0102ba1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102ba7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bae:	00 
f0102baf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102bb3:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102bb8:	89 04 24             	mov    %eax,(%esp)
f0102bbb:	e8 2e e5 ff ff       	call   f01010ee <pgdir_walk>
f0102bc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102bc6:	c7 04 24 e8 7f 10 f0 	movl   $0xf0107fe8,(%esp)
f0102bcd:	e8 54 13 00 00       	call   f0103f26 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U|PTE_P);
f0102bd2:	a1 90 0e 1f f0       	mov    0xf01f0e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bd7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bdc:	77 20                	ja     f0102bfe <mem_init+0x17b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bde:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102be2:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0102be9:	f0 
f0102bea:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102bf1:	00 
f0102bf2:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102bf9:	e8 42 d4 ff ff       	call   f0100040 <_panic>
f0102bfe:	8b 15 88 0e 1f f0    	mov    0xf01f0e88,%edx
f0102c04:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102c0b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c11:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c18:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c19:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c1e:	89 04 24             	mov    %eax,(%esp)
f0102c21:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c26:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102c2b:	e8 c3 e5 ff ff       	call   f01011f3 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f0102c30:	a1 48 02 1f f0       	mov    0xf01f0248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c35:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c3a:	77 20                	ja     f0102c5c <mem_init+0x180f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c40:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0102c47:	f0 
f0102c48:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102c4f:	00 
f0102c50:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102c57:	e8 e4 d3 ff ff       	call   f0100040 <_panic>
f0102c5c:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102c63:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c64:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c69:	89 04 24             	mov    %eax,(%esp)
f0102c6c:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102c71:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c76:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102c7b:	e8 73 e5 ff ff       	call   f01011f3 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0, PTE_W);
f0102c80:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c87:	00 
f0102c88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c8f:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102c94:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102c99:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102c9e:	e8 50 e5 ff ff       	call   f01011f3 <boot_map_region>
f0102ca3:	c7 45 cc 00 20 1f f0 	movl   $0xf01f2000,-0x34(%ebp)
f0102caa:	bb 00 20 1f f0       	mov    $0xf01f2000,%ebx
f0102caf:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cb4:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102cba:	77 20                	ja     f0102cdc <mem_init+0x188f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cbc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cc0:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
f0102ccf:	00 
f0102cd0:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102cd7:	e8 64 d3 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir, (uint32_t)(KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);	
f0102cdc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ce3:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ce4:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir, (uint32_t)(KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);	
f0102cea:	89 04 24             	mov    %eax,(%esp)
f0102ced:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102cf2:	89 f2                	mov    %esi,%edx
f0102cf4:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0102cf9:	e8 f5 e4 ff ff       	call   f01011f3 <boot_map_region>
f0102cfe:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d04:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
f0102d0a:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d10:	75 a2                	jne    f0102cb4 <mem_init+0x1867>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d12:	8b 1d 8c 0e 1f f0    	mov    0xf01f0e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d18:	8b 0d 88 0e 1f f0    	mov    0xf01f0e88,%ecx
f0102d1e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d21:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d28:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d2e:	be 00 00 00 00       	mov    $0x0,%esi
f0102d33:	eb 70                	jmp    f0102da5 <mem_init+0x1958>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d35:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d3b:	89 d8                	mov    %ebx,%eax
f0102d3d:	e8 7a dd ff ff       	call   f0100abc <check_va2pa>
f0102d42:	8b 15 90 0e 1f f0    	mov    0xf01f0e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d48:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d4e:	77 20                	ja     f0102d70 <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d54:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0102d5b:	f0 
f0102d5c:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102d63:	00 
f0102d64:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102d6b:	e8 d0 d2 ff ff       	call   f0100040 <_panic>
f0102d70:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d77:	39 d0                	cmp    %edx,%eax
f0102d79:	74 24                	je     f0102d9f <mem_init+0x1952>
f0102d7b:	c7 44 24 0c cc 7a 10 	movl   $0xf0107acc,0xc(%esp)
f0102d82:	f0 
f0102d83:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102d8a:	f0 
f0102d8b:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102d92:	00 
f0102d93:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102d9a:	e8 a1 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d9f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102da5:	39 f7                	cmp    %esi,%edi
f0102da7:	77 8c                	ja     f0102d35 <mem_init+0x18e8>
f0102da9:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dae:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102db4:	89 d8                	mov    %ebx,%eax
f0102db6:	e8 01 dd ff ff       	call   f0100abc <check_va2pa>
f0102dbb:	8b 15 48 02 1f f0    	mov    0xf01f0248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102dc7:	77 20                	ja     f0102de9 <mem_init+0x199c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102dcd:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0102dd4:	f0 
f0102dd5:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102ddc:	00 
f0102ddd:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102de4:	e8 57 d2 ff ff       	call   f0100040 <_panic>
f0102de9:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102df0:	39 d0                	cmp    %edx,%eax
f0102df2:	74 24                	je     f0102e18 <mem_init+0x19cb>
f0102df4:	c7 44 24 0c 00 7b 10 	movl   $0xf0107b00,0xc(%esp)
f0102dfb:	f0 
f0102dfc:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102e03:	f0 
f0102e04:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102e0b:	00 
f0102e0c:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102e13:	e8 28 d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e18:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e1e:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102e24:	75 88                	jne    f0102dae <mem_init+0x1961>
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e26:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e29:	c1 e7 0c             	shl    $0xc,%edi
f0102e2c:	be 00 00 00 00       	mov    $0x0,%esi
f0102e31:	eb 3b                	jmp    f0102e6e <mem_init+0x1a21>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e33:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	  assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e39:	89 d8                	mov    %ebx,%eax
f0102e3b:	e8 7c dc ff ff       	call   f0100abc <check_va2pa>
f0102e40:	39 c6                	cmp    %eax,%esi
f0102e42:	74 24                	je     f0102e68 <mem_init+0x1a1b>
f0102e44:	c7 44 24 0c 34 7b 10 	movl   $0xf0107b34,0xc(%esp)
f0102e4b:	f0 
f0102e4c:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102e53:	f0 
f0102e54:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102e5b:	00 
f0102e5c:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102e63:	e8 d8 d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e68:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e6e:	39 fe                	cmp    %edi,%esi
f0102e70:	72 c1                	jb     f0102e33 <mem_init+0x19e6>
f0102e72:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102e77:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e7a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e7d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e80:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e86:	89 c6                	mov    %eax,%esi
f0102e88:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102e8e:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102e94:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e97:	89 da                	mov    %ebx,%edx
f0102e99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e9c:	e8 1b dc ff ff       	call   f0100abc <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ea1:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ea8:	77 23                	ja     f0102ecd <mem_init+0x1a80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eaa:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ead:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102eb1:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0102eb8:	f0 
f0102eb9:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102ec0:	00 
f0102ec1:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102ec8:	e8 73 d1 ff ff       	call   f0100040 <_panic>
f0102ecd:	39 f0                	cmp    %esi,%eax
f0102ecf:	74 24                	je     f0102ef5 <mem_init+0x1aa8>
f0102ed1:	c7 44 24 0c 5c 7b 10 	movl   $0xf0107b5c,0xc(%esp)
f0102ed8:	f0 
f0102ed9:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102ee0:	f0 
f0102ee1:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102ee8:	00 
f0102ee9:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102ef0:	e8 4b d1 ff ff       	call   f0100040 <_panic>
f0102ef5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102efb:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f01:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f04:	0f 85 55 05 00 00    	jne    f010345f <mem_init+0x2012>
f0102f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f0f:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
					  == PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + i) == ~0);
f0102f12:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102f15:	89 f0                	mov    %esi,%eax
f0102f17:	e8 a0 db ff ff       	call   f0100abc <check_va2pa>
f0102f1c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f1f:	74 24                	je     f0102f45 <mem_init+0x1af8>
f0102f21:	c7 44 24 0c a4 7b 10 	movl   $0xf0107ba4,0xc(%esp)
f0102f28:	f0 
f0102f29:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102f30:	f0 
f0102f31:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102f38:	00 
f0102f39:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102f40:	e8 fb d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
					  == PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f45:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f4b:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f51:	75 bf                	jne    f0102f12 <mem_init+0x1ac5>
f0102f53:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102f59:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	  assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f60:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102f66:	0f 85 0e ff ff ff    	jne    f0102e7a <mem_init+0x1a2d>
f0102f6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6f:	b8 00 00 00 00       	mov    $0x0,%eax
		  assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f74:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f7a:	83 fa 04             	cmp    $0x4,%edx
f0102f7d:	77 2e                	ja     f0102fad <mem_init+0x1b60>
			case PDX(UVPT):
			case PDX(KSTACKTOP-1):
			case PDX(UPAGES):
			case PDX(UENVS):
			case PDX(MMIOBASE):
				assert(pgdir[i] & PTE_P);
f0102f7f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f83:	0f 85 aa 00 00 00    	jne    f0103033 <mem_init+0x1be6>
f0102f89:	c7 44 24 0c 01 80 10 	movl   $0xf0108001,0xc(%esp)
f0102f90:	f0 
f0102f91:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102f98:	f0 
f0102f99:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0102fa0:	00 
f0102fa1:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102fa8:	e8 93 d0 ff ff       	call   f0100040 <_panic>
				break;
			default:
				if (i >= PDX(KERNBASE)) {
f0102fad:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fb2:	76 55                	jbe    f0103009 <mem_init+0x1bbc>
					assert(pgdir[i] & PTE_P);
f0102fb4:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102fb7:	f6 c2 01             	test   $0x1,%dl
f0102fba:	75 24                	jne    f0102fe0 <mem_init+0x1b93>
f0102fbc:	c7 44 24 0c 01 80 10 	movl   $0xf0108001,0xc(%esp)
f0102fc3:	f0 
f0102fc4:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102fcb:	f0 
f0102fcc:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102fd3:	00 
f0102fd4:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0102fdb:	e8 60 d0 ff ff       	call   f0100040 <_panic>
					assert(pgdir[i] & PTE_W);
f0102fe0:	f6 c2 02             	test   $0x2,%dl
f0102fe3:	75 4e                	jne    f0103033 <mem_init+0x1be6>
f0102fe5:	c7 44 24 0c 12 80 10 	movl   $0xf0108012,0xc(%esp)
f0102fec:	f0 
f0102fed:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0102ff4:	f0 
f0102ff5:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102ffc:	00 
f0102ffd:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103004:	e8 37 d0 ff ff       	call   f0100040 <_panic>
				} else
				  assert(pgdir[i] == 0);
f0103009:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010300d:	74 24                	je     f0103033 <mem_init+0x1be6>
f010300f:	c7 44 24 0c 23 80 10 	movl   $0xf0108023,0xc(%esp)
f0103016:	f0 
f0103017:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f010301e:	f0 
f010301f:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0103026:	00 
f0103027:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010302e:	e8 0d d0 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103033:	40                   	inc    %eax
f0103034:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103039:	0f 85 35 ff ff ff    	jne    f0102f74 <mem_init+0x1b27>
				} else
				  assert(pgdir[i] == 0);
				break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010303f:	c7 04 24 c8 7b 10 f0 	movl   $0xf0107bc8,(%esp)
f0103046:	e8 db 0e 00 00       	call   f0103f26 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010304b:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103050:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103055:	77 20                	ja     f0103077 <mem_init+0x1c2a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103057:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010305b:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0103062:	f0 
f0103063:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f010306a:	00 
f010306b:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103072:	e8 c9 cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103077:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010307c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010307f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103084:	e8 4e db ff ff       	call   f0100bd7 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103089:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010308c:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103091:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103094:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010309e:	e8 1c df ff ff       	call   f0100fbf <page_alloc>
f01030a3:	89 c6                	mov    %eax,%esi
f01030a5:	85 c0                	test   %eax,%eax
f01030a7:	75 24                	jne    f01030cd <mem_init+0x1c80>
f01030a9:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f01030b0:	f0 
f01030b1:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01030b8:	f0 
f01030b9:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f01030c0:	00 
f01030c1:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01030c8:	e8 73 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030d4:	e8 e6 de ff ff       	call   f0100fbf <page_alloc>
f01030d9:	89 c7                	mov    %eax,%edi
f01030db:	85 c0                	test   %eax,%eax
f01030dd:	75 24                	jne    f0103103 <mem_init+0x1cb6>
f01030df:	c7 44 24 0c 23 7e 10 	movl   $0xf0107e23,0xc(%esp)
f01030e6:	f0 
f01030e7:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01030ee:	f0 
f01030ef:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f01030f6:	00 
f01030f7:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01030fe:	e8 3d cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103103:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010310a:	e8 b0 de ff ff       	call   f0100fbf <page_alloc>
f010310f:	89 c3                	mov    %eax,%ebx
f0103111:	85 c0                	test   %eax,%eax
f0103113:	75 24                	jne    f0103139 <mem_init+0x1cec>
f0103115:	c7 44 24 0c 39 7e 10 	movl   $0xf0107e39,0xc(%esp)
f010311c:	f0 
f010311d:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0103124:	f0 
f0103125:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f010312c:	00 
f010312d:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103134:	e8 07 cf ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103139:	89 34 24             	mov    %esi,(%esp)
f010313c:	e8 31 df ff ff       	call   f0101072 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103141:	89 f8                	mov    %edi,%eax
f0103143:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f0103149:	c1 f8 03             	sar    $0x3,%eax
f010314c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010314f:	89 c2                	mov    %eax,%edx
f0103151:	c1 ea 0c             	shr    $0xc,%edx
f0103154:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f010315a:	72 20                	jb     f010317c <mem_init+0x1d2f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010315c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103160:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0103167:	f0 
f0103168:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010316f:	00 
f0103170:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0103177:	e8 c4 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010317c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103183:	00 
f0103184:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010318b:	00 
	return (void *)(pa + KERNBASE);
f010318c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103191:	89 04 24             	mov    %eax,(%esp)
f0103194:	e8 01 2f 00 00       	call   f010609a <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103199:	89 d8                	mov    %ebx,%eax
f010319b:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f01031a1:	c1 f8 03             	sar    $0x3,%eax
f01031a4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031a7:	89 c2                	mov    %eax,%edx
f01031a9:	c1 ea 0c             	shr    $0xc,%edx
f01031ac:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f01031b2:	72 20                	jb     f01031d4 <mem_init+0x1d87>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031b8:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f01031bf:	f0 
f01031c0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031c7:	00 
f01031c8:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f01031cf:	e8 6c ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031d4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031db:	00 
f01031dc:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031e3:	00 
	return (void *)(pa + KERNBASE);
f01031e4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031e9:	89 04 24             	mov    %eax,(%esp)
f01031ec:	e8 a9 2e 00 00       	call   f010609a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01031f1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01031f8:	00 
f01031f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103200:	00 
f0103201:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103205:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f010320a:	89 04 24             	mov    %eax,(%esp)
f010320d:	e8 47 e1 ff ff       	call   f0101359 <page_insert>
	assert(pp1->pp_ref == 1);
f0103212:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103217:	74 24                	je     f010323d <mem_init+0x1df0>
f0103219:	c7 44 24 0c 0a 7f 10 	movl   $0xf0107f0a,0xc(%esp)
f0103220:	f0 
f0103221:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0103228:	f0 
f0103229:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0103230:	00 
f0103231:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103238:	e8 03 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010323d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103244:	01 01 01 
f0103247:	74 24                	je     f010326d <mem_init+0x1e20>
f0103249:	c7 44 24 0c e8 7b 10 	movl   $0xf0107be8,0xc(%esp)
f0103250:	f0 
f0103251:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0103258:	f0 
f0103259:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0103260:	00 
f0103261:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103268:	e8 d3 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010326d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103274:	00 
f0103275:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010327c:	00 
f010327d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103281:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0103286:	89 04 24             	mov    %eax,(%esp)
f0103289:	e8 cb e0 ff ff       	call   f0101359 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010328e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103295:	02 02 02 
f0103298:	74 24                	je     f01032be <mem_init+0x1e71>
f010329a:	c7 44 24 0c 0c 7c 10 	movl   $0xf0107c0c,0xc(%esp)
f01032a1:	f0 
f01032a2:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01032a9:	f0 
f01032aa:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f01032b1:	00 
f01032b2:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01032b9:	e8 82 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032be:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032c3:	74 24                	je     f01032e9 <mem_init+0x1e9c>
f01032c5:	c7 44 24 0c 2c 7f 10 	movl   $0xf0107f2c,0xc(%esp)
f01032cc:	f0 
f01032cd:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01032d4:	f0 
f01032d5:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01032dc:	00 
f01032dd:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01032e4:	e8 57 cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01032e9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01032ee:	74 24                	je     f0103314 <mem_init+0x1ec7>
f01032f0:	c7 44 24 0c 96 7f 10 	movl   $0xf0107f96,0xc(%esp)
f01032f7:	f0 
f01032f8:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01032ff:	f0 
f0103300:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0103307:	00 
f0103308:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f010330f:	e8 2c cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103314:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010331b:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010331e:	89 d8                	mov    %ebx,%eax
f0103320:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f0103326:	c1 f8 03             	sar    $0x3,%eax
f0103329:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010332c:	89 c2                	mov    %eax,%edx
f010332e:	c1 ea 0c             	shr    $0xc,%edx
f0103331:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f0103337:	72 20                	jb     f0103359 <mem_init+0x1f0c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103339:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010333d:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0103344:	f0 
f0103345:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010334c:	00 
f010334d:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0103354:	e8 e7 cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103359:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103360:	03 03 03 
f0103363:	74 24                	je     f0103389 <mem_init+0x1f3c>
f0103365:	c7 44 24 0c 30 7c 10 	movl   $0xf0107c30,0xc(%esp)
f010336c:	f0 
f010336d:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0103374:	f0 
f0103375:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f010337c:	00 
f010337d:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103384:	e8 b7 cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103389:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103390:	00 
f0103391:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f0103396:	89 04 24             	mov    %eax,(%esp)
f0103399:	e8 6b df ff ff       	call   f0101309 <page_remove>
	assert(pp2->pp_ref == 0);
f010339e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01033a3:	74 24                	je     f01033c9 <mem_init+0x1f7c>
f01033a5:	c7 44 24 0c 64 7f 10 	movl   $0xf0107f64,0xc(%esp)
f01033ac:	f0 
f01033ad:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01033b4:	f0 
f01033b5:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f01033bc:	00 
f01033bd:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f01033c4:	e8 77 cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033c9:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
f01033ce:	8b 08                	mov    (%eax),%ecx
f01033d0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033d6:	89 f2                	mov    %esi,%edx
f01033d8:	2b 15 90 0e 1f f0    	sub    0xf01f0e90,%edx
f01033de:	c1 fa 03             	sar    $0x3,%edx
f01033e1:	c1 e2 0c             	shl    $0xc,%edx
f01033e4:	39 d1                	cmp    %edx,%ecx
f01033e6:	74 24                	je     f010340c <mem_init+0x1fbf>
f01033e8:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f01033ef:	f0 
f01033f0:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f01033f7:	f0 
f01033f8:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f01033ff:	00 
f0103400:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103407:	e8 34 cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010340c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103412:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103417:	74 24                	je     f010343d <mem_init+0x1ff0>
f0103419:	c7 44 24 0c 1b 7f 10 	movl   $0xf0107f1b,0xc(%esp)
f0103420:	f0 
f0103421:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0103428:	f0 
f0103429:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0103430:	00 
f0103431:	c7 04 24 bd 7c 10 f0 	movl   $0xf0107cbd,(%esp)
f0103438:	e8 03 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010343d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103443:	89 34 24             	mov    %esi,(%esp)
f0103446:	e8 27 dc ff ff       	call   f0101072 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010344b:	c7 04 24 5c 7c 10 f0 	movl   $0xf0107c5c,(%esp)
f0103452:	e8 cf 0a 00 00       	call   f0103f26 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103457:	83 c4 3c             	add    $0x3c,%esp
f010345a:	5b                   	pop    %ebx
f010345b:	5e                   	pop    %esi
f010345c:	5f                   	pop    %edi
f010345d:	5d                   	pop    %ebp
f010345e:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010345f:	89 da                	mov    %ebx,%edx
f0103461:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103464:	e8 53 d6 ff ff       	call   f0100abc <check_va2pa>
f0103469:	e9 5f fa ff ff       	jmp    f0102ecd <mem_init+0x1a80>

f010346e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010346e:	55                   	push   %ebp
f010346f:	89 e5                	mov    %esp,%ebp
f0103471:	57                   	push   %edi
f0103472:	56                   	push   %esi
f0103473:	53                   	push   %ebx
f0103474:	83 ec 1c             	sub    $0x1c,%esp
f0103477:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010347a:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.

	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
f010347d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103480:	a3 44 02 1f f0       	mov    %eax,0xf01f0244
	pte_t* pte;	

	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f0103485:	89 c6                	mov    %eax,%esi
f0103487:	03 75 10             	add    0x10(%ebp),%esi
f010348a:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0103490:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0103496:	eb 5e                	jmp    f01034f6 <user_mem_check+0x88>
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
f0103498:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010349f:	00 
f01034a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034a9:	8b 43 60             	mov    0x60(%ebx),%eax
f01034ac:	89 04 24             	mov    %eax,(%esp)
f01034af:	e8 3a dc ff ff       	call   f01010ee <pgdir_walk>
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
f01034b4:	85 c0                	test   %eax,%eax
f01034b6:	74 19                	je     f01034d1 <user_mem_check+0x63>
f01034b8:	8b 00                	mov    (%eax),%eax
f01034ba:	89 fa                	mov    %edi,%edx
f01034bc:	83 ca 01             	or     $0x1,%edx
f01034bf:	09 c2                	or     %eax,%edx
f01034c1:	39 d0                	cmp    %edx,%eax
f01034c3:	75 0c                	jne    f01034d1 <user_mem_check+0x63>
f01034c5:	a1 44 02 1f f0       	mov    0xf01f0244,%eax
f01034ca:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01034cf:	76 1b                	jbe    f01034ec <user_mem_check+0x7e>
			if (user_mem_check_addr != start)
f01034d1:	a1 44 02 1f f0       	mov    0xf01f0244,%eax
f01034d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
f01034d9:	74 2b                	je     f0103506 <user_mem_check+0x98>
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
f01034db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034e0:	a3 44 02 1f f0       	mov    %eax,0xf01f0244
			return -E_FAULT;
f01034e5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01034ea:	eb 1f                	jmp    f010350b <user_mem_check+0x9d>

	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
	pte_t* pte;	

	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f01034ec:	05 00 10 00 00       	add    $0x1000,%eax
f01034f1:	a3 44 02 1f f0       	mov    %eax,0xf01f0244
f01034f6:	a1 44 02 1f f0       	mov    0xf01f0244,%eax
f01034fb:	39 c6                	cmp    %eax,%esi
f01034fd:	77 99                	ja     f0103498 <user_mem_check+0x2a>
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
		}
	}

	return 0;
f01034ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0103504:	eb 05                	jmp    f010350b <user_mem_check+0x9d>
	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
			if (user_mem_check_addr != start)
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
f0103506:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		}
	}

	return 0;
}
f010350b:	83 c4 1c             	add    $0x1c,%esp
f010350e:	5b                   	pop    %ebx
f010350f:	5e                   	pop    %esi
f0103510:	5f                   	pop    %edi
f0103511:	5d                   	pop    %ebp
f0103512:	c3                   	ret    

f0103513 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103513:	55                   	push   %ebp
f0103514:	89 e5                	mov    %esp,%ebp
f0103516:	53                   	push   %ebx
f0103517:	83 ec 14             	sub    $0x14,%esp
f010351a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010351d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103520:	83 c8 04             	or     $0x4,%eax
f0103523:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103527:	8b 45 10             	mov    0x10(%ebp),%eax
f010352a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010352e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103531:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103535:	89 1c 24             	mov    %ebx,(%esp)
f0103538:	e8 31 ff ff ff       	call   f010346e <user_mem_check>
f010353d:	85 c0                	test   %eax,%eax
f010353f:	79 24                	jns    f0103565 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103541:	a1 44 02 1f f0       	mov    0xf01f0244,%eax
f0103546:	89 44 24 08          	mov    %eax,0x8(%esp)
f010354a:	8b 43 48             	mov    0x48(%ebx),%eax
f010354d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103551:	c7 04 24 88 7c 10 f0 	movl   $0xf0107c88,(%esp)
f0103558:	e8 c9 09 00 00       	call   f0103f26 <cprintf>
					"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010355d:	89 1c 24             	mov    %ebx,(%esp)
f0103560:	e8 f8 06 00 00       	call   f0103c5d <env_destroy>
	}
}
f0103565:	83 c4 14             	add    $0x14,%esp
f0103568:	5b                   	pop    %ebx
f0103569:	5d                   	pop    %ebp
f010356a:	c3                   	ret    
	...

f010356c <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010356c:	55                   	push   %ebp
f010356d:	89 e5                	mov    %esp,%ebp
f010356f:	57                   	push   %edi
f0103570:	56                   	push   %esi
f0103571:	53                   	push   %ebx
f0103572:	83 ec 1c             	sub    $0x1c,%esp
f0103575:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
f0103577:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f010357e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103583:	89 c7                	mov    %eax,%edi
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
f0103585:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f010358a:	77 0d                	ja     f0103599 <region_alloc+0x2d>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
f010358c:	89 d3                	mov    %edx,%ebx
f010358e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103594:	e9 89 00 00 00       	jmp    f0103622 <region_alloc+0xb6>
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
f0103599:	c7 44 24 08 34 80 10 	movl   $0xf0108034,0x8(%esp)
f01035a0:	f0 
f01035a1:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
f01035a8:	00 
f01035a9:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f01035b0:	e8 8b ca ff ff       	call   f0100040 <_panic>
	int r;
	for (; min<max; min+=PGSIZE){
		pp = page_alloc(0);	
f01035b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035bc:	e8 fe d9 ff ff       	call   f0100fbf <page_alloc>
		if (!pp) 	
f01035c1:	85 c0                	test   %eax,%eax
f01035c3:	75 1c                	jne    f01035e1 <region_alloc+0x75>
			panic("region_alloc:page alloc failed");
f01035c5:	c7 44 24 08 54 80 10 	movl   $0xf0108054,0x8(%esp)
f01035cc:	f0 
f01035cd:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f01035d4:	00 
f01035d5:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f01035dc:	e8 5f ca ff ff       	call   f0100040 <_panic>
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
f01035e1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035e8:	00 
f01035e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035ed:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035f1:	8b 46 60             	mov    0x60(%esi),%eax
f01035f4:	89 04 24             	mov    %eax,(%esp)
f01035f7:	e8 5d dd ff ff       	call   f0101359 <page_insert>
		if (r != 0) 
f01035fc:	85 c0                	test   %eax,%eax
f01035fe:	74 1c                	je     f010361c <region_alloc+0xb0>
			panic("region_alloc: page insert failed");
f0103600:	c7 44 24 08 74 80 10 	movl   $0xf0108074,0x8(%esp)
f0103607:	f0 
f0103608:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f010360f:	00 
f0103610:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103617:	e8 24 ca ff ff       	call   f0100040 <_panic>
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
	int r;
	for (; min<max; min+=PGSIZE){
f010361c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103622:	39 fb                	cmp    %edi,%ebx
f0103624:	72 8f                	jb     f01035b5 <region_alloc+0x49>
			panic("region_alloc:page alloc failed");
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
		if (r != 0) 
			panic("region_alloc: page insert failed");
	}
}
f0103626:	83 c4 1c             	add    $0x1c,%esp
f0103629:	5b                   	pop    %ebx
f010362a:	5e                   	pop    %esi
f010362b:	5f                   	pop    %edi
f010362c:	5d                   	pop    %ebp
f010362d:	c3                   	ret    

f010362e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010362e:	55                   	push   %ebp
f010362f:	89 e5                	mov    %esp,%ebp
f0103631:	57                   	push   %edi
f0103632:	56                   	push   %esi
f0103633:	53                   	push   %ebx
f0103634:	83 ec 0c             	sub    $0xc,%esp
f0103637:	8b 45 08             	mov    0x8(%ebp),%eax
f010363a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010363d:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103640:	85 c0                	test   %eax,%eax
f0103642:	75 24                	jne    f0103668 <envid2env+0x3a>
		*env_store = curenv;
f0103644:	e8 7f 30 00 00       	call   f01066c8 <cpunum>
f0103649:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103650:	29 c2                	sub    %eax,%edx
f0103652:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103655:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f010365c:	89 06                	mov    %eax,(%esi)
		return 0;
f010365e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103663:	e9 84 00 00 00       	jmp    f01036ec <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103668:	89 c3                	mov    %eax,%ebx
f010366a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103670:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103677:	c1 e3 07             	shl    $0x7,%ebx
f010367a:	29 cb                	sub    %ecx,%ebx
f010367c:	03 1d 48 02 1f f0    	add    0xf01f0248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103682:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103686:	74 05                	je     f010368d <envid2env+0x5f>
f0103688:	39 43 48             	cmp    %eax,0x48(%ebx)
f010368b:	74 0d                	je     f010369a <envid2env+0x6c>
		*env_store = 0;
f010368d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103693:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103698:	eb 52                	jmp    f01036ec <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010369a:	84 d2                	test   %dl,%dl
f010369c:	74 47                	je     f01036e5 <envid2env+0xb7>
f010369e:	e8 25 30 00 00       	call   f01066c8 <cpunum>
f01036a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036aa:	29 c2                	sub    %eax,%edx
f01036ac:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036af:	39 1c 85 28 10 1f f0 	cmp    %ebx,-0xfe0efd8(,%eax,4)
f01036b6:	74 2d                	je     f01036e5 <envid2env+0xb7>
f01036b8:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01036bb:	e8 08 30 00 00       	call   f01066c8 <cpunum>
f01036c0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036c7:	29 c2                	sub    %eax,%edx
f01036c9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036cc:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f01036d3:	3b 78 48             	cmp    0x48(%eax),%edi
f01036d6:	74 0d                	je     f01036e5 <envid2env+0xb7>
		*env_store = 0;
f01036d8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036de:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036e3:	eb 07                	jmp    f01036ec <envid2env+0xbe>
	}

	*env_store = e;
f01036e5:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036ec:	83 c4 0c             	add    $0xc,%esp
f01036ef:	5b                   	pop    %ebx
f01036f0:	5e                   	pop    %esi
f01036f1:	5f                   	pop    %edi
f01036f2:	5d                   	pop    %ebp
f01036f3:	c3                   	ret    

f01036f4 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01036f4:	55                   	push   %ebp
f01036f5:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01036f7:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f01036fc:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01036ff:	b8 23 00 00 00       	mov    $0x23,%eax
f0103704:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103706:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103708:	b0 10                	mov    $0x10,%al
f010370a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010370c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010370e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103710:	ea 17 37 10 f0 08 00 	ljmp   $0x8,$0xf0103717
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103717:	b0 00                	mov    $0x0,%al
f0103719:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010371c:	5d                   	pop    %ebp
f010371d:	c3                   	ret    

f010371e <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010371e:	55                   	push   %ebp
f010371f:	89 e5                	mov    %esp,%ebp
f0103721:	56                   	push   %esi
f0103722:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f0103723:	8b 35 48 02 1f f0    	mov    0xf01f0248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103729:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010372f:	b9 00 00 00 00       	mov    $0x0,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f0103734:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0103739:	eb 02                	jmp    f010373d <env_init+0x1f>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f010373b:	89 d9                	mov    %ebx,%ecx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f010373d:	89 c3                	mov    %eax,%ebx
f010373f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103746:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010374d:	89 48 44             	mov    %ecx,0x44(%eax)
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f0103750:	4a                   	dec    %edx
f0103751:	83 e8 7c             	sub    $0x7c,%eax
f0103754:	83 fa ff             	cmp    $0xffffffff,%edx
f0103757:	75 e2                	jne    f010373b <env_init+0x1d>
f0103759:	89 35 4c 02 1f f0    	mov    %esi,0xf01f024c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f010375f:	e8 90 ff ff ff       	call   f01036f4 <env_init_percpu>
}
f0103764:	5b                   	pop    %ebx
f0103765:	5e                   	pop    %esi
f0103766:	5d                   	pop    %ebp
f0103767:	c3                   	ret    

f0103768 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103768:	55                   	push   %ebp
f0103769:	89 e5                	mov    %esp,%ebp
f010376b:	56                   	push   %esi
f010376c:	53                   	push   %ebx
f010376d:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103770:	8b 1d 4c 02 1f f0    	mov    0xf01f024c,%ebx
f0103776:	85 db                	test   %ebx,%ebx
f0103778:	0f 84 69 01 00 00    	je     f01038e7 <env_alloc+0x17f>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010377e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103785:	e8 35 d8 ff ff       	call   f0100fbf <page_alloc>
f010378a:	89 c6                	mov    %eax,%esi
f010378c:	85 c0                	test   %eax,%eax
f010378e:	0f 84 5a 01 00 00    	je     f01038ee <env_alloc+0x186>
f0103794:	2b 05 90 0e 1f f0    	sub    0xf01f0e90,%eax
f010379a:	c1 f8 03             	sar    $0x3,%eax
f010379d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037a0:	89 c2                	mov    %eax,%edx
f01037a2:	c1 ea 0c             	shr    $0xc,%edx
f01037a5:	3b 15 88 0e 1f f0    	cmp    0xf01f0e88,%edx
f01037ab:	72 20                	jb     f01037cd <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037b1:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f01037b8:	f0 
f01037b9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037c0:	00 
f01037c1:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f01037c8:	e8 73 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037cd:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	e->env_pgdir = page2kva(p);
f01037d2:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);	
f01037d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037dc:	00 
f01037dd:	8b 15 8c 0e 1f f0    	mov    0xf01f0e8c,%edx
f01037e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037e7:	89 04 24             	mov    %eax,(%esp)
f01037ea:	e8 5f 29 00 00       	call   f010614e <memcpy>
	p->pp_ref++;
f01037ef:	66 ff 46 04          	incw   0x4(%esi)


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037f3:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037f6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037fb:	77 20                	ja     f010381d <env_alloc+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103801:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0103808:	f0 
f0103809:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103810:	00 
f0103811:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103818:	e8 23 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010381d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103823:	83 ca 05             	or     $0x5,%edx
f0103826:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010382c:	8b 43 48             	mov    0x48(%ebx),%eax
f010382f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103834:	89 c1                	mov    %eax,%ecx
f0103836:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010383c:	7f 05                	jg     f0103843 <env_alloc+0xdb>
		generation = 1 << ENVGENSHIFT;
f010383e:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103843:	89 d8                	mov    %ebx,%eax
f0103845:	2b 05 48 02 1f f0    	sub    0xf01f0248,%eax
f010384b:	c1 f8 02             	sar    $0x2,%eax
f010384e:	89 c6                	mov    %eax,%esi
f0103850:	c1 e6 05             	shl    $0x5,%esi
f0103853:	89 c2                	mov    %eax,%edx
f0103855:	c1 e2 0a             	shl    $0xa,%edx
f0103858:	01 f2                	add    %esi,%edx
f010385a:	01 c2                	add    %eax,%edx
f010385c:	89 d6                	mov    %edx,%esi
f010385e:	c1 e6 0f             	shl    $0xf,%esi
f0103861:	01 f2                	add    %esi,%edx
f0103863:	c1 e2 05             	shl    $0x5,%edx
f0103866:	01 d0                	add    %edx,%eax
f0103868:	f7 d8                	neg    %eax
f010386a:	09 c1                	or     %eax,%ecx
f010386c:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010386f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103872:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103875:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010387c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103883:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010388a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103891:	00 
f0103892:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103899:	00 
f010389a:	89 1c 24             	mov    %ebx,(%esp)
f010389d:	e8 f8 27 00 00       	call   f010609a <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01038a2:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01038a8:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01038ae:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01038b4:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038bb:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF; 
f01038c1:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
		
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01038c8:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01038cf:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01038d3:	8b 43 44             	mov    0x44(%ebx),%eax
f01038d6:	a3 4c 02 1f f0       	mov    %eax,0xf01f024c
	*newenv_store = e;
f01038db:	8b 45 08             	mov    0x8(%ebp),%eax
f01038de:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01038e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e5:	eb 0c                	jmp    f01038f3 <env_alloc+0x18b>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038e7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038ec:	eb 05                	jmp    f01038f3 <env_alloc+0x18b>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038ee:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038f3:	83 c4 10             	add    $0x10,%esp
f01038f6:	5b                   	pop    %ebx
f01038f7:	5e                   	pop    %esi
f01038f8:	5d                   	pop    %ebp
f01038f9:	c3                   	ret    

f01038fa <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038fa:	55                   	push   %ebp
f01038fb:	89 e5                	mov    %esp,%ebp
f01038fd:	57                   	push   %edi
f01038fe:	56                   	push   %esi
f01038ff:	53                   	push   %ebx
f0103900:	83 ec 3c             	sub    $0x3c,%esp
f0103903:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103906:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env* e;
	int ret = env_alloc(&e, 0);
f0103909:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103910:	00 
f0103911:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103914:	89 04 24             	mov    %eax,(%esp)
f0103917:	e8 4c fe ff ff       	call   f0103768 <env_alloc>
	if (ret == -E_NO_FREE_ENV )
f010391c:	83 f8 fb             	cmp    $0xfffffffb,%eax
f010391f:	75 24                	jne    f0103945 <env_create+0x4b>
		panic("env_create:failed no free env %e", ret);
f0103921:	c7 44 24 0c fb ff ff 	movl   $0xfffffffb,0xc(%esp)
f0103928:	ff 
f0103929:	c7 44 24 08 98 80 10 	movl   $0xf0108098,0x8(%esp)
f0103930:	f0 
f0103931:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f0103938:	00 
f0103939:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103940:	e8 fb c6 ff ff       	call   f0100040 <_panic>
	if (ret == -E_NO_MEM)
f0103945:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103948:	75 24                	jne    f010396e <env_create+0x74>
		panic("env_create:failed no free mem %e", ret);
f010394a:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f0103951:	ff 
f0103952:	c7 44 24 08 bc 80 10 	movl   $0xf01080bc,0x8(%esp)
f0103959:	f0 
f010395a:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f0103961:	00 
f0103962:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103969:	e8 d2 c6 ff ff       	call   f0100040 <_panic>
	e->env_type = type;
f010396e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103971:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103974:	89 58 50             	mov    %ebx,0x50(%eax)
	if (type == ENV_TYPE_FS) 
f0103977:	83 fb 01             	cmp    $0x1,%ebx
f010397a:	75 07                	jne    f0103983 <env_create+0x89>
		e->env_tf.tf_eflags |= FL_IOPL_3;
f010397c:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf*)binary;  //elf header
	if (elf->e_magic != ELF_MAGIC) 
f0103983:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103989:	74 1c                	je     f01039a7 <env_create+0xad>
		panic("load_icode: illegal elf header");
f010398b:	c7 44 24 08 e0 80 10 	movl   $0xf01080e0,0x8(%esp)
f0103992:	f0 
f0103993:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f010399a:	00 
f010399b:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f01039a2:	e8 99 c6 ff ff       	call   f0100040 <_panic>
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
f01039a7:	89 fb                	mov    %edi,%ebx
f01039a9:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* eph = ph + elf->e_phnum;
f01039ac:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039b0:	c1 e6 05             	shl    $0x5,%esi
f01039b3:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f01039b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039b8:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039c0:	77 20                	ja     f01039e2 <env_create+0xe8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039c6:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f01039cd:	f0 
f01039ce:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01039d5:	00 
f01039d6:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f01039dd:	e8 5e c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039e2:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039e7:	0f 22 d8             	mov    %eax,%cr3
f01039ea:	eb 71                	jmp    f0103a5d <env_create+0x163>

	for (; ph < eph; ph++) {
		if(ph->p_type != ELF_PROG_LOAD)
f01039ec:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039ef:	75 69                	jne    f0103a5a <env_create+0x160>
			continue;
		if (ph->p_filesz > ph->p_memsz) 
f01039f1:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039f4:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01039f7:	76 1c                	jbe    f0103a15 <env_create+0x11b>
			panic("load_icode:file size is larger than mem size");
f01039f9:	c7 44 24 08 00 81 10 	movl   $0xf0108100,0x8(%esp)
f0103a00:	f0 
f0103a01:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0103a08:	00 
f0103a09:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103a10:	e8 2b c6 ff ff       	call   f0100040 <_panic>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
f0103a15:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a1b:	e8 4c fb ff ff       	call   f010356c <region_alloc>
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103a20:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a27:	89 f8                	mov    %edi,%eax
f0103a29:	03 43 04             	add    0x4(%ebx),%eax
f0103a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a30:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a33:	89 04 24             	mov    %eax,(%esp)
f0103a36:	e8 a9 26 00 00       	call   f01060e4 <memmove>
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
f0103a3b:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a3e:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a41:	29 c2                	sub    %eax,%edx
f0103a43:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a4e:	00 
f0103a4f:	03 43 08             	add    0x8(%ebx),%eax
f0103a52:	89 04 24             	mov    %eax,(%esp)
f0103a55:	e8 40 26 00 00       	call   f010609a <memset>
		panic("load_icode: illegal elf header");
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
	struct Proghdr* eph = ph + elf->e_phnum;
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++) {
f0103a5a:	83 c3 20             	add    $0x20,%ebx
f0103a5d:	39 de                	cmp    %ebx,%esi
f0103a5f:	77 8b                	ja     f01039ec <env_create+0xf2>
			panic("load_icode:file size is larger than mem size");
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
	}
	e->env_tf.tf_eip = elf->e_entry; 
f0103a61:	8b 47 18             	mov    0x18(%edi),%eax
f0103a64:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a67:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	//lcr3(PADDR(kern_pgdir));
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);		
f0103a6a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a6f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a77:	e8 f0 fa ff ff       	call   f010356c <region_alloc>
	if (type == ENV_TYPE_FS) 
		e->env_tf.tf_eflags |= FL_IOPL_3;
	
	load_icode(e, binary);

}
f0103a7c:	83 c4 3c             	add    $0x3c,%esp
f0103a7f:	5b                   	pop    %ebx
f0103a80:	5e                   	pop    %esi
f0103a81:	5f                   	pop    %edi
f0103a82:	5d                   	pop    %ebp
f0103a83:	c3                   	ret    

f0103a84 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a84:	55                   	push   %ebp
f0103a85:	89 e5                	mov    %esp,%ebp
f0103a87:	57                   	push   %edi
f0103a88:	56                   	push   %esi
f0103a89:	53                   	push   %ebx
f0103a8a:	83 ec 2c             	sub    $0x2c,%esp
f0103a8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a90:	e8 33 2c 00 00       	call   f01066c8 <cpunum>
f0103a95:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a9c:	29 c2                	sub    %eax,%edx
f0103a9e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103aa1:	39 3c 85 28 10 1f f0 	cmp    %edi,-0xfe0efd8(,%eax,4)
f0103aa8:	75 3d                	jne    f0103ae7 <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f0103aaa:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103aaf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ab4:	77 20                	ja     f0103ad6 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ab6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aba:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0103ac1:	f0 
f0103ac2:	c7 44 24 04 b3 01 00 	movl   $0x1b3,0x4(%esp)
f0103ac9:	00 
f0103aca:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103ad1:	e8 6a c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ad6:	05 00 00 00 10       	add    $0x10000000,%eax
f0103adb:	0f 22 d8             	mov    %eax,%cr3
f0103ade:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103ae5:	eb 07                	jmp    f0103aee <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ae7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103aee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103af1:	c1 e0 02             	shl    $0x2,%eax
f0103af4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103af7:	8b 47 60             	mov    0x60(%edi),%eax
f0103afa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103afd:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103b00:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b06:	0f 84 b6 00 00 00    	je     f0103bc2 <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b0c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b12:	89 f0                	mov    %esi,%eax
f0103b14:	c1 e8 0c             	shr    $0xc,%eax
f0103b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b1a:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f0103b20:	72 20                	jb     f0103b42 <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b22:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b26:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0103b2d:	f0 
f0103b2e:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
f0103b35:	00 
f0103b36:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103b3d:	e8 fe c4 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b42:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b45:	c1 e2 16             	shl    $0x16,%edx
f0103b48:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b50:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b57:	01 
f0103b58:	74 17                	je     f0103b71 <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b5a:	89 d8                	mov    %ebx,%eax
f0103b5c:	c1 e0 0c             	shl    $0xc,%eax
f0103b5f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b66:	8b 47 60             	mov    0x60(%edi),%eax
f0103b69:	89 04 24             	mov    %eax,(%esp)
f0103b6c:	e8 98 d7 ff ff       	call   f0101309 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b71:	43                   	inc    %ebx
f0103b72:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b78:	75 d6                	jne    f0103b50 <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b7a:	8b 47 60             	mov    0x60(%edi),%eax
f0103b7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b80:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b87:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b8a:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f0103b90:	72 1c                	jb     f0103bae <env_free+0x12a>
		panic("pa2page called with invalid pa");
f0103b92:	c7 44 24 08 84 74 10 	movl   $0xf0107484,0x8(%esp)
f0103b99:	f0 
f0103b9a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ba1:	00 
f0103ba2:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0103ba9:	e8 92 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bae:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bb1:	c1 e0 03             	shl    $0x3,%eax
f0103bb4:	03 05 90 0e 1f f0    	add    0xf01f0e90,%eax
		page_decref(pa2page(pa));
f0103bba:	89 04 24             	mov    %eax,(%esp)
f0103bbd:	e8 0c d5 ff ff       	call   f01010ce <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bc2:	ff 45 e0             	incl   -0x20(%ebp)
f0103bc5:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bcc:	0f 85 1c ff ff ff    	jne    f0103aee <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bd2:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bd5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bda:	77 20                	ja     f0103bfc <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103be0:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0103be7:	f0 
f0103be8:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
f0103bef:	00 
f0103bf0:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103bf7:	e8 44 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103bfc:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c03:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103c08:	c1 e8 0c             	shr    $0xc,%eax
f0103c0b:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f0103c11:	72 1c                	jb     f0103c2f <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103c13:	c7 44 24 08 84 74 10 	movl   $0xf0107484,0x8(%esp)
f0103c1a:	f0 
f0103c1b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c22:	00 
f0103c23:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0103c2a:	e8 11 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c2f:	c1 e0 03             	shl    $0x3,%eax
f0103c32:	03 05 90 0e 1f f0    	add    0xf01f0e90,%eax
	page_decref(pa2page(pa));
f0103c38:	89 04 24             	mov    %eax,(%esp)
f0103c3b:	e8 8e d4 ff ff       	call   f01010ce <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c40:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c47:	a1 4c 02 1f f0       	mov    0xf01f024c,%eax
f0103c4c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c4f:	89 3d 4c 02 1f f0    	mov    %edi,0xf01f024c
}
f0103c55:	83 c4 2c             	add    $0x2c,%esp
f0103c58:	5b                   	pop    %ebx
f0103c59:	5e                   	pop    %esi
f0103c5a:	5f                   	pop    %edi
f0103c5b:	5d                   	pop    %ebp
f0103c5c:	c3                   	ret    

f0103c5d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c5d:	55                   	push   %ebp
f0103c5e:	89 e5                	mov    %esp,%ebp
f0103c60:	53                   	push   %ebx
f0103c61:	83 ec 14             	sub    $0x14,%esp
f0103c64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c67:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c6b:	75 23                	jne    f0103c90 <env_destroy+0x33>
f0103c6d:	e8 56 2a 00 00       	call   f01066c8 <cpunum>
f0103c72:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c79:	29 c2                	sub    %eax,%edx
f0103c7b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c7e:	39 1c 85 28 10 1f f0 	cmp    %ebx,-0xfe0efd8(,%eax,4)
f0103c85:	74 09                	je     f0103c90 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103c87:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c8e:	eb 39                	jmp    f0103cc9 <env_destroy+0x6c>
	}

	env_free(e);
f0103c90:	89 1c 24             	mov    %ebx,(%esp)
f0103c93:	e8 ec fd ff ff       	call   f0103a84 <env_free>

	if (curenv == e) {
f0103c98:	e8 2b 2a 00 00       	call   f01066c8 <cpunum>
f0103c9d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ca4:	29 c2                	sub    %eax,%edx
f0103ca6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca9:	39 1c 85 28 10 1f f0 	cmp    %ebx,-0xfe0efd8(,%eax,4)
f0103cb0:	75 17                	jne    f0103cc9 <env_destroy+0x6c>
		curenv = NULL;
f0103cb2:	e8 11 2a 00 00       	call   f01066c8 <cpunum>
f0103cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cba:	c7 80 28 10 1f f0 00 	movl   $0x0,-0xfe0efd8(%eax)
f0103cc1:	00 00 00 
		sched_yield();
f0103cc4:	e8 31 10 00 00       	call   f0104cfa <sched_yield>
	}
}
f0103cc9:	83 c4 14             	add    $0x14,%esp
f0103ccc:	5b                   	pop    %ebx
f0103ccd:	5d                   	pop    %ebp
f0103cce:	c3                   	ret    

f0103ccf <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ccf:	55                   	push   %ebp
f0103cd0:	89 e5                	mov    %esp,%ebp
f0103cd2:	53                   	push   %ebx
f0103cd3:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cd6:	e8 ed 29 00 00       	call   f01066c8 <cpunum>
f0103cdb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ce2:	29 c2                	sub    %eax,%edx
f0103ce4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ce7:	8b 1c 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%ebx
f0103cee:	e8 d5 29 00 00       	call   f01066c8 <cpunum>
f0103cf3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103cf6:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cf9:	61                   	popa   
f0103cfa:	07                   	pop    %es
f0103cfb:	1f                   	pop    %ds
f0103cfc:	83 c4 08             	add    $0x8,%esp
f0103cff:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103d00:	c7 44 24 08 38 81 10 	movl   $0xf0108138,0x8(%esp)
f0103d07:	f0 
f0103d08:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
f0103d0f:	00 
f0103d10:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103d17:	e8 24 c3 ff ff       	call   f0100040 <_panic>

f0103d1c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d1c:	55                   	push   %ebp
f0103d1d:	89 e5                	mov    %esp,%ebp
f0103d1f:	53                   	push   %ebx
f0103d20:	83 ec 14             	sub    $0x14,%esp
f0103d23:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.
	
	//panic("env_run not yet implemented");
	
	if (curenv){
f0103d26:	e8 9d 29 00 00       	call   f01066c8 <cpunum>
f0103d2b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d32:	29 c2                	sub    %eax,%edx
f0103d34:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d37:	83 3c 85 28 10 1f f0 	cmpl   $0x0,-0xfe0efd8(,%eax,4)
f0103d3e:	00 
f0103d3f:	74 33                	je     f0103d74 <env_run+0x58>
		if (curenv->env_status == ENV_RUNNING) 
f0103d41:	e8 82 29 00 00       	call   f01066c8 <cpunum>
f0103d46:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d4d:	29 c2                	sub    %eax,%edx
f0103d4f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d52:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0103d59:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d5d:	75 15                	jne    f0103d74 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103d5f:	e8 64 29 00 00       	call   f01066c8 <cpunum>
f0103d64:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d67:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0103d6d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	
	curenv = e;
f0103d74:	e8 4f 29 00 00       	call   f01066c8 <cpunum>
f0103d79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d80:	29 c2                	sub    %eax,%edx
f0103d82:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d85:	89 1c 85 28 10 1f f0 	mov    %ebx,-0xfe0efd8(,%eax,4)
	e->env_status = ENV_RUNNING;
f0103d8c:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103d93:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0103d96:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d99:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d9e:	77 20                	ja     f0103dc0 <env_run+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103da0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103da4:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0103dab:	f0 
f0103dac:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
f0103db3:	00 
f0103db4:	c7 04 24 2d 81 10 f0 	movl   $0xf010812d,(%esp)
f0103dbb:	e8 80 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103dc0:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dc5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dc8:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0103dcf:	e8 56 2c 00 00       	call   f0106a2a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103dd4:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&(e->env_tf));		
f0103dd6:	89 1c 24             	mov    %ebx,(%esp)
f0103dd9:	e8 f1 fe ff ff       	call   f0103ccf <env_pop_tf>
	...

f0103de0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103de0:	55                   	push   %ebp
f0103de1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103de3:	ba 70 00 00 00       	mov    $0x70,%edx
f0103de8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103deb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103dec:	b2 71                	mov    $0x71,%dl
f0103dee:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103def:	0f b6 c0             	movzbl %al,%eax
}
f0103df2:	5d                   	pop    %ebp
f0103df3:	c3                   	ret    

f0103df4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103df4:	55                   	push   %ebp
f0103df5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103df7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103dfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dff:	ee                   	out    %al,(%dx)
f0103e00:	b2 71                	mov    $0x71,%dl
f0103e02:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e05:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103e06:	5d                   	pop    %ebp
f0103e07:	c3                   	ret    

f0103e08 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103e08:	55                   	push   %ebp
f0103e09:	89 e5                	mov    %esp,%ebp
f0103e0b:	56                   	push   %esi
f0103e0c:	53                   	push   %ebx
f0103e0d:	83 ec 10             	sub    $0x10,%esp
f0103e10:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e13:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e15:	66 a3 a8 93 12 f0    	mov    %ax,0xf01293a8
	if (!didinit)
f0103e1b:	80 3d 50 02 1f f0 00 	cmpb   $0x0,0xf01f0250
f0103e22:	74 51                	je     f0103e75 <irq_setmask_8259A+0x6d>
f0103e24:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e29:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e2a:	89 f0                	mov    %esi,%eax
f0103e2c:	66 c1 e8 08          	shr    $0x8,%ax
f0103e30:	b2 a1                	mov    $0xa1,%dl
f0103e32:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e33:	c7 04 24 44 81 10 f0 	movl   $0xf0108144,(%esp)
f0103e3a:	e8 e7 00 00 00       	call   f0103f26 <cprintf>
	for (i = 0; i < 16; i++)
f0103e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e44:	0f b7 f6             	movzwl %si,%esi
f0103e47:	f7 d6                	not    %esi
f0103e49:	89 f0                	mov    %esi,%eax
f0103e4b:	88 d9                	mov    %bl,%cl
f0103e4d:	d3 f8                	sar    %cl,%eax
f0103e4f:	a8 01                	test   $0x1,%al
f0103e51:	74 10                	je     f0103e63 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103e53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e57:	c7 04 24 57 88 10 f0 	movl   $0xf0108857,(%esp)
f0103e5e:	e8 c3 00 00 00       	call   f0103f26 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e63:	43                   	inc    %ebx
f0103e64:	83 fb 10             	cmp    $0x10,%ebx
f0103e67:	75 e0                	jne    f0103e49 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e69:	c7 04 24 ff 7f 10 f0 	movl   $0xf0107fff,(%esp)
f0103e70:	e8 b1 00 00 00       	call   f0103f26 <cprintf>
}
f0103e75:	83 c4 10             	add    $0x10,%esp
f0103e78:	5b                   	pop    %ebx
f0103e79:	5e                   	pop    %esi
f0103e7a:	5d                   	pop    %ebp
f0103e7b:	c3                   	ret    

f0103e7c <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e7c:	55                   	push   %ebp
f0103e7d:	89 e5                	mov    %esp,%ebp
f0103e7f:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103e82:	c6 05 50 02 1f f0 01 	movb   $0x1,0xf01f0250
f0103e89:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e8e:	b0 ff                	mov    $0xff,%al
f0103e90:	ee                   	out    %al,(%dx)
f0103e91:	b2 a1                	mov    $0xa1,%dl
f0103e93:	ee                   	out    %al,(%dx)
f0103e94:	b2 20                	mov    $0x20,%dl
f0103e96:	b0 11                	mov    $0x11,%al
f0103e98:	ee                   	out    %al,(%dx)
f0103e99:	b2 21                	mov    $0x21,%dl
f0103e9b:	b0 20                	mov    $0x20,%al
f0103e9d:	ee                   	out    %al,(%dx)
f0103e9e:	b0 04                	mov    $0x4,%al
f0103ea0:	ee                   	out    %al,(%dx)
f0103ea1:	b0 03                	mov    $0x3,%al
f0103ea3:	ee                   	out    %al,(%dx)
f0103ea4:	b2 a0                	mov    $0xa0,%dl
f0103ea6:	b0 11                	mov    $0x11,%al
f0103ea8:	ee                   	out    %al,(%dx)
f0103ea9:	b2 a1                	mov    $0xa1,%dl
f0103eab:	b0 28                	mov    $0x28,%al
f0103ead:	ee                   	out    %al,(%dx)
f0103eae:	b0 02                	mov    $0x2,%al
f0103eb0:	ee                   	out    %al,(%dx)
f0103eb1:	b0 01                	mov    $0x1,%al
f0103eb3:	ee                   	out    %al,(%dx)
f0103eb4:	b2 20                	mov    $0x20,%dl
f0103eb6:	b0 68                	mov    $0x68,%al
f0103eb8:	ee                   	out    %al,(%dx)
f0103eb9:	b0 0a                	mov    $0xa,%al
f0103ebb:	ee                   	out    %al,(%dx)
f0103ebc:	b2 a0                	mov    $0xa0,%dl
f0103ebe:	b0 68                	mov    $0x68,%al
f0103ec0:	ee                   	out    %al,(%dx)
f0103ec1:	b0 0a                	mov    $0xa,%al
f0103ec3:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103ec4:	66 a1 a8 93 12 f0    	mov    0xf01293a8,%ax
f0103eca:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103ece:	74 0b                	je     f0103edb <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103ed0:	0f b7 c0             	movzwl %ax,%eax
f0103ed3:	89 04 24             	mov    %eax,(%esp)
f0103ed6:	e8 2d ff ff ff       	call   f0103e08 <irq_setmask_8259A>
}
f0103edb:	c9                   	leave  
f0103edc:	c3                   	ret    
f0103edd:	00 00                	add    %al,(%eax)
	...

f0103ee0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ee0:	55                   	push   %ebp
f0103ee1:	89 e5                	mov    %esp,%ebp
f0103ee3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103ee6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ee9:	89 04 24             	mov    %eax,(%esp)
f0103eec:	e8 97 c8 ff ff       	call   f0100788 <cputchar>
	*cnt++;
}
f0103ef1:	c9                   	leave  
f0103ef2:	c3                   	ret    

f0103ef3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103ef3:	55                   	push   %ebp
f0103ef4:	89 e5                	mov    %esp,%ebp
f0103ef6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103ef9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f15:	c7 04 24 e0 3e 10 f0 	movl   $0xf0103ee0,(%esp)
f0103f1c:	e8 29 1b 00 00       	call   f0105a4a <vprintfmt>
	return cnt;
}
f0103f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f24:	c9                   	leave  
f0103f25:	c3                   	ret    

f0103f26 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f26:	55                   	push   %ebp
f0103f27:	89 e5                	mov    %esp,%ebp
f0103f29:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f2c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f33:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f36:	89 04 24             	mov    %eax,(%esp)
f0103f39:	e8 b5 ff ff ff       	call   f0103ef3 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f3e:	c9                   	leave  
f0103f3f:	c3                   	ret    

f0103f40 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f40:	55                   	push   %ebp
f0103f41:	89 e5                	mov    %esp,%ebp
f0103f43:	57                   	push   %edi
f0103f44:	56                   	push   %esi
f0103f45:	53                   	push   %ebx
f0103f46:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum()*(KSTKSIZE+KSTKGAP);
f0103f49:	e8 7a 27 00 00       	call   f01066c8 <cpunum>
f0103f4e:	89 c3                	mov    %eax,%ebx
f0103f50:	e8 73 27 00 00       	call   f01066c8 <cpunum>
f0103f55:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103f5c:	29 da                	sub    %ebx,%edx
f0103f5e:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103f61:	f7 d8                	neg    %eax
f0103f63:	c1 e0 10             	shl    $0x10,%eax
f0103f66:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103f6b:	89 04 95 30 10 1f f0 	mov    %eax,-0xfe0efd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103f72:	e8 51 27 00 00       	call   f01066c8 <cpunum>
f0103f77:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f7e:	29 c2                	sub    %eax,%edx
f0103f80:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f83:	66 c7 04 85 34 10 1f 	movw   $0x10,-0xfe0efcc(,%eax,4)
f0103f8a:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103f8d:	e8 36 27 00 00       	call   f01066c8 <cpunum>
f0103f92:	8d 58 05             	lea    0x5(%eax),%ebx
f0103f95:	e8 2e 27 00 00       	call   f01066c8 <cpunum>
f0103f9a:	89 c6                	mov    %eax,%esi
f0103f9c:	e8 27 27 00 00       	call   f01066c8 <cpunum>
f0103fa1:	89 c7                	mov    %eax,%edi
f0103fa3:	e8 20 27 00 00       	call   f01066c8 <cpunum>
f0103fa8:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f0103faf:	f0 67 00 
f0103fb2:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0103fb9:	29 f2                	sub    %esi,%edx
f0103fbb:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103fbe:	8d 14 95 2c 10 1f f0 	lea    -0xfe0efd4(,%edx,4),%edx
f0103fc5:	66 89 14 dd 42 93 12 	mov    %dx,-0xfed6cbe(,%ebx,8)
f0103fcc:	f0 
f0103fcd:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103fd4:	29 fa                	sub    %edi,%edx
f0103fd6:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103fd9:	8d 14 95 2c 10 1f f0 	lea    -0xfe0efd4(,%edx,4),%edx
f0103fe0:	c1 ea 10             	shr    $0x10,%edx
f0103fe3:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f0103fea:	c6 04 dd 45 93 12 f0 	movb   $0x99,-0xfed6cbb(,%ebx,8)
f0103ff1:	99 
f0103ff2:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f0103ff9:	40 
f0103ffa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104001:	29 c2                	sub    %eax,%edx
f0104003:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104006:	8d 04 85 2c 10 1f f0 	lea    -0xfe0efd4(,%eax,4),%eax
f010400d:	c1 e8 18             	shr    $0x18,%eax
f0104010:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
				sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0104017:	e8 ac 26 00 00       	call   f01066c8 <cpunum>
f010401c:	80 24 c5 6d 93 12 f0 	andb   $0xef,-0xfed6c93(,%eax,8)
f0104023:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + cpunum()*sizeof(struct Segdesc));
f0104024:	e8 9f 26 00 00       	call   f01066c8 <cpunum>
f0104029:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104030:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104033:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f0104038:	0f 01 18             	lidtl  (%eax)
	
	// Load the IDT
	lidt(&idt_pd);
}
f010403b:	83 c4 0c             	add    $0xc,%esp
f010403e:	5b                   	pop    %ebx
f010403f:	5e                   	pop    %esi
f0104040:	5f                   	pop    %edi
f0104041:	5d                   	pop    %ebp
f0104042:	c3                   	ret    

f0104043 <trap_init>:
}


void
trap_init(void)
{
f0104043:	55                   	push   %ebp
f0104044:	89 e5                	mov    %esp,%ebp
f0104046:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0104049:	b8 fc 4a 10 f0       	mov    $0xf0104afc,%eax
f010404e:	66 a3 60 02 1f f0    	mov    %ax,0xf01f0260
f0104054:	66 c7 05 62 02 1f f0 	movw   $0x8,0xf01f0262
f010405b:	08 00 
f010405d:	c6 05 64 02 1f f0 00 	movb   $0x0,0xf01f0264
f0104064:	c6 05 65 02 1f f0 8e 	movb   $0x8e,0xf01f0265
f010406b:	c1 e8 10             	shr    $0x10,%eax
f010406e:	66 a3 66 02 1f f0    	mov    %ax,0xf01f0266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0104074:	b8 06 4b 10 f0       	mov    $0xf0104b06,%eax
f0104079:	66 a3 68 02 1f f0    	mov    %ax,0xf01f0268
f010407f:	66 c7 05 6a 02 1f f0 	movw   $0x8,0xf01f026a
f0104086:	08 00 
f0104088:	c6 05 6c 02 1f f0 00 	movb   $0x0,0xf01f026c
f010408f:	c6 05 6d 02 1f f0 8e 	movb   $0x8e,0xf01f026d
f0104096:	c1 e8 10             	shr    $0x10,%eax
f0104099:	66 a3 6e 02 1f f0    	mov    %ax,0xf01f026e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f010409f:	b8 10 4b 10 f0       	mov    $0xf0104b10,%eax
f01040a4:	66 a3 70 02 1f f0    	mov    %ax,0xf01f0270
f01040aa:	66 c7 05 72 02 1f f0 	movw   $0x8,0xf01f0272
f01040b1:	08 00 
f01040b3:	c6 05 74 02 1f f0 00 	movb   $0x0,0xf01f0274
f01040ba:	c6 05 75 02 1f f0 8e 	movb   $0x8e,0xf01f0275
f01040c1:	c1 e8 10             	shr    $0x10,%eax
f01040c4:	66 a3 76 02 1f f0    	mov    %ax,0xf01f0276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01040ca:	b8 1a 4b 10 f0       	mov    $0xf0104b1a,%eax
f01040cf:	66 a3 78 02 1f f0    	mov    %ax,0xf01f0278
f01040d5:	66 c7 05 7a 02 1f f0 	movw   $0x8,0xf01f027a
f01040dc:	08 00 
f01040de:	c6 05 7c 02 1f f0 00 	movb   $0x0,0xf01f027c
f01040e5:	c6 05 7d 02 1f f0 ee 	movb   $0xee,0xf01f027d
f01040ec:	c1 e8 10             	shr    $0x10,%eax
f01040ef:	66 a3 7e 02 1f f0    	mov    %ax,0xf01f027e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01040f5:	b8 24 4b 10 f0       	mov    $0xf0104b24,%eax
f01040fa:	66 a3 80 02 1f f0    	mov    %ax,0xf01f0280
f0104100:	66 c7 05 82 02 1f f0 	movw   $0x8,0xf01f0282
f0104107:	08 00 
f0104109:	c6 05 84 02 1f f0 00 	movb   $0x0,0xf01f0284
f0104110:	c6 05 85 02 1f f0 8e 	movb   $0x8e,0xf01f0285
f0104117:	c1 e8 10             	shr    $0x10,%eax
f010411a:	66 a3 86 02 1f f0    	mov    %ax,0xf01f0286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0104120:	b8 2e 4b 10 f0       	mov    $0xf0104b2e,%eax
f0104125:	66 a3 88 02 1f f0    	mov    %ax,0xf01f0288
f010412b:	66 c7 05 8a 02 1f f0 	movw   $0x8,0xf01f028a
f0104132:	08 00 
f0104134:	c6 05 8c 02 1f f0 00 	movb   $0x0,0xf01f028c
f010413b:	c6 05 8d 02 1f f0 8e 	movb   $0x8e,0xf01f028d
f0104142:	c1 e8 10             	shr    $0x10,%eax
f0104145:	66 a3 8e 02 1f f0    	mov    %ax,0xf01f028e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f010414b:	b8 38 4b 10 f0       	mov    $0xf0104b38,%eax
f0104150:	66 a3 90 02 1f f0    	mov    %ax,0xf01f0290
f0104156:	66 c7 05 92 02 1f f0 	movw   $0x8,0xf01f0292
f010415d:	08 00 
f010415f:	c6 05 94 02 1f f0 00 	movb   $0x0,0xf01f0294
f0104166:	c6 05 95 02 1f f0 8e 	movb   $0x8e,0xf01f0295
f010416d:	c1 e8 10             	shr    $0x10,%eax
f0104170:	66 a3 96 02 1f f0    	mov    %ax,0xf01f0296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0104176:	b8 42 4b 10 f0       	mov    $0xf0104b42,%eax
f010417b:	66 a3 98 02 1f f0    	mov    %ax,0xf01f0298
f0104181:	66 c7 05 9a 02 1f f0 	movw   $0x8,0xf01f029a
f0104188:	08 00 
f010418a:	c6 05 9c 02 1f f0 00 	movb   $0x0,0xf01f029c
f0104191:	c6 05 9d 02 1f f0 8e 	movb   $0x8e,0xf01f029d
f0104198:	c1 e8 10             	shr    $0x10,%eax
f010419b:	66 a3 9e 02 1f f0    	mov    %ax,0xf01f029e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01041a1:	b8 4c 4b 10 f0       	mov    $0xf0104b4c,%eax
f01041a6:	66 a3 a0 02 1f f0    	mov    %ax,0xf01f02a0
f01041ac:	66 c7 05 a2 02 1f f0 	movw   $0x8,0xf01f02a2
f01041b3:	08 00 
f01041b5:	c6 05 a4 02 1f f0 00 	movb   $0x0,0xf01f02a4
f01041bc:	c6 05 a5 02 1f f0 8e 	movb   $0x8e,0xf01f02a5
f01041c3:	c1 e8 10             	shr    $0x10,%eax
f01041c6:	66 a3 a6 02 1f f0    	mov    %ax,0xf01f02a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01041cc:	b8 54 4b 10 f0       	mov    $0xf0104b54,%eax
f01041d1:	66 a3 b0 02 1f f0    	mov    %ax,0xf01f02b0
f01041d7:	66 c7 05 b2 02 1f f0 	movw   $0x8,0xf01f02b2
f01041de:	08 00 
f01041e0:	c6 05 b4 02 1f f0 00 	movb   $0x0,0xf01f02b4
f01041e7:	c6 05 b5 02 1f f0 8e 	movb   $0x8e,0xf01f02b5
f01041ee:	c1 e8 10             	shr    $0x10,%eax
f01041f1:	66 a3 b6 02 1f f0    	mov    %ax,0xf01f02b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01041f7:	b8 5c 4b 10 f0       	mov    $0xf0104b5c,%eax
f01041fc:	66 a3 b8 02 1f f0    	mov    %ax,0xf01f02b8
f0104202:	66 c7 05 ba 02 1f f0 	movw   $0x8,0xf01f02ba
f0104209:	08 00 
f010420b:	c6 05 bc 02 1f f0 00 	movb   $0x0,0xf01f02bc
f0104212:	c6 05 bd 02 1f f0 8e 	movb   $0x8e,0xf01f02bd
f0104219:	c1 e8 10             	shr    $0x10,%eax
f010421c:	66 a3 be 02 1f f0    	mov    %ax,0xf01f02be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0104222:	b8 64 4b 10 f0       	mov    $0xf0104b64,%eax
f0104227:	66 a3 c0 02 1f f0    	mov    %ax,0xf01f02c0
f010422d:	66 c7 05 c2 02 1f f0 	movw   $0x8,0xf01f02c2
f0104234:	08 00 
f0104236:	c6 05 c4 02 1f f0 00 	movb   $0x0,0xf01f02c4
f010423d:	c6 05 c5 02 1f f0 8e 	movb   $0x8e,0xf01f02c5
f0104244:	c1 e8 10             	shr    $0x10,%eax
f0104247:	66 a3 c6 02 1f f0    	mov    %ax,0xf01f02c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f010424d:	b8 6c 4b 10 f0       	mov    $0xf0104b6c,%eax
f0104252:	66 a3 c8 02 1f f0    	mov    %ax,0xf01f02c8
f0104258:	66 c7 05 ca 02 1f f0 	movw   $0x8,0xf01f02ca
f010425f:	08 00 
f0104261:	c6 05 cc 02 1f f0 00 	movb   $0x0,0xf01f02cc
f0104268:	c6 05 cd 02 1f f0 8e 	movb   $0x8e,0xf01f02cd
f010426f:	c1 e8 10             	shr    $0x10,%eax
f0104272:	66 a3 ce 02 1f f0    	mov    %ax,0xf01f02ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0104278:	b8 74 4b 10 f0       	mov    $0xf0104b74,%eax
f010427d:	66 a3 d0 02 1f f0    	mov    %ax,0xf01f02d0
f0104283:	66 c7 05 d2 02 1f f0 	movw   $0x8,0xf01f02d2
f010428a:	08 00 
f010428c:	c6 05 d4 02 1f f0 00 	movb   $0x0,0xf01f02d4
f0104293:	c6 05 d5 02 1f f0 8e 	movb   $0x8e,0xf01f02d5
f010429a:	c1 e8 10             	shr    $0x10,%eax
f010429d:	66 a3 d6 02 1f f0    	mov    %ax,0xf01f02d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01042a3:	b8 7c 4b 10 f0       	mov    $0xf0104b7c,%eax
f01042a8:	66 a3 e0 02 1f f0    	mov    %ax,0xf01f02e0
f01042ae:	66 c7 05 e2 02 1f f0 	movw   $0x8,0xf01f02e2
f01042b5:	08 00 
f01042b7:	c6 05 e4 02 1f f0 00 	movb   $0x0,0xf01f02e4
f01042be:	c6 05 e5 02 1f f0 8e 	movb   $0x8e,0xf01f02e5
f01042c5:	c1 e8 10             	shr    $0x10,%eax
f01042c8:	66 a3 e6 02 1f f0    	mov    %ax,0xf01f02e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01042ce:	b8 86 4b 10 f0       	mov    $0xf0104b86,%eax
f01042d3:	66 a3 e8 02 1f f0    	mov    %ax,0xf01f02e8
f01042d9:	66 c7 05 ea 02 1f f0 	movw   $0x8,0xf01f02ea
f01042e0:	08 00 
f01042e2:	c6 05 ec 02 1f f0 00 	movb   $0x0,0xf01f02ec
f01042e9:	c6 05 ed 02 1f f0 8e 	movb   $0x8e,0xf01f02ed
f01042f0:	c1 e8 10             	shr    $0x10,%eax
f01042f3:	66 a3 ee 02 1f f0    	mov    %ax,0xf01f02ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f01042f9:	b8 8e 4b 10 f0       	mov    $0xf0104b8e,%eax
f01042fe:	66 a3 f0 02 1f f0    	mov    %ax,0xf01f02f0
f0104304:	66 c7 05 f2 02 1f f0 	movw   $0x8,0xf01f02f2
f010430b:	08 00 
f010430d:	c6 05 f4 02 1f f0 00 	movb   $0x0,0xf01f02f4
f0104314:	c6 05 f5 02 1f f0 8e 	movb   $0x8e,0xf01f02f5
f010431b:	c1 e8 10             	shr    $0x10,%eax
f010431e:	66 a3 f6 02 1f f0    	mov    %ax,0xf01f02f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0104324:	b8 98 4b 10 f0       	mov    $0xf0104b98,%eax
f0104329:	66 a3 f8 02 1f f0    	mov    %ax,0xf01f02f8
f010432f:	66 c7 05 fa 02 1f f0 	movw   $0x8,0xf01f02fa
f0104336:	08 00 
f0104338:	c6 05 fc 02 1f f0 00 	movb   $0x0,0xf01f02fc
f010433f:	c6 05 fd 02 1f f0 8e 	movb   $0x8e,0xf01f02fd
f0104346:	c1 e8 10             	shr    $0x10,%eax
f0104349:	66 a3 fe 02 1f f0    	mov    %ax,0xf01f02fe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f010434f:	b8 a2 4b 10 f0       	mov    $0xf0104ba2,%eax
f0104354:	66 a3 e0 03 1f f0    	mov    %ax,0xf01f03e0
f010435a:	66 c7 05 e2 03 1f f0 	movw   $0x8,0xf01f03e2
f0104361:	08 00 
f0104363:	c6 05 e4 03 1f f0 00 	movb   $0x0,0xf01f03e4
f010436a:	c6 05 e5 03 1f f0 ee 	movb   $0xee,0xf01f03e5
f0104371:	c1 e8 10             	shr    $0x10,%eax
f0104374:	66 a3 e6 03 1f f0    	mov    %ax,0xf01f03e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f010437a:	b8 b8 4b 10 f0       	mov    $0xf0104bb8,%eax
f010437f:	66 a3 60 03 1f f0    	mov    %ax,0xf01f0360
f0104385:	66 c7 05 62 03 1f f0 	movw   $0x8,0xf01f0362
f010438c:	08 00 
f010438e:	c6 05 64 03 1f f0 00 	movb   $0x0,0xf01f0364
f0104395:	c6 05 65 03 1f f0 8e 	movb   $0x8e,0xf01f0365
f010439c:	c1 e8 10             	shr    $0x10,%eax
f010439f:	66 a3 66 03 1f f0    	mov    %ax,0xf01f0366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f01043a5:	b8 c2 4b 10 f0       	mov    $0xf0104bc2,%eax
f01043aa:	66 a3 68 03 1f f0    	mov    %ax,0xf01f0368
f01043b0:	66 c7 05 6a 03 1f f0 	movw   $0x8,0xf01f036a
f01043b7:	08 00 
f01043b9:	c6 05 6c 03 1f f0 00 	movb   $0x0,0xf01f036c
f01043c0:	c6 05 6d 03 1f f0 8e 	movb   $0x8e,0xf01f036d
f01043c7:	c1 e8 10             	shr    $0x10,%eax
f01043ca:	66 a3 6e 03 1f f0    	mov    %ax,0xf01f036e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f01043d0:	b8 cc 4b 10 f0       	mov    $0xf0104bcc,%eax
f01043d5:	66 a3 80 03 1f f0    	mov    %ax,0xf01f0380
f01043db:	66 c7 05 82 03 1f f0 	movw   $0x8,0xf01f0382
f01043e2:	08 00 
f01043e4:	c6 05 84 03 1f f0 00 	movb   $0x0,0xf01f0384
f01043eb:	c6 05 85 03 1f f0 8e 	movb   $0x8e,0xf01f0385
f01043f2:	c1 e8 10             	shr    $0x10,%eax
f01043f5:	66 a3 86 03 1f f0    	mov    %ax,0xf01f0386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f01043fb:	b8 d6 4b 10 f0       	mov    $0xf0104bd6,%eax
f0104400:	66 a3 98 03 1f f0    	mov    %ax,0xf01f0398
f0104406:	66 c7 05 9a 03 1f f0 	movw   $0x8,0xf01f039a
f010440d:	08 00 
f010440f:	c6 05 9c 03 1f f0 00 	movb   $0x0,0xf01f039c
f0104416:	c6 05 9d 03 1f f0 8e 	movb   $0x8e,0xf01f039d
f010441d:	c1 e8 10             	shr    $0x10,%eax
f0104420:	66 a3 9e 03 1f f0    	mov    %ax,0xf01f039e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0104426:	b8 e0 4b 10 f0       	mov    $0xf0104be0,%eax
f010442b:	66 a3 d0 03 1f f0    	mov    %ax,0xf01f03d0
f0104431:	66 c7 05 d2 03 1f f0 	movw   $0x8,0xf01f03d2
f0104438:	08 00 
f010443a:	c6 05 d4 03 1f f0 00 	movb   $0x0,0xf01f03d4
f0104441:	c6 05 d5 03 1f f0 8e 	movb   $0x8e,0xf01f03d5
f0104448:	c1 e8 10             	shr    $0x10,%eax
f010444b:	66 a3 d6 03 1f f0    	mov    %ax,0xf01f03d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0104451:	b8 ea 4b 10 f0       	mov    $0xf0104bea,%eax
f0104456:	66 a3 f8 03 1f f0    	mov    %ax,0xf01f03f8
f010445c:	66 c7 05 fa 03 1f f0 	movw   $0x8,0xf01f03fa
f0104463:	08 00 
f0104465:	c6 05 fc 03 1f f0 00 	movb   $0x0,0xf01f03fc
f010446c:	c6 05 fd 03 1f f0 8e 	movb   $0x8e,0xf01f03fd
f0104473:	c1 e8 10             	shr    $0x10,%eax
f0104476:	66 a3 fe 03 1f f0    	mov    %ax,0xf01f03fe

	// Per-CPU setup 
	trap_init_percpu();
f010447c:	e8 bf fa ff ff       	call   f0103f40 <trap_init_percpu>
}
f0104481:	c9                   	leave  
f0104482:	c3                   	ret    

f0104483 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104483:	55                   	push   %ebp
f0104484:	89 e5                	mov    %esp,%ebp
f0104486:	53                   	push   %ebx
f0104487:	83 ec 14             	sub    $0x14,%esp
f010448a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010448d:	8b 03                	mov    (%ebx),%eax
f010448f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104493:	c7 04 24 58 81 10 f0 	movl   $0xf0108158,(%esp)
f010449a:	e8 87 fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010449f:	8b 43 04             	mov    0x4(%ebx),%eax
f01044a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a6:	c7 04 24 67 81 10 f0 	movl   $0xf0108167,(%esp)
f01044ad:	e8 74 fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01044b2:	8b 43 08             	mov    0x8(%ebx),%eax
f01044b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044b9:	c7 04 24 76 81 10 f0 	movl   $0xf0108176,(%esp)
f01044c0:	e8 61 fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01044c5:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044cc:	c7 04 24 85 81 10 f0 	movl   $0xf0108185,(%esp)
f01044d3:	e8 4e fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01044d8:	8b 43 10             	mov    0x10(%ebx),%eax
f01044db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044df:	c7 04 24 94 81 10 f0 	movl   $0xf0108194,(%esp)
f01044e6:	e8 3b fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01044eb:	8b 43 14             	mov    0x14(%ebx),%eax
f01044ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f2:	c7 04 24 a3 81 10 f0 	movl   $0xf01081a3,(%esp)
f01044f9:	e8 28 fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01044fe:	8b 43 18             	mov    0x18(%ebx),%eax
f0104501:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104505:	c7 04 24 b2 81 10 f0 	movl   $0xf01081b2,(%esp)
f010450c:	e8 15 fa ff ff       	call   f0103f26 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104511:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104514:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104518:	c7 04 24 c1 81 10 f0 	movl   $0xf01081c1,(%esp)
f010451f:	e8 02 fa ff ff       	call   f0103f26 <cprintf>
}
f0104524:	83 c4 14             	add    $0x14,%esp
f0104527:	5b                   	pop    %ebx
f0104528:	5d                   	pop    %ebp
f0104529:	c3                   	ret    

f010452a <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010452a:	55                   	push   %ebp
f010452b:	89 e5                	mov    %esp,%ebp
f010452d:	53                   	push   %ebx
f010452e:	83 ec 14             	sub    $0x14,%esp
f0104531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104534:	e8 8f 21 00 00       	call   f01066c8 <cpunum>
f0104539:	89 44 24 08          	mov    %eax,0x8(%esp)
f010453d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104541:	c7 04 24 25 82 10 f0 	movl   $0xf0108225,(%esp)
f0104548:	e8 d9 f9 ff ff       	call   f0103f26 <cprintf>
	print_regs(&tf->tf_regs);
f010454d:	89 1c 24             	mov    %ebx,(%esp)
f0104550:	e8 2e ff ff ff       	call   f0104483 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104555:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104559:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455d:	c7 04 24 43 82 10 f0 	movl   $0xf0108243,(%esp)
f0104564:	e8 bd f9 ff ff       	call   f0103f26 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104569:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010456d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104571:	c7 04 24 56 82 10 f0 	movl   $0xf0108256,(%esp)
f0104578:	e8 a9 f9 ff ff       	call   f0103f26 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010457d:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104580:	83 f8 13             	cmp    $0x13,%eax
f0104583:	77 09                	ja     f010458e <print_trapframe+0x64>
	  return excnames[trapno];
f0104585:	8b 14 85 00 85 10 f0 	mov    -0xfef7b00(,%eax,4),%edx
f010458c:	eb 20                	jmp    f01045ae <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f010458e:	83 f8 30             	cmp    $0x30,%eax
f0104591:	74 0f                	je     f01045a2 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104593:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104596:	83 fa 0f             	cmp    $0xf,%edx
f0104599:	77 0e                	ja     f01045a9 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f010459b:	ba dc 81 10 f0       	mov    $0xf01081dc,%edx
f01045a0:	eb 0c                	jmp    f01045ae <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
	  return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01045a2:	ba d0 81 10 f0       	mov    $0xf01081d0,%edx
f01045a7:	eb 05                	jmp    f01045ae <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01045a9:	ba ef 81 10 f0       	mov    $0xf01081ef,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045ae:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b6:	c7 04 24 69 82 10 f0 	movl   $0xf0108269,(%esp)
f01045bd:	e8 64 f9 ff ff       	call   f0103f26 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01045c2:	3b 1d 60 0a 1f f0    	cmp    0xf01f0a60,%ebx
f01045c8:	75 19                	jne    f01045e3 <print_trapframe+0xb9>
f01045ca:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045ce:	75 13                	jne    f01045e3 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01045d0:	0f 20 d0             	mov    %cr2,%eax
	  cprintf("  cr2  0x%08x\n", rcr2());
f01045d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d7:	c7 04 24 7b 82 10 f0 	movl   $0xf010827b,(%esp)
f01045de:	e8 43 f9 ff ff       	call   f0103f26 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01045e3:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01045e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ea:	c7 04 24 8a 82 10 f0 	movl   $0xf010828a,(%esp)
f01045f1:	e8 30 f9 ff ff       	call   f0103f26 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01045f6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045fa:	75 4d                	jne    f0104649 <print_trapframe+0x11f>
	  cprintf(" [%s, %s, %s]\n",
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
f01045fc:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
	  cprintf(" [%s, %s, %s]\n",
f01045ff:	a8 01                	test   $0x1,%al
f0104601:	74 07                	je     f010460a <print_trapframe+0xe0>
f0104603:	b9 fe 81 10 f0       	mov    $0xf01081fe,%ecx
f0104608:	eb 05                	jmp    f010460f <print_trapframe+0xe5>
f010460a:	b9 09 82 10 f0       	mov    $0xf0108209,%ecx
f010460f:	a8 02                	test   $0x2,%al
f0104611:	74 07                	je     f010461a <print_trapframe+0xf0>
f0104613:	ba 15 82 10 f0       	mov    $0xf0108215,%edx
f0104618:	eb 05                	jmp    f010461f <print_trapframe+0xf5>
f010461a:	ba 1b 82 10 f0       	mov    $0xf010821b,%edx
f010461f:	a8 04                	test   $0x4,%al
f0104621:	74 07                	je     f010462a <print_trapframe+0x100>
f0104623:	b8 20 82 10 f0       	mov    $0xf0108220,%eax
f0104628:	eb 05                	jmp    f010462f <print_trapframe+0x105>
f010462a:	b8 73 83 10 f0       	mov    $0xf0108373,%eax
f010462f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104633:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104637:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463b:	c7 04 24 98 82 10 f0 	movl   $0xf0108298,(%esp)
f0104642:	e8 df f8 ff ff       	call   f0103f26 <cprintf>
f0104647:	eb 0c                	jmp    f0104655 <print_trapframe+0x12b>
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
	else
	  cprintf("\n");
f0104649:	c7 04 24 ff 7f 10 f0 	movl   $0xf0107fff,(%esp)
f0104650:	e8 d1 f8 ff ff       	call   f0103f26 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104655:	8b 43 30             	mov    0x30(%ebx),%eax
f0104658:	89 44 24 04          	mov    %eax,0x4(%esp)
f010465c:	c7 04 24 a7 82 10 f0 	movl   $0xf01082a7,(%esp)
f0104663:	e8 be f8 ff ff       	call   f0103f26 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104668:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010466c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104670:	c7 04 24 b6 82 10 f0 	movl   $0xf01082b6,(%esp)
f0104677:	e8 aa f8 ff ff       	call   f0103f26 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010467c:	8b 43 38             	mov    0x38(%ebx),%eax
f010467f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104683:	c7 04 24 c9 82 10 f0 	movl   $0xf01082c9,(%esp)
f010468a:	e8 97 f8 ff ff       	call   f0103f26 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010468f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104693:	74 27                	je     f01046bc <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104695:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104698:	89 44 24 04          	mov    %eax,0x4(%esp)
f010469c:	c7 04 24 d8 82 10 f0 	movl   $0xf01082d8,(%esp)
f01046a3:	e8 7e f8 ff ff       	call   f0103f26 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01046a8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01046ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b0:	c7 04 24 e7 82 10 f0 	movl   $0xf01082e7,(%esp)
f01046b7:	e8 6a f8 ff ff       	call   f0103f26 <cprintf>
	}
}
f01046bc:	83 c4 14             	add    $0x14,%esp
f01046bf:	5b                   	pop    %ebx
f01046c0:	5d                   	pop    %ebp
f01046c1:	c3                   	ret    

f01046c2 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01046c2:	55                   	push   %ebp
f01046c3:	89 e5                	mov    %esp,%ebp
f01046c5:	57                   	push   %edi
f01046c6:	56                   	push   %esi
f01046c7:	53                   	push   %ebx
f01046c8:	83 ec 2c             	sub    $0x2c,%esp
f01046cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01046ce:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	
	if ((tf->tf_cs & 0x0001) == 0) {
f01046d1:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f01046d5:	75 1c                	jne    f01046f3 <page_fault_handler+0x31>
		panic("page_fault_handler:page fault");
f01046d7:	c7 44 24 08 fa 82 10 	movl   $0xf01082fa,0x8(%esp)
f01046de:	f0 
f01046df:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01046e6:	00 
f01046e7:	c7 04 24 18 83 10 f0 	movl   $0xf0108318,(%esp)
f01046ee:	e8 4d b9 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall){
f01046f3:	e8 d0 1f 00 00       	call   f01066c8 <cpunum>
f01046f8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01046ff:	29 c2                	sub    %eax,%edx
f0104701:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104704:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f010470b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010470f:	0f 84 ed 00 00 00    	je     f0104802 <page_fault_handler+0x140>
		struct UTrapframe *utf;
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP-1)
f0104715:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104718:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		else
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
f010471e:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall){
		struct UTrapframe *utf;
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP-1)
f0104725:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010472b:	77 06                	ja     f0104733 <page_fault_handler+0x71>
			utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010472d:	83 e8 38             	sub    $0x38,%eax
f0104730:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		else
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
		user_mem_assert(curenv, (void*)utf, sizeof(struct UTrapframe), PTE_U|PTE_W);
f0104733:	e8 90 1f 00 00       	call   f01066c8 <cpunum>
f0104738:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010473f:	00 
f0104740:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104747:	00 
f0104748:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010474b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010474f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104752:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104758:	89 04 24             	mov    %eax,(%esp)
f010475b:	e8 b3 ed ff ff       	call   f0103513 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104760:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104763:	89 30                	mov    %esi,(%eax)
		utf->utf_regs = tf->tf_regs;
f0104765:	89 c7                	mov    %eax,%edi
f0104767:	83 c7 08             	add    $0x8,%edi
f010476a:	89 de                	mov    %ebx,%esi
f010476c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104771:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104777:	74 03                	je     f010477c <page_fault_handler+0xba>
f0104779:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f010477a:	b0 1f                	mov    $0x1f,%al
f010477c:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104782:	74 05                	je     f0104789 <page_fault_handler+0xc7>
f0104784:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104786:	83 e8 02             	sub    $0x2,%eax
f0104789:	89 c1                	mov    %eax,%ecx
f010478b:	c1 e9 02             	shr    $0x2,%ecx
f010478e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104790:	a8 02                	test   $0x2,%al
f0104792:	74 02                	je     f0104796 <page_fault_handler+0xd4>
f0104794:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104796:	a8 01                	test   $0x1,%al
f0104798:	74 01                	je     f010479b <page_fault_handler+0xd9>
f010479a:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010479b:	8b 43 30             	mov    0x30(%ebx),%eax
f010479e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047a1:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01047a4:	8b 43 38             	mov    0x38(%ebx),%eax
f01047a7:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01047aa:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01047ad:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_err = tf->tf_trapno;
f01047b0:	8b 43 28             	mov    0x28(%ebx),%eax
f01047b3:	89 42 04             	mov    %eax,0x4(%edx)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01047b6:	e8 0d 1f 00 00       	call   f01066c8 <cpunum>
f01047bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01047be:	8b 98 28 10 1f f0    	mov    -0xfe0efd8(%eax),%ebx
f01047c4:	e8 ff 1e 00 00       	call   f01066c8 <cpunum>
f01047c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01047cc:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01047d2:	8b 40 64             	mov    0x64(%eax),%eax
f01047d5:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)utf;
f01047d8:	e8 eb 1e 00 00       	call   f01066c8 <cpunum>
f01047dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e0:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01047e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047e9:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f01047ec:	e8 d7 1e 00 00       	call   f01066c8 <cpunum>
f01047f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f4:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01047fa:	89 04 24             	mov    %eax,(%esp)
f01047fd:	e8 1a f5 ff ff       	call   f0103d1c <env_run>
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104802:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104805:	e8 be 1e 00 00       	call   f01066c8 <cpunum>
		curenv->env_tf.tf_esp = (uint32_t)utf;
		env_run(curenv);
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010480a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010480e:	89 74 24 08          	mov    %esi,0x8(%esp)
				curenv->env_id, fault_va, tf->tf_eip);
f0104812:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104819:	29 c2                	sub    %eax,%edx
f010481b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010481e:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
		curenv->env_tf.tf_esp = (uint32_t)utf;
		env_run(curenv);
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104825:	8b 40 48             	mov    0x48(%eax),%eax
f0104828:	89 44 24 04          	mov    %eax,0x4(%esp)
f010482c:	c7 04 24 c0 84 10 f0 	movl   $0xf01084c0,(%esp)
f0104833:	e8 ee f6 ff ff       	call   f0103f26 <cprintf>
				curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104838:	89 1c 24             	mov    %ebx,(%esp)
f010483b:	e8 ea fc ff ff       	call   f010452a <print_trapframe>
	env_destroy(curenv);
f0104840:	e8 83 1e 00 00       	call   f01066c8 <cpunum>
f0104845:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010484c:	29 c2                	sub    %eax,%edx
f010484e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104851:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0104858:	89 04 24             	mov    %eax,(%esp)
f010485b:	e8 fd f3 ff ff       	call   f0103c5d <env_destroy>
	}
}
f0104860:	83 c4 2c             	add    $0x2c,%esp
f0104863:	5b                   	pop    %ebx
f0104864:	5e                   	pop    %esi
f0104865:	5f                   	pop    %edi
f0104866:	5d                   	pop    %ebp
f0104867:	c3                   	ret    

f0104868 <breakpoint_handler>:

void breakpoint_handler(struct Trapframe *tf){
f0104868:	55                   	push   %ebp
f0104869:	89 e5                	mov    %esp,%ebp
f010486b:	83 ec 18             	sub    $0x18,%esp
	monitor(tf);
f010486e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104871:	89 04 24             	mov    %eax,(%esp)
f0104874:	e8 0a c1 ff ff       	call   f0100983 <monitor>
}
f0104879:	c9                   	leave  
f010487a:	c3                   	ret    

f010487b <system_call_handler>:

int32_t system_call_handler(struct Trapframe *tf){
f010487b:	55                   	push   %ebp
f010487c:	89 e5                	mov    %esp,%ebp
f010487e:	83 ec 28             	sub    $0x28,%esp
f0104881:	8b 45 08             	mov    0x8(%ebp),%eax
	return syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,\
f0104884:	8b 50 04             	mov    0x4(%eax),%edx
f0104887:	89 54 24 14          	mov    %edx,0x14(%esp)
f010488b:	8b 10                	mov    (%eax),%edx
f010488d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104891:	8b 50 10             	mov    0x10(%eax),%edx
f0104894:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104898:	8b 50 18             	mov    0x18(%eax),%edx
f010489b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010489f:	8b 50 14             	mov    0x14(%eax),%edx
f01048a2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01048a6:	8b 40 1c             	mov    0x1c(%eax),%eax
f01048a9:	89 04 24             	mov    %eax,(%esp)
f01048ac:	e8 65 05 00 00       	call   f0104e16 <syscall>
				tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);	
}
f01048b1:	c9                   	leave  
f01048b2:	c3                   	ret    

f01048b3 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01048b3:	55                   	push   %ebp
f01048b4:	89 e5                	mov    %esp,%ebp
f01048b6:	57                   	push   %edi
f01048b7:	56                   	push   %esi
f01048b8:	83 ec 10             	sub    $0x10,%esp
f01048bb:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01048be:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01048bf:	83 3d 80 0e 1f f0 00 	cmpl   $0x0,0xf01f0e80
f01048c6:	74 01                	je     f01048c9 <trap+0x16>
		asm volatile("hlt");
f01048c8:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048c9:	e8 fa 1d 00 00       	call   f01066c8 <cpunum>
f01048ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048d5:	29 c2                	sub    %eax,%edx
f01048d7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048da:	8d 14 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01048e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01048e6:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01048ea:	83 f8 02             	cmp    $0x2,%eax
f01048ed:	75 0c                	jne    f01048fb <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01048ef:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f01048f6:	e8 8c 20 00 00       	call   f0106987 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01048fb:	9c                   	pushf  
f01048fc:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01048fd:	f6 c4 02             	test   $0x2,%ah
f0104900:	74 24                	je     f0104926 <trap+0x73>
f0104902:	c7 44 24 0c 24 83 10 	movl   $0xf0108324,0xc(%esp)
f0104909:	f0 
f010490a:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0104911:	f0 
f0104912:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f0104919:	00 
f010491a:	c7 04 24 18 83 10 f0 	movl   $0xf0108318,(%esp)
f0104921:	e8 1a b7 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104926:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010492a:	83 e0 03             	and    $0x3,%eax
f010492d:	83 f8 03             	cmp    $0x3,%eax
f0104930:	0f 85 a7 00 00 00    	jne    f01049dd <trap+0x12a>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104936:	e8 8d 1d 00 00       	call   f01066c8 <cpunum>
f010493b:	6b c0 74             	imul   $0x74,%eax,%eax
f010493e:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f0104945:	75 24                	jne    f010496b <trap+0xb8>
f0104947:	c7 44 24 0c 3d 83 10 	movl   $0xf010833d,0xc(%esp)
f010494e:	f0 
f010494f:	c7 44 24 08 e3 7c 10 	movl   $0xf0107ce3,0x8(%esp)
f0104956:	f0 
f0104957:	c7 44 24 04 45 01 00 	movl   $0x145,0x4(%esp)
f010495e:	00 
f010495f:	c7 04 24 18 83 10 f0 	movl   $0xf0108318,(%esp)
f0104966:	e8 d5 b6 ff ff       	call   f0100040 <_panic>
f010496b:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104972:	e8 10 20 00 00       	call   f0106987 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104977:	e8 4c 1d 00 00       	call   f01066c8 <cpunum>
f010497c:	6b c0 74             	imul   $0x74,%eax,%eax
f010497f:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104985:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104989:	75 2d                	jne    f01049b8 <trap+0x105>
			env_free(curenv);
f010498b:	e8 38 1d 00 00       	call   f01066c8 <cpunum>
f0104990:	6b c0 74             	imul   $0x74,%eax,%eax
f0104993:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104999:	89 04 24             	mov    %eax,(%esp)
f010499c:	e8 e3 f0 ff ff       	call   f0103a84 <env_free>
			curenv = NULL;
f01049a1:	e8 22 1d 00 00       	call   f01066c8 <cpunum>
f01049a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a9:	c7 80 28 10 1f f0 00 	movl   $0x0,-0xfe0efd8(%eax)
f01049b0:	00 00 00 
			sched_yield();
f01049b3:	e8 42 03 00 00       	call   f0104cfa <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049b8:	e8 0b 1d 00 00       	call   f01066c8 <cpunum>
f01049bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c0:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f01049c6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049cb:	89 c7                	mov    %eax,%edi
f01049cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01049cf:	e8 f4 1c 00 00       	call   f01066c8 <cpunum>
f01049d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d7:	8b b0 28 10 1f f0    	mov    -0xfe0efd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01049dd:	89 35 60 0a 1f f0    	mov    %esi,0xf01f0a60
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	int32_t ret;

	switch (tf->tf_trapno){
f01049e3:	8b 46 28             	mov    0x28(%esi),%eax
f01049e6:	83 f8 20             	cmp    $0x20,%eax
f01049e9:	74 5b                	je     f0104a46 <trap+0x193>
f01049eb:	83 f8 20             	cmp    $0x20,%eax
f01049ee:	77 11                	ja     f0104a01 <trap+0x14e>
f01049f0:	83 f8 03             	cmp    $0x3,%eax
f01049f3:	74 2a                	je     f0104a1f <trap+0x16c>
f01049f5:	83 f8 0e             	cmp    $0xe,%eax
f01049f8:	74 18                	je     f0104a12 <trap+0x15f>
f01049fa:	83 f8 01             	cmp    $0x1,%eax
f01049fd:	75 5f                	jne    f0104a5e <trap+0x1ab>
f01049ff:	eb 2b                	jmp    f0104a2c <trap+0x179>
f0104a01:	83 f8 24             	cmp    $0x24,%eax
f0104a04:	74 51                	je     f0104a57 <trap+0x1a4>
f0104a06:	83 f8 30             	cmp    $0x30,%eax
f0104a09:	74 2e                	je     f0104a39 <trap+0x186>
f0104a0b:	83 f8 21             	cmp    $0x21,%eax
f0104a0e:	75 4e                	jne    f0104a5e <trap+0x1ab>
f0104a10:	eb 3e                	jmp    f0104a50 <trap+0x19d>
		case T_PGFLT:{ //14
			page_fault_handler(tf);
f0104a12:	89 34 24             	mov    %esi,(%esp)
f0104a15:	e8 a8 fc ff ff       	call   f01046c2 <page_fault_handler>
f0104a1a:	e9 9b 00 00 00       	jmp    f0104aba <trap+0x207>
			return;
		}
		case T_BRKPT:{ //3 
			breakpoint_handler(tf);
f0104a1f:	89 34 24             	mov    %esi,(%esp)
f0104a22:	e8 41 fe ff ff       	call   f0104868 <breakpoint_handler>
f0104a27:	e9 8e 00 00 00       	jmp    f0104aba <trap+0x207>
			return;
		}
		case T_DEBUG:{
			breakpoint_handler(tf);
f0104a2c:	89 34 24             	mov    %esi,(%esp)
f0104a2f:	e8 34 fe ff ff       	call   f0104868 <breakpoint_handler>
f0104a34:	e9 81 00 00 00       	jmp    f0104aba <trap+0x207>
			return;
		}
		case T_SYSCALL:{
			ret = system_call_handler(tf);
f0104a39:	89 34 24             	mov    %esi,(%esp)
f0104a3c:	e8 3a fe ff ff       	call   f010487b <system_call_handler>
			tf->tf_regs.reg_eax = ret;
f0104a41:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a44:	eb 74                	jmp    f0104aba <trap+0x207>
			return;
		}
		case IRQ_OFFSET+IRQ_TIMER:{
			lapic_eoi();
f0104a46:	e8 d4 1d 00 00       	call   f010681f <lapic_eoi>
			sched_yield();
f0104a4b:	e8 aa 02 00 00       	call   f0104cfa <sched_yield>
			return;
		}
		case IRQ_OFFSET+IRQ_KBD:{
			kbd_intr();
f0104a50:	e8 c9 bb ff ff       	call   f010061e <kbd_intr>
f0104a55:	eb 63                	jmp    f0104aba <trap+0x207>
			return;
		}
		case IRQ_OFFSET+IRQ_SERIAL:{
			serial_intr();
f0104a57:	e8 a7 bb ff ff       	call   f0100603 <serial_intr>
f0104a5c:	eb 5c                	jmp    f0104aba <trap+0x207>
	}	

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a5e:	83 f8 27             	cmp    $0x27,%eax
f0104a61:	75 16                	jne    f0104a79 <trap+0x1c6>
		cprintf("Spurious interrupt on irq 7\n");
f0104a63:	c7 04 24 44 83 10 f0 	movl   $0xf0108344,(%esp)
f0104a6a:	e8 b7 f4 ff ff       	call   f0103f26 <cprintf>
		print_trapframe(tf);
f0104a6f:	89 34 24             	mov    %esi,(%esp)
f0104a72:	e8 b3 fa ff ff       	call   f010452a <print_trapframe>
f0104a77:	eb 41                	jmp    f0104aba <trap+0x207>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a79:	89 34 24             	mov    %esi,(%esp)
f0104a7c:	e8 a9 fa ff ff       	call   f010452a <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a81:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a86:	75 1c                	jne    f0104aa4 <trap+0x1f1>
	  panic("unhandled trap in kernel");
f0104a88:	c7 44 24 08 61 83 10 	movl   $0xf0108361,0x8(%esp)
f0104a8f:	f0 
f0104a90:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0104a97:	00 
f0104a98:	c7 04 24 18 83 10 f0 	movl   $0xf0108318,(%esp)
f0104a9f:	e8 9c b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104aa4:	e8 1f 1c 00 00       	call   f01066c8 <cpunum>
f0104aa9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aac:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104ab2:	89 04 24             	mov    %eax,(%esp)
f0104ab5:	e8 a3 f1 ff ff       	call   f0103c5d <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104aba:	e8 09 1c 00 00       	call   f01066c8 <cpunum>
f0104abf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac2:	83 b8 28 10 1f f0 00 	cmpl   $0x0,-0xfe0efd8(%eax)
f0104ac9:	74 2a                	je     f0104af5 <trap+0x242>
f0104acb:	e8 f8 1b 00 00       	call   f01066c8 <cpunum>
f0104ad0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad3:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104ad9:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104add:	75 16                	jne    f0104af5 <trap+0x242>
		env_run(curenv);
f0104adf:	e8 e4 1b 00 00       	call   f01066c8 <cpunum>
f0104ae4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae7:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0104aed:	89 04 24             	mov    %eax,(%esp)
f0104af0:	e8 27 f2 ff ff       	call   f0103d1c <env_run>
	else
		sched_yield();
f0104af5:	e8 00 02 00 00       	call   f0104cfa <sched_yield>
	...

f0104afc <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104afc:	6a 00                	push   $0x0
f0104afe:	6a 00                	push   $0x0
f0104b00:	e9 ee 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b05:	90                   	nop

f0104b06 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104b06:	6a 00                	push   $0x0
f0104b08:	6a 01                	push   $0x1
f0104b0a:	e9 e4 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b0f:	90                   	nop

f0104b10 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104b10:	6a 00                	push   $0x0
f0104b12:	6a 02                	push   $0x2
f0104b14:	e9 da 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b19:	90                   	nop

f0104b1a <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104b1a:	6a 00                	push   $0x0
f0104b1c:	6a 03                	push   $0x3
f0104b1e:	e9 d0 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b23:	90                   	nop

f0104b24 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104b24:	6a 00                	push   $0x0
f0104b26:	6a 04                	push   $0x4
f0104b28:	e9 c6 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b2d:	90                   	nop

f0104b2e <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104b2e:	6a 00                	push   $0x0
f0104b30:	6a 05                	push   $0x5
f0104b32:	e9 bc 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b37:	90                   	nop

f0104b38 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104b38:	6a 00                	push   $0x0
f0104b3a:	6a 06                	push   $0x6
f0104b3c:	e9 b2 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b41:	90                   	nop

f0104b42 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104b42:	6a 00                	push   $0x0
f0104b44:	6a 07                	push   $0x7
f0104b46:	e9 a8 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b4b:	90                   	nop

f0104b4c <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104b4c:	6a 08                	push   $0x8
f0104b4e:	e9 a0 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b53:	90                   	nop

f0104b54 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104b54:	6a 0a                	push   $0xa
f0104b56:	e9 98 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b5b:	90                   	nop

f0104b5c <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0104b5c:	6a 0b                	push   $0xb
f0104b5e:	e9 90 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b63:	90                   	nop

f0104b64 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104b64:	6a 0c                	push   $0xc
f0104b66:	e9 88 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b6b:	90                   	nop

f0104b6c <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104b6c:	6a 0d                	push   $0xd
f0104b6e:	e9 80 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b73:	90                   	nop

f0104b74 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104b74:	6a 0e                	push   $0xe
f0104b76:	e9 78 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b7b:	90                   	nop

f0104b7c <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104b7c:	6a 00                	push   $0x0
f0104b7e:	6a 10                	push   $0x10
f0104b80:	e9 6e 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b85:	90                   	nop

f0104b86 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104b86:	6a 11                	push   $0x11
f0104b88:	e9 66 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b8d:	90                   	nop

f0104b8e <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104b8e:	6a 00                	push   $0x0
f0104b90:	6a 12                	push   $0x12
f0104b92:	e9 5c 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104b97:	90                   	nop

f0104b98 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104b98:	6a 00                	push   $0x0
f0104b9a:	6a 13                	push   $0x13
f0104b9c:	e9 52 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104ba1:	90                   	nop

f0104ba2 <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104ba2:	6a 00                	push   $0x0
f0104ba4:	6a 30                	push   $0x30
f0104ba6:	e9 48 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104bab:	90                   	nop

f0104bac <t_default>:
TRAPHANDLER_NOEC(t_default, T_DEFAULT)
f0104bac:	6a 00                	push   $0x0
f0104bae:	68 f4 01 00 00       	push   $0x1f4
f0104bb3:	e9 3b 00 00 00       	jmp    f0104bf3 <_alltraps>

f0104bb8 <irq_timer>:
TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET+IRQ_TIMER)
f0104bb8:	6a 00                	push   $0x0
f0104bba:	6a 20                	push   $0x20
f0104bbc:	e9 32 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104bc1:	90                   	nop

f0104bc2 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET+IRQ_KBD)
f0104bc2:	6a 00                	push   $0x0
f0104bc4:	6a 21                	push   $0x21
f0104bc6:	e9 28 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104bcb:	90                   	nop

f0104bcc <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET+IRQ_SERIAL)
f0104bcc:	6a 00                	push   $0x0
f0104bce:	6a 24                	push   $0x24
f0104bd0:	e9 1e 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104bd5:	90                   	nop

f0104bd6 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
f0104bd6:	6a 00                	push   $0x0
f0104bd8:	6a 27                	push   $0x27
f0104bda:	e9 14 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104bdf:	90                   	nop

f0104be0 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET+IRQ_IDE)
f0104be0:	6a 00                	push   $0x0
f0104be2:	6a 2e                	push   $0x2e
f0104be4:	e9 0a 00 00 00       	jmp    f0104bf3 <_alltraps>
f0104be9:	90                   	nop

f0104bea <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET+IRQ_ERROR)
f0104bea:	6a 00                	push   $0x0
f0104bec:	6a 33                	push   $0x33
f0104bee:	e9 00 00 00 00       	jmp    f0104bf3 <_alltraps>

f0104bf3 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	pushl %ds
f0104bf3:	1e                   	push   %ds
	pushl %es
f0104bf4:	06                   	push   %es
	pushal
f0104bf5:	60                   	pusha  

	movl $GD_KD,%eax
f0104bf6:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104bfb:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104bfd:	8e c0                	mov    %eax,%es
	push %esp
f0104bff:	54                   	push   %esp
	call trap
f0104c00:	e8 ae fc ff ff       	call   f01048b3 <trap>
f0104c05:	00 00                	add    %al,(%eax)
	...

f0104c08 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104c08:	55                   	push   %ebp
f0104c09:	89 e5                	mov    %esp,%ebp
f0104c0b:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104c0e:	8b 15 48 02 1f f0    	mov    0xf01f0248,%edx
f0104c14:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c17:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104c1c:	8b 0a                	mov    (%edx),%ecx
f0104c1e:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104c1f:	83 f9 02             	cmp    $0x2,%ecx
f0104c22:	76 0d                	jbe    f0104c31 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c24:	40                   	inc    %eax
f0104c25:	83 c2 7c             	add    $0x7c,%edx
f0104c28:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c2d:	75 ed                	jne    f0104c1c <sched_halt+0x14>
f0104c2f:	eb 07                	jmp    f0104c38 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c31:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c36:	75 1a                	jne    f0104c52 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104c38:	c7 04 24 50 85 10 f0 	movl   $0xf0108550,(%esp)
f0104c3f:	e8 e2 f2 ff ff       	call   f0103f26 <cprintf>
		while (1)
			monitor(NULL);
f0104c44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c4b:	e8 33 bd ff ff       	call   f0100983 <monitor>
f0104c50:	eb f2                	jmp    f0104c44 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c52:	e8 71 1a 00 00       	call   f01066c8 <cpunum>
f0104c57:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c5e:	29 c2                	sub    %eax,%edx
f0104c60:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c63:	c7 04 85 28 10 1f f0 	movl   $0x0,-0xfe0efd8(,%eax,4)
f0104c6a:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c6e:	a1 8c 0e 1f f0       	mov    0xf01f0e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c73:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c78:	77 20                	ja     f0104c9a <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c7e:	c7 44 24 08 c4 6d 10 	movl   $0xf0106dc4,0x8(%esp)
f0104c85:	f0 
f0104c86:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
f0104c8d:	00 
f0104c8e:	c7 04 24 79 85 10 f0 	movl   $0xf0108579,(%esp)
f0104c95:	e8 a6 b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104c9a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c9f:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104ca2:	e8 21 1a 00 00       	call   f01066c8 <cpunum>
f0104ca7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cae:	29 c2                	sub    %eax,%edx
f0104cb0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cb3:	8d 14 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104cba:	b8 02 00 00 00       	mov    $0x2,%eax
f0104cbf:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104cc3:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104cca:	e8 5b 1d 00 00       	call   f0106a2a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104ccf:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104cd1:	e8 f2 19 00 00       	call   f01066c8 <cpunum>
f0104cd6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cdd:	29 c2                	sub    %eax,%edx
f0104cdf:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104ce2:	8b 04 85 30 10 1f f0 	mov    -0xfe0efd0(,%eax,4),%eax
f0104ce9:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104cee:	89 c4                	mov    %eax,%esp
f0104cf0:	6a 00                	push   $0x0
f0104cf2:	6a 00                	push   $0x0
f0104cf4:	fb                   	sti    
f0104cf5:	f4                   	hlt    
f0104cf6:	eb fd                	jmp    f0104cf5 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104cf8:	c9                   	leave  
f0104cf9:	c3                   	ret    

f0104cfa <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104cfa:	55                   	push   %ebp
f0104cfb:	89 e5                	mov    %esp,%ebp
f0104cfd:	56                   	push   %esi
f0104cfe:	53                   	push   %ebx
f0104cff:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
f0104d02:	e8 c1 19 00 00       	call   f01066c8 <cpunum>
f0104d07:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d0e:	29 c2                	sub    %eax,%edx
f0104d10:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d13:	83 3c 85 28 10 1f f0 	cmpl   $0x0,-0xfe0efd8(,%eax,4)
f0104d1a:	00 
f0104d1b:	74 23                	je     f0104d40 <sched_yield+0x46>
f0104d1d:	e8 a6 19 00 00       	call   f01066c8 <cpunum>
f0104d22:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d29:	29 c2                	sub    %eax,%edx
f0104d2b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d2e:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0104d35:	8b 48 48             	mov    0x48(%eax),%ecx
f0104d38:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104d3e:	eb 05                	jmp    f0104d45 <sched_yield+0x4b>
f0104d40:	b9 00 00 00 00       	mov    $0x0,%ecx
	int nevs = NENV+1;
	while (--nevs){
		i = (i+1)%NENV;
		if (envs[i].env_status == ENV_RUNNABLE)
f0104d45:	8b 1d 48 02 1f f0    	mov    0xf01f0248,%ebx
f0104d4b:	ba 00 04 00 00       	mov    $0x400,%edx
	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
	int nevs = NENV+1;
	while (--nevs){
		i = (i+1)%NENV;
f0104d50:	8d 41 01             	lea    0x1(%ecx),%eax
f0104d53:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104d58:	79 07                	jns    f0104d61 <sched_yield+0x67>
f0104d5a:	48                   	dec    %eax
f0104d5b:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104d60:	40                   	inc    %eax
f0104d61:	89 c1                	mov    %eax,%ecx
		if (envs[i].env_status == ENV_RUNNABLE)
f0104d63:	8d 34 85 00 00 00 00 	lea    0x0(,%eax,4),%esi
f0104d6a:	c1 e0 07             	shl    $0x7,%eax
f0104d6d:	29 f0                	sub    %esi,%eax
f0104d6f:	01 d8                	add    %ebx,%eax
f0104d71:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104d75:	75 08                	jne    f0104d7f <sched_yield+0x85>
			env_run(&envs[i]);
f0104d77:	89 04 24             	mov    %eax,(%esp)
f0104d7a:	e8 9d ef ff ff       	call   f0103d1c <env_run>

	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
	int nevs = NENV+1;
	while (--nevs){
f0104d7f:	4a                   	dec    %edx
f0104d80:	75 ce                	jne    f0104d50 <sched_yield+0x56>
		i = (i+1)%NENV;
		if (envs[i].env_status == ENV_RUNNABLE)
			env_run(&envs[i]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104d82:	e8 41 19 00 00       	call   f01066c8 <cpunum>
f0104d87:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d8e:	29 c2                	sub    %eax,%edx
f0104d90:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d93:	83 3c 85 28 10 1f f0 	cmpl   $0x0,-0xfe0efd8(,%eax,4)
f0104d9a:	00 
f0104d9b:	74 3e                	je     f0104ddb <sched_yield+0xe1>
f0104d9d:	e8 26 19 00 00       	call   f01066c8 <cpunum>
f0104da2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104da9:	29 c2                	sub    %eax,%edx
f0104dab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dae:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0104db5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104db9:	75 20                	jne    f0104ddb <sched_yield+0xe1>
		env_run(curenv);
f0104dbb:	e8 08 19 00 00       	call   f01066c8 <cpunum>
f0104dc0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dc7:	29 c2                	sub    %eax,%edx
f0104dc9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dcc:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0104dd3:	89 04 24             	mov    %eax,(%esp)
f0104dd6:	e8 41 ef ff ff       	call   f0103d1c <env_run>

	// sched_halt never returns
	sched_halt();
f0104ddb:	e8 28 fe ff ff       	call   f0104c08 <sched_halt>
}
f0104de0:	83 c4 10             	add    $0x10,%esp
f0104de3:	5b                   	pop    %ebx
f0104de4:	5e                   	pop    %esi
f0104de5:	5d                   	pop    %ebp
f0104de6:	c3                   	ret    
	...

f0104de8 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104de8:	55                   	push   %ebp
f0104de9:	89 e5                	mov    %esp,%ebp
f0104deb:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104dee:	e8 d5 18 00 00       	call   f01066c8 <cpunum>
f0104df3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dfa:	29 c2                	sub    %eax,%edx
f0104dfc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dff:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0104e06:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104e09:	c9                   	leave  
f0104e0a:	c3                   	ret    

f0104e0b <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104e0b:	55                   	push   %ebp
f0104e0c:	89 e5                	mov    %esp,%ebp
f0104e0e:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104e11:	e8 e4 fe ff ff       	call   f0104cfa <sched_yield>

f0104e16 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104e16:	55                   	push   %ebp
f0104e17:	89 e5                	mov    %esp,%ebp
f0104e19:	57                   	push   %edi
f0104e1a:	56                   	push   %esi
f0104e1b:	53                   	push   %ebx
f0104e1c:	83 ec 2c             	sub    $0x2c,%esp
f0104e1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e22:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104e28:	8b 7d 18             	mov    0x18(%ebp),%edi
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104e2b:	83 f8 0d             	cmp    $0xd,%eax
f0104e2e:	0f 87 83 06 00 00    	ja     f01054b7 <syscall+0x6a1>
f0104e34:	ff 24 85 f8 87 10 f0 	jmp    *-0xfef7808(,%eax,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.

	user_mem_assert(curenv, (void*)s, len, 0); 
f0104e3b:	e8 88 18 00 00       	call   f01066c8 <cpunum>
f0104e40:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104e47:	00 
f0104e48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104e4c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104e50:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e57:	29 c2                	sub    %eax,%edx
f0104e59:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e5c:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0104e63:	89 04 24             	mov    %eax,(%esp)
f0104e66:	e8 a8 e6 ff ff       	call   f0103513 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104e6b:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104e6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104e73:	c7 04 24 86 85 10 f0 	movl   $0xf0108586,(%esp)
f0104e7a:	e8 a7 f0 ff ff       	call   f0103f26 <cprintf>
	//panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:{
			sys_cputs((char*)a1, a2);
			return 0;
f0104e7f:	be 00 00 00 00       	mov    $0x0,%esi
f0104e84:	e9 3a 06 00 00       	jmp    f01054c3 <syscall+0x6ad>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104e89:	e8 a2 b7 ff ff       	call   f0100630 <cons_getc>
f0104e8e:	89 c6                	mov    %eax,%esi
		case SYS_cputs:{
			sys_cputs((char*)a1, a2);
			return 0;
		}
		case SYS_cgetc:
			return sys_cgetc();	
f0104e90:	e9 2e 06 00 00       	jmp    f01054c3 <syscall+0x6ad>
		case SYS_getenvid:
			return sys_getenvid(); 
f0104e95:	e8 4e ff ff ff       	call   f0104de8 <sys_getenvid>
f0104e9a:	89 c6                	mov    %eax,%esi
f0104e9c:	e9 22 06 00 00       	jmp    f01054c3 <syscall+0x6ad>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ea1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ea8:	00 
f0104ea9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104eac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eb0:	89 34 24             	mov    %esi,(%esp)
f0104eb3:	e8 76 e7 ff ff       	call   f010362e <envid2env>
f0104eb8:	89 c6                	mov    %eax,%esi
f0104eba:	85 c0                	test   %eax,%eax
f0104ebc:	0f 88 01 06 00 00    	js     f01054c3 <syscall+0x6ad>
	  return r;
	env_destroy(e);
f0104ec2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ec5:	89 04 24             	mov    %eax,(%esp)
f0104ec8:	e8 90 ed ff ff       	call   f0103c5d <env_destroy>
	return 0;
f0104ecd:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_cgetc:
			return sys_cgetc();	
		case SYS_getenvid:
			return sys_getenvid(); 
		case SYS_env_destroy:
			return sys_env_destroy(a1); 
f0104ed2:	e9 ec 05 00 00       	jmp    f01054c3 <syscall+0x6ad>
		case SYS_yield:{
			sys_yield();
f0104ed7:	e8 2f ff ff ff       	call   f0104e0b <sys_yield>

	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");

	struct Env* e;
	int ret = env_alloc(&e, sys_getenvid());
f0104edc:	e8 07 ff ff ff       	call   f0104de8 <sys_getenvid>
f0104ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ee5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ee8:	89 04 24             	mov    %eax,(%esp)
f0104eeb:	e8 78 e8 ff ff       	call   f0103768 <env_alloc>
f0104ef0:	89 c6                	mov    %eax,%esi
	if (ret < 0){
f0104ef2:	85 c0                	test   %eax,%eax
f0104ef4:	79 11                	jns    f0104f07 <syscall+0xf1>
		cprintf("sys_exofork: env_alloc failed");
f0104ef6:	c7 04 24 8b 85 10 f0 	movl   $0xf010858b,(%esp)
f0104efd:	e8 24 f0 ff ff       	call   f0103f26 <cprintf>
f0104f02:	e9 bc 05 00 00       	jmp    f01054c3 <syscall+0x6ad>
		return ret;
	}
	e->env_status = ENV_NOT_RUNNABLE;
f0104f07:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104f0a:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104f11:	e8 b2 17 00 00       	call   f01066c8 <cpunum>
f0104f16:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f1d:	29 c2                	sub    %eax,%edx
f0104f1f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f22:	8b 34 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%esi
f0104f29:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104f2e:	89 df                	mov    %ebx,%edi
f0104f30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;  //?
f0104f32:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f35:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104f3c:	8b 70 48             	mov    0x48(%eax),%esi
		case SYS_yield:{
			sys_yield();
			return 0;
			}
		case SYS_exofork:
			return sys_exofork();
f0104f3f:	e9 7f 05 00 00       	jmp    f01054c3 <syscall+0x6ad>
	// envid's status.

	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");

	if (status != ENV_RUNNABLE && status!= ENV_NOT_RUNNABLE) {
f0104f44:	83 fb 02             	cmp    $0x2,%ebx
f0104f47:	74 1b                	je     f0104f64 <syscall+0x14e>
f0104f49:	83 fb 04             	cmp    $0x4,%ebx
f0104f4c:	74 16                	je     f0104f64 <syscall+0x14e>
		cprintf("sys_env_set_status: wrong status input");
f0104f4e:	c7 04 24 b8 85 10 f0 	movl   $0xf01085b8,(%esp)
f0104f55:	e8 cc ef ff ff       	call   f0103f26 <cprintf>
		return -E_INVAL;
f0104f5a:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104f5f:	e9 5f 05 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}

	struct Env* e;
	int ret = envid2env(envid, &e, true);
f0104f64:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f6b:	00 
f0104f6c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f73:	89 34 24             	mov    %esi,(%esp)
f0104f76:	e8 b3 e6 ff ff       	call   f010362e <envid2env>
f0104f7b:	89 c6                	mov    %eax,%esi
	if (ret < 0) {
f0104f7d:	85 c0                	test   %eax,%eax
f0104f7f:	79 11                	jns    f0104f92 <syscall+0x17c>
		cprintf("sys_env_set_status: envid2env fail");
f0104f81:	c7 04 24 e0 85 10 f0 	movl   $0xf01085e0,(%esp)
f0104f88:	e8 99 ef ff ff       	call   f0103f26 <cprintf>
f0104f8d:	e9 31 05 00 00       	jmp    f01054c3 <syscall+0x6ad>
		return ret;
	}
	e->env_status = status;
f0104f92:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f95:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f0104f98:	be 00 00 00 00       	mov    $0x0,%esi
			return 0;
			}
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
f0104f9d:	e9 21 05 00 00       	jmp    f01054c3 <syscall+0x6ad>

	// LAB 4: Your code here.
	//panic("sys_page_alloc not implemented");

	//check input validness
	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va){
f0104fa2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104fa8:	77 0f                	ja     f0104fb9 <syscall+0x1a3>
f0104faa:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f0104fb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104fb5:	39 c3                	cmp    %eax,%ebx
f0104fb7:	74 16                	je     f0104fcf <syscall+0x1b9>
		cprintf("sys_page_alloc: wrong va input");
f0104fb9:	c7 04 24 04 86 10 f0 	movl   $0xf0108604,(%esp)
f0104fc0:	e8 61 ef ff ff       	call   f0103f26 <cprintf>
		return -E_INVAL;
f0104fc5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104fca:	e9 f4 04 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}

	if((perm & ~PTE_SYSCALL) != 0){
f0104fcf:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104fd6:	74 16                	je     f0104fee <syscall+0x1d8>
		cprintf("sys_page_alloc: wrong perm input");
f0104fd8:	c7 04 24 24 86 10 f0 	movl   $0xf0108624,(%esp)
f0104fdf:	e8 42 ef ff ff       	call   f0103f26 <cprintf>
		return -E_INVAL;
f0104fe4:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104fe9:	e9 d5 04 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}

	struct PageInfo* pp;
	struct Env* e;
	int ret1 = envid2env(envid, &e, 1);
f0104fee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ff5:	00 
f0104ff6:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ffd:	89 34 24             	mov    %esi,(%esp)
f0105000:	e8 29 e6 ff ff       	call   f010362e <envid2env>
	if (ret1 < 0) {
f0105005:	85 c0                	test   %eax,%eax
f0105007:	79 16                	jns    f010501f <syscall+0x209>
		cprintf("sys_page_alloc: envid2env wrong");
f0105009:	c7 04 24 48 86 10 f0 	movl   $0xf0108648,(%esp)
f0105010:	e8 11 ef ff ff       	call   f0103f26 <cprintf>
		return -E_BAD_ENV; 
f0105015:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f010501a:	e9 a4 04 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}

	pp = page_alloc(1);
f010501f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105026:	e8 94 bf ff ff       	call   f0100fbf <page_alloc>
f010502b:	89 c6                	mov    %eax,%esi
	if (pp == NULL) {
f010502d:	85 c0                	test   %eax,%eax
f010502f:	75 16                	jne    f0105047 <syscall+0x231>
		cprintf("sys_page_alloc: page_alloc failed");
f0105031:	c7 04 24 68 86 10 f0 	movl   $0xf0108668,(%esp)
f0105038:	e8 e9 ee ff ff       	call   f0103f26 <cprintf>
		return -E_NO_MEM;
f010503d:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0105042:	e9 7c 04 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}

	int ret2 = page_insert(e->env_pgdir, pp, va, perm);
f0105047:	8b 45 14             	mov    0x14(%ebp),%eax
f010504a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010504e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105052:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105056:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105059:	8b 40 60             	mov    0x60(%eax),%eax
f010505c:	89 04 24             	mov    %eax,(%esp)
f010505f:	e8 f5 c2 ff ff       	call   f0101359 <page_insert>
	if (ret2 < 0){
f0105064:	85 c0                	test   %eax,%eax
f0105066:	79 1e                	jns    f0105086 <syscall+0x270>
		page_free(pp);
f0105068:	89 34 24             	mov    %esi,(%esp)
f010506b:	e8 02 c0 ff ff       	call   f0101072 <page_free>
		cprintf("sys_page_alloc: page_insert failed");
f0105070:	c7 04 24 8c 86 10 f0 	movl   $0xf010868c,(%esp)
f0105077:	e8 aa ee ff ff       	call   f0103f26 <cprintf>
		return -E_NO_MEM;
f010507c:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0105081:	e9 3d 04 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}
	return 0;
f0105086:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3); 
f010508b:	e9 33 04 00 00       	jmp    f01054c3 <syscall+0x6ad>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE)!=srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE)!=dstva){
f0105090:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105096:	77 26                	ja     f01050be <syscall+0x2a8>
f0105098:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f010509e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01050a3:	39 c3                	cmp    %eax,%ebx
f01050a5:	75 17                	jne    f01050be <syscall+0x2a8>
f01050a7:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01050ad:	77 0f                	ja     f01050be <syscall+0x2a8>
f01050af:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
f01050b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01050ba:	39 c7                	cmp    %eax,%edi
f01050bc:	74 1c                	je     f01050da <syscall+0x2c4>
		panic("sys_page_map: invalid srcva | dstva");
f01050be:	c7 44 24 08 b0 86 10 	movl   $0xf01086b0,0x8(%esp)
f01050c5:	f0 
f01050c6:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f01050cd:	00 
f01050ce:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f01050d5:	e8 66 af ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	if ((perm & ~PTE_SYSCALL)!=0){
f01050da:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01050e1:	74 1c                	je     f01050ff <syscall+0x2e9>
		panic("sys_page_map: invalid permission");
f01050e3:	c7 44 24 08 d4 86 10 	movl   $0xf01086d4,0x8(%esp)
f01050ea:	f0 
f01050eb:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
f01050f2:	00 
f01050f3:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f01050fa:	e8 41 af ff ff       	call   f0100040 <_panic>

	pte_t* srcpte;
	struct Env* srcenv;
	struct Env* dstenv; 
	struct PageInfo* pp;
	if ((envid2env(srcenvid, &srcenv, true) < 0) || envid2env(dstenvid, &dstenv, true) < 0)
f01050ff:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105106:	00 
f0105107:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010510a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010510e:	89 34 24             	mov    %esi,(%esp)
f0105111:	e8 18 e5 ff ff       	call   f010362e <envid2env>
f0105116:	85 c0                	test   %eax,%eax
f0105118:	0f 88 a6 00 00 00    	js     f01051c4 <syscall+0x3ae>
f010511e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105125:	00 
f0105126:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010512d:	8b 55 14             	mov    0x14(%ebp),%edx
f0105130:	89 14 24             	mov    %edx,(%esp)
f0105133:	e8 f6 e4 ff ff       	call   f010362e <envid2env>
f0105138:	85 c0                	test   %eax,%eax
f010513a:	0f 88 8e 00 00 00    	js     f01051ce <syscall+0x3b8>
	  return -E_BAD_ENV;
	pp = page_lookup(srcenv->env_pgdir, srcva, &srcpte);	
f0105140:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105143:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105147:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010514b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010514e:	8b 40 60             	mov    0x60(%eax),%eax
f0105151:	89 04 24             	mov    %eax,(%esp)
f0105154:	e8 f7 c0 ff ff       	call   f0101250 <page_lookup>
	if (pp == NULL || ((perm&PTE_W) > 0 && (*srcpte&PTE_W) == 0)){
f0105159:	85 c0                	test   %eax,%eax
f010515b:	74 0e                	je     f010516b <syscall+0x355>
f010515d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105161:	74 24                	je     f0105187 <syscall+0x371>
f0105163:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105166:	f6 02 02             	testb  $0x2,(%edx)
f0105169:	75 1c                	jne    f0105187 <syscall+0x371>
		panic("sys_page_map: page_lookup failed");
f010516b:	c7 44 24 08 f8 86 10 	movl   $0xf01086f8,0x8(%esp)
f0105172:	f0 
f0105173:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f010517a:	00 
f010517b:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f0105182:	e8 b9 ae ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0){
f0105187:	8b 55 1c             	mov    0x1c(%ebp),%edx
f010518a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010518e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105192:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105199:	8b 40 60             	mov    0x60(%eax),%eax
f010519c:	89 04 24             	mov    %eax,(%esp)
f010519f:	e8 b5 c1 ff ff       	call   f0101359 <page_insert>
f01051a4:	85 c0                	test   %eax,%eax
f01051a6:	79 30                	jns    f01051d8 <syscall+0x3c2>
		panic("sys_page_map: page_insert failed");
f01051a8:	c7 44 24 08 1c 87 10 	movl   $0xf010871c,0x8(%esp)
f01051af:	f0 
f01051b0:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f01051b7:	00 
f01051b8:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f01051bf:	e8 7c ae ff ff       	call   f0100040 <_panic>
	pte_t* srcpte;
	struct Env* srcenv;
	struct Env* dstenv; 
	struct PageInfo* pp;
	if ((envid2env(srcenvid, &srcenv, true) < 0) || envid2env(dstenvid, &dstenv, true) < 0)
	  return -E_BAD_ENV;
f01051c4:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01051c9:	e9 f5 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
f01051ce:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01051d3:	e9 eb 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
	}
	if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0){
		panic("sys_page_map: page_insert failed");
		return -E_NO_MEM;
	}
	return 0;
f01051d8:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3); 
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f01051dd:	e9 e1 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE)!= va)
f01051e2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01051e8:	77 46                	ja     f0105230 <syscall+0x41a>
f01051ea:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f01051f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01051f5:	39 c3                	cmp    %eax,%ebx
f01051f7:	75 41                	jne    f010523a <syscall+0x424>
	  return -E_INVAL;
	struct Env* e;
	if (envid2env(envid, &e, true) < 0)
f01051f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105200:	00 
f0105201:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105204:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105208:	89 34 24             	mov    %esi,(%esp)
f010520b:	e8 1e e4 ff ff       	call   f010362e <envid2env>
f0105210:	85 c0                	test   %eax,%eax
f0105212:	78 30                	js     f0105244 <syscall+0x42e>
	  return -E_BAD_ENV;
	page_remove(e->env_pgdir, va);
f0105214:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010521b:	8b 40 60             	mov    0x60(%eax),%eax
f010521e:	89 04 24             	mov    %eax,(%esp)
f0105221:	e8 e3 c0 ff ff       	call   f0101309 <page_remove>
	return 0;
f0105226:	be 00 00 00 00       	mov    $0x0,%esi
f010522b:	e9 93 02 00 00       	jmp    f01054c3 <syscall+0x6ad>

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE)!= va)
	  return -E_INVAL;
f0105230:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105235:	e9 89 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
f010523a:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010523f:	e9 7f 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
	struct Env* e;
	if (envid2env(envid, &e, true) < 0)
	  return -E_BAD_ENV;
f0105244:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3); 
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
f0105249:	e9 75 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
f010524e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105255:	00 
f0105256:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105259:	89 44 24 04          	mov    %eax,0x4(%esp)
f010525d:	89 34 24             	mov    %esi,(%esp)
f0105260:	e8 c9 e3 ff ff       	call   f010362e <envid2env>
f0105265:	85 c0                	test   %eax,%eax
f0105267:	78 10                	js     f0105279 <syscall+0x463>
	  return -E_BAD_ENV;

	e->env_pgfault_upcall = func;
f0105269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010526c:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f010526f:	be 00 00 00 00       	mov    $0x0,%esi
f0105274:	e9 4a 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
	  return -E_BAD_ENV;
f0105279:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);		
f010527e:	e9 40 02 00 00       	jmp    f01054c3 <syscall+0x6ad>
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");

	int r;
	struct Env* e;
	if (envid2env(envid, &e, 0) < 0){
f0105283:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010528a:	00 
f010528b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010528e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105292:	89 34 24             	mov    %esi,(%esp)
f0105295:	e8 94 e3 ff ff       	call   f010362e <envid2env>
f010529a:	85 c0                	test   %eax,%eax
f010529c:	79 1c                	jns    f01052ba <syscall+0x4a4>
		panic("sys_ipc_try_send: envid2env failed");
f010529e:	c7 44 24 08 40 87 10 	movl   $0xf0108740,0x8(%esp)
f01052a5:	f0 
f01052a6:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f01052ad:	00 
f01052ae:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f01052b5:	e8 86 ad ff ff       	call   f0100040 <_panic>
		return -E_BAD_ENV;
	}
	if (e->env_ipc_recving == false) 
f01052ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052bd:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01052c1:	0f 84 3d 01 00 00    	je     f0105404 <syscall+0x5ee>
	  return -E_IPC_NOT_RECV;
	e->env_ipc_perm = 0;
f01052c7:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	if ((uint32_t)srcva < UTOP){
f01052ce:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01052d5:	0f 87 e6 00 00 00    	ja     f01053c1 <syscall+0x5ab>
		pte_t* pte; 
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f01052db:	e8 e8 13 00 00       	call   f01066c8 <cpunum>
f01052e0:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01052e3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01052e7:	8b 55 14             	mov    0x14(%ebp),%edx
f01052ea:	89 54 24 04          	mov    %edx,0x4(%esp)
f01052ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052f5:	29 c2                	sub    %eax,%edx
f01052f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052fa:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0105301:	8b 40 60             	mov    0x60(%eax),%eax
f0105304:	89 04 24             	mov    %eax,(%esp)
f0105307:	e8 44 bf ff ff       	call   f0101250 <page_lookup>
		if (pte == NULL)
f010530c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010530f:	85 d2                	test   %edx,%edx
f0105311:	0f 84 f7 00 00 00    	je     f010540e <syscall+0x5f8>
		  return -E_INVAL;
		if (ROUNDDOWN(srcva, PGSIZE) != srcva || ((perm & ~PTE_SYSCALL) != 0)){
f0105317:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010531a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0105320:	39 4d 14             	cmp    %ecx,0x14(%ebp)
f0105323:	75 08                	jne    f010532d <syscall+0x517>
f0105325:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f010532b:	74 1c                	je     f0105349 <syscall+0x533>
			panic("sys_ipc_try_send: srcva failed)");
f010532d:	c7 44 24 08 64 87 10 	movl   $0xf0108764,0x8(%esp)
f0105334:	f0 
f0105335:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f010533c:	00 
f010533d:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f0105344:	e8 f7 ac ff ff       	call   f0100040 <_panic>
			return -E_INVAL;
		}
		if ((perm&PTE_W) && (*pte&PTE_W)==0){
f0105349:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010534f:	74 21                	je     f0105372 <syscall+0x55c>
f0105351:	f6 02 02             	testb  $0x2,(%edx)
f0105354:	75 1c                	jne    f0105372 <syscall+0x55c>
			panic("sys_ipc_try_send: permission failed");
f0105356:	c7 44 24 08 84 87 10 	movl   $0xf0108784,0x8(%esp)
f010535d:	f0 
f010535e:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f0105365:	00 
f0105366:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f010536d:	e8 ce ac ff ff       	call   f0100040 <_panic>
			return -E_INVAL;
		}
		if ((uint32_t)e->env_ipc_dstva < UTOP){
f0105372:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105375:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105378:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010537e:	77 41                	ja     f01053c1 <syscall+0x5ab>
			if((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0){
f0105380:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105384:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105388:	89 44 24 04          	mov    %eax,0x4(%esp)
f010538c:	8b 42 60             	mov    0x60(%edx),%eax
f010538f:	89 04 24             	mov    %eax,(%esp)
f0105392:	e8 c2 bf ff ff       	call   f0101359 <page_insert>
f0105397:	85 c0                	test   %eax,%eax
f0105399:	79 20                	jns    f01053bb <syscall+0x5a5>
				panic("sys_ipc_try_send: page_insert failed %e", r);
f010539b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010539f:	c7 44 24 08 a8 87 10 	movl   $0xf01087a8,0x8(%esp)
f01053a6:	f0 
f01053a7:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
f01053ae:	00 
f01053af:	c7 04 24 a9 85 10 f0 	movl   $0xf01085a9,(%esp)
f01053b6:	e8 85 ac ff ff       	call   f0100040 <_panic>
				return -E_NO_MEM;
			}
			e->env_ipc_perm = perm;
f01053bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053be:	89 78 78             	mov    %edi,0x78(%eax)
		}
	}
	e->env_ipc_recving = 0;
f01053c1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01053c4:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id; 
f01053c8:	e8 fb 12 00 00       	call   f01066c8 <cpunum>
f01053cd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01053d4:	29 c2                	sub    %eax,%edx
f01053d6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053d9:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f01053e0:	8b 40 48             	mov    0x48(%eax),%eax
f01053e3:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;
f01053e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053e9:	89 58 70             	mov    %ebx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f01053ec:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax= 0;
f01053f3:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f01053fa:	be 00 00 00 00       	mov    $0x0,%esi
f01053ff:	e9 bf 00 00 00       	jmp    f01054c3 <syscall+0x6ad>
	if (envid2env(envid, &e, 0) < 0){
		panic("sys_ipc_try_send: envid2env failed");
		return -E_BAD_ENV;
	}
	if (e->env_ipc_recving == false) 
	  return -E_IPC_NOT_RECV;
f0105404:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0105409:	e9 b5 00 00 00       	jmp    f01054c3 <syscall+0x6ad>
	e->env_ipc_perm = 0;
	if ((uint32_t)srcva < UTOP){
		pte_t* pte; 
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (pte == NULL)
		  return -E_INVAL;
f010540e:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);		
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f0105413:	e9 ab 00 00 00       	jmp    f01054c3 <syscall+0x6ad>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");

	if (((uint32_t)dstva < UTOP) && (ROUNDDOWN(dstva, PGSIZE) != dstva))
f0105418:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010541e:	77 0f                	ja     f010542f <syscall+0x619>
f0105420:	89 f0                	mov    %esi,%eax
f0105422:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105427:	39 c6                	cmp    %eax,%esi
f0105429:	0f 85 8f 00 00 00    	jne    f01054be <syscall+0x6a8>
	  return -E_INVAL;
	curenv->env_ipc_recving = true;
f010542f:	e8 94 12 00 00       	call   f01066c8 <cpunum>
f0105434:	6b c0 74             	imul   $0x74,%eax,%eax
f0105437:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010543d:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105441:	e8 82 12 00 00       	call   f01066c8 <cpunum>
f0105446:	6b c0 74             	imul   $0x74,%eax,%eax
f0105449:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f010544f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0105456:	e8 6d 12 00 00       	call   f01066c8 <cpunum>
f010545b:	6b c0 74             	imul   $0x74,%eax,%eax
f010545e:	8b 80 28 10 1f f0    	mov    -0xfe0efd8(%eax),%eax
f0105464:	89 70 6c             	mov    %esi,0x6c(%eax)

	sys_yield();
f0105467:	e8 9f f9 ff ff       	call   f0104e0b <sys_yield>
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
	int r;
	struct Env* e;
	if ((r = envid2env(envid, &e, 1)) < 0){
f010546c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105473:	00 
f0105474:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105477:	89 44 24 04          	mov    %eax,0x4(%esp)
f010547b:	89 34 24             	mov    %esi,(%esp)
f010547e:	e8 ab e1 ff ff       	call   f010362e <envid2env>
f0105483:	89 c6                	mov    %eax,%esi
f0105485:	85 c0                	test   %eax,%eax
f0105487:	79 12                	jns    f010549b <syscall+0x685>
		cprintf("sys_env_set_trapframe: envid2env, %e", r);
f0105489:	89 44 24 04          	mov    %eax,0x4(%esp)
f010548d:	c7 04 24 d0 87 10 f0 	movl   $0xf01087d0,(%esp)
f0105494:	e8 8d ea ff ff       	call   f0103f26 <cprintf>
f0105499:	eb 28                	jmp    f01054c3 <syscall+0x6ad>
		return r;
	}
	tf->tf_eflags |= FL_IF;
f010549b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_tf = *tf;
f01054a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054a5:	b9 11 00 00 00       	mov    $0x11,%ecx
f01054aa:	89 c7                	mov    %eax,%edi
f01054ac:	89 de                	mov    %ebx,%esi
f01054ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0;
f01054b0:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);
f01054b5:	eb 0c                	jmp    f01054c3 <syscall+0x6ad>
		default:
			return -E_INVAL;
f01054b7:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01054bc:	eb 05                	jmp    f01054c3 <syscall+0x6ad>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);		
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f01054be:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);
		default:
			return -E_INVAL;
	}	
}
f01054c3:	89 f0                	mov    %esi,%eax
f01054c5:	83 c4 2c             	add    $0x2c,%esp
f01054c8:	5b                   	pop    %ebx
f01054c9:	5e                   	pop    %esi
f01054ca:	5f                   	pop    %edi
f01054cb:	5d                   	pop    %ebp
f01054cc:	c3                   	ret    
f01054cd:	00 00                	add    %al,(%eax)
	...

f01054d0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01054d0:	55                   	push   %ebp
f01054d1:	89 e5                	mov    %esp,%ebp
f01054d3:	57                   	push   %edi
f01054d4:	56                   	push   %esi
f01054d5:	53                   	push   %ebx
f01054d6:	83 ec 14             	sub    $0x14,%esp
f01054d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01054dc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01054df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01054e2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01054e5:	8b 1a                	mov    (%edx),%ebx
f01054e7:	8b 01                	mov    (%ecx),%eax
f01054e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01054ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01054f3:	e9 83 00 00 00       	jmp    f010557b <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f01054f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01054fb:	01 d8                	add    %ebx,%eax
f01054fd:	89 c7                	mov    %eax,%edi
f01054ff:	c1 ef 1f             	shr    $0x1f,%edi
f0105502:	01 c7                	add    %eax,%edi
f0105504:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105506:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105509:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010550c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0105510:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105512:	eb 01                	jmp    f0105515 <stab_binsearch+0x45>
			m--;
f0105514:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105515:	39 c3                	cmp    %eax,%ebx
f0105517:	7f 1e                	jg     f0105537 <stab_binsearch+0x67>
f0105519:	0f b6 0a             	movzbl (%edx),%ecx
f010551c:	83 ea 0c             	sub    $0xc,%edx
f010551f:	39 f1                	cmp    %esi,%ecx
f0105521:	75 f1                	jne    f0105514 <stab_binsearch+0x44>
f0105523:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105526:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105529:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010552c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105530:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105533:	76 18                	jbe    f010554d <stab_binsearch+0x7d>
f0105535:	eb 05                	jmp    f010553c <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105537:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010553a:	eb 3f                	jmp    f010557b <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010553c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010553f:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0105541:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105544:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010554b:	eb 2e                	jmp    f010557b <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010554d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105550:	73 15                	jae    f0105567 <stab_binsearch+0x97>
			*region_right = m - 1;
f0105552:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105555:	49                   	dec    %ecx
f0105556:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105559:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010555c:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010555e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105565:	eb 14                	jmp    f010557b <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105567:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010556a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010556d:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010556f:	ff 45 0c             	incl   0xc(%ebp)
f0105572:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105574:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010557b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010557e:	0f 8e 74 ff ff ff    	jle    f01054f8 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105584:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105588:	75 0d                	jne    f0105597 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010558a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010558d:	8b 02                	mov    (%edx),%eax
f010558f:	48                   	dec    %eax
f0105590:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105593:	89 01                	mov    %eax,(%ecx)
f0105595:	eb 2a                	jmp    f01055c1 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105597:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010559a:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010559c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010559f:	8b 0a                	mov    (%edx),%ecx
f01055a1:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01055a4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01055a7:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01055ab:	eb 01                	jmp    f01055ae <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01055ad:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01055ae:	39 c8                	cmp    %ecx,%eax
f01055b0:	7e 0a                	jle    f01055bc <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f01055b2:	0f b6 1a             	movzbl (%edx),%ebx
f01055b5:	83 ea 0c             	sub    $0xc,%edx
f01055b8:	39 f3                	cmp    %esi,%ebx
f01055ba:	75 f1                	jne    f01055ad <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f01055bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01055bf:	89 02                	mov    %eax,(%edx)
	}
}
f01055c1:	83 c4 14             	add    $0x14,%esp
f01055c4:	5b                   	pop    %ebx
f01055c5:	5e                   	pop    %esi
f01055c6:	5f                   	pop    %edi
f01055c7:	5d                   	pop    %ebp
f01055c8:	c3                   	ret    

f01055c9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01055c9:	55                   	push   %ebp
f01055ca:	89 e5                	mov    %esp,%ebp
f01055cc:	57                   	push   %edi
f01055cd:	56                   	push   %esi
f01055ce:	53                   	push   %ebx
f01055cf:	83 ec 5c             	sub    $0x5c,%esp
f01055d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01055d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01055d8:	c7 03 30 88 10 f0    	movl   $0xf0108830,(%ebx)
	info->eip_line = 0;
f01055de:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01055e5:	c7 43 08 30 88 10 f0 	movl   $0xf0108830,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01055ec:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01055f3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01055f6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01055fd:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105603:	0f 87 df 00 00 00    	ja     f01056e8 <debuginfo_eip+0x11f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0105609:	e8 ba 10 00 00       	call   f01066c8 <cpunum>
f010560e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105615:	00 
f0105616:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010561d:	00 
f010561e:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105625:	00 
f0105626:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010562d:	29 c2                	sub    %eax,%edx
f010562f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105632:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0105639:	89 04 24             	mov    %eax,(%esp)
f010563c:	e8 2d de ff ff       	call   f010346e <user_mem_check>
f0105641:	85 c0                	test   %eax,%eax
f0105643:	0f 88 53 02 00 00    	js     f010589c <debuginfo_eip+0x2d3>
			return -1;

		stabs = usd->stabs;
f0105649:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f010564f:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105652:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0105658:	a1 08 00 20 00       	mov    0x200008,%eax
f010565d:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105660:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105666:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
f0105669:	e8 5a 10 00 00       	call   f01066c8 <cpunum>
f010566e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105675:	00 
f0105676:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010567d:	00 
f010567e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105681:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105685:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010568c:	29 c2                	sub    %eax,%edx
f010568e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105691:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f0105698:	89 04 24             	mov    %eax,(%esp)
f010569b:	e8 ce dd ff ff       	call   f010346e <user_mem_check>
f01056a0:	85 c0                	test   %eax,%eax
f01056a2:	0f 88 fb 01 00 00    	js     f01058a3 <debuginfo_eip+0x2da>
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
f01056a8:	e8 1b 10 00 00       	call   f01066c8 <cpunum>
f01056ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01056b4:	00 
f01056b5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01056bc:	00 
f01056bd:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01056c0:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056cb:	29 c2                	sub    %eax,%edx
f01056cd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056d0:	8b 04 85 28 10 1f f0 	mov    -0xfe0efd8(,%eax,4),%eax
f01056d7:	89 04 24             	mov    %eax,(%esp)
f01056da:	e8 8f dd ff ff       	call   f010346e <user_mem_check>
f01056df:	85 c0                	test   %eax,%eax
f01056e1:	79 1f                	jns    f0105702 <debuginfo_eip+0x139>
f01056e3:	e9 c2 01 00 00       	jmp    f01058aa <debuginfo_eip+0x2e1>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01056e8:	c7 45 c0 89 ee 11 f0 	movl   $0xf011ee89,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01056ef:	c7 45 bc 49 42 11 f0 	movl   $0xf0114249,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01056f6:	bf 48 42 11 f0       	mov    $0xf0114248,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01056fb:	c7 45 c4 d0 8d 10 f0 	movl   $0xf0108dd0,-0x3c(%ebp)
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105702:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105705:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105708:	0f 83 a3 01 00 00    	jae    f01058b1 <debuginfo_eip+0x2e8>
f010570e:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105712:	0f 85 a0 01 00 00    	jne    f01058b8 <debuginfo_eip+0x2ef>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105718:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010571f:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105722:	c1 ff 02             	sar    $0x2,%edi
f0105725:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f0105728:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010572b:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010572e:	89 c2                	mov    %eax,%edx
f0105730:	c1 e2 08             	shl    $0x8,%edx
f0105733:	01 d0                	add    %edx,%eax
f0105735:	89 c2                	mov    %eax,%edx
f0105737:	c1 e2 10             	shl    $0x10,%edx
f010573a:	01 d0                	add    %edx,%eax
f010573c:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f0105740:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105743:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105747:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010574e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105751:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105754:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105757:	e8 74 fd ff ff       	call   f01054d0 <stab_binsearch>
	if (lfile == 0)
f010575c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010575f:	85 c0                	test   %eax,%eax
f0105761:	0f 84 58 01 00 00    	je     f01058bf <debuginfo_eip+0x2f6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105767:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010576a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010576d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105770:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105774:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010577b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010577e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105781:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105784:	e8 47 fd ff ff       	call   f01054d0 <stab_binsearch>

	if (lfun <= rfun) {
f0105789:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010578c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010578f:	39 d0                	cmp    %edx,%eax
f0105791:	7f 32                	jg     f01057c5 <debuginfo_eip+0x1fc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105793:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105796:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105799:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f010579c:	8b 39                	mov    (%ecx),%edi
f010579e:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01057a1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01057a4:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01057a7:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01057aa:	73 09                	jae    f01057b5 <debuginfo_eip+0x1ec>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01057ac:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01057af:	03 7d bc             	add    -0x44(%ebp),%edi
f01057b2:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01057b5:	8b 49 08             	mov    0x8(%ecx),%ecx
f01057b8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01057bb:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01057bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01057c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01057c3:	eb 0f                	jmp    f01057d4 <debuginfo_eip+0x20b>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01057c5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01057c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01057cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01057ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01057d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01057d4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01057db:	00 
f01057dc:	8b 43 08             	mov    0x8(%ebx),%eax
f01057df:	89 04 24             	mov    %eax,(%esp)
f01057e2:	e8 9b 08 00 00       	call   f0106082 <strfind>
f01057e7:	2b 43 08             	sub    0x8(%ebx),%eax
f01057ea:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
f01057ed:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057f1:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01057f8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01057fb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01057fe:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105801:	e8 ca fc ff ff       	call   f01054d0 <stab_binsearch>
	if (lline > rline )
f0105806:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105809:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010580c:	0f 8f b4 00 00 00    	jg     f01058c6 <debuginfo_eip+0x2fd>
		return -1;	
	info->eip_line = stabs[rline].n_desc;
f0105812:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105815:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105818:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f010581d:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105820:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105823:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105826:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105829:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f010582d:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105830:	eb 04                	jmp    f0105836 <debuginfo_eip+0x26d>
f0105832:	48                   	dec    %eax
f0105833:	83 ea 0c             	sub    $0xc,%edx
f0105836:	89 c7                	mov    %eax,%edi
f0105838:	39 c6                	cmp    %eax,%esi
f010583a:	7f 28                	jg     f0105864 <debuginfo_eip+0x29b>
	       && stabs[lline].n_type != N_SOL
f010583c:	8a 4a fc             	mov    -0x4(%edx),%cl
f010583f:	80 f9 84             	cmp    $0x84,%cl
f0105842:	0f 84 99 00 00 00    	je     f01058e1 <debuginfo_eip+0x318>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105848:	80 f9 64             	cmp    $0x64,%cl
f010584b:	75 e5                	jne    f0105832 <debuginfo_eip+0x269>
f010584d:	83 3a 00             	cmpl   $0x0,(%edx)
f0105850:	74 e0                	je     f0105832 <debuginfo_eip+0x269>
f0105852:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105855:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105858:	e9 8a 00 00 00       	jmp    f01058e7 <debuginfo_eip+0x31e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f010585d:	03 45 bc             	add    -0x44(%ebp),%eax
f0105860:	89 03                	mov    %eax,(%ebx)
f0105862:	eb 03                	jmp    f0105867 <debuginfo_eip+0x29e>
f0105864:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105867:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010586a:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010586d:	39 f2                	cmp    %esi,%edx
f010586f:	7d 5c                	jge    f01058cd <debuginfo_eip+0x304>
		for (lline = lfun + 1;
f0105871:	42                   	inc    %edx
f0105872:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105875:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105877:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010587a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010587d:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105881:	eb 03                	jmp    f0105886 <debuginfo_eip+0x2bd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105883:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105886:	39 f0                	cmp    %esi,%eax
f0105888:	7d 4a                	jge    f01058d4 <debuginfo_eip+0x30b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010588a:	8a 0a                	mov    (%edx),%cl
f010588c:	40                   	inc    %eax
f010588d:	83 c2 0c             	add    $0xc,%edx
f0105890:	80 f9 a0             	cmp    $0xa0,%cl
f0105893:	74 ee                	je     f0105883 <debuginfo_eip+0x2ba>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105895:	b8 00 00 00 00       	mov    $0x0,%eax
f010589a:	eb 3d                	jmp    f01058d9 <debuginfo_eip+0x310>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f010589c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058a1:	eb 36                	jmp    f01058d9 <debuginfo_eip+0x310>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
			return -1;
f01058a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058a8:	eb 2f                	jmp    f01058d9 <debuginfo_eip+0x310>
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
f01058aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058af:	eb 28                	jmp    f01058d9 <debuginfo_eip+0x310>
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01058b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058b6:	eb 21                	jmp    f01058d9 <debuginfo_eip+0x310>
f01058b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058bd:	eb 1a                	jmp    f01058d9 <debuginfo_eip+0x310>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01058bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058c4:	eb 13                	jmp    f01058d9 <debuginfo_eip+0x310>
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
	if (lline > rline )
		return -1;	
f01058c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01058cb:	eb 0c                	jmp    f01058d9 <debuginfo_eip+0x310>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01058cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01058d2:	eb 05                	jmp    f01058d9 <debuginfo_eip+0x310>
f01058d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058d9:	83 c4 5c             	add    $0x5c,%esp
f01058dc:	5b                   	pop    %ebx
f01058dd:	5e                   	pop    %esi
f01058de:	5f                   	pop    %edi
f01058df:	5d                   	pop    %ebp
f01058e0:	c3                   	ret    
f01058e1:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01058e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01058e7:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01058ea:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01058ed:	8b 04 87             	mov    (%edi,%eax,4),%eax
f01058f0:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01058f3:	2b 55 bc             	sub    -0x44(%ebp),%edx
f01058f6:	39 d0                	cmp    %edx,%eax
f01058f8:	0f 82 5f ff ff ff    	jb     f010585d <debuginfo_eip+0x294>
f01058fe:	e9 64 ff ff ff       	jmp    f0105867 <debuginfo_eip+0x29e>
	...

f0105904 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105904:	55                   	push   %ebp
f0105905:	89 e5                	mov    %esp,%ebp
f0105907:	57                   	push   %edi
f0105908:	56                   	push   %esi
f0105909:	53                   	push   %ebx
f010590a:	83 ec 3c             	sub    $0x3c,%esp
f010590d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105910:	89 d7                	mov    %edx,%edi
f0105912:	8b 45 08             	mov    0x8(%ebp),%eax
f0105915:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105918:	8b 45 0c             	mov    0xc(%ebp),%eax
f010591b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010591e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105921:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105924:	85 c0                	test   %eax,%eax
f0105926:	75 08                	jne    f0105930 <printnum+0x2c>
f0105928:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010592b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010592e:	77 57                	ja     f0105987 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105930:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105934:	4b                   	dec    %ebx
f0105935:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105939:	8b 45 10             	mov    0x10(%ebp),%eax
f010593c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105940:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105944:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105948:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010594f:	00 
f0105950:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105953:	89 04 24             	mov    %eax,(%esp)
f0105956:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105959:	89 44 24 04          	mov    %eax,0x4(%esp)
f010595d:	e8 d6 11 00 00       	call   f0106b38 <__udivdi3>
f0105962:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105966:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010596a:	89 04 24             	mov    %eax,(%esp)
f010596d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105971:	89 fa                	mov    %edi,%edx
f0105973:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105976:	e8 89 ff ff ff       	call   f0105904 <printnum>
f010597b:	eb 0f                	jmp    f010598c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010597d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105981:	89 34 24             	mov    %esi,(%esp)
f0105984:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105987:	4b                   	dec    %ebx
f0105988:	85 db                	test   %ebx,%ebx
f010598a:	7f f1                	jg     f010597d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010598c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105990:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105994:	8b 45 10             	mov    0x10(%ebp),%eax
f0105997:	89 44 24 08          	mov    %eax,0x8(%esp)
f010599b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01059a2:	00 
f01059a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01059a6:	89 04 24             	mov    %eax,(%esp)
f01059a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059b0:	e8 a3 12 00 00       	call   f0106c58 <__umoddi3>
f01059b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059b9:	0f be 80 3a 88 10 f0 	movsbl -0xfef77c6(%eax),%eax
f01059c0:	89 04 24             	mov    %eax,(%esp)
f01059c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01059c6:	83 c4 3c             	add    $0x3c,%esp
f01059c9:	5b                   	pop    %ebx
f01059ca:	5e                   	pop    %esi
f01059cb:	5f                   	pop    %edi
f01059cc:	5d                   	pop    %ebp
f01059cd:	c3                   	ret    

f01059ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01059ce:	55                   	push   %ebp
f01059cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01059d1:	83 fa 01             	cmp    $0x1,%edx
f01059d4:	7e 0e                	jle    f01059e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01059d6:	8b 10                	mov    (%eax),%edx
f01059d8:	8d 4a 08             	lea    0x8(%edx),%ecx
f01059db:	89 08                	mov    %ecx,(%eax)
f01059dd:	8b 02                	mov    (%edx),%eax
f01059df:	8b 52 04             	mov    0x4(%edx),%edx
f01059e2:	eb 22                	jmp    f0105a06 <getuint+0x38>
	else if (lflag)
f01059e4:	85 d2                	test   %edx,%edx
f01059e6:	74 10                	je     f01059f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01059e8:	8b 10                	mov    (%eax),%edx
f01059ea:	8d 4a 04             	lea    0x4(%edx),%ecx
f01059ed:	89 08                	mov    %ecx,(%eax)
f01059ef:	8b 02                	mov    (%edx),%eax
f01059f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01059f6:	eb 0e                	jmp    f0105a06 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01059f8:	8b 10                	mov    (%eax),%edx
f01059fa:	8d 4a 04             	lea    0x4(%edx),%ecx
f01059fd:	89 08                	mov    %ecx,(%eax)
f01059ff:	8b 02                	mov    (%edx),%eax
f0105a01:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105a06:	5d                   	pop    %ebp
f0105a07:	c3                   	ret    

f0105a08 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105a08:	55                   	push   %ebp
f0105a09:	89 e5                	mov    %esp,%ebp
f0105a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105a0e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105a11:	8b 10                	mov    (%eax),%edx
f0105a13:	3b 50 04             	cmp    0x4(%eax),%edx
f0105a16:	73 08                	jae    f0105a20 <sprintputch+0x18>
		*b->buf++ = ch;
f0105a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a1b:	88 0a                	mov    %cl,(%edx)
f0105a1d:	42                   	inc    %edx
f0105a1e:	89 10                	mov    %edx,(%eax)
}
f0105a20:	5d                   	pop    %ebp
f0105a21:	c3                   	ret    

f0105a22 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105a22:	55                   	push   %ebp
f0105a23:	89 e5                	mov    %esp,%ebp
f0105a25:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105a28:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a2f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a32:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a36:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105a39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a40:	89 04 24             	mov    %eax,(%esp)
f0105a43:	e8 02 00 00 00       	call   f0105a4a <vprintfmt>
	va_end(ap);
}
f0105a48:	c9                   	leave  
f0105a49:	c3                   	ret    

f0105a4a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105a4a:	55                   	push   %ebp
f0105a4b:	89 e5                	mov    %esp,%ebp
f0105a4d:	57                   	push   %edi
f0105a4e:	56                   	push   %esi
f0105a4f:	53                   	push   %ebx
f0105a50:	83 ec 4c             	sub    $0x4c,%esp
f0105a53:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a56:	8b 75 10             	mov    0x10(%ebp),%esi
f0105a59:	eb 12                	jmp    f0105a6d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105a5b:	85 c0                	test   %eax,%eax
f0105a5d:	0f 84 6b 03 00 00    	je     f0105dce <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105a63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a67:	89 04 24             	mov    %eax,(%esp)
f0105a6a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105a6d:	0f b6 06             	movzbl (%esi),%eax
f0105a70:	46                   	inc    %esi
f0105a71:	83 f8 25             	cmp    $0x25,%eax
f0105a74:	75 e5                	jne    f0105a5b <vprintfmt+0x11>
f0105a76:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105a7a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105a81:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105a86:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105a8d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a92:	eb 26                	jmp    f0105aba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a94:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105a97:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105a9b:	eb 1d                	jmp    f0105aba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a9d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105aa0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105aa4:	eb 14                	jmp    f0105aba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105aa6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105aa9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105ab0:	eb 08                	jmp    f0105aba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105ab2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105ab5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105aba:	0f b6 06             	movzbl (%esi),%eax
f0105abd:	8d 56 01             	lea    0x1(%esi),%edx
f0105ac0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105ac3:	8a 16                	mov    (%esi),%dl
f0105ac5:	83 ea 23             	sub    $0x23,%edx
f0105ac8:	80 fa 55             	cmp    $0x55,%dl
f0105acb:	0f 87 e1 02 00 00    	ja     f0105db2 <vprintfmt+0x368>
f0105ad1:	0f b6 d2             	movzbl %dl,%edx
f0105ad4:	ff 24 95 80 89 10 f0 	jmp    *-0xfef7680(,%edx,4)
f0105adb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105ade:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105ae3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105ae6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105aea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105aed:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105af0:	83 fa 09             	cmp    $0x9,%edx
f0105af3:	77 2a                	ja     f0105b1f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105af5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105af6:	eb eb                	jmp    f0105ae3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105af8:	8b 45 14             	mov    0x14(%ebp),%eax
f0105afb:	8d 50 04             	lea    0x4(%eax),%edx
f0105afe:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b01:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b03:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105b06:	eb 17                	jmp    f0105b1f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105b08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105b0c:	78 98                	js     f0105aa6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105b11:	eb a7                	jmp    f0105aba <vprintfmt+0x70>
f0105b13:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105b16:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105b1d:	eb 9b                	jmp    f0105aba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105b1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105b23:	79 95                	jns    f0105aba <vprintfmt+0x70>
f0105b25:	eb 8b                	jmp    f0105ab2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105b27:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b28:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105b2b:	eb 8d                	jmp    f0105aba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105b2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b30:	8d 50 04             	lea    0x4(%eax),%edx
f0105b33:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b3a:	8b 00                	mov    (%eax),%eax
f0105b3c:	89 04 24             	mov    %eax,(%esp)
f0105b3f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b42:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105b45:	e9 23 ff ff ff       	jmp    f0105a6d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105b4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b4d:	8d 50 04             	lea    0x4(%eax),%edx
f0105b50:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b53:	8b 00                	mov    (%eax),%eax
f0105b55:	85 c0                	test   %eax,%eax
f0105b57:	79 02                	jns    f0105b5b <vprintfmt+0x111>
f0105b59:	f7 d8                	neg    %eax
f0105b5b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105b5d:	83 f8 0f             	cmp    $0xf,%eax
f0105b60:	7f 0b                	jg     f0105b6d <vprintfmt+0x123>
f0105b62:	8b 04 85 e0 8a 10 f0 	mov    -0xfef7520(,%eax,4),%eax
f0105b69:	85 c0                	test   %eax,%eax
f0105b6b:	75 23                	jne    f0105b90 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105b6d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105b71:	c7 44 24 08 52 88 10 	movl   $0xf0108852,0x8(%esp)
f0105b78:	f0 
f0105b79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b80:	89 04 24             	mov    %eax,(%esp)
f0105b83:	e8 9a fe ff ff       	call   f0105a22 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b88:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105b8b:	e9 dd fe ff ff       	jmp    f0105a6d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b94:	c7 44 24 08 f5 7c 10 	movl   $0xf0107cf5,0x8(%esp)
f0105b9b:	f0 
f0105b9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ba0:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ba3:	89 14 24             	mov    %edx,(%esp)
f0105ba6:	e8 77 fe ff ff       	call   f0105a22 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105bab:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105bae:	e9 ba fe ff ff       	jmp    f0105a6d <vprintfmt+0x23>
f0105bb3:	89 f9                	mov    %edi,%ecx
f0105bb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bb8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105bbb:	8b 45 14             	mov    0x14(%ebp),%eax
f0105bbe:	8d 50 04             	lea    0x4(%eax),%edx
f0105bc1:	89 55 14             	mov    %edx,0x14(%ebp)
f0105bc4:	8b 30                	mov    (%eax),%esi
f0105bc6:	85 f6                	test   %esi,%esi
f0105bc8:	75 05                	jne    f0105bcf <vprintfmt+0x185>
				p = "(null)";
f0105bca:	be 4b 88 10 f0       	mov    $0xf010884b,%esi
			if (width > 0 && padc != '-')
f0105bcf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105bd3:	0f 8e 84 00 00 00    	jle    f0105c5d <vprintfmt+0x213>
f0105bd9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105bdd:	74 7e                	je     f0105c5d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105bdf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105be3:	89 34 24             	mov    %esi,(%esp)
f0105be6:	e8 63 03 00 00       	call   f0105f4e <strnlen>
f0105beb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105bee:	29 c2                	sub    %eax,%edx
f0105bf0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105bf3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105bf7:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105bfa:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105bfd:	89 de                	mov    %ebx,%esi
f0105bff:	89 d3                	mov    %edx,%ebx
f0105c01:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c03:	eb 0b                	jmp    f0105c10 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105c05:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c09:	89 3c 24             	mov    %edi,(%esp)
f0105c0c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105c0f:	4b                   	dec    %ebx
f0105c10:	85 db                	test   %ebx,%ebx
f0105c12:	7f f1                	jg     f0105c05 <vprintfmt+0x1bb>
f0105c14:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105c17:	89 f3                	mov    %esi,%ebx
f0105c19:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c1f:	85 c0                	test   %eax,%eax
f0105c21:	79 05                	jns    f0105c28 <vprintfmt+0x1de>
f0105c23:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105c2b:	29 c2                	sub    %eax,%edx
f0105c2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105c30:	eb 2b                	jmp    f0105c5d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105c32:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105c36:	74 18                	je     f0105c50 <vprintfmt+0x206>
f0105c38:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105c3b:	83 fa 5e             	cmp    $0x5e,%edx
f0105c3e:	76 10                	jbe    f0105c50 <vprintfmt+0x206>
					putch('?', putdat);
f0105c40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c44:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105c4b:	ff 55 08             	call   *0x8(%ebp)
f0105c4e:	eb 0a                	jmp    f0105c5a <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105c50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c54:	89 04 24             	mov    %eax,(%esp)
f0105c57:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105c5a:	ff 4d e4             	decl   -0x1c(%ebp)
f0105c5d:	0f be 06             	movsbl (%esi),%eax
f0105c60:	46                   	inc    %esi
f0105c61:	85 c0                	test   %eax,%eax
f0105c63:	74 21                	je     f0105c86 <vprintfmt+0x23c>
f0105c65:	85 ff                	test   %edi,%edi
f0105c67:	78 c9                	js     f0105c32 <vprintfmt+0x1e8>
f0105c69:	4f                   	dec    %edi
f0105c6a:	79 c6                	jns    f0105c32 <vprintfmt+0x1e8>
f0105c6c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105c6f:	89 de                	mov    %ebx,%esi
f0105c71:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105c74:	eb 18                	jmp    f0105c8e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105c76:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105c7a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105c81:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105c83:	4b                   	dec    %ebx
f0105c84:	eb 08                	jmp    f0105c8e <vprintfmt+0x244>
f0105c86:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105c89:	89 de                	mov    %ebx,%esi
f0105c8b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105c8e:	85 db                	test   %ebx,%ebx
f0105c90:	7f e4                	jg     f0105c76 <vprintfmt+0x22c>
f0105c92:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105c95:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c97:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105c9a:	e9 ce fd ff ff       	jmp    f0105a6d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105c9f:	83 f9 01             	cmp    $0x1,%ecx
f0105ca2:	7e 10                	jle    f0105cb4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0105ca4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ca7:	8d 50 08             	lea    0x8(%eax),%edx
f0105caa:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cad:	8b 30                	mov    (%eax),%esi
f0105caf:	8b 78 04             	mov    0x4(%eax),%edi
f0105cb2:	eb 26                	jmp    f0105cda <vprintfmt+0x290>
	else if (lflag)
f0105cb4:	85 c9                	test   %ecx,%ecx
f0105cb6:	74 12                	je     f0105cca <vprintfmt+0x280>
		return va_arg(*ap, long);
f0105cb8:	8b 45 14             	mov    0x14(%ebp),%eax
f0105cbb:	8d 50 04             	lea    0x4(%eax),%edx
f0105cbe:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cc1:	8b 30                	mov    (%eax),%esi
f0105cc3:	89 f7                	mov    %esi,%edi
f0105cc5:	c1 ff 1f             	sar    $0x1f,%edi
f0105cc8:	eb 10                	jmp    f0105cda <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0105cca:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ccd:	8d 50 04             	lea    0x4(%eax),%edx
f0105cd0:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cd3:	8b 30                	mov    (%eax),%esi
f0105cd5:	89 f7                	mov    %esi,%edi
f0105cd7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105cda:	85 ff                	test   %edi,%edi
f0105cdc:	78 0a                	js     f0105ce8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105cde:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ce3:	e9 8c 00 00 00       	jmp    f0105d74 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105ce8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105cec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105cf3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105cf6:	f7 de                	neg    %esi
f0105cf8:	83 d7 00             	adc    $0x0,%edi
f0105cfb:	f7 df                	neg    %edi
			}
			base = 10;
f0105cfd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d02:	eb 70                	jmp    f0105d74 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105d04:	89 ca                	mov    %ecx,%edx
f0105d06:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d09:	e8 c0 fc ff ff       	call   f01059ce <getuint>
f0105d0e:	89 c6                	mov    %eax,%esi
f0105d10:	89 d7                	mov    %edx,%edi
			base = 10;
f0105d12:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105d17:	eb 5b                	jmp    f0105d74 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
f0105d19:	89 ca                	mov    %ecx,%edx
f0105d1b:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d1e:	e8 ab fc ff ff       	call   f01059ce <getuint>
f0105d23:	89 c6                	mov    %eax,%esi
f0105d25:	89 d7                	mov    %edx,%edi
			base = 8;
f0105d27:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105d2c:	eb 46                	jmp    f0105d74 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105d2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d32:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105d39:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105d3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d40:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105d47:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105d4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d4d:	8d 50 04             	lea    0x4(%eax),%edx
f0105d50:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105d53:	8b 30                	mov    (%eax),%esi
f0105d55:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105d5a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105d5f:	eb 13                	jmp    f0105d74 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105d61:	89 ca                	mov    %ecx,%edx
f0105d63:	8d 45 14             	lea    0x14(%ebp),%eax
f0105d66:	e8 63 fc ff ff       	call   f01059ce <getuint>
f0105d6b:	89 c6                	mov    %eax,%esi
f0105d6d:	89 d7                	mov    %edx,%edi
			base = 16;
f0105d6f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105d74:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105d78:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105d7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105d7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d83:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d87:	89 34 24             	mov    %esi,(%esp)
f0105d8a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d8e:	89 da                	mov    %ebx,%edx
f0105d90:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d93:	e8 6c fb ff ff       	call   f0105904 <printnum>
			break;
f0105d98:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105d9b:	e9 cd fc ff ff       	jmp    f0105a6d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105da0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105da4:	89 04 24             	mov    %eax,(%esp)
f0105da7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105daa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105dad:	e9 bb fc ff ff       	jmp    f0105a6d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105db2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105db6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105dbd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105dc0:	eb 01                	jmp    f0105dc3 <vprintfmt+0x379>
f0105dc2:	4e                   	dec    %esi
f0105dc3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105dc7:	75 f9                	jne    f0105dc2 <vprintfmt+0x378>
f0105dc9:	e9 9f fc ff ff       	jmp    f0105a6d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105dce:	83 c4 4c             	add    $0x4c,%esp
f0105dd1:	5b                   	pop    %ebx
f0105dd2:	5e                   	pop    %esi
f0105dd3:	5f                   	pop    %edi
f0105dd4:	5d                   	pop    %ebp
f0105dd5:	c3                   	ret    

f0105dd6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105dd6:	55                   	push   %ebp
f0105dd7:	89 e5                	mov    %esp,%ebp
f0105dd9:	83 ec 28             	sub    $0x28,%esp
f0105ddc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105de5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105de9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105dec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105df3:	85 c0                	test   %eax,%eax
f0105df5:	74 30                	je     f0105e27 <vsnprintf+0x51>
f0105df7:	85 d2                	test   %edx,%edx
f0105df9:	7e 33                	jle    f0105e2e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105dfb:	8b 45 14             	mov    0x14(%ebp),%eax
f0105dfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e02:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e05:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e09:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105e0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e10:	c7 04 24 08 5a 10 f0 	movl   $0xf0105a08,(%esp)
f0105e17:	e8 2e fc ff ff       	call   f0105a4a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105e1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105e1f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105e25:	eb 0c                	jmp    f0105e33 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105e27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105e2c:	eb 05                	jmp    f0105e33 <vsnprintf+0x5d>
f0105e2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105e33:	c9                   	leave  
f0105e34:	c3                   	ret    

f0105e35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105e35:	55                   	push   %ebp
f0105e36:	89 e5                	mov    %esp,%ebp
f0105e38:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105e3b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105e3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e42:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e45:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e49:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e50:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e53:	89 04 24             	mov    %eax,(%esp)
f0105e56:	e8 7b ff ff ff       	call   f0105dd6 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105e5b:	c9                   	leave  
f0105e5c:	c3                   	ret    
f0105e5d:	00 00                	add    %al,(%eax)
	...

f0105e60 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105e60:	55                   	push   %ebp
f0105e61:	89 e5                	mov    %esp,%ebp
f0105e63:	57                   	push   %edi
f0105e64:	56                   	push   %esi
f0105e65:	53                   	push   %ebx
f0105e66:	83 ec 1c             	sub    $0x1c,%esp
f0105e69:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105e6c:	85 c0                	test   %eax,%eax
f0105e6e:	74 10                	je     f0105e80 <readline+0x20>
		cprintf("%s", prompt);
f0105e70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e74:	c7 04 24 f5 7c 10 f0 	movl   $0xf0107cf5,(%esp)
f0105e7b:	e8 a6 e0 ff ff       	call   f0103f26 <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105e80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105e87:	e8 1d a9 ff ff       	call   f01007a9 <iscons>
f0105e8c:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105e8e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105e93:	e8 00 a9 ff ff       	call   f0100798 <getchar>
f0105e98:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105e9a:	85 c0                	test   %eax,%eax
f0105e9c:	79 20                	jns    f0105ebe <readline+0x5e>
			if (c != -E_EOF)
f0105e9e:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105ea1:	0f 84 82 00 00 00    	je     f0105f29 <readline+0xc9>
				cprintf("read error: %e\n", c);
f0105ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105eab:	c7 04 24 3f 8b 10 f0 	movl   $0xf0108b3f,(%esp)
f0105eb2:	e8 6f e0 ff ff       	call   f0103f26 <cprintf>
			return NULL;
f0105eb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ebc:	eb 70                	jmp    f0105f2e <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105ebe:	83 f8 08             	cmp    $0x8,%eax
f0105ec1:	74 05                	je     f0105ec8 <readline+0x68>
f0105ec3:	83 f8 7f             	cmp    $0x7f,%eax
f0105ec6:	75 17                	jne    f0105edf <readline+0x7f>
f0105ec8:	85 f6                	test   %esi,%esi
f0105eca:	7e 13                	jle    f0105edf <readline+0x7f>
			if (echoing)
f0105ecc:	85 ff                	test   %edi,%edi
f0105ece:	74 0c                	je     f0105edc <readline+0x7c>
				cputchar('\b');
f0105ed0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105ed7:	e8 ac a8 ff ff       	call   f0100788 <cputchar>
			i--;
f0105edc:	4e                   	dec    %esi
f0105edd:	eb b4                	jmp    f0105e93 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105edf:	83 fb 1f             	cmp    $0x1f,%ebx
f0105ee2:	7e 1d                	jle    f0105f01 <readline+0xa1>
f0105ee4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105eea:	7f 15                	jg     f0105f01 <readline+0xa1>
			if (echoing)
f0105eec:	85 ff                	test   %edi,%edi
f0105eee:	74 08                	je     f0105ef8 <readline+0x98>
				cputchar(c);
f0105ef0:	89 1c 24             	mov    %ebx,(%esp)
f0105ef3:	e8 90 a8 ff ff       	call   f0100788 <cputchar>
			buf[i++] = c;
f0105ef8:	88 9e 80 0a 1f f0    	mov    %bl,-0xfe0f580(%esi)
f0105efe:	46                   	inc    %esi
f0105eff:	eb 92                	jmp    f0105e93 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105f01:	83 fb 0a             	cmp    $0xa,%ebx
f0105f04:	74 05                	je     f0105f0b <readline+0xab>
f0105f06:	83 fb 0d             	cmp    $0xd,%ebx
f0105f09:	75 88                	jne    f0105e93 <readline+0x33>
			if (echoing)
f0105f0b:	85 ff                	test   %edi,%edi
f0105f0d:	74 0c                	je     f0105f1b <readline+0xbb>
				cputchar('\n');
f0105f0f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105f16:	e8 6d a8 ff ff       	call   f0100788 <cputchar>
			buf[i] = 0;
f0105f1b:	c6 86 80 0a 1f f0 00 	movb   $0x0,-0xfe0f580(%esi)
			return buf;
f0105f22:	b8 80 0a 1f f0       	mov    $0xf01f0a80,%eax
f0105f27:	eb 05                	jmp    f0105f2e <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105f29:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105f2e:	83 c4 1c             	add    $0x1c,%esp
f0105f31:	5b                   	pop    %ebx
f0105f32:	5e                   	pop    %esi
f0105f33:	5f                   	pop    %edi
f0105f34:	5d                   	pop    %ebp
f0105f35:	c3                   	ret    
	...

f0105f38 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105f38:	55                   	push   %ebp
f0105f39:	89 e5                	mov    %esp,%ebp
f0105f3b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105f3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f43:	eb 01                	jmp    f0105f46 <strlen+0xe>
		n++;
f0105f45:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105f46:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105f4a:	75 f9                	jne    f0105f45 <strlen+0xd>
		n++;
	return n;
}
f0105f4c:	5d                   	pop    %ebp
f0105f4d:	c3                   	ret    

f0105f4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105f4e:	55                   	push   %ebp
f0105f4f:	89 e5                	mov    %esp,%ebp
f0105f51:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105f54:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105f57:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f5c:	eb 01                	jmp    f0105f5f <strnlen+0x11>
		n++;
f0105f5e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105f5f:	39 d0                	cmp    %edx,%eax
f0105f61:	74 06                	je     f0105f69 <strnlen+0x1b>
f0105f63:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105f67:	75 f5                	jne    f0105f5e <strnlen+0x10>
		n++;
	return n;
}
f0105f69:	5d                   	pop    %ebp
f0105f6a:	c3                   	ret    

f0105f6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105f6b:	55                   	push   %ebp
f0105f6c:	89 e5                	mov    %esp,%ebp
f0105f6e:	53                   	push   %ebx
f0105f6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105f75:	ba 00 00 00 00       	mov    $0x0,%edx
f0105f7a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105f7d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105f80:	42                   	inc    %edx
f0105f81:	84 c9                	test   %cl,%cl
f0105f83:	75 f5                	jne    f0105f7a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105f85:	5b                   	pop    %ebx
f0105f86:	5d                   	pop    %ebp
f0105f87:	c3                   	ret    

f0105f88 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105f88:	55                   	push   %ebp
f0105f89:	89 e5                	mov    %esp,%ebp
f0105f8b:	53                   	push   %ebx
f0105f8c:	83 ec 08             	sub    $0x8,%esp
f0105f8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105f92:	89 1c 24             	mov    %ebx,(%esp)
f0105f95:	e8 9e ff ff ff       	call   f0105f38 <strlen>
	strcpy(dst + len, src);
f0105f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f9d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105fa1:	01 d8                	add    %ebx,%eax
f0105fa3:	89 04 24             	mov    %eax,(%esp)
f0105fa6:	e8 c0 ff ff ff       	call   f0105f6b <strcpy>
	return dst;
}
f0105fab:	89 d8                	mov    %ebx,%eax
f0105fad:	83 c4 08             	add    $0x8,%esp
f0105fb0:	5b                   	pop    %ebx
f0105fb1:	5d                   	pop    %ebp
f0105fb2:	c3                   	ret    

f0105fb3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105fb3:	55                   	push   %ebp
f0105fb4:	89 e5                	mov    %esp,%ebp
f0105fb6:	56                   	push   %esi
f0105fb7:	53                   	push   %ebx
f0105fb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105fbe:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105fc1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105fc6:	eb 0c                	jmp    f0105fd4 <strncpy+0x21>
		*dst++ = *src;
f0105fc8:	8a 1a                	mov    (%edx),%bl
f0105fca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105fcd:	80 3a 01             	cmpb   $0x1,(%edx)
f0105fd0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105fd3:	41                   	inc    %ecx
f0105fd4:	39 f1                	cmp    %esi,%ecx
f0105fd6:	75 f0                	jne    f0105fc8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105fd8:	5b                   	pop    %ebx
f0105fd9:	5e                   	pop    %esi
f0105fda:	5d                   	pop    %ebp
f0105fdb:	c3                   	ret    

f0105fdc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105fdc:	55                   	push   %ebp
f0105fdd:	89 e5                	mov    %esp,%ebp
f0105fdf:	56                   	push   %esi
f0105fe0:	53                   	push   %ebx
f0105fe1:	8b 75 08             	mov    0x8(%ebp),%esi
f0105fe4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105fe7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105fea:	85 d2                	test   %edx,%edx
f0105fec:	75 0a                	jne    f0105ff8 <strlcpy+0x1c>
f0105fee:	89 f0                	mov    %esi,%eax
f0105ff0:	eb 1a                	jmp    f010600c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105ff2:	88 18                	mov    %bl,(%eax)
f0105ff4:	40                   	inc    %eax
f0105ff5:	41                   	inc    %ecx
f0105ff6:	eb 02                	jmp    f0105ffa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105ff8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0105ffa:	4a                   	dec    %edx
f0105ffb:	74 0a                	je     f0106007 <strlcpy+0x2b>
f0105ffd:	8a 19                	mov    (%ecx),%bl
f0105fff:	84 db                	test   %bl,%bl
f0106001:	75 ef                	jne    f0105ff2 <strlcpy+0x16>
f0106003:	89 c2                	mov    %eax,%edx
f0106005:	eb 02                	jmp    f0106009 <strlcpy+0x2d>
f0106007:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0106009:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f010600c:	29 f0                	sub    %esi,%eax
}
f010600e:	5b                   	pop    %ebx
f010600f:	5e                   	pop    %esi
f0106010:	5d                   	pop    %ebp
f0106011:	c3                   	ret    

f0106012 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106012:	55                   	push   %ebp
f0106013:	89 e5                	mov    %esp,%ebp
f0106015:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106018:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010601b:	eb 02                	jmp    f010601f <strcmp+0xd>
		p++, q++;
f010601d:	41                   	inc    %ecx
f010601e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010601f:	8a 01                	mov    (%ecx),%al
f0106021:	84 c0                	test   %al,%al
f0106023:	74 04                	je     f0106029 <strcmp+0x17>
f0106025:	3a 02                	cmp    (%edx),%al
f0106027:	74 f4                	je     f010601d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106029:	0f b6 c0             	movzbl %al,%eax
f010602c:	0f b6 12             	movzbl (%edx),%edx
f010602f:	29 d0                	sub    %edx,%eax
}
f0106031:	5d                   	pop    %ebp
f0106032:	c3                   	ret    

f0106033 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106033:	55                   	push   %ebp
f0106034:	89 e5                	mov    %esp,%ebp
f0106036:	53                   	push   %ebx
f0106037:	8b 45 08             	mov    0x8(%ebp),%eax
f010603a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010603d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0106040:	eb 03                	jmp    f0106045 <strncmp+0x12>
		n--, p++, q++;
f0106042:	4a                   	dec    %edx
f0106043:	40                   	inc    %eax
f0106044:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106045:	85 d2                	test   %edx,%edx
f0106047:	74 14                	je     f010605d <strncmp+0x2a>
f0106049:	8a 18                	mov    (%eax),%bl
f010604b:	84 db                	test   %bl,%bl
f010604d:	74 04                	je     f0106053 <strncmp+0x20>
f010604f:	3a 19                	cmp    (%ecx),%bl
f0106051:	74 ef                	je     f0106042 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106053:	0f b6 00             	movzbl (%eax),%eax
f0106056:	0f b6 11             	movzbl (%ecx),%edx
f0106059:	29 d0                	sub    %edx,%eax
f010605b:	eb 05                	jmp    f0106062 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010605d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106062:	5b                   	pop    %ebx
f0106063:	5d                   	pop    %ebp
f0106064:	c3                   	ret    

f0106065 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106065:	55                   	push   %ebp
f0106066:	89 e5                	mov    %esp,%ebp
f0106068:	8b 45 08             	mov    0x8(%ebp),%eax
f010606b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010606e:	eb 05                	jmp    f0106075 <strchr+0x10>
		if (*s == c)
f0106070:	38 ca                	cmp    %cl,%dl
f0106072:	74 0c                	je     f0106080 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106074:	40                   	inc    %eax
f0106075:	8a 10                	mov    (%eax),%dl
f0106077:	84 d2                	test   %dl,%dl
f0106079:	75 f5                	jne    f0106070 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f010607b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106080:	5d                   	pop    %ebp
f0106081:	c3                   	ret    

f0106082 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106082:	55                   	push   %ebp
f0106083:	89 e5                	mov    %esp,%ebp
f0106085:	8b 45 08             	mov    0x8(%ebp),%eax
f0106088:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010608b:	eb 05                	jmp    f0106092 <strfind+0x10>
		if (*s == c)
f010608d:	38 ca                	cmp    %cl,%dl
f010608f:	74 07                	je     f0106098 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106091:	40                   	inc    %eax
f0106092:	8a 10                	mov    (%eax),%dl
f0106094:	84 d2                	test   %dl,%dl
f0106096:	75 f5                	jne    f010608d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0106098:	5d                   	pop    %ebp
f0106099:	c3                   	ret    

f010609a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010609a:	55                   	push   %ebp
f010609b:	89 e5                	mov    %esp,%ebp
f010609d:	57                   	push   %edi
f010609e:	56                   	push   %esi
f010609f:	53                   	push   %ebx
f01060a0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060a3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01060a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01060a9:	85 c9                	test   %ecx,%ecx
f01060ab:	74 30                	je     f01060dd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01060ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01060b3:	75 25                	jne    f01060da <memset+0x40>
f01060b5:	f6 c1 03             	test   $0x3,%cl
f01060b8:	75 20                	jne    f01060da <memset+0x40>
		c &= 0xFF;
f01060ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01060bd:	89 d3                	mov    %edx,%ebx
f01060bf:	c1 e3 08             	shl    $0x8,%ebx
f01060c2:	89 d6                	mov    %edx,%esi
f01060c4:	c1 e6 18             	shl    $0x18,%esi
f01060c7:	89 d0                	mov    %edx,%eax
f01060c9:	c1 e0 10             	shl    $0x10,%eax
f01060cc:	09 f0                	or     %esi,%eax
f01060ce:	09 d0                	or     %edx,%eax
f01060d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01060d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01060d5:	fc                   	cld    
f01060d6:	f3 ab                	rep stos %eax,%es:(%edi)
f01060d8:	eb 03                	jmp    f01060dd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01060da:	fc                   	cld    
f01060db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01060dd:	89 f8                	mov    %edi,%eax
f01060df:	5b                   	pop    %ebx
f01060e0:	5e                   	pop    %esi
f01060e1:	5f                   	pop    %edi
f01060e2:	5d                   	pop    %ebp
f01060e3:	c3                   	ret    

f01060e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01060e4:	55                   	push   %ebp
f01060e5:	89 e5                	mov    %esp,%ebp
f01060e7:	57                   	push   %edi
f01060e8:	56                   	push   %esi
f01060e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01060ec:	8b 75 0c             	mov    0xc(%ebp),%esi
f01060ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01060f2:	39 c6                	cmp    %eax,%esi
f01060f4:	73 34                	jae    f010612a <memmove+0x46>
f01060f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01060f9:	39 d0                	cmp    %edx,%eax
f01060fb:	73 2d                	jae    f010612a <memmove+0x46>
		s += n;
		d += n;
f01060fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106100:	f6 c2 03             	test   $0x3,%dl
f0106103:	75 1b                	jne    f0106120 <memmove+0x3c>
f0106105:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010610b:	75 13                	jne    f0106120 <memmove+0x3c>
f010610d:	f6 c1 03             	test   $0x3,%cl
f0106110:	75 0e                	jne    f0106120 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106112:	83 ef 04             	sub    $0x4,%edi
f0106115:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106118:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010611b:	fd                   	std    
f010611c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010611e:	eb 07                	jmp    f0106127 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106120:	4f                   	dec    %edi
f0106121:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106124:	fd                   	std    
f0106125:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106127:	fc                   	cld    
f0106128:	eb 20                	jmp    f010614a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010612a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106130:	75 13                	jne    f0106145 <memmove+0x61>
f0106132:	a8 03                	test   $0x3,%al
f0106134:	75 0f                	jne    f0106145 <memmove+0x61>
f0106136:	f6 c1 03             	test   $0x3,%cl
f0106139:	75 0a                	jne    f0106145 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010613b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010613e:	89 c7                	mov    %eax,%edi
f0106140:	fc                   	cld    
f0106141:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106143:	eb 05                	jmp    f010614a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106145:	89 c7                	mov    %eax,%edi
f0106147:	fc                   	cld    
f0106148:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010614a:	5e                   	pop    %esi
f010614b:	5f                   	pop    %edi
f010614c:	5d                   	pop    %ebp
f010614d:	c3                   	ret    

f010614e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010614e:	55                   	push   %ebp
f010614f:	89 e5                	mov    %esp,%ebp
f0106151:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106154:	8b 45 10             	mov    0x10(%ebp),%eax
f0106157:	89 44 24 08          	mov    %eax,0x8(%esp)
f010615b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010615e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106162:	8b 45 08             	mov    0x8(%ebp),%eax
f0106165:	89 04 24             	mov    %eax,(%esp)
f0106168:	e8 77 ff ff ff       	call   f01060e4 <memmove>
}
f010616d:	c9                   	leave  
f010616e:	c3                   	ret    

f010616f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010616f:	55                   	push   %ebp
f0106170:	89 e5                	mov    %esp,%ebp
f0106172:	57                   	push   %edi
f0106173:	56                   	push   %esi
f0106174:	53                   	push   %ebx
f0106175:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106178:	8b 75 0c             	mov    0xc(%ebp),%esi
f010617b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010617e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106183:	eb 16                	jmp    f010619b <memcmp+0x2c>
		if (*s1 != *s2)
f0106185:	8a 04 17             	mov    (%edi,%edx,1),%al
f0106188:	42                   	inc    %edx
f0106189:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f010618d:	38 c8                	cmp    %cl,%al
f010618f:	74 0a                	je     f010619b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0106191:	0f b6 c0             	movzbl %al,%eax
f0106194:	0f b6 c9             	movzbl %cl,%ecx
f0106197:	29 c8                	sub    %ecx,%eax
f0106199:	eb 09                	jmp    f01061a4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010619b:	39 da                	cmp    %ebx,%edx
f010619d:	75 e6                	jne    f0106185 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010619f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01061a4:	5b                   	pop    %ebx
f01061a5:	5e                   	pop    %esi
f01061a6:	5f                   	pop    %edi
f01061a7:	5d                   	pop    %ebp
f01061a8:	c3                   	ret    

f01061a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01061a9:	55                   	push   %ebp
f01061aa:	89 e5                	mov    %esp,%ebp
f01061ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01061af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01061b2:	89 c2                	mov    %eax,%edx
f01061b4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01061b7:	eb 05                	jmp    f01061be <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01061b9:	38 08                	cmp    %cl,(%eax)
f01061bb:	74 05                	je     f01061c2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01061bd:	40                   	inc    %eax
f01061be:	39 d0                	cmp    %edx,%eax
f01061c0:	72 f7                	jb     f01061b9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01061c2:	5d                   	pop    %ebp
f01061c3:	c3                   	ret    

f01061c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01061c4:	55                   	push   %ebp
f01061c5:	89 e5                	mov    %esp,%ebp
f01061c7:	57                   	push   %edi
f01061c8:	56                   	push   %esi
f01061c9:	53                   	push   %ebx
f01061ca:	8b 55 08             	mov    0x8(%ebp),%edx
f01061cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01061d0:	eb 01                	jmp    f01061d3 <strtol+0xf>
		s++;
f01061d2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01061d3:	8a 02                	mov    (%edx),%al
f01061d5:	3c 20                	cmp    $0x20,%al
f01061d7:	74 f9                	je     f01061d2 <strtol+0xe>
f01061d9:	3c 09                	cmp    $0x9,%al
f01061db:	74 f5                	je     f01061d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01061dd:	3c 2b                	cmp    $0x2b,%al
f01061df:	75 08                	jne    f01061e9 <strtol+0x25>
		s++;
f01061e1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01061e2:	bf 00 00 00 00       	mov    $0x0,%edi
f01061e7:	eb 13                	jmp    f01061fc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01061e9:	3c 2d                	cmp    $0x2d,%al
f01061eb:	75 0a                	jne    f01061f7 <strtol+0x33>
		s++, neg = 1;
f01061ed:	8d 52 01             	lea    0x1(%edx),%edx
f01061f0:	bf 01 00 00 00       	mov    $0x1,%edi
f01061f5:	eb 05                	jmp    f01061fc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01061f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01061fc:	85 db                	test   %ebx,%ebx
f01061fe:	74 05                	je     f0106205 <strtol+0x41>
f0106200:	83 fb 10             	cmp    $0x10,%ebx
f0106203:	75 28                	jne    f010622d <strtol+0x69>
f0106205:	8a 02                	mov    (%edx),%al
f0106207:	3c 30                	cmp    $0x30,%al
f0106209:	75 10                	jne    f010621b <strtol+0x57>
f010620b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010620f:	75 0a                	jne    f010621b <strtol+0x57>
		s += 2, base = 16;
f0106211:	83 c2 02             	add    $0x2,%edx
f0106214:	bb 10 00 00 00       	mov    $0x10,%ebx
f0106219:	eb 12                	jmp    f010622d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010621b:	85 db                	test   %ebx,%ebx
f010621d:	75 0e                	jne    f010622d <strtol+0x69>
f010621f:	3c 30                	cmp    $0x30,%al
f0106221:	75 05                	jne    f0106228 <strtol+0x64>
		s++, base = 8;
f0106223:	42                   	inc    %edx
f0106224:	b3 08                	mov    $0x8,%bl
f0106226:	eb 05                	jmp    f010622d <strtol+0x69>
	else if (base == 0)
		base = 10;
f0106228:	bb 0a 00 00 00       	mov    $0xa,%ebx
f010622d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106232:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106234:	8a 0a                	mov    (%edx),%cl
f0106236:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106239:	80 fb 09             	cmp    $0x9,%bl
f010623c:	77 08                	ja     f0106246 <strtol+0x82>
			dig = *s - '0';
f010623e:	0f be c9             	movsbl %cl,%ecx
f0106241:	83 e9 30             	sub    $0x30,%ecx
f0106244:	eb 1e                	jmp    f0106264 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0106246:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0106249:	80 fb 19             	cmp    $0x19,%bl
f010624c:	77 08                	ja     f0106256 <strtol+0x92>
			dig = *s - 'a' + 10;
f010624e:	0f be c9             	movsbl %cl,%ecx
f0106251:	83 e9 57             	sub    $0x57,%ecx
f0106254:	eb 0e                	jmp    f0106264 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0106256:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0106259:	80 fb 19             	cmp    $0x19,%bl
f010625c:	77 12                	ja     f0106270 <strtol+0xac>
			dig = *s - 'A' + 10;
f010625e:	0f be c9             	movsbl %cl,%ecx
f0106261:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106264:	39 f1                	cmp    %esi,%ecx
f0106266:	7d 0c                	jge    f0106274 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0106268:	42                   	inc    %edx
f0106269:	0f af c6             	imul   %esi,%eax
f010626c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010626e:	eb c4                	jmp    f0106234 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106270:	89 c1                	mov    %eax,%ecx
f0106272:	eb 02                	jmp    f0106276 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106274:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0106276:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010627a:	74 05                	je     f0106281 <strtol+0xbd>
		*endptr = (char *) s;
f010627c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010627f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106281:	85 ff                	test   %edi,%edi
f0106283:	74 04                	je     f0106289 <strtol+0xc5>
f0106285:	89 c8                	mov    %ecx,%eax
f0106287:	f7 d8                	neg    %eax
}
f0106289:	5b                   	pop    %ebx
f010628a:	5e                   	pop    %esi
f010628b:	5f                   	pop    %edi
f010628c:	5d                   	pop    %ebp
f010628d:	c3                   	ret    
	...

f0106290 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106290:	fa                   	cli    

	xorw    %ax, %ax
f0106291:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106293:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106295:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106297:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106299:	0f 01 16             	lgdtl  (%esi)
f010629c:	74 70                	je     f010630e <sum+0x2>
	movl    %cr0, %eax
f010629e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01062a1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01062a5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01062a8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01062ae:	08 00                	or     %al,(%eax)

f01062b0 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01062b0:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01062b4:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01062b6:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01062b8:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01062ba:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01062be:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01062c0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01062c2:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f01062c7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01062ca:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01062cd:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01062d2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01062d5:	8b 25 84 0e 1f f0    	mov    0xf01f0e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01062db:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01062e0:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01062e5:	ff d0                	call   *%eax

f01062e7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01062e7:	eb fe                	jmp    f01062e7 <spin>
f01062e9:	8d 76 00             	lea    0x0(%esi),%esi

f01062ec <gdt>:
	...
f01062f4:	ff                   	(bad)  
f01062f5:	ff 00                	incl   (%eax)
f01062f7:	00 00                	add    %al,(%eax)
f01062f9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106300:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106304 <gdtdesc>:
f0106304:	17                   	pop    %ss
f0106305:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010630a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010630a:	90                   	nop
	...

f010630c <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f010630c:	55                   	push   %ebp
f010630d:	89 e5                	mov    %esp,%ebp
f010630f:	56                   	push   %esi
f0106310:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106311:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0106316:	b9 00 00 00 00       	mov    $0x0,%ecx
f010631b:	eb 07                	jmp    f0106324 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f010631d:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106321:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106323:	41                   	inc    %ecx
f0106324:	39 d1                	cmp    %edx,%ecx
f0106326:	7c f5                	jl     f010631d <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106328:	88 d8                	mov    %bl,%al
f010632a:	5b                   	pop    %ebx
f010632b:	5e                   	pop    %esi
f010632c:	5d                   	pop    %ebp
f010632d:	c3                   	ret    

f010632e <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010632e:	55                   	push   %ebp
f010632f:	89 e5                	mov    %esp,%ebp
f0106331:	56                   	push   %esi
f0106332:	53                   	push   %ebx
f0106333:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106336:	8b 0d 88 0e 1f f0    	mov    0xf01f0e88,%ecx
f010633c:	89 c3                	mov    %eax,%ebx
f010633e:	c1 eb 0c             	shr    $0xc,%ebx
f0106341:	39 cb                	cmp    %ecx,%ebx
f0106343:	72 20                	jb     f0106365 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106345:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106349:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f0106350:	f0 
f0106351:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106358:	00 
f0106359:	c7 04 24 dd 8c 10 f0 	movl   $0xf0108cdd,(%esp)
f0106360:	e8 db 9c ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106365:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106368:	89 f2                	mov    %esi,%edx
f010636a:	c1 ea 0c             	shr    $0xc,%edx
f010636d:	39 d1                	cmp    %edx,%ecx
f010636f:	77 20                	ja     f0106391 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106371:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106375:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f010637c:	f0 
f010637d:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106384:	00 
f0106385:	c7 04 24 dd 8c 10 f0 	movl   $0xf0108cdd,(%esp)
f010638c:	e8 af 9c ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106391:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0106397:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f010639d:	eb 2f                	jmp    f01063ce <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010639f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01063a6:	00 
f01063a7:	c7 44 24 04 ed 8c 10 	movl   $0xf0108ced,0x4(%esp)
f01063ae:	f0 
f01063af:	89 1c 24             	mov    %ebx,(%esp)
f01063b2:	e8 b8 fd ff ff       	call   f010616f <memcmp>
f01063b7:	85 c0                	test   %eax,%eax
f01063b9:	75 10                	jne    f01063cb <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f01063bb:	ba 10 00 00 00       	mov    $0x10,%edx
f01063c0:	89 d8                	mov    %ebx,%eax
f01063c2:	e8 45 ff ff ff       	call   f010630c <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01063c7:	84 c0                	test   %al,%al
f01063c9:	74 0c                	je     f01063d7 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01063cb:	83 c3 10             	add    $0x10,%ebx
f01063ce:	39 f3                	cmp    %esi,%ebx
f01063d0:	72 cd                	jb     f010639f <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01063d2:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01063d7:	89 d8                	mov    %ebx,%eax
f01063d9:	83 c4 10             	add    $0x10,%esp
f01063dc:	5b                   	pop    %ebx
f01063dd:	5e                   	pop    %esi
f01063de:	5d                   	pop    %ebp
f01063df:	c3                   	ret    

f01063e0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01063e0:	55                   	push   %ebp
f01063e1:	89 e5                	mov    %esp,%ebp
f01063e3:	57                   	push   %edi
f01063e4:	56                   	push   %esi
f01063e5:	53                   	push   %ebx
f01063e6:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01063e9:	c7 05 c0 13 1f f0 20 	movl   $0xf01f1020,0xf01f13c0
f01063f0:	10 1f f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01063f3:	83 3d 88 0e 1f f0 00 	cmpl   $0x0,0xf01f0e88
f01063fa:	75 24                	jne    f0106420 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063fc:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106403:	00 
f0106404:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f010640b:	f0 
f010640c:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106413:	00 
f0106414:	c7 04 24 dd 8c 10 f0 	movl   $0xf0108cdd,(%esp)
f010641b:	e8 20 9c ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106420:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106427:	85 c0                	test   %eax,%eax
f0106429:	74 16                	je     f0106441 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010642b:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010642e:	ba 00 04 00 00       	mov    $0x400,%edx
f0106433:	e8 f6 fe ff ff       	call   f010632e <mpsearch1>
f0106438:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010643b:	85 c0                	test   %eax,%eax
f010643d:	75 3c                	jne    f010647b <mp_init+0x9b>
f010643f:	eb 20                	jmp    f0106461 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106441:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106448:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010644b:	2d 00 04 00 00       	sub    $0x400,%eax
f0106450:	ba 00 04 00 00       	mov    $0x400,%edx
f0106455:	e8 d4 fe ff ff       	call   f010632e <mpsearch1>
f010645a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010645d:	85 c0                	test   %eax,%eax
f010645f:	75 1a                	jne    f010647b <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106461:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106466:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010646b:	e8 be fe ff ff       	call   f010632e <mpsearch1>
f0106470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106473:	85 c0                	test   %eax,%eax
f0106475:	0f 84 2c 02 00 00    	je     f01066a7 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010647b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010647e:	8b 58 04             	mov    0x4(%eax),%ebx
f0106481:	85 db                	test   %ebx,%ebx
f0106483:	74 06                	je     f010648b <mp_init+0xab>
f0106485:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106489:	74 11                	je     f010649c <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010648b:	c7 04 24 50 8b 10 f0 	movl   $0xf0108b50,(%esp)
f0106492:	e8 8f da ff ff       	call   f0103f26 <cprintf>
f0106497:	e9 0b 02 00 00       	jmp    f01066a7 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010649c:	89 d8                	mov    %ebx,%eax
f010649e:	c1 e8 0c             	shr    $0xc,%eax
f01064a1:	3b 05 88 0e 1f f0    	cmp    0xf01f0e88,%eax
f01064a7:	72 20                	jb     f01064c9 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01064ad:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f01064b4:	f0 
f01064b5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01064bc:	00 
f01064bd:	c7 04 24 dd 8c 10 f0 	movl   $0xf0108cdd,(%esp)
f01064c4:	e8 77 9b ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01064c9:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01064cf:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01064d6:	00 
f01064d7:	c7 44 24 04 f2 8c 10 	movl   $0xf0108cf2,0x4(%esp)
f01064de:	f0 
f01064df:	89 1c 24             	mov    %ebx,(%esp)
f01064e2:	e8 88 fc ff ff       	call   f010616f <memcmp>
f01064e7:	85 c0                	test   %eax,%eax
f01064e9:	74 11                	je     f01064fc <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01064eb:	c7 04 24 80 8b 10 f0 	movl   $0xf0108b80,(%esp)
f01064f2:	e8 2f da ff ff       	call   f0103f26 <cprintf>
f01064f7:	e9 ab 01 00 00       	jmp    f01066a7 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01064fc:	66 8b 73 04          	mov    0x4(%ebx),%si
f0106500:	0f b7 d6             	movzwl %si,%edx
f0106503:	89 d8                	mov    %ebx,%eax
f0106505:	e8 02 fe ff ff       	call   f010630c <sum>
f010650a:	84 c0                	test   %al,%al
f010650c:	74 11                	je     f010651f <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010650e:	c7 04 24 b4 8b 10 f0 	movl   $0xf0108bb4,(%esp)
f0106515:	e8 0c da ff ff       	call   f0103f26 <cprintf>
f010651a:	e9 88 01 00 00       	jmp    f01066a7 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010651f:	8a 43 06             	mov    0x6(%ebx),%al
f0106522:	3c 01                	cmp    $0x1,%al
f0106524:	74 1c                	je     f0106542 <mp_init+0x162>
f0106526:	3c 04                	cmp    $0x4,%al
f0106528:	74 18                	je     f0106542 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010652a:	0f b6 c0             	movzbl %al,%eax
f010652d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106531:	c7 04 24 d8 8b 10 f0 	movl   $0xf0108bd8,(%esp)
f0106538:	e8 e9 d9 ff ff       	call   f0103f26 <cprintf>
f010653d:	e9 65 01 00 00       	jmp    f01066a7 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106542:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0106546:	0f b7 c6             	movzwl %si,%eax
f0106549:	01 d8                	add    %ebx,%eax
f010654b:	e8 bc fd ff ff       	call   f010630c <sum>
f0106550:	02 43 2a             	add    0x2a(%ebx),%al
f0106553:	84 c0                	test   %al,%al
f0106555:	74 11                	je     f0106568 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106557:	c7 04 24 f8 8b 10 f0 	movl   $0xf0108bf8,(%esp)
f010655e:	e8 c3 d9 ff ff       	call   f0103f26 <cprintf>
f0106563:	e9 3f 01 00 00       	jmp    f01066a7 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106568:	85 db                	test   %ebx,%ebx
f010656a:	0f 84 37 01 00 00    	je     f01066a7 <mp_init+0x2c7>
		return;
	ismp = 1;
f0106570:	c7 05 00 10 1f f0 01 	movl   $0x1,0xf01f1000
f0106577:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010657a:	8b 43 24             	mov    0x24(%ebx),%eax
f010657d:	a3 00 20 23 f0       	mov    %eax,0xf0232000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106582:	8d 73 2c             	lea    0x2c(%ebx),%esi
f0106585:	bf 00 00 00 00       	mov    $0x0,%edi
f010658a:	e9 94 00 00 00       	jmp    f0106623 <mp_init+0x243>
		switch (*p) {
f010658f:	8a 06                	mov    (%esi),%al
f0106591:	84 c0                	test   %al,%al
f0106593:	74 06                	je     f010659b <mp_init+0x1bb>
f0106595:	3c 04                	cmp    $0x4,%al
f0106597:	77 68                	ja     f0106601 <mp_init+0x221>
f0106599:	eb 61                	jmp    f01065fc <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010659b:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f010659f:	74 1d                	je     f01065be <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f01065a1:	a1 c4 13 1f f0       	mov    0xf01f13c4,%eax
f01065a6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065ad:	29 c2                	sub    %eax,%edx
f01065af:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01065b2:	8d 04 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%eax
f01065b9:	a3 c0 13 1f f0       	mov    %eax,0xf01f13c0
			if (ncpu < NCPU) {
f01065be:	a1 c4 13 1f f0       	mov    0xf01f13c4,%eax
f01065c3:	83 f8 07             	cmp    $0x7,%eax
f01065c6:	7f 1b                	jg     f01065e3 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f01065c8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065cf:	29 c2                	sub    %eax,%edx
f01065d1:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01065d4:	88 04 95 20 10 1f f0 	mov    %al,-0xfe0efe0(,%edx,4)
				ncpu++;
f01065db:	40                   	inc    %eax
f01065dc:	a3 c4 13 1f f0       	mov    %eax,0xf01f13c4
f01065e1:	eb 14                	jmp    f01065f7 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01065e3:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01065e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065eb:	c7 04 24 28 8c 10 f0 	movl   $0xf0108c28,(%esp)
f01065f2:	e8 2f d9 ff ff       	call   f0103f26 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01065f7:	83 c6 14             	add    $0x14,%esi
			continue;
f01065fa:	eb 26                	jmp    f0106622 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01065fc:	83 c6 08             	add    $0x8,%esi
			continue;
f01065ff:	eb 21                	jmp    f0106622 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106601:	0f b6 c0             	movzbl %al,%eax
f0106604:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106608:	c7 04 24 50 8c 10 f0 	movl   $0xf0108c50,(%esp)
f010660f:	e8 12 d9 ff ff       	call   f0103f26 <cprintf>
			ismp = 0;
f0106614:	c7 05 00 10 1f f0 00 	movl   $0x0,0xf01f1000
f010661b:	00 00 00 
			i = conf->entry;
f010661e:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106622:	47                   	inc    %edi
f0106623:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106627:	39 c7                	cmp    %eax,%edi
f0106629:	0f 82 60 ff ff ff    	jb     f010658f <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010662f:	a1 c0 13 1f f0       	mov    0xf01f13c0,%eax
f0106634:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010663b:	83 3d 00 10 1f f0 00 	cmpl   $0x0,0xf01f1000
f0106642:	75 22                	jne    f0106666 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106644:	c7 05 c4 13 1f f0 01 	movl   $0x1,0xf01f13c4
f010664b:	00 00 00 
		lapicaddr = 0;
f010664e:	c7 05 00 20 23 f0 00 	movl   $0x0,0xf0232000
f0106655:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106658:	c7 04 24 70 8c 10 f0 	movl   $0xf0108c70,(%esp)
f010665f:	e8 c2 d8 ff ff       	call   f0103f26 <cprintf>
		return;
f0106664:	eb 41                	jmp    f01066a7 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106666:	8b 15 c4 13 1f f0    	mov    0xf01f13c4,%edx
f010666c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106670:	0f b6 00             	movzbl (%eax),%eax
f0106673:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106677:	c7 04 24 f7 8c 10 f0 	movl   $0xf0108cf7,(%esp)
f010667e:	e8 a3 d8 ff ff       	call   f0103f26 <cprintf>

	if (mp->imcrp) {
f0106683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106686:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010668a:	74 1b                	je     f01066a7 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010668c:	c7 04 24 9c 8c 10 f0 	movl   $0xf0108c9c,(%esp)
f0106693:	e8 8e d8 ff ff       	call   f0103f26 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106698:	ba 22 00 00 00       	mov    $0x22,%edx
f010669d:	b0 70                	mov    $0x70,%al
f010669f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01066a0:	b2 23                	mov    $0x23,%dl
f01066a2:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01066a3:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01066a6:	ee                   	out    %al,(%dx)
	}
}
f01066a7:	83 c4 2c             	add    $0x2c,%esp
f01066aa:	5b                   	pop    %ebx
f01066ab:	5e                   	pop    %esi
f01066ac:	5f                   	pop    %edi
f01066ad:	5d                   	pop    %ebp
f01066ae:	c3                   	ret    
	...

f01066b0 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01066b0:	55                   	push   %ebp
f01066b1:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01066b3:	c1 e0 02             	shl    $0x2,%eax
f01066b6:	03 05 04 20 23 f0    	add    0xf0232004,%eax
f01066bc:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01066be:	a1 04 20 23 f0       	mov    0xf0232004,%eax
f01066c3:	8b 40 20             	mov    0x20(%eax),%eax
}
f01066c6:	5d                   	pop    %ebp
f01066c7:	c3                   	ret    

f01066c8 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01066c8:	55                   	push   %ebp
f01066c9:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01066cb:	a1 04 20 23 f0       	mov    0xf0232004,%eax
f01066d0:	85 c0                	test   %eax,%eax
f01066d2:	74 08                	je     f01066dc <cpunum+0x14>
	  return lapic[ID] >> 24;
f01066d4:	8b 40 20             	mov    0x20(%eax),%eax
f01066d7:	c1 e8 18             	shr    $0x18,%eax
f01066da:	eb 05                	jmp    f01066e1 <cpunum+0x19>
	return 0;
f01066dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01066e1:	5d                   	pop    %ebp
f01066e2:	c3                   	ret    

f01066e3 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01066e3:	55                   	push   %ebp
f01066e4:	89 e5                	mov    %esp,%ebp
f01066e6:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01066e9:	a1 00 20 23 f0       	mov    0xf0232000,%eax
f01066ee:	85 c0                	test   %eax,%eax
f01066f0:	0f 84 27 01 00 00    	je     f010681d <lapic_init+0x13a>
	  return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01066f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01066fd:	00 
f01066fe:	89 04 24             	mov    %eax,(%esp)
f0106701:	e8 d9 ac ff ff       	call   f01013df <mmio_map_region>
f0106706:	a3 04 20 23 f0       	mov    %eax,0xf0232004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010670b:	ba 27 01 00 00       	mov    $0x127,%edx
f0106710:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106715:	e8 96 ff ff ff       	call   f01066b0 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010671a:	ba 0b 00 00 00       	mov    $0xb,%edx
f010671f:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106724:	e8 87 ff ff ff       	call   f01066b0 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106729:	ba 20 00 02 00       	mov    $0x20020,%edx
f010672e:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106733:	e8 78 ff ff ff       	call   f01066b0 <lapicw>
	lapicw(TICR, 10000000); 
f0106738:	ba 80 96 98 00       	mov    $0x989680,%edx
f010673d:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106742:	e8 69 ff ff ff       	call   f01066b0 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106747:	e8 7c ff ff ff       	call   f01066c8 <cpunum>
f010674c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106753:	29 c2                	sub    %eax,%edx
f0106755:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106758:	8d 04 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%eax
f010675f:	39 05 c0 13 1f f0    	cmp    %eax,0xf01f13c0
f0106765:	74 0f                	je     f0106776 <lapic_init+0x93>
	  lapicw(LINT0, MASKED);
f0106767:	ba 00 00 01 00       	mov    $0x10000,%edx
f010676c:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106771:	e8 3a ff ff ff       	call   f01066b0 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106776:	ba 00 00 01 00       	mov    $0x10000,%edx
f010677b:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106780:	e8 2b ff ff ff       	call   f01066b0 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106785:	a1 04 20 23 f0       	mov    0xf0232004,%eax
f010678a:	8b 40 30             	mov    0x30(%eax),%eax
f010678d:	c1 e8 10             	shr    $0x10,%eax
f0106790:	3c 03                	cmp    $0x3,%al
f0106792:	76 0f                	jbe    f01067a3 <lapic_init+0xc0>
	  lapicw(PCINT, MASKED);
f0106794:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106799:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010679e:	e8 0d ff ff ff       	call   f01066b0 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01067a3:	ba 33 00 00 00       	mov    $0x33,%edx
f01067a8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01067ad:	e8 fe fe ff ff       	call   f01066b0 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01067b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01067b7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01067bc:	e8 ef fe ff ff       	call   f01066b0 <lapicw>
	lapicw(ESR, 0);
f01067c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01067c6:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01067cb:	e8 e0 fe ff ff       	call   f01066b0 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01067d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01067d5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01067da:	e8 d1 fe ff ff       	call   f01066b0 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01067df:	ba 00 00 00 00       	mov    $0x0,%edx
f01067e4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067e9:	e8 c2 fe ff ff       	call   f01066b0 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01067ee:	ba 00 85 08 00       	mov    $0x88500,%edx
f01067f3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067f8:	e8 b3 fe ff ff       	call   f01066b0 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01067fd:	8b 15 04 20 23 f0    	mov    0xf0232004,%edx
f0106803:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106809:	f6 c4 10             	test   $0x10,%ah
f010680c:	75 f5                	jne    f0106803 <lapic_init+0x120>
	  ;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010680e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106813:	b8 20 00 00 00       	mov    $0x20,%eax
f0106818:	e8 93 fe ff ff       	call   f01066b0 <lapicw>
}
f010681d:	c9                   	leave  
f010681e:	c3                   	ret    

f010681f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010681f:	55                   	push   %ebp
f0106820:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106822:	83 3d 04 20 23 f0 00 	cmpl   $0x0,0xf0232004
f0106829:	74 0f                	je     f010683a <lapic_eoi+0x1b>
	  lapicw(EOI, 0);
f010682b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106830:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106835:	e8 76 fe ff ff       	call   f01066b0 <lapicw>
}
f010683a:	5d                   	pop    %ebp
f010683b:	c3                   	ret    

f010683c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010683c:	55                   	push   %ebp
f010683d:	89 e5                	mov    %esp,%ebp
f010683f:	56                   	push   %esi
f0106840:	53                   	push   %ebx
f0106841:	83 ec 10             	sub    $0x10,%esp
f0106844:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106847:	8a 5d 08             	mov    0x8(%ebp),%bl
f010684a:	ba 70 00 00 00       	mov    $0x70,%edx
f010684f:	b0 0f                	mov    $0xf,%al
f0106851:	ee                   	out    %al,(%dx)
f0106852:	b2 71                	mov    $0x71,%dl
f0106854:	b0 0a                	mov    $0xa,%al
f0106856:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106857:	83 3d 88 0e 1f f0 00 	cmpl   $0x0,0xf01f0e88
f010685e:	75 24                	jne    f0106884 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106860:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106867:	00 
f0106868:	c7 44 24 08 e8 6d 10 	movl   $0xf0106de8,0x8(%esp)
f010686f:	f0 
f0106870:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106877:	00 
f0106878:	c7 04 24 14 8d 10 f0 	movl   $0xf0108d14,(%esp)
f010687f:	e8 bc 97 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106884:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010688b:	00 00 
	wrv[1] = addr >> 4;
f010688d:	89 f0                	mov    %esi,%eax
f010688f:	c1 e8 04             	shr    $0x4,%eax
f0106892:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106898:	c1 e3 18             	shl    $0x18,%ebx
f010689b:	89 da                	mov    %ebx,%edx
f010689d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068a2:	e8 09 fe ff ff       	call   f01066b0 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01068a7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01068ac:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068b1:	e8 fa fd ff ff       	call   f01066b0 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01068b6:	ba 00 85 00 00       	mov    $0x8500,%edx
f01068bb:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068c0:	e8 eb fd ff ff       	call   f01066b0 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01068c5:	c1 ee 0c             	shr    $0xc,%esi
f01068c8:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01068ce:	89 da                	mov    %ebx,%edx
f01068d0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068d5:	e8 d6 fd ff ff       	call   f01066b0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01068da:	89 f2                	mov    %esi,%edx
f01068dc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068e1:	e8 ca fd ff ff       	call   f01066b0 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01068e6:	89 da                	mov    %ebx,%edx
f01068e8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01068ed:	e8 be fd ff ff       	call   f01066b0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01068f2:	89 f2                	mov    %esi,%edx
f01068f4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01068f9:	e8 b2 fd ff ff       	call   f01066b0 <lapicw>
		microdelay(200);
	}
}
f01068fe:	83 c4 10             	add    $0x10,%esp
f0106901:	5b                   	pop    %ebx
f0106902:	5e                   	pop    %esi
f0106903:	5d                   	pop    %ebp
f0106904:	c3                   	ret    

f0106905 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106905:	55                   	push   %ebp
f0106906:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106908:	8b 55 08             	mov    0x8(%ebp),%edx
f010690b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106911:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106916:	e8 95 fd ff ff       	call   f01066b0 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010691b:	8b 15 04 20 23 f0    	mov    0xf0232004,%edx
f0106921:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106927:	f6 c4 10             	test   $0x10,%ah
f010692a:	75 f5                	jne    f0106921 <lapic_ipi+0x1c>
	  ;
}
f010692c:	5d                   	pop    %ebp
f010692d:	c3                   	ret    
	...

f0106930 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106930:	55                   	push   %ebp
f0106931:	89 e5                	mov    %esp,%ebp
f0106933:	53                   	push   %ebx
f0106934:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106937:	83 38 00             	cmpl   $0x0,(%eax)
f010693a:	74 25                	je     f0106961 <holding+0x31>
f010693c:	8b 58 08             	mov    0x8(%eax),%ebx
f010693f:	e8 84 fd ff ff       	call   f01066c8 <cpunum>
f0106944:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010694b:	29 c2                	sub    %eax,%edx
f010694d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106950:	8d 04 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106957:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106959:	0f 94 c0             	sete   %al
f010695c:	0f b6 c0             	movzbl %al,%eax
f010695f:	eb 05                	jmp    f0106966 <holding+0x36>
f0106961:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106966:	83 c4 04             	add    $0x4,%esp
f0106969:	5b                   	pop    %ebx
f010696a:	5d                   	pop    %ebp
f010696b:	c3                   	ret    

f010696c <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010696c:	55                   	push   %ebp
f010696d:	89 e5                	mov    %esp,%ebp
f010696f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106972:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106978:	8b 55 0c             	mov    0xc(%ebp),%edx
f010697b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010697e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106985:	5d                   	pop    %ebp
f0106986:	c3                   	ret    

f0106987 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106987:	55                   	push   %ebp
f0106988:	89 e5                	mov    %esp,%ebp
f010698a:	53                   	push   %ebx
f010698b:	83 ec 24             	sub    $0x24,%esp
f010698e:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106991:	89 d8                	mov    %ebx,%eax
f0106993:	e8 98 ff ff ff       	call   f0106930 <holding>
f0106998:	85 c0                	test   %eax,%eax
f010699a:	74 30                	je     f01069cc <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010699c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010699f:	e8 24 fd ff ff       	call   f01066c8 <cpunum>
f01069a4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01069a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01069ac:	c7 44 24 08 24 8d 10 	movl   $0xf0108d24,0x8(%esp)
f01069b3:	f0 
f01069b4:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01069bb:	00 
f01069bc:	c7 04 24 88 8d 10 f0 	movl   $0xf0108d88,(%esp)
f01069c3:	e8 78 96 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01069c8:	f3 90                	pause  
f01069ca:	eb 05                	jmp    f01069d1 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01069cc:	ba 01 00 00 00       	mov    $0x1,%edx
f01069d1:	89 d0                	mov    %edx,%eax
f01069d3:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01069d6:	85 c0                	test   %eax,%eax
f01069d8:	75 ee                	jne    f01069c8 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01069da:	e8 e9 fc ff ff       	call   f01066c8 <cpunum>
f01069df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01069e6:	29 c2                	sub    %eax,%edx
f01069e8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069eb:	8d 04 85 20 10 1f f0 	lea    -0xfe0efe0(,%eax,4),%eax
f01069f2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01069f5:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01069f8:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01069fa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01069ff:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106a05:	76 10                	jbe    f0106a17 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106a07:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106a0a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106a0d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106a0f:	40                   	inc    %eax
f0106a10:	83 f8 0a             	cmp    $0xa,%eax
f0106a13:	75 ea                	jne    f01069ff <spin_lock+0x78>
f0106a15:	eb 0d                	jmp    f0106a24 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106a17:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106a1e:	40                   	inc    %eax
f0106a1f:	83 f8 09             	cmp    $0x9,%eax
f0106a22:	7e f3                	jle    f0106a17 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106a24:	83 c4 24             	add    $0x24,%esp
f0106a27:	5b                   	pop    %ebx
f0106a28:	5d                   	pop    %ebp
f0106a29:	c3                   	ret    

f0106a2a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106a2a:	55                   	push   %ebp
f0106a2b:	89 e5                	mov    %esp,%ebp
f0106a2d:	57                   	push   %edi
f0106a2e:	56                   	push   %esi
f0106a2f:	53                   	push   %ebx
f0106a30:	83 ec 7c             	sub    $0x7c,%esp
f0106a33:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106a36:	89 d8                	mov    %ebx,%eax
f0106a38:	e8 f3 fe ff ff       	call   f0106930 <holding>
f0106a3d:	85 c0                	test   %eax,%eax
f0106a3f:	0f 85 d3 00 00 00    	jne    f0106b18 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106a45:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106a4c:	00 
f0106a4d:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106a50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a54:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106a57:	89 34 24             	mov    %esi,(%esp)
f0106a5a:	e8 85 f6 ff ff       	call   f01060e4 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106a5f:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106a62:	0f b6 38             	movzbl (%eax),%edi
f0106a65:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106a68:	e8 5b fc ff ff       	call   f01066c8 <cpunum>
f0106a6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a71:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106a75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a79:	c7 04 24 50 8d 10 f0 	movl   $0xf0108d50,(%esp)
f0106a80:	e8 a1 d4 ff ff       	call   f0103f26 <cprintf>
f0106a85:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106a87:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106a8a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106a8d:	89 c7                	mov    %eax,%edi
f0106a8f:	eb 63                	jmp    f0106af4 <spin_unlock+0xca>
f0106a91:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106a95:	89 04 24             	mov    %eax,(%esp)
f0106a98:	e8 2c eb ff ff       	call   f01055c9 <debuginfo_eip>
f0106a9d:	85 c0                	test   %eax,%eax
f0106a9f:	78 39                	js     f0106ada <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106aa1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106aa3:	89 c2                	mov    %eax,%edx
f0106aa5:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106aa8:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106aac:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106aaf:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106ab3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106ab6:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106aba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106abd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106ac1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106ac4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106acc:	c7 04 24 98 8d 10 f0 	movl   $0xf0108d98,(%esp)
f0106ad3:	e8 4e d4 ff ff       	call   f0103f26 <cprintf>
f0106ad8:	eb 12                	jmp    f0106aec <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106ada:	8b 06                	mov    (%esi),%eax
f0106adc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ae0:	c7 04 24 af 8d 10 f0 	movl   $0xf0108daf,(%esp)
f0106ae7:	e8 3a d4 ff ff       	call   f0103f26 <cprintf>
f0106aec:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106aef:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106af2:	74 08                	je     f0106afc <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106af4:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106af6:	8b 03                	mov    (%ebx),%eax
f0106af8:	85 c0                	test   %eax,%eax
f0106afa:	75 95                	jne    f0106a91 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106afc:	c7 44 24 08 b7 8d 10 	movl   $0xf0108db7,0x8(%esp)
f0106b03:	f0 
f0106b04:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106b0b:	00 
f0106b0c:	c7 04 24 88 8d 10 f0 	movl   $0xf0108d88,(%esp)
f0106b13:	e8 28 95 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106b18:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106b1f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106b26:	b8 00 00 00 00       	mov    $0x0,%eax
f0106b2b:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106b2e:	83 c4 7c             	add    $0x7c,%esp
f0106b31:	5b                   	pop    %ebx
f0106b32:	5e                   	pop    %esi
f0106b33:	5f                   	pop    %edi
f0106b34:	5d                   	pop    %ebp
f0106b35:	c3                   	ret    
	...

f0106b38 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0106b38:	55                   	push   %ebp
f0106b39:	57                   	push   %edi
f0106b3a:	56                   	push   %esi
f0106b3b:	83 ec 10             	sub    $0x10,%esp
f0106b3e:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106b42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106b46:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106b4a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0106b4e:	89 cd                	mov    %ecx,%ebp
f0106b50:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106b54:	85 c0                	test   %eax,%eax
f0106b56:	75 2c                	jne    f0106b84 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0106b58:	39 f9                	cmp    %edi,%ecx
f0106b5a:	77 68                	ja     f0106bc4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106b5c:	85 c9                	test   %ecx,%ecx
f0106b5e:	75 0b                	jne    f0106b6b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106b60:	b8 01 00 00 00       	mov    $0x1,%eax
f0106b65:	31 d2                	xor    %edx,%edx
f0106b67:	f7 f1                	div    %ecx
f0106b69:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106b6b:	31 d2                	xor    %edx,%edx
f0106b6d:	89 f8                	mov    %edi,%eax
f0106b6f:	f7 f1                	div    %ecx
f0106b71:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106b73:	89 f0                	mov    %esi,%eax
f0106b75:	f7 f1                	div    %ecx
f0106b77:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106b79:	89 f0                	mov    %esi,%eax
f0106b7b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106b7d:	83 c4 10             	add    $0x10,%esp
f0106b80:	5e                   	pop    %esi
f0106b81:	5f                   	pop    %edi
f0106b82:	5d                   	pop    %ebp
f0106b83:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106b84:	39 f8                	cmp    %edi,%eax
f0106b86:	77 2c                	ja     f0106bb4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106b88:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0106b8b:	83 f6 1f             	xor    $0x1f,%esi
f0106b8e:	75 4c                	jne    f0106bdc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106b90:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106b92:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106b97:	72 0a                	jb     f0106ba3 <__udivdi3+0x6b>
f0106b99:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106b9d:	0f 87 ad 00 00 00    	ja     f0106c50 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106ba3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106ba8:	89 f0                	mov    %esi,%eax
f0106baa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106bac:	83 c4 10             	add    $0x10,%esp
f0106baf:	5e                   	pop    %esi
f0106bb0:	5f                   	pop    %edi
f0106bb1:	5d                   	pop    %ebp
f0106bb2:	c3                   	ret    
f0106bb3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106bb4:	31 ff                	xor    %edi,%edi
f0106bb6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106bb8:	89 f0                	mov    %esi,%eax
f0106bba:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106bbc:	83 c4 10             	add    $0x10,%esp
f0106bbf:	5e                   	pop    %esi
f0106bc0:	5f                   	pop    %edi
f0106bc1:	5d                   	pop    %ebp
f0106bc2:	c3                   	ret    
f0106bc3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106bc4:	89 fa                	mov    %edi,%edx
f0106bc6:	89 f0                	mov    %esi,%eax
f0106bc8:	f7 f1                	div    %ecx
f0106bca:	89 c6                	mov    %eax,%esi
f0106bcc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0106bce:	89 f0                	mov    %esi,%eax
f0106bd0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0106bd2:	83 c4 10             	add    $0x10,%esp
f0106bd5:	5e                   	pop    %esi
f0106bd6:	5f                   	pop    %edi
f0106bd7:	5d                   	pop    %ebp
f0106bd8:	c3                   	ret    
f0106bd9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106bdc:	89 f1                	mov    %esi,%ecx
f0106bde:	d3 e0                	shl    %cl,%eax
f0106be0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106be4:	b8 20 00 00 00       	mov    $0x20,%eax
f0106be9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0106beb:	89 ea                	mov    %ebp,%edx
f0106bed:	88 c1                	mov    %al,%cl
f0106bef:	d3 ea                	shr    %cl,%edx
f0106bf1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106bf5:	09 ca                	or     %ecx,%edx
f0106bf7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0106bfb:	89 f1                	mov    %esi,%ecx
f0106bfd:	d3 e5                	shl    %cl,%ebp
f0106bff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0106c03:	89 fd                	mov    %edi,%ebp
f0106c05:	88 c1                	mov    %al,%cl
f0106c07:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0106c09:	89 fa                	mov    %edi,%edx
f0106c0b:	89 f1                	mov    %esi,%ecx
f0106c0d:	d3 e2                	shl    %cl,%edx
f0106c0f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106c13:	88 c1                	mov    %al,%cl
f0106c15:	d3 ef                	shr    %cl,%edi
f0106c17:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106c19:	89 f8                	mov    %edi,%eax
f0106c1b:	89 ea                	mov    %ebp,%edx
f0106c1d:	f7 74 24 08          	divl   0x8(%esp)
f0106c21:	89 d1                	mov    %edx,%ecx
f0106c23:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f0106c25:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106c29:	39 d1                	cmp    %edx,%ecx
f0106c2b:	72 17                	jb     f0106c44 <__udivdi3+0x10c>
f0106c2d:	74 09                	je     f0106c38 <__udivdi3+0x100>
f0106c2f:	89 fe                	mov    %edi,%esi
f0106c31:	31 ff                	xor    %edi,%edi
f0106c33:	e9 41 ff ff ff       	jmp    f0106b79 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0106c38:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106c3c:	89 f1                	mov    %esi,%ecx
f0106c3e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106c40:	39 c2                	cmp    %eax,%edx
f0106c42:	73 eb                	jae    f0106c2f <__udivdi3+0xf7>
		{
		  q0--;
f0106c44:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106c47:	31 ff                	xor    %edi,%edi
f0106c49:	e9 2b ff ff ff       	jmp    f0106b79 <__udivdi3+0x41>
f0106c4e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106c50:	31 f6                	xor    %esi,%esi
f0106c52:	e9 22 ff ff ff       	jmp    f0106b79 <__udivdi3+0x41>
	...

f0106c58 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0106c58:	55                   	push   %ebp
f0106c59:	57                   	push   %edi
f0106c5a:	56                   	push   %esi
f0106c5b:	83 ec 20             	sub    $0x20,%esp
f0106c5e:	8b 44 24 30          	mov    0x30(%esp),%eax
f0106c62:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0106c66:	89 44 24 14          	mov    %eax,0x14(%esp)
f0106c6a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0106c6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106c72:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0106c76:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0106c78:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0106c7a:	85 ed                	test   %ebp,%ebp
f0106c7c:	75 16                	jne    f0106c94 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0106c7e:	39 f1                	cmp    %esi,%ecx
f0106c80:	0f 86 a6 00 00 00    	jbe    f0106d2c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106c86:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0106c88:	89 d0                	mov    %edx,%eax
f0106c8a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106c8c:	83 c4 20             	add    $0x20,%esp
f0106c8f:	5e                   	pop    %esi
f0106c90:	5f                   	pop    %edi
f0106c91:	5d                   	pop    %ebp
f0106c92:	c3                   	ret    
f0106c93:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0106c94:	39 f5                	cmp    %esi,%ebp
f0106c96:	0f 87 ac 00 00 00    	ja     f0106d48 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0106c9c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0106c9f:	83 f0 1f             	xor    $0x1f,%eax
f0106ca2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0106ca6:	0f 84 a8 00 00 00    	je     f0106d54 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0106cac:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106cb0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0106cb2:	bf 20 00 00 00       	mov    $0x20,%edi
f0106cb7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0106cbb:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106cbf:	89 f9                	mov    %edi,%ecx
f0106cc1:	d3 e8                	shr    %cl,%eax
f0106cc3:	09 e8                	or     %ebp,%eax
f0106cc5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0106cc9:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106ccd:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106cd1:	d3 e0                	shl    %cl,%eax
f0106cd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106cd7:	89 f2                	mov    %esi,%edx
f0106cd9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0106cdb:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106cdf:	d3 e0                	shl    %cl,%eax
f0106ce1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0106ce5:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106ce9:	89 f9                	mov    %edi,%ecx
f0106ceb:	d3 e8                	shr    %cl,%eax
f0106ced:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0106cef:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0106cf1:	89 f2                	mov    %esi,%edx
f0106cf3:	f7 74 24 18          	divl   0x18(%esp)
f0106cf7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0106cf9:	f7 64 24 0c          	mull   0xc(%esp)
f0106cfd:	89 c5                	mov    %eax,%ebp
f0106cff:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106d01:	39 d6                	cmp    %edx,%esi
f0106d03:	72 67                	jb     f0106d6c <__umoddi3+0x114>
f0106d05:	74 75                	je     f0106d7c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0106d07:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106d0b:	29 e8                	sub    %ebp,%eax
f0106d0d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0106d0f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d13:	d3 e8                	shr    %cl,%eax
f0106d15:	89 f2                	mov    %esi,%edx
f0106d17:	89 f9                	mov    %edi,%ecx
f0106d19:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0106d1b:	09 d0                	or     %edx,%eax
f0106d1d:	89 f2                	mov    %esi,%edx
f0106d1f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106d23:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d25:	83 c4 20             	add    $0x20,%esp
f0106d28:	5e                   	pop    %esi
f0106d29:	5f                   	pop    %edi
f0106d2a:	5d                   	pop    %ebp
f0106d2b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0106d2c:	85 c9                	test   %ecx,%ecx
f0106d2e:	75 0b                	jne    f0106d3b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0106d30:	b8 01 00 00 00       	mov    $0x1,%eax
f0106d35:	31 d2                	xor    %edx,%edx
f0106d37:	f7 f1                	div    %ecx
f0106d39:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0106d3b:	89 f0                	mov    %esi,%eax
f0106d3d:	31 d2                	xor    %edx,%edx
f0106d3f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0106d41:	89 f8                	mov    %edi,%eax
f0106d43:	e9 3e ff ff ff       	jmp    f0106c86 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0106d48:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d4a:	83 c4 20             	add    $0x20,%esp
f0106d4d:	5e                   	pop    %esi
f0106d4e:	5f                   	pop    %edi
f0106d4f:	5d                   	pop    %ebp
f0106d50:	c3                   	ret    
f0106d51:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0106d54:	39 f5                	cmp    %esi,%ebp
f0106d56:	72 04                	jb     f0106d5c <__umoddi3+0x104>
f0106d58:	39 f9                	cmp    %edi,%ecx
f0106d5a:	77 06                	ja     f0106d62 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0106d5c:	89 f2                	mov    %esi,%edx
f0106d5e:	29 cf                	sub    %ecx,%edi
f0106d60:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0106d62:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0106d64:	83 c4 20             	add    $0x20,%esp
f0106d67:	5e                   	pop    %esi
f0106d68:	5f                   	pop    %edi
f0106d69:	5d                   	pop    %ebp
f0106d6a:	c3                   	ret    
f0106d6b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0106d6c:	89 d1                	mov    %edx,%ecx
f0106d6e:	89 c5                	mov    %eax,%ebp
f0106d70:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106d74:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106d78:	eb 8d                	jmp    f0106d07 <__umoddi3+0xaf>
f0106d7a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0106d7c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106d80:	72 ea                	jb     f0106d6c <__umoddi3+0x114>
f0106d82:	89 f1                	mov    %esi,%ecx
f0106d84:	eb 81                	jmp    f0106d07 <__umoddi3+0xaf>
