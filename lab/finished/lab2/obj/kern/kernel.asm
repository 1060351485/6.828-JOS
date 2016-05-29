
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
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 70 f9 11 f0       	mov    $0xf011f970,%eax
f010004b:	2d 00 f3 11 f0       	sub    $0xf011f300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 f3 11 f0 	movl   $0xf011f300,(%esp)
f0100063:	e8 c6 37 00 00       	call   f010382e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 4a 04 00 00       	call   f01004b7 <cons_init>

	//cprintf("6828 decimal is %o octal!\n", 6828);

	// Lab 2 memory management initialization functions
	mem_init();
f010006d:	e8 c6 10 00 00       	call   f0101138 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100079:	e8 e9 06 00 00       	call   f0100767 <monitor>
f010007e:	eb f2                	jmp    f0100072 <i386_init+0x32>

f0100080 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100080:	55                   	push   %ebp
f0100081:	89 e5                	mov    %esp,%ebp
f0100083:	56                   	push   %esi
f0100084:	53                   	push   %ebx
f0100085:	83 ec 10             	sub    $0x10,%esp
f0100088:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010008b:	83 3d 60 f9 11 f0 00 	cmpl   $0x0,0xf011f960
f0100092:	75 3d                	jne    f01000d1 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100094:	89 35 60 f9 11 f0    	mov    %esi,0xf011f960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009a:	fa                   	cli    
f010009b:	fc                   	cld    

	va_start(ap, fmt);
f010009c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010009f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01000a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000ad:	c7 04 24 80 3c 10 f0 	movl   $0xf0103c80,(%esp)
f01000b4:	e8 d1 2c 00 00       	call   f0102d8a <cprintf>
	vcprintf(fmt, ap);
f01000b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000bd:	89 34 24             	mov    %esi,(%esp)
f01000c0:	e8 92 2c 00 00       	call   f0102d57 <vcprintf>
	cprintf("\n");
f01000c5:	c7 04 24 f1 4b 10 f0 	movl   $0xf0104bf1,(%esp)
f01000cc:	e8 b9 2c 00 00       	call   f0102d8a <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000d8:	e8 8a 06 00 00       	call   f0100767 <monitor>
f01000dd:	eb f2                	jmp    f01000d1 <_panic+0x51>

f01000df <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000df:	55                   	push   %ebp
f01000e0:	89 e5                	mov    %esp,%ebp
f01000e2:	53                   	push   %ebx
f01000e3:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e6:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01000f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000f7:	c7 04 24 98 3c 10 f0 	movl   $0xf0103c98,(%esp)
f01000fe:	e8 87 2c 00 00       	call   f0102d8a <cprintf>
	vcprintf(fmt, ap);
f0100103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100107:	8b 45 10             	mov    0x10(%ebp),%eax
f010010a:	89 04 24             	mov    %eax,(%esp)
f010010d:	e8 45 2c 00 00       	call   f0102d57 <vcprintf>
	cprintf("\n");
f0100112:	c7 04 24 f1 4b 10 f0 	movl   $0xf0104bf1,(%esp)
f0100119:	e8 6c 2c 00 00       	call   f0102d8a <cprintf>
	va_end(ap);
}
f010011e:	83 c4 14             	add    $0x14,%esp
f0100121:	5b                   	pop    %ebx
f0100122:	5d                   	pop    %ebp
f0100123:	c3                   	ret    

f0100124 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100124:	55                   	push   %ebp
f0100125:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100127:	ba 84 00 00 00       	mov    $0x84,%edx
f010012c:	ec                   	in     (%dx),%al
f010012d:	ec                   	in     (%dx),%al
f010012e:	ec                   	in     (%dx),%al
f010012f:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100130:	5d                   	pop    %ebp
f0100131:	c3                   	ret    

f0100132 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100132:	55                   	push   %ebp
f0100133:	89 e5                	mov    %esp,%ebp
f0100135:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010013a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013b:	a8 01                	test   $0x1,%al
f010013d:	74 08                	je     f0100147 <serial_proc_data+0x15>
f010013f:	b2 f8                	mov    $0xf8,%dl
f0100141:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100142:	0f b6 c0             	movzbl %al,%eax
f0100145:	eb 05                	jmp    f010014c <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014c:	5d                   	pop    %ebp
f010014d:	c3                   	ret    

f010014e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010014e:	55                   	push   %ebp
f010014f:	89 e5                	mov    %esp,%ebp
f0100151:	53                   	push   %ebx
f0100152:	83 ec 04             	sub    $0x4,%esp
f0100155:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100157:	eb 29                	jmp    f0100182 <cons_intr+0x34>
		if (c == 0)
f0100159:	85 c0                	test   %eax,%eax
f010015b:	74 25                	je     f0100182 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010015d:	8b 15 24 f5 11 f0    	mov    0xf011f524,%edx
f0100163:	88 82 20 f3 11 f0    	mov    %al,-0xfee0ce0(%edx)
f0100169:	8d 42 01             	lea    0x1(%edx),%eax
f010016c:	a3 24 f5 11 f0       	mov    %eax,0xf011f524
		if (cons.wpos == CONSBUFSIZE)
f0100171:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100176:	75 0a                	jne    f0100182 <cons_intr+0x34>
			cons.wpos = 0;
f0100178:	c7 05 24 f5 11 f0 00 	movl   $0x0,0xf011f524
f010017f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100182:	ff d3                	call   *%ebx
f0100184:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100187:	75 d0                	jne    f0100159 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100189:	83 c4 04             	add    $0x4,%esp
f010018c:	5b                   	pop    %ebx
f010018d:	5d                   	pop    %ebp
f010018e:	c3                   	ret    

f010018f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010018f:	55                   	push   %ebp
f0100190:	89 e5                	mov    %esp,%ebp
f0100192:	57                   	push   %edi
f0100193:	56                   	push   %esi
f0100194:	53                   	push   %ebx
f0100195:	83 ec 2c             	sub    $0x2c,%esp
f0100198:	89 c6                	mov    %eax,%esi
f010019a:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010019f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001a4:	eb 05                	jmp    f01001ab <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001a6:	e8 79 ff ff ff       	call   f0100124 <delay>
f01001ab:	89 fa                	mov    %edi,%edx
f01001ad:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001ae:	a8 20                	test   $0x20,%al
f01001b0:	75 03                	jne    f01001b5 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001b2:	4b                   	dec    %ebx
f01001b3:	75 f1                	jne    f01001a6 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001b5:	89 f2                	mov    %esi,%edx
f01001b7:	89 f0                	mov    %esi,%eax
f01001b9:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001bc:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c1:	ee                   	out    %al,(%dx)
f01001c2:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c7:	bf 79 03 00 00       	mov    $0x379,%edi
f01001cc:	eb 05                	jmp    f01001d3 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01001ce:	e8 51 ff ff ff       	call   f0100124 <delay>
f01001d3:	89 fa                	mov    %edi,%edx
f01001d5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001d6:	84 c0                	test   %al,%al
f01001d8:	78 03                	js     f01001dd <cons_putc+0x4e>
f01001da:	4b                   	dec    %ebx
f01001db:	75 f1                	jne    f01001ce <cons_putc+0x3f>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001dd:	ba 78 03 00 00       	mov    $0x378,%edx
f01001e2:	8a 45 e7             	mov    -0x19(%ebp),%al
f01001e5:	ee                   	out    %al,(%dx)
f01001e6:	b2 7a                	mov    $0x7a,%dl
f01001e8:	b0 0d                	mov    $0xd,%al
f01001ea:	ee                   	out    %al,(%dx)
f01001eb:	b0 08                	mov    $0x8,%al
f01001ed:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01001ee:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01001f4:	75 06                	jne    f01001fc <cons_putc+0x6d>
		c |= 0x0700;
f01001f6:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01001fc:	89 f0                	mov    %esi,%eax
f01001fe:	25 ff 00 00 00       	and    $0xff,%eax
f0100203:	83 f8 09             	cmp    $0x9,%eax
f0100206:	74 78                	je     f0100280 <cons_putc+0xf1>
f0100208:	83 f8 09             	cmp    $0x9,%eax
f010020b:	7f 0b                	jg     f0100218 <cons_putc+0x89>
f010020d:	83 f8 08             	cmp    $0x8,%eax
f0100210:	0f 85 9e 00 00 00    	jne    f01002b4 <cons_putc+0x125>
f0100216:	eb 10                	jmp    f0100228 <cons_putc+0x99>
f0100218:	83 f8 0a             	cmp    $0xa,%eax
f010021b:	74 39                	je     f0100256 <cons_putc+0xc7>
f010021d:	83 f8 0d             	cmp    $0xd,%eax
f0100220:	0f 85 8e 00 00 00    	jne    f01002b4 <cons_putc+0x125>
f0100226:	eb 36                	jmp    f010025e <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f0100228:	66 a1 34 f5 11 f0    	mov    0xf011f534,%ax
f010022e:	66 85 c0             	test   %ax,%ax
f0100231:	0f 84 e2 00 00 00    	je     f0100319 <cons_putc+0x18a>
			crt_pos--;
f0100237:	48                   	dec    %eax
f0100238:	66 a3 34 f5 11 f0    	mov    %ax,0xf011f534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010023e:	0f b7 c0             	movzwl %ax,%eax
f0100241:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f0100247:	83 ce 20             	or     $0x20,%esi
f010024a:	8b 15 30 f5 11 f0    	mov    0xf011f530,%edx
f0100250:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100254:	eb 78                	jmp    f01002ce <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100256:	66 83 05 34 f5 11 f0 	addw   $0x50,0xf011f534
f010025d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010025e:	66 8b 0d 34 f5 11 f0 	mov    0xf011f534,%cx
f0100265:	bb 50 00 00 00       	mov    $0x50,%ebx
f010026a:	89 c8                	mov    %ecx,%eax
f010026c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100271:	66 f7 f3             	div    %bx
f0100274:	66 29 d1             	sub    %dx,%cx
f0100277:	66 89 0d 34 f5 11 f0 	mov    %cx,0xf011f534
f010027e:	eb 4e                	jmp    f01002ce <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100280:	b8 20 00 00 00       	mov    $0x20,%eax
f0100285:	e8 05 ff ff ff       	call   f010018f <cons_putc>
		cons_putc(' ');
f010028a:	b8 20 00 00 00       	mov    $0x20,%eax
f010028f:	e8 fb fe ff ff       	call   f010018f <cons_putc>
		cons_putc(' ');
f0100294:	b8 20 00 00 00       	mov    $0x20,%eax
f0100299:	e8 f1 fe ff ff       	call   f010018f <cons_putc>
		cons_putc(' ');
f010029e:	b8 20 00 00 00       	mov    $0x20,%eax
f01002a3:	e8 e7 fe ff ff       	call   f010018f <cons_putc>
		cons_putc(' ');
f01002a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ad:	e8 dd fe ff ff       	call   f010018f <cons_putc>
f01002b2:	eb 1a                	jmp    f01002ce <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002b4:	66 a1 34 f5 11 f0    	mov    0xf011f534,%ax
f01002ba:	0f b7 c8             	movzwl %ax,%ecx
f01002bd:	8b 15 30 f5 11 f0    	mov    0xf011f530,%edx
f01002c3:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002c7:	40                   	inc    %eax
f01002c8:	66 a3 34 f5 11 f0    	mov    %ax,0xf011f534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01002ce:	66 81 3d 34 f5 11 f0 	cmpw   $0x7cf,0xf011f534
f01002d5:	cf 07 
f01002d7:	76 40                	jbe    f0100319 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002d9:	a1 30 f5 11 f0       	mov    0xf011f530,%eax
f01002de:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01002e5:	00 
f01002e6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01002ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01002f0:	89 04 24             	mov    %eax,(%esp)
f01002f3:	e8 80 35 00 00       	call   f0103878 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01002f8:	8b 15 30 f5 11 f0    	mov    0xf011f530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01002fe:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100303:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100309:	40                   	inc    %eax
f010030a:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010030f:	75 f2                	jne    f0100303 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100311:	66 83 2d 34 f5 11 f0 	subw   $0x50,0xf011f534
f0100318:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100319:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
f010031f:	b0 0e                	mov    $0xe,%al
f0100321:	89 ca                	mov    %ecx,%edx
f0100323:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100324:	66 8b 35 34 f5 11 f0 	mov    0xf011f534,%si
f010032b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010032e:	89 f0                	mov    %esi,%eax
f0100330:	66 c1 e8 08          	shr    $0x8,%ax
f0100334:	89 da                	mov    %ebx,%edx
f0100336:	ee                   	out    %al,(%dx)
f0100337:	b0 0f                	mov    $0xf,%al
f0100339:	89 ca                	mov    %ecx,%edx
f010033b:	ee                   	out    %al,(%dx)
f010033c:	89 f0                	mov    %esi,%eax
f010033e:	89 da                	mov    %ebx,%edx
f0100340:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100341:	83 c4 2c             	add    $0x2c,%esp
f0100344:	5b                   	pop    %ebx
f0100345:	5e                   	pop    %esi
f0100346:	5f                   	pop    %edi
f0100347:	5d                   	pop    %ebp
f0100348:	c3                   	ret    

f0100349 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100349:	55                   	push   %ebp
f010034a:	89 e5                	mov    %esp,%ebp
f010034c:	53                   	push   %ebx
f010034d:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100350:	ba 64 00 00 00       	mov    $0x64,%edx
f0100355:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100356:	a8 01                	test   $0x1,%al
f0100358:	0f 84 d8 00 00 00    	je     f0100436 <kbd_proc_data+0xed>
f010035e:	b2 60                	mov    $0x60,%dl
f0100360:	ec                   	in     (%dx),%al
f0100361:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100363:	3c e0                	cmp    $0xe0,%al
f0100365:	75 11                	jne    f0100378 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100367:	83 0d 28 f5 11 f0 40 	orl    $0x40,0xf011f528
		return 0;
f010036e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100373:	e9 c3 00 00 00       	jmp    f010043b <kbd_proc_data+0xf2>
	} else if (data & 0x80) {
f0100378:	84 c0                	test   %al,%al
f010037a:	79 33                	jns    f01003af <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010037c:	8b 0d 28 f5 11 f0    	mov    0xf011f528,%ecx
f0100382:	f6 c1 40             	test   $0x40,%cl
f0100385:	75 05                	jne    f010038c <kbd_proc_data+0x43>
f0100387:	88 c2                	mov    %al,%dl
f0100389:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010038c:	0f b6 d2             	movzbl %dl,%edx
f010038f:	8a 82 e0 3c 10 f0    	mov    -0xfefc320(%edx),%al
f0100395:	83 c8 40             	or     $0x40,%eax
f0100398:	0f b6 c0             	movzbl %al,%eax
f010039b:	f7 d0                	not    %eax
f010039d:	21 c1                	and    %eax,%ecx
f010039f:	89 0d 28 f5 11 f0    	mov    %ecx,0xf011f528
		return 0;
f01003a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003aa:	e9 8c 00 00 00       	jmp    f010043b <kbd_proc_data+0xf2>
	} else if (shift & E0ESC) {
f01003af:	8b 0d 28 f5 11 f0    	mov    0xf011f528,%ecx
f01003b5:	f6 c1 40             	test   $0x40,%cl
f01003b8:	74 0e                	je     f01003c8 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003ba:	88 c2                	mov    %al,%dl
f01003bc:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003bf:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003c2:	89 0d 28 f5 11 f0    	mov    %ecx,0xf011f528
	}

	shift |= shiftcode[data];
f01003c8:	0f b6 d2             	movzbl %dl,%edx
f01003cb:	0f b6 82 e0 3c 10 f0 	movzbl -0xfefc320(%edx),%eax
f01003d2:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003d8:	0f b6 8a e0 3d 10 f0 	movzbl -0xfefc220(%edx),%ecx
f01003df:	31 c8                	xor    %ecx,%eax
f01003e1:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f01003e6:	89 c1                	mov    %eax,%ecx
f01003e8:	83 e1 03             	and    $0x3,%ecx
f01003eb:	8b 0c 8d e0 3e 10 f0 	mov    -0xfefc120(,%ecx,4),%ecx
f01003f2:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01003f6:	a8 08                	test   $0x8,%al
f01003f8:	74 18                	je     f0100412 <kbd_proc_data+0xc9>
		if ('a' <= c && c <= 'z')
f01003fa:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01003fd:	83 fa 19             	cmp    $0x19,%edx
f0100400:	77 05                	ja     f0100407 <kbd_proc_data+0xbe>
			c += 'A' - 'a';
f0100402:	83 eb 20             	sub    $0x20,%ebx
f0100405:	eb 0b                	jmp    f0100412 <kbd_proc_data+0xc9>
		else if ('A' <= c && c <= 'Z')
f0100407:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010040a:	83 fa 19             	cmp    $0x19,%edx
f010040d:	77 03                	ja     f0100412 <kbd_proc_data+0xc9>
			c += 'a' - 'A';
f010040f:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100412:	f7 d0                	not    %eax
f0100414:	a8 06                	test   $0x6,%al
f0100416:	75 23                	jne    f010043b <kbd_proc_data+0xf2>
f0100418:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010041e:	75 1b                	jne    f010043b <kbd_proc_data+0xf2>
		cprintf("Rebooting!\n");
f0100420:	c7 04 24 b2 3c 10 f0 	movl   $0xf0103cb2,(%esp)
f0100427:	e8 5e 29 00 00       	call   f0102d8a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042c:	ba 92 00 00 00       	mov    $0x92,%edx
f0100431:	b0 03                	mov    $0x3,%al
f0100433:	ee                   	out    %al,(%dx)
f0100434:	eb 05                	jmp    f010043b <kbd_proc_data+0xf2>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100436:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010043b:	89 d8                	mov    %ebx,%eax
f010043d:	83 c4 14             	add    $0x14,%esp
f0100440:	5b                   	pop    %ebx
f0100441:	5d                   	pop    %ebp
f0100442:	c3                   	ret    

f0100443 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100443:	55                   	push   %ebp
f0100444:	89 e5                	mov    %esp,%ebp
f0100446:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100449:	80 3d 00 f3 11 f0 00 	cmpb   $0x0,0xf011f300
f0100450:	74 0a                	je     f010045c <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100452:	b8 32 01 10 f0       	mov    $0xf0100132,%eax
f0100457:	e8 f2 fc ff ff       	call   f010014e <cons_intr>
}
f010045c:	c9                   	leave  
f010045d:	c3                   	ret    

f010045e <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010045e:	55                   	push   %ebp
f010045f:	89 e5                	mov    %esp,%ebp
f0100461:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100464:	b8 49 03 10 f0       	mov    $0xf0100349,%eax
f0100469:	e8 e0 fc ff ff       	call   f010014e <cons_intr>
}
f010046e:	c9                   	leave  
f010046f:	c3                   	ret    

f0100470 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100470:	55                   	push   %ebp
f0100471:	89 e5                	mov    %esp,%ebp
f0100473:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100476:	e8 c8 ff ff ff       	call   f0100443 <serial_intr>
	kbd_intr();
f010047b:	e8 de ff ff ff       	call   f010045e <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100480:	8b 15 20 f5 11 f0    	mov    0xf011f520,%edx
f0100486:	3b 15 24 f5 11 f0    	cmp    0xf011f524,%edx
f010048c:	74 22                	je     f01004b0 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f010048e:	0f b6 82 20 f3 11 f0 	movzbl -0xfee0ce0(%edx),%eax
f0100495:	42                   	inc    %edx
f0100496:	89 15 20 f5 11 f0    	mov    %edx,0xf011f520
		if (cons.rpos == CONSBUFSIZE)
f010049c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004a2:	75 11                	jne    f01004b5 <cons_getc+0x45>
			cons.rpos = 0;
f01004a4:	c7 05 20 f5 11 f0 00 	movl   $0x0,0xf011f520
f01004ab:	00 00 00 
f01004ae:	eb 05                	jmp    f01004b5 <cons_getc+0x45>
		return c;
	}
	return 0;
f01004b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004b5:	c9                   	leave  
f01004b6:	c3                   	ret    

f01004b7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004b7:	55                   	push   %ebp
f01004b8:	89 e5                	mov    %esp,%ebp
f01004ba:	57                   	push   %edi
f01004bb:	56                   	push   %esi
f01004bc:	53                   	push   %ebx
f01004bd:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004c0:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004c7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004ce:	5a a5 
	if (*cp != 0xA55A) {
f01004d0:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01004d6:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004da:	74 11                	je     f01004ed <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004dc:	c7 05 2c f5 11 f0 b4 	movl   $0x3b4,0xf011f52c
f01004e3:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01004e6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004eb:	eb 16                	jmp    f0100503 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01004ed:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004f4:	c7 05 2c f5 11 f0 d4 	movl   $0x3d4,0xf011f52c
f01004fb:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01004fe:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100503:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
f0100509:	b0 0e                	mov    $0xe,%al
f010050b:	89 ca                	mov    %ecx,%edx
f010050d:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010050e:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100511:	89 da                	mov    %ebx,%edx
f0100513:	ec                   	in     (%dx),%al
f0100514:	0f b6 f8             	movzbl %al,%edi
f0100517:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010051a:	b0 0f                	mov    $0xf,%al
f010051c:	89 ca                	mov    %ecx,%edx
f010051e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010051f:	89 da                	mov    %ebx,%edx
f0100521:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100522:	89 35 30 f5 11 f0    	mov    %esi,0xf011f530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100528:	0f b6 d8             	movzbl %al,%ebx
f010052b:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010052d:	66 89 3d 34 f5 11 f0 	mov    %di,0xf011f534
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100534:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100539:	b0 00                	mov    $0x0,%al
f010053b:	89 da                	mov    %ebx,%edx
f010053d:	ee                   	out    %al,(%dx)
f010053e:	b2 fb                	mov    $0xfb,%dl
f0100540:	b0 80                	mov    $0x80,%al
f0100542:	ee                   	out    %al,(%dx)
f0100543:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100548:	b0 0c                	mov    $0xc,%al
f010054a:	89 ca                	mov    %ecx,%edx
f010054c:	ee                   	out    %al,(%dx)
f010054d:	b2 f9                	mov    $0xf9,%dl
f010054f:	b0 00                	mov    $0x0,%al
f0100551:	ee                   	out    %al,(%dx)
f0100552:	b2 fb                	mov    $0xfb,%dl
f0100554:	b0 03                	mov    $0x3,%al
f0100556:	ee                   	out    %al,(%dx)
f0100557:	b2 fc                	mov    $0xfc,%dl
f0100559:	b0 00                	mov    $0x0,%al
f010055b:	ee                   	out    %al,(%dx)
f010055c:	b2 f9                	mov    $0xf9,%dl
f010055e:	b0 01                	mov    $0x1,%al
f0100560:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100561:	b2 fd                	mov    $0xfd,%dl
f0100563:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100564:	3c ff                	cmp    $0xff,%al
f0100566:	0f 95 45 e7          	setne  -0x19(%ebp)
f010056a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010056d:	a2 00 f3 11 f0       	mov    %al,0xf011f300
f0100572:	89 da                	mov    %ebx,%edx
f0100574:	ec                   	in     (%dx),%al
f0100575:	89 ca                	mov    %ecx,%edx
f0100577:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100578:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010057c:	75 0c                	jne    f010058a <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f010057e:	c7 04 24 be 3c 10 f0 	movl   $0xf0103cbe,(%esp)
f0100585:	e8 00 28 00 00       	call   f0102d8a <cprintf>
}
f010058a:	83 c4 2c             	add    $0x2c,%esp
f010058d:	5b                   	pop    %ebx
f010058e:	5e                   	pop    %esi
f010058f:	5f                   	pop    %edi
f0100590:	5d                   	pop    %ebp
f0100591:	c3                   	ret    

f0100592 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100592:	55                   	push   %ebp
f0100593:	89 e5                	mov    %esp,%ebp
f0100595:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100598:	8b 45 08             	mov    0x8(%ebp),%eax
f010059b:	e8 ef fb ff ff       	call   f010018f <cons_putc>
}
f01005a0:	c9                   	leave  
f01005a1:	c3                   	ret    

f01005a2 <getchar>:

