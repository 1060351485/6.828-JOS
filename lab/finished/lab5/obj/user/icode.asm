
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 30 80 00 a0 	movl   $0x8026a0,0x803000
  800046:	26 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 a6 26 80 00 	movl   $0x8026a6,(%esp)
  800050:	e8 67 02 00 00       	call   8002bc <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 b5 26 80 00 	movl   $0x8026b5,(%esp)
  80005c:	e8 5b 02 00 00       	call   8002bc <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 c8 26 80 00 	movl   $0x8026c8,(%esp)
  800070:	e8 3f 16 00 00       	call   8016b4 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 ce 26 80 	movl   $0x8026ce,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  800096:	e8 29 01 00 00       	call   8001c4 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 f1 26 80 00 	movl   $0x8026f1,(%esp)
  8000a2:	e8 15 02 00 00       	call   8002bc <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 d1 0a 00 00       	call   800b8c <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 0f 11 00 00       	call   8011de <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 04 27 80 00 	movl   $0x802704,(%esp)
  8000da:	e8 dd 01 00 00       	call   8002bc <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 93 0f 00 00       	call   80107a <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 18 27 80 00 	movl   $0x802718,(%esp)
  8000ee:	e8 c9 01 00 00       	call   8002bc <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 2c 27 80 	movl   $0x80272c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 35 27 80 	movl   $0x802735,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 3f 27 80 	movl   $0x80273f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 3e 27 80 00 	movl   $0x80273e,(%esp)
  80011a:	e8 3d 1c 00 00       	call   801d5c <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 44 27 80 	movl   $0x802744,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  80013e:	e8 81 00 00 00       	call   8001c4 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 5b 27 80 00 	movl   $0x80275b,(%esp)
  80014a:	e8 6d 01 00 00       	call   8002bc <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 10             	sub    $0x10,%esp
  800164:	8b 75 08             	mov    0x8(%ebp),%esi
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80016a:	e8 ac 0a 00 00       	call   800c1b <sys_getenvid>
  80016f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800174:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80017b:	c1 e0 07             	shl    $0x7,%eax
  80017e:	29 d0                	sub    %edx,%eax
  800180:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800185:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80018a:	85 f6                	test   %esi,%esi
  80018c:	7e 07                	jle    800195 <libmain+0x39>
		binaryname = argv[0];
  80018e:	8b 03                	mov    (%ebx),%eax
  800190:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800195:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800199:	89 34 24             	mov    %esi,(%esp)
  80019c:	e8 93 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001a1:	e8 0a 00 00 00       	call   8001b0 <exit>
}
  8001a6:	83 c4 10             	add    $0x10,%esp
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
  8001ad:	00 00                	add    %al,(%eax)
	...

008001b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001bd:	e8 07 0a 00 00       	call   800bc9 <sys_env_destroy>
}
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	56                   	push   %esi
  8001c8:	53                   	push   %ebx
  8001c9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001cc:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001d5:	e8 41 0a 00 00       	call   800c1b <sys_getenvid>
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f0:	c7 04 24 78 27 80 00 	movl   $0x802778,(%esp)
  8001f7:	e8 c0 00 00 00       	call   8002bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800200:	8b 45 10             	mov    0x10(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	e8 50 00 00 00       	call   80025b <vcprintf>
	cprintf("\n");
  80020b:	c7 04 24 83 2c 80 00 	movl   $0x802c83,(%esp)
  800212:	e8 a5 00 00 00       	call   8002bc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800217:	cc                   	int3   
  800218:	eb fd                	jmp    800217 <_panic+0x53>
	...

0080021c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	83 ec 14             	sub    $0x14,%esp
  800223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800226:	8b 03                	mov    (%ebx),%eax
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022f:	40                   	inc    %eax
  800230:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800232:	3d ff 00 00 00       	cmp    $0xff,%eax
  800237:	75 19                	jne    800252 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800239:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800240:	00 
  800241:	8d 43 08             	lea    0x8(%ebx),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	e8 40 09 00 00       	call   800b8c <sys_cputs>
		b->idx = 0;
  80024c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800252:	ff 43 04             	incl   0x4(%ebx)
}
  800255:	83 c4 14             	add    $0x14,%esp
  800258:	5b                   	pop    %ebx
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800264:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80026b:	00 00 00 
	b.cnt = 0;
  80026e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800275:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027f:	8b 45 08             	mov    0x8(%ebp),%eax
  800282:	89 44 24 08          	mov    %eax,0x8(%esp)
  800286:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80028c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800290:	c7 04 24 1c 02 80 00 	movl   $0x80021c,(%esp)
  800297:	e8 82 01 00 00       	call   80041e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80029c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 d8 08 00 00       	call   800b8c <sys_cputs>

	return b.cnt;
}
  8002b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	e8 87 ff ff ff       	call   80025b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d4:	c9                   	leave  
  8002d5:	c3                   	ret    
	...

008002d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
  8002de:	83 ec 3c             	sub    $0x3c,%esp
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	89 d7                	mov    %edx,%edi
  8002e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	75 08                	jne    800304 <printnum+0x2c>
  8002fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  800302:	77 57                	ja     80035b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800304:	89 74 24 10          	mov    %esi,0x10(%esp)
  800308:	4b                   	dec    %ebx
  800309:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80030d:	8b 45 10             	mov    0x10(%ebp),%eax
  800310:	89 44 24 08          	mov    %eax,0x8(%esp)
  800314:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800318:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80031c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800323:	00 
  800324:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800331:	e8 0e 21 00 00       	call   802444 <__udivdi3>
  800336:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80033a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	89 54 24 04          	mov    %edx,0x4(%esp)
  800345:	89 fa                	mov    %edi,%edx
  800347:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034a:	e8 89 ff ff ff       	call   8002d8 <printnum>
  80034f:	eb 0f                	jmp    800360 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800351:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800355:	89 34 24             	mov    %esi,(%esp)
  800358:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035b:	4b                   	dec    %ebx
  80035c:	85 db                	test   %ebx,%ebx
  80035e:	7f f1                	jg     800351 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800360:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800364:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800368:	8b 45 10             	mov    0x10(%ebp),%eax
  80036b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800376:	00 
  800377:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800380:	89 44 24 04          	mov    %eax,0x4(%esp)
  800384:	e8 db 21 00 00       	call   802564 <__umoddi3>
  800389:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80038d:	0f be 80 9b 27 80 00 	movsbl 0x80279b(%eax),%eax
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039a:	83 c4 3c             	add    $0x3c,%esp
  80039d:	5b                   	pop    %ebx
  80039e:	5e                   	pop    %esi
  80039f:	5f                   	pop    %edi
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a5:	83 fa 01             	cmp    $0x1,%edx
  8003a8:	7e 0e                	jle    8003b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003af:	89 08                	mov    %ecx,(%eax)
  8003b1:	8b 02                	mov    (%edx),%eax
  8003b3:	8b 52 04             	mov    0x4(%edx),%edx
  8003b6:	eb 22                	jmp    8003da <getuint+0x38>
	else if (lflag)
  8003b8:	85 d2                	test   %edx,%edx
  8003ba:	74 10                	je     8003cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ca:	eb 0e                	jmp    8003da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d1:	89 08                	mov    %ecx,(%eax)
  8003d3:	8b 02                	mov    (%edx),%eax
  8003d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003e5:	8b 10                	mov    (%eax),%edx
  8003e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ea:	73 08                	jae    8003f4 <sprintputch+0x18>
		*b->buf++ = ch;
  8003ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ef:	88 0a                	mov    %cl,(%edx)
  8003f1:	42                   	inc    %edx
  8003f2:	89 10                	mov    %edx,(%eax)
}
  8003f4:	5d                   	pop    %ebp
  8003f5:	c3                   	ret    

