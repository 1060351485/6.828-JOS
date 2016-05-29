
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 97 1b 00 00       	call   801bc8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c1                	mov    %al,%cl

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 c0             	movzbl %al,%eax
  800043:	89 c3                	mov    %eax,%ebx
  800045:	81 e3 c0 00 00 00    	and    $0xc0,%ebx
  80004b:	83 fb 40             	cmp    $0x40,%ebx
  80004e:	75 ef                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800050:	84 c9                	test   %cl,%cl
  800052:	74 0c                	je     800060 <ide_wait_ready+0x2c>
  800054:	83 e0 21             	and    $0x21,%eax
		return -1;
	return 0;
  800057:	83 f8 01             	cmp    $0x1,%eax
  80005a:	19 c0                	sbb    %eax,%eax
  80005c:	f7 d0                	not    %eax
  80005e:	eb 05                	jmp    800065 <ide_wait_ready+0x31>
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800065:	5b                   	pop    %ebx
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	53                   	push   %ebx
  80006c:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
  800074:	e8 bb ff ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	b0 f0                	mov    $0xf0,%al
  800080:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800081:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800086:	b2 f7                	mov    $0xf7,%dl
  800088:	eb 09                	jmp    800093 <ide_probe_disk1+0x2b>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008a:	43                   	inc    %ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008b:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800091:	74 05                	je     800098 <ide_probe_disk1+0x30>
  800093:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800094:	a8 a1                	test   $0xa1,%al
  800096:	75 f2                	jne    80008a <ide_probe_disk1+0x22>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800098:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009d:	b0 e0                	mov    $0xe0,%al
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000a6:	0f 9e c0             	setle  %al
  8000a9:	0f b6 c0             	movzbl %al,%eax
  8000ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b0:	c7 04 24 a0 40 80 00 	movl   $0x8040a0,(%esp)
  8000b7:	e8 60 1c 00 00       	call   801d1c <cprintf>
	return (x < 1000);
  8000bc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000c2:	0f 9e c0             	setle  %al
}
  8000c5:	83 c4 14             	add    $0x14,%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 18             	sub    $0x18,%esp
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d4:	83 f8 01             	cmp    $0x1,%eax
  8000d7:	76 1c                	jbe    8000f5 <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d9:	c7 44 24 08 b7 40 80 	movl   $0x8040b7,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 c7 40 80 00 	movl   $0x8040c7,(%esp)
  8000f0:	e8 2f 1b 00 00       	call   801c24 <_panic>
	diskno = d;
  8000f5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 1c             	sub    $0x1c,%esp
  800105:	8b 7d 08             	mov    0x8(%ebp),%edi
  800108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80010b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  80010e:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800114:	76 24                	jbe    80013a <ide_read+0x3e>
  800116:	c7 44 24 0c d0 40 80 	movl   $0x8040d0,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 c7 40 80 00 	movl   $0x8040c7,(%esp)
  800135:	e8 ea 1a 00 00       	call   801c24 <_panic>

	ide_wait_ready(0);
  80013a:	b8 00 00 00 00       	mov    $0x0,%eax
  80013f:	e8 f0 fe ff ff       	call   800034 <ide_wait_ready>
  800144:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800149:	88 d8                	mov    %bl,%al
  80014b:	ee                   	out    %al,(%dx)
  80014c:	b2 f3                	mov    $0xf3,%dl
  80014e:	89 f8                	mov    %edi,%eax
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 08             	shr    $0x8,%eax
  800156:	b2 f4                	mov    $0xf4,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800159:	89 f8                	mov    %edi,%eax
  80015b:	c1 e8 10             	shr    $0x10,%eax
  80015e:	b2 f5                	mov    $0xf5,%dl
  800160:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800161:	a1 00 50 80 00       	mov    0x805000,%eax
  800166:	83 e0 01             	and    $0x1,%eax
  800169:	c1 e0 04             	shl    $0x4,%eax
  80016c:	83 c8 e0             	or     $0xffffffe0,%eax
  80016f:	c1 ef 18             	shr    $0x18,%edi
  800172:	83 e7 0f             	and    $0xf,%edi
  800175:	09 f8                	or     %edi,%eax
  800177:	b2 f6                	mov    $0xf6,%dl
  800179:	ee                   	out    %al,(%dx)
  80017a:	b2 f7                	mov    $0xf7,%dl
  80017c:	b0 20                	mov    $0x20,%al
  80017e:	ee                   	out    %al,(%dx)
  80017f:	eb 24                	jmp    8001a5 <ide_read+0xa9>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800181:	b8 01 00 00 00       	mov    $0x1,%eax
  800186:	e8 a9 fe ff ff       	call   800034 <ide_wait_ready>
  80018b:	85 c0                	test   %eax,%eax
  80018d:	78 1f                	js     8001ae <ide_read+0xb2>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018f:	89 f7                	mov    %esi,%edi
  800191:	b9 80 00 00 00       	mov    $0x80,%ecx
  800196:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019b:	fc                   	cld    
  80019c:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80019e:	4b                   	dec    %ebx
  80019f:	81 c6 00 02 00 00    	add    $0x200,%esi
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	75 d8                	jne    800181 <ide_read+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001ae:	83 c4 1c             	add    $0x1c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001c8:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001ce:	76 24                	jbe    8001f4 <ide_write+0x3e>
  8001d0:	c7 44 24 0c d0 40 80 	movl   $0x8040d0,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 c7 40 80 00 	movl   $0x8040c7,(%esp)
  8001ef:	e8 30 1a 00 00       	call   801c24 <_panic>

	ide_wait_ready(0);
  8001f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f9:	e8 36 fe ff ff       	call   800034 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001fe:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800203:	88 d8                	mov    %bl,%al
  800205:	ee                   	out    %al,(%dx)
  800206:	b2 f3                	mov    $0xf3,%dl
  800208:	89 f0                	mov    %esi,%eax
  80020a:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80020b:	89 f0                	mov    %esi,%eax
  80020d:	c1 e8 08             	shr    $0x8,%eax
  800210:	b2 f4                	mov    $0xf4,%dl
  800212:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800213:	89 f0                	mov    %esi,%eax
  800215:	c1 e8 10             	shr    $0x10,%eax
  800218:	b2 f5                	mov    $0xf5,%dl
  80021a:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021b:	a1 00 50 80 00       	mov    0x805000,%eax
  800220:	83 e0 01             	and    $0x1,%eax
  800223:	c1 e0 04             	shl    $0x4,%eax
  800226:	83 c8 e0             	or     $0xffffffe0,%eax
  800229:	c1 ee 18             	shr    $0x18,%esi
  80022c:	83 e6 0f             	and    $0xf,%esi
  80022f:	09 f0                	or     %esi,%eax
  800231:	b2 f6                	mov    $0xf6,%dl
  800233:	ee                   	out    %al,(%dx)
  800234:	b2 f7                	mov    $0xf7,%dl
  800236:	b0 30                	mov    $0x30,%al
  800238:	ee                   	out    %al,(%dx)
  800239:	eb 24                	jmp    80025f <ide_write+0xa9>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80023b:	b8 01 00 00 00       	mov    $0x1,%eax
  800240:	e8 ef fd ff ff       	call   800034 <ide_wait_ready>
  800245:	85 c0                	test   %eax,%eax
  800247:	78 1f                	js     800268 <ide_write+0xb2>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800249:	89 fe                	mov    %edi,%esi
  80024b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800250:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800255:	fc                   	cld    
  800256:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800258:	4b                   	dec    %ebx
  800259:	81 c7 00 02 00 00    	add    $0x200,%edi
  80025f:	85 db                	test   %ebx,%ebx
  800261:	75 d8                	jne    80023b <ide_write+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800268:	83 c4 1c             	add    $0x1c,%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 20             	sub    $0x20,%esp
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80027b:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  800283:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800289:	76 2e                	jbe    8002b9 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80028b:	8b 50 04             	mov    0x4(%eax),%edx
  80028e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800292:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800296:	8b 40 28             	mov    0x28(%eax),%eax
  800299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029d:	c7 44 24 08 f4 40 80 	movl   $0x8040f4,0x8(%esp)
  8002a4:	00 
  8002a5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ac:	00 
  8002ad:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8002b4:	e8 6b 19 00 00       	call   801c24 <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002b9:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002bf:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c2:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	74 25                	je     8002f0 <bc_pgfault+0x80>
  8002cb:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ce:	72 20                	jb     8002f0 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	c7 44 24 08 24 41 80 	movl   $0x804124,0x8(%esp)
  8002db:	00 
  8002dc:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e3:	00 
  8002e4:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8002eb:	e8 34 19 00 00       	call   801c24 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8002f0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(sys_getenvid(), addr, PTE_SYSCALL) < 0)
  8002f6:	e8 80 23 00 00       	call   80267b <sys_getenvid>
  8002fb:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800302:	00 
  800303:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	e8 aa 23 00 00       	call   8026b9 <sys_page_alloc>
  80030f:	85 c0                	test   %eax,%eax
  800311:	79 1c                	jns    80032f <bc_pgfault+0xbf>
		panic("bc_pgfault: sys_page_alloc failed");
  800313:	c7 44 24 08 48 41 80 	movl   $0x804148,0x8(%esp)
  80031a:	00 
  80031b:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  800322:	00 
  800323:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  80032a:	e8 f5 18 00 00       	call   801c24 <_panic>
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  80032f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800336:	00 
  800337:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033b:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800342:	89 04 24             	mov    %eax,(%esp)
  800345:	e8 b2 fd ff ff       	call   8000fc <ide_read>
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 20                	jns    80036e <bc_pgfault+0xfe>
		panic("bc_pgfault: ide_write, %e", r);	
  80034e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800352:	c7 44 24 08 00 42 80 	movl   $0x804200,0x8(%esp)
  800359:	00 
  80035a:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800361:	00 
  800362:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  800369:	e8 b6 18 00 00       	call   801c24 <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80036e:	89 d8                	mov    %ebx,%eax
  800370:	c1 e8 0c             	shr    $0xc,%eax
  800373:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80037a:	25 07 0e 00 00       	and    $0xe07,%eax
  80037f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800383:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800387:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80038e:	00 
  80038f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800393:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80039a:	e8 6e 23 00 00       	call   80270d <sys_page_map>
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	79 20                	jns    8003c3 <bc_pgfault+0x153>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	c7 44 24 08 6c 41 80 	movl   $0x80416c,0x8(%esp)
  8003ae:	00 
  8003af:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  8003b6:	00 
  8003b7:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8003be:	e8 61 18 00 00       	call   801c24 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003c3:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  8003ca:	74 2c                	je     8003f8 <bc_pgfault+0x188>
  8003cc:	89 34 24             	mov    %esi,(%esp)
  8003cf:	e8 03 04 00 00       	call   8007d7 <block_is_free>
  8003d4:	84 c0                	test   %al,%al
  8003d6:	74 20                	je     8003f8 <bc_pgfault+0x188>
		panic("reading free block %08x\n", blockno);
  8003d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003dc:	c7 44 24 08 1a 42 80 	movl   $0x80421a,0x8(%esp)
  8003e3:	00 
  8003e4:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8003eb:	00 
  8003ec:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8003f3:	e8 2c 18 00 00       	call   801c24 <_panic>
}
  8003f8:	83 c4 20             	add    $0x20,%esp
  8003fb:	5b                   	pop    %ebx
  8003fc:	5e                   	pop    %esi
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	83 ec 18             	sub    $0x18,%esp
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800408:	85 c0                	test   %eax,%eax
  80040a:	74 0f                	je     80041b <diskaddr+0x1c>
  80040c:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	74 25                	je     80043b <diskaddr+0x3c>
  800416:	3b 42 04             	cmp    0x4(%edx),%eax
  800419:	72 20                	jb     80043b <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80041b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041f:	c7 44 24 08 8c 41 80 	movl   $0x80418c,0x8(%esp)
  800426:	00 
  800427:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80042e:	00 
  80042f:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  800436:	e8 e9 17 00 00       	call   801c24 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80043b:	05 00 00 01 00       	add    $0x10000,%eax
  800440:	c1 e0 0c             	shl    $0xc,%eax
}
  800443:	c9                   	leave  
  800444:	c3                   	ret    

00800445 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	c1 ea 16             	shr    $0x16,%edx
  800450:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800457:	f6 c2 01             	test   $0x1,%dl
  80045a:	74 0f                	je     80046b <va_is_mapped+0x26>
  80045c:	c1 e8 0c             	shr    $0xc,%eax
  80045f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800466:	83 e0 01             	and    $0x1,%eax
  800469:	eb 05                	jmp    800470 <va_is_mapped+0x2b>
  80046b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	c1 e8 0c             	shr    $0xc,%eax
  80047b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800482:	a8 40                	test   $0x40,%al
  800484:	0f 95 c0             	setne  %al
}
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    

00800489 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 20             	sub    $0x20,%esp
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800494:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  80049a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80049f:	76 20                	jbe    8004c1 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);
  8004a1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004a5:	c7 44 24 08 33 42 80 	movl   $0x804233,0x8(%esp)
  8004ac:	00 
  8004ad:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004b4:	00 
  8004b5:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8004bc:	e8 63 17 00 00       	call   801c24 <_panic>

	// LAB 5: Your code here.
	//panic("flush_block not implemented");
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8004c1:	89 f3                	mov    %esi,%ebx
  8004c3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	int r;
	if (!va_is_mapped(addr) || !va_is_dirty(addr))
  8004c9:	89 1c 24             	mov    %ebx,(%esp)
  8004cc:	e8 74 ff ff ff       	call   800445 <va_is_mapped>
  8004d1:	84 c0                	test   %al,%al
  8004d3:	0f 84 98 00 00 00    	je     800571 <flush_block+0xe8>
  8004d9:	89 1c 24             	mov    %ebx,(%esp)
  8004dc:	e8 91 ff ff ff       	call   800472 <va_is_dirty>
  8004e1:	84 c0                	test   %al,%al
  8004e3:	0f 84 88 00 00 00    	je     800571 <flush_block+0xe8>
		return;
	if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  8004e9:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004f0:	00 
  8004f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004f5:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  8004fb:	c1 ee 0c             	shr    $0xc,%esi
	
	addr = ROUNDDOWN(addr, PGSIZE);
	int r;
	if (!va_is_mapped(addr) || !va_is_dirty(addr))
		return;
	if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  8004fe:	c1 e6 03             	shl    $0x3,%esi
  800501:	89 34 24             	mov    %esi,(%esp)
  800504:	e8 ad fc ff ff       	call   8001b6 <ide_write>
  800509:	85 c0                	test   %eax,%eax
  80050b:	79 20                	jns    80052d <flush_block+0xa4>
		panic("flush_block: ide_write, %e", r);
  80050d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800511:	c7 44 24 08 4e 42 80 	movl   $0x80424e,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  800528:	e8 f7 16 00 00       	call   801c24 <_panic>
	if (sys_page_map(0, addr, 0, addr, PTE_SYSCALL) < 0)
  80052d:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800534:	00 
  800535:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800539:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80054c:	e8 bc 21 00 00       	call   80270d <sys_page_map>
  800551:	85 c0                	test   %eax,%eax
  800553:	79 1c                	jns    800571 <flush_block+0xe8>
		panic("flush_block: sys_page_map failed");
  800555:	c7 44 24 08 b0 41 80 	movl   $0x8041b0,0x8(%esp)
  80055c:	00 
  80055d:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  800564:	00 
  800565:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  80056c:	e8 b3 16 00 00       	call   801c24 <_panic>
}
  800571:	83 c4 20             	add    $0x20,%esp
  800574:	5b                   	pop    %ebx
  800575:	5e                   	pop    %esi
  800576:	5d                   	pop    %ebp
  800577:	c3                   	ret    

00800578 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	81 ec 28 02 00 00    	sub    $0x228,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800581:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  800588:	e8 17 24 00 00       	call   8029a4 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80058d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800594:	e8 66 fe ff ff       	call   8003ff <diskaddr>
  800599:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8005a0:	00 
  8005a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8005ab:	89 04 24             	mov    %eax,(%esp)
  8005ae:	e8 8d 1e 00 00       	call   802440 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8005b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ba:	e8 40 fe ff ff       	call   8003ff <diskaddr>
  8005bf:	c7 44 24 04 69 42 80 	movl   $0x804269,0x4(%esp)
  8005c6:	00 
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	e8 f8 1c 00 00       	call   8022c7 <strcpy>
	flush_block(diskaddr(1));
  8005cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005d6:	e8 24 fe ff ff       	call   8003ff <diskaddr>
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	e8 a6 fe ff ff       	call   800489 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ea:	e8 10 fe ff ff       	call   8003ff <diskaddr>
  8005ef:	89 04 24             	mov    %eax,(%esp)
  8005f2:	e8 4e fe ff ff       	call   800445 <va_is_mapped>
  8005f7:	84 c0                	test   %al,%al
  8005f9:	75 24                	jne    80061f <bc_init+0xa7>
  8005fb:	c7 44 24 0c 8b 42 80 	movl   $0x80428b,0xc(%esp)
  800602:	00 
  800603:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  80060a:	00 
  80060b:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  800612:	00 
  800613:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  80061a:	e8 05 16 00 00       	call   801c24 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80061f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800626:	e8 d4 fd ff ff       	call   8003ff <diskaddr>
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 3f fe ff ff       	call   800472 <va_is_dirty>
  800633:	84 c0                	test   %al,%al
  800635:	74 24                	je     80065b <bc_init+0xe3>
  800637:	c7 44 24 0c 70 42 80 	movl   $0x804270,0xc(%esp)
  80063e:	00 
  80063f:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  800646:	00 
  800647:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80064e:	00 
  80064f:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  800656:	e8 c9 15 00 00       	call   801c24 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80065b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800662:	e8 98 fd ff ff       	call   8003ff <diskaddr>
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800672:	e8 e9 20 00 00       	call   802760 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80067e:	e8 7c fd ff ff       	call   8003ff <diskaddr>
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	e8 ba fd ff ff       	call   800445 <va_is_mapped>
  80068b:	84 c0                	test   %al,%al
  80068d:	74 24                	je     8006b3 <bc_init+0x13b>
  80068f:	c7 44 24 0c 8a 42 80 	movl   $0x80428a,0xc(%esp)
  800696:	00 
  800697:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  80069e:	00 
  80069f:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006a6:	00 
  8006a7:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8006ae:	e8 71 15 00 00       	call   801c24 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ba:	e8 40 fd ff ff       	call   8003ff <diskaddr>
  8006bf:	c7 44 24 04 69 42 80 	movl   $0x804269,0x4(%esp)
  8006c6:	00 
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	e8 9f 1c 00 00       	call   80236e <strcmp>
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 24                	je     8006f7 <bc_init+0x17f>
  8006d3:	c7 44 24 0c d4 41 80 	movl   $0x8041d4,0xc(%esp)
  8006da:	00 
  8006db:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8006e2:	00 
  8006e3:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8006ea:	00 
  8006eb:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  8006f2:	e8 2d 15 00 00       	call   801c24 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8006f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006fe:	e8 fc fc ff ff       	call   8003ff <diskaddr>
  800703:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80070a:	00 
  80070b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800711:	89 54 24 04          	mov    %edx,0x4(%esp)
  800715:	89 04 24             	mov    %eax,(%esp)
  800718:	e8 23 1d 00 00       	call   802440 <memmove>
	flush_block(diskaddr(1));
  80071d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800724:	e8 d6 fc ff ff       	call   8003ff <diskaddr>
  800729:	89 04 24             	mov    %eax,(%esp)
  80072c:	e8 58 fd ff ff       	call   800489 <flush_block>

	cprintf("block cache is good\n");
  800731:	c7 04 24 a5 42 80 00 	movl   $0x8042a5,(%esp)
  800738:	e8 df 15 00 00       	call   801d1c <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80073d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800744:	e8 b6 fc ff ff       	call   8003ff <diskaddr>
  800749:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800750:	00 
  800751:	89 44 24 04          	mov    %eax,0x4(%esp)
  800755:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	e8 dd 1c 00 00       	call   802440 <memmove>
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    
  800765:	00 00                	add    %al,(%eax)
	...

00800768 <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  80076b:	eb 01                	jmp    80076e <skip_slash+0x6>
	  p++;
  80076d:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  80076e:	80 38 2f             	cmpb   $0x2f,(%eax)
  800771:	74 fa                	je     80076d <skip_slash+0x5>
	  p++;
	return p;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  80077b:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800780:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800786:	74 1c                	je     8007a4 <check_super+0x2f>
	  panic("bad file system magic number");
  800788:	c7 44 24 08 ba 42 80 	movl   $0x8042ba,0x8(%esp)
  80078f:	00 
  800790:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800797:	00 
  800798:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  80079f:	e8 80 14 00 00       	call   801c24 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007a4:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007ab:	76 1c                	jbe    8007c9 <check_super+0x54>
	  panic("file system is too large");
  8007ad:	c7 44 24 08 df 42 80 	movl   $0x8042df,0x8(%esp)
  8007b4:	00 
  8007b5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8007bc:	00 
  8007bd:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  8007c4:	e8 5b 14 00 00       	call   801c24 <_panic>

	cprintf("superblock is good\n");
  8007c9:	c7 04 24 f8 42 80 00 	movl   $0x8042f8,(%esp)
  8007d0:	e8 47 15 00 00       	call   801d1c <cprintf>
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8007dd:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8007e2:	85 c0                	test   %eax,%eax
  8007e4:	74 1d                	je     800803 <block_is_free+0x2c>
  8007e6:	39 48 04             	cmp    %ecx,0x4(%eax)
  8007e9:	76 1c                	jbe    800807 <block_is_free+0x30>
	  return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8007eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8007f0:	d3 e0                	shl    %cl,%eax
  8007f2:	c1 e9 05             	shr    $0x5,%ecx
// --------------------------------------------------------------

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
  8007f5:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8007fb:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  8007fe:	0f 95 c0             	setne  %al
  800801:	eb 06                	jmp    800809 <block_is_free+0x32>
{
	if (super == 0 || blockno >= super->s_nblocks)
	  return 0;
  800803:	b0 00                	mov    $0x0,%al
  800805:	eb 02                	jmp    800809 <block_is_free+0x32>
  800807:	b0 00                	mov    $0x0,%al
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
	  return 1;
	return 0;
}
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	83 ec 18             	sub    $0x18,%esp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800814:	85 c9                	test   %ecx,%ecx
  800816:	75 1c                	jne    800834 <free_block+0x29>
	  panic("attempt to free zero block");
  800818:	c7 44 24 08 0c 43 80 	movl   $0x80430c,0x8(%esp)
  80081f:	00 
  800820:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800827:	00 
  800828:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  80082f:	e8 f0 13 00 00       	call   801c24 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800834:	89 c8                	mov    %ecx,%eax
  800836:	c1 e8 05             	shr    $0x5,%eax
  800839:	c1 e0 02             	shl    $0x2,%eax
  80083c:	03 05 08 a0 80 00    	add    0x80a008,%eax
  800842:	ba 01 00 00 00       	mov    $0x1,%edx
  800847:	d3 e2                	shl    %cl,%edx
  800849:	09 10                	or     %edx,(%eax)
}
  80084b:	c9                   	leave  
  80084c:	c3                   	ret    