int
getchar(void)
{
f01005a2:	55                   	push   %ebp
f01005a3:	89 e5                	mov    %esp,%ebp
f01005a5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005a8:	e8 c3 fe ff ff       	call   f0100470 <cons_getc>
f01005ad:	85 c0                	test   %eax,%eax
f01005af:	74 f7                	je     f01005a8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005b1:	c9                   	leave  
f01005b2:	c3                   	ret    

f01005b3 <iscons>:

int
iscons(int fdnum)
{
f01005b3:	55                   	push   %ebp
f01005b4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01005b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005bb:	5d                   	pop    %ebp
f01005bc:	c3                   	ret    
f01005bd:	00 00                	add    %al,(%eax)
	...

f01005c0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01005c0:	55                   	push   %ebp
f01005c1:	89 e5                	mov    %esp,%ebp
f01005c3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01005c6:	c7 04 24 f0 3e 10 f0 	movl   $0xf0103ef0,(%esp)
f01005cd:	e8 b8 27 00 00       	call   f0102d8a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005d2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01005d9:	00 
f01005da:	c7 04 24 a0 3f 10 f0 	movl   $0xf0103fa0,(%esp)
f01005e1:	e8 a4 27 00 00       	call   f0102d8a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01005e6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01005ed:	00 
f01005ee:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01005f5:	f0 
f01005f6:	c7 04 24 c8 3f 10 f0 	movl   $0xf0103fc8,(%esp)
f01005fd:	e8 88 27 00 00       	call   f0102d8a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100602:	c7 44 24 08 72 3c 10 	movl   $0x103c72,0x8(%esp)
f0100609:	00 
f010060a:	c7 44 24 04 72 3c 10 	movl   $0xf0103c72,0x4(%esp)
f0100611:	f0 
f0100612:	c7 04 24 ec 3f 10 f0 	movl   $0xf0103fec,(%esp)
f0100619:	e8 6c 27 00 00       	call   f0102d8a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010061e:	c7 44 24 08 00 f3 11 	movl   $0x11f300,0x8(%esp)
f0100625:	00 
f0100626:	c7 44 24 04 00 f3 11 	movl   $0xf011f300,0x4(%esp)
f010062d:	f0 
f010062e:	c7 04 24 10 40 10 f0 	movl   $0xf0104010,(%esp)
f0100635:	e8 50 27 00 00       	call   f0102d8a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010063a:	c7 44 24 08 70 f9 11 	movl   $0x11f970,0x8(%esp)
f0100641:	00 
f0100642:	c7 44 24 04 70 f9 11 	movl   $0xf011f970,0x4(%esp)
f0100649:	f0 
f010064a:	c7 04 24 34 40 10 f0 	movl   $0xf0104034,(%esp)
f0100651:	e8 34 27 00 00       	call   f0102d8a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100656:	b8 6f fd 11 f0       	mov    $0xf011fd6f,%eax
f010065b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100660:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100665:	89 c2                	mov    %eax,%edx
f0100667:	85 c0                	test   %eax,%eax
f0100669:	79 06                	jns    f0100671 <mon_kerninfo+0xb1>
f010066b:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100671:	c1 fa 0a             	sar    $0xa,%edx
f0100674:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100678:	c7 04 24 58 40 10 f0 	movl   $0xf0104058,(%esp)
f010067f:	e8 06 27 00 00       	call   f0102d8a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100684:	b8 00 00 00 00       	mov    $0x0,%eax
f0100689:	c9                   	leave  
f010068a:	c3                   	ret    

f010068b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010068b:	55                   	push   %ebp
f010068c:	89 e5                	mov    %esp,%ebp
f010068e:	53                   	push   %ebx
f010068f:	83 ec 14             	sub    $0x14,%esp
f0100692:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100697:	8b 83 44 41 10 f0    	mov    -0xfefbebc(%ebx),%eax
f010069d:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006a1:	8b 83 40 41 10 f0    	mov    -0xfefbec0(%ebx),%eax
f01006a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006ab:	c7 04 24 09 3f 10 f0 	movl   $0xf0103f09,(%esp)
f01006b2:	e8 d3 26 00 00       	call   f0102d8a <cprintf>
f01006b7:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006ba:	83 fb 24             	cmp    $0x24,%ebx
f01006bd:	75 d8                	jne    f0100697 <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c4:	83 c4 14             	add    $0x14,%esp
f01006c7:	5b                   	pop    %ebx
f01006c8:	5d                   	pop    %ebp
f01006c9:	c3                   	ret    

f01006ca <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006ca:	55                   	push   %ebp
f01006cb:	89 e5                	mov    %esp,%ebp
f01006cd:	57                   	push   %edi
f01006ce:	56                   	push   %esi
f01006cf:	53                   	push   %ebx
f01006d0:	83 ec 6c             	sub    $0x6c,%esp
	// Your code here.
	
	int bt_cnt = 0;
	struct Eipdebuginfo eip_info;
	int* pre_ebp = (int *)read_ebp();
f01006d3:	89 eb                	mov    %ebp,%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
f01006d5:	c7 04 24 12 3f 10 f0 	movl   $0xf0103f12,(%esp)
f01006dc:	e8 a9 26 00 00       	call   f0102d8a <cprintf>
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	int bt_cnt = 0;
f01006e1:	bf 00 00 00 00       	mov    $0x0,%edi
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f01006e6:	eb 71                	jmp    f0100759 <mon_backtrace+0x8f>
		bt_cnt++;
f01006e8:	47                   	inc    %edi
		eip = (int)*(pre_ebp+1);
f01006e9:	8b 73 04             	mov    0x4(%ebx),%esi
		debuginfo_eip((uintptr_t)eip, &eip_info);
f01006ec:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01006ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006f3:	89 34 24             	mov    %esi,(%esp)
f01006f6:	e8 89 27 00 00       	call   f0102e84 <debuginfo_eip>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
f01006fb:	89 f0                	mov    %esi,%eax
f01006fd:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100700:	89 44 24 30          	mov    %eax,0x30(%esp)
f0100704:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100707:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f010070b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010070e:	89 44 24 28          	mov    %eax,0x28(%esp)
f0100712:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100715:	89 44 24 24          	mov    %eax,0x24(%esp)
f0100719:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010071c:	89 44 24 20          	mov    %eax,0x20(%esp)
f0100720:	8b 43 18             	mov    0x18(%ebx),%eax
f0100723:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100727:	8b 43 14             	mov    0x14(%ebx),%eax
f010072a:	89 44 24 18          	mov    %eax,0x18(%esp)
f010072e:	8b 43 10             	mov    0x10(%ebx),%eax
f0100731:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100735:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100738:	89 44 24 10          	mov    %eax,0x10(%esp)
f010073c:	8b 43 08             	mov    0x8(%ebx),%eax
f010073f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100743:	89 74 24 08          	mov    %esi,0x8(%esp)
f0100747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010074b:	c7 04 24 84 40 10 f0 	movl   $0xf0104084,(%esp)
f0100752:	e8 33 26 00 00       	call   f0102d8a <cprintf>
		
		pre_ebp = (int *)*pre_ebp;
f0100757:	8b 1b                	mov    (%ebx),%ebx
	int eip;
	char * format_str = "  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n\t %s:%d: %.*s+%d\n";

	cprintf("Stack backtrace:\n");
	
	while(pre_ebp){
f0100759:	85 db                	test   %ebx,%ebx
f010075b:	75 8b                	jne    f01006e8 <mon_backtrace+0x1e>
		cprintf(format_str, pre_ebp, eip, *(pre_ebp+2), *(pre_ebp+3), *(pre_ebp+4), *(pre_ebp+5), *(pre_ebp+6), eip_info.eip_file, eip_info.eip_line, eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip-eip_info.eip_fn_addr );	
		
		pre_ebp = (int *)*pre_ebp;
	}
	return bt_cnt;
}
f010075d:	89 f8                	mov    %edi,%eax
f010075f:	83 c4 6c             	add    $0x6c,%esp
f0100762:	5b                   	pop    %ebx
f0100763:	5e                   	pop    %esi
f0100764:	5f                   	pop    %edi
f0100765:	5d                   	pop    %ebp
f0100766:	c3                   	ret    

f0100767 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100767:	55                   	push   %ebp
f0100768:	89 e5                	mov    %esp,%ebp
f010076a:	57                   	push   %edi
f010076b:	56                   	push   %esi
f010076c:	53                   	push   %ebx
f010076d:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100770:	c7 04 24 cc 40 10 f0 	movl   $0xf01040cc,(%esp)
f0100777:	e8 0e 26 00 00       	call   f0102d8a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010077c:	c7 04 24 f0 40 10 f0 	movl   $0xf01040f0,(%esp)
f0100783:	e8 02 26 00 00       	call   f0102d8a <cprintf>
	
	while (1) {
		buf = readline("K> ");
f0100788:	c7 04 24 24 3f 10 f0 	movl   $0xf0103f24,(%esp)
f010078f:	e8 70 2e 00 00       	call   f0103604 <readline>
f0100794:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100796:	85 c0                	test   %eax,%eax
f0100798:	74 ee                	je     f0100788 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010079a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007a1:	be 00 00 00 00       	mov    $0x0,%esi
f01007a6:	eb 04                	jmp    f01007ac <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007a8:	c6 03 00             	movb   $0x0,(%ebx)
f01007ab:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007ac:	8a 03                	mov    (%ebx),%al
f01007ae:	84 c0                	test   %al,%al
f01007b0:	74 5e                	je     f0100810 <monitor+0xa9>
f01007b2:	0f be c0             	movsbl %al,%eax
f01007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b9:	c7 04 24 28 3f 10 f0 	movl   $0xf0103f28,(%esp)
f01007c0:	e8 34 30 00 00       	call   f01037f9 <strchr>
f01007c5:	85 c0                	test   %eax,%eax
f01007c7:	75 df                	jne    f01007a8 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01007c9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007cc:	74 42                	je     f0100810 <monitor+0xa9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007ce:	83 fe 0f             	cmp    $0xf,%esi
f01007d1:	75 16                	jne    f01007e9 <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007d3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007da:	00 
f01007db:	c7 04 24 2d 3f 10 f0 	movl   $0xf0103f2d,(%esp)
f01007e2:	e8 a3 25 00 00       	call   f0102d8a <cprintf>
f01007e7:	eb 9f                	jmp    f0100788 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01007e9:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007ed:	46                   	inc    %esi
f01007ee:	eb 01                	jmp    f01007f1 <monitor+0x8a>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007f0:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007f1:	8a 03                	mov    (%ebx),%al
f01007f3:	84 c0                	test   %al,%al
f01007f5:	74 b5                	je     f01007ac <monitor+0x45>
f01007f7:	0f be c0             	movsbl %al,%eax
f01007fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007fe:	c7 04 24 28 3f 10 f0 	movl   $0xf0103f28,(%esp)
f0100805:	e8 ef 2f 00 00       	call   f01037f9 <strchr>
f010080a:	85 c0                	test   %eax,%eax
f010080c:	74 e2                	je     f01007f0 <monitor+0x89>
f010080e:	eb 9c                	jmp    f01007ac <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f0100810:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100817:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100818:	85 f6                	test   %esi,%esi
f010081a:	0f 84 68 ff ff ff    	je     f0100788 <monitor+0x21>
f0100820:	bb 40 41 10 f0       	mov    $0xf0104140,%ebx
f0100825:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010082a:	8b 03                	mov    (%ebx),%eax
f010082c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100830:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100833:	89 04 24             	mov    %eax,(%esp)
f0100836:	e8 6b 2f 00 00       	call   f01037a6 <strcmp>
f010083b:	85 c0                	test   %eax,%eax
f010083d:	75 24                	jne    f0100863 <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f010083f:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100842:	8b 55 08             	mov    0x8(%ebp),%edx
f0100845:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100849:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010084c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100850:	89 34 24             	mov    %esi,(%esp)
f0100853:	ff 14 85 48 41 10 f0 	call   *-0xfefbeb8(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010085a:	85 c0                	test   %eax,%eax
f010085c:	78 26                	js     f0100884 <monitor+0x11d>
f010085e:	e9 25 ff ff ff       	jmp    f0100788 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100863:	47                   	inc    %edi
f0100864:	83 c3 0c             	add    $0xc,%ebx
f0100867:	83 ff 03             	cmp    $0x3,%edi
f010086a:	75 be                	jne    f010082a <monitor+0xc3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010086c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010086f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100873:	c7 04 24 4a 3f 10 f0 	movl   $0xf0103f4a,(%esp)
f010087a:	e8 0b 25 00 00       	call   f0102d8a <cprintf>
f010087f:	e9 04 ff ff ff       	jmp    f0100788 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100884:	83 c4 5c             	add    $0x5c,%esp
f0100887:	5b                   	pop    %ebx
f0100888:	5e                   	pop    %esi
f0100889:	5f                   	pop    %edi
f010088a:	5d                   	pop    %ebp
f010088b:	c3                   	ret    

f010088c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

	static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010088c:	55                   	push   %ebp
f010088d:	89 e5                	mov    %esp,%ebp
f010088f:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100892:	89 d1                	mov    %edx,%ecx
f0100894:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100897:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010089a:	a8 01                	test   $0x1,%al
f010089c:	74 4d                	je     f01008eb <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010089e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008a3:	89 c1                	mov    %eax,%ecx
f01008a5:	c1 e9 0c             	shr    $0xc,%ecx
f01008a8:	3b 0d 64 f9 11 f0    	cmp    0xf011f964,%ecx
f01008ae:	72 20                	jb     f01008d0 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008b4:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f01008bb:	f0 
f01008bc:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f01008c3:	00 
f01008c4:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01008cb:	e8 b0 f7 ff ff       	call   f0100080 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f01008d0:	c1 ea 0c             	shr    $0xc,%edx
f01008d3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01008d9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01008e0:	a8 01                	test   $0x1,%al
f01008e2:	74 0e                	je     f01008f2 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01008e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008e9:	eb 0c                	jmp    f01008f7 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01008eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01008f0:	eb 05                	jmp    f01008f7 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f01008f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f01008f7:	c9                   	leave  
f01008f8:	c3                   	ret    

f01008f9 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
	static void *
boot_alloc(uint32_t n)
{
f01008f9:	55                   	push   %ebp
f01008fa:	89 e5                	mov    %esp,%ebp
f01008fc:	53                   	push   %ebx
f01008fd:	83 ec 24             	sub    $0x24,%esp
f0100900:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100902:	83 3d 3c f5 11 f0 00 	cmpl   $0x0,0xf011f53c
f0100909:	75 0f                	jne    f010091a <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010090b:	b8 6f 09 12 f0       	mov    $0xf012096f,%eax
f0100910:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100915:	a3 3c f5 11 f0       	mov    %eax,0xf011f53c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	// first end is at address 0xf011b970, result is 0xf011c100, use 107KB for kernel 
	if (n > 0) {
f010091a:	85 d2                	test   %edx,%edx
f010091c:	74 55                	je     f0100973 <boot_alloc+0x7a>
		result = nextfree;
f010091e:	a1 3c f5 11 f0       	mov    0xf011f53c,%eax
		nextfree = ROUNDUP((char *)(nextfree+n), PGSIZE);
f0100923:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f010092a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100930:	89 15 3c f5 11 f0    	mov    %edx,0xf011f53c
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE ){
f0100936:	8b 0d 64 f9 11 f0    	mov    0xf011f964,%ecx
f010093c:	c1 e1 0c             	shl    $0xc,%ecx
f010093f:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100945:	39 cb                	cmp    %ecx,%ebx
f0100947:	76 2f                	jbe    f0100978 <boot_alloc+0x7f>
			panic("Cannot alloc more physical memory. Requested %dK, Available %dK\n", (uint32_t)nextfree/1024, npages*PGSIZE/1024);
f0100949:	c1 e9 0a             	shr    $0xa,%ecx
f010094c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100950:	c1 ea 0a             	shr    $0xa,%edx
f0100953:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100957:	c7 44 24 08 88 41 10 	movl   $0xf0104188,0x8(%esp)
f010095e:	f0 
f010095f:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100966:	00 
f0100967:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010096e:	e8 0d f7 ff ff       	call   f0100080 <_panic>
		}
		return result;
	}
	return nextfree;
f0100973:	a1 3c f5 11 f0       	mov    0xf011f53c,%eax
}
f0100978:	83 c4 24             	add    $0x24,%esp
f010097b:	5b                   	pop    %ebx
f010097c:	5d                   	pop    %ebp
f010097d:	c3                   	ret    

f010097e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

	static int
nvram_read(int r)
{
f010097e:	55                   	push   %ebp
f010097f:	89 e5                	mov    %esp,%ebp
f0100981:	56                   	push   %esi
f0100982:	53                   	push   %ebx
f0100983:	83 ec 10             	sub    $0x10,%esp
f0100986:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100988:	89 04 24             	mov    %eax,(%esp)
f010098b:	e8 8c 23 00 00       	call   f0102d1c <mc146818_read>
f0100990:	89 c6                	mov    %eax,%esi
f0100992:	43                   	inc    %ebx
f0100993:	89 1c 24             	mov    %ebx,(%esp)
f0100996:	e8 81 23 00 00       	call   f0102d1c <mc146818_read>
f010099b:	c1 e0 08             	shl    $0x8,%eax
f010099e:	09 f0                	or     %esi,%eax
}
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	5b                   	pop    %ebx
f01009a4:	5e                   	pop    %esi
f01009a5:	5d                   	pop    %ebp
f01009a6:	c3                   	ret    

f01009a7 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
	static void
check_page_free_list(bool only_low_memory)
{
f01009a7:	55                   	push   %ebp
f01009a8:	89 e5                	mov    %esp,%ebp
f01009aa:	57                   	push   %edi
f01009ab:	56                   	push   %esi
f01009ac:	53                   	push   %ebx
f01009ad:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009b0:	3c 01                	cmp    $0x1,%al
f01009b2:	19 f6                	sbb    %esi,%esi
f01009b4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01009ba:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01009bb:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f01009c1:	85 d2                	test   %edx,%edx
f01009c3:	75 1c                	jne    f01009e1 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f01009c5:	c7 44 24 08 cc 41 10 	movl   $0xf01041cc,0x8(%esp)
f01009cc:	f0 
f01009cd:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
f01009d4:	00 
f01009d5:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01009dc:	e8 9f f6 ff ff       	call   f0100080 <_panic>

	if (only_low_memory) {
f01009e1:	84 c0                	test   %al,%al
f01009e3:	74 4b                	je     f0100a30 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01009e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01009eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01009ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009f1:	89 d0                	mov    %edx,%eax
f01009f3:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f01009f9:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009fc:	c1 e8 16             	shr    $0x16,%eax
f01009ff:	39 c6                	cmp    %eax,%esi
f0100a01:	0f 96 c0             	setbe  %al
f0100a04:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100a07:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100a0b:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a0d:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a11:	8b 12                	mov    (%edx),%edx
f0100a13:	85 d2                	test   %edx,%edx
f0100a15:	75 da                	jne    f01009f1 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a17:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100a1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a20:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100a26:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a2b:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a30:	8b 1d 40 f5 11 f0    	mov    0xf011f540,%ebx
f0100a36:	eb 63                	jmp    f0100a9b <check_page_free_list+0xf4>
f0100a38:	89 d8                	mov    %ebx,%eax
f0100a3a:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0100a40:	c1 f8 03             	sar    $0x3,%eax
f0100a43:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a46:	89 c2                	mov    %eax,%edx
f0100a48:	c1 ea 16             	shr    $0x16,%edx
f0100a4b:	39 d6                	cmp    %edx,%esi
f0100a4d:	76 4a                	jbe    f0100a99 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a4f:	89 c2                	mov    %eax,%edx
f0100a51:	c1 ea 0c             	shr    $0xc,%edx
f0100a54:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0100a5a:	72 20                	jb     f0100a7c <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a60:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0100a67:	f0 
f0100a68:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100a6f:	00 
f0100a70:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0100a77:	e8 04 f6 ff ff       	call   f0100080 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a7c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100a83:	00 
f0100a84:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100a8b:	00 
	return (void *)(pa + KERNBASE);
f0100a8c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a91:	89 04 24             	mov    %eax,(%esp)
f0100a94:	e8 95 2d 00 00       	call   f010382e <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a99:	8b 1b                	mov    (%ebx),%ebx
f0100a9b:	85 db                	test   %ebx,%ebx
f0100a9d:	75 99                	jne    f0100a38 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a9f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aa4:	e8 50 fe ff ff       	call   f01008f9 <boot_alloc>
f0100aa9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aac:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ab2:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
		assert(pp < pages + npages);
f0100ab8:	a1 64 f9 11 f0       	mov    0xf011f964,%eax
f0100abd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ac0:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ac3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ac6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ac9:	be 00 00 00 00       	mov    $0x0,%esi
f0100ace:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ad1:	e9 91 01 00 00       	jmp    f0100c67 <check_page_free_list+0x2c0>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ad6:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100ad9:	73 24                	jae    f0100aff <check_page_free_list+0x158>
f0100adb:	c7 44 24 0c 16 49 10 	movl   $0xf0104916,0xc(%esp)
f0100ae2:	f0 
f0100ae3:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100aea:	f0 
f0100aeb:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
f0100af2:	00 
f0100af3:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100afa:	e8 81 f5 ff ff       	call   f0100080 <_panic>
		assert(pp < pages + npages);
f0100aff:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b02:	72 24                	jb     f0100b28 <check_page_free_list+0x181>
f0100b04:	c7 44 24 0c 37 49 10 	movl   $0xf0104937,0xc(%esp)
f0100b0b:	f0 
f0100b0c:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100b13:	f0 
f0100b14:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
f0100b1b:	00 
f0100b1c:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100b23:	e8 58 f5 ff ff       	call   f0100080 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b28:	89 d0                	mov    %edx,%eax
f0100b2a:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b2d:	a8 07                	test   $0x7,%al
f0100b2f:	74 24                	je     f0100b55 <check_page_free_list+0x1ae>
f0100b31:	c7 44 24 0c f0 41 10 	movl   $0xf01041f0,0xc(%esp)
f0100b38:	f0 
f0100b39:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100b40:	f0 
f0100b41:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
f0100b48:	00 
f0100b49:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100b50:	e8 2b f5 ff ff       	call   f0100080 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b55:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b58:	c1 e0 0c             	shl    $0xc,%eax
f0100b5b:	75 24                	jne    f0100b81 <check_page_free_list+0x1da>
f0100b5d:	c7 44 24 0c 4b 49 10 	movl   $0xf010494b,0xc(%esp)
f0100b64:	f0 
f0100b65:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100b6c:	f0 
f0100b6d:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
f0100b74:	00 
f0100b75:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100b7c:	e8 ff f4 ff ff       	call   f0100080 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b81:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b86:	75 24                	jne    f0100bac <check_page_free_list+0x205>
f0100b88:	c7 44 24 0c 5c 49 10 	movl   $0xf010495c,0xc(%esp)
f0100b8f:	f0 
f0100b90:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100b97:	f0 
f0100b98:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
f0100b9f:	00 
f0100ba0:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100ba7:	e8 d4 f4 ff ff       	call   f0100080 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bac:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bb1:	75 24                	jne    f0100bd7 <check_page_free_list+0x230>
f0100bb3:	c7 44 24 0c 24 42 10 	movl   $0xf0104224,0xc(%esp)
f0100bba:	f0 
f0100bbb:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100bc2:	f0 
f0100bc3:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
f0100bca:	00 
f0100bcb:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100bd2:	e8 a9 f4 ff ff       	call   f0100080 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bd7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bdc:	75 24                	jne    f0100c02 <check_page_free_list+0x25b>
f0100bde:	c7 44 24 0c 75 49 10 	movl   $0xf0104975,0xc(%esp)
f0100be5:	f0 
f0100be6:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100bed:	f0 
f0100bee:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
f0100bf5:	00 
f0100bf6:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100bfd:	e8 7e f4 ff ff       	call   f0100080 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c02:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c07:	76 58                	jbe    f0100c61 <check_page_free_list+0x2ba>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c09:	89 c1                	mov    %eax,%ecx
f0100c0b:	c1 e9 0c             	shr    $0xc,%ecx
f0100c0e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100c11:	77 20                	ja     f0100c33 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c17:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0100c1e:	f0 
f0100c1f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c26:	00 
f0100c27:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0100c2e:	e8 4d f4 ff ff       	call   f0100080 <_panic>
	return (void *)(pa + KERNBASE);
f0100c33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c38:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100c3b:	76 27                	jbe    f0100c64 <check_page_free_list+0x2bd>
f0100c3d:	c7 44 24 0c 48 42 10 	movl   $0xf0104248,0xc(%esp)
f0100c44:	f0 
f0100c45:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100c4c:	f0 
f0100c4d:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
f0100c54:	00 
f0100c55:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100c5c:	e8 1f f4 ff ff       	call   f0100080 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c61:	46                   	inc    %esi
f0100c62:	eb 01                	jmp    f0100c65 <check_page_free_list+0x2be>
		else
			++nfree_extmem;
f0100c64:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c65:	8b 12                	mov    (%edx),%edx
f0100c67:	85 d2                	test   %edx,%edx
f0100c69:	0f 85 67 fe ff ff    	jne    f0100ad6 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c6f:	85 f6                	test   %esi,%esi
f0100c71:	7f 24                	jg     f0100c97 <check_page_free_list+0x2f0>
f0100c73:	c7 44 24 0c 8f 49 10 	movl   $0xf010498f,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100c92:	e8 e9 f3 ff ff       	call   f0100080 <_panic>
	assert(nfree_extmem > 0);
f0100c97:	85 db                	test   %ebx,%ebx
f0100c99:	7f 24                	jg     f0100cbf <check_page_free_list+0x318>
f0100c9b:	c7 44 24 0c a1 49 10 	movl   $0xf01049a1,0xc(%esp)
f0100ca2:	f0 
f0100ca3:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100caa:	f0 
f0100cab:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
f0100cb2:	00 
f0100cb3:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100cba:	e8 c1 f3 ff ff       	call   f0100080 <_panic>
}
f0100cbf:	83 c4 4c             	add    $0x4c,%esp
f0100cc2:	5b                   	pop    %ebx
f0100cc3:	5e                   	pop    %esi
f0100cc4:	5f                   	pop    %edi
f0100cc5:	5d                   	pop    %ebp
f0100cc6:	c3                   	ret    

f0100cc7 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
	void
page_init(void)
{
f0100cc7:	55                   	push   %ebp
f0100cc8:	89 e5                	mov    %esp,%ebp
f0100cca:	57                   	push   %edi
f0100ccb:	56                   	push   %esi
f0100ccc:	53                   	push   %ebx
f0100ccd:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!

	uint32_t num_alloc = ((uint32_t)boot_alloc(0)-KERNBASE)/PGSIZE;
f0100cd0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cd5:	e8 1f fc ff ff       	call   f01008f9 <boot_alloc>
f0100cda:	05 00 00 00 10       	add    $0x10000000,%eax
f0100cdf:	c1 e8 0c             	shr    $0xc,%eax
	size_t i;

	for(i = 0; i < npages; ++i) {
		if((i == 0)||
				// io hole
				( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100ce2:	8b 35 38 f5 11 f0    	mov    0xf011f538,%esi
f0100ce8:	8d 7e 60             	lea    0x60(%esi),%edi
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cf0:	ba 00 00 00 00       	mov    $0x0,%edx
		if((i == 0)||
				// io hole
				( i >= npages_basemem && i<npages_basemem+num_io_pages )||
				// alloc by kernel, kernel alloc pages and kern_pgdir on stack
				// num_alloc isn't all pages used, it is just memory used by kernel
				( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc  )) {
f0100cf5:	01 f8                	add    %edi,%eax
f0100cf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100cfa:	eb 44                	jmp    f0100d40 <page_init+0x79>
		if((i == 0)||
f0100cfc:	85 d2                	test   %edx,%edx
f0100cfe:	74 13                	je     f0100d13 <page_init+0x4c>
f0100d00:	39 f2                	cmp    %esi,%edx
f0100d02:	72 06                	jb     f0100d0a <page_init+0x43>
				// io hole
				( i >= npages_basemem && i<npages_basemem+num_io_pages )||
f0100d04:	39 fa                	cmp    %edi,%edx
f0100d06:	72 0b                	jb     f0100d13 <page_init+0x4c>
f0100d08:	eb 04                	jmp    f0100d0e <page_init+0x47>
f0100d0a:	39 fa                	cmp    %edi,%edx
f0100d0c:	72 12                	jb     f0100d20 <page_init+0x59>
				// alloc by kernel, kernel alloc pages and kern_pgdir on stack
				// num_alloc isn't all pages used, it is just memory used by kernel
				( i >= npages_basemem+num_io_pages && i < npages_basemem+num_io_pages+num_alloc  )) {
f0100d0e:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100d11:	73 0d                	jae    f0100d20 <page_init+0x59>
			pages[0].pp_ref = 1;	
f0100d13:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0100d18:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0100d1e:	eb 1f                	jmp    f0100d3f <page_init+0x78>
		}else {
			pages[i].pp_ref = 0;
f0100d20:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100d27:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0100d2d:	66 c7 44 01 04 00 00 	movw   $0x0,0x4(%ecx,%eax,1)
			pages[i].pp_link = page_free_list;
f0100d34:	89 1c 01             	mov    %ebx,(%ecx,%eax,1)
			page_free_list = &pages[i];
f0100d37:	89 c3                	mov    %eax,%ebx
f0100d39:	03 1d 6c f9 11 f0    	add    0xf011f96c,%ebx
	uint32_t num_io_pages = (EXTPHYSMEM - IOPHYSMEM)/PGSIZE;
	page_free_list = NULL;

	size_t i;

	for(i = 0; i < npages; ++i) {
f0100d3f:	42                   	inc    %edx
f0100d40:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0100d46:	72 b4                	jb     f0100cfc <page_init+0x35>
f0100d48:	89 1d 40 f5 11 f0    	mov    %ebx,0xf011f540
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}

	}
}
f0100d4e:	83 c4 1c             	add    $0x1c,%esp
f0100d51:	5b                   	pop    %ebx
f0100d52:	5e                   	pop    %esi
f0100d53:	5f                   	pop    %edi
f0100d54:	5d                   	pop    %ebp
f0100d55:	c3                   	ret    

f0100d56 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
	struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d56:	55                   	push   %ebp
f0100d57:	89 e5                	mov    %esp,%ebp
f0100d59:	53                   	push   %ebx
f0100d5a:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo* temp_page;
	if (page_free_list) {
f0100d5d:	8b 1d 40 f5 11 f0    	mov    0xf011f540,%ebx
f0100d63:	85 db                	test   %ebx,%ebx
f0100d65:	0f 84 96 00 00 00    	je     f0100e01 <page_alloc+0xab>
		temp_page = page_free_list;
		assert(temp_page->pp_ref == 0);
f0100d6b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100d70:	74 24                	je     f0100d96 <page_alloc+0x40>
f0100d72:	c7 44 24 0c b2 49 10 	movl   $0xf01049b2,0xc(%esp)
f0100d79:	f0 
f0100d7a:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0100d81:	f0 
f0100d82:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
f0100d89:	00 
f0100d8a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100d91:	e8 ea f2 ff ff       	call   f0100080 <_panic>
		page_free_list = page_free_list->pp_link;
f0100d96:	8b 03                	mov    (%ebx),%eax
f0100d98:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
		temp_page->pp_link = NULL;
f0100d9d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	} else {
		return NULL;
	} 
	// temp_page is a Pageinfo, i think page2kva is actual page
	if (alloc_flags & ALLOC_ZERO) {
f0100da3:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100da7:	74 58                	je     f0100e01 <page_alloc+0xab>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100da9:	89 d8                	mov    %ebx,%eax
f0100dab:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0100db1:	c1 f8 03             	sar    $0x3,%eax
f0100db4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100db7:	89 c2                	mov    %eax,%edx
f0100db9:	c1 ea 0c             	shr    $0xc,%edx
f0100dbc:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0100dc2:	72 20                	jb     f0100de4 <page_alloc+0x8e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dc8:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0100dcf:	f0 
f0100dd0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100dd7:	00 
f0100dd8:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0100ddf:	e8 9c f2 ff ff       	call   f0100080 <_panic>
		memset(page2kva(temp_page), 0, PGSIZE); 
f0100de4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100deb:	00 
f0100dec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100df3:	00 
	return (void *)(pa + KERNBASE);
f0100df4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100df9:	89 04 24             	mov    %eax,(%esp)
f0100dfc:	e8 2d 2a 00 00       	call   f010382e <memset>
	}

	return temp_page;
}
f0100e01:	89 d8                	mov    %ebx,%eax
f0100e03:	83 c4 14             	add    $0x14,%esp
f0100e06:	5b                   	pop    %ebx
f0100e07:	5d                   	pop    %ebp
f0100e08:	c3                   	ret    

f0100e09 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
	void
page_free(struct PageInfo *pp)
{
f0100e09:	55                   	push   %ebp
f0100e0a:	89 e5                	mov    %esp,%ebp
f0100e0c:	83 ec 18             	sub    $0x18,%esp
f0100e0f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0) {
f0100e12:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e17:	74 1c                	je     f0100e35 <page_free+0x2c>
		panic("Still using page");
f0100e19:	c7 44 24 08 c9 49 10 	movl   $0xf01049c9,0x8(%esp)
f0100e20:	f0 
f0100e21:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
f0100e28:	00 
f0100e29:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100e30:	e8 4b f2 ff ff       	call   f0100080 <_panic>
	}
	if (pp->pp_link != NULL) {
f0100e35:	83 38 00             	cmpl   $0x0,(%eax)
f0100e38:	74 1c                	je     f0100e56 <page_free+0x4d>
		panic("free page still have a link");
f0100e3a:	c7 44 24 08 da 49 10 	movl   $0xf01049da,0x8(%esp)
f0100e41:	f0 
f0100e42:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0100e49:	00 
f0100e4a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100e51:	e8 2a f2 ff ff       	call   f0100080 <_panic>
	}
	pp->pp_link = page_free_list;
f0100e56:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f0100e5c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e5e:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
}
f0100e63:	c9                   	leave  
f0100e64:	c3                   	ret    

f0100e65 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
	void
page_decref(struct PageInfo* pp)
{
f0100e65:	55                   	push   %ebp
f0100e66:	89 e5                	mov    %esp,%ebp
f0100e68:	83 ec 18             	sub    $0x18,%esp
f0100e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100e6e:	8b 50 04             	mov    0x4(%eax),%edx
f0100e71:	4a                   	dec    %edx
f0100e72:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100e76:	66 85 d2             	test   %dx,%dx
f0100e79:	75 08                	jne    f0100e83 <page_decref+0x1e>
		page_free(pp);
f0100e7b:	89 04 24             	mov    %eax,(%esp)
f0100e7e:	e8 86 ff ff ff       	call   f0100e09 <page_free>
}
f0100e83:	c9                   	leave  
f0100e84:	c3                   	ret    

f0100e85 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
	pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e85:	55                   	push   %ebp
f0100e86:	89 e5                	mov    %esp,%ebp
f0100e88:	57                   	push   %edi
f0100e89:	56                   	push   %esi
f0100e8a:	53                   	push   %ebx
f0100e8b:	83 ec 1c             	sub    $0x1c,%esp
f0100e8e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pde_t* pgdir_entry = &pgdir[PDX(va)];
f0100e91:	89 fb                	mov    %edi,%ebx
f0100e93:	c1 eb 16             	shr    $0x16,%ebx
f0100e96:	c1 e3 02             	shl    $0x2,%ebx
f0100e99:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pgtb_entry = NULL;
	struct PageInfo * pg = NULL;
	
	if (!(*pgdir_entry & PTE_P)){
f0100e9c:	f6 03 01             	testb  $0x1,(%ebx)
f0100e9f:	0f 85 8b 00 00 00    	jne    f0100f30 <pgdir_walk+0xab>
		if(create){
f0100ea5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ea9:	0f 84 c7 00 00 00    	je     f0100f76 <pgdir_walk+0xf1>
			pg = page_alloc(1);
f0100eaf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100eb6:	e8 9b fe ff ff       	call   f0100d56 <page_alloc>
f0100ebb:	89 c6                	mov    %eax,%esi
			if (!pg) 
f0100ebd:	85 c0                	test   %eax,%eax
f0100ebf:	0f 84 b8 00 00 00    	je     f0100f7d <pgdir_walk+0xf8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ec5:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0100ecb:	c1 f8 03             	sar    $0x3,%eax
f0100ece:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ed1:	89 c2                	mov    %eax,%edx
f0100ed3:	c1 ea 0c             	shr    $0xc,%edx
f0100ed6:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0100edc:	72 20                	jb     f0100efe <pgdir_walk+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ede:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee2:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0100ee9:	f0 
f0100eea:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100ef1:	00 
f0100ef2:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0100ef9:	e8 82 f1 ff ff       	call   f0100080 <_panic>
				return NULL;
			memset(page2kva(pg), 0, PGSIZE);
f0100efe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100f05:	00 
f0100f06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f0d:	00 
	return (void *)(pa + KERNBASE);
f0100f0e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f13:	89 04 24             	mov    %eax,(%esp)
f0100f16:	e8 13 29 00 00       	call   f010382e <memset>
			pg->pp_ref += 1;
f0100f1b:	66 ff 46 04          	incw   0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f1f:	2b 35 6c f9 11 f0    	sub    0xf011f96c,%esi
f0100f25:	c1 fe 03             	sar    $0x3,%esi
f0100f28:	c1 e6 0c             	shl    $0xc,%esi
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
f0100f2b:	83 ce 07             	or     $0x7,%esi
f0100f2e:	89 33                	mov    %esi,(%ebx)
		}else{
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
f0100f30:	8b 03                	mov    (%ebx),%eax
f0100f32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f37:	89 c2                	mov    %eax,%edx
f0100f39:	c1 ea 0c             	shr    $0xc,%edx
f0100f3c:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0100f42:	72 20                	jb     f0100f64 <pgdir_walk+0xdf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f48:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0100f4f:	f0 
f0100f50:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f0100f57:	00 
f0100f58:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0100f5f:	e8 1c f1 ff ff       	call   f0100080 <_panic>
	return &pgtb_entry[PTX(va)];
f0100f64:	c1 ef 0a             	shr    $0xa,%edi
f0100f67:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f0100f6d:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
f0100f74:	eb 0c                	jmp    f0100f82 <pgdir_walk+0xfd>
				return NULL;
			memset(page2kva(pg), 0, PGSIZE);
			pg->pp_ref += 1;
			*pgdir_entry = page2pa(pg)|PTE_P|PTE_U|PTE_W; 
		}else{
			return NULL;
f0100f76:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7b:	eb 05                	jmp    f0100f82 <pgdir_walk+0xfd>
	
	if (!(*pgdir_entry & PTE_P)){
		if(create){
			pg = page_alloc(1);
			if (!pg) 
				return NULL;
f0100f7d:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
		}
	}
	pgtb_entry = KADDR(PTE_ADDR(*pgdir_entry)); 
	return &pgtb_entry[PTX(va)];
}
f0100f82:	83 c4 1c             	add    $0x1c,%esp
f0100f85:	5b                   	pop    %ebx
f0100f86:	5e                   	pop    %esi
f0100f87:	5f                   	pop    %edi
f0100f88:	5d                   	pop    %ebp
f0100f89:	c3                   	ret    

f0100f8a <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f8a:	55                   	push   %ebp
f0100f8b:	89 e5                	mov    %esp,%ebp
f0100f8d:	57                   	push   %edi
f0100f8e:	56                   	push   %esi
f0100f8f:	53                   	push   %ebx
f0100f90:	83 ec 2c             	sub    $0x2c,%esp
f0100f93:	89 c7                	mov    %eax,%edi
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0100f95:	c1 e9 0c             	shr    $0xc,%ecx
f0100f98:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f9b:	89 d3                	mov    %edx,%ebx
f0100f9d:	be 00 00 00 00       	mov    $0x0,%esi
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0100fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa5:	83 c8 01             	or     $0x1,%eax
f0100fa8:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0100fab:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fae:	29 d0                	sub    %edx,%eax
f0100fb0:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0100fb3:	eb 25                	jmp    f0100fda <boot_map_region+0x50>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
f0100fb5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100fbc:	00 
f0100fbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fc1:	89 3c 24             	mov    %edi,(%esp)
f0100fc4:	e8 bc fe ff ff       	call   f0100e85 <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0100fc9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fcc:	01 da                	add    %ebx,%edx
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
f0100fce:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100fd1:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t* tb_entry = NULL;
	int i = 0;
	for (i = 0; i < size/PGSIZE ; i++){
f0100fd3:	46                   	inc    %esi
f0100fd4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100fda:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100fdd:	75 d6                	jne    f0100fb5 <boot_map_region+0x2b>
		tb_entry = pgdir_walk(pgdir, (void*)(va+i*PGSIZE), 1);	
		*tb_entry = (pa+i*PGSIZE)|perm|PTE_P;
	} 
}
f0100fdf:	83 c4 2c             	add    $0x2c,%esp
f0100fe2:	5b                   	pop    %ebx
f0100fe3:	5e                   	pop    %esi
f0100fe4:	5f                   	pop    %edi
f0100fe5:	5d                   	pop    %ebp
f0100fe6:	c3                   	ret    

f0100fe7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
	struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fe7:	55                   	push   %ebp
f0100fe8:	89 e5                	mov    %esp,%ebp
f0100fea:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
f0100fed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ff4:	00 
f0100ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ffc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fff:	89 04 24             	mov    %eax,(%esp)
f0101002:	e8 7e fe ff ff       	call   f0100e85 <pgdir_walk>
	if (pt_entry && *pt_entry&PTE_P) {
f0101007:	85 c0                	test   %eax,%eax
f0101009:	74 3e                	je     f0101049 <page_lookup+0x62>
f010100b:	f6 00 01             	testb  $0x1,(%eax)
f010100e:	74 40                	je     f0101050 <page_lookup+0x69>
		*pte_store = pt_entry;
f0101010:	8b 55 10             	mov    0x10(%ebp),%edx
f0101013:	89 02                	mov    %eax,(%edx)
	}else{
		return NULL;
	}
	return pa2page(PTE_ADDR(*pt_entry));
f0101015:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101017:	c1 e8 0c             	shr    $0xc,%eax
f010101a:	3b 05 64 f9 11 f0    	cmp    0xf011f964,%eax
f0101020:	72 1c                	jb     f010103e <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f0101022:	c7 44 24 08 90 42 10 	movl   $0xf0104290,0x8(%esp)
f0101029:	f0 
f010102a:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101031:	00 
f0101032:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0101039:	e8 42 f0 ff ff       	call   f0100080 <_panic>
	return &pages[PGNUM(pa)];
f010103e:	c1 e0 03             	shl    $0x3,%eax
f0101041:	03 05 6c f9 11 f0    	add    0xf011f96c,%eax
f0101047:	eb 0c                	jmp    f0101055 <page_lookup+0x6e>
	// Fill this function in
	pte_t *pt_entry = pgdir_walk(pgdir, va, 0);
	if (pt_entry && *pt_entry&PTE_P) {
		*pte_store = pt_entry;
	}else{
		return NULL;
f0101049:	b8 00 00 00 00       	mov    $0x0,%eax
f010104e:	eb 05                	jmp    f0101055 <page_lookup+0x6e>
f0101050:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	return pa2page(PTE_ADDR(*pt_entry));
}
f0101055:	c9                   	leave  
f0101056:	c3                   	ret    

f0101057 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
	void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101057:	55                   	push   %ebp
f0101058:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010105a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010105d:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101060:	5d                   	pop    %ebp
f0101061:	c3                   	ret    

f0101062 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
	void
page_remove(pde_t *pgdir, void *va)
{
f0101062:	55                   	push   %ebp
f0101063:	89 e5                	mov    %esp,%ebp
f0101065:	56                   	push   %esi
f0101066:	53                   	push   %ebx
f0101067:	83 ec 20             	sub    $0x20,%esp
f010106a:	8b 75 08             	mov    0x8(%ebp),%esi
f010106d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte_store = NULL;
f0101070:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pg = page_lookup(pgdir, va, &pte_store); 
f0101077:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010107a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010107e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101082:	89 34 24             	mov    %esi,(%esp)
f0101085:	e8 5d ff ff ff       	call   f0100fe7 <page_lookup>
	if (!pg) 
f010108a:	85 c0                	test   %eax,%eax
f010108c:	74 1d                	je     f01010ab <page_remove+0x49>
		return;
	page_decref(pg);	
f010108e:	89 04 24             	mov    %eax,(%esp)
f0101091:	e8 cf fd ff ff       	call   f0100e65 <page_decref>
	tlb_invalidate(pgdir, va);
f0101096:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010109a:	89 34 24             	mov    %esi,(%esp)
f010109d:	e8 b5 ff ff ff       	call   f0101057 <tlb_invalidate>
	*pte_store = 0;
f01010a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f01010ab:	83 c4 20             	add    $0x20,%esp
f01010ae:	5b                   	pop    %ebx
f01010af:	5e                   	pop    %esi
f01010b0:	5d                   	pop    %ebp
f01010b1:	c3                   	ret    

f01010b2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
	int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010b2:	55                   	push   %ebp
f01010b3:	89 e5                	mov    %esp,%ebp
f01010b5:	57                   	push   %edi
f01010b6:	56                   	push   %esi
f01010b7:	53                   	push   %ebx
f01010b8:	83 ec 1c             	sub    $0x1c,%esp
f01010bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01010be:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
f01010c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010c8:	00 
f01010c9:	8b 45 10             	mov    0x10(%ebp),%eax
f01010cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010d0:	89 34 24             	mov    %esi,(%esp)
f01010d3:	e8 ad fd ff ff       	call   f0100e85 <pgdir_walk>
f01010d8:	89 c3                	mov    %eax,%ebx
	if (!pg_entry) {
f01010da:	85 c0                	test   %eax,%eax
f01010dc:	74 4d                	je     f010112b <page_insert+0x79>
		return -E_NO_MEM;
	} 
	pp->pp_ref++;
f01010de:	66 ff 47 04          	incw   0x4(%edi)
	if (*pg_entry & PTE_P){
f01010e2:	f6 00 01             	testb  $0x1,(%eax)
f01010e5:	74 1e                	je     f0101105 <page_insert+0x53>
		tlb_invalidate(pgdir, va);
f01010e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01010ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010ee:	89 34 24             	mov    %esi,(%esp)
f01010f1:	e8 61 ff ff ff       	call   f0101057 <tlb_invalidate>
		page_remove(pgdir, va);
f01010f6:	8b 45 10             	mov    0x10(%ebp),%eax
f01010f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010fd:	89 34 24             	mov    %esi,(%esp)
f0101100:	e8 5d ff ff ff       	call   f0101062 <page_remove>
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
f0101105:	8b 55 14             	mov    0x14(%ebp),%edx
f0101108:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010110b:	2b 3d 6c f9 11 f0    	sub    0xf011f96c,%edi
f0101111:	c1 ff 03             	sar    $0x3,%edi
f0101114:	c1 e7 0c             	shl    $0xc,%edi
f0101117:	09 d7                	or     %edx,%edi
f0101119:	89 3b                	mov    %edi,(%ebx)
	pgdir[PDX(va)] |= perm | PTE_P;	
f010111b:	8b 45 10             	mov    0x10(%ebp),%eax
f010111e:	c1 e8 16             	shr    $0x16,%eax
f0101121:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101124:	b8 00 00 00 00       	mov    $0x0,%eax
f0101129:	eb 05                	jmp    f0101130 <page_insert+0x7e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t* pg_entry = pgdir_walk(pgdir, va, 1);
	if (!pg_entry) {
		return -E_NO_MEM;
f010112b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}
	*pg_entry = page2pa(pp) | perm | PTE_P;
	pgdir[PDX(va)] |= perm | PTE_P;	
	return 0;
}
f0101130:	83 c4 1c             	add    $0x1c,%esp
f0101133:	5b                   	pop    %ebx
f0101134:	5e                   	pop    %esi
f0101135:	5f                   	pop    %edi
f0101136:	5d                   	pop    %ebp
f0101137:	c3                   	ret    

f0101138 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
{
f0101138:	55                   	push   %ebp
f0101139:	89 e5                	mov    %esp,%ebp
f010113b:	57                   	push   %edi
f010113c:	56                   	push   %esi
f010113d:	53                   	push   %ebx
f010113e:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101141:	b8 15 00 00 00       	mov    $0x15,%eax
f0101146:	e8 33 f8 ff ff       	call   f010097e <nvram_read>
f010114b:	c1 e0 0a             	shl    $0xa,%eax
f010114e:	89 c2                	mov    %eax,%edx
f0101150:	85 c0                	test   %eax,%eax
f0101152:	79 06                	jns    f010115a <mem_init+0x22>
f0101154:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010115a:	c1 fa 0c             	sar    $0xc,%edx
f010115d:	89 15 38 f5 11 f0    	mov    %edx,0xf011f538
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101163:	b8 17 00 00 00       	mov    $0x17,%eax
f0101168:	e8 11 f8 ff ff       	call   f010097e <nvram_read>
f010116d:	89 c2                	mov    %eax,%edx
f010116f:	c1 e2 0a             	shl    $0xa,%edx
f0101172:	89 d0                	mov    %edx,%eax
f0101174:	85 d2                	test   %edx,%edx
f0101176:	79 06                	jns    f010117e <mem_init+0x46>
f0101178:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010117e:	c1 f8 0c             	sar    $0xc,%eax
f0101181:	74 0e                	je     f0101191 <mem_init+0x59>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101183:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101189:	89 15 64 f9 11 f0    	mov    %edx,0xf011f964
f010118f:	eb 0c                	jmp    f010119d <mem_init+0x65>
	else
		npages = npages_basemem;
f0101191:	8b 15 38 f5 11 f0    	mov    0xf011f538,%edx
f0101197:	89 15 64 f9 11 f0    	mov    %edx,0xf011f964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
			npages * PGSIZE / 1024,
			npages_basemem * PGSIZE / 1024,
			npages_extmem * PGSIZE / 1024);
f010119d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011a0:	c1 e8 0a             	shr    $0xa,%eax
f01011a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
			npages * PGSIZE / 1024,
			npages_basemem * PGSIZE / 1024,
f01011a7:	a1 38 f5 11 f0       	mov    0xf011f538,%eax
f01011ac:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011af:	c1 e8 0a             	shr    $0xa,%eax
f01011b2:	89 44 24 08          	mov    %eax,0x8(%esp)
			npages * PGSIZE / 1024,
f01011b6:	a1 64 f9 11 f0       	mov    0xf011f964,%eax
f01011bb:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011be:	c1 e8 0a             	shr    $0xa,%eax
f01011c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011c5:	c7 04 24 b0 42 10 f0 	movl   $0xf01042b0,(%esp)
f01011cc:	e8 b9 1b 00 00       	call   f0102d8a <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011d1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011d6:	e8 1e f7 ff ff       	call   f01008f9 <boot_alloc>
f01011db:	a3 68 f9 11 f0       	mov    %eax,0xf011f968
	memset(kern_pgdir, 0, PGSIZE);
f01011e0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011e7:	00 
f01011e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011ef:	00 
f01011f0:	89 04 24             	mov    %eax,(%esp)
f01011f3:	e8 36 26 00 00       	call   f010382e <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011f8:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101202:	77 20                	ja     f0101224 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101204:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101208:	c7 44 24 08 ec 42 10 	movl   $0xf01042ec,0x8(%esp)
f010120f:	f0 
f0101210:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f0101217:	00 
f0101218:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010121f:	e8 5c ee ff ff       	call   f0100080 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101224:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010122a:	83 ca 05             	or     $0x5,%edx
f010122d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f0101233:	a1 64 f9 11 f0       	mov    0xf011f964,%eax
f0101238:	c1 e0 03             	shl    $0x3,%eax
f010123b:	e8 b9 f6 ff ff       	call   f01008f9 <boot_alloc>
f0101240:	a3 6c f9 11 f0       	mov    %eax,0xf011f96c
	memset(pages, 0, sizeof(struct PageInfo)*npages); 
f0101245:	8b 15 64 f9 11 f0    	mov    0xf011f964,%edx
f010124b:	c1 e2 03             	shl    $0x3,%edx
f010124e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101252:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101259:	00 
f010125a:	89 04 24             	mov    %eax,(%esp)
f010125d:	e8 cc 25 00 00       	call   f010382e <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101262:	e8 60 fa ff ff       	call   f0100cc7 <page_init>

	check_page_free_list(1);
f0101267:	b8 01 00 00 00       	mov    $0x1,%eax
f010126c:	e8 36 f7 ff ff       	call   f01009a7 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101271:	83 3d 6c f9 11 f0 00 	cmpl   $0x0,0xf011f96c
f0101278:	75 1c                	jne    f0101296 <mem_init+0x15e>
		panic("'pages' is a null pointer!");
f010127a:	c7 44 24 08 f6 49 10 	movl   $0xf01049f6,0x8(%esp)
f0101281:	f0 
f0101282:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f0101289:	00 
f010128a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101291:	e8 ea ed ff ff       	call   f0100080 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101296:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f010129b:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012a0:	eb 03                	jmp    f01012a5 <mem_init+0x16d>
		++nfree;
f01012a2:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012a3:	8b 00                	mov    (%eax),%eax
f01012a5:	85 c0                	test   %eax,%eax
f01012a7:	75 f9                	jne    f01012a2 <mem_init+0x16a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012b0:	e8 a1 fa ff ff       	call   f0100d56 <page_alloc>
f01012b5:	89 c6                	mov    %eax,%esi
f01012b7:	85 c0                	test   %eax,%eax
f01012b9:	75 24                	jne    f01012df <mem_init+0x1a7>
f01012bb:	c7 44 24 0c 11 4a 10 	movl   $0xf0104a11,0xc(%esp)
f01012c2:	f0 
f01012c3:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01012ca:	f0 
f01012cb:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
f01012d2:	00 
f01012d3:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01012da:	e8 a1 ed ff ff       	call   f0100080 <_panic>
	assert((pp1 = page_alloc(0)));
f01012df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012e6:	e8 6b fa ff ff       	call   f0100d56 <page_alloc>
f01012eb:	89 c7                	mov    %eax,%edi
f01012ed:	85 c0                	test   %eax,%eax
f01012ef:	75 24                	jne    f0101315 <mem_init+0x1dd>
f01012f1:	c7 44 24 0c 27 4a 10 	movl   $0xf0104a27,0xc(%esp)
f01012f8:	f0 
f01012f9:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101300:	f0 
f0101301:	c7 44 24 04 6a 02 00 	movl   $0x26a,0x4(%esp)
f0101308:	00 
f0101309:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101310:	e8 6b ed ff ff       	call   f0100080 <_panic>
	assert((pp2 = page_alloc(0)));
f0101315:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010131c:	e8 35 fa ff ff       	call   f0100d56 <page_alloc>
f0101321:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101324:	85 c0                	test   %eax,%eax
f0101326:	75 24                	jne    f010134c <mem_init+0x214>
f0101328:	c7 44 24 0c 3d 4a 10 	movl   $0xf0104a3d,0xc(%esp)
f010132f:	f0 
f0101330:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101337:	f0 
f0101338:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f010133f:	00 
f0101340:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101347:	e8 34 ed ff ff       	call   f0100080 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010134c:	39 fe                	cmp    %edi,%esi
f010134e:	75 24                	jne    f0101374 <mem_init+0x23c>
f0101350:	c7 44 24 0c 53 4a 10 	movl   $0xf0104a53,0xc(%esp)
f0101357:	f0 
f0101358:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010135f:	f0 
f0101360:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f0101367:	00 
f0101368:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010136f:	e8 0c ed ff ff       	call   f0100080 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101374:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101377:	74 05                	je     f010137e <mem_init+0x246>
f0101379:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010137c:	75 24                	jne    f01013a2 <mem_init+0x26a>
f010137e:	c7 44 24 0c 10 43 10 	movl   $0xf0104310,0xc(%esp)
f0101385:	f0 
f0101386:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010138d:	f0 
f010138e:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f0101395:	00 
f0101396:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010139d:	e8 de ec ff ff       	call   f0100080 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013a2:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013a8:	a1 64 f9 11 f0       	mov    0xf011f964,%eax
f01013ad:	c1 e0 0c             	shl    $0xc,%eax
f01013b0:	89 f1                	mov    %esi,%ecx
f01013b2:	29 d1                	sub    %edx,%ecx
f01013b4:	c1 f9 03             	sar    $0x3,%ecx
f01013b7:	c1 e1 0c             	shl    $0xc,%ecx
f01013ba:	39 c1                	cmp    %eax,%ecx
f01013bc:	72 24                	jb     f01013e2 <mem_init+0x2aa>
f01013be:	c7 44 24 0c 65 4a 10 	movl   $0xf0104a65,0xc(%esp)
f01013c5:	f0 
f01013c6:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01013cd:	f0 
f01013ce:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f01013d5:	00 
f01013d6:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01013dd:	e8 9e ec ff ff       	call   f0100080 <_panic>
f01013e2:	89 f9                	mov    %edi,%ecx
f01013e4:	29 d1                	sub    %edx,%ecx
f01013e6:	c1 f9 03             	sar    $0x3,%ecx
f01013e9:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01013ec:	39 c8                	cmp    %ecx,%eax
f01013ee:	77 24                	ja     f0101414 <mem_init+0x2dc>
f01013f0:	c7 44 24 0c 82 4a 10 	movl   $0xf0104a82,0xc(%esp)
f01013f7:	f0 
f01013f8:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01013ff:	f0 
f0101400:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0101407:	00 
f0101408:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010140f:	e8 6c ec ff ff       	call   f0100080 <_panic>
f0101414:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101417:	29 d1                	sub    %edx,%ecx
f0101419:	89 ca                	mov    %ecx,%edx
f010141b:	c1 fa 03             	sar    $0x3,%edx
f010141e:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101421:	39 d0                	cmp    %edx,%eax
f0101423:	77 24                	ja     f0101449 <mem_init+0x311>
f0101425:	c7 44 24 0c 9f 4a 10 	movl   $0xf0104a9f,0xc(%esp)
f010142c:	f0 
f010142d:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101434:	f0 
f0101435:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f010143c:	00 
f010143d:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101444:	e8 37 ec ff ff       	call   f0100080 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101449:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f010144e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101451:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f0101458:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010145b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101462:	e8 ef f8 ff ff       	call   f0100d56 <page_alloc>
f0101467:	85 c0                	test   %eax,%eax
f0101469:	74 24                	je     f010148f <mem_init+0x357>
f010146b:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f0101472:	f0 
f0101473:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010147a:	f0 
f010147b:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
f0101482:	00 
f0101483:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010148a:	e8 f1 eb ff ff       	call   f0100080 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010148f:	89 34 24             	mov    %esi,(%esp)
f0101492:	e8 72 f9 ff ff       	call   f0100e09 <page_free>
	page_free(pp1);
f0101497:	89 3c 24             	mov    %edi,(%esp)
f010149a:	e8 6a f9 ff ff       	call   f0100e09 <page_free>
	page_free(pp2);
f010149f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a2:	89 04 24             	mov    %eax,(%esp)
f01014a5:	e8 5f f9 ff ff       	call   f0100e09 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014b1:	e8 a0 f8 ff ff       	call   f0100d56 <page_alloc>
f01014b6:	89 c6                	mov    %eax,%esi
f01014b8:	85 c0                	test   %eax,%eax
f01014ba:	75 24                	jne    f01014e0 <mem_init+0x3a8>
f01014bc:	c7 44 24 0c 11 4a 10 	movl   $0xf0104a11,0xc(%esp)
f01014c3:	f0 
f01014c4:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01014cb:	f0 
f01014cc:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f01014d3:	00 
f01014d4:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01014db:	e8 a0 eb ff ff       	call   f0100080 <_panic>
	assert((pp1 = page_alloc(0)));
f01014e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014e7:	e8 6a f8 ff ff       	call   f0100d56 <page_alloc>
f01014ec:	89 c7                	mov    %eax,%edi
f01014ee:	85 c0                	test   %eax,%eax
f01014f0:	75 24                	jne    f0101516 <mem_init+0x3de>
f01014f2:	c7 44 24 0c 27 4a 10 	movl   $0xf0104a27,0xc(%esp)
f01014f9:	f0 
f01014fa:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101501:	f0 
f0101502:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
f0101509:	00 
f010150a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101511:	e8 6a eb ff ff       	call   f0100080 <_panic>
	assert((pp2 = page_alloc(0)));
f0101516:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010151d:	e8 34 f8 ff ff       	call   f0100d56 <page_alloc>
f0101522:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101525:	85 c0                	test   %eax,%eax
f0101527:	75 24                	jne    f010154d <mem_init+0x415>
f0101529:	c7 44 24 0c 3d 4a 10 	movl   $0xf0104a3d,0xc(%esp)
f0101530:	f0 
f0101531:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101538:	f0 
f0101539:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0101540:	00 
f0101541:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101548:	e8 33 eb ff ff       	call   f0100080 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010154d:	39 fe                	cmp    %edi,%esi
f010154f:	75 24                	jne    f0101575 <mem_init+0x43d>
f0101551:	c7 44 24 0c 53 4a 10 	movl   $0xf0104a53,0xc(%esp)
f0101558:	f0 
f0101559:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101560:	f0 
f0101561:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
f0101568:	00 
f0101569:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101570:	e8 0b eb ff ff       	call   f0100080 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101575:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101578:	74 05                	je     f010157f <mem_init+0x447>
f010157a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010157d:	75 24                	jne    f01015a3 <mem_init+0x46b>
f010157f:	c7 44 24 0c 10 43 10 	movl   $0xf0104310,0xc(%esp)
f0101586:	f0 
f0101587:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010158e:	f0 
f010158f:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f0101596:	00 
f0101597:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010159e:	e8 dd ea ff ff       	call   f0100080 <_panic>
	assert(!page_alloc(0));
f01015a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015aa:	e8 a7 f7 ff ff       	call   f0100d56 <page_alloc>
f01015af:	85 c0                	test   %eax,%eax
f01015b1:	74 24                	je     f01015d7 <mem_init+0x49f>
f01015b3:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f01015ba:	f0 
f01015bb:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01015c2:	f0 
f01015c3:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
f01015ca:	00 
f01015cb:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01015d2:	e8 a9 ea ff ff       	call   f0100080 <_panic>
f01015d7:	89 f0                	mov    %esi,%eax
f01015d9:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f01015df:	c1 f8 03             	sar    $0x3,%eax
f01015e2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015e5:	89 c2                	mov    %eax,%edx
f01015e7:	c1 ea 0c             	shr    $0xc,%edx
f01015ea:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f01015f0:	72 20                	jb     f0101612 <mem_init+0x4da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015f6:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f01015fd:	f0 
f01015fe:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101605:	00 
f0101606:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f010160d:	e8 6e ea ff ff       	call   f0100080 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101612:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101619:	00 
f010161a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101621:	00 
	return (void *)(pa + KERNBASE);
f0101622:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101627:	89 04 24             	mov    %eax,(%esp)
f010162a:	e8 ff 21 00 00       	call   f010382e <memset>
	page_free(pp0);
f010162f:	89 34 24             	mov    %esi,(%esp)
f0101632:	e8 d2 f7 ff ff       	call   f0100e09 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101637:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010163e:	e8 13 f7 ff ff       	call   f0100d56 <page_alloc>
f0101643:	85 c0                	test   %eax,%eax
f0101645:	75 24                	jne    f010166b <mem_init+0x533>
f0101647:	c7 44 24 0c cb 4a 10 	movl   $0xf0104acb,0xc(%esp)
f010164e:	f0 
f010164f:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101656:	f0 
f0101657:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f010165e:	00 
f010165f:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101666:	e8 15 ea ff ff       	call   f0100080 <_panic>
	assert(pp && pp0 == pp);
f010166b:	39 c6                	cmp    %eax,%esi
f010166d:	74 24                	je     f0101693 <mem_init+0x55b>
f010166f:	c7 44 24 0c e9 4a 10 	movl   $0xf0104ae9,0xc(%esp)
f0101676:	f0 
f0101677:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010167e:	f0 
f010167f:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0101686:	00 
f0101687:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010168e:	e8 ed e9 ff ff       	call   f0100080 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101693:	89 f2                	mov    %esi,%edx
f0101695:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f010169b:	c1 fa 03             	sar    $0x3,%edx
f010169e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016a1:	89 d0                	mov    %edx,%eax
f01016a3:	c1 e8 0c             	shr    $0xc,%eax
f01016a6:	3b 05 64 f9 11 f0    	cmp    0xf011f964,%eax
f01016ac:	72 20                	jb     f01016ce <mem_init+0x596>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01016b2:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f01016b9:	f0 
f01016ba:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016c1:	00 
f01016c2:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f01016c9:	e8 b2 e9 ff ff       	call   f0100080 <_panic>
	return (void *)(pa + KERNBASE);
f01016ce:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01016d4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016da:	80 38 00             	cmpb   $0x0,(%eax)
f01016dd:	74 24                	je     f0101703 <mem_init+0x5cb>
f01016df:	c7 44 24 0c f9 4a 10 	movl   $0xf0104af9,0xc(%esp)
f01016e6:	f0 
f01016e7:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01016ee:	f0 
f01016ef:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f01016f6:	00 
f01016f7:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01016fe:	e8 7d e9 ff ff       	call   f0100080 <_panic>
f0101703:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101704:	39 d0                	cmp    %edx,%eax
f0101706:	75 d2                	jne    f01016da <mem_init+0x5a2>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101708:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010170b:	89 15 40 f5 11 f0    	mov    %edx,0xf011f540

	// free the pages we took
	page_free(pp0);
f0101711:	89 34 24             	mov    %esi,(%esp)
f0101714:	e8 f0 f6 ff ff       	call   f0100e09 <page_free>
	page_free(pp1);
f0101719:	89 3c 24             	mov    %edi,(%esp)
f010171c:	e8 e8 f6 ff ff       	call   f0100e09 <page_free>
	page_free(pp2);
f0101721:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101724:	89 04 24             	mov    %eax,(%esp)
f0101727:	e8 dd f6 ff ff       	call   f0100e09 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010172c:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f0101731:	eb 03                	jmp    f0101736 <mem_init+0x5fe>
		--nfree;
f0101733:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101734:	8b 00                	mov    (%eax),%eax
f0101736:	85 c0                	test   %eax,%eax
f0101738:	75 f9                	jne    f0101733 <mem_init+0x5fb>
		--nfree;
	assert(nfree == 0);
f010173a:	85 db                	test   %ebx,%ebx
f010173c:	74 24                	je     f0101762 <mem_init+0x62a>
f010173e:	c7 44 24 0c 03 4b 10 	movl   $0xf0104b03,0xc(%esp)
f0101745:	f0 
f0101746:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010174d:	f0 
f010174e:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0101755:	00 
f0101756:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010175d:	e8 1e e9 ff ff       	call   f0100080 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101762:	c7 04 24 30 43 10 f0 	movl   $0xf0104330,(%esp)
f0101769:	e8 1c 16 00 00       	call   f0102d8a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010176e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101775:	e8 dc f5 ff ff       	call   f0100d56 <page_alloc>
f010177a:	89 c7                	mov    %eax,%edi
f010177c:	85 c0                	test   %eax,%eax
f010177e:	75 24                	jne    f01017a4 <mem_init+0x66c>
f0101780:	c7 44 24 0c 11 4a 10 	movl   $0xf0104a11,0xc(%esp)
f0101787:	f0 
f0101788:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010178f:	f0 
f0101790:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0101797:	00 
f0101798:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010179f:	e8 dc e8 ff ff       	call   f0100080 <_panic>
	assert((pp1 = page_alloc(0)));
f01017a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ab:	e8 a6 f5 ff ff       	call   f0100d56 <page_alloc>
f01017b0:	89 c6                	mov    %eax,%esi
f01017b2:	85 c0                	test   %eax,%eax
f01017b4:	75 24                	jne    f01017da <mem_init+0x6a2>
f01017b6:	c7 44 24 0c 27 4a 10 	movl   $0xf0104a27,0xc(%esp)
f01017bd:	f0 
f01017be:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01017c5:	f0 
f01017c6:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f01017cd:	00 
f01017ce:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01017d5:	e8 a6 e8 ff ff       	call   f0100080 <_panic>
	assert((pp2 = page_alloc(0)));
f01017da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017e1:	e8 70 f5 ff ff       	call   f0100d56 <page_alloc>
f01017e6:	89 c3                	mov    %eax,%ebx
f01017e8:	85 c0                	test   %eax,%eax
f01017ea:	75 24                	jne    f0101810 <mem_init+0x6d8>
f01017ec:	c7 44 24 0c 3d 4a 10 	movl   $0xf0104a3d,0xc(%esp)
f01017f3:	f0 
f01017f4:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01017fb:	f0 
f01017fc:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0101803:	00 
f0101804:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010180b:	e8 70 e8 ff ff       	call   f0100080 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101810:	39 f7                	cmp    %esi,%edi
f0101812:	75 24                	jne    f0101838 <mem_init+0x700>
f0101814:	c7 44 24 0c 53 4a 10 	movl   $0xf0104a53,0xc(%esp)
f010181b:	f0 
f010181c:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101823:	f0 
f0101824:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f010182b:	00 
f010182c:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101833:	e8 48 e8 ff ff       	call   f0100080 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101838:	39 c6                	cmp    %eax,%esi
f010183a:	74 04                	je     f0101840 <mem_init+0x708>
f010183c:	39 c7                	cmp    %eax,%edi
f010183e:	75 24                	jne    f0101864 <mem_init+0x72c>
f0101840:	c7 44 24 0c 10 43 10 	movl   $0xf0104310,0xc(%esp)
f0101847:	f0 
f0101848:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010184f:	f0 
f0101850:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0101857:	00 
f0101858:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010185f:	e8 1c e8 ff ff       	call   f0100080 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101864:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f010186a:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010186d:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f0101874:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101877:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010187e:	e8 d3 f4 ff ff       	call   f0100d56 <page_alloc>
f0101883:	85 c0                	test   %eax,%eax
f0101885:	74 24                	je     f01018ab <mem_init+0x773>
f0101887:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f010188e:	f0 
f010188f:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101896:	f0 
f0101897:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010189e:	00 
f010189f:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01018a6:	e8 d5 e7 ff ff       	call   f0100080 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018b9:	00 
f01018ba:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01018bf:	89 04 24             	mov    %eax,(%esp)
f01018c2:	e8 20 f7 ff ff       	call   f0100fe7 <page_lookup>
f01018c7:	85 c0                	test   %eax,%eax
f01018c9:	74 24                	je     f01018ef <mem_init+0x7b7>
f01018cb:	c7 44 24 0c 50 43 10 	movl   $0xf0104350,0xc(%esp)
f01018d2:	f0 
f01018d3:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01018da:	f0 
f01018db:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f01018e2:	00 
f01018e3:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01018ea:	e8 91 e7 ff ff       	call   f0100080 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018ef:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018f6:	00 
f01018f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018fe:	00 
f01018ff:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101903:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101908:	89 04 24             	mov    %eax,(%esp)
f010190b:	e8 a2 f7 ff ff       	call   f01010b2 <page_insert>
f0101910:	85 c0                	test   %eax,%eax
f0101912:	78 24                	js     f0101938 <mem_init+0x800>
f0101914:	c7 44 24 0c 88 43 10 	movl   $0xf0104388,0xc(%esp)
f010191b:	f0 
f010191c:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101923:	f0 
f0101924:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f010192b:	00 
f010192c:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101933:	e8 48 e7 ff ff       	call   f0100080 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101938:	89 3c 24             	mov    %edi,(%esp)
f010193b:	e8 c9 f4 ff ff       	call   f0100e09 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101940:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101947:	00 
f0101948:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010194f:	00 
f0101950:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101954:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101959:	89 04 24             	mov    %eax,(%esp)
f010195c:	e8 51 f7 ff ff       	call   f01010b2 <page_insert>
f0101961:	85 c0                	test   %eax,%eax
f0101963:	74 24                	je     f0101989 <mem_init+0x851>
f0101965:	c7 44 24 0c b8 43 10 	movl   $0xf01043b8,0xc(%esp)
f010196c:	f0 
f010196d:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101974:	f0 
f0101975:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010197c:	00 
f010197d:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101984:	e8 f7 e6 ff ff       	call   f0100080 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101989:	8b 0d 68 f9 11 f0    	mov    0xf011f968,%ecx
f010198f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101992:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101997:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010199a:	8b 11                	mov    (%ecx),%edx
f010199c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019a2:	89 f8                	mov    %edi,%eax
f01019a4:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019a7:	c1 f8 03             	sar    $0x3,%eax
f01019aa:	c1 e0 0c             	shl    $0xc,%eax
f01019ad:	39 c2                	cmp    %eax,%edx
f01019af:	74 24                	je     f01019d5 <mem_init+0x89d>
f01019b1:	c7 44 24 0c e8 43 10 	movl   $0xf01043e8,0xc(%esp)
f01019b8:	f0 
f01019b9:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01019c0:	f0 
f01019c1:	c7 44 24 04 0d 03 00 	movl   $0x30d,0x4(%esp)
f01019c8:	00 
f01019c9:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01019d0:	e8 ab e6 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01019da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019dd:	e8 aa ee ff ff       	call   f010088c <check_va2pa>
f01019e2:	89 f2                	mov    %esi,%edx
f01019e4:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019e7:	c1 fa 03             	sar    $0x3,%edx
f01019ea:	c1 e2 0c             	shl    $0xc,%edx
f01019ed:	39 d0                	cmp    %edx,%eax
f01019ef:	74 24                	je     f0101a15 <mem_init+0x8dd>
f01019f1:	c7 44 24 0c 10 44 10 	movl   $0xf0104410,0xc(%esp)
f01019f8:	f0 
f01019f9:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101a00:	f0 
f0101a01:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101a08:	00 
f0101a09:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101a10:	e8 6b e6 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f0101a15:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a1a:	74 24                	je     f0101a40 <mem_init+0x908>
f0101a1c:	c7 44 24 0c 0e 4b 10 	movl   $0xf0104b0e,0xc(%esp)
f0101a23:	f0 
f0101a24:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101a2b:	f0 
f0101a2c:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0101a33:	00 
f0101a34:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101a3b:	e8 40 e6 ff ff       	call   f0100080 <_panic>
	assert(pp0->pp_ref == 1);
f0101a40:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a45:	74 24                	je     f0101a6b <mem_init+0x933>
f0101a47:	c7 44 24 0c 1f 4b 10 	movl   $0xf0104b1f,0xc(%esp)
f0101a4e:	f0 
f0101a4f:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101a56:	f0 
f0101a57:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0101a5e:	00 
f0101a5f:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101a66:	e8 15 e6 ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a6b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a72:	00 
f0101a73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a7a:	00 
f0101a7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a7f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a82:	89 14 24             	mov    %edx,(%esp)
f0101a85:	e8 28 f6 ff ff       	call   f01010b2 <page_insert>
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	74 24                	je     f0101ab2 <mem_init+0x97a>
f0101a8e:	c7 44 24 0c 40 44 10 	movl   $0xf0104440,0xc(%esp)
f0101a95:	f0 
f0101a96:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101a9d:	f0 
f0101a9e:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101aa5:	00 
f0101aa6:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101aad:	e8 ce e5 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ab2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab7:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101abc:	e8 cb ed ff ff       	call   f010088c <check_va2pa>
f0101ac1:	89 da                	mov    %ebx,%edx
f0101ac3:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f0101ac9:	c1 fa 03             	sar    $0x3,%edx
f0101acc:	c1 e2 0c             	shl    $0xc,%edx
f0101acf:	39 d0                	cmp    %edx,%eax
f0101ad1:	74 24                	je     f0101af7 <mem_init+0x9bf>
f0101ad3:	c7 44 24 0c 7c 44 10 	movl   $0xf010447c,0xc(%esp)
f0101ada:	f0 
f0101adb:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101ae2:	f0 
f0101ae3:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0101aea:	00 
f0101aeb:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101af2:	e8 89 e5 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101af7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101afc:	74 24                	je     f0101b22 <mem_init+0x9ea>
f0101afe:	c7 44 24 0c 30 4b 10 	movl   $0xf0104b30,0xc(%esp)
f0101b05:	f0 
f0101b06:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101b0d:	f0 
f0101b0e:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0101b15:	00 
f0101b16:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101b1d:	e8 5e e5 ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b29:	e8 28 f2 ff ff       	call   f0100d56 <page_alloc>
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	74 24                	je     f0101b56 <mem_init+0xa1e>
f0101b32:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f0101b39:	f0 
f0101b3a:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101b41:	f0 
f0101b42:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101b49:	00 
f0101b4a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101b51:	e8 2a e5 ff ff       	call   f0100080 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b56:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b5d:	00 
f0101b5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b65:	00 
f0101b66:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b6a:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101b6f:	89 04 24             	mov    %eax,(%esp)
f0101b72:	e8 3b f5 ff ff       	call   f01010b2 <page_insert>
f0101b77:	85 c0                	test   %eax,%eax
f0101b79:	74 24                	je     f0101b9f <mem_init+0xa67>
f0101b7b:	c7 44 24 0c 40 44 10 	movl   $0xf0104440,0xc(%esp)
f0101b82:	f0 
f0101b83:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101b8a:	f0 
f0101b8b:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101b92:	00 
f0101b93:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101b9a:	e8 e1 e4 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b9f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ba4:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101ba9:	e8 de ec ff ff       	call   f010088c <check_va2pa>
f0101bae:	89 da                	mov    %ebx,%edx
f0101bb0:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f0101bb6:	c1 fa 03             	sar    $0x3,%edx
f0101bb9:	c1 e2 0c             	shl    $0xc,%edx
f0101bbc:	39 d0                	cmp    %edx,%eax
f0101bbe:	74 24                	je     f0101be4 <mem_init+0xaac>
f0101bc0:	c7 44 24 0c 7c 44 10 	movl   $0xf010447c,0xc(%esp)
f0101bc7:	f0 
f0101bc8:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101bcf:	f0 
f0101bd0:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101bd7:	00 
f0101bd8:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101bdf:	e8 9c e4 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101be4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101be9:	74 24                	je     f0101c0f <mem_init+0xad7>
f0101beb:	c7 44 24 0c 30 4b 10 	movl   $0xf0104b30,0xc(%esp)
f0101bf2:	f0 
f0101bf3:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101c02:	00 
f0101c03:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101c0a:	e8 71 e4 ff ff       	call   f0100080 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c16:	e8 3b f1 ff ff       	call   f0100d56 <page_alloc>
f0101c1b:	85 c0                	test   %eax,%eax
f0101c1d:	74 24                	je     f0101c43 <mem_init+0xb0b>
f0101c1f:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f0101c26:	f0 
f0101c27:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101c2e:	f0 
f0101c2f:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101c36:	00 
f0101c37:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101c3e:	e8 3d e4 ff ff       	call   f0100080 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c43:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f0101c49:	8b 02                	mov    (%edx),%eax
f0101c4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c50:	89 c1                	mov    %eax,%ecx
f0101c52:	c1 e9 0c             	shr    $0xc,%ecx
f0101c55:	3b 0d 64 f9 11 f0    	cmp    0xf011f964,%ecx
f0101c5b:	72 20                	jb     f0101c7d <mem_init+0xb45>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c61:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0101c68:	f0 
f0101c69:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101c70:	00 
f0101c71:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101c78:	e8 03 e4 ff ff       	call   f0100080 <_panic>
	return (void *)(pa + KERNBASE);
f0101c7d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c8c:	00 
f0101c8d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c94:	00 
f0101c95:	89 14 24             	mov    %edx,(%esp)
f0101c98:	e8 e8 f1 ff ff       	call   f0100e85 <pgdir_walk>
f0101c9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ca0:	83 c2 04             	add    $0x4,%edx
f0101ca3:	39 d0                	cmp    %edx,%eax
f0101ca5:	74 24                	je     f0101ccb <mem_init+0xb93>
f0101ca7:	c7 44 24 0c ac 44 10 	movl   $0xf01044ac,0xc(%esp)
f0101cae:	f0 
f0101caf:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101cb6:	f0 
f0101cb7:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101cbe:	00 
f0101cbf:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101cc6:	e8 b5 e3 ff ff       	call   f0100080 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ccb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101cd2:	00 
f0101cd3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cda:	00 
f0101cdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cdf:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101ce4:	89 04 24             	mov    %eax,(%esp)
f0101ce7:	e8 c6 f3 ff ff       	call   f01010b2 <page_insert>
f0101cec:	85 c0                	test   %eax,%eax
f0101cee:	74 24                	je     f0101d14 <mem_init+0xbdc>
f0101cf0:	c7 44 24 0c ec 44 10 	movl   $0xf01044ec,0xc(%esp)
f0101cf7:	f0 
f0101cf8:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101cff:	f0 
f0101d00:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f0101d07:	00 
f0101d08:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101d0f:	e8 6c e3 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d14:	8b 0d 68 f9 11 f0    	mov    0xf011f968,%ecx
f0101d1a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101d1d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d22:	89 c8                	mov    %ecx,%eax
f0101d24:	e8 63 eb ff ff       	call   f010088c <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d29:	89 da                	mov    %ebx,%edx
f0101d2b:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f0101d31:	c1 fa 03             	sar    $0x3,%edx
f0101d34:	c1 e2 0c             	shl    $0xc,%edx
f0101d37:	39 d0                	cmp    %edx,%eax
f0101d39:	74 24                	je     f0101d5f <mem_init+0xc27>
f0101d3b:	c7 44 24 0c 7c 44 10 	movl   $0xf010447c,0xc(%esp)
f0101d42:	f0 
f0101d43:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101d4a:	f0 
f0101d4b:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101d52:	00 
f0101d53:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101d5a:	e8 21 e3 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0101d5f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d64:	74 24                	je     f0101d8a <mem_init+0xc52>
f0101d66:	c7 44 24 0c 30 4b 10 	movl   $0xf0104b30,0xc(%esp)
f0101d6d:	f0 
f0101d6e:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101d75:	f0 
f0101d76:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101d7d:	00 
f0101d7e:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101d85:	e8 f6 e2 ff ff       	call   f0100080 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d91:	00 
f0101d92:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d99:	00 
f0101d9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d9d:	89 04 24             	mov    %eax,(%esp)
f0101da0:	e8 e0 f0 ff ff       	call   f0100e85 <pgdir_walk>
f0101da5:	f6 00 04             	testb  $0x4,(%eax)
f0101da8:	75 24                	jne    f0101dce <mem_init+0xc96>
f0101daa:	c7 44 24 0c 2c 45 10 	movl   $0xf010452c,0xc(%esp)
f0101db1:	f0 
f0101db2:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101db9:	f0 
f0101dba:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0101dc1:	00 
f0101dc2:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101dc9:	e8 b2 e2 ff ff       	call   f0100080 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101dce:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101dd3:	f6 00 04             	testb  $0x4,(%eax)
f0101dd6:	75 24                	jne    f0101dfc <mem_init+0xcc4>
f0101dd8:	c7 44 24 0c 41 4b 10 	movl   $0xf0104b41,0xc(%esp)
f0101ddf:	f0 
f0101de0:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101de7:	f0 
f0101de8:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101def:	00 
f0101df0:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101df7:	e8 84 e2 ff ff       	call   f0100080 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dfc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e03:	00 
f0101e04:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e0b:	00 
f0101e0c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e10:	89 04 24             	mov    %eax,(%esp)
f0101e13:	e8 9a f2 ff ff       	call   f01010b2 <page_insert>
f0101e18:	85 c0                	test   %eax,%eax
f0101e1a:	74 24                	je     f0101e40 <mem_init+0xd08>
f0101e1c:	c7 44 24 0c 40 44 10 	movl   $0xf0104440,0xc(%esp)
f0101e23:	f0 
f0101e24:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101e2b:	f0 
f0101e2c:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101e33:	00 
f0101e34:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101e3b:	e8 40 e2 ff ff       	call   f0100080 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e47:	00 
f0101e48:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e4f:	00 
f0101e50:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101e55:	89 04 24             	mov    %eax,(%esp)
f0101e58:	e8 28 f0 ff ff       	call   f0100e85 <pgdir_walk>
f0101e5d:	f6 00 02             	testb  $0x2,(%eax)
f0101e60:	75 24                	jne    f0101e86 <mem_init+0xd4e>
f0101e62:	c7 44 24 0c 60 45 10 	movl   $0xf0104560,0xc(%esp)
f0101e69:	f0 
f0101e6a:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101e71:	f0 
f0101e72:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101e79:	00 
f0101e7a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101e81:	e8 fa e1 ff ff       	call   f0100080 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e8d:	00 
f0101e8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e95:	00 
f0101e96:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101e9b:	89 04 24             	mov    %eax,(%esp)
f0101e9e:	e8 e2 ef ff ff       	call   f0100e85 <pgdir_walk>
f0101ea3:	f6 00 04             	testb  $0x4,(%eax)
f0101ea6:	74 24                	je     f0101ecc <mem_init+0xd94>
f0101ea8:	c7 44 24 0c 94 45 10 	movl   $0xf0104594,0xc(%esp)
f0101eaf:	f0 
f0101eb0:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101eb7:	f0 
f0101eb8:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101ebf:	00 
f0101ec0:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101ec7:	e8 b4 e1 ff ff       	call   f0100080 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ecc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ed3:	00 
f0101ed4:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101edb:	00 
f0101edc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ee0:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101ee5:	89 04 24             	mov    %eax,(%esp)
f0101ee8:	e8 c5 f1 ff ff       	call   f01010b2 <page_insert>
f0101eed:	85 c0                	test   %eax,%eax
f0101eef:	78 24                	js     f0101f15 <mem_init+0xddd>
f0101ef1:	c7 44 24 0c cc 45 10 	movl   $0xf01045cc,0xc(%esp)
f0101ef8:	f0 
f0101ef9:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101f00:	f0 
f0101f01:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101f08:	00 
f0101f09:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101f10:	e8 6b e1 ff ff       	call   f0100080 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f15:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f1c:	00 
f0101f1d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f24:	00 
f0101f25:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f29:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101f2e:	89 04 24             	mov    %eax,(%esp)
f0101f31:	e8 7c f1 ff ff       	call   f01010b2 <page_insert>
f0101f36:	85 c0                	test   %eax,%eax
f0101f38:	74 24                	je     f0101f5e <mem_init+0xe26>
f0101f3a:	c7 44 24 0c 04 46 10 	movl   $0xf0104604,0xc(%esp)
f0101f41:	f0 
f0101f42:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101f49:	f0 
f0101f4a:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101f51:	00 
f0101f52:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101f59:	e8 22 e1 ff ff       	call   f0100080 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f65:	00 
f0101f66:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f6d:	00 
f0101f6e:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101f73:	89 04 24             	mov    %eax,(%esp)
f0101f76:	e8 0a ef ff ff       	call   f0100e85 <pgdir_walk>
f0101f7b:	f6 00 04             	testb  $0x4,(%eax)
f0101f7e:	74 24                	je     f0101fa4 <mem_init+0xe6c>
f0101f80:	c7 44 24 0c 94 45 10 	movl   $0xf0104594,0xc(%esp)
f0101f87:	f0 
f0101f88:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101f8f:	f0 
f0101f90:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f0101f97:	00 
f0101f98:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101f9f:	e8 dc e0 ff ff       	call   f0100080 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fa4:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101fa9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fac:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fb1:	e8 d6 e8 ff ff       	call   f010088c <check_va2pa>
f0101fb6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fb9:	89 f0                	mov    %esi,%eax
f0101fbb:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0101fc1:	c1 f8 03             	sar    $0x3,%eax
f0101fc4:	c1 e0 0c             	shl    $0xc,%eax
f0101fc7:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fca:	74 24                	je     f0101ff0 <mem_init+0xeb8>
f0101fcc:	c7 44 24 0c 40 46 10 	movl   $0xf0104640,0xc(%esp)
f0101fd3:	f0 
f0101fd4:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0101fdb:	f0 
f0101fdc:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0101fe3:	00 
f0101fe4:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0101feb:	e8 90 e0 ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ff0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ff5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff8:	e8 8f e8 ff ff       	call   f010088c <check_va2pa>
f0101ffd:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102000:	74 24                	je     f0102026 <mem_init+0xeee>
f0102002:	c7 44 24 0c 6c 46 10 	movl   $0xf010466c,0xc(%esp)
f0102009:	f0 
f010200a:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102011:	f0 
f0102012:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0102019:	00 
f010201a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102021:	e8 5a e0 ff ff       	call   f0100080 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102026:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010202b:	74 24                	je     f0102051 <mem_init+0xf19>
f010202d:	c7 44 24 0c 57 4b 10 	movl   $0xf0104b57,0xc(%esp)
f0102034:	f0 
f0102035:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010203c:	f0 
f010203d:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0102044:	00 
f0102045:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010204c:	e8 2f e0 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f0102051:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102056:	74 24                	je     f010207c <mem_init+0xf44>
f0102058:	c7 44 24 0c 68 4b 10 	movl   $0xf0104b68,0xc(%esp)
f010205f:	f0 
f0102060:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102067:	f0 
f0102068:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f010206f:	00 
f0102070:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102077:	e8 04 e0 ff ff       	call   f0100080 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010207c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102083:	e8 ce ec ff ff       	call   f0100d56 <page_alloc>
f0102088:	85 c0                	test   %eax,%eax
f010208a:	74 04                	je     f0102090 <mem_init+0xf58>
f010208c:	39 c3                	cmp    %eax,%ebx
f010208e:	74 24                	je     f01020b4 <mem_init+0xf7c>
f0102090:	c7 44 24 0c 9c 46 10 	movl   $0xf010469c,0xc(%esp)
f0102097:	f0 
f0102098:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010209f:	f0 
f01020a0:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f01020a7:	00 
f01020a8:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01020af:	e8 cc df ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020bb:	00 
f01020bc:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01020c1:	89 04 24             	mov    %eax,(%esp)
f01020c4:	e8 99 ef ff ff       	call   f0101062 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020c9:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f01020cf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01020d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01020d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020da:	e8 ad e7 ff ff       	call   f010088c <check_va2pa>
f01020df:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020e2:	74 24                	je     f0102108 <mem_init+0xfd0>
f01020e4:	c7 44 24 0c c0 46 10 	movl   $0xf01046c0,0xc(%esp)
f01020eb:	f0 
f01020ec:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01020f3:	f0 
f01020f4:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f01020fb:	00 
f01020fc:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102103:	e8 78 df ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102108:	ba 00 10 00 00       	mov    $0x1000,%edx
f010210d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102110:	e8 77 e7 ff ff       	call   f010088c <check_va2pa>
f0102115:	89 f2                	mov    %esi,%edx
f0102117:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f010211d:	c1 fa 03             	sar    $0x3,%edx
f0102120:	c1 e2 0c             	shl    $0xc,%edx
f0102123:	39 d0                	cmp    %edx,%eax
f0102125:	74 24                	je     f010214b <mem_init+0x1013>
f0102127:	c7 44 24 0c 6c 46 10 	movl   $0xf010466c,0xc(%esp)
f010212e:	f0 
f010212f:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102136:	f0 
f0102137:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f010213e:	00 
f010213f:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102146:	e8 35 df ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 1);
f010214b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102150:	74 24                	je     f0102176 <mem_init+0x103e>
f0102152:	c7 44 24 0c 0e 4b 10 	movl   $0xf0104b0e,0xc(%esp)
f0102159:	f0 
f010215a:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102161:	f0 
f0102162:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0102169:	00 
f010216a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102171:	e8 0a df ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f0102176:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010217b:	74 24                	je     f01021a1 <mem_init+0x1069>
f010217d:	c7 44 24 0c 68 4b 10 	movl   $0xf0104b68,0xc(%esp)
f0102184:	f0 
f0102185:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010218c:	f0 
f010218d:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0102194:	00 
f0102195:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010219c:	e8 df de ff ff       	call   f0100080 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021a8:	00 
f01021a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021b0:	00 
f01021b1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021b5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021b8:	89 0c 24             	mov    %ecx,(%esp)
f01021bb:	e8 f2 ee ff ff       	call   f01010b2 <page_insert>
f01021c0:	85 c0                	test   %eax,%eax
f01021c2:	74 24                	je     f01021e8 <mem_init+0x10b0>
f01021c4:	c7 44 24 0c e4 46 10 	movl   $0xf01046e4,0xc(%esp)
f01021cb:	f0 
f01021cc:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01021d3:	f0 
f01021d4:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f01021db:	00 
f01021dc:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01021e3:	e8 98 de ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref);
f01021e8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021ed:	75 24                	jne    f0102213 <mem_init+0x10db>
f01021ef:	c7 44 24 0c 79 4b 10 	movl   $0xf0104b79,0xc(%esp)
f01021f6:	f0 
f01021f7:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01021fe:	f0 
f01021ff:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0102206:	00 
f0102207:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010220e:	e8 6d de ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_link == NULL);
f0102213:	83 3e 00             	cmpl   $0x0,(%esi)
f0102216:	74 24                	je     f010223c <mem_init+0x1104>
f0102218:	c7 44 24 0c 85 4b 10 	movl   $0xf0104b85,0xc(%esp)
f010221f:	f0 
f0102220:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102227:	f0 
f0102228:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f010222f:	00 
f0102230:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102237:	e8 44 de ff ff       	call   f0100080 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010223c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102243:	00 
f0102244:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102249:	89 04 24             	mov    %eax,(%esp)
f010224c:	e8 11 ee ff ff       	call   f0101062 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102251:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102256:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102259:	ba 00 00 00 00       	mov    $0x0,%edx
f010225e:	e8 29 e6 ff ff       	call   f010088c <check_va2pa>
f0102263:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102266:	74 24                	je     f010228c <mem_init+0x1154>
f0102268:	c7 44 24 0c c0 46 10 	movl   $0xf01046c0,0xc(%esp)
f010226f:	f0 
f0102270:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102277:	f0 
f0102278:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010227f:	00 
f0102280:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102287:	e8 f4 dd ff ff       	call   f0100080 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010228c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102291:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102294:	e8 f3 e5 ff ff       	call   f010088c <check_va2pa>
f0102299:	83 f8 ff             	cmp    $0xffffffff,%eax
f010229c:	74 24                	je     f01022c2 <mem_init+0x118a>
f010229e:	c7 44 24 0c 1c 47 10 	movl   $0xf010471c,0xc(%esp)
f01022a5:	f0 
f01022a6:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01022ad:	f0 
f01022ae:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01022b5:	00 
f01022b6:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01022bd:	e8 be dd ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 0);
f01022c2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c7:	74 24                	je     f01022ed <mem_init+0x11b5>
f01022c9:	c7 44 24 0c 9a 4b 10 	movl   $0xf0104b9a,0xc(%esp)
f01022d0:	f0 
f01022d1:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01022d8:	f0 
f01022d9:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01022e0:	00 
f01022e1:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01022e8:	e8 93 dd ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 0);
f01022ed:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022f2:	74 24                	je     f0102318 <mem_init+0x11e0>
f01022f4:	c7 44 24 0c 68 4b 10 	movl   $0xf0104b68,0xc(%esp)
f01022fb:	f0 
f01022fc:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102303:	f0 
f0102304:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f010230b:	00 
f010230c:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102313:	e8 68 dd ff ff       	call   f0100080 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102318:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010231f:	e8 32 ea ff ff       	call   f0100d56 <page_alloc>
f0102324:	85 c0                	test   %eax,%eax
f0102326:	74 04                	je     f010232c <mem_init+0x11f4>
f0102328:	39 c6                	cmp    %eax,%esi
f010232a:	74 24                	je     f0102350 <mem_init+0x1218>
f010232c:	c7 44 24 0c 44 47 10 	movl   $0xf0104744,0xc(%esp)
f0102333:	f0 
f0102334:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010233b:	f0 
f010233c:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0102343:	00 
f0102344:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010234b:	e8 30 dd ff ff       	call   f0100080 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102357:	e8 fa e9 ff ff       	call   f0100d56 <page_alloc>
f010235c:	85 c0                	test   %eax,%eax
f010235e:	74 24                	je     f0102384 <mem_init+0x124c>
f0102360:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f0102367:	f0 
f0102368:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010236f:	f0 
f0102370:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0102377:	00 
f0102378:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010237f:	e8 fc dc ff ff       	call   f0100080 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102384:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102389:	8b 08                	mov    (%eax),%ecx
f010238b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102391:	89 fa                	mov    %edi,%edx
f0102393:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f0102399:	c1 fa 03             	sar    $0x3,%edx
f010239c:	c1 e2 0c             	shl    $0xc,%edx
f010239f:	39 d1                	cmp    %edx,%ecx
f01023a1:	74 24                	je     f01023c7 <mem_init+0x128f>
f01023a3:	c7 44 24 0c e8 43 10 	movl   $0xf01043e8,0xc(%esp)
f01023aa:	f0 
f01023ab:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01023b2:	f0 
f01023b3:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f01023ba:	00 
f01023bb:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01023c2:	e8 b9 dc ff ff       	call   f0100080 <_panic>
	kern_pgdir[0] = 0;
f01023c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023cd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023d2:	74 24                	je     f01023f8 <mem_init+0x12c0>
f01023d4:	c7 44 24 0c 1f 4b 10 	movl   $0xf0104b1f,0xc(%esp)
f01023db:	f0 
f01023dc:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01023e3:	f0 
f01023e4:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f01023eb:	00 
f01023ec:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01023f3:	e8 88 dc ff ff       	call   f0100080 <_panic>
	pp0->pp_ref = 0;
f01023f8:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023fe:	89 3c 24             	mov    %edi,(%esp)
f0102401:	e8 03 ea ff ff       	call   f0100e09 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102406:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010240d:	00 
f010240e:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102415:	00 
f0102416:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f010241b:	89 04 24             	mov    %eax,(%esp)
f010241e:	e8 62 ea ff ff       	call   f0100e85 <pgdir_walk>
f0102423:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102426:	8b 0d 68 f9 11 f0    	mov    0xf011f968,%ecx
f010242c:	8b 51 04             	mov    0x4(%ecx),%edx
f010242f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102435:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102438:	8b 15 64 f9 11 f0    	mov    0xf011f964,%edx
f010243e:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102441:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102444:	c1 ea 0c             	shr    $0xc,%edx
f0102447:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010244a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010244d:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102450:	72 23                	jb     f0102475 <mem_init+0x133d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102452:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102455:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102459:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0102460:	f0 
f0102461:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0102468:	00 
f0102469:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102470:	e8 0b dc ff ff       	call   f0100080 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102475:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102478:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010247e:	39 d0                	cmp    %edx,%eax
f0102480:	74 24                	je     f01024a6 <mem_init+0x136e>
f0102482:	c7 44 24 0c ab 4b 10 	movl   $0xf0104bab,0xc(%esp)
f0102489:	f0 
f010248a:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102491:	f0 
f0102492:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102499:	00 
f010249a:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01024a1:	e8 da db ff ff       	call   f0100080 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024a6:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024ad:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024b3:	89 f8                	mov    %edi,%eax
f01024b5:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f01024bb:	c1 f8 03             	sar    $0x3,%eax
f01024be:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024c1:	89 c1                	mov    %eax,%ecx
f01024c3:	c1 e9 0c             	shr    $0xc,%ecx
f01024c6:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01024c9:	77 20                	ja     f01024eb <mem_init+0x13b3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024cf:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f01024d6:	f0 
f01024d7:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024de:	00 
f01024df:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f01024e6:	e8 95 db ff ff       	call   f0100080 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024eb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024f2:	00 
f01024f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024fa:	00 
	return (void *)(pa + KERNBASE);
f01024fb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102500:	89 04 24             	mov    %eax,(%esp)
f0102503:	e8 26 13 00 00       	call   f010382e <memset>
	page_free(pp0);
f0102508:	89 3c 24             	mov    %edi,(%esp)
f010250b:	e8 f9 e8 ff ff       	call   f0100e09 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102510:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102517:	00 
f0102518:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010251f:	00 
f0102520:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102525:	89 04 24             	mov    %eax,(%esp)
f0102528:	e8 58 e9 ff ff       	call   f0100e85 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010252d:	89 fa                	mov    %edi,%edx
f010252f:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f0102535:	c1 fa 03             	sar    $0x3,%edx
f0102538:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010253b:	89 d0                	mov    %edx,%eax
f010253d:	c1 e8 0c             	shr    $0xc,%eax
f0102540:	3b 05 64 f9 11 f0    	cmp    0xf011f964,%eax
f0102546:	72 20                	jb     f0102568 <mem_init+0x1430>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102548:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010254c:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0102553:	f0 
f0102554:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010255b:	00 
f010255c:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0102563:	e8 18 db ff ff       	call   f0100080 <_panic>
	return (void *)(pa + KERNBASE);
f0102568:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010256e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f0102571:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102577:	f6 00 01             	testb  $0x1,(%eax)
f010257a:	74 24                	je     f01025a0 <mem_init+0x1468>
f010257c:	c7 44 24 0c c3 4b 10 	movl   $0xf0104bc3,0xc(%esp)
f0102583:	f0 
f0102584:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010258b:	f0 
f010258c:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0102593:	00 
f0102594:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010259b:	e8 e0 da ff ff       	call   f0100080 <_panic>
f01025a0:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025a3:	39 d0                	cmp    %edx,%eax
f01025a5:	75 d0                	jne    f0102577 <mem_init+0x143f>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025a7:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01025ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025b2:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01025b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01025bb:	89 0d 40 f5 11 f0    	mov    %ecx,0xf011f540

	// free the pages we took
	page_free(pp0);
f01025c1:	89 3c 24             	mov    %edi,(%esp)
f01025c4:	e8 40 e8 ff ff       	call   f0100e09 <page_free>
	page_free(pp1);
f01025c9:	89 34 24             	mov    %esi,(%esp)
f01025cc:	e8 38 e8 ff ff       	call   f0100e09 <page_free>
	page_free(pp2);
f01025d1:	89 1c 24             	mov    %ebx,(%esp)
f01025d4:	e8 30 e8 ff ff       	call   f0100e09 <page_free>

	cprintf("check_page() succeeded!\n");
f01025d9:	c7 04 24 da 4b 10 f0 	movl   $0xf0104bda,(%esp)
f01025e0:	e8 a5 07 00 00       	call   f0102d8a <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE), PADDR(pages), PTE_W);
f01025e5:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025ef:	77 20                	ja     f0102611 <mem_init+0x14d9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025f5:	c7 44 24 08 ec 42 10 	movl   $0xf01042ec,0x8(%esp)
f01025fc:	f0 
f01025fd:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
f0102604:	00 
f0102605:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010260c:	e8 6f da ff ff       	call   f0100080 <_panic>
f0102611:	8b 15 64 f9 11 f0    	mov    0xf011f964,%edx
f0102617:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f010261e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102624:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010262b:	00 
	return (physaddr_t)kva - KERNBASE;