008003f6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f6:	55                   	push   %ebp
  8003f7:	89 e5                	mov    %esp,%ebp
  8003f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800403:	8b 45 10             	mov    0x10(%ebp),%eax
  800406:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80040d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	e8 02 00 00 00       	call   80041e <vprintfmt>
	va_end(ap);
}
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	57                   	push   %edi
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	83 ec 4c             	sub    $0x4c,%esp
  800427:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80042a:	8b 75 10             	mov    0x10(%ebp),%esi
  80042d:	eb 12                	jmp    800441 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042f:	85 c0                	test   %eax,%eax
  800431:	0f 84 6b 03 00 00    	je     8007a2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800437:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043b:	89 04 24             	mov    %eax,(%esp)
  80043e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800441:	0f b6 06             	movzbl (%esi),%eax
  800444:	46                   	inc    %esi
  800445:	83 f8 25             	cmp    $0x25,%eax
  800448:	75 e5                	jne    80042f <vprintfmt+0x11>
  80044a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80044e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800455:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80045a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800461:	b9 00 00 00 00       	mov    $0x0,%ecx
  800466:	eb 26                	jmp    80048e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80046b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80046f:	eb 1d                	jmp    80048e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800474:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800478:	eb 14                	jmp    80048e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80047d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800484:	eb 08                	jmp    80048e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800486:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800489:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	0f b6 06             	movzbl (%esi),%eax
  800491:	8d 56 01             	lea    0x1(%esi),%edx
  800494:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800497:	8a 16                	mov    (%esi),%dl
  800499:	83 ea 23             	sub    $0x23,%edx
  80049c:	80 fa 55             	cmp    $0x55,%dl
  80049f:	0f 87 e1 02 00 00    	ja     800786 <vprintfmt+0x368>
  8004a5:	0f b6 d2             	movzbl %dl,%edx
  8004a8:	ff 24 95 e0 28 80 00 	jmp    *0x8028e0(,%edx,4)
  8004af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004b2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ba:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004be:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c4:	83 fa 09             	cmp    $0x9,%edx
  8004c7:	77 2a                	ja     8004f3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004ca:	eb eb                	jmp    8004b7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 50 04             	lea    0x4(%eax),%edx
  8004d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004da:	eb 17                	jmp    8004f3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	78 98                	js     80047a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e5:	eb a7                	jmp    80048e <vprintfmt+0x70>
  8004e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ea:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004f1:	eb 9b                	jmp    80048e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f7:	79 95                	jns    80048e <vprintfmt+0x70>
  8004f9:	eb 8b                	jmp    800486 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004fb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004ff:	eb 8d                	jmp    80048e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 04             	lea    0x4(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800519:	e9 23 ff ff ff       	jmp    800441 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	85 c0                	test   %eax,%eax
  80052b:	79 02                	jns    80052f <vprintfmt+0x111>
  80052d:	f7 d8                	neg    %eax
  80052f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800531:	83 f8 0f             	cmp    $0xf,%eax
  800534:	7f 0b                	jg     800541 <vprintfmt+0x123>
  800536:	8b 04 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%eax
  80053d:	85 c0                	test   %eax,%eax
  80053f:	75 23                	jne    800564 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800541:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800545:	c7 44 24 08 b3 27 80 	movl   $0x8027b3,0x8(%esp)
  80054c:	00 
  80054d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800551:	8b 45 08             	mov    0x8(%ebp),%eax
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	e8 9a fe ff ff       	call   8003f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80055f:	e9 dd fe ff ff       	jmp    800441 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800564:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800568:	c7 44 24 08 71 2b 80 	movl   $0x802b71,0x8(%esp)
  80056f:	00 
  800570:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800574:	8b 55 08             	mov    0x8(%ebp),%edx
  800577:	89 14 24             	mov    %edx,(%esp)
  80057a:	e8 77 fe ff ff       	call   8003f6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800582:	e9 ba fe ff ff       	jmp    800441 <vprintfmt+0x23>
  800587:	89 f9                	mov    %edi,%ecx
  800589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 50 04             	lea    0x4(%eax),%edx
  800595:	89 55 14             	mov    %edx,0x14(%ebp)
  800598:	8b 30                	mov    (%eax),%esi
  80059a:	85 f6                	test   %esi,%esi
  80059c:	75 05                	jne    8005a3 <vprintfmt+0x185>
				p = "(null)";
  80059e:	be ac 27 80 00       	mov    $0x8027ac,%esi
			if (width > 0 && padc != '-')
  8005a3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005a7:	0f 8e 84 00 00 00    	jle    800631 <vprintfmt+0x213>
  8005ad:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005b1:	74 7e                	je     800631 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b7:	89 34 24             	mov    %esi,(%esp)
  8005ba:	e8 8b 02 00 00       	call   80084a <strnlen>
  8005bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c2:	29 c2                	sub    %eax,%edx
  8005c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005c7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005cb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ce:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005d1:	89 de                	mov    %ebx,%esi
  8005d3:	89 d3                	mov    %edx,%ebx
  8005d5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	eb 0b                	jmp    8005e4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005dd:	89 3c 24             	mov    %edi,(%esp)
  8005e0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e3:	4b                   	dec    %ebx
  8005e4:	85 db                	test   %ebx,%ebx
  8005e6:	7f f1                	jg     8005d9 <vprintfmt+0x1bb>
  8005e8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005eb:	89 f3                	mov    %esi,%ebx
  8005ed:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	79 05                	jns    8005fc <vprintfmt+0x1de>
  8005f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ff:	29 c2                	sub    %eax,%edx
  800601:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800604:	eb 2b                	jmp    800631 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800606:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060a:	74 18                	je     800624 <vprintfmt+0x206>
  80060c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060f:	83 fa 5e             	cmp    $0x5e,%edx
  800612:	76 10                	jbe    800624 <vprintfmt+0x206>
					putch('?', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
  800622:	eb 0a                	jmp    80062e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800624:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062e:	ff 4d e4             	decl   -0x1c(%ebp)
  800631:	0f be 06             	movsbl (%esi),%eax
  800634:	46                   	inc    %esi
  800635:	85 c0                	test   %eax,%eax
  800637:	74 21                	je     80065a <vprintfmt+0x23c>
  800639:	85 ff                	test   %edi,%edi
  80063b:	78 c9                	js     800606 <vprintfmt+0x1e8>
  80063d:	4f                   	dec    %edi
  80063e:	79 c6                	jns    800606 <vprintfmt+0x1e8>
  800640:	8b 7d 08             	mov    0x8(%ebp),%edi
  800643:	89 de                	mov    %ebx,%esi
  800645:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800648:	eb 18                	jmp    800662 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800655:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800657:	4b                   	dec    %ebx
  800658:	eb 08                	jmp    800662 <vprintfmt+0x244>
  80065a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80065d:	89 de                	mov    %ebx,%esi
  80065f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800662:	85 db                	test   %ebx,%ebx
  800664:	7f e4                	jg     80064a <vprintfmt+0x22c>
  800666:	89 7d 08             	mov    %edi,0x8(%ebp)
  800669:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066e:	e9 ce fd ff ff       	jmp    800441 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7e 10                	jle    800688 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 08             	lea    0x8(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 30                	mov    (%eax),%esi
  800683:	8b 78 04             	mov    0x4(%eax),%edi
  800686:	eb 26                	jmp    8006ae <vprintfmt+0x290>
	else if (lflag)
  800688:	85 c9                	test   %ecx,%ecx
  80068a:	74 12                	je     80069e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 30                	mov    (%eax),%esi
  800697:	89 f7                	mov    %esi,%edi
  800699:	c1 ff 1f             	sar    $0x1f,%edi
  80069c:	eb 10                	jmp    8006ae <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a7:	8b 30                	mov    (%eax),%esi
  8006a9:	89 f7                	mov    %esi,%edi
  8006ab:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ae:	85 ff                	test   %edi,%edi
  8006b0:	78 0a                	js     8006bc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b7:	e9 8c 00 00 00       	jmp    800748 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ca:	f7 de                	neg    %esi
  8006cc:	83 d7 00             	adc    $0x0,%edi
  8006cf:	f7 df                	neg    %edi
			}
			base = 10;
  8006d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d6:	eb 70                	jmp    800748 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d8:	89 ca                	mov    %ecx,%edx
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dd:	e8 c0 fc ff ff       	call   8003a2 <getuint>
  8006e2:	89 c6                	mov    %eax,%esi
  8006e4:	89 d7                	mov    %edx,%edi
			base = 10;
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006eb:	eb 5b                	jmp    800748 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8006ed:	89 ca                	mov    %ecx,%edx
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	e8 ab fc ff ff       	call   8003a2 <getuint>
  8006f7:	89 c6                	mov    %eax,%esi
  8006f9:	89 d7                	mov    %edx,%edi
			base = 8;
  8006fb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800700:	eb 46                	jmp    800748 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800702:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800706:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800710:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800714:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 50 04             	lea    0x4(%eax),%edx
  800724:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800727:	8b 30                	mov    (%eax),%esi
  800729:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800733:	eb 13                	jmp    800748 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800735:	89 ca                	mov    %ecx,%edx
  800737:	8d 45 14             	lea    0x14(%ebp),%eax
  80073a:	e8 63 fc ff ff       	call   8003a2 <getuint>
  80073f:	89 c6                	mov    %eax,%esi
  800741:	89 d7                	mov    %edx,%edi
			base = 16;
  800743:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800748:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80074c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800750:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800753:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800757:	89 44 24 08          	mov    %eax,0x8(%esp)
  80075b:	89 34 24             	mov    %esi,(%esp)
  80075e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800762:	89 da                	mov    %ebx,%edx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	e8 6c fb ff ff       	call   8002d8 <printnum>
			break;
  80076c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076f:	e9 cd fc ff ff       	jmp    800441 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	89 04 24             	mov    %eax,(%esp)
  80077b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800781:	e9 bb fc ff ff       	jmp    800441 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800786:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800791:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800794:	eb 01                	jmp    800797 <vprintfmt+0x379>
  800796:	4e                   	dec    %esi
  800797:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80079b:	75 f9                	jne    800796 <vprintfmt+0x378>
  80079d:	e9 9f fc ff ff       	jmp    800441 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007a2:	83 c4 4c             	add    $0x4c,%esp
  8007a5:	5b                   	pop    %ebx
  8007a6:	5e                   	pop    %esi
  8007a7:	5f                   	pop    %edi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 28             	sub    $0x28,%esp
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	74 30                	je     8007fb <vsnprintf+0x51>
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	7e 33                	jle    800802 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	c7 04 24 dc 03 80 00 	movl   $0x8003dc,(%esp)
  8007eb:	e8 2e fc ff ff       	call   80041e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f9:	eb 0c                	jmp    800807 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800800:	eb 05                	jmp    800807 <vsnprintf+0x5d>
  800802:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800807:	c9                   	leave  
  800808:	c3                   	ret    

00800809 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800812:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800816:	8b 45 10             	mov    0x10(%ebp),%eax
  800819:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800820:	89 44 24 04          	mov    %eax,0x4(%esp)
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 7b ff ff ff       	call   8007aa <vsnprintf>
	va_end(ap);

	return rc;
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    
  800831:	00 00                	add    %al,(%eax)
	...

00800834 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	eb 01                	jmp    800842 <strlen+0xe>
		n++;
  800841:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800846:	75 f9                	jne    800841 <strlen+0xd>
		n++;
	return n;
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 01                	jmp    80085b <strnlen+0x11>
		n++;
  80085a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1b>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f5                	jne    80085a <strnlen+0x10>
		n++;
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	ba 00 00 00 00       	mov    $0x0,%edx
  800876:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800879:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80087c:	42                   	inc    %edx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	75 f5                	jne    800876 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800881:	5b                   	pop    %ebx
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	53                   	push   %ebx
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088e:	89 1c 24             	mov    %ebx,(%esp)
  800891:	e8 9e ff ff ff       	call   800834 <strlen>
	strcpy(dst + len, src);
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
  800899:	89 54 24 04          	mov    %edx,0x4(%esp)
  80089d:	01 d8                	add    %ebx,%eax
  80089f:	89 04 24             	mov    %eax,(%esp)
  8008a2:	e8 c0 ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008a7:	89 d8                	mov    %ebx,%eax
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	5b                   	pop    %ebx
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c2:	eb 0c                	jmp    8008d0 <strncpy+0x21>
		*dst++ = *src;
  8008c4:	8a 1a                	mov    (%edx),%bl
  8008c6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008cc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cf:	41                   	inc    %ecx
  8008d0:	39 f1                	cmp    %esi,%ecx
  8008d2:	75 f0                	jne    8008c4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	85 d2                	test   %edx,%edx
  8008e8:	75 0a                	jne    8008f4 <strlcpy+0x1c>
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	eb 1a                	jmp    800908 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ee:	88 18                	mov    %bl,(%eax)
  8008f0:	40                   	inc    %eax
  8008f1:	41                   	inc    %ecx
  8008f2:	eb 02                	jmp    8008f6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008f6:	4a                   	dec    %edx
  8008f7:	74 0a                	je     800903 <strlcpy+0x2b>
  8008f9:	8a 19                	mov    (%ecx),%bl
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	75 ef                	jne    8008ee <strlcpy+0x16>
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	eb 02                	jmp    800905 <strlcpy+0x2d>
  800903:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800905:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800908:	29 f0                	sub    %esi,%eax
}
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800914:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800917:	eb 02                	jmp    80091b <strcmp+0xd>
		p++, q++;
  800919:	41                   	inc    %ecx
  80091a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091b:	8a 01                	mov    (%ecx),%al
  80091d:	84 c0                	test   %al,%al
  80091f:	74 04                	je     800925 <strcmp+0x17>
  800921:	3a 02                	cmp    (%edx),%al
  800923:	74 f4                	je     800919 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800925:	0f b6 c0             	movzbl %al,%eax
  800928:	0f b6 12             	movzbl (%edx),%edx
  80092b:	29 d0                	sub    %edx,%eax
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800939:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80093c:	eb 03                	jmp    800941 <strncmp+0x12>
		n--, p++, q++;
  80093e:	4a                   	dec    %edx
  80093f:	40                   	inc    %eax
  800940:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800941:	85 d2                	test   %edx,%edx
  800943:	74 14                	je     800959 <strncmp+0x2a>
  800945:	8a 18                	mov    (%eax),%bl
  800947:	84 db                	test   %bl,%bl
  800949:	74 04                	je     80094f <strncmp+0x20>
  80094b:	3a 19                	cmp    (%ecx),%bl
  80094d:	74 ef                	je     80093e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	0f b6 00             	movzbl (%eax),%eax
  800952:	0f b6 11             	movzbl (%ecx),%edx
  800955:	29 d0                	sub    %edx,%eax
  800957:	eb 05                	jmp    80095e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096a:	eb 05                	jmp    800971 <strchr+0x10>
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	74 0c                	je     80097c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800970:	40                   	inc    %eax
  800971:	8a 10                	mov    (%eax),%dl
  800973:	84 d2                	test   %dl,%dl
  800975:	75 f5                	jne    80096c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800987:	eb 05                	jmp    80098e <strfind+0x10>
		if (*s == c)
  800989:	38 ca                	cmp    %cl,%dl
  80098b:	74 07                	je     800994 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098d:	40                   	inc    %eax
  80098e:	8a 10                	mov    (%eax),%dl
  800990:	84 d2                	test   %dl,%dl
  800992:	75 f5                	jne    800989 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	57                   	push   %edi
  80099a:	56                   	push   %esi
  80099b:	53                   	push   %ebx
  80099c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a5:	85 c9                	test   %ecx,%ecx
  8009a7:	74 30                	je     8009d9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009af:	75 25                	jne    8009d6 <memset+0x40>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 20                	jne    8009d6 <memset+0x40>
		c &= 0xFF;
  8009b6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b9:	89 d3                	mov    %edx,%ebx
  8009bb:	c1 e3 08             	shl    $0x8,%ebx
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	c1 e6 18             	shl    $0x18,%esi
  8009c3:	89 d0                	mov    %edx,%eax
  8009c5:	c1 e0 10             	shl    $0x10,%eax
  8009c8:	09 f0                	or     %esi,%eax
  8009ca:	09 d0                	or     %edx,%eax
  8009cc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ce:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d1:	fc                   	cld    
  8009d2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d4:	eb 03                	jmp    8009d9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d6:	fc                   	cld    
  8009d7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d9:	89 f8                	mov    %edi,%eax
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5f                   	pop    %edi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ee:	39 c6                	cmp    %eax,%esi
  8009f0:	73 34                	jae    800a26 <memmove+0x46>
  8009f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f5:	39 d0                	cmp    %edx,%eax
  8009f7:	73 2d                	jae    800a26 <memmove+0x46>
		s += n;
		d += n;
  8009f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	f6 c2 03             	test   $0x3,%dl
  8009ff:	75 1b                	jne    800a1c <memmove+0x3c>
  800a01:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a07:	75 13                	jne    800a1c <memmove+0x3c>
  800a09:	f6 c1 03             	test   $0x3,%cl
  800a0c:	75 0e                	jne    800a1c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0e:	83 ef 04             	sub    $0x4,%edi
  800a11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a14:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a17:	fd                   	std    
  800a18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1a:	eb 07                	jmp    800a23 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1c:	4f                   	dec    %edi
  800a1d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a20:	fd                   	std    
  800a21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a23:	fc                   	cld    
  800a24:	eb 20                	jmp    800a46 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a2c:	75 13                	jne    800a41 <memmove+0x61>
  800a2e:	a8 03                	test   $0x3,%al
  800a30:	75 0f                	jne    800a41 <memmove+0x61>
  800a32:	f6 c1 03             	test   $0x3,%cl
  800a35:	75 0a                	jne    800a41 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a37:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a3a:	89 c7                	mov    %eax,%edi
  800a3c:	fc                   	cld    
  800a3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3f:	eb 05                	jmp    800a46 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a41:	89 c7                	mov    %eax,%edi
  800a43:	fc                   	cld    
  800a44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a50:	8b 45 10             	mov    0x10(%ebp),%eax
  800a53:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	89 04 24             	mov    %eax,(%esp)
  800a64:	e8 77 ff ff ff       	call   8009e0 <memmove>
}
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7f:	eb 16                	jmp    800a97 <memcmp+0x2c>
		if (*s1 != *s2)
  800a81:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a84:	42                   	inc    %edx
  800a85:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a89:	38 c8                	cmp    %cl,%al
  800a8b:	74 0a                	je     800a97 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a8d:	0f b6 c0             	movzbl %al,%eax
  800a90:	0f b6 c9             	movzbl %cl,%ecx
  800a93:	29 c8                	sub    %ecx,%eax
  800a95:	eb 09                	jmp    800aa0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a97:	39 da                	cmp    %ebx,%edx
  800a99:	75 e6                	jne    800a81 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aae:	89 c2                	mov    %eax,%edx
  800ab0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab3:	eb 05                	jmp    800aba <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab5:	38 08                	cmp    %cl,(%eax)
  800ab7:	74 05                	je     800abe <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab9:	40                   	inc    %eax
  800aba:	39 d0                	cmp    %edx,%eax
  800abc:	72 f7                	jb     800ab5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acc:	eb 01                	jmp    800acf <strtol+0xf>
		s++;
  800ace:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acf:	8a 02                	mov    (%edx),%al
  800ad1:	3c 20                	cmp    $0x20,%al
  800ad3:	74 f9                	je     800ace <strtol+0xe>
  800ad5:	3c 09                	cmp    $0x9,%al
  800ad7:	74 f5                	je     800ace <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad9:	3c 2b                	cmp    $0x2b,%al
  800adb:	75 08                	jne    800ae5 <strtol+0x25>
		s++;
  800add:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae3:	eb 13                	jmp    800af8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae5:	3c 2d                	cmp    $0x2d,%al
  800ae7:	75 0a                	jne    800af3 <strtol+0x33>
		s++, neg = 1;
  800ae9:	8d 52 01             	lea    0x1(%edx),%edx
  800aec:	bf 01 00 00 00       	mov    $0x1,%edi
  800af1:	eb 05                	jmp    800af8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800af3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af8:	85 db                	test   %ebx,%ebx
  800afa:	74 05                	je     800b01 <strtol+0x41>
  800afc:	83 fb 10             	cmp    $0x10,%ebx
  800aff:	75 28                	jne    800b29 <strtol+0x69>
  800b01:	8a 02                	mov    (%edx),%al
  800b03:	3c 30                	cmp    $0x30,%al
  800b05:	75 10                	jne    800b17 <strtol+0x57>
  800b07:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0b:	75 0a                	jne    800b17 <strtol+0x57>
		s += 2, base = 16;
  800b0d:	83 c2 02             	add    $0x2,%edx
  800b10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b15:	eb 12                	jmp    800b29 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	75 0e                	jne    800b29 <strtol+0x69>
  800b1b:	3c 30                	cmp    $0x30,%al
  800b1d:	75 05                	jne    800b24 <strtol+0x64>
		s++, base = 8;
  800b1f:	42                   	inc    %edx
  800b20:	b3 08                	mov    $0x8,%bl
  800b22:	eb 05                	jmp    800b29 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b24:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b30:	8a 0a                	mov    (%edx),%cl
  800b32:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b35:	80 fb 09             	cmp    $0x9,%bl
  800b38:	77 08                	ja     800b42 <strtol+0x82>
			dig = *s - '0';
  800b3a:	0f be c9             	movsbl %cl,%ecx
  800b3d:	83 e9 30             	sub    $0x30,%ecx
  800b40:	eb 1e                	jmp    800b60 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b42:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b45:	80 fb 19             	cmp    $0x19,%bl
  800b48:	77 08                	ja     800b52 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b4a:	0f be c9             	movsbl %cl,%ecx
  800b4d:	83 e9 57             	sub    $0x57,%ecx
  800b50:	eb 0e                	jmp    800b60 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b52:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b55:	80 fb 19             	cmp    $0x19,%bl
  800b58:	77 12                	ja     800b6c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b5a:	0f be c9             	movsbl %cl,%ecx
  800b5d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b60:	39 f1                	cmp    %esi,%ecx
  800b62:	7d 0c                	jge    800b70 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b64:	42                   	inc    %edx
  800b65:	0f af c6             	imul   %esi,%eax
  800b68:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b6a:	eb c4                	jmp    800b30 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b6c:	89 c1                	mov    %eax,%ecx
  800b6e:	eb 02                	jmp    800b72 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b70:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b76:	74 05                	je     800b7d <strtol+0xbd>
		*endptr = (char *) s;
  800b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b7d:	85 ff                	test   %edi,%edi
  800b7f:	74 04                	je     800b85 <strtol+0xc5>
  800b81:	89 c8                	mov    %ecx,%eax
  800b83:	f7 d8                	neg    %eax
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    
	...

