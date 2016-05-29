
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  80004d:	e8 a2 01 00 00       	call   8001f4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 fe 25 80 	movl   $0x8025fe,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 fe 25 80 00 	movl   $0x8025fe,(%esp)
  800069:	e8 96 13 00 00       	call   801404 <spawnl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 04 26 80 	movl   $0x802604,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 1c 26 80 00 	movl   $0x80261c,(%esp)
  80008d:	e8 6a 00 00 00       	call   8000fc <_panic>
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	83 ec 10             	sub    $0x10,%esp
  80009c:	8b 75 08             	mov    0x8(%ebp),%esi
  80009f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a2:	e8 ac 0a 00 00       	call   800b53 <sys_getenvid>
  8000a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b3:	c1 e0 07             	shl    $0x7,%eax
  8000b6:	29 d0                	sub    %edx,%eax
  8000b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	85 f6                	test   %esi,%esi
  8000c4:	7e 07                	jle    8000cd <libmain+0x39>
		binaryname = argv[0];
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 07 0a 00 00       	call   800b01 <sys_env_destroy>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800104:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800107:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80010d:	e8 41 0a 00 00       	call   800b53 <sys_getenvid>
  800112:	8b 55 0c             	mov    0xc(%ebp),%edx
  800115:	89 54 24 10          	mov    %edx,0x10(%esp)
  800119:	8b 55 08             	mov    0x8(%ebp),%edx
  80011c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800120:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800124:	89 44 24 04          	mov    %eax,0x4(%esp)
  800128:	c7 04 24 38 26 80 00 	movl   $0x802638,(%esp)
  80012f:	e8 c0 00 00 00       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800134:	89 74 24 04          	mov    %esi,0x4(%esp)
  800138:	8b 45 10             	mov    0x10(%ebp),%eax
  80013b:	89 04 24             	mov    %eax,(%esp)
  80013e:	e8 50 00 00 00       	call   800193 <vcprintf>
	cprintf("\n");
  800143:	c7 04 24 42 2b 80 00 	movl   $0x802b42,(%esp)
  80014a:	e8 a5 00 00 00       	call   8001f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80014f:	cc                   	int3   
  800150:	eb fd                	jmp    80014f <_panic+0x53>
	...

00800154 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	53                   	push   %ebx
  800158:	83 ec 14             	sub    $0x14,%esp
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015e:	8b 03                	mov    (%ebx),%eax
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800167:	40                   	inc    %eax
  800168:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80016a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016f:	75 19                	jne    80018a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800171:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800178:	00 
  800179:	8d 43 08             	lea    0x8(%ebx),%eax
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	e8 40 09 00 00       	call   800ac4 <sys_cputs>
		b->idx = 0;
  800184:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80018a:	ff 43 04             	incl   0x4(%ebx)
}
  80018d:	83 c4 14             	add    $0x14,%esp
  800190:	5b                   	pop    %ebx
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80019c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a3:	00 00 00 
	b.cnt = 0;
  8001a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c8:	c7 04 24 54 01 80 00 	movl   $0x800154,(%esp)
  8001cf:	e8 82 01 00 00       	call   800356 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 d8 08 00 00       	call   800ac4 <sys_cputs>

	return b.cnt;
}
  8001ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800201:	8b 45 08             	mov    0x8(%ebp),%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	e8 87 ff ff ff       	call   800193 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    
	...

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 3c             	sub    $0x3c,%esp
  800219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80021c:	89 d7                	mov    %edx,%edi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80022d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 08                	jne    80023c <printnum+0x2c>
  800234:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800237:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023a:	77 57                	ja     800293 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800240:	4b                   	dec    %ebx
  800241:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800245:	8b 45 10             	mov    0x10(%ebp),%eax
  800248:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800250:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800254:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025b:	00 
  80025c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	e8 0e 21 00 00       	call   80237c <__udivdi3>
  80026e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800272:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027d:	89 fa                	mov    %edi,%edx
  80027f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800282:	e8 89 ff ff ff       	call   800210 <printnum>
  800287:	eb 0f                	jmp    800298 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028d:	89 34 24             	mov    %esi,(%esp)
  800290:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800293:	4b                   	dec    %ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7f f1                	jg     800289 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800298:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ae:	00 
  8002af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	e8 db 21 00 00       	call   80249c <__umoddi3>
  8002c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c5:	0f be 80 5b 26 80 00 	movsbl 0x80265b(%eax),%eax
  8002cc:	89 04 24             	mov    %eax,(%esp)
  8002cf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002d2:	83 c4 3c             	add    $0x3c,%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002dd:	83 fa 01             	cmp    $0x1,%edx
  8002e0:	7e 0e                	jle    8002f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ee:	eb 22                	jmp    800312 <getuint+0x38>
	else if (lflag)
  8002f0:	85 d2                	test   %edx,%edx
  8002f2:	74 10                	je     800304 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800302:	eb 0e                	jmp    800312 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	3b 50 04             	cmp    0x4(%eax),%edx
  800322:	73 08                	jae    80032c <sprintputch+0x18>
		*b->buf++ = ch;
  800324:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800327:	88 0a                	mov    %cl,(%edx)
  800329:	42                   	inc    %edx
  80032a:	89 10                	mov    %edx,(%eax)
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800337:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80033b:	8b 45 10             	mov    0x10(%ebp),%eax
  80033e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
  800345:	89 44 24 04          	mov    %eax,0x4(%esp)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	89 04 24             	mov    %eax,(%esp)
  80034f:	e8 02 00 00 00       	call   800356 <vprintfmt>
	va_end(ap);
}
  800354:	c9                   	leave  
  800355:	c3                   	ret    