0080084d <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	83 ec 10             	sub    $0x10,%esp
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t i;
	for (i = 0;i < super->s_nblocks; i++){
  800855:	bb 00 00 00 00       	mov    $0x0,%ebx
  80085a:	eb 3c                	jmp    800898 <alloc_block+0x4b>
		if (block_is_free(i)){
  80085c:	89 1c 24             	mov    %ebx,(%esp)
  80085f:	e8 73 ff ff ff       	call   8007d7 <block_is_free>
  800864:	84 c0                	test   %al,%al
  800866:	74 2f                	je     800897 <alloc_block+0x4a>
			bitmap[i/32] &= ~(1 << (i%32));			
  800868:	89 d8                	mov    %ebx,%eax
  80086a:	c1 e8 05             	shr    $0x5,%eax
  80086d:	c1 e0 02             	shl    $0x2,%eax
  800870:	03 05 08 a0 80 00    	add    0x80a008,%eax
  800876:	89 de                	mov    %ebx,%esi
  800878:	ba 01 00 00 00       	mov    $0x1,%edx
  80087d:	88 d9                	mov    %bl,%cl
  80087f:	d3 e2                	shl    %cl,%edx
  800881:	f7 d2                	not    %edx
  800883:	21 10                	and    %edx,(%eax)
			flush_block(diskaddr(i));
  800885:	89 1c 24             	mov    %ebx,(%esp)
  800888:	e8 72 fb ff ff       	call   8003ff <diskaddr>
  80088d:	89 04 24             	mov    %eax,(%esp)
  800890:	e8 f4 fb ff ff       	call   800489 <flush_block>
			return i;
  800895:	eb 10                	jmp    8008a7 <alloc_block+0x5a>
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	uint32_t i;
	for (i = 0;i < super->s_nblocks; i++){
  800897:	43                   	inc    %ebx
  800898:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80089d:	3b 58 04             	cmp    0x4(%eax),%ebx
  8008a0:	72 ba                	jb     80085c <alloc_block+0xf>
			bitmap[i/32] &= ~(1 << (i%32));			
			flush_block(diskaddr(i));
			return i;
		}
	}
	return -E_NO_DISK;
  8008a2:	be f7 ff ff ff       	mov    $0xfffffff7,%esi
}
  8008a7:	89 f0                	mov    %esi,%eax
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	5b                   	pop    %ebx
  8008ad:	5e                   	pop    %esi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	57                   	push   %edi
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	83 ec 2c             	sub    $0x2c,%esp
  8008b9:	89 c6                	mov    %eax,%esi
  8008bb:	89 d3                	mov    %edx,%ebx
  8008bd:	89 cf                	mov    %ecx,%edi
  8008bf:	8a 45 08             	mov    0x8(%ebp),%al
	// LAB 5: Your code here.
	//panic("file_block_walk not implemented");
	
	if (filebno < NDIRECT) {
  8008c2:	83 fa 09             	cmp    $0x9,%edx
  8008c5:	77 10                	ja     8008d7 <file_block_walk+0x27>
		*ppdiskbno = &f->f_direct[filebno];
  8008c7:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  8008ce:	89 01                	mov    %eax,(%ecx)
		}
	}else{
		return -E_INVAL;
	}

	return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	eb 7d                	jmp    800954 <file_block_walk+0xa4>
	// LAB 5: Your code here.
	//panic("file_block_walk not implemented");
	
	if (filebno < NDIRECT) {
		*ppdiskbno = &f->f_direct[filebno];
	}else if (filebno < NDIRECT + NINDIRECT) {
  8008d7:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008dd:	77 69                	ja     800948 <file_block_walk+0x98>
		if (f->f_indirect) {
  8008df:	8b 96 b0 00 00 00    	mov    0xb0(%esi),%edx
  8008e5:	85 d2                	test   %edx,%edx
  8008e7:	74 15                	je     8008fe <file_block_walk+0x4e>
			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT];	
  8008e9:	89 14 24             	mov    %edx,(%esp)
  8008ec:	e8 0e fb ff ff       	call   8003ff <diskaddr>
  8008f1:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  8008f5:	89 07                	mov    %eax,(%edi)
		}
	}else{
		return -E_INVAL;
	}

	return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	eb 56                	jmp    800954 <file_block_walk+0xa4>
		*ppdiskbno = &f->f_direct[filebno];
	}else if (filebno < NDIRECT + NINDIRECT) {
		if (f->f_indirect) {
			*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT];	
		}else{
			if (alloc){
  8008fe:	84 c0                	test   %al,%al
  800900:	74 4d                	je     80094f <file_block_walk+0x9f>
				uint32_t blockno = alloc_block();
  800902:	e8 46 ff ff ff       	call   80084d <alloc_block>
  800907:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				if (blockno < 0){
					cprintf("file_block_walk: alloc_block failed");
					return -E_NO_DISK;
				}
				memset(diskaddr(blockno), 0, BLKSIZE);
  80090a:	89 04 24             	mov    %eax,(%esp)
  80090d:	e8 ed fa ff ff       	call   8003ff <diskaddr>
  800912:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800919:	00 
  80091a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800921:	00 
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 cc 1a 00 00       	call   8023f6 <memset>
				f->f_indirect = blockno;
  80092a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80092d:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
				*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT];	
  800933:	89 04 24             	mov    %eax,(%esp)
  800936:	e8 c4 fa ff ff       	call   8003ff <diskaddr>
  80093b:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  80093f:	89 07                	mov    %eax,(%edi)
		}
	}else{
		return -E_INVAL;
	}

	return 0;
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
  800946:	eb 0c                	jmp    800954 <file_block_walk+0xa4>
			}else{
				return -E_NOT_FOUND;
			}
		}
	}else{
		return -E_INVAL;
  800948:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80094d:	eb 05                	jmp    800954 <file_block_walk+0xa4>
				}
				memset(diskaddr(blockno), 0, BLKSIZE);
				f->f_indirect = blockno;
				*ppdiskbno = &((uint32_t *)diskaddr(f->f_indirect))[filebno - NDIRECT];	
			}else{
				return -E_NOT_FOUND;
  80094f:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
	}else{
		return -E_INVAL;
	}

	return 0;
}
  800954:	83 c4 2c             	add    $0x2c,%esp
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	83 ec 14             	sub    $0x14,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800963:	bb 00 00 00 00       	mov    $0x0,%ebx
  800968:	eb 34                	jmp    80099e <check_bitmap+0x42>
	  assert(!block_is_free(2+i));
  80096a:	8d 43 02             	lea    0x2(%ebx),%eax
  80096d:	89 04 24             	mov    %eax,(%esp)
  800970:	e8 62 fe ff ff       	call   8007d7 <block_is_free>
  800975:	84 c0                	test   %al,%al
  800977:	74 24                	je     80099d <check_bitmap+0x41>
  800979:	c7 44 24 0c 27 43 80 	movl   $0x804327,0xc(%esp)
  800980:	00 
  800981:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  800988:	00 
  800989:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800990:	00 
  800991:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  800998:	e8 87 12 00 00       	call   801c24 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80099d:	43                   	inc    %ebx
  80099e:	89 da                	mov    %ebx,%edx
  8009a0:	c1 e2 0f             	shl    $0xf,%edx
  8009a3:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8009a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8009ab:	72 bd                	jb     80096a <check_bitmap+0xe>
	  assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009b4:	e8 1e fe ff ff       	call   8007d7 <block_is_free>
  8009b9:	84 c0                	test   %al,%al
  8009bb:	74 24                	je     8009e1 <check_bitmap+0x85>
  8009bd:	c7 44 24 0c 3b 43 80 	movl   $0x80433b,0xc(%esp)
  8009c4:	00 
  8009c5:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8009cc:	00 
  8009cd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8009d4:	00 
  8009d5:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  8009dc:	e8 43 12 00 00       	call   801c24 <_panic>
	assert(!block_is_free(1));
  8009e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009e8:	e8 ea fd ff ff       	call   8007d7 <block_is_free>
  8009ed:	84 c0                	test   %al,%al
  8009ef:	74 24                	je     800a15 <check_bitmap+0xb9>
  8009f1:	c7 44 24 0c 4d 43 80 	movl   $0x80434d,0xc(%esp)
  8009f8:	00 
  8009f9:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  800a00:	00 
  800a01:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800a08:	00 
  800a09:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  800a10:	e8 0f 12 00 00       	call   801c24 <_panic>

	cprintf("bitmap is good\n");
  800a15:	c7 04 24 5f 43 80 00 	movl   $0x80435f,(%esp)
  800a1c:	e8 fb 12 00 00       	call   801d1c <cprintf>
}
  800a21:	83 c4 14             	add    $0x14,%esp
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if availabl
	if (ide_probe_disk1())
  800a2d:	e8 36 f6 ff ff       	call   800068 <ide_probe_disk1>
  800a32:	84 c0                	test   %al,%al
  800a34:	74 0e                	je     800a44 <fs_init+0x1d>
	  ide_set_disk(1);
  800a36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a3d:	e8 89 f6 ff ff       	call   8000cb <ide_set_disk>
  800a42:	eb 0c                	jmp    800a50 <fs_init+0x29>
	else
	  ide_set_disk(0);
  800a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a4b:	e8 7b f6 ff ff       	call   8000cb <ide_set_disk>
	bc_init();
  800a50:	e8 23 fb ff ff       	call   800578 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a5c:	e8 9e f9 ff ff       	call   8003ff <diskaddr>
  800a61:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800a66:	e8 0a fd ff ff       	call   800775 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a6b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a72:	e8 88 f9 ff ff       	call   8003ff <diskaddr>
  800a77:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800a7c:	e8 db fe ff ff       	call   80095c <check_bitmap>

}
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	53                   	push   %ebx
  800a87:	83 ec 24             	sub    $0x24,%esp
	// LAB 5: Your code here.
	//panic("file_get_block not implemented");
	
	int r;
	uint32_t* pdiskbno;
	if ((r = file_block_walk(f, filebno, &pdiskbno, 1)) < 0){
  800a8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a91:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	e8 11 fe ff ff       	call   8008b0 <file_block_walk>
  800a9f:	89 c3                	mov    %eax,%ebx
  800aa1:	85 c0                	test   %eax,%eax
  800aa3:	79 12                	jns    800ab7 <file_get_block+0x34>
		cprintf("file_get_block: file_block_walk failed, %e", r);
  800aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa9:	c7 04 24 ac 43 80 00 	movl   $0x8043ac,(%esp)
  800ab0:	e8 67 12 00 00       	call   801d1c <cprintf>
		return r;	
  800ab5:	eb 26                	jmp    800add <file_get_block+0x5a>
	}
	if (!*pdiskbno){
  800ab7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800aba:	83 3b 00             	cmpl   $0x0,(%ebx)
  800abd:	75 07                	jne    800ac6 <file_get_block+0x43>
		*pdiskbno = alloc_block();
  800abf:	e8 89 fd ff ff       	call   80084d <alloc_block>
  800ac4:	89 03                	mov    %eax,(%ebx)
		if (*pdiskbno < 0)
			return -E_NO_DISK;
	}
	*blk = (char *)diskaddr(*pdiskbno);
  800ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac9:	8b 00                	mov    (%eax),%eax
  800acb:	89 04 24             	mov    %eax,(%esp)
  800ace:	e8 2c f9 ff ff       	call   8003ff <diskaddr>
  800ad3:	8b 55 10             	mov    0x10(%ebp),%edx
  800ad6:	89 02                	mov    %eax,(%edx)
	return 0;
  800ad8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  800add:	89 d8                	mov    %ebx,%eax
  800adf:	83 c4 24             	add    $0x24,%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800af1:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800af7:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800afd:	e8 66 fc ff ff       	call   800768 <skip_slash>
  800b02:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	f = &super->s_root;
  800b08:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800b0d:	83 c0 08             	add    $0x8,%eax
  800b10:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  800b16:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b1d:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800b24:	74 0c                	je     800b32 <walk_path+0x4d>
	  *pdir = 0;
  800b26:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800b2c:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  800b32:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b3e:	b8 00 00 00 00       	mov    $0x0,%eax
	name[0] = 0;

	if (pdir)
	  *pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b43:	e9 95 01 00 00       	jmp    800cdd <walk_path+0x1f8>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
		  path++;
  800b48:	46                   	inc    %esi
  800b49:	eb 06                	jmp    800b51 <walk_path+0x6c>
	name[0] = 0;

	if (pdir)
	  *pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b4b:	8b b5 4c ff ff ff    	mov    -0xb4(%ebp),%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800b51:	8a 06                	mov    (%esi),%al
  800b53:	3c 2f                	cmp    $0x2f,%al
  800b55:	74 04                	je     800b5b <walk_path+0x76>
  800b57:	84 c0                	test   %al,%al
  800b59:	75 ed                	jne    800b48 <walk_path+0x63>
		  path++;
		if (path - p >= MAXNAMELEN)
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	2b 9d 4c ff ff ff    	sub    -0xb4(%ebp),%ebx
  800b63:	83 fb 7f             	cmp    $0x7f,%ebx
  800b66:	0f 8f a6 01 00 00    	jg     800d12 <walk_path+0x22d>
		  return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b70:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7a:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800b80:	89 14 24             	mov    %edx,(%esp)
  800b83:	e8 b8 18 00 00       	call   802440 <memmove>
		name[path - p] = '\0';
  800b88:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b8f:	00 
		path = skip_slash(path);
  800b90:	89 f0                	mov    %esi,%eax
  800b92:	e8 d1 fb ff ff       	call   800768 <skip_slash>
  800b97:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800b9d:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800ba3:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800baa:	0f 85 69 01 00 00    	jne    800d19 <walk_path+0x234>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800bb0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bb6:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bbb:	74 24                	je     800be1 <walk_path+0xfc>
  800bbd:	c7 44 24 0c 6f 43 80 	movl   $0x80436f,0xc(%esp)
  800bc4:	00 
  800bc5:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  800bcc:	00 
  800bcd:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  800bd4:	00 
  800bd5:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  800bdc:	e8 43 10 00 00       	call   801c24 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	85 c0                	test   %eax,%eax
  800be5:	79 06                	jns    800bed <walk_path+0x108>
  800be7:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800bed:	c1 fa 0c             	sar    $0xc,%edx
  800bf0:	89 95 48 ff ff ff    	mov    %edx,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800bf6:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800bfd:	00 00 00 
  800c00:	eb 62                	jmp    800c64 <walk_path+0x17f>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800c02:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0c:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800c12:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c16:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c1c:	89 04 24             	mov    %eax,(%esp)
  800c1f:	e8 5f fe ff ff       	call   800a83 <file_get_block>
  800c24:	85 c0                	test   %eax,%eax
  800c26:	78 4c                	js     800c74 <walk_path+0x18f>
		  return r;
		f = (struct File*) blk;
  800c28:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800c33:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
		  return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800c36:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800c3c:	89 54 24 04          	mov    %edx,0x4(%esp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
		  return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
		  if (strcmp(f[j].f_name, name) == 0) {
  800c40:	89 34 24             	mov    %esi,(%esp)
  800c43:	e8 26 17 00 00       	call   80236e <strcmp>
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	0f 84 81 00 00 00    	je     800cd1 <walk_path+0x1ec>
  800c50:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
		  return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c56:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800c5c:	75 d5                	jne    800c33 <walk_path+0x14e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c5e:	ff 85 54 ff ff ff    	incl   -0xac(%ebp)
  800c64:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c6a:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  800c70:	75 90                	jne    800c02 <walk_path+0x11d>
  800c72:	eb 09                	jmp    800c7d <walk_path+0x198>

		if (dir->f_type != FTYPE_DIR)
		  return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c74:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800c77:	0f 85 a8 00 00 00    	jne    800d25 <walk_path+0x240>
  800c7d:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c83:	80 38 00             	cmpb   $0x0,(%eax)
  800c86:	0f 85 94 00 00 00    	jne    800d20 <walk_path+0x23b>
				if (pdir)
  800c8c:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800c93:	74 0e                	je     800ca3 <walk_path+0x1be>
				  *pdir = dir;
  800c95:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c9b:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800ca1:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  800ca3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ca7:	74 15                	je     800cbe <walk_path+0x1d9>
				  strcpy(lastelem, name);
  800ca9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	89 14 24             	mov    %edx,(%esp)
  800cb9:	e8 09 16 00 00       	call   8022c7 <strcpy>
				*pf = 0;
  800cbe:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cc4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800cca:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ccf:	eb 54                	jmp    800d25 <walk_path+0x240>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
		  return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
		  if (strcmp(f[j].f_name, name) == 0) {
  800cd1:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800cd7:	89 b5 50 ff ff ff    	mov    %esi,-0xb0(%ebp)
	name[0] = 0;

	if (pdir)
	  *pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cdd:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800ce3:	80 3a 00             	cmpb   $0x0,(%edx)
  800ce6:	0f 85 5f fe ff ff    	jne    800b4b <walk_path+0x66>
			}
			return r;
		}
	}

	if (pdir)
  800cec:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800cf3:	74 08                	je     800cfd <walk_path+0x218>
	  *pdir = dir;
  800cf5:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800cfb:	89 02                	mov    %eax,(%edx)
	*pf = f;
  800cfd:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800d03:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800d09:	89 10                	mov    %edx,(%eax)
	return 0;
  800d0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d10:	eb 13                	jmp    800d25 <walk_path+0x240>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
		  path++;
		if (path - p >= MAXNAMELEN)
		  return -E_BAD_PATH;
  800d12:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d17:	eb 0c                	jmp    800d25 <walk_path+0x240>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
		  return -E_NOT_FOUND;
  800d19:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800d1e:	eb 05                	jmp    800d25 <walk_path+0x240>
				  *pdir = dir;
				if (lastelem)
				  strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800d20:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	if (pdir)
	  *pdir = dir;
	*pf = f;
	return 0;
}
  800d25:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800d36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	e8 98 fd ff ff       	call   800ae5 <walk_path>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 3c             	sub    $0x3c,%esp
  800d58:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d5e:	8b 45 14             	mov    0x14(%ebp),%eax
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d61:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d64:	8b 93 80 00 00 00    	mov    0x80(%ebx),%edx
  800d6a:	39 c2                	cmp    %eax,%edx
  800d6c:	0f 8e 8a 00 00 00    	jle    800dfc <file_read+0xad>
	  return 0;

	count = MIN(count, f->f_size - offset);
  800d72:	29 c2                	sub    %eax,%edx
  800d74:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800d77:	39 ca                	cmp    %ecx,%edx
  800d79:	76 03                	jbe    800d7e <file_read+0x2f>
  800d7b:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	03 45 d0             	add    -0x30(%ebp),%eax
  800d83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d86:	eb 68                	jmp    800df0 <file_read+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d88:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d8f:	89 d8                	mov    %ebx,%eax
  800d91:	85 db                	test   %ebx,%ebx
  800d93:	79 06                	jns    800d9b <file_read+0x4c>
  800d95:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800d9b:	c1 f8 0c             	sar    $0xc,%eax
  800d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da2:	8b 45 08             	mov    0x8(%ebp),%eax
  800da5:	89 04 24             	mov    %eax,(%esp)
  800da8:	e8 d6 fc ff ff       	call   800a83 <file_get_block>
  800dad:	85 c0                	test   %eax,%eax
  800daf:	78 50                	js     800e01 <file_read+0xb2>
		  return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800db8:	79 07                	jns    800dc1 <file_read+0x72>
  800dba:	48                   	dec    %eax
  800dbb:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800dc0:	40                   	inc    %eax
  800dc1:	89 c2                	mov    %eax,%edx
  800dc3:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800dc8:	29 c1                	sub    %eax,%ecx
  800dca:	89 c8                	mov    %ecx,%eax
  800dcc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800dcf:	29 f1                	sub    %esi,%ecx
  800dd1:	89 c6                	mov    %eax,%esi
  800dd3:	39 c8                	cmp    %ecx,%eax
  800dd5:	76 02                	jbe    800dd9 <file_read+0x8a>
  800dd7:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800dd9:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ddd:	03 55 e4             	add    -0x1c(%ebp),%edx
  800de0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800de4:	89 3c 24             	mov    %edi,(%esp)
  800de7:	e8 54 16 00 00       	call   802440 <memmove>
		pos += bn;
  800dec:	01 f3                	add    %esi,%ebx
		buf += bn;
  800dee:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
	  return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800df0:	89 de                	mov    %ebx,%esi
  800df2:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800df5:	72 91                	jb     800d88 <file_read+0x39>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800df7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800dfa:	eb 05                	jmp    800e01 <file_read+0xb2>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
	  return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800e01:	83 c4 3c             	add    $0x3c,%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 3c             	sub    $0x3c,%esp
  800e12:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800e15:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e1b:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800e1e:	0f 8e 9c 00 00 00    	jle    800ec0 <file_set_size+0xb7>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800e24:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e29:	89 c7                	mov    %eax,%edi
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	79 06                	jns    800e35 <file_set_size+0x2c>
  800e2f:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
  800e35:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e40:	89 c2                	mov    %eax,%edx
  800e42:	85 c0                	test   %eax,%eax
  800e44:	79 06                	jns    800e4c <file_set_size+0x43>
  800e46:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800e4c:	c1 fa 0c             	sar    $0xc,%edx
  800e4f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e52:	89 d3                	mov    %edx,%ebx
  800e54:	eb 44                	jmp    800e9a <file_set_size+0x91>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5d:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e60:	89 da                	mov    %ebx,%edx
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	e8 47 fa ff ff       	call   8008b0 <file_block_walk>
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 1c                	js     800e89 <file_set_size+0x80>
	  return r;
	if (*ptr) {
  800e6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e70:	8b 00                	mov    (%eax),%eax
  800e72:	85 c0                	test   %eax,%eax
  800e74:	74 23                	je     800e99 <file_set_size+0x90>
		free_block(*ptr);
  800e76:	89 04 24             	mov    %eax,(%esp)
  800e79:	e8 8d f9 ff ff       	call   80080b <free_block>
		*ptr = 0;
  800e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e87:	eb 10                	jmp    800e99 <file_set_size+0x90>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
	  if ((r = file_free_block(f, bno)) < 0)
		cprintf("warning: file_free_block: %e", r);
  800e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8d:	c7 04 24 8c 43 80 00 	movl   $0x80438c,(%esp)
  800e94:	e8 83 0e 00 00       	call   801d1c <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e99:	43                   	inc    %ebx
  800e9a:	39 df                	cmp    %ebx,%edi
  800e9c:	77 b8                	ja     800e56 <file_set_size+0x4d>
	  if ((r = file_free_block(f, bno)) < 0)
		cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e9e:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800ea2:	77 1c                	ja     800ec0 <file_set_size+0xb7>
  800ea4:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	74 12                	je     800ec0 <file_set_size+0xb7>
		free_block(f->f_indirect);
  800eae:	89 04 24             	mov    %eax,(%esp)
  800eb1:	e8 55 f9 ff ff       	call   80080b <free_block>
		f->f_indirect = 0;
  800eb6:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800ebd:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
	  file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec3:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800ec9:	89 34 24             	mov    %esi,(%esp)
  800ecc:	e8 b8 f5 ff ff       	call   800489 <flush_block>
	return 0;
}
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	83 c4 3c             	add    $0x3c,%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 3c             	sub    $0x3c,%esp
  800ee7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800eea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800eed:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef0:	01 d8                	add    %ebx,%eax
  800ef2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ef5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef8:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800efe:	76 7a                	jbe    800f7a <file_write+0x9c>
	  if ((r = file_set_size(f, offset + count)) < 0)
  800f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f04:	89 14 24             	mov    %edx,(%esp)
  800f07:	e8 fd fe ff ff       	call   800e09 <file_set_size>
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	79 6a                	jns    800f7a <file_write+0x9c>
  800f10:	eb 72                	jmp    800f84 <file_write+0xa6>
		return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800f12:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f15:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f19:	89 d8                	mov    %ebx,%eax
  800f1b:	85 db                	test   %ebx,%ebx
  800f1d:	79 06                	jns    800f25 <file_write+0x47>
  800f1f:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f25:	c1 f8 0c             	sar    $0xc,%eax
  800f28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2f:	89 0c 24             	mov    %ecx,(%esp)
  800f32:	e8 4c fb ff ff       	call   800a83 <file_get_block>
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 49                	js     800f84 <file_write+0xa6>
		  return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800f42:	79 07                	jns    800f4b <file_write+0x6d>
  800f44:	48                   	dec    %eax
  800f45:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800f4a:	40                   	inc    %eax
  800f4b:	89 c2                	mov    %eax,%edx
  800f4d:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f52:	29 c1                	sub    %eax,%ecx
  800f54:	89 c8                	mov    %ecx,%eax
  800f56:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f59:	29 f1                	sub    %esi,%ecx
  800f5b:	89 c6                	mov    %eax,%esi
  800f5d:	39 c8                	cmp    %ecx,%eax
  800f5f:	76 02                	jbe    800f63 <file_write+0x85>
  800f61:	89 ce                	mov    %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f63:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f6b:	03 55 e4             	add    -0x1c(%ebp),%edx
  800f6e:	89 14 24             	mov    %edx,(%esp)
  800f71:	e8 ca 14 00 00       	call   802440 <memmove>
		pos += bn;
  800f76:	01 f3                	add    %esi,%ebx
		buf += bn;
  800f78:	01 f7                	add    %esi,%edi
	// Extend file if necessary
	if (offset + count > f->f_size)
	  if ((r = file_set_size(f, offset + count)) < 0)
		return r;

	for (pos = offset; pos < offset + count; ) {
  800f7a:	89 de                	mov    %ebx,%esi
  800f7c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800f7f:	77 91                	ja     800f12 <file_write+0x34>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f81:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f84:	83 c4 3c             	add    $0x3c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 20             	sub    $0x20,%esp
  800f94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f97:	be 00 00 00 00       	mov    $0x0,%esi
  800f9c:	eb 35                	jmp    800fd3 <file_flush+0x47>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800fa8:	89 f2                	mov    %esi,%edx
  800faa:	89 d8                	mov    %ebx,%eax
  800fac:	e8 ff f8 ff ff       	call   8008b0 <file_block_walk>
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 1d                	js     800fd2 <file_flush+0x46>
					pdiskbno == NULL || *pdiskbno == 0)
  800fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	74 16                	je     800fd2 <file_flush+0x46>
					pdiskbno == NULL || *pdiskbno == 0)
  800fbc:	8b 00                	mov    (%eax),%eax
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	74 10                	je     800fd2 <file_flush+0x46>
		  continue;
		flush_block(diskaddr(*pdiskbno));
  800fc2:	89 04 24             	mov    %eax,(%esp)
  800fc5:	e8 35 f4 ff ff       	call   8003ff <diskaddr>
  800fca:	89 04 24             	mov    %eax,(%esp)
  800fcd:	e8 b7 f4 ff ff       	call   800489 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fd2:	46                   	inc    %esi
  800fd3:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800fd9:	05 ff 0f 00 00       	add    $0xfff,%eax
  800fde:	89 c2                	mov    %eax,%edx
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	79 06                	jns    800fea <file_flush+0x5e>
  800fe4:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800fea:	c1 fa 0c             	sar    $0xc,%edx
  800fed:	39 d6                	cmp    %edx,%esi
  800fef:	7c ad                	jl     800f9e <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
					pdiskbno == NULL || *pdiskbno == 0)
		  continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800ff1:	89 1c 24             	mov    %ebx,(%esp)
  800ff4:	e8 90 f4 ff ff       	call   800489 <flush_block>
	if (f->f_indirect)
  800ff9:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800fff:	85 c0                	test   %eax,%eax
  801001:	74 10                	je     801013 <file_flush+0x87>
	  flush_block(diskaddr(f->f_indirect));
  801003:	89 04 24             	mov    %eax,(%esp)
  801006:	e8 f4 f3 ff ff       	call   8003ff <diskaddr>
  80100b:	89 04 24             	mov    %eax,(%esp)
  80100e:	e8 76 f4 ff ff       	call   800489 <flush_block>
}
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801026:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80102c:	89 04 24             	mov    %eax,(%esp)
  80102f:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801035:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	e8 a2 fa ff ff       	call   800ae5 <walk_path>
  801043:	85 c0                	test   %eax,%eax
  801045:	0f 84 dc 00 00 00    	je     801127 <file_create+0x10d>
	  return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80104b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80104e:	0f 85 d8 00 00 00    	jne    80112c <file_create+0x112>
  801054:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  80105a:	85 db                	test   %ebx,%ebx
  80105c:	0f 84 ca 00 00 00    	je     80112c <file_create+0x112>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801062:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801068:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80106d:	74 24                	je     801093 <file_create+0x79>
  80106f:	c7 44 24 0c 6f 43 80 	movl   $0x80436f,0xc(%esp)
  801076:	00 
  801077:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  801086:	00 
  801087:	c7 04 24 d7 42 80 00 	movl   $0x8042d7,(%esp)
  80108e:	e8 91 0b 00 00       	call   801c24 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801093:	89 c2                	mov    %eax,%edx
  801095:	85 c0                	test   %eax,%eax
  801097:	79 06                	jns    80109f <file_create+0x85>
  801099:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80109f:	c1 fa 0c             	sar    $0xc,%edx
  8010a2:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8010a8:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8010ad:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8010b3:	eb 38                	jmp    8010ed <file_create+0xd3>
  8010b5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010bd:	89 1c 24             	mov    %ebx,(%esp)
  8010c0:	e8 be f9 ff ff       	call   800a83 <file_get_block>
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	78 63                	js     80112c <file_create+0x112>
  8010c9:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
		  return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010cf:	ba 00 00 00 00       	mov    $0x0,%edx
		  if (f[j].f_name[0] == '\0') {
  8010d4:	80 38 00             	cmpb   $0x0,(%eax)
  8010d7:	75 08                	jne    8010e1 <file_create+0xc7>
			  *file = &f[j];
  8010d9:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8010df:	eb 56                	jmp    801137 <file_create+0x11d>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
		  return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010e1:	42                   	inc    %edx
  8010e2:	05 00 01 00 00       	add    $0x100,%eax
  8010e7:	83 fa 10             	cmp    $0x10,%edx
  8010ea:	75 e8                	jne    8010d4 <file_create+0xba>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8010ec:	46                   	inc    %esi
  8010ed:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  8010f3:	75 c0                	jne    8010b5 <file_create+0x9b>
		  if (f[j].f_name[0] == '\0') {
			  *file = &f[j];
			  return 0;
		  }
	}
	dir->f_size += BLKSIZE;
  8010f5:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  8010fc:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010ff:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801105:	89 44 24 08          	mov    %eax,0x8(%esp)
  801109:	89 74 24 04          	mov    %esi,0x4(%esp)
  80110d:	89 1c 24             	mov    %ebx,(%esp)
  801110:	e8 6e f9 ff ff       	call   800a83 <file_get_block>
  801115:	85 c0                	test   %eax,%eax
  801117:	78 13                	js     80112c <file_create+0x112>
	  return r;
	f = (struct File*) blk;
	*file = &f[0];
  801119:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  80111f:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801125:	eb 10                	jmp    801137 <file_create+0x11d>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
	  return -E_FILE_EXISTS;
  801127:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  80112c:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
	  return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
	  return r;

	strcpy(f->f_name, name);
  801137:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80113d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801141:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	e8 78 11 00 00       	call   8022c7 <strcpy>
	*pf = f;
  80114f:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801155:	8b 45 0c             	mov    0xc(%ebp),%eax
  801158:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80115a:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801160:	89 04 24             	mov    %eax,(%esp)
  801163:	e8 24 fe ff ff       	call   800f8c <file_flush>
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb bd                	jmp    80112c <file_create+0x112>

0080116f <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	53                   	push   %ebx
  801173:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801176:	bb 01 00 00 00       	mov    $0x1,%ebx
  80117b:	eb 11                	jmp    80118e <fs_sync+0x1f>
	  flush_block(diskaddr(i));
  80117d:	89 1c 24             	mov    %ebx,(%esp)
  801180:	e8 7a f2 ff ff       	call   8003ff <diskaddr>
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 fc f2 ff ff       	call   800489 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80118d:	43                   	inc    %ebx
  80118e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  801193:	3b 58 04             	cmp    0x4(%eax),%ebx
  801196:	72 e5                	jb     80117d <fs_sync+0xe>
	  flush_block(diskaddr(i));
}
  801198:	83 c4 14             	add    $0x14,%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    
	...

008011a0 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8011a6:	e8 c4 ff ff ff       	call   80116f <fs_sync>
	return 0;
}
  8011ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b0:	c9                   	leave  
  8011b1:	c3                   	ret    

