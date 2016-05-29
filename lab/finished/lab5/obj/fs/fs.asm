
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
  80002c:	e8 9b 1b 00 00       	call   801bcc <libmain>
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
  8000b0:	c7 04 24 40 3b 80 00 	movl   $0x803b40,(%esp)
  8000b7:	e8 70 1c 00 00       	call   801d2c <cprintf>
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
  8000d9:	c7 44 24 08 57 3b 80 	movl   $0x803b57,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 67 3b 80 00 	movl   $0x803b67,(%esp)
  8000f0:	e8 3f 1b 00 00       	call   801c34 <_panic>
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
  800116:	c7 44 24 0c 70 3b 80 	movl   $0x803b70,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 67 3b 80 00 	movl   $0x803b67,(%esp)
  800135:	e8 fa 1a 00 00       	call   801c34 <_panic>

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
  8001d0:	c7 44 24 0c 70 3b 80 	movl   $0x803b70,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 67 3b 80 00 	movl   $0x803b67,(%esp)
  8001ef:	e8 40 1a 00 00       	call   801c34 <_panic>

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
  80029d:	c7 44 24 08 94 3b 80 	movl   $0x803b94,0x8(%esp)
  8002a4:	00 
  8002a5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ac:	00 
  8002ad:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8002b4:	e8 7b 19 00 00       	call   801c34 <_panic>
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
  8002c2:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	74 25                	je     8002f0 <bc_pgfault+0x80>
  8002cb:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ce:	72 20                	jb     8002f0 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	c7 44 24 08 c4 3b 80 	movl   $0x803bc4,0x8(%esp)
  8002db:	00 
  8002dc:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e3:	00 
  8002e4:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8002eb:	e8 44 19 00 00       	call   801c34 <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	
	addr = ROUNDDOWN(addr, PGSIZE);
  8002f0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (sys_page_alloc(sys_getenvid(), addr, PTE_SYSCALL) < 0)
  8002f6:	e8 90 23 00 00       	call   80268b <sys_getenvid>
  8002fb:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  800302:	00 
  800303:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	e8 ba 23 00 00       	call   8026c9 <sys_page_alloc>
  80030f:	85 c0                	test   %eax,%eax
  800311:	79 1c                	jns    80032f <bc_pgfault+0xbf>
		panic("bc_pgfault: sys_page_alloc failed");
  800313:	c7 44 24 08 e8 3b 80 	movl   $0x803be8,0x8(%esp)
  80031a:	00 
  80031b:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  800322:	00 
  800323:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  80032a:	e8 05 19 00 00       	call   801c34 <_panic>
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
  800352:	c7 44 24 08 a0 3c 80 	movl   $0x803ca0,0x8(%esp)
  800359:	00 
  80035a:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800361:	00 
  800362:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  800369:	e8 c6 18 00 00       	call   801c34 <_panic>

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
  80039a:	e8 7e 23 00 00       	call   80271d <sys_page_map>
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	79 20                	jns    8003c3 <bc_pgfault+0x153>
		panic("in bc_pgfault, sys_page_map: %e", r);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	c7 44 24 08 0c 3c 80 	movl   $0x803c0c,0x8(%esp)
  8003ae:	00 
  8003af:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  8003b6:	00 
  8003b7:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8003be:	e8 71 18 00 00       	call   801c34 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003c3:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003ca:	74 2c                	je     8003f8 <bc_pgfault+0x188>
  8003cc:	89 34 24             	mov    %esi,(%esp)
  8003cf:	e8 03 04 00 00       	call   8007d7 <block_is_free>
  8003d4:	84 c0                	test   %al,%al
  8003d6:	74 20                	je     8003f8 <bc_pgfault+0x188>
		panic("reading free block %08x\n", blockno);
  8003d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003dc:	c7 44 24 08 ba 3c 80 	movl   $0x803cba,0x8(%esp)
  8003e3:	00 
  8003e4:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8003eb:	00 
  8003ec:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8003f3:	e8 3c 18 00 00       	call   801c34 <_panic>
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
  80040c:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	74 25                	je     80043b <diskaddr+0x3c>
  800416:	3b 42 04             	cmp    0x4(%edx),%eax
  800419:	72 20                	jb     80043b <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80041b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80041f:	c7 44 24 08 2c 3c 80 	movl   $0x803c2c,0x8(%esp)
  800426:	00 
  800427:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80042e:	00 
  80042f:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  800436:	e8 f9 17 00 00       	call   801c34 <_panic>
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
  8004a5:	c7 44 24 08 d3 3c 80 	movl   $0x803cd3,0x8(%esp)
  8004ac:	00 
  8004ad:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004b4:	00 
  8004b5:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8004bc:	e8 73 17 00 00       	call   801c34 <_panic>

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
  800511:	c7 44 24 08 ee 3c 80 	movl   $0x803cee,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  800528:	e8 07 17 00 00       	call   801c34 <_panic>
	if (sys_page_map(0, addr, 0, addr, PTE_SYSCALL) < 0)
  80052d:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800534:	00 
  800535:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800539:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80054c:	e8 cc 21 00 00       	call   80271d <sys_page_map>
  800551:	85 c0                	test   %eax,%eax
  800553:	79 1c                	jns    800571 <flush_block+0xe8>
		panic("flush_block: sys_page_map failed");
  800555:	c7 44 24 08 50 3c 80 	movl   $0x803c50,0x8(%esp)
  80055c:	00 
  80055d:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  800564:	00 
  800565:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  80056c:	e8 c3 16 00 00       	call   801c34 <_panic>
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
  800588:	e8 a7 23 00 00       	call   802934 <set_pgfault_handler>
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
  8005ae:	e8 9d 1e 00 00       	call   802450 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8005b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ba:	e8 40 fe ff ff       	call   8003ff <diskaddr>
  8005bf:	c7 44 24 04 09 3d 80 	movl   $0x803d09,0x4(%esp)
  8005c6:	00 
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	e8 08 1d 00 00       	call   8022d7 <strcpy>
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
  8005fb:	c7 44 24 0c 2b 3d 80 	movl   $0x803d2b,0xc(%esp)
  800602:	00 
  800603:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  80060a:	00 
  80060b:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  800612:	00 
  800613:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  80061a:	e8 15 16 00 00       	call   801c34 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  80061f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800626:	e8 d4 fd ff ff       	call   8003ff <diskaddr>
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 3f fe ff ff       	call   800472 <va_is_dirty>
  800633:	84 c0                	test   %al,%al
  800635:	74 24                	je     80065b <bc_init+0xe3>
  800637:	c7 44 24 0c 10 3d 80 	movl   $0x803d10,0xc(%esp)
  80063e:	00 
  80063f:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  800646:	00 
  800647:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  80064e:	00 
  80064f:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  800656:	e8 d9 15 00 00       	call   801c34 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80065b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800662:	e8 98 fd ff ff       	call   8003ff <diskaddr>
  800667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800672:	e8 f9 20 00 00       	call   802770 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80067e:	e8 7c fd ff ff       	call   8003ff <diskaddr>
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	e8 ba fd ff ff       	call   800445 <va_is_mapped>
  80068b:	84 c0                	test   %al,%al
  80068d:	74 24                	je     8006b3 <bc_init+0x13b>
  80068f:	c7 44 24 0c 2a 3d 80 	movl   $0x803d2a,0xc(%esp)
  800696:	00 
  800697:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  80069e:	00 
  80069f:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006a6:	00 
  8006a7:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8006ae:	e8 81 15 00 00       	call   801c34 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ba:	e8 40 fd ff ff       	call   8003ff <diskaddr>
  8006bf:	c7 44 24 04 09 3d 80 	movl   $0x803d09,0x4(%esp)
  8006c6:	00 
  8006c7:	89 04 24             	mov    %eax,(%esp)
  8006ca:	e8 af 1c 00 00       	call   80237e <strcmp>
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 24                	je     8006f7 <bc_init+0x17f>
  8006d3:	c7 44 24 0c 74 3c 80 	movl   $0x803c74,0xc(%esp)
  8006da:	00 
  8006db:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  8006e2:	00 
  8006e3:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  8006ea:	00 
  8006eb:	c7 04 24 98 3c 80 00 	movl   $0x803c98,(%esp)
  8006f2:	e8 3d 15 00 00       	call   801c34 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8006f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006fe:	e8 fc fc ff ff       	call   8003ff <diskaddr>
  800703:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80070a:	00 
  80070b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800711:	89 54 24 04          	mov    %edx,0x4(%esp)
  800715:	89 04 24             	mov    %eax,(%esp)
  800718:	e8 33 1d 00 00       	call   802450 <memmove>
	flush_block(diskaddr(1));
  80071d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800724:	e8 d6 fc ff ff       	call   8003ff <diskaddr>
  800729:	89 04 24             	mov    %eax,(%esp)
  80072c:	e8 58 fd ff ff       	call   800489 <flush_block>

	cprintf("block cache is good\n");
  800731:	c7 04 24 45 3d 80 00 	movl   $0x803d45,(%esp)
  800738:	e8 ef 15 00 00       	call   801d2c <cprintf>
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
  80075e:	e8 ed 1c 00 00       	call   802450 <memmove>
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
  80077b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800780:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800786:	74 1c                	je     8007a4 <check_super+0x2f>
	  panic("bad file system magic number");
  800788:	c7 44 24 08 5a 3d 80 	movl   $0x803d5a,0x8(%esp)
  80078f:	00 
  800790:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800797:	00 
  800798:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  80079f:	e8 90 14 00 00       	call   801c34 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007a4:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007ab:	76 1c                	jbe    8007c9 <check_super+0x54>
	  panic("file system is too large");
  8007ad:	c7 44 24 08 7f 3d 80 	movl   $0x803d7f,0x8(%esp)
  8007b4:	00 
  8007b5:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8007bc:	00 
  8007bd:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  8007c4:	e8 6b 14 00 00       	call   801c34 <_panic>

	cprintf("superblock is good\n");
  8007c9:	c7 04 24 98 3d 80 00 	movl   $0x803d98,(%esp)
  8007d0:	e8 57 15 00 00       	call   801d2c <cprintf>
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
  8007dd:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  8007f5:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
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
  800818:	c7 44 24 08 ac 3d 80 	movl   $0x803dac,0x8(%esp)
  80081f:	00 
  800820:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800827:	00 
  800828:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  80082f:	e8 00 14 00 00       	call   801c34 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800834:	89 c8                	mov    %ecx,%eax
  800836:	c1 e8 05             	shr    $0x5,%eax
  800839:	c1 e0 02             	shl    $0x2,%eax
  80083c:	03 05 04 a0 80 00    	add    0x80a004,%eax
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
  800870:	03 05 04 a0 80 00    	add    0x80a004,%eax
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
  800898:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  800925:	e8 dc 1a 00 00       	call   802406 <memset>
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
  800979:	c7 44 24 0c c7 3d 80 	movl   $0x803dc7,0xc(%esp)
  800980:	00 
  800981:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  800988:	00 
  800989:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800990:	00 
  800991:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  800998:	e8 97 12 00 00       	call   801c34 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80099d:	43                   	inc    %ebx
  80099e:	89 da                	mov    %ebx,%edx
  8009a0:	c1 e2 0f             	shl    $0xf,%edx
  8009a3:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8009ab:	72 bd                	jb     80096a <check_bitmap+0xe>
	  assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009b4:	e8 1e fe ff ff       	call   8007d7 <block_is_free>
  8009b9:	84 c0                	test   %al,%al
  8009bb:	74 24                	je     8009e1 <check_bitmap+0x85>
  8009bd:	c7 44 24 0c db 3d 80 	movl   $0x803ddb,0xc(%esp)
  8009c4:	00 
  8009c5:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  8009cc:	00 
  8009cd:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
  8009d4:	00 
  8009d5:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  8009dc:	e8 53 12 00 00       	call   801c34 <_panic>
	assert(!block_is_free(1));
  8009e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009e8:	e8 ea fd ff ff       	call   8007d7 <block_is_free>
  8009ed:	84 c0                	test   %al,%al
  8009ef:	74 24                	je     800a15 <check_bitmap+0xb9>
  8009f1:	c7 44 24 0c ed 3d 80 	movl   $0x803ded,0xc(%esp)
  8009f8:	00 
  8009f9:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  800a00:	00 
  800a01:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800a08:	00 
  800a09:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  800a10:	e8 1f 12 00 00       	call   801c34 <_panic>

	cprintf("bitmap is good\n");
  800a15:	c7 04 24 ff 3d 80 00 	movl   $0x803dff,(%esp)
  800a1c:	e8 0b 13 00 00       	call   801d2c <cprintf>
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
  800a61:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800a66:	e8 0a fd ff ff       	call   800775 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a6b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a72:	e8 88 f9 ff ff       	call   8003ff <diskaddr>
  800a77:	a3 04 a0 80 00       	mov    %eax,0x80a004
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
  800aa9:	c7 04 24 4c 3e 80 00 	movl   $0x803e4c,(%esp)
  800ab0:	e8 77 12 00 00       	call   801d2c <cprintf>
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
  800b08:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  800b83:	e8 c8 18 00 00       	call   802450 <memmove>
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
  800bbd:	c7 44 24 0c 0f 3e 80 	movl   $0x803e0f,0xc(%esp)
  800bc4:	00 
  800bc5:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  800bcc:	00 
  800bcd:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  800bd4:	00 
  800bd5:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  800bdc:	e8 53 10 00 00       	call   801c34 <_panic>
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
  800c43:	e8 36 17 00 00       	call   80237e <strcmp>
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
  800cb9:	e8 19 16 00 00       	call   8022d7 <strcpy>
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
  800de7:	e8 64 16 00 00       	call   802450 <memmove>
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
  800e8d:	c7 04 24 2c 3e 80 00 	movl   $0x803e2c,(%esp)
  800e94:	e8 93 0e 00 00       	call   801d2c <cprintf>
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
  800f71:	e8 da 14 00 00       	call   802450 <memmove>
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
  80106f:	c7 44 24 0c 0f 3e 80 	movl   $0x803e0f,0xc(%esp)
  801076:	00 
  801077:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  80107e:	00 
  80107f:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  801086:	00 
  801087:	c7 04 24 77 3d 80 00 	movl   $0x803d77,(%esp)
  80108e:	e8 a1 0b 00 00       	call   801c34 <_panic>
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
  80114a:	e8 88 11 00 00       	call   8022d7 <strcpy>
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
  80118e:	a1 08 a0 80 00       	mov    0x80a008,%eax
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
  8011fa:	e8 89 1b 00 00       	call   802d88 <pageref>
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
  801228:	e8 9c 14 00 00       	call   8026c9 <sys_page_alloc>
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
  80125f:	e8 a2 11 00 00       	call   802406 <memset>
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
  8012a9:	e8 da 1a 00 00       	call   802d88 <pageref>
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
  801348:	e8 8a 0f 00 00       	call   8022d7 <strcpy>
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
  80149e:	e8 ad 0f 00 00       	call   802450 <memmove>
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
  8015db:	e8 ec 13 00 00       	call   8029cc <ipc_recv>
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
  8015ed:	c7 04 24 78 3e 80 00 	movl   $0x803e78,(%esp)
  8015f4:	e8 33 07 00 00       	call   801d2c <cprintf>
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
  801656:	c7 04 24 a8 3e 80 00 	movl   $0x803ea8,(%esp)
  80165d:	e8 ca 06 00 00       	call   801d2c <cprintf>
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
  80167f:	e8 b1 13 00 00       	call   802a35 <ipc_send>
		sys_page_unmap(0, fsreq);
  801684:	a1 44 50 80 00       	mov    0x805044,%eax
  801689:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801694:	e8 d7 10 00 00       	call   802770 <sys_page_unmap>
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
  8016a4:	c7 05 60 90 80 00 cb 	movl   $0x803ecb,0x809060
  8016ab:	3e 80 00 
	cprintf("FS is running\n");
  8016ae:	c7 04 24 ce 3e 80 00 	movl   $0x803ece,(%esp)
  8016b5:	e8 72 06 00 00       	call   801d2c <cprintf>
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
  8016c6:	c7 04 24 dd 3e 80 00 	movl   $0x803edd,(%esp)
  8016cd:	e8 5a 06 00 00       	call   801d2c <cprintf>

	serve_init();
  8016d2:	e8 db fa ff ff       	call   8011b2 <serve_init>
	fs_init();
  8016d7:	e8 4b f3 ff ff       	call   800a27 <fs_init>
    fs_test();
  8016dc:	e8 07 00 00 00       	call   8016e8 <fs_test>
	serve();
  8016e1:	e8 d0 fe ff ff       	call   8015b6 <serve>
	...

