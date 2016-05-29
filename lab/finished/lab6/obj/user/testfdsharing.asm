
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 eb 01 00 00       	call   80021c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800044:	00 
  800045:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  80004c:	e8 97 1b 00 00       	call   801be8 <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 45 2b 80 	movl   $0x802b45,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 53 2b 80 00 	movl   $0x802b53,(%esp)
  800072:	e8 01 02 00 00       	call   800278 <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 f1 17 00 00       	call   801878 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 52 80 	movl   $0x805220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 03 17 00 00       	call   8017a2 <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 68 2b 80 	movl   $0x802b68,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 53 2b 80 00 	movl   $0x802b53,(%esp)
  8000c0:	e8 b3 01 00 00       	call   800278 <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 3d 10 00 00       	call   801107 <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 72 2b 80 	movl   $0x802b72,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 53 2b 80 00 	movl   $0x802b53,(%esp)
  8000eb:	e8 88 01 00 00       	call   800278 <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 70 17 00 00       	call   801878 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 b0 2b 80 00 	movl   $0x802bb0,(%esp)
  80010f:	e8 5c 02 00 00       	call   800370 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 76 16 00 00       	call   8017a2 <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 f4 2b 80 	movl   $0x802bf4,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 53 2b 80 00 	movl   $0x802b53,(%esp)
  80014f:	e8 24 01 00 00       	call   800278 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 52 80 00 	movl   $0x805220,(%esp)
  800167:	e8 b3 09 00 00       	call   800b1f <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 53 2b 80 00 	movl   $0x802b53,(%esp)
  800187:	e8 ec 00 00 00       	call   800278 <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 7b 2b 80 00 	movl   $0x802b7b,(%esp)
  800193:	e8 d8 01 00 00       	call   800370 <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 d0 16 00 00       	call   801878 <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 fe 13 00 00       	call   8015ae <close>
		exit();
  8001b0:	e8 af 00 00 00       	call   800264 <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 3f 23 00 00       	call   8024fc <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 cd 15 00 00       	call   8017a2 <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 58 2c 80 	movl   $0x802c58,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 53 2b 80 00 	movl   $0x802b53,(%esp)
  8001f8:	e8 7b 00 00 00       	call   800278 <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 94 2b 80 00 	movl   $0x802b94,(%esp)
  800204:	e8 67 01 00 00       	call   800370 <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 9d 13 00 00       	call   8015ae <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800211:	cc                   	int3   

	breakpoint();
}
  800212:	83 c4 2c             	add    $0x2c,%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
	...

0080021c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 10             	sub    $0x10,%esp
  800224:	8b 75 08             	mov    0x8(%ebp),%esi
  800227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80022a:	e8 a0 0a 00 00       	call   800ccf <sys_getenvid>
  80022f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800234:	c1 e0 07             	shl    $0x7,%eax
  800237:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80023c:	a3 20 54 80 00       	mov    %eax,0x805420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800241:	85 f6                	test   %esi,%esi
  800243:	7e 07                	jle    80024c <libmain+0x30>
		binaryname = argv[0];
  800245:	8b 03                	mov    (%ebx),%eax
  800247:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80024c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800250:	89 34 24             	mov    %esi,(%esp)
  800253:	e8 dc fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800258:	e8 07 00 00 00       	call   800264 <exit>
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80026a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800271:	e8 07 0a 00 00       	call   800c7d <sys_env_destroy>
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800280:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800283:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800289:	e8 41 0a 00 00       	call   800ccf <sys_getenvid>
  80028e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800291:	89 54 24 10          	mov    %edx,0x10(%esp)
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80029c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a4:	c7 04 24 88 2c 80 00 	movl   $0x802c88,(%esp)
  8002ab:	e8 c0 00 00 00       	call   800370 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	e8 50 00 00 00       	call   80030f <vcprintf>
	cprintf("\n");
  8002bf:	c7 04 24 92 2b 80 00 	movl   $0x802b92,(%esp)
  8002c6:	e8 a5 00 00 00       	call   800370 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002cb:	cc                   	int3   
  8002cc:	eb fd                	jmp    8002cb <_panic+0x53>
	...

008002d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 14             	sub    $0x14,%esp
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002da:	8b 03                	mov    (%ebx),%eax
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002e3:	40                   	inc    %eax
  8002e4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002eb:	75 19                	jne    800306 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002ed:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002f4:	00 
  8002f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 40 09 00 00       	call   800c40 <sys_cputs>
		b->idx = 0;
  800300:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800306:	ff 43 04             	incl   0x4(%ebx)
}
  800309:	83 c4 14             	add    $0x14,%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800318:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80031f:	00 00 00 
	b.cnt = 0;
  800322:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800329:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80032c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800333:	8b 45 08             	mov    0x8(%ebp),%eax
  800336:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800340:	89 44 24 04          	mov    %eax,0x4(%esp)
  800344:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  80034b:	e8 82 01 00 00       	call   8004d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800350:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	e8 d8 08 00 00       	call   800c40 <sys_cputs>

	return b.cnt;
}
  800368:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800376:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	e8 87 ff ff ff       	call   80030f <vcprintf>
	va_end(ap);

	return cnt;
}
  800388:	c9                   	leave  
  800389:	c3                   	ret    
	...

0080038c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 3c             	sub    $0x3c,%esp
  800395:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800398:	89 d7                	mov    %edx,%edi
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003a9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	75 08                	jne    8003b8 <printnum+0x2c>
  8003b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b6:	77 57                	ja     80040f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003bc:	4b                   	dec    %ebx
  8003bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003cc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d7:	00 
  8003d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	e8 fe 24 00 00       	call   8028e8 <__udivdi3>
  8003ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003f2:	89 04 24             	mov    %eax,(%esp)
  8003f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003f9:	89 fa                	mov    %edi,%edx
  8003fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003fe:	e8 89 ff ff ff       	call   80038c <printnum>
  800403:	eb 0f                	jmp    800414 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800405:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800409:	89 34 24             	mov    %esi,(%esp)
  80040c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80040f:	4b                   	dec    %ebx
  800410:	85 db                	test   %ebx,%ebx
  800412:	7f f1                	jg     800405 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800414:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800418:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80041c:	8b 45 10             	mov    0x10(%ebp),%eax
  80041f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800423:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80042a:	00 
  80042b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80042e:	89 04 24             	mov    %eax,(%esp)
  800431:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800434:	89 44 24 04          	mov    %eax,0x4(%esp)
  800438:	e8 cb 25 00 00       	call   802a08 <__umoddi3>
  80043d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800441:	0f be 80 ab 2c 80 00 	movsbl 0x802cab(%eax),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80044e:	83 c4 3c             	add    $0x3c,%esp
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    

00800456 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800456:	55                   	push   %ebp
  800457:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800459:	83 fa 01             	cmp    $0x1,%edx
  80045c:	7e 0e                	jle    80046c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80045e:	8b 10                	mov    (%eax),%edx
  800460:	8d 4a 08             	lea    0x8(%edx),%ecx
  800463:	89 08                	mov    %ecx,(%eax)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	8b 52 04             	mov    0x4(%edx),%edx
  80046a:	eb 22                	jmp    80048e <getuint+0x38>
	else if (lflag)
  80046c:	85 d2                	test   %edx,%edx
  80046e:	74 10                	je     800480 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	eb 0e                	jmp    80048e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800480:	8b 10                	mov    (%eax),%edx
  800482:	8d 4a 04             	lea    0x4(%edx),%ecx
  800485:	89 08                	mov    %ecx,(%eax)
  800487:	8b 02                	mov    (%edx),%eax
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800496:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800499:	8b 10                	mov    (%eax),%edx
  80049b:	3b 50 04             	cmp    0x4(%eax),%edx
  80049e:	73 08                	jae    8004a8 <sprintputch+0x18>
		*b->buf++ = ch;
  8004a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a3:	88 0a                	mov    %cl,(%edx)
  8004a5:	42                   	inc    %edx
  8004a6:	89 10                	mov    %edx,(%eax)
}
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    

008004aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 02 00 00 00       	call   8004d2 <vprintfmt>
	va_end(ap);
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    