00800356 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
  80035c:	83 ec 4c             	sub    $0x4c,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800362:	8b 75 10             	mov    0x10(%ebp),%esi
  800365:	eb 12                	jmp    800379 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800367:	85 c0                	test   %eax,%eax
  800369:	0f 84 6b 03 00 00    	je     8006da <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80036f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800373:	89 04 24             	mov    %eax,(%esp)
  800376:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	0f b6 06             	movzbl (%esi),%eax
  80037c:	46                   	inc    %esi
  80037d:	83 f8 25             	cmp    $0x25,%eax
  800380:	75 e5                	jne    800367 <vprintfmt+0x11>
  800382:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800386:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800392:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800399:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039e:	eb 26                	jmp    8003c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003a7:	eb 1d                	jmp    8003c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ac:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003b0:	eb 14                	jmp    8003c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003bc:	eb 08                	jmp    8003c6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003be:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	0f b6 06             	movzbl (%esi),%eax
  8003c9:	8d 56 01             	lea    0x1(%esi),%edx
  8003cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003cf:	8a 16                	mov    (%esi),%dl
  8003d1:	83 ea 23             	sub    $0x23,%edx
  8003d4:	80 fa 55             	cmp    $0x55,%dl
  8003d7:	0f 87 e1 02 00 00    	ja     8006be <vprintfmt+0x368>
  8003dd:	0f b6 d2             	movzbl %dl,%edx
  8003e0:	ff 24 95 a0 27 80 00 	jmp    *0x8027a0(,%edx,4)
  8003e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ea:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ef:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003f2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003f6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003fc:	83 fa 09             	cmp    $0x9,%edx
  8003ff:	77 2a                	ja     80042b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800401:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800402:	eb eb                	jmp    8003ef <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800412:	eb 17                	jmp    80042b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800414:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800418:	78 98                	js     8003b2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80041d:	eb a7                	jmp    8003c6 <vprintfmt+0x70>
  80041f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800422:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800429:	eb 9b                	jmp    8003c6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80042b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042f:	79 95                	jns    8003c6 <vprintfmt+0x70>
  800431:	eb 8b                	jmp    8003be <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800433:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800437:	eb 8d                	jmp    8003c6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800446:	8b 00                	mov    (%eax),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800451:	e9 23 ff ff ff       	jmp    800379 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	85 c0                	test   %eax,%eax
  800463:	79 02                	jns    800467 <vprintfmt+0x111>
  800465:	f7 d8                	neg    %eax
  800467:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 0f             	cmp    $0xf,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x123>
  80046e:	8b 04 85 00 29 80 00 	mov    0x802900(,%eax,4),%eax
  800475:	85 c0                	test   %eax,%eax
  800477:	75 23                	jne    80049c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800479:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047d:	c7 44 24 08 73 26 80 	movl   $0x802673,0x8(%esp)
  800484:	00 
  800485:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800489:	8b 45 08             	mov    0x8(%ebp),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	e8 9a fe ff ff       	call   80032e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800497:	e9 dd fe ff ff       	jmp    800379 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80049c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a0:	c7 44 24 08 b6 29 80 	movl   $0x8029b6,0x8(%esp)
  8004a7:	00 
  8004a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8004af:	89 14 24             	mov    %edx,(%esp)
  8004b2:	e8 77 fe ff ff       	call   80032e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ba:	e9 ba fe ff ff       	jmp    800379 <vprintfmt+0x23>
  8004bf:	89 f9                	mov    %edi,%ecx
  8004c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 30                	mov    (%eax),%esi
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	75 05                	jne    8004db <vprintfmt+0x185>
				p = "(null)";
  8004d6:	be 6c 26 80 00       	mov    $0x80266c,%esi
			if (width > 0 && padc != '-')
  8004db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004df:	0f 8e 84 00 00 00    	jle    800569 <vprintfmt+0x213>
  8004e5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004e9:	74 7e                	je     800569 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004ef:	89 34 24             	mov    %esi,(%esp)
  8004f2:	e8 8b 02 00 00       	call   800782 <strnlen>
  8004f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004fa:	29 c2                	sub    %eax,%edx
  8004fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004ff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800503:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800506:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800509:	89 de                	mov    %ebx,%esi
  80050b:	89 d3                	mov    %edx,%ebx
  80050d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	eb 0b                	jmp    80051c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800511:	89 74 24 04          	mov    %esi,0x4(%esp)
  800515:	89 3c 24             	mov    %edi,(%esp)
  800518:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	4b                   	dec    %ebx
  80051c:	85 db                	test   %ebx,%ebx
  80051e:	7f f1                	jg     800511 <vprintfmt+0x1bb>
  800520:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800523:	89 f3                	mov    %esi,%ebx
  800525:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800528:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	79 05                	jns    800534 <vprintfmt+0x1de>
  80052f:	b8 00 00 00 00       	mov    $0x0,%eax
  800534:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800537:	29 c2                	sub    %eax,%edx
  800539:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80053c:	eb 2b                	jmp    800569 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800542:	74 18                	je     80055c <vprintfmt+0x206>
  800544:	8d 50 e0             	lea    -0x20(%eax),%edx
  800547:	83 fa 5e             	cmp    $0x5e,%edx
  80054a:	76 10                	jbe    80055c <vprintfmt+0x206>
					putch('?', putdat);
  80054c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800550:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	eb 0a                	jmp    800566 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800566:	ff 4d e4             	decl   -0x1c(%ebp)
  800569:	0f be 06             	movsbl (%esi),%eax
  80056c:	46                   	inc    %esi
  80056d:	85 c0                	test   %eax,%eax
  80056f:	74 21                	je     800592 <vprintfmt+0x23c>
  800571:	85 ff                	test   %edi,%edi
  800573:	78 c9                	js     80053e <vprintfmt+0x1e8>
  800575:	4f                   	dec    %edi
  800576:	79 c6                	jns    80053e <vprintfmt+0x1e8>
  800578:	8b 7d 08             	mov    0x8(%ebp),%edi
  80057b:	89 de                	mov    %ebx,%esi
  80057d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800580:	eb 18                	jmp    80059a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800582:	89 74 24 04          	mov    %esi,0x4(%esp)
  800586:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80058d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058f:	4b                   	dec    %ebx
  800590:	eb 08                	jmp    80059a <vprintfmt+0x244>
  800592:	8b 7d 08             	mov    0x8(%ebp),%edi
  800595:	89 de                	mov    %ebx,%esi
  800597:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80059a:	85 db                	test   %ebx,%ebx
  80059c:	7f e4                	jg     800582 <vprintfmt+0x22c>
  80059e:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005a1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a6:	e9 ce fd ff ff       	jmp    800379 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 f9 01             	cmp    $0x1,%ecx
  8005ae:	7e 10                	jle    8005c0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 08             	lea    0x8(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 30                	mov    (%eax),%esi
  8005bb:	8b 78 04             	mov    0x4(%eax),%edi
  8005be:	eb 26                	jmp    8005e6 <vprintfmt+0x290>
	else if (lflag)
  8005c0:	85 c9                	test   %ecx,%ecx
  8005c2:	74 12                	je     8005d6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 30                	mov    (%eax),%esi
  8005cf:	89 f7                	mov    %esi,%edi
  8005d1:	c1 ff 1f             	sar    $0x1f,%edi
  8005d4:	eb 10                	jmp    8005e6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 30                	mov    (%eax),%esi
  8005e1:	89 f7                	mov    %esi,%edi
  8005e3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e6:	85 ff                	test   %edi,%edi
  8005e8:	78 0a                	js     8005f4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 8c 00 00 00       	jmp    800680 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800602:	f7 de                	neg    %esi
  800604:	83 d7 00             	adc    $0x0,%edi
  800607:	f7 df                	neg    %edi
			}
			base = 10;
  800609:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060e:	eb 70                	jmp    800680 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800610:	89 ca                	mov    %ecx,%edx
  800612:	8d 45 14             	lea    0x14(%ebp),%eax
  800615:	e8 c0 fc ff ff       	call   8002da <getuint>
  80061a:	89 c6                	mov    %eax,%esi
  80061c:	89 d7                	mov    %edx,%edi
			base = 10;
  80061e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800623:	eb 5b                	jmp    800680 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800625:	89 ca                	mov    %ecx,%edx
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 ab fc ff ff       	call   8002da <getuint>
  80062f:	89 c6                	mov    %eax,%esi
  800631:	89 d7                	mov    %edx,%edi
			base = 8;
  800633:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800638:	eb 46                	jmp    800680 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80063a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800645:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065f:	8b 30                	mov    (%eax),%esi
  800661:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800666:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80066b:	eb 13                	jmp    800680 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066d:	89 ca                	mov    %ecx,%edx
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 63 fc ff ff       	call   8002da <getuint>
  800677:	89 c6                	mov    %eax,%esi
  800679:	89 d7                	mov    %edx,%edi
			base = 16;
  80067b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800680:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800684:	89 54 24 10          	mov    %edx,0x10(%esp)
  800688:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800693:	89 34 24             	mov    %esi,(%esp)
  800696:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069a:	89 da                	mov    %ebx,%edx
  80069c:	8b 45 08             	mov    0x8(%ebp),%eax
  80069f:	e8 6c fb ff ff       	call   800210 <printnum>
			break;
  8006a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a7:	e9 cd fc ff ff       	jmp    800379 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b9:	e9 bb fc ff ff       	jmp    800379 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cc:	eb 01                	jmp    8006cf <vprintfmt+0x379>
  8006ce:	4e                   	dec    %esi
  8006cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006d3:	75 f9                	jne    8006ce <vprintfmt+0x378>
  8006d5:	e9 9f fc ff ff       	jmp    800379 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006da:	83 c4 4c             	add    $0x4c,%esp
  8006dd:	5b                   	pop    %ebx
  8006de:	5e                   	pop    %esi
  8006df:	5f                   	pop    %edi
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 28             	sub    $0x28,%esp
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	74 30                	je     800733 <vsnprintf+0x51>
  800703:	85 d2                	test   %edx,%edx
  800705:	7e 33                	jle    80073a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070e:	8b 45 10             	mov    0x10(%ebp),%eax
  800711:	89 44 24 08          	mov    %eax,0x8(%esp)
  800715:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071c:	c7 04 24 14 03 80 00 	movl   $0x800314,(%esp)
  800723:	e8 2e fc ff ff       	call   800356 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	eb 0c                	jmp    80073f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800738:	eb 05                	jmp    80073f <vsnprintf+0x5d>
  80073a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8b 45 0c             	mov    0xc(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	89 04 24             	mov    %eax,(%esp)
  800762:	e8 7b ff ff ff       	call   8006e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800767:	c9                   	leave  
  800768:	c3                   	ret    
  800769:	00 00                	add    %al,(%eax)
	...

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 01                	jmp    80077a <strlen+0xe>
		n++;
  800779:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	75 f9                	jne    800779 <strlen+0xd>
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 01                	jmp    800793 <strnlen+0x11>
		n++;
  800792:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800793:	39 d0                	cmp    %edx,%eax
  800795:	74 06                	je     80079d <strnlen+0x1b>
  800797:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079b:	75 f5                	jne    800792 <strnlen+0x10>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b4:	42                   	inc    %edx
  8007b5:	84 c9                	test   %cl,%cl
  8007b7:	75 f5                	jne    8007ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b9:	5b                   	pop    %ebx
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c6:	89 1c 24             	mov    %ebx,(%esp)
  8007c9:	e8 9e ff ff ff       	call   80076c <strlen>
	strcpy(dst + len, src);
  8007ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d5:	01 d8                	add    %ebx,%eax
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 c0 ff ff ff       	call   80079f <strcpy>
	return dst;
}
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	83 c4 08             	add    $0x8,%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fa:	eb 0c                	jmp    800808 <strncpy+0x21>
		*dst++ = *src;
  8007fc:	8a 1a                	mov    (%edx),%bl
  8007fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800801:	80 3a 01             	cmpb   $0x1,(%edx)
  800804:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	41                   	inc    %ecx
  800808:	39 f1                	cmp    %esi,%ecx
  80080a:	75 f0                	jne    8007fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	56                   	push   %esi
  800814:	53                   	push   %ebx
  800815:	8b 75 08             	mov    0x8(%ebp),%esi
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081e:	85 d2                	test   %edx,%edx
  800820:	75 0a                	jne    80082c <strlcpy+0x1c>
  800822:	89 f0                	mov    %esi,%eax
  800824:	eb 1a                	jmp    800840 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800826:	88 18                	mov    %bl,(%eax)
  800828:	40                   	inc    %eax
  800829:	41                   	inc    %ecx
  80082a:	eb 02                	jmp    80082e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80082e:	4a                   	dec    %edx
  80082f:	74 0a                	je     80083b <strlcpy+0x2b>
  800831:	8a 19                	mov    (%ecx),%bl
  800833:	84 db                	test   %bl,%bl
  800835:	75 ef                	jne    800826 <strlcpy+0x16>
  800837:	89 c2                	mov    %eax,%edx
  800839:	eb 02                	jmp    80083d <strlcpy+0x2d>
  80083b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80083d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800840:	29 f0                	sub    %esi,%eax
}
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084f:	eb 02                	jmp    800853 <strcmp+0xd>
		p++, q++;
  800851:	41                   	inc    %ecx
  800852:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800853:	8a 01                	mov    (%ecx),%al
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x17>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 f4                	je     800851 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800871:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800874:	eb 03                	jmp    800879 <strncmp+0x12>
		n--, p++, q++;
  800876:	4a                   	dec    %edx
  800877:	40                   	inc    %eax
  800878:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 14                	je     800891 <strncmp+0x2a>
  80087d:	8a 18                	mov    (%eax),%bl
  80087f:	84 db                	test   %bl,%bl
  800881:	74 04                	je     800887 <strncmp+0x20>
  800883:	3a 19                	cmp    (%ecx),%bl
  800885:	74 ef                	je     800876 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 00             	movzbl (%eax),%eax
  80088a:	0f b6 11             	movzbl (%ecx),%edx
  80088d:	29 d0                	sub    %edx,%eax
  80088f:	eb 05                	jmp    800896 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a2:	eb 05                	jmp    8008a9 <strchr+0x10>
		if (*s == c)
  8008a4:	38 ca                	cmp    %cl,%dl
  8008a6:	74 0c                	je     8008b4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a8:	40                   	inc    %eax
  8008a9:	8a 10                	mov    (%eax),%dl
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f5                	jne    8008a4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bf:	eb 05                	jmp    8008c6 <strfind+0x10>
		if (*s == c)
  8008c1:	38 ca                	cmp    %cl,%dl
  8008c3:	74 07                	je     8008cc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c5:	40                   	inc    %eax
  8008c6:	8a 10                	mov    (%eax),%dl
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	75 f5                	jne    8008c1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	57                   	push   %edi
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	74 30                	je     800911 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e7:	75 25                	jne    80090e <memset+0x40>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 20                	jne    80090e <memset+0x40>
		c &= 0xFF;
  8008ee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f1:	89 d3                	mov    %edx,%ebx
  8008f3:	c1 e3 08             	shl    $0x8,%ebx
  8008f6:	89 d6                	mov    %edx,%esi
  8008f8:	c1 e6 18             	shl    $0x18,%esi
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	c1 e0 10             	shl    $0x10,%eax
  800900:	09 f0                	or     %esi,%eax
  800902:	09 d0                	or     %edx,%eax
  800904:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800906:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800909:	fc                   	cld    
  80090a:	f3 ab                	rep stos %eax,%es:(%edi)
  80090c:	eb 03                	jmp    800911 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090e:	fc                   	cld    
  80090f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800911:	89 f8                	mov    %edi,%eax
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	57                   	push   %edi
  80091c:	56                   	push   %esi
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 75 0c             	mov    0xc(%ebp),%esi
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800926:	39 c6                	cmp    %eax,%esi
  800928:	73 34                	jae    80095e <memmove+0x46>
  80092a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092d:	39 d0                	cmp    %edx,%eax
  80092f:	73 2d                	jae    80095e <memmove+0x46>
		s += n;
		d += n;
  800931:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800934:	f6 c2 03             	test   $0x3,%dl
  800937:	75 1b                	jne    800954 <memmove+0x3c>
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 13                	jne    800954 <memmove+0x3c>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 0e                	jne    800954 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800946:	83 ef 04             	sub    $0x4,%edi
  800949:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094f:	fd                   	std    
  800950:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800952:	eb 07                	jmp    80095b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800954:	4f                   	dec    %edi
  800955:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800958:	fd                   	std    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095b:	fc                   	cld    
  80095c:	eb 20                	jmp    80097e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x61>
  800966:	a8 03                	test   $0x3,%al
  800968:	75 0f                	jne    800979 <memmove+0x61>
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 0a                	jne    800979 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 05                	jmp    80097e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800988:	8b 45 10             	mov    0x10(%ebp),%eax
  80098b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800992:	89 44 24 04          	mov    %eax,0x4(%esp)
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	e8 77 ff ff ff       	call   800918 <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	eb 16                	jmp    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
  8009b9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009bc:	42                   	inc    %edx
  8009bd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009c1:	38 c8                	cmp    %cl,%al
  8009c3:	74 0a                	je     8009cf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009c5:	0f b6 c0             	movzbl %al,%eax
  8009c8:	0f b6 c9             	movzbl %cl,%ecx
  8009cb:	29 c8                	sub    %ecx,%eax
  8009cd:	eb 09                	jmp    8009d8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 da                	cmp    %ebx,%edx
  8009d1:	75 e6                	jne    8009b9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5f                   	pop    %edi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e6:	89 c2                	mov    %eax,%edx
  8009e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009eb:	eb 05                	jmp    8009f2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	74 05                	je     8009f6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f1:	40                   	inc    %eax
  8009f2:	39 d0                	cmp    %edx,%eax
  8009f4:	72 f7                	jb     8009ed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a04:	eb 01                	jmp    800a07 <strtol+0xf>
		s++;
  800a06:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a07:	8a 02                	mov    (%edx),%al
  800a09:	3c 20                	cmp    $0x20,%al
  800a0b:	74 f9                	je     800a06 <strtol+0xe>
  800a0d:	3c 09                	cmp    $0x9,%al
  800a0f:	74 f5                	je     800a06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a11:	3c 2b                	cmp    $0x2b,%al
  800a13:	75 08                	jne    800a1d <strtol+0x25>
		s++;
  800a15:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a16:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1b:	eb 13                	jmp    800a30 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1d:	3c 2d                	cmp    $0x2d,%al
  800a1f:	75 0a                	jne    800a2b <strtol+0x33>
		s++, neg = 1;
  800a21:	8d 52 01             	lea    0x1(%edx),%edx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi
  800a29:	eb 05                	jmp    800a30 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	74 05                	je     800a39 <strtol+0x41>
  800a34:	83 fb 10             	cmp    $0x10,%ebx
  800a37:	75 28                	jne    800a61 <strtol+0x69>
  800a39:	8a 02                	mov    (%edx),%al
  800a3b:	3c 30                	cmp    $0x30,%al
  800a3d:	75 10                	jne    800a4f <strtol+0x57>
  800a3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a43:	75 0a                	jne    800a4f <strtol+0x57>
		s += 2, base = 16;
  800a45:	83 c2 02             	add    $0x2,%edx
  800a48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4d:	eb 12                	jmp    800a61 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	75 0e                	jne    800a61 <strtol+0x69>
  800a53:	3c 30                	cmp    $0x30,%al
  800a55:	75 05                	jne    800a5c <strtol+0x64>
		s++, base = 8;
  800a57:	42                   	inc    %edx
  800a58:	b3 08                	mov    $0x8,%bl
  800a5a:	eb 05                	jmp    800a61 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
  800a66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a68:	8a 0a                	mov    (%edx),%cl
  800a6a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a6d:	80 fb 09             	cmp    $0x9,%bl
  800a70:	77 08                	ja     800a7a <strtol+0x82>
			dig = *s - '0';
  800a72:	0f be c9             	movsbl %cl,%ecx
  800a75:	83 e9 30             	sub    $0x30,%ecx
  800a78:	eb 1e                	jmp    800a98 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a7a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a7d:	80 fb 19             	cmp    $0x19,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a82:	0f be c9             	movsbl %cl,%ecx
  800a85:	83 e9 57             	sub    $0x57,%ecx
  800a88:	eb 0e                	jmp    800a98 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a8a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a8d:	80 fb 19             	cmp    $0x19,%bl
  800a90:	77 12                	ja     800aa4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a92:	0f be c9             	movsbl %cl,%ecx
  800a95:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a98:	39 f1                	cmp    %esi,%ecx
  800a9a:	7d 0c                	jge    800aa8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a9c:	42                   	inc    %edx
  800a9d:	0f af c6             	imul   %esi,%eax
  800aa0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aa2:	eb c4                	jmp    800a68 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aa4:	89 c1                	mov    %eax,%ecx
  800aa6:	eb 02                	jmp    800aaa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aaa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aae:	74 05                	je     800ab5 <strtol+0xbd>
		*endptr = (char *) s;
  800ab0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ab5:	85 ff                	test   %edi,%edi
  800ab7:	74 04                	je     800abd <strtol+0xc5>
  800ab9:	89 c8                	mov    %ecx,%eax
  800abb:	f7 d8                	neg    %eax
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    
	...

