
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 de 0a 00 00       	call   800b1f <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 80 	cmpl   $0xeec00080,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 de 0d 00 00       	call   800e48 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  80007c:	e8 3f 01 00 00       	call   8001c0 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 11 12 80 00 	movl   $0x801211,(%esp)
  800097:	e8 24 01 00 00       	call   8001c0 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 f0 0d 00 00       	call   800eb1 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d2:	e8 48 0a 00 00       	call   800b1f <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x30>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 34 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800100:	e8 07 00 00 00       	call   80010c <exit>
}
  800105:	83 c4 10             	add    $0x10,%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800119:	e8 af 09 00 00       	call   800acd <sys_env_destroy>
}
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 14             	sub    $0x14,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	8b 55 08             	mov    0x8(%ebp),%edx
  80012f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800133:	40                   	inc    %eax
  800134:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 19                	jne    800156 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80013d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800144:	00 
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	89 04 24             	mov    %eax,(%esp)
  80014b:	e8 40 09 00 00       	call   800a90 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800156:	ff 43 04             	incl   0x4(%ebx)
}
  800159:	83 c4 14             	add    $0x14,%esp
  80015c:	5b                   	pop    %ebx
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800168:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016f:	00 00 00 
	b.cnt = 0;
  800172:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800179:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800190:	89 44 24 04          	mov    %eax,0x4(%esp)
  800194:	c7 04 24 20 01 80 00 	movl   $0x800120,(%esp)
  80019b:	e8 82 01 00 00       	call   800322 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 d8 08 00 00       	call   800a90 <sys_cputs>

	return b.cnt;
}
  8001b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 87 ff ff ff       	call   80015f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    
	...

008001dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 3c             	sub    $0x3c,%esp
  8001e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e8:	89 d7                	mov    %edx,%edi
  8001ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	75 08                	jne    800208 <printnum+0x2c>
  800200:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800203:	39 45 10             	cmp    %eax,0x10(%ebp)
  800206:	77 57                	ja     80025f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800208:	89 74 24 10          	mov    %esi,0x10(%esp)
  80020c:	4b                   	dec    %ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80021c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800220:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800227:	00 
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	89 04 24             	mov    %eax,(%esp)
  80022e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	e8 76 0d 00 00       	call   800fb0 <__udivdi3>
  80023a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80023e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 fa                	mov    %edi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 89 ff ff ff       	call   8001dc <printnum>
  800253:	eb 0f                	jmp    800264 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800259:	89 34 24             	mov    %esi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	4b                   	dec    %ebx
  800260:	85 db                	test   %ebx,%ebx
  800262:	7f f1                	jg     800255 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800264:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800268:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027a:	00 
  80027b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027e:	89 04 24             	mov    %eax,(%esp)
  800281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800284:	89 44 24 04          	mov    %eax,0x4(%esp)
  800288:	e8 43 0e 00 00       	call   8010d0 <__umoddi3>
  80028d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800291:	0f be 80 32 12 80 00 	movsbl 0x801232(%eax),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80029e:	83 c4 3c             	add    $0x3c,%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a9:	83 fa 01             	cmp    $0x1,%edx
  8002ac:	7e 0e                	jle    8002bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ae:	8b 10                	mov    (%eax),%edx
  8002b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b3:	89 08                	mov    %ecx,(%eax)
  8002b5:	8b 02                	mov    (%edx),%eax
  8002b7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ba:	eb 22                	jmp    8002de <getuint+0x38>
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 10                	je     8002d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 0e                	jmp    8002de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ee:	73 08                	jae    8002f8 <sprintputch+0x18>
		*b->buf++ = ch;
  8002f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f3:	88 0a                	mov    %cl,(%edx)
  8002f5:	42                   	inc    %edx
  8002f6:	89 10                	mov    %edx,(%eax)
}
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800300:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800303:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800311:	89 44 24 04          	mov    %eax,0x4(%esp)
  800315:	8b 45 08             	mov    0x8(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 02 00 00 00       	call   800322 <vprintfmt>
	va_end(ap);
}
  800320:	c9                   	leave  
  800321:	c3                   	ret    