008004d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	57                   	push   %edi
  8004d6:	56                   	push   %esi
  8004d7:	53                   	push   %ebx
  8004d8:	83 ec 4c             	sub    $0x4c,%esp
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004de:	8b 75 10             	mov    0x10(%ebp),%esi
  8004e1:	eb 12                	jmp    8004f5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	0f 84 6b 03 00 00    	je     800856 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f5:	0f b6 06             	movzbl (%esi),%eax
  8004f8:	46                   	inc    %esi
  8004f9:	83 f8 25             	cmp    $0x25,%eax
  8004fc:	75 e5                	jne    8004e3 <vprintfmt+0x11>
  8004fe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800502:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800509:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80050e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800515:	b9 00 00 00 00       	mov    $0x0,%ecx
  80051a:	eb 26                	jmp    800542 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80051f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800523:	eb 1d                	jmp    800542 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800528:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80052c:	eb 14                	jmp    800542 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800531:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800538:	eb 08                	jmp    800542 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80053a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80053d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	0f b6 06             	movzbl (%esi),%eax
  800545:	8d 56 01             	lea    0x1(%esi),%edx
  800548:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80054b:	8a 16                	mov    (%esi),%dl
  80054d:	83 ea 23             	sub    $0x23,%edx
  800550:	80 fa 55             	cmp    $0x55,%dl
  800553:	0f 87 e1 02 00 00    	ja     80083a <vprintfmt+0x368>
  800559:	0f b6 d2             	movzbl %dl,%edx
  80055c:	ff 24 95 e0 2d 80 00 	jmp    *0x802de0(,%edx,4)
  800563:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800566:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80056b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80056e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800572:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800575:	8d 50 d0             	lea    -0x30(%eax),%edx
  800578:	83 fa 09             	cmp    $0x9,%edx
  80057b:	77 2a                	ja     8005a7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80057d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057e:	eb eb                	jmp    80056b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058e:	eb 17                	jmp    8005a7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800590:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800594:	78 98                	js     80052e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800599:	eb a7                	jmp    800542 <vprintfmt+0x70>
  80059b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80059e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005a5:	eb 9b                	jmp    800542 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ab:	79 95                	jns    800542 <vprintfmt+0x70>
  8005ad:	eb 8b                	jmp    80053a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005af:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005b3:	eb 8d                	jmp    800542 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005cd:	e9 23 ff ff ff       	jmp    8004f5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 00                	mov    (%eax),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	79 02                	jns    8005e3 <vprintfmt+0x111>
  8005e1:	f7 d8                	neg    %eax
  8005e3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e5:	83 f8 11             	cmp    $0x11,%eax
  8005e8:	7f 0b                	jg     8005f5 <vprintfmt+0x123>
  8005ea:	8b 04 85 40 2f 80 00 	mov    0x802f40(,%eax,4),%eax
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	75 23                	jne    800618 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f9:	c7 44 24 08 c3 2c 80 	movl   $0x802cc3,0x8(%esp)
  800600:	00 
  800601:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800605:	8b 45 08             	mov    0x8(%ebp),%eax
  800608:	89 04 24             	mov    %eax,(%esp)
  80060b:	e8 9a fe ff ff       	call   8004aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800613:	e9 dd fe ff ff       	jmp    8004f5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800618:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80061c:	c7 44 24 08 6d 31 80 	movl   $0x80316d,0x8(%esp)
  800623:	00 
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	8b 55 08             	mov    0x8(%ebp),%edx
  80062b:	89 14 24             	mov    %edx,(%esp)
  80062e:	e8 77 fe ff ff       	call   8004aa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800636:	e9 ba fe ff ff       	jmp    8004f5 <vprintfmt+0x23>
  80063b:	89 f9                	mov    %edi,%ecx
  80063d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800640:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 30                	mov    (%eax),%esi
  80064e:	85 f6                	test   %esi,%esi
  800650:	75 05                	jne    800657 <vprintfmt+0x185>
				p = "(null)";
  800652:	be bc 2c 80 00       	mov    $0x802cbc,%esi
			if (width > 0 && padc != '-')
  800657:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80065b:	0f 8e 84 00 00 00    	jle    8006e5 <vprintfmt+0x213>
  800661:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800665:	74 7e                	je     8006e5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800667:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80066b:	89 34 24             	mov    %esi,(%esp)
  80066e:	e8 8b 02 00 00       	call   8008fe <strnlen>
  800673:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800676:	29 c2                	sub    %eax,%edx
  800678:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80067b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80067f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800682:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800685:	89 de                	mov    %ebx,%esi
  800687:	89 d3                	mov    %edx,%ebx
  800689:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	eb 0b                	jmp    800698 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80068d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800691:	89 3c 24             	mov    %edi,(%esp)
  800694:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	4b                   	dec    %ebx
  800698:	85 db                	test   %ebx,%ebx
  80069a:	7f f1                	jg     80068d <vprintfmt+0x1bb>
  80069c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80069f:	89 f3                	mov    %esi,%ebx
  8006a1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	79 05                	jns    8006b0 <vprintfmt+0x1de>
  8006ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b3:	29 c2                	sub    %eax,%edx
  8006b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006b8:	eb 2b                	jmp    8006e5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ba:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006be:	74 18                	je     8006d8 <vprintfmt+0x206>
  8006c0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006c3:	83 fa 5e             	cmp    $0x5e,%edx
  8006c6:	76 10                	jbe    8006d8 <vprintfmt+0x206>
					putch('?', putdat);
  8006c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
  8006d6:	eb 0a                	jmp    8006e2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	89 04 24             	mov    %eax,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e2:	ff 4d e4             	decl   -0x1c(%ebp)
  8006e5:	0f be 06             	movsbl (%esi),%eax
  8006e8:	46                   	inc    %esi
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 21                	je     80070e <vprintfmt+0x23c>
  8006ed:	85 ff                	test   %edi,%edi
  8006ef:	78 c9                	js     8006ba <vprintfmt+0x1e8>
  8006f1:	4f                   	dec    %edi
  8006f2:	79 c6                	jns    8006ba <vprintfmt+0x1e8>
  8006f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f7:	89 de                	mov    %ebx,%esi
  8006f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006fc:	eb 18                	jmp    800716 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800702:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800709:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80070b:	4b                   	dec    %ebx
  80070c:	eb 08                	jmp    800716 <vprintfmt+0x244>
  80070e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800711:	89 de                	mov    %ebx,%esi
  800713:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800716:	85 db                	test   %ebx,%ebx
  800718:	7f e4                	jg     8006fe <vprintfmt+0x22c>
  80071a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80071d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800722:	e9 ce fd ff ff       	jmp    8004f5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800727:	83 f9 01             	cmp    $0x1,%ecx
  80072a:	7e 10                	jle    80073c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 08             	lea    0x8(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 30                	mov    (%eax),%esi
  800737:	8b 78 04             	mov    0x4(%eax),%edi
  80073a:	eb 26                	jmp    800762 <vprintfmt+0x290>
	else if (lflag)
  80073c:	85 c9                	test   %ecx,%ecx
  80073e:	74 12                	je     800752 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 04             	lea    0x4(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	8b 30                	mov    (%eax),%esi
  80074b:	89 f7                	mov    %esi,%edi
  80074d:	c1 ff 1f             	sar    $0x1f,%edi
  800750:	eb 10                	jmp    800762 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8d 50 04             	lea    0x4(%eax),%edx
  800758:	89 55 14             	mov    %edx,0x14(%ebp)
  80075b:	8b 30                	mov    (%eax),%esi
  80075d:	89 f7                	mov    %esi,%edi
  80075f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800762:	85 ff                	test   %edi,%edi
  800764:	78 0a                	js     800770 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800766:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076b:	e9 8c 00 00 00       	jmp    8007fc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800774:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80077e:	f7 de                	neg    %esi
  800780:	83 d7 00             	adc    $0x0,%edi
  800783:	f7 df                	neg    %edi
			}
			base = 10;
  800785:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078a:	eb 70                	jmp    8007fc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80078c:	89 ca                	mov    %ecx,%edx
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
  800791:	e8 c0 fc ff ff       	call   800456 <getuint>
  800796:	89 c6                	mov    %eax,%esi
  800798:	89 d7                	mov    %edx,%edi
			base = 10;
  80079a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80079f:	eb 5b                	jmp    8007fc <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8007a1:	89 ca                	mov    %ecx,%edx
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 ab fc ff ff       	call   800456 <getuint>
  8007ab:	89 c6                	mov    %eax,%esi
  8007ad:	89 d7                	mov    %edx,%edi
			base = 8;
  8007af:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007b4:	eb 46                	jmp    8007fc <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007db:	8b 30                	mov    (%eax),%esi
  8007dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007e7:	eb 13                	jmp    8007fc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e9:	89 ca                	mov    %ecx,%edx
  8007eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ee:	e8 63 fc ff ff       	call   800456 <getuint>
  8007f3:	89 c6                	mov    %eax,%esi
  8007f5:	89 d7                	mov    %edx,%edi
			base = 16;
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800800:	89 54 24 10          	mov    %edx,0x10(%esp)
  800804:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800807:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80080b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080f:	89 34 24             	mov    %esi,(%esp)
  800812:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800816:	89 da                	mov    %ebx,%edx
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	e8 6c fb ff ff       	call   80038c <printnum>
			break;
  800820:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800823:	e9 cd fc ff ff       	jmp    8004f5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800828:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082c:	89 04 24             	mov    %eax,(%esp)
  80082f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800832:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800835:	e9 bb fc ff ff       	jmp    8004f5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80083e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800845:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800848:	eb 01                	jmp    80084b <vprintfmt+0x379>
  80084a:	4e                   	dec    %esi
  80084b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80084f:	75 f9                	jne    80084a <vprintfmt+0x378>
  800851:	e9 9f fc ff ff       	jmp    8004f5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800856:	83 c4 4c             	add    $0x4c,%esp
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	5f                   	pop    %edi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 28             	sub    $0x28,%esp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800871:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800874:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087b:	85 c0                	test   %eax,%eax
  80087d:	74 30                	je     8008af <vsnprintf+0x51>
  80087f:	85 d2                	test   %edx,%edx
  800881:	7e 33                	jle    8008b6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088a:	8b 45 10             	mov    0x10(%ebp),%eax
  80088d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800891:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800894:	89 44 24 04          	mov    %eax,0x4(%esp)
  800898:	c7 04 24 90 04 80 00 	movl   $0x800490,(%esp)
  80089f:	e8 2e fc ff ff       	call   8004d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ad:	eb 0c                	jmp    8008bb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b4:	eb 05                	jmp    8008bb <vsnprintf+0x5d>
  8008b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8008cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	89 04 24             	mov    %eax,(%esp)
  8008de:	e8 7b ff ff ff       	call   80085e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    
  8008e5:	00 00                	add    %al,(%eax)
	...

008008e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f3:	eb 01                	jmp    8008f6 <strlen+0xe>
		n++;
  8008f5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fa:	75 f9                	jne    8008f5 <strlen+0xd>
		n++;
	return n;
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800904:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
  80090c:	eb 01                	jmp    80090f <strnlen+0x11>
		n++;
  80090e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090f:	39 d0                	cmp    %edx,%eax
  800911:	74 06                	je     800919 <strnlen+0x1b>
  800913:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800917:	75 f5                	jne    80090e <strnlen+0x10>
		n++;
	return n;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800925:	ba 00 00 00 00       	mov    $0x0,%edx
  80092a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80092d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800930:	42                   	inc    %edx
  800931:	84 c9                	test   %cl,%cl
  800933:	75 f5                	jne    80092a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800935:	5b                   	pop    %ebx
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	83 ec 08             	sub    $0x8,%esp
  80093f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800942:	89 1c 24             	mov    %ebx,(%esp)
  800945:	e8 9e ff ff ff       	call   8008e8 <strlen>
	strcpy(dst + len, src);
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800951:	01 d8                	add    %ebx,%eax
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	e8 c0 ff ff ff       	call   80091b <strcpy>
	return dst;
}
  80095b:	89 d8                	mov    %ebx,%eax
  80095d:	83 c4 08             	add    $0x8,%esp
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800971:	b9 00 00 00 00       	mov    $0x0,%ecx
  800976:	eb 0c                	jmp    800984 <strncpy+0x21>
		*dst++ = *src;
  800978:	8a 1a                	mov    (%edx),%bl
  80097a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80097d:	80 3a 01             	cmpb   $0x1,(%edx)
  800980:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800983:	41                   	inc    %ecx
  800984:	39 f1                	cmp    %esi,%ecx
  800986:	75 f0                	jne    800978 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80099a:	85 d2                	test   %edx,%edx
  80099c:	75 0a                	jne    8009a8 <strlcpy+0x1c>
  80099e:	89 f0                	mov    %esi,%eax
  8009a0:	eb 1a                	jmp    8009bc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a2:	88 18                	mov    %bl,(%eax)
  8009a4:	40                   	inc    %eax
  8009a5:	41                   	inc    %ecx
  8009a6:	eb 02                	jmp    8009aa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009aa:	4a                   	dec    %edx
  8009ab:	74 0a                	je     8009b7 <strlcpy+0x2b>
  8009ad:	8a 19                	mov    (%ecx),%bl
  8009af:	84 db                	test   %bl,%bl
  8009b1:	75 ef                	jne    8009a2 <strlcpy+0x16>
  8009b3:	89 c2                	mov    %eax,%edx
  8009b5:	eb 02                	jmp    8009b9 <strlcpy+0x2d>
  8009b7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009b9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009bc:	29 f0                	sub    %esi,%eax
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009cb:	eb 02                	jmp    8009cf <strcmp+0xd>
		p++, q++;
  8009cd:	41                   	inc    %ecx
  8009ce:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009cf:	8a 01                	mov    (%ecx),%al
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 04                	je     8009d9 <strcmp+0x17>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	74 f4                	je     8009cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 12             	movzbl (%edx),%edx
  8009df:	29 d0                	sub    %edx,%eax
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ed:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009f0:	eb 03                	jmp    8009f5 <strncmp+0x12>
		n--, p++, q++;
  8009f2:	4a                   	dec    %edx
  8009f3:	40                   	inc    %eax
  8009f4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	74 14                	je     800a0d <strncmp+0x2a>
  8009f9:	8a 18                	mov    (%eax),%bl
  8009fb:	84 db                	test   %bl,%bl
  8009fd:	74 04                	je     800a03 <strncmp+0x20>
  8009ff:	3a 19                	cmp    (%ecx),%bl
  800a01:	74 ef                	je     8009f2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a03:	0f b6 00             	movzbl (%eax),%eax
  800a06:	0f b6 11             	movzbl (%ecx),%edx
  800a09:	29 d0                	sub    %edx,%eax
  800a0b:	eb 05                	jmp    800a12 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a1e:	eb 05                	jmp    800a25 <strchr+0x10>
		if (*s == c)
  800a20:	38 ca                	cmp    %cl,%dl
  800a22:	74 0c                	je     800a30 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a24:	40                   	inc    %eax
  800a25:	8a 10                	mov    (%eax),%dl
  800a27:	84 d2                	test   %dl,%dl
  800a29:	75 f5                	jne    800a20 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a3b:	eb 05                	jmp    800a42 <strfind+0x10>
		if (*s == c)
  800a3d:	38 ca                	cmp    %cl,%dl
  800a3f:	74 07                	je     800a48 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a41:	40                   	inc    %eax
  800a42:	8a 10                	mov    (%eax),%dl
  800a44:	84 d2                	test   %dl,%dl
  800a46:	75 f5                	jne    800a3d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a59:	85 c9                	test   %ecx,%ecx
  800a5b:	74 30                	je     800a8d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a63:	75 25                	jne    800a8a <memset+0x40>
  800a65:	f6 c1 03             	test   $0x3,%cl
  800a68:	75 20                	jne    800a8a <memset+0x40>
		c &= 0xFF;
  800a6a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6d:	89 d3                	mov    %edx,%ebx
  800a6f:	c1 e3 08             	shl    $0x8,%ebx
  800a72:	89 d6                	mov    %edx,%esi
  800a74:	c1 e6 18             	shl    $0x18,%esi
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	c1 e0 10             	shl    $0x10,%eax
  800a7c:	09 f0                	or     %esi,%eax
  800a7e:	09 d0                	or     %edx,%eax
  800a80:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a82:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a85:	fc                   	cld    
  800a86:	f3 ab                	rep stos %eax,%es:(%edi)
  800a88:	eb 03                	jmp    800a8d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8a:	fc                   	cld    
  800a8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8d:	89 f8                	mov    %edi,%eax
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 34                	jae    800ada <memmove+0x46>
  800aa6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa9:	39 d0                	cmp    %edx,%eax
  800aab:	73 2d                	jae    800ada <memmove+0x46>
		s += n;
		d += n;
  800aad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab0:	f6 c2 03             	test   $0x3,%dl
  800ab3:	75 1b                	jne    800ad0 <memmove+0x3c>
  800ab5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abb:	75 13                	jne    800ad0 <memmove+0x3c>
  800abd:	f6 c1 03             	test   $0x3,%cl
  800ac0:	75 0e                	jne    800ad0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac2:	83 ef 04             	sub    $0x4,%edi
  800ac5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800acb:	fd                   	std    
  800acc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ace:	eb 07                	jmp    800ad7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ad0:	4f                   	dec    %edi
  800ad1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad4:	fd                   	std    
  800ad5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad7:	fc                   	cld    
  800ad8:	eb 20                	jmp    800afa <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ada:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae0:	75 13                	jne    800af5 <memmove+0x61>
  800ae2:	a8 03                	test   $0x3,%al
  800ae4:	75 0f                	jne    800af5 <memmove+0x61>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 0a                	jne    800af5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aee:	89 c7                	mov    %eax,%edi
  800af0:	fc                   	cld    
  800af1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af3:	eb 05                	jmp    800afa <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af5:	89 c7                	mov    %eax,%edi
  800af7:	fc                   	cld    
  800af8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b04:	8b 45 10             	mov    0x10(%ebp),%eax
  800b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 77 ff ff ff       	call   800a94 <memmove>
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	eb 16                	jmp    800b4b <memcmp+0x2c>
		if (*s1 != *s2)
  800b35:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b38:	42                   	inc    %edx
  800b39:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b3d:	38 c8                	cmp    %cl,%al
  800b3f:	74 0a                	je     800b4b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b41:	0f b6 c0             	movzbl %al,%eax
  800b44:	0f b6 c9             	movzbl %cl,%ecx
  800b47:	29 c8                	sub    %ecx,%eax
  800b49:	eb 09                	jmp    800b54 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4b:	39 da                	cmp    %ebx,%edx
  800b4d:	75 e6                	jne    800b35 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b62:	89 c2                	mov    %eax,%edx
  800b64:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b67:	eb 05                	jmp    800b6e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b69:	38 08                	cmp    %cl,(%eax)
  800b6b:	74 05                	je     800b72 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6d:	40                   	inc    %eax
  800b6e:	39 d0                	cmp    %edx,%eax
  800b70:	72 f7                	jb     800b69 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b80:	eb 01                	jmp    800b83 <strtol+0xf>
		s++;
  800b82:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b83:	8a 02                	mov    (%edx),%al
  800b85:	3c 20                	cmp    $0x20,%al
  800b87:	74 f9                	je     800b82 <strtol+0xe>
  800b89:	3c 09                	cmp    $0x9,%al
  800b8b:	74 f5                	je     800b82 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8d:	3c 2b                	cmp    $0x2b,%al
  800b8f:	75 08                	jne    800b99 <strtol+0x25>
		s++;
  800b91:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi
  800b97:	eb 13                	jmp    800bac <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b99:	3c 2d                	cmp    $0x2d,%al
  800b9b:	75 0a                	jne    800ba7 <strtol+0x33>
		s++, neg = 1;
  800b9d:	8d 52 01             	lea    0x1(%edx),%edx
  800ba0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba5:	eb 05                	jmp    800bac <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bac:	85 db                	test   %ebx,%ebx
  800bae:	74 05                	je     800bb5 <strtol+0x41>
  800bb0:	83 fb 10             	cmp    $0x10,%ebx
  800bb3:	75 28                	jne    800bdd <strtol+0x69>
  800bb5:	8a 02                	mov    (%edx),%al
  800bb7:	3c 30                	cmp    $0x30,%al
  800bb9:	75 10                	jne    800bcb <strtol+0x57>
  800bbb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bbf:	75 0a                	jne    800bcb <strtol+0x57>
		s += 2, base = 16;
  800bc1:	83 c2 02             	add    $0x2,%edx
  800bc4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc9:	eb 12                	jmp    800bdd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bcb:	85 db                	test   %ebx,%ebx
  800bcd:	75 0e                	jne    800bdd <strtol+0x69>
  800bcf:	3c 30                	cmp    $0x30,%al
  800bd1:	75 05                	jne    800bd8 <strtol+0x64>
		s++, base = 8;
  800bd3:	42                   	inc    %edx
  800bd4:	b3 08                	mov    $0x8,%bl
  800bd6:	eb 05                	jmp    800bdd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bd8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be4:	8a 0a                	mov    (%edx),%cl
  800be6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800be9:	80 fb 09             	cmp    $0x9,%bl
  800bec:	77 08                	ja     800bf6 <strtol+0x82>
			dig = *s - '0';
  800bee:	0f be c9             	movsbl %cl,%ecx
  800bf1:	83 e9 30             	sub    $0x30,%ecx
  800bf4:	eb 1e                	jmp    800c14 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bf6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bf9:	80 fb 19             	cmp    $0x19,%bl
  800bfc:	77 08                	ja     800c06 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bfe:	0f be c9             	movsbl %cl,%ecx
  800c01:	83 e9 57             	sub    $0x57,%ecx
  800c04:	eb 0e                	jmp    800c14 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c06:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c09:	80 fb 19             	cmp    $0x19,%bl
  800c0c:	77 12                	ja     800c20 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c0e:	0f be c9             	movsbl %cl,%ecx
  800c11:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c14:	39 f1                	cmp    %esi,%ecx
  800c16:	7d 0c                	jge    800c24 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c18:	42                   	inc    %edx
  800c19:	0f af c6             	imul   %esi,%eax
  800c1c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c1e:	eb c4                	jmp    800be4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c20:	89 c1                	mov    %eax,%ecx
  800c22:	eb 02                	jmp    800c26 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c24:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2a:	74 05                	je     800c31 <strtol+0xbd>
		*endptr = (char *) s;
  800c2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c2f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c31:	85 ff                	test   %edi,%edi
  800c33:	74 04                	je     800c39 <strtol+0xc5>
  800c35:	89 c8                	mov    %ecx,%eax
  800c37:	f7 d8                	neg    %eax
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    
	...

