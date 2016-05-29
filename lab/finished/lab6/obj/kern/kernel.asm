
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
f0100015:	b8 00 b0 12 00       	mov    $0x12b000,%eax
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
f0100034:	bc 00 b0 12 f0       	mov    $0xf012b000,%esp

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
f010004b:	83 3d 8c 8e 29 f0 00 	cmpl   $0x0,0xf0298e8c
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 8c 8e 29 f0    	mov    %esi,0xf0298e8c

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 38 68 00 00       	call   f010689c <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 7b 10 f0 	movl   $0xf0107b20,(%esp)
f010007d:	e8 ac 3e 00 00       	call   f0103f2e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 6d 3e 00 00       	call   f0103efb <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 7f 8d 10 f0 	movl   $0xf0108d7f,(%esp)
f0100095:	e8 94 3e 00 00       	call   f0103f2e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 f9 08 00 00       	call   f010099f <monitor>
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
f01000ae:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 8b 7b 10 f0 	movl   $0xf0107b8b,(%esp)
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
f01000e2:	e8 b5 67 00 00       	call   f010689c <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 97 7b 10 f0 	movl   $0xf0107b97,(%esp)
f01000f2:	e8 37 3e 00 00       	call   f0103f2e <cprintf>

	lapic_init();
f01000f7:	e8 bb 67 00 00       	call   f01068b7 <lapic_init>
	env_init_percpu();
f01000fc:	e8 03 36 00 00       	call   f0103704 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 42 3e 00 00       	call   f0103f48 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 91 67 00 00       	call   f010689c <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 90 29 f0    	add    $0xf0299020,%edx
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
f010011d:	c7 04 24 c0 d3 12 f0 	movl   $0xf012d3c0,(%esp)
f0100124:	e8 32 6a 00 00       	call   f0106b5b <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();	
	sched_yield();
f0100129:	e8 20 4c 00 00       	call   f0104d4e <sched_yield>

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
f0100135:	b8 40 aa 32 f0       	mov    $0xf032aa40,%eax
f010013a:	2d 7d 73 29 f0       	sub    $0xf029737d,%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010014a:	00 
f010014b:	c7 04 24 7d 73 29 f0 	movl   $0xf029737d,(%esp)
f0100152:	e8 17 61 00 00       	call   f010626e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100157:	e8 37 05 00 00       	call   f0100693 <cons_init>

	//cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
	mem_init();
f010015c:	e8 08 13 00 00       	call   f0101469 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100161:	e8 c8 35 00 00       	call   f010372e <env_init>
	trap_init();
f0100166:	e8 e0 3e 00 00       	call   f010404b <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010016b:	e8 44 64 00 00       	call   f01065b4 <mp_init>
	lapic_init();
f0100170:	e8 42 67 00 00       	call   f01068b7 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100175:	e8 fb 3c 00 00       	call   f0103e75 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f010017a:	e8 e5 76 00 00       	call   f0107864 <time_init>
	pci_init();
f010017f:	e8 b1 76 00 00       	call   f0107835 <pci_init>
f0100184:	c7 04 24 c0 d3 12 f0 	movl   $0xf012d3c0,(%esp)
f010018b:	e8 cb 69 00 00       	call   f0106b5b <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100190:	83 3d 94 8e 29 f0 07 	cmpl   $0x7,0xf0298e94
f0100197:	77 24                	ja     f01001bd <i386_init+0x8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100199:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001a0:	00 
f01001a1:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01001a8:	f0 
f01001a9:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01001b0:	00 
f01001b1:	c7 04 24 8b 7b 10 f0 	movl   $0xf0107b8b,(%esp)
f01001b8:	e8 83 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001bd:	b8 de 64 10 f0       	mov    $0xf01064de,%eax
f01001c2:	2d 64 64 10 f0       	sub    $0xf0106464,%eax
f01001c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001cb:	c7 44 24 04 64 64 10 	movl   $0xf0106464,0x4(%esp)
f01001d2:	f0 
f01001d3:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001da:	e8 d9 60 00 00       	call   f01062b8 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001df:	bb 20 90 29 f0       	mov    $0xf0299020,%ebx
f01001e4:	eb 6f                	jmp    f0100255 <i386_init+0x127>
		if (c == cpus + cpunum())  // We've started already.
f01001e6:	e8 b1 66 00 00       	call   f010689c <cpunum>
f01001eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001f2:	29 c2                	sub    %eax,%edx
f01001f4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001f7:	8d 04 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%eax
f01001fe:	39 c3                	cmp    %eax,%ebx
f0100200:	74 50                	je     f0100252 <i386_init+0x124>

static void boot_aps(void);


void
i386_init(void)
f0100202:	89 d8                	mov    %ebx,%eax
f0100204:	2d 20 90 29 f0       	sub    $0xf0299020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100209:	c1 f8 02             	sar    $0x2,%eax
f010020c:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010020f:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0100212:	89 d1                	mov    %edx,%ecx
f0100214:	c1 e1 05             	shl    $0x5,%ecx
f0100217:	29 d1                	sub    %edx,%ecx
f0100219:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f010021c:	89 d1                	mov    %edx,%ecx
f010021e:	c1 e1 0e             	shl    $0xe,%ecx
f0100221:	29 d1                	sub    %edx,%ecx
f0100223:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100226:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f010022a:	c1 e0 0f             	shl    $0xf,%eax
f010022d:	05 00 a0 29 f0       	add    $0xf029a000,%eax
f0100232:	a3 90 8e 29 f0       	mov    %eax,0xf0298e90
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100237:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f010023e:	00 
f010023f:	0f b6 03             	movzbl (%ebx),%eax
f0100242:	89 04 24             	mov    %eax,(%esp)
f0100245:	e8 c6 67 00 00       	call   f0106a10 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010024a:	8b 43 04             	mov    0x4(%ebx),%eax
f010024d:	83 f8 01             	cmp    $0x1,%eax
f0100250:	75 f8                	jne    f010024a <i386_init+0x11c>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100252:	83 c3 74             	add    $0x74,%ebx
f0100255:	a1 c4 93 29 f0       	mov    0xf02993c4,%eax
f010025a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100261:	29 c2                	sub    %eax,%edx
f0100263:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100266:	8d 04 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%eax
f010026d:	39 c3                	cmp    %eax,%ebx
f010026f:	0f 82 71 ff ff ff    	jb     f01001e6 <i386_init+0xb8>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100275:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010027c:	00 
f010027d:	c7 04 24 91 f7 1a f0 	movl   $0xf01af791,(%esp)
f0100284:	e8 66 36 00 00       	call   f01038ef <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f0100289:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0100290:	00 
f0100291:	c7 04 24 d3 5e 21 f0 	movl   $0xf0215ed3,(%esp)
f0100298:	e8 52 36 00 00       	call   f01038ef <env_create>
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010029d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002a4:	00 
f01002a5:	c7 04 24 9f 69 1d f0 	movl   $0xf01d699f,(%esp)
f01002ac:	e8 3e 36 00 00       	call   f01038ef <env_create>
	ENV_CREATE(user_idle, ENV_TYPE_USER);
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01002b1:	e8 84 03 00 00       	call   f010063a <kbd_intr>
	
	// Schedule and run the first user environment!
	sched_yield();
f01002b6:	e8 93 4a 00 00       	call   f0104d4e <sched_yield>

f01002bb <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002bb:	55                   	push   %ebp
f01002bc:	89 e5                	mov    %esp,%ebp
f01002be:	53                   	push   %ebx
f01002bf:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002c2:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002c8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01002cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002d3:	c7 04 24 ad 7b 10 f0 	movl   $0xf0107bad,(%esp)
f01002da:	e8 4f 3c 00 00       	call   f0103f2e <cprintf>
	vcprintf(fmt, ap);
f01002df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002e3:	8b 45 10             	mov    0x10(%ebp),%eax
f01002e6:	89 04 24             	mov    %eax,(%esp)
f01002e9:	e8 0d 3c 00 00       	call   f0103efb <vcprintf>
	cprintf("\n");
f01002ee:	c7 04 24 7f 8d 10 f0 	movl   $0xf0108d7f,(%esp)
f01002f5:	e8 34 3c 00 00       	call   f0103f2e <cprintf>
	va_end(ap);
}
f01002fa:	83 c4 14             	add    $0x14,%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5d                   	pop    %ebp
f01002ff:	c3                   	ret    

f0100300 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100300:	55                   	push   %ebp
f0100301:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100303:	ba 84 00 00 00       	mov    $0x84,%edx
f0100308:	ec                   	in     (%dx),%al
f0100309:	ec                   	in     (%dx),%al
f010030a:	ec                   	in     (%dx),%al
f010030b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010030c:	5d                   	pop    %ebp
f010030d:	c3                   	ret    

f010030e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010030e:	55                   	push   %ebp
f010030f:	89 e5                	mov    %esp,%ebp
f0100311:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100316:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100317:	a8 01                	test   $0x1,%al
f0100319:	74 08                	je     f0100323 <serial_proc_data+0x15>
f010031b:	b2 f8                	mov    $0xf8,%dl
f010031d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010031e:	0f b6 c0             	movzbl %al,%eax
f0100321:	eb 05                	jmp    f0100328 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100328:	5d                   	pop    %ebp
f0100329:	c3                   	ret    

f010032a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010032a:	55                   	push   %ebp
f010032b:	89 e5                	mov    %esp,%ebp
f010032d:	53                   	push   %ebx
f010032e:	83 ec 04             	sub    $0x4,%esp
f0100331:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100333:	eb 29                	jmp    f010035e <cons_intr+0x34>
		if (c == 0)
f0100335:	85 c0                	test   %eax,%eax
f0100337:	74 25                	je     f010035e <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100339:	8b 15 24 82 29 f0    	mov    0xf0298224,%edx
f010033f:	88 82 20 80 29 f0    	mov    %al,-0xfd67fe0(%edx)
f0100345:	8d 42 01             	lea    0x1(%edx),%eax
f0100348:	a3 24 82 29 f0       	mov    %eax,0xf0298224
		if (cons.wpos == CONSBUFSIZE)
f010034d:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100352:	75 0a                	jne    f010035e <cons_intr+0x34>
			cons.wpos = 0;
f0100354:	c7 05 24 82 29 f0 00 	movl   $0x0,0xf0298224
f010035b:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010035e:	ff d3                	call   *%ebx
f0100360:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100363:	75 d0                	jne    f0100335 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100365:	83 c4 04             	add    $0x4,%esp
f0100368:	5b                   	pop    %ebx
f0100369:	5d                   	pop    %ebp
f010036a:	c3                   	ret    

f010036b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010036b:	55                   	push   %ebp
f010036c:	89 e5                	mov    %esp,%ebp
f010036e:	57                   	push   %edi
f010036f:	56                   	push   %esi
f0100370:	53                   	push   %ebx
f0100371:	83 ec 2c             	sub    $0x2c,%esp
f0100374:	89 c6                	mov    %eax,%esi
f0100376:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010037b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100380:	eb 05                	jmp    f0100387 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100382:	e8 79 ff ff ff       	call   f0100300 <delay>
f0100387:	89 fa                	mov    %edi,%edx
f0100389:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010038a:	a8 20                	test   $0x20,%al
f010038c:	75 03                	jne    f0100391 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038e:	4b                   	dec    %ebx
f010038f:	75 f1                	jne    f0100382 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100391:	89 f2                	mov    %esi,%edx
f0100393:	89 f0                	mov    %esi,%eax
f0100395:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100398:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010039d:	ee                   	out    %al,(%dx)
f010039e:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a3:	bf 79 03 00 00       	mov    $0x379,%edi
f01003a8:	eb 05                	jmp    f01003af <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01003aa:	e8 51 ff ff ff       	call   f0100300 <delay>
f01003af:	89 fa                	mov    %edi,%edx
f01003b1:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003b2:	84 c0                	test   %al,%al
f01003b4:	78 03                	js     f01003b9 <cons_putc+0x4e>
f01003b6:	4b                   	dec    %ebx
f01003b7:	75 f1                	jne    f01003aa <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	ba 78 03 00 00       	mov    $0x378,%edx
f01003be:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003c1:	ee                   	out    %al,(%dx)
f01003c2:	b2 7a                	mov    $0x7a,%dl
f01003c4:	b0 0d                	mov    $0xd,%al
f01003c6:	ee                   	out    %al,(%dx)
f01003c7:	b0 08                	mov    $0x8,%al
f01003c9:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003ca:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003d0:	75 06                	jne    f01003d8 <cons_putc+0x6d>
		c |= 0x0700;
f01003d2:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003d8:	89 f0                	mov    %esi,%eax
f01003da:	25 ff 00 00 00       	and    $0xff,%eax
f01003df:	83 f8 09             	cmp    $0x9,%eax
f01003e2:	74 78                	je     f010045c <cons_putc+0xf1>
f01003e4:	83 f8 09             	cmp    $0x9,%eax
f01003e7:	7f 0b                	jg     f01003f4 <cons_putc+0x89>
f01003e9:	83 f8 08             	cmp    $0x8,%eax
f01003ec:	0f 85 9e 00 00 00    	jne    f0100490 <cons_putc+0x125>
f01003f2:	eb 10                	jmp    f0100404 <cons_putc+0x99>
f01003f4:	83 f8 0a             	cmp    $0xa,%eax
f01003f7:	74 39                	je     f0100432 <cons_putc+0xc7>
f01003f9:	83 f8 0d             	cmp    $0xd,%eax
f01003fc:	0f 85 8e 00 00 00    	jne    f0100490 <cons_putc+0x125>
f0100402:	eb 36                	jmp    f010043a <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f0100404:	66 a1 34 82 29 f0    	mov    0xf0298234,%ax
f010040a:	66 85 c0             	test   %ax,%ax
f010040d:	0f 84 e2 00 00 00    	je     f01004f5 <cons_putc+0x18a>
			crt_pos--;
f0100413:	48                   	dec    %eax
f0100414:	66 a3 34 82 29 f0    	mov    %ax,0xf0298234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010041a:	0f b7 c0             	movzwl %ax,%eax
f010041d:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100423:	83 ce 20             	or     $0x20,%esi
f0100426:	8b 15 30 82 29 f0    	mov    0xf0298230,%edx
f010042c:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100430:	eb 78                	jmp    f01004aa <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100432:	66 83 05 34 82 29 f0 	addw   $0x50,0xf0298234
f0100439:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010043a:	66 8b 0d 34 82 29 f0 	mov    0xf0298234,%cx
f0100441:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100446:	89 c8                	mov    %ecx,%eax
f0100448:	ba 00 00 00 00       	mov    $0x0,%edx
f010044d:	66 f7 f3             	div    %bx
f0100450:	66 29 d1             	sub    %dx,%cx
f0100453:	66 89 0d 34 82 29 f0 	mov    %cx,0xf0298234
f010045a:	eb 4e                	jmp    f01004aa <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f010045c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100461:	e8 05 ff ff ff       	call   f010036b <cons_putc>
		cons_putc(' ');
f0100466:	b8 20 00 00 00       	mov    $0x20,%eax
f010046b:	e8 fb fe ff ff       	call   f010036b <cons_putc>
		cons_putc(' ');
f0100470:	b8 20 00 00 00       	mov    $0x20,%eax
f0100475:	e8 f1 fe ff ff       	call   f010036b <cons_putc>
		cons_putc(' ');
f010047a:	b8 20 00 00 00       	mov    $0x20,%eax
f010047f:	e8 e7 fe ff ff       	call   f010036b <cons_putc>
		cons_putc(' ');
f0100484:	b8 20 00 00 00       	mov    $0x20,%eax
f0100489:	e8 dd fe ff ff       	call   f010036b <cons_putc>
f010048e:	eb 1a                	jmp    f01004aa <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100490:	66 a1 34 82 29 f0    	mov    0xf0298234,%ax
f0100496:	0f b7 c8             	movzwl %ax,%ecx
f0100499:	8b 15 30 82 29 f0    	mov    0xf0298230,%edx
f010049f:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01004a3:	40                   	inc    %eax
f01004a4:	66 a3 34 82 29 f0    	mov    %ax,0xf0298234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01004aa:	66 81 3d 34 82 29 f0 	cmpw   $0x7cf,0xf0298234
f01004b1:	cf 07 
f01004b3:	76 40                	jbe    f01004f5 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004b5:	a1 30 82 29 f0       	mov    0xf0298230,%eax
f01004ba:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01004c1:	00 
f01004c2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004c8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004cc:	89 04 24             	mov    %eax,(%esp)
f01004cf:	e8 e4 5d 00 00       	call   f01062b8 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004d4:	8b 15 30 82 29 f0    	mov    0xf0298230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004da:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004df:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004e5:	40                   	inc    %eax
f01004e6:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004eb:	75 f2                	jne    f01004df <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004ed:	66 83 2d 34 82 29 f0 	subw   $0x50,0xf0298234
f01004f4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004f5:	8b 0d 2c 82 29 f0    	mov    0xf029822c,%ecx
f01004fb:	b0 0e                	mov    $0xe,%al
f01004fd:	89 ca                	mov    %ecx,%edx
f01004ff:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100500:	66 8b 35 34 82 29 f0 	mov    0xf0298234,%si
f0100507:	8d 59 01             	lea    0x1(%ecx),%ebx
f010050a:	89 f0                	mov    %esi,%eax
f010050c:	66 c1 e8 08          	shr    $0x8,%ax
f0100510:	89 da                	mov    %ebx,%edx
f0100512:	ee                   	out    %al,(%dx)
f0100513:	b0 0f                	mov    $0xf,%al
f0100515:	89 ca                	mov    %ecx,%edx
f0100517:	ee                   	out    %al,(%dx)
f0100518:	89 f0                	mov    %esi,%eax
f010051a:	89 da                	mov    %ebx,%edx
f010051c:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010051d:	83 c4 2c             	add    $0x2c,%esp
f0100520:	5b                   	pop    %ebx
f0100521:	5e                   	pop    %esi
f0100522:	5f                   	pop    %edi
f0100523:	5d                   	pop    %ebp
f0100524:	c3                   	ret    

f0100525 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100525:	55                   	push   %ebp
f0100526:	89 e5                	mov    %esp,%ebp
f0100528:	53                   	push   %ebx
f0100529:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010052c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100531:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100532:	a8 01                	test   $0x1,%al
f0100534:	0f 84 d8 00 00 00    	je     f0100612 <kbd_proc_data+0xed>
f010053a:	b2 60                	mov    $0x60,%dl
f010053c:	ec                   	in     (%dx),%al
f010053d:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010053f:	3c e0                	cmp    $0xe0,%al
f0100541:	75 11                	jne    f0100554 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100543:	83 0d 28 82 29 f0 40 	orl    $0x40,0xf0298228
		return 0;
f010054a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010054f:	e9 c3 00 00 00       	jmp    f0100617 <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100554:	84 c0                	test   %al,%al
f0100556:	79 33                	jns    f010058b <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100558:	8b 0d 28 82 29 f0    	mov    0xf0298228,%ecx
f010055e:	f6 c1 40             	test   $0x40,%cl
f0100561:	75 05                	jne    f0100568 <kbd_proc_data+0x43>
f0100563:	88 c2                	mov    %al,%dl
f0100565:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100568:	0f b6 d2             	movzbl %dl,%edx
f010056b:	8a 82 00 7c 10 f0    	mov    -0xfef8400(%edx),%al
f0100571:	83 c8 40             	or     $0x40,%eax
f0100574:	0f b6 c0             	movzbl %al,%eax
f0100577:	f7 d0                	not    %eax
f0100579:	21 c1                	and    %eax,%ecx
f010057b:	89 0d 28 82 29 f0    	mov    %ecx,0xf0298228
		return 0;
f0100581:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100586:	e9 8c 00 00 00       	jmp    f0100617 <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f010058b:	8b 0d 28 82 29 f0    	mov    0xf0298228,%ecx
f0100591:	f6 c1 40             	test   $0x40,%cl
f0100594:	74 0e                	je     f01005a4 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100596:	88 c2                	mov    %al,%dl
f0100598:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010059b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010059e:	89 0d 28 82 29 f0    	mov    %ecx,0xf0298228
	}

	shift |= shiftcode[data];
f01005a4:	0f b6 d2             	movzbl %dl,%edx
f01005a7:	0f b6 82 00 7c 10 f0 	movzbl -0xfef8400(%edx),%eax
f01005ae:	0b 05 28 82 29 f0    	or     0xf0298228,%eax
	shift ^= togglecode[data];
f01005b4:	0f b6 8a 00 7d 10 f0 	movzbl -0xfef8300(%edx),%ecx
f01005bb:	31 c8                	xor    %ecx,%eax
f01005bd:	a3 28 82 29 f0       	mov    %eax,0xf0298228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c2:	89 c1                	mov    %eax,%ecx
f01005c4:	83 e1 03             	and    $0x3,%ecx
f01005c7:	8b 0c 8d 00 7e 10 f0 	mov    -0xfef8200(,%ecx,4),%ecx
f01005ce:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005d2:	a8 08                	test   $0x8,%al
f01005d4:	74 18                	je     f01005ee <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01005d6:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005d9:	83 fa 19             	cmp    $0x19,%edx
f01005dc:	77 05                	ja     f01005e3 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f01005de:	83 eb 20             	sub    $0x20,%ebx
f01005e1:	eb 0b                	jmp    f01005ee <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f01005e3:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005e6:	83 fa 19             	cmp    $0x19,%edx
f01005e9:	77 03                	ja     f01005ee <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f01005eb:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005ee:	f7 d0                	not    %eax
f01005f0:	a8 06                	test   $0x6,%al
f01005f2:	75 23                	jne    f0100617 <kbd_proc_data+0xf2>
f01005f4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005fa:	75 1b                	jne    f0100617 <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f01005fc:	c7 04 24 c7 7b 10 f0 	movl   $0xf0107bc7,(%esp)
f0100603:	e8 26 39 00 00       	call   f0103f2e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100608:	ba 92 00 00 00       	mov    $0x92,%edx
f010060d:	b0 03                	mov    $0x3,%al
f010060f:	ee                   	out    %al,(%dx)
f0100610:	eb 05                	jmp    f0100617 <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100612:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100617:	89 d8                	mov    %ebx,%eax
f0100619:	83 c4 14             	add    $0x14,%esp
f010061c:	5b                   	pop    %ebx
f010061d:	5d                   	pop    %ebp
f010061e:	c3                   	ret    

f010061f <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010061f:	55                   	push   %ebp
f0100620:	89 e5                	mov    %esp,%ebp
f0100622:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100625:	80 3d 00 80 29 f0 00 	cmpb   $0x0,0xf0298000
f010062c:	74 0a                	je     f0100638 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f010062e:	b8 0e 03 10 f0       	mov    $0xf010030e,%eax
f0100633:	e8 f2 fc ff ff       	call   f010032a <cons_intr>
}
f0100638:	c9                   	leave  
f0100639:	c3                   	ret    

f010063a <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010063a:	55                   	push   %ebp
f010063b:	89 e5                	mov    %esp,%ebp
f010063d:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100640:	b8 25 05 10 f0       	mov    $0xf0100525,%eax
f0100645:	e8 e0 fc ff ff       	call   f010032a <cons_intr>
}
f010064a:	c9                   	leave  
f010064b:	c3                   	ret    

f010064c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010064c:	55                   	push   %ebp
f010064d:	89 e5                	mov    %esp,%ebp
f010064f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100652:	e8 c8 ff ff ff       	call   f010061f <serial_intr>
	kbd_intr();
f0100657:	e8 de ff ff ff       	call   f010063a <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010065c:	8b 15 20 82 29 f0    	mov    0xf0298220,%edx
f0100662:	3b 15 24 82 29 f0    	cmp    0xf0298224,%edx
f0100668:	74 22                	je     f010068c <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010066a:	0f b6 82 20 80 29 f0 	movzbl -0xfd67fe0(%edx),%eax
f0100671:	42                   	inc    %edx
f0100672:	89 15 20 82 29 f0    	mov    %edx,0xf0298220
		if (cons.rpos == CONSBUFSIZE)
f0100678:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067e:	75 11                	jne    f0100691 <cons_getc+0x45>
			cons.rpos = 0;
f0100680:	c7 05 20 82 29 f0 00 	movl   $0x0,0xf0298220
f0100687:	00 00 00 
f010068a:	eb 05                	jmp    f0100691 <cons_getc+0x45>
		return c;
	}
	return 0;
f010068c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100691:	c9                   	leave  
f0100692:	c3                   	ret    

f0100693 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100693:	55                   	push   %ebp
f0100694:	89 e5                	mov    %esp,%ebp
f0100696:	57                   	push   %edi
f0100697:	56                   	push   %esi
f0100698:	53                   	push   %ebx
f0100699:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010069c:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006a3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006aa:	5a a5 
	if (*cp != 0xA55A) {
f01006ac:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006b2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b6:	74 11                	je     f01006c9 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006b8:	c7 05 2c 82 29 f0 b4 	movl   $0x3b4,0xf029822c
f01006bf:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006c2:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006c7:	eb 16                	jmp    f01006df <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006c9:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006d0:	c7 05 2c 82 29 f0 d4 	movl   $0x3d4,0xf029822c
f01006d7:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006da:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006df:	8b 0d 2c 82 29 f0    	mov    0xf029822c,%ecx
f01006e5:	b0 0e                	mov    $0xe,%al
f01006e7:	89 ca                	mov    %ecx,%edx
f01006e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ea:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ed:	89 da                	mov    %ebx,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	0f b6 f8             	movzbl %al,%edi
f01006f3:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	b0 0f                	mov    $0xf,%al
f01006f8:	89 ca                	mov    %ecx,%edx
f01006fa:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fb:	89 da                	mov    %ebx,%edx
f01006fd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006fe:	89 35 30 82 29 f0    	mov    %esi,0xf0298230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100704:	0f b6 d8             	movzbl %al,%ebx
f0100707:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100709:	66 89 3d 34 82 29 f0 	mov    %di,0xf0298234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100710:	e8 25 ff ff ff       	call   f010063a <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100715:	0f b7 05 a8 d3 12 f0 	movzwl 0xf012d3a8,%eax
f010071c:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100721:	89 04 24             	mov    %eax,(%esp)
f0100724:	e8 d3 36 00 00       	call   f0103dfc <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100729:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010072e:	b0 00                	mov    $0x0,%al
f0100730:	89 da                	mov    %ebx,%edx
f0100732:	ee                   	out    %al,(%dx)
f0100733:	b2 fb                	mov    $0xfb,%dl
f0100735:	b0 80                	mov    $0x80,%al
f0100737:	ee                   	out    %al,(%dx)
f0100738:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010073d:	b0 0c                	mov    $0xc,%al
f010073f:	89 ca                	mov    %ecx,%edx
f0100741:	ee                   	out    %al,(%dx)
f0100742:	b2 f9                	mov    $0xf9,%dl
f0100744:	b0 00                	mov    $0x0,%al
f0100746:	ee                   	out    %al,(%dx)
f0100747:	b2 fb                	mov    $0xfb,%dl
f0100749:	b0 03                	mov    $0x3,%al
f010074b:	ee                   	out    %al,(%dx)
f010074c:	b2 fc                	mov    $0xfc,%dl
f010074e:	b0 00                	mov    $0x0,%al
f0100750:	ee                   	out    %al,(%dx)
f0100751:	b2 f9                	mov    $0xf9,%dl
f0100753:	b0 01                	mov    $0x1,%al
f0100755:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100756:	b2 fd                	mov    $0xfd,%dl
f0100758:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100759:	3c ff                	cmp    $0xff,%al
f010075b:	0f 95 45 e7          	setne  -0x19(%ebp)
f010075f:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100762:	a2 00 80 29 f0       	mov    %al,0xf0298000
f0100767:	89 da                	mov    %ebx,%edx
f0100769:	ec                   	in     (%dx),%al
f010076a:	89 ca                	mov    %ecx,%edx
f010076c:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010076d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100771:	74 1d                	je     f0100790 <cons_init+0xfd>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100773:	0f b7 05 a8 d3 12 f0 	movzwl 0xf012d3a8,%eax
f010077a:	25 ef ff 00 00       	and    $0xffef,%eax
f010077f:	89 04 24             	mov    %eax,(%esp)
f0100782:	e8 75 36 00 00       	call   f0103dfc <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100787:	80 3d 00 80 29 f0 00 	cmpb   $0x0,0xf0298000
f010078e:	75 0c                	jne    f010079c <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100790:	c7 04 24 d3 7b 10 f0 	movl   $0xf0107bd3,(%esp)
f0100797:	e8 92 37 00 00       	call   f0103f2e <cprintf>
}
f010079c:	83 c4 2c             	add    $0x2c,%esp
f010079f:	5b                   	pop    %ebx
f01007a0:	5e                   	pop    %esi
f01007a1:	5f                   	pop    %edi
f01007a2:	5d                   	pop    %ebp
f01007a3:	c3                   	ret    

f01007a4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007a4:	55                   	push   %ebp
f01007a5:	89 e5                	mov    %esp,%ebp
f01007a7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ad:	e8 b9 fb ff ff       	call   f010036b <cons_putc>
}
f01007b2:	c9                   	leave  
f01007b3:	c3                   	ret    

f01007b4 <getchar>:

int
getchar(void)
{
f01007b4:	55                   	push   %ebp
f01007b5:	89 e5                	mov    %esp,%ebp
f01007b7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ba:	e8 8d fe ff ff       	call   f010064c <cons_getc>
f01007bf:	85 c0                	test   %eax,%eax
f01007c1:	74 f7                	je     f01007ba <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007c3:	c9                   	leave  
f01007c4:	c3                   	ret    

f01007c5 <iscons>:

int
iscons(int fdnum)
{
f01007c5:	55                   	push   %ebp
f01007c6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007cd:	5d                   	pop    %ebp
f01007ce:	c3                   	ret    
	...

f01007d0 <continue_exec>:

/***** Implementations of basic kernel monitor commands *****/

int
continue_exec(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags &= ~FL_TF;
f01007d6:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	    return -1;
}
f01007dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007e2:	5d                   	pop    %ebp
f01007e3:	c3                   	ret    

f01007e4 <single_step>:

int
single_step(int argc, char **argv, struct Trapframe *tf)
{
f01007e4:	55                   	push   %ebp
f01007e5:	89 e5                	mov    %esp,%ebp
f01007e7:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags |= FL_TF;
f01007ea:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
		return -1;
}
f01007f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007f6:	5d                   	pop    %ebp
f01007f7:	c3                   	ret    

f01007f8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f8:	55                   	push   %ebp
f01007f9:	89 e5                	mov    %esp,%ebp
f01007fb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007fe:	c7 04 24 10 7e 10 f0 	movl   $0xf0107e10,(%esp)
f0100805:	e8 24 37 00 00       	call   f0103f2e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100811:	00 
f0100812:	c7 04 24 f0 7e 10 f0 	movl   $0xf0107ef0,(%esp)
f0100819:	e8 10 37 00 00       	call   f0103f2e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100825:	00 
f0100826:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010082d:	f0 
f010082e:	c7 04 24 18 7f 10 f0 	movl   $0xf0107f18,(%esp)
f0100835:	e8 f4 36 00 00       	call   f0103f2e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010083a:	c7 44 24 08 0a 7b 10 	movl   $0x107b0a,0x8(%esp)
f0100841:	00 
f0100842:	c7 44 24 04 0a 7b 10 	movl   $0xf0107b0a,0x4(%esp)
f0100849:	f0 
f010084a:	c7 04 24 3c 7f 10 f0 	movl   $0xf0107f3c,(%esp)
f0100851:	e8 d8 36 00 00       	call   f0103f2e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100856:	c7 44 24 08 7d 73 29 	movl   $0x29737d,0x8(%esp)
f010085d:	00 
f010085e:	c7 44 24 04 7d 73 29 	movl   $0xf029737d,0x4(%esp)
f0100865:	f0 
f0100866:	c7 04 24 60 7f 10 f0 	movl   $0xf0107f60,(%esp)
f010086d:	e8 bc 36 00 00       	call   f0103f2e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100872:	c7 44 24 08 40 aa 32 	movl   $0x32aa40,0x8(%esp)
f0100879:	00 
f010087a:	c7 44 24 04 40 aa 32 	movl   $0xf032aa40,0x4(%esp)
f0100881:	f0 
f0100882:	c7 04 24 84 7f 10 f0 	movl   $0xf0107f84,(%esp)
f0100889:	e8 a0 36 00 00       	call   f0103f2e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010088e:	b8 3f ae 32 f0       	mov    $0xf032ae3f,%eax
f0100893:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100898:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089d:	89 c2                	mov    %eax,%edx
f010089f:	85 c0                	test   %eax,%eax
f01008a1:	79 06                	jns    f01008a9 <mon_kerninfo+0xb1>
f01008a3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a9:	c1 fa 0a             	sar    $0xa,%edx
f01008ac:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008b0:	c7 04 24 a8 7f 10 f0 	movl   $0xf0107fa8,(%esp)
f01008b7:	e8 72 36 00 00       	call   f0103f2e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c1:	c9                   	leave  
f01008c2:	c3                   	ret    

f01008c3 <mon_help>:
		return -1;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008c3:	55                   	push   %ebp
f01008c4:	89 e5                	mov    %esp,%ebp
f01008c6:	53                   	push   %ebx
f01008c7:	83 ec 14             	sub    $0x14,%esp
f01008ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008cf:	8b 83 c4 80 10 f0    	mov    -0xfef7f3c(%ebx),%eax
f01008d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008d9:	8b 83 c0 80 10 f0    	mov    -0xfef7f40(%ebx),%eax
f01008df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e3:	c7 04 24 29 7e 10 f0 	movl   $0xf0107e29,(%esp)
f01008ea:	e8 3f 36 00 00       	call   f0103f2e <cprintf>
f01008ef:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01008f2:	83 fb 3c             	cmp    $0x3c,%ebx
f01008f5:	75 d8                	jne    f01008cf <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01008f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fc:	83 c4 14             	add    $0x14,%esp
f01008ff:	5b                   	pop    %ebx
f0100900:	5d                   	pop    %ebp
f0100901:	c3                   	ret    

f0100902 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100902:	55                   	push   %ebp
f0100903:	89 e5                	mov    %esp,%ebp
f0100905:	57                   	push   %edi
f0100906:	56                   	push   %esi
f0100907:	53                   	push   %ebx
f0100908:	83 ec 6c             	sub    $0x6c,%esp
	// Your code here.
	
	int bt_cnt = 0;
	struct Eipdebuginfo eip_info;
	int* pre_ebp = (int *)read_ebp();
f010090b:	89 eb                	mov    %ebp,%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
f010090d:	c7 04 24 32 7e 10 f0 	movl   $0xf0107e32,(%esp)
f0100914:	e8 15 36 00 00       	call   f0103f2e <cprintf>
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	int bt_cnt = 0;
f0100919:	bf 00 00 00 00       	mov    $0x0,%edi
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f010091e:	eb 71                	jmp    f0100991 <mon_backtrace+0x8f>
		bt_cnt++;
f0100920:	47                   	inc    %edi
		eip = (int)*(pre_ebp+1);
f0100921:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip((uintptr_t)eip, &eip_info);
f0100924:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100927:	89 44 24 04          	mov    %eax,0x4(%esp)
f010092b:	89 34 24             	mov    %esi,(%esp)
f010092e:	e8 6a 4e 00 00       	call   f010579d <debuginfo_eip>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
f0100933:	89 f0                	mov    %esi,%eax
f0100935:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100938:	89 44 24 30          	mov    %eax,0x30(%esp)
f010093c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010093f:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100943:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100946:	89 44 24 28          	mov    %eax,0x28(%esp)
f010094a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010094d:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100951:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100954:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100958:	8b 43 18             	mov    0x18(%ebx),%eax
f010095b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010095f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100962:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100966:	8b 43 10             	mov    0x10(%ebx),%eax
f0100969:	89 44 24 14          	mov    %eax,0x14(%esp)
f010096d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100970:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100974:	8b 43 08             	mov    0x8(%ebx),%eax
f0100977:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010097b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010097f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100983:	c7 04 24 d4 7f 10 f0 	movl   $0xf0107fd4,(%esp)
f010098a:	e8 9f 35 00 00       	call   f0103f2e <cprintf>
		
		pre_ebp = (int *)*pre_ebp;
f010098f:	8b 1b                	mov    (%ebx),%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f0100991:	85 db                	test   %ebx,%ebx
f0100993:	75 8b                	jne    f0100920 <mon_backtrace+0x1e>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
		
		pre_ebp = (int *)*pre_ebp;
	}
	return bt_cnt;
}
f0100995:	89 f8                	mov    %edi,%eax
f0100997:	83 c4 6c             	add    $0x6c,%esp
f010099a:	5b                   	pop    %ebx
f010099b:	5e                   	pop    %esi
f010099c:	5f                   	pop    %edi
f010099d:	5d                   	pop    %ebp
f010099e:	c3                   	ret    

f010099f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010099f:	55                   	push   %ebp
f01009a0:	89 e5                	mov    %esp,%ebp
f01009a2:	57                   	push   %edi
f01009a3:	56                   	push   %esi
f01009a4:	53                   	push   %ebx
f01009a5:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009a8:	c7 04 24 1c 80 10 f0 	movl   $0xf010801c,(%esp)
f01009af:	e8 7a 35 00 00       	call   f0103f2e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009b4:	c7 04 24 40 80 10 f0 	movl   $0xf0108040,(%esp)
f01009bb:	e8 6e 35 00 00       	call   f0103f2e <cprintf>

	if (tf != NULL)
f01009c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009c4:	74 0b                	je     f01009d1 <monitor+0x32>
		print_trapframe(tf);
f01009c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01009c9:	89 04 24             	mov    %eax,(%esp)
f01009cc:	e8 8c 3b 00 00       	call   f010455d <print_trapframe>
	
	while (1) {
		buf = readline("K> ");
f01009d1:	c7 04 24 44 7e 10 f0 	movl   $0xf0107e44,(%esp)
f01009d8:	e8 57 56 00 00       	call   f0106034 <readline>
f01009dd:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009df:	85 c0                	test   %eax,%eax
f01009e1:	74 ee                	je     f01009d1 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009e3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009ea:	be 00 00 00 00       	mov    $0x0,%esi
f01009ef:	eb 04                	jmp    f01009f5 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009f1:	c6 03 00             	movb   $0x0,(%ebx)
f01009f4:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009f5:	8a 03                	mov    (%ebx),%al
f01009f7:	84 c0                	test   %al,%al
f01009f9:	74 5e                	je     f0100a59 <monitor+0xba>
f01009fb:	0f be c0             	movsbl %al,%eax
f01009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a02:	c7 04 24 48 7e 10 f0 	movl   $0xf0107e48,(%esp)
f0100a09:	e8 2b 58 00 00       	call   f0106239 <strchr>
f0100a0e:	85 c0                	test   %eax,%eax
f0100a10:	75 df                	jne    f01009f1 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100a12:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a15:	74 42                	je     f0100a59 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a17:	83 fe 0f             	cmp    $0xf,%esi
f0100a1a:	75 16                	jne    f0100a32 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a1c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a23:	00 
f0100a24:	c7 04 24 4d 7e 10 f0 	movl   $0xf0107e4d,(%esp)
f0100a2b:	e8 fe 34 00 00       	call   f0103f2e <cprintf>
f0100a30:	eb 9f                	jmp    f01009d1 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100a32:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a36:	46                   	inc    %esi
f0100a37:	eb 01                	jmp    f0100a3a <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a39:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a3a:	8a 03                	mov    (%ebx),%al
f0100a3c:	84 c0                	test   %al,%al
f0100a3e:	74 b5                	je     f01009f5 <monitor+0x56>
f0100a40:	0f be c0             	movsbl %al,%eax
f0100a43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a47:	c7 04 24 48 7e 10 f0 	movl   $0xf0107e48,(%esp)
f0100a4e:	e8 e6 57 00 00       	call   f0106239 <strchr>
f0100a53:	85 c0                	test   %eax,%eax
f0100a55:	74 e2                	je     f0100a39 <monitor+0x9a>
f0100a57:	eb 9c                	jmp    f01009f5 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100a59:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a60:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a61:	85 f6                	test   %esi,%esi
f0100a63:	0f 84 68 ff ff ff    	je     f01009d1 <monitor+0x32>
f0100a69:	bb c0 80 10 f0       	mov    $0xf01080c0,%ebx
f0100a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a73:	8b 03                	mov    (%ebx),%eax
f0100a75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a79:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a7c:	89 04 24             	mov    %eax,(%esp)
f0100a7f:	e8 62 57 00 00       	call   f01061e6 <strcmp>
f0100a84:	85 c0                	test   %eax,%eax
f0100a86:	75 24                	jne    f0100aac <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100a88:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100a8b:	8b 55 08             	mov    0x8(%ebp),%edx
f0100a8e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100a92:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a95:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100a99:	89 34 24             	mov    %esi,(%esp)
f0100a9c:	ff 14 85 c8 80 10 f0 	call   *-0xfef7f38(,%eax,4)
		print_trapframe(tf);
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100aa3:	85 c0                	test   %eax,%eax
f0100aa5:	78 26                	js     f0100acd <monitor+0x12e>
f0100aa7:	e9 25 ff ff ff       	jmp    f01009d1 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100aac:	47                   	inc    %edi
f0100aad:	83 c3 0c             	add    $0xc,%ebx
f0100ab0:	83 ff 05             	cmp    $0x5,%edi
f0100ab3:	75 be                	jne    f0100a73 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ab5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100abc:	c7 04 24 6a 7e 10 f0 	movl   $0xf0107e6a,(%esp)
f0100ac3:	e8 66 34 00 00       	call   f0103f2e <cprintf>
f0100ac8:	e9 04 ff ff ff       	jmp    f01009d1 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100acd:	83 c4 5c             	add    $0x5c,%esp
f0100ad0:	5b                   	pop    %ebx
f0100ad1:	5e                   	pop    %esi
f0100ad2:	5f                   	pop    %edi
f0100ad3:	5d                   	pop    %ebp
f0100ad4:	c3                   	ret    
f0100ad5:	00 00                	add    %al,(%eax)
	...

f0100ad8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
f0100adb:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ade:	89 d1                	mov    %edx,%ecx
f0100ae0:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ae3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ae6:	a8 01                	test   $0x1,%al
f0100ae8:	74 4d                	je     f0100b37 <check_va2pa+0x5f>
	  return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100aea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aef:	89 c1                	mov    %eax,%ecx
f0100af1:	c1 e9 0c             	shr    $0xc,%ecx
f0100af4:	3b 0d 94 8e 29 f0    	cmp    0xf0298e94,%ecx
f0100afa:	72 20                	jb     f0100b1c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100afc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b00:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0100b07:	f0 
f0100b08:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0100b0f:	00 
f0100b10:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100b17:	e8 24 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b1c:	c1 ea 0c             	shr    $0xc,%edx
f0100b1f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b25:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b2c:	a8 01                	test   $0x1,%al
f0100b2e:	74 0e                	je     f0100b3e <check_va2pa+0x66>
	  return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b30:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b35:	eb 0c                	jmp    f0100b43 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
	  return ~0;
f0100b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b3c:	eb 05                	jmp    f0100b43 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
	  return ~0;
f0100b3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100b43:	c9                   	leave  
f0100b44:	c3                   	ret    

f0100b45 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b45:	55                   	push   %ebp
f0100b46:	89 e5                	mov    %esp,%ebp
f0100b48:	53                   	push   %ebx
f0100b49:	83 ec 24             	sub    $0x24,%esp
f0100b4c:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b4e:	83 3d 3c 82 29 f0 00 	cmpl   $0x0,0xf029823c
f0100b55:	75 0f                	jne    f0100b66 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b57:	b8 3f ba 32 f0       	mov    $0xf032ba3f,%eax
f0100b5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b61:	a3 3c 82 29 f0       	mov    %eax,0xf029823c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	// first end is at address 0xf011b970, result is 0xf011c100, use 107KB for kernel 
	if (n > 0) {
f0100b66:	85 d2                	test   %edx,%edx
f0100b68:	74 55                	je     f0100bbf <boot_alloc+0x7a>
		result = nextfree;
f0100b6a:	a1 3c 82 29 f0       	mov    0xf029823c,%eax
		nextfree = ROUNDUP((char *)(nextfree+n), PGSIZE);
f0100b6f:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100b76:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b7c:	89 15 3c 82 29 f0    	mov    %edx,0xf029823c
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE ){
f0100b82:	8b 0d 94 8e 29 f0    	mov    0xf0298e94,%ecx
f0100b88:	c1 e1 0c             	shl    $0xc,%ecx
f0100b8b:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100b91:	39 cb                	cmp    %ecx,%ebx
f0100b93:	76 2f                	jbe    f0100bc4 <boot_alloc+0x7f>
			panic("Cannot alloc more physical memory. Requested %dK, Available %dK\n", (uint32_t)nextfree/1024, npages*PGSIZE/1024);
f0100b95:	c1 e9 0a             	shr    $0xa,%ecx
f0100b98:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100b9c:	c1 ea 0a             	shr    $0xa,%edx
f0100b9f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ba3:	c7 44 24 08 fc 80 10 	movl   $0xf01080fc,0x8(%esp)
f0100baa:	f0 
f0100bab:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f0100bb2:	00 
f0100bb3:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100bba:	e8 81 f4 ff ff       	call   f0100040 <_panic>
		}
		return result;
	}
	return nextfree;
f0100bbf:	a1 3c 82 29 f0       	mov    0xf029823c,%eax
}
f0100bc4:	83 c4 24             	add    $0x24,%esp
f0100bc7:	5b                   	pop    %ebx
f0100bc8:	5d                   	pop    %ebp
f0100bc9:	c3                   	ret    

f0100bca <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bca:	55                   	push   %ebp
f0100bcb:	89 e5                	mov    %esp,%ebp
f0100bcd:	56                   	push   %esi
f0100bce:	53                   	push   %ebx
f0100bcf:	83 ec 10             	sub    $0x10,%esp
f0100bd2:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bd4:	89 04 24             	mov    %eax,(%esp)
f0100bd7:	e8 f8 31 00 00       	call   f0103dd4 <mc146818_read>
f0100bdc:	89 c6                	mov    %eax,%esi
f0100bde:	43                   	inc    %ebx
f0100bdf:	89 1c 24             	mov    %ebx,(%esp)
f0100be2:	e8 ed 31 00 00       	call   f0103dd4 <mc146818_read>
f0100be7:	c1 e0 08             	shl    $0x8,%eax
f0100bea:	09 f0                	or     %esi,%eax
}
f0100bec:	83 c4 10             	add    $0x10,%esp
f0100bef:	5b                   	pop    %ebx
f0100bf0:	5e                   	pop    %esi
f0100bf1:	5d                   	pop    %ebp
f0100bf2:	c3                   	ret    

f0100bf3 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bf3:	55                   	push   %ebp
f0100bf4:	89 e5                	mov    %esp,%ebp
f0100bf6:	57                   	push   %edi
f0100bf7:	56                   	push   %esi
f0100bf8:	53                   	push   %ebx
f0100bf9:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bfc:	3c 01                	cmp    $0x1,%al
f0100bfe:	19 f6                	sbb    %esi,%esi
f0100c00:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100c06:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c07:	8b 15 40 82 29 f0    	mov    0xf0298240,%edx
f0100c0d:	85 d2                	test   %edx,%edx
f0100c0f:	75 1c                	jne    f0100c2d <check_page_free_list+0x3a>
	  panic("'page_free_list' is a null pointer!");
f0100c11:	c7 44 24 08 40 81 10 	movl   $0xf0108140,0x8(%esp)
f0100c18:	f0 
f0100c19:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0100c20:	00 
f0100c21:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100c28:	e8 13 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100c2d:	84 c0                	test   %al,%al
f0100c2f:	74 4b                	je     f0100c7c <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c31:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100c34:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100c3a:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c3d:	89 d0                	mov    %edx,%eax
f0100c3f:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0100c45:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c48:	c1 e8 16             	shr    $0x16,%eax
f0100c4b:	39 c6                	cmp    %eax,%esi
f0100c4d:	0f 96 c0             	setbe  %al
f0100c50:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100c53:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100c57:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c59:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c5d:	8b 12                	mov    (%edx),%edx
f0100c5f:	85 d2                	test   %edx,%edx
f0100c61:	75 da                	jne    f0100c3d <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c63:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c6c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c6f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100c72:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c77:	a3 40 82 29 f0       	mov    %eax,0xf0298240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c7c:	8b 1d 40 82 29 f0    	mov    0xf0298240,%ebx
f0100c82:	eb 63                	jmp    f0100ce7 <check_page_free_list+0xf4>
f0100c84:	89 d8                	mov    %ebx,%eax
f0100c86:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0100c8c:	c1 f8 03             	sar    $0x3,%eax
f0100c8f:	c1 e0 0c             	shl    $0xc,%eax
	  if (PDX(page2pa(pp)) < pdx_limit)
f0100c92:	89 c2                	mov    %eax,%edx
f0100c94:	c1 ea 16             	shr    $0x16,%edx
f0100c97:	39 d6                	cmp    %edx,%esi
f0100c99:	76 4a                	jbe    f0100ce5 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c9b:	89 c2                	mov    %eax,%edx
f0100c9d:	c1 ea 0c             	shr    $0xc,%edx
f0100ca0:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0100ca6:	72 20                	jb     f0100cc8 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cac:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0100cb3:	f0 
f0100cb4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100cbb:	00 
f0100cbc:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0100cc3:	e8 78 f3 ff ff       	call   f0100040 <_panic>
		memset(page2kva(pp), 0x97, 128);
f0100cc8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ccf:	00 
f0100cd0:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100cd7:	00 
	return (void *)(pa + KERNBASE);
f0100cd8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cdd:	89 04 24             	mov    %eax,(%esp)
f0100ce0:	e8 89 55 00 00       	call   f010626e <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ce5:	8b 1b                	mov    (%ebx),%ebx
f0100ce7:	85 db                	test   %ebx,%ebx
f0100ce9:	75 99                	jne    f0100c84 <check_page_free_list+0x91>
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ceb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cf0:	e8 50 fe ff ff       	call   f0100b45 <boot_alloc>
f0100cf5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf8:	8b 15 40 82 29 f0    	mov    0xf0298240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cfe:	8b 0d 9c 8e 29 f0    	mov    0xf0298e9c,%ecx
		assert(pp < pages + npages);
f0100d04:	a1 94 8e 29 f0       	mov    0xf0298e94,%eax
f0100d09:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100d0c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d12:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d15:	be 00 00 00 00       	mov    $0x0,%esi
f0100d1a:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d1d:	e9 c4 01 00 00       	jmp    f0100ee6 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d22:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100d25:	73 24                	jae    f0100d4b <check_page_free_list+0x158>
f0100d27:	c7 44 24 0c 57 8a 10 	movl   $0xf0108a57,0xc(%esp)
f0100d2e:	f0 
f0100d2f:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100d36:	f0 
f0100d37:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0100d3e:	00 
f0100d3f:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100d46:	e8 f5 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d4b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d4e:	72 24                	jb     f0100d74 <check_page_free_list+0x181>
f0100d50:	c7 44 24 0c 78 8a 10 	movl   $0xf0108a78,0xc(%esp)
f0100d57:	f0 
f0100d58:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100d5f:	f0 
f0100d60:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0100d67:	00 
f0100d68:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100d6f:	e8 cc f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d74:	89 d0                	mov    %edx,%eax
f0100d76:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d79:	a8 07                	test   $0x7,%al
f0100d7b:	74 24                	je     f0100da1 <check_page_free_list+0x1ae>
f0100d7d:	c7 44 24 0c 64 81 10 	movl   $0xf0108164,0xc(%esp)
f0100d84:	f0 
f0100d85:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100d8c:	f0 
f0100d8d:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0100d94:	00 
f0100d95:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100d9c:	e8 9f f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100da1:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100da4:	c1 e0 0c             	shl    $0xc,%eax
f0100da7:	75 24                	jne    f0100dcd <check_page_free_list+0x1da>
f0100da9:	c7 44 24 0c 8c 8a 10 	movl   $0xf0108a8c,0xc(%esp)
f0100db0:	f0 
f0100db1:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100db8:	f0 
f0100db9:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0100dc0:	00 
f0100dc1:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100dc8:	e8 73 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dcd:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dd2:	75 24                	jne    f0100df8 <check_page_free_list+0x205>
f0100dd4:	c7 44 24 0c 9d 8a 10 	movl   $0xf0108a9d,0xc(%esp)
f0100ddb:	f0 
f0100ddc:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100de3:	f0 
f0100de4:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0100deb:	00 
f0100dec:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100df3:	e8 48 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100df8:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100dfd:	75 24                	jne    f0100e23 <check_page_free_list+0x230>
f0100dff:	c7 44 24 0c 98 81 10 	movl   $0xf0108198,0xc(%esp)
f0100e06:	f0 
f0100e07:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100e0e:	f0 
f0100e0f:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0100e16:	00 
f0100e17:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100e1e:	e8 1d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e23:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e28:	75 24                	jne    f0100e4e <check_page_free_list+0x25b>
f0100e2a:	c7 44 24 0c b6 8a 10 	movl   $0xf0108ab6,0xc(%esp)
f0100e31:	f0 
f0100e32:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100e39:	f0 
f0100e3a:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0100e41:	00 
f0100e42:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100e49:	e8 f2 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e4e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e53:	76 59                	jbe    f0100eae <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e55:	89 c1                	mov    %eax,%ecx
f0100e57:	c1 e9 0c             	shr    $0xc,%ecx
f0100e5a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100e5d:	77 20                	ja     f0100e7f <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e63:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0100e6a:	f0 
f0100e6b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100e72:	00 
f0100e73:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0100e7a:	e8 c1 f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100e7f:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e85:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e88:	76 24                	jbe    f0100eae <check_page_free_list+0x2bb>
f0100e8a:	c7 44 24 0c bc 81 10 	movl   $0xf01081bc,0xc(%esp)
f0100e91:	f0 
f0100e92:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100e99:	f0 
f0100e9a:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f0100ea1:	00 
f0100ea2:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100ea9:	e8 92 f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100eae:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eb3:	75 24                	jne    f0100ed9 <check_page_free_list+0x2e6>
f0100eb5:	c7 44 24 0c d0 8a 10 	movl   $0xf0108ad0,0xc(%esp)
f0100ebc:	f0 
f0100ebd:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100ec4:	f0 
f0100ec5:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0100ecc:	00 
f0100ecd:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100ed4:	e8 67 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100ed9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ede:	77 03                	ja     f0100ee3 <check_page_free_list+0x2f0>
		  ++nfree_basemem;
f0100ee0:	46                   	inc    %esi
f0100ee1:	eb 01                	jmp    f0100ee4 <check_page_free_list+0x2f1>
		else
		  ++nfree_extmem;
f0100ee3:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
	  if (PDX(page2pa(pp)) < pdx_limit)
		memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ee4:	8b 12                	mov    (%edx),%edx
f0100ee6:	85 d2                	test   %edx,%edx
f0100ee8:	0f 85 34 fe ff ff    	jne    f0100d22 <check_page_free_list+0x12f>
		  ++nfree_basemem;
		else
		  ++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100eee:	85 f6                	test   %esi,%esi
f0100ef0:	7f 24                	jg     f0100f16 <check_page_free_list+0x323>
f0100ef2:	c7 44 24 0c ed 8a 10 	movl   $0xf0108aed,0xc(%esp)
f0100ef9:	f0 
f0100efa:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100f01:	f0 
f0100f02:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100f09:	00 
f0100f0a:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100f11:	e8 2a f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f16:	85 db                	test   %ebx,%ebx
f0100f18:	7f 24                	jg     f0100f3e <check_page_free_list+0x34b>
f0100f1a:	c7 44 24 0c ff 8a 10 	movl   $0xf0108aff,0xc(%esp)
f0100f21:	f0 
f0100f22:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0100f29:	f0 
f0100f2a:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0100f31:	00 
f0100f32:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0100f39:	e8 02 f1 ff ff       	call   f0100040 <_panic>
	
	//cprintf("check_page_free_list() succeeded!\n");
}
f0100f3e:	83 c4 4c             	add    $0x4c,%esp
f0100f41:	5b                   	pop    %ebx
f0100f42:	5e                   	pop    %esi
f0100f43:	5f                   	pop    %edi
f0100f44:	5d                   	pop    %ebp
f0100f45:	c3                   	ret    

f0100f46 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f46:	55                   	push   %ebp
f0100f47:	89 e5                	mov    %esp,%ebp
f0100f49:	57                   	push   %edi
f0100f4a:	56                   	push   %esi
f0100f4b:	53                   	push   %ebx
f0100f4c:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	uint32_t num_alloc = ((uint32_t)boot_alloc(0)-KERNBASE)/PGSIZE;
f0100f4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f54:	e8 ec fb ff ff       	call   f0100b45 <boot_alloc>
f0100f59:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f5e:	c1 e8 0c             	shr    $0xc,%eax
	size_t i;

	for(i = 0; i < npages; ++i) {
		if((i == 0)||
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100f61:	8b 0d 38 82 29 f0    	mov    0xf0298238,%ecx
f0100f67:	8d 59 60             	lea    0x60(%ecx),%ebx
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f6a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f6f:	ba 00 00 00 00       	mov    $0x0,%edx
		if((i == 0)||
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
					// alloc by kernel, kernel alloc pages and kern_pgdir on stack
					// num_alloc isn't all pages used, it is just memory used by kernel
					( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc )||(i == MPENTRY_PADDR/PGSIZE)){
f0100f74:	01 d8                	add    %ebx,%eax
f0100f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100f79:	eb 4a                	jmp    f0100fc5 <page_init+0x7f>
		if((i == 0)||
f0100f7b:	85 d2                	test   %edx,%edx
f0100f7d:	74 18                	je     f0100f97 <page_init+0x51>
f0100f7f:	39 ca                	cmp    %ecx,%edx
f0100f81:	72 06                	jb     f0100f89 <page_init+0x43>
					// io hole
					( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100f83:	39 da                	cmp    %ebx,%edx
f0100f85:	72 10                	jb     f0100f97 <page_init+0x51>
f0100f87:	eb 04                	jmp    f0100f8d <page_init+0x47>
f0100f89:	39 da                	cmp    %ebx,%edx
f0100f8b:	72 05                	jb     f0100f92 <page_init+0x4c>
					// alloc by kernel, kernel alloc pages and kern_pgdir on stack
					// num_alloc isn't all pages used, it is just memory used by kernel
					( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc )||(i == MPENTRY_PADDR/PGSIZE)){
f0100f8d:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100f90:	72 05                	jb     f0100f97 <page_init+0x51>
f0100f92:	83 fa 07             	cmp    $0x7,%edx
f0100f95:	75 0e                	jne    f0100fa5 <page_init+0x5f>
			pages[i].pp_ref = 1;	
f0100f97:	a1 9c 8e 29 f0       	mov    0xf0298e9c,%eax
f0100f9c:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
f0100fa3:	eb 1f                	jmp    f0100fc4 <page_init+0x7e>
		}else {
			pages[i].pp_ref = 0;
f0100fa5:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100fac:	8b 35 9c 8e 29 f0    	mov    0xf0298e9c,%esi
f0100fb2:	66 c7 44 06 04 00 00 	movw   $0x0,0x4(%esi,%eax,1)
			pages[i].pp_link = page_free_list;
f0100fb9:	89 3c 06             	mov    %edi,(%esi,%eax,1)
			page_free_list = &pages[i];
f0100fbc:	89 c7                	mov    %eax,%edi
f0100fbe:	03 3d 9c 8e 29 f0    	add    0xf0298e9c,%edi
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100fc4:	42                   	inc    %edx
f0100fc5:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0100fcb:	72 ae                	jb     f0100f7b <page_init+0x35>
f0100fcd:	89 3d 40 82 29 f0    	mov    %edi,0xf0298240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100fd3:	83 c4 1c             	add    $0x1c,%esp
f0100fd6:	5b                   	pop    %ebx
f0100fd7:	5e                   	pop    %esi
f0100fd8:	5f                   	pop    %edi
f0100fd9:	5d                   	pop    %ebp
f0100fda:	c3                   	ret    

f0100fdb <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fdb:	55                   	push   %ebp
f0100fdc:	89 e5                	mov    %esp,%ebp
f0100fde:	53                   	push   %ebx
f0100fdf:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo* temp_page;
	if (page_free_list) {
f0100fe2:	8b 1d 40 82 29 f0    	mov    0xf0298240,%ebx
f0100fe8:	85 db                	test   %ebx,%ebx
f0100fea:	0f 84 96 00 00 00    	je     f0101086 <page_alloc+0xab>
		temp_page = page_free_list;
		assert(temp_page->pp_ref == 0);
f0100ff0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100ff5:	74 24                	je     f010101b <page_alloc+0x40>
f0100ff7:	c7 44 24 0c 10 8b 10 	movl   $0xf0108b10,0xc(%esp)
f0100ffe:	f0 
f0100fff:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101006:	f0 
f0101007:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f010100e:	00 
f010100f:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101016:	e8 25 f0 ff ff       	call   f0100040 <_panic>
		page_free_list = page_free_list->pp_link;
f010101b:	8b 03                	mov    (%ebx),%eax
f010101d:	a3 40 82 29 f0       	mov    %eax,0xf0298240
		temp_page->pp_link = NULL;
f0101022:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	} else {
		return NULL;
	} 
	// temp_page is a Pageinfo, i think page2kva is actual page
	if (alloc_flags & ALLOC_ZERO) {
f0101028:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010102c:	74 58                	je     f0101086 <page_alloc+0xab>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010102e:	89 d8                	mov    %ebx,%eax
f0101030:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0101036:	c1 f8 03             	sar    $0x3,%eax
f0101039:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010103c:	89 c2                	mov    %eax,%edx
f010103e:	c1 ea 0c             	shr    $0xc,%edx
f0101041:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0101047:	72 20                	jb     f0101069 <page_alloc+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101049:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010104d:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0101054:	f0 
f0101055:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010105c:	00 
f010105d:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0101064:	e8 d7 ef ff ff       	call   f0100040 <_panic>
		memset(page2kva(temp_page), 0, PGSIZE); 
f0101069:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101070:	00 
f0101071:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101078:	00 
	return (void *)(pa + KERNBASE);
f0101079:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010107e:	89 04 24             	mov    %eax,(%esp)
f0101081:	e8 e8 51 00 00       	call   f010626e <memset>
	}

	return temp_page;
}
f0101086:	89 d8                	mov    %ebx,%eax
f0101088:	83 c4 14             	add    $0x14,%esp
f010108b:	5b                   	pop    %ebx
f010108c:	5d                   	pop    %ebp
f010108d:	c3                   	ret    

f010108e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010108e:	55                   	push   %ebp
f010108f:	89 e5                	mov    %esp,%ebp
f0101091:	83 ec 18             	sub    $0x18,%esp
f0101094:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f0101097:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010109c:	74 1c                	je     f01010ba <page_free+0x2c>
		panic("Still using page");
f010109e:	c7 44 24 08 27 8b 10 	movl   $0xf0108b27,0x8(%esp)
f01010a5:	f0 
f01010a6:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f01010ad:	00 
f01010ae:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01010b5:	e8 86 ef ff ff       	call   f0100040 <_panic>
	}
	if (pp->pp_link != NULL) {
f01010ba:	83 38 00             	cmpl   $0x0,(%eax)
f01010bd:	74 1c                	je     f01010db <page_free+0x4d>
		panic("free page still have a link");
f01010bf:	c7 44 24 08 38 8b 10 	movl   $0xf0108b38,0x8(%esp)
f01010c6:	f0 
f01010c7:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f01010ce:	00 
f01010cf:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01010d6:	e8 65 ef ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f01010db:	8b 15 40 82 29 f0    	mov    0xf0298240,%edx
f01010e1:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010e3:	a3 40 82 29 f0       	mov    %eax,0xf0298240
}
f01010e8:	c9                   	leave  
f01010e9:	c3                   	ret    

f01010ea <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01010ea:	55                   	push   %ebp
f01010eb:	89 e5                	mov    %esp,%ebp
f01010ed:	83 ec 18             	sub    $0x18,%esp
f01010f0:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01010f3:	8b 50 04             	mov    0x4(%eax),%edx
f01010f6:	4a                   	dec    %edx
f01010f7:	66 89 50 04          	mov    %dx,0x4(%eax)
f01010fb:	66 85 d2             	test   %dx,%dx
f01010fe:	75 08                	jne    f0101108 <page_decref+0x1e>
	  page_free(pp);
f0101100:	89 04 24             	mov    %eax,(%esp)
f0101103:	e8 86 ff ff ff       	call   f010108e <page_free>
}
f0101108:	c9                   	leave  
f0101109:	c3                   	ret    

f010110a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010110a:	55                   	push   %ebp
f010110b:	89 e5                	mov    %esp,%ebp
f010110d:	57                   	push   %edi
f010110e:	56                   	push   %esi
f010110f:	53                   	push   %ebx
f0101110:	83 ec 1c             	sub    $0x1c,%esp
f0101113:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pde_t* pgdir_entry = &pgdir[PDX(va)];
f0101116:	89 fb                	mov    %edi,%ebx
f0101118:	c1 eb 16             	shr    $0x16,%ebx
f010111b:	c1 e3 02             	shl    $0x2,%ebx
f010111e:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pgtb_entry = NULL;
	struct PageInfo * pg = NULL;

	if (!(*pgdir_entry & PTE_P)){
f0101121:	f6 03 01             	testb  $0x1,(%ebx)
f0101124:	0f 85 8b 00 00 00    	jne    f01011b5 <pgdir_walk+0xab>
		if(create){
f010112a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010112e:	0f 84 c7 00 00 00    	je     f01011fb <pgdir_walk+0xf1>
			pg = page_alloc(1);
f0101134:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010113b:	e8 9b fe ff ff       	call   f0100fdb <page_alloc>
f0101140:	89 c6                	mov    %eax,%esi
			if (!pg) 
f0101142:	85 c0                	test   %eax,%eax
f0101144:	0f 84 b8 00 00 00    	je     f0101202 <pgdir_walk+0xf8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010114a:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0101150:	c1 f8 03             	sar    $0x3,%eax
f0101153:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101156:	89 c2                	mov    %eax,%edx
f0101158:	c1 ea 0c             	shr    $0xc,%edx
f010115b:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0101161:	72 20                	jb     f0101183 <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101163:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101167:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f010116e:	f0 
f010116f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101176:	00 
f0101177:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f010117e:	e8 bd ee ff ff       	call   f0100040 <_panic>
			  return NULL;
			memset(page2kva(pg), 0, PGSIZE);
f0101183:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010118a:	00 
f010118b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101192:	00 
	return (void *)(pa + KERNBASE);
f0101193:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101198:	89 04 24             	mov    %eax,(%esp)
f010119b:	e8 ce 50 00 00       	call   f010626e <memset>
			pg->pp_ref += 1;
f01011a0:	66 ff 46 04          	incw   0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011a4:	2b 35 9c 8e 29 f0    	sub    0xf0298e9c,%esi
f01011aa:	c1 fe 03             	sar    $0x3,%esi
f01011ad:	c1 e6 0c             	shl    $0xc,%esi
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
f01011b0:	83 ce 07             	or     $0x7,%esi
f01011b3:	89 33                	mov    %esi,(%ebx)
		}else{
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
f01011b5:	8b 03                	mov    (%ebx),%eax
f01011b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011bc:	89 c2                	mov    %eax,%edx
f01011be:	c1 ea 0c             	shr    $0xc,%edx
f01011c1:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f01011c7:	72 20                	jb     f01011e9 <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011cd:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01011d4:	f0 
f01011d5:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f01011dc:	00 
f01011dd:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01011e4:	e8 57 ee ff ff       	call   f0100040 <_panic>
	return &pgtb_entry[PTX(va)];
f01011e9:	c1 ef 0a             	shr    $0xa,%edi
f01011ec:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01011f2:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
f01011f9:	eb 0c                	jmp    f0101207 <pgdir_walk+0xfd>
			  return NULL;
			memset(page2kva(pg), 0, PGSIZE);
			pg->pp_ref += 1;
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
		}else{
			return NULL;
f01011fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101200:	eb 05                	jmp    f0101207 <pgdir_walk+0xfd>

	if (!(*pgdir_entry & PTE_P)){
		if(create){
			pg = page_alloc(1);
			if (!pg) 
			  return NULL;
f0101202:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
	return &pgtb_entry[PTX(va)];
}
f0101207:	83 c4 1c             	add    $0x1c,%esp
f010120a:	5b                   	pop    %ebx
f010120b:	5e                   	pop    %esi
f010120c:	5f                   	pop    %edi
f010120d:	5d                   	pop    %ebp
f010120e:	c3                   	ret    

f010120f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010120f:	55                   	push   %ebp
f0101210:	89 e5                	mov    %esp,%ebp
f0101212:	57                   	push   %edi
f0101213:	56                   	push   %esi
f0101214:	53                   	push   %ebx
f0101215:	83 ec 2c             	sub    $0x2c,%esp
f0101218:	89 c7                	mov    %eax,%edi
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f010121a:	c1 e9 0c             	shr    $0xc,%ecx
f010121d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101220:	89 d3                	mov    %edx,%ebx
f0101222:	be 00 00 00 00       	mov    $0x0,%esi
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0101227:	8b 45 0c             	mov    0xc(%ebp),%eax
f010122a:	83 c8 01             	or     $0x1,%eax
f010122d:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101230:	8b 45 08             	mov    0x8(%ebp),%eax
f0101233:	29 d0                	sub    %edx,%eax
f0101235:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0101238:	eb 25                	jmp    f010125f <boot_map_region+0x50>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
f010123a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101241:	00 
f0101242:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101246:	89 3c 24             	mov    %edi,(%esp)
f0101249:	e8 bc fe ff ff       	call   f010110a <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f010124e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101251:	01 da                	add    %ebx,%edx
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0101253:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101256:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0101258:	46                   	inc    %esi
f0101259:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010125f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101262:	75 d6                	jne    f010123a <boot_map_region+0x2b>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
	} 
}
f0101264:	83 c4 2c             	add    $0x2c,%esp
f0101267:	5b                   	pop    %ebx
f0101268:	5e                   	pop    %esi
f0101269:	5f                   	pop    %edi
f010126a:	5d                   	pop    %ebp
f010126b:	c3                   	ret    

f010126c <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010126c:	55                   	push   %ebp
f010126d:	89 e5                	mov    %esp,%ebp
f010126f:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f0101272:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101279:	00 
f010127a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010127d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101281:	8b 45 08             	mov    0x8(%ebp),%eax
f0101284:	89 04 24             	mov    %eax,(%esp)
f0101287:	e8 7e fe ff ff       	call   f010110a <pgdir_walk>
	if (pt_entry && *pt_entry&PTE_P) {
f010128c:	85 c0                	test   %eax,%eax
f010128e:	74 3e                	je     f01012ce <page_lookup+0x62>
f0101290:	f6 00 01             	testb  $0x1,(%eax)
f0101293:	74 40                	je     f01012d5 <page_lookup+0x69>
		*pte_store = pt_entry;
f0101295:	8b 55 10             	mov    0x10(%ebp),%edx
f0101298:	89 02                	mov    %eax,(%edx)
	}else{
		return NULL;
	}
	return pa2page(PTE_ADDR(*pt_entry));
f010129a:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010129c:	c1 e8 0c             	shr    $0xc,%eax
f010129f:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f01012a5:	72 1c                	jb     f01012c3 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f01012a7:	c7 44 24 08 04 82 10 	movl   $0xf0108204,0x8(%esp)
f01012ae:	f0 
f01012af:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01012b6:	00 
f01012b7:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f01012be:	e8 7d ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01012c3:	c1 e0 03             	shl    $0x3,%eax
f01012c6:	03 05 9c 8e 29 f0    	add    0xf0298e9c,%eax
f01012cc:	eb 0c                	jmp    f01012da <page_lookup+0x6e>
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
	if (pt_entry && *pt_entry&PTE_P) {
		*pte_store = pt_entry;
	}else{
		return NULL;
f01012ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d3:	eb 05                	jmp    f01012da <page_lookup+0x6e>
f01012d5:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return pa2page(PTE_ADDR(*pt_entry));
}
f01012da:	c9                   	leave  
f01012db:	c3                   	ret    

f01012dc <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012dc:	55                   	push   %ebp
f01012dd:	89 e5                	mov    %esp,%ebp
f01012df:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012e2:	e8 b5 55 00 00       	call   f010689c <cpunum>
f01012e7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01012ee:	29 c2                	sub    %eax,%edx
f01012f0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01012f3:	83 3c 85 28 90 29 f0 	cmpl   $0x0,-0xfd66fd8(,%eax,4)
f01012fa:	00 
f01012fb:	74 20                	je     f010131d <tlb_invalidate+0x41>
f01012fd:	e8 9a 55 00 00       	call   f010689c <cpunum>
f0101302:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101309:	29 c2                	sub    %eax,%edx
f010130b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010130e:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0101315:	8b 55 08             	mov    0x8(%ebp),%edx
f0101318:	39 50 60             	cmp    %edx,0x60(%eax)
f010131b:	75 06                	jne    f0101323 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010131d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101320:	0f 01 38             	invlpg (%eax)
	  invlpg(va);
}
f0101323:	c9                   	leave  
f0101324:	c3                   	ret    

f0101325 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101325:	55                   	push   %ebp
f0101326:	89 e5                	mov    %esp,%ebp
f0101328:	56                   	push   %esi
f0101329:	53                   	push   %ebx
f010132a:	83 ec 20             	sub    $0x20,%esp
f010132d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte_store = NULL;
f0101333:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg = page_lookup(pgdir, va, &pte_store); 
f010133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010133d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101341:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101345:	89 34 24             	mov    %esi,(%esp)
f0101348:	e8 1f ff ff ff       	call   f010126c <page_lookup>
	if (!pg) 
f010134d:	85 c0                	test   %eax,%eax
f010134f:	74 1d                	je     f010136e <page_remove+0x49>
	  return;
	page_decref(pg);	
f0101351:	89 04 24             	mov    %eax,(%esp)
f0101354:	e8 91 fd ff ff       	call   f01010ea <page_decref>
	tlb_invalidate(pgdir, va);
f0101359:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010135d:	89 34 24             	mov    %esi,(%esp)
f0101360:	e8 77 ff ff ff       	call   f01012dc <tlb_invalidate>
	*pte_store = 0;
f0101365:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101368:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010136e:	83 c4 20             	add    $0x20,%esp
f0101371:	5b                   	pop    %ebx
f0101372:	5e                   	pop    %esi
f0101373:	5d                   	pop    %ebp
f0101374:	c3                   	ret    

f0101375 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101375:	55                   	push   %ebp
f0101376:	89 e5                	mov    %esp,%ebp
f0101378:	57                   	push   %edi
f0101379:	56                   	push   %esi
f010137a:	53                   	push   %ebx
f010137b:	83 ec 1c             	sub    $0x1c,%esp
f010137e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101381:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f0101384:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010138b:	00 
f010138c:	8b 45 10             	mov    0x10(%ebp),%eax
f010138f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101393:	89 34 24             	mov    %esi,(%esp)
f0101396:	e8 6f fd ff ff       	call   f010110a <pgdir_walk>
f010139b:	89 c3                	mov    %eax,%ebx
	if (!pg_entry) {
f010139d:	85 c0                	test   %eax,%eax
f010139f:	74 4d                	je     f01013ee <page_insert+0x79>
		return -E_NO_MEM;
	} 
	pp->pp_ref++;
f01013a1:	66 ff 47 04          	incw   0x4(%edi)
	if (*pg_entry & PTE_P){
f01013a5:	f6 00 01             	testb  $0x1,(%eax)
f01013a8:	74 1e                	je     f01013c8 <page_insert+0x53>
		tlb_invalidate(pgdir, va);
f01013aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01013ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013b1:	89 34 24             	mov    %esi,(%esp)
f01013b4:	e8 23 ff ff ff       	call   f01012dc <tlb_invalidate>
		page_remove(pgdir, va);
f01013b9:	8b 45 10             	mov    0x10(%ebp),%eax
f01013bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013c0:	89 34 24             	mov    %esi,(%esp)
f01013c3:	e8 5d ff ff ff       	call   f0101325 <page_remove>
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
f01013c8:	8b 55 14             	mov    0x14(%ebp),%edx
f01013cb:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ce:	2b 3d 9c 8e 29 f0    	sub    0xf0298e9c,%edi
f01013d4:	c1 ff 03             	sar    $0x3,%edi
f01013d7:	c1 e7 0c             	shl    $0xc,%edi
f01013da:	09 d7                	or     %edx,%edi
f01013dc:	89 3b                	mov    %edi,(%ebx)
	pgdir[PDX(va)] |= perm | PTE_P;	
f01013de:	8b 45 10             	mov    0x10(%ebp),%eax
f01013e1:	c1 e8 16             	shr    $0x16,%eax
f01013e4:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f01013e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ec:	eb 05                	jmp    f01013f3 <page_insert+0x7e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
	if (!pg_entry) {
		return -E_NO_MEM;
f01013ee:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
	pgdir[PDX(va)] |= perm | PTE_P;	
	return 0;
}
f01013f3:	83 c4 1c             	add    $0x1c,%esp
f01013f6:	5b                   	pop    %ebx
f01013f7:	5e                   	pop    %esi
f01013f8:	5f                   	pop    %edi
f01013f9:	5d                   	pop    %ebp
f01013fa:	c3                   	ret    

f01013fb <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013fb:	55                   	push   %ebp
f01013fc:	89 e5                	mov    %esp,%ebp
f01013fe:	56                   	push   %esi
f01013ff:	53                   	push   %ebx
f0101400:	83 ec 10             	sub    $0x10,%esp
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	//panic("mmio_map_region not implemented");
	void* ret = (void*)base;
f0101403:	8b 1d 00 d3 12 f0    	mov    0xf012d300,%ebx
	uint32_t round_size = ROUNDUP(size, PGSIZE); 
f0101409:	8b 75 0c             	mov    0xc(%ebp),%esi
f010140c:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0101412:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (base + round_size >= MMIOLIM){
f0101418:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010141b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101420:	76 1c                	jbe    f010143e <mmio_map_region+0x43>
		panic("mmio_map_region: map overflow");
f0101422:	c7 44 24 08 54 8b 10 	movl   $0xf0108b54,0x8(%esp)
f0101429:	f0 
f010142a:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0101431:	00 
f0101432:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101439:	e8 02 ec ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, round_size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010143e:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101445:	00 
f0101446:	8b 45 08             	mov    0x8(%ebp),%eax
f0101449:	89 04 24             	mov    %eax,(%esp)
f010144c:	89 f1                	mov    %esi,%ecx
f010144e:	89 da                	mov    %ebx,%edx
f0101450:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101455:	e8 b5 fd ff ff       	call   f010120f <boot_map_region>
	base+=round_size;
f010145a:	01 35 00 d3 12 f0    	add    %esi,0xf012d300
	return ret;

}
f0101460:	89 d8                	mov    %ebx,%eax
f0101462:	83 c4 10             	add    $0x10,%esp
f0101465:	5b                   	pop    %ebx
f0101466:	5e                   	pop    %esi
f0101467:	5d                   	pop    %ebp
f0101468:	c3                   	ret    

f0101469 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101469:	55                   	push   %ebp
f010146a:	89 e5                	mov    %esp,%ebp
f010146c:	57                   	push   %edi
f010146d:	56                   	push   %esi
f010146e:	53                   	push   %ebx
f010146f:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101472:	b8 15 00 00 00       	mov    $0x15,%eax
f0101477:	e8 4e f7 ff ff       	call   f0100bca <nvram_read>
f010147c:	c1 e0 0a             	shl    $0xa,%eax
f010147f:	89 c2                	mov    %eax,%edx
f0101481:	85 c0                	test   %eax,%eax
f0101483:	79 06                	jns    f010148b <mem_init+0x22>
f0101485:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010148b:	c1 fa 0c             	sar    $0xc,%edx
f010148e:	89 15 38 82 29 f0    	mov    %edx,0xf0298238
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101494:	b8 17 00 00 00       	mov    $0x17,%eax
f0101499:	e8 2c f7 ff ff       	call   f0100bca <nvram_read>
f010149e:	89 c2                	mov    %eax,%edx
f01014a0:	c1 e2 0a             	shl    $0xa,%edx
f01014a3:	89 d0                	mov    %edx,%eax
f01014a5:	85 d2                	test   %edx,%edx
f01014a7:	79 06                	jns    f01014af <mem_init+0x46>
f01014a9:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01014af:	c1 f8 0c             	sar    $0xc,%eax
f01014b2:	74 0e                	je     f01014c2 <mem_init+0x59>
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01014b4:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01014ba:	89 15 94 8e 29 f0    	mov    %edx,0xf0298e94
f01014c0:	eb 0c                	jmp    f01014ce <mem_init+0x65>
	else
	  npages = npages_basemem;
f01014c2:	8b 15 38 82 29 f0    	mov    0xf0298238,%edx
f01014c8:	89 15 94 8e 29 f0    	mov    %edx,0xf0298e94

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
				npages * PGSIZE / 1024,
				npages_basemem * PGSIZE / 1024,
				npages_extmem * PGSIZE / 1024);
f01014ce:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014d1:	c1 e8 0a             	shr    $0xa,%eax
f01014d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
				npages * PGSIZE / 1024,
				npages_basemem * PGSIZE / 1024,
f01014d8:	a1 38 82 29 f0       	mov    0xf0298238,%eax
f01014dd:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014e0:	c1 e8 0a             	shr    $0xa,%eax
f01014e3:	89 44 24 08          	mov    %eax,0x8(%esp)
				npages * PGSIZE / 1024,
f01014e7:	a1 94 8e 29 f0       	mov    0xf0298e94,%eax
f01014ec:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
	  npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
	  npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ef:	c1 e8 0a             	shr    $0xa,%eax
f01014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014f6:	c7 04 24 24 82 10 f0 	movl   $0xf0108224,(%esp)
f01014fd:	e8 2c 2a 00 00       	call   f0103f2e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101502:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101507:	e8 39 f6 ff ff       	call   f0100b45 <boot_alloc>
f010150c:	a3 98 8e 29 f0       	mov    %eax,0xf0298e98
	memset(kern_pgdir, 0, PGSIZE);
f0101511:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101518:	00 
f0101519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101520:	00 
f0101521:	89 04 24             	mov    %eax,(%esp)
f0101524:	e8 45 4d 00 00       	call   f010626e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101529:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010152e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101533:	77 20                	ja     f0101555 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101535:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101539:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0101540:	f0 
f0101541:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f0101548:	00 
f0101549:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101550:	e8 eb ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101555:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010155b:	83 ca 05             	or     $0x5,%edx
f010155e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f0101564:	a1 94 8e 29 f0       	mov    0xf0298e94,%eax
f0101569:	c1 e0 03             	shl    $0x3,%eax
f010156c:	e8 d4 f5 ff ff       	call   f0100b45 <boot_alloc>
f0101571:	a3 9c 8e 29 f0       	mov    %eax,0xf0298e9c
	memset(pages, 0, sizeof(struct PageInfo)*npages); 
f0101576:	8b 15 94 8e 29 f0    	mov    0xf0298e94,%edx
f010157c:	c1 e2 03             	shl    $0x3,%edx
f010157f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101583:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010158a:	00 
f010158b:	89 04 24             	mov    %eax,(%esp)
f010158e:	e8 db 4c 00 00       	call   f010626e <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f0101593:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101598:	e8 a8 f5 ff ff       	call   f0100b45 <boot_alloc>
f010159d:	a3 48 82 29 f0       	mov    %eax,0xf0298248
	memset(envs, 0, sizeof(struct Env)*NENV);
f01015a2:	c7 44 24 08 00 00 02 	movl   $0x20000,0x8(%esp)
f01015a9:	00 
f01015aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015b1:	00 
f01015b2:	89 04 24             	mov    %eax,(%esp)
f01015b5:	e8 b4 4c 00 00       	call   f010626e <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015ba:	e8 87 f9 ff ff       	call   f0100f46 <page_init>

	check_page_free_list(1);
f01015bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01015c4:	e8 2a f6 ff ff       	call   f0100bf3 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015c9:	83 3d 9c 8e 29 f0 00 	cmpl   $0x0,0xf0298e9c
f01015d0:	75 1c                	jne    f01015ee <mem_init+0x185>
	  panic("'pages' is a null pointer!");
f01015d2:	c7 44 24 08 72 8b 10 	movl   $0xf0108b72,0x8(%esp)
f01015d9:	f0 
f01015da:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f01015e1:	00 
f01015e2:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01015e9:	e8 52 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015ee:	a1 40 82 29 f0       	mov    0xf0298240,%eax
f01015f3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015f8:	eb 03                	jmp    f01015fd <mem_init+0x194>
	  ++nfree;
f01015fa:	43                   	inc    %ebx

	if (!pages)
	  panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015fb:	8b 00                	mov    (%eax),%eax
f01015fd:	85 c0                	test   %eax,%eax
f01015ff:	75 f9                	jne    f01015fa <mem_init+0x191>
	  ++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101608:	e8 ce f9 ff ff       	call   f0100fdb <page_alloc>
f010160d:	89 c6                	mov    %eax,%esi
f010160f:	85 c0                	test   %eax,%eax
f0101611:	75 24                	jne    f0101637 <mem_init+0x1ce>
f0101613:	c7 44 24 0c 8d 8b 10 	movl   $0xf0108b8d,0xc(%esp)
f010161a:	f0 
f010161b:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101622:	f0 
f0101623:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010162a:	00 
f010162b:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101632:	e8 09 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101637:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010163e:	e8 98 f9 ff ff       	call   f0100fdb <page_alloc>
f0101643:	89 c7                	mov    %eax,%edi
f0101645:	85 c0                	test   %eax,%eax
f0101647:	75 24                	jne    f010166d <mem_init+0x204>
f0101649:	c7 44 24 0c a3 8b 10 	movl   $0xf0108ba3,0xc(%esp)
f0101650:	f0 
f0101651:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101658:	f0 
f0101659:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f0101660:	00 
f0101661:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101668:	e8 d3 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010166d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101674:	e8 62 f9 ff ff       	call   f0100fdb <page_alloc>
f0101679:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010167c:	85 c0                	test   %eax,%eax
f010167e:	75 24                	jne    f01016a4 <mem_init+0x23b>
f0101680:	c7 44 24 0c b9 8b 10 	movl   $0xf0108bb9,0xc(%esp)
f0101687:	f0 
f0101688:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010168f:	f0 
f0101690:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101697:	00 
f0101698:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010169f:	e8 9c e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016a4:	39 fe                	cmp    %edi,%esi
f01016a6:	75 24                	jne    f01016cc <mem_init+0x263>
f01016a8:	c7 44 24 0c cf 8b 10 	movl   $0xf0108bcf,0xc(%esp)
f01016af:	f0 
f01016b0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01016b7:	f0 
f01016b8:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f01016bf:	00 
f01016c0:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01016c7:	e8 74 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016cc:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01016cf:	74 05                	je     f01016d6 <mem_init+0x26d>
f01016d1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01016d4:	75 24                	jne    f01016fa <mem_init+0x291>
f01016d6:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f01016dd:	f0 
f01016de:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01016e5:	f0 
f01016e6:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f01016ed:	00 
f01016ee:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01016f5:	e8 46 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016fa:	8b 15 9c 8e 29 f0    	mov    0xf0298e9c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101700:	a1 94 8e 29 f0       	mov    0xf0298e94,%eax
f0101705:	c1 e0 0c             	shl    $0xc,%eax
f0101708:	89 f1                	mov    %esi,%ecx
f010170a:	29 d1                	sub    %edx,%ecx
f010170c:	c1 f9 03             	sar    $0x3,%ecx
f010170f:	c1 e1 0c             	shl    $0xc,%ecx
f0101712:	39 c1                	cmp    %eax,%ecx
f0101714:	72 24                	jb     f010173a <mem_init+0x2d1>
f0101716:	c7 44 24 0c e1 8b 10 	movl   $0xf0108be1,0xc(%esp)
f010171d:	f0 
f010171e:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101725:	f0 
f0101726:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f010172d:	00 
f010172e:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101735:	e8 06 e9 ff ff       	call   f0100040 <_panic>
f010173a:	89 f9                	mov    %edi,%ecx
f010173c:	29 d1                	sub    %edx,%ecx
f010173e:	c1 f9 03             	sar    $0x3,%ecx
f0101741:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101744:	39 c8                	cmp    %ecx,%eax
f0101746:	77 24                	ja     f010176c <mem_init+0x303>
f0101748:	c7 44 24 0c fe 8b 10 	movl   $0xf0108bfe,0xc(%esp)
f010174f:	f0 
f0101750:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101757:	f0 
f0101758:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f010175f:	00 
f0101760:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101767:	e8 d4 e8 ff ff       	call   f0100040 <_panic>
f010176c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010176f:	29 d1                	sub    %edx,%ecx
f0101771:	89 ca                	mov    %ecx,%edx
f0101773:	c1 fa 03             	sar    $0x3,%edx
f0101776:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101779:	39 d0                	cmp    %edx,%eax
f010177b:	77 24                	ja     f01017a1 <mem_init+0x338>
f010177d:	c7 44 24 0c 1b 8c 10 	movl   $0xf0108c1b,0xc(%esp)
f0101784:	f0 
f0101785:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010178c:	f0 
f010178d:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0101794:	00 
f0101795:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010179c:	e8 9f e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017a1:	a1 40 82 29 f0       	mov    0xf0298240,%eax
f01017a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017a9:	c7 05 40 82 29 f0 00 	movl   $0x0,0xf0298240
f01017b0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ba:	e8 1c f8 ff ff       	call   f0100fdb <page_alloc>
f01017bf:	85 c0                	test   %eax,%eax
f01017c1:	74 24                	je     f01017e7 <mem_init+0x37e>
f01017c3:	c7 44 24 0c 38 8c 10 	movl   $0xf0108c38,0xc(%esp)
f01017ca:	f0 
f01017cb:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01017d2:	f0 
f01017d3:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f01017da:	00 
f01017db:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01017e2:	e8 59 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01017e7:	89 34 24             	mov    %esi,(%esp)
f01017ea:	e8 9f f8 ff ff       	call   f010108e <page_free>
	page_free(pp1);
f01017ef:	89 3c 24             	mov    %edi,(%esp)
f01017f2:	e8 97 f8 ff ff       	call   f010108e <page_free>
	page_free(pp2);
f01017f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017fa:	89 04 24             	mov    %eax,(%esp)
f01017fd:	e8 8c f8 ff ff       	call   f010108e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101809:	e8 cd f7 ff ff       	call   f0100fdb <page_alloc>
f010180e:	89 c6                	mov    %eax,%esi
f0101810:	85 c0                	test   %eax,%eax
f0101812:	75 24                	jne    f0101838 <mem_init+0x3cf>
f0101814:	c7 44 24 0c 8d 8b 10 	movl   $0xf0108b8d,0xc(%esp)
f010181b:	f0 
f010181c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101823:	f0 
f0101824:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f010182b:	00 
f010182c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101833:	e8 08 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101838:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010183f:	e8 97 f7 ff ff       	call   f0100fdb <page_alloc>
f0101844:	89 c7                	mov    %eax,%edi
f0101846:	85 c0                	test   %eax,%eax
f0101848:	75 24                	jne    f010186e <mem_init+0x405>
f010184a:	c7 44 24 0c a3 8b 10 	movl   $0xf0108ba3,0xc(%esp)
f0101851:	f0 
f0101852:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101859:	f0 
f010185a:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101861:	00 
f0101862:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101869:	e8 d2 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010186e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101875:	e8 61 f7 ff ff       	call   f0100fdb <page_alloc>
f010187a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010187d:	85 c0                	test   %eax,%eax
f010187f:	75 24                	jne    f01018a5 <mem_init+0x43c>
f0101881:	c7 44 24 0c b9 8b 10 	movl   $0xf0108bb9,0xc(%esp)
f0101888:	f0 
f0101889:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101890:	f0 
f0101891:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101898:	00 
f0101899:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01018a0:	e8 9b e7 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018a5:	39 fe                	cmp    %edi,%esi
f01018a7:	75 24                	jne    f01018cd <mem_init+0x464>
f01018a9:	c7 44 24 0c cf 8b 10 	movl   $0xf0108bcf,0xc(%esp)
f01018b0:	f0 
f01018b1:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01018b8:	f0 
f01018b9:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f01018c0:	00 
f01018c1:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01018c8:	e8 73 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018cd:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01018d0:	74 05                	je     f01018d7 <mem_init+0x46e>
f01018d2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018d5:	75 24                	jne    f01018fb <mem_init+0x492>
f01018d7:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f01018de:	f0 
f01018df:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01018e6:	f0 
f01018e7:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f01018ee:	00 
f01018ef:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01018f6:	e8 45 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101902:	e8 d4 f6 ff ff       	call   f0100fdb <page_alloc>
f0101907:	85 c0                	test   %eax,%eax
f0101909:	74 24                	je     f010192f <mem_init+0x4c6>
f010190b:	c7 44 24 0c 38 8c 10 	movl   $0xf0108c38,0xc(%esp)
f0101912:	f0 
f0101913:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010191a:	f0 
f010191b:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101922:	00 
f0101923:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010192a:	e8 11 e7 ff ff       	call   f0100040 <_panic>
f010192f:	89 f0                	mov    %esi,%eax
f0101931:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0101937:	c1 f8 03             	sar    $0x3,%eax
f010193a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010193d:	89 c2                	mov    %eax,%edx
f010193f:	c1 ea 0c             	shr    $0xc,%edx
f0101942:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0101948:	72 20                	jb     f010196a <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010194a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010194e:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0101955:	f0 
f0101956:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010195d:	00 
f010195e:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0101965:	e8 d6 e6 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010196a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101971:	00 
f0101972:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101979:	00 
	return (void *)(pa + KERNBASE);
f010197a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010197f:	89 04 24             	mov    %eax,(%esp)
f0101982:	e8 e7 48 00 00       	call   f010626e <memset>
	page_free(pp0);
f0101987:	89 34 24             	mov    %esi,(%esp)
f010198a:	e8 ff f6 ff ff       	call   f010108e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010198f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101996:	e8 40 f6 ff ff       	call   f0100fdb <page_alloc>
f010199b:	85 c0                	test   %eax,%eax
f010199d:	75 24                	jne    f01019c3 <mem_init+0x55a>
f010199f:	c7 44 24 0c 47 8c 10 	movl   $0xf0108c47,0xc(%esp)
f01019a6:	f0 
f01019a7:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01019ae:	f0 
f01019af:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f01019b6:	00 
f01019b7:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01019be:	e8 7d e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01019c3:	39 c6                	cmp    %eax,%esi
f01019c5:	74 24                	je     f01019eb <mem_init+0x582>
f01019c7:	c7 44 24 0c 65 8c 10 	movl   $0xf0108c65,0xc(%esp)
f01019ce:	f0 
f01019cf:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01019d6:	f0 
f01019d7:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f01019de:	00 
f01019df:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01019e6:	e8 55 e6 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019eb:	89 f2                	mov    %esi,%edx
f01019ed:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f01019f3:	c1 fa 03             	sar    $0x3,%edx
f01019f6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019f9:	89 d0                	mov    %edx,%eax
f01019fb:	c1 e8 0c             	shr    $0xc,%eax
f01019fe:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f0101a04:	72 20                	jb     f0101a26 <mem_init+0x5bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a06:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a0a:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0101a11:	f0 
f0101a12:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a19:	00 
f0101a1a:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0101a21:	e8 1a e6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101a26:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101a2c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
	  assert(c[i] == 0);
f0101a32:	80 38 00             	cmpb   $0x0,(%eax)
f0101a35:	74 24                	je     f0101a5b <mem_init+0x5f2>
f0101a37:	c7 44 24 0c 75 8c 10 	movl   $0xf0108c75,0xc(%esp)
f0101a3e:	f0 
f0101a3f:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101a46:	f0 
f0101a47:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101a4e:	00 
f0101a4f:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101a56:	e8 e5 e5 ff ff       	call   f0100040 <_panic>
f0101a5b:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101a5c:	39 d0                	cmp    %edx,%eax
f0101a5e:	75 d2                	jne    f0101a32 <mem_init+0x5c9>
	  assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101a60:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101a63:	89 15 40 82 29 f0    	mov    %edx,0xf0298240

	// free the pages we took
	page_free(pp0);
f0101a69:	89 34 24             	mov    %esi,(%esp)
f0101a6c:	e8 1d f6 ff ff       	call   f010108e <page_free>
	page_free(pp1);
f0101a71:	89 3c 24             	mov    %edi,(%esp)
f0101a74:	e8 15 f6 ff ff       	call   f010108e <page_free>
	page_free(pp2);
f0101a79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a7c:	89 04 24             	mov    %eax,(%esp)
f0101a7f:	e8 0a f6 ff ff       	call   f010108e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a84:	a1 40 82 29 f0       	mov    0xf0298240,%eax
f0101a89:	eb 03                	jmp    f0101a8e <mem_init+0x625>
	  --nfree;
f0101a8b:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a8c:	8b 00                	mov    (%eax),%eax
f0101a8e:	85 c0                	test   %eax,%eax
f0101a90:	75 f9                	jne    f0101a8b <mem_init+0x622>
	  --nfree;
	assert(nfree == 0);
f0101a92:	85 db                	test   %ebx,%ebx
f0101a94:	74 24                	je     f0101aba <mem_init+0x651>
f0101a96:	c7 44 24 0c 7f 8c 10 	movl   $0xf0108c7f,0xc(%esp)
f0101a9d:	f0 
f0101a9e:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101aa5:	f0 
f0101aa6:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101aad:	00 
f0101aae:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101ab5:	e8 86 e5 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101aba:	c7 04 24 80 82 10 f0 	movl   $0xf0108280,(%esp)
f0101ac1:	e8 68 24 00 00       	call   f0103f2e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ac6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101acd:	e8 09 f5 ff ff       	call   f0100fdb <page_alloc>
f0101ad2:	89 c7                	mov    %eax,%edi
f0101ad4:	85 c0                	test   %eax,%eax
f0101ad6:	75 24                	jne    f0101afc <mem_init+0x693>
f0101ad8:	c7 44 24 0c 8d 8b 10 	movl   $0xf0108b8d,0xc(%esp)
f0101adf:	f0 
f0101ae0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101ae7:	f0 
f0101ae8:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0101aef:	00 
f0101af0:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101af7:	e8 44 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101afc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b03:	e8 d3 f4 ff ff       	call   f0100fdb <page_alloc>
f0101b08:	89 c6                	mov    %eax,%esi
f0101b0a:	85 c0                	test   %eax,%eax
f0101b0c:	75 24                	jne    f0101b32 <mem_init+0x6c9>
f0101b0e:	c7 44 24 0c a3 8b 10 	movl   $0xf0108ba3,0xc(%esp)
f0101b15:	f0 
f0101b16:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101b1d:	f0 
f0101b1e:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101b25:	00 
f0101b26:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101b2d:	e8 0e e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b39:	e8 9d f4 ff ff       	call   f0100fdb <page_alloc>
f0101b3e:	89 c3                	mov    %eax,%ebx
f0101b40:	85 c0                	test   %eax,%eax
f0101b42:	75 24                	jne    f0101b68 <mem_init+0x6ff>
f0101b44:	c7 44 24 0c b9 8b 10 	movl   $0xf0108bb9,0xc(%esp)
f0101b4b:	f0 
f0101b4c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101b53:	f0 
f0101b54:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101b5b:	00 
f0101b5c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101b63:	e8 d8 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b68:	39 f7                	cmp    %esi,%edi
f0101b6a:	75 24                	jne    f0101b90 <mem_init+0x727>
f0101b6c:	c7 44 24 0c cf 8b 10 	movl   $0xf0108bcf,0xc(%esp)
f0101b73:	f0 
f0101b74:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101b7b:	f0 
f0101b7c:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0101b83:	00 
f0101b84:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101b8b:	e8 b0 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b90:	39 c6                	cmp    %eax,%esi
f0101b92:	74 04                	je     f0101b98 <mem_init+0x72f>
f0101b94:	39 c7                	cmp    %eax,%edi
f0101b96:	75 24                	jne    f0101bbc <mem_init+0x753>
f0101b98:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f0101b9f:	f0 
f0101ba0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101baf:	00 
f0101bb0:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101bb7:	e8 84 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bbc:	8b 15 40 82 29 f0    	mov    0xf0298240,%edx
f0101bc2:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101bc5:	c7 05 40 82 29 f0 00 	movl   $0x0,0xf0298240
f0101bcc:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bd6:	e8 00 f4 ff ff       	call   f0100fdb <page_alloc>
f0101bdb:	85 c0                	test   %eax,%eax
f0101bdd:	74 24                	je     f0101c03 <mem_init+0x79a>
f0101bdf:	c7 44 24 0c 38 8c 10 	movl   $0xf0108c38,0xc(%esp)
f0101be6:	f0 
f0101be7:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101bee:	f0 
f0101bef:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0101bf6:	00 
f0101bf7:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101bfe:	e8 3d e4 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c06:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c11:	00 
f0101c12:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101c17:	89 04 24             	mov    %eax,(%esp)
f0101c1a:	e8 4d f6 ff ff       	call   f010126c <page_lookup>
f0101c1f:	85 c0                	test   %eax,%eax
f0101c21:	74 24                	je     f0101c47 <mem_init+0x7de>
f0101c23:	c7 44 24 0c a0 82 10 	movl   $0xf01082a0,0xc(%esp)
f0101c2a:	f0 
f0101c2b:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0101c3a:	00 
f0101c3b:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101c42:	e8 f9 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c47:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c4e:	00 
f0101c4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c56:	00 
f0101c57:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c5b:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101c60:	89 04 24             	mov    %eax,(%esp)
f0101c63:	e8 0d f7 ff ff       	call   f0101375 <page_insert>
f0101c68:	85 c0                	test   %eax,%eax
f0101c6a:	78 24                	js     f0101c90 <mem_init+0x827>
f0101c6c:	c7 44 24 0c d8 82 10 	movl   $0xf01082d8,0xc(%esp)
f0101c73:	f0 
f0101c74:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101c7b:	f0 
f0101c7c:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101c83:	00 
f0101c84:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101c8b:	e8 b0 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c90:	89 3c 24             	mov    %edi,(%esp)
f0101c93:	e8 f6 f3 ff ff       	call   f010108e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c98:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c9f:	00 
f0101ca0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ca7:	00 
f0101ca8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101cac:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101cb1:	89 04 24             	mov    %eax,(%esp)
f0101cb4:	e8 bc f6 ff ff       	call   f0101375 <page_insert>
f0101cb9:	85 c0                	test   %eax,%eax
f0101cbb:	74 24                	je     f0101ce1 <mem_init+0x878>
f0101cbd:	c7 44 24 0c 08 83 10 	movl   $0xf0108308,0xc(%esp)
f0101cc4:	f0 
f0101cc5:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101ccc:	f0 
f0101ccd:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101cd4:	00 
f0101cd5:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101cdc:	e8 5f e3 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ce1:	8b 0d 98 8e 29 f0    	mov    0xf0298e98,%ecx
f0101ce7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cea:	a1 9c 8e 29 f0       	mov    0xf0298e9c,%eax
f0101cef:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101cf2:	8b 11                	mov    (%ecx),%edx
f0101cf4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101cfa:	89 f8                	mov    %edi,%eax
f0101cfc:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101cff:	c1 f8 03             	sar    $0x3,%eax
f0101d02:	c1 e0 0c             	shl    $0xc,%eax
f0101d05:	39 c2                	cmp    %eax,%edx
f0101d07:	74 24                	je     f0101d2d <mem_init+0x8c4>
f0101d09:	c7 44 24 0c 38 83 10 	movl   $0xf0108338,0xc(%esp)
f0101d10:	f0 
f0101d11:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101d18:	f0 
f0101d19:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0101d20:	00 
f0101d21:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101d28:	e8 13 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d35:	e8 9e ed ff ff       	call   f0100ad8 <check_va2pa>
f0101d3a:	89 f2                	mov    %esi,%edx
f0101d3c:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101d3f:	c1 fa 03             	sar    $0x3,%edx
f0101d42:	c1 e2 0c             	shl    $0xc,%edx
f0101d45:	39 d0                	cmp    %edx,%eax
f0101d47:	74 24                	je     f0101d6d <mem_init+0x904>
f0101d49:	c7 44 24 0c 60 83 10 	movl   $0xf0108360,0xc(%esp)
f0101d50:	f0 
f0101d51:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101d60:	00 
f0101d61:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101d68:	e8 d3 e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101d6d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d72:	74 24                	je     f0101d98 <mem_init+0x92f>
f0101d74:	c7 44 24 0c 8a 8c 10 	movl   $0xf0108c8a,0xc(%esp)
f0101d7b:	f0 
f0101d7c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101d83:	f0 
f0101d84:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101d8b:	00 
f0101d8c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101d93:	e8 a8 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101d98:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d9d:	74 24                	je     f0101dc3 <mem_init+0x95a>
f0101d9f:	c7 44 24 0c 9b 8c 10 	movl   $0xf0108c9b,0xc(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101dae:	f0 
f0101daf:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0101db6:	00 
f0101db7:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101dbe:	e8 7d e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dc3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dca:	00 
f0101dcb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dd2:	00 
f0101dd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101dda:	89 14 24             	mov    %edx,(%esp)
f0101ddd:	e8 93 f5 ff ff       	call   f0101375 <page_insert>
f0101de2:	85 c0                	test   %eax,%eax
f0101de4:	74 24                	je     f0101e0a <mem_init+0x9a1>
f0101de6:	c7 44 24 0c 90 83 10 	movl   $0xf0108390,0xc(%esp)
f0101ded:	f0 
f0101dee:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101df5:	f0 
f0101df6:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101dfd:	00 
f0101dfe:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101e05:	e8 36 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e0f:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101e14:	e8 bf ec ff ff       	call   f0100ad8 <check_va2pa>
f0101e19:	89 da                	mov    %ebx,%edx
f0101e1b:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f0101e21:	c1 fa 03             	sar    $0x3,%edx
f0101e24:	c1 e2 0c             	shl    $0xc,%edx
f0101e27:	39 d0                	cmp    %edx,%eax
f0101e29:	74 24                	je     f0101e4f <mem_init+0x9e6>
f0101e2b:	c7 44 24 0c cc 83 10 	movl   $0xf01083cc,0xc(%esp)
f0101e32:	f0 
f0101e33:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101e3a:	f0 
f0101e3b:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101e42:	00 
f0101e43:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101e4a:	e8 f1 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e4f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e54:	74 24                	je     f0101e7a <mem_init+0xa11>
f0101e56:	c7 44 24 0c ac 8c 10 	movl   $0xf0108cac,0xc(%esp)
f0101e5d:	f0 
f0101e5e:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101e65:	f0 
f0101e66:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0101e6d:	00 
f0101e6e:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101e75:	e8 c6 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e81:	e8 55 f1 ff ff       	call   f0100fdb <page_alloc>
f0101e86:	85 c0                	test   %eax,%eax
f0101e88:	74 24                	je     f0101eae <mem_init+0xa45>
f0101e8a:	c7 44 24 0c 38 8c 10 	movl   $0xf0108c38,0xc(%esp)
f0101e91:	f0 
f0101e92:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101e99:	f0 
f0101e9a:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0101ea1:	00 
f0101ea2:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101ea9:	e8 92 e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101eae:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101eb5:	00 
f0101eb6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ebd:	00 
f0101ebe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ec2:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101ec7:	89 04 24             	mov    %eax,(%esp)
f0101eca:	e8 a6 f4 ff ff       	call   f0101375 <page_insert>
f0101ecf:	85 c0                	test   %eax,%eax
f0101ed1:	74 24                	je     f0101ef7 <mem_init+0xa8e>
f0101ed3:	c7 44 24 0c 90 83 10 	movl   $0xf0108390,0xc(%esp)
f0101eda:	f0 
f0101edb:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101ee2:	f0 
f0101ee3:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101eea:	00 
f0101eeb:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101ef2:	e8 49 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ef7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101efc:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0101f01:	e8 d2 eb ff ff       	call   f0100ad8 <check_va2pa>
f0101f06:	89 da                	mov    %ebx,%edx
f0101f08:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f0101f0e:	c1 fa 03             	sar    $0x3,%edx
f0101f11:	c1 e2 0c             	shl    $0xc,%edx
f0101f14:	39 d0                	cmp    %edx,%eax
f0101f16:	74 24                	je     f0101f3c <mem_init+0xad3>
f0101f18:	c7 44 24 0c cc 83 10 	movl   $0xf01083cc,0xc(%esp)
f0101f1f:	f0 
f0101f20:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101f27:	f0 
f0101f28:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101f2f:	00 
f0101f30:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101f37:	e8 04 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f3c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f41:	74 24                	je     f0101f67 <mem_init+0xafe>
f0101f43:	c7 44 24 0c ac 8c 10 	movl   $0xf0108cac,0xc(%esp)
f0101f4a:	f0 
f0101f4b:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101f5a:	00 
f0101f5b:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101f62:	e8 d9 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f6e:	e8 68 f0 ff ff       	call   f0100fdb <page_alloc>
f0101f73:	85 c0                	test   %eax,%eax
f0101f75:	74 24                	je     f0101f9b <mem_init+0xb32>
f0101f77:	c7 44 24 0c 38 8c 10 	movl   $0xf0108c38,0xc(%esp)
f0101f7e:	f0 
f0101f7f:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0101f86:	f0 
f0101f87:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101f8e:	00 
f0101f8f:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101f96:	e8 a5 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101f9b:	8b 15 98 8e 29 f0    	mov    0xf0298e98,%edx
f0101fa1:	8b 02                	mov    (%edx),%eax
f0101fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fa8:	89 c1                	mov    %eax,%ecx
f0101faa:	c1 e9 0c             	shr    $0xc,%ecx
f0101fad:	3b 0d 94 8e 29 f0    	cmp    0xf0298e94,%ecx
f0101fb3:	72 20                	jb     f0101fd5 <mem_init+0xb6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fb9:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0101fc0:	f0 
f0101fc1:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101fc8:	00 
f0101fc9:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0101fd0:	e8 6b e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101fd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101fdd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fe4:	00 
f0101fe5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fec:	00 
f0101fed:	89 14 24             	mov    %edx,(%esp)
f0101ff0:	e8 15 f1 ff ff       	call   f010110a <pgdir_walk>
f0101ff5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ff8:	83 c2 04             	add    $0x4,%edx
f0101ffb:	39 d0                	cmp    %edx,%eax
f0101ffd:	74 24                	je     f0102023 <mem_init+0xbba>
f0101fff:	c7 44 24 0c fc 83 10 	movl   $0xf01083fc,0xc(%esp)
f0102006:	f0 
f0102007:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010200e:	f0 
f010200f:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0102016:	00 
f0102017:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010201e:	e8 1d e0 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102023:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010202a:	00 
f010202b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102032:	00 
f0102033:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102037:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f010203c:	89 04 24             	mov    %eax,(%esp)
f010203f:	e8 31 f3 ff ff       	call   f0101375 <page_insert>
f0102044:	85 c0                	test   %eax,%eax
f0102046:	74 24                	je     f010206c <mem_init+0xc03>
f0102048:	c7 44 24 0c 3c 84 10 	movl   $0xf010843c,0xc(%esp)
f010204f:	f0 
f0102050:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102057:	f0 
f0102058:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010205f:	00 
f0102060:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102067:	e8 d4 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010206c:	8b 0d 98 8e 29 f0    	mov    0xf0298e98,%ecx
f0102072:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102075:	ba 00 10 00 00       	mov    $0x1000,%edx
f010207a:	89 c8                	mov    %ecx,%eax
f010207c:	e8 57 ea ff ff       	call   f0100ad8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102081:	89 da                	mov    %ebx,%edx
f0102083:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f0102089:	c1 fa 03             	sar    $0x3,%edx
f010208c:	c1 e2 0c             	shl    $0xc,%edx
f010208f:	39 d0                	cmp    %edx,%eax
f0102091:	74 24                	je     f01020b7 <mem_init+0xc4e>
f0102093:	c7 44 24 0c cc 83 10 	movl   $0xf01083cc,0xc(%esp)
f010209a:	f0 
f010209b:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01020aa:	00 
f01020ab:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01020b7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020bc:	74 24                	je     f01020e2 <mem_init+0xc79>
f01020be:	c7 44 24 0c ac 8c 10 	movl   $0xf0108cac,0xc(%esp)
f01020c5:	f0 
f01020c6:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01020cd:	f0 
f01020ce:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f01020d5:	00 
f01020d6:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01020dd:	e8 5e df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020e9:	00 
f01020ea:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020f1:	00 
f01020f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020f5:	89 04 24             	mov    %eax,(%esp)
f01020f8:	e8 0d f0 ff ff       	call   f010110a <pgdir_walk>
f01020fd:	f6 00 04             	testb  $0x4,(%eax)
f0102100:	75 24                	jne    f0102126 <mem_init+0xcbd>
f0102102:	c7 44 24 0c 7c 84 10 	movl   $0xf010847c,0xc(%esp)
f0102109:	f0 
f010210a:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102111:	f0 
f0102112:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102119:	00 
f010211a:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102121:	e8 1a df ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102126:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f010212b:	f6 00 04             	testb  $0x4,(%eax)
f010212e:	75 24                	jne    f0102154 <mem_init+0xceb>
f0102130:	c7 44 24 0c bd 8c 10 	movl   $0xf0108cbd,0xc(%esp)
f0102137:	f0 
f0102138:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010213f:	f0 
f0102140:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102147:	00 
f0102148:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010214f:	e8 ec de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102154:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010215b:	00 
f010215c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102163:	00 
f0102164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102168:	89 04 24             	mov    %eax,(%esp)
f010216b:	e8 05 f2 ff ff       	call   f0101375 <page_insert>
f0102170:	85 c0                	test   %eax,%eax
f0102172:	74 24                	je     f0102198 <mem_init+0xd2f>
f0102174:	c7 44 24 0c 90 83 10 	movl   $0xf0108390,0xc(%esp)
f010217b:	f0 
f010217c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102183:	f0 
f0102184:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010218b:	00 
f010218c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102193:	e8 a8 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102198:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010219f:	00 
f01021a0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021a7:	00 
f01021a8:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01021ad:	89 04 24             	mov    %eax,(%esp)
f01021b0:	e8 55 ef ff ff       	call   f010110a <pgdir_walk>
f01021b5:	f6 00 02             	testb  $0x2,(%eax)
f01021b8:	75 24                	jne    f01021de <mem_init+0xd75>
f01021ba:	c7 44 24 0c b0 84 10 	movl   $0xf01084b0,0xc(%esp)
f01021c1:	f0 
f01021c2:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01021c9:	f0 
f01021ca:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01021d1:	00 
f01021d2:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01021d9:	e8 62 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021e5:	00 
f01021e6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021ed:	00 
f01021ee:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01021f3:	89 04 24             	mov    %eax,(%esp)
f01021f6:	e8 0f ef ff ff       	call   f010110a <pgdir_walk>
f01021fb:	f6 00 04             	testb  $0x4,(%eax)
f01021fe:	74 24                	je     f0102224 <mem_init+0xdbb>
f0102200:	c7 44 24 0c e4 84 10 	movl   $0xf01084e4,0xc(%esp)
f0102207:	f0 
f0102208:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010220f:	f0 
f0102210:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102217:	00 
f0102218:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010221f:	e8 1c de ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102224:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010222b:	00 
f010222c:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102233:	00 
f0102234:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102238:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f010223d:	89 04 24             	mov    %eax,(%esp)
f0102240:	e8 30 f1 ff ff       	call   f0101375 <page_insert>
f0102245:	85 c0                	test   %eax,%eax
f0102247:	78 24                	js     f010226d <mem_init+0xe04>
f0102249:	c7 44 24 0c 1c 85 10 	movl   $0xf010851c,0xc(%esp)
f0102250:	f0 
f0102251:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102258:	f0 
f0102259:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102260:	00 
f0102261:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102268:	e8 d3 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010226d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102274:	00 
f0102275:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010227c:	00 
f010227d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102281:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102286:	89 04 24             	mov    %eax,(%esp)
f0102289:	e8 e7 f0 ff ff       	call   f0101375 <page_insert>
f010228e:	85 c0                	test   %eax,%eax
f0102290:	74 24                	je     f01022b6 <mem_init+0xe4d>
f0102292:	c7 44 24 0c 54 85 10 	movl   $0xf0108554,0xc(%esp)
f0102299:	f0 
f010229a:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01022a1:	f0 
f01022a2:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f01022a9:	00 
f01022aa:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01022b1:	e8 8a dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01022b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022bd:	00 
f01022be:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022c5:	00 
f01022c6:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01022cb:	89 04 24             	mov    %eax,(%esp)
f01022ce:	e8 37 ee ff ff       	call   f010110a <pgdir_walk>
f01022d3:	f6 00 04             	testb  $0x4,(%eax)
f01022d6:	74 24                	je     f01022fc <mem_init+0xe93>
f01022d8:	c7 44 24 0c e4 84 10 	movl   $0xf01084e4,0xc(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f01022ef:	00 
f01022f0:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01022f7:	e8 44 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01022fc:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102301:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102304:	ba 00 00 00 00       	mov    $0x0,%edx
f0102309:	e8 ca e7 ff ff       	call   f0100ad8 <check_va2pa>
f010230e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102311:	89 f0                	mov    %esi,%eax
f0102313:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0102319:	c1 f8 03             	sar    $0x3,%eax
f010231c:	c1 e0 0c             	shl    $0xc,%eax
f010231f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102322:	74 24                	je     f0102348 <mem_init+0xedf>
f0102324:	c7 44 24 0c 90 85 10 	movl   $0xf0108590,0xc(%esp)
f010232b:	f0 
f010232c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102333:	f0 
f0102334:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f010233b:	00 
f010233c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102343:	e8 f8 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102348:	ba 00 10 00 00       	mov    $0x1000,%edx
f010234d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102350:	e8 83 e7 ff ff       	call   f0100ad8 <check_va2pa>
f0102355:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102358:	74 24                	je     f010237e <mem_init+0xf15>
f010235a:	c7 44 24 0c bc 85 10 	movl   $0xf01085bc,0xc(%esp)
f0102361:	f0 
f0102362:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102369:	f0 
f010236a:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102371:	00 
f0102372:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102379:	e8 c2 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010237e:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102383:	74 24                	je     f01023a9 <mem_init+0xf40>
f0102385:	c7 44 24 0c d3 8c 10 	movl   $0xf0108cd3,0xc(%esp)
f010238c:	f0 
f010238d:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102394:	f0 
f0102395:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010239c:	00 
f010239d:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01023a4:	e8 97 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023a9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01023ae:	74 24                	je     f01023d4 <mem_init+0xf6b>
f01023b0:	c7 44 24 0c e4 8c 10 	movl   $0xf0108ce4,0xc(%esp)
f01023b7:	f0 
f01023b8:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01023bf:	f0 
f01023c0:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01023c7:	00 
f01023c8:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01023cf:	e8 6c dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01023d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023db:	e8 fb eb ff ff       	call   f0100fdb <page_alloc>
f01023e0:	85 c0                	test   %eax,%eax
f01023e2:	74 04                	je     f01023e8 <mem_init+0xf7f>
f01023e4:	39 c3                	cmp    %eax,%ebx
f01023e6:	74 24                	je     f010240c <mem_init+0xfa3>
f01023e8:	c7 44 24 0c ec 85 10 	movl   $0xf01085ec,0xc(%esp)
f01023ef:	f0 
f01023f0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01023f7:	f0 
f01023f8:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01023ff:	00 
f0102400:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102407:	e8 34 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010240c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102413:	00 
f0102414:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102419:	89 04 24             	mov    %eax,(%esp)
f010241c:	e8 04 ef ff ff       	call   f0101325 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102421:	8b 15 98 8e 29 f0    	mov    0xf0298e98,%edx
f0102427:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010242a:	ba 00 00 00 00       	mov    $0x0,%edx
f010242f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102432:	e8 a1 e6 ff ff       	call   f0100ad8 <check_va2pa>
f0102437:	83 f8 ff             	cmp    $0xffffffff,%eax
f010243a:	74 24                	je     f0102460 <mem_init+0xff7>
f010243c:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f0102443:	f0 
f0102444:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010244b:	f0 
f010244c:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102453:	00 
f0102454:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010245b:	e8 e0 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102460:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102465:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102468:	e8 6b e6 ff ff       	call   f0100ad8 <check_va2pa>
f010246d:	89 f2                	mov    %esi,%edx
f010246f:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f0102475:	c1 fa 03             	sar    $0x3,%edx
f0102478:	c1 e2 0c             	shl    $0xc,%edx
f010247b:	39 d0                	cmp    %edx,%eax
f010247d:	74 24                	je     f01024a3 <mem_init+0x103a>
f010247f:	c7 44 24 0c bc 85 10 	movl   $0xf01085bc,0xc(%esp)
f0102486:	f0 
f0102487:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010248e:	f0 
f010248f:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102496:	00 
f0102497:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010249e:	e8 9d db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01024a3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024a8:	74 24                	je     f01024ce <mem_init+0x1065>
f01024aa:	c7 44 24 0c 8a 8c 10 	movl   $0xf0108c8a,0xc(%esp)
f01024b1:	f0 
f01024b2:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01024b9:	f0 
f01024ba:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f01024c1:	00 
f01024c2:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01024c9:	e8 72 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024ce:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024d3:	74 24                	je     f01024f9 <mem_init+0x1090>
f01024d5:	c7 44 24 0c e4 8c 10 	movl   $0xf0108ce4,0xc(%esp)
f01024dc:	f0 
f01024dd:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01024e4:	f0 
f01024e5:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01024ec:	00 
f01024ed:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01024f4:	e8 47 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01024f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102500:	00 
f0102501:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102508:	00 
f0102509:	89 74 24 04          	mov    %esi,0x4(%esp)
f010250d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102510:	89 0c 24             	mov    %ecx,(%esp)
f0102513:	e8 5d ee ff ff       	call   f0101375 <page_insert>
f0102518:	85 c0                	test   %eax,%eax
f010251a:	74 24                	je     f0102540 <mem_init+0x10d7>
f010251c:	c7 44 24 0c 34 86 10 	movl   $0xf0108634,0xc(%esp)
f0102523:	f0 
f0102524:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010252b:	f0 
f010252c:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102533:	00 
f0102534:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010253b:	e8 00 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102540:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102545:	75 24                	jne    f010256b <mem_init+0x1102>
f0102547:	c7 44 24 0c f5 8c 10 	movl   $0xf0108cf5,0xc(%esp)
f010254e:	f0 
f010254f:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102556:	f0 
f0102557:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010255e:	00 
f010255f:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102566:	e8 d5 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f010256b:	83 3e 00             	cmpl   $0x0,(%esi)
f010256e:	74 24                	je     f0102594 <mem_init+0x112b>
f0102570:	c7 44 24 0c 01 8d 10 	movl   $0xf0108d01,0xc(%esp)
f0102577:	f0 
f0102578:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010257f:	f0 
f0102580:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102587:	00 
f0102588:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010258f:	e8 ac da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102594:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010259b:	00 
f010259c:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01025a1:	89 04 24             	mov    %eax,(%esp)
f01025a4:	e8 7c ed ff ff       	call   f0101325 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025a9:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01025ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01025b6:	e8 1d e5 ff ff       	call   f0100ad8 <check_va2pa>
f01025bb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025be:	74 24                	je     f01025e4 <mem_init+0x117b>
f01025c0:	c7 44 24 0c 10 86 10 	movl   $0xf0108610,0xc(%esp)
f01025c7:	f0 
f01025c8:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01025cf:	f0 
f01025d0:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f01025d7:	00 
f01025d8:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01025df:	e8 5c da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01025e4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025ec:	e8 e7 e4 ff ff       	call   f0100ad8 <check_va2pa>
f01025f1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025f4:	74 24                	je     f010261a <mem_init+0x11b1>
f01025f6:	c7 44 24 0c 6c 86 10 	movl   $0xf010866c,0xc(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102605:	f0 
f0102606:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f010260d:	00 
f010260e:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102615:	e8 26 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010261a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010261f:	74 24                	je     f0102645 <mem_init+0x11dc>
f0102621:	c7 44 24 0c 16 8d 10 	movl   $0xf0108d16,0xc(%esp)
f0102628:	f0 
f0102629:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102630:	f0 
f0102631:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102638:	00 
f0102639:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102640:	e8 fb d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102645:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010264a:	74 24                	je     f0102670 <mem_init+0x1207>
f010264c:	c7 44 24 0c e4 8c 10 	movl   $0xf0108ce4,0xc(%esp)
f0102653:	f0 
f0102654:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010265b:	f0 
f010265c:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0102663:	00 
f0102664:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010266b:	e8 d0 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102670:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102677:	e8 5f e9 ff ff       	call   f0100fdb <page_alloc>
f010267c:	85 c0                	test   %eax,%eax
f010267e:	74 04                	je     f0102684 <mem_init+0x121b>
f0102680:	39 c6                	cmp    %eax,%esi
f0102682:	74 24                	je     f01026a8 <mem_init+0x123f>
f0102684:	c7 44 24 0c 94 86 10 	movl   $0xf0108694,0xc(%esp)
f010268b:	f0 
f010268c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102693:	f0 
f0102694:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010269b:	00 
f010269c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01026a3:	e8 98 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01026a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026af:	e8 27 e9 ff ff       	call   f0100fdb <page_alloc>
f01026b4:	85 c0                	test   %eax,%eax
f01026b6:	74 24                	je     f01026dc <mem_init+0x1273>
f01026b8:	c7 44 24 0c 38 8c 10 	movl   $0xf0108c38,0xc(%esp)
f01026bf:	f0 
f01026c0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01026c7:	f0 
f01026c8:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01026cf:	00 
f01026d0:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01026d7:	e8 64 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026dc:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01026e1:	8b 08                	mov    (%eax),%ecx
f01026e3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026e9:	89 fa                	mov    %edi,%edx
f01026eb:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f01026f1:	c1 fa 03             	sar    $0x3,%edx
f01026f4:	c1 e2 0c             	shl    $0xc,%edx
f01026f7:	39 d1                	cmp    %edx,%ecx
f01026f9:	74 24                	je     f010271f <mem_init+0x12b6>
f01026fb:	c7 44 24 0c 38 83 10 	movl   $0xf0108338,0xc(%esp)
f0102702:	f0 
f0102703:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010270a:	f0 
f010270b:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102712:	00 
f0102713:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010271a:	e8 21 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010271f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102725:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010272a:	74 24                	je     f0102750 <mem_init+0x12e7>
f010272c:	c7 44 24 0c 9b 8c 10 	movl   $0xf0108c9b,0xc(%esp)
f0102733:	f0 
f0102734:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010273b:	f0 
f010273c:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102743:	00 
f0102744:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010274b:	e8 f0 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102750:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102756:	89 3c 24             	mov    %edi,(%esp)
f0102759:	e8 30 e9 ff ff       	call   f010108e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010275e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102765:	00 
f0102766:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010276d:	00 
f010276e:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102773:	89 04 24             	mov    %eax,(%esp)
f0102776:	e8 8f e9 ff ff       	call   f010110a <pgdir_walk>
f010277b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010277e:	8b 0d 98 8e 29 f0    	mov    0xf0298e98,%ecx
f0102784:	8b 51 04             	mov    0x4(%ecx),%edx
f0102787:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010278d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102790:	8b 15 94 8e 29 f0    	mov    0xf0298e94,%edx
f0102796:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102799:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010279c:	c1 ea 0c             	shr    $0xc,%edx
f010279f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01027a2:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01027a5:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01027a8:	72 23                	jb     f01027cd <mem_init+0x1364>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01027ad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01027b1:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01027b8:	f0 
f01027b9:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f01027c0:	00 
f01027c1:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01027c8:	e8 73 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01027d0:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01027d6:	39 d0                	cmp    %edx,%eax
f01027d8:	74 24                	je     f01027fe <mem_init+0x1395>
f01027da:	c7 44 24 0c 27 8d 10 	movl   $0xf0108d27,0xc(%esp)
f01027e1:	f0 
f01027e2:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01027e9:	f0 
f01027ea:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01027f1:	00 
f01027f2:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01027f9:	e8 42 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027fe:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102805:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010280b:	89 f8                	mov    %edi,%eax
f010280d:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0102813:	c1 f8 03             	sar    $0x3,%eax
f0102816:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102819:	89 c1                	mov    %eax,%ecx
f010281b:	c1 e9 0c             	shr    $0xc,%ecx
f010281e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102821:	77 20                	ja     f0102843 <mem_init+0x13da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102823:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102827:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f010282e:	f0 
f010282f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102836:	00 
f0102837:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f010283e:	e8 fd d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102843:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010284a:	00 
f010284b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102852:	00 
	return (void *)(pa + KERNBASE);
f0102853:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102858:	89 04 24             	mov    %eax,(%esp)
f010285b:	e8 0e 3a 00 00       	call   f010626e <memset>
	page_free(pp0);
f0102860:	89 3c 24             	mov    %edi,(%esp)
f0102863:	e8 26 e8 ff ff       	call   f010108e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102868:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010286f:	00 
f0102870:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102877:	00 
f0102878:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f010287d:	89 04 24             	mov    %eax,(%esp)
f0102880:	e8 85 e8 ff ff       	call   f010110a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102885:	89 fa                	mov    %edi,%edx
f0102887:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f010288d:	c1 fa 03             	sar    $0x3,%edx
f0102890:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102893:	89 d0                	mov    %edx,%eax
f0102895:	c1 e8 0c             	shr    $0xc,%eax
f0102898:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f010289e:	72 20                	jb     f01028c0 <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01028a4:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01028ab:	f0 
f01028ac:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028b3:	00 
f01028b4:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f01028bb:	e8 80 d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01028c0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01028c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028c9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
	  assert((ptep[i] & PTE_P) == 0);
f01028cf:	f6 00 01             	testb  $0x1,(%eax)
f01028d2:	74 24                	je     f01028f8 <mem_init+0x148f>
f01028d4:	c7 44 24 0c 3f 8d 10 	movl   $0xf0108d3f,0xc(%esp)
f01028db:	f0 
f01028dc:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01028e3:	f0 
f01028e4:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f01028eb:	00 
f01028ec:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01028f3:	e8 48 d7 ff ff       	call   f0100040 <_panic>
f01028f8:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01028fb:	39 d0                	cmp    %edx,%eax
f01028fd:	75 d0                	jne    f01028cf <mem_init+0x1466>
	  assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01028ff:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102904:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010290a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102910:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102913:	89 0d 40 82 29 f0    	mov    %ecx,0xf0298240

	// free the pages we took
	page_free(pp0);
f0102919:	89 3c 24             	mov    %edi,(%esp)
f010291c:	e8 6d e7 ff ff       	call   f010108e <page_free>
	page_free(pp1);
f0102921:	89 34 24             	mov    %esi,(%esp)
f0102924:	e8 65 e7 ff ff       	call   f010108e <page_free>
	page_free(pp2);
f0102929:	89 1c 24             	mov    %ebx,(%esp)
f010292c:	e8 5d e7 ff ff       	call   f010108e <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102931:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102938:	00 
f0102939:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102940:	e8 b6 ea ff ff       	call   f01013fb <mmio_map_region>
f0102945:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102947:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010294e:	00 
f010294f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102956:	e8 a0 ea ff ff       	call   f01013fb <mmio_map_region>
f010295b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010295d:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102963:	76 0d                	jbe    f0102972 <mem_init+0x1509>
f0102965:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010296b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102970:	76 24                	jbe    f0102996 <mem_init+0x152d>
f0102972:	c7 44 24 0c b8 86 10 	movl   $0xf01086b8,0xc(%esp)
f0102979:	f0 
f010297a:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102981:	f0 
f0102982:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0102989:	00 
f010298a:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102991:	e8 aa d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102996:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010299c:	76 0e                	jbe    f01029ac <mem_init+0x1543>
f010299e:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01029a4:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01029aa:	76 24                	jbe    f01029d0 <mem_init+0x1567>
f01029ac:	c7 44 24 0c e0 86 10 	movl   $0xf01086e0,0xc(%esp)
f01029b3:	f0 
f01029b4:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01029bb:	f0 
f01029bc:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01029c3:	00 
f01029c4:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01029cb:	e8 70 d6 ff ff       	call   f0100040 <_panic>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01029d0:	89 da                	mov    %ebx,%edx
f01029d2:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01029d4:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01029da:	74 24                	je     f0102a00 <mem_init+0x1597>
f01029dc:	c7 44 24 0c 08 87 10 	movl   $0xf0108708,0xc(%esp)
f01029e3:	f0 
f01029e4:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01029eb:	f0 
f01029ec:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f01029f3:	00 
f01029f4:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01029fb:	e8 40 d6 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a00:	39 c6                	cmp    %eax,%esi
f0102a02:	73 24                	jae    f0102a28 <mem_init+0x15bf>
f0102a04:	c7 44 24 0c 56 8d 10 	movl   $0xf0108d56,0xc(%esp)
f0102a0b:	f0 
f0102a0c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102a13:	f0 
f0102a14:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102a1b:	00 
f0102a1c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102a23:	e8 18 d6 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a28:	8b 3d 98 8e 29 f0    	mov    0xf0298e98,%edi
f0102a2e:	89 da                	mov    %ebx,%edx
f0102a30:	89 f8                	mov    %edi,%eax
f0102a32:	e8 a1 e0 ff ff       	call   f0100ad8 <check_va2pa>
f0102a37:	85 c0                	test   %eax,%eax
f0102a39:	74 24                	je     f0102a5f <mem_init+0x15f6>
f0102a3b:	c7 44 24 0c 30 87 10 	movl   $0xf0108730,0xc(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102a4a:	f0 
f0102a4b:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102a52:	00 
f0102a53:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102a5a:	e8 e1 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102a5f:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102a65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a68:	89 c2                	mov    %eax,%edx
f0102a6a:	89 f8                	mov    %edi,%eax
f0102a6c:	e8 67 e0 ff ff       	call   f0100ad8 <check_va2pa>
f0102a71:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102a76:	74 24                	je     f0102a9c <mem_init+0x1633>
f0102a78:	c7 44 24 0c 54 87 10 	movl   $0xf0108754,0xc(%esp)
f0102a7f:	f0 
f0102a80:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102a87:	f0 
f0102a88:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102a8f:	00 
f0102a90:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102a97:	e8 a4 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102a9c:	89 f2                	mov    %esi,%edx
f0102a9e:	89 f8                	mov    %edi,%eax
f0102aa0:	e8 33 e0 ff ff       	call   f0100ad8 <check_va2pa>
f0102aa5:	85 c0                	test   %eax,%eax
f0102aa7:	74 24                	je     f0102acd <mem_init+0x1664>
f0102aa9:	c7 44 24 0c 84 87 10 	movl   $0xf0108784,0xc(%esp)
f0102ab0:	f0 
f0102ab1:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102ab8:	f0 
f0102ab9:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102ac0:	00 
f0102ac1:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102ac8:	e8 73 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102acd:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102ad3:	89 f8                	mov    %edi,%eax
f0102ad5:	e8 fe df ff ff       	call   f0100ad8 <check_va2pa>
f0102ada:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102add:	74 24                	je     f0102b03 <mem_init+0x169a>
f0102adf:	c7 44 24 0c a8 87 10 	movl   $0xf01087a8,0xc(%esp)
f0102ae6:	f0 
f0102ae7:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102aee:	f0 
f0102aef:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102af6:	00 
f0102af7:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102b03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b0a:	00 
f0102b0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b0f:	89 3c 24             	mov    %edi,(%esp)
f0102b12:	e8 f3 e5 ff ff       	call   f010110a <pgdir_walk>
f0102b17:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b1a:	75 24                	jne    f0102b40 <mem_init+0x16d7>
f0102b1c:	c7 44 24 0c d4 87 10 	movl   $0xf01087d4,0xc(%esp)
f0102b23:	f0 
f0102b24:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102b2b:	f0 
f0102b2c:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102b33:	00 
f0102b34:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102b3b:	e8 00 d5 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b47:	00 
f0102b48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b4c:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102b51:	89 04 24             	mov    %eax,(%esp)
f0102b54:	e8 b1 e5 ff ff       	call   f010110a <pgdir_walk>
f0102b59:	f6 00 04             	testb  $0x4,(%eax)
f0102b5c:	74 24                	je     f0102b82 <mem_init+0x1719>
f0102b5e:	c7 44 24 0c 18 88 10 	movl   $0xf0108818,0xc(%esp)
f0102b65:	f0 
f0102b66:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102b6d:	f0 
f0102b6e:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102b75:	00 
f0102b76:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102b7d:	e8 be d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102b82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b89:	00 
f0102b8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b8e:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102b93:	89 04 24             	mov    %eax,(%esp)
f0102b96:	e8 6f e5 ff ff       	call   f010110a <pgdir_walk>
f0102b9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102ba1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ba8:	00 
f0102ba9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102bac:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102bb0:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102bb5:	89 04 24             	mov    %eax,(%esp)
f0102bb8:	e8 4d e5 ff ff       	call   f010110a <pgdir_walk>
f0102bbd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102bc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bca:	00 
f0102bcb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102bcf:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102bd4:	89 04 24             	mov    %eax,(%esp)
f0102bd7:	e8 2e e5 ff ff       	call   f010110a <pgdir_walk>
f0102bdc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102be2:	c7 04 24 68 8d 10 f0 	movl   $0xf0108d68,(%esp)
f0102be9:	e8 40 13 00 00       	call   f0103f2e <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U|PTE_P);
f0102bee:	a1 9c 8e 29 f0       	mov    0xf0298e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102bf3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bf8:	77 20                	ja     f0102c1a <mem_init+0x17b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bfe:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102c0d:	00 
f0102c0e:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102c15:	e8 26 d4 ff ff       	call   f0100040 <_panic>
f0102c1a:	8b 15 94 8e 29 f0    	mov    0xf0298e94,%edx
f0102c20:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102c27:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c2d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102c34:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c35:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c3a:	89 04 24             	mov    %eax,(%esp)
f0102c3d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c42:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102c47:	e8 c3 e5 ff ff       	call   f010120f <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f0102c4c:	a1 48 82 29 f0       	mov    0xf0298248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c51:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c56:	77 20                	ja     f0102c78 <mem_init+0x180f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c5c:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0102c63:	f0 
f0102c64:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102c6b:	00 
f0102c6c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102c73:	e8 c8 d3 ff ff       	call   f0100040 <_panic>
f0102c78:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102c7f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c80:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c85:	89 04 24             	mov    %eax,(%esp)
f0102c88:	b9 00 00 02 00       	mov    $0x20000,%ecx
f0102c8d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102c92:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102c97:	e8 73 e5 ff ff       	call   f010120f <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE, 0, PTE_W);
f0102c9c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ca3:	00 
f0102ca4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102cab:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102cb0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102cb5:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102cba:	e8 50 e5 ff ff       	call   f010120f <boot_map_region>
f0102cbf:	c7 45 cc 00 a0 29 f0 	movl   $0xf029a000,-0x34(%ebp)
f0102cc6:	bb 00 a0 29 f0       	mov    $0xf029a000,%ebx
f0102ccb:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cd0:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102cd6:	77 20                	ja     f0102cf8 <mem_init+0x188f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cd8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102cdc:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0102ce3:	f0 
f0102ce4:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
f0102ceb:	00 
f0102cec:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102cf3:	e8 48 d3 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir, (uint32_t)(KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);	
f0102cf8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102cff:	00 
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d00:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
		boot_map_region(kern_pgdir, (uint32_t)(KSTACKTOP-i*(KSTKSIZE+KSTKGAP)-KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);	
f0102d06:	89 04 24             	mov    %eax,(%esp)
f0102d09:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d0e:	89 f2                	mov    %esi,%edx
f0102d10:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0102d15:	e8 f5 e4 ff ff       	call   f010120f <boot_map_region>
f0102d1a:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102d20:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

	int i;
	for (i = 0; i < NCPU; i++){
f0102d26:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102d2c:	75 a2                	jne    f0102cd0 <mem_init+0x1867>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d2e:	8b 1d 98 8e 29 f0    	mov    0xf0298e98,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d34:	8b 0d 94 8e 29 f0    	mov    0xf0298e94,%ecx
f0102d3a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102d3d:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102d44:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102d4a:	be 00 00 00 00       	mov    $0x0,%esi
f0102d4f:	eb 70                	jmp    f0102dc1 <mem_init+0x1958>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d51:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d57:	89 d8                	mov    %ebx,%eax
f0102d59:	e8 7a dd ff ff       	call   f0100ad8 <check_va2pa>
f0102d5e:	8b 15 9c 8e 29 f0    	mov    0xf0298e9c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d64:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102d6a:	77 20                	ja     f0102d8c <mem_init+0x1923>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d70:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0102d77:	f0 
f0102d78:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102d7f:	00 
f0102d80:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102d87:	e8 b4 d2 ff ff       	call   f0100040 <_panic>
f0102d8c:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d93:	39 d0                	cmp    %edx,%eax
f0102d95:	74 24                	je     f0102dbb <mem_init+0x1952>
f0102d97:	c7 44 24 0c 4c 88 10 	movl   $0xf010884c,0xc(%esp)
f0102d9e:	f0 
f0102d9f:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102da6:	f0 
f0102da7:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f0102dae:	00 
f0102daf:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102db6:	e8 85 d2 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102dbb:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102dc1:	39 f7                	cmp    %esi,%edi
f0102dc3:	77 8c                	ja     f0102d51 <mem_init+0x18e8>
f0102dc5:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dca:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102dd0:	89 d8                	mov    %ebx,%eax
f0102dd2:	e8 01 dd ff ff       	call   f0100ad8 <check_va2pa>
f0102dd7:	8b 15 48 82 29 f0    	mov    0xf0298248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ddd:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102de3:	77 20                	ja     f0102e05 <mem_init+0x199c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102de5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102de9:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0102df0:	f0 
f0102df1:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102df8:	00 
f0102df9:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102e00:	e8 3b d2 ff ff       	call   f0100040 <_panic>
f0102e05:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102e0c:	39 d0                	cmp    %edx,%eax
f0102e0e:	74 24                	je     f0102e34 <mem_init+0x19cb>
f0102e10:	c7 44 24 0c 80 88 10 	movl   $0xf0108880,0xc(%esp)
f0102e17:	f0 
f0102e18:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102e1f:	f0 
f0102e20:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f0102e27:	00 
f0102e28:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102e2f:	e8 0c d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102e34:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e3a:	81 fe 00 00 02 00    	cmp    $0x20000,%esi
f0102e40:	75 88                	jne    f0102dca <mem_init+0x1961>
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e42:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e45:	c1 e7 0c             	shl    $0xc,%edi
f0102e48:	be 00 00 00 00       	mov    $0x0,%esi
f0102e4d:	eb 3b                	jmp    f0102e8a <mem_init+0x1a21>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e4f:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	  assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e55:	89 d8                	mov    %ebx,%eax
f0102e57:	e8 7c dc ff ff       	call   f0100ad8 <check_va2pa>
f0102e5c:	39 c6                	cmp    %eax,%esi
f0102e5e:	74 24                	je     f0102e84 <mem_init+0x1a1b>
f0102e60:	c7 44 24 0c b4 88 10 	movl   $0xf01088b4,0xc(%esp)
f0102e67:	f0 
f0102e68:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102e6f:	f0 
f0102e70:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0102e77:	00 
f0102e78:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102e7f:	e8 bc d1 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
	  assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e84:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e8a:	39 fe                	cmp    %edi,%esi
f0102e8c:	72 c1                	jb     f0102e4f <mem_init+0x19e6>
f0102e8e:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102e93:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e96:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102e99:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e9c:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ea2:	89 c6                	mov    %eax,%esi
f0102ea4:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102eaa:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102eb0:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102eb3:	89 da                	mov    %ebx,%edx
f0102eb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102eb8:	e8 1b dc ff ff       	call   f0100ad8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ebd:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ec4:	77 23                	ja     f0102ee9 <mem_init+0x1a80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ec6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102ec9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ecd:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0102ed4:	f0 
f0102ed5:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102edc:	00 
f0102edd:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102ee4:	e8 57 d1 ff ff       	call   f0100040 <_panic>
f0102ee9:	39 f0                	cmp    %esi,%eax
f0102eeb:	74 24                	je     f0102f11 <mem_init+0x1aa8>
f0102eed:	c7 44 24 0c dc 88 10 	movl   $0xf01088dc,0xc(%esp)
f0102ef4:	f0 
f0102ef5:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102efc:	f0 
f0102efd:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102f04:	00 
f0102f05:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102f0c:	e8 2f d1 ff ff       	call   f0100040 <_panic>
f0102f11:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f17:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f1d:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102f20:	0f 85 55 05 00 00    	jne    f010347b <mem_init+0x2012>
f0102f26:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f2b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
					  == PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + i) == ~0);
f0102f2e:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102f31:	89 f0                	mov    %esi,%eax
f0102f33:	e8 a0 db ff ff       	call   f0100ad8 <check_va2pa>
f0102f38:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f3b:	74 24                	je     f0102f61 <mem_init+0x1af8>
f0102f3d:	c7 44 24 0c 24 89 10 	movl   $0xf0108924,0xc(%esp)
f0102f44:	f0 
f0102f45:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102f4c:	f0 
f0102f4d:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0102f54:	00 
f0102f55:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102f5c:	e8 df d0 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
					  == PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102f61:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f67:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102f6d:	75 bf                	jne    f0102f2e <mem_init+0x1ac5>
f0102f6f:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102f75:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	  assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102f7c:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102f82:	0f 85 0e ff ff ff    	jne    f0102e96 <mem_init+0x1a2d>
f0102f88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8b:	b8 00 00 00 00       	mov    $0x0,%eax
		  assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f90:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f96:	83 fa 04             	cmp    $0x4,%edx
f0102f99:	77 2e                	ja     f0102fc9 <mem_init+0x1b60>
			case PDX(UVPT):
			case PDX(KSTACKTOP-1):
			case PDX(UPAGES):
			case PDX(UENVS):
			case PDX(MMIOBASE):
				assert(pgdir[i] & PTE_P);
f0102f9b:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102f9f:	0f 85 aa 00 00 00    	jne    f010304f <mem_init+0x1be6>
f0102fa5:	c7 44 24 0c 81 8d 10 	movl   $0xf0108d81,0xc(%esp)
f0102fac:	f0 
f0102fad:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102fb4:	f0 
f0102fb5:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0102fbc:	00 
f0102fbd:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102fc4:	e8 77 d0 ff ff       	call   f0100040 <_panic>
				break;
			default:
				if (i >= PDX(KERNBASE)) {
f0102fc9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fce:	76 55                	jbe    f0103025 <mem_init+0x1bbc>
					assert(pgdir[i] & PTE_P);
f0102fd0:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102fd3:	f6 c2 01             	test   $0x1,%dl
f0102fd6:	75 24                	jne    f0102ffc <mem_init+0x1b93>
f0102fd8:	c7 44 24 0c 81 8d 10 	movl   $0xf0108d81,0xc(%esp)
f0102fdf:	f0 
f0102fe0:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0102fe7:	f0 
f0102fe8:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102fef:	00 
f0102ff0:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0102ff7:	e8 44 d0 ff ff       	call   f0100040 <_panic>
					assert(pgdir[i] & PTE_W);
f0102ffc:	f6 c2 02             	test   $0x2,%dl
f0102fff:	75 4e                	jne    f010304f <mem_init+0x1be6>
f0103001:	c7 44 24 0c 92 8d 10 	movl   $0xf0108d92,0xc(%esp)
f0103008:	f0 
f0103009:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103010:	f0 
f0103011:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0103018:	00 
f0103019:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103020:	e8 1b d0 ff ff       	call   f0100040 <_panic>
				} else
				  assert(pgdir[i] == 0);
f0103025:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103029:	74 24                	je     f010304f <mem_init+0x1be6>
f010302b:	c7 44 24 0c a3 8d 10 	movl   $0xf0108da3,0xc(%esp)
f0103032:	f0 
f0103033:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010303a:	f0 
f010303b:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0103042:	00 
f0103043:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010304a:	e8 f1 cf ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010304f:	40                   	inc    %eax
f0103050:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103055:	0f 85 35 ff ff ff    	jne    f0102f90 <mem_init+0x1b27>
				} else
				  assert(pgdir[i] == 0);
				break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010305b:	c7 04 24 48 89 10 f0 	movl   $0xf0108948,(%esp)
f0103062:	e8 c7 0e 00 00       	call   f0103f2e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103067:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010306c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103071:	77 20                	ja     f0103093 <mem_init+0x1c2a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103073:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103077:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f010307e:	f0 
f010307f:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0103086:	00 
f0103087:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010308e:	e8 ad cf ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103093:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103098:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010309b:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a0:	e8 4e db ff ff       	call   f0100bf3 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01030a5:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01030a8:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01030ad:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01030b0:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01030b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030ba:	e8 1c df ff ff       	call   f0100fdb <page_alloc>
f01030bf:	89 c6                	mov    %eax,%esi
f01030c1:	85 c0                	test   %eax,%eax
f01030c3:	75 24                	jne    f01030e9 <mem_init+0x1c80>
f01030c5:	c7 44 24 0c 8d 8b 10 	movl   $0xf0108b8d,0xc(%esp)
f01030cc:	f0 
f01030cd:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01030d4:	f0 
f01030d5:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f01030dc:	00 
f01030dd:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01030e4:	e8 57 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01030f0:	e8 e6 de ff ff       	call   f0100fdb <page_alloc>
f01030f5:	89 c7                	mov    %eax,%edi
f01030f7:	85 c0                	test   %eax,%eax
f01030f9:	75 24                	jne    f010311f <mem_init+0x1cb6>
f01030fb:	c7 44 24 0c a3 8b 10 	movl   $0xf0108ba3,0xc(%esp)
f0103102:	f0 
f0103103:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010310a:	f0 
f010310b:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0103112:	00 
f0103113:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010311a:	e8 21 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010311f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103126:	e8 b0 de ff ff       	call   f0100fdb <page_alloc>
f010312b:	89 c3                	mov    %eax,%ebx
f010312d:	85 c0                	test   %eax,%eax
f010312f:	75 24                	jne    f0103155 <mem_init+0x1cec>
f0103131:	c7 44 24 0c b9 8b 10 	movl   $0xf0108bb9,0xc(%esp)
f0103138:	f0 
f0103139:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103140:	f0 
f0103141:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0103148:	00 
f0103149:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103150:	e8 eb ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103155:	89 34 24             	mov    %esi,(%esp)
f0103158:	e8 31 df ff ff       	call   f010108e <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010315d:	89 f8                	mov    %edi,%eax
f010315f:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0103165:	c1 f8 03             	sar    $0x3,%eax
f0103168:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010316b:	89 c2                	mov    %eax,%edx
f010316d:	c1 ea 0c             	shr    $0xc,%edx
f0103170:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0103176:	72 20                	jb     f0103198 <mem_init+0x1d2f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103178:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010317c:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0103183:	f0 
f0103184:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010318b:	00 
f010318c:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0103193:	e8 a8 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103198:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010319f:	00 
f01031a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01031a7:	00 
	return (void *)(pa + KERNBASE);
f01031a8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01031ad:	89 04 24             	mov    %eax,(%esp)
f01031b0:	e8 b9 30 00 00       	call   f010626e <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01031b5:	89 d8                	mov    %ebx,%eax
f01031b7:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f01031bd:	c1 f8 03             	sar    $0x3,%eax
f01031c0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031c3:	89 c2                	mov    %eax,%edx
f01031c5:	c1 ea 0c             	shr    $0xc,%edx
f01031c8:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f01031ce:	72 20                	jb     f01031f0 <mem_init+0x1d87>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031d4:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01031db:	f0 
f01031dc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01031e3:	00 
f01031e4:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f01031eb:	e8 50 ce ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01031f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031f7:	00 
f01031f8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01031ff:	00 
	return (void *)(pa + KERNBASE);
f0103200:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103205:	89 04 24             	mov    %eax,(%esp)
f0103208:	e8 61 30 00 00       	call   f010626e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010320d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103214:	00 
f0103215:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010321c:	00 
f010321d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103221:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f0103226:	89 04 24             	mov    %eax,(%esp)
f0103229:	e8 47 e1 ff ff       	call   f0101375 <page_insert>
	assert(pp1->pp_ref == 1);
f010322e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103233:	74 24                	je     f0103259 <mem_init+0x1df0>
f0103235:	c7 44 24 0c 8a 8c 10 	movl   $0xf0108c8a,0xc(%esp)
f010323c:	f0 
f010323d:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103244:	f0 
f0103245:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f010324c:	00 
f010324d:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103254:	e8 e7 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103259:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103260:	01 01 01 
f0103263:	74 24                	je     f0103289 <mem_init+0x1e20>
f0103265:	c7 44 24 0c 68 89 10 	movl   $0xf0108968,0xc(%esp)
f010326c:	f0 
f010326d:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103274:	f0 
f0103275:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f010327c:	00 
f010327d:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103284:	e8 b7 cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103289:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103290:	00 
f0103291:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103298:	00 
f0103299:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010329d:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01032a2:	89 04 24             	mov    %eax,(%esp)
f01032a5:	e8 cb e0 ff ff       	call   f0101375 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01032aa:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01032b1:	02 02 02 
f01032b4:	74 24                	je     f01032da <mem_init+0x1e71>
f01032b6:	c7 44 24 0c 8c 89 10 	movl   $0xf010898c,0xc(%esp)
f01032bd:	f0 
f01032be:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01032c5:	f0 
f01032c6:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f01032cd:	00 
f01032ce:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01032d5:	e8 66 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01032da:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01032df:	74 24                	je     f0103305 <mem_init+0x1e9c>
f01032e1:	c7 44 24 0c ac 8c 10 	movl   $0xf0108cac,0xc(%esp)
f01032e8:	f0 
f01032e9:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01032f0:	f0 
f01032f1:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f01032f8:	00 
f01032f9:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103300:	e8 3b cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103305:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010330a:	74 24                	je     f0103330 <mem_init+0x1ec7>
f010330c:	c7 44 24 0c 16 8d 10 	movl   $0xf0108d16,0xc(%esp)
f0103313:	f0 
f0103314:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010331b:	f0 
f010331c:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0103323:	00 
f0103324:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f010332b:	e8 10 cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103330:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103337:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010333a:	89 d8                	mov    %ebx,%eax
f010333c:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f0103342:	c1 f8 03             	sar    $0x3,%eax
f0103345:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103348:	89 c2                	mov    %eax,%edx
f010334a:	c1 ea 0c             	shr    $0xc,%edx
f010334d:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f0103353:	72 20                	jb     f0103375 <mem_init+0x1f0c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103355:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103359:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0103360:	f0 
f0103361:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103368:	00 
f0103369:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0103370:	e8 cb cc ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103375:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010337c:	03 03 03 
f010337f:	74 24                	je     f01033a5 <mem_init+0x1f3c>
f0103381:	c7 44 24 0c b0 89 10 	movl   $0xf01089b0,0xc(%esp)
f0103388:	f0 
f0103389:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103390:	f0 
f0103391:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0103398:	00 
f0103399:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01033a0:	e8 9b cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01033a5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033ac:	00 
f01033ad:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01033b2:	89 04 24             	mov    %eax,(%esp)
f01033b5:	e8 6b df ff ff       	call   f0101325 <page_remove>
	assert(pp2->pp_ref == 0);
f01033ba:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01033bf:	74 24                	je     f01033e5 <mem_init+0x1f7c>
f01033c1:	c7 44 24 0c e4 8c 10 	movl   $0xf0108ce4,0xc(%esp)
f01033c8:	f0 
f01033c9:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01033d0:	f0 
f01033d1:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f01033d8:	00 
f01033d9:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f01033e0:	e8 5b cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01033e5:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
f01033ea:	8b 08                	mov    (%eax),%ecx
f01033ec:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01033f2:	89 f2                	mov    %esi,%edx
f01033f4:	2b 15 9c 8e 29 f0    	sub    0xf0298e9c,%edx
f01033fa:	c1 fa 03             	sar    $0x3,%edx
f01033fd:	c1 e2 0c             	shl    $0xc,%edx
f0103400:	39 d1                	cmp    %edx,%ecx
f0103402:	74 24                	je     f0103428 <mem_init+0x1fbf>
f0103404:	c7 44 24 0c 38 83 10 	movl   $0xf0108338,0xc(%esp)
f010340b:	f0 
f010340c:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103413:	f0 
f0103414:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f010341b:	00 
f010341c:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103423:	e8 18 cc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103428:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010342e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103433:	74 24                	je     f0103459 <mem_init+0x1ff0>
f0103435:	c7 44 24 0c 9b 8c 10 	movl   $0xf0108c9b,0xc(%esp)
f010343c:	f0 
f010343d:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0103444:	f0 
f0103445:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f010344c:	00 
f010344d:	c7 04 24 3d 8a 10 f0 	movl   $0xf0108a3d,(%esp)
f0103454:	e8 e7 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103459:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010345f:	89 34 24             	mov    %esi,(%esp)
f0103462:	e8 27 dc ff ff       	call   f010108e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103467:	c7 04 24 dc 89 10 f0 	movl   $0xf01089dc,(%esp)
f010346e:	e8 bb 0a 00 00       	call   f0103f2e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103473:	83 c4 3c             	add    $0x3c,%esp
f0103476:	5b                   	pop    %ebx
f0103477:	5e                   	pop    %esi
f0103478:	5f                   	pop    %edi
f0103479:	5d                   	pop    %ebp
f010347a:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
		  assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010347b:	89 da                	mov    %ebx,%edx
f010347d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103480:	e8 53 d6 ff ff       	call   f0100ad8 <check_va2pa>
f0103485:	e9 5f fa ff ff       	jmp    f0102ee9 <mem_init+0x1a80>

f010348a <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010348a:	55                   	push   %ebp
f010348b:	89 e5                	mov    %esp,%ebp
f010348d:	57                   	push   %edi
f010348e:	56                   	push   %esi
f010348f:	53                   	push   %ebx
f0103490:	83 ec 1c             	sub    $0x1c,%esp
f0103493:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103496:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.

	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
f0103499:	8b 45 0c             	mov    0xc(%ebp),%eax
f010349c:	a3 44 82 29 f0       	mov    %eax,0xf0298244
	pte_t* pte;	

	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f01034a1:	89 c6                	mov    %eax,%esi
f01034a3:	03 75 10             	add    0x10(%ebp),%esi
f01034a6:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f01034ac:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01034b2:	eb 5e                	jmp    f0103512 <user_mem_check+0x88>
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
f01034b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034bb:	00 
f01034bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034c5:	8b 43 60             	mov    0x60(%ebx),%eax
f01034c8:	89 04 24             	mov    %eax,(%esp)
f01034cb:	e8 3a dc ff ff       	call   f010110a <pgdir_walk>
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
f01034d0:	85 c0                	test   %eax,%eax
f01034d2:	74 19                	je     f01034ed <user_mem_check+0x63>
f01034d4:	8b 00                	mov    (%eax),%eax
f01034d6:	89 fa                	mov    %edi,%edx
f01034d8:	83 ca 01             	or     $0x1,%edx
f01034db:	09 c2                	or     %eax,%edx
f01034dd:	39 d0                	cmp    %edx,%eax
f01034df:	75 0c                	jne    f01034ed <user_mem_check+0x63>
f01034e1:	a1 44 82 29 f0       	mov    0xf0298244,%eax
f01034e6:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01034eb:	76 1b                	jbe    f0103508 <user_mem_check+0x7e>
			if (user_mem_check_addr != start)
f01034ed:	a1 44 82 29 f0       	mov    0xf0298244,%eax
f01034f2:	3b 45 0c             	cmp    0xc(%ebp),%eax
f01034f5:	74 2b                	je     f0103522 <user_mem_check+0x98>
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
f01034f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034fc:	a3 44 82 29 f0       	mov    %eax,0xf0298244
			return -E_FAULT;
f0103501:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103506:	eb 1f                	jmp    f0103527 <user_mem_check+0x9d>

	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
	pte_t* pte;	

	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f0103508:	05 00 10 00 00       	add    $0x1000,%eax
f010350d:	a3 44 82 29 f0       	mov    %eax,0xf0298244
f0103512:	a1 44 82 29 f0       	mov    0xf0298244,%eax
f0103517:	39 c6                	cmp    %eax,%esi
f0103519:	77 99                	ja     f01034b4 <user_mem_check+0x2a>
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
		}
	}

	return 0;
f010351b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103520:	eb 05                	jmp    f0103527 <user_mem_check+0x9d>
	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
			if (user_mem_check_addr != start)
			  user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
f0103522:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		}
	}

	return 0;
}
f0103527:	83 c4 1c             	add    $0x1c,%esp
f010352a:	5b                   	pop    %ebx
f010352b:	5e                   	pop    %esi
f010352c:	5f                   	pop    %edi
f010352d:	5d                   	pop    %ebp
f010352e:	c3                   	ret    

f010352f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010352f:	55                   	push   %ebp
f0103530:	89 e5                	mov    %esp,%ebp
f0103532:	53                   	push   %ebx
f0103533:	83 ec 14             	sub    $0x14,%esp
f0103536:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103539:	8b 45 14             	mov    0x14(%ebp),%eax
f010353c:	83 c8 04             	or     $0x4,%eax
f010353f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103543:	8b 45 10             	mov    0x10(%ebp),%eax
f0103546:	89 44 24 08          	mov    %eax,0x8(%esp)
f010354a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010354d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103551:	89 1c 24             	mov    %ebx,(%esp)
f0103554:	e8 31 ff ff ff       	call   f010348a <user_mem_check>
f0103559:	85 c0                	test   %eax,%eax
f010355b:	79 24                	jns    f0103581 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010355d:	a1 44 82 29 f0       	mov    0xf0298244,%eax
f0103562:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103566:	8b 43 48             	mov    0x48(%ebx),%eax
f0103569:	89 44 24 04          	mov    %eax,0x4(%esp)
f010356d:	c7 04 24 08 8a 10 f0 	movl   $0xf0108a08,(%esp)
f0103574:	e8 b5 09 00 00       	call   f0103f2e <cprintf>
					"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103579:	89 1c 24             	mov    %ebx,(%esp)
f010357c:	e8 d1 06 00 00       	call   f0103c52 <env_destroy>
	}
}
f0103581:	83 c4 14             	add    $0x14,%esp
f0103584:	5b                   	pop    %ebx
f0103585:	5d                   	pop    %ebp
f0103586:	c3                   	ret    
	...

f0103588 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103588:	55                   	push   %ebp
f0103589:	89 e5                	mov    %esp,%ebp
f010358b:	57                   	push   %edi
f010358c:	56                   	push   %esi
f010358d:	53                   	push   %ebx
f010358e:	83 ec 1c             	sub    $0x1c,%esp
f0103591:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
f0103593:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f010359a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010359f:	89 c7                	mov    %eax,%edi
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
f01035a1:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f01035a6:	77 0d                	ja     f01035b5 <region_alloc+0x2d>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
f01035a8:	89 d3                	mov    %edx,%ebx
f01035aa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01035b0:	e9 89 00 00 00       	jmp    f010363e <region_alloc+0xb6>
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
f01035b5:	c7 44 24 08 b4 8d 10 	movl   $0xf0108db4,0x8(%esp)
f01035bc:	f0 
f01035bd:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f01035c4:	00 
f01035c5:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f01035cc:	e8 6f ca ff ff       	call   f0100040 <_panic>
	int r;
	for (; min<max; min+=PGSIZE){
		pp = page_alloc(0);	
f01035d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035d8:	e8 fe d9 ff ff       	call   f0100fdb <page_alloc>
		if (!pp) 	
f01035dd:	85 c0                	test   %eax,%eax
f01035df:	75 1c                	jne    f01035fd <region_alloc+0x75>
			panic("region_alloc:page alloc failed");
f01035e1:	c7 44 24 08 d4 8d 10 	movl   $0xf0108dd4,0x8(%esp)
f01035e8:	f0 
f01035e9:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01035f0:	00 
f01035f1:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f01035f8:	e8 43 ca ff ff       	call   f0100040 <_panic>
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
f01035fd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103604:	00 
f0103605:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103609:	89 44 24 04          	mov    %eax,0x4(%esp)
f010360d:	8b 46 60             	mov    0x60(%esi),%eax
f0103610:	89 04 24             	mov    %eax,(%esp)
f0103613:	e8 5d dd ff ff       	call   f0101375 <page_insert>
		if (r != 0) 
f0103618:	85 c0                	test   %eax,%eax
f010361a:	74 1c                	je     f0103638 <region_alloc+0xb0>
			panic("region_alloc: page insert failed");
f010361c:	c7 44 24 08 f4 8d 10 	movl   $0xf0108df4,0x8(%esp)
f0103623:	f0 
f0103624:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f010362b:	00 
f010362c:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103633:	e8 08 ca ff ff       	call   f0100040 <_panic>
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
	int r;
	for (; min<max; min+=PGSIZE){
f0103638:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010363e:	39 fb                	cmp    %edi,%ebx
f0103640:	72 8f                	jb     f01035d1 <region_alloc+0x49>
			panic("region_alloc:page alloc failed");
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
		if (r != 0) 
			panic("region_alloc: page insert failed");
	}
}
f0103642:	83 c4 1c             	add    $0x1c,%esp
f0103645:	5b                   	pop    %ebx
f0103646:	5e                   	pop    %esi
f0103647:	5f                   	pop    %edi
f0103648:	5d                   	pop    %ebp
f0103649:	c3                   	ret    

f010364a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010364a:	55                   	push   %ebp
f010364b:	89 e5                	mov    %esp,%ebp
f010364d:	57                   	push   %edi
f010364e:	56                   	push   %esi
f010364f:	53                   	push   %ebx
f0103650:	83 ec 0c             	sub    $0xc,%esp
f0103653:	8b 45 08             	mov    0x8(%ebp),%eax
f0103656:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103659:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010365c:	85 c0                	test   %eax,%eax
f010365e:	75 21                	jne    f0103681 <envid2env+0x37>
		*env_store = curenv;
f0103660:	e8 37 32 00 00       	call   f010689c <cpunum>
f0103665:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010366c:	29 c2                	sub    %eax,%edx
f010366e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103671:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0103678:	89 06                	mov    %eax,(%esi)
		return 0;
f010367a:	b8 00 00 00 00       	mov    $0x0,%eax
f010367f:	eb 7b                	jmp    f01036fc <envid2env+0xb2>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103681:	89 c3                	mov    %eax,%ebx
f0103683:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103689:	c1 e3 07             	shl    $0x7,%ebx
f010368c:	03 1d 48 82 29 f0    	add    0xf0298248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103692:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103696:	74 05                	je     f010369d <envid2env+0x53>
f0103698:	39 43 48             	cmp    %eax,0x48(%ebx)
f010369b:	74 0d                	je     f01036aa <envid2env+0x60>
		*env_store = 0;
f010369d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036a3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036a8:	eb 52                	jmp    f01036fc <envid2env+0xb2>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01036aa:	84 d2                	test   %dl,%dl
f01036ac:	74 47                	je     f01036f5 <envid2env+0xab>
f01036ae:	e8 e9 31 00 00       	call   f010689c <cpunum>
f01036b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036ba:	29 c2                	sub    %eax,%edx
f01036bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036bf:	39 1c 85 28 90 29 f0 	cmp    %ebx,-0xfd66fd8(,%eax,4)
f01036c6:	74 2d                	je     f01036f5 <envid2env+0xab>
f01036c8:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01036cb:	e8 cc 31 00 00       	call   f010689c <cpunum>
f01036d0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01036d7:	29 c2                	sub    %eax,%edx
f01036d9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01036dc:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f01036e3:	3b 78 48             	cmp    0x48(%eax),%edi
f01036e6:	74 0d                	je     f01036f5 <envid2env+0xab>
		*env_store = 0;
f01036e8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01036ee:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036f3:	eb 07                	jmp    f01036fc <envid2env+0xb2>
	}

	*env_store = e;
f01036f5:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01036f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036fc:	83 c4 0c             	add    $0xc,%esp
f01036ff:	5b                   	pop    %ebx
f0103700:	5e                   	pop    %esi
f0103701:	5f                   	pop    %edi
f0103702:	5d                   	pop    %ebp
f0103703:	c3                   	ret    

f0103704 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103704:	55                   	push   %ebp
f0103705:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103707:	b8 20 d3 12 f0       	mov    $0xf012d320,%eax
f010370c:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010370f:	b8 23 00 00 00       	mov    $0x23,%eax
f0103714:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103716:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103718:	b0 10                	mov    $0x10,%al
f010371a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010371c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010371e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103720:	ea 27 37 10 f0 08 00 	ljmp   $0x8,$0xf0103727
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103727:	b0 00                	mov    $0x0,%al
f0103729:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010372c:	5d                   	pop    %ebp
f010372d:	c3                   	ret    

f010372e <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010372e:	55                   	push   %ebp
f010372f:	89 e5                	mov    %esp,%ebp
f0103731:	56                   	push   %esi
f0103732:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f0103733:	8b 35 48 82 29 f0    	mov    0xf0298248,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103739:	8d 86 80 ff 01 00    	lea    0x1ff80(%esi),%eax
f010373f:	b9 00 00 00 00       	mov    $0x0,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f0103744:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0103749:	eb 02                	jmp    f010374d <env_init+0x1f>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f010374b:	89 d9                	mov    %ebx,%ecx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f010374d:	89 c3                	mov    %eax,%ebx
f010374f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0103756:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010375d:	89 48 44             	mov    %ecx,0x44(%eax)
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f0103760:	4a                   	dec    %edx
f0103761:	83 c0 80             	add    $0xffffff80,%eax
f0103764:	83 fa ff             	cmp    $0xffffffff,%edx
f0103767:	75 e2                	jne    f010374b <env_init+0x1d>
f0103769:	89 35 4c 82 29 f0    	mov    %esi,0xf029824c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f010376f:	e8 90 ff ff ff       	call   f0103704 <env_init_percpu>
}
f0103774:	5b                   	pop    %ebx
f0103775:	5e                   	pop    %esi
f0103776:	5d                   	pop    %ebp
f0103777:	c3                   	ret    

f0103778 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103778:	55                   	push   %ebp
f0103779:	89 e5                	mov    %esp,%ebp
f010377b:	56                   	push   %esi
f010377c:	53                   	push   %ebx
f010377d:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103780:	8b 1d 4c 82 29 f0    	mov    0xf029824c,%ebx
f0103786:	85 db                	test   %ebx,%ebx
f0103788:	0f 84 4e 01 00 00    	je     f01038dc <env_alloc+0x164>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010378e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103795:	e8 41 d8 ff ff       	call   f0100fdb <page_alloc>
f010379a:	89 c6                	mov    %eax,%esi
f010379c:	85 c0                	test   %eax,%eax
f010379e:	0f 84 3f 01 00 00    	je     f01038e3 <env_alloc+0x16b>
f01037a4:	2b 05 9c 8e 29 f0    	sub    0xf0298e9c,%eax
f01037aa:	c1 f8 03             	sar    $0x3,%eax
f01037ad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037b0:	89 c2                	mov    %eax,%edx
f01037b2:	c1 ea 0c             	shr    $0xc,%edx
f01037b5:	3b 15 94 8e 29 f0    	cmp    0xf0298e94,%edx
f01037bb:	72 20                	jb     f01037dd <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037c1:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01037c8:	f0 
f01037c9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037d0:	00 
f01037d1:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f01037d8:	e8 63 c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037dd:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	e->env_pgdir = page2kva(p);
f01037e2:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);	
f01037e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037ec:	00 
f01037ed:	8b 15 98 8e 29 f0    	mov    0xf0298e98,%edx
f01037f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037f7:	89 04 24             	mov    %eax,(%esp)
f01037fa:	e8 23 2b 00 00       	call   f0106322 <memcpy>
	p->pp_ref++;
f01037ff:	66 ff 46 04          	incw   0x4(%esi)


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103803:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103806:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010380b:	77 20                	ja     f010382d <env_alloc+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010380d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103811:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0103818:	f0 
f0103819:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103820:	00 
f0103821:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103828:	e8 13 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010382d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103833:	83 ca 05             	or     $0x5,%edx
f0103836:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010383c:	8b 43 48             	mov    0x48(%ebx),%eax
f010383f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103844:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103849:	7f 05                	jg     f0103850 <env_alloc+0xd8>
		generation = 1 << ENVGENSHIFT;
f010384b:	b8 00 10 00 00       	mov    $0x1000,%eax
	e->env_id = generation | (e - envs);
f0103850:	89 da                	mov    %ebx,%edx
f0103852:	2b 15 48 82 29 f0    	sub    0xf0298248,%edx
f0103858:	c1 fa 07             	sar    $0x7,%edx
f010385b:	09 d0                	or     %edx,%eax
f010385d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103860:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103863:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103866:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010386d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103874:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010387b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103882:	00 
f0103883:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010388a:	00 
f010388b:	89 1c 24             	mov    %ebx,(%esp)
f010388e:	e8 db 29 00 00       	call   f010626e <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103893:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103899:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010389f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01038a5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038ac:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF; 
f01038b2:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
		
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01038b9:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01038c0:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01038c4:	8b 43 44             	mov    0x44(%ebx),%eax
f01038c7:	a3 4c 82 29 f0       	mov    %eax,0xf029824c
	*newenv_store = e;
f01038cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01038cf:	89 18                	mov    %ebx,(%eax)
	
	e->env_e1000_waiting_rx = false;
f01038d1:	c6 43 7c 00          	movb   $0x0,0x7c(%ebx)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01038d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01038da:	eb 0c                	jmp    f01038e8 <env_alloc+0x170>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01038dc:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038e1:	eb 05                	jmp    f01038e8 <env_alloc+0x170>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01038e3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	
	e->env_e1000_waiting_rx = false;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01038e8:	83 c4 10             	add    $0x10,%esp
f01038eb:	5b                   	pop    %ebx
f01038ec:	5e                   	pop    %esi
f01038ed:	5d                   	pop    %ebp
f01038ee:	c3                   	ret    

f01038ef <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01038ef:	55                   	push   %ebp
f01038f0:	89 e5                	mov    %esp,%ebp
f01038f2:	57                   	push   %edi
f01038f3:	56                   	push   %esi
f01038f4:	53                   	push   %ebx
f01038f5:	83 ec 3c             	sub    $0x3c,%esp
f01038f8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.

	struct Env* e;
	int ret = env_alloc(&e, 0);
f01038fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103905:	00 
f0103906:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103909:	89 04 24             	mov    %eax,(%esp)
f010390c:	e8 67 fe ff ff       	call   f0103778 <env_alloc>
	if (ret == -E_NO_FREE_ENV )
f0103911:	83 f8 fb             	cmp    $0xfffffffb,%eax
f0103914:	75 24                	jne    f010393a <env_create+0x4b>
		panic("env_create:failed no free env %e", ret);
f0103916:	c7 44 24 0c fb ff ff 	movl   $0xfffffffb,0xc(%esp)
f010391d:	ff 
f010391e:	c7 44 24 08 18 8e 10 	movl   $0xf0108e18,0x8(%esp)
f0103925:	f0 
f0103926:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
f010392d:	00 
f010392e:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103935:	e8 06 c7 ff ff       	call   f0100040 <_panic>
	if (ret == -E_NO_MEM)
f010393a:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010393d:	75 24                	jne    f0103963 <env_create+0x74>
		panic("env_create:failed no free mem %e", ret);
f010393f:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f0103946:	ff 
f0103947:	c7 44 24 08 3c 8e 10 	movl   $0xf0108e3c,0x8(%esp)
f010394e:	f0 
f010394f:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0103956:	00 
f0103957:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f010395e:	e8 dd c6 ff ff       	call   f0100040 <_panic>
	e->env_type = type;
f0103963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103966:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103969:	89 58 50             	mov    %ebx,0x50(%eax)
	if (type == ENV_TYPE_FS) 
f010396c:	83 fb 01             	cmp    $0x1,%ebx
f010396f:	75 07                	jne    f0103978 <env_create+0x89>
		e->env_tf.tf_eflags |= FL_IOPL_3;
f0103971:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf*)binary;  //elf header
	if (elf->e_magic != ELF_MAGIC) 
f0103978:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010397e:	74 1c                	je     f010399c <env_create+0xad>
		panic("load_icode: illegal elf header");
f0103980:	c7 44 24 08 60 8e 10 	movl   $0xf0108e60,0x8(%esp)
f0103987:	f0 
f0103988:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f010398f:	00 
f0103990:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103997:	e8 a4 c6 ff ff       	call   f0100040 <_panic>
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
f010399c:	89 fb                	mov    %edi,%ebx
f010399e:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* eph = ph + elf->e_phnum;
f01039a1:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01039a5:	c1 e6 05             	shl    $0x5,%esi
f01039a8:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f01039aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039ad:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039b5:	77 20                	ja     f01039d7 <env_create+0xe8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039bb:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f01039c2:	f0 
f01039c3:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f01039ca:	00 
f01039cb:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f01039d2:	e8 69 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039d7:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01039dc:	0f 22 d8             	mov    %eax,%cr3
f01039df:	eb 71                	jmp    f0103a52 <env_create+0x163>

	for (; ph < eph; ph++) {
		if(ph->p_type != ELF_PROG_LOAD)
f01039e1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039e4:	75 69                	jne    f0103a4f <env_create+0x160>
			continue;
		if (ph->p_filesz > ph->p_memsz) 
f01039e6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039e9:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01039ec:	76 1c                	jbe    f0103a0a <env_create+0x11b>
			panic("load_icode:file size is larger than mem size");
f01039ee:	c7 44 24 08 80 8e 10 	movl   $0xf0108e80,0x8(%esp)
f01039f5:	f0 
f01039f6:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f01039fd:	00 
f01039fe:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103a05:	e8 36 c6 ff ff       	call   f0100040 <_panic>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
f0103a0a:	8b 53 08             	mov    0x8(%ebx),%edx
f0103a0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a10:	e8 73 fb ff ff       	call   f0103588 <region_alloc>
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103a15:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a18:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a1c:	89 f8                	mov    %edi,%eax
f0103a1e:	03 43 04             	add    0x4(%ebx),%eax
f0103a21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a25:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a28:	89 04 24             	mov    %eax,(%esp)
f0103a2b:	e8 88 28 00 00       	call   f01062b8 <memmove>
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
f0103a30:	8b 43 10             	mov    0x10(%ebx),%eax
f0103a33:	8b 53 14             	mov    0x14(%ebx),%edx
f0103a36:	29 c2                	sub    %eax,%edx
f0103a38:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103a43:	00 
f0103a44:	03 43 08             	add    0x8(%ebx),%eax
f0103a47:	89 04 24             	mov    %eax,(%esp)
f0103a4a:	e8 1f 28 00 00       	call   f010626e <memset>
		panic("load_icode: illegal elf header");
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
	struct Proghdr* eph = ph + elf->e_phnum;
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++) {
f0103a4f:	83 c3 20             	add    $0x20,%ebx
f0103a52:	39 de                	cmp    %ebx,%esi
f0103a54:	77 8b                	ja     f01039e1 <env_create+0xf2>
			panic("load_icode:file size is larger than mem size");
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
	}
	e->env_tf.tf_eip = elf->e_entry; 
f0103a56:	8b 47 18             	mov    0x18(%edi),%eax
f0103a59:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103a5c:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	//lcr3(PADDR(kern_pgdir));
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);		
f0103a5f:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a64:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a6c:	e8 17 fb ff ff       	call   f0103588 <region_alloc>
	if (type == ENV_TYPE_FS) 
		e->env_tf.tf_eflags |= FL_IOPL_3;
	
	load_icode(e, binary);

}
f0103a71:	83 c4 3c             	add    $0x3c,%esp
f0103a74:	5b                   	pop    %ebx
f0103a75:	5e                   	pop    %esi
f0103a76:	5f                   	pop    %edi
f0103a77:	5d                   	pop    %ebp
f0103a78:	c3                   	ret    

f0103a79 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a79:	55                   	push   %ebp
f0103a7a:	89 e5                	mov    %esp,%ebp
f0103a7c:	57                   	push   %edi
f0103a7d:	56                   	push   %esi
f0103a7e:	53                   	push   %ebx
f0103a7f:	83 ec 2c             	sub    $0x2c,%esp
f0103a82:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a85:	e8 12 2e 00 00       	call   f010689c <cpunum>
f0103a8a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a91:	29 c2                	sub    %eax,%edx
f0103a93:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a96:	39 3c 85 28 90 29 f0 	cmp    %edi,-0xfd66fd8(,%eax,4)
f0103a9d:	75 3d                	jne    f0103adc <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f0103a9f:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103aa4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103aa9:	77 20                	ja     f0103acb <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103aab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aaf:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0103ab6:	f0 
f0103ab7:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
f0103abe:	00 
f0103abf:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103ac6:	e8 75 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103acb:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ad0:	0f 22 d8             	mov    %eax,%cr3
f0103ad3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103ada:	eb 07                	jmp    f0103ae3 <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103adc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103ae3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ae6:	c1 e0 02             	shl    $0x2,%eax
f0103ae9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103aec:	8b 47 60             	mov    0x60(%edi),%eax
f0103aef:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103af2:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103af5:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103afb:	0f 84 b6 00 00 00    	je     f0103bb7 <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b01:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b07:	89 f0                	mov    %esi,%eax
f0103b09:	c1 e8 0c             	shr    $0xc,%eax
f0103b0c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b0f:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f0103b15:	72 20                	jb     f0103b37 <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b17:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b1b:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0103b22:	f0 
f0103b23:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f0103b2a:	00 
f0103b2b:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103b32:	e8 09 c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b37:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b3a:	c1 e2 16             	shl    $0x16,%edx
f0103b3d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b40:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b45:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b4c:	01 
f0103b4d:	74 17                	je     f0103b66 <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b4f:	89 d8                	mov    %ebx,%eax
f0103b51:	c1 e0 0c             	shl    $0xc,%eax
f0103b54:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b5b:	8b 47 60             	mov    0x60(%edi),%eax
f0103b5e:	89 04 24             	mov    %eax,(%esp)
f0103b61:	e8 bf d7 ff ff       	call   f0101325 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b66:	43                   	inc    %ebx
f0103b67:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b6d:	75 d6                	jne    f0103b45 <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b6f:	8b 47 60             	mov    0x60(%edi),%eax
f0103b72:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b75:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b7c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b7f:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f0103b85:	72 1c                	jb     f0103ba3 <env_free+0x12a>
		panic("pa2page called with invalid pa");
f0103b87:	c7 44 24 08 04 82 10 	movl   $0xf0108204,0x8(%esp)
f0103b8e:	f0 
f0103b8f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b96:	00 
f0103b97:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0103b9e:	e8 9d c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103ba3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ba6:	c1 e0 03             	shl    $0x3,%eax
f0103ba9:	03 05 9c 8e 29 f0    	add    0xf0298e9c,%eax
		page_decref(pa2page(pa));
f0103baf:	89 04 24             	mov    %eax,(%esp)
f0103bb2:	e8 33 d5 ff ff       	call   f01010ea <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103bb7:	ff 45 e0             	incl   -0x20(%ebp)
f0103bba:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bc1:	0f 85 1c ff ff ff    	jne    f0103ae3 <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bc7:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bcf:	77 20                	ja     f0103bf1 <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bd5:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0103bdc:	f0 
f0103bdd:	c7 44 24 04 d2 01 00 	movl   $0x1d2,0x4(%esp)
f0103be4:	00 
f0103be5:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103bec:	e8 4f c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103bf1:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103bf8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103bfd:	c1 e8 0c             	shr    $0xc,%eax
f0103c00:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f0103c06:	72 1c                	jb     f0103c24 <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103c08:	c7 44 24 08 04 82 10 	movl   $0xf0108204,0x8(%esp)
f0103c0f:	f0 
f0103c10:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c17:	00 
f0103c18:	c7 04 24 49 8a 10 f0 	movl   $0xf0108a49,(%esp)
f0103c1f:	e8 1c c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c24:	c1 e0 03             	shl    $0x3,%eax
f0103c27:	03 05 9c 8e 29 f0    	add    0xf0298e9c,%eax
	page_decref(pa2page(pa));
f0103c2d:	89 04 24             	mov    %eax,(%esp)
f0103c30:	e8 b5 d4 ff ff       	call   f01010ea <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c35:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c3c:	a1 4c 82 29 f0       	mov    0xf029824c,%eax
f0103c41:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c44:	89 3d 4c 82 29 f0    	mov    %edi,0xf029824c
}
f0103c4a:	83 c4 2c             	add    $0x2c,%esp
f0103c4d:	5b                   	pop    %ebx
f0103c4e:	5e                   	pop    %esi
f0103c4f:	5f                   	pop    %edi
f0103c50:	5d                   	pop    %ebp
f0103c51:	c3                   	ret    

f0103c52 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c52:	55                   	push   %ebp
f0103c53:	89 e5                	mov    %esp,%ebp
f0103c55:	53                   	push   %ebx
f0103c56:	83 ec 14             	sub    $0x14,%esp
f0103c59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c5c:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c60:	75 23                	jne    f0103c85 <env_destroy+0x33>
f0103c62:	e8 35 2c 00 00       	call   f010689c <cpunum>
f0103c67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c6e:	29 c2                	sub    %eax,%edx
f0103c70:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c73:	39 1c 85 28 90 29 f0 	cmp    %ebx,-0xfd66fd8(,%eax,4)
f0103c7a:	74 09                	je     f0103c85 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103c7c:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c83:	eb 39                	jmp    f0103cbe <env_destroy+0x6c>
	}

	env_free(e);
f0103c85:	89 1c 24             	mov    %ebx,(%esp)
f0103c88:	e8 ec fd ff ff       	call   f0103a79 <env_free>

	if (curenv == e) {
f0103c8d:	e8 0a 2c 00 00       	call   f010689c <cpunum>
f0103c92:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c99:	29 c2                	sub    %eax,%edx
f0103c9b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c9e:	39 1c 85 28 90 29 f0 	cmp    %ebx,-0xfd66fd8(,%eax,4)
f0103ca5:	75 17                	jne    f0103cbe <env_destroy+0x6c>
		curenv = NULL;
f0103ca7:	e8 f0 2b 00 00       	call   f010689c <cpunum>
f0103cac:	6b c0 74             	imul   $0x74,%eax,%eax
f0103caf:	c7 80 28 90 29 f0 00 	movl   $0x0,-0xfd66fd8(%eax)
f0103cb6:	00 00 00 
		sched_yield();
f0103cb9:	e8 90 10 00 00       	call   f0104d4e <sched_yield>
	}
}
f0103cbe:	83 c4 14             	add    $0x14,%esp
f0103cc1:	5b                   	pop    %ebx
f0103cc2:	5d                   	pop    %ebp
f0103cc3:	c3                   	ret    

f0103cc4 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103cc4:	55                   	push   %ebp
f0103cc5:	89 e5                	mov    %esp,%ebp
f0103cc7:	53                   	push   %ebx
f0103cc8:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ccb:	e8 cc 2b 00 00       	call   f010689c <cpunum>
f0103cd0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cd7:	29 c2                	sub    %eax,%edx
f0103cd9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cdc:	8b 1c 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%ebx
f0103ce3:	e8 b4 2b 00 00       	call   f010689c <cpunum>
f0103ce8:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103ceb:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cee:	61                   	popa   
f0103cef:	07                   	pop    %es
f0103cf0:	1f                   	pop    %ds
f0103cf1:	83 c4 08             	add    $0x8,%esp
f0103cf4:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103cf5:	c7 44 24 08 b8 8e 10 	movl   $0xf0108eb8,0x8(%esp)
f0103cfc:	f0 
f0103cfd:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
f0103d04:	00 
f0103d05:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103d0c:	e8 2f c3 ff ff       	call   f0100040 <_panic>

f0103d11 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103d11:	55                   	push   %ebp
f0103d12:	89 e5                	mov    %esp,%ebp
f0103d14:	53                   	push   %ebx
f0103d15:	83 ec 14             	sub    $0x14,%esp
f0103d18:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.
	
	//panic("env_run not yet implemented");
	
	if (curenv){
f0103d1b:	e8 7c 2b 00 00       	call   f010689c <cpunum>
f0103d20:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d27:	29 c2                	sub    %eax,%edx
f0103d29:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d2c:	83 3c 85 28 90 29 f0 	cmpl   $0x0,-0xfd66fd8(,%eax,4)
f0103d33:	00 
f0103d34:	74 33                	je     f0103d69 <env_run+0x58>
		if (curenv->env_status == ENV_RUNNING) 
f0103d36:	e8 61 2b 00 00       	call   f010689c <cpunum>
f0103d3b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d42:	29 c2                	sub    %eax,%edx
f0103d44:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d47:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0103d4e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d52:	75 15                	jne    f0103d69 <env_run+0x58>
			curenv->env_status = ENV_RUNNABLE;
f0103d54:	e8 43 2b 00 00       	call   f010689c <cpunum>
f0103d59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d5c:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0103d62:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	
	curenv = e;
f0103d69:	e8 2e 2b 00 00       	call   f010689c <cpunum>
f0103d6e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d75:	29 c2                	sub    %eax,%edx
f0103d77:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d7a:	89 1c 85 28 90 29 f0 	mov    %ebx,-0xfd66fd8(,%eax,4)
	e->env_status = ENV_RUNNING;
f0103d81:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103d88:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0103d8b:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d8e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d93:	77 20                	ja     f0103db5 <env_run+0xa4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d99:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0103da0:	f0 
f0103da1:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0103da8:	00 
f0103da9:	c7 04 24 ad 8e 10 f0 	movl   $0xf0108ead,(%esp)
f0103db0:	e8 8b c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103db5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103dba:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103dbd:	c7 04 24 c0 d3 12 f0 	movl   $0xf012d3c0,(%esp)
f0103dc4:	e8 35 2e 00 00       	call   f0106bfe <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103dc9:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&(e->env_tf));		
f0103dcb:	89 1c 24             	mov    %ebx,(%esp)
f0103dce:	e8 f1 fe ff ff       	call   f0103cc4 <env_pop_tf>
	...

f0103dd4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103dd4:	55                   	push   %ebp
f0103dd5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103dd7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ddc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ddf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103de0:	b2 71                	mov    $0x71,%dl
f0103de2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103de3:	0f b6 c0             	movzbl %al,%eax
}
f0103de6:	5d                   	pop    %ebp
f0103de7:	c3                   	ret    

f0103de8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103de8:	55                   	push   %ebp
f0103de9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103deb:	ba 70 00 00 00       	mov    $0x70,%edx
f0103df0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103df3:	ee                   	out    %al,(%dx)
f0103df4:	b2 71                	mov    $0x71,%dl
f0103df6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103df9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103dfa:	5d                   	pop    %ebp
f0103dfb:	c3                   	ret    

f0103dfc <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103dfc:	55                   	push   %ebp
f0103dfd:	89 e5                	mov    %esp,%ebp
f0103dff:	56                   	push   %esi
f0103e00:	53                   	push   %ebx
f0103e01:	83 ec 10             	sub    $0x10,%esp
f0103e04:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	irq_mask_8259A = mask;
	irq_mask_8259A &= ~(1 << IRQ_E1000);
f0103e07:	89 f0                	mov    %esi,%eax
f0103e09:	80 e4 f7             	and    $0xf7,%ah
f0103e0c:	66 a3 a8 d3 12 f0    	mov    %ax,0xf012d3a8
	if (!didinit)
f0103e12:	80 3d 50 82 29 f0 00 	cmpb   $0x0,0xf0298250
f0103e19:	74 53                	je     f0103e6e <irq_setmask_8259A+0x72>
f0103e1b:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e20:	89 f0                	mov    %esi,%eax
f0103e22:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e23:	89 f0                	mov    %esi,%eax
f0103e25:	66 c1 e8 08          	shr    $0x8,%ax
f0103e29:	b2 a1                	mov    $0xa1,%dl
f0103e2b:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e2c:	c7 04 24 c4 8e 10 f0 	movl   $0xf0108ec4,(%esp)
f0103e33:	e8 f6 00 00 00       	call   f0103f2e <cprintf>
	for (i = 0; i < 16; i++)
f0103e38:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e3d:	0f b7 f6             	movzwl %si,%esi
f0103e40:	f7 d6                	not    %esi
f0103e42:	89 f0                	mov    %esi,%eax
f0103e44:	88 d9                	mov    %bl,%cl
f0103e46:	d3 f8                	sar    %cl,%eax
f0103e48:	a8 01                	test   $0x1,%al
f0103e4a:	74 10                	je     f0103e5c <irq_setmask_8259A+0x60>
			cprintf(" %d", i);
f0103e4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e50:	c7 04 24 1b 96 10 f0 	movl   $0xf010961b,(%esp)
f0103e57:	e8 d2 00 00 00       	call   f0103f2e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e5c:	43                   	inc    %ebx
f0103e5d:	83 fb 10             	cmp    $0x10,%ebx
f0103e60:	75 e0                	jne    f0103e42 <irq_setmask_8259A+0x46>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e62:	c7 04 24 7f 8d 10 f0 	movl   $0xf0108d7f,(%esp)
f0103e69:	e8 c0 00 00 00       	call   f0103f2e <cprintf>
}
f0103e6e:	83 c4 10             	add    $0x10,%esp
f0103e71:	5b                   	pop    %ebx
f0103e72:	5e                   	pop    %esi
f0103e73:	5d                   	pop    %ebp
f0103e74:	c3                   	ret    

f0103e75 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e75:	55                   	push   %ebp
f0103e76:	89 e5                	mov    %esp,%ebp
f0103e78:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103e7b:	c6 05 50 82 29 f0 01 	movb   $0x1,0xf0298250
f0103e82:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e87:	b0 ff                	mov    $0xff,%al
f0103e89:	ee                   	out    %al,(%dx)
f0103e8a:	b2 a1                	mov    $0xa1,%dl
f0103e8c:	ee                   	out    %al,(%dx)
f0103e8d:	b2 20                	mov    $0x20,%dl
f0103e8f:	b0 11                	mov    $0x11,%al
f0103e91:	ee                   	out    %al,(%dx)
f0103e92:	b2 21                	mov    $0x21,%dl
f0103e94:	b0 20                	mov    $0x20,%al
f0103e96:	ee                   	out    %al,(%dx)
f0103e97:	b0 04                	mov    $0x4,%al
f0103e99:	ee                   	out    %al,(%dx)
f0103e9a:	b0 03                	mov    $0x3,%al
f0103e9c:	ee                   	out    %al,(%dx)
f0103e9d:	b2 a0                	mov    $0xa0,%dl
f0103e9f:	b0 11                	mov    $0x11,%al
f0103ea1:	ee                   	out    %al,(%dx)
f0103ea2:	b2 a1                	mov    $0xa1,%dl
f0103ea4:	b0 28                	mov    $0x28,%al
f0103ea6:	ee                   	out    %al,(%dx)
f0103ea7:	b0 02                	mov    $0x2,%al
f0103ea9:	ee                   	out    %al,(%dx)
f0103eaa:	b0 01                	mov    $0x1,%al
f0103eac:	ee                   	out    %al,(%dx)
f0103ead:	b2 20                	mov    $0x20,%dl
f0103eaf:	b0 68                	mov    $0x68,%al
f0103eb1:	ee                   	out    %al,(%dx)
f0103eb2:	b0 0a                	mov    $0xa,%al
f0103eb4:	ee                   	out    %al,(%dx)
f0103eb5:	b2 a0                	mov    $0xa0,%dl
f0103eb7:	b0 68                	mov    $0x68,%al
f0103eb9:	ee                   	out    %al,(%dx)
f0103eba:	b0 0a                	mov    $0xa,%al
f0103ebc:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103ebd:	66 a1 a8 d3 12 f0    	mov    0xf012d3a8,%ax
f0103ec3:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103ec7:	74 0b                	je     f0103ed4 <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103ec9:	0f b7 c0             	movzwl %ax,%eax
f0103ecc:	89 04 24             	mov    %eax,(%esp)
f0103ecf:	e8 28 ff ff ff       	call   f0103dfc <irq_setmask_8259A>
}
f0103ed4:	c9                   	leave  
f0103ed5:	c3                   	ret    

f0103ed6 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103ed6:	55                   	push   %ebp
f0103ed7:	89 e5                	mov    %esp,%ebp
f0103ed9:	ba 20 00 00 00       	mov    $0x20,%edx
f0103ede:	b0 20                	mov    $0x20,%al
f0103ee0:	ee                   	out    %al,(%dx)
f0103ee1:	b2 a0                	mov    $0xa0,%dl
f0103ee3:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103ee4:	5d                   	pop    %ebp
f0103ee5:	c3                   	ret    
	...

f0103ee8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ee8:	55                   	push   %ebp
f0103ee9:	89 e5                	mov    %esp,%ebp
f0103eeb:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103eee:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ef1:	89 04 24             	mov    %eax,(%esp)
f0103ef4:	e8 ab c8 ff ff       	call   f01007a4 <cputchar>
	*cnt++;
}
f0103ef9:	c9                   	leave  
f0103efa:	c3                   	ret    

f0103efb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103efb:	55                   	push   %ebp
f0103efc:	89 e5                	mov    %esp,%ebp
f0103efe:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103f01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f12:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f16:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f19:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f1d:	c7 04 24 e8 3e 10 f0 	movl   $0xf0103ee8,(%esp)
f0103f24:	e8 f5 1c 00 00       	call   f0105c1e <vprintfmt>
	return cnt;
}
f0103f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f2c:	c9                   	leave  
f0103f2d:	c3                   	ret    

f0103f2e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f2e:	55                   	push   %ebp
f0103f2f:	89 e5                	mov    %esp,%ebp
f0103f31:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103f34:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103f37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f3b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f3e:	89 04 24             	mov    %eax,(%esp)
f0103f41:	e8 b5 ff ff ff       	call   f0103efb <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f46:	c9                   	leave  
f0103f47:	c3                   	ret    

f0103f48 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f48:	55                   	push   %ebp
f0103f49:	89 e5                	mov    %esp,%ebp
f0103f4b:	57                   	push   %edi
f0103f4c:	56                   	push   %esi
f0103f4d:	53                   	push   %ebx
f0103f4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum()*(KSTKSIZE+KSTKGAP);
f0103f51:	e8 46 29 00 00       	call   f010689c <cpunum>
f0103f56:	89 c3                	mov    %eax,%ebx
f0103f58:	e8 3f 29 00 00       	call   f010689c <cpunum>
f0103f5d:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103f64:	29 da                	sub    %ebx,%edx
f0103f66:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103f69:	f7 d8                	neg    %eax
f0103f6b:	c1 e0 10             	shl    $0x10,%eax
f0103f6e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103f73:	89 04 95 30 90 29 f0 	mov    %eax,-0xfd66fd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103f7a:	e8 1d 29 00 00       	call   f010689c <cpunum>
f0103f7f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f86:	29 c2                	sub    %eax,%edx
f0103f88:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f8b:	66 c7 04 85 34 90 29 	movw   $0x10,-0xfd66fcc(,%eax,4)
f0103f92:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103f95:	e8 02 29 00 00       	call   f010689c <cpunum>
f0103f9a:	8d 58 05             	lea    0x5(%eax),%ebx
f0103f9d:	e8 fa 28 00 00       	call   f010689c <cpunum>
f0103fa2:	89 c6                	mov    %eax,%esi
f0103fa4:	e8 f3 28 00 00       	call   f010689c <cpunum>
f0103fa9:	89 c7                	mov    %eax,%edi
f0103fab:	e8 ec 28 00 00       	call   f010689c <cpunum>
f0103fb0:	66 c7 04 dd 40 d3 12 	movw   $0x67,-0xfed2cc0(,%ebx,8)
f0103fb7:	f0 67 00 
f0103fba:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0103fc1:	29 f2                	sub    %esi,%edx
f0103fc3:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103fc6:	8d 14 95 2c 90 29 f0 	lea    -0xfd66fd4(,%edx,4),%edx
f0103fcd:	66 89 14 dd 42 d3 12 	mov    %dx,-0xfed2cbe(,%ebx,8)
f0103fd4:	f0 
f0103fd5:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103fdc:	29 fa                	sub    %edi,%edx
f0103fde:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103fe1:	8d 14 95 2c 90 29 f0 	lea    -0xfd66fd4(,%edx,4),%edx
f0103fe8:	c1 ea 10             	shr    $0x10,%edx
f0103feb:	88 14 dd 44 d3 12 f0 	mov    %dl,-0xfed2cbc(,%ebx,8)
f0103ff2:	c6 04 dd 45 d3 12 f0 	movb   $0x99,-0xfed2cbb(,%ebx,8)
f0103ff9:	99 
f0103ffa:	c6 04 dd 46 d3 12 f0 	movb   $0x40,-0xfed2cba(,%ebx,8)
f0104001:	40 
f0104002:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104009:	29 c2                	sub    %eax,%edx
f010400b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010400e:	8d 04 85 2c 90 29 f0 	lea    -0xfd66fd4(,%eax,4),%eax
f0104015:	c1 e8 18             	shr    $0x18,%eax
f0104018:	88 04 dd 47 d3 12 f0 	mov    %al,-0xfed2cb9(,%ebx,8)
				sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f010401f:	e8 78 28 00 00       	call   f010689c <cpunum>
f0104024:	80 24 c5 6d d3 12 f0 	andb   $0xef,-0xfed2c93(,%eax,8)
f010402b:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + cpunum()*sizeof(struct Segdesc));
f010402c:	e8 6b 28 00 00       	call   f010689c <cpunum>
f0104031:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104038:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010403b:	b8 ac d3 12 f0       	mov    $0xf012d3ac,%eax
f0104040:	0f 01 18             	lidtl  (%eax)
	
	// Load the IDT
	lidt(&idt_pd);
}
f0104043:	83 c4 0c             	add    $0xc,%esp
f0104046:	5b                   	pop    %ebx
f0104047:	5e                   	pop    %esi
f0104048:	5f                   	pop    %edi
f0104049:	5d                   	pop    %ebp
f010404a:	c3                   	ret    

f010404b <trap_init>:
}


void
trap_init(void)
{
f010404b:	55                   	push   %ebp
f010404c:	89 e5                	mov    %esp,%ebp
f010404e:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0104051:	b8 48 4b 10 f0       	mov    $0xf0104b48,%eax
f0104056:	66 a3 60 82 29 f0    	mov    %ax,0xf0298260
f010405c:	66 c7 05 62 82 29 f0 	movw   $0x8,0xf0298262
f0104063:	08 00 
f0104065:	c6 05 64 82 29 f0 00 	movb   $0x0,0xf0298264
f010406c:	c6 05 65 82 29 f0 8e 	movb   $0x8e,0xf0298265
f0104073:	c1 e8 10             	shr    $0x10,%eax
f0104076:	66 a3 66 82 29 f0    	mov    %ax,0xf0298266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f010407c:	b8 52 4b 10 f0       	mov    $0xf0104b52,%eax
f0104081:	66 a3 68 82 29 f0    	mov    %ax,0xf0298268
f0104087:	66 c7 05 6a 82 29 f0 	movw   $0x8,0xf029826a
f010408e:	08 00 
f0104090:	c6 05 6c 82 29 f0 00 	movb   $0x0,0xf029826c
f0104097:	c6 05 6d 82 29 f0 8e 	movb   $0x8e,0xf029826d
f010409e:	c1 e8 10             	shr    $0x10,%eax
f01040a1:	66 a3 6e 82 29 f0    	mov    %ax,0xf029826e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01040a7:	b8 5c 4b 10 f0       	mov    $0xf0104b5c,%eax
f01040ac:	66 a3 70 82 29 f0    	mov    %ax,0xf0298270
f01040b2:	66 c7 05 72 82 29 f0 	movw   $0x8,0xf0298272
f01040b9:	08 00 
f01040bb:	c6 05 74 82 29 f0 00 	movb   $0x0,0xf0298274
f01040c2:	c6 05 75 82 29 f0 8e 	movb   $0x8e,0xf0298275
f01040c9:	c1 e8 10             	shr    $0x10,%eax
f01040cc:	66 a3 76 82 29 f0    	mov    %ax,0xf0298276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01040d2:	b8 66 4b 10 f0       	mov    $0xf0104b66,%eax
f01040d7:	66 a3 78 82 29 f0    	mov    %ax,0xf0298278
f01040dd:	66 c7 05 7a 82 29 f0 	movw   $0x8,0xf029827a
f01040e4:	08 00 
f01040e6:	c6 05 7c 82 29 f0 00 	movb   $0x0,0xf029827c
f01040ed:	c6 05 7d 82 29 f0 ee 	movb   $0xee,0xf029827d
f01040f4:	c1 e8 10             	shr    $0x10,%eax
f01040f7:	66 a3 7e 82 29 f0    	mov    %ax,0xf029827e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01040fd:	b8 70 4b 10 f0       	mov    $0xf0104b70,%eax
f0104102:	66 a3 80 82 29 f0    	mov    %ax,0xf0298280
f0104108:	66 c7 05 82 82 29 f0 	movw   $0x8,0xf0298282
f010410f:	08 00 
f0104111:	c6 05 84 82 29 f0 00 	movb   $0x0,0xf0298284
f0104118:	c6 05 85 82 29 f0 8e 	movb   $0x8e,0xf0298285
f010411f:	c1 e8 10             	shr    $0x10,%eax
f0104122:	66 a3 86 82 29 f0    	mov    %ax,0xf0298286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0104128:	b8 7a 4b 10 f0       	mov    $0xf0104b7a,%eax
f010412d:	66 a3 88 82 29 f0    	mov    %ax,0xf0298288
f0104133:	66 c7 05 8a 82 29 f0 	movw   $0x8,0xf029828a
f010413a:	08 00 
f010413c:	c6 05 8c 82 29 f0 00 	movb   $0x0,0xf029828c
f0104143:	c6 05 8d 82 29 f0 8e 	movb   $0x8e,0xf029828d
f010414a:	c1 e8 10             	shr    $0x10,%eax
f010414d:	66 a3 8e 82 29 f0    	mov    %ax,0xf029828e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0104153:	b8 84 4b 10 f0       	mov    $0xf0104b84,%eax
f0104158:	66 a3 90 82 29 f0    	mov    %ax,0xf0298290
f010415e:	66 c7 05 92 82 29 f0 	movw   $0x8,0xf0298292
f0104165:	08 00 
f0104167:	c6 05 94 82 29 f0 00 	movb   $0x0,0xf0298294
f010416e:	c6 05 95 82 29 f0 8e 	movb   $0x8e,0xf0298295
f0104175:	c1 e8 10             	shr    $0x10,%eax
f0104178:	66 a3 96 82 29 f0    	mov    %ax,0xf0298296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f010417e:	b8 8e 4b 10 f0       	mov    $0xf0104b8e,%eax
f0104183:	66 a3 98 82 29 f0    	mov    %ax,0xf0298298
f0104189:	66 c7 05 9a 82 29 f0 	movw   $0x8,0xf029829a
f0104190:	08 00 
f0104192:	c6 05 9c 82 29 f0 00 	movb   $0x0,0xf029829c
f0104199:	c6 05 9d 82 29 f0 8e 	movb   $0x8e,0xf029829d
f01041a0:	c1 e8 10             	shr    $0x10,%eax
f01041a3:	66 a3 9e 82 29 f0    	mov    %ax,0xf029829e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01041a9:	b8 98 4b 10 f0       	mov    $0xf0104b98,%eax
f01041ae:	66 a3 a0 82 29 f0    	mov    %ax,0xf02982a0
f01041b4:	66 c7 05 a2 82 29 f0 	movw   $0x8,0xf02982a2
f01041bb:	08 00 
f01041bd:	c6 05 a4 82 29 f0 00 	movb   $0x0,0xf02982a4
f01041c4:	c6 05 a5 82 29 f0 8e 	movb   $0x8e,0xf02982a5
f01041cb:	c1 e8 10             	shr    $0x10,%eax
f01041ce:	66 a3 a6 82 29 f0    	mov    %ax,0xf02982a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01041d4:	b8 a0 4b 10 f0       	mov    $0xf0104ba0,%eax
f01041d9:	66 a3 b0 82 29 f0    	mov    %ax,0xf02982b0
f01041df:	66 c7 05 b2 82 29 f0 	movw   $0x8,0xf02982b2
f01041e6:	08 00 
f01041e8:	c6 05 b4 82 29 f0 00 	movb   $0x0,0xf02982b4
f01041ef:	c6 05 b5 82 29 f0 8e 	movb   $0x8e,0xf02982b5
f01041f6:	c1 e8 10             	shr    $0x10,%eax
f01041f9:	66 a3 b6 82 29 f0    	mov    %ax,0xf02982b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01041ff:	b8 a8 4b 10 f0       	mov    $0xf0104ba8,%eax
f0104204:	66 a3 b8 82 29 f0    	mov    %ax,0xf02982b8
f010420a:	66 c7 05 ba 82 29 f0 	movw   $0x8,0xf02982ba
f0104211:	08 00 
f0104213:	c6 05 bc 82 29 f0 00 	movb   $0x0,0xf02982bc
f010421a:	c6 05 bd 82 29 f0 8e 	movb   $0x8e,0xf02982bd
f0104221:	c1 e8 10             	shr    $0x10,%eax
f0104224:	66 a3 be 82 29 f0    	mov    %ax,0xf02982be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010422a:	b8 b0 4b 10 f0       	mov    $0xf0104bb0,%eax
f010422f:	66 a3 c0 82 29 f0    	mov    %ax,0xf02982c0
f0104235:	66 c7 05 c2 82 29 f0 	movw   $0x8,0xf02982c2
f010423c:	08 00 
f010423e:	c6 05 c4 82 29 f0 00 	movb   $0x0,0xf02982c4
f0104245:	c6 05 c5 82 29 f0 8e 	movb   $0x8e,0xf02982c5
f010424c:	c1 e8 10             	shr    $0x10,%eax
f010424f:	66 a3 c6 82 29 f0    	mov    %ax,0xf02982c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0104255:	b8 b8 4b 10 f0       	mov    $0xf0104bb8,%eax
f010425a:	66 a3 c8 82 29 f0    	mov    %ax,0xf02982c8
f0104260:	66 c7 05 ca 82 29 f0 	movw   $0x8,0xf02982ca
f0104267:	08 00 
f0104269:	c6 05 cc 82 29 f0 00 	movb   $0x0,0xf02982cc
f0104270:	c6 05 cd 82 29 f0 8e 	movb   $0x8e,0xf02982cd
f0104277:	c1 e8 10             	shr    $0x10,%eax
f010427a:	66 a3 ce 82 29 f0    	mov    %ax,0xf02982ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0104280:	b8 c0 4b 10 f0       	mov    $0xf0104bc0,%eax
f0104285:	66 a3 d0 82 29 f0    	mov    %ax,0xf02982d0
f010428b:	66 c7 05 d2 82 29 f0 	movw   $0x8,0xf02982d2
f0104292:	08 00 
f0104294:	c6 05 d4 82 29 f0 00 	movb   $0x0,0xf02982d4
f010429b:	c6 05 d5 82 29 f0 8e 	movb   $0x8e,0xf02982d5
f01042a2:	c1 e8 10             	shr    $0x10,%eax
f01042a5:	66 a3 d6 82 29 f0    	mov    %ax,0xf02982d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01042ab:	b8 c8 4b 10 f0       	mov    $0xf0104bc8,%eax
f01042b0:	66 a3 e0 82 29 f0    	mov    %ax,0xf02982e0
f01042b6:	66 c7 05 e2 82 29 f0 	movw   $0x8,0xf02982e2
f01042bd:	08 00 
f01042bf:	c6 05 e4 82 29 f0 00 	movb   $0x0,0xf02982e4
f01042c6:	c6 05 e5 82 29 f0 8e 	movb   $0x8e,0xf02982e5
f01042cd:	c1 e8 10             	shr    $0x10,%eax
f01042d0:	66 a3 e6 82 29 f0    	mov    %ax,0xf02982e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01042d6:	b8 d2 4b 10 f0       	mov    $0xf0104bd2,%eax
f01042db:	66 a3 e8 82 29 f0    	mov    %ax,0xf02982e8
f01042e1:	66 c7 05 ea 82 29 f0 	movw   $0x8,0xf02982ea
f01042e8:	08 00 
f01042ea:	c6 05 ec 82 29 f0 00 	movb   $0x0,0xf02982ec
f01042f1:	c6 05 ed 82 29 f0 8e 	movb   $0x8e,0xf02982ed
f01042f8:	c1 e8 10             	shr    $0x10,%eax
f01042fb:	66 a3 ee 82 29 f0    	mov    %ax,0xf02982ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0104301:	b8 da 4b 10 f0       	mov    $0xf0104bda,%eax
f0104306:	66 a3 f0 82 29 f0    	mov    %ax,0xf02982f0
f010430c:	66 c7 05 f2 82 29 f0 	movw   $0x8,0xf02982f2
f0104313:	08 00 
f0104315:	c6 05 f4 82 29 f0 00 	movb   $0x0,0xf02982f4
f010431c:	c6 05 f5 82 29 f0 8e 	movb   $0x8e,0xf02982f5
f0104323:	c1 e8 10             	shr    $0x10,%eax
f0104326:	66 a3 f6 82 29 f0    	mov    %ax,0xf02982f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f010432c:	b8 e4 4b 10 f0       	mov    $0xf0104be4,%eax
f0104331:	66 a3 f8 82 29 f0    	mov    %ax,0xf02982f8
f0104337:	66 c7 05 fa 82 29 f0 	movw   $0x8,0xf02982fa
f010433e:	08 00 
f0104340:	c6 05 fc 82 29 f0 00 	movb   $0x0,0xf02982fc
f0104347:	c6 05 fd 82 29 f0 8e 	movb   $0x8e,0xf02982fd
f010434e:	c1 e8 10             	shr    $0x10,%eax
f0104351:	66 a3 fe 82 29 f0    	mov    %ax,0xf02982fe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0104357:	b8 ee 4b 10 f0       	mov    $0xf0104bee,%eax
f010435c:	66 a3 e0 83 29 f0    	mov    %ax,0xf02983e0
f0104362:	66 c7 05 e2 83 29 f0 	movw   $0x8,0xf02983e2
f0104369:	08 00 
f010436b:	c6 05 e4 83 29 f0 00 	movb   $0x0,0xf02983e4
f0104372:	c6 05 e5 83 29 f0 ee 	movb   $0xee,0xf02983e5
f0104379:	c1 e8 10             	shr    $0x10,%eax
f010437c:	66 a3 e6 83 29 f0    	mov    %ax,0xf02983e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f0104382:	b8 04 4c 10 f0       	mov    $0xf0104c04,%eax
f0104387:	66 a3 60 83 29 f0    	mov    %ax,0xf0298360
f010438d:	66 c7 05 62 83 29 f0 	movw   $0x8,0xf0298362
f0104394:	08 00 
f0104396:	c6 05 64 83 29 f0 00 	movb   $0x0,0xf0298364
f010439d:	c6 05 65 83 29 f0 8e 	movb   $0x8e,0xf0298365
f01043a4:	c1 e8 10             	shr    $0x10,%eax
f01043a7:	66 a3 66 83 29 f0    	mov    %ax,0xf0298366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f01043ad:	b8 0e 4c 10 f0       	mov    $0xf0104c0e,%eax
f01043b2:	66 a3 68 83 29 f0    	mov    %ax,0xf0298368
f01043b8:	66 c7 05 6a 83 29 f0 	movw   $0x8,0xf029836a
f01043bf:	08 00 
f01043c1:	c6 05 6c 83 29 f0 00 	movb   $0x0,0xf029836c
f01043c8:	c6 05 6d 83 29 f0 8e 	movb   $0x8e,0xf029836d
f01043cf:	c1 e8 10             	shr    $0x10,%eax
f01043d2:	66 a3 6e 83 29 f0    	mov    %ax,0xf029836e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f01043d8:	b8 18 4c 10 f0       	mov    $0xf0104c18,%eax
f01043dd:	66 a3 80 83 29 f0    	mov    %ax,0xf0298380
f01043e3:	66 c7 05 82 83 29 f0 	movw   $0x8,0xf0298382
f01043ea:	08 00 
f01043ec:	c6 05 84 83 29 f0 00 	movb   $0x0,0xf0298384
f01043f3:	c6 05 85 83 29 f0 8e 	movb   $0x8e,0xf0298385
f01043fa:	c1 e8 10             	shr    $0x10,%eax
f01043fd:	66 a3 86 83 29 f0    	mov    %ax,0xf0298386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f0104403:	b8 22 4c 10 f0       	mov    $0xf0104c22,%eax
f0104408:	66 a3 98 83 29 f0    	mov    %ax,0xf0298398
f010440e:	66 c7 05 9a 83 29 f0 	movw   $0x8,0xf029839a
f0104415:	08 00 
f0104417:	c6 05 9c 83 29 f0 00 	movb   $0x0,0xf029839c
f010441e:	c6 05 9d 83 29 f0 8e 	movb   $0x8e,0xf029839d
f0104425:	c1 e8 10             	shr    $0x10,%eax
f0104428:	66 a3 9e 83 29 f0    	mov    %ax,0xf029839e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f010442e:	b8 2c 4c 10 f0       	mov    $0xf0104c2c,%eax
f0104433:	66 a3 d0 83 29 f0    	mov    %ax,0xf02983d0
f0104439:	66 c7 05 d2 83 29 f0 	movw   $0x8,0xf02983d2
f0104440:	08 00 
f0104442:	c6 05 d4 83 29 f0 00 	movb   $0x0,0xf02983d4
f0104449:	c6 05 d5 83 29 f0 8e 	movb   $0x8e,0xf02983d5
f0104450:	c1 e8 10             	shr    $0x10,%eax
f0104453:	66 a3 d6 83 29 f0    	mov    %ax,0xf02983d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0104459:	b8 36 4c 10 f0       	mov    $0xf0104c36,%eax
f010445e:	66 a3 f8 83 29 f0    	mov    %ax,0xf02983f8
f0104464:	66 c7 05 fa 83 29 f0 	movw   $0x8,0xf02983fa
f010446b:	08 00 
f010446d:	c6 05 fc 83 29 f0 00 	movb   $0x0,0xf02983fc
f0104474:	c6 05 fd 83 29 f0 8e 	movb   $0x8e,0xf02983fd
f010447b:	c1 e8 10             	shr    $0x10,%eax
f010447e:	66 a3 fe 83 29 f0    	mov    %ax,0xf02983fe

	SETGATE(idt[IRQ_OFFSET + IRQ_E1000], 0, GD_KT, irq_e1000, 0);
f0104484:	b8 40 4c 10 f0       	mov    $0xf0104c40,%eax
f0104489:	66 a3 b8 83 29 f0    	mov    %ax,0xf02983b8
f010448f:	66 c7 05 ba 83 29 f0 	movw   $0x8,0xf02983ba
f0104496:	08 00 
f0104498:	c6 05 bc 83 29 f0 00 	movb   $0x0,0xf02983bc
f010449f:	c6 05 bd 83 29 f0 8e 	movb   $0x8e,0xf02983bd
f01044a6:	c1 e8 10             	shr    $0x10,%eax
f01044a9:	66 a3 be 83 29 f0    	mov    %ax,0xf02983be
	
	// Per-CPU setup 
	trap_init_percpu();
f01044af:	e8 94 fa ff ff       	call   f0103f48 <trap_init_percpu>
}
f01044b4:	c9                   	leave  
f01044b5:	c3                   	ret    

f01044b6 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01044b6:	55                   	push   %ebp
f01044b7:	89 e5                	mov    %esp,%ebp
f01044b9:	53                   	push   %ebx
f01044ba:	83 ec 14             	sub    $0x14,%esp
f01044bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01044c0:	8b 03                	mov    (%ebx),%eax
f01044c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044c6:	c7 04 24 d8 8e 10 f0 	movl   $0xf0108ed8,(%esp)
f01044cd:	e8 5c fa ff ff       	call   f0103f2e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01044d2:	8b 43 04             	mov    0x4(%ebx),%eax
f01044d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044d9:	c7 04 24 e7 8e 10 f0 	movl   $0xf0108ee7,(%esp)
f01044e0:	e8 49 fa ff ff       	call   f0103f2e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01044e5:	8b 43 08             	mov    0x8(%ebx),%eax
f01044e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ec:	c7 04 24 f6 8e 10 f0 	movl   $0xf0108ef6,(%esp)
f01044f3:	e8 36 fa ff ff       	call   f0103f2e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01044f8:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ff:	c7 04 24 05 8f 10 f0 	movl   $0xf0108f05,(%esp)
f0104506:	e8 23 fa ff ff       	call   f0103f2e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010450b:	8b 43 10             	mov    0x10(%ebx),%eax
f010450e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104512:	c7 04 24 14 8f 10 f0 	movl   $0xf0108f14,(%esp)
f0104519:	e8 10 fa ff ff       	call   f0103f2e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010451e:	8b 43 14             	mov    0x14(%ebx),%eax
f0104521:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104525:	c7 04 24 23 8f 10 f0 	movl   $0xf0108f23,(%esp)
f010452c:	e8 fd f9 ff ff       	call   f0103f2e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104531:	8b 43 18             	mov    0x18(%ebx),%eax
f0104534:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104538:	c7 04 24 32 8f 10 f0 	movl   $0xf0108f32,(%esp)
f010453f:	e8 ea f9 ff ff       	call   f0103f2e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104544:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104547:	89 44 24 04          	mov    %eax,0x4(%esp)
f010454b:	c7 04 24 41 8f 10 f0 	movl   $0xf0108f41,(%esp)
f0104552:	e8 d7 f9 ff ff       	call   f0103f2e <cprintf>
}
f0104557:	83 c4 14             	add    $0x14,%esp
f010455a:	5b                   	pop    %ebx
f010455b:	5d                   	pop    %ebp
f010455c:	c3                   	ret    

f010455d <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010455d:	55                   	push   %ebp
f010455e:	89 e5                	mov    %esp,%ebp
f0104560:	53                   	push   %ebx
f0104561:	83 ec 14             	sub    $0x14,%esp
f0104564:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104567:	e8 30 23 00 00       	call   f010689c <cpunum>
f010456c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104574:	c7 04 24 a5 8f 10 f0 	movl   $0xf0108fa5,(%esp)
f010457b:	e8 ae f9 ff ff       	call   f0103f2e <cprintf>
	print_regs(&tf->tf_regs);
f0104580:	89 1c 24             	mov    %ebx,(%esp)
f0104583:	e8 2e ff ff ff       	call   f01044b6 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104588:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010458c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104590:	c7 04 24 c3 8f 10 f0 	movl   $0xf0108fc3,(%esp)
f0104597:	e8 92 f9 ff ff       	call   f0103f2e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010459c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045a4:	c7 04 24 d6 8f 10 f0 	movl   $0xf0108fd6,(%esp)
f01045ab:	e8 7e f9 ff ff       	call   f0103f2e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045b0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01045b3:	83 f8 13             	cmp    $0x13,%eax
f01045b6:	77 09                	ja     f01045c1 <print_trapframe+0x64>
	  return excnames[trapno];
f01045b8:	8b 14 85 80 92 10 f0 	mov    -0xfef6d80(,%eax,4),%edx
f01045bf:	eb 20                	jmp    f01045e1 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01045c1:	83 f8 30             	cmp    $0x30,%eax
f01045c4:	74 0f                	je     f01045d5 <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01045c6:	8d 50 e0             	lea    -0x20(%eax),%edx
f01045c9:	83 fa 0f             	cmp    $0xf,%edx
f01045cc:	77 0e                	ja     f01045dc <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01045ce:	ba 5c 8f 10 f0       	mov    $0xf0108f5c,%edx
f01045d3:	eb 0c                	jmp    f01045e1 <print_trapframe+0x84>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
	  return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01045d5:	ba 50 8f 10 f0       	mov    $0xf0108f50,%edx
f01045da:	eb 05                	jmp    f01045e1 <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01045dc:	ba 6f 8f 10 f0       	mov    $0xf0108f6f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01045e1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e9:	c7 04 24 e9 8f 10 f0 	movl   $0xf0108fe9,(%esp)
f01045f0:	e8 39 f9 ff ff       	call   f0103f2e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01045f5:	3b 1d 60 8a 29 f0    	cmp    0xf0298a60,%ebx
f01045fb:	75 19                	jne    f0104616 <print_trapframe+0xb9>
f01045fd:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104601:	75 13                	jne    f0104616 <print_trapframe+0xb9>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104603:	0f 20 d0             	mov    %cr2,%eax
	  cprintf("  cr2  0x%08x\n", rcr2());
f0104606:	89 44 24 04          	mov    %eax,0x4(%esp)
f010460a:	c7 04 24 fb 8f 10 f0 	movl   $0xf0108ffb,(%esp)
f0104611:	e8 18 f9 ff ff       	call   f0103f2e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104616:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104619:	89 44 24 04          	mov    %eax,0x4(%esp)
f010461d:	c7 04 24 0a 90 10 f0 	movl   $0xf010900a,(%esp)
f0104624:	e8 05 f9 ff ff       	call   f0103f2e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104629:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010462d:	75 4d                	jne    f010467c <print_trapframe+0x11f>
	  cprintf(" [%s, %s, %s]\n",
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
f010462f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
	  cprintf(" [%s, %s, %s]\n",
f0104632:	a8 01                	test   $0x1,%al
f0104634:	74 07                	je     f010463d <print_trapframe+0xe0>
f0104636:	b9 7e 8f 10 f0       	mov    $0xf0108f7e,%ecx
f010463b:	eb 05                	jmp    f0104642 <print_trapframe+0xe5>
f010463d:	b9 89 8f 10 f0       	mov    $0xf0108f89,%ecx
f0104642:	a8 02                	test   $0x2,%al
f0104644:	74 07                	je     f010464d <print_trapframe+0xf0>
f0104646:	ba 95 8f 10 f0       	mov    $0xf0108f95,%edx
f010464b:	eb 05                	jmp    f0104652 <print_trapframe+0xf5>
f010464d:	ba 9b 8f 10 f0       	mov    $0xf0108f9b,%edx
f0104652:	a8 04                	test   $0x4,%al
f0104654:	74 07                	je     f010465d <print_trapframe+0x100>
f0104656:	b8 a0 8f 10 f0       	mov    $0xf0108fa0,%eax
f010465b:	eb 05                	jmp    f0104662 <print_trapframe+0x105>
f010465d:	b8 f3 90 10 f0       	mov    $0xf01090f3,%eax
f0104662:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104666:	89 54 24 08          	mov    %edx,0x8(%esp)
f010466a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010466e:	c7 04 24 18 90 10 f0 	movl   $0xf0109018,(%esp)
f0104675:	e8 b4 f8 ff ff       	call   f0103f2e <cprintf>
f010467a:	eb 0c                	jmp    f0104688 <print_trapframe+0x12b>
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
	else
	  cprintf("\n");
f010467c:	c7 04 24 7f 8d 10 f0 	movl   $0xf0108d7f,(%esp)
f0104683:	e8 a6 f8 ff ff       	call   f0103f2e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104688:	8b 43 30             	mov    0x30(%ebx),%eax
f010468b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010468f:	c7 04 24 27 90 10 f0 	movl   $0xf0109027,(%esp)
f0104696:	e8 93 f8 ff ff       	call   f0103f2e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010469b:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010469f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a3:	c7 04 24 36 90 10 f0 	movl   $0xf0109036,(%esp)
f01046aa:	e8 7f f8 ff ff       	call   f0103f2e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01046af:	8b 43 38             	mov    0x38(%ebx),%eax
f01046b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b6:	c7 04 24 49 90 10 f0 	movl   $0xf0109049,(%esp)
f01046bd:	e8 6c f8 ff ff       	call   f0103f2e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01046c2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01046c6:	74 27                	je     f01046ef <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01046c8:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046cf:	c7 04 24 58 90 10 f0 	movl   $0xf0109058,(%esp)
f01046d6:	e8 53 f8 ff ff       	call   f0103f2e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01046db:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01046df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e3:	c7 04 24 67 90 10 f0 	movl   $0xf0109067,(%esp)
f01046ea:	e8 3f f8 ff ff       	call   f0103f2e <cprintf>
	}
}
f01046ef:	83 c4 14             	add    $0x14,%esp
f01046f2:	5b                   	pop    %ebx
f01046f3:	5d                   	pop    %ebp
f01046f4:	c3                   	ret    

f01046f5 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01046f5:	55                   	push   %ebp
f01046f6:	89 e5                	mov    %esp,%ebp
f01046f8:	57                   	push   %edi
f01046f9:	56                   	push   %esi
f01046fa:	53                   	push   %ebx
f01046fb:	83 ec 2c             	sub    $0x2c,%esp
f01046fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104701:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	
	if ((tf->tf_cs & 0x0001) == 0) {
f0104704:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f0104708:	75 1c                	jne    f0104726 <page_fault_handler+0x31>
		panic("page_fault_handler:page fault");
f010470a:	c7 44 24 08 7a 90 10 	movl   $0xf010907a,0x8(%esp)
f0104711:	f0 
f0104712:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0104719:	00 
f010471a:	c7 04 24 98 90 10 f0 	movl   $0xf0109098,(%esp)
f0104721:	e8 1a b9 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall){
f0104726:	e8 71 21 00 00       	call   f010689c <cpunum>
f010472b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104732:	29 c2                	sub    %eax,%edx
f0104734:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104737:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f010473e:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104742:	0f 84 ed 00 00 00    	je     f0104835 <page_fault_handler+0x140>
		struct UTrapframe *utf;
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP-1)
f0104748:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010474b:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
		else
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104751:	c7 45 e4 cc ff bf ee 	movl   $0xeebfffcc,-0x1c(%ebp)

	// LAB 4: Your code here.
	
	if (curenv->env_pgfault_upcall){
		struct UTrapframe *utf;
		if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP-1)
f0104758:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010475e:	77 06                	ja     f0104766 <page_fault_handler+0x71>
			utf = (struct UTrapframe*)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0104760:	83 e8 38             	sub    $0x38,%eax
f0104763:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		else
			utf = (struct UTrapframe*)(UXSTACKTOP - sizeof(struct UTrapframe));
		user_mem_assert(curenv, (void*)utf, sizeof(struct UTrapframe), PTE_U|PTE_W);
f0104766:	e8 31 21 00 00       	call   f010689c <cpunum>
f010476b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104772:	00 
f0104773:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f010477a:	00 
f010477b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010477e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104782:	6b c0 74             	imul   $0x74,%eax,%eax
f0104785:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f010478b:	89 04 24             	mov    %eax,(%esp)
f010478e:	e8 9c ed ff ff       	call   f010352f <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104796:	89 30                	mov    %esi,(%eax)
		utf->utf_regs = tf->tf_regs;
f0104798:	89 c7                	mov    %eax,%edi
f010479a:	83 c7 08             	add    $0x8,%edi
f010479d:	89 de                	mov    %ebx,%esi
f010479f:	b8 20 00 00 00       	mov    $0x20,%eax
f01047a4:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01047aa:	74 03                	je     f01047af <page_fault_handler+0xba>
f01047ac:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01047ad:	b0 1f                	mov    $0x1f,%al
f01047af:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01047b5:	74 05                	je     f01047bc <page_fault_handler+0xc7>
f01047b7:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047b9:	83 e8 02             	sub    $0x2,%eax
f01047bc:	89 c1                	mov    %eax,%ecx
f01047be:	c1 e9 02             	shr    $0x2,%ecx
f01047c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047c3:	a8 02                	test   $0x2,%al
f01047c5:	74 02                	je     f01047c9 <page_fault_handler+0xd4>
f01047c7:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01047c9:	a8 01                	test   $0x1,%al
f01047cb:	74 01                	je     f01047ce <page_fault_handler+0xd9>
f01047cd:	a4                   	movsb  %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01047ce:	8b 43 30             	mov    0x30(%ebx),%eax
f01047d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047d4:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01047d7:	8b 43 38             	mov    0x38(%ebx),%eax
f01047da:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01047dd:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01047e0:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_err = tf->tf_trapno;
f01047e3:	8b 43 28             	mov    0x28(%ebx),%eax
f01047e6:	89 42 04             	mov    %eax,0x4(%edx)
		curenv->env_tf.tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f01047e9:	e8 ae 20 00 00       	call   f010689c <cpunum>
f01047ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f1:	8b 98 28 90 29 f0    	mov    -0xfd66fd8(%eax),%ebx
f01047f7:	e8 a0 20 00 00       	call   f010689c <cpunum>
f01047fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ff:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0104805:	8b 40 64             	mov    0x64(%eax),%eax
f0104808:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = (uint32_t)utf;
f010480b:	e8 8c 20 00 00       	call   f010689c <cpunum>
f0104810:	6b c0 74             	imul   $0x74,%eax,%eax
f0104813:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0104819:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010481c:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run(curenv);
f010481f:	e8 78 20 00 00       	call   f010689c <cpunum>
f0104824:	6b c0 74             	imul   $0x74,%eax,%eax
f0104827:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f010482d:	89 04 24             	mov    %eax,(%esp)
f0104830:	e8 dc f4 ff ff       	call   f0103d11 <env_run>
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104835:	8b 7b 30             	mov    0x30(%ebx),%edi
				curenv->env_id, fault_va, tf->tf_eip);
f0104838:	e8 5f 20 00 00       	call   f010689c <cpunum>
		curenv->env_tf.tf_esp = (uint32_t)utf;
		env_run(curenv);
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010483d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104841:	89 74 24 08          	mov    %esi,0x8(%esp)
				curenv->env_id, fault_va, tf->tf_eip);
f0104845:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010484c:	29 c2                	sub    %eax,%edx
f010484e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104851:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
		curenv->env_tf.tf_esp = (uint32_t)utf;
		env_run(curenv);
	}else{
	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104858:	8b 40 48             	mov    0x48(%eax),%eax
f010485b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010485f:	c7 04 24 40 92 10 f0 	movl   $0xf0109240,(%esp)
f0104866:	e8 c3 f6 ff ff       	call   f0103f2e <cprintf>
				curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010486b:	89 1c 24             	mov    %ebx,(%esp)
f010486e:	e8 ea fc ff ff       	call   f010455d <print_trapframe>
	env_destroy(curenv);
f0104873:	e8 24 20 00 00       	call   f010689c <cpunum>
f0104878:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010487f:	29 c2                	sub    %eax,%edx
f0104881:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104884:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f010488b:	89 04 24             	mov    %eax,(%esp)
f010488e:	e8 bf f3 ff ff       	call   f0103c52 <env_destroy>
	}
}
f0104893:	83 c4 2c             	add    $0x2c,%esp
f0104896:	5b                   	pop    %ebx
f0104897:	5e                   	pop    %esi
f0104898:	5f                   	pop    %edi
f0104899:	5d                   	pop    %ebp
f010489a:	c3                   	ret    

f010489b <breakpoint_handler>:

void breakpoint_handler(struct Trapframe *tf){
f010489b:	55                   	push   %ebp
f010489c:	89 e5                	mov    %esp,%ebp
f010489e:	83 ec 18             	sub    $0x18,%esp
	monitor(tf);
f01048a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01048a4:	89 04 24             	mov    %eax,(%esp)
f01048a7:	e8 f3 c0 ff ff       	call   f010099f <monitor>
}
f01048ac:	c9                   	leave  
f01048ad:	c3                   	ret    

f01048ae <system_call_handler>:

int32_t system_call_handler(struct Trapframe *tf){
f01048ae:	55                   	push   %ebp
f01048af:	89 e5                	mov    %esp,%ebp
f01048b1:	83 ec 28             	sub    $0x28,%esp
f01048b4:	8b 45 08             	mov    0x8(%ebp),%eax
	return syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,\
f01048b7:	8b 50 04             	mov    0x4(%eax),%edx
f01048ba:	89 54 24 14          	mov    %edx,0x14(%esp)
f01048be:	8b 10                	mov    (%eax),%edx
f01048c0:	89 54 24 10          	mov    %edx,0x10(%esp)
f01048c4:	8b 50 10             	mov    0x10(%eax),%edx
f01048c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01048cb:	8b 50 18             	mov    0x18(%eax),%edx
f01048ce:	89 54 24 08          	mov    %edx,0x8(%esp)
f01048d2:	8b 50 14             	mov    0x14(%eax),%edx
f01048d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01048d9:	8b 40 1c             	mov    0x1c(%eax),%eax
f01048dc:	89 04 24             	mov    %eax,(%esp)
f01048df:	e8 ef 05 00 00       	call   f0104ed3 <syscall>
				tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);	
}
f01048e4:	c9                   	leave  
f01048e5:	c3                   	ret    

f01048e6 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01048e6:	55                   	push   %ebp
f01048e7:	89 e5                	mov    %esp,%ebp
f01048e9:	57                   	push   %edi
f01048ea:	56                   	push   %esi
f01048eb:	83 ec 10             	sub    $0x10,%esp
f01048ee:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01048f1:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01048f2:	83 3d 8c 8e 29 f0 00 	cmpl   $0x0,0xf0298e8c
f01048f9:	74 01                	je     f01048fc <trap+0x16>
		asm volatile("hlt");
f01048fb:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01048fc:	e8 9b 1f 00 00       	call   f010689c <cpunum>
f0104901:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104908:	29 c2                	sub    %eax,%edx
f010490a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010490d:	8d 14 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104914:	b8 01 00 00 00       	mov    $0x1,%eax
f0104919:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010491d:	83 f8 02             	cmp    $0x2,%eax
f0104920:	75 0c                	jne    f010492e <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104922:	c7 04 24 c0 d3 12 f0 	movl   $0xf012d3c0,(%esp)
f0104929:	e8 2d 22 00 00       	call   f0106b5b <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010492e:	9c                   	pushf  
f010492f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104930:	f6 c4 02             	test   $0x2,%ah
f0104933:	74 24                	je     f0104959 <trap+0x73>
f0104935:	c7 44 24 0c a4 90 10 	movl   $0xf01090a4,0xc(%esp)
f010493c:	f0 
f010493d:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0104944:	f0 
f0104945:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
f010494c:	00 
f010494d:	c7 04 24 98 90 10 f0 	movl   $0xf0109098,(%esp)
f0104954:	e8 e7 b6 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104959:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010495d:	83 e0 03             	and    $0x3,%eax
f0104960:	83 f8 03             	cmp    $0x3,%eax
f0104963:	0f 85 a7 00 00 00    	jne    f0104a10 <trap+0x12a>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104969:	e8 2e 1f 00 00       	call   f010689c <cpunum>
f010496e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104971:	83 b8 28 90 29 f0 00 	cmpl   $0x0,-0xfd66fd8(%eax)
f0104978:	75 24                	jne    f010499e <trap+0xb8>
f010497a:	c7 44 24 0c bd 90 10 	movl   $0xf01090bd,0xc(%esp)
f0104981:	f0 
f0104982:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0104989:	f0 
f010498a:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
f0104991:	00 
f0104992:	c7 04 24 98 90 10 f0 	movl   $0xf0109098,(%esp)
f0104999:	e8 a2 b6 ff ff       	call   f0100040 <_panic>
f010499e:	c7 04 24 c0 d3 12 f0 	movl   $0xf012d3c0,(%esp)
f01049a5:	e8 b1 21 00 00       	call   f0106b5b <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01049aa:	e8 ed 1e 00 00       	call   f010689c <cpunum>
f01049af:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b2:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f01049b8:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01049bc:	75 2d                	jne    f01049eb <trap+0x105>
			env_free(curenv);
f01049be:	e8 d9 1e 00 00       	call   f010689c <cpunum>
f01049c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c6:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f01049cc:	89 04 24             	mov    %eax,(%esp)
f01049cf:	e8 a5 f0 ff ff       	call   f0103a79 <env_free>
			curenv = NULL;
f01049d4:	e8 c3 1e 00 00       	call   f010689c <cpunum>
f01049d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049dc:	c7 80 28 90 29 f0 00 	movl   $0x0,-0xfd66fd8(%eax)
f01049e3:	00 00 00 
			sched_yield();
f01049e6:	e8 63 03 00 00       	call   f0104d4e <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01049eb:	e8 ac 1e 00 00       	call   f010689c <cpunum>
f01049f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f3:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f01049f9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01049fe:	89 c7                	mov    %eax,%edi
f0104a00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a02:	e8 95 1e 00 00       	call   f010689c <cpunum>
f0104a07:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0a:	8b b0 28 90 29 f0    	mov    -0xfd66fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104a10:	89 35 60 8a 29 f0    	mov    %esi,0xf0298a60
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	int32_t ret;

	switch (tf->tf_trapno){
f0104a16:	8b 46 28             	mov    0x28(%esi),%eax
f0104a19:	83 f8 20             	cmp    $0x20,%eax
f0104a1c:	74 6a                	je     f0104a88 <trap+0x1a2>
f0104a1e:	83 f8 20             	cmp    $0x20,%eax
f0104a21:	77 11                	ja     f0104a34 <trap+0x14e>
f0104a23:	83 f8 03             	cmp    $0x3,%eax
f0104a26:	74 36                	je     f0104a5e <trap+0x178>
f0104a28:	83 f8 0e             	cmp    $0xe,%eax
f0104a2b:	74 24                	je     f0104a51 <trap+0x16b>
f0104a2d:	83 f8 01             	cmp    $0x1,%eax
f0104a30:	75 7a                	jne    f0104aac <trap+0x1c6>
f0104a32:	eb 37                	jmp    f0104a6b <trap+0x185>
f0104a34:	83 f8 24             	cmp    $0x24,%eax
f0104a37:	74 65                	je     f0104a9e <trap+0x1b8>
f0104a39:	83 f8 24             	cmp    $0x24,%eax
f0104a3c:	77 07                	ja     f0104a45 <trap+0x15f>
f0104a3e:	83 f8 21             	cmp    $0x21,%eax
f0104a41:	75 69                	jne    f0104aac <trap+0x1c6>
f0104a43:	eb 52                	jmp    f0104a97 <trap+0x1b1>
f0104a45:	83 f8 2b             	cmp    $0x2b,%eax
f0104a48:	74 5b                	je     f0104aa5 <trap+0x1bf>
f0104a4a:	83 f8 30             	cmp    $0x30,%eax
f0104a4d:	75 5d                	jne    f0104aac <trap+0x1c6>
f0104a4f:	eb 27                	jmp    f0104a78 <trap+0x192>
		case T_PGFLT:{ //14
			page_fault_handler(tf);
f0104a51:	89 34 24             	mov    %esi,(%esp)
f0104a54:	e8 9c fc ff ff       	call   f01046f5 <page_fault_handler>
f0104a59:	e9 aa 00 00 00       	jmp    f0104b08 <trap+0x222>
			return;
		}
		case T_BRKPT:{ //3 
			breakpoint_handler(tf);
f0104a5e:	89 34 24             	mov    %esi,(%esp)
f0104a61:	e8 35 fe ff ff       	call   f010489b <breakpoint_handler>
f0104a66:	e9 9d 00 00 00       	jmp    f0104b08 <trap+0x222>
			return;
		}
		case T_DEBUG:{
			breakpoint_handler(tf);
f0104a6b:	89 34 24             	mov    %esi,(%esp)
f0104a6e:	e8 28 fe ff ff       	call   f010489b <breakpoint_handler>
f0104a73:	e9 90 00 00 00       	jmp    f0104b08 <trap+0x222>
			return;
		}
		case T_SYSCALL:{
			ret = system_call_handler(tf);
f0104a78:	89 34 24             	mov    %esi,(%esp)
f0104a7b:	e8 2e fe ff ff       	call   f01048ae <system_call_handler>
			tf->tf_regs.reg_eax = ret;
f0104a80:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104a83:	e9 80 00 00 00       	jmp    f0104b08 <trap+0x222>
			return;
		}
		case IRQ_OFFSET+IRQ_TIMER:{
			lapic_eoi();
f0104a88:	e8 66 1f 00 00       	call   f01069f3 <lapic_eoi>
			time_tick();
f0104a8d:	e8 e1 2d 00 00       	call   f0107873 <time_tick>
			sched_yield();
f0104a92:	e8 b7 02 00 00       	call   f0104d4e <sched_yield>
			return;
		}
		case IRQ_OFFSET+IRQ_KBD:{
			kbd_intr();
f0104a97:	e8 9e bb ff ff       	call   f010063a <kbd_intr>
f0104a9c:	eb 6a                	jmp    f0104b08 <trap+0x222>
			return;
		}
		case IRQ_OFFSET+IRQ_SERIAL:{
			serial_intr();
f0104a9e:	e8 7c bb ff ff       	call   f010061f <serial_intr>
f0104aa3:	eb 63                	jmp    f0104b08 <trap+0x222>
			return;
		}
		case IRQ_OFFSET+IRQ_E1000:{
			e1000_trap_handler();
f0104aa5:	e8 b9 23 00 00       	call   f0106e63 <e1000_trap_handler>
f0104aaa:	eb 5c                	jmp    f0104b08 <trap+0x222>
	}	

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104aac:	83 f8 27             	cmp    $0x27,%eax
f0104aaf:	75 16                	jne    f0104ac7 <trap+0x1e1>
		cprintf("Spurious interrupt on irq 7\n");
f0104ab1:	c7 04 24 c4 90 10 f0 	movl   $0xf01090c4,(%esp)
f0104ab8:	e8 71 f4 ff ff       	call   f0103f2e <cprintf>
		print_trapframe(tf);
f0104abd:	89 34 24             	mov    %esi,(%esp)
f0104ac0:	e8 98 fa ff ff       	call   f010455d <print_trapframe>
f0104ac5:	eb 41                	jmp    f0104b08 <trap+0x222>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104ac7:	89 34 24             	mov    %esi,(%esp)
f0104aca:	e8 8e fa ff ff       	call   f010455d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104acf:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104ad4:	75 1c                	jne    f0104af2 <trap+0x20c>
	  panic("unhandled trap in kernel");
f0104ad6:	c7 44 24 08 e1 90 10 	movl   $0xf01090e1,0x8(%esp)
f0104add:	f0 
f0104ade:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
f0104ae5:	00 
f0104ae6:	c7 04 24 98 90 10 f0 	movl   $0xf0109098,(%esp)
f0104aed:	e8 4e b5 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104af2:	e8 a5 1d 00 00       	call   f010689c <cpunum>
f0104af7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afa:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0104b00:	89 04 24             	mov    %eax,(%esp)
f0104b03:	e8 4a f1 ff ff       	call   f0103c52 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104b08:	e8 8f 1d 00 00       	call   f010689c <cpunum>
f0104b0d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b10:	83 b8 28 90 29 f0 00 	cmpl   $0x0,-0xfd66fd8(%eax)
f0104b17:	74 2a                	je     f0104b43 <trap+0x25d>
f0104b19:	e8 7e 1d 00 00       	call   f010689c <cpunum>
f0104b1e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b21:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0104b27:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b2b:	75 16                	jne    f0104b43 <trap+0x25d>
		env_run(curenv);
f0104b2d:	e8 6a 1d 00 00       	call   f010689c <cpunum>
f0104b32:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b35:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0104b3b:	89 04 24             	mov    %eax,(%esp)
f0104b3e:	e8 ce f1 ff ff       	call   f0103d11 <env_run>
	else
		sched_yield();
f0104b43:	e8 06 02 00 00       	call   f0104d4e <sched_yield>

f0104b48 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104b48:	6a 00                	push   $0x0
f0104b4a:	6a 00                	push   $0x0
f0104b4c:	e9 f8 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b51:	90                   	nop

f0104b52 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104b52:	6a 00                	push   $0x0
f0104b54:	6a 01                	push   $0x1
f0104b56:	e9 ee 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b5b:	90                   	nop

f0104b5c <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104b5c:	6a 00                	push   $0x0
f0104b5e:	6a 02                	push   $0x2
f0104b60:	e9 e4 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b65:	90                   	nop

f0104b66 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104b66:	6a 00                	push   $0x0
f0104b68:	6a 03                	push   $0x3
f0104b6a:	e9 da 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b6f:	90                   	nop

f0104b70 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104b70:	6a 00                	push   $0x0
f0104b72:	6a 04                	push   $0x4
f0104b74:	e9 d0 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b79:	90                   	nop

f0104b7a <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104b7a:	6a 00                	push   $0x0
f0104b7c:	6a 05                	push   $0x5
f0104b7e:	e9 c6 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b83:	90                   	nop

f0104b84 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104b84:	6a 00                	push   $0x0
f0104b86:	6a 06                	push   $0x6
f0104b88:	e9 bc 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b8d:	90                   	nop

f0104b8e <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104b8e:	6a 00                	push   $0x0
f0104b90:	6a 07                	push   $0x7
f0104b92:	e9 b2 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b97:	90                   	nop

f0104b98 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104b98:	6a 08                	push   $0x8
f0104b9a:	e9 aa 00 00 00       	jmp    f0104c49 <_alltraps>
f0104b9f:	90                   	nop

f0104ba0 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104ba0:	6a 0a                	push   $0xa
f0104ba2:	e9 a2 00 00 00       	jmp    f0104c49 <_alltraps>
f0104ba7:	90                   	nop

f0104ba8 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0104ba8:	6a 0b                	push   $0xb
f0104baa:	e9 9a 00 00 00       	jmp    f0104c49 <_alltraps>
f0104baf:	90                   	nop

f0104bb0 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104bb0:	6a 0c                	push   $0xc
f0104bb2:	e9 92 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bb7:	90                   	nop

f0104bb8 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104bb8:	6a 0d                	push   $0xd
f0104bba:	e9 8a 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bbf:	90                   	nop

f0104bc0 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104bc0:	6a 0e                	push   $0xe
f0104bc2:	e9 82 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bc7:	90                   	nop

f0104bc8 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104bc8:	6a 00                	push   $0x0
f0104bca:	6a 10                	push   $0x10
f0104bcc:	e9 78 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bd1:	90                   	nop

f0104bd2 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104bd2:	6a 11                	push   $0x11
f0104bd4:	e9 70 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bd9:	90                   	nop

f0104bda <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104bda:	6a 00                	push   $0x0
f0104bdc:	6a 12                	push   $0x12
f0104bde:	e9 66 00 00 00       	jmp    f0104c49 <_alltraps>
f0104be3:	90                   	nop

f0104be4 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104be4:	6a 00                	push   $0x0
f0104be6:	6a 13                	push   $0x13
f0104be8:	e9 5c 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bed:	90                   	nop

f0104bee <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104bee:	6a 00                	push   $0x0
f0104bf0:	6a 30                	push   $0x30
f0104bf2:	e9 52 00 00 00       	jmp    f0104c49 <_alltraps>
f0104bf7:	90                   	nop

f0104bf8 <t_default>:
TRAPHANDLER_NOEC(t_default, T_DEFAULT)
f0104bf8:	6a 00                	push   $0x0
f0104bfa:	68 f4 01 00 00       	push   $0x1f4
f0104bff:	e9 45 00 00 00       	jmp    f0104c49 <_alltraps>

f0104c04 <irq_timer>:
TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET+IRQ_TIMER)
f0104c04:	6a 00                	push   $0x0
f0104c06:	6a 20                	push   $0x20
f0104c08:	e9 3c 00 00 00       	jmp    f0104c49 <_alltraps>
f0104c0d:	90                   	nop

f0104c0e <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET+IRQ_KBD)
f0104c0e:	6a 00                	push   $0x0
f0104c10:	6a 21                	push   $0x21
f0104c12:	e9 32 00 00 00       	jmp    f0104c49 <_alltraps>
f0104c17:	90                   	nop

f0104c18 <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET+IRQ_SERIAL)
f0104c18:	6a 00                	push   $0x0
f0104c1a:	6a 24                	push   $0x24
f0104c1c:	e9 28 00 00 00       	jmp    f0104c49 <_alltraps>
f0104c21:	90                   	nop

f0104c22 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
f0104c22:	6a 00                	push   $0x0
f0104c24:	6a 27                	push   $0x27
f0104c26:	e9 1e 00 00 00       	jmp    f0104c49 <_alltraps>
f0104c2b:	90                   	nop

f0104c2c <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET+IRQ_IDE)
f0104c2c:	6a 00                	push   $0x0
f0104c2e:	6a 2e                	push   $0x2e
f0104c30:	e9 14 00 00 00       	jmp    f0104c49 <_alltraps>
f0104c35:	90                   	nop

f0104c36 <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET+IRQ_ERROR)
f0104c36:	6a 00                	push   $0x0
f0104c38:	6a 33                	push   $0x33
f0104c3a:	e9 0a 00 00 00       	jmp    f0104c49 <_alltraps>
f0104c3f:	90                   	nop

f0104c40 <irq_e1000>:

TRAPHANDLER_NOEC(irq_e1000, IRQ_OFFSET+IRQ_E1000)
f0104c40:	6a 00                	push   $0x0
f0104c42:	6a 2b                	push   $0x2b
f0104c44:	e9 00 00 00 00       	jmp    f0104c49 <_alltraps>

f0104c49 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	pushl %ds
f0104c49:	1e                   	push   %ds
	pushl %es
f0104c4a:	06                   	push   %es
	pushal
f0104c4b:	60                   	pusha  

	movl $GD_KD,%eax
f0104c4c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104c51:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104c53:	8e c0                	mov    %eax,%es
	push %esp
f0104c55:	54                   	push   %esp
	call trap
f0104c56:	e8 8b fc ff ff       	call   f01048e6 <trap>
	...

f0104c5c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104c5c:	55                   	push   %ebp
f0104c5d:	89 e5                	mov    %esp,%ebp
f0104c5f:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104c62:	8b 15 48 82 29 f0    	mov    0xf0298248,%edx
f0104c68:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c6b:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104c70:	8b 0a                	mov    (%edx),%ecx
f0104c72:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104c73:	83 f9 02             	cmp    $0x2,%ecx
f0104c76:	76 0d                	jbe    f0104c85 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104c78:	40                   	inc    %eax
f0104c79:	83 ea 80             	sub    $0xffffff80,%edx
f0104c7c:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c81:	75 ed                	jne    f0104c70 <sched_halt+0x14>
f0104c83:	eb 07                	jmp    f0104c8c <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c85:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c8a:	75 1a                	jne    f0104ca6 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104c8c:	c7 04 24 d0 92 10 f0 	movl   $0xf01092d0,(%esp)
f0104c93:	e8 96 f2 ff ff       	call   f0103f2e <cprintf>
		while (1)
			monitor(NULL);
f0104c98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c9f:	e8 fb bc ff ff       	call   f010099f <monitor>
f0104ca4:	eb f2                	jmp    f0104c98 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104ca6:	e8 f1 1b 00 00       	call   f010689c <cpunum>
f0104cab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cb2:	29 c2                	sub    %eax,%edx
f0104cb4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cb7:	c7 04 85 28 90 29 f0 	movl   $0x0,-0xfd66fd8(,%eax,4)
f0104cbe:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104cc2:	a1 98 8e 29 f0       	mov    0xf0298e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104cc7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104ccc:	77 20                	ja     f0104cee <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104cce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104cd2:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0104cd9:	f0 
f0104cda:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
f0104ce1:	00 
f0104ce2:	c7 04 24 f9 92 10 f0 	movl   $0xf01092f9,(%esp)
f0104ce9:	e8 52 b3 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104cee:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104cf3:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104cf6:	e8 a1 1b 00 00       	call   f010689c <cpunum>
f0104cfb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d02:	29 c2                	sub    %eax,%edx
f0104d04:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d07:	8d 14 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104d0e:	b8 02 00 00 00       	mov    $0x2,%eax
f0104d13:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104d17:	c7 04 24 c0 d3 12 f0 	movl   $0xf012d3c0,(%esp)
f0104d1e:	e8 db 1e 00 00       	call   f0106bfe <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104d23:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104d25:	e8 72 1b 00 00       	call   f010689c <cpunum>
f0104d2a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d31:	29 c2                	sub    %eax,%edx
f0104d33:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104d36:	8b 04 85 30 90 29 f0 	mov    -0xfd66fd0(,%eax,4),%eax
f0104d3d:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104d42:	89 c4                	mov    %eax,%esp
f0104d44:	6a 00                	push   $0x0
f0104d46:	6a 00                	push   $0x0
f0104d48:	fb                   	sti    
f0104d49:	f4                   	hlt    
f0104d4a:	eb fd                	jmp    f0104d49 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104d4c:	c9                   	leave  
f0104d4d:	c3                   	ret    

f0104d4e <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104d4e:	55                   	push   %ebp
f0104d4f:	89 e5                	mov    %esp,%ebp
f0104d51:	53                   	push   %ebx
f0104d52:	83 ec 14             	sub    $0x14,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
f0104d55:	e8 42 1b 00 00       	call   f010689c <cpunum>
f0104d5a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d61:	29 c2                	sub    %eax,%edx
f0104d63:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d66:	83 3c 85 28 90 29 f0 	cmpl   $0x0,-0xfd66fd8(,%eax,4)
f0104d6d:	00 
f0104d6e:	74 23                	je     f0104d93 <sched_yield+0x45>
f0104d70:	e8 27 1b 00 00       	call   f010689c <cpunum>
f0104d75:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d7c:	29 c2                	sub    %eax,%edx
f0104d7e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d81:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0104d88:	8b 48 48             	mov    0x48(%eax),%ecx
f0104d8b:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104d91:	eb 05                	jmp    f0104d98 <sched_yield+0x4a>
f0104d93:	b9 00 00 00 00       	mov    $0x0,%ecx
	int nevs = NENV+1;
	while (--nevs){
		i = (i+1)%NENV;
		if (envs[i].env_status == ENV_RUNNABLE)
f0104d98:	8b 1d 48 82 29 f0    	mov    0xf0298248,%ebx
f0104d9e:	ba 00 04 00 00       	mov    $0x400,%edx
	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
	int nevs = NENV+1;
	while (--nevs){
		i = (i+1)%NENV;
f0104da3:	8d 41 01             	lea    0x1(%ecx),%eax
f0104da6:	25 ff 03 00 80       	and    $0x800003ff,%eax
f0104dab:	79 07                	jns    f0104db4 <sched_yield+0x66>
f0104dad:	48                   	dec    %eax
f0104dae:	0d 00 fc ff ff       	or     $0xfffffc00,%eax
f0104db3:	40                   	inc    %eax
f0104db4:	89 c1                	mov    %eax,%ecx
		if (envs[i].env_status == ENV_RUNNABLE)
f0104db6:	c1 e0 07             	shl    $0x7,%eax
f0104db9:	01 d8                	add    %ebx,%eax
f0104dbb:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104dbf:	75 08                	jne    f0104dc9 <sched_yield+0x7b>
			env_run(&envs[i]);
f0104dc1:	89 04 24             	mov    %eax,(%esp)
f0104dc4:	e8 48 ef ff ff       	call   f0103d11 <env_run>

	// LAB 4: Your code here.
	
	int i = (curenv)?ENVX(curenv->env_id):0;
	int nevs = NENV+1;
	while (--nevs){
f0104dc9:	4a                   	dec    %edx
f0104dca:	75 d7                	jne    f0104da3 <sched_yield+0x55>
		i = (i+1)%NENV;
		if (envs[i].env_status == ENV_RUNNABLE)
			env_run(&envs[i]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104dcc:	e8 cb 1a 00 00       	call   f010689c <cpunum>
f0104dd1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dd8:	29 c2                	sub    %eax,%edx
f0104dda:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ddd:	83 3c 85 28 90 29 f0 	cmpl   $0x0,-0xfd66fd8(,%eax,4)
f0104de4:	00 
f0104de5:	74 3e                	je     f0104e25 <sched_yield+0xd7>
f0104de7:	e8 b0 1a 00 00       	call   f010689c <cpunum>
f0104dec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104df3:	29 c2                	sub    %eax,%edx
f0104df5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104df8:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0104dff:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104e03:	75 20                	jne    f0104e25 <sched_yield+0xd7>
		env_run(curenv);
f0104e05:	e8 92 1a 00 00       	call   f010689c <cpunum>
f0104e0a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e11:	29 c2                	sub    %eax,%edx
f0104e13:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e16:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0104e1d:	89 04 24             	mov    %eax,(%esp)
f0104e20:	e8 ec ee ff ff       	call   f0103d11 <env_run>
f0104e25:	a1 48 82 29 f0       	mov    0xf0298248,%eax
	
	for (i = 0;i < NENV; i++){
		if (envs[i].env_e1000_waiting_rx){
f0104e2a:	ba 00 04 00 00       	mov    $0x400,%edx
f0104e2f:	80 78 7c 00          	cmpb   $0x0,0x7c(%eax)
f0104e33:	74 0c                	je     f0104e41 <sched_yield+0xf3>
			envs[i].env_e1000_waiting_rx = false;
f0104e35:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
			env_run(&envs[i]);
f0104e39:	89 04 24             	mov    %eax,(%esp)
f0104e3c:	e8 d0 ee ff ff       	call   f0103d11 <env_run>
f0104e41:	83 e8 80             	sub    $0xffffff80,%eax
			env_run(&envs[i]);
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);
	
	for (i = 0;i < NENV; i++){
f0104e44:	4a                   	dec    %edx
f0104e45:	75 e8                	jne    f0104e2f <sched_yield+0xe1>
			env_run(&envs[i]);
		}
	}

	// sched_halt never returns
	sched_halt();
f0104e47:	e8 10 fe ff ff       	call   f0104c5c <sched_halt>
}
f0104e4c:	83 c4 14             	add    $0x14,%esp
f0104e4f:	5b                   	pop    %ebx
f0104e50:	5d                   	pop    %ebp
f0104e51:	c3                   	ret    
	...

f0104e54 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0104e54:	55                   	push   %ebp
f0104e55:	89 e5                	mov    %esp,%ebp
f0104e57:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104e5a:	e8 3d 1a 00 00       	call   f010689c <cpunum>
f0104e5f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e66:	29 c2                	sub    %eax,%edx
f0104e68:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e6b:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0104e72:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104e75:	c9                   	leave  
f0104e76:	c3                   	ret    

f0104e77 <sys_yield>:
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
f0104e77:	55                   	push   %ebp
f0104e78:	89 e5                	mov    %esp,%ebp
f0104e7a:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f0104e7d:	e8 cc fe ff ff       	call   f0104d4e <sched_yield>

f0104e82 <sys_e1000_get_mac>:
	return 0;
}

int
sys_e1000_get_mac(uint8_t *mac_addr)
{
f0104e82:	55                   	push   %ebp
f0104e83:	89 e5                	mov    %esp,%ebp
f0104e85:	53                   	push   %ebx
f0104e86:	83 ec 14             	sub    $0x14,%esp
f0104e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Make sure user controls address
	user_mem_assert(curenv, mac_addr, 12, PTE_W);
f0104e8c:	e8 0b 1a 00 00       	call   f010689c <cpunum>
f0104e91:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104e98:	00 
f0104e99:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f0104ea0:	00 
f0104ea1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104ea5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104eac:	29 c2                	sub    %eax,%edx
f0104eae:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104eb1:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0104eb8:	89 04 24             	mov    %eax,(%esp)
f0104ebb:	e8 6f e6 ff ff       	call   f010352f <user_mem_assert>
	e1000_get_mac(mac_addr);
f0104ec0:	89 1c 24             	mov    %ebx,(%esp)
f0104ec3:	e8 4c 23 00 00       	call   f0107214 <e1000_get_mac>
	return 0;
}
f0104ec8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ecd:	83 c4 14             	add    $0x14,%esp
f0104ed0:	5b                   	pop    %ebx
f0104ed1:	5d                   	pop    %ebp
f0104ed2:	c3                   	ret    

f0104ed3 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ed3:	55                   	push   %ebp
f0104ed4:	89 e5                	mov    %esp,%ebp
f0104ed6:	57                   	push   %edi
f0104ed7:	56                   	push   %esi
f0104ed8:	53                   	push   %ebx
f0104ed9:	83 ec 2c             	sub    $0x2c,%esp
f0104edc:	8b 45 08             	mov    0x8(%ebp),%eax
f0104edf:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104ee5:	8b 75 18             	mov    0x18(%ebp),%esi
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104ee8:	83 f8 11             	cmp    $0x11,%eax
f0104eeb:	0f 87 94 07 00 00    	ja     f0105685 <syscall+0x7b2>
f0104ef1:	ff 24 85 ac 95 10 f0 	jmp    *-0xfef6a54(,%eax,4)
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.

	user_mem_assert(curenv, (void*)s, len, 0); 
f0104ef8:	e8 9f 19 00 00       	call   f010689c <cpunum>
f0104efd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104f04:	00 
f0104f05:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104f09:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104f0d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f14:	29 c2                	sub    %eax,%edx
f0104f16:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f19:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0104f20:	89 04 24             	mov    %eax,(%esp)
f0104f23:	e8 07 e6 ff ff       	call   f010352f <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104f28:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104f30:	c7 04 24 06 93 10 f0 	movl   $0xf0109306,(%esp)
f0104f37:	e8 f2 ef ff ff       	call   f0103f2e <cprintf>
	//panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;
f0104f3c:	be 00 00 00 00       	mov    $0x0,%esi
f0104f41:	e9 52 07 00 00       	jmp    f0105698 <syscall+0x7c5>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104f46:	e8 01 b7 ff ff       	call   f010064c <cons_getc>
f0104f4b:	89 c6                	mov    %eax,%esi
		case SYS_cputs:
			sys_cputs((char*)a1, a2);
			return 0;

		case SYS_cgetc:
			return sys_cgetc();	
f0104f4d:	e9 46 07 00 00       	jmp    f0105698 <syscall+0x7c5>
		case SYS_getenvid:
			return sys_getenvid(); 
f0104f52:	e8 fd fe ff ff       	call   f0104e54 <sys_getenvid>
f0104f57:	89 c6                	mov    %eax,%esi
f0104f59:	e9 3a 07 00 00       	jmp    f0105698 <syscall+0x7c5>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104f5e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f65:	00 
f0104f66:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f6d:	89 3c 24             	mov    %edi,(%esp)
f0104f70:	e8 d5 e6 ff ff       	call   f010364a <envid2env>
f0104f75:	89 c6                	mov    %eax,%esi
f0104f77:	85 c0                	test   %eax,%eax
f0104f79:	0f 88 19 07 00 00    	js     f0105698 <syscall+0x7c5>
	  return r;
	env_destroy(e);
f0104f7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f82:	89 04 24             	mov    %eax,(%esp)
f0104f85:	e8 c8 ec ff ff       	call   f0103c52 <env_destroy>
	return 0;
f0104f8a:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_cgetc:
			return sys_cgetc();	
		case SYS_getenvid:
			return sys_getenvid(); 
		case SYS_env_destroy:
			return sys_env_destroy(a1); 
f0104f8f:	e9 04 07 00 00       	jmp    f0105698 <syscall+0x7c5>
		case SYS_yield:
			sys_yield();
f0104f94:	e8 de fe ff ff       	call   f0104e77 <sys_yield>

	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");

	struct Env* e;
	int ret = env_alloc(&e, sys_getenvid());
f0104f99:	e8 b6 fe ff ff       	call   f0104e54 <sys_getenvid>
f0104f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fa2:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104fa5:	89 04 24             	mov    %eax,(%esp)
f0104fa8:	e8 cb e7 ff ff       	call   f0103778 <env_alloc>
f0104fad:	89 c6                	mov    %eax,%esi
	if (ret < 0){
f0104faf:	85 c0                	test   %eax,%eax
f0104fb1:	79 11                	jns    f0104fc4 <syscall+0xf1>
		cprintf("sys_exofork: env_alloc failed");
f0104fb3:	c7 04 24 0b 93 10 f0 	movl   $0xf010930b,(%esp)
f0104fba:	e8 6f ef ff ff       	call   f0103f2e <cprintf>
f0104fbf:	e9 d4 06 00 00       	jmp    f0105698 <syscall+0x7c5>
		return ret;
	}
	e->env_status = ENV_NOT_RUNNABLE;
f0104fc4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104fc7:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104fce:	e8 c9 18 00 00       	call   f010689c <cpunum>
f0104fd3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104fda:	29 c2                	sub    %eax,%edx
f0104fdc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104fdf:	8b 34 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%esi
f0104fe6:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104feb:	89 df                	mov    %ebx,%edi
f0104fed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;  //?
f0104fef:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ff2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104ff9:	8b 70 48             	mov    0x48(%eax),%esi
			return sys_env_destroy(a1); 
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
f0104ffc:	e9 97 06 00 00       	jmp    f0105698 <syscall+0x7c5>
	// envid's status.

	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");

	if (status != ENV_RUNNABLE && status!= ENV_NOT_RUNNABLE) {
f0105001:	83 fb 02             	cmp    $0x2,%ebx
f0105004:	74 1b                	je     f0105021 <syscall+0x14e>
f0105006:	83 fb 04             	cmp    $0x4,%ebx
f0105009:	74 16                	je     f0105021 <syscall+0x14e>
		cprintf("sys_env_set_status: wrong status input");
f010500b:	c7 04 24 38 93 10 f0 	movl   $0xf0109338,(%esp)
f0105012:	e8 17 ef ff ff       	call   f0103f2e <cprintf>
		return -E_INVAL;
f0105017:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010501c:	e9 77 06 00 00       	jmp    f0105698 <syscall+0x7c5>
	}

	struct Env* e;
	int ret = envid2env(envid, &e, true);
f0105021:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105028:	00 
f0105029:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010502c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105030:	89 3c 24             	mov    %edi,(%esp)
f0105033:	e8 12 e6 ff ff       	call   f010364a <envid2env>
f0105038:	89 c6                	mov    %eax,%esi
	if (ret < 0) {
f010503a:	85 c0                	test   %eax,%eax
f010503c:	79 11                	jns    f010504f <syscall+0x17c>
		cprintf("sys_env_set_status: envid2env fail");
f010503e:	c7 04 24 60 93 10 f0 	movl   $0xf0109360,(%esp)
f0105045:	e8 e4 ee ff ff       	call   f0103f2e <cprintf>
f010504a:	e9 49 06 00 00       	jmp    f0105698 <syscall+0x7c5>
		return ret;
	}
	e->env_status = status;
f010504f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105052:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f0105055:	be 00 00 00 00       	mov    $0x0,%esi
			sys_yield();
			return 0;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
f010505a:	e9 39 06 00 00       	jmp    f0105698 <syscall+0x7c5>

	// LAB 4: Your code here.
	//panic("sys_page_alloc not implemented");

	//check input validness
	if ((uint32_t)va >= UTOP || ROUNDUP(va, PGSIZE) != va){
f010505f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105065:	77 0f                	ja     f0105076 <syscall+0x1a3>
f0105067:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f010506d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105072:	39 c3                	cmp    %eax,%ebx
f0105074:	74 16                	je     f010508c <syscall+0x1b9>
		cprintf("sys_page_alloc: wrong va input");
f0105076:	c7 04 24 84 93 10 f0 	movl   $0xf0109384,(%esp)
f010507d:	e8 ac ee ff ff       	call   f0103f2e <cprintf>
		return -E_INVAL;
f0105082:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105087:	e9 0c 06 00 00       	jmp    f0105698 <syscall+0x7c5>
	}

	if((perm & ~PTE_SYSCALL) != 0){
f010508c:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0105093:	74 16                	je     f01050ab <syscall+0x1d8>
		cprintf("sys_page_alloc: wrong perm input");
f0105095:	c7 04 24 a4 93 10 f0 	movl   $0xf01093a4,(%esp)
f010509c:	e8 8d ee ff ff       	call   f0103f2e <cprintf>
		return -E_INVAL;
f01050a1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01050a6:	e9 ed 05 00 00       	jmp    f0105698 <syscall+0x7c5>
	}

	struct PageInfo* pp;
	struct Env* e;
	int ret1 = envid2env(envid, &e, 1);
f01050ab:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050b2:	00 
f01050b3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01050b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050ba:	89 3c 24             	mov    %edi,(%esp)
f01050bd:	e8 88 e5 ff ff       	call   f010364a <envid2env>
	if (ret1 < 0) {
f01050c2:	85 c0                	test   %eax,%eax
f01050c4:	79 16                	jns    f01050dc <syscall+0x209>
		cprintf("sys_page_alloc: envid2env wrong");
f01050c6:	c7 04 24 c8 93 10 f0 	movl   $0xf01093c8,(%esp)
f01050cd:	e8 5c ee ff ff       	call   f0103f2e <cprintf>
		return -E_BAD_ENV; 
f01050d2:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01050d7:	e9 bc 05 00 00       	jmp    f0105698 <syscall+0x7c5>
	}

	pp = page_alloc(1);
f01050dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01050e3:	e8 f3 be ff ff       	call   f0100fdb <page_alloc>
f01050e8:	89 c6                	mov    %eax,%esi
	if (pp == NULL) {
f01050ea:	85 c0                	test   %eax,%eax
f01050ec:	75 16                	jne    f0105104 <syscall+0x231>
		cprintf("sys_page_alloc: page_alloc failed");
f01050ee:	c7 04 24 e8 93 10 f0 	movl   $0xf01093e8,(%esp)
f01050f5:	e8 34 ee ff ff       	call   f0103f2e <cprintf>
		return -E_NO_MEM;
f01050fa:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01050ff:	e9 94 05 00 00       	jmp    f0105698 <syscall+0x7c5>
	}

	int ret2 = page_insert(e->env_pgdir, pp, va, perm);
f0105104:	8b 45 14             	mov    0x14(%ebp),%eax
f0105107:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010510b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010510f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105113:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105116:	8b 40 60             	mov    0x60(%eax),%eax
f0105119:	89 04 24             	mov    %eax,(%esp)
f010511c:	e8 54 c2 ff ff       	call   f0101375 <page_insert>
	if (ret2 < 0){
f0105121:	85 c0                	test   %eax,%eax
f0105123:	79 1e                	jns    f0105143 <syscall+0x270>
		page_free(pp);
f0105125:	89 34 24             	mov    %esi,(%esp)
f0105128:	e8 61 bf ff ff       	call   f010108e <page_free>
		cprintf("sys_page_alloc: page_insert failed");
f010512d:	c7 04 24 0c 94 10 f0 	movl   $0xf010940c,(%esp)
f0105134:	e8 f5 ed ff ff       	call   f0103f2e <cprintf>
		return -E_NO_MEM;
f0105139:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f010513e:	e9 55 05 00 00       	jmp    f0105698 <syscall+0x7c5>
	}
	return 0;
f0105143:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3); 
f0105148:	e9 4b 05 00 00       	jmp    f0105698 <syscall+0x7c5>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");

	if ((uint32_t)srcva >= UTOP || ROUNDUP(srcva,PGSIZE)!=srcva || (uint32_t)dstva >= UTOP || ROUNDUP(dstva,PGSIZE)!=dstva){
f010514d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105153:	77 26                	ja     f010517b <syscall+0x2a8>
f0105155:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f010515b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105160:	39 c3                	cmp    %eax,%ebx
f0105162:	75 17                	jne    f010517b <syscall+0x2a8>
f0105164:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010516a:	77 0f                	ja     f010517b <syscall+0x2a8>
f010516c:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
f0105172:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105177:	39 c6                	cmp    %eax,%esi
f0105179:	74 1c                	je     f0105197 <syscall+0x2c4>
		panic("sys_page_map: invalid srcva | dstva");
f010517b:	c7 44 24 08 30 94 10 	movl   $0xf0109430,0x8(%esp)
f0105182:	f0 
f0105183:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
f010518a:	00 
f010518b:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f0105192:	e8 a9 ae ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	if ((perm & ~PTE_SYSCALL)!=0){
f0105197:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f010519e:	74 1c                	je     f01051bc <syscall+0x2e9>
		panic("sys_page_map: invalid permission");
f01051a0:	c7 44 24 08 54 94 10 	movl   $0xf0109454,0x8(%esp)
f01051a7:	f0 
f01051a8:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
f01051af:	00 
f01051b0:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f01051b7:	e8 84 ae ff ff       	call   f0100040 <_panic>

	pte_t* srcpte;
	struct Env* srcenv;
	struct Env* dstenv; 
	struct PageInfo* pp;
	if ((envid2env(srcenvid, &srcenv, true) < 0) || envid2env(dstenvid, &dstenv, true) < 0)
f01051bc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051c3:	00 
f01051c4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01051c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051cb:	89 3c 24             	mov    %edi,(%esp)
f01051ce:	e8 77 e4 ff ff       	call   f010364a <envid2env>
f01051d3:	85 c0                	test   %eax,%eax
f01051d5:	0f 88 a6 00 00 00    	js     f0105281 <syscall+0x3ae>
f01051db:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01051e2:	00 
f01051e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01051e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051ea:	8b 55 14             	mov    0x14(%ebp),%edx
f01051ed:	89 14 24             	mov    %edx,(%esp)
f01051f0:	e8 55 e4 ff ff       	call   f010364a <envid2env>
f01051f5:	85 c0                	test   %eax,%eax
f01051f7:	0f 88 8e 00 00 00    	js     f010528b <syscall+0x3b8>
	  return -E_BAD_ENV;
	pp = page_lookup(srcenv->env_pgdir, srcva, &srcpte);	
f01051fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105200:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105204:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105208:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010520b:	8b 40 60             	mov    0x60(%eax),%eax
f010520e:	89 04 24             	mov    %eax,(%esp)
f0105211:	e8 56 c0 ff ff       	call   f010126c <page_lookup>
	if (pp == NULL || ((perm&PTE_W) > 0 && (*srcpte&PTE_W) == 0)){
f0105216:	85 c0                	test   %eax,%eax
f0105218:	74 0e                	je     f0105228 <syscall+0x355>
f010521a:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010521e:	74 24                	je     f0105244 <syscall+0x371>
f0105220:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105223:	f6 02 02             	testb  $0x2,(%edx)
f0105226:	75 1c                	jne    f0105244 <syscall+0x371>
		panic("sys_page_map: page_lookup failed");
f0105228:	c7 44 24 08 78 94 10 	movl   $0xf0109478,0x8(%esp)
f010522f:	f0 
f0105230:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0105237:	00 
f0105238:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f010523f:	e8 fc ad ff ff       	call   f0100040 <_panic>
		return -E_INVAL;
	}
	if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0){
f0105244:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105247:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010524b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010524f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105256:	8b 40 60             	mov    0x60(%eax),%eax
f0105259:	89 04 24             	mov    %eax,(%esp)
f010525c:	e8 14 c1 ff ff       	call   f0101375 <page_insert>
f0105261:	85 c0                	test   %eax,%eax
f0105263:	79 30                	jns    f0105295 <syscall+0x3c2>
		panic("sys_page_map: page_insert failed");
f0105265:	c7 44 24 08 9c 94 10 	movl   $0xf010949c,0x8(%esp)
f010526c:	f0 
f010526d:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
f0105274:	00 
f0105275:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f010527c:	e8 bf ad ff ff       	call   f0100040 <_panic>
	pte_t* srcpte;
	struct Env* srcenv;
	struct Env* dstenv; 
	struct PageInfo* pp;
	if ((envid2env(srcenvid, &srcenv, true) < 0) || envid2env(dstenvid, &dstenv, true) < 0)
	  return -E_BAD_ENV;
f0105281:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105286:	e9 0d 04 00 00       	jmp    f0105698 <syscall+0x7c5>
f010528b:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105290:	e9 03 04 00 00       	jmp    f0105698 <syscall+0x7c5>
	}
	if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0){
		panic("sys_page_map: page_insert failed");
		return -E_NO_MEM;
	}
	return 0;
f0105295:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3); 
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f010529a:	e9 f9 03 00 00       	jmp    f0105698 <syscall+0x7c5>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE)!= va)
f010529f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01052a5:	77 46                	ja     f01052ed <syscall+0x41a>
f01052a7:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
f01052ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01052b2:	39 c3                	cmp    %eax,%ebx
f01052b4:	75 41                	jne    f01052f7 <syscall+0x424>
	  return -E_INVAL;
	struct Env* e;
	if (envid2env(envid, &e, true) < 0)
f01052b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01052bd:	00 
f01052be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01052c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052c5:	89 3c 24             	mov    %edi,(%esp)
f01052c8:	e8 7d e3 ff ff       	call   f010364a <envid2env>
f01052cd:	85 c0                	test   %eax,%eax
f01052cf:	78 30                	js     f0105301 <syscall+0x42e>
	  return -E_BAD_ENV;
	page_remove(e->env_pgdir, va);
f01052d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01052d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052d8:	8b 40 60             	mov    0x60(%eax),%eax
f01052db:	89 04 24             	mov    %eax,(%esp)
f01052de:	e8 42 c0 ff ff       	call   f0101325 <page_remove>
	return 0;
f01052e3:	be 00 00 00 00       	mov    $0x0,%esi
f01052e8:	e9 ab 03 00 00       	jmp    f0105698 <syscall+0x7c5>

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");

	if ((uint32_t)va >= UTOP || ROUNDUP(va,PGSIZE)!= va)
	  return -E_INVAL;
f01052ed:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052f2:	e9 a1 03 00 00       	jmp    f0105698 <syscall+0x7c5>
f01052f7:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01052fc:	e9 97 03 00 00       	jmp    f0105698 <syscall+0x7c5>
	struct Env* e;
	if (envid2env(envid, &e, true) < 0)
	  return -E_BAD_ENV;
f0105301:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3); 
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
f0105306:	e9 8d 03 00 00       	jmp    f0105698 <syscall+0x7c5>
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
f010530b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105312:	00 
f0105313:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105316:	89 44 24 04          	mov    %eax,0x4(%esp)
f010531a:	89 3c 24             	mov    %edi,(%esp)
f010531d:	e8 28 e3 ff ff       	call   f010364a <envid2env>
f0105322:	85 c0                	test   %eax,%eax
f0105324:	78 10                	js     f0105336 <syscall+0x463>
	  return -E_BAD_ENV;

	e->env_pgfault_upcall = func;
f0105326:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105329:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f010532c:	be 00 00 00 00       	mov    $0x0,%esi
f0105331:	e9 62 03 00 00       	jmp    f0105698 <syscall+0x7c5>
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
	  return -E_BAD_ENV;
f0105336:	be fe ff ff ff       	mov    $0xfffffffe,%esi
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);		
f010533b:	e9 58 03 00 00       	jmp    f0105698 <syscall+0x7c5>
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");

	int r;
	struct Env* e;
	if ((r = envid2env(envid, &e, 0)) < 0){
f0105340:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105347:	00 
f0105348:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010534b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010534f:	89 3c 24             	mov    %edi,(%esp)
f0105352:	e8 f3 e2 ff ff       	call   f010364a <envid2env>
f0105357:	85 c0                	test   %eax,%eax
f0105359:	79 20                	jns    f010537b <syscall+0x4a8>
		panic("sys_ipc_try_send: envid2env failed, %e", r);
f010535b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010535f:	c7 44 24 08 c0 94 10 	movl   $0xf01094c0,0x8(%esp)
f0105366:	f0 
f0105367:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f010536e:	00 
f010536f:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f0105376:	e8 c5 ac ff ff       	call   f0100040 <_panic>
		return -E_BAD_ENV;
	}
	if (e->env_ipc_recving == false) 
f010537b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010537e:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105382:	0f 84 3d 01 00 00    	je     f01054c5 <syscall+0x5f2>
	  return -E_IPC_NOT_RECV;
	e->env_ipc_perm = 0;
f0105388:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	if ((uint32_t)srcva < UTOP){
f010538f:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105396:	0f 87 e6 00 00 00    	ja     f0105482 <syscall+0x5af>
		pte_t* pte; 
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f010539c:	e8 fb 14 00 00       	call   f010689c <cpunum>
f01053a1:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01053a4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053a8:	8b 55 14             	mov    0x14(%ebp),%edx
f01053ab:	89 54 24 04          	mov    %edx,0x4(%esp)
f01053af:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01053b6:	29 c2                	sub    %eax,%edx
f01053b8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01053bb:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f01053c2:	8b 40 60             	mov    0x60(%eax),%eax
f01053c5:	89 04 24             	mov    %eax,(%esp)
f01053c8:	e8 9f be ff ff       	call   f010126c <page_lookup>
		if (pte == NULL)
f01053cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053d0:	85 d2                	test   %edx,%edx
f01053d2:	0f 84 f7 00 00 00    	je     f01054cf <syscall+0x5fc>
		  return -E_INVAL;
		if (ROUNDDOWN(srcva, PGSIZE) != srcva || ((perm & ~PTE_SYSCALL) != 0)){
f01053d8:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01053db:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01053e1:	39 4d 14             	cmp    %ecx,0x14(%ebp)
f01053e4:	75 08                	jne    f01053ee <syscall+0x51b>
f01053e6:	f7 c6 f8 f1 ff ff    	test   $0xfffff1f8,%esi
f01053ec:	74 1c                	je     f010540a <syscall+0x537>
			panic("sys_ipc_try_send: srcva failed)");
f01053ee:	c7 44 24 08 e8 94 10 	movl   $0xf01094e8,0x8(%esp)
f01053f5:	f0 
f01053f6:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f01053fd:	00 
f01053fe:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f0105405:	e8 36 ac ff ff       	call   f0100040 <_panic>
			return -E_INVAL;
		}
		if ((perm&PTE_W) && (*pte&PTE_W)==0){
f010540a:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0105410:	74 21                	je     f0105433 <syscall+0x560>
f0105412:	f6 02 02             	testb  $0x2,(%edx)
f0105415:	75 1c                	jne    f0105433 <syscall+0x560>
			panic("sys_ipc_try_send: permission failed");
f0105417:	c7 44 24 08 08 95 10 	movl   $0xf0109508,0x8(%esp)
f010541e:	f0 
f010541f:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0105426:	00 
f0105427:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f010542e:	e8 0d ac ff ff       	call   f0100040 <_panic>
			return -E_INVAL;
		}
		if ((uint32_t)e->env_ipc_dstva < UTOP){
f0105433:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105436:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105439:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010543f:	77 41                	ja     f0105482 <syscall+0x5af>
			if((r = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm)) < 0){
f0105441:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105445:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105449:	89 44 24 04          	mov    %eax,0x4(%esp)
f010544d:	8b 42 60             	mov    0x60(%edx),%eax
f0105450:	89 04 24             	mov    %eax,(%esp)
f0105453:	e8 1d bf ff ff       	call   f0101375 <page_insert>
f0105458:	85 c0                	test   %eax,%eax
f010545a:	79 20                	jns    f010547c <syscall+0x5a9>
				panic("sys_ipc_try_send: page_insert failed %e", r);
f010545c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105460:	c7 44 24 08 2c 95 10 	movl   $0xf010952c,0x8(%esp)
f0105467:	f0 
f0105468:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f010546f:	00 
f0105470:	c7 04 24 29 93 10 f0 	movl   $0xf0109329,(%esp)
f0105477:	e8 c4 ab ff ff       	call   f0100040 <_panic>
				return -E_NO_MEM;
			}
			e->env_ipc_perm = perm;
f010547c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010547f:	89 70 78             	mov    %esi,0x78(%eax)
		}
	}
	e->env_ipc_recving = 0;
f0105482:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105485:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id; 
f0105489:	e8 0e 14 00 00       	call   f010689c <cpunum>
f010548e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105495:	29 c2                	sub    %eax,%edx
f0105497:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010549a:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f01054a1:	8b 40 48             	mov    0x48(%eax),%eax
f01054a4:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;
f01054a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054aa:	89 58 70             	mov    %ebx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f01054ad:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax= 0;
f01054b4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f01054bb:	be 00 00 00 00       	mov    $0x0,%esi
f01054c0:	e9 d3 01 00 00       	jmp    f0105698 <syscall+0x7c5>
	if ((r = envid2env(envid, &e, 0)) < 0){
		panic("sys_ipc_try_send: envid2env failed, %e", r);
		return -E_BAD_ENV;
	}
	if (e->env_ipc_recving == false) 
	  return -E_IPC_NOT_RECV;
f01054c5:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f01054ca:	e9 c9 01 00 00       	jmp    f0105698 <syscall+0x7c5>
	e->env_ipc_perm = 0;
	if ((uint32_t)srcva < UTOP){
		pte_t* pte; 
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (pte == NULL)
		  return -E_INVAL;
f01054cf:	be fd ff ff ff       	mov    $0xfffffffd,%esi
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);		
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
f01054d4:	e9 bf 01 00 00       	jmp    f0105698 <syscall+0x7c5>
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");

	if (((uint32_t)dstva < UTOP) && (ROUNDDOWN(dstva, PGSIZE) != dstva))
f01054d9:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f01054df:	77 0f                	ja     f01054f0 <syscall+0x61d>
f01054e1:	89 f8                	mov    %edi,%eax
f01054e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01054e8:	39 c7                	cmp    %eax,%edi
f01054ea:	0f 85 9c 01 00 00    	jne    f010568c <syscall+0x7b9>
	  return -E_INVAL;
	curenv->env_ipc_recving = true;
f01054f0:	e8 a7 13 00 00       	call   f010689c <cpunum>
f01054f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01054f8:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f01054fe:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105502:	e8 95 13 00 00       	call   f010689c <cpunum>
f0105507:	6b c0 74             	imul   $0x74,%eax,%eax
f010550a:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0105510:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0105517:	e8 80 13 00 00       	call   f010689c <cpunum>
f010551c:	6b c0 74             	imul   $0x74,%eax,%eax
f010551f:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0105525:	89 78 6c             	mov    %edi,0x6c(%eax)

	sys_yield();
f0105528:	e8 4a f9 ff ff       	call   f0104e77 <sys_yield>
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
	int r;
	struct Env* e;
	if ((r = envid2env(envid, &e, 1)) < 0){
f010552d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105534:	00 
f0105535:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105538:	89 44 24 04          	mov    %eax,0x4(%esp)
f010553c:	89 3c 24             	mov    %edi,(%esp)
f010553f:	e8 06 e1 ff ff       	call   f010364a <envid2env>
f0105544:	89 c6                	mov    %eax,%esi
f0105546:	85 c0                	test   %eax,%eax
f0105548:	79 15                	jns    f010555f <syscall+0x68c>
		cprintf("sys_env_set_trapframe: envid2env, %e", r);
f010554a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010554e:	c7 04 24 54 95 10 f0 	movl   $0xf0109554,(%esp)
f0105555:	e8 d4 e9 ff ff       	call   f0103f2e <cprintf>
f010555a:	e9 39 01 00 00       	jmp    f0105698 <syscall+0x7c5>
		return r;
	}
	tf->tf_eflags |= FL_IF;
f010555f:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_tf = *tf;
f0105566:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105569:	b9 11 00 00 00       	mov    $0x11,%ecx
f010556e:	89 c7                	mov    %eax,%edi
f0105570:	89 de                	mov    %ebx,%esi
f0105572:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return 0;
f0105574:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);
f0105579:	e9 1a 01 00 00       	jmp    f0105698 <syscall+0x7c5>
sys_time_msec(void)
{
	// LAB 6: Your code here.
	//panic("sys_time_msec not implemented");

	return  time_msec();
f010557e:	e8 28 23 00 00       	call   f01078ab <time_msec>
f0105583:	89 c6                	mov    %eax,%esi
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);
		case SYS_time_msec:
			return sys_time_msec();
f0105585:	e9 0e 01 00 00       	jmp    f0105698 <syscall+0x7c5>
sys_e1000_transmit(char * pck, size_t length)
{
	int r;
	int num_try = 20;

	if ((r = user_mem_check(curenv, (void*)pck, length, PTE_P)) < 0){
f010558a:	e8 0d 13 00 00       	call   f010689c <cpunum>
f010558f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
f0105596:	00 
f0105597:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010559b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010559f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01055a6:	29 c2                	sub    %eax,%edx
f01055a8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01055ab:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f01055b2:	89 04 24             	mov    %eax,(%esp)
f01055b5:	e8 d0 de ff ff       	call   f010348a <user_mem_check>
f01055ba:	89 c6                	mov    %eax,%esi
f01055bc:	85 c0                	test   %eax,%eax
f01055be:	79 1a                	jns    f01055da <syscall+0x707>
		cprintf("sys_e1000_transmit: user_mem_check failed, %e", r);
f01055c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055c4:	c7 04 24 7c 95 10 f0 	movl   $0xf010957c,(%esp)
f01055cb:	e8 5e e9 ff ff       	call   f0103f2e <cprintf>
f01055d0:	e9 c3 00 00 00       	jmp    f0105698 <syscall+0x7c5>
		return r;
	}

	while((r = e1000_transmit(pck, length)) < 0 && num_try){
		sys_yield();
f01055d5:	e8 9d f8 ff ff       	call   f0104e77 <sys_yield>
	if ((r = user_mem_check(curenv, (void*)pck, length, PTE_P)) < 0){
		cprintf("sys_e1000_transmit: user_mem_check failed, %e", r);
		return r;
	}

	while((r = e1000_transmit(pck, length)) < 0 && num_try){
f01055da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055de:	89 3c 24             	mov    %edi,(%esp)
f01055e1:	e8 26 17 00 00       	call   f0106d0c <e1000_transmit>
f01055e6:	85 c0                	test   %eax,%eax
f01055e8:	78 eb                	js     f01055d5 <syscall+0x702>
		num_try--;
	}
	if (num_try == 0)
	  return -E_E1000_TXBUF_FULL;

	return 0;
f01055ea:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe*)a2);
		case SYS_time_msec:
			return sys_time_msec();
		case SYS_e1000_transmit:
			return sys_e1000_transmit((char *)a1, a2);
f01055ef:	e9 a4 00 00 00       	jmp    f0105698 <syscall+0x7c5>

static int
sys_e1000_receive(char * pck, size_t* length)
{

	user_mem_assert(curenv, pck, PKT_SIZE, PTE_W);
f01055f4:	e8 a3 12 00 00       	call   f010689c <cpunum>
f01055f9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0105600:	00 
f0105601:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
f0105608:	00 
f0105609:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010560d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105614:	29 c2                	sub    %eax,%edx
f0105616:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105619:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f0105620:	89 04 24             	mov    %eax,(%esp)
f0105623:	e8 07 df ff ff       	call   f010352f <user_mem_assert>
	if (e1000_receive(pck, length) == 0)
f0105628:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010562c:	89 3c 24             	mov    %edi,(%esp)
f010562f:	e8 6c 17 00 00       	call   f0106da0 <e1000_receive>
f0105634:	85 c0                	test   %eax,%eax
f0105636:	74 5b                	je     f0105693 <syscall+0x7c0>
	  return 0;
	else {
		curenv->env_status = ENV_NOT_RUNNABLE;
f0105638:	e8 5f 12 00 00       	call   f010689c <cpunum>
f010563d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105640:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f0105646:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
		curenv->env_e1000_waiting_rx = true;
f010564d:	e8 4a 12 00 00       	call   f010689c <cpunum>
f0105652:	6b c0 74             	imul   $0x74,%eax,%eax
f0105655:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f010565b:	c6 40 7c 01          	movb   $0x1,0x7c(%eax)
		curenv->env_tf.tf_regs.reg_eax = -E_E1000_RXBUF_EMPTY;
f010565f:	e8 38 12 00 00       	call   f010689c <cpunum>
f0105664:	6b c0 74             	imul   $0x74,%eax,%eax
f0105667:	8b 80 28 90 29 f0    	mov    -0xfd66fd8(%eax),%eax
f010566d:	c7 40 1c ef ff ff ff 	movl   $0xffffffef,0x1c(%eax)
		sys_yield();
f0105674:	e8 fe f7 ff ff       	call   f0104e77 <sys_yield>
		case SYS_e1000_transmit:
			return sys_e1000_transmit((char *)a1, a2);
		case SYS_e1000_receive:
			return sys_e1000_receive((char*)a1, (size_t*)a2);
		case SYS_e1000_get_mac:
			return sys_e1000_get_mac((uint8_t *)a1);
f0105679:	89 3c 24             	mov    %edi,(%esp)
f010567c:	e8 01 f8 ff ff       	call   f0104e82 <sys_e1000_get_mac>
f0105681:	89 c6                	mov    %eax,%esi
f0105683:	eb 13                	jmp    f0105698 <syscall+0x7c5>
		default:
			return -E_INVAL;
f0105685:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010568a:	eb 0c                	jmp    f0105698 <syscall+0x7c5>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void*)a2);		
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void*)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f010568c:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105691:	eb 05                	jmp    f0105698 <syscall+0x7c5>
		case SYS_time_msec:
			return sys_time_msec();
		case SYS_e1000_transmit:
			return sys_e1000_transmit((char *)a1, a2);
		case SYS_e1000_receive:
			return sys_e1000_receive((char*)a1, (size_t*)a2);
f0105693:	be 00 00 00 00       	mov    $0x0,%esi
		case SYS_e1000_get_mac:
			return sys_e1000_get_mac((uint8_t *)a1);
		default:
			return -E_INVAL;
	}	
}
f0105698:	89 f0                	mov    %esi,%eax
f010569a:	83 c4 2c             	add    $0x2c,%esp
f010569d:	5b                   	pop    %ebx
f010569e:	5e                   	pop    %esi
f010569f:	5f                   	pop    %edi
f01056a0:	5d                   	pop    %ebp
f01056a1:	c3                   	ret    
	...

f01056a4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01056a4:	55                   	push   %ebp
f01056a5:	89 e5                	mov    %esp,%ebp
f01056a7:	57                   	push   %edi
f01056a8:	56                   	push   %esi
f01056a9:	53                   	push   %ebx
f01056aa:	83 ec 14             	sub    $0x14,%esp
f01056ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01056b0:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01056b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01056b6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01056b9:	8b 1a                	mov    (%edx),%ebx
f01056bb:	8b 01                	mov    (%ecx),%eax
f01056bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01056c0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01056c7:	e9 83 00 00 00       	jmp    f010574f <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f01056cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01056cf:	01 d8                	add    %ebx,%eax
f01056d1:	89 c7                	mov    %eax,%edi
f01056d3:	c1 ef 1f             	shr    $0x1f,%edi
f01056d6:	01 c7                	add    %eax,%edi
f01056d8:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01056da:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01056dd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01056e0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01056e4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01056e6:	eb 01                	jmp    f01056e9 <stab_binsearch+0x45>
			m--;
f01056e8:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01056e9:	39 c3                	cmp    %eax,%ebx
f01056eb:	7f 1e                	jg     f010570b <stab_binsearch+0x67>
f01056ed:	0f b6 0a             	movzbl (%edx),%ecx
f01056f0:	83 ea 0c             	sub    $0xc,%edx
f01056f3:	39 f1                	cmp    %esi,%ecx
f01056f5:	75 f1                	jne    f01056e8 <stab_binsearch+0x44>
f01056f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01056fa:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01056fd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105700:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105704:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105707:	76 18                	jbe    f0105721 <stab_binsearch+0x7d>
f0105709:	eb 05                	jmp    f0105710 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010570b:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010570e:	eb 3f                	jmp    f010574f <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105710:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105713:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0105715:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105718:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010571f:	eb 2e                	jmp    f010574f <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105721:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105724:	73 15                	jae    f010573b <stab_binsearch+0x97>
			*region_right = m - 1;
f0105726:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105729:	49                   	dec    %ecx
f010572a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010572d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105730:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105732:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105739:	eb 14                	jmp    f010574f <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010573b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010573e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105741:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0105743:	ff 45 0c             	incl   0xc(%ebp)
f0105746:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105748:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010574f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105752:	0f 8e 74 ff ff ff    	jle    f01056cc <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105758:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010575c:	75 0d                	jne    f010576b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010575e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105761:	8b 02                	mov    (%edx),%eax
f0105763:	48                   	dec    %eax
f0105764:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105767:	89 01                	mov    %eax,(%ecx)
f0105769:	eb 2a                	jmp    f0105795 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010576b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010576e:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105770:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105773:	8b 0a                	mov    (%edx),%ecx
f0105775:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105778:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010577b:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010577f:	eb 01                	jmp    f0105782 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105781:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105782:	39 c8                	cmp    %ecx,%eax
f0105784:	7e 0a                	jle    f0105790 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0105786:	0f b6 1a             	movzbl (%edx),%ebx
f0105789:	83 ea 0c             	sub    $0xc,%edx
f010578c:	39 f3                	cmp    %esi,%ebx
f010578e:	75 f1                	jne    f0105781 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105790:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105793:	89 02                	mov    %eax,(%edx)
	}
}
f0105795:	83 c4 14             	add    $0x14,%esp
f0105798:	5b                   	pop    %ebx
f0105799:	5e                   	pop    %esi
f010579a:	5f                   	pop    %edi
f010579b:	5d                   	pop    %ebp
f010579c:	c3                   	ret    

f010579d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010579d:	55                   	push   %ebp
f010579e:	89 e5                	mov    %esp,%ebp
f01057a0:	57                   	push   %edi
f01057a1:	56                   	push   %esi
f01057a2:	53                   	push   %ebx
f01057a3:	83 ec 5c             	sub    $0x5c,%esp
f01057a6:	8b 75 08             	mov    0x8(%ebp),%esi
f01057a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01057ac:	c7 03 f4 95 10 f0    	movl   $0xf01095f4,(%ebx)
	info->eip_line = 0;
f01057b2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01057b9:	c7 43 08 f4 95 10 f0 	movl   $0xf01095f4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01057c0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01057c7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01057ca:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01057d1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01057d7:	0f 87 df 00 00 00    	ja     f01058bc <debuginfo_eip+0x11f>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f01057dd:	e8 ba 10 00 00       	call   f010689c <cpunum>
f01057e2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01057e9:	00 
f01057ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01057f1:	00 
f01057f2:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01057f9:	00 
f01057fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105801:	29 c2                	sub    %eax,%edx
f0105803:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105806:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f010580d:	89 04 24             	mov    %eax,(%esp)
f0105810:	e8 75 dc ff ff       	call   f010348a <user_mem_check>
f0105815:	85 c0                	test   %eax,%eax
f0105817:	0f 88 53 02 00 00    	js     f0105a70 <debuginfo_eip+0x2d3>
			return -1;

		stabs = usd->stabs;
f010581d:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0105823:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0105826:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f010582c:	a1 08 00 20 00       	mov    0x200008,%eax
f0105831:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105834:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010583a:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
f010583d:	e8 5a 10 00 00       	call   f010689c <cpunum>
f0105842:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105849:	00 
f010584a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105851:	00 
f0105852:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105855:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105859:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105860:	29 c2                	sub    %eax,%edx
f0105862:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105865:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f010586c:	89 04 24             	mov    %eax,(%esp)
f010586f:	e8 16 dc ff ff       	call   f010348a <user_mem_check>
f0105874:	85 c0                	test   %eax,%eax
f0105876:	0f 88 fb 01 00 00    	js     f0105a77 <debuginfo_eip+0x2da>
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
f010587c:	e8 1b 10 00 00       	call   f010689c <cpunum>
f0105881:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105888:	00 
f0105889:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105890:	00 
f0105891:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105894:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105898:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010589f:	29 c2                	sub    %eax,%edx
f01058a1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01058a4:	8b 04 85 28 90 29 f0 	mov    -0xfd66fd8(,%eax,4),%eax
f01058ab:	89 04 24             	mov    %eax,(%esp)
f01058ae:	e8 d7 db ff ff       	call   f010348a <user_mem_check>
f01058b3:	85 c0                	test   %eax,%eax
f01058b5:	79 1f                	jns    f01058d6 <debuginfo_eip+0x139>
f01058b7:	e9 c2 01 00 00       	jmp    f0105a7e <debuginfo_eip+0x2e1>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01058bc:	c7 45 c0 8b 27 12 f0 	movl   $0xf012278b,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01058c3:	c7 45 bc 51 6c 11 f0 	movl   $0xf0116c51,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01058ca:	bf 50 6c 11 f0       	mov    $0xf0116c50,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01058cf:	c7 45 c4 40 9e 10 f0 	movl   $0xf0109e40,-0x3c(%ebp)
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01058d6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01058d9:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f01058dc:	0f 83 a3 01 00 00    	jae    f0105a85 <debuginfo_eip+0x2e8>
f01058e2:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01058e6:	0f 85 a0 01 00 00    	jne    f0105a8c <debuginfo_eip+0x2ef>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01058ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01058f3:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01058f6:	c1 ff 02             	sar    $0x2,%edi
f01058f9:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f01058fc:	8d 04 87             	lea    (%edi,%eax,4),%eax
f01058ff:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0105902:	89 c2                	mov    %eax,%edx
f0105904:	c1 e2 08             	shl    $0x8,%edx
f0105907:	01 d0                	add    %edx,%eax
f0105909:	89 c2                	mov    %eax,%edx
f010590b:	c1 e2 10             	shl    $0x10,%edx
f010590e:	01 d0                	add    %edx,%eax
f0105910:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f0105914:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105917:	89 74 24 04          	mov    %esi,0x4(%esp)
f010591b:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105922:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105925:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105928:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010592b:	e8 74 fd ff ff       	call   f01056a4 <stab_binsearch>
	if (lfile == 0)
f0105930:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105933:	85 c0                	test   %eax,%eax
f0105935:	0f 84 58 01 00 00    	je     f0105a93 <debuginfo_eip+0x2f6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010593b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010593e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105941:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105944:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105948:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010594f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105952:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105955:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105958:	e8 47 fd ff ff       	call   f01056a4 <stab_binsearch>

	if (lfun <= rfun) {
f010595d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105960:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105963:	39 d0                	cmp    %edx,%eax
f0105965:	7f 32                	jg     f0105999 <debuginfo_eip+0x1fc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105967:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010596a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010596d:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f0105970:	8b 39                	mov    (%ecx),%edi
f0105972:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0105975:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105978:	2b 7d bc             	sub    -0x44(%ebp),%edi
f010597b:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f010597e:	73 09                	jae    f0105989 <debuginfo_eip+0x1ec>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105980:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105983:	03 7d bc             	add    -0x44(%ebp),%edi
f0105986:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105989:	8b 49 08             	mov    0x8(%ecx),%ecx
f010598c:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010598f:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105991:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105994:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105997:	eb 0f                	jmp    f01059a8 <debuginfo_eip+0x20b>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105999:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010599c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010599f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01059a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01059a8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01059af:	00 
f01059b0:	8b 43 08             	mov    0x8(%ebx),%eax
f01059b3:	89 04 24             	mov    %eax,(%esp)
f01059b6:	e8 9b 08 00 00       	call   f0106256 <strfind>
f01059bb:	2b 43 08             	sub    0x8(%ebx),%eax
f01059be:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
f01059c1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059c5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01059cc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01059cf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01059d2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01059d5:	e8 ca fc ff ff       	call   f01056a4 <stab_binsearch>
	if (lline > rline )
f01059da:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01059dd:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01059e0:	0f 8f b4 00 00 00    	jg     f0105a9a <debuginfo_eip+0x2fd>
		return -1;	
	info->eip_line = stabs[rline].n_desc;
f01059e6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01059e9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01059ec:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f01059f1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01059f4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01059f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01059fa:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01059fd:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0105a01:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105a04:	eb 04                	jmp    f0105a0a <debuginfo_eip+0x26d>
f0105a06:	48                   	dec    %eax
f0105a07:	83 ea 0c             	sub    $0xc,%edx
f0105a0a:	89 c7                	mov    %eax,%edi
f0105a0c:	39 c6                	cmp    %eax,%esi
f0105a0e:	7f 28                	jg     f0105a38 <debuginfo_eip+0x29b>
	       && stabs[lline].n_type != N_SOL
f0105a10:	8a 4a fc             	mov    -0x4(%edx),%cl
f0105a13:	80 f9 84             	cmp    $0x84,%cl
f0105a16:	0f 84 99 00 00 00    	je     f0105ab5 <debuginfo_eip+0x318>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105a1c:	80 f9 64             	cmp    $0x64,%cl
f0105a1f:	75 e5                	jne    f0105a06 <debuginfo_eip+0x269>
f0105a21:	83 3a 00             	cmpl   $0x0,(%edx)
f0105a24:	74 e0                	je     f0105a06 <debuginfo_eip+0x269>
f0105a26:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0105a29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105a2c:	e9 8a 00 00 00       	jmp    f0105abb <debuginfo_eip+0x31e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105a31:	03 45 bc             	add    -0x44(%ebp),%eax
f0105a34:	89 03                	mov    %eax,(%ebx)
f0105a36:	eb 03                	jmp    f0105a3b <debuginfo_eip+0x29e>
f0105a38:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105a3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105a3e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105a41:	39 f2                	cmp    %esi,%edx
f0105a43:	7d 5c                	jge    f0105aa1 <debuginfo_eip+0x304>
		for (lline = lfun + 1;
f0105a45:	42                   	inc    %edx
f0105a46:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105a49:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105a4b:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0105a4e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105a51:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105a55:	eb 03                	jmp    f0105a5a <debuginfo_eip+0x2bd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105a57:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105a5a:	39 f0                	cmp    %esi,%eax
f0105a5c:	7d 4a                	jge    f0105aa8 <debuginfo_eip+0x30b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105a5e:	8a 0a                	mov    (%edx),%cl
f0105a60:	40                   	inc    %eax
f0105a61:	83 c2 0c             	add    $0xc,%edx
f0105a64:	80 f9 a0             	cmp    $0xa0,%cl
f0105a67:	74 ee                	je     f0105a57 <debuginfo_eip+0x2ba>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105a69:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a6e:	eb 3d                	jmp    f0105aad <debuginfo_eip+0x310>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f0105a70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a75:	eb 36                	jmp    f0105aad <debuginfo_eip+0x310>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
			return -1;
f0105a77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a7c:	eb 2f                	jmp    f0105aad <debuginfo_eip+0x310>
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
f0105a7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a83:	eb 28                	jmp    f0105aad <debuginfo_eip+0x310>
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105a85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a8a:	eb 21                	jmp    f0105aad <debuginfo_eip+0x310>
f0105a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a91:	eb 1a                	jmp    f0105aad <debuginfo_eip+0x310>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a98:	eb 13                	jmp    f0105aad <debuginfo_eip+0x310>
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
	if (lline > rline )
		return -1;	
f0105a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105a9f:	eb 0c                	jmp    f0105aad <debuginfo_eip+0x310>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105aa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105aa6:	eb 05                	jmp    f0105aad <debuginfo_eip+0x310>
f0105aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105aad:	83 c4 5c             	add    $0x5c,%esp
f0105ab0:	5b                   	pop    %ebx
f0105ab1:	5e                   	pop    %esi
f0105ab2:	5f                   	pop    %edi
f0105ab3:	5d                   	pop    %ebp
f0105ab4:	c3                   	ret    
f0105ab5:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105ab8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105abb:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105abe:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105ac1:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0105ac4:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105ac7:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0105aca:	39 d0                	cmp    %edx,%eax
f0105acc:	0f 82 5f ff ff ff    	jb     f0105a31 <debuginfo_eip+0x294>
f0105ad2:	e9 64 ff ff ff       	jmp    f0105a3b <debuginfo_eip+0x29e>
	...

f0105ad8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105ad8:	55                   	push   %ebp
f0105ad9:	89 e5                	mov    %esp,%ebp
f0105adb:	57                   	push   %edi
f0105adc:	56                   	push   %esi
f0105add:	53                   	push   %ebx
f0105ade:	83 ec 3c             	sub    $0x3c,%esp
f0105ae1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ae4:	89 d7                	mov    %edx,%edi
f0105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ae9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105aec:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105aef:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105af2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105af5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105af8:	85 c0                	test   %eax,%eax
f0105afa:	75 08                	jne    f0105b04 <printnum+0x2c>
f0105afc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105aff:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105b02:	77 57                	ja     f0105b5b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105b04:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105b08:	4b                   	dec    %ebx
f0105b09:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105b0d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b10:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b14:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105b18:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105b1c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105b23:	00 
f0105b24:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b27:	89 04 24             	mov    %eax,(%esp)
f0105b2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b31:	e8 86 1d 00 00       	call   f01078bc <__udivdi3>
f0105b36:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b3a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105b3e:	89 04 24             	mov    %eax,(%esp)
f0105b41:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b45:	89 fa                	mov    %edi,%edx
f0105b47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b4a:	e8 89 ff ff ff       	call   f0105ad8 <printnum>
f0105b4f:	eb 0f                	jmp    f0105b60 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105b51:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b55:	89 34 24             	mov    %esi,(%esp)
f0105b58:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105b5b:	4b                   	dec    %ebx
f0105b5c:	85 db                	test   %ebx,%ebx
f0105b5e:	7f f1                	jg     f0105b51 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105b60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b64:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105b68:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105b76:	00 
f0105b77:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b7a:	89 04 24             	mov    %eax,(%esp)
f0105b7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b84:	e8 53 1e 00 00       	call   f01079dc <__umoddi3>
f0105b89:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105b8d:	0f be 80 fe 95 10 f0 	movsbl -0xfef6a02(%eax),%eax
f0105b94:	89 04 24             	mov    %eax,(%esp)
f0105b97:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105b9a:	83 c4 3c             	add    $0x3c,%esp
f0105b9d:	5b                   	pop    %ebx
f0105b9e:	5e                   	pop    %esi
f0105b9f:	5f                   	pop    %edi
f0105ba0:	5d                   	pop    %ebp
f0105ba1:	c3                   	ret    

f0105ba2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105ba2:	55                   	push   %ebp
f0105ba3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105ba5:	83 fa 01             	cmp    $0x1,%edx
f0105ba8:	7e 0e                	jle    f0105bb8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105baa:	8b 10                	mov    (%eax),%edx
f0105bac:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105baf:	89 08                	mov    %ecx,(%eax)
f0105bb1:	8b 02                	mov    (%edx),%eax
f0105bb3:	8b 52 04             	mov    0x4(%edx),%edx
f0105bb6:	eb 22                	jmp    f0105bda <getuint+0x38>
	else if (lflag)
f0105bb8:	85 d2                	test   %edx,%edx
f0105bba:	74 10                	je     f0105bcc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105bbc:	8b 10                	mov    (%eax),%edx
f0105bbe:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105bc1:	89 08                	mov    %ecx,(%eax)
f0105bc3:	8b 02                	mov    (%edx),%eax
f0105bc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105bca:	eb 0e                	jmp    f0105bda <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105bcc:	8b 10                	mov    (%eax),%edx
f0105bce:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105bd1:	89 08                	mov    %ecx,(%eax)
f0105bd3:	8b 02                	mov    (%edx),%eax
f0105bd5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105bda:	5d                   	pop    %ebp
f0105bdb:	c3                   	ret    

f0105bdc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105bdc:	55                   	push   %ebp
f0105bdd:	89 e5                	mov    %esp,%ebp
f0105bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105be2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105be5:	8b 10                	mov    (%eax),%edx
f0105be7:	3b 50 04             	cmp    0x4(%eax),%edx
f0105bea:	73 08                	jae    f0105bf4 <sprintputch+0x18>
		*b->buf++ = ch;
f0105bec:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105bef:	88 0a                	mov    %cl,(%edx)
f0105bf1:	42                   	inc    %edx
f0105bf2:	89 10                	mov    %edx,(%eax)
}
f0105bf4:	5d                   	pop    %ebp
f0105bf5:	c3                   	ret    

f0105bf6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105bf6:	55                   	push   %ebp
f0105bf7:	89 e5                	mov    %esp,%ebp
f0105bf9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105bfc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105bff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c03:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c06:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c11:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c14:	89 04 24             	mov    %eax,(%esp)
f0105c17:	e8 02 00 00 00       	call   f0105c1e <vprintfmt>
	va_end(ap);
}
f0105c1c:	c9                   	leave  
f0105c1d:	c3                   	ret    

f0105c1e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105c1e:	55                   	push   %ebp
f0105c1f:	89 e5                	mov    %esp,%ebp
f0105c21:	57                   	push   %edi
f0105c22:	56                   	push   %esi
f0105c23:	53                   	push   %ebx
f0105c24:	83 ec 4c             	sub    $0x4c,%esp
f0105c27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105c2a:	8b 75 10             	mov    0x10(%ebp),%esi
f0105c2d:	eb 12                	jmp    f0105c41 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105c2f:	85 c0                	test   %eax,%eax
f0105c31:	0f 84 6b 03 00 00    	je     f0105fa2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0105c37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c3b:	89 04 24             	mov    %eax,(%esp)
f0105c3e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105c41:	0f b6 06             	movzbl (%esi),%eax
f0105c44:	46                   	inc    %esi
f0105c45:	83 f8 25             	cmp    $0x25,%eax
f0105c48:	75 e5                	jne    f0105c2f <vprintfmt+0x11>
f0105c4a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105c4e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0105c55:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0105c5a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105c61:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c66:	eb 26                	jmp    f0105c8e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c68:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105c6b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105c6f:	eb 1d                	jmp    f0105c8e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c71:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105c74:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0105c78:	eb 14                	jmp    f0105c8e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c7a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105c7d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105c84:	eb 08                	jmp    f0105c8e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105c86:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0105c89:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105c8e:	0f b6 06             	movzbl (%esi),%eax
f0105c91:	8d 56 01             	lea    0x1(%esi),%edx
f0105c94:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105c97:	8a 16                	mov    (%esi),%dl
f0105c99:	83 ea 23             	sub    $0x23,%edx
f0105c9c:	80 fa 55             	cmp    $0x55,%dl
f0105c9f:	0f 87 e1 02 00 00    	ja     f0105f86 <vprintfmt+0x368>
f0105ca5:	0f b6 d2             	movzbl %dl,%edx
f0105ca8:	ff 24 95 40 97 10 f0 	jmp    *-0xfef68c0(,%edx,4)
f0105caf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105cb2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105cb7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105cba:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105cbe:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105cc1:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105cc4:	83 fa 09             	cmp    $0x9,%edx
f0105cc7:	77 2a                	ja     f0105cf3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105cc9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105cca:	eb eb                	jmp    f0105cb7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105ccc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ccf:	8d 50 04             	lea    0x4(%eax),%edx
f0105cd2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105cd5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cd7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105cda:	eb 17                	jmp    f0105cf3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105cdc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105ce0:	78 98                	js     f0105c7a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ce2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105ce5:	eb a7                	jmp    f0105c8e <vprintfmt+0x70>
f0105ce7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105cea:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105cf1:	eb 9b                	jmp    f0105c8e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105cf3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105cf7:	79 95                	jns    f0105c8e <vprintfmt+0x70>
f0105cf9:	eb 8b                	jmp    f0105c86 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105cfb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105cfc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105cff:	eb 8d                	jmp    f0105c8e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105d01:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d04:	8d 50 04             	lea    0x4(%eax),%edx
f0105d07:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d0e:	8b 00                	mov    (%eax),%eax
f0105d10:	89 04 24             	mov    %eax,(%esp)
f0105d13:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d16:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105d19:	e9 23 ff ff ff       	jmp    f0105c41 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105d1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d21:	8d 50 04             	lea    0x4(%eax),%edx
f0105d24:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d27:	8b 00                	mov    (%eax),%eax
f0105d29:	85 c0                	test   %eax,%eax
f0105d2b:	79 02                	jns    f0105d2f <vprintfmt+0x111>
f0105d2d:	f7 d8                	neg    %eax
f0105d2f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105d31:	83 f8 11             	cmp    $0x11,%eax
f0105d34:	7f 0b                	jg     f0105d41 <vprintfmt+0x123>
f0105d36:	8b 04 85 a0 98 10 f0 	mov    -0xfef6760(,%eax,4),%eax
f0105d3d:	85 c0                	test   %eax,%eax
f0105d3f:	75 23                	jne    f0105d64 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0105d41:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d45:	c7 44 24 08 16 96 10 	movl   $0xf0109616,0x8(%esp)
f0105d4c:	f0 
f0105d4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d51:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d54:	89 04 24             	mov    %eax,(%esp)
f0105d57:	e8 9a fe ff ff       	call   f0105bf6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d5c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105d5f:	e9 dd fe ff ff       	jmp    f0105c41 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0105d64:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d68:	c7 44 24 08 75 8a 10 	movl   $0xf0108a75,0x8(%esp)
f0105d6f:	f0 
f0105d70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105d74:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d77:	89 14 24             	mov    %edx,(%esp)
f0105d7a:	e8 77 fe ff ff       	call   f0105bf6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105d7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105d82:	e9 ba fe ff ff       	jmp    f0105c41 <vprintfmt+0x23>
f0105d87:	89 f9                	mov    %edi,%ecx
f0105d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105d8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105d92:	8d 50 04             	lea    0x4(%eax),%edx
f0105d95:	89 55 14             	mov    %edx,0x14(%ebp)
f0105d98:	8b 30                	mov    (%eax),%esi
f0105d9a:	85 f6                	test   %esi,%esi
f0105d9c:	75 05                	jne    f0105da3 <vprintfmt+0x185>
				p = "(null)";
f0105d9e:	be 0f 96 10 f0       	mov    $0xf010960f,%esi
			if (width > 0 && padc != '-')
f0105da3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105da7:	0f 8e 84 00 00 00    	jle    f0105e31 <vprintfmt+0x213>
f0105dad:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105db1:	74 7e                	je     f0105e31 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105db3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105db7:	89 34 24             	mov    %esi,(%esp)
f0105dba:	e8 63 03 00 00       	call   f0106122 <strnlen>
f0105dbf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105dc2:	29 c2                	sub    %eax,%edx
f0105dc4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105dc7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105dcb:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105dce:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105dd1:	89 de                	mov    %ebx,%esi
f0105dd3:	89 d3                	mov    %edx,%ebx
f0105dd5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105dd7:	eb 0b                	jmp    f0105de4 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105dd9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105ddd:	89 3c 24             	mov    %edi,(%esp)
f0105de0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105de3:	4b                   	dec    %ebx
f0105de4:	85 db                	test   %ebx,%ebx
f0105de6:	7f f1                	jg     f0105dd9 <vprintfmt+0x1bb>
f0105de8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105deb:	89 f3                	mov    %esi,%ebx
f0105ded:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105df3:	85 c0                	test   %eax,%eax
f0105df5:	79 05                	jns    f0105dfc <vprintfmt+0x1de>
f0105df7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dfc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105dff:	29 c2                	sub    %eax,%edx
f0105e01:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105e04:	eb 2b                	jmp    f0105e31 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105e06:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105e0a:	74 18                	je     f0105e24 <vprintfmt+0x206>
f0105e0c:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105e0f:	83 fa 5e             	cmp    $0x5e,%edx
f0105e12:	76 10                	jbe    f0105e24 <vprintfmt+0x206>
					putch('?', putdat);
f0105e14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e18:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105e1f:	ff 55 08             	call   *0x8(%ebp)
f0105e22:	eb 0a                	jmp    f0105e2e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105e24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105e28:	89 04 24             	mov    %eax,(%esp)
f0105e2b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105e2e:	ff 4d e4             	decl   -0x1c(%ebp)
f0105e31:	0f be 06             	movsbl (%esi),%eax
f0105e34:	46                   	inc    %esi
f0105e35:	85 c0                	test   %eax,%eax
f0105e37:	74 21                	je     f0105e5a <vprintfmt+0x23c>
f0105e39:	85 ff                	test   %edi,%edi
f0105e3b:	78 c9                	js     f0105e06 <vprintfmt+0x1e8>
f0105e3d:	4f                   	dec    %edi
f0105e3e:	79 c6                	jns    f0105e06 <vprintfmt+0x1e8>
f0105e40:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e43:	89 de                	mov    %ebx,%esi
f0105e45:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105e48:	eb 18                	jmp    f0105e62 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105e4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e4e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105e55:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105e57:	4b                   	dec    %ebx
f0105e58:	eb 08                	jmp    f0105e62 <vprintfmt+0x244>
f0105e5a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e5d:	89 de                	mov    %ebx,%esi
f0105e5f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105e62:	85 db                	test   %ebx,%ebx
f0105e64:	7f e4                	jg     f0105e4a <vprintfmt+0x22c>
f0105e66:	89 7d 08             	mov    %edi,0x8(%ebp)
f0105e69:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e6b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105e6e:	e9 ce fd ff ff       	jmp    f0105c41 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105e73:	83 f9 01             	cmp    $0x1,%ecx
f0105e76:	7e 10                	jle    f0105e88 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0105e78:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e7b:	8d 50 08             	lea    0x8(%eax),%edx
f0105e7e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e81:	8b 30                	mov    (%eax),%esi
f0105e83:	8b 78 04             	mov    0x4(%eax),%edi
f0105e86:	eb 26                	jmp    f0105eae <vprintfmt+0x290>
	else if (lflag)
f0105e88:	85 c9                	test   %ecx,%ecx
f0105e8a:	74 12                	je     f0105e9e <vprintfmt+0x280>
		return va_arg(*ap, long);
f0105e8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0105e8f:	8d 50 04             	lea    0x4(%eax),%edx
f0105e92:	89 55 14             	mov    %edx,0x14(%ebp)
f0105e95:	8b 30                	mov    (%eax),%esi
f0105e97:	89 f7                	mov    %esi,%edi
f0105e99:	c1 ff 1f             	sar    $0x1f,%edi
f0105e9c:	eb 10                	jmp    f0105eae <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0105e9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ea1:	8d 50 04             	lea    0x4(%eax),%edx
f0105ea4:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ea7:	8b 30                	mov    (%eax),%esi
f0105ea9:	89 f7                	mov    %esi,%edi
f0105eab:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105eae:	85 ff                	test   %edi,%edi
f0105eb0:	78 0a                	js     f0105ebc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105eb2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105eb7:	e9 8c 00 00 00       	jmp    f0105f48 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105ebc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105ec0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105ec7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105eca:	f7 de                	neg    %esi
f0105ecc:	83 d7 00             	adc    $0x0,%edi
f0105ecf:	f7 df                	neg    %edi
			}
			base = 10;
f0105ed1:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ed6:	eb 70                	jmp    f0105f48 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105ed8:	89 ca                	mov    %ecx,%edx
f0105eda:	8d 45 14             	lea    0x14(%ebp),%eax
f0105edd:	e8 c0 fc ff ff       	call   f0105ba2 <getuint>
f0105ee2:	89 c6                	mov    %eax,%esi
f0105ee4:	89 d7                	mov    %edx,%edi
			base = 10;
f0105ee6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105eeb:	eb 5b                	jmp    f0105f48 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
f0105eed:	89 ca                	mov    %ecx,%edx
f0105eef:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ef2:	e8 ab fc ff ff       	call   f0105ba2 <getuint>
f0105ef7:	89 c6                	mov    %eax,%esi
f0105ef9:	89 d7                	mov    %edx,%edi
			base = 8;
f0105efb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0105f00:	eb 46                	jmp    f0105f48 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
f0105f02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f06:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105f0d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105f10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f14:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105f1b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105f1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f21:	8d 50 04             	lea    0x4(%eax),%edx
f0105f24:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105f27:	8b 30                	mov    (%eax),%esi
f0105f29:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105f2e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105f33:	eb 13                	jmp    f0105f48 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105f35:	89 ca                	mov    %ecx,%edx
f0105f37:	8d 45 14             	lea    0x14(%ebp),%eax
f0105f3a:	e8 63 fc ff ff       	call   f0105ba2 <getuint>
f0105f3f:	89 c6                	mov    %eax,%esi
f0105f41:	89 d7                	mov    %edx,%edi
			base = 16;
f0105f43:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105f48:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105f4c:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105f50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105f53:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f57:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105f5b:	89 34 24             	mov    %esi,(%esp)
f0105f5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f62:	89 da                	mov    %ebx,%edx
f0105f64:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f67:	e8 6c fb ff ff       	call   f0105ad8 <printnum>
			break;
f0105f6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105f6f:	e9 cd fc ff ff       	jmp    f0105c41 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105f74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f78:	89 04 24             	mov    %eax,(%esp)
f0105f7b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f7e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105f81:	e9 bb fc ff ff       	jmp    f0105c41 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105f86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105f8a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105f91:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105f94:	eb 01                	jmp    f0105f97 <vprintfmt+0x379>
f0105f96:	4e                   	dec    %esi
f0105f97:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105f9b:	75 f9                	jne    f0105f96 <vprintfmt+0x378>
f0105f9d:	e9 9f fc ff ff       	jmp    f0105c41 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105fa2:	83 c4 4c             	add    $0x4c,%esp
f0105fa5:	5b                   	pop    %ebx
f0105fa6:	5e                   	pop    %esi
f0105fa7:	5f                   	pop    %edi
f0105fa8:	5d                   	pop    %ebp
f0105fa9:	c3                   	ret    

f0105faa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105faa:	55                   	push   %ebp
f0105fab:	89 e5                	mov    %esp,%ebp
f0105fad:	83 ec 28             	sub    $0x28,%esp
f0105fb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fb3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105fb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105fb9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105fbd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105fc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105fc7:	85 c0                	test   %eax,%eax
f0105fc9:	74 30                	je     f0105ffb <vsnprintf+0x51>
f0105fcb:	85 d2                	test   %edx,%edx
f0105fcd:	7e 33                	jle    f0106002 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105fcf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fd6:	8b 45 10             	mov    0x10(%ebp),%eax
f0105fd9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105fdd:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105fe4:	c7 04 24 dc 5b 10 f0 	movl   $0xf0105bdc,(%esp)
f0105feb:	e8 2e fc ff ff       	call   f0105c1e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105ff3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105ff9:	eb 0c                	jmp    f0106007 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105ffb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106000:	eb 05                	jmp    f0106007 <vsnprintf+0x5d>
f0106002:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0106007:	c9                   	leave  
f0106008:	c3                   	ret    

f0106009 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0106009:	55                   	push   %ebp
f010600a:	89 e5                	mov    %esp,%ebp
f010600c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010600f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0106012:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106016:	8b 45 10             	mov    0x10(%ebp),%eax
f0106019:	89 44 24 08          	mov    %eax,0x8(%esp)
f010601d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106020:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106024:	8b 45 08             	mov    0x8(%ebp),%eax
f0106027:	89 04 24             	mov    %eax,(%esp)
f010602a:	e8 7b ff ff ff       	call   f0105faa <vsnprintf>
	va_end(ap);

	return rc;
}
f010602f:	c9                   	leave  
f0106030:	c3                   	ret    
f0106031:	00 00                	add    %al,(%eax)
	...

f0106034 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106034:	55                   	push   %ebp
f0106035:	89 e5                	mov    %esp,%ebp
f0106037:	57                   	push   %edi
f0106038:	56                   	push   %esi
f0106039:	53                   	push   %ebx
f010603a:	83 ec 1c             	sub    $0x1c,%esp
f010603d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0106040:	85 c0                	test   %eax,%eax
f0106042:	74 10                	je     f0106054 <readline+0x20>
		cprintf("%s", prompt);
f0106044:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106048:	c7 04 24 75 8a 10 f0 	movl   $0xf0108a75,(%esp)
f010604f:	e8 da de ff ff       	call   f0103f2e <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0106054:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010605b:	e8 65 a7 ff ff       	call   f01007c5 <iscons>
f0106060:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0106062:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0106067:	e8 48 a7 ff ff       	call   f01007b4 <getchar>
f010606c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010606e:	85 c0                	test   %eax,%eax
f0106070:	79 20                	jns    f0106092 <readline+0x5e>
			if (c != -E_EOF)
f0106072:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0106075:	0f 84 82 00 00 00    	je     f01060fd <readline+0xc9>
				cprintf("read error: %e\n", c);
f010607b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010607f:	c7 04 24 07 99 10 f0 	movl   $0xf0109907,(%esp)
f0106086:	e8 a3 de ff ff       	call   f0103f2e <cprintf>
			return NULL;
f010608b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106090:	eb 70                	jmp    f0106102 <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106092:	83 f8 08             	cmp    $0x8,%eax
f0106095:	74 05                	je     f010609c <readline+0x68>
f0106097:	83 f8 7f             	cmp    $0x7f,%eax
f010609a:	75 17                	jne    f01060b3 <readline+0x7f>
f010609c:	85 f6                	test   %esi,%esi
f010609e:	7e 13                	jle    f01060b3 <readline+0x7f>
			if (echoing)
f01060a0:	85 ff                	test   %edi,%edi
f01060a2:	74 0c                	je     f01060b0 <readline+0x7c>
				cputchar('\b');
f01060a4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01060ab:	e8 f4 a6 ff ff       	call   f01007a4 <cputchar>
			i--;
f01060b0:	4e                   	dec    %esi
f01060b1:	eb b4                	jmp    f0106067 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01060b3:	83 fb 1f             	cmp    $0x1f,%ebx
f01060b6:	7e 1d                	jle    f01060d5 <readline+0xa1>
f01060b8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01060be:	7f 15                	jg     f01060d5 <readline+0xa1>
			if (echoing)
f01060c0:	85 ff                	test   %edi,%edi
f01060c2:	74 08                	je     f01060cc <readline+0x98>
				cputchar(c);
f01060c4:	89 1c 24             	mov    %ebx,(%esp)
f01060c7:	e8 d8 a6 ff ff       	call   f01007a4 <cputchar>
			buf[i++] = c;
f01060cc:	88 9e 80 8a 29 f0    	mov    %bl,-0xfd67580(%esi)
f01060d2:	46                   	inc    %esi
f01060d3:	eb 92                	jmp    f0106067 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01060d5:	83 fb 0a             	cmp    $0xa,%ebx
f01060d8:	74 05                	je     f01060df <readline+0xab>
f01060da:	83 fb 0d             	cmp    $0xd,%ebx
f01060dd:	75 88                	jne    f0106067 <readline+0x33>
			if (echoing)
f01060df:	85 ff                	test   %edi,%edi
f01060e1:	74 0c                	je     f01060ef <readline+0xbb>
				cputchar('\n');
f01060e3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01060ea:	e8 b5 a6 ff ff       	call   f01007a4 <cputchar>
			buf[i] = 0;
f01060ef:	c6 86 80 8a 29 f0 00 	movb   $0x0,-0xfd67580(%esi)
			return buf;
f01060f6:	b8 80 8a 29 f0       	mov    $0xf0298a80,%eax
f01060fb:	eb 05                	jmp    f0106102 <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01060fd:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0106102:	83 c4 1c             	add    $0x1c,%esp
f0106105:	5b                   	pop    %ebx
f0106106:	5e                   	pop    %esi
f0106107:	5f                   	pop    %edi
f0106108:	5d                   	pop    %ebp
f0106109:	c3                   	ret    
	...

f010610c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010610c:	55                   	push   %ebp
f010610d:	89 e5                	mov    %esp,%ebp
f010610f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106112:	b8 00 00 00 00       	mov    $0x0,%eax
f0106117:	eb 01                	jmp    f010611a <strlen+0xe>
		n++;
f0106119:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010611a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010611e:	75 f9                	jne    f0106119 <strlen+0xd>
		n++;
	return n;
}
f0106120:	5d                   	pop    %ebp
f0106121:	c3                   	ret    

f0106122 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106122:	55                   	push   %ebp
f0106123:	89 e5                	mov    %esp,%ebp
f0106125:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0106128:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010612b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106130:	eb 01                	jmp    f0106133 <strnlen+0x11>
		n++;
f0106132:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106133:	39 d0                	cmp    %edx,%eax
f0106135:	74 06                	je     f010613d <strnlen+0x1b>
f0106137:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010613b:	75 f5                	jne    f0106132 <strnlen+0x10>
		n++;
	return n;
}
f010613d:	5d                   	pop    %ebp
f010613e:	c3                   	ret    

f010613f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010613f:	55                   	push   %ebp
f0106140:	89 e5                	mov    %esp,%ebp
f0106142:	53                   	push   %ebx
f0106143:	8b 45 08             	mov    0x8(%ebp),%eax
f0106146:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106149:	ba 00 00 00 00       	mov    $0x0,%edx
f010614e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0106151:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0106154:	42                   	inc    %edx
f0106155:	84 c9                	test   %cl,%cl
f0106157:	75 f5                	jne    f010614e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106159:	5b                   	pop    %ebx
f010615a:	5d                   	pop    %ebp
f010615b:	c3                   	ret    

f010615c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010615c:	55                   	push   %ebp
f010615d:	89 e5                	mov    %esp,%ebp
f010615f:	53                   	push   %ebx
f0106160:	83 ec 08             	sub    $0x8,%esp
f0106163:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106166:	89 1c 24             	mov    %ebx,(%esp)
f0106169:	e8 9e ff ff ff       	call   f010610c <strlen>
	strcpy(dst + len, src);
f010616e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106171:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106175:	01 d8                	add    %ebx,%eax
f0106177:	89 04 24             	mov    %eax,(%esp)
f010617a:	e8 c0 ff ff ff       	call   f010613f <strcpy>
	return dst;
}
f010617f:	89 d8                	mov    %ebx,%eax
f0106181:	83 c4 08             	add    $0x8,%esp
f0106184:	5b                   	pop    %ebx
f0106185:	5d                   	pop    %ebp
f0106186:	c3                   	ret    

f0106187 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106187:	55                   	push   %ebp
f0106188:	89 e5                	mov    %esp,%ebp
f010618a:	56                   	push   %esi
f010618b:	53                   	push   %ebx
f010618c:	8b 45 08             	mov    0x8(%ebp),%eax
f010618f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106192:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106195:	b9 00 00 00 00       	mov    $0x0,%ecx
f010619a:	eb 0c                	jmp    f01061a8 <strncpy+0x21>
		*dst++ = *src;
f010619c:	8a 1a                	mov    (%edx),%bl
f010619e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01061a1:	80 3a 01             	cmpb   $0x1,(%edx)
f01061a4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01061a7:	41                   	inc    %ecx
f01061a8:	39 f1                	cmp    %esi,%ecx
f01061aa:	75 f0                	jne    f010619c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01061ac:	5b                   	pop    %ebx
f01061ad:	5e                   	pop    %esi
f01061ae:	5d                   	pop    %ebp
f01061af:	c3                   	ret    

f01061b0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01061b0:	55                   	push   %ebp
f01061b1:	89 e5                	mov    %esp,%ebp
f01061b3:	56                   	push   %esi
f01061b4:	53                   	push   %ebx
f01061b5:	8b 75 08             	mov    0x8(%ebp),%esi
f01061b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01061bb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01061be:	85 d2                	test   %edx,%edx
f01061c0:	75 0a                	jne    f01061cc <strlcpy+0x1c>
f01061c2:	89 f0                	mov    %esi,%eax
f01061c4:	eb 1a                	jmp    f01061e0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01061c6:	88 18                	mov    %bl,(%eax)
f01061c8:	40                   	inc    %eax
f01061c9:	41                   	inc    %ecx
f01061ca:	eb 02                	jmp    f01061ce <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01061cc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f01061ce:	4a                   	dec    %edx
f01061cf:	74 0a                	je     f01061db <strlcpy+0x2b>
f01061d1:	8a 19                	mov    (%ecx),%bl
f01061d3:	84 db                	test   %bl,%bl
f01061d5:	75 ef                	jne    f01061c6 <strlcpy+0x16>
f01061d7:	89 c2                	mov    %eax,%edx
f01061d9:	eb 02                	jmp    f01061dd <strlcpy+0x2d>
f01061db:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01061dd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01061e0:	29 f0                	sub    %esi,%eax
}
f01061e2:	5b                   	pop    %ebx
f01061e3:	5e                   	pop    %esi
f01061e4:	5d                   	pop    %ebp
f01061e5:	c3                   	ret    

f01061e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01061e6:	55                   	push   %ebp
f01061e7:	89 e5                	mov    %esp,%ebp
f01061e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01061ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01061ef:	eb 02                	jmp    f01061f3 <strcmp+0xd>
		p++, q++;
f01061f1:	41                   	inc    %ecx
f01061f2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01061f3:	8a 01                	mov    (%ecx),%al
f01061f5:	84 c0                	test   %al,%al
f01061f7:	74 04                	je     f01061fd <strcmp+0x17>
f01061f9:	3a 02                	cmp    (%edx),%al
f01061fb:	74 f4                	je     f01061f1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01061fd:	0f b6 c0             	movzbl %al,%eax
f0106200:	0f b6 12             	movzbl (%edx),%edx
f0106203:	29 d0                	sub    %edx,%eax
}
f0106205:	5d                   	pop    %ebp
f0106206:	c3                   	ret    

f0106207 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106207:	55                   	push   %ebp
f0106208:	89 e5                	mov    %esp,%ebp
f010620a:	53                   	push   %ebx
f010620b:	8b 45 08             	mov    0x8(%ebp),%eax
f010620e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106211:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0106214:	eb 03                	jmp    f0106219 <strncmp+0x12>
		n--, p++, q++;
f0106216:	4a                   	dec    %edx
f0106217:	40                   	inc    %eax
f0106218:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106219:	85 d2                	test   %edx,%edx
f010621b:	74 14                	je     f0106231 <strncmp+0x2a>
f010621d:	8a 18                	mov    (%eax),%bl
f010621f:	84 db                	test   %bl,%bl
f0106221:	74 04                	je     f0106227 <strncmp+0x20>
f0106223:	3a 19                	cmp    (%ecx),%bl
f0106225:	74 ef                	je     f0106216 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106227:	0f b6 00             	movzbl (%eax),%eax
f010622a:	0f b6 11             	movzbl (%ecx),%edx
f010622d:	29 d0                	sub    %edx,%eax
f010622f:	eb 05                	jmp    f0106236 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0106231:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106236:	5b                   	pop    %ebx
f0106237:	5d                   	pop    %ebp
f0106238:	c3                   	ret    

f0106239 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106239:	55                   	push   %ebp
f010623a:	89 e5                	mov    %esp,%ebp
f010623c:	8b 45 08             	mov    0x8(%ebp),%eax
f010623f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0106242:	eb 05                	jmp    f0106249 <strchr+0x10>
		if (*s == c)
f0106244:	38 ca                	cmp    %cl,%dl
f0106246:	74 0c                	je     f0106254 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106248:	40                   	inc    %eax
f0106249:	8a 10                	mov    (%eax),%dl
f010624b:	84 d2                	test   %dl,%dl
f010624d:	75 f5                	jne    f0106244 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f010624f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106254:	5d                   	pop    %ebp
f0106255:	c3                   	ret    

f0106256 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0106256:	55                   	push   %ebp
f0106257:	89 e5                	mov    %esp,%ebp
f0106259:	8b 45 08             	mov    0x8(%ebp),%eax
f010625c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010625f:	eb 05                	jmp    f0106266 <strfind+0x10>
		if (*s == c)
f0106261:	38 ca                	cmp    %cl,%dl
f0106263:	74 07                	je     f010626c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0106265:	40                   	inc    %eax
f0106266:	8a 10                	mov    (%eax),%dl
f0106268:	84 d2                	test   %dl,%dl
f010626a:	75 f5                	jne    f0106261 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f010626c:	5d                   	pop    %ebp
f010626d:	c3                   	ret    

f010626e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010626e:	55                   	push   %ebp
f010626f:	89 e5                	mov    %esp,%ebp
f0106271:	57                   	push   %edi
f0106272:	56                   	push   %esi
f0106273:	53                   	push   %ebx
f0106274:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106277:	8b 45 0c             	mov    0xc(%ebp),%eax
f010627a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010627d:	85 c9                	test   %ecx,%ecx
f010627f:	74 30                	je     f01062b1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106281:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106287:	75 25                	jne    f01062ae <memset+0x40>
f0106289:	f6 c1 03             	test   $0x3,%cl
f010628c:	75 20                	jne    f01062ae <memset+0x40>
		c &= 0xFF;
f010628e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106291:	89 d3                	mov    %edx,%ebx
f0106293:	c1 e3 08             	shl    $0x8,%ebx
f0106296:	89 d6                	mov    %edx,%esi
f0106298:	c1 e6 18             	shl    $0x18,%esi
f010629b:	89 d0                	mov    %edx,%eax
f010629d:	c1 e0 10             	shl    $0x10,%eax
f01062a0:	09 f0                	or     %esi,%eax
f01062a2:	09 d0                	or     %edx,%eax
f01062a4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01062a6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01062a9:	fc                   	cld    
f01062aa:	f3 ab                	rep stos %eax,%es:(%edi)
f01062ac:	eb 03                	jmp    f01062b1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01062ae:	fc                   	cld    
f01062af:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01062b1:	89 f8                	mov    %edi,%eax
f01062b3:	5b                   	pop    %ebx
f01062b4:	5e                   	pop    %esi
f01062b5:	5f                   	pop    %edi
f01062b6:	5d                   	pop    %ebp
f01062b7:	c3                   	ret    

f01062b8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01062b8:	55                   	push   %ebp
f01062b9:	89 e5                	mov    %esp,%ebp
f01062bb:	57                   	push   %edi
f01062bc:	56                   	push   %esi
f01062bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01062c0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01062c6:	39 c6                	cmp    %eax,%esi
f01062c8:	73 34                	jae    f01062fe <memmove+0x46>
f01062ca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01062cd:	39 d0                	cmp    %edx,%eax
f01062cf:	73 2d                	jae    f01062fe <memmove+0x46>
		s += n;
		d += n;
f01062d1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062d4:	f6 c2 03             	test   $0x3,%dl
f01062d7:	75 1b                	jne    f01062f4 <memmove+0x3c>
f01062d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01062df:	75 13                	jne    f01062f4 <memmove+0x3c>
f01062e1:	f6 c1 03             	test   $0x3,%cl
f01062e4:	75 0e                	jne    f01062f4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01062e6:	83 ef 04             	sub    $0x4,%edi
f01062e9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01062ec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01062ef:	fd                   	std    
f01062f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01062f2:	eb 07                	jmp    f01062fb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01062f4:	4f                   	dec    %edi
f01062f5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01062f8:	fd                   	std    
f01062f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01062fb:	fc                   	cld    
f01062fc:	eb 20                	jmp    f010631e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01062fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106304:	75 13                	jne    f0106319 <memmove+0x61>
f0106306:	a8 03                	test   $0x3,%al
f0106308:	75 0f                	jne    f0106319 <memmove+0x61>
f010630a:	f6 c1 03             	test   $0x3,%cl
f010630d:	75 0a                	jne    f0106319 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010630f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106312:	89 c7                	mov    %eax,%edi
f0106314:	fc                   	cld    
f0106315:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106317:	eb 05                	jmp    f010631e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106319:	89 c7                	mov    %eax,%edi
f010631b:	fc                   	cld    
f010631c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010631e:	5e                   	pop    %esi
f010631f:	5f                   	pop    %edi
f0106320:	5d                   	pop    %ebp
f0106321:	c3                   	ret    

f0106322 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106322:	55                   	push   %ebp
f0106323:	89 e5                	mov    %esp,%ebp
f0106325:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106328:	8b 45 10             	mov    0x10(%ebp),%eax
f010632b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010632f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106332:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106336:	8b 45 08             	mov    0x8(%ebp),%eax
f0106339:	89 04 24             	mov    %eax,(%esp)
f010633c:	e8 77 ff ff ff       	call   f01062b8 <memmove>
}
f0106341:	c9                   	leave  
f0106342:	c3                   	ret    

f0106343 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106343:	55                   	push   %ebp
f0106344:	89 e5                	mov    %esp,%ebp
f0106346:	57                   	push   %edi
f0106347:	56                   	push   %esi
f0106348:	53                   	push   %ebx
f0106349:	8b 7d 08             	mov    0x8(%ebp),%edi
f010634c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010634f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106352:	ba 00 00 00 00       	mov    $0x0,%edx
f0106357:	eb 16                	jmp    f010636f <memcmp+0x2c>
		if (*s1 != *s2)
f0106359:	8a 04 17             	mov    (%edi,%edx,1),%al
f010635c:	42                   	inc    %edx
f010635d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0106361:	38 c8                	cmp    %cl,%al
f0106363:	74 0a                	je     f010636f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0106365:	0f b6 c0             	movzbl %al,%eax
f0106368:	0f b6 c9             	movzbl %cl,%ecx
f010636b:	29 c8                	sub    %ecx,%eax
f010636d:	eb 09                	jmp    f0106378 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010636f:	39 da                	cmp    %ebx,%edx
f0106371:	75 e6                	jne    f0106359 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0106373:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106378:	5b                   	pop    %ebx
f0106379:	5e                   	pop    %esi
f010637a:	5f                   	pop    %edi
f010637b:	5d                   	pop    %ebp
f010637c:	c3                   	ret    

f010637d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010637d:	55                   	push   %ebp
f010637e:	89 e5                	mov    %esp,%ebp
f0106380:	8b 45 08             	mov    0x8(%ebp),%eax
f0106383:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106386:	89 c2                	mov    %eax,%edx
f0106388:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010638b:	eb 05                	jmp    f0106392 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010638d:	38 08                	cmp    %cl,(%eax)
f010638f:	74 05                	je     f0106396 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106391:	40                   	inc    %eax
f0106392:	39 d0                	cmp    %edx,%eax
f0106394:	72 f7                	jb     f010638d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106396:	5d                   	pop    %ebp
f0106397:	c3                   	ret    

f0106398 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106398:	55                   	push   %ebp
f0106399:	89 e5                	mov    %esp,%ebp
f010639b:	57                   	push   %edi
f010639c:	56                   	push   %esi
f010639d:	53                   	push   %ebx
f010639e:	8b 55 08             	mov    0x8(%ebp),%edx
f01063a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063a4:	eb 01                	jmp    f01063a7 <strtol+0xf>
		s++;
f01063a6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01063a7:	8a 02                	mov    (%edx),%al
f01063a9:	3c 20                	cmp    $0x20,%al
f01063ab:	74 f9                	je     f01063a6 <strtol+0xe>
f01063ad:	3c 09                	cmp    $0x9,%al
f01063af:	74 f5                	je     f01063a6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01063b1:	3c 2b                	cmp    $0x2b,%al
f01063b3:	75 08                	jne    f01063bd <strtol+0x25>
		s++;
f01063b5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01063b6:	bf 00 00 00 00       	mov    $0x0,%edi
f01063bb:	eb 13                	jmp    f01063d0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01063bd:	3c 2d                	cmp    $0x2d,%al
f01063bf:	75 0a                	jne    f01063cb <strtol+0x33>
		s++, neg = 1;
f01063c1:	8d 52 01             	lea    0x1(%edx),%edx
f01063c4:	bf 01 00 00 00       	mov    $0x1,%edi
f01063c9:	eb 05                	jmp    f01063d0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01063cb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01063d0:	85 db                	test   %ebx,%ebx
f01063d2:	74 05                	je     f01063d9 <strtol+0x41>
f01063d4:	83 fb 10             	cmp    $0x10,%ebx
f01063d7:	75 28                	jne    f0106401 <strtol+0x69>
f01063d9:	8a 02                	mov    (%edx),%al
f01063db:	3c 30                	cmp    $0x30,%al
f01063dd:	75 10                	jne    f01063ef <strtol+0x57>
f01063df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01063e3:	75 0a                	jne    f01063ef <strtol+0x57>
		s += 2, base = 16;
f01063e5:	83 c2 02             	add    $0x2,%edx
f01063e8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01063ed:	eb 12                	jmp    f0106401 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01063ef:	85 db                	test   %ebx,%ebx
f01063f1:	75 0e                	jne    f0106401 <strtol+0x69>
f01063f3:	3c 30                	cmp    $0x30,%al
f01063f5:	75 05                	jne    f01063fc <strtol+0x64>
		s++, base = 8;
f01063f7:	42                   	inc    %edx
f01063f8:	b3 08                	mov    $0x8,%bl
f01063fa:	eb 05                	jmp    f0106401 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01063fc:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106401:	b8 00 00 00 00       	mov    $0x0,%eax
f0106406:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106408:	8a 0a                	mov    (%edx),%cl
f010640a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010640d:	80 fb 09             	cmp    $0x9,%bl
f0106410:	77 08                	ja     f010641a <strtol+0x82>
			dig = *s - '0';
f0106412:	0f be c9             	movsbl %cl,%ecx
f0106415:	83 e9 30             	sub    $0x30,%ecx
f0106418:	eb 1e                	jmp    f0106438 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010641a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010641d:	80 fb 19             	cmp    $0x19,%bl
f0106420:	77 08                	ja     f010642a <strtol+0x92>
			dig = *s - 'a' + 10;
f0106422:	0f be c9             	movsbl %cl,%ecx
f0106425:	83 e9 57             	sub    $0x57,%ecx
f0106428:	eb 0e                	jmp    f0106438 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010642a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010642d:	80 fb 19             	cmp    $0x19,%bl
f0106430:	77 12                	ja     f0106444 <strtol+0xac>
			dig = *s - 'A' + 10;
f0106432:	0f be c9             	movsbl %cl,%ecx
f0106435:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106438:	39 f1                	cmp    %esi,%ecx
f010643a:	7d 0c                	jge    f0106448 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f010643c:	42                   	inc    %edx
f010643d:	0f af c6             	imul   %esi,%eax
f0106440:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0106442:	eb c4                	jmp    f0106408 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0106444:	89 c1                	mov    %eax,%ecx
f0106446:	eb 02                	jmp    f010644a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0106448:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010644a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010644e:	74 05                	je     f0106455 <strtol+0xbd>
		*endptr = (char *) s;
f0106450:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106453:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106455:	85 ff                	test   %edi,%edi
f0106457:	74 04                	je     f010645d <strtol+0xc5>
f0106459:	89 c8                	mov    %ecx,%eax
f010645b:	f7 d8                	neg    %eax
}
f010645d:	5b                   	pop    %ebx
f010645e:	5e                   	pop    %esi
f010645f:	5f                   	pop    %edi
f0106460:	5d                   	pop    %ebp
f0106461:	c3                   	ret    
	...

f0106464 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106464:	fa                   	cli    

	xorw    %ax, %ax
f0106465:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106467:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106469:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010646b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010646d:	0f 01 16             	lgdtl  (%esi)
f0106470:	74 70                	je     f01064e2 <sum+0x2>
	movl    %cr0, %eax
f0106472:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106475:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106479:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010647c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106482:	08 00                	or     %al,(%eax)

f0106484 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106484:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106488:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010648a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010648c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010648e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106492:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106494:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106496:	b8 00 b0 12 00       	mov    $0x12b000,%eax
	movl    %eax, %cr3
f010649b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010649e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01064a1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01064a6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01064a9:	8b 25 90 8e 29 f0    	mov    0xf0298e90,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01064af:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01064b4:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f01064b9:	ff d0                	call   *%eax

f01064bb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01064bb:	eb fe                	jmp    f01064bb <spin>
f01064bd:	8d 76 00             	lea    0x0(%esi),%esi

f01064c0 <gdt>:
	...
f01064c8:	ff                   	(bad)  
f01064c9:	ff 00                	incl   (%eax)
f01064cb:	00 00                	add    %al,(%eax)
f01064cd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01064d4:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01064d8 <gdtdesc>:
f01064d8:	17                   	pop    %ss
f01064d9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01064de <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01064de:	90                   	nop
	...

f01064e0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01064e0:	55                   	push   %ebp
f01064e1:	89 e5                	mov    %esp,%ebp
f01064e3:	56                   	push   %esi
f01064e4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f01064e5:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f01064ea:	b9 00 00 00 00       	mov    $0x0,%ecx
f01064ef:	eb 07                	jmp    f01064f8 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f01064f1:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f01064f5:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01064f7:	41                   	inc    %ecx
f01064f8:	39 d1                	cmp    %edx,%ecx
f01064fa:	7c f5                	jl     f01064f1 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f01064fc:	88 d8                	mov    %bl,%al
f01064fe:	5b                   	pop    %ebx
f01064ff:	5e                   	pop    %esi
f0106500:	5d                   	pop    %ebp
f0106501:	c3                   	ret    

f0106502 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106502:	55                   	push   %ebp
f0106503:	89 e5                	mov    %esp,%ebp
f0106505:	56                   	push   %esi
f0106506:	53                   	push   %ebx
f0106507:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010650a:	8b 0d 94 8e 29 f0    	mov    0xf0298e94,%ecx
f0106510:	89 c3                	mov    %eax,%ebx
f0106512:	c1 eb 0c             	shr    $0xc,%ebx
f0106515:	39 cb                	cmp    %ecx,%ebx
f0106517:	72 20                	jb     f0106539 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106519:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010651d:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0106524:	f0 
f0106525:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010652c:	00 
f010652d:	c7 04 24 a5 9a 10 f0 	movl   $0xf0109aa5,(%esp)
f0106534:	e8 07 9b ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106539:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010653c:	89 f2                	mov    %esi,%edx
f010653e:	c1 ea 0c             	shr    $0xc,%edx
f0106541:	39 d1                	cmp    %edx,%ecx
f0106543:	77 20                	ja     f0106565 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106545:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106549:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0106550:	f0 
f0106551:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106558:	00 
f0106559:	c7 04 24 a5 9a 10 f0 	movl   $0xf0109aa5,(%esp)
f0106560:	e8 db 9a ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106565:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010656b:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106571:	eb 2f                	jmp    f01065a2 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106573:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010657a:	00 
f010657b:	c7 44 24 04 b5 9a 10 	movl   $0xf0109ab5,0x4(%esp)
f0106582:	f0 
f0106583:	89 1c 24             	mov    %ebx,(%esp)
f0106586:	e8 b8 fd ff ff       	call   f0106343 <memcmp>
f010658b:	85 c0                	test   %eax,%eax
f010658d:	75 10                	jne    f010659f <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f010658f:	ba 10 00 00 00       	mov    $0x10,%edx
f0106594:	89 d8                	mov    %ebx,%eax
f0106596:	e8 45 ff ff ff       	call   f01064e0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010659b:	84 c0                	test   %al,%al
f010659d:	74 0c                	je     f01065ab <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010659f:	83 c3 10             	add    $0x10,%ebx
f01065a2:	39 f3                	cmp    %esi,%ebx
f01065a4:	72 cd                	jb     f0106573 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01065a6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01065ab:	89 d8                	mov    %ebx,%eax
f01065ad:	83 c4 10             	add    $0x10,%esp
f01065b0:	5b                   	pop    %ebx
f01065b1:	5e                   	pop    %esi
f01065b2:	5d                   	pop    %ebp
f01065b3:	c3                   	ret    

f01065b4 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01065b4:	55                   	push   %ebp
f01065b5:	89 e5                	mov    %esp,%ebp
f01065b7:	57                   	push   %edi
f01065b8:	56                   	push   %esi
f01065b9:	53                   	push   %ebx
f01065ba:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01065bd:	c7 05 c0 93 29 f0 20 	movl   $0xf0299020,0xf02993c0
f01065c4:	90 29 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01065c7:	83 3d 94 8e 29 f0 00 	cmpl   $0x0,0xf0298e94
f01065ce:	75 24                	jne    f01065f4 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065d0:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01065d7:	00 
f01065d8:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f01065df:	f0 
f01065e0:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01065e7:	00 
f01065e8:	c7 04 24 a5 9a 10 f0 	movl   $0xf0109aa5,(%esp)
f01065ef:	e8 4c 9a ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01065f4:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01065fb:	85 c0                	test   %eax,%eax
f01065fd:	74 16                	je     f0106615 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01065ff:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106602:	ba 00 04 00 00       	mov    $0x400,%edx
f0106607:	e8 f6 fe ff ff       	call   f0106502 <mpsearch1>
f010660c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010660f:	85 c0                	test   %eax,%eax
f0106611:	75 3c                	jne    f010664f <mp_init+0x9b>
f0106613:	eb 20                	jmp    f0106635 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106615:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010661c:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010661f:	2d 00 04 00 00       	sub    $0x400,%eax
f0106624:	ba 00 04 00 00       	mov    $0x400,%edx
f0106629:	e8 d4 fe ff ff       	call   f0106502 <mpsearch1>
f010662e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106631:	85 c0                	test   %eax,%eax
f0106633:	75 1a                	jne    f010664f <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106635:	ba 00 00 01 00       	mov    $0x10000,%edx
f010663a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010663f:	e8 be fe ff ff       	call   f0106502 <mpsearch1>
f0106644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106647:	85 c0                	test   %eax,%eax
f0106649:	0f 84 2c 02 00 00    	je     f010687b <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010664f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106652:	8b 58 04             	mov    0x4(%eax),%ebx
f0106655:	85 db                	test   %ebx,%ebx
f0106657:	74 06                	je     f010665f <mp_init+0xab>
f0106659:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010665d:	74 11                	je     f0106670 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f010665f:	c7 04 24 18 99 10 f0 	movl   $0xf0109918,(%esp)
f0106666:	e8 c3 d8 ff ff       	call   f0103f2e <cprintf>
f010666b:	e9 0b 02 00 00       	jmp    f010687b <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106670:	89 d8                	mov    %ebx,%eax
f0106672:	c1 e8 0c             	shr    $0xc,%eax
f0106675:	3b 05 94 8e 29 f0    	cmp    0xf0298e94,%eax
f010667b:	72 20                	jb     f010669d <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010667d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106681:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0106688:	f0 
f0106689:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106690:	00 
f0106691:	c7 04 24 a5 9a 10 f0 	movl   $0xf0109aa5,(%esp)
f0106698:	e8 a3 99 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010669d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01066a3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01066aa:	00 
f01066ab:	c7 44 24 04 ba 9a 10 	movl   $0xf0109aba,0x4(%esp)
f01066b2:	f0 
f01066b3:	89 1c 24             	mov    %ebx,(%esp)
f01066b6:	e8 88 fc ff ff       	call   f0106343 <memcmp>
f01066bb:	85 c0                	test   %eax,%eax
f01066bd:	74 11                	je     f01066d0 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01066bf:	c7 04 24 48 99 10 f0 	movl   $0xf0109948,(%esp)
f01066c6:	e8 63 d8 ff ff       	call   f0103f2e <cprintf>
f01066cb:	e9 ab 01 00 00       	jmp    f010687b <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01066d0:	66 8b 73 04          	mov    0x4(%ebx),%si
f01066d4:	0f b7 d6             	movzwl %si,%edx
f01066d7:	89 d8                	mov    %ebx,%eax
f01066d9:	e8 02 fe ff ff       	call   f01064e0 <sum>
f01066de:	84 c0                	test   %al,%al
f01066e0:	74 11                	je     f01066f3 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f01066e2:	c7 04 24 7c 99 10 f0 	movl   $0xf010997c,(%esp)
f01066e9:	e8 40 d8 ff ff       	call   f0103f2e <cprintf>
f01066ee:	e9 88 01 00 00       	jmp    f010687b <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01066f3:	8a 43 06             	mov    0x6(%ebx),%al
f01066f6:	3c 01                	cmp    $0x1,%al
f01066f8:	74 1c                	je     f0106716 <mp_init+0x162>
f01066fa:	3c 04                	cmp    $0x4,%al
f01066fc:	74 18                	je     f0106716 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01066fe:	0f b6 c0             	movzbl %al,%eax
f0106701:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106705:	c7 04 24 a0 99 10 f0 	movl   $0xf01099a0,(%esp)
f010670c:	e8 1d d8 ff ff       	call   f0103f2e <cprintf>
f0106711:	e9 65 01 00 00       	jmp    f010687b <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106716:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f010671a:	0f b7 c6             	movzwl %si,%eax
f010671d:	01 d8                	add    %ebx,%eax
f010671f:	e8 bc fd ff ff       	call   f01064e0 <sum>
f0106724:	02 43 2a             	add    0x2a(%ebx),%al
f0106727:	84 c0                	test   %al,%al
f0106729:	74 11                	je     f010673c <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010672b:	c7 04 24 c0 99 10 f0 	movl   $0xf01099c0,(%esp)
f0106732:	e8 f7 d7 ff ff       	call   f0103f2e <cprintf>
f0106737:	e9 3f 01 00 00       	jmp    f010687b <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010673c:	85 db                	test   %ebx,%ebx
f010673e:	0f 84 37 01 00 00    	je     f010687b <mp_init+0x2c7>
		return;
	ismp = 1;
f0106744:	c7 05 00 90 29 f0 01 	movl   $0x1,0xf0299000
f010674b:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010674e:	8b 43 24             	mov    0x24(%ebx),%eax
f0106751:	a3 00 a0 2d f0       	mov    %eax,0xf02da000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106756:	8d 73 2c             	lea    0x2c(%ebx),%esi
f0106759:	bf 00 00 00 00       	mov    $0x0,%edi
f010675e:	e9 94 00 00 00       	jmp    f01067f7 <mp_init+0x243>
		switch (*p) {
f0106763:	8a 06                	mov    (%esi),%al
f0106765:	84 c0                	test   %al,%al
f0106767:	74 06                	je     f010676f <mp_init+0x1bb>
f0106769:	3c 04                	cmp    $0x4,%al
f010676b:	77 68                	ja     f01067d5 <mp_init+0x221>
f010676d:	eb 61                	jmp    f01067d0 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010676f:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106773:	74 1d                	je     f0106792 <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f0106775:	a1 c4 93 29 f0       	mov    0xf02993c4,%eax
f010677a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106781:	29 c2                	sub    %eax,%edx
f0106783:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106786:	8d 04 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%eax
f010678d:	a3 c0 93 29 f0       	mov    %eax,0xf02993c0
			if (ncpu < NCPU) {
f0106792:	a1 c4 93 29 f0       	mov    0xf02993c4,%eax
f0106797:	83 f8 07             	cmp    $0x7,%eax
f010679a:	7f 1b                	jg     f01067b7 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f010679c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01067a3:	29 c2                	sub    %eax,%edx
f01067a5:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01067a8:	88 04 95 20 90 29 f0 	mov    %al,-0xfd66fe0(,%edx,4)
				ncpu++;
f01067af:	40                   	inc    %eax
f01067b0:	a3 c4 93 29 f0       	mov    %eax,0xf02993c4
f01067b5:	eb 14                	jmp    f01067cb <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01067b7:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f01067bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067bf:	c7 04 24 f0 99 10 f0 	movl   $0xf01099f0,(%esp)
f01067c6:	e8 63 d7 ff ff       	call   f0103f2e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01067cb:	83 c6 14             	add    $0x14,%esi
			continue;
f01067ce:	eb 26                	jmp    f01067f6 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01067d0:	83 c6 08             	add    $0x8,%esi
			continue;
f01067d3:	eb 21                	jmp    f01067f6 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01067d5:	0f b6 c0             	movzbl %al,%eax
f01067d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067dc:	c7 04 24 18 9a 10 f0 	movl   $0xf0109a18,(%esp)
f01067e3:	e8 46 d7 ff ff       	call   f0103f2e <cprintf>
			ismp = 0;
f01067e8:	c7 05 00 90 29 f0 00 	movl   $0x0,0xf0299000
f01067ef:	00 00 00 
			i = conf->entry;
f01067f2:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01067f6:	47                   	inc    %edi
f01067f7:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01067fb:	39 c7                	cmp    %eax,%edi
f01067fd:	0f 82 60 ff ff ff    	jb     f0106763 <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106803:	a1 c0 93 29 f0       	mov    0xf02993c0,%eax
f0106808:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010680f:	83 3d 00 90 29 f0 00 	cmpl   $0x0,0xf0299000
f0106816:	75 22                	jne    f010683a <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106818:	c7 05 c4 93 29 f0 01 	movl   $0x1,0xf02993c4
f010681f:	00 00 00 
		lapicaddr = 0;
f0106822:	c7 05 00 a0 2d f0 00 	movl   $0x0,0xf02da000
f0106829:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010682c:	c7 04 24 38 9a 10 f0 	movl   $0xf0109a38,(%esp)
f0106833:	e8 f6 d6 ff ff       	call   f0103f2e <cprintf>
		return;
f0106838:	eb 41                	jmp    f010687b <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010683a:	8b 15 c4 93 29 f0    	mov    0xf02993c4,%edx
f0106840:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106844:	0f b6 00             	movzbl (%eax),%eax
f0106847:	89 44 24 04          	mov    %eax,0x4(%esp)
f010684b:	c7 04 24 bf 9a 10 f0 	movl   $0xf0109abf,(%esp)
f0106852:	e8 d7 d6 ff ff       	call   f0103f2e <cprintf>

	if (mp->imcrp) {
f0106857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010685a:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010685e:	74 1b                	je     f010687b <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106860:	c7 04 24 64 9a 10 f0 	movl   $0xf0109a64,(%esp)
f0106867:	e8 c2 d6 ff ff       	call   f0103f2e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010686c:	ba 22 00 00 00       	mov    $0x22,%edx
f0106871:	b0 70                	mov    $0x70,%al
f0106873:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106874:	b2 23                	mov    $0x23,%dl
f0106876:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106877:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010687a:	ee                   	out    %al,(%dx)
	}
}
f010687b:	83 c4 2c             	add    $0x2c,%esp
f010687e:	5b                   	pop    %ebx
f010687f:	5e                   	pop    %esi
f0106880:	5f                   	pop    %edi
f0106881:	5d                   	pop    %ebp
f0106882:	c3                   	ret    
	...

f0106884 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106884:	55                   	push   %ebp
f0106885:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106887:	c1 e0 02             	shl    $0x2,%eax
f010688a:	03 05 04 a0 2d f0    	add    0xf02da004,%eax
f0106890:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106892:	a1 04 a0 2d f0       	mov    0xf02da004,%eax
f0106897:	8b 40 20             	mov    0x20(%eax),%eax
}
f010689a:	5d                   	pop    %ebp
f010689b:	c3                   	ret    

f010689c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010689c:	55                   	push   %ebp
f010689d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010689f:	a1 04 a0 2d f0       	mov    0xf02da004,%eax
f01068a4:	85 c0                	test   %eax,%eax
f01068a6:	74 08                	je     f01068b0 <cpunum+0x14>
	  return lapic[ID] >> 24;
f01068a8:	8b 40 20             	mov    0x20(%eax),%eax
f01068ab:	c1 e8 18             	shr    $0x18,%eax
f01068ae:	eb 05                	jmp    f01068b5 <cpunum+0x19>
	return 0;
f01068b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01068b5:	5d                   	pop    %ebp
f01068b6:	c3                   	ret    

f01068b7 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01068b7:	55                   	push   %ebp
f01068b8:	89 e5                	mov    %esp,%ebp
f01068ba:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01068bd:	a1 00 a0 2d f0       	mov    0xf02da000,%eax
f01068c2:	85 c0                	test   %eax,%eax
f01068c4:	0f 84 27 01 00 00    	je     f01069f1 <lapic_init+0x13a>
	  return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01068ca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01068d1:	00 
f01068d2:	89 04 24             	mov    %eax,(%esp)
f01068d5:	e8 21 ab ff ff       	call   f01013fb <mmio_map_region>
f01068da:	a3 04 a0 2d f0       	mov    %eax,0xf02da004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01068df:	ba 27 01 00 00       	mov    $0x127,%edx
f01068e4:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01068e9:	e8 96 ff ff ff       	call   f0106884 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01068ee:	ba 0b 00 00 00       	mov    $0xb,%edx
f01068f3:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01068f8:	e8 87 ff ff ff       	call   f0106884 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01068fd:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106902:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106907:	e8 78 ff ff ff       	call   f0106884 <lapicw>
	lapicw(TICR, 10000000); 
f010690c:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106911:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106916:	e8 69 ff ff ff       	call   f0106884 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010691b:	e8 7c ff ff ff       	call   f010689c <cpunum>
f0106920:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106927:	29 c2                	sub    %eax,%edx
f0106929:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010692c:	8d 04 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%eax
f0106933:	39 05 c0 93 29 f0    	cmp    %eax,0xf02993c0
f0106939:	74 0f                	je     f010694a <lapic_init+0x93>
	  lapicw(LINT0, MASKED);
f010693b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106940:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106945:	e8 3a ff ff ff       	call   f0106884 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010694a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010694f:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106954:	e8 2b ff ff ff       	call   f0106884 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106959:	a1 04 a0 2d f0       	mov    0xf02da004,%eax
f010695e:	8b 40 30             	mov    0x30(%eax),%eax
f0106961:	c1 e8 10             	shr    $0x10,%eax
f0106964:	3c 03                	cmp    $0x3,%al
f0106966:	76 0f                	jbe    f0106977 <lapic_init+0xc0>
	  lapicw(PCINT, MASKED);
f0106968:	ba 00 00 01 00       	mov    $0x10000,%edx
f010696d:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106972:	e8 0d ff ff ff       	call   f0106884 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106977:	ba 33 00 00 00       	mov    $0x33,%edx
f010697c:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106981:	e8 fe fe ff ff       	call   f0106884 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106986:	ba 00 00 00 00       	mov    $0x0,%edx
f010698b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106990:	e8 ef fe ff ff       	call   f0106884 <lapicw>
	lapicw(ESR, 0);
f0106995:	ba 00 00 00 00       	mov    $0x0,%edx
f010699a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010699f:	e8 e0 fe ff ff       	call   f0106884 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01069a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01069a9:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01069ae:	e8 d1 fe ff ff       	call   f0106884 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01069b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01069b8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01069bd:	e8 c2 fe ff ff       	call   f0106884 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01069c2:	ba 00 85 08 00       	mov    $0x88500,%edx
f01069c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01069cc:	e8 b3 fe ff ff       	call   f0106884 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01069d1:	8b 15 04 a0 2d f0    	mov    0xf02da004,%edx
f01069d7:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01069dd:	f6 c4 10             	test   $0x10,%ah
f01069e0:	75 f5                	jne    f01069d7 <lapic_init+0x120>
	  ;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01069e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01069e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01069ec:	e8 93 fe ff ff       	call   f0106884 <lapicw>
}
f01069f1:	c9                   	leave  
f01069f2:	c3                   	ret    

f01069f3 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01069f3:	55                   	push   %ebp
f01069f4:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01069f6:	83 3d 04 a0 2d f0 00 	cmpl   $0x0,0xf02da004
f01069fd:	74 0f                	je     f0106a0e <lapic_eoi+0x1b>
	  lapicw(EOI, 0);
f01069ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0106a04:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106a09:	e8 76 fe ff ff       	call   f0106884 <lapicw>
}
f0106a0e:	5d                   	pop    %ebp
f0106a0f:	c3                   	ret    

f0106a10 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106a10:	55                   	push   %ebp
f0106a11:	89 e5                	mov    %esp,%ebp
f0106a13:	56                   	push   %esi
f0106a14:	53                   	push   %ebx
f0106a15:	83 ec 10             	sub    $0x10,%esp
f0106a18:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106a1b:	8a 5d 08             	mov    0x8(%ebp),%bl
f0106a1e:	ba 70 00 00 00       	mov    $0x70,%edx
f0106a23:	b0 0f                	mov    $0xf,%al
f0106a25:	ee                   	out    %al,(%dx)
f0106a26:	b2 71                	mov    $0x71,%dl
f0106a28:	b0 0a                	mov    $0xa,%al
f0106a2a:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106a2b:	83 3d 94 8e 29 f0 00 	cmpl   $0x0,0xf0298e94
f0106a32:	75 24                	jne    f0106a58 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106a34:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106a3b:	00 
f0106a3c:	c7 44 24 08 68 7b 10 	movl   $0xf0107b68,0x8(%esp)
f0106a43:	f0 
f0106a44:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106a4b:	00 
f0106a4c:	c7 04 24 dc 9a 10 f0 	movl   $0xf0109adc,(%esp)
f0106a53:	e8 e8 95 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106a58:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106a5f:	00 00 
	wrv[1] = addr >> 4;
f0106a61:	89 f0                	mov    %esi,%eax
f0106a63:	c1 e8 04             	shr    $0x4,%eax
f0106a66:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106a6c:	c1 e3 18             	shl    $0x18,%ebx
f0106a6f:	89 da                	mov    %ebx,%edx
f0106a71:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106a76:	e8 09 fe ff ff       	call   f0106884 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106a7b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106a80:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106a85:	e8 fa fd ff ff       	call   f0106884 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106a8a:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106a8f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106a94:	e8 eb fd ff ff       	call   f0106884 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106a99:	c1 ee 0c             	shr    $0xc,%esi
f0106a9c:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106aa2:	89 da                	mov    %ebx,%edx
f0106aa4:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106aa9:	e8 d6 fd ff ff       	call   f0106884 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106aae:	89 f2                	mov    %esi,%edx
f0106ab0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ab5:	e8 ca fd ff ff       	call   f0106884 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106aba:	89 da                	mov    %ebx,%edx
f0106abc:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106ac1:	e8 be fd ff ff       	call   f0106884 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106ac6:	89 f2                	mov    %esi,%edx
f0106ac8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106acd:	e8 b2 fd ff ff       	call   f0106884 <lapicw>
		microdelay(200);
	}
}
f0106ad2:	83 c4 10             	add    $0x10,%esp
f0106ad5:	5b                   	pop    %ebx
f0106ad6:	5e                   	pop    %esi
f0106ad7:	5d                   	pop    %ebp
f0106ad8:	c3                   	ret    

f0106ad9 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106ad9:	55                   	push   %ebp
f0106ada:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106adc:	8b 55 08             	mov    0x8(%ebp),%edx
f0106adf:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106ae5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106aea:	e8 95 fd ff ff       	call   f0106884 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106aef:	8b 15 04 a0 2d f0    	mov    0xf02da004,%edx
f0106af5:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106afb:	f6 c4 10             	test   $0x10,%ah
f0106afe:	75 f5                	jne    f0106af5 <lapic_ipi+0x1c>
	  ;
}
f0106b00:	5d                   	pop    %ebp
f0106b01:	c3                   	ret    
	...

f0106b04 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106b04:	55                   	push   %ebp
f0106b05:	89 e5                	mov    %esp,%ebp
f0106b07:	53                   	push   %ebx
f0106b08:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106b0b:	83 38 00             	cmpl   $0x0,(%eax)
f0106b0e:	74 25                	je     f0106b35 <holding+0x31>
f0106b10:	8b 58 08             	mov    0x8(%eax),%ebx
f0106b13:	e8 84 fd ff ff       	call   f010689c <cpunum>
f0106b18:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b1f:	29 c2                	sub    %eax,%edx
f0106b21:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b24:	8d 04 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f0106b2b:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f0106b2d:	0f 94 c0             	sete   %al
f0106b30:	0f b6 c0             	movzbl %al,%eax
f0106b33:	eb 05                	jmp    f0106b3a <holding+0x36>
f0106b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106b3a:	83 c4 04             	add    $0x4,%esp
f0106b3d:	5b                   	pop    %ebx
f0106b3e:	5d                   	pop    %ebp
f0106b3f:	c3                   	ret    

f0106b40 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106b40:	55                   	push   %ebp
f0106b41:	89 e5                	mov    %esp,%ebp
f0106b43:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106b46:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106b4f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106b52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106b59:	5d                   	pop    %ebp
f0106b5a:	c3                   	ret    

f0106b5b <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106b5b:	55                   	push   %ebp
f0106b5c:	89 e5                	mov    %esp,%ebp
f0106b5e:	53                   	push   %ebx
f0106b5f:	83 ec 24             	sub    $0x24,%esp
f0106b62:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106b65:	89 d8                	mov    %ebx,%eax
f0106b67:	e8 98 ff ff ff       	call   f0106b04 <holding>
f0106b6c:	85 c0                	test   %eax,%eax
f0106b6e:	74 30                	je     f0106ba0 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106b70:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106b73:	e8 24 fd ff ff       	call   f010689c <cpunum>
f0106b78:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106b7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106b80:	c7 44 24 08 ec 9a 10 	movl   $0xf0109aec,0x8(%esp)
f0106b87:	f0 
f0106b88:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106b8f:	00 
f0106b90:	c7 04 24 4e 9b 10 f0 	movl   $0xf0109b4e,(%esp)
f0106b97:	e8 a4 94 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106b9c:	f3 90                	pause  
f0106b9e:	eb 05                	jmp    f0106ba5 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106ba0:	ba 01 00 00 00       	mov    $0x1,%edx
f0106ba5:	89 d0                	mov    %edx,%eax
f0106ba7:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106baa:	85 c0                	test   %eax,%eax
f0106bac:	75 ee                	jne    f0106b9c <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106bae:	e8 e9 fc ff ff       	call   f010689c <cpunum>
f0106bb3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106bba:	29 c2                	sub    %eax,%edx
f0106bbc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106bbf:	8d 04 85 20 90 29 f0 	lea    -0xfd66fe0(,%eax,4),%eax
f0106bc6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106bc9:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106bcc:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106bce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106bd3:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106bd9:	76 10                	jbe    f0106beb <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106bdb:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106bde:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106be1:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106be3:	40                   	inc    %eax
f0106be4:	83 f8 0a             	cmp    $0xa,%eax
f0106be7:	75 ea                	jne    f0106bd3 <spin_lock+0x78>
f0106be9:	eb 0d                	jmp    f0106bf8 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106beb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106bf2:	40                   	inc    %eax
f0106bf3:	83 f8 09             	cmp    $0x9,%eax
f0106bf6:	7e f3                	jle    f0106beb <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106bf8:	83 c4 24             	add    $0x24,%esp
f0106bfb:	5b                   	pop    %ebx
f0106bfc:	5d                   	pop    %ebp
f0106bfd:	c3                   	ret    

f0106bfe <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106bfe:	55                   	push   %ebp
f0106bff:	89 e5                	mov    %esp,%ebp
f0106c01:	57                   	push   %edi
f0106c02:	56                   	push   %esi
f0106c03:	53                   	push   %ebx
f0106c04:	83 ec 7c             	sub    $0x7c,%esp
f0106c07:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106c0a:	89 d8                	mov    %ebx,%eax
f0106c0c:	e8 f3 fe ff ff       	call   f0106b04 <holding>
f0106c11:	85 c0                	test   %eax,%eax
f0106c13:	0f 85 d3 00 00 00    	jne    f0106cec <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106c19:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106c20:	00 
f0106c21:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106c24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c28:	8d 75 a8             	lea    -0x58(%ebp),%esi
f0106c2b:	89 34 24             	mov    %esi,(%esp)
f0106c2e:	e8 85 f6 ff ff       	call   f01062b8 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106c33:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106c36:	0f b6 38             	movzbl (%eax),%edi
f0106c39:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106c3c:	e8 5b fc ff ff       	call   f010689c <cpunum>
f0106c41:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106c45:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106c49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106c4d:	c7 04 24 18 9b 10 f0 	movl   $0xf0109b18,(%esp)
f0106c54:	e8 d5 d2 ff ff       	call   f0103f2e <cprintf>
f0106c59:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106c5b:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106c5e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106c61:	89 c7                	mov    %eax,%edi
f0106c63:	eb 63                	jmp    f0106cc8 <spin_unlock+0xca>
f0106c65:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106c69:	89 04 24             	mov    %eax,(%esp)
f0106c6c:	e8 2c eb ff ff       	call   f010579d <debuginfo_eip>
f0106c71:	85 c0                	test   %eax,%eax
f0106c73:	78 39                	js     f0106cae <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106c75:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106c77:	89 c2                	mov    %eax,%edx
f0106c79:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106c7c:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106c80:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106c83:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106c87:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106c8a:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106c8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106c91:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106c95:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106c98:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ca0:	c7 04 24 5e 9b 10 f0 	movl   $0xf0109b5e,(%esp)
f0106ca7:	e8 82 d2 ff ff       	call   f0103f2e <cprintf>
f0106cac:	eb 12                	jmp    f0106cc0 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106cae:	8b 06                	mov    (%esi),%eax
f0106cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106cb4:	c7 04 24 75 9b 10 f0 	movl   $0xf0109b75,(%esp)
f0106cbb:	e8 6e d2 ff ff       	call   f0103f2e <cprintf>
f0106cc0:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106cc3:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106cc6:	74 08                	je     f0106cd0 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106cc8:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106cca:	8b 03                	mov    (%ebx),%eax
f0106ccc:	85 c0                	test   %eax,%eax
f0106cce:	75 95                	jne    f0106c65 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106cd0:	c7 44 24 08 7d 9b 10 	movl   $0xf0109b7d,0x8(%esp)
f0106cd7:	f0 
f0106cd8:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106cdf:	00 
f0106ce0:	c7 04 24 4e 9b 10 f0 	movl   $0xf0109b4e,(%esp)
f0106ce7:	e8 54 93 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106cec:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106cf3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106cfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0106cff:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106d02:	83 c4 7c             	add    $0x7c,%esp
f0106d05:	5b                   	pop    %ebx
f0106d06:	5e                   	pop    %esi
f0106d07:	5f                   	pop    %edi
f0106d08:	5d                   	pop    %ebp
f0106d09:	c3                   	ret    
	...

f0106d0c <e1000_transmit>:
	e1000_regs[E1000_RCTL] &= E1000_RCTL_SZ_2048; 

	return 1;
}

int e1000_transmit(char *pck, size_t length){
f0106d0c:	55                   	push   %ebp
f0106d0d:	89 e5                	mov    %esp,%ebp
f0106d0f:	56                   	push   %esi
f0106d10:	53                   	push   %ebx
f0106d11:	83 ec 10             	sub    $0x10,%esp
f0106d14:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (length > PKT_SIZE) {
f0106d17:	81 fb 00 08 00 00    	cmp    $0x800,%ebx
f0106d1d:	76 13                	jbe    f0106d32 <e1000_transmit+0x26>
		cprintf("e1000_transmit: invalid packet length");
f0106d1f:	c7 04 24 98 9b 10 f0 	movl   $0xf0109b98,(%esp)
f0106d26:	e8 03 d2 ff ff       	call   f0103f2e <cprintf>
		return -1;
f0106d2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0106d30:	eb 67                	jmp    f0106d99 <e1000_transmit+0x8d>
	}

	uint32_t idx = e1000_regs[E1000_TDT]; 
f0106d32:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f0106d37:	8b b0 18 38 00 00    	mov    0x3818(%eax),%esi
	if (! (txq[idx].status&(E1000_TXD_STAT_DD>>E1000_TXD_STAT)))
f0106d3d:	89 f0                	mov    %esi,%eax
f0106d3f:	c1 e0 04             	shl    $0x4,%eax
f0106d42:	f6 80 3c a8 31 f0 01 	testb  $0x1,-0xfce57c4(%eax)
f0106d49:	74 49                	je     f0106d94 <e1000_transmit+0x88>
	  return -1;

	memmove((void*)&tx_paks[idx], (void*)pck, length);
f0106d4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106d4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106d52:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106d56:	89 f0                	mov    %esi,%eax
f0106d58:	c1 e0 0b             	shl    $0xb,%eax
f0106d5b:	05 40 aa 31 f0       	add    $0xf031aa40,%eax
f0106d60:	89 04 24             	mov    %eax,(%esp)
f0106d63:	e8 50 f5 ff ff       	call   f01062b8 <memmove>

	txq[idx].status &= ~E1000_TXD_STAT_DD; 
f0106d68:	89 f0                	mov    %esi,%eax
f0106d6a:	c1 e0 04             	shl    $0x4,%eax
f0106d6d:	05 30 a8 31 f0       	add    $0xf031a830,%eax
f0106d72:	80 60 0c fe          	andb   $0xfe,0xc(%eax)
	txq[idx].cmd |= E1000_TXD_CMD_EOP;
f0106d76:	80 48 0b 01          	orb    $0x1,0xb(%eax)
	txq[idx].length = length;
f0106d7a:	66 89 58 08          	mov    %bx,0x8(%eax)
	e1000_regs[E1000_TDT] = (idx+1)%NTXQ;
f0106d7e:	46                   	inc    %esi
f0106d7f:	83 e6 1f             	and    $0x1f,%esi
f0106d82:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f0106d87:	89 b0 18 38 00 00    	mov    %esi,0x3818(%eax)

	return 0;
f0106d8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106d92:	eb 05                	jmp    f0106d99 <e1000_transmit+0x8d>
		return -1;
	}

	uint32_t idx = e1000_regs[E1000_TDT]; 
	if (! (txq[idx].status&(E1000_TXD_STAT_DD>>E1000_TXD_STAT)))
	  return -1;
f0106d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	txq[idx].cmd |= E1000_TXD_CMD_EOP;
	txq[idx].length = length;
	e1000_regs[E1000_TDT] = (idx+1)%NTXQ;

	return 0;
}
f0106d99:	83 c4 10             	add    $0x10,%esp
f0106d9c:	5b                   	pop    %ebx
f0106d9d:	5e                   	pop    %esi
f0106d9e:	5d                   	pop    %ebp
f0106d9f:	c3                   	ret    

f0106da0 <e1000_receive>:

int
e1000_receive(char *pck, size_t* length){
f0106da0:	55                   	push   %ebp
f0106da1:	89 e5                	mov    %esp,%ebp
f0106da3:	56                   	push   %esi
f0106da4:	53                   	push   %ebx
f0106da5:	83 ec 10             	sub    $0x10,%esp

	size_t index = (e1000_regs[E1000_RDT] + 1)%NRXQ;
f0106da8:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f0106dad:	8b b0 18 28 00 00    	mov    0x2818(%eax),%esi
f0106db3:	46                   	inc    %esi
f0106db4:	83 e6 7f             	and    $0x7f,%esi
	if (!(rxq[index].status&E1000_RXD_STAT_DD)) 
f0106db7:	89 f0                	mov    %esi,%eax
f0106db9:	c1 e0 04             	shl    $0x4,%eax
f0106dbc:	0f b6 80 3c a0 31 f0 	movzbl -0xfce5fc4(%eax),%eax
f0106dc3:	a8 01                	test   $0x1,%al
f0106dc5:	74 6a                	je     f0106e31 <e1000_receive+0x91>
	  return -E_E1000_RXBUF_EMPTY;

	if (!(rxq[index].status & E1000_RXD_STAT_EOP))
f0106dc7:	a8 02                	test   $0x2,%al
f0106dc9:	75 1c                	jne    f0106de7 <e1000_receive+0x47>
	  panic("e1000_receive: EOP not set");
f0106dcb:	c7 44 24 08 be 9b 10 	movl   $0xf0109bbe,0x8(%esp)
f0106dd2:	f0 
f0106dd3:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106dda:	00 
f0106ddb:	c7 04 24 d9 9b 10 f0 	movl   $0xf0109bd9,(%esp)
f0106de2:	e8 59 92 ff ff       	call   f0100040 <_panic>

	*length = rxq[index].length;
f0106de7:	89 f3                	mov    %esi,%ebx
f0106de9:	c1 e3 04             	shl    $0x4,%ebx
f0106dec:	0f b7 83 38 a0 31 f0 	movzwl -0xfce5fc8(%ebx),%eax
f0106df3:	81 c3 30 a0 31 f0    	add    $0xf031a030,%ebx
f0106df9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106dfc:	89 02                	mov    %eax,(%edx)
	memmove((void*)pck, &rx_paks[index], *length);
f0106dfe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106e02:	89 f0                	mov    %esi,%eax
f0106e04:	c1 e0 0b             	shl    $0xb,%eax
f0106e07:	05 20 a0 2d f0       	add    $0xf02da020,%eax
f0106e0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e10:	8b 45 08             	mov    0x8(%ebp),%eax
f0106e13:	89 04 24             	mov    %eax,(%esp)
f0106e16:	e8 9d f4 ff ff       	call   f01062b8 <memmove>

	rxq[index].status &= ~E1000_RXD_STAT_DD;
	rxq[index].status &= ~E1000_RXD_STAT_EOP;
f0106e1b:	80 63 0c fc          	andb   $0xfc,0xc(%ebx)

	e1000_regs[E1000_RDT] = index;
f0106e1f:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f0106e24:	89 b0 18 28 00 00    	mov    %esi,0x2818(%eax)

	return 0;
f0106e2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0106e2f:	eb 05                	jmp    f0106e36 <e1000_receive+0x96>
int
e1000_receive(char *pck, size_t* length){

	size_t index = (e1000_regs[E1000_RDT] + 1)%NRXQ;
	if (!(rxq[index].status&E1000_RXD_STAT_DD)) 
	  return -E_E1000_RXBUF_EMPTY;
f0106e31:	b8 ef ff ff ff       	mov    $0xffffffef,%eax
	rxq[index].status &= ~E1000_RXD_STAT_EOP;

	e1000_regs[E1000_RDT] = index;

	return 0;
}
f0106e36:	83 c4 10             	add    $0x10,%esp
f0106e39:	5b                   	pop    %ebx
f0106e3a:	5e                   	pop    %esi
f0106e3b:	5d                   	pop    %ebp
f0106e3c:	c3                   	ret    

f0106e3d <clear_e1000_interrupt>:

void
clear_e1000_interrupt(void)
{
f0106e3d:	55                   	push   %ebp
f0106e3e:	89 e5                	mov    %esp,%ebp
f0106e40:	83 ec 08             	sub    $0x8,%esp
	// As per the Intel manual, section 13.4.7, writing to a bit clears
	// that bit, acknowledging the interrupt.
	e1000_regs[E1000_ICR] |= E1000_RXT0;
f0106e43:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f0106e48:	8b 90 c0 00 00 00    	mov    0xc0(%eax),%edx
f0106e4e:	80 ca 80             	or     $0x80,%dl
f0106e51:	89 90 c0 00 00 00    	mov    %edx,0xc0(%eax)
	lapic_eoi();
f0106e57:	e8 97 fb ff ff       	call   f01069f3 <lapic_eoi>
	irq_eoi();
f0106e5c:	e8 75 d0 ff ff       	call   f0103ed6 <irq_eoi>

}
f0106e61:	c9                   	leave  
f0106e62:	c3                   	ret    

f0106e63 <e1000_trap_handler>:

void
e1000_trap_handler(void)
{
f0106e63:	55                   	push   %ebp
f0106e64:	89 e5                	mov    %esp,%ebp
f0106e66:	83 ec 08             	sub    $0x8,%esp
	int i;

	// See if there's an environment waiting to receive a packet
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_e1000_waiting_rx)
		  receiver = &envs[i];
f0106e69:	a1 48 82 29 f0       	mov    0xf0298248,%eax
	struct Env *receiver = NULL;
	int i;

	// See if there's an environment waiting to receive a packet
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_e1000_waiting_rx)
f0106e6e:	ba 00 04 00 00       	mov    $0x400,%edx
}

void
e1000_trap_handler(void)
{
	struct Env *receiver = NULL;
f0106e73:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i;

	// See if there's an environment waiting to receive a packet
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_e1000_waiting_rx)
f0106e78:	80 78 7c 00          	cmpb   $0x0,0x7c(%eax)
f0106e7c:	74 02                	je     f0106e80 <e1000_trap_handler+0x1d>
		  receiver = &envs[i];
f0106e7e:	89 c1                	mov    %eax,%ecx
	struct Env *receiver = NULL;
	int i;

	// See if there's an environment waiting to receive a packet
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_e1000_waiting_rx)
f0106e80:	83 e8 80             	sub    $0xffffff80,%eax
{
	struct Env *receiver = NULL;
	int i;

	// See if there's an environment waiting to receive a packet
	for (i = 0; i < NENV; i++) {
f0106e83:	4a                   	dec    %edx
f0106e84:	75 f2                	jne    f0106e78 <e1000_trap_handler+0x15>
		if (envs[i].env_e1000_waiting_rx)
		  receiver = &envs[i];
	}

	// If no environment is waiting, quietly acknowledge the interrupt
	if (!receiver) {
f0106e86:	85 c9                	test   %ecx,%ecx
f0106e88:	75 07                	jne    f0106e91 <e1000_trap_handler+0x2e>
		clear_e1000_interrupt();
f0106e8a:	e8 ae ff ff ff       	call   f0106e3d <clear_e1000_interrupt>
		return;
f0106e8f:	eb 10                	jmp    f0106ea1 <e1000_trap_handler+0x3e>
	}
	else {
		receiver->env_status = ENV_RUNNABLE;
f0106e91:	c7 41 54 02 00 00 00 	movl   $0x2,0x54(%ecx)
		receiver->env_e1000_waiting_rx = false;
f0106e98:	c6 41 7c 00          	movb   $0x0,0x7c(%ecx)
		clear_e1000_interrupt();
f0106e9c:	e8 9c ff ff ff       	call   f0106e3d <clear_e1000_interrupt>
		return;
	}
}
f0106ea1:	c9                   	leave  
f0106ea2:	c3                   	ret    

f0106ea3 <read_mac_from_eeprom>:

// This method reads the MAC address 16 bits at a time from the EEPROM
void
read_mac_from_eeprom(void)
{
f0106ea3:	55                   	push   %ebp
f0106ea4:	89 e5                	mov    %esp,%ebp
f0106ea6:	53                   	push   %ebx
	uint8_t word_num;

	for (word_num = 0; word_num < E1000_NUM_MAC_WORDS; word_num++) {

		// Set address to read
		e1000_regs[E1000_EERD] |= (word_num << E1000_EERD_ADDR);
f0106ea7:	8b 15 28 a0 31 f0    	mov    0xf031a028,%edx
f0106ead:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106eb2:	8b 42 14             	mov    0x14(%edx),%eax
f0106eb5:	89 cb                	mov    %ecx,%ebx
f0106eb7:	c1 e3 08             	shl    $0x8,%ebx
f0106eba:	09 d8                	or     %ebx,%eax
f0106ebc:	89 42 14             	mov    %eax,0x14(%edx)

		// Tell controller to read
		e1000_regs[E1000_EERD] |= E1000_EERD_READ;
f0106ebf:	8b 42 14             	mov    0x14(%edx),%eax
f0106ec2:	83 c8 01             	or     $0x1,%eax
f0106ec5:	89 42 14             	mov    %eax,0x14(%edx)

		// Spin until controller indicates it is down with the read
		while (!(e1000_regs[E1000_EERD] & E1000_EERD_DONE))
f0106ec8:	8b 42 14             	mov    0x14(%edx),%eax
f0106ecb:	a8 10                	test   $0x10,%al
f0106ecd:	74 f9                	je     f0106ec8 <read_mac_from_eeprom+0x25>
		  ;

		// Read value into memory
		mac[word_num] = e1000_regs[E1000_EERD] >> E1000_EERD_DATA;
f0106ecf:	8b 42 14             	mov    0x14(%edx),%eax
f0106ed2:	c1 e8 10             	shr    $0x10,%eax
f0106ed5:	66 89 84 09 20 a0 31 	mov    %ax,-0xfce5fe0(%ecx,%ecx,1)
f0106edc:	f0 

		// Register has to be cleared, otherwise it keeps reading the
		// same value over and over
		e1000_regs[E1000_EERD] = 0x0;
f0106edd:	c7 42 14 00 00 00 00 	movl   $0x0,0x14(%edx)
f0106ee4:	41                   	inc    %ecx
void
read_mac_from_eeprom(void)
{
	uint8_t word_num;

	for (word_num = 0; word_num < E1000_NUM_MAC_WORDS; word_num++) {
f0106ee5:	83 f9 03             	cmp    $0x3,%ecx
f0106ee8:	75 c8                	jne    f0106eb2 <read_mac_from_eeprom+0xf>

		// Register has to be cleared, otherwise it keeps reading the
		// same value over and over
		e1000_regs[E1000_EERD] = 0x0;
	}
}
f0106eea:	5b                   	pop    %ebx
f0106eeb:	5d                   	pop    %ebp
f0106eec:	c3                   	ret    

f0106eed <e1000_init>:
uint16_t mac[E1000_NUM_MAC_WORDS];

// Forward declaration
void read_mac_from_eeprom(void);

int e1000_init(struct pci_func *f){
f0106eed:	55                   	push   %ebp
f0106eee:	89 e5                	mov    %esp,%ebp
f0106ef0:	83 ec 18             	sub    $0x18,%esp
f0106ef3:	8b 45 08             	mov    0x8(%ebp),%eax

	e1000_regs = mmio_map_region((physaddr_t)(f->reg_base[0]), f->reg_size[0]);
f0106ef6:	8b 50 2c             	mov    0x2c(%eax),%edx
f0106ef9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106efd:	8b 40 14             	mov    0x14(%eax),%eax
f0106f00:	89 04 24             	mov    %eax,(%esp)
f0106f03:	e8 f3 a4 ff ff       	call   f01013fb <mmio_map_region>
f0106f08:	a3 28 a0 31 f0       	mov    %eax,0xf031a028
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106f0d:	ba 30 a8 31 f0       	mov    $0xf031a830,%edx
f0106f12:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0106f18:	77 20                	ja     f0106f3a <e1000_init+0x4d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0106f1a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106f1e:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0106f25:	f0 
f0106f26:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
f0106f2d:	00 
f0106f2e:	c7 04 24 d9 9b 10 f0 	movl   $0xf0109bd9,(%esp)
f0106f35:	e8 06 91 ff ff       	call   f0100040 <_panic>
	/*-------------------
	  transmission init
	  ----------------------*/

	//txq base address
	e1000_regs[E1000_TDBAL] = PADDR(txq); 
f0106f3a:	c7 80 00 38 00 00 30 	movl   $0x31a830,0x3800(%eax)
f0106f41:	a8 31 00 
	e1000_regs[E1000_TDBAH] = ZERO;
f0106f44:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f0106f4b:	00 00 00 
	e1000_regs[E1000_TDLEN] = NTXQ * sizeof(struct e1000_tx_desc);
f0106f4e:	c7 80 08 38 00 00 00 	movl   $0x200,0x3808(%eax)
f0106f55:	02 00 00 

	// transmit descriptor header and tail
	e1000_regs[E1000_TDH] = ZERO;
f0106f58:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0106f5f:	00 00 00 
	e1000_regs[E1000_TDT] = ZERO;
f0106f62:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f0106f69:	00 00 00 

	// transmit control register 
	e1000_regs[E1000_TCTL] |= E1000_TCTL_EN; 
f0106f6c:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106f72:	83 ca 02             	or     $0x2,%edx
f0106f75:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	e1000_regs[E1000_TCTL] |= E1000_TCTL_PSP;
f0106f7b:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106f81:	83 ca 08             	or     $0x8,%edx
f0106f84:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	e1000_regs[E1000_TCTL] |= E1000_TCTL_CT;
f0106f8a:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106f90:	80 ce 01             	or     $0x1,%dh
f0106f93:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)
	e1000_regs[E1000_TCTL] |= E1000_TCTL_COLD;
f0106f99:	8b 90 00 04 00 00    	mov    0x400(%eax),%edx
f0106f9f:	81 ca 00 00 04 00    	or     $0x40000,%edx
f0106fa5:	89 90 00 04 00 00    	mov    %edx,0x400(%eax)

	// transmit IPG register 
	e1000_regs[E1000_TIPG] = 0xA<<E1000_IPGT;
f0106fab:	c7 80 10 04 00 00 0a 	movl   $0xa,0x410(%eax)
f0106fb2:	00 00 00 
	e1000_regs[E1000_TIPG] = 0x8<<E1000_IPGT1;
f0106fb5:	c7 80 10 04 00 00 00 	movl   $0x2000,0x410(%eax)
f0106fbc:	20 00 00 
	e1000_regs[E1000_TIPG] = 0xC<<E1000_IPGT2;
f0106fbf:	c7 80 10 04 00 00 00 	movl   $0xc00000,0x410(%eax)
f0106fc6:	00 c0 00 

	// set each tx descriptor
	memset(txq, 0, NTXQ * sizeof(struct e1000_tx_desc));
f0106fc9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
f0106fd0:	00 
f0106fd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0106fd8:	00 
f0106fd9:	c7 04 24 30 a8 31 f0 	movl   $0xf031a830,(%esp)
f0106fe0:	e8 89 f2 ff ff       	call   f010626e <memset>
f0106fe5:	b8 30 a8 31 f0       	mov    $0xf031a830,%eax
	int i;
	for (i = 0;i < NTXQ; i++){
f0106fea:	ba 00 00 00 00       	mov    $0x0,%edx
		txq[i].buffer_addr = PADDR(&tx_paks[i]);
f0106fef:	89 d1                	mov    %edx,%ecx
f0106ff1:	c1 e1 0b             	shl    $0xb,%ecx
f0106ff4:	81 c1 40 aa 31 f0    	add    $0xf031aa40,%ecx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0106ffa:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0107000:	77 20                	ja     f0107022 <e1000_init+0x135>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0107002:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0107006:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f010700d:	f0 
f010700e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0107015:	00 
f0107016:	c7 04 24 d9 9b 10 f0 	movl   $0xf0109bd9,(%esp)
f010701d:	e8 1e 90 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0107022:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f0107028:	89 08                	mov    %ecx,(%eax)
f010702a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		txq[i].cmd |= E1000_TXD_CMD_RS; 
f0107031:	8a 48 0b             	mov    0xb(%eax),%cl
f0107034:	83 c9 08             	or     $0x8,%ecx
		txq[i].cmd &= ~E1000_TXD_CMD_DEXT;
f0107037:	83 e1 df             	and    $0xffffffdf,%ecx
f010703a:	88 48 0b             	mov    %cl,0xb(%eax)
		txq[i].status |= E1000_TXD_STAT_DD;
f010703d:	80 48 0c 01          	orb    $0x1,0xc(%eax)
	e1000_regs[E1000_TIPG] = 0xC<<E1000_IPGT2;

	// set each tx descriptor
	memset(txq, 0, NTXQ * sizeof(struct e1000_tx_desc));
	int i;
	for (i = 0;i < NTXQ; i++){
f0107041:	42                   	inc    %edx
f0107042:	83 c0 10             	add    $0x10,%eax
f0107045:	83 fa 20             	cmp    $0x20,%edx
f0107048:	75 a5                	jne    f0106fef <e1000_init+0x102>
	  receive init
	  ----------------------*/

	// MAC address
	
	read_mac_from_eeprom();
f010704a:	e8 54 fe ff ff       	call   f0106ea3 <read_mac_from_eeprom>

	e1000_regs[E1000_RAL] = 0x0;
f010704f:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f0107054:	c7 80 00 54 00 00 00 	movl   $0x0,0x5400(%eax)
f010705b:	00 00 00 
	e1000_regs[E1000_RAL] = mac[0];
f010705e:	0f b7 15 20 a0 31 f0 	movzwl 0xf031a020,%edx
f0107065:	89 90 00 54 00 00    	mov    %edx,0x5400(%eax)
	e1000_regs[E1000_RAL] |= (mac[1] << E1000_EERD_DATA);
f010706b:	8b 90 00 54 00 00    	mov    0x5400(%eax),%edx
f0107071:	0f b7 0d 22 a0 31 f0 	movzwl 0xf031a022,%ecx
f0107078:	c1 e1 10             	shl    $0x10,%ecx
f010707b:	09 ca                	or     %ecx,%edx
f010707d:	89 90 00 54 00 00    	mov    %edx,0x5400(%eax)

	e1000_regs[E1000_RAH] = 0x0;
f0107083:	c7 80 04 54 00 00 00 	movl   $0x0,0x5404(%eax)
f010708a:	00 00 00 
	e1000_regs[E1000_RAH] |= mac[2];
f010708d:	8b 90 04 54 00 00    	mov    0x5404(%eax),%edx
f0107093:	0f b7 0d 24 a0 31 f0 	movzwl 0xf031a024,%ecx
f010709a:	09 ca                	or     %ecx,%edx
f010709c:	89 90 04 54 00 00    	mov    %edx,0x5404(%eax)
	e1000_regs[E1000_RAH] |= E1000_RAH_AV;
f01070a2:	8b 90 04 54 00 00    	mov    0x5404(%eax),%edx
f01070a8:	81 ca 00 00 00 80    	or     $0x80000000,%edx
f01070ae:	89 90 04 54 00 00    	mov    %edx,0x5404(%eax)
f01070b4:	b8 00 52 00 00       	mov    $0x5200,%eax

	for (i = 0; i < NMTA; i++){
		e1000_regs[E1000_MTA+i] = ZERO;	
f01070b9:	89 c2                	mov    %eax,%edx
f01070bb:	03 15 28 a0 31 f0    	add    0xf031a028,%edx
f01070c1:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f01070c7:	83 c0 04             	add    $0x4,%eax

	e1000_regs[E1000_RAH] = 0x0;
	e1000_regs[E1000_RAH] |= mac[2];
	e1000_regs[E1000_RAH] |= E1000_RAH_AV;

	for (i = 0; i < NMTA; i++){
f01070ca:	3d 00 54 00 00       	cmp    $0x5400,%eax
f01070cf:	75 e8                	jne    f01070b9 <e1000_init+0x1cc>

	// Interrupt
	//e1000_regs[E1000_IMS] |= E1000_ICR_LSC; 
	//e1000_regs[E1000_IMS] |= E1000_ICR_RXO; 
	//e1000_regs[E1000_IMS] |= E1000_ICR_RXSEQ; 
	e1000_regs[E1000_IMS] |= E1000_ICR_RXT0; 
f01070d1:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f01070d6:	8b 90 d0 00 00 00    	mov    0xd0(%eax),%edx
f01070dc:	80 ca 80             	or     $0x80,%dl
f01070df:	89 90 d0 00 00 00    	mov    %edx,0xd0(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01070e5:	ba 30 a0 31 f0       	mov    $0xf031a030,%edx
f01070ea:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01070f0:	77 20                	ja     f0107112 <e1000_init+0x225>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01070f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01070f6:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f01070fd:	f0 
f01070fe:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
f0107105:	00 
f0107106:	c7 04 24 d9 9b 10 f0 	movl   $0xf0109bd9,(%esp)
f010710d:	e8 2e 8f ff ff       	call   f0100040 <_panic>
	//e1000_regs[E1000_IMS] |= E1000_ICR_RXDMT0; 

	// Receive Descriptor Base Address
	e1000_regs[E1000_RDBAL] = PADDR(&rxq);
f0107112:	c7 80 00 28 00 00 30 	movl   $0x31a030,0x2800(%eax)
f0107119:	a0 31 00 
	e1000_regs[E1000_RDBAH] = ZERO;
f010711c:	c7 80 04 28 00 00 00 	movl   $0x0,0x2804(%eax)
f0107123:	00 00 00 
	e1000_regs[E1000_RDLEN] = NRXQ * sizeof(struct e1000_rx_desc);
f0107126:	c7 80 08 28 00 00 00 	movl   $0x800,0x2808(%eax)
f010712d:	08 00 00 

	// transmit descriptor header and tail
	e1000_regs[E1000_RDH] = 0;
f0107130:	c7 80 10 28 00 00 00 	movl   $0x0,0x2810(%eax)
f0107137:	00 00 00 
	e1000_regs[E1000_RDT] = NRXQ - 1;
f010713a:	c7 80 18 28 00 00 7f 	movl   $0x7f,0x2818(%eax)
f0107141:	00 00 00 
	memset(rxq, 0, NRXQ*sizeof(struct e1000_rx_desc));
f0107144:	c7 44 24 08 00 08 00 	movl   $0x800,0x8(%esp)
f010714b:	00 
f010714c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107153:	00 
f0107154:	c7 04 24 30 a0 31 f0 	movl   $0xf031a030,(%esp)
f010715b:	e8 0e f1 ff ff       	call   f010626e <memset>
f0107160:	ba 30 a0 31 f0       	mov    $0xf031a030,%edx

	for (i = 0; i < NRXQ; i++) {
f0107165:	b8 00 00 00 00       	mov    $0x0,%eax
		rxq[i].buffer_addr = PADDR(&rx_paks[i]);	
f010716a:	89 c1                	mov    %eax,%ecx
f010716c:	c1 e1 0b             	shl    $0xb,%ecx
f010716f:	81 c1 20 a0 2d f0    	add    $0xf02da020,%ecx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0107175:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010717b:	77 20                	ja     f010719d <e1000_init+0x2b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010717d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0107181:	c7 44 24 08 44 7b 10 	movl   $0xf0107b44,0x8(%esp)
f0107188:	f0 
f0107189:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
f0107190:	00 
f0107191:	c7 04 24 d9 9b 10 f0 	movl   $0xf0109bd9,(%esp)
f0107198:	e8 a3 8e ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010719d:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f01071a3:	89 0a                	mov    %ecx,(%edx)
f01071a5:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	// transmit descriptor header and tail
	e1000_regs[E1000_RDH] = 0;
	e1000_regs[E1000_RDT] = NRXQ - 1;
	memset(rxq, 0, NRXQ*sizeof(struct e1000_rx_desc));

	for (i = 0; i < NRXQ; i++) {
f01071ac:	40                   	inc    %eax
f01071ad:	83 c2 10             	add    $0x10,%edx
f01071b0:	3d 80 00 00 00       	cmp    $0x80,%eax
f01071b5:	75 b3                	jne    f010716a <e1000_init+0x27d>
		rxq[i].buffer_addr = PADDR(&rx_paks[i]);	
	} 	

	// Receive Control Register
	e1000_regs[E1000_RCTL] |= E1000_RCTL_EN;
f01071b7:	a1 28 a0 31 f0       	mov    0xf031a028,%eax
f01071bc:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f01071c2:	83 ca 02             	or     $0x2,%edx
f01071c5:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	e1000_regs[E1000_RCTL] &= ~E1000_RCTL_LPE; 
f01071cb:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f01071d1:	83 e2 df             	and    $0xffffffdf,%edx
f01071d4:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	e1000_regs[E1000_RCTL] &= E1000_RCTL_LBM_NO; 
f01071da:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f01071e0:	80 e2 3f             	and    $0x3f,%dl
f01071e3:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	e1000_regs[E1000_RCTL] |= E1000_RCTL_SECRC; 
f01071e9:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f01071ef:	81 ca 00 00 00 04    	or     $0x4000000,%edx
f01071f5:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)
	e1000_regs[E1000_RCTL] &= E1000_RCTL_SZ_2048; 
f01071fb:	8b 90 00 01 00 00    	mov    0x100(%eax),%edx
f0107201:	81 e2 ff ff fc ff    	and    $0xfffcffff,%edx
f0107207:	89 90 00 01 00 00    	mov    %edx,0x100(%eax)

	return 1;
}
f010720d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107212:	c9                   	leave  
f0107213:	c3                   	ret    

f0107214 <e1000_get_mac>:
}


void
e1000_get_mac(uint8_t *mac_addr)
{
f0107214:	55                   	push   %ebp
f0107215:	89 e5                	mov    %esp,%ebp
f0107217:	8b 45 08             	mov    0x8(%ebp),%eax
	*((uint32_t *) mac_addr) =  (uint32_t) e1000_regs[E1000_RAL];
f010721a:	8b 15 28 a0 31 f0    	mov    0xf031a028,%edx
f0107220:	8b 92 00 54 00 00    	mov    0x5400(%edx),%edx
f0107226:	89 10                	mov    %edx,(%eax)
	*((uint16_t*)(mac_addr + 4)) = (uint16_t) e1000_regs[E1000_RAH];
f0107228:	8b 15 28 a0 31 f0    	mov    0xf031a028,%edx
f010722e:	8b 92 04 54 00 00    	mov    0x5404(%edx),%edx
f0107234:	66 89 50 04          	mov    %dx,0x4(%eax)
}
f0107238:	5d                   	pop    %ebp
f0107239:	c3                   	ret    
	...

f010723c <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f010723c:	55                   	push   %ebp
f010723d:	89 e5                	mov    %esp,%ebp
f010723f:	57                   	push   %edi
f0107240:	56                   	push   %esi
f0107241:	53                   	push   %ebx
f0107242:	83 ec 3c             	sub    $0x3c,%esp
f0107245:	89 c7                	mov    %eax,%edi
f0107247:	89 55 e4             	mov    %edx,-0x1c(%ebp)
				cprintf("pci_attach_match: attaching "
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
f010724a:	89 cb                	mov    %ecx,%ebx
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010724c:	eb 41                	jmp    f010728f <pci_attach_match+0x53>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f010724e:	39 3b                	cmp    %edi,(%ebx)
f0107250:	75 3a                	jne    f010728c <pci_attach_match+0x50>
f0107252:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107255:	39 56 04             	cmp    %edx,0x4(%esi)
f0107258:	75 32                	jne    f010728c <pci_attach_match+0x50>
			int r = list[i].attachfn(pcif);
f010725a:	8b 55 08             	mov    0x8(%ebp),%edx
f010725d:	89 14 24             	mov    %edx,(%esp)
f0107260:	ff d0                	call   *%eax
			if (r > 0)
f0107262:	85 c0                	test   %eax,%eax
f0107264:	7f 32                	jg     f0107298 <pci_attach_match+0x5c>
				return r;
			if (r < 0)
f0107266:	85 c0                	test   %eax,%eax
f0107268:	79 22                	jns    f010728c <pci_attach_match+0x50>
				cprintf("pci_attach_match: attaching "
f010726a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010726e:	8b 46 08             	mov    0x8(%esi),%eax
f0107271:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107275:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107278:	89 54 24 08          	mov    %edx,0x8(%esp)
f010727c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0107280:	c7 04 24 e8 9b 10 f0 	movl   $0xf0109be8,(%esp)
f0107287:	e8 a2 cc ff ff       	call   f0103f2e <cprintf>
f010728c:	83 c3 0c             	add    $0xc,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
	outl(pci_conf1_data_ioport, v);
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
f010728f:	89 de                	mov    %ebx,%esi
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0107291:	8b 43 08             	mov    0x8(%ebx),%eax
f0107294:	85 c0                	test   %eax,%eax
f0107296:	75 b6                	jne    f010724e <pci_attach_match+0x12>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0107298:	83 c4 3c             	add    $0x3c,%esp
f010729b:	5b                   	pop    %ebx
f010729c:	5e                   	pop    %esi
f010729d:	5f                   	pop    %edi
f010729e:	5d                   	pop    %ebp
f010729f:	c3                   	ret    

f01072a0 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f01072a0:	55                   	push   %ebp
f01072a1:	89 e5                	mov    %esp,%ebp
f01072a3:	53                   	push   %ebx
f01072a4:	83 ec 14             	sub    $0x14,%esp
f01072a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f01072aa:	3d ff 00 00 00       	cmp    $0xff,%eax
f01072af:	76 24                	jbe    f01072d5 <pci_conf1_set_addr+0x35>
f01072b1:	c7 44 24 0c 40 9d 10 	movl   $0xf0109d40,0xc(%esp)
f01072b8:	f0 
f01072b9:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01072c0:	f0 
f01072c1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
f01072c8:	00 
f01072c9:	c7 04 24 4a 9d 10 f0 	movl   $0xf0109d4a,(%esp)
f01072d0:	e8 6b 8d ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f01072d5:	83 fa 1f             	cmp    $0x1f,%edx
f01072d8:	76 24                	jbe    f01072fe <pci_conf1_set_addr+0x5e>
f01072da:	c7 44 24 0c 55 9d 10 	movl   $0xf0109d55,0xc(%esp)
f01072e1:	f0 
f01072e2:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f01072e9:	f0 
f01072ea:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f01072f1:	00 
f01072f2:	c7 04 24 4a 9d 10 f0 	movl   $0xf0109d4a,(%esp)
f01072f9:	e8 42 8d ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f01072fe:	83 f9 07             	cmp    $0x7,%ecx
f0107301:	76 24                	jbe    f0107327 <pci_conf1_set_addr+0x87>
f0107303:	c7 44 24 0c 5e 9d 10 	movl   $0xf0109d5e,0xc(%esp)
f010730a:	f0 
f010730b:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0107312:	f0 
f0107313:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f010731a:	00 
f010731b:	c7 04 24 4a 9d 10 f0 	movl   $0xf0109d4a,(%esp)
f0107322:	e8 19 8d ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0107327:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010732d:	76 24                	jbe    f0107353 <pci_conf1_set_addr+0xb3>
f010732f:	c7 44 24 0c 67 9d 10 	movl   $0xf0109d67,0xc(%esp)
f0107336:	f0 
f0107337:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f010733e:	f0 
f010733f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
f0107346:	00 
f0107347:	c7 04 24 4a 9d 10 f0 	movl   $0xf0109d4a,(%esp)
f010734e:	e8 ed 8c ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f0107353:	f6 c3 03             	test   $0x3,%bl
f0107356:	74 24                	je     f010737c <pci_conf1_set_addr+0xdc>
f0107358:	c7 44 24 0c 74 9d 10 	movl   $0xf0109d74,0xc(%esp)
f010735f:	f0 
f0107360:	c7 44 24 08 63 8a 10 	movl   $0xf0108a63,0x8(%esp)
f0107367:	f0 
f0107368:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
f010736f:	00 
f0107370:	c7 04 24 4a 9d 10 f0 	movl   $0xf0109d4a,(%esp)
f0107377:	e8 c4 8c ff ff       	call   f0100040 <_panic>

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
f010737c:	c1 e0 10             	shl    $0x10,%eax
f010737f:	0d 00 00 00 80       	or     $0x80000000,%eax
f0107384:	c1 e2 0b             	shl    $0xb,%edx
f0107387:	09 d0                	or     %edx,%eax
f0107389:	09 d8                	or     %ebx,%eax
f010738b:	c1 e1 08             	shl    $0x8,%ecx
	assert(dev < 32);
	assert(func < 8);
	assert(offset < 256);
	assert((offset & 0x3) == 0);

	uint32_t v = (1 << 31) |		// config-space
f010738e:	09 c8                	or     %ecx,%eax
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0107390:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0107395:	ef                   	out    %eax,(%dx)
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0107396:	83 c4 14             	add    $0x14,%esp
f0107399:	5b                   	pop    %ebx
f010739a:	5d                   	pop    %ebp
f010739b:	c3                   	ret    

f010739c <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f010739c:	55                   	push   %ebp
f010739d:	89 e5                	mov    %esp,%ebp
f010739f:	53                   	push   %ebx
f01073a0:	83 ec 14             	sub    $0x14,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01073a3:	8b 48 08             	mov    0x8(%eax),%ecx
f01073a6:	8b 58 04             	mov    0x4(%eax),%ebx
f01073a9:	8b 00                	mov    (%eax),%eax
f01073ab:	8b 40 04             	mov    0x4(%eax),%eax
f01073ae:	89 14 24             	mov    %edx,(%esp)
f01073b1:	89 da                	mov    %ebx,%edx
f01073b3:	e8 e8 fe ff ff       	call   f01072a0 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f01073b8:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01073bd:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f01073be:	83 c4 14             	add    $0x14,%esp
f01073c1:	5b                   	pop    %ebx
f01073c2:	5d                   	pop    %ebp
f01073c3:	c3                   	ret    

f01073c4 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f01073c4:	55                   	push   %ebp
f01073c5:	89 e5                	mov    %esp,%ebp
f01073c7:	57                   	push   %edi
f01073c8:	56                   	push   %esi
f01073c9:	53                   	push   %ebx
f01073ca:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
f01073d0:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f01073d2:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f01073d9:	00 
f01073da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01073e1:	00 
f01073e2:	8d 45 a0             	lea    -0x60(%ebp),%eax
f01073e5:	89 04 24             	mov    %eax,(%esp)
f01073e8:	e8 81 ee ff ff       	call   f010626e <memset>
	df.bus = bus;
f01073ed:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01073f0:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f01073f7:	c7 85 f8 fe ff ff 00 	movl   $0x0,-0x108(%ebp)
f01073fe:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0107401:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107404:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;

		totaldev++;

		struct pci_func f = df;
f010740a:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0107410:	89 85 00 ff ff ff    	mov    %eax,-0x100(%ebp)
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0107416:	ba 0c 00 00 00       	mov    $0xc,%edx
f010741b:	8d 45 a0             	lea    -0x60(%ebp),%eax
f010741e:	e8 79 ff ff ff       	call   f010739c <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0107423:	89 c2                	mov    %eax,%edx
f0107425:	c1 ea 10             	shr    $0x10,%edx
f0107428:	83 e2 7f             	and    $0x7f,%edx
f010742b:	83 fa 01             	cmp    $0x1,%edx
f010742e:	0f 87 66 01 00 00    	ja     f010759a <pci_scan_bus+0x1d6>
			continue;

		totaldev++;
f0107434:	ff 85 f8 fe ff ff    	incl   -0x108(%ebp)

		struct pci_func f = df;
f010743a:	b9 12 00 00 00       	mov    $0x12,%ecx
f010743f:	8b bd 00 ff ff ff    	mov    -0x100(%ebp),%edi
f0107445:	8b b5 04 ff ff ff    	mov    -0xfc(%ebp),%esi
f010744b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010744d:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f0107454:	00 00 00 
f0107457:	25 00 00 80 00       	and    $0x800000,%eax
f010745c:	89 85 fc fe ff ff    	mov    %eax,-0x104(%ebp)
		     f.func++) {
			struct pci_func af = f;
f0107462:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0107468:	e9 12 01 00 00       	jmp    f010757f <pci_scan_bus+0x1bb>
		     f.func++) {
			struct pci_func af = f;
f010746d:	b9 12 00 00 00       	mov    $0x12,%ecx
f0107472:	89 df                	mov    %ebx,%edi
f0107474:	8b b5 00 ff ff ff    	mov    -0x100(%ebp),%esi
f010747a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f010747c:	ba 00 00 00 00       	mov    $0x0,%edx
f0107481:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0107487:	e8 10 ff ff ff       	call   f010739c <pci_conf_read>
f010748c:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0107492:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0107496:	0f 84 dd 00 00 00    	je     f0107579 <pci_scan_bus+0x1b5>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f010749c:	ba 3c 00 00 00       	mov    $0x3c,%edx
f01074a1:	89 d8                	mov    %ebx,%eax
f01074a3:	e8 f4 fe ff ff       	call   f010739c <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f01074a8:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f01074ab:	ba 08 00 00 00       	mov    $0x8,%edx
f01074b0:	89 d8                	mov    %ebx,%eax
f01074b2:	e8 e5 fe ff ff       	call   f010739c <pci_conf_read>
f01074b7:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01074bd:	89 c2                	mov    %eax,%edx
f01074bf:	c1 ea 18             	shr    $0x18,%edx
f01074c2:	83 fa 06             	cmp    $0x6,%edx
f01074c5:	77 09                	ja     f01074d0 <pci_scan_bus+0x10c>
		class = pci_class[PCI_CLASS(f->dev_class)];
f01074c7:	8b 34 95 fc 9d 10 f0 	mov    -0xfef6204(,%edx,4),%esi
f01074ce:	eb 05                	jmp    f01074d5 <pci_scan_bus+0x111>
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f01074d0:	be 88 9d 10 f0       	mov    $0xf0109d88,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01074d5:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01074db:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f01074df:	89 7c 24 24          	mov    %edi,0x24(%esp)
f01074e3:	89 74 24 20          	mov    %esi,0x20(%esp)
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
		PCI_CLASS(f->dev_class), PCI_SUBCLASS(f->dev_class), class,
f01074e7:	c1 e8 10             	shr    $0x10,%eax
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f01074ea:	25 ff 00 00 00       	and    $0xff,%eax
f01074ef:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01074f3:	89 54 24 18          	mov    %edx,0x18(%esp)
f01074f7:	89 c8                	mov    %ecx,%eax
f01074f9:	c1 e8 10             	shr    $0x10,%eax
f01074fc:	89 44 24 14          	mov    %eax,0x14(%esp)
f0107500:	81 e1 ff ff 00 00    	and    $0xffff,%ecx
f0107506:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010750a:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
f0107510:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107514:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
f010751a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010751e:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0107524:	8b 40 04             	mov    0x4(%eax),%eax
f0107527:	89 44 24 04          	mov    %eax,0x4(%esp)
f010752b:	c7 04 24 14 9c 10 f0 	movl   $0xf0109c14,(%esp)
f0107532:	e8 f7 c9 ff ff       	call   f0103f2e <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0107537:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
f010753d:	89 c2                	mov    %eax,%edx
f010753f:	c1 ea 10             	shr    $0x10,%edx

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0107542:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0107548:	c1 e8 18             	shr    $0x18,%eax
			af.irq_line = PCI_INTERRUPT_LINE(intr);

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
			if (pci_show_devs)
				pci_print_func(&af);
			pci_attach(&af);
f010754b:	89 1c 24             	mov    %ebx,(%esp)

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f010754e:	b9 0c d4 12 f0       	mov    $0xf012d40c,%ecx
f0107553:	e8 e4 fc ff ff       	call   f010723c <pci_attach_match>
}

static int
pci_attach(struct pci_func *f)
{
	return
f0107558:	85 c0                	test   %eax,%eax
f010755a:	75 1d                	jne    f0107579 <pci_scan_bus+0x1b5>
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f010755c:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0107562:	89 c2                	mov    %eax,%edx
f0107564:	c1 ea 10             	shr    $0x10,%edx
f0107567:	25 ff ff 00 00       	and    $0xffff,%eax
			af.irq_line = PCI_INTERRUPT_LINE(intr);

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
			if (pci_show_devs)
				pci_print_func(&af);
			pci_attach(&af);
f010756c:	89 1c 24             	mov    %ebx,(%esp)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f010756f:	b9 f4 d3 12 f0       	mov    $0xf012d3f4,%ecx
f0107574:	e8 c3 fc ff ff       	call   f010723c <pci_attach_match>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0107579:	ff 85 18 ff ff ff    	incl   -0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f010757f:	83 bd fc fe ff ff 01 	cmpl   $0x1,-0x104(%ebp)
f0107586:	19 c0                	sbb    %eax,%eax
f0107588:	83 e0 f9             	and    $0xfffffff9,%eax
f010758b:	83 c0 08             	add    $0x8,%eax
f010758e:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f0107594:	0f 87 d3 fe ff ff    	ja     f010746d <pci_scan_bus+0xa9>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f010759a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010759d:	40                   	inc    %eax
f010759e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01075a1:	83 f8 1f             	cmp    $0x1f,%eax
f01075a4:	0f 86 6c fe ff ff    	jbe    f0107416 <pci_scan_bus+0x52>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f01075aa:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
f01075b0:	81 c4 2c 01 00 00    	add    $0x12c,%esp
f01075b6:	5b                   	pop    %ebx
f01075b7:	5e                   	pop    %esi
f01075b8:	5f                   	pop    %edi
f01075b9:	5d                   	pop    %ebp
f01075ba:	c3                   	ret    

f01075bb <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f01075bb:	55                   	push   %ebp
f01075bc:	89 e5                	mov    %esp,%ebp
f01075be:	57                   	push   %edi
f01075bf:	56                   	push   %esi
f01075c0:	53                   	push   %ebx
f01075c1:	83 ec 3c             	sub    $0x3c,%esp
f01075c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f01075c7:	ba 1c 00 00 00       	mov    $0x1c,%edx
f01075cc:	89 d8                	mov    %ebx,%eax
f01075ce:	e8 c9 fd ff ff       	call   f010739c <pci_conf_read>
f01075d3:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f01075d5:	ba 18 00 00 00       	mov    $0x18,%edx
f01075da:	89 d8                	mov    %ebx,%eax
f01075dc:	e8 bb fd ff ff       	call   f010739c <pci_conf_read>
f01075e1:	89 c6                	mov    %eax,%esi

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f01075e3:	83 e7 0f             	and    $0xf,%edi
f01075e6:	83 ff 01             	cmp    $0x1,%edi
f01075e9:	75 2a                	jne    f0107615 <pci_bridge_attach+0x5a>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01075eb:	8b 43 08             	mov    0x8(%ebx),%eax
f01075ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01075f2:	8b 43 04             	mov    0x4(%ebx),%eax
f01075f5:	89 44 24 08          	mov    %eax,0x8(%esp)
			pcif->bus->busno, pcif->dev, pcif->func);
f01075f9:	8b 03                	mov    (%ebx),%eax
{
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f01075fb:	8b 40 04             	mov    0x4(%eax),%eax
f01075fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107602:	c7 04 24 50 9c 10 f0 	movl   $0xf0109c50,(%esp)
f0107609:	e8 20 c9 ff ff       	call   f0103f2e <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f010760e:	b8 00 00 00 00       	mov    $0x0,%eax
f0107613:	eb 66                	jmp    f010767b <pci_bridge_attach+0xc0>
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0107615:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f010761c:	00 
f010761d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107624:	00 
f0107625:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0107628:	89 3c 24             	mov    %edi,(%esp)
f010762b:	e8 3e ec ff ff       	call   f010626e <memset>
	nbus.parent_bridge = pcif;
f0107630:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0107633:	89 f2                	mov    %esi,%edx
f0107635:	0f b6 c6             	movzbl %dh,%eax
f0107638:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);
f010763b:	c1 ee 10             	shr    $0x10,%esi
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010763e:	81 e6 ff 00 00 00    	and    $0xff,%esi
f0107644:	89 74 24 14          	mov    %esi,0x14(%esp)
f0107648:	89 44 24 10          	mov    %eax,0x10(%esp)
f010764c:	8b 43 08             	mov    0x8(%ebx),%eax
f010764f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107653:	8b 43 04             	mov    0x4(%ebx),%eax
f0107656:	89 44 24 08          	mov    %eax,0x8(%esp)
			pcif->bus->busno, pcif->dev, pcif->func,
f010765a:	8b 03                	mov    (%ebx),%eax
	memset(&nbus, 0, sizeof(nbus));
	nbus.parent_bridge = pcif;
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010765c:	8b 40 04             	mov    0x4(%eax),%eax
f010765f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107663:	c7 04 24 84 9c 10 f0 	movl   $0xf0109c84,(%esp)
f010766a:	e8 bf c8 ff ff       	call   f0103f2e <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f010766f:	89 f8                	mov    %edi,%eax
f0107671:	e8 4e fd ff ff       	call   f01073c4 <pci_scan_bus>
	return 1;
f0107676:	b8 01 00 00 00       	mov    $0x1,%eax
}
f010767b:	83 c4 3c             	add    $0x3c,%esp
f010767e:	5b                   	pop    %ebx
f010767f:	5e                   	pop    %esi
f0107680:	5f                   	pop    %edi
f0107681:	5d                   	pop    %ebp
f0107682:	c3                   	ret    

f0107683 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0107683:	55                   	push   %ebp
f0107684:	89 e5                	mov    %esp,%ebp
f0107686:	56                   	push   %esi
f0107687:	53                   	push   %ebx
f0107688:	83 ec 10             	sub    $0x10,%esp
f010768b:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f010768d:	8b 48 08             	mov    0x8(%eax),%ecx
f0107690:	8b 58 04             	mov    0x4(%eax),%ebx
f0107693:	8b 00                	mov    (%eax),%eax
f0107695:	8b 40 04             	mov    0x4(%eax),%eax
f0107698:	89 14 24             	mov    %edx,(%esp)
f010769b:	89 da                	mov    %ebx,%edx
f010769d:	e8 fe fb ff ff       	call   f01072a0 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01076a2:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01076a7:	89 f0                	mov    %esi,%eax
f01076a9:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f01076aa:	83 c4 10             	add    $0x10,%esp
f01076ad:	5b                   	pop    %ebx
f01076ae:	5e                   	pop    %esi
f01076af:	5d                   	pop    %ebp
f01076b0:	c3                   	ret    

f01076b1 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f01076b1:	55                   	push   %ebp
f01076b2:	89 e5                	mov    %esp,%ebp
f01076b4:	57                   	push   %edi
f01076b5:	56                   	push   %esi
f01076b6:	53                   	push   %ebx
f01076b7:	83 ec 4c             	sub    $0x4c,%esp
f01076ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f01076bd:	b9 07 00 00 00       	mov    $0x7,%ecx
f01076c2:	ba 04 00 00 00       	mov    $0x4,%edx
f01076c7:	89 d8                	mov    %ebx,%eax
f01076c9:	e8 b5 ff ff ff       	call   f0107683 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01076ce:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f01076d3:	89 f2                	mov    %esi,%edx
f01076d5:	89 d8                	mov    %ebx,%eax
f01076d7:	e8 c0 fc ff ff       	call   f010739c <pci_conf_read>
f01076dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f01076df:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f01076e4:	89 f2                	mov    %esi,%edx
f01076e6:	89 d8                	mov    %ebx,%eax
f01076e8:	e8 96 ff ff ff       	call   f0107683 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f01076ed:	89 f2                	mov    %esi,%edx
f01076ef:	89 d8                	mov    %ebx,%eax
f01076f1:	e8 a6 fc ff ff       	call   f010739c <pci_conf_read>

		if (rv == 0)
f01076f6:	85 c0                	test   %eax,%eax
f01076f8:	0f 84 c7 00 00 00    	je     f01077c5 <pci_func_enable+0x114>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f01076fe:	8d 56 f0             	lea    -0x10(%esi),%edx
f0107701:	c1 ea 02             	shr    $0x2,%edx
f0107704:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0107707:	a8 01                	test   $0x1,%al
f0107709:	75 2c                	jne    f0107737 <pci_func_enable+0x86>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f010770b:	89 c2                	mov    %eax,%edx
f010770d:	83 e2 06             	and    $0x6,%edx
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0107710:	83 fa 04             	cmp    $0x4,%edx
f0107713:	0f 94 c2             	sete   %dl
f0107716:	0f b6 d2             	movzbl %dl,%edx
f0107719:	8d 3c 95 04 00 00 00 	lea    0x4(,%edx,4),%edi
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
				bar_width = 8;

			size = PCI_MAPREG_MEM_SIZE(rv);
f0107720:	83 e0 f0             	and    $0xfffffff0,%eax
f0107723:	89 c2                	mov    %eax,%edx
f0107725:	f7 da                	neg    %edx
f0107727:	21 d0                	and    %edx,%eax
f0107729:	89 45 dc             	mov    %eax,-0x24(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f010772c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010772f:	83 e0 f0             	and    $0xfffffff0,%eax
f0107732:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0107735:	eb 1a                	jmp    f0107751 <pci_func_enable+0xa0>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0107737:	83 e0 fc             	and    $0xfffffffc,%eax
f010773a:	89 c2                	mov    %eax,%edx
f010773c:	f7 da                	neg    %edx
f010773e:	21 d0                	and    %edx,%eax
f0107740:	89 45 dc             	mov    %eax,-0x24(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0107743:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107746:	83 e2 fc             	and    $0xfffffffc,%edx
f0107749:	89 55 d8             	mov    %edx,-0x28(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f010774c:	bf 04 00 00 00       	mov    $0x4,%edi
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0107751:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0107754:	89 f2                	mov    %esi,%edx
f0107756:	89 d8                	mov    %ebx,%eax
f0107758:	e8 26 ff ff ff       	call   f0107683 <pci_conf_write>
		f->reg_base[regnum] = base;
f010775d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107760:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107763:	89 54 83 14          	mov    %edx,0x14(%ebx,%eax,4)
		f->reg_size[regnum] = size;
f0107767:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010776a:	89 54 83 2c          	mov    %edx,0x2c(%ebx,%eax,4)

		if (size && !base)
f010776e:	85 d2                	test   %edx,%edx
f0107770:	74 58                	je     f01077ca <pci_func_enable+0x119>
f0107772:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0107776:	75 52                	jne    f01077ca <pci_func_enable+0x119>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0107778:	8b 43 0c             	mov    0xc(%ebx),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f010777b:	89 54 24 20          	mov    %edx,0x20(%esp)
f010777f:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f0107786:	00 
f0107787:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010778a:	89 54 24 18          	mov    %edx,0x18(%esp)
f010778e:	89 c2                	mov    %eax,%edx
f0107790:	c1 ea 10             	shr    $0x10,%edx
f0107793:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107797:	25 ff ff 00 00       	and    $0xffff,%eax
f010779c:	89 44 24 10          	mov    %eax,0x10(%esp)
f01077a0:	8b 43 08             	mov    0x8(%ebx),%eax
f01077a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01077a7:	8b 43 04             	mov    0x4(%ebx),%eax
f01077aa:	89 44 24 08          	mov    %eax,0x8(%esp)
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
f01077ae:	8b 03                	mov    (%ebx),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f01077b0:	8b 40 04             	mov    0x4(%eax),%eax
f01077b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01077b7:	c7 04 24 b4 9c 10 f0 	movl   $0xf0109cb4,(%esp)
f01077be:	e8 6b c7 ff ff       	call   f0103f2e <cprintf>
f01077c3:	eb 05                	jmp    f01077ca <pci_func_enable+0x119>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f01077c5:	bf 04 00 00 00       	mov    $0x4,%edi
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f01077ca:	01 fe                	add    %edi,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01077cc:	83 fe 27             	cmp    $0x27,%esi
f01077cf:	0f 86 fe fe ff ff    	jbe    f01076d3 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f01077d5:	8b 43 0c             	mov    0xc(%ebx),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f01077d8:	89 c2                	mov    %eax,%edx
f01077da:	c1 ea 10             	shr    $0x10,%edx
f01077dd:	89 54 24 14          	mov    %edx,0x14(%esp)
f01077e1:	25 ff ff 00 00       	and    $0xffff,%eax
f01077e6:	89 44 24 10          	mov    %eax,0x10(%esp)
f01077ea:	8b 43 08             	mov    0x8(%ebx),%eax
f01077ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01077f1:	8b 43 04             	mov    0x4(%ebx),%eax
f01077f4:	89 44 24 08          	mov    %eax,0x8(%esp)
		f->bus->busno, f->dev, f->func,
f01077f8:	8b 03                	mov    (%ebx),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f01077fa:	8b 40 04             	mov    0x4(%eax),%eax
f01077fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107801:	c7 04 24 10 9d 10 f0 	movl   $0xf0109d10,(%esp)
f0107808:	e8 21 c7 ff ff       	call   f0103f2e <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f010780d:	83 c4 4c             	add    $0x4c,%esp
f0107810:	5b                   	pop    %ebx
f0107811:	5e                   	pop    %esi
f0107812:	5f                   	pop    %edi
f0107813:	5d                   	pop    %ebp
f0107814:	c3                   	ret    

f0107815 <pci_network_attach>:
	pci_scan_bus(&nbus);
	return 1;
}

static int 
pci_network_attach(struct pci_func *pcif){
f0107815:	55                   	push   %ebp
f0107816:	89 e5                	mov    %esp,%ebp
f0107818:	53                   	push   %ebx
f0107819:	83 ec 14             	sub    $0x14,%esp
f010781c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f010781f:	89 1c 24             	mov    %ebx,(%esp)
f0107822:	e8 8a fe ff ff       	call   f01076b1 <pci_func_enable>
	return e1000_init(pcif);			
f0107827:	89 1c 24             	mov    %ebx,(%esp)
f010782a:	e8 be f6 ff ff       	call   f0106eed <e1000_init>
}
f010782f:	83 c4 14             	add    $0x14,%esp
f0107832:	5b                   	pop    %ebx
f0107833:	5d                   	pop    %ebp
f0107834:	c3                   	ret    

f0107835 <pci_init>:
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}

int
pci_init(void)
{
f0107835:	55                   	push   %ebp
f0107836:	89 e5                	mov    %esp,%ebp
f0107838:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f010783b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107842:	00 
f0107843:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010784a:	00 
f010784b:	c7 04 24 80 8e 29 f0 	movl   $0xf0298e80,(%esp)
f0107852:	e8 17 ea ff ff       	call   f010626e <memset>

	return pci_scan_bus(&root_bus);
f0107857:	b8 80 8e 29 f0       	mov    $0xf0298e80,%eax
f010785c:	e8 63 fb ff ff       	call   f01073c4 <pci_scan_bus>
}
f0107861:	c9                   	leave  
f0107862:	c3                   	ret    
	...

f0107864 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0107864:	55                   	push   %ebp
f0107865:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0107867:	c7 05 88 8e 29 f0 00 	movl   $0x0,0xf0298e88
f010786e:	00 00 00 
}
f0107871:	5d                   	pop    %ebp
f0107872:	c3                   	ret    

f0107873 <time_tick>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0107873:	55                   	push   %ebp
f0107874:	89 e5                	mov    %esp,%ebp
f0107876:	83 ec 18             	sub    $0x18,%esp
	ticks++;
f0107879:	a1 88 8e 29 f0       	mov    0xf0298e88,%eax
f010787e:	40                   	inc    %eax
f010787f:	a3 88 8e 29 f0       	mov    %eax,0xf0298e88
	if (ticks * 10 < ticks)
f0107884:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0107887:	d1 e2                	shl    %edx
f0107889:	39 d0                	cmp    %edx,%eax
f010788b:	76 1c                	jbe    f01078a9 <time_tick+0x36>
		panic("time_tick: time overflowed");
f010788d:	c7 44 24 08 18 9e 10 	movl   $0xf0109e18,0x8(%esp)
f0107894:	f0 
f0107895:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f010789c:	00 
f010789d:	c7 04 24 33 9e 10 f0 	movl   $0xf0109e33,(%esp)
f01078a4:	e8 97 87 ff ff       	call   f0100040 <_panic>
}
f01078a9:	c9                   	leave  
f01078aa:	c3                   	ret    

f01078ab <time_msec>:

unsigned int
time_msec(void)
{
f01078ab:	55                   	push   %ebp
f01078ac:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f01078ae:	a1 88 8e 29 f0       	mov    0xf0298e88,%eax
f01078b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01078b6:	d1 e0                	shl    %eax
}
f01078b8:	5d                   	pop    %ebp
f01078b9:	c3                   	ret    
	...

f01078bc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01078bc:	55                   	push   %ebp
f01078bd:	57                   	push   %edi
f01078be:	56                   	push   %esi
f01078bf:	83 ec 10             	sub    $0x10,%esp
f01078c2:	8b 74 24 20          	mov    0x20(%esp),%esi
f01078c6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01078ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01078ce:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f01078d2:	89 cd                	mov    %ecx,%ebp
f01078d4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01078d8:	85 c0                	test   %eax,%eax
f01078da:	75 2c                	jne    f0107908 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01078dc:	39 f9                	cmp    %edi,%ecx
f01078de:	77 68                	ja     f0107948 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01078e0:	85 c9                	test   %ecx,%ecx
f01078e2:	75 0b                	jne    f01078ef <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01078e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01078e9:	31 d2                	xor    %edx,%edx
f01078eb:	f7 f1                	div    %ecx
f01078ed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01078ef:	31 d2                	xor    %edx,%edx
f01078f1:	89 f8                	mov    %edi,%eax
f01078f3:	f7 f1                	div    %ecx
f01078f5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01078f7:	89 f0                	mov    %esi,%eax
f01078f9:	f7 f1                	div    %ecx
f01078fb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f01078fd:	89 f0                	mov    %esi,%eax
f01078ff:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0107901:	83 c4 10             	add    $0x10,%esp
f0107904:	5e                   	pop    %esi
f0107905:	5f                   	pop    %edi
f0107906:	5d                   	pop    %ebp
f0107907:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0107908:	39 f8                	cmp    %edi,%eax
f010790a:	77 2c                	ja     f0107938 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010790c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f010790f:	83 f6 1f             	xor    $0x1f,%esi
f0107912:	75 4c                	jne    f0107960 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0107914:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0107916:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010791b:	72 0a                	jb     f0107927 <__udivdi3+0x6b>
f010791d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0107921:	0f 87 ad 00 00 00    	ja     f01079d4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0107927:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010792c:	89 f0                	mov    %esi,%eax
f010792e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0107930:	83 c4 10             	add    $0x10,%esp
f0107933:	5e                   	pop    %esi
f0107934:	5f                   	pop    %edi
f0107935:	5d                   	pop    %ebp
f0107936:	c3                   	ret    
f0107937:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0107938:	31 ff                	xor    %edi,%edi
f010793a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010793c:	89 f0                	mov    %esi,%eax
f010793e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0107940:	83 c4 10             	add    $0x10,%esp
f0107943:	5e                   	pop    %esi
f0107944:	5f                   	pop    %edi
f0107945:	5d                   	pop    %ebp
f0107946:	c3                   	ret    
f0107947:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0107948:	89 fa                	mov    %edi,%edx
f010794a:	89 f0                	mov    %esi,%eax
f010794c:	f7 f1                	div    %ecx
f010794e:	89 c6                	mov    %eax,%esi
f0107950:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0107952:	89 f0                	mov    %esi,%eax
f0107954:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0107956:	83 c4 10             	add    $0x10,%esp
f0107959:	5e                   	pop    %esi
f010795a:	5f                   	pop    %edi
f010795b:	5d                   	pop    %ebp
f010795c:	c3                   	ret    
f010795d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0107960:	89 f1                	mov    %esi,%ecx
f0107962:	d3 e0                	shl    %cl,%eax
f0107964:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0107968:	b8 20 00 00 00       	mov    $0x20,%eax
f010796d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f010796f:	89 ea                	mov    %ebp,%edx
f0107971:	88 c1                	mov    %al,%cl
f0107973:	d3 ea                	shr    %cl,%edx
f0107975:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0107979:	09 ca                	or     %ecx,%edx
f010797b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f010797f:	89 f1                	mov    %esi,%ecx
f0107981:	d3 e5                	shl    %cl,%ebp
f0107983:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0107987:	89 fd                	mov    %edi,%ebp
f0107989:	88 c1                	mov    %al,%cl
f010798b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f010798d:	89 fa                	mov    %edi,%edx
f010798f:	89 f1                	mov    %esi,%ecx
f0107991:	d3 e2                	shl    %cl,%edx
f0107993:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107997:	88 c1                	mov    %al,%cl
f0107999:	d3 ef                	shr    %cl,%edi
f010799b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010799d:	89 f8                	mov    %edi,%eax
f010799f:	89 ea                	mov    %ebp,%edx
f01079a1:	f7 74 24 08          	divl   0x8(%esp)
f01079a5:	89 d1                	mov    %edx,%ecx
f01079a7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01079a9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01079ad:	39 d1                	cmp    %edx,%ecx
f01079af:	72 17                	jb     f01079c8 <__udivdi3+0x10c>
f01079b1:	74 09                	je     f01079bc <__udivdi3+0x100>
f01079b3:	89 fe                	mov    %edi,%esi
f01079b5:	31 ff                	xor    %edi,%edi
f01079b7:	e9 41 ff ff ff       	jmp    f01078fd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01079bc:	8b 54 24 04          	mov    0x4(%esp),%edx
f01079c0:	89 f1                	mov    %esi,%ecx
f01079c2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01079c4:	39 c2                	cmp    %eax,%edx
f01079c6:	73 eb                	jae    f01079b3 <__udivdi3+0xf7>
		{
		  q0--;
f01079c8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01079cb:	31 ff                	xor    %edi,%edi
f01079cd:	e9 2b ff ff ff       	jmp    f01078fd <__udivdi3+0x41>
f01079d2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01079d4:	31 f6                	xor    %esi,%esi
f01079d6:	e9 22 ff ff ff       	jmp    f01078fd <__udivdi3+0x41>
	...

f01079dc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01079dc:	55                   	push   %ebp
f01079dd:	57                   	push   %edi
f01079de:	56                   	push   %esi
f01079df:	83 ec 20             	sub    $0x20,%esp
f01079e2:	8b 44 24 30          	mov    0x30(%esp),%eax
f01079e6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01079ea:	89 44 24 14          	mov    %eax,0x14(%esp)
f01079ee:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f01079f2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01079f6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01079fa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f01079fc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01079fe:	85 ed                	test   %ebp,%ebp
f0107a00:	75 16                	jne    f0107a18 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0107a02:	39 f1                	cmp    %esi,%ecx
f0107a04:	0f 86 a6 00 00 00    	jbe    f0107ab0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0107a0a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0107a0c:	89 d0                	mov    %edx,%eax
f0107a0e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0107a10:	83 c4 20             	add    $0x20,%esp
f0107a13:	5e                   	pop    %esi
f0107a14:	5f                   	pop    %edi
f0107a15:	5d                   	pop    %ebp
f0107a16:	c3                   	ret    
f0107a17:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0107a18:	39 f5                	cmp    %esi,%ebp
f0107a1a:	0f 87 ac 00 00 00    	ja     f0107acc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0107a20:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0107a23:	83 f0 1f             	xor    $0x1f,%eax
f0107a26:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107a2a:	0f 84 a8 00 00 00    	je     f0107ad8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0107a30:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0107a34:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0107a36:	bf 20 00 00 00       	mov    $0x20,%edi
f0107a3b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0107a3f:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107a43:	89 f9                	mov    %edi,%ecx
f0107a45:	d3 e8                	shr    %cl,%eax
f0107a47:	09 e8                	or     %ebp,%eax
f0107a49:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0107a4d:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0107a51:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0107a55:	d3 e0                	shl    %cl,%eax
f0107a57:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0107a5b:	89 f2                	mov    %esi,%edx
f0107a5d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0107a5f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0107a63:	d3 e0                	shl    %cl,%eax
f0107a65:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0107a69:	8b 44 24 14          	mov    0x14(%esp),%eax
f0107a6d:	89 f9                	mov    %edi,%ecx
f0107a6f:	d3 e8                	shr    %cl,%eax
f0107a71:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0107a73:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0107a75:	89 f2                	mov    %esi,%edx
f0107a77:	f7 74 24 18          	divl   0x18(%esp)
f0107a7b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0107a7d:	f7 64 24 0c          	mull   0xc(%esp)
f0107a81:	89 c5                	mov    %eax,%ebp
f0107a83:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0107a85:	39 d6                	cmp    %edx,%esi
f0107a87:	72 67                	jb     f0107af0 <__umoddi3+0x114>
f0107a89:	74 75                	je     f0107b00 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0107a8b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0107a8f:	29 e8                	sub    %ebp,%eax
f0107a91:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0107a93:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0107a97:	d3 e8                	shr    %cl,%eax
f0107a99:	89 f2                	mov    %esi,%edx
f0107a9b:	89 f9                	mov    %edi,%ecx
f0107a9d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0107a9f:	09 d0                	or     %edx,%eax
f0107aa1:	89 f2                	mov    %esi,%edx
f0107aa3:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0107aa7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0107aa9:	83 c4 20             	add    $0x20,%esp
f0107aac:	5e                   	pop    %esi
f0107aad:	5f                   	pop    %edi
f0107aae:	5d                   	pop    %ebp
f0107aaf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0107ab0:	85 c9                	test   %ecx,%ecx
f0107ab2:	75 0b                	jne    f0107abf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0107ab4:	b8 01 00 00 00       	mov    $0x1,%eax
f0107ab9:	31 d2                	xor    %edx,%edx
f0107abb:	f7 f1                	div    %ecx
f0107abd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0107abf:	89 f0                	mov    %esi,%eax
f0107ac1:	31 d2                	xor    %edx,%edx
f0107ac3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0107ac5:	89 f8                	mov    %edi,%eax
f0107ac7:	e9 3e ff ff ff       	jmp    f0107a0a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0107acc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0107ace:	83 c4 20             	add    $0x20,%esp
f0107ad1:	5e                   	pop    %esi
f0107ad2:	5f                   	pop    %edi
f0107ad3:	5d                   	pop    %ebp
f0107ad4:	c3                   	ret    
f0107ad5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0107ad8:	39 f5                	cmp    %esi,%ebp
f0107ada:	72 04                	jb     f0107ae0 <__umoddi3+0x104>
f0107adc:	39 f9                	cmp    %edi,%ecx
f0107ade:	77 06                	ja     f0107ae6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0107ae0:	89 f2                	mov    %esi,%edx
f0107ae2:	29 cf                	sub    %ecx,%edi
f0107ae4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0107ae6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0107ae8:	83 c4 20             	add    $0x20,%esp
f0107aeb:	5e                   	pop    %esi
f0107aec:	5f                   	pop    %edi
f0107aed:	5d                   	pop    %ebp
f0107aee:	c3                   	ret    
f0107aef:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0107af0:	89 d1                	mov    %edx,%ecx
f0107af2:	89 c5                	mov    %eax,%ebp
f0107af4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0107af8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0107afc:	eb 8d                	jmp    f0107a8b <__umoddi3+0xaf>
f0107afe:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0107b00:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0107b04:	72 ea                	jb     f0107af0 <__umoddi3+0x114>
f0107b06:	89 f1                	mov    %esi,%ecx
f0107b08:	eb 81                	jmp    f0107a8b <__umoddi3+0xaf>