008011b2 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011b5:	ba 60 50 80 00       	mov    $0x805060,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  8011ba:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011c4:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011c6:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011c9:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011cf:	40                   	inc    %eax
  8011d0:	83 c2 10             	add    $0x10,%edx
  8011d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d8:	75 ea                	jne    8011c4 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 10             	sub    $0x10,%esp
  8011e4:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8011e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  8011f1:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	e8 ed 1b 00 00       	call   802dec <pageref>
  8011ff:	85 c0                	test   %eax,%eax
  801201:	74 07                	je     80120a <openfile_alloc+0x2e>
  801203:	83 f8 01             	cmp    $0x1,%eax
  801206:	75 62                	jne    80126a <openfile_alloc+0x8e>
  801208:	eb 27                	jmp    801231 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80120a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801211:	00 
  801212:	89 d8                	mov    %ebx,%eax
  801214:	c1 e0 04             	shl    $0x4,%eax
  801217:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  80121d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801221:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801228:	e8 8c 14 00 00       	call   8026b9 <sys_page_alloc>
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 4b                	js     80127c <openfile_alloc+0xa0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801231:	c1 e3 04             	shl    $0x4,%ebx
  801234:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80123a:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801241:	04 00 00 
			*o = &opentab[i];
  801244:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801246:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80124d:	00 
  80124e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801255:	00 
  801256:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  80125c:	89 04 24             	mov    %eax,(%esp)
  80125f:	e8 92 11 00 00       	call   8023f6 <memset>
			return (*o)->o_fileid;
  801264:	8b 06                	mov    (%esi),%eax
  801266:	8b 00                	mov    (%eax),%eax
  801268:	eb 12                	jmp    80127c <openfile_alloc+0xa0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80126a:	43                   	inc    %ebx
  80126b:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801271:	0f 85 75 ff ff ff    	jne    8011ec <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801277:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 1c             	sub    $0x1c,%esp
  80128c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80128f:	89 fe                	mov    %edi,%esi
  801291:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801297:	c1 e6 04             	shl    $0x4,%esi
  80129a:	8d 9e 60 50 80 00    	lea    0x805060(%esi),%ebx
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8012a0:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  8012a6:	89 04 24             	mov    %eax,(%esp)
  8012a9:	e8 3e 1b 00 00       	call   802dec <pageref>
  8012ae:	83 f8 01             	cmp    $0x1,%eax
  8012b1:	7e 14                	jle    8012c7 <openfile_lookup+0x44>
  8012b3:	39 be 60 50 80 00    	cmp    %edi,0x805060(%esi)
  8012b9:	75 13                	jne    8012ce <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  8012bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8012be:	89 18                	mov    %ebx,(%eax)
	return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c5:	eb 0c                	jmp    8012d3 <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb 05                	jmp    8012d3 <openfile_lookup+0x50>
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8012d3:	83 c4 1c             	add    $0x1c,%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5f                   	pop    %edi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    

008012db <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8012db:	55                   	push   %ebp
  8012dc:	89 e5                	mov    %esp,%ebp
  8012de:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012eb:	8b 00                	mov    (%eax),%eax
  8012ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f4:	89 04 24             	mov    %eax,(%esp)
  8012f7:	e8 87 ff ff ff       	call   801283 <openfile_lookup>
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 13                	js     801313 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  801300:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801303:	8b 40 04             	mov    0x4(%eax),%eax
  801306:	89 04 24             	mov    %eax,(%esp)
  801309:	e8 7e fc ff ff       	call   800f8c <file_flush>
	return 0;
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	53                   	push   %ebx
  801319:	83 ec 24             	sub    $0x24,%esp
  80131c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	89 44 24 08          	mov    %eax,0x8(%esp)
  801326:	8b 03                	mov    (%ebx),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 4c ff ff ff       	call   801283 <openfile_lookup>
  801337:	85 c0                	test   %eax,%eax
  801339:	78 3f                	js     80137a <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80133b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133e:	8b 40 04             	mov    0x4(%eax),%eax
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	89 1c 24             	mov    %ebx,(%esp)
  801348:	e8 7a 0f 00 00       	call   8022c7 <strcpy>
	ret->ret_size = o->o_file->f_size;
  80134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801350:	8b 50 04             	mov    0x4(%eax),%edx
  801353:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801359:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80135f:	8b 40 04             	mov    0x4(%eax),%eax
  801362:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801369:	0f 94 c0             	sete   %al
  80136c:	0f b6 c0             	movzbl %al,%eax
  80136f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801375:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80137a:	83 c4 24             	add    $0x24,%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 24             	sub    $0x24,%esp
  801387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//panic("serve_write not implemented");

	int r;
	struct OpenFile* o;
	
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) 
  80138a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801391:	8b 03                	mov    (%ebx),%eax
  801393:	89 44 24 04          	mov    %eax,0x4(%esp)
  801397:	8b 45 08             	mov    0x8(%ebp),%eax
  80139a:	89 04 24             	mov    %eax,(%esp)
  80139d:	e8 e1 fe ff ff       	call   801283 <openfile_lookup>
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 33                	js     8013d9 <serve_write+0x59>
		return r;
	r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  8013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a9:	8b 50 0c             	mov    0xc(%eax),%edx
  8013ac:	8b 52 04             	mov    0x4(%edx),%edx
  8013af:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013b3:	8b 53 04             	mov    0x4(%ebx),%edx
  8013b6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013ba:	83 c3 08             	add    $0x8,%ebx
  8013bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c1:	8b 40 04             	mov    0x4(%eax),%eax
  8013c4:	89 04 24             	mov    %eax,(%esp)
  8013c7:	e8 12 fb ff ff       	call   800ede <file_write>
	if (r > 0)
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	7e 09                	jle    8013d9 <serve_write+0x59>
		o->o_fd->fd_offset += r;
  8013d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8013d6:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  8013d9:	83 c4 24             	add    $0x24,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 24             	sub    $0x24,%esp
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:
	
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f0:	8b 03                	mov    (%ebx),%eax
  8013f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	89 04 24             	mov    %eax,(%esp)
  8013fc:	e8 82 fe ff ff       	call   801283 <openfile_lookup>
  801401:	85 c0                	test   %eax,%eax
  801403:	78 30                	js     801435 <serve_read+0x56>
		return r;
	
	r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset);
  801405:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801408:	8b 50 0c             	mov    0xc(%eax),%edx
  80140b:	8b 52 04             	mov    0x4(%edx),%edx
  80140e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801412:	8b 53 04             	mov    0x4(%ebx),%edx
  801415:	89 54 24 08          	mov    %edx,0x8(%esp)
  801419:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80141d:	8b 40 04             	mov    0x4(%eax),%eax
  801420:	89 04 24             	mov    %eax,(%esp)
  801423:	e8 27 f9 ff ff       	call   800d4f <file_read>
	if (r > 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	7e 09                	jle    801435 <serve_read+0x56>
		o->o_fd->fd_offset += r;
  80142c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80142f:	8b 52 0c             	mov    0xc(%edx),%edx
  801432:	01 42 04             	add    %eax,0x4(%edx)
	return r;
}
  801435:	83 c4 24             	add    $0x24,%esp
  801438:	5b                   	pop    %ebx
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	53                   	push   %ebx
  80143f:	83 ec 24             	sub    $0x24,%esp
  801442:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144c:	8b 03                	mov    (%ebx),%eax
  80144e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801452:	8b 45 08             	mov    0x8(%ebp),%eax
  801455:	89 04 24             	mov    %eax,(%esp)
  801458:	e8 26 fe ff ff       	call   801283 <openfile_lookup>
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 15                	js     801476 <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801461:	8b 43 04             	mov    0x4(%ebx),%eax
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146b:	8b 40 04             	mov    0x4(%eax),%eax
  80146e:	89 04 24             	mov    %eax,(%esp)
  801471:	e8 93 f9 ff ff       	call   800e09 <file_set_size>
}
  801476:	83 c4 24             	add    $0x24,%esp
  801479:	5b                   	pop    %ebx
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	81 ec 24 04 00 00    	sub    $0x424,%esp
  801486:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801489:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801490:	00 
  801491:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801495:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 9d 0f 00 00       	call   802440 <memmove>
	path[MAXPATHLEN-1] = 0;
  8014a3:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  8014a7:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 27 fd ff ff       	call   8011dc <openfile_alloc>
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	0f 88 f0 00 00 00    	js     8015ad <serve_open+0x131>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  8014bd:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  8014c4:	74 32                	je     8014f8 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  8014c6:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d0:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014d6:	89 04 24             	mov    %eax,(%esp)
  8014d9:	e8 3c fb ff ff       	call   80101a <file_create>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	79 36                	jns    801518 <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  8014e2:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8014e9:	0f 85 be 00 00 00    	jne    8015ad <serve_open+0x131>
  8014ef:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014f2:	0f 85 b5 00 00 00    	jne    8015ad <serve_open+0x131>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8014f8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801502:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801508:	89 04 24             	mov    %eax,(%esp)
  80150b:	e8 20 f8 ff ff       	call   800d30 <file_open>
  801510:	85 c0                	test   %eax,%eax
  801512:	0f 88 95 00 00 00    	js     8015ad <serve_open+0x131>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801518:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80151f:	74 1a                	je     80153b <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  801521:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801528:	00 
  801529:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  80152f:	89 04 24             	mov    %eax,(%esp)
  801532:	e8 d2 f8 ff ff       	call   800e09 <file_set_size>
  801537:	85 c0                	test   %eax,%eax
  801539:	78 72                	js     8015ad <serve_open+0x131>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  80153b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801541:	89 44 24 04          	mov    %eax,0x4(%esp)
  801545:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80154b:	89 04 24             	mov    %eax,(%esp)
  80154e:	e8 dd f7 ff ff       	call   800d30 <file_open>
  801553:	85 c0                	test   %eax,%eax
  801555:	78 56                	js     8015ad <serve_open+0x131>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801557:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80155d:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801563:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801566:	8b 50 0c             	mov    0xc(%eax),%edx
  801569:	8b 08                	mov    (%eax),%ecx
  80156b:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  80156e:	8b 50 0c             	mov    0xc(%eax),%edx
  801571:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  801577:	83 e1 03             	and    $0x3,%ecx
  80157a:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  80157d:	8b 40 0c             	mov    0xc(%eax),%eax
  801580:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801586:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801588:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80158e:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801594:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801597:	8b 50 0c             	mov    0xc(%eax),%edx
  80159a:	8b 45 10             	mov    0x10(%ebp),%eax
  80159d:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ad:	81 c4 24 04 00 00    	add    $0x424,%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015be:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8015c1:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  8015c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8015cb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015cf:	a1 44 50 80 00       	mov    0x805044,%eax
  8015d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d8:	89 34 24             	mov    %esi,(%esp)
  8015db:	e8 5c 14 00 00       	call   802a3c <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  8015e0:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8015e4:	75 15                	jne    8015fb <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  8015e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	c7 04 24 d8 43 80 00 	movl   $0x8043d8,(%esp)
  8015f4:	e8 23 07 00 00       	call   801d1c <cprintf>
				whom);
			continue; // just leave it hanging...
  8015f9:	eb c9                	jmp    8015c4 <serve+0xe>
		}

		pg = NULL;
  8015fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801602:	83 f8 01             	cmp    $0x1,%eax
  801605:	75 21                	jne    801628 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801607:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80160b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80160e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801612:	a1 44 50 80 00       	mov    0x805044,%eax
  801617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	89 04 24             	mov    %eax,(%esp)
  801621:	e8 56 fe ff ff       	call   80147c <serve_open>
  801626:	eb 3f                	jmp    801667 <serve+0xb1>
		} else if (req < NHANDLERS && handlers[req]) {
  801628:	83 f8 08             	cmp    $0x8,%eax
  80162b:	77 1e                	ja     80164b <serve+0x95>
  80162d:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801634:	85 d2                	test   %edx,%edx
  801636:	74 13                	je     80164b <serve+0x95>
			r = handlers[req](whom, fsreq);
  801638:	a1 44 50 80 00       	mov    0x805044,%eax
  80163d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801641:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801644:	89 04 24             	mov    %eax,(%esp)
  801647:	ff d2                	call   *%edx
  801649:	eb 1c                	jmp    801667 <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80164b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801652:	89 44 24 04          	mov    %eax,0x4(%esp)
  801656:	c7 04 24 08 44 80 00 	movl   $0x804408,(%esp)
  80165d:	e8 ba 06 00 00       	call   801d1c <cprintf>
			r = -E_INVAL;
  801662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801667:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80166a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80166e:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801671:	89 54 24 08          	mov    %edx,0x8(%esp)
  801675:	89 44 24 04          	mov    %eax,0x4(%esp)
  801679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167c:	89 04 24             	mov    %eax,(%esp)
  80167f:	e8 21 14 00 00       	call   802aa5 <ipc_send>
		sys_page_unmap(0, fsreq);
  801684:	a1 44 50 80 00       	mov    0x805044,%eax
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801694:	e8 c7 10 00 00       	call   802760 <sys_page_unmap>
  801699:	e9 26 ff ff ff       	jmp    8015c4 <serve+0xe>

0080169e <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8016a4:	c7 05 60 90 80 00 2b 	movl   $0x80442b,0x809060
  8016ab:	44 80 00 
	cprintf("FS is running\n");
  8016ae:	c7 04 24 2e 44 80 00 	movl   $0x80442e,(%esp)
  8016b5:	e8 62 06 00 00       	call   801d1c <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  8016ba:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  8016bf:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  8016c4:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  8016c6:	c7 04 24 3d 44 80 00 	movl   $0x80443d,(%esp)
  8016cd:	e8 4a 06 00 00       	call   801d1c <cprintf>

	serve_init();
  8016d2:	e8 db fa ff ff       	call   8011b2 <serve_init>
	fs_init();
  8016d7:	e8 4b f3 ff ff       	call   800a27 <fs_init>
    //fs_test();
	serve();
  8016dc:	e8 d5 fe ff ff       	call   8015b6 <serve>
  8016e1:	00 00                	add    %al,(%eax)
	...

008016e4 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8016eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016f2:	00 
  8016f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  8016fa:	00 
  8016fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801702:	e8 b2 0f 00 00       	call   8026b9 <sys_page_alloc>
  801707:	85 c0                	test   %eax,%eax
  801709:	79 20                	jns    80172b <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80170b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80170f:	c7 44 24 08 4c 44 80 	movl   $0x80444c,0x8(%esp)
  801716:	00 
  801717:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  80171e:	00 
  80171f:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801726:	e8 f9 04 00 00       	call   801c24 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80172b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801732:	00 
  801733:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173c:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801743:	e8 f8 0c 00 00       	call   802440 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801748:	e8 00 f1 ff ff       	call   80084d <alloc_block>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	79 20                	jns    801771 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801751:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801755:	c7 44 24 08 69 44 80 	movl   $0x804469,0x8(%esp)
  80175c:	00 
  80175d:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  801764:	00 
  801765:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  80176c:	e8 b3 04 00 00       	call   801c24 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801771:	89 c2                	mov    %eax,%edx
  801773:	85 c0                	test   %eax,%eax
  801775:	79 03                	jns    80177a <fs_test+0x96>
  801777:	8d 50 1f             	lea    0x1f(%eax),%edx
  80177a:	c1 fa 05             	sar    $0x5,%edx
  80177d:	c1 e2 02             	shl    $0x2,%edx
  801780:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801785:	79 05                	jns    80178c <fs_test+0xa8>
  801787:	48                   	dec    %eax
  801788:	83 c8 e0             	or     $0xffffffe0,%eax
  80178b:	40                   	inc    %eax
  80178c:	bb 01 00 00 00       	mov    $0x1,%ebx
  801791:	88 c1                	mov    %al,%cl
  801793:	d3 e3                	shl    %cl,%ebx
  801795:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  80179b:	75 24                	jne    8017c1 <fs_test+0xdd>
  80179d:	c7 44 24 0c 79 44 80 	movl   $0x804479,0xc(%esp)
  8017a4:	00 
  8017a5:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8017ac:	00 
  8017ad:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  8017b4:	00 
  8017b5:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  8017bc:	e8 63 04 00 00       	call   801c24 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017c1:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8017c7:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  8017ca:	74 24                	je     8017f0 <fs_test+0x10c>
  8017cc:	c7 44 24 0c f4 45 80 	movl   $0x8045f4,0xc(%esp)
  8017d3:	00 
  8017d4:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8017db:	00 
  8017dc:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8017e3:	00 
  8017e4:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  8017eb:	e8 34 04 00 00       	call   801c24 <_panic>
	cprintf("alloc_block is good\n");
  8017f0:	c7 04 24 94 44 80 00 	movl   $0x804494,(%esp)
  8017f7:	e8 20 05 00 00       	call   801d1c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8017fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	c7 04 24 a9 44 80 00 	movl   $0x8044a9,(%esp)
  80180a:	e8 21 f5 ff ff       	call   800d30 <file_open>
  80180f:	85 c0                	test   %eax,%eax
  801811:	79 25                	jns    801838 <fs_test+0x154>
  801813:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801816:	74 40                	je     801858 <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  801818:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80181c:	c7 44 24 08 b4 44 80 	movl   $0x8044b4,0x8(%esp)
  801823:	00 
  801824:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80182b:	00 
  80182c:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801833:	e8 ec 03 00 00       	call   801c24 <_panic>
	else if (r == 0)
  801838:	85 c0                	test   %eax,%eax
  80183a:	75 1c                	jne    801858 <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  80183c:	c7 44 24 08 14 46 80 	movl   $0x804614,0x8(%esp)
  801843:	00 
  801844:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80184b:	00 
  80184c:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801853:	e8 cc 03 00 00       	call   801c24 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801858:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185f:	c7 04 24 cd 44 80 00 	movl   $0x8044cd,(%esp)
  801866:	e8 c5 f4 ff ff       	call   800d30 <file_open>
  80186b:	85 c0                	test   %eax,%eax
  80186d:	79 20                	jns    80188f <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  80186f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801873:	c7 44 24 08 d6 44 80 	movl   $0x8044d6,0x8(%esp)
  80187a:	00 
  80187b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801882:	00 
  801883:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  80188a:	e8 95 03 00 00       	call   801c24 <_panic>
	cprintf("file_open is good\n");
  80188f:	c7 04 24 ed 44 80 00 	movl   $0x8044ed,(%esp)
  801896:	e8 81 04 00 00       	call   801d1c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80189b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018a9:	00 
  8018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ad:	89 04 24             	mov    %eax,(%esp)
  8018b0:	e8 ce f1 ff ff       	call   800a83 <file_get_block>
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	79 20                	jns    8018d9 <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  8018b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018bd:	c7 44 24 08 00 45 80 	movl   $0x804500,0x8(%esp)
  8018c4:	00 
  8018c5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8018cc:	00 
  8018cd:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  8018d4:	e8 4b 03 00 00       	call   801c24 <_panic>
	if (strcmp(blk, msg) != 0)
  8018d9:	c7 44 24 04 34 46 80 	movl   $0x804634,0x4(%esp)
  8018e0:	00 
  8018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e4:	89 04 24             	mov    %eax,(%esp)
  8018e7:	e8 82 0a 00 00       	call   80236e <strcmp>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	74 1c                	je     80190c <fs_test+0x228>
		panic("file_get_block returned wrong data");
  8018f0:	c7 44 24 08 5c 46 80 	movl   $0x80465c,0x8(%esp)
  8018f7:	00 
  8018f8:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8018ff:	00 
  801900:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801907:	e8 18 03 00 00       	call   801c24 <_panic>
	cprintf("file_get_block is good\n");
  80190c:	c7 04 24 13 45 80 00 	movl   $0x804513,(%esp)
  801913:	e8 04 04 00 00       	call   801d1c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801918:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191b:	8a 10                	mov    (%eax),%dl
  80191d:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80191f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801922:	c1 e8 0c             	shr    $0xc,%eax
  801925:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80192c:	a8 40                	test   $0x40,%al
  80192e:	75 24                	jne    801954 <fs_test+0x270>
  801930:	c7 44 24 0c 2c 45 80 	movl   $0x80452c,0xc(%esp)
  801937:	00 
  801938:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  80193f:	00 
  801940:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801947:	00 
  801948:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  80194f:	e8 d0 02 00 00       	call   801c24 <_panic>
	file_flush(f);
  801954:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801957:	89 04 24             	mov    %eax,(%esp)
  80195a:	e8 2d f6 ff ff       	call   800f8c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80195f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801962:	c1 e8 0c             	shr    $0xc,%eax
  801965:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80196c:	a8 40                	test   $0x40,%al
  80196e:	74 24                	je     801994 <fs_test+0x2b0>
  801970:	c7 44 24 0c 2b 45 80 	movl   $0x80452b,0xc(%esp)
  801977:	00 
  801978:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  80197f:	00 
  801980:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801987:	00 
  801988:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  80198f:	e8 90 02 00 00       	call   801c24 <_panic>
	cprintf("file_flush is good\n");
  801994:	c7 04 24 47 45 80 00 	movl   $0x804547,(%esp)
  80199b:	e8 7c 03 00 00       	call   801d1c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8019a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019a7:	00 
  8019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ab:	89 04 24             	mov    %eax,(%esp)
  8019ae:	e8 56 f4 ff ff       	call   800e09 <file_set_size>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	79 20                	jns    8019d7 <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  8019b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bb:	c7 44 24 08 5b 45 80 	movl   $0x80455b,0x8(%esp)
  8019c2:	00 
  8019c3:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8019ca:	00 
  8019cb:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  8019d2:	e8 4d 02 00 00       	call   801c24 <_panic>
	assert(f->f_direct[0] == 0);
  8019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019da:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8019e1:	74 24                	je     801a07 <fs_test+0x323>
  8019e3:	c7 44 24 0c 6d 45 80 	movl   $0x80456d,0xc(%esp)
  8019ea:	00 
  8019eb:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8019f2:	00 
  8019f3:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8019fa:	00 
  8019fb:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801a02:	e8 1d 02 00 00       	call   801c24 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a07:	c1 e8 0c             	shr    $0xc,%eax
  801a0a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a11:	a8 40                	test   $0x40,%al
  801a13:	74 24                	je     801a39 <fs_test+0x355>
  801a15:	c7 44 24 0c 81 45 80 	movl   $0x804581,0xc(%esp)
  801a1c:	00 
  801a1d:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  801a24:	00 
  801a25:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801a2c:	00 
  801a2d:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801a34:	e8 eb 01 00 00       	call   801c24 <_panic>
	cprintf("file_truncate is good\n");
  801a39:	c7 04 24 9b 45 80 00 	movl   $0x80459b,(%esp)
  801a40:	e8 d7 02 00 00       	call   801d1c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801a45:	c7 04 24 34 46 80 00 	movl   $0x804634,(%esp)
  801a4c:	e8 43 08 00 00       	call   802294 <strlen>
  801a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a58:	89 04 24             	mov    %eax,(%esp)
  801a5b:	e8 a9 f3 ff ff       	call   800e09 <file_set_size>
  801a60:	85 c0                	test   %eax,%eax
  801a62:	79 20                	jns    801a84 <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  801a64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a68:	c7 44 24 08 b2 45 80 	movl   $0x8045b2,0x8(%esp)
  801a6f:	00 
  801a70:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801a77:	00 
  801a78:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801a7f:	e8 a0 01 00 00       	call   801c24 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a87:	89 c2                	mov    %eax,%edx
  801a89:	c1 ea 0c             	shr    $0xc,%edx
  801a8c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a93:	f6 c2 40             	test   $0x40,%dl
  801a96:	74 24                	je     801abc <fs_test+0x3d8>
  801a98:	c7 44 24 0c 81 45 80 	movl   $0x804581,0xc(%esp)
  801a9f:	00 
  801aa0:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  801aa7:	00 
  801aa8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801aaf:	00 
  801ab0:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801ab7:	e8 68 01 00 00       	call   801c24 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801abc:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801abf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ac3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aca:	00 
  801acb:	89 04 24             	mov    %eax,(%esp)
  801ace:	e8 b0 ef ff ff       	call   800a83 <file_get_block>
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	79 20                	jns    801af7 <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801ad7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801adb:	c7 44 24 08 c6 45 80 	movl   $0x8045c6,0x8(%esp)
  801ae2:	00 
  801ae3:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801aea:	00 
  801aeb:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801af2:	e8 2d 01 00 00       	call   801c24 <_panic>
	strcpy(blk, msg);
  801af7:	c7 44 24 04 34 46 80 	movl   $0x804634,0x4(%esp)
  801afe:	00 
  801aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 bd 07 00 00       	call   8022c7 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b0d:	c1 e8 0c             	shr    $0xc,%eax
  801b10:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b17:	a8 40                	test   $0x40,%al
  801b19:	75 24                	jne    801b3f <fs_test+0x45b>
  801b1b:	c7 44 24 0c 2c 45 80 	movl   $0x80452c,0xc(%esp)
  801b22:	00 
  801b23:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  801b2a:	00 
  801b2b:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801b32:	00 
  801b33:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801b3a:	e8 e5 00 00 00       	call   801c24 <_panic>
	file_flush(f);
  801b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 42 f4 ff ff       	call   800f8c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4d:	c1 e8 0c             	shr    $0xc,%eax
  801b50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b57:	a8 40                	test   $0x40,%al
  801b59:	74 24                	je     801b7f <fs_test+0x49b>
  801b5b:	c7 44 24 0c 2b 45 80 	movl   $0x80452b,0xc(%esp)
  801b62:	00 
  801b63:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  801b6a:	00 
  801b6b:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801b72:	00 
  801b73:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801b7a:	e8 a5 00 00 00       	call   801c24 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	c1 e8 0c             	shr    $0xc,%eax
  801b85:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b8c:	a8 40                	test   $0x40,%al
  801b8e:	74 24                	je     801bb4 <fs_test+0x4d0>
  801b90:	c7 44 24 0c 81 45 80 	movl   $0x804581,0xc(%esp)
  801b97:	00 
  801b98:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  801b9f:	00 
  801ba0:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801ba7:	00 
  801ba8:	c7 04 24 5f 44 80 00 	movl   $0x80445f,(%esp)
  801baf:	e8 70 00 00 00       	call   801c24 <_panic>
	cprintf("file rewrite is good\n");
  801bb4:	c7 04 24 db 45 80 00 	movl   $0x8045db,(%esp)
  801bbb:	e8 5c 01 00 00       	call   801d1c <cprintf>
}
  801bc0:	83 c4 24             	add    $0x24,%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    
	...

00801bc8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 10             	sub    $0x10,%esp
  801bd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801bd6:	e8 a0 0a 00 00       	call   80267b <sys_getenvid>
  801bdb:	25 ff 03 00 00       	and    $0x3ff,%eax
  801be0:	c1 e0 07             	shl    $0x7,%eax
  801be3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801be8:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801bed:	85 f6                	test   %esi,%esi
  801bef:	7e 07                	jle    801bf8 <libmain+0x30>
		binaryname = argv[0];
  801bf1:	8b 03                	mov    (%ebx),%eax
  801bf3:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801bf8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	e8 9a fa ff ff       	call   80169e <umain>

	// exit gracefully
	exit();
  801c04:	e8 07 00 00 00       	call   801c10 <exit>
}
  801c09:	83 c4 10             	add    $0x10,%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  801c16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1d:	e8 07 0a 00 00       	call   802629 <sys_env_destroy>
}
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	56                   	push   %esi
  801c28:	53                   	push   %ebx
  801c29:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c2c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c2f:	8b 1d 60 90 80 00    	mov    0x809060,%ebx
  801c35:	e8 41 0a 00 00       	call   80267b <sys_getenvid>
  801c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c41:	8b 55 08             	mov    0x8(%ebp),%edx
  801c44:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c50:	c7 04 24 8c 46 80 00 	movl   $0x80468c,(%esp)
  801c57:	e8 c0 00 00 00       	call   801d1c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c60:	8b 45 10             	mov    0x10(%ebp),%eax
  801c63:	89 04 24             	mov    %eax,(%esp)
  801c66:	e8 50 00 00 00       	call   801cbb <vcprintf>
	cprintf("\n");
  801c6b:	c7 04 24 6e 42 80 00 	movl   $0x80426e,(%esp)
  801c72:	e8 a5 00 00 00       	call   801d1c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c77:	cc                   	int3   
  801c78:	eb fd                	jmp    801c77 <_panic+0x53>
	...