00800ac4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	89 cb                	mov    %ecx,%ebx
  800b19:	89 cf                	mov    %ecx,%edi
  800b1b:	89 ce                	mov    %ecx,%esi
  800b1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	7e 28                	jle    800b4b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b23:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b27:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b2e:	00 
  800b2f:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800b36:	00 
  800b37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b3e:	00 
  800b3f:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800b46:	e8 b1 f5 ff ff       	call   8000fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4b:	83 c4 2c             	add    $0x2c,%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_yield>:

void
sys_yield(void)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b82:	89 d1                	mov    %edx,%ecx
  800b84:	89 d3                	mov    %edx,%ebx
  800b86:	89 d7                	mov    %edx,%edi
  800b88:	89 d6                	mov    %edx,%esi
  800b8a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
  800b97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	be 00 00 00 00       	mov    $0x0,%esi
  800b9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 f7                	mov    %esi,%edi
  800baf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 28                	jle    800bdd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bc0:	00 
  800bc1:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd0:	00 
  800bd1:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800bd8:	e8 1f f5 ff ff       	call   8000fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdd:	83 c4 2c             	add    $0x2c,%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf3:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	7e 28                	jle    800c30 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c0c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c13:	00 
  800c14:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c23:	00 
  800c24:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800c2b:	e8 cc f4 ff ff       	call   8000fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c30:	83 c4 2c             	add    $0x2c,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c46:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	89 df                	mov    %ebx,%edi
  800c53:	89 de                	mov    %ebx,%esi
  800c55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 28                	jle    800c83 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c66:	00 
  800c67:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800c7e:	e8 79 f4 ff ff       	call   8000fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c83:	83 c4 2c             	add    $0x2c,%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c99:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 df                	mov    %ebx,%edi
  800ca6:	89 de                	mov    %ebx,%esi
  800ca8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caa:	85 c0                	test   %eax,%eax
  800cac:	7e 28                	jle    800cd6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cb9:	00 
  800cba:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc9:	00 
  800cca:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800cd1:	e8 26 f4 ff ff       	call   8000fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd6:	83 c4 2c             	add    $0x2c,%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 28                	jle    800d29 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d05:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d14:	00 
  800d15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1c:	00 
  800d1d:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d24:	e8 d3 f3 ff ff       	call   8000fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d29:	83 c4 2c             	add    $0x2c,%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7e 28                	jle    800d7c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d58:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d5f:	00 
  800d60:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800d67:	00 
  800d68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6f:	00 
  800d70:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800d77:	e8 80 f3 ff ff       	call   8000fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7c:	83 c4 2c             	add    $0x2c,%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	57                   	push   %edi
  800d88:	56                   	push   %esi
  800d89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	be 00 00 00 00       	mov    $0x0,%esi
  800d8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 cb                	mov    %ecx,%ebx
  800dbf:	89 cf                	mov    %ecx,%edi
  800dc1:	89 ce                	mov    %ecx,%esi
  800dc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	7e 28                	jle    800df1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dd4:	00 
  800dd5:	c7 44 24 08 5f 29 80 	movl   $0x80295f,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 7c 29 80 00 	movl   $0x80297c,(%esp)
  800dec:	e8 0b f3 ff ff       	call   8000fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df1:	83 c4 2c             	add    $0x2c,%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    
  800df9:	00 00                	add    %al,(%eax)
	...