00800322 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
  800328:	83 ec 4c             	sub    $0x4c,%esp
  80032b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032e:	8b 75 10             	mov    0x10(%ebp),%esi
  800331:	eb 12                	jmp    800345 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800333:	85 c0                	test   %eax,%eax
  800335:	0f 84 6b 03 00 00    	je     8006a6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80033b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033f:	89 04 24             	mov    %eax,(%esp)
  800342:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800345:	0f b6 06             	movzbl (%esi),%eax
  800348:	46                   	inc    %esi
  800349:	83 f8 25             	cmp    $0x25,%eax
  80034c:	75 e5                	jne    800333 <vprintfmt+0x11>
  80034e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800352:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800359:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80035e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800365:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036a:	eb 26                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800373:	eb 1d                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800378:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80037c:	eb 14                	jmp    800392 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800381:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800388:	eb 08                	jmp    800392 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80038a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80038d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	0f b6 06             	movzbl (%esi),%eax
  800395:	8d 56 01             	lea    0x1(%esi),%edx
  800398:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80039b:	8a 16                	mov    (%esi),%dl
  80039d:	83 ea 23             	sub    $0x23,%edx
  8003a0:	80 fa 55             	cmp    $0x55,%dl
  8003a3:	0f 87 e1 02 00 00    	ja     80068a <vprintfmt+0x368>
  8003a9:	0f b6 d2             	movzbl %dl,%edx
  8003ac:	ff 24 95 80 13 80 00 	jmp    *0x801380(,%edx,4)
  8003b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003b6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003be:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003c2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003c5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c8:	83 fa 09             	cmp    $0x9,%edx
  8003cb:	77 2a                	ja     8003f7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003cd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ce:	eb eb                	jmp    8003bb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 17                	jmp    8003f7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e4:	78 98                	js     80037e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e9:	eb a7                	jmp    800392 <vprintfmt+0x70>
  8003eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f5:	eb 9b                	jmp    800392 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fb:	79 95                	jns    800392 <vprintfmt+0x70>
  8003fd:	eb 8b                	jmp    80038a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ff:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800403:	eb 8d                	jmp    800392 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 50 04             	lea    0x4(%eax),%edx
  80040b:	89 55 14             	mov    %edx,0x14(%ebp)
  80040e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800412:	8b 00                	mov    (%eax),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80041d:	e9 23 ff ff ff       	jmp    800345 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	79 02                	jns    800433 <vprintfmt+0x111>
  800431:	f7 d8                	neg    %eax
  800433:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 11             	cmp    $0x11,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x123>
  80043a:	8b 04 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	75 23                	jne    800468 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800445:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800449:	c7 44 24 08 4a 12 80 	movl   $0x80124a,0x8(%esp)
  800450:	00 
  800451:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800455:	8b 45 08             	mov    0x8(%ebp),%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 9a fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 dd fe ff ff       	jmp    800345 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046c:	c7 44 24 08 53 12 80 	movl   $0x801253,0x8(%esp)
  800473:	00 
  800474:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800478:	8b 55 08             	mov    0x8(%ebp),%edx
  80047b:	89 14 24             	mov    %edx,(%esp)
  80047e:	e8 77 fe ff ff       	call   8002fa <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800486:	e9 ba fe ff ff       	jmp    800345 <vprintfmt+0x23>
  80048b:	89 f9                	mov    %edi,%ecx
  80048d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800490:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	8b 30                	mov    (%eax),%esi
  80049e:	85 f6                	test   %esi,%esi
  8004a0:	75 05                	jne    8004a7 <vprintfmt+0x185>
				p = "(null)";
  8004a2:	be 43 12 80 00       	mov    $0x801243,%esi
			if (width > 0 && padc != '-')
  8004a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ab:	0f 8e 84 00 00 00    	jle    800535 <vprintfmt+0x213>
  8004b1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004b5:	74 7e                	je     800535 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bb:	89 34 24             	mov    %esi,(%esp)
  8004be:	e8 8b 02 00 00       	call   80074e <strnlen>
  8004c3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c6:	29 c2                	sub    %eax,%edx
  8004c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004cb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004cf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004d5:	89 de                	mov    %ebx,%esi
  8004d7:	89 d3                	mov    %edx,%ebx
  8004d9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0b                	jmp    8004e8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	89 3c 24             	mov    %edi,(%esp)
  8004e4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	4b                   	dec    %ebx
  8004e8:	85 db                	test   %ebx,%ebx
  8004ea:	7f f1                	jg     8004dd <vprintfmt+0x1bb>
  8004ec:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004ef:	89 f3                	mov    %esi,%ebx
  8004f1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 05                	jns    800500 <vprintfmt+0x1de>
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800503:	29 c2                	sub    %eax,%edx
  800505:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800508:	eb 2b                	jmp    800535 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050e:	74 18                	je     800528 <vprintfmt+0x206>
  800510:	8d 50 e0             	lea    -0x20(%eax),%edx
  800513:	83 fa 5e             	cmp    $0x5e,%edx
  800516:	76 10                	jbe    800528 <vprintfmt+0x206>
					putch('?', putdat);
  800518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80051c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	eb 0a                	jmp    800532 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800528:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052c:	89 04 24             	mov    %eax,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	ff 4d e4             	decl   -0x1c(%ebp)
  800535:	0f be 06             	movsbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	85 c0                	test   %eax,%eax
  80053b:	74 21                	je     80055e <vprintfmt+0x23c>
  80053d:	85 ff                	test   %edi,%edi
  80053f:	78 c9                	js     80050a <vprintfmt+0x1e8>
  800541:	4f                   	dec    %edi
  800542:	79 c6                	jns    80050a <vprintfmt+0x1e8>
  800544:	8b 7d 08             	mov    0x8(%ebp),%edi
  800547:	89 de                	mov    %ebx,%esi
  800549:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054c:	eb 18                	jmp    800566 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800552:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800559:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055b:	4b                   	dec    %ebx
  80055c:	eb 08                	jmp    800566 <vprintfmt+0x244>
  80055e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800561:	89 de                	mov    %ebx,%esi
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800566:	85 db                	test   %ebx,%ebx
  800568:	7f e4                	jg     80054e <vprintfmt+0x22c>
  80056a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80056d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	e9 ce fd ff ff       	jmp    800345 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800577:	83 f9 01             	cmp    $0x1,%ecx
  80057a:	7e 10                	jle    80058c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 50 08             	lea    0x8(%eax),%edx
  800582:	89 55 14             	mov    %edx,0x14(%ebp)
  800585:	8b 30                	mov    (%eax),%esi
  800587:	8b 78 04             	mov    0x4(%eax),%edi
  80058a:	eb 26                	jmp    8005b2 <vprintfmt+0x290>
	else if (lflag)
  80058c:	85 c9                	test   %ecx,%ecx
  80058e:	74 12                	je     8005a2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 50 04             	lea    0x4(%eax),%edx
  800596:	89 55 14             	mov    %edx,0x14(%ebp)
  800599:	8b 30                	mov    (%eax),%esi
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	c1 ff 1f             	sar    $0x1f,%edi
  8005a0:	eb 10                	jmp    8005b2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 04             	lea    0x4(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 30                	mov    (%eax),%esi
  8005ad:	89 f7                	mov    %esi,%edi
  8005af:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	78 0a                	js     8005c0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bb:	e9 8c 00 00 00       	jmp    80064c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ce:	f7 de                	neg    %esi
  8005d0:	83 d7 00             	adc    $0x0,%edi
  8005d3:	f7 df                	neg    %edi
			}
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	eb 70                	jmp    80064c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005dc:	89 ca                	mov    %ecx,%edx
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 c0 fc ff ff       	call   8002a6 <getuint>
  8005e6:	89 c6                	mov    %eax,%esi
  8005e8:	89 d7                	mov    %edx,%edi
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ef:	eb 5b                	jmp    80064c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8005f1:	89 ca                	mov    %ecx,%edx
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 ab fc ff ff       	call   8002a6 <getuint>
  8005fb:	89 c6                	mov    %eax,%esi
  8005fd:	89 d7                	mov    %edx,%edi
			base = 8;
  8005ff:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800604:	eb 46                	jmp    80064c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800606:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 04             	lea    0x4(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062b:	8b 30                	mov    (%eax),%esi
  80062d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800632:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800637:	eb 13                	jmp    80064c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800639:	89 ca                	mov    %ecx,%edx
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 63 fc ff ff       	call   8002a6 <getuint>
  800643:	89 c6                	mov    %eax,%esi
  800645:	89 d7                	mov    %edx,%edi
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800650:	89 54 24 10          	mov    %edx,0x10(%esp)
  800654:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065f:	89 34 24             	mov    %esi,(%esp)
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	89 da                	mov    %ebx,%edx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	e8 6c fb ff ff       	call   8001dc <printnum>
			break;
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800673:	e9 cd fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800678:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800685:	e9 bb fc ff ff       	jmp    800345 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800695:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	eb 01                	jmp    80069b <vprintfmt+0x379>
  80069a:	4e                   	dec    %esi
  80069b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80069f:	75 f9                	jne    80069a <vprintfmt+0x378>
  8006a1:	e9 9f fc ff ff       	jmp    800345 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006a6:	83 c4 4c             	add    $0x4c,%esp
  8006a9:	5b                   	pop    %ebx
  8006aa:	5e                   	pop    %esi
  8006ab:	5f                   	pop    %edi
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	83 ec 28             	sub    $0x28,%esp
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 30                	je     8006ff <vsnprintf+0x51>
  8006cf:	85 d2                	test   %edx,%edx
  8006d1:	7e 33                	jle    800706 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006da:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	c7 04 24 e0 02 80 00 	movl   $0x8002e0,(%esp)
  8006ef:	e8 2e fc ff ff       	call   800322 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	eb 0c                	jmp    80070b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800704:	eb 05                	jmp    80070b <vsnprintf+0x5d>
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800713:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800716:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071a:	8b 45 10             	mov    0x10(%ebp),%eax
  80071d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800721:	8b 45 0c             	mov    0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	e8 7b ff ff ff       	call   8006ae <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    
  800735:	00 00                	add    %al,(%eax)
	...

00800738 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 01                	jmp    800746 <strlen+0xe>
		n++;
  800745:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	75 f9                	jne    800745 <strlen+0xd>
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	eb 01                	jmp    80075f <strnlen+0x11>
		n++;
  80075e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	39 d0                	cmp    %edx,%eax
  800761:	74 06                	je     800769 <strnlen+0x1b>
  800763:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800767:	75 f5                	jne    80075e <strnlen+0x10>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800775:	ba 00 00 00 00       	mov    $0x0,%edx
  80077a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80077d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800780:	42                   	inc    %edx
  800781:	84 c9                	test   %cl,%cl
  800783:	75 f5                	jne    80077a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	89 1c 24             	mov    %ebx,(%esp)
  800795:	e8 9e ff ff ff       	call   800738 <strlen>
	strcpy(dst + len, src);
  80079a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a1:	01 d8                	add    %ebx,%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 c0 ff ff ff       	call   80076b <strcpy>
	return dst;
}
  8007ab:	89 d8                	mov    %ebx,%eax
  8007ad:	83 c4 08             	add    $0x8,%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	56                   	push   %esi
  8007b7:	53                   	push   %ebx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c6:	eb 0c                	jmp    8007d4 <strncpy+0x21>
		*dst++ = *src;
  8007c8:	8a 1a                	mov    (%edx),%bl
  8007ca:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cd:	80 3a 01             	cmpb   $0x1,(%edx)
  8007d0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d3:	41                   	inc    %ecx
  8007d4:	39 f1                	cmp    %esi,%ecx
  8007d6:	75 f0                	jne    8007c8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	56                   	push   %esi
  8007e0:	53                   	push   %ebx
  8007e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	75 0a                	jne    8007f8 <strlcpy+0x1c>
  8007ee:	89 f0                	mov    %esi,%eax
  8007f0:	eb 1a                	jmp    80080c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f2:	88 18                	mov    %bl,(%eax)
  8007f4:	40                   	inc    %eax
  8007f5:	41                   	inc    %ecx
  8007f6:	eb 02                	jmp    8007fa <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007fa:	4a                   	dec    %edx
  8007fb:	74 0a                	je     800807 <strlcpy+0x2b>
  8007fd:	8a 19                	mov    (%ecx),%bl
  8007ff:	84 db                	test   %bl,%bl
  800801:	75 ef                	jne    8007f2 <strlcpy+0x16>
  800803:	89 c2                	mov    %eax,%edx
  800805:	eb 02                	jmp    800809 <strlcpy+0x2d>
  800807:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800809:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 02                	jmp    80081f <strcmp+0xd>
		p++, q++;
  80081d:	41                   	inc    %ecx
  80081e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081f:	8a 01                	mov    (%ecx),%al
  800821:	84 c0                	test   %al,%al
  800823:	74 04                	je     800829 <strcmp+0x17>
  800825:	3a 02                	cmp    (%edx),%al
  800827:	74 f4                	je     80081d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800829:	0f b6 c0             	movzbl %al,%eax
  80082c:	0f b6 12             	movzbl (%edx),%edx
  80082f:	29 d0                	sub    %edx,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800840:	eb 03                	jmp    800845 <strncmp+0x12>
		n--, p++, q++;
  800842:	4a                   	dec    %edx
  800843:	40                   	inc    %eax
  800844:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800845:	85 d2                	test   %edx,%edx
  800847:	74 14                	je     80085d <strncmp+0x2a>
  800849:	8a 18                	mov    (%eax),%bl
  80084b:	84 db                	test   %bl,%bl
  80084d:	74 04                	je     800853 <strncmp+0x20>
  80084f:	3a 19                	cmp    (%ecx),%bl
  800851:	74 ef                	je     800842 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 00             	movzbl (%eax),%eax
  800856:	0f b6 11             	movzbl (%ecx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb 05                	jmp    800862 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086e:	eb 05                	jmp    800875 <strchr+0x10>
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 0c                	je     800880 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800874:	40                   	inc    %eax
  800875:	8a 10                	mov    (%eax),%dl
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f5                	jne    800870 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088b:	eb 05                	jmp    800892 <strfind+0x10>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 07                	je     800898 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800891:	40                   	inc    %eax
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f5                	jne    80088d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	74 30                	je     8008dd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b3:	75 25                	jne    8008da <memset+0x40>
  8008b5:	f6 c1 03             	test   $0x3,%cl
  8008b8:	75 20                	jne    8008da <memset+0x40>
		c &= 0xFF;
  8008ba:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 d0                	or     %edx,%eax
  8008d0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 03                	jmp    8008dd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	fc                   	cld    
  8008db:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008dd:	89 f8                	mov    %edi,%eax
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	57                   	push   %edi
  8008e8:	56                   	push   %esi
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f2:	39 c6                	cmp    %eax,%esi
  8008f4:	73 34                	jae    80092a <memmove+0x46>
  8008f6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f9:	39 d0                	cmp    %edx,%eax
  8008fb:	73 2d                	jae    80092a <memmove+0x46>
		s += n;
		d += n;
  8008fd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800900:	f6 c2 03             	test   $0x3,%dl
  800903:	75 1b                	jne    800920 <memmove+0x3c>
  800905:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090b:	75 13                	jne    800920 <memmove+0x3c>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0e                	jne    800920 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 07                	jmp    800927 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	4f                   	dec    %edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 20                	jmp    80094a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	75 13                	jne    800945 <memmove+0x61>
  800932:	a8 03                	test   $0x3,%al
  800934:	75 0f                	jne    800945 <memmove+0x61>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80093b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800954:	8b 45 10             	mov    0x10(%ebp),%eax
  800957:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	e8 77 ff ff ff       	call   8008e4 <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	ba 00 00 00 00       	mov    $0x0,%edx
  800983:	eb 16                	jmp    80099b <memcmp+0x2c>
		if (*s1 != *s2)
  800985:	8a 04 17             	mov    (%edi,%edx,1),%al
  800988:	42                   	inc    %edx
  800989:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  80098d:	38 c8                	cmp    %cl,%al
  80098f:	74 0a                	je     80099b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 c9             	movzbl %cl,%ecx
  800997:	29 c8                	sub    %ecx,%eax
  800999:	eb 09                	jmp    8009a4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	39 da                	cmp    %ebx,%edx
  80099d:	75 e6                	jne    800985 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5f                   	pop    %edi
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b2:	89 c2                	mov    %eax,%edx
  8009b4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b7:	eb 05                	jmp    8009be <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b9:	38 08                	cmp    %cl,(%eax)
  8009bb:	74 05                	je     8009c2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bd:	40                   	inc    %eax
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	72 f7                	jb     8009b9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	57                   	push   %edi
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	eb 01                	jmp    8009d3 <strtol+0xf>
		s++;
  8009d2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	8a 02                	mov    (%edx),%al
  8009d5:	3c 20                	cmp    $0x20,%al
  8009d7:	74 f9                	je     8009d2 <strtol+0xe>
  8009d9:	3c 09                	cmp    $0x9,%al
  8009db:	74 f5                	je     8009d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dd:	3c 2b                	cmp    $0x2b,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x25>
		s++;
  8009e1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb 13                	jmp    8009fc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 0a                	jne    8009f7 <strtol+0x33>
		s++, neg = 1;
  8009ed:	8d 52 01             	lea    0x1(%edx),%edx
  8009f0:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f5:	eb 05                	jmp    8009fc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	74 05                	je     800a05 <strtol+0x41>
  800a00:	83 fb 10             	cmp    $0x10,%ebx
  800a03:	75 28                	jne    800a2d <strtol+0x69>
  800a05:	8a 02                	mov    (%edx),%al
  800a07:	3c 30                	cmp    $0x30,%al
  800a09:	75 10                	jne    800a1b <strtol+0x57>
  800a0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a0f:	75 0a                	jne    800a1b <strtol+0x57>
		s += 2, base = 16;
  800a11:	83 c2 02             	add    $0x2,%edx
  800a14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a19:	eb 12                	jmp    800a2d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	75 0e                	jne    800a2d <strtol+0x69>
  800a1f:	3c 30                	cmp    $0x30,%al
  800a21:	75 05                	jne    800a28 <strtol+0x64>
		s++, base = 8;
  800a23:	42                   	inc    %edx
  800a24:	b3 08                	mov    $0x8,%bl
  800a26:	eb 05                	jmp    800a2d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a28:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	8a 0a                	mov    (%edx),%cl
  800a36:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a39:	80 fb 09             	cmp    $0x9,%bl
  800a3c:	77 08                	ja     800a46 <strtol+0x82>
			dig = *s - '0';
  800a3e:	0f be c9             	movsbl %cl,%ecx
  800a41:	83 e9 30             	sub    $0x30,%ecx
  800a44:	eb 1e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a46:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a4e:	0f be c9             	movsbl %cl,%ecx
  800a51:	83 e9 57             	sub    $0x57,%ecx
  800a54:	eb 0e                	jmp    800a64 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a56:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 12                	ja     800a70 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a5e:	0f be c9             	movsbl %cl,%ecx
  800a61:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a64:	39 f1                	cmp    %esi,%ecx
  800a66:	7d 0c                	jge    800a74 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a68:	42                   	inc    %edx
  800a69:	0f af c6             	imul   %esi,%eax
  800a6c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a6e:	eb c4                	jmp    800a34 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a70:	89 c1                	mov    %eax,%ecx
  800a72:	eb 02                	jmp    800a76 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a74:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7a:	74 05                	je     800a81 <strtol+0xbd>
		*endptr = (char *) s;
  800a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a81:	85 ff                	test   %edi,%edi
  800a83:	74 04                	je     800a89 <strtol+0xc5>
  800a85:	89 c8                	mov    %ecx,%eax
  800a87:	f7 d8                	neg    %eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    
	...

00800a90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	57                   	push   %edi
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	89 c6                	mov    %eax,%esi
  800aa7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <sys_cgetc>:

int
sys_cgetc(void)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	57                   	push   %edi
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab9:	b8 01 00 00 00       	mov    $0x1,%eax
  800abe:	89 d1                	mov    %edx,%ecx
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	89 d7                	mov    %edx,%edi
  800ac4:	89 d6                	mov    %edx,%esi
  800ac6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae3:	89 cb                	mov    %ecx,%ebx
  800ae5:	89 cf                	mov    %ecx,%edi
  800ae7:	89 ce                	mov    %ecx,%esi
  800ae9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	7e 28                	jle    800b17 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800af3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800afa:	00 
  800afb:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800b02:	00 
  800b03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b0a:	00 
  800b0b:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800b12:	e8 41 04 00 00       	call   800f58 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b17:	83 c4 2c             	add    $0x2c,%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_yield>:

void
sys_yield(void)
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
  800b49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b66:	be 00 00 00 00       	mov    $0x0,%esi
  800b6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	89 f7                	mov    %esi,%edi
  800b7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 28                	jle    800ba9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b85:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800b94:	00 
  800b95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9c:	00 
  800b9d:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800ba4:	e8 af 03 00 00       	call   800f58 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	83 c4 2c             	add    $0x2c,%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 28                	jle    800bfc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bdf:	00 
  800be0:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800be7:	00 
  800be8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bef:	00 
  800bf0:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800bf7:	e8 5c 03 00 00       	call   800f58 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfc:	83 c4 2c             	add    $0x2c,%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 06 00 00 00       	mov    $0x6,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 28                	jle    800c4f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800c4a:	e8 09 03 00 00       	call   800f58 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c4f:	83 c4 2c             	add    $0x2c,%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c65:	b8 08 00 00 00       	mov    $0x8,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 df                	mov    %ebx,%edi
  800c72:	89 de                	mov    %ebx,%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 28                	jle    800ca2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c85:	00 
  800c86:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c95:	00 
  800c96:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800c9d:	e8 b6 02 00 00       	call   800f58 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca2:	83 c4 2c             	add    $0x2c,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 28                	jle    800cf5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800ce0:	00 
  800ce1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce8:	00 
  800ce9:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800cf0:	e8 63 02 00 00       	call   800f58 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf5:	83 c4 2c             	add    $0x2c,%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 df                	mov    %ebx,%edi
  800d18:	89 de                	mov    %ebx,%esi
  800d1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	7e 28                	jle    800d48 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d20:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d24:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800d33:	00 
  800d34:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3b:	00 
  800d3c:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800d43:	e8 10 02 00 00       	call   800f58 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d48:	83 c4 2c             	add    $0x2c,%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 28                	jle    800dbd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d99:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800da0:	00 
  800da1:	c7 44 24 08 47 15 80 	movl   $0x801547,0x8(%esp)
  800da8:	00 
  800da9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db0:	00 
  800db1:	c7 04 24 64 15 80 00 	movl   $0x801564,(%esp)
  800db8:	e8 9b 01 00 00       	call   800f58 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbd:	83 c4 2c             	add    $0x2c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	89 d3                	mov    %edx,%ebx
  800dd9:	89 d7                	mov    %edx,%edi
  800ddb:	89 d6                	mov    %edx,%esi
  800ddd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800def:	b8 10 00 00 00       	mov    $0x10,%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 df                	mov    %ebx,%edi
  800dfc:	89 de                	mov    %ebx,%esi
  800dfe:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e31:	b8 11 00 00 00       	mov    $0x11,%eax
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
  800e39:	89 cb                	mov    %ecx,%ebx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	89 ce                	mov    %ecx,%esi
  800e3f:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    
	...

00800e48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 10             	sub    $0x10,%esp
  800e50:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	75 05                	jne    800e62 <ipc_recv+0x1a>
  800e5d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800e62:	89 04 24             	mov    %eax,(%esp)
  800e65:	e8 09 ff ff ff       	call   800d73 <sys_ipc_recv>
	if (from_env_store != NULL)
  800e6a:	85 db                	test   %ebx,%ebx
  800e6c:	74 0b                	je     800e79 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  800e6e:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800e74:	8b 52 74             	mov    0x74(%edx),%edx
  800e77:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  800e79:	85 f6                	test   %esi,%esi
  800e7b:	74 0b                	je     800e88 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  800e7d:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800e83:	8b 52 78             	mov    0x78(%edx),%edx
  800e86:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	79 16                	jns    800ea2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  800e8c:	85 db                	test   %ebx,%ebx
  800e8e:	74 06                	je     800e96 <ipc_recv+0x4e>
			*from_env_store = 0;
  800e90:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  800e96:	85 f6                	test   %esi,%esi
  800e98:	74 10                	je     800eaa <ipc_recv+0x62>
			*perm_store = 0;
  800e9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800ea0:	eb 08                	jmp    800eaa <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  800ea2:	a1 04 20 80 00       	mov    0x802004,%eax
  800ea7:	8b 40 70             	mov    0x70(%eax),%eax
}
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
  800eb7:	83 ec 1c             	sub    $0x1c,%esp
  800eba:	8b 75 08             	mov    0x8(%ebp),%esi
  800ebd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  800ec3:	eb 2a                	jmp    800eef <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  800ec5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800ec8:	74 20                	je     800eea <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  800eca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ece:	c7 44 24 08 74 15 80 	movl   $0x801574,0x8(%esp)
  800ed5:	00 
  800ed6:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800edd:	00 
  800ede:	c7 04 24 99 15 80 00 	movl   $0x801599,(%esp)
  800ee5:	e8 6e 00 00 00       	call   800f58 <_panic>
		sys_yield();
  800eea:	e8 4f fc ff ff       	call   800b3e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  800eef:	85 db                	test   %ebx,%ebx
  800ef1:	75 07                	jne    800efa <ipc_send+0x49>
  800ef3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800ef8:	eb 02                	jmp    800efc <ipc_send+0x4b>
  800efa:	89 d8                	mov    %ebx,%eax
  800efc:	8b 55 14             	mov    0x14(%ebp),%edx
  800eff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f07:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f0b:	89 34 24             	mov    %esi,(%esp)
  800f0e:	e8 3d fe ff ff       	call   800d50 <sys_ipc_try_send>
  800f13:	85 c0                	test   %eax,%eax
  800f15:	78 ae                	js     800ec5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  800f17:	83 c4 1c             	add    $0x1c,%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f2a:	89 c2                	mov    %eax,%edx
  800f2c:	c1 e2 07             	shl    $0x7,%edx
  800f2f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f35:	8b 52 50             	mov    0x50(%edx),%edx
  800f38:	39 ca                	cmp    %ecx,%edx
  800f3a:	75 0d                	jne    800f49 <ipc_find_env+0x2a>
			return envs[i].env_id;
  800f3c:	c1 e0 07             	shl    $0x7,%eax
  800f3f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800f44:	8b 40 40             	mov    0x40(%eax),%eax
  800f47:	eb 0c                	jmp    800f55 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f49:	40                   	inc    %eax
  800f4a:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f4f:	75 d9                	jne    800f2a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800f51:	66 b8 00 00          	mov    $0x0,%ax
}
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    
	...