00800c40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 c3                	mov    %eax,%ebx
  800c53:	89 c7                	mov    %eax,%edi
  800c55:	89 c6                	mov    %eax,%esi
  800c57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6e:	89 d1                	mov    %edx,%ecx
  800c70:	89 d3                	mov    %edx,%ebx
  800c72:	89 d7                	mov    %edx,%edi
  800c74:	89 d6                	mov    %edx,%esi
  800c76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 cb                	mov    %ecx,%ebx
  800c95:	89 cf                	mov    %ecx,%edi
  800c97:	89 ce                	mov    %ecx,%esi
  800c99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 28                	jle    800cc7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800caa:	00 
  800cab:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cba:	00 
  800cbb:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800cc2:	e8 b1 f5 ff ff       	call   800278 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc7:	83 c4 2c             	add    $0x2c,%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cda:	b8 02 00 00 00       	mov    $0x2,%eax
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	89 d3                	mov    %edx,%ebx
  800ce3:	89 d7                	mov    %edx,%edi
  800ce5:	89 d6                	mov    %edx,%esi
  800ce7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_yield>:

void
sys_yield(void)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfe:	89 d1                	mov    %edx,%ecx
  800d00:	89 d3                	mov    %edx,%ebx
  800d02:	89 d7                	mov    %edx,%edi
  800d04:	89 d6                	mov    %edx,%esi
  800d06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d16:	be 00 00 00 00       	mov    $0x0,%esi
  800d1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 f7                	mov    %esi,%edi
  800d2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 28                	jle    800d59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d3c:	00 
  800d3d:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800d44:	00 
  800d45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4c:	00 
  800d4d:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800d54:	e8 1f f5 ff ff       	call   800278 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d59:	83 c4 2c             	add    $0x2c,%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7e 28                	jle    800dac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d8f:	00 
  800d90:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800d97:	00 
  800d98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9f:	00 
  800da0:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800da7:	e8 cc f4 ff ff       	call   800278 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dac:	83 c4 2c             	add    $0x2c,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 df                	mov    %ebx,%edi
  800dcf:	89 de                	mov    %ebx,%esi
  800dd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	7e 28                	jle    800dff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800de2:	00 
  800de3:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800dea:	00 
  800deb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df2:	00 
  800df3:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800dfa:	e8 79 f4 ff ff       	call   800278 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dff:	83 c4 2c             	add    $0x2c,%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e15:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	89 df                	mov    %ebx,%edi
  800e22:	89 de                	mov    %ebx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800e4d:	e8 26 f4 ff ff       	call   800278 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 09 00 00 00       	mov    $0x9,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800ea0:	e8 d3 f3 ff ff       	call   800278 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ea5:	83 c4 2c             	add    $0x2c,%esp
  800ea8:	5b                   	pop    %ebx
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7e 28                	jle    800ef8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800edb:	00 
  800edc:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eeb:	00 
  800eec:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800ef3:	e8 80 f3 ff ff       	call   800278 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef8:	83 c4 2c             	add    $0x2c,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	be 00 00 00 00       	mov    $0x0,%esi
  800f0b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f36:	8b 55 08             	mov    0x8(%ebp),%edx
  800f39:	89 cb                	mov    %ecx,%ebx
  800f3b:	89 cf                	mov    %ecx,%edi
  800f3d:	89 ce                	mov    %ecx,%esi
  800f3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7e 28                	jle    800f6d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f49:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f50:	00 
  800f51:	c7 44 24 08 a7 2f 80 	movl   $0x802fa7,0x8(%esp)
  800f58:	00 
  800f59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f60:	00 
  800f61:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  800f68:	e8 0b f3 ff ff       	call   800278 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6d:	83 c4 2c             	add    $0x2c,%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	57                   	push   %edi
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f80:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	89 d3                	mov    %edx,%ebx
  800f89:	89 d7                	mov    %edx,%edi
  800f8b:	89 d6                	mov    %edx,%esi
  800f8d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f9f:	b8 10 00 00 00       	mov    $0x10,%eax
  800fa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa7:	8b 55 08             	mov    0x8(%ebp),%edx
  800faa:	89 df                	mov    %ebx,%edi
  800fac:	89 de                	mov    %ebx,%esi
  800fae:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 df                	mov    %ebx,%edi
  800fcd:	89 de                	mov    %ebx,%esi
  800fcf:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	57                   	push   %edi
  800fda:	56                   	push   %esi
  800fdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe1:	b8 11 00 00 00       	mov    $0x11,%eax
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	89 cb                	mov    %ecx,%ebx
  800feb:	89 cf                	mov    %ecx,%edi
  800fed:	89 ce                	mov    %ecx,%esi
  800fef:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
	...

00800ff8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 24             	sub    $0x24,%esp
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801002:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  801004:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801008:	75 20                	jne    80102a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  80100a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80100e:	c7 44 24 08 d4 2f 80 	movl   $0x802fd4,0x8(%esp)
  801015:	00 
  801016:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80101d:	00 
  80101e:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801025:	e8 4e f2 ff ff       	call   800278 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80102a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801030:	89 d8                	mov    %ebx,%eax
  801032:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801035:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80103c:	f6 c4 08             	test   $0x8,%ah
  80103f:	75 1c                	jne    80105d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801041:	c7 44 24 08 04 30 80 	movl   $0x803004,0x8(%esp)
  801048:	00 
  801049:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801058:	e8 1b f2 ff ff       	call   800278 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80105d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801064:	00 
  801065:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80106c:	00 
  80106d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801074:	e8 94 fc ff ff       	call   800d0d <sys_page_alloc>
  801079:	85 c0                	test   %eax,%eax
  80107b:	79 20                	jns    80109d <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  80107d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801081:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801098:	e8 db f1 ff ff       	call   800278 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  80109d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010a4:	00 
  8010a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010a9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010b0:	e8 df f9 ff ff       	call   800a94 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8010b5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010bc:	00 
  8010bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c8:	00 
  8010c9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010d0:	00 
  8010d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d8:	e8 84 fc ff ff       	call   800d61 <sys_page_map>
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	79 20                	jns    801101 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  8010e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e5:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  8010fc:	e8 77 f1 ff ff       	call   800278 <_panic>

}
  801101:	83 c4 24             	add    $0x24,%esp
  801104:	5b                   	pop    %ebx
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801110:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  801117:	e8 e0 15 00 00       	call   8026fc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80111c:	ba 07 00 00 00       	mov    $0x7,%edx
  801121:	89 d0                	mov    %edx,%eax
  801123:	cd 30                	int    $0x30
  801125:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801128:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  80112b:	85 c0                	test   %eax,%eax
  80112d:	79 20                	jns    80114f <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80112f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801133:	c7 44 24 08 85 30 80 	movl   $0x803085,0x8(%esp)
  80113a:	00 
  80113b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801142:	00 
  801143:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  80114a:	e8 29 f1 ff ff       	call   800278 <_panic>
	if (child_envid == 0) { // child
  80114f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801153:	75 1c                	jne    801171 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801155:	e8 75 fb ff ff       	call   800ccf <sys_getenvid>
  80115a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80115f:	c1 e0 07             	shl    $0x7,%eax
  801162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801167:	a3 20 54 80 00       	mov    %eax,0x805420
		return 0;
  80116c:	e9 58 02 00 00       	jmp    8013c9 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801171:	bf 00 00 00 00       	mov    $0x0,%edi
  801176:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80117b:	89 f0                	mov    %esi,%eax
  80117d:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801180:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801187:	a8 01                	test   $0x1,%al
  801189:	0f 84 7a 01 00 00    	je     801309 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80118f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801196:	a8 01                	test   $0x1,%al
  801198:	0f 84 6b 01 00 00    	je     801309 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80119e:	a1 20 54 80 00       	mov    0x805420,%eax
  8011a3:	8b 40 48             	mov    0x48(%eax),%eax
  8011a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8011a9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011b0:	f6 c4 04             	test   $0x4,%ah
  8011b3:	74 52                	je     801207 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011b5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8011c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	e8 82 fb ff ff       	call   800d61 <sys_page_map>
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	0f 89 22 01 00 00    	jns    801309 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8011e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011eb:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801202:	e8 71 f0 ff ff       	call   800278 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801207:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80120e:	f6 c4 08             	test   $0x8,%ah
  801211:	75 0f                	jne    801222 <fork+0x11b>
  801213:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80121a:	a8 02                	test   $0x2,%al
  80121c:	0f 84 99 00 00 00    	je     8012bb <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  801222:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801229:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  80122c:	83 f8 01             	cmp    $0x1,%eax
  80122f:	19 db                	sbb    %ebx,%ebx
  801231:	83 e3 fc             	and    $0xfffffffc,%ebx
  801234:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80123a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80123e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801242:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80124d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801250:	89 04 24             	mov    %eax,(%esp)
  801253:	e8 09 fb ff ff       	call   800d61 <sys_page_map>
  801258:	85 c0                	test   %eax,%eax
  80125a:	79 20                	jns    80127c <fork+0x175>
			panic("sys_page_map: %e\n", r);
  80125c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801260:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801277:	e8 fc ef ff ff       	call   800278 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80127c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801280:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801287:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 ca fa ff ff       	call   800d61 <sys_page_map>
  801297:	85 c0                	test   %eax,%eax
  801299:	79 6e                	jns    801309 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80129b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129f:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  8012b6:	e8 bd ef ff ff       	call   800278 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8012bb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012dd:	89 04 24             	mov    %eax,(%esp)
  8012e0:	e8 7c fa ff ff       	call   800d61 <sys_page_map>
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	79 20                	jns    801309 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8012e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ed:	c7 44 24 08 73 30 80 	movl   $0x803073,0x8(%esp)
  8012f4:	00 
  8012f5:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8012fc:	00 
  8012fd:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801304:	e8 6f ef ff ff       	call   800278 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801309:	46                   	inc    %esi
  80130a:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801310:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801316:	0f 85 5f fe ff ff    	jne    80117b <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80131c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801323:	00 
  801324:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80132b:	ee 
  80132c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 d6 f9 ff ff       	call   800d0d <sys_page_alloc>
  801337:	85 c0                	test   %eax,%eax
  801339:	79 20                	jns    80135b <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  80133b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133f:	c7 44 24 08 5f 30 80 	movl   $0x80305f,0x8(%esp)
  801346:	00 
  801347:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80134e:	00 
  80134f:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801356:	e8 1d ef ff ff       	call   800278 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  80135b:	c7 44 24 04 70 27 80 	movl   $0x802770,0x4(%esp)
  801362:	00 
  801363:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801366:	89 04 24             	mov    %eax,(%esp)
  801369:	e8 3f fb ff ff       	call   800ead <sys_env_set_pgfault_upcall>
  80136e:	85 c0                	test   %eax,%eax
  801370:	79 20                	jns    801392 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801372:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801376:	c7 44 24 08 34 30 80 	movl   $0x803034,0x8(%esp)
  80137d:	00 
  80137e:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801385:	00 
  801386:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  80138d:	e8 e6 ee ff ff       	call   800278 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801392:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801399:	00 
  80139a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 62 fa ff ff       	call   800e07 <sys_env_set_status>
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	79 20                	jns    8013c9 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  8013a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ad:	c7 44 24 08 96 30 80 	movl   $0x803096,0x8(%esp)
  8013b4:	00 
  8013b5:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8013bc:	00 
  8013bd:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  8013c4:	e8 af ee ff ff       	call   800278 <_panic>

	return child_envid;
}
  8013c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013cc:	83 c4 3c             	add    $0x3c,%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <sfork>:

// Challenge!
int
sfork(void)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013da:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  8013e1:	00 
  8013e2:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8013e9:	00 
  8013ea:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  8013f1:	e8 82 ee ff ff       	call   800278 <_panic>
	...

008013f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801403:	c1 e8 0c             	shr    $0xc,%eax
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 df ff ff ff       	call   8013f8 <fd2num>
  801419:	05 20 00 0d 00       	add    $0xd0020,%eax
  80141e:	c1 e0 0c             	shl    $0xc,%eax
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	53                   	push   %ebx
  801427:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80142a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80142f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801431:	89 c2                	mov    %eax,%edx
  801433:	c1 ea 16             	shr    $0x16,%edx
  801436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80143d:	f6 c2 01             	test   $0x1,%dl
  801440:	74 11                	je     801453 <fd_alloc+0x30>
  801442:	89 c2                	mov    %eax,%edx
  801444:	c1 ea 0c             	shr    $0xc,%edx
  801447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80144e:	f6 c2 01             	test   $0x1,%dl
  801451:	75 09                	jne    80145c <fd_alloc+0x39>
			*fd_store = fd;
  801453:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801455:	b8 00 00 00 00       	mov    $0x0,%eax
  80145a:	eb 17                	jmp    801473 <fd_alloc+0x50>
  80145c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801461:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801466:	75 c7                	jne    80142f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80146e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801473:	5b                   	pop    %ebx
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80147c:	83 f8 1f             	cmp    $0x1f,%eax
  80147f:	77 36                	ja     8014b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801481:	05 00 00 0d 00       	add    $0xd0000,%eax
  801486:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801489:	89 c2                	mov    %eax,%edx
  80148b:	c1 ea 16             	shr    $0x16,%edx
  80148e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801495:	f6 c2 01             	test   $0x1,%dl
  801498:	74 24                	je     8014be <fd_lookup+0x48>
  80149a:	89 c2                	mov    %eax,%edx
  80149c:	c1 ea 0c             	shr    $0xc,%edx
  80149f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014a6:	f6 c2 01             	test   $0x1,%dl
  8014a9:	74 1a                	je     8014c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8014b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b5:	eb 13                	jmp    8014ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014bc:	eb 0c                	jmp    8014ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014c3:	eb 05                	jmp    8014ca <fd_lookup+0x54>
  8014c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 14             	sub    $0x14,%esp
  8014d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	eb 0e                	jmp    8014ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8014e0:	39 08                	cmp    %ecx,(%eax)
  8014e2:	75 09                	jne    8014ed <dev_lookup+0x21>
			*dev = devtab[i];
  8014e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	eb 33                	jmp    801520 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	42                   	inc    %edx
  8014ee:	8b 04 95 40 31 80 00 	mov    0x803140(,%edx,4),%eax
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	75 e7                	jne    8014e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014f9:	a1 20 54 80 00       	mov    0x805420,%eax
  8014fe:	8b 40 48             	mov    0x48(%eax),%eax
  801501:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801505:	89 44 24 04          	mov    %eax,0x4(%esp)
  801509:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  801510:	e8 5b ee ff ff       	call   800370 <cprintf>
	*dev = 0;
  801515:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80151b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801520:	83 c4 14             	add    $0x14,%esp
  801523:	5b                   	pop    %ebx
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    

00801526 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 30             	sub    $0x30,%esp
  80152e:	8b 75 08             	mov    0x8(%ebp),%esi
  801531:	8a 45 0c             	mov    0xc(%ebp),%al
  801534:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801537:	89 34 24             	mov    %esi,(%esp)
  80153a:	e8 b9 fe ff ff       	call   8013f8 <fd2num>
  80153f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801542:	89 54 24 04          	mov    %edx,0x4(%esp)
  801546:	89 04 24             	mov    %eax,(%esp)
  801549:	e8 28 ff ff ff       	call   801476 <fd_lookup>
  80154e:	89 c3                	mov    %eax,%ebx
  801550:	85 c0                	test   %eax,%eax
  801552:	78 05                	js     801559 <fd_close+0x33>
	    || fd != fd2)
  801554:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801557:	74 0d                	je     801566 <fd_close+0x40>
		return (must_exist ? r : 0);
  801559:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80155d:	75 46                	jne    8015a5 <fd_close+0x7f>
  80155f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801564:	eb 3f                	jmp    8015a5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801566:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156d:	8b 06                	mov    (%esi),%eax
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	e8 55 ff ff ff       	call   8014cc <dev_lookup>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	85 c0                	test   %eax,%eax
  80157b:	78 18                	js     801595 <fd_close+0x6f>
		if (dev->dev_close)
  80157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801580:	8b 40 10             	mov    0x10(%eax),%eax
  801583:	85 c0                	test   %eax,%eax
  801585:	74 09                	je     801590 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801587:	89 34 24             	mov    %esi,(%esp)
  80158a:	ff d0                	call   *%eax
  80158c:	89 c3                	mov    %eax,%ebx
  80158e:	eb 05                	jmp    801595 <fd_close+0x6f>
		else
			r = 0;
  801590:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801595:	89 74 24 04          	mov    %esi,0x4(%esp)
  801599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a0:	e8 0f f8 ff ff       	call   800db4 <sys_page_unmap>
	return r;
}
  8015a5:	89 d8                	mov    %ebx,%eax
  8015a7:	83 c4 30             	add    $0x30,%esp
  8015aa:	5b                   	pop    %ebx
  8015ab:	5e                   	pop    %esi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    

008015ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	89 04 24             	mov    %eax,(%esp)
  8015c1:	e8 b0 fe ff ff       	call   801476 <fd_lookup>
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 13                	js     8015dd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015d1:	00 
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 49 ff ff ff       	call   801526 <fd_close>
}
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <close_all>:

void
close_all(void)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015eb:	89 1c 24             	mov    %ebx,(%esp)
  8015ee:	e8 bb ff ff ff       	call   8015ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015f3:	43                   	inc    %ebx
  8015f4:	83 fb 20             	cmp    $0x20,%ebx
  8015f7:	75 f2                	jne    8015eb <close_all+0xc>
		close(i);
}
  8015f9:	83 c4 14             	add    $0x14,%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	57                   	push   %edi
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 4c             	sub    $0x4c,%esp
  801608:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80160b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 59 fe ff ff       	call   801476 <fd_lookup>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	85 c0                	test   %eax,%eax
  801621:	0f 88 e1 00 00 00    	js     801708 <dup+0x109>
		return r;
	close(newfdnum);
  801627:	89 3c 24             	mov    %edi,(%esp)
  80162a:	e8 7f ff ff ff       	call   8015ae <close>

	newfd = INDEX2FD(newfdnum);
  80162f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801635:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163b:	89 04 24             	mov    %eax,(%esp)
  80163e:	e8 c5 fd ff ff       	call   801408 <fd2data>
  801643:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801645:	89 34 24             	mov    %esi,(%esp)
  801648:	e8 bb fd ff ff       	call   801408 <fd2data>
  80164d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801650:	89 d8                	mov    %ebx,%eax
  801652:	c1 e8 16             	shr    $0x16,%eax
  801655:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80165c:	a8 01                	test   $0x1,%al
  80165e:	74 46                	je     8016a6 <dup+0xa7>
  801660:	89 d8                	mov    %ebx,%eax
  801662:	c1 e8 0c             	shr    $0xc,%eax
  801665:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80166c:	f6 c2 01             	test   $0x1,%dl
  80166f:	74 35                	je     8016a6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801671:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801678:	25 07 0e 00 00       	and    $0xe07,%eax
  80167d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801681:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801684:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801688:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80168f:	00 
  801690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801694:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169b:	e8 c1 f6 ff ff       	call   800d61 <sys_page_map>
  8016a0:	89 c3                	mov    %eax,%ebx
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 3b                	js     8016e1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016a9:	89 c2                	mov    %eax,%edx
  8016ab:	c1 ea 0c             	shr    $0xc,%edx
  8016ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016b5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ca:	00 
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d6:	e8 86 f6 ff ff       	call   800d61 <sys_page_map>
  8016db:	89 c3                	mov    %eax,%ebx
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	79 25                	jns    801706 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ec:	e8 c3 f6 ff ff       	call   800db4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ff:	e8 b0 f6 ff ff       	call   800db4 <sys_page_unmap>
	return r;
  801704:	eb 02                	jmp    801708 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801706:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	83 c4 4c             	add    $0x4c,%esp
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5f                   	pop    %edi
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	53                   	push   %ebx
  801716:	83 ec 24             	sub    $0x24,%esp
  801719:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801723:	89 1c 24             	mov    %ebx,(%esp)
  801726:	e8 4b fd ff ff       	call   801476 <fd_lookup>
  80172b:	85 c0                	test   %eax,%eax
  80172d:	78 6d                	js     80179c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801732:	89 44 24 04          	mov    %eax,0x4(%esp)
  801736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801739:	8b 00                	mov    (%eax),%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 89 fd ff ff       	call   8014cc <dev_lookup>
  801743:	85 c0                	test   %eax,%eax
  801745:	78 55                	js     80179c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174a:	8b 50 08             	mov    0x8(%eax),%edx
  80174d:	83 e2 03             	and    $0x3,%edx
  801750:	83 fa 01             	cmp    $0x1,%edx
  801753:	75 23                	jne    801778 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801755:	a1 20 54 80 00       	mov    0x805420,%eax
  80175a:	8b 40 48             	mov    0x48(%eax),%eax
  80175d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	c7 04 24 05 31 80 00 	movl   $0x803105,(%esp)
  80176c:	e8 ff eb ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  801771:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801776:	eb 24                	jmp    80179c <read+0x8a>
	}
	if (!dev->dev_read)
  801778:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80177b:	8b 52 08             	mov    0x8(%edx),%edx
  80177e:	85 d2                	test   %edx,%edx
  801780:	74 15                	je     801797 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801782:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801785:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801790:	89 04 24             	mov    %eax,(%esp)
  801793:	ff d2                	call   *%edx
  801795:	eb 05                	jmp    80179c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801797:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80179c:	83 c4 24             	add    $0x24,%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	57                   	push   %edi
  8017a6:	56                   	push   %esi
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 1c             	sub    $0x1c,%esp
  8017ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b6:	eb 23                	jmp    8017db <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b8:	89 f0                	mov    %esi,%eax
  8017ba:	29 d8                	sub    %ebx,%eax
  8017bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c3:	01 d8                	add    %ebx,%eax
  8017c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c9:	89 3c 24             	mov    %edi,(%esp)
  8017cc:	e8 41 ff ff ff       	call   801712 <read>
		if (m < 0)
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 10                	js     8017e5 <readn+0x43>
			return m;
		if (m == 0)
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	74 0a                	je     8017e3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017d9:	01 c3                	add    %eax,%ebx
  8017db:	39 f3                	cmp    %esi,%ebx
  8017dd:	72 d9                	jb     8017b8 <readn+0x16>
  8017df:	89 d8                	mov    %ebx,%eax
  8017e1:	eb 02                	jmp    8017e5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8017e3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8017e5:	83 c4 1c             	add    $0x1c,%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5f                   	pop    %edi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 24             	sub    $0x24,%esp
  8017f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fe:	89 1c 24             	mov    %ebx,(%esp)
  801801:	e8 70 fc ff ff       	call   801476 <fd_lookup>
  801806:	85 c0                	test   %eax,%eax
  801808:	78 68                	js     801872 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80180a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	8b 00                	mov    (%eax),%eax
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 ae fc ff ff       	call   8014cc <dev_lookup>
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 50                	js     801872 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801825:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801829:	75 23                	jne    80184e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80182b:	a1 20 54 80 00       	mov    0x805420,%eax
  801830:	8b 40 48             	mov    0x48(%eax),%eax
  801833:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	c7 04 24 21 31 80 00 	movl   $0x803121,(%esp)
  801842:	e8 29 eb ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  801847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184c:	eb 24                	jmp    801872 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80184e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801851:	8b 52 0c             	mov    0xc(%edx),%edx
  801854:	85 d2                	test   %edx,%edx
  801856:	74 15                	je     80186d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801858:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80185b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80185f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801862:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801866:	89 04 24             	mov    %eax,(%esp)
  801869:	ff d2                	call   *%edx
  80186b:	eb 05                	jmp    801872 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80186d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801872:	83 c4 24             	add    $0x24,%esp
  801875:	5b                   	pop    %ebx
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <seek>:

int
seek(int fdnum, off_t offset)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	89 04 24             	mov    %eax,(%esp)
  80188b:	e8 e6 fb ff ff       	call   801476 <fd_lookup>
  801890:	85 c0                	test   %eax,%eax
  801892:	78 0e                	js     8018a2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801894:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80189a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80189d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 24             	sub    $0x24,%esp
  8018ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b5:	89 1c 24             	mov    %ebx,(%esp)
  8018b8:	e8 b9 fb ff ff       	call   801476 <fd_lookup>
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 61                	js     801922 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cb:	8b 00                	mov    (%eax),%eax
  8018cd:	89 04 24             	mov    %eax,(%esp)
  8018d0:	e8 f7 fb ff ff       	call   8014cc <dev_lookup>
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 49                	js     801922 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018e0:	75 23                	jne    801905 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018e2:	a1 20 54 80 00       	mov    0x805420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018e7:	8b 40 48             	mov    0x48(%eax),%eax
  8018ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f2:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  8018f9:	e8 72 ea ff ff       	call   800370 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801903:	eb 1d                	jmp    801922 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801905:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801908:	8b 52 18             	mov    0x18(%edx),%edx
  80190b:	85 d2                	test   %edx,%edx
  80190d:	74 0e                	je     80191d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80190f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801912:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	ff d2                	call   *%edx
  80191b:	eb 05                	jmp    801922 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80191d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801922:	83 c4 24             	add    $0x24,%esp
  801925:	5b                   	pop    %ebx
  801926:	5d                   	pop    %ebp
  801927:	c3                   	ret    

