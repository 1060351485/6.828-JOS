
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 20 18 10 f0 	movl   $0xf0101820,(%esp)
f0100055:	e8 d0 08 00 00       	call   f010092a <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 9b 06 00 00       	call   f0100722 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 3c 18 10 f0 	movl   $0xf010183c,(%esp)
f0100092:	e8 93 08 00 00       	call   f010092a <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 44 a9 11 f0       	mov    $0xf011a944,%eax
f01000a8:	2d 00 a3 11 f0       	sub    $0xf011a300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 a3 11 f0 	movl   $0xf011a300,(%esp)
f01000c0:	e8 09 13 00 00       	call   f01013ce <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 45 04 00 00       	call   f010050f <cons_init>
	// Test the stack backtrace function (lab 1 only)
	//test_backtrace(5);

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d1:	e8 e9 06 00 00       	call   f01007bf <monitor>
f01000d6:	eb f2                	jmp    f01000ca <i386_init+0x2d>

f01000d8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000d8:	55                   	push   %ebp
f01000d9:	89 e5                	mov    %esp,%ebp
f01000db:	56                   	push   %esi
f01000dc:	53                   	push   %ebx
f01000dd:	83 ec 10             	sub    $0x10,%esp
f01000e0:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000e3:	83 3d 40 a9 11 f0 00 	cmpl   $0x0,0xf011a940
f01000ea:	75 3d                	jne    f0100129 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000ec:	89 35 40 a9 11 f0    	mov    %esi,0xf011a940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000f2:	fa                   	cli    
f01000f3:	fc                   	cld    

	va_start(ap, fmt);
f01000f4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000fa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0100101:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100105:	c7 04 24 57 18 10 f0 	movl   $0xf0101857,(%esp)
f010010c:	e8 19 08 00 00       	call   f010092a <cprintf>
	vcprintf(fmt, ap);
f0100111:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100115:	89 34 24             	mov    %esi,(%esp)
f0100118:	e8 da 07 00 00       	call   f01008f7 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 93 18 10 f0 	movl   $0xf0101893,(%esp)
f0100124:	e8 01 08 00 00       	call   f010092a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100130:	e8 8a 06 00 00       	call   f01007bf <monitor>
f0100135:	eb f2                	jmp    f0100129 <_panic+0x51>

f0100137 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100137:	55                   	push   %ebp
f0100138:	89 e5                	mov    %esp,%ebp
f010013a:	53                   	push   %ebx
f010013b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010013e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100141:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100144:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100148:	8b 45 08             	mov    0x8(%ebp),%eax
f010014b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010014f:	c7 04 24 6f 18 10 f0 	movl   $0xf010186f,(%esp)
f0100156:	e8 cf 07 00 00       	call   f010092a <cprintf>
	vcprintf(fmt, ap);
f010015b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010015f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100162:	89 04 24             	mov    %eax,(%esp)
f0100165:	e8 8d 07 00 00       	call   f01008f7 <vcprintf>
	cprintf("\n");
f010016a:	c7 04 24 93 18 10 f0 	movl   $0xf0101893,(%esp)
f0100171:	e8 b4 07 00 00       	call   f010092a <cprintf>
	va_end(ap);
}
f0100176:	83 c4 14             	add    $0x14,%esp
f0100179:	5b                   	pop    %ebx
f010017a:	5d                   	pop    %ebp
f010017b:	c3                   	ret    

f010017c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010017c:	55                   	push   %ebp
f010017d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017f:	ba 84 00 00 00       	mov    $0x84,%edx
f0100184:	ec                   	in     (%dx),%al
f0100185:	ec                   	in     (%dx),%al
f0100186:	ec                   	in     (%dx),%al
f0100187:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100188:	5d                   	pop    %ebp
f0100189:	c3                   	ret    

f010018a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100192:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100193:	a8 01                	test   $0x1,%al
f0100195:	74 08                	je     f010019f <serial_proc_data+0x15>
f0100197:	b2 f8                	mov    $0xf8,%dl
f0100199:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010019a:	0f b6 c0             	movzbl %al,%eax
f010019d:	eb 05                	jmp    f01001a4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010019f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001a4:	5d                   	pop    %ebp
f01001a5:	c3                   	ret    

f01001a6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a6:	55                   	push   %ebp
f01001a7:	89 e5                	mov    %esp,%ebp
f01001a9:	53                   	push   %ebx
f01001aa:	83 ec 04             	sub    $0x4,%esp
f01001ad:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001af:	eb 29                	jmp    f01001da <cons_intr+0x34>
		if (c == 0)
f01001b1:	85 c0                	test   %eax,%eax
f01001b3:	74 25                	je     f01001da <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b5:	8b 15 24 a5 11 f0    	mov    0xf011a524,%edx
f01001bb:	88 82 20 a3 11 f0    	mov    %al,-0xfee5ce0(%edx)
f01001c1:	8d 42 01             	lea    0x1(%edx),%eax
f01001c4:	a3 24 a5 11 f0       	mov    %eax,0xf011a524
		if (cons.wpos == CONSBUFSIZE)
f01001c9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ce:	75 0a                	jne    f01001da <cons_intr+0x34>
			cons.wpos = 0;
f01001d0:	c7 05 24 a5 11 f0 00 	movl   $0x0,0xf011a524
f01001d7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001da:	ff d3                	call   *%ebx
f01001dc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001df:	75 d0                	jne    f01001b1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001e1:	83 c4 04             	add    $0x4,%esp
f01001e4:	5b                   	pop    %ebx
f01001e5:	5d                   	pop    %ebp
f01001e6:	c3                   	ret    

f01001e7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001e7:	55                   	push   %ebp
f01001e8:	89 e5                	mov    %esp,%ebp
f01001ea:	57                   	push   %edi
f01001eb:	56                   	push   %esi
f01001ec:	53                   	push   %ebx
f01001ed:	83 ec 2c             	sub    $0x2c,%esp
f01001f0:	89 c6                	mov    %eax,%esi
f01001f2:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001f7:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001fc:	eb 05                	jmp    f0100203 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001fe:	e8 79 ff ff ff       	call   f010017c <delay>
f0100203:	89 fa                	mov    %edi,%edx
f0100205:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100206:	a8 20                	test   $0x20,%al
f0100208:	75 03                	jne    f010020d <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010020a:	4b                   	dec    %ebx
f010020b:	75 f1                	jne    f01001fe <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010020d:	89 f2                	mov    %esi,%edx
f010020f:	89 f0                	mov    %esi,%eax
f0100211:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100214:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100219:	ee                   	out    %al,(%dx)
f010021a:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010021f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100224:	eb 05                	jmp    f010022b <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100226:	e8 51 ff ff ff       	call   f010017c <delay>
f010022b:	89 fa                	mov    %edi,%edx
f010022d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010022e:	84 c0                	test   %al,%al
f0100230:	78 03                	js     f0100235 <cons_putc+0x4e>
f0100232:	4b                   	dec    %ebx
f0100233:	75 f1                	jne    f0100226 <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100235:	ba 78 03 00 00       	mov    $0x378,%edx
f010023a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010023d:	ee                   	out    %al,(%dx)
f010023e:	b2 7a                	mov    $0x7a,%dl
f0100240:	b0 0d                	mov    $0xd,%al
f0100242:	ee                   	out    %al,(%dx)
f0100243:	b0 08                	mov    $0x8,%al
f0100245:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100246:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010024c:	75 06                	jne    f0100254 <cons_putc+0x6d>
		c |= 0x0700;
f010024e:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100254:	89 f0                	mov    %esi,%eax
f0100256:	25 ff 00 00 00       	and    $0xff,%eax
f010025b:	83 f8 09             	cmp    $0x9,%eax
f010025e:	74 78                	je     f01002d8 <cons_putc+0xf1>
f0100260:	83 f8 09             	cmp    $0x9,%eax
f0100263:	7f 0b                	jg     f0100270 <cons_putc+0x89>
f0100265:	83 f8 08             	cmp    $0x8,%eax
f0100268:	0f 85 9e 00 00 00    	jne    f010030c <cons_putc+0x125>
f010026e:	eb 10                	jmp    f0100280 <cons_putc+0x99>
f0100270:	83 f8 0a             	cmp    $0xa,%eax
f0100273:	74 39                	je     f01002ae <cons_putc+0xc7>
f0100275:	83 f8 0d             	cmp    $0xd,%eax
f0100278:	0f 85 8e 00 00 00    	jne    f010030c <cons_putc+0x125>
f010027e:	eb 36                	jmp    f01002b6 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f0100280:	66 a1 34 a5 11 f0    	mov    0xf011a534,%ax
f0100286:	66 85 c0             	test   %ax,%ax
f0100289:	0f 84 e2 00 00 00    	je     f0100371 <cons_putc+0x18a>
			crt_pos--;
f010028f:	48                   	dec    %eax
f0100290:	66 a3 34 a5 11 f0    	mov    %ax,0xf011a534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100296:	0f b7 c0             	movzwl %ax,%eax
f0100299:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010029f:	83 ce 20             	or     $0x20,%esi
f01002a2:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
f01002a8:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002ac:	eb 78                	jmp    f0100326 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002ae:	66 83 05 34 a5 11 f0 	addw   $0x50,0xf011a534
f01002b5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002b6:	66 8b 0d 34 a5 11 f0 	mov    0xf011a534,%cx
f01002bd:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002c2:	89 c8                	mov    %ecx,%eax
f01002c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01002c9:	66 f7 f3             	div    %bx
f01002cc:	66 29 d1             	sub    %dx,%cx
f01002cf:	66 89 0d 34 a5 11 f0 	mov    %cx,0xf011a534
f01002d6:	eb 4e                	jmp    f0100326 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f01002d8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002dd:	e8 05 ff ff ff       	call   f01001e7 <cons_putc>
		cons_putc(' ');
f01002e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e7:	e8 fb fe ff ff       	call   f01001e7 <cons_putc>
		cons_putc(' ');
f01002ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01002f1:	e8 f1 fe ff ff       	call   f01001e7 <cons_putc>
		cons_putc(' ');
f01002f6:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fb:	e8 e7 fe ff ff       	call   f01001e7 <cons_putc>
		cons_putc(' ');
f0100300:	b8 20 00 00 00       	mov    $0x20,%eax
f0100305:	e8 dd fe ff ff       	call   f01001e7 <cons_putc>
f010030a:	eb 1a                	jmp    f0100326 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010030c:	66 a1 34 a5 11 f0    	mov    0xf011a534,%ax
f0100312:	0f b7 c8             	movzwl %ax,%ecx
f0100315:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
f010031b:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010031f:	40                   	inc    %eax
f0100320:	66 a3 34 a5 11 f0    	mov    %ax,0xf011a534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100326:	66 81 3d 34 a5 11 f0 	cmpw   $0x7cf,0xf011a534
f010032d:	cf 07 
f010032f:	76 40                	jbe    f0100371 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100331:	a1 30 a5 11 f0       	mov    0xf011a530,%eax
f0100336:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010033d:	00 
f010033e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100344:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100348:	89 04 24             	mov    %eax,(%esp)
f010034b:	e8 c8 10 00 00       	call   f0101418 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100350:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100356:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010035b:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100361:	40                   	inc    %eax
f0100362:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100367:	75 f2                	jne    f010035b <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100369:	66 83 2d 34 a5 11 f0 	subw   $0x50,0xf011a534
f0100370:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100371:	8b 0d 2c a5 11 f0    	mov    0xf011a52c,%ecx
f0100377:	b0 0e                	mov    $0xe,%al
f0100379:	89 ca                	mov    %ecx,%edx
f010037b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010037c:	66 8b 35 34 a5 11 f0 	mov    0xf011a534,%si
f0100383:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100386:	89 f0                	mov    %esi,%eax
f0100388:	66 c1 e8 08          	shr    $0x8,%ax
f010038c:	89 da                	mov    %ebx,%edx
f010038e:	ee                   	out    %al,(%dx)
f010038f:	b0 0f                	mov    $0xf,%al
f0100391:	89 ca                	mov    %ecx,%edx
f0100393:	ee                   	out    %al,(%dx)
f0100394:	89 f0                	mov    %esi,%eax
f0100396:	89 da                	mov    %ebx,%edx
f0100398:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100399:	83 c4 2c             	add    $0x2c,%esp
f010039c:	5b                   	pop    %ebx
f010039d:	5e                   	pop    %esi
f010039e:	5f                   	pop    %edi
f010039f:	5d                   	pop    %ebp
f01003a0:	c3                   	ret    