f010262c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102631:	89 04 24             	mov    %eax,(%esp)
f0102634:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102639:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f010263e:	e8 47 e9 ff ff       	call   f0100f8a <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102643:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0102648:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010264d:	77 20                	ja     f010266f <mem_init+0x1537>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010264f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102653:	c7 44 24 08 ec 42 10 	movl   $0xf01042ec,0x8(%esp)
f010265a:	f0 
f010265b:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0102662:	00 
f0102663:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010266a:	e8 11 da ff ff       	call   f0100080 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE , PADDR(bootstack), PTE_W);
f010266f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102676:	00 
f0102677:	c7 04 24 00 50 11 00 	movl   $0x115000,(%esp)
f010267e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102683:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102688:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f010268d:	e8 f8 e8 ff ff       	call   f0100f8a <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KERNBASE, (2^32)-KERNBASE, 0, PTE_W);
f0102692:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102699:	00 
f010269a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026a1:	b9 22 00 00 10       	mov    $0x10000022,%ecx
f01026a6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026ab:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01026b0:	e8 d5 e8 ff ff       	call   f0100f8a <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026b5:	8b 1d 68 f9 11 f0    	mov    0xf011f968,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026bb:	8b 15 64 f9 11 f0    	mov    0xf011f964,%edx
f01026c1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01026c4:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f01026cb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f01026d1:	be 00 00 00 00       	mov    $0x0,%esi
f01026d6:	eb 70                	jmp    f0102748 <mem_init+0x1610>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01026d8:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026de:	89 d8                	mov    %ebx,%eax
f01026e0:	e8 a7 e1 ff ff       	call   f010088c <check_va2pa>
f01026e5:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026eb:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026f1:	77 20                	ja     f0102713 <mem_init+0x15db>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026f7:	c7 44 24 08 ec 42 10 	movl   $0xf01042ec,0x8(%esp)
f01026fe:	f0 
f01026ff:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0102706:	00 
f0102707:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010270e:	e8 6d d9 ff ff       	call   f0100080 <_panic>
f0102713:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010271a:	39 d0                	cmp    %edx,%eax
f010271c:	74 24                	je     f0102742 <mem_init+0x160a>
f010271e:	c7 44 24 0c 68 47 10 	movl   $0xf0104768,0xc(%esp)
f0102725:	f0 
f0102726:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010272d:	f0 
f010272e:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f0102735:	00 
f0102736:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010273d:	e8 3e d9 ff ff       	call   f0100080 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102742:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102748:	39 f7                	cmp    %esi,%edi
f010274a:	77 8c                	ja     f01026d8 <mem_init+0x15a0>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010274c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010274f:	c1 e7 0c             	shl    $0xc,%edi
f0102752:	be 00 00 00 00       	mov    $0x0,%esi
f0102757:	eb 3b                	jmp    f0102794 <mem_init+0x165c>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f0102759:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010275f:	89 d8                	mov    %ebx,%eax
f0102761:	e8 26 e1 ff ff       	call   f010088c <check_va2pa>
f0102766:	39 c6                	cmp    %eax,%esi
f0102768:	74 24                	je     f010278e <mem_init+0x1656>
f010276a:	c7 44 24 0c 9c 47 10 	movl   $0xf010479c,0xc(%esp)
f0102771:	f0 
f0102772:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102779:	f0 
f010277a:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f0102781:	00 
f0102782:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102789:	e8 f2 d8 ff ff       	call   f0100080 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010278e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102794:	39 fe                	cmp    %edi,%esi
f0102796:	72 c1                	jb     f0102759 <mem_init+0x1621>
f0102798:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f010279d:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
f01027a2:	81 c7 00 80 00 20    	add    $0x20008000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027a8:	89 f2                	mov    %esi,%edx
f01027aa:	89 d8                	mov    %ebx,%eax
f01027ac:	e8 db e0 ff ff       	call   f010088c <check_va2pa>
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	void
mem_init(void)
f01027b1:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01027b4:	39 d0                	cmp    %edx,%eax
f01027b6:	74 24                	je     f01027dc <mem_init+0x16a4>
f01027b8:	c7 44 24 0c c4 47 10 	movl   $0xf01047c4,0xc(%esp)
f01027bf:	f0 
f01027c0:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01027c7:	f0 
f01027c8:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f01027cf:	00 
f01027d0:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01027d7:	e8 a4 d8 ff ff       	call   f0100080 <_panic>
f01027dc:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01027e2:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01027e8:	75 be                	jne    f01027a8 <mem_init+0x1670>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01027ea:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01027ef:	89 d8                	mov    %ebx,%eax
f01027f1:	e8 96 e0 ff ff       	call   f010088c <check_va2pa>
f01027f6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027f9:	74 24                	je     f010281f <mem_init+0x16e7>
f01027fb:	c7 44 24 0c 0c 48 10 	movl   $0xf010480c,0xc(%esp)
f0102802:	f0 
f0102803:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f010280a:	f0 
f010280b:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0102812:	00 
f0102813:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010281a:	e8 61 d8 ff ff       	call   f0100080 <_panic>
f010281f:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102824:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102829:	72 3c                	jb     f0102867 <mem_init+0x172f>
f010282b:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102830:	76 07                	jbe    f0102839 <mem_init+0x1701>
f0102832:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102837:	75 2e                	jne    f0102867 <mem_init+0x172f>
			case PDX(UVPT):
			case PDX(KSTACKTOP-1):
			case PDX(UPAGES):
				assert(pgdir[i] & PTE_P);
