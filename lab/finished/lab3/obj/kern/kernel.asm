
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
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
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
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 50 6e 1e f0       	mov    $0xf01e6e50,%eax
f010004b:	2d 51 5f 1e f0       	sub    $0xf01e5f51,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 51 5f 1e f0 	movl   $0xf01e5f51,(%esp)
f0100063:	e8 5a 4d 00 00       	call   f0104dc2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 6a 04 00 00       	call   f01004d7 <cons_init>

	//cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
	mem_init();
f010006d:	e8 22 11 00 00       	call   f0101194 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100072:	e8 54 30 00 00       	call   f01030cb <env_init>
	trap_init();
f0100077:	e8 51 37 00 00       	call   f01037cd <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010007c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100083:	00 
f0100084:	c7 04 24 23 9e 1a f0 	movl   $0xf01a9e23,(%esp)
f010008b:	e8 2d 32 00 00       	call   f01032bd <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100090:	a1 ac 61 1e f0       	mov    0xf01e61ac,%eax
f0100095:	89 04 24             	mov    %eax,(%esp)
f0100098:	e8 df 35 00 00       	call   f010367c <env_run>

f010009d <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	56                   	push   %esi
f01000a1:	53                   	push   %ebx
f01000a2:	83 ec 10             	sub    $0x10,%esp
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 40 6e 1e f0 00 	cmpl   $0x0,0xf01e6e40
f01000af:	75 3d                	jne    f01000ee <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 40 6e 1e f0    	mov    %esi,0xf01e6e40

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01000c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000ca:	c7 04 24 20 52 10 f0 	movl   $0xf0105220,(%esp)
f01000d1:	e8 80 36 00 00       	call   f0103756 <cprintf>
	vcprintf(fmt, ap);
f01000d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000da:	89 34 24             	mov    %esi,(%esp)
f01000dd:	e8 41 36 00 00       	call   f0103723 <vcprintf>
	cprintf("\n");
f01000e2:	c7 04 24 72 62 10 f0 	movl   $0xf0106272,(%esp)
f01000e9:	e8 68 36 00 00       	call   f0103756 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f5:	e8 b5 06 00 00       	call   f01007af <monitor>
f01000fa:	eb f2                	jmp    f01000ee <_panic+0x51>

f01000fc <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000fc:	55                   	push   %ebp
f01000fd:	89 e5                	mov    %esp,%ebp
f01000ff:	53                   	push   %ebx
f0100100:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100103:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100106:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100109:	89 44 24 08          	mov    %eax,0x8(%esp)
f010010d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100110:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100114:	c7 04 24 38 52 10 f0 	movl   $0xf0105238,(%esp)
f010011b:	e8 36 36 00 00       	call   f0103756 <cprintf>
	vcprintf(fmt, ap);
f0100120:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100124:	8b 45 10             	mov    0x10(%ebp),%eax
f0100127:	89 04 24             	mov    %eax,(%esp)
f010012a:	e8 f4 35 00 00       	call   f0103723 <vcprintf>
	cprintf("\n");
f010012f:	c7 04 24 72 62 10 f0 	movl   $0xf0106272,(%esp)
f0100136:	e8 1b 36 00 00       	call   f0103756 <cprintf>
	va_end(ap);
}
f010013b:	83 c4 14             	add    $0x14,%esp
f010013e:	5b                   	pop    %ebx
f010013f:	5d                   	pop    %ebp
f0100140:	c3                   	ret    
f0100141:	00 00                	add    %al,(%eax)
	...

f0100144 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100144:	55                   	push   %ebp
f0100145:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100147:	ba 84 00 00 00       	mov    $0x84,%edx
f010014c:	ec                   	in     (%dx),%al
f010014d:	ec                   	in     (%dx),%al
f010014e:	ec                   	in     (%dx),%al
f010014f:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100150:	5d                   	pop    %ebp
f0100151:	c3                   	ret    

f0100152 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100152:	55                   	push   %ebp
f0100153:	89 e5                	mov    %esp,%ebp
f0100155:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015b:	a8 01                	test   $0x1,%al
f010015d:	74 08                	je     f0100167 <serial_proc_data+0x15>
f010015f:	b2 f8                	mov    $0xf8,%dl
f0100161:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100162:	0f b6 c0             	movzbl %al,%eax
f0100165:	eb 05                	jmp    f010016c <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010016c:	5d                   	pop    %ebp
f010016d:	c3                   	ret    

f010016e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010016e:	55                   	push   %ebp
f010016f:	89 e5                	mov    %esp,%ebp
f0100171:	53                   	push   %ebx
f0100172:	83 ec 04             	sub    $0x4,%esp
f0100175:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100177:	eb 29                	jmp    f01001a2 <cons_intr+0x34>
		if (c == 0)
f0100179:	85 c0                	test   %eax,%eax
f010017b:	74 25                	je     f01001a2 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010017d:	8b 15 84 61 1e f0    	mov    0xf01e6184,%edx
f0100183:	88 82 80 5f 1e f0    	mov    %al,-0xfe1a080(%edx)
f0100189:	8d 42 01             	lea    0x1(%edx),%eax
f010018c:	a3 84 61 1e f0       	mov    %eax,0xf01e6184
		if (cons.wpos == CONSBUFSIZE)
f0100191:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100196:	75 0a                	jne    f01001a2 <cons_intr+0x34>
			cons.wpos = 0;
f0100198:	c7 05 84 61 1e f0 00 	movl   $0x0,0xf01e6184
f010019f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001a2:	ff d3                	call   *%ebx
f01001a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a7:	75 d0                	jne    f0100179 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001a9:	83 c4 04             	add    $0x4,%esp
f01001ac:	5b                   	pop    %ebx
f01001ad:	5d                   	pop    %ebp
f01001ae:	c3                   	ret    

f01001af <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001af:	55                   	push   %ebp
f01001b0:	89 e5                	mov    %esp,%ebp
f01001b2:	57                   	push   %edi
f01001b3:	56                   	push   %esi
f01001b4:	53                   	push   %ebx
f01001b5:	83 ec 2c             	sub    $0x2c,%esp
f01001b8:	89 c6                	mov    %eax,%esi
f01001ba:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001bf:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001c4:	eb 05                	jmp    f01001cb <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001c6:	e8 79 ff ff ff       	call   f0100144 <delay>
f01001cb:	89 fa                	mov    %edi,%edx
f01001cd:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ce:	a8 20                	test   $0x20,%al
f01001d0:	75 03                	jne    f01001d5 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001d2:	4b                   	dec    %ebx
f01001d3:	75 f1                	jne    f01001c6 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001d5:	89 f2                	mov    %esi,%edx
f01001d7:	89 f0                	mov    %esi,%eax
f01001d9:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e1:	ee                   	out    %al,(%dx)
f01001e2:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e7:	bf 79 03 00 00       	mov    $0x379,%edi
f01001ec:	eb 05                	jmp    f01001f3 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01001ee:	e8 51 ff ff ff       	call   f0100144 <delay>
f01001f3:	89 fa                	mov    %edi,%edx
f01001f5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001f6:	84 c0                	test   %al,%al
f01001f8:	78 03                	js     f01001fd <cons_putc+0x4e>
f01001fa:	4b                   	dec    %ebx
f01001fb:	75 f1                	jne    f01001ee <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001fd:	ba 78 03 00 00       	mov    $0x378,%edx
f0100202:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100205:	ee                   	out    %al,(%dx)
f0100206:	b2 7a                	mov    $0x7a,%dl
f0100208:	b0 0d                	mov    $0xd,%al
f010020a:	ee                   	out    %al,(%dx)
f010020b:	b0 08                	mov    $0x8,%al
f010020d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010020e:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100214:	75 06                	jne    f010021c <cons_putc+0x6d>
		c |= 0x0700;
f0100216:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f010021c:	89 f0                	mov    %esi,%eax
f010021e:	25 ff 00 00 00       	and    $0xff,%eax
f0100223:	83 f8 09             	cmp    $0x9,%eax
f0100226:	74 78                	je     f01002a0 <cons_putc+0xf1>
f0100228:	83 f8 09             	cmp    $0x9,%eax
f010022b:	7f 0b                	jg     f0100238 <cons_putc+0x89>
f010022d:	83 f8 08             	cmp    $0x8,%eax
f0100230:	0f 85 9e 00 00 00    	jne    f01002d4 <cons_putc+0x125>
f0100236:	eb 10                	jmp    f0100248 <cons_putc+0x99>
f0100238:	83 f8 0a             	cmp    $0xa,%eax
f010023b:	74 39                	je     f0100276 <cons_putc+0xc7>
f010023d:	83 f8 0d             	cmp    $0xd,%eax
f0100240:	0f 85 8e 00 00 00    	jne    f01002d4 <cons_putc+0x125>
f0100246:	eb 36                	jmp    f010027e <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f0100248:	66 a1 94 61 1e f0    	mov    0xf01e6194,%ax
f010024e:	66 85 c0             	test   %ax,%ax
f0100251:	0f 84 e2 00 00 00    	je     f0100339 <cons_putc+0x18a>
			crt_pos--;
f0100257:	48                   	dec    %eax
f0100258:	66 a3 94 61 1e f0    	mov    %ax,0xf01e6194
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010025e:	0f b7 c0             	movzwl %ax,%eax
f0100261:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100267:	83 ce 20             	or     $0x20,%esi
f010026a:	8b 15 90 61 1e f0    	mov    0xf01e6190,%edx
f0100270:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100274:	eb 78                	jmp    f01002ee <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100276:	66 83 05 94 61 1e f0 	addw   $0x50,0xf01e6194
f010027d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010027e:	66 8b 0d 94 61 1e f0 	mov    0xf01e6194,%cx
f0100285:	bb 50 00 00 00       	mov    $0x50,%ebx
f010028a:	89 c8                	mov    %ecx,%eax
f010028c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100291:	66 f7 f3             	div    %bx
f0100294:	66 29 d1             	sub    %dx,%cx
f0100297:	66 89 0d 94 61 1e f0 	mov    %cx,0xf01e6194
f010029e:	eb 4e                	jmp    f01002ee <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f01002a0:	b8 20 00 00 00       	mov    $0x20,%eax
f01002a5:	e8 05 ff ff ff       	call   f01001af <cons_putc>
		cons_putc(' ');
f01002aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01002af:	e8 fb fe ff ff       	call   f01001af <cons_putc>
		cons_putc(' ');
f01002b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b9:	e8 f1 fe ff ff       	call   f01001af <cons_putc>
		cons_putc(' ');
f01002be:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c3:	e8 e7 fe ff ff       	call   f01001af <cons_putc>
		cons_putc(' ');
f01002c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002cd:	e8 dd fe ff ff       	call   f01001af <cons_putc>
f01002d2:	eb 1a                	jmp    f01002ee <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002d4:	66 a1 94 61 1e f0    	mov    0xf01e6194,%ax
f01002da:	0f b7 c8             	movzwl %ax,%ecx
f01002dd:	8b 15 90 61 1e f0    	mov    0xf01e6190,%edx
f01002e3:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002e7:	40                   	inc    %eax
f01002e8:	66 a3 94 61 1e f0    	mov    %ax,0xf01e6194
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01002ee:	66 81 3d 94 61 1e f0 	cmpw   $0x7cf,0xf01e6194
f01002f5:	cf 07 
f01002f7:	76 40                	jbe    f0100339 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002f9:	a1 90 61 1e f0       	mov    0xf01e6190,%eax
f01002fe:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100305:	00 
f0100306:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010030c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100310:	89 04 24             	mov    %eax,(%esp)
f0100313:	e8 f4 4a 00 00       	call   f0104e0c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100318:	8b 15 90 61 1e f0    	mov    0xf01e6190,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010031e:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100323:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100329:	40                   	inc    %eax
f010032a:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010032f:	75 f2                	jne    f0100323 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100331:	66 83 2d 94 61 1e f0 	subw   $0x50,0xf01e6194
f0100338:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100339:	8b 0d 8c 61 1e f0    	mov    0xf01e618c,%ecx
f010033f:	b0 0e                	mov    $0xe,%al
f0100341:	89 ca                	mov    %ecx,%edx
f0100343:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100344:	66 8b 35 94 61 1e f0 	mov    0xf01e6194,%si
f010034b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010034e:	89 f0                	mov    %esi,%eax
f0100350:	66 c1 e8 08          	shr    $0x8,%ax
f0100354:	89 da                	mov    %ebx,%edx
f0100356:	ee                   	out    %al,(%dx)
f0100357:	b0 0f                	mov    $0xf,%al
f0100359:	89 ca                	mov    %ecx,%edx
f010035b:	ee                   	out    %al,(%dx)
f010035c:	89 f0                	mov    %esi,%eax
f010035e:	89 da                	mov    %ebx,%edx
f0100360:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100361:	83 c4 2c             	add    $0x2c,%esp
f0100364:	5b                   	pop    %ebx
f0100365:	5e                   	pop    %esi
f0100366:	5f                   	pop    %edi
f0100367:	5d                   	pop    %ebp
f0100368:	c3                   	ret    

f0100369 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100369:	55                   	push   %ebp
f010036a:	89 e5                	mov    %esp,%ebp
f010036c:	53                   	push   %ebx
f010036d:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100370:	ba 64 00 00 00       	mov    $0x64,%edx
f0100375:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100376:	a8 01                	test   $0x1,%al
f0100378:	0f 84 d8 00 00 00    	je     f0100456 <kbd_proc_data+0xed>
f010037e:	b2 60                	mov    $0x60,%dl
f0100380:	ec                   	in     (%dx),%al
f0100381:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100383:	3c e0                	cmp    $0xe0,%al
f0100385:	75 11                	jne    f0100398 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100387:	83 0d 88 61 1e f0 40 	orl    $0x40,0xf01e6188
		return 0;
f010038e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100393:	e9 c3 00 00 00       	jmp    f010045b <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100398:	84 c0                	test   %al,%al
f010039a:	79 33                	jns    f01003cf <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010039c:	8b 0d 88 61 1e f0    	mov    0xf01e6188,%ecx
f01003a2:	f6 c1 40             	test   $0x40,%cl
f01003a5:	75 05                	jne    f01003ac <kbd_proc_data+0x43>
f01003a7:	88 c2                	mov    %al,%dl
f01003a9:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003ac:	0f b6 d2             	movzbl %dl,%edx
f01003af:	8a 82 80 52 10 f0    	mov    -0xfefad80(%edx),%al
f01003b5:	83 c8 40             	or     $0x40,%eax
f01003b8:	0f b6 c0             	movzbl %al,%eax
f01003bb:	f7 d0                	not    %eax
f01003bd:	21 c1                	and    %eax,%ecx
f01003bf:	89 0d 88 61 1e f0    	mov    %ecx,0xf01e6188
		return 0;
f01003c5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ca:	e9 8c 00 00 00       	jmp    f010045b <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f01003cf:	8b 0d 88 61 1e f0    	mov    0xf01e6188,%ecx
f01003d5:	f6 c1 40             	test   $0x40,%cl
f01003d8:	74 0e                	je     f01003e8 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003da:	88 c2                	mov    %al,%dl
f01003dc:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003df:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003e2:	89 0d 88 61 1e f0    	mov    %ecx,0xf01e6188
	}

	shift |= shiftcode[data];
f01003e8:	0f b6 d2             	movzbl %dl,%edx
f01003eb:	0f b6 82 80 52 10 f0 	movzbl -0xfefad80(%edx),%eax
f01003f2:	0b 05 88 61 1e f0    	or     0xf01e6188,%eax
	shift ^= togglecode[data];
f01003f8:	0f b6 8a 80 53 10 f0 	movzbl -0xfefac80(%edx),%ecx
f01003ff:	31 c8                	xor    %ecx,%eax
f0100401:	a3 88 61 1e f0       	mov    %eax,0xf01e6188

	c = charcode[shift & (CTL | SHIFT)][data];
f0100406:	89 c1                	mov    %eax,%ecx
f0100408:	83 e1 03             	and    $0x3,%ecx
f010040b:	8b 0c 8d 80 54 10 f0 	mov    -0xfefab80(,%ecx,4),%ecx
f0100412:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100416:	a8 08                	test   $0x8,%al
f0100418:	74 18                	je     f0100432 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f010041a:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010041d:	83 fa 19             	cmp    $0x19,%edx
f0100420:	77 05                	ja     f0100427 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100422:	83 eb 20             	sub    $0x20,%ebx
f0100425:	eb 0b                	jmp    f0100432 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100427:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010042a:	83 fa 19             	cmp    $0x19,%edx
f010042d:	77 03                	ja     f0100432 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010042f:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100432:	f7 d0                	not    %eax
f0100434:	a8 06                	test   $0x6,%al
f0100436:	75 23                	jne    f010045b <kbd_proc_data+0xf2>
f0100438:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010043e:	75 1b                	jne    f010045b <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f0100440:	c7 04 24 52 52 10 f0 	movl   $0xf0105252,(%esp)
f0100447:	e8 0a 33 00 00       	call   f0103756 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044c:	ba 92 00 00 00       	mov    $0x92,%edx
f0100451:	b0 03                	mov    $0x3,%al
f0100453:	ee                   	out    %al,(%dx)
f0100454:	eb 05                	jmp    f010045b <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100456:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010045b:	89 d8                	mov    %ebx,%eax
f010045d:	83 c4 14             	add    $0x14,%esp
f0100460:	5b                   	pop    %ebx
f0100461:	5d                   	pop    %ebp
f0100462:	c3                   	ret    

f0100463 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100463:	55                   	push   %ebp
f0100464:	89 e5                	mov    %esp,%ebp
f0100466:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100469:	80 3d 60 5f 1e f0 00 	cmpb   $0x0,0xf01e5f60
f0100470:	74 0a                	je     f010047c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100472:	b8 52 01 10 f0       	mov    $0xf0100152,%eax
f0100477:	e8 f2 fc ff ff       	call   f010016e <cons_intr>
}
f010047c:	c9                   	leave  
f010047d:	c3                   	ret    

f010047e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010047e:	55                   	push   %ebp
f010047f:	89 e5                	mov    %esp,%ebp
f0100481:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100484:	b8 69 03 10 f0       	mov    $0xf0100369,%eax
f0100489:	e8 e0 fc ff ff       	call   f010016e <cons_intr>
}
f010048e:	c9                   	leave  
f010048f:	c3                   	ret    

f0100490 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100496:	e8 c8 ff ff ff       	call   f0100463 <serial_intr>
	kbd_intr();
f010049b:	e8 de ff ff ff       	call   f010047e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004a0:	8b 15 80 61 1e f0    	mov    0xf01e6180,%edx
f01004a6:	3b 15 84 61 1e f0    	cmp    0xf01e6184,%edx
f01004ac:	74 22                	je     f01004d0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004ae:	0f b6 82 80 5f 1e f0 	movzbl -0xfe1a080(%edx),%eax
f01004b5:	42                   	inc    %edx
f01004b6:	89 15 80 61 1e f0    	mov    %edx,0xf01e6180
		if (cons.rpos == CONSBUFSIZE)
f01004bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004c2:	75 11                	jne    f01004d5 <cons_getc+0x45>
			cons.rpos = 0;
f01004c4:	c7 05 80 61 1e f0 00 	movl   $0x0,0xf01e6180
f01004cb:	00 00 00 
f01004ce:	eb 05                	jmp    f01004d5 <cons_getc+0x45>
		return c;
	}
	return 0;
f01004d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004d5:	c9                   	leave  
f01004d6:	c3                   	ret    

f01004d7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004d7:	55                   	push   %ebp
f01004d8:	89 e5                	mov    %esp,%ebp
f01004da:	57                   	push   %edi
f01004db:	56                   	push   %esi
f01004dc:	53                   	push   %ebx
f01004dd:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004e0:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004e7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004ee:	5a a5 
	if (*cp != 0xA55A) {
f01004f0:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01004f6:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004fa:	74 11                	je     f010050d <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004fc:	c7 05 8c 61 1e f0 b4 	movl   $0x3b4,0xf01e618c
f0100503:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100506:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010050b:	eb 16                	jmp    f0100523 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010050d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100514:	c7 05 8c 61 1e f0 d4 	movl   $0x3d4,0xf01e618c
f010051b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010051e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100523:	8b 0d 8c 61 1e f0    	mov    0xf01e618c,%ecx
f0100529:	b0 0e                	mov    $0xe,%al
f010052b:	89 ca                	mov    %ecx,%edx
f010052d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010052e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100531:	89 da                	mov    %ebx,%edx
f0100533:	ec                   	in     (%dx),%al
f0100534:	0f b6 f8             	movzbl %al,%edi
f0100537:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010053a:	b0 0f                	mov    $0xf,%al
f010053c:	89 ca                	mov    %ecx,%edx
f010053e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010053f:	89 da                	mov    %ebx,%edx
f0100541:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100542:	89 35 90 61 1e f0    	mov    %esi,0xf01e6190

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100548:	0f b6 d8             	movzbl %al,%ebx
f010054b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010054d:	66 89 3d 94 61 1e f0 	mov    %di,0xf01e6194
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100554:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100559:	b0 00                	mov    $0x0,%al
f010055b:	89 da                	mov    %ebx,%edx
f010055d:	ee                   	out    %al,(%dx)
f010055e:	b2 fb                	mov    $0xfb,%dl
f0100560:	b0 80                	mov    $0x80,%al
f0100562:	ee                   	out    %al,(%dx)
f0100563:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100568:	b0 0c                	mov    $0xc,%al
f010056a:	89 ca                	mov    %ecx,%edx
f010056c:	ee                   	out    %al,(%dx)
f010056d:	b2 f9                	mov    $0xf9,%dl
f010056f:	b0 00                	mov    $0x0,%al
f0100571:	ee                   	out    %al,(%dx)
f0100572:	b2 fb                	mov    $0xfb,%dl
f0100574:	b0 03                	mov    $0x3,%al
f0100576:	ee                   	out    %al,(%dx)
f0100577:	b2 fc                	mov    $0xfc,%dl
f0100579:	b0 00                	mov    $0x0,%al
f010057b:	ee                   	out    %al,(%dx)
f010057c:	b2 f9                	mov    $0xf9,%dl
f010057e:	b0 01                	mov    $0x1,%al
f0100580:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100581:	b2 fd                	mov    $0xfd,%dl
f0100583:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100584:	3c ff                	cmp    $0xff,%al
f0100586:	0f 95 45 e7          	setne  -0x19(%ebp)
f010058a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010058d:	a2 60 5f 1e f0       	mov    %al,0xf01e5f60
f0100592:	89 da                	mov    %ebx,%edx
f0100594:	ec                   	in     (%dx),%al
f0100595:	89 ca                	mov    %ecx,%edx
f0100597:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100598:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010059c:	75 0c                	jne    f01005aa <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f010059e:	c7 04 24 5e 52 10 f0 	movl   $0xf010525e,(%esp)
f01005a5:	e8 ac 31 00 00       	call   f0103756 <cprintf>
}
f01005aa:	83 c4 2c             	add    $0x2c,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5e                   	pop    %esi
f01005af:	5f                   	pop    %edi
f01005b0:	5d                   	pop    %ebp
f01005b1:	c3                   	ret    

f01005b2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005b2:	55                   	push   %ebp
f01005b3:	89 e5                	mov    %esp,%ebp
f01005b5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005bb:	e8 ef fb ff ff       	call   f01001af <cons_putc>
}
f01005c0:	c9                   	leave  
f01005c1:	c3                   	ret    

f01005c2 <getchar>:

int
getchar(void)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005c8:	e8 c3 fe ff ff       	call   f0100490 <cons_getc>
f01005cd:	85 c0                	test   %eax,%eax
f01005cf:	74 f7                	je     f01005c8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005d1:	c9                   	leave  
f01005d2:	c3                   	ret    

f01005d3 <iscons>:

int
iscons(int fdnum)
{
f01005d3:	55                   	push   %ebp
f01005d4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01005d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005db:	5d                   	pop    %ebp
f01005dc:	c3                   	ret    
f01005dd:	00 00                	add    %al,(%eax)
	...

f01005e0 <continue_exec>:

/***** Implementations of basic kernel monitor commands *****/

int
continue_exec(int argc, char **argv, struct Trapframe *tf)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags &= ~FL_TF;
f01005e6:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	    return -1;
}
f01005ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01005f2:	5d                   	pop    %ebp
f01005f3:	c3                   	ret    

f01005f4 <single_step>:

int
single_step(int argc, char **argv, struct Trapframe *tf)
{
f01005f4:	55                   	push   %ebp
f01005f5:	89 e5                	mov    %esp,%ebp
f01005f7:	8b 45 10             	mov    0x10(%ebp),%eax
	tf->tf_eflags |= FL_TF;
f01005fa:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
		return -1;
}
f0100601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100606:	5d                   	pop    %ebp
f0100607:	c3                   	ret    

f0100608 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100608:	55                   	push   %ebp
f0100609:	89 e5                	mov    %esp,%ebp
f010060b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010060e:	c7 04 24 90 54 10 f0 	movl   $0xf0105490,(%esp)
f0100615:	e8 3c 31 00 00       	call   f0103756 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010061a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100621:	00 
f0100622:	c7 04 24 70 55 10 f0 	movl   $0xf0105570,(%esp)
f0100629:	e8 28 31 00 00       	call   f0103756 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010062e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100635:	00 
f0100636:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010063d:	f0 
f010063e:	c7 04 24 98 55 10 f0 	movl   $0xf0105598,(%esp)
f0100645:	e8 0c 31 00 00       	call   f0103756 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010064a:	c7 44 24 08 06 52 10 	movl   $0x105206,0x8(%esp)
f0100651:	00 
f0100652:	c7 44 24 04 06 52 10 	movl   $0xf0105206,0x4(%esp)
f0100659:	f0 
f010065a:	c7 04 24 bc 55 10 f0 	movl   $0xf01055bc,(%esp)
f0100661:	e8 f0 30 00 00       	call   f0103756 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100666:	c7 44 24 08 51 5f 1e 	movl   $0x1e5f51,0x8(%esp)
f010066d:	00 
f010066e:	c7 44 24 04 51 5f 1e 	movl   $0xf01e5f51,0x4(%esp)
f0100675:	f0 
f0100676:	c7 04 24 e0 55 10 f0 	movl   $0xf01055e0,(%esp)
f010067d:	e8 d4 30 00 00       	call   f0103756 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100682:	c7 44 24 08 50 6e 1e 	movl   $0x1e6e50,0x8(%esp)
f0100689:	00 
f010068a:	c7 44 24 04 50 6e 1e 	movl   $0xf01e6e50,0x4(%esp)
f0100691:	f0 
f0100692:	c7 04 24 04 56 10 f0 	movl   $0xf0105604,(%esp)
f0100699:	e8 b8 30 00 00       	call   f0103756 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010069e:	b8 4f 72 1e f0       	mov    $0xf01e724f,%eax
f01006a3:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006a8:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ad:	89 c2                	mov    %eax,%edx
f01006af:	85 c0                	test   %eax,%eax
f01006b1:	79 06                	jns    f01006b9 <mon_kerninfo+0xb1>
f01006b3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006b9:	c1 fa 0a             	sar    $0xa,%edx
f01006bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006c0:	c7 04 24 28 56 10 f0 	movl   $0xf0105628,(%esp)
f01006c7:	e8 8a 30 00 00       	call   f0103756 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d1:	c9                   	leave  
f01006d2:	c3                   	ret    

f01006d3 <mon_help>:
		return -1;
}

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006d3:	55                   	push   %ebp
f01006d4:	89 e5                	mov    %esp,%ebp
f01006d6:	53                   	push   %ebx
f01006d7:	83 ec 14             	sub    $0x14,%esp
f01006da:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006df:	8b 83 44 57 10 f0    	mov    -0xfefa8bc(%ebx),%eax
f01006e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006e9:	8b 83 40 57 10 f0    	mov    -0xfefa8c0(%ebx),%eax
f01006ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006f3:	c7 04 24 a9 54 10 f0 	movl   $0xf01054a9,(%esp)
f01006fa:	e8 57 30 00 00       	call   f0103756 <cprintf>
f01006ff:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100702:	83 fb 3c             	cmp    $0x3c,%ebx
f0100705:	75 d8                	jne    f01006df <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100707:	b8 00 00 00 00       	mov    $0x0,%eax
f010070c:	83 c4 14             	add    $0x14,%esp
f010070f:	5b                   	pop    %ebx
f0100710:	5d                   	pop    %ebp
f0100711:	c3                   	ret    

f0100712 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100712:	55                   	push   %ebp
f0100713:	89 e5                	mov    %esp,%ebp
f0100715:	57                   	push   %edi
f0100716:	56                   	push   %esi
f0100717:	53                   	push   %ebx
f0100718:	83 ec 6c             	sub    $0x6c,%esp
	// Your code here.
	
	int bt_cnt = 0;
	struct Eipdebuginfo eip_info;
	int* pre_ebp = (int *)read_ebp();
f010071b:	89 eb                	mov    %ebp,%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
f010071d:	c7 04 24 b2 54 10 f0 	movl   $0xf01054b2,(%esp)
f0100724:	e8 2d 30 00 00       	call   f0103756 <cprintf>
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	int bt_cnt = 0;
f0100729:	bf 00 00 00 00       	mov    $0x0,%edi
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f010072e:	eb 71                	jmp    f01007a1 <mon_backtrace+0x8f>
		bt_cnt++;
f0100730:	47                   	inc    %edi
		eip = (int)*(pre_ebp+1);
f0100731:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip((uintptr_t)eip, &eip_info);
f0100734:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100737:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073b:	89 34 24             	mov    %esi,(%esp)
f010073e:	e8 f6 3b 00 00       	call   f0104339 <debuginfo_eip>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
f0100743:	89 f0                	mov    %esi,%eax
f0100745:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100748:	89 44 24 30          	mov    %eax,0x30(%esp)
f010074c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010074f:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100753:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100756:	89 44 24 28          	mov    %eax,0x28(%esp)
f010075a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010075d:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100761:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100764:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100768:	8b 43 18             	mov    0x18(%ebx),%eax
f010076b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010076f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100772:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100776:	8b 43 10             	mov    0x10(%ebx),%eax
f0100779:	89 44 24 14          	mov    %eax,0x14(%esp)
f010077d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100780:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100784:	8b 43 08             	mov    0x8(%ebx),%eax
f0100787:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010078b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010078f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100793:	c7 04 24 54 56 10 f0 	movl   $0xf0105654,(%esp)
f010079a:	e8 b7 2f 00 00       	call   f0103756 <cprintf>
		
		pre_ebp = (int *)*pre_ebp;
f010079f:	8b 1b                	mov    (%ebx),%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f01007a1:	85 db                	test   %ebx,%ebx
f01007a3:	75 8b                	jne    f0100730 <mon_backtrace+0x1e>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
		
		pre_ebp = (int *)*pre_ebp;
	}
	return bt_cnt;
}
f01007a5:	89 f8                	mov    %edi,%eax
f01007a7:	83 c4 6c             	add    $0x6c,%esp
f01007aa:	5b                   	pop    %ebx
f01007ab:	5e                   	pop    %esi
f01007ac:	5f                   	pop    %edi
f01007ad:	5d                   	pop    %ebp
f01007ae:	c3                   	ret    

f01007af <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007af:	55                   	push   %ebp
f01007b0:	89 e5                	mov    %esp,%ebp
f01007b2:	57                   	push   %edi
f01007b3:	56                   	push   %esi
f01007b4:	53                   	push   %ebx
f01007b5:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b8:	c7 04 24 9c 56 10 f0 	movl   $0xf010569c,(%esp)
f01007bf:	e8 92 2f 00 00       	call   f0103756 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c4:	c7 04 24 c0 56 10 f0 	movl   $0xf01056c0,(%esp)
f01007cb:	e8 86 2f 00 00       	call   f0103756 <cprintf>

	if (tf != NULL)
f01007d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007d4:	74 0b                	je     f01007e1 <monitor+0x32>
		print_trapframe(tf);
f01007d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d9:	89 04 24             	mov    %eax,(%esp)
f01007dc:	e8 d0 34 00 00       	call   f0103cb1 <print_trapframe>
	
	while (1) {
		buf = readline("K> ");
f01007e1:	c7 04 24 c4 54 10 f0 	movl   $0xf01054c4,(%esp)
f01007e8:	e8 ab 43 00 00       	call   f0104b98 <readline>
f01007ed:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007ef:	85 c0                	test   %eax,%eax
f01007f1:	74 ee                	je     f01007e1 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007f3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007fa:	be 00 00 00 00       	mov    $0x0,%esi
f01007ff:	eb 04                	jmp    f0100805 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100801:	c6 03 00             	movb   $0x0,(%ebx)
f0100804:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100805:	8a 03                	mov    (%ebx),%al
f0100807:	84 c0                	test   %al,%al
f0100809:	74 5e                	je     f0100869 <monitor+0xba>
f010080b:	0f be c0             	movsbl %al,%eax
f010080e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100812:	c7 04 24 c8 54 10 f0 	movl   $0xf01054c8,(%esp)
f0100819:	e8 6f 45 00 00       	call   f0104d8d <strchr>
f010081e:	85 c0                	test   %eax,%eax
f0100820:	75 df                	jne    f0100801 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100822:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100825:	74 42                	je     f0100869 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100827:	83 fe 0f             	cmp    $0xf,%esi
f010082a:	75 16                	jne    f0100842 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010082c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100833:	00 
f0100834:	c7 04 24 cd 54 10 f0 	movl   $0xf01054cd,(%esp)
f010083b:	e8 16 2f 00 00       	call   f0103756 <cprintf>
f0100840:	eb 9f                	jmp    f01007e1 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100842:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100846:	46                   	inc    %esi
f0100847:	eb 01                	jmp    f010084a <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100849:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010084a:	8a 03                	mov    (%ebx),%al
f010084c:	84 c0                	test   %al,%al
f010084e:	74 b5                	je     f0100805 <monitor+0x56>
f0100850:	0f be c0             	movsbl %al,%eax
f0100853:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100857:	c7 04 24 c8 54 10 f0 	movl   $0xf01054c8,(%esp)
f010085e:	e8 2a 45 00 00       	call   f0104d8d <strchr>
f0100863:	85 c0                	test   %eax,%eax
f0100865:	74 e2                	je     f0100849 <monitor+0x9a>
f0100867:	eb 9c                	jmp    f0100805 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f0100869:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100870:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100871:	85 f6                	test   %esi,%esi
f0100873:	0f 84 68 ff ff ff    	je     f01007e1 <monitor+0x32>
f0100879:	bb 40 57 10 f0       	mov    $0xf0105740,%ebx
f010087e:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100883:	8b 03                	mov    (%ebx),%eax
f0100885:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100889:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010088c:	89 04 24             	mov    %eax,(%esp)
f010088f:	e8 a6 44 00 00       	call   f0104d3a <strcmp>
f0100894:	85 c0                	test   %eax,%eax
f0100896:	75 24                	jne    f01008bc <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f0100898:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010089b:	8b 55 08             	mov    0x8(%ebp),%edx
f010089e:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008a2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008a5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008a9:	89 34 24             	mov    %esi,(%esp)
f01008ac:	ff 14 85 48 57 10 f0 	call   *-0xfefa8b8(,%eax,4)
		print_trapframe(tf);
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008b3:	85 c0                	test   %eax,%eax
f01008b5:	78 26                	js     f01008dd <monitor+0x12e>
f01008b7:	e9 25 ff ff ff       	jmp    f01007e1 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008bc:	47                   	inc    %edi
f01008bd:	83 c3 0c             	add    $0xc,%ebx
f01008c0:	83 ff 05             	cmp    $0x5,%edi
f01008c3:	75 be                	jne    f0100883 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008c5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cc:	c7 04 24 ea 54 10 f0 	movl   $0xf01054ea,(%esp)
f01008d3:	e8 7e 2e 00 00       	call   f0103756 <cprintf>
f01008d8:	e9 04 ff ff ff       	jmp    f01007e1 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008dd:	83 c4 5c             	add    $0x5c,%esp
f01008e0:	5b                   	pop    %ebx
f01008e1:	5e                   	pop    %esi
f01008e2:	5f                   	pop    %edi
f01008e3:	5d                   	pop    %ebp
f01008e4:	c3                   	ret    
f01008e5:	00 00                	add    %al,(%eax)
	...

f01008e8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

	static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008e8:	55                   	push   %ebp
f01008e9:	89 e5                	mov    %esp,%ebp
f01008eb:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01008ee:	89 d1                	mov    %edx,%ecx
f01008f0:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01008f3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01008f6:	a8 01                	test   $0x1,%al
f01008f8:	74 4d                	je     f0100947 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008ff:	89 c1                	mov    %eax,%ecx
f0100901:	c1 e9 0c             	shr    $0xc,%ecx
f0100904:	3b 0d 44 6e 1e f0    	cmp    0xf01e6e44,%ecx
f010090a:	72 20                	jb     f010092c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010090c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100910:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0100917:	f0 
f0100918:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f010091f:	00 
f0100920:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100927:	e8 71 f7 ff ff       	call   f010009d <_panic>
	if (!(p[PTX(va)] & PTE_P))
f010092c:	c1 ea 0c             	shr    $0xc,%edx
f010092f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100935:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010093c:	a8 01                	test   $0x1,%al
f010093e:	74 0e                	je     f010094e <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100940:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100945:	eb 0c                	jmp    f0100953 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010094c:	eb 05                	jmp    f0100953 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f010094e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100953:	c9                   	leave  
f0100954:	c3                   	ret    

f0100955 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
	static void *
boot_alloc(uint32_t n)
{
f0100955:	55                   	push   %ebp
f0100956:	89 e5                	mov    %esp,%ebp
f0100958:	53                   	push   %ebx
f0100959:	83 ec 24             	sub    $0x24,%esp
f010095c:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010095e:	83 3d 9c 61 1e f0 00 	cmpl   $0x0,0xf01e619c
f0100965:	75 0f                	jne    f0100976 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100967:	b8 4f 7e 1e f0       	mov    $0xf01e7e4f,%eax
f010096c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100971:	a3 9c 61 1e f0       	mov    %eax,0xf01e619c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	// first end is at address 0xf011b970, result is 0xf011c100, use 107KB for kernel 
	if (n > 0) {
f0100976:	85 d2                	test   %edx,%edx
f0100978:	74 55                	je     f01009cf <boot_alloc+0x7a>
		result = nextfree;
f010097a:	a1 9c 61 1e f0       	mov    0xf01e619c,%eax
		nextfree = ROUNDUP((char *)(nextfree+n), PGSIZE);
f010097f:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100986:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010098c:	89 15 9c 61 1e f0    	mov    %edx,0xf01e619c
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE ){
f0100992:	8b 0d 44 6e 1e f0    	mov    0xf01e6e44,%ecx
f0100998:	c1 e1 0c             	shl    $0xc,%ecx
f010099b:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f01009a1:	39 cb                	cmp    %ecx,%ebx
f01009a3:	76 2f                	jbe    f01009d4 <boot_alloc+0x7f>
			panic("Cannot alloc more physical memory. Requested %dK, Available %dK\n", (uint32_t)nextfree/1024, npages*PGSIZE/1024);
f01009a5:	c1 e9 0a             	shr    $0xa,%ecx
f01009a8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01009ac:	c1 ea 0a             	shr    $0xa,%edx
f01009af:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01009b3:	c7 44 24 08 a0 57 10 	movl   $0xf01057a0,0x8(%esp)
f01009ba:	f0 
f01009bb:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f01009c2:	00 
f01009c3:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01009ca:	e8 ce f6 ff ff       	call   f010009d <_panic>
		}
		return result;
	}
	return nextfree;
f01009cf:	a1 9c 61 1e f0       	mov    0xf01e619c,%eax
}
f01009d4:	83 c4 24             	add    $0x24,%esp
f01009d7:	5b                   	pop    %ebx
f01009d8:	5d                   	pop    %ebp
f01009d9:	c3                   	ret    

