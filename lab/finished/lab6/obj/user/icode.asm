
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
  80003f:	c7 05 00 40 80 00 00 	movl   $0x802c00,0x804000
  800046:	2c 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 06 2c 80 00 	movl   $0x802c06,(%esp)
  800050:	e8 5b 02 00 00       	call   8002b0 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 15 2c 80 00 	movl   $0x802c15,(%esp)
  80005c:	e8 4f 02 00 00       	call   8002b0 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 28 2c 80 00 	movl   $0x802c28,(%esp)
  800070:	e8 b3 16 00 00       	call   801728 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 2e 2c 80 	movl   $0x802c2e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 44 2c 80 00 	movl   $0x802c44,(%esp)
  800096:	e8 1d 01 00 00       	call   8001b8 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 51 2c 80 00 	movl   $0x802c51,(%esp)
  8000a2:	e8 09 02 00 00       	call   8002b0 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 c5 0a 00 00       	call   800b80 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 83 11 00 00       	call   801252 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 64 2c 80 00 	movl   $0x802c64,(%esp)
  8000da:	e8 d1 01 00 00       	call   8002b0 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 07 10 00 00       	call   8010ee <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 78 2c 80 00 	movl   $0x802c78,(%esp)
  8000ee:	e8 bd 01 00 00       	call   8002b0 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 8c 2c 80 	movl   $0x802c8c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 95 2c 80 	movl   $0x802c95,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 9f 2c 80 	movl   $0x802c9f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 9e 2c 80 00 	movl   $0x802c9e,(%esp)
  80011a:	e8 ab 1c 00 00       	call   801dca <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 a4 2c 80 	movl   $0x802ca4,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 44 2c 80 00 	movl   $0x802c44,(%esp)
  80013e:	e8 75 00 00 00       	call   8001b8 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 bb 2c 80 00 	movl   $0x802cbb,(%esp)
  80014a:	e8 61 01 00 00       	call   8002b0 <cprintf>
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
  80016a:	e8 a0 0a 00 00       	call   800c0f <sys_getenvid>
  80016f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800174:	c1 e0 07             	shl    $0x7,%eax
  800177:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80017c:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800181:	85 f6                	test   %esi,%esi
  800183:	7e 07                	jle    80018c <libmain+0x30>
		binaryname = argv[0];
  800185:	8b 03                	mov    (%ebx),%eax
  800187:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80018c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800190:	89 34 24             	mov    %esi,(%esp)
  800193:	e8 9c fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800198:	e8 07 00 00 00       	call   8001a4 <exit>
}
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b1:	e8 07 0a 00 00       	call   800bbd <sys_env_destroy>
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c3:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001c9:	e8 41 0a 00 00       	call   800c0f <sys_getenvid>
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e4:	c7 04 24 d8 2c 80 00 	movl   $0x802cd8,(%esp)
  8001eb:	e8 c0 00 00 00       	call   8002b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f7:	89 04 24             	mov    %eax,(%esp)
  8001fa:	e8 50 00 00 00       	call   80024f <vcprintf>
	cprintf("\n");
  8001ff:	c7 04 24 28 32 80 00 	movl   $0x803228,(%esp)
  800206:	e8 a5 00 00 00       	call   8002b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020b:	cc                   	int3   
  80020c:	eb fd                	jmp    80020b <_panic+0x53>
	...

00800210 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	53                   	push   %ebx
  800214:	83 ec 14             	sub    $0x14,%esp
  800217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80021a:	8b 03                	mov    (%ebx),%eax
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800223:	40                   	inc    %eax
  800224:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800226:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022b:	75 19                	jne    800246 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80022d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800234:	00 
  800235:	8d 43 08             	lea    0x8(%ebx),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 40 09 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  800240:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800246:	ff 43 04             	incl   0x4(%ebx)
}
  800249:	83 c4 14             	add    $0x14,%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800258:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025f:	00 00 00 
	b.cnt = 0;
  800262:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800269:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80026c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 45 08             	mov    0x8(%ebp),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 10 02 80 00 	movl   $0x800210,(%esp)
  80028b:	e8 82 01 00 00       	call   800412 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800290:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800296:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 d8 08 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  8002a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	e8 87 ff ff ff       	call   80024f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c8:	c9                   	leave  
  8002c9:	c3                   	ret    
	...

008002cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 3c             	sub    $0x3c,%esp
  8002d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d8:	89 d7                	mov    %edx,%edi
  8002da:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	75 08                	jne    8002f8 <printnum+0x2c>
  8002f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f6:	77 57                	ja     80034f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002fc:	4b                   	dec    %ebx
  8002fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800301:	8b 45 10             	mov    0x10(%ebp),%eax
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80030c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800310:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800317:	00 
  800318:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800321:	89 44 24 04          	mov    %eax,0x4(%esp)
  800325:	e8 76 26 00 00       	call   8029a0 <__udivdi3>
  80032a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800332:	89 04 24             	mov    %eax,(%esp)
  800335:	89 54 24 04          	mov    %edx,0x4(%esp)
  800339:	89 fa                	mov    %edi,%edx
  80033b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033e:	e8 89 ff ff ff       	call   8002cc <printnum>
  800343:	eb 0f                	jmp    800354 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800345:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800349:	89 34 24             	mov    %esi,(%esp)
  80034c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034f:	4b                   	dec    %ebx
  800350:	85 db                	test   %ebx,%ebx
  800352:	7f f1                	jg     800345 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036a:	00 
  80036b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036e:	89 04 24             	mov    %eax,(%esp)
  800371:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800374:	89 44 24 04          	mov    %eax,0x4(%esp)
  800378:	e8 43 27 00 00       	call   802ac0 <__umoddi3>
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	0f be 80 fb 2c 80 00 	movsbl 0x802cfb(%eax),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038e:	83 c4 3c             	add    $0x3c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800399:	83 fa 01             	cmp    $0x1,%edx
  80039c:	7e 0e                	jle    8003ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	8b 52 04             	mov    0x4(%edx),%edx
  8003aa:	eb 22                	jmp    8003ce <getuint+0x38>
	else if (lflag)
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 10                	je     8003c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	eb 0e                	jmp    8003ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d9:	8b 10                	mov    (%eax),%edx
  8003db:	3b 50 04             	cmp    0x4(%eax),%edx
  8003de:	73 08                	jae    8003e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	88 0a                	mov    %cl,(%edx)
  8003e5:	42                   	inc    %edx
  8003e6:	89 10                	mov    %edx,(%eax)
}
  8003e8:	5d                   	pop    %ebp
  8003e9:	c3                   	ret    

008003ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	e8 02 00 00 00       	call   800412 <vprintfmt>
	va_end(ap);
}
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	57                   	push   %edi
  800416:	56                   	push   %esi
  800417:	53                   	push   %ebx
  800418:	83 ec 4c             	sub    $0x4c,%esp
  80041b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041e:	8b 75 10             	mov    0x10(%ebp),%esi
  800421:	eb 12                	jmp    800435 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800423:	85 c0                	test   %eax,%eax
  800425:	0f 84 6b 03 00 00    	je     800796 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80042b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800435:	0f b6 06             	movzbl (%esi),%eax
  800438:	46                   	inc    %esi
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e5                	jne    800423 <vprintfmt+0x11>
  80043e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800442:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800449:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80044e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800455:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045a:	eb 26                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80045f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800463:	eb 1d                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800468:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80046c:	eb 14                	jmp    800482 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800478:	eb 08                	jmp    800482 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80047a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80047d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	0f b6 06             	movzbl (%esi),%eax
  800485:	8d 56 01             	lea    0x1(%esi),%edx
  800488:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048b:	8a 16                	mov    (%esi),%dl
  80048d:	83 ea 23             	sub    $0x23,%edx
  800490:	80 fa 55             	cmp    $0x55,%dl
  800493:	0f 87 e1 02 00 00    	ja     80077a <vprintfmt+0x368>
  800499:	0f b6 d2             	movzbl %dl,%edx
  80049c:	ff 24 95 40 2e 80 00 	jmp    *0x802e40(,%edx,4)
  8004a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b8:	83 fa 09             	cmp    $0x9,%edx
  8004bb:	77 2a                	ja     8004e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004be:	eb eb                	jmp    8004ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ce:	eb 17                	jmp    8004e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d4:	78 98                	js     80046e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d9:	eb a7                	jmp    800482 <vprintfmt+0x70>
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004e5:	eb 9b                	jmp    800482 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004eb:	79 95                	jns    800482 <vprintfmt+0x70>
  8004ed:	eb 8b                	jmp    80047a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f3:	eb 8d                	jmp    800482 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f8:	8d 50 04             	lea    0x4(%eax),%edx
  8004fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80050d:	e9 23 ff ff ff       	jmp    800435 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 50 04             	lea    0x4(%eax),%edx
  800518:	89 55 14             	mov    %edx,0x14(%ebp)
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	79 02                	jns    800523 <vprintfmt+0x111>
  800521:	f7 d8                	neg    %eax
  800523:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800525:	83 f8 11             	cmp    $0x11,%eax
  800528:	7f 0b                	jg     800535 <vprintfmt+0x123>
  80052a:	8b 04 85 a0 2f 80 00 	mov    0x802fa0(,%eax,4),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	75 23                	jne    800558 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800535:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800539:	c7 44 24 08 13 2d 80 	movl   $0x802d13,0x8(%esp)
  800540:	00 
  800541:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800545:	8b 45 08             	mov    0x8(%ebp),%eax
  800548:	89 04 24             	mov    %eax,(%esp)
  80054b:	e8 9a fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800553:	e9 dd fe ff ff       	jmp    800435 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800558:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80055c:	c7 44 24 08 dd 30 80 	movl   $0x8030dd,0x8(%esp)
  800563:	00 
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	8b 55 08             	mov    0x8(%ebp),%edx
  80056b:	89 14 24             	mov    %edx,(%esp)
  80056e:	e8 77 fe ff ff       	call   8003ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800576:	e9 ba fe ff ff       	jmp    800435 <vprintfmt+0x23>
  80057b:	89 f9                	mov    %edi,%ecx
  80057d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800580:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 30                	mov    (%eax),%esi
  80058e:	85 f6                	test   %esi,%esi
  800590:	75 05                	jne    800597 <vprintfmt+0x185>
				p = "(null)";
  800592:	be 0c 2d 80 00       	mov    $0x802d0c,%esi
			if (width > 0 && padc != '-')
  800597:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059b:	0f 8e 84 00 00 00    	jle    800625 <vprintfmt+0x213>
  8005a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005a5:	74 7e                	je     800625 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ab:	89 34 24             	mov    %esi,(%esp)
  8005ae:	e8 8b 02 00 00       	call   80083e <strnlen>
  8005b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005b6:	29 c2                	sub    %eax,%edx
  8005b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005c5:	89 de                	mov    %ebx,%esi
  8005c7:	89 d3                	mov    %edx,%ebx
  8005c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	eb 0b                	jmp    8005d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d1:	89 3c 24             	mov    %edi,(%esp)
  8005d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d7:	4b                   	dec    %ebx
  8005d8:	85 db                	test   %ebx,%ebx
  8005da:	7f f1                	jg     8005cd <vprintfmt+0x1bb>
  8005dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005df:	89 f3                	mov    %esi,%ebx
  8005e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	79 05                	jns    8005f0 <vprintfmt+0x1de>
  8005eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f8:	eb 2b                	jmp    800625 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fe:	74 18                	je     800618 <vprintfmt+0x206>
  800600:	8d 50 e0             	lea    -0x20(%eax),%edx
  800603:	83 fa 5e             	cmp    $0x5e,%edx
  800606:	76 10                	jbe    800618 <vprintfmt+0x206>
					putch('?', putdat);
  800608:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
  800616:	eb 0a                	jmp    800622 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	ff 4d e4             	decl   -0x1c(%ebp)
  800625:	0f be 06             	movsbl (%esi),%eax
  800628:	46                   	inc    %esi
  800629:	85 c0                	test   %eax,%eax
  80062b:	74 21                	je     80064e <vprintfmt+0x23c>
  80062d:	85 ff                	test   %edi,%edi
  80062f:	78 c9                	js     8005fa <vprintfmt+0x1e8>
  800631:	4f                   	dec    %edi
  800632:	79 c6                	jns    8005fa <vprintfmt+0x1e8>
  800634:	8b 7d 08             	mov    0x8(%ebp),%edi
  800637:	89 de                	mov    %ebx,%esi
  800639:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80063c:	eb 18                	jmp    800656 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800649:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064b:	4b                   	dec    %ebx
  80064c:	eb 08                	jmp    800656 <vprintfmt+0x244>
  80064e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800651:	89 de                	mov    %ebx,%esi
  800653:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800656:	85 db                	test   %ebx,%ebx
  800658:	7f e4                	jg     80063e <vprintfmt+0x22c>
  80065a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80065d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	e9 ce fd ff ff       	jmp    800435 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800667:	83 f9 01             	cmp    $0x1,%ecx
  80066a:	7e 10                	jle    80067c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 08             	lea    0x8(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 30                	mov    (%eax),%esi
  800677:	8b 78 04             	mov    0x4(%eax),%edi
  80067a:	eb 26                	jmp    8006a2 <vprintfmt+0x290>
	else if (lflag)
  80067c:	85 c9                	test   %ecx,%ecx
  80067e:	74 12                	je     800692 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	89 f7                	mov    %esi,%edi
  80068d:	c1 ff 1f             	sar    $0x1f,%edi
  800690:	eb 10                	jmp    8006a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	89 f7                	mov    %esi,%edi
  80069f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	78 0a                	js     8006b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 8c 00 00 00       	jmp    80073c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006be:	f7 de                	neg    %esi
  8006c0:	83 d7 00             	adc    $0x0,%edi
  8006c3:	f7 df                	neg    %edi
			}
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	eb 70                	jmp    80073c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cc:	89 ca                	mov    %ecx,%edx
  8006ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d1:	e8 c0 fc ff ff       	call   800396 <getuint>
  8006d6:	89 c6                	mov    %eax,%esi
  8006d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006df:	eb 5b                	jmp    80073c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 ab fc ff ff       	call   800396 <getuint>
  8006eb:	89 c6                	mov    %eax,%esi
  8006ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8006ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f4:	eb 46                	jmp    80073c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800701:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071b:	8b 30                	mov    (%eax),%esi
  80071d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800727:	eb 13                	jmp    80073c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800729:	89 ca                	mov    %ecx,%edx
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 63 fc ff ff       	call   800396 <getuint>
  800733:	89 c6                	mov    %eax,%esi
  800735:	89 d7                	mov    %edx,%edi
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800740:	89 54 24 10          	mov    %edx,0x10(%esp)
  800744:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800747:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074f:	89 34 24             	mov    %esi,(%esp)
  800752:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800756:	89 da                	mov    %ebx,%edx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	e8 6c fb ff ff       	call   8002cc <printnum>
			break;
  800760:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800763:	e9 cd fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800768:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800772:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800775:	e9 bb fc ff ff       	jmp    800435 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800785:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	eb 01                	jmp    80078b <vprintfmt+0x379>
  80078a:	4e                   	dec    %esi
  80078b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80078f:	75 f9                	jne    80078a <vprintfmt+0x378>
  800791:	e9 9f fc ff ff       	jmp    800435 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800796:	83 c4 4c             	add    $0x4c,%esp
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5f                   	pop    %edi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 28             	sub    $0x28,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 30                	je     8007ef <vsnprintf+0x51>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 33                	jle    8007f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  8007df:	e8 2e fc ff ff       	call   800412 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ed:	eb 0c                	jmp    8007fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f4:	eb 05                	jmp    8007fb <vsnprintf+0x5d>
  8007f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 7b ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    
  800825:	00 00                	add    %al,(%eax)
	...