00801c7c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	53                   	push   %ebx
  801c80:	83 ec 14             	sub    $0x14,%esp
  801c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801c86:	8b 03                	mov    (%ebx),%eax
  801c88:	8b 55 08             	mov    0x8(%ebp),%edx
  801c8b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801c8f:	40                   	inc    %eax
  801c90:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801c92:	3d ff 00 00 00       	cmp    $0xff,%eax
  801c97:	75 19                	jne    801cb2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801c99:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801ca0:	00 
  801ca1:	8d 43 08             	lea    0x8(%ebx),%eax
  801ca4:	89 04 24             	mov    %eax,(%esp)
  801ca7:	e8 40 09 00 00       	call   8025ec <sys_cputs>
		b->idx = 0;
  801cac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801cb2:	ff 43 04             	incl   0x4(%ebx)
}
  801cb5:	83 c4 14             	add    $0x14,%esp
  801cb8:	5b                   	pop    %ebx
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801cc4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ccb:	00 00 00 
	b.cnt = 0;
  801cce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801cd5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801cec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf0:	c7 04 24 7c 1c 80 00 	movl   $0x801c7c,(%esp)
  801cf7:	e8 82 01 00 00       	call   801e7e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801cfc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d06:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d0c:	89 04 24             	mov    %eax,(%esp)
  801d0f:	e8 d8 08 00 00       	call   8025ec <sys_cputs>

	return b.cnt;
}
  801d14:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d22:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801d25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	89 04 24             	mov    %eax,(%esp)
  801d2f:	e8 87 ff ff ff       	call   801cbb <vcprintf>
	va_end(ap);

	return cnt;
}
  801d34:	c9                   	leave  
  801d35:	c3                   	ret    
	...

00801d38 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	57                   	push   %edi
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 3c             	sub    $0x3c,%esp
  801d41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d44:	89 d7                	mov    %edx,%edi
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d52:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801d55:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	75 08                	jne    801d64 <printnum+0x2c>
  801d5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d5f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801d62:	77 57                	ja     801dbb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801d64:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d68:	4b                   	dec    %ebx
  801d69:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d74:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801d78:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801d7c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d83:	00 
  801d84:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d87:	89 04 24             	mov    %eax,(%esp)
  801d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d91:	e8 9e 20 00 00       	call   803e34 <__udivdi3>
  801d96:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d9a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da5:	89 fa                	mov    %edi,%edx
  801da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801daa:	e8 89 ff ff ff       	call   801d38 <printnum>
  801daf:	eb 0f                	jmp    801dc0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801db1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801db5:	89 34 24             	mov    %esi,(%esp)
  801db8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801dbb:	4b                   	dec    %ebx
  801dbc:	85 db                	test   %ebx,%ebx
  801dbe:	7f f1                	jg     801db1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801dc0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dc4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dc8:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dd6:	00 
  801dd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801dda:	89 04 24             	mov    %eax,(%esp)
  801ddd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801de0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de4:	e8 6b 21 00 00       	call   803f54 <__umoddi3>
  801de9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ded:	0f be 80 af 46 80 00 	movsbl 0x8046af(%eax),%eax
  801df4:	89 04 24             	mov    %eax,(%esp)
  801df7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801dfa:	83 c4 3c             	add    $0x3c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801e05:	83 fa 01             	cmp    $0x1,%edx
  801e08:	7e 0e                	jle    801e18 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801e0a:	8b 10                	mov    (%eax),%edx
  801e0c:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e0f:	89 08                	mov    %ecx,(%eax)
  801e11:	8b 02                	mov    (%edx),%eax
  801e13:	8b 52 04             	mov    0x4(%edx),%edx
  801e16:	eb 22                	jmp    801e3a <getuint+0x38>
	else if (lflag)
  801e18:	85 d2                	test   %edx,%edx
  801e1a:	74 10                	je     801e2c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801e1c:	8b 10                	mov    (%eax),%edx
  801e1e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e21:	89 08                	mov    %ecx,(%eax)
  801e23:	8b 02                	mov    (%edx),%eax
  801e25:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2a:	eb 0e                	jmp    801e3a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801e2c:	8b 10                	mov    (%eax),%edx
  801e2e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e31:	89 08                	mov    %ecx,(%eax)
  801e33:	8b 02                	mov    (%edx),%eax
  801e35:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    

00801e3c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801e42:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801e45:	8b 10                	mov    (%eax),%edx
  801e47:	3b 50 04             	cmp    0x4(%eax),%edx
  801e4a:	73 08                	jae    801e54 <sprintputch+0x18>
		*b->buf++ = ch;
  801e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4f:	88 0a                	mov    %cl,(%edx)
  801e51:	42                   	inc    %edx
  801e52:	89 10                	mov    %edx,(%eax)
}
  801e54:	5d                   	pop    %ebp
  801e55:	c3                   	ret    

00801e56 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801e5c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e63:	8b 45 10             	mov    0x10(%ebp),%eax
  801e66:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	89 04 24             	mov    %eax,(%esp)
  801e77:	e8 02 00 00 00       	call   801e7e <vprintfmt>
	va_end(ap);
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 4c             	sub    $0x4c,%esp
  801e87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e8a:	8b 75 10             	mov    0x10(%ebp),%esi
  801e8d:	eb 12                	jmp    801ea1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	0f 84 6b 03 00 00    	je     802202 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801e97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e9b:	89 04 24             	mov    %eax,(%esp)
  801e9e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ea1:	0f b6 06             	movzbl (%esi),%eax
  801ea4:	46                   	inc    %esi
  801ea5:	83 f8 25             	cmp    $0x25,%eax
  801ea8:	75 e5                	jne    801e8f <vprintfmt+0x11>
  801eaa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801eae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801eb5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801eba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801ec1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ec6:	eb 26                	jmp    801eee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ec8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801ecb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801ecf:	eb 1d                	jmp    801eee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ed1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801ed4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801ed8:	eb 14                	jmp    801eee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eda:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801edd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801ee4:	eb 08                	jmp    801eee <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801ee6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801ee9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eee:	0f b6 06             	movzbl (%esi),%eax
  801ef1:	8d 56 01             	lea    0x1(%esi),%edx
  801ef4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801ef7:	8a 16                	mov    (%esi),%dl
  801ef9:	83 ea 23             	sub    $0x23,%edx
  801efc:	80 fa 55             	cmp    $0x55,%dl
  801eff:	0f 87 e1 02 00 00    	ja     8021e6 <vprintfmt+0x368>
  801f05:	0f b6 d2             	movzbl %dl,%edx
  801f08:	ff 24 95 00 48 80 00 	jmp    *0x804800(,%edx,4)
  801f0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801f12:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801f17:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801f1a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801f1e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801f21:	8d 50 d0             	lea    -0x30(%eax),%edx
  801f24:	83 fa 09             	cmp    $0x9,%edx
  801f27:	77 2a                	ja     801f53 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801f29:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801f2a:	eb eb                	jmp    801f17 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801f2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2f:	8d 50 04             	lea    0x4(%eax),%edx
  801f32:	89 55 14             	mov    %edx,0x14(%ebp)
  801f35:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f37:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801f3a:	eb 17                	jmp    801f53 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801f3c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801f40:	78 98                	js     801eda <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f42:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801f45:	eb a7                	jmp    801eee <vprintfmt+0x70>
  801f47:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801f4a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801f51:	eb 9b                	jmp    801eee <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801f53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801f57:	79 95                	jns    801eee <vprintfmt+0x70>
  801f59:	eb 8b                	jmp    801ee6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801f5b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f5c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801f5f:	eb 8d                	jmp    801eee <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801f61:	8b 45 14             	mov    0x14(%ebp),%eax
  801f64:	8d 50 04             	lea    0x4(%eax),%edx
  801f67:	89 55 14             	mov    %edx,0x14(%ebp)
  801f6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f6e:	8b 00                	mov    (%eax),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f76:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801f79:	e9 23 ff ff ff       	jmp    801ea1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801f7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f81:	8d 50 04             	lea    0x4(%eax),%edx
  801f84:	89 55 14             	mov    %edx,0x14(%ebp)
  801f87:	8b 00                	mov    (%eax),%eax
  801f89:	85 c0                	test   %eax,%eax
  801f8b:	79 02                	jns    801f8f <vprintfmt+0x111>
  801f8d:	f7 d8                	neg    %eax
  801f8f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801f91:	83 f8 11             	cmp    $0x11,%eax
  801f94:	7f 0b                	jg     801fa1 <vprintfmt+0x123>
  801f96:	8b 04 85 60 49 80 00 	mov    0x804960(,%eax,4),%eax
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	75 23                	jne    801fc4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801fa1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fa5:	c7 44 24 08 c7 46 80 	movl   $0x8046c7,0x8(%esp)
  801fac:	00 
  801fad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb4:	89 04 24             	mov    %eax,(%esp)
  801fb7:	e8 9a fe ff ff       	call   801e56 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fbc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801fbf:	e9 dd fe ff ff       	jmp    801ea1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801fc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc8:	c7 44 24 08 ef 40 80 	movl   $0x8040ef,0x8(%esp)
  801fcf:	00 
  801fd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fd4:	8b 55 08             	mov    0x8(%ebp),%edx
  801fd7:	89 14 24             	mov    %edx,(%esp)
  801fda:	e8 77 fe ff ff       	call   801e56 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fdf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801fe2:	e9 ba fe ff ff       	jmp    801ea1 <vprintfmt+0x23>
  801fe7:	89 f9                	mov    %edi,%ecx
  801fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801fef:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff2:	8d 50 04             	lea    0x4(%eax),%edx
  801ff5:	89 55 14             	mov    %edx,0x14(%ebp)
  801ff8:	8b 30                	mov    (%eax),%esi
  801ffa:	85 f6                	test   %esi,%esi
  801ffc:	75 05                	jne    802003 <vprintfmt+0x185>
				p = "(null)";
  801ffe:	be c0 46 80 00       	mov    $0x8046c0,%esi
			if (width > 0 && padc != '-')
  802003:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  802007:	0f 8e 84 00 00 00    	jle    802091 <vprintfmt+0x213>
  80200d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  802011:	74 7e                	je     802091 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  802013:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802017:	89 34 24             	mov    %esi,(%esp)
  80201a:	e8 8b 02 00 00       	call   8022aa <strnlen>
  80201f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802022:	29 c2                	sub    %eax,%edx
  802024:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  802027:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80202b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80202e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  802031:	89 de                	mov    %ebx,%esi
  802033:	89 d3                	mov    %edx,%ebx
  802035:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802037:	eb 0b                	jmp    802044 <vprintfmt+0x1c6>
					putch(padc, putdat);
  802039:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203d:	89 3c 24             	mov    %edi,(%esp)
  802040:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802043:	4b                   	dec    %ebx
  802044:	85 db                	test   %ebx,%ebx
  802046:	7f f1                	jg     802039 <vprintfmt+0x1bb>
  802048:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80204b:	89 f3                	mov    %esi,%ebx
  80204d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  802050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802053:	85 c0                	test   %eax,%eax
  802055:	79 05                	jns    80205c <vprintfmt+0x1de>
  802057:	b8 00 00 00 00       	mov    $0x0,%eax
  80205c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80205f:	29 c2                	sub    %eax,%edx
  802061:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802064:	eb 2b                	jmp    802091 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802066:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80206a:	74 18                	je     802084 <vprintfmt+0x206>
  80206c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80206f:	83 fa 5e             	cmp    $0x5e,%edx
  802072:	76 10                	jbe    802084 <vprintfmt+0x206>
					putch('?', putdat);
  802074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802078:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80207f:	ff 55 08             	call   *0x8(%ebp)
  802082:	eb 0a                	jmp    80208e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  802084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802088:	89 04 24             	mov    %eax,(%esp)
  80208b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80208e:	ff 4d e4             	decl   -0x1c(%ebp)
  802091:	0f be 06             	movsbl (%esi),%eax
  802094:	46                   	inc    %esi
  802095:	85 c0                	test   %eax,%eax
  802097:	74 21                	je     8020ba <vprintfmt+0x23c>
  802099:	85 ff                	test   %edi,%edi
  80209b:	78 c9                	js     802066 <vprintfmt+0x1e8>
  80209d:	4f                   	dec    %edi
  80209e:	79 c6                	jns    802066 <vprintfmt+0x1e8>
  8020a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a3:	89 de                	mov    %ebx,%esi
  8020a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8020a8:	eb 18                	jmp    8020c2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8020aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8020b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8020b7:	4b                   	dec    %ebx
  8020b8:	eb 08                	jmp    8020c2 <vprintfmt+0x244>
  8020ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020bd:	89 de                	mov    %ebx,%esi
  8020bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8020c2:	85 db                	test   %ebx,%ebx
  8020c4:	7f e4                	jg     8020aa <vprintfmt+0x22c>
  8020c6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8020c9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8020ce:	e9 ce fd ff ff       	jmp    801ea1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8020d3:	83 f9 01             	cmp    $0x1,%ecx
  8020d6:	7e 10                	jle    8020e8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8020d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020db:	8d 50 08             	lea    0x8(%eax),%edx
  8020de:	89 55 14             	mov    %edx,0x14(%ebp)
  8020e1:	8b 30                	mov    (%eax),%esi
  8020e3:	8b 78 04             	mov    0x4(%eax),%edi
  8020e6:	eb 26                	jmp    80210e <vprintfmt+0x290>
	else if (lflag)
  8020e8:	85 c9                	test   %ecx,%ecx
  8020ea:	74 12                	je     8020fe <vprintfmt+0x280>
		return va_arg(*ap, long);
  8020ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ef:	8d 50 04             	lea    0x4(%eax),%edx
  8020f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8020f5:	8b 30                	mov    (%eax),%esi
  8020f7:	89 f7                	mov    %esi,%edi
  8020f9:	c1 ff 1f             	sar    $0x1f,%edi
  8020fc:	eb 10                	jmp    80210e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8020fe:	8b 45 14             	mov    0x14(%ebp),%eax
  802101:	8d 50 04             	lea    0x4(%eax),%edx
  802104:	89 55 14             	mov    %edx,0x14(%ebp)
  802107:	8b 30                	mov    (%eax),%esi
  802109:	89 f7                	mov    %esi,%edi
  80210b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80210e:	85 ff                	test   %edi,%edi
  802110:	78 0a                	js     80211c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  802112:	b8 0a 00 00 00       	mov    $0xa,%eax
  802117:	e9 8c 00 00 00       	jmp    8021a8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80211c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802120:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  802127:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80212a:	f7 de                	neg    %esi
  80212c:	83 d7 00             	adc    $0x0,%edi
  80212f:	f7 df                	neg    %edi
			}
			base = 10;
  802131:	b8 0a 00 00 00       	mov    $0xa,%eax
  802136:	eb 70                	jmp    8021a8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802138:	89 ca                	mov    %ecx,%edx
  80213a:	8d 45 14             	lea    0x14(%ebp),%eax
  80213d:	e8 c0 fc ff ff       	call   801e02 <getuint>
  802142:	89 c6                	mov    %eax,%esi
  802144:	89 d7                	mov    %edx,%edi
			base = 10;
  802146:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80214b:	eb 5b                	jmp    8021a8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80214d:	89 ca                	mov    %ecx,%edx
  80214f:	8d 45 14             	lea    0x14(%ebp),%eax
  802152:	e8 ab fc ff ff       	call   801e02 <getuint>
  802157:	89 c6                	mov    %eax,%esi
  802159:	89 d7                	mov    %edx,%edi
			base = 8;
  80215b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  802160:	eb 46                	jmp    8021a8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  802162:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802166:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80216d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802170:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802174:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80217b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80217e:	8b 45 14             	mov    0x14(%ebp),%eax
  802181:	8d 50 04             	lea    0x4(%eax),%edx
  802184:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802187:	8b 30                	mov    (%eax),%esi
  802189:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80218e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  802193:	eb 13                	jmp    8021a8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802195:	89 ca                	mov    %ecx,%edx
  802197:	8d 45 14             	lea    0x14(%ebp),%eax
  80219a:	e8 63 fc ff ff       	call   801e02 <getuint>
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	89 d7                	mov    %edx,%edi
			base = 16;
  8021a3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8021a8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8021ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  8021b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8021b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021bb:	89 34 24             	mov    %esi,(%esp)
  8021be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021c2:	89 da                	mov    %ebx,%edx
  8021c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c7:	e8 6c fb ff ff       	call   801d38 <printnum>
			break;
  8021cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8021cf:	e9 cd fc ff ff       	jmp    801ea1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8021d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8021de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8021e1:	e9 bb fc ff ff       	jmp    801ea1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8021e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8021f1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8021f4:	eb 01                	jmp    8021f7 <vprintfmt+0x379>
  8021f6:	4e                   	dec    %esi
  8021f7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8021fb:	75 f9                	jne    8021f6 <vprintfmt+0x378>
  8021fd:	e9 9f fc ff ff       	jmp    801ea1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  802202:	83 c4 4c             	add    $0x4c,%esp
  802205:	5b                   	pop    %ebx
  802206:	5e                   	pop    %esi
  802207:	5f                   	pop    %edi
  802208:	5d                   	pop    %ebp
  802209:	c3                   	ret    

0080220a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	83 ec 28             	sub    $0x28,%esp
  802210:	8b 45 08             	mov    0x8(%ebp),%eax
  802213:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802216:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802219:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80221d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802220:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802227:	85 c0                	test   %eax,%eax
  802229:	74 30                	je     80225b <vsnprintf+0x51>
  80222b:	85 d2                	test   %edx,%edx
  80222d:	7e 33                	jle    802262 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80222f:	8b 45 14             	mov    0x14(%ebp),%eax
  802232:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802236:	8b 45 10             	mov    0x10(%ebp),%eax
  802239:	89 44 24 08          	mov    %eax,0x8(%esp)
  80223d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802240:	89 44 24 04          	mov    %eax,0x4(%esp)
  802244:	c7 04 24 3c 1e 80 00 	movl   $0x801e3c,(%esp)
  80224b:	e8 2e fc ff ff       	call   801e7e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802250:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802253:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802259:	eb 0c                	jmp    802267 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80225b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802260:	eb 05                	jmp    802267 <vsnprintf+0x5d>
  802262:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802267:	c9                   	leave  
  802268:	c3                   	ret    

00802269 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80226f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802272:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802276:	8b 45 10             	mov    0x10(%ebp),%eax
  802279:	89 44 24 08          	mov    %eax,0x8(%esp)
  80227d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802280:	89 44 24 04          	mov    %eax,0x4(%esp)
  802284:	8b 45 08             	mov    0x8(%ebp),%eax
  802287:	89 04 24             	mov    %eax,(%esp)
  80228a:	e8 7b ff ff ff       	call   80220a <vsnprintf>
	va_end(ap);

	return rc;
}
  80228f:	c9                   	leave  
  802290:	c3                   	ret    
  802291:	00 00                	add    %al,(%eax)
	...

00802294 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80229a:	b8 00 00 00 00       	mov    $0x0,%eax
  80229f:	eb 01                	jmp    8022a2 <strlen+0xe>
		n++;
  8022a1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8022a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8022a6:	75 f9                	jne    8022a1 <strlen+0xd>
		n++;
	return n;
}
  8022a8:	5d                   	pop    %ebp
  8022a9:	c3                   	ret    

008022aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8022b0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b8:	eb 01                	jmp    8022bb <strnlen+0x11>
		n++;
  8022ba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022bb:	39 d0                	cmp    %edx,%eax
  8022bd:	74 06                	je     8022c5 <strnlen+0x1b>
  8022bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8022c3:	75 f5                	jne    8022ba <strnlen+0x10>
		n++;
	return n;
}
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    

008022c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8022c7:	55                   	push   %ebp
  8022c8:	89 e5                	mov    %esp,%ebp
  8022ca:	53                   	push   %ebx
  8022cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8022d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022d6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8022d9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8022dc:	42                   	inc    %edx
  8022dd:	84 c9                	test   %cl,%cl
  8022df:	75 f5                	jne    8022d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8022e1:	5b                   	pop    %ebx
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    

008022e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	53                   	push   %ebx
  8022e8:	83 ec 08             	sub    $0x8,%esp
  8022eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8022ee:	89 1c 24             	mov    %ebx,(%esp)
  8022f1:	e8 9e ff ff ff       	call   802294 <strlen>
	strcpy(dst + len, src);
  8022f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022fd:	01 d8                	add    %ebx,%eax
  8022ff:	89 04 24             	mov    %eax,(%esp)
  802302:	e8 c0 ff ff ff       	call   8022c7 <strcpy>
	return dst;
}
  802307:	89 d8                	mov    %ebx,%eax
  802309:	83 c4 08             	add    $0x8,%esp
  80230c:	5b                   	pop    %ebx
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	8b 45 08             	mov    0x8(%ebp),%eax
  802317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80231d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802322:	eb 0c                	jmp    802330 <strncpy+0x21>
		*dst++ = *src;
  802324:	8a 1a                	mov    (%edx),%bl
  802326:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802329:	80 3a 01             	cmpb   $0x1,(%edx)
  80232c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80232f:	41                   	inc    %ecx
  802330:	39 f1                	cmp    %esi,%ecx
  802332:	75 f0                	jne    802324 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    

00802338 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	56                   	push   %esi
  80233c:	53                   	push   %ebx
  80233d:	8b 75 08             	mov    0x8(%ebp),%esi
  802340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802343:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802346:	85 d2                	test   %edx,%edx
  802348:	75 0a                	jne    802354 <strlcpy+0x1c>
  80234a:	89 f0                	mov    %esi,%eax
  80234c:	eb 1a                	jmp    802368 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80234e:	88 18                	mov    %bl,(%eax)
  802350:	40                   	inc    %eax
  802351:	41                   	inc    %ecx
  802352:	eb 02                	jmp    802356 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802354:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  802356:	4a                   	dec    %edx
  802357:	74 0a                	je     802363 <strlcpy+0x2b>
  802359:	8a 19                	mov    (%ecx),%bl
  80235b:	84 db                	test   %bl,%bl
  80235d:	75 ef                	jne    80234e <strlcpy+0x16>
  80235f:	89 c2                	mov    %eax,%edx
  802361:	eb 02                	jmp    802365 <strlcpy+0x2d>
  802363:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  802365:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  802368:	29 f0                	sub    %esi,%eax
}
  80236a:	5b                   	pop    %ebx
  80236b:	5e                   	pop    %esi
  80236c:	5d                   	pop    %ebp
  80236d:	c3                   	ret    

0080236e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802374:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802377:	eb 02                	jmp    80237b <strcmp+0xd>
		p++, q++;
  802379:	41                   	inc    %ecx
  80237a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80237b:	8a 01                	mov    (%ecx),%al
  80237d:	84 c0                	test   %al,%al
  80237f:	74 04                	je     802385 <strcmp+0x17>
  802381:	3a 02                	cmp    (%edx),%al
  802383:	74 f4                	je     802379 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802385:	0f b6 c0             	movzbl %al,%eax
  802388:	0f b6 12             	movzbl (%edx),%edx
  80238b:	29 d0                	sub    %edx,%eax
}
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    

0080238f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	53                   	push   %ebx
  802393:	8b 45 08             	mov    0x8(%ebp),%eax
  802396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802399:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80239c:	eb 03                	jmp    8023a1 <strncmp+0x12>
		n--, p++, q++;
  80239e:	4a                   	dec    %edx
  80239f:	40                   	inc    %eax
  8023a0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8023a1:	85 d2                	test   %edx,%edx
  8023a3:	74 14                	je     8023b9 <strncmp+0x2a>
  8023a5:	8a 18                	mov    (%eax),%bl
  8023a7:	84 db                	test   %bl,%bl
  8023a9:	74 04                	je     8023af <strncmp+0x20>
  8023ab:	3a 19                	cmp    (%ecx),%bl
  8023ad:	74 ef                	je     80239e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8023af:	0f b6 00             	movzbl (%eax),%eax
  8023b2:	0f b6 11             	movzbl (%ecx),%edx
  8023b5:	29 d0                	sub    %edx,%eax
  8023b7:	eb 05                	jmp    8023be <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8023b9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8023be:	5b                   	pop    %ebx
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    

008023c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8023ca:	eb 05                	jmp    8023d1 <strchr+0x10>
		if (*s == c)
  8023cc:	38 ca                	cmp    %cl,%dl
  8023ce:	74 0c                	je     8023dc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8023d0:	40                   	inc    %eax
  8023d1:	8a 10                	mov    (%eax),%dl
  8023d3:	84 d2                	test   %dl,%dl
  8023d5:	75 f5                	jne    8023cc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8023d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023dc:	5d                   	pop    %ebp
  8023dd:	c3                   	ret    

008023de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8023de:	55                   	push   %ebp
  8023df:	89 e5                	mov    %esp,%ebp
  8023e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8023e7:	eb 05                	jmp    8023ee <strfind+0x10>
		if (*s == c)
  8023e9:	38 ca                	cmp    %cl,%dl
  8023eb:	74 07                	je     8023f4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8023ed:	40                   	inc    %eax
  8023ee:	8a 10                	mov    (%eax),%dl
  8023f0:	84 d2                	test   %dl,%dl
  8023f2:	75 f5                	jne    8023e9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    

008023f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8023f6:	55                   	push   %ebp
  8023f7:	89 e5                	mov    %esp,%ebp
  8023f9:	57                   	push   %edi
  8023fa:	56                   	push   %esi
  8023fb:	53                   	push   %ebx
  8023fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  802402:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802405:	85 c9                	test   %ecx,%ecx
  802407:	74 30                	je     802439 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802409:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80240f:	75 25                	jne    802436 <memset+0x40>
  802411:	f6 c1 03             	test   $0x3,%cl
  802414:	75 20                	jne    802436 <memset+0x40>
		c &= 0xFF;
  802416:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802419:	89 d3                	mov    %edx,%ebx
  80241b:	c1 e3 08             	shl    $0x8,%ebx
  80241e:	89 d6                	mov    %edx,%esi
  802420:	c1 e6 18             	shl    $0x18,%esi
  802423:	89 d0                	mov    %edx,%eax
  802425:	c1 e0 10             	shl    $0x10,%eax
  802428:	09 f0                	or     %esi,%eax
  80242a:	09 d0                	or     %edx,%eax
  80242c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80242e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802431:	fc                   	cld    
  802432:	f3 ab                	rep stos %eax,%es:(%edi)
  802434:	eb 03                	jmp    802439 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802436:	fc                   	cld    
  802437:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802439:	89 f8                	mov    %edi,%eax
  80243b:	5b                   	pop    %ebx
  80243c:	5e                   	pop    %esi
  80243d:	5f                   	pop    %edi
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	57                   	push   %edi
  802444:	56                   	push   %esi
  802445:	8b 45 08             	mov    0x8(%ebp),%eax
  802448:	8b 75 0c             	mov    0xc(%ebp),%esi
  80244b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80244e:	39 c6                	cmp    %eax,%esi
  802450:	73 34                	jae    802486 <memmove+0x46>
  802452:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802455:	39 d0                	cmp    %edx,%eax
  802457:	73 2d                	jae    802486 <memmove+0x46>
		s += n;
		d += n;
  802459:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80245c:	f6 c2 03             	test   $0x3,%dl
  80245f:	75 1b                	jne    80247c <memmove+0x3c>
  802461:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802467:	75 13                	jne    80247c <memmove+0x3c>
  802469:	f6 c1 03             	test   $0x3,%cl
  80246c:	75 0e                	jne    80247c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80246e:	83 ef 04             	sub    $0x4,%edi
  802471:	8d 72 fc             	lea    -0x4(%edx),%esi
  802474:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  802477:	fd                   	std    
  802478:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80247a:	eb 07                	jmp    802483 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80247c:	4f                   	dec    %edi
  80247d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802480:	fd                   	std    
  802481:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802483:	fc                   	cld    
  802484:	eb 20                	jmp    8024a6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802486:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80248c:	75 13                	jne    8024a1 <memmove+0x61>
  80248e:	a8 03                	test   $0x3,%al
  802490:	75 0f                	jne    8024a1 <memmove+0x61>
  802492:	f6 c1 03             	test   $0x3,%cl
  802495:	75 0a                	jne    8024a1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802497:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80249a:	89 c7                	mov    %eax,%edi
  80249c:	fc                   	cld    
  80249d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80249f:	eb 05                	jmp    8024a6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8024a1:	89 c7                	mov    %eax,%edi
  8024a3:	fc                   	cld    
  8024a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8024a6:	5e                   	pop    %esi
  8024a7:	5f                   	pop    %edi
  8024a8:	5d                   	pop    %ebp
  8024a9:	c3                   	ret    