008016e8 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  8016ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8016f6:	00 
  8016f7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  8016fe:	00 
  8016ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801706:	e8 be 0f 00 00       	call   8026c9 <sys_page_alloc>
  80170b:	85 c0                	test   %eax,%eax
  80170d:	79 20                	jns    80172f <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80170f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801713:	c7 44 24 08 ec 3e 80 	movl   $0x803eec,0x8(%esp)
  80171a:	00 
  80171b:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  801722:	00 
  801723:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  80172a:	e8 05 05 00 00       	call   801c34 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80172f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801736:	00 
  801737:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80173c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801740:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801747:	e8 04 0d 00 00       	call   802450 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80174c:	e8 fc f0 ff ff       	call   80084d <alloc_block>
  801751:	85 c0                	test   %eax,%eax
  801753:	79 20                	jns    801775 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801755:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801759:	c7 44 24 08 09 3f 80 	movl   $0x803f09,0x8(%esp)
  801760:	00 
  801761:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  801768:	00 
  801769:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801770:	e8 bf 04 00 00       	call   801c34 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801775:	89 c2                	mov    %eax,%edx
  801777:	85 c0                	test   %eax,%eax
  801779:	79 03                	jns    80177e <fs_test+0x96>
  80177b:	8d 50 1f             	lea    0x1f(%eax),%edx
  80177e:	c1 fa 05             	sar    $0x5,%edx
  801781:	c1 e2 02             	shl    $0x2,%edx
  801784:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801789:	79 05                	jns    801790 <fs_test+0xa8>
  80178b:	48                   	dec    %eax
  80178c:	83 c8 e0             	or     $0xffffffe0,%eax
  80178f:	40                   	inc    %eax
  801790:	bb 01 00 00 00       	mov    $0x1,%ebx
  801795:	88 c1                	mov    %al,%cl
  801797:	d3 e3                	shl    %cl,%ebx
  801799:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  80179f:	75 24                	jne    8017c5 <fs_test+0xdd>
  8017a1:	c7 44 24 0c 19 3f 80 	movl   $0x803f19,0xc(%esp)
  8017a8:	00 
  8017a9:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  8017b0:	00 
  8017b1:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  8017b8:	00 
  8017b9:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  8017c0:	e8 6f 04 00 00       	call   801c34 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8017c5:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8017cb:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  8017ce:	74 24                	je     8017f4 <fs_test+0x10c>
  8017d0:	c7 44 24 0c 94 40 80 	movl   $0x804094,0xc(%esp)
  8017d7:	00 
  8017d8:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  8017df:	00 
  8017e0:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8017e7:	00 
  8017e8:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  8017ef:	e8 40 04 00 00       	call   801c34 <_panic>
	cprintf("alloc_block is good\n");
  8017f4:	c7 04 24 34 3f 80 00 	movl   $0x803f34,(%esp)
  8017fb:	e8 2c 05 00 00       	call   801d2c <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801800:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801803:	89 44 24 04          	mov    %eax,0x4(%esp)
  801807:	c7 04 24 49 3f 80 00 	movl   $0x803f49,(%esp)
  80180e:	e8 1d f5 ff ff       	call   800d30 <file_open>
  801813:	85 c0                	test   %eax,%eax
  801815:	79 25                	jns    80183c <fs_test+0x154>
  801817:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80181a:	74 40                	je     80185c <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  80181c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801820:	c7 44 24 08 54 3f 80 	movl   $0x803f54,0x8(%esp)
  801827:	00 
  801828:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80182f:	00 
  801830:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801837:	e8 f8 03 00 00       	call   801c34 <_panic>
	else if (r == 0)
  80183c:	85 c0                	test   %eax,%eax
  80183e:	75 1c                	jne    80185c <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  801840:	c7 44 24 08 b4 40 80 	movl   $0x8040b4,0x8(%esp)
  801847:	00 
  801848:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80184f:	00 
  801850:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801857:	e8 d8 03 00 00       	call   801c34 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80185c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801863:	c7 04 24 6d 3f 80 00 	movl   $0x803f6d,(%esp)
  80186a:	e8 c1 f4 ff ff       	call   800d30 <file_open>
  80186f:	85 c0                	test   %eax,%eax
  801871:	79 20                	jns    801893 <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  801873:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801877:	c7 44 24 08 76 3f 80 	movl   $0x803f76,0x8(%esp)
  80187e:	00 
  80187f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801886:	00 
  801887:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  80188e:	e8 a1 03 00 00       	call   801c34 <_panic>
	cprintf("file_open is good\n");
  801893:	c7 04 24 8d 3f 80 00 	movl   $0x803f8d,(%esp)
  80189a:	e8 8d 04 00 00       	call   801d2c <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80189f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ad:	00 
  8018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 ca f1 ff ff       	call   800a83 <file_get_block>
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	79 20                	jns    8018dd <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  8018bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c1:	c7 44 24 08 a0 3f 80 	movl   $0x803fa0,0x8(%esp)
  8018c8:	00 
  8018c9:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8018d0:	00 
  8018d1:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  8018d8:	e8 57 03 00 00       	call   801c34 <_panic>
	if (strcmp(blk, msg) != 0)
  8018dd:	c7 44 24 04 d4 40 80 	movl   $0x8040d4,0x4(%esp)
  8018e4:	00 
  8018e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e8:	89 04 24             	mov    %eax,(%esp)
  8018eb:	e8 8e 0a 00 00       	call   80237e <strcmp>
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	74 1c                	je     801910 <fs_test+0x228>
		panic("file_get_block returned wrong data");
  8018f4:	c7 44 24 08 fc 40 80 	movl   $0x8040fc,0x8(%esp)
  8018fb:	00 
  8018fc:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801903:	00 
  801904:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  80190b:	e8 24 03 00 00       	call   801c34 <_panic>
	cprintf("file_get_block is good\n");
  801910:	c7 04 24 b3 3f 80 00 	movl   $0x803fb3,(%esp)
  801917:	e8 10 04 00 00       	call   801d2c <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80191c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191f:	8a 10                	mov    (%eax),%dl
  801921:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	c1 e8 0c             	shr    $0xc,%eax
  801929:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801930:	a8 40                	test   $0x40,%al
  801932:	75 24                	jne    801958 <fs_test+0x270>
  801934:	c7 44 24 0c cc 3f 80 	movl   $0x803fcc,0xc(%esp)
  80193b:	00 
  80193c:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801943:	00 
  801944:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80194b:	00 
  80194c:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801953:	e8 dc 02 00 00       	call   801c34 <_panic>
	file_flush(f);
  801958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195b:	89 04 24             	mov    %eax,(%esp)
  80195e:	e8 29 f6 ff ff       	call   800f8c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801963:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801966:	c1 e8 0c             	shr    $0xc,%eax
  801969:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801970:	a8 40                	test   $0x40,%al
  801972:	74 24                	je     801998 <fs_test+0x2b0>
  801974:	c7 44 24 0c cb 3f 80 	movl   $0x803fcb,0xc(%esp)
  80197b:	00 
  80197c:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801983:	00 
  801984:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80198b:	00 
  80198c:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801993:	e8 9c 02 00 00       	call   801c34 <_panic>
	cprintf("file_flush is good\n");
  801998:	c7 04 24 e7 3f 80 00 	movl   $0x803fe7,(%esp)
  80199f:	e8 88 03 00 00       	call   801d2c <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8019a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ab:	00 
  8019ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019af:	89 04 24             	mov    %eax,(%esp)
  8019b2:	e8 52 f4 ff ff       	call   800e09 <file_set_size>
  8019b7:	85 c0                	test   %eax,%eax
  8019b9:	79 20                	jns    8019db <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  8019bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bf:	c7 44 24 08 fb 3f 80 	movl   $0x803ffb,0x8(%esp)
  8019c6:	00 
  8019c7:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  8019ce:	00 
  8019cf:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  8019d6:	e8 59 02 00 00       	call   801c34 <_panic>
	assert(f->f_direct[0] == 0);
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8019e5:	74 24                	je     801a0b <fs_test+0x323>
  8019e7:	c7 44 24 0c 0d 40 80 	movl   $0x80400d,0xc(%esp)
  8019ee:	00 
  8019ef:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  8019f6:	00 
  8019f7:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8019fe:	00 
  8019ff:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801a06:	e8 29 02 00 00       	call   801c34 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a0b:	c1 e8 0c             	shr    $0xc,%eax
  801a0e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a15:	a8 40                	test   $0x40,%al
  801a17:	74 24                	je     801a3d <fs_test+0x355>
  801a19:	c7 44 24 0c 21 40 80 	movl   $0x804021,0xc(%esp)
  801a20:	00 
  801a21:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801a28:	00 
  801a29:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801a30:	00 
  801a31:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801a38:	e8 f7 01 00 00       	call   801c34 <_panic>
	cprintf("file_truncate is good\n");
  801a3d:	c7 04 24 3b 40 80 00 	movl   $0x80403b,(%esp)
  801a44:	e8 e3 02 00 00       	call   801d2c <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801a49:	c7 04 24 d4 40 80 00 	movl   $0x8040d4,(%esp)
  801a50:	e8 4f 08 00 00       	call   8022a4 <strlen>
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 a5 f3 ff ff       	call   800e09 <file_set_size>
  801a64:	85 c0                	test   %eax,%eax
  801a66:	79 20                	jns    801a88 <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  801a68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a6c:	c7 44 24 08 52 40 80 	movl   $0x804052,0x8(%esp)
  801a73:	00 
  801a74:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801a7b:	00 
  801a7c:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801a83:	e8 ac 01 00 00       	call   801c34 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	c1 ea 0c             	shr    $0xc,%edx
  801a90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a97:	f6 c2 40             	test   $0x40,%dl
  801a9a:	74 24                	je     801ac0 <fs_test+0x3d8>
  801a9c:	c7 44 24 0c 21 40 80 	movl   $0x804021,0xc(%esp)
  801aa3:	00 
  801aa4:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801aab:	00 
  801aac:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801ab3:	00 
  801ab4:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801abb:	e8 74 01 00 00       	call   801c34 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801ac0:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801ac3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ac7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ace:	00 
  801acf:	89 04 24             	mov    %eax,(%esp)
  801ad2:	e8 ac ef ff ff       	call   800a83 <file_get_block>
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	79 20                	jns    801afb <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801adb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801adf:	c7 44 24 08 66 40 80 	movl   $0x804066,0x8(%esp)
  801ae6:	00 
  801ae7:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801aee:	00 
  801aef:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801af6:	e8 39 01 00 00       	call   801c34 <_panic>
	strcpy(blk, msg);
  801afb:	c7 44 24 04 d4 40 80 	movl   $0x8040d4,0x4(%esp)
  801b02:	00 
  801b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b06:	89 04 24             	mov    %eax,(%esp)
  801b09:	e8 c9 07 00 00       	call   8022d7 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b11:	c1 e8 0c             	shr    $0xc,%eax
  801b14:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b1b:	a8 40                	test   $0x40,%al
  801b1d:	75 24                	jne    801b43 <fs_test+0x45b>
  801b1f:	c7 44 24 0c cc 3f 80 	movl   $0x803fcc,0xc(%esp)
  801b26:	00 
  801b27:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801b2e:	00 
  801b2f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801b36:	00 
  801b37:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801b3e:	e8 f1 00 00 00       	call   801c34 <_panic>
	file_flush(f);
  801b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b46:	89 04 24             	mov    %eax,(%esp)
  801b49:	e8 3e f4 ff ff       	call   800f8c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b51:	c1 e8 0c             	shr    $0xc,%eax
  801b54:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b5b:	a8 40                	test   $0x40,%al
  801b5d:	74 24                	je     801b83 <fs_test+0x49b>
  801b5f:	c7 44 24 0c cb 3f 80 	movl   $0x803fcb,0xc(%esp)
  801b66:	00 
  801b67:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801b6e:	00 
  801b6f:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801b76:	00 
  801b77:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801b7e:	e8 b1 00 00 00       	call   801c34 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b86:	c1 e8 0c             	shr    $0xc,%eax
  801b89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b90:	a8 40                	test   $0x40,%al
  801b92:	74 24                	je     801bb8 <fs_test+0x4d0>
  801b94:	c7 44 24 0c 21 40 80 	movl   $0x804021,0xc(%esp)
  801b9b:	00 
  801b9c:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  801ba3:	00 
  801ba4:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801bab:	00 
  801bac:	c7 04 24 ff 3e 80 00 	movl   $0x803eff,(%esp)
  801bb3:	e8 7c 00 00 00       	call   801c34 <_panic>
	cprintf("file rewrite is good\n");
  801bb8:	c7 04 24 7b 40 80 00 	movl   $0x80407b,(%esp)
  801bbf:	e8 68 01 00 00       	call   801d2c <cprintf>
}
  801bc4:	83 c4 24             	add    $0x24,%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    
	...

00801bcc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 10             	sub    $0x10,%esp
  801bd4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801bda:	e8 ac 0a 00 00       	call   80268b <sys_getenvid>
  801bdf:	25 ff 03 00 00       	and    $0x3ff,%eax
  801be4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801beb:	c1 e0 07             	shl    $0x7,%eax
  801bee:	29 d0                	sub    %edx,%eax
  801bf0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf5:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801bfa:	85 f6                	test   %esi,%esi
  801bfc:	7e 07                	jle    801c05 <libmain+0x39>
		binaryname = argv[0];
  801bfe:	8b 03                	mov    (%ebx),%eax
  801c00:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c09:	89 34 24             	mov    %esi,(%esp)
  801c0c:	e8 8d fa ff ff       	call   80169e <umain>

	// exit gracefully
	exit();
  801c11:	e8 0a 00 00 00       	call   801c20 <exit>
}
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	5b                   	pop    %ebx
  801c1a:	5e                   	pop    %esi
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    
  801c1d:	00 00                	add    %al,(%eax)
	...

00801c20 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  801c26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c2d:	e8 07 0a 00 00       	call   802639 <sys_env_destroy>
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801c3c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801c3f:	8b 1d 60 90 80 00    	mov    0x809060,%ebx
  801c45:	e8 41 0a 00 00       	call   80268b <sys_getenvid>
  801c4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c51:	8b 55 08             	mov    0x8(%ebp),%edx
  801c54:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c58:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c60:	c7 04 24 2c 41 80 00 	movl   $0x80412c,(%esp)
  801c67:	e8 c0 00 00 00       	call   801d2c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801c6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c70:	8b 45 10             	mov    0x10(%ebp),%eax
  801c73:	89 04 24             	mov    %eax,(%esp)
  801c76:	e8 50 00 00 00       	call   801ccb <vcprintf>
	cprintf("\n");
  801c7b:	c7 04 24 0e 3d 80 00 	movl   $0x803d0e,(%esp)
  801c82:	e8 a5 00 00 00       	call   801d2c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801c87:	cc                   	int3   
  801c88:	eb fd                	jmp    801c87 <_panic+0x53>
	...

00801c8c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	53                   	push   %ebx
  801c90:	83 ec 14             	sub    $0x14,%esp
  801c93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801c96:	8b 03                	mov    (%ebx),%eax
  801c98:	8b 55 08             	mov    0x8(%ebp),%edx
  801c9b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801c9f:	40                   	inc    %eax
  801ca0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801ca2:	3d ff 00 00 00       	cmp    $0xff,%eax
  801ca7:	75 19                	jne    801cc2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801ca9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801cb0:	00 
  801cb1:	8d 43 08             	lea    0x8(%ebx),%eax
  801cb4:	89 04 24             	mov    %eax,(%esp)
  801cb7:	e8 40 09 00 00       	call   8025fc <sys_cputs>
		b->idx = 0;
  801cbc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801cc2:	ff 43 04             	incl   0x4(%ebx)
}
  801cc5:	83 c4 14             	add    $0x14,%esp
  801cc8:	5b                   	pop    %ebx
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801cd4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801cdb:	00 00 00 
	b.cnt = 0;
  801cde:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801ce5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ceb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d00:	c7 04 24 8c 1c 80 00 	movl   $0x801c8c,(%esp)
  801d07:	e8 82 01 00 00       	call   801e8e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d0c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d16:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d1c:	89 04 24             	mov    %eax,(%esp)
  801d1f:	e8 d8 08 00 00       	call   8025fc <sys_cputs>

	return b.cnt;
}
  801d24:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d32:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 87 ff ff ff       	call   801ccb <vcprintf>
	va_end(ap);

	return cnt;
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    
	...