00800dfc <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  800e08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e0f:	00 
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	89 04 24             	mov    %eax,(%esp)
  800e16:	e8 49 0e 00 00       	call   801c64 <open>
  800e1b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	0f 88 8c 05 00 00    	js     8013b5 <spawn+0x5b9>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  800e29:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800e30:	00 
  800e31:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  800e41:	89 04 24             	mov    %eax,(%esp)
  800e44:	e8 d5 09 00 00       	call   80181e <readn>
  800e49:	3d 00 02 00 00       	cmp    $0x200,%eax
  800e4e:	75 0c                	jne    800e5c <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  800e50:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  800e57:	45 4c 46 
  800e5a:	74 3b                	je     800e97 <spawn+0x9b>
		close(fd);
  800e5c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  800e62:	89 04 24             	mov    %eax,(%esp)
  800e65:	e8 c0 07 00 00       	call   80162a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  800e6a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  800e71:	46 
  800e72:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  800e78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7c:	c7 04 24 8a 29 80 00 	movl   $0x80298a,(%esp)
  800e83:	e8 6c f3 ff ff       	call   8001f4 <cprintf>
		return -E_NOT_EXEC;
  800e88:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  800e8f:	ff ff ff 
  800e92:	e9 2a 05 00 00       	jmp    8013c1 <spawn+0x5c5>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e97:	ba 07 00 00 00       	mov    $0x7,%edx
  800e9c:	89 d0                	mov    %edx,%eax
  800e9e:	cd 30                	int    $0x30
  800ea0:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  800ea6:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  800eac:	85 c0                	test   %eax,%eax
  800eae:	0f 88 0d 05 00 00    	js     8013c1 <spawn+0x5c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  800eb4:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ec0:	c1 e0 07             	shl    $0x7,%eax
  800ec3:	29 d0                	sub    %edx,%eax
  800ec5:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  800ecb:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  800ed1:	b9 11 00 00 00       	mov    $0x11,%ecx
  800ed6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  800ed8:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  800ede:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800ee4:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  800ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ef1:	eb 0d                	jmp    800f00 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  800ef3:	89 04 24             	mov    %eax,(%esp)
  800ef6:	e8 71 f8 ff ff       	call   80076c <strlen>
  800efb:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800eff:	46                   	inc    %esi
  800f00:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  800f02:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800f09:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	75 e3                	jne    800ef3 <spawn+0xf7>
  800f10:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  800f16:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  800f1c:	bf 00 10 40 00       	mov    $0x401000,%edi
  800f21:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  800f23:	89 f8                	mov    %edi,%eax
  800f25:	83 e0 fc             	and    $0xfffffffc,%eax
  800f28:	f7 d2                	not    %edx
  800f2a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800f2d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  800f33:	89 d0                	mov    %edx,%eax
  800f35:	83 e8 08             	sub    $0x8,%eax
  800f38:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  800f3d:	0f 86 8f 04 00 00    	jbe    8013d2 <spawn+0x5d6>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f43:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800f52:	00 
  800f53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5a:	e8 32 fc ff ff       	call   800b91 <sys_page_alloc>
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	0f 88 70 04 00 00    	js     8013d7 <spawn+0x5db>
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6c:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  800f72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f75:	eb 2e                	jmp    800fa5 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  800f77:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  800f7d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  800f83:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  800f86:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8d:	89 3c 24             	mov    %edi,(%esp)
  800f90:	e8 0a f8 ff ff       	call   80079f <strcpy>
		string_store += strlen(argv[i]) + 1;
  800f95:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	e8 cc f7 ff ff       	call   80076c <strlen>
  800fa0:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  800fa4:	43                   	inc    %ebx
  800fa5:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  800fab:	7c ca                	jl     800f77 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  800fad:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  800fb3:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  800fb9:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  800fc0:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  800fc6:	74 24                	je     800fec <spawn+0x1f0>
  800fc8:	c7 44 24 0c 2c 2a 80 	movl   $0x802a2c,0xc(%esp)
  800fcf:	00 
  800fd0:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  800fdf:	00 
  800fe0:	c7 04 24 b9 29 80 00 	movl   $0x8029b9,(%esp)
  800fe7:	e8 10 f1 ff ff       	call   8000fc <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  800fec:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  800ff2:	2d 00 30 80 11       	sub    $0x11803000,%eax
  800ff7:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  800ffd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801000:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801006:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801009:	89 d0                	mov    %edx,%eax
  80100b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801010:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801016:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80101d:	00 
  80101e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801025:	ee 
  801026:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80102c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801030:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801037:	00 
  801038:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103f:	e8 a1 fb ff ff       	call   800be5 <sys_page_map>
  801044:	89 c3                	mov    %eax,%ebx
  801046:	85 c0                	test   %eax,%eax
  801048:	78 1a                	js     801064 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80104a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801051:	00 
  801052:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801059:	e8 da fb ff ff       	call   800c38 <sys_page_unmap>
  80105e:	89 c3                	mov    %eax,%ebx
  801060:	85 c0                	test   %eax,%eax
  801062:	79 1f                	jns    801083 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801064:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80106b:	00 
  80106c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801073:	e8 c0 fb ff ff       	call   800c38 <sys_page_unmap>
	return r;
  801078:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80107e:	e9 3e 03 00 00       	jmp    8013c1 <spawn+0x5c5>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801083:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801089:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  80108f:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801095:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80109c:	00 00 00 
  80109f:	e9 bb 01 00 00       	jmp    80125f <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  8010a4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8010aa:	83 38 01             	cmpl   $0x1,(%eax)
  8010ad:	0f 85 9f 01 00 00    	jne    801252 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	8b 40 18             	mov    0x18(%eax),%eax
  8010b8:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  8010bb:	83 f8 01             	cmp    $0x1,%eax
  8010be:	19 c0                	sbb    %eax,%eax
  8010c0:	83 e0 fe             	and    $0xfffffffe,%eax
  8010c3:	83 c0 07             	add    $0x7,%eax
  8010c6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8010cc:	8b 52 04             	mov    0x4(%edx),%edx
  8010cf:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  8010d5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8010db:	8b 40 10             	mov    0x10(%eax),%eax
  8010de:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8010e4:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  8010ea:	8b 52 14             	mov    0x14(%edx),%edx
  8010ed:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  8010f3:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8010f9:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8010fc:	89 f8                	mov    %edi,%eax
  8010fe:	25 ff 0f 00 00       	and    $0xfff,%eax
  801103:	74 16                	je     80111b <spawn+0x31f>
		va -= i;
  801105:	29 c7                	sub    %eax,%edi
		memsz += i;
  801107:	01 c2                	add    %eax,%edx
  801109:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  80110f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801115:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801120:	e9 1f 01 00 00       	jmp    801244 <spawn+0x448>
		if (i >= filesz) {
  801125:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  80112b:	77 2b                	ja     801158 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80112d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801133:	89 54 24 08          	mov    %edx,0x8(%esp)
  801137:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80113b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801141:	89 04 24             	mov    %eax,(%esp)
  801144:	e8 48 fa ff ff       	call   800b91 <sys_page_alloc>
  801149:	85 c0                	test   %eax,%eax
  80114b:	0f 89 e7 00 00 00    	jns    801238 <spawn+0x43c>
  801151:	89 c6                	mov    %eax,%esi
  801153:	e9 39 02 00 00       	jmp    801391 <spawn+0x595>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801158:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80115f:	00 
  801160:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801167:	00 
  801168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116f:	e8 1d fa ff ff       	call   800b91 <sys_page_alloc>
  801174:	85 c0                	test   %eax,%eax
  801176:	0f 88 0b 02 00 00    	js     801387 <spawn+0x58b>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80117c:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801182:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801184:	89 44 24 04          	mov    %eax,0x4(%esp)
  801188:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80118e:	89 04 24             	mov    %eax,(%esp)
  801191:	e8 5e 07 00 00       	call   8018f4 <seek>
  801196:	85 c0                	test   %eax,%eax
  801198:	0f 88 ed 01 00 00    	js     80138b <spawn+0x58f>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80119e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8011a4:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8011a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8011ab:	76 05                	jbe    8011b2 <spawn+0x3b6>
  8011ad:	b8 00 10 00 00       	mov    $0x1000,%eax
  8011b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b6:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8011bd:	00 
  8011be:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8011c4:	89 04 24             	mov    %eax,(%esp)
  8011c7:	e8 52 06 00 00       	call   80181e <readn>
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	0f 88 bb 01 00 00    	js     80138f <spawn+0x593>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8011d4:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8011da:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011de:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011e2:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8011e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ec:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8011f3:	00 
  8011f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011fb:	e8 e5 f9 ff ff       	call   800be5 <sys_page_map>
  801200:	85 c0                	test   %eax,%eax
  801202:	79 20                	jns    801224 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801204:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801208:	c7 44 24 08 c5 29 80 	movl   $0x8029c5,0x8(%esp)
  80120f:	00 
  801210:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801217:	00 
  801218:	c7 04 24 b9 29 80 00 	movl   $0x8029b9,(%esp)
  80121f:	e8 d8 ee ff ff       	call   8000fc <_panic>
			sys_page_unmap(0, UTEMP);
  801224:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80122b:	00 
  80122c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801233:	e8 00 fa ff ff       	call   800c38 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801238:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80123e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801244:	89 de                	mov    %ebx,%esi
  801246:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  80124c:	0f 82 d3 fe ff ff    	jb     801125 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801252:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801258:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  80125f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801266:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  80126c:	0f 8c 32 fe ff ff    	jl     8010a4 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801272:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801278:	89 04 24             	mov    %eax,(%esp)
  80127b:	e8 aa 03 00 00       	call   80162a <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801280:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  801285:	89 f0                	mov    %esi,%eax
  801287:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  80128a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801291:	a8 01                	test   $0x1,%al
  801293:	0f 84 82 00 00 00    	je     80131b <spawn+0x51f>
  801299:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012a0:	a8 01                	test   $0x1,%al
  8012a2:	74 77                	je     80131b <spawn+0x51f>
  8012a4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012ab:	f6 c4 04             	test   $0x4,%ah
  8012ae:	74 6b                	je     80131b <spawn+0x51f>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  8012b0:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8012b7:	89 f3                	mov    %esi,%ebx
  8012b9:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  8012bc:	e8 92 f8 ff ff       	call   800b53 <sys_getenvid>
  8012c1:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  8012c7:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8012cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012cf:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  8012d5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012dd:	89 04 24             	mov    %eax,(%esp)
  8012e0:	e8 00 f9 ff ff       	call   800be5 <sys_page_map>
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	79 32                	jns    80131b <spawn+0x51f>
  8012e9:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	c7 04 24 54 2a 80 00 	movl   $0x802a54,(%esp)
  8012f6:	e8 f9 ee ff ff       	call   8001f4 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  8012fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012ff:	c7 44 24 08 e2 29 80 	movl   $0x8029e2,0x8(%esp)
  801306:	00 
  801307:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80130e:	00 
  80130f:	c7 04 24 b9 29 80 00 	movl   $0x8029b9,(%esp)
  801316:	e8 e1 ed ff ff       	call   8000fc <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  80131b:	46                   	inc    %esi
  80131c:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801322:	0f 85 5d ff ff ff    	jne    801285 <spawn+0x489>
  801328:	e9 b2 00 00 00       	jmp    8013df <spawn+0x5e3>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80132d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801331:	c7 44 24 08 f8 29 80 	movl   $0x8029f8,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 b9 29 80 00 	movl   $0x8029b9,(%esp)
  801348:	e8 af ed ff ff       	call   8000fc <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80134d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801354:	00 
  801355:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 28 f9 ff ff       	call   800c8b <sys_env_set_status>
  801363:	85 c0                	test   %eax,%eax
  801365:	79 5a                	jns    8013c1 <spawn+0x5c5>
		panic("sys_env_set_status: %e", r);
  801367:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80136b:	c7 44 24 08 12 2a 80 	movl   $0x802a12,0x8(%esp)
  801372:	00 
  801373:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 b9 29 80 00 	movl   $0x8029b9,(%esp)
  801382:	e8 75 ed ff ff       	call   8000fc <_panic>
  801387:	89 c6                	mov    %eax,%esi
  801389:	eb 06                	jmp    801391 <spawn+0x595>
  80138b:	89 c6                	mov    %eax,%esi
  80138d:	eb 02                	jmp    801391 <spawn+0x595>
  80138f:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801391:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	e8 62 f7 ff ff       	call   800b01 <sys_env_destroy>
	close(fd);
  80139f:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8013a5:	89 04 24             	mov    %eax,(%esp)
  8013a8:	e8 7d 02 00 00       	call   80162a <close>
	return r;
  8013ad:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  8013b3:	eb 0c                	jmp    8013c1 <spawn+0x5c5>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8013b5:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8013bb:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8013c1:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8013c7:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5e                   	pop    %esi
  8013cf:	5f                   	pop    %edi
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8013d2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  8013d7:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8013dd:	eb e2                	jmp    8013c1 <spawn+0x5c5>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8013df:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8013ef:	89 04 24             	mov    %eax,(%esp)
  8013f2:	e8 e7 f8 ff ff       	call   800cde <sys_env_set_trapframe>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	0f 89 4e ff ff ff    	jns    80134d <spawn+0x551>
  8013ff:	e9 29 ff ff ff       	jmp    80132d <spawn+0x531>

00801404 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	57                   	push   %edi
  801408:	56                   	push   %esi
  801409:	53                   	push   %ebx
  80140a:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  80140d:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801410:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801415:	eb 03                	jmp    80141a <spawnl+0x16>
		argc++;
  801417:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801418:	89 d0                	mov    %edx,%eax
  80141a:	8d 50 04             	lea    0x4(%eax),%edx
  80141d:	83 38 00             	cmpl   $0x0,(%eax)
  801420:	75 f5                	jne    801417 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801422:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801429:	83 e0 f0             	and    $0xfffffff0,%eax
  80142c:	29 c4                	sub    %eax,%esp
  80142e:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801432:	83 e7 f0             	and    $0xfffffff0,%edi
  801435:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801437:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143a:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  80143c:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801443:	00 

	va_start(vl, arg0);
  801444:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
  80144c:	eb 09                	jmp    801457 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  80144e:	40                   	inc    %eax
  80144f:	8b 1a                	mov    (%edx),%ebx
  801451:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801454:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801457:	39 c8                	cmp    %ecx,%eax
  801459:	75 f3                	jne    80144e <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80145b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80145f:	8b 45 08             	mov    0x8(%ebp),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 92 f9 ff ff       	call   800dfc <spawn>
}
  80146a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    
	...

00801474 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	05 00 00 00 30       	add    $0x30000000,%eax
  80147f:	c1 e8 0c             	shr    $0xc,%eax
}
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	89 04 24             	mov    %eax,(%esp)
  801490:	e8 df ff ff ff       	call   801474 <fd2num>
  801495:	05 20 00 0d 00       	add    $0xd0020,%eax
  80149a:	c1 e0 0c             	shl    $0xc,%eax
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014a6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014ab:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014ad:	89 c2                	mov    %eax,%edx
  8014af:	c1 ea 16             	shr    $0x16,%edx
  8014b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014b9:	f6 c2 01             	test   $0x1,%dl
  8014bc:	74 11                	je     8014cf <fd_alloc+0x30>
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	c1 ea 0c             	shr    $0xc,%edx
  8014c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014ca:	f6 c2 01             	test   $0x1,%dl
  8014cd:	75 09                	jne    8014d8 <fd_alloc+0x39>
			*fd_store = fd;
  8014cf:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d6:	eb 17                	jmp    8014ef <fd_alloc+0x50>
  8014d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014e2:	75 c7                	jne    8014ab <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014ef:	5b                   	pop    %ebx
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014f8:	83 f8 1f             	cmp    $0x1f,%eax
  8014fb:	77 36                	ja     801533 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014fd:	05 00 00 0d 00       	add    $0xd0000,%eax
  801502:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801505:	89 c2                	mov    %eax,%edx
  801507:	c1 ea 16             	shr    $0x16,%edx
  80150a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801511:	f6 c2 01             	test   $0x1,%dl
  801514:	74 24                	je     80153a <fd_lookup+0x48>
  801516:	89 c2                	mov    %eax,%edx
  801518:	c1 ea 0c             	shr    $0xc,%edx
  80151b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801522:	f6 c2 01             	test   $0x1,%dl
  801525:	74 1a                	je     801541 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801527:	8b 55 0c             	mov    0xc(%ebp),%edx
  80152a:	89 02                	mov    %eax,(%edx)
	return 0;
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
  801531:	eb 13                	jmp    801546 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801533:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801538:	eb 0c                	jmp    801546 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80153a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80153f:	eb 05                	jmp    801546 <fd_lookup+0x54>
  801541:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801546:	5d                   	pop    %ebp
  801547:	c3                   	ret    