008024aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8024aa:	55                   	push   %ebp
  8024ab:	89 e5                	mov    %esp,%ebp
  8024ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8024b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8024b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024be:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 77 ff ff ff       	call   802440 <memmove>
}
  8024c9:	c9                   	leave  
  8024ca:	c3                   	ret    

008024cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8024cb:	55                   	push   %ebp
  8024cc:	89 e5                	mov    %esp,%ebp
  8024ce:	57                   	push   %edi
  8024cf:	56                   	push   %esi
  8024d0:	53                   	push   %ebx
  8024d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8024da:	ba 00 00 00 00       	mov    $0x0,%edx
  8024df:	eb 16                	jmp    8024f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8024e1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8024e4:	42                   	inc    %edx
  8024e5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8024e9:	38 c8                	cmp    %cl,%al
  8024eb:	74 0a                	je     8024f7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8024ed:	0f b6 c0             	movzbl %al,%eax
  8024f0:	0f b6 c9             	movzbl %cl,%ecx
  8024f3:	29 c8                	sub    %ecx,%eax
  8024f5:	eb 09                	jmp    802500 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8024f7:	39 da                	cmp    %ebx,%edx
  8024f9:	75 e6                	jne    8024e1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8024fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    

00802505 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802505:	55                   	push   %ebp
  802506:	89 e5                	mov    %esp,%ebp
  802508:	8b 45 08             	mov    0x8(%ebp),%eax
  80250b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80250e:	89 c2                	mov    %eax,%edx
  802510:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802513:	eb 05                	jmp    80251a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  802515:	38 08                	cmp    %cl,(%eax)
  802517:	74 05                	je     80251e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802519:	40                   	inc    %eax
  80251a:	39 d0                	cmp    %edx,%eax
  80251c:	72 f7                	jb     802515 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    

00802520 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802520:	55                   	push   %ebp
  802521:	89 e5                	mov    %esp,%ebp
  802523:	57                   	push   %edi
  802524:	56                   	push   %esi
  802525:	53                   	push   %ebx
  802526:	8b 55 08             	mov    0x8(%ebp),%edx
  802529:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80252c:	eb 01                	jmp    80252f <strtol+0xf>
		s++;
  80252e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80252f:	8a 02                	mov    (%edx),%al
  802531:	3c 20                	cmp    $0x20,%al
  802533:	74 f9                	je     80252e <strtol+0xe>
  802535:	3c 09                	cmp    $0x9,%al
  802537:	74 f5                	je     80252e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802539:	3c 2b                	cmp    $0x2b,%al
  80253b:	75 08                	jne    802545 <strtol+0x25>
		s++;
  80253d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80253e:	bf 00 00 00 00       	mov    $0x0,%edi
  802543:	eb 13                	jmp    802558 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802545:	3c 2d                	cmp    $0x2d,%al
  802547:	75 0a                	jne    802553 <strtol+0x33>
		s++, neg = 1;
  802549:	8d 52 01             	lea    0x1(%edx),%edx
  80254c:	bf 01 00 00 00       	mov    $0x1,%edi
  802551:	eb 05                	jmp    802558 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802553:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802558:	85 db                	test   %ebx,%ebx
  80255a:	74 05                	je     802561 <strtol+0x41>
  80255c:	83 fb 10             	cmp    $0x10,%ebx
  80255f:	75 28                	jne    802589 <strtol+0x69>
  802561:	8a 02                	mov    (%edx),%al
  802563:	3c 30                	cmp    $0x30,%al
  802565:	75 10                	jne    802577 <strtol+0x57>
  802567:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80256b:	75 0a                	jne    802577 <strtol+0x57>
		s += 2, base = 16;
  80256d:	83 c2 02             	add    $0x2,%edx
  802570:	bb 10 00 00 00       	mov    $0x10,%ebx
  802575:	eb 12                	jmp    802589 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802577:	85 db                	test   %ebx,%ebx
  802579:	75 0e                	jne    802589 <strtol+0x69>
  80257b:	3c 30                	cmp    $0x30,%al
  80257d:	75 05                	jne    802584 <strtol+0x64>
		s++, base = 8;
  80257f:	42                   	inc    %edx
  802580:	b3 08                	mov    $0x8,%bl
  802582:	eb 05                	jmp    802589 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802584:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802589:	b8 00 00 00 00       	mov    $0x0,%eax
  80258e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802590:	8a 0a                	mov    (%edx),%cl
  802592:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802595:	80 fb 09             	cmp    $0x9,%bl
  802598:	77 08                	ja     8025a2 <strtol+0x82>
			dig = *s - '0';
  80259a:	0f be c9             	movsbl %cl,%ecx
  80259d:	83 e9 30             	sub    $0x30,%ecx
  8025a0:	eb 1e                	jmp    8025c0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8025a2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8025a5:	80 fb 19             	cmp    $0x19,%bl
  8025a8:	77 08                	ja     8025b2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8025aa:	0f be c9             	movsbl %cl,%ecx
  8025ad:	83 e9 57             	sub    $0x57,%ecx
  8025b0:	eb 0e                	jmp    8025c0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8025b2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8025b5:	80 fb 19             	cmp    $0x19,%bl
  8025b8:	77 12                	ja     8025cc <strtol+0xac>
			dig = *s - 'A' + 10;
  8025ba:	0f be c9             	movsbl %cl,%ecx
  8025bd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8025c0:	39 f1                	cmp    %esi,%ecx
  8025c2:	7d 0c                	jge    8025d0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8025c4:	42                   	inc    %edx
  8025c5:	0f af c6             	imul   %esi,%eax
  8025c8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8025ca:	eb c4                	jmp    802590 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8025cc:	89 c1                	mov    %eax,%ecx
  8025ce:	eb 02                	jmp    8025d2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8025d0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8025d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8025d6:	74 05                	je     8025dd <strtol+0xbd>
		*endptr = (char *) s;
  8025d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8025db:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8025dd:	85 ff                	test   %edi,%edi
  8025df:	74 04                	je     8025e5 <strtol+0xc5>
  8025e1:	89 c8                	mov    %ecx,%eax
  8025e3:	f7 d8                	neg    %eax
}
  8025e5:	5b                   	pop    %ebx
  8025e6:	5e                   	pop    %esi
  8025e7:	5f                   	pop    %edi
  8025e8:	5d                   	pop    %ebp
  8025e9:	c3                   	ret    
	...

008025ec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8025ec:	55                   	push   %ebp
  8025ed:	89 e5                	mov    %esp,%ebp
  8025ef:	57                   	push   %edi
  8025f0:	56                   	push   %esi
  8025f1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8025f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8025fd:	89 c3                	mov    %eax,%ebx
  8025ff:	89 c7                	mov    %eax,%edi
  802601:	89 c6                	mov    %eax,%esi
  802603:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802605:	5b                   	pop    %ebx
  802606:	5e                   	pop    %esi
  802607:	5f                   	pop    %edi
  802608:	5d                   	pop    %ebp
  802609:	c3                   	ret    

0080260a <sys_cgetc>:

int
sys_cgetc(void)
{
  80260a:	55                   	push   %ebp
  80260b:	89 e5                	mov    %esp,%ebp
  80260d:	57                   	push   %edi
  80260e:	56                   	push   %esi
  80260f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802610:	ba 00 00 00 00       	mov    $0x0,%edx
  802615:	b8 01 00 00 00       	mov    $0x1,%eax
  80261a:	89 d1                	mov    %edx,%ecx
  80261c:	89 d3                	mov    %edx,%ebx
  80261e:	89 d7                	mov    %edx,%edi
  802620:	89 d6                	mov    %edx,%esi
  802622:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802624:	5b                   	pop    %ebx
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    

00802629 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802629:	55                   	push   %ebp
  80262a:	89 e5                	mov    %esp,%ebp
  80262c:	57                   	push   %edi
  80262d:	56                   	push   %esi
  80262e:	53                   	push   %ebx
  80262f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802632:	b9 00 00 00 00       	mov    $0x0,%ecx
  802637:	b8 03 00 00 00       	mov    $0x3,%eax
  80263c:	8b 55 08             	mov    0x8(%ebp),%edx
  80263f:	89 cb                	mov    %ecx,%ebx
  802641:	89 cf                	mov    %ecx,%edi
  802643:	89 ce                	mov    %ecx,%esi
  802645:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802647:	85 c0                	test   %eax,%eax
  802649:	7e 28                	jle    802673 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80264b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80264f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802656:	00 
  802657:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  80265e:	00 
  80265f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802666:	00 
  802667:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  80266e:	e8 b1 f5 ff ff       	call   801c24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802673:	83 c4 2c             	add    $0x2c,%esp
  802676:	5b                   	pop    %ebx
  802677:	5e                   	pop    %esi
  802678:	5f                   	pop    %edi
  802679:	5d                   	pop    %ebp
  80267a:	c3                   	ret    

0080267b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80267b:	55                   	push   %ebp
  80267c:	89 e5                	mov    %esp,%ebp
  80267e:	57                   	push   %edi
  80267f:	56                   	push   %esi
  802680:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802681:	ba 00 00 00 00       	mov    $0x0,%edx
  802686:	b8 02 00 00 00       	mov    $0x2,%eax
  80268b:	89 d1                	mov    %edx,%ecx
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 d7                	mov    %edx,%edi
  802691:	89 d6                	mov    %edx,%esi
  802693:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802695:	5b                   	pop    %ebx
  802696:	5e                   	pop    %esi
  802697:	5f                   	pop    %edi
  802698:	5d                   	pop    %ebp
  802699:	c3                   	ret    

0080269a <sys_yield>:

void
sys_yield(void)
{
  80269a:	55                   	push   %ebp
  80269b:	89 e5                	mov    %esp,%ebp
  80269d:	57                   	push   %edi
  80269e:	56                   	push   %esi
  80269f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8026a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8026aa:	89 d1                	mov    %edx,%ecx
  8026ac:	89 d3                	mov    %edx,%ebx
  8026ae:	89 d7                	mov    %edx,%edi
  8026b0:	89 d6                	mov    %edx,%esi
  8026b2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8026b4:	5b                   	pop    %ebx
  8026b5:	5e                   	pop    %esi
  8026b6:	5f                   	pop    %edi
  8026b7:	5d                   	pop    %ebp
  8026b8:	c3                   	ret    

008026b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8026b9:	55                   	push   %ebp
  8026ba:	89 e5                	mov    %esp,%ebp
  8026bc:	57                   	push   %edi
  8026bd:	56                   	push   %esi
  8026be:	53                   	push   %ebx
  8026bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026c2:	be 00 00 00 00       	mov    $0x0,%esi
  8026c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8026cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8026d5:	89 f7                	mov    %esi,%edi
  8026d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8026d9:	85 c0                	test   %eax,%eax
  8026db:	7e 28                	jle    802705 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026e1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8026e8:	00 
  8026e9:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  8026f0:	00 
  8026f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8026f8:	00 
  8026f9:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  802700:	e8 1f f5 ff ff       	call   801c24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802705:	83 c4 2c             	add    $0x2c,%esp
  802708:	5b                   	pop    %ebx
  802709:	5e                   	pop    %esi
  80270a:	5f                   	pop    %edi
  80270b:	5d                   	pop    %ebp
  80270c:	c3                   	ret    

0080270d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80270d:	55                   	push   %ebp
  80270e:	89 e5                	mov    %esp,%ebp
  802710:	57                   	push   %edi
  802711:	56                   	push   %esi
  802712:	53                   	push   %ebx
  802713:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802716:	b8 05 00 00 00       	mov    $0x5,%eax
  80271b:	8b 75 18             	mov    0x18(%ebp),%esi
  80271e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802721:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802727:	8b 55 08             	mov    0x8(%ebp),%edx
  80272a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80272c:	85 c0                	test   %eax,%eax
  80272e:	7e 28                	jle    802758 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802730:	89 44 24 10          	mov    %eax,0x10(%esp)
  802734:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80273b:	00 
  80273c:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  802743:	00 
  802744:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80274b:	00 
  80274c:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  802753:	e8 cc f4 ff ff       	call   801c24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802758:	83 c4 2c             	add    $0x2c,%esp
  80275b:	5b                   	pop    %ebx
  80275c:	5e                   	pop    %esi
  80275d:	5f                   	pop    %edi
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    

00802760 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	57                   	push   %edi
  802764:	56                   	push   %esi
  802765:	53                   	push   %ebx
  802766:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80276e:	b8 06 00 00 00       	mov    $0x6,%eax
  802773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802776:	8b 55 08             	mov    0x8(%ebp),%edx
  802779:	89 df                	mov    %ebx,%edi
  80277b:	89 de                	mov    %ebx,%esi
  80277d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80277f:	85 c0                	test   %eax,%eax
  802781:	7e 28                	jle    8027ab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802783:	89 44 24 10          	mov    %eax,0x10(%esp)
  802787:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80278e:	00 
  80278f:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  802796:	00 
  802797:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80279e:	00 
  80279f:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  8027a6:	e8 79 f4 ff ff       	call   801c24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8027ab:	83 c4 2c             	add    $0x2c,%esp
  8027ae:	5b                   	pop    %ebx
  8027af:	5e                   	pop    %esi
  8027b0:	5f                   	pop    %edi
  8027b1:	5d                   	pop    %ebp
  8027b2:	c3                   	ret    

008027b3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8027b3:	55                   	push   %ebp
  8027b4:	89 e5                	mov    %esp,%ebp
  8027b6:	57                   	push   %edi
  8027b7:	56                   	push   %esi
  8027b8:	53                   	push   %ebx
  8027b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8027c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8027cc:	89 df                	mov    %ebx,%edi
  8027ce:	89 de                	mov    %ebx,%esi
  8027d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8027d2:	85 c0                	test   %eax,%eax
  8027d4:	7e 28                	jle    8027fe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027da:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8027e1:	00 
  8027e2:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  8027e9:	00 
  8027ea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8027f1:	00 
  8027f2:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  8027f9:	e8 26 f4 ff ff       	call   801c24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8027fe:	83 c4 2c             	add    $0x2c,%esp
  802801:	5b                   	pop    %ebx
  802802:	5e                   	pop    %esi
  802803:	5f                   	pop    %edi
  802804:	5d                   	pop    %ebp
  802805:	c3                   	ret    

00802806 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802806:	55                   	push   %ebp
  802807:	89 e5                	mov    %esp,%ebp
  802809:	57                   	push   %edi
  80280a:	56                   	push   %esi
  80280b:	53                   	push   %ebx
  80280c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80280f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802814:	b8 09 00 00 00       	mov    $0x9,%eax
  802819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80281c:	8b 55 08             	mov    0x8(%ebp),%edx
  80281f:	89 df                	mov    %ebx,%edi
  802821:	89 de                	mov    %ebx,%esi
  802823:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802825:	85 c0                	test   %eax,%eax
  802827:	7e 28                	jle    802851 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802829:	89 44 24 10          	mov    %eax,0x10(%esp)
  80282d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802834:	00 
  802835:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  80283c:	00 
  80283d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802844:	00 
  802845:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  80284c:	e8 d3 f3 ff ff       	call   801c24 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802851:	83 c4 2c             	add    $0x2c,%esp
  802854:	5b                   	pop    %ebx
  802855:	5e                   	pop    %esi
  802856:	5f                   	pop    %edi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    

00802859 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802859:	55                   	push   %ebp
  80285a:	89 e5                	mov    %esp,%ebp
  80285c:	57                   	push   %edi
  80285d:	56                   	push   %esi
  80285e:	53                   	push   %ebx
  80285f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802862:	bb 00 00 00 00       	mov    $0x0,%ebx
  802867:	b8 0a 00 00 00       	mov    $0xa,%eax
  80286c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80286f:	8b 55 08             	mov    0x8(%ebp),%edx
  802872:	89 df                	mov    %ebx,%edi
  802874:	89 de                	mov    %ebx,%esi
  802876:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802878:	85 c0                	test   %eax,%eax
  80287a:	7e 28                	jle    8028a4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80287c:	89 44 24 10          	mov    %eax,0x10(%esp)
  802880:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802887:	00 
  802888:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  80288f:	00 
  802890:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802897:	00 
  802898:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  80289f:	e8 80 f3 ff ff       	call   801c24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8028a4:	83 c4 2c             	add    $0x2c,%esp
  8028a7:	5b                   	pop    %ebx
  8028a8:	5e                   	pop    %esi
  8028a9:	5f                   	pop    %edi
  8028aa:	5d                   	pop    %ebp
  8028ab:	c3                   	ret    

008028ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8028ac:	55                   	push   %ebp
  8028ad:	89 e5                	mov    %esp,%ebp
  8028af:	57                   	push   %edi
  8028b0:	56                   	push   %esi
  8028b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028b2:	be 00 00 00 00       	mov    $0x0,%esi
  8028b7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8028bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8028c8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8028ca:	5b                   	pop    %ebx
  8028cb:	5e                   	pop    %esi
  8028cc:	5f                   	pop    %edi
  8028cd:	5d                   	pop    %ebp
  8028ce:	c3                   	ret    

008028cf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8028cf:	55                   	push   %ebp
  8028d0:	89 e5                	mov    %esp,%ebp
  8028d2:	57                   	push   %edi
  8028d3:	56                   	push   %esi
  8028d4:	53                   	push   %ebx
  8028d5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8028dd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8028e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8028e5:	89 cb                	mov    %ecx,%ebx
  8028e7:	89 cf                	mov    %ecx,%edi
  8028e9:	89 ce                	mov    %ecx,%esi
  8028eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8028ed:	85 c0                	test   %eax,%eax
  8028ef:	7e 28                	jle    802919 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028f5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8028fc:	00 
  8028fd:	c7 44 24 08 c7 49 80 	movl   $0x8049c7,0x8(%esp)
  802904:	00 
  802905:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80290c:	00 
  80290d:	c7 04 24 e4 49 80 00 	movl   $0x8049e4,(%esp)
  802914:	e8 0b f3 ff ff       	call   801c24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802919:	83 c4 2c             	add    $0x2c,%esp
  80291c:	5b                   	pop    %ebx
  80291d:	5e                   	pop    %esi
  80291e:	5f                   	pop    %edi
  80291f:	5d                   	pop    %ebp
  802920:	c3                   	ret    

00802921 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  802921:	55                   	push   %ebp
  802922:	89 e5                	mov    %esp,%ebp
  802924:	57                   	push   %edi
  802925:	56                   	push   %esi
  802926:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802927:	ba 00 00 00 00       	mov    $0x0,%edx
  80292c:	b8 0e 00 00 00       	mov    $0xe,%eax
  802931:	89 d1                	mov    %edx,%ecx
  802933:	89 d3                	mov    %edx,%ebx
  802935:	89 d7                	mov    %edx,%edi
  802937:	89 d6                	mov    %edx,%esi
  802939:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80293b:	5b                   	pop    %ebx
  80293c:	5e                   	pop    %esi
  80293d:	5f                   	pop    %edi
  80293e:	5d                   	pop    %ebp
  80293f:	c3                   	ret    

00802940 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  802940:	55                   	push   %ebp
  802941:	89 e5                	mov    %esp,%ebp
  802943:	57                   	push   %edi
  802944:	56                   	push   %esi
  802945:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802946:	bb 00 00 00 00       	mov    $0x0,%ebx
  80294b:	b8 10 00 00 00       	mov    $0x10,%eax
  802950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802953:	8b 55 08             	mov    0x8(%ebp),%edx
  802956:	89 df                	mov    %ebx,%edi
  802958:	89 de                	mov    %ebx,%esi
  80295a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  80295c:	5b                   	pop    %ebx
  80295d:	5e                   	pop    %esi
  80295e:	5f                   	pop    %edi
  80295f:	5d                   	pop    %ebp
  802960:	c3                   	ret    

00802961 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  802961:	55                   	push   %ebp
  802962:	89 e5                	mov    %esp,%ebp
  802964:	57                   	push   %edi
  802965:	56                   	push   %esi
  802966:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802967:	bb 00 00 00 00       	mov    $0x0,%ebx
  80296c:	b8 0f 00 00 00       	mov    $0xf,%eax
  802971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802974:	8b 55 08             	mov    0x8(%ebp),%edx
  802977:	89 df                	mov    %ebx,%edi
  802979:	89 de                	mov    %ebx,%esi
  80297b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  80297d:	5b                   	pop    %ebx
  80297e:	5e                   	pop    %esi
  80297f:	5f                   	pop    %edi
  802980:	5d                   	pop    %ebp
  802981:	c3                   	ret    

00802982 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  802982:	55                   	push   %ebp
  802983:	89 e5                	mov    %esp,%ebp
  802985:	57                   	push   %edi
  802986:	56                   	push   %esi
  802987:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802988:	b9 00 00 00 00       	mov    $0x0,%ecx
  80298d:	b8 11 00 00 00       	mov    $0x11,%eax
  802992:	8b 55 08             	mov    0x8(%ebp),%edx
  802995:	89 cb                	mov    %ecx,%ebx
  802997:	89 cf                	mov    %ecx,%edi
  802999:	89 ce                	mov    %ecx,%esi
  80299b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  80299d:	5b                   	pop    %ebx
  80299e:	5e                   	pop    %esi
  80299f:	5f                   	pop    %edi
  8029a0:	5d                   	pop    %ebp
  8029a1:	c3                   	ret    
	...

008029a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029a4:	55                   	push   %ebp
  8029a5:	89 e5                	mov    %esp,%ebp
  8029a7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8029aa:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  8029b1:	75 58                	jne    802a0b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8029b3:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8029b8:	8b 40 48             	mov    0x48(%eax),%eax
  8029bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8029c2:	00 
  8029c3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8029ca:	ee 
  8029cb:	89 04 24             	mov    %eax,(%esp)
  8029ce:	e8 e6 fc ff ff       	call   8026b9 <sys_page_alloc>
  8029d3:	85 c0                	test   %eax,%eax
  8029d5:	74 1c                	je     8029f3 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8029d7:	c7 44 24 08 f2 49 80 	movl   $0x8049f2,0x8(%esp)
  8029de:	00 
  8029df:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029e6:	00 
  8029e7:	c7 04 24 07 4a 80 00 	movl   $0x804a07,(%esp)
  8029ee:	e8 31 f2 ff ff       	call   801c24 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8029f3:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8029f8:	8b 40 48             	mov    0x48(%eax),%eax
  8029fb:	c7 44 24 04 18 2a 80 	movl   $0x802a18,0x4(%esp)
  802a02:	00 
  802a03:	89 04 24             	mov    %eax,(%esp)
  802a06:	e8 4e fe ff ff       	call   802859 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  802a0e:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  802a13:	c9                   	leave  
  802a14:	c3                   	ret    
  802a15:	00 00                	add    %al,(%eax)
	...

00802a18 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a18:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a19:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802a1e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a20:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  802a23:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802a27:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802a29:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802a2d:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802a2e:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802a31:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  802a33:	58                   	pop    %eax
	popl %eax
  802a34:	58                   	pop    %eax

	// Pop all registers back
	popal
  802a35:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802a36:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802a39:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802a3a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802a3b:	c3                   	ret    

00802a3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a3c:	55                   	push   %ebp
  802a3d:	89 e5                	mov    %esp,%ebp
  802a3f:	56                   	push   %esi
  802a40:	53                   	push   %ebx
  802a41:	83 ec 10             	sub    $0x10,%esp
  802a44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a4a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802a4d:	85 c0                	test   %eax,%eax
  802a4f:	75 05                	jne    802a56 <ipc_recv+0x1a>
  802a51:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a56:	89 04 24             	mov    %eax,(%esp)
  802a59:	e8 71 fe ff ff       	call   8028cf <sys_ipc_recv>
	if (from_env_store != NULL)
  802a5e:	85 db                	test   %ebx,%ebx
  802a60:	74 0b                	je     802a6d <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802a62:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  802a68:	8b 52 74             	mov    0x74(%edx),%edx
  802a6b:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802a6d:	85 f6                	test   %esi,%esi
  802a6f:	74 0b                	je     802a7c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802a71:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  802a77:	8b 52 78             	mov    0x78(%edx),%edx
  802a7a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802a7c:	85 c0                	test   %eax,%eax
  802a7e:	79 16                	jns    802a96 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802a80:	85 db                	test   %ebx,%ebx
  802a82:	74 06                	je     802a8a <ipc_recv+0x4e>
			*from_env_store = 0;
  802a84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802a8a:	85 f6                	test   %esi,%esi
  802a8c:	74 10                	je     802a9e <ipc_recv+0x62>
			*perm_store = 0;
  802a8e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802a94:	eb 08                	jmp    802a9e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802a96:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802a9b:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a9e:	83 c4 10             	add    $0x10,%esp
  802aa1:	5b                   	pop    %ebx
  802aa2:	5e                   	pop    %esi
  802aa3:	5d                   	pop    %ebp
  802aa4:	c3                   	ret    

00802aa5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802aa5:	55                   	push   %ebp
  802aa6:	89 e5                	mov    %esp,%ebp
  802aa8:	57                   	push   %edi
  802aa9:	56                   	push   %esi
  802aaa:	53                   	push   %ebx
  802aab:	83 ec 1c             	sub    $0x1c,%esp
  802aae:	8b 75 08             	mov    0x8(%ebp),%esi
  802ab1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802ab4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802ab7:	eb 2a                	jmp    802ae3 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802ab9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802abc:	74 20                	je     802ade <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802abe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ac2:	c7 44 24 08 18 4a 80 	movl   $0x804a18,0x8(%esp)
  802ac9:	00 
  802aca:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802ad1:	00 
  802ad2:	c7 04 24 3d 4a 80 00 	movl   $0x804a3d,(%esp)
  802ad9:	e8 46 f1 ff ff       	call   801c24 <_panic>
		sys_yield();
  802ade:	e8 b7 fb ff ff       	call   80269a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802ae3:	85 db                	test   %ebx,%ebx
  802ae5:	75 07                	jne    802aee <ipc_send+0x49>
  802ae7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802aec:	eb 02                	jmp    802af0 <ipc_send+0x4b>
  802aee:	89 d8                	mov    %ebx,%eax
  802af0:	8b 55 14             	mov    0x14(%ebp),%edx
  802af3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  802afb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802aff:	89 34 24             	mov    %esi,(%esp)
  802b02:	e8 a5 fd ff ff       	call   8028ac <sys_ipc_try_send>
  802b07:	85 c0                	test   %eax,%eax
  802b09:	78 ae                	js     802ab9 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802b0b:	83 c4 1c             	add    $0x1c,%esp
  802b0e:	5b                   	pop    %ebx
  802b0f:	5e                   	pop    %esi
  802b10:	5f                   	pop    %edi
  802b11:	5d                   	pop    %ebp
  802b12:	c3                   	ret    

00802b13 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b13:	55                   	push   %ebp
  802b14:	89 e5                	mov    %esp,%ebp
  802b16:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802b19:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b1e:	89 c2                	mov    %eax,%edx
  802b20:	c1 e2 07             	shl    $0x7,%edx
  802b23:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b29:	8b 52 50             	mov    0x50(%edx),%edx
  802b2c:	39 ca                	cmp    %ecx,%edx
  802b2e:	75 0d                	jne    802b3d <ipc_find_env+0x2a>
			return envs[i].env_id;
  802b30:	c1 e0 07             	shl    $0x7,%eax
  802b33:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802b38:	8b 40 40             	mov    0x40(%eax),%eax
  802b3b:	eb 0c                	jmp    802b49 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b3d:	40                   	inc    %eax
  802b3e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b43:	75 d9                	jne    802b1e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802b45:	66 b8 00 00          	mov    $0x0,%ax
}
  802b49:	5d                   	pop    %ebp
  802b4a:	c3                   	ret    
	...

00802b4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802b4c:	55                   	push   %ebp
  802b4d:	89 e5                	mov    %esp,%ebp
  802b4f:	56                   	push   %esi
  802b50:	53                   	push   %ebx
  802b51:	83 ec 10             	sub    $0x10,%esp
  802b54:	89 c3                	mov    %eax,%ebx
  802b56:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802b58:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802b5f:	75 11                	jne    802b72 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802b61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802b68:	e8 a6 ff ff ff       	call   802b13 <ipc_find_env>
  802b6d:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802b72:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802b79:	00 
  802b7a:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  802b81:	00 
  802b82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b86:	a1 00 a0 80 00       	mov    0x80a000,%eax
  802b8b:	89 04 24             	mov    %eax,(%esp)
  802b8e:	e8 12 ff ff ff       	call   802aa5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802b93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b9a:	00 
  802b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ba6:	e8 91 fe ff ff       	call   802a3c <ipc_recv>
}
  802bab:	83 c4 10             	add    $0x10,%esp
  802bae:	5b                   	pop    %ebx
  802baf:	5e                   	pop    %esi
  802bb0:	5d                   	pop    %ebp
  802bb1:	c3                   	ret    