00801928 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	83 ec 24             	sub    $0x24,%esp
  80192f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801932:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801935:	89 44 24 04          	mov    %eax,0x4(%esp)
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 32 fb ff ff       	call   801476 <fd_lookup>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 52                	js     80199a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801948:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801952:	8b 00                	mov    (%eax),%eax
  801954:	89 04 24             	mov    %eax,(%esp)
  801957:	e8 70 fb ff ff       	call   8014cc <dev_lookup>
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 3a                	js     80199a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801963:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801967:	74 2c                	je     801995 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801969:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80196c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801973:	00 00 00 
	stat->st_isdir = 0;
  801976:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80197d:	00 00 00 
	stat->st_dev = dev;
  801980:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801986:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80198a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198d:	89 14 24             	mov    %edx,(%esp)
  801990:	ff 50 14             	call   *0x14(%eax)
  801993:	eb 05                	jmp    80199a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801995:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80199a:	83 c4 24             	add    $0x24,%esp
  80199d:	5b                   	pop    %ebx
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019af:	00 
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 2d 02 00 00       	call   801be8 <open>
  8019bb:	89 c3                	mov    %eax,%ebx
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 1b                	js     8019dc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8019c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c8:	89 1c 24             	mov    %ebx,(%esp)
  8019cb:	e8 58 ff ff ff       	call   801928 <fstat>
  8019d0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d2:	89 1c 24             	mov    %ebx,(%esp)
  8019d5:	e8 d4 fb ff ff       	call   8015ae <close>
	return r;
  8019da:	89 f3                	mov    %esi,%ebx
}
  8019dc:	89 d8                	mov    %ebx,%eax
  8019de:	83 c4 10             	add    $0x10,%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    
  8019e5:	00 00                	add    %al,(%eax)
	...

008019e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 10             	sub    $0x10,%esp
  8019f0:	89 c3                	mov    %eax,%ebx
  8019f2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019f4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019fb:	75 11                	jne    801a0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a04:	e8 62 0e 00 00       	call   80286b <ipc_find_env>
  801a09:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a15:	00 
  801a16:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a1d:	00 
  801a1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a22:	a1 00 50 80 00       	mov    0x805000,%eax
  801a27:	89 04 24             	mov    %eax,(%esp)
  801a2a:	e8 ce 0d 00 00       	call   8027fd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a36:	00 
  801a37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a42:	e8 4d 0d 00 00       	call   802794 <ipc_recv>
}
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a54:	8b 45 08             	mov    0x8(%ebp),%eax
  801a57:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801a71:	e8 72 ff ff ff       	call   8019e8 <fsipc>
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a81:	8b 40 0c             	mov    0xc(%eax),%eax
  801a84:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a89:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8e:	b8 06 00 00 00       	mov    $0x6,%eax
  801a93:	e8 50 ff ff ff       	call   8019e8 <fsipc>
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 14             	sub    $0x14,%esp
  801aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aaa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab4:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab9:	e8 2a ff ff ff       	call   8019e8 <fsipc>
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 2b                	js     801aed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac2:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ac9:	00 
  801aca:	89 1c 24             	mov    %ebx,(%esp)
  801acd:	e8 49 ee ff ff       	call   80091b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ad2:	a1 80 60 80 00       	mov    0x806080,%eax
  801ad7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801add:	a1 84 60 80 00       	mov    0x806084,%eax
  801ae2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aed:	83 c4 14             	add    $0x14,%esp
  801af0:	5b                   	pop    %ebx
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 18             	sub    $0x18,%esp
  801af9:	8b 55 10             	mov    0x10(%ebp),%edx
  801afc:	89 d0                	mov    %edx,%eax
  801afe:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801b04:	76 05                	jbe    801b0b <devfile_write+0x18>
  801b06:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0e:	8b 52 0c             	mov    0xc(%edx),%edx
  801b11:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b17:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b27:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801b2e:	e8 61 ef ff ff       	call   800a94 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	b8 04 00 00 00       	mov    $0x4,%eax
  801b3d:	e8 a6 fe ff ff       	call   8019e8 <fsipc>
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	56                   	push   %esi
  801b48:	53                   	push   %ebx
  801b49:	83 ec 10             	sub    $0x10,%esp
  801b4c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	8b 40 0c             	mov    0xc(%eax),%eax
  801b55:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b5a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b60:	ba 00 00 00 00       	mov    $0x0,%edx
  801b65:	b8 03 00 00 00       	mov    $0x3,%eax
  801b6a:	e8 79 fe ff ff       	call   8019e8 <fsipc>
  801b6f:	89 c3                	mov    %eax,%ebx
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 6a                	js     801bdf <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b75:	39 c6                	cmp    %eax,%esi
  801b77:	73 24                	jae    801b9d <devfile_read+0x59>
  801b79:	c7 44 24 0c 54 31 80 	movl   $0x803154,0xc(%esp)
  801b80:	00 
  801b81:	c7 44 24 08 5b 31 80 	movl   $0x80315b,0x8(%esp)
  801b88:	00 
  801b89:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b90:	00 
  801b91:	c7 04 24 70 31 80 00 	movl   $0x803170,(%esp)
  801b98:	e8 db e6 ff ff       	call   800278 <_panic>
	assert(r <= PGSIZE);
  801b9d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ba2:	7e 24                	jle    801bc8 <devfile_read+0x84>
  801ba4:	c7 44 24 0c 7b 31 80 	movl   $0x80317b,0xc(%esp)
  801bab:	00 
  801bac:	c7 44 24 08 5b 31 80 	movl   $0x80315b,0x8(%esp)
  801bb3:	00 
  801bb4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bbb:	00 
  801bbc:	c7 04 24 70 31 80 00 	movl   $0x803170,(%esp)
  801bc3:	e8 b0 e6 ff ff       	call   800278 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bcc:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bd3:	00 
  801bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd7:	89 04 24             	mov    %eax,(%esp)
  801bda:	e8 b5 ee ff ff       	call   800a94 <memmove>
	return r;
}
  801bdf:	89 d8                	mov    %ebx,%eax
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	56                   	push   %esi
  801bec:	53                   	push   %ebx
  801bed:	83 ec 20             	sub    $0x20,%esp
  801bf0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bf3:	89 34 24             	mov    %esi,(%esp)
  801bf6:	e8 ed ec ff ff       	call   8008e8 <strlen>
  801bfb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c00:	7f 60                	jg     801c62 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 16 f8 ff ff       	call   801423 <fd_alloc>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 54                	js     801c67 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c17:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801c1e:	e8 f8 ec ff ff       	call   80091b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c26:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c33:	e8 b0 fd ff ff       	call   8019e8 <fsipc>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	79 15                	jns    801c53 <open+0x6b>
		fd_close(fd, 0);
  801c3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c45:	00 
  801c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c49:	89 04 24             	mov    %eax,(%esp)
  801c4c:	e8 d5 f8 ff ff       	call   801526 <fd_close>
		return r;
  801c51:	eb 14                	jmp    801c67 <open+0x7f>
	}

	return fd2num(fd);
  801c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c56:	89 04 24             	mov    %eax,(%esp)
  801c59:	e8 9a f7 ff ff       	call   8013f8 <fd2num>
  801c5e:	89 c3                	mov    %eax,%ebx
  801c60:	eb 05                	jmp    801c67 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c62:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c67:	89 d8                	mov    %ebx,%eax
  801c69:	83 c4 20             	add    $0x20,%esp
  801c6c:	5b                   	pop    %ebx
  801c6d:	5e                   	pop    %esi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c76:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7b:	b8 08 00 00 00       	mov    $0x8,%eax
  801c80:	e8 63 fd ff ff       	call   8019e8 <fsipc>
}
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    
	...

00801c88 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c8e:	c7 44 24 04 87 31 80 	movl   $0x803187,0x4(%esp)
  801c95:	00 
  801c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c99:	89 04 24             	mov    %eax,(%esp)
  801c9c:	e8 7a ec ff ff       	call   80091b <strcpy>
	return 0;
}
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	53                   	push   %ebx
  801cac:	83 ec 14             	sub    $0x14,%esp
  801caf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cb2:	89 1c 24             	mov    %ebx,(%esp)
  801cb5:	e8 ea 0b 00 00       	call   8028a4 <pageref>
  801cba:	83 f8 01             	cmp    $0x1,%eax
  801cbd:	75 0d                	jne    801ccc <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801cbf:	8b 43 0c             	mov    0xc(%ebx),%eax
  801cc2:	89 04 24             	mov    %eax,(%esp)
  801cc5:	e8 1f 03 00 00       	call   801fe9 <nsipc_close>
  801cca:	eb 05                	jmp    801cd1 <devsock_close+0x29>
	else
		return 0;
  801ccc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cd1:	83 c4 14             	add    $0x14,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cdd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ce4:	00 
  801ce5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ce8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf6:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf9:	89 04 24             	mov    %eax,(%esp)
  801cfc:	e8 e3 03 00 00       	call   8020e4 <nsipc_send>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d09:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d10:	00 
  801d11:	8b 45 10             	mov    0x10(%ebp),%eax
  801d14:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d22:	8b 40 0c             	mov    0xc(%eax),%eax
  801d25:	89 04 24             	mov    %eax,(%esp)
  801d28:	e8 37 03 00 00       	call   802064 <nsipc_recv>
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 20             	sub    $0x20,%esp
  801d37:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 df f6 ff ff       	call   801423 <fd_alloc>
  801d44:	89 c3                	mov    %eax,%ebx
  801d46:	85 c0                	test   %eax,%eax
  801d48:	78 21                	js     801d6b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d4a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d51:	00 
  801d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d60:	e8 a8 ef ff ff       	call   800d0d <sys_page_alloc>
  801d65:	89 c3                	mov    %eax,%ebx
  801d67:	85 c0                	test   %eax,%eax
  801d69:	79 0a                	jns    801d75 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d6b:	89 34 24             	mov    %esi,(%esp)
  801d6e:	e8 76 02 00 00       	call   801fe9 <nsipc_close>
		return r;
  801d73:	eb 22                	jmp    801d97 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d75:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d83:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d8a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 63 f6 ff ff       	call   8013f8 <fd2num>
  801d95:	89 c3                	mov    %eax,%ebx
}
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	83 c4 20             	add    $0x20,%esp
  801d9c:	5b                   	pop    %ebx
  801d9d:	5e                   	pop    %esi
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801da6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801da9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dad:	89 04 24             	mov    %eax,(%esp)
  801db0:	e8 c1 f6 ff ff       	call   801476 <fd_lookup>
  801db5:	85 c0                	test   %eax,%eax
  801db7:	78 17                	js     801dd0 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbc:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801dc2:	39 10                	cmp    %edx,(%eax)
  801dc4:	75 05                	jne    801dcb <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801dc6:	8b 40 0c             	mov    0xc(%eax),%eax
  801dc9:	eb 05                	jmp    801dd0 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801dcb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	e8 c0 ff ff ff       	call   801da0 <fd2sockid>
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 1f                	js     801e03 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de4:	8b 55 10             	mov    0x10(%ebp),%edx
  801de7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dee:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df2:	89 04 24             	mov    %eax,(%esp)
  801df5:	e8 38 01 00 00       	call   801f32 <nsipc_accept>
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 05                	js     801e03 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801dfe:	e8 2c ff ff ff       	call   801d2f <alloc_sockfd>
}
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	e8 8d ff ff ff       	call   801da0 <fd2sockid>
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 16                	js     801e2d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801e17:	8b 55 10             	mov    0x10(%ebp),%edx
  801e1a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e25:	89 04 24             	mov    %eax,(%esp)
  801e28:	e8 5b 01 00 00       	call   801f88 <nsipc_bind>
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <shutdown>:

int
shutdown(int s, int how)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	e8 63 ff ff ff       	call   801da0 <fd2sockid>
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 0f                	js     801e50 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e41:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e44:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e48:	89 04 24             	mov    %eax,(%esp)
  801e4b:	e8 77 01 00 00       	call   801fc7 <nsipc_shutdown>
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	e8 40 ff ff ff       	call   801da0 <fd2sockid>
  801e60:	85 c0                	test   %eax,%eax
  801e62:	78 16                	js     801e7a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e64:	8b 55 10             	mov    0x10(%ebp),%edx
  801e67:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e72:	89 04 24             	mov    %eax,(%esp)
  801e75:	e8 89 01 00 00       	call   802003 <nsipc_connect>
}
  801e7a:	c9                   	leave  
  801e7b:	c3                   	ret    

00801e7c <listen>:

int
listen(int s, int backlog)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	e8 16 ff ff ff       	call   801da0 <fd2sockid>
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	78 0f                	js     801e9d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e91:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e95:	89 04 24             	mov    %eax,(%esp)
  801e98:	e8 a5 01 00 00       	call   802042 <nsipc_listen>
}
  801e9d:	c9                   	leave  
  801e9e:	c3                   	ret    

00801e9f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ea5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 99 02 00 00       	call   802157 <nsipc_socket>
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 05                	js     801ec7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ec2:	e8 68 fe ff ff       	call   801d2f <alloc_sockfd>
}
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    
  801ec9:	00 00                	add    %al,(%eax)
	...

00801ecc <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	53                   	push   %ebx
  801ed0:	83 ec 14             	sub    $0x14,%esp
  801ed3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ed5:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801edc:	75 11                	jne    801eef <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ede:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ee5:	e8 81 09 00 00       	call   80286b <ipc_find_env>
  801eea:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801eef:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ef6:	00 
  801ef7:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801efe:	00 
  801eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f03:	a1 04 50 80 00       	mov    0x805004,%eax
  801f08:	89 04 24             	mov    %eax,(%esp)
  801f0b:	e8 ed 08 00 00       	call   8027fd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f17:	00 
  801f18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f1f:	00 
  801f20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f27:	e8 68 08 00 00       	call   802794 <ipc_recv>
}
  801f2c:	83 c4 14             	add    $0x14,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	56                   	push   %esi
  801f36:	53                   	push   %ebx
  801f37:	83 ec 10             	sub    $0x10,%esp
  801f3a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f40:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f45:	8b 06                	mov    (%esi),%eax
  801f47:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f51:	e8 76 ff ff ff       	call   801ecc <nsipc>
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	78 23                	js     801f7f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f5c:	a1 10 70 80 00       	mov    0x807010,%eax
  801f61:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f65:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801f6c:	00 
  801f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	e8 1c eb ff ff       	call   800a94 <memmove>
		*addrlen = ret->ret_addrlen;
  801f78:	a1 10 70 80 00       	mov    0x807010,%eax
  801f7d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f7f:	89 d8                	mov    %ebx,%eax
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	53                   	push   %ebx
  801f8c:	83 ec 14             	sub    $0x14,%esp
  801f8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa5:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801fac:	e8 e3 ea ff ff       	call   800a94 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fb1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801fb7:	b8 02 00 00 00       	mov    $0x2,%eax
  801fbc:	e8 0b ff ff ff       	call   801ecc <nsipc>
}
  801fc1:	83 c4 14             	add    $0x14,%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5d                   	pop    %ebp
  801fc6:	c3                   	ret    