00800b8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	89 c3                	mov    %eax,%ebx
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	89 c6                	mov    %eax,%esi
  800ba3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_cgetc>:

int
sys_cgetc(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 cb                	mov    %ecx,%ebx
  800be1:	89 cf                	mov    %ecx,%edi
  800be3:	89 ce                	mov    %ecx,%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 28                	jle    800c13 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800c0e:	e8 b1 f5 ff ff       	call   8001c4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c13:	83 c4 2c             	add    $0x2c,%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2b:	89 d1                	mov    %edx,%ecx
  800c2d:	89 d3                	mov    %edx,%ebx
  800c2f:	89 d7                	mov    %edx,%edi
  800c31:	89 d6                	mov    %edx,%esi
  800c33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_yield>:

void
sys_yield(void)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	be 00 00 00 00       	mov    $0x0,%esi
  800c67:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	89 f7                	mov    %esi,%edi
  800c77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 28                	jle    800ca5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c81:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c88:	00 
  800c89:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800c90:	00 
  800c91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c98:	00 
  800c99:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800ca0:	e8 1f f5 ff ff       	call   8001c4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca5:	83 c4 2c             	add    $0x2c,%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800cbb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7e 28                	jle    800cf8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cdb:	00 
  800cdc:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ceb:	00 
  800cec:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800cf3:	e8 cc f4 ff ff       	call   8001c4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf8:	83 c4 2c             	add    $0x2c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 28                	jle    800d4b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d27:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d2e:	00 
  800d2f:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800d36:	00 
  800d37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3e:	00 
  800d3f:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800d46:	e8 79 f4 ff ff       	call   8001c4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d4b:	83 c4 2c             	add    $0x2c,%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 08 00 00 00       	mov    $0x8,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 28                	jle    800d9e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d81:	00 
  800d82:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800d89:	00 
  800d8a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d91:	00 
  800d92:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800d99:	e8 26 f4 ff ff       	call   8001c4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9e:	83 c4 2c             	add    $0x2c,%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db4:	b8 09 00 00 00       	mov    $0x9,%eax
  800db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	89 df                	mov    %ebx,%edi
  800dc1:	89 de                	mov    %ebx,%esi
  800dc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 28                	jle    800df1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd4:	00 
  800dd5:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800dec:	e8 d3 f3 ff ff       	call   8001c4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df1:	83 c4 2c             	add    $0x2c,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	89 df                	mov    %ebx,%edi
  800e14:	89 de                	mov    %ebx,%esi
  800e16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	7e 28                	jle    800e44 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e20:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e27:	00 
  800e28:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800e2f:	00 
  800e30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e37:	00 
  800e38:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800e3f:	e8 80 f3 ff ff       	call   8001c4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e44:	83 c4 2c             	add    $0x2c,%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e52:	be 00 00 00 00       	mov    $0x0,%esi
  800e57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e5c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5e                   	pop    %esi
  800e6c:	5f                   	pop    %edi
  800e6d:	5d                   	pop    %ebp
  800e6e:	c3                   	ret    

00800e6f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
  800e75:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	89 cb                	mov    %ecx,%ebx
  800e87:	89 cf                	mov    %ecx,%edi
  800e89:	89 ce                	mov    %ecx,%esi
  800e8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	7e 28                	jle    800eb9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e95:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 08 9f 2a 80 	movl   $0x802a9f,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  800eb4:	e8 0b f3 ff ff       	call   8001c4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb9:	83 c4 2c             	add    $0x2c,%esp
  800ebc:	5b                   	pop    %ebx
  800ebd:	5e                   	pop    %esi
  800ebe:	5f                   	pop    %edi
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    
  800ec1:	00 00                	add    %al,(%eax)
	...

00800ec4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecf:	c1 e8 0c             	shr    $0xc,%eax
}
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	89 04 24             	mov    %eax,(%esp)
  800ee0:	e8 df ff ff ff       	call   800ec4 <fd2num>
  800ee5:	05 20 00 0d 00       	add    $0xd0020,%eax
  800eea:	c1 e0 0c             	shl    $0xc,%eax
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	53                   	push   %ebx
  800ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ef6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800efb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efd:	89 c2                	mov    %eax,%edx
  800eff:	c1 ea 16             	shr    $0x16,%edx
  800f02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f09:	f6 c2 01             	test   $0x1,%dl
  800f0c:	74 11                	je     800f1f <fd_alloc+0x30>
  800f0e:	89 c2                	mov    %eax,%edx
  800f10:	c1 ea 0c             	shr    $0xc,%edx
  800f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1a:	f6 c2 01             	test   $0x1,%dl
  800f1d:	75 09                	jne    800f28 <fd_alloc+0x39>
			*fd_store = fd;
  800f1f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
  800f26:	eb 17                	jmp    800f3f <fd_alloc+0x50>
  800f28:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f2d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f32:	75 c7                	jne    800efb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f34:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f3a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f3f:	5b                   	pop    %ebx
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f48:	83 f8 1f             	cmp    $0x1f,%eax
  800f4b:	77 36                	ja     800f83 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f52:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f55:	89 c2                	mov    %eax,%edx
  800f57:	c1 ea 16             	shr    $0x16,%edx
  800f5a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f61:	f6 c2 01             	test   $0x1,%dl
  800f64:	74 24                	je     800f8a <fd_lookup+0x48>
  800f66:	89 c2                	mov    %eax,%edx
  800f68:	c1 ea 0c             	shr    $0xc,%edx
  800f6b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f72:	f6 c2 01             	test   $0x1,%dl
  800f75:	74 1a                	je     800f91 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7a:	89 02                	mov    %eax,(%edx)
	return 0;
  800f7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f81:	eb 13                	jmp    800f96 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f88:	eb 0c                	jmp    800f96 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8f:	eb 05                	jmp    800f96 <fd_lookup+0x54>
  800f91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f96:	5d                   	pop    %ebp
  800f97:	c3                   	ret    

