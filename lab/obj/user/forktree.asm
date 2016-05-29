
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 0c 0b 00 00       	call   800b4f <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  800052:	e8 99 01 00 00       	call   8001f0 <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	53                   	push   %ebx
  800081:	83 ec 44             	sub    $0x44,%esp
  800084:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800087:	8a 45 0c             	mov    0xc(%ebp),%al
  80008a:	88 45 e7             	mov    %al,-0x19(%ebp)
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008d:	89 1c 24             	mov    %ebx,(%esp)
  800090:	e8 d3 06 00 00       	call   800768 <strlen>
  800095:	83 f8 02             	cmp    $0x2,%eax
  800098:	7f 40                	jg     8000da <forkchild+0x5d>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  80009e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a6:	c7 44 24 08 d1 15 80 	movl   $0x8015d1,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b5:	00 
  8000b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 7c 06 00 00       	call   80073d <snprintf>
	if (fork() == 0) {
  8000c1:	e8 c1 0e 00 00       	call   800f87 <fork>
  8000c6:	85 c0                	test   %eax,%eax
  8000c8:	75 10                	jne    8000da <forkchild+0x5d>
		forktree(nxt);
  8000ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cd:	89 04 24             	mov    %eax,(%esp)
  8000d0:	e8 5f ff ff ff       	call   800034 <forktree>
		exit();
  8000d5:	e8 62 00 00 00       	call   80013c <exit>
	}
}
  8000da:	83 c4 44             	add    $0x44,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 d0 15 80 00 	movl   $0x8015d0,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800102:	e8 48 0a 00 00       	call   800b4f <sys_getenvid>
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	c1 e0 07             	shl    $0x7,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 f6                	test   %esi,%esi
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 03                	mov    (%ebx),%eax
  80011f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800128:	89 34 24             	mov    %esi,(%esp)
  80012b:	e8 b0 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800149:	e8 af 09 00 00       	call   800afd <sys_env_destroy>
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	53                   	push   %ebx
  800154:	83 ec 14             	sub    $0x14,%esp
  800157:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015a:	8b 03                	mov    (%ebx),%eax
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800163:	40                   	inc    %eax
  800164:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800166:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016b:	75 19                	jne    800186 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80016d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800174:	00 
  800175:	8d 43 08             	lea    0x8(%ebx),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 40 09 00 00       	call   800ac0 <sys_cputs>
		b->idx = 0;
  800180:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800186:	ff 43 04             	incl   0x4(%ebx)
}
  800189:	83 c4 14             	add    $0x14,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800198:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019f:	00 00 00 
	b.cnt = 0;
  8001a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c4:	c7 04 24 50 01 80 00 	movl   $0x800150,(%esp)
  8001cb:	e8 82 01 00 00       	call   800352 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	89 04 24             	mov    %eax,(%esp)
  8001e3:	e8 d8 08 00 00       	call   800ac0 <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800200:	89 04 24             	mov    %eax,(%esp)
  800203:	e8 87 ff ff ff       	call   80018f <vcprintf>
	va_end(ap);

	return cnt;
}
  800208:	c9                   	leave  
  800209:	c3                   	ret    
	...

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 3c             	sub    $0x3c,%esp
  800215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800218:	89 d7                	mov    %edx,%edi
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800226:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800229:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022c:	85 c0                	test   %eax,%eax
  80022e:	75 08                	jne    800238 <printnum+0x2c>
  800230:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800233:	39 45 10             	cmp    %eax,0x10(%ebp)
  800236:	77 57                	ja     80028f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	89 74 24 10          	mov    %esi,0x10(%esp)
  80023c:	4b                   	dec    %ebx
  80023d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800241:	8b 45 10             	mov    0x10(%ebp),%eax
  800244:	89 44 24 08          	mov    %eax,0x8(%esp)
  800248:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80024c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800250:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800257:	00 
  800258:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800261:	89 44 24 04          	mov    %eax,0x4(%esp)
  800265:	e8 fe 10 00 00       	call   801368 <__udivdi3>
  80026a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80026e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	89 54 24 04          	mov    %edx,0x4(%esp)
  800279:	89 fa                	mov    %edi,%edx
  80027b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027e:	e8 89 ff ff ff       	call   80020c <printnum>
  800283:	eb 0f                	jmp    800294 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800289:	89 34 24             	mov    %esi,(%esp)
  80028c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	4b                   	dec    %ebx
  800290:	85 db                	test   %ebx,%ebx
  800292:	7f f1                	jg     800285 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800294:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800298:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80029c:	8b 45 10             	mov    0x10(%ebp),%eax
  80029f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002aa:	00 
  8002ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ae:	89 04 24             	mov    %eax,(%esp)
  8002b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	e8 cb 11 00 00       	call   801488 <__umoddi3>
  8002bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c1:	0f be 80 e0 15 80 00 	movsbl 0x8015e0(%eax),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ce:	83 c4 3c             	add    $0x3c,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d9:	83 fa 01             	cmp    $0x1,%edx
  8002dc:	7e 0e                	jle    8002ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ea:	eb 22                	jmp    80030e <getuint+0x38>
	else if (lflag)
  8002ec:	85 d2                	test   %edx,%edx
  8002ee:	74 10                	je     800300 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 0e                	jmp    80030e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800316:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	3b 50 04             	cmp    0x4(%eax),%edx
  80031e:	73 08                	jae    800328 <sprintputch+0x18>
		*b->buf++ = ch;
  800320:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800323:	88 0a                	mov    %cl,(%edx)
  800325:	42                   	inc    %edx
  800326:	89 10                	mov    %edx,(%eax)
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800330:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800333:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800337:	8b 45 10             	mov    0x10(%ebp),%eax
  80033a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800341:	89 44 24 04          	mov    %eax,0x4(%esp)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	e8 02 00 00 00       	call   800352 <vprintfmt>
	va_end(ap);
}
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	57                   	push   %edi
  800356:	56                   	push   %esi
  800357:	53                   	push   %ebx
  800358:	83 ec 4c             	sub    $0x4c,%esp
  80035b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035e:	8b 75 10             	mov    0x10(%ebp),%esi
  800361:	eb 12                	jmp    800375 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800363:	85 c0                	test   %eax,%eax
  800365:	0f 84 6b 03 00 00    	je     8006d6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80036b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800375:	0f b6 06             	movzbl (%esi),%eax
  800378:	46                   	inc    %esi
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e5                	jne    800363 <vprintfmt+0x11>
  80037e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800382:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800389:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80038e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800395:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039a:	eb 26                	jmp    8003c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80039f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003a3:	eb 1d                	jmp    8003c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ac:	eb 14                	jmp    8003c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b8:	eb 08                	jmp    8003c2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	0f b6 06             	movzbl (%esi),%eax
  8003c5:	8d 56 01             	lea    0x1(%esi),%edx
  8003c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003cb:	8a 16                	mov    (%esi),%dl
  8003cd:	83 ea 23             	sub    $0x23,%edx
  8003d0:	80 fa 55             	cmp    $0x55,%dl
  8003d3:	0f 87 e1 02 00 00    	ja     8006ba <vprintfmt+0x368>
  8003d9:	0f b6 d2             	movzbl %dl,%edx
  8003dc:	ff 24 95 20 17 80 00 	jmp    *0x801720(,%edx,4)
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003eb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ee:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003f2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003f8:	83 fa 09             	cmp    $0x9,%edx
  8003fb:	77 2a                	ja     800427 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fe:	eb eb                	jmp    8003eb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040e:	eb 17                	jmp    800427 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800410:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800414:	78 98                	js     8003ae <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800419:	eb a7                	jmp    8003c2 <vprintfmt+0x70>
  80041b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800425:	eb 9b                	jmp    8003c2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800427:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042b:	79 95                	jns    8003c2 <vprintfmt+0x70>
  80042d:	eb 8b                	jmp    8003ba <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	eb 8d                	jmp    8003c2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800442:	8b 00                	mov    (%eax),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044d:	e9 23 ff ff ff       	jmp    800375 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	85 c0                	test   %eax,%eax
  80045f:	79 02                	jns    800463 <vprintfmt+0x111>
  800461:	f7 d8                	neg    %eax
  800463:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800465:	83 f8 11             	cmp    $0x11,%eax
  800468:	7f 0b                	jg     800475 <vprintfmt+0x123>
  80046a:	8b 04 85 80 18 80 00 	mov    0x801880(,%eax,4),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	75 23                	jne    800498 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800475:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800479:	c7 44 24 08 f8 15 80 	movl   $0x8015f8,0x8(%esp)
  800480:	00 
  800481:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800485:	8b 45 08             	mov    0x8(%ebp),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	e8 9a fe ff ff       	call   80032a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800493:	e9 dd fe ff ff       	jmp    800375 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800498:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049c:	c7 44 24 08 01 16 80 	movl   $0x801601,0x8(%esp)
  8004a3:	00 
  8004a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ab:	89 14 24             	mov    %edx,(%esp)
  8004ae:	e8 77 fe ff ff       	call   80032a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004b6:	e9 ba fe ff ff       	jmp    800375 <vprintfmt+0x23>
  8004bb:	89 f9                	mov    %edi,%ecx
  8004bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 50 04             	lea    0x4(%eax),%edx
  8004c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cc:	8b 30                	mov    (%eax),%esi
  8004ce:	85 f6                	test   %esi,%esi
  8004d0:	75 05                	jne    8004d7 <vprintfmt+0x185>
				p = "(null)";
  8004d2:	be f1 15 80 00       	mov    $0x8015f1,%esi
			if (width > 0 && padc != '-')
  8004d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004db:	0f 8e 84 00 00 00    	jle    800565 <vprintfmt+0x213>
  8004e1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004e5:	74 7e                	je     800565 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004eb:	89 34 24             	mov    %esi,(%esp)
  8004ee:	e8 8b 02 00 00       	call   80077e <strnlen>
  8004f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004f6:	29 c2                	sub    %eax,%edx
  8004f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004fb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004ff:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800502:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800505:	89 de                	mov    %ebx,%esi
  800507:	89 d3                	mov    %edx,%ebx
  800509:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	eb 0b                	jmp    800518 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80050d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800511:	89 3c 24             	mov    %edi,(%esp)
  800514:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	4b                   	dec    %ebx
  800518:	85 db                	test   %ebx,%ebx
  80051a:	7f f1                	jg     80050d <vprintfmt+0x1bb>
  80051c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80051f:	89 f3                	mov    %esi,%ebx
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800524:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	79 05                	jns    800530 <vprintfmt+0x1de>
  80052b:	b8 00 00 00 00       	mov    $0x0,%eax
  800530:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800533:	29 c2                	sub    %eax,%edx
  800535:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800538:	eb 2b                	jmp    800565 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053e:	74 18                	je     800558 <vprintfmt+0x206>
  800540:	8d 50 e0             	lea    -0x20(%eax),%edx
  800543:	83 fa 5e             	cmp    $0x5e,%edx
  800546:	76 10                	jbe    800558 <vprintfmt+0x206>
					putch('?', putdat);
  800548:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	eb 0a                	jmp    800562 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800558:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800562:	ff 4d e4             	decl   -0x1c(%ebp)
  800565:	0f be 06             	movsbl (%esi),%eax
  800568:	46                   	inc    %esi
  800569:	85 c0                	test   %eax,%eax
  80056b:	74 21                	je     80058e <vprintfmt+0x23c>
  80056d:	85 ff                	test   %edi,%edi
  80056f:	78 c9                	js     80053a <vprintfmt+0x1e8>
  800571:	4f                   	dec    %edi
  800572:	79 c6                	jns    80053a <vprintfmt+0x1e8>
  800574:	8b 7d 08             	mov    0x8(%ebp),%edi
  800577:	89 de                	mov    %ebx,%esi
  800579:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80057c:	eb 18                	jmp    800596 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800582:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800589:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058b:	4b                   	dec    %ebx
  80058c:	eb 08                	jmp    800596 <vprintfmt+0x244>
  80058e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800591:	89 de                	mov    %ebx,%esi
  800593:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800596:	85 db                	test   %ebx,%ebx
  800598:	7f e4                	jg     80057e <vprintfmt+0x22c>
  80059a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80059d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a2:	e9 ce fd ff ff       	jmp    800375 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a7:	83 f9 01             	cmp    $0x1,%ecx
  8005aa:	7e 10                	jle    8005bc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 08             	lea    0x8(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 30                	mov    (%eax),%esi
  8005b7:	8b 78 04             	mov    0x4(%eax),%edi
  8005ba:	eb 26                	jmp    8005e2 <vprintfmt+0x290>
	else if (lflag)
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	74 12                	je     8005d2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	89 f7                	mov    %esi,%edi
  8005cd:	c1 ff 1f             	sar    $0x1f,%edi
  8005d0:	eb 10                	jmp    8005e2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 30                	mov    (%eax),%esi
  8005dd:	89 f7                	mov    %esi,%edi
  8005df:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e2:	85 ff                	test   %edi,%edi
  8005e4:	78 0a                	js     8005f0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005eb:	e9 8c 00 00 00       	jmp    80067c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005fe:	f7 de                	neg    %esi
  800600:	83 d7 00             	adc    $0x0,%edi
  800603:	f7 df                	neg    %edi
			}
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060a:	eb 70                	jmp    80067c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060c:	89 ca                	mov    %ecx,%edx
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 c0 fc ff ff       	call   8002d6 <getuint>
  800616:	89 c6                	mov    %eax,%esi
  800618:	89 d7                	mov    %edx,%edi
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80061f:	eb 5b                	jmp    80067c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800621:	89 ca                	mov    %ecx,%edx
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 ab fc ff ff       	call   8002d6 <getuint>
  80062b:	89 c6                	mov    %eax,%esi
  80062d:	89 d7                	mov    %edx,%edi
			base = 8;
  80062f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800634:	eb 46                	jmp    80067c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800636:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800641:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065b:	8b 30                	mov    (%eax),%esi
  80065d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800667:	eb 13                	jmp    80067c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800669:	89 ca                	mov    %ecx,%edx
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 63 fc ff ff       	call   8002d6 <getuint>
  800673:	89 c6                	mov    %eax,%esi
  800675:	89 d7                	mov    %edx,%edi
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800680:	89 54 24 10          	mov    %edx,0x10(%esp)
  800684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800687:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80068b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068f:	89 34 24             	mov    %esi,(%esp)
  800692:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800696:	89 da                	mov    %ebx,%edx
  800698:	8b 45 08             	mov    0x8(%ebp),%eax
  80069b:	e8 6c fb ff ff       	call   80020c <printnum>
			break;
  8006a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a3:	e9 cd fc ff ff       	jmp    800375 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ac:	89 04 24             	mov    %eax,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b5:	e9 bb fc ff ff       	jmp    800375 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c8:	eb 01                	jmp    8006cb <vprintfmt+0x379>
  8006ca:	4e                   	dec    %esi
  8006cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006cf:	75 f9                	jne    8006ca <vprintfmt+0x378>
  8006d1:	e9 9f fc ff ff       	jmp    800375 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006d6:	83 c4 4c             	add    $0x4c,%esp
  8006d9:	5b                   	pop    %ebx
  8006da:	5e                   	pop    %esi
  8006db:	5f                   	pop    %edi
  8006dc:	5d                   	pop    %ebp
  8006dd:	c3                   	ret    