f01003a1 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003a1:	55                   	push   %ebp
f01003a2:	89 e5                	mov    %esp,%ebp
f01003a4:	53                   	push   %ebx
f01003a5:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a8:	ba 64 00 00 00       	mov    $0x64,%edx
f01003ad:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01003ae:	a8 01                	test   $0x1,%al
f01003b0:	0f 84 d8 00 00 00    	je     f010048e <kbd_proc_data+0xed>
f01003b6:	b2 60                	mov    $0x60,%dl
f01003b8:	ec                   	in     (%dx),%al
f01003b9:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003bb:	3c e0                	cmp    $0xe0,%al
f01003bd:	75 11                	jne    f01003d0 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01003bf:	83 0d 28 a5 11 f0 40 	orl    $0x40,0xf011a528
		return 0;
f01003c6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003cb:	e9 c3 00 00 00       	jmp    f0100493 <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f01003d0:	84 c0                	test   %al,%al
f01003d2:	79 33                	jns    f0100407 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003d4:	8b 0d 28 a5 11 f0    	mov    0xf011a528,%ecx
f01003da:	f6 c1 40             	test   $0x40,%cl
f01003dd:	75 05                	jne    f01003e4 <kbd_proc_data+0x43>
f01003df:	88 c2                	mov    %al,%dl
f01003e1:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003e4:	0f b6 d2             	movzbl %dl,%edx
f01003e7:	8a 82 c0 18 10 f0    	mov    -0xfefe740(%edx),%al
f01003ed:	83 c8 40             	or     $0x40,%eax
f01003f0:	0f b6 c0             	movzbl %al,%eax
f01003f3:	f7 d0                	not    %eax
f01003f5:	21 c1                	and    %eax,%ecx
f01003f7:	89 0d 28 a5 11 f0    	mov    %ecx,0xf011a528
		return 0;
f01003fd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100402:	e9 8c 00 00 00       	jmp    f0100493 <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f0100407:	8b 0d 28 a5 11 f0    	mov    0xf011a528,%ecx
f010040d:	f6 c1 40             	test   $0x40,%cl
f0100410:	74 0e                	je     f0100420 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100412:	88 c2                	mov    %al,%dl
f0100414:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100417:	83 e1 bf             	and    $0xffffffbf,%ecx
f010041a:	89 0d 28 a5 11 f0    	mov    %ecx,0xf011a528
	}

	shift |= shiftcode[data];
f0100420:	0f b6 d2             	movzbl %dl,%edx
f0100423:	0f b6 82 c0 18 10 f0 	movzbl -0xfefe740(%edx),%eax
f010042a:	0b 05 28 a5 11 f0    	or     0xf011a528,%eax
	shift ^= togglecode[data];
f0100430:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100437:	31 c8                	xor    %ecx,%eax
f0100439:	a3 28 a5 11 f0       	mov    %eax,0xf011a528

	c = charcode[shift & (CTL | SHIFT)][data];
f010043e:	89 c1                	mov    %eax,%ecx
f0100440:	83 e1 03             	and    $0x3,%ecx
f0100443:	8b 0c 8d c0 1a 10 f0 	mov    -0xfefe540(,%ecx,4),%ecx
f010044a:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f010044e:	a8 08                	test   $0x8,%al
f0100450:	74 18                	je     f010046a <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f0100452:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100455:	83 fa 19             	cmp    $0x19,%edx
f0100458:	77 05                	ja     f010045f <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f010045a:	83 eb 20             	sub    $0x20,%ebx
f010045d:	eb 0b                	jmp    f010046a <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f010045f:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100462:	83 fa 19             	cmp    $0x19,%edx
f0100465:	77 03                	ja     f010046a <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f0100467:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010046a:	f7 d0                	not    %eax
f010046c:	a8 06                	test   $0x6,%al
f010046e:	75 23                	jne    f0100493 <kbd_proc_data+0xf2>
f0100470:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100476:	75 1b                	jne    f0100493 <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f0100478:	c7 04 24 89 18 10 f0 	movl   $0xf0101889,(%esp)
f010047f:	e8 a6 04 00 00       	call   f010092a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100484:	ba 92 00 00 00       	mov    $0x92,%edx
f0100489:	b0 03                	mov    $0x3,%al
f010048b:	ee                   	out    %al,(%dx)
f010048c:	eb 05                	jmp    f0100493 <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010048e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100493:	89 d8                	mov    %ebx,%eax
f0100495:	83 c4 14             	add    $0x14,%esp
f0100498:	5b                   	pop    %ebx
f0100499:	5d                   	pop    %ebp
f010049a:	c3                   	ret    

f010049b <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010049b:	55                   	push   %ebp
f010049c:	89 e5                	mov    %esp,%ebp
f010049e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004a1:	80 3d 00 a3 11 f0 00 	cmpb   $0x0,0xf011a300
f01004a8:	74 0a                	je     f01004b4 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004aa:	b8 8a 01 10 f0       	mov    $0xf010018a,%eax
f01004af:	e8 f2 fc ff ff       	call   f01001a6 <cons_intr>
}
f01004b4:	c9                   	leave  
f01004b5:	c3                   	ret    

f01004b6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004b6:	55                   	push   %ebp
f01004b7:	89 e5                	mov    %esp,%ebp
f01004b9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004bc:	b8 a1 03 10 f0       	mov    $0xf01003a1,%eax
f01004c1:	e8 e0 fc ff ff       	call   f01001a6 <cons_intr>
}
f01004c6:	c9                   	leave  
f01004c7:	c3                   	ret    

f01004c8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c8:	55                   	push   %ebp
f01004c9:	89 e5                	mov    %esp,%ebp
f01004cb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004ce:	e8 c8 ff ff ff       	call   f010049b <serial_intr>
	kbd_intr();
f01004d3:	e8 de ff ff ff       	call   f01004b6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d8:	8b 15 20 a5 11 f0    	mov    0xf011a520,%edx
f01004de:	3b 15 24 a5 11 f0    	cmp    0xf011a524,%edx
f01004e4:	74 22                	je     f0100508 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004e6:	0f b6 82 20 a3 11 f0 	movzbl -0xfee5ce0(%edx),%eax
f01004ed:	42                   	inc    %edx
f01004ee:	89 15 20 a5 11 f0    	mov    %edx,0xf011a520
		if (cons.rpos == CONSBUFSIZE)
f01004f4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004fa:	75 11                	jne    f010050d <cons_getc+0x45>
			cons.rpos = 0;
f01004fc:	c7 05 20 a5 11 f0 00 	movl   $0x0,0xf011a520
f0100503:	00 00 00 
f0100506:	eb 05                	jmp    f010050d <cons_getc+0x45>
		return c;
	}
	return 0;
f0100508:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010050d:	c9                   	leave  
f010050e:	c3                   	ret    

f010050f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010050f:	55                   	push   %ebp
f0100510:	89 e5                	mov    %esp,%ebp
f0100512:	57                   	push   %edi
f0100513:	56                   	push   %esi
f0100514:	53                   	push   %ebx
f0100515:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100518:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010051f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100526:	5a a5 
	if (*cp != 0xA55A) {
f0100528:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010052e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100532:	74 11                	je     f0100545 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100534:	c7 05 2c a5 11 f0 b4 	movl   $0x3b4,0xf011a52c
f010053b:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010053e:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100543:	eb 16                	jmp    f010055b <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100545:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010054c:	c7 05 2c a5 11 f0 d4 	movl   $0x3d4,0xf011a52c
f0100553:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100556:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010055b:	8b 0d 2c a5 11 f0    	mov    0xf011a52c,%ecx
f0100561:	b0 0e                	mov    $0xe,%al
f0100563:	89 ca                	mov    %ecx,%edx
f0100565:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100566:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100569:	89 da                	mov    %ebx,%edx
f010056b:	ec                   	in     (%dx),%al
f010056c:	0f b6 f8             	movzbl %al,%edi
f010056f:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100572:	b0 0f                	mov    $0xf,%al
f0100574:	89 ca                	mov    %ecx,%edx
f0100576:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100577:	89 da                	mov    %ebx,%edx
f0100579:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010057a:	89 35 30 a5 11 f0    	mov    %esi,0xf011a530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100580:	0f b6 d8             	movzbl %al,%ebx
f0100583:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100585:	66 89 3d 34 a5 11 f0 	mov    %di,0xf011a534
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010058c:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100591:	b0 00                	mov    $0x0,%al
f0100593:	89 da                	mov    %ebx,%edx
f0100595:	ee                   	out    %al,(%dx)
f0100596:	b2 fb                	mov    $0xfb,%dl
f0100598:	b0 80                	mov    $0x80,%al
f010059a:	ee                   	out    %al,(%dx)
f010059b:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005a0:	b0 0c                	mov    $0xc,%al
f01005a2:	89 ca                	mov    %ecx,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 f9                	mov    $0xf9,%dl
f01005a7:	b0 00                	mov    $0x0,%al
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	b2 fb                	mov    $0xfb,%dl
f01005ac:	b0 03                	mov    $0x3,%al
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	b2 fc                	mov    $0xfc,%dl
f01005b1:	b0 00                	mov    $0x0,%al
f01005b3:	ee                   	out    %al,(%dx)
f01005b4:	b2 f9                	mov    $0xf9,%dl
f01005b6:	b0 01                	mov    $0x1,%al
f01005b8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b9:	b2 fd                	mov    $0xfd,%dl
f01005bb:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005bc:	3c ff                	cmp    $0xff,%al
f01005be:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005c2:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005c5:	a2 00 a3 11 f0       	mov    %al,0xf011a300
f01005ca:	89 da                	mov    %ebx,%edx
f01005cc:	ec                   	in     (%dx),%al
f01005cd:	89 ca                	mov    %ecx,%edx
f01005cf:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d0:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005d4:	75 0c                	jne    f01005e2 <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f01005d6:	c7 04 24 95 18 10 f0 	movl   $0xf0101895,(%esp)
f01005dd:	e8 48 03 00 00       	call   f010092a <cprintf>
}
f01005e2:	83 c4 2c             	add    $0x2c,%esp
f01005e5:	5b                   	pop    %ebx
f01005e6:	5e                   	pop    %esi
f01005e7:	5f                   	pop    %edi
f01005e8:	5d                   	pop    %ebp
f01005e9:	c3                   	ret    

f01005ea <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005ea:	55                   	push   %ebp
f01005eb:	89 e5                	mov    %esp,%ebp
f01005ed:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01005f3:	e8 ef fb ff ff       	call   f01001e7 <cons_putc>
}
f01005f8:	c9                   	leave  
f01005f9:	c3                   	ret    

f01005fa <getchar>:

int
getchar(void)
{
f01005fa:	55                   	push   %ebp
f01005fb:	89 e5                	mov    %esp,%ebp
f01005fd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100600:	e8 c3 fe ff ff       	call   f01004c8 <cons_getc>
f0100605:	85 c0                	test   %eax,%eax
f0100607:	74 f7                	je     f0100600 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100609:	c9                   	leave  
f010060a:	c3                   	ret    

f010060b <iscons>:

int
iscons(int fdnum)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010060e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100613:	5d                   	pop    %ebp
f0100614:	c3                   	ret    
f0100615:	00 00                	add    %al,(%eax)
	...

f0100618 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100618:	55                   	push   %ebp
f0100619:	89 e5                	mov    %esp,%ebp
f010061b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010061e:	c7 04 24 d0 1a 10 f0 	movl   $0xf0101ad0,(%esp)
f0100625:	e8 00 03 00 00       	call   f010092a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010062a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100631:	00 
f0100632:	c7 04 24 80 1b 10 f0 	movl   $0xf0101b80,(%esp)
f0100639:	e8 ec 02 00 00       	call   f010092a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010063e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100645:	00 
f0100646:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010064d:	f0 
f010064e:	c7 04 24 a8 1b 10 f0 	movl   $0xf0101ba8,(%esp)
f0100655:	e8 d0 02 00 00       	call   f010092a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010065a:	c7 44 24 08 12 18 10 	movl   $0x101812,0x8(%esp)
f0100661:	00 
f0100662:	c7 44 24 04 12 18 10 	movl   $0xf0101812,0x4(%esp)
f0100669:	f0 
f010066a:	c7 04 24 cc 1b 10 f0 	movl   $0xf0101bcc,(%esp)
f0100671:	e8 b4 02 00 00       	call   f010092a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100676:	c7 44 24 08 00 a3 11 	movl   $0x11a300,0x8(%esp)
f010067d:	00 
f010067e:	c7 44 24 04 00 a3 11 	movl   $0xf011a300,0x4(%esp)
f0100685:	f0 
f0100686:	c7 04 24 f0 1b 10 f0 	movl   $0xf0101bf0,(%esp)
f010068d:	e8 98 02 00 00       	call   f010092a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100692:	c7 44 24 08 44 a9 11 	movl   $0x11a944,0x8(%esp)
f0100699:	00 
f010069a:	c7 44 24 04 44 a9 11 	movl   $0xf011a944,0x4(%esp)
f01006a1:	f0 
f01006a2:	c7 04 24 14 1c 10 f0 	movl   $0xf0101c14,(%esp)
f01006a9:	e8 7c 02 00 00       	call   f010092a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006ae:	b8 43 ad 11 f0       	mov    $0xf011ad43,%eax
f01006b3:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006b8:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006bd:	89 c2                	mov    %eax,%edx
f01006bf:	85 c0                	test   %eax,%eax
f01006c1:	79 06                	jns    f01006c9 <mon_kerninfo+0xb1>
f01006c3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006c9:	c1 fa 0a             	sar    $0xa,%edx
f01006cc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006d0:	c7 04 24 38 1c 10 f0 	movl   $0xf0101c38,(%esp)
f01006d7:	e8 4e 02 00 00       	call   f010092a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e1:	c9                   	leave  
f01006e2:	c3                   	ret    

f01006e3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006e3:	55                   	push   %ebp
f01006e4:	89 e5                	mov    %esp,%ebp
f01006e6:	53                   	push   %ebx
f01006e7:	83 ec 14             	sub    $0x14,%esp
f01006ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006ef:	8b 83 24 1d 10 f0    	mov    -0xfefe2dc(%ebx),%eax
f01006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006f9:	8b 83 20 1d 10 f0    	mov    -0xfefe2e0(%ebx),%eax
f01006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100703:	c7 04 24 e9 1a 10 f0 	movl   $0xf0101ae9,(%esp)
f010070a:	e8 1b 02 00 00       	call   f010092a <cprintf>
f010070f:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100712:	83 fb 24             	cmp    $0x24,%ebx
f0100715:	75 d8                	jne    f01006ef <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100717:	b8 00 00 00 00       	mov    $0x0,%eax
f010071c:	83 c4 14             	add    $0x14,%esp
f010071f:	5b                   	pop    %ebx
f0100720:	5d                   	pop    %ebp
f0100721:	c3                   	ret    

f0100722 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100722:	55                   	push   %ebp
f0100723:	89 e5                	mov    %esp,%ebp
f0100725:	57                   	push   %edi
f0100726:	56                   	push   %esi
f0100727:	53                   	push   %ebx
f0100728:	83 ec 6c             	sub    $0x6c,%esp
	// Your code here.
	
	int bt_cnt = 0;
	struct Eipdebuginfo eip_info;
	int* pre_ebp = (int *)read_ebp();
f010072b:	89 eb                	mov    %ebp,%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
f010072d:	c7 04 24 f2 1a 10 f0 	movl   $0xf0101af2,(%esp)
f0100734:	e8 f1 01 00 00       	call   f010092a <cprintf>
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	int bt_cnt = 0;
f0100739:	bf 00 00 00 00       	mov    $0x0,%edi
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f010073e:	eb 71                	jmp    f01007b1 <mon_backtrace+0x8f>
		bt_cnt++;
f0100740:	47                   	inc    %edi
		eip = (int)*(pre_ebp+1);
f0100741:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip((uintptr_t)eip, &eip_info);
f0100744:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100747:	89 44 24 04          	mov    %eax,0x4(%esp)
f010074b:	89 34 24             	mov    %esi,(%esp)
f010074e:	e8 d1 02 00 00       	call   f0100a24 <debuginfo_eip>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
f0100753:	89 f0                	mov    %esi,%eax
f0100755:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100758:	89 44 24 30          	mov    %eax,0x30(%esp)
f010075c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010075f:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0100763:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100766:	89 44 24 28          	mov    %eax,0x28(%esp)
f010076a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010076d:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100771:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100774:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100778:	8b 43 18             	mov    0x18(%ebx),%eax
f010077b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010077f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100782:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100786:	8b 43 10             	mov    0x10(%ebx),%eax
f0100789:	89 44 24 14          	mov    %eax,0x14(%esp)
f010078d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100790:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100794:	8b 43 08             	mov    0x8(%ebx),%eax
f0100797:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010079b:	89 74 24 08          	mov    %esi,0x8(%esp)
f010079f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01007a3:	c7 04 24 64 1c 10 f0 	movl   $0xf0101c64,(%esp)
f01007aa:	e8 7b 01 00 00       	call   f010092a <cprintf>
		
		pre_ebp = (int *)*pre_ebp;
f01007af:	8b 1b                	mov    (%ebx),%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f01007b1:	85 db                	test   %ebx,%ebx
f01007b3:	75 8b                	jne    f0100740 <mon_backtrace+0x1e>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
		
		pre_ebp = (int *)*pre_ebp;
	}
	return bt_cnt;
}
f01007b5:	89 f8                	mov    %edi,%eax
f01007b7:	83 c4 6c             	add    $0x6c,%esp
f01007ba:	5b                   	pop    %ebx
f01007bb:	5e                   	pop    %esi
f01007bc:	5f                   	pop    %edi
f01007bd:	5d                   	pop    %ebp
f01007be:	c3                   	ret    

f01007bf <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007bf:	55                   	push   %ebp
f01007c0:	89 e5                	mov    %esp,%ebp
f01007c2:	57                   	push   %edi
f01007c3:	56                   	push   %esi
f01007c4:	53                   	push   %ebx
f01007c5:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007c8:	c7 04 24 ac 1c 10 f0 	movl   $0xf0101cac,(%esp)
f01007cf:	e8 56 01 00 00       	call   f010092a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007d4:	c7 04 24 d0 1c 10 f0 	movl   $0xf0101cd0,(%esp)
f01007db:	e8 4a 01 00 00       	call   f010092a <cprintf>
	
	while (1) {
		buf = readline("K> ");
f01007e0:	c7 04 24 04 1b 10 f0 	movl   $0xf0101b04,(%esp)
f01007e7:	e8 b8 09 00 00       	call   f01011a4 <readline>
f01007ec:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007ee:	85 c0                	test   %eax,%eax
f01007f0:	74 ee                	je     f01007e0 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007f2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007f9:	be 00 00 00 00       	mov    $0x0,%esi
f01007fe:	eb 04                	jmp    f0100804 <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100800:	c6 03 00             	movb   $0x0,(%ebx)
f0100803:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100804:	8a 03                	mov    (%ebx),%al
f0100806:	84 c0                	test   %al,%al
f0100808:	74 5e                	je     f0100868 <monitor+0xa9>
f010080a:	0f be c0             	movsbl %al,%eax
f010080d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100811:	c7 04 24 08 1b 10 f0 	movl   $0xf0101b08,(%esp)
f0100818:	e8 7c 0b 00 00       	call   f0101399 <strchr>
f010081d:	85 c0                	test   %eax,%eax
f010081f:	75 df                	jne    f0100800 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100821:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100824:	74 42                	je     f0100868 <monitor+0xa9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100826:	83 fe 0f             	cmp    $0xf,%esi
f0100829:	75 16                	jne    f0100841 <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010082b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100832:	00 
f0100833:	c7 04 24 0d 1b 10 f0 	movl   $0xf0101b0d,(%esp)
f010083a:	e8 eb 00 00 00       	call   f010092a <cprintf>
f010083f:	eb 9f                	jmp    f01007e0 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100841:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100845:	46                   	inc    %esi
f0100846:	eb 01                	jmp    f0100849 <monitor+0x8a>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100848:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100849:	8a 03                	mov    (%ebx),%al
f010084b:	84 c0                	test   %al,%al
f010084d:	74 b5                	je     f0100804 <monitor+0x45>
f010084f:	0f be c0             	movsbl %al,%eax
f0100852:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100856:	c7 04 24 08 1b 10 f0 	movl   $0xf0101b08,(%esp)
f010085d:	e8 37 0b 00 00       	call   f0101399 <strchr>
f0100862:	85 c0                	test   %eax,%eax
f0100864:	74 e2                	je     f0100848 <monitor+0x89>
f0100866:	eb 9c                	jmp    f0100804 <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f0100868:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010086f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100870:	85 f6                	test   %esi,%esi
f0100872:	0f 84 68 ff ff ff    	je     f01007e0 <monitor+0x21>
f0100878:	bb 20 1d 10 f0       	mov    $0xf0101d20,%ebx
f010087d:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100882:	8b 03                	mov    (%ebx),%eax
f0100884:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100888:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010088b:	89 04 24             	mov    %eax,(%esp)
f010088e:	e8 b3 0a 00 00       	call   f0101346 <strcmp>
f0100893:	85 c0                	test   %eax,%eax
f0100895:	75 24                	jne    f01008bb <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f0100897:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010089a:	8b 55 08             	mov    0x8(%ebp),%edx
f010089d:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008a1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008a4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008a8:	89 34 24             	mov    %esi,(%esp)
f01008ab:	ff 14 85 28 1d 10 f0 	call   *-0xfefe2d8(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008b2:	85 c0                	test   %eax,%eax
f01008b4:	78 26                	js     f01008dc <monitor+0x11d>
f01008b6:	e9 25 ff ff ff       	jmp    f01007e0 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008bb:	47                   	inc    %edi
f01008bc:	83 c3 0c             	add    $0xc,%ebx
f01008bf:	83 ff 03             	cmp    $0x3,%edi
f01008c2:	75 be                	jne    f0100882 <monitor+0xc3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cb:	c7 04 24 2a 1b 10 f0 	movl   $0xf0101b2a,(%esp)
f01008d2:	e8 53 00 00 00       	call   f010092a <cprintf>
f01008d7:	e9 04 ff ff ff       	jmp    f01007e0 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008dc:	83 c4 5c             	add    $0x5c,%esp
f01008df:	5b                   	pop    %ebx
f01008e0:	5e                   	pop    %esi
f01008e1:	5f                   	pop    %edi
f01008e2:	5d                   	pop    %ebp
f01008e3:	c3                   	ret    

f01008e4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008e4:	55                   	push   %ebp
f01008e5:	89 e5                	mov    %esp,%ebp
f01008e7:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01008ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01008ed:	89 04 24             	mov    %eax,(%esp)
f01008f0:	e8 f5 fc ff ff       	call   f01005ea <cputchar>
	*cnt++;
}
f01008f5:	c9                   	leave  
f01008f6:	c3                   	ret    

f01008f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008f7:	55                   	push   %ebp
f01008f8:	89 e5                	mov    %esp,%ebp
f01008fa:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01008fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100904:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100907:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010090b:	8b 45 08             	mov    0x8(%ebp),%eax
f010090e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100912:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100915:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100919:	c7 04 24 e4 08 10 f0 	movl   $0xf01008e4,(%esp)
f0100920:	e8 69 04 00 00       	call   f0100d8e <vprintfmt>
	return cnt;
}
f0100925:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100928:	c9                   	leave  
f0100929:	c3                   	ret    

f010092a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010092a:	55                   	push   %ebp
f010092b:	89 e5                	mov    %esp,%ebp
f010092d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100930:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100933:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100937:	8b 45 08             	mov    0x8(%ebp),%eax
f010093a:	89 04 24             	mov    %eax,(%esp)
f010093d:	e8 b5 ff ff ff       	call   f01008f7 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100942:	c9                   	leave  
f0100943:	c3                   	ret    

f0100944 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100944:	55                   	push   %ebp
f0100945:	89 e5                	mov    %esp,%ebp
f0100947:	57                   	push   %edi
f0100948:	56                   	push   %esi
f0100949:	53                   	push   %ebx
f010094a:	83 ec 10             	sub    $0x10,%esp
f010094d:	89 c3                	mov    %eax,%ebx
f010094f:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100952:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100955:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100958:	8b 0a                	mov    (%edx),%ecx
f010095a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010095d:	8b 00                	mov    (%eax),%eax
f010095f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100962:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100969:	eb 77                	jmp    f01009e2 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f010096b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010096e:	01 c8                	add    %ecx,%eax
f0100970:	bf 02 00 00 00       	mov    $0x2,%edi
f0100975:	99                   	cltd   
f0100976:	f7 ff                	idiv   %edi
f0100978:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010097a:	eb 01                	jmp    f010097d <stab_binsearch+0x39>
			m--;