00801fc7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801fdd:	b8 03 00 00 00       	mov    $0x3,%eax
  801fe2:	e8 e5 fe ff ff       	call   801ecc <nsipc>
}
  801fe7:	c9                   	leave  
  801fe8:	c3                   	ret    

00801fe9 <nsipc_close>:

int
nsipc_close(int s)
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ff7:	b8 04 00 00 00       	mov    $0x4,%eax
  801ffc:	e8 cb fe ff ff       	call   801ecc <nsipc>
}
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	53                   	push   %ebx
  802007:	83 ec 14             	sub    $0x14,%esp
  80200a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80200d:	8b 45 08             	mov    0x8(%ebp),%eax
  802010:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802015:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802020:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802027:	e8 68 ea ff ff       	call   800a94 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80202c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802032:	b8 05 00 00 00       	mov    $0x5,%eax
  802037:	e8 90 fe ff ff       	call   801ecc <nsipc>
}
  80203c:	83 c4 14             	add    $0x14,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    

00802042 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802048:	8b 45 08             	mov    0x8(%ebp),%eax
  80204b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802050:	8b 45 0c             	mov    0xc(%ebp),%eax
  802053:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802058:	b8 06 00 00 00       	mov    $0x6,%eax
  80205d:	e8 6a fe ff ff       	call   801ecc <nsipc>
}
  802062:	c9                   	leave  
  802063:	c3                   	ret    

00802064 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802064:	55                   	push   %ebp
  802065:	89 e5                	mov    %esp,%ebp
  802067:	56                   	push   %esi
  802068:	53                   	push   %ebx
  802069:	83 ec 10             	sub    $0x10,%esp
  80206c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80206f:	8b 45 08             	mov    0x8(%ebp),%eax
  802072:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802077:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80207d:	8b 45 14             	mov    0x14(%ebp),%eax
  802080:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802085:	b8 07 00 00 00       	mov    $0x7,%eax
  80208a:	e8 3d fe ff ff       	call   801ecc <nsipc>
  80208f:	89 c3                	mov    %eax,%ebx
  802091:	85 c0                	test   %eax,%eax
  802093:	78 46                	js     8020db <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802095:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80209a:	7f 04                	jg     8020a0 <nsipc_recv+0x3c>
  80209c:	39 c6                	cmp    %eax,%esi
  80209e:	7d 24                	jge    8020c4 <nsipc_recv+0x60>
  8020a0:	c7 44 24 0c 93 31 80 	movl   $0x803193,0xc(%esp)
  8020a7:	00 
  8020a8:	c7 44 24 08 5b 31 80 	movl   $0x80315b,0x8(%esp)
  8020af:	00 
  8020b0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8020b7:	00 
  8020b8:	c7 04 24 a8 31 80 00 	movl   $0x8031a8,(%esp)
  8020bf:	e8 b4 e1 ff ff       	call   800278 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c8:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8020cf:	00 
  8020d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d3:	89 04 24             	mov    %eax,(%esp)
  8020d6:	e8 b9 e9 ff ff       	call   800a94 <memmove>
	}

	return r;
}
  8020db:	89 d8                	mov    %ebx,%eax
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	53                   	push   %ebx
  8020e8:	83 ec 14             	sub    $0x14,%esp
  8020eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020f6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020fc:	7e 24                	jle    802122 <nsipc_send+0x3e>
  8020fe:	c7 44 24 0c b4 31 80 	movl   $0x8031b4,0xc(%esp)
  802105:	00 
  802106:	c7 44 24 08 5b 31 80 	movl   $0x80315b,0x8(%esp)
  80210d:	00 
  80210e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802115:	00 
  802116:	c7 04 24 a8 31 80 00 	movl   $0x8031a8,(%esp)
  80211d:	e8 56 e1 ff ff       	call   800278 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802122:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802126:	8b 45 0c             	mov    0xc(%ebp),%eax
  802129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212d:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802134:	e8 5b e9 ff ff       	call   800a94 <memmove>
	nsipcbuf.send.req_size = size;
  802139:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80213f:	8b 45 14             	mov    0x14(%ebp),%eax
  802142:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802147:	b8 08 00 00 00       	mov    $0x8,%eax
  80214c:	e8 7b fd ff ff       	call   801ecc <nsipc>
}
  802151:	83 c4 14             	add    $0x14,%esp
  802154:	5b                   	pop    %ebx
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    

00802157 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802157:	55                   	push   %ebp
  802158:	89 e5                	mov    %esp,%ebp
  80215a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80215d:	8b 45 08             	mov    0x8(%ebp),%eax
  802160:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802165:	8b 45 0c             	mov    0xc(%ebp),%eax
  802168:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80216d:	8b 45 10             	mov    0x10(%ebp),%eax
  802170:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802175:	b8 09 00 00 00       	mov    $0x9,%eax
  80217a:	e8 4d fd ff ff       	call   801ecc <nsipc>
}
  80217f:	c9                   	leave  
  802180:	c3                   	ret    
  802181:	00 00                	add    %al,(%eax)
	...

00802184 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	56                   	push   %esi
  802188:	53                   	push   %ebx
  802189:	83 ec 10             	sub    $0x10,%esp
  80218c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80218f:	8b 45 08             	mov    0x8(%ebp),%eax
  802192:	89 04 24             	mov    %eax,(%esp)
  802195:	e8 6e f2 ff ff       	call   801408 <fd2data>
  80219a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80219c:	c7 44 24 04 c0 31 80 	movl   $0x8031c0,0x4(%esp)
  8021a3:	00 
  8021a4:	89 34 24             	mov    %esi,(%esp)
  8021a7:	e8 6f e7 ff ff       	call   80091b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8021ac:	8b 43 04             	mov    0x4(%ebx),%eax
  8021af:	2b 03                	sub    (%ebx),%eax
  8021b1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8021b7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8021be:	00 00 00 
	stat->st_dev = &devpipe;
  8021c1:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8021c8:	40 80 00 
	return 0;
}
  8021cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    

008021d7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	53                   	push   %ebx
  8021db:	83 ec 14             	sub    $0x14,%esp
  8021de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ec:	e8 c3 eb ff ff       	call   800db4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021f1:	89 1c 24             	mov    %ebx,(%esp)
  8021f4:	e8 0f f2 ff ff       	call   801408 <fd2data>
  8021f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802204:	e8 ab eb ff ff       	call   800db4 <sys_page_unmap>
}
  802209:	83 c4 14             	add    $0x14,%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    

0080220f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80220f:	55                   	push   %ebp
  802210:	89 e5                	mov    %esp,%ebp
  802212:	57                   	push   %edi
  802213:	56                   	push   %esi
  802214:	53                   	push   %ebx
  802215:	83 ec 2c             	sub    $0x2c,%esp
  802218:	89 c7                	mov    %eax,%edi
  80221a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80221d:	a1 20 54 80 00       	mov    0x805420,%eax
  802222:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802225:	89 3c 24             	mov    %edi,(%esp)
  802228:	e8 77 06 00 00       	call   8028a4 <pageref>
  80222d:	89 c6                	mov    %eax,%esi
  80222f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802232:	89 04 24             	mov    %eax,(%esp)
  802235:	e8 6a 06 00 00       	call   8028a4 <pageref>
  80223a:	39 c6                	cmp    %eax,%esi
  80223c:	0f 94 c0             	sete   %al
  80223f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802242:	8b 15 20 54 80 00    	mov    0x805420,%edx
  802248:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80224b:	39 cb                	cmp    %ecx,%ebx
  80224d:	75 08                	jne    802257 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80224f:	83 c4 2c             	add    $0x2c,%esp
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5f                   	pop    %edi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802257:	83 f8 01             	cmp    $0x1,%eax
  80225a:	75 c1                	jne    80221d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80225c:	8b 42 58             	mov    0x58(%edx),%eax
  80225f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802266:	00 
  802267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80226b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80226f:	c7 04 24 c7 31 80 00 	movl   $0x8031c7,(%esp)
  802276:	e8 f5 e0 ff ff       	call   800370 <cprintf>
  80227b:	eb a0                	jmp    80221d <_pipeisclosed+0xe>

0080227d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80227d:	55                   	push   %ebp
  80227e:	89 e5                	mov    %esp,%ebp
  802280:	57                   	push   %edi
  802281:	56                   	push   %esi
  802282:	53                   	push   %ebx
  802283:	83 ec 1c             	sub    $0x1c,%esp
  802286:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802289:	89 34 24             	mov    %esi,(%esp)
  80228c:	e8 77 f1 ff ff       	call   801408 <fd2data>
  802291:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802293:	bf 00 00 00 00       	mov    $0x0,%edi
  802298:	eb 3c                	jmp    8022d6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80229a:	89 da                	mov    %ebx,%edx
  80229c:	89 f0                	mov    %esi,%eax
  80229e:	e8 6c ff ff ff       	call   80220f <_pipeisclosed>
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	75 38                	jne    8022df <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8022a7:	e8 42 ea ff ff       	call   800cee <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8022ac:	8b 43 04             	mov    0x4(%ebx),%eax
  8022af:	8b 13                	mov    (%ebx),%edx
  8022b1:	83 c2 20             	add    $0x20,%edx
  8022b4:	39 d0                	cmp    %edx,%eax
  8022b6:	73 e2                	jae    80229a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8022b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022bb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8022be:	89 c2                	mov    %eax,%edx
  8022c0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8022c6:	79 05                	jns    8022cd <devpipe_write+0x50>
  8022c8:	4a                   	dec    %edx
  8022c9:	83 ca e0             	or     $0xffffffe0,%edx
  8022cc:	42                   	inc    %edx
  8022cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022d1:	40                   	inc    %eax
  8022d2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d5:	47                   	inc    %edi
  8022d6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8022d9:	75 d1                	jne    8022ac <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8022db:	89 f8                	mov    %edi,%eax
  8022dd:	eb 05                	jmp    8022e4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022df:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    

008022ec <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	57                   	push   %edi
  8022f0:	56                   	push   %esi
  8022f1:	53                   	push   %ebx
  8022f2:	83 ec 1c             	sub    $0x1c,%esp
  8022f5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022f8:	89 3c 24             	mov    %edi,(%esp)
  8022fb:	e8 08 f1 ff ff       	call   801408 <fd2data>
  802300:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802302:	be 00 00 00 00       	mov    $0x0,%esi
  802307:	eb 3a                	jmp    802343 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802309:	85 f6                	test   %esi,%esi
  80230b:	74 04                	je     802311 <devpipe_read+0x25>
				return i;
  80230d:	89 f0                	mov    %esi,%eax
  80230f:	eb 40                	jmp    802351 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802311:	89 da                	mov    %ebx,%edx
  802313:	89 f8                	mov    %edi,%eax
  802315:	e8 f5 fe ff ff       	call   80220f <_pipeisclosed>
  80231a:	85 c0                	test   %eax,%eax
  80231c:	75 2e                	jne    80234c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80231e:	e8 cb e9 ff ff       	call   800cee <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802323:	8b 03                	mov    (%ebx),%eax
  802325:	3b 43 04             	cmp    0x4(%ebx),%eax
  802328:	74 df                	je     802309 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80232a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80232f:	79 05                	jns    802336 <devpipe_read+0x4a>
  802331:	48                   	dec    %eax
  802332:	83 c8 e0             	or     $0xffffffe0,%eax
  802335:	40                   	inc    %eax
  802336:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80233a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802340:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802342:	46                   	inc    %esi
  802343:	3b 75 10             	cmp    0x10(%ebp),%esi
  802346:	75 db                	jne    802323 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802348:	89 f0                	mov    %esi,%eax
  80234a:	eb 05                	jmp    802351 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80234c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802351:	83 c4 1c             	add    $0x1c,%esp
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    