00800828 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
  800833:	eb 01                	jmp    800836 <strlen+0xe>
		n++;
  800835:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083a:	75 f9                	jne    800835 <strlen+0xd>
		n++;
	return n;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	eb 01                	jmp    80084f <strnlen+0x11>
		n++;
  80084e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	39 d0                	cmp    %edx,%eax
  800851:	74 06                	je     800859 <strnlen+0x1b>
  800853:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800857:	75 f5                	jne    80084e <strnlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	ba 00 00 00 00       	mov    $0x0,%edx
  80086a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80086d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800870:	42                   	inc    %edx
  800871:	84 c9                	test   %cl,%cl
  800873:	75 f5                	jne    80086a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800875:	5b                   	pop    %ebx
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800882:	89 1c 24             	mov    %ebx,(%esp)
  800885:	e8 9e ff ff ff       	call   800828 <strlen>
	strcpy(dst + len, src);
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800891:	01 d8                	add    %ebx,%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 c0 ff ff ff       	call   80085b <strcpy>
	return dst;
}
  80089b:	89 d8                	mov    %ebx,%eax
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b6:	eb 0c                	jmp    8008c4 <strncpy+0x21>
		*dst++ = *src;
  8008b8:	8a 1a                	mov    (%edx),%bl
  8008ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c3:	41                   	inc    %ecx
  8008c4:	39 f1                	cmp    %esi,%ecx
  8008c6:	75 f0                	jne    8008b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	56                   	push   %esi
  8008d0:	53                   	push   %ebx
  8008d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008da:	85 d2                	test   %edx,%edx
  8008dc:	75 0a                	jne    8008e8 <strlcpy+0x1c>
  8008de:	89 f0                	mov    %esi,%eax
  8008e0:	eb 1a                	jmp    8008fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e2:	88 18                	mov    %bl,(%eax)
  8008e4:	40                   	inc    %eax
  8008e5:	41                   	inc    %ecx
  8008e6:	eb 02                	jmp    8008ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008ea:	4a                   	dec    %edx
  8008eb:	74 0a                	je     8008f7 <strlcpy+0x2b>
  8008ed:	8a 19                	mov    (%ecx),%bl
  8008ef:	84 db                	test   %bl,%bl
  8008f1:	75 ef                	jne    8008e2 <strlcpy+0x16>
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 02                	jmp    8008f9 <strlcpy+0x2d>
  8008f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008fc:	29 f0                	sub    %esi,%eax
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090b:	eb 02                	jmp    80090f <strcmp+0xd>
		p++, q++;
  80090d:	41                   	inc    %ecx
  80090e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80090f:	8a 01                	mov    (%ecx),%al
  800911:	84 c0                	test   %al,%al
  800913:	74 04                	je     800919 <strcmp+0x17>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	74 f4                	je     80090d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	0f b6 12             	movzbl (%edx),%edx
  80091f:	29 d0                	sub    %edx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800930:	eb 03                	jmp    800935 <strncmp+0x12>
		n--, p++, q++;
  800932:	4a                   	dec    %edx
  800933:	40                   	inc    %eax
  800934:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800935:	85 d2                	test   %edx,%edx
  800937:	74 14                	je     80094d <strncmp+0x2a>
  800939:	8a 18                	mov    (%eax),%bl
  80093b:	84 db                	test   %bl,%bl
  80093d:	74 04                	je     800943 <strncmp+0x20>
  80093f:	3a 19                	cmp    (%ecx),%bl
  800941:	74 ef                	je     800932 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f b6 11             	movzbl (%ecx),%edx
  800949:	29 d0                	sub    %edx,%eax
  80094b:	eb 05                	jmp    800952 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5b                   	pop    %ebx
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80095e:	eb 05                	jmp    800965 <strchr+0x10>
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 0c                	je     800970 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800964:	40                   	inc    %eax
  800965:	8a 10                	mov    (%eax),%dl
  800967:	84 d2                	test   %dl,%dl
  800969:	75 f5                	jne    800960 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80097b:	eb 05                	jmp    800982 <strfind+0x10>
		if (*s == c)
  80097d:	38 ca                	cmp    %cl,%dl
  80097f:	74 07                	je     800988 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800981:	40                   	inc    %eax
  800982:	8a 10                	mov    (%eax),%dl
  800984:	84 d2                	test   %dl,%dl
  800986:	75 f5                	jne    80097d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 7d 08             	mov    0x8(%ebp),%edi
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
  800996:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800999:	85 c9                	test   %ecx,%ecx
  80099b:	74 30                	je     8009cd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80099d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a3:	75 25                	jne    8009ca <memset+0x40>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 20                	jne    8009ca <memset+0x40>
		c &= 0xFF;
  8009aa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ad:	89 d3                	mov    %edx,%ebx
  8009af:	c1 e3 08             	shl    $0x8,%ebx
  8009b2:	89 d6                	mov    %edx,%esi
  8009b4:	c1 e6 18             	shl    $0x18,%esi
  8009b7:	89 d0                	mov    %edx,%eax
  8009b9:	c1 e0 10             	shl    $0x10,%eax
  8009bc:	09 f0                	or     %esi,%eax
  8009be:	09 d0                	or     %edx,%eax
  8009c0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009c5:	fc                   	cld    
  8009c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c8:	eb 03                	jmp    8009cd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ca:	fc                   	cld    
  8009cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cd:	89 f8                	mov    %edi,%eax
  8009cf:	5b                   	pop    %ebx
  8009d0:	5e                   	pop    %esi
  8009d1:	5f                   	pop    %edi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009e2:	39 c6                	cmp    %eax,%esi
  8009e4:	73 34                	jae    800a1a <memmove+0x46>
  8009e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 2d                	jae    800a1a <memmove+0x46>
		s += n;
		d += n;
  8009ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	f6 c2 03             	test   $0x3,%dl
  8009f3:	75 1b                	jne    800a10 <memmove+0x3c>
  8009f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fb:	75 13                	jne    800a10 <memmove+0x3c>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 0e                	jne    800a10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a02:	83 ef 04             	sub    $0x4,%edi
  800a05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a0b:	fd                   	std    
  800a0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0e:	eb 07                	jmp    800a17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a10:	4f                   	dec    %edi
  800a11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a14:	fd                   	std    
  800a15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a17:	fc                   	cld    
  800a18:	eb 20                	jmp    800a3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a20:	75 13                	jne    800a35 <memmove+0x61>
  800a22:	a8 03                	test   $0x3,%al
  800a24:	75 0f                	jne    800a35 <memmove+0x61>
  800a26:	f6 c1 03             	test   $0x3,%cl
  800a29:	75 0a                	jne    800a35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	fc                   	cld    
  800a31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a33:	eb 05                	jmp    800a3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3a:	5e                   	pop    %esi
  800a3b:	5f                   	pop    %edi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a44:	8b 45 10             	mov    0x10(%ebp),%eax
  800a47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	89 04 24             	mov    %eax,(%esp)
  800a58:	e8 77 ff ff ff       	call   8009d4 <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	eb 16                	jmp    800a8b <memcmp+0x2c>
		if (*s1 != *s2)
  800a75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a78:	42                   	inc    %edx
  800a79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a7d:	38 c8                	cmp    %cl,%al
  800a7f:	74 0a                	je     800a8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 c9             	movzbl %cl,%ecx
  800a87:	29 c8                	sub    %ecx,%eax
  800a89:	eb 09                	jmp    800a94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8b:	39 da                	cmp    %ebx,%edx
  800a8d:	75 e6                	jne    800a75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa2:	89 c2                	mov    %eax,%edx
  800aa4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa7:	eb 05                	jmp    800aae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa9:	38 08                	cmp    %cl,(%eax)
  800aab:	74 05                	je     800ab2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aad:	40                   	inc    %eax
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	72 f7                	jb     800aa9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac0:	eb 01                	jmp    800ac3 <strtol+0xf>
		s++;
  800ac2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac3:	8a 02                	mov    (%edx),%al
  800ac5:	3c 20                	cmp    $0x20,%al
  800ac7:	74 f9                	je     800ac2 <strtol+0xe>
  800ac9:	3c 09                	cmp    $0x9,%al
  800acb:	74 f5                	je     800ac2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800acd:	3c 2b                	cmp    $0x2b,%al
  800acf:	75 08                	jne    800ad9 <strtol+0x25>
		s++;
  800ad1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad7:	eb 13                	jmp    800aec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad9:	3c 2d                	cmp    $0x2d,%al
  800adb:	75 0a                	jne    800ae7 <strtol+0x33>
		s++, neg = 1;
  800add:	8d 52 01             	lea    0x1(%edx),%edx
  800ae0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae5:	eb 05                	jmp    800aec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	74 05                	je     800af5 <strtol+0x41>
  800af0:	83 fb 10             	cmp    $0x10,%ebx
  800af3:	75 28                	jne    800b1d <strtol+0x69>
  800af5:	8a 02                	mov    (%edx),%al
  800af7:	3c 30                	cmp    $0x30,%al
  800af9:	75 10                	jne    800b0b <strtol+0x57>
  800afb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aff:	75 0a                	jne    800b0b <strtol+0x57>
		s += 2, base = 16;
  800b01:	83 c2 02             	add    $0x2,%edx
  800b04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b09:	eb 12                	jmp    800b1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	75 0e                	jne    800b1d <strtol+0x69>
  800b0f:	3c 30                	cmp    $0x30,%al
  800b11:	75 05                	jne    800b18 <strtol+0x64>
		s++, base = 8;
  800b13:	42                   	inc    %edx
  800b14:	b3 08                	mov    $0x8,%bl
  800b16:	eb 05                	jmp    800b1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b24:	8a 0a                	mov    (%edx),%cl
  800b26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b29:	80 fb 09             	cmp    $0x9,%bl
  800b2c:	77 08                	ja     800b36 <strtol+0x82>
			dig = *s - '0';
  800b2e:	0f be c9             	movsbl %cl,%ecx
  800b31:	83 e9 30             	sub    $0x30,%ecx
  800b34:	eb 1e                	jmp    800b54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b39:	80 fb 19             	cmp    $0x19,%bl
  800b3c:	77 08                	ja     800b46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b3e:	0f be c9             	movsbl %cl,%ecx
  800b41:	83 e9 57             	sub    $0x57,%ecx
  800b44:	eb 0e                	jmp    800b54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b49:	80 fb 19             	cmp    $0x19,%bl
  800b4c:	77 12                	ja     800b60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b4e:	0f be c9             	movsbl %cl,%ecx
  800b51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b54:	39 f1                	cmp    %esi,%ecx
  800b56:	7d 0c                	jge    800b64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b58:	42                   	inc    %edx
  800b59:	0f af c6             	imul   %esi,%eax
  800b5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b5e:	eb c4                	jmp    800b24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b60:	89 c1                	mov    %eax,%ecx
  800b62:	eb 02                	jmp    800b66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6a:	74 05                	je     800b71 <strtol+0xbd>
		*endptr = (char *) s;
  800b6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b71:	85 ff                	test   %edi,%edi
  800b73:	74 04                	je     800b79 <strtol+0xc5>
  800b75:	89 c8                	mov    %ecx,%eax
  800b77:	f7 d8                	neg    %eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    
	...

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 c3                	mov    %eax,%ebx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	89 c6                	mov    %eax,%esi
  800b97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	89 cb                	mov    %ecx,%ebx
  800bd5:	89 cf                	mov    %ecx,%edi
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 28                	jle    800c07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bea:	00 
  800beb:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bfa:	00 
  800bfb:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800c02:	e8 b1 f5 ff ff       	call   8001b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c07:	83 c4 2c             	add    $0x2c,%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1f:	89 d1                	mov    %edx,%ecx
  800c21:	89 d3                	mov    %edx,%ebx
  800c23:	89 d7                	mov    %edx,%edi
  800c25:	89 d6                	mov    %edx,%esi
  800c27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_yield>:

void
sys_yield(void)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	ba 00 00 00 00       	mov    $0x0,%edx
  800c39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3e:	89 d1                	mov    %edx,%ecx
  800c40:	89 d3                	mov    %edx,%ebx
  800c42:	89 d7                	mov    %edx,%edi
  800c44:	89 d6                	mov    %edx,%esi
  800c46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	be 00 00 00 00       	mov    $0x0,%esi
  800c5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c66:	8b 55 08             	mov    0x8(%ebp),%edx
  800c69:	89 f7                	mov    %esi,%edi
  800c6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 28                	jle    800c99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800c84:	00 
  800c85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8c:	00 
  800c8d:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800c94:	e8 1f f5 ff ff       	call   8001b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c99:	83 c4 2c             	add    $0x2c,%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	b8 05 00 00 00       	mov    $0x5,%eax
  800caf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 28                	jle    800cec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdf:	00 
  800ce0:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800ce7:	e8 cc f4 ff ff       	call   8001b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cec:	83 c4 2c             	add    $0x2c,%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 06 00 00 00       	mov    $0x6,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 28                	jle    800d3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d22:	00 
  800d23:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d32:	00 
  800d33:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800d3a:	e8 79 f4 ff ff       	call   8001b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d3f:	83 c4 2c             	add    $0x2c,%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d55:	b8 08 00 00 00       	mov    $0x8,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 df                	mov    %ebx,%edi
  800d62:	89 de                	mov    %ebx,%esi
  800d64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	7e 28                	jle    800d92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d75:	00 
  800d76:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d85:	00 
  800d86:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800d8d:	e8 26 f4 ff ff       	call   8001b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d92:	83 c4 2c             	add    $0x2c,%esp
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 09 00 00 00       	mov    $0x9,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800de0:	e8 d3 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	89 df                	mov    %ebx,%edi
  800e08:	89 de                	mov    %ebx,%esi
  800e0a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e0c:	85 c0                	test   %eax,%eax
  800e0e:	7e 28                	jle    800e38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800e33:	e8 80 f3 ff ff       	call   8001b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e38:	83 c4 2c             	add    $0x2c,%esp
  800e3b:	5b                   	pop    %ebx
  800e3c:	5e                   	pop    %esi
  800e3d:	5f                   	pop    %edi
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	be 00 00 00 00       	mov    $0x0,%esi
  800e4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 cb                	mov    %ecx,%ebx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	89 ce                	mov    %ecx,%esi
  800e7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7e 28                	jle    800ead <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e90:	00 
  800e91:	c7 44 24 08 07 30 80 	movl   $0x803007,0x8(%esp)
  800e98:	00 
  800e99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea0:	00 
  800ea1:	c7 04 24 24 30 80 00 	movl   $0x803024,(%esp)
  800ea8:	e8 0b f3 ff ff       	call   8001b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ead:	83 c4 2c             	add    $0x2c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec5:	89 d1                	mov    %edx,%ecx
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	89 d7                	mov    %edx,%edi
  800ecb:	89 d6                	mov    %edx,%esi
  800ecd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edf:	b8 10 00 00 00       	mov    $0x10,%eax
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eea:	89 df                	mov    %ebx,%edi
  800eec:	89 de                	mov    %ebx,%esi
  800eee:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f00:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	89 df                	mov    %ebx,%edi
  800f0d:	89 de                	mov    %ebx,%esi
  800f0f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f21:	b8 11 00 00 00       	mov    $0x11,%eax
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 cb                	mov    %ecx,%ebx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	89 ce                	mov    %ecx,%esi
  800f2f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    
	...

00800f38 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	05 00 00 00 30       	add    $0x30000000,%eax
  800f43:	c1 e8 0c             	shr    $0xc,%eax
}
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f51:	89 04 24             	mov    %eax,(%esp)
  800f54:	e8 df ff ff ff       	call   800f38 <fd2num>
  800f59:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f5e:	c1 e0 0c             	shl    $0xc,%eax
}
  800f61:	c9                   	leave  
  800f62:	c3                   	ret    

00800f63 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	53                   	push   %ebx
  800f67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f6a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f6f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f71:	89 c2                	mov    %eax,%edx
  800f73:	c1 ea 16             	shr    $0x16,%edx
  800f76:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f7d:	f6 c2 01             	test   $0x1,%dl
  800f80:	74 11                	je     800f93 <fd_alloc+0x30>
  800f82:	89 c2                	mov    %eax,%edx
  800f84:	c1 ea 0c             	shr    $0xc,%edx
  800f87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f8e:	f6 c2 01             	test   $0x1,%dl
  800f91:	75 09                	jne    800f9c <fd_alloc+0x39>
			*fd_store = fd;
  800f93:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f95:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9a:	eb 17                	jmp    800fb3 <fd_alloc+0x50>
  800f9c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fa1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fa6:	75 c7                	jne    800f6f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fa8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fb3:	5b                   	pop    %ebx
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    

00800fb6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fbc:	83 f8 1f             	cmp    $0x1f,%eax
  800fbf:	77 36                	ja     800ff7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fc1:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fc6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	c1 ea 16             	shr    $0x16,%edx
  800fce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fd5:	f6 c2 01             	test   $0x1,%dl
  800fd8:	74 24                	je     800ffe <fd_lookup+0x48>
  800fda:	89 c2                	mov    %eax,%edx
  800fdc:	c1 ea 0c             	shr    $0xc,%edx
  800fdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	74 1a                	je     801005 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800feb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fee:	89 02                	mov    %eax,(%edx)
	return 0;
  800ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff5:	eb 13                	jmp    80100a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ff7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ffc:	eb 0c                	jmp    80100a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ffe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801003:	eb 05                	jmp    80100a <fd_lookup+0x54>
  801005:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	53                   	push   %ebx
  801010:	83 ec 14             	sub    $0x14,%esp
  801013:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801016:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801019:	ba 00 00 00 00       	mov    $0x0,%edx
  80101e:	eb 0e                	jmp    80102e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801020:	39 08                	cmp    %ecx,(%eax)
  801022:	75 09                	jne    80102d <dev_lookup+0x21>
			*dev = devtab[i];
  801024:	89 03                	mov    %eax,(%ebx)
			return 0;
  801026:	b8 00 00 00 00       	mov    $0x0,%eax
  80102b:	eb 33                	jmp    801060 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80102d:	42                   	inc    %edx
  80102e:	8b 04 95 b0 30 80 00 	mov    0x8030b0(,%edx,4),%eax
  801035:	85 c0                	test   %eax,%eax
  801037:	75 e7                	jne    801020 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801039:	a1 08 50 80 00       	mov    0x805008,%eax
  80103e:	8b 40 48             	mov    0x48(%eax),%eax
  801041:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801045:	89 44 24 04          	mov    %eax,0x4(%esp)
  801049:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801050:	e8 5b f2 ff ff       	call   8002b0 <cprintf>
	*dev = 0;
  801055:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80105b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801060:	83 c4 14             	add    $0x14,%esp
  801063:	5b                   	pop    %ebx
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	56                   	push   %esi
  80106a:	53                   	push   %ebx
  80106b:	83 ec 30             	sub    $0x30,%esp
  80106e:	8b 75 08             	mov    0x8(%ebp),%esi
  801071:	8a 45 0c             	mov    0xc(%ebp),%al
  801074:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801077:	89 34 24             	mov    %esi,(%esp)
  80107a:	e8 b9 fe ff ff       	call   800f38 <fd2num>
  80107f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801082:	89 54 24 04          	mov    %edx,0x4(%esp)
  801086:	89 04 24             	mov    %eax,(%esp)
  801089:	e8 28 ff ff ff       	call   800fb6 <fd_lookup>
  80108e:	89 c3                	mov    %eax,%ebx
  801090:	85 c0                	test   %eax,%eax
  801092:	78 05                	js     801099 <fd_close+0x33>
	    || fd != fd2)
  801094:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801097:	74 0d                	je     8010a6 <fd_close+0x40>
		return (must_exist ? r : 0);
  801099:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80109d:	75 46                	jne    8010e5 <fd_close+0x7f>
  80109f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010a4:	eb 3f                	jmp    8010e5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ad:	8b 06                	mov    (%esi),%eax
  8010af:	89 04 24             	mov    %eax,(%esp)
  8010b2:	e8 55 ff ff ff       	call   80100c <dev_lookup>
  8010b7:	89 c3                	mov    %eax,%ebx
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 18                	js     8010d5 <fd_close+0x6f>
		if (dev->dev_close)
  8010bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c0:	8b 40 10             	mov    0x10(%eax),%eax
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	74 09                	je     8010d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010c7:	89 34 24             	mov    %esi,(%esp)
  8010ca:	ff d0                	call   *%eax
  8010cc:	89 c3                	mov    %eax,%ebx
  8010ce:	eb 05                	jmp    8010d5 <fd_close+0x6f>
		else
			r = 0;
  8010d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e0:	e8 0f fc ff ff       	call   800cf4 <sys_page_unmap>
	return r;
}
  8010e5:	89 d8                	mov    %ebx,%eax
  8010e7:	83 c4 30             	add    $0x30,%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	89 04 24             	mov    %eax,(%esp)
  801101:	e8 b0 fe ff ff       	call   800fb6 <fd_lookup>
  801106:	85 c0                	test   %eax,%eax
  801108:	78 13                	js     80111d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80110a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801111:	00 
  801112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 49 ff ff ff       	call   801066 <fd_close>
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <close_all>:

void
close_all(void)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	53                   	push   %ebx
  801123:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801126:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80112b:	89 1c 24             	mov    %ebx,(%esp)
  80112e:	e8 bb ff ff ff       	call   8010ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801133:	43                   	inc    %ebx
  801134:	83 fb 20             	cmp    $0x20,%ebx
  801137:	75 f2                	jne    80112b <close_all+0xc>
		close(i);
}
  801139:	83 c4 14             	add    $0x14,%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 4c             	sub    $0x4c,%esp
  801148:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80114b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 59 fe ff ff       	call   800fb6 <fd_lookup>
  80115d:	89 c3                	mov    %eax,%ebx
  80115f:	85 c0                	test   %eax,%eax
  801161:	0f 88 e1 00 00 00    	js     801248 <dup+0x109>
		return r;
	close(newfdnum);
  801167:	89 3c 24             	mov    %edi,(%esp)
  80116a:	e8 7f ff ff ff       	call   8010ee <close>

	newfd = INDEX2FD(newfdnum);
  80116f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801175:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801178:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80117b:	89 04 24             	mov    %eax,(%esp)
  80117e:	e8 c5 fd ff ff       	call   800f48 <fd2data>
  801183:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801185:	89 34 24             	mov    %esi,(%esp)
  801188:	e8 bb fd ff ff       	call   800f48 <fd2data>
  80118d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801190:	89 d8                	mov    %ebx,%eax
  801192:	c1 e8 16             	shr    $0x16,%eax
  801195:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80119c:	a8 01                	test   $0x1,%al
  80119e:	74 46                	je     8011e6 <dup+0xa7>
  8011a0:	89 d8                	mov    %ebx,%eax
  8011a2:	c1 e8 0c             	shr    $0xc,%eax
  8011a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011ac:	f6 c2 01             	test   $0x1,%dl
  8011af:	74 35                	je     8011e6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8011bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cf:	00 
  8011d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011db:	e8 c1 fa ff ff       	call   800ca1 <sys_page_map>
  8011e0:	89 c3                	mov    %eax,%ebx
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 3b                	js     801221 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 0c             	shr    $0xc,%edx
  8011ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801203:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80120a:	00 
  80120b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801216:	e8 86 fa ff ff       	call   800ca1 <sys_page_map>
  80121b:	89 c3                	mov    %eax,%ebx
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 25                	jns    801246 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801221:	89 74 24 04          	mov    %esi,0x4(%esp)
  801225:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122c:	e8 c3 fa ff ff       	call   800cf4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801231:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123f:	e8 b0 fa ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  801244:	eb 02                	jmp    801248 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801246:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801248:	89 d8                	mov    %ebx,%eax
  80124a:	83 c4 4c             	add    $0x4c,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	53                   	push   %ebx
  801256:	83 ec 24             	sub    $0x24,%esp
  801259:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801263:	89 1c 24             	mov    %ebx,(%esp)
  801266:	e8 4b fd ff ff       	call   800fb6 <fd_lookup>
  80126b:	85 c0                	test   %eax,%eax
  80126d:	78 6d                	js     8012dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	8b 00                	mov    (%eax),%eax
  80127b:	89 04 24             	mov    %eax,(%esp)
  80127e:	e8 89 fd ff ff       	call   80100c <dev_lookup>
  801283:	85 c0                	test   %eax,%eax
  801285:	78 55                	js     8012dc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801287:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128a:	8b 50 08             	mov    0x8(%eax),%edx
  80128d:	83 e2 03             	and    $0x3,%edx
  801290:	83 fa 01             	cmp    $0x1,%edx
  801293:	75 23                	jne    8012b8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801295:	a1 08 50 80 00       	mov    0x805008,%eax
  80129a:	8b 40 48             	mov    0x48(%eax),%eax
  80129d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a5:	c7 04 24 75 30 80 00 	movl   $0x803075,(%esp)
  8012ac:	e8 ff ef ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb 24                	jmp    8012dc <read+0x8a>
	}
	if (!dev->dev_read)
  8012b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bb:	8b 52 08             	mov    0x8(%edx),%edx
  8012be:	85 d2                	test   %edx,%edx
  8012c0:	74 15                	je     8012d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	ff d2                	call   *%edx
  8012d5:	eb 05                	jmp    8012dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012dc:	83 c4 24             	add    $0x24,%esp
  8012df:	5b                   	pop    %ebx
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 1c             	sub    $0x1c,%esp
  8012eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f6:	eb 23                	jmp    80131b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012f8:	89 f0                	mov    %esi,%eax
  8012fa:	29 d8                	sub    %ebx,%eax
  8012fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801300:	8b 45 0c             	mov    0xc(%ebp),%eax
  801303:	01 d8                	add    %ebx,%eax
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	89 3c 24             	mov    %edi,(%esp)
  80130c:	e8 41 ff ff ff       	call   801252 <read>
		if (m < 0)
  801311:	85 c0                	test   %eax,%eax
  801313:	78 10                	js     801325 <readn+0x43>
			return m;
		if (m == 0)
  801315:	85 c0                	test   %eax,%eax
  801317:	74 0a                	je     801323 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801319:	01 c3                	add    %eax,%ebx
  80131b:	39 f3                	cmp    %esi,%ebx
  80131d:	72 d9                	jb     8012f8 <readn+0x16>
  80131f:	89 d8                	mov    %ebx,%eax
  801321:	eb 02                	jmp    801325 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801323:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801325:	83 c4 1c             	add    $0x1c,%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	53                   	push   %ebx
  801331:	83 ec 24             	sub    $0x24,%esp
  801334:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133e:	89 1c 24             	mov    %ebx,(%esp)
  801341:	e8 70 fc ff ff       	call   800fb6 <fd_lookup>
  801346:	85 c0                	test   %eax,%eax
  801348:	78 68                	js     8013b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801354:	8b 00                	mov    (%eax),%eax
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	e8 ae fc ff ff       	call   80100c <dev_lookup>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 50                	js     8013b2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801365:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801369:	75 23                	jne    80138e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80136b:	a1 08 50 80 00       	mov    0x805008,%eax
  801370:	8b 40 48             	mov    0x48(%eax),%eax
  801373:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	c7 04 24 91 30 80 00 	movl   $0x803091,(%esp)
  801382:	e8 29 ef ff ff       	call   8002b0 <cprintf>
		return -E_INVAL;
  801387:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138c:	eb 24                	jmp    8013b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80138e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801391:	8b 52 0c             	mov    0xc(%edx),%edx
  801394:	85 d2                	test   %edx,%edx
  801396:	74 15                	je     8013ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801398:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80139b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013a6:	89 04 24             	mov    %eax,(%esp)
  8013a9:	ff d2                	call   *%edx
  8013ab:	eb 05                	jmp    8013b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013b2:	83 c4 24             	add    $0x24,%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b8:	55                   	push   %ebp
  8013b9:	89 e5                	mov    %esp,%ebp
  8013bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 e6 fb ff ff       	call   800fb6 <fd_lookup>
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 0e                	js     8013e2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 24             	sub    $0x24,%esp
  8013eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f5:	89 1c 24             	mov    %ebx,(%esp)
  8013f8:	e8 b9 fb ff ff       	call   800fb6 <fd_lookup>
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 61                	js     801462 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801401:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140b:	8b 00                	mov    (%eax),%eax
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	e8 f7 fb ff ff       	call   80100c <dev_lookup>
  801415:	85 c0                	test   %eax,%eax
  801417:	78 49                	js     801462 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801420:	75 23                	jne    801445 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801422:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801427:	8b 40 48             	mov    0x48(%eax),%eax
  80142a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80142e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801432:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801439:	e8 72 ee ff ff       	call   8002b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80143e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801443:	eb 1d                	jmp    801462 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801445:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801448:	8b 52 18             	mov    0x18(%edx),%edx
  80144b:	85 d2                	test   %edx,%edx
  80144d:	74 0e                	je     80145d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80144f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801452:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	ff d2                	call   *%edx
  80145b:	eb 05                	jmp    801462 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80145d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801462:	83 c4 24             	add    $0x24,%esp
  801465:	5b                   	pop    %ebx
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	53                   	push   %ebx
  80146c:	83 ec 24             	sub    $0x24,%esp
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801472:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	89 04 24             	mov    %eax,(%esp)
  80147f:	e8 32 fb ff ff       	call   800fb6 <fd_lookup>
  801484:	85 c0                	test   %eax,%eax
  801486:	78 52                	js     8014da <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	8b 00                	mov    (%eax),%eax
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	e8 70 fb ff ff       	call   80100c <dev_lookup>
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 3a                	js     8014da <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014a7:	74 2c                	je     8014d5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014b3:	00 00 00 
	stat->st_isdir = 0;
  8014b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014bd:	00 00 00 
	stat->st_dev = dev;
  8014c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014cd:	89 14 24             	mov    %edx,(%esp)
  8014d0:	ff 50 14             	call   *0x14(%eax)
  8014d3:	eb 05                	jmp    8014da <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014da:	83 c4 24             	add    $0x24,%esp
  8014dd:	5b                   	pop    %ebx
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ef:	00 
  8014f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 2d 02 00 00       	call   801728 <open>
  8014fb:	89 c3                	mov    %eax,%ebx
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 1b                	js     80151c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	89 1c 24             	mov    %ebx,(%esp)
  80150b:	e8 58 ff ff ff       	call   801468 <fstat>
  801510:	89 c6                	mov    %eax,%esi
	close(fd);
  801512:	89 1c 24             	mov    %ebx,(%esp)
  801515:	e8 d4 fb ff ff       	call   8010ee <close>
	return r;
  80151a:	89 f3                	mov    %esi,%ebx
}
  80151c:	89 d8                	mov    %ebx,%eax
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	5b                   	pop    %ebx
  801522:	5e                   	pop    %esi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    
  801525:	00 00                	add    %al,(%eax)
	...