00800f58 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800f60:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f63:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f69:	e8 b1 fb ff ff       	call   800b1f <sys_getenvid>
  800f6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f71:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f75:	8b 55 08             	mov    0x8(%ebp),%edx
  800f78:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f7c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f84:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  800f8b:	e8 30 f2 ff ff       	call   8001c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f90:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f94:	8b 45 10             	mov    0x10(%ebp),%eax
  800f97:	89 04 24             	mov    %eax,(%esp)
  800f9a:	e8 c0 f1 ff ff       	call   80015f <vcprintf>
	cprintf("\n");
  800f9f:	c7 04 24 0f 12 80 00 	movl   $0x80120f,(%esp)
  800fa6:	e8 15 f2 ff ff       	call   8001c0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fab:	cc                   	int3   
  800fac:	eb fd                	jmp    800fab <_panic+0x53>
	...

00800fb0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800fb0:	55                   	push   %ebp
  800fb1:	57                   	push   %edi
  800fb2:	56                   	push   %esi
  800fb3:	83 ec 10             	sub    $0x10,%esp
  800fb6:	8b 74 24 20          	mov    0x20(%esp),%esi
  800fba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800fbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800fc6:	89 cd                	mov    %ecx,%ebp
  800fc8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	75 2c                	jne    800ffc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800fd0:	39 f9                	cmp    %edi,%ecx
  800fd2:	77 68                	ja     80103c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800fd4:	85 c9                	test   %ecx,%ecx
  800fd6:	75 0b                	jne    800fe3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800fd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdd:	31 d2                	xor    %edx,%edx
  800fdf:	f7 f1                	div    %ecx
  800fe1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	89 f8                	mov    %edi,%eax
  800fe7:	f7 f1                	div    %ecx
  800fe9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800feb:	89 f0                	mov    %esi,%eax
  800fed:	f7 f1                	div    %ecx
  800fef:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ffc:	39 f8                	cmp    %edi,%eax
  800ffe:	77 2c                	ja     80102c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801000:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801003:	83 f6 1f             	xor    $0x1f,%esi
  801006:	75 4c                	jne    801054 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801008:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80100a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80100f:	72 0a                	jb     80101b <__udivdi3+0x6b>
  801011:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801015:	0f 87 ad 00 00 00    	ja     8010c8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80101b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801020:	89 f0                	mov    %esi,%eax
  801022:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
  80102b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80102c:	31 ff                	xor    %edi,%edi
  80102e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801030:	89 f0                	mov    %esi,%eax
  801032:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    
  80103b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80103c:	89 fa                	mov    %edi,%edx
  80103e:	89 f0                	mov    %esi,%eax
  801040:	f7 f1                	div    %ecx
  801042:	89 c6                	mov    %eax,%esi
  801044:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801046:	89 f0                	mov    %esi,%eax
  801048:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    
  801051:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801054:	89 f1                	mov    %esi,%ecx
  801056:	d3 e0                	shl    %cl,%eax
  801058:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80105c:	b8 20 00 00 00       	mov    $0x20,%eax
  801061:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801063:	89 ea                	mov    %ebp,%edx
  801065:	88 c1                	mov    %al,%cl
  801067:	d3 ea                	shr    %cl,%edx
  801069:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80106d:	09 ca                	or     %ecx,%edx
  80106f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801073:	89 f1                	mov    %esi,%ecx
  801075:	d3 e5                	shl    %cl,%ebp
  801077:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80107b:	89 fd                	mov    %edi,%ebp
  80107d:	88 c1                	mov    %al,%cl
  80107f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801081:	89 fa                	mov    %edi,%edx
  801083:	89 f1                	mov    %esi,%ecx
  801085:	d3 e2                	shl    %cl,%edx
  801087:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80108b:	88 c1                	mov    %al,%cl
  80108d:	d3 ef                	shr    %cl,%edi
  80108f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801091:	89 f8                	mov    %edi,%eax
  801093:	89 ea                	mov    %ebp,%edx
  801095:	f7 74 24 08          	divl   0x8(%esp)
  801099:	89 d1                	mov    %edx,%ecx
  80109b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80109d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010a1:	39 d1                	cmp    %edx,%ecx
  8010a3:	72 17                	jb     8010bc <__udivdi3+0x10c>
  8010a5:	74 09                	je     8010b0 <__udivdi3+0x100>
  8010a7:	89 fe                	mov    %edi,%esi
  8010a9:	31 ff                	xor    %edi,%edi
  8010ab:	e9 41 ff ff ff       	jmp    800ff1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8010b0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010b4:	89 f1                	mov    %esi,%ecx
  8010b6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010b8:	39 c2                	cmp    %eax,%edx
  8010ba:	73 eb                	jae    8010a7 <__udivdi3+0xf7>
		{
		  q0--;
  8010bc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8010bf:	31 ff                	xor    %edi,%edi
  8010c1:	e9 2b ff ff ff       	jmp    800ff1 <__udivdi3+0x41>
  8010c6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8010c8:	31 f6                	xor    %esi,%esi
  8010ca:	e9 22 ff ff ff       	jmp    800ff1 <__udivdi3+0x41>
	...

008010d0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8010d0:	55                   	push   %ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	83 ec 20             	sub    $0x20,%esp
  8010d6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8010da:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8010de:	89 44 24 14          	mov    %eax,0x14(%esp)
  8010e2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8010e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8010ea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8010ee:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8010f0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8010f2:	85 ed                	test   %ebp,%ebp
  8010f4:	75 16                	jne    80110c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8010f6:	39 f1                	cmp    %esi,%ecx
  8010f8:	0f 86 a6 00 00 00    	jbe    8011a4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010fe:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801100:	89 d0                	mov    %edx,%eax
  801102:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    
  80110b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80110c:	39 f5                	cmp    %esi,%ebp
  80110e:	0f 87 ac 00 00 00    	ja     8011c0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801114:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801117:	83 f0 1f             	xor    $0x1f,%eax
  80111a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111e:	0f 84 a8 00 00 00    	je     8011cc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801124:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801128:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80112a:	bf 20 00 00 00       	mov    $0x20,%edi
  80112f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801133:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801137:	89 f9                	mov    %edi,%ecx
  801139:	d3 e8                	shr    %cl,%eax
  80113b:	09 e8                	or     %ebp,%eax
  80113d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801141:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801145:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801149:	d3 e0                	shl    %cl,%eax
  80114b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80114f:	89 f2                	mov    %esi,%edx
  801151:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801153:	8b 44 24 14          	mov    0x14(%esp),%eax
  801157:	d3 e0                	shl    %cl,%eax
  801159:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80115d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801161:	89 f9                	mov    %edi,%ecx
  801163:	d3 e8                	shr    %cl,%eax
  801165:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801167:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801169:	89 f2                	mov    %esi,%edx
  80116b:	f7 74 24 18          	divl   0x18(%esp)
  80116f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801171:	f7 64 24 0c          	mull   0xc(%esp)
  801175:	89 c5                	mov    %eax,%ebp
  801177:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801179:	39 d6                	cmp    %edx,%esi
  80117b:	72 67                	jb     8011e4 <__umoddi3+0x114>
  80117d:	74 75                	je     8011f4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80117f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801183:	29 e8                	sub    %ebp,%eax
  801185:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801187:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80118b:	d3 e8                	shr    %cl,%eax
  80118d:	89 f2                	mov    %esi,%edx
  80118f:	89 f9                	mov    %edi,%ecx
  801191:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801193:	09 d0                	or     %edx,%eax
  801195:	89 f2                	mov    %esi,%edx
  801197:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80119b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80119d:	83 c4 20             	add    $0x20,%esp
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8011a4:	85 c9                	test   %ecx,%ecx
  8011a6:	75 0b                	jne    8011b3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8011a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ad:	31 d2                	xor    %edx,%edx
  8011af:	f7 f1                	div    %ecx
  8011b1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8011b3:	89 f0                	mov    %esi,%eax
  8011b5:	31 d2                	xor    %edx,%edx
  8011b7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8011b9:	89 f8                	mov    %edi,%eax
  8011bb:	e9 3e ff ff ff       	jmp    8010fe <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8011c0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8011c2:	83 c4 20             	add    $0x20,%esp
  8011c5:	5e                   	pop    %esi
  8011c6:	5f                   	pop    %edi
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    
  8011c9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8011cc:	39 f5                	cmp    %esi,%ebp
  8011ce:	72 04                	jb     8011d4 <__umoddi3+0x104>
  8011d0:	39 f9                	cmp    %edi,%ecx
  8011d2:	77 06                	ja     8011da <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8011d4:	89 f2                	mov    %esi,%edx
  8011d6:	29 cf                	sub    %ecx,%edi
  8011d8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8011da:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8011dc:	83 c4 20             	add    $0x20,%esp
  8011df:	5e                   	pop    %esi
  8011e0:	5f                   	pop    %edi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    
  8011e3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8011e4:	89 d1                	mov    %edx,%ecx
  8011e6:	89 c5                	mov    %eax,%ebp
  8011e8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8011ec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8011f0:	eb 8d                	jmp    80117f <__umoddi3+0xaf>
  8011f2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8011f4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8011f8:	72 ea                	jb     8011e4 <__umoddi3+0x114>
  8011fa:	89 f1                	mov    %esi,%ecx
  8011fc:	eb 81                	jmp    80117f <__umoddi3+0xaf>