00800f98 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 14             	sub    $0x14,%esp
  800f9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800faa:	eb 0e                	jmp    800fba <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fac:	39 08                	cmp    %ecx,(%eax)
  800fae:	75 09                	jne    800fb9 <dev_lookup+0x21>
			*dev = devtab[i];
  800fb0:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	eb 33                	jmp    800fec <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb9:	42                   	inc    %edx
  800fba:	8b 04 95 48 2b 80 00 	mov    0x802b48(,%edx,4),%eax
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	75 e7                	jne    800fac <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fc5:	a1 04 40 80 00       	mov    0x804004,%eax
  800fca:	8b 40 48             	mov    0x48(%eax),%eax
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd5:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  800fdc:	e8 db f2 ff ff       	call   8002bc <cprintf>
	*dev = 0;
  800fe1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fec:	83 c4 14             	add    $0x14,%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	56                   	push   %esi
  800ff6:	53                   	push   %ebx
  800ff7:	83 ec 30             	sub    $0x30,%esp
  800ffa:	8b 75 08             	mov    0x8(%ebp),%esi
  800ffd:	8a 45 0c             	mov    0xc(%ebp),%al
  801000:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801003:	89 34 24             	mov    %esi,(%esp)
  801006:	e8 b9 fe ff ff       	call   800ec4 <fd2num>
  80100b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80100e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801012:	89 04 24             	mov    %eax,(%esp)
  801015:	e8 28 ff ff ff       	call   800f42 <fd_lookup>
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 05                	js     801025 <fd_close+0x33>
	    || fd != fd2)
  801020:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801023:	74 0d                	je     801032 <fd_close+0x40>
		return (must_exist ? r : 0);
  801025:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801029:	75 46                	jne    801071 <fd_close+0x7f>
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801030:	eb 3f                	jmp    801071 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801032:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801035:	89 44 24 04          	mov    %eax,0x4(%esp)
  801039:	8b 06                	mov    (%esi),%eax
  80103b:	89 04 24             	mov    %eax,(%esp)
  80103e:	e8 55 ff ff ff       	call   800f98 <dev_lookup>
  801043:	89 c3                	mov    %eax,%ebx
  801045:	85 c0                	test   %eax,%eax
  801047:	78 18                	js     801061 <fd_close+0x6f>
		if (dev->dev_close)
  801049:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104c:	8b 40 10             	mov    0x10(%eax),%eax
  80104f:	85 c0                	test   %eax,%eax
  801051:	74 09                	je     80105c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801053:	89 34 24             	mov    %esi,(%esp)
  801056:	ff d0                	call   *%eax
  801058:	89 c3                	mov    %eax,%ebx
  80105a:	eb 05                	jmp    801061 <fd_close+0x6f>
		else
			r = 0;
  80105c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801061:	89 74 24 04          	mov    %esi,0x4(%esp)
  801065:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106c:	e8 8f fc ff ff       	call   800d00 <sys_page_unmap>
	return r;
}
  801071:	89 d8                	mov    %ebx,%eax
  801073:	83 c4 30             	add    $0x30,%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801083:	89 44 24 04          	mov    %eax,0x4(%esp)
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	89 04 24             	mov    %eax,(%esp)
  80108d:	e8 b0 fe ff ff       	call   800f42 <fd_lookup>
  801092:	85 c0                	test   %eax,%eax
  801094:	78 13                	js     8010a9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801096:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80109d:	00 
  80109e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 49 ff ff ff       	call   800ff2 <fd_close>
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <close_all>:

void
close_all(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	53                   	push   %ebx
  8010af:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010b7:	89 1c 24             	mov    %ebx,(%esp)
  8010ba:	e8 bb ff ff ff       	call   80107a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010bf:	43                   	inc    %ebx
  8010c0:	83 fb 20             	cmp    $0x20,%ebx
  8010c3:	75 f2                	jne    8010b7 <close_all+0xc>
		close(i);
}
  8010c5:	83 c4 14             	add    $0x14,%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 4c             	sub    $0x4c,%esp
  8010d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010de:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	e8 59 fe ff ff       	call   800f42 <fd_lookup>
  8010e9:	89 c3                	mov    %eax,%ebx
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	0f 88 e1 00 00 00    	js     8011d4 <dup+0x109>
		return r;
	close(newfdnum);
  8010f3:	89 3c 24             	mov    %edi,(%esp)
  8010f6:	e8 7f ff ff ff       	call   80107a <close>

	newfd = INDEX2FD(newfdnum);
  8010fb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801101:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801107:	89 04 24             	mov    %eax,(%esp)
  80110a:	e8 c5 fd ff ff       	call   800ed4 <fd2data>
  80110f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801111:	89 34 24             	mov    %esi,(%esp)
  801114:	e8 bb fd ff ff       	call   800ed4 <fd2data>
  801119:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80111c:	89 d8                	mov    %ebx,%eax
  80111e:	c1 e8 16             	shr    $0x16,%eax
  801121:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801128:	a8 01                	test   $0x1,%al
  80112a:	74 46                	je     801172 <dup+0xa7>
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	c1 e8 0c             	shr    $0xc,%eax
  801131:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	74 35                	je     801172 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80113d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801144:	25 07 0e 00 00       	and    $0xe07,%eax
  801149:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801150:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801154:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80115b:	00 
  80115c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801160:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801167:	e8 41 fb ff ff       	call   800cad <sys_page_map>
  80116c:	89 c3                	mov    %eax,%ebx
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 3b                	js     8011ad <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801175:	89 c2                	mov    %eax,%edx
  801177:	c1 ea 0c             	shr    $0xc,%edx
  80117a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801181:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801187:	89 54 24 10          	mov    %edx,0x10(%esp)
  80118b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80118f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801196:	00 
  801197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a2:	e8 06 fb ff ff       	call   800cad <sys_page_map>
  8011a7:	89 c3                	mov    %eax,%ebx
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	79 25                	jns    8011d2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b8:	e8 43 fb ff ff       	call   800d00 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cb:	e8 30 fb ff ff       	call   800d00 <sys_page_unmap>
	return r;
  8011d0:	eb 02                	jmp    8011d4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011d2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	83 c4 4c             	add    $0x4c,%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5f                   	pop    %edi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 24             	sub    $0x24,%esp
  8011e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ef:	89 1c 24             	mov    %ebx,(%esp)
  8011f2:	e8 4b fd ff ff       	call   800f42 <fd_lookup>
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 6d                	js     801268 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801202:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801205:	8b 00                	mov    (%eax),%eax
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	e8 89 fd ff ff       	call   800f98 <dev_lookup>
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 55                	js     801268 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	8b 50 08             	mov    0x8(%eax),%edx
  801219:	83 e2 03             	and    $0x3,%edx
  80121c:	83 fa 01             	cmp    $0x1,%edx
  80121f:	75 23                	jne    801244 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801221:	a1 04 40 80 00       	mov    0x804004,%eax
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80122d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801231:	c7 04 24 0d 2b 80 00 	movl   $0x802b0d,(%esp)
  801238:	e8 7f f0 ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  80123d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801242:	eb 24                	jmp    801268 <read+0x8a>
	}
	if (!dev->dev_read)
  801244:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801247:	8b 52 08             	mov    0x8(%edx),%edx
  80124a:	85 d2                	test   %edx,%edx
  80124c:	74 15                	je     801263 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80124e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801251:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801258:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80125c:	89 04 24             	mov    %eax,(%esp)
  80125f:	ff d2                	call   *%edx
  801261:	eb 05                	jmp    801268 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801263:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801268:	83 c4 24             	add    $0x24,%esp
  80126b:	5b                   	pop    %ebx
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 7d 08             	mov    0x8(%ebp),%edi
  80127a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80127d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801282:	eb 23                	jmp    8012a7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801284:	89 f0                	mov    %esi,%eax
  801286:	29 d8                	sub    %ebx,%eax
  801288:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128f:	01 d8                	add    %ebx,%eax
  801291:	89 44 24 04          	mov    %eax,0x4(%esp)
  801295:	89 3c 24             	mov    %edi,(%esp)
  801298:	e8 41 ff ff ff       	call   8011de <read>
		if (m < 0)
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 10                	js     8012b1 <readn+0x43>
			return m;
		if (m == 0)
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	74 0a                	je     8012af <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012a5:	01 c3                	add    %eax,%ebx
  8012a7:	39 f3                	cmp    %esi,%ebx
  8012a9:	72 d9                	jb     801284 <readn+0x16>
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	eb 02                	jmp    8012b1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012af:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012b1:	83 c4 1c             	add    $0x1c,%esp
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 24             	sub    $0x24,%esp
  8012c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ca:	89 1c 24             	mov    %ebx,(%esp)
  8012cd:	e8 70 fc ff ff       	call   800f42 <fd_lookup>
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 68                	js     80133e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e0:	8b 00                	mov    (%eax),%eax
  8012e2:	89 04 24             	mov    %eax,(%esp)
  8012e5:	e8 ae fc ff ff       	call   800f98 <dev_lookup>
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 50                	js     80133e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f5:	75 23                	jne    80131a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8012fc:	8b 40 48             	mov    0x48(%eax),%eax
  8012ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	c7 04 24 29 2b 80 00 	movl   $0x802b29,(%esp)
  80130e:	e8 a9 ef ff ff       	call   8002bc <cprintf>
		return -E_INVAL;
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801318:	eb 24                	jmp    80133e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80131a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131d:	8b 52 0c             	mov    0xc(%edx),%edx
  801320:	85 d2                	test   %edx,%edx
  801322:	74 15                	je     801339 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801324:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801327:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80132e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	ff d2                	call   *%edx
  801337:	eb 05                	jmp    80133e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801339:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80133e:	83 c4 24             	add    $0x24,%esp
  801341:	5b                   	pop    %ebx
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <seek>:

int
seek(int fdnum, off_t offset)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	89 04 24             	mov    %eax,(%esp)
  801357:	e8 e6 fb ff ff       	call   800f42 <fd_lookup>
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 0e                	js     80136e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801360:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801363:	8b 55 0c             	mov    0xc(%ebp),%edx
  801366:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	53                   	push   %ebx
  801374:	83 ec 24             	sub    $0x24,%esp
  801377:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801381:	89 1c 24             	mov    %ebx,(%esp)
  801384:	e8 b9 fb ff ff       	call   800f42 <fd_lookup>
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 61                	js     8013ee <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801390:	89 44 24 04          	mov    %eax,0x4(%esp)
  801394:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801397:	8b 00                	mov    (%eax),%eax
  801399:	89 04 24             	mov    %eax,(%esp)
  80139c:	e8 f7 fb ff ff       	call   800f98 <dev_lookup>
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 49                	js     8013ee <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013ac:	75 23                	jne    8013d1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013ae:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013b3:	8b 40 48             	mov    0x48(%eax),%eax
  8013b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013be:	c7 04 24 ec 2a 80 00 	movl   $0x802aec,(%esp)
  8013c5:	e8 f2 ee ff ff       	call   8002bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cf:	eb 1d                	jmp    8013ee <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d4:	8b 52 18             	mov    0x18(%edx),%edx
  8013d7:	85 d2                	test   %edx,%edx
  8013d9:	74 0e                	je     8013e9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	ff d2                	call   *%edx
  8013e7:	eb 05                	jmp    8013ee <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013ee:	83 c4 24             	add    $0x24,%esp
  8013f1:	5b                   	pop    %ebx
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    

008013f4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	53                   	push   %ebx
  8013f8:	83 ec 24             	sub    $0x24,%esp
  8013fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	89 04 24             	mov    %eax,(%esp)
  80140b:	e8 32 fb ff ff       	call   800f42 <fd_lookup>
  801410:	85 c0                	test   %eax,%eax
  801412:	78 52                	js     801466 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801414:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	8b 00                	mov    (%eax),%eax
  801420:	89 04 24             	mov    %eax,(%esp)
  801423:	e8 70 fb ff ff       	call   800f98 <dev_lookup>
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 3a                	js     801466 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801433:	74 2c                	je     801461 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801435:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801438:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80143f:	00 00 00 
	stat->st_isdir = 0;
  801442:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801449:	00 00 00 
	stat->st_dev = dev;
  80144c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801452:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801456:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801459:	89 14 24             	mov    %edx,(%esp)
  80145c:	ff 50 14             	call   *0x14(%eax)
  80145f:	eb 05                	jmp    801466 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801461:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801466:	83 c4 24             	add    $0x24,%esp
  801469:	5b                   	pop    %ebx
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	56                   	push   %esi
  801470:	53                   	push   %ebx
  801471:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801474:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80147b:	00 
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	89 04 24             	mov    %eax,(%esp)
  801482:	e8 2d 02 00 00       	call   8016b4 <open>
  801487:	89 c3                	mov    %eax,%ebx
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 1b                	js     8014a8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80148d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801490:	89 44 24 04          	mov    %eax,0x4(%esp)
  801494:	89 1c 24             	mov    %ebx,(%esp)
  801497:	e8 58 ff ff ff       	call   8013f4 <fstat>
  80149c:	89 c6                	mov    %eax,%esi
	close(fd);
  80149e:	89 1c 24             	mov    %ebx,(%esp)
  8014a1:	e8 d4 fb ff ff       	call   80107a <close>
	return r;
  8014a6:	89 f3                	mov    %esi,%ebx
}
  8014a8:	89 d8                	mov    %ebx,%eax
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    
  8014b1:	00 00                	add    %al,(%eax)
	...