f01009da <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

	static int
nvram_read(int r)
{
f01009da:	55                   	push   %ebp
f01009db:	89 e5                	mov    %esp,%ebp
f01009dd:	56                   	push   %esi
f01009de:	53                   	push   %ebx
f01009df:	83 ec 10             	sub    $0x10,%esp
f01009e2:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009e4:	89 04 24             	mov    %eax,(%esp)
f01009e7:	e8 fc 2c 00 00       	call   f01036e8 <mc146818_read>
f01009ec:	89 c6                	mov    %eax,%esi
f01009ee:	43                   	inc    %ebx
f01009ef:	89 1c 24             	mov    %ebx,(%esp)
f01009f2:	e8 f1 2c 00 00       	call   f01036e8 <mc146818_read>
f01009f7:	c1 e0 08             	shl    $0x8,%eax
f01009fa:	09 f0                	or     %esi,%eax
}
f01009fc:	83 c4 10             	add    $0x10,%esp
f01009ff:	5b                   	pop    %ebx
f0100a00:	5e                   	pop    %esi
f0100a01:	5d                   	pop    %ebp
f0100a02:	c3                   	ret    

f0100a03 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
	static void
check_page_free_list(bool only_low_memory)
{
f0100a03:	55                   	push   %ebp
f0100a04:	89 e5                	mov    %esp,%ebp
f0100a06:	57                   	push   %edi
f0100a07:	56                   	push   %esi
f0100a08:	53                   	push   %ebx
f0100a09:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a0c:	3c 01                	cmp    $0x1,%al
f0100a0e:	19 f6                	sbb    %esi,%esi
f0100a10:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100a16:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100a17:	8b 15 a0 61 1e f0    	mov    0xf01e61a0,%edx
f0100a1d:	85 d2                	test   %edx,%edx
f0100a1f:	75 1c                	jne    f0100a3d <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100a21:	c7 44 24 08 e4 57 10 	movl   $0xf01057e4,0x8(%esp)
f0100a28:	f0 
f0100a29:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0100a30:	00 
f0100a31:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100a38:	e8 60 f6 ff ff       	call   f010009d <_panic>

	if (only_low_memory) {
f0100a3d:	84 c0                	test   %al,%al
f0100a3f:	74 4b                	je     f0100a8c <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a41:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100a44:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a4d:	89 d0                	mov    %edx,%eax
f0100a4f:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0100a55:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a58:	c1 e8 16             	shr    $0x16,%eax
f0100a5b:	39 c6                	cmp    %eax,%esi
f0100a5d:	0f 96 c0             	setbe  %al
f0100a60:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100a63:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100a67:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a69:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a6d:	8b 12                	mov    (%edx),%edx
f0100a6f:	85 d2                	test   %edx,%edx
f0100a71:	75 da                	jne    f0100a4d <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a73:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a7c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100a82:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a87:	a3 a0 61 1e f0       	mov    %eax,0xf01e61a0
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a8c:	8b 1d a0 61 1e f0    	mov    0xf01e61a0,%ebx
f0100a92:	eb 63                	jmp    f0100af7 <check_page_free_list+0xf4>
f0100a94:	89 d8                	mov    %ebx,%eax
f0100a96:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0100a9c:	c1 f8 03             	sar    $0x3,%eax
f0100a9f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aa2:	89 c2                	mov    %eax,%edx
f0100aa4:	c1 ea 16             	shr    $0x16,%edx
f0100aa7:	39 d6                	cmp    %edx,%esi
f0100aa9:	76 4a                	jbe    f0100af5 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aab:	89 c2                	mov    %eax,%edx
f0100aad:	c1 ea 0c             	shr    $0xc,%edx
f0100ab0:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0100ab6:	72 20                	jb     f0100ad8 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ab8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100abc:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0100ac3:	f0 
f0100ac4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100acb:	00 
f0100acc:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0100ad3:	e8 c5 f5 ff ff       	call   f010009d <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ad8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100adf:	00 
f0100ae0:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100ae7:	00 
	return (void *)(pa + KERNBASE);
f0100ae8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100aed:	89 04 24             	mov    %eax,(%esp)
f0100af0:	e8 cd 42 00 00       	call   f0104dc2 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100af5:	8b 1b                	mov    (%ebx),%ebx
f0100af7:	85 db                	test   %ebx,%ebx
f0100af9:	75 99                	jne    f0100a94 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100afb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b00:	e8 50 fe ff ff       	call   f0100955 <boot_alloc>
f0100b05:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b08:	8b 15 a0 61 1e f0    	mov    0xf01e61a0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b0e:	8b 0d 4c 6e 1e f0    	mov    0xf01e6e4c,%ecx
		assert(pp < pages + npages);
f0100b14:	a1 44 6e 1e f0       	mov    0xf01e6e44,%eax
f0100b19:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b1c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b22:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b25:	be 00 00 00 00       	mov    $0x0,%esi
f0100b2a:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b2d:	e9 91 01 00 00       	jmp    f0100cc3 <check_page_free_list+0x2c0>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b32:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100b35:	73 24                	jae    f0100b5b <check_page_free_list+0x158>
f0100b37:	c7 44 24 0c 97 5f 10 	movl   $0xf0105f97,0xc(%esp)
f0100b3e:	f0 
f0100b3f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100b46:	f0 
f0100b47:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f0100b4e:	00 
f0100b4f:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100b56:	e8 42 f5 ff ff       	call   f010009d <_panic>
		assert(pp < pages + npages);
f0100b5b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b5e:	72 24                	jb     f0100b84 <check_page_free_list+0x181>
f0100b60:	c7 44 24 0c b8 5f 10 	movl   $0xf0105fb8,0xc(%esp)
f0100b67:	f0 
f0100b68:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100b6f:	f0 
f0100b70:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0100b77:	00 
f0100b78:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100b7f:	e8 19 f5 ff ff       	call   f010009d <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b84:	89 d0                	mov    %edx,%eax
f0100b86:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b89:	a8 07                	test   $0x7,%al
f0100b8b:	74 24                	je     f0100bb1 <check_page_free_list+0x1ae>
f0100b8d:	c7 44 24 0c 08 58 10 	movl   $0xf0105808,0xc(%esp)
f0100b94:	f0 
f0100b95:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100b9c:	f0 
f0100b9d:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0100ba4:	00 
f0100ba5:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100bac:	e8 ec f4 ff ff       	call   f010009d <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bb1:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bb4:	c1 e0 0c             	shl    $0xc,%eax
f0100bb7:	75 24                	jne    f0100bdd <check_page_free_list+0x1da>
f0100bb9:	c7 44 24 0c cc 5f 10 	movl   $0xf0105fcc,0xc(%esp)
f0100bc0:	f0 
f0100bc1:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100bd0:	00 
f0100bd1:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100bd8:	e8 c0 f4 ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bdd:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100be2:	75 24                	jne    f0100c08 <check_page_free_list+0x205>
f0100be4:	c7 44 24 0c dd 5f 10 	movl   $0xf0105fdd,0xc(%esp)
f0100beb:	f0 
f0100bec:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100bf3:	f0 
f0100bf4:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0100bfb:	00 
f0100bfc:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100c03:	e8 95 f4 ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c08:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c0d:	75 24                	jne    f0100c33 <check_page_free_list+0x230>
f0100c0f:	c7 44 24 0c 3c 58 10 	movl   $0xf010583c,0xc(%esp)
f0100c16:	f0 
f0100c17:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100c1e:	f0 
f0100c1f:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f0100c26:	00 
f0100c27:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100c2e:	e8 6a f4 ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c33:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c38:	75 24                	jne    f0100c5e <check_page_free_list+0x25b>
f0100c3a:	c7 44 24 0c f6 5f 10 	movl   $0xf0105ff6,0xc(%esp)
f0100c41:	f0 
f0100c42:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100c49:	f0 
f0100c4a:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
f0100c51:	00 
f0100c52:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100c59:	e8 3f f4 ff ff       	call   f010009d <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c5e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c63:	76 58                	jbe    f0100cbd <check_page_free_list+0x2ba>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c65:	89 c1                	mov    %eax,%ecx
f0100c67:	c1 e9 0c             	shr    $0xc,%ecx
f0100c6a:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100c6d:	77 20                	ja     f0100c8f <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c73:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100c82:	00 
f0100c83:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0100c8a:	e8 0e f4 ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f0100c8f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c94:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100c97:	76 27                	jbe    f0100cc0 <check_page_free_list+0x2bd>
f0100c99:	c7 44 24 0c 60 58 10 	movl   $0xf0105860,0xc(%esp)
f0100ca0:	f0 
f0100ca1:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100ca8:	f0 
f0100ca9:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0100cb0:	00 
f0100cb1:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100cb8:	e8 e0 f3 ff ff       	call   f010009d <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cbd:	46                   	inc    %esi
f0100cbe:	eb 01                	jmp    f0100cc1 <check_page_free_list+0x2be>
		else
			++nfree_extmem;
f0100cc0:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cc1:	8b 12                	mov    (%edx),%edx
f0100cc3:	85 d2                	test   %edx,%edx
f0100cc5:	0f 85 67 fe ff ff    	jne    f0100b32 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ccb:	85 f6                	test   %esi,%esi
f0100ccd:	7f 24                	jg     f0100cf3 <check_page_free_list+0x2f0>
f0100ccf:	c7 44 24 0c 10 60 10 	movl   $0xf0106010,0xc(%esp)
f0100cd6:	f0 
f0100cd7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100cde:	f0 
f0100cdf:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0100ce6:	00 
f0100ce7:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100cee:	e8 aa f3 ff ff       	call   f010009d <_panic>
	assert(nfree_extmem > 0);
f0100cf3:	85 db                	test   %ebx,%ebx
f0100cf5:	7f 24                	jg     f0100d1b <check_page_free_list+0x318>
f0100cf7:	c7 44 24 0c 22 60 10 	movl   $0xf0106022,0xc(%esp)
f0100cfe:	f0 
f0100cff:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100d06:	f0 
f0100d07:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0100d0e:	00 
f0100d0f:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100d16:	e8 82 f3 ff ff       	call   f010009d <_panic>
}
f0100d1b:	83 c4 4c             	add    $0x4c,%esp
f0100d1e:	5b                   	pop    %ebx
f0100d1f:	5e                   	pop    %esi
f0100d20:	5f                   	pop    %edi
f0100d21:	5d                   	pop    %ebp
f0100d22:	c3                   	ret    

f0100d23 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
	void
page_init(void)
{
f0100d23:	55                   	push   %ebp
f0100d24:	89 e5                	mov    %esp,%ebp
f0100d26:	57                   	push   %edi
f0100d27:	56                   	push   %esi
f0100d28:	53                   	push   %ebx
f0100d29:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	uint32_t num_alloc = ((uint32_t)boot_alloc(0)-KERNBASE)/PGSIZE;
f0100d2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d31:	e8 1f fc ff ff       	call   f0100955 <boot_alloc>
f0100d36:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d3b:	c1 e8 0c             	shr    $0xc,%eax
	size_t i;

	for(i = 0; i < npages; ++i) {
		if((i == 0)||
				// io hole
				( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100d3e:	8b 35 98 61 1e f0    	mov    0xf01e6198,%esi
f0100d44:	8d 7e 60             	lea    0x60(%esi),%edi
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100d47:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d4c:	ba 00 00 00 00       	mov    $0x0,%edx
		if((i == 0)||
				// io hole
				( i >= npages_basemem && i<npages_basemem+num_io_pages )||
				// alloc by kernel, kernel alloc pages and kern_pgdir on stack
				// num_alloc isn't all pages used, it is just memory used by kernel
				( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc  )) {
f0100d51:	01 f8                	add    %edi,%eax
f0100d53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100d56:	eb 44                	jmp    f0100d9c <page_init+0x79>
		if((i == 0)||
f0100d58:	85 d2                	test   %edx,%edx
f0100d5a:	74 13                	je     f0100d6f <page_init+0x4c>
f0100d5c:	39 f2                	cmp    %esi,%edx
f0100d5e:	72 06                	jb     f0100d66 <page_init+0x43>
				// io hole
				( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100d60:	39 fa                	cmp    %edi,%edx
f0100d62:	72 0b                	jb     f0100d6f <page_init+0x4c>
f0100d64:	eb 04                	jmp    f0100d6a <page_init+0x47>
f0100d66:	39 fa                	cmp    %edi,%edx
f0100d68:	72 12                	jb     f0100d7c <page_init+0x59>
				// alloc by kernel, kernel alloc pages and kern_pgdir on stack
				// num_alloc isn't all pages used, it is just memory used by kernel
				( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc  )) {
f0100d6a:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100d6d:	73 0d                	jae    f0100d7c <page_init+0x59>
			pages[0].pp_ref = 1;	
f0100d6f:	a1 4c 6e 1e f0       	mov    0xf01e6e4c,%eax
f0100d74:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0100d7a:	eb 1f                	jmp    f0100d9b <page_init+0x78>
		}else {
			pages[i].pp_ref = 0;
f0100d7c:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100d83:	8b 0d 4c 6e 1e f0    	mov    0xf01e6e4c,%ecx
f0100d89:	66 c7 44 01 04 00 00 	movw   $0x0,0x4(%ecx,%eax,1)
			pages[i].pp_link = page_free_list;
f0100d90:	89 1c 01             	mov    %ebx,(%ecx,%eax,1)
			page_free_list = &pages[i];
f0100d93:	89 c3                	mov    %eax,%ebx
f0100d95:	03 1d 4c 6e 1e f0    	add    0xf01e6e4c,%ebx
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100d9b:	42                   	inc    %edx
f0100d9c:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0100da2:	72 b4                	jb     f0100d58 <page_init+0x35>
f0100da4:	89 1d a0 61 1e f0    	mov    %ebx,0xf01e61a0
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100daa:	83 c4 1c             	add    $0x1c,%esp
f0100dad:	5b                   	pop    %ebx
f0100dae:	5e                   	pop    %esi
f0100daf:	5f                   	pop    %edi
f0100db0:	5d                   	pop    %ebp
f0100db1:	c3                   	ret    

f0100db2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
	struct PageInfo *
page_alloc(int alloc_flags)
{
f0100db2:	55                   	push   %ebp
f0100db3:	89 e5                	mov    %esp,%ebp
f0100db5:	53                   	push   %ebx
f0100db6:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo* temp_page;
	if (page_free_list) {
f0100db9:	8b 1d a0 61 1e f0    	mov    0xf01e61a0,%ebx
f0100dbf:	85 db                	test   %ebx,%ebx
f0100dc1:	0f 84 96 00 00 00    	je     f0100e5d <page_alloc+0xab>
		temp_page = page_free_list;
		assert(temp_page->pp_ref == 0);
f0100dc7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100dcc:	74 24                	je     f0100df2 <page_alloc+0x40>
f0100dce:	c7 44 24 0c 33 60 10 	movl   $0xf0106033,0xc(%esp)
f0100dd5:	f0 
f0100dd6:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0100ddd:	f0 
f0100dde:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f0100de5:	00 
f0100de6:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100ded:	e8 ab f2 ff ff       	call   f010009d <_panic>
		page_free_list = page_free_list->pp_link;
f0100df2:	8b 03                	mov    (%ebx),%eax
f0100df4:	a3 a0 61 1e f0       	mov    %eax,0xf01e61a0
		temp_page->pp_link = NULL;
f0100df9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	} else {
		return NULL;
	} 
	// temp_page is a Pageinfo, i think page2kva is actual page
	if (alloc_flags & ALLOC_ZERO) {
f0100dff:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e03:	74 58                	je     f0100e5d <page_alloc+0xab>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e05:	89 d8                	mov    %ebx,%eax
f0100e07:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0100e0d:	c1 f8 03             	sar    $0x3,%eax
f0100e10:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e13:	89 c2                	mov    %eax,%edx
f0100e15:	c1 ea 0c             	shr    $0xc,%edx
f0100e18:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0100e1e:	72 20                	jb     f0100e40 <page_alloc+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e24:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0100e2b:	f0 
f0100e2c:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e33:	00 
f0100e34:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0100e3b:	e8 5d f2 ff ff       	call   f010009d <_panic>
		memset(page2kva(temp_page), 0, PGSIZE); 
f0100e40:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e47:	00 
f0100e48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e4f:	00 
	return (void *)(pa + KERNBASE);
f0100e50:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e55:	89 04 24             	mov    %eax,(%esp)
f0100e58:	e8 65 3f 00 00       	call   f0104dc2 <memset>
	}

	return temp_page;
}
f0100e5d:	89 d8                	mov    %ebx,%eax
f0100e5f:	83 c4 14             	add    $0x14,%esp
f0100e62:	5b                   	pop    %ebx
f0100e63:	5d                   	pop    %ebp
f0100e64:	c3                   	ret    

f0100e65 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
	void
page_free(struct PageInfo *pp)
{
f0100e65:	55                   	push   %ebp
f0100e66:	89 e5                	mov    %esp,%ebp
f0100e68:	83 ec 18             	sub    $0x18,%esp
f0100e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f0100e6e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e73:	74 1c                	je     f0100e91 <page_free+0x2c>
		panic("Still using page");
f0100e75:	c7 44 24 08 4a 60 10 	movl   $0xf010604a,0x8(%esp)
f0100e7c:	f0 
f0100e7d:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0100e84:	00 
f0100e85:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100e8c:	e8 0c f2 ff ff       	call   f010009d <_panic>
	}
	if (pp->pp_link != NULL) {
f0100e91:	83 38 00             	cmpl   $0x0,(%eax)
f0100e94:	74 1c                	je     f0100eb2 <page_free+0x4d>
		panic("free page still have a link");
f0100e96:	c7 44 24 08 5b 60 10 	movl   $0xf010605b,0x8(%esp)
f0100e9d:	f0 
f0100e9e:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
f0100ea5:	00 
f0100ea6:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100ead:	e8 eb f1 ff ff       	call   f010009d <_panic>
	}
	pp->pp_link = page_free_list;
f0100eb2:	8b 15 a0 61 1e f0    	mov    0xf01e61a0,%edx
f0100eb8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100eba:	a3 a0 61 1e f0       	mov    %eax,0xf01e61a0
}
f0100ebf:	c9                   	leave  
f0100ec0:	c3                   	ret    

f0100ec1 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
	void
page_decref(struct PageInfo* pp)
{
f0100ec1:	55                   	push   %ebp
f0100ec2:	89 e5                	mov    %esp,%ebp
f0100ec4:	83 ec 18             	sub    $0x18,%esp
f0100ec7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100eca:	8b 50 04             	mov    0x4(%eax),%edx
f0100ecd:	4a                   	dec    %edx
f0100ece:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100ed2:	66 85 d2             	test   %dx,%dx
f0100ed5:	75 08                	jne    f0100edf <page_decref+0x1e>
		page_free(pp);
f0100ed7:	89 04 24             	mov    %eax,(%esp)
f0100eda:	e8 86 ff ff ff       	call   f0100e65 <page_free>
}
f0100edf:	c9                   	leave  
f0100ee0:	c3                   	ret    

f0100ee1 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
	pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ee1:	55                   	push   %ebp
f0100ee2:	89 e5                	mov    %esp,%ebp
f0100ee4:	57                   	push   %edi
f0100ee5:	56                   	push   %esi
f0100ee6:	53                   	push   %ebx
f0100ee7:	83 ec 1c             	sub    $0x1c,%esp
f0100eea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pde_t* pgdir_entry = &pgdir[PDX(va)];
f0100eed:	89 fb                	mov    %edi,%ebx
f0100eef:	c1 eb 16             	shr    $0x16,%ebx
f0100ef2:	c1 e3 02             	shl    $0x2,%ebx
f0100ef5:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pgtb_entry = NULL;
	struct PageInfo * pg = NULL;

	if (!(*pgdir_entry & PTE_P)){
f0100ef8:	f6 03 01             	testb  $0x1,(%ebx)
f0100efb:	0f 85 8b 00 00 00    	jne    f0100f8c <pgdir_walk+0xab>
		if(create){
f0100f01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f05:	0f 84 c7 00 00 00    	je     f0100fd2 <pgdir_walk+0xf1>
			pg = page_alloc(1);
f0100f0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f12:	e8 9b fe ff ff       	call   f0100db2 <page_alloc>
f0100f17:	89 c6                	mov    %eax,%esi
			if (!pg) 
f0100f19:	85 c0                	test   %eax,%eax
f0100f1b:	0f 84 b8 00 00 00    	je     f0100fd9 <pgdir_walk+0xf8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f21:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0100f27:	c1 f8 03             	sar    $0x3,%eax
f0100f2a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f2d:	89 c2                	mov    %eax,%edx
f0100f2f:	c1 ea 0c             	shr    $0xc,%edx
f0100f32:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0100f38:	72 20                	jb     f0100f5a <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f3e:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0100f45:	f0 
f0100f46:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100f4d:	00 
f0100f4e:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0100f55:	e8 43 f1 ff ff       	call   f010009d <_panic>
				return NULL;
			memset(page2kva(pg), 0, PGSIZE);
f0100f5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100f61:	00 
f0100f62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f69:	00 
	return (void *)(pa + KERNBASE);
f0100f6a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f6f:	89 04 24             	mov    %eax,(%esp)
f0100f72:	e8 4b 3e 00 00       	call   f0104dc2 <memset>
			pg->pp_ref += 1;
f0100f77:	66 ff 46 04          	incw   0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f7b:	2b 35 4c 6e 1e f0    	sub    0xf01e6e4c,%esi
f0100f81:	c1 fe 03             	sar    $0x3,%esi
f0100f84:	c1 e6 0c             	shl    $0xc,%esi
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
f0100f87:	83 ce 07             	or     $0x7,%esi
f0100f8a:	89 33                	mov    %esi,(%ebx)
		}else{
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
f0100f8c:	8b 03                	mov    (%ebx),%eax
f0100f8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f93:	89 c2                	mov    %eax,%edx
f0100f95:	c1 ea 0c             	shr    $0xc,%edx
f0100f98:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0100f9e:	72 20                	jb     f0100fc0 <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa4:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0100fab:	f0 
f0100fac:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f0100fb3:	00 
f0100fb4:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0100fbb:	e8 dd f0 ff ff       	call   f010009d <_panic>
	return &pgtb_entry[PTX(va)];
f0100fc0:	c1 ef 0a             	shr    $0xa,%edi
f0100fc3:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f0100fc9:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
f0100fd0:	eb 0c                	jmp    f0100fde <pgdir_walk+0xfd>
				return NULL;
			memset(page2kva(pg), 0, PGSIZE);
			pg->pp_ref += 1;
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
		}else{
			return NULL;
f0100fd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd7:	eb 05                	jmp    f0100fde <pgdir_walk+0xfd>

	if (!(*pgdir_entry & PTE_P)){
		if(create){
			pg = page_alloc(1);
			if (!pg) 
				return NULL;
f0100fd9:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
	return &pgtb_entry[PTX(va)];
}
f0100fde:	83 c4 1c             	add    $0x1c,%esp
f0100fe1:	5b                   	pop    %ebx
f0100fe2:	5e                   	pop    %esi
f0100fe3:	5f                   	pop    %edi
f0100fe4:	5d                   	pop    %ebp
f0100fe5:	c3                   	ret    

f0100fe6 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fe6:	55                   	push   %ebp
f0100fe7:	89 e5                	mov    %esp,%ebp
f0100fe9:	57                   	push   %edi
f0100fea:	56                   	push   %esi
f0100feb:	53                   	push   %ebx
f0100fec:	83 ec 2c             	sub    $0x2c,%esp
f0100fef:	89 c7                	mov    %eax,%edi
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0100ff1:	c1 e9 0c             	shr    $0xc,%ecx
f0100ff4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ff7:	89 d3                	mov    %edx,%ebx
f0100ff9:	be 00 00 00 00       	mov    $0x0,%esi
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0100ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101001:	83 c8 01             	or     $0x1,%eax
f0101004:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101007:	8b 45 08             	mov    0x8(%ebp),%eax
f010100a:	29 d0                	sub    %edx,%eax
f010100c:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f010100f:	eb 25                	jmp    f0101036 <boot_map_region+0x50>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
f0101011:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101018:	00 
f0101019:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010101d:	89 3c 24             	mov    %edi,(%esp)
f0101020:	e8 bc fe ff ff       	call   f0100ee1 <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101025:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101028:	01 da                	add    %ebx,%edx
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f010102a:	0b 55 e0             	or     -0x20(%ebp),%edx
f010102d:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f010102f:	46                   	inc    %esi
f0101030:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101036:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101039:	75 d6                	jne    f0101011 <boot_map_region+0x2b>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
	} 
}
f010103b:	83 c4 2c             	add    $0x2c,%esp
f010103e:	5b                   	pop    %ebx
f010103f:	5e                   	pop    %esi
f0101040:	5f                   	pop    %edi
f0101041:	5d                   	pop    %ebp
f0101042:	c3                   	ret    

f0101043 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
	struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101043:	55                   	push   %ebp
f0101044:	89 e5                	mov    %esp,%ebp
f0101046:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f0101049:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101050:	00 
f0101051:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101058:	8b 45 08             	mov    0x8(%ebp),%eax
f010105b:	89 04 24             	mov    %eax,(%esp)
f010105e:	e8 7e fe ff ff       	call   f0100ee1 <pgdir_walk>
	if (pt_entry && *pt_entry&PTE_P) {
f0101063:	85 c0                	test   %eax,%eax
f0101065:	74 3e                	je     f01010a5 <page_lookup+0x62>
f0101067:	f6 00 01             	testb  $0x1,(%eax)
f010106a:	74 40                	je     f01010ac <page_lookup+0x69>
		*pte_store = pt_entry;
f010106c:	8b 55 10             	mov    0x10(%ebp),%edx
f010106f:	89 02                	mov    %eax,(%edx)
	}else{
		return NULL;
	}
	return pa2page(PTE_ADDR(*pt_entry));
f0101071:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101073:	c1 e8 0c             	shr    $0xc,%eax
f0101076:	3b 05 44 6e 1e f0    	cmp    0xf01e6e44,%eax
f010107c:	72 1c                	jb     f010109a <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f010107e:	c7 44 24 08 a8 58 10 	movl   $0xf01058a8,0x8(%esp)
f0101085:	f0 
f0101086:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010108d:	00 
f010108e:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0101095:	e8 03 f0 ff ff       	call   f010009d <_panic>
	return &pages[PGNUM(pa)];
f010109a:	c1 e0 03             	shl    $0x3,%eax
f010109d:	03 05 4c 6e 1e f0    	add    0xf01e6e4c,%eax
f01010a3:	eb 0c                	jmp    f01010b1 <page_lookup+0x6e>
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
	if (pt_entry && *pt_entry&PTE_P) {
		*pte_store = pt_entry;
	}else{
		return NULL;
f01010a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01010aa:	eb 05                	jmp    f01010b1 <page_lookup+0x6e>
f01010ac:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return pa2page(PTE_ADDR(*pt_entry));
}
f01010b1:	c9                   	leave  
f01010b2:	c3                   	ret    

f01010b3 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
	void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010b3:	55                   	push   %ebp
f01010b4:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b9:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01010bc:	5d                   	pop    %ebp
f01010bd:	c3                   	ret    

f01010be <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
	void
page_remove(pde_t *pgdir, void *va)
{
f01010be:	55                   	push   %ebp
f01010bf:	89 e5                	mov    %esp,%ebp
f01010c1:	56                   	push   %esi
f01010c2:	53                   	push   %ebx
f01010c3:	83 ec 20             	sub    $0x20,%esp
f01010c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01010c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte_store = NULL;
f01010cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg = page_lookup(pgdir, va, &pte_store); 
f01010d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010d6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010de:	89 34 24             	mov    %esi,(%esp)
f01010e1:	e8 5d ff ff ff       	call   f0101043 <page_lookup>
	if (!pg) 
f01010e6:	85 c0                	test   %eax,%eax
f01010e8:	74 1d                	je     f0101107 <page_remove+0x49>
		return;
	page_decref(pg);	
f01010ea:	89 04 24             	mov    %eax,(%esp)
f01010ed:	e8 cf fd ff ff       	call   f0100ec1 <page_decref>
	tlb_invalidate(pgdir, va);
f01010f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010f6:	89 34 24             	mov    %esi,(%esp)
f01010f9:	e8 b5 ff ff ff       	call   f01010b3 <tlb_invalidate>
	*pte_store = 0;
f01010fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101101:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f0101107:	83 c4 20             	add    $0x20,%esp
f010110a:	5b                   	pop    %ebx
f010110b:	5e                   	pop    %esi
f010110c:	5d                   	pop    %ebp
f010110d:	c3                   	ret    

f010110e <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
	int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010110e:	55                   	push   %ebp
f010110f:	89 e5                	mov    %esp,%ebp
f0101111:	57                   	push   %edi
f0101112:	56                   	push   %esi
f0101113:	53                   	push   %ebx
f0101114:	83 ec 1c             	sub    $0x1c,%esp
f0101117:	8b 75 08             	mov    0x8(%ebp),%esi
f010111a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f010111d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101124:	00 
f0101125:	8b 45 10             	mov    0x10(%ebp),%eax
f0101128:	89 44 24 04          	mov    %eax,0x4(%esp)
f010112c:	89 34 24             	mov    %esi,(%esp)
f010112f:	e8 ad fd ff ff       	call   f0100ee1 <pgdir_walk>
f0101134:	89 c3                	mov    %eax,%ebx
	if (!pg_entry) {
f0101136:	85 c0                	test   %eax,%eax
f0101138:	74 4d                	je     f0101187 <page_insert+0x79>
		return -E_NO_MEM;
	} 
	pp->pp_ref++;
f010113a:	66 ff 47 04          	incw   0x4(%edi)
	if (*pg_entry & PTE_P){
f010113e:	f6 00 01             	testb  $0x1,(%eax)
f0101141:	74 1e                	je     f0101161 <page_insert+0x53>
		tlb_invalidate(pgdir, va);
f0101143:	8b 45 10             	mov    0x10(%ebp),%eax
f0101146:	89 44 24 04          	mov    %eax,0x4(%esp)
f010114a:	89 34 24             	mov    %esi,(%esp)
f010114d:	e8 61 ff ff ff       	call   f01010b3 <tlb_invalidate>
		page_remove(pgdir, va);
f0101152:	8b 45 10             	mov    0x10(%ebp),%eax
f0101155:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101159:	89 34 24             	mov    %esi,(%esp)
f010115c:	e8 5d ff ff ff       	call   f01010be <page_remove>
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
f0101161:	8b 55 14             	mov    0x14(%ebp),%edx
f0101164:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101167:	2b 3d 4c 6e 1e f0    	sub    0xf01e6e4c,%edi
f010116d:	c1 ff 03             	sar    $0x3,%edi
f0101170:	c1 e7 0c             	shl    $0xc,%edi
f0101173:	09 d7                	or     %edx,%edi
f0101175:	89 3b                	mov    %edi,(%ebx)
	pgdir[PDX(va)] |= perm | PTE_P;	
f0101177:	8b 45 10             	mov    0x10(%ebp),%eax
f010117a:	c1 e8 16             	shr    $0x16,%eax
f010117d:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101180:	b8 00 00 00 00       	mov    $0x0,%eax
f0101185:	eb 05                	jmp    f010118c <page_insert+0x7e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
	if (!pg_entry) {
		return -E_NO_MEM;
f0101187:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
	pgdir[PDX(va)] |= perm | PTE_P;	
	return 0;
}
f010118c:	83 c4 1c             	add    $0x1c,%esp
f010118f:	5b                   	pop    %ebx
f0101190:	5e                   	pop    %esi
f0101191:	5f                   	pop    %edi
f0101192:	5d                   	pop    %ebp
f0101193:	c3                   	ret    

f0101194 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
{
f0101194:	55                   	push   %ebp
f0101195:	89 e5                	mov    %esp,%ebp
f0101197:	57                   	push   %edi
f0101198:	56                   	push   %esi
f0101199:	53                   	push   %ebx
f010119a:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010119d:	b8 15 00 00 00       	mov    $0x15,%eax
f01011a2:	e8 33 f8 ff ff       	call   f01009da <nvram_read>
f01011a7:	c1 e0 0a             	shl    $0xa,%eax
f01011aa:	89 c2                	mov    %eax,%edx
f01011ac:	85 c0                	test   %eax,%eax
f01011ae:	79 06                	jns    f01011b6 <mem_init+0x22>
f01011b0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011b6:	c1 fa 0c             	sar    $0xc,%edx
f01011b9:	89 15 98 61 1e f0    	mov    %edx,0xf01e6198
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01011bf:	b8 17 00 00 00       	mov    $0x17,%eax
f01011c4:	e8 11 f8 ff ff       	call   f01009da <nvram_read>
f01011c9:	89 c2                	mov    %eax,%edx
f01011cb:	c1 e2 0a             	shl    $0xa,%edx
f01011ce:	89 d0                	mov    %edx,%eax
f01011d0:	85 d2                	test   %edx,%edx
f01011d2:	79 06                	jns    f01011da <mem_init+0x46>
f01011d4:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01011da:	c1 f8 0c             	sar    $0xc,%eax
f01011dd:	74 0e                	je     f01011ed <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01011df:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01011e5:	89 15 44 6e 1e f0    	mov    %edx,0xf01e6e44
f01011eb:	eb 0c                	jmp    f01011f9 <mem_init+0x65>
	else
		npages = npages_basemem;
f01011ed:	8b 15 98 61 1e f0    	mov    0xf01e6198,%edx
f01011f3:	89 15 44 6e 1e f0    	mov    %edx,0xf01e6e44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
			npages * PGSIZE / 1024,
			npages_basemem * PGSIZE / 1024,
			npages_extmem * PGSIZE / 1024);
f01011f9:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011fc:	c1 e8 0a             	shr    $0xa,%eax
f01011ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
			npages * PGSIZE / 1024,
			npages_basemem * PGSIZE / 1024,
f0101203:	a1 98 61 1e f0       	mov    0xf01e6198,%eax
f0101208:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010120b:	c1 e8 0a             	shr    $0xa,%eax
f010120e:	89 44 24 08          	mov    %eax,0x8(%esp)
			npages * PGSIZE / 1024,
f0101212:	a1 44 6e 1e f0       	mov    0xf01e6e44,%eax
f0101217:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010121a:	c1 e8 0a             	shr    $0xa,%eax
f010121d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101221:	c7 04 24 c8 58 10 f0 	movl   $0xf01058c8,(%esp)
f0101228:	e8 29 25 00 00       	call   f0103756 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010122d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101232:	e8 1e f7 ff ff       	call   f0100955 <boot_alloc>
f0101237:	a3 48 6e 1e f0       	mov    %eax,0xf01e6e48
	memset(kern_pgdir, 0, PGSIZE);
f010123c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101243:	00 
f0101244:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010124b:	00 
f010124c:	89 04 24             	mov    %eax,(%esp)
f010124f:	e8 6e 3b 00 00       	call   f0104dc2 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101254:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101259:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010125e:	77 20                	ja     f0101280 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101260:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101264:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f010126b:	f0 
f010126c:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
f0101273:	00 
f0101274:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010127b:	e8 1d ee ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101280:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101286:	83 ca 05             	or     $0x5,%edx
f0101289:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f010128f:	a1 44 6e 1e f0       	mov    0xf01e6e44,%eax
f0101294:	c1 e0 03             	shl    $0x3,%eax
f0101297:	e8 b9 f6 ff ff       	call   f0100955 <boot_alloc>
f010129c:	a3 4c 6e 1e f0       	mov    %eax,0xf01e6e4c
	memset(pages, 0, sizeof(struct PageInfo)*npages); 
f01012a1:	8b 15 44 6e 1e f0    	mov    0xf01e6e44,%edx
f01012a7:	c1 e2 03             	shl    $0x3,%edx
f01012aa:	89 54 24 08          	mov    %edx,0x8(%esp)
f01012ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012b5:	00 
f01012b6:	89 04 24             	mov    %eax,(%esp)
f01012b9:	e8 04 3b 00 00       	call   f0104dc2 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f01012be:	b8 00 80 01 00       	mov    $0x18000,%eax
f01012c3:	e8 8d f6 ff ff       	call   f0100955 <boot_alloc>
f01012c8:	a3 ac 61 1e f0       	mov    %eax,0xf01e61ac
	memset(envs, 0, sizeof(struct Env)*NENV);
f01012cd:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f01012d4:	00 
f01012d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012dc:	00 
f01012dd:	89 04 24             	mov    %eax,(%esp)
f01012e0:	e8 dd 3a 00 00       	call   f0104dc2 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01012e5:	e8 39 fa ff ff       	call   f0100d23 <page_init>

	check_page_free_list(1);
f01012ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01012ef:	e8 0f f7 ff ff       	call   f0100a03 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012f4:	83 3d 4c 6e 1e f0 00 	cmpl   $0x0,0xf01e6e4c
f01012fb:	75 1c                	jne    f0101319 <mem_init+0x185>
		panic("'pages' is a null pointer!");
f01012fd:	c7 44 24 08 77 60 10 	movl   $0xf0106077,0x8(%esp)
f0101304:	f0 
f0101305:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
f010130c:	00 
f010130d:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101314:	e8 84 ed ff ff       	call   f010009d <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101319:	a1 a0 61 1e f0       	mov    0xf01e61a0,%eax
f010131e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101323:	eb 03                	jmp    f0101328 <mem_init+0x194>
		++nfree;
f0101325:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101326:	8b 00                	mov    (%eax),%eax
f0101328:	85 c0                	test   %eax,%eax
f010132a:	75 f9                	jne    f0101325 <mem_init+0x191>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010132c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101333:	e8 7a fa ff ff       	call   f0100db2 <page_alloc>
f0101338:	89 c6                	mov    %eax,%esi
f010133a:	85 c0                	test   %eax,%eax
f010133c:	75 24                	jne    f0101362 <mem_init+0x1ce>
f010133e:	c7 44 24 0c 92 60 10 	movl   $0xf0106092,0xc(%esp)
f0101345:	f0 
f0101346:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010134d:	f0 
f010134e:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0101355:	00 
f0101356:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010135d:	e8 3b ed ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0101362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101369:	e8 44 fa ff ff       	call   f0100db2 <page_alloc>
f010136e:	89 c7                	mov    %eax,%edi
f0101370:	85 c0                	test   %eax,%eax
f0101372:	75 24                	jne    f0101398 <mem_init+0x204>
f0101374:	c7 44 24 0c a8 60 10 	movl   $0xf01060a8,0xc(%esp)
f010137b:	f0 
f010137c:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101383:	f0 
f0101384:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f010138b:	00 
f010138c:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101393:	e8 05 ed ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f0101398:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010139f:	e8 0e fa ff ff       	call   f0100db2 <page_alloc>
f01013a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013a7:	85 c0                	test   %eax,%eax
f01013a9:	75 24                	jne    f01013cf <mem_init+0x23b>
f01013ab:	c7 44 24 0c be 60 10 	movl   $0xf01060be,0xc(%esp)
f01013b2:	f0 
f01013b3:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01013ba:	f0 
f01013bb:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f01013c2:	00 
f01013c3:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01013ca:	e8 ce ec ff ff       	call   f010009d <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013cf:	39 fe                	cmp    %edi,%esi
f01013d1:	75 24                	jne    f01013f7 <mem_init+0x263>
f01013d3:	c7 44 24 0c d4 60 10 	movl   $0xf01060d4,0xc(%esp)
f01013da:	f0 
f01013db:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01013e2:	f0 
f01013e3:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f01013ea:	00 
f01013eb:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01013f2:	e8 a6 ec ff ff       	call   f010009d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013f7:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01013fa:	74 05                	je     f0101401 <mem_init+0x26d>
f01013fc:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01013ff:	75 24                	jne    f0101425 <mem_init+0x291>
f0101401:	c7 44 24 0c 28 59 10 	movl   $0xf0105928,0xc(%esp)
f0101408:	f0 
f0101409:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101410:	f0 
f0101411:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101418:	00 
f0101419:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101420:	e8 78 ec ff ff       	call   f010009d <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101425:	8b 15 4c 6e 1e f0    	mov    0xf01e6e4c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010142b:	a1 44 6e 1e f0       	mov    0xf01e6e44,%eax
f0101430:	c1 e0 0c             	shl    $0xc,%eax
f0101433:	89 f1                	mov    %esi,%ecx
f0101435:	29 d1                	sub    %edx,%ecx
f0101437:	c1 f9 03             	sar    $0x3,%ecx
f010143a:	c1 e1 0c             	shl    $0xc,%ecx
f010143d:	39 c1                	cmp    %eax,%ecx
f010143f:	72 24                	jb     f0101465 <mem_init+0x2d1>
f0101441:	c7 44 24 0c e6 60 10 	movl   $0xf01060e6,0xc(%esp)
f0101448:	f0 
f0101449:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101450:	f0 
f0101451:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0101458:	00 
f0101459:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101460:	e8 38 ec ff ff       	call   f010009d <_panic>
f0101465:	89 f9                	mov    %edi,%ecx
f0101467:	29 d1                	sub    %edx,%ecx
f0101469:	c1 f9 03             	sar    $0x3,%ecx
f010146c:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010146f:	39 c8                	cmp    %ecx,%eax
f0101471:	77 24                	ja     f0101497 <mem_init+0x303>
f0101473:	c7 44 24 0c 03 61 10 	movl   $0xf0106103,0xc(%esp)
f010147a:	f0 
f010147b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101482:	f0 
f0101483:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f010148a:	00 
f010148b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101492:	e8 06 ec ff ff       	call   f010009d <_panic>
f0101497:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010149a:	29 d1                	sub    %edx,%ecx
f010149c:	89 ca                	mov    %ecx,%edx
f010149e:	c1 fa 03             	sar    $0x3,%edx
f01014a1:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01014a4:	39 d0                	cmp    %edx,%eax
f01014a6:	77 24                	ja     f01014cc <mem_init+0x338>
f01014a8:	c7 44 24 0c 20 61 10 	movl   $0xf0106120,0xc(%esp)
f01014af:	f0 
f01014b0:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01014b7:	f0 
f01014b8:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f01014bf:	00 
f01014c0:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01014c7:	e8 d1 eb ff ff       	call   f010009d <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014cc:	a1 a0 61 1e f0       	mov    0xf01e61a0,%eax
f01014d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014d4:	c7 05 a0 61 1e f0 00 	movl   $0x0,0xf01e61a0
f01014db:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014e5:	e8 c8 f8 ff ff       	call   f0100db2 <page_alloc>
f01014ea:	85 c0                	test   %eax,%eax
f01014ec:	74 24                	je     f0101512 <mem_init+0x37e>
f01014ee:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f01014f5:	f0 
f01014f6:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 04 c5 02 00 	movl   $0x2c5,0x4(%esp)
f0101505:	00 
f0101506:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010150d:	e8 8b eb ff ff       	call   f010009d <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101512:	89 34 24             	mov    %esi,(%esp)
f0101515:	e8 4b f9 ff ff       	call   f0100e65 <page_free>
	page_free(pp1);
f010151a:	89 3c 24             	mov    %edi,(%esp)
f010151d:	e8 43 f9 ff ff       	call   f0100e65 <page_free>
	page_free(pp2);
f0101522:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101525:	89 04 24             	mov    %eax,(%esp)
f0101528:	e8 38 f9 ff ff       	call   f0100e65 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010152d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101534:	e8 79 f8 ff ff       	call   f0100db2 <page_alloc>
f0101539:	89 c6                	mov    %eax,%esi
f010153b:	85 c0                	test   %eax,%eax
f010153d:	75 24                	jne    f0101563 <mem_init+0x3cf>
f010153f:	c7 44 24 0c 92 60 10 	movl   $0xf0106092,0xc(%esp)
f0101546:	f0 
f0101547:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010154e:	f0 
f010154f:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101556:	00 
f0101557:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010155e:	e8 3a eb ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0101563:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010156a:	e8 43 f8 ff ff       	call   f0100db2 <page_alloc>
f010156f:	89 c7                	mov    %eax,%edi
f0101571:	85 c0                	test   %eax,%eax
f0101573:	75 24                	jne    f0101599 <mem_init+0x405>
f0101575:	c7 44 24 0c a8 60 10 	movl   $0xf01060a8,0xc(%esp)
f010157c:	f0 
f010157d:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101584:	f0 
f0101585:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f010158c:	00 
f010158d:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101594:	e8 04 eb ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f0101599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a0:	e8 0d f8 ff ff       	call   f0100db2 <page_alloc>
f01015a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015a8:	85 c0                	test   %eax,%eax
f01015aa:	75 24                	jne    f01015d0 <mem_init+0x43c>
f01015ac:	c7 44 24 0c be 60 10 	movl   $0xf01060be,0xc(%esp)
f01015b3:	f0 
f01015b4:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01015bb:	f0 
f01015bc:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f01015c3:	00 
f01015c4:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01015cb:	e8 cd ea ff ff       	call   f010009d <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015d0:	39 fe                	cmp    %edi,%esi
f01015d2:	75 24                	jne    f01015f8 <mem_init+0x464>
f01015d4:	c7 44 24 0c d4 60 10 	movl   $0xf01060d4,0xc(%esp)
f01015db:	f0 
f01015dc:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01015e3:	f0 
f01015e4:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f01015eb:	00 
f01015ec:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01015f3:	e8 a5 ea ff ff       	call   f010009d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015f8:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01015fb:	74 05                	je     f0101602 <mem_init+0x46e>
f01015fd:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101600:	75 24                	jne    f0101626 <mem_init+0x492>
f0101602:	c7 44 24 0c 28 59 10 	movl   $0xf0105928,0xc(%esp)
f0101609:	f0 
f010160a:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101611:	f0 
f0101612:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101619:	00 
f010161a:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101621:	e8 77 ea ff ff       	call   f010009d <_panic>
	assert(!page_alloc(0));
f0101626:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010162d:	e8 80 f7 ff ff       	call   f0100db2 <page_alloc>
f0101632:	85 c0                	test   %eax,%eax
f0101634:	74 24                	je     f010165a <mem_init+0x4c6>
f0101636:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f010163d:	f0 
f010163e:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101645:	f0 
f0101646:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f010164d:	00 
f010164e:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101655:	e8 43 ea ff ff       	call   f010009d <_panic>
f010165a:	89 f0                	mov    %esi,%eax
f010165c:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0101662:	c1 f8 03             	sar    $0x3,%eax
f0101665:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101668:	89 c2                	mov    %eax,%edx
f010166a:	c1 ea 0c             	shr    $0xc,%edx
f010166d:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0101673:	72 20                	jb     f0101695 <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101675:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101679:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0101680:	f0 
f0101681:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101688:	00 
f0101689:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0101690:	e8 08 ea ff ff       	call   f010009d <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101695:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010169c:	00 
f010169d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01016a4:	00 
	return (void *)(pa + KERNBASE);
f01016a5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016aa:	89 04 24             	mov    %eax,(%esp)
f01016ad:	e8 10 37 00 00       	call   f0104dc2 <memset>
	page_free(pp0);
f01016b2:	89 34 24             	mov    %esi,(%esp)
f01016b5:	e8 ab f7 ff ff       	call   f0100e65 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016c1:	e8 ec f6 ff ff       	call   f0100db2 <page_alloc>
f01016c6:	85 c0                	test   %eax,%eax
f01016c8:	75 24                	jne    f01016ee <mem_init+0x55a>
f01016ca:	c7 44 24 0c 4c 61 10 	movl   $0xf010614c,0xc(%esp)
f01016d1:	f0 
f01016d2:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01016d9:	f0 
f01016da:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01016e1:	00 
f01016e2:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01016e9:	e8 af e9 ff ff       	call   f010009d <_panic>
	assert(pp && pp0 == pp);
f01016ee:	39 c6                	cmp    %eax,%esi
f01016f0:	74 24                	je     f0101716 <mem_init+0x582>
f01016f2:	c7 44 24 0c 6a 61 10 	movl   $0xf010616a,0xc(%esp)
f01016f9:	f0 
f01016fa:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101701:	f0 
f0101702:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0101709:	00 
f010170a:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101711:	e8 87 e9 ff ff       	call   f010009d <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101716:	89 f2                	mov    %esi,%edx
f0101718:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f010171e:	c1 fa 03             	sar    $0x3,%edx
f0101721:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101724:	89 d0                	mov    %edx,%eax
f0101726:	c1 e8 0c             	shr    $0xc,%eax
f0101729:	3b 05 44 6e 1e f0    	cmp    0xf01e6e44,%eax
f010172f:	72 20                	jb     f0101751 <mem_init+0x5bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101731:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101735:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f010173c:	f0 
f010173d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101744:	00 
f0101745:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f010174c:	e8 4c e9 ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f0101751:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f0101757:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010175d:	80 38 00             	cmpb   $0x0,(%eax)
f0101760:	74 24                	je     f0101786 <mem_init+0x5f2>
f0101762:	c7 44 24 0c 7a 61 10 	movl   $0xf010617a,0xc(%esp)
f0101769:	f0 
f010176a:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101771:	f0 
f0101772:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0101779:	00 
f010177a:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101781:	e8 17 e9 ff ff       	call   f010009d <_panic>
f0101786:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101787:	39 d0                	cmp    %edx,%eax
f0101789:	75 d2                	jne    f010175d <mem_init+0x5c9>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010178b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010178e:	89 15 a0 61 1e f0    	mov    %edx,0xf01e61a0

	// free the pages we took
	page_free(pp0);
f0101794:	89 34 24             	mov    %esi,(%esp)
f0101797:	e8 c9 f6 ff ff       	call   f0100e65 <page_free>
	page_free(pp1);
f010179c:	89 3c 24             	mov    %edi,(%esp)
f010179f:	e8 c1 f6 ff ff       	call   f0100e65 <page_free>
	page_free(pp2);
f01017a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017a7:	89 04 24             	mov    %eax,(%esp)
f01017aa:	e8 b6 f6 ff ff       	call   f0100e65 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017af:	a1 a0 61 1e f0       	mov    0xf01e61a0,%eax
f01017b4:	eb 03                	jmp    f01017b9 <mem_init+0x625>
		--nfree;
f01017b6:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017b7:	8b 00                	mov    (%eax),%eax
f01017b9:	85 c0                	test   %eax,%eax
f01017bb:	75 f9                	jne    f01017b6 <mem_init+0x622>
		--nfree;
	assert(nfree == 0);
f01017bd:	85 db                	test   %ebx,%ebx
f01017bf:	74 24                	je     f01017e5 <mem_init+0x651>
f01017c1:	c7 44 24 0c 84 61 10 	movl   $0xf0106184,0xc(%esp)
f01017c8:	f0 
f01017c9:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01017d0:	f0 
f01017d1:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f01017d8:	00 
f01017d9:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01017e0:	e8 b8 e8 ff ff       	call   f010009d <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017e5:	c7 04 24 48 59 10 f0 	movl   $0xf0105948,(%esp)
f01017ec:	e8 65 1f 00 00       	call   f0103756 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017f8:	e8 b5 f5 ff ff       	call   f0100db2 <page_alloc>
f01017fd:	89 c7                	mov    %eax,%edi
f01017ff:	85 c0                	test   %eax,%eax
f0101801:	75 24                	jne    f0101827 <mem_init+0x693>
f0101803:	c7 44 24 0c 92 60 10 	movl   $0xf0106092,0xc(%esp)
f010180a:	f0 
f010180b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101812:	f0 
f0101813:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f010181a:	00 
f010181b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101822:	e8 76 e8 ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0101827:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010182e:	e8 7f f5 ff ff       	call   f0100db2 <page_alloc>
f0101833:	89 c6                	mov    %eax,%esi
f0101835:	85 c0                	test   %eax,%eax
f0101837:	75 24                	jne    f010185d <mem_init+0x6c9>
f0101839:	c7 44 24 0c a8 60 10 	movl   $0xf01060a8,0xc(%esp)
f0101840:	f0 
f0101841:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101848:	f0 
f0101849:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101850:	00 
f0101851:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101858:	e8 40 e8 ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f010185d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101864:	e8 49 f5 ff ff       	call   f0100db2 <page_alloc>
f0101869:	89 c3                	mov    %eax,%ebx
f010186b:	85 c0                	test   %eax,%eax
f010186d:	75 24                	jne    f0101893 <mem_init+0x6ff>
f010186f:	c7 44 24 0c be 60 10 	movl   $0xf01060be,0xc(%esp)
f0101876:	f0 
f0101877:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010187e:	f0 
f010187f:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101886:	00 
f0101887:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010188e:	e8 0a e8 ff ff       	call   f010009d <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101893:	39 f7                	cmp    %esi,%edi
f0101895:	75 24                	jne    f01018bb <mem_init+0x727>
f0101897:	c7 44 24 0c d4 60 10 	movl   $0xf01060d4,0xc(%esp)
f010189e:	f0 
f010189f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01018a6:	f0 
f01018a7:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f01018ae:	00 
f01018af:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01018b6:	e8 e2 e7 ff ff       	call   f010009d <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018bb:	39 c6                	cmp    %eax,%esi
f01018bd:	74 04                	je     f01018c3 <mem_init+0x72f>
f01018bf:	39 c7                	cmp    %eax,%edi
f01018c1:	75 24                	jne    f01018e7 <mem_init+0x753>
f01018c3:	c7 44 24 0c 28 59 10 	movl   $0xf0105928,0xc(%esp)
f01018ca:	f0 
f01018cb:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01018d2:	f0 
f01018d3:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01018da:	00 
f01018db:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01018e2:	e8 b6 e7 ff ff       	call   f010009d <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018e7:	8b 15 a0 61 1e f0    	mov    0xf01e61a0,%edx
f01018ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f01018f0:	c7 05 a0 61 1e f0 00 	movl   $0x0,0xf01e61a0
f01018f7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101901:	e8 ac f4 ff ff       	call   f0100db2 <page_alloc>
f0101906:	85 c0                	test   %eax,%eax
f0101908:	74 24                	je     f010192e <mem_init+0x79a>
f010190a:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f0101911:	f0 
f0101912:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101919:	f0 
f010191a:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101921:	00 
f0101922:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101929:	e8 6f e7 ff ff       	call   f010009d <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010192e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101931:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101935:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010193c:	00 
f010193d:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101942:	89 04 24             	mov    %eax,(%esp)
f0101945:	e8 f9 f6 ff ff       	call   f0101043 <page_lookup>
f010194a:	85 c0                	test   %eax,%eax
f010194c:	74 24                	je     f0101972 <mem_init+0x7de>
f010194e:	c7 44 24 0c 68 59 10 	movl   $0xf0105968,0xc(%esp)
f0101955:	f0 
f0101956:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010195d:	f0 
f010195e:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101965:	00 
f0101966:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010196d:	e8 2b e7 ff ff       	call   f010009d <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101972:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101979:	00 
f010197a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101981:	00 
f0101982:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101986:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f010198b:	89 04 24             	mov    %eax,(%esp)
f010198e:	e8 7b f7 ff ff       	call   f010110e <page_insert>
f0101993:	85 c0                	test   %eax,%eax
f0101995:	78 24                	js     f01019bb <mem_init+0x827>
f0101997:	c7 44 24 0c a0 59 10 	movl   $0xf01059a0,0xc(%esp)
f010199e:	f0 
f010199f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01019a6:	f0 
f01019a7:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f01019ae:	00 
f01019af:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01019b6:	e8 e2 e6 ff ff       	call   f010009d <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019bb:	89 3c 24             	mov    %edi,(%esp)
f01019be:	e8 a2 f4 ff ff       	call   f0100e65 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019c3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01019ca:	00 
f01019cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01019d2:	00 
f01019d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019d7:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f01019dc:	89 04 24             	mov    %eax,(%esp)
f01019df:	e8 2a f7 ff ff       	call   f010110e <page_insert>
f01019e4:	85 c0                	test   %eax,%eax
f01019e6:	74 24                	je     f0101a0c <mem_init+0x878>
f01019e8:	c7 44 24 0c d0 59 10 	movl   $0xf01059d0,0xc(%esp)
f01019ef:	f0 
f01019f0:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01019f7:	f0 
f01019f8:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01019ff:	00 
f0101a00:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101a07:	e8 91 e6 ff ff       	call   f010009d <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a0c:	8b 0d 48 6e 1e f0    	mov    0xf01e6e48,%ecx
f0101a12:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a15:	a1 4c 6e 1e f0       	mov    0xf01e6e4c,%eax
f0101a1a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a1d:	8b 11                	mov    (%ecx),%edx
f0101a1f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a25:	89 f8                	mov    %edi,%eax
f0101a27:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101a2a:	c1 f8 03             	sar    $0x3,%eax
f0101a2d:	c1 e0 0c             	shl    $0xc,%eax
f0101a30:	39 c2                	cmp    %eax,%edx
f0101a32:	74 24                	je     f0101a58 <mem_init+0x8c4>
f0101a34:	c7 44 24 0c 00 5a 10 	movl   $0xf0105a00,0xc(%esp)
f0101a3b:	f0 
f0101a3c:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101a43:	f0 
f0101a44:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0101a4b:	00 
f0101a4c:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101a53:	e8 45 e6 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a58:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a60:	e8 83 ee ff ff       	call   f01008e8 <check_va2pa>
f0101a65:	89 f2                	mov    %esi,%edx
f0101a67:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101a6a:	c1 fa 03             	sar    $0x3,%edx
f0101a6d:	c1 e2 0c             	shl    $0xc,%edx
f0101a70:	39 d0                	cmp    %edx,%eax
f0101a72:	74 24                	je     f0101a98 <mem_init+0x904>
f0101a74:	c7 44 24 0c 28 5a 10 	movl   $0xf0105a28,0xc(%esp)
f0101a7b:	f0 
f0101a7c:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101a83:	f0 
f0101a84:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101a8b:	00 
f0101a8c:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101a93:	e8 05 e6 ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 1);
f0101a98:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a9d:	74 24                	je     f0101ac3 <mem_init+0x92f>
f0101a9f:	c7 44 24 0c 8f 61 10 	movl   $0xf010618f,0xc(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101aae:	f0 
f0101aaf:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101ab6:	00 
f0101ab7:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101abe:	e8 da e5 ff ff       	call   f010009d <_panic>
	assert(pp0->pp_ref == 1);
f0101ac3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ac8:	74 24                	je     f0101aee <mem_init+0x95a>
f0101aca:	c7 44 24 0c a0 61 10 	movl   $0xf01061a0,0xc(%esp)
f0101ad1:	f0 
f0101ad2:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101ad9:	f0 
f0101ada:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101ae1:	00 
f0101ae2:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101ae9:	e8 af e5 ff ff       	call   f010009d <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aee:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101af5:	00 
f0101af6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101afd:	00 
f0101afe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b02:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101b05:	89 14 24             	mov    %edx,(%esp)
f0101b08:	e8 01 f6 ff ff       	call   f010110e <page_insert>
f0101b0d:	85 c0                	test   %eax,%eax
f0101b0f:	74 24                	je     f0101b35 <mem_init+0x9a1>
f0101b11:	c7 44 24 0c 58 5a 10 	movl   $0xf0105a58,0xc(%esp)
f0101b18:	f0 
f0101b19:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101b20:	f0 
f0101b21:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0101b28:	00 
f0101b29:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101b30:	e8 68 e5 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b35:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b3a:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101b3f:	e8 a4 ed ff ff       	call   f01008e8 <check_va2pa>
f0101b44:	89 da                	mov    %ebx,%edx
f0101b46:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f0101b4c:	c1 fa 03             	sar    $0x3,%edx
f0101b4f:	c1 e2 0c             	shl    $0xc,%edx
f0101b52:	39 d0                	cmp    %edx,%eax
f0101b54:	74 24                	je     f0101b7a <mem_init+0x9e6>
f0101b56:	c7 44 24 0c 94 5a 10 	movl   $0xf0105a94,0xc(%esp)
f0101b5d:	f0 
f0101b5e:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101b65:	f0 
f0101b66:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101b6d:	00 
f0101b6e:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101b75:	e8 23 e5 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0101b7a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b7f:	74 24                	je     f0101ba5 <mem_init+0xa11>
f0101b81:	c7 44 24 0c b1 61 10 	movl   $0xf01061b1,0xc(%esp)
f0101b88:	f0 
f0101b89:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101b90:	f0 
f0101b91:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101b98:	00 
f0101b99:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101ba0:	e8 f8 e4 ff ff       	call   f010009d <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ba5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bac:	e8 01 f2 ff ff       	call   f0100db2 <page_alloc>
f0101bb1:	85 c0                	test   %eax,%eax
f0101bb3:	74 24                	je     f0101bd9 <mem_init+0xa45>
f0101bb5:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f0101bbc:	f0 
f0101bbd:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101bc4:	f0 
f0101bc5:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101bcc:	00 
f0101bcd:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101bd4:	e8 c4 e4 ff ff       	call   f010009d <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bd9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101be0:	00 
f0101be1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101be8:	00 
f0101be9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101bed:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101bf2:	89 04 24             	mov    %eax,(%esp)
f0101bf5:	e8 14 f5 ff ff       	call   f010110e <page_insert>
f0101bfa:	85 c0                	test   %eax,%eax
f0101bfc:	74 24                	je     f0101c22 <mem_init+0xa8e>
f0101bfe:	c7 44 24 0c 58 5a 10 	movl   $0xf0105a58,0xc(%esp)
f0101c05:	f0 
f0101c06:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101c0d:	f0 
f0101c0e:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0101c15:	00 
f0101c16:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101c1d:	e8 7b e4 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c27:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101c2c:	e8 b7 ec ff ff       	call   f01008e8 <check_va2pa>
f0101c31:	89 da                	mov    %ebx,%edx
f0101c33:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f0101c39:	c1 fa 03             	sar    $0x3,%edx
f0101c3c:	c1 e2 0c             	shl    $0xc,%edx
f0101c3f:	39 d0                	cmp    %edx,%eax
f0101c41:	74 24                	je     f0101c67 <mem_init+0xad3>
f0101c43:	c7 44 24 0c 94 5a 10 	movl   $0xf0105a94,0xc(%esp)
f0101c4a:	f0 
f0101c4b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101c52:	f0 
f0101c53:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101c5a:	00 
f0101c5b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101c62:	e8 36 e4 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0101c67:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c6c:	74 24                	je     f0101c92 <mem_init+0xafe>
f0101c6e:	c7 44 24 0c b1 61 10 	movl   $0xf01061b1,0xc(%esp)
f0101c75:	f0 
f0101c76:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101c7d:	f0 
f0101c7e:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101c85:	00 
f0101c86:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101c8d:	e8 0b e4 ff ff       	call   f010009d <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c99:	e8 14 f1 ff ff       	call   f0100db2 <page_alloc>
f0101c9e:	85 c0                	test   %eax,%eax
f0101ca0:	74 24                	je     f0101cc6 <mem_init+0xb32>
f0101ca2:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f0101ca9:	f0 
f0101caa:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101cb1:	f0 
f0101cb2:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101cb9:	00 
f0101cba:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101cc1:	e8 d7 e3 ff ff       	call   f010009d <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cc6:	8b 15 48 6e 1e f0    	mov    0xf01e6e48,%edx
f0101ccc:	8b 02                	mov    (%edx),%eax
f0101cce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cd3:	89 c1                	mov    %eax,%ecx
f0101cd5:	c1 e9 0c             	shr    $0xc,%ecx
f0101cd8:	3b 0d 44 6e 1e f0    	cmp    0xf01e6e44,%ecx
f0101cde:	72 20                	jb     f0101d00 <mem_init+0xb6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ce0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ce4:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0101ceb:	f0 
f0101cec:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101cf3:	00 
f0101cf4:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101cfb:	e8 9d e3 ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f0101d00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d0f:	00 
f0101d10:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d17:	00 
f0101d18:	89 14 24             	mov    %edx,(%esp)
f0101d1b:	e8 c1 f1 ff ff       	call   f0100ee1 <pgdir_walk>
f0101d20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101d23:	83 c2 04             	add    $0x4,%edx
f0101d26:	39 d0                	cmp    %edx,%eax
f0101d28:	74 24                	je     f0101d4e <mem_init+0xbba>
f0101d2a:	c7 44 24 0c c4 5a 10 	movl   $0xf0105ac4,0xc(%esp)
f0101d31:	f0 
f0101d32:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101d39:	f0 
f0101d3a:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101d41:	00 
f0101d42:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101d49:	e8 4f e3 ff ff       	call   f010009d <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d4e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101d55:	00 
f0101d56:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d5d:	00 
f0101d5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d62:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101d67:	89 04 24             	mov    %eax,(%esp)
f0101d6a:	e8 9f f3 ff ff       	call   f010110e <page_insert>
f0101d6f:	85 c0                	test   %eax,%eax
f0101d71:	74 24                	je     f0101d97 <mem_init+0xc03>
f0101d73:	c7 44 24 0c 04 5b 10 	movl   $0xf0105b04,0xc(%esp)
f0101d7a:	f0 
f0101d7b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101d82:	f0 
f0101d83:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101d8a:	00 
f0101d8b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101d92:	e8 06 e3 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d97:	8b 0d 48 6e 1e f0    	mov    0xf01e6e48,%ecx
f0101d9d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101da0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da5:	89 c8                	mov    %ecx,%eax
f0101da7:	e8 3c eb ff ff       	call   f01008e8 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dac:	89 da                	mov    %ebx,%edx
f0101dae:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f0101db4:	c1 fa 03             	sar    $0x3,%edx
f0101db7:	c1 e2 0c             	shl    $0xc,%edx
f0101dba:	39 d0                	cmp    %edx,%eax
f0101dbc:	74 24                	je     f0101de2 <mem_init+0xc4e>
f0101dbe:	c7 44 24 0c 94 5a 10 	movl   $0xf0105a94,0xc(%esp)
f0101dc5:	f0 
f0101dc6:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101dcd:	f0 
f0101dce:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101dd5:	00 
f0101dd6:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101ddd:	e8 bb e2 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0101de2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101de7:	74 24                	je     f0101e0d <mem_init+0xc79>
f0101de9:	c7 44 24 0c b1 61 10 	movl   $0xf01061b1,0xc(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101df8:	f0 
f0101df9:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101e00:	00 
f0101e01:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101e08:	e8 90 e2 ff ff       	call   f010009d <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e0d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e14:	00 
f0101e15:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e1c:	00 
f0101e1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e20:	89 04 24             	mov    %eax,(%esp)
f0101e23:	e8 b9 f0 ff ff       	call   f0100ee1 <pgdir_walk>
f0101e28:	f6 00 04             	testb  $0x4,(%eax)
f0101e2b:	75 24                	jne    f0101e51 <mem_init+0xcbd>
f0101e2d:	c7 44 24 0c 44 5b 10 	movl   $0xf0105b44,0xc(%esp)
f0101e34:	f0 
f0101e35:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101e3c:	f0 
f0101e3d:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101e44:	00 
f0101e45:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101e4c:	e8 4c e2 ff ff       	call   f010009d <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e51:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101e56:	f6 00 04             	testb  $0x4,(%eax)
f0101e59:	75 24                	jne    f0101e7f <mem_init+0xceb>
f0101e5b:	c7 44 24 0c c2 61 10 	movl   $0xf01061c2,0xc(%esp)
f0101e62:	f0 
f0101e63:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101e6a:	f0 
f0101e6b:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101e72:	00 
f0101e73:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101e7a:	e8 1e e2 ff ff       	call   f010009d <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e7f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e86:	00 
f0101e87:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e8e:	00 
f0101e8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e93:	89 04 24             	mov    %eax,(%esp)
f0101e96:	e8 73 f2 ff ff       	call   f010110e <page_insert>
f0101e9b:	85 c0                	test   %eax,%eax
f0101e9d:	74 24                	je     f0101ec3 <mem_init+0xd2f>
f0101e9f:	c7 44 24 0c 58 5a 10 	movl   $0xf0105a58,0xc(%esp)
f0101ea6:	f0 
f0101ea7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101eae:	f0 
f0101eaf:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0101eb6:	00 
f0101eb7:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101ebe:	e8 da e1 ff ff       	call   f010009d <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ec3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101eca:	00 
f0101ecb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ed2:	00 
f0101ed3:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101ed8:	89 04 24             	mov    %eax,(%esp)
f0101edb:	e8 01 f0 ff ff       	call   f0100ee1 <pgdir_walk>
f0101ee0:	f6 00 02             	testb  $0x2,(%eax)
f0101ee3:	75 24                	jne    f0101f09 <mem_init+0xd75>
f0101ee5:	c7 44 24 0c 78 5b 10 	movl   $0xf0105b78,0xc(%esp)
f0101eec:	f0 
f0101eed:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101ef4:	f0 
f0101ef5:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101efc:	00 
f0101efd:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101f04:	e8 94 e1 ff ff       	call   f010009d <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f10:	00 
f0101f11:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f18:	00 
f0101f19:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101f1e:	89 04 24             	mov    %eax,(%esp)
f0101f21:	e8 bb ef ff ff       	call   f0100ee1 <pgdir_walk>
f0101f26:	f6 00 04             	testb  $0x4,(%eax)
f0101f29:	74 24                	je     f0101f4f <mem_init+0xdbb>
f0101f2b:	c7 44 24 0c ac 5b 10 	movl   $0xf0105bac,0xc(%esp)
f0101f32:	f0 
f0101f33:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101f3a:	f0 
f0101f3b:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101f42:	00 
f0101f43:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101f4a:	e8 4e e1 ff ff       	call   f010009d <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f4f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f56:	00 
f0101f57:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f5e:	00 
f0101f5f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f63:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101f68:	89 04 24             	mov    %eax,(%esp)
f0101f6b:	e8 9e f1 ff ff       	call   f010110e <page_insert>
f0101f70:	85 c0                	test   %eax,%eax
f0101f72:	78 24                	js     f0101f98 <mem_init+0xe04>
f0101f74:	c7 44 24 0c e4 5b 10 	movl   $0xf0105be4,0xc(%esp)
f0101f7b:	f0 
f0101f7c:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101f83:	f0 
f0101f84:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101f8b:	00 
f0101f8c:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101f93:	e8 05 e1 ff ff       	call   f010009d <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f98:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9f:	00 
f0101fa0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fa7:	00 
f0101fa8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fac:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101fb1:	89 04 24             	mov    %eax,(%esp)
f0101fb4:	e8 55 f1 ff ff       	call   f010110e <page_insert>
f0101fb9:	85 c0                	test   %eax,%eax
f0101fbb:	74 24                	je     f0101fe1 <mem_init+0xe4d>
f0101fbd:	c7 44 24 0c 1c 5c 10 	movl   $0xf0105c1c,0xc(%esp)
f0101fc4:	f0 
f0101fc5:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0101fcc:	f0 
f0101fcd:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101fd4:	00 
f0101fd5:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0101fdc:	e8 bc e0 ff ff       	call   f010009d <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fe1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fe8:	00 
f0101fe9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ff0:	00 
f0101ff1:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0101ff6:	89 04 24             	mov    %eax,(%esp)
f0101ff9:	e8 e3 ee ff ff       	call   f0100ee1 <pgdir_walk>
f0101ffe:	f6 00 04             	testb  $0x4,(%eax)
f0102001:	74 24                	je     f0102027 <mem_init+0xe93>
f0102003:	c7 44 24 0c ac 5b 10 	movl   $0xf0105bac,0xc(%esp)
f010200a:	f0 
f010200b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102012:	f0 
f0102013:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010201a:	00 
f010201b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102022:	e8 76 e0 ff ff       	call   f010009d <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102027:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f010202c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010202f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102034:	e8 af e8 ff ff       	call   f01008e8 <check_va2pa>
f0102039:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010203c:	89 f0                	mov    %esi,%eax
f010203e:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0102044:	c1 f8 03             	sar    $0x3,%eax
f0102047:	c1 e0 0c             	shl    $0xc,%eax
f010204a:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010204d:	74 24                	je     f0102073 <mem_init+0xedf>
f010204f:	c7 44 24 0c 58 5c 10 	movl   $0xf0105c58,0xc(%esp)
f0102056:	f0 
f0102057:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010205e:	f0 
f010205f:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102066:	00 
f0102067:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010206e:	e8 2a e0 ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102073:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102078:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010207b:	e8 68 e8 ff ff       	call   f01008e8 <check_va2pa>
f0102080:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102083:	74 24                	je     f01020a9 <mem_init+0xf15>
f0102085:	c7 44 24 0c 84 5c 10 	movl   $0xf0105c84,0xc(%esp)
f010208c:	f0 
f010208d:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102094:	f0 
f0102095:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010209c:	00 
f010209d:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01020a4:	e8 f4 df ff ff       	call   f010009d <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01020a9:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f01020ae:	74 24                	je     f01020d4 <mem_init+0xf40>
f01020b0:	c7 44 24 0c d8 61 10 	movl   $0xf01061d8,0xc(%esp)
f01020b7:	f0 
f01020b8:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01020bf:	f0 
f01020c0:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01020c7:	00 
f01020c8:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01020cf:	e8 c9 df ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 0);
f01020d4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020d9:	74 24                	je     f01020ff <mem_init+0xf6b>
f01020db:	c7 44 24 0c e9 61 10 	movl   $0xf01061e9,0xc(%esp)
f01020e2:	f0 
f01020e3:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01020ea:	f0 
f01020eb:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01020f2:	00 
f01020f3:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01020fa:	e8 9e df ff ff       	call   f010009d <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102106:	e8 a7 ec ff ff       	call   f0100db2 <page_alloc>
f010210b:	85 c0                	test   %eax,%eax
f010210d:	74 04                	je     f0102113 <mem_init+0xf7f>
f010210f:	39 c3                	cmp    %eax,%ebx
f0102111:	74 24                	je     f0102137 <mem_init+0xfa3>
f0102113:	c7 44 24 0c b4 5c 10 	movl   $0xf0105cb4,0xc(%esp)
f010211a:	f0 
f010211b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102122:	f0 
f0102123:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f010212a:	00 
f010212b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102132:	e8 66 df ff ff       	call   f010009d <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102137:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010213e:	00 
f010213f:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102144:	89 04 24             	mov    %eax,(%esp)
f0102147:	e8 72 ef ff ff       	call   f01010be <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010214c:	8b 15 48 6e 1e f0    	mov    0xf01e6e48,%edx
f0102152:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102155:	ba 00 00 00 00       	mov    $0x0,%edx
f010215a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010215d:	e8 86 e7 ff ff       	call   f01008e8 <check_va2pa>
f0102162:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102165:	74 24                	je     f010218b <mem_init+0xff7>
f0102167:	c7 44 24 0c d8 5c 10 	movl   $0xf0105cd8,0xc(%esp)
f010216e:	f0 
f010216f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102176:	f0 
f0102177:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f010217e:	00 
f010217f:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102186:	e8 12 df ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010218b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102190:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102193:	e8 50 e7 ff ff       	call   f01008e8 <check_va2pa>
f0102198:	89 f2                	mov    %esi,%edx
f010219a:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f01021a0:	c1 fa 03             	sar    $0x3,%edx
f01021a3:	c1 e2 0c             	shl    $0xc,%edx
f01021a6:	39 d0                	cmp    %edx,%eax
f01021a8:	74 24                	je     f01021ce <mem_init+0x103a>
f01021aa:	c7 44 24 0c 84 5c 10 	movl   $0xf0105c84,0xc(%esp)
f01021b1:	f0 
f01021b2:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01021b9:	f0 
f01021ba:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f01021c1:	00 
f01021c2:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01021c9:	e8 cf de ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 1);
f01021ce:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021d3:	74 24                	je     f01021f9 <mem_init+0x1065>
f01021d5:	c7 44 24 0c 8f 61 10 	movl   $0xf010618f,0xc(%esp)
f01021dc:	f0 
f01021dd:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01021e4:	f0 
f01021e5:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01021ec:	00 
f01021ed:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01021f4:	e8 a4 de ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 0);
f01021f9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021fe:	74 24                	je     f0102224 <mem_init+0x1090>
f0102200:	c7 44 24 0c e9 61 10 	movl   $0xf01061e9,0xc(%esp)
f0102207:	f0 
f0102208:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010220f:	f0 
f0102210:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f0102217:	00 
f0102218:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010221f:	e8 79 de ff ff       	call   f010009d <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102224:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010222b:	00 
f010222c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102233:	00 
f0102234:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102238:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010223b:	89 0c 24             	mov    %ecx,(%esp)
f010223e:	e8 cb ee ff ff       	call   f010110e <page_insert>
f0102243:	85 c0                	test   %eax,%eax
f0102245:	74 24                	je     f010226b <mem_init+0x10d7>
f0102247:	c7 44 24 0c fc 5c 10 	movl   $0xf0105cfc,0xc(%esp)
f010224e:	f0 
f010224f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102256:	f0 
f0102257:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f010225e:	00 
f010225f:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102266:	e8 32 de ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref);
f010226b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102270:	75 24                	jne    f0102296 <mem_init+0x1102>
f0102272:	c7 44 24 0c fa 61 10 	movl   $0xf01061fa,0xc(%esp)
f0102279:	f0 
f010227a:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102281:	f0 
f0102282:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0102289:	00 
f010228a:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102291:	e8 07 de ff ff       	call   f010009d <_panic>
	assert(pp1->pp_link == NULL);
f0102296:	83 3e 00             	cmpl   $0x0,(%esi)
f0102299:	74 24                	je     f01022bf <mem_init+0x112b>
f010229b:	c7 44 24 0c 06 62 10 	movl   $0xf0106206,0xc(%esp)
f01022a2:	f0 
f01022a3:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f01022b2:	00 
f01022b3:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01022ba:	e8 de dd ff ff       	call   f010009d <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022bf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022c6:	00 
f01022c7:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f01022cc:	89 04 24             	mov    %eax,(%esp)
f01022cf:	e8 ea ed ff ff       	call   f01010be <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022d4:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f01022d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022dc:	ba 00 00 00 00       	mov    $0x0,%edx
f01022e1:	e8 02 e6 ff ff       	call   f01008e8 <check_va2pa>
f01022e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022e9:	74 24                	je     f010230f <mem_init+0x117b>
f01022eb:	c7 44 24 0c d8 5c 10 	movl   $0xf0105cd8,0xc(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01022fa:	f0 
f01022fb:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102302:	00 
f0102303:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010230a:	e8 8e dd ff ff       	call   f010009d <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010230f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102314:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102317:	e8 cc e5 ff ff       	call   f01008e8 <check_va2pa>
f010231c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010231f:	74 24                	je     f0102345 <mem_init+0x11b1>
f0102321:	c7 44 24 0c 34 5d 10 	movl   $0xf0105d34,0xc(%esp)
f0102328:	f0 
f0102329:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102330:	f0 
f0102331:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102338:	00 
f0102339:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102340:	e8 58 dd ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 0);
f0102345:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010234a:	74 24                	je     f0102370 <mem_init+0x11dc>
f010234c:	c7 44 24 0c 1b 62 10 	movl   $0xf010621b,0xc(%esp)
f0102353:	f0 
f0102354:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010235b:	f0 
f010235c:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102363:	00 
f0102364:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010236b:	e8 2d dd ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 0);
f0102370:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102375:	74 24                	je     f010239b <mem_init+0x1207>
f0102377:	c7 44 24 0c e9 61 10 	movl   $0xf01061e9,0xc(%esp)
f010237e:	f0 
f010237f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102386:	f0 
f0102387:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f010238e:	00 
f010238f:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102396:	e8 02 dd ff ff       	call   f010009d <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010239b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023a2:	e8 0b ea ff ff       	call   f0100db2 <page_alloc>
f01023a7:	85 c0                	test   %eax,%eax
f01023a9:	74 04                	je     f01023af <mem_init+0x121b>
f01023ab:	39 c6                	cmp    %eax,%esi
f01023ad:	74 24                	je     f01023d3 <mem_init+0x123f>
f01023af:	c7 44 24 0c 5c 5d 10 	movl   $0xf0105d5c,0xc(%esp)
f01023b6:	f0 
f01023b7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01023be:	f0 
f01023bf:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f01023c6:	00 
f01023c7:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01023ce:	e8 ca dc ff ff       	call   f010009d <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01023d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023da:	e8 d3 e9 ff ff       	call   f0100db2 <page_alloc>
f01023df:	85 c0                	test   %eax,%eax
f01023e1:	74 24                	je     f0102407 <mem_init+0x1273>
f01023e3:	c7 44 24 0c 3d 61 10 	movl   $0xf010613d,0xc(%esp)
f01023ea:	f0 
f01023eb:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01023f2:	f0 
f01023f3:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f01023fa:	00 
f01023fb:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102402:	e8 96 dc ff ff       	call   f010009d <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102407:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f010240c:	8b 08                	mov    (%eax),%ecx
f010240e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102414:	89 fa                	mov    %edi,%edx
f0102416:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f010241c:	c1 fa 03             	sar    $0x3,%edx
f010241f:	c1 e2 0c             	shl    $0xc,%edx
f0102422:	39 d1                	cmp    %edx,%ecx
f0102424:	74 24                	je     f010244a <mem_init+0x12b6>
f0102426:	c7 44 24 0c 00 5a 10 	movl   $0xf0105a00,0xc(%esp)
f010242d:	f0 
f010242e:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102435:	f0 
f0102436:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f010243d:	00 
f010243e:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102445:	e8 53 dc ff ff       	call   f010009d <_panic>
	kern_pgdir[0] = 0;
f010244a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102450:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102455:	74 24                	je     f010247b <mem_init+0x12e7>
f0102457:	c7 44 24 0c a0 61 10 	movl   $0xf01061a0,0xc(%esp)
f010245e:	f0 
f010245f:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102466:	f0 
f0102467:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f010246e:	00 
f010246f:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102476:	e8 22 dc ff ff       	call   f010009d <_panic>
	pp0->pp_ref = 0;
f010247b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102481:	89 3c 24             	mov    %edi,(%esp)
f0102484:	e8 dc e9 ff ff       	call   f0100e65 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102489:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102490:	00 
f0102491:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102498:	00 
f0102499:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f010249e:	89 04 24             	mov    %eax,(%esp)
f01024a1:	e8 3b ea ff ff       	call   f0100ee1 <pgdir_walk>
f01024a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01024a9:	8b 0d 48 6e 1e f0    	mov    0xf01e6e48,%ecx
f01024af:	8b 51 04             	mov    0x4(%ecx),%edx
f01024b2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01024b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024bb:	8b 15 44 6e 1e f0    	mov    0xf01e6e44,%edx
f01024c1:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01024c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024c7:	c1 ea 0c             	shr    $0xc,%edx
f01024ca:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01024cd:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01024d0:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01024d3:	72 23                	jb     f01024f8 <mem_init+0x1364>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024d5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024d8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01024dc:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f01024e3:	f0 
f01024e4:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f01024eb:	00 
f01024ec:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01024f3:	e8 a5 db ff ff       	call   f010009d <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024fb:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102501:	39 d0                	cmp    %edx,%eax
f0102503:	74 24                	je     f0102529 <mem_init+0x1395>
f0102505:	c7 44 24 0c 2c 62 10 	movl   $0xf010622c,0xc(%esp)
f010250c:	f0 
f010250d:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102514:	f0 
f0102515:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f010251c:	00 
f010251d:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102524:	e8 74 db ff ff       	call   f010009d <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102529:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102530:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102536:	89 f8                	mov    %edi,%eax
f0102538:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f010253e:	c1 f8 03             	sar    $0x3,%eax
f0102541:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102544:	89 c1                	mov    %eax,%ecx
f0102546:	c1 e9 0c             	shr    $0xc,%ecx
f0102549:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f010254c:	77 20                	ja     f010256e <mem_init+0x13da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010254e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102552:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0102559:	f0 
f010255a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102561:	00 
f0102562:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0102569:	e8 2f db ff ff       	call   f010009d <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010256e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102575:	00 
f0102576:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010257d:	00 
	return (void *)(pa + KERNBASE);
f010257e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102583:	89 04 24             	mov    %eax,(%esp)
f0102586:	e8 37 28 00 00       	call   f0104dc2 <memset>
	page_free(pp0);
f010258b:	89 3c 24             	mov    %edi,(%esp)
f010258e:	e8 d2 e8 ff ff       	call   f0100e65 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102593:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010259a:	00 
f010259b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01025a2:	00 
f01025a3:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f01025a8:	89 04 24             	mov    %eax,(%esp)
f01025ab:	e8 31 e9 ff ff       	call   f0100ee1 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b0:	89 fa                	mov    %edi,%edx
f01025b2:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f01025b8:	c1 fa 03             	sar    $0x3,%edx
f01025bb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025be:	89 d0                	mov    %edx,%eax
f01025c0:	c1 e8 0c             	shr    $0xc,%eax
f01025c3:	3b 05 44 6e 1e f0    	cmp    0xf01e6e44,%eax
f01025c9:	72 20                	jb     f01025eb <mem_init+0x1457>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01025cf:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f01025d6:	f0 
f01025d7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01025de:	00 
f01025df:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f01025e6:	e8 b2 da ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f01025eb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01025f4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025fa:	f6 00 01             	testb  $0x1,(%eax)
f01025fd:	74 24                	je     f0102623 <mem_init+0x148f>
f01025ff:	c7 44 24 0c 44 62 10 	movl   $0xf0106244,0xc(%esp)
f0102606:	f0 
f0102607:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010260e:	f0 
f010260f:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102616:	00 
f0102617:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010261e:	e8 7a da ff ff       	call   f010009d <_panic>
f0102623:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102626:	39 d0                	cmp    %edx,%eax
f0102628:	75 d0                	jne    f01025fa <mem_init+0x1466>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010262a:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f010262f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102635:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010263b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010263e:	89 0d a0 61 1e f0    	mov    %ecx,0xf01e61a0

	// free the pages we took
	page_free(pp0);
f0102644:	89 3c 24             	mov    %edi,(%esp)
f0102647:	e8 19 e8 ff ff       	call   f0100e65 <page_free>
	page_free(pp1);
f010264c:	89 34 24             	mov    %esi,(%esp)
f010264f:	e8 11 e8 ff ff       	call   f0100e65 <page_free>
	page_free(pp2);
f0102654:	89 1c 24             	mov    %ebx,(%esp)
f0102657:	e8 09 e8 ff ff       	call   f0100e65 <page_free>

	cprintf("check_page() succeeded!\n");
f010265c:	c7 04 24 5b 62 10 f0 	movl   $0xf010625b,(%esp)
f0102663:	e8 ee 10 00 00       	call   f0103756 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_U|PTE_P);
f0102668:	a1 4c 6e 1e f0       	mov    0xf01e6e4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010266d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102672:	77 20                	ja     f0102694 <mem_init+0x1500>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102674:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102678:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f010267f:	f0 
f0102680:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102687:	00 
f0102688:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010268f:	e8 09 da ff ff       	call   f010009d <_panic>
f0102694:	8b 15 44 6e 1e f0    	mov    0xf01e6e44,%edx
f010269a:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f01026a1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01026a7:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01026ae:	00 
	return (physaddr_t)kva - KERNBASE;
f01026af:	05 00 00 00 10       	add    $0x10000000,%eax
f01026b4:	89 04 24             	mov    %eax,(%esp)
f01026b7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026bc:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f01026c1:	e8 20 e9 ff ff       	call   f0100fe6 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U);
f01026c6:	a1 ac 61 1e f0       	mov    0xf01e61ac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d0:	77 20                	ja     f01026f2 <mem_init+0x155e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026d6:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f01026dd:	f0 
f01026de:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f01026e5:	00 
f01026e6:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01026ed:	e8 ab d9 ff ff       	call   f010009d <_panic>
f01026f2:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f01026f9:	00 
	return (physaddr_t)kva - KERNBASE;
f01026fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01026ff:	89 04 24             	mov    %eax,(%esp)
f0102702:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102707:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010270c:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102711:	e8 d0 e8 ff ff       	call   f0100fe6 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102716:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f010271b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102720:	77 20                	ja     f0102742 <mem_init+0x15ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102722:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102726:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f010272d:	f0 
f010272e:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102735:	00 
f0102736:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010273d:	e8 5b d9 ff ff       	call   f010009d <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE , PADDR(bootstack), PTE_W);
f0102742:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102749:	00 
f010274a:	c7 04 24 00 a0 11 00 	movl   $0x11a000,(%esp)
f0102751:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102756:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010275b:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102760:	e8 81 e8 ff ff       	call   f0100fe6 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KERNBASE, (2^32)-KERNBASE, 0, PTE_W);
f0102765:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010276c:	00 
f010276d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102774:	b9 22 00 00 10       	mov    $0x10000022,%ecx
f0102779:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010277e:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102783:	e8 5e e8 ff ff       	call   f0100fe6 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102788:	8b 1d 48 6e 1e f0    	mov    0xf01e6e48,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010278e:	8b 15 44 6e 1e f0    	mov    0xf01e6e44,%edx
f0102794:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102797:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f010279e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f01027a4:	be 00 00 00 00       	mov    $0x0,%esi
f01027a9:	eb 70                	jmp    f010281b <mem_init+0x1687>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01027ab:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027b1:	89 d8                	mov    %ebx,%eax
f01027b3:	e8 30 e1 ff ff       	call   f01008e8 <check_va2pa>
f01027b8:	8b 15 4c 6e 1e f0    	mov    0xf01e6e4c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027be:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027c4:	77 20                	ja     f01027e6 <mem_init+0x1652>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027ca:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f01027d1:	f0 
f01027d2:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f01027d9:	00 
f01027da:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01027e1:	e8 b7 d8 ff ff       	call   f010009d <_panic>
f01027e6:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01027ed:	39 d0                	cmp    %edx,%eax
f01027ef:	74 24                	je     f0102815 <mem_init+0x1681>
f01027f1:	c7 44 24 0c 80 5d 10 	movl   $0xf0105d80,0xc(%esp)
f01027f8:	f0 
f01027f9:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102800:	f0 
f0102801:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0102808:	00 
f0102809:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102810:	e8 88 d8 ff ff       	call   f010009d <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102815:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010281b:	39 f7                	cmp    %esi,%edi
f010281d:	77 8c                	ja     f01027ab <mem_init+0x1617>
f010281f:	be 00 00 00 00       	mov    $0x0,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f0102824:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010282a:	89 d8                	mov    %ebx,%eax
f010282c:	e8 b7 e0 ff ff       	call   f01008e8 <check_va2pa>
f0102831:	8b 15 ac 61 1e f0    	mov    0xf01e61ac,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102837:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010283d:	77 20                	ja     f010285f <mem_init+0x16cb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010283f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102843:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f010284a:	f0 
f010284b:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0102852:	00 
f0102853:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010285a:	e8 3e d8 ff ff       	call   f010009d <_panic>
f010285f:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102866:	39 d0                	cmp    %edx,%eax
f0102868:	74 24                	je     f010288e <mem_init+0x16fa>
f010286a:	c7 44 24 0c b4 5d 10 	movl   $0xf0105db4,0xc(%esp)
f0102871:	f0 
f0102872:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102879:	f0 
f010287a:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0102881:	00 
f0102882:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102889:	e8 0f d8 ff ff       	call   f010009d <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010288e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102894:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f010289a:	75 88                	jne    f0102824 <mem_init+0x1690>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010289c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010289f:	c1 e7 0c             	shl    $0xc,%edi
f01028a2:	be 00 00 00 00       	mov    $0x0,%esi
f01028a7:	eb 3b                	jmp    f01028e4 <mem_init+0x1750>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01028a9:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028af:	89 d8                	mov    %ebx,%eax
f01028b1:	e8 32 e0 ff ff       	call   f01008e8 <check_va2pa>
f01028b6:	39 c6                	cmp    %eax,%esi
f01028b8:	74 24                	je     f01028de <mem_init+0x174a>
f01028ba:	c7 44 24 0c e8 5d 10 	movl   $0xf0105de8,0xc(%esp)
f01028c1:	f0 
f01028c2:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01028c9:	f0 
f01028ca:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f01028d1:	00 
f01028d2:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01028d9:	e8 bf d7 ff ff       	call   f010009d <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01028de:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028e4:	39 fe                	cmp    %edi,%esi
f01028e6:	72 c1                	jb     f01028a9 <mem_init+0x1715>
f01028e8:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01028ed:	bf 00 a0 11 f0       	mov    $0xf011a000,%edi
f01028f2:	81 c7 00 80 00 20    	add    $0x20008000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028f8:	89 f2                	mov    %esi,%edx
f01028fa:	89 d8                	mov    %ebx,%eax
f01028fc:	e8 e7 df ff ff       	call   f01008e8 <check_va2pa>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f0102901:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102904:	39 d0                	cmp    %edx,%eax
f0102906:	74 24                	je     f010292c <mem_init+0x1798>
f0102908:	c7 44 24 0c 10 5e 10 	movl   $0xf0105e10,0xc(%esp)
f010290f:	f0 
f0102910:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102917:	f0 
f0102918:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f010291f:	00 
f0102920:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102927:	e8 71 d7 ff ff       	call   f010009d <_panic>
f010292c:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102932:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102938:	75 be                	jne    f01028f8 <mem_init+0x1764>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010293a:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010293f:	89 d8                	mov    %ebx,%eax
f0102941:	e8 a2 df ff ff       	call   f01008e8 <check_va2pa>
f0102946:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102949:	74 24                	je     f010296f <mem_init+0x17db>
f010294b:	c7 44 24 0c 58 5e 10 	movl   $0xf0105e58,0xc(%esp)
f0102952:	f0 
f0102953:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010295a:	f0 
f010295b:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0102962:	00 
f0102963:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f010296a:	e8 2e d7 ff ff       	call   f010009d <_panic>
f010296f:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102974:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102979:	72 3c                	jb     f01029b7 <mem_init+0x1823>
f010297b:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102980:	76 07                	jbe    f0102989 <mem_init+0x17f5>
f0102982:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102987:	75 2e                	jne    f01029b7 <mem_init+0x1823>
			case PDX(UVPT):
			case PDX(KSTACKTOP-1):
			case PDX(UPAGES):
			case PDX(UENVS):
				assert(pgdir[i] & PTE_P);
f0102989:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010298d:	0f 85 aa 00 00 00    	jne    f0102a3d <mem_init+0x18a9>
f0102993:	c7 44 24 0c 74 62 10 	movl   $0xf0106274,0xc(%esp)
f010299a:	f0 
f010299b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01029a2:	f0 
f01029a3:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01029aa:	00 
f01029ab:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01029b2:	e8 e6 d6 ff ff       	call   f010009d <_panic>
				break;
			default:
				if (i >= PDX(KERNBASE)) {
f01029b7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029bc:	76 55                	jbe    f0102a13 <mem_init+0x187f>
					assert(pgdir[i] & PTE_P);
f01029be:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01029c1:	f6 c2 01             	test   $0x1,%dl
f01029c4:	75 24                	jne    f01029ea <mem_init+0x1856>
f01029c6:	c7 44 24 0c 74 62 10 	movl   $0xf0106274,0xc(%esp)
f01029cd:	f0 
f01029ce:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01029d5:	f0 
f01029d6:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01029dd:	00 
f01029de:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f01029e5:	e8 b3 d6 ff ff       	call   f010009d <_panic>
					assert(pgdir[i] & PTE_W);
f01029ea:	f6 c2 02             	test   $0x2,%dl
f01029ed:	75 4e                	jne    f0102a3d <mem_init+0x18a9>
f01029ef:	c7 44 24 0c 85 62 10 	movl   $0xf0106285,0xc(%esp)
f01029f6:	f0 
f01029f7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f01029fe:	f0 
f01029ff:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0102a06:	00 
f0102a07:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102a0e:	e8 8a d6 ff ff       	call   f010009d <_panic>
				} else
					assert(pgdir[i] == 0);
f0102a13:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102a17:	74 24                	je     f0102a3d <mem_init+0x18a9>
f0102a19:	c7 44 24 0c 96 62 10 	movl   $0xf0106296,0xc(%esp)
f0102a20:	f0 
f0102a21:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102a28:	f0 
f0102a29:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0102a30:	00 
f0102a31:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102a38:	e8 60 d6 ff ff       	call   f010009d <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a3d:	40                   	inc    %eax
f0102a3e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102a43:	0f 85 2b ff ff ff    	jne    f0102974 <mem_init+0x17e0>
				} else
					assert(pgdir[i] == 0);
				break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a49:	c7 04 24 88 5e 10 f0 	movl   $0xf0105e88,(%esp)
f0102a50:	e8 01 0d 00 00       	call   f0103756 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a55:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a5a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a5f:	77 20                	ja     f0102a81 <mem_init+0x18ed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a61:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a65:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f0102a6c:	f0 
f0102a6d:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
f0102a74:	00 
f0102a75:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102a7c:	e8 1c d6 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a81:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a86:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a89:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a8e:	e8 70 df ff ff       	call   f0100a03 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a93:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102a96:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102a9b:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a9e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102aa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aa8:	e8 05 e3 ff ff       	call   f0100db2 <page_alloc>
f0102aad:	89 c6                	mov    %eax,%esi
f0102aaf:	85 c0                	test   %eax,%eax
f0102ab1:	75 24                	jne    f0102ad7 <mem_init+0x1943>
f0102ab3:	c7 44 24 0c 92 60 10 	movl   $0xf0106092,0xc(%esp)
f0102aba:	f0 
f0102abb:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102ac2:	f0 
f0102ac3:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102aca:	00 
f0102acb:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102ad2:	e8 c6 d5 ff ff       	call   f010009d <_panic>
	assert((pp1 = page_alloc(0)));
f0102ad7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ade:	e8 cf e2 ff ff       	call   f0100db2 <page_alloc>
f0102ae3:	89 c7                	mov    %eax,%edi
f0102ae5:	85 c0                	test   %eax,%eax
f0102ae7:	75 24                	jne    f0102b0d <mem_init+0x1979>
f0102ae9:	c7 44 24 0c a8 60 10 	movl   $0xf01060a8,0xc(%esp)
f0102af0:	f0 
f0102af1:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102af8:	f0 
f0102af9:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102b00:	00 
f0102b01:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102b08:	e8 90 d5 ff ff       	call   f010009d <_panic>
	assert((pp2 = page_alloc(0)));
f0102b0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b14:	e8 99 e2 ff ff       	call   f0100db2 <page_alloc>
f0102b19:	89 c3                	mov    %eax,%ebx
f0102b1b:	85 c0                	test   %eax,%eax
f0102b1d:	75 24                	jne    f0102b43 <mem_init+0x19af>
f0102b1f:	c7 44 24 0c be 60 10 	movl   $0xf01060be,0xc(%esp)
f0102b26:	f0 
f0102b27:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102b2e:	f0 
f0102b2f:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102b36:	00 
f0102b37:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102b3e:	e8 5a d5 ff ff       	call   f010009d <_panic>
	page_free(pp0);
f0102b43:	89 34 24             	mov    %esi,(%esp)
f0102b46:	e8 1a e3 ff ff       	call   f0100e65 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b4b:	89 f8                	mov    %edi,%eax
f0102b4d:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0102b53:	c1 f8 03             	sar    $0x3,%eax
f0102b56:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b59:	89 c2                	mov    %eax,%edx
f0102b5b:	c1 ea 0c             	shr    $0xc,%edx
f0102b5e:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0102b64:	72 20                	jb     f0102b86 <mem_init+0x19f2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b6a:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0102b71:	f0 
f0102b72:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102b79:	00 
f0102b7a:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0102b81:	e8 17 d5 ff ff       	call   f010009d <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b86:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b8d:	00 
f0102b8e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102b95:	00 
	return (void *)(pa + KERNBASE);
f0102b96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b9b:	89 04 24             	mov    %eax,(%esp)
f0102b9e:	e8 1f 22 00 00       	call   f0104dc2 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ba3:	89 d8                	mov    %ebx,%eax
f0102ba5:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0102bab:	c1 f8 03             	sar    $0x3,%eax
f0102bae:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb1:	89 c2                	mov    %eax,%edx
f0102bb3:	c1 ea 0c             	shr    $0xc,%edx
f0102bb6:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0102bbc:	72 20                	jb     f0102bde <mem_init+0x1a4a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bc2:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0102bc9:	f0 
f0102bca:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102bd1:	00 
f0102bd2:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0102bd9:	e8 bf d4 ff ff       	call   f010009d <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102bde:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102be5:	00 
f0102be6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102bed:	00 
	return (void *)(pa + KERNBASE);
f0102bee:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bf3:	89 04 24             	mov    %eax,(%esp)
f0102bf6:	e8 c7 21 00 00       	call   f0104dc2 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102bfb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c02:	00 
f0102c03:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c0a:	00 
f0102c0b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102c0f:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102c14:	89 04 24             	mov    %eax,(%esp)
f0102c17:	e8 f2 e4 ff ff       	call   f010110e <page_insert>
	assert(pp1->pp_ref == 1);
f0102c1c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c21:	74 24                	je     f0102c47 <mem_init+0x1ab3>
f0102c23:	c7 44 24 0c 8f 61 10 	movl   $0xf010618f,0xc(%esp)
f0102c2a:	f0 
f0102c2b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102c32:	f0 
f0102c33:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0102c3a:	00 
f0102c3b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102c42:	e8 56 d4 ff ff       	call   f010009d <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c47:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c4e:	01 01 01 
f0102c51:	74 24                	je     f0102c77 <mem_init+0x1ae3>
f0102c53:	c7 44 24 0c a8 5e 10 	movl   $0xf0105ea8,0xc(%esp)
f0102c5a:	f0 
f0102c5b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102c62:	f0 
f0102c63:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102c6a:	00 
f0102c6b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102c72:	e8 26 d4 ff ff       	call   f010009d <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c77:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c7e:	00 
f0102c7f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c86:	00 
f0102c87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c8b:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102c90:	89 04 24             	mov    %eax,(%esp)
f0102c93:	e8 76 e4 ff ff       	call   f010110e <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c98:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c9f:	02 02 02 
f0102ca2:	74 24                	je     f0102cc8 <mem_init+0x1b34>
f0102ca4:	c7 44 24 0c cc 5e 10 	movl   $0xf0105ecc,0xc(%esp)
f0102cab:	f0 
f0102cac:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102cb3:	f0 
f0102cb4:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102cbb:	00 
f0102cbc:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102cc3:	e8 d5 d3 ff ff       	call   f010009d <_panic>
	assert(pp2->pp_ref == 1);
f0102cc8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ccd:	74 24                	je     f0102cf3 <mem_init+0x1b5f>
f0102ccf:	c7 44 24 0c b1 61 10 	movl   $0xf01061b1,0xc(%esp)
f0102cd6:	f0 
f0102cd7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102cde:	f0 
f0102cdf:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102ce6:	00 
f0102ce7:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102cee:	e8 aa d3 ff ff       	call   f010009d <_panic>
	assert(pp1->pp_ref == 0);
f0102cf3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cf8:	74 24                	je     f0102d1e <mem_init+0x1b8a>
f0102cfa:	c7 44 24 0c 1b 62 10 	movl   $0xf010621b,0xc(%esp)
f0102d01:	f0 
f0102d02:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102d09:	f0 
f0102d0a:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102d11:	00 
f0102d12:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102d19:	e8 7f d3 ff ff       	call   f010009d <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d1e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d25:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d28:	89 d8                	mov    %ebx,%eax
f0102d2a:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0102d30:	c1 f8 03             	sar    $0x3,%eax
f0102d33:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d36:	89 c2                	mov    %eax,%edx
f0102d38:	c1 ea 0c             	shr    $0xc,%edx
f0102d3b:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0102d41:	72 20                	jb     f0102d63 <mem_init+0x1bcf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d43:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d47:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0102d4e:	f0 
f0102d4f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102d56:	00 
f0102d57:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0102d5e:	e8 3a d3 ff ff       	call   f010009d <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d63:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d6a:	03 03 03 
f0102d6d:	74 24                	je     f0102d93 <mem_init+0x1bff>
f0102d6f:	c7 44 24 0c f0 5e 10 	movl   $0xf0105ef0,0xc(%esp)
f0102d76:	f0 
f0102d77:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102d7e:	f0 
f0102d7f:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102d86:	00 
f0102d87:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102d8e:	e8 0a d3 ff ff       	call   f010009d <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d93:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d9a:	00 
f0102d9b:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102da0:	89 04 24             	mov    %eax,(%esp)
f0102da3:	e8 16 e3 ff ff       	call   f01010be <page_remove>
	assert(pp2->pp_ref == 0);
f0102da8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102dad:	74 24                	je     f0102dd3 <mem_init+0x1c3f>
f0102daf:	c7 44 24 0c e9 61 10 	movl   $0xf01061e9,0xc(%esp)
f0102db6:	f0 
f0102db7:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102dbe:	f0 
f0102dbf:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102dc6:	00 
f0102dc7:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102dce:	e8 ca d2 ff ff       	call   f010009d <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dd3:	a1 48 6e 1e f0       	mov    0xf01e6e48,%eax
f0102dd8:	8b 08                	mov    (%eax),%ecx
f0102dda:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102de0:	89 f2                	mov    %esi,%edx
f0102de2:	2b 15 4c 6e 1e f0    	sub    0xf01e6e4c,%edx
f0102de8:	c1 fa 03             	sar    $0x3,%edx
f0102deb:	c1 e2 0c             	shl    $0xc,%edx
f0102dee:	39 d1                	cmp    %edx,%ecx
f0102df0:	74 24                	je     f0102e16 <mem_init+0x1c82>
f0102df2:	c7 44 24 0c 00 5a 10 	movl   $0xf0105a00,0xc(%esp)
f0102df9:	f0 
f0102dfa:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102e01:	f0 
f0102e02:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102e09:	00 
f0102e0a:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102e11:	e8 87 d2 ff ff       	call   f010009d <_panic>
	kern_pgdir[0] = 0;
f0102e16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102e1c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e21:	74 24                	je     f0102e47 <mem_init+0x1cb3>
f0102e23:	c7 44 24 0c a0 61 10 	movl   $0xf01061a0,0xc(%esp)
f0102e2a:	f0 
f0102e2b:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0102e32:	f0 
f0102e33:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f0102e3a:	00 
f0102e3b:	c7 04 24 7d 5f 10 f0 	movl   $0xf0105f7d,(%esp)
f0102e42:	e8 56 d2 ff ff       	call   f010009d <_panic>
	pp0->pp_ref = 0;
f0102e47:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102e4d:	89 34 24             	mov    %esi,(%esp)
f0102e50:	e8 10 e0 ff ff       	call   f0100e65 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e55:	c7 04 24 1c 5f 10 f0 	movl   $0xf0105f1c,(%esp)
f0102e5c:	e8 f5 08 00 00       	call   f0103756 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e61:	83 c4 3c             	add    $0x3c,%esp
f0102e64:	5b                   	pop    %ebx
f0102e65:	5e                   	pop    %esi
f0102e66:	5f                   	pop    %edi
f0102e67:	5d                   	pop    %ebp
f0102e68:	c3                   	ret    

f0102e69 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
	int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e69:	55                   	push   %ebp
f0102e6a:	89 e5                	mov    %esp,%ebp
f0102e6c:	57                   	push   %edi
f0102e6d:	56                   	push   %esi
f0102e6e:	53                   	push   %ebx
f0102e6f:	83 ec 1c             	sub    $0x1c,%esp
f0102e72:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0102e75:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 3: Your code here.
	
	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
f0102e78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e7b:	a3 a4 61 1e f0       	mov    %eax,0xf01e61a4
	pte_t* pte;	
	
	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f0102e80:	89 c6                	mov    %eax,%esi
f0102e82:	03 75 10             	add    0x10(%ebp),%esi
f0102e85:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f0102e8b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102e91:	eb 5e                	jmp    f0102ef1 <user_mem_check+0x88>
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
f0102e93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e9a:	00 
f0102e9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ea4:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0102ea7:	89 04 24             	mov    %eax,(%esp)
f0102eaa:	e8 32 e0 ff ff       	call   f0100ee1 <pgdir_walk>
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
f0102eaf:	85 c0                	test   %eax,%eax
f0102eb1:	74 19                	je     f0102ecc <user_mem_check+0x63>
f0102eb3:	8b 00                	mov    (%eax),%eax
f0102eb5:	89 fa                	mov    %edi,%edx
f0102eb7:	83 ca 01             	or     $0x1,%edx
f0102eba:	09 c2                	or     %eax,%edx
f0102ebc:	39 d0                	cmp    %edx,%eax
f0102ebe:	75 0c                	jne    f0102ecc <user_mem_check+0x63>
f0102ec0:	a1 a4 61 1e f0       	mov    0xf01e61a4,%eax
f0102ec5:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0102eca:	76 1b                	jbe    f0102ee7 <user_mem_check+0x7e>
			if (user_mem_check_addr != start)
f0102ecc:	a1 a4 61 1e f0       	mov    0xf01e61a4,%eax
f0102ed1:	3b 45 0c             	cmp    0xc(%ebp),%eax
f0102ed4:	74 2b                	je     f0102f01 <user_mem_check+0x98>
				user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
f0102ed6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102edb:	a3 a4 61 1e f0       	mov    %eax,0xf01e61a4
			return -E_FAULT;
f0102ee0:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ee5:	eb 1f                	jmp    f0102f06 <user_mem_check+0x9d>
	
	uint32_t start = (uint32_t)va;
	user_mem_check_addr = start;
	pte_t* pte;	
	
	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
f0102ee7:	05 00 10 00 00       	add    $0x1000,%eax
f0102eec:	a3 a4 61 1e f0       	mov    %eax,0xf01e61a4
f0102ef1:	a1 a4 61 1e f0       	mov    0xf01e61a4,%eax
f0102ef6:	39 c6                	cmp    %eax,%esi
f0102ef8:	77 99                	ja     f0102e93 <user_mem_check+0x2a>
				user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
		}
	}
				
	return 0;