00801d48 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	57                   	push   %edi
  801d4c:	56                   	push   %esi
  801d4d:	53                   	push   %ebx
  801d4e:	83 ec 3c             	sub    $0x3c,%esp
  801d51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d54:	89 d7                	mov    %edx,%edi
  801d56:	8b 45 08             	mov    0x8(%ebp),%eax
  801d59:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d62:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801d65:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	75 08                	jne    801d74 <printnum+0x2c>
  801d6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d6f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801d72:	77 57                	ja     801dcb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801d74:	89 74 24 10          	mov    %esi,0x10(%esp)
  801d78:	4b                   	dec    %ebx
  801d79:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d84:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801d88:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801d8c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d93:	00 
  801d94:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801d97:	89 04 24             	mov    %eax,(%esp)
  801d9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da1:	e8 2e 1b 00 00       	call   8038d4 <__udivdi3>
  801da6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801daa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801dae:	89 04 24             	mov    %eax,(%esp)
  801db1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db5:	89 fa                	mov    %edi,%edx
  801db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dba:	e8 89 ff ff ff       	call   801d48 <printnum>
  801dbf:	eb 0f                	jmp    801dd0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801dc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dc5:	89 34 24             	mov    %esi,(%esp)
  801dc8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801dcb:	4b                   	dec    %ebx
  801dcc:	85 db                	test   %ebx,%ebx
  801dce:	7f f1                	jg     801dc1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801dd0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dd4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dd8:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ddf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801de6:	00 
  801de7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801dea:	89 04 24             	mov    %eax,(%esp)
  801ded:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801df0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df4:	e8 fb 1b 00 00       	call   8039f4 <__umoddi3>
  801df9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfd:	0f be 80 4f 41 80 00 	movsbl 0x80414f(%eax),%eax
  801e04:	89 04 24             	mov    %eax,(%esp)
  801e07:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801e0a:	83 c4 3c             	add    $0x3c,%esp
  801e0d:	5b                   	pop    %ebx
  801e0e:	5e                   	pop    %esi
  801e0f:	5f                   	pop    %edi
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801e15:	83 fa 01             	cmp    $0x1,%edx
  801e18:	7e 0e                	jle    801e28 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801e1a:	8b 10                	mov    (%eax),%edx
  801e1c:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e1f:	89 08                	mov    %ecx,(%eax)
  801e21:	8b 02                	mov    (%edx),%eax
  801e23:	8b 52 04             	mov    0x4(%edx),%edx
  801e26:	eb 22                	jmp    801e4a <getuint+0x38>
	else if (lflag)
  801e28:	85 d2                	test   %edx,%edx
  801e2a:	74 10                	je     801e3c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801e2c:	8b 10                	mov    (%eax),%edx
  801e2e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e31:	89 08                	mov    %ecx,(%eax)
  801e33:	8b 02                	mov    (%edx),%eax
  801e35:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3a:	eb 0e                	jmp    801e4a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801e3c:	8b 10                	mov    (%eax),%edx
  801e3e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e41:	89 08                	mov    %ecx,(%eax)
  801e43:	8b 02                	mov    (%edx),%eax
  801e45:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801e52:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801e55:	8b 10                	mov    (%eax),%edx
  801e57:	3b 50 04             	cmp    0x4(%eax),%edx
  801e5a:	73 08                	jae    801e64 <sprintputch+0x18>
		*b->buf++ = ch;
  801e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e5f:	88 0a                	mov    %cl,(%edx)
  801e61:	42                   	inc    %edx
  801e62:	89 10                	mov    %edx,(%eax)
}
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801e6c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801e6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e73:	8b 45 10             	mov    0x10(%ebp),%eax
  801e76:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e81:	8b 45 08             	mov    0x8(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 02 00 00 00       	call   801e8e <vprintfmt>
	va_end(ap);
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	57                   	push   %edi
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	83 ec 4c             	sub    $0x4c,%esp
  801e97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e9a:	8b 75 10             	mov    0x10(%ebp),%esi
  801e9d:	eb 12                	jmp    801eb1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	0f 84 6b 03 00 00    	je     802212 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801ea7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eab:	89 04 24             	mov    %eax,(%esp)
  801eae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801eb1:	0f b6 06             	movzbl (%esi),%eax
  801eb4:	46                   	inc    %esi
  801eb5:	83 f8 25             	cmp    $0x25,%eax
  801eb8:	75 e5                	jne    801e9f <vprintfmt+0x11>
  801eba:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801ebe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801ec5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801eca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801ed1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ed6:	eb 26                	jmp    801efe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ed8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801edb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801edf:	eb 1d                	jmp    801efe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ee1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801ee4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801ee8:	eb 14                	jmp    801efe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801eed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801ef4:	eb 08                	jmp    801efe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801ef6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801ef9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801efe:	0f b6 06             	movzbl (%esi),%eax
  801f01:	8d 56 01             	lea    0x1(%esi),%edx
  801f04:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801f07:	8a 16                	mov    (%esi),%dl
  801f09:	83 ea 23             	sub    $0x23,%edx
  801f0c:	80 fa 55             	cmp    $0x55,%dl
  801f0f:	0f 87 e1 02 00 00    	ja     8021f6 <vprintfmt+0x368>
  801f15:	0f b6 d2             	movzbl %dl,%edx
  801f18:	ff 24 95 a0 42 80 00 	jmp    *0x8042a0(,%edx,4)
  801f1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801f22:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801f27:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801f2a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801f2e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801f31:	8d 50 d0             	lea    -0x30(%eax),%edx
  801f34:	83 fa 09             	cmp    $0x9,%edx
  801f37:	77 2a                	ja     801f63 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801f39:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801f3a:	eb eb                	jmp    801f27 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801f3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3f:	8d 50 04             	lea    0x4(%eax),%edx
  801f42:	89 55 14             	mov    %edx,0x14(%ebp)
  801f45:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f47:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801f4a:	eb 17                	jmp    801f63 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801f4c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801f50:	78 98                	js     801eea <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f52:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801f55:	eb a7                	jmp    801efe <vprintfmt+0x70>
  801f57:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801f5a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801f61:	eb 9b                	jmp    801efe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801f63:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801f67:	79 95                	jns    801efe <vprintfmt+0x70>
  801f69:	eb 8b                	jmp    801ef6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801f6b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801f6f:	eb 8d                	jmp    801efe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801f71:	8b 45 14             	mov    0x14(%ebp),%eax
  801f74:	8d 50 04             	lea    0x4(%eax),%edx
  801f77:	89 55 14             	mov    %edx,0x14(%ebp)
  801f7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f7e:	8b 00                	mov    (%eax),%eax
  801f80:	89 04 24             	mov    %eax,(%esp)
  801f83:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f86:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801f89:	e9 23 ff ff ff       	jmp    801eb1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801f8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801f91:	8d 50 04             	lea    0x4(%eax),%edx
  801f94:	89 55 14             	mov    %edx,0x14(%ebp)
  801f97:	8b 00                	mov    (%eax),%eax
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	79 02                	jns    801f9f <vprintfmt+0x111>
  801f9d:	f7 d8                	neg    %eax
  801f9f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801fa1:	83 f8 0f             	cmp    $0xf,%eax
  801fa4:	7f 0b                	jg     801fb1 <vprintfmt+0x123>
  801fa6:	8b 04 85 00 44 80 00 	mov    0x804400(,%eax,4),%eax
  801fad:	85 c0                	test   %eax,%eax
  801faf:	75 23                	jne    801fd4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801fb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fb5:	c7 44 24 08 67 41 80 	movl   $0x804167,0x8(%esp)
  801fbc:	00 
  801fbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc4:	89 04 24             	mov    %eax,(%esp)
  801fc7:	e8 9a fe ff ff       	call   801e66 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fcc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801fcf:	e9 dd fe ff ff       	jmp    801eb1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801fd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fd8:	c7 44 24 08 8f 3b 80 	movl   $0x803b8f,0x8(%esp)
  801fdf:	00 
  801fe0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  801fe7:	89 14 24             	mov    %edx,(%esp)
  801fea:	e8 77 fe ff ff       	call   801e66 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ff2:	e9 ba fe ff ff       	jmp    801eb1 <vprintfmt+0x23>
  801ff7:	89 f9                	mov    %edi,%ecx
  801ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ffc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801fff:	8b 45 14             	mov    0x14(%ebp),%eax
  802002:	8d 50 04             	lea    0x4(%eax),%edx
  802005:	89 55 14             	mov    %edx,0x14(%ebp)
  802008:	8b 30                	mov    (%eax),%esi
  80200a:	85 f6                	test   %esi,%esi
  80200c:	75 05                	jne    802013 <vprintfmt+0x185>
				p = "(null)";
  80200e:	be 60 41 80 00       	mov    $0x804160,%esi
			if (width > 0 && padc != '-')
  802013:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  802017:	0f 8e 84 00 00 00    	jle    8020a1 <vprintfmt+0x213>
  80201d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  802021:	74 7e                	je     8020a1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  802023:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802027:	89 34 24             	mov    %esi,(%esp)
  80202a:	e8 8b 02 00 00       	call   8022ba <strnlen>
  80202f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  802032:	29 c2                	sub    %eax,%edx
  802034:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  802037:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80203b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80203e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  802041:	89 de                	mov    %ebx,%esi
  802043:	89 d3                	mov    %edx,%ebx
  802045:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802047:	eb 0b                	jmp    802054 <vprintfmt+0x1c6>
					putch(padc, putdat);
  802049:	89 74 24 04          	mov    %esi,0x4(%esp)
  80204d:	89 3c 24             	mov    %edi,(%esp)
  802050:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  802053:	4b                   	dec    %ebx
  802054:	85 db                	test   %ebx,%ebx
  802056:	7f f1                	jg     802049 <vprintfmt+0x1bb>
  802058:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80205b:	89 f3                	mov    %esi,%ebx
  80205d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  802060:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802063:	85 c0                	test   %eax,%eax
  802065:	79 05                	jns    80206c <vprintfmt+0x1de>
  802067:	b8 00 00 00 00       	mov    $0x0,%eax
  80206c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80206f:	29 c2                	sub    %eax,%edx
  802071:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802074:	eb 2b                	jmp    8020a1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802076:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80207a:	74 18                	je     802094 <vprintfmt+0x206>
  80207c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80207f:	83 fa 5e             	cmp    $0x5e,%edx
  802082:	76 10                	jbe    802094 <vprintfmt+0x206>
					putch('?', putdat);
  802084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802088:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80208f:	ff 55 08             	call   *0x8(%ebp)
  802092:	eb 0a                	jmp    80209e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  802094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802098:	89 04 24             	mov    %eax,(%esp)
  80209b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80209e:	ff 4d e4             	decl   -0x1c(%ebp)
  8020a1:	0f be 06             	movsbl (%esi),%eax
  8020a4:	46                   	inc    %esi
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	74 21                	je     8020ca <vprintfmt+0x23c>
  8020a9:	85 ff                	test   %edi,%edi
  8020ab:	78 c9                	js     802076 <vprintfmt+0x1e8>
  8020ad:	4f                   	dec    %edi
  8020ae:	79 c6                	jns    802076 <vprintfmt+0x1e8>
  8020b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b3:	89 de                	mov    %ebx,%esi
  8020b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8020b8:	eb 18                	jmp    8020d2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8020ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8020c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8020c7:	4b                   	dec    %ebx
  8020c8:	eb 08                	jmp    8020d2 <vprintfmt+0x244>
  8020ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020cd:	89 de                	mov    %ebx,%esi
  8020cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8020d2:	85 db                	test   %ebx,%ebx
  8020d4:	7f e4                	jg     8020ba <vprintfmt+0x22c>
  8020d6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8020d9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8020de:	e9 ce fd ff ff       	jmp    801eb1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8020e3:	83 f9 01             	cmp    $0x1,%ecx
  8020e6:	7e 10                	jle    8020f8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8020e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020eb:	8d 50 08             	lea    0x8(%eax),%edx
  8020ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8020f1:	8b 30                	mov    (%eax),%esi
  8020f3:	8b 78 04             	mov    0x4(%eax),%edi
  8020f6:	eb 26                	jmp    80211e <vprintfmt+0x290>
	else if (lflag)
  8020f8:	85 c9                	test   %ecx,%ecx
  8020fa:	74 12                	je     80210e <vprintfmt+0x280>
		return va_arg(*ap, long);
  8020fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ff:	8d 50 04             	lea    0x4(%eax),%edx
  802102:	89 55 14             	mov    %edx,0x14(%ebp)
  802105:	8b 30                	mov    (%eax),%esi
  802107:	89 f7                	mov    %esi,%edi
  802109:	c1 ff 1f             	sar    $0x1f,%edi
  80210c:	eb 10                	jmp    80211e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80210e:	8b 45 14             	mov    0x14(%ebp),%eax
  802111:	8d 50 04             	lea    0x4(%eax),%edx
  802114:	89 55 14             	mov    %edx,0x14(%ebp)
  802117:	8b 30                	mov    (%eax),%esi
  802119:	89 f7                	mov    %esi,%edi
  80211b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80211e:	85 ff                	test   %edi,%edi
  802120:	78 0a                	js     80212c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  802122:	b8 0a 00 00 00       	mov    $0xa,%eax
  802127:	e9 8c 00 00 00       	jmp    8021b8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80212c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802130:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  802137:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80213a:	f7 de                	neg    %esi
  80213c:	83 d7 00             	adc    $0x0,%edi
  80213f:	f7 df                	neg    %edi
			}
			base = 10;
  802141:	b8 0a 00 00 00       	mov    $0xa,%eax
  802146:	eb 70                	jmp    8021b8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802148:	89 ca                	mov    %ecx,%edx
  80214a:	8d 45 14             	lea    0x14(%ebp),%eax
  80214d:	e8 c0 fc ff ff       	call   801e12 <getuint>
  802152:	89 c6                	mov    %eax,%esi
  802154:	89 d7                	mov    %edx,%edi
			base = 10;
  802156:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80215b:	eb 5b                	jmp    8021b8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80215d:	89 ca                	mov    %ecx,%edx
  80215f:	8d 45 14             	lea    0x14(%ebp),%eax
  802162:	e8 ab fc ff ff       	call   801e12 <getuint>
  802167:	89 c6                	mov    %eax,%esi
  802169:	89 d7                	mov    %edx,%edi
			base = 8;
  80216b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  802170:	eb 46                	jmp    8021b8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  802172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802176:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80217d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802184:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80218b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80218e:	8b 45 14             	mov    0x14(%ebp),%eax
  802191:	8d 50 04             	lea    0x4(%eax),%edx
  802194:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802197:	8b 30                	mov    (%eax),%esi
  802199:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80219e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8021a3:	eb 13                	jmp    8021b8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8021a5:	89 ca                	mov    %ecx,%edx
  8021a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8021aa:	e8 63 fc ff ff       	call   801e12 <getuint>
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	89 d7                	mov    %edx,%edi
			base = 16;
  8021b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8021b8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8021bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8021c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8021c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021cb:	89 34 24             	mov    %esi,(%esp)
  8021ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021d2:	89 da                	mov    %ebx,%edx
  8021d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d7:	e8 6c fb ff ff       	call   801d48 <printnum>
			break;
  8021dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8021df:	e9 cd fc ff ff       	jmp    801eb1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8021e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021e8:	89 04 24             	mov    %eax,(%esp)
  8021eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8021ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8021f1:	e9 bb fc ff ff       	jmp    801eb1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8021f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802201:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  802204:	eb 01                	jmp    802207 <vprintfmt+0x379>
  802206:	4e                   	dec    %esi
  802207:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80220b:	75 f9                	jne    802206 <vprintfmt+0x378>
  80220d:	e9 9f fc ff ff       	jmp    801eb1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  802212:	83 c4 4c             	add    $0x4c,%esp
  802215:	5b                   	pop    %ebx
  802216:	5e                   	pop    %esi
  802217:	5f                   	pop    %edi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    

0080221a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	83 ec 28             	sub    $0x28,%esp
  802220:	8b 45 08             	mov    0x8(%ebp),%eax
  802223:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802226:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802229:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80222d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802230:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802237:	85 c0                	test   %eax,%eax
  802239:	74 30                	je     80226b <vsnprintf+0x51>
  80223b:	85 d2                	test   %edx,%edx
  80223d:	7e 33                	jle    802272 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80223f:	8b 45 14             	mov    0x14(%ebp),%eax
  802242:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802246:	8b 45 10             	mov    0x10(%ebp),%eax
  802249:	89 44 24 08          	mov    %eax,0x8(%esp)
  80224d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802250:	89 44 24 04          	mov    %eax,0x4(%esp)
  802254:	c7 04 24 4c 1e 80 00 	movl   $0x801e4c,(%esp)
  80225b:	e8 2e fc ff ff       	call   801e8e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802260:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802263:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802269:	eb 0c                	jmp    802277 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80226b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802270:	eb 05                	jmp    802277 <vsnprintf+0x5d>
  802272:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80227f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802282:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802286:	8b 45 10             	mov    0x10(%ebp),%eax
  802289:	89 44 24 08          	mov    %eax,0x8(%esp)
  80228d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802290:	89 44 24 04          	mov    %eax,0x4(%esp)
  802294:	8b 45 08             	mov    0x8(%ebp),%eax
  802297:	89 04 24             	mov    %eax,(%esp)
  80229a:	e8 7b ff ff ff       	call   80221a <vsnprintf>
	va_end(ap);

	return rc;
}
  80229f:	c9                   	leave  
  8022a0:	c3                   	ret    
  8022a1:	00 00                	add    %al,(%eax)
	...

008022a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8022aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8022af:	eb 01                	jmp    8022b2 <strlen+0xe>
		n++;
  8022b1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8022b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8022b6:	75 f9                	jne    8022b1 <strlen+0xd>
		n++;
	return n;
}
  8022b8:	5d                   	pop    %ebp
  8022b9:	c3                   	ret    

008022ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8022ba:	55                   	push   %ebp
  8022bb:	89 e5                	mov    %esp,%ebp
  8022bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8022c0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c8:	eb 01                	jmp    8022cb <strnlen+0x11>
		n++;
  8022ca:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022cb:	39 d0                	cmp    %edx,%eax
  8022cd:	74 06                	je     8022d5 <strnlen+0x1b>
  8022cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8022d3:	75 f5                	jne    8022ca <strnlen+0x10>
		n++;
	return n;
}
  8022d5:	5d                   	pop    %ebp
  8022d6:	c3                   	ret    

008022d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	53                   	push   %ebx
  8022db:	8b 45 08             	mov    0x8(%ebp),%eax
  8022de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8022e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8022e9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8022ec:	42                   	inc    %edx
  8022ed:	84 c9                	test   %cl,%cl
  8022ef:	75 f5                	jne    8022e6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8022f1:	5b                   	pop    %ebx
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    

008022f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8022f4:	55                   	push   %ebp
  8022f5:	89 e5                	mov    %esp,%ebp
  8022f7:	53                   	push   %ebx
  8022f8:	83 ec 08             	sub    $0x8,%esp
  8022fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8022fe:	89 1c 24             	mov    %ebx,(%esp)
  802301:	e8 9e ff ff ff       	call   8022a4 <strlen>
	strcpy(dst + len, src);
  802306:	8b 55 0c             	mov    0xc(%ebp),%edx
  802309:	89 54 24 04          	mov    %edx,0x4(%esp)
  80230d:	01 d8                	add    %ebx,%eax
  80230f:	89 04 24             	mov    %eax,(%esp)
  802312:	e8 c0 ff ff ff       	call   8022d7 <strcpy>
	return dst;
}
  802317:	89 d8                	mov    %ebx,%eax
  802319:	83 c4 08             	add    $0x8,%esp
  80231c:	5b                   	pop    %ebx
  80231d:	5d                   	pop    %ebp
  80231e:	c3                   	ret    

0080231f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80231f:	55                   	push   %ebp
  802320:	89 e5                	mov    %esp,%ebp
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	8b 45 08             	mov    0x8(%ebp),%eax
  802327:	8b 55 0c             	mov    0xc(%ebp),%edx
  80232a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80232d:	b9 00 00 00 00       	mov    $0x0,%ecx
  802332:	eb 0c                	jmp    802340 <strncpy+0x21>
		*dst++ = *src;
  802334:	8a 1a                	mov    (%edx),%bl
  802336:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802339:	80 3a 01             	cmpb   $0x1,(%edx)
  80233c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80233f:	41                   	inc    %ecx
  802340:	39 f1                	cmp    %esi,%ecx
  802342:	75 f0                	jne    802334 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    

00802348 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	56                   	push   %esi
  80234c:	53                   	push   %ebx
  80234d:	8b 75 08             	mov    0x8(%ebp),%esi
  802350:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802353:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802356:	85 d2                	test   %edx,%edx
  802358:	75 0a                	jne    802364 <strlcpy+0x1c>
  80235a:	89 f0                	mov    %esi,%eax
  80235c:	eb 1a                	jmp    802378 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80235e:	88 18                	mov    %bl,(%eax)
  802360:	40                   	inc    %eax
  802361:	41                   	inc    %ecx
  802362:	eb 02                	jmp    802366 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802364:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  802366:	4a                   	dec    %edx
  802367:	74 0a                	je     802373 <strlcpy+0x2b>
  802369:	8a 19                	mov    (%ecx),%bl
  80236b:	84 db                	test   %bl,%bl
  80236d:	75 ef                	jne    80235e <strlcpy+0x16>
  80236f:	89 c2                	mov    %eax,%edx
  802371:	eb 02                	jmp    802375 <strlcpy+0x2d>
  802373:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  802375:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  802378:	29 f0                	sub    %esi,%eax
}
  80237a:	5b                   	pop    %ebx
  80237b:	5e                   	pop    %esi
  80237c:	5d                   	pop    %ebp
  80237d:	c3                   	ret    

0080237e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802384:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802387:	eb 02                	jmp    80238b <strcmp+0xd>
		p++, q++;
  802389:	41                   	inc    %ecx
  80238a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80238b:	8a 01                	mov    (%ecx),%al
  80238d:	84 c0                	test   %al,%al
  80238f:	74 04                	je     802395 <strcmp+0x17>
  802391:	3a 02                	cmp    (%edx),%al
  802393:	74 f4                	je     802389 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802395:	0f b6 c0             	movzbl %al,%eax
  802398:	0f b6 12             	movzbl (%edx),%edx
  80239b:	29 d0                	sub    %edx,%eax
}
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    

