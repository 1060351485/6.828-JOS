
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
  800045:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  80004c:	e8 2b 1b 00 00       	call   801b7c <open>
  800051:	89 c3                	mov    %eax,%ebx
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("open motd: %e", fd);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 05 26 80 	movl   $0x802605,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 13 26 80 00 	movl   $0x802613,(%esp)
  800072:	e8 0d 02 00 00       	call   800284 <_panic>
	seek(fd, 0);
  800077:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007e:	00 
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 85 17 00 00       	call   80180c <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800087:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 20 42 80 	movl   $0x804220,0x4(%esp)
  800096:	00 
  800097:	89 1c 24             	mov    %ebx,(%esp)
  80009a:	e8 97 16 00 00       	call   801736 <readn>
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	7f 20                	jg     8000c5 <umain+0x91>
		panic("readn: %e", n);
  8000a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a9:	c7 44 24 08 28 26 80 	movl   $0x802628,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b8:	00 
  8000b9:	c7 04 24 13 26 80 00 	movl   $0x802613,(%esp)
  8000c0:	e8 bf 01 00 00       	call   800284 <_panic>

	if ((r = fork()) < 0)
  8000c5:	e8 c9 0f 00 00       	call   801093 <fork>
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	79 20                	jns    8000f0 <umain+0xbc>
		panic("fork: %e", r);
  8000d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d4:	c7 44 24 08 32 26 80 	movl   $0x802632,0x8(%esp)
  8000db:	00 
  8000dc:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8000e3:	00 
  8000e4:	c7 04 24 13 26 80 00 	movl   $0x802613,(%esp)
  8000eb:	e8 94 01 00 00       	call   800284 <_panic>
	if (r == 0) {
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	0f 85 bd 00 00 00    	jne    8001b5 <umain+0x181>
		seek(fd, 0);
  8000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ff:	00 
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	e8 04 17 00 00       	call   80180c <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  800108:	c7 04 24 70 26 80 00 	movl   $0x802670,(%esp)
  80010f:	e8 68 02 00 00       	call   80037c <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800114:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80011b:	00 
  80011c:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800123:	00 
  800124:	89 1c 24             	mov    %ebx,(%esp)
  800127:	e8 0a 16 00 00       	call   801736 <readn>
  80012c:	39 f8                	cmp    %edi,%eax
  80012e:	74 24                	je     800154 <umain+0x120>
			panic("read in parent got %d, read in child got %d", n, n2);
  800130:	89 44 24 10          	mov    %eax,0x10(%esp)
  800134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800138:	c7 44 24 08 b4 26 80 	movl   $0x8026b4,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  800147:	00 
  800148:	c7 04 24 13 26 80 00 	movl   $0x802613,(%esp)
  80014f:	e8 30 01 00 00       	call   800284 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800154:	89 44 24 08          	mov    %eax,0x8(%esp)
  800158:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  80015f:	00 
  800160:	c7 04 24 20 42 80 00 	movl   $0x804220,(%esp)
  800167:	e8 bf 09 00 00       	call   800b2b <memcmp>
  80016c:	85 c0                	test   %eax,%eax
  80016e:	74 1c                	je     80018c <umain+0x158>
			panic("read in parent got different bytes from read in child");
  800170:	c7 44 24 08 e0 26 80 	movl   $0x8026e0,0x8(%esp)
  800177:	00 
  800178:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80017f:	00 
  800180:	c7 04 24 13 26 80 00 	movl   $0x802613,(%esp)
  800187:	e8 f8 00 00 00       	call   800284 <_panic>
		cprintf("read in child succeeded\n");
  80018c:	c7 04 24 3b 26 80 00 	movl   $0x80263b,(%esp)
  800193:	e8 e4 01 00 00       	call   80037c <cprintf>
		seek(fd, 0);
  800198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80019f:	00 
  8001a0:	89 1c 24             	mov    %ebx,(%esp)
  8001a3:	e8 64 16 00 00       	call   80180c <seek>
		close(fd);
  8001a8:	89 1c 24             	mov    %ebx,(%esp)
  8001ab:	e8 92 13 00 00       	call   801542 <close>
		exit();
  8001b0:	e8 bb 00 00 00       	call   800270 <exit>
	}
	wait(r);
  8001b5:	89 34 24             	mov    %esi,(%esp)
  8001b8:	e8 d7 1d 00 00       	call   801f94 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8001bd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  8001cc:	00 
  8001cd:	89 1c 24             	mov    %ebx,(%esp)
  8001d0:	e8 61 15 00 00       	call   801736 <readn>
  8001d5:	39 f8                	cmp    %edi,%eax
  8001d7:	74 24                	je     8001fd <umain+0x1c9>
		panic("read in parent got %d, then got %d", n, n2);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8001e1:	c7 44 24 08 18 27 80 	movl   $0x802718,0x8(%esp)
  8001e8:	00 
  8001e9:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8001f0:	00 
  8001f1:	c7 04 24 13 26 80 00 	movl   $0x802613,(%esp)
  8001f8:	e8 87 00 00 00       	call   800284 <_panic>
	cprintf("read in parent succeeded\n");
  8001fd:	c7 04 24 54 26 80 00 	movl   $0x802654,(%esp)
  800204:	e8 73 01 00 00       	call   80037c <cprintf>
	close(fd);
  800209:	89 1c 24             	mov    %ebx,(%esp)
  80020c:	e8 31 13 00 00       	call   801542 <close>
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
  80022a:	e8 ac 0a 00 00       	call   800cdb <sys_getenvid>
  80022f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800234:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80023b:	c1 e0 07             	shl    $0x7,%eax
  80023e:	29 d0                	sub    %edx,%eax
  800240:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800245:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80024a:	85 f6                	test   %esi,%esi
  80024c:	7e 07                	jle    800255 <libmain+0x39>
		binaryname = argv[0];
  80024e:	8b 03                	mov    (%ebx),%eax
  800250:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	e8 d3 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800261:	e8 0a 00 00 00       	call   800270 <exit>
}
  800266:	83 c4 10             	add    $0x10,%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800276:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80027d:	e8 07 0a 00 00       	call   800c89 <sys_env_destroy>
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80028c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80028f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800295:	e8 41 0a 00 00       	call   800cdb <sys_getenvid>
  80029a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b0:	c7 04 24 48 27 80 00 	movl   $0x802748,(%esp)
  8002b7:	e8 c0 00 00 00       	call   80037c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	e8 50 00 00 00       	call   80031b <vcprintf>
	cprintf("\n");
  8002cb:	c7 04 24 52 26 80 00 	movl   $0x802652,(%esp)
  8002d2:	e8 a5 00 00 00       	call   80037c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d7:	cc                   	int3   
  8002d8:	eb fd                	jmp    8002d7 <_panic+0x53>
	...

008002dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 14             	sub    $0x14,%esp
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e6:	8b 03                	mov    (%ebx),%eax
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002ef:	40                   	inc    %eax
  8002f0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f7:	75 19                	jne    800312 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002f9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800300:	00 
  800301:	8d 43 08             	lea    0x8(%ebx),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 40 09 00 00       	call   800c4c <sys_cputs>
		b->idx = 0;
  80030c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800312:	ff 43 04             	incl   0x4(%ebx)
}
  800315:	83 c4 14             	add    $0x14,%esp
  800318:	5b                   	pop    %ebx
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800324:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032b:	00 00 00 
	b.cnt = 0;
  80032e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800335:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	89 44 24 08          	mov    %eax,0x8(%esp)
  800346:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80034c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800350:	c7 04 24 dc 02 80 00 	movl   $0x8002dc,(%esp)
  800357:	e8 82 01 00 00       	call   8004de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80035c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800362:	89 44 24 04          	mov    %eax,0x4(%esp)
  800366:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 d8 08 00 00       	call   800c4c <sys_cputs>

	return b.cnt;
}
  800374:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800382:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 87 ff ff ff       	call   80031b <vcprintf>
	va_end(ap);

	return cnt;
}
  800394:	c9                   	leave  
  800395:	c3                   	ret    
	...