f0102efa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eff:	eb 05                	jmp    f0102f06 <user_mem_check+0x9d>
	for (user_mem_check_addr= start; user_mem_check_addr < ROUNDUP(start+len, PGSIZE); user_mem_check_addr+=PGSIZE){
		pte = pgdir_walk(env->env_pgdir, (void*)ROUNDDOWN(user_mem_check_addr, PGSIZE), false);
		if(pte == NULL || (*pte|perm|PTE_P)!=*pte ||user_mem_check_addr >= ULIM){
			if (user_mem_check_addr != start)
				user_mem_check_addr = ROUNDDOWN(user_mem_check_addr, PGSIZE);	
			return -E_FAULT;
f0102f01:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		}
	}
				
	return 0;
}
f0102f06:	83 c4 1c             	add    $0x1c,%esp
f0102f09:	5b                   	pop    %ebx
f0102f0a:	5e                   	pop    %esi
f0102f0b:	5f                   	pop    %edi
f0102f0c:	5d                   	pop    %ebp
f0102f0d:	c3                   	ret    

f0102f0e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
	void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f0e:	55                   	push   %ebp
f0102f0f:	89 e5                	mov    %esp,%ebp
f0102f11:	53                   	push   %ebx
f0102f12:	83 ec 14             	sub    $0x14,%esp
f0102f15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f18:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f1b:	83 c8 04             	or     $0x4,%eax
f0102f1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f22:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f25:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f30:	89 1c 24             	mov    %ebx,(%esp)
f0102f33:	e8 31 ff ff ff       	call   f0102e69 <user_mem_check>
f0102f38:	85 c0                	test   %eax,%eax
f0102f3a:	79 24                	jns    f0102f60 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f3c:	a1 a4 61 1e f0       	mov    0xf01e61a4,%eax
f0102f41:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f45:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f48:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f4c:	c7 04 24 48 5f 10 f0 	movl   $0xf0105f48,(%esp)
f0102f53:	e8 fe 07 00 00       	call   f0103756 <cprintf>
				"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f58:	89 1c 24             	mov    %ebx,(%esp)