00802bb2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802bb2:	55                   	push   %ebp
  802bb3:	89 e5                	mov    %esp,%ebp
  802bb5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  802bbb:	8b 40 0c             	mov    0xc(%eax),%eax
  802bbe:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bc6:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  802bd0:	b8 02 00 00 00       	mov    $0x2,%eax
  802bd5:	e8 72 ff ff ff       	call   802b4c <fsipc>
}
  802bda:	c9                   	leave  
  802bdb:	c3                   	ret    

00802bdc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802bdc:	55                   	push   %ebp
  802bdd:	89 e5                	mov    %esp,%ebp
  802bdf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802be2:	8b 45 08             	mov    0x8(%ebp),%eax
  802be5:	8b 40 0c             	mov    0xc(%eax),%eax
  802be8:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802bed:	ba 00 00 00 00       	mov    $0x0,%edx
  802bf2:	b8 06 00 00 00       	mov    $0x6,%eax
  802bf7:	e8 50 ff ff ff       	call   802b4c <fsipc>
}
  802bfc:	c9                   	leave  
  802bfd:	c3                   	ret    

00802bfe <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802bfe:	55                   	push   %ebp
  802bff:	89 e5                	mov    %esp,%ebp
  802c01:	53                   	push   %ebx
  802c02:	83 ec 14             	sub    $0x14,%esp
  802c05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802c08:	8b 45 08             	mov    0x8(%ebp),%eax
  802c0b:	8b 40 0c             	mov    0xc(%eax),%eax
  802c0e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802c13:	ba 00 00 00 00       	mov    $0x0,%edx
  802c18:	b8 05 00 00 00       	mov    $0x5,%eax
  802c1d:	e8 2a ff ff ff       	call   802b4c <fsipc>
  802c22:	85 c0                	test   %eax,%eax
  802c24:	78 2b                	js     802c51 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802c26:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  802c2d:	00 
  802c2e:	89 1c 24             	mov    %ebx,(%esp)
  802c31:	e8 91 f6 ff ff       	call   8022c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802c36:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802c3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802c41:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802c46:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802c4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c51:	83 c4 14             	add    $0x14,%esp
  802c54:	5b                   	pop    %ebx
  802c55:	5d                   	pop    %ebp
  802c56:	c3                   	ret    

00802c57 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802c57:	55                   	push   %ebp
  802c58:	89 e5                	mov    %esp,%ebp
  802c5a:	83 ec 18             	sub    $0x18,%esp
  802c5d:	8b 55 10             	mov    0x10(%ebp),%edx
  802c60:	89 d0                	mov    %edx,%eax
  802c62:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802c68:	76 05                	jbe    802c6f <devfile_write+0x18>
  802c6a:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  802c72:	8b 52 0c             	mov    0xc(%edx),%edx
  802c75:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802c7b:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802c80:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c84:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c87:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c8b:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  802c92:	e8 a9 f7 ff ff       	call   802440 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  802c97:	ba 00 00 00 00       	mov    $0x0,%edx
  802c9c:	b8 04 00 00 00       	mov    $0x4,%eax
  802ca1:	e8 a6 fe ff ff       	call   802b4c <fsipc>
}
  802ca6:	c9                   	leave  
  802ca7:	c3                   	ret    

00802ca8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802ca8:	55                   	push   %ebp
  802ca9:	89 e5                	mov    %esp,%ebp
  802cab:	56                   	push   %esi
  802cac:	53                   	push   %ebx
  802cad:	83 ec 10             	sub    $0x10,%esp
  802cb0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  802cb6:	8b 40 0c             	mov    0xc(%eax),%eax
  802cb9:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802cbe:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  802cc9:	b8 03 00 00 00       	mov    $0x3,%eax
  802cce:	e8 79 fe ff ff       	call   802b4c <fsipc>
  802cd3:	89 c3                	mov    %eax,%ebx
  802cd5:	85 c0                	test   %eax,%eax
  802cd7:	78 6a                	js     802d43 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802cd9:	39 c6                	cmp    %eax,%esi
  802cdb:	73 24                	jae    802d01 <devfile_read+0x59>
  802cdd:	c7 44 24 0c 47 4a 80 	movl   $0x804a47,0xc(%esp)
  802ce4:	00 
  802ce5:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  802cec:	00 
  802ced:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802cf4:	00 
  802cf5:	c7 04 24 4e 4a 80 00 	movl   $0x804a4e,(%esp)
  802cfc:	e8 23 ef ff ff       	call   801c24 <_panic>
	assert(r <= PGSIZE);
  802d01:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802d06:	7e 24                	jle    802d2c <devfile_read+0x84>
  802d08:	c7 44 24 0c 59 4a 80 	movl   $0x804a59,0xc(%esp)
  802d0f:	00 
  802d10:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  802d17:	00 
  802d18:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802d1f:	00 
  802d20:	c7 04 24 4e 4a 80 00 	movl   $0x804a4e,(%esp)
  802d27:	e8 f8 ee ff ff       	call   801c24 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802d2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d30:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  802d37:	00 
  802d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d3b:	89 04 24             	mov    %eax,(%esp)
  802d3e:	e8 fd f6 ff ff       	call   802440 <memmove>
	return r;
}
  802d43:	89 d8                	mov    %ebx,%eax
  802d45:	83 c4 10             	add    $0x10,%esp
  802d48:	5b                   	pop    %ebx
  802d49:	5e                   	pop    %esi
  802d4a:	5d                   	pop    %ebp
  802d4b:	c3                   	ret    

00802d4c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802d4c:	55                   	push   %ebp
  802d4d:	89 e5                	mov    %esp,%ebp
  802d4f:	56                   	push   %esi
  802d50:	53                   	push   %ebx
  802d51:	83 ec 20             	sub    $0x20,%esp
  802d54:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802d57:	89 34 24             	mov    %esi,(%esp)
  802d5a:	e8 35 f5 ff ff       	call   802294 <strlen>
  802d5f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802d64:	7f 60                	jg     802dc6 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802d66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d69:	89 04 24             	mov    %eax,(%esp)
  802d6c:	e8 ea 00 00 00       	call   802e5b <fd_alloc>
  802d71:	89 c3                	mov    %eax,%ebx
  802d73:	85 c0                	test   %eax,%eax
  802d75:	78 54                	js     802dcb <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802d77:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d7b:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  802d82:	e8 40 f5 ff ff       	call   8022c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802d87:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d8a:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802d8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d92:	b8 01 00 00 00       	mov    $0x1,%eax
  802d97:	e8 b0 fd ff ff       	call   802b4c <fsipc>
  802d9c:	89 c3                	mov    %eax,%ebx
  802d9e:	85 c0                	test   %eax,%eax
  802da0:	79 15                	jns    802db7 <open+0x6b>
		fd_close(fd, 0);
  802da2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802da9:	00 
  802daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dad:	89 04 24             	mov    %eax,(%esp)
  802db0:	e8 a9 01 00 00       	call   802f5e <fd_close>
		return r;
  802db5:	eb 14                	jmp    802dcb <open+0x7f>
	}

	return fd2num(fd);
  802db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dba:	89 04 24             	mov    %eax,(%esp)
  802dbd:	e8 6e 00 00 00       	call   802e30 <fd2num>
  802dc2:	89 c3                	mov    %eax,%ebx
  802dc4:	eb 05                	jmp    802dcb <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802dc6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802dcb:	89 d8                	mov    %ebx,%eax
  802dcd:	83 c4 20             	add    $0x20,%esp
  802dd0:	5b                   	pop    %ebx
  802dd1:	5e                   	pop    %esi
  802dd2:	5d                   	pop    %ebp
  802dd3:	c3                   	ret    

00802dd4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802dd4:	55                   	push   %ebp
  802dd5:	89 e5                	mov    %esp,%ebp
  802dd7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802dda:	ba 00 00 00 00       	mov    $0x0,%edx
  802ddf:	b8 08 00 00 00       	mov    $0x8,%eax
  802de4:	e8 63 fd ff ff       	call   802b4c <fsipc>
}
  802de9:	c9                   	leave  
  802dea:	c3                   	ret    
	...

00802dec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802dec:	55                   	push   %ebp
  802ded:	89 e5                	mov    %esp,%ebp
  802def:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802df2:	89 c2                	mov    %eax,%edx
  802df4:	c1 ea 16             	shr    $0x16,%edx
  802df7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802dfe:	f6 c2 01             	test   $0x1,%dl
  802e01:	74 1e                	je     802e21 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802e03:	c1 e8 0c             	shr    $0xc,%eax
  802e06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802e0d:	a8 01                	test   $0x1,%al
  802e0f:	74 17                	je     802e28 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802e11:	c1 e8 0c             	shr    $0xc,%eax
  802e14:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802e1b:	ef 
  802e1c:	0f b7 c0             	movzwl %ax,%eax
  802e1f:	eb 0c                	jmp    802e2d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802e21:	b8 00 00 00 00       	mov    $0x0,%eax
  802e26:	eb 05                	jmp    802e2d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802e28:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802e2d:	5d                   	pop    %ebp
  802e2e:	c3                   	ret    
	...

00802e30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802e30:	55                   	push   %ebp
  802e31:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802e33:	8b 45 08             	mov    0x8(%ebp),%eax
  802e36:	05 00 00 00 30       	add    $0x30000000,%eax
  802e3b:	c1 e8 0c             	shr    $0xc,%eax
}
  802e3e:	5d                   	pop    %ebp
  802e3f:	c3                   	ret    

00802e40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802e40:	55                   	push   %ebp
  802e41:	89 e5                	mov    %esp,%ebp
  802e43:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802e46:	8b 45 08             	mov    0x8(%ebp),%eax
  802e49:	89 04 24             	mov    %eax,(%esp)
  802e4c:	e8 df ff ff ff       	call   802e30 <fd2num>
  802e51:	05 20 00 0d 00       	add    $0xd0020,%eax
  802e56:	c1 e0 0c             	shl    $0xc,%eax
}
  802e59:	c9                   	leave  
  802e5a:	c3                   	ret    

00802e5b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802e5b:	55                   	push   %ebp
  802e5c:	89 e5                	mov    %esp,%ebp
  802e5e:	53                   	push   %ebx
  802e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802e62:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802e67:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802e69:	89 c2                	mov    %eax,%edx
  802e6b:	c1 ea 16             	shr    $0x16,%edx
  802e6e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802e75:	f6 c2 01             	test   $0x1,%dl
  802e78:	74 11                	je     802e8b <fd_alloc+0x30>
  802e7a:	89 c2                	mov    %eax,%edx
  802e7c:	c1 ea 0c             	shr    $0xc,%edx
  802e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802e86:	f6 c2 01             	test   $0x1,%dl
  802e89:	75 09                	jne    802e94 <fd_alloc+0x39>
			*fd_store = fd;
  802e8b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  802e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  802e92:	eb 17                	jmp    802eab <fd_alloc+0x50>
  802e94:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802e99:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802e9e:	75 c7                	jne    802e67 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802ea0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  802ea6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802eab:	5b                   	pop    %ebx
  802eac:	5d                   	pop    %ebp
  802ead:	c3                   	ret    

00802eae <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802eae:	55                   	push   %ebp
  802eaf:	89 e5                	mov    %esp,%ebp
  802eb1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802eb4:	83 f8 1f             	cmp    $0x1f,%eax
  802eb7:	77 36                	ja     802eef <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802eb9:	05 00 00 0d 00       	add    $0xd0000,%eax
  802ebe:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802ec1:	89 c2                	mov    %eax,%edx
  802ec3:	c1 ea 16             	shr    $0x16,%edx
  802ec6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ecd:	f6 c2 01             	test   $0x1,%dl
  802ed0:	74 24                	je     802ef6 <fd_lookup+0x48>
  802ed2:	89 c2                	mov    %eax,%edx
  802ed4:	c1 ea 0c             	shr    $0xc,%edx
  802ed7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ede:	f6 c2 01             	test   $0x1,%dl
  802ee1:	74 1a                	je     802efd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
  802ee6:	89 02                	mov    %eax,(%edx)
	return 0;
  802ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  802eed:	eb 13                	jmp    802f02 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802ef4:	eb 0c                	jmp    802f02 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802efb:	eb 05                	jmp    802f02 <fd_lookup+0x54>
  802efd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802f02:	5d                   	pop    %ebp
  802f03:	c3                   	ret    

00802f04 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802f04:	55                   	push   %ebp
  802f05:	89 e5                	mov    %esp,%ebp
  802f07:	53                   	push   %ebx
  802f08:	83 ec 14             	sub    $0x14,%esp
  802f0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  802f11:	ba 00 00 00 00       	mov    $0x0,%edx
  802f16:	eb 0e                	jmp    802f26 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  802f18:	39 08                	cmp    %ecx,(%eax)
  802f1a:	75 09                	jne    802f25 <dev_lookup+0x21>
			*dev = devtab[i];
  802f1c:	89 03                	mov    %eax,(%ebx)
			return 0;
  802f1e:	b8 00 00 00 00       	mov    $0x0,%eax
  802f23:	eb 33                	jmp    802f58 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802f25:	42                   	inc    %edx
  802f26:	8b 04 95 e8 4a 80 00 	mov    0x804ae8(,%edx,4),%eax
  802f2d:	85 c0                	test   %eax,%eax
  802f2f:	75 e7                	jne    802f18 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802f31:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802f36:	8b 40 48             	mov    0x48(%eax),%eax
  802f39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f41:	c7 04 24 68 4a 80 00 	movl   $0x804a68,(%esp)
  802f48:	e8 cf ed ff ff       	call   801d1c <cprintf>
	*dev = 0;
  802f4d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  802f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802f58:	83 c4 14             	add    $0x14,%esp
  802f5b:	5b                   	pop    %ebx
  802f5c:	5d                   	pop    %ebp
  802f5d:	c3                   	ret    

00802f5e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802f5e:	55                   	push   %ebp
  802f5f:	89 e5                	mov    %esp,%ebp
  802f61:	56                   	push   %esi
  802f62:	53                   	push   %ebx
  802f63:	83 ec 30             	sub    $0x30,%esp
  802f66:	8b 75 08             	mov    0x8(%ebp),%esi
  802f69:	8a 45 0c             	mov    0xc(%ebp),%al
  802f6c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802f6f:	89 34 24             	mov    %esi,(%esp)
  802f72:	e8 b9 fe ff ff       	call   802e30 <fd2num>
  802f77:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802f7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f7e:	89 04 24             	mov    %eax,(%esp)
  802f81:	e8 28 ff ff ff       	call   802eae <fd_lookup>
  802f86:	89 c3                	mov    %eax,%ebx
  802f88:	85 c0                	test   %eax,%eax
  802f8a:	78 05                	js     802f91 <fd_close+0x33>
	    || fd != fd2)
  802f8c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802f8f:	74 0d                	je     802f9e <fd_close+0x40>
		return (must_exist ? r : 0);
  802f91:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802f95:	75 46                	jne    802fdd <fd_close+0x7f>
  802f97:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f9c:	eb 3f                	jmp    802fdd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802f9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fa5:	8b 06                	mov    (%esi),%eax
  802fa7:	89 04 24             	mov    %eax,(%esp)
  802faa:	e8 55 ff ff ff       	call   802f04 <dev_lookup>
  802faf:	89 c3                	mov    %eax,%ebx
  802fb1:	85 c0                	test   %eax,%eax
  802fb3:	78 18                	js     802fcd <fd_close+0x6f>
		if (dev->dev_close)
  802fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fb8:	8b 40 10             	mov    0x10(%eax),%eax
  802fbb:	85 c0                	test   %eax,%eax
  802fbd:	74 09                	je     802fc8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802fbf:	89 34 24             	mov    %esi,(%esp)
  802fc2:	ff d0                	call   *%eax
  802fc4:	89 c3                	mov    %eax,%ebx
  802fc6:	eb 05                	jmp    802fcd <fd_close+0x6f>
		else
			r = 0;
  802fc8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802fcd:	89 74 24 04          	mov    %esi,0x4(%esp)
  802fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fd8:	e8 83 f7 ff ff       	call   802760 <sys_page_unmap>
	return r;
}
  802fdd:	89 d8                	mov    %ebx,%eax
  802fdf:	83 c4 30             	add    $0x30,%esp
  802fe2:	5b                   	pop    %ebx
  802fe3:	5e                   	pop    %esi
  802fe4:	5d                   	pop    %ebp
  802fe5:	c3                   	ret    

00802fe6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802fe6:	55                   	push   %ebp
  802fe7:	89 e5                	mov    %esp,%ebp
  802fe9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802fec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fef:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  802ff6:	89 04 24             	mov    %eax,(%esp)
  802ff9:	e8 b0 fe ff ff       	call   802eae <fd_lookup>
  802ffe:	85 c0                	test   %eax,%eax
  803000:	78 13                	js     803015 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  803002:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803009:	00 
  80300a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80300d:	89 04 24             	mov    %eax,(%esp)
  803010:	e8 49 ff ff ff       	call   802f5e <fd_close>
}
  803015:	c9                   	leave  
  803016:	c3                   	ret    

00803017 <close_all>:

void
close_all(void)
{
  803017:	55                   	push   %ebp
  803018:	89 e5                	mov    %esp,%ebp
  80301a:	53                   	push   %ebx
  80301b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80301e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  803023:	89 1c 24             	mov    %ebx,(%esp)
  803026:	e8 bb ff ff ff       	call   802fe6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80302b:	43                   	inc    %ebx
  80302c:	83 fb 20             	cmp    $0x20,%ebx
  80302f:	75 f2                	jne    803023 <close_all+0xc>
		close(i);
}
  803031:	83 c4 14             	add    $0x14,%esp
  803034:	5b                   	pop    %ebx
  803035:	5d                   	pop    %ebp
  803036:	c3                   	ret    

00803037 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  803037:	55                   	push   %ebp
  803038:	89 e5                	mov    %esp,%ebp
  80303a:	57                   	push   %edi
  80303b:	56                   	push   %esi
  80303c:	53                   	push   %ebx
  80303d:	83 ec 4c             	sub    $0x4c,%esp
  803040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  803043:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80304a:	8b 45 08             	mov    0x8(%ebp),%eax
  80304d:	89 04 24             	mov    %eax,(%esp)
  803050:	e8 59 fe ff ff       	call   802eae <fd_lookup>
  803055:	89 c3                	mov    %eax,%ebx
  803057:	85 c0                	test   %eax,%eax
  803059:	0f 88 e1 00 00 00    	js     803140 <dup+0x109>
		return r;
	close(newfdnum);
  80305f:	89 3c 24             	mov    %edi,(%esp)
  803062:	e8 7f ff ff ff       	call   802fe6 <close>

	newfd = INDEX2FD(newfdnum);
  803067:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80306d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  803070:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803073:	89 04 24             	mov    %eax,(%esp)
  803076:	e8 c5 fd ff ff       	call   802e40 <fd2data>
  80307b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80307d:	89 34 24             	mov    %esi,(%esp)
  803080:	e8 bb fd ff ff       	call   802e40 <fd2data>
  803085:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  803088:	89 d8                	mov    %ebx,%eax
  80308a:	c1 e8 16             	shr    $0x16,%eax
  80308d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  803094:	a8 01                	test   $0x1,%al
  803096:	74 46                	je     8030de <dup+0xa7>
  803098:	89 d8                	mov    %ebx,%eax
  80309a:	c1 e8 0c             	shr    $0xc,%eax
  80309d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8030a4:	f6 c2 01             	test   $0x1,%dl
  8030a7:	74 35                	je     8030de <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8030a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8030b0:	25 07 0e 00 00       	and    $0xe07,%eax
  8030b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8030b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8030bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8030c7:	00 
  8030c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8030cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030d3:	e8 35 f6 ff ff       	call   80270d <sys_page_map>
  8030d8:	89 c3                	mov    %eax,%ebx
  8030da:	85 c0                	test   %eax,%eax
  8030dc:	78 3b                	js     803119 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8030de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030e1:	89 c2                	mov    %eax,%edx
  8030e3:	c1 ea 0c             	shr    $0xc,%edx
  8030e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8030ed:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8030f3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8030f7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8030fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803102:	00 
  803103:	89 44 24 04          	mov    %eax,0x4(%esp)
  803107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80310e:	e8 fa f5 ff ff       	call   80270d <sys_page_map>
  803113:	89 c3                	mov    %eax,%ebx
  803115:	85 c0                	test   %eax,%eax
  803117:	79 25                	jns    80313e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  803119:	89 74 24 04          	mov    %esi,0x4(%esp)
  80311d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803124:	e8 37 f6 ff ff       	call   802760 <sys_page_unmap>
	sys_page_unmap(0, nva);
  803129:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80312c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803137:	e8 24 f6 ff ff       	call   802760 <sys_page_unmap>
	return r;
  80313c:	eb 02                	jmp    803140 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80313e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  803140:	89 d8                	mov    %ebx,%eax
  803142:	83 c4 4c             	add    $0x4c,%esp
  803145:	5b                   	pop    %ebx
  803146:	5e                   	pop    %esi
  803147:	5f                   	pop    %edi
  803148:	5d                   	pop    %ebp
  803149:	c3                   	ret    

0080314a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80314a:	55                   	push   %ebp
  80314b:	89 e5                	mov    %esp,%ebp
  80314d:	53                   	push   %ebx
  80314e:	83 ec 24             	sub    $0x24,%esp
  803151:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803154:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80315b:	89 1c 24             	mov    %ebx,(%esp)
  80315e:	e8 4b fd ff ff       	call   802eae <fd_lookup>
  803163:	85 c0                	test   %eax,%eax
  803165:	78 6d                	js     8031d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803167:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80316a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80316e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803171:	8b 00                	mov    (%eax),%eax
  803173:	89 04 24             	mov    %eax,(%esp)
  803176:	e8 89 fd ff ff       	call   802f04 <dev_lookup>
  80317b:	85 c0                	test   %eax,%eax
  80317d:	78 55                	js     8031d4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80317f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803182:	8b 50 08             	mov    0x8(%eax),%edx
  803185:	83 e2 03             	and    $0x3,%edx
  803188:	83 fa 01             	cmp    $0x1,%edx
  80318b:	75 23                	jne    8031b0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80318d:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803192:	8b 40 48             	mov    0x48(%eax),%eax
  803195:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80319d:	c7 04 24 ac 4a 80 00 	movl   $0x804aac,(%esp)
  8031a4:	e8 73 eb ff ff       	call   801d1c <cprintf>
		return -E_INVAL;
  8031a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8031ae:	eb 24                	jmp    8031d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8031b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031b3:	8b 52 08             	mov    0x8(%edx),%edx
  8031b6:	85 d2                	test   %edx,%edx
  8031b8:	74 15                	je     8031cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8031ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8031bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8031c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8031c8:	89 04 24             	mov    %eax,(%esp)
  8031cb:	ff d2                	call   *%edx
  8031cd:	eb 05                	jmp    8031d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8031cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8031d4:	83 c4 24             	add    $0x24,%esp
  8031d7:	5b                   	pop    %ebx
  8031d8:	5d                   	pop    %ebp
  8031d9:	c3                   	ret    

008031da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8031da:	55                   	push   %ebp
  8031db:	89 e5                	mov    %esp,%ebp
  8031dd:	57                   	push   %edi
  8031de:	56                   	push   %esi
  8031df:	53                   	push   %ebx
  8031e0:	83 ec 1c             	sub    $0x1c,%esp
  8031e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8031e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8031e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8031ee:	eb 23                	jmp    803213 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8031f0:	89 f0                	mov    %esi,%eax
  8031f2:	29 d8                	sub    %ebx,%eax
  8031f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8031f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031fb:	01 d8                	add    %ebx,%eax
  8031fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  803201:	89 3c 24             	mov    %edi,(%esp)
  803204:	e8 41 ff ff ff       	call   80314a <read>
		if (m < 0)
  803209:	85 c0                	test   %eax,%eax
  80320b:	78 10                	js     80321d <readn+0x43>
			return m;
		if (m == 0)
  80320d:	85 c0                	test   %eax,%eax
  80320f:	74 0a                	je     80321b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803211:	01 c3                	add    %eax,%ebx
  803213:	39 f3                	cmp    %esi,%ebx
  803215:	72 d9                	jb     8031f0 <readn+0x16>
  803217:	89 d8                	mov    %ebx,%eax
  803219:	eb 02                	jmp    80321d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80321b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80321d:	83 c4 1c             	add    $0x1c,%esp
  803220:	5b                   	pop    %ebx
  803221:	5e                   	pop    %esi
  803222:	5f                   	pop    %edi
  803223:	5d                   	pop    %ebp
  803224:	c3                   	ret    

00803225 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  803225:	55                   	push   %ebp
  803226:	89 e5                	mov    %esp,%ebp
  803228:	53                   	push   %ebx
  803229:	83 ec 24             	sub    $0x24,%esp
  80322c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80322f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803232:	89 44 24 04          	mov    %eax,0x4(%esp)
  803236:	89 1c 24             	mov    %ebx,(%esp)
  803239:	e8 70 fc ff ff       	call   802eae <fd_lookup>
  80323e:	85 c0                	test   %eax,%eax
  803240:	78 68                	js     8032aa <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803242:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803245:	89 44 24 04          	mov    %eax,0x4(%esp)
  803249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80324c:	8b 00                	mov    (%eax),%eax
  80324e:	89 04 24             	mov    %eax,(%esp)
  803251:	e8 ae fc ff ff       	call   802f04 <dev_lookup>
  803256:	85 c0                	test   %eax,%eax
  803258:	78 50                	js     8032aa <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80325a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80325d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803261:	75 23                	jne    803286 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  803263:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803268:	8b 40 48             	mov    0x48(%eax),%eax
  80326b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80326f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803273:	c7 04 24 c8 4a 80 00 	movl   $0x804ac8,(%esp)
  80327a:	e8 9d ea ff ff       	call   801d1c <cprintf>
		return -E_INVAL;
  80327f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803284:	eb 24                	jmp    8032aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  803286:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803289:	8b 52 0c             	mov    0xc(%edx),%edx
  80328c:	85 d2                	test   %edx,%edx
  80328e:	74 15                	je     8032a5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  803290:	8b 4d 10             	mov    0x10(%ebp),%ecx
  803293:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803297:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80329a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80329e:	89 04 24             	mov    %eax,(%esp)
  8032a1:	ff d2                	call   *%edx
  8032a3:	eb 05                	jmp    8032aa <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8032a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8032aa:	83 c4 24             	add    $0x24,%esp
  8032ad:	5b                   	pop    %ebx
  8032ae:	5d                   	pop    %ebp
  8032af:	c3                   	ret    

