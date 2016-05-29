
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 80 15 80 00 	movl   $0x801580,(%esp)
  800042:	e8 65 01 00 00       	call   8001ac <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 f7 0e 00 00       	call   800f43 <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 f8 15 80 00 	movl   $0x8015f8,(%esp)
  800059:	e8 4e 01 00 00       	call   8001ac <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800067:	e8 40 01 00 00       	call   8001ac <cprintf>
	sys_yield();
  80006c:	e8 b9 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  800071:	e8 b4 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  800076:	e8 af 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  80007b:	e8 aa 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  800080:	e8 a5 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  800085:	e8 a0 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  80008a:	e8 9b 0a 00 00       	call   800b2a <sys_yield>
	sys_yield();
  80008f:	e8 96 0a 00 00       	call   800b2a <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 d0 15 80 00 	movl   $0x8015d0,(%esp)
  80009b:	e8 0c 01 00 00       	call   8001ac <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 11 0a 00 00       	call   800ab9 <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
	...

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000be:	e8 48 0a 00 00       	call   800b0b <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	c1 e0 07             	shl    $0x7,%eax
  8000cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d0:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d5:	85 f6                	test   %esi,%esi
  8000d7:	7e 07                	jle    8000e0 <libmain+0x30>
		binaryname = argv[0];
  8000d9:	8b 03                	mov    (%ebx),%eax
  8000db:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e4:	89 34 24             	mov    %esi,(%esp)
  8000e7:	e8 48 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 07 00 00 00       	call   8000f8 <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800105:	e8 af 09 00 00       	call   800ab9 <sys_env_destroy>
}
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 14             	sub    $0x14,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 03                	mov    (%ebx),%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80011f:	40                   	inc    %eax
  800120:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800122:	3d ff 00 00 00       	cmp    $0xff,%eax
  800127:	75 19                	jne    800142 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800129:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800130:	00 
  800131:	8d 43 08             	lea    0x8(%ebx),%eax
  800134:	89 04 24             	mov    %eax,(%esp)
  800137:	e8 40 09 00 00       	call   800a7c <sys_cputs>
		b->idx = 0;
  80013c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800142:	ff 43 04             	incl   0x4(%ebx)
}
  800145:	83 c4 14             	add    $0x14,%esp
  800148:	5b                   	pop    %ebx
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800154:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015b:	00 00 00 
	b.cnt = 0;
  80015e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800165:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800168:	8b 45 0c             	mov    0xc(%ebp),%eax
  80016b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	89 44 24 08          	mov    %eax,0x8(%esp)
  800176:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 0c 01 80 00 	movl   $0x80010c,(%esp)
  800187:	e8 82 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800192:	89 44 24 04          	mov    %eax,0x4(%esp)
  800196:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019c:	89 04 24             	mov    %eax,(%esp)
  80019f:	e8 d8 08 00 00       	call   800a7c <sys_cputs>

	return b.cnt;
}
  8001a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 87 ff ff ff       	call   80014b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
	...

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 3c             	sub    $0x3c,%esp
  8001d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d4:	89 d7                	mov    %edx,%edi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	75 08                	jne    8001f4 <printnum+0x2c>
  8001ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f2:	77 57                	ja     80024b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8001f8:	4b                   	dec    %ebx
  8001f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800200:	89 44 24 08          	mov    %eax,0x8(%esp)
  800204:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800208:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80020c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800213:	00 
  800214:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800217:	89 04 24             	mov    %eax,(%esp)
  80021a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80021d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800221:	e8 fe 10 00 00       	call   801324 <__udivdi3>
  800226:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	89 54 24 04          	mov    %edx,0x4(%esp)
  800235:	89 fa                	mov    %edi,%edx
  800237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023a:	e8 89 ff ff ff       	call   8001c8 <printnum>
  80023f:	eb 0f                	jmp    800250 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	89 34 24             	mov    %esi,(%esp)
  800248:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024b:	4b                   	dec    %ebx
  80024c:	85 db                	test   %ebx,%ebx
  80024e:	7f f1                	jg     800241 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800250:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800254:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800266:	00 
  800267:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80026a:	89 04 24             	mov    %eax,(%esp)
  80026d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800270:	89 44 24 04          	mov    %eax,0x4(%esp)
  800274:	e8 cb 11 00 00       	call   801444 <__umoddi3>
  800279:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027d:	0f be 80 20 16 80 00 	movsbl 0x801620(%eax),%eax
  800284:	89 04 24             	mov    %eax,(%esp)
  800287:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028a:	83 c4 3c             	add    $0x3c,%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    