f0102839:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010283d:	0f 85 aa 00 00 00    	jne    f01028ed <mem_init+0x17b5>
f0102843:	c7 44 24 0c f3 4b 10 	movl   $0xf0104bf3,0xc(%esp)
f010284a:	f0 
f010284b:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102852:	f0 
f0102853:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010285a:	00 
f010285b:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102862:	e8 19 d8 ff ff       	call   f0100080 <_panic>
				break;
			default:
				if (i >= PDX(KERNBASE)) {
f0102867:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010286c:	76 55                	jbe    f01028c3 <mem_init+0x178b>
					assert(pgdir[i] & PTE_P);
f010286e:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102871:	f6 c2 01             	test   $0x1,%dl
f0102874:	75 24                	jne    f010289a <mem_init+0x1762>
f0102876:	c7 44 24 0c f3 4b 10 	movl   $0xf0104bf3,0xc(%esp)
f010287d:	f0 
f010287e:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102885:	f0 
f0102886:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f010288d:	00 
f010288e:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102895:	e8 e6 d7 ff ff       	call   f0100080 <_panic>
					assert(pgdir[i] & PTE_W);
f010289a:	f6 c2 02             	test   $0x2,%dl
f010289d:	75 4e                	jne    f01028ed <mem_init+0x17b5>
f010289f:	c7 44 24 0c 04 4c 10 	movl   $0xf0104c04,0xc(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f01028b6:	00 
f01028b7:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01028be:	e8 bd d7 ff ff       	call   f0100080 <_panic>
				} else
					assert(pgdir[i] == 0);
f01028c3:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01028c7:	74 24                	je     f01028ed <mem_init+0x17b5>
f01028c9:	c7 44 24 0c 15 4c 10 	movl   $0xf0104c15,0xc(%esp)
f01028d0:	f0 
f01028d1:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01028d8:	f0 
f01028d9:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01028e0:	00 
f01028e1:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01028e8:	e8 93 d7 ff ff       	call   f0100080 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01028ed:	40                   	inc    %eax
f01028ee:	3d 00 04 00 00       	cmp    $0x400,%eax
f01028f3:	0f 85 2b ff ff ff    	jne    f0102824 <mem_init+0x16ec>
				} else
					assert(pgdir[i] == 0);
				break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01028f9:	c7 04 24 3c 48 10 f0 	movl   $0xf010483c,(%esp)