0080239f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	53                   	push   %ebx
  8023a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023a9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8023ac:	eb 03                	jmp    8023b1 <strncmp+0x12>
		n--, p++, q++;
  8023ae:	4a                   	dec    %edx
  8023af:	40                   	inc    %eax
  8023b0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8023b1:	85 d2                	test   %edx,%edx
  8023b3:	74 14                	je     8023c9 <strncmp+0x2a>
  8023b5:	8a 18                	mov    (%eax),%bl
  8023b7:	84 db                	test   %bl,%bl
  8023b9:	74 04                	je     8023bf <strncmp+0x20>
  8023bb:	3a 19                	cmp    (%ecx),%bl
  8023bd:	74 ef                	je     8023ae <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8023bf:	0f b6 00             	movzbl (%eax),%eax
  8023c2:	0f b6 11             	movzbl (%ecx),%edx
  8023c5:	29 d0                	sub    %edx,%eax
  8023c7:	eb 05                	jmp    8023ce <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8023ce:	5b                   	pop    %ebx
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    

008023d1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8023da:	eb 05                	jmp    8023e1 <strchr+0x10>
		if (*s == c)
  8023dc:	38 ca                	cmp    %cl,%dl
  8023de:	74 0c                	je     8023ec <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8023e0:	40                   	inc    %eax
  8023e1:	8a 10                	mov    (%eax),%dl
  8023e3:	84 d2                	test   %dl,%dl
  8023e5:	75 f5                	jne    8023dc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8023e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023ec:	5d                   	pop    %ebp
  8023ed:	c3                   	ret    

008023ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8023ee:	55                   	push   %ebp
  8023ef:	89 e5                	mov    %esp,%ebp
  8023f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8023f7:	eb 05                	jmp    8023fe <strfind+0x10>
		if (*s == c)
  8023f9:	38 ca                	cmp    %cl,%dl
  8023fb:	74 07                	je     802404 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8023fd:	40                   	inc    %eax
  8023fe:	8a 10                	mov    (%eax),%dl
  802400:	84 d2                	test   %dl,%dl
  802402:	75 f5                	jne    8023f9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    

00802406 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	57                   	push   %edi
  80240a:	56                   	push   %esi
  80240b:	53                   	push   %ebx
  80240c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80240f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802412:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802415:	85 c9                	test   %ecx,%ecx
  802417:	74 30                	je     802449 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802419:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80241f:	75 25                	jne    802446 <memset+0x40>
  802421:	f6 c1 03             	test   $0x3,%cl
  802424:	75 20                	jne    802446 <memset+0x40>
		c &= 0xFF;
  802426:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802429:	89 d3                	mov    %edx,%ebx
  80242b:	c1 e3 08             	shl    $0x8,%ebx
  80242e:	89 d6                	mov    %edx,%esi
  802430:	c1 e6 18             	shl    $0x18,%esi
  802433:	89 d0                	mov    %edx,%eax
  802435:	c1 e0 10             	shl    $0x10,%eax
  802438:	09 f0                	or     %esi,%eax
  80243a:	09 d0                	or     %edx,%eax
  80243c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80243e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802441:	fc                   	cld    
  802442:	f3 ab                	rep stos %eax,%es:(%edi)
  802444:	eb 03                	jmp    802449 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802446:	fc                   	cld    
  802447:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802449:	89 f8                	mov    %edi,%eax
  80244b:	5b                   	pop    %ebx
  80244c:	5e                   	pop    %esi
  80244d:	5f                   	pop    %edi
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

00802450 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	57                   	push   %edi
  802454:	56                   	push   %esi
  802455:	8b 45 08             	mov    0x8(%ebp),%eax
  802458:	8b 75 0c             	mov    0xc(%ebp),%esi
  80245b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80245e:	39 c6                	cmp    %eax,%esi
  802460:	73 34                	jae    802496 <memmove+0x46>
  802462:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802465:	39 d0                	cmp    %edx,%eax
  802467:	73 2d                	jae    802496 <memmove+0x46>
		s += n;
		d += n;
  802469:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80246c:	f6 c2 03             	test   $0x3,%dl
  80246f:	75 1b                	jne    80248c <memmove+0x3c>
  802471:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802477:	75 13                	jne    80248c <memmove+0x3c>
  802479:	f6 c1 03             	test   $0x3,%cl
  80247c:	75 0e                	jne    80248c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80247e:	83 ef 04             	sub    $0x4,%edi
  802481:	8d 72 fc             	lea    -0x4(%edx),%esi
  802484:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  802487:	fd                   	std    
  802488:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80248a:	eb 07                	jmp    802493 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80248c:	4f                   	dec    %edi
  80248d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802490:	fd                   	std    
  802491:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802493:	fc                   	cld    
  802494:	eb 20                	jmp    8024b6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802496:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80249c:	75 13                	jne    8024b1 <memmove+0x61>
  80249e:	a8 03                	test   $0x3,%al
  8024a0:	75 0f                	jne    8024b1 <memmove+0x61>
  8024a2:	f6 c1 03             	test   $0x3,%cl
  8024a5:	75 0a                	jne    8024b1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8024a7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8024aa:	89 c7                	mov    %eax,%edi
  8024ac:	fc                   	cld    
  8024ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024af:	eb 05                	jmp    8024b6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8024b1:	89 c7                	mov    %eax,%edi
  8024b3:	fc                   	cld    
  8024b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8024b6:	5e                   	pop    %esi
  8024b7:	5f                   	pop    %edi
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    

008024ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8024c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d1:	89 04 24             	mov    %eax,(%esp)
  8024d4:	e8 77 ff ff ff       	call   802450 <memmove>
}
  8024d9:	c9                   	leave  
  8024da:	c3                   	ret    

008024db <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8024db:	55                   	push   %ebp
  8024dc:	89 e5                	mov    %esp,%ebp
  8024de:	57                   	push   %edi
  8024df:	56                   	push   %esi
  8024e0:	53                   	push   %ebx
  8024e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8024ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ef:	eb 16                	jmp    802507 <memcmp+0x2c>
		if (*s1 != *s2)
  8024f1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8024f4:	42                   	inc    %edx
  8024f5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8024f9:	38 c8                	cmp    %cl,%al
  8024fb:	74 0a                	je     802507 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8024fd:	0f b6 c0             	movzbl %al,%eax
  802500:	0f b6 c9             	movzbl %cl,%ecx
  802503:	29 c8                	sub    %ecx,%eax
  802505:	eb 09                	jmp    802510 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802507:	39 da                	cmp    %ebx,%edx
  802509:	75 e6                	jne    8024f1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80250b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80251e:	89 c2                	mov    %eax,%edx
  802520:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802523:	eb 05                	jmp    80252a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  802525:	38 08                	cmp    %cl,(%eax)
  802527:	74 05                	je     80252e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802529:	40                   	inc    %eax
  80252a:	39 d0                	cmp    %edx,%eax
  80252c:	72 f7                	jb     802525 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80252e:	5d                   	pop    %ebp
  80252f:	c3                   	ret    

00802530 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802530:	55                   	push   %ebp
  802531:	89 e5                	mov    %esp,%ebp
  802533:	57                   	push   %edi
  802534:	56                   	push   %esi
  802535:	53                   	push   %ebx
  802536:	8b 55 08             	mov    0x8(%ebp),%edx
  802539:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80253c:	eb 01                	jmp    80253f <strtol+0xf>
		s++;
  80253e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80253f:	8a 02                	mov    (%edx),%al
  802541:	3c 20                	cmp    $0x20,%al
  802543:	74 f9                	je     80253e <strtol+0xe>
  802545:	3c 09                	cmp    $0x9,%al
  802547:	74 f5                	je     80253e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802549:	3c 2b                	cmp    $0x2b,%al
  80254b:	75 08                	jne    802555 <strtol+0x25>
		s++;
  80254d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80254e:	bf 00 00 00 00       	mov    $0x0,%edi
  802553:	eb 13                	jmp    802568 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802555:	3c 2d                	cmp    $0x2d,%al
  802557:	75 0a                	jne    802563 <strtol+0x33>
		s++, neg = 1;
  802559:	8d 52 01             	lea    0x1(%edx),%edx
  80255c:	bf 01 00 00 00       	mov    $0x1,%edi
  802561:	eb 05                	jmp    802568 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802563:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802568:	85 db                	test   %ebx,%ebx
  80256a:	74 05                	je     802571 <strtol+0x41>
  80256c:	83 fb 10             	cmp    $0x10,%ebx
  80256f:	75 28                	jne    802599 <strtol+0x69>
  802571:	8a 02                	mov    (%edx),%al
  802573:	3c 30                	cmp    $0x30,%al
  802575:	75 10                	jne    802587 <strtol+0x57>
  802577:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80257b:	75 0a                	jne    802587 <strtol+0x57>
		s += 2, base = 16;
  80257d:	83 c2 02             	add    $0x2,%edx
  802580:	bb 10 00 00 00       	mov    $0x10,%ebx
  802585:	eb 12                	jmp    802599 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802587:	85 db                	test   %ebx,%ebx
  802589:	75 0e                	jne    802599 <strtol+0x69>
  80258b:	3c 30                	cmp    $0x30,%al
  80258d:	75 05                	jne    802594 <strtol+0x64>
		s++, base = 8;
  80258f:	42                   	inc    %edx
  802590:	b3 08                	mov    $0x8,%bl
  802592:	eb 05                	jmp    802599 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802594:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802599:	b8 00 00 00 00       	mov    $0x0,%eax
  80259e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8025a0:	8a 0a                	mov    (%edx),%cl
  8025a2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8025a5:	80 fb 09             	cmp    $0x9,%bl
  8025a8:	77 08                	ja     8025b2 <strtol+0x82>
			dig = *s - '0';
  8025aa:	0f be c9             	movsbl %cl,%ecx
  8025ad:	83 e9 30             	sub    $0x30,%ecx
  8025b0:	eb 1e                	jmp    8025d0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8025b2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8025b5:	80 fb 19             	cmp    $0x19,%bl
  8025b8:	77 08                	ja     8025c2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8025ba:	0f be c9             	movsbl %cl,%ecx
  8025bd:	83 e9 57             	sub    $0x57,%ecx
  8025c0:	eb 0e                	jmp    8025d0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8025c2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8025c5:	80 fb 19             	cmp    $0x19,%bl
  8025c8:	77 12                	ja     8025dc <strtol+0xac>
			dig = *s - 'A' + 10;
  8025ca:	0f be c9             	movsbl %cl,%ecx
  8025cd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8025d0:	39 f1                	cmp    %esi,%ecx
  8025d2:	7d 0c                	jge    8025e0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8025d4:	42                   	inc    %edx
  8025d5:	0f af c6             	imul   %esi,%eax
  8025d8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8025da:	eb c4                	jmp    8025a0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8025dc:	89 c1                	mov    %eax,%ecx
  8025de:	eb 02                	jmp    8025e2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8025e0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8025e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8025e6:	74 05                	je     8025ed <strtol+0xbd>
		*endptr = (char *) s;
  8025e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8025eb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8025ed:	85 ff                	test   %edi,%edi
  8025ef:	74 04                	je     8025f5 <strtol+0xc5>
  8025f1:	89 c8                	mov    %ecx,%eax
  8025f3:	f7 d8                	neg    %eax
}
  8025f5:	5b                   	pop    %ebx
  8025f6:	5e                   	pop    %esi
  8025f7:	5f                   	pop    %edi
  8025f8:	5d                   	pop    %ebp
  8025f9:	c3                   	ret    
	...

008025fc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	57                   	push   %edi
  802600:	56                   	push   %esi
  802601:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802602:	b8 00 00 00 00       	mov    $0x0,%eax
  802607:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80260a:	8b 55 08             	mov    0x8(%ebp),%edx
  80260d:	89 c3                	mov    %eax,%ebx
  80260f:	89 c7                	mov    %eax,%edi
  802611:	89 c6                	mov    %eax,%esi
  802613:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802615:	5b                   	pop    %ebx
  802616:	5e                   	pop    %esi
  802617:	5f                   	pop    %edi
  802618:	5d                   	pop    %ebp
  802619:	c3                   	ret    

0080261a <sys_cgetc>:

int
sys_cgetc(void)
{
  80261a:	55                   	push   %ebp
  80261b:	89 e5                	mov    %esp,%ebp
  80261d:	57                   	push   %edi
  80261e:	56                   	push   %esi
  80261f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802620:	ba 00 00 00 00       	mov    $0x0,%edx
  802625:	b8 01 00 00 00       	mov    $0x1,%eax
  80262a:	89 d1                	mov    %edx,%ecx
  80262c:	89 d3                	mov    %edx,%ebx
  80262e:	89 d7                	mov    %edx,%edi
  802630:	89 d6                	mov    %edx,%esi
  802632:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802634:	5b                   	pop    %ebx
  802635:	5e                   	pop    %esi
  802636:	5f                   	pop    %edi
  802637:	5d                   	pop    %ebp
  802638:	c3                   	ret    

00802639 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802639:	55                   	push   %ebp
  80263a:	89 e5                	mov    %esp,%ebp
  80263c:	57                   	push   %edi
  80263d:	56                   	push   %esi
  80263e:	53                   	push   %ebx
  80263f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802642:	b9 00 00 00 00       	mov    $0x0,%ecx
  802647:	b8 03 00 00 00       	mov    $0x3,%eax
  80264c:	8b 55 08             	mov    0x8(%ebp),%edx
  80264f:	89 cb                	mov    %ecx,%ebx
  802651:	89 cf                	mov    %ecx,%edi
  802653:	89 ce                	mov    %ecx,%esi
  802655:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802657:	85 c0                	test   %eax,%eax
  802659:	7e 28                	jle    802683 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80265b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80265f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  802666:	00 
  802667:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  80266e:	00 
  80266f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802676:	00 
  802677:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  80267e:	e8 b1 f5 ff ff       	call   801c34 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802683:	83 c4 2c             	add    $0x2c,%esp
  802686:	5b                   	pop    %ebx
  802687:	5e                   	pop    %esi
  802688:	5f                   	pop    %edi
  802689:	5d                   	pop    %ebp
  80268a:	c3                   	ret    

0080268b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80268b:	55                   	push   %ebp
  80268c:	89 e5                	mov    %esp,%ebp
  80268e:	57                   	push   %edi
  80268f:	56                   	push   %esi
  802690:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802691:	ba 00 00 00 00       	mov    $0x0,%edx
  802696:	b8 02 00 00 00       	mov    $0x2,%eax
  80269b:	89 d1                	mov    %edx,%ecx
  80269d:	89 d3                	mov    %edx,%ebx
  80269f:	89 d7                	mov    %edx,%edi
  8026a1:	89 d6                	mov    %edx,%esi
  8026a3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8026a5:	5b                   	pop    %ebx
  8026a6:	5e                   	pop    %esi
  8026a7:	5f                   	pop    %edi
  8026a8:	5d                   	pop    %ebp
  8026a9:	c3                   	ret    

008026aa <sys_yield>:

void
sys_yield(void)
{
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	57                   	push   %edi
  8026ae:	56                   	push   %esi
  8026af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8026b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8026ba:	89 d1                	mov    %edx,%ecx
  8026bc:	89 d3                	mov    %edx,%ebx
  8026be:	89 d7                	mov    %edx,%edi
  8026c0:	89 d6                	mov    %edx,%esi
  8026c2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    

008026c9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8026c9:	55                   	push   %ebp
  8026ca:	89 e5                	mov    %esp,%ebp
  8026cc:	57                   	push   %edi
  8026cd:	56                   	push   %esi
  8026ce:	53                   	push   %ebx
  8026cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026d2:	be 00 00 00 00       	mov    $0x0,%esi
  8026d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8026dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8026df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8026e5:	89 f7                	mov    %esi,%edi
  8026e7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8026e9:	85 c0                	test   %eax,%eax
  8026eb:	7e 28                	jle    802715 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026f1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8026f8:	00 
  8026f9:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  802700:	00 
  802701:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802708:	00 
  802709:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  802710:	e8 1f f5 ff ff       	call   801c34 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802715:	83 c4 2c             	add    $0x2c,%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    

0080271d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	57                   	push   %edi
  802721:	56                   	push   %esi
  802722:	53                   	push   %ebx
  802723:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802726:	b8 05 00 00 00       	mov    $0x5,%eax
  80272b:	8b 75 18             	mov    0x18(%ebp),%esi
  80272e:	8b 7d 14             	mov    0x14(%ebp),%edi
  802731:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802737:	8b 55 08             	mov    0x8(%ebp),%edx
  80273a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80273c:	85 c0                	test   %eax,%eax
  80273e:	7e 28                	jle    802768 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802740:	89 44 24 10          	mov    %eax,0x10(%esp)
  802744:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80274b:	00 
  80274c:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  802753:	00 
  802754:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80275b:	00 
  80275c:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  802763:	e8 cc f4 ff ff       	call   801c34 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802768:	83 c4 2c             	add    $0x2c,%esp
  80276b:	5b                   	pop    %ebx
  80276c:	5e                   	pop    %esi
  80276d:	5f                   	pop    %edi
  80276e:	5d                   	pop    %ebp
  80276f:	c3                   	ret    

00802770 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802770:	55                   	push   %ebp
  802771:	89 e5                	mov    %esp,%ebp
  802773:	57                   	push   %edi
  802774:	56                   	push   %esi
  802775:	53                   	push   %ebx
  802776:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802779:	bb 00 00 00 00       	mov    $0x0,%ebx
  80277e:	b8 06 00 00 00       	mov    $0x6,%eax
  802783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802786:	8b 55 08             	mov    0x8(%ebp),%edx
  802789:	89 df                	mov    %ebx,%edi
  80278b:	89 de                	mov    %ebx,%esi
  80278d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80278f:	85 c0                	test   %eax,%eax
  802791:	7e 28                	jle    8027bb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802793:	89 44 24 10          	mov    %eax,0x10(%esp)
  802797:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80279e:	00 
  80279f:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  8027a6:	00 
  8027a7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8027ae:	00 
  8027af:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  8027b6:	e8 79 f4 ff ff       	call   801c34 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8027bb:	83 c4 2c             	add    $0x2c,%esp
  8027be:	5b                   	pop    %ebx
  8027bf:	5e                   	pop    %esi
  8027c0:	5f                   	pop    %edi
  8027c1:	5d                   	pop    %ebp
  8027c2:	c3                   	ret    

008027c3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8027c3:	55                   	push   %ebp
  8027c4:	89 e5                	mov    %esp,%ebp
  8027c6:	57                   	push   %edi
  8027c7:	56                   	push   %esi
  8027c8:	53                   	push   %ebx
  8027c9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8027d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8027dc:	89 df                	mov    %ebx,%edi
  8027de:	89 de                	mov    %ebx,%esi
  8027e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8027e2:	85 c0                	test   %eax,%eax
  8027e4:	7e 28                	jle    80280e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027ea:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8027f1:	00 
  8027f2:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  8027f9:	00 
  8027fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802801:	00 
  802802:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  802809:	e8 26 f4 ff ff       	call   801c34 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80280e:	83 c4 2c             	add    $0x2c,%esp
  802811:	5b                   	pop    %ebx
  802812:	5e                   	pop    %esi
  802813:	5f                   	pop    %edi
  802814:	5d                   	pop    %ebp
  802815:	c3                   	ret    

00802816 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802816:	55                   	push   %ebp
  802817:	89 e5                	mov    %esp,%ebp
  802819:	57                   	push   %edi
  80281a:	56                   	push   %esi
  80281b:	53                   	push   %ebx
  80281c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80281f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802824:	b8 09 00 00 00       	mov    $0x9,%eax
  802829:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80282c:	8b 55 08             	mov    0x8(%ebp),%edx
  80282f:	89 df                	mov    %ebx,%edi
  802831:	89 de                	mov    %ebx,%esi
  802833:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802835:	85 c0                	test   %eax,%eax
  802837:	7e 28                	jle    802861 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802839:	89 44 24 10          	mov    %eax,0x10(%esp)
  80283d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  802844:	00 
  802845:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  80284c:	00 
  80284d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802854:	00 
  802855:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  80285c:	e8 d3 f3 ff ff       	call   801c34 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802861:	83 c4 2c             	add    $0x2c,%esp
  802864:	5b                   	pop    %ebx
  802865:	5e                   	pop    %esi
  802866:	5f                   	pop    %edi
  802867:	5d                   	pop    %ebp
  802868:	c3                   	ret    

00802869 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802869:	55                   	push   %ebp
  80286a:	89 e5                	mov    %esp,%ebp
  80286c:	57                   	push   %edi
  80286d:	56                   	push   %esi
  80286e:	53                   	push   %ebx
  80286f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802872:	bb 00 00 00 00       	mov    $0x0,%ebx
  802877:	b8 0a 00 00 00       	mov    $0xa,%eax
  80287c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80287f:	8b 55 08             	mov    0x8(%ebp),%edx
  802882:	89 df                	mov    %ebx,%edi
  802884:	89 de                	mov    %ebx,%esi
  802886:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802888:	85 c0                	test   %eax,%eax
  80288a:	7e 28                	jle    8028b4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80288c:	89 44 24 10          	mov    %eax,0x10(%esp)
  802890:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802897:	00 
  802898:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  80289f:	00 
  8028a0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028a7:	00 
  8028a8:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  8028af:	e8 80 f3 ff ff       	call   801c34 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8028b4:	83 c4 2c             	add    $0x2c,%esp
  8028b7:	5b                   	pop    %ebx
  8028b8:	5e                   	pop    %esi
  8028b9:	5f                   	pop    %edi
  8028ba:	5d                   	pop    %ebp
  8028bb:	c3                   	ret    

008028bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8028bc:	55                   	push   %ebp
  8028bd:	89 e5                	mov    %esp,%ebp
  8028bf:	57                   	push   %edi
  8028c0:	56                   	push   %esi
  8028c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028c2:	be 00 00 00 00       	mov    $0x0,%esi
  8028c7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8028cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8028d8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8028da:	5b                   	pop    %ebx
  8028db:	5e                   	pop    %esi
  8028dc:	5f                   	pop    %edi
  8028dd:	5d                   	pop    %ebp
  8028de:	c3                   	ret    

008028df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8028df:	55                   	push   %ebp
  8028e0:	89 e5                	mov    %esp,%ebp
  8028e2:	57                   	push   %edi
  8028e3:	56                   	push   %esi
  8028e4:	53                   	push   %ebx
  8028e5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8028ed:	b8 0d 00 00 00       	mov    $0xd,%eax
  8028f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8028f5:	89 cb                	mov    %ecx,%ebx
  8028f7:	89 cf                	mov    %ecx,%edi
  8028f9:	89 ce                	mov    %ecx,%esi
  8028fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8028fd:	85 c0                	test   %eax,%eax
  8028ff:	7e 28                	jle    802929 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802901:	89 44 24 10          	mov    %eax,0x10(%esp)
  802905:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80290c:	00 
  80290d:	c7 44 24 08 5f 44 80 	movl   $0x80445f,0x8(%esp)
  802914:	00 
  802915:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80291c:	00 
  80291d:	c7 04 24 7c 44 80 00 	movl   $0x80447c,(%esp)
  802924:	e8 0b f3 ff ff       	call   801c34 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802929:	83 c4 2c             	add    $0x2c,%esp
  80292c:	5b                   	pop    %ebx
  80292d:	5e                   	pop    %esi
  80292e:	5f                   	pop    %edi
  80292f:	5d                   	pop    %ebp
  802930:	c3                   	ret    
  802931:	00 00                	add    %al,(%eax)
	...

00802934 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802934:	55                   	push   %ebp
  802935:	89 e5                	mov    %esp,%ebp
  802937:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80293a:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802941:	75 58                	jne    80299b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  802943:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802948:	8b 40 48             	mov    0x48(%eax),%eax
  80294b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802952:	00 
  802953:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80295a:	ee 
  80295b:	89 04 24             	mov    %eax,(%esp)
  80295e:	e8 66 fd ff ff       	call   8026c9 <sys_page_alloc>
  802963:	85 c0                	test   %eax,%eax
  802965:	74 1c                	je     802983 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  802967:	c7 44 24 08 8a 44 80 	movl   $0x80448a,0x8(%esp)
  80296e:	00 
  80296f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802976:	00 
  802977:	c7 04 24 9f 44 80 00 	movl   $0x80449f,(%esp)
  80297e:	e8 b1 f2 ff ff       	call   801c34 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802983:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802988:	8b 40 48             	mov    0x48(%eax),%eax
  80298b:	c7 44 24 04 a8 29 80 	movl   $0x8029a8,0x4(%esp)
  802992:	00 
  802993:	89 04 24             	mov    %eax,(%esp)
  802996:	e8 ce fe ff ff       	call   802869 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80299b:	8b 45 08             	mov    0x8(%ebp),%eax
  80299e:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  8029a3:	c9                   	leave  
  8029a4:	c3                   	ret    
  8029a5:	00 00                	add    %al,(%eax)
	...

008029a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8029a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8029a9:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8029ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8029b0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8029b3:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8029b7:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8029b9:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8029bd:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8029be:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8029c1:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8029c3:	58                   	pop    %eax
	popl %eax
  8029c4:	58                   	pop    %eax

	// Pop all registers back
	popal
  8029c5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8029c6:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8029c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8029ca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8029cb:	c3                   	ret    

008029cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029cc:	55                   	push   %ebp
  8029cd:	89 e5                	mov    %esp,%ebp
  8029cf:	56                   	push   %esi
  8029d0:	53                   	push   %ebx
  8029d1:	83 ec 10             	sub    $0x10,%esp
  8029d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8029d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029da:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8029dd:	85 c0                	test   %eax,%eax
  8029df:	75 05                	jne    8029e6 <ipc_recv+0x1a>
  8029e1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8029e6:	89 04 24             	mov    %eax,(%esp)
  8029e9:	e8 f1 fe ff ff       	call   8028df <sys_ipc_recv>
	if (from_env_store != NULL)
  8029ee:	85 db                	test   %ebx,%ebx
  8029f0:	74 0b                	je     8029fd <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8029f2:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8029f8:	8b 52 74             	mov    0x74(%edx),%edx
  8029fb:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8029fd:	85 f6                	test   %esi,%esi
  8029ff:	74 0b                	je     802a0c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802a01:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  802a07:	8b 52 78             	mov    0x78(%edx),%edx
  802a0a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802a0c:	85 c0                	test   %eax,%eax
  802a0e:	79 16                	jns    802a26 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802a10:	85 db                	test   %ebx,%ebx
  802a12:	74 06                	je     802a1a <ipc_recv+0x4e>
			*from_env_store = 0;
  802a14:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802a1a:	85 f6                	test   %esi,%esi
  802a1c:	74 10                	je     802a2e <ipc_recv+0x62>
			*perm_store = 0;
  802a1e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802a24:	eb 08                	jmp    802a2e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802a26:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a2b:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a2e:	83 c4 10             	add    $0x10,%esp
  802a31:	5b                   	pop    %ebx
  802a32:	5e                   	pop    %esi
  802a33:	5d                   	pop    %ebp
  802a34:	c3                   	ret    

00802a35 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a35:	55                   	push   %ebp
  802a36:	89 e5                	mov    %esp,%ebp
  802a38:	57                   	push   %edi
  802a39:	56                   	push   %esi
  802a3a:	53                   	push   %ebx
  802a3b:	83 ec 1c             	sub    $0x1c,%esp
  802a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  802a41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802a44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802a47:	eb 2a                	jmp    802a73 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802a49:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a4c:	74 20                	je     802a6e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802a4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a52:	c7 44 24 08 b0 44 80 	movl   $0x8044b0,0x8(%esp)
  802a59:	00 
  802a5a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802a61:	00 
  802a62:	c7 04 24 d5 44 80 00 	movl   $0x8044d5,(%esp)
  802a69:	e8 c6 f1 ff ff       	call   801c34 <_panic>
		sys_yield();
  802a6e:	e8 37 fc ff ff       	call   8026aa <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802a73:	85 db                	test   %ebx,%ebx
  802a75:	75 07                	jne    802a7e <ipc_send+0x49>
  802a77:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802a7c:	eb 02                	jmp    802a80 <ipc_send+0x4b>
  802a7e:	89 d8                	mov    %ebx,%eax
  802a80:	8b 55 14             	mov    0x14(%ebp),%edx
  802a83:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a8b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a8f:	89 34 24             	mov    %esi,(%esp)
  802a92:	e8 25 fe ff ff       	call   8028bc <sys_ipc_try_send>
  802a97:	85 c0                	test   %eax,%eax
  802a99:	78 ae                	js     802a49 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802a9b:	83 c4 1c             	add    $0x1c,%esp
  802a9e:	5b                   	pop    %ebx
  802a9f:	5e                   	pop    %esi
  802aa0:	5f                   	pop    %edi
  802aa1:	5d                   	pop    %ebp
  802aa2:	c3                   	ret    

00802aa3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802aa3:	55                   	push   %ebp
  802aa4:	89 e5                	mov    %esp,%ebp
  802aa6:	53                   	push   %ebx
  802aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802aaa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802aaf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802ab6:	89 c2                	mov    %eax,%edx
  802ab8:	c1 e2 07             	shl    $0x7,%edx
  802abb:	29 ca                	sub    %ecx,%edx
  802abd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802ac3:	8b 52 50             	mov    0x50(%edx),%edx
  802ac6:	39 da                	cmp    %ebx,%edx
  802ac8:	75 0f                	jne    802ad9 <ipc_find_env+0x36>
			return envs[i].env_id;
  802aca:	c1 e0 07             	shl    $0x7,%eax
  802acd:	29 c8                	sub    %ecx,%eax
  802acf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802ad4:	8b 40 40             	mov    0x40(%eax),%eax
  802ad7:	eb 0c                	jmp    802ae5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ad9:	40                   	inc    %eax
  802ada:	3d 00 04 00 00       	cmp    $0x400,%eax
  802adf:	75 ce                	jne    802aaf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ae1:	66 b8 00 00          	mov    $0x0,%ax
}
  802ae5:	5b                   	pop    %ebx
  802ae6:	5d                   	pop    %ebp
  802ae7:	c3                   	ret    

00802ae8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802ae8:	55                   	push   %ebp
  802ae9:	89 e5                	mov    %esp,%ebp
  802aeb:	56                   	push   %esi
  802aec:	53                   	push   %ebx
  802aed:	83 ec 10             	sub    $0x10,%esp
  802af0:	89 c3                	mov    %eax,%ebx
  802af2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802af4:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802afb:	75 11                	jne    802b0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802afd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802b04:	e8 9a ff ff ff       	call   802aa3 <ipc_find_env>
  802b09:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802b0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802b15:	00 
  802b16:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  802b1d:	00 
  802b1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b22:	a1 00 a0 80 00       	mov    0x80a000,%eax
  802b27:	89 04 24             	mov    %eax,(%esp)
  802b2a:	e8 06 ff ff ff       	call   802a35 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b36:	00 
  802b37:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b42:	e8 85 fe ff ff       	call   8029cc <ipc_recv>
}
  802b47:	83 c4 10             	add    $0x10,%esp
  802b4a:	5b                   	pop    %ebx
  802b4b:	5e                   	pop    %esi
  802b4c:	5d                   	pop    %ebp
  802b4d:	c3                   	ret    

00802b4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802b4e:	55                   	push   %ebp
  802b4f:	89 e5                	mov    %esp,%ebp
  802b51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802b54:	8b 45 08             	mov    0x8(%ebp),%eax
  802b57:	8b 40 0c             	mov    0xc(%eax),%eax
  802b5a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b62:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802b67:	ba 00 00 00 00       	mov    $0x0,%edx
  802b6c:	b8 02 00 00 00       	mov    $0x2,%eax
  802b71:	e8 72 ff ff ff       	call   802ae8 <fsipc>
}
  802b76:	c9                   	leave  
  802b77:	c3                   	ret    

00802b78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802b78:	55                   	push   %ebp
  802b79:	89 e5                	mov    %esp,%ebp
  802b7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  802b81:	8b 40 0c             	mov    0xc(%eax),%eax
  802b84:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802b89:	ba 00 00 00 00       	mov    $0x0,%edx
  802b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  802b93:	e8 50 ff ff ff       	call   802ae8 <fsipc>
}
  802b98:	c9                   	leave  
  802b99:	c3                   	ret    

00802b9a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802b9a:	55                   	push   %ebp
  802b9b:	89 e5                	mov    %esp,%ebp
  802b9d:	53                   	push   %ebx
  802b9e:	83 ec 14             	sub    $0x14,%esp
  802ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  802ba7:	8b 40 0c             	mov    0xc(%eax),%eax
  802baa:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802baf:	ba 00 00 00 00       	mov    $0x0,%edx
  802bb4:	b8 05 00 00 00       	mov    $0x5,%eax
  802bb9:	e8 2a ff ff ff       	call   802ae8 <fsipc>
  802bbe:	85 c0                	test   %eax,%eax
  802bc0:	78 2b                	js     802bed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802bc2:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  802bc9:	00 
  802bca:	89 1c 24             	mov    %ebx,(%esp)
  802bcd:	e8 05 f7 ff ff       	call   8022d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802bd2:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802bd7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802bdd:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802be2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bed:	83 c4 14             	add    $0x14,%esp
  802bf0:	5b                   	pop    %ebx
  802bf1:	5d                   	pop    %ebp
  802bf2:	c3                   	ret    

00802bf3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802bf3:	55                   	push   %ebp
  802bf4:	89 e5                	mov    %esp,%ebp
  802bf6:	83 ec 18             	sub    $0x18,%esp
  802bf9:	8b 55 10             	mov    0x10(%ebp),%edx
  802bfc:	89 d0                	mov    %edx,%eax
  802bfe:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  802c04:	76 05                	jbe    802c0b <devfile_write+0x18>
  802c06:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  802c0e:	8b 52 0c             	mov    0xc(%edx),%edx
  802c11:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802c17:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802c1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c27:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  802c2e:	e8 1d f8 ff ff       	call   802450 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  802c33:	ba 00 00 00 00       	mov    $0x0,%edx
  802c38:	b8 04 00 00 00       	mov    $0x4,%eax
  802c3d:	e8 a6 fe ff ff       	call   802ae8 <fsipc>
}
  802c42:	c9                   	leave  
  802c43:	c3                   	ret    

00802c44 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802c44:	55                   	push   %ebp
  802c45:	89 e5                	mov    %esp,%ebp
  802c47:	56                   	push   %esi
  802c48:	53                   	push   %ebx
  802c49:	83 ec 10             	sub    $0x10,%esp
  802c4c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  802c52:	8b 40 0c             	mov    0xc(%eax),%eax
  802c55:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802c5a:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802c60:	ba 00 00 00 00       	mov    $0x0,%edx
  802c65:	b8 03 00 00 00       	mov    $0x3,%eax
  802c6a:	e8 79 fe ff ff       	call   802ae8 <fsipc>
  802c6f:	89 c3                	mov    %eax,%ebx
  802c71:	85 c0                	test   %eax,%eax
  802c73:	78 6a                	js     802cdf <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802c75:	39 c6                	cmp    %eax,%esi
  802c77:	73 24                	jae    802c9d <devfile_read+0x59>
  802c79:	c7 44 24 0c df 44 80 	movl   $0x8044df,0xc(%esp)
  802c80:	00 
  802c81:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  802c88:	00 
  802c89:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802c90:	00 
  802c91:	c7 04 24 e6 44 80 00 	movl   $0x8044e6,(%esp)
  802c98:	e8 97 ef ff ff       	call   801c34 <_panic>
	assert(r <= PGSIZE);
  802c9d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802ca2:	7e 24                	jle    802cc8 <devfile_read+0x84>
  802ca4:	c7 44 24 0c f1 44 80 	movl   $0x8044f1,0xc(%esp)
  802cab:	00 
  802cac:	c7 44 24 08 7d 3b 80 	movl   $0x803b7d,0x8(%esp)
  802cb3:	00 
  802cb4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802cbb:	00 
  802cbc:	c7 04 24 e6 44 80 00 	movl   $0x8044e6,(%esp)
  802cc3:	e8 6c ef ff ff       	call   801c34 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ccc:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  802cd3:	00 
  802cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cd7:	89 04 24             	mov    %eax,(%esp)
  802cda:	e8 71 f7 ff ff       	call   802450 <memmove>
	return r;
}
  802cdf:	89 d8                	mov    %ebx,%eax
  802ce1:	83 c4 10             	add    $0x10,%esp
  802ce4:	5b                   	pop    %ebx
  802ce5:	5e                   	pop    %esi
  802ce6:	5d                   	pop    %ebp
  802ce7:	c3                   	ret    