00800292 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800295:	83 fa 01             	cmp    $0x1,%edx
  800298:	7e 0e                	jle    8002a8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	eb 22                	jmp    8002ca <getuint+0x38>
	else if (lflag)
  8002a8:	85 d2                	test   %edx,%edx
  8002aa:	74 10                	je     8002bc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 02                	mov    (%edx),%eax
  8002b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ba:	eb 0e                	jmp    8002ca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d5:	8b 10                	mov    (%eax),%edx
  8002d7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002da:	73 08                	jae    8002e4 <sprintputch+0x18>
		*b->buf++ = ch;
  8002dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002df:	88 0a                	mov    %cl,(%edx)
  8002e1:	42                   	inc    %edx
  8002e2:	89 10                	mov    %edx,(%eax)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 02 00 00 00       	call   80030e <vprintfmt>
	va_end(ap);
}
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 4c             	sub    $0x4c,%esp
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 75 10             	mov    0x10(%ebp),%esi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 6b 03 00 00    	je     800692 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800327:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	0f b6 06             	movzbl (%esi),%eax
  800334:	46                   	inc    %esi
  800335:	83 f8 25             	cmp    $0x25,%eax
  800338:	75 e5                	jne    80031f <vprintfmt+0x11>
  80033a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80033e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800345:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80034a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
  800356:	eb 26                	jmp    80037e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80035f:	eb 1d                	jmp    80037e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800364:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800368:	eb 14                	jmp    80037e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80036d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800374:	eb 08                	jmp    80037e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800376:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800379:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	0f b6 06             	movzbl (%esi),%eax
  800381:	8d 56 01             	lea    0x1(%esi),%edx
  800384:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800387:	8a 16                	mov    (%esi),%dl
  800389:	83 ea 23             	sub    $0x23,%edx
  80038c:	80 fa 55             	cmp    $0x55,%dl
  80038f:	0f 87 e1 02 00 00    	ja     800676 <vprintfmt+0x368>
  800395:	0f b6 d2             	movzbl %dl,%edx
  800398:	ff 24 95 60 17 80 00 	jmp    *0x801760(,%edx,4)
  80039f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003a2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003aa:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ae:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003b4:	83 fa 09             	cmp    $0x9,%edx
  8003b7:	77 2a                	ja     8003e3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ba:	eb eb                	jmp    8003a7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 50 04             	lea    0x4(%eax),%edx
  8003c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ca:	eb 17                	jmp    8003e3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d0:	78 98                	js     80036a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003d5:	eb a7                	jmp    80037e <vprintfmt+0x70>
  8003d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003da:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003e1:	eb 9b                	jmp    80037e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e7:	79 95                	jns    80037e <vprintfmt+0x70>
  8003e9:	eb 8b                	jmp    800376 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003eb:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ef:	eb 8d                	jmp    80037e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800409:	e9 23 ff ff ff       	jmp    800331 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	85 c0                	test   %eax,%eax
  80041b:	79 02                	jns    80041f <vprintfmt+0x111>
  80041d:	f7 d8                	neg    %eax
  80041f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800421:	83 f8 11             	cmp    $0x11,%eax
  800424:	7f 0b                	jg     800431 <vprintfmt+0x123>
  800426:	8b 04 85 c0 18 80 00 	mov    0x8018c0(,%eax,4),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	75 23                	jne    800454 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800431:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800435:	c7 44 24 08 38 16 80 	movl   $0x801638,0x8(%esp)
  80043c:	00 
  80043d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800441:	8b 45 08             	mov    0x8(%ebp),%eax
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	e8 9a fe ff ff       	call   8002e6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80044f:	e9 dd fe ff ff       	jmp    800331 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800454:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800458:	c7 44 24 08 41 16 80 	movl   $0x801641,0x8(%esp)
  80045f:	00 
  800460:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800464:	8b 55 08             	mov    0x8(%ebp),%edx
  800467:	89 14 24             	mov    %edx,(%esp)
  80046a:	e8 77 fe ff ff       	call   8002e6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800472:	e9 ba fe ff ff       	jmp    800331 <vprintfmt+0x23>
  800477:	89 f9                	mov    %edi,%ecx
  800479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 30                	mov    (%eax),%esi
  80048a:	85 f6                	test   %esi,%esi
  80048c:	75 05                	jne    800493 <vprintfmt+0x185>
				p = "(null)";
  80048e:	be 31 16 80 00       	mov    $0x801631,%esi
			if (width > 0 && padc != '-')
  800493:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800497:	0f 8e 84 00 00 00    	jle    800521 <vprintfmt+0x213>
  80049d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004a1:	74 7e                	je     800521 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a7:	89 34 24             	mov    %esi,(%esp)
  8004aa:	e8 8b 02 00 00       	call   80073a <strnlen>
  8004af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b2:	29 c2                	sub    %eax,%edx
  8004b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004b7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004bb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004be:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004c1:	89 de                	mov    %ebx,%esi
  8004c3:	89 d3                	mov    %edx,%ebx
  8004c5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	eb 0b                	jmp    8004d4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cd:	89 3c 24             	mov    %edi,(%esp)
  8004d0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	4b                   	dec    %ebx
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	7f f1                	jg     8004c9 <vprintfmt+0x1bb>
  8004d8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004db:	89 f3                	mov    %esi,%ebx
  8004dd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	79 05                	jns    8004ec <vprintfmt+0x1de>
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ef:	29 c2                	sub    %eax,%edx
  8004f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f4:	eb 2b                	jmp    800521 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004fa:	74 18                	je     800514 <vprintfmt+0x206>
  8004fc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ff:	83 fa 5e             	cmp    $0x5e,%edx
  800502:	76 10                	jbe    800514 <vprintfmt+0x206>
					putch('?', putdat);
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050f:	ff 55 08             	call   *0x8(%ebp)
  800512:	eb 0a                	jmp    80051e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800514:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800518:	89 04 24             	mov    %eax,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051e:	ff 4d e4             	decl   -0x1c(%ebp)
  800521:	0f be 06             	movsbl (%esi),%eax
  800524:	46                   	inc    %esi
  800525:	85 c0                	test   %eax,%eax
  800527:	74 21                	je     80054a <vprintfmt+0x23c>
  800529:	85 ff                	test   %edi,%edi
  80052b:	78 c9                	js     8004f6 <vprintfmt+0x1e8>
  80052d:	4f                   	dec    %edi
  80052e:	79 c6                	jns    8004f6 <vprintfmt+0x1e8>
  800530:	8b 7d 08             	mov    0x8(%ebp),%edi
  800533:	89 de                	mov    %ebx,%esi
  800535:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800538:	eb 18                	jmp    800552 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800545:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	4b                   	dec    %ebx
  800548:	eb 08                	jmp    800552 <vprintfmt+0x244>
  80054a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80054d:	89 de                	mov    %ebx,%esi
  80054f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800552:	85 db                	test   %ebx,%ebx
  800554:	7f e4                	jg     80053a <vprintfmt+0x22c>
  800556:	89 7d 08             	mov    %edi,0x8(%ebp)
  800559:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80055e:	e9 ce fd ff ff       	jmp    800331 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800563:	83 f9 01             	cmp    $0x1,%ecx
  800566:	7e 10                	jle    800578 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 08             	lea    0x8(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 30                	mov    (%eax),%esi
  800573:	8b 78 04             	mov    0x4(%eax),%edi
  800576:	eb 26                	jmp    80059e <vprintfmt+0x290>
	else if (lflag)
  800578:	85 c9                	test   %ecx,%ecx
  80057a:	74 12                	je     80058e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 04             	lea    0x4(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	89 f7                	mov    %esi,%edi
  800589:	c1 ff 1f             	sar    $0x1f,%edi
  80058c:	eb 10                	jmp    80059e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 30                	mov    (%eax),%esi
  800599:	89 f7                	mov    %esi,%edi
  80059b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059e:	85 ff                	test   %edi,%edi
  8005a0:	78 0a                	js     8005ac <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a7:	e9 8c 00 00 00       	jmp    800638 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ba:	f7 de                	neg    %esi
  8005bc:	83 d7 00             	adc    $0x0,%edi
  8005bf:	f7 df                	neg    %edi
			}
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c6:	eb 70                	jmp    800638 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c8:	89 ca                	mov    %ecx,%edx
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 c0 fc ff ff       	call   800292 <getuint>
  8005d2:	89 c6                	mov    %eax,%esi
  8005d4:	89 d7                	mov    %edx,%edi
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005db:	eb 5b                	jmp    800638 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8005dd:	89 ca                	mov    %ecx,%edx
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 ab fc ff ff       	call   800292 <getuint>
  8005e7:	89 c6                	mov    %eax,%esi
  8005e9:	89 d7                	mov    %edx,%edi
			base = 8;
  8005eb:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005f0:	eb 46                	jmp    800638 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800617:	8b 30                	mov    (%eax),%esi
  800619:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80061e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800623:	eb 13                	jmp    800638 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800625:	89 ca                	mov    %ecx,%edx
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 63 fc ff ff       	call   800292 <getuint>
  80062f:	89 c6                	mov    %eax,%esi
  800631:	89 d7                	mov    %edx,%edi
			base = 16;
  800633:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800638:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80063c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800640:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800643:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800647:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064b:	89 34 24             	mov    %esi,(%esp)
  80064e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800652:	89 da                	mov    %ebx,%edx
  800654:	8b 45 08             	mov    0x8(%ebp),%eax
  800657:	e8 6c fb ff ff       	call   8001c8 <printnum>
			break;
  80065c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065f:	e9 cd fc ff ff       	jmp    800331 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	89 04 24             	mov    %eax,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800671:	e9 bb fc ff ff       	jmp    800331 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800676:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800681:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800684:	eb 01                	jmp    800687 <vprintfmt+0x379>
  800686:	4e                   	dec    %esi
  800687:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80068b:	75 f9                	jne    800686 <vprintfmt+0x378>
  80068d:	e9 9f fc ff ff       	jmp    800331 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800692:	83 c4 4c             	add    $0x4c,%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 28             	sub    $0x28,%esp
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	74 30                	je     8006eb <vsnprintf+0x51>
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	7e 33                	jle    8006f2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	c7 04 24 cc 02 80 00 	movl   $0x8002cc,(%esp)
  8006db:	e8 2e fc ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e9:	eb 0c                	jmp    8006f7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f0:	eb 05                	jmp    8006f7 <vsnprintf+0x5d>
  8006f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    

008006f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800702:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800706:	8b 45 10             	mov    0x10(%ebp),%eax
  800709:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	89 04 24             	mov    %eax,(%esp)
  80071a:	e8 7b ff ff ff       	call   80069a <vsnprintf>
	va_end(ap);

	return rc;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    
  800721:	00 00                	add    %al,(%eax)
	...

00800724 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	eb 01                	jmp    800732 <strlen+0xe>
		n++;
  800731:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800736:	75 f9                	jne    800731 <strlen+0xd>
		n++;
	return n;
}
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800743:	b8 00 00 00 00       	mov    $0x0,%eax
  800748:	eb 01                	jmp    80074b <strnlen+0x11>
		n++;
  80074a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	39 d0                	cmp    %edx,%eax
  80074d:	74 06                	je     800755 <strnlen+0x1b>
  80074f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800753:	75 f5                	jne    80074a <strnlen+0x10>
		n++;
	return n;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800761:	ba 00 00 00 00       	mov    $0x0,%edx
  800766:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800769:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80076c:	42                   	inc    %edx
  80076d:	84 c9                	test   %cl,%cl
  80076f:	75 f5                	jne    800766 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800771:	5b                   	pop    %ebx
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077e:	89 1c 24             	mov    %ebx,(%esp)
  800781:	e8 9e ff ff ff       	call   800724 <strlen>
	strcpy(dst + len, src);
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
  800789:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078d:	01 d8                	add    %ebx,%eax
  80078f:	89 04 24             	mov    %eax,(%esp)
  800792:	e8 c0 ff ff ff       	call   800757 <strcpy>
	return dst;
}
  800797:	89 d8                	mov    %ebx,%eax
  800799:	83 c4 08             	add    $0x8,%esp
  80079c:	5b                   	pop    %ebx
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b2:	eb 0c                	jmp    8007c0 <strncpy+0x21>
		*dst++ = *src;
  8007b4:	8a 1a                	mov    (%edx),%bl
  8007b6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007bc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	41                   	inc    %ecx
  8007c0:	39 f1                	cmp    %esi,%ecx
  8007c2:	75 f0                	jne    8007b4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	75 0a                	jne    8007e4 <strlcpy+0x1c>
  8007da:	89 f0                	mov    %esi,%eax
  8007dc:	eb 1a                	jmp    8007f8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007de:	88 18                	mov    %bl,(%eax)
  8007e0:	40                   	inc    %eax
  8007e1:	41                   	inc    %ecx
  8007e2:	eb 02                	jmp    8007e6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007e6:	4a                   	dec    %edx
  8007e7:	74 0a                	je     8007f3 <strlcpy+0x2b>
  8007e9:	8a 19                	mov    (%ecx),%bl
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	75 ef                	jne    8007de <strlcpy+0x16>
  8007ef:	89 c2                	mov    %eax,%edx
  8007f1:	eb 02                	jmp    8007f5 <strlcpy+0x2d>
  8007f3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007f5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007f8:	29 f0                	sub    %esi,%eax
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800807:	eb 02                	jmp    80080b <strcmp+0xd>
		p++, q++;
  800809:	41                   	inc    %ecx
  80080a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080b:	8a 01                	mov    (%ecx),%al
  80080d:	84 c0                	test   %al,%al
  80080f:	74 04                	je     800815 <strcmp+0x17>
  800811:	3a 02                	cmp    (%edx),%al
  800813:	74 f4                	je     800809 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800815:	0f b6 c0             	movzbl %al,%eax
  800818:	0f b6 12             	movzbl (%edx),%edx
  80081b:	29 d0                	sub    %edx,%eax
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80082c:	eb 03                	jmp    800831 <strncmp+0x12>
		n--, p++, q++;
  80082e:	4a                   	dec    %edx
  80082f:	40                   	inc    %eax
  800830:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800831:	85 d2                	test   %edx,%edx
  800833:	74 14                	je     800849 <strncmp+0x2a>
  800835:	8a 18                	mov    (%eax),%bl
  800837:	84 db                	test   %bl,%bl
  800839:	74 04                	je     80083f <strncmp+0x20>
  80083b:	3a 19                	cmp    (%ecx),%bl
  80083d:	74 ef                	je     80082e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 00             	movzbl (%eax),%eax
  800842:	0f b6 11             	movzbl (%ecx),%edx
  800845:	29 d0                	sub    %edx,%eax
  800847:	eb 05                	jmp    80084e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800849:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80085a:	eb 05                	jmp    800861 <strchr+0x10>
		if (*s == c)
  80085c:	38 ca                	cmp    %cl,%dl
  80085e:	74 0c                	je     80086c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800860:	40                   	inc    %eax
  800861:	8a 10                	mov    (%eax),%dl
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f5                	jne    80085c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800877:	eb 05                	jmp    80087e <strfind+0x10>
		if (*s == c)
  800879:	38 ca                	cmp    %cl,%dl
  80087b:	74 07                	je     800884 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80087d:	40                   	inc    %eax
  80087e:	8a 10                	mov    (%eax),%dl
  800880:	84 d2                	test   %dl,%dl
  800882:	75 f5                	jne    800879 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	57                   	push   %edi
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800895:	85 c9                	test   %ecx,%ecx
  800897:	74 30                	je     8008c9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800899:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80089f:	75 25                	jne    8008c6 <memset+0x40>
  8008a1:	f6 c1 03             	test   $0x3,%cl
  8008a4:	75 20                	jne    8008c6 <memset+0x40>
		c &= 0xFF;
  8008a6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a9:	89 d3                	mov    %edx,%ebx
  8008ab:	c1 e3 08             	shl    $0x8,%ebx
  8008ae:	89 d6                	mov    %edx,%esi
  8008b0:	c1 e6 18             	shl    $0x18,%esi
  8008b3:	89 d0                	mov    %edx,%eax
  8008b5:	c1 e0 10             	shl    $0x10,%eax
  8008b8:	09 f0                	or     %esi,%eax
  8008ba:	09 d0                	or     %edx,%eax
  8008bc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008be:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008c1:	fc                   	cld    
  8008c2:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c4:	eb 03                	jmp    8008c9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c6:	fc                   	cld    
  8008c7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c9:	89 f8                	mov    %edi,%eax
  8008cb:	5b                   	pop    %ebx
  8008cc:	5e                   	pop    %esi
  8008cd:	5f                   	pop    %edi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	57                   	push   %edi
  8008d4:	56                   	push   %esi
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008de:	39 c6                	cmp    %eax,%esi
  8008e0:	73 34                	jae    800916 <memmove+0x46>
  8008e2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e5:	39 d0                	cmp    %edx,%eax
  8008e7:	73 2d                	jae    800916 <memmove+0x46>
		s += n;
		d += n;
  8008e9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ec:	f6 c2 03             	test   $0x3,%dl
  8008ef:	75 1b                	jne    80090c <memmove+0x3c>
  8008f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f7:	75 13                	jne    80090c <memmove+0x3c>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 0e                	jne    80090c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fe:	83 ef 04             	sub    $0x4,%edi
  800901:	8d 72 fc             	lea    -0x4(%edx),%esi
  800904:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800907:	fd                   	std    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 07                	jmp    800913 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090c:	4f                   	dec    %edi
  80090d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800910:	fd                   	std    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800913:	fc                   	cld    
  800914:	eb 20                	jmp    800936 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800916:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091c:	75 13                	jne    800931 <memmove+0x61>
  80091e:	a8 03                	test   $0x3,%al
  800920:	75 0f                	jne    800931 <memmove+0x61>
  800922:	f6 c1 03             	test   $0x3,%cl
  800925:	75 0a                	jne    800931 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800927:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092f:	eb 05                	jmp    800936 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800931:	89 c7                	mov    %eax,%edi
  800933:	fc                   	cld    
  800934:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800936:	5e                   	pop    %esi
  800937:	5f                   	pop    %edi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800940:	8b 45 10             	mov    0x10(%ebp),%eax
  800943:	89 44 24 08          	mov    %eax,0x8(%esp)
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	89 04 24             	mov    %eax,(%esp)
  800954:	e8 77 ff ff ff       	call   8008d0 <memmove>
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	8b 7d 08             	mov    0x8(%ebp),%edi
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
  800967:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	eb 16                	jmp    800987 <memcmp+0x2c>
		if (*s1 != *s2)
  800971:	8a 04 17             	mov    (%edi,%edx,1),%al
  800974:	42                   	inc    %edx
  800975:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800979:	38 c8                	cmp    %cl,%al
  80097b:	74 0a                	je     800987 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  80097d:	0f b6 c0             	movzbl %al,%eax
  800980:	0f b6 c9             	movzbl %cl,%ecx
  800983:	29 c8                	sub    %ecx,%eax
  800985:	eb 09                	jmp    800990 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800987:	39 da                	cmp    %ebx,%edx
  800989:	75 e6                	jne    800971 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80099e:	89 c2                	mov    %eax,%edx
  8009a0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009a3:	eb 05                	jmp    8009aa <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a5:	38 08                	cmp    %cl,(%eax)
  8009a7:	74 05                	je     8009ae <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a9:	40                   	inc    %eax
  8009aa:	39 d0                	cmp    %edx,%eax
  8009ac:	72 f7                	jb     8009a5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	57                   	push   %edi
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bc:	eb 01                	jmp    8009bf <strtol+0xf>
		s++;
  8009be:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	8a 02                	mov    (%edx),%al
  8009c1:	3c 20                	cmp    $0x20,%al
  8009c3:	74 f9                	je     8009be <strtol+0xe>
  8009c5:	3c 09                	cmp    $0x9,%al
  8009c7:	74 f5                	je     8009be <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c9:	3c 2b                	cmp    $0x2b,%al
  8009cb:	75 08                	jne    8009d5 <strtol+0x25>
		s++;
  8009cd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ce:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d3:	eb 13                	jmp    8009e8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d5:	3c 2d                	cmp    $0x2d,%al
  8009d7:	75 0a                	jne    8009e3 <strtol+0x33>
		s++, neg = 1;
  8009d9:	8d 52 01             	lea    0x1(%edx),%edx
  8009dc:	bf 01 00 00 00       	mov    $0x1,%edi
  8009e1:	eb 05                	jmp    8009e8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e8:	85 db                	test   %ebx,%ebx
  8009ea:	74 05                	je     8009f1 <strtol+0x41>
  8009ec:	83 fb 10             	cmp    $0x10,%ebx
  8009ef:	75 28                	jne    800a19 <strtol+0x69>
  8009f1:	8a 02                	mov    (%edx),%al
  8009f3:	3c 30                	cmp    $0x30,%al
  8009f5:	75 10                	jne    800a07 <strtol+0x57>
  8009f7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009fb:	75 0a                	jne    800a07 <strtol+0x57>
		s += 2, base = 16;
  8009fd:	83 c2 02             	add    $0x2,%edx
  800a00:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a05:	eb 12                	jmp    800a19 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a07:	85 db                	test   %ebx,%ebx
  800a09:	75 0e                	jne    800a19 <strtol+0x69>
  800a0b:	3c 30                	cmp    $0x30,%al
  800a0d:	75 05                	jne    800a14 <strtol+0x64>
		s++, base = 8;
  800a0f:	42                   	inc    %edx
  800a10:	b3 08                	mov    $0x8,%bl
  800a12:	eb 05                	jmp    800a19 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a14:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a20:	8a 0a                	mov    (%edx),%cl
  800a22:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a25:	80 fb 09             	cmp    $0x9,%bl
  800a28:	77 08                	ja     800a32 <strtol+0x82>
			dig = *s - '0';
  800a2a:	0f be c9             	movsbl %cl,%ecx
  800a2d:	83 e9 30             	sub    $0x30,%ecx
  800a30:	eb 1e                	jmp    800a50 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a32:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a35:	80 fb 19             	cmp    $0x19,%bl
  800a38:	77 08                	ja     800a42 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a3a:	0f be c9             	movsbl %cl,%ecx
  800a3d:	83 e9 57             	sub    $0x57,%ecx
  800a40:	eb 0e                	jmp    800a50 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a42:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a45:	80 fb 19             	cmp    $0x19,%bl
  800a48:	77 12                	ja     800a5c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a4a:	0f be c9             	movsbl %cl,%ecx
  800a4d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a50:	39 f1                	cmp    %esi,%ecx
  800a52:	7d 0c                	jge    800a60 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a54:	42                   	inc    %edx
  800a55:	0f af c6             	imul   %esi,%eax
  800a58:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a5a:	eb c4                	jmp    800a20 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a5c:	89 c1                	mov    %eax,%ecx
  800a5e:	eb 02                	jmp    800a62 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a60:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a66:	74 05                	je     800a6d <strtol+0xbd>
		*endptr = (char *) s;
  800a68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a6b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a6d:	85 ff                	test   %edi,%edi
  800a6f:	74 04                	je     800a75 <strtol+0xc5>
  800a71:	89 c8                	mov    %ecx,%eax
  800a73:	f7 d8                	neg    %eax
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    
	...

