
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  800054:	e8 2b 01 00 00       	call   800184 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 85 0a 00 00       	call   800ae3 <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 2b 0a 00 00       	call   800a91 <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 92 0d 00 00       	call   800e0c <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
	...

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 75 08             	mov    0x8(%ebp),%esi
  800093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800096:	e8 48 0a 00 00       	call   800ae3 <sys_getenvid>
  80009b:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a0:	c1 e0 07             	shl    $0x7,%eax
  8000a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ad:	85 f6                	test   %esi,%esi
  8000af:	7e 07                	jle    8000b8 <libmain+0x30>
		binaryname = argv[0];
  8000b1:	8b 03                	mov    (%ebx),%eax
  8000b3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000bc:	89 34 24             	mov    %esi,(%esp)
  8000bf:	e8 a4 ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000c4:	e8 07 00 00 00       	call   8000d0 <exit>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000dd:	e8 af 09 00 00       	call   800a91 <sys_env_destroy>
}
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 14             	sub    $0x14,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 03                	mov    (%ebx),%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8000f7:	40                   	inc    %eax
  8000f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8000fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ff:	75 19                	jne    80011a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800101:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800108:	00 
  800109:	8d 43 08             	lea    0x8(%ebx),%eax
  80010c:	89 04 24             	mov    %eax,(%esp)
  80010f:	e8 40 09 00 00       	call   800a54 <sys_cputs>
		b->idx = 0;
  800114:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80011a:	ff 43 04             	incl   0x4(%ebx)
}
  80011d:	83 c4 14             	add    $0x14,%esp
  800120:	5b                   	pop    %ebx
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800133:	00 00 00 
	b.cnt = 0;
  800136:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800140:	8b 45 0c             	mov    0xc(%ebp),%eax
  800143:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800147:	8b 45 08             	mov    0x8(%ebp),%eax
  80014a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800154:	89 44 24 04          	mov    %eax,0x4(%esp)
  800158:	c7 04 24 e4 00 80 00 	movl   $0x8000e4,(%esp)
  80015f:	e8 82 01 00 00       	call   8002e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800164:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800174:	89 04 24             	mov    %eax,(%esp)
  800177:	e8 d8 08 00 00       	call   800a54 <sys_cputs>

	return b.cnt;
}
  80017c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	8b 45 08             	mov    0x8(%ebp),%eax
  800194:	89 04 24             	mov    %eax,(%esp)
  800197:	e8 87 ff ff ff       	call   800123 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	75 08                	jne    8001cc <printnum+0x2c>
  8001c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ca:	77 57                	ja     800223 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001d0:	4b                   	dec    %ebx
  8001d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8001e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8001e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001eb:	00 
  8001ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f9:	e8 fe 0c 00 00       	call   800efc <__udivdi3>
  8001fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800202:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	89 fa                	mov    %edi,%edx
  80020f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800212:	e8 89 ff ff ff       	call   8001a0 <printnum>
  800217:	eb 0f                	jmp    800228 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800219:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021d:	89 34 24             	mov    %esi,(%esp)
  800220:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800223:	4b                   	dec    %ebx
  800224:	85 db                	test   %ebx,%ebx
  800226:	7f f1                	jg     800219 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800228:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80022c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800230:	8b 45 10             	mov    0x10(%ebp),%eax
  800233:	89 44 24 08          	mov    %eax,0x8(%esp)
  800237:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023e:	00 
  80023f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024c:	e8 cb 0d 00 00       	call   80101c <__umoddi3>
  800251:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800255:	0f be 80 86 11 80 00 	movsbl 0x801186(%eax),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800262:	83 c4 3c             	add    $0x3c,%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026d:	83 fa 01             	cmp    $0x1,%edx
  800270:	7e 0e                	jle    800280 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 08             	lea    0x8(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	8b 52 04             	mov    0x4(%edx),%edx
  80027e:	eb 22                	jmp    8002a2 <getuint+0x38>
	else if (lflag)
  800280:	85 d2                	test   %edx,%edx
  800282:	74 10                	je     800294 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800284:	8b 10                	mov    (%eax),%edx
  800286:	8d 4a 04             	lea    0x4(%edx),%ecx
  800289:	89 08                	mov    %ecx,(%eax)
  80028b:	8b 02                	mov    (%edx),%eax
  80028d:	ba 00 00 00 00       	mov    $0x0,%edx
  800292:	eb 0e                	jmp    8002a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800294:	8b 10                	mov    (%eax),%edx
  800296:	8d 4a 04             	lea    0x4(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 02                	mov    (%edx),%eax
  80029d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    

008002a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002ad:	8b 10                	mov    (%eax),%edx
  8002af:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b2:	73 08                	jae    8002bc <sprintputch+0x18>
		*b->buf++ = ch;
  8002b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b7:	88 0a                	mov    %cl,(%edx)
  8002b9:	42                   	inc    %edx
  8002ba:	89 10                	mov    %edx,(%eax)
}
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	e8 02 00 00 00       	call   8002e6 <vprintfmt>
	va_end(ap);
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    

008002e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 4c             	sub    $0x4c,%esp
  8002ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8002f5:	eb 12                	jmp    800309 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	0f 84 6b 03 00 00    	je     80066a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8002ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800303:	89 04 24             	mov    %eax,(%esp)
  800306:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 06             	movzbl (%esi),%eax
  80030c:	46                   	inc    %esi
  80030d:	83 f8 25             	cmp    $0x25,%eax
  800310:	75 e5                	jne    8002f7 <vprintfmt+0x11>
  800312:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800316:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80031d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800322:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	eb 26                	jmp    800356 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800333:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800337:	eb 1d                	jmp    800356 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800340:	eb 14                	jmp    800356 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800345:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034c:	eb 08                	jmp    800356 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80034e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800351:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	0f b6 06             	movzbl (%esi),%eax
  800359:	8d 56 01             	lea    0x1(%esi),%edx
  80035c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80035f:	8a 16                	mov    (%esi),%dl
  800361:	83 ea 23             	sub    $0x23,%edx
  800364:	80 fa 55             	cmp    $0x55,%dl
  800367:	0f 87 e1 02 00 00    	ja     80064e <vprintfmt+0x368>
  80036d:	0f b6 d2             	movzbl %dl,%edx
  800370:	ff 24 95 c0 12 80 00 	jmp    *0x8012c0(,%edx,4)
  800377:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80037a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800382:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800386:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800389:	8d 50 d0             	lea    -0x30(%eax),%edx
  80038c:	83 fa 09             	cmp    $0x9,%edx
  80038f:	77 2a                	ja     8003bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800391:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800392:	eb eb                	jmp    80037f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 50 04             	lea    0x4(%eax),%edx
  80039a:	89 55 14             	mov    %edx,0x14(%ebp)
  80039d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a2:	eb 17                	jmp    8003bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a8:	78 98                	js     800342 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ad:	eb a7                	jmp    800356 <vprintfmt+0x70>
  8003af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003b9:	eb 9b                	jmp    800356 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003bf:	79 95                	jns    800356 <vprintfmt+0x70>
  8003c1:	eb 8b                	jmp    80034e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c7:	eb 8d                	jmp    800356 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 04 24             	mov    %eax,(%esp)
  8003db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 23 ff ff ff       	jmp    800309 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	85 c0                	test   %eax,%eax
  8003f3:	79 02                	jns    8003f7 <vprintfmt+0x111>
  8003f5:	f7 d8                	neg    %eax
  8003f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f9:	83 f8 11             	cmp    $0x11,%eax
  8003fc:	7f 0b                	jg     800409 <vprintfmt+0x123>
  8003fe:	8b 04 85 20 14 80 00 	mov    0x801420(,%eax,4),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	75 23                	jne    80042c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800409:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80040d:	c7 44 24 08 9e 11 80 	movl   $0x80119e,0x8(%esp)
  800414:	00 
  800415:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 9a fe ff ff       	call   8002be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800427:	e9 dd fe ff ff       	jmp    800309 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80042c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800430:	c7 44 24 08 a7 11 80 	movl   $0x8011a7,0x8(%esp)
  800437:	00 
  800438:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043c:	8b 55 08             	mov    0x8(%ebp),%edx
  80043f:	89 14 24             	mov    %edx,(%esp)
  800442:	e8 77 fe ff ff       	call   8002be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80044a:	e9 ba fe ff ff       	jmp    800309 <vprintfmt+0x23>
  80044f:	89 f9                	mov    %edi,%ecx
  800451:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800454:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	8b 30                	mov    (%eax),%esi
  800462:	85 f6                	test   %esi,%esi
  800464:	75 05                	jne    80046b <vprintfmt+0x185>
				p = "(null)";
  800466:	be 97 11 80 00       	mov    $0x801197,%esi
			if (width > 0 && padc != '-')
  80046b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046f:	0f 8e 84 00 00 00    	jle    8004f9 <vprintfmt+0x213>
  800475:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800479:	74 7e                	je     8004f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80047f:	89 34 24             	mov    %esi,(%esp)
  800482:	e8 8b 02 00 00       	call   800712 <strnlen>
  800487:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80048a:	29 c2                	sub    %eax,%edx
  80048c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80048f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800493:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800496:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800499:	89 de                	mov    %ebx,%esi
  80049b:	89 d3                	mov    %edx,%ebx
  80049d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049f:	eb 0b                	jmp    8004ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a5:	89 3c 24             	mov    %edi,(%esp)
  8004a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	4b                   	dec    %ebx
  8004ac:	85 db                	test   %ebx,%ebx
  8004ae:	7f f1                	jg     8004a1 <vprintfmt+0x1bb>
  8004b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004b3:	89 f3                	mov    %esi,%ebx
  8004b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	79 05                	jns    8004c4 <vprintfmt+0x1de>
  8004bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c7:	29 c2                	sub    %eax,%edx
  8004c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004cc:	eb 2b                	jmp    8004f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d2:	74 18                	je     8004ec <vprintfmt+0x206>
  8004d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004d7:	83 fa 5e             	cmp    $0x5e,%edx
  8004da:	76 10                	jbe    8004ec <vprintfmt+0x206>
					putch('?', putdat);
  8004dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e7:	ff 55 08             	call   *0x8(%ebp)
  8004ea:	eb 0a                	jmp    8004f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8004ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004f9:	0f be 06             	movsbl (%esi),%eax
  8004fc:	46                   	inc    %esi
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	74 21                	je     800522 <vprintfmt+0x23c>
  800501:	85 ff                	test   %edi,%edi
  800503:	78 c9                	js     8004ce <vprintfmt+0x1e8>
  800505:	4f                   	dec    %edi
  800506:	79 c6                	jns    8004ce <vprintfmt+0x1e8>
  800508:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050b:	89 de                	mov    %ebx,%esi
  80050d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800510:	eb 18                	jmp    80052a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800512:	89 74 24 04          	mov    %esi,0x4(%esp)
  800516:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80051d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051f:	4b                   	dec    %ebx
  800520:	eb 08                	jmp    80052a <vprintfmt+0x244>
  800522:	8b 7d 08             	mov    0x8(%ebp),%edi
  800525:	89 de                	mov    %ebx,%esi
  800527:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80052a:	85 db                	test   %ebx,%ebx
  80052c:	7f e4                	jg     800512 <vprintfmt+0x22c>
  80052e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800531:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800536:	e9 ce fd ff ff       	jmp    800309 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053b:	83 f9 01             	cmp    $0x1,%ecx
  80053e:	7e 10                	jle    800550 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 08             	lea    0x8(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 30                	mov    (%eax),%esi
  80054b:	8b 78 04             	mov    0x4(%eax),%edi
  80054e:	eb 26                	jmp    800576 <vprintfmt+0x290>
	else if (lflag)
  800550:	85 c9                	test   %ecx,%ecx
  800552:	74 12                	je     800566 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 04             	lea    0x4(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 30                	mov    (%eax),%esi
  80055f:	89 f7                	mov    %esi,%edi
  800561:	c1 ff 1f             	sar    $0x1f,%edi
  800564:	eb 10                	jmp    800576 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 30                	mov    (%eax),%esi
  800571:	89 f7                	mov    %esi,%edi
  800573:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800576:	85 ff                	test   %edi,%edi
  800578:	78 0a                	js     800584 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 8c 00 00 00       	jmp    800610 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800584:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800588:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80058f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800592:	f7 de                	neg    %esi
  800594:	83 d7 00             	adc    $0x0,%edi
  800597:	f7 df                	neg    %edi
			}
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059e:	eb 70                	jmp    800610 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a0:	89 ca                	mov    %ecx,%edx
  8005a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a5:	e8 c0 fc ff ff       	call   80026a <getuint>
  8005aa:	89 c6                	mov    %eax,%esi
  8005ac:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b3:	eb 5b                	jmp    800610 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8005b5:	89 ca                	mov    %ecx,%edx
  8005b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ba:	e8 ab fc ff ff       	call   80026a <getuint>
  8005bf:	89 c6                	mov    %eax,%esi
  8005c1:	89 d7                	mov    %edx,%edi
			base = 8;
  8005c3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005c8:	eb 46                	jmp    800610 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ef:	8b 30                	mov    (%eax),%esi
  8005f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005fb:	eb 13                	jmp    800610 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fd:	89 ca                	mov    %ecx,%edx
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 63 fc ff ff       	call   80026a <getuint>
  800607:	89 c6                	mov    %eax,%esi
  800609:	89 d7                	mov    %edx,%edi
			base = 16;
  80060b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800610:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800614:	89 54 24 10          	mov    %edx,0x10(%esp)
  800618:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062a:	89 da                	mov    %ebx,%edx
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	e8 6c fb ff ff       	call   8001a0 <printnum>
			break;
  800634:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800637:	e9 cd fc ff ff       	jmp    800309 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800649:	e9 bb fc ff ff       	jmp    800309 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800652:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800659:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065c:	eb 01                	jmp    80065f <vprintfmt+0x379>
  80065e:	4e                   	dec    %esi
  80065f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800663:	75 f9                	jne    80065e <vprintfmt+0x378>
  800665:	e9 9f fc ff ff       	jmp    800309 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80066a:	83 c4 4c             	add    $0x4c,%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5f                   	pop    %edi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	83 ec 28             	sub    $0x28,%esp
  800678:	8b 45 08             	mov    0x8(%ebp),%eax
  80067b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800681:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800685:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068f:	85 c0                	test   %eax,%eax
  800691:	74 30                	je     8006c3 <vsnprintf+0x51>
  800693:	85 d2                	test   %edx,%edx
  800695:	7e 33                	jle    8006ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80069e:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ac:	c7 04 24 a4 02 80 00 	movl   $0x8002a4,(%esp)
  8006b3:	e8 2e fc ff ff       	call   8002e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c1:	eb 0c                	jmp    8006cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c8:	eb 05                	jmp    8006cf <vsnprintf+0x5d>
  8006ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 7b ff ff ff       	call   800672 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    
  8006f9:	00 00                	add    %al,(%eax)
	...

008006fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	eb 01                	jmp    80070a <strlen+0xe>
		n++;
  800709:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070e:	75 f9                	jne    800709 <strlen+0xd>
		n++;
	return n;
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
  800720:	eb 01                	jmp    800723 <strnlen+0x11>
		n++;
  800722:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	39 d0                	cmp    %edx,%eax
  800725:	74 06                	je     80072d <strnlen+0x1b>
  800727:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072b:	75 f5                	jne    800722 <strnlen+0x10>
		n++;
	return n;
}
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
  80073e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800741:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800744:	42                   	inc    %edx
  800745:	84 c9                	test   %cl,%cl
  800747:	75 f5                	jne    80073e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800749:	5b                   	pop    %ebx
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800756:	89 1c 24             	mov    %ebx,(%esp)
  800759:	e8 9e ff ff ff       	call   8006fc <strlen>
	strcpy(dst + len, src);
  80075e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800761:	89 54 24 04          	mov    %edx,0x4(%esp)
  800765:	01 d8                	add    %ebx,%eax
  800767:	89 04 24             	mov    %eax,(%esp)
  80076a:	e8 c0 ff ff ff       	call   80072f <strcpy>
	return dst;
}
  80076f:	89 d8                	mov    %ebx,%eax
  800771:	83 c4 08             	add    $0x8,%esp
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800782:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800785:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078a:	eb 0c                	jmp    800798 <strncpy+0x21>
		*dst++ = *src;
  80078c:	8a 1a                	mov    (%edx),%bl
  80078e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800791:	80 3a 01             	cmpb   $0x1,(%edx)
  800794:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	41                   	inc    %ecx
  800798:	39 f1                	cmp    %esi,%ecx
  80079a:	75 f0                	jne    80078c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	56                   	push   %esi
  8007a4:	53                   	push   %ebx
  8007a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	75 0a                	jne    8007bc <strlcpy+0x1c>
  8007b2:	89 f0                	mov    %esi,%eax
  8007b4:	eb 1a                	jmp    8007d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b6:	88 18                	mov    %bl,(%eax)
  8007b8:	40                   	inc    %eax
  8007b9:	41                   	inc    %ecx
  8007ba:	eb 02                	jmp    8007be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007be:	4a                   	dec    %edx
  8007bf:	74 0a                	je     8007cb <strlcpy+0x2b>
  8007c1:	8a 19                	mov    (%ecx),%bl
  8007c3:	84 db                	test   %bl,%bl
  8007c5:	75 ef                	jne    8007b6 <strlcpy+0x16>
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	eb 02                	jmp    8007cd <strlcpy+0x2d>
  8007cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007d0:	29 f0                	sub    %esi,%eax
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5e                   	pop    %esi
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007df:	eb 02                	jmp    8007e3 <strcmp+0xd>
		p++, q++;
  8007e1:	41                   	inc    %ecx
  8007e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e3:	8a 01                	mov    (%ecx),%al
  8007e5:	84 c0                	test   %al,%al
  8007e7:	74 04                	je     8007ed <strcmp+0x17>
  8007e9:	3a 02                	cmp    (%edx),%al
  8007eb:	74 f4                	je     8007e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ed:	0f b6 c0             	movzbl %al,%eax
  8007f0:	0f b6 12             	movzbl (%edx),%edx
  8007f3:	29 d0                	sub    %edx,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800801:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800804:	eb 03                	jmp    800809 <strncmp+0x12>
		n--, p++, q++;
  800806:	4a                   	dec    %edx
  800807:	40                   	inc    %eax
  800808:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 14                	je     800821 <strncmp+0x2a>
  80080d:	8a 18                	mov    (%eax),%bl
  80080f:	84 db                	test   %bl,%bl
  800811:	74 04                	je     800817 <strncmp+0x20>
  800813:	3a 19                	cmp    (%ecx),%bl
  800815:	74 ef                	je     800806 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800817:	0f b6 00             	movzbl (%eax),%eax
  80081a:	0f b6 11             	movzbl (%ecx),%edx
  80081d:	29 d0                	sub    %edx,%eax
  80081f:	eb 05                	jmp    800826 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800821:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800826:	5b                   	pop    %ebx
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800832:	eb 05                	jmp    800839 <strchr+0x10>
		if (*s == c)
  800834:	38 ca                	cmp    %cl,%dl
  800836:	74 0c                	je     800844 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800838:	40                   	inc    %eax
  800839:	8a 10                	mov    (%eax),%dl
  80083b:	84 d2                	test   %dl,%dl
  80083d:	75 f5                	jne    800834 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084f:	eb 05                	jmp    800856 <strfind+0x10>
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 07                	je     80085c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800855:	40                   	inc    %eax
  800856:	8a 10                	mov    (%eax),%dl
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f5                	jne    800851 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 7d 08             	mov    0x8(%ebp),%edi
  800867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 30                	je     8008a1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800871:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800877:	75 25                	jne    80089e <memset+0x40>
  800879:	f6 c1 03             	test   $0x3,%cl
  80087c:	75 20                	jne    80089e <memset+0x40>
		c &= 0xFF;
  80087e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800881:	89 d3                	mov    %edx,%ebx
  800883:	c1 e3 08             	shl    $0x8,%ebx
  800886:	89 d6                	mov    %edx,%esi
  800888:	c1 e6 18             	shl    $0x18,%esi
  80088b:	89 d0                	mov    %edx,%eax
  80088d:	c1 e0 10             	shl    $0x10,%eax
  800890:	09 f0                	or     %esi,%eax
  800892:	09 d0                	or     %edx,%eax
  800894:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800896:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800899:	fc                   	cld    
  80089a:	f3 ab                	rep stos %eax,%es:(%edi)
  80089c:	eb 03                	jmp    8008a1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089e:	fc                   	cld    
  80089f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b6:	39 c6                	cmp    %eax,%esi
  8008b8:	73 34                	jae    8008ee <memmove+0x46>
  8008ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bd:	39 d0                	cmp    %edx,%eax
  8008bf:	73 2d                	jae    8008ee <memmove+0x46>
		s += n;
		d += n;
  8008c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c4:	f6 c2 03             	test   $0x3,%dl
  8008c7:	75 1b                	jne    8008e4 <memmove+0x3c>
  8008c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cf:	75 13                	jne    8008e4 <memmove+0x3c>
  8008d1:	f6 c1 03             	test   $0x3,%cl
  8008d4:	75 0e                	jne    8008e4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008d6:	83 ef 04             	sub    $0x4,%edi
  8008d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008dc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008df:	fd                   	std    
  8008e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e2:	eb 07                	jmp    8008eb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008e4:	4f                   	dec    %edi
  8008e5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e8:	fd                   	std    
  8008e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008eb:	fc                   	cld    
  8008ec:	eb 20                	jmp    80090e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f4:	75 13                	jne    800909 <memmove+0x61>
  8008f6:	a8 03                	test   $0x3,%al
  8008f8:	75 0f                	jne    800909 <memmove+0x61>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0a                	jne    800909 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 05                	jmp    80090e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800918:	8b 45 10             	mov    0x10(%ebp),%eax
  80091b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80091f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	89 04 24             	mov    %eax,(%esp)
  80092c:	e8 77 ff ff ff       	call   8008a8 <memmove>
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800942:	ba 00 00 00 00       	mov    $0x0,%edx
  800947:	eb 16                	jmp    80095f <memcmp+0x2c>
		if (*s1 != *s2)
  800949:	8a 04 17             	mov    (%edi,%edx,1),%al
  80094c:	42                   	inc    %edx
  80094d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800951:	38 c8                	cmp    %cl,%al
  800953:	74 0a                	je     80095f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800955:	0f b6 c0             	movzbl %al,%eax
  800958:	0f b6 c9             	movzbl %cl,%ecx
  80095b:	29 c8                	sub    %ecx,%eax
  80095d:	eb 09                	jmp    800968 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095f:	39 da                	cmp    %ebx,%edx
  800961:	75 e6                	jne    800949 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800976:	89 c2                	mov    %eax,%edx
  800978:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097b:	eb 05                	jmp    800982 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097d:	38 08                	cmp    %cl,(%eax)
  80097f:	74 05                	je     800986 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800981:	40                   	inc    %eax
  800982:	39 d0                	cmp    %edx,%eax
  800984:	72 f7                	jb     80097d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 55 08             	mov    0x8(%ebp),%edx
  800991:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800994:	eb 01                	jmp    800997 <strtol+0xf>
		s++;
  800996:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	8a 02                	mov    (%edx),%al
  800999:	3c 20                	cmp    $0x20,%al
  80099b:	74 f9                	je     800996 <strtol+0xe>
  80099d:	3c 09                	cmp    $0x9,%al
  80099f:	74 f5                	je     800996 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a1:	3c 2b                	cmp    $0x2b,%al
  8009a3:	75 08                	jne    8009ad <strtol+0x25>
		s++;
  8009a5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ab:	eb 13                	jmp    8009c0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ad:	3c 2d                	cmp    $0x2d,%al
  8009af:	75 0a                	jne    8009bb <strtol+0x33>
		s++, neg = 1;
  8009b1:	8d 52 01             	lea    0x1(%edx),%edx
  8009b4:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b9:	eb 05                	jmp    8009c0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009bb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c0:	85 db                	test   %ebx,%ebx
  8009c2:	74 05                	je     8009c9 <strtol+0x41>
  8009c4:	83 fb 10             	cmp    $0x10,%ebx
  8009c7:	75 28                	jne    8009f1 <strtol+0x69>
  8009c9:	8a 02                	mov    (%edx),%al
  8009cb:	3c 30                	cmp    $0x30,%al
  8009cd:	75 10                	jne    8009df <strtol+0x57>
  8009cf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009d3:	75 0a                	jne    8009df <strtol+0x57>
		s += 2, base = 16;
  8009d5:	83 c2 02             	add    $0x2,%edx
  8009d8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009dd:	eb 12                	jmp    8009f1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8009df:	85 db                	test   %ebx,%ebx
  8009e1:	75 0e                	jne    8009f1 <strtol+0x69>
  8009e3:	3c 30                	cmp    $0x30,%al
  8009e5:	75 05                	jne    8009ec <strtol+0x64>
		s++, base = 8;
  8009e7:	42                   	inc    %edx
  8009e8:	b3 08                	mov    $0x8,%bl
  8009ea:	eb 05                	jmp    8009f1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  8009ec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f8:	8a 0a                	mov    (%edx),%cl
  8009fa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x82>
			dig = *s - '0';
  800a02:	0f be c9             	movsbl %cl,%ecx
  800a05:	83 e9 30             	sub    $0x30,%ecx
  800a08:	eb 1e                	jmp    800a28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 08                	ja     800a1a <strtol+0x92>
			dig = *s - 'a' + 10;
  800a12:	0f be c9             	movsbl %cl,%ecx
  800a15:	83 e9 57             	sub    $0x57,%ecx
  800a18:	eb 0e                	jmp    800a28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a1d:	80 fb 19             	cmp    $0x19,%bl
  800a20:	77 12                	ja     800a34 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a22:	0f be c9             	movsbl %cl,%ecx
  800a25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a28:	39 f1                	cmp    %esi,%ecx
  800a2a:	7d 0c                	jge    800a38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a2c:	42                   	inc    %edx
  800a2d:	0f af c6             	imul   %esi,%eax
  800a30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a32:	eb c4                	jmp    8009f8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a34:	89 c1                	mov    %eax,%ecx
  800a36:	eb 02                	jmp    800a3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3e:	74 05                	je     800a45 <strtol+0xbd>
		*endptr = (char *) s;
  800a40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a45:	85 ff                	test   %edi,%edi
  800a47:	74 04                	je     800a4d <strtol+0xc5>
  800a49:	89 c8                	mov    %ecx,%eax
  800a4b:	f7 d8                	neg    %eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    
	...