008006de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	83 ec 28             	sub    $0x28,%esp
  8006e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	74 30                	je     80072f <vsnprintf+0x51>
  8006ff:	85 d2                	test   %edx,%edx
  800701:	7e 33                	jle    800736 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070a:	8b 45 10             	mov    0x10(%ebp),%eax
  80070d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800711:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	c7 04 24 10 03 80 00 	movl   $0x800310,(%esp)
  80071f:	e8 2e fc ff ff       	call   800352 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800727:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	eb 0c                	jmp    80073b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800734:	eb 05                	jmp    80073b <vsnprintf+0x5d>
  800736:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073b:	c9                   	leave  
  80073c:	c3                   	ret    

0080073d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800751:	8b 45 0c             	mov    0xc(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	e8 7b ff ff ff       	call   8006de <vsnprintf>
	va_end(ap);

	return rc;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    
  800765:	00 00                	add    %al,(%eax)
	...

00800768 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	b8 00 00 00 00       	mov    $0x0,%eax
  800773:	eb 01                	jmp    800776 <strlen+0xe>
		n++;
  800775:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077a:	75 f9                	jne    800775 <strlen+0xd>
		n++;
	return n;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
  80078c:	eb 01                	jmp    80078f <strnlen+0x11>
		n++;
  80078e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078f:	39 d0                	cmp    %edx,%eax
  800791:	74 06                	je     800799 <strnlen+0x1b>
  800793:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800797:	75 f5                	jne    80078e <strnlen+0x10>
		n++;
	return n;
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007aa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007b0:	42                   	inc    %edx
  8007b1:	84 c9                	test   %cl,%cl
  8007b3:	75 f5                	jne    8007aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c2:	89 1c 24             	mov    %ebx,(%esp)
  8007c5:	e8 9e ff ff ff       	call   800768 <strlen>
	strcpy(dst + len, src);
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d1:	01 d8                	add    %ebx,%eax
  8007d3:	89 04 24             	mov    %eax,(%esp)
  8007d6:	e8 c0 ff ff ff       	call   80079b <strcpy>
	return dst;
}
  8007db:	89 d8                	mov    %ebx,%eax
  8007dd:	83 c4 08             	add    $0x8,%esp
  8007e0:	5b                   	pop    %ebx
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f6:	eb 0c                	jmp    800804 <strncpy+0x21>
		*dst++ = *src;
  8007f8:	8a 1a                	mov    (%edx),%bl
  8007fa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fd:	80 3a 01             	cmpb   $0x1,(%edx)
  800800:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800803:	41                   	inc    %ecx
  800804:	39 f1                	cmp    %esi,%ecx
  800806:	75 f0                	jne    8007f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	5e                   	pop    %esi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 75 08             	mov    0x8(%ebp),%esi
  800814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800817:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081a:	85 d2                	test   %edx,%edx
  80081c:	75 0a                	jne    800828 <strlcpy+0x1c>
  80081e:	89 f0                	mov    %esi,%eax
  800820:	eb 1a                	jmp    80083c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	88 18                	mov    %bl,(%eax)
  800824:	40                   	inc    %eax
  800825:	41                   	inc    %ecx
  800826:	eb 02                	jmp    80082a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800828:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80082a:	4a                   	dec    %edx
  80082b:	74 0a                	je     800837 <strlcpy+0x2b>
  80082d:	8a 19                	mov    (%ecx),%bl
  80082f:	84 db                	test   %bl,%bl
  800831:	75 ef                	jne    800822 <strlcpy+0x16>
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 02                	jmp    800839 <strlcpy+0x2d>
  800837:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80083c:	29 f0                	sub    %esi,%eax
}
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084b:	eb 02                	jmp    80084f <strcmp+0xd>
		p++, q++;
  80084d:	41                   	inc    %ecx
  80084e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084f:	8a 01                	mov    (%ecx),%al
  800851:	84 c0                	test   %al,%al
  800853:	74 04                	je     800859 <strcmp+0x17>
  800855:	3a 02                	cmp    (%edx),%al
  800857:	74 f4                	je     80084d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 c0             	movzbl %al,%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800870:	eb 03                	jmp    800875 <strncmp+0x12>
		n--, p++, q++;
  800872:	4a                   	dec    %edx
  800873:	40                   	inc    %eax
  800874:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800875:	85 d2                	test   %edx,%edx
  800877:	74 14                	je     80088d <strncmp+0x2a>
  800879:	8a 18                	mov    (%eax),%bl
  80087b:	84 db                	test   %bl,%bl
  80087d:	74 04                	je     800883 <strncmp+0x20>
  80087f:	3a 19                	cmp    (%ecx),%bl
  800881:	74 ef                	je     800872 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 00             	movzbl (%eax),%eax
  800886:	0f b6 11             	movzbl (%ecx),%edx
  800889:	29 d0                	sub    %edx,%eax
  80088b:	eb 05                	jmp    800892 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800892:	5b                   	pop    %ebx
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089e:	eb 05                	jmp    8008a5 <strchr+0x10>
		if (*s == c)
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 0c                	je     8008b0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a4:	40                   	inc    %eax
  8008a5:	8a 10                	mov    (%eax),%dl
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	75 f5                	jne    8008a0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008bb:	eb 05                	jmp    8008c2 <strfind+0x10>
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 07                	je     8008c8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c1:	40                   	inc    %eax
  8008c2:	8a 10                	mov    (%eax),%dl
  8008c4:	84 d2                	test   %dl,%dl
  8008c6:	75 f5                	jne    8008bd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d9:	85 c9                	test   %ecx,%ecx
  8008db:	74 30                	je     80090d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 25                	jne    80090a <memset+0x40>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 20                	jne    80090a <memset+0x40>
		c &= 0xFF;
  8008ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ed:	89 d3                	mov    %edx,%ebx
  8008ef:	c1 e3 08             	shl    $0x8,%ebx
  8008f2:	89 d6                	mov    %edx,%esi
  8008f4:	c1 e6 18             	shl    $0x18,%esi
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	c1 e0 10             	shl    $0x10,%eax
  8008fc:	09 f0                	or     %esi,%eax
  8008fe:	09 d0                	or     %edx,%eax
  800900:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800902:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800905:	fc                   	cld    
  800906:	f3 ab                	rep stos %eax,%es:(%edi)
  800908:	eb 03                	jmp    80090d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090a:	fc                   	cld    
  80090b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800922:	39 c6                	cmp    %eax,%esi
  800924:	73 34                	jae    80095a <memmove+0x46>
  800926:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800929:	39 d0                	cmp    %edx,%eax
  80092b:	73 2d                	jae    80095a <memmove+0x46>
		s += n;
		d += n;
  80092d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	f6 c2 03             	test   $0x3,%dl
  800933:	75 1b                	jne    800950 <memmove+0x3c>
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 13                	jne    800950 <memmove+0x3c>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 0e                	jne    800950 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800942:	83 ef 04             	sub    $0x4,%edi
  800945:	8d 72 fc             	lea    -0x4(%edx),%esi
  800948:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80094b:	fd                   	std    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 07                	jmp    800957 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800950:	4f                   	dec    %edi
  800951:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800954:	fd                   	std    
  800955:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800957:	fc                   	cld    
  800958:	eb 20                	jmp    80097a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800960:	75 13                	jne    800975 <memmove+0x61>
  800962:	a8 03                	test   $0x3,%al
  800964:	75 0f                	jne    800975 <memmove+0x61>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0a                	jne    800975 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80096e:	89 c7                	mov    %eax,%edi
  800970:	fc                   	cld    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800973:	eb 05                	jmp    80097a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800975:	89 c7                	mov    %eax,%edi
  800977:	fc                   	cld    
  800978:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800984:	8b 45 10             	mov    0x10(%ebp),%eax
  800987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	89 04 24             	mov    %eax,(%esp)
  800998:	e8 77 ff ff ff       	call   800914 <memmove>
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b3:	eb 16                	jmp    8009cb <memcmp+0x2c>
		if (*s1 != *s2)
  8009b5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009b8:	42                   	inc    %edx
  8009b9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009bd:	38 c8                	cmp    %cl,%al
  8009bf:	74 0a                	je     8009cb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009c1:	0f b6 c0             	movzbl %al,%eax
  8009c4:	0f b6 c9             	movzbl %cl,%ecx
  8009c7:	29 c8                	sub    %ecx,%eax
  8009c9:	eb 09                	jmp    8009d4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cb:	39 da                	cmp    %ebx,%edx
  8009cd:	75 e6                	jne    8009b5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e7:	eb 05                	jmp    8009ee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	38 08                	cmp    %cl,(%eax)
  8009eb:	74 05                	je     8009f2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ed:	40                   	inc    %eax
  8009ee:	39 d0                	cmp    %edx,%eax
  8009f0:	72 f7                	jb     8009e9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a00:	eb 01                	jmp    800a03 <strtol+0xf>
		s++;
  800a02:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a03:	8a 02                	mov    (%edx),%al
  800a05:	3c 20                	cmp    $0x20,%al
  800a07:	74 f9                	je     800a02 <strtol+0xe>
  800a09:	3c 09                	cmp    $0x9,%al
  800a0b:	74 f5                	je     800a02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0d:	3c 2b                	cmp    $0x2b,%al
  800a0f:	75 08                	jne    800a19 <strtol+0x25>
		s++;
  800a11:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
  800a17:	eb 13                	jmp    800a2c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	75 0a                	jne    800a27 <strtol+0x33>
		s++, neg = 1;
  800a1d:	8d 52 01             	lea    0x1(%edx),%edx
  800a20:	bf 01 00 00 00       	mov    $0x1,%edi
  800a25:	eb 05                	jmp    800a2c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	74 05                	je     800a35 <strtol+0x41>
  800a30:	83 fb 10             	cmp    $0x10,%ebx
  800a33:	75 28                	jne    800a5d <strtol+0x69>
  800a35:	8a 02                	mov    (%edx),%al
  800a37:	3c 30                	cmp    $0x30,%al
  800a39:	75 10                	jne    800a4b <strtol+0x57>
  800a3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a3f:	75 0a                	jne    800a4b <strtol+0x57>
		s += 2, base = 16;
  800a41:	83 c2 02             	add    $0x2,%edx
  800a44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a49:	eb 12                	jmp    800a5d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a4b:	85 db                	test   %ebx,%ebx
  800a4d:	75 0e                	jne    800a5d <strtol+0x69>
  800a4f:	3c 30                	cmp    $0x30,%al
  800a51:	75 05                	jne    800a58 <strtol+0x64>
		s++, base = 8;
  800a53:	42                   	inc    %edx
  800a54:	b3 08                	mov    $0x8,%bl
  800a56:	eb 05                	jmp    800a5d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a62:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a64:	8a 0a                	mov    (%edx),%cl
  800a66:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a69:	80 fb 09             	cmp    $0x9,%bl
  800a6c:	77 08                	ja     800a76 <strtol+0x82>
			dig = *s - '0';
  800a6e:	0f be c9             	movsbl %cl,%ecx
  800a71:	83 e9 30             	sub    $0x30,%ecx
  800a74:	eb 1e                	jmp    800a94 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a76:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a7e:	0f be c9             	movsbl %cl,%ecx
  800a81:	83 e9 57             	sub    $0x57,%ecx
  800a84:	eb 0e                	jmp    800a94 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a89:	80 fb 19             	cmp    $0x19,%bl
  800a8c:	77 12                	ja     800aa0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a8e:	0f be c9             	movsbl %cl,%ecx
  800a91:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a94:	39 f1                	cmp    %esi,%ecx
  800a96:	7d 0c                	jge    800aa4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a98:	42                   	inc    %edx
  800a99:	0f af c6             	imul   %esi,%eax
  800a9c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a9e:	eb c4                	jmp    800a64 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800aa0:	89 c1                	mov    %eax,%ecx
  800aa2:	eb 02                	jmp    800aa6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaa:	74 05                	je     800ab1 <strtol+0xbd>
		*endptr = (char *) s;
  800aac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aaf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ab1:	85 ff                	test   %edi,%edi
  800ab3:	74 04                	je     800ab9 <strtol+0xc5>
  800ab5:	89 c8                	mov    %ecx,%eax
  800ab7:	f7 d8                	neg    %eax
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    
	...