f010097c:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010097d:	39 ca                	cmp    %ecx,%edx
f010097f:	7c 1d                	jl     f010099e <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100981:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100984:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0100989:	39 f7                	cmp    %esi,%edi
f010098b:	75 ef                	jne    f010097c <stab_binsearch+0x38>
f010098d:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100990:	6b fa 0c             	imul   $0xc,%edx,%edi
f0100993:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0100997:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f010099a:	73 18                	jae    f01009b4 <stab_binsearch+0x70>
f010099c:	eb 05                	jmp    f01009a3 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010099e:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f01009a1:	eb 3f                	jmp    f01009e2 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01009a3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009a6:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f01009a8:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009ab:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01009b2:	eb 2e                	jmp    f01009e2 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009b4:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f01009b7:	76 15                	jbe    f01009ce <stab_binsearch+0x8a>
			*region_right = m - 1;
f01009b9:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01009bc:	4f                   	dec    %edi
f01009bd:	89 7d f0             	mov    %edi,-0x10(%ebp)
f01009c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009c3:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009c5:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01009cc:	eb 14                	jmp    f01009e2 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01009ce:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01009d1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009d4:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f01009d6:	ff 45 0c             	incl   0xc(%ebp)
f01009d9:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009db:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01009e2:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f01009e5:	7e 84                	jle    f010096b <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01009e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01009eb:	75 0d                	jne    f01009fa <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f01009ed:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01009f0:	8b 02                	mov    (%edx),%eax
f01009f2:	48                   	dec    %eax
f01009f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01009f6:	89 01                	mov    %eax,(%ecx)
f01009f8:	eb 22                	jmp    f0100a1c <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01009fd:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009ff:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a02:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a04:	eb 01                	jmp    f0100a07 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a06:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a07:	39 c1                	cmp    %eax,%ecx
f0100a09:	7d 0c                	jge    f0100a17 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100a0b:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100a0e:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100a13:	39 f2                	cmp    %esi,%edx
f0100a15:	75 ef                	jne    f0100a06 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a17:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a1a:	89 02                	mov    %eax,(%edx)
	}
}
f0100a1c:	83 c4 10             	add    $0x10,%esp
f0100a1f:	5b                   	pop    %ebx
f0100a20:	5e                   	pop    %esi
f0100a21:	5f                   	pop    %edi
f0100a22:	5d                   	pop    %ebp
f0100a23:	c3                   	ret    

f0100a24 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a24:	55                   	push   %ebp
f0100a25:	89 e5                	mov    %esp,%ebp
f0100a27:	57                   	push   %edi
f0100a28:	56                   	push   %esi
f0100a29:	53                   	push   %ebx
f0100a2a:	83 ec 4c             	sub    $0x4c,%esp
f0100a2d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a33:	c7 03 44 1d 10 f0    	movl   $0xf0101d44,(%ebx)
	info->eip_line = 0;
f0100a39:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a40:	c7 43 08 44 1d 10 f0 	movl   $0xf0101d44,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a47:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a4e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a51:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a58:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100a5e:	76 12                	jbe    f0100a72 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a60:	b8 9c f1 10 f0       	mov    $0xf010f19c,%eax
f0100a65:	3d 39 65 10 f0       	cmp    $0xf0106539,%eax
f0100a6a:	0f 86 a7 01 00 00    	jbe    f0100c17 <debuginfo_eip+0x1f3>
f0100a70:	eb 1c                	jmp    f0100a8e <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a72:	c7 44 24 08 4e 1d 10 	movl   $0xf0101d4e,0x8(%esp)
f0100a79:	f0 
f0100a7a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100a81:	00 
f0100a82:	c7 04 24 5b 1d 10 f0 	movl   $0xf0101d5b,(%esp)
f0100a89:	e8 4a f6 ff ff       	call   f01000d8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a93:	80 3d 9b f1 10 f0 00 	cmpb   $0x0,0xf010f19b
f0100a9a:	0f 85 83 01 00 00    	jne    f0100c23 <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100aa0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aa7:	b8 38 65 10 f0       	mov    $0xf0106538,%eax
f0100aac:	2d 90 1f 10 f0       	sub    $0xf0101f90,%eax
f0100ab1:	c1 f8 02             	sar    $0x2,%eax
f0100ab4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100aba:	48                   	dec    %eax
f0100abb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100abe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ac2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100ac9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100acc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100acf:	b8 90 1f 10 f0       	mov    $0xf0101f90,%eax
f0100ad4:	e8 6b fe ff ff       	call   f0100944 <stab_binsearch>
	if (lfile == 0)
f0100ad9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100ae1:	85 d2                	test   %edx,%edx
f0100ae3:	0f 84 3a 01 00 00    	je     f0100c23 <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ae9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100aec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aef:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100af2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100af6:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100afd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b00:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b03:	b8 90 1f 10 f0       	mov    $0xf0101f90,%eax
f0100b08:	e8 37 fe ff ff       	call   f0100944 <stab_binsearch>

	if (lfun <= rfun) {
f0100b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b10:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b13:	39 d0                	cmp    %edx,%eax
f0100b15:	7f 3e                	jg     f0100b55 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b17:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100b1a:	8d b9 90 1f 10 f0    	lea    -0xfefe070(%ecx),%edi
f0100b20:	8b 89 90 1f 10 f0    	mov    -0xfefe070(%ecx),%ecx
f0100b26:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100b29:	b9 9c f1 10 f0       	mov    $0xf010f19c,%ecx
f0100b2e:	81 e9 39 65 10 f0    	sub    $0xf0106539,%ecx
f0100b34:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0100b37:	73 0c                	jae    f0100b45 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b39:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0100b3c:	81 c1 39 65 10 f0    	add    $0xf0106539,%ecx
f0100b42:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b45:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b48:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100b4b:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100b4d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100b50:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100b53:	eb 0f                	jmp    f0100b64 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b55:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100b5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b61:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b64:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100b6b:	00 
f0100b6c:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b6f:	89 04 24             	mov    %eax,(%esp)
f0100b72:	e8 3f 08 00 00       	call   f01013b6 <strfind>
f0100b77:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b7a:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
f0100b7d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b81:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100b88:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100b8b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100b8e:	b8 90 1f 10 f0       	mov    $0xf0101f90,%eax
f0100b93:	e8 ac fd ff ff       	call   f0100944 <stab_binsearch>
	if (lline > rline )
f0100b98:	8b 55 d0             	mov    -0x30(%ebp),%edx
		return -1;	
f0100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
	if (lline > rline )
f0100ba0:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100ba3:	7f 7e                	jg     f0100c23 <debuginfo_eip+0x1ff>
		return -1;	
	info->eip_line = stabs[rline].n_desc;
f0100ba5:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100ba8:	0f b7 82 96 1f 10 f0 	movzwl -0xfefe06a(%edx),%eax
f0100baf:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bb2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bb8:	eb 01                	jmp    f0100bbb <debuginfo_eip+0x197>
f0100bba:	48                   	dec    %eax
f0100bbb:	89 c6                	mov    %eax,%esi
f0100bbd:	39 c7                	cmp    %eax,%edi
f0100bbf:	7f 26                	jg     f0100be7 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0100bc1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bc4:	8d 0c 95 90 1f 10 f0 	lea    -0xfefe070(,%edx,4),%ecx
f0100bcb:	8a 51 04             	mov    0x4(%ecx),%dl
f0100bce:	80 fa 84             	cmp    $0x84,%dl
f0100bd1:	74 58                	je     f0100c2b <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100bd3:	80 fa 64             	cmp    $0x64,%dl
f0100bd6:	75 e2                	jne    f0100bba <debuginfo_eip+0x196>
f0100bd8:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0100bdc:	74 dc                	je     f0100bba <debuginfo_eip+0x196>
f0100bde:	eb 4b                	jmp    f0100c2b <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100be0:	05 39 65 10 f0       	add    $0xf0106539,%eax
f0100be5:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100be7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100bea:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bed:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bf2:	39 d1                	cmp    %edx,%ecx
f0100bf4:	7d 2d                	jge    f0100c23 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0100bf6:	8d 41 01             	lea    0x1(%ecx),%eax
f0100bf9:	eb 03                	jmp    f0100bfe <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100bfb:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100bfe:	39 d0                	cmp    %edx,%eax
f0100c00:	7d 1c                	jge    f0100c1e <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c02:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100c05:	40                   	inc    %eax
f0100c06:	80 3c 8d 94 1f 10 f0 	cmpb   $0xa0,-0xfefe06c(,%ecx,4)
f0100c0d:	a0 
f0100c0e:	74 eb                	je     f0100bfb <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c15:	eb 0c                	jmp    f0100c23 <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c1c:	eb 05                	jmp    f0100c23 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c23:	83 c4 4c             	add    $0x4c,%esp
f0100c26:	5b                   	pop    %ebx
f0100c27:	5e                   	pop    %esi
f0100c28:	5f                   	pop    %edi
f0100c29:	5d                   	pop    %ebp
f0100c2a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c2b:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100c2e:	8b 86 90 1f 10 f0    	mov    -0xfefe070(%esi),%eax
f0100c34:	ba 9c f1 10 f0       	mov    $0xf010f19c,%edx
f0100c39:	81 ea 39 65 10 f0    	sub    $0xf0106539,%edx
f0100c3f:	39 d0                	cmp    %edx,%eax
f0100c41:	72 9d                	jb     f0100be0 <debuginfo_eip+0x1bc>
f0100c43:	eb a2                	jmp    f0100be7 <debuginfo_eip+0x1c3>
f0100c45:	00 00                	add    %al,(%eax)
	...

f0100c48 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c48:	55                   	push   %ebp
f0100c49:	89 e5                	mov    %esp,%ebp
f0100c4b:	57                   	push   %edi
f0100c4c:	56                   	push   %esi
f0100c4d:	53                   	push   %ebx
f0100c4e:	83 ec 3c             	sub    $0x3c,%esp
f0100c51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c54:	89 d7                	mov    %edx,%edi
f0100c56:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c59:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c62:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c65:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c68:	85 c0                	test   %eax,%eax
f0100c6a:	75 08                	jne    f0100c74 <printnum+0x2c>
f0100c6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c6f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c72:	77 57                	ja     f0100ccb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c74:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100c78:	4b                   	dec    %ebx
f0100c79:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100c7d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c80:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c84:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100c88:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100c8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100c93:	00 
f0100c94:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c97:	89 04 24             	mov    %eax,(%esp)
f0100c9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ca1:	e8 1e 09 00 00       	call   f01015c4 <__udivdi3>
f0100ca6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100caa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100cae:	89 04 24             	mov    %eax,(%esp)
f0100cb1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cb5:	89 fa                	mov    %edi,%edx
f0100cb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cba:	e8 89 ff ff ff       	call   f0100c48 <printnum>
f0100cbf:	eb 0f                	jmp    f0100cd0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100cc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100cc5:	89 34 24             	mov    %esi,(%esp)
f0100cc8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100ccb:	4b                   	dec    %ebx
f0100ccc:	85 db                	test   %ebx,%ebx
f0100cce:	7f f1                	jg     f0100cc1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100cd0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100cd4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100cd8:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cdf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100ce6:	00 
f0100ce7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cea:	89 04 24             	mov    %eax,(%esp)
f0100ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cf4:	e8 eb 09 00 00       	call   f01016e4 <__umoddi3>
f0100cf9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100cfd:	0f be 80 69 1d 10 f0 	movsbl -0xfefe297(%eax),%eax
f0100d04:	89 04 24             	mov    %eax,(%esp)
f0100d07:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100d0a:	83 c4 3c             	add    $0x3c,%esp
f0100d0d:	5b                   	pop    %ebx
f0100d0e:	5e                   	pop    %esi
f0100d0f:	5f                   	pop    %edi
f0100d10:	5d                   	pop    %ebp
f0100d11:	c3                   	ret    

f0100d12 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d12:	55                   	push   %ebp
f0100d13:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d15:	83 fa 01             	cmp    $0x1,%edx
f0100d18:	7e 0e                	jle    f0100d28 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d1a:	8b 10                	mov    (%eax),%edx
f0100d1c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d1f:	89 08                	mov    %ecx,(%eax)
f0100d21:	8b 02                	mov    (%edx),%eax
f0100d23:	8b 52 04             	mov    0x4(%edx),%edx
f0100d26:	eb 22                	jmp    f0100d4a <getuint+0x38>
	else if (lflag)
f0100d28:	85 d2                	test   %edx,%edx
f0100d2a:	74 10                	je     f0100d3c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d2c:	8b 10                	mov    (%eax),%edx
f0100d2e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d31:	89 08                	mov    %ecx,(%eax)
f0100d33:	8b 02                	mov    (%edx),%eax
f0100d35:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d3a:	eb 0e                	jmp    f0100d4a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d3c:	8b 10                	mov    (%eax),%edx
f0100d3e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d41:	89 08                	mov    %ecx,(%eax)
f0100d43:	8b 02                	mov    (%edx),%eax
f0100d45:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d4a:	5d                   	pop    %ebp
f0100d4b:	c3                   	ret    

f0100d4c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d4c:	55                   	push   %ebp
f0100d4d:	89 e5                	mov    %esp,%ebp
f0100d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d52:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100d55:	8b 10                	mov    (%eax),%edx
f0100d57:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d5a:	73 08                	jae    f0100d64 <sprintputch+0x18>
		*b->buf++ = ch;
f0100d5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100d5f:	88 0a                	mov    %cl,(%edx)
f0100d61:	42                   	inc    %edx
f0100d62:	89 10                	mov    %edx,(%eax)
}
f0100d64:	5d                   	pop    %ebp
f0100d65:	c3                   	ret    