008032b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8032b0:	55                   	push   %ebp
  8032b1:	89 e5                	mov    %esp,%ebp
  8032b3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8032b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8032b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8032c0:	89 04 24             	mov    %eax,(%esp)
  8032c3:	e8 e6 fb ff ff       	call   802eae <fd_lookup>
  8032c8:	85 c0                	test   %eax,%eax
  8032ca:	78 0e                	js     8032da <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8032cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8032cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032d2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8032d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8032da:	c9                   	leave  
  8032db:	c3                   	ret    

008032dc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8032dc:	55                   	push   %ebp
  8032dd:	89 e5                	mov    %esp,%ebp
  8032df:	53                   	push   %ebx
  8032e0:	83 ec 24             	sub    $0x24,%esp
  8032e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8032e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8032e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032ed:	89 1c 24             	mov    %ebx,(%esp)
  8032f0:	e8 b9 fb ff ff       	call   802eae <fd_lookup>
  8032f5:	85 c0                	test   %eax,%eax
  8032f7:	78 61                	js     80335a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8032f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  803300:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803303:	8b 00                	mov    (%eax),%eax
  803305:	89 04 24             	mov    %eax,(%esp)
  803308:	e8 f7 fb ff ff       	call   802f04 <dev_lookup>
  80330d:	85 c0                	test   %eax,%eax
  80330f:	78 49                	js     80335a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  803311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803314:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803318:	75 23                	jne    80333d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80331a:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80331f:	8b 40 48             	mov    0x48(%eax),%eax
  803322:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80332a:	c7 04 24 88 4a 80 00 	movl   $0x804a88,(%esp)
  803331:	e8 e6 e9 ff ff       	call   801d1c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  803336:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80333b:	eb 1d                	jmp    80335a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80333d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803340:	8b 52 18             	mov    0x18(%edx),%edx
  803343:	85 d2                	test   %edx,%edx
  803345:	74 0e                	je     803355 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  803347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80334a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80334e:	89 04 24             	mov    %eax,(%esp)
  803351:	ff d2                	call   *%edx
  803353:	eb 05                	jmp    80335a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  803355:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80335a:	83 c4 24             	add    $0x24,%esp
  80335d:	5b                   	pop    %ebx
  80335e:	5d                   	pop    %ebp
  80335f:	c3                   	ret    

00803360 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  803360:	55                   	push   %ebp
  803361:	89 e5                	mov    %esp,%ebp
  803363:	53                   	push   %ebx
  803364:	83 ec 24             	sub    $0x24,%esp
  803367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80336a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80336d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803371:	8b 45 08             	mov    0x8(%ebp),%eax
  803374:	89 04 24             	mov    %eax,(%esp)
  803377:	e8 32 fb ff ff       	call   802eae <fd_lookup>
  80337c:	85 c0                	test   %eax,%eax
  80337e:	78 52                	js     8033d2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803383:	89 44 24 04          	mov    %eax,0x4(%esp)
  803387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80338a:	8b 00                	mov    (%eax),%eax
  80338c:	89 04 24             	mov    %eax,(%esp)
  80338f:	e8 70 fb ff ff       	call   802f04 <dev_lookup>
  803394:	85 c0                	test   %eax,%eax
  803396:	78 3a                	js     8033d2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  803398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80339b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80339f:	74 2c                	je     8033cd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8033a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8033a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8033ab:	00 00 00 
	stat->st_isdir = 0;
  8033ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8033b5:	00 00 00 
	stat->st_dev = dev;
  8033b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8033be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8033c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8033c5:	89 14 24             	mov    %edx,(%esp)
  8033c8:	ff 50 14             	call   *0x14(%eax)
  8033cb:	eb 05                	jmp    8033d2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8033cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8033d2:	83 c4 24             	add    $0x24,%esp
  8033d5:	5b                   	pop    %ebx
  8033d6:	5d                   	pop    %ebp
  8033d7:	c3                   	ret    

008033d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8033d8:	55                   	push   %ebp
  8033d9:	89 e5                	mov    %esp,%ebp
  8033db:	56                   	push   %esi
  8033dc:	53                   	push   %ebx
  8033dd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8033e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8033e7:	00 
  8033e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8033eb:	89 04 24             	mov    %eax,(%esp)
  8033ee:	e8 59 f9 ff ff       	call   802d4c <open>
  8033f3:	89 c3                	mov    %eax,%ebx
  8033f5:	85 c0                	test   %eax,%eax
  8033f7:	78 1b                	js     803414 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8033f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  803400:	89 1c 24             	mov    %ebx,(%esp)
  803403:	e8 58 ff ff ff       	call   803360 <fstat>
  803408:	89 c6                	mov    %eax,%esi
	close(fd);
  80340a:	89 1c 24             	mov    %ebx,(%esp)
  80340d:	e8 d4 fb ff ff       	call   802fe6 <close>
	return r;
  803412:	89 f3                	mov    %esi,%ebx
}
  803414:	89 d8                	mov    %ebx,%eax
  803416:	83 c4 10             	add    $0x10,%esp
  803419:	5b                   	pop    %ebx
  80341a:	5e                   	pop    %esi
  80341b:	5d                   	pop    %ebp
  80341c:	c3                   	ret    
  80341d:	00 00                	add    %al,(%eax)
	...

00803420 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803420:	55                   	push   %ebp
  803421:	89 e5                	mov    %esp,%ebp
  803423:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  803426:	c7 44 24 04 fc 4a 80 	movl   $0x804afc,0x4(%esp)
  80342d:	00 
  80342e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803431:	89 04 24             	mov    %eax,(%esp)
  803434:	e8 8e ee ff ff       	call   8022c7 <strcpy>
	return 0;
}
  803439:	b8 00 00 00 00       	mov    $0x0,%eax
  80343e:	c9                   	leave  
  80343f:	c3                   	ret    

00803440 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803440:	55                   	push   %ebp
  803441:	89 e5                	mov    %esp,%ebp
  803443:	53                   	push   %ebx
  803444:	83 ec 14             	sub    $0x14,%esp
  803447:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80344a:	89 1c 24             	mov    %ebx,(%esp)
  80344d:	e8 9a f9 ff ff       	call   802dec <pageref>
  803452:	83 f8 01             	cmp    $0x1,%eax
  803455:	75 0d                	jne    803464 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  803457:	8b 43 0c             	mov    0xc(%ebx),%eax
  80345a:	89 04 24             	mov    %eax,(%esp)
  80345d:	e8 1f 03 00 00       	call   803781 <nsipc_close>
  803462:	eb 05                	jmp    803469 <devsock_close+0x29>
	else
		return 0;
  803464:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803469:	83 c4 14             	add    $0x14,%esp
  80346c:	5b                   	pop    %ebx
  80346d:	5d                   	pop    %ebp
  80346e:	c3                   	ret    

0080346f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80346f:	55                   	push   %ebp
  803470:	89 e5                	mov    %esp,%ebp
  803472:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  803475:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80347c:	00 
  80347d:	8b 45 10             	mov    0x10(%ebp),%eax
  803480:	89 44 24 08          	mov    %eax,0x8(%esp)
  803484:	8b 45 0c             	mov    0xc(%ebp),%eax
  803487:	89 44 24 04          	mov    %eax,0x4(%esp)
  80348b:	8b 45 08             	mov    0x8(%ebp),%eax
  80348e:	8b 40 0c             	mov    0xc(%eax),%eax
  803491:	89 04 24             	mov    %eax,(%esp)
  803494:	e8 e3 03 00 00       	call   80387c <nsipc_send>
}
  803499:	c9                   	leave  
  80349a:	c3                   	ret    

0080349b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80349b:	55                   	push   %ebp
  80349c:	89 e5                	mov    %esp,%ebp
  80349e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8034a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8034a8:	00 
  8034a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8034ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8034b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8034ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8034bd:	89 04 24             	mov    %eax,(%esp)
  8034c0:	e8 37 03 00 00       	call   8037fc <nsipc_recv>
}
  8034c5:	c9                   	leave  
  8034c6:	c3                   	ret    

008034c7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8034c7:	55                   	push   %ebp
  8034c8:	89 e5                	mov    %esp,%ebp
  8034ca:	56                   	push   %esi
  8034cb:	53                   	push   %ebx
  8034cc:	83 ec 20             	sub    $0x20,%esp
  8034cf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8034d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034d4:	89 04 24             	mov    %eax,(%esp)
  8034d7:	e8 7f f9 ff ff       	call   802e5b <fd_alloc>
  8034dc:	89 c3                	mov    %eax,%ebx
  8034de:	85 c0                	test   %eax,%eax
  8034e0:	78 21                	js     803503 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8034e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8034e9:	00 
  8034ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034f8:	e8 bc f1 ff ff       	call   8026b9 <sys_page_alloc>
  8034fd:	89 c3                	mov    %eax,%ebx
  8034ff:	85 c0                	test   %eax,%eax
  803501:	79 0a                	jns    80350d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  803503:	89 34 24             	mov    %esi,(%esp)
  803506:	e8 76 02 00 00       	call   803781 <nsipc_close>
		return r;
  80350b:	eb 22                	jmp    80352f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80350d:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803513:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803516:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80351b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  803522:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  803525:	89 04 24             	mov    %eax,(%esp)
  803528:	e8 03 f9 ff ff       	call   802e30 <fd2num>
  80352d:	89 c3                	mov    %eax,%ebx
}
  80352f:	89 d8                	mov    %ebx,%eax
  803531:	83 c4 20             	add    $0x20,%esp
  803534:	5b                   	pop    %ebx
  803535:	5e                   	pop    %esi
  803536:	5d                   	pop    %ebp
  803537:	c3                   	ret    

00803538 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  803538:	55                   	push   %ebp
  803539:	89 e5                	mov    %esp,%ebp
  80353b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80353e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803541:	89 54 24 04          	mov    %edx,0x4(%esp)
  803545:	89 04 24             	mov    %eax,(%esp)
  803548:	e8 61 f9 ff ff       	call   802eae <fd_lookup>
  80354d:	85 c0                	test   %eax,%eax
  80354f:	78 17                	js     803568 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803551:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803554:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80355a:	39 10                	cmp    %edx,(%eax)
  80355c:	75 05                	jne    803563 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80355e:	8b 40 0c             	mov    0xc(%eax),%eax
  803561:	eb 05                	jmp    803568 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  803563:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  803568:	c9                   	leave  
  803569:	c3                   	ret    

0080356a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80356a:	55                   	push   %ebp
  80356b:	89 e5                	mov    %esp,%ebp
  80356d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803570:	8b 45 08             	mov    0x8(%ebp),%eax
  803573:	e8 c0 ff ff ff       	call   803538 <fd2sockid>
  803578:	85 c0                	test   %eax,%eax
  80357a:	78 1f                	js     80359b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80357c:	8b 55 10             	mov    0x10(%ebp),%edx
  80357f:	89 54 24 08          	mov    %edx,0x8(%esp)
  803583:	8b 55 0c             	mov    0xc(%ebp),%edx
  803586:	89 54 24 04          	mov    %edx,0x4(%esp)
  80358a:	89 04 24             	mov    %eax,(%esp)
  80358d:	e8 38 01 00 00       	call   8036ca <nsipc_accept>
  803592:	85 c0                	test   %eax,%eax
  803594:	78 05                	js     80359b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  803596:	e8 2c ff ff ff       	call   8034c7 <alloc_sockfd>
}
  80359b:	c9                   	leave  
  80359c:	c3                   	ret    

0080359d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80359d:	55                   	push   %ebp
  80359e:	89 e5                	mov    %esp,%ebp
  8035a0:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8035a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8035a6:	e8 8d ff ff ff       	call   803538 <fd2sockid>
  8035ab:	85 c0                	test   %eax,%eax
  8035ad:	78 16                	js     8035c5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8035af:	8b 55 10             	mov    0x10(%ebp),%edx
  8035b2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8035b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8035b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8035bd:	89 04 24             	mov    %eax,(%esp)
  8035c0:	e8 5b 01 00 00       	call   803720 <nsipc_bind>
}
  8035c5:	c9                   	leave  
  8035c6:	c3                   	ret    

008035c7 <shutdown>:

int
shutdown(int s, int how)
{
  8035c7:	55                   	push   %ebp
  8035c8:	89 e5                	mov    %esp,%ebp
  8035ca:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8035cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8035d0:	e8 63 ff ff ff       	call   803538 <fd2sockid>
  8035d5:	85 c0                	test   %eax,%eax
  8035d7:	78 0f                	js     8035e8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8035d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8035dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8035e0:	89 04 24             	mov    %eax,(%esp)
  8035e3:	e8 77 01 00 00       	call   80375f <nsipc_shutdown>
}
  8035e8:	c9                   	leave  
  8035e9:	c3                   	ret    

008035ea <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8035ea:	55                   	push   %ebp
  8035eb:	89 e5                	mov    %esp,%ebp
  8035ed:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8035f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8035f3:	e8 40 ff ff ff       	call   803538 <fd2sockid>
  8035f8:	85 c0                	test   %eax,%eax
  8035fa:	78 16                	js     803612 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8035fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8035ff:	89 54 24 08          	mov    %edx,0x8(%esp)
  803603:	8b 55 0c             	mov    0xc(%ebp),%edx
  803606:	89 54 24 04          	mov    %edx,0x4(%esp)
  80360a:	89 04 24             	mov    %eax,(%esp)
  80360d:	e8 89 01 00 00       	call   80379b <nsipc_connect>
}
  803612:	c9                   	leave  
  803613:	c3                   	ret    

00803614 <listen>:

int
listen(int s, int backlog)
{
  803614:	55                   	push   %ebp
  803615:	89 e5                	mov    %esp,%ebp
  803617:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80361a:	8b 45 08             	mov    0x8(%ebp),%eax
  80361d:	e8 16 ff ff ff       	call   803538 <fd2sockid>
  803622:	85 c0                	test   %eax,%eax
  803624:	78 0f                	js     803635 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803626:	8b 55 0c             	mov    0xc(%ebp),%edx
  803629:	89 54 24 04          	mov    %edx,0x4(%esp)
  80362d:	89 04 24             	mov    %eax,(%esp)
  803630:	e8 a5 01 00 00       	call   8037da <nsipc_listen>
}
  803635:	c9                   	leave  
  803636:	c3                   	ret    

00803637 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803637:	55                   	push   %ebp
  803638:	89 e5                	mov    %esp,%ebp
  80363a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80363d:	8b 45 10             	mov    0x10(%ebp),%eax
  803640:	89 44 24 08          	mov    %eax,0x8(%esp)
  803644:	8b 45 0c             	mov    0xc(%ebp),%eax
  803647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80364b:	8b 45 08             	mov    0x8(%ebp),%eax
  80364e:	89 04 24             	mov    %eax,(%esp)
  803651:	e8 99 02 00 00       	call   8038ef <nsipc_socket>
  803656:	85 c0                	test   %eax,%eax
  803658:	78 05                	js     80365f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  80365a:	e8 68 fe ff ff       	call   8034c7 <alloc_sockfd>
}
  80365f:	c9                   	leave  
  803660:	c3                   	ret    
  803661:	00 00                	add    %al,(%eax)
	...

00803664 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803664:	55                   	push   %ebp
  803665:	89 e5                	mov    %esp,%ebp
  803667:	53                   	push   %ebx
  803668:	83 ec 14             	sub    $0x14,%esp
  80366b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80366d:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803674:	75 11                	jne    803687 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803676:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80367d:	e8 91 f4 ff ff       	call   802b13 <ipc_find_env>
  803682:	a3 04 a0 80 00       	mov    %eax,0x80a004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803687:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80368e:	00 
  80368f:	c7 44 24 08 00 c0 80 	movl   $0x80c000,0x8(%esp)
  803696:	00 
  803697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80369b:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8036a0:	89 04 24             	mov    %eax,(%esp)
  8036a3:	e8 fd f3 ff ff       	call   802aa5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8036a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8036af:	00 
  8036b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8036b7:	00 
  8036b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036bf:	e8 78 f3 ff ff       	call   802a3c <ipc_recv>
}
  8036c4:	83 c4 14             	add    $0x14,%esp
  8036c7:	5b                   	pop    %ebx
  8036c8:	5d                   	pop    %ebp
  8036c9:	c3                   	ret    

008036ca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8036ca:	55                   	push   %ebp
  8036cb:	89 e5                	mov    %esp,%ebp
  8036cd:	56                   	push   %esi
  8036ce:	53                   	push   %ebx
  8036cf:	83 ec 10             	sub    $0x10,%esp
  8036d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8036d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8036d8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8036dd:	8b 06                	mov    (%esi),%eax
  8036df:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8036e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8036e9:	e8 76 ff ff ff       	call   803664 <nsipc>
  8036ee:	89 c3                	mov    %eax,%ebx
  8036f0:	85 c0                	test   %eax,%eax
  8036f2:	78 23                	js     803717 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8036f4:	a1 10 c0 80 00       	mov    0x80c010,%eax
  8036f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8036fd:	c7 44 24 04 00 c0 80 	movl   $0x80c000,0x4(%esp)
  803704:	00 
  803705:	8b 45 0c             	mov    0xc(%ebp),%eax
  803708:	89 04 24             	mov    %eax,(%esp)
  80370b:	e8 30 ed ff ff       	call   802440 <memmove>
		*addrlen = ret->ret_addrlen;
  803710:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803715:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  803717:	89 d8                	mov    %ebx,%eax
  803719:	83 c4 10             	add    $0x10,%esp
  80371c:	5b                   	pop    %ebx
  80371d:	5e                   	pop    %esi
  80371e:	5d                   	pop    %ebp
  80371f:	c3                   	ret    

00803720 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803720:	55                   	push   %ebp
  803721:	89 e5                	mov    %esp,%ebp
  803723:	53                   	push   %ebx
  803724:	83 ec 14             	sub    $0x14,%esp
  803727:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80372a:	8b 45 08             	mov    0x8(%ebp),%eax
  80372d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803732:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803736:	8b 45 0c             	mov    0xc(%ebp),%eax
  803739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80373d:	c7 04 24 04 c0 80 00 	movl   $0x80c004,(%esp)
  803744:	e8 f7 ec ff ff       	call   802440 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803749:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  80374f:	b8 02 00 00 00       	mov    $0x2,%eax
  803754:	e8 0b ff ff ff       	call   803664 <nsipc>
}
  803759:	83 c4 14             	add    $0x14,%esp
  80375c:	5b                   	pop    %ebx
  80375d:	5d                   	pop    %ebp
  80375e:	c3                   	ret    

0080375f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80375f:	55                   	push   %ebp
  803760:	89 e5                	mov    %esp,%ebp
  803762:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803765:	8b 45 08             	mov    0x8(%ebp),%eax
  803768:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  80376d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803770:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803775:	b8 03 00 00 00       	mov    $0x3,%eax
  80377a:	e8 e5 fe ff ff       	call   803664 <nsipc>
}
  80377f:	c9                   	leave  
  803780:	c3                   	ret    

00803781 <nsipc_close>:

int
nsipc_close(int s)
{
  803781:	55                   	push   %ebp
  803782:	89 e5                	mov    %esp,%ebp
  803784:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803787:	8b 45 08             	mov    0x8(%ebp),%eax
  80378a:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  80378f:	b8 04 00 00 00       	mov    $0x4,%eax
  803794:	e8 cb fe ff ff       	call   803664 <nsipc>
}
  803799:	c9                   	leave  
  80379a:	c3                   	ret    

0080379b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80379b:	55                   	push   %ebp
  80379c:	89 e5                	mov    %esp,%ebp
  80379e:	53                   	push   %ebx
  80379f:	83 ec 14             	sub    $0x14,%esp
  8037a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8037a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8037a8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8037ad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8037b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037b8:	c7 04 24 04 c0 80 00 	movl   $0x80c004,(%esp)
  8037bf:	e8 7c ec ff ff       	call   802440 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8037c4:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  8037ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8037cf:	e8 90 fe ff ff       	call   803664 <nsipc>
}
  8037d4:	83 c4 14             	add    $0x14,%esp
  8037d7:	5b                   	pop    %ebx
  8037d8:	5d                   	pop    %ebp
  8037d9:	c3                   	ret    

008037da <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8037da:	55                   	push   %ebp
  8037db:	89 e5                	mov    %esp,%ebp
  8037dd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8037e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8037e3:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  8037e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037eb:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  8037f0:	b8 06 00 00 00       	mov    $0x6,%eax
  8037f5:	e8 6a fe ff ff       	call   803664 <nsipc>
}
  8037fa:	c9                   	leave  
  8037fb:	c3                   	ret    

008037fc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8037fc:	55                   	push   %ebp
  8037fd:	89 e5                	mov    %esp,%ebp
  8037ff:	56                   	push   %esi
  803800:	53                   	push   %ebx
  803801:	83 ec 10             	sub    $0x10,%esp
  803804:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803807:	8b 45 08             	mov    0x8(%ebp),%eax
  80380a:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  80380f:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803815:	8b 45 14             	mov    0x14(%ebp),%eax
  803818:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80381d:	b8 07 00 00 00       	mov    $0x7,%eax
  803822:	e8 3d fe ff ff       	call   803664 <nsipc>
  803827:	89 c3                	mov    %eax,%ebx
  803829:	85 c0                	test   %eax,%eax
  80382b:	78 46                	js     803873 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80382d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803832:	7f 04                	jg     803838 <nsipc_recv+0x3c>
  803834:	39 c6                	cmp    %eax,%esi
  803836:	7d 24                	jge    80385c <nsipc_recv+0x60>
  803838:	c7 44 24 0c 08 4b 80 	movl   $0x804b08,0xc(%esp)
  80383f:	00 
  803840:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  803847:	00 
  803848:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80384f:	00 
  803850:	c7 04 24 1d 4b 80 00 	movl   $0x804b1d,(%esp)
  803857:	e8 c8 e3 ff ff       	call   801c24 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80385c:	89 44 24 08          	mov    %eax,0x8(%esp)
  803860:	c7 44 24 04 00 c0 80 	movl   $0x80c000,0x4(%esp)
  803867:	00 
  803868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80386b:	89 04 24             	mov    %eax,(%esp)
  80386e:	e8 cd eb ff ff       	call   802440 <memmove>
	}

	return r;
}
  803873:	89 d8                	mov    %ebx,%eax
  803875:	83 c4 10             	add    $0x10,%esp
  803878:	5b                   	pop    %ebx
  803879:	5e                   	pop    %esi
  80387a:	5d                   	pop    %ebp
  80387b:	c3                   	ret    

0080387c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80387c:	55                   	push   %ebp
  80387d:	89 e5                	mov    %esp,%ebp
  80387f:	53                   	push   %ebx
  803880:	83 ec 14             	sub    $0x14,%esp
  803883:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803886:	8b 45 08             	mov    0x8(%ebp),%eax
  803889:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  80388e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803894:	7e 24                	jle    8038ba <nsipc_send+0x3e>
  803896:	c7 44 24 0c 29 4b 80 	movl   $0x804b29,0xc(%esp)
  80389d:	00 
  80389e:	c7 44 24 08 dd 40 80 	movl   $0x8040dd,0x8(%esp)
  8038a5:	00 
  8038a6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8038ad:	00 
  8038ae:	c7 04 24 1d 4b 80 00 	movl   $0x804b1d,(%esp)
  8038b5:	e8 6a e3 ff ff       	call   801c24 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8038ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8038be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038c5:	c7 04 24 0c c0 80 00 	movl   $0x80c00c,(%esp)
  8038cc:	e8 6f eb ff ff       	call   802440 <memmove>
	nsipcbuf.send.req_size = size;
  8038d1:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  8038d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8038da:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  8038df:	b8 08 00 00 00       	mov    $0x8,%eax
  8038e4:	e8 7b fd ff ff       	call   803664 <nsipc>
}
  8038e9:	83 c4 14             	add    $0x14,%esp
  8038ec:	5b                   	pop    %ebx
  8038ed:	5d                   	pop    %ebp
  8038ee:	c3                   	ret    

008038ef <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8038ef:	55                   	push   %ebp
  8038f0:	89 e5                	mov    %esp,%ebp
  8038f2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8038f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8038f8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  8038fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  803900:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  803905:	8b 45 10             	mov    0x10(%ebp),%eax
  803908:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  80390d:	b8 09 00 00 00       	mov    $0x9,%eax
  803912:	e8 4d fd ff ff       	call   803664 <nsipc>
}
  803917:	c9                   	leave  
  803918:	c3                   	ret    
  803919:	00 00                	add    %al,(%eax)
	...

0080391c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80391c:	55                   	push   %ebp
  80391d:	89 e5                	mov    %esp,%ebp
  80391f:	56                   	push   %esi
  803920:	53                   	push   %ebx
  803921:	83 ec 10             	sub    $0x10,%esp
  803924:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803927:	8b 45 08             	mov    0x8(%ebp),%eax
  80392a:	89 04 24             	mov    %eax,(%esp)
  80392d:	e8 0e f5 ff ff       	call   802e40 <fd2data>
  803932:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  803934:	c7 44 24 04 35 4b 80 	movl   $0x804b35,0x4(%esp)
  80393b:	00 
  80393c:	89 34 24             	mov    %esi,(%esp)
  80393f:	e8 83 e9 ff ff       	call   8022c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803944:	8b 43 04             	mov    0x4(%ebx),%eax
  803947:	2b 03                	sub    (%ebx),%eax
  803949:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80394f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  803956:	00 00 00 
	stat->st_dev = &devpipe;
  803959:	c7 86 88 00 00 00 9c 	movl   $0x80909c,0x88(%esi)
  803960:	90 80 00 
	return 0;
}
  803963:	b8 00 00 00 00       	mov    $0x0,%eax
  803968:	83 c4 10             	add    $0x10,%esp
  80396b:	5b                   	pop    %ebx
  80396c:	5e                   	pop    %esi
  80396d:	5d                   	pop    %ebp
  80396e:	c3                   	ret    

0080396f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80396f:	55                   	push   %ebp
  803970:	89 e5                	mov    %esp,%ebp
  803972:	53                   	push   %ebx
  803973:	83 ec 14             	sub    $0x14,%esp
  803976:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803979:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80397d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803984:	e8 d7 ed ff ff       	call   802760 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803989:	89 1c 24             	mov    %ebx,(%esp)
  80398c:	e8 af f4 ff ff       	call   802e40 <fd2data>
  803991:	89 44 24 04          	mov    %eax,0x4(%esp)
  803995:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80399c:	e8 bf ed ff ff       	call   802760 <sys_page_unmap>
}
  8039a1:	83 c4 14             	add    $0x14,%esp
  8039a4:	5b                   	pop    %ebx
  8039a5:	5d                   	pop    %ebp
  8039a6:	c3                   	ret    