008014b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	56                   	push   %esi
  8014b8:	53                   	push   %ebx
  8014b9:	83 ec 10             	sub    $0x10,%esp
  8014bc:	89 c3                	mov    %eax,%ebx
  8014be:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014c0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014c7:	75 11                	jne    8014da <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014d0:	e8 e6 0e 00 00       	call   8023bb <ipc_find_env>
  8014d5:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014da:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014e1:	00 
  8014e2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8014e9:	00 
  8014ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 52 0e 00 00       	call   80234d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801502:	00 
  801503:	89 74 24 04          	mov    %esi,0x4(%esp)
  801507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150e:	e8 d1 0d 00 00       	call   8022e4 <ipc_recv>
}
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	5b                   	pop    %ebx
  801517:	5e                   	pop    %esi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	8b 40 0c             	mov    0xc(%eax),%eax
  801526:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80152b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801533:	ba 00 00 00 00       	mov    $0x0,%edx
  801538:	b8 02 00 00 00       	mov    $0x2,%eax
  80153d:	e8 72 ff ff ff       	call   8014b4 <fsipc>
}
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80154a:	8b 45 08             	mov    0x8(%ebp),%eax
  80154d:	8b 40 0c             	mov    0xc(%eax),%eax
  801550:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	b8 06 00 00 00       	mov    $0x6,%eax
  80155f:	e8 50 ff ff ff       	call   8014b4 <fsipc>
}
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 14             	sub    $0x14,%esp
  80156d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	8b 40 0c             	mov    0xc(%eax),%eax
  801576:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80157b:	ba 00 00 00 00       	mov    $0x0,%edx
  801580:	b8 05 00 00 00       	mov    $0x5,%eax
  801585:	e8 2a ff ff ff       	call   8014b4 <fsipc>
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 2b                	js     8015b9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80158e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801595:	00 
  801596:	89 1c 24             	mov    %ebx,(%esp)
  801599:	e8 c9 f2 ff ff       	call   800867 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80159e:	a1 80 50 80 00       	mov    0x805080,%eax
  8015a3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015a9:	a1 84 50 80 00       	mov    0x805084,%eax
  8015ae:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015b9:	83 c4 14             	add    $0x14,%esp
  8015bc:	5b                   	pop    %ebx
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    

008015bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 18             	sub    $0x18,%esp
  8015c5:	8b 55 10             	mov    0x10(%ebp),%edx
  8015c8:	89 d0                	mov    %edx,%eax
  8015ca:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8015d0:	76 05                	jbe    8015d7 <devfile_write+0x18>
  8015d2:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015da:	8b 52 0c             	mov    0xc(%edx),%edx
  8015dd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015e3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8015fa:	e8 e1 f3 ff ff       	call   8009e0 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  8015ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801604:	b8 04 00 00 00       	mov    $0x4,%eax
  801609:	e8 a6 fe ff ff       	call   8014b4 <fsipc>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	83 ec 10             	sub    $0x10,%esp
  801618:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80161b:	8b 45 08             	mov    0x8(%ebp),%eax
  80161e:	8b 40 0c             	mov    0xc(%eax),%eax
  801621:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801626:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80162c:	ba 00 00 00 00       	mov    $0x0,%edx
  801631:	b8 03 00 00 00       	mov    $0x3,%eax
  801636:	e8 79 fe ff ff       	call   8014b4 <fsipc>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 6a                	js     8016ab <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801641:	39 c6                	cmp    %eax,%esi
  801643:	73 24                	jae    801669 <devfile_read+0x59>
  801645:	c7 44 24 0c 58 2b 80 	movl   $0x802b58,0xc(%esp)
  80164c:	00 
  80164d:	c7 44 24 08 5f 2b 80 	movl   $0x802b5f,0x8(%esp)
  801654:	00 
  801655:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80165c:	00 
  80165d:	c7 04 24 74 2b 80 00 	movl   $0x802b74,(%esp)
  801664:	e8 5b eb ff ff       	call   8001c4 <_panic>
	assert(r <= PGSIZE);
  801669:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80166e:	7e 24                	jle    801694 <devfile_read+0x84>
  801670:	c7 44 24 0c 7f 2b 80 	movl   $0x802b7f,0xc(%esp)
  801677:	00 
  801678:	c7 44 24 08 5f 2b 80 	movl   $0x802b5f,0x8(%esp)
  80167f:	00 
  801680:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801687:	00 
  801688:	c7 04 24 74 2b 80 00 	movl   $0x802b74,(%esp)
  80168f:	e8 30 eb ff ff       	call   8001c4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801694:	89 44 24 08          	mov    %eax,0x8(%esp)
  801698:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80169f:	00 
  8016a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 35 f3 ff ff       	call   8009e0 <memmove>
	return r;
}
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5e                   	pop    %esi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 20             	sub    $0x20,%esp
  8016bc:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016bf:	89 34 24             	mov    %esi,(%esp)
  8016c2:	e8 6d f1 ff ff       	call   800834 <strlen>
  8016c7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016cc:	7f 60                	jg     80172e <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 16 f8 ff ff       	call   800eef <fd_alloc>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 54                	js     801733 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8016ea:	e8 78 f1 ff ff       	call   800867 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8016ff:	e8 b0 fd ff ff       	call   8014b4 <fsipc>
  801704:	89 c3                	mov    %eax,%ebx
  801706:	85 c0                	test   %eax,%eax
  801708:	79 15                	jns    80171f <open+0x6b>
		fd_close(fd, 0);
  80170a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801711:	00 
  801712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801715:	89 04 24             	mov    %eax,(%esp)
  801718:	e8 d5 f8 ff ff       	call   800ff2 <fd_close>
		return r;
  80171d:	eb 14                	jmp    801733 <open+0x7f>
	}

	return fd2num(fd);
  80171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801722:	89 04 24             	mov    %eax,(%esp)
  801725:	e8 9a f7 ff ff       	call   800ec4 <fd2num>
  80172a:	89 c3                	mov    %eax,%ebx
  80172c:	eb 05                	jmp    801733 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80172e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801733:	89 d8                	mov    %ebx,%eax
  801735:	83 c4 20             	add    $0x20,%esp
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801742:	ba 00 00 00 00       	mov    $0x0,%edx
  801747:	b8 08 00 00 00       	mov    $0x8,%eax
  80174c:	e8 63 fd ff ff       	call   8014b4 <fsipc>
}
  801751:	c9                   	leave  
  801752:	c3                   	ret    
	...