00800ac0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	89 c6                	mov    %eax,%esi
  800ad7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cgetc>:

int
sys_cgetc(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 cb                	mov    %ecx,%ebx
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	89 ce                	mov    %ecx,%esi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 28                	jle    800b47 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b23:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b2a:	00 
  800b2b:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800b32:	00 
  800b33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b3a:	00 
  800b3b:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800b42:	e8 31 07 00 00       	call   801278 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b47:	83 c4 2c             	add    $0x2c,%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_yield>:

void
sys_yield(void)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	be 00 00 00 00       	mov    $0x0,%esi
  800b9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 f7                	mov    %esi,%edi
  800bab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	7e 28                	jle    800bd9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bbc:	00 
  800bbd:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800bc4:	00 
  800bc5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bcc:	00 
  800bcd:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800bd4:	e8 9f 06 00 00       	call   801278 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd9:	83 c4 2c             	add    $0x2c,%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bea:	b8 05 00 00 00       	mov    $0x5,%eax
  800bef:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 28                	jle    800c2c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c08:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c0f:	00 
  800c10:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800c17:	00 
  800c18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1f:	00 
  800c20:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800c27:	e8 4c 06 00 00       	call   801278 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	83 c4 2c             	add    $0x2c,%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 06 00 00 00       	mov    $0x6,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800c7a:	e8 f9 05 00 00       	call   801278 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 28                	jle    800cd2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cb5:	00 
  800cb6:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800cbd:	00 
  800cbe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc5:	00 
  800cc6:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800ccd:	e8 a6 05 00 00       	call   801278 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd2:	83 c4 2c             	add    $0x2c,%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 28                	jle    800d25 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d01:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d08:	00 
  800d09:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800d10:	00 
  800d11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d18:	00 
  800d19:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800d20:	e8 53 05 00 00       	call   801278 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d25:	83 c4 2c             	add    $0x2c,%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 28                	jle    800d78 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d54:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d5b:	00 
  800d5c:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800d63:	00 
  800d64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6b:	00 
  800d6c:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800d73:	e8 00 05 00 00       	call   801278 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d78:	83 c4 2c             	add    $0x2c,%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	be 00 00 00 00       	mov    $0x0,%esi
  800d8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d90:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 cb                	mov    %ecx,%ebx
  800dbb:	89 cf                	mov    %ecx,%edi
  800dbd:	89 ce                	mov    %ecx,%esi
  800dbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 28                	jle    800ded <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 08 e7 18 80 	movl   $0x8018e7,0x8(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de0:	00 
  800de1:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  800de8:	e8 8b 04 00 00       	call   801278 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ded:	83 c4 2c             	add    $0x2c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800e00:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e05:	89 d1                	mov    %edx,%ecx
  800e07:	89 d3                	mov    %edx,%ebx
  800e09:	89 d7                	mov    %edx,%edi
  800e0b:	89 d6                	mov    %edx,%esi
  800e0d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	89 df                	mov    %ebx,%edi
  800e2c:	89 de                	mov    %ebx,%esi
  800e2e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e40:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4b:	89 df                	mov    %ebx,%edi
  800e4d:	89 de                	mov    %ebx,%esi
  800e4f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	57                   	push   %edi
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e61:	b8 11 00 00 00       	mov    $0x11,%eax
  800e66:	8b 55 08             	mov    0x8(%ebp),%edx
  800e69:	89 cb                	mov    %ecx,%ebx
  800e6b:	89 cf                	mov    %ecx,%edi
  800e6d:	89 ce                	mov    %ecx,%esi
  800e6f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
	...

00800e78 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 24             	sub    $0x24,%esp
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e82:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800e84:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e88:	75 20                	jne    800eaa <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e8a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e8e:	c7 44 24 08 14 19 80 	movl   $0x801914,0x8(%esp)
  800e95:	00 
  800e96:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e9d:	00 
  800e9e:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  800ea5:	e8 ce 03 00 00       	call   801278 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eaa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800eb5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ebc:	f6 c4 08             	test   $0x8,%ah
  800ebf:	75 1c                	jne    800edd <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ec1:	c7 44 24 08 44 19 80 	movl   $0x801944,0x8(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed0:	00 
  800ed1:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  800ed8:	e8 9b 03 00 00       	call   801278 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800edd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800eec:	00 
  800eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef4:	e8 94 fc ff ff       	call   800b8d <sys_page_alloc>
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	79 20                	jns    800f1d <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800efd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f01:	c7 44 24 08 9f 19 80 	movl   $0x80199f,0x8(%esp)
  800f08:	00 
  800f09:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800f10:	00 
  800f11:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  800f18:	e8 5b 03 00 00       	call   801278 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800f1d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f24:	00 
  800f25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f29:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f30:	e8 df f9 ff ff       	call   800914 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f35:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f3c:	00 
  800f3d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f41:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f58:	e8 84 fc ff ff       	call   800be1 <sys_page_map>
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	79 20                	jns    800f81 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800f61:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f65:	c7 44 24 08 b3 19 80 	movl   $0x8019b3,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  800f7c:	e8 f7 02 00 00       	call   801278 <_panic>

}
  800f81:	83 c4 24             	add    $0x24,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800f90:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  800f97:	e8 34 03 00 00       	call   8012d0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f9c:	ba 07 00 00 00       	mov    $0x7,%edx
  800fa1:	89 d0                	mov    %edx,%eax
  800fa3:	cd 30                	int    $0x30
  800fa5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fa8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	79 20                	jns    800fcf <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fb3:	c7 44 24 08 c5 19 80 	movl   $0x8019c5,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  800fc2:	00 
  800fc3:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  800fca:	e8 a9 02 00 00       	call   801278 <_panic>
	if (child_envid == 0) { // child
  800fcf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fd3:	75 1c                	jne    800ff1 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd5:	e8 75 fb ff ff       	call   800b4f <sys_getenvid>
  800fda:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdf:	c1 e0 07             	shl    $0x7,%eax
  800fe2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe7:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fec:	e9 58 02 00 00       	jmp    801249 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800ff1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff6:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800ffb:	89 f0                	mov    %esi,%eax
  800ffd:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801000:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801007:	a8 01                	test   $0x1,%al
  801009:	0f 84 7a 01 00 00    	je     801189 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80100f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801016:	a8 01                	test   $0x1,%al
  801018:	0f 84 6b 01 00 00    	je     801189 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80101e:	a1 04 20 80 00       	mov    0x802004,%eax
  801023:	8b 40 48             	mov    0x48(%eax),%eax
  801026:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801029:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801030:	f6 c4 04             	test   $0x4,%ah
  801033:	74 52                	je     801087 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	25 07 0e 00 00       	and    $0xe07,%eax
  801041:	89 44 24 10          	mov    %eax,0x10(%esp)
  801045:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801049:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80104c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801050:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	e8 82 fb ff ff       	call   800be1 <sys_page_map>
  80105f:	85 c0                	test   %eax,%eax
  801061:	0f 89 22 01 00 00    	jns    801189 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801067:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80106b:	c7 44 24 08 b3 19 80 	movl   $0x8019b3,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  801082:	e8 f1 01 00 00       	call   801278 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801087:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108e:	f6 c4 08             	test   $0x8,%ah
  801091:	75 0f                	jne    8010a2 <fork+0x11b>
  801093:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109a:	a8 02                	test   $0x2,%al
  80109c:	0f 84 99 00 00 00    	je     80113b <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  8010a2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a9:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8010ac:	83 f8 01             	cmp    $0x1,%eax
  8010af:	19 db                	sbb    %ebx,%ebx
  8010b1:	83 e3 fc             	and    $0xfffffffc,%ebx
  8010b4:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010ba:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010be:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d0:	89 04 24             	mov    %eax,(%esp)
  8010d3:	e8 09 fb ff ff       	call   800be1 <sys_page_map>
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	79 20                	jns    8010fc <fork+0x175>
			panic("sys_page_map: %e\n", r);
  8010dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e0:	c7 44 24 08 b3 19 80 	movl   $0x8019b3,0x8(%esp)
  8010e7:	00 
  8010e8:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010ef:	00 
  8010f0:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  8010f7:	e8 7c 01 00 00       	call   801278 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010fc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801100:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801104:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801107:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80110f:	89 04 24             	mov    %eax,(%esp)
  801112:	e8 ca fa ff ff       	call   800be1 <sys_page_map>
  801117:	85 c0                	test   %eax,%eax
  801119:	79 6e                	jns    801189 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80111b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111f:	c7 44 24 08 b3 19 80 	movl   $0x8019b3,0x8(%esp)
  801126:	00 
  801127:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80112e:	00 
  80112f:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  801136:	e8 3d 01 00 00       	call   801278 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80113b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801142:	25 07 0e 00 00       	and    $0xe07,%eax
  801147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80114b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801152:	89 44 24 08          	mov    %eax,0x8(%esp)
  801156:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80115a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	e8 7c fa ff ff       	call   800be1 <sys_page_map>
  801165:	85 c0                	test   %eax,%eax
  801167:	79 20                	jns    801189 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116d:	c7 44 24 08 b3 19 80 	movl   $0x8019b3,0x8(%esp)
  801174:	00 
  801175:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  80117c:	00 
  80117d:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  801184:	e8 ef 00 00 00       	call   801278 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801189:	46                   	inc    %esi
  80118a:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801190:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801196:	0f 85 5f fe ff ff    	jne    800ffb <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80119c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011a3:	00 
  8011a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011ab:	ee 
  8011ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011af:	89 04 24             	mov    %eax,(%esp)
  8011b2:	e8 d6 f9 ff ff       	call   800b8d <sys_page_alloc>
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	79 20                	jns    8011db <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  8011bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bf:	c7 44 24 08 9f 19 80 	movl   $0x80199f,0x8(%esp)
  8011c6:	00 
  8011c7:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8011ce:	00 
  8011cf:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  8011d6:	e8 9d 00 00 00       	call   801278 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8011db:	c7 44 24 04 44 13 80 	movl   $0x801344,0x4(%esp)
  8011e2:	00 
  8011e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	e8 3f fb ff ff       	call   800d2d <sys_env_set_pgfault_upcall>
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	79 20                	jns    801212 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8011f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f6:	c7 44 24 08 74 19 80 	movl   $0x801974,0x8(%esp)
  8011fd:	00 
  8011fe:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801205:	00 
  801206:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  80120d:	e8 66 00 00 00       	call   801278 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801212:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801219:	00 
  80121a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80121d:	89 04 24             	mov    %eax,(%esp)
  801220:	e8 62 fa ff ff       	call   800c87 <sys_env_set_status>
  801225:	85 c0                	test   %eax,%eax
  801227:	79 20                	jns    801249 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122d:	c7 44 24 08 d6 19 80 	movl   $0x8019d6,0x8(%esp)
  801234:	00 
  801235:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80123c:	00 
  80123d:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  801244:	e8 2f 00 00 00       	call   801278 <_panic>

	return child_envid;
}
  801249:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80124c:	83 c4 3c             	add    $0x3c,%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <sfork>:

// Challenge!
int
sfork(void)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80125a:	c7 44 24 08 ee 19 80 	movl   $0x8019ee,0x8(%esp)
  801261:	00 
  801262:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801269:	00 
  80126a:	c7 04 24 94 19 80 00 	movl   $0x801994,(%esp)
  801271:	e8 02 00 00 00       	call   801278 <_panic>
	...

00801278 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801280:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801283:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801289:	e8 c1 f8 ff ff       	call   800b4f <sys_getenvid>
  80128e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801291:	89 54 24 10          	mov    %edx,0x10(%esp)
  801295:	8b 55 08             	mov    0x8(%ebp),%edx
  801298:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80129c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a4:	c7 04 24 04 1a 80 00 	movl   $0x801a04,(%esp)
  8012ab:	e8 40 ef ff ff       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 d0 ee ff ff       	call   80018f <vcprintf>
	cprintf("\n");
  8012bf:	c7 04 24 cf 15 80 00 	movl   $0x8015cf,(%esp)
  8012c6:	e8 25 ef ff ff       	call   8001f0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012cb:	cc                   	int3   
  8012cc:	eb fd                	jmp    8012cb <_panic+0x53>
	...

008012d0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012d6:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012dd:	75 58                	jne    801337 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8012df:	a1 04 20 80 00       	mov    0x802004,%eax
  8012e4:	8b 40 48             	mov    0x48(%eax),%eax
  8012e7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012ee:	00 
  8012ef:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012f6:	ee 
  8012f7:	89 04 24             	mov    %eax,(%esp)
  8012fa:	e8 8e f8 ff ff       	call   800b8d <sys_page_alloc>
  8012ff:	85 c0                	test   %eax,%eax
  801301:	74 1c                	je     80131f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801303:	c7 44 24 08 28 1a 80 	movl   $0x801a28,0x8(%esp)
  80130a:	00 
  80130b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801312:	00 
  801313:	c7 04 24 3d 1a 80 00 	movl   $0x801a3d,(%esp)
  80131a:	e8 59 ff ff ff       	call   801278 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80131f:	a1 04 20 80 00       	mov    0x802004,%eax
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	c7 44 24 04 44 13 80 	movl   $0x801344,0x4(%esp)
  80132e:	00 
  80132f:	89 04 24             	mov    %eax,(%esp)
  801332:	e8 f6 f9 ff ff       	call   800d2d <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801337:	8b 45 08             	mov    0x8(%ebp),%eax
  80133a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    
  801341:	00 00                	add    %al,(%eax)
	...

00801344 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801344:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801345:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80134a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80134c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80134f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801353:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801355:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801359:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80135a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  80135d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80135f:	58                   	pop    %eax
	popl %eax
  801360:	58                   	pop    %eax

	// Pop all registers back
	popal
  801361:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801362:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801365:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801366:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801367:	c3                   	ret    

00801368 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801368:	55                   	push   %ebp
  801369:	57                   	push   %edi
  80136a:	56                   	push   %esi
  80136b:	83 ec 10             	sub    $0x10,%esp
  80136e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801372:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80137a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80137e:	89 cd                	mov    %ecx,%ebp
  801380:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801384:	85 c0                	test   %eax,%eax
  801386:	75 2c                	jne    8013b4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801388:	39 f9                	cmp    %edi,%ecx
  80138a:	77 68                	ja     8013f4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80138c:	85 c9                	test   %ecx,%ecx
  80138e:	75 0b                	jne    80139b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801390:	b8 01 00 00 00       	mov    $0x1,%eax
  801395:	31 d2                	xor    %edx,%edx
  801397:	f7 f1                	div    %ecx
  801399:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	89 f8                	mov    %edi,%eax
  80139f:	f7 f1                	div    %ecx
  8013a1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	f7 f1                	div    %ecx
  8013a7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	5e                   	pop    %esi
  8013b1:	5f                   	pop    %edi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8013b4:	39 f8                	cmp    %edi,%eax
  8013b6:	77 2c                	ja     8013e4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8013b8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8013bb:	83 f6 1f             	xor    $0x1f,%esi
  8013be:	75 4c                	jne    80140c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013c0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013c2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013c7:	72 0a                	jb     8013d3 <__udivdi3+0x6b>
  8013c9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8013cd:	0f 87 ad 00 00 00    	ja     801480 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8013d3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013d8:	89 f0                	mov    %esi,%eax
  8013da:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    
  8013e3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8013e4:	31 ff                	xor    %edi,%edi
  8013e6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013e8:	89 f0                	mov    %esi,%eax
  8013ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	5e                   	pop    %esi
  8013f0:	5f                   	pop    %edi
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    
  8013f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013f4:	89 fa                	mov    %edi,%edx
  8013f6:	89 f0                	mov    %esi,%eax
  8013f8:	f7 f1                	div    %ecx
  8013fa:	89 c6                	mov    %eax,%esi
  8013fc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013fe:	89 f0                	mov    %esi,%eax
  801400:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	5e                   	pop    %esi
  801406:	5f                   	pop    %edi
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    
  801409:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80140c:	89 f1                	mov    %esi,%ecx
  80140e:	d3 e0                	shl    %cl,%eax
  801410:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801414:	b8 20 00 00 00       	mov    $0x20,%eax
  801419:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80141b:	89 ea                	mov    %ebp,%edx
  80141d:	88 c1                	mov    %al,%cl
  80141f:	d3 ea                	shr    %cl,%edx
  801421:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801425:	09 ca                	or     %ecx,%edx
  801427:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80142b:	89 f1                	mov    %esi,%ecx
  80142d:	d3 e5                	shl    %cl,%ebp
  80142f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801433:	89 fd                	mov    %edi,%ebp
  801435:	88 c1                	mov    %al,%cl
  801437:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801439:	89 fa                	mov    %edi,%edx
  80143b:	89 f1                	mov    %esi,%ecx
  80143d:	d3 e2                	shl    %cl,%edx
  80143f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801443:	88 c1                	mov    %al,%cl
  801445:	d3 ef                	shr    %cl,%edi
  801447:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801449:	89 f8                	mov    %edi,%eax
  80144b:	89 ea                	mov    %ebp,%edx
  80144d:	f7 74 24 08          	divl   0x8(%esp)
  801451:	89 d1                	mov    %edx,%ecx
  801453:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801455:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801459:	39 d1                	cmp    %edx,%ecx
  80145b:	72 17                	jb     801474 <__udivdi3+0x10c>
  80145d:	74 09                	je     801468 <__udivdi3+0x100>
  80145f:	89 fe                	mov    %edi,%esi
  801461:	31 ff                	xor    %edi,%edi
  801463:	e9 41 ff ff ff       	jmp    8013a9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801468:	8b 54 24 04          	mov    0x4(%esp),%edx
  80146c:	89 f1                	mov    %esi,%ecx
  80146e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801470:	39 c2                	cmp    %eax,%edx
  801472:	73 eb                	jae    80145f <__udivdi3+0xf7>
		{
		  q0--;
  801474:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801477:	31 ff                	xor    %edi,%edi
  801479:	e9 2b ff ff ff       	jmp    8013a9 <__udivdi3+0x41>
  80147e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801480:	31 f6                	xor    %esi,%esi
  801482:	e9 22 ff ff ff       	jmp    8013a9 <__udivdi3+0x41>
	...

00801488 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801488:	55                   	push   %ebp
  801489:	57                   	push   %edi
  80148a:	56                   	push   %esi
  80148b:	83 ec 20             	sub    $0x20,%esp
  80148e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801492:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801496:	89 44 24 14          	mov    %eax,0x14(%esp)
  80149a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80149e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8014a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8014a6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8014a8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8014aa:	85 ed                	test   %ebp,%ebp
  8014ac:	75 16                	jne    8014c4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8014ae:	39 f1                	cmp    %esi,%ecx
  8014b0:	0f 86 a6 00 00 00    	jbe    80155c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014b6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8014b8:	89 d0                	mov    %edx,%eax
  8014ba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014bc:	83 c4 20             	add    $0x20,%esp
  8014bf:	5e                   	pop    %esi
  8014c0:	5f                   	pop    %edi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    
  8014c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8014c4:	39 f5                	cmp    %esi,%ebp
  8014c6:	0f 87 ac 00 00 00    	ja     801578 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8014cc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8014cf:	83 f0 1f             	xor    $0x1f,%eax
  8014d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014d6:	0f 84 a8 00 00 00    	je     801584 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8014dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014e0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8014e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8014e7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8014eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014ef:	89 f9                	mov    %edi,%ecx
  8014f1:	d3 e8                	shr    %cl,%eax
  8014f3:	09 e8                	or     %ebp,%eax
  8014f5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8014f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801501:	d3 e0                	shl    %cl,%eax
  801503:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801507:	89 f2                	mov    %esi,%edx
  801509:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80150b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80150f:	d3 e0                	shl    %cl,%eax
  801511:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801515:	8b 44 24 14          	mov    0x14(%esp),%eax
  801519:	89 f9                	mov    %edi,%ecx
  80151b:	d3 e8                	shr    %cl,%eax
  80151d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80151f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801521:	89 f2                	mov    %esi,%edx
  801523:	f7 74 24 18          	divl   0x18(%esp)
  801527:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801529:	f7 64 24 0c          	mull   0xc(%esp)
  80152d:	89 c5                	mov    %eax,%ebp
  80152f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801531:	39 d6                	cmp    %edx,%esi
  801533:	72 67                	jb     80159c <__umoddi3+0x114>
  801535:	74 75                	je     8015ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801537:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80153b:	29 e8                	sub    %ebp,%eax
  80153d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80153f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801543:	d3 e8                	shr    %cl,%eax
  801545:	89 f2                	mov    %esi,%edx
  801547:	89 f9                	mov    %edi,%ecx
  801549:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80154b:	09 d0                	or     %edx,%eax
  80154d:	89 f2                	mov    %esi,%edx
  80154f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801553:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801555:	83 c4 20             	add    $0x20,%esp
  801558:	5e                   	pop    %esi
  801559:	5f                   	pop    %edi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80155c:	85 c9                	test   %ecx,%ecx
  80155e:	75 0b                	jne    80156b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801560:	b8 01 00 00 00       	mov    $0x1,%eax
  801565:	31 d2                	xor    %edx,%edx
  801567:	f7 f1                	div    %ecx
  801569:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80156b:	89 f0                	mov    %esi,%eax
  80156d:	31 d2                	xor    %edx,%edx
  80156f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801571:	89 f8                	mov    %edi,%eax
  801573:	e9 3e ff ff ff       	jmp    8014b6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801578:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80157a:	83 c4 20             	add    $0x20,%esp
  80157d:	5e                   	pop    %esi
  80157e:	5f                   	pop    %edi
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    
  801581:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801584:	39 f5                	cmp    %esi,%ebp
  801586:	72 04                	jb     80158c <__umoddi3+0x104>
  801588:	39 f9                	cmp    %edi,%ecx
  80158a:	77 06                	ja     801592 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80158c:	89 f2                	mov    %esi,%edx
  80158e:	29 cf                	sub    %ecx,%edi
  801590:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801592:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801594:	83 c4 20             	add    $0x20,%esp
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
  80159b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80159c:	89 d1                	mov    %edx,%ecx
  80159e:	89 c5                	mov    %eax,%ebp
  8015a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8015a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8015a8:	eb 8d                	jmp    801537 <__umoddi3+0xaf>
  8015aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8015b0:	72 ea                	jb     80159c <__umoddi3+0x114>
  8015b2:	89 f1                	mov    %esi,%ecx
  8015b4:	eb 81                	jmp    801537 <__umoddi3+0xaf>
