
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 66 12 00 00       	call   8012a8 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 4f 0b 00 00       	call   800ba3 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 20 17 80 00 	movl   $0x801720,(%esp)
  800063:	e8 dc 01 00 00       	call   800244 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 33 0b 00 00       	call   800ba3 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 3a 17 80 00 	movl   $0x80173a,(%esp)
  80007f:	e8 c0 01 00 00       	call   800244 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 8e 12 00 00       	call   801335 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 0a 12 00 00       	call   8012cc <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 c7 0a 00 00       	call   800ba3 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 50 17 80 00 	movl   $0x801750,(%esp)
  8000fa:	e8 45 01 00 00       	call   800244 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 36                	je     80013f <umain+0x10b>
			return;
		++val;
  800109:	40                   	inc    %eax
  80010a:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80010f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800126:	00 
  800127:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 03 12 00 00       	call   801335 <ipc_send>
		if (val == 10)
  800132:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  800139:	0f 85 68 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013f:	83 c4 4c             	add    $0x4c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 48 0a 00 00       	call   800ba3 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	c1 e0 07             	shl    $0x7,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 f6                	test   %esi,%esi
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 03                	mov    (%ebx),%eax
  800173:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800178:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017c:	89 34 24             	mov    %esi,(%esp)
  80017f:	e8 b0 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019d:	e8 af 09 00 00       	call   800b51 <sys_env_destroy>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 14             	sub    $0x14,%esp
  8001ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ae:	8b 03                	mov    (%ebx),%eax
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001b7:	40                   	inc    %eax
  8001b8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bf:	75 19                	jne    8001da <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c8:	00 
  8001c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 40 09 00 00       	call   800b14 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001da:	ff 43 04             	incl   0x4(%ebx)
}
  8001dd:	83 c4 14             	add    $0x14,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	8b 45 0c             	mov    0xc(%ebp),%eax
  800203:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 a4 01 80 00 	movl   $0x8001a4,(%esp)
  80021f:	e8 82 01 00 00       	call   8003a6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800224:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	e8 d8 08 00 00       	call   800b14 <sys_cputs>

	return b.cnt;
}
  80023c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	89 04 24             	mov    %eax,(%esp)
  800257:	e8 87 ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 3c             	sub    $0x3c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d7                	mov    %edx,%edi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80027d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800280:	85 c0                	test   %eax,%eax
  800282:	75 08                	jne    80028c <printnum+0x2c>
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028a:	77 57                	ja     8002e3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80028c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800290:	4b                   	dec    %ebx
  800291:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ab:	00 
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 04 24             	mov    %eax,(%esp)
  8002b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b9:	e8 0e 12 00 00       	call   8014cc <__udivdi3>
  8002be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c6:	89 04 24             	mov    %eax,(%esp)
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	89 fa                	mov    %edi,%edx
  8002cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d2:	e8 89 ff ff ff       	call   800260 <printnum>
  8002d7:	eb 0f                	jmp    8002e8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dd:	89 34 24             	mov    %esi,(%esp)
  8002e0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e3:	4b                   	dec    %ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f f1                	jg     8002d9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ec:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fe:	00 
  8002ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	e8 db 12 00 00       	call   8015ec <__umoddi3>
  800311:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800315:	0f be 80 80 17 80 00 	movsbl 0x801780(%eax),%eax
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800322:	83 c4 3c             	add    $0x3c,%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032d:	83 fa 01             	cmp    $0x1,%edx
  800330:	7e 0e                	jle    800340 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 08             	lea    0x8(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	8b 52 04             	mov    0x4(%edx),%edx
  80033e:	eb 22                	jmp    800362 <getuint+0x38>
	else if (lflag)
  800340:	85 d2                	test   %edx,%edx
  800342:	74 10                	je     800354 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	eb 0e                	jmp    800362 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800354:	8b 10                	mov    (%eax),%edx
  800356:	8d 4a 04             	lea    0x4(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 02                	mov    (%edx),%eax
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036d:	8b 10                	mov    (%eax),%edx
  80036f:	3b 50 04             	cmp    0x4(%eax),%edx
  800372:	73 08                	jae    80037c <sprintputch+0x18>
		*b->buf++ = ch;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	88 0a                	mov    %cl,(%edx)
  800379:	42                   	inc    %edx
  80037a:	89 10                	mov    %edx,(%eax)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038b:	8b 45 10             	mov    0x10(%ebp),%eax
  80038e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800392:	8b 45 0c             	mov    0xc(%ebp),%eax
  800395:	89 44 24 04          	mov    %eax,0x4(%esp)
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 02 00 00 00       	call   8003a6 <vprintfmt>
	va_end(ap);
}
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	57                   	push   %edi
  8003aa:	56                   	push   %esi
  8003ab:	53                   	push   %ebx
  8003ac:	83 ec 4c             	sub    $0x4c,%esp
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 6b 03 00 00    	je     80072a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c3:	89 04 24             	mov    %eax,(%esp)
  8003c6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 06             	movzbl (%esi),%eax
  8003cc:	46                   	inc    %esi
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	75 e5                	jne    8003b7 <vprintfmt+0x11>
  8003d2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003d6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003dd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ee:	eb 26                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003f7:	eb 1d                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003fc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800400:	eb 14                	jmp    800416 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800405:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80040c:	eb 08                	jmp    800416 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80040e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800411:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	0f b6 06             	movzbl (%esi),%eax
  800419:	8d 56 01             	lea    0x1(%esi),%edx
  80041c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041f:	8a 16                	mov    (%esi),%dl
  800421:	83 ea 23             	sub    $0x23,%edx
  800424:	80 fa 55             	cmp    $0x55,%dl
  800427:	0f 87 e1 02 00 00    	ja     80070e <vprintfmt+0x368>
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	ff 24 95 c0 18 80 00 	jmp    *0x8018c0(,%edx,4)
  800437:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800442:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800446:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800449:	8d 50 d0             	lea    -0x30(%eax),%edx
  80044c:	83 fa 09             	cmp    $0x9,%edx
  80044f:	77 2a                	ja     80047b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800451:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800452:	eb eb                	jmp    80043f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800462:	eb 17                	jmp    80047b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800464:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800468:	78 98                	js     800402 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80046d:	eb a7                	jmp    800416 <vprintfmt+0x70>
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800472:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800479:	eb 9b                	jmp    800416 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047f:	79 95                	jns    800416 <vprintfmt+0x70>
  800481:	eb 8b                	jmp    80040e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800483:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800487:	eb 8d                	jmp    800416 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800489:	8b 45 14             	mov    0x14(%ebp),%eax
  80048c:	8d 50 04             	lea    0x4(%eax),%edx
  80048f:	89 55 14             	mov    %edx,0x14(%ebp)
  800492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a1:	e9 23 ff ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	79 02                	jns    8004b7 <vprintfmt+0x111>
  8004b5:	f7 d8                	neg    %eax
  8004b7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 11             	cmp    $0x11,%eax
  8004bc:	7f 0b                	jg     8004c9 <vprintfmt+0x123>
  8004be:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	75 23                	jne    8004ec <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004cd:	c7 44 24 08 98 17 80 	movl   $0x801798,0x8(%esp)
  8004d4:	00 
  8004d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 9a fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e7:	e9 dd fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f0:	c7 44 24 08 a1 17 80 	movl   $0x8017a1,0x8(%esp)
  8004f7:	00 
  8004f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ff:	89 14 24             	mov    %edx,(%esp)
  800502:	e8 77 fe ff ff       	call   80037e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050a:	e9 ba fe ff ff       	jmp    8003c9 <vprintfmt+0x23>
  80050f:	89 f9                	mov    %edi,%ecx
  800511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800514:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 30                	mov    (%eax),%esi
  800522:	85 f6                	test   %esi,%esi
  800524:	75 05                	jne    80052b <vprintfmt+0x185>
				p = "(null)";
  800526:	be 91 17 80 00       	mov    $0x801791,%esi
			if (width > 0 && padc != '-')
  80052b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052f:	0f 8e 84 00 00 00    	jle    8005b9 <vprintfmt+0x213>
  800535:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800539:	74 7e                	je     8005b9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053f:	89 34 24             	mov    %esi,(%esp)
  800542:	e8 8b 02 00 00       	call   8007d2 <strnlen>
  800547:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054a:	29 c2                	sub    %eax,%edx
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80054f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800553:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800556:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800559:	89 de                	mov    %ebx,%esi
  80055b:	89 d3                	mov    %edx,%ebx
  80055d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 0b                	jmp    80056c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	89 3c 24             	mov    %edi,(%esp)
  800568:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	4b                   	dec    %ebx
  80056c:	85 db                	test   %ebx,%ebx
  80056e:	7f f1                	jg     800561 <vprintfmt+0x1bb>
  800570:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800573:	89 f3                	mov    %esi,%ebx
  800575:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057b:	85 c0                	test   %eax,%eax
  80057d:	79 05                	jns    800584 <vprintfmt+0x1de>
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800587:	29 c2                	sub    %eax,%edx
  800589:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058c:	eb 2b                	jmp    8005b9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80058e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800592:	74 18                	je     8005ac <vprintfmt+0x206>
  800594:	8d 50 e0             	lea    -0x20(%eax),%edx
  800597:	83 fa 5e             	cmp    $0x5e,%edx
  80059a:	76 10                	jbe    8005ac <vprintfmt+0x206>
					putch('?', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
  8005aa:	eb 0a                	jmp    8005b6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b9:	0f be 06             	movsbl (%esi),%eax
  8005bc:	46                   	inc    %esi
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	74 21                	je     8005e2 <vprintfmt+0x23c>
  8005c1:	85 ff                	test   %edi,%edi
  8005c3:	78 c9                	js     80058e <vprintfmt+0x1e8>
  8005c5:	4f                   	dec    %edi
  8005c6:	79 c6                	jns    80058e <vprintfmt+0x1e8>
  8005c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cb:	89 de                	mov    %ebx,%esi
  8005cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005dd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x244>
  8005e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e5:	89 de                	mov    %ebx,%esi
  8005e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x22c>
  8005ee:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f6:	e9 ce fd ff ff       	jmp    8003c9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fb:	83 f9 01             	cmp    $0x1,%ecx
  8005fe:	7e 10                	jle    800610 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 08             	lea    0x8(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	8b 78 04             	mov    0x4(%eax),%edi
  80060e:	eb 26                	jmp    800636 <vprintfmt+0x290>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	74 12                	je     800626 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 30                	mov    (%eax),%esi
  80061f:	89 f7                	mov    %esi,%edi
  800621:	c1 ff 1f             	sar    $0x1f,%edi
  800624:	eb 10                	jmp    800636 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 30                	mov    (%eax),%esi
  800631:	89 f7                	mov    %esi,%edi
  800633:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	85 ff                	test   %edi,%edi
  800638:	78 0a                	js     800644 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	e9 8c 00 00 00       	jmp    8006d0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	f7 de                	neg    %esi
  800654:	83 d7 00             	adc    $0x0,%edi
  800657:	f7 df                	neg    %edi
			}
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	eb 70                	jmp    8006d0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	89 ca                	mov    %ecx,%edx
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 c0 fc ff ff       	call   80032a <getuint>
  80066a:	89 c6                	mov    %eax,%esi
  80066c:	89 d7                	mov    %edx,%edi
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800673:	eb 5b                	jmp    8006d0 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800675:	89 ca                	mov    %ecx,%edx
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 ab fc ff ff       	call   80032a <getuint>
  80067f:	89 c6                	mov    %eax,%esi
  800681:	89 d7                	mov    %edx,%edi
			base = 8;
  800683:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800688:	eb 46                	jmp    8006d0 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bb:	eb 13                	jmp    8006d0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 63 fc ff ff       	call   80032a <getuint>
  8006c7:	89 c6                	mov    %eax,%esi
  8006c9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e3:	89 34 24             	mov    %esi,(%esp)
  8006e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ea:	89 da                	mov    %ebx,%edx
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	e8 6c fb ff ff       	call   800260 <printnum>
			break;
  8006f4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f7:	e9 cd fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800706:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800709:	e9 bb fc ff ff       	jmp    8003c9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800712:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	eb 01                	jmp    80071f <vprintfmt+0x379>
  80071e:	4e                   	dec    %esi
  80071f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800723:	75 f9                	jne    80071e <vprintfmt+0x378>
  800725:	e9 9f fc ff ff       	jmp    8003c9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80072a:	83 c4 4c             	add    $0x4c,%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 28             	sub    $0x28,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 30                	je     800783 <vsnprintf+0x51>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 33                	jle    80078a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076c:	c7 04 24 64 03 80 00 	movl   $0x800364,(%esp)
  800773:	e8 2e fc ff ff       	call   8003a6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	eb 0c                	jmp    80078f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800788:	eb 05                	jmp    80078f <vsnprintf+0x5d>
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079e:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	e8 7b ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    
  8007b9:	00 00                	add    %al,(%eax)
	...

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 01                	jmp    8007ca <strlen+0xe>
		n++;
  8007c9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f9                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	eb 01                	jmp    8007e3 <strnlen+0x11>
		n++;
  8007e2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 06                	je     8007ed <strnlen+0x1b>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f5                	jne    8007e2 <strnlen+0x10>
		n++;
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800801:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800804:	42                   	inc    %edx
  800805:	84 c9                	test   %cl,%cl
  800807:	75 f5                	jne    8007fe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800809:	5b                   	pop    %ebx
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	89 1c 24             	mov    %ebx,(%esp)
  800819:	e8 9e ff ff ff       	call   8007bc <strlen>
	strcpy(dst + len, src);
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	89 54 24 04          	mov    %edx,0x4(%esp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	89 04 24             	mov    %eax,(%esp)
  80082a:	e8 c0 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	83 c4 08             	add    $0x8,%esp
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084a:	eb 0c                	jmp    800858 <strncpy+0x21>
		*dst++ = *src;
  80084c:	8a 1a                	mov    (%edx),%bl
  80084e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 3a 01             	cmpb   $0x1,(%edx)
  800854:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	41                   	inc    %ecx
  800858:	39 f1                	cmp    %esi,%ecx
  80085a:	75 f0                	jne    80084c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 75 08             	mov    0x8(%ebp),%esi
  800868:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	85 d2                	test   %edx,%edx
  800870:	75 0a                	jne    80087c <strlcpy+0x1c>
  800872:	89 f0                	mov    %esi,%eax
  800874:	eb 1a                	jmp    800890 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800876:	88 18                	mov    %bl,(%eax)
  800878:	40                   	inc    %eax
  800879:	41                   	inc    %ecx
  80087a:	eb 02                	jmp    80087e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80087e:	4a                   	dec    %edx
  80087f:	74 0a                	je     80088b <strlcpy+0x2b>
  800881:	8a 19                	mov    (%ecx),%bl
  800883:	84 db                	test   %bl,%bl
  800885:	75 ef                	jne    800876 <strlcpy+0x16>
  800887:	89 c2                	mov    %eax,%edx
  800889:	eb 02                	jmp    80088d <strlcpy+0x2d>
  80088b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800890:	29 f0                	sub    %esi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	eb 02                	jmp    8008a3 <strcmp+0xd>
		p++, q++;
  8008a1:	41                   	inc    %ecx
  8008a2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a3:	8a 01                	mov    (%ecx),%al
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 04                	je     8008ad <strcmp+0x17>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	74 f4                	je     8008a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c4:	eb 03                	jmp    8008c9 <strncmp+0x12>
		n--, p++, q++;
  8008c6:	4a                   	dec    %edx
  8008c7:	40                   	inc    %eax
  8008c8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c9:	85 d2                	test   %edx,%edx
  8008cb:	74 14                	je     8008e1 <strncmp+0x2a>
  8008cd:	8a 18                	mov    (%eax),%bl
  8008cf:	84 db                	test   %bl,%bl
  8008d1:	74 04                	je     8008d7 <strncmp+0x20>
  8008d3:	3a 19                	cmp    (%ecx),%bl
  8008d5:	74 ef                	je     8008c6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 00             	movzbl (%eax),%eax
  8008da:	0f b6 11             	movzbl (%ecx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb 05                	jmp    8008e6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f2:	eb 05                	jmp    8008f9 <strchr+0x10>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 0c                	je     800904 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f8:	40                   	inc    %eax
  8008f9:	8a 10                	mov    (%eax),%dl
  8008fb:	84 d2                	test   %dl,%dl
  8008fd:	75 f5                	jne    8008f4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090f:	eb 05                	jmp    800916 <strfind+0x10>
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 07                	je     80091c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800915:	40                   	inc    %eax
  800916:	8a 10                	mov    (%eax),%dl
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f5                	jne    800911 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 7d 08             	mov    0x8(%ebp),%edi
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 30                	je     800961 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 25                	jne    80095e <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 20                	jne    80095e <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d6                	mov    %edx,%esi
  800948:	c1 e6 18             	shl    $0x18,%esi
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 10             	shl    $0x10,%eax
  800950:	09 f0                	or     %esi,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800956:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800959:	fc                   	cld    
  80095a:	f3 ab                	rep stos %eax,%es:(%edi)
  80095c:	eb 03                	jmp    800961 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 34                	jae    8009ae <memmove+0x46>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2d                	jae    8009ae <memmove+0x46>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	f6 c2 03             	test   $0x3,%dl
  800987:	75 1b                	jne    8009a4 <memmove+0x3c>
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 13                	jne    8009a4 <memmove+0x3c>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 07                	jmp    8009ab <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a4:	4f                   	dec    %edi
  8009a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ab:	fc                   	cld    
  8009ac:	eb 20                	jmp    8009ce <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b4:	75 13                	jne    8009c9 <memmove+0x61>
  8009b6:	a8 03                	test   $0x3,%al
  8009b8:	75 0f                	jne    8009c9 <memmove+0x61>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	89 04 24             	mov    %eax,(%esp)
  8009ec:	e8 77 ff ff ff       	call   800968 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	57                   	push   %edi
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	eb 16                	jmp    800a1f <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a0c:	42                   	inc    %edx
  800a0d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a11:	38 c8                	cmp    %cl,%al
  800a13:	74 0a                	je     800a1f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c0             	movzbl %al,%eax
  800a18:	0f b6 c9             	movzbl %cl,%ecx
  800a1b:	29 c8                	sub    %ecx,%eax
  800a1d:	eb 09                	jmp    800a28 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	75 e6                	jne    800a09 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a36:	89 c2                	mov    %eax,%edx
  800a38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3b:	eb 05                	jmp    800a42 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	38 08                	cmp    %cl,(%eax)
  800a3f:	74 05                	je     800a46 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	40                   	inc    %eax
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	72 f7                	jb     800a3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	57                   	push   %edi
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a54:	eb 01                	jmp    800a57 <strtol+0xf>
		s++;
  800a56:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a57:	8a 02                	mov    (%edx),%al
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f9                	je     800a56 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f5                	je     800a56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 08                	jne    800a6d <strtol+0x25>
		s++;
  800a65:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb 13                	jmp    800a80 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6d:	3c 2d                	cmp    $0x2d,%al
  800a6f:	75 0a                	jne    800a7b <strtol+0x33>
		s++, neg = 1;
  800a71:	8d 52 01             	lea    0x1(%edx),%edx
  800a74:	bf 01 00 00 00       	mov    $0x1,%edi
  800a79:	eb 05                	jmp    800a80 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	74 05                	je     800a89 <strtol+0x41>
  800a84:	83 fb 10             	cmp    $0x10,%ebx
  800a87:	75 28                	jne    800ab1 <strtol+0x69>
  800a89:	8a 02                	mov    (%edx),%al
  800a8b:	3c 30                	cmp    $0x30,%al
  800a8d:	75 10                	jne    800a9f <strtol+0x57>
  800a8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a93:	75 0a                	jne    800a9f <strtol+0x57>
		s += 2, base = 16;
  800a95:	83 c2 02             	add    $0x2,%edx
  800a98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9d:	eb 12                	jmp    800ab1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a9f:	85 db                	test   %ebx,%ebx
  800aa1:	75 0e                	jne    800ab1 <strtol+0x69>
  800aa3:	3c 30                	cmp    $0x30,%al
  800aa5:	75 05                	jne    800aac <strtol+0x64>
		s++, base = 8;
  800aa7:	42                   	inc    %edx
  800aa8:	b3 08                	mov    $0x8,%bl
  800aaa:	eb 05                	jmp    800ab1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aac:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab8:	8a 0a                	mov    (%edx),%cl
  800aba:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800abd:	80 fb 09             	cmp    $0x9,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x82>
			dig = *s - '0';
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 30             	sub    $0x30,%ecx
  800ac8:	eb 1e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aca:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 57             	sub    $0x57,%ecx
  800ad8:	eb 0e                	jmp    800ae8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ada:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 12                	ja     800af4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae2:	0f be c9             	movsbl %cl,%ecx
  800ae5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae8:	39 f1                	cmp    %esi,%ecx
  800aea:	7d 0c                	jge    800af8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aec:	42                   	inc    %edx
  800aed:	0f af c6             	imul   %esi,%eax
  800af0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af2:	eb c4                	jmp    800ab8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af4:	89 c1                	mov    %eax,%ecx
  800af6:	eb 02                	jmp    800afa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 05                	je     800b05 <strtol+0xbd>
		*endptr = (char *) s;
  800b00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b03:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b05:	85 ff                	test   %edi,%edi
  800b07:	74 04                	je     800b0d <strtol+0xc5>
  800b09:	89 c8                	mov    %ecx,%eax
  800b0b:	f7 d8                	neg    %eax
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
	...

00800b14 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b22:	8b 55 08             	mov    0x8(%ebp),%edx
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	89 c7                	mov    %eax,%edi
  800b29:	89 c6                	mov    %eax,%esi
  800b2b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	89 cb                	mov    %ecx,%ebx
  800b69:	89 cf                	mov    %ecx,%edi
  800b6b:	89 ce                	mov    %ecx,%esi
  800b6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 28                	jle    800b9b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b77:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7e:	00 
  800b7f:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800b86:	00 
  800b87:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8e:	00 
  800b8f:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800b96:	e8 41 08 00 00       	call   8013dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9b:	83 c4 2c             	add    $0x2c,%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_yield>:

void
sys_yield(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	be 00 00 00 00       	mov    $0x0,%esi
  800bef:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 f7                	mov    %esi,%edi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 28                	jle    800c2d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c09:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c10:	00 
  800c11:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800c18:	00 
  800c19:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c20:	00 
  800c21:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800c28:	e8 af 07 00 00       	call   8013dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2d:	83 c4 2c             	add    $0x2c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c43:	8b 75 18             	mov    0x18(%ebp),%esi
  800c46:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 28                	jle    800c80 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c63:	00 
  800c64:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800c6b:	00 
  800c6c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c73:	00 
  800c74:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800c7b:	e8 5c 07 00 00       	call   8013dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c80:	83 c4 2c             	add    $0x2c,%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 df                	mov    %ebx,%edi
  800ca3:	89 de                	mov    %ebx,%esi
  800ca5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 28                	jle    800cd3 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb6:	00 
  800cb7:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800cce:	e8 09 07 00 00       	call   8013dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	83 c4 2c             	add    $0x2c,%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 28                	jle    800d26 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d02:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d09:	00 
  800d0a:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800d11:	00 
  800d12:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d19:	00 
  800d1a:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800d21:	e8 b6 06 00 00       	call   8013dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d26:	83 c4 2c             	add    $0x2c,%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800d74:	e8 63 06 00 00       	call   8013dc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d79:	83 c4 2c             	add    $0x2c,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 df                	mov    %ebx,%edi
  800d9c:	89 de                	mov    %ebx,%esi
  800d9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 28                	jle    800dcc <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800daf:	00 
  800db0:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800db7:	00 
  800db8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbf:	00 
  800dc0:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800dc7:	e8 10 06 00 00       	call   8013dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dcc:	83 c4 2c             	add    $0x2c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dda:	be 00 00 00 00       	mov    $0x0,%esi
  800ddf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e05:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 cb                	mov    %ecx,%ebx
  800e0f:	89 cf                	mov    %ecx,%edi
  800e11:	89 ce                	mov    %ecx,%esi
  800e13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e15:	85 c0                	test   %eax,%eax
  800e17:	7e 28                	jle    800e41 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e24:	00 
  800e25:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800e3c:	e8 9b 05 00 00       	call   8013dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e41:	83 c4 2c             	add    $0x2c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 d3                	mov    %edx,%ebx
  800e5d:	89 d7                	mov    %edx,%edi
  800e5f:	89 d6                	mov    %edx,%esi
  800e61:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 10 00 00 00       	mov    $0x10,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	57                   	push   %edi
  800e8d:	56                   	push   %esi
  800e8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e94:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	89 df                	mov    %ebx,%edi
  800ea1:	89 de                	mov    %ebx,%esi
  800ea3:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb5:	b8 11 00 00 00       	mov    $0x11,%eax
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 cb                	mov    %ecx,%ebx
  800ebf:	89 cf                	mov    %ecx,%edi
  800ec1:	89 ce                	mov    %ecx,%esi
  800ec3:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
	...

00800ecc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 24             	sub    $0x24,%esp
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ed6:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800ed8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800edc:	75 20                	jne    800efe <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800ede:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ee2:	c7 44 24 08 b4 1a 80 	movl   $0x801ab4,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800ef9:	e8 de 04 00 00       	call   8013dc <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800efe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f04:	89 d8                	mov    %ebx,%eax
  800f06:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f10:	f6 c4 08             	test   $0x8,%ah
  800f13:	75 1c                	jne    800f31 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f15:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f24:	00 
  800f25:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800f2c:	e8 ab 04 00 00       	call   8013dc <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f31:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f38:	00 
  800f39:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f40:	00 
  800f41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f48:	e8 94 fc ff ff       	call   800be1 <sys_page_alloc>
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	79 20                	jns    800f71 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800f51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f55:	c7 44 24 08 3f 1b 80 	movl   $0x801b3f,0x8(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800f64:	00 
  800f65:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800f6c:	e8 6b 04 00 00       	call   8013dc <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800f71:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f78:	00 
  800f79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f7d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f84:	e8 df f9 ff ff       	call   800968 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f89:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f90:	00 
  800f91:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fac:	e8 84 fc ff ff       	call   800c35 <sys_page_map>
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	79 20                	jns    800fd5 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800fb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb9:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800fd0:	e8 07 04 00 00       	call   8013dc <_panic>

}
  800fd5:	83 c4 24             	add    $0x24,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800fe4:	c7 04 24 cc 0e 80 00 	movl   $0x800ecc,(%esp)
  800feb:	e8 44 04 00 00       	call   801434 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ff0:	ba 07 00 00 00       	mov    $0x7,%edx
  800ff5:	89 d0                	mov    %edx,%eax
  800ff7:	cd 30                	int    $0x30
  800ff9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ffc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800fff:	85 c0                	test   %eax,%eax
  801001:	79 20                	jns    801023 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  801003:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801007:	c7 44 24 08 65 1b 80 	movl   $0x801b65,0x8(%esp)
  80100e:	00 
  80100f:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801016:	00 
  801017:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80101e:	e8 b9 03 00 00       	call   8013dc <_panic>
	if (child_envid == 0) { // child
  801023:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801027:	75 1c                	jne    801045 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801029:	e8 75 fb ff ff       	call   800ba3 <sys_getenvid>
  80102e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801033:	c1 e0 07             	shl    $0x7,%eax
  801036:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103b:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  801040:	e9 58 02 00 00       	jmp    80129d <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801045:	bf 00 00 00 00       	mov    $0x0,%edi
  80104a:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80104f:	89 f0                	mov    %esi,%eax
  801051:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801054:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105b:	a8 01                	test   $0x1,%al
  80105d:	0f 84 7a 01 00 00    	je     8011dd <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801063:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80106a:	a8 01                	test   $0x1,%al
  80106c:	0f 84 6b 01 00 00    	je     8011dd <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801072:	a1 08 20 80 00       	mov    0x802008,%eax
  801077:	8b 40 48             	mov    0x48(%eax),%eax
  80107a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  80107d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801084:	f6 c4 04             	test   $0x4,%ah
  801087:	74 52                	je     8010db <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801089:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801090:	25 07 0e 00 00       	and    $0xe07,%eax
  801095:	89 44 24 10          	mov    %eax,0x10(%esp)
  801099:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80109d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ab:	89 04 24             	mov    %eax,(%esp)
  8010ae:	e8 82 fb ff ff       	call   800c35 <sys_page_map>
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	0f 89 22 01 00 00    	jns    8011dd <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8010bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010bf:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8010d6:	e8 01 03 00 00       	call   8013dc <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8010db:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e2:	f6 c4 08             	test   $0x8,%ah
  8010e5:	75 0f                	jne    8010f6 <fork+0x11b>
  8010e7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ee:	a8 02                	test   $0x2,%al
  8010f0:	0f 84 99 00 00 00    	je     80118f <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  8010f6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010fd:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801100:	83 f8 01             	cmp    $0x1,%eax
  801103:	19 db                	sbb    %ebx,%ebx
  801105:	83 e3 fc             	and    $0xfffffffc,%ebx
  801108:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80110e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801112:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801116:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801119:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	e8 09 fb ff ff       	call   800c35 <sys_page_map>
  80112c:	85 c0                	test   %eax,%eax
  80112e:	79 20                	jns    801150 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801130:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801134:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  80113b:	00 
  80113c:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801143:	00 
  801144:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80114b:	e8 8c 02 00 00       	call   8013dc <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801150:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801154:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80115b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801163:	89 04 24             	mov    %eax,(%esp)
  801166:	e8 ca fa ff ff       	call   800c35 <sys_page_map>
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 6e                	jns    8011dd <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80116f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801173:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80118a:	e8 4d 02 00 00       	call   8013dc <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80118f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801196:	25 07 0e 00 00       	and    $0xe07,%eax
  80119b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80119f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b1:	89 04 24             	mov    %eax,(%esp)
  8011b4:	e8 7c fa ff ff       	call   800c35 <sys_page_map>
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	79 20                	jns    8011dd <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8011bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c1:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  8011c8:	00 
  8011c9:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011d0:	00 
  8011d1:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8011d8:	e8 ff 01 00 00       	call   8013dc <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8011dd:	46                   	inc    %esi
  8011de:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011e4:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8011ea:	0f 85 5f fe ff ff    	jne    80104f <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8011f0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f7:	00 
  8011f8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011ff:	ee 
  801200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801203:	89 04 24             	mov    %eax,(%esp)
  801206:	e8 d6 f9 ff ff       	call   800be1 <sys_page_alloc>
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 20                	jns    80122f <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  80120f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801213:	c7 44 24 08 3f 1b 80 	movl   $0x801b3f,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80122a:	e8 ad 01 00 00       	call   8013dc <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  80122f:	c7 44 24 04 a8 14 80 	movl   $0x8014a8,0x4(%esp)
  801236:	00 
  801237:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80123a:	89 04 24             	mov    %eax,(%esp)
  80123d:	e8 3f fb ff ff       	call   800d81 <sys_env_set_pgfault_upcall>
  801242:	85 c0                	test   %eax,%eax
  801244:	79 20                	jns    801266 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801246:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124a:	c7 44 24 08 14 1b 80 	movl   $0x801b14,0x8(%esp)
  801251:	00 
  801252:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801259:	00 
  80125a:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  801261:	e8 76 01 00 00       	call   8013dc <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801266:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80126d:	00 
  80126e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 62 fa ff ff       	call   800cdb <sys_env_set_status>
  801279:	85 c0                	test   %eax,%eax
  80127b:	79 20                	jns    80129d <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  80127d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801281:	c7 44 24 08 76 1b 80 	movl   $0x801b76,0x8(%esp)
  801288:	00 
  801289:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801290:	00 
  801291:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  801298:	e8 3f 01 00 00       	call   8013dc <_panic>

	return child_envid;
}
  80129d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a0:	83 c4 3c             	add    $0x3c,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <sfork>:

// Challenge!
int
sfork(void)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012ae:	c7 44 24 08 8e 1b 80 	movl   $0x801b8e,0x8(%esp)
  8012b5:	00 
  8012b6:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8012bd:	00 
  8012be:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8012c5:	e8 12 01 00 00       	call   8013dc <_panic>
	...

008012cc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 10             	sub    $0x10,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012da:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	75 05                	jne    8012e6 <ipc_recv+0x1a>
  8012e1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 09 fb ff ff       	call   800df7 <sys_ipc_recv>
	if (from_env_store != NULL)
  8012ee:	85 db                	test   %ebx,%ebx
  8012f0:	74 0b                	je     8012fd <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8012f2:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8012f8:	8b 52 74             	mov    0x74(%edx),%edx
  8012fb:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8012fd:	85 f6                	test   %esi,%esi
  8012ff:	74 0b                	je     80130c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801301:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801307:	8b 52 78             	mov    0x78(%edx),%edx
  80130a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  80130c:	85 c0                	test   %eax,%eax
  80130e:	79 16                	jns    801326 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801310:	85 db                	test   %ebx,%ebx
  801312:	74 06                	je     80131a <ipc_recv+0x4e>
			*from_env_store = 0;
  801314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80131a:	85 f6                	test   %esi,%esi
  80131c:	74 10                	je     80132e <ipc_recv+0x62>
			*perm_store = 0;
  80131e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801324:	eb 08                	jmp    80132e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801326:	a1 08 20 80 00       	mov    0x802008,%eax
  80132b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	57                   	push   %edi
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
  80133b:	83 ec 1c             	sub    $0x1c,%esp
  80133e:	8b 75 08             	mov    0x8(%ebp),%esi
  801341:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801344:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801347:	eb 2a                	jmp    801373 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801349:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80134c:	74 20                	je     80136e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80134e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801352:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  801359:	00 
  80135a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801361:	00 
  801362:	c7 04 24 c9 1b 80 00 	movl   $0x801bc9,(%esp)
  801369:	e8 6e 00 00 00       	call   8013dc <_panic>
		sys_yield();
  80136e:	e8 4f f8 ff ff       	call   800bc2 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801373:	85 db                	test   %ebx,%ebx
  801375:	75 07                	jne    80137e <ipc_send+0x49>
  801377:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80137c:	eb 02                	jmp    801380 <ipc_send+0x4b>
  80137e:	89 d8                	mov    %ebx,%eax
  801380:	8b 55 14             	mov    0x14(%ebp),%edx
  801383:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801387:	89 44 24 08          	mov    %eax,0x8(%esp)
  80138b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80138f:	89 34 24             	mov    %esi,(%esp)
  801392:	e8 3d fa ff ff       	call   800dd4 <sys_ipc_try_send>
  801397:	85 c0                	test   %eax,%eax
  801399:	78 ae                	js     801349 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80139b:	83 c4 1c             	add    $0x1c,%esp
  80139e:	5b                   	pop    %ebx
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 e2 07             	shl    $0x7,%edx
  8013b3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b9:	8b 52 50             	mov    0x50(%edx),%edx
  8013bc:	39 ca                	cmp    %ecx,%edx
  8013be:	75 0d                	jne    8013cd <ipc_find_env+0x2a>
			return envs[i].env_id;
  8013c0:	c1 e0 07             	shl    $0x7,%eax
  8013c3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013c8:	8b 40 40             	mov    0x40(%eax),%eax
  8013cb:	eb 0c                	jmp    8013d9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013cd:	40                   	inc    %eax
  8013ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d3:	75 d9                	jne    8013ae <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d5:	66 b8 00 00          	mov    $0x0,%ax
}
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    
	...

008013dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013e7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013ed:	e8 b1 f7 ff ff       	call   800ba3 <sys_getenvid>
  8013f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801400:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	c7 04 24 d4 1b 80 00 	movl   $0x801bd4,(%esp)
  80140f:	e8 30 ee ff ff       	call   800244 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801414:	89 74 24 04          	mov    %esi,0x4(%esp)
  801418:	8b 45 10             	mov    0x10(%ebp),%eax
  80141b:	89 04 24             	mov    %eax,(%esp)
  80141e:	e8 c0 ed ff ff       	call   8001e3 <vcprintf>
	cprintf("\n");
  801423:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  80142a:	e8 15 ee ff ff       	call   800244 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80142f:	cc                   	int3   
  801430:	eb fd                	jmp    80142f <_panic+0x53>
	...

00801434 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80143a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801441:	75 58                	jne    80149b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801443:	a1 08 20 80 00       	mov    0x802008,%eax
  801448:	8b 40 48             	mov    0x48(%eax),%eax
  80144b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801452:	00 
  801453:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80145a:	ee 
  80145b:	89 04 24             	mov    %eax,(%esp)
  80145e:	e8 7e f7 ff ff       	call   800be1 <sys_page_alloc>
  801463:	85 c0                	test   %eax,%eax
  801465:	74 1c                	je     801483 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801467:	c7 44 24 08 f8 1b 80 	movl   $0x801bf8,0x8(%esp)
  80146e:	00 
  80146f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801476:	00 
  801477:	c7 04 24 0d 1c 80 00 	movl   $0x801c0d,(%esp)
  80147e:	e8 59 ff ff ff       	call   8013dc <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801483:	a1 08 20 80 00       	mov    0x802008,%eax
  801488:	8b 40 48             	mov    0x48(%eax),%eax
  80148b:	c7 44 24 04 a8 14 80 	movl   $0x8014a8,0x4(%esp)
  801492:	00 
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 e6 f8 ff ff       	call   800d81 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    
  8014a5:	00 00                	add    %al,(%eax)
	...

008014a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014a9:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8014ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014b0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8014b3:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8014b7:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8014b9:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8014bd:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8014be:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8014c1:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8014c3:	58                   	pop    %eax
	popl %eax
  8014c4:	58                   	pop    %eax

	// Pop all registers back
	popal
  8014c5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8014c6:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8014c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8014ca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8014cb:	c3                   	ret    

008014cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8014cc:	55                   	push   %ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	83 ec 10             	sub    $0x10,%esp
  8014d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8014d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8014da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8014e2:	89 cd                	mov    %ecx,%ebp
  8014e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	75 2c                	jne    801518 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8014ec:	39 f9                	cmp    %edi,%ecx
  8014ee:	77 68                	ja     801558 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8014f0:	85 c9                	test   %ecx,%ecx
  8014f2:	75 0b                	jne    8014ff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	31 d2                	xor    %edx,%edx
  8014fb:	f7 f1                	div    %ecx
  8014fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8014ff:	31 d2                	xor    %edx,%edx
  801501:	89 f8                	mov    %edi,%eax
  801503:	f7 f1                	div    %ecx
  801505:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801507:	89 f0                	mov    %esi,%eax
  801509:	f7 f1                	div    %ecx
  80150b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80150d:	89 f0                	mov    %esi,%eax
  80150f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801518:	39 f8                	cmp    %edi,%eax
  80151a:	77 2c                	ja     801548 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80151c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80151f:	83 f6 1f             	xor    $0x1f,%esi
  801522:	75 4c                	jne    801570 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801524:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801526:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80152b:	72 0a                	jb     801537 <__udivdi3+0x6b>
  80152d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801531:	0f 87 ad 00 00 00    	ja     8015e4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801537:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	5e                   	pop    %esi
  801544:	5f                   	pop    %edi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    
  801547:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801548:	31 ff                	xor    %edi,%edi
  80154a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80154c:	89 f0                	mov    %esi,%eax
  80154e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    
  801557:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801558:	89 fa                	mov    %edi,%edx
  80155a:	89 f0                	mov    %esi,%eax
  80155c:	f7 f1                	div    %ecx
  80155e:	89 c6                	mov    %eax,%esi
  801560:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801562:	89 f0                	mov    %esi,%eax
  801564:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    
  80156d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801570:	89 f1                	mov    %esi,%ecx
  801572:	d3 e0                	shl    %cl,%eax
  801574:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801578:	b8 20 00 00 00       	mov    $0x20,%eax
  80157d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80157f:	89 ea                	mov    %ebp,%edx
  801581:	88 c1                	mov    %al,%cl
  801583:	d3 ea                	shr    %cl,%edx
  801585:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801589:	09 ca                	or     %ecx,%edx
  80158b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80158f:	89 f1                	mov    %esi,%ecx
  801591:	d3 e5                	shl    %cl,%ebp
  801593:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801597:	89 fd                	mov    %edi,%ebp
  801599:	88 c1                	mov    %al,%cl
  80159b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80159d:	89 fa                	mov    %edi,%edx
  80159f:	89 f1                	mov    %esi,%ecx
  8015a1:	d3 e2                	shl    %cl,%edx
  8015a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a7:	88 c1                	mov    %al,%cl
  8015a9:	d3 ef                	shr    %cl,%edi
  8015ab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015ad:	89 f8                	mov    %edi,%eax
  8015af:	89 ea                	mov    %ebp,%edx
  8015b1:	f7 74 24 08          	divl   0x8(%esp)
  8015b5:	89 d1                	mov    %edx,%ecx
  8015b7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8015b9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015bd:	39 d1                	cmp    %edx,%ecx
  8015bf:	72 17                	jb     8015d8 <__udivdi3+0x10c>
  8015c1:	74 09                	je     8015cc <__udivdi3+0x100>
  8015c3:	89 fe                	mov    %edi,%esi
  8015c5:	31 ff                	xor    %edi,%edi
  8015c7:	e9 41 ff ff ff       	jmp    80150d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8015cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015d0:	89 f1                	mov    %esi,%ecx
  8015d2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015d4:	39 c2                	cmp    %eax,%edx
  8015d6:	73 eb                	jae    8015c3 <__udivdi3+0xf7>
		{
		  q0--;
  8015d8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8015db:	31 ff                	xor    %edi,%edi
  8015dd:	e9 2b ff ff ff       	jmp    80150d <__udivdi3+0x41>
  8015e2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015e4:	31 f6                	xor    %esi,%esi
  8015e6:	e9 22 ff ff ff       	jmp    80150d <__udivdi3+0x41>
	...

008015ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8015ec:	55                   	push   %ebp
  8015ed:	57                   	push   %edi
  8015ee:	56                   	push   %esi
  8015ef:	83 ec 20             	sub    $0x20,%esp
  8015f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8015f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8015fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8015fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801602:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801606:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80160a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80160c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80160e:	85 ed                	test   %ebp,%ebp
  801610:	75 16                	jne    801628 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801612:	39 f1                	cmp    %esi,%ecx
  801614:	0f 86 a6 00 00 00    	jbe    8016c0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80161a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801620:	83 c4 20             	add    $0x20,%esp
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    
  801627:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801628:	39 f5                	cmp    %esi,%ebp
  80162a:	0f 87 ac 00 00 00    	ja     8016dc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801630:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801633:	83 f0 1f             	xor    $0x1f,%eax
  801636:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163a:	0f 84 a8 00 00 00    	je     8016e8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801640:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801644:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801646:	bf 20 00 00 00       	mov    $0x20,%edi
  80164b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80164f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801653:	89 f9                	mov    %edi,%ecx
  801655:	d3 e8                	shr    %cl,%eax
  801657:	09 e8                	or     %ebp,%eax
  801659:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80165d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801661:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801665:	d3 e0                	shl    %cl,%eax
  801667:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80166b:	89 f2                	mov    %esi,%edx
  80166d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80166f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801673:	d3 e0                	shl    %cl,%eax
  801675:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801679:	8b 44 24 14          	mov    0x14(%esp),%eax
  80167d:	89 f9                	mov    %edi,%ecx
  80167f:	d3 e8                	shr    %cl,%eax
  801681:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801683:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801685:	89 f2                	mov    %esi,%edx
  801687:	f7 74 24 18          	divl   0x18(%esp)
  80168b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80168d:	f7 64 24 0c          	mull   0xc(%esp)
  801691:	89 c5                	mov    %eax,%ebp
  801693:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801695:	39 d6                	cmp    %edx,%esi
  801697:	72 67                	jb     801700 <__umoddi3+0x114>
  801699:	74 75                	je     801710 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80169b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80169f:	29 e8                	sub    %ebp,%eax
  8016a1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8016a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016a7:	d3 e8                	shr    %cl,%eax
  8016a9:	89 f2                	mov    %esi,%edx
  8016ab:	89 f9                	mov    %edi,%ecx
  8016ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8016af:	09 d0                	or     %edx,%eax
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016b7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016b9:	83 c4 20             	add    $0x20,%esp
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8016c0:	85 c9                	test   %ecx,%ecx
  8016c2:	75 0b                	jne    8016cf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8016c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c9:	31 d2                	xor    %edx,%edx
  8016cb:	f7 f1                	div    %ecx
  8016cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8016cf:	89 f0                	mov    %esi,%eax
  8016d1:	31 d2                	xor    %edx,%edx
  8016d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8016d5:	89 f8                	mov    %edi,%eax
  8016d7:	e9 3e ff ff ff       	jmp    80161a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8016dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016de:	83 c4 20             	add    $0x20,%esp
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    
  8016e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8016e8:	39 f5                	cmp    %esi,%ebp
  8016ea:	72 04                	jb     8016f0 <__umoddi3+0x104>
  8016ec:	39 f9                	cmp    %edi,%ecx
  8016ee:	77 06                	ja     8016f6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8016f0:	89 f2                	mov    %esi,%edx
  8016f2:	29 cf                	sub    %ecx,%edi
  8016f4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8016f6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	5e                   	pop    %esi
  8016fc:	5f                   	pop    %edi
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    
  8016ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801700:	89 d1                	mov    %edx,%ecx
  801702:	89 c5                	mov    %eax,%ebp
  801704:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801708:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80170c:	eb 8d                	jmp    80169b <__umoddi3+0xaf>
  80170e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801710:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801714:	72 ea                	jb     801700 <__umoddi3+0x114>
  801716:	89 f1                	mov    %esi,%ecx
  801718:	eb 81                	jmp    80169b <__umoddi3+0xaf>