00801548 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 14             	sub    $0x14,%esp
  80154f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
  80155a:	eb 0e                	jmp    80156a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80155c:	39 08                	cmp    %ecx,(%eax)
  80155e:	75 09                	jne    801569 <dev_lookup+0x21>
			*dev = devtab[i];
  801560:	89 03                	mov    %eax,(%ebx)
			return 0;
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
  801567:	eb 33                	jmp    80159c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801569:	42                   	inc    %edx
  80156a:	8b 04 95 fc 2a 80 00 	mov    0x802afc(,%edx,4),%eax
  801571:	85 c0                	test   %eax,%eax
  801573:	75 e7                	jne    80155c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801575:	a1 04 40 80 00       	mov    0x804004,%eax
  80157a:	8b 40 48             	mov    0x48(%eax),%eax
  80157d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801581:	89 44 24 04          	mov    %eax,0x4(%esp)
  801585:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  80158c:	e8 63 ec ff ff       	call   8001f4 <cprintf>
	*dev = 0;
  801591:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801597:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80159c:	83 c4 14             	add    $0x14,%esp
  80159f:	5b                   	pop    %ebx
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 30             	sub    $0x30,%esp
  8015aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ad:	8a 45 0c             	mov    0xc(%ebp),%al
  8015b0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015b3:	89 34 24             	mov    %esi,(%esp)
  8015b6:	e8 b9 fe ff ff       	call   801474 <fd2num>
  8015bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015c2:	89 04 24             	mov    %eax,(%esp)
  8015c5:	e8 28 ff ff ff       	call   8014f2 <fd_lookup>
  8015ca:	89 c3                	mov    %eax,%ebx
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	78 05                	js     8015d5 <fd_close+0x33>
	    || fd != fd2)
  8015d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015d3:	74 0d                	je     8015e2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8015d5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015d9:	75 46                	jne    801621 <fd_close+0x7f>
  8015db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e0:	eb 3f                	jmp    801621 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e9:	8b 06                	mov    (%esi),%eax
  8015eb:	89 04 24             	mov    %eax,(%esp)
  8015ee:	e8 55 ff ff ff       	call   801548 <dev_lookup>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 18                	js     801611 <fd_close+0x6f>
		if (dev->dev_close)
  8015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fc:	8b 40 10             	mov    0x10(%eax),%eax
  8015ff:	85 c0                	test   %eax,%eax
  801601:	74 09                	je     80160c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801603:	89 34 24             	mov    %esi,(%esp)
  801606:	ff d0                	call   *%eax
  801608:	89 c3                	mov    %eax,%ebx
  80160a:	eb 05                	jmp    801611 <fd_close+0x6f>
		else
			r = 0;
  80160c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801611:	89 74 24 04          	mov    %esi,0x4(%esp)
  801615:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161c:	e8 17 f6 ff ff       	call   800c38 <sys_page_unmap>
	return r;
}
  801621:	89 d8                	mov    %ebx,%eax
  801623:	83 c4 30             	add    $0x30,%esp
  801626:	5b                   	pop    %ebx
  801627:	5e                   	pop    %esi
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801630:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	8b 45 08             	mov    0x8(%ebp),%eax
  80163a:	89 04 24             	mov    %eax,(%esp)
  80163d:	e8 b0 fe ff ff       	call   8014f2 <fd_lookup>
  801642:	85 c0                	test   %eax,%eax
  801644:	78 13                	js     801659 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801646:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80164d:	00 
  80164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801651:	89 04 24             	mov    %eax,(%esp)
  801654:	e8 49 ff ff ff       	call   8015a2 <fd_close>
}
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <close_all>:

void
close_all(void)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	53                   	push   %ebx
  80165f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801662:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801667:	89 1c 24             	mov    %ebx,(%esp)
  80166a:	e8 bb ff ff ff       	call   80162a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80166f:	43                   	inc    %ebx
  801670:	83 fb 20             	cmp    $0x20,%ebx
  801673:	75 f2                	jne    801667 <close_all+0xc>
		close(i);
}
  801675:	83 c4 14             	add    $0x14,%esp
  801678:	5b                   	pop    %ebx
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	83 ec 4c             	sub    $0x4c,%esp
  801684:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801687:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80168a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	89 04 24             	mov    %eax,(%esp)
  801694:	e8 59 fe ff ff       	call   8014f2 <fd_lookup>
  801699:	89 c3                	mov    %eax,%ebx
  80169b:	85 c0                	test   %eax,%eax
  80169d:	0f 88 e1 00 00 00    	js     801784 <dup+0x109>
		return r;
	close(newfdnum);
  8016a3:	89 3c 24             	mov    %edi,(%esp)
  8016a6:	e8 7f ff ff ff       	call   80162a <close>

	newfd = INDEX2FD(newfdnum);
  8016ab:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016b1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b7:	89 04 24             	mov    %eax,(%esp)
  8016ba:	e8 c5 fd ff ff       	call   801484 <fd2data>
  8016bf:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016c1:	89 34 24             	mov    %esi,(%esp)
  8016c4:	e8 bb fd ff ff       	call   801484 <fd2data>
  8016c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016cc:	89 d8                	mov    %ebx,%eax
  8016ce:	c1 e8 16             	shr    $0x16,%eax
  8016d1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016d8:	a8 01                	test   $0x1,%al
  8016da:	74 46                	je     801722 <dup+0xa7>
  8016dc:	89 d8                	mov    %ebx,%eax
  8016de:	c1 e8 0c             	shr    $0xc,%eax
  8016e1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016e8:	f6 c2 01             	test   $0x1,%dl
  8016eb:	74 35                	je     801722 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801700:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801704:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170b:	00 
  80170c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801717:	e8 c9 f4 ff ff       	call   800be5 <sys_page_map>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 3b                	js     80175d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801725:	89 c2                	mov    %eax,%edx
  801727:	c1 ea 0c             	shr    $0xc,%edx
  80172a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801731:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801737:	89 54 24 10          	mov    %edx,0x10(%esp)
  80173b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80173f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801746:	00 
  801747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801752:	e8 8e f4 ff ff       	call   800be5 <sys_page_map>
  801757:	89 c3                	mov    %eax,%ebx
  801759:	85 c0                	test   %eax,%eax
  80175b:	79 25                	jns    801782 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80175d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801768:	e8 cb f4 ff ff       	call   800c38 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80176d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801770:	89 44 24 04          	mov    %eax,0x4(%esp)
  801774:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177b:	e8 b8 f4 ff ff       	call   800c38 <sys_page_unmap>
	return r;
  801780:	eb 02                	jmp    801784 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801782:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801784:	89 d8                	mov    %ebx,%eax
  801786:	83 c4 4c             	add    $0x4c,%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5f                   	pop    %edi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	53                   	push   %ebx
  801792:	83 ec 24             	sub    $0x24,%esp
  801795:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801798:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179f:	89 1c 24             	mov    %ebx,(%esp)
  8017a2:	e8 4b fd ff ff       	call   8014f2 <fd_lookup>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 6d                	js     801818 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b5:	8b 00                	mov    (%eax),%eax
  8017b7:	89 04 24             	mov    %eax,(%esp)
  8017ba:	e8 89 fd ff ff       	call   801548 <dev_lookup>
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 55                	js     801818 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c6:	8b 50 08             	mov    0x8(%eax),%edx
  8017c9:	83 e2 03             	and    $0x3,%edx
  8017cc:	83 fa 01             	cmp    $0x1,%edx
  8017cf:	75 23                	jne    8017f4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017d6:	8b 40 48             	mov    0x48(%eax),%eax
  8017d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e1:	c7 04 24 c1 2a 80 00 	movl   $0x802ac1,(%esp)
  8017e8:	e8 07 ea ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  8017ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f2:	eb 24                	jmp    801818 <read+0x8a>
	}
	if (!dev->dev_read)
  8017f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f7:	8b 52 08             	mov    0x8(%edx),%edx
  8017fa:	85 d2                	test   %edx,%edx
  8017fc:	74 15                	je     801813 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801801:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801808:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80180c:	89 04 24             	mov    %eax,(%esp)
  80180f:	ff d2                	call   *%edx
  801811:	eb 05                	jmp    801818 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801813:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801818:	83 c4 24             	add    $0x24,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	53                   	push   %ebx
  801824:	83 ec 1c             	sub    $0x1c,%esp
  801827:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80182d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801832:	eb 23                	jmp    801857 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801834:	89 f0                	mov    %esi,%eax
  801836:	29 d8                	sub    %ebx,%eax
  801838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	01 d8                	add    %ebx,%eax
  801841:	89 44 24 04          	mov    %eax,0x4(%esp)
  801845:	89 3c 24             	mov    %edi,(%esp)
  801848:	e8 41 ff ff ff       	call   80178e <read>
		if (m < 0)
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 10                	js     801861 <readn+0x43>
			return m;
		if (m == 0)
  801851:	85 c0                	test   %eax,%eax
  801853:	74 0a                	je     80185f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801855:	01 c3                	add    %eax,%ebx
  801857:	39 f3                	cmp    %esi,%ebx
  801859:	72 d9                	jb     801834 <readn+0x16>
  80185b:	89 d8                	mov    %ebx,%eax
  80185d:	eb 02                	jmp    801861 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80185f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801861:	83 c4 1c             	add    $0x1c,%esp
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5f                   	pop    %edi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 24             	sub    $0x24,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187a:	89 1c 24             	mov    %ebx,(%esp)
  80187d:	e8 70 fc ff ff       	call   8014f2 <fd_lookup>
  801882:	85 c0                	test   %eax,%eax
  801884:	78 68                	js     8018ee <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801886:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801890:	8b 00                	mov    (%eax),%eax
  801892:	89 04 24             	mov    %eax,(%esp)
  801895:	e8 ae fc ff ff       	call   801548 <dev_lookup>
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 50                	js     8018ee <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80189e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018a5:	75 23                	jne    8018ca <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ac:	8b 40 48             	mov    0x48(%eax),%eax
  8018af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b7:	c7 04 24 dd 2a 80 00 	movl   $0x802add,(%esp)
  8018be:	e8 31 e9 ff ff       	call   8001f4 <cprintf>
		return -E_INVAL;
  8018c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c8:	eb 24                	jmp    8018ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d0:	85 d2                	test   %edx,%edx
  8018d2:	74 15                	je     8018e9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	ff d2                	call   *%edx
  8018e7:	eb 05                	jmp    8018ee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018ee:	83 c4 24             	add    $0x24,%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	89 04 24             	mov    %eax,(%esp)
  801907:	e8 e6 fb ff ff       	call   8014f2 <fd_lookup>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 0e                	js     80191e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801913:	8b 55 0c             	mov    0xc(%ebp),%edx
  801916:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 24             	sub    $0x24,%esp
  801927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	89 1c 24             	mov    %ebx,(%esp)
  801934:	e8 b9 fb ff ff       	call   8014f2 <fd_lookup>
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 61                	js     80199e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80193d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801940:	89 44 24 04          	mov    %eax,0x4(%esp)
  801944:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801947:	8b 00                	mov    (%eax),%eax
  801949:	89 04 24             	mov    %eax,(%esp)
  80194c:	e8 f7 fb ff ff       	call   801548 <dev_lookup>
  801951:	85 c0                	test   %eax,%eax
  801953:	78 49                	js     80199e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801955:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801958:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80195c:	75 23                	jne    801981 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80195e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801963:	8b 40 48             	mov    0x48(%eax),%eax
  801966:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80196a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196e:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  801975:	e8 7a e8 ff ff       	call   8001f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80197a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80197f:	eb 1d                	jmp    80199e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801981:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801984:	8b 52 18             	mov    0x18(%edx),%edx
  801987:	85 d2                	test   %edx,%edx
  801989:	74 0e                	je     801999 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80198b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80198e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801992:	89 04 24             	mov    %eax,(%esp)
  801995:	ff d2                	call   *%edx
  801997:	eb 05                	jmp    80199e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801999:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80199e:	83 c4 24             	add    $0x24,%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 24             	sub    $0x24,%esp
  8019ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	89 04 24             	mov    %eax,(%esp)
  8019bb:	e8 32 fb ff ff       	call   8014f2 <fd_lookup>
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 52                	js     801a16 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ce:	8b 00                	mov    (%eax),%eax
  8019d0:	89 04 24             	mov    %eax,(%esp)
  8019d3:	e8 70 fb ff ff       	call   801548 <dev_lookup>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	78 3a                	js     801a16 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e3:	74 2c                	je     801a11 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ef:	00 00 00 
	stat->st_isdir = 0;
  8019f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f9:	00 00 00 
	stat->st_dev = dev;
  8019fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a06:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a09:	89 14 24             	mov    %edx,(%esp)
  801a0c:	ff 50 14             	call   *0x14(%eax)
  801a0f:	eb 05                	jmp    801a16 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a11:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a16:	83 c4 24             	add    $0x24,%esp
  801a19:	5b                   	pop    %ebx
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	56                   	push   %esi
  801a20:	53                   	push   %ebx
  801a21:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a2b:	00 
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	89 04 24             	mov    %eax,(%esp)
  801a32:	e8 2d 02 00 00       	call   801c64 <open>
  801a37:	89 c3                	mov    %eax,%ebx
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	78 1b                	js     801a58 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a44:	89 1c 24             	mov    %ebx,(%esp)
  801a47:	e8 58 ff ff ff       	call   8019a4 <fstat>
  801a4c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a4e:	89 1c 24             	mov    %ebx,(%esp)
  801a51:	e8 d4 fb ff ff       	call   80162a <close>
	return r;
  801a56:	89 f3                	mov    %esi,%ebx
}
  801a58:	89 d8                	mov    %ebx,%eax
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	5b                   	pop    %ebx
  801a5e:	5e                   	pop    %esi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    
  801a61:	00 00                	add    %al,(%eax)
	...