f0102900:	e8 85 04 00 00       	call   f0102d8a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102905:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010290a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010290f:	77 20                	ja     f0102931 <mem_init+0x17f9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102911:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102915:	c7 44 24 08 ec 42 10 	movl   $0xf01042ec,0x8(%esp)
f010291c:	f0 
f010291d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102924:	00 
f0102925:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f010292c:	e8 4f d7 ff ff       	call   f0100080 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102931:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102936:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102939:	b8 00 00 00 00       	mov    $0x0,%eax
f010293e:	e8 64 e0 ff ff       	call   f01009a7 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102943:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102946:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010294b:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010294e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102951:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102958:	e8 f9 e3 ff ff       	call   f0100d56 <page_alloc>
f010295d:	89 c6                	mov    %eax,%esi
f010295f:	85 c0                	test   %eax,%eax
f0102961:	75 24                	jne    f0102987 <mem_init+0x184f>
f0102963:	c7 44 24 0c 11 4a 10 	movl   $0xf0104a11,0xc(%esp)
f010296a:	f0 
f010296b:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102972:	f0 
f0102973:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f010297a:	00 
f010297b:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102982:	e8 f9 d6 ff ff       	call   f0100080 <_panic>
	assert((pp1 = page_alloc(0)));
f0102987:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010298e:	e8 c3 e3 ff ff       	call   f0100d56 <page_alloc>
f0102993:	89 c7                	mov    %eax,%edi
f0102995:	85 c0                	test   %eax,%eax
f0102997:	75 24                	jne    f01029bd <mem_init+0x1885>
f0102999:	c7 44 24 0c 27 4a 10 	movl   $0xf0104a27,0xc(%esp)
f01029a0:	f0 
f01029a1:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01029a8:	f0 
f01029a9:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01029b0:	00 
f01029b1:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01029b8:	e8 c3 d6 ff ff       	call   f0100080 <_panic>
	assert((pp2 = page_alloc(0)));