00800398 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	57                   	push   %edi
  80039c:	56                   	push   %esi
  80039d:	53                   	push   %ebx
  80039e:	83 ec 3c             	sub    $0x3c,%esp
  8003a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a4:	89 d7                	mov    %edx,%edi
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003b5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	75 08                	jne    8003c4 <printnum+0x2c>
  8003bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003bf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003c2:	77 57                	ja     80041b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003c4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003c8:	4b                   	dec    %ebx
  8003c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003d8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e3:	00 
  8003e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e7:	89 04 24             	mov    %eax,(%esp)
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	e8 a2 1f 00 00       	call   802398 <__udivdi3>
  8003f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003fa:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003fe:	89 04 24             	mov    %eax,(%esp)
  800401:	89 54 24 04          	mov    %edx,0x4(%esp)
  800405:	89 fa                	mov    %edi,%edx
  800407:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040a:	e8 89 ff ff ff       	call   800398 <printnum>
  80040f:	eb 0f                	jmp    800420 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800411:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800415:	89 34 24             	mov    %esi,(%esp)
  800418:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80041b:	4b                   	dec    %ebx
  80041c:	85 db                	test   %ebx,%ebx
  80041e:	7f f1                	jg     800411 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800420:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800424:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800428:	8b 45 10             	mov    0x10(%ebp),%eax
  80042b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80042f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800436:	00 
  800437:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80043a:	89 04 24             	mov    %eax,(%esp)
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	89 44 24 04          	mov    %eax,0x4(%esp)
  800444:	e8 6f 20 00 00       	call   8024b8 <__umoddi3>
  800449:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044d:	0f be 80 6b 27 80 00 	movsbl 0x80276b(%eax),%eax
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80045a:	83 c4 3c             	add    $0x3c,%esp
  80045d:	5b                   	pop    %ebx
  80045e:	5e                   	pop    %esi
  80045f:	5f                   	pop    %edi
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800465:	83 fa 01             	cmp    $0x1,%edx
  800468:	7e 0e                	jle    800478 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80046a:	8b 10                	mov    (%eax),%edx
  80046c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046f:	89 08                	mov    %ecx,(%eax)
  800471:	8b 02                	mov    (%edx),%eax
  800473:	8b 52 04             	mov    0x4(%edx),%edx
  800476:	eb 22                	jmp    80049a <getuint+0x38>
	else if (lflag)
  800478:	85 d2                	test   %edx,%edx
  80047a:	74 10                	je     80048c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80047c:	8b 10                	mov    (%eax),%edx
  80047e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800481:	89 08                	mov    %ecx,(%eax)
  800483:	8b 02                	mov    (%edx),%eax
  800485:	ba 00 00 00 00       	mov    $0x0,%edx
  80048a:	eb 0e                	jmp    80049a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80048c:	8b 10                	mov    (%eax),%edx
  80048e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800491:	89 08                	mov    %ecx,(%eax)
  800493:	8b 02                	mov    (%edx),%eax
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004aa:	73 08                	jae    8004b4 <sprintputch+0x18>
		*b->buf++ = ch;
  8004ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004af:	88 0a                	mov    %cl,(%edx)
  8004b1:	42                   	inc    %edx
  8004b2:	89 10                	mov    %edx,(%eax)
}
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 02 00 00 00       	call   8004de <vprintfmt>
	va_end(ap);
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 4c             	sub    $0x4c,%esp
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	8b 75 10             	mov    0x10(%ebp),%esi
  8004ed:	eb 12                	jmp    800501 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	0f 84 6b 03 00 00    	je     800862 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800501:	0f b6 06             	movzbl (%esi),%eax
  800504:	46                   	inc    %esi
  800505:	83 f8 25             	cmp    $0x25,%eax
  800508:	75 e5                	jne    8004ef <vprintfmt+0x11>
  80050a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80050e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800515:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80051a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800521:	b9 00 00 00 00       	mov    $0x0,%ecx
  800526:	eb 26                	jmp    80054e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80052b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80052f:	eb 1d                	jmp    80054e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800534:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800538:	eb 14                	jmp    80054e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80053d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800544:	eb 08                	jmp    80054e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800546:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800549:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	0f b6 06             	movzbl (%esi),%eax
  800551:	8d 56 01             	lea    0x1(%esi),%edx
  800554:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800557:	8a 16                	mov    (%esi),%dl
  800559:	83 ea 23             	sub    $0x23,%edx
  80055c:	80 fa 55             	cmp    $0x55,%dl
  80055f:	0f 87 e1 02 00 00    	ja     800846 <vprintfmt+0x368>
  800565:	0f b6 d2             	movzbl %dl,%edx
  800568:	ff 24 95 a0 28 80 00 	jmp    *0x8028a0(,%edx,4)
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800577:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80057a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80057e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800581:	8d 50 d0             	lea    -0x30(%eax),%edx
  800584:	83 fa 09             	cmp    $0x9,%edx
  800587:	77 2a                	ja     8005b3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800589:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80058a:	eb eb                	jmp    800577 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80059a:	eb 17                	jmp    8005b3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80059c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a0:	78 98                	js     80053a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a5:	eb a7                	jmp    80054e <vprintfmt+0x70>
  8005a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005aa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005b1:	eb 9b                	jmp    80054e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b7:	79 95                	jns    80054e <vprintfmt+0x70>
  8005b9:	eb 8b                	jmp    800546 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005bb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005bf:	eb 8d                	jmp    80054e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005d9:	e9 23 ff ff ff       	jmp    800501 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	79 02                	jns    8005ef <vprintfmt+0x111>
  8005ed:	f7 d8                	neg    %eax
  8005ef:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f1:	83 f8 0f             	cmp    $0xf,%eax
  8005f4:	7f 0b                	jg     800601 <vprintfmt+0x123>
  8005f6:	8b 04 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%eax
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	75 23                	jne    800624 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800601:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800605:	c7 44 24 08 83 27 80 	movl   $0x802783,0x8(%esp)
  80060c:	00 
  80060d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800611:	8b 45 08             	mov    0x8(%ebp),%eax
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	e8 9a fe ff ff       	call   8004b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80061f:	e9 dd fe ff ff       	jmp    800501 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800624:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800628:	c7 44 24 08 21 2c 80 	movl   $0x802c21,0x8(%esp)
  80062f:	00 
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	8b 55 08             	mov    0x8(%ebp),%edx
  800637:	89 14 24             	mov    %edx,(%esp)
  80063a:	e8 77 fe ff ff       	call   8004b6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800642:	e9 ba fe ff ff       	jmp    800501 <vprintfmt+0x23>
  800647:	89 f9                	mov    %edi,%ecx
  800649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 30                	mov    (%eax),%esi
  80065a:	85 f6                	test   %esi,%esi
  80065c:	75 05                	jne    800663 <vprintfmt+0x185>
				p = "(null)";
  80065e:	be 7c 27 80 00       	mov    $0x80277c,%esi
			if (width > 0 && padc != '-')
  800663:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800667:	0f 8e 84 00 00 00    	jle    8006f1 <vprintfmt+0x213>
  80066d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800671:	74 7e                	je     8006f1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800673:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800677:	89 34 24             	mov    %esi,(%esp)
  80067a:	e8 8b 02 00 00       	call   80090a <strnlen>
  80067f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800682:	29 c2                	sub    %eax,%edx
  800684:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800687:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80068b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80068e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800691:	89 de                	mov    %ebx,%esi
  800693:	89 d3                	mov    %edx,%ebx
  800695:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	eb 0b                	jmp    8006a4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800699:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069d:	89 3c 24             	mov    %edi,(%esp)
  8006a0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a3:	4b                   	dec    %ebx
  8006a4:	85 db                	test   %ebx,%ebx
  8006a6:	7f f1                	jg     800699 <vprintfmt+0x1bb>
  8006a8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006ab:	89 f3                	mov    %esi,%ebx
  8006ad:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	79 05                	jns    8006bc <vprintfmt+0x1de>
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006bf:	29 c2                	sub    %eax,%edx
  8006c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006c4:	eb 2b                	jmp    8006f1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006c6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ca:	74 18                	je     8006e4 <vprintfmt+0x206>
  8006cc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006cf:	83 fa 5e             	cmp    $0x5e,%edx
  8006d2:	76 10                	jbe    8006e4 <vprintfmt+0x206>
					putch('?', putdat);
  8006d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006df:	ff 55 08             	call   *0x8(%ebp)
  8006e2:	eb 0a                	jmp    8006ee <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e8:	89 04 24             	mov    %eax,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ee:	ff 4d e4             	decl   -0x1c(%ebp)
  8006f1:	0f be 06             	movsbl (%esi),%eax
  8006f4:	46                   	inc    %esi
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 21                	je     80071a <vprintfmt+0x23c>
  8006f9:	85 ff                	test   %edi,%edi
  8006fb:	78 c9                	js     8006c6 <vprintfmt+0x1e8>
  8006fd:	4f                   	dec    %edi
  8006fe:	79 c6                	jns    8006c6 <vprintfmt+0x1e8>
  800700:	8b 7d 08             	mov    0x8(%ebp),%edi
  800703:	89 de                	mov    %ebx,%esi
  800705:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800708:	eb 18                	jmp    800722 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80070a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80070e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800715:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800717:	4b                   	dec    %ebx
  800718:	eb 08                	jmp    800722 <vprintfmt+0x244>
  80071a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071d:	89 de                	mov    %ebx,%esi
  80071f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800722:	85 db                	test   %ebx,%ebx
  800724:	7f e4                	jg     80070a <vprintfmt+0x22c>
  800726:	89 7d 08             	mov    %edi,0x8(%ebp)
  800729:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80072e:	e9 ce fd ff ff       	jmp    800501 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800733:	83 f9 01             	cmp    $0x1,%ecx
  800736:	7e 10                	jle    800748 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8d 50 08             	lea    0x8(%eax),%edx
  80073e:	89 55 14             	mov    %edx,0x14(%ebp)
  800741:	8b 30                	mov    (%eax),%esi
  800743:	8b 78 04             	mov    0x4(%eax),%edi
  800746:	eb 26                	jmp    80076e <vprintfmt+0x290>
	else if (lflag)
  800748:	85 c9                	test   %ecx,%ecx
  80074a:	74 12                	je     80075e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 04             	lea    0x4(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 30                	mov    (%eax),%esi
  800757:	89 f7                	mov    %esi,%edi
  800759:	c1 ff 1f             	sar    $0x1f,%edi
  80075c:	eb 10                	jmp    80076e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8d 50 04             	lea    0x4(%eax),%edx
  800764:	89 55 14             	mov    %edx,0x14(%ebp)
  800767:	8b 30                	mov    (%eax),%esi
  800769:	89 f7                	mov    %esi,%edi
  80076b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80076e:	85 ff                	test   %edi,%edi
  800770:	78 0a                	js     80077c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800772:	b8 0a 00 00 00       	mov    $0xa,%eax
  800777:	e9 8c 00 00 00       	jmp    800808 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80078a:	f7 de                	neg    %esi
  80078c:	83 d7 00             	adc    $0x0,%edi
  80078f:	f7 df                	neg    %edi
			}
			base = 10;
  800791:	b8 0a 00 00 00       	mov    $0xa,%eax
  800796:	eb 70                	jmp    800808 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800798:	89 ca                	mov    %ecx,%edx
  80079a:	8d 45 14             	lea    0x14(%ebp),%eax
  80079d:	e8 c0 fc ff ff       	call   800462 <getuint>
  8007a2:	89 c6                	mov    %eax,%esi
  8007a4:	89 d7                	mov    %edx,%edi
			base = 10;
  8007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007ab:	eb 5b                	jmp    800808 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8007ad:	89 ca                	mov    %ecx,%edx
  8007af:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b2:	e8 ab fc ff ff       	call   800462 <getuint>
  8007b7:	89 c6                	mov    %eax,%esi
  8007b9:	89 d7                	mov    %edx,%edi
			base = 8;
  8007bb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c0:	eb 46                	jmp    800808 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007db:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 50 04             	lea    0x4(%eax),%edx
  8007e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e7:	8b 30                	mov    (%eax),%esi
  8007e9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f3:	eb 13                	jmp    800808 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f5:	89 ca                	mov    %ecx,%edx
  8007f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fa:	e8 63 fc ff ff       	call   800462 <getuint>
  8007ff:	89 c6                	mov    %eax,%esi
  800801:	89 d7                	mov    %edx,%edi
			base = 16;
  800803:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800808:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80080c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800810:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800813:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800817:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081b:	89 34 24             	mov    %esi,(%esp)
  80081e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800822:	89 da                	mov    %ebx,%edx
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	e8 6c fb ff ff       	call   800398 <printnum>
			break;
  80082c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80082f:	e9 cd fc ff ff       	jmp    800501 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800834:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800838:	89 04 24             	mov    %eax,(%esp)
  80083b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800841:	e9 bb fc ff ff       	jmp    800501 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800846:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800851:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800854:	eb 01                	jmp    800857 <vprintfmt+0x379>
  800856:	4e                   	dec    %esi
  800857:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80085b:	75 f9                	jne    800856 <vprintfmt+0x378>
  80085d:	e9 9f fc ff ff       	jmp    800501 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800862:	83 c4 4c             	add    $0x4c,%esp
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5f                   	pop    %edi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 28             	sub    $0x28,%esp
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800876:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800879:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80087d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800880:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800887:	85 c0                	test   %eax,%eax
  800889:	74 30                	je     8008bb <vsnprintf+0x51>
  80088b:	85 d2                	test   %edx,%edx
  80088d:	7e 33                	jle    8008c2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
  800899:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	c7 04 24 9c 04 80 00 	movl   $0x80049c,(%esp)
  8008ab:	e8 2e fc ff ff       	call   8004de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b9:	eb 0c                	jmp    8008c7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c0:	eb 05                	jmp    8008c7 <vsnprintf+0x5d>
  8008c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	89 04 24             	mov    %eax,(%esp)
  8008ea:	e8 7b ff ff ff       	call   80086a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    
  8008f1:	00 00                	add    %al,(%eax)
	...