00801a64 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	83 ec 10             	sub    $0x10,%esp
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a70:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a77:	75 11                	jne    801a8a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a79:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a80:	e8 6e 08 00 00       	call   8022f3 <ipc_find_env>
  801a85:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a8a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a91:	00 
  801a92:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a99:	00 
  801a9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a9e:	a1 00 40 80 00       	mov    0x804000,%eax
  801aa3:	89 04 24             	mov    %eax,(%esp)
  801aa6:	e8 da 07 00 00       	call   802285 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801aab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ab2:	00 
  801ab3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ab7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abe:	e8 59 07 00 00       	call   80221c <ipc_recv>
}
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ade:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae8:	b8 02 00 00 00       	mov    $0x2,%eax
  801aed:	e8 72 ff ff ff       	call   801a64 <fsipc>
}
  801af2:	c9                   	leave  
  801af3:	c3                   	ret    

00801af4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	8b 40 0c             	mov    0xc(%eax),%eax
  801b00:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b05:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b0f:	e8 50 ff ff ff       	call   801a64 <fsipc>
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	53                   	push   %ebx
  801b1a:	83 ec 14             	sub    $0x14,%esp
  801b1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
  801b23:	8b 40 0c             	mov    0xc(%eax),%eax
  801b26:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b30:	b8 05 00 00 00       	mov    $0x5,%eax
  801b35:	e8 2a ff ff ff       	call   801a64 <fsipc>
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 2b                	js     801b69 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b45:	00 
  801b46:	89 1c 24             	mov    %ebx,(%esp)
  801b49:	e8 51 ec ff ff       	call   80079f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b4e:	a1 80 50 80 00       	mov    0x805080,%eax
  801b53:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b59:	a1 84 50 80 00       	mov    0x805084,%eax
  801b5e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b69:	83 c4 14             	add    $0x14,%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 18             	sub    $0x18,%esp
  801b75:	8b 55 10             	mov    0x10(%ebp),%edx
  801b78:	89 d0                	mov    %edx,%eax
  801b7a:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801b80:	76 05                	jbe    801b87 <devfile_write+0x18>
  801b82:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b87:	8b 55 08             	mov    0x8(%ebp),%edx
  801b8a:	8b 52 0c             	mov    0xc(%edx),%edx
  801b8d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b93:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801baa:	e8 69 ed ff ff       	call   800918 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801baf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb4:	b8 04 00 00 00       	mov    $0x4,%eax
  801bb9:	e8 a6 fe ff ff       	call   801a64 <fsipc>
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 10             	sub    $0x10,%esp
  801bc8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bce:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bd6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  801be1:	b8 03 00 00 00       	mov    $0x3,%eax
  801be6:	e8 79 fe ff ff       	call   801a64 <fsipc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 6a                	js     801c5b <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bf1:	39 c6                	cmp    %eax,%esi
  801bf3:	73 24                	jae    801c19 <devfile_read+0x59>
  801bf5:	c7 44 24 0c 0c 2b 80 	movl   $0x802b0c,0xc(%esp)
  801bfc:	00 
  801bfd:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  801c04:	00 
  801c05:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c0c:	00 
  801c0d:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  801c14:	e8 e3 e4 ff ff       	call   8000fc <_panic>
	assert(r <= PGSIZE);
  801c19:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c1e:	7e 24                	jle    801c44 <devfile_read+0x84>
  801c20:	c7 44 24 0c 1e 2b 80 	movl   $0x802b1e,0xc(%esp)
  801c27:	00 
  801c28:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  801c2f:	00 
  801c30:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c37:	00 
  801c38:	c7 04 24 13 2b 80 00 	movl   $0x802b13,(%esp)
  801c3f:	e8 b8 e4 ff ff       	call   8000fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c48:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c4f:	00 
  801c50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c53:	89 04 24             	mov    %eax,(%esp)
  801c56:	e8 bd ec ff ff       	call   800918 <memmove>
	return r;
}
  801c5b:	89 d8                	mov    %ebx,%eax
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	56                   	push   %esi
  801c68:	53                   	push   %ebx
  801c69:	83 ec 20             	sub    $0x20,%esp
  801c6c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c6f:	89 34 24             	mov    %esi,(%esp)
  801c72:	e8 f5 ea ff ff       	call   80076c <strlen>
  801c77:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c7c:	7f 60                	jg     801cde <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c81:	89 04 24             	mov    %eax,(%esp)
  801c84:	e8 16 f8 ff ff       	call   80149f <fd_alloc>
  801c89:	89 c3                	mov    %eax,%ebx
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 54                	js     801ce3 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c93:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c9a:	e8 00 eb ff ff       	call   80079f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ca7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801caa:	b8 01 00 00 00       	mov    $0x1,%eax
  801caf:	e8 b0 fd ff ff       	call   801a64 <fsipc>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	79 15                	jns    801ccf <open+0x6b>
		fd_close(fd, 0);
  801cba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cc1:	00 
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 d5 f8 ff ff       	call   8015a2 <fd_close>
		return r;
  801ccd:	eb 14                	jmp    801ce3 <open+0x7f>
	}

	return fd2num(fd);
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	89 04 24             	mov    %eax,(%esp)
  801cd5:	e8 9a f7 ff ff       	call   801474 <fd2num>
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	eb 05                	jmp    801ce3 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cde:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ce3:	89 d8                	mov    %ebx,%eax
  801ce5:	83 c4 20             	add    $0x20,%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5e                   	pop    %esi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf7:	b8 08 00 00 00       	mov    $0x8,%eax
  801cfc:	e8 63 fd ff ff       	call   801a64 <fsipc>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    
	...

00801d04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	56                   	push   %esi
  801d08:	53                   	push   %ebx
  801d09:	83 ec 10             	sub    $0x10,%esp
  801d0c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d12:	89 04 24             	mov    %eax,(%esp)
  801d15:	e8 6a f7 ff ff       	call   801484 <fd2data>
  801d1a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d1c:	c7 44 24 04 2a 2b 80 	movl   $0x802b2a,0x4(%esp)
  801d23:	00 
  801d24:	89 34 24             	mov    %esi,(%esp)
  801d27:	e8 73 ea ff ff       	call   80079f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801d2f:	2b 03                	sub    (%ebx),%eax
  801d31:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d37:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d3e:	00 00 00 
	stat->st_dev = &devpipe;
  801d41:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801d48:	30 80 00 
	return 0;
}
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	53                   	push   %ebx
  801d5b:	83 ec 14             	sub    $0x14,%esp
  801d5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d6c:	e8 c7 ee ff ff       	call   800c38 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d71:	89 1c 24             	mov    %ebx,(%esp)
  801d74:	e8 0b f7 ff ff       	call   801484 <fd2data>
  801d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d84:	e8 af ee ff ff       	call   800c38 <sys_page_unmap>
}
  801d89:	83 c4 14             	add    $0x14,%esp
  801d8c:	5b                   	pop    %ebx
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	57                   	push   %edi
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	83 ec 2c             	sub    $0x2c,%esp
  801d98:	89 c7                	mov    %eax,%edi
  801d9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d9d:	a1 04 40 80 00       	mov    0x804004,%eax
  801da2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801da5:	89 3c 24             	mov    %edi,(%esp)
  801da8:	e8 8b 05 00 00       	call   802338 <pageref>
  801dad:	89 c6                	mov    %eax,%esi
  801daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 7e 05 00 00       	call   802338 <pageref>
  801dba:	39 c6                	cmp    %eax,%esi
  801dbc:	0f 94 c0             	sete   %al
  801dbf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dc2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801dc8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801dcb:	39 cb                	cmp    %ecx,%ebx
  801dcd:	75 08                	jne    801dd7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801dcf:	83 c4 2c             	add    $0x2c,%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5f                   	pop    %edi
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801dd7:	83 f8 01             	cmp    $0x1,%eax
  801dda:	75 c1                	jne    801d9d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ddc:	8b 42 58             	mov    0x58(%edx),%eax
  801ddf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801de6:	00 
  801de7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801deb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801def:	c7 04 24 31 2b 80 00 	movl   $0x802b31,(%esp)
  801df6:	e8 f9 e3 ff ff       	call   8001f4 <cprintf>
  801dfb:	eb a0                	jmp    801d9d <_pipeisclosed+0xe>