00801754 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	57                   	push   %edi
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801760:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801767:	00 
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	89 04 24             	mov    %eax,(%esp)
  80176e:	e8 41 ff ff ff       	call   8016b4 <open>
  801773:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801779:	85 c0                	test   %eax,%eax
  80177b:	0f 88 8c 05 00 00    	js     801d0d <spawn+0x5b9>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801781:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801788:	00 
  801789:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801799:	89 04 24             	mov    %eax,(%esp)
  80179c:	e8 cd fa ff ff       	call   80126e <readn>
  8017a1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8017a6:	75 0c                	jne    8017b4 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8017a8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8017af:	45 4c 46 
  8017b2:	74 3b                	je     8017ef <spawn+0x9b>
		close(fd);
  8017b4:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	e8 b8 f8 ff ff       	call   80107a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8017c2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8017c9:	46 
  8017ca:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8017d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d4:	c7 04 24 8b 2b 80 00 	movl   $0x802b8b,(%esp)
  8017db:	e8 dc ea ff ff       	call   8002bc <cprintf>
		return -E_NOT_EXEC;
  8017e0:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  8017e7:	ff ff ff 
  8017ea:	e9 2a 05 00 00       	jmp    801d19 <spawn+0x5c5>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8017ef:	ba 07 00 00 00       	mov    $0x7,%edx
  8017f4:	89 d0                	mov    %edx,%eax
  8017f6:	cd 30                	int    $0x30
  8017f8:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8017fe:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801804:	85 c0                	test   %eax,%eax
  801806:	0f 88 0d 05 00 00    	js     801d19 <spawn+0x5c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80180c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801811:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801818:	c1 e0 07             	shl    $0x7,%eax
  80181b:	29 d0                	sub    %edx,%eax
  80181d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801823:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801829:	b9 11 00 00 00       	mov    $0x11,%ecx
  80182e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801830:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801836:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80183c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801841:	bb 00 00 00 00       	mov    $0x0,%ebx
  801846:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801849:	eb 0d                	jmp    801858 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	e8 e1 ef ff ff       	call   800834 <strlen>
  801853:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801857:	46                   	inc    %esi
  801858:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80185a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801861:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801864:	85 c0                	test   %eax,%eax
  801866:	75 e3                	jne    80184b <spawn+0xf7>
  801868:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80186e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801874:	bf 00 10 40 00       	mov    $0x401000,%edi
  801879:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80187b:	89 f8                	mov    %edi,%eax
  80187d:	83 e0 fc             	and    $0xfffffffc,%eax
  801880:	f7 d2                	not    %edx
  801882:	8d 14 90             	lea    (%eax,%edx,4),%edx
  801885:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	83 e8 08             	sub    $0x8,%eax
  801890:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801895:	0f 86 8f 04 00 00    	jbe    801d2a <spawn+0x5d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80189b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018a2:	00 
  8018a3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018aa:	00 
  8018ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b2:	e8 a2 f3 ff ff       	call   800c59 <sys_page_alloc>
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	0f 88 70 04 00 00    	js     801d2f <spawn+0x5db>
  8018bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8018ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018cd:	eb 2e                	jmp    8018fd <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8018cf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8018d5:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8018db:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8018de:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8018e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e5:	89 3c 24             	mov    %edi,(%esp)
  8018e8:	e8 7a ef ff ff       	call   800867 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8018ed:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8018f0:	89 04 24             	mov    %eax,(%esp)
  8018f3:	e8 3c ef ff ff       	call   800834 <strlen>
  8018f8:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8018fc:	43                   	inc    %ebx
  8018fd:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801903:	7c ca                	jl     8018cf <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801905:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80190b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801911:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801918:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80191e:	74 24                	je     801944 <spawn+0x1f0>
  801920:	c7 44 24 0c 18 2c 80 	movl   $0x802c18,0xc(%esp)
  801927:	00 
  801928:	c7 44 24 08 5f 2b 80 	movl   $0x802b5f,0x8(%esp)
  80192f:	00 
  801930:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  801937:	00 
  801938:	c7 04 24 a5 2b 80 00 	movl   $0x802ba5,(%esp)
  80193f:	e8 80 e8 ff ff       	call   8001c4 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801944:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80194a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80194f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801955:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801958:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80195e:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801961:	89 d0                	mov    %edx,%eax
  801963:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801968:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80196e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801975:	00 
  801976:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  80197d:	ee 
  80197e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801984:	89 44 24 08          	mov    %eax,0x8(%esp)
  801988:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80198f:	00 
  801990:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801997:	e8 11 f3 ff ff       	call   800cad <sys_page_map>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 1a                	js     8019bc <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8019a2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019a9:	00 
  8019aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b1:	e8 4a f3 ff ff       	call   800d00 <sys_page_unmap>
  8019b6:	89 c3                	mov    %eax,%ebx
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	79 1f                	jns    8019db <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8019bc:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019c3:	00 
  8019c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019cb:	e8 30 f3 ff ff       	call   800d00 <sys_page_unmap>
	return r;
  8019d0:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8019d6:	e9 3e 03 00 00       	jmp    801d19 <spawn+0x5c5>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8019db:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8019e1:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8019e7:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019ed:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8019f4:	00 00 00 
  8019f7:	e9 bb 01 00 00       	jmp    801bb7 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8019fc:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a02:	83 38 01             	cmpl   $0x1,(%eax)
  801a05:	0f 85 9f 01 00 00    	jne    801baa <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a0b:	89 c2                	mov    %eax,%edx
  801a0d:	8b 40 18             	mov    0x18(%eax),%eax
  801a10:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a13:	83 f8 01             	cmp    $0x1,%eax
  801a16:	19 c0                	sbb    %eax,%eax
  801a18:	83 e0 fe             	and    $0xfffffffe,%eax
  801a1b:	83 c0 07             	add    $0x7,%eax
  801a1e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a24:	8b 52 04             	mov    0x4(%edx),%edx
  801a27:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801a2d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a33:	8b 40 10             	mov    0x10(%eax),%eax
  801a36:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801a3c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801a42:	8b 52 14             	mov    0x14(%edx),%edx
  801a45:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801a4b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a51:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801a54:	89 f8                	mov    %edi,%eax
  801a56:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a5b:	74 16                	je     801a73 <spawn+0x31f>
		va -= i;
  801a5d:	29 c7                	sub    %eax,%edi
		memsz += i;
  801a5f:	01 c2                	add    %eax,%edx
  801a61:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801a67:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801a6d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801a73:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a78:	e9 1f 01 00 00       	jmp    801b9c <spawn+0x448>
		if (i >= filesz) {
  801a7d:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801a83:	77 2b                	ja     801ab0 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801a85:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801a8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a8f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a93:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 b8 f1 ff ff       	call   800c59 <sys_page_alloc>
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	0f 89 e7 00 00 00    	jns    801b90 <spawn+0x43c>
  801aa9:	89 c6                	mov    %eax,%esi
  801aab:	e9 39 02 00 00       	jmp    801ce9 <spawn+0x595>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ab0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ab7:	00 
  801ab8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801abf:	00 
  801ac0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac7:	e8 8d f1 ff ff       	call   800c59 <sys_page_alloc>
  801acc:	85 c0                	test   %eax,%eax
  801ace:	0f 88 0b 02 00 00    	js     801cdf <spawn+0x58b>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801ad4:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801ada:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 56 f8 ff ff       	call   801344 <seek>
  801aee:	85 c0                	test   %eax,%eax
  801af0:	0f 88 ed 01 00 00    	js     801ce3 <spawn+0x58f>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801af6:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801afc:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801afe:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b03:	76 05                	jbe    801b0a <spawn+0x3b6>
  801b05:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b0e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b15:	00 
  801b16:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 4a f7 ff ff       	call   80126e <readn>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	0f 88 bb 01 00 00    	js     801ce7 <spawn+0x593>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b2c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801b32:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b36:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801b3a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b44:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b4b:	00 
  801b4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b53:	e8 55 f1 ff ff       	call   800cad <sys_page_map>
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	79 20                	jns    801b7c <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801b5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b60:	c7 44 24 08 b1 2b 80 	movl   $0x802bb1,0x8(%esp)
  801b67:	00 
  801b68:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801b6f:	00 
  801b70:	c7 04 24 a5 2b 80 00 	movl   $0x802ba5,(%esp)
  801b77:	e8 48 e6 ff ff       	call   8001c4 <_panic>
			sys_page_unmap(0, UTEMP);
  801b7c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b83:	00 
  801b84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8b:	e8 70 f1 ff ff       	call   800d00 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b90:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b96:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801b9c:	89 de                	mov    %ebx,%esi
  801b9e:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801ba4:	0f 82 d3 fe ff ff    	jb     801a7d <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801baa:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801bb0:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801bb7:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801bbe:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801bc4:	0f 8c 32 fe ff ff    	jl     8019fc <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801bca:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801bd0:	89 04 24             	mov    %eax,(%esp)
  801bd3:	e8 a2 f4 ff ff       	call   80107a <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801bd8:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  801bdd:	89 f0                	mov    %esi,%eax
  801bdf:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  801be2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801be9:	a8 01                	test   $0x1,%al
  801beb:	0f 84 82 00 00 00    	je     801c73 <spawn+0x51f>
  801bf1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801bf8:	a8 01                	test   $0x1,%al
  801bfa:	74 77                	je     801c73 <spawn+0x51f>
  801bfc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801c03:	f6 c4 04             	test   $0x4,%ah
  801c06:	74 6b                	je     801c73 <spawn+0x51f>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801c08:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801c0f:	89 f3                	mov    %esi,%ebx
  801c11:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801c14:	e8 02 f0 ff ff       	call   800c1b <sys_getenvid>
  801c19:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801c1f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801c23:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c27:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801c2d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 70 f0 ff ff       	call   800cad <sys_page_map>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	79 32                	jns    801c73 <spawn+0x51f>
  801c41:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  801c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c47:	c7 04 24 40 2c 80 00 	movl   $0x802c40,(%esp)
  801c4e:	e8 69 e6 ff ff       	call   8002bc <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801c53:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c57:	c7 44 24 08 ce 2b 80 	movl   $0x802bce,0x8(%esp)
  801c5e:	00 
  801c5f:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801c66:	00 
  801c67:	c7 04 24 a5 2b 80 00 	movl   $0x802ba5,(%esp)
  801c6e:	e8 51 e5 ff ff       	call   8001c4 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801c73:	46                   	inc    %esi
  801c74:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801c7a:	0f 85 5d ff ff ff    	jne    801bdd <spawn+0x489>
  801c80:	e9 b2 00 00 00       	jmp    801d37 <spawn+0x5e3>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801c85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c89:	c7 44 24 08 e4 2b 80 	movl   $0x802be4,0x8(%esp)
  801c90:	00 
  801c91:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801c98:	00 
  801c99:	c7 04 24 a5 2b 80 00 	movl   $0x802ba5,(%esp)
  801ca0:	e8 1f e5 ff ff       	call   8001c4 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ca5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801cac:	00 
  801cad:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cb3:	89 04 24             	mov    %eax,(%esp)
  801cb6:	e8 98 f0 ff ff       	call   800d53 <sys_env_set_status>
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	79 5a                	jns    801d19 <spawn+0x5c5>
		panic("sys_env_set_status: %e", r);
  801cbf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cc3:	c7 44 24 08 fe 2b 80 	movl   $0x802bfe,0x8(%esp)
  801cca:	00 
  801ccb:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801cd2:	00 
  801cd3:	c7 04 24 a5 2b 80 00 	movl   $0x802ba5,(%esp)
  801cda:	e8 e5 e4 ff ff       	call   8001c4 <_panic>
  801cdf:	89 c6                	mov    %eax,%esi
  801ce1:	eb 06                	jmp    801ce9 <spawn+0x595>
  801ce3:	89 c6                	mov    %eax,%esi
  801ce5:	eb 02                	jmp    801ce9 <spawn+0x595>
  801ce7:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801ce9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801cef:	89 04 24             	mov    %eax,(%esp)
  801cf2:	e8 d2 ee ff ff       	call   800bc9 <sys_env_destroy>
	close(fd);
  801cf7:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801cfd:	89 04 24             	mov    %eax,(%esp)
  801d00:	e8 75 f3 ff ff       	call   80107a <close>
	return r;
  801d05:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801d0b:	eb 0c                	jmp    801d19 <spawn+0x5c5>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d0d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d13:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d19:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d1f:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801d25:	5b                   	pop    %ebx
  801d26:	5e                   	pop    %esi
  801d27:	5f                   	pop    %edi
  801d28:	5d                   	pop    %ebp
  801d29:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d2a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801d2f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801d35:	eb e2                	jmp    801d19 <spawn+0x5c5>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d37:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d41:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d47:	89 04 24             	mov    %eax,(%esp)
  801d4a:	e8 57 f0 ff ff       	call   800da6 <sys_env_set_trapframe>
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	0f 89 4e ff ff ff    	jns    801ca5 <spawn+0x551>
  801d57:	e9 29 ff ff ff       	jmp    801c85 <spawn+0x531>

00801d5c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	57                   	push   %edi
  801d60:	56                   	push   %esi
  801d61:	53                   	push   %ebx
  801d62:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801d65:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801d68:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d6d:	eb 03                	jmp    801d72 <spawnl+0x16>
		argc++;
  801d6f:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801d70:	89 d0                	mov    %edx,%eax
  801d72:	8d 50 04             	lea    0x4(%eax),%edx
  801d75:	83 38 00             	cmpl   $0x0,(%eax)
  801d78:	75 f5                	jne    801d6f <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801d7a:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801d81:	83 e0 f0             	and    $0xfffffff0,%eax
  801d84:	29 c4                	sub    %eax,%esp
  801d86:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801d8a:	83 e7 f0             	and    $0xfffffff0,%edi
  801d8d:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d92:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801d94:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801d9b:	00 

	va_start(vl, arg0);
  801d9c:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	eb 09                	jmp    801daf <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801da6:	40                   	inc    %eax
  801da7:	8b 1a                	mov    (%edx),%ebx
  801da9:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801dac:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801daf:	39 c8                	cmp    %ecx,%eax
  801db1:	75 f3                	jne    801da6 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801db3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	89 04 24             	mov    %eax,(%esp)
  801dbd:	e8 92 f9 ff ff       	call   801754 <spawn>
}
  801dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    
	...

00801dcc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	83 ec 10             	sub    $0x10,%esp
  801dd4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	89 04 24             	mov    %eax,(%esp)
  801ddd:	e8 f2 f0 ff ff       	call   800ed4 <fd2data>
  801de2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801de4:	c7 44 24 04 6b 2c 80 	movl   $0x802c6b,0x4(%esp)
  801deb:	00 
  801dec:	89 34 24             	mov    %esi,(%esp)
  801def:	e8 73 ea ff ff       	call   800867 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801df4:	8b 43 04             	mov    0x4(%ebx),%eax
  801df7:	2b 03                	sub    (%ebx),%eax
  801df9:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801dff:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e06:	00 00 00 
	stat->st_dev = &devpipe;
  801e09:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801e10:	30 80 00 
	return 0;
}
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
  801e18:	83 c4 10             	add    $0x10,%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	53                   	push   %ebx
  801e23:	83 ec 14             	sub    $0x14,%esp
  801e26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e34:	e8 c7 ee ff ff       	call   800d00 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e39:	89 1c 24             	mov    %ebx,(%esp)
  801e3c:	e8 93 f0 ff ff       	call   800ed4 <fd2data>
  801e41:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4c:	e8 af ee ff ff       	call   800d00 <sys_page_unmap>
}
  801e51:	83 c4 14             	add    $0x14,%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	57                   	push   %edi
  801e5b:	56                   	push   %esi
  801e5c:	53                   	push   %ebx
  801e5d:	83 ec 2c             	sub    $0x2c,%esp
  801e60:	89 c7                	mov    %eax,%edi
  801e62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e65:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e6d:	89 3c 24             	mov    %edi,(%esp)
  801e70:	e8 8b 05 00 00       	call   802400 <pageref>
  801e75:	89 c6                	mov    %eax,%esi
  801e77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7a:	89 04 24             	mov    %eax,(%esp)
  801e7d:	e8 7e 05 00 00       	call   802400 <pageref>
  801e82:	39 c6                	cmp    %eax,%esi
  801e84:	0f 94 c0             	sete   %al
  801e87:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e8a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e90:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e93:	39 cb                	cmp    %ecx,%ebx
  801e95:	75 08                	jne    801e9f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e97:	83 c4 2c             	add    $0x2c,%esp
  801e9a:	5b                   	pop    %ebx
  801e9b:	5e                   	pop    %esi
  801e9c:	5f                   	pop    %edi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e9f:	83 f8 01             	cmp    $0x1,%eax
  801ea2:	75 c1                	jne    801e65 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ea4:	8b 42 58             	mov    0x58(%edx),%eax
  801ea7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801eae:	00 
  801eaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb7:	c7 04 24 72 2c 80 00 	movl   $0x802c72,(%esp)
  801ebe:	e8 f9 e3 ff ff       	call   8002bc <cprintf>
  801ec3:	eb a0                	jmp    801e65 <_pipeisclosed+0xe>