f0102f5b:	e8 c5 06 00 00       	call   f0103625 <env_destroy>
	}
}
f0102f60:	83 c4 14             	add    $0x14,%esp
f0102f63:	5b                   	pop    %ebx
f0102f64:	5d                   	pop    %ebp
f0102f65:	c3                   	ret    
	...

f0102f68 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f68:	55                   	push   %ebp
f0102f69:	89 e5                	mov    %esp,%ebp
f0102f6b:	57                   	push   %edi
f0102f6c:	56                   	push   %esi
f0102f6d:	53                   	push   %ebx
f0102f6e:	83 ec 1c             	sub    $0x1c,%esp
f0102f71:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
f0102f73:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102f7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f7f:	89 c7                	mov    %eax,%edi
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
f0102f81:	3d 00 00 c0 ee       	cmp    $0xeec00000,%eax
f0102f86:	77 0d                	ja     f0102f95 <region_alloc+0x2d>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void* max = (void*)ROUNDUP((size_t)va+len, PGSIZE);
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
f0102f88:	89 d3                	mov    %edx,%ebx
f0102f8a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f90:	e9 89 00 00 00       	jmp    f010301e <region_alloc+0xb6>
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
f0102f95:	c7 44 24 08 a4 62 10 	movl   $0xf01062a4,0x8(%esp)
f0102f9c:	f0 
f0102f9d:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
f0102fa4:	00 
f0102fa5:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0102fac:	e8 ec d0 ff ff       	call   f010009d <_panic>
	int r;
	for (; min<max; min+=PGSIZE){
		pp = page_alloc(0);	
f0102fb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fb8:	e8 f5 dd ff ff       	call   f0100db2 <page_alloc>
		if (!pp) 	
f0102fbd:	85 c0                	test   %eax,%eax
f0102fbf:	75 1c                	jne    f0102fdd <region_alloc+0x75>
			panic("region_alloc:page alloc failed");
f0102fc1:	c7 44 24 08 c4 62 10 	movl   $0xf01062c4,0x8(%esp)
f0102fc8:	f0 
f0102fc9:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
f0102fd0:	00 
f0102fd1:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0102fd8:	e8 c0 d0 ff ff       	call   f010009d <_panic>
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
f0102fdd:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102fe4:	00 
f0102fe5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fed:	8b 46 5c             	mov    0x5c(%esi),%eax
f0102ff0:	89 04 24             	mov    %eax,(%esp)
f0102ff3:	e8 16 e1 ff ff       	call   f010110e <page_insert>
		if (r != 0) 
f0102ff8:	85 c0                	test   %eax,%eax
f0102ffa:	74 1c                	je     f0103018 <region_alloc+0xb0>
			panic("region_alloc: page insert failed");
f0102ffc:	c7 44 24 08 e4 62 10 	movl   $0xf01062e4,0x8(%esp)
f0103003:	f0 
f0103004:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
f010300b:	00 
f010300c:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0103013:	e8 85 d0 ff ff       	call   f010009d <_panic>
	void* min = (void*)ROUNDDOWN((size_t)va, PGSIZE);
	struct PageInfo* pp;
	if ((size_t)max > UTOP)
		panic("region_alloc: alloc above UTOP");
	int r;
	for (; min<max; min+=PGSIZE){
f0103018:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010301e:	39 fb                	cmp    %edi,%ebx
f0103020:	72 8f                	jb     f0102fb1 <region_alloc+0x49>
			panic("region_alloc:page alloc failed");
		r = page_insert(e->env_pgdir, pp, min, PTE_W|PTE_U);
		if (r != 0) 
			panic("region_alloc: page insert failed");
	}
}
f0103022:	83 c4 1c             	add    $0x1c,%esp
f0103025:	5b                   	pop    %ebx
f0103026:	5e                   	pop    %esi
f0103027:	5f                   	pop    %edi
f0103028:	5d                   	pop    %ebp
f0103029:	c3                   	ret    