00801dfd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	83 ec 1c             	sub    $0x1c,%esp
  801e06:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e09:	89 34 24             	mov    %esi,(%esp)
  801e0c:	e8 73 f6 ff ff       	call   801484 <fd2data>
  801e11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e13:	bf 00 00 00 00       	mov    $0x0,%edi
  801e18:	eb 3c                	jmp    801e56 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e1a:	89 da                	mov    %ebx,%edx
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	e8 6c ff ff ff       	call   801d8f <_pipeisclosed>
  801e23:	85 c0                	test   %eax,%eax
  801e25:	75 38                	jne    801e5f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e27:	e8 46 ed ff ff       	call   800b72 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2f:	8b 13                	mov    (%ebx),%edx
  801e31:	83 c2 20             	add    $0x20,%edx
  801e34:	39 d0                	cmp    %edx,%eax
  801e36:	73 e2                	jae    801e1a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e46:	79 05                	jns    801e4d <devpipe_write+0x50>
  801e48:	4a                   	dec    %edx
  801e49:	83 ca e0             	or     $0xffffffe0,%edx
  801e4c:	42                   	inc    %edx
  801e4d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e51:	40                   	inc    %eax
  801e52:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e55:	47                   	inc    %edi
  801e56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e59:	75 d1                	jne    801e2c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e5b:	89 f8                	mov    %edi,%eax
  801e5d:	eb 05                	jmp    801e64 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e5f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	57                   	push   %edi
  801e70:	56                   	push   %esi
  801e71:	53                   	push   %ebx
  801e72:	83 ec 1c             	sub    $0x1c,%esp
  801e75:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e78:	89 3c 24             	mov    %edi,(%esp)
  801e7b:	e8 04 f6 ff ff       	call   801484 <fd2data>
  801e80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e82:	be 00 00 00 00       	mov    $0x0,%esi
  801e87:	eb 3a                	jmp    801ec3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e89:	85 f6                	test   %esi,%esi
  801e8b:	74 04                	je     801e91 <devpipe_read+0x25>
				return i;
  801e8d:	89 f0                	mov    %esi,%eax
  801e8f:	eb 40                	jmp    801ed1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e91:	89 da                	mov    %ebx,%edx
  801e93:	89 f8                	mov    %edi,%eax
  801e95:	e8 f5 fe ff ff       	call   801d8f <_pipeisclosed>
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	75 2e                	jne    801ecc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e9e:	e8 cf ec ff ff       	call   800b72 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ea3:	8b 03                	mov    (%ebx),%eax
  801ea5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ea8:	74 df                	je     801e89 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eaa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801eaf:	79 05                	jns    801eb6 <devpipe_read+0x4a>
  801eb1:	48                   	dec    %eax
  801eb2:	83 c8 e0             	or     $0xffffffe0,%eax
  801eb5:	40                   	inc    %eax
  801eb6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801eba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ec0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ec2:	46                   	inc    %esi
  801ec3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ec6:	75 db                	jne    801ea3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ec8:	89 f0                	mov    %esi,%eax
  801eca:	eb 05                	jmp    801ed1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ed1:	83 c4 1c             	add    $0x1c,%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	57                   	push   %edi
  801edd:	56                   	push   %esi
  801ede:	53                   	push   %ebx
  801edf:	83 ec 3c             	sub    $0x3c,%esp
  801ee2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ee5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ee8:	89 04 24             	mov    %eax,(%esp)
  801eeb:	e8 af f5 ff ff       	call   80149f <fd_alloc>
  801ef0:	89 c3                	mov    %eax,%ebx
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	0f 88 45 01 00 00    	js     80203f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f01:	00 
  801f02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f10:	e8 7c ec ff ff       	call   800b91 <sys_page_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	0f 88 20 01 00 00    	js     80203f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f1f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f22:	89 04 24             	mov    %eax,(%esp)
  801f25:	e8 75 f5 ff ff       	call   80149f <fd_alloc>
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	0f 88 f8 00 00 00    	js     80202c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f34:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f3b:	00 
  801f3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4a:	e8 42 ec ff ff       	call   800b91 <sys_page_alloc>
  801f4f:	89 c3                	mov    %eax,%ebx
  801f51:	85 c0                	test   %eax,%eax
  801f53:	0f 88 d3 00 00 00    	js     80202c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f5c:	89 04 24             	mov    %eax,(%esp)
  801f5f:	e8 20 f5 ff ff       	call   801484 <fd2data>
  801f64:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f6d:	00 
  801f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f79:	e8 13 ec ff ff       	call   800b91 <sys_page_alloc>
  801f7e:	89 c3                	mov    %eax,%ebx
  801f80:	85 c0                	test   %eax,%eax
  801f82:	0f 88 91 00 00 00    	js     802019 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 f1 f4 ff ff       	call   801484 <fd2data>
  801f93:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f9a:	00 
  801f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fa6:	00 
  801fa7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb2:	e8 2e ec ff ff       	call   800be5 <sys_page_map>
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 4c                	js     802009 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fcb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fd2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801fd8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fdb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fe0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fe7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 82 f4 ff ff       	call   801474 <fd2num>
  801ff2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ff4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ff7:	89 04 24             	mov    %eax,(%esp)
  801ffa:	e8 75 f4 ff ff       	call   801474 <fd2num>
  801fff:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802002:	bb 00 00 00 00       	mov    $0x0,%ebx
  802007:	eb 36                	jmp    80203f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802009:	89 74 24 04          	mov    %esi,0x4(%esp)
  80200d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802014:	e8 1f ec ff ff       	call   800c38 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802019:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80201c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802020:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802027:	e8 0c ec ff ff       	call   800c38 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80202c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80202f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802033:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203a:	e8 f9 eb ff ff       	call   800c38 <sys_page_unmap>
    err:
	return r;
}
  80203f:	89 d8                	mov    %ebx,%eax
  802041:	83 c4 3c             	add    $0x3c,%esp
  802044:	5b                   	pop    %ebx
  802045:	5e                   	pop    %esi
  802046:	5f                   	pop    %edi
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80204f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802052:	89 44 24 04          	mov    %eax,0x4(%esp)
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	89 04 24             	mov    %eax,(%esp)
  80205c:	e8 91 f4 ff ff       	call   8014f2 <fd_lookup>
  802061:	85 c0                	test   %eax,%eax
  802063:	78 15                	js     80207a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	89 04 24             	mov    %eax,(%esp)
  80206b:	e8 14 f4 ff ff       	call   801484 <fd2data>
	return _pipeisclosed(fd, p);
  802070:	89 c2                	mov    %eax,%edx
  802072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802075:	e8 15 fd ff ff       	call   801d8f <_pipeisclosed>
}
  80207a:	c9                   	leave  
  80207b:	c3                   	ret    

0080207c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80207f:	b8 00 00 00 00       	mov    $0x0,%eax
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80208c:	c7 44 24 04 49 2b 80 	movl   $0x802b49,0x4(%esp)
  802093:	00 
  802094:	8b 45 0c             	mov    0xc(%ebp),%eax
  802097:	89 04 24             	mov    %eax,(%esp)
  80209a:	e8 00 e7 ff ff       	call   80079f <strcpy>
	return 0;
}
  80209f:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a4:	c9                   	leave  
  8020a5:	c3                   	ret    

008020a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	57                   	push   %edi
  8020aa:	56                   	push   %esi
  8020ab:	53                   	push   %ebx
  8020ac:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020bd:	eb 30                	jmp    8020ef <devcons_write+0x49>
		m = n - tot;
  8020bf:	8b 75 10             	mov    0x10(%ebp),%esi
  8020c2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8020c4:	83 fe 7f             	cmp    $0x7f,%esi
  8020c7:	76 05                	jbe    8020ce <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8020c9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8020d2:	03 45 0c             	add    0xc(%ebp),%eax
  8020d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d9:	89 3c 24             	mov    %edi,(%esp)
  8020dc:	e8 37 e8 ff ff       	call   800918 <memmove>
		sys_cputs(buf, m);
  8020e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020e5:	89 3c 24             	mov    %edi,(%esp)
  8020e8:	e8 d7 e9 ff ff       	call   800ac4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020ed:	01 f3                	add    %esi,%ebx
  8020ef:	89 d8                	mov    %ebx,%eax
  8020f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020f4:	72 c9                	jb     8020bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020fc:	5b                   	pop    %ebx
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    

00802101 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802101:	55                   	push   %ebp
  802102:	89 e5                	mov    %esp,%ebp
  802104:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802107:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80210b:	75 07                	jne    802114 <devcons_read+0x13>
  80210d:	eb 25                	jmp    802134 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80210f:	e8 5e ea ff ff       	call   800b72 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802114:	e8 c9 e9 ff ff       	call   800ae2 <sys_cgetc>
  802119:	85 c0                	test   %eax,%eax
  80211b:	74 f2                	je     80210f <devcons_read+0xe>
  80211d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80211f:	85 c0                	test   %eax,%eax
  802121:	78 1d                	js     802140 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802123:	83 f8 04             	cmp    $0x4,%eax
  802126:	74 13                	je     80213b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212b:	88 10                	mov    %dl,(%eax)
	return 1;
  80212d:	b8 01 00 00 00       	mov    $0x1,%eax
  802132:	eb 0c                	jmp    802140 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802134:	b8 00 00 00 00       	mov    $0x0,%eax
  802139:	eb 05                	jmp    802140 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80213b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802140:	c9                   	leave  
  802141:	c3                   	ret    

00802142 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802148:	8b 45 08             	mov    0x8(%ebp),%eax
  80214b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80214e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802155:	00 
  802156:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 63 e9 ff ff       	call   800ac4 <sys_cputs>
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <getchar>:

int
getchar(void)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802169:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802170:	00 
  802171:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802174:	89 44 24 04          	mov    %eax,0x4(%esp)
  802178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217f:	e8 0a f6 ff ff       	call   80178e <read>
	if (r < 0)
  802184:	85 c0                	test   %eax,%eax
  802186:	78 0f                	js     802197 <getchar+0x34>
		return r;
	if (r < 1)
  802188:	85 c0                	test   %eax,%eax
  80218a:	7e 06                	jle    802192 <getchar+0x2f>
		return -E_EOF;
	return c;
  80218c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802190:	eb 05                	jmp    802197 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802192:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802197:	c9                   	leave  
  802198:	c3                   	ret    

00802199 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802199:	55                   	push   %ebp
  80219a:	89 e5                	mov    %esp,%ebp
  80219c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80219f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	89 04 24             	mov    %eax,(%esp)
  8021ac:	e8 41 f3 ff ff       	call   8014f2 <fd_lookup>
  8021b1:	85 c0                	test   %eax,%eax
  8021b3:	78 11                	js     8021c6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021be:	39 10                	cmp    %edx,(%eax)
  8021c0:	0f 94 c0             	sete   %al
  8021c3:	0f b6 c0             	movzbl %al,%eax
}
  8021c6:	c9                   	leave  
  8021c7:	c3                   	ret    

008021c8 <opencons>:

int
opencons(void)
{
  8021c8:	55                   	push   %ebp
  8021c9:	89 e5                	mov    %esp,%ebp
  8021cb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 c6 f2 ff ff       	call   80149f <fd_alloc>
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	78 3c                	js     802219 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021e4:	00 
  8021e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f3:	e8 99 e9 ff ff       	call   800b91 <sys_page_alloc>
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	78 1d                	js     802219 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802205:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802207:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802211:	89 04 24             	mov    %eax,(%esp)
  802214:	e8 5b f2 ff ff       	call   801474 <fd2num>
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    
	...

0080221c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	56                   	push   %esi
  802220:	53                   	push   %ebx
  802221:	83 ec 10             	sub    $0x10,%esp
  802224:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  80222d:	85 c0                	test   %eax,%eax
  80222f:	75 05                	jne    802236 <ipc_recv+0x1a>
  802231:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802236:	89 04 24             	mov    %eax,(%esp)
  802239:	e8 69 eb ff ff       	call   800da7 <sys_ipc_recv>
	if (from_env_store != NULL)
  80223e:	85 db                	test   %ebx,%ebx
  802240:	74 0b                	je     80224d <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802242:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802248:	8b 52 74             	mov    0x74(%edx),%edx
  80224b:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  80224d:	85 f6                	test   %esi,%esi
  80224f:	74 0b                	je     80225c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802251:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802257:	8b 52 78             	mov    0x78(%edx),%edx
  80225a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  80225c:	85 c0                	test   %eax,%eax
  80225e:	79 16                	jns    802276 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802260:	85 db                	test   %ebx,%ebx
  802262:	74 06                	je     80226a <ipc_recv+0x4e>
			*from_env_store = 0;
  802264:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80226a:	85 f6                	test   %esi,%esi
  80226c:	74 10                	je     80227e <ipc_recv+0x62>
			*perm_store = 0;
  80226e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802274:	eb 08                	jmp    80227e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802276:	a1 04 40 80 00       	mov    0x804004,%eax
  80227b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80227e:	83 c4 10             	add    $0x10,%esp
  802281:	5b                   	pop    %ebx
  802282:	5e                   	pop    %esi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    

00802285 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802285:	55                   	push   %ebp
  802286:	89 e5                	mov    %esp,%ebp
  802288:	57                   	push   %edi
  802289:	56                   	push   %esi
  80228a:	53                   	push   %ebx
  80228b:	83 ec 1c             	sub    $0x1c,%esp
  80228e:	8b 75 08             	mov    0x8(%ebp),%esi
  802291:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802294:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802297:	eb 2a                	jmp    8022c3 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802299:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80229c:	74 20                	je     8022be <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80229e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022a2:	c7 44 24 08 58 2b 80 	movl   $0x802b58,0x8(%esp)
  8022a9:	00 
  8022aa:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8022b1:	00 
  8022b2:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  8022b9:	e8 3e de ff ff       	call   8000fc <_panic>
		sys_yield();
  8022be:	e8 af e8 ff ff       	call   800b72 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8022c3:	85 db                	test   %ebx,%ebx
  8022c5:	75 07                	jne    8022ce <ipc_send+0x49>
  8022c7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022cc:	eb 02                	jmp    8022d0 <ipc_send+0x4b>
  8022ce:	89 d8                	mov    %ebx,%eax
  8022d0:	8b 55 14             	mov    0x14(%ebp),%edx
  8022d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022df:	89 34 24             	mov    %esi,(%esp)
  8022e2:	e8 9d ea ff ff       	call   800d84 <sys_ipc_try_send>
  8022e7:	85 c0                	test   %eax,%eax
  8022e9:	78 ae                	js     802299 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8022eb:	83 c4 1c             	add    $0x1c,%esp
  8022ee:	5b                   	pop    %ebx
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    

008022f3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	53                   	push   %ebx
  8022f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8022fa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022ff:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802306:	89 c2                	mov    %eax,%edx
  802308:	c1 e2 07             	shl    $0x7,%edx
  80230b:	29 ca                	sub    %ecx,%edx
  80230d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802313:	8b 52 50             	mov    0x50(%edx),%edx
  802316:	39 da                	cmp    %ebx,%edx
  802318:	75 0f                	jne    802329 <ipc_find_env+0x36>
			return envs[i].env_id;
  80231a:	c1 e0 07             	shl    $0x7,%eax
  80231d:	29 c8                	sub    %ecx,%eax
  80231f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802324:	8b 40 40             	mov    0x40(%eax),%eax
  802327:	eb 0c                	jmp    802335 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802329:	40                   	inc    %eax
  80232a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80232f:	75 ce                	jne    8022ff <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802331:	66 b8 00 00          	mov    $0x0,%ax
}
  802335:	5b                   	pop    %ebx
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    