f0100d66 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d66:	55                   	push   %ebp
f0100d67:	89 e5                	mov    %esp,%ebp
f0100d69:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d6c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d73:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d76:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d7d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d81:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d84:	89 04 24             	mov    %eax,(%esp)
f0100d87:	e8 02 00 00 00       	call   f0100d8e <vprintfmt>
	va_end(ap);
}
f0100d8c:	c9                   	leave  
f0100d8d:	c3                   	ret    

f0100d8e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d8e:	55                   	push   %ebp
f0100d8f:	89 e5                	mov    %esp,%ebp
f0100d91:	57                   	push   %edi
f0100d92:	56                   	push   %esi
f0100d93:	53                   	push   %ebx
f0100d94:	83 ec 4c             	sub    $0x4c,%esp
f0100d97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d9a:	8b 75 10             	mov    0x10(%ebp),%esi
f0100d9d:	eb 12                	jmp    f0100db1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d9f:	85 c0                	test   %eax,%eax
f0100da1:	0f 84 6b 03 00 00    	je     f0101112 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0100da7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dab:	89 04 24             	mov    %eax,(%esp)
f0100dae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100db1:	0f b6 06             	movzbl (%esi),%eax
f0100db4:	46                   	inc    %esi
f0100db5:	83 f8 25             	cmp    $0x25,%eax
f0100db8:	75 e5                	jne    f0100d9f <vprintfmt+0x11>
f0100dba:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100dbe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100dc5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100dca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100dd6:	eb 26                	jmp    f0100dfe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dd8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100ddb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100ddf:	eb 1d                	jmp    f0100dfe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100de1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100de4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100de8:	eb 14                	jmp    f0100dfe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100df4:	eb 08                	jmp    f0100dfe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100df6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100df9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dfe:	0f b6 06             	movzbl (%esi),%eax
f0100e01:	8d 56 01             	lea    0x1(%esi),%edx
f0100e04:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e07:	8a 16                	mov    (%esi),%dl
f0100e09:	83 ea 23             	sub    $0x23,%edx
f0100e0c:	80 fa 55             	cmp    $0x55,%dl
f0100e0f:	0f 87 e1 02 00 00    	ja     f01010f6 <vprintfmt+0x368>
f0100e15:	0f b6 d2             	movzbl %dl,%edx
f0100e18:	ff 24 95 00 1e 10 f0 	jmp    *-0xfefe200(,%edx,4)
f0100e1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e22:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e27:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100e2a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100e2e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100e31:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100e34:	83 fa 09             	cmp    $0x9,%edx
f0100e37:	77 2a                	ja     f0100e63 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e39:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e3a:	eb eb                	jmp    f0100e27 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e3f:	8d 50 04             	lea    0x4(%eax),%edx
f0100e42:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e45:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e47:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e4a:	eb 17                	jmp    f0100e63 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0100e4c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e50:	78 98                	js     f0100dea <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e52:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e55:	eb a7                	jmp    f0100dfe <vprintfmt+0x70>
f0100e57:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e5a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0100e61:	eb 9b                	jmp    f0100dfe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0100e63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e67:	79 95                	jns    f0100dfe <vprintfmt+0x70>
f0100e69:	eb 8b                	jmp    f0100df6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e6b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100e6f:	eb 8d                	jmp    f0100dfe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e71:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e74:	8d 50 04             	lea    0x4(%eax),%edx
f0100e77:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e7e:	8b 00                	mov    (%eax),%eax
f0100e80:	89 04 24             	mov    %eax,(%esp)
f0100e83:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e86:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100e89:	e9 23 ff ff ff       	jmp    f0100db1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e91:	8d 50 04             	lea    0x4(%eax),%edx
f0100e94:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e97:	8b 00                	mov    (%eax),%eax
f0100e99:	85 c0                	test   %eax,%eax
f0100e9b:	79 02                	jns    f0100e9f <vprintfmt+0x111>
f0100e9d:	f7 d8                	neg    %eax
f0100e9f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ea1:	83 f8 07             	cmp    $0x7,%eax
f0100ea4:	7f 0b                	jg     f0100eb1 <vprintfmt+0x123>
f0100ea6:	8b 04 85 60 1f 10 f0 	mov    -0xfefe0a0(,%eax,4),%eax
f0100ead:	85 c0                	test   %eax,%eax
f0100eaf:	75 23                	jne    f0100ed4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0100eb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100eb5:	c7 44 24 08 81 1d 10 	movl   $0xf0101d81,0x8(%esp)
f0100ebc:	f0 
f0100ebd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ec1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ec4:	89 04 24             	mov    %eax,(%esp)
f0100ec7:	e8 9a fe ff ff       	call   f0100d66 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ecc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100ecf:	e9 dd fe ff ff       	jmp    f0100db1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100ed4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ed8:	c7 44 24 08 8a 1d 10 	movl   $0xf0101d8a,0x8(%esp)
f0100edf:	f0 
f0100ee0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ee4:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ee7:	89 14 24             	mov    %edx,(%esp)
f0100eea:	e8 77 fe ff ff       	call   f0100d66 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eef:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100ef2:	e9 ba fe ff ff       	jmp    f0100db1 <vprintfmt+0x23>
f0100ef7:	89 f9                	mov    %edi,%ecx
f0100ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100efc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100eff:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f02:	8d 50 04             	lea    0x4(%eax),%edx
f0100f05:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f08:	8b 30                	mov    (%eax),%esi
f0100f0a:	85 f6                	test   %esi,%esi
f0100f0c:	75 05                	jne    f0100f13 <vprintfmt+0x185>
				p = "(null)";
f0100f0e:	be 7a 1d 10 f0       	mov    $0xf0101d7a,%esi
			if (width > 0 && padc != '-')
f0100f13:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f17:	0f 8e 84 00 00 00    	jle    f0100fa1 <vprintfmt+0x213>
f0100f1d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100f21:	74 7e                	je     f0100fa1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100f27:	89 34 24             	mov    %esi,(%esp)
f0100f2a:	e8 53 03 00 00       	call   f0101282 <strnlen>
f0100f2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f32:	29 c2                	sub    %eax,%edx
f0100f34:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0100f37:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0100f3b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0100f3e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0100f41:	89 de                	mov    %ebx,%esi
f0100f43:	89 d3                	mov    %edx,%ebx
f0100f45:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f47:	eb 0b                	jmp    f0100f54 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0100f49:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f4d:	89 3c 24             	mov    %edi,(%esp)
f0100f50:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f53:	4b                   	dec    %ebx
f0100f54:	85 db                	test   %ebx,%ebx
f0100f56:	7f f1                	jg     f0100f49 <vprintfmt+0x1bb>
f0100f58:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0100f5b:	89 f3                	mov    %esi,%ebx
f0100f5d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0100f60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f63:	85 c0                	test   %eax,%eax
f0100f65:	79 05                	jns    f0100f6c <vprintfmt+0x1de>
f0100f67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f6c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f6f:	29 c2                	sub    %eax,%edx
f0100f71:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100f74:	eb 2b                	jmp    f0100fa1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f76:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f7a:	74 18                	je     f0100f94 <vprintfmt+0x206>
f0100f7c:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100f7f:	83 fa 5e             	cmp    $0x5e,%edx
f0100f82:	76 10                	jbe    f0100f94 <vprintfmt+0x206>
					putch('?', putdat);
f0100f84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f88:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100f8f:	ff 55 08             	call   *0x8(%ebp)
f0100f92:	eb 0a                	jmp    f0100f9e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0100f94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f98:	89 04 24             	mov    %eax,(%esp)
f0100f9b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f9e:	ff 4d e4             	decl   -0x1c(%ebp)
f0100fa1:	0f be 06             	movsbl (%esi),%eax
f0100fa4:	46                   	inc    %esi
f0100fa5:	85 c0                	test   %eax,%eax
f0100fa7:	74 21                	je     f0100fca <vprintfmt+0x23c>
f0100fa9:	85 ff                	test   %edi,%edi
f0100fab:	78 c9                	js     f0100f76 <vprintfmt+0x1e8>
f0100fad:	4f                   	dec    %edi
f0100fae:	79 c6                	jns    f0100f76 <vprintfmt+0x1e8>
f0100fb0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100fb3:	89 de                	mov    %ebx,%esi
f0100fb5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fb8:	eb 18                	jmp    f0100fd2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100fba:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fbe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100fc5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100fc7:	4b                   	dec    %ebx
f0100fc8:	eb 08                	jmp    f0100fd2 <vprintfmt+0x244>
f0100fca:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100fcd:	89 de                	mov    %ebx,%esi
f0100fcf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fd2:	85 db                	test   %ebx,%ebx
f0100fd4:	7f e4                	jg     f0100fba <vprintfmt+0x22c>
f0100fd6:	89 7d 08             	mov    %edi,0x8(%ebp)
f0100fd9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fdb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100fde:	e9 ce fd ff ff       	jmp    f0100db1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100fe3:	83 f9 01             	cmp    $0x1,%ecx
f0100fe6:	7e 10                	jle    f0100ff8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0100fe8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100feb:	8d 50 08             	lea    0x8(%eax),%edx
f0100fee:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ff1:	8b 30                	mov    (%eax),%esi
f0100ff3:	8b 78 04             	mov    0x4(%eax),%edi
f0100ff6:	eb 26                	jmp    f010101e <vprintfmt+0x290>
	else if (lflag)
f0100ff8:	85 c9                	test   %ecx,%ecx
f0100ffa:	74 12                	je     f010100e <vprintfmt+0x280>
		return va_arg(*ap, long);
f0100ffc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fff:	8d 50 04             	lea    0x4(%eax),%edx
f0101002:	89 55 14             	mov    %edx,0x14(%ebp)
f0101005:	8b 30                	mov    (%eax),%esi
f0101007:	89 f7                	mov    %esi,%edi
f0101009:	c1 ff 1f             	sar    $0x1f,%edi
f010100c:	eb 10                	jmp    f010101e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010100e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101011:	8d 50 04             	lea    0x4(%eax),%edx
f0101014:	89 55 14             	mov    %edx,0x14(%ebp)
f0101017:	8b 30                	mov    (%eax),%esi
f0101019:	89 f7                	mov    %esi,%edi
f010101b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010101e:	85 ff                	test   %edi,%edi
f0101020:	78 0a                	js     f010102c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101022:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101027:	e9 8c 00 00 00       	jmp    f01010b8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010102c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101030:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101037:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010103a:	f7 de                	neg    %esi
f010103c:	83 d7 00             	adc    $0x0,%edi
f010103f:	f7 df                	neg    %edi
			}
			base = 10;
f0101041:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101046:	eb 70                	jmp    f01010b8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101048:	89 ca                	mov    %ecx,%edx
f010104a:	8d 45 14             	lea    0x14(%ebp),%eax
f010104d:	e8 c0 fc ff ff       	call   f0100d12 <getuint>
f0101052:	89 c6                	mov    %eax,%esi
f0101054:	89 d7                	mov    %edx,%edi
			base = 10;
f0101056:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010105b:	eb 5b                	jmp    f01010b8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
f010105d:	89 ca                	mov    %ecx,%edx
f010105f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101062:	e8 ab fc ff ff       	call   f0100d12 <getuint>
f0101067:	89 c6                	mov    %eax,%esi
f0101069:	89 d7                	mov    %edx,%edi
			base = 8;