f010302a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010302a:	55                   	push   %ebp
f010302b:	89 e5                	mov    %esp,%ebp
f010302d:	53                   	push   %ebx
f010302e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103031:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103034:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103037:	85 c0                	test   %eax,%eax
f0103039:	75 0e                	jne    f0103049 <envid2env+0x1f>
		*env_store = curenv;
f010303b:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0103040:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103042:	b8 00 00 00 00       	mov    $0x0,%eax
f0103047:	eb 55                	jmp    f010309e <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103049:	89 c2                	mov    %eax,%edx
f010304b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103051:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103054:	c1 e2 05             	shl    $0x5,%edx
f0103057:	03 15 ac 61 1e f0    	add    0xf01e61ac,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010305d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103061:	74 05                	je     f0103068 <envid2env+0x3e>
f0103063:	39 42 48             	cmp    %eax,0x48(%edx)
f0103066:	74 0d                	je     f0103075 <envid2env+0x4b>
		*env_store = 0;
f0103068:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f010306e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103073:	eb 29                	jmp    f010309e <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103075:	84 db                	test   %bl,%bl
f0103077:	74 1e                	je     f0103097 <envid2env+0x6d>
f0103079:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f010307e:	39 c2                	cmp    %eax,%edx
f0103080:	74 15                	je     f0103097 <envid2env+0x6d>
f0103082:	8b 58 48             	mov    0x48(%eax),%ebx
f0103085:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0103088:	74 0d                	je     f0103097 <envid2env+0x6d>
		*env_store = 0;
f010308a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0103090:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103095:	eb 07                	jmp    f010309e <envid2env+0x74>
	}

	*env_store = e;
f0103097:	89 11                	mov    %edx,(%ecx)
	return 0;
f0103099:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010309e:	5b                   	pop    %ebx
f010309f:	5d                   	pop    %ebp
f01030a0:	c3                   	ret    

f01030a1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01030a1:	55                   	push   %ebp
f01030a2:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01030a4:	b8 00 43 12 f0       	mov    $0xf0124300,%eax
f01030a9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01030ac:	b8 23 00 00 00       	mov    $0x23,%eax
f01030b1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01030b3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01030b5:	b0 10                	mov    $0x10,%al
f01030b7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01030b9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01030bb:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01030bd:	ea c4 30 10 f0 08 00 	ljmp   $0x8,$0xf01030c4
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01030c4:	b0 00                	mov    $0x0,%al
f01030c6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01030c9:	5d                   	pop    %ebp
f01030ca:	c3                   	ret    

f01030cb <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01030cb:	55                   	push   %ebp
f01030cc:	89 e5                	mov    %esp,%ebp
f01030ce:	56                   	push   %esi
f01030cf:	53                   	push   %ebx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f01030d0:	8b 35 ac 61 1e f0    	mov    0xf01e61ac,%esi
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01030d6:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f01030dc:	b9 00 00 00 00       	mov    $0x0,%ecx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f01030e1:	ba ff 03 00 00       	mov    $0x3ff,%edx
f01030e6:	eb 02                	jmp    f01030ea <env_init+0x1f>
		envs[i].env_status = ENV_FREE;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01030e8:	89 d9                	mov    %ebx,%ecx
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
		envs[i].env_status = ENV_FREE;
f01030ea:	89 c3                	mov    %eax,%ebx
f01030ec:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01030f3:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030fa:	89 48 44             	mov    %ecx,0x44(%eax)
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;

	for (i = NENV-1; i >= 0;i--){ 
f01030fd:	4a                   	dec    %edx
f01030fe:	83 e8 60             	sub    $0x60,%eax
f0103101:	83 fa ff             	cmp    $0xffffffff,%edx
f0103104:	75 e2                	jne    f01030e8 <env_init+0x1d>
f0103106:	89 35 b0 61 1e f0    	mov    %esi,0xf01e61b0
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f010310c:	e8 90 ff ff ff       	call   f01030a1 <env_init_percpu>
}
f0103111:	5b                   	pop    %ebx
f0103112:	5e                   	pop    %esi
f0103113:	5d                   	pop    %ebp
f0103114:	c3                   	ret    

f0103115 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103115:	55                   	push   %ebp
f0103116:	89 e5                	mov    %esp,%ebp
f0103118:	56                   	push   %esi
f0103119:	53                   	push   %ebx
f010311a:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010311d:	8b 1d b0 61 1e f0    	mov    0xf01e61b0,%ebx
f0103123:	85 db                	test   %ebx,%ebx
f0103125:	0f 84 7f 01 00 00    	je     f01032aa <env_alloc+0x195>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010312b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103132:	e8 7b dc ff ff       	call   f0100db2 <page_alloc>
f0103137:	89 c6                	mov    %eax,%esi
f0103139:	85 c0                	test   %eax,%eax
f010313b:	0f 84 70 01 00 00    	je     f01032b1 <env_alloc+0x19c>
f0103141:	2b 05 4c 6e 1e f0    	sub    0xf01e6e4c,%eax
f0103147:	c1 f8 03             	sar    $0x3,%eax
f010314a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010314d:	89 c2                	mov    %eax,%edx
f010314f:	c1 ea 0c             	shr    $0xc,%edx
f0103152:	3b 15 44 6e 1e f0    	cmp    0xf01e6e44,%edx
f0103158:	72 20                	jb     f010317a <env_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010315a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010315e:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f0103165:	f0 
f0103166:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010316d:	00 
f010316e:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0103175:	e8 23 cf ff ff       	call   f010009d <_panic>
	return (void *)(pa + KERNBASE);
f010317a:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	e->env_pgdir = page2kva(p);
f010317f:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);	
f0103182:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103189:	00 
f010318a:	8b 15 48 6e 1e f0    	mov    0xf01e6e48,%edx
f0103190:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103194:	89 04 24             	mov    %eax,(%esp)
f0103197:	e8 da 1c 00 00       	call   f0104e76 <memcpy>
	p->pp_ref++;
f010319c:	66 ff 46 04          	incw   0x4(%esi)


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031a0:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031a8:	77 20                	ja     f01031ca <env_alloc+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031ae:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f01031b5:	f0 
f01031b6:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01031bd:	00 
f01031be:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f01031c5:	e8 d3 ce ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031ca:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031d0:	83 ca 05             	or     $0x5,%edx
f01031d3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031d9:	8b 43 48             	mov    0x48(%ebx),%eax
f01031dc:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031e1:	89 c1                	mov    %eax,%ecx
f01031e3:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f01031e9:	7f 05                	jg     f01031f0 <env_alloc+0xdb>
		generation = 1 << ENVGENSHIFT;
f01031eb:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f01031f0:	89 d8                	mov    %ebx,%eax
f01031f2:	2b 05 ac 61 1e f0    	sub    0xf01e61ac,%eax
f01031f8:	c1 f8 05             	sar    $0x5,%eax
f01031fb:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01031fe:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103201:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103204:	89 d6                	mov    %edx,%esi
f0103206:	c1 e6 08             	shl    $0x8,%esi
f0103209:	01 f2                	add    %esi,%edx
f010320b:	89 d6                	mov    %edx,%esi
f010320d:	c1 e6 10             	shl    $0x10,%esi
f0103210:	01 f2                	add    %esi,%edx
f0103212:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103215:	09 c1                	or     %eax,%ecx
f0103217:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010321a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010321d:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103220:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103227:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010322e:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103235:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010323c:	00 
f010323d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103244:	00 
f0103245:	89 1c 24             	mov    %ebx,(%esp)
f0103248:	e8 75 1b 00 00       	call   f0104dc2 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010324d:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103253:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103259:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010325f:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103266:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010326c:	8b 43 44             	mov    0x44(%ebx),%eax
f010326f:	a3 b0 61 1e f0       	mov    %eax,0xf01e61b0
	*newenv_store = e;
f0103274:	8b 45 08             	mov    0x8(%ebp),%eax
f0103277:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103279:	8b 53 48             	mov    0x48(%ebx),%edx
f010327c:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0103281:	85 c0                	test   %eax,%eax
f0103283:	74 05                	je     f010328a <env_alloc+0x175>
f0103285:	8b 40 48             	mov    0x48(%eax),%eax
f0103288:	eb 05                	jmp    f010328f <env_alloc+0x17a>
f010328a:	b8 00 00 00 00       	mov    $0x0,%eax
f010328f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103293:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103297:	c7 04 24 e1 63 10 f0 	movl   $0xf01063e1,(%esp)
f010329e:	e8 b3 04 00 00       	call   f0103756 <cprintf>
	return 0;
f01032a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01032a8:	eb 0c                	jmp    f01032b6 <env_alloc+0x1a1>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01032aa:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032af:	eb 05                	jmp    f01032b6 <env_alloc+0x1a1>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01032b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01032b6:	83 c4 10             	add    $0x10,%esp
f01032b9:	5b                   	pop    %ebx
f01032ba:	5e                   	pop    %esi
f01032bb:	5d                   	pop    %ebp
f01032bc:	c3                   	ret    

f01032bd <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01032bd:	55                   	push   %ebp
f01032be:	89 e5                	mov    %esp,%ebp
f01032c0:	57                   	push   %edi
f01032c1:	56                   	push   %esi
f01032c2:	53                   	push   %ebx
f01032c3:	83 ec 3c             	sub    $0x3c,%esp
f01032c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env* e;
	int ret = env_alloc(&e, 0);
f01032c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01032d0:	00 
f01032d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032d4:	89 04 24             	mov    %eax,(%esp)
f01032d7:	e8 39 fe ff ff       	call   f0103115 <env_alloc>
	if (ret == -E_NO_FREE_ENV )
f01032dc:	83 f8 fb             	cmp    $0xfffffffb,%eax
f01032df:	75 24                	jne    f0103305 <env_create+0x48>
		panic("env_create:failed no free env %e", ret);
f01032e1:	c7 44 24 0c fb ff ff 	movl   $0xfffffffb,0xc(%esp)
f01032e8:	ff 
f01032e9:	c7 44 24 08 08 63 10 	movl   $0xf0106308,0x8(%esp)
f01032f0:	f0 
f01032f1:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
f01032f8:	00 
f01032f9:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0103300:	e8 98 cd ff ff       	call   f010009d <_panic>
	if (ret == -E_NO_MEM)
f0103305:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0103308:	75 24                	jne    f010332e <env_create+0x71>
		panic("env_create:failed no free mem %e", ret);
f010330a:	c7 44 24 0c fc ff ff 	movl   $0xfffffffc,0xc(%esp)
f0103311:	ff 
f0103312:	c7 44 24 08 2c 63 10 	movl   $0xf010632c,0x8(%esp)
f0103319:	f0 
f010331a:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
f0103321:	00 
f0103322:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0103329:	e8 6f cd ff ff       	call   f010009d <_panic>
	e->env_type = type;
f010332e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103331:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103334:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103337:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010333a:	89 42 50             	mov    %eax,0x50(%edx)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf*)binary;  //elf header
	if (elf->e_magic != ELF_MAGIC) 
f010333d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103343:	74 1c                	je     f0103361 <env_create+0xa4>
		panic("load_icode: illegal elf header");
f0103345:	c7 44 24 08 50 63 10 	movl   $0xf0106350,0x8(%esp)
f010334c:	f0 
f010334d:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f0103354:	00 
f0103355:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f010335c:	e8 3c cd ff ff       	call   f010009d <_panic>
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
f0103361:	89 fb                	mov    %edi,%ebx
f0103363:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* eph = ph + elf->e_phnum;
f0103366:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010336a:	c1 e6 05             	shl    $0x5,%esi
f010336d:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f010336f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103372:	8b 42 5c             	mov    0x5c(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103375:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010337a:	77 20                	ja     f010339c <env_create+0xdf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103380:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f0103387:	f0 
f0103388:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f010338f:	00 
f0103390:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0103397:	e8 01 cd ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f010339c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01033a1:	0f 22 d8             	mov    %eax,%cr3
f01033a4:	eb 71                	jmp    f0103417 <env_create+0x15a>

	for (; ph < eph; ph++) {
		if(ph->p_type != ELF_PROG_LOAD)
f01033a6:	83 3b 01             	cmpl   $0x1,(%ebx)
f01033a9:	75 69                	jne    f0103414 <env_create+0x157>
			continue;
		if (ph->p_filesz > ph->p_memsz) 
f01033ab:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01033ae:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01033b1:	76 1c                	jbe    f01033cf <env_create+0x112>
			panic("load_icode:file size is larger than mem size");
f01033b3:	c7 44 24 08 70 63 10 	movl   $0xf0106370,0x8(%esp)
f01033ba:	f0 
f01033bb:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f01033c2:	00 
f01033c3:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f01033ca:	e8 ce cc ff ff       	call   f010009d <_panic>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
f01033cf:	8b 53 08             	mov    0x8(%ebx),%edx
f01033d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033d5:	e8 8e fb ff ff       	call   f0102f68 <region_alloc>
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f01033da:	8b 43 10             	mov    0x10(%ebx),%eax
f01033dd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033e1:	89 f8                	mov    %edi,%eax
f01033e3:	03 43 04             	add    0x4(%ebx),%eax
f01033e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033ea:	8b 43 08             	mov    0x8(%ebx),%eax
f01033ed:	89 04 24             	mov    %eax,(%esp)
f01033f0:	e8 17 1a 00 00       	call   f0104e0c <memmove>
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
f01033f5:	8b 43 10             	mov    0x10(%ebx),%eax
f01033f8:	8b 53 14             	mov    0x14(%ebx),%edx
f01033fb:	29 c2                	sub    %eax,%edx
f01033fd:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103401:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103408:	00 
f0103409:	03 43 08             	add    0x8(%ebx),%eax
f010340c:	89 04 24             	mov    %eax,(%esp)
f010340f:	e8 ae 19 00 00       	call   f0104dc2 <memset>
		panic("load_icode: illegal elf header");
	struct Proghdr* ph = (struct Proghdr*)((uint8_t*)elf+ elf->e_phoff); //program header 
	struct Proghdr* eph = ph + elf->e_phnum;
	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++) {
f0103414:	83 c3 20             	add    $0x20,%ebx
f0103417:	39 de                	cmp    %ebx,%esi
f0103419:	77 8b                	ja     f01033a6 <env_create+0xe9>
			panic("load_icode:file size is larger than mem size");
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);	
		memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
		memset((void*)ph->p_va+ph->p_filesz, 0, ph->p_memsz-ph->p_filesz);
	}
	e->env_tf.tf_eip = elf->e_entry; 
f010341b:	8b 47 18             	mov    0x18(%edi),%eax
f010341e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103421:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	//lcr3(PADDR(kern_pgdir));
	region_alloc(e, (void*)(USTACKTOP - PGSIZE), PGSIZE);		
f0103424:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103429:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010342e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103431:	e8 32 fb ff ff       	call   f0102f68 <region_alloc>
		panic("env_create:failed no free env %e", ret);
	if (ret == -E_NO_MEM)
		panic("env_create:failed no free mem %e", ret);
	e->env_type = type;
	load_icode(e, binary);
}
f0103436:	83 c4 3c             	add    $0x3c,%esp
f0103439:	5b                   	pop    %ebx
f010343a:	5e                   	pop    %esi
f010343b:	5f                   	pop    %edi
f010343c:	5d                   	pop    %ebp
f010343d:	c3                   	ret    

f010343e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010343e:	55                   	push   %ebp
f010343f:	89 e5                	mov    %esp,%ebp
f0103441:	57                   	push   %edi
f0103442:	56                   	push   %esi
f0103443:	53                   	push   %ebx
f0103444:	83 ec 2c             	sub    $0x2c,%esp
f0103447:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010344a:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f010344f:	39 c7                	cmp    %eax,%edi
f0103451:	75 37                	jne    f010348a <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103453:	8b 15 48 6e 1e f0    	mov    0xf01e6e48,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103459:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010345f:	77 20                	ja     f0103481 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103461:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103465:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f010346c:	f0 
f010346d:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0103474:	00 
f0103475:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f010347c:	e8 1c cc ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103481:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103487:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010348a:	8b 57 48             	mov    0x48(%edi),%edx
f010348d:	85 c0                	test   %eax,%eax
f010348f:	74 05                	je     f0103496 <env_free+0x58>
f0103491:	8b 40 48             	mov    0x48(%eax),%eax
f0103494:	eb 05                	jmp    f010349b <env_free+0x5d>
f0103496:	b8 00 00 00 00       	mov    $0x0,%eax
f010349b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010349f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034a3:	c7 04 24 f6 63 10 f0 	movl   $0xf01063f6,(%esp)
f01034aa:	e8 a7 02 00 00       	call   f0103756 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034af:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034b9:	c1 e0 02             	shl    $0x2,%eax
f01034bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01034bf:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034c5:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01034c8:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01034ce:	0f 84 b6 00 00 00    	je     f010358a <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034d4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034da:	89 f0                	mov    %esi,%eax
f01034dc:	c1 e8 0c             	shr    $0xc,%eax
f01034df:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034e2:	3b 05 44 6e 1e f0    	cmp    0xf01e6e44,%eax
f01034e8:	72 20                	jb     f010350a <env_free+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01034ee:	c7 44 24 08 7c 57 10 	movl   $0xf010577c,0x8(%esp)
f01034f5:	f0 
f01034f6:	c7 44 24 04 ad 01 00 	movl   $0x1ad,0x4(%esp)
f01034fd:	00 
f01034fe:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0103505:	e8 93 cb ff ff       	call   f010009d <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010350a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010350d:	c1 e2 16             	shl    $0x16,%edx
f0103510:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103513:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103518:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010351f:	01 
f0103520:	74 17                	je     f0103539 <env_free+0xfb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103522:	89 d8                	mov    %ebx,%eax
f0103524:	c1 e0 0c             	shl    $0xc,%eax
f0103527:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010352a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010352e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103531:	89 04 24             	mov    %eax,(%esp)
f0103534:	e8 85 db ff ff       	call   f01010be <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103539:	43                   	inc    %ebx
f010353a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103540:	75 d6                	jne    f0103518 <env_free+0xda>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103542:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103545:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103548:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010354f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103552:	3b 05 44 6e 1e f0    	cmp    0xf01e6e44,%eax
f0103558:	72 1c                	jb     f0103576 <env_free+0x138>
		panic("pa2page called with invalid pa");
f010355a:	c7 44 24 08 a8 58 10 	movl   $0xf01058a8,0x8(%esp)
f0103561:	f0 
f0103562:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103569:	00 
f010356a:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f0103571:	e8 27 cb ff ff       	call   f010009d <_panic>
	return &pages[PGNUM(pa)];
f0103576:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103579:	c1 e0 03             	shl    $0x3,%eax
f010357c:	03 05 4c 6e 1e f0    	add    0xf01e6e4c,%eax
		page_decref(pa2page(pa));
f0103582:	89 04 24             	mov    %eax,(%esp)
f0103585:	e8 37 d9 ff ff       	call   f0100ec1 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010358a:	ff 45 e0             	incl   -0x20(%ebp)
f010358d:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103594:	0f 85 1c ff ff ff    	jne    f01034b6 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010359a:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010359d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035a2:	77 20                	ja     f01035c4 <env_free+0x186>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035a8:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f01035af:	f0 
f01035b0:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f01035b7:	00 
f01035b8:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f01035bf:	e8 d9 ca ff ff       	call   f010009d <_panic>
	e->env_pgdir = 0;
f01035c4:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01035cb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035d0:	c1 e8 0c             	shr    $0xc,%eax
f01035d3:	3b 05 44 6e 1e f0    	cmp    0xf01e6e44,%eax
f01035d9:	72 1c                	jb     f01035f7 <env_free+0x1b9>
		panic("pa2page called with invalid pa");
f01035db:	c7 44 24 08 a8 58 10 	movl   $0xf01058a8,0x8(%esp)
f01035e2:	f0 
f01035e3:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01035ea:	00 
f01035eb:	c7 04 24 89 5f 10 f0 	movl   $0xf0105f89,(%esp)
f01035f2:	e8 a6 ca ff ff       	call   f010009d <_panic>
	return &pages[PGNUM(pa)];
f01035f7:	c1 e0 03             	shl    $0x3,%eax
f01035fa:	03 05 4c 6e 1e f0    	add    0xf01e6e4c,%eax
	page_decref(pa2page(pa));
f0103600:	89 04 24             	mov    %eax,(%esp)
f0103603:	e8 b9 d8 ff ff       	call   f0100ec1 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103608:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010360f:	a1 b0 61 1e f0       	mov    0xf01e61b0,%eax
f0103614:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103617:	89 3d b0 61 1e f0    	mov    %edi,0xf01e61b0
}
f010361d:	83 c4 2c             	add    $0x2c,%esp
f0103620:	5b                   	pop    %ebx
f0103621:	5e                   	pop    %esi
f0103622:	5f                   	pop    %edi
f0103623:	5d                   	pop    %ebp
f0103624:	c3                   	ret    

f0103625 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103625:	55                   	push   %ebp
f0103626:	89 e5                	mov    %esp,%ebp
f0103628:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f010362b:	8b 45 08             	mov    0x8(%ebp),%eax
f010362e:	89 04 24             	mov    %eax,(%esp)
f0103631:	e8 08 fe ff ff       	call   f010343e <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103636:	c7 04 24 a0 63 10 f0 	movl   $0xf01063a0,(%esp)
f010363d:	e8 14 01 00 00       	call   f0103756 <cprintf>
	while (1)
		monitor(NULL);
f0103642:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103649:	e8 61 d1 ff ff       	call   f01007af <monitor>
f010364e:	eb f2                	jmp    f0103642 <env_destroy+0x1d>

f0103650 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103650:	55                   	push   %ebp
f0103651:	89 e5                	mov    %esp,%ebp
f0103653:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103656:	8b 65 08             	mov    0x8(%ebp),%esp
f0103659:	61                   	popa   
f010365a:	07                   	pop    %es
f010365b:	1f                   	pop    %ds
f010365c:	83 c4 08             	add    $0x8,%esp
f010365f:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103660:	c7 44 24 08 0c 64 10 	movl   $0xf010640c,0x8(%esp)
f0103667:	f0 
f0103668:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
f010366f:	00 
f0103670:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f0103677:	e8 21 ca ff ff       	call   f010009d <_panic>

f010367c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010367c:	55                   	push   %ebp
f010367d:	89 e5                	mov    %esp,%ebp
f010367f:	83 ec 18             	sub    $0x18,%esp
f0103682:	8b 45 08             	mov    0x8(%ebp),%eax

	// LAB 3: Your code here.
	
	//panic("env_run not yet implemented");
	
	if (curenv){
f0103685:	8b 15 a8 61 1e f0    	mov    0xf01e61a8,%edx
f010368b:	85 d2                	test   %edx,%edx
f010368d:	74 0d                	je     f010369c <env_run+0x20>
		if (curenv->env_status == ENV_RUNNING) 
f010368f:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103693:	75 07                	jne    f010369c <env_run+0x20>
			curenv->env_status = ENV_RUNNABLE;
f0103695:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	}
	
	curenv = e;
f010369c:	a3 a8 61 1e f0       	mov    %eax,0xf01e61a8
	e->env_status = ENV_RUNNING;
f01036a1:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f01036a8:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f01036ab:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036ae:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01036b4:	77 20                	ja     f01036d6 <env_run+0x5a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01036ba:	c7 44 24 08 04 59 10 	movl   $0xf0105904,0x8(%esp)
f01036c1:	f0 
f01036c2:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f01036c9:	00 
f01036ca:	c7 04 24 d6 63 10 f0 	movl   $0xf01063d6,(%esp)
f01036d1:	e8 c7 c9 ff ff       	call   f010009d <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036d6:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01036dc:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&(e->env_tf));		
f01036df:	89 04 24             	mov    %eax,(%esp)
f01036e2:	e8 69 ff ff ff       	call   f0103650 <env_pop_tf>
	...

f01036e8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036e8:	55                   	push   %ebp
f01036e9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036eb:	ba 70 00 00 00       	mov    $0x70,%edx
f01036f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036f4:	b2 71                	mov    $0x71,%dl
f01036f6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036f7:	0f b6 c0             	movzbl %al,%eax
}
f01036fa:	5d                   	pop    %ebp
f01036fb:	c3                   	ret    

f01036fc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036fc:	55                   	push   %ebp
f01036fd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036ff:	ba 70 00 00 00       	mov    $0x70,%edx
f0103704:	8b 45 08             	mov    0x8(%ebp),%eax
f0103707:	ee                   	out    %al,(%dx)
f0103708:	b2 71                	mov    $0x71,%dl
f010370a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010370d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010370e:	5d                   	pop    %ebp
f010370f:	c3                   	ret    

f0103710 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103710:	55                   	push   %ebp
f0103711:	89 e5                	mov    %esp,%ebp
f0103713:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103716:	8b 45 08             	mov    0x8(%ebp),%eax
f0103719:	89 04 24             	mov    %eax,(%esp)
f010371c:	e8 91 ce ff ff       	call   f01005b2 <cputchar>
	*cnt++;
}
f0103721:	c9                   	leave  
f0103722:	c3                   	ret    

f0103723 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103723:	55                   	push   %ebp
f0103724:	89 e5                	mov    %esp,%ebp
f0103726:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103729:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103730:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103733:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103737:	8b 45 08             	mov    0x8(%ebp),%eax
f010373a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010373e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103741:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103745:	c7 04 24 10 37 10 f0 	movl   $0xf0103710,(%esp)
f010374c:	e8 31 10 00 00       	call   f0104782 <vprintfmt>
	return cnt;
}
f0103751:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103754:	c9                   	leave  
f0103755:	c3                   	ret    

f0103756 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103756:	55                   	push   %ebp
f0103757:	89 e5                	mov    %esp,%ebp
f0103759:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010375c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010375f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103763:	8b 45 08             	mov    0x8(%ebp),%eax
f0103766:	89 04 24             	mov    %eax,(%esp)
f0103769:	e8 b5 ff ff ff       	call   f0103723 <vcprintf>
	va_end(ap);

	return cnt;
}
f010376e:	c9                   	leave  
f010376f:	c3                   	ret    

f0103770 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103770:	55                   	push   %ebp
f0103771:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103773:	c7 05 c4 69 1e f0 00 	movl   $0xf0000000,0xf01e69c4
f010377a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010377d:	66 c7 05 c8 69 1e f0 	movw   $0x10,0xf01e69c8
f0103784:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103786:	66 c7 05 48 43 12 f0 	movw   $0x67,0xf0124348
f010378d:	67 00 
f010378f:	b8 c0 69 1e f0       	mov    $0xf01e69c0,%eax
f0103794:	66 a3 4a 43 12 f0    	mov    %ax,0xf012434a
f010379a:	89 c2                	mov    %eax,%edx
f010379c:	c1 ea 10             	shr    $0x10,%edx
f010379f:	88 15 4c 43 12 f0    	mov    %dl,0xf012434c
f01037a5:	c6 05 4e 43 12 f0 40 	movb   $0x40,0xf012434e
f01037ac:	c1 e8 18             	shr    $0x18,%eax
f01037af:	a2 4f 43 12 f0       	mov    %al,0xf012434f
				sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01037b4:	c6 05 4d 43 12 f0 89 	movb   $0x89,0xf012434d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037bb:	b8 28 00 00 00       	mov    $0x28,%eax
f01037c0:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037c3:	b8 50 43 12 f0       	mov    $0xf0124350,%eax
f01037c8:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01037cb:	5d                   	pop    %ebp
f01037cc:	c3                   	ret    

f01037cd <trap_init>:
}