00801ec5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	57                   	push   %edi
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 1c             	sub    $0x1c,%esp
  801ece:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ed1:	89 34 24             	mov    %esi,(%esp)
  801ed4:	e8 fb ef ff ff       	call   800ed4 <fd2data>
  801ed9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801edb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ee0:	eb 3c                	jmp    801f1e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ee2:	89 da                	mov    %ebx,%edx
  801ee4:	89 f0                	mov    %esi,%eax
  801ee6:	e8 6c ff ff ff       	call   801e57 <_pipeisclosed>
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	75 38                	jne    801f27 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eef:	e8 46 ed ff ff       	call   800c3a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ef4:	8b 43 04             	mov    0x4(%ebx),%eax
  801ef7:	8b 13                	mov    (%ebx),%edx
  801ef9:	83 c2 20             	add    $0x20,%edx
  801efc:	39 d0                	cmp    %edx,%eax
  801efe:	73 e2                	jae    801ee2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f00:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f03:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f06:	89 c2                	mov    %eax,%edx
  801f08:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f0e:	79 05                	jns    801f15 <devpipe_write+0x50>
  801f10:	4a                   	dec    %edx
  801f11:	83 ca e0             	or     $0xffffffe0,%edx
  801f14:	42                   	inc    %edx
  801f15:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f19:	40                   	inc    %eax
  801f1a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f1d:	47                   	inc    %edi
  801f1e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f21:	75 d1                	jne    801ef4 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f23:	89 f8                	mov    %edi,%eax
  801f25:	eb 05                	jmp    801f2c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f2c:	83 c4 1c             	add    $0x1c,%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5f                   	pop    %edi
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	57                   	push   %edi
  801f38:	56                   	push   %esi
  801f39:	53                   	push   %ebx
  801f3a:	83 ec 1c             	sub    $0x1c,%esp
  801f3d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f40:	89 3c 24             	mov    %edi,(%esp)
  801f43:	e8 8c ef ff ff       	call   800ed4 <fd2data>
  801f48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4a:	be 00 00 00 00       	mov    $0x0,%esi
  801f4f:	eb 3a                	jmp    801f8b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f51:	85 f6                	test   %esi,%esi
  801f53:	74 04                	je     801f59 <devpipe_read+0x25>
				return i;
  801f55:	89 f0                	mov    %esi,%eax
  801f57:	eb 40                	jmp    801f99 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f59:	89 da                	mov    %ebx,%edx
  801f5b:	89 f8                	mov    %edi,%eax
  801f5d:	e8 f5 fe ff ff       	call   801e57 <_pipeisclosed>
  801f62:	85 c0                	test   %eax,%eax
  801f64:	75 2e                	jne    801f94 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f66:	e8 cf ec ff ff       	call   800c3a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f6b:	8b 03                	mov    (%ebx),%eax
  801f6d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f70:	74 df                	je     801f51 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f72:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f77:	79 05                	jns    801f7e <devpipe_read+0x4a>
  801f79:	48                   	dec    %eax
  801f7a:	83 c8 e0             	or     $0xffffffe0,%eax
  801f7d:	40                   	inc    %eax
  801f7e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f85:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f88:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8a:	46                   	inc    %esi
  801f8b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f8e:	75 db                	jne    801f6b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f90:	89 f0                	mov    %esi,%eax
  801f92:	eb 05                	jmp    801f99 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f94:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f99:	83 c4 1c             	add    $0x1c,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	57                   	push   %edi
  801fa5:	56                   	push   %esi
  801fa6:	53                   	push   %ebx
  801fa7:	83 ec 3c             	sub    $0x3c,%esp
  801faa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fb0:	89 04 24             	mov    %eax,(%esp)
  801fb3:	e8 37 ef ff ff       	call   800eef <fd_alloc>
  801fb8:	89 c3                	mov    %eax,%ebx
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	0f 88 45 01 00 00    	js     802107 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fc9:	00 
  801fca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd8:	e8 7c ec ff ff       	call   800c59 <sys_page_alloc>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	0f 88 20 01 00 00    	js     802107 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fe7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 fd ee ff ff       	call   800eef <fd_alloc>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	85 c0                	test   %eax,%eax
  801ff6:	0f 88 f8 00 00 00    	js     8020f4 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffc:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802003:	00 
  802004:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802007:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802012:	e8 42 ec ff ff       	call   800c59 <sys_page_alloc>
  802017:	89 c3                	mov    %eax,%ebx
  802019:	85 c0                	test   %eax,%eax
  80201b:	0f 88 d3 00 00 00    	js     8020f4 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802024:	89 04 24             	mov    %eax,(%esp)
  802027:	e8 a8 ee ff ff       	call   800ed4 <fd2data>
  80202c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802035:	00 
  802036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802041:	e8 13 ec ff ff       	call   800c59 <sys_page_alloc>
  802046:	89 c3                	mov    %eax,%ebx
  802048:	85 c0                	test   %eax,%eax
  80204a:	0f 88 91 00 00 00    	js     8020e1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802050:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802053:	89 04 24             	mov    %eax,(%esp)
  802056:	e8 79 ee ff ff       	call   800ed4 <fd2data>
  80205b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802062:	00 
  802063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80206e:	00 
  80206f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80207a:	e8 2e ec ff ff       	call   800cad <sys_page_map>
  80207f:	89 c3                	mov    %eax,%ebx
  802081:	85 c0                	test   %eax,%eax
  802083:	78 4c                	js     8020d1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802085:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80208b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80208e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802090:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802093:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80209a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020a3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020a8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020b2:	89 04 24             	mov    %eax,(%esp)
  8020b5:	e8 0a ee ff ff       	call   800ec4 <fd2num>
  8020ba:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020bf:	89 04 24             	mov    %eax,(%esp)
  8020c2:	e8 fd ed ff ff       	call   800ec4 <fd2num>
  8020c7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020cf:	eb 36                	jmp    802107 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8020d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020dc:	e8 1f ec ff ff       	call   800d00 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ef:	e8 0c ec ff ff       	call   800d00 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802102:	e8 f9 eb ff ff       	call   800d00 <sys_page_unmap>
    err:
	return r;
}
  802107:	89 d8                	mov    %ebx,%eax
  802109:	83 c4 3c             	add    $0x3c,%esp
  80210c:	5b                   	pop    %ebx
  80210d:	5e                   	pop    %esi
  80210e:	5f                   	pop    %edi
  80210f:	5d                   	pop    %ebp
  802110:	c3                   	ret    

00802111 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802117:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80211e:	8b 45 08             	mov    0x8(%ebp),%eax
  802121:	89 04 24             	mov    %eax,(%esp)
  802124:	e8 19 ee ff ff       	call   800f42 <fd_lookup>
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 15                	js     802142 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80212d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802130:	89 04 24             	mov    %eax,(%esp)
  802133:	e8 9c ed ff ff       	call   800ed4 <fd2data>
	return _pipeisclosed(fd, p);
  802138:	89 c2                	mov    %eax,%edx
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	e8 15 fd ff ff       	call   801e57 <_pipeisclosed>
}
  802142:	c9                   	leave  
  802143:	c3                   	ret    

00802144 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802147:	b8 00 00 00 00       	mov    $0x0,%eax
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802154:	c7 44 24 04 8a 2c 80 	movl   $0x802c8a,0x4(%esp)
  80215b:	00 
  80215c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215f:	89 04 24             	mov    %eax,(%esp)
  802162:	e8 00 e7 ff ff       	call   800867 <strcpy>
	return 0;
}
  802167:	b8 00 00 00 00       	mov    $0x0,%eax
  80216c:	c9                   	leave  
  80216d:	c3                   	ret    

0080216e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216e:	55                   	push   %ebp
  80216f:	89 e5                	mov    %esp,%ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80217a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80217f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802185:	eb 30                	jmp    8021b7 <devcons_write+0x49>
		m = n - tot;
  802187:	8b 75 10             	mov    0x10(%ebp),%esi
  80218a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80218c:	83 fe 7f             	cmp    $0x7f,%esi
  80218f:	76 05                	jbe    802196 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802191:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802196:	89 74 24 08          	mov    %esi,0x8(%esp)
  80219a:	03 45 0c             	add    0xc(%ebp),%eax
  80219d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a1:	89 3c 24             	mov    %edi,(%esp)
  8021a4:	e8 37 e8 ff ff       	call   8009e0 <memmove>
		sys_cputs(buf, m);
  8021a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ad:	89 3c 24             	mov    %edi,(%esp)
  8021b0:	e8 d7 e9 ff ff       	call   800b8c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b5:	01 f3                	add    %esi,%ebx
  8021b7:	89 d8                	mov    %ebx,%eax
  8021b9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021bc:	72 c9                	jb     802187 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021be:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5e                   	pop    %esi
  8021c6:	5f                   	pop    %edi
  8021c7:	5d                   	pop    %ebp
  8021c8:	c3                   	ret    

008021c9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8021cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d3:	75 07                	jne    8021dc <devcons_read+0x13>
  8021d5:	eb 25                	jmp    8021fc <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d7:	e8 5e ea ff ff       	call   800c3a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021dc:	e8 c9 e9 ff ff       	call   800baa <sys_cgetc>
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	74 f2                	je     8021d7 <devcons_read+0xe>
  8021e5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	78 1d                	js     802208 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021eb:	83 f8 04             	cmp    $0x4,%eax
  8021ee:	74 13                	je     802203 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f3:	88 10                	mov    %dl,(%eax)
	return 1;
  8021f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fa:	eb 0c                	jmp    802208 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021fc:	b8 00 00 00 00       	mov    $0x0,%eax
  802201:	eb 05                	jmp    802208 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802203:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802208:	c9                   	leave  
  802209:	c3                   	ret    

0080220a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80220a:	55                   	push   %ebp
  80220b:	89 e5                	mov    %esp,%ebp
  80220d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802210:	8b 45 08             	mov    0x8(%ebp),%eax
  802213:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802216:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80221d:	00 
  80221e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802221:	89 04 24             	mov    %eax,(%esp)
  802224:	e8 63 e9 ff ff       	call   800b8c <sys_cputs>
}
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <getchar>:

int
getchar(void)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802231:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802238:	00 
  802239:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80223c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802247:	e8 92 ef ff ff       	call   8011de <read>
	if (r < 0)
  80224c:	85 c0                	test   %eax,%eax
  80224e:	78 0f                	js     80225f <getchar+0x34>
		return r;
	if (r < 1)
  802250:	85 c0                	test   %eax,%eax
  802252:	7e 06                	jle    80225a <getchar+0x2f>
		return -E_EOF;
	return c;
  802254:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802258:	eb 05                	jmp    80225f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80225a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80225f:	c9                   	leave  
  802260:	c3                   	ret    

00802261 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802261:	55                   	push   %ebp
  802262:	89 e5                	mov    %esp,%ebp
  802264:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802267:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226e:	8b 45 08             	mov    0x8(%ebp),%eax
  802271:	89 04 24             	mov    %eax,(%esp)
  802274:	e8 c9 ec ff ff       	call   800f42 <fd_lookup>
  802279:	85 c0                	test   %eax,%eax
  80227b:	78 11                	js     80228e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80227d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802280:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802286:	39 10                	cmp    %edx,(%eax)
  802288:	0f 94 c0             	sete   %al
  80228b:	0f b6 c0             	movzbl %al,%eax
}
  80228e:	c9                   	leave  
  80228f:	c3                   	ret    

00802290 <opencons>:

int
opencons(void)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802296:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802299:	89 04 24             	mov    %eax,(%esp)
  80229c:	e8 4e ec ff ff       	call   800eef <fd_alloc>
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	78 3c                	js     8022e1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022ac:	00 
  8022ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022bb:	e8 99 e9 ff ff       	call   800c59 <sys_page_alloc>
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	78 1d                	js     8022e1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022c4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022d9:	89 04 24             	mov    %eax,(%esp)
  8022dc:	e8 e3 eb ff ff       	call   800ec4 <fd2num>
}
  8022e1:	c9                   	leave  
  8022e2:	c3                   	ret    
	...

008022e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	56                   	push   %esi
  8022e8:	53                   	push   %ebx
  8022e9:	83 ec 10             	sub    $0x10,%esp
  8022ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8022ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	75 05                	jne    8022fe <ipc_recv+0x1a>
  8022f9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022fe:	89 04 24             	mov    %eax,(%esp)
  802301:	e8 69 eb ff ff       	call   800e6f <sys_ipc_recv>
	if (from_env_store != NULL)
  802306:	85 db                	test   %ebx,%ebx
  802308:	74 0b                	je     802315 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80230a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802310:	8b 52 74             	mov    0x74(%edx),%edx
  802313:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802315:	85 f6                	test   %esi,%esi
  802317:	74 0b                	je     802324 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802319:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80231f:	8b 52 78             	mov    0x78(%edx),%edx
  802322:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802324:	85 c0                	test   %eax,%eax
  802326:	79 16                	jns    80233e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802328:	85 db                	test   %ebx,%ebx
  80232a:	74 06                	je     802332 <ipc_recv+0x4e>
			*from_env_store = 0;
  80232c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802332:	85 f6                	test   %esi,%esi
  802334:	74 10                	je     802346 <ipc_recv+0x62>
			*perm_store = 0;
  802336:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80233c:	eb 08                	jmp    802346 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80233e:	a1 04 40 80 00       	mov    0x804004,%eax
  802343:	8b 40 70             	mov    0x70(%eax),%eax
}
  802346:	83 c4 10             	add    $0x10,%esp
  802349:	5b                   	pop    %ebx
  80234a:	5e                   	pop    %esi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    

