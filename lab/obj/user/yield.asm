
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  80004e:	e8 49 01 00 00       	call   80019c <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 bd 0a 00 00       	call   800b1a <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 11 80 00 	movl   $0x801100,(%esp)
  800074:	e8 23 01 00 00       	call   80019c <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	43                   	inc    %ebx
  80007a:	83 fb 05             	cmp    $0x5,%ebx
  80007d:	75 d9                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007f:	a1 04 20 80 00       	mov    0x802004,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 2c 11 80 00 	movl   $0x80112c,(%esp)
  800092:	e8 05 01 00 00       	call   80019c <cprintf>
}
  800097:	83 c4 14             	add    $0x14,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ae:	e8 48 0a 00 00       	call   800afb <sys_getenvid>
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	c1 e0 07             	shl    $0x7,%eax
  8000bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c0:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c5:	85 f6                	test   %esi,%esi
  8000c7:	7e 07                	jle    8000d0 <libmain+0x30>
		binaryname = argv[0];
  8000c9:	8b 03                	mov    (%ebx),%eax
  8000cb:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d4:	89 34 24             	mov    %esi,(%esp)
  8000d7:	e8 58 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 07 00 00 00       	call   8000e8 <exit>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

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
  8000f5:	e8 af 09 00 00       	call   800aa9 <sys_env_destroy>
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 14             	sub    $0x14,%esp
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800106:	8b 03                	mov    (%ebx),%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80010f:	40                   	inc    %eax
  800110:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 19                	jne    800132 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800119:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800120:	00 
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	89 04 24             	mov    %eax,(%esp)
  800127:	e8 40 09 00 00       	call   800a6c <sys_cputs>
		b->idx = 0;
  80012c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800132:	ff 43 04             	incl   0x4(%ebx)
}
  800135:	83 c4 14             	add    $0x14,%esp
  800138:	5b                   	pop    %ebx
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015f:	8b 45 08             	mov    0x8(%ebp),%eax
  800162:	89 44 24 08          	mov    %eax,0x8(%esp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	c7 04 24 fc 00 80 00 	movl   $0x8000fc,(%esp)
  800177:	e8 82 01 00 00       	call   8002fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80017c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800182:	89 44 24 04          	mov    %eax,0x4(%esp)
  800186:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 d8 08 00 00       	call   800a6c <sys_cputs>

	return b.cnt;
}
  800194:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    

0080019c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 87 ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    
	...