void
trap_init(void)
{
f01037cd:	55                   	push   %ebp
f01037ce:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f01037d0:	b8 3c 40 10 f0       	mov    $0xf010403c,%eax
f01037d5:	66 a3 c0 61 1e f0    	mov    %ax,0xf01e61c0
f01037db:	66 c7 05 c2 61 1e f0 	movw   $0x8,0xf01e61c2
f01037e2:	08 00 
f01037e4:	c6 05 c4 61 1e f0 00 	movb   $0x0,0xf01e61c4
f01037eb:	c6 05 c5 61 1e f0 8e 	movb   $0x8e,0xf01e61c5
f01037f2:	c1 e8 10             	shr    $0x10,%eax
f01037f5:	66 a3 c6 61 1e f0    	mov    %ax,0xf01e61c6
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f01037fb:	b8 46 40 10 f0       	mov    $0xf0104046,%eax
f0103800:	66 a3 c8 61 1e f0    	mov    %ax,0xf01e61c8
f0103806:	66 c7 05 ca 61 1e f0 	movw   $0x8,0xf01e61ca
f010380d:	08 00 
f010380f:	c6 05 cc 61 1e f0 00 	movb   $0x0,0xf01e61cc
f0103816:	c6 05 cd 61 1e f0 8e 	movb   $0x8e,0xf01e61cd
f010381d:	c1 e8 10             	shr    $0x10,%eax
f0103820:	66 a3 ce 61 1e f0    	mov    %ax,0xf01e61ce
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103826:	b8 50 40 10 f0       	mov    $0xf0104050,%eax
f010382b:	66 a3 d0 61 1e f0    	mov    %ax,0xf01e61d0
f0103831:	66 c7 05 d2 61 1e f0 	movw   $0x8,0xf01e61d2
f0103838:	08 00 
f010383a:	c6 05 d4 61 1e f0 00 	movb   $0x0,0xf01e61d4
f0103841:	c6 05 d5 61 1e f0 8e 	movb   $0x8e,0xf01e61d5
f0103848:	c1 e8 10             	shr    $0x10,%eax
f010384b:	66 a3 d6 61 1e f0    	mov    %ax,0xf01e61d6
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103851:	b8 5a 40 10 f0       	mov    $0xf010405a,%eax
f0103856:	66 a3 d8 61 1e f0    	mov    %ax,0xf01e61d8
f010385c:	66 c7 05 da 61 1e f0 	movw   $0x8,0xf01e61da
f0103863:	08 00 
f0103865:	c6 05 dc 61 1e f0 00 	movb   $0x0,0xf01e61dc
f010386c:	c6 05 dd 61 1e f0 ee 	movb   $0xee,0xf01e61dd
f0103873:	c1 e8 10             	shr    $0x10,%eax
f0103876:	66 a3 de 61 1e f0    	mov    %ax,0xf01e61de
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f010387c:	b8 64 40 10 f0       	mov    $0xf0104064,%eax
f0103881:	66 a3 e0 61 1e f0    	mov    %ax,0xf01e61e0
f0103887:	66 c7 05 e2 61 1e f0 	movw   $0x8,0xf01e61e2
f010388e:	08 00 
f0103890:	c6 05 e4 61 1e f0 00 	movb   $0x0,0xf01e61e4
f0103897:	c6 05 e5 61 1e f0 8e 	movb   $0x8e,0xf01e61e5
f010389e:	c1 e8 10             	shr    $0x10,%eax
f01038a1:	66 a3 e6 61 1e f0    	mov    %ax,0xf01e61e6
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01038a7:	b8 6e 40 10 f0       	mov    $0xf010406e,%eax
f01038ac:	66 a3 e8 61 1e f0    	mov    %ax,0xf01e61e8
f01038b2:	66 c7 05 ea 61 1e f0 	movw   $0x8,0xf01e61ea
f01038b9:	08 00 
f01038bb:	c6 05 ec 61 1e f0 00 	movb   $0x0,0xf01e61ec
f01038c2:	c6 05 ed 61 1e f0 8e 	movb   $0x8e,0xf01e61ed
f01038c9:	c1 e8 10             	shr    $0x10,%eax
f01038cc:	66 a3 ee 61 1e f0    	mov    %ax,0xf01e61ee
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f01038d2:	b8 78 40 10 f0       	mov    $0xf0104078,%eax
f01038d7:	66 a3 f0 61 1e f0    	mov    %ax,0xf01e61f0
f01038dd:	66 c7 05 f2 61 1e f0 	movw   $0x8,0xf01e61f2
f01038e4:	08 00 
f01038e6:	c6 05 f4 61 1e f0 00 	movb   $0x0,0xf01e61f4
f01038ed:	c6 05 f5 61 1e f0 8e 	movb   $0x8e,0xf01e61f5
f01038f4:	c1 e8 10             	shr    $0x10,%eax
f01038f7:	66 a3 f6 61 1e f0    	mov    %ax,0xf01e61f6
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f01038fd:	b8 82 40 10 f0       	mov    $0xf0104082,%eax
f0103902:	66 a3 f8 61 1e f0    	mov    %ax,0xf01e61f8
f0103908:	66 c7 05 fa 61 1e f0 	movw   $0x8,0xf01e61fa
f010390f:	08 00 
f0103911:	c6 05 fc 61 1e f0 00 	movb   $0x0,0xf01e61fc
f0103918:	c6 05 fd 61 1e f0 8e 	movb   $0x8e,0xf01e61fd
f010391f:	c1 e8 10             	shr    $0x10,%eax
f0103922:	66 a3 fe 61 1e f0    	mov    %ax,0xf01e61fe
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103928:	b8 8c 40 10 f0       	mov    $0xf010408c,%eax
f010392d:	66 a3 00 62 1e f0    	mov    %ax,0xf01e6200
f0103933:	66 c7 05 02 62 1e f0 	movw   $0x8,0xf01e6202
f010393a:	08 00 
f010393c:	c6 05 04 62 1e f0 00 	movb   $0x0,0xf01e6204
f0103943:	c6 05 05 62 1e f0 8e 	movb   $0x8e,0xf01e6205
f010394a:	c1 e8 10             	shr    $0x10,%eax
f010394d:	66 a3 06 62 1e f0    	mov    %ax,0xf01e6206
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103953:	b8 94 40 10 f0       	mov    $0xf0104094,%eax
f0103958:	66 a3 10 62 1e f0    	mov    %ax,0xf01e6210
f010395e:	66 c7 05 12 62 1e f0 	movw   $0x8,0xf01e6212
f0103965:	08 00 
f0103967:	c6 05 14 62 1e f0 00 	movb   $0x0,0xf01e6214
f010396e:	c6 05 15 62 1e f0 8e 	movb   $0x8e,0xf01e6215
f0103975:	c1 e8 10             	shr    $0x10,%eax
f0103978:	66 a3 16 62 1e f0    	mov    %ax,0xf01e6216
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f010397e:	b8 9c 40 10 f0       	mov    $0xf010409c,%eax
f0103983:	66 a3 18 62 1e f0    	mov    %ax,0xf01e6218
f0103989:	66 c7 05 1a 62 1e f0 	movw   $0x8,0xf01e621a
f0103990:	08 00 
f0103992:	c6 05 1c 62 1e f0 00 	movb   $0x0,0xf01e621c
f0103999:	c6 05 1d 62 1e f0 8e 	movb   $0x8e,0xf01e621d
f01039a0:	c1 e8 10             	shr    $0x10,%eax
f01039a3:	66 a3 1e 62 1e f0    	mov    %ax,0xf01e621e
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01039a9:	b8 a4 40 10 f0       	mov    $0xf01040a4,%eax
f01039ae:	66 a3 20 62 1e f0    	mov    %ax,0xf01e6220
f01039b4:	66 c7 05 22 62 1e f0 	movw   $0x8,0xf01e6222
f01039bb:	08 00 
f01039bd:	c6 05 24 62 1e f0 00 	movb   $0x0,0xf01e6224
f01039c4:	c6 05 25 62 1e f0 8e 	movb   $0x8e,0xf01e6225
f01039cb:	c1 e8 10             	shr    $0x10,%eax
f01039ce:	66 a3 26 62 1e f0    	mov    %ax,0xf01e6226
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01039d4:	b8 ac 40 10 f0       	mov    $0xf01040ac,%eax
f01039d9:	66 a3 28 62 1e f0    	mov    %ax,0xf01e6228
f01039df:	66 c7 05 2a 62 1e f0 	movw   $0x8,0xf01e622a
f01039e6:	08 00 
f01039e8:	c6 05 2c 62 1e f0 00 	movb   $0x0,0xf01e622c
f01039ef:	c6 05 2d 62 1e f0 8e 	movb   $0x8e,0xf01e622d
f01039f6:	c1 e8 10             	shr    $0x10,%eax
f01039f9:	66 a3 2e 62 1e f0    	mov    %ax,0xf01e622e
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01039ff:	b8 b4 40 10 f0       	mov    $0xf01040b4,%eax
f0103a04:	66 a3 30 62 1e f0    	mov    %ax,0xf01e6230
f0103a0a:	66 c7 05 32 62 1e f0 	movw   $0x8,0xf01e6232
f0103a11:	08 00 
f0103a13:	c6 05 34 62 1e f0 00 	movb   $0x0,0xf01e6234
f0103a1a:	c6 05 35 62 1e f0 8e 	movb   $0x8e,0xf01e6235
f0103a21:	c1 e8 10             	shr    $0x10,%eax
f0103a24:	66 a3 36 62 1e f0    	mov    %ax,0xf01e6236
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103a2a:	b8 bc 40 10 f0       	mov    $0xf01040bc,%eax
f0103a2f:	66 a3 40 62 1e f0    	mov    %ax,0xf01e6240
f0103a35:	66 c7 05 42 62 1e f0 	movw   $0x8,0xf01e6242
f0103a3c:	08 00 
f0103a3e:	c6 05 44 62 1e f0 00 	movb   $0x0,0xf01e6244
f0103a45:	c6 05 45 62 1e f0 8e 	movb   $0x8e,0xf01e6245
f0103a4c:	c1 e8 10             	shr    $0x10,%eax
f0103a4f:	66 a3 46 62 1e f0    	mov    %ax,0xf01e6246
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103a55:	b8 c6 40 10 f0       	mov    $0xf01040c6,%eax
f0103a5a:	66 a3 48 62 1e f0    	mov    %ax,0xf01e6248
f0103a60:	66 c7 05 4a 62 1e f0 	movw   $0x8,0xf01e624a
f0103a67:	08 00 
f0103a69:	c6 05 4c 62 1e f0 00 	movb   $0x0,0xf01e624c
f0103a70:	c6 05 4d 62 1e f0 8e 	movb   $0x8e,0xf01e624d
f0103a77:	c1 e8 10             	shr    $0x10,%eax
f0103a7a:	66 a3 4e 62 1e f0    	mov    %ax,0xf01e624e
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103a80:	b8 ce 40 10 f0       	mov    $0xf01040ce,%eax
f0103a85:	66 a3 50 62 1e f0    	mov    %ax,0xf01e6250
f0103a8b:	66 c7 05 52 62 1e f0 	movw   $0x8,0xf01e6252
f0103a92:	08 00 
f0103a94:	c6 05 54 62 1e f0 00 	movb   $0x0,0xf01e6254
f0103a9b:	c6 05 55 62 1e f0 8e 	movb   $0x8e,0xf01e6255
f0103aa2:	c1 e8 10             	shr    $0x10,%eax
f0103aa5:	66 a3 56 62 1e f0    	mov    %ax,0xf01e6256
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103aab:	b8 d8 40 10 f0       	mov    $0xf01040d8,%eax
f0103ab0:	66 a3 58 62 1e f0    	mov    %ax,0xf01e6258
f0103ab6:	66 c7 05 5a 62 1e f0 	movw   $0x8,0xf01e625a
f0103abd:	08 00 
f0103abf:	c6 05 5c 62 1e f0 00 	movb   $0x0,0xf01e625c
f0103ac6:	c6 05 5d 62 1e f0 8e 	movb   $0x8e,0xf01e625d
f0103acd:	c1 e8 10             	shr    $0x10,%eax
f0103ad0:	66 a3 5e 62 1e f0    	mov    %ax,0xf01e625e

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103ad6:	b8 e2 40 10 f0       	mov    $0xf01040e2,%eax
f0103adb:	66 a3 40 63 1e f0    	mov    %ax,0xf01e6340
f0103ae1:	66 c7 05 42 63 1e f0 	movw   $0x8,0xf01e6342
f0103ae8:	08 00 
f0103aea:	c6 05 44 63 1e f0 00 	movb   $0x0,0xf01e6344
f0103af1:	c6 05 45 63 1e f0 ee 	movb   $0xee,0xf01e6345
f0103af8:	c1 e8 10             	shr    $0x10,%eax
f0103afb:	66 a3 46 63 1e f0    	mov    %ax,0xf01e6346

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irq_timer, 0);
f0103b01:	b8 f8 40 10 f0       	mov    $0xf01040f8,%eax
f0103b06:	66 a3 c0 62 1e f0    	mov    %ax,0xf01e62c0
f0103b0c:	66 c7 05 c2 62 1e f0 	movw   $0x8,0xf01e62c2
f0103b13:	08 00 
f0103b15:	c6 05 c4 62 1e f0 00 	movb   $0x0,0xf01e62c4
f0103b1c:	c6 05 c5 62 1e f0 8e 	movb   $0x8e,0xf01e62c5
f0103b23:	c1 e8 10             	shr    $0x10,%eax
f0103b26:	66 a3 c6 62 1e f0    	mov    %ax,0xf01e62c6
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irq_kbd, 0);
f0103b2c:	b8 02 41 10 f0       	mov    $0xf0104102,%eax
f0103b31:	66 a3 c8 62 1e f0    	mov    %ax,0xf01e62c8
f0103b37:	66 c7 05 ca 62 1e f0 	movw   $0x8,0xf01e62ca
f0103b3e:	08 00 
f0103b40:	c6 05 cc 62 1e f0 00 	movb   $0x0,0xf01e62cc
f0103b47:	c6 05 cd 62 1e f0 8e 	movb   $0x8e,0xf01e62cd
f0103b4e:	c1 e8 10             	shr    $0x10,%eax
f0103b51:	66 a3 ce 62 1e f0    	mov    %ax,0xf01e62ce
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irq_serial, 0);
f0103b57:	b8 0c 41 10 f0       	mov    $0xf010410c,%eax
f0103b5c:	66 a3 e0 62 1e f0    	mov    %ax,0xf01e62e0
f0103b62:	66 c7 05 e2 62 1e f0 	movw   $0x8,0xf01e62e2
f0103b69:	08 00 
f0103b6b:	c6 05 e4 62 1e f0 00 	movb   $0x0,0xf01e62e4
f0103b72:	c6 05 e5 62 1e f0 8e 	movb   $0x8e,0xf01e62e5
f0103b79:	c1 e8 10             	shr    $0x10,%eax
f0103b7c:	66 a3 e6 62 1e f0    	mov    %ax,0xf01e62e6
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irq_spurious, 0);
f0103b82:	b8 16 41 10 f0       	mov    $0xf0104116,%eax
f0103b87:	66 a3 f8 62 1e f0    	mov    %ax,0xf01e62f8
f0103b8d:	66 c7 05 fa 62 1e f0 	movw   $0x8,0xf01e62fa
f0103b94:	08 00 
f0103b96:	c6 05 fc 62 1e f0 00 	movb   $0x0,0xf01e62fc
f0103b9d:	c6 05 fd 62 1e f0 8e 	movb   $0x8e,0xf01e62fd
f0103ba4:	c1 e8 10             	shr    $0x10,%eax
f0103ba7:	66 a3 fe 62 1e f0    	mov    %ax,0xf01e62fe
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irq_ide, 0);
f0103bad:	b8 20 41 10 f0       	mov    $0xf0104120,%eax
f0103bb2:	66 a3 30 63 1e f0    	mov    %ax,0xf01e6330
f0103bb8:	66 c7 05 32 63 1e f0 	movw   $0x8,0xf01e6332
f0103bbf:	08 00 
f0103bc1:	c6 05 34 63 1e f0 00 	movb   $0x0,0xf01e6334
f0103bc8:	c6 05 35 63 1e f0 8e 	movb   $0x8e,0xf01e6335
f0103bcf:	c1 e8 10             	shr    $0x10,%eax
f0103bd2:	66 a3 36 63 1e f0    	mov    %ax,0xf01e6336
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irq_error, 0);
f0103bd8:	b8 2a 41 10 f0       	mov    $0xf010412a,%eax
f0103bdd:	66 a3 58 63 1e f0    	mov    %ax,0xf01e6358
f0103be3:	66 c7 05 5a 63 1e f0 	movw   $0x8,0xf01e635a
f0103bea:	08 00 
f0103bec:	c6 05 5c 63 1e f0 00 	movb   $0x0,0xf01e635c
f0103bf3:	c6 05 5d 63 1e f0 8e 	movb   $0x8e,0xf01e635d
f0103bfa:	c1 e8 10             	shr    $0x10,%eax
f0103bfd:	66 a3 5e 63 1e f0    	mov    %ax,0xf01e635e

	// Per-CPU setup 
	trap_init_percpu();
f0103c03:	e8 68 fb ff ff       	call   f0103770 <trap_init_percpu>
}
f0103c08:	5d                   	pop    %ebp
f0103c09:	c3                   	ret    

f0103c0a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c0a:	55                   	push   %ebp
f0103c0b:	89 e5                	mov    %esp,%ebp
f0103c0d:	53                   	push   %ebx
f0103c0e:	83 ec 14             	sub    $0x14,%esp
f0103c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c14:	8b 03                	mov    (%ebx),%eax
f0103c16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c1a:	c7 04 24 18 64 10 f0 	movl   $0xf0106418,(%esp)
f0103c21:	e8 30 fb ff ff       	call   f0103756 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c26:	8b 43 04             	mov    0x4(%ebx),%eax
f0103c29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c2d:	c7 04 24 27 64 10 f0 	movl   $0xf0106427,(%esp)
f0103c34:	e8 1d fb ff ff       	call   f0103756 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c39:	8b 43 08             	mov    0x8(%ebx),%eax
f0103c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c40:	c7 04 24 36 64 10 f0 	movl   $0xf0106436,(%esp)
f0103c47:	e8 0a fb ff ff       	call   f0103756 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103c4c:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c53:	c7 04 24 45 64 10 f0 	movl   $0xf0106445,(%esp)
f0103c5a:	e8 f7 fa ff ff       	call   f0103756 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103c5f:	8b 43 10             	mov    0x10(%ebx),%eax
f0103c62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c66:	c7 04 24 54 64 10 f0 	movl   $0xf0106454,(%esp)
f0103c6d:	e8 e4 fa ff ff       	call   f0103756 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103c72:	8b 43 14             	mov    0x14(%ebx),%eax
f0103c75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c79:	c7 04 24 63 64 10 f0 	movl   $0xf0106463,(%esp)
f0103c80:	e8 d1 fa ff ff       	call   f0103756 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103c85:	8b 43 18             	mov    0x18(%ebx),%eax
f0103c88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c8c:	c7 04 24 72 64 10 f0 	movl   $0xf0106472,(%esp)
f0103c93:	e8 be fa ff ff       	call   f0103756 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103c98:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c9f:	c7 04 24 81 64 10 f0 	movl   $0xf0106481,(%esp)
f0103ca6:	e8 ab fa ff ff       	call   f0103756 <cprintf>
}
f0103cab:	83 c4 14             	add    $0x14,%esp
f0103cae:	5b                   	pop    %ebx
f0103caf:	5d                   	pop    %ebp
f0103cb0:	c3                   	ret    

f0103cb1 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103cb1:	55                   	push   %ebp
f0103cb2:	89 e5                	mov    %esp,%ebp
f0103cb4:	53                   	push   %ebx
f0103cb5:	83 ec 14             	sub    $0x14,%esp
f0103cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103cbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cbf:	c7 04 24 d5 65 10 f0 	movl   $0xf01065d5,(%esp)
f0103cc6:	e8 8b fa ff ff       	call   f0103756 <cprintf>
	print_regs(&tf->tf_regs);
f0103ccb:	89 1c 24             	mov    %ebx,(%esp)
f0103cce:	e8 37 ff ff ff       	call   f0103c0a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103cd3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cdb:	c7 04 24 d2 64 10 f0 	movl   $0xf01064d2,(%esp)
f0103ce2:	e8 6f fa ff ff       	call   f0103756 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ce7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cef:	c7 04 24 e5 64 10 f0 	movl   $0xf01064e5,(%esp)
f0103cf6:	e8 5b fa ff ff       	call   f0103756 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103cfb:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103cfe:	83 f8 13             	cmp    $0x13,%eax
f0103d01:	77 09                	ja     f0103d0c <print_trapframe+0x5b>
	  return excnames[trapno];
f0103d03:	8b 14 85 a0 67 10 f0 	mov    -0xfef9860(,%eax,4),%edx
f0103d0a:	eb 11                	jmp    f0103d1d <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
f0103d0c:	83 f8 30             	cmp    $0x30,%eax
f0103d0f:	75 07                	jne    f0103d18 <print_trapframe+0x67>
	  return "System call";
f0103d11:	ba 90 64 10 f0       	mov    $0xf0106490,%edx
f0103d16:	eb 05                	jmp    f0103d1d <print_trapframe+0x6c>
	return "(unknown trap)";
f0103d18:	ba 9c 64 10 f0       	mov    $0xf010649c,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d1d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103d21:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d25:	c7 04 24 f8 64 10 f0 	movl   $0xf01064f8,(%esp)
f0103d2c:	e8 25 fa ff ff       	call   f0103756 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d31:	3b 1d 28 6a 1e f0    	cmp    0xf01e6a28,%ebx
f0103d37:	75 19                	jne    f0103d52 <print_trapframe+0xa1>
f0103d39:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d3d:	75 13                	jne    f0103d52 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103d3f:	0f 20 d0             	mov    %cr2,%eax
	  cprintf("  cr2  0x%08x\n", rcr2());
f0103d42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d46:	c7 04 24 0a 65 10 f0 	movl   $0xf010650a,(%esp)
f0103d4d:	e8 04 fa ff ff       	call   f0103756 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103d52:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103d55:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d59:	c7 04 24 19 65 10 f0 	movl   $0xf0106519,(%esp)
f0103d60:	e8 f1 f9 ff ff       	call   f0103756 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103d65:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d69:	75 4d                	jne    f0103db8 <print_trapframe+0x107>
	  cprintf(" [%s, %s, %s]\n",
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
f0103d6b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
	  cprintf(" [%s, %s, %s]\n",
f0103d6e:	a8 01                	test   $0x1,%al
f0103d70:	74 07                	je     f0103d79 <print_trapframe+0xc8>
f0103d72:	b9 ab 64 10 f0       	mov    $0xf01064ab,%ecx
f0103d77:	eb 05                	jmp    f0103d7e <print_trapframe+0xcd>
f0103d79:	b9 b6 64 10 f0       	mov    $0xf01064b6,%ecx
f0103d7e:	a8 02                	test   $0x2,%al
f0103d80:	74 07                	je     f0103d89 <print_trapframe+0xd8>
f0103d82:	ba c2 64 10 f0       	mov    $0xf01064c2,%edx
f0103d87:	eb 05                	jmp    f0103d8e <print_trapframe+0xdd>
f0103d89:	ba c8 64 10 f0       	mov    $0xf01064c8,%edx
f0103d8e:	a8 04                	test   $0x4,%al
f0103d90:	74 07                	je     f0103d99 <print_trapframe+0xe8>
f0103d92:	b8 cd 64 10 f0       	mov    $0xf01064cd,%eax
f0103d97:	eb 05                	jmp    f0103d9e <print_trapframe+0xed>
f0103d99:	b8 00 66 10 f0       	mov    $0xf0106600,%eax
f0103d9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103da2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103da6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103daa:	c7 04 24 27 65 10 f0 	movl   $0xf0106527,(%esp)
f0103db1:	e8 a0 f9 ff ff       	call   f0103756 <cprintf>
f0103db6:	eb 0c                	jmp    f0103dc4 <print_trapframe+0x113>
				  tf->tf_err & 4 ? "user" : "kernel",
				  tf->tf_err & 2 ? "write" : "read",
				  tf->tf_err & 1 ? "protection" : "not-present");
	else
	  cprintf("\n");
f0103db8:	c7 04 24 72 62 10 f0 	movl   $0xf0106272,(%esp)
f0103dbf:	e8 92 f9 ff ff       	call   f0103756 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103dc4:	8b 43 30             	mov    0x30(%ebx),%eax
f0103dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dcb:	c7 04 24 36 65 10 f0 	movl   $0xf0106536,(%esp)
f0103dd2:	e8 7f f9 ff ff       	call   f0103756 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103dd7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ddb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ddf:	c7 04 24 45 65 10 f0 	movl   $0xf0106545,(%esp)
f0103de6:	e8 6b f9 ff ff       	call   f0103756 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103deb:	8b 43 38             	mov    0x38(%ebx),%eax
f0103dee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103df2:	c7 04 24 58 65 10 f0 	movl   $0xf0106558,(%esp)
f0103df9:	e8 58 f9 ff ff       	call   f0103756 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103dfe:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e02:	74 27                	je     f0103e2b <print_trapframe+0x17a>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e04:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103e07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e0b:	c7 04 24 67 65 10 f0 	movl   $0xf0106567,(%esp)
f0103e12:	e8 3f f9 ff ff       	call   f0103756 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e17:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e1f:	c7 04 24 76 65 10 f0 	movl   $0xf0106576,(%esp)
f0103e26:	e8 2b f9 ff ff       	call   f0103756 <cprintf>
	}
}
f0103e2b:	83 c4 14             	add    $0x14,%esp
f0103e2e:	5b                   	pop    %ebx
f0103e2f:	5d                   	pop    %ebp
f0103e30:	c3                   	ret    

f0103e31 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e31:	55                   	push   %ebp
f0103e32:	89 e5                	mov    %esp,%ebp
f0103e34:	53                   	push   %ebx
f0103e35:	83 ec 14             	sub    $0x14,%esp
f0103e38:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103e3b:	0f 20 d0             	mov    %cr2,%eax

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	
	if ((tf->tf_cs & 0x0001) == 0) {
f0103e3e:	f6 43 34 01          	testb  $0x1,0x34(%ebx)
f0103e42:	75 1c                	jne    f0103e60 <page_fault_handler+0x2f>
		panic("page_fault_handler:page fault");
f0103e44:	c7 44 24 08 89 65 10 	movl   $0xf0106589,0x8(%esp)
f0103e4b:	f0 
f0103e4c:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
f0103e53:	00 
f0103e54:	c7 04 24 a7 65 10 f0 	movl   $0xf01065a7,(%esp)
f0103e5b:	e8 3d c2 ff ff       	call   f010009d <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e60:	8b 53 30             	mov    0x30(%ebx),%edx
f0103e63:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103e67:	89 44 24 08          	mov    %eax,0x8(%esp)
				curenv->env_id, fault_va, tf->tf_eip);
f0103e6b:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e70:	8b 40 48             	mov    0x48(%eax),%eax
f0103e73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e77:	c7 04 24 4c 67 10 f0 	movl   $0xf010674c,(%esp)
f0103e7e:	e8 d3 f8 ff ff       	call   f0103756 <cprintf>
				curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e83:	89 1c 24             	mov    %ebx,(%esp)
f0103e86:	e8 26 fe ff ff       	call   f0103cb1 <print_trapframe>
	env_destroy(curenv);
f0103e8b:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0103e90:	89 04 24             	mov    %eax,(%esp)
f0103e93:	e8 8d f7 ff ff       	call   f0103625 <env_destroy>
}
f0103e98:	83 c4 14             	add    $0x14,%esp
f0103e9b:	5b                   	pop    %ebx
f0103e9c:	5d                   	pop    %ebp
f0103e9d:	c3                   	ret    

f0103e9e <breakpoint_handler>:

void breakpoint_handler(struct Trapframe *tf){
f0103e9e:	55                   	push   %ebp
f0103e9f:	89 e5                	mov    %esp,%ebp
f0103ea1:	83 ec 18             	sub    $0x18,%esp
	monitor(tf);
f0103ea4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ea7:	89 04 24             	mov    %eax,(%esp)
f0103eaa:	e8 00 c9 ff ff       	call   f01007af <monitor>
}
f0103eaf:	c9                   	leave  
f0103eb0:	c3                   	ret    

f0103eb1 <system_call_handler>:

int32_t system_call_handler(struct Trapframe *tf){
f0103eb1:	55                   	push   %ebp
f0103eb2:	89 e5                	mov    %esp,%ebp
f0103eb4:	83 ec 28             	sub    $0x28,%esp
f0103eb7:	8b 45 08             	mov    0x8(%ebp),%eax
	return syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,\
f0103eba:	8b 50 04             	mov    0x4(%eax),%edx
f0103ebd:	89 54 24 14          	mov    %edx,0x14(%esp)
f0103ec1:	8b 10                	mov    (%eax),%edx
f0103ec3:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103ec7:	8b 50 10             	mov    0x10(%eax),%edx
f0103eca:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103ece:	8b 50 18             	mov    0x18(%eax),%edx
f0103ed1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103ed5:	8b 50 14             	mov    0x14(%eax),%edx
f0103ed8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103edc:	8b 40 1c             	mov    0x1c(%eax),%eax
f0103edf:	89 04 24             	mov    %eax,(%esp)
f0103ee2:	e8 61 02 00 00       	call   f0104148 <syscall>
				tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);	
}
f0103ee7:	c9                   	leave  
f0103ee8:	c3                   	ret    

f0103ee9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103ee9:	55                   	push   %ebp
f0103eea:	89 e5                	mov    %esp,%ebp
f0103eec:	57                   	push   %edi
f0103eed:	56                   	push   %esi
f0103eee:	83 ec 10             	sub    $0x10,%esp
f0103ef1:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103ef4:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103ef5:	9c                   	pushf  
f0103ef6:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103ef7:	f6 c4 02             	test   $0x2,%ah
f0103efa:	74 24                	je     f0103f20 <trap+0x37>
f0103efc:	c7 44 24 0c b3 65 10 	movl   $0xf01065b3,0xc(%esp)
f0103f03:	f0 
f0103f04:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0103f0b:	f0 
f0103f0c:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
f0103f13:	00 
f0103f14:	c7 04 24 a7 65 10 f0 	movl   $0xf01065a7,(%esp)
f0103f1b:	e8 7d c1 ff ff       	call   f010009d <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103f20:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f24:	c7 04 24 cc 65 10 f0 	movl   $0xf01065cc,(%esp)
f0103f2b:	e8 26 f8 ff ff       	call   f0103756 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103f30:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f34:	83 e0 03             	and    $0x3,%eax
f0103f37:	83 f8 03             	cmp    $0x3,%eax
f0103f3a:	75 3c                	jne    f0103f78 <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f0103f3c:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0103f41:	85 c0                	test   %eax,%eax
f0103f43:	75 24                	jne    f0103f69 <trap+0x80>
f0103f45:	c7 44 24 0c e7 65 10 	movl   $0xf01065e7,0xc(%esp)
f0103f4c:	f0 
f0103f4d:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f0103f54:	f0 
f0103f55:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
f0103f5c:	00 
f0103f5d:	c7 04 24 a7 65 10 f0 	movl   $0xf01065a7,(%esp)
f0103f64:	e8 34 c1 ff ff       	call   f010009d <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103f69:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103f6e:	89 c7                	mov    %eax,%edi
f0103f70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103f72:	8b 35 a8 61 1e f0    	mov    0xf01e61a8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103f78:	89 35 28 6a 1e f0    	mov    %esi,0xf01e6a28
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	int32_t ret;

	switch (tf->tf_trapno){
f0103f7e:	8b 46 28             	mov    0x28(%esi),%eax
f0103f81:	83 f8 03             	cmp    $0x3,%eax
f0103f84:	74 22                	je     f0103fa8 <trap+0xbf>
f0103f86:	83 f8 03             	cmp    $0x3,%eax
f0103f89:	77 07                	ja     f0103f92 <trap+0xa9>
f0103f8b:	83 f8 01             	cmp    $0x1,%eax
f0103f8e:	75 39                	jne    f0103fc9 <trap+0xe0>
f0103f90:	eb 20                	jmp    f0103fb2 <trap+0xc9>
f0103f92:	83 f8 0e             	cmp    $0xe,%eax
f0103f95:	74 07                	je     f0103f9e <trap+0xb5>
f0103f97:	83 f8 30             	cmp    $0x30,%eax
f0103f9a:	75 2d                	jne    f0103fc9 <trap+0xe0>
f0103f9c:	eb 1e                	jmp    f0103fbc <trap+0xd3>
		case T_PGFLT:{ //14
			page_fault_handler(tf);
f0103f9e:	89 34 24             	mov    %esi,(%esp)
f0103fa1:	e8 8b fe ff ff       	call   f0103e31 <page_fault_handler>
f0103fa6:	eb 59                	jmp    f0104001 <trap+0x118>
			return;
		}
		case T_BRKPT:{ //3 
			breakpoint_handler(tf);
f0103fa8:	89 34 24             	mov    %esi,(%esp)
f0103fab:	e8 ee fe ff ff       	call   f0103e9e <breakpoint_handler>
f0103fb0:	eb 4f                	jmp    f0104001 <trap+0x118>
			return;
		}
		case T_DEBUG:{
			breakpoint_handler(tf);
f0103fb2:	89 34 24             	mov    %esi,(%esp)
f0103fb5:	e8 e4 fe ff ff       	call   f0103e9e <breakpoint_handler>
f0103fba:	eb 45                	jmp    f0104001 <trap+0x118>
			return;
		}
		case T_SYSCALL:{
			ret = system_call_handler(tf);
f0103fbc:	89 34 24             	mov    %esi,(%esp)
f0103fbf:	e8 ed fe ff ff       	call   f0103eb1 <system_call_handler>
			tf->tf_regs.reg_eax = ret;
f0103fc4:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103fc7:	eb 38                	jmp    f0104001 <trap+0x118>
		}

	}	

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103fc9:	89 34 24             	mov    %esi,(%esp)
f0103fcc:	e8 e0 fc ff ff       	call   f0103cb1 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103fd1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103fd6:	75 1c                	jne    f0103ff4 <trap+0x10b>
	  panic("unhandled trap in kernel");
f0103fd8:	c7 44 24 08 ee 65 10 	movl   $0xf01065ee,0x8(%esp)
f0103fdf:	f0 
f0103fe0:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f0103fe7:	00 
f0103fe8:	c7 04 24 a7 65 10 f0 	movl   $0xf01065a7,(%esp)
f0103fef:	e8 a9 c0 ff ff       	call   f010009d <_panic>
	else {
		env_destroy(curenv);
f0103ff4:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0103ff9:	89 04 24             	mov    %eax,(%esp)
f0103ffc:	e8 24 f6 ff ff       	call   f0103625 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104001:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0104006:	85 c0                	test   %eax,%eax
f0104008:	74 06                	je     f0104010 <trap+0x127>
f010400a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010400e:	74 24                	je     f0104034 <trap+0x14b>
f0104010:	c7 44 24 0c 70 67 10 	movl   $0xf0106770,0xc(%esp)
f0104017:	f0 
f0104018:	c7 44 24 08 a3 5f 10 	movl   $0xf0105fa3,0x8(%esp)
f010401f:	f0 
f0104020:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f0104027:	00 
f0104028:	c7 04 24 a7 65 10 f0 	movl   $0xf01065a7,(%esp)
f010402f:	e8 69 c0 ff ff       	call   f010009d <_panic>
	env_run(curenv);
f0104034:	89 04 24             	mov    %eax,(%esp)
f0104037:	e8 40 f6 ff ff       	call   f010367c <env_run>

f010403c <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f010403c:	6a 00                	push   $0x0
f010403e:	6a 00                	push   $0x0
f0104040:	e9 ee 00 00 00       	jmp    f0104133 <_alltraps>
f0104045:	90                   	nop

f0104046 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104046:	6a 00                	push   $0x0
f0104048:	6a 01                	push   $0x1
f010404a:	e9 e4 00 00 00       	jmp    f0104133 <_alltraps>
f010404f:	90                   	nop

f0104050 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104050:	6a 00                	push   $0x0
f0104052:	6a 02                	push   $0x2
f0104054:	e9 da 00 00 00       	jmp    f0104133 <_alltraps>
f0104059:	90                   	nop

f010405a <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f010405a:	6a 00                	push   $0x0
f010405c:	6a 03                	push   $0x3
f010405e:	e9 d0 00 00 00       	jmp    f0104133 <_alltraps>
f0104063:	90                   	nop

f0104064 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104064:	6a 00                	push   $0x0
f0104066:	6a 04                	push   $0x4
f0104068:	e9 c6 00 00 00       	jmp    f0104133 <_alltraps>
f010406d:	90                   	nop

f010406e <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f010406e:	6a 00                	push   $0x0
f0104070:	6a 05                	push   $0x5
f0104072:	e9 bc 00 00 00       	jmp    f0104133 <_alltraps>
f0104077:	90                   	nop

f0104078 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104078:	6a 00                	push   $0x0
f010407a:	6a 06                	push   $0x6
f010407c:	e9 b2 00 00 00       	jmp    f0104133 <_alltraps>
f0104081:	90                   	nop

f0104082 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104082:	6a 00                	push   $0x0
f0104084:	6a 07                	push   $0x7
f0104086:	e9 a8 00 00 00       	jmp    f0104133 <_alltraps>
f010408b:	90                   	nop

f010408c <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f010408c:	6a 08                	push   $0x8
f010408e:	e9 a0 00 00 00       	jmp    f0104133 <_alltraps>
f0104093:	90                   	nop

f0104094 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104094:	6a 0a                	push   $0xa
f0104096:	e9 98 00 00 00       	jmp    f0104133 <_alltraps>
f010409b:	90                   	nop

f010409c <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f010409c:	6a 0b                	push   $0xb
f010409e:	e9 90 00 00 00       	jmp    f0104133 <_alltraps>
f01040a3:	90                   	nop

f01040a4 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01040a4:	6a 0c                	push   $0xc
f01040a6:	e9 88 00 00 00       	jmp    f0104133 <_alltraps>
f01040ab:	90                   	nop

f01040ac <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01040ac:	6a 0d                	push   $0xd
f01040ae:	e9 80 00 00 00       	jmp    f0104133 <_alltraps>
f01040b3:	90                   	nop

f01040b4 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01040b4:	6a 0e                	push   $0xe
f01040b6:	e9 78 00 00 00       	jmp    f0104133 <_alltraps>
f01040bb:	90                   	nop

f01040bc <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01040bc:	6a 00                	push   $0x0
f01040be:	6a 10                	push   $0x10
f01040c0:	e9 6e 00 00 00       	jmp    f0104133 <_alltraps>
f01040c5:	90                   	nop

f01040c6 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f01040c6:	6a 11                	push   $0x11
f01040c8:	e9 66 00 00 00       	jmp    f0104133 <_alltraps>
f01040cd:	90                   	nop

f01040ce <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01040ce:	6a 00                	push   $0x0
f01040d0:	6a 12                	push   $0x12
f01040d2:	e9 5c 00 00 00       	jmp    f0104133 <_alltraps>
f01040d7:	90                   	nop

f01040d8 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01040d8:	6a 00                	push   $0x0
f01040da:	6a 13                	push   $0x13
f01040dc:	e9 52 00 00 00       	jmp    f0104133 <_alltraps>
f01040e1:	90                   	nop

f01040e2 <t_syscall>:
TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01040e2:	6a 00                	push   $0x0
f01040e4:	6a 30                	push   $0x30
f01040e6:	e9 48 00 00 00       	jmp    f0104133 <_alltraps>
f01040eb:	90                   	nop

f01040ec <t_default>:
TRAPHANDLER_NOEC(t_default, T_DEFAULT)
f01040ec:	6a 00                	push   $0x0
f01040ee:	68 f4 01 00 00       	push   $0x1f4
f01040f3:	e9 3b 00 00 00       	jmp    f0104133 <_alltraps>

f01040f8 <irq_timer>:
TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET+IRQ_TIMER)
f01040f8:	6a 00                	push   $0x0
f01040fa:	6a 20                	push   $0x20
f01040fc:	e9 32 00 00 00       	jmp    f0104133 <_alltraps>
f0104101:	90                   	nop