00801528 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	56                   	push   %esi
  80152c:	53                   	push   %ebx
  80152d:	83 ec 10             	sub    $0x10,%esp
  801530:	89 c3                	mov    %eax,%ebx
  801532:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801534:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80153b:	75 11                	jne    80154e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80153d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801544:	e8 da 13 00 00       	call   802923 <ipc_find_env>
  801549:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80154e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801555:	00 
  801556:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80155d:	00 
  80155e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801562:	a1 00 50 80 00       	mov    0x805000,%eax
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	e8 46 13 00 00       	call   8028b5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80156f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801576:	00 
  801577:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801582:	e8 c5 12 00 00       	call   80284c <ipc_recv>
}
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	5b                   	pop    %ebx
  80158b:	5e                   	pop    %esi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801594:	8b 45 08             	mov    0x8(%ebp),%eax
  801597:	8b 40 0c             	mov    0xc(%eax),%eax
  80159a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80159f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8015b1:	e8 72 ff ff ff       	call   801528 <fsipc>
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015be:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015c4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8015d3:	e8 50 ff ff ff       	call   801528 <fsipc>
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 14             	sub    $0x14,%esp
  8015e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ea:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8015f9:	e8 2a ff ff ff       	call   801528 <fsipc>
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 2b                	js     80162d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801602:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801609:	00 
  80160a:	89 1c 24             	mov    %ebx,(%esp)
  80160d:	e8 49 f2 ff ff       	call   80085b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801612:	a1 80 60 80 00       	mov    0x806080,%eax
  801617:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80161d:	a1 84 60 80 00       	mov    0x806084,%eax
  801622:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801628:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162d:	83 c4 14             	add    $0x14,%esp
  801630:	5b                   	pop    %ebx
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 18             	sub    $0x18,%esp
  801639:	8b 55 10             	mov    0x10(%ebp),%edx
  80163c:	89 d0                	mov    %edx,%eax
  80163e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801644:	76 05                	jbe    80164b <devfile_write+0x18>
  801646:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80164b:	8b 55 08             	mov    0x8(%ebp),%edx
  80164e:	8b 52 0c             	mov    0xc(%edx),%edx
  801651:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801657:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80165c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801660:	8b 45 0c             	mov    0xc(%ebp),%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80166e:	e8 61 f3 ff ff       	call   8009d4 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801673:	ba 00 00 00 00       	mov    $0x0,%edx
  801678:	b8 04 00 00 00       	mov    $0x4,%eax
  80167d:	e8 a6 fe ff ff       	call   801528 <fsipc>
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	83 ec 10             	sub    $0x10,%esp
  80168c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	8b 40 0c             	mov    0xc(%eax),%eax
  801695:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80169a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	b8 03 00 00 00       	mov    $0x3,%eax
  8016aa:	e8 79 fe ff ff       	call   801528 <fsipc>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 6a                	js     80171f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016b5:	39 c6                	cmp    %eax,%esi
  8016b7:	73 24                	jae    8016dd <devfile_read+0x59>
  8016b9:	c7 44 24 0c c4 30 80 	movl   $0x8030c4,0xc(%esp)
  8016c0:	00 
  8016c1:	c7 44 24 08 cb 30 80 	movl   $0x8030cb,0x8(%esp)
  8016c8:	00 
  8016c9:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016d0:	00 
  8016d1:	c7 04 24 e0 30 80 00 	movl   $0x8030e0,(%esp)
  8016d8:	e8 db ea ff ff       	call   8001b8 <_panic>
	assert(r <= PGSIZE);
  8016dd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016e2:	7e 24                	jle    801708 <devfile_read+0x84>
  8016e4:	c7 44 24 0c eb 30 80 	movl   $0x8030eb,0xc(%esp)
  8016eb:	00 
  8016ec:	c7 44 24 08 cb 30 80 	movl   $0x8030cb,0x8(%esp)
  8016f3:	00 
  8016f4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8016fb:	00 
  8016fc:	c7 04 24 e0 30 80 00 	movl   $0x8030e0,(%esp)
  801703:	e8 b0 ea ff ff       	call   8001b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801708:	89 44 24 08          	mov    %eax,0x8(%esp)
  80170c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801713:	00 
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
  801717:	89 04 24             	mov    %eax,(%esp)
  80171a:	e8 b5 f2 ff ff       	call   8009d4 <memmove>
	return r;
}
  80171f:	89 d8                	mov    %ebx,%eax
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	5b                   	pop    %ebx
  801725:	5e                   	pop    %esi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 20             	sub    $0x20,%esp
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801733:	89 34 24             	mov    %esi,(%esp)
  801736:	e8 ed f0 ff ff       	call   800828 <strlen>
  80173b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801740:	7f 60                	jg     8017a2 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801742:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 16 f8 ff ff       	call   800f63 <fd_alloc>
  80174d:	89 c3                	mov    %eax,%ebx
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 54                	js     8017a7 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801753:	89 74 24 04          	mov    %esi,0x4(%esp)
  801757:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80175e:	e8 f8 f0 ff ff       	call   80085b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801763:	8b 45 0c             	mov    0xc(%ebp),%eax
  801766:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80176b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176e:	b8 01 00 00 00       	mov    $0x1,%eax
  801773:	e8 b0 fd ff ff       	call   801528 <fsipc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	85 c0                	test   %eax,%eax
  80177c:	79 15                	jns    801793 <open+0x6b>
		fd_close(fd, 0);
  80177e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801785:	00 
  801786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801789:	89 04 24             	mov    %eax,(%esp)
  80178c:	e8 d5 f8 ff ff       	call   801066 <fd_close>
		return r;
  801791:	eb 14                	jmp    8017a7 <open+0x7f>
	}

	return fd2num(fd);
  801793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 9a f7 ff ff       	call   800f38 <fd2num>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	eb 05                	jmp    8017a7 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017a2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017a7:	89 d8                	mov    %ebx,%eax
  8017a9:	83 c4 20             	add    $0x20,%esp
  8017ac:	5b                   	pop    %ebx
  8017ad:	5e                   	pop    %esi
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8017c0:	e8 63 fd ff ff       	call   801528 <fsipc>
}
  8017c5:	c9                   	leave  
  8017c6:	c3                   	ret    
	...