00802ce8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802ce8:	55                   	push   %ebp
  802ce9:	89 e5                	mov    %esp,%ebp
  802ceb:	56                   	push   %esi
  802cec:	53                   	push   %ebx
  802ced:	83 ec 20             	sub    $0x20,%esp
  802cf0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802cf3:	89 34 24             	mov    %esi,(%esp)
  802cf6:	e8 a9 f5 ff ff       	call   8022a4 <strlen>
  802cfb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802d00:	7f 60                	jg     802d62 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d05:	89 04 24             	mov    %eax,(%esp)
  802d08:	e8 ea 00 00 00       	call   802df7 <fd_alloc>
  802d0d:	89 c3                	mov    %eax,%ebx
  802d0f:	85 c0                	test   %eax,%eax
  802d11:	78 54                	js     802d67 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802d13:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d17:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  802d1e:	e8 b4 f5 ff ff       	call   8022d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d26:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802d2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d2e:	b8 01 00 00 00       	mov    $0x1,%eax
  802d33:	e8 b0 fd ff ff       	call   802ae8 <fsipc>
  802d38:	89 c3                	mov    %eax,%ebx
  802d3a:	85 c0                	test   %eax,%eax
  802d3c:	79 15                	jns    802d53 <open+0x6b>
		fd_close(fd, 0);
  802d3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802d45:	00 
  802d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d49:	89 04 24             	mov    %eax,(%esp)
  802d4c:	e8 a9 01 00 00       	call   802efa <fd_close>
		return r;
  802d51:	eb 14                	jmp    802d67 <open+0x7f>
	}

	return fd2num(fd);
  802d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d56:	89 04 24             	mov    %eax,(%esp)
  802d59:	e8 6e 00 00 00       	call   802dcc <fd2num>
  802d5e:	89 c3                	mov    %eax,%ebx
  802d60:	eb 05                	jmp    802d67 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802d62:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802d67:	89 d8                	mov    %ebx,%eax
  802d69:	83 c4 20             	add    $0x20,%esp
  802d6c:	5b                   	pop    %ebx
  802d6d:	5e                   	pop    %esi
  802d6e:	5d                   	pop    %ebp
  802d6f:	c3                   	ret    

00802d70 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802d70:	55                   	push   %ebp
  802d71:	89 e5                	mov    %esp,%ebp
  802d73:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802d76:	ba 00 00 00 00       	mov    $0x0,%edx
  802d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  802d80:	e8 63 fd ff ff       	call   802ae8 <fsipc>
}
  802d85:	c9                   	leave  
  802d86:	c3                   	ret    
	...

00802d88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802d88:	55                   	push   %ebp
  802d89:	89 e5                	mov    %esp,%ebp
  802d8b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802d8e:	89 c2                	mov    %eax,%edx
  802d90:	c1 ea 16             	shr    $0x16,%edx
  802d93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802d9a:	f6 c2 01             	test   $0x1,%dl
  802d9d:	74 1e                	je     802dbd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802d9f:	c1 e8 0c             	shr    $0xc,%eax
  802da2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802da9:	a8 01                	test   $0x1,%al
  802dab:	74 17                	je     802dc4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802dad:	c1 e8 0c             	shr    $0xc,%eax
  802db0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802db7:	ef 
  802db8:	0f b7 c0             	movzwl %ax,%eax
  802dbb:	eb 0c                	jmp    802dc9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  802dc2:	eb 05                	jmp    802dc9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802dc4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802dc9:	5d                   	pop    %ebp
  802dca:	c3                   	ret    
	...

00802dcc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802dcc:	55                   	push   %ebp
  802dcd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  802dd2:	05 00 00 00 30       	add    $0x30000000,%eax
  802dd7:	c1 e8 0c             	shr    $0xc,%eax
}
  802dda:	5d                   	pop    %ebp
  802ddb:	c3                   	ret    

00802ddc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802ddc:	55                   	push   %ebp
  802ddd:	89 e5                	mov    %esp,%ebp
  802ddf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802de2:	8b 45 08             	mov    0x8(%ebp),%eax
  802de5:	89 04 24             	mov    %eax,(%esp)
  802de8:	e8 df ff ff ff       	call   802dcc <fd2num>
  802ded:	05 20 00 0d 00       	add    $0xd0020,%eax
  802df2:	c1 e0 0c             	shl    $0xc,%eax
}
  802df5:	c9                   	leave  
  802df6:	c3                   	ret    

00802df7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802df7:	55                   	push   %ebp
  802df8:	89 e5                	mov    %esp,%ebp
  802dfa:	53                   	push   %ebx
  802dfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802dfe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802e03:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802e05:	89 c2                	mov    %eax,%edx
  802e07:	c1 ea 16             	shr    $0x16,%edx
  802e0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802e11:	f6 c2 01             	test   $0x1,%dl
  802e14:	74 11                	je     802e27 <fd_alloc+0x30>
  802e16:	89 c2                	mov    %eax,%edx
  802e18:	c1 ea 0c             	shr    $0xc,%edx
  802e1b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802e22:	f6 c2 01             	test   $0x1,%dl
  802e25:	75 09                	jne    802e30 <fd_alloc+0x39>
			*fd_store = fd;
  802e27:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  802e29:	b8 00 00 00 00       	mov    $0x0,%eax
  802e2e:	eb 17                	jmp    802e47 <fd_alloc+0x50>
  802e30:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802e35:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802e3a:	75 c7                	jne    802e03 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802e3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  802e42:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802e47:	5b                   	pop    %ebx
  802e48:	5d                   	pop    %ebp
  802e49:	c3                   	ret    

00802e4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802e4a:	55                   	push   %ebp
  802e4b:	89 e5                	mov    %esp,%ebp
  802e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802e50:	83 f8 1f             	cmp    $0x1f,%eax
  802e53:	77 36                	ja     802e8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802e55:	05 00 00 0d 00       	add    $0xd0000,%eax
  802e5a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802e5d:	89 c2                	mov    %eax,%edx
  802e5f:	c1 ea 16             	shr    $0x16,%edx
  802e62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802e69:	f6 c2 01             	test   $0x1,%dl
  802e6c:	74 24                	je     802e92 <fd_lookup+0x48>
  802e6e:	89 c2                	mov    %eax,%edx
  802e70:	c1 ea 0c             	shr    $0xc,%edx
  802e73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802e7a:	f6 c2 01             	test   $0x1,%dl
  802e7d:	74 1a                	je     802e99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e82:	89 02                	mov    %eax,(%edx)
	return 0;
  802e84:	b8 00 00 00 00       	mov    $0x0,%eax
  802e89:	eb 13                	jmp    802e9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802e8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e90:	eb 0c                	jmp    802e9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802e97:	eb 05                	jmp    802e9e <fd_lookup+0x54>
  802e99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802e9e:	5d                   	pop    %ebp
  802e9f:	c3                   	ret    

00802ea0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802ea0:	55                   	push   %ebp
  802ea1:	89 e5                	mov    %esp,%ebp
  802ea3:	53                   	push   %ebx
  802ea4:	83 ec 14             	sub    $0x14,%esp
  802ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802eaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  802ead:	ba 00 00 00 00       	mov    $0x0,%edx
  802eb2:	eb 0e                	jmp    802ec2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  802eb4:	39 08                	cmp    %ecx,(%eax)
  802eb6:	75 09                	jne    802ec1 <dev_lookup+0x21>
			*dev = devtab[i];
  802eb8:	89 03                	mov    %eax,(%ebx)
			return 0;
  802eba:	b8 00 00 00 00       	mov    $0x0,%eax
  802ebf:	eb 33                	jmp    802ef4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802ec1:	42                   	inc    %edx
  802ec2:	8b 04 95 80 45 80 00 	mov    0x804580(,%edx,4),%eax
  802ec9:	85 c0                	test   %eax,%eax
  802ecb:	75 e7                	jne    802eb4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802ecd:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ed2:	8b 40 48             	mov    0x48(%eax),%eax
  802ed5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802edd:	c7 04 24 00 45 80 00 	movl   $0x804500,(%esp)
  802ee4:	e8 43 ee ff ff       	call   801d2c <cprintf>
	*dev = 0;
  802ee9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  802eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802ef4:	83 c4 14             	add    $0x14,%esp
  802ef7:	5b                   	pop    %ebx
  802ef8:	5d                   	pop    %ebp
  802ef9:	c3                   	ret    

00802efa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802efa:	55                   	push   %ebp
  802efb:	89 e5                	mov    %esp,%ebp
  802efd:	56                   	push   %esi
  802efe:	53                   	push   %ebx
  802eff:	83 ec 30             	sub    $0x30,%esp
  802f02:	8b 75 08             	mov    0x8(%ebp),%esi
  802f05:	8a 45 0c             	mov    0xc(%ebp),%al
  802f08:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802f0b:	89 34 24             	mov    %esi,(%esp)
  802f0e:	e8 b9 fe ff ff       	call   802dcc <fd2num>
  802f13:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802f16:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f1a:	89 04 24             	mov    %eax,(%esp)
  802f1d:	e8 28 ff ff ff       	call   802e4a <fd_lookup>
  802f22:	89 c3                	mov    %eax,%ebx
  802f24:	85 c0                	test   %eax,%eax
  802f26:	78 05                	js     802f2d <fd_close+0x33>
	    || fd != fd2)
  802f28:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802f2b:	74 0d                	je     802f3a <fd_close+0x40>
		return (must_exist ? r : 0);
  802f2d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802f31:	75 46                	jne    802f79 <fd_close+0x7f>
  802f33:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f38:	eb 3f                	jmp    802f79 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802f3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f41:	8b 06                	mov    (%esi),%eax
  802f43:	89 04 24             	mov    %eax,(%esp)
  802f46:	e8 55 ff ff ff       	call   802ea0 <dev_lookup>
  802f4b:	89 c3                	mov    %eax,%ebx
  802f4d:	85 c0                	test   %eax,%eax
  802f4f:	78 18                	js     802f69 <fd_close+0x6f>
		if (dev->dev_close)
  802f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f54:	8b 40 10             	mov    0x10(%eax),%eax
  802f57:	85 c0                	test   %eax,%eax
  802f59:	74 09                	je     802f64 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802f5b:	89 34 24             	mov    %esi,(%esp)
  802f5e:	ff d0                	call   *%eax
  802f60:	89 c3                	mov    %eax,%ebx
  802f62:	eb 05                	jmp    802f69 <fd_close+0x6f>
		else
			r = 0;
  802f64:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802f69:	89 74 24 04          	mov    %esi,0x4(%esp)
  802f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f74:	e8 f7 f7 ff ff       	call   802770 <sys_page_unmap>
	return r;
}
  802f79:	89 d8                	mov    %ebx,%eax
  802f7b:	83 c4 30             	add    $0x30,%esp
  802f7e:	5b                   	pop    %ebx
  802f7f:	5e                   	pop    %esi
  802f80:	5d                   	pop    %ebp
  802f81:	c3                   	ret    

00802f82 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802f82:	55                   	push   %ebp
  802f83:	89 e5                	mov    %esp,%ebp
  802f85:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802f88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f92:	89 04 24             	mov    %eax,(%esp)
  802f95:	e8 b0 fe ff ff       	call   802e4a <fd_lookup>
  802f9a:	85 c0                	test   %eax,%eax
  802f9c:	78 13                	js     802fb1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802f9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802fa5:	00 
  802fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fa9:	89 04 24             	mov    %eax,(%esp)
  802fac:	e8 49 ff ff ff       	call   802efa <fd_close>
}
  802fb1:	c9                   	leave  
  802fb2:	c3                   	ret    

00802fb3 <close_all>:

void
close_all(void)
{
  802fb3:	55                   	push   %ebp
  802fb4:	89 e5                	mov    %esp,%ebp
  802fb6:	53                   	push   %ebx
  802fb7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802fba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802fbf:	89 1c 24             	mov    %ebx,(%esp)
  802fc2:	e8 bb ff ff ff       	call   802f82 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802fc7:	43                   	inc    %ebx
  802fc8:	83 fb 20             	cmp    $0x20,%ebx
  802fcb:	75 f2                	jne    802fbf <close_all+0xc>
		close(i);
}
  802fcd:	83 c4 14             	add    $0x14,%esp
  802fd0:	5b                   	pop    %ebx
  802fd1:	5d                   	pop    %ebp
  802fd2:	c3                   	ret    

00802fd3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802fd3:	55                   	push   %ebp
  802fd4:	89 e5                	mov    %esp,%ebp
  802fd6:	57                   	push   %edi
  802fd7:	56                   	push   %esi
  802fd8:	53                   	push   %ebx
  802fd9:	83 ec 4c             	sub    $0x4c,%esp
  802fdc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802fdf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  802fe9:	89 04 24             	mov    %eax,(%esp)
  802fec:	e8 59 fe ff ff       	call   802e4a <fd_lookup>
  802ff1:	89 c3                	mov    %eax,%ebx
  802ff3:	85 c0                	test   %eax,%eax
  802ff5:	0f 88 e1 00 00 00    	js     8030dc <dup+0x109>
		return r;
	close(newfdnum);
  802ffb:	89 3c 24             	mov    %edi,(%esp)
  802ffe:	e8 7f ff ff ff       	call   802f82 <close>

	newfd = INDEX2FD(newfdnum);
  803003:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  803009:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80300c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80300f:	89 04 24             	mov    %eax,(%esp)
  803012:	e8 c5 fd ff ff       	call   802ddc <fd2data>
  803017:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  803019:	89 34 24             	mov    %esi,(%esp)
  80301c:	e8 bb fd ff ff       	call   802ddc <fd2data>
  803021:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  803024:	89 d8                	mov    %ebx,%eax
  803026:	c1 e8 16             	shr    $0x16,%eax
  803029:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  803030:	a8 01                	test   $0x1,%al
  803032:	74 46                	je     80307a <dup+0xa7>
  803034:	89 d8                	mov    %ebx,%eax
  803036:	c1 e8 0c             	shr    $0xc,%eax
  803039:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  803040:	f6 c2 01             	test   $0x1,%dl
  803043:	74 35                	je     80307a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  803045:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80304c:	25 07 0e 00 00       	and    $0xe07,%eax
  803051:	89 44 24 10          	mov    %eax,0x10(%esp)
  803055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80305c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803063:	00 
  803064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803068:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80306f:	e8 a9 f6 ff ff       	call   80271d <sys_page_map>
  803074:	89 c3                	mov    %eax,%ebx
  803076:	85 c0                	test   %eax,%eax
  803078:	78 3b                	js     8030b5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80307a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80307d:	89 c2                	mov    %eax,%edx
  80307f:	c1 ea 0c             	shr    $0xc,%edx
  803082:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  803089:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80308f:	89 54 24 10          	mov    %edx,0x10(%esp)
  803093:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803097:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80309e:	00 
  80309f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030aa:	e8 6e f6 ff ff       	call   80271d <sys_page_map>
  8030af:	89 c3                	mov    %eax,%ebx
  8030b1:	85 c0                	test   %eax,%eax
  8030b3:	79 25                	jns    8030da <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8030b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030c0:	e8 ab f6 ff ff       	call   802770 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8030c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8030c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030d3:	e8 98 f6 ff ff       	call   802770 <sys_page_unmap>
	return r;
  8030d8:	eb 02                	jmp    8030dc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8030da:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8030dc:	89 d8                	mov    %ebx,%eax
  8030de:	83 c4 4c             	add    $0x4c,%esp
  8030e1:	5b                   	pop    %ebx
  8030e2:	5e                   	pop    %esi
  8030e3:	5f                   	pop    %edi
  8030e4:	5d                   	pop    %ebp
  8030e5:	c3                   	ret    

008030e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8030e6:	55                   	push   %ebp
  8030e7:	89 e5                	mov    %esp,%ebp
  8030e9:	53                   	push   %ebx
  8030ea:	83 ec 24             	sub    $0x24,%esp
  8030ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030f7:	89 1c 24             	mov    %ebx,(%esp)
  8030fa:	e8 4b fd ff ff       	call   802e4a <fd_lookup>
  8030ff:	85 c0                	test   %eax,%eax
  803101:	78 6d                	js     803170 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803106:	89 44 24 04          	mov    %eax,0x4(%esp)
  80310a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80310d:	8b 00                	mov    (%eax),%eax
  80310f:	89 04 24             	mov    %eax,(%esp)
  803112:	e8 89 fd ff ff       	call   802ea0 <dev_lookup>
  803117:	85 c0                	test   %eax,%eax
  803119:	78 55                	js     803170 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80311b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80311e:	8b 50 08             	mov    0x8(%eax),%edx
  803121:	83 e2 03             	and    $0x3,%edx
  803124:	83 fa 01             	cmp    $0x1,%edx
  803127:	75 23                	jne    80314c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  803129:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80312e:	8b 40 48             	mov    0x48(%eax),%eax
  803131:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803135:	89 44 24 04          	mov    %eax,0x4(%esp)
  803139:	c7 04 24 44 45 80 00 	movl   $0x804544,(%esp)
  803140:	e8 e7 eb ff ff       	call   801d2c <cprintf>
		return -E_INVAL;
  803145:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80314a:	eb 24                	jmp    803170 <read+0x8a>
	}
	if (!dev->dev_read)
  80314c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80314f:	8b 52 08             	mov    0x8(%edx),%edx
  803152:	85 d2                	test   %edx,%edx
  803154:	74 15                	je     80316b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  803156:	8b 4d 10             	mov    0x10(%ebp),%ecx
  803159:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80315d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803160:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803164:	89 04 24             	mov    %eax,(%esp)
  803167:	ff d2                	call   *%edx
  803169:	eb 05                	jmp    803170 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80316b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  803170:	83 c4 24             	add    $0x24,%esp
  803173:	5b                   	pop    %ebx
  803174:	5d                   	pop    %ebp
  803175:	c3                   	ret    

00803176 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803176:	55                   	push   %ebp
  803177:	89 e5                	mov    %esp,%ebp
  803179:	57                   	push   %edi
  80317a:	56                   	push   %esi
  80317b:	53                   	push   %ebx
  80317c:	83 ec 1c             	sub    $0x1c,%esp
  80317f:	8b 7d 08             	mov    0x8(%ebp),%edi
  803182:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803185:	bb 00 00 00 00       	mov    $0x0,%ebx
  80318a:	eb 23                	jmp    8031af <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80318c:	89 f0                	mov    %esi,%eax
  80318e:	29 d8                	sub    %ebx,%eax
  803190:	89 44 24 08          	mov    %eax,0x8(%esp)
  803194:	8b 45 0c             	mov    0xc(%ebp),%eax
  803197:	01 d8                	add    %ebx,%eax
  803199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80319d:	89 3c 24             	mov    %edi,(%esp)
  8031a0:	e8 41 ff ff ff       	call   8030e6 <read>
		if (m < 0)
  8031a5:	85 c0                	test   %eax,%eax
  8031a7:	78 10                	js     8031b9 <readn+0x43>
			return m;
		if (m == 0)
  8031a9:	85 c0                	test   %eax,%eax
  8031ab:	74 0a                	je     8031b7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8031ad:	01 c3                	add    %eax,%ebx
  8031af:	39 f3                	cmp    %esi,%ebx
  8031b1:	72 d9                	jb     80318c <readn+0x16>
  8031b3:	89 d8                	mov    %ebx,%eax
  8031b5:	eb 02                	jmp    8031b9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8031b7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8031b9:	83 c4 1c             	add    $0x1c,%esp
  8031bc:	5b                   	pop    %ebx
  8031bd:	5e                   	pop    %esi
  8031be:	5f                   	pop    %edi
  8031bf:	5d                   	pop    %ebp
  8031c0:	c3                   	ret    