f0104102 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET+IRQ_KBD)
f0104102:	6a 00                	push   $0x0
f0104104:	6a 21                	push   $0x21
f0104106:	e9 28 00 00 00       	jmp    f0104133 <_alltraps>
f010410b:	90                   	nop

f010410c <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET+IRQ_SERIAL)
f010410c:	6a 00                	push   $0x0
f010410e:	6a 24                	push   $0x24
f0104110:	e9 1e 00 00 00       	jmp    f0104133 <_alltraps>
f0104115:	90                   	nop

f0104116 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
f0104116:	6a 00                	push   $0x0
f0104118:	6a 27                	push   $0x27
f010411a:	e9 14 00 00 00       	jmp    f0104133 <_alltraps>
f010411f:	90                   	nop

f0104120 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET+IRQ_IDE)
f0104120:	6a 00                	push   $0x0
f0104122:	6a 2e                	push   $0x2e
f0104124:	e9 0a 00 00 00       	jmp    f0104133 <_alltraps>
f0104129:	90                   	nop

f010412a <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET+IRQ_ERROR)
f010412a:	6a 00                	push   $0x0
f010412c:	6a 33                	push   $0x33
f010412e:	e9 00 00 00 00       	jmp    f0104133 <_alltraps>

f0104133 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	pushl %ds
f0104133:	1e                   	push   %ds
	pushl %es
f0104134:	06                   	push   %es
	pushal
f0104135:	60                   	pusha  

	movl $GD_KD,%eax
f0104136:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010413b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010413d:	8e c0                	mov    %eax,%es
	push %esp
f010413f:	54                   	push   %esp
	call trap
f0104140:	e8 a4 fd ff ff       	call   f0103ee9 <trap>
f0104145:	00 00                	add    %al,(%eax)
	...

f0104148 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104148:	55                   	push   %ebp
f0104149:	89 e5                	mov    %esp,%ebp
f010414b:	56                   	push   %esi
f010414c:	53                   	push   %ebx
f010414d:	83 ec 20             	sub    $0x20,%esp
f0104150:	8b 45 08             	mov    0x8(%ebp),%eax
f0104153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104156:	8b 75 10             	mov    0x10(%ebp),%esi
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104159:	83 f8 01             	cmp    $0x1,%eax
f010415c:	74 50                	je     f01041ae <syscall+0x66>
f010415e:	83 f8 01             	cmp    $0x1,%eax
f0104161:	72 10                	jb     f0104173 <syscall+0x2b>
f0104163:	83 f8 02             	cmp    $0x2,%eax
f0104166:	74 50                	je     f01041b8 <syscall+0x70>
f0104168:	83 f8 03             	cmp    $0x3,%eax
f010416b:	0f 85 c2 00 00 00    	jne    f0104233 <syscall+0xeb>
f0104171:	eb 4f                	jmp    f01041c2 <syscall+0x7a>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	
	user_mem_assert(curenv, (void*)s, len, 0); 
f0104173:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010417a:	00 
f010417b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010417f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104183:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0104188:	89 04 24             	mov    %eax,(%esp)
f010418b:	e8 7e ed ff ff       	call   f0102f0e <user_mem_assert>
	
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104194:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104198:	c7 04 24 f0 67 10 f0 	movl   $0xf01067f0,(%esp)
f010419f:	e8 b2 f5 ff ff       	call   f0103756 <cprintf>
	//panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:{
			sys_cputs((const char*)a1, a2);
			return 0;
f01041a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01041a9:	e9 8a 00 00 00       	jmp    f0104238 <syscall+0xf0>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01041ae:	e8 dd c2 ff ff       	call   f0100490 <cons_getc>
		case SYS_cputs:{
			sys_cputs((const char*)a1, a2);
			return 0;
		}
		case SYS_cgetc:
			return sys_cgetc();	
f01041b3:	e9 80 00 00 00       	jmp    f0104238 <syscall+0xf0>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01041b8:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f01041bd:	8b 40 48             	mov    0x48(%eax),%eax
			return 0;
		}
		case SYS_cgetc:
			return sys_cgetc();	
		case SYS_getenvid:
			return sys_getenvid(); 
f01041c0:	eb 76                	jmp    f0104238 <syscall+0xf0>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01041c2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01041c9:	00 
f01041ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01041cd:	89 44 24 04          	mov    %eax,0x4(%esp)
		case SYS_cgetc:
			return sys_cgetc();	
		case SYS_getenvid:
			return sys_getenvid(); 
		case SYS_env_destroy:
			return sys_env_destroy(curenv->env_id); 
f01041d1:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01041d6:	8b 40 48             	mov    0x48(%eax),%eax
f01041d9:	89 04 24             	mov    %eax,(%esp)
f01041dc:	e8 49 ee ff ff       	call   f010302a <envid2env>
f01041e1:	85 c0                	test   %eax,%eax
f01041e3:	78 53                	js     f0104238 <syscall+0xf0>
	  return r;
	if (e == curenv)
f01041e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041e8:	8b 15 a8 61 1e f0    	mov    0xf01e61a8,%edx
f01041ee:	39 d0                	cmp    %edx,%eax
f01041f0:	75 15                	jne    f0104207 <syscall+0xbf>
	  cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01041f2:	8b 40 48             	mov    0x48(%eax),%eax
f01041f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041f9:	c7 04 24 f5 67 10 f0 	movl   $0xf01067f5,(%esp)
f0104200:	e8 51 f5 ff ff       	call   f0103756 <cprintf>
f0104205:	eb 1a                	jmp    f0104221 <syscall+0xd9>
	else
	  cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104207:	8b 40 48             	mov    0x48(%eax),%eax
f010420a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010420e:	8b 42 48             	mov    0x48(%edx),%eax
f0104211:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104215:	c7 04 24 10 68 10 f0 	movl   $0xf0106810,(%esp)
f010421c:	e8 35 f5 ff ff       	call   f0103756 <cprintf>
	env_destroy(e);
f0104221:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104224:	89 04 24             	mov    %eax,(%esp)
f0104227:	e8 f9 f3 ff ff       	call   f0103625 <env_destroy>
	return 0;
f010422c:	b8 00 00 00 00       	mov    $0x0,%eax
		case SYS_cgetc:
			return sys_cgetc();	
		case SYS_getenvid:
			return sys_getenvid(); 
		case SYS_env_destroy:
			return sys_env_destroy(curenv->env_id); 
f0104231:	eb 05                	jmp    f0104238 <syscall+0xf0>
		default:
			return -E_INVAL;
f0104233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}	
}
f0104238:	83 c4 20             	add    $0x20,%esp
f010423b:	5b                   	pop    %ebx
f010423c:	5e                   	pop    %esi
f010423d:	5d                   	pop    %ebp
f010423e:	c3                   	ret    
	...

f0104240 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104240:	55                   	push   %ebp
f0104241:	89 e5                	mov    %esp,%ebp
f0104243:	57                   	push   %edi
f0104244:	56                   	push   %esi
f0104245:	53                   	push   %ebx
f0104246:	83 ec 14             	sub    $0x14,%esp
f0104249:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010424c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010424f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104252:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104255:	8b 1a                	mov    (%edx),%ebx
f0104257:	8b 01                	mov    (%ecx),%eax
f0104259:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010425c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0104263:	e9 83 00 00 00       	jmp    f01042eb <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0104268:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010426b:	01 d8                	add    %ebx,%eax
f010426d:	89 c7                	mov    %eax,%edi
f010426f:	c1 ef 1f             	shr    $0x1f,%edi
f0104272:	01 c7                	add    %eax,%edi
f0104274:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104276:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104279:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010427c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0104280:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104282:	eb 01                	jmp    f0104285 <stab_binsearch+0x45>
			m--;
f0104284:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104285:	39 c3                	cmp    %eax,%ebx
f0104287:	7f 1e                	jg     f01042a7 <stab_binsearch+0x67>
f0104289:	0f b6 0a             	movzbl (%edx),%ecx
f010428c:	83 ea 0c             	sub    $0xc,%edx
f010428f:	39 f1                	cmp    %esi,%ecx
f0104291:	75 f1                	jne    f0104284 <stab_binsearch+0x44>
f0104293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104296:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104299:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010429c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01042a0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01042a3:	76 18                	jbe    f01042bd <stab_binsearch+0x7d>
f01042a5:	eb 05                	jmp    f01042ac <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01042a7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01042aa:	eb 3f                	jmp    f01042eb <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01042ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01042af:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01042b1:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01042b4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01042bb:	eb 2e                	jmp    f01042eb <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01042bd:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01042c0:	73 15                	jae    f01042d7 <stab_binsearch+0x97>
			*region_right = m - 1;
f01042c2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01042c5:	49                   	dec    %ecx
f01042c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01042c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042cc:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01042ce:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01042d5:	eb 14                	jmp    f01042eb <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01042d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01042da:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01042dd:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f01042df:	ff 45 0c             	incl   0xc(%ebp)
f01042e2:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01042e4:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01042eb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01042ee:	0f 8e 74 ff ff ff    	jle    f0104268 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01042f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01042f8:	75 0d                	jne    f0104307 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01042fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01042fd:	8b 02                	mov    (%edx),%eax
f01042ff:	48                   	dec    %eax
f0104300:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104303:	89 01                	mov    %eax,(%ecx)
f0104305:	eb 2a                	jmp    f0104331 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104307:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010430a:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f010430c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010430f:	8b 0a                	mov    (%edx),%ecx
f0104311:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104314:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0104317:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010431b:	eb 01                	jmp    f010431e <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010431d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010431e:	39 c8                	cmp    %ecx,%eax
f0104320:	7e 0a                	jle    f010432c <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0104322:	0f b6 1a             	movzbl (%edx),%ebx
f0104325:	83 ea 0c             	sub    $0xc,%edx
f0104328:	39 f3                	cmp    %esi,%ebx
f010432a:	75 f1                	jne    f010431d <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f010432c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010432f:	89 02                	mov    %eax,(%edx)
	}
}
f0104331:	83 c4 14             	add    $0x14,%esp
f0104334:	5b                   	pop    %ebx
f0104335:	5e                   	pop    %esi
f0104336:	5f                   	pop    %edi
f0104337:	5d                   	pop    %ebp
f0104338:	c3                   	ret    

f0104339 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104339:	55                   	push   %ebp
f010433a:	89 e5                	mov    %esp,%ebp
f010433c:	57                   	push   %edi
f010433d:	56                   	push   %esi
f010433e:	53                   	push   %ebx
f010433f:	83 ec 5c             	sub    $0x5c,%esp
f0104342:	8b 75 08             	mov    0x8(%ebp),%esi
f0104345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104348:	c7 03 28 68 10 f0    	movl   $0xf0106828,(%ebx)
	info->eip_line = 0;
f010434e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104355:	c7 43 08 28 68 10 f0 	movl   $0xf0106828,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010435c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104363:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104366:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010436d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104373:	0f 87 a6 00 00 00    	ja     f010441f <debuginfo_eip+0xe6>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0104379:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104380:	00 
f0104381:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0104388:	00 
f0104389:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0104390:	00 
f0104391:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f0104396:	89 04 24             	mov    %eax,(%esp)
f0104399:	e8 cb ea ff ff       	call   f0102e69 <user_mem_check>
f010439e:	85 c0                	test   %eax,%eax
f01043a0:	0f 88 2d 02 00 00    	js     f01045d3 <debuginfo_eip+0x29a>
			return -1;

		stabs = usd->stabs;
f01043a6:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f01043ac:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f01043af:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01043b5:	a1 08 00 20 00       	mov    0x200008,%eax
f01043ba:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f01043bd:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f01043c3:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
f01043c6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01043cd:	00 
f01043ce:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01043d5:	00 
f01043d6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01043d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01043dd:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f01043e2:	89 04 24             	mov    %eax,(%esp)
f01043e5:	e8 7f ea ff ff       	call   f0102e69 <user_mem_check>
f01043ea:	85 c0                	test   %eax,%eax
f01043ec:	0f 88 e8 01 00 00    	js     f01045da <debuginfo_eip+0x2a1>
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
f01043f2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01043f9:	00 
f01043fa:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0104401:	00 
f0104402:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104405:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104409:	a1 a8 61 1e f0       	mov    0xf01e61a8,%eax
f010440e:	89 04 24             	mov    %eax,(%esp)
f0104411:	e8 53 ea ff ff       	call   f0102e69 <user_mem_check>
f0104416:	85 c0                	test   %eax,%eax
f0104418:	79 1f                	jns    f0104439 <debuginfo_eip+0x100>
f010441a:	e9 c2 01 00 00       	jmp    f01045e1 <debuginfo_eip+0x2a8>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010441f:	c7 45 c0 09 96 11 f0 	movl   $0xf0119609,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104426:	c7 45 bc fd f6 10 f0 	movl   $0xf010f6fd,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010442d:	bf fc f6 10 f0       	mov    $0xf010f6fc,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104432:	c7 45 c4 50 6a 10 f0 	movl   $0xf0106a50,-0x3c(%ebp)
			return -1;
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104439:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010443c:	39 55 bc             	cmp    %edx,-0x44(%ebp)
f010443f:	0f 83 a3 01 00 00    	jae    f01045e8 <debuginfo_eip+0x2af>
f0104445:	80 7a ff 00          	cmpb   $0x0,-0x1(%edx)
f0104449:	0f 85 a0 01 00 00    	jne    f01045ef <debuginfo_eip+0x2b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010444f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104456:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0104459:	c1 ff 02             	sar    $0x2,%edi
f010445c:	8d 04 bf             	lea    (%edi,%edi,4),%eax
f010445f:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104462:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104465:	89 c2                	mov    %eax,%edx
f0104467:	c1 e2 08             	shl    $0x8,%edx
f010446a:	01 d0                	add    %edx,%eax
f010446c:	89 c2                	mov    %eax,%edx
f010446e:	c1 e2 10             	shl    $0x10,%edx
f0104471:	01 d0                	add    %edx,%eax
f0104473:	8d 44 47 ff          	lea    -0x1(%edi,%eax,2),%eax
f0104477:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010447a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010447e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104485:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104488:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010448b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010448e:	e8 ad fd ff ff       	call   f0104240 <stab_binsearch>
	if (lfile == 0)
f0104493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104496:	85 c0                	test   %eax,%eax
f0104498:	0f 84 58 01 00 00    	je     f01045f6 <debuginfo_eip+0x2bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010449e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01044a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01044a7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01044ab:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01044b2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01044b5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01044b8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01044bb:	e8 80 fd ff ff       	call   f0104240 <stab_binsearch>

	if (lfun <= rfun) {
f01044c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01044c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01044c6:	39 d0                	cmp    %edx,%eax
f01044c8:	7f 32                	jg     f01044fc <debuginfo_eip+0x1c3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01044ca:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01044cd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01044d0:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01044d3:	8b 39                	mov    (%ecx),%edi
f01044d5:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01044d8:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01044db:	2b 7d bc             	sub    -0x44(%ebp),%edi
f01044de:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f01044e1:	73 09                	jae    f01044ec <debuginfo_eip+0x1b3>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01044e3:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01044e6:	03 7d bc             	add    -0x44(%ebp),%edi
f01044e9:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01044ec:	8b 49 08             	mov    0x8(%ecx),%ecx
f01044ef:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01044f2:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01044f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01044f7:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01044fa:	eb 0f                	jmp    f010450b <debuginfo_eip+0x1d2>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01044fc:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01044ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104502:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104505:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104508:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010450b:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104512:	00 
f0104513:	8b 43 08             	mov    0x8(%ebx),%eax
f0104516:	89 04 24             	mov    %eax,(%esp)
f0104519:	e8 8c 08 00 00       	call   f0104daa <strfind>
f010451e:	2b 43 08             	sub    0x8(%ebx),%eax
f0104521:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
f0104524:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104528:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010452f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104532:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104535:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104538:	e8 03 fd ff ff       	call   f0104240 <stab_binsearch>
	if (lline > rline )
f010453d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104540:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0104543:	0f 8f b4 00 00 00    	jg     f01045fd <debuginfo_eip+0x2c4>
		return -1;	
	info->eip_line = stabs[rline].n_desc;
f0104549:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010454c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010454f:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104554:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104557:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010455a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010455d:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104560:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0104564:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104567:	eb 04                	jmp    f010456d <debuginfo_eip+0x234>
f0104569:	48                   	dec    %eax
f010456a:	83 ea 0c             	sub    $0xc,%edx
f010456d:	89 c7                	mov    %eax,%edi
f010456f:	39 c6                	cmp    %eax,%esi
f0104571:	7f 28                	jg     f010459b <debuginfo_eip+0x262>
	       && stabs[lline].n_type != N_SOL
f0104573:	8a 4a fc             	mov    -0x4(%edx),%cl
f0104576:	80 f9 84             	cmp    $0x84,%cl
f0104579:	0f 84 99 00 00 00    	je     f0104618 <debuginfo_eip+0x2df>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010457f:	80 f9 64             	cmp    $0x64,%cl
f0104582:	75 e5                	jne    f0104569 <debuginfo_eip+0x230>
f0104584:	83 3a 00             	cmpl   $0x0,(%edx)
f0104587:	74 e0                	je     f0104569 <debuginfo_eip+0x230>
f0104589:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010458c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010458f:	e9 8a 00 00 00       	jmp    f010461e <debuginfo_eip+0x2e5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104594:	03 45 bc             	add    -0x44(%ebp),%eax
f0104597:	89 03                	mov    %eax,(%ebx)
f0104599:	eb 03                	jmp    f010459e <debuginfo_eip+0x265>
f010459b:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010459e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01045a1:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01045a4:	39 f2                	cmp    %esi,%edx
f01045a6:	7d 5c                	jge    f0104604 <debuginfo_eip+0x2cb>
		for (lline = lfun + 1;
f01045a8:	42                   	inc    %edx
f01045a9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01045ac:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01045ae:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01045b1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01045b4:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01045b8:	eb 03                	jmp    f01045bd <debuginfo_eip+0x284>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01045ba:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01045bd:	39 f0                	cmp    %esi,%eax
f01045bf:	7d 4a                	jge    f010460b <debuginfo_eip+0x2d2>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01045c1:	8a 0a                	mov    (%edx),%cl
f01045c3:	40                   	inc    %eax
f01045c4:	83 c2 0c             	add    $0xc,%edx
f01045c7:	80 f9 a0             	cmp    $0xa0,%cl
f01045ca:	74 ee                	je     f01045ba <debuginfo_eip+0x281>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01045cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01045d1:	eb 3d                	jmp    f0104610 <debuginfo_eip+0x2d7>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		if( user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f01045d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045d8:	eb 36                	jmp    f0104610 <debuginfo_eip+0x2d7>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if ( user_mem_check(curenv, (void*)stabs, sizeof(stabs), PTE_U)< 0)
			return -1;
f01045da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045df:	eb 2f                	jmp    f0104610 <debuginfo_eip+0x2d7>
		if ( user_mem_check(curenv, (void*)stabstr, sizeof(stabstr), PTE_U)< 0)
			return -1;
f01045e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045e6:	eb 28                	jmp    f0104610 <debuginfo_eip+0x2d7>
	}
	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01045e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045ed:	eb 21                	jmp    f0104610 <debuginfo_eip+0x2d7>
f01045ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045f4:	eb 1a                	jmp    f0104610 <debuginfo_eip+0x2d7>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01045f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045fb:	eb 13                	jmp    f0104610 <debuginfo_eip+0x2d7>
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
	if (lline > rline )
		return -1;	
f01045fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104602:	eb 0c                	jmp    f0104610 <debuginfo_eip+0x2d7>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104604:	b8 00 00 00 00       	mov    $0x0,%eax
f0104609:	eb 05                	jmp    f0104610 <debuginfo_eip+0x2d7>
f010460b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104610:	83 c4 5c             	add    $0x5c,%esp
f0104613:	5b                   	pop    %ebx
f0104614:	5e                   	pop    %esi
f0104615:	5f                   	pop    %edi
f0104616:	5d                   	pop    %ebp
f0104617:	c3                   	ret    
f0104618:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010461b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010461e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104621:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104624:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0104627:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010462a:	2b 55 bc             	sub    -0x44(%ebp),%edx
f010462d:	39 d0                	cmp    %edx,%eax
f010462f:	0f 82 5f ff ff ff    	jb     f0104594 <debuginfo_eip+0x25b>
f0104635:	e9 64 ff ff ff       	jmp    f010459e <debuginfo_eip+0x265>
	...

f010463c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010463c:	55                   	push   %ebp
f010463d:	89 e5                	mov    %esp,%ebp
f010463f:	57                   	push   %edi
f0104640:	56                   	push   %esi
f0104641:	53                   	push   %ebx
f0104642:	83 ec 3c             	sub    $0x3c,%esp
f0104645:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104648:	89 d7                	mov    %edx,%edi
f010464a:	8b 45 08             	mov    0x8(%ebp),%eax
f010464d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104650:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104653:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104656:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104659:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010465c:	85 c0                	test   %eax,%eax
f010465e:	75 08                	jne    f0104668 <printnum+0x2c>
f0104660:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104663:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104666:	77 57                	ja     f01046bf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104668:	89 74 24 10          	mov    %esi,0x10(%esp)
f010466c:	4b                   	dec    %ebx
f010466d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104671:	8b 45 10             	mov    0x10(%ebp),%eax
f0104674:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104678:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f010467c:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0104680:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104687:	00 
f0104688:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010468b:	89 04 24             	mov    %eax,(%esp)
f010468e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104691:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104695:	e8 1e 09 00 00       	call   f0104fb8 <__udivdi3>
f010469a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010469e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01046a2:	89 04 24             	mov    %eax,(%esp)
f01046a5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01046a9:	89 fa                	mov    %edi,%edx
f01046ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046ae:	e8 89 ff ff ff       	call   f010463c <printnum>
f01046b3:	eb 0f                	jmp    f01046c4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01046b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046b9:	89 34 24             	mov    %esi,(%esp)
f01046bc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01046bf:	4b                   	dec    %ebx
f01046c0:	85 db                	test   %ebx,%ebx
f01046c2:	7f f1                	jg     f01046b5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01046c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01046cc:	8b 45 10             	mov    0x10(%ebp),%eax
f01046cf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01046da:	00 
f01046db:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046de:	89 04 24             	mov    %eax,(%esp)
f01046e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e8:	e8 eb 09 00 00       	call   f01050d8 <__umoddi3>
f01046ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046f1:	0f be 80 32 68 10 f0 	movsbl -0xfef97ce(%eax),%eax
f01046f8:	89 04 24             	mov    %eax,(%esp)
f01046fb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01046fe:	83 c4 3c             	add    $0x3c,%esp
f0104701:	5b                   	pop    %ebx
f0104702:	5e                   	pop    %esi
f0104703:	5f                   	pop    %edi
f0104704:	5d                   	pop    %ebp
f0104705:	c3                   	ret    

f0104706 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104706:	55                   	push   %ebp
f0104707:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104709:	83 fa 01             	cmp    $0x1,%edx
f010470c:	7e 0e                	jle    f010471c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010470e:	8b 10                	mov    (%eax),%edx
f0104710:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104713:	89 08                	mov    %ecx,(%eax)
f0104715:	8b 02                	mov    (%edx),%eax
f0104717:	8b 52 04             	mov    0x4(%edx),%edx
f010471a:	eb 22                	jmp    f010473e <getuint+0x38>
	else if (lflag)
f010471c:	85 d2                	test   %edx,%edx
f010471e:	74 10                	je     f0104730 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104720:	8b 10                	mov    (%eax),%edx
f0104722:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104725:	89 08                	mov    %ecx,(%eax)
f0104727:	8b 02                	mov    (%edx),%eax
f0104729:	ba 00 00 00 00       	mov    $0x0,%edx
f010472e:	eb 0e                	jmp    f010473e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104730:	8b 10                	mov    (%eax),%edx
f0104732:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104735:	89 08                	mov    %ecx,(%eax)
f0104737:	8b 02                	mov    (%edx),%eax
f0104739:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010473e:	5d                   	pop    %ebp
f010473f:	c3                   	ret    

f0104740 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104740:	55                   	push   %ebp
f0104741:	89 e5                	mov    %esp,%ebp
f0104743:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104746:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0104749:	8b 10                	mov    (%eax),%edx
f010474b:	3b 50 04             	cmp    0x4(%eax),%edx
f010474e:	73 08                	jae    f0104758 <sprintputch+0x18>
		*b->buf++ = ch;
f0104750:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104753:	88 0a                	mov    %cl,(%edx)
f0104755:	42                   	inc    %edx
f0104756:	89 10                	mov    %edx,(%eax)
}
f0104758:	5d                   	pop    %ebp
f0104759:	c3                   	ret    

f010475a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010475a:	55                   	push   %ebp
f010475b:	89 e5                	mov    %esp,%ebp
f010475d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0104760:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104763:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104767:	8b 45 10             	mov    0x10(%ebp),%eax
f010476a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010476e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104771:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104775:	8b 45 08             	mov    0x8(%ebp),%eax
f0104778:	89 04 24             	mov    %eax,(%esp)
f010477b:	e8 02 00 00 00       	call   f0104782 <vprintfmt>
	va_end(ap);
}
f0104780:	c9                   	leave  
f0104781:	c3                   	ret    

f0104782 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104782:	55                   	push   %ebp
f0104783:	89 e5                	mov    %esp,%ebp
f0104785:	57                   	push   %edi
f0104786:	56                   	push   %esi
f0104787:	53                   	push   %ebx
f0104788:	83 ec 4c             	sub    $0x4c,%esp
f010478b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010478e:	8b 75 10             	mov    0x10(%ebp),%esi
f0104791:	eb 12                	jmp    f01047a5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104793:	85 c0                	test   %eax,%eax
f0104795:	0f 84 6b 03 00 00    	je     f0104b06 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f010479b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010479f:	89 04 24             	mov    %eax,(%esp)
f01047a2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01047a5:	0f b6 06             	movzbl (%esi),%eax
f01047a8:	46                   	inc    %esi
f01047a9:	83 f8 25             	cmp    $0x25,%eax
f01047ac:	75 e5                	jne    f0104793 <vprintfmt+0x11>
f01047ae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01047b2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01047b9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01047be:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01047c5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01047ca:	eb 26                	jmp    f01047f2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047cc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01047cf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01047d3:	eb 1d                	jmp    f01047f2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01047d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01047dc:	eb 14                	jmp    f01047f2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01047e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01047e8:	eb 08                	jmp    f01047f2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01047ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01047ed:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047f2:	0f b6 06             	movzbl (%esi),%eax
f01047f5:	8d 56 01             	lea    0x1(%esi),%edx
f01047f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01047fb:	8a 16                	mov    (%esi),%dl
f01047fd:	83 ea 23             	sub    $0x23,%edx
f0104800:	80 fa 55             	cmp    $0x55,%dl
f0104803:	0f 87 e1 02 00 00    	ja     f0104aea <vprintfmt+0x368>
f0104809:	0f b6 d2             	movzbl %dl,%edx
f010480c:	ff 24 95 c0 68 10 f0 	jmp    *-0xfef9740(,%edx,4)
f0104813:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104816:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010481b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010481e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0104822:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104825:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104828:	83 fa 09             	cmp    $0x9,%edx
f010482b:	77 2a                	ja     f0104857 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010482d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010482e:	eb eb                	jmp    f010481b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104830:	8b 45 14             	mov    0x14(%ebp),%eax
f0104833:	8d 50 04             	lea    0x4(%eax),%edx
f0104836:	89 55 14             	mov    %edx,0x14(%ebp)
f0104839:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010483b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010483e:	eb 17                	jmp    f0104857 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0104840:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104844:	78 98                	js     f01047de <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104846:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104849:	eb a7                	jmp    f01047f2 <vprintfmt+0x70>
f010484b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010484e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0104855:	eb 9b                	jmp    f01047f2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0104857:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010485b:	79 95                	jns    f01047f2 <vprintfmt+0x70>
f010485d:	eb 8b                	jmp    f01047ea <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010485f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104860:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104863:	eb 8d                	jmp    f01047f2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104865:	8b 45 14             	mov    0x14(%ebp),%eax
f0104868:	8d 50 04             	lea    0x4(%eax),%edx
f010486b:	89 55 14             	mov    %edx,0x14(%ebp)
f010486e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104872:	8b 00                	mov    (%eax),%eax
f0104874:	89 04 24             	mov    %eax,(%esp)
f0104877:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010487a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010487d:	e9 23 ff ff ff       	jmp    f01047a5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104882:	8b 45 14             	mov    0x14(%ebp),%eax
f0104885:	8d 50 04             	lea    0x4(%eax),%edx
f0104888:	89 55 14             	mov    %edx,0x14(%ebp)
f010488b:	8b 00                	mov    (%eax),%eax
f010488d:	85 c0                	test   %eax,%eax
f010488f:	79 02                	jns    f0104893 <vprintfmt+0x111>
f0104891:	f7 d8                	neg    %eax
f0104893:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104895:	83 f8 07             	cmp    $0x7,%eax
f0104898:	7f 0b                	jg     f01048a5 <vprintfmt+0x123>
f010489a:	8b 04 85 20 6a 10 f0 	mov    -0xfef95e0(,%eax,4),%eax
f01048a1:	85 c0                	test   %eax,%eax
f01048a3:	75 23                	jne    f01048c8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01048a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01048a9:	c7 44 24 08 4a 68 10 	movl   $0xf010684a,0x8(%esp)
f01048b0:	f0 
f01048b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01048b8:	89 04 24             	mov    %eax,(%esp)
f01048bb:	e8 9a fe ff ff       	call   f010475a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01048c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01048c3:	e9 dd fe ff ff       	jmp    f01047a5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01048c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048cc:	c7 44 24 08 b5 5f 10 	movl   $0xf0105fb5,0x8(%esp)
f01048d3:	f0 
f01048d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01048d8:	8b 55 08             	mov    0x8(%ebp),%edx
f01048db:	89 14 24             	mov    %edx,(%esp)
f01048de:	e8 77 fe ff ff       	call   f010475a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01048e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048e6:	e9 ba fe ff ff       	jmp    f01047a5 <vprintfmt+0x23>
f01048eb:	89 f9                	mov    %edi,%ecx
f01048ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01048f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01048f6:	8d 50 04             	lea    0x4(%eax),%edx
f01048f9:	89 55 14             	mov    %edx,0x14(%ebp)
f01048fc:	8b 30                	mov    (%eax),%esi
f01048fe:	85 f6                	test   %esi,%esi
f0104900:	75 05                	jne    f0104907 <vprintfmt+0x185>
				p = "(null)";
f0104902:	be 43 68 10 f0       	mov    $0xf0106843,%esi
			if (width > 0 && padc != '-')
f0104907:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010490b:	0f 8e 84 00 00 00    	jle    f0104995 <vprintfmt+0x213>
f0104911:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0104915:	74 7e                	je     f0104995 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104917:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010491b:	89 34 24             	mov    %esi,(%esp)
f010491e:	e8 53 03 00 00       	call   f0104c76 <strnlen>
f0104923:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104926:	29 c2                	sub    %eax,%edx
f0104928:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f010492b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010492f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104932:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0104935:	89 de                	mov    %ebx,%esi
f0104937:	89 d3                	mov    %edx,%ebx
f0104939:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010493b:	eb 0b                	jmp    f0104948 <vprintfmt+0x1c6>
					putch(padc, putdat);
f010493d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104941:	89 3c 24             	mov    %edi,(%esp)
f0104944:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104947:	4b                   	dec    %ebx
f0104948:	85 db                	test   %ebx,%ebx
f010494a:	7f f1                	jg     f010493d <vprintfmt+0x1bb>
f010494c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010494f:	89 f3                	mov    %esi,%ebx
f0104951:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0104954:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104957:	85 c0                	test   %eax,%eax
f0104959:	79 05                	jns    f0104960 <vprintfmt+0x1de>
f010495b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104960:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104963:	29 c2                	sub    %eax,%edx
f0104965:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104968:	eb 2b                	jmp    f0104995 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010496a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010496e:	74 18                	je     f0104988 <vprintfmt+0x206>
f0104970:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104973:	83 fa 5e             	cmp    $0x5e,%edx
f0104976:	76 10                	jbe    f0104988 <vprintfmt+0x206>
					putch('?', putdat);
f0104978:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010497c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104983:	ff 55 08             	call   *0x8(%ebp)
f0104986:	eb 0a                	jmp    f0104992 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0104988:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010498c:	89 04 24             	mov    %eax,(%esp)
f010498f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104992:	ff 4d e4             	decl   -0x1c(%ebp)
f0104995:	0f be 06             	movsbl (%esi),%eax
f0104998:	46                   	inc    %esi
f0104999:	85 c0                	test   %eax,%eax
f010499b:	74 21                	je     f01049be <vprintfmt+0x23c>
f010499d:	85 ff                	test   %edi,%edi
f010499f:	78 c9                	js     f010496a <vprintfmt+0x1e8>
f01049a1:	4f                   	dec    %edi
f01049a2:	79 c6                	jns    f010496a <vprintfmt+0x1e8>
f01049a4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01049a7:	89 de                	mov    %ebx,%esi
f01049a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01049ac:	eb 18                	jmp    f01049c6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01049ae:	89 74 24 04          	mov    %esi,0x4(%esp)
f01049b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01049b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01049bb:	4b                   	dec    %ebx
f01049bc:	eb 08                	jmp    f01049c6 <vprintfmt+0x244>
f01049be:	8b 7d 08             	mov    0x8(%ebp),%edi
f01049c1:	89 de                	mov    %ebx,%esi
f01049c3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01049c6:	85 db                	test   %ebx,%ebx
f01049c8:	7f e4                	jg     f01049ae <vprintfmt+0x22c>
f01049ca:	89 7d 08             	mov    %edi,0x8(%ebp)
f01049cd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01049cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01049d2:	e9 ce fd ff ff       	jmp    f01047a5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01049d7:	83 f9 01             	cmp    $0x1,%ecx
f01049da:	7e 10                	jle    f01049ec <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01049dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01049df:	8d 50 08             	lea    0x8(%eax),%edx
f01049e2:	89 55 14             	mov    %edx,0x14(%ebp)
f01049e5:	8b 30                	mov    (%eax),%esi
f01049e7:	8b 78 04             	mov    0x4(%eax),%edi
f01049ea:	eb 26                	jmp    f0104a12 <vprintfmt+0x290>
	else if (lflag)
f01049ec:	85 c9                	test   %ecx,%ecx
f01049ee:	74 12                	je     f0104a02 <vprintfmt+0x280>
		return va_arg(*ap, long);
f01049f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01049f3:	8d 50 04             	lea    0x4(%eax),%edx
f01049f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01049f9:	8b 30                	mov    (%eax),%esi
f01049fb:	89 f7                	mov    %esi,%edi
f01049fd:	c1 ff 1f             	sar    $0x1f,%edi
f0104a00:	eb 10                	jmp    f0104a12 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0104a02:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a05:	8d 50 04             	lea    0x4(%eax),%edx
f0104a08:	89 55 14             	mov    %edx,0x14(%ebp)
f0104a0b:	8b 30                	mov    (%eax),%esi
f0104a0d:	89 f7                	mov    %esi,%edi
f0104a0f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104a12:	85 ff                	test   %edi,%edi
f0104a14:	78 0a                	js     f0104a20 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104a16:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a1b:	e9 8c 00 00 00       	jmp    f0104aac <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0104a20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a24:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104a2b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104a2e:	f7 de                	neg    %esi
f0104a30:	83 d7 00             	adc    $0x0,%edi
f0104a33:	f7 df                	neg    %edi
			}
			base = 10;
f0104a35:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a3a:	eb 70                	jmp    f0104aac <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104a3c:	89 ca                	mov    %ecx,%edx
f0104a3e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104a41:	e8 c0 fc ff ff       	call   f0104706 <getuint>
f0104a46:	89 c6                	mov    %eax,%esi
f0104a48:	89 d7                	mov    %edx,%edi
			base = 10;
f0104a4a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104a4f:	eb 5b                	jmp    f0104aac <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
f0104a51:	89 ca                	mov    %ecx,%edx
f0104a53:	8d 45 14             	lea    0x14(%ebp),%eax
f0104a56:	e8 ab fc ff ff       	call   f0104706 <getuint>
f0104a5b:	89 c6                	mov    %eax,%esi
f0104a5d:	89 d7                	mov    %edx,%edi
			base = 8;