008017c8 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	57                   	push   %edi
  8017cc:	56                   	push   %esi
  8017cd:	53                   	push   %ebx
  8017ce:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8017d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017db:	00 
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 41 ff ff ff       	call   801728 <open>
  8017e7:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	0f 88 86 05 00 00    	js     801d7b <spawn+0x5b3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8017f5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8017fc:	00 
  8017fd:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801803:	89 44 24 04          	mov    %eax,0x4(%esp)
  801807:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 cd fa ff ff       	call   8012e2 <readn>
  801815:	3d 00 02 00 00       	cmp    $0x200,%eax
  80181a:	75 0c                	jne    801828 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  80181c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801823:	45 4c 46 
  801826:	74 3b                	je     801863 <spawn+0x9b>
		close(fd);
  801828:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80182e:	89 04 24             	mov    %eax,(%esp)
  801831:	e8 b8 f8 ff ff       	call   8010ee <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801836:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  80183d:	46 
  80183e:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801844:	89 44 24 04          	mov    %eax,0x4(%esp)
  801848:	c7 04 24 f7 30 80 00 	movl   $0x8030f7,(%esp)
  80184f:	e8 5c ea ff ff       	call   8002b0 <cprintf>
		return -E_NOT_EXEC;
  801854:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  80185b:	ff ff ff 
  80185e:	e9 24 05 00 00       	jmp    801d87 <spawn+0x5bf>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801863:	ba 07 00 00 00       	mov    $0x7,%edx
  801868:	89 d0                	mov    %edx,%eax
  80186a:	cd 30                	int    $0x30
  80186c:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801872:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801878:	85 c0                	test   %eax,%eax
  80187a:	0f 88 07 05 00 00    	js     801d87 <spawn+0x5bf>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801880:	89 c6                	mov    %eax,%esi
  801882:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801888:	c1 e6 07             	shl    $0x7,%esi
  80188b:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801891:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801897:	b9 11 00 00 00       	mov    $0x11,%ecx
  80189c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80189e:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8018a4:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018aa:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8018af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8018b7:	eb 0d                	jmp    8018c6 <spawn+0xfe>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8018b9:	89 04 24             	mov    %eax,(%esp)
  8018bc:	e8 67 ef ff ff       	call   800828 <strlen>
  8018c1:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018c5:	46                   	inc    %esi
  8018c6:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8018c8:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8018cf:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	75 e3                	jne    8018b9 <spawn+0xf1>
  8018d6:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8018dc:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8018e2:	bf 00 10 40 00       	mov    $0x401000,%edi
  8018e7:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8018e9:	89 f8                	mov    %edi,%eax
  8018eb:	83 e0 fc             	and    $0xfffffffc,%eax
  8018ee:	f7 d2                	not    %edx
  8018f0:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8018f3:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8018f9:	89 d0                	mov    %edx,%eax
  8018fb:	83 e8 08             	sub    $0x8,%eax
  8018fe:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801903:	0f 86 8f 04 00 00    	jbe    801d98 <spawn+0x5d0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801909:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801910:	00 
  801911:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801918:	00 
  801919:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801920:	e8 28 f3 ff ff       	call   800c4d <sys_page_alloc>
  801925:	85 c0                	test   %eax,%eax
  801927:	0f 88 70 04 00 00    	js     801d9d <spawn+0x5d5>
  80192d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801932:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801938:	8b 75 0c             	mov    0xc(%ebp),%esi
  80193b:	eb 2e                	jmp    80196b <spawn+0x1a3>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80193d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801943:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801949:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80194c:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80194f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801953:	89 3c 24             	mov    %edi,(%esp)
  801956:	e8 00 ef ff ff       	call   80085b <strcpy>
		string_store += strlen(argv[i]) + 1;
  80195b:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 c2 ee ff ff       	call   800828 <strlen>
  801966:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80196a:	43                   	inc    %ebx
  80196b:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801971:	7c ca                	jl     80193d <spawn+0x175>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801973:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801979:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  80197f:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801986:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80198c:	74 24                	je     8019b2 <spawn+0x1ea>
  80198e:	c7 44 24 0c 84 31 80 	movl   $0x803184,0xc(%esp)
  801995:	00 
  801996:	c7 44 24 08 cb 30 80 	movl   $0x8030cb,0x8(%esp)
  80199d:	00 
  80199e:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  8019a5:	00 
  8019a6:	c7 04 24 11 31 80 00 	movl   $0x803111,(%esp)
  8019ad:	e8 06 e8 ff ff       	call   8001b8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019b2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8019b8:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8019bd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8019c3:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8019c6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8019cc:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019cf:	89 d0                	mov    %edx,%eax
  8019d1:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8019d6:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8019dc:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019e3:	00 
  8019e4:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8019eb:	ee 
  8019ec:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8019f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019fd:	00 
  8019fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a05:	e8 97 f2 ff ff       	call   800ca1 <sys_page_map>
  801a0a:	89 c3                	mov    %eax,%ebx
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 1a                	js     801a2a <spawn+0x262>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a10:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a17:	00 
  801a18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a1f:	e8 d0 f2 ff ff       	call   800cf4 <sys_page_unmap>
  801a24:	89 c3                	mov    %eax,%ebx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	79 1f                	jns    801a49 <spawn+0x281>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801a2a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a31:	00 
  801a32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a39:	e8 b6 f2 ff ff       	call   800cf4 <sys_page_unmap>
	return r;
  801a3e:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a44:	e9 3e 03 00 00       	jmp    801d87 <spawn+0x5bf>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801a49:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801a4f:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801a55:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a5b:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801a62:	00 00 00 
  801a65:	e9 bb 01 00 00       	jmp    801c25 <spawn+0x45d>
		if (ph->p_type != ELF_PROG_LOAD)
  801a6a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801a70:	83 38 01             	cmpl   $0x1,(%eax)
  801a73:	0f 85 9f 01 00 00    	jne    801c18 <spawn+0x450>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a79:	89 c2                	mov    %eax,%edx
  801a7b:	8b 40 18             	mov    0x18(%eax),%eax
  801a7e:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801a81:	83 f8 01             	cmp    $0x1,%eax
  801a84:	19 c0                	sbb    %eax,%eax
  801a86:	83 e0 fe             	and    $0xfffffffe,%eax
  801a89:	83 c0 07             	add    $0x7,%eax
  801a8c:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801a92:	8b 52 04             	mov    0x4(%edx),%edx
  801a95:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801a9b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801aa1:	8b 40 10             	mov    0x10(%eax),%eax
  801aa4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801aaa:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801ab0:	8b 52 14             	mov    0x14(%edx),%edx
  801ab3:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801ab9:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801abf:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801ac2:	89 f8                	mov    %edi,%eax
  801ac4:	25 ff 0f 00 00       	and    $0xfff,%eax
  801ac9:	74 16                	je     801ae1 <spawn+0x319>
		va -= i;
  801acb:	29 c7                	sub    %eax,%edi
		memsz += i;
  801acd:	01 c2                	add    %eax,%edx
  801acf:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801ad5:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801adb:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ae1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae6:	e9 1f 01 00 00       	jmp    801c0a <spawn+0x442>
		if (i >= filesz) {
  801aeb:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801af1:	77 2b                	ja     801b1e <spawn+0x356>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801af3:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801af9:	89 54 24 08          	mov    %edx,0x8(%esp)
  801afd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b01:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 3e f1 ff ff       	call   800c4d <sys_page_alloc>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	0f 89 e7 00 00 00    	jns    801bfe <spawn+0x436>
  801b17:	89 c6                	mov    %eax,%esi
  801b19:	e9 39 02 00 00       	jmp    801d57 <spawn+0x58f>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b1e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b25:	00 
  801b26:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b2d:	00 
  801b2e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b35:	e8 13 f1 ff ff       	call   800c4d <sys_page_alloc>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	0f 88 0b 02 00 00    	js     801d4d <spawn+0x585>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b42:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801b48:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 5c f8 ff ff       	call   8013b8 <seek>
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	0f 88 ed 01 00 00    	js     801d51 <spawn+0x589>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801b64:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b6a:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b6c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b71:	76 05                	jbe    801b78 <spawn+0x3b0>
  801b73:	b8 00 10 00 00       	mov    $0x1000,%eax
  801b78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801b83:	00 
  801b84:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801b8a:	89 04 24             	mov    %eax,(%esp)
  801b8d:	e8 50 f7 ff ff       	call   8012e2 <readn>
  801b92:	85 c0                	test   %eax,%eax
  801b94:	0f 88 bb 01 00 00    	js     801d55 <spawn+0x58d>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801b9a:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801ba0:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ba8:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bae:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bb9:	00 
  801bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc1:	e8 db f0 ff ff       	call   800ca1 <sys_page_map>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	79 20                	jns    801bea <spawn+0x422>
				panic("spawn: sys_page_map data: %e", r);
  801bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bce:	c7 44 24 08 1d 31 80 	movl   $0x80311d,0x8(%esp)
  801bd5:	00 
  801bd6:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801bdd:	00 
  801bde:	c7 04 24 11 31 80 00 	movl   $0x803111,(%esp)
  801be5:	e8 ce e5 ff ff       	call   8001b8 <_panic>
			sys_page_unmap(0, UTEMP);
  801bea:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bf1:	00 
  801bf2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf9:	e8 f6 f0 ff ff       	call   800cf4 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bfe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c04:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801c0a:	89 de                	mov    %ebx,%esi
  801c0c:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801c12:	0f 82 d3 fe ff ff    	jb     801aeb <spawn+0x323>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c18:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801c1e:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801c25:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c2c:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801c32:	0f 8c 32 fe ff ff    	jl     801a6a <spawn+0x2a2>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c38:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 a8 f4 ff ff       	call   8010ee <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801c46:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  801c4b:	89 f0                	mov    %esi,%eax
  801c4d:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  801c50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c57:	a8 01                	test   $0x1,%al
  801c59:	0f 84 82 00 00 00    	je     801ce1 <spawn+0x519>
  801c5f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801c66:	a8 01                	test   $0x1,%al
  801c68:	74 77                	je     801ce1 <spawn+0x519>
  801c6a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801c71:	f6 c4 04             	test   $0x4,%ah
  801c74:	74 6b                	je     801ce1 <spawn+0x519>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801c76:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801c7d:	89 f3                	mov    %esi,%ebx
  801c7f:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  801c82:	e8 88 ef ff ff       	call   800c0f <sys_getenvid>
  801c87:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801c8d:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801c91:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c95:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca3:	89 04 24             	mov    %eax,(%esp)
  801ca6:	e8 f6 ef ff ff       	call   800ca1 <sys_page_map>
  801cab:	85 c0                	test   %eax,%eax
  801cad:	79 32                	jns    801ce1 <spawn+0x519>
  801caf:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  801cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb5:	c7 04 24 ac 31 80 00 	movl   $0x8031ac,(%esp)
  801cbc:	e8 ef e5 ff ff       	call   8002b0 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801cc1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cc5:	c7 44 24 08 3a 31 80 	movl   $0x80313a,0x8(%esp)
  801ccc:	00 
  801ccd:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801cd4:	00 
  801cd5:	c7 04 24 11 31 80 00 	movl   $0x803111,(%esp)
  801cdc:	e8 d7 e4 ff ff       	call   8001b8 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801ce1:	46                   	inc    %esi
  801ce2:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801ce8:	0f 85 5d ff ff ff    	jne    801c4b <spawn+0x483>
  801cee:	e9 b2 00 00 00       	jmp    801da5 <spawn+0x5dd>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801cf3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cf7:	c7 44 24 08 50 31 80 	movl   $0x803150,0x8(%esp)
  801cfe:	00 
  801cff:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801d06:	00 
  801d07:	c7 04 24 11 31 80 00 	movl   $0x803111,(%esp)
  801d0e:	e8 a5 e4 ff ff       	call   8001b8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d13:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801d1a:	00 
  801d1b:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 1e f0 ff ff       	call   800d47 <sys_env_set_status>
  801d29:	85 c0                	test   %eax,%eax
  801d2b:	79 5a                	jns    801d87 <spawn+0x5bf>
		panic("sys_env_set_status: %e", r);
  801d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d31:	c7 44 24 08 6a 31 80 	movl   $0x80316a,0x8(%esp)
  801d38:	00 
  801d39:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  801d40:	00 
  801d41:	c7 04 24 11 31 80 00 	movl   $0x803111,(%esp)
  801d48:	e8 6b e4 ff ff       	call   8001b8 <_panic>
  801d4d:	89 c6                	mov    %eax,%esi
  801d4f:	eb 06                	jmp    801d57 <spawn+0x58f>
  801d51:	89 c6                	mov    %eax,%esi
  801d53:	eb 02                	jmp    801d57 <spawn+0x58f>
  801d55:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801d57:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d5d:	89 04 24             	mov    %eax,(%esp)
  801d60:	e8 58 ee ff ff       	call   800bbd <sys_env_destroy>
	close(fd);
  801d65:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d6b:	89 04 24             	mov    %eax,(%esp)
  801d6e:	e8 7b f3 ff ff       	call   8010ee <close>
	return r;
  801d73:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801d79:	eb 0c                	jmp    801d87 <spawn+0x5bf>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d7b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d81:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801d87:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801d8d:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d98:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801d9d:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801da3:	eb e2                	jmp    801d87 <spawn+0x5bf>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801da5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801dab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801daf:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801db5:	89 04 24             	mov    %eax,(%esp)
  801db8:	e8 dd ef ff ff       	call   800d9a <sys_env_set_trapframe>
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	0f 89 4e ff ff ff    	jns    801d13 <spawn+0x54b>
  801dc5:	e9 29 ff ff ff       	jmp    801cf3 <spawn+0x52b>

00801dca <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	57                   	push   %edi
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801dd3:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ddb:	eb 03                	jmp    801de0 <spawnl+0x16>
		argc++;
  801ddd:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dde:	89 d0                	mov    %edx,%eax
  801de0:	8d 50 04             	lea    0x4(%eax),%edx
  801de3:	83 38 00             	cmpl   $0x0,(%eax)
  801de6:	75 f5                	jne    801ddd <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801de8:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801def:	83 e0 f0             	and    $0xfffffff0,%eax
  801df2:	29 c4                	sub    %eax,%esp
  801df4:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801df8:	83 e7 f0             	and    $0xfffffff0,%edi
  801dfb:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e00:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801e02:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801e09:	00 

	va_start(vl, arg0);
  801e0a:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801e0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e12:	eb 09                	jmp    801e1d <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801e14:	40                   	inc    %eax
  801e15:	8b 1a                	mov    (%edx),%ebx
  801e17:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801e1a:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e1d:	39 c8                	cmp    %ecx,%eax
  801e1f:	75 f3                	jne    801e14 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e21:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e25:	8b 45 08             	mov    0x8(%ebp),%eax
  801e28:	89 04 24             	mov    %eax,(%esp)
  801e2b:	e8 98 f9 ff ff       	call   8017c8 <spawn>
}
  801e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e3e:	c7 44 24 04 d7 31 80 	movl   $0x8031d7,0x4(%esp)
  801e45:	00 
  801e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e49:	89 04 24             	mov    %eax,(%esp)
  801e4c:	e8 0a ea ff ff       	call   80085b <strcpy>
	return 0;
}
  801e51:	b8 00 00 00 00       	mov    $0x0,%eax
  801e56:	c9                   	leave  
  801e57:	c3                   	ret    

00801e58 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	53                   	push   %ebx
  801e5c:	83 ec 14             	sub    $0x14,%esp
  801e5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e62:	89 1c 24             	mov    %ebx,(%esp)
  801e65:	e8 f2 0a 00 00       	call   80295c <pageref>
  801e6a:	83 f8 01             	cmp    $0x1,%eax
  801e6d:	75 0d                	jne    801e7c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801e6f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e72:	89 04 24             	mov    %eax,(%esp)
  801e75:	e8 1f 03 00 00       	call   802199 <nsipc_close>
  801e7a:	eb 05                	jmp    801e81 <devsock_close+0x29>
	else
		return 0;
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e81:	83 c4 14             	add    $0x14,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e8d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e94:	00 
  801e95:	8b 45 10             	mov    0x10(%ebp),%eax
  801e98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ea9:	89 04 24             	mov    %eax,(%esp)
  801eac:	e8 e3 03 00 00       	call   802294 <nsipc_send>
}
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801eb9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ec0:	00 
  801ec1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed5:	89 04 24             	mov    %eax,(%esp)
  801ed8:	e8 37 03 00 00       	call   802214 <nsipc_recv>
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 20             	sub    $0x20,%esp
  801ee7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ee9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eec:	89 04 24             	mov    %eax,(%esp)
  801eef:	e8 6f f0 ff ff       	call   800f63 <fd_alloc>
  801ef4:	89 c3                	mov    %eax,%ebx
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 21                	js     801f1b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801efa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f01:	00 
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 38 ed ff ff       	call   800c4d <sys_page_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	79 0a                	jns    801f25 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801f1b:	89 34 24             	mov    %esi,(%esp)
  801f1e:	e8 76 02 00 00       	call   802199 <nsipc_close>
		return r;
  801f23:	eb 22                	jmp    801f47 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f25:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f33:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f3a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f3d:	89 04 24             	mov    %eax,(%esp)
  801f40:	e8 f3 ef ff ff       	call   800f38 <fd2num>
  801f45:	89 c3                	mov    %eax,%ebx
}
  801f47:	89 d8                	mov    %ebx,%eax
  801f49:	83 c4 20             	add    $0x20,%esp
  801f4c:	5b                   	pop    %ebx
  801f4d:	5e                   	pop    %esi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f56:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f59:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f5d:	89 04 24             	mov    %eax,(%esp)
  801f60:	e8 51 f0 ff ff       	call   800fb6 <fd_lookup>
  801f65:	85 c0                	test   %eax,%eax
  801f67:	78 17                	js     801f80 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6c:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f72:	39 10                	cmp    %edx,(%eax)
  801f74:	75 05                	jne    801f7b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f76:	8b 40 0c             	mov    0xc(%eax),%eax
  801f79:	eb 05                	jmp    801f80 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f7b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    

00801f82 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f88:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8b:	e8 c0 ff ff ff       	call   801f50 <fd2sockid>
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 1f                	js     801fb3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f94:	8b 55 10             	mov    0x10(%ebp),%edx
  801f97:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fa2:	89 04 24             	mov    %eax,(%esp)
  801fa5:	e8 38 01 00 00       	call   8020e2 <nsipc_accept>
  801faa:	85 c0                	test   %eax,%eax
  801fac:	78 05                	js     801fb3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801fae:	e8 2c ff ff ff       	call   801edf <alloc_sockfd>
}
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	e8 8d ff ff ff       	call   801f50 <fd2sockid>
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 16                	js     801fdd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801fc7:	8b 55 10             	mov    0x10(%ebp),%edx
  801fca:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 5b 01 00 00       	call   802138 <nsipc_bind>
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <shutdown>:

int
shutdown(int s, int how)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe8:	e8 63 ff ff ff       	call   801f50 <fd2sockid>
  801fed:	85 c0                	test   %eax,%eax
  801fef:	78 0f                	js     802000 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ff8:	89 04 24             	mov    %eax,(%esp)
  801ffb:	e8 77 01 00 00       	call   802177 <nsipc_shutdown>
}
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802002:	55                   	push   %ebp
  802003:	89 e5                	mov    %esp,%ebp
  802005:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802008:	8b 45 08             	mov    0x8(%ebp),%eax
  80200b:	e8 40 ff ff ff       	call   801f50 <fd2sockid>
  802010:	85 c0                	test   %eax,%eax
  802012:	78 16                	js     80202a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802014:	8b 55 10             	mov    0x10(%ebp),%edx
  802017:	89 54 24 08          	mov    %edx,0x8(%esp)
  80201b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802022:	89 04 24             	mov    %eax,(%esp)
  802025:	e8 89 01 00 00       	call   8021b3 <nsipc_connect>
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <listen>:

int
listen(int s, int backlog)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802032:	8b 45 08             	mov    0x8(%ebp),%eax
  802035:	e8 16 ff ff ff       	call   801f50 <fd2sockid>
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 0f                	js     80204d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80203e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802041:	89 54 24 04          	mov    %edx,0x4(%esp)
  802045:	89 04 24             	mov    %eax,(%esp)
  802048:	e8 a5 01 00 00       	call   8021f2 <nsipc_listen>
}
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    

0080204f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802055:	8b 45 10             	mov    0x10(%ebp),%eax
  802058:	89 44 24 08          	mov    %eax,0x8(%esp)
  80205c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802063:	8b 45 08             	mov    0x8(%ebp),%eax
  802066:	89 04 24             	mov    %eax,(%esp)
  802069:	e8 99 02 00 00       	call   802307 <nsipc_socket>
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 05                	js     802077 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802072:	e8 68 fe ff ff       	call   801edf <alloc_sockfd>
}
  802077:	c9                   	leave  
  802078:	c3                   	ret    
  802079:	00 00                	add    %al,(%eax)
	...

0080207c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	53                   	push   %ebx
  802080:	83 ec 14             	sub    $0x14,%esp
  802083:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802085:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80208c:	75 11                	jne    80209f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80208e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802095:	e8 89 08 00 00       	call   802923 <ipc_find_env>
  80209a:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80209f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020a6:	00 
  8020a7:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8020ae:	00 
  8020af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020b3:	a1 04 50 80 00       	mov    0x805004,%eax
  8020b8:	89 04 24             	mov    %eax,(%esp)
  8020bb:	e8 f5 07 00 00       	call   8028b5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020c7:	00 
  8020c8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020cf:	00 
  8020d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020d7:	e8 70 07 00 00       	call   80284c <ipc_recv>
}
  8020dc:	83 c4 14             	add    $0x14,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    

008020e2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	56                   	push   %esi
  8020e6:	53                   	push   %ebx
  8020e7:	83 ec 10             	sub    $0x10,%esp
  8020ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8020ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8020f5:	8b 06                	mov    (%esi),%eax
  8020f7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8020fc:	b8 01 00 00 00       	mov    $0x1,%eax
  802101:	e8 76 ff ff ff       	call   80207c <nsipc>
  802106:	89 c3                	mov    %eax,%ebx
  802108:	85 c0                	test   %eax,%eax
  80210a:	78 23                	js     80212f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80210c:	a1 10 70 80 00       	mov    0x807010,%eax
  802111:	89 44 24 08          	mov    %eax,0x8(%esp)
  802115:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80211c:	00 
  80211d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802120:	89 04 24             	mov    %eax,(%esp)
  802123:	e8 ac e8 ff ff       	call   8009d4 <memmove>
		*addrlen = ret->ret_addrlen;
  802128:	a1 10 70 80 00       	mov    0x807010,%eax
  80212d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80212f:	89 d8                	mov    %ebx,%eax
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	53                   	push   %ebx
  80213c:	83 ec 14             	sub    $0x14,%esp
  80213f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802142:	8b 45 08             	mov    0x8(%ebp),%eax
  802145:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80214a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802151:	89 44 24 04          	mov    %eax,0x4(%esp)
  802155:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80215c:	e8 73 e8 ff ff       	call   8009d4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802161:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802167:	b8 02 00 00 00       	mov    $0x2,%eax
  80216c:	e8 0b ff ff ff       	call   80207c <nsipc>
}
  802171:	83 c4 14             	add    $0x14,%esp
  802174:	5b                   	pop    %ebx
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    

00802177 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80217d:	8b 45 08             	mov    0x8(%ebp),%eax
  802180:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802185:	8b 45 0c             	mov    0xc(%ebp),%eax
  802188:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80218d:	b8 03 00 00 00       	mov    $0x3,%eax
  802192:	e8 e5 fe ff ff       	call   80207c <nsipc>
}
  802197:	c9                   	leave  
  802198:	c3                   	ret    

00802199 <nsipc_close>:

int
nsipc_close(int s)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80219f:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a2:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8021a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8021ac:	e8 cb fe ff ff       	call   80207c <nsipc>
}
  8021b1:	c9                   	leave  
  8021b2:	c3                   	ret    

008021b3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	53                   	push   %ebx
  8021b7:	83 ec 14             	sub    $0x14,%esp
  8021ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c0:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d0:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8021d7:	e8 f8 e7 ff ff       	call   8009d4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021dc:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8021e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8021e7:	e8 90 fe ff ff       	call   80207c <nsipc>
}
  8021ec:	83 c4 14             	add    $0x14,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    

008021f2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802200:	8b 45 0c             	mov    0xc(%ebp),%eax
  802203:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802208:	b8 06 00 00 00       	mov    $0x6,%eax
  80220d:	e8 6a fe ff ff       	call   80207c <nsipc>
}
  802212:	c9                   	leave  
  802213:	c3                   	ret    

00802214 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	56                   	push   %esi
  802218:	53                   	push   %ebx
  802219:	83 ec 10             	sub    $0x10,%esp
  80221c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80221f:	8b 45 08             	mov    0x8(%ebp),%eax
  802222:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802227:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80222d:	8b 45 14             	mov    0x14(%ebp),%eax
  802230:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802235:	b8 07 00 00 00       	mov    $0x7,%eax
  80223a:	e8 3d fe ff ff       	call   80207c <nsipc>
  80223f:	89 c3                	mov    %eax,%ebx
  802241:	85 c0                	test   %eax,%eax
  802243:	78 46                	js     80228b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802245:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80224a:	7f 04                	jg     802250 <nsipc_recv+0x3c>
  80224c:	39 c6                	cmp    %eax,%esi
  80224e:	7d 24                	jge    802274 <nsipc_recv+0x60>
  802250:	c7 44 24 0c e3 31 80 	movl   $0x8031e3,0xc(%esp)
  802257:	00 
  802258:	c7 44 24 08 cb 30 80 	movl   $0x8030cb,0x8(%esp)
  80225f:	00 
  802260:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802267:	00 
  802268:	c7 04 24 f8 31 80 00 	movl   $0x8031f8,(%esp)
  80226f:	e8 44 df ff ff       	call   8001b8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802274:	89 44 24 08          	mov    %eax,0x8(%esp)
  802278:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80227f:	00 
  802280:	8b 45 0c             	mov    0xc(%ebp),%eax
  802283:	89 04 24             	mov    %eax,(%esp)
  802286:	e8 49 e7 ff ff       	call   8009d4 <memmove>
	}

	return r;
}
  80228b:	89 d8                	mov    %ebx,%eax
  80228d:	83 c4 10             	add    $0x10,%esp
  802290:	5b                   	pop    %ebx
  802291:	5e                   	pop    %esi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    

00802294 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802294:	55                   	push   %ebp
  802295:	89 e5                	mov    %esp,%ebp
  802297:	53                   	push   %ebx
  802298:	83 ec 14             	sub    $0x14,%esp
  80229b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80229e:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a1:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8022a6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022ac:	7e 24                	jle    8022d2 <nsipc_send+0x3e>
  8022ae:	c7 44 24 0c 04 32 80 	movl   $0x803204,0xc(%esp)
  8022b5:	00 
  8022b6:	c7 44 24 08 cb 30 80 	movl   $0x8030cb,0x8(%esp)
  8022bd:	00 
  8022be:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8022c5:	00 
  8022c6:	c7 04 24 f8 31 80 00 	movl   $0x8031f8,(%esp)
  8022cd:	e8 e6 de ff ff       	call   8001b8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022dd:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8022e4:	e8 eb e6 ff ff       	call   8009d4 <memmove>
	nsipcbuf.send.req_size = size;
  8022e9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8022ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8022f2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8022f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8022fc:	e8 7b fd ff ff       	call   80207c <nsipc>
}
  802301:	83 c4 14             	add    $0x14,%esp
  802304:	5b                   	pop    %ebx
  802305:	5d                   	pop    %ebp
  802306:	c3                   	ret    

00802307 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80230d:	8b 45 08             	mov    0x8(%ebp),%eax
  802310:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802315:	8b 45 0c             	mov    0xc(%ebp),%eax
  802318:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80231d:	8b 45 10             	mov    0x10(%ebp),%eax
  802320:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802325:	b8 09 00 00 00       	mov    $0x9,%eax
  80232a:	e8 4d fd ff ff       	call   80207c <nsipc>
}
  80232f:	c9                   	leave  
  802330:	c3                   	ret    
  802331:	00 00                	add    %al,(%eax)
	...

00802334 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	56                   	push   %esi
  802338:	53                   	push   %ebx
  802339:	83 ec 10             	sub    $0x10,%esp
  80233c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80233f:	8b 45 08             	mov    0x8(%ebp),%eax
  802342:	89 04 24             	mov    %eax,(%esp)
  802345:	e8 fe eb ff ff       	call   800f48 <fd2data>
  80234a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80234c:	c7 44 24 04 10 32 80 	movl   $0x803210,0x4(%esp)
  802353:	00 
  802354:	89 34 24             	mov    %esi,(%esp)
  802357:	e8 ff e4 ff ff       	call   80085b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80235c:	8b 43 04             	mov    0x4(%ebx),%eax
  80235f:	2b 03                	sub    (%ebx),%eax
  802361:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802367:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80236e:	00 00 00 
	stat->st_dev = &devpipe;
  802371:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802378:	40 80 00 
	return 0;
}
  80237b:	b8 00 00 00 00       	mov    $0x0,%eax
  802380:	83 c4 10             	add    $0x10,%esp
  802383:	5b                   	pop    %ebx
  802384:	5e                   	pop    %esi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    

00802387 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802387:	55                   	push   %ebp
  802388:	89 e5                	mov    %esp,%ebp
  80238a:	53                   	push   %ebx
  80238b:	83 ec 14             	sub    $0x14,%esp
  80238e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802391:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80239c:	e8 53 e9 ff ff       	call   800cf4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8023a1:	89 1c 24             	mov    %ebx,(%esp)
  8023a4:	e8 9f eb ff ff       	call   800f48 <fd2data>
  8023a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b4:	e8 3b e9 ff ff       	call   800cf4 <sys_page_unmap>
}
  8023b9:	83 c4 14             	add    $0x14,%esp
  8023bc:	5b                   	pop    %ebx
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    

008023bf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	57                   	push   %edi
  8023c3:	56                   	push   %esi
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 2c             	sub    $0x2c,%esp
  8023c8:	89 c7                	mov    %eax,%edi
  8023ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8023cd:	a1 08 50 80 00       	mov    0x805008,%eax
  8023d2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8023d5:	89 3c 24             	mov    %edi,(%esp)
  8023d8:	e8 7f 05 00 00       	call   80295c <pageref>
  8023dd:	89 c6                	mov    %eax,%esi
  8023df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023e2:	89 04 24             	mov    %eax,(%esp)
  8023e5:	e8 72 05 00 00       	call   80295c <pageref>
  8023ea:	39 c6                	cmp    %eax,%esi
  8023ec:	0f 94 c0             	sete   %al
  8023ef:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8023f2:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8023f8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8023fb:	39 cb                	cmp    %ecx,%ebx
  8023fd:	75 08                	jne    802407 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8023ff:	83 c4 2c             	add    $0x2c,%esp
  802402:	5b                   	pop    %ebx
  802403:	5e                   	pop    %esi
  802404:	5f                   	pop    %edi
  802405:	5d                   	pop    %ebp
  802406:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802407:	83 f8 01             	cmp    $0x1,%eax
  80240a:	75 c1                	jne    8023cd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80240c:	8b 42 58             	mov    0x58(%edx),%eax
  80240f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802416:	00 
  802417:	89 44 24 08          	mov    %eax,0x8(%esp)
  80241b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80241f:	c7 04 24 17 32 80 00 	movl   $0x803217,(%esp)
  802426:	e8 85 de ff ff       	call   8002b0 <cprintf>
  80242b:	eb a0                	jmp    8023cd <_pipeisclosed+0xe>

0080242d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80242d:	55                   	push   %ebp
  80242e:	89 e5                	mov    %esp,%ebp
  802430:	57                   	push   %edi
  802431:	56                   	push   %esi
  802432:	53                   	push   %ebx
  802433:	83 ec 1c             	sub    $0x1c,%esp
  802436:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802439:	89 34 24             	mov    %esi,(%esp)
  80243c:	e8 07 eb ff ff       	call   800f48 <fd2data>
  802441:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802443:	bf 00 00 00 00       	mov    $0x0,%edi
  802448:	eb 3c                	jmp    802486 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80244a:	89 da                	mov    %ebx,%edx
  80244c:	89 f0                	mov    %esi,%eax
  80244e:	e8 6c ff ff ff       	call   8023bf <_pipeisclosed>
  802453:	85 c0                	test   %eax,%eax
  802455:	75 38                	jne    80248f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802457:	e8 d2 e7 ff ff       	call   800c2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80245c:	8b 43 04             	mov    0x4(%ebx),%eax
  80245f:	8b 13                	mov    (%ebx),%edx
  802461:	83 c2 20             	add    $0x20,%edx
  802464:	39 d0                	cmp    %edx,%eax
  802466:	73 e2                	jae    80244a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802468:	8b 55 0c             	mov    0xc(%ebp),%edx
  80246b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80246e:	89 c2                	mov    %eax,%edx
  802470:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802476:	79 05                	jns    80247d <devpipe_write+0x50>
  802478:	4a                   	dec    %edx
  802479:	83 ca e0             	or     $0xffffffe0,%edx
  80247c:	42                   	inc    %edx
  80247d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802481:	40                   	inc    %eax
  802482:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802485:	47                   	inc    %edi
  802486:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802489:	75 d1                	jne    80245c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80248b:	89 f8                	mov    %edi,%eax
  80248d:	eb 05                	jmp    802494 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802494:	83 c4 1c             	add    $0x1c,%esp
  802497:	5b                   	pop    %ebx
  802498:	5e                   	pop    %esi
  802499:	5f                   	pop    %edi
  80249a:	5d                   	pop    %ebp
  80249b:	c3                   	ret    