008001b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 3c             	sub    $0x3c,%esp
  8001c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001c4:	89 d7                	mov    %edx,%edi
  8001c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	75 08                	jne    8001e4 <printnum+0x2c>
  8001dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 57                	ja     80023b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001e8:	4b                   	dec    %ebx
  8001e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800203:	00 
  800204:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	e8 66 0c 00 00       	call   800e7c <__udivdi3>
  800216:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80021a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	89 54 24 04          	mov    %edx,0x4(%esp)
  800225:	89 fa                	mov    %edi,%edx
  800227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022a:	e8 89 ff ff ff       	call   8001b8 <printnum>
  80022f:	eb 0f                	jmp    800240 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	89 34 24             	mov    %esi,(%esp)
  800238:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023b:	4b                   	dec    %ebx
  80023c:	85 db                	test   %ebx,%ebx
  80023e:	7f f1                	jg     800231 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800240:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800244:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800248:	8b 45 10             	mov    0x10(%ebp),%eax
  80024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800256:	00 
  800257:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800260:	89 44 24 04          	mov    %eax,0x4(%esp)
  800264:	e8 33 0d 00 00       	call   800f9c <__umoddi3>
  800269:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026d:	0f be 80 55 11 80 00 	movsbl 0x801155(%eax),%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027a:	83 c4 3c             	add    $0x3c,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800285:	83 fa 01             	cmp    $0x1,%edx
  800288:	7e 0e                	jle    800298 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028a:	8b 10                	mov    (%eax),%edx
  80028c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028f:	89 08                	mov    %ecx,(%eax)
  800291:	8b 02                	mov    (%edx),%eax
  800293:	8b 52 04             	mov    0x4(%edx),%edx
  800296:	eb 22                	jmp    8002ba <getuint+0x38>
	else if (lflag)
  800298:	85 d2                	test   %edx,%edx
  80029a:	74 10                	je     8002ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 02                	mov    (%edx),%eax
  8002a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002aa:	eb 0e                	jmp    8002ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ca:	73 08                	jae    8002d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8002cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cf:	88 0a                	mov    %cl,(%edx)
  8002d1:	42                   	inc    %edx
  8002d2:	89 10                	mov    %edx,(%eax)
}
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	e8 02 00 00 00       	call   8002fe <vprintfmt>
	va_end(ap);
}
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	57                   	push   %edi
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	83 ec 4c             	sub    $0x4c,%esp
  800307:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030a:	8b 75 10             	mov    0x10(%ebp),%esi
  80030d:	eb 12                	jmp    800321 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80030f:	85 c0                	test   %eax,%eax
  800311:	0f 84 6b 03 00 00    	je     800682 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800317:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80031b:	89 04 24             	mov    %eax,(%esp)
  80031e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800321:	0f b6 06             	movzbl (%esi),%eax
  800324:	46                   	inc    %esi
  800325:	83 f8 25             	cmp    $0x25,%eax
  800328:	75 e5                	jne    80030f <vprintfmt+0x11>
  80032a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80032e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800335:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80033a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
  800346:	eb 26                	jmp    80036e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80034b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80034f:	eb 1d                	jmp    80036e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800354:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800358:	eb 14                	jmp    80036e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80035d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800364:	eb 08                	jmp    80036e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800366:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800369:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	0f b6 06             	movzbl (%esi),%eax
  800371:	8d 56 01             	lea    0x1(%esi),%edx
  800374:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800377:	8a 16                	mov    (%esi),%dl
  800379:	83 ea 23             	sub    $0x23,%edx
  80037c:	80 fa 55             	cmp    $0x55,%dl
  80037f:	0f 87 e1 02 00 00    	ja     800666 <vprintfmt+0x368>
  800385:	0f b6 d2             	movzbl %dl,%edx
  800388:	ff 24 95 a0 12 80 00 	jmp    *0x8012a0(,%edx,4)
  80038f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800392:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800397:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80039a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80039e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003a4:	83 fa 09             	cmp    $0x9,%edx
  8003a7:	77 2a                	ja     8003d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003aa:	eb eb                	jmp    800397 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ba:	eb 17                	jmp    8003d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003c0:	78 98                	js     80035a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c5:	eb a7                	jmp    80036e <vprintfmt+0x70>
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003d1:	eb 9b                	jmp    80036e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d7:	79 95                	jns    80036e <vprintfmt+0x70>
  8003d9:	eb 8b                	jmp    800366 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003df:	eb 8d                	jmp    80036e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 50 04             	lea    0x4(%eax),%edx
  8003e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	89 04 24             	mov    %eax,(%esp)
  8003f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f9:	e9 23 ff ff ff       	jmp    800321 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	79 02                	jns    80040f <vprintfmt+0x111>
  80040d:	f7 d8                	neg    %eax
  80040f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 11             	cmp    $0x11,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x123>
  800416:	8b 04 85 00 14 80 00 	mov    0x801400(,%eax,4),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	75 23                	jne    800444 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800421:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800425:	c7 44 24 08 6d 11 80 	movl   $0x80116d,0x8(%esp)
  80042c:	00 
  80042d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 9a fe ff ff       	call   8002d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043f:	e9 dd fe ff ff       	jmp    800321 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800444:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800448:	c7 44 24 08 76 11 80 	movl   $0x801176,0x8(%esp)
  80044f:	00 
  800450:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	89 14 24             	mov    %edx,(%esp)
  80045a:	e8 77 fe ff ff       	call   8002d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800462:	e9 ba fe ff ff       	jmp    800321 <vprintfmt+0x23>
  800467:	89 f9                	mov    %edi,%ecx
  800469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 30                	mov    (%eax),%esi
  80047a:	85 f6                	test   %esi,%esi
  80047c:	75 05                	jne    800483 <vprintfmt+0x185>
				p = "(null)";
  80047e:	be 66 11 80 00       	mov    $0x801166,%esi
			if (width > 0 && padc != '-')
  800483:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800487:	0f 8e 84 00 00 00    	jle    800511 <vprintfmt+0x213>
  80048d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800491:	74 7e                	je     800511 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800493:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800497:	89 34 24             	mov    %esi,(%esp)
  80049a:	e8 8b 02 00 00       	call   80072a <strnlen>
  80049f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004a2:	29 c2                	sub    %eax,%edx
  8004a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004b1:	89 de                	mov    %ebx,%esi
  8004b3:	89 d3                	mov    %edx,%ebx
  8004b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	eb 0b                	jmp    8004c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004bd:	89 3c 24             	mov    %edi,(%esp)
  8004c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	4b                   	dec    %ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f f1                	jg     8004b9 <vprintfmt+0x1bb>
  8004c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004cb:	89 f3                	mov    %esi,%ebx
  8004cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	79 05                	jns    8004dc <vprintfmt+0x1de>
  8004d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004df:	29 c2                	sub    %eax,%edx
  8004e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004e4:	eb 2b                	jmp    800511 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ea:	74 18                	je     800504 <vprintfmt+0x206>
  8004ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ef:	83 fa 5e             	cmp    $0x5e,%edx
  8004f2:	76 10                	jbe    800504 <vprintfmt+0x206>
					putch('?', putdat);
  8004f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
  800502:	eb 0a                	jmp    80050e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050e:	ff 4d e4             	decl   -0x1c(%ebp)
  800511:	0f be 06             	movsbl (%esi),%eax
  800514:	46                   	inc    %esi
  800515:	85 c0                	test   %eax,%eax
  800517:	74 21                	je     80053a <vprintfmt+0x23c>
  800519:	85 ff                	test   %edi,%edi
  80051b:	78 c9                	js     8004e6 <vprintfmt+0x1e8>
  80051d:	4f                   	dec    %edi
  80051e:	79 c6                	jns    8004e6 <vprintfmt+0x1e8>
  800520:	8b 7d 08             	mov    0x8(%ebp),%edi
  800523:	89 de                	mov    %ebx,%esi
  800525:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800528:	eb 18                	jmp    800542 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800535:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800537:	4b                   	dec    %ebx
  800538:	eb 08                	jmp    800542 <vprintfmt+0x244>
  80053a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053d:	89 de                	mov    %ebx,%esi
  80053f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800542:	85 db                	test   %ebx,%ebx
  800544:	7f e4                	jg     80052a <vprintfmt+0x22c>
  800546:	89 7d 08             	mov    %edi,0x8(%ebp)
  800549:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054e:	e9 ce fd ff ff       	jmp    800321 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800553:	83 f9 01             	cmp    $0x1,%ecx
  800556:	7e 10                	jle    800568 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 50 08             	lea    0x8(%eax),%edx
  80055e:	89 55 14             	mov    %edx,0x14(%ebp)
  800561:	8b 30                	mov    (%eax),%esi
  800563:	8b 78 04             	mov    0x4(%eax),%edi
  800566:	eb 26                	jmp    80058e <vprintfmt+0x290>
	else if (lflag)
  800568:	85 c9                	test   %ecx,%ecx
  80056a:	74 12                	je     80057e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 50 04             	lea    0x4(%eax),%edx
  800572:	89 55 14             	mov    %edx,0x14(%ebp)
  800575:	8b 30                	mov    (%eax),%esi
  800577:	89 f7                	mov    %esi,%edi
  800579:	c1 ff 1f             	sar    $0x1f,%edi
  80057c:	eb 10                	jmp    80058e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 30                	mov    (%eax),%esi
  800589:	89 f7                	mov    %esi,%edi
  80058b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058e:	85 ff                	test   %edi,%edi
  800590:	78 0a                	js     80059c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 8c 00 00 00       	jmp    800628 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005aa:	f7 de                	neg    %esi
  8005ac:	83 d7 00             	adc    $0x0,%edi
  8005af:	f7 df                	neg    %edi
			}
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b6:	eb 70                	jmp    800628 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b8:	89 ca                	mov    %ecx,%edx
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 c0 fc ff ff       	call   800282 <getuint>
  8005c2:	89 c6                	mov    %eax,%esi
  8005c4:	89 d7                	mov    %edx,%edi
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005cb:	eb 5b                	jmp    800628 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8005cd:	89 ca                	mov    %ecx,%edx
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 ab fc ff ff       	call   800282 <getuint>
  8005d7:	89 c6                	mov    %eax,%esi
  8005d9:	89 d7                	mov    %edx,%edi
			base = 8;
  8005db:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005e0:	eb 46                	jmp    800628 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800607:	8b 30                	mov    (%eax),%esi
  800609:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800613:	eb 13                	jmp    800628 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800615:	89 ca                	mov    %ecx,%edx
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 63 fc ff ff       	call   800282 <getuint>
  80061f:	89 c6                	mov    %eax,%esi
  800621:	89 d7                	mov    %edx,%edi
			base = 16;
  800623:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800628:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80062c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800637:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063b:	89 34 24             	mov    %esi,(%esp)
  80063e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800642:	89 da                	mov    %ebx,%edx
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	e8 6c fb ff ff       	call   8001b8 <printnum>
			break;
  80064c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064f:	e9 cd fc ff ff       	jmp    800321 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800661:	e9 bb fc ff ff       	jmp    800321 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800671:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800674:	eb 01                	jmp    800677 <vprintfmt+0x379>
  800676:	4e                   	dec    %esi
  800677:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80067b:	75 f9                	jne    800676 <vprintfmt+0x378>
  80067d:	e9 9f fc ff ff       	jmp    800321 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800682:	83 c4 4c             	add    $0x4c,%esp
  800685:	5b                   	pop    %ebx
  800686:	5e                   	pop    %esi
  800687:	5f                   	pop    %edi
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 28             	sub    $0x28,%esp
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800699:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	74 30                	je     8006db <vsnprintf+0x51>
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	7e 33                	jle    8006e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	c7 04 24 bc 02 80 00 	movl   $0x8002bc,(%esp)
  8006cb:	e8 2e fc ff ff       	call   8002fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	eb 0c                	jmp    8006e7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e0:	eb 05                	jmp    8006e7 <vsnprintf+0x5d>
  8006e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800700:	89 44 24 04          	mov    %eax,0x4(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	e8 7b ff ff ff       	call   80068a <vsnprintf>
	va_end(ap);

	return rc;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    
  800711:	00 00                	add    %al,(%eax)
	...

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	eb 01                	jmp    800722 <strlen+0xe>
		n++;
  800721:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800726:	75 f9                	jne    800721 <strlen+0xd>
		n++;
	return n;
}
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	eb 01                	jmp    80073b <strnlen+0x11>
		n++;
  80073a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073b:	39 d0                	cmp    %edx,%eax
  80073d:	74 06                	je     800745 <strnlen+0x1b>
  80073f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800743:	75 f5                	jne    80073a <strnlen+0x10>
		n++;
	return n;
}
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	8b 45 08             	mov    0x8(%ebp),%eax
  80074e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800751:	ba 00 00 00 00       	mov    $0x0,%edx
  800756:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800759:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80075c:	42                   	inc    %edx
  80075d:	84 c9                	test   %cl,%cl
  80075f:	75 f5                	jne    800756 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800761:	5b                   	pop    %ebx
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	83 ec 08             	sub    $0x8,%esp
  80076b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076e:	89 1c 24             	mov    %ebx,(%esp)
  800771:	e8 9e ff ff ff       	call   800714 <strlen>
	strcpy(dst + len, src);
  800776:	8b 55 0c             	mov    0xc(%ebp),%edx
  800779:	89 54 24 04          	mov    %edx,0x4(%esp)
  80077d:	01 d8                	add    %ebx,%eax
  80077f:	89 04 24             	mov    %eax,(%esp)
  800782:	e8 c0 ff ff ff       	call   800747 <strcpy>
	return dst;
}
  800787:	89 d8                	mov    %ebx,%eax
  800789:	83 c4 08             	add    $0x8,%esp
  80078c:	5b                   	pop    %ebx
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a2:	eb 0c                	jmp    8007b0 <strncpy+0x21>
		*dst++ = *src;
  8007a4:	8a 1a                	mov    (%edx),%bl
  8007a6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007af:	41                   	inc    %ecx
  8007b0:	39 f1                	cmp    %esi,%ecx
  8007b2:	75 f0                	jne    8007a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	56                   	push   %esi
  8007bc:	53                   	push   %ebx
  8007bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	75 0a                	jne    8007d4 <strlcpy+0x1c>
  8007ca:	89 f0                	mov    %esi,%eax
  8007cc:	eb 1a                	jmp    8007e8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ce:	88 18                	mov    %bl,(%eax)
  8007d0:	40                   	inc    %eax
  8007d1:	41                   	inc    %ecx
  8007d2:	eb 02                	jmp    8007d6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007d6:	4a                   	dec    %edx
  8007d7:	74 0a                	je     8007e3 <strlcpy+0x2b>
  8007d9:	8a 19                	mov    (%ecx),%bl
  8007db:	84 db                	test   %bl,%bl
  8007dd:	75 ef                	jne    8007ce <strlcpy+0x16>
  8007df:	89 c2                	mov    %eax,%edx
  8007e1:	eb 02                	jmp    8007e5 <strlcpy+0x2d>
  8007e3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007e5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e8:	29 f0                	sub    %esi,%eax
}
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f7:	eb 02                	jmp    8007fb <strcmp+0xd>
		p++, q++;
  8007f9:	41                   	inc    %ecx
  8007fa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007fb:	8a 01                	mov    (%ecx),%al
  8007fd:	84 c0                	test   %al,%al
  8007ff:	74 04                	je     800805 <strcmp+0x17>
  800801:	3a 02                	cmp    (%edx),%al
  800803:	74 f4                	je     8007f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800805:	0f b6 c0             	movzbl %al,%eax
  800808:	0f b6 12             	movzbl (%edx),%edx
  80080b:	29 d0                	sub    %edx,%eax
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80081c:	eb 03                	jmp    800821 <strncmp+0x12>
		n--, p++, q++;
  80081e:	4a                   	dec    %edx
  80081f:	40                   	inc    %eax
  800820:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800821:	85 d2                	test   %edx,%edx
  800823:	74 14                	je     800839 <strncmp+0x2a>
  800825:	8a 18                	mov    (%eax),%bl
  800827:	84 db                	test   %bl,%bl
  800829:	74 04                	je     80082f <strncmp+0x20>
  80082b:	3a 19                	cmp    (%ecx),%bl
  80082d:	74 ef                	je     80081e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 11             	movzbl (%ecx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084a:	eb 05                	jmp    800851 <strchr+0x10>
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 0c                	je     80085c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800850:	40                   	inc    %eax
  800851:	8a 10                	mov    (%eax),%dl
  800853:	84 d2                	test   %dl,%dl
  800855:	75 f5                	jne    80084c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800867:	eb 05                	jmp    80086e <strfind+0x10>
		if (*s == c)
  800869:	38 ca                	cmp    %cl,%dl
  80086b:	74 07                	je     800874 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80086d:	40                   	inc    %eax
  80086e:	8a 10                	mov    (%eax),%dl
  800870:	84 d2                	test   %dl,%dl
  800872:	75 f5                	jne    800869 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	57                   	push   %edi
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800882:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800885:	85 c9                	test   %ecx,%ecx
  800887:	74 30                	je     8008b9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800889:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088f:	75 25                	jne    8008b6 <memset+0x40>
  800891:	f6 c1 03             	test   $0x3,%cl
  800894:	75 20                	jne    8008b6 <memset+0x40>
		c &= 0xFF;
  800896:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800899:	89 d3                	mov    %edx,%ebx
  80089b:	c1 e3 08             	shl    $0x8,%ebx
  80089e:	89 d6                	mov    %edx,%esi
  8008a0:	c1 e6 18             	shl    $0x18,%esi
  8008a3:	89 d0                	mov    %edx,%eax
  8008a5:	c1 e0 10             	shl    $0x10,%eax
  8008a8:	09 f0                	or     %esi,%eax
  8008aa:	09 d0                	or     %edx,%eax
  8008ac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b1:	fc                   	cld    
  8008b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b4:	eb 03                	jmp    8008b9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b6:	fc                   	cld    
  8008b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b9:	89 f8                	mov    %edi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ce:	39 c6                	cmp    %eax,%esi
  8008d0:	73 34                	jae    800906 <memmove+0x46>
  8008d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d5:	39 d0                	cmp    %edx,%eax
  8008d7:	73 2d                	jae    800906 <memmove+0x46>
		s += n;
		d += n;
  8008d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dc:	f6 c2 03             	test   $0x3,%dl
  8008df:	75 1b                	jne    8008fc <memmove+0x3c>
  8008e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e7:	75 13                	jne    8008fc <memmove+0x3c>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 0e                	jne    8008fc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ee:	83 ef 04             	sub    $0x4,%edi
  8008f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f7:	fd                   	std    
  8008f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fa:	eb 07                	jmp    800903 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008fc:	4f                   	dec    %edi
  8008fd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800900:	fd                   	std    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800903:	fc                   	cld    
  800904:	eb 20                	jmp    800926 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090c:	75 13                	jne    800921 <memmove+0x61>
  80090e:	a8 03                	test   $0x3,%al
  800910:	75 0f                	jne    800921 <memmove+0x61>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 0a                	jne    800921 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800917:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091a:	89 c7                	mov    %eax,%edi
  80091c:	fc                   	cld    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 05                	jmp    800926 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800921:	89 c7                	mov    %eax,%edi
  800923:	fc                   	cld    
  800924:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800930:	8b 45 10             	mov    0x10(%ebp),%eax
  800933:	89 44 24 08          	mov    %eax,0x8(%esp)
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	89 04 24             	mov    %eax,(%esp)
  800944:	e8 77 ff ff ff       	call   8008c0 <memmove>
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    

0080094b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 7d 08             	mov    0x8(%ebp),%edi
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	eb 16                	jmp    800977 <memcmp+0x2c>
		if (*s1 != *s2)
  800961:	8a 04 17             	mov    (%edi,%edx,1),%al
  800964:	42                   	inc    %edx
  800965:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800969:	38 c8                	cmp    %cl,%al
  80096b:	74 0a                	je     800977 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80096d:	0f b6 c0             	movzbl %al,%eax
  800970:	0f b6 c9             	movzbl %cl,%ecx
  800973:	29 c8                	sub    %ecx,%eax
  800975:	eb 09                	jmp    800980 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800977:	39 da                	cmp    %ebx,%edx
  800979:	75 e6                	jne    800961 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80098e:	89 c2                	mov    %eax,%edx
  800990:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800993:	eb 05                	jmp    80099a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800995:	38 08                	cmp    %cl,(%eax)
  800997:	74 05                	je     80099e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800999:	40                   	inc    %eax
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	72 f7                	jb     800995 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	eb 01                	jmp    8009af <strtol+0xf>
		s++;
  8009ae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009af:	8a 02                	mov    (%edx),%al
  8009b1:	3c 20                	cmp    $0x20,%al
  8009b3:	74 f9                	je     8009ae <strtol+0xe>
  8009b5:	3c 09                	cmp    $0x9,%al
  8009b7:	74 f5                	je     8009ae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b9:	3c 2b                	cmp    $0x2b,%al
  8009bb:	75 08                	jne    8009c5 <strtol+0x25>
		s++;
  8009bd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	eb 13                	jmp    8009d8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c5:	3c 2d                	cmp    $0x2d,%al
  8009c7:	75 0a                	jne    8009d3 <strtol+0x33>
		s++, neg = 1;
  8009c9:	8d 52 01             	lea    0x1(%edx),%edx
  8009cc:	bf 01 00 00 00       	mov    $0x1,%edi
  8009d1:	eb 05                	jmp    8009d8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	74 05                	je     8009e1 <strtol+0x41>
  8009dc:	83 fb 10             	cmp    $0x10,%ebx
  8009df:	75 28                	jne    800a09 <strtol+0x69>
  8009e1:	8a 02                	mov    (%edx),%al
  8009e3:	3c 30                	cmp    $0x30,%al
  8009e5:	75 10                	jne    8009f7 <strtol+0x57>
  8009e7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009eb:	75 0a                	jne    8009f7 <strtol+0x57>
		s += 2, base = 16;
  8009ed:	83 c2 02             	add    $0x2,%edx
  8009f0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f5:	eb 12                	jmp    800a09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009f7:	85 db                	test   %ebx,%ebx
  8009f9:	75 0e                	jne    800a09 <strtol+0x69>
  8009fb:	3c 30                	cmp    $0x30,%al
  8009fd:	75 05                	jne    800a04 <strtol+0x64>
		s++, base = 8;
  8009ff:	42                   	inc    %edx
  800a00:	b3 08                	mov    $0x8,%bl
  800a02:	eb 05                	jmp    800a09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a10:	8a 0a                	mov    (%edx),%cl
  800a12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a15:	80 fb 09             	cmp    $0x9,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x82>
			dig = *s - '0';
  800a1a:	0f be c9             	movsbl %cl,%ecx
  800a1d:	83 e9 30             	sub    $0x30,%ecx
  800a20:	eb 1e                	jmp    800a40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 08                	ja     800a32 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a2a:	0f be c9             	movsbl %cl,%ecx
  800a2d:	83 e9 57             	sub    $0x57,%ecx
  800a30:	eb 0e                	jmp    800a40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 12                	ja     800a4c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a3a:	0f be c9             	movsbl %cl,%ecx
  800a3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a40:	39 f1                	cmp    %esi,%ecx
  800a42:	7d 0c                	jge    800a50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a44:	42                   	inc    %edx
  800a45:	0f af c6             	imul   %esi,%eax
  800a48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a4a:	eb c4                	jmp    800a10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a4c:	89 c1                	mov    %eax,%ecx
  800a4e:	eb 02                	jmp    800a52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a56:	74 05                	je     800a5d <strtol+0xbd>
		*endptr = (char *) s;
  800a58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a5d:	85 ff                	test   %edi,%edi
  800a5f:	74 04                	je     800a65 <strtol+0xc5>
  800a61:	89 c8                	mov    %ecx,%eax
  800a63:	f7 d8                	neg    %eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    
	...

00800a6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	89 c3                	mov    %eax,%ebx
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	89 c6                	mov    %eax,%esi
  800a83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	ba 00 00 00 00       	mov    $0x0,%edx
  800a95:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9a:	89 d1                	mov    %edx,%ecx
  800a9c:	89 d3                	mov    %edx,%ebx
  800a9e:	89 d7                	mov    %edx,%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab7:	b8 03 00 00 00       	mov    $0x3,%eax
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	89 cb                	mov    %ecx,%ebx
  800ac1:	89 cf                	mov    %ecx,%edi
  800ac3:	89 ce                	mov    %ecx,%esi
  800ac5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	7e 28                	jle    800af3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800acf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ad6:	00 
  800ad7:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800ade:	00 
  800adf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ae6:	00 
  800ae7:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800aee:	e8 31 03 00 00       	call   800e24 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af3:	83 c4 2c             	add    $0x2c,%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_yield>:

void
sys_yield(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	be 00 00 00 00       	mov    $0x0,%esi
  800b47:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	89 f7                	mov    %esi,%edi
  800b57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 28                	jle    800b85 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b68:	00 
  800b69:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800b70:	00 
  800b71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b78:	00 
  800b79:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800b80:	e8 9f 02 00 00       	call   800e24 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b85:	83 c4 2c             	add    $0x2c,%esp
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b96:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bac:	85 c0                	test   %eax,%eax
  800bae:	7e 28                	jle    800bd8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bbb:	00 
  800bbc:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800bc3:	00 
  800bc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bcb:	00 
  800bcc:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800bd3:	e8 4c 02 00 00       	call   800e24 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd8:	83 c4 2c             	add    $0x2c,%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 28                	jle    800c2b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800c16:	00 
  800c17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1e:	00 
  800c1f:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800c26:	e8 f9 01 00 00       	call   800e24 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2b:	83 c4 2c             	add    $0x2c,%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	b8 08 00 00 00       	mov    $0x8,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7e 28                	jle    800c7e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c61:	00 
  800c62:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800c69:	00 
  800c6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c71:	00 
  800c72:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800c79:	e8 a6 01 00 00       	call   800e24 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7e:	83 c4 2c             	add    $0x2c,%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 09 00 00 00       	mov    $0x9,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 28                	jle    800cd1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cad:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cb4:	00 
  800cb5:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc4:	00 
  800cc5:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800ccc:	e8 53 01 00 00       	call   800e24 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cd1:	83 c4 2c             	add    $0x2c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 df                	mov    %ebx,%edi
  800cf4:	89 de                	mov    %ebx,%esi
  800cf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7e 28                	jle    800d24 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d00:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d07:	00 
  800d08:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800d1f:	e8 00 01 00 00       	call   800e24 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d24:	83 c4 2c             	add    $0x2c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	be 00 00 00 00       	mov    $0x0,%esi
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	57                   	push   %edi
  800d53:	56                   	push   %esi
  800d54:	53                   	push   %ebx
  800d55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 cb                	mov    %ecx,%ebx
  800d67:	89 cf                	mov    %ecx,%edi
  800d69:	89 ce                	mov    %ecx,%esi
  800d6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 67 14 80 	movl   $0x801467,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800d94:	e8 8b 00 00 00       	call   800e24 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dac:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 d3                	mov    %edx,%ebx
  800db5:	89 d7                	mov    %edx,%edi
  800db7:	89 d6                	mov    %edx,%esi
  800db9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0d:	b8 11 00 00 00       	mov    $0x11,%eax
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 cb                	mov    %ecx,%ebx
  800e17:	89 cf                	mov    %ecx,%edi
  800e19:	89 ce                	mov    %ecx,%esi
  800e1b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
	...

00800e24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e2c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e2f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800e35:	e8 c1 fc ff ff       	call   800afb <sys_getenvid>
  800e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e50:	c7 04 24 94 14 80 00 	movl   $0x801494,(%esp)
  800e57:	e8 40 f3 ff ff       	call   80019c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e60:	8b 45 10             	mov    0x10(%ebp),%eax
  800e63:	89 04 24             	mov    %eax,(%esp)
  800e66:	e8 d0 f2 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  800e6b:	c7 04 24 b8 14 80 00 	movl   $0x8014b8,(%esp)
  800e72:	e8 25 f3 ff ff       	call   80019c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e77:	cc                   	int3   
  800e78:	eb fd                	jmp    800e77 <_panic+0x53>
	...

00800e7c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800e7c:	55                   	push   %ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	83 ec 10             	sub    $0x10,%esp
  800e82:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e86:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800e92:	89 cd                	mov    %ecx,%ebp
  800e94:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	75 2c                	jne    800ec8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800e9c:	39 f9                	cmp    %edi,%ecx
  800e9e:	77 68                	ja     800f08 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800ea0:	85 c9                	test   %ecx,%ecx
  800ea2:	75 0b                	jne    800eaf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800ea4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea9:	31 d2                	xor    %edx,%edx
  800eab:	f7 f1                	div    %ecx
  800ead:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800eaf:	31 d2                	xor    %edx,%edx
  800eb1:	89 f8                	mov    %edi,%eax
  800eb3:	f7 f1                	div    %ecx
  800eb5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	f7 f1                	div    %ecx
  800ebb:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ebd:	89 f0                	mov    %esi,%eax
  800ebf:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ec8:	39 f8                	cmp    %edi,%eax
  800eca:	77 2c                	ja     800ef8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ecc:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800ecf:	83 f6 1f             	xor    $0x1f,%esi
  800ed2:	75 4c                	jne    800f20 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ed4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ed6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800edb:	72 0a                	jb     800ee7 <__udivdi3+0x6b>
  800edd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ee1:	0f 87 ad 00 00 00    	ja     800f94 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800ee7:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800eec:	89 f0                	mov    %esi,%eax
  800eee:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    
  800ef7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ef8:	31 ff                	xor    %edi,%edi
  800efa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800efc:	89 f0                	mov    %esi,%eax
  800efe:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    
  800f07:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f08:	89 fa                	mov    %edi,%edx
  800f0a:	89 f0                	mov    %esi,%eax
  800f0c:	f7 f1                	div    %ecx
  800f0e:	89 c6                	mov    %eax,%esi
  800f10:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f12:	89 f0                	mov    %esi,%eax
  800f14:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f20:	89 f1                	mov    %esi,%ecx
  800f22:	d3 e0                	shl    %cl,%eax
  800f24:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f28:	b8 20 00 00 00       	mov    $0x20,%eax
  800f2d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f2f:	89 ea                	mov    %ebp,%edx
  800f31:	88 c1                	mov    %al,%cl
  800f33:	d3 ea                	shr    %cl,%edx
  800f35:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f39:	09 ca                	or     %ecx,%edx
  800f3b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f3f:	89 f1                	mov    %esi,%ecx
  800f41:	d3 e5                	shl    %cl,%ebp
  800f43:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800f47:	89 fd                	mov    %edi,%ebp
  800f49:	88 c1                	mov    %al,%cl
  800f4b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800f4d:	89 fa                	mov    %edi,%edx
  800f4f:	89 f1                	mov    %esi,%ecx
  800f51:	d3 e2                	shl    %cl,%edx
  800f53:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f57:	88 c1                	mov    %al,%cl
  800f59:	d3 ef                	shr    %cl,%edi
  800f5b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	89 ea                	mov    %ebp,%edx
  800f61:	f7 74 24 08          	divl   0x8(%esp)
  800f65:	89 d1                	mov    %edx,%ecx
  800f67:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800f69:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f6d:	39 d1                	cmp    %edx,%ecx
  800f6f:	72 17                	jb     800f88 <__udivdi3+0x10c>
  800f71:	74 09                	je     800f7c <__udivdi3+0x100>
  800f73:	89 fe                	mov    %edi,%esi
  800f75:	31 ff                	xor    %edi,%edi
  800f77:	e9 41 ff ff ff       	jmp    800ebd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800f7c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f80:	89 f1                	mov    %esi,%ecx
  800f82:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f84:	39 c2                	cmp    %eax,%edx
  800f86:	73 eb                	jae    800f73 <__udivdi3+0xf7>
		{
		  q0--;
  800f88:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f8b:	31 ff                	xor    %edi,%edi
  800f8d:	e9 2b ff ff ff       	jmp    800ebd <__udivdi3+0x41>
  800f92:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f94:	31 f6                	xor    %esi,%esi
  800f96:	e9 22 ff ff ff       	jmp    800ebd <__udivdi3+0x41>
	...

00800f9c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800f9c:	55                   	push   %ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	83 ec 20             	sub    $0x20,%esp
  800fa2:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fa6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800faa:	89 44 24 14          	mov    %eax,0x14(%esp)
  800fae:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800fb2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fb6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800fba:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800fbc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fbe:	85 ed                	test   %ebp,%ebp
  800fc0:	75 16                	jne    800fd8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800fc2:	39 f1                	cmp    %esi,%ecx
  800fc4:	0f 86 a6 00 00 00    	jbe    801070 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800fca:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800fcc:	89 d0                	mov    %edx,%eax
  800fce:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    
  800fd7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800fd8:	39 f5                	cmp    %esi,%ebp
  800fda:	0f 87 ac 00 00 00    	ja     80108c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800fe0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800fe3:	83 f0 1f             	xor    $0x1f,%eax
  800fe6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fea:	0f 84 a8 00 00 00    	je     801098 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ff0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ff4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ff6:	bf 20 00 00 00       	mov    $0x20,%edi
  800ffb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800fff:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801003:	89 f9                	mov    %edi,%ecx
  801005:	d3 e8                	shr    %cl,%eax
  801007:	09 e8                	or     %ebp,%eax
  801009:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80100d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801011:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801015:	d3 e0                	shl    %cl,%eax
  801017:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80101b:	89 f2                	mov    %esi,%edx
  80101d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80101f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801023:	d3 e0                	shl    %cl,%eax
  801025:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801029:	8b 44 24 14          	mov    0x14(%esp),%eax
  80102d:	89 f9                	mov    %edi,%ecx
  80102f:	d3 e8                	shr    %cl,%eax
  801031:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801033:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801035:	89 f2                	mov    %esi,%edx
  801037:	f7 74 24 18          	divl   0x18(%esp)
  80103b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80103d:	f7 64 24 0c          	mull   0xc(%esp)
  801041:	89 c5                	mov    %eax,%ebp
  801043:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801045:	39 d6                	cmp    %edx,%esi
  801047:	72 67                	jb     8010b0 <__umoddi3+0x114>
  801049:	74 75                	je     8010c0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80104b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80104f:	29 e8                	sub    %ebp,%eax
  801051:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801053:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801057:	d3 e8                	shr    %cl,%eax
  801059:	89 f2                	mov    %esi,%edx
  80105b:	89 f9                	mov    %edi,%ecx
  80105d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80105f:	09 d0                	or     %edx,%eax
  801061:	89 f2                	mov    %esi,%edx
  801063:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801067:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801069:	83 c4 20             	add    $0x20,%esp
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801070:	85 c9                	test   %ecx,%ecx
  801072:	75 0b                	jne    80107f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801074:	b8 01 00 00 00       	mov    $0x1,%eax
  801079:	31 d2                	xor    %edx,%edx
  80107b:	f7 f1                	div    %ecx
  80107d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80107f:	89 f0                	mov    %esi,%eax
  801081:	31 d2                	xor    %edx,%edx
  801083:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801085:	89 f8                	mov    %edi,%eax
  801087:	e9 3e ff ff ff       	jmp    800fca <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80108c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80108e:	83 c4 20             	add    $0x20,%esp
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801098:	39 f5                	cmp    %esi,%ebp
  80109a:	72 04                	jb     8010a0 <__umoddi3+0x104>
  80109c:	39 f9                	cmp    %edi,%ecx
  80109e:	77 06                	ja     8010a6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8010a0:	89 f2                	mov    %esi,%edx
  8010a2:	29 cf                	sub    %ecx,%edi
  8010a4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8010a6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    
  8010af:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8010b0:	89 d1                	mov    %edx,%ecx
  8010b2:	89 c5                	mov    %eax,%ebp
  8010b4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8010b8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8010bc:	eb 8d                	jmp    80104b <__umoddi3+0xaf>
  8010be:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010c0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8010c4:	72 ea                	jb     8010b0 <__umoddi3+0x114>
  8010c6:	89 f1                	mov    %esi,%ecx
  8010c8:	eb 81                	jmp    80104b <__umoddi3+0xaf>