008008f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	eb 01                	jmp    800902 <strlen+0xe>
		n++;
  800901:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800902:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800906:	75 f9                	jne    800901 <strlen+0xd>
		n++;
	return n;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	eb 01                	jmp    80091b <strnlen+0x11>
		n++;
  80091a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	74 06                	je     800925 <strnlen+0x1b>
  80091f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800923:	75 f5                	jne    80091a <strnlen+0x10>
		n++;
	return n;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800931:	ba 00 00 00 00       	mov    $0x0,%edx
  800936:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800939:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80093c:	42                   	inc    %edx
  80093d:	84 c9                	test   %cl,%cl
  80093f:	75 f5                	jne    800936 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800941:	5b                   	pop    %ebx
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	83 ec 08             	sub    $0x8,%esp
  80094b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094e:	89 1c 24             	mov    %ebx,(%esp)
  800951:	e8 9e ff ff ff       	call   8008f4 <strlen>
	strcpy(dst + len, src);
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
  800959:	89 54 24 04          	mov    %edx,0x4(%esp)
  80095d:	01 d8                	add    %ebx,%eax
  80095f:	89 04 24             	mov    %eax,(%esp)
  800962:	e8 c0 ff ff ff       	call   800927 <strcpy>
	return dst;
}
  800967:	89 d8                	mov    %ebx,%eax
  800969:	83 c4 08             	add    $0x8,%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800982:	eb 0c                	jmp    800990 <strncpy+0x21>
		*dst++ = *src;
  800984:	8a 1a                	mov    (%edx),%bl
  800986:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800989:	80 3a 01             	cmpb   $0x1,(%edx)
  80098c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098f:	41                   	inc    %ecx
  800990:	39 f1                	cmp    %esi,%ecx
  800992:	75 f0                	jne    800984 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a6:	85 d2                	test   %edx,%edx
  8009a8:	75 0a                	jne    8009b4 <strlcpy+0x1c>
  8009aa:	89 f0                	mov    %esi,%eax
  8009ac:	eb 1a                	jmp    8009c8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ae:	88 18                	mov    %bl,(%eax)
  8009b0:	40                   	inc    %eax
  8009b1:	41                   	inc    %ecx
  8009b2:	eb 02                	jmp    8009b6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009b6:	4a                   	dec    %edx
  8009b7:	74 0a                	je     8009c3 <strlcpy+0x2b>
  8009b9:	8a 19                	mov    (%ecx),%bl
  8009bb:	84 db                	test   %bl,%bl
  8009bd:	75 ef                	jne    8009ae <strlcpy+0x16>
  8009bf:	89 c2                	mov    %eax,%edx
  8009c1:	eb 02                	jmp    8009c5 <strlcpy+0x2d>
  8009c3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009c5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009c8:	29 f0                	sub    %esi,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d7:	eb 02                	jmp    8009db <strcmp+0xd>
		p++, q++;
  8009d9:	41                   	inc    %ecx
  8009da:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009db:	8a 01                	mov    (%ecx),%al
  8009dd:	84 c0                	test   %al,%al
  8009df:	74 04                	je     8009e5 <strcmp+0x17>
  8009e1:	3a 02                	cmp    (%edx),%al
  8009e3:	74 f4                	je     8009d9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e5:	0f b6 c0             	movzbl %al,%eax
  8009e8:	0f b6 12             	movzbl (%edx),%edx
  8009eb:	29 d0                	sub    %edx,%eax
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009fc:	eb 03                	jmp    800a01 <strncmp+0x12>
		n--, p++, q++;
  8009fe:	4a                   	dec    %edx
  8009ff:	40                   	inc    %eax
  800a00:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 14                	je     800a19 <strncmp+0x2a>
  800a05:	8a 18                	mov    (%eax),%bl
  800a07:	84 db                	test   %bl,%bl
  800a09:	74 04                	je     800a0f <strncmp+0x20>
  800a0b:	3a 19                	cmp    (%ecx),%bl
  800a0d:	74 ef                	je     8009fe <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0f:	0f b6 00             	movzbl (%eax),%eax
  800a12:	0f b6 11             	movzbl (%ecx),%edx
  800a15:	29 d0                	sub    %edx,%eax
  800a17:	eb 05                	jmp    800a1e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a2a:	eb 05                	jmp    800a31 <strchr+0x10>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 0c                	je     800a3c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a30:	40                   	inc    %eax
  800a31:	8a 10                	mov    (%eax),%dl
  800a33:	84 d2                	test   %dl,%dl
  800a35:	75 f5                	jne    800a2c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a47:	eb 05                	jmp    800a4e <strfind+0x10>
		if (*s == c)
  800a49:	38 ca                	cmp    %cl,%dl
  800a4b:	74 07                	je     800a54 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4d:	40                   	inc    %eax
  800a4e:	8a 10                	mov    (%eax),%dl
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 f5                	jne    800a49 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a65:	85 c9                	test   %ecx,%ecx
  800a67:	74 30                	je     800a99 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6f:	75 25                	jne    800a96 <memset+0x40>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 20                	jne    800a96 <memset+0x40>
		c &= 0xFF;
  800a76:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a79:	89 d3                	mov    %edx,%ebx
  800a7b:	c1 e3 08             	shl    $0x8,%ebx
  800a7e:	89 d6                	mov    %edx,%esi
  800a80:	c1 e6 18             	shl    $0x18,%esi
  800a83:	89 d0                	mov    %edx,%eax
  800a85:	c1 e0 10             	shl    $0x10,%eax
  800a88:	09 f0                	or     %esi,%eax
  800a8a:	09 d0                	or     %edx,%eax
  800a8c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a91:	fc                   	cld    
  800a92:	f3 ab                	rep stos %eax,%es:(%edi)
  800a94:	eb 03                	jmp    800a99 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a96:	fc                   	cld    
  800a97:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a99:	89 f8                	mov    %edi,%eax
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aae:	39 c6                	cmp    %eax,%esi
  800ab0:	73 34                	jae    800ae6 <memmove+0x46>
  800ab2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab5:	39 d0                	cmp    %edx,%eax
  800ab7:	73 2d                	jae    800ae6 <memmove+0x46>
		s += n;
		d += n;
  800ab9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abc:	f6 c2 03             	test   $0x3,%dl
  800abf:	75 1b                	jne    800adc <memmove+0x3c>
  800ac1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac7:	75 13                	jne    800adc <memmove+0x3c>
  800ac9:	f6 c1 03             	test   $0x3,%cl
  800acc:	75 0e                	jne    800adc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ace:	83 ef 04             	sub    $0x4,%edi
  800ad1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ad7:	fd                   	std    
  800ad8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ada:	eb 07                	jmp    800ae3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adc:	4f                   	dec    %edi
  800add:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae0:	fd                   	std    
  800ae1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae3:	fc                   	cld    
  800ae4:	eb 20                	jmp    800b06 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aec:	75 13                	jne    800b01 <memmove+0x61>
  800aee:	a8 03                	test   $0x3,%al
  800af0:	75 0f                	jne    800b01 <memmove+0x61>
  800af2:	f6 c1 03             	test   $0x3,%cl
  800af5:	75 0a                	jne    800b01 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800afa:	89 c7                	mov    %eax,%edi
  800afc:	fc                   	cld    
  800afd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aff:	eb 05                	jmp    800b06 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b01:	89 c7                	mov    %eax,%edi
  800b03:	fc                   	cld    
  800b04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b10:	8b 45 10             	mov    0x10(%ebp),%eax
  800b13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	89 04 24             	mov    %eax,(%esp)
  800b24:	e8 77 ff ff ff       	call   800aa0 <memmove>
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	eb 16                	jmp    800b57 <memcmp+0x2c>
		if (*s1 != *s2)
  800b41:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b44:	42                   	inc    %edx
  800b45:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b49:	38 c8                	cmp    %cl,%al
  800b4b:	74 0a                	je     800b57 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b4d:	0f b6 c0             	movzbl %al,%eax
  800b50:	0f b6 c9             	movzbl %cl,%ecx
  800b53:	29 c8                	sub    %ecx,%eax
  800b55:	eb 09                	jmp    800b60 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b57:	39 da                	cmp    %ebx,%edx
  800b59:	75 e6                	jne    800b41 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b73:	eb 05                	jmp    800b7a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b75:	38 08                	cmp    %cl,(%eax)
  800b77:	74 05                	je     800b7e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b79:	40                   	inc    %eax
  800b7a:	39 d0                	cmp    %edx,%eax
  800b7c:	72 f7                	jb     800b75 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8c:	eb 01                	jmp    800b8f <strtol+0xf>
		s++;
  800b8e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8f:	8a 02                	mov    (%edx),%al
  800b91:	3c 20                	cmp    $0x20,%al
  800b93:	74 f9                	je     800b8e <strtol+0xe>
  800b95:	3c 09                	cmp    $0x9,%al
  800b97:	74 f5                	je     800b8e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b99:	3c 2b                	cmp    $0x2b,%al
  800b9b:	75 08                	jne    800ba5 <strtol+0x25>
		s++;
  800b9d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba3:	eb 13                	jmp    800bb8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ba5:	3c 2d                	cmp    $0x2d,%al
  800ba7:	75 0a                	jne    800bb3 <strtol+0x33>
		s++, neg = 1;
  800ba9:	8d 52 01             	lea    0x1(%edx),%edx
  800bac:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb1:	eb 05                	jmp    800bb8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	85 db                	test   %ebx,%ebx
  800bba:	74 05                	je     800bc1 <strtol+0x41>
  800bbc:	83 fb 10             	cmp    $0x10,%ebx
  800bbf:	75 28                	jne    800be9 <strtol+0x69>
  800bc1:	8a 02                	mov    (%edx),%al
  800bc3:	3c 30                	cmp    $0x30,%al
  800bc5:	75 10                	jne    800bd7 <strtol+0x57>
  800bc7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcb:	75 0a                	jne    800bd7 <strtol+0x57>
		s += 2, base = 16;
  800bcd:	83 c2 02             	add    $0x2,%edx
  800bd0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd5:	eb 12                	jmp    800be9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bd7:	85 db                	test   %ebx,%ebx
  800bd9:	75 0e                	jne    800be9 <strtol+0x69>
  800bdb:	3c 30                	cmp    $0x30,%al
  800bdd:	75 05                	jne    800be4 <strtol+0x64>
		s++, base = 8;
  800bdf:	42                   	inc    %edx
  800be0:	b3 08                	mov    $0x8,%bl
  800be2:	eb 05                	jmp    800be9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800be4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf0:	8a 0a                	mov    (%edx),%cl
  800bf2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf5:	80 fb 09             	cmp    $0x9,%bl
  800bf8:	77 08                	ja     800c02 <strtol+0x82>
			dig = *s - '0';
  800bfa:	0f be c9             	movsbl %cl,%ecx
  800bfd:	83 e9 30             	sub    $0x30,%ecx
  800c00:	eb 1e                	jmp    800c20 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c02:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c05:	80 fb 19             	cmp    $0x19,%bl
  800c08:	77 08                	ja     800c12 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c0a:	0f be c9             	movsbl %cl,%ecx
  800c0d:	83 e9 57             	sub    $0x57,%ecx
  800c10:	eb 0e                	jmp    800c20 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c12:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c15:	80 fb 19             	cmp    $0x19,%bl
  800c18:	77 12                	ja     800c2c <strtol+0xac>
			dig = *s - 'A' + 10;
  800c1a:	0f be c9             	movsbl %cl,%ecx
  800c1d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c20:	39 f1                	cmp    %esi,%ecx
  800c22:	7d 0c                	jge    800c30 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c24:	42                   	inc    %edx
  800c25:	0f af c6             	imul   %esi,%eax
  800c28:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c2a:	eb c4                	jmp    800bf0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c2c:	89 c1                	mov    %eax,%ecx
  800c2e:	eb 02                	jmp    800c32 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c30:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c36:	74 05                	je     800c3d <strtol+0xbd>
		*endptr = (char *) s;
  800c38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c3d:	85 ff                	test   %edi,%edi
  800c3f:	74 04                	je     800c45 <strtol+0xc5>
  800c41:	89 c8                	mov    %ecx,%eax
  800c43:	f7 d8                	neg    %eax
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
	...

00800c4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 c3                	mov    %eax,%ebx
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	89 c6                	mov    %eax,%esi
  800c63:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7a:	89 d1                	mov    %edx,%ecx
  800c7c:	89 d3                	mov    %edx,%ebx
  800c7e:	89 d7                	mov    %edx,%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c97:	b8 03 00 00 00       	mov    $0x3,%eax
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 cb                	mov    %ecx,%ebx
  800ca1:	89 cf                	mov    %ecx,%edi
  800ca3:	89 ce                	mov    %ecx,%esi
  800ca5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 28                	jle    800cd3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cb6:	00 
  800cb7:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800cce:	e8 b1 f5 ff ff       	call   800284 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd3:	83 c4 2c             	add    $0x2c,%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ceb:	89 d1                	mov    %edx,%ecx
  800ced:	89 d3                	mov    %edx,%ebx
  800cef:	89 d7                	mov    %edx,%edi
  800cf1:	89 d6                	mov    %edx,%esi
  800cf3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_yield>:

void
sys_yield(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0a:	89 d1                	mov    %edx,%ecx
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	89 d7                	mov    %edx,%edi
  800d10:	89 d6                	mov    %edx,%esi
  800d12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 f7                	mov    %esi,%edi
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800d60:	e8 1f f5 ff ff       	call   800284 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d65:	83 c4 2c             	add    $0x2c,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b8 05 00 00 00       	mov    $0x5,%eax
  800d7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 28                	jle    800db8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d9b:	00 
  800d9c:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800da3:	00 
  800da4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dab:	00 
  800dac:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800db3:	e8 cc f4 ff ff       	call   800284 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800db8:	83 c4 2c             	add    $0x2c,%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 28                	jle    800e0b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800e06:	e8 79 f4 ff ff       	call   800284 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0b:	83 c4 2c             	add    $0x2c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    

00800e13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	57                   	push   %edi
  800e17:	56                   	push   %esi
  800e18:	53                   	push   %ebx
  800e19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	b8 08 00 00 00       	mov    $0x8,%eax
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 df                	mov    %ebx,%edi
  800e2e:	89 de                	mov    %ebx,%esi
  800e30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e32:	85 c0                	test   %eax,%eax
  800e34:	7e 28                	jle    800e5e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e36:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e51:	00 
  800e52:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800e59:	e8 26 f4 ff ff       	call   800284 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e5e:	83 c4 2c             	add    $0x2c,%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	b8 09 00 00 00       	mov    $0x9,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	89 df                	mov    %ebx,%edi
  800e81:	89 de                	mov    %ebx,%esi
  800e83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 28                	jle    800eb1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800eac:	e8 d3 f3 ff ff       	call   800284 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb1:	83 c4 2c             	add    $0x2c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 df                	mov    %ebx,%edi
  800ed4:	89 de                	mov    %ebx,%esi
  800ed6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 28                	jle    800f04 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800eef:	00 
  800ef0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef7:	00 
  800ef8:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800eff:	e8 80 f3 ff ff       	call   800284 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f04:	83 c4 2c             	add    $0x2c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	57                   	push   %edi
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	be 00 00 00 00       	mov    $0x0,%esi
  800f17:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f1c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	89 cb                	mov    %ecx,%ebx
  800f47:	89 cf                	mov    %ecx,%edi
  800f49:	89 ce                	mov    %ecx,%esi
  800f4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	7e 28                	jle    800f79 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f55:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 08 5f 2a 80 	movl   $0x802a5f,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6c:	00 
  800f6d:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  800f74:	e8 0b f3 ff ff       	call   800284 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f79:	83 c4 2c             	add    $0x2c,%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    
  800f81:	00 00                	add    %al,(%eax)
	...

00800f84 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	53                   	push   %ebx
  800f88:	83 ec 24             	sub    $0x24,%esp
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f8e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800f90:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f94:	75 20                	jne    800fb6 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f96:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f9a:	c7 44 24 08 8c 2a 80 	movl   $0x802a8c,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800fa9:	00 
  800faa:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  800fb1:	e8 ce f2 ff ff       	call   800284 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fb6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fc1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc8:	f6 c4 08             	test   $0x8,%ah
  800fcb:	75 1c                	jne    800fe9 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800fcd:	c7 44 24 08 bc 2a 80 	movl   $0x802abc,0x8(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  800fe4:	e8 9b f2 ff ff       	call   800284 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fe9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ff8:	00 
  800ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801000:	e8 14 fd ff ff       	call   800d19 <sys_page_alloc>
  801005:	85 c0                	test   %eax,%eax
  801007:	79 20                	jns    801029 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100d:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  801014:	00 
  801015:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80101c:	00 
  80101d:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801024:	e8 5b f2 ff ff       	call   800284 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801029:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801030:	00 
  801031:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801035:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80103c:	e8 5f fa ff ff       	call   800aa0 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801041:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801048:	00 
  801049:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80104d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801064:	e8 04 fd ff ff       	call   800d6d <sys_page_map>
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 20                	jns    80108d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80106d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801071:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801088:	e8 f7 f1 ff ff       	call   800284 <_panic>

}
  80108d:	83 c4 24             	add    $0x24,%esp
  801090:	5b                   	pop    %ebx
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80109c:	c7 04 24 84 0f 80 00 	movl   $0x800f84,(%esp)
  8010a3:	e8 f8 10 00 00       	call   8021a0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010a8:	ba 07 00 00 00       	mov    $0x7,%edx
  8010ad:	89 d0                	mov    %edx,%eax
  8010af:	cd 30                	int    $0x30
  8010b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010b4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	79 20                	jns    8010db <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8010bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010bf:	c7 44 24 08 3d 2b 80 	movl   $0x802b3d,0x8(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  8010d6:	e8 a9 f1 ff ff       	call   800284 <_panic>
	if (child_envid == 0) { // child
  8010db:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010df:	75 25                	jne    801106 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8010e1:	e8 f5 fb ff ff       	call   800cdb <sys_getenvid>
  8010e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010f2:	c1 e0 07             	shl    $0x7,%eax
  8010f5:	29 d0                	sub    %edx,%eax
  8010f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010fc:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  801101:	e9 58 02 00 00       	jmp    80135e <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801106:	bf 00 00 00 00       	mov    $0x0,%edi
  80110b:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801110:	89 f0                	mov    %esi,%eax
  801112:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801115:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111c:	a8 01                	test   $0x1,%al
  80111e:	0f 84 7a 01 00 00    	je     80129e <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801124:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80112b:	a8 01                	test   $0x1,%al
  80112d:	0f 84 6b 01 00 00    	je     80129e <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801133:	a1 20 44 80 00       	mov    0x804420,%eax
  801138:	8b 40 48             	mov    0x48(%eax),%eax
  80113b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  80113e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801145:	f6 c4 04             	test   $0x4,%ah
  801148:	74 52                	je     80119c <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80114a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801151:	25 07 0e 00 00       	and    $0xe07,%eax
  801156:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80115e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801161:	89 44 24 08          	mov    %eax,0x8(%esp)
  801165:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801169:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80116c:	89 04 24             	mov    %eax,(%esp)
  80116f:	e8 f9 fb ff ff       	call   800d6d <sys_page_map>
  801174:	85 c0                	test   %eax,%eax
  801176:	0f 89 22 01 00 00    	jns    80129e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80117c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801180:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801187:	00 
  801188:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80118f:	00 
  801190:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801197:	e8 e8 f0 ff ff       	call   800284 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80119c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011a3:	f6 c4 08             	test   $0x8,%ah
  8011a6:	75 0f                	jne    8011b7 <fork+0x124>
  8011a8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011af:	a8 02                	test   $0x2,%al
  8011b1:	0f 84 99 00 00 00    	je     801250 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8011b7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011be:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011c1:	83 f8 01             	cmp    $0x1,%eax
  8011c4:	19 db                	sbb    %ebx,%ebx
  8011c6:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011c9:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011cf:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011d3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e5:	89 04 24             	mov    %eax,(%esp)
  8011e8:	e8 80 fb ff ff       	call   800d6d <sys_page_map>
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	79 20                	jns    801211 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8011f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f5:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  8011fc:	00 
  8011fd:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801204:	00 
  801205:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  80120c:	e8 73 f0 ff ff       	call   800284 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801211:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801215:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80121c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801220:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801224:	89 04 24             	mov    %eax,(%esp)
  801227:	e8 41 fb ff ff       	call   800d6d <sys_page_map>
  80122c:	85 c0                	test   %eax,%eax
  80122e:	79 6e                	jns    80129e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801234:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  80123b:	00 
  80123c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801243:	00 
  801244:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  80124b:	e8 34 f0 ff ff       	call   800284 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801250:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801257:	25 07 0e 00 00       	and    $0xe07,%eax
  80125c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801260:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801264:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80126b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80126f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801272:	89 04 24             	mov    %eax,(%esp)
  801275:	e8 f3 fa ff ff       	call   800d6d <sys_page_map>
  80127a:	85 c0                	test   %eax,%eax
  80127c:	79 20                	jns    80129e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80127e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801282:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801289:	00 
  80128a:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801291:	00 
  801292:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801299:	e8 e6 ef ff ff       	call   800284 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80129e:	46                   	inc    %esi
  80129f:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012a5:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8012ab:	0f 85 5f fe ff ff    	jne    801110 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8012b1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012c0:	ee 
  8012c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c4:	89 04 24             	mov    %eax,(%esp)
  8012c7:	e8 4d fa ff ff       	call   800d19 <sys_page_alloc>
  8012cc:	85 c0                	test   %eax,%eax
  8012ce:	79 20                	jns    8012f0 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  8012d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d4:	c7 44 24 08 17 2b 80 	movl   $0x802b17,0x8(%esp)
  8012db:	00 
  8012dc:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012e3:	00 
  8012e4:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  8012eb:	e8 94 ef ff ff       	call   800284 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8012f0:	c7 44 24 04 14 22 80 	movl   $0x802214,0x4(%esp)
  8012f7:	00 
  8012f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012fb:	89 04 24             	mov    %eax,(%esp)
  8012fe:	e8 b6 fb ff ff       	call   800eb9 <sys_env_set_pgfault_upcall>
  801303:	85 c0                	test   %eax,%eax
  801305:	79 20                	jns    801327 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801307:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130b:	c7 44 24 08 ec 2a 80 	movl   $0x802aec,0x8(%esp)
  801312:	00 
  801313:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  80131a:	00 
  80131b:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801322:	e8 5d ef ff ff       	call   800284 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801327:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80132e:	00 
  80132f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 d9 fa ff ff       	call   800e13 <sys_env_set_status>
  80133a:	85 c0                	test   %eax,%eax
  80133c:	79 20                	jns    80135e <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  80133e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801342:	c7 44 24 08 4e 2b 80 	movl   $0x802b4e,0x8(%esp)
  801349:	00 
  80134a:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801351:	00 
  801352:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801359:	e8 26 ef ff ff       	call   800284 <_panic>

	return child_envid;
}
  80135e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801361:	83 c4 3c             	add    $0x3c,%esp
  801364:	5b                   	pop    %ebx
  801365:	5e                   	pop    %esi
  801366:	5f                   	pop    %edi
  801367:	5d                   	pop    %ebp
  801368:	c3                   	ret    

00801369 <sfork>:

// Challenge!
int
sfork(void)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80136f:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  801376:	00 
  801377:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80137e:	00 
  80137f:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  801386:	e8 f9 ee ff ff       	call   800284 <_panic>
	...

0080138c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80138f:	8b 45 08             	mov    0x8(%ebp),%eax
  801392:	05 00 00 00 30       	add    $0x30000000,%eax
  801397:	c1 e8 0c             	shr    $0xc,%eax
}
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	89 04 24             	mov    %eax,(%esp)
  8013a8:	e8 df ff ff ff       	call   80138c <fd2num>
  8013ad:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013b2:	c1 e0 0c             	shl    $0xc,%eax
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013c3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c5:	89 c2                	mov    %eax,%edx
  8013c7:	c1 ea 16             	shr    $0x16,%edx
  8013ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013d1:	f6 c2 01             	test   $0x1,%dl
  8013d4:	74 11                	je     8013e7 <fd_alloc+0x30>
  8013d6:	89 c2                	mov    %eax,%edx
  8013d8:	c1 ea 0c             	shr    $0xc,%edx
  8013db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013e2:	f6 c2 01             	test   $0x1,%dl
  8013e5:	75 09                	jne    8013f0 <fd_alloc+0x39>
			*fd_store = fd;
  8013e7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ee:	eb 17                	jmp    801407 <fd_alloc+0x50>
  8013f0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013fa:	75 c7                	jne    8013c3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801402:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801407:	5b                   	pop    %ebx
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801410:	83 f8 1f             	cmp    $0x1f,%eax
  801413:	77 36                	ja     80144b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801415:	05 00 00 0d 00       	add    $0xd0000,%eax
  80141a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80141d:	89 c2                	mov    %eax,%edx
  80141f:	c1 ea 16             	shr    $0x16,%edx
  801422:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801429:	f6 c2 01             	test   $0x1,%dl
  80142c:	74 24                	je     801452 <fd_lookup+0x48>
  80142e:	89 c2                	mov    %eax,%edx
  801430:	c1 ea 0c             	shr    $0xc,%edx
  801433:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143a:	f6 c2 01             	test   $0x1,%dl
  80143d:	74 1a                	je     801459 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80143f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801442:	89 02                	mov    %eax,(%edx)
	return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
  801449:	eb 13                	jmp    80145e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80144b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801450:	eb 0c                	jmp    80145e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801452:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801457:	eb 05                	jmp    80145e <fd_lookup+0x54>
  801459:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 14             	sub    $0x14,%esp
  801467:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80146d:	ba 00 00 00 00       	mov    $0x0,%edx
  801472:	eb 0e                	jmp    801482 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801474:	39 08                	cmp    %ecx,(%eax)
  801476:	75 09                	jne    801481 <dev_lookup+0x21>
			*dev = devtab[i];
  801478:	89 03                	mov    %eax,(%ebx)
			return 0;
  80147a:	b8 00 00 00 00       	mov    $0x0,%eax
  80147f:	eb 33                	jmp    8014b4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	42                   	inc    %edx
  801482:	8b 04 95 f8 2b 80 00 	mov    0x802bf8(,%edx,4),%eax
  801489:	85 c0                	test   %eax,%eax
  80148b:	75 e7                	jne    801474 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80148d:	a1 20 44 80 00       	mov    0x804420,%eax
  801492:	8b 40 48             	mov    0x48(%eax),%eax
  801495:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149d:	c7 04 24 7c 2b 80 00 	movl   $0x802b7c,(%esp)
  8014a4:	e8 d3 ee ff ff       	call   80037c <cprintf>
	*dev = 0;
  8014a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014b4:	83 c4 14             	add    $0x14,%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	83 ec 30             	sub    $0x30,%esp
  8014c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c5:	8a 45 0c             	mov    0xc(%ebp),%al
  8014c8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014cb:	89 34 24             	mov    %esi,(%esp)
  8014ce:	e8 b9 fe ff ff       	call   80138c <fd2num>
  8014d3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014da:	89 04 24             	mov    %eax,(%esp)
  8014dd:	e8 28 ff ff ff       	call   80140a <fd_lookup>
  8014e2:	89 c3                	mov    %eax,%ebx
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 05                	js     8014ed <fd_close+0x33>
	    || fd != fd2)
  8014e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014eb:	74 0d                	je     8014fa <fd_close+0x40>
		return (must_exist ? r : 0);
  8014ed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014f1:	75 46                	jne    801539 <fd_close+0x7f>
  8014f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f8:	eb 3f                	jmp    801539 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801501:	8b 06                	mov    (%esi),%eax
  801503:	89 04 24             	mov    %eax,(%esp)
  801506:	e8 55 ff ff ff       	call   801460 <dev_lookup>
  80150b:	89 c3                	mov    %eax,%ebx
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 18                	js     801529 <fd_close+0x6f>
		if (dev->dev_close)
  801511:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801514:	8b 40 10             	mov    0x10(%eax),%eax
  801517:	85 c0                	test   %eax,%eax
  801519:	74 09                	je     801524 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80151b:	89 34 24             	mov    %esi,(%esp)
  80151e:	ff d0                	call   *%eax
  801520:	89 c3                	mov    %eax,%ebx
  801522:	eb 05                	jmp    801529 <fd_close+0x6f>
		else
			r = 0;
  801524:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801529:	89 74 24 04          	mov    %esi,0x4(%esp)
  80152d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801534:	e8 87 f8 ff ff       	call   800dc0 <sys_page_unmap>
	return r;
}
  801539:	89 d8                	mov    %ebx,%eax
  80153b:	83 c4 30             	add    $0x30,%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    

