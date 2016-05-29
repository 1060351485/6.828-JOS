
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
  80003d:	e8 fb 11 00 00       	call   80123d <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 5b 0b 00 00       	call   800baf <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 c0 16 80 00 	movl   $0x8016c0,(%esp)
  800063:	e8 e8 01 00 00       	call   800250 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 3f 0b 00 00       	call   800baf <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 da 16 80 00 	movl   $0x8016da,(%esp)
  80007f:	e8 cc 01 00 00       	call   800250 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 22 12 00 00       	call   8012c9 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 9e 11 00 00       	call   801260 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 d3 0a 00 00       	call   800baf <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 f0 16 80 00 	movl   $0x8016f0,(%esp)
  8000fa:	e8 51 01 00 00       	call   800250 <cprintf>
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
  80012d:	e8 97 11 00 00       	call   8012c9 <ipc_send>
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
  800156:	e8 54 0a 00 00       	call   800baf <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 af 09 00 00       	call   800b5d <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	40                   	inc    %eax
  8001c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cb:	75 19                	jne    8001e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d4:	00 
  8001d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 40 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e6:	ff 43 04             	incl   0x4(%ebx)
}
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ff:	00 00 00 
	b.cnt = 0;
  800202:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800209:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800213:	8b 45 08             	mov    0x8(%ebp),%eax
  800216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022b:	e8 82 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 d8 08 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  800248:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800256:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 87 ff ff ff       	call   8001ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    
	...

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d7                	mov    %edx,%edi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800289:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	85 c0                	test   %eax,%eax
  80028e:	75 08                	jne    800298 <printnum+0x2c>
  800290:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800293:	39 45 10             	cmp    %eax,0x10(%ebp)
  800296:	77 57                	ja     8002ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800298:	89 74 24 10          	mov    %esi,0x10(%esp)
  80029c:	4b                   	dec    %ebx
  80029d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b7:	00 
  8002b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	e8 a2 11 00 00       	call   80146c <__udivdi3>
  8002ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d9:	89 fa                	mov    %edi,%edx
  8002db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002de:	e8 89 ff ff ff       	call   80026c <printnum>
  8002e3:	eb 0f                	jmp    8002f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ef:	4b                   	dec    %ebx
  8002f0:	85 db                	test   %ebx,%ebx
  8002f2:	7f f1                	jg     8002e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030a:	00 
  80030b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	e8 6f 12 00 00       	call   80158c <__umoddi3>
  80031d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800321:	0f be 80 20 17 80 00 	movsbl 0x801720(%eax),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032e:	83 c4 3c             	add    $0x3c,%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800339:	83 fa 01             	cmp    $0x1,%edx
  80033c:	7e 0e                	jle    80034c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 08             	lea    0x8(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	8b 52 04             	mov    0x4(%edx),%edx
  80034a:	eb 22                	jmp    80036e <getuint+0x38>
	else if (lflag)
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 10                	je     800360 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 0e                	jmp    80036e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800376:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 08                	jae    800388 <sprintputch+0x18>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	42                   	inc    %edx
  800386:	89 10                	mov    %edx,(%eax)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 02 00 00 00       	call   8003b2 <vprintfmt>
	va_end(ap);
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 4c             	sub    $0x4c,%esp
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003be:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c1:	eb 12                	jmp    8003d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	0f 84 6b 03 00 00    	je     800736 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d5:	0f b6 06             	movzbl (%esi),%eax
  8003d8:	46                   	inc    %esi
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	75 e5                	jne    8003c3 <vprintfmt+0x11>
  8003de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	eb 26                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800403:	eb 1d                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80040c:	eb 14                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800418:	eb 08                	jmp    800422 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80041d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	0f b6 06             	movzbl (%esi),%eax
  800425:	8d 56 01             	lea    0x1(%esi),%edx
  800428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042b:	8a 16                	mov    (%esi),%dl
  80042d:	83 ea 23             	sub    $0x23,%edx
  800430:	80 fa 55             	cmp    $0x55,%dl
  800433:	0f 87 e1 02 00 00    	ja     80071a <vprintfmt+0x368>
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
  800443:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800446:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800452:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800455:	8d 50 d0             	lea    -0x30(%eax),%edx
  800458:	83 fa 09             	cmp    $0x9,%edx
  80045b:	77 2a                	ja     800487 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb eb                	jmp    80044b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046e:	eb 17                	jmp    800487 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	78 98                	js     80040e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800479:	eb a7                	jmp    800422 <vprintfmt+0x70>
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800485:	eb 9b                	jmp    800422 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800487:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048b:	79 95                	jns    800422 <vprintfmt+0x70>
  80048d:	eb 8b                	jmp    80041a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	eb 8d                	jmp    800422 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ad:	e9 23 ff ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	79 02                	jns    8004c3 <vprintfmt+0x111>
  8004c1:	f7 d8                	neg    %eax
  8004c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c5:	83 f8 0f             	cmp    $0xf,%eax
  8004c8:	7f 0b                	jg     8004d5 <vprintfmt+0x123>
  8004ca:	8b 04 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 23                	jne    8004f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d9:	c7 44 24 08 38 17 80 	movl   $0x801738,0x8(%esp)
  8004e0:	00 
  8004e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 9a fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 dd fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 41 17 80 	movl   $0x801741,0x8(%esp)
  800503:	00 
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 14 24             	mov    %edx,(%esp)
  80050e:	e8 77 fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ba fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
  80051b:	89 f9                	mov    %edi,%ecx
  80051d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800520:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 30                	mov    (%eax),%esi
  80052e:	85 f6                	test   %esi,%esi
  800530:	75 05                	jne    800537 <vprintfmt+0x185>
				p = "(null)";
  800532:	be 31 17 80 00       	mov    $0x801731,%esi
			if (width > 0 && padc != '-')
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	0f 8e 84 00 00 00    	jle    8005c5 <vprintfmt+0x213>
  800541:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800545:	74 7e                	je     8005c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054b:	89 34 24             	mov    %esi,(%esp)
  80054e:	e8 8b 02 00 00       	call   8007de <strnlen>
  800553:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800556:	29 c2                	sub    %eax,%edx
  800558:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80055b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800562:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800565:	89 de                	mov    %ebx,%esi
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	eb 0b                	jmp    800578 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80056d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800571:	89 3c 24             	mov    %edi,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f f1                	jg     80056d <vprintfmt+0x1bb>
  80057c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057f:	89 f3                	mov    %esi,%ebx
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	79 05                	jns    800590 <vprintfmt+0x1de>
  80058b:	b8 00 00 00 00       	mov    $0x0,%eax
  800590:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800598:	eb 2b                	jmp    8005c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059e:	74 18                	je     8005b8 <vprintfmt+0x206>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x206>
					putch('?', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	eb 0a                	jmp    8005c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	46                   	inc    %esi
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	74 21                	je     8005ee <vprintfmt+0x23c>
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	78 c9                	js     80059a <vprintfmt+0x1e8>
  8005d1:	4f                   	dec    %edi
  8005d2:	79 c6                	jns    80059a <vprintfmt+0x1e8>
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	89 de                	mov    %ebx,%esi
  8005d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005dc:	eb 18                	jmp    8005f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x244>
  8005ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	7f e4                	jg     8005de <vprintfmt+0x22c>
  8005fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800602:	e9 ce fd ff ff       	jmp    8003d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7e 10                	jle    80061c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 08             	lea    0x8(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
  800617:	8b 78 04             	mov    0x4(%eax),%edi
  80061a:	eb 26                	jmp    800642 <vprintfmt+0x290>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 12                	je     800632 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	c1 ff 1f             	sar    $0x1f,%edi
  800630:	eb 10                	jmp    800642 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 30                	mov    (%eax),%esi
  80063d:	89 f7                	mov    %esi,%edi
  80063f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	85 ff                	test   %edi,%edi
  800644:	78 0a                	js     800650 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8c 00 00 00       	jmp    8006dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	f7 de                	neg    %esi
  800660:	83 d7 00             	adc    $0x0,%edi
  800663:	f7 df                	neg    %edi
			}
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	eb 70                	jmp    8006dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	89 ca                	mov    %ecx,%edx
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 c0 fc ff ff       	call   800336 <getuint>
  800676:	89 c6                	mov    %eax,%esi
  800678:	89 d7                	mov    %edx,%edi
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067f:	eb 5b                	jmp    8006dc <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 ab fc ff ff       	call   800336 <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
			base = 8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800694:	eb 46                	jmp    8006dc <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 30                	mov    (%eax),%esi
  8006bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c7:	eb 13                	jmp    8006dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 63 fc ff ff       	call   800336 <getuint>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ef:	89 34 24             	mov    %esi,(%esp)
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	89 da                	mov    %ebx,%edx
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	e8 6c fb ff ff       	call   80026c <printnum>
			break;
  800700:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800703:	e9 cd fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800715:	e9 bb fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800725:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	eb 01                	jmp    80072b <vprintfmt+0x379>
  80072a:	4e                   	dec    %esi
  80072b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072f:	75 f9                	jne    80072a <vprintfmt+0x378>
  800731:	e9 9f fc ff ff       	jmp    8003d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800736:	83 c4 4c             	add    $0x4c,%esp
  800739:	5b                   	pop    %ebx
  80073a:	5e                   	pop    %esi
  80073b:	5f                   	pop    %edi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 28             	sub    $0x28,%esp
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800751:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800754:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075b:	85 c0                	test   %eax,%eax
  80075d:	74 30                	je     80078f <vsnprintf+0x51>
  80075f:	85 d2                	test   %edx,%edx
  800761:	7e 33                	jle    800796 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	c7 04 24 70 03 80 00 	movl   $0x800370,(%esp)
  80077f:	e8 2e fc ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800784:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800787:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	eb 0c                	jmp    80079b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800794:	eb 05                	jmp    80079b <vsnprintf+0x5d>
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 7b ff ff ff       	call   80073e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    
  8007c5:	00 00                	add    %al,(%eax)
	...

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 01                	jmp    8007d6 <strlen+0xe>
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 01                	jmp    8007ef <strnlen+0x11>
		n++;
  8007ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	74 06                	je     8007f9 <strnlen+0x1b>
  8007f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f7:	75 f5                	jne    8007ee <strnlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	42                   	inc    %edx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 f5                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	89 1c 24             	mov    %ebx,(%esp)
  800825:	e8 9e ff ff ff       	call   8007c8 <strlen>
	strcpy(dst + len, src);
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	01 d8                	add    %ebx,%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 c0 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	eb 0c                	jmp    800864 <strncpy+0x21>
		*dst++ = *src;
  800858:	8a 1a                	mov    (%edx),%bl
  80085a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 3a 01             	cmpb   $0x1,(%edx)
  800860:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	41                   	inc    %ecx
  800864:	39 f1                	cmp    %esi,%ecx
  800866:	75 f0                	jne    800858 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 0a                	jne    800888 <strlcpy+0x1c>
  80087e:	89 f0                	mov    %esi,%eax
  800880:	eb 1a                	jmp    80089c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	88 18                	mov    %bl,(%eax)
  800884:	40                   	inc    %eax
  800885:	41                   	inc    %ecx
  800886:	eb 02                	jmp    80088a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80088a:	4a                   	dec    %edx
  80088b:	74 0a                	je     800897 <strlcpy+0x2b>
  80088d:	8a 19                	mov    (%ecx),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strlcpy+0x16>
  800893:	89 c2                	mov    %eax,%edx
  800895:	eb 02                	jmp    800899 <strlcpy+0x2d>
  800897:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 02                	jmp    8008af <strcmp+0xd>
		p++, q++;
  8008ad:	41                   	inc    %ecx
  8008ae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	8a 01                	mov    (%ecx),%al
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x17>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 f4                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 03                	jmp    8008d5 <strncmp+0x12>
		n--, p++, q++;
  8008d2:	4a                   	dec    %edx
  8008d3:	40                   	inc    %eax
  8008d4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 14                	je     8008ed <strncmp+0x2a>
  8008d9:	8a 18                	mov    (%eax),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	74 04                	je     8008e3 <strncmp+0x20>
  8008df:	3a 19                	cmp    (%ecx),%bl
  8008e1:	74 ef                	je     8008d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb 05                	jmp    8008f2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	eb 05                	jmp    800905 <strchr+0x10>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0c                	je     800910 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800904:	40                   	inc    %eax
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f5                	jne    800900 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091b:	eb 05                	jmp    800922 <strfind+0x10>
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 07                	je     800928 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800921:	40                   	inc    %eax
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f5                	jne    80091d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 30                	je     80096d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 25                	jne    80096a <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 20                	jne    80096a <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	c1 e6 18             	shl    $0x18,%esi
  800957:	89 d0                	mov    %edx,%eax
  800959:	c1 e0 10             	shl    $0x10,%eax
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 d0                	or     %edx,%eax
  800960:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 03                	jmp    80096d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 34                	jae    8009ba <memmove+0x46>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2d                	jae    8009ba <memmove+0x46>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 1b                	jne    8009b0 <memmove+0x3c>
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 13                	jne    8009b0 <memmove+0x3c>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0e                	jne    8009b0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 07                	jmp    8009b7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b0:	4f                   	dec    %edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 20                	jmp    8009da <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	75 13                	jne    8009d5 <memmove+0x61>
  8009c2:	a8 03                	test   $0x3,%al
  8009c4:	75 0f                	jne    8009d5 <memmove+0x61>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 77 ff ff ff       	call   800974 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	eb 16                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a18:	42                   	inc    %edx
  800a19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a1d:	38 c8                	cmp    %cl,%al
  800a1f:	74 0a                	je     800a2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 c9             	movzbl %cl,%ecx
  800a27:	29 c8                	sub    %ecx,%eax
  800a29:	eb 09                	jmp    800a34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	75 e6                	jne    800a15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	eb 05                	jmp    800a4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	74 05                	je     800a52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4d:	40                   	inc    %eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	72 f7                	jb     800a49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 01                	jmp    800a63 <strtol+0xf>
		s++;
  800a62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	8a 02                	mov    (%edx),%al
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f9                	je     800a62 <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f5                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 08                	jne    800a79 <strtol+0x25>
		s++;
  800a71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
  800a77:	eb 13                	jmp    800a8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	75 0a                	jne    800a87 <strtol+0x33>
		s++, neg = 1;
  800a7d:	8d 52 01             	lea    0x1(%edx),%edx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb 05                	jmp    800a8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 05                	je     800a95 <strtol+0x41>
  800a90:	83 fb 10             	cmp    $0x10,%ebx
  800a93:	75 28                	jne    800abd <strtol+0x69>
  800a95:	8a 02                	mov    (%edx),%al
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 10                	jne    800aab <strtol+0x57>
  800a9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9f:	75 0a                	jne    800aab <strtol+0x57>
		s += 2, base = 16;
  800aa1:	83 c2 02             	add    $0x2,%edx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 12                	jmp    800abd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 0e                	jne    800abd <strtol+0x69>
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 05                	jne    800ab8 <strtol+0x64>
		s++, base = 8;
  800ab3:	42                   	inc    %edx
  800ab4:	b3 08                	mov    $0x8,%bl
  800ab6:	eb 05                	jmp    800abd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	8a 0a                	mov    (%edx),%cl
  800ac6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x82>
			dig = *s - '0';
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 30             	sub    $0x30,%ecx
  800ad4:	eb 1e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 57             	sub    $0x57,%ecx
  800ae4:	eb 0e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 12                	ja     800b00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af4:	39 f1                	cmp    %esi,%ecx
  800af6:	7d 0c                	jge    800b04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af8:	42                   	inc    %edx
  800af9:	0f af c6             	imul   %esi,%eax
  800afc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb c4                	jmp    800ac4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	89 c1                	mov    %eax,%ecx
  800b02:	eb 02                	jmp    800b06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 05                	je     800b11 <strtol+0xbd>
		*endptr = (char *) s;
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b11:	85 ff                	test   %edi,%edi
  800b13:	74 04                	je     800b19 <strtol+0xc5>
  800b15:	89 c8                	mov    %ecx,%eax
  800b17:	f7 d8                	neg    %eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
	...

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	89 cb                	mov    %ecx,%ebx
  800b75:	89 cf                	mov    %ecx,%edi
  800b77:	89 ce                	mov    %ecx,%esi
  800b79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 28                	jle    800ba7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8a:	00 
  800b8b:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800b92:	00 
  800b93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9a:	00 
  800b9b:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800ba2:	e8 d5 07 00 00       	call   80137c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	83 c4 2c             	add    $0x2c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 28                	jle    800c39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800c24:	00 
  800c25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2c:	00 
  800c2d:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800c34:	e8 43 07 00 00       	call   80137c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	83 c4 2c             	add    $0x2c,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 28                	jle    800c8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6f:	00 
  800c70:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800c77:	00 
  800c78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7f:	00 
  800c80:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800c87:	e8 f0 06 00 00       	call   80137c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8c:	83 c4 2c             	add    $0x2c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800cda:	e8 9d 06 00 00       	call   80137c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800d2d:	e8 4a 06 00 00       	call   80137c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800d80:	e8 f7 05 00 00       	call   80137c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800dd3:	e8 a4 05 00 00       	call   80137c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	be 00 00 00 00       	mov    $0x0,%esi
  800deb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 cb                	mov    %ecx,%ebx
  800e1b:	89 cf                	mov    %ecx,%edi
  800e1d:	89 ce                	mov    %ecx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 28                	jle    800e4d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e29:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e30:	00 
  800e31:	c7 44 24 08 1f 1a 80 	movl   $0x801a1f,0x8(%esp)
  800e38:	00 
  800e39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e40:	00 
  800e41:	c7 04 24 3c 1a 80 00 	movl   $0x801a3c,(%esp)
  800e48:	e8 2f 05 00 00       	call   80137c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4d:	83 c4 2c             	add    $0x2c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	00 00                	add    %al,(%eax)
	...

00800e58 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 24             	sub    $0x24,%esp
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e62:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800e64:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e68:	75 20                	jne    800e8a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e6a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6e:	c7 44 24 08 4c 1a 80 	movl   $0x801a4c,0x8(%esp)
  800e75:	00 
  800e76:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e7d:	00 
  800e7e:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  800e85:	e8 f2 04 00 00       	call   80137c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e8a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e9c:	f6 c4 08             	test   $0x8,%ah
  800e9f:	75 1c                	jne    800ebd <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ea1:	c7 44 24 08 7c 1a 80 	movl   $0x801a7c,0x8(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb0:	00 
  800eb1:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  800eb8:	e8 bf 04 00 00       	call   80137c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ebd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed4:	e8 14 fd ff ff       	call   800bed <sys_page_alloc>
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 20                	jns    800efd <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee1:	c7 44 24 08 d7 1a 80 	movl   $0x801ad7,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  800ef8:	e8 7f 04 00 00       	call   80137c <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800efd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f04:	00 
  800f05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f09:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f10:	e8 5f fa ff ff       	call   800974 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f15:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f1c:	00 
  800f1d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 04 fd ff ff       	call   800c41 <sys_page_map>
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 20                	jns    800f61 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f45:	c7 44 24 08 eb 1a 80 	movl   $0x801aeb,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  800f5c:	e8 1b 04 00 00       	call   80137c <_panic>

}
  800f61:	83 c4 24             	add    $0x24,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800f70:	c7 04 24 58 0e 80 00 	movl   $0x800e58,(%esp)
  800f77:	e8 58 04 00 00       	call   8013d4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f7c:	ba 07 00 00 00       	mov    $0x7,%edx
  800f81:	89 d0                	mov    %edx,%eax
  800f83:	cd 30                	int    $0x30
  800f85:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f88:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	79 20                	jns    800faf <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800f8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f93:	c7 44 24 08 fd 1a 80 	movl   $0x801afd,0x8(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  800fa2:	00 
  800fa3:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  800faa:	e8 cd 03 00 00       	call   80137c <_panic>
	if (child_envid == 0) { // child
  800faf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fb3:	75 25                	jne    800fda <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb5:	e8 f5 fb ff ff       	call   800baf <sys_getenvid>
  800fba:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fc6:	c1 e0 07             	shl    $0x7,%eax
  800fc9:	29 d0                	sub    %edx,%eax
  800fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd0:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800fd5:	e9 58 02 00 00       	jmp    801232 <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800fda:	bf 00 00 00 00       	mov    $0x0,%edi
  800fdf:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fe4:	89 f0                	mov    %esi,%eax
  800fe6:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fe9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff0:	a8 01                	test   $0x1,%al
  800ff2:	0f 84 7a 01 00 00    	je     801172 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800ff8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fff:	a8 01                	test   $0x1,%al
  801001:	0f 84 6b 01 00 00    	je     801172 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801007:	a1 08 20 80 00       	mov    0x802008,%eax
  80100c:	8b 40 48             	mov    0x48(%eax),%eax
  80100f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801012:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801019:	f6 c4 04             	test   $0x4,%ah
  80101c:	74 52                	je     801070 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80101e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801025:	25 07 0e 00 00       	and    $0xe07,%eax
  80102a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801032:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801035:	89 44 24 08          	mov    %eax,0x8(%esp)
  801039:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80103d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801040:	89 04 24             	mov    %eax,(%esp)
  801043:	e8 f9 fb ff ff       	call   800c41 <sys_page_map>
  801048:	85 c0                	test   %eax,%eax
  80104a:	0f 89 22 01 00 00    	jns    801172 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801054:	c7 44 24 08 eb 1a 80 	movl   $0x801aeb,0x8(%esp)
  80105b:	00 
  80105c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801063:	00 
  801064:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  80106b:	e8 0c 03 00 00       	call   80137c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801070:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801077:	f6 c4 08             	test   $0x8,%ah
  80107a:	75 0f                	jne    80108b <fork+0x124>
  80107c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801083:	a8 02                	test   $0x2,%al
  801085:	0f 84 99 00 00 00    	je     801124 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80108b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801092:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801095:	83 f8 01             	cmp    $0x1,%eax
  801098:	19 db                	sbb    %ebx,%ebx
  80109a:	83 e3 fc             	and    $0xfffffffc,%ebx
  80109d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010a3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010a7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b9:	89 04 24             	mov    %eax,(%esp)
  8010bc:	e8 80 fb ff ff       	call   800c41 <sys_page_map>
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	79 20                	jns    8010e5 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8010c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010c9:	c7 44 24 08 eb 1a 80 	movl   $0x801aeb,0x8(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010d8:	00 
  8010d9:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  8010e0:	e8 97 02 00 00       	call   80137c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010e5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010e9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010f8:	89 04 24             	mov    %eax,(%esp)
  8010fb:	e8 41 fb ff ff       	call   800c41 <sys_page_map>
  801100:	85 c0                	test   %eax,%eax
  801102:	79 6e                	jns    801172 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801104:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801108:	c7 44 24 08 eb 1a 80 	movl   $0x801aeb,0x8(%esp)
  80110f:	00 
  801110:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801117:	00 
  801118:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  80111f:	e8 58 02 00 00       	call   80137c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801124:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112b:	25 07 0e 00 00       	and    $0xe07,%eax
  801130:	89 44 24 10          	mov    %eax,0x10(%esp)
  801134:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801138:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80113b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801143:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801146:	89 04 24             	mov    %eax,(%esp)
  801149:	e8 f3 fa ff ff       	call   800c41 <sys_page_map>
  80114e:	85 c0                	test   %eax,%eax
  801150:	79 20                	jns    801172 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801152:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801156:	c7 44 24 08 eb 1a 80 	movl   $0x801aeb,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  80116d:	e8 0a 02 00 00       	call   80137c <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801172:	46                   	inc    %esi
  801173:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801179:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80117f:	0f 85 5f fe ff ff    	jne    800fe4 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801185:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80118c:	00 
  80118d:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801194:	ee 
  801195:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801198:	89 04 24             	mov    %eax,(%esp)
  80119b:	e8 4d fa ff ff       	call   800bed <sys_page_alloc>
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	79 20                	jns    8011c4 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  8011a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a8:	c7 44 24 08 d7 1a 80 	movl   $0x801ad7,0x8(%esp)
  8011af:	00 
  8011b0:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011b7:	00 
  8011b8:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  8011bf:	e8 b8 01 00 00       	call   80137c <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8011c4:	c7 44 24 04 48 14 80 	movl   $0x801448,0x4(%esp)
  8011cb:	00 
  8011cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011cf:	89 04 24             	mov    %eax,(%esp)
  8011d2:	e8 b6 fb ff ff       	call   800d8d <sys_env_set_pgfault_upcall>
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	79 20                	jns    8011fb <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8011db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011df:	c7 44 24 08 ac 1a 80 	movl   $0x801aac,0x8(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  8011f6:	e8 81 01 00 00       	call   80137c <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8011fb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801202:	00 
  801203:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 d9 fa ff ff       	call   800ce7 <sys_env_set_status>
  80120e:	85 c0                	test   %eax,%eax
  801210:	79 20                	jns    801232 <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  801212:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801216:	c7 44 24 08 0e 1b 80 	movl   $0x801b0e,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  80122d:	e8 4a 01 00 00       	call   80137c <_panic>

	return child_envid;
}
  801232:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801235:	83 c4 3c             	add    $0x3c,%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sfork>:

// Challenge!
int
sfork(void)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801243:	c7 44 24 08 26 1b 80 	movl   $0x801b26,0x8(%esp)
  80124a:	00 
  80124b:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801252:	00 
  801253:	c7 04 24 cc 1a 80 00 	movl   $0x801acc,(%esp)
  80125a:	e8 1d 01 00 00       	call   80137c <_panic>
	...

00801260 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 10             	sub    $0x10,%esp
  801268:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80126b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801271:	85 c0                	test   %eax,%eax
  801273:	75 05                	jne    80127a <ipc_recv+0x1a>
  801275:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80127a:	89 04 24             	mov    %eax,(%esp)
  80127d:	e8 81 fb ff ff       	call   800e03 <sys_ipc_recv>
	if (from_env_store != NULL)
  801282:	85 db                	test   %ebx,%ebx
  801284:	74 0b                	je     801291 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801286:	8b 15 08 20 80 00    	mov    0x802008,%edx
  80128c:	8b 52 74             	mov    0x74(%edx),%edx
  80128f:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801291:	85 f6                	test   %esi,%esi
  801293:	74 0b                	je     8012a0 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801295:	8b 15 08 20 80 00    	mov    0x802008,%edx
  80129b:	8b 52 78             	mov    0x78(%edx),%edx
  80129e:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	79 16                	jns    8012ba <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8012a4:	85 db                	test   %ebx,%ebx
  8012a6:	74 06                	je     8012ae <ipc_recv+0x4e>
			*from_env_store = 0;
  8012a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8012ae:	85 f6                	test   %esi,%esi
  8012b0:	74 10                	je     8012c2 <ipc_recv+0x62>
			*perm_store = 0;
  8012b2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8012b8:	eb 08                	jmp    8012c2 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8012ba:	a1 08 20 80 00       	mov    0x802008,%eax
  8012bf:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 1c             	sub    $0x1c,%esp
  8012d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8012db:	eb 2a                	jmp    801307 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8012dd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012e0:	74 20                	je     801302 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8012e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e6:	c7 44 24 08 3c 1b 80 	movl   $0x801b3c,0x8(%esp)
  8012ed:	00 
  8012ee:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8012f5:	00 
  8012f6:	c7 04 24 61 1b 80 00 	movl   $0x801b61,(%esp)
  8012fd:	e8 7a 00 00 00       	call   80137c <_panic>
		sys_yield();
  801302:	e8 c7 f8 ff ff       	call   800bce <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801307:	85 db                	test   %ebx,%ebx
  801309:	75 07                	jne    801312 <ipc_send+0x49>
  80130b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801310:	eb 02                	jmp    801314 <ipc_send+0x4b>
  801312:	89 d8                	mov    %ebx,%eax
  801314:	8b 55 14             	mov    0x14(%ebp),%edx
  801317:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80131b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801323:	89 34 24             	mov    %esi,(%esp)
  801326:	e8 b5 fa ff ff       	call   800de0 <sys_ipc_try_send>
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 ae                	js     8012dd <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80132f:	83 c4 1c             	add    $0x1c,%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	53                   	push   %ebx
  80133b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801343:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	c1 e2 07             	shl    $0x7,%edx
  80134f:	29 ca                	sub    %ecx,%edx
  801351:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801357:	8b 52 50             	mov    0x50(%edx),%edx
  80135a:	39 da                	cmp    %ebx,%edx
  80135c:	75 0f                	jne    80136d <ipc_find_env+0x36>
			return envs[i].env_id;
  80135e:	c1 e0 07             	shl    $0x7,%eax
  801361:	29 c8                	sub    %ecx,%eax
  801363:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801368:	8b 40 40             	mov    0x40(%eax),%eax
  80136b:	eb 0c                	jmp    801379 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80136d:	40                   	inc    %eax
  80136e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801373:	75 ce                	jne    801343 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801375:	66 b8 00 00          	mov    $0x0,%ax
}
  801379:	5b                   	pop    %ebx
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801384:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801387:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80138d:	e8 1d f8 ff ff       	call   800baf <sys_getenvid>
  801392:	8b 55 0c             	mov    0xc(%ebp),%edx
  801395:	89 54 24 10          	mov    %edx,0x10(%esp)
  801399:	8b 55 08             	mov    0x8(%ebp),%edx
  80139c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a8:	c7 04 24 6c 1b 80 00 	movl   $0x801b6c,(%esp)
  8013af:	e8 9c ee ff ff       	call   800250 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 2c ee ff ff       	call   8001ef <vcprintf>
	cprintf("\n");
  8013c3:	c7 04 24 e9 1a 80 00 	movl   $0x801ae9,(%esp)
  8013ca:	e8 81 ee ff ff       	call   800250 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013cf:	cc                   	int3   
  8013d0:	eb fd                	jmp    8013cf <_panic+0x53>
	...

008013d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013da:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8013e1:	75 58                	jne    80143b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8013e3:	a1 08 20 80 00       	mov    0x802008,%eax
  8013e8:	8b 40 48             	mov    0x48(%eax),%eax
  8013eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013f2:	00 
  8013f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013fa:	ee 
  8013fb:	89 04 24             	mov    %eax,(%esp)
  8013fe:	e8 ea f7 ff ff       	call   800bed <sys_page_alloc>
  801403:	85 c0                	test   %eax,%eax
  801405:	74 1c                	je     801423 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801407:	c7 44 24 08 90 1b 80 	movl   $0x801b90,0x8(%esp)
  80140e:	00 
  80140f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801416:	00 
  801417:	c7 04 24 a5 1b 80 00 	movl   $0x801ba5,(%esp)
  80141e:	e8 59 ff ff ff       	call   80137c <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801423:	a1 08 20 80 00       	mov    0x802008,%eax
  801428:	8b 40 48             	mov    0x48(%eax),%eax
  80142b:	c7 44 24 04 48 14 80 	movl   $0x801448,0x4(%esp)
  801432:	00 
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 52 f9 ff ff       	call   800d8d <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    
  801445:	00 00                	add    %al,(%eax)
	...

00801448 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801448:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801449:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  80144e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801450:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801453:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801457:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801459:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  80145d:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80145e:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801461:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  801463:	58                   	pop    %eax
	popl %eax
  801464:	58                   	pop    %eax

	// Pop all registers back
	popal
  801465:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801466:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801469:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80146a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80146b:	c3                   	ret    

0080146c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80146c:	55                   	push   %ebp
  80146d:	57                   	push   %edi
  80146e:	56                   	push   %esi
  80146f:	83 ec 10             	sub    $0x10,%esp
  801472:	8b 74 24 20          	mov    0x20(%esp),%esi
  801476:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80147a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80147e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801482:	89 cd                	mov    %ecx,%ebp
  801484:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801488:	85 c0                	test   %eax,%eax
  80148a:	75 2c                	jne    8014b8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80148c:	39 f9                	cmp    %edi,%ecx
  80148e:	77 68                	ja     8014f8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801490:	85 c9                	test   %ecx,%ecx
  801492:	75 0b                	jne    80149f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801494:	b8 01 00 00 00       	mov    $0x1,%eax
  801499:	31 d2                	xor    %edx,%edx
  80149b:	f7 f1                	div    %ecx
  80149d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80149f:	31 d2                	xor    %edx,%edx
  8014a1:	89 f8                	mov    %edi,%eax
  8014a3:	f7 f1                	div    %ecx
  8014a5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014a7:	89 f0                	mov    %esi,%eax
  8014a9:	f7 f1                	div    %ecx
  8014ab:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014ad:	89 f0                	mov    %esi,%eax
  8014af:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	5e                   	pop    %esi
  8014b5:	5f                   	pop    %edi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014b8:	39 f8                	cmp    %edi,%eax
  8014ba:	77 2c                	ja     8014e8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8014bc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8014bf:	83 f6 1f             	xor    $0x1f,%esi
  8014c2:	75 4c                	jne    801510 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014c4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014c6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014cb:	72 0a                	jb     8014d7 <__udivdi3+0x6b>
  8014cd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8014d1:	0f 87 ad 00 00 00    	ja     801584 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014d7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014dc:	89 f0                	mov    %esi,%eax
  8014de:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	5e                   	pop    %esi
  8014e4:	5f                   	pop    %edi
  8014e5:	5d                   	pop    %ebp
  8014e6:	c3                   	ret    
  8014e7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014e8:	31 ff                	xor    %edi,%edi
  8014ea:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014ec:	89 f0                	mov    %esi,%eax
  8014ee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	5e                   	pop    %esi
  8014f4:	5f                   	pop    %edi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    
  8014f7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014f8:	89 fa                	mov    %edi,%edx
  8014fa:	89 f0                	mov    %esi,%eax
  8014fc:	f7 f1                	div    %ecx
  8014fe:	89 c6                	mov    %eax,%esi
  801500:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801502:	89 f0                	mov    %esi,%eax
  801504:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801510:	89 f1                	mov    %esi,%ecx
  801512:	d3 e0                	shl    %cl,%eax
  801514:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801518:	b8 20 00 00 00       	mov    $0x20,%eax
  80151d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80151f:	89 ea                	mov    %ebp,%edx
  801521:	88 c1                	mov    %al,%cl
  801523:	d3 ea                	shr    %cl,%edx
  801525:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801529:	09 ca                	or     %ecx,%edx
  80152b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80152f:	89 f1                	mov    %esi,%ecx
  801531:	d3 e5                	shl    %cl,%ebp
  801533:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801537:	89 fd                	mov    %edi,%ebp
  801539:	88 c1                	mov    %al,%cl
  80153b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80153d:	89 fa                	mov    %edi,%edx
  80153f:	89 f1                	mov    %esi,%ecx
  801541:	d3 e2                	shl    %cl,%edx
  801543:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801547:	88 c1                	mov    %al,%cl
  801549:	d3 ef                	shr    %cl,%edi
  80154b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80154d:	89 f8                	mov    %edi,%eax
  80154f:	89 ea                	mov    %ebp,%edx
  801551:	f7 74 24 08          	divl   0x8(%esp)
  801555:	89 d1                	mov    %edx,%ecx
  801557:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801559:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80155d:	39 d1                	cmp    %edx,%ecx
  80155f:	72 17                	jb     801578 <__udivdi3+0x10c>
  801561:	74 09                	je     80156c <__udivdi3+0x100>
  801563:	89 fe                	mov    %edi,%esi
  801565:	31 ff                	xor    %edi,%edi
  801567:	e9 41 ff ff ff       	jmp    8014ad <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80156c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801570:	89 f1                	mov    %esi,%ecx
  801572:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801574:	39 c2                	cmp    %eax,%edx
  801576:	73 eb                	jae    801563 <__udivdi3+0xf7>
		{
		  q0--;
  801578:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80157b:	31 ff                	xor    %edi,%edi
  80157d:	e9 2b ff ff ff       	jmp    8014ad <__udivdi3+0x41>
  801582:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801584:	31 f6                	xor    %esi,%esi
  801586:	e9 22 ff ff ff       	jmp    8014ad <__udivdi3+0x41>
	...

0080158c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80158c:	55                   	push   %ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	83 ec 20             	sub    $0x20,%esp
  801592:	8b 44 24 30          	mov    0x30(%esp),%eax
  801596:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80159a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80159e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8015a2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8015a6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8015aa:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8015ac:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8015ae:	85 ed                	test   %ebp,%ebp
  8015b0:	75 16                	jne    8015c8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8015b2:	39 f1                	cmp    %esi,%ecx
  8015b4:	0f 86 a6 00 00 00    	jbe    801660 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015ba:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8015bc:	89 d0                	mov    %edx,%eax
  8015be:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015c0:	83 c4 20             	add    $0x20,%esp
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    
  8015c7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015c8:	39 f5                	cmp    %esi,%ebp
  8015ca:	0f 87 ac 00 00 00    	ja     80167c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8015d0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8015d3:	83 f0 1f             	xor    $0x1f,%eax
  8015d6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015da:	0f 84 a8 00 00 00    	je     801688 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8015e0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015e4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015e6:	bf 20 00 00 00       	mov    $0x20,%edi
  8015eb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8015ef:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015f3:	89 f9                	mov    %edi,%ecx
  8015f5:	d3 e8                	shr    %cl,%eax
  8015f7:	09 e8                	or     %ebp,%eax
  8015f9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8015fd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801601:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801605:	d3 e0                	shl    %cl,%eax
  801607:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80160b:	89 f2                	mov    %esi,%edx
  80160d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80160f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801613:	d3 e0                	shl    %cl,%eax
  801615:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801619:	8b 44 24 14          	mov    0x14(%esp),%eax
  80161d:	89 f9                	mov    %edi,%ecx
  80161f:	d3 e8                	shr    %cl,%eax
  801621:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801623:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801625:	89 f2                	mov    %esi,%edx
  801627:	f7 74 24 18          	divl   0x18(%esp)
  80162b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80162d:	f7 64 24 0c          	mull   0xc(%esp)
  801631:	89 c5                	mov    %eax,%ebp
  801633:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801635:	39 d6                	cmp    %edx,%esi
  801637:	72 67                	jb     8016a0 <__umoddi3+0x114>
  801639:	74 75                	je     8016b0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80163b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80163f:	29 e8                	sub    %ebp,%eax
  801641:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801643:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801647:	d3 e8                	shr    %cl,%eax
  801649:	89 f2                	mov    %esi,%edx
  80164b:	89 f9                	mov    %edi,%ecx
  80164d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80164f:	09 d0                	or     %edx,%eax
  801651:	89 f2                	mov    %esi,%edx
  801653:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801657:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801659:	83 c4 20             	add    $0x20,%esp
  80165c:	5e                   	pop    %esi
  80165d:	5f                   	pop    %edi
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801660:	85 c9                	test   %ecx,%ecx
  801662:	75 0b                	jne    80166f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801664:	b8 01 00 00 00       	mov    $0x1,%eax
  801669:	31 d2                	xor    %edx,%edx
  80166b:	f7 f1                	div    %ecx
  80166d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80166f:	89 f0                	mov    %esi,%eax
  801671:	31 d2                	xor    %edx,%edx
  801673:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801675:	89 f8                	mov    %edi,%eax
  801677:	e9 3e ff ff ff       	jmp    8015ba <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80167c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80167e:	83 c4 20             	add    $0x20,%esp
  801681:	5e                   	pop    %esi
  801682:	5f                   	pop    %edi
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    
  801685:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801688:	39 f5                	cmp    %esi,%ebp
  80168a:	72 04                	jb     801690 <__umoddi3+0x104>
  80168c:	39 f9                	cmp    %edi,%ecx
  80168e:	77 06                	ja     801696 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801690:	89 f2                	mov    %esi,%edx
  801692:	29 cf                	sub    %ecx,%edi
  801694:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801696:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801698:	83 c4 20             	add    $0x20,%esp
  80169b:	5e                   	pop    %esi
  80169c:	5f                   	pop    %edi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    
  80169f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8016a0:	89 d1                	mov    %edx,%ecx
  8016a2:	89 c5                	mov    %eax,%ebp
  8016a4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8016a8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8016ac:	eb 8d                	jmp    80163b <__umoddi3+0xaf>
  8016ae:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016b0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8016b4:	72 ea                	jb     8016a0 <__umoddi3+0x114>
  8016b6:	89 f1                	mov    %esi,%ecx
  8016b8:	eb 81                	jmp    80163b <__umoddi3+0xaf>