008031c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8031c1:	55                   	push   %ebp
  8031c2:	89 e5                	mov    %esp,%ebp
  8031c4:	53                   	push   %ebx
  8031c5:	83 ec 24             	sub    $0x24,%esp
  8031c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031d2:	89 1c 24             	mov    %ebx,(%esp)
  8031d5:	e8 70 fc ff ff       	call   802e4a <fd_lookup>
  8031da:	85 c0                	test   %eax,%eax
  8031dc:	78 68                	js     803246 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8031de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031e8:	8b 00                	mov    (%eax),%eax
  8031ea:	89 04 24             	mov    %eax,(%esp)
  8031ed:	e8 ae fc ff ff       	call   802ea0 <dev_lookup>
  8031f2:	85 c0                	test   %eax,%eax
  8031f4:	78 50                	js     803246 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8031f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8031fd:	75 23                	jne    803222 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8031ff:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803204:	8b 40 48             	mov    0x48(%eax),%eax
  803207:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80320b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80320f:	c7 04 24 60 45 80 00 	movl   $0x804560,(%esp)
  803216:	e8 11 eb ff ff       	call   801d2c <cprintf>
		return -E_INVAL;
  80321b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803220:	eb 24                	jmp    803246 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  803222:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803225:	8b 52 0c             	mov    0xc(%edx),%edx
  803228:	85 d2                	test   %edx,%edx
  80322a:	74 15                	je     803241 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80322c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80322f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803236:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80323a:	89 04 24             	mov    %eax,(%esp)
  80323d:	ff d2                	call   *%edx
  80323f:	eb 05                	jmp    803246 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  803241:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  803246:	83 c4 24             	add    $0x24,%esp
  803249:	5b                   	pop    %ebx
  80324a:	5d                   	pop    %ebp
  80324b:	c3                   	ret    

0080324c <seek>:

int
seek(int fdnum, off_t offset)
{
  80324c:	55                   	push   %ebp
  80324d:	89 e5                	mov    %esp,%ebp
  80324f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803252:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803255:	89 44 24 04          	mov    %eax,0x4(%esp)
  803259:	8b 45 08             	mov    0x8(%ebp),%eax
  80325c:	89 04 24             	mov    %eax,(%esp)
  80325f:	e8 e6 fb ff ff       	call   802e4a <fd_lookup>
  803264:	85 c0                	test   %eax,%eax
  803266:	78 0e                	js     803276 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803268:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80326b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80326e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  803271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803276:	c9                   	leave  
  803277:	c3                   	ret    

00803278 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803278:	55                   	push   %ebp
  803279:	89 e5                	mov    %esp,%ebp
  80327b:	53                   	push   %ebx
  80327c:	83 ec 24             	sub    $0x24,%esp
  80327f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803282:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803285:	89 44 24 04          	mov    %eax,0x4(%esp)
  803289:	89 1c 24             	mov    %ebx,(%esp)
  80328c:	e8 b9 fb ff ff       	call   802e4a <fd_lookup>
  803291:	85 c0                	test   %eax,%eax
  803293:	78 61                	js     8032f6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80329c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80329f:	8b 00                	mov    (%eax),%eax
  8032a1:	89 04 24             	mov    %eax,(%esp)
  8032a4:	e8 f7 fb ff ff       	call   802ea0 <dev_lookup>
  8032a9:	85 c0                	test   %eax,%eax
  8032ab:	78 49                	js     8032f6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8032ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8032b4:	75 23                	jne    8032d9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8032b6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8032bb:	8b 40 48             	mov    0x48(%eax),%eax
  8032be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8032c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032c6:	c7 04 24 20 45 80 00 	movl   $0x804520,(%esp)
  8032cd:	e8 5a ea ff ff       	call   801d2c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8032d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8032d7:	eb 1d                	jmp    8032f6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8032d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8032dc:	8b 52 18             	mov    0x18(%edx),%edx
  8032df:	85 d2                	test   %edx,%edx
  8032e1:	74 0e                	je     8032f1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8032e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8032ea:	89 04 24             	mov    %eax,(%esp)
  8032ed:	ff d2                	call   *%edx
  8032ef:	eb 05                	jmp    8032f6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8032f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8032f6:	83 c4 24             	add    $0x24,%esp
  8032f9:	5b                   	pop    %ebx
  8032fa:	5d                   	pop    %ebp
  8032fb:	c3                   	ret    

008032fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8032fc:	55                   	push   %ebp
  8032fd:	89 e5                	mov    %esp,%ebp
  8032ff:	53                   	push   %ebx
  803300:	83 ec 24             	sub    $0x24,%esp
  803303:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80330d:	8b 45 08             	mov    0x8(%ebp),%eax
  803310:	89 04 24             	mov    %eax,(%esp)
  803313:	e8 32 fb ff ff       	call   802e4a <fd_lookup>
  803318:	85 c0                	test   %eax,%eax
  80331a:	78 52                	js     80336e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80331c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80331f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803326:	8b 00                	mov    (%eax),%eax
  803328:	89 04 24             	mov    %eax,(%esp)
  80332b:	e8 70 fb ff ff       	call   802ea0 <dev_lookup>
  803330:	85 c0                	test   %eax,%eax
  803332:	78 3a                	js     80336e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  803334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803337:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80333b:	74 2c                	je     803369 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80333d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803340:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803347:	00 00 00 
	stat->st_isdir = 0;
  80334a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803351:	00 00 00 
	stat->st_dev = dev;
  803354:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80335a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80335e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803361:	89 14 24             	mov    %edx,(%esp)
  803364:	ff 50 14             	call   *0x14(%eax)
  803367:	eb 05                	jmp    80336e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803369:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80336e:	83 c4 24             	add    $0x24,%esp
  803371:	5b                   	pop    %ebx
  803372:	5d                   	pop    %ebp
  803373:	c3                   	ret    

00803374 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803374:	55                   	push   %ebp
  803375:	89 e5                	mov    %esp,%ebp
  803377:	56                   	push   %esi
  803378:	53                   	push   %ebx
  803379:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80337c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803383:	00 
  803384:	8b 45 08             	mov    0x8(%ebp),%eax
  803387:	89 04 24             	mov    %eax,(%esp)
  80338a:	e8 59 f9 ff ff       	call   802ce8 <open>
  80338f:	89 c3                	mov    %eax,%ebx
  803391:	85 c0                	test   %eax,%eax
  803393:	78 1b                	js     8033b0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  803395:	8b 45 0c             	mov    0xc(%ebp),%eax
  803398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80339c:	89 1c 24             	mov    %ebx,(%esp)
  80339f:	e8 58 ff ff ff       	call   8032fc <fstat>
  8033a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8033a6:	89 1c 24             	mov    %ebx,(%esp)
  8033a9:	e8 d4 fb ff ff       	call   802f82 <close>
	return r;
  8033ae:	89 f3                	mov    %esi,%ebx
}
  8033b0:	89 d8                	mov    %ebx,%eax
  8033b2:	83 c4 10             	add    $0x10,%esp
  8033b5:	5b                   	pop    %ebx
  8033b6:	5e                   	pop    %esi
  8033b7:	5d                   	pop    %ebp
  8033b8:	c3                   	ret    
  8033b9:	00 00                	add    %al,(%eax)
	...

008033bc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8033bc:	55                   	push   %ebp
  8033bd:	89 e5                	mov    %esp,%ebp
  8033bf:	56                   	push   %esi
  8033c0:	53                   	push   %ebx
  8033c1:	83 ec 10             	sub    $0x10,%esp
  8033c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8033c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8033ca:	89 04 24             	mov    %eax,(%esp)
  8033cd:	e8 0a fa ff ff       	call   802ddc <fd2data>
  8033d2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8033d4:	c7 44 24 04 90 45 80 	movl   $0x804590,0x4(%esp)
  8033db:	00 
  8033dc:	89 34 24             	mov    %esi,(%esp)
  8033df:	e8 f3 ee ff ff       	call   8022d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8033e4:	8b 43 04             	mov    0x4(%ebx),%eax
  8033e7:	2b 03                	sub    (%ebx),%eax
  8033e9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8033ef:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8033f6:	00 00 00 
	stat->st_dev = &devpipe;
  8033f9:	c7 86 88 00 00 00 80 	movl   $0x809080,0x88(%esi)
  803400:	90 80 00 
	return 0;
}
  803403:	b8 00 00 00 00       	mov    $0x0,%eax
  803408:	83 c4 10             	add    $0x10,%esp
  80340b:	5b                   	pop    %ebx
  80340c:	5e                   	pop    %esi
  80340d:	5d                   	pop    %ebp
  80340e:	c3                   	ret    

0080340f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80340f:	55                   	push   %ebp
  803410:	89 e5                	mov    %esp,%ebp
  803412:	53                   	push   %ebx
  803413:	83 ec 14             	sub    $0x14,%esp
  803416:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803419:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80341d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803424:	e8 47 f3 ff ff       	call   802770 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803429:	89 1c 24             	mov    %ebx,(%esp)
  80342c:	e8 ab f9 ff ff       	call   802ddc <fd2data>
  803431:	89 44 24 04          	mov    %eax,0x4(%esp)
  803435:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80343c:	e8 2f f3 ff ff       	call   802770 <sys_page_unmap>
}
  803441:	83 c4 14             	add    $0x14,%esp
  803444:	5b                   	pop    %ebx
  803445:	5d                   	pop    %ebp
  803446:	c3                   	ret    

00803447 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803447:	55                   	push   %ebp
  803448:	89 e5                	mov    %esp,%ebp
  80344a:	57                   	push   %edi
  80344b:	56                   	push   %esi
  80344c:	53                   	push   %ebx
  80344d:	83 ec 2c             	sub    $0x2c,%esp
  803450:	89 c7                	mov    %eax,%edi
  803452:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803455:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80345a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80345d:	89 3c 24             	mov    %edi,(%esp)
  803460:	e8 23 f9 ff ff       	call   802d88 <pageref>
  803465:	89 c6                	mov    %eax,%esi
  803467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80346a:	89 04 24             	mov    %eax,(%esp)
  80346d:	e8 16 f9 ff ff       	call   802d88 <pageref>
  803472:	39 c6                	cmp    %eax,%esi
  803474:	0f 94 c0             	sete   %al
  803477:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80347a:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803480:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803483:	39 cb                	cmp    %ecx,%ebx
  803485:	75 08                	jne    80348f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  803487:	83 c4 2c             	add    $0x2c,%esp
  80348a:	5b                   	pop    %ebx
  80348b:	5e                   	pop    %esi
  80348c:	5f                   	pop    %edi
  80348d:	5d                   	pop    %ebp
  80348e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80348f:	83 f8 01             	cmp    $0x1,%eax
  803492:	75 c1                	jne    803455 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803494:	8b 42 58             	mov    0x58(%edx),%eax
  803497:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80349e:	00 
  80349f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8034a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8034a7:	c7 04 24 97 45 80 00 	movl   $0x804597,(%esp)
  8034ae:	e8 79 e8 ff ff       	call   801d2c <cprintf>
  8034b3:	eb a0                	jmp    803455 <_pipeisclosed+0xe>

008034b5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8034b5:	55                   	push   %ebp
  8034b6:	89 e5                	mov    %esp,%ebp
  8034b8:	57                   	push   %edi
  8034b9:	56                   	push   %esi
  8034ba:	53                   	push   %ebx
  8034bb:	83 ec 1c             	sub    $0x1c,%esp
  8034be:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8034c1:	89 34 24             	mov    %esi,(%esp)
  8034c4:	e8 13 f9 ff ff       	call   802ddc <fd2data>
  8034c9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8034cb:	bf 00 00 00 00       	mov    $0x0,%edi
  8034d0:	eb 3c                	jmp    80350e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8034d2:	89 da                	mov    %ebx,%edx
  8034d4:	89 f0                	mov    %esi,%eax
  8034d6:	e8 6c ff ff ff       	call   803447 <_pipeisclosed>
  8034db:	85 c0                	test   %eax,%eax
  8034dd:	75 38                	jne    803517 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8034df:	e8 c6 f1 ff ff       	call   8026aa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8034e4:	8b 43 04             	mov    0x4(%ebx),%eax
  8034e7:	8b 13                	mov    (%ebx),%edx
  8034e9:	83 c2 20             	add    $0x20,%edx
  8034ec:	39 d0                	cmp    %edx,%eax
  8034ee:	73 e2                	jae    8034d2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8034f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8034f3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8034f6:	89 c2                	mov    %eax,%edx
  8034f8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8034fe:	79 05                	jns    803505 <devpipe_write+0x50>
  803500:	4a                   	dec    %edx
  803501:	83 ca e0             	or     $0xffffffe0,%edx
  803504:	42                   	inc    %edx
  803505:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803509:	40                   	inc    %eax
  80350a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80350d:	47                   	inc    %edi
  80350e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803511:	75 d1                	jne    8034e4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803513:	89 f8                	mov    %edi,%eax
  803515:	eb 05                	jmp    80351c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803517:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80351c:	83 c4 1c             	add    $0x1c,%esp
  80351f:	5b                   	pop    %ebx
  803520:	5e                   	pop    %esi
  803521:	5f                   	pop    %edi
  803522:	5d                   	pop    %ebp
  803523:	c3                   	ret    

00803524 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803524:	55                   	push   %ebp
  803525:	89 e5                	mov    %esp,%ebp
  803527:	57                   	push   %edi
  803528:	56                   	push   %esi
  803529:	53                   	push   %ebx
  80352a:	83 ec 1c             	sub    $0x1c,%esp
  80352d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803530:	89 3c 24             	mov    %edi,(%esp)
  803533:	e8 a4 f8 ff ff       	call   802ddc <fd2data>
  803538:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80353a:	be 00 00 00 00       	mov    $0x0,%esi
  80353f:	eb 3a                	jmp    80357b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803541:	85 f6                	test   %esi,%esi
  803543:	74 04                	je     803549 <devpipe_read+0x25>
				return i;
  803545:	89 f0                	mov    %esi,%eax
  803547:	eb 40                	jmp    803589 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803549:	89 da                	mov    %ebx,%edx
  80354b:	89 f8                	mov    %edi,%eax
  80354d:	e8 f5 fe ff ff       	call   803447 <_pipeisclosed>
  803552:	85 c0                	test   %eax,%eax
  803554:	75 2e                	jne    803584 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803556:	e8 4f f1 ff ff       	call   8026aa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80355b:	8b 03                	mov    (%ebx),%eax
  80355d:	3b 43 04             	cmp    0x4(%ebx),%eax
  803560:	74 df                	je     803541 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803562:	25 1f 00 00 80       	and    $0x8000001f,%eax
  803567:	79 05                	jns    80356e <devpipe_read+0x4a>
  803569:	48                   	dec    %eax
  80356a:	83 c8 e0             	or     $0xffffffe0,%eax
  80356d:	40                   	inc    %eax
  80356e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  803572:	8b 55 0c             	mov    0xc(%ebp),%edx
  803575:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  803578:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80357a:	46                   	inc    %esi
  80357b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80357e:	75 db                	jne    80355b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803580:	89 f0                	mov    %esi,%eax
  803582:	eb 05                	jmp    803589 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803584:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803589:	83 c4 1c             	add    $0x1c,%esp
  80358c:	5b                   	pop    %ebx
  80358d:	5e                   	pop    %esi
  80358e:	5f                   	pop    %edi
  80358f:	5d                   	pop    %ebp
  803590:	c3                   	ret    

00803591 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803591:	55                   	push   %ebp
  803592:	89 e5                	mov    %esp,%ebp
  803594:	57                   	push   %edi
  803595:	56                   	push   %esi
  803596:	53                   	push   %ebx
  803597:	83 ec 3c             	sub    $0x3c,%esp
  80359a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80359d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8035a0:	89 04 24             	mov    %eax,(%esp)
  8035a3:	e8 4f f8 ff ff       	call   802df7 <fd_alloc>
  8035a8:	89 c3                	mov    %eax,%ebx
  8035aa:	85 c0                	test   %eax,%eax
  8035ac:	0f 88 45 01 00 00    	js     8036f7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8035b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8035b9:	00 
  8035ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035c8:	e8 fc f0 ff ff       	call   8026c9 <sys_page_alloc>
  8035cd:	89 c3                	mov    %eax,%ebx
  8035cf:	85 c0                	test   %eax,%eax
  8035d1:	0f 88 20 01 00 00    	js     8036f7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8035d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8035da:	89 04 24             	mov    %eax,(%esp)
  8035dd:	e8 15 f8 ff ff       	call   802df7 <fd_alloc>
  8035e2:	89 c3                	mov    %eax,%ebx
  8035e4:	85 c0                	test   %eax,%eax
  8035e6:	0f 88 f8 00 00 00    	js     8036e4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8035ec:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8035f3:	00 
  8035f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803602:	e8 c2 f0 ff ff       	call   8026c9 <sys_page_alloc>
  803607:	89 c3                	mov    %eax,%ebx
  803609:	85 c0                	test   %eax,%eax
  80360b:	0f 88 d3 00 00 00    	js     8036e4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803614:	89 04 24             	mov    %eax,(%esp)
  803617:	e8 c0 f7 ff ff       	call   802ddc <fd2data>
  80361c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80361e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803625:	00 
  803626:	89 44 24 04          	mov    %eax,0x4(%esp)
  80362a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803631:	e8 93 f0 ff ff       	call   8026c9 <sys_page_alloc>
  803636:	89 c3                	mov    %eax,%ebx
  803638:	85 c0                	test   %eax,%eax
  80363a:	0f 88 91 00 00 00    	js     8036d1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803640:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803643:	89 04 24             	mov    %eax,(%esp)
  803646:	e8 91 f7 ff ff       	call   802ddc <fd2data>
  80364b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803652:	00 
  803653:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803657:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80365e:	00 
  80365f:	89 74 24 04          	mov    %esi,0x4(%esp)
  803663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80366a:	e8 ae f0 ff ff       	call   80271d <sys_page_map>
  80366f:	89 c3                	mov    %eax,%ebx
  803671:	85 c0                	test   %eax,%eax
  803673:	78 4c                	js     8036c1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803675:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80367b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80367e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803680:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803683:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80368a:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803690:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803693:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803695:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803698:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80369f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8036a2:	89 04 24             	mov    %eax,(%esp)
  8036a5:	e8 22 f7 ff ff       	call   802dcc <fd2num>
  8036aa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8036ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8036af:	89 04 24             	mov    %eax,(%esp)
  8036b2:	e8 15 f7 ff ff       	call   802dcc <fd2num>
  8036b7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8036ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8036bf:	eb 36                	jmp    8036f7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8036c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8036c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036cc:	e8 9f f0 ff ff       	call   802770 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8036d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8036d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036df:	e8 8c f0 ff ff       	call   802770 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8036e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8036e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036f2:	e8 79 f0 ff ff       	call   802770 <sys_page_unmap>
    err:
	return r;
}
  8036f7:	89 d8                	mov    %ebx,%eax
  8036f9:	83 c4 3c             	add    $0x3c,%esp
  8036fc:	5b                   	pop    %ebx
  8036fd:	5e                   	pop    %esi
  8036fe:	5f                   	pop    %edi
  8036ff:	5d                   	pop    %ebp
  803700:	c3                   	ret    