f010106b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0101070:	eb 46                	jmp    f01010b8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
f0101072:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101076:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010107d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101084:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010108b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010108e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101091:	8d 50 04             	lea    0x4(%eax),%edx
f0101094:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101097:	8b 30                	mov    (%eax),%esi
f0101099:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010109e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01010a3:	eb 13                	jmp    f01010b8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010a5:	89 ca                	mov    %ecx,%edx
f01010a7:	8d 45 14             	lea    0x14(%ebp),%eax
f01010aa:	e8 63 fc ff ff       	call   f0100d12 <getuint>
f01010af:	89 c6                	mov    %eax,%esi
f01010b1:	89 d7                	mov    %edx,%edi
			base = 16;
f01010b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010b8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01010bc:	89 54 24 10          	mov    %edx,0x10(%esp)
f01010c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01010c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010cb:	89 34 24             	mov    %esi,(%esp)
f01010ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010d2:	89 da                	mov    %ebx,%edx
f01010d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01010d7:	e8 6c fb ff ff       	call   f0100c48 <printnum>
			break;
f01010dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01010df:	e9 cd fc ff ff       	jmp    f0100db1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01010e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010e8:	89 04 24             	mov    %eax,(%esp)
f01010eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01010f1:	e9 bb fc ff ff       	jmp    f0100db1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01010f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101101:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101104:	eb 01                	jmp    f0101107 <vprintfmt+0x379>
f0101106:	4e                   	dec    %esi
f0101107:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010110b:	75 f9                	jne    f0101106 <vprintfmt+0x378>
f010110d:	e9 9f fc ff ff       	jmp    f0100db1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0101112:	83 c4 4c             	add    $0x4c,%esp
f0101115:	5b                   	pop    %ebx
f0101116:	5e                   	pop    %esi
f0101117:	5f                   	pop    %edi
f0101118:	5d                   	pop    %ebp
f0101119:	c3                   	ret    

f010111a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010111a:	55                   	push   %ebp
f010111b:	89 e5                	mov    %esp,%ebp
f010111d:	83 ec 28             	sub    $0x28,%esp
f0101120:	8b 45 08             	mov    0x8(%ebp),%eax
f0101123:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101126:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101129:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010112d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101130:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101137:	85 c0                	test   %eax,%eax
f0101139:	74 30                	je     f010116b <vsnprintf+0x51>
f010113b:	85 d2                	test   %edx,%edx
f010113d:	7e 33                	jle    f0101172 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010113f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101142:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101146:	8b 45 10             	mov    0x10(%ebp),%eax
f0101149:	89 44 24 08          	mov    %eax,0x8(%esp)
f010114d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101150:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101154:	c7 04 24 4c 0d 10 f0 	movl   $0xf0100d4c,(%esp)
f010115b:	e8 2e fc ff ff       	call   f0100d8e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101160:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101163:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101166:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101169:	eb 0c                	jmp    f0101177 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101170:	eb 05                	jmp    f0101177 <vsnprintf+0x5d>
f0101172:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101177:	c9                   	leave  
f0101178:	c3                   	ret    

f0101179 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101179:	55                   	push   %ebp
f010117a:	89 e5                	mov    %esp,%ebp
f010117c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010117f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101182:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101186:	8b 45 10             	mov    0x10(%ebp),%eax
f0101189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010118d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101190:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101194:	8b 45 08             	mov    0x8(%ebp),%eax
f0101197:	89 04 24             	mov    %eax,(%esp)
f010119a:	e8 7b ff ff ff       	call   f010111a <vsnprintf>
	va_end(ap);

	return rc;
}
f010119f:	c9                   	leave  
f01011a0:	c3                   	ret    
f01011a1:	00 00                	add    %al,(%eax)
	...

f01011a4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011a4:	55                   	push   %ebp
f01011a5:	89 e5                	mov    %esp,%ebp
f01011a7:	57                   	push   %edi
f01011a8:	56                   	push   %esi
f01011a9:	53                   	push   %ebx
f01011aa:	83 ec 1c             	sub    $0x1c,%esp
f01011ad:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011b0:	85 c0                	test   %eax,%eax
f01011b2:	74 10                	je     f01011c4 <readline+0x20>
		cprintf("%s", prompt);
f01011b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011b8:	c7 04 24 8a 1d 10 f0 	movl   $0xf0101d8a,(%esp)
f01011bf:	e8 66 f7 ff ff       	call   f010092a <cprintf>

	i = 0;
	echoing = iscons(0);
f01011c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01011cb:	e8 3b f4 ff ff       	call   f010060b <iscons>
f01011d0:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011d7:	e8 1e f4 ff ff       	call   f01005fa <getchar>
f01011dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011de:	85 c0                	test   %eax,%eax
f01011e0:	79 17                	jns    f01011f9 <readline+0x55>
			cprintf("read error: %e\n", c);
f01011e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011e6:	c7 04 24 80 1f 10 f0 	movl   $0xf0101f80,(%esp)
f01011ed:	e8 38 f7 ff ff       	call   f010092a <cprintf>
			return NULL;
f01011f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f7:	eb 69                	jmp    f0101262 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01011f9:	83 f8 08             	cmp    $0x8,%eax
f01011fc:	74 05                	je     f0101203 <readline+0x5f>
f01011fe:	83 f8 7f             	cmp    $0x7f,%eax
f0101201:	75 17                	jne    f010121a <readline+0x76>
f0101203:	85 f6                	test   %esi,%esi
f0101205:	7e 13                	jle    f010121a <readline+0x76>
			if (echoing)
f0101207:	85 ff                	test   %edi,%edi
f0101209:	74 0c                	je     f0101217 <readline+0x73>
				cputchar('\b');
f010120b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101212:	e8 d3 f3 ff ff       	call   f01005ea <cputchar>
			i--;
f0101217:	4e                   	dec    %esi
f0101218:	eb bd                	jmp    f01011d7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010121a:	83 fb 1f             	cmp    $0x1f,%ebx
f010121d:	7e 1d                	jle    f010123c <readline+0x98>
f010121f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101225:	7f 15                	jg     f010123c <readline+0x98>
			if (echoing)
f0101227:	85 ff                	test   %edi,%edi
f0101229:	74 08                	je     f0101233 <readline+0x8f>
				cputchar(c);
f010122b:	89 1c 24             	mov    %ebx,(%esp)
f010122e:	e8 b7 f3 ff ff       	call   f01005ea <cputchar>
			buf[i++] = c;
f0101233:	88 9e 40 a5 11 f0    	mov    %bl,-0xfee5ac0(%esi)
f0101239:	46                   	inc    %esi
f010123a:	eb 9b                	jmp    f01011d7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010123c:	83 fb 0a             	cmp    $0xa,%ebx
f010123f:	74 05                	je     f0101246 <readline+0xa2>
f0101241:	83 fb 0d             	cmp    $0xd,%ebx
f0101244:	75 91                	jne    f01011d7 <readline+0x33>
			if (echoing)
f0101246:	85 ff                	test   %edi,%edi
f0101248:	74 0c                	je     f0101256 <readline+0xb2>
				cputchar('\n');
f010124a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101251:	e8 94 f3 ff ff       	call   f01005ea <cputchar>
			buf[i] = 0;
f0101256:	c6 86 40 a5 11 f0 00 	movb   $0x0,-0xfee5ac0(%esi)
			return buf;
f010125d:	b8 40 a5 11 f0       	mov    $0xf011a540,%eax
		}
	}
}
f0101262:	83 c4 1c             	add    $0x1c,%esp
f0101265:	5b                   	pop    %ebx
f0101266:	5e                   	pop    %esi
f0101267:	5f                   	pop    %edi
f0101268:	5d                   	pop    %ebp
f0101269:	c3                   	ret    
	...

f010126c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010126c:	55                   	push   %ebp
f010126d:	89 e5                	mov    %esp,%ebp
f010126f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101272:	b8 00 00 00 00       	mov    $0x0,%eax
f0101277:	eb 01                	jmp    f010127a <strlen+0xe>
		n++;
f0101279:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010127a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010127e:	75 f9                	jne    f0101279 <strlen+0xd>
		n++;
	return n;
}
f0101280:	5d                   	pop    %ebp
f0101281:	c3                   	ret    

f0101282 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101282:	55                   	push   %ebp
f0101283:	89 e5                	mov    %esp,%ebp
f0101285:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0101288:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010128b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101290:	eb 01                	jmp    f0101293 <strnlen+0x11>
		n++;
f0101292:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101293:	39 d0                	cmp    %edx,%eax
f0101295:	74 06                	je     f010129d <strnlen+0x1b>
f0101297:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010129b:	75 f5                	jne    f0101292 <strnlen+0x10>
		n++;
	return n;
}
f010129d:	5d                   	pop    %ebp
f010129e:	c3                   	ret    

f010129f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010129f:	55                   	push   %ebp
f01012a0:	89 e5                	mov    %esp,%ebp
f01012a2:	53                   	push   %ebx
f01012a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01012a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01012ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01012b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012b4:	42                   	inc    %edx
f01012b5:	84 c9                	test   %cl,%cl
f01012b7:	75 f5                	jne    f01012ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01012b9:	5b                   	pop    %ebx
f01012ba:	5d                   	pop    %ebp
f01012bb:	c3                   	ret    

f01012bc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012bc:	55                   	push   %ebp
f01012bd:	89 e5                	mov    %esp,%ebp
f01012bf:	53                   	push   %ebx
f01012c0:	83 ec 08             	sub    $0x8,%esp
f01012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012c6:	89 1c 24             	mov    %ebx,(%esp)
f01012c9:	e8 9e ff ff ff       	call   f010126c <strlen>
	strcpy(dst + len, src);
f01012ce:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012d1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012d5:	01 d8                	add    %ebx,%eax
f01012d7:	89 04 24             	mov    %eax,(%esp)
f01012da:	e8 c0 ff ff ff       	call   f010129f <strcpy>
	return dst;
}
f01012df:	89 d8                	mov    %ebx,%eax
f01012e1:	83 c4 08             	add    $0x8,%esp
f01012e4:	5b                   	pop    %ebx
f01012e5:	5d                   	pop    %ebp
f01012e6:	c3                   	ret    

f01012e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012e7:	55                   	push   %ebp
f01012e8:	89 e5                	mov    %esp,%ebp
f01012ea:	56                   	push   %esi
f01012eb:	53                   	push   %ebx
f01012ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012fa:	eb 0c                	jmp    f0101308 <strncpy+0x21>
		*dst++ = *src;
f01012fc:	8a 1a                	mov    (%edx),%bl
f01012fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101301:	80 3a 01             	cmpb   $0x1,(%edx)
f0101304:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101307:	41                   	inc    %ecx
f0101308:	39 f1                	cmp    %esi,%ecx
f010130a:	75 f0                	jne    f01012fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010130c:	5b                   	pop    %ebx
f010130d:	5e                   	pop    %esi
f010130e:	5d                   	pop    %ebp
f010130f:	c3                   	ret    

f0101310 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101310:	55                   	push   %ebp
f0101311:	89 e5                	mov    %esp,%ebp
f0101313:	56                   	push   %esi
f0101314:	53                   	push   %ebx
f0101315:	8b 75 08             	mov    0x8(%ebp),%esi
f0101318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010131b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010131e:	85 d2                	test   %edx,%edx
f0101320:	75 0a                	jne    f010132c <strlcpy+0x1c>
f0101322:	89 f0                	mov    %esi,%eax
f0101324:	eb 1a                	jmp    f0101340 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101326:	88 18                	mov    %bl,(%eax)
f0101328:	40                   	inc    %eax
f0101329:	41                   	inc    %ecx
f010132a:	eb 02                	jmp    f010132e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010132c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010132e:	4a                   	dec    %edx
f010132f:	74 0a                	je     f010133b <strlcpy+0x2b>
f0101331:	8a 19                	mov    (%ecx),%bl
f0101333:	84 db                	test   %bl,%bl
f0101335:	75 ef                	jne    f0101326 <strlcpy+0x16>
f0101337:	89 c2                	mov    %eax,%edx
f0101339:	eb 02                	jmp    f010133d <strlcpy+0x2d>
f010133b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010133d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101340:	29 f0                	sub    %esi,%eax
}
f0101342:	5b                   	pop    %ebx
f0101343:	5e                   	pop    %esi
f0101344:	5d                   	pop    %ebp
f0101345:	c3                   	ret    

