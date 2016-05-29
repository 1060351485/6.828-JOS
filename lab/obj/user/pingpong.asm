
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 49 0f 00 00       	call   800f8b <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 03 0b 00 00       	call   800b53 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 e0 16 80 00 	movl   $0x8016e0,(%esp)
  80005f:	e8 90 01 00 00       	call   8001f4 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 5e 12 00 00       	call   8012e5 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 da 11 00 00       	call   80127c <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 a7 0a 00 00       	call   800b53 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 f6 16 80 00 	movl   $0x8016f6,(%esp)
  8000bf:	e8 30 01 00 00       	call   8001f4 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 25                	je     8000ee <umain+0xba>
			return;
		i++;
  8000c9:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d1:	00 
  8000d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d9:	00 
  8000da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 04 24             	mov    %eax,(%esp)
  8000e4:	e8 fc 11 00 00       	call   8012e5 <ipc_send>
		if (i == 10)
  8000e9:	83 fb 0a             	cmp    $0xa,%ebx
  8000ec:	75 9c                	jne    80008a <umain+0x56>
			return;
	}

}
  8000ee:	83 c4 2c             	add    $0x2c,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800106:	e8 48 0a 00 00       	call   800b53 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	c1 e0 07             	shl    $0x7,%eax
  800113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800118:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011d:	85 f6                	test   %esi,%esi
  80011f:	7e 07                	jle    800128 <libmain+0x30>
		binaryname = argv[0];
  800121:	8b 03                	mov    (%ebx),%eax
  800123:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800128:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80012c:	89 34 24             	mov    %esi,(%esp)
  80012f:	e8 00 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800134:	e8 07 00 00 00       	call   800140 <exit>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800146:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014d:	e8 af 09 00 00       	call   800b01 <sys_env_destroy>
}
  800152:	c9                   	leave  
  800153:	c3                   	ret    

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
  800269:	e8 0e 12 00 00       	call   80147c <__udivdi3>
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
  8002bc:	e8 db 12 00 00       	call   80159c <__umoddi3>
  8002c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c5:	0f be 80 13 17 80 00 	movsbl 0x801713(%eax),%eax
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
  8003e0:	ff 24 95 60 18 80 00 	jmp    *0x801860(,%edx,4)
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
  800469:	83 f8 11             	cmp    $0x11,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x123>
  80046e:	8b 04 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%eax
  800475:	85 c0                	test   %eax,%eax
  800477:	75 23                	jne    80049c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800479:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80047d:	c7 44 24 08 2b 17 80 	movl   $0x80172b,0x8(%esp)
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
  8004a0:	c7 44 24 08 34 17 80 	movl   $0x801734,0x8(%esp)
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
  8004d6:	be 24 17 80 00       	mov    $0x801724,%esi
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
  800b2f:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800b36:	00 
  800b37:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b3e:	00 
  800b3f:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800b46:	e8 41 08 00 00       	call   80138c <_panic>

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
  800bc1:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800bc8:	00 
  800bc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd0:	00 
  800bd1:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800bd8:	e8 af 07 00 00       	call   80138c <_panic>

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
  800c14:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c23:	00 
  800c24:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800c2b:	e8 5c 07 00 00       	call   80138c <_panic>

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
  800c67:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c76:	00 
  800c77:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800c7e:	e8 09 07 00 00       	call   80138c <_panic>

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
  800cba:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc9:	00 
  800cca:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800cd1:	e8 b6 06 00 00       	call   80138c <_panic>

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
  800d0d:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800d14:	00 
  800d15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1c:	00 
  800d1d:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800d24:	e8 63 06 00 00       	call   80138c <_panic>

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
  800d60:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800d67:	00 
  800d68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6f:	00 
  800d70:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800d77:	e8 10 06 00 00       	call   80138c <_panic>

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
  800dd5:	c7 44 24 08 27 1a 80 	movl   $0x801a27,0x8(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de4:	00 
  800de5:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  800dec:	e8 9b 05 00 00       	call   80138c <_panic>

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

00800df9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	57                   	push   %edi
  800dfd:	56                   	push   %esi
  800dfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	ba 00 00 00 00       	mov    $0x0,%edx
  800e04:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e09:	89 d1                	mov    %edx,%ecx
  800e0b:	89 d3                	mov    %edx,%ebx
  800e0d:	89 d7                	mov    %edx,%edi
  800e0f:	89 d6                	mov    %edx,%esi
  800e11:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e23:	b8 10 00 00 00       	mov    $0x10,%eax
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2e:	89 df                	mov    %ebx,%edi
  800e30:	89 de                	mov    %ebx,%esi
  800e32:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e44:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	89 df                	mov    %ebx,%edi
  800e51:	89 de                	mov    %ebx,%esi
  800e53:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e60:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e65:	b8 11 00 00 00       	mov    $0x11,%eax
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	89 cb                	mov    %ecx,%ebx
  800e6f:	89 cf                	mov    %ecx,%edi
  800e71:	89 ce                	mov    %ecx,%esi
  800e73:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
	...

00800e7c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 24             	sub    $0x24,%esp
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e86:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800e88:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e8c:	75 20                	jne    800eae <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e8e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e92:	c7 44 24 08 54 1a 80 	movl   $0x801a54,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ea1:	00 
  800ea2:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  800ea9:	e8 de 04 00 00       	call   80138c <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eae:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800eb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec0:	f6 c4 08             	test   $0x8,%ah
  800ec3:	75 1c                	jne    800ee1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ec5:	c7 44 24 08 84 1a 80 	movl   $0x801a84,0x8(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed4:	00 
  800ed5:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  800edc:	e8 ab 04 00 00       	call   80138c <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ee1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ef0:	00 
  800ef1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef8:	e8 94 fc ff ff       	call   800b91 <sys_page_alloc>
  800efd:	85 c0                	test   %eax,%eax
  800eff:	79 20                	jns    800f21 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800f01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f05:	c7 44 24 08 df 1a 80 	movl   $0x801adf,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  800f1c:	e8 6b 04 00 00       	call   80138c <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800f21:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f28:	00 
  800f29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f2d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f34:	e8 df f9 ff ff       	call   800918 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f39:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f40:	00 
  800f41:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f5c:	e8 84 fc ff ff       	call   800be5 <sys_page_map>
  800f61:	85 c0                	test   %eax,%eax
  800f63:	79 20                	jns    800f85 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800f65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f69:	c7 44 24 08 f3 1a 80 	movl   $0x801af3,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  800f80:	e8 07 04 00 00       	call   80138c <_panic>

}
  800f85:	83 c4 24             	add    $0x24,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800f94:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  800f9b:	e8 44 04 00 00       	call   8013e4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fa0:	ba 07 00 00 00       	mov    $0x7,%edx
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	cd 30                	int    $0x30
  800fa9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fac:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 20                	jns    800fd3 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800fb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb7:	c7 44 24 08 05 1b 80 	movl   $0x801b05,0x8(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  800fc6:	00 
  800fc7:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  800fce:	e8 b9 03 00 00       	call   80138c <_panic>
	if (child_envid == 0) { // child
  800fd3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fd7:	75 1c                	jne    800ff5 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd9:	e8 75 fb ff ff       	call   800b53 <sys_getenvid>
  800fde:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe3:	c1 e0 07             	shl    $0x7,%eax
  800fe6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800feb:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ff0:	e9 58 02 00 00       	jmp    80124d <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800ff5:	bf 00 00 00 00       	mov    $0x0,%edi
  800ffa:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fff:	89 f0                	mov    %esi,%eax
  801001:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801004:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100b:	a8 01                	test   $0x1,%al
  80100d:	0f 84 7a 01 00 00    	je     80118d <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801013:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80101a:	a8 01                	test   $0x1,%al
  80101c:	0f 84 6b 01 00 00    	je     80118d <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801022:	a1 04 20 80 00       	mov    0x802004,%eax
  801027:	8b 40 48             	mov    0x48(%eax),%eax
  80102a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  80102d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801034:	f6 c4 04             	test   $0x4,%ah
  801037:	74 52                	je     80108b <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801039:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801040:	25 07 0e 00 00       	and    $0xe07,%eax
  801045:	89 44 24 10          	mov    %eax,0x10(%esp)
  801049:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80104d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801050:	89 44 24 08          	mov    %eax,0x8(%esp)
  801054:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801058:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105b:	89 04 24             	mov    %eax,(%esp)
  80105e:	e8 82 fb ff ff       	call   800be5 <sys_page_map>
  801063:	85 c0                	test   %eax,%eax
  801065:	0f 89 22 01 00 00    	jns    80118d <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80106b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80106f:	c7 44 24 08 f3 1a 80 	movl   $0x801af3,0x8(%esp)
  801076:	00 
  801077:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80107e:	00 
  80107f:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  801086:	e8 01 03 00 00       	call   80138c <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80108b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801092:	f6 c4 08             	test   $0x8,%ah
  801095:	75 0f                	jne    8010a6 <fork+0x11b>
  801097:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109e:	a8 02                	test   $0x2,%al
  8010a0:	0f 84 99 00 00 00    	je     80113f <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  8010a6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ad:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8010b0:	83 f8 01             	cmp    $0x1,%eax
  8010b3:	19 db                	sbb    %ebx,%ebx
  8010b5:	83 e3 fc             	and    $0xfffffffc,%ebx
  8010b8:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010be:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d4:	89 04 24             	mov    %eax,(%esp)
  8010d7:	e8 09 fb ff ff       	call   800be5 <sys_page_map>
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	79 20                	jns    801100 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  8010e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e4:	c7 44 24 08 f3 1a 80 	movl   $0x801af3,0x8(%esp)
  8010eb:	00 
  8010ec:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010f3:	00 
  8010f4:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  8010fb:	e8 8c 02 00 00       	call   80138c <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801100:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801104:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801113:	89 04 24             	mov    %eax,(%esp)
  801116:	e8 ca fa ff ff       	call   800be5 <sys_page_map>
  80111b:	85 c0                	test   %eax,%eax
  80111d:	79 6e                	jns    80118d <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80111f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801123:	c7 44 24 08 f3 1a 80 	movl   $0x801af3,0x8(%esp)
  80112a:	00 
  80112b:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801132:	00 
  801133:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  80113a:	e8 4d 02 00 00       	call   80138c <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80113f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801146:	25 07 0e 00 00       	and    $0xe07,%eax
  80114b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801153:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801156:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80115e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801161:	89 04 24             	mov    %eax,(%esp)
  801164:	e8 7c fa ff ff       	call   800be5 <sys_page_map>
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 20                	jns    80118d <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80116d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801171:	c7 44 24 08 f3 1a 80 	movl   $0x801af3,0x8(%esp)
  801178:	00 
  801179:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801180:	00 
  801181:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  801188:	e8 ff 01 00 00       	call   80138c <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80118d:	46                   	inc    %esi
  80118e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801194:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80119a:	0f 85 5f fe ff ff    	jne    800fff <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8011a0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011af:	ee 
  8011b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011b3:	89 04 24             	mov    %eax,(%esp)
  8011b6:	e8 d6 f9 ff ff       	call   800b91 <sys_page_alloc>
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	79 20                	jns    8011df <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  8011bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c3:	c7 44 24 08 df 1a 80 	movl   $0x801adf,0x8(%esp)
  8011ca:	00 
  8011cb:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011d2:	00 
  8011d3:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  8011da:	e8 ad 01 00 00       	call   80138c <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8011df:	c7 44 24 04 58 14 80 	movl   $0x801458,0x4(%esp)
  8011e6:	00 
  8011e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011ea:	89 04 24             	mov    %eax,(%esp)
  8011ed:	e8 3f fb ff ff       	call   800d31 <sys_env_set_pgfault_upcall>
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	79 20                	jns    801216 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8011f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011fa:	c7 44 24 08 b4 1a 80 	movl   $0x801ab4,0x8(%esp)
  801201:	00 
  801202:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801209:	00 
  80120a:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  801211:	e8 76 01 00 00       	call   80138c <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801216:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80121d:	00 
  80121e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801221:	89 04 24             	mov    %eax,(%esp)
  801224:	e8 62 fa ff ff       	call   800c8b <sys_env_set_status>
  801229:	85 c0                	test   %eax,%eax
  80122b:	79 20                	jns    80124d <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  80122d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801231:	c7 44 24 08 16 1b 80 	movl   $0x801b16,0x8(%esp)
  801238:	00 
  801239:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801240:	00 
  801241:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  801248:	e8 3f 01 00 00       	call   80138c <_panic>

	return child_envid;
}
  80124d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801250:	83 c4 3c             	add    $0x3c,%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <sfork>:

// Challenge!
int
sfork(void)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80125e:	c7 44 24 08 2e 1b 80 	movl   $0x801b2e,0x8(%esp)
  801265:	00 
  801266:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80126d:	00 
  80126e:	c7 04 24 d4 1a 80 00 	movl   $0x801ad4,(%esp)
  801275:	e8 12 01 00 00       	call   80138c <_panic>
	...

0080127c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	56                   	push   %esi
  801280:	53                   	push   %ebx
  801281:	83 ec 10             	sub    $0x10,%esp
  801284:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  80128d:	85 c0                	test   %eax,%eax
  80128f:	75 05                	jne    801296 <ipc_recv+0x1a>
  801291:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	e8 09 fb ff ff       	call   800da7 <sys_ipc_recv>
	if (from_env_store != NULL)
  80129e:	85 db                	test   %ebx,%ebx
  8012a0:	74 0b                	je     8012ad <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8012a2:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8012a8:	8b 52 74             	mov    0x74(%edx),%edx
  8012ab:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8012ad:	85 f6                	test   %esi,%esi
  8012af:	74 0b                	je     8012bc <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8012b1:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8012b7:	8b 52 78             	mov    0x78(%edx),%edx
  8012ba:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	79 16                	jns    8012d6 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8012c0:	85 db                	test   %ebx,%ebx
  8012c2:	74 06                	je     8012ca <ipc_recv+0x4e>
			*from_env_store = 0;
  8012c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8012ca:	85 f6                	test   %esi,%esi
  8012cc:	74 10                	je     8012de <ipc_recv+0x62>
			*perm_store = 0;
  8012ce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8012d4:	eb 08                	jmp    8012de <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8012d6:	a1 04 20 80 00       	mov    0x802004,%eax
  8012db:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	57                   	push   %edi
  8012e9:	56                   	push   %esi
  8012ea:	53                   	push   %ebx
  8012eb:	83 ec 1c             	sub    $0x1c,%esp
  8012ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8012f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8012f7:	eb 2a                	jmp    801323 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8012f9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012fc:	74 20                	je     80131e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8012fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801302:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 69 1b 80 00 	movl   $0x801b69,(%esp)
  801319:	e8 6e 00 00 00       	call   80138c <_panic>
		sys_yield();
  80131e:	e8 4f f8 ff ff       	call   800b72 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801323:	85 db                	test   %ebx,%ebx
  801325:	75 07                	jne    80132e <ipc_send+0x49>
  801327:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80132c:	eb 02                	jmp    801330 <ipc_send+0x4b>
  80132e:	89 d8                	mov    %ebx,%eax
  801330:	8b 55 14             	mov    0x14(%ebp),%edx
  801333:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801337:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133f:	89 34 24             	mov    %esi,(%esp)
  801342:	e8 3d fa ff ff       	call   800d84 <sys_ipc_try_send>
  801347:	85 c0                	test   %eax,%eax
  801349:	78 ae                	js     8012f9 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80134b:	83 c4 1c             	add    $0x1c,%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80135e:	89 c2                	mov    %eax,%edx
  801360:	c1 e2 07             	shl    $0x7,%edx
  801363:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801369:	8b 52 50             	mov    0x50(%edx),%edx
  80136c:	39 ca                	cmp    %ecx,%edx
  80136e:	75 0d                	jne    80137d <ipc_find_env+0x2a>
			return envs[i].env_id;
  801370:	c1 e0 07             	shl    $0x7,%eax
  801373:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801378:	8b 40 40             	mov    0x40(%eax),%eax
  80137b:	eb 0c                	jmp    801389 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80137d:	40                   	inc    %eax
  80137e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801383:	75 d9                	jne    80135e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801385:	66 b8 00 00          	mov    $0x0,%ax
}
  801389:	5d                   	pop    %ebp
  80138a:	c3                   	ret    
	...

0080138c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	56                   	push   %esi
  801390:	53                   	push   %ebx
  801391:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801394:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801397:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80139d:	e8 b1 f7 ff ff       	call   800b53 <sys_getenvid>
  8013a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	c7 04 24 74 1b 80 00 	movl   $0x801b74,(%esp)
  8013bf:	e8 30 ee ff ff       	call   8001f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 c0 ed ff ff       	call   800193 <vcprintf>
	cprintf("\n");
  8013d3:	c7 04 24 f1 1a 80 00 	movl   $0x801af1,(%esp)
  8013da:	e8 15 ee ff ff       	call   8001f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013df:	cc                   	int3   
  8013e0:	eb fd                	jmp    8013df <_panic+0x53>
	...

008013e4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8013ea:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8013f1:	75 58                	jne    80144b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8013f3:	a1 04 20 80 00       	mov    0x802004,%eax
  8013f8:	8b 40 48             	mov    0x48(%eax),%eax
  8013fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801402:	00 
  801403:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80140a:	ee 
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 7e f7 ff ff       	call   800b91 <sys_page_alloc>
  801413:	85 c0                	test   %eax,%eax
  801415:	74 1c                	je     801433 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801417:	c7 44 24 08 98 1b 80 	movl   $0x801b98,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801426:	00 
  801427:	c7 04 24 ad 1b 80 00 	movl   $0x801bad,(%esp)
  80142e:	e8 59 ff ff ff       	call   80138c <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801433:	a1 04 20 80 00       	mov    0x802004,%eax
  801438:	8b 40 48             	mov    0x48(%eax),%eax
  80143b:	c7 44 24 04 58 14 80 	movl   $0x801458,0x4(%esp)
  801442:	00 
  801443:	89 04 24             	mov    %eax,(%esp)
  801446:	e8 e6 f8 ff ff       	call   800d31 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80144b:	8b 45 08             	mov    0x8(%ebp),%eax
  80144e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801453:	c9                   	leave  
  801454:	c3                   	ret    
  801455:	00 00                	add    %al,(%eax)
	...

00801458 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801458:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801459:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80145e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801460:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  801463:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801467:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801469:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  80146d:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80146e:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801471:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  801473:	58                   	pop    %eax
	popl %eax
  801474:	58                   	pop    %eax

	// Pop all registers back
	popal
  801475:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801476:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801479:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80147a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80147b:	c3                   	ret    

0080147c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80147c:	55                   	push   %ebp
  80147d:	57                   	push   %edi
  80147e:	56                   	push   %esi
  80147f:	83 ec 10             	sub    $0x10,%esp
  801482:	8b 74 24 20          	mov    0x20(%esp),%esi
  801486:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80148a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80148e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801492:	89 cd                	mov    %ecx,%ebp
  801494:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801498:	85 c0                	test   %eax,%eax
  80149a:	75 2c                	jne    8014c8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80149c:	39 f9                	cmp    %edi,%ecx
  80149e:	77 68                	ja     801508 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8014a0:	85 c9                	test   %ecx,%ecx
  8014a2:	75 0b                	jne    8014af <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8014a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014a9:	31 d2                	xor    %edx,%edx
  8014ab:	f7 f1                	div    %ecx
  8014ad:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8014af:	31 d2                	xor    %edx,%edx
  8014b1:	89 f8                	mov    %edi,%eax
  8014b3:	f7 f1                	div    %ecx
  8014b5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014b7:	89 f0                	mov    %esi,%eax
  8014b9:	f7 f1                	div    %ecx
  8014bb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014bd:	89 f0                	mov    %esi,%eax
  8014bf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	5e                   	pop    %esi
  8014c5:	5f                   	pop    %edi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014c8:	39 f8                	cmp    %edi,%eax
  8014ca:	77 2c                	ja     8014f8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8014cc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8014cf:	83 f6 1f             	xor    $0x1f,%esi
  8014d2:	75 4c                	jne    801520 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014d4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014d6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014db:	72 0a                	jb     8014e7 <__udivdi3+0x6b>
  8014dd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8014e1:	0f 87 ad 00 00 00    	ja     801594 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014e7:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014f8:	31 ff                	xor    %edi,%edi
  8014fa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014fc:	89 f0                	mov    %esi,%eax
  8014fe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801500:	83 c4 10             	add    $0x10,%esp
  801503:	5e                   	pop    %esi
  801504:	5f                   	pop    %edi
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    
  801507:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801508:	89 fa                	mov    %edi,%edx
  80150a:	89 f0                	mov    %esi,%eax
  80150c:	f7 f1                	div    %ecx
  80150e:	89 c6                	mov    %eax,%esi
  801510:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801512:	89 f0                	mov    %esi,%eax
  801514:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    
  80151d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801520:	89 f1                	mov    %esi,%ecx
  801522:	d3 e0                	shl    %cl,%eax
  801524:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801528:	b8 20 00 00 00       	mov    $0x20,%eax
  80152d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80152f:	89 ea                	mov    %ebp,%edx
  801531:	88 c1                	mov    %al,%cl
  801533:	d3 ea                	shr    %cl,%edx
  801535:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801539:	09 ca                	or     %ecx,%edx
  80153b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80153f:	89 f1                	mov    %esi,%ecx
  801541:	d3 e5                	shl    %cl,%ebp
  801543:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801547:	89 fd                	mov    %edi,%ebp
  801549:	88 c1                	mov    %al,%cl
  80154b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80154d:	89 fa                	mov    %edi,%edx
  80154f:	89 f1                	mov    %esi,%ecx
  801551:	d3 e2                	shl    %cl,%edx
  801553:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801557:	88 c1                	mov    %al,%cl
  801559:	d3 ef                	shr    %cl,%edi
  80155b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80155d:	89 f8                	mov    %edi,%eax
  80155f:	89 ea                	mov    %ebp,%edx
  801561:	f7 74 24 08          	divl   0x8(%esp)
  801565:	89 d1                	mov    %edx,%ecx
  801567:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801569:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80156d:	39 d1                	cmp    %edx,%ecx
  80156f:	72 17                	jb     801588 <__udivdi3+0x10c>
  801571:	74 09                	je     80157c <__udivdi3+0x100>
  801573:	89 fe                	mov    %edi,%esi
  801575:	31 ff                	xor    %edi,%edi
  801577:	e9 41 ff ff ff       	jmp    8014bd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80157c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801580:	89 f1                	mov    %esi,%ecx
  801582:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801584:	39 c2                	cmp    %eax,%edx
  801586:	73 eb                	jae    801573 <__udivdi3+0xf7>
		{
		  q0--;
  801588:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80158b:	31 ff                	xor    %edi,%edi
  80158d:	e9 2b ff ff ff       	jmp    8014bd <__udivdi3+0x41>
  801592:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801594:	31 f6                	xor    %esi,%esi
  801596:	e9 22 ff ff ff       	jmp    8014bd <__udivdi3+0x41>
	...

0080159c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80159c:	55                   	push   %ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	83 ec 20             	sub    $0x20,%esp
  8015a2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8015a6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8015aa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8015ae:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8015b2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8015b6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8015ba:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8015bc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8015be:	85 ed                	test   %ebp,%ebp
  8015c0:	75 16                	jne    8015d8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8015c2:	39 f1                	cmp    %esi,%ecx
  8015c4:	0f 86 a6 00 00 00    	jbe    801670 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8015ca:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8015cc:	89 d0                	mov    %edx,%eax
  8015ce:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8015d0:	83 c4 20             	add    $0x20,%esp
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    
  8015d7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8015d8:	39 f5                	cmp    %esi,%ebp
  8015da:	0f 87 ac 00 00 00    	ja     80168c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8015e0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8015e3:	83 f0 1f             	xor    $0x1f,%eax
  8015e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ea:	0f 84 a8 00 00 00    	je     801698 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8015f0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015f4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8015f6:	bf 20 00 00 00       	mov    $0x20,%edi
  8015fb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8015ff:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801603:	89 f9                	mov    %edi,%ecx
  801605:	d3 e8                	shr    %cl,%eax
  801607:	09 e8                	or     %ebp,%eax
  801609:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80160d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801611:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801615:	d3 e0                	shl    %cl,%eax
  801617:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80161b:	89 f2                	mov    %esi,%edx
  80161d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80161f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801623:	d3 e0                	shl    %cl,%eax
  801625:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801629:	8b 44 24 14          	mov    0x14(%esp),%eax
  80162d:	89 f9                	mov    %edi,%ecx
  80162f:	d3 e8                	shr    %cl,%eax
  801631:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801633:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801635:	89 f2                	mov    %esi,%edx
  801637:	f7 74 24 18          	divl   0x18(%esp)
  80163b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80163d:	f7 64 24 0c          	mull   0xc(%esp)
  801641:	89 c5                	mov    %eax,%ebp
  801643:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801645:	39 d6                	cmp    %edx,%esi
  801647:	72 67                	jb     8016b0 <__umoddi3+0x114>
  801649:	74 75                	je     8016c0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80164b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80164f:	29 e8                	sub    %ebp,%eax
  801651:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801653:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801657:	d3 e8                	shr    %cl,%eax
  801659:	89 f2                	mov    %esi,%edx
  80165b:	89 f9                	mov    %edi,%ecx
  80165d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80165f:	09 d0                	or     %edx,%eax
  801661:	89 f2                	mov    %esi,%edx
  801663:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801667:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801669:	83 c4 20             	add    $0x20,%esp
  80166c:	5e                   	pop    %esi
  80166d:	5f                   	pop    %edi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801670:	85 c9                	test   %ecx,%ecx
  801672:	75 0b                	jne    80167f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801674:	b8 01 00 00 00       	mov    $0x1,%eax
  801679:	31 d2                	xor    %edx,%edx
  80167b:	f7 f1                	div    %ecx
  80167d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80167f:	89 f0                	mov    %esi,%eax
  801681:	31 d2                	xor    %edx,%edx
  801683:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801685:	89 f8                	mov    %edi,%eax
  801687:	e9 3e ff ff ff       	jmp    8015ca <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80168c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80168e:	83 c4 20             	add    $0x20,%esp
  801691:	5e                   	pop    %esi
  801692:	5f                   	pop    %edi
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    
  801695:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801698:	39 f5                	cmp    %esi,%ebp
  80169a:	72 04                	jb     8016a0 <__umoddi3+0x104>
  80169c:	39 f9                	cmp    %edi,%ecx
  80169e:	77 06                	ja     8016a6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8016a0:	89 f2                	mov    %esi,%edx
  8016a2:	29 cf                	sub    %ecx,%edi
  8016a4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8016a6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016a8:	83 c4 20             	add    $0x20,%esp
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    
  8016af:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8016b0:	89 d1                	mov    %edx,%ecx
  8016b2:	89 c5                	mov    %eax,%ebp
  8016b4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8016b8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8016bc:	eb 8d                	jmp    80164b <__umoddi3+0xaf>
  8016be:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8016c0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8016c4:	72 ea                	jb     8016b0 <__umoddi3+0x114>
  8016c6:	89 f1                	mov    %esi,%ecx
  8016c8:	eb 81                	jmp    80164b <__umoddi3+0xaf>