0080234d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	57                   	push   %edi
  802351:	56                   	push   %esi
  802352:	53                   	push   %ebx
  802353:	83 ec 1c             	sub    $0x1c,%esp
  802356:	8b 75 08             	mov    0x8(%ebp),%esi
  802359:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80235c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80235f:	eb 2a                	jmp    80238b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802361:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802364:	74 20                	je     802386 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802366:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80236a:	c7 44 24 08 98 2c 80 	movl   $0x802c98,0x8(%esp)
  802371:	00 
  802372:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802379:	00 
  80237a:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  802381:	e8 3e de ff ff       	call   8001c4 <_panic>
		sys_yield();
  802386:	e8 af e8 ff ff       	call   800c3a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80238b:	85 db                	test   %ebx,%ebx
  80238d:	75 07                	jne    802396 <ipc_send+0x49>
  80238f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802394:	eb 02                	jmp    802398 <ipc_send+0x4b>
  802396:	89 d8                	mov    %ebx,%eax
  802398:	8b 55 14             	mov    0x14(%ebp),%edx
  80239b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80239f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023a7:	89 34 24             	mov    %esi,(%esp)
  8023aa:	e8 9d ea ff ff       	call   800e4c <sys_ipc_try_send>
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 ae                	js     802361 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8023b3:	83 c4 1c             	add    $0x1c,%esp
  8023b6:	5b                   	pop    %ebx
  8023b7:	5e                   	pop    %esi
  8023b8:	5f                   	pop    %edi
  8023b9:	5d                   	pop    %ebp
  8023ba:	c3                   	ret    

008023bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023bb:	55                   	push   %ebp
  8023bc:	89 e5                	mov    %esp,%ebp
  8023be:	53                   	push   %ebx
  8023bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8023c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023c7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8023ce:	89 c2                	mov    %eax,%edx
  8023d0:	c1 e2 07             	shl    $0x7,%edx
  8023d3:	29 ca                	sub    %ecx,%edx
  8023d5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023db:	8b 52 50             	mov    0x50(%edx),%edx
  8023de:	39 da                	cmp    %ebx,%edx
  8023e0:	75 0f                	jne    8023f1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8023e2:	c1 e0 07             	shl    $0x7,%eax
  8023e5:	29 c8                	sub    %ecx,%eax
  8023e7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8023ec:	8b 40 40             	mov    0x40(%eax),%eax
  8023ef:	eb 0c                	jmp    8023fd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023f1:	40                   	inc    %eax
  8023f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023f7:	75 ce                	jne    8023c7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023f9:	66 b8 00 00          	mov    $0x0,%ax
}
  8023fd:	5b                   	pop    %ebx
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802406:	89 c2                	mov    %eax,%edx
  802408:	c1 ea 16             	shr    $0x16,%edx
  80240b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802412:	f6 c2 01             	test   $0x1,%dl
  802415:	74 1e                	je     802435 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802417:	c1 e8 0c             	shr    $0xc,%eax
  80241a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802421:	a8 01                	test   $0x1,%al
  802423:	74 17                	je     80243c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802425:	c1 e8 0c             	shr    $0xc,%eax
  802428:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80242f:	ef 
  802430:	0f b7 c0             	movzwl %ax,%eax
  802433:	eb 0c                	jmp    802441 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802435:	b8 00 00 00 00       	mov    $0x0,%eax
  80243a:	eb 05                	jmp    802441 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80243c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    
	...

00802444 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802444:	55                   	push   %ebp
  802445:	57                   	push   %edi
  802446:	56                   	push   %esi
  802447:	83 ec 10             	sub    $0x10,%esp
  80244a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80244e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802452:	89 74 24 04          	mov    %esi,0x4(%esp)
  802456:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80245a:	89 cd                	mov    %ecx,%ebp
  80245c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802460:	85 c0                	test   %eax,%eax
  802462:	75 2c                	jne    802490 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802464:	39 f9                	cmp    %edi,%ecx
  802466:	77 68                	ja     8024d0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802468:	85 c9                	test   %ecx,%ecx
  80246a:	75 0b                	jne    802477 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80246c:	b8 01 00 00 00       	mov    $0x1,%eax
  802471:	31 d2                	xor    %edx,%edx
  802473:	f7 f1                	div    %ecx
  802475:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802477:	31 d2                	xor    %edx,%edx
  802479:	89 f8                	mov    %edi,%eax
  80247b:	f7 f1                	div    %ecx
  80247d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80247f:	89 f0                	mov    %esi,%eax
  802481:	f7 f1                	div    %ecx
  802483:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802485:	89 f0                	mov    %esi,%eax
  802487:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802489:	83 c4 10             	add    $0x10,%esp
  80248c:	5e                   	pop    %esi
  80248d:	5f                   	pop    %edi
  80248e:	5d                   	pop    %ebp
  80248f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802490:	39 f8                	cmp    %edi,%eax
  802492:	77 2c                	ja     8024c0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802494:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802497:	83 f6 1f             	xor    $0x1f,%esi
  80249a:	75 4c                	jne    8024e8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80249c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80249e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024a3:	72 0a                	jb     8024af <__udivdi3+0x6b>
  8024a5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8024a9:	0f 87 ad 00 00 00    	ja     80255c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024af:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024b4:	89 f0                	mov    %esi,%eax
  8024b6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024b8:	83 c4 10             	add    $0x10,%esp
  8024bb:	5e                   	pop    %esi
  8024bc:	5f                   	pop    %edi
  8024bd:	5d                   	pop    %ebp
  8024be:	c3                   	ret    
  8024bf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024c0:	31 ff                	xor    %edi,%edi
  8024c2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024c4:	89 f0                	mov    %esi,%eax
  8024c6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024c8:	83 c4 10             	add    $0x10,%esp
  8024cb:	5e                   	pop    %esi
  8024cc:	5f                   	pop    %edi
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    
  8024cf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024d0:	89 fa                	mov    %edi,%edx
  8024d2:	89 f0                	mov    %esi,%eax
  8024d4:	f7 f1                	div    %ecx
  8024d6:	89 c6                	mov    %eax,%esi
  8024d8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024da:	89 f0                	mov    %esi,%eax
  8024dc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024de:	83 c4 10             	add    $0x10,%esp
  8024e1:	5e                   	pop    %esi
  8024e2:	5f                   	pop    %edi
  8024e3:	5d                   	pop    %ebp
  8024e4:	c3                   	ret    
  8024e5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024e8:	89 f1                	mov    %esi,%ecx
  8024ea:	d3 e0                	shl    %cl,%eax
  8024ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024f0:	b8 20 00 00 00       	mov    $0x20,%eax
  8024f5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8024f7:	89 ea                	mov    %ebp,%edx
  8024f9:	88 c1                	mov    %al,%cl
  8024fb:	d3 ea                	shr    %cl,%edx
  8024fd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802501:	09 ca                	or     %ecx,%edx
  802503:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802507:	89 f1                	mov    %esi,%ecx
  802509:	d3 e5                	shl    %cl,%ebp
  80250b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80250f:	89 fd                	mov    %edi,%ebp
  802511:	88 c1                	mov    %al,%cl
  802513:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802515:	89 fa                	mov    %edi,%edx
  802517:	89 f1                	mov    %esi,%ecx
  802519:	d3 e2                	shl    %cl,%edx
  80251b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80251f:	88 c1                	mov    %al,%cl
  802521:	d3 ef                	shr    %cl,%edi
  802523:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802525:	89 f8                	mov    %edi,%eax
  802527:	89 ea                	mov    %ebp,%edx
  802529:	f7 74 24 08          	divl   0x8(%esp)
  80252d:	89 d1                	mov    %edx,%ecx
  80252f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802531:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802535:	39 d1                	cmp    %edx,%ecx
  802537:	72 17                	jb     802550 <__udivdi3+0x10c>
  802539:	74 09                	je     802544 <__udivdi3+0x100>
  80253b:	89 fe                	mov    %edi,%esi
  80253d:	31 ff                	xor    %edi,%edi
  80253f:	e9 41 ff ff ff       	jmp    802485 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802544:	8b 54 24 04          	mov    0x4(%esp),%edx
  802548:	89 f1                	mov    %esi,%ecx
  80254a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80254c:	39 c2                	cmp    %eax,%edx
  80254e:	73 eb                	jae    80253b <__udivdi3+0xf7>
		{
		  q0--;
  802550:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802553:	31 ff                	xor    %edi,%edi
  802555:	e9 2b ff ff ff       	jmp    802485 <__udivdi3+0x41>
  80255a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80255c:	31 f6                	xor    %esi,%esi
  80255e:	e9 22 ff ff ff       	jmp    802485 <__udivdi3+0x41>
	...

00802564 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802564:	55                   	push   %ebp
  802565:	57                   	push   %edi
  802566:	56                   	push   %esi
  802567:	83 ec 20             	sub    $0x20,%esp
  80256a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80256e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802572:	89 44 24 14          	mov    %eax,0x14(%esp)
  802576:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80257a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802582:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802584:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802586:	85 ed                	test   %ebp,%ebp
  802588:	75 16                	jne    8025a0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80258a:	39 f1                	cmp    %esi,%ecx
  80258c:	0f 86 a6 00 00 00    	jbe    802638 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802592:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802594:	89 d0                	mov    %edx,%eax
  802596:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802598:	83 c4 20             	add    $0x20,%esp
  80259b:	5e                   	pop    %esi
  80259c:	5f                   	pop    %edi
  80259d:	5d                   	pop    %ebp
  80259e:	c3                   	ret    
  80259f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025a0:	39 f5                	cmp    %esi,%ebp
  8025a2:	0f 87 ac 00 00 00    	ja     802654 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025a8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8025ab:	83 f0 1f             	xor    $0x1f,%eax
  8025ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025b2:	0f 84 a8 00 00 00    	je     802660 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025b8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025bc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025be:	bf 20 00 00 00       	mov    $0x20,%edi
  8025c3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025c7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025cb:	89 f9                	mov    %edi,%ecx
  8025cd:	d3 e8                	shr    %cl,%eax
  8025cf:	09 e8                	or     %ebp,%eax
  8025d1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8025d5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025d9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025dd:	d3 e0                	shl    %cl,%eax
  8025df:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8025e7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025eb:	d3 e0                	shl    %cl,%eax
  8025ed:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025f1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8025fb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025fd:	89 f2                	mov    %esi,%edx
  8025ff:	f7 74 24 18          	divl   0x18(%esp)
  802603:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802605:	f7 64 24 0c          	mull   0xc(%esp)
  802609:	89 c5                	mov    %eax,%ebp
  80260b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80260d:	39 d6                	cmp    %edx,%esi
  80260f:	72 67                	jb     802678 <__umoddi3+0x114>
  802611:	74 75                	je     802688 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802613:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802617:	29 e8                	sub    %ebp,%eax
  802619:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80261b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80261f:	d3 e8                	shr    %cl,%eax
  802621:	89 f2                	mov    %esi,%edx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802627:	09 d0                	or     %edx,%eax
  802629:	89 f2                	mov    %esi,%edx
  80262b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80262f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802631:	83 c4 20             	add    $0x20,%esp
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802638:	85 c9                	test   %ecx,%ecx
  80263a:	75 0b                	jne    802647 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80263c:	b8 01 00 00 00       	mov    $0x1,%eax
  802641:	31 d2                	xor    %edx,%edx
  802643:	f7 f1                	div    %ecx
  802645:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802647:	89 f0                	mov    %esi,%eax
  802649:	31 d2                	xor    %edx,%edx
  80264b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80264d:	89 f8                	mov    %edi,%eax
  80264f:	e9 3e ff ff ff       	jmp    802592 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802654:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802656:	83 c4 20             	add    $0x20,%esp
  802659:	5e                   	pop    %esi
  80265a:	5f                   	pop    %edi
  80265b:	5d                   	pop    %ebp
  80265c:	c3                   	ret    
  80265d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802660:	39 f5                	cmp    %esi,%ebp
  802662:	72 04                	jb     802668 <__umoddi3+0x104>
  802664:	39 f9                	cmp    %edi,%ecx
  802666:	77 06                	ja     80266e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802668:	89 f2                	mov    %esi,%edx
  80266a:	29 cf                	sub    %ecx,%edi
  80266c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80266e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802670:	83 c4 20             	add    $0x20,%esp
  802673:	5e                   	pop    %esi
  802674:	5f                   	pop    %edi
  802675:	5d                   	pop    %ebp
  802676:	c3                   	ret    
  802677:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802678:	89 d1                	mov    %edx,%ecx
  80267a:	89 c5                	mov    %eax,%ebp
  80267c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802680:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802684:	eb 8d                	jmp    802613 <__umoddi3+0xaf>
  802686:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802688:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80268c:	72 ea                	jb     802678 <__umoddi3+0x114>
  80268e:	89 f1                	mov    %esi,%ecx
  802690:	eb 81                	jmp    802613 <__umoddi3+0xaf>