f01029bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029c4:	e8 8d e3 ff ff       	call   f0100d56 <page_alloc>
f01029c9:	89 c3                	mov    %eax,%ebx
f01029cb:	85 c0                	test   %eax,%eax
f01029cd:	75 24                	jne    f01029f3 <mem_init+0x18bb>
f01029cf:	c7 44 24 0c 3d 4a 10 	movl   $0xf0104a3d,0xc(%esp)
f01029d6:	f0 
f01029d7:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f01029de:	f0 
f01029df:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f01029e6:	00 
f01029e7:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f01029ee:	e8 8d d6 ff ff       	call   f0100080 <_panic>
	page_free(pp0);
f01029f3:	89 34 24             	mov    %esi,(%esp)
f01029f6:	e8 0e e4 ff ff       	call   f0100e09 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029fb:	89 f8                	mov    %edi,%eax
f01029fd:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0102a03:	c1 f8 03             	sar    $0x3,%eax
f0102a06:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a09:	89 c2                	mov    %eax,%edx
f0102a0b:	c1 ea 0c             	shr    $0xc,%edx
f0102a0e:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0102a14:	72 20                	jb     f0102a36 <mem_init+0x18fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a1a:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0102a21:	f0 
f0102a22:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102a29:	00 
f0102a2a:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0102a31:	e8 4a d6 ff ff       	call   f0100080 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a36:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a3d:	00 
f0102a3e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102a45:	00 
	return (void *)(pa + KERNBASE);
f0102a46:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a4b:	89 04 24             	mov    %eax,(%esp)
f0102a4e:	e8 db 0d 00 00       	call   f010382e <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a53:	89 d8                	mov    %ebx,%eax
f0102a55:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0102a5b:	c1 f8 03             	sar    $0x3,%eax
f0102a5e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a61:	89 c2                	mov    %eax,%edx
f0102a63:	c1 ea 0c             	shr    $0xc,%edx
f0102a66:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0102a6c:	72 20                	jb     f0102a8e <mem_init+0x1956>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a72:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0102a79:	f0 
f0102a7a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102a81:	00 
f0102a82:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0102a89:	e8 f2 d5 ff ff       	call   f0100080 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a8e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a95:	00 
f0102a96:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102a9d:	00 
	return (void *)(pa + KERNBASE);
f0102a9e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aa3:	89 04 24             	mov    %eax,(%esp)
f0102aa6:	e8 83 0d 00 00       	call   f010382e <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102aab:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102ab2:	00 
f0102ab3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102aba:	00 
f0102abb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102abf:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102ac4:	89 04 24             	mov    %eax,(%esp)
f0102ac7:	e8 e6 e5 ff ff       	call   f01010b2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102acc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ad1:	74 24                	je     f0102af7 <mem_init+0x19bf>
f0102ad3:	c7 44 24 0c 0e 4b 10 	movl   $0xf0104b0e,0xc(%esp)
f0102ada:	f0 
f0102adb:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102ae2:	f0 
f0102ae3:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102aea:	00 
f0102aeb:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102af2:	e8 89 d5 ff ff       	call   f0100080 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102af7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102afe:	01 01 01 
f0102b01:	74 24                	je     f0102b27 <mem_init+0x19ef>
f0102b03:	c7 44 24 0c 5c 48 10 	movl   $0xf010485c,0xc(%esp)
f0102b0a:	f0 
f0102b0b:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102b12:	f0 
f0102b13:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102b1a:	00 
f0102b1b:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102b22:	e8 59 d5 ff ff       	call   f0100080 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b27:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b2e:	00 
f0102b2f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b36:	00 
f0102b37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b3b:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102b40:	89 04 24             	mov    %eax,(%esp)
f0102b43:	e8 6a e5 ff ff       	call   f01010b2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b48:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b4f:	02 02 02 
f0102b52:	74 24                	je     f0102b78 <mem_init+0x1a40>
f0102b54:	c7 44 24 0c 80 48 10 	movl   $0xf0104880,0xc(%esp)
f0102b5b:	f0 
f0102b5c:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102b63:	f0 
f0102b64:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102b6b:	00 
f0102b6c:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102b73:	e8 08 d5 ff ff       	call   f0100080 <_panic>
	assert(pp2->pp_ref == 1);
f0102b78:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b7d:	74 24                	je     f0102ba3 <mem_init+0x1a6b>
f0102b7f:	c7 44 24 0c 30 4b 10 	movl   $0xf0104b30,0xc(%esp)
f0102b86:	f0 
f0102b87:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102b8e:	f0 
f0102b8f:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102b96:	00 
f0102b97:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102b9e:	e8 dd d4 ff ff       	call   f0100080 <_panic>
	assert(pp1->pp_ref == 0);
f0102ba3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ba8:	74 24                	je     f0102bce <mem_init+0x1a96>
f0102baa:	c7 44 24 0c 9a 4b 10 	movl   $0xf0104b9a,0xc(%esp)
f0102bb1:	f0 
f0102bb2:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102bb9:	f0 
f0102bba:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102bc1:	00 
f0102bc2:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102bc9:	e8 b2 d4 ff ff       	call   f0100080 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bce:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bd5:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bd8:	89 d8                	mov    %ebx,%eax
f0102bda:	2b 05 6c f9 11 f0    	sub    0xf011f96c,%eax
f0102be0:	c1 f8 03             	sar    $0x3,%eax
f0102be3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102be6:	89 c2                	mov    %eax,%edx
f0102be8:	c1 ea 0c             	shr    $0xc,%edx
f0102beb:	3b 15 64 f9 11 f0    	cmp    0xf011f964,%edx
f0102bf1:	72 20                	jb     f0102c13 <mem_init+0x1adb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bf7:	c7 44 24 08 64 41 10 	movl   $0xf0104164,0x8(%esp)
f0102bfe:	f0 
f0102bff:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102c06:	00 
f0102c07:	c7 04 24 08 49 10 f0 	movl   $0xf0104908,(%esp)
f0102c0e:	e8 6d d4 ff ff       	call   f0100080 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c13:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c1a:	03 03 03 
f0102c1d:	74 24                	je     f0102c43 <mem_init+0x1b0b>
f0102c1f:	c7 44 24 0c a4 48 10 	movl   $0xf01048a4,0xc(%esp)
f0102c26:	f0 
f0102c27:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102c2e:	f0 
f0102c2f:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102c36:	00 
f0102c37:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102c3e:	e8 3d d4 ff ff       	call   f0100080 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c43:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c4a:	00 
f0102c4b:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102c50:	89 04 24             	mov    %eax,(%esp)
f0102c53:	e8 0a e4 ff ff       	call   f0101062 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c58:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c5d:	74 24                	je     f0102c83 <mem_init+0x1b4b>
f0102c5f:	c7 44 24 0c 68 4b 10 	movl   $0xf0104b68,0xc(%esp)
f0102c66:	f0 
f0102c67:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102c6e:	f0 
f0102c6f:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0102c76:	00 
f0102c77:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102c7e:	e8 fd d3 ff ff       	call   f0100080 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c83:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102c88:	8b 08                	mov    (%eax),%ecx
f0102c8a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c90:	89 f2                	mov    %esi,%edx
f0102c92:	2b 15 6c f9 11 f0    	sub    0xf011f96c,%edx
f0102c98:	c1 fa 03             	sar    $0x3,%edx
f0102c9b:	c1 e2 0c             	shl    $0xc,%edx
f0102c9e:	39 d1                	cmp    %edx,%ecx
f0102ca0:	74 24                	je     f0102cc6 <mem_init+0x1b8e>
f0102ca2:	c7 44 24 0c e8 43 10 	movl   $0xf01043e8,0xc(%esp)
f0102ca9:	f0 
f0102caa:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102cb1:	f0 
f0102cb2:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102cb9:	00 
f0102cba:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102cc1:	e8 ba d3 ff ff       	call   f0100080 <_panic>
	kern_pgdir[0] = 0;
f0102cc6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102ccc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cd1:	74 24                	je     f0102cf7 <mem_init+0x1bbf>
f0102cd3:	c7 44 24 0c 1f 4b 10 	movl   $0xf0104b1f,0xc(%esp)
f0102cda:	f0 
f0102cdb:	c7 44 24 08 22 49 10 	movl   $0xf0104922,0x8(%esp)
f0102ce2:	f0 
f0102ce3:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102cea:	00 
f0102ceb:	c7 04 24 fc 48 10 f0 	movl   $0xf01048fc,(%esp)
f0102cf2:	e8 89 d3 ff ff       	call   f0100080 <_panic>
	pp0->pp_ref = 0;
f0102cf7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cfd:	89 34 24             	mov    %esi,(%esp)
f0102d00:	e8 04 e1 ff ff       	call   f0100e09 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d05:	c7 04 24 d0 48 10 f0 	movl   $0xf01048d0,(%esp)
f0102d0c:	e8 79 00 00 00       	call   f0102d8a <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d11:	83 c4 3c             	add    $0x3c,%esp
f0102d14:	5b                   	pop    %ebx
f0102d15:	5e                   	pop    %esi
f0102d16:	5f                   	pop    %edi
f0102d17:	5d                   	pop    %ebp
f0102d18:	c3                   	ret    
f0102d19:	00 00                	add    %al,(%eax)
	...

f0102d1c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102d1c:	55                   	push   %ebp
f0102d1d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d1f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d24:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d27:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102d28:	b2 71                	mov    $0x71,%dl
f0102d2a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102d2b:	0f b6 c0             	movzbl %al,%eax
}
f0102d2e:	5d                   	pop    %ebp
f0102d2f:	c3                   	ret    

f0102d30 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d30:	55                   	push   %ebp
f0102d31:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d33:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d38:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d3b:	ee                   	out    %al,(%dx)
f0102d3c:	b2 71                	mov    $0x71,%dl
f0102d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d41:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d42:	5d                   	pop    %ebp
f0102d43:	c3                   	ret    

f0102d44 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d44:	55                   	push   %ebp
f0102d45:	89 e5                	mov    %esp,%ebp
f0102d47:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102d4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d4d:	89 04 24             	mov    %eax,(%esp)
f0102d50:	e8 3d d8 ff ff       	call   f0100592 <cputchar>
	*cnt++;
}
f0102d55:	c9                   	leave  
f0102d56:	c3                   	ret    

f0102d57 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d57:	55                   	push   %ebp
f0102d58:	89 e5                	mov    %esp,%ebp
f0102d5a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102d5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d67:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d6e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d79:	c7 04 24 44 2d 10 f0 	movl   $0xf0102d44,(%esp)
f0102d80:	e8 69 04 00 00       	call   f01031ee <vprintfmt>
	return cnt;
}
f0102d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d88:	c9                   	leave  
f0102d89:	c3                   	ret    

f0102d8a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d8a:	55                   	push   %ebp
f0102d8b:	89 e5                	mov    %esp,%ebp
f0102d8d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d90:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102d93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d97:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d9a:	89 04 24             	mov    %eax,(%esp)
f0102d9d:	e8 b5 ff ff ff       	call   f0102d57 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102da2:	c9                   	leave  
f0102da3:	c3                   	ret    

f0102da4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102da4:	55                   	push   %ebp
f0102da5:	89 e5                	mov    %esp,%ebp
f0102da7:	57                   	push   %edi
f0102da8:	56                   	push   %esi
f0102da9:	53                   	push   %ebx
f0102daa:	83 ec 10             	sub    $0x10,%esp
f0102dad:	89 c3                	mov    %eax,%ebx
f0102daf:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102db2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102db5:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102db8:	8b 0a                	mov    (%edx),%ecx
f0102dba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102dbd:	8b 00                	mov    (%eax),%eax
f0102dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102dc2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102dc9:	eb 77                	jmp    f0102e42 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0102dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102dce:	01 c8                	add    %ecx,%eax
f0102dd0:	bf 02 00 00 00       	mov    $0x2,%edi
f0102dd5:	99                   	cltd   
f0102dd6:	f7 ff                	idiv   %edi
f0102dd8:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102dda:	eb 01                	jmp    f0102ddd <stab_binsearch+0x39>
			m--;
f0102ddc:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102ddd:	39 ca                	cmp    %ecx,%edx
f0102ddf:	7c 1d                	jl     f0102dfe <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102de1:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102de4:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0102de9:	39 f7                	cmp    %esi,%edi
f0102deb:	75 ef                	jne    f0102ddc <stab_binsearch+0x38>
f0102ded:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102df0:	6b fa 0c             	imul   $0xc,%edx,%edi
f0102df3:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0102df7:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102dfa:	73 18                	jae    f0102e14 <stab_binsearch+0x70>
f0102dfc:	eb 05                	jmp    f0102e03 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102dfe:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0102e01:	eb 3f                	jmp    f0102e42 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102e03:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102e06:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0102e08:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e0b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e12:	eb 2e                	jmp    f0102e42 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102e14:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102e17:	76 15                	jbe    f0102e2e <stab_binsearch+0x8a>
			*region_right = m - 1;
f0102e19:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102e1c:	4f                   	dec    %edi
f0102e1d:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0102e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e23:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e25:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e2c:	eb 14                	jmp    f0102e42 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102e2e:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102e31:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102e34:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0102e36:	ff 45 0c             	incl   0xc(%ebp)
f0102e39:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e3b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102e42:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0102e45:	7e 84                	jle    f0102dcb <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102e47:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102e4b:	75 0d                	jne    f0102e5a <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0102e4d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e50:	8b 02                	mov    (%edx),%eax
f0102e52:	48                   	dec    %eax
f0102e53:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e56:	89 01                	mov    %eax,(%ecx)
f0102e58:	eb 22                	jmp    f0102e7c <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e5a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e5d:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e5f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e62:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e64:	eb 01                	jmp    f0102e67 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102e66:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e67:	39 c1                	cmp    %eax,%ecx
f0102e69:	7d 0c                	jge    f0102e77 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102e6b:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0102e6e:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0102e73:	39 f2                	cmp    %esi,%edx
f0102e75:	75 ef                	jne    f0102e66 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102e77:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e7a:	89 02                	mov    %eax,(%edx)
	}
}
f0102e7c:	83 c4 10             	add    $0x10,%esp
f0102e7f:	5b                   	pop    %ebx
f0102e80:	5e                   	pop    %esi
f0102e81:	5f                   	pop    %edi
f0102e82:	5d                   	pop    %ebp
f0102e83:	c3                   	ret    

f0102e84 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102e84:	55                   	push   %ebp
f0102e85:	89 e5                	mov    %esp,%ebp
f0102e87:	57                   	push   %edi
f0102e88:	56                   	push   %esi
f0102e89:	53                   	push   %ebx
f0102e8a:	83 ec 4c             	sub    $0x4c,%esp
f0102e8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102e93:	c7 03 23 4c 10 f0    	movl   $0xf0104c23,(%ebx)
	info->eip_line = 0;
f0102e99:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102ea0:	c7 43 08 23 4c 10 f0 	movl   $0xf0104c23,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102ea7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102eae:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102eb1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102eb8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ebe:	76 12                	jbe    f0102ed2 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ec0:	b8 3c 4a 11 f0       	mov    $0xf0114a3c,%eax
f0102ec5:	3d a9 b8 10 f0       	cmp    $0xf010b8a9,%eax
f0102eca:	0f 86 a7 01 00 00    	jbe    f0103077 <debuginfo_eip+0x1f3>
f0102ed0:	eb 1c                	jmp    f0102eee <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102ed2:	c7 44 24 08 2d 4c 10 	movl   $0xf0104c2d,0x8(%esp)
f0102ed9:	f0 
f0102eda:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102ee1:	00 
f0102ee2:	c7 04 24 3a 4c 10 f0 	movl   $0xf0104c3a,(%esp)
f0102ee9:	e8 92 d1 ff ff       	call   f0100080 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102eee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ef3:	80 3d 3b 4a 11 f0 00 	cmpb   $0x0,0xf0114a3b
f0102efa:	0f 85 83 01 00 00    	jne    f0103083 <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102f00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102f07:	b8 a8 b8 10 f0       	mov    $0xf010b8a8,%eax
f0102f0c:	2d 70 4e 10 f0       	sub    $0xf0104e70,%eax
f0102f11:	c1 f8 02             	sar    $0x2,%eax
f0102f14:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102f1a:	48                   	dec    %eax
f0102f1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102f1e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f22:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102f29:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102f2c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f2f:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f0102f34:	e8 6b fe ff ff       	call   f0102da4 <stab_binsearch>
	if (lfile == 0)
f0102f39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0102f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102f41:	85 d2                	test   %edx,%edx
f0102f43:	0f 84 3a 01 00 00    	je     f0103083 <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f49:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f52:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f56:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102f5d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f60:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f63:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f0102f68:	e8 37 fe ff ff       	call   f0102da4 <stab_binsearch>

	if (lfun <= rfun) {
f0102f6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102f70:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f73:	39 d0                	cmp    %edx,%eax
f0102f75:	7f 3e                	jg     f0102fb5 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102f77:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0102f7a:	8d b9 70 4e 10 f0    	lea    -0xfefb190(%ecx),%edi
f0102f80:	8b 89 70 4e 10 f0    	mov    -0xfefb190(%ecx),%ecx
f0102f86:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0102f89:	b9 3c 4a 11 f0       	mov    $0xf0114a3c,%ecx
f0102f8e:	81 e9 a9 b8 10 f0    	sub    $0xf010b8a9,%ecx
f0102f94:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0102f97:	73 0c                	jae    f0102fa5 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102f99:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0102f9c:	81 c1 a9 b8 10 f0    	add    $0xf010b8a9,%ecx
f0102fa2:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102fa5:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102fa8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102fab:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102fad:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102fb0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102fb3:	eb 0f                	jmp    f0102fc4 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102fb5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102fbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102fc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102fc4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102fcb:	00 
f0102fcc:	8b 43 08             	mov    0x8(%ebx),%eax
f0102fcf:	89 04 24             	mov    %eax,(%esp)
f0102fd2:	e8 3f 08 00 00       	call   f0103816 <strfind>
f0102fd7:	2b 43 08             	sub    0x8(%ebx),%eax
f0102fda:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
f0102fdd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102fe1:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102fe8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102feb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102fee:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f0102ff3:	e8 ac fd ff ff       	call   f0102da4 <stab_binsearch>
	if (lline > rline )
f0102ff8:	8b 55 d0             	mov    -0x30(%ebp),%edx
		return -1;	
f0102ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	
	stab_binsearch(stabs, &lline, &rline, N_SLINE , addr);
	if (lline > rline )
f0103000:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0103003:	7f 7e                	jg     f0103083 <debuginfo_eip+0x1ff>
		return -1;	
	info->eip_line = stabs[rline].n_desc;
f0103005:	6b d2 0c             	imul   $0xc,%edx,%edx
f0103008:	0f b7 82 76 4e 10 f0 	movzwl -0xfefb18a(%edx),%eax
f010300f:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103012:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103015:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103018:	eb 01                	jmp    f010301b <debuginfo_eip+0x197>
f010301a:	48                   	dec    %eax
f010301b:	89 c6                	mov    %eax,%esi
f010301d:	39 c7                	cmp    %eax,%edi
f010301f:	7f 26                	jg     f0103047 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0103021:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103024:	8d 0c 95 70 4e 10 f0 	lea    -0xfefb190(,%edx,4),%ecx
f010302b:	8a 51 04             	mov    0x4(%ecx),%dl
f010302e:	80 fa 84             	cmp    $0x84,%dl
f0103031:	74 58                	je     f010308b <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103033:	80 fa 64             	cmp    $0x64,%dl
f0103036:	75 e2                	jne    f010301a <debuginfo_eip+0x196>
f0103038:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f010303c:	74 dc                	je     f010301a <debuginfo_eip+0x196>
f010303e:	eb 4b                	jmp    f010308b <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103040:	05 a9 b8 10 f0       	add    $0xf010b8a9,%eax
f0103045:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103047:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010304a:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010304d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103052:	39 d1                	cmp    %edx,%ecx
f0103054:	7d 2d                	jge    f0103083 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0103056:	8d 41 01             	lea    0x1(%ecx),%eax
f0103059:	eb 03                	jmp    f010305e <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010305b:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010305e:	39 d0                	cmp    %edx,%eax
f0103060:	7d 1c                	jge    f010307e <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103062:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103065:	40                   	inc    %eax
f0103066:	80 3c 8d 74 4e 10 f0 	cmpb   $0xa0,-0xfefb18c(,%ecx,4)
f010306d:	a0 
f010306e:	74 eb                	je     f010305b <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103070:	b8 00 00 00 00       	mov    $0x0,%eax
f0103075:	eb 0c                	jmp    f0103083 <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103077:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010307c:	eb 05                	jmp    f0103083 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010307e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103083:	83 c4 4c             	add    $0x4c,%esp
f0103086:	5b                   	pop    %ebx
f0103087:	5e                   	pop    %esi
f0103088:	5f                   	pop    %edi
f0103089:	5d                   	pop    %ebp
f010308a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010308b:	6b f6 0c             	imul   $0xc,%esi,%esi
f010308e:	8b 86 70 4e 10 f0    	mov    -0xfefb190(%esi),%eax
f0103094:	ba 3c 4a 11 f0       	mov    $0xf0114a3c,%edx
f0103099:	81 ea a9 b8 10 f0    	sub    $0xf010b8a9,%edx
f010309f:	39 d0                	cmp    %edx,%eax
f01030a1:	72 9d                	jb     f0103040 <debuginfo_eip+0x1bc>
f01030a3:	eb a2                	jmp    f0103047 <debuginfo_eip+0x1c3>
f01030a5:	00 00                	add    %al,(%eax)
	...

f01030a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01030a8:	55                   	push   %ebp
f01030a9:	89 e5                	mov    %esp,%ebp
f01030ab:	57                   	push   %edi
f01030ac:	56                   	push   %esi
f01030ad:	53                   	push   %ebx
f01030ae:	83 ec 3c             	sub    $0x3c,%esp
f01030b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01030b4:	89 d7                	mov    %edx,%edi
f01030b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01030bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01030c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01030c5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01030c8:	85 c0                	test   %eax,%eax
f01030ca:	75 08                	jne    f01030d4 <printnum+0x2c>
f01030cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01030cf:	39 45 10             	cmp    %eax,0x10(%ebp)
f01030d2:	77 57                	ja     f010312b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01030d4:	89 74 24 10          	mov    %esi,0x10(%esp)
f01030d8:	4b                   	dec    %ebx
f01030d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01030dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01030e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030e4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01030e8:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01030ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01030f3:	00 
f01030f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01030f7:	89 04 24             	mov    %eax,(%esp)
f01030fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103101:	e8 1e 09 00 00       	call   f0103a24 <__udivdi3>
f0103106:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010310a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010310e:	89 04 24             	mov    %eax,(%esp)
f0103111:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103115:	89 fa                	mov    %edi,%edx
f0103117:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010311a:	e8 89 ff ff ff       	call   f01030a8 <printnum>
f010311f:	eb 0f                	jmp    f0103130 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103121:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103125:	89 34 24             	mov    %esi,(%esp)
f0103128:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010312b:	4b                   	dec    %ebx
f010312c:	85 db                	test   %ebx,%ebx
f010312e:	7f f1                	jg     f0103121 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103130:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103134:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103138:	8b 45 10             	mov    0x10(%ebp),%eax
f010313b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010313f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103146:	00 
f0103147:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010314a:	89 04 24             	mov    %eax,(%esp)
f010314d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103150:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103154:	e8 eb 09 00 00       	call   f0103b44 <__umoddi3>
f0103159:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010315d:	0f be 80 48 4c 10 f0 	movsbl -0xfefb3b8(%eax),%eax
f0103164:	89 04 24             	mov    %eax,(%esp)
f0103167:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010316a:	83 c4 3c             	add    $0x3c,%esp
f010316d:	5b                   	pop    %ebx
f010316e:	5e                   	pop    %esi
f010316f:	5f                   	pop    %edi
f0103170:	5d                   	pop    %ebp
f0103171:	c3                   	ret    

f0103172 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103172:	55                   	push   %ebp
f0103173:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103175:	83 fa 01             	cmp    $0x1,%edx
f0103178:	7e 0e                	jle    f0103188 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010317a:	8b 10                	mov    (%eax),%edx
f010317c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010317f:	89 08                	mov    %ecx,(%eax)
f0103181:	8b 02                	mov    (%edx),%eax
f0103183:	8b 52 04             	mov    0x4(%edx),%edx
f0103186:	eb 22                	jmp    f01031aa <getuint+0x38>
	else if (lflag)
f0103188:	85 d2                	test   %edx,%edx
f010318a:	74 10                	je     f010319c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010318c:	8b 10                	mov    (%eax),%edx
f010318e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103191:	89 08                	mov    %ecx,(%eax)
f0103193:	8b 02                	mov    (%edx),%eax
f0103195:	ba 00 00 00 00       	mov    $0x0,%edx
f010319a:	eb 0e                	jmp    f01031aa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010319c:	8b 10                	mov    (%eax),%edx
f010319e:	8d 4a 04             	lea    0x4(%edx),%ecx
f01031a1:	89 08                	mov    %ecx,(%eax)
f01031a3:	8b 02                	mov    (%edx),%eax
f01031a5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01031aa:	5d                   	pop    %ebp
f01031ab:	c3                   	ret    

f01031ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01031ac:	55                   	push   %ebp
f01031ad:	89 e5                	mov    %esp,%ebp
f01031af:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01031b2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01031b5:	8b 10                	mov    (%eax),%edx
f01031b7:	3b 50 04             	cmp    0x4(%eax),%edx
f01031ba:	73 08                	jae    f01031c4 <sprintputch+0x18>
		*b->buf++ = ch;
f01031bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01031bf:	88 0a                	mov    %cl,(%edx)
f01031c1:	42                   	inc    %edx
f01031c2:	89 10                	mov    %edx,(%eax)
}
f01031c4:	5d                   	pop    %ebp
f01031c5:	c3                   	ret    