00800a7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	89 c7                	mov    %eax,%edi
  800a91:	89 c6                	mov    %eax,%esi
  800a93:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aaa:	89 d1                	mov    %edx,%ecx
  800aac:	89 d3                	mov    %edx,%ebx
  800aae:	89 d7                	mov    %edx,%edi
  800ab0:	89 d6                	mov    %edx,%esi
  800ab2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
  800abf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac7:	b8 03 00 00 00       	mov    $0x3,%eax
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 cb                	mov    %ecx,%ebx
  800ad1:	89 cf                	mov    %ecx,%edi
  800ad3:	89 ce                	mov    %ecx,%esi
  800ad5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	7e 28                	jle    800b03 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800adf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ae6:	00 
  800ae7:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800aee:	00 
  800aef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800af6:	00 
  800af7:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800afe:	e8 31 07 00 00       	call   801234 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b03:	83 c4 2c             	add    $0x2c,%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1b:	89 d1                	mov    %edx,%ecx
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	89 d7                	mov    %edx,%edi
  800b21:	89 d6                	mov    %edx,%esi
  800b23:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_yield>:

void
sys_yield(void)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 d3                	mov    %edx,%ebx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b52:	be 00 00 00 00       	mov    $0x0,%esi
  800b57:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	89 f7                	mov    %esi,%edi
  800b67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	7e 28                	jle    800b95 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b71:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b78:	00 
  800b79:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800b80:	00 
  800b81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b88:	00 
  800b89:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800b90:	e8 9f 06 00 00       	call   801234 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b95:	83 c4 2c             	add    $0x2c,%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bab:	8b 75 18             	mov    0x18(%ebp),%esi
  800bae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 28                	jle    800be8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bcb:	00 
  800bcc:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800bd3:	00 
  800bd4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bdb:	00 
  800bdc:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800be3:	e8 4c 06 00 00       	call   801234 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be8:	83 c4 2c             	add    $0x2c,%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 df                	mov    %ebx,%edi
  800c0b:	89 de                	mov    %ebx,%esi
  800c0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	7e 28                	jle    800c3b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c17:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c1e:	00 
  800c1f:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800c26:	00 
  800c27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2e:	00 
  800c2f:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800c36:	e8 f9 05 00 00       	call   801234 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3b:	83 c4 2c             	add    $0x2c,%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 08 00 00 00       	mov    $0x8,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 28                	jle    800c8e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c71:	00 
  800c72:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800c79:	00 
  800c7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c81:	00 
  800c82:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800c89:	e8 a6 05 00 00       	call   801234 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c8e:	83 c4 2c             	add    $0x2c,%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 28                	jle    800ce1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cc4:	00 
  800cc5:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800ccc:	00 
  800ccd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd4:	00 
  800cd5:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800cdc:	e8 53 05 00 00       	call   801234 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ce1:	83 c4 2c             	add    $0x2c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 df                	mov    %ebx,%edi
  800d04:	89 de                	mov    %ebx,%esi
  800d06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	7e 28                	jle    800d34 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d10:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d17:	00 
  800d18:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800d1f:	00 
  800d20:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d27:	00 
  800d28:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800d2f:	e8 00 05 00 00       	call   801234 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d34:	83 c4 2c             	add    $0x2c,%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
  800d79:	89 ce                	mov    %ecx,%esi
  800d7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 28                	jle    800da9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d85:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 08 27 19 80 	movl   $0x801927,0x8(%esp)
  800d94:	00 
  800d95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d9c:	00 
  800d9d:	c7 04 24 44 19 80 00 	movl   $0x801944,(%esp)
  800da4:	e8 8b 04 00 00       	call   801234 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da9:	83 c4 2c             	add    $0x2c,%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 d3                	mov    %edx,%ebx
  800dc5:	89 d7                	mov    %edx,%edi
  800dc7:	89 d6                	mov    %edx,%esi
  800dc9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	b8 10 00 00 00       	mov    $0x10,%eax
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfc:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	89 df                	mov    %ebx,%edi
  800e09:	89 de                	mov    %ebx,%esi
  800e0b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1d:	b8 11 00 00 00       	mov    $0x11,%eax
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 cb                	mov    %ecx,%ebx
  800e27:	89 cf                	mov    %ecx,%edi
  800e29:	89 ce                	mov    %ecx,%esi
  800e2b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
	...