f0104a5f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0104a64:	eb 46                	jmp    f0104aac <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
f0104a66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a6a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104a71:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104a74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a78:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104a7f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104a82:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a85:	8d 50 04             	lea    0x4(%eax),%edx
f0104a88:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104a8b:	8b 30                	mov    (%eax),%esi
f0104a8d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104a92:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104a97:	eb 13                	jmp    f0104aac <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104a99:	89 ca                	mov    %ecx,%edx
f0104a9b:	8d 45 14             	lea    0x14(%ebp),%eax
f0104a9e:	e8 63 fc ff ff       	call   f0104706 <getuint>
f0104aa3:	89 c6                	mov    %eax,%esi
f0104aa5:	89 d7                	mov    %edx,%edi
			base = 16;
f0104aa7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104aac:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0104ab0:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104ab4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ab7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104abb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104abf:	89 34 24             	mov    %esi,(%esp)
f0104ac2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104ac6:	89 da                	mov    %ebx,%edx
f0104ac8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104acb:	e8 6c fb ff ff       	call   f010463c <printnum>
			break;
f0104ad0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104ad3:	e9 cd fc ff ff       	jmp    f01047a5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104ad8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104adc:	89 04 24             	mov    %eax,(%esp)
f0104adf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ae2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104ae5:	e9 bb fc ff ff       	jmp    f01047a5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104aea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104aee:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104af5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104af8:	eb 01                	jmp    f0104afb <vprintfmt+0x379>
f0104afa:	4e                   	dec    %esi
f0104afb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0104aff:	75 f9                	jne    f0104afa <vprintfmt+0x378>
f0104b01:	e9 9f fc ff ff       	jmp    f01047a5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0104b06:	83 c4 4c             	add    $0x4c,%esp
f0104b09:	5b                   	pop    %ebx
f0104b0a:	5e                   	pop    %esi
f0104b0b:	5f                   	pop    %edi
f0104b0c:	5d                   	pop    %ebp
f0104b0d:	c3                   	ret    

f0104b0e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104b0e:	55                   	push   %ebp
f0104b0f:	89 e5                	mov    %esp,%ebp
f0104b11:	83 ec 28             	sub    $0x28,%esp
f0104b14:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104b1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b1d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104b21:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104b24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104b2b:	85 c0                	test   %eax,%eax
f0104b2d:	74 30                	je     f0104b5f <vsnprintf+0x51>
f0104b2f:	85 d2                	test   %edx,%edx
f0104b31:	7e 33                	jle    f0104b66 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104b33:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b36:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b3a:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b3d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b41:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104b44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b48:	c7 04 24 40 47 10 f0 	movl   $0xf0104740,(%esp)
f0104b4f:	e8 2e fc ff ff       	call   f0104782 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104b5d:	eb 0c                	jmp    f0104b6b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b64:	eb 05                	jmp    f0104b6b <vsnprintf+0x5d>
f0104b66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104b6b:	c9                   	leave  
f0104b6c:	c3                   	ret    

f0104b6d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104b6d:	55                   	push   %ebp
f0104b6e:	89 e5                	mov    %esp,%ebp
f0104b70:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104b73:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104b76:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b7a:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b7d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b88:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b8b:	89 04 24             	mov    %eax,(%esp)
f0104b8e:	e8 7b ff ff ff       	call   f0104b0e <vsnprintf>
	va_end(ap);

	return rc;
}
f0104b93:	c9                   	leave  
f0104b94:	c3                   	ret    
f0104b95:	00 00                	add    %al,(%eax)
	...

f0104b98 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104b98:	55                   	push   %ebp
f0104b99:	89 e5                	mov    %esp,%ebp
f0104b9b:	57                   	push   %edi
f0104b9c:	56                   	push   %esi
f0104b9d:	53                   	push   %ebx
f0104b9e:	83 ec 1c             	sub    $0x1c,%esp
f0104ba1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104ba4:	85 c0                	test   %eax,%eax
f0104ba6:	74 10                	je     f0104bb8 <readline+0x20>
		cprintf("%s", prompt);
f0104ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bac:	c7 04 24 b5 5f 10 f0 	movl   $0xf0105fb5,(%esp)
f0104bb3:	e8 9e eb ff ff       	call   f0103756 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104bb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104bbf:	e8 0f ba ff ff       	call   f01005d3 <iscons>
f0104bc4:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104bc6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104bcb:	e8 f2 b9 ff ff       	call   f01005c2 <getchar>
f0104bd0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104bd2:	85 c0                	test   %eax,%eax
f0104bd4:	79 17                	jns    f0104bed <readline+0x55>
			cprintf("read error: %e\n", c);
f0104bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bda:	c7 04 24 40 6a 10 f0 	movl   $0xf0106a40,(%esp)
f0104be1:	e8 70 eb ff ff       	call   f0103756 <cprintf>
			return NULL;
f0104be6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104beb:	eb 69                	jmp    f0104c56 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104bed:	83 f8 08             	cmp    $0x8,%eax
f0104bf0:	74 05                	je     f0104bf7 <readline+0x5f>
f0104bf2:	83 f8 7f             	cmp    $0x7f,%eax
f0104bf5:	75 17                	jne    f0104c0e <readline+0x76>
f0104bf7:	85 f6                	test   %esi,%esi
f0104bf9:	7e 13                	jle    f0104c0e <readline+0x76>
			if (echoing)
f0104bfb:	85 ff                	test   %edi,%edi
f0104bfd:	74 0c                	je     f0104c0b <readline+0x73>
				cputchar('\b');
f0104bff:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104c06:	e8 a7 b9 ff ff       	call   f01005b2 <cputchar>
			i--;
f0104c0b:	4e                   	dec    %esi
f0104c0c:	eb bd                	jmp    f0104bcb <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104c0e:	83 fb 1f             	cmp    $0x1f,%ebx
f0104c11:	7e 1d                	jle    f0104c30 <readline+0x98>
f0104c13:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104c19:	7f 15                	jg     f0104c30 <readline+0x98>
			if (echoing)
f0104c1b:	85 ff                	test   %edi,%edi
f0104c1d:	74 08                	je     f0104c27 <readline+0x8f>
				cputchar(c);
f0104c1f:	89 1c 24             	mov    %ebx,(%esp)
f0104c22:	e8 8b b9 ff ff       	call   f01005b2 <cputchar>
			buf[i++] = c;
f0104c27:	88 9e 40 6a 1e f0    	mov    %bl,-0xfe195c0(%esi)
f0104c2d:	46                   	inc    %esi
f0104c2e:	eb 9b                	jmp    f0104bcb <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104c30:	83 fb 0a             	cmp    $0xa,%ebx
f0104c33:	74 05                	je     f0104c3a <readline+0xa2>
f0104c35:	83 fb 0d             	cmp    $0xd,%ebx
f0104c38:	75 91                	jne    f0104bcb <readline+0x33>
			if (echoing)
f0104c3a:	85 ff                	test   %edi,%edi
f0104c3c:	74 0c                	je     f0104c4a <readline+0xb2>
				cputchar('\n');
f0104c3e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104c45:	e8 68 b9 ff ff       	call   f01005b2 <cputchar>
			buf[i] = 0;
f0104c4a:	c6 86 40 6a 1e f0 00 	movb   $0x0,-0xfe195c0(%esi)
			return buf;
f0104c51:	b8 40 6a 1e f0       	mov    $0xf01e6a40,%eax
		}
	}
}
f0104c56:	83 c4 1c             	add    $0x1c,%esp
f0104c59:	5b                   	pop    %ebx
f0104c5a:	5e                   	pop    %esi
f0104c5b:	5f                   	pop    %edi
f0104c5c:	5d                   	pop    %ebp
f0104c5d:	c3                   	ret    
	...

f0104c60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104c60:	55                   	push   %ebp
f0104c61:	89 e5                	mov    %esp,%ebp
f0104c63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104c66:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c6b:	eb 01                	jmp    f0104c6e <strlen+0xe>
		n++;
f0104c6d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104c6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104c72:	75 f9                	jne    f0104c6d <strlen+0xd>
		n++;
	return n;
}
f0104c74:	5d                   	pop    %ebp
f0104c75:	c3                   	ret    

f0104c76 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104c76:	55                   	push   %ebp
f0104c77:	89 e5                	mov    %esp,%ebp
f0104c79:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0104c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104c7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c84:	eb 01                	jmp    f0104c87 <strnlen+0x11>
		n++;
f0104c86:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104c87:	39 d0                	cmp    %edx,%eax
f0104c89:	74 06                	je     f0104c91 <strnlen+0x1b>
f0104c8b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104c8f:	75 f5                	jne    f0104c86 <strnlen+0x10>
		n++;
	return n;
}
f0104c91:	5d                   	pop    %ebp
f0104c92:	c3                   	ret    

f0104c93 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104c93:	55                   	push   %ebp
f0104c94:	89 e5                	mov    %esp,%ebp
f0104c96:	53                   	push   %ebx
f0104c97:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104c9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ca2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0104ca5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0104ca8:	42                   	inc    %edx
f0104ca9:	84 c9                	test   %cl,%cl
f0104cab:	75 f5                	jne    f0104ca2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104cad:	5b                   	pop    %ebx
f0104cae:	5d                   	pop    %ebp
f0104caf:	c3                   	ret    

f0104cb0 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104cb0:	55                   	push   %ebp
f0104cb1:	89 e5                	mov    %esp,%ebp
f0104cb3:	53                   	push   %ebx
f0104cb4:	83 ec 08             	sub    $0x8,%esp
f0104cb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104cba:	89 1c 24             	mov    %ebx,(%esp)
f0104cbd:	e8 9e ff ff ff       	call   f0104c60 <strlen>
	strcpy(dst + len, src);
f0104cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104cc5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104cc9:	01 d8                	add    %ebx,%eax
f0104ccb:	89 04 24             	mov    %eax,(%esp)
f0104cce:	e8 c0 ff ff ff       	call   f0104c93 <strcpy>
	return dst;
}
f0104cd3:	89 d8                	mov    %ebx,%eax
f0104cd5:	83 c4 08             	add    $0x8,%esp
f0104cd8:	5b                   	pop    %ebx
f0104cd9:	5d                   	pop    %ebp
f0104cda:	c3                   	ret    

f0104cdb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104cdb:	55                   	push   %ebp
f0104cdc:	89 e5                	mov    %esp,%ebp
f0104cde:	56                   	push   %esi
f0104cdf:	53                   	push   %ebx
f0104ce0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ce3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ce6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cee:	eb 0c                	jmp    f0104cfc <strncpy+0x21>
		*dst++ = *src;
f0104cf0:	8a 1a                	mov    (%edx),%bl
f0104cf2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104cf5:	80 3a 01             	cmpb   $0x1,(%edx)
f0104cf8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104cfb:	41                   	inc    %ecx
f0104cfc:	39 f1                	cmp    %esi,%ecx
f0104cfe:	75 f0                	jne    f0104cf0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104d00:	5b                   	pop    %ebx
f0104d01:	5e                   	pop    %esi
f0104d02:	5d                   	pop    %ebp
f0104d03:	c3                   	ret    

f0104d04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104d04:	55                   	push   %ebp
f0104d05:	89 e5                	mov    %esp,%ebp
f0104d07:	56                   	push   %esi
f0104d08:	53                   	push   %ebx
f0104d09:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d0f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104d12:	85 d2                	test   %edx,%edx
f0104d14:	75 0a                	jne    f0104d20 <strlcpy+0x1c>
f0104d16:	89 f0                	mov    %esi,%eax
f0104d18:	eb 1a                	jmp    f0104d34 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104d1a:	88 18                	mov    %bl,(%eax)
f0104d1c:	40                   	inc    %eax
f0104d1d:	41                   	inc    %ecx
f0104d1e:	eb 02                	jmp    f0104d22 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104d20:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0104d22:	4a                   	dec    %edx
f0104d23:	74 0a                	je     f0104d2f <strlcpy+0x2b>
f0104d25:	8a 19                	mov    (%ecx),%bl
f0104d27:	84 db                	test   %bl,%bl
f0104d29:	75 ef                	jne    f0104d1a <strlcpy+0x16>
f0104d2b:	89 c2                	mov    %eax,%edx
f0104d2d:	eb 02                	jmp    f0104d31 <strlcpy+0x2d>
f0104d2f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104d31:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104d34:	29 f0                	sub    %esi,%eax
}
f0104d36:	5b                   	pop    %ebx
f0104d37:	5e                   	pop    %esi
f0104d38:	5d                   	pop    %ebp
f0104d39:	c3                   	ret    

f0104d3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104d3a:	55                   	push   %ebp
f0104d3b:	89 e5                	mov    %esp,%ebp
f0104d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104d43:	eb 02                	jmp    f0104d47 <strcmp+0xd>
		p++, q++;
f0104d45:	41                   	inc    %ecx
f0104d46:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104d47:	8a 01                	mov    (%ecx),%al
f0104d49:	84 c0                	test   %al,%al
f0104d4b:	74 04                	je     f0104d51 <strcmp+0x17>
f0104d4d:	3a 02                	cmp    (%edx),%al
f0104d4f:	74 f4                	je     f0104d45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104d51:	0f b6 c0             	movzbl %al,%eax
f0104d54:	0f b6 12             	movzbl (%edx),%edx
f0104d57:	29 d0                	sub    %edx,%eax
}
f0104d59:	5d                   	pop    %ebp
f0104d5a:	c3                   	ret    

f0104d5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104d5b:	55                   	push   %ebp
f0104d5c:	89 e5                	mov    %esp,%ebp
f0104d5e:	53                   	push   %ebx
f0104d5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0104d68:	eb 03                	jmp    f0104d6d <strncmp+0x12>
		n--, p++, q++;
f0104d6a:	4a                   	dec    %edx
f0104d6b:	40                   	inc    %eax
f0104d6c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104d6d:	85 d2                	test   %edx,%edx
f0104d6f:	74 14                	je     f0104d85 <strncmp+0x2a>
f0104d71:	8a 18                	mov    (%eax),%bl
f0104d73:	84 db                	test   %bl,%bl
f0104d75:	74 04                	je     f0104d7b <strncmp+0x20>
f0104d77:	3a 19                	cmp    (%ecx),%bl
f0104d79:	74 ef                	je     f0104d6a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104d7b:	0f b6 00             	movzbl (%eax),%eax
f0104d7e:	0f b6 11             	movzbl (%ecx),%edx
f0104d81:	29 d0                	sub    %edx,%eax
f0104d83:	eb 05                	jmp    f0104d8a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104d85:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104d8a:	5b                   	pop    %ebx
f0104d8b:	5d                   	pop    %ebp
f0104d8c:	c3                   	ret    

f0104d8d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104d8d:	55                   	push   %ebp
f0104d8e:	89 e5                	mov    %esp,%ebp
f0104d90:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d93:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104d96:	eb 05                	jmp    f0104d9d <strchr+0x10>
		if (*s == c)
f0104d98:	38 ca                	cmp    %cl,%dl
f0104d9a:	74 0c                	je     f0104da8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104d9c:	40                   	inc    %eax
f0104d9d:	8a 10                	mov    (%eax),%dl
f0104d9f:	84 d2                	test   %dl,%dl
f0104da1:	75 f5                	jne    f0104d98 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0104da3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104da8:	5d                   	pop    %ebp
f0104da9:	c3                   	ret    

f0104daa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104daa:	55                   	push   %ebp
f0104dab:	89 e5                	mov    %esp,%ebp
f0104dad:	8b 45 08             	mov    0x8(%ebp),%eax
f0104db0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104db3:	eb 05                	jmp    f0104dba <strfind+0x10>
		if (*s == c)
f0104db5:	38 ca                	cmp    %cl,%dl
f0104db7:	74 07                	je     f0104dc0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104db9:	40                   	inc    %eax
f0104dba:	8a 10                	mov    (%eax),%dl
f0104dbc:	84 d2                	test   %dl,%dl
f0104dbe:	75 f5                	jne    f0104db5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0104dc0:	5d                   	pop    %ebp
f0104dc1:	c3                   	ret    

f0104dc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104dc2:	55                   	push   %ebp
f0104dc3:	89 e5                	mov    %esp,%ebp
f0104dc5:	57                   	push   %edi
f0104dc6:	56                   	push   %esi
f0104dc7:	53                   	push   %ebx
f0104dc8:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104dd1:	85 c9                	test   %ecx,%ecx
f0104dd3:	74 30                	je     f0104e05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104dd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104ddb:	75 25                	jne    f0104e02 <memset+0x40>
f0104ddd:	f6 c1 03             	test   $0x3,%cl
f0104de0:	75 20                	jne    f0104e02 <memset+0x40>
		c &= 0xFF;
f0104de2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104de5:	89 d3                	mov    %edx,%ebx
f0104de7:	c1 e3 08             	shl    $0x8,%ebx
f0104dea:	89 d6                	mov    %edx,%esi
f0104dec:	c1 e6 18             	shl    $0x18,%esi
f0104def:	89 d0                	mov    %edx,%eax
f0104df1:	c1 e0 10             	shl    $0x10,%eax
f0104df4:	09 f0                	or     %esi,%eax
f0104df6:	09 d0                	or     %edx,%eax
f0104df8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104dfa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104dfd:	fc                   	cld    
f0104dfe:	f3 ab                	rep stos %eax,%es:(%edi)
f0104e00:	eb 03                	jmp    f0104e05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104e02:	fc                   	cld    
f0104e03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104e05:	89 f8                	mov    %edi,%eax
f0104e07:	5b                   	pop    %ebx
f0104e08:	5e                   	pop    %esi
f0104e09:	5f                   	pop    %edi
f0104e0a:	5d                   	pop    %ebp
f0104e0b:	c3                   	ret    

f0104e0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104e0c:	55                   	push   %ebp
f0104e0d:	89 e5                	mov    %esp,%ebp
f0104e0f:	57                   	push   %edi
f0104e10:	56                   	push   %esi
f0104e11:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e14:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104e1a:	39 c6                	cmp    %eax,%esi
f0104e1c:	73 34                	jae    f0104e52 <memmove+0x46>
f0104e1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104e21:	39 d0                	cmp    %edx,%eax
f0104e23:	73 2d                	jae    f0104e52 <memmove+0x46>
		s += n;
		d += n;
f0104e25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104e28:	f6 c2 03             	test   $0x3,%dl
f0104e2b:	75 1b                	jne    f0104e48 <memmove+0x3c>
f0104e2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104e33:	75 13                	jne    f0104e48 <memmove+0x3c>
f0104e35:	f6 c1 03             	test   $0x3,%cl
f0104e38:	75 0e                	jne    f0104e48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104e3a:	83 ef 04             	sub    $0x4,%edi
f0104e3d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104e40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104e43:	fd                   	std    
f0104e44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104e46:	eb 07                	jmp    f0104e4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104e48:	4f                   	dec    %edi
f0104e49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104e4c:	fd                   	std    
f0104e4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104e4f:	fc                   	cld    
f0104e50:	eb 20                	jmp    f0104e72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104e52:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104e58:	75 13                	jne    f0104e6d <memmove+0x61>
f0104e5a:	a8 03                	test   $0x3,%al
f0104e5c:	75 0f                	jne    f0104e6d <memmove+0x61>
f0104e5e:	f6 c1 03             	test   $0x3,%cl
f0104e61:	75 0a                	jne    f0104e6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104e63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104e66:	89 c7                	mov    %eax,%edi
f0104e68:	fc                   	cld    
f0104e69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104e6b:	eb 05                	jmp    f0104e72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104e6d:	89 c7                	mov    %eax,%edi
f0104e6f:	fc                   	cld    
f0104e70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104e72:	5e                   	pop    %esi
f0104e73:	5f                   	pop    %edi
f0104e74:	5d                   	pop    %ebp
f0104e75:	c3                   	ret    

f0104e76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104e76:	55                   	push   %ebp
f0104e77:	89 e5                	mov    %esp,%ebp
f0104e79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104e7c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e83:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e8d:	89 04 24             	mov    %eax,(%esp)
f0104e90:	e8 77 ff ff ff       	call   f0104e0c <memmove>
}
f0104e95:	c9                   	leave  
f0104e96:	c3                   	ret    

f0104e97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104e97:	55                   	push   %ebp
f0104e98:	89 e5                	mov    %esp,%ebp
f0104e9a:	57                   	push   %edi
f0104e9b:	56                   	push   %esi
f0104e9c:	53                   	push   %ebx
f0104e9d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ea0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ea3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104ea6:	ba 00 00 00 00       	mov    $0x0,%edx
f0104eab:	eb 16                	jmp    f0104ec3 <memcmp+0x2c>
		if (*s1 != *s2)
f0104ead:	8a 04 17             	mov    (%edi,%edx,1),%al
f0104eb0:	42                   	inc    %edx
f0104eb1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0104eb5:	38 c8                	cmp    %cl,%al
f0104eb7:	74 0a                	je     f0104ec3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0104eb9:	0f b6 c0             	movzbl %al,%eax
f0104ebc:	0f b6 c9             	movzbl %cl,%ecx
f0104ebf:	29 c8                	sub    %ecx,%eax
f0104ec1:	eb 09                	jmp    f0104ecc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104ec3:	39 da                	cmp    %ebx,%edx
f0104ec5:	75 e6                	jne    f0104ead <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104ec7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ecc:	5b                   	pop    %ebx
f0104ecd:	5e                   	pop    %esi
f0104ece:	5f                   	pop    %edi
f0104ecf:	5d                   	pop    %ebp
f0104ed0:	c3                   	ret    

f0104ed1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104ed1:	55                   	push   %ebp
f0104ed2:	89 e5                	mov    %esp,%ebp
f0104ed4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ed7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104eda:	89 c2                	mov    %eax,%edx
f0104edc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104edf:	eb 05                	jmp    f0104ee6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104ee1:	38 08                	cmp    %cl,(%eax)
f0104ee3:	74 05                	je     f0104eea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104ee5:	40                   	inc    %eax
f0104ee6:	39 d0                	cmp    %edx,%eax
f0104ee8:	72 f7                	jb     f0104ee1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104eea:	5d                   	pop    %ebp
f0104eeb:	c3                   	ret    

f0104eec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104eec:	55                   	push   %ebp
f0104eed:	89 e5                	mov    %esp,%ebp
f0104eef:	57                   	push   %edi
f0104ef0:	56                   	push   %esi
f0104ef1:	53                   	push   %ebx
f0104ef2:	8b 55 08             	mov    0x8(%ebp),%edx
f0104ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104ef8:	eb 01                	jmp    f0104efb <strtol+0xf>
		s++;
f0104efa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104efb:	8a 02                	mov    (%edx),%al
f0104efd:	3c 20                	cmp    $0x20,%al
f0104eff:	74 f9                	je     f0104efa <strtol+0xe>
f0104f01:	3c 09                	cmp    $0x9,%al
f0104f03:	74 f5                	je     f0104efa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104f05:	3c 2b                	cmp    $0x2b,%al
f0104f07:	75 08                	jne    f0104f11 <strtol+0x25>
		s++;
f0104f09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104f0a:	bf 00 00 00 00       	mov    $0x0,%edi
f0104f0f:	eb 13                	jmp    f0104f24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104f11:	3c 2d                	cmp    $0x2d,%al
f0104f13:	75 0a                	jne    f0104f1f <strtol+0x33>
		s++, neg = 1;
f0104f15:	8d 52 01             	lea    0x1(%edx),%edx
f0104f18:	bf 01 00 00 00       	mov    $0x1,%edi
f0104f1d:	eb 05                	jmp    f0104f24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104f1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104f24:	85 db                	test   %ebx,%ebx
f0104f26:	74 05                	je     f0104f2d <strtol+0x41>
f0104f28:	83 fb 10             	cmp    $0x10,%ebx
f0104f2b:	75 28                	jne    f0104f55 <strtol+0x69>
f0104f2d:	8a 02                	mov    (%edx),%al
f0104f2f:	3c 30                	cmp    $0x30,%al
f0104f31:	75 10                	jne    f0104f43 <strtol+0x57>
f0104f33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104f37:	75 0a                	jne    f0104f43 <strtol+0x57>
		s += 2, base = 16;
f0104f39:	83 c2 02             	add    $0x2,%edx
f0104f3c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104f41:	eb 12                	jmp    f0104f55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104f43:	85 db                	test   %ebx,%ebx
f0104f45:	75 0e                	jne    f0104f55 <strtol+0x69>
f0104f47:	3c 30                	cmp    $0x30,%al
f0104f49:	75 05                	jne    f0104f50 <strtol+0x64>
		s++, base = 8;
f0104f4b:	42                   	inc    %edx
f0104f4c:	b3 08                	mov    $0x8,%bl
f0104f4e:	eb 05                	jmp    f0104f55 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104f50:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104f55:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104f5c:	8a 0a                	mov    (%edx),%cl
f0104f5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104f61:	80 fb 09             	cmp    $0x9,%bl
f0104f64:	77 08                	ja     f0104f6e <strtol+0x82>
			dig = *s - '0';
f0104f66:	0f be c9             	movsbl %cl,%ecx
f0104f69:	83 e9 30             	sub    $0x30,%ecx
f0104f6c:	eb 1e                	jmp    f0104f8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104f6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104f71:	80 fb 19             	cmp    $0x19,%bl
f0104f74:	77 08                	ja     f0104f7e <strtol+0x92>
			dig = *s - 'a' + 10;
f0104f76:	0f be c9             	movsbl %cl,%ecx
f0104f79:	83 e9 57             	sub    $0x57,%ecx
f0104f7c:	eb 0e                	jmp    f0104f8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0104f7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104f81:	80 fb 19             	cmp    $0x19,%bl
f0104f84:	77 12                	ja     f0104f98 <strtol+0xac>
			dig = *s - 'A' + 10;
f0104f86:	0f be c9             	movsbl %cl,%ecx
f0104f89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104f8c:	39 f1                	cmp    %esi,%ecx
f0104f8e:	7d 0c                	jge    f0104f9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0104f90:	42                   	inc    %edx
f0104f91:	0f af c6             	imul   %esi,%eax
f0104f94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104f96:	eb c4                	jmp    f0104f5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104f98:	89 c1                	mov    %eax,%ecx
f0104f9a:	eb 02                	jmp    f0104f9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104f9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104f9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104fa2:	74 05                	je     f0104fa9 <strtol+0xbd>
		*endptr = (char *) s;
f0104fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104fa7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104fa9:	85 ff                	test   %edi,%edi
f0104fab:	74 04                	je     f0104fb1 <strtol+0xc5>
f0104fad:	89 c8                	mov    %ecx,%eax
f0104faf:	f7 d8                	neg    %eax
}
f0104fb1:	5b                   	pop    %ebx
f0104fb2:	5e                   	pop    %esi
f0104fb3:	5f                   	pop    %edi
f0104fb4:	5d                   	pop    %ebp
f0104fb5:	c3                   	ret    
	...

f0104fb8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0104fb8:	55                   	push   %ebp
f0104fb9:	57                   	push   %edi
f0104fba:	56                   	push   %esi
f0104fbb:	83 ec 10             	sub    $0x10,%esp
f0104fbe:	8b 74 24 20          	mov    0x20(%esp),%esi
f0104fc2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0104fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0104fce:	89 cd                	mov    %ecx,%ebp
f0104fd0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0104fd4:	85 c0                	test   %eax,%eax
f0104fd6:	75 2c                	jne    f0105004 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0104fd8:	39 f9                	cmp    %edi,%ecx
f0104fda:	77 68                	ja     f0105044 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0104fdc:	85 c9                	test   %ecx,%ecx
f0104fde:	75 0b                	jne    f0104feb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0104fe0:	b8 01 00 00 00       	mov    $0x1,%eax
f0104fe5:	31 d2                	xor    %edx,%edx
f0104fe7:	f7 f1                	div    %ecx
f0104fe9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0104feb:	31 d2                	xor    %edx,%edx
f0104fed:	89 f8                	mov    %edi,%eax
f0104fef:	f7 f1                	div    %ecx
f0104ff1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0104ff3:	89 f0                	mov    %esi,%eax
f0104ff5:	f7 f1                	div    %ecx
f0104ff7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0104ff9:	89 f0                	mov    %esi,%eax
f0104ffb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0104ffd:	83 c4 10             	add    $0x10,%esp
f0105000:	5e                   	pop    %esi
f0105001:	5f                   	pop    %edi
f0105002:	5d                   	pop    %ebp
f0105003:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105004:	39 f8                	cmp    %edi,%eax
f0105006:	77 2c                	ja     f0105034 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0105008:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f010500b:	83 f6 1f             	xor    $0x1f,%esi
f010500e:	75 4c                	jne    f010505c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0105010:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0105012:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0105017:	72 0a                	jb     f0105023 <__udivdi3+0x6b>
f0105019:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f010501d:	0f 87 ad 00 00 00    	ja     f01050d0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0105023:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105028:	89 f0                	mov    %esi,%eax
f010502a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010502c:	83 c4 10             	add    $0x10,%esp
f010502f:	5e                   	pop    %esi
f0105030:	5f                   	pop    %edi
f0105031:	5d                   	pop    %ebp
f0105032:	c3                   	ret    
f0105033:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105034:	31 ff                	xor    %edi,%edi
f0105036:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0105038:	89 f0                	mov    %esi,%eax
f010503a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010503c:	83 c4 10             	add    $0x10,%esp
f010503f:	5e                   	pop    %esi
f0105040:	5f                   	pop    %edi
f0105041:	5d                   	pop    %ebp
f0105042:	c3                   	ret    
f0105043:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105044:	89 fa                	mov    %edi,%edx
f0105046:	89 f0                	mov    %esi,%eax
f0105048:	f7 f1                	div    %ecx
f010504a:	89 c6                	mov    %eax,%esi
f010504c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010504e:	89 f0                	mov    %esi,%eax
f0105050:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0105052:	83 c4 10             	add    $0x10,%esp
f0105055:	5e                   	pop    %esi
f0105056:	5f                   	pop    %edi
f0105057:	5d                   	pop    %ebp
f0105058:	c3                   	ret    
f0105059:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010505c:	89 f1                	mov    %esi,%ecx
f010505e:	d3 e0                	shl    %cl,%eax
f0105060:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0105064:	b8 20 00 00 00       	mov    $0x20,%eax
f0105069:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f010506b:	89 ea                	mov    %ebp,%edx
f010506d:	88 c1                	mov    %al,%cl
f010506f:	d3 ea                	shr    %cl,%edx
f0105071:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0105075:	09 ca                	or     %ecx,%edx
f0105077:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f010507b:	89 f1                	mov    %esi,%ecx
f010507d:	d3 e5                	shl    %cl,%ebp
f010507f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0105083:	89 fd                	mov    %edi,%ebp
f0105085:	88 c1                	mov    %al,%cl
f0105087:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0105089:	89 fa                	mov    %edi,%edx
f010508b:	89 f1                	mov    %esi,%ecx
f010508d:	d3 e2                	shl    %cl,%edx
f010508f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105093:	88 c1                	mov    %al,%cl
f0105095:	d3 ef                	shr    %cl,%edi
f0105097:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0105099:	89 f8                	mov    %edi,%eax
f010509b:	89 ea                	mov    %ebp,%edx
f010509d:	f7 74 24 08          	divl   0x8(%esp)
f01050a1:	89 d1                	mov    %edx,%ecx
f01050a3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01050a5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01050a9:	39 d1                	cmp    %edx,%ecx
f01050ab:	72 17                	jb     f01050c4 <__udivdi3+0x10c>
f01050ad:	74 09                	je     f01050b8 <__udivdi3+0x100>
f01050af:	89 fe                	mov    %edi,%esi
f01050b1:	31 ff                	xor    %edi,%edi
f01050b3:	e9 41 ff ff ff       	jmp    f0104ff9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01050b8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01050bc:	89 f1                	mov    %esi,%ecx
f01050be:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01050c0:	39 c2                	cmp    %eax,%edx
f01050c2:	73 eb                	jae    f01050af <__udivdi3+0xf7>
		{
		  q0--;
f01050c4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01050c7:	31 ff                	xor    %edi,%edi
f01050c9:	e9 2b ff ff ff       	jmp    f0104ff9 <__udivdi3+0x41>
f01050ce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01050d0:	31 f6                	xor    %esi,%esi
f01050d2:	e9 22 ff ff ff       	jmp    f0104ff9 <__udivdi3+0x41>
	...

f01050d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01050d8:	55                   	push   %ebp
f01050d9:	57                   	push   %edi
f01050da:	56                   	push   %esi
f01050db:	83 ec 20             	sub    $0x20,%esp
f01050de:	8b 44 24 30          	mov    0x30(%esp),%eax
f01050e2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01050e6:	89 44 24 14          	mov    %eax,0x14(%esp)
f01050ea:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f01050ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01050f2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f01050f6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f01050f8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01050fa:	85 ed                	test   %ebp,%ebp
f01050fc:	75 16                	jne    f0105114 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f01050fe:	39 f1                	cmp    %esi,%ecx
f0105100:	0f 86 a6 00 00 00    	jbe    f01051ac <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0105106:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0105108:	89 d0                	mov    %edx,%eax
f010510a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f010510c:	83 c4 20             	add    $0x20,%esp
f010510f:	5e                   	pop    %esi
f0105110:	5f                   	pop    %edi
f0105111:	5d                   	pop    %ebp
f0105112:	c3                   	ret    
f0105113:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0105114:	39 f5                	cmp    %esi,%ebp
f0105116:	0f 87 ac 00 00 00    	ja     f01051c8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f010511c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f010511f:	83 f0 1f             	xor    $0x1f,%eax
f0105122:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105126:	0f 84 a8 00 00 00    	je     f01051d4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f010512c:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0105130:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0105132:	bf 20 00 00 00       	mov    $0x20,%edi
f0105137:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f010513b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010513f:	89 f9                	mov    %edi,%ecx
f0105141:	d3 e8                	shr    %cl,%eax
f0105143:	09 e8                	or     %ebp,%eax
f0105145:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0105149:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010514d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0105151:	d3 e0                	shl    %cl,%eax
f0105153:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0105157:	89 f2                	mov    %esi,%edx
f0105159:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f010515b:	8b 44 24 14          	mov    0x14(%esp),%eax
f010515f:	d3 e0                	shl    %cl,%eax
f0105161:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0105165:	8b 44 24 14          	mov    0x14(%esp),%eax
f0105169:	89 f9                	mov    %edi,%ecx
f010516b:	d3 e8                	shr    %cl,%eax
f010516d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010516f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0105171:	89 f2                	mov    %esi,%edx
f0105173:	f7 74 24 18          	divl   0x18(%esp)
f0105177:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0105179:	f7 64 24 0c          	mull   0xc(%esp)
f010517d:	89 c5                	mov    %eax,%ebp
f010517f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0105181:	39 d6                	cmp    %edx,%esi
f0105183:	72 67                	jb     f01051ec <__umoddi3+0x114>
f0105185:	74 75                	je     f01051fc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0105187:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010518b:	29 e8                	sub    %ebp,%eax
f010518d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f010518f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0105193:	d3 e8                	shr    %cl,%eax
f0105195:	89 f2                	mov    %esi,%edx
f0105197:	89 f9                	mov    %edi,%ecx
f0105199:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f010519b:	09 d0                	or     %edx,%eax
f010519d:	89 f2                	mov    %esi,%edx
f010519f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01051a3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01051a5:	83 c4 20             	add    $0x20,%esp
f01051a8:	5e                   	pop    %esi
f01051a9:	5f                   	pop    %edi
f01051aa:	5d                   	pop    %ebp
f01051ab:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01051ac:	85 c9                	test   %ecx,%ecx
f01051ae:	75 0b                	jne    f01051bb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01051b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01051b5:	31 d2                	xor    %edx,%edx
f01051b7:	f7 f1                	div    %ecx
f01051b9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01051bb:	89 f0                	mov    %esi,%eax
f01051bd:	31 d2                	xor    %edx,%edx
f01051bf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01051c1:	89 f8                	mov    %edi,%eax
f01051c3:	e9 3e ff ff ff       	jmp    f0105106 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01051c8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01051ca:	83 c4 20             	add    $0x20,%esp
f01051cd:	5e                   	pop    %esi
f01051ce:	5f                   	pop    %edi
f01051cf:	5d                   	pop    %ebp
f01051d0:	c3                   	ret    
f01051d1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01051d4:	39 f5                	cmp    %esi,%ebp
f01051d6:	72 04                	jb     f01051dc <__umoddi3+0x104>
f01051d8:	39 f9                	cmp    %edi,%ecx
f01051da:	77 06                	ja     f01051e2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01051dc:	89 f2                	mov    %esi,%edx
f01051de:	29 cf                	sub    %ecx,%edi
f01051e0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01051e2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01051e4:	83 c4 20             	add    $0x20,%esp
f01051e7:	5e                   	pop    %esi
f01051e8:	5f                   	pop    %edi
f01051e9:	5d                   	pop    %ebp
f01051ea:	c3                   	ret    
f01051eb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01051ec:	89 d1                	mov    %edx,%ecx
f01051ee:	89 c5                	mov    %eax,%ebp
f01051f0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f01051f4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f01051f8:	eb 8d                	jmp    f0105187 <__umoddi3+0xaf>
f01051fa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01051fc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0105200:	72 ea                	jb     f01051ec <__umoddi3+0x114>
f0105202:	89 f1                	mov    %esi,%ecx
f0105204:	eb 81                	jmp    f0105187 <__umoddi3+0xaf>