f01031c6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01031c6:	55                   	push   %ebp
f01031c7:	89 e5                	mov    %esp,%ebp
f01031c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01031cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01031cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031d3:	8b 45 10             	mov    0x10(%ebp),%eax
f01031d6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e4:	89 04 24             	mov    %eax,(%esp)
f01031e7:	e8 02 00 00 00       	call   f01031ee <vprintfmt>
	va_end(ap);
}
f01031ec:	c9                   	leave  
f01031ed:	c3                   	ret    

f01031ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01031ee:	55                   	push   %ebp
f01031ef:	89 e5                	mov    %esp,%ebp
f01031f1:	57                   	push   %edi
f01031f2:	56                   	push   %esi
f01031f3:	53                   	push   %ebx
f01031f4:	83 ec 4c             	sub    $0x4c,%esp
f01031f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031fa:	8b 75 10             	mov    0x10(%ebp),%esi
f01031fd:	eb 12                	jmp    f0103211 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01031ff:	85 c0                	test   %eax,%eax
f0103201:	0f 84 6b 03 00 00    	je     f0103572 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0103207:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010320b:	89 04 24             	mov    %eax,(%esp)
f010320e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103211:	0f b6 06             	movzbl (%esi),%eax
f0103214:	46                   	inc    %esi
f0103215:	83 f8 25             	cmp    $0x25,%eax
f0103218:	75 e5                	jne    f01031ff <vprintfmt+0x11>
f010321a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f010321e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103225:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010322a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103231:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103236:	eb 26                	jmp    f010325e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103238:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010323b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010323f:	eb 1d                	jmp    f010325e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103241:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103244:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103248:	eb 14                	jmp    f010325e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010324a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f010324d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103254:	eb 08                	jmp    f010325e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103256:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103259:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010325e:	0f b6 06             	movzbl (%esi),%eax
f0103261:	8d 56 01             	lea    0x1(%esi),%edx
f0103264:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103267:	8a 16                	mov    (%esi),%dl
f0103269:	83 ea 23             	sub    $0x23,%edx
f010326c:	80 fa 55             	cmp    $0x55,%dl
f010326f:	0f 87 e1 02 00 00    	ja     f0103556 <vprintfmt+0x368>
f0103275:	0f b6 d2             	movzbl %dl,%edx
f0103278:	ff 24 95 e0 4c 10 f0 	jmp    *-0xfefb320(,%edx,4)
f010327f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103282:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103287:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010328a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010328e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103291:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103294:	83 fa 09             	cmp    $0x9,%edx
f0103297:	77 2a                	ja     f01032c3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103299:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010329a:	eb eb                	jmp    f0103287 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010329c:	8b 45 14             	mov    0x14(%ebp),%eax
f010329f:	8d 50 04             	lea    0x4(%eax),%edx
f01032a2:	89 55 14             	mov    %edx,0x14(%ebp)
f01032a5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01032aa:	eb 17                	jmp    f01032c3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f01032ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032b0:	78 98                	js     f010324a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01032b5:	eb a7                	jmp    f010325e <vprintfmt+0x70>
f01032b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01032ba:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01032c1:	eb 9b                	jmp    f010325e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f01032c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032c7:	79 95                	jns    f010325e <vprintfmt+0x70>
f01032c9:	eb 8b                	jmp    f0103256 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01032cb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01032cf:	eb 8d                	jmp    f010325e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01032d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01032d4:	8d 50 04             	lea    0x4(%eax),%edx
f01032d7:	89 55 14             	mov    %edx,0x14(%ebp)
f01032da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032de:	8b 00                	mov    (%eax),%eax
f01032e0:	89 04 24             	mov    %eax,(%esp)
f01032e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01032e9:	e9 23 ff ff ff       	jmp    f0103211 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01032ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01032f1:	8d 50 04             	lea    0x4(%eax),%edx
f01032f4:	89 55 14             	mov    %edx,0x14(%ebp)
f01032f7:	8b 00                	mov    (%eax),%eax
f01032f9:	85 c0                	test   %eax,%eax
f01032fb:	79 02                	jns    f01032ff <vprintfmt+0x111>
f01032fd:	f7 d8                	neg    %eax
f01032ff:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103301:	83 f8 07             	cmp    $0x7,%eax
f0103304:	7f 0b                	jg     f0103311 <vprintfmt+0x123>
f0103306:	8b 04 85 40 4e 10 f0 	mov    -0xfefb1c0(,%eax,4),%eax
f010330d:	85 c0                	test   %eax,%eax
f010330f:	75 23                	jne    f0103334 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0103311:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103315:	c7 44 24 08 60 4c 10 	movl   $0xf0104c60,0x8(%esp)
f010331c:	f0 
f010331d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103321:	8b 45 08             	mov    0x8(%ebp),%eax
f0103324:	89 04 24             	mov    %eax,(%esp)
f0103327:	e8 9a fe ff ff       	call   f01031c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010332c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010332f:	e9 dd fe ff ff       	jmp    f0103211 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103334:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103338:	c7 44 24 08 34 49 10 	movl   $0xf0104934,0x8(%esp)
f010333f:	f0 
f0103340:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103344:	8b 55 08             	mov    0x8(%ebp),%edx
f0103347:	89 14 24             	mov    %edx,(%esp)
f010334a:	e8 77 fe ff ff       	call   f01031c6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010334f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103352:	e9 ba fe ff ff       	jmp    f0103211 <vprintfmt+0x23>
f0103357:	89 f9                	mov    %edi,%ecx
f0103359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010335c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010335f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103362:	8d 50 04             	lea    0x4(%eax),%edx
f0103365:	89 55 14             	mov    %edx,0x14(%ebp)
f0103368:	8b 30                	mov    (%eax),%esi
f010336a:	85 f6                	test   %esi,%esi
f010336c:	75 05                	jne    f0103373 <vprintfmt+0x185>
				p = "(null)";
f010336e:	be 59 4c 10 f0       	mov    $0xf0104c59,%esi
			if (width > 0 && padc != '-')
f0103373:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103377:	0f 8e 84 00 00 00    	jle    f0103401 <vprintfmt+0x213>
f010337d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103381:	74 7e                	je     f0103401 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103383:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103387:	89 34 24             	mov    %esi,(%esp)
f010338a:	e8 53 03 00 00       	call   f01036e2 <strnlen>
f010338f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103392:	29 c2                	sub    %eax,%edx
f0103394:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0103397:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010339b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010339e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01033a1:	89 de                	mov    %ebx,%esi
f01033a3:	89 d3                	mov    %edx,%ebx
f01033a5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01033a7:	eb 0b                	jmp    f01033b4 <vprintfmt+0x1c6>
					putch(padc, putdat);
f01033a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033ad:	89 3c 24             	mov    %edi,(%esp)
f01033b0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01033b3:	4b                   	dec    %ebx
f01033b4:	85 db                	test   %ebx,%ebx
f01033b6:	7f f1                	jg     f01033a9 <vprintfmt+0x1bb>
f01033b8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01033bb:	89 f3                	mov    %esi,%ebx
f01033bd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f01033c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c3:	85 c0                	test   %eax,%eax
f01033c5:	79 05                	jns    f01033cc <vprintfmt+0x1de>
f01033c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01033cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01033cf:	29 c2                	sub    %eax,%edx
f01033d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01033d4:	eb 2b                	jmp    f0103401 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01033d6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01033da:	74 18                	je     f01033f4 <vprintfmt+0x206>
f01033dc:	8d 50 e0             	lea    -0x20(%eax),%edx
f01033df:	83 fa 5e             	cmp    $0x5e,%edx
f01033e2:	76 10                	jbe    f01033f4 <vprintfmt+0x206>
					putch('?', putdat);
f01033e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033e8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01033ef:	ff 55 08             	call   *0x8(%ebp)
f01033f2:	eb 0a                	jmp    f01033fe <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01033f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033f8:	89 04 24             	mov    %eax,(%esp)
f01033fb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033fe:	ff 4d e4             	decl   -0x1c(%ebp)
f0103401:	0f be 06             	movsbl (%esi),%eax
f0103404:	46                   	inc    %esi
f0103405:	85 c0                	test   %eax,%eax
f0103407:	74 21                	je     f010342a <vprintfmt+0x23c>
f0103409:	85 ff                	test   %edi,%edi
f010340b:	78 c9                	js     f01033d6 <vprintfmt+0x1e8>
f010340d:	4f                   	dec    %edi
f010340e:	79 c6                	jns    f01033d6 <vprintfmt+0x1e8>
f0103410:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103413:	89 de                	mov    %ebx,%esi
f0103415:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103418:	eb 18                	jmp    f0103432 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010341a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010341e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103425:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103427:	4b                   	dec    %ebx
f0103428:	eb 08                	jmp    f0103432 <vprintfmt+0x244>
f010342a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010342d:	89 de                	mov    %ebx,%esi
f010342f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103432:	85 db                	test   %ebx,%ebx
f0103434:	7f e4                	jg     f010341a <vprintfmt+0x22c>
f0103436:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103439:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010343b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010343e:	e9 ce fd ff ff       	jmp    f0103211 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103443:	83 f9 01             	cmp    $0x1,%ecx
f0103446:	7e 10                	jle    f0103458 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0103448:	8b 45 14             	mov    0x14(%ebp),%eax
f010344b:	8d 50 08             	lea    0x8(%eax),%edx
f010344e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103451:	8b 30                	mov    (%eax),%esi
f0103453:	8b 78 04             	mov    0x4(%eax),%edi
f0103456:	eb 26                	jmp    f010347e <vprintfmt+0x290>
	else if (lflag)
f0103458:	85 c9                	test   %ecx,%ecx
f010345a:	74 12                	je     f010346e <vprintfmt+0x280>
		return va_arg(*ap, long);
f010345c:	8b 45 14             	mov    0x14(%ebp),%eax
f010345f:	8d 50 04             	lea    0x4(%eax),%edx
f0103462:	89 55 14             	mov    %edx,0x14(%ebp)
f0103465:	8b 30                	mov    (%eax),%esi
f0103467:	89 f7                	mov    %esi,%edi
f0103469:	c1 ff 1f             	sar    $0x1f,%edi
f010346c:	eb 10                	jmp    f010347e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010346e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103471:	8d 50 04             	lea    0x4(%eax),%edx
f0103474:	89 55 14             	mov    %edx,0x14(%ebp)
f0103477:	8b 30                	mov    (%eax),%esi
f0103479:	89 f7                	mov    %esi,%edi
f010347b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010347e:	85 ff                	test   %edi,%edi
f0103480:	78 0a                	js     f010348c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103482:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103487:	e9 8c 00 00 00       	jmp    f0103518 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010348c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103490:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103497:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010349a:	f7 de                	neg    %esi
f010349c:	83 d7 00             	adc    $0x0,%edi
f010349f:	f7 df                	neg    %edi
			}
			base = 10;
f01034a1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01034a6:	eb 70                	jmp    f0103518 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01034a8:	89 ca                	mov    %ecx,%edx
f01034aa:	8d 45 14             	lea    0x14(%ebp),%eax
f01034ad:	e8 c0 fc ff ff       	call   f0103172 <getuint>
f01034b2:	89 c6                	mov    %eax,%esi
f01034b4:	89 d7                	mov    %edx,%edi
			base = 10;
f01034b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01034bb:	eb 5b                	jmp    f0103518 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
f01034bd:	89 ca                	mov    %ecx,%edx
f01034bf:	8d 45 14             	lea    0x14(%ebp),%eax
f01034c2:	e8 ab fc ff ff       	call   f0103172 <getuint>
f01034c7:	89 c6                	mov    %eax,%esi
f01034c9:	89 d7                	mov    %edx,%edi
			base = 8;
f01034cb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01034d0:	eb 46                	jmp    f0103518 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
f01034d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034d6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01034dd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01034e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034e4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01034eb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01034ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f1:	8d 50 04             	lea    0x4(%eax),%edx
f01034f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01034f7:	8b 30                	mov    (%eax),%esi
f01034f9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01034fe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103503:	eb 13                	jmp    f0103518 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103505:	89 ca                	mov    %ecx,%edx
f0103507:	8d 45 14             	lea    0x14(%ebp),%eax
f010350a:	e8 63 fc ff ff       	call   f0103172 <getuint>
f010350f:	89 c6                	mov    %eax,%esi
f0103511:	89 d7                	mov    %edx,%edi
			base = 16;
f0103513:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103518:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f010351c:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103520:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103523:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103527:	89 44 24 08          	mov    %eax,0x8(%esp)
f010352b:	89 34 24             	mov    %esi,(%esp)
f010352e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103532:	89 da                	mov    %ebx,%edx
f0103534:	8b 45 08             	mov    0x8(%ebp),%eax
f0103537:	e8 6c fb ff ff       	call   f01030a8 <printnum>
			break;
f010353c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010353f:	e9 cd fc ff ff       	jmp    f0103211 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103544:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103548:	89 04 24             	mov    %eax,(%esp)
f010354b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010354e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103551:	e9 bb fc ff ff       	jmp    f0103211 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103556:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010355a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103561:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103564:	eb 01                	jmp    f0103567 <vprintfmt+0x379>
f0103566:	4e                   	dec    %esi
f0103567:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010356b:	75 f9                	jne    f0103566 <vprintfmt+0x378>
f010356d:	e9 9f fc ff ff       	jmp    f0103211 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103572:	83 c4 4c             	add    $0x4c,%esp
f0103575:	5b                   	pop    %ebx
f0103576:	5e                   	pop    %esi
f0103577:	5f                   	pop    %edi
f0103578:	5d                   	pop    %ebp
f0103579:	c3                   	ret    

f010357a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010357a:	55                   	push   %ebp
f010357b:	89 e5                	mov    %esp,%ebp
f010357d:	83 ec 28             	sub    $0x28,%esp
f0103580:	8b 45 08             	mov    0x8(%ebp),%eax
f0103583:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103586:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103589:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010358d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103597:	85 c0                	test   %eax,%eax
f0103599:	74 30                	je     f01035cb <vsnprintf+0x51>
f010359b:	85 d2                	test   %edx,%edx
f010359d:	7e 33                	jle    f01035d2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010359f:	8b 45 14             	mov    0x14(%ebp),%eax
f01035a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01035a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01035b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035b4:	c7 04 24 ac 31 10 f0 	movl   $0xf01031ac,(%esp)
f01035bb:	e8 2e fc ff ff       	call   f01031ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01035c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01035c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01035c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01035c9:	eb 0c                	jmp    f01035d7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01035cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01035d0:	eb 05                	jmp    f01035d7 <vsnprintf+0x5d>
f01035d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01035d7:	c9                   	leave  
f01035d8:	c3                   	ret    

f01035d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01035d9:	55                   	push   %ebp
f01035da:	89 e5                	mov    %esp,%ebp
f01035dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01035df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01035e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035e6:	8b 45 10             	mov    0x10(%ebp),%eax
f01035e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01035f7:	89 04 24             	mov    %eax,(%esp)
f01035fa:	e8 7b ff ff ff       	call   f010357a <vsnprintf>
	va_end(ap);

	return rc;
}
f01035ff:	c9                   	leave  
f0103600:	c3                   	ret    
f0103601:	00 00                	add    %al,(%eax)
	...

f0103604 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103604:	55                   	push   %ebp
f0103605:	89 e5                	mov    %esp,%ebp
f0103607:	57                   	push   %edi
f0103608:	56                   	push   %esi
f0103609:	53                   	push   %ebx
f010360a:	83 ec 1c             	sub    $0x1c,%esp
f010360d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103610:	85 c0                	test   %eax,%eax
f0103612:	74 10                	je     f0103624 <readline+0x20>
		cprintf("%s", prompt);
f0103614:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103618:	c7 04 24 34 49 10 f0 	movl   $0xf0104934,(%esp)
f010361f:	e8 66 f7 ff ff       	call   f0102d8a <cprintf>

	i = 0;
	echoing = iscons(0);
f0103624:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010362b:	e8 83 cf ff ff       	call   f01005b3 <iscons>
f0103630:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103632:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103637:	e8 66 cf ff ff       	call   f01005a2 <getchar>
f010363c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010363e:	85 c0                	test   %eax,%eax
f0103640:	79 17                	jns    f0103659 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103642:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103646:	c7 04 24 60 4e 10 f0 	movl   $0xf0104e60,(%esp)
f010364d:	e8 38 f7 ff ff       	call   f0102d8a <cprintf>
			return NULL;
f0103652:	b8 00 00 00 00       	mov    $0x0,%eax
f0103657:	eb 69                	jmp    f01036c2 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103659:	83 f8 08             	cmp    $0x8,%eax
f010365c:	74 05                	je     f0103663 <readline+0x5f>
f010365e:	83 f8 7f             	cmp    $0x7f,%eax
f0103661:	75 17                	jne    f010367a <readline+0x76>
f0103663:	85 f6                	test   %esi,%esi
f0103665:	7e 13                	jle    f010367a <readline+0x76>
			if (echoing)
f0103667:	85 ff                	test   %edi,%edi
f0103669:	74 0c                	je     f0103677 <readline+0x73>
				cputchar('\b');
f010366b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103672:	e8 1b cf ff ff       	call   f0100592 <cputchar>
			i--;
f0103677:	4e                   	dec    %esi
f0103678:	eb bd                	jmp    f0103637 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010367a:	83 fb 1f             	cmp    $0x1f,%ebx
f010367d:	7e 1d                	jle    f010369c <readline+0x98>
f010367f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103685:	7f 15                	jg     f010369c <readline+0x98>
			if (echoing)
f0103687:	85 ff                	test   %edi,%edi
f0103689:	74 08                	je     f0103693 <readline+0x8f>
				cputchar(c);
f010368b:	89 1c 24             	mov    %ebx,(%esp)
f010368e:	e8 ff ce ff ff       	call   f0100592 <cputchar>
			buf[i++] = c;
f0103693:	88 9e 60 f5 11 f0    	mov    %bl,-0xfee0aa0(%esi)
f0103699:	46                   	inc    %esi
f010369a:	eb 9b                	jmp    f0103637 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010369c:	83 fb 0a             	cmp    $0xa,%ebx
f010369f:	74 05                	je     f01036a6 <readline+0xa2>
f01036a1:	83 fb 0d             	cmp    $0xd,%ebx
f01036a4:	75 91                	jne    f0103637 <readline+0x33>
			if (echoing)
f01036a6:	85 ff                	test   %edi,%edi
f01036a8:	74 0c                	je     f01036b6 <readline+0xb2>
				cputchar('\n');
f01036aa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01036b1:	e8 dc ce ff ff       	call   f0100592 <cputchar>
			buf[i] = 0;
f01036b6:	c6 86 60 f5 11 f0 00 	movb   $0x0,-0xfee0aa0(%esi)
			return buf;
f01036bd:	b8 60 f5 11 f0       	mov    $0xf011f560,%eax
		}
	}
}
f01036c2:	83 c4 1c             	add    $0x1c,%esp
f01036c5:	5b                   	pop    %ebx
f01036c6:	5e                   	pop    %esi
f01036c7:	5f                   	pop    %edi
f01036c8:	5d                   	pop    %ebp
f01036c9:	c3                   	ret    
	...

f01036cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01036cc:	55                   	push   %ebp
f01036cd:	89 e5                	mov    %esp,%ebp
f01036cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01036d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01036d7:	eb 01                	jmp    f01036da <strlen+0xe>
		n++;
f01036d9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01036da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01036de:	75 f9                	jne    f01036d9 <strlen+0xd>
		n++;
	return n;
}
f01036e0:	5d                   	pop    %ebp
f01036e1:	c3                   	ret    

f01036e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01036e2:	55                   	push   %ebp
f01036e3:	89 e5                	mov    %esp,%ebp
f01036e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01036e8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f0:	eb 01                	jmp    f01036f3 <strnlen+0x11>
		n++;
f01036f2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036f3:	39 d0                	cmp    %edx,%eax
f01036f5:	74 06                	je     f01036fd <strnlen+0x1b>
f01036f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01036fb:	75 f5                	jne    f01036f2 <strnlen+0x10>
		n++;
	return n;
}
f01036fd:	5d                   	pop    %ebp
f01036fe:	c3                   	ret    

f01036ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	53                   	push   %ebx
f0103703:	8b 45 08             	mov    0x8(%ebp),%eax
f0103706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103709:	ba 00 00 00 00       	mov    $0x0,%edx
f010370e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103711:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103714:	42                   	inc    %edx
f0103715:	84 c9                	test   %cl,%cl
f0103717:	75 f5                	jne    f010370e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103719:	5b                   	pop    %ebx
f010371a:	5d                   	pop    %ebp
f010371b:	c3                   	ret    

f010371c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010371c:	55                   	push   %ebp
f010371d:	89 e5                	mov    %esp,%ebp
f010371f:	53                   	push   %ebx
f0103720:	83 ec 08             	sub    $0x8,%esp
f0103723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103726:	89 1c 24             	mov    %ebx,(%esp)
f0103729:	e8 9e ff ff ff       	call   f01036cc <strlen>
	strcpy(dst + len, src);
f010372e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103731:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103735:	01 d8                	add    %ebx,%eax
f0103737:	89 04 24             	mov    %eax,(%esp)
f010373a:	e8 c0 ff ff ff       	call   f01036ff <strcpy>
	return dst;
}
f010373f:	89 d8                	mov    %ebx,%eax
f0103741:	83 c4 08             	add    $0x8,%esp
f0103744:	5b                   	pop    %ebx
f0103745:	5d                   	pop    %ebp
f0103746:	c3                   	ret    

f0103747 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103747:	55                   	push   %ebp
f0103748:	89 e5                	mov    %esp,%ebp
f010374a:	56                   	push   %esi
f010374b:	53                   	push   %ebx
f010374c:	8b 45 08             	mov    0x8(%ebp),%eax
f010374f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103752:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103755:	b9 00 00 00 00       	mov    $0x0,%ecx
f010375a:	eb 0c                	jmp    f0103768 <strncpy+0x21>
		*dst++ = *src;
f010375c:	8a 1a                	mov    (%edx),%bl
f010375e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103761:	80 3a 01             	cmpb   $0x1,(%edx)
f0103764:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103767:	41                   	inc    %ecx
f0103768:	39 f1                	cmp    %esi,%ecx
f010376a:	75 f0                	jne    f010375c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010376c:	5b                   	pop    %ebx
f010376d:	5e                   	pop    %esi
f010376e:	5d                   	pop    %ebp
f010376f:	c3                   	ret    