0080249c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	57                   	push   %edi
  8024a0:	56                   	push   %esi
  8024a1:	53                   	push   %ebx
  8024a2:	83 ec 1c             	sub    $0x1c,%esp
  8024a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8024a8:	89 3c 24             	mov    %edi,(%esp)
  8024ab:	e8 98 ea ff ff       	call   800f48 <fd2data>
  8024b0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024b2:	be 00 00 00 00       	mov    $0x0,%esi
  8024b7:	eb 3a                	jmp    8024f3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8024b9:	85 f6                	test   %esi,%esi
  8024bb:	74 04                	je     8024c1 <devpipe_read+0x25>
				return i;
  8024bd:	89 f0                	mov    %esi,%eax
  8024bf:	eb 40                	jmp    802501 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8024c1:	89 da                	mov    %ebx,%edx
  8024c3:	89 f8                	mov    %edi,%eax
  8024c5:	e8 f5 fe ff ff       	call   8023bf <_pipeisclosed>
  8024ca:	85 c0                	test   %eax,%eax
  8024cc:	75 2e                	jne    8024fc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8024ce:	e8 5b e7 ff ff       	call   800c2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8024d3:	8b 03                	mov    (%ebx),%eax
  8024d5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8024d8:	74 df                	je     8024b9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8024da:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8024df:	79 05                	jns    8024e6 <devpipe_read+0x4a>
  8024e1:	48                   	dec    %eax
  8024e2:	83 c8 e0             	or     $0xffffffe0,%eax
  8024e5:	40                   	inc    %eax
  8024e6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8024ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ed:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8024f0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024f2:	46                   	inc    %esi
  8024f3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024f6:	75 db                	jne    8024d3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8024f8:	89 f0                	mov    %esi,%eax
  8024fa:	eb 05                	jmp    802501 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024fc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802501:	83 c4 1c             	add    $0x1c,%esp
  802504:	5b                   	pop    %ebx
  802505:	5e                   	pop    %esi
  802506:	5f                   	pop    %edi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    

00802509 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	57                   	push   %edi
  80250d:	56                   	push   %esi
  80250e:	53                   	push   %ebx
  80250f:	83 ec 3c             	sub    $0x3c,%esp
  802512:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802515:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802518:	89 04 24             	mov    %eax,(%esp)
  80251b:	e8 43 ea ff ff       	call   800f63 <fd_alloc>
  802520:	89 c3                	mov    %eax,%ebx
  802522:	85 c0                	test   %eax,%eax
  802524:	0f 88 45 01 00 00    	js     80266f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80252a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802531:	00 
  802532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802535:	89 44 24 04          	mov    %eax,0x4(%esp)
  802539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802540:	e8 08 e7 ff ff       	call   800c4d <sys_page_alloc>
  802545:	89 c3                	mov    %eax,%ebx
  802547:	85 c0                	test   %eax,%eax
  802549:	0f 88 20 01 00 00    	js     80266f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80254f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802552:	89 04 24             	mov    %eax,(%esp)
  802555:	e8 09 ea ff ff       	call   800f63 <fd_alloc>
  80255a:	89 c3                	mov    %eax,%ebx
  80255c:	85 c0                	test   %eax,%eax
  80255e:	0f 88 f8 00 00 00    	js     80265c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802564:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80256b:	00 
  80256c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80256f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802573:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80257a:	e8 ce e6 ff ff       	call   800c4d <sys_page_alloc>
  80257f:	89 c3                	mov    %eax,%ebx
  802581:	85 c0                	test   %eax,%eax
  802583:	0f 88 d3 00 00 00    	js     80265c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80258c:	89 04 24             	mov    %eax,(%esp)
  80258f:	e8 b4 e9 ff ff       	call   800f48 <fd2data>
  802594:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802596:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80259d:	00 
  80259e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a9:	e8 9f e6 ff ff       	call   800c4d <sys_page_alloc>
  8025ae:	89 c3                	mov    %eax,%ebx
  8025b0:	85 c0                	test   %eax,%eax
  8025b2:	0f 88 91 00 00 00    	js     802649 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025bb:	89 04 24             	mov    %eax,(%esp)
  8025be:	e8 85 e9 ff ff       	call   800f48 <fd2data>
  8025c3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8025ca:	00 
  8025cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8025d6:	00 
  8025d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e2:	e8 ba e6 ff ff       	call   800ca1 <sys_page_map>
  8025e7:	89 c3                	mov    %eax,%ebx
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	78 4c                	js     802639 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8025ed:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025f6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8025f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802602:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802608:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80260b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80260d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802610:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80261a:	89 04 24             	mov    %eax,(%esp)
  80261d:	e8 16 e9 ff ff       	call   800f38 <fd2num>
  802622:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802624:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802627:	89 04 24             	mov    %eax,(%esp)
  80262a:	e8 09 e9 ff ff       	call   800f38 <fd2num>
  80262f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802632:	bb 00 00 00 00       	mov    $0x0,%ebx
  802637:	eb 36                	jmp    80266f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80263d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802644:	e8 ab e6 ff ff       	call   800cf4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802649:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80264c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802657:	e8 98 e6 ff ff       	call   800cf4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80265c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80265f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80266a:	e8 85 e6 ff ff       	call   800cf4 <sys_page_unmap>
    err:
	return r;
}
  80266f:	89 d8                	mov    %ebx,%eax
  802671:	83 c4 3c             	add    $0x3c,%esp
  802674:	5b                   	pop    %ebx
  802675:	5e                   	pop    %esi
  802676:	5f                   	pop    %edi
  802677:	5d                   	pop    %ebp
  802678:	c3                   	ret    

00802679 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802679:	55                   	push   %ebp
  80267a:	89 e5                	mov    %esp,%ebp
  80267c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80267f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802682:	89 44 24 04          	mov    %eax,0x4(%esp)
  802686:	8b 45 08             	mov    0x8(%ebp),%eax
  802689:	89 04 24             	mov    %eax,(%esp)
  80268c:	e8 25 e9 ff ff       	call   800fb6 <fd_lookup>
  802691:	85 c0                	test   %eax,%eax
  802693:	78 15                	js     8026aa <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802698:	89 04 24             	mov    %eax,(%esp)
  80269b:	e8 a8 e8 ff ff       	call   800f48 <fd2data>
	return _pipeisclosed(fd, p);
  8026a0:	89 c2                	mov    %eax,%edx
  8026a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a5:	e8 15 fd ff ff       	call   8023bf <_pipeisclosed>
}
  8026aa:	c9                   	leave  
  8026ab:	c3                   	ret    

008026ac <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8026ac:	55                   	push   %ebp
  8026ad:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8026af:	b8 00 00 00 00       	mov    $0x0,%eax
  8026b4:	5d                   	pop    %ebp
  8026b5:	c3                   	ret    

008026b6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8026b6:	55                   	push   %ebp
  8026b7:	89 e5                	mov    %esp,%ebp
  8026b9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8026bc:	c7 44 24 04 2f 32 80 	movl   $0x80322f,0x4(%esp)
  8026c3:	00 
  8026c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026c7:	89 04 24             	mov    %eax,(%esp)
  8026ca:	e8 8c e1 ff ff       	call   80085b <strcpy>
	return 0;
}
  8026cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8026d4:	c9                   	leave  
  8026d5:	c3                   	ret    

008026d6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8026d6:	55                   	push   %ebp
  8026d7:	89 e5                	mov    %esp,%ebp
  8026d9:	57                   	push   %edi
  8026da:	56                   	push   %esi
  8026db:	53                   	push   %ebx
  8026dc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8026e7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026ed:	eb 30                	jmp    80271f <devcons_write+0x49>
		m = n - tot;
  8026ef:	8b 75 10             	mov    0x10(%ebp),%esi
  8026f2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026f4:	83 fe 7f             	cmp    $0x7f,%esi
  8026f7:	76 05                	jbe    8026fe <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8026f9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8026fe:	89 74 24 08          	mov    %esi,0x8(%esp)
  802702:	03 45 0c             	add    0xc(%ebp),%eax
  802705:	89 44 24 04          	mov    %eax,0x4(%esp)
  802709:	89 3c 24             	mov    %edi,(%esp)
  80270c:	e8 c3 e2 ff ff       	call   8009d4 <memmove>
		sys_cputs(buf, m);
  802711:	89 74 24 04          	mov    %esi,0x4(%esp)
  802715:	89 3c 24             	mov    %edi,(%esp)
  802718:	e8 63 e4 ff ff       	call   800b80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80271d:	01 f3                	add    %esi,%ebx
  80271f:	89 d8                	mov    %ebx,%eax
  802721:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802724:	72 c9                	jb     8026ef <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802726:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80272c:	5b                   	pop    %ebx
  80272d:	5e                   	pop    %esi
  80272e:	5f                   	pop    %edi
  80272f:	5d                   	pop    %ebp
  802730:	c3                   	ret    

00802731 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802731:	55                   	push   %ebp
  802732:	89 e5                	mov    %esp,%ebp
  802734:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802737:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80273b:	75 07                	jne    802744 <devcons_read+0x13>
  80273d:	eb 25                	jmp    802764 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80273f:	e8 ea e4 ff ff       	call   800c2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802744:	e8 55 e4 ff ff       	call   800b9e <sys_cgetc>
  802749:	85 c0                	test   %eax,%eax
  80274b:	74 f2                	je     80273f <devcons_read+0xe>
  80274d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80274f:	85 c0                	test   %eax,%eax
  802751:	78 1d                	js     802770 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802753:	83 f8 04             	cmp    $0x4,%eax
  802756:	74 13                	je     80276b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275b:	88 10                	mov    %dl,(%eax)
	return 1;
  80275d:	b8 01 00 00 00       	mov    $0x1,%eax
  802762:	eb 0c                	jmp    802770 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802764:	b8 00 00 00 00       	mov    $0x0,%eax
  802769:	eb 05                	jmp    802770 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80276b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802770:	c9                   	leave  
  802771:	c3                   	ret    

00802772 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802772:	55                   	push   %ebp
  802773:	89 e5                	mov    %esp,%ebp
  802775:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802778:	8b 45 08             	mov    0x8(%ebp),%eax
  80277b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80277e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802785:	00 
  802786:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802789:	89 04 24             	mov    %eax,(%esp)
  80278c:	e8 ef e3 ff ff       	call   800b80 <sys_cputs>
}
  802791:	c9                   	leave  
  802792:	c3                   	ret    

00802793 <getchar>:

int
getchar(void)
{
  802793:	55                   	push   %ebp
  802794:	89 e5                	mov    %esp,%ebp
  802796:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802799:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8027a0:	00 
  8027a1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027af:	e8 9e ea ff ff       	call   801252 <read>
	if (r < 0)
  8027b4:	85 c0                	test   %eax,%eax
  8027b6:	78 0f                	js     8027c7 <getchar+0x34>
		return r;
	if (r < 1)
  8027b8:	85 c0                	test   %eax,%eax
  8027ba:	7e 06                	jle    8027c2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8027bc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8027c0:	eb 05                	jmp    8027c7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8027c2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8027c7:	c9                   	leave  
  8027c8:	c3                   	ret    

008027c9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8027c9:	55                   	push   %ebp
  8027ca:	89 e5                	mov    %esp,%ebp
  8027cc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d9:	89 04 24             	mov    %eax,(%esp)
  8027dc:	e8 d5 e7 ff ff       	call   800fb6 <fd_lookup>
  8027e1:	85 c0                	test   %eax,%eax
  8027e3:	78 11                	js     8027f6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8027e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027e8:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8027ee:	39 10                	cmp    %edx,(%eax)
  8027f0:	0f 94 c0             	sete   %al
  8027f3:	0f b6 c0             	movzbl %al,%eax
}
  8027f6:	c9                   	leave  
  8027f7:	c3                   	ret    

008027f8 <opencons>:

int
opencons(void)
{
  8027f8:	55                   	push   %ebp
  8027f9:	89 e5                	mov    %esp,%ebp
  8027fb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802801:	89 04 24             	mov    %eax,(%esp)
  802804:	e8 5a e7 ff ff       	call   800f63 <fd_alloc>
  802809:	85 c0                	test   %eax,%eax
  80280b:	78 3c                	js     802849 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80280d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802814:	00 
  802815:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80281c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802823:	e8 25 e4 ff ff       	call   800c4d <sys_page_alloc>
  802828:	85 c0                	test   %eax,%eax
  80282a:	78 1d                	js     802849 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80282c:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802835:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80283a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802841:	89 04 24             	mov    %eax,(%esp)
  802844:	e8 ef e6 ff ff       	call   800f38 <fd2num>
}
  802849:	c9                   	leave  
  80284a:	c3                   	ret    
	...

0080284c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80284c:	55                   	push   %ebp
  80284d:	89 e5                	mov    %esp,%ebp
  80284f:	56                   	push   %esi
  802850:	53                   	push   %ebx
  802851:	83 ec 10             	sub    $0x10,%esp
  802854:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802857:	8b 45 0c             	mov    0xc(%ebp),%eax
  80285a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  80285d:	85 c0                	test   %eax,%eax
  80285f:	75 05                	jne    802866 <ipc_recv+0x1a>
  802861:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802866:	89 04 24             	mov    %eax,(%esp)
  802869:	e8 f5 e5 ff ff       	call   800e63 <sys_ipc_recv>
	if (from_env_store != NULL)
  80286e:	85 db                	test   %ebx,%ebx
  802870:	74 0b                	je     80287d <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802872:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802878:	8b 52 74             	mov    0x74(%edx),%edx
  80287b:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  80287d:	85 f6                	test   %esi,%esi
  80287f:	74 0b                	je     80288c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802881:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802887:	8b 52 78             	mov    0x78(%edx),%edx
  80288a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  80288c:	85 c0                	test   %eax,%eax
  80288e:	79 16                	jns    8028a6 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802890:	85 db                	test   %ebx,%ebx
  802892:	74 06                	je     80289a <ipc_recv+0x4e>
			*from_env_store = 0;
  802894:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80289a:	85 f6                	test   %esi,%esi
  80289c:	74 10                	je     8028ae <ipc_recv+0x62>
			*perm_store = 0;
  80289e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8028a4:	eb 08                	jmp    8028ae <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8028a6:	a1 08 50 80 00       	mov    0x805008,%eax
  8028ab:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028ae:	83 c4 10             	add    $0x10,%esp
  8028b1:	5b                   	pop    %ebx
  8028b2:	5e                   	pop    %esi
  8028b3:	5d                   	pop    %ebp
  8028b4:	c3                   	ret    