008039a7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8039a7:	55                   	push   %ebp
  8039a8:	89 e5                	mov    %esp,%ebp
  8039aa:	57                   	push   %edi
  8039ab:	56                   	push   %esi
  8039ac:	53                   	push   %ebx
  8039ad:	83 ec 2c             	sub    $0x2c,%esp
  8039b0:	89 c7                	mov    %eax,%edi
  8039b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8039b5:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8039ba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8039bd:	89 3c 24             	mov    %edi,(%esp)
  8039c0:	e8 27 f4 ff ff       	call   802dec <pageref>
  8039c5:	89 c6                	mov    %eax,%esi
  8039c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8039ca:	89 04 24             	mov    %eax,(%esp)
  8039cd:	e8 1a f4 ff ff       	call   802dec <pageref>
  8039d2:	39 c6                	cmp    %eax,%esi
  8039d4:	0f 94 c0             	sete   %al
  8039d7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8039da:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  8039e0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8039e3:	39 cb                	cmp    %ecx,%ebx
  8039e5:	75 08                	jne    8039ef <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8039e7:	83 c4 2c             	add    $0x2c,%esp
  8039ea:	5b                   	pop    %ebx
  8039eb:	5e                   	pop    %esi
  8039ec:	5f                   	pop    %edi
  8039ed:	5d                   	pop    %ebp
  8039ee:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8039ef:	83 f8 01             	cmp    $0x1,%eax
  8039f2:	75 c1                	jne    8039b5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8039f4:	8b 42 58             	mov    0x58(%edx),%eax
  8039f7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8039fe:	00 
  8039ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  803a03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803a07:	c7 04 24 3c 4b 80 00 	movl   $0x804b3c,(%esp)
  803a0e:	e8 09 e3 ff ff       	call   801d1c <cprintf>
  803a13:	eb a0                	jmp    8039b5 <_pipeisclosed+0xe>

00803a15 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803a15:	55                   	push   %ebp
  803a16:	89 e5                	mov    %esp,%ebp
  803a18:	57                   	push   %edi
  803a19:	56                   	push   %esi
  803a1a:	53                   	push   %ebx
  803a1b:	83 ec 1c             	sub    $0x1c,%esp
  803a1e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803a21:	89 34 24             	mov    %esi,(%esp)
  803a24:	e8 17 f4 ff ff       	call   802e40 <fd2data>
  803a29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803a2b:	bf 00 00 00 00       	mov    $0x0,%edi
  803a30:	eb 3c                	jmp    803a6e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803a32:	89 da                	mov    %ebx,%edx
  803a34:	89 f0                	mov    %esi,%eax
  803a36:	e8 6c ff ff ff       	call   8039a7 <_pipeisclosed>
  803a3b:	85 c0                	test   %eax,%eax
  803a3d:	75 38                	jne    803a77 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803a3f:	e8 56 ec ff ff       	call   80269a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803a44:	8b 43 04             	mov    0x4(%ebx),%eax
  803a47:	8b 13                	mov    (%ebx),%edx
  803a49:	83 c2 20             	add    $0x20,%edx
  803a4c:	39 d0                	cmp    %edx,%eax
  803a4e:	73 e2                	jae    803a32 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803a50:	8b 55 0c             	mov    0xc(%ebp),%edx
  803a53:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  803a56:	89 c2                	mov    %eax,%edx
  803a58:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  803a5e:	79 05                	jns    803a65 <devpipe_write+0x50>
  803a60:	4a                   	dec    %edx
  803a61:	83 ca e0             	or     $0xffffffe0,%edx
  803a64:	42                   	inc    %edx
  803a65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803a69:	40                   	inc    %eax
  803a6a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803a6d:	47                   	inc    %edi
  803a6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803a71:	75 d1                	jne    803a44 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803a73:	89 f8                	mov    %edi,%eax
  803a75:	eb 05                	jmp    803a7c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803a77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803a7c:	83 c4 1c             	add    $0x1c,%esp
  803a7f:	5b                   	pop    %ebx
  803a80:	5e                   	pop    %esi
  803a81:	5f                   	pop    %edi
  803a82:	5d                   	pop    %ebp
  803a83:	c3                   	ret    

00803a84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803a84:	55                   	push   %ebp
  803a85:	89 e5                	mov    %esp,%ebp
  803a87:	57                   	push   %edi
  803a88:	56                   	push   %esi
  803a89:	53                   	push   %ebx
  803a8a:	83 ec 1c             	sub    $0x1c,%esp
  803a8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803a90:	89 3c 24             	mov    %edi,(%esp)
  803a93:	e8 a8 f3 ff ff       	call   802e40 <fd2data>
  803a98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803a9a:	be 00 00 00 00       	mov    $0x0,%esi
  803a9f:	eb 3a                	jmp    803adb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803aa1:	85 f6                	test   %esi,%esi
  803aa3:	74 04                	je     803aa9 <devpipe_read+0x25>
				return i;
  803aa5:	89 f0                	mov    %esi,%eax
  803aa7:	eb 40                	jmp    803ae9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803aa9:	89 da                	mov    %ebx,%edx
  803aab:	89 f8                	mov    %edi,%eax
  803aad:	e8 f5 fe ff ff       	call   8039a7 <_pipeisclosed>
  803ab2:	85 c0                	test   %eax,%eax
  803ab4:	75 2e                	jne    803ae4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803ab6:	e8 df eb ff ff       	call   80269a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803abb:	8b 03                	mov    (%ebx),%eax
  803abd:	3b 43 04             	cmp    0x4(%ebx),%eax
  803ac0:	74 df                	je     803aa1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803ac2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  803ac7:	79 05                	jns    803ace <devpipe_read+0x4a>
  803ac9:	48                   	dec    %eax
  803aca:	83 c8 e0             	or     $0xffffffe0,%eax
  803acd:	40                   	inc    %eax
  803ace:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  803ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
  803ad5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  803ad8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803ada:	46                   	inc    %esi
  803adb:	3b 75 10             	cmp    0x10(%ebp),%esi
  803ade:	75 db                	jne    803abb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803ae0:	89 f0                	mov    %esi,%eax
  803ae2:	eb 05                	jmp    803ae9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803ae4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803ae9:	83 c4 1c             	add    $0x1c,%esp
  803aec:	5b                   	pop    %ebx
  803aed:	5e                   	pop    %esi
  803aee:	5f                   	pop    %edi
  803aef:	5d                   	pop    %ebp
  803af0:	c3                   	ret    

00803af1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803af1:	55                   	push   %ebp
  803af2:	89 e5                	mov    %esp,%ebp
  803af4:	57                   	push   %edi
  803af5:	56                   	push   %esi
  803af6:	53                   	push   %ebx
  803af7:	83 ec 3c             	sub    $0x3c,%esp
  803afa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803afd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803b00:	89 04 24             	mov    %eax,(%esp)
  803b03:	e8 53 f3 ff ff       	call   802e5b <fd_alloc>
  803b08:	89 c3                	mov    %eax,%ebx
  803b0a:	85 c0                	test   %eax,%eax
  803b0c:	0f 88 45 01 00 00    	js     803c57 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803b12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803b19:	00 
  803b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b28:	e8 8c eb ff ff       	call   8026b9 <sys_page_alloc>
  803b2d:	89 c3                	mov    %eax,%ebx
  803b2f:	85 c0                	test   %eax,%eax
  803b31:	0f 88 20 01 00 00    	js     803c57 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803b37:	8d 45 e0             	lea    -0x20(%ebp),%eax
  803b3a:	89 04 24             	mov    %eax,(%esp)
  803b3d:	e8 19 f3 ff ff       	call   802e5b <fd_alloc>
  803b42:	89 c3                	mov    %eax,%ebx
  803b44:	85 c0                	test   %eax,%eax
  803b46:	0f 88 f8 00 00 00    	js     803c44 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803b4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803b53:	00 
  803b54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b62:	e8 52 eb ff ff       	call   8026b9 <sys_page_alloc>
  803b67:	89 c3                	mov    %eax,%ebx
  803b69:	85 c0                	test   %eax,%eax
  803b6b:	0f 88 d3 00 00 00    	js     803c44 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803b71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b74:	89 04 24             	mov    %eax,(%esp)
  803b77:	e8 c4 f2 ff ff       	call   802e40 <fd2data>
  803b7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803b7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803b85:	00 
  803b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b91:	e8 23 eb ff ff       	call   8026b9 <sys_page_alloc>
  803b96:	89 c3                	mov    %eax,%ebx
  803b98:	85 c0                	test   %eax,%eax
  803b9a:	0f 88 91 00 00 00    	js     803c31 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803ba0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803ba3:	89 04 24             	mov    %eax,(%esp)
  803ba6:	e8 95 f2 ff ff       	call   802e40 <fd2data>
  803bab:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803bb2:	00 
  803bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803bb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803bbe:	00 
  803bbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  803bc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803bca:	e8 3e eb ff ff       	call   80270d <sys_page_map>
  803bcf:	89 c3                	mov    %eax,%ebx
  803bd1:	85 c0                	test   %eax,%eax
  803bd3:	78 4c                	js     803c21 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803bd5:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803bdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803bde:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803be0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803be3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803bea:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803bf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803bf3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803bf5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803bf8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803bff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c02:	89 04 24             	mov    %eax,(%esp)
  803c05:	e8 26 f2 ff ff       	call   802e30 <fd2num>
  803c0a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803c0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803c0f:	89 04 24             	mov    %eax,(%esp)
  803c12:	e8 19 f2 ff ff       	call   802e30 <fd2num>
  803c17:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  803c1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  803c1f:	eb 36                	jmp    803c57 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  803c21:	89 74 24 04          	mov    %esi,0x4(%esp)
  803c25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803c2c:	e8 2f eb ff ff       	call   802760 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803c31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803c3f:	e8 1c eb ff ff       	call   802760 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803c44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803c52:	e8 09 eb ff ff       	call   802760 <sys_page_unmap>
    err:
	return r;
}
  803c57:	89 d8                	mov    %ebx,%eax
  803c59:	83 c4 3c             	add    $0x3c,%esp
  803c5c:	5b                   	pop    %ebx
  803c5d:	5e                   	pop    %esi
  803c5e:	5f                   	pop    %edi
  803c5f:	5d                   	pop    %ebp
  803c60:	c3                   	ret    

00803c61 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803c61:	55                   	push   %ebp
  803c62:	89 e5                	mov    %esp,%ebp
  803c64:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  803c71:	89 04 24             	mov    %eax,(%esp)
  803c74:	e8 35 f2 ff ff       	call   802eae <fd_lookup>
  803c79:	85 c0                	test   %eax,%eax
  803c7b:	78 15                	js     803c92 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c80:	89 04 24             	mov    %eax,(%esp)
  803c83:	e8 b8 f1 ff ff       	call   802e40 <fd2data>
	return _pipeisclosed(fd, p);
  803c88:	89 c2                	mov    %eax,%edx
  803c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803c8d:	e8 15 fd ff ff       	call   8039a7 <_pipeisclosed>
}
  803c92:	c9                   	leave  
  803c93:	c3                   	ret    

00803c94 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803c94:	55                   	push   %ebp
  803c95:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803c97:	b8 00 00 00 00       	mov    $0x0,%eax
  803c9c:	5d                   	pop    %ebp
  803c9d:	c3                   	ret    

00803c9e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803c9e:	55                   	push   %ebp
  803c9f:	89 e5                	mov    %esp,%ebp
  803ca1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  803ca4:	c7 44 24 04 54 4b 80 	movl   $0x804b54,0x4(%esp)
  803cab:	00 
  803cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  803caf:	89 04 24             	mov    %eax,(%esp)
  803cb2:	e8 10 e6 ff ff       	call   8022c7 <strcpy>
	return 0;
}
  803cb7:	b8 00 00 00 00       	mov    $0x0,%eax
  803cbc:	c9                   	leave  
  803cbd:	c3                   	ret    

00803cbe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803cbe:	55                   	push   %ebp
  803cbf:	89 e5                	mov    %esp,%ebp
  803cc1:	57                   	push   %edi
  803cc2:	56                   	push   %esi
  803cc3:	53                   	push   %ebx
  803cc4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803cca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803ccf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803cd5:	eb 30                	jmp    803d07 <devcons_write+0x49>
		m = n - tot;
  803cd7:	8b 75 10             	mov    0x10(%ebp),%esi
  803cda:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803cdc:	83 fe 7f             	cmp    $0x7f,%esi
  803cdf:	76 05                	jbe    803ce6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  803ce1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803ce6:	89 74 24 08          	mov    %esi,0x8(%esp)
  803cea:	03 45 0c             	add    0xc(%ebp),%eax
  803ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  803cf1:	89 3c 24             	mov    %edi,(%esp)
  803cf4:	e8 47 e7 ff ff       	call   802440 <memmove>
		sys_cputs(buf, m);
  803cf9:	89 74 24 04          	mov    %esi,0x4(%esp)
  803cfd:	89 3c 24             	mov    %edi,(%esp)
  803d00:	e8 e7 e8 ff ff       	call   8025ec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803d05:	01 f3                	add    %esi,%ebx
  803d07:	89 d8                	mov    %ebx,%eax
  803d09:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803d0c:	72 c9                	jb     803cd7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803d0e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803d14:	5b                   	pop    %ebx
  803d15:	5e                   	pop    %esi
  803d16:	5f                   	pop    %edi
  803d17:	5d                   	pop    %ebp
  803d18:	c3                   	ret    

00803d19 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803d19:	55                   	push   %ebp
  803d1a:	89 e5                	mov    %esp,%ebp
  803d1c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  803d1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803d23:	75 07                	jne    803d2c <devcons_read+0x13>
  803d25:	eb 25                	jmp    803d4c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803d27:	e8 6e e9 ff ff       	call   80269a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803d2c:	e8 d9 e8 ff ff       	call   80260a <sys_cgetc>
  803d31:	85 c0                	test   %eax,%eax
  803d33:	74 f2                	je     803d27 <devcons_read+0xe>
  803d35:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  803d37:	85 c0                	test   %eax,%eax
  803d39:	78 1d                	js     803d58 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803d3b:	83 f8 04             	cmp    $0x4,%eax
  803d3e:	74 13                	je     803d53 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  803d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d43:	88 10                	mov    %dl,(%eax)
	return 1;
  803d45:	b8 01 00 00 00       	mov    $0x1,%eax
  803d4a:	eb 0c                	jmp    803d58 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  803d4c:	b8 00 00 00 00       	mov    $0x0,%eax
  803d51:	eb 05                	jmp    803d58 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803d53:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803d58:	c9                   	leave  
  803d59:	c3                   	ret    

00803d5a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803d5a:	55                   	push   %ebp
  803d5b:	89 e5                	mov    %esp,%ebp
  803d5d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803d60:	8b 45 08             	mov    0x8(%ebp),%eax
  803d63:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803d66:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803d6d:	00 
  803d6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803d71:	89 04 24             	mov    %eax,(%esp)
  803d74:	e8 73 e8 ff ff       	call   8025ec <sys_cputs>
}
  803d79:	c9                   	leave  
  803d7a:	c3                   	ret    

00803d7b <getchar>:

int
getchar(void)
{
  803d7b:	55                   	push   %ebp
  803d7c:	89 e5                	mov    %esp,%ebp
  803d7e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803d81:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803d88:	00 
  803d89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803d90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d97:	e8 ae f3 ff ff       	call   80314a <read>
	if (r < 0)
  803d9c:	85 c0                	test   %eax,%eax
  803d9e:	78 0f                	js     803daf <getchar+0x34>
		return r;
	if (r < 1)
  803da0:	85 c0                	test   %eax,%eax
  803da2:	7e 06                	jle    803daa <getchar+0x2f>
		return -E_EOF;
	return c;
  803da4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803da8:	eb 05                	jmp    803daf <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803daa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803daf:	c9                   	leave  
  803db0:	c3                   	ret    

00803db1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803db1:	55                   	push   %ebp
  803db2:	89 e5                	mov    %esp,%ebp
  803db4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803db7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803dba:	89 44 24 04          	mov    %eax,0x4(%esp)
  803dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  803dc1:	89 04 24             	mov    %eax,(%esp)
  803dc4:	e8 e5 f0 ff ff       	call   802eae <fd_lookup>
  803dc9:	85 c0                	test   %eax,%eax
  803dcb:	78 11                	js     803dde <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803dd0:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803dd6:	39 10                	cmp    %edx,(%eax)
  803dd8:	0f 94 c0             	sete   %al
  803ddb:	0f b6 c0             	movzbl %al,%eax
}
  803dde:	c9                   	leave  
  803ddf:	c3                   	ret    

00803de0 <opencons>:

int
opencons(void)
{
  803de0:	55                   	push   %ebp
  803de1:	89 e5                	mov    %esp,%ebp
  803de3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803de9:	89 04 24             	mov    %eax,(%esp)
  803dec:	e8 6a f0 ff ff       	call   802e5b <fd_alloc>
  803df1:	85 c0                	test   %eax,%eax
  803df3:	78 3c                	js     803e31 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803df5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803dfc:	00 
  803dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  803e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803e0b:	e8 a9 e8 ff ff       	call   8026b9 <sys_page_alloc>
  803e10:	85 c0                	test   %eax,%eax
  803e12:	78 1d                	js     803e31 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803e14:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e1d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803e22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803e29:	89 04 24             	mov    %eax,(%esp)
  803e2c:	e8 ff ef ff ff       	call   802e30 <fd2num>
}
  803e31:	c9                   	leave  
  803e32:	c3                   	ret    
	...

00803e34 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803e34:	55                   	push   %ebp
  803e35:	57                   	push   %edi
  803e36:	56                   	push   %esi
  803e37:	83 ec 10             	sub    $0x10,%esp
  803e3a:	8b 74 24 20          	mov    0x20(%esp),%esi
  803e3e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803e42:	89 74 24 04          	mov    %esi,0x4(%esp)
  803e46:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  803e4a:	89 cd                	mov    %ecx,%ebp
  803e4c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803e50:	85 c0                	test   %eax,%eax
  803e52:	75 2c                	jne    803e80 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  803e54:	39 f9                	cmp    %edi,%ecx
  803e56:	77 68                	ja     803ec0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803e58:	85 c9                	test   %ecx,%ecx
  803e5a:	75 0b                	jne    803e67 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803e5c:	b8 01 00 00 00       	mov    $0x1,%eax
  803e61:	31 d2                	xor    %edx,%edx
  803e63:	f7 f1                	div    %ecx
  803e65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803e67:	31 d2                	xor    %edx,%edx
  803e69:	89 f8                	mov    %edi,%eax
  803e6b:	f7 f1                	div    %ecx
  803e6d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803e6f:	89 f0                	mov    %esi,%eax
  803e71:	f7 f1                	div    %ecx
  803e73:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803e75:	89 f0                	mov    %esi,%eax
  803e77:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803e79:	83 c4 10             	add    $0x10,%esp
  803e7c:	5e                   	pop    %esi
  803e7d:	5f                   	pop    %edi
  803e7e:	5d                   	pop    %ebp
  803e7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803e80:	39 f8                	cmp    %edi,%eax
  803e82:	77 2c                	ja     803eb0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803e84:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  803e87:	83 f6 1f             	xor    $0x1f,%esi
  803e8a:	75 4c                	jne    803ed8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803e8c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803e8e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803e93:	72 0a                	jb     803e9f <__udivdi3+0x6b>
  803e95:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803e99:	0f 87 ad 00 00 00    	ja     803f4c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803e9f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803ea4:	89 f0                	mov    %esi,%eax
  803ea6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803ea8:	83 c4 10             	add    $0x10,%esp
  803eab:	5e                   	pop    %esi
  803eac:	5f                   	pop    %edi
  803ead:	5d                   	pop    %ebp
  803eae:	c3                   	ret    
  803eaf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803eb0:	31 ff                	xor    %edi,%edi
  803eb2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803eb4:	89 f0                	mov    %esi,%eax
  803eb6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803eb8:	83 c4 10             	add    $0x10,%esp
  803ebb:	5e                   	pop    %esi
  803ebc:	5f                   	pop    %edi
  803ebd:	5d                   	pop    %ebp
  803ebe:	c3                   	ret    
  803ebf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803ec0:	89 fa                	mov    %edi,%edx
  803ec2:	89 f0                	mov    %esi,%eax
  803ec4:	f7 f1                	div    %ecx
  803ec6:	89 c6                	mov    %eax,%esi
  803ec8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803eca:	89 f0                	mov    %esi,%eax
  803ecc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803ece:	83 c4 10             	add    $0x10,%esp
  803ed1:	5e                   	pop    %esi
  803ed2:	5f                   	pop    %edi
  803ed3:	5d                   	pop    %ebp
  803ed4:	c3                   	ret    
  803ed5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803ed8:	89 f1                	mov    %esi,%ecx
  803eda:	d3 e0                	shl    %cl,%eax
  803edc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803ee0:	b8 20 00 00 00       	mov    $0x20,%eax
  803ee5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  803ee7:	89 ea                	mov    %ebp,%edx
  803ee9:	88 c1                	mov    %al,%cl
  803eeb:	d3 ea                	shr    %cl,%edx
  803eed:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803ef1:	09 ca                	or     %ecx,%edx
  803ef3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  803ef7:	89 f1                	mov    %esi,%ecx
  803ef9:	d3 e5                	shl    %cl,%ebp
  803efb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  803eff:	89 fd                	mov    %edi,%ebp
  803f01:	88 c1                	mov    %al,%cl
  803f03:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  803f05:	89 fa                	mov    %edi,%edx
  803f07:	89 f1                	mov    %esi,%ecx
  803f09:	d3 e2                	shl    %cl,%edx
  803f0b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803f0f:	88 c1                	mov    %al,%cl
  803f11:	d3 ef                	shr    %cl,%edi
  803f13:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803f15:	89 f8                	mov    %edi,%eax
  803f17:	89 ea                	mov    %ebp,%edx
  803f19:	f7 74 24 08          	divl   0x8(%esp)
  803f1d:	89 d1                	mov    %edx,%ecx
  803f1f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  803f21:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803f25:	39 d1                	cmp    %edx,%ecx
  803f27:	72 17                	jb     803f40 <__udivdi3+0x10c>
  803f29:	74 09                	je     803f34 <__udivdi3+0x100>
  803f2b:	89 fe                	mov    %edi,%esi
  803f2d:	31 ff                	xor    %edi,%edi
  803f2f:	e9 41 ff ff ff       	jmp    803e75 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803f34:	8b 54 24 04          	mov    0x4(%esp),%edx
  803f38:	89 f1                	mov    %esi,%ecx
  803f3a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803f3c:	39 c2                	cmp    %eax,%edx
  803f3e:	73 eb                	jae    803f2b <__udivdi3+0xf7>
		{
		  q0--;
  803f40:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803f43:	31 ff                	xor    %edi,%edi
  803f45:	e9 2b ff ff ff       	jmp    803e75 <__udivdi3+0x41>
  803f4a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803f4c:	31 f6                	xor    %esi,%esi
  803f4e:	e9 22 ff ff ff       	jmp    803e75 <__udivdi3+0x41>
	...

00803f54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  803f54:	55                   	push   %ebp
  803f55:	57                   	push   %edi
  803f56:	56                   	push   %esi
  803f57:	83 ec 20             	sub    $0x20,%esp
  803f5a:	8b 44 24 30          	mov    0x30(%esp),%eax
  803f5e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803f62:	89 44 24 14          	mov    %eax,0x14(%esp)
  803f66:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  803f6a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803f6e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  803f72:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  803f74:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803f76:	85 ed                	test   %ebp,%ebp
  803f78:	75 16                	jne    803f90 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  803f7a:	39 f1                	cmp    %esi,%ecx
  803f7c:	0f 86 a6 00 00 00    	jbe    804028 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803f82:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803f84:	89 d0                	mov    %edx,%eax
  803f86:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803f88:	83 c4 20             	add    $0x20,%esp
  803f8b:	5e                   	pop    %esi
  803f8c:	5f                   	pop    %edi
  803f8d:	5d                   	pop    %ebp
  803f8e:	c3                   	ret    
  803f8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803f90:	39 f5                	cmp    %esi,%ebp
  803f92:	0f 87 ac 00 00 00    	ja     804044 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803f98:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  803f9b:	83 f0 1f             	xor    $0x1f,%eax
  803f9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  803fa2:	0f 84 a8 00 00 00    	je     804050 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803fa8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803fac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803fae:	bf 20 00 00 00       	mov    $0x20,%edi
  803fb3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803fb7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803fbb:	89 f9                	mov    %edi,%ecx
  803fbd:	d3 e8                	shr    %cl,%eax
  803fbf:	09 e8                	or     %ebp,%eax
  803fc1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803fc5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803fc9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803fcd:	d3 e0                	shl    %cl,%eax
  803fcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803fd3:	89 f2                	mov    %esi,%edx
  803fd5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803fd7:	8b 44 24 14          	mov    0x14(%esp),%eax
  803fdb:	d3 e0                	shl    %cl,%eax
  803fdd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803fe1:	8b 44 24 14          	mov    0x14(%esp),%eax
  803fe5:	89 f9                	mov    %edi,%ecx
  803fe7:	d3 e8                	shr    %cl,%eax
  803fe9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  803feb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803fed:	89 f2                	mov    %esi,%edx
  803fef:	f7 74 24 18          	divl   0x18(%esp)
  803ff3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803ff5:	f7 64 24 0c          	mull   0xc(%esp)
  803ff9:	89 c5                	mov    %eax,%ebp
  803ffb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803ffd:	39 d6                	cmp    %edx,%esi
  803fff:	72 67                	jb     804068 <__umoddi3+0x114>
  804001:	74 75                	je     804078 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  804003:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  804007:	29 e8                	sub    %ebp,%eax
  804009:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80400b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80400f:	d3 e8                	shr    %cl,%eax
  804011:	89 f2                	mov    %esi,%edx
  804013:	89 f9                	mov    %edi,%ecx
  804015:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  804017:	09 d0                	or     %edx,%eax
  804019:	89 f2                	mov    %esi,%edx
  80401b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80401f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  804021:	83 c4 20             	add    $0x20,%esp
  804024:	5e                   	pop    %esi
  804025:	5f                   	pop    %edi
  804026:	5d                   	pop    %ebp
  804027:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  804028:	85 c9                	test   %ecx,%ecx
  80402a:	75 0b                	jne    804037 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80402c:	b8 01 00 00 00       	mov    $0x1,%eax
  804031:	31 d2                	xor    %edx,%edx
  804033:	f7 f1                	div    %ecx
  804035:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  804037:	89 f0                	mov    %esi,%eax
  804039:	31 d2                	xor    %edx,%edx
  80403b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80403d:	89 f8                	mov    %edi,%eax
  80403f:	e9 3e ff ff ff       	jmp    803f82 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  804044:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  804046:	83 c4 20             	add    $0x20,%esp
  804049:	5e                   	pop    %esi
  80404a:	5f                   	pop    %edi
  80404b:	5d                   	pop    %ebp
  80404c:	c3                   	ret    
  80404d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  804050:	39 f5                	cmp    %esi,%ebp
  804052:	72 04                	jb     804058 <__umoddi3+0x104>
  804054:	39 f9                	cmp    %edi,%ecx
  804056:	77 06                	ja     80405e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  804058:	89 f2                	mov    %esi,%edx
  80405a:	29 cf                	sub    %ecx,%edi
  80405c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80405e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  804060:	83 c4 20             	add    $0x20,%esp
  804063:	5e                   	pop    %esi
  804064:	5f                   	pop    %edi
  804065:	5d                   	pop    %ebp
  804066:	c3                   	ret    
  804067:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  804068:	89 d1                	mov    %edx,%ecx
  80406a:	89 c5                	mov    %eax,%ebp
  80406c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  804070:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  804074:	eb 8d                	jmp    804003 <__umoddi3+0xaf>
  804076:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  804078:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80407c:	72 ea                	jb     804068 <__umoddi3+0x114>
  80407e:	89 f1                	mov    %esi,%ecx
  804080:	eb 81                	jmp    804003 <__umoddi3+0xaf>