00802359 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	57                   	push   %edi
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	83 ec 3c             	sub    $0x3c,%esp
  802362:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802365:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802368:	89 04 24             	mov    %eax,(%esp)
  80236b:	e8 b3 f0 ff ff       	call   801423 <fd_alloc>
  802370:	89 c3                	mov    %eax,%ebx
  802372:	85 c0                	test   %eax,%eax
  802374:	0f 88 45 01 00 00    	js     8024bf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80237a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802381:	00 
  802382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802385:	89 44 24 04          	mov    %eax,0x4(%esp)
  802389:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802390:	e8 78 e9 ff ff       	call   800d0d <sys_page_alloc>
  802395:	89 c3                	mov    %eax,%ebx
  802397:	85 c0                	test   %eax,%eax
  802399:	0f 88 20 01 00 00    	js     8024bf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80239f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8023a2:	89 04 24             	mov    %eax,(%esp)
  8023a5:	e8 79 f0 ff ff       	call   801423 <fd_alloc>
  8023aa:	89 c3                	mov    %eax,%ebx
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	0f 88 f8 00 00 00    	js     8024ac <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023b4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023bb:	00 
  8023bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ca:	e8 3e e9 ff ff       	call   800d0d <sys_page_alloc>
  8023cf:	89 c3                	mov    %eax,%ebx
  8023d1:	85 c0                	test   %eax,%eax
  8023d3:	0f 88 d3 00 00 00    	js     8024ac <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8023d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023dc:	89 04 24             	mov    %eax,(%esp)
  8023df:	e8 24 f0 ff ff       	call   801408 <fd2data>
  8023e4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023e6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023ed:	00 
  8023ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023f9:	e8 0f e9 ff ff       	call   800d0d <sys_page_alloc>
  8023fe:	89 c3                	mov    %eax,%ebx
  802400:	85 c0                	test   %eax,%eax
  802402:	0f 88 91 00 00 00    	js     802499 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80240b:	89 04 24             	mov    %eax,(%esp)
  80240e:	e8 f5 ef ff ff       	call   801408 <fd2data>
  802413:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80241a:	00 
  80241b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80241f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802426:	00 
  802427:	89 74 24 04          	mov    %esi,0x4(%esp)
  80242b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802432:	e8 2a e9 ff ff       	call   800d61 <sys_page_map>
  802437:	89 c3                	mov    %eax,%ebx
  802439:	85 c0                	test   %eax,%eax
  80243b:	78 4c                	js     802489 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80243d:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802443:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802446:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80244b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802452:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80245b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80245d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802460:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80246a:	89 04 24             	mov    %eax,(%esp)
  80246d:	e8 86 ef ff ff       	call   8013f8 <fd2num>
  802472:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802474:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802477:	89 04 24             	mov    %eax,(%esp)
  80247a:	e8 79 ef ff ff       	call   8013f8 <fd2num>
  80247f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802482:	bb 00 00 00 00       	mov    $0x0,%ebx
  802487:	eb 36                	jmp    8024bf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802489:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802494:	e8 1b e9 ff ff       	call   800db4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802499:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80249c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a7:	e8 08 e9 ff ff       	call   800db4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8024ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024ba:	e8 f5 e8 ff ff       	call   800db4 <sys_page_unmap>
    err:
	return r;
}
  8024bf:	89 d8                	mov    %ebx,%eax
  8024c1:	83 c4 3c             	add    $0x3c,%esp
  8024c4:	5b                   	pop    %ebx
  8024c5:	5e                   	pop    %esi
  8024c6:	5f                   	pop    %edi
  8024c7:	5d                   	pop    %ebp
  8024c8:	c3                   	ret    

008024c9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8024c9:	55                   	push   %ebp
  8024ca:	89 e5                	mov    %esp,%ebp
  8024cc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d9:	89 04 24             	mov    %eax,(%esp)
  8024dc:	e8 95 ef ff ff       	call   801476 <fd_lookup>
  8024e1:	85 c0                	test   %eax,%eax
  8024e3:	78 15                	js     8024fa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8024e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e8:	89 04 24             	mov    %eax,(%esp)
  8024eb:	e8 18 ef ff ff       	call   801408 <fd2data>
	return _pipeisclosed(fd, p);
  8024f0:	89 c2                	mov    %eax,%edx
  8024f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f5:	e8 15 fd ff ff       	call   80220f <_pipeisclosed>
}
  8024fa:	c9                   	leave  
  8024fb:	c3                   	ret    

008024fc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024fc:	55                   	push   %ebp
  8024fd:	89 e5                	mov    %esp,%ebp
  8024ff:	56                   	push   %esi
  802500:	53                   	push   %ebx
  802501:	83 ec 10             	sub    $0x10,%esp
  802504:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802507:	85 f6                	test   %esi,%esi
  802509:	75 24                	jne    80252f <wait+0x33>
  80250b:	c7 44 24 0c df 31 80 	movl   $0x8031df,0xc(%esp)
  802512:	00 
  802513:	c7 44 24 08 5b 31 80 	movl   $0x80315b,0x8(%esp)
  80251a:	00 
  80251b:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802522:	00 
  802523:	c7 04 24 ea 31 80 00 	movl   $0x8031ea,(%esp)
  80252a:	e8 49 dd ff ff       	call   800278 <_panic>
	e = &envs[ENVX(envid)];
  80252f:	89 f3                	mov    %esi,%ebx
  802531:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802537:	c1 e3 07             	shl    $0x7,%ebx
  80253a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802540:	eb 05                	jmp    802547 <wait+0x4b>
		sys_yield();
  802542:	e8 a7 e7 ff ff       	call   800cee <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802547:	8b 43 48             	mov    0x48(%ebx),%eax
  80254a:	39 f0                	cmp    %esi,%eax
  80254c:	75 07                	jne    802555 <wait+0x59>
  80254e:	8b 43 54             	mov    0x54(%ebx),%eax
  802551:	85 c0                	test   %eax,%eax
  802553:	75 ed                	jne    802542 <wait+0x46>
		sys_yield();
}
  802555:	83 c4 10             	add    $0x10,%esp
  802558:	5b                   	pop    %ebx
  802559:	5e                   	pop    %esi
  80255a:	5d                   	pop    %ebp
  80255b:	c3                   	ret    

0080255c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80255c:	55                   	push   %ebp
  80255d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80255f:	b8 00 00 00 00       	mov    $0x0,%eax
  802564:	5d                   	pop    %ebp
  802565:	c3                   	ret    

00802566 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802566:	55                   	push   %ebp
  802567:	89 e5                	mov    %esp,%ebp
  802569:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80256c:	c7 44 24 04 f5 31 80 	movl   $0x8031f5,0x4(%esp)
  802573:	00 
  802574:	8b 45 0c             	mov    0xc(%ebp),%eax
  802577:	89 04 24             	mov    %eax,(%esp)
  80257a:	e8 9c e3 ff ff       	call   80091b <strcpy>
	return 0;
}
  80257f:	b8 00 00 00 00       	mov    $0x0,%eax
  802584:	c9                   	leave  
  802585:	c3                   	ret    

00802586 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802586:	55                   	push   %ebp
  802587:	89 e5                	mov    %esp,%ebp
  802589:	57                   	push   %edi
  80258a:	56                   	push   %esi
  80258b:	53                   	push   %ebx
  80258c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802592:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802597:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80259d:	eb 30                	jmp    8025cf <devcons_write+0x49>
		m = n - tot;
  80259f:	8b 75 10             	mov    0x10(%ebp),%esi
  8025a2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025a4:	83 fe 7f             	cmp    $0x7f,%esi
  8025a7:	76 05                	jbe    8025ae <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8025a9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8025ae:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025b2:	03 45 0c             	add    0xc(%ebp),%eax
  8025b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b9:	89 3c 24             	mov    %edi,(%esp)
  8025bc:	e8 d3 e4 ff ff       	call   800a94 <memmove>
		sys_cputs(buf, m);
  8025c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c5:	89 3c 24             	mov    %edi,(%esp)
  8025c8:	e8 73 e6 ff ff       	call   800c40 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025cd:	01 f3                	add    %esi,%ebx
  8025cf:	89 d8                	mov    %ebx,%eax
  8025d1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025d4:	72 c9                	jb     80259f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8025d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8025dc:	5b                   	pop    %ebx
  8025dd:	5e                   	pop    %esi
  8025de:	5f                   	pop    %edi
  8025df:	5d                   	pop    %ebp
  8025e0:	c3                   	ret    

008025e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8025e1:	55                   	push   %ebp
  8025e2:	89 e5                	mov    %esp,%ebp
  8025e4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8025e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025eb:	75 07                	jne    8025f4 <devcons_read+0x13>
  8025ed:	eb 25                	jmp    802614 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8025ef:	e8 fa e6 ff ff       	call   800cee <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8025f4:	e8 65 e6 ff ff       	call   800c5e <sys_cgetc>
  8025f9:	85 c0                	test   %eax,%eax
  8025fb:	74 f2                	je     8025ef <devcons_read+0xe>
  8025fd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8025ff:	85 c0                	test   %eax,%eax
  802601:	78 1d                	js     802620 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802603:	83 f8 04             	cmp    $0x4,%eax
  802606:	74 13                	je     80261b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80260b:	88 10                	mov    %dl,(%eax)
	return 1;
  80260d:	b8 01 00 00 00       	mov    $0x1,%eax
  802612:	eb 0c                	jmp    802620 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802614:	b8 00 00 00 00       	mov    $0x0,%eax
  802619:	eb 05                	jmp    802620 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80261b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802620:	c9                   	leave  
  802621:	c3                   	ret    

00802622 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802622:	55                   	push   %ebp
  802623:	89 e5                	mov    %esp,%ebp
  802625:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802628:	8b 45 08             	mov    0x8(%ebp),%eax
  80262b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80262e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802635:	00 
  802636:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802639:	89 04 24             	mov    %eax,(%esp)
  80263c:	e8 ff e5 ff ff       	call   800c40 <sys_cputs>
}
  802641:	c9                   	leave  
  802642:	c3                   	ret    

00802643 <getchar>:

int
getchar(void)
{
  802643:	55                   	push   %ebp
  802644:	89 e5                	mov    %esp,%ebp
  802646:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802649:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802650:	00 
  802651:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802654:	89 44 24 04          	mov    %eax,0x4(%esp)
  802658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265f:	e8 ae f0 ff ff       	call   801712 <read>
	if (r < 0)
  802664:	85 c0                	test   %eax,%eax
  802666:	78 0f                	js     802677 <getchar+0x34>
		return r;
	if (r < 1)
  802668:	85 c0                	test   %eax,%eax
  80266a:	7e 06                	jle    802672 <getchar+0x2f>
		return -E_EOF;
	return c;
  80266c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802670:	eb 05                	jmp    802677 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802672:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802677:	c9                   	leave  
  802678:	c3                   	ret    

00802679 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802679:	55                   	push   %ebp
  80267a:	89 e5                	mov    %esp,%ebp
  80267c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80267f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802682:	89 44 24 04          	mov    %eax,0x4(%esp)
  802686:	8b 45 08             	mov    0x8(%ebp),%eax
  802689:	89 04 24             	mov    %eax,(%esp)
  80268c:	e8 e5 ed ff ff       	call   801476 <fd_lookup>
  802691:	85 c0                	test   %eax,%eax
  802693:	78 11                	js     8026a6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802698:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80269e:	39 10                	cmp    %edx,(%eax)
  8026a0:	0f 94 c0             	sete   %al
  8026a3:	0f b6 c0             	movzbl %al,%eax
}
  8026a6:	c9                   	leave  
  8026a7:	c3                   	ret    

008026a8 <opencons>:

int
opencons(void)
{
  8026a8:	55                   	push   %ebp
  8026a9:	89 e5                	mov    %esp,%ebp
  8026ab:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026b1:	89 04 24             	mov    %eax,(%esp)
  8026b4:	e8 6a ed ff ff       	call   801423 <fd_alloc>
  8026b9:	85 c0                	test   %eax,%eax
  8026bb:	78 3c                	js     8026f9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8026bd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026c4:	00 
  8026c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d3:	e8 35 e6 ff ff       	call   800d0d <sys_page_alloc>
  8026d8:	85 c0                	test   %eax,%eax
  8026da:	78 1d                	js     8026f9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8026dc:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8026e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026ea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026f1:	89 04 24             	mov    %eax,(%esp)
  8026f4:	e8 ff ec ff ff       	call   8013f8 <fd2num>
}
  8026f9:	c9                   	leave  
  8026fa:	c3                   	ret    
	...

008026fc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026fc:	55                   	push   %ebp
  8026fd:	89 e5                	mov    %esp,%ebp
  8026ff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802702:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802709:	75 58                	jne    802763 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80270b:	a1 20 54 80 00       	mov    0x805420,%eax
  802710:	8b 40 48             	mov    0x48(%eax),%eax
  802713:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80271a:	00 
  80271b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802722:	ee 
  802723:	89 04 24             	mov    %eax,(%esp)
  802726:	e8 e2 e5 ff ff       	call   800d0d <sys_page_alloc>
  80272b:	85 c0                	test   %eax,%eax
  80272d:	74 1c                	je     80274b <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  80272f:	c7 44 24 08 01 32 80 	movl   $0x803201,0x8(%esp)
  802736:	00 
  802737:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80273e:	00 
  80273f:	c7 04 24 16 32 80 00 	movl   $0x803216,(%esp)
  802746:	e8 2d db ff ff       	call   800278 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80274b:	a1 20 54 80 00       	mov    0x805420,%eax
  802750:	8b 40 48             	mov    0x48(%eax),%eax
  802753:	c7 44 24 04 70 27 80 	movl   $0x802770,0x4(%esp)
  80275a:	00 
  80275b:	89 04 24             	mov    %eax,(%esp)
  80275e:	e8 4a e7 ff ff       	call   800ead <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802763:	8b 45 08             	mov    0x8(%ebp),%eax
  802766:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80276b:	c9                   	leave  
  80276c:	c3                   	ret    
  80276d:	00 00                	add    %al,(%eax)
	...

00802770 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802770:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802771:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802776:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802778:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80277b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80277f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802781:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802785:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802786:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802789:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80278b:	58                   	pop    %eax
	popl %eax
  80278c:	58                   	pop    %eax

	// Pop all registers back
	popal
  80278d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80278e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802791:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802792:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802793:	c3                   	ret    

00802794 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802794:	55                   	push   %ebp
  802795:	89 e5                	mov    %esp,%ebp
  802797:	56                   	push   %esi
  802798:	53                   	push   %ebx
  802799:	83 ec 10             	sub    $0x10,%esp
  80279c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80279f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027a2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8027a5:	85 c0                	test   %eax,%eax
  8027a7:	75 05                	jne    8027ae <ipc_recv+0x1a>
  8027a9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8027ae:	89 04 24             	mov    %eax,(%esp)
  8027b1:	e8 6d e7 ff ff       	call   800f23 <sys_ipc_recv>
	if (from_env_store != NULL)
  8027b6:	85 db                	test   %ebx,%ebx
  8027b8:	74 0b                	je     8027c5 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8027ba:	8b 15 20 54 80 00    	mov    0x805420,%edx
  8027c0:	8b 52 74             	mov    0x74(%edx),%edx
  8027c3:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8027c5:	85 f6                	test   %esi,%esi
  8027c7:	74 0b                	je     8027d4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8027c9:	8b 15 20 54 80 00    	mov    0x805420,%edx
  8027cf:	8b 52 78             	mov    0x78(%edx),%edx
  8027d2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8027d4:	85 c0                	test   %eax,%eax
  8027d6:	79 16                	jns    8027ee <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8027d8:	85 db                	test   %ebx,%ebx
  8027da:	74 06                	je     8027e2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8027dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8027e2:	85 f6                	test   %esi,%esi
  8027e4:	74 10                	je     8027f6 <ipc_recv+0x62>
			*perm_store = 0;
  8027e6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8027ec:	eb 08                	jmp    8027f6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8027ee:	a1 20 54 80 00       	mov    0x805420,%eax
  8027f3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027f6:	83 c4 10             	add    $0x10,%esp
  8027f9:	5b                   	pop    %ebx
  8027fa:	5e                   	pop    %esi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    