00801542 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80154f:	8b 45 08             	mov    0x8(%ebp),%eax
  801552:	89 04 24             	mov    %eax,(%esp)
  801555:	e8 b0 fe ff ff       	call   80140a <fd_lookup>
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 13                	js     801571 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80155e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801565:	00 
  801566:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801569:	89 04 24             	mov    %eax,(%esp)
  80156c:	e8 49 ff ff ff       	call   8014ba <fd_close>
}
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <close_all>:

void
close_all(void)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	53                   	push   %ebx
  801577:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80157a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80157f:	89 1c 24             	mov    %ebx,(%esp)
  801582:	e8 bb ff ff ff       	call   801542 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801587:	43                   	inc    %ebx
  801588:	83 fb 20             	cmp    $0x20,%ebx
  80158b:	75 f2                	jne    80157f <close_all+0xc>
		close(i);
}
  80158d:	83 c4 14             	add    $0x14,%esp
  801590:	5b                   	pop    %ebx
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	57                   	push   %edi
  801597:	56                   	push   %esi
  801598:	53                   	push   %ebx
  801599:	83 ec 4c             	sub    $0x4c,%esp
  80159c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80159f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a9:	89 04 24             	mov    %eax,(%esp)
  8015ac:	e8 59 fe ff ff       	call   80140a <fd_lookup>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	0f 88 e1 00 00 00    	js     80169c <dup+0x109>
		return r;
	close(newfdnum);
  8015bb:	89 3c 24             	mov    %edi,(%esp)
  8015be:	e8 7f ff ff ff       	call   801542 <close>

	newfd = INDEX2FD(newfdnum);
  8015c3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015c9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015cf:	89 04 24             	mov    %eax,(%esp)
  8015d2:	e8 c5 fd ff ff       	call   80139c <fd2data>
  8015d7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015d9:	89 34 24             	mov    %esi,(%esp)
  8015dc:	e8 bb fd ff ff       	call   80139c <fd2data>
  8015e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	c1 e8 16             	shr    $0x16,%eax
  8015e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015f0:	a8 01                	test   $0x1,%al
  8015f2:	74 46                	je     80163a <dup+0xa7>
  8015f4:	89 d8                	mov    %ebx,%eax
  8015f6:	c1 e8 0c             	shr    $0xc,%eax
  8015f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801600:	f6 c2 01             	test   $0x1,%dl
  801603:	74 35                	je     80163a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801605:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80160c:	25 07 0e 00 00       	and    $0xe07,%eax
  801611:	89 44 24 10          	mov    %eax,0x10(%esp)
  801615:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801618:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801623:	00 
  801624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801628:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162f:	e8 39 f7 ff ff       	call   800d6d <sys_page_map>
  801634:	89 c3                	mov    %eax,%ebx
  801636:	85 c0                	test   %eax,%eax
  801638:	78 3b                	js     801675 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80163a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	c1 ea 0c             	shr    $0xc,%edx
  801642:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801649:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80164f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801653:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801657:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80165e:	00 
  80165f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166a:	e8 fe f6 ff ff       	call   800d6d <sys_page_map>
  80166f:	89 c3                	mov    %eax,%ebx
  801671:	85 c0                	test   %eax,%eax
  801673:	79 25                	jns    80169a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801675:	89 74 24 04          	mov    %esi,0x4(%esp)
  801679:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801680:	e8 3b f7 ff ff       	call   800dc0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801685:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801693:	e8 28 f7 ff ff       	call   800dc0 <sys_page_unmap>
	return r;
  801698:	eb 02                	jmp    80169c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80169a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80169c:	89 d8                	mov    %ebx,%eax
  80169e:	83 c4 4c             	add    $0x4c,%esp
  8016a1:	5b                   	pop    %ebx
  8016a2:	5e                   	pop    %esi
  8016a3:	5f                   	pop    %edi
  8016a4:	5d                   	pop    %ebp
  8016a5:	c3                   	ret    

008016a6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	83 ec 24             	sub    $0x24,%esp
  8016ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	89 1c 24             	mov    %ebx,(%esp)
  8016ba:	e8 4b fd ff ff       	call   80140a <fd_lookup>
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 6d                	js     801730 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	8b 00                	mov    (%eax),%eax
  8016cf:	89 04 24             	mov    %eax,(%esp)
  8016d2:	e8 89 fd ff ff       	call   801460 <dev_lookup>
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 55                	js     801730 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016de:	8b 50 08             	mov    0x8(%eax),%edx
  8016e1:	83 e2 03             	and    $0x3,%edx
  8016e4:	83 fa 01             	cmp    $0x1,%edx
  8016e7:	75 23                	jne    80170c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e9:	a1 20 44 80 00       	mov    0x804420,%eax
  8016ee:	8b 40 48             	mov    0x48(%eax),%eax
  8016f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	c7 04 24 bd 2b 80 00 	movl   $0x802bbd,(%esp)
  801700:	e8 77 ec ff ff       	call   80037c <cprintf>
		return -E_INVAL;
  801705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170a:	eb 24                	jmp    801730 <read+0x8a>
	}
	if (!dev->dev_read)
  80170c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170f:	8b 52 08             	mov    0x8(%edx),%edx
  801712:	85 d2                	test   %edx,%edx
  801714:	74 15                	je     80172b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801716:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801719:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801720:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	ff d2                	call   *%edx
  801729:	eb 05                	jmp    801730 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80172b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801730:	83 c4 24             	add    $0x24,%esp
  801733:	5b                   	pop    %ebx
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	57                   	push   %edi
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 1c             	sub    $0x1c,%esp
  80173f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801742:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801745:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174a:	eb 23                	jmp    80176f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80174c:	89 f0                	mov    %esi,%eax
  80174e:	29 d8                	sub    %ebx,%eax
  801750:	89 44 24 08          	mov    %eax,0x8(%esp)
  801754:	8b 45 0c             	mov    0xc(%ebp),%eax
  801757:	01 d8                	add    %ebx,%eax
  801759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175d:	89 3c 24             	mov    %edi,(%esp)
  801760:	e8 41 ff ff ff       	call   8016a6 <read>
		if (m < 0)
  801765:	85 c0                	test   %eax,%eax
  801767:	78 10                	js     801779 <readn+0x43>
			return m;
		if (m == 0)
  801769:	85 c0                	test   %eax,%eax
  80176b:	74 0a                	je     801777 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80176d:	01 c3                	add    %eax,%ebx
  80176f:	39 f3                	cmp    %esi,%ebx
  801771:	72 d9                	jb     80174c <readn+0x16>
  801773:	89 d8                	mov    %ebx,%eax
  801775:	eb 02                	jmp    801779 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801777:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801779:	83 c4 1c             	add    $0x1c,%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5f                   	pop    %edi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 24             	sub    $0x24,%esp
  801788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801792:	89 1c 24             	mov    %ebx,(%esp)
  801795:	e8 70 fc ff ff       	call   80140a <fd_lookup>
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 68                	js     801806 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a8:	8b 00                	mov    (%eax),%eax
  8017aa:	89 04 24             	mov    %eax,(%esp)
  8017ad:	e8 ae fc ff ff       	call   801460 <dev_lookup>
  8017b2:	85 c0                	test   %eax,%eax
  8017b4:	78 50                	js     801806 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bd:	75 23                	jne    8017e2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017bf:	a1 20 44 80 00       	mov    0x804420,%eax
  8017c4:	8b 40 48             	mov    0x48(%eax),%eax
  8017c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cf:	c7 04 24 d9 2b 80 00 	movl   $0x802bd9,(%esp)
  8017d6:	e8 a1 eb ff ff       	call   80037c <cprintf>
		return -E_INVAL;
  8017db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e0:	eb 24                	jmp    801806 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017e8:	85 d2                	test   %edx,%edx
  8017ea:	74 15                	je     801801 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	ff d2                	call   *%edx
  8017ff:	eb 05                	jmp    801806 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801801:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801806:	83 c4 24             	add    $0x24,%esp
  801809:	5b                   	pop    %ebx
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <seek>:

int
seek(int fdnum, off_t offset)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801812:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801815:	89 44 24 04          	mov    %eax,0x4(%esp)
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	e8 e6 fb ff ff       	call   80140a <fd_lookup>
  801824:	85 c0                	test   %eax,%eax
  801826:	78 0e                	js     801836 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801828:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80182b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801831:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	53                   	push   %ebx
  80183c:	83 ec 24             	sub    $0x24,%esp
  80183f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801842:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801845:	89 44 24 04          	mov    %eax,0x4(%esp)
  801849:	89 1c 24             	mov    %ebx,(%esp)
  80184c:	e8 b9 fb ff ff       	call   80140a <fd_lookup>
  801851:	85 c0                	test   %eax,%eax
  801853:	78 61                	js     8018b6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801855:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185f:	8b 00                	mov    (%eax),%eax
  801861:	89 04 24             	mov    %eax,(%esp)
  801864:	e8 f7 fb ff ff       	call   801460 <dev_lookup>
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 49                	js     8018b6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801870:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801874:	75 23                	jne    801899 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801876:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80187b:	8b 40 48             	mov    0x48(%eax),%eax
  80187e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  80188d:	e8 ea ea ff ff       	call   80037c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801897:	eb 1d                	jmp    8018b6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801899:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189c:	8b 52 18             	mov    0x18(%edx),%edx
  80189f:	85 d2                	test   %edx,%edx
  8018a1:	74 0e                	je     8018b1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018aa:	89 04 24             	mov    %eax,(%esp)
  8018ad:	ff d2                	call   *%edx
  8018af:	eb 05                	jmp    8018b6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018b6:	83 c4 24             	add    $0x24,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 24             	sub    $0x24,%esp
  8018c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d0:	89 04 24             	mov    %eax,(%esp)
  8018d3:	e8 32 fb ff ff       	call   80140a <fd_lookup>
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 52                	js     80192e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	8b 00                	mov    (%eax),%eax
  8018e8:	89 04 24             	mov    %eax,(%esp)
  8018eb:	e8 70 fb ff ff       	call   801460 <dev_lookup>
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 3a                	js     80192e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018fb:	74 2c                	je     801929 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018fd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801900:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801907:	00 00 00 
	stat->st_isdir = 0;
  80190a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801911:	00 00 00 
	stat->st_dev = dev;
  801914:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80191a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80191e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801921:	89 14 24             	mov    %edx,(%esp)
  801924:	ff 50 14             	call   *0x14(%eax)
  801927:	eb 05                	jmp    80192e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801929:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80192e:	83 c4 24             	add    $0x24,%esp
  801931:	5b                   	pop    %ebx
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	56                   	push   %esi
  801938:	53                   	push   %ebx
  801939:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80193c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801943:	00 
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	89 04 24             	mov    %eax,(%esp)
  80194a:	e8 2d 02 00 00       	call   801b7c <open>
  80194f:	89 c3                	mov    %eax,%ebx
  801951:	85 c0                	test   %eax,%eax
  801953:	78 1b                	js     801970 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801955:	8b 45 0c             	mov    0xc(%ebp),%eax
  801958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195c:	89 1c 24             	mov    %ebx,(%esp)
  80195f:	e8 58 ff ff ff       	call   8018bc <fstat>
  801964:	89 c6                	mov    %eax,%esi
	close(fd);
  801966:	89 1c 24             	mov    %ebx,(%esp)
  801969:	e8 d4 fb ff ff       	call   801542 <close>
	return r;
  80196e:	89 f3                	mov    %esi,%ebx
}
  801970:	89 d8                	mov    %ebx,%eax
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	5b                   	pop    %ebx
  801976:	5e                   	pop    %esi
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    
  801979:	00 00                	add    %al,(%eax)
	...