00803701 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803701:	55                   	push   %ebp
  803702:	89 e5                	mov    %esp,%ebp
  803704:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803707:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80370a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80370e:	8b 45 08             	mov    0x8(%ebp),%eax
  803711:	89 04 24             	mov    %eax,(%esp)
  803714:	e8 31 f7 ff ff       	call   802e4a <fd_lookup>
  803719:	85 c0                	test   %eax,%eax
  80371b:	78 15                	js     803732 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80371d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803720:	89 04 24             	mov    %eax,(%esp)
  803723:	e8 b4 f6 ff ff       	call   802ddc <fd2data>
	return _pipeisclosed(fd, p);
  803728:	89 c2                	mov    %eax,%edx
  80372a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80372d:	e8 15 fd ff ff       	call   803447 <_pipeisclosed>
}
  803732:	c9                   	leave  
  803733:	c3                   	ret    

00803734 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803734:	55                   	push   %ebp
  803735:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803737:	b8 00 00 00 00       	mov    $0x0,%eax
  80373c:	5d                   	pop    %ebp
  80373d:	c3                   	ret    

0080373e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80373e:	55                   	push   %ebp
  80373f:	89 e5                	mov    %esp,%ebp
  803741:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  803744:	c7 44 24 04 af 45 80 	movl   $0x8045af,0x4(%esp)
  80374b:	00 
  80374c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80374f:	89 04 24             	mov    %eax,(%esp)
  803752:	e8 80 eb ff ff       	call   8022d7 <strcpy>
	return 0;
}
  803757:	b8 00 00 00 00       	mov    $0x0,%eax
  80375c:	c9                   	leave  
  80375d:	c3                   	ret    

0080375e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80375e:	55                   	push   %ebp
  80375f:	89 e5                	mov    %esp,%ebp
  803761:	57                   	push   %edi
  803762:	56                   	push   %esi
  803763:	53                   	push   %ebx
  803764:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80376a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80376f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803775:	eb 30                	jmp    8037a7 <devcons_write+0x49>
		m = n - tot;
  803777:	8b 75 10             	mov    0x10(%ebp),%esi
  80377a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80377c:	83 fe 7f             	cmp    $0x7f,%esi
  80377f:	76 05                	jbe    803786 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  803781:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803786:	89 74 24 08          	mov    %esi,0x8(%esp)
  80378a:	03 45 0c             	add    0xc(%ebp),%eax
  80378d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803791:	89 3c 24             	mov    %edi,(%esp)
  803794:	e8 b7 ec ff ff       	call   802450 <memmove>
		sys_cputs(buf, m);
  803799:	89 74 24 04          	mov    %esi,0x4(%esp)
  80379d:	89 3c 24             	mov    %edi,(%esp)
  8037a0:	e8 57 ee ff ff       	call   8025fc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037a5:	01 f3                	add    %esi,%ebx
  8037a7:	89 d8                	mov    %ebx,%eax
  8037a9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8037ac:	72 c9                	jb     803777 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8037ae:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8037b4:	5b                   	pop    %ebx
  8037b5:	5e                   	pop    %esi
  8037b6:	5f                   	pop    %edi
  8037b7:	5d                   	pop    %ebp
  8037b8:	c3                   	ret    

008037b9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8037b9:	55                   	push   %ebp
  8037ba:	89 e5                	mov    %esp,%ebp
  8037bc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8037bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8037c3:	75 07                	jne    8037cc <devcons_read+0x13>
  8037c5:	eb 25                	jmp    8037ec <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8037c7:	e8 de ee ff ff       	call   8026aa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8037cc:	e8 49 ee ff ff       	call   80261a <sys_cgetc>
  8037d1:	85 c0                	test   %eax,%eax
  8037d3:	74 f2                	je     8037c7 <devcons_read+0xe>
  8037d5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8037d7:	85 c0                	test   %eax,%eax
  8037d9:	78 1d                	js     8037f8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8037db:	83 f8 04             	cmp    $0x4,%eax
  8037de:	74 13                	je     8037f3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8037e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037e3:	88 10                	mov    %dl,(%eax)
	return 1;
  8037e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8037ea:	eb 0c                	jmp    8037f8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8037ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8037f1:	eb 05                	jmp    8037f8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8037f3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8037f8:	c9                   	leave  
  8037f9:	c3                   	ret    

008037fa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8037fa:	55                   	push   %ebp
  8037fb:	89 e5                	mov    %esp,%ebp
  8037fd:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803800:	8b 45 08             	mov    0x8(%ebp),%eax
  803803:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803806:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80380d:	00 
  80380e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803811:	89 04 24             	mov    %eax,(%esp)
  803814:	e8 e3 ed ff ff       	call   8025fc <sys_cputs>
}
  803819:	c9                   	leave  
  80381a:	c3                   	ret    

0080381b <getchar>:

int
getchar(void)
{
  80381b:	55                   	push   %ebp
  80381c:	89 e5                	mov    %esp,%ebp
  80381e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803821:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803828:	00 
  803829:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80382c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803830:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803837:	e8 aa f8 ff ff       	call   8030e6 <read>
	if (r < 0)
  80383c:	85 c0                	test   %eax,%eax
  80383e:	78 0f                	js     80384f <getchar+0x34>
		return r;
	if (r < 1)
  803840:	85 c0                	test   %eax,%eax
  803842:	7e 06                	jle    80384a <getchar+0x2f>
		return -E_EOF;
	return c;
  803844:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803848:	eb 05                	jmp    80384f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80384a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80384f:	c9                   	leave  
  803850:	c3                   	ret    

00803851 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803851:	55                   	push   %ebp
  803852:	89 e5                	mov    %esp,%ebp
  803854:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803857:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80385a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80385e:	8b 45 08             	mov    0x8(%ebp),%eax
  803861:	89 04 24             	mov    %eax,(%esp)
  803864:	e8 e1 f5 ff ff       	call   802e4a <fd_lookup>
  803869:	85 c0                	test   %eax,%eax
  80386b:	78 11                	js     80387e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80386d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803870:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803876:	39 10                	cmp    %edx,(%eax)
  803878:	0f 94 c0             	sete   %al
  80387b:	0f b6 c0             	movzbl %al,%eax
}
  80387e:	c9                   	leave  
  80387f:	c3                   	ret    

00803880 <opencons>:

int
opencons(void)
{
  803880:	55                   	push   %ebp
  803881:	89 e5                	mov    %esp,%ebp
  803883:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803886:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803889:	89 04 24             	mov    %eax,(%esp)
  80388c:	e8 66 f5 ff ff       	call   802df7 <fd_alloc>
  803891:	85 c0                	test   %eax,%eax
  803893:	78 3c                	js     8038d1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803895:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80389c:	00 
  80389d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8038ab:	e8 19 ee ff ff       	call   8026c9 <sys_page_alloc>
  8038b0:	85 c0                	test   %eax,%eax
  8038b2:	78 1d                	js     8038d1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8038b4:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8038ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8038bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8038c9:	89 04 24             	mov    %eax,(%esp)
  8038cc:	e8 fb f4 ff ff       	call   802dcc <fd2num>
}
  8038d1:	c9                   	leave  
  8038d2:	c3                   	ret    
	...

008038d4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8038d4:	55                   	push   %ebp
  8038d5:	57                   	push   %edi
  8038d6:	56                   	push   %esi
  8038d7:	83 ec 10             	sub    $0x10,%esp
  8038da:	8b 74 24 20          	mov    0x20(%esp),%esi
  8038de:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8038e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8038e6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8038ea:	89 cd                	mov    %ecx,%ebp
  8038ec:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8038f0:	85 c0                	test   %eax,%eax
  8038f2:	75 2c                	jne    803920 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8038f4:	39 f9                	cmp    %edi,%ecx
  8038f6:	77 68                	ja     803960 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8038f8:	85 c9                	test   %ecx,%ecx
  8038fa:	75 0b                	jne    803907 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8038fc:	b8 01 00 00 00       	mov    $0x1,%eax
  803901:	31 d2                	xor    %edx,%edx
  803903:	f7 f1                	div    %ecx
  803905:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803907:	31 d2                	xor    %edx,%edx
  803909:	89 f8                	mov    %edi,%eax
  80390b:	f7 f1                	div    %ecx
  80390d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80390f:	89 f0                	mov    %esi,%eax
  803911:	f7 f1                	div    %ecx
  803913:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803915:	89 f0                	mov    %esi,%eax
  803917:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803919:	83 c4 10             	add    $0x10,%esp
  80391c:	5e                   	pop    %esi
  80391d:	5f                   	pop    %edi
  80391e:	5d                   	pop    %ebp
  80391f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803920:	39 f8                	cmp    %edi,%eax
  803922:	77 2c                	ja     803950 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803924:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  803927:	83 f6 1f             	xor    $0x1f,%esi
  80392a:	75 4c                	jne    803978 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80392c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80392e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803933:	72 0a                	jb     80393f <__udivdi3+0x6b>
  803935:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803939:	0f 87 ad 00 00 00    	ja     8039ec <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80393f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803944:	89 f0                	mov    %esi,%eax
  803946:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803948:	83 c4 10             	add    $0x10,%esp
  80394b:	5e                   	pop    %esi
  80394c:	5f                   	pop    %edi
  80394d:	5d                   	pop    %ebp
  80394e:	c3                   	ret    
  80394f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803950:	31 ff                	xor    %edi,%edi
  803952:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803954:	89 f0                	mov    %esi,%eax
  803956:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803958:	83 c4 10             	add    $0x10,%esp
  80395b:	5e                   	pop    %esi
  80395c:	5f                   	pop    %edi
  80395d:	5d                   	pop    %ebp
  80395e:	c3                   	ret    
  80395f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803960:	89 fa                	mov    %edi,%edx
  803962:	89 f0                	mov    %esi,%eax
  803964:	f7 f1                	div    %ecx
  803966:	89 c6                	mov    %eax,%esi
  803968:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80396a:	89 f0                	mov    %esi,%eax
  80396c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80396e:	83 c4 10             	add    $0x10,%esp
  803971:	5e                   	pop    %esi
  803972:	5f                   	pop    %edi
  803973:	5d                   	pop    %ebp
  803974:	c3                   	ret    
  803975:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803978:	89 f1                	mov    %esi,%ecx
  80397a:	d3 e0                	shl    %cl,%eax
  80397c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803980:	b8 20 00 00 00       	mov    $0x20,%eax
  803985:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  803987:	89 ea                	mov    %ebp,%edx
  803989:	88 c1                	mov    %al,%cl
  80398b:	d3 ea                	shr    %cl,%edx
  80398d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803991:	09 ca                	or     %ecx,%edx
  803993:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  803997:	89 f1                	mov    %esi,%ecx
  803999:	d3 e5                	shl    %cl,%ebp
  80399b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80399f:	89 fd                	mov    %edi,%ebp
  8039a1:	88 c1                	mov    %al,%cl
  8039a3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8039a5:	89 fa                	mov    %edi,%edx
  8039a7:	89 f1                	mov    %esi,%ecx
  8039a9:	d3 e2                	shl    %cl,%edx
  8039ab:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8039af:	88 c1                	mov    %al,%cl
  8039b1:	d3 ef                	shr    %cl,%edi
  8039b3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8039b5:	89 f8                	mov    %edi,%eax
  8039b7:	89 ea                	mov    %ebp,%edx
  8039b9:	f7 74 24 08          	divl   0x8(%esp)
  8039bd:	89 d1                	mov    %edx,%ecx
  8039bf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8039c1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8039c5:	39 d1                	cmp    %edx,%ecx
  8039c7:	72 17                	jb     8039e0 <__udivdi3+0x10c>
  8039c9:	74 09                	je     8039d4 <__udivdi3+0x100>
  8039cb:	89 fe                	mov    %edi,%esi
  8039cd:	31 ff                	xor    %edi,%edi
  8039cf:	e9 41 ff ff ff       	jmp    803915 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8039d4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8039d8:	89 f1                	mov    %esi,%ecx
  8039da:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8039dc:	39 c2                	cmp    %eax,%edx
  8039de:	73 eb                	jae    8039cb <__udivdi3+0xf7>
		{
		  q0--;
  8039e0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8039e3:	31 ff                	xor    %edi,%edi
  8039e5:	e9 2b ff ff ff       	jmp    803915 <__udivdi3+0x41>
  8039ea:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8039ec:	31 f6                	xor    %esi,%esi
  8039ee:	e9 22 ff ff ff       	jmp    803915 <__udivdi3+0x41>
	...

008039f4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8039f4:	55                   	push   %ebp
  8039f5:	57                   	push   %edi
  8039f6:	56                   	push   %esi
  8039f7:	83 ec 20             	sub    $0x20,%esp
  8039fa:	8b 44 24 30          	mov    0x30(%esp),%eax
  8039fe:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803a02:	89 44 24 14          	mov    %eax,0x14(%esp)
  803a06:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  803a0a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a0e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  803a12:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  803a14:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803a16:	85 ed                	test   %ebp,%ebp
  803a18:	75 16                	jne    803a30 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  803a1a:	39 f1                	cmp    %esi,%ecx
  803a1c:	0f 86 a6 00 00 00    	jbe    803ac8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803a22:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803a24:	89 d0                	mov    %edx,%eax
  803a26:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803a28:	83 c4 20             	add    $0x20,%esp
  803a2b:	5e                   	pop    %esi
  803a2c:	5f                   	pop    %edi
  803a2d:	5d                   	pop    %ebp
  803a2e:	c3                   	ret    
  803a2f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803a30:	39 f5                	cmp    %esi,%ebp
  803a32:	0f 87 ac 00 00 00    	ja     803ae4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803a38:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  803a3b:	83 f0 1f             	xor    $0x1f,%eax
  803a3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  803a42:	0f 84 a8 00 00 00    	je     803af0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803a48:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a4c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803a4e:	bf 20 00 00 00       	mov    $0x20,%edi
  803a53:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803a57:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803a5b:	89 f9                	mov    %edi,%ecx
  803a5d:	d3 e8                	shr    %cl,%eax
  803a5f:	09 e8                	or     %ebp,%eax
  803a61:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803a65:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803a69:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a6d:	d3 e0                	shl    %cl,%eax
  803a6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803a73:	89 f2                	mov    %esi,%edx
  803a75:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803a77:	8b 44 24 14          	mov    0x14(%esp),%eax
  803a7b:	d3 e0                	shl    %cl,%eax
  803a7d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803a81:	8b 44 24 14          	mov    0x14(%esp),%eax
  803a85:	89 f9                	mov    %edi,%ecx
  803a87:	d3 e8                	shr    %cl,%eax
  803a89:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  803a8b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803a8d:	89 f2                	mov    %esi,%edx
  803a8f:	f7 74 24 18          	divl   0x18(%esp)
  803a93:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803a95:	f7 64 24 0c          	mull   0xc(%esp)
  803a99:	89 c5                	mov    %eax,%ebp
  803a9b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803a9d:	39 d6                	cmp    %edx,%esi
  803a9f:	72 67                	jb     803b08 <__umoddi3+0x114>
  803aa1:	74 75                	je     803b18 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803aa3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803aa7:	29 e8                	sub    %ebp,%eax
  803aa9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803aab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803aaf:	d3 e8                	shr    %cl,%eax
  803ab1:	89 f2                	mov    %esi,%edx
  803ab3:	89 f9                	mov    %edi,%ecx
  803ab5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803ab7:	09 d0                	or     %edx,%eax
  803ab9:	89 f2                	mov    %esi,%edx
  803abb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803abf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803ac1:	83 c4 20             	add    $0x20,%esp
  803ac4:	5e                   	pop    %esi
  803ac5:	5f                   	pop    %edi
  803ac6:	5d                   	pop    %ebp
  803ac7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803ac8:	85 c9                	test   %ecx,%ecx
  803aca:	75 0b                	jne    803ad7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803acc:	b8 01 00 00 00       	mov    $0x1,%eax
  803ad1:	31 d2                	xor    %edx,%edx
  803ad3:	f7 f1                	div    %ecx
  803ad5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803ad7:	89 f0                	mov    %esi,%eax
  803ad9:	31 d2                	xor    %edx,%edx
  803adb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803add:	89 f8                	mov    %edi,%eax
  803adf:	e9 3e ff ff ff       	jmp    803a22 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  803ae4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803ae6:	83 c4 20             	add    $0x20,%esp
  803ae9:	5e                   	pop    %esi
  803aea:	5f                   	pop    %edi
  803aeb:	5d                   	pop    %ebp
  803aec:	c3                   	ret    
  803aed:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803af0:	39 f5                	cmp    %esi,%ebp
  803af2:	72 04                	jb     803af8 <__umoddi3+0x104>
  803af4:	39 f9                	cmp    %edi,%ecx
  803af6:	77 06                	ja     803afe <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803af8:	89 f2                	mov    %esi,%edx
  803afa:	29 cf                	sub    %ecx,%edi
  803afc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  803afe:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803b00:	83 c4 20             	add    $0x20,%esp
  803b03:	5e                   	pop    %esi
  803b04:	5f                   	pop    %edi
  803b05:	5d                   	pop    %ebp
  803b06:	c3                   	ret    
  803b07:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803b08:	89 d1                	mov    %edx,%ecx
  803b0a:	89 c5                	mov    %eax,%ebp
  803b0c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803b10:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803b14:	eb 8d                	jmp    803aa3 <__umoddi3+0xaf>
  803b16:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803b18:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803b1c:	72 ea                	jb     803b08 <__umoddi3+0x114>
  803b1e:	89 f1                	mov    %esi,%ecx
  803b20:	eb 81                	jmp    803aa3 <__umoddi3+0xaf>