008027fd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027fd:	55                   	push   %ebp
  8027fe:	89 e5                	mov    %esp,%ebp
  802800:	57                   	push   %edi
  802801:	56                   	push   %esi
  802802:	53                   	push   %ebx
  802803:	83 ec 1c             	sub    $0x1c,%esp
  802806:	8b 75 08             	mov    0x8(%ebp),%esi
  802809:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80280c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80280f:	eb 2a                	jmp    80283b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802811:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802814:	74 20                	je     802836 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802816:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80281a:	c7 44 24 08 24 32 80 	movl   $0x803224,0x8(%esp)
  802821:	00 
  802822:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802829:	00 
  80282a:	c7 04 24 4c 32 80 00 	movl   $0x80324c,(%esp)
  802831:	e8 42 da ff ff       	call   800278 <_panic>
		sys_yield();
  802836:	e8 b3 e4 ff ff       	call   800cee <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80283b:	85 db                	test   %ebx,%ebx
  80283d:	75 07                	jne    802846 <ipc_send+0x49>
  80283f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802844:	eb 02                	jmp    802848 <ipc_send+0x4b>
  802846:	89 d8                	mov    %ebx,%eax
  802848:	8b 55 14             	mov    0x14(%ebp),%edx
  80284b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80284f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802853:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802857:	89 34 24             	mov    %esi,(%esp)
  80285a:	e8 a1 e6 ff ff       	call   800f00 <sys_ipc_try_send>
  80285f:	85 c0                	test   %eax,%eax
  802861:	78 ae                	js     802811 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802863:	83 c4 1c             	add    $0x1c,%esp
  802866:	5b                   	pop    %ebx
  802867:	5e                   	pop    %esi
  802868:	5f                   	pop    %edi
  802869:	5d                   	pop    %ebp
  80286a:	c3                   	ret    

0080286b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80286b:	55                   	push   %ebp
  80286c:	89 e5                	mov    %esp,%ebp
  80286e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802871:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802876:	89 c2                	mov    %eax,%edx
  802878:	c1 e2 07             	shl    $0x7,%edx
  80287b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802881:	8b 52 50             	mov    0x50(%edx),%edx
  802884:	39 ca                	cmp    %ecx,%edx
  802886:	75 0d                	jne    802895 <ipc_find_env+0x2a>
			return envs[i].env_id;
  802888:	c1 e0 07             	shl    $0x7,%eax
  80288b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802890:	8b 40 40             	mov    0x40(%eax),%eax
  802893:	eb 0c                	jmp    8028a1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802895:	40                   	inc    %eax
  802896:	3d 00 04 00 00       	cmp    $0x400,%eax
  80289b:	75 d9                	jne    802876 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80289d:	66 b8 00 00          	mov    $0x0,%ax
}
  8028a1:	5d                   	pop    %ebp
  8028a2:	c3                   	ret    
	...

008028a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028a4:	55                   	push   %ebp
  8028a5:	89 e5                	mov    %esp,%ebp
  8028a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028aa:	89 c2                	mov    %eax,%edx
  8028ac:	c1 ea 16             	shr    $0x16,%edx
  8028af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028b6:	f6 c2 01             	test   $0x1,%dl
  8028b9:	74 1e                	je     8028d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028bb:	c1 e8 0c             	shr    $0xc,%eax
  8028be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8028c5:	a8 01                	test   $0x1,%al
  8028c7:	74 17                	je     8028e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028c9:	c1 e8 0c             	shr    $0xc,%eax
  8028cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8028d3:	ef 
  8028d4:	0f b7 c0             	movzwl %ax,%eax
  8028d7:	eb 0c                	jmp    8028e5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8028d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8028de:	eb 05                	jmp    8028e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8028e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8028e5:	5d                   	pop    %ebp
  8028e6:	c3                   	ret    
	...

008028e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8028e8:	55                   	push   %ebp
  8028e9:	57                   	push   %edi
  8028ea:	56                   	push   %esi
  8028eb:	83 ec 10             	sub    $0x10,%esp
  8028ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8028f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8028fe:	89 cd                	mov    %ecx,%ebp
  802900:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802904:	85 c0                	test   %eax,%eax
  802906:	75 2c                	jne    802934 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802908:	39 f9                	cmp    %edi,%ecx
  80290a:	77 68                	ja     802974 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80290c:	85 c9                	test   %ecx,%ecx
  80290e:	75 0b                	jne    80291b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802910:	b8 01 00 00 00       	mov    $0x1,%eax
  802915:	31 d2                	xor    %edx,%edx
  802917:	f7 f1                	div    %ecx
  802919:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80291b:	31 d2                	xor    %edx,%edx
  80291d:	89 f8                	mov    %edi,%eax
  80291f:	f7 f1                	div    %ecx
  802921:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802923:	89 f0                	mov    %esi,%eax
  802925:	f7 f1                	div    %ecx
  802927:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802929:	89 f0                	mov    %esi,%eax
  80292b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80292d:	83 c4 10             	add    $0x10,%esp
  802930:	5e                   	pop    %esi
  802931:	5f                   	pop    %edi
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802934:	39 f8                	cmp    %edi,%eax
  802936:	77 2c                	ja     802964 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802938:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80293b:	83 f6 1f             	xor    $0x1f,%esi
  80293e:	75 4c                	jne    80298c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802940:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802942:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802947:	72 0a                	jb     802953 <__udivdi3+0x6b>
  802949:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80294d:	0f 87 ad 00 00 00    	ja     802a00 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802953:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802958:	89 f0                	mov    %esi,%eax
  80295a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80295c:	83 c4 10             	add    $0x10,%esp
  80295f:	5e                   	pop    %esi
  802960:	5f                   	pop    %edi
  802961:	5d                   	pop    %ebp
  802962:	c3                   	ret    
  802963:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802964:	31 ff                	xor    %edi,%edi
  802966:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802968:	89 f0                	mov    %esi,%eax
  80296a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80296c:	83 c4 10             	add    $0x10,%esp
  80296f:	5e                   	pop    %esi
  802970:	5f                   	pop    %edi
  802971:	5d                   	pop    %ebp
  802972:	c3                   	ret    
  802973:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802974:	89 fa                	mov    %edi,%edx
  802976:	89 f0                	mov    %esi,%eax
  802978:	f7 f1                	div    %ecx
  80297a:	89 c6                	mov    %eax,%esi
  80297c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80297e:	89 f0                	mov    %esi,%eax
  802980:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802982:	83 c4 10             	add    $0x10,%esp
  802985:	5e                   	pop    %esi
  802986:	5f                   	pop    %edi
  802987:	5d                   	pop    %ebp
  802988:	c3                   	ret    
  802989:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80298c:	89 f1                	mov    %esi,%ecx
  80298e:	d3 e0                	shl    %cl,%eax
  802990:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802994:	b8 20 00 00 00       	mov    $0x20,%eax
  802999:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80299b:	89 ea                	mov    %ebp,%edx
  80299d:	88 c1                	mov    %al,%cl
  80299f:	d3 ea                	shr    %cl,%edx
  8029a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8029a5:	09 ca                	or     %ecx,%edx
  8029a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8029ab:	89 f1                	mov    %esi,%ecx
  8029ad:	d3 e5                	shl    %cl,%ebp
  8029af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8029b3:	89 fd                	mov    %edi,%ebp
  8029b5:	88 c1                	mov    %al,%cl
  8029b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8029b9:	89 fa                	mov    %edi,%edx
  8029bb:	89 f1                	mov    %esi,%ecx
  8029bd:	d3 e2                	shl    %cl,%edx
  8029bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029c3:	88 c1                	mov    %al,%cl
  8029c5:	d3 ef                	shr    %cl,%edi
  8029c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029c9:	89 f8                	mov    %edi,%eax
  8029cb:	89 ea                	mov    %ebp,%edx
  8029cd:	f7 74 24 08          	divl   0x8(%esp)
  8029d1:	89 d1                	mov    %edx,%ecx
  8029d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8029d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029d9:	39 d1                	cmp    %edx,%ecx
  8029db:	72 17                	jb     8029f4 <__udivdi3+0x10c>
  8029dd:	74 09                	je     8029e8 <__udivdi3+0x100>
  8029df:	89 fe                	mov    %edi,%esi
  8029e1:	31 ff                	xor    %edi,%edi
  8029e3:	e9 41 ff ff ff       	jmp    802929 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8029e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029ec:	89 f1                	mov    %esi,%ecx
  8029ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029f0:	39 c2                	cmp    %eax,%edx
  8029f2:	73 eb                	jae    8029df <__udivdi3+0xf7>
		{
		  q0--;
  8029f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8029f7:	31 ff                	xor    %edi,%edi
  8029f9:	e9 2b ff ff ff       	jmp    802929 <__udivdi3+0x41>
  8029fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a00:	31 f6                	xor    %esi,%esi
  802a02:	e9 22 ff ff ff       	jmp    802929 <__udivdi3+0x41>
	...

00802a08 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a08:	55                   	push   %ebp
  802a09:	57                   	push   %edi
  802a0a:	56                   	push   %esi
  802a0b:	83 ec 20             	sub    $0x20,%esp
  802a0e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a12:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a16:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a1a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a1e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a22:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a26:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802a28:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a2a:	85 ed                	test   %ebp,%ebp
  802a2c:	75 16                	jne    802a44 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802a2e:	39 f1                	cmp    %esi,%ecx
  802a30:	0f 86 a6 00 00 00    	jbe    802adc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a36:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a38:	89 d0                	mov    %edx,%eax
  802a3a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a3c:	83 c4 20             	add    $0x20,%esp
  802a3f:	5e                   	pop    %esi
  802a40:	5f                   	pop    %edi
  802a41:	5d                   	pop    %ebp
  802a42:	c3                   	ret    
  802a43:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a44:	39 f5                	cmp    %esi,%ebp
  802a46:	0f 87 ac 00 00 00    	ja     802af8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a4c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802a4f:	83 f0 1f             	xor    $0x1f,%eax
  802a52:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a56:	0f 84 a8 00 00 00    	je     802b04 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a5c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a60:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a62:	bf 20 00 00 00       	mov    $0x20,%edi
  802a67:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802a6b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a6f:	89 f9                	mov    %edi,%ecx
  802a71:	d3 e8                	shr    %cl,%eax
  802a73:	09 e8                	or     %ebp,%eax
  802a75:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802a79:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a7d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a81:	d3 e0                	shl    %cl,%eax
  802a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a87:	89 f2                	mov    %esi,%edx
  802a89:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802a8b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a8f:	d3 e0                	shl    %cl,%eax
  802a91:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a95:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a99:	89 f9                	mov    %edi,%ecx
  802a9b:	d3 e8                	shr    %cl,%eax
  802a9d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802a9f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802aa1:	89 f2                	mov    %esi,%edx
  802aa3:	f7 74 24 18          	divl   0x18(%esp)
  802aa7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802aa9:	f7 64 24 0c          	mull   0xc(%esp)
  802aad:	89 c5                	mov    %eax,%ebp
  802aaf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ab1:	39 d6                	cmp    %edx,%esi
  802ab3:	72 67                	jb     802b1c <__umoddi3+0x114>
  802ab5:	74 75                	je     802b2c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802ab7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802abb:	29 e8                	sub    %ebp,%eax
  802abd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802abf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ac3:	d3 e8                	shr    %cl,%eax
  802ac5:	89 f2                	mov    %esi,%edx
  802ac7:	89 f9                	mov    %edi,%ecx
  802ac9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802acb:	09 d0                	or     %edx,%eax
  802acd:	89 f2                	mov    %esi,%edx
  802acf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ad3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ad5:	83 c4 20             	add    $0x20,%esp
  802ad8:	5e                   	pop    %esi
  802ad9:	5f                   	pop    %edi
  802ada:	5d                   	pop    %ebp
  802adb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802adc:	85 c9                	test   %ecx,%ecx
  802ade:	75 0b                	jne    802aeb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ae0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ae5:	31 d2                	xor    %edx,%edx
  802ae7:	f7 f1                	div    %ecx
  802ae9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802aeb:	89 f0                	mov    %esi,%eax
  802aed:	31 d2                	xor    %edx,%edx
  802aef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802af1:	89 f8                	mov    %edi,%eax
  802af3:	e9 3e ff ff ff       	jmp    802a36 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802af8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802afa:	83 c4 20             	add    $0x20,%esp
  802afd:	5e                   	pop    %esi
  802afe:	5f                   	pop    %edi
  802aff:	5d                   	pop    %ebp
  802b00:	c3                   	ret    
  802b01:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b04:	39 f5                	cmp    %esi,%ebp
  802b06:	72 04                	jb     802b0c <__umoddi3+0x104>
  802b08:	39 f9                	cmp    %edi,%ecx
  802b0a:	77 06                	ja     802b12 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b0c:	89 f2                	mov    %esi,%edx
  802b0e:	29 cf                	sub    %ecx,%edi
  802b10:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b12:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b14:	83 c4 20             	add    $0x20,%esp
  802b17:	5e                   	pop    %esi
  802b18:	5f                   	pop    %edi
  802b19:	5d                   	pop    %ebp
  802b1a:	c3                   	ret    
  802b1b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b1c:	89 d1                	mov    %edx,%ecx
  802b1e:	89 c5                	mov    %eax,%ebp
  802b20:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b24:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b28:	eb 8d                	jmp    802ab7 <__umoddi3+0xaf>
  802b2a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b2c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b30:	72 ea                	jb     802b1c <__umoddi3+0x114>
  802b32:	89 f1                	mov    %esi,%ecx
  802b34:	eb 81                	jmp    802ab7 <__umoddi3+0xaf>