00802338 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80233e:	89 c2                	mov    %eax,%edx
  802340:	c1 ea 16             	shr    $0x16,%edx
  802343:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80234a:	f6 c2 01             	test   $0x1,%dl
  80234d:	74 1e                	je     80236d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80234f:	c1 e8 0c             	shr    $0xc,%eax
  802352:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802359:	a8 01                	test   $0x1,%al
  80235b:	74 17                	je     802374 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80235d:	c1 e8 0c             	shr    $0xc,%eax
  802360:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802367:	ef 
  802368:	0f b7 c0             	movzwl %ax,%eax
  80236b:	eb 0c                	jmp    802379 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80236d:	b8 00 00 00 00       	mov    $0x0,%eax
  802372:	eb 05                	jmp    802379 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802374:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
	...

0080237c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80237c:	55                   	push   %ebp
  80237d:	57                   	push   %edi
  80237e:	56                   	push   %esi
  80237f:	83 ec 10             	sub    $0x10,%esp
  802382:	8b 74 24 20          	mov    0x20(%esp),%esi
  802386:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80238a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80238e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802392:	89 cd                	mov    %ecx,%ebp
  802394:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802398:	85 c0                	test   %eax,%eax
  80239a:	75 2c                	jne    8023c8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80239c:	39 f9                	cmp    %edi,%ecx
  80239e:	77 68                	ja     802408 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023a0:	85 c9                	test   %ecx,%ecx
  8023a2:	75 0b                	jne    8023af <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8023a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023a9:	31 d2                	xor    %edx,%edx
  8023ab:	f7 f1                	div    %ecx
  8023ad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8023af:	31 d2                	xor    %edx,%edx
  8023b1:	89 f8                	mov    %edi,%eax
  8023b3:	f7 f1                	div    %ecx
  8023b5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023b7:	89 f0                	mov    %esi,%eax
  8023b9:	f7 f1                	div    %ecx
  8023bb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023bd:	89 f0                	mov    %esi,%eax
  8023bf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023c1:	83 c4 10             	add    $0x10,%esp
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023c8:	39 f8                	cmp    %edi,%eax
  8023ca:	77 2c                	ja     8023f8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023cc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8023cf:	83 f6 1f             	xor    $0x1f,%esi
  8023d2:	75 4c                	jne    802420 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023d4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023d6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023db:	72 0a                	jb     8023e7 <__udivdi3+0x6b>
  8023dd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023e1:	0f 87 ad 00 00 00    	ja     802494 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023e7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023ec:	89 f0                	mov    %esi,%eax
  8023ee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023f0:	83 c4 10             	add    $0x10,%esp
  8023f3:	5e                   	pop    %esi
  8023f4:	5f                   	pop    %edi
  8023f5:	5d                   	pop    %ebp
  8023f6:	c3                   	ret    
  8023f7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023f8:	31 ff                	xor    %edi,%edi
  8023fa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023fc:	89 f0                	mov    %esi,%eax
  8023fe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802400:	83 c4 10             	add    $0x10,%esp
  802403:	5e                   	pop    %esi
  802404:	5f                   	pop    %edi
  802405:	5d                   	pop    %ebp
  802406:	c3                   	ret    
  802407:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802408:	89 fa                	mov    %edi,%edx
  80240a:	89 f0                	mov    %esi,%eax
  80240c:	f7 f1                	div    %ecx
  80240e:	89 c6                	mov    %eax,%esi
  802410:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802412:	89 f0                	mov    %esi,%eax
  802414:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802416:	83 c4 10             	add    $0x10,%esp
  802419:	5e                   	pop    %esi
  80241a:	5f                   	pop    %edi
  80241b:	5d                   	pop    %ebp
  80241c:	c3                   	ret    
  80241d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802420:	89 f1                	mov    %esi,%ecx
  802422:	d3 e0                	shl    %cl,%eax
  802424:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802428:	b8 20 00 00 00       	mov    $0x20,%eax
  80242d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80242f:	89 ea                	mov    %ebp,%edx
  802431:	88 c1                	mov    %al,%cl
  802433:	d3 ea                	shr    %cl,%edx
  802435:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802439:	09 ca                	or     %ecx,%edx
  80243b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80243f:	89 f1                	mov    %esi,%ecx
  802441:	d3 e5                	shl    %cl,%ebp
  802443:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802447:	89 fd                	mov    %edi,%ebp
  802449:	88 c1                	mov    %al,%cl
  80244b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80244d:	89 fa                	mov    %edi,%edx
  80244f:	89 f1                	mov    %esi,%ecx
  802451:	d3 e2                	shl    %cl,%edx
  802453:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802457:	88 c1                	mov    %al,%cl
  802459:	d3 ef                	shr    %cl,%edi
  80245b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80245d:	89 f8                	mov    %edi,%eax
  80245f:	89 ea                	mov    %ebp,%edx
  802461:	f7 74 24 08          	divl   0x8(%esp)
  802465:	89 d1                	mov    %edx,%ecx
  802467:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802469:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80246d:	39 d1                	cmp    %edx,%ecx
  80246f:	72 17                	jb     802488 <__udivdi3+0x10c>
  802471:	74 09                	je     80247c <__udivdi3+0x100>
  802473:	89 fe                	mov    %edi,%esi
  802475:	31 ff                	xor    %edi,%edi
  802477:	e9 41 ff ff ff       	jmp    8023bd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80247c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802480:	89 f1                	mov    %esi,%ecx
  802482:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802484:	39 c2                	cmp    %eax,%edx
  802486:	73 eb                	jae    802473 <__udivdi3+0xf7>
		{
		  q0--;
  802488:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80248b:	31 ff                	xor    %edi,%edi
  80248d:	e9 2b ff ff ff       	jmp    8023bd <__udivdi3+0x41>
  802492:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802494:	31 f6                	xor    %esi,%esi
  802496:	e9 22 ff ff ff       	jmp    8023bd <__udivdi3+0x41>
	...

0080249c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80249c:	55                   	push   %ebp
  80249d:	57                   	push   %edi
  80249e:	56                   	push   %esi
  80249f:	83 ec 20             	sub    $0x20,%esp
  8024a2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8024a6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024aa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8024ae:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8024b2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8024b6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8024ba:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8024bc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024be:	85 ed                	test   %ebp,%ebp
  8024c0:	75 16                	jne    8024d8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8024c2:	39 f1                	cmp    %esi,%ecx
  8024c4:	0f 86 a6 00 00 00    	jbe    802570 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024ca:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8024cc:	89 d0                	mov    %edx,%eax
  8024ce:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024d0:	83 c4 20             	add    $0x20,%esp
  8024d3:	5e                   	pop    %esi
  8024d4:	5f                   	pop    %edi
  8024d5:	5d                   	pop    %ebp
  8024d6:	c3                   	ret    
  8024d7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024d8:	39 f5                	cmp    %esi,%ebp
  8024da:	0f 87 ac 00 00 00    	ja     80258c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024e0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8024e3:	83 f0 1f             	xor    $0x1f,%eax
  8024e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024ea:	0f 84 a8 00 00 00    	je     802598 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024f0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024f4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024f6:	bf 20 00 00 00       	mov    $0x20,%edi
  8024fb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8024ff:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802503:	89 f9                	mov    %edi,%ecx
  802505:	d3 e8                	shr    %cl,%eax
  802507:	09 e8                	or     %ebp,%eax
  802509:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80250d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802511:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802515:	d3 e0                	shl    %cl,%eax
  802517:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80251b:	89 f2                	mov    %esi,%edx
  80251d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80251f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802523:	d3 e0                	shl    %cl,%eax
  802525:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802529:	8b 44 24 14          	mov    0x14(%esp),%eax
  80252d:	89 f9                	mov    %edi,%ecx
  80252f:	d3 e8                	shr    %cl,%eax
  802531:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802533:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802535:	89 f2                	mov    %esi,%edx
  802537:	f7 74 24 18          	divl   0x18(%esp)
  80253b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80253d:	f7 64 24 0c          	mull   0xc(%esp)
  802541:	89 c5                	mov    %eax,%ebp
  802543:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802545:	39 d6                	cmp    %edx,%esi
  802547:	72 67                	jb     8025b0 <__umoddi3+0x114>
  802549:	74 75                	je     8025c0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80254b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80254f:	29 e8                	sub    %ebp,%eax
  802551:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802553:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802557:	d3 e8                	shr    %cl,%eax
  802559:	89 f2                	mov    %esi,%edx
  80255b:	89 f9                	mov    %edi,%ecx
  80255d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80255f:	09 d0                	or     %edx,%eax
  802561:	89 f2                	mov    %esi,%edx
  802563:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802567:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802569:	83 c4 20             	add    $0x20,%esp
  80256c:	5e                   	pop    %esi
  80256d:	5f                   	pop    %edi
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802570:	85 c9                	test   %ecx,%ecx
  802572:	75 0b                	jne    80257f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802574:	b8 01 00 00 00       	mov    $0x1,%eax
  802579:	31 d2                	xor    %edx,%edx
  80257b:	f7 f1                	div    %ecx
  80257d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80257f:	89 f0                	mov    %esi,%eax
  802581:	31 d2                	xor    %edx,%edx
  802583:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802585:	89 f8                	mov    %edi,%eax
  802587:	e9 3e ff ff ff       	jmp    8024ca <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80258c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80258e:	83 c4 20             	add    $0x20,%esp
  802591:	5e                   	pop    %esi
  802592:	5f                   	pop    %edi
  802593:	5d                   	pop    %ebp
  802594:	c3                   	ret    
  802595:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802598:	39 f5                	cmp    %esi,%ebp
  80259a:	72 04                	jb     8025a0 <__umoddi3+0x104>
  80259c:	39 f9                	cmp    %edi,%ecx
  80259e:	77 06                	ja     8025a6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025a0:	89 f2                	mov    %esi,%edx
  8025a2:	29 cf                	sub    %ecx,%edi
  8025a4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8025a6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025a8:	83 c4 20             	add    $0x20,%esp
  8025ab:	5e                   	pop    %esi
  8025ac:	5f                   	pop    %edi
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    
  8025af:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025b0:	89 d1                	mov    %edx,%ecx
  8025b2:	89 c5                	mov    %eax,%ebp
  8025b4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8025b8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8025bc:	eb 8d                	jmp    80254b <__umoddi3+0xaf>
  8025be:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025c0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8025c4:	72 ea                	jb     8025b0 <__umoddi3+0x114>
  8025c6:	89 f1                	mov    %esi,%ecx
  8025c8:	eb 81                	jmp    80254b <__umoddi3+0xaf>