f0103770 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103770:	55                   	push   %ebp
f0103771:	89 e5                	mov    %esp,%ebp
f0103773:	56                   	push   %esi
f0103774:	53                   	push   %ebx
f0103775:	8b 75 08             	mov    0x8(%ebp),%esi
f0103778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010377b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010377e:	85 d2                	test   %edx,%edx
f0103780:	75 0a                	jne    f010378c <strlcpy+0x1c>
f0103782:	89 f0                	mov    %esi,%eax
f0103784:	eb 1a                	jmp    f01037a0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103786:	88 18                	mov    %bl,(%eax)
f0103788:	40                   	inc    %eax
f0103789:	41                   	inc    %ecx
f010378a:	eb 02                	jmp    f010378e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010378c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010378e:	4a                   	dec    %edx
f010378f:	74 0a                	je     f010379b <strlcpy+0x2b>
f0103791:	8a 19                	mov    (%ecx),%bl
f0103793:	84 db                	test   %bl,%bl
f0103795:	75 ef                	jne    f0103786 <strlcpy+0x16>
f0103797:	89 c2                	mov    %eax,%edx
f0103799:	eb 02                	jmp    f010379d <strlcpy+0x2d>
f010379b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010379d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01037a0:	29 f0                	sub    %esi,%eax
}
f01037a2:	5b                   	pop    %ebx
f01037a3:	5e                   	pop    %esi
f01037a4:	5d                   	pop    %ebp
f01037a5:	c3                   	ret    

f01037a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01037a6:	55                   	push   %ebp
f01037a7:	89 e5                	mov    %esp,%ebp
f01037a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01037af:	eb 02                	jmp    f01037b3 <strcmp+0xd>
		p++, q++;
f01037b1:	41                   	inc    %ecx
f01037b2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01037b3:	8a 01                	mov    (%ecx),%al
f01037b5:	84 c0                	test   %al,%al
f01037b7:	74 04                	je     f01037bd <strcmp+0x17>
f01037b9:	3a 02                	cmp    (%edx),%al
f01037bb:	74 f4                	je     f01037b1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01037bd:	0f b6 c0             	movzbl %al,%eax
f01037c0:	0f b6 12             	movzbl (%edx),%edx
f01037c3:	29 d0                	sub    %edx,%eax
}
f01037c5:	5d                   	pop    %ebp
f01037c6:	c3                   	ret    

f01037c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01037c7:	55                   	push   %ebp
f01037c8:	89 e5                	mov    %esp,%ebp
f01037ca:	53                   	push   %ebx
f01037cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01037ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01037d1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01037d4:	eb 03                	jmp    f01037d9 <strncmp+0x12>
		n--, p++, q++;
f01037d6:	4a                   	dec    %edx
f01037d7:	40                   	inc    %eax
f01037d8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01037d9:	85 d2                	test   %edx,%edx
f01037db:	74 14                	je     f01037f1 <strncmp+0x2a>
f01037dd:	8a 18                	mov    (%eax),%bl
f01037df:	84 db                	test   %bl,%bl
f01037e1:	74 04                	je     f01037e7 <strncmp+0x20>
f01037e3:	3a 19                	cmp    (%ecx),%bl
f01037e5:	74 ef                	je     f01037d6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01037e7:	0f b6 00             	movzbl (%eax),%eax
f01037ea:	0f b6 11             	movzbl (%ecx),%edx
f01037ed:	29 d0                	sub    %edx,%eax
f01037ef:	eb 05                	jmp    f01037f6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01037f1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01037f6:	5b                   	pop    %ebx
f01037f7:	5d                   	pop    %ebp
f01037f8:	c3                   	ret    

f01037f9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01037f9:	55                   	push   %ebp
f01037fa:	89 e5                	mov    %esp,%ebp
f01037fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01037ff:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103802:	eb 05                	jmp    f0103809 <strchr+0x10>
		if (*s == c)
f0103804:	38 ca                	cmp    %cl,%dl
f0103806:	74 0c                	je     f0103814 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103808:	40                   	inc    %eax
f0103809:	8a 10                	mov    (%eax),%dl
f010380b:	84 d2                	test   %dl,%dl
f010380d:	75 f5                	jne    f0103804 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f010380f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103814:	5d                   	pop    %ebp
f0103815:	c3                   	ret    

f0103816 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103816:	55                   	push   %ebp
f0103817:	89 e5                	mov    %esp,%ebp
f0103819:	8b 45 08             	mov    0x8(%ebp),%eax
f010381c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010381f:	eb 05                	jmp    f0103826 <strfind+0x10>
		if (*s == c)
f0103821:	38 ca                	cmp    %cl,%dl
f0103823:	74 07                	je     f010382c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103825:	40                   	inc    %eax
f0103826:	8a 10                	mov    (%eax),%dl
f0103828:	84 d2                	test   %dl,%dl
f010382a:	75 f5                	jne    f0103821 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f010382c:	5d                   	pop    %ebp
f010382d:	c3                   	ret    

f010382e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010382e:	55                   	push   %ebp
f010382f:	89 e5                	mov    %esp,%ebp
f0103831:	57                   	push   %edi
f0103832:	56                   	push   %esi
f0103833:	53                   	push   %ebx
f0103834:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103837:	8b 45 0c             	mov    0xc(%ebp),%eax
f010383a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010383d:	85 c9                	test   %ecx,%ecx
f010383f:	74 30                	je     f0103871 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103841:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103847:	75 25                	jne    f010386e <memset+0x40>
f0103849:	f6 c1 03             	test   $0x3,%cl
f010384c:	75 20                	jne    f010386e <memset+0x40>
		c &= 0xFF;
f010384e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103851:	89 d3                	mov    %edx,%ebx
f0103853:	c1 e3 08             	shl    $0x8,%ebx
f0103856:	89 d6                	mov    %edx,%esi
f0103858:	c1 e6 18             	shl    $0x18,%esi
f010385b:	89 d0                	mov    %edx,%eax
f010385d:	c1 e0 10             	shl    $0x10,%eax
f0103860:	09 f0                	or     %esi,%eax
f0103862:	09 d0                	or     %edx,%eax
f0103864:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103866:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103869:	fc                   	cld    
f010386a:	f3 ab                	rep stos %eax,%es:(%edi)
f010386c:	eb 03                	jmp    f0103871 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010386e:	fc                   	cld    
f010386f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103871:	89 f8                	mov    %edi,%eax
f0103873:	5b                   	pop    %ebx
f0103874:	5e                   	pop    %esi
f0103875:	5f                   	pop    %edi
f0103876:	5d                   	pop    %ebp
f0103877:	c3                   	ret    

f0103878 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103878:	55                   	push   %ebp
f0103879:	89 e5                	mov    %esp,%ebp
f010387b:	57                   	push   %edi
f010387c:	56                   	push   %esi
f010387d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103880:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103886:	39 c6                	cmp    %eax,%esi
f0103888:	73 34                	jae    f01038be <memmove+0x46>
f010388a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010388d:	39 d0                	cmp    %edx,%eax
f010388f:	73 2d                	jae    f01038be <memmove+0x46>
		s += n;
		d += n;
f0103891:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103894:	f6 c2 03             	test   $0x3,%dl
f0103897:	75 1b                	jne    f01038b4 <memmove+0x3c>
f0103899:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010389f:	75 13                	jne    f01038b4 <memmove+0x3c>
f01038a1:	f6 c1 03             	test   $0x3,%cl
f01038a4:	75 0e                	jne    f01038b4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01038a6:	83 ef 04             	sub    $0x4,%edi
f01038a9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01038ac:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01038af:	fd                   	std    
f01038b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038b2:	eb 07                	jmp    f01038bb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01038b4:	4f                   	dec    %edi
f01038b5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01038b8:	fd                   	std    
f01038b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01038bb:	fc                   	cld    
f01038bc:	eb 20                	jmp    f01038de <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01038be:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01038c4:	75 13                	jne    f01038d9 <memmove+0x61>
f01038c6:	a8 03                	test   $0x3,%al
f01038c8:	75 0f                	jne    f01038d9 <memmove+0x61>
f01038ca:	f6 c1 03             	test   $0x3,%cl
f01038cd:	75 0a                	jne    f01038d9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01038cf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01038d2:	89 c7                	mov    %eax,%edi
f01038d4:	fc                   	cld    
f01038d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038d7:	eb 05                	jmp    f01038de <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01038d9:	89 c7                	mov    %eax,%edi
f01038db:	fc                   	cld    
f01038dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01038de:	5e                   	pop    %esi
f01038df:	5f                   	pop    %edi
f01038e0:	5d                   	pop    %ebp
f01038e1:	c3                   	ret    

f01038e2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01038e2:	55                   	push   %ebp
f01038e3:	89 e5                	mov    %esp,%ebp
f01038e5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01038e8:	8b 45 10             	mov    0x10(%ebp),%eax
f01038eb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01038f9:	89 04 24             	mov    %eax,(%esp)
f01038fc:	e8 77 ff ff ff       	call   f0103878 <memmove>
}
f0103901:	c9                   	leave  
f0103902:	c3                   	ret    

f0103903 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103903:	55                   	push   %ebp
f0103904:	89 e5                	mov    %esp,%ebp
f0103906:	57                   	push   %edi
f0103907:	56                   	push   %esi
f0103908:	53                   	push   %ebx
f0103909:	8b 7d 08             	mov    0x8(%ebp),%edi
f010390c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010390f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103912:	ba 00 00 00 00       	mov    $0x0,%edx
f0103917:	eb 16                	jmp    f010392f <memcmp+0x2c>
		if (*s1 != *s2)
f0103919:	8a 04 17             	mov    (%edi,%edx,1),%al
f010391c:	42                   	inc    %edx
f010391d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0103921:	38 c8                	cmp    %cl,%al
f0103923:	74 0a                	je     f010392f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0103925:	0f b6 c0             	movzbl %al,%eax
f0103928:	0f b6 c9             	movzbl %cl,%ecx
f010392b:	29 c8                	sub    %ecx,%eax
f010392d:	eb 09                	jmp    f0103938 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010392f:	39 da                	cmp    %ebx,%edx
f0103931:	75 e6                	jne    f0103919 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103933:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103938:	5b                   	pop    %ebx
f0103939:	5e                   	pop    %esi
f010393a:	5f                   	pop    %edi
f010393b:	5d                   	pop    %ebp
f010393c:	c3                   	ret    

f010393d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010393d:	55                   	push   %ebp
f010393e:	89 e5                	mov    %esp,%ebp
f0103940:	8b 45 08             	mov    0x8(%ebp),%eax
f0103943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103946:	89 c2                	mov    %eax,%edx
f0103948:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010394b:	eb 05                	jmp    f0103952 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010394d:	38 08                	cmp    %cl,(%eax)
f010394f:	74 05                	je     f0103956 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103951:	40                   	inc    %eax
f0103952:	39 d0                	cmp    %edx,%eax
f0103954:	72 f7                	jb     f010394d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103956:	5d                   	pop    %ebp
f0103957:	c3                   	ret    

f0103958 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103958:	55                   	push   %ebp
f0103959:	89 e5                	mov    %esp,%ebp
f010395b:	57                   	push   %edi
f010395c:	56                   	push   %esi
f010395d:	53                   	push   %ebx
f010395e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103961:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103964:	eb 01                	jmp    f0103967 <strtol+0xf>
		s++;
f0103966:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103967:	8a 02                	mov    (%edx),%al
f0103969:	3c 20                	cmp    $0x20,%al
f010396b:	74 f9                	je     f0103966 <strtol+0xe>
f010396d:	3c 09                	cmp    $0x9,%al
f010396f:	74 f5                	je     f0103966 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103971:	3c 2b                	cmp    $0x2b,%al
f0103973:	75 08                	jne    f010397d <strtol+0x25>
		s++;
f0103975:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103976:	bf 00 00 00 00       	mov    $0x0,%edi
f010397b:	eb 13                	jmp    f0103990 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010397d:	3c 2d                	cmp    $0x2d,%al
f010397f:	75 0a                	jne    f010398b <strtol+0x33>
		s++, neg = 1;
f0103981:	8d 52 01             	lea    0x1(%edx),%edx
f0103984:	bf 01 00 00 00       	mov    $0x1,%edi
f0103989:	eb 05                	jmp    f0103990 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010398b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103990:	85 db                	test   %ebx,%ebx
f0103992:	74 05                	je     f0103999 <strtol+0x41>
f0103994:	83 fb 10             	cmp    $0x10,%ebx
f0103997:	75 28                	jne    f01039c1 <strtol+0x69>
f0103999:	8a 02                	mov    (%edx),%al
f010399b:	3c 30                	cmp    $0x30,%al
f010399d:	75 10                	jne    f01039af <strtol+0x57>
f010399f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01039a3:	75 0a                	jne    f01039af <strtol+0x57>
		s += 2, base = 16;
f01039a5:	83 c2 02             	add    $0x2,%edx
f01039a8:	bb 10 00 00 00       	mov    $0x10,%ebx
f01039ad:	eb 12                	jmp    f01039c1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01039af:	85 db                	test   %ebx,%ebx
f01039b1:	75 0e                	jne    f01039c1 <strtol+0x69>
f01039b3:	3c 30                	cmp    $0x30,%al
f01039b5:	75 05                	jne    f01039bc <strtol+0x64>
		s++, base = 8;
f01039b7:	42                   	inc    %edx
f01039b8:	b3 08                	mov    $0x8,%bl
f01039ba:	eb 05                	jmp    f01039c1 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01039bc:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01039c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01039c6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01039c8:	8a 0a                	mov    (%edx),%cl
f01039ca:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01039cd:	80 fb 09             	cmp    $0x9,%bl
f01039d0:	77 08                	ja     f01039da <strtol+0x82>
			dig = *s - '0';
f01039d2:	0f be c9             	movsbl %cl,%ecx
f01039d5:	83 e9 30             	sub    $0x30,%ecx
f01039d8:	eb 1e                	jmp    f01039f8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01039da:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01039dd:	80 fb 19             	cmp    $0x19,%bl
f01039e0:	77 08                	ja     f01039ea <strtol+0x92>
			dig = *s - 'a' + 10;
f01039e2:	0f be c9             	movsbl %cl,%ecx
f01039e5:	83 e9 57             	sub    $0x57,%ecx
f01039e8:	eb 0e                	jmp    f01039f8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01039ea:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01039ed:	80 fb 19             	cmp    $0x19,%bl
f01039f0:	77 12                	ja     f0103a04 <strtol+0xac>
			dig = *s - 'A' + 10;
f01039f2:	0f be c9             	movsbl %cl,%ecx
f01039f5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01039f8:	39 f1                	cmp    %esi,%ecx
f01039fa:	7d 0c                	jge    f0103a08 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01039fc:	42                   	inc    %edx
f01039fd:	0f af c6             	imul   %esi,%eax
f0103a00:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103a02:	eb c4                	jmp    f01039c8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103a04:	89 c1                	mov    %eax,%ecx
f0103a06:	eb 02                	jmp    f0103a0a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103a08:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0103a0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103a0e:	74 05                	je     f0103a15 <strtol+0xbd>
		*endptr = (char *) s;
f0103a10:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a13:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103a15:	85 ff                	test   %edi,%edi
f0103a17:	74 04                	je     f0103a1d <strtol+0xc5>
f0103a19:	89 c8                	mov    %ecx,%eax
f0103a1b:	f7 d8                	neg    %eax
}
f0103a1d:	5b                   	pop    %ebx
f0103a1e:	5e                   	pop    %esi
f0103a1f:	5f                   	pop    %edi
f0103a20:	5d                   	pop    %ebp
f0103a21:	c3                   	ret    
	...

f0103a24 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f0103a24:	55                   	push   %ebp
f0103a25:	57                   	push   %edi
f0103a26:	56                   	push   %esi
f0103a27:	83 ec 10             	sub    $0x10,%esp
f0103a2a:	8b 74 24 20          	mov    0x20(%esp),%esi
f0103a2e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103a32:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a36:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
f0103a3a:	89 cd                	mov    %ecx,%ebp
f0103a3c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103a40:	85 c0                	test   %eax,%eax
f0103a42:	75 2c                	jne    f0103a70 <__udivdi3+0x4c>
    {
      if (d0 > n1)
f0103a44:	39 f9                	cmp    %edi,%ecx
f0103a46:	77 68                	ja     f0103ab0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103a48:	85 c9                	test   %ecx,%ecx
f0103a4a:	75 0b                	jne    f0103a57 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103a4c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a51:	31 d2                	xor    %edx,%edx
f0103a53:	f7 f1                	div    %ecx
f0103a55:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103a57:	31 d2                	xor    %edx,%edx
f0103a59:	89 f8                	mov    %edi,%eax
f0103a5b:	f7 f1                	div    %ecx
f0103a5d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103a5f:	89 f0                	mov    %esi,%eax
f0103a61:	f7 f1                	div    %ecx
f0103a63:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a65:	89 f0                	mov    %esi,%eax
f0103a67:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a69:	83 c4 10             	add    $0x10,%esp
f0103a6c:	5e                   	pop    %esi
f0103a6d:	5f                   	pop    %edi
f0103a6e:	5d                   	pop    %ebp
f0103a6f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103a70:	39 f8                	cmp    %edi,%eax
f0103a72:	77 2c                	ja     f0103aa0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103a74:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
f0103a77:	83 f6 1f             	xor    $0x1f,%esi
f0103a7a:	75 4c                	jne    f0103ac8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103a7c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103a7e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103a83:	72 0a                	jb     f0103a8f <__udivdi3+0x6b>
f0103a85:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0103a89:	0f 87 ad 00 00 00    	ja     f0103b3c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103a8f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103a94:	89 f0                	mov    %esi,%eax
f0103a96:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103a98:	83 c4 10             	add    $0x10,%esp
f0103a9b:	5e                   	pop    %esi
f0103a9c:	5f                   	pop    %edi
f0103a9d:	5d                   	pop    %ebp
f0103a9e:	c3                   	ret    
f0103a9f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103aa0:	31 ff                	xor    %edi,%edi
f0103aa2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103aa4:	89 f0                	mov    %esi,%eax
f0103aa6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103aa8:	83 c4 10             	add    $0x10,%esp
f0103aab:	5e                   	pop    %esi
f0103aac:	5f                   	pop    %edi
f0103aad:	5d                   	pop    %ebp
f0103aae:	c3                   	ret    
f0103aaf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103ab0:	89 fa                	mov    %edi,%edx
f0103ab2:	89 f0                	mov    %esi,%eax
f0103ab4:	f7 f1                	div    %ecx
f0103ab6:	89 c6                	mov    %eax,%esi
f0103ab8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
f0103aba:	89 f0                	mov    %esi,%eax
f0103abc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f0103abe:	83 c4 10             	add    $0x10,%esp
f0103ac1:	5e                   	pop    %esi
f0103ac2:	5f                   	pop    %edi
f0103ac3:	5d                   	pop    %ebp
f0103ac4:	c3                   	ret    
f0103ac5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103ac8:	89 f1                	mov    %esi,%ecx
f0103aca:	d3 e0                	shl    %cl,%eax
f0103acc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103ad0:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ad5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
f0103ad7:	89 ea                	mov    %ebp,%edx
f0103ad9:	88 c1                	mov    %al,%cl
f0103adb:	d3 ea                	shr    %cl,%edx
f0103add:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0103ae1:	09 ca                	or     %ecx,%edx
f0103ae3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
f0103ae7:	89 f1                	mov    %esi,%ecx
f0103ae9:	d3 e5                	shl    %cl,%ebp
f0103aeb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
f0103aef:	89 fd                	mov    %edi,%ebp
f0103af1:	88 c1                	mov    %al,%cl
f0103af3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
f0103af5:	89 fa                	mov    %edi,%edx
f0103af7:	89 f1                	mov    %esi,%ecx
f0103af9:	d3 e2                	shl    %cl,%edx
f0103afb:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103aff:	88 c1                	mov    %al,%cl
f0103b01:	d3 ef                	shr    %cl,%edi
f0103b03:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103b05:	89 f8                	mov    %edi,%eax
f0103b07:	89 ea                	mov    %ebp,%edx
f0103b09:	f7 74 24 08          	divl   0x8(%esp)
f0103b0d:	89 d1                	mov    %edx,%ecx
f0103b0f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
f0103b11:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b15:	39 d1                	cmp    %edx,%ecx
f0103b17:	72 17                	jb     f0103b30 <__udivdi3+0x10c>
f0103b19:	74 09                	je     f0103b24 <__udivdi3+0x100>
f0103b1b:	89 fe                	mov    %edi,%esi
f0103b1d:	31 ff                	xor    %edi,%edi
f0103b1f:	e9 41 ff ff ff       	jmp    f0103a65 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
f0103b24:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103b28:	89 f1                	mov    %esi,%ecx
f0103b2a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103b2c:	39 c2                	cmp    %eax,%edx
f0103b2e:	73 eb                	jae    f0103b1b <__udivdi3+0xf7>
		{
		  q0--;
f0103b30:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103b33:	31 ff                	xor    %edi,%edi
f0103b35:	e9 2b ff ff ff       	jmp    f0103a65 <__udivdi3+0x41>
f0103b3a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103b3c:	31 f6                	xor    %esi,%esi
f0103b3e:	e9 22 ff ff ff       	jmp    f0103a65 <__udivdi3+0x41>
	...

f0103b44 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
f0103b44:	55                   	push   %ebp
f0103b45:	57                   	push   %edi
f0103b46:	56                   	push   %esi
f0103b47:	83 ec 20             	sub    $0x20,%esp
f0103b4a:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103b4e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
f0103b52:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103b56:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
f0103b5a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103b5e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
f0103b62:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
f0103b64:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
f0103b66:	85 ed                	test   %ebp,%ebp
f0103b68:	75 16                	jne    f0103b80 <__umoddi3+0x3c>
    {
      if (d0 > n1)
f0103b6a:	39 f1                	cmp    %esi,%ecx
f0103b6c:	0f 86 a6 00 00 00    	jbe    f0103c18 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103b72:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
f0103b74:	89 d0                	mov    %edx,%eax
f0103b76:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103b78:	83 c4 20             	add    $0x20,%esp
f0103b7b:	5e                   	pop    %esi
f0103b7c:	5f                   	pop    %edi
f0103b7d:	5d                   	pop    %ebp
f0103b7e:	c3                   	ret    
f0103b7f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
f0103b80:	39 f5                	cmp    %esi,%ebp
f0103b82:	0f 87 ac 00 00 00    	ja     f0103c34 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
f0103b88:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
f0103b8b:	83 f0 1f             	xor    $0x1f,%eax
f0103b8e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103b92:	0f 84 a8 00 00 00    	je     f0103c40 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
f0103b98:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103b9c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
f0103b9e:	bf 20 00 00 00       	mov    $0x20,%edi
f0103ba3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
f0103ba7:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103bab:	89 f9                	mov    %edi,%ecx
f0103bad:	d3 e8                	shr    %cl,%eax
f0103baf:	09 e8                	or     %ebp,%eax
f0103bb1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
f0103bb5:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103bb9:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103bbd:	d3 e0                	shl    %cl,%eax
f0103bbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103bc3:	89 f2                	mov    %esi,%edx
f0103bc5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
f0103bc7:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103bcb:	d3 e0                	shl    %cl,%eax
f0103bcd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
f0103bd1:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103bd5:	89 f9                	mov    %edi,%ecx
f0103bd7:	d3 e8                	shr    %cl,%eax
f0103bd9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
f0103bdb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0103bdd:	89 f2                	mov    %esi,%edx
f0103bdf:	f7 74 24 18          	divl   0x18(%esp)
f0103be3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
f0103be5:	f7 64 24 0c          	mull   0xc(%esp)
f0103be9:	89 c5                	mov    %eax,%ebp
f0103beb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103bed:	39 d6                	cmp    %edx,%esi
f0103bef:	72 67                	jb     f0103c58 <__umoddi3+0x114>
f0103bf1:	74 75                	je     f0103c68 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f0103bf3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0103bf7:	29 e8                	sub    %ebp,%eax
f0103bf9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
f0103bfb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103bff:	d3 e8                	shr    %cl,%eax
f0103c01:	89 f2                	mov    %esi,%edx
f0103c03:	89 f9                	mov    %edi,%ecx
f0103c05:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
f0103c07:	09 d0                	or     %edx,%eax
f0103c09:	89 f2                	mov    %esi,%edx
f0103c0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103c0f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c11:	83 c4 20             	add    $0x20,%esp
f0103c14:	5e                   	pop    %esi
f0103c15:	5f                   	pop    %edi
f0103c16:	5d                   	pop    %ebp
f0103c17:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
f0103c18:	85 c9                	test   %ecx,%ecx
f0103c1a:	75 0b                	jne    f0103c27 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0103c1c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c21:	31 d2                	xor    %edx,%edx
f0103c23:	f7 f1                	div    %ecx
f0103c25:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0103c27:	89 f0                	mov    %esi,%eax
f0103c29:	31 d2                	xor    %edx,%edx
f0103c2b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0103c2d:	89 f8                	mov    %edi,%eax
f0103c2f:	e9 3e ff ff ff       	jmp    f0103b72 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
f0103c34:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c36:	83 c4 20             	add    $0x20,%esp
f0103c39:	5e                   	pop    %esi
f0103c3a:	5f                   	pop    %edi
f0103c3b:	5d                   	pop    %ebp
f0103c3c:	c3                   	ret    
f0103c3d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
f0103c40:	39 f5                	cmp    %esi,%ebp
f0103c42:	72 04                	jb     f0103c48 <__umoddi3+0x104>
f0103c44:	39 f9                	cmp    %edi,%ecx
f0103c46:	77 06                	ja     f0103c4e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0103c48:	89 f2                	mov    %esi,%edx
f0103c4a:	29 cf                	sub    %ecx,%edi
f0103c4c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
f0103c4e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
f0103c50:	83 c4 20             	add    $0x20,%esp
f0103c53:	5e                   	pop    %esi
f0103c54:	5f                   	pop    %edi
f0103c55:	5d                   	pop    %ebp
f0103c56:	c3                   	ret    
f0103c57:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f0103c58:	89 d1                	mov    %edx,%ecx
f0103c5a:	89 c5                	mov    %eax,%ebp
f0103c5c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0103c60:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0103c64:	eb 8d                	jmp    f0103bf3 <__umoddi3+0xaf>
f0103c66:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f0103c68:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0103c6c:	72 ea                	jb     f0103c58 <__umoddi3+0x114>
f0103c6e:	89 f1                	mov    %esi,%ecx
f0103c70:	eb 81                	jmp    f0103bf3 <__umoddi3+0xaf>