0080197c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
  801981:	83 ec 10             	sub    $0x10,%esp
  801984:	89 c3                	mov    %eax,%ebx
  801986:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801988:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80198f:	75 11                	jne    8019a2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801991:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801998:	e8 72 09 00 00       	call   80230f <ipc_find_env>
  80199d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019a9:	00 
  8019aa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019b1:	00 
  8019b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	e8 de 08 00 00       	call   8022a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ca:	00 
  8019cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d6:	e8 5d 08 00 00       	call   802238 <ipc_recv>
}
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801a00:	b8 02 00 00 00       	mov    $0x2,%eax
  801a05:	e8 72 ff ff ff       	call   80197c <fsipc>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	8b 40 0c             	mov    0xc(%eax),%eax
  801a18:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	b8 06 00 00 00       	mov    $0x6,%eax
  801a27:	e8 50 ff ff ff       	call   80197c <fsipc>
}
  801a2c:	c9                   	leave  
  801a2d:	c3                   	ret    

00801a2e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	53                   	push   %ebx
  801a32:	83 ec 14             	sub    $0x14,%esp
  801a35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a43:	ba 00 00 00 00       	mov    $0x0,%edx
  801a48:	b8 05 00 00 00       	mov    $0x5,%eax
  801a4d:	e8 2a ff ff ff       	call   80197c <fsipc>
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 2b                	js     801a81 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a56:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a5d:	00 
  801a5e:	89 1c 24             	mov    %ebx,(%esp)
  801a61:	e8 c1 ee ff ff       	call   800927 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a66:	a1 80 50 80 00       	mov    0x805080,%eax
  801a6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a71:	a1 84 50 80 00       	mov    0x805084,%eax
  801a76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a81:	83 c4 14             	add    $0x14,%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	83 ec 18             	sub    $0x18,%esp
  801a8d:	8b 55 10             	mov    0x10(%ebp),%edx
  801a90:	89 d0                	mov    %edx,%eax
  801a92:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801a98:	76 05                	jbe    801a9f <devfile_write+0x18>
  801a9a:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa2:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801aab:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ac2:	e8 d9 ef ff ff       	call   800aa0 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  801acc:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad1:	e8 a6 fe ff ff       	call   80197c <fsipc>
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	56                   	push   %esi
  801adc:	53                   	push   %ebx
  801add:	83 ec 10             	sub    $0x10,%esp
  801ae0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801af4:	ba 00 00 00 00       	mov    $0x0,%edx
  801af9:	b8 03 00 00 00       	mov    $0x3,%eax
  801afe:	e8 79 fe ff ff       	call   80197c <fsipc>
  801b03:	89 c3                	mov    %eax,%ebx
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 6a                	js     801b73 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b09:	39 c6                	cmp    %eax,%esi
  801b0b:	73 24                	jae    801b31 <devfile_read+0x59>
  801b0d:	c7 44 24 0c 08 2c 80 	movl   $0x802c08,0xc(%esp)
  801b14:	00 
  801b15:	c7 44 24 08 0f 2c 80 	movl   $0x802c0f,0x8(%esp)
  801b1c:	00 
  801b1d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b24:	00 
  801b25:	c7 04 24 24 2c 80 00 	movl   $0x802c24,(%esp)
  801b2c:	e8 53 e7 ff ff       	call   800284 <_panic>
	assert(r <= PGSIZE);
  801b31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b36:	7e 24                	jle    801b5c <devfile_read+0x84>
  801b38:	c7 44 24 0c 2f 2c 80 	movl   $0x802c2f,0xc(%esp)
  801b3f:	00 
  801b40:	c7 44 24 08 0f 2c 80 	movl   $0x802c0f,0x8(%esp)
  801b47:	00 
  801b48:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b4f:	00 
  801b50:	c7 04 24 24 2c 80 00 	movl   $0x802c24,(%esp)
  801b57:	e8 28 e7 ff ff       	call   800284 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b60:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b67:	00 
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	89 04 24             	mov    %eax,(%esp)
  801b6e:	e8 2d ef ff ff       	call   800aa0 <memmove>
	return r;
}
  801b73:	89 d8                	mov    %ebx,%eax
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5e                   	pop    %esi
  801b7a:	5d                   	pop    %ebp
  801b7b:	c3                   	ret    

00801b7c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	56                   	push   %esi
  801b80:	53                   	push   %ebx
  801b81:	83 ec 20             	sub    $0x20,%esp
  801b84:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b87:	89 34 24             	mov    %esi,(%esp)
  801b8a:	e8 65 ed ff ff       	call   8008f4 <strlen>
  801b8f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b94:	7f 60                	jg     801bf6 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b99:	89 04 24             	mov    %eax,(%esp)
  801b9c:	e8 16 f8 ff ff       	call   8013b7 <fd_alloc>
  801ba1:	89 c3                	mov    %eax,%ebx
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	78 54                	js     801bfb <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ba7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bab:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bb2:	e8 70 ed ff ff       	call   800927 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bba:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bbf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc7:	e8 b0 fd ff ff       	call   80197c <fsipc>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	79 15                	jns    801be7 <open+0x6b>
		fd_close(fd, 0);
  801bd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bd9:	00 
  801bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 d5 f8 ff ff       	call   8014ba <fd_close>
		return r;
  801be5:	eb 14                	jmp    801bfb <open+0x7f>
	}

	return fd2num(fd);
  801be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 9a f7 ff ff       	call   80138c <fd2num>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	eb 05                	jmp    801bfb <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bf6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bfb:	89 d8                	mov    %ebx,%eax
  801bfd:	83 c4 20             	add    $0x20,%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0f:	b8 08 00 00 00       	mov    $0x8,%eax
  801c14:	e8 63 fd ff ff       	call   80197c <fsipc>
}
  801c19:	c9                   	leave  
  801c1a:	c3                   	ret    
	...

00801c1c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	56                   	push   %esi
  801c20:	53                   	push   %ebx
  801c21:	83 ec 10             	sub    $0x10,%esp
  801c24:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	89 04 24             	mov    %eax,(%esp)
  801c2d:	e8 6a f7 ff ff       	call   80139c <fd2data>
  801c32:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c34:	c7 44 24 04 3b 2c 80 	movl   $0x802c3b,0x4(%esp)
  801c3b:	00 
  801c3c:	89 34 24             	mov    %esi,(%esp)
  801c3f:	e8 e3 ec ff ff       	call   800927 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c44:	8b 43 04             	mov    0x4(%ebx),%eax
  801c47:	2b 03                	sub    (%ebx),%eax
  801c49:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c4f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c56:	00 00 00 
	stat->st_dev = &devpipe;
  801c59:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c60:	30 80 00 
	return 0;
}
  801c63:	b8 00 00 00 00       	mov    $0x0,%eax
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	53                   	push   %ebx
  801c73:	83 ec 14             	sub    $0x14,%esp
  801c76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c84:	e8 37 f1 ff ff       	call   800dc0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c89:	89 1c 24             	mov    %ebx,(%esp)
  801c8c:	e8 0b f7 ff ff       	call   80139c <fd2data>
  801c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c9c:	e8 1f f1 ff ff       	call   800dc0 <sys_page_unmap>
}
  801ca1:	83 c4 14             	add    $0x14,%esp
  801ca4:	5b                   	pop    %ebx
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	57                   	push   %edi
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	83 ec 2c             	sub    $0x2c,%esp
  801cb0:	89 c7                	mov    %eax,%edi
  801cb2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801cb5:	a1 20 44 80 00       	mov    0x804420,%eax
  801cba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cbd:	89 3c 24             	mov    %edi,(%esp)
  801cc0:	e8 8f 06 00 00       	call   802354 <pageref>
  801cc5:	89 c6                	mov    %eax,%esi
  801cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cca:	89 04 24             	mov    %eax,(%esp)
  801ccd:	e8 82 06 00 00       	call   802354 <pageref>
  801cd2:	39 c6                	cmp    %eax,%esi
  801cd4:	0f 94 c0             	sete   %al
  801cd7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801cda:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801ce0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ce3:	39 cb                	cmp    %ecx,%ebx
  801ce5:	75 08                	jne    801cef <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ce7:	83 c4 2c             	add    $0x2c,%esp
  801cea:	5b                   	pop    %ebx
  801ceb:	5e                   	pop    %esi
  801cec:	5f                   	pop    %edi
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801cef:	83 f8 01             	cmp    $0x1,%eax
  801cf2:	75 c1                	jne    801cb5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cf4:	8b 42 58             	mov    0x58(%edx),%eax
  801cf7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cfe:	00 
  801cff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d07:	c7 04 24 42 2c 80 00 	movl   $0x802c42,(%esp)
  801d0e:	e8 69 e6 ff ff       	call   80037c <cprintf>
  801d13:	eb a0                	jmp    801cb5 <_pipeisclosed+0xe>

00801d15 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	83 ec 1c             	sub    $0x1c,%esp
  801d1e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d21:	89 34 24             	mov    %esi,(%esp)
  801d24:	e8 73 f6 ff ff       	call   80139c <fd2data>
  801d29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d30:	eb 3c                	jmp    801d6e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d32:	89 da                	mov    %ebx,%edx
  801d34:	89 f0                	mov    %esi,%eax
  801d36:	e8 6c ff ff ff       	call   801ca7 <_pipeisclosed>
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	75 38                	jne    801d77 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d3f:	e8 b6 ef ff ff       	call   800cfa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d44:	8b 43 04             	mov    0x4(%ebx),%eax
  801d47:	8b 13                	mov    (%ebx),%edx
  801d49:	83 c2 20             	add    $0x20,%edx
  801d4c:	39 d0                	cmp    %edx,%eax
  801d4e:	73 e2                	jae    801d32 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d53:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d5e:	79 05                	jns    801d65 <devpipe_write+0x50>
  801d60:	4a                   	dec    %edx
  801d61:	83 ca e0             	or     $0xffffffe0,%edx
  801d64:	42                   	inc    %edx
  801d65:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d69:	40                   	inc    %eax
  801d6a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d6d:	47                   	inc    %edi
  801d6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d71:	75 d1                	jne    801d44 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d73:	89 f8                	mov    %edi,%eax
  801d75:	eb 05                	jmp    801d7c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    