00800a54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	89 c6                	mov    %eax,%esi
  800a6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a82:	89 d1                	mov    %edx,%ecx
  800a84:	89 d3                	mov    %edx,%ebx
  800a86:	89 d7                	mov    %edx,%edi
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	89 cb                	mov    %ecx,%ebx
  800aa9:	89 cf                	mov    %ecx,%edi
  800aab:	89 ce                	mov    %ecx,%esi
  800aad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	7e 28                	jle    800adb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ab7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800abe:	00 
  800abf:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800ac6:	00 
  800ac7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ace:	00 
  800acf:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800ad6:	e8 c9 03 00 00       	call   800ea4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adb:	83 c4 2c             	add    $0x2c,%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 02 00 00 00       	mov    $0x2,%eax
  800af3:	89 d1                	mov    %edx,%ecx
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	89 d7                	mov    %edx,%edi
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_yield>:

void
sys_yield(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	be 00 00 00 00       	mov    $0x0,%esi
  800b2f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 f7                	mov    %esi,%edi
  800b3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b41:	85 c0                	test   %eax,%eax
  800b43:	7e 28                	jle    800b6d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b45:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b49:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b50:	00 
  800b51:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800b58:	00 
  800b59:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b60:	00 
  800b61:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800b68:	e8 37 03 00 00       	call   800ea4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6d:	83 c4 2c             	add    $0x2c,%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	57                   	push   %edi
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b8 05 00 00 00       	mov    $0x5,%eax
  800b83:	8b 75 18             	mov    0x18(%ebp),%esi
  800b86:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 28                	jle    800bc0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b9c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ba3:	00 
  800ba4:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800bab:	00 
  800bac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb3:	00 
  800bb4:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800bbb:	e8 e4 02 00 00       	call   800ea4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc0:	83 c4 2c             	add    $0x2c,%esp
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	89 df                	mov    %ebx,%edi
  800be3:	89 de                	mov    %ebx,%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 28                	jle    800c13 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800c0e:	e8 91 02 00 00       	call   800ea4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c13:	83 c4 2c             	add    $0x2c,%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c29:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	89 df                	mov    %ebx,%edi
  800c36:	89 de                	mov    %ebx,%esi
  800c38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	7e 28                	jle    800c66 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c42:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c49:	00 
  800c4a:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800c51:	00 
  800c52:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c59:	00 
  800c5a:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800c61:	e8 3e 02 00 00       	call   800ea4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c66:	83 c4 2c             	add    $0x2c,%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 28                	jle    800cb9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c95:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cac:	00 
  800cad:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800cb4:	e8 eb 01 00 00       	call   800ea4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cb9:	83 c4 2c             	add    $0x2c,%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 28                	jle    800d0c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce8:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cff:	00 
  800d00:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800d07:	e8 98 01 00 00       	call   800ea4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0c:	83 c4 2c             	add    $0x2c,%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	be 00 00 00 00       	mov    $0x0,%esi
  800d1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 cb                	mov    %ecx,%ebx
  800d4f:	89 cf                	mov    %ecx,%edi
  800d51:	89 ce                	mov    %ecx,%esi
  800d53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 28                	jle    800d81 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d64:	00 
  800d65:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d74:	00 
  800d75:	c7 04 24 a4 14 80 00 	movl   $0x8014a4,(%esp)
  800d7c:	e8 23 01 00 00       	call   800ea4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d81:	83 c4 2c             	add    $0x2c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d94:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	89 d3                	mov    %edx,%ebx
  800d9d:	89 d7                	mov    %edx,%edi
  800d9f:	89 d6                	mov    %edx,%esi
  800da1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db3:	b8 10 00 00 00       	mov    $0x10,%eax
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 df                	mov    %ebx,%edi
  800dc0:	89 de                	mov    %ebx,%esi
  800dc2:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd4:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	89 df                	mov    %ebx,%edi
  800de1:	89 de                	mov    %ebx,%esi
  800de3:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df5:	b8 11 00 00 00       	mov    $0x11,%eax
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 cb                	mov    %ecx,%ebx
  800dff:	89 cf                	mov    %ecx,%edi
  800e01:	89 ce                	mov    %ecx,%esi
  800e03:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
	...

00800e0c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e12:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800e19:	75 58                	jne    800e73 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  800e1b:	a1 04 20 80 00       	mov    0x802004,%eax
  800e20:	8b 40 48             	mov    0x48(%eax),%eax
  800e23:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800e32:	ee 
  800e33:	89 04 24             	mov    %eax,(%esp)
  800e36:	e8 e6 fc ff ff       	call   800b21 <sys_page_alloc>
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	74 1c                	je     800e5b <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  800e3f:	c7 44 24 08 b2 14 80 	movl   $0x8014b2,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  800e56:	e8 49 00 00 00       	call   800ea4 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e5b:	a1 04 20 80 00       	mov    0x802004,%eax
  800e60:	8b 40 48             	mov    0x48(%eax),%eax
  800e63:	c7 44 24 04 80 0e 80 	movl   $0x800e80,0x4(%esp)
  800e6a:	00 
  800e6b:	89 04 24             	mov    %eax,(%esp)
  800e6e:	e8 4e fe ff ff       	call   800cc1 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e73:	8b 45 08             	mov    0x8(%ebp),%eax
  800e76:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e7b:	c9                   	leave  
  800e7c:	c3                   	ret    
  800e7d:	00 00                	add    %al,(%eax)
	...

00800e80 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e80:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e81:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e86:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e88:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  800e8b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  800e8f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  800e91:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  800e95:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  800e96:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  800e99:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  800e9b:	58                   	pop    %eax
	popl %eax
  800e9c:	58                   	pop    %eax

	// Pop all registers back
	popal
  800e9d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  800e9e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  800ea1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  800ea2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  800ea3:	c3                   	ret    

00800ea4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800eac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800eaf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800eb5:	e8 29 fc ff ff       	call   800ae3 <sys_getenvid>
  800eba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ec8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ecc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed0:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800ed7:	e8 a8 f2 ff ff       	call   800184 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800edc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	e8 38 f2 ff ff       	call   800123 <vcprintf>
	cprintf("\n");
  800eeb:	c7 04 24 7a 11 80 00 	movl   $0x80117a,(%esp)
  800ef2:	e8 8d f2 ff ff       	call   800184 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ef7:	cc                   	int3   
  800ef8:	eb fd                	jmp    800ef7 <_panic+0x53>
	...

00800efc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800efc:	55                   	push   %ebp
  800efd:	57                   	push   %edi
  800efe:	56                   	push   %esi
  800eff:	83 ec 10             	sub    $0x10,%esp
  800f02:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f06:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800f0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800f12:	89 cd                	mov    %ecx,%ebp
  800f14:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	75 2c                	jne    800f48 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800f1c:	39 f9                	cmp    %edi,%ecx
  800f1e:	77 68                	ja     800f88 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f20:	85 c9                	test   %ecx,%ecx
  800f22:	75 0b                	jne    800f2f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f24:	b8 01 00 00 00       	mov    $0x1,%eax
  800f29:	31 d2                	xor    %edx,%edx
  800f2b:	f7 f1                	div    %ecx
  800f2d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f2f:	31 d2                	xor    %edx,%edx
  800f31:	89 f8                	mov    %edi,%eax
  800f33:	f7 f1                	div    %ecx
  800f35:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	f7 f1                	div    %ecx
  800f3b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f3d:	89 f0                	mov    %esi,%eax
  800f3f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f48:	39 f8                	cmp    %edi,%eax
  800f4a:	77 2c                	ja     800f78 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f4c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800f4f:	83 f6 1f             	xor    $0x1f,%esi
  800f52:	75 4c                	jne    800fa0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f54:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f56:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f5b:	72 0a                	jb     800f67 <__udivdi3+0x6b>
  800f5d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f61:	0f 87 ad 00 00 00    	ja     801014 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f67:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f6c:	89 f0                	mov    %esi,%eax
  800f6e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f70:	83 c4 10             	add    $0x10,%esp
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    
  800f77:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f78:	31 ff                	xor    %edi,%edi
  800f7a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f7c:	89 f0                	mov    %esi,%eax
  800f7e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f88:	89 fa                	mov    %edi,%edx
  800f8a:	89 f0                	mov    %esi,%eax
  800f8c:	f7 f1                	div    %ecx
  800f8e:	89 c6                	mov    %eax,%esi
  800f90:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f92:	89 f0                	mov    %esi,%eax
  800f94:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800fa0:	89 f1                	mov    %esi,%ecx
  800fa2:	d3 e0                	shl    %cl,%eax
  800fa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800fa8:	b8 20 00 00 00       	mov    $0x20,%eax
  800fad:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800faf:	89 ea                	mov    %ebp,%edx
  800fb1:	88 c1                	mov    %al,%cl
  800fb3:	d3 ea                	shr    %cl,%edx
  800fb5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800fb9:	09 ca                	or     %ecx,%edx
  800fbb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800fbf:	89 f1                	mov    %esi,%ecx
  800fc1:	d3 e5                	shl    %cl,%ebp
  800fc3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800fc7:	89 fd                	mov    %edi,%ebp
  800fc9:	88 c1                	mov    %al,%cl
  800fcb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800fcd:	89 fa                	mov    %edi,%edx
  800fcf:	89 f1                	mov    %esi,%ecx
  800fd1:	d3 e2                	shl    %cl,%edx
  800fd3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd7:	88 c1                	mov    %al,%cl
  800fd9:	d3 ef                	shr    %cl,%edi
  800fdb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fdd:	89 f8                	mov    %edi,%eax
  800fdf:	89 ea                	mov    %ebp,%edx
  800fe1:	f7 74 24 08          	divl   0x8(%esp)
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800fe9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fed:	39 d1                	cmp    %edx,%ecx
  800fef:	72 17                	jb     801008 <__udivdi3+0x10c>
  800ff1:	74 09                	je     800ffc <__udivdi3+0x100>
  800ff3:	89 fe                	mov    %edi,%esi
  800ff5:	31 ff                	xor    %edi,%edi
  800ff7:	e9 41 ff ff ff       	jmp    800f3d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800ffc:	8b 54 24 04          	mov    0x4(%esp),%edx
  801000:	89 f1                	mov    %esi,%ecx
  801002:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801004:	39 c2                	cmp    %eax,%edx
  801006:	73 eb                	jae    800ff3 <__udivdi3+0xf7>
		{
		  q0--;
  801008:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80100b:	31 ff                	xor    %edi,%edi
  80100d:	e9 2b ff ff ff       	jmp    800f3d <__udivdi3+0x41>
  801012:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801014:	31 f6                	xor    %esi,%esi
  801016:	e9 22 ff ff ff       	jmp    800f3d <__udivdi3+0x41>
	...

0080101c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80101c:	55                   	push   %ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	83 ec 20             	sub    $0x20,%esp
  801022:	8b 44 24 30          	mov    0x30(%esp),%eax
  801026:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80102a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80102e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801032:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801036:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80103a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80103c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80103e:	85 ed                	test   %ebp,%ebp
  801040:	75 16                	jne    801058 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801042:	39 f1                	cmp    %esi,%ecx
  801044:	0f 86 a6 00 00 00    	jbe    8010f0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80104a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80104c:	89 d0                	mov    %edx,%eax
  80104e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801050:	83 c4 20             	add    $0x20,%esp
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801058:	39 f5                	cmp    %esi,%ebp
  80105a:	0f 87 ac 00 00 00    	ja     80110c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801060:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801063:	83 f0 1f             	xor    $0x1f,%eax
  801066:	89 44 24 10          	mov    %eax,0x10(%esp)
  80106a:	0f 84 a8 00 00 00    	je     801118 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801070:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801074:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801076:	bf 20 00 00 00       	mov    $0x20,%edi
  80107b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80107f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801083:	89 f9                	mov    %edi,%ecx
  801085:	d3 e8                	shr    %cl,%eax
  801087:	09 e8                	or     %ebp,%eax
  801089:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80108d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801091:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801095:	d3 e0                	shl    %cl,%eax
  801097:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80109b:	89 f2                	mov    %esi,%edx
  80109d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80109f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010a3:	d3 e0                	shl    %cl,%eax
  8010a5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8010a9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010ad:	89 f9                	mov    %edi,%ecx
  8010af:	d3 e8                	shr    %cl,%eax
  8010b1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8010b3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8010b5:	89 f2                	mov    %esi,%edx
  8010b7:	f7 74 24 18          	divl   0x18(%esp)
  8010bb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8010bd:	f7 64 24 0c          	mull   0xc(%esp)
  8010c1:	89 c5                	mov    %eax,%ebp
  8010c3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010c5:	39 d6                	cmp    %edx,%esi
  8010c7:	72 67                	jb     801130 <__umoddi3+0x114>
  8010c9:	74 75                	je     801140 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010cb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010cf:	29 e8                	sub    %ebp,%eax
  8010d1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 f2                	mov    %esi,%edx
  8010db:	89 f9                	mov    %edi,%ecx
  8010dd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8010df:	09 d0                	or     %edx,%eax
  8010e1:	89 f2                	mov    %esi,%edx
  8010e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010e7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010e9:	83 c4 20             	add    $0x20,%esp
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010f0:	85 c9                	test   %ecx,%ecx
  8010f2:	75 0b                	jne    8010ff <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f9:	31 d2                	xor    %edx,%edx
  8010fb:	f7 f1                	div    %ecx
  8010fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010ff:	89 f0                	mov    %esi,%eax
  801101:	31 d2                	xor    %edx,%edx
  801103:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801105:	89 f8                	mov    %edi,%eax
  801107:	e9 3e ff ff ff       	jmp    80104a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80110c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80110e:	83 c4 20             	add    $0x20,%esp
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    
  801115:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801118:	39 f5                	cmp    %esi,%ebp
  80111a:	72 04                	jb     801120 <__umoddi3+0x104>
  80111c:	39 f9                	cmp    %edi,%ecx
  80111e:	77 06                	ja     801126 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801120:	89 f2                	mov    %esi,%edx
  801122:	29 cf                	sub    %ecx,%edi
  801124:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801126:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    
  80112f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801130:	89 d1                	mov    %edx,%ecx
  801132:	89 c5                	mov    %eax,%ebp
  801134:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801138:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80113c:	eb 8d                	jmp    8010cb <__umoddi3+0xaf>
  80113e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801140:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801144:	72 ea                	jb     801130 <__umoddi3+0x114>
  801146:	89 f1                	mov    %esi,%ecx
  801148:	eb 81                	jmp    8010cb <__umoddi3+0xaf>