f0101346 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101346:	55                   	push   %ebp
f0101347:	89 e5                	mov    %esp,%ebp
f0101349:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010134c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010134f:	eb 02                	jmp    f0101353 <strcmp+0xd>
		p++, q++;
f0101351:	41                   	inc    %ecx
f0101352:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101353:	8a 01                	mov    (%ecx),%al
f0101355:	84 c0                	test   %al,%al
f0101357:	74 04                	je     f010135d <strcmp+0x17>
f0101359:	3a 02                	cmp    (%edx),%al
f010135b:	74 f4                	je     f0101351 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010135d:	0f b6 c0             	movzbl %al,%eax
f0101360:	0f b6 12             	movzbl (%edx),%edx
f0101363:	29 d0                	sub    %edx,%eax
}
f0101365:	5d                   	pop    %ebp
f0101366:	c3                   	ret    

f0101367 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101367:	55                   	push   %ebp
f0101368:	89 e5                	mov    %esp,%ebp
f010136a:	53                   	push   %ebx
f010136b:	8b 45 08             	mov    0x8(%ebp),%eax
f010136e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101371:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0101374:	eb 03                	jmp    f0101379 <strncmp+0x12>
		n--, p++, q++;
f0101376:	4a                   	dec    %edx
f0101377:	40                   	inc    %eax
f0101378:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101379:	85 d2                	test   %edx,%edx
f010137b:	74 14                	je     f0101391 <strncmp+0x2a>
f010137d:	8a 18                	mov    (%eax),%bl
f010137f:	84 db                	test   %bl,%bl
f0101381:	74 04                	je     f0101387 <strncmp+0x20>
f0101383:	3a 19                	cmp    (%ecx),%bl
f0101385:	74 ef                	je     f0101376 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101387:	0f b6 00             	movzbl (%eax),%eax
f010138a:	0f b6 11             	movzbl (%ecx),%edx
f010138d:	29 d0                	sub    %edx,%eax
f010138f:	eb 05                	jmp    f0101396 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101391:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101396:	5b                   	pop    %ebx
f0101397:	5d                   	pop    %ebp
f0101398:	c3                   	ret    

f0101399 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101399:	55                   	push   %ebp
f010139a:	89 e5                	mov    %esp,%ebp
f010139c:	8b 45 08             	mov    0x8(%ebp),%eax
f010139f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013a2:	eb 05                	jmp    f01013a9 <strchr+0x10>
		if (*s == c)
f01013a4:	38 ca                	cmp    %cl,%dl
f01013a6:	74 0c                	je     f01013b4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013a8:	40                   	inc    %eax
f01013a9:	8a 10                	mov    (%eax),%dl
f01013ab:	84 d2                	test   %dl,%dl
f01013ad:	75 f5                	jne    f01013a4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01013af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013b4:	5d                   	pop    %ebp
f01013b5:	c3                   	ret    

f01013b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013b6:	55                   	push   %ebp
f01013b7:	89 e5                	mov    %esp,%ebp
f01013b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01013bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013bf:	eb 05                	jmp    f01013c6 <strfind+0x10>
		if (*s == c)
f01013c1:	38 ca                	cmp    %cl,%dl
f01013c3:	74 07                	je     f01013cc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01013c5:	40                   	inc    %eax
f01013c6:	8a 10                	mov    (%eax),%dl
f01013c8:	84 d2                	test   %dl,%dl
f01013ca:	75 f5                	jne    f01013c1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01013cc:	5d                   	pop    %ebp
f01013cd:	c3                   	ret    

f01013ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013ce:	55                   	push   %ebp
f01013cf:	89 e5                	mov    %esp,%ebp
f01013d1:	57                   	push   %edi
f01013d2:	56                   	push   %esi
f01013d3:	53                   	push   %ebx
f01013d4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013dd:	85 c9                	test   %ecx,%ecx
f01013df:	74 30                	je     f0101411 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01013e7:	75 25                	jne    f010140e <memset+0x40>
f01013e9:	f6 c1 03             	test   $0x3,%cl
f01013ec:	75 20                	jne    f010140e <memset+0x40>
		c &= 0xFF;
f01013ee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01013f1:	89 d3                	mov    %edx,%ebx
f01013f3:	c1 e3 08             	shl    $0x8,%ebx
f01013f6:	89 d6                	mov    %edx,%esi
f01013f8:	c1 e6 18             	shl    $0x18,%esi
f01013fb:	89 d0                	mov    %edx,%eax
f01013fd:	c1 e0 10             	shl    $0x10,%eax
f0101400:	09 f0                	or     %esi,%eax
f0101402:	09 d0                	or     %edx,%eax
f0101404:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101406:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101409:	fc                   	cld    
f010140a:	f3 ab                	rep stos %eax,%es:(%edi)
f010140c:	eb 03                	jmp    f0101411 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010140e:	fc                   	cld    
f010140f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101411:	89 f8                	mov    %edi,%eax
f0101413:	5b                   	pop    %ebx
f0101414:	5e                   	pop    %esi
f0101415:	5f                   	pop    %edi
f0101416:	5d                   	pop    %ebp
f0101417:	c3                   	ret    

f0101418 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101418:	55                   	push   %ebp
f0101419:	89 e5                	mov    %esp,%ebp
f010141b:	57                   	push   %edi
f010141c:	56                   	push   %esi
f010141d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101420:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101423:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101426:	39 c6                	cmp    %eax,%esi
f0101428:	73 34                	jae    f010145e <memmove+0x46>
f010142a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010142d:	39 d0                	cmp    %edx,%eax
f010142f:	73 2d                	jae    f010145e <memmove+0x46>
		s += n;
		d += n;
f0101431:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101434:	f6 c2 03             	test   $0x3,%dl
f0101437:	75 1b                	jne    f0101454 <memmove+0x3c>
f0101439:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010143f:	75 13                	jne    f0101454 <memmove+0x3c>
f0101441:	f6 c1 03             	test   $0x3,%cl
f0101444:	75 0e                	jne    f0101454 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101446:	83 ef 04             	sub    $0x4,%edi
f0101449:	8d 72 fc             	lea    -0x4(%edx),%esi
f010144c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010144f:	fd                   	std    
f0101450:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101452:	eb 07                	jmp    f010145b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101454:	4f                   	dec    %edi
f0101455:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101458:	fd                   	std    
f0101459:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010145b:	fc                   	cld    
f010145c:	eb 20                	jmp    f010147e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010145e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101464:	75 13                	jne    f0101479 <memmove+0x61>
f0101466:	a8 03                	test   $0x3,%al
f0101468:	75 0f                	jne    f0101479 <memmove+0x61>
f010146a:	f6 c1 03             	test   $0x3,%cl
f010146d:	75 0a                	jne    f0101479 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010146f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101472:	89 c7                	mov    %eax,%edi
f0101474:	fc                   	cld    
f0101475:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101477:	eb 05                	jmp    f010147e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101479:	89 c7                	mov    %eax,%edi
f010147b:	fc                   	cld    
f010147c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010147e:	5e                   	pop    %esi
f010147f:	5f                   	pop    %edi
f0101480:	5d                   	pop    %ebp
f0101481:	c3                   	ret    

f0101482 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101482:	55                   	push   %ebp
f0101483:	89 e5                	mov    %esp,%ebp
f0101485:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101488:	8b 45 10             	mov    0x10(%ebp),%eax
f010148b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010148f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101492:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101496:	8b 45 08             	mov    0x8(%ebp),%eax
f0101499:	89 04 24             	mov    %eax,(%esp)
f010149c:	e8 77 ff ff ff       	call   f0101418 <memmove>
}
f01014a1:	c9                   	leave  
f01014a2:	c3                   	ret    

f01014a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014a3:	55                   	push   %ebp
f01014a4:	89 e5                	mov    %esp,%ebp
f01014a6:	57                   	push   %edi
f01014a7:	56                   	push   %esi
f01014a8:	53                   	push   %ebx
f01014a9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01014b7:	eb 16                	jmp    f01014cf <memcmp+0x2c>
		if (*s1 != *s2)
f01014b9:	8a 04 17             	mov    (%edi,%edx,1),%al
f01014bc:	42                   	inc    %edx
f01014bd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01014c1:	38 c8                	cmp    %cl,%al
f01014c3:	74 0a                	je     f01014cf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01014c5:	0f b6 c0             	movzbl %al,%eax
f01014c8:	0f b6 c9             	movzbl %cl,%ecx
f01014cb:	29 c8                	sub    %ecx,%eax
f01014cd:	eb 09                	jmp    f01014d8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014cf:	39 da                	cmp    %ebx,%edx
f01014d1:	75 e6                	jne    f01014b9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01014d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014d8:	5b                   	pop    %ebx
f01014d9:	5e                   	pop    %esi
f01014da:	5f                   	pop    %edi
f01014db:	5d                   	pop    %ebp
f01014dc:	c3                   	ret    

f01014dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014dd:	55                   	push   %ebp
f01014de:	89 e5                	mov    %esp,%ebp
f01014e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01014e6:	89 c2                	mov    %eax,%edx
f01014e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01014eb:	eb 05                	jmp    f01014f2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014ed:	38 08                	cmp    %cl,(%eax)
f01014ef:	74 05                	je     f01014f6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014f1:	40                   	inc    %eax
f01014f2:	39 d0                	cmp    %edx,%eax
f01014f4:	72 f7                	jb     f01014ed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01014f6:	5d                   	pop    %ebp
f01014f7:	c3                   	ret    

f01014f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01014f8:	55                   	push   %ebp
f01014f9:	89 e5                	mov    %esp,%ebp
f01014fb:	57                   	push   %edi
f01014fc:	56                   	push   %esi
f01014fd:	53                   	push   %ebx
f01014fe:	8b 55 08             	mov    0x8(%ebp),%edx
f0101501:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101504:	eb 01                	jmp    f0101507 <strtol+0xf>
		s++;
f0101506:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101507:	8a 02                	mov    (%edx),%al
f0101509:	3c 20                	cmp    $0x20,%al
f010150b:	74 f9                	je     f0101506 <strtol+0xe>
f010150d:	3c 09                	cmp    $0x9,%al
f010150f:	74 f5                	je     f0101506 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101511:	3c 2b                	cmp    $0x2b,%al
f0101513:	75 08                	jne    f010151d <strtol+0x25>
		s++;
f0101515:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101516:	bf 00 00 00 00       	mov    $0x0,%edi
f010151b:	eb 13                	jmp    f0101530 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010151d:	3c 2d                	cmp    $0x2d,%al
f010151f:	75 0a                	jne    f010152b <strtol+0x33>
		s++, neg = 1;
f0101521:	8d 52 01             	lea    0x1(%edx),%edx
f0101524:	bf 01 00 00 00       	mov    $0x1,%edi
f0101529:	eb 05                	jmp    f0101530 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010152b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101530:	85 db                	test   %ebx,%ebx
f0101532:	74 05                	je     f0101539 <strtol+0x41>
f0101534:	83 fb 10             	cmp    $0x10,%ebx
f0101537:	75 28                	jne    f0101561 <strtol+0x69>
f0101539:	8a 02                	mov    (%edx),%al
f010153b:	3c 30                	cmp    $0x30,%al
f010153d:	75 10                	jne    f010154f <strtol+0x57>
f010153f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101543:	75 0a                	jne    f010154f <strtol+0x57>
		s += 2, base = 16;
f0101545:	83 c2 02             	add    $0x2,%edx
f0101548:	bb 10 00 00 00       	mov    $0x10,%ebx
f010154d:	eb 12                	jmp    f0101561 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010154f:	85 db                	test   %ebx,%ebx
f0101551:	75 0e                	jne    f0101561 <strtol+0x69>
f0101553:	3c 30                	cmp    $0x30,%al
f0101555:	75 05                	jne    f010155c <strtol+0x64>
		s++, base = 8;
f0101557:	42                   	inc    %edx
f0101558:	b3 08                	mov    $0x8,%bl
f010155a:	eb 05                	jmp    f0101561 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010155c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101561:	b8 00 00 00 00       	mov    $0x0,%eax
f0101566:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101568:	8a 0a                	mov    (%edx),%cl
f010156a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010156d:	80 fb 09             	cmp    $0x9,%bl
f0101570:	77 08                	ja     f010157a <strtol+0x82>
			dig = *s - '0';