00801d84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	57                   	push   %edi
  801d88:	56                   	push   %esi
  801d89:	53                   	push   %ebx
  801d8a:	83 ec 1c             	sub    $0x1c,%esp
  801d8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d90:	89 3c 24             	mov    %edi,(%esp)
  801d93:	e8 04 f6 ff ff       	call   80139c <fd2data>
  801d98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9a:	be 00 00 00 00       	mov    $0x0,%esi
  801d9f:	eb 3a                	jmp    801ddb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801da1:	85 f6                	test   %esi,%esi
  801da3:	74 04                	je     801da9 <devpipe_read+0x25>
				return i;
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	eb 40                	jmp    801de9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801da9:	89 da                	mov    %ebx,%edx
  801dab:	89 f8                	mov    %edi,%eax
  801dad:	e8 f5 fe ff ff       	call   801ca7 <_pipeisclosed>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	75 2e                	jne    801de4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801db6:	e8 3f ef ff ff       	call   800cfa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801dbb:	8b 03                	mov    (%ebx),%eax
  801dbd:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dc0:	74 df                	je     801da1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dc2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dc7:	79 05                	jns    801dce <devpipe_read+0x4a>
  801dc9:	48                   	dec    %eax
  801dca:	83 c8 e0             	or     $0xffffffe0,%eax
  801dcd:	40                   	inc    %eax
  801dce:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801dd8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dda:	46                   	inc    %esi
  801ddb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dde:	75 db                	jne    801dbb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801de0:	89 f0                	mov    %esi,%eax
  801de2:	eb 05                	jmp    801de9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801de9:	83 c4 1c             	add    $0x1c,%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	57                   	push   %edi
  801df5:	56                   	push   %esi
  801df6:	53                   	push   %ebx
  801df7:	83 ec 3c             	sub    $0x3c,%esp
  801dfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dfd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e00:	89 04 24             	mov    %eax,(%esp)
  801e03:	e8 af f5 ff ff       	call   8013b7 <fd_alloc>
  801e08:	89 c3                	mov    %eax,%ebx
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	0f 88 45 01 00 00    	js     801f57 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e19:	00 
  801e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e28:	e8 ec ee ff ff       	call   800d19 <sys_page_alloc>
  801e2d:	89 c3                	mov    %eax,%ebx
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	0f 88 20 01 00 00    	js     801f57 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e37:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e3a:	89 04 24             	mov    %eax,(%esp)
  801e3d:	e8 75 f5 ff ff       	call   8013b7 <fd_alloc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	85 c0                	test   %eax,%eax
  801e46:	0f 88 f8 00 00 00    	js     801f44 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e53:	00 
  801e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e62:	e8 b2 ee ff ff       	call   800d19 <sys_page_alloc>
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	0f 88 d3 00 00 00    	js     801f44 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e71:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e74:	89 04 24             	mov    %eax,(%esp)
  801e77:	e8 20 f5 ff ff       	call   80139c <fd2data>
  801e7c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e85:	00 
  801e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e91:	e8 83 ee ff ff       	call   800d19 <sys_page_alloc>
  801e96:	89 c3                	mov    %eax,%ebx
  801e98:	85 c0                	test   %eax,%eax
  801e9a:	0f 88 91 00 00 00    	js     801f31 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 f1 f4 ff ff       	call   80139c <fd2data>
  801eab:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801eb2:	00 
  801eb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ebe:	00 
  801ebf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eca:	e8 9e ee ff ff       	call   800d6d <sys_page_map>
  801ecf:	89 c3                	mov    %eax,%ebx
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 4c                	js     801f21 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ed5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ede:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ee0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ee3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ef0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f02:	89 04 24             	mov    %eax,(%esp)
  801f05:	e8 82 f4 ff ff       	call   80138c <fd2num>
  801f0a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f0f:	89 04 24             	mov    %eax,(%esp)
  801f12:	e8 75 f4 ff ff       	call   80138c <fd2num>
  801f17:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f1f:	eb 36                	jmp    801f57 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f21:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f2c:	e8 8f ee ff ff       	call   800dc0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f31:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3f:	e8 7c ee ff ff       	call   800dc0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f52:	e8 69 ee ff ff       	call   800dc0 <sys_page_unmap>
    err:
	return r;
}
  801f57:	89 d8                	mov    %ebx,%eax
  801f59:	83 c4 3c             	add    $0x3c,%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 91 f4 ff ff       	call   80140a <fd_lookup>
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	78 15                	js     801f92 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	89 04 24             	mov    %eax,(%esp)
  801f83:	e8 14 f4 ff ff       	call   80139c <fd2data>
	return _pipeisclosed(fd, p);
  801f88:	89 c2                	mov    %eax,%edx
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	e8 15 fd ff ff       	call   801ca7 <_pipeisclosed>
}
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	83 ec 10             	sub    $0x10,%esp
  801f9c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f9f:	85 f6                	test   %esi,%esi
  801fa1:	75 24                	jne    801fc7 <wait+0x33>
  801fa3:	c7 44 24 0c 5a 2c 80 	movl   $0x802c5a,0xc(%esp)
  801faa:	00 
  801fab:	c7 44 24 08 0f 2c 80 	movl   $0x802c0f,0x8(%esp)
  801fb2:	00 
  801fb3:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  801fba:	00 
  801fbb:	c7 04 24 65 2c 80 00 	movl   $0x802c65,(%esp)
  801fc2:	e8 bd e2 ff ff       	call   800284 <_panic>
	e = &envs[ENVX(envid)];
  801fc7:	89 f3                	mov    %esi,%ebx
  801fc9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801fcf:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  801fd6:	c1 e3 07             	shl    $0x7,%ebx
  801fd9:	29 c3                	sub    %eax,%ebx
  801fdb:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801fe1:	eb 05                	jmp    801fe8 <wait+0x54>
		sys_yield();
  801fe3:	e8 12 ed ff ff       	call   800cfa <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801fe8:	8b 43 48             	mov    0x48(%ebx),%eax
  801feb:	39 f0                	cmp    %esi,%eax
  801fed:	75 07                	jne    801ff6 <wait+0x62>
  801fef:	8b 43 54             	mov    0x54(%ebx),%eax
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	75 ed                	jne    801fe3 <wait+0x4f>
		sys_yield();
}
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5d                   	pop    %ebp
  801ffc:	c3                   	ret    
  801ffd:	00 00                	add    %al,(%eax)
	...

00802000 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802010:	c7 44 24 04 70 2c 80 	movl   $0x802c70,0x4(%esp)
  802017:	00 
  802018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201b:	89 04 24             	mov    %eax,(%esp)
  80201e:	e8 04 e9 ff ff       	call   800927 <strcpy>
	return 0;
}
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80202a:	55                   	push   %ebp
  80202b:	89 e5                	mov    %esp,%ebp
  80202d:	57                   	push   %edi
  80202e:	56                   	push   %esi
  80202f:	53                   	push   %ebx
  802030:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802036:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80203b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802041:	eb 30                	jmp    802073 <devcons_write+0x49>
		m = n - tot;
  802043:	8b 75 10             	mov    0x10(%ebp),%esi
  802046:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802048:	83 fe 7f             	cmp    $0x7f,%esi
  80204b:	76 05                	jbe    802052 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80204d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802052:	89 74 24 08          	mov    %esi,0x8(%esp)
  802056:	03 45 0c             	add    0xc(%ebp),%eax
  802059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80205d:	89 3c 24             	mov    %edi,(%esp)
  802060:	e8 3b ea ff ff       	call   800aa0 <memmove>
		sys_cputs(buf, m);
  802065:	89 74 24 04          	mov    %esi,0x4(%esp)
  802069:	89 3c 24             	mov    %edi,(%esp)
  80206c:	e8 db eb ff ff       	call   800c4c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802071:	01 f3                	add    %esi,%ebx
  802073:	89 d8                	mov    %ebx,%eax
  802075:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802078:	72 c9                	jb     802043 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80207a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5f                   	pop    %edi
  802083:	5d                   	pop    %ebp
  802084:	c3                   	ret    

00802085 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80208b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80208f:	75 07                	jne    802098 <devcons_read+0x13>
  802091:	eb 25                	jmp    8020b8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802093:	e8 62 ec ff ff       	call   800cfa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802098:	e8 cd eb ff ff       	call   800c6a <sys_cgetc>
  80209d:	85 c0                	test   %eax,%eax
  80209f:	74 f2                	je     802093 <devcons_read+0xe>
  8020a1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 1d                	js     8020c4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020a7:	83 f8 04             	cmp    $0x4,%eax
  8020aa:	74 13                	je     8020bf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020af:	88 10                	mov    %dl,(%eax)
	return 1;
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	eb 0c                	jmp    8020c4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020bd:	eb 05                	jmp    8020c4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020bf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020c4:	c9                   	leave  
  8020c5:	c3                   	ret    

008020c6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020d9:	00 
  8020da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 67 eb ff ff       	call   800c4c <sys_cputs>
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <getchar>:

int
getchar(void)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020f4:	00 
  8020f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802103:	e8 9e f5 ff ff       	call   8016a6 <read>
	if (r < 0)
  802108:	85 c0                	test   %eax,%eax
  80210a:	78 0f                	js     80211b <getchar+0x34>
		return r;
	if (r < 1)
  80210c:	85 c0                	test   %eax,%eax
  80210e:	7e 06                	jle    802116 <getchar+0x2f>
		return -E_EOF;
	return c;
  802110:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802114:	eb 05                	jmp    80211b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802116:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80211b:	c9                   	leave  
  80211c:	c3                   	ret    

0080211d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802123:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212a:	8b 45 08             	mov    0x8(%ebp),%eax
  80212d:	89 04 24             	mov    %eax,(%esp)
  802130:	e8 d5 f2 ff ff       	call   80140a <fd_lookup>
  802135:	85 c0                	test   %eax,%eax
  802137:	78 11                	js     80214a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802142:	39 10                	cmp    %edx,(%eax)
  802144:	0f 94 c0             	sete   %al
  802147:	0f b6 c0             	movzbl %al,%eax
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <opencons>:

int
opencons(void)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802155:	89 04 24             	mov    %eax,(%esp)
  802158:	e8 5a f2 ff ff       	call   8013b7 <fd_alloc>
  80215d:	85 c0                	test   %eax,%eax
  80215f:	78 3c                	js     80219d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802161:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802168:	00 
  802169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 9d eb ff ff       	call   800d19 <sys_page_alloc>
  80217c:	85 c0                	test   %eax,%eax
  80217e:	78 1d                	js     80219d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802180:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802189:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80218b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802195:	89 04 24             	mov    %eax,(%esp)
  802198:	e8 ef f1 ff ff       	call   80138c <fd2num>
}
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    
	...

008021a0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021a6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021ad:	75 58                	jne    802207 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8021af:	a1 20 44 80 00       	mov    0x804420,%eax
  8021b4:	8b 40 48             	mov    0x48(%eax),%eax
  8021b7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021be:	00 
  8021bf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8021c6:	ee 
  8021c7:	89 04 24             	mov    %eax,(%esp)
  8021ca:	e8 4a eb ff ff       	call   800d19 <sys_page_alloc>
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	74 1c                	je     8021ef <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8021d3:	c7 44 24 08 7c 2c 80 	movl   $0x802c7c,0x8(%esp)
  8021da:	00 
  8021db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8021e2:	00 
  8021e3:	c7 04 24 91 2c 80 00 	movl   $0x802c91,(%esp)
  8021ea:	e8 95 e0 ff ff       	call   800284 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8021ef:	a1 20 44 80 00       	mov    0x804420,%eax
  8021f4:	8b 40 48             	mov    0x48(%eax),%eax
  8021f7:	c7 44 24 04 14 22 80 	movl   $0x802214,0x4(%esp)
  8021fe:	00 
  8021ff:	89 04 24             	mov    %eax,(%esp)
  802202:	e8 b2 ec ff ff       	call   800eb9 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802207:	8b 45 08             	mov    0x8(%ebp),%eax
  80220a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80220f:	c9                   	leave  
  802210:	c3                   	ret    
  802211:	00 00                	add    %al,(%eax)
	...

00802214 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802214:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802215:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80221a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80221c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80221f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802223:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802225:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802229:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80222a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  80222d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80222f:	58                   	pop    %eax
	popl %eax
  802230:	58                   	pop    %eax

	// Pop all registers back
	popal
  802231:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802232:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802235:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802236:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802237:	c3                   	ret    

00802238 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802238:	55                   	push   %ebp
  802239:	89 e5                	mov    %esp,%ebp
  80223b:	56                   	push   %esi
  80223c:	53                   	push   %ebx
  80223d:	83 ec 10             	sub    $0x10,%esp
  802240:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802243:	8b 45 0c             	mov    0xc(%ebp),%eax
  802246:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802249:	85 c0                	test   %eax,%eax
  80224b:	75 05                	jne    802252 <ipc_recv+0x1a>
  80224d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802252:	89 04 24             	mov    %eax,(%esp)
  802255:	e8 d5 ec ff ff       	call   800f2f <sys_ipc_recv>
	if (from_env_store != NULL)
  80225a:	85 db                	test   %ebx,%ebx
  80225c:	74 0b                	je     802269 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80225e:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802264:	8b 52 74             	mov    0x74(%edx),%edx
  802267:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802269:	85 f6                	test   %esi,%esi
  80226b:	74 0b                	je     802278 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  80226d:	8b 15 20 44 80 00    	mov    0x804420,%edx
  802273:	8b 52 78             	mov    0x78(%edx),%edx
  802276:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802278:	85 c0                	test   %eax,%eax
  80227a:	79 16                	jns    802292 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80227c:	85 db                	test   %ebx,%ebx
  80227e:	74 06                	je     802286 <ipc_recv+0x4e>
			*from_env_store = 0;
  802280:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802286:	85 f6                	test   %esi,%esi
  802288:	74 10                	je     80229a <ipc_recv+0x62>
			*perm_store = 0;
  80228a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802290:	eb 08                	jmp    80229a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802292:	a1 20 44 80 00       	mov    0x804420,%eax
  802297:	8b 40 70             	mov    0x70(%eax),%eax
}
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5d                   	pop    %ebp
  8022a0:	c3                   	ret    