008028b5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028b5:	55                   	push   %ebp
  8028b6:	89 e5                	mov    %esp,%ebp
  8028b8:	57                   	push   %edi
  8028b9:	56                   	push   %esi
  8028ba:	53                   	push   %ebx
  8028bb:	83 ec 1c             	sub    $0x1c,%esp
  8028be:	8b 75 08             	mov    0x8(%ebp),%esi
  8028c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8028c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8028c7:	eb 2a                	jmp    8028f3 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8028c9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8028cc:	74 20                	je     8028ee <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8028ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028d2:	c7 44 24 08 3c 32 80 	movl   $0x80323c,0x8(%esp)
  8028d9:	00 
  8028da:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8028e1:	00 
  8028e2:	c7 04 24 64 32 80 00 	movl   $0x803264,(%esp)
  8028e9:	e8 ca d8 ff ff       	call   8001b8 <_panic>
		sys_yield();
  8028ee:	e8 3b e3 ff ff       	call   800c2e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8028f3:	85 db                	test   %ebx,%ebx
  8028f5:	75 07                	jne    8028fe <ipc_send+0x49>
  8028f7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8028fc:	eb 02                	jmp    802900 <ipc_send+0x4b>
  8028fe:	89 d8                	mov    %ebx,%eax
  802900:	8b 55 14             	mov    0x14(%ebp),%edx
  802903:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80290b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80290f:	89 34 24             	mov    %esi,(%esp)
  802912:	e8 29 e5 ff ff       	call   800e40 <sys_ipc_try_send>
  802917:	85 c0                	test   %eax,%eax
  802919:	78 ae                	js     8028c9 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80291b:	83 c4 1c             	add    $0x1c,%esp
  80291e:	5b                   	pop    %ebx
  80291f:	5e                   	pop    %esi
  802920:	5f                   	pop    %edi
  802921:	5d                   	pop    %ebp
  802922:	c3                   	ret    

00802923 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802923:	55                   	push   %ebp
  802924:	89 e5                	mov    %esp,%ebp
  802926:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802929:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80292e:	89 c2                	mov    %eax,%edx
  802930:	c1 e2 07             	shl    $0x7,%edx
  802933:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802939:	8b 52 50             	mov    0x50(%edx),%edx
  80293c:	39 ca                	cmp    %ecx,%edx
  80293e:	75 0d                	jne    80294d <ipc_find_env+0x2a>
			return envs[i].env_id;
  802940:	c1 e0 07             	shl    $0x7,%eax
  802943:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802948:	8b 40 40             	mov    0x40(%eax),%eax
  80294b:	eb 0c                	jmp    802959 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80294d:	40                   	inc    %eax
  80294e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802953:	75 d9                	jne    80292e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802955:	66 b8 00 00          	mov    $0x0,%ax
}
  802959:	5d                   	pop    %ebp
  80295a:	c3                   	ret    
	...

0080295c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80295c:	55                   	push   %ebp
  80295d:	89 e5                	mov    %esp,%ebp
  80295f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802962:	89 c2                	mov    %eax,%edx
  802964:	c1 ea 16             	shr    $0x16,%edx
  802967:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80296e:	f6 c2 01             	test   $0x1,%dl
  802971:	74 1e                	je     802991 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802973:	c1 e8 0c             	shr    $0xc,%eax
  802976:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80297d:	a8 01                	test   $0x1,%al
  80297f:	74 17                	je     802998 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802981:	c1 e8 0c             	shr    $0xc,%eax
  802984:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80298b:	ef 
  80298c:	0f b7 c0             	movzwl %ax,%eax
  80298f:	eb 0c                	jmp    80299d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802991:	b8 00 00 00 00       	mov    $0x0,%eax
  802996:	eb 05                	jmp    80299d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802998:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80299d:	5d                   	pop    %ebp
  80299e:	c3                   	ret    
	...

008029a0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8029a0:	55                   	push   %ebp
  8029a1:	57                   	push   %edi
  8029a2:	56                   	push   %esi
  8029a3:	83 ec 10             	sub    $0x10,%esp
  8029a6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8029aa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029b2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8029b6:	89 cd                	mov    %ecx,%ebp
  8029b8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8029bc:	85 c0                	test   %eax,%eax
  8029be:	75 2c                	jne    8029ec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8029c0:	39 f9                	cmp    %edi,%ecx
  8029c2:	77 68                	ja     802a2c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029c4:	85 c9                	test   %ecx,%ecx
  8029c6:	75 0b                	jne    8029d3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8029cd:	31 d2                	xor    %edx,%edx
  8029cf:	f7 f1                	div    %ecx
  8029d1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029d3:	31 d2                	xor    %edx,%edx
  8029d5:	89 f8                	mov    %edi,%eax
  8029d7:	f7 f1                	div    %ecx
  8029d9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029db:	89 f0                	mov    %esi,%eax
  8029dd:	f7 f1                	div    %ecx
  8029df:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029e1:	89 f0                	mov    %esi,%eax
  8029e3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029e5:	83 c4 10             	add    $0x10,%esp
  8029e8:	5e                   	pop    %esi
  8029e9:	5f                   	pop    %edi
  8029ea:	5d                   	pop    %ebp
  8029eb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029ec:	39 f8                	cmp    %edi,%eax
  8029ee:	77 2c                	ja     802a1c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029f0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8029f3:	83 f6 1f             	xor    $0x1f,%esi
  8029f6:	75 4c                	jne    802a44 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029f8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029fa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029ff:	72 0a                	jb     802a0b <__udivdi3+0x6b>
  802a01:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802a05:	0f 87 ad 00 00 00    	ja     802ab8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a0b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a10:	89 f0                	mov    %esi,%eax
  802a12:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a14:	83 c4 10             	add    $0x10,%esp
  802a17:	5e                   	pop    %esi
  802a18:	5f                   	pop    %edi
  802a19:	5d                   	pop    %ebp
  802a1a:	c3                   	ret    
  802a1b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a1c:	31 ff                	xor    %edi,%edi
  802a1e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a20:	89 f0                	mov    %esi,%eax
  802a22:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a24:	83 c4 10             	add    $0x10,%esp
  802a27:	5e                   	pop    %esi
  802a28:	5f                   	pop    %edi
  802a29:	5d                   	pop    %ebp
  802a2a:	c3                   	ret    
  802a2b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a2c:	89 fa                	mov    %edi,%edx
  802a2e:	89 f0                	mov    %esi,%eax
  802a30:	f7 f1                	div    %ecx
  802a32:	89 c6                	mov    %eax,%esi
  802a34:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a36:	89 f0                	mov    %esi,%eax
  802a38:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a3a:	83 c4 10             	add    $0x10,%esp
  802a3d:	5e                   	pop    %esi
  802a3e:	5f                   	pop    %edi
  802a3f:	5d                   	pop    %ebp
  802a40:	c3                   	ret    
  802a41:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a44:	89 f1                	mov    %esi,%ecx
  802a46:	d3 e0                	shl    %cl,%eax
  802a48:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a4c:	b8 20 00 00 00       	mov    $0x20,%eax
  802a51:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a53:	89 ea                	mov    %ebp,%edx
  802a55:	88 c1                	mov    %al,%cl
  802a57:	d3 ea                	shr    %cl,%edx
  802a59:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802a5d:	09 ca                	or     %ecx,%edx
  802a5f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a63:	89 f1                	mov    %esi,%ecx
  802a65:	d3 e5                	shl    %cl,%ebp
  802a67:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a6b:	89 fd                	mov    %edi,%ebp
  802a6d:	88 c1                	mov    %al,%cl
  802a6f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a71:	89 fa                	mov    %edi,%edx
  802a73:	89 f1                	mov    %esi,%ecx
  802a75:	d3 e2                	shl    %cl,%edx
  802a77:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a7b:	88 c1                	mov    %al,%cl
  802a7d:	d3 ef                	shr    %cl,%edi
  802a7f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a81:	89 f8                	mov    %edi,%eax
  802a83:	89 ea                	mov    %ebp,%edx
  802a85:	f7 74 24 08          	divl   0x8(%esp)
  802a89:	89 d1                	mov    %edx,%ecx
  802a8b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a8d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a91:	39 d1                	cmp    %edx,%ecx
  802a93:	72 17                	jb     802aac <__udivdi3+0x10c>
  802a95:	74 09                	je     802aa0 <__udivdi3+0x100>
  802a97:	89 fe                	mov    %edi,%esi
  802a99:	31 ff                	xor    %edi,%edi
  802a9b:	e9 41 ff ff ff       	jmp    8029e1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802aa0:	8b 54 24 04          	mov    0x4(%esp),%edx
  802aa4:	89 f1                	mov    %esi,%ecx
  802aa6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aa8:	39 c2                	cmp    %eax,%edx
  802aaa:	73 eb                	jae    802a97 <__udivdi3+0xf7>
		{
		  q0--;
  802aac:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802aaf:	31 ff                	xor    %edi,%edi
  802ab1:	e9 2b ff ff ff       	jmp    8029e1 <__udivdi3+0x41>
  802ab6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ab8:	31 f6                	xor    %esi,%esi
  802aba:	e9 22 ff ff ff       	jmp    8029e1 <__udivdi3+0x41>
	...

00802ac0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802ac0:	55                   	push   %ebp
  802ac1:	57                   	push   %edi
  802ac2:	56                   	push   %esi
  802ac3:	83 ec 20             	sub    $0x20,%esp
  802ac6:	8b 44 24 30          	mov    0x30(%esp),%eax
  802aca:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802ace:	89 44 24 14          	mov    %eax,0x14(%esp)
  802ad2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802ad6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802ada:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802ade:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802ae0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ae2:	85 ed                	test   %ebp,%ebp
  802ae4:	75 16                	jne    802afc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802ae6:	39 f1                	cmp    %esi,%ecx
  802ae8:	0f 86 a6 00 00 00    	jbe    802b94 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802aee:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802af0:	89 d0                	mov    %edx,%eax
  802af2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802af4:	83 c4 20             	add    $0x20,%esp
  802af7:	5e                   	pop    %esi
  802af8:	5f                   	pop    %edi
  802af9:	5d                   	pop    %ebp
  802afa:	c3                   	ret    
  802afb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802afc:	39 f5                	cmp    %esi,%ebp
  802afe:	0f 87 ac 00 00 00    	ja     802bb0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b04:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802b07:	83 f0 1f             	xor    $0x1f,%eax
  802b0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b0e:	0f 84 a8 00 00 00    	je     802bbc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b14:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b18:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b1a:	bf 20 00 00 00       	mov    $0x20,%edi
  802b1f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802b23:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b27:	89 f9                	mov    %edi,%ecx
  802b29:	d3 e8                	shr    %cl,%eax
  802b2b:	09 e8                	or     %ebp,%eax
  802b2d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802b31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b35:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b39:	d3 e0                	shl    %cl,%eax
  802b3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b3f:	89 f2                	mov    %esi,%edx
  802b41:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b43:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b47:	d3 e0                	shl    %cl,%eax
  802b49:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b4d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b51:	89 f9                	mov    %edi,%ecx
  802b53:	d3 e8                	shr    %cl,%eax
  802b55:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b57:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b59:	89 f2                	mov    %esi,%edx
  802b5b:	f7 74 24 18          	divl   0x18(%esp)
  802b5f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b61:	f7 64 24 0c          	mull   0xc(%esp)
  802b65:	89 c5                	mov    %eax,%ebp
  802b67:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b69:	39 d6                	cmp    %edx,%esi
  802b6b:	72 67                	jb     802bd4 <__umoddi3+0x114>
  802b6d:	74 75                	je     802be4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b6f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b73:	29 e8                	sub    %ebp,%eax
  802b75:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b77:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b7b:	d3 e8                	shr    %cl,%eax
  802b7d:	89 f2                	mov    %esi,%edx
  802b7f:	89 f9                	mov    %edi,%ecx
  802b81:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b83:	09 d0                	or     %edx,%eax
  802b85:	89 f2                	mov    %esi,%edx
  802b87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b8b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b8d:	83 c4 20             	add    $0x20,%esp
  802b90:	5e                   	pop    %esi
  802b91:	5f                   	pop    %edi
  802b92:	5d                   	pop    %ebp
  802b93:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b94:	85 c9                	test   %ecx,%ecx
  802b96:	75 0b                	jne    802ba3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b98:	b8 01 00 00 00       	mov    $0x1,%eax
  802b9d:	31 d2                	xor    %edx,%edx
  802b9f:	f7 f1                	div    %ecx
  802ba1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802ba3:	89 f0                	mov    %esi,%eax
  802ba5:	31 d2                	xor    %edx,%edx
  802ba7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802ba9:	89 f8                	mov    %edi,%eax
  802bab:	e9 3e ff ff ff       	jmp    802aee <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802bb0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bb2:	83 c4 20             	add    $0x20,%esp
  802bb5:	5e                   	pop    %esi
  802bb6:	5f                   	pop    %edi
  802bb7:	5d                   	pop    %ebp
  802bb8:	c3                   	ret    
  802bb9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802bbc:	39 f5                	cmp    %esi,%ebp
  802bbe:	72 04                	jb     802bc4 <__umoddi3+0x104>
  802bc0:	39 f9                	cmp    %edi,%ecx
  802bc2:	77 06                	ja     802bca <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802bc4:	89 f2                	mov    %esi,%edx
  802bc6:	29 cf                	sub    %ecx,%edi
  802bc8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802bca:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bcc:	83 c4 20             	add    $0x20,%esp
  802bcf:	5e                   	pop    %esi
  802bd0:	5f                   	pop    %edi
  802bd1:	5d                   	pop    %ebp
  802bd2:	c3                   	ret    
  802bd3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802bd4:	89 d1                	mov    %edx,%ecx
  802bd6:	89 c5                	mov    %eax,%ebp
  802bd8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802bdc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802be0:	eb 8d                	jmp    802b6f <__umoddi3+0xaf>
  802be2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802be4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802be8:	72 ea                	jb     802bd4 <__umoddi3+0x114>
  802bea:	89 f1                	mov    %esi,%ecx
  802bec:	eb 81                	jmp    802b6f <__umoddi3+0xaf>