f0101572:	0f be c9             	movsbl %cl,%ecx
f0101575:	83 e9 30             	sub    $0x30,%ecx
f0101578:	eb 1e                	jmp    f0101598 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010157a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f010157d:	80 fb 19             	cmp    $0x19,%bl
f0101580:	77 08                	ja     f010158a <strtol+0x92>
			dig = *s - 'a' + 10;
f0101582:	0f be c9             	movsbl %cl,%ecx
f0101585:	83 e9 57             	sub    $0x57,%ecx
f0101588:	eb 0e                	jmp    f0101598 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010158a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f010158d:	80 fb 19             	cmp    $0x19,%bl
f0101590:	77 12                	ja     f01015a4 <strtol+0xac>
			dig = *s - 'A' + 10;
f0101592:	0f be c9             	movsbl %cl,%ecx
f0101595:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101598:	39 f1                	cmp    %esi,%ecx
f010159a:	7d 0c                	jge    f01015a8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f010159c:	42                   	inc    %edx
f010159d:	0f af c6             	imul   %esi,%eax
f01015a0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01015a2:	eb c4                	jmp    f0101568 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01015a4:	89 c1                	mov    %eax,%ecx
f01015a6:	eb 02                	jmp    f01015aa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01015a8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01015aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015ae:	74 05                	je     f01015b5 <strtol+0xbd>
		*endptr = (char *) s;
f01015b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015b3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01015b5:	85 ff                	test   %edi,%edi
f01015b7:	74 04                	je     f01015bd <strtol+0xc5>
f01015b9:	89 c8                	mov    %ecx,%eax
f01015bb:	f7 d8                	neg    %eax
}
f01015bd:	5b                   	pop    %ebx
f01015be:	5e                   	pop    %esi
f01015bf:	5f                   	pop    %edi
f01015c0:	5d                   	pop    %ebp
f01015c1:	c3                   	ret    
	...

f01015c4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01015c4:	55                   	push   %ebp
f01015c5:	57                   	push   %edi
f01015c6:	56                   	push   %esi
f01015c7:	83 ec 10             	sub    $0x10,%esp
f01015ca:	8b 74 24 20          	mov    0x20(%esp),%esi
f01015ce:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01015d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01015d6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f01015da:	89 cd                	mov    %ecx,%ebp
f01015dc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f01015e0:	85 c0                	test   %eax,%eax
f01015e2:	75 2c                	jne    f0101610 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f01015e4:	39 f9                	cmp    %edi,%ecx
f01015e6:	77 68                	ja     f0101650 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01015e8:	85 c9                	test   %ecx,%ecx
f01015ea:	75 0b                	jne    f01015f7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01015ec:	b8 01 00 00 00       	mov    $0x1,%eax
f01015f1:	31 d2                	xor    %edx,%edx
f01015f3:	f7 f1                	div    %ecx
f01015f5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01015f7:	31 d2                	xor    %edx,%edx
f01015f9:	89 f8                	mov    %edi,%eax
f01015fb:	f7 f1                	div    %ecx
f01015fd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01015ff:	89 f0                	mov    %esi,%eax
f0101601:	f7 f1                	div    %ecx
f0101603:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101605:	89 f0                	mov    %esi,%eax
f0101607:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101609:	83 c4 10             	add    $0x10,%esp
f010160c:	5e                   	pop    %esi
f010160d:	5f                   	pop    %edi
f010160e:	5d                   	pop    %ebp
f010160f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101610:	39 f8                	cmp    %edi,%eax
f0101612:	77 2c                	ja     f0101640 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0101614:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0101617:	83 f6 1f             	xor    $0x1f,%esi
f010161a:	75 4c                	jne    f0101668 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f010161c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010161e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0101623:	72 0a                	jb     f010162f <__udivdi3+0x6b>
f0101625:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0101629:	0f 87 ad 00 00 00    	ja     f01016dc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010162f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101634:	89 f0                	mov    %esi,%eax
f0101636:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101638:	83 c4 10             	add    $0x10,%esp
f010163b:	5e                   	pop    %esi
f010163c:	5f                   	pop    %edi
f010163d:	5d                   	pop    %ebp
f010163e:	c3                   	ret    
f010163f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101640:	31 ff                	xor    %edi,%edi
f0101642:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0101644:	89 f0                	mov    %esi,%eax
f0101646:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0101648:	83 c4 10             	add    $0x10,%esp
f010164b:	5e                   	pop    %esi
f010164c:	5f                   	pop    %edi
f010164d:	5d                   	pop    %ebp
f010164e:	c3                   	ret    
f010164f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101650:	89 fa                	mov    %edi,%edx
f0101652:	89 f0                	mov    %esi,%eax
f0101654:	f7 f1                	div    %ecx
f0101656:	89 c6                	mov    %eax,%esi
f0101658:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f010165a:	89 f0                	mov    %esi,%eax
f010165c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	5e                   	pop    %esi
f0101662:	5f                   	pop    %edi
f0101663:	5d                   	pop    %ebp
f0101664:	c3                   	ret    
f0101665:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101668:	89 f1                	mov    %esi,%ecx
f010166a:	d3 e0                	shl    %cl,%eax
f010166c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0101670:	b8 20 00 00 00       	mov    $0x20,%eax
f0101675:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0101677:	89 ea                	mov    %ebp,%edx
f0101679:	88 c1                	mov    %al,%cl
f010167b:	d3 ea                	shr    %cl,%edx
f010167d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0101681:	09 ca                	or     %ecx,%edx
f0101683:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0101687:	89 f1                	mov    %esi,%ecx
f0101689:	d3 e5                	shl    %cl,%ebp
f010168b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f010168f:	89 fd                	mov    %edi,%ebp
f0101691:	88 c1                	mov    %al,%cl
f0101693:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0101695:	89 fa                	mov    %edi,%edx
f0101697:	89 f1                	mov    %esi,%ecx
f0101699:	d3 e2                	shl    %cl,%edx
f010169b:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010169f:	88 c1                	mov    %al,%cl
f01016a1:	d3 ef                	shr    %cl,%edi
f01016a3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f01016a5:	89 f8                	mov    %edi,%eax
f01016a7:	89 ea                	mov    %ebp,%edx
f01016a9:	f7 74 24 08          	divl   0x8(%esp)
f01016ad:	89 d1                	mov    %edx,%ecx
f01016af:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f01016b1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01016b5:	39 d1                	cmp    %edx,%ecx
f01016b7:	72 17                	jb     f01016d0 <__udivdi3+0x10c>
f01016b9:	74 09                	je     f01016c4 <__udivdi3+0x100>
f01016bb:	89 fe                	mov    %edi,%esi
f01016bd:	31 ff                	xor    %edi,%edi
f01016bf:	e9 41 ff ff ff       	jmp    f0101605 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f01016c4:	8b 54 24 04          	mov    0x4(%esp),%edx
f01016c8:	89 f1                	mov    %esi,%ecx
f01016ca:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01016cc:	39 c2                	cmp    %eax,%edx
f01016ce:	73 eb                	jae    f01016bb <__udivdi3+0xf7>
		{
		  q0--;
f01016d0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01016d3:	31 ff                	xor    %edi,%edi
f01016d5:	e9 2b ff ff ff       	jmp    f0101605 <__udivdi3+0x41>
f01016da:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01016dc:	31 f6                	xor    %esi,%esi
f01016de:	e9 22 ff ff ff       	jmp    f0101605 <__udivdi3+0x41>
	...

f01016e4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f01016e4:	55                   	push   %ebp
f01016e5:	57                   	push   %edi
f01016e6:	56                   	push   %esi
f01016e7:	83 ec 20             	sub    $0x20,%esp
f01016ea:	8b 44 24 30          	mov    0x30(%esp),%eax
f01016ee:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f01016f2:	89 44 24 14          	mov    %eax,0x14(%esp)
f01016f6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f01016fa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01016fe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0101702:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0101704:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0101706:	85 ed                	test   %ebp,%ebp
f0101708:	75 16                	jne    f0101720 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f010170a:	39 f1                	cmp    %esi,%ecx
f010170c:	0f 86 a6 00 00 00    	jbe    f01017b8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101712:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0101714:	89 d0                	mov    %edx,%eax
f0101716:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0101718:	83 c4 20             	add    $0x20,%esp
f010171b:	5e                   	pop    %esi
f010171c:	5f                   	pop    %edi
f010171d:	5d                   	pop    %ebp
f010171e:	c3                   	ret    
f010171f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0101720:	39 f5                	cmp    %esi,%ebp
f0101722:	0f 87 ac 00 00 00    	ja     f01017d4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0101728:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f010172b:	83 f0 1f             	xor    $0x1f,%eax
f010172e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101732:	0f 84 a8 00 00 00    	je     f01017e0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0101738:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010173c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f010173e:	bf 20 00 00 00       	mov    $0x20,%edi
f0101743:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0101747:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010174b:	89 f9                	mov    %edi,%ecx
f010174d:	d3 e8                	shr    %cl,%eax
f010174f:	09 e8                	or     %ebp,%eax
f0101751:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0101755:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101759:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010175d:	d3 e0                	shl    %cl,%eax
f010175f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101763:	89 f2                	mov    %esi,%edx
f0101765:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0101767:	8b 44 24 14          	mov    0x14(%esp),%eax
f010176b:	d3 e0                	shl    %cl,%eax
f010176d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0101771:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101775:	89 f9                	mov    %edi,%ecx
f0101777:	d3 e8                	shr    %cl,%eax
f0101779:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f010177b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010177d:	89 f2                	mov    %esi,%edx
f010177f:	f7 74 24 18          	divl   0x18(%esp)
f0101783:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0101785:	f7 64 24 0c          	mull   0xc(%esp)
f0101789:	89 c5                	mov    %eax,%ebp
f010178b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010178d:	39 d6                	cmp    %edx,%esi
f010178f:	72 67                	jb     f01017f8 <__umoddi3+0x114>
f0101791:	74 75                	je     f0101808 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0101793:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0101797:	29 e8                	sub    %ebp,%eax
f0101799:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f010179b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010179f:	d3 e8                	shr    %cl,%eax
f01017a1:	89 f2                	mov    %esi,%edx
f01017a3:	89 f9                	mov    %edi,%ecx
f01017a5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f01017a7:	09 d0                	or     %edx,%eax
f01017a9:	89 f2                	mov    %esi,%edx
f01017ab:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01017af:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01017b1:	83 c4 20             	add    $0x20,%esp
f01017b4:	5e                   	pop    %esi
f01017b5:	5f                   	pop    %edi
f01017b6:	5d                   	pop    %ebp
f01017b7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f01017b8:	85 c9                	test   %ecx,%ecx
f01017ba:	75 0b                	jne    f01017c7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01017bc:	b8 01 00 00 00       	mov    $0x1,%eax
f01017c1:	31 d2                	xor    %edx,%edx
f01017c3:	f7 f1                	div    %ecx
f01017c5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f01017c7:	89 f0                	mov    %esi,%eax
f01017c9:	31 d2                	xor    %edx,%edx
f01017cb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01017cd:	89 f8                	mov    %edi,%eax
f01017cf:	e9 3e ff ff ff       	jmp    f0101712 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f01017d4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01017d6:	83 c4 20             	add    $0x20,%esp
f01017d9:	5e                   	pop    %esi
f01017da:	5f                   	pop    %edi
f01017db:	5d                   	pop    %ebp
f01017dc:	c3                   	ret    
f01017dd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f01017e0:	39 f5                	cmp    %esi,%ebp
f01017e2:	72 04                	jb     f01017e8 <__umoddi3+0x104>
f01017e4:	39 f9                	cmp    %edi,%ecx
f01017e6:	77 06                	ja     f01017ee <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f01017e8:	89 f2                	mov    %esi,%edx
f01017ea:	29 cf                	sub    %ecx,%edi
f01017ec:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f01017ee:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f01017f0:	83 c4 20             	add    $0x20,%esp
f01017f3:	5e                   	pop    %esi
f01017f4:	5f                   	pop    %edi
f01017f5:	5d                   	pop    %ebp
f01017f6:	c3                   	ret    
f01017f7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01017f8:	89 d1                	mov    %edx,%ecx
f01017fa:	89 c5                	mov    %eax,%ebp
f01017fc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0101800:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0101804:	eb 8d                	jmp    f0101793 <__umoddi3+0xaf>
f0101806:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0101808:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f010180c:	72 ea                	jb     f01017f8 <__umoddi3+0x114>
f010180e:	89 f1                	mov    %esi,%ecx
f0101810:	eb 81                	jmp    f0101793 <__umoddi3+0xaf>