008022a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	57                   	push   %edi
  8022a5:	56                   	push   %esi
  8022a6:	53                   	push   %ebx
  8022a7:	83 ec 1c             	sub    $0x1c,%esp
  8022aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8022ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8022b3:	eb 2a                	jmp    8022df <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8022b5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022b8:	74 20                	je     8022da <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8022ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022be:	c7 44 24 08 a0 2c 80 	movl   $0x802ca0,0x8(%esp)
  8022c5:	00 
  8022c6:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8022cd:	00 
  8022ce:	c7 04 24 c8 2c 80 00 	movl   $0x802cc8,(%esp)
  8022d5:	e8 aa df ff ff       	call   800284 <_panic>
		sys_yield();
  8022da:	e8 1b ea ff ff       	call   800cfa <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8022df:	85 db                	test   %ebx,%ebx
  8022e1:	75 07                	jne    8022ea <ipc_send+0x49>
  8022e3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022e8:	eb 02                	jmp    8022ec <ipc_send+0x4b>
  8022ea:	89 d8                	mov    %ebx,%eax
  8022ec:	8b 55 14             	mov    0x14(%ebp),%edx
  8022ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022f7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022fb:	89 34 24             	mov    %esi,(%esp)
  8022fe:	e8 09 ec ff ff       	call   800f0c <sys_ipc_try_send>
  802303:	85 c0                	test   %eax,%eax
  802305:	78 ae                	js     8022b5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802307:	83 c4 1c             	add    $0x1c,%esp
  80230a:	5b                   	pop    %ebx
  80230b:	5e                   	pop    %esi
  80230c:	5f                   	pop    %edi
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	53                   	push   %ebx
  802313:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802316:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80231b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802322:	89 c2                	mov    %eax,%edx
  802324:	c1 e2 07             	shl    $0x7,%edx
  802327:	29 ca                	sub    %ecx,%edx
  802329:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80232f:	8b 52 50             	mov    0x50(%edx),%edx
  802332:	39 da                	cmp    %ebx,%edx
  802334:	75 0f                	jne    802345 <ipc_find_env+0x36>
			return envs[i].env_id;
  802336:	c1 e0 07             	shl    $0x7,%eax
  802339:	29 c8                	sub    %ecx,%eax
  80233b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802340:	8b 40 40             	mov    0x40(%eax),%eax
  802343:	eb 0c                	jmp    802351 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802345:	40                   	inc    %eax
  802346:	3d 00 04 00 00       	cmp    $0x400,%eax
  80234b:	75 ce                	jne    80231b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80234d:	66 b8 00 00          	mov    $0x0,%ax
}
  802351:	5b                   	pop    %ebx
  802352:	5d                   	pop    %ebp
  802353:	c3                   	ret    

00802354 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80235a:	89 c2                	mov    %eax,%edx
  80235c:	c1 ea 16             	shr    $0x16,%edx
  80235f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802366:	f6 c2 01             	test   $0x1,%dl
  802369:	74 1e                	je     802389 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80236b:	c1 e8 0c             	shr    $0xc,%eax
  80236e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802375:	a8 01                	test   $0x1,%al
  802377:	74 17                	je     802390 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802379:	c1 e8 0c             	shr    $0xc,%eax
  80237c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802383:	ef 
  802384:	0f b7 c0             	movzwl %ax,%eax
  802387:	eb 0c                	jmp    802395 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802389:	b8 00 00 00 00       	mov    $0x0,%eax
  80238e:	eb 05                	jmp    802395 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802390:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    
	...

00802398 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802398:	55                   	push   %ebp
  802399:	57                   	push   %edi
  80239a:	56                   	push   %esi
  80239b:	83 ec 10             	sub    $0x10,%esp
  80239e:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023a2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023aa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023ae:	89 cd                	mov    %ecx,%ebp
  8023b0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	75 2c                	jne    8023e4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023b8:	39 f9                	cmp    %edi,%ecx
  8023ba:	77 68                	ja     802424 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023bc:	85 c9                	test   %ecx,%ecx
  8023be:	75 0b                	jne    8023cb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c5:	31 d2                	xor    %edx,%edx
  8023c7:	f7 f1                	div    %ecx
  8023c9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	89 f8                	mov    %edi,%eax
  8023cf:	f7 f1                	div    %ecx
  8023d1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023d3:	89 f0                	mov    %esi,%eax
  8023d5:	f7 f1                	div    %ecx
  8023d7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023d9:	89 f0                	mov    %esi,%eax
  8023db:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	5e                   	pop    %esi
  8023e1:	5f                   	pop    %edi
  8023e2:	5d                   	pop    %ebp
  8023e3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023e4:	39 f8                	cmp    %edi,%eax
  8023e6:	77 2c                	ja     802414 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023e8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8023eb:	83 f6 1f             	xor    $0x1f,%esi
  8023ee:	75 4c                	jne    80243c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023f0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023f2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023f7:	72 0a                	jb     802403 <__udivdi3+0x6b>
  8023f9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023fd:	0f 87 ad 00 00 00    	ja     8024b0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802403:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802408:	89 f0                	mov    %esi,%eax
  80240a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80240c:	83 c4 10             	add    $0x10,%esp
  80240f:	5e                   	pop    %esi
  802410:	5f                   	pop    %edi
  802411:	5d                   	pop    %ebp
  802412:	c3                   	ret    
  802413:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802414:	31 ff                	xor    %edi,%edi
  802416:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802418:	89 f0                	mov    %esi,%eax
  80241a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80241c:	83 c4 10             	add    $0x10,%esp
  80241f:	5e                   	pop    %esi
  802420:	5f                   	pop    %edi
  802421:	5d                   	pop    %ebp
  802422:	c3                   	ret    
  802423:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802424:	89 fa                	mov    %edi,%edx
  802426:	89 f0                	mov    %esi,%eax
  802428:	f7 f1                	div    %ecx
  80242a:	89 c6                	mov    %eax,%esi
  80242c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80242e:	89 f0                	mov    %esi,%eax
  802430:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80243c:	89 f1                	mov    %esi,%ecx
  80243e:	d3 e0                	shl    %cl,%eax
  802440:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802444:	b8 20 00 00 00       	mov    $0x20,%eax
  802449:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80244b:	89 ea                	mov    %ebp,%edx
  80244d:	88 c1                	mov    %al,%cl
  80244f:	d3 ea                	shr    %cl,%edx
  802451:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802455:	09 ca                	or     %ecx,%edx
  802457:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80245b:	89 f1                	mov    %esi,%ecx
  80245d:	d3 e5                	shl    %cl,%ebp
  80245f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802463:	89 fd                	mov    %edi,%ebp
  802465:	88 c1                	mov    %al,%cl
  802467:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802469:	89 fa                	mov    %edi,%edx
  80246b:	89 f1                	mov    %esi,%ecx
  80246d:	d3 e2                	shl    %cl,%edx
  80246f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802473:	88 c1                	mov    %al,%cl
  802475:	d3 ef                	shr    %cl,%edi
  802477:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802479:	89 f8                	mov    %edi,%eax
  80247b:	89 ea                	mov    %ebp,%edx
  80247d:	f7 74 24 08          	divl   0x8(%esp)
  802481:	89 d1                	mov    %edx,%ecx
  802483:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802485:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802489:	39 d1                	cmp    %edx,%ecx
  80248b:	72 17                	jb     8024a4 <__udivdi3+0x10c>
  80248d:	74 09                	je     802498 <__udivdi3+0x100>
  80248f:	89 fe                	mov    %edi,%esi
  802491:	31 ff                	xor    %edi,%edi
  802493:	e9 41 ff ff ff       	jmp    8023d9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802498:	8b 54 24 04          	mov    0x4(%esp),%edx
  80249c:	89 f1                	mov    %esi,%ecx
  80249e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024a0:	39 c2                	cmp    %eax,%edx
  8024a2:	73 eb                	jae    80248f <__udivdi3+0xf7>
		{
		  q0--;
  8024a4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024a7:	31 ff                	xor    %edi,%edi
  8024a9:	e9 2b ff ff ff       	jmp    8023d9 <__udivdi3+0x41>
  8024ae:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024b0:	31 f6                	xor    %esi,%esi
  8024b2:	e9 22 ff ff ff       	jmp    8023d9 <__udivdi3+0x41>
	...

008024b8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024b8:	55                   	push   %ebp
  8024b9:	57                   	push   %edi
  8024ba:	56                   	push   %esi
  8024bb:	83 ec 20             	sub    $0x20,%esp
  8024be:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024c2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024c6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024ca:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8024ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024d2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024d6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8024d8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024da:	85 ed                	test   %ebp,%ebp
  8024dc:	75 16                	jne    8024f4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8024de:	39 f1                	cmp    %esi,%ecx
  8024e0:	0f 86 a6 00 00 00    	jbe    80258c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024e6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8024e8:	89 d0                	mov    %edx,%eax
  8024ea:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024ec:	83 c4 20             	add    $0x20,%esp
  8024ef:	5e                   	pop    %esi
  8024f0:	5f                   	pop    %edi
  8024f1:	5d                   	pop    %ebp
  8024f2:	c3                   	ret    
  8024f3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024f4:	39 f5                	cmp    %esi,%ebp
  8024f6:	0f 87 ac 00 00 00    	ja     8025a8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024fc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8024ff:	83 f0 1f             	xor    $0x1f,%eax
  802502:	89 44 24 10          	mov    %eax,0x10(%esp)
  802506:	0f 84 a8 00 00 00    	je     8025b4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80250c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802510:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802512:	bf 20 00 00 00       	mov    $0x20,%edi
  802517:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80251b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80251f:	89 f9                	mov    %edi,%ecx
  802521:	d3 e8                	shr    %cl,%eax
  802523:	09 e8                	or     %ebp,%eax
  802525:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802529:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80252d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802531:	d3 e0                	shl    %cl,%eax
  802533:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802537:	89 f2                	mov    %esi,%edx
  802539:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80253b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80253f:	d3 e0                	shl    %cl,%eax
  802541:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802545:	8b 44 24 14          	mov    0x14(%esp),%eax
  802549:	89 f9                	mov    %edi,%ecx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80254f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802551:	89 f2                	mov    %esi,%edx
  802553:	f7 74 24 18          	divl   0x18(%esp)
  802557:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	89 c5                	mov    %eax,%ebp
  80255f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802561:	39 d6                	cmp    %edx,%esi
  802563:	72 67                	jb     8025cc <__umoddi3+0x114>
  802565:	74 75                	je     8025dc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802567:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80256b:	29 e8                	sub    %ebp,%eax
  80256d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80256f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802573:	d3 e8                	shr    %cl,%eax
  802575:	89 f2                	mov    %esi,%edx
  802577:	89 f9                	mov    %edi,%ecx
  802579:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80257b:	09 d0                	or     %edx,%eax
  80257d:	89 f2                	mov    %esi,%edx
  80257f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802583:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802585:	83 c4 20             	add    $0x20,%esp
  802588:	5e                   	pop    %esi
  802589:	5f                   	pop    %edi
  80258a:	5d                   	pop    %ebp
  80258b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80258c:	85 c9                	test   %ecx,%ecx
  80258e:	75 0b                	jne    80259b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802590:	b8 01 00 00 00       	mov    $0x1,%eax
  802595:	31 d2                	xor    %edx,%edx
  802597:	f7 f1                	div    %ecx
  802599:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80259b:	89 f0                	mov    %esi,%eax
  80259d:	31 d2                	xor    %edx,%edx
  80259f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025a1:	89 f8                	mov    %edi,%eax
  8025a3:	e9 3e ff ff ff       	jmp    8024e6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025a8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025aa:	83 c4 20             	add    $0x20,%esp
  8025ad:	5e                   	pop    %esi
  8025ae:	5f                   	pop    %edi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    
  8025b1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025b4:	39 f5                	cmp    %esi,%ebp
  8025b6:	72 04                	jb     8025bc <__umoddi3+0x104>
  8025b8:	39 f9                	cmp    %edi,%ecx
  8025ba:	77 06                	ja     8025c2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025bc:	89 f2                	mov    %esi,%edx
  8025be:	29 cf                	sub    %ecx,%edi
  8025c0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025c2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c4:	83 c4 20             	add    $0x20,%esp
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
  8025cb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025cc:	89 d1                	mov    %edx,%ecx
  8025ce:	89 c5                	mov    %eax,%ebp
  8025d0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025d4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025d8:	eb 8d                	jmp    802567 <__umoddi3+0xaf>
  8025da:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025dc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025e0:	72 ea                	jb     8025cc <__umoddi3+0x114>
  8025e2:	89 f1                	mov    %esi,%ecx
  8025e4:	eb 81                	jmp    802567 <__umoddi3+0xaf>