00800e34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	53                   	push   %ebx
  800e38:	83 ec 24             	sub    $0x24,%esp
  800e3b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e3e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800e40:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e44:	75 20                	jne    800e66 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e46:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e4a:	c7 44 24 08 54 19 80 	movl   $0x801954,0x8(%esp)
  800e51:	00 
  800e52:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e59:	00 
  800e5a:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800e61:	e8 ce 03 00 00       	call   801234 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e66:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e71:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e78:	f6 c4 08             	test   $0x8,%ah
  800e7b:	75 1c                	jne    800e99 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e7d:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  800e84:	00 
  800e85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8c:	00 
  800e8d:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800e94:	e8 9b 03 00 00       	call   801234 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e99:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb0:	e8 94 fc ff ff       	call   800b49 <sys_page_alloc>
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	79 20                	jns    800ed9 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800ed4:	e8 5b 03 00 00       	call   801234 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800ed9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ee0:	00 
  800ee1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800eec:	e8 df f9 ff ff       	call   8008d0 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800ef1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ef8:	00 
  800ef9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800efd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f04:	00 
  800f05:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f0c:	00 
  800f0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f14:	e8 84 fc ff ff       	call   800b9d <sys_page_map>
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	79 20                	jns    800f3d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800f1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f21:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800f38:	e8 f7 02 00 00       	call   801234 <_panic>

}
  800f3d:	83 c4 24             	add    $0x24,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800f4c:	c7 04 24 34 0e 80 00 	movl   $0x800e34,(%esp)
  800f53:	e8 34 03 00 00       	call   80128c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f58:	ba 07 00 00 00       	mov    $0x7,%edx
  800f5d:	89 d0                	mov    %edx,%eax
  800f5f:	cd 30                	int    $0x30
  800f61:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f64:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	79 20                	jns    800f8b <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6f:	c7 44 24 08 05 1a 80 	movl   $0x801a05,0x8(%esp)
  800f76:	00 
  800f77:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  800f7e:	00 
  800f7f:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800f86:	e8 a9 02 00 00       	call   801234 <_panic>
	if (child_envid == 0) { // child
  800f8b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f8f:	75 1c                	jne    800fad <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800f91:	e8 75 fb ff ff       	call   800b0b <sys_getenvid>
  800f96:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9b:	c1 e0 07             	shl    $0x7,%eax
  800f9e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa3:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fa8:	e9 58 02 00 00       	jmp    801205 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800fad:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb2:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fb7:	89 f0                	mov    %esi,%eax
  800fb9:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fbc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc3:	a8 01                	test   $0x1,%al
  800fc5:	0f 84 7a 01 00 00    	je     801145 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800fcb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	0f 84 6b 01 00 00    	je     801145 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800fda:	a1 04 20 80 00       	mov    0x802004,%eax
  800fdf:	8b 40 48             	mov    0x48(%eax),%eax
  800fe2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  800fe5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fec:	f6 c4 04             	test   $0x4,%ah
  800fef:	74 52                	je     801043 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800ff1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff8:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801001:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801005:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801008:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801010:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801013:	89 04 24             	mov    %eax,(%esp)
  801016:	e8 82 fb ff ff       	call   800b9d <sys_page_map>
  80101b:	85 c0                	test   %eax,%eax
  80101d:	0f 89 22 01 00 00    	jns    801145 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801023:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801027:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  80102e:	00 
  80102f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801036:	00 
  801037:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  80103e:	e8 f1 01 00 00       	call   801234 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801043:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104a:	f6 c4 08             	test   $0x8,%ah
  80104d:	75 0f                	jne    80105e <fork+0x11b>
  80104f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801056:	a8 02                	test   $0x2,%al
  801058:	0f 84 99 00 00 00    	je     8010f7 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80105e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801065:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801068:	83 f8 01             	cmp    $0x1,%eax
  80106b:	19 db                	sbb    %ebx,%ebx
  80106d:	83 e3 fc             	and    $0xfffffffc,%ebx
  801070:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801076:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80107a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801081:	89 44 24 08          	mov    %eax,0x8(%esp)
  801085:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801089:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108c:	89 04 24             	mov    %eax,(%esp)
  80108f:	e8 09 fb ff ff       	call   800b9d <sys_page_map>
  801094:	85 c0                	test   %eax,%eax
  801096:	79 20                	jns    8010b8 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109c:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  8010a3:	00 
  8010a4:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010ab:	00 
  8010ac:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8010b3:	e8 7c 01 00 00       	call   801234 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010b8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010bc:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010cb:	89 04 24             	mov    %eax,(%esp)
  8010ce:	e8 ca fa ff ff       	call   800b9d <sys_page_map>
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	79 6e                	jns    801145 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8010d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010db:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8010f2:	e8 3d 01 00 00       	call   801234 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010f7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010fe:	25 07 0e 00 00       	and    $0xe07,%eax
  801103:	89 44 24 10          	mov    %eax,0x10(%esp)
  801107:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80110b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80110e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801112:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801119:	89 04 24             	mov    %eax,(%esp)
  80111c:	e8 7c fa ff ff       	call   800b9d <sys_page_map>
  801121:	85 c0                	test   %eax,%eax
  801123:	79 20                	jns    801145 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801125:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801129:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  801130:	00 
  801131:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801138:	00 
  801139:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801140:	e8 ef 00 00 00       	call   801234 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801145:	46                   	inc    %esi
  801146:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80114c:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801152:	0f 85 5f fe ff ff    	jne    800fb7 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801158:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80115f:	00 
  801160:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801167:	ee 
  801168:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80116b:	89 04 24             	mov    %eax,(%esp)
  80116e:	e8 d6 f9 ff ff       	call   800b49 <sys_page_alloc>
  801173:	85 c0                	test   %eax,%eax
  801175:	79 20                	jns    801197 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801177:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117b:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  801182:	00 
  801183:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80118a:	00 
  80118b:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801192:	e8 9d 00 00 00       	call   801234 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801197:	c7 44 24 04 00 13 80 	movl   $0x801300,0x4(%esp)
  80119e:	00 
  80119f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011a2:	89 04 24             	mov    %eax,(%esp)
  8011a5:	e8 3f fb ff ff       	call   800ce9 <sys_env_set_pgfault_upcall>
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 20                	jns    8011ce <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8011ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b2:	c7 44 24 08 b4 19 80 	movl   $0x8019b4,0x8(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8011c1:	00 
  8011c2:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8011c9:	e8 66 00 00 00       	call   801234 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8011ce:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011d5:	00 
  8011d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d9:	89 04 24             	mov    %eax,(%esp)
  8011dc:	e8 62 fa ff ff       	call   800c43 <sys_env_set_status>
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	79 20                	jns    801205 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  8011e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e9:	c7 44 24 08 16 1a 80 	movl   $0x801a16,0x8(%esp)
  8011f0:	00 
  8011f1:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8011f8:	00 
  8011f9:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801200:	e8 2f 00 00 00       	call   801234 <_panic>

	return child_envid;
}
  801205:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801208:	83 c4 3c             	add    $0x3c,%esp
  80120b:	5b                   	pop    %ebx
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <sfork>:

// Challenge!
int
sfork(void)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801216:	c7 44 24 08 2e 1a 80 	movl   $0x801a2e,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  80122d:	e8 02 00 00 00       	call   801234 <_panic>
	...

00801234 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80123c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80123f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801245:	e8 c1 f8 ff ff       	call   800b0b <sys_getenvid>
  80124a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801251:	8b 55 08             	mov    0x8(%ebp),%edx
  801254:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801258:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80125c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801260:	c7 04 24 44 1a 80 00 	movl   $0x801a44,(%esp)
  801267:	e8 40 ef ff ff       	call   8001ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80126c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801270:	8b 45 10             	mov    0x10(%ebp),%eax
  801273:	89 04 24             	mov    %eax,(%esp)
  801276:	e8 d0 ee ff ff       	call   80014b <vcprintf>
	cprintf("\n");
  80127b:	c7 04 24 14 16 80 00 	movl   $0x801614,(%esp)
  801282:	e8 25 ef ff ff       	call   8001ac <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801287:	cc                   	int3   
  801288:	eb fd                	jmp    801287 <_panic+0x53>
	...

0080128c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801292:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801299:	75 58                	jne    8012f3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80129b:	a1 04 20 80 00       	mov    0x802004,%eax
  8012a0:	8b 40 48             	mov    0x48(%eax),%eax
  8012a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012aa:	00 
  8012ab:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012b2:	ee 
  8012b3:	89 04 24             	mov    %eax,(%esp)
  8012b6:	e8 8e f8 ff ff       	call   800b49 <sys_page_alloc>
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	74 1c                	je     8012db <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8012bf:	c7 44 24 08 68 1a 80 	movl   $0x801a68,0x8(%esp)
  8012c6:	00 
  8012c7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ce:	00 
  8012cf:	c7 04 24 7d 1a 80 00 	movl   $0x801a7d,(%esp)
  8012d6:	e8 59 ff ff ff       	call   801234 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8012db:	a1 04 20 80 00       	mov    0x802004,%eax
  8012e0:	8b 40 48             	mov    0x48(%eax),%eax
  8012e3:	c7 44 24 04 00 13 80 	movl   $0x801300,0x4(%esp)
  8012ea:	00 
  8012eb:	89 04 24             	mov    %eax,(%esp)
  8012ee:	e8 f6 f9 ff ff       	call   800ce9 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012fb:	c9                   	leave  
  8012fc:	c3                   	ret    
  8012fd:	00 00                	add    %al,(%eax)
	...

00801300 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801300:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801301:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801306:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801308:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80130b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80130f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801311:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801315:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  801316:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  801319:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80131b:	58                   	pop    %eax
	popl %eax
  80131c:	58                   	pop    %eax

	// Pop all registers back
	popal
  80131d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80131e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801321:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801322:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801323:	c3                   	ret    

00801324 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801324:	55                   	push   %ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	83 ec 10             	sub    $0x10,%esp
  80132a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80132e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801332:	89 74 24 04          	mov    %esi,0x4(%esp)
  801336:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80133a:	89 cd                	mov    %ecx,%ebp
  80133c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801340:	85 c0                	test   %eax,%eax
  801342:	75 2c                	jne    801370 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801344:	39 f9                	cmp    %edi,%ecx
  801346:	77 68                	ja     8013b0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801348:	85 c9                	test   %ecx,%ecx
  80134a:	75 0b                	jne    801357 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80134c:	b8 01 00 00 00       	mov    $0x1,%eax
  801351:	31 d2                	xor    %edx,%edx
  801353:	f7 f1                	div    %ecx
  801355:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801357:	31 d2                	xor    %edx,%edx
  801359:	89 f8                	mov    %edi,%eax
  80135b:	f7 f1                	div    %ecx
  80135d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80135f:	89 f0                	mov    %esi,%eax
  801361:	f7 f1                	div    %ecx
  801363:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801365:	89 f0                	mov    %esi,%eax
  801367:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801370:	39 f8                	cmp    %edi,%eax
  801372:	77 2c                	ja     8013a0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801374:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801377:	83 f6 1f             	xor    $0x1f,%esi
  80137a:	75 4c                	jne    8013c8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80137c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80137e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801383:	72 0a                	jb     80138f <__udivdi3+0x6b>
  801385:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801389:	0f 87 ad 00 00 00    	ja     80143c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80138f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801394:	89 f0                	mov    %esi,%eax
  801396:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	5e                   	pop    %esi
  80139c:	5f                   	pop    %edi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    
  80139f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8013a0:	31 ff                	xor    %edi,%edi
  8013a2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013a4:	89 f0                	mov    %esi,%eax
  8013a6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    
  8013af:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8013b0:	89 fa                	mov    %edi,%edx
  8013b2:	89 f0                	mov    %esi,%eax
  8013b4:	f7 f1                	div    %ecx
  8013b6:	89 c6                	mov    %eax,%esi
  8013b8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8013ba:	89 f0                	mov    %esi,%eax
  8013bc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    
  8013c5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8013c8:	89 f1                	mov    %esi,%ecx
  8013ca:	d3 e0                	shl    %cl,%eax
  8013cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8013d0:	b8 20 00 00 00       	mov    $0x20,%eax
  8013d5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8013d7:	89 ea                	mov    %ebp,%edx
  8013d9:	88 c1                	mov    %al,%cl
  8013db:	d3 ea                	shr    %cl,%edx
  8013dd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8013e1:	09 ca                	or     %ecx,%edx
  8013e3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8013e7:	89 f1                	mov    %esi,%ecx
  8013e9:	d3 e5                	shl    %cl,%ebp
  8013eb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8013ef:	89 fd                	mov    %edi,%ebp
  8013f1:	88 c1                	mov    %al,%cl
  8013f3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8013f5:	89 fa                	mov    %edi,%edx
  8013f7:	89 f1                	mov    %esi,%ecx
  8013f9:	d3 e2                	shl    %cl,%edx
  8013fb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ff:	88 c1                	mov    %al,%cl
  801401:	d3 ef                	shr    %cl,%edi
  801403:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801405:	89 f8                	mov    %edi,%eax
  801407:	89 ea                	mov    %ebp,%edx
  801409:	f7 74 24 08          	divl   0x8(%esp)
  80140d:	89 d1                	mov    %edx,%ecx
  80140f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801411:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801415:	39 d1                	cmp    %edx,%ecx
  801417:	72 17                	jb     801430 <__udivdi3+0x10c>
  801419:	74 09                	je     801424 <__udivdi3+0x100>
  80141b:	89 fe                	mov    %edi,%esi
  80141d:	31 ff                	xor    %edi,%edi
  80141f:	e9 41 ff ff ff       	jmp    801365 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801424:	8b 54 24 04          	mov    0x4(%esp),%edx
  801428:	89 f1                	mov    %esi,%ecx
  80142a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80142c:	39 c2                	cmp    %eax,%edx
  80142e:	73 eb                	jae    80141b <__udivdi3+0xf7>
		{
		  q0--;
  801430:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801433:	31 ff                	xor    %edi,%edi
  801435:	e9 2b ff ff ff       	jmp    801365 <__udivdi3+0x41>
  80143a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80143c:	31 f6                	xor    %esi,%esi
  80143e:	e9 22 ff ff ff       	jmp    801365 <__udivdi3+0x41>
	...

00801444 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801444:	55                   	push   %ebp
  801445:	57                   	push   %edi
  801446:	56                   	push   %esi
  801447:	83 ec 20             	sub    $0x20,%esp
  80144a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80144e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801452:	89 44 24 14          	mov    %eax,0x14(%esp)
  801456:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80145a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80145e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801462:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801464:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801466:	85 ed                	test   %ebp,%ebp
  801468:	75 16                	jne    801480 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80146a:	39 f1                	cmp    %esi,%ecx
  80146c:	0f 86 a6 00 00 00    	jbe    801518 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801472:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801474:	89 d0                	mov    %edx,%eax
  801476:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801478:	83 c4 20             	add    $0x20,%esp
  80147b:	5e                   	pop    %esi
  80147c:	5f                   	pop    %edi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    
  80147f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801480:	39 f5                	cmp    %esi,%ebp
  801482:	0f 87 ac 00 00 00    	ja     801534 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801488:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80148b:	83 f0 1f             	xor    $0x1f,%eax
  80148e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801492:	0f 84 a8 00 00 00    	je     801540 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801498:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80149c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80149e:	bf 20 00 00 00       	mov    $0x20,%edi
  8014a3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8014a7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014ab:	89 f9                	mov    %edi,%ecx
  8014ad:	d3 e8                	shr    %cl,%eax
  8014af:	09 e8                	or     %ebp,%eax
  8014b1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8014b5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8014b9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014bd:	d3 e0                	shl    %cl,%eax
  8014bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014c3:	89 f2                	mov    %esi,%edx
  8014c5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8014c7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014cb:	d3 e0                	shl    %cl,%eax
  8014cd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8014d1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8014d5:	89 f9                	mov    %edi,%ecx
  8014d7:	d3 e8                	shr    %cl,%eax
  8014d9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8014db:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014dd:	89 f2                	mov    %esi,%edx
  8014df:	f7 74 24 18          	divl   0x18(%esp)
  8014e3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8014e5:	f7 64 24 0c          	mull   0xc(%esp)
  8014e9:	89 c5                	mov    %eax,%ebp
  8014eb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014ed:	39 d6                	cmp    %edx,%esi
  8014ef:	72 67                	jb     801558 <__umoddi3+0x114>
  8014f1:	74 75                	je     801568 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8014f3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8014f7:	29 e8                	sub    %ebp,%eax
  8014f9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8014fb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014ff:	d3 e8                	shr    %cl,%eax
  801501:	89 f2                	mov    %esi,%edx
  801503:	89 f9                	mov    %edi,%ecx
  801505:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801507:	09 d0                	or     %edx,%eax
  801509:	89 f2                	mov    %esi,%edx
  80150b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80150f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801511:	83 c4 20             	add    $0x20,%esp
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801518:	85 c9                	test   %ecx,%ecx
  80151a:	75 0b                	jne    801527 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80151c:	b8 01 00 00 00       	mov    $0x1,%eax
  801521:	31 d2                	xor    %edx,%edx
  801523:	f7 f1                	div    %ecx
  801525:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801527:	89 f0                	mov    %esi,%eax
  801529:	31 d2                	xor    %edx,%edx
  80152b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	e9 3e ff ff ff       	jmp    801472 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801534:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801536:	83 c4 20             	add    $0x20,%esp
  801539:	5e                   	pop    %esi
  80153a:	5f                   	pop    %edi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    
  80153d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801540:	39 f5                	cmp    %esi,%ebp
  801542:	72 04                	jb     801548 <__umoddi3+0x104>
  801544:	39 f9                	cmp    %edi,%ecx
  801546:	77 06                	ja     80154e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801548:	89 f2                	mov    %esi,%edx
  80154a:	29 cf                	sub    %ecx,%edi
  80154c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80154e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801550:	83 c4 20             	add    $0x20,%esp
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    
  801557:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801558:	89 d1                	mov    %edx,%ecx
  80155a:	89 c5                	mov    %eax,%ebp
  80155c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801560:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801564:	eb 8d                	jmp    8014f3 <__umoddi3+0xaf>
  801566:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801568:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80156c:	72 ea                	jb     801558 <__umoddi3+0x114>
  80156e:	89 f1                	mov    %esi,%ecx
  801570:	eb 81                	jmp    8014f3 <__umoddi3+0xaf>
