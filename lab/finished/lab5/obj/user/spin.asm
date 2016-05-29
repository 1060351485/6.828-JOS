
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
  80003b:	c7 04 24 20 15 80 00 	movl   $0x801520,(%esp)
  800042:	e8 71 01 00 00       	call   8001b8 <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 83 0e 00 00       	call   800ecf <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 98 15 80 00 	movl   $0x801598,(%esp)
  800059:	e8 5a 01 00 00       	call   8001b8 <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 48 15 80 00 	movl   $0x801548,(%esp)
  800067:	e8 4c 01 00 00       	call   8001b8 <cprintf>
	sys_yield();
  80006c:	e8 c5 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800071:	e8 c0 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800076:	e8 bb 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  80007b:	e8 b6 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800080:	e8 b1 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  800085:	e8 ac 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  80008a:	e8 a7 0a 00 00       	call   800b36 <sys_yield>
	sys_yield();
  80008f:	e8 a2 0a 00 00       	call   800b36 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  80009b:	e8 18 01 00 00       	call   8001b8 <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 1d 0a 00 00       	call   800ac5 <sys_env_destroy>
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
  8000be:	e8 54 0a 00 00       	call   800b17 <sys_getenvid>
  8000c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000cf:	c1 e0 07             	shl    $0x7,%eax
  8000d2:	29 d0                	sub    %edx,%eax
  8000d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d9:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000de:	85 f6                	test   %esi,%esi
  8000e0:	7e 07                	jle    8000e9 <libmain+0x39>
		binaryname = argv[0];
  8000e2:	8b 03                	mov    (%ebx),%eax
  8000e4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ed:	89 34 24             	mov    %esi,(%esp)
  8000f0:	e8 3f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80010a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800111:	e8 af 09 00 00       	call   800ac5 <sys_env_destroy>
}
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 14             	sub    $0x14,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 03                	mov    (%ebx),%eax
  800124:	8b 55 08             	mov    0x8(%ebp),%edx
  800127:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80012b:	40                   	inc    %eax
  80012c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 19                	jne    80014e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800135:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80013c:	00 
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	89 04 24             	mov    %eax,(%esp)
  800143:	e8 40 09 00 00       	call   800a88 <sys_cputs>
		b->idx = 0;
  800148:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80014e:	ff 43 04             	incl   0x4(%ebx)
}
  800151:	83 c4 14             	add    $0x14,%esp
  800154:	5b                   	pop    %ebx
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	8b 45 0c             	mov    0xc(%ebp),%eax
  800177:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800182:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018c:	c7 04 24 18 01 80 00 	movl   $0x800118,(%esp)
  800193:	e8 82 01 00 00       	call   80031a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800198:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 d8 08 00 00       	call   800a88 <sys_cputs>

	return b.cnt;
}
  8001b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 87 ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    
	...

008001d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	83 ec 3c             	sub    $0x3c,%esp
  8001dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001e0:	89 d7                	mov    %edx,%edi
  8001e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	75 08                	jne    800200 <printnum+0x2c>
  8001f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001fe:	77 57                	ja     800257 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800200:	89 74 24 10          	mov    %esi,0x10(%esp)
  800204:	4b                   	dec    %ebx
  800205:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800209:	8b 45 10             	mov    0x10(%ebp),%eax
  80020c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800210:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800214:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800218:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021f:	00 
  800220:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	e8 86 10 00 00       	call   8012b8 <__udivdi3>
  800232:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800236:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80023a:	89 04 24             	mov    %eax,(%esp)
  80023d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800241:	89 fa                	mov    %edi,%edx
  800243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800246:	e8 89 ff ff ff       	call   8001d4 <printnum>
  80024b:	eb 0f                	jmp    80025c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800251:	89 34 24             	mov    %esi,(%esp)
  800254:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800257:	4b                   	dec    %ebx
  800258:	85 db                	test   %ebx,%ebx
  80025a:	7f f1                	jg     80024d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800260:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800264:	8b 45 10             	mov    0x10(%ebp),%eax
  800267:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800272:	00 
  800273:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80027c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800280:	e8 53 11 00 00       	call   8013d8 <__umoddi3>
  800285:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800289:	0f be 80 c0 15 80 00 	movsbl 0x8015c0(%eax),%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800296:	83 c4 3c             	add    $0x3c,%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a1:	83 fa 01             	cmp    $0x1,%edx
  8002a4:	7e 0e                	jle    8002b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	eb 22                	jmp    8002d6 <getuint+0x38>
	else if (lflag)
  8002b4:	85 d2                	test   %edx,%edx
  8002b6:	74 10                	je     8002c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bd:	89 08                	mov    %ecx,(%eax)
  8002bf:	8b 02                	mov    (%edx),%eax
  8002c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c6:	eb 0e                	jmp    8002d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002de:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e1:	8b 10                	mov    (%eax),%edx
  8002e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e6:	73 08                	jae    8002f0 <sprintputch+0x18>
		*b->buf++ = ch;
  8002e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002eb:	88 0a                	mov    %cl,(%edx)
  8002ed:	42                   	inc    %edx
  8002ee:	89 10                	mov    %edx,(%eax)
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	8b 45 0c             	mov    0xc(%ebp),%eax
  800309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030d:	8b 45 08             	mov    0x8(%ebp),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	e8 02 00 00 00       	call   80031a <vprintfmt>
	va_end(ap);
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 4c             	sub    $0x4c,%esp
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800326:	8b 75 10             	mov    0x10(%ebp),%esi
  800329:	eb 12                	jmp    80033d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032b:	85 c0                	test   %eax,%eax
  80032d:	0f 84 6b 03 00 00    	je     80069e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800333:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033d:	0f b6 06             	movzbl (%esi),%eax
  800340:	46                   	inc    %esi
  800341:	83 f8 25             	cmp    $0x25,%eax
  800344:	75 e5                	jne    80032b <vprintfmt+0x11>
  800346:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80034a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800351:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800356:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	eb 26                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800367:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80036b:	eb 1d                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800370:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800374:	eb 14                	jmp    80038a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800379:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800380:	eb 08                	jmp    80038a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800382:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800385:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	0f b6 06             	movzbl (%esi),%eax
  80038d:	8d 56 01             	lea    0x1(%esi),%edx
  800390:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800393:	8a 16                	mov    (%esi),%dl
  800395:	83 ea 23             	sub    $0x23,%edx
  800398:	80 fa 55             	cmp    $0x55,%dl
  80039b:	0f 87 e1 02 00 00    	ja     800682 <vprintfmt+0x368>
  8003a1:	0f b6 d2             	movzbl %dl,%edx
  8003a4:	ff 24 95 00 17 80 00 	jmp    *0x801700(,%edx,4)
  8003ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003ae:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003b6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003bd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003c0:	83 fa 09             	cmp    $0x9,%edx
  8003c3:	77 2a                	ja     8003ef <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb eb                	jmp    8003b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 17                	jmp    8003ef <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003dc:	78 98                	js     800376 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003e1:	eb a7                	jmp    80038a <vprintfmt+0x70>
  8003e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003ed:	eb 9b                	jmp    80038a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8003ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f3:	79 95                	jns    80038a <vprintfmt+0x70>
  8003f5:	eb 8b                	jmp    800382 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fb:	eb 8d                	jmp    80038a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 50 04             	lea    0x4(%eax),%edx
  800403:	89 55 14             	mov    %edx,0x14(%ebp)
  800406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800415:	e9 23 ff ff ff       	jmp    80033d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	79 02                	jns    80042b <vprintfmt+0x111>
  800429:	f7 d8                	neg    %eax
  80042b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042d:	83 f8 0f             	cmp    $0xf,%eax
  800430:	7f 0b                	jg     80043d <vprintfmt+0x123>
  800432:	8b 04 85 60 18 80 00 	mov    0x801860(,%eax,4),%eax
  800439:	85 c0                	test   %eax,%eax
  80043b:	75 23                	jne    800460 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80043d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800441:	c7 44 24 08 d8 15 80 	movl   $0x8015d8,0x8(%esp)
  800448:	00 
  800449:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
  800450:	89 04 24             	mov    %eax,(%esp)
  800453:	e8 9a fe ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 dd fe ff ff       	jmp    80033d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800464:	c7 44 24 08 e1 15 80 	movl   $0x8015e1,0x8(%esp)
  80046b:	00 
  80046c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800470:	8b 55 08             	mov    0x8(%ebp),%edx
  800473:	89 14 24             	mov    %edx,(%esp)
  800476:	e8 77 fe ff ff       	call   8002f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80047e:	e9 ba fe ff ff       	jmp    80033d <vprintfmt+0x23>
  800483:	89 f9                	mov    %edi,%ecx
  800485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 30                	mov    (%eax),%esi
  800496:	85 f6                	test   %esi,%esi
  800498:	75 05                	jne    80049f <vprintfmt+0x185>
				p = "(null)";
  80049a:	be d1 15 80 00       	mov    $0x8015d1,%esi
			if (width > 0 && padc != '-')
  80049f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a3:	0f 8e 84 00 00 00    	jle    80052d <vprintfmt+0x213>
  8004a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004ad:	74 7e                	je     80052d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b3:	89 34 24             	mov    %esi,(%esp)
  8004b6:	e8 8b 02 00 00       	call   800746 <strnlen>
  8004bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004cd:	89 de                	mov    %ebx,%esi
  8004cf:	89 d3                	mov    %edx,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	eb 0b                	jmp    8004e0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d9:	89 3c 24             	mov    %edi,(%esp)
  8004dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	4b                   	dec    %ebx
  8004e0:	85 db                	test   %ebx,%ebx
  8004e2:	7f f1                	jg     8004d5 <vprintfmt+0x1bb>
  8004e4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004e7:	89 f3                	mov    %esi,%ebx
  8004e9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8004ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	79 05                	jns    8004f8 <vprintfmt+0x1de>
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004fb:	29 c2                	sub    %eax,%edx
  8004fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800500:	eb 2b                	jmp    80052d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800506:	74 18                	je     800520 <vprintfmt+0x206>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 10                	jbe    800520 <vprintfmt+0x206>
					putch('?', putdat);
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
  80051e:	eb 0a                	jmp    80052a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	89 04 24             	mov    %eax,(%esp)
  800527:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052a:	ff 4d e4             	decl   -0x1c(%ebp)
  80052d:	0f be 06             	movsbl (%esi),%eax
  800530:	46                   	inc    %esi
  800531:	85 c0                	test   %eax,%eax
  800533:	74 21                	je     800556 <vprintfmt+0x23c>
  800535:	85 ff                	test   %edi,%edi
  800537:	78 c9                	js     800502 <vprintfmt+0x1e8>
  800539:	4f                   	dec    %edi
  80053a:	79 c6                	jns    800502 <vprintfmt+0x1e8>
  80053c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80053f:	89 de                	mov    %ebx,%esi
  800541:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800544:	eb 18                	jmp    80055e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800546:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800551:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	4b                   	dec    %ebx
  800554:	eb 08                	jmp    80055e <vprintfmt+0x244>
  800556:	8b 7d 08             	mov    0x8(%ebp),%edi
  800559:	89 de                	mov    %ebx,%esi
  80055b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80055e:	85 db                	test   %ebx,%ebx
  800560:	7f e4                	jg     800546 <vprintfmt+0x22c>
  800562:	89 7d 08             	mov    %edi,0x8(%ebp)
  800565:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056a:	e9 ce fd ff ff       	jmp    80033d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 f9 01             	cmp    $0x1,%ecx
  800572:	7e 10                	jle    800584 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 30                	mov    (%eax),%esi
  80057f:	8b 78 04             	mov    0x4(%eax),%edi
  800582:	eb 26                	jmp    8005aa <vprintfmt+0x290>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	74 12                	je     80059a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 30                	mov    (%eax),%esi
  800593:	89 f7                	mov    %esi,%edi
  800595:	c1 ff 1f             	sar    $0x1f,%edi
  800598:	eb 10                	jmp    8005aa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 30                	mov    (%eax),%esi
  8005a5:	89 f7                	mov    %esi,%edi
  8005a7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	78 0a                	js     8005b8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	e9 8c 00 00 00       	jmp    800644 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005c6:	f7 de                	neg    %esi
  8005c8:	83 d7 00             	adc    $0x0,%edi
  8005cb:	f7 df                	neg    %edi
			}
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	eb 70                	jmp    800644 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 c0 fc ff ff       	call   80029e <getuint>
  8005de:	89 c6                	mov    %eax,%esi
  8005e0:	89 d7                	mov    %edx,%edi
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e7:	eb 5b                	jmp    800644 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8005e9:	89 ca                	mov    %ecx,%edx
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 ab fc ff ff       	call   80029e <getuint>
  8005f3:	89 c6                	mov    %eax,%esi
  8005f5:	89 d7                	mov    %edx,%edi
			base = 8;
  8005f7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005fc:	eb 46                	jmp    800644 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800609:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800610:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 30                	mov    (%eax),%esi
  800625:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062f:	eb 13                	jmp    800644 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 63 fc ff ff       	call   80029e <getuint>
  80063b:	89 c6                	mov    %eax,%esi
  80063d:	89 d7                	mov    %edx,%edi
			base = 16;
  80063f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800644:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800648:	89 54 24 10          	mov    %edx,0x10(%esp)
  80064c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800653:	89 44 24 08          	mov    %eax,0x8(%esp)
  800657:	89 34 24             	mov    %esi,(%esp)
  80065a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065e:	89 da                	mov    %ebx,%edx
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	e8 6c fb ff ff       	call   8001d4 <printnum>
			break;
  800668:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066b:	e9 cd fc ff ff       	jmp    80033d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067d:	e9 bb fc ff ff       	jmp    80033d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80068d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800690:	eb 01                	jmp    800693 <vprintfmt+0x379>
  800692:	4e                   	dec    %esi
  800693:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800697:	75 f9                	jne    800692 <vprintfmt+0x378>
  800699:	e9 9f fc ff ff       	jmp    80033d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80069e:	83 c4 4c             	add    $0x4c,%esp
  8006a1:	5b                   	pop    %ebx
  8006a2:	5e                   	pop    %esi
  8006a3:	5f                   	pop    %edi
  8006a4:	5d                   	pop    %ebp
  8006a5:	c3                   	ret    

008006a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	83 ec 28             	sub    $0x28,%esp
  8006ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8006af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	74 30                	je     8006f7 <vsnprintf+0x51>
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	7e 33                	jle    8006fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e0:	c7 04 24 d8 02 80 00 	movl   $0x8002d8,(%esp)
  8006e7:	e8 2e fc ff ff       	call   80031a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	eb 0c                	jmp    800703 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006fc:	eb 05                	jmp    800703 <vsnprintf+0x5d>
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800703:	c9                   	leave  
  800704:	c3                   	ret    

00800705 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 44 24 08          	mov    %eax,0x8(%esp)
  800719:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 7b ff ff ff       	call   8006a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    
  80072d:	00 00                	add    %al,(%eax)
	...

00800730 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800736:	b8 00 00 00 00       	mov    $0x0,%eax
  80073b:	eb 01                	jmp    80073e <strlen+0xe>
		n++;
  80073d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800742:	75 f9                	jne    80073d <strlen+0xd>
		n++;
	return n;
}
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	b8 00 00 00 00       	mov    $0x0,%eax
  800754:	eb 01                	jmp    800757 <strnlen+0x11>
		n++;
  800756:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 06                	je     800761 <strnlen+0x1b>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	75 f5                	jne    800756 <strnlen+0x10>
		n++;
	return n;
}
  800761:	5d                   	pop    %ebp
  800762:	c3                   	ret    

00800763 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	53                   	push   %ebx
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076d:	ba 00 00 00 00       	mov    $0x0,%edx
  800772:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800775:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800778:	42                   	inc    %edx
  800779:	84 c9                	test   %cl,%cl
  80077b:	75 f5                	jne    800772 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80077d:	5b                   	pop    %ebx
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078a:	89 1c 24             	mov    %ebx,(%esp)
  80078d:	e8 9e ff ff ff       	call   800730 <strlen>
	strcpy(dst + len, src);
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 54 24 04          	mov    %edx,0x4(%esp)
  800799:	01 d8                	add    %ebx,%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 c0 ff ff ff       	call   800763 <strcpy>
	return dst;
}
  8007a3:	89 d8                	mov    %ebx,%eax
  8007a5:	83 c4 08             	add    $0x8,%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007be:	eb 0c                	jmp    8007cc <strncpy+0x21>
		*dst++ = *src;
  8007c0:	8a 1a                	mov    (%edx),%bl
  8007c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	41                   	inc    %ecx
  8007cc:	39 f1                	cmp    %esi,%ecx
  8007ce:	75 f0                	jne    8007c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d0:	5b                   	pop    %ebx
  8007d1:	5e                   	pop    %esi
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	56                   	push   %esi
  8007d8:	53                   	push   %ebx
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	75 0a                	jne    8007f0 <strlcpy+0x1c>
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	eb 1a                	jmp    800804 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ea:	88 18                	mov    %bl,(%eax)
  8007ec:	40                   	inc    %eax
  8007ed:	41                   	inc    %ecx
  8007ee:	eb 02                	jmp    8007f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8007f2:	4a                   	dec    %edx
  8007f3:	74 0a                	je     8007ff <strlcpy+0x2b>
  8007f5:	8a 19                	mov    (%ecx),%bl
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	75 ef                	jne    8007ea <strlcpy+0x16>
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	eb 02                	jmp    800801 <strlcpy+0x2d>
  8007ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800801:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800804:	29 f0                	sub    %esi,%eax
}
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800813:	eb 02                	jmp    800817 <strcmp+0xd>
		p++, q++;
  800815:	41                   	inc    %ecx
  800816:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800817:	8a 01                	mov    (%ecx),%al
  800819:	84 c0                	test   %al,%al
  80081b:	74 04                	je     800821 <strcmp+0x17>
  80081d:	3a 02                	cmp    (%edx),%al
  80081f:	74 f4                	je     800815 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800821:	0f b6 c0             	movzbl %al,%eax
  800824:	0f b6 12             	movzbl (%edx),%edx
  800827:	29 d0                	sub    %edx,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800835:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800838:	eb 03                	jmp    80083d <strncmp+0x12>
		n--, p++, q++;
  80083a:	4a                   	dec    %edx
  80083b:	40                   	inc    %eax
  80083c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 14                	je     800855 <strncmp+0x2a>
  800841:	8a 18                	mov    (%eax),%bl
  800843:	84 db                	test   %bl,%bl
  800845:	74 04                	je     80084b <strncmp+0x20>
  800847:	3a 19                	cmp    (%ecx),%bl
  800849:	74 ef                	je     80083a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 11             	movzbl (%ecx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb 05                	jmp    80085a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800866:	eb 05                	jmp    80086d <strchr+0x10>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0c                	je     800878 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	40                   	inc    %eax
  80086d:	8a 10                	mov    (%eax),%dl
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f5                	jne    800868 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800883:	eb 05                	jmp    80088a <strfind+0x10>
		if (*s == c)
  800885:	38 ca                	cmp    %cl,%dl
  800887:	74 07                	je     800890 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800889:	40                   	inc    %eax
  80088a:	8a 10                	mov    (%eax),%dl
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f5                	jne    800885 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a1:	85 c9                	test   %ecx,%ecx
  8008a3:	74 30                	je     8008d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ab:	75 25                	jne    8008d2 <memset+0x40>
  8008ad:	f6 c1 03             	test   $0x3,%cl
  8008b0:	75 20                	jne    8008d2 <memset+0x40>
		c &= 0xFF;
  8008b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b5:	89 d3                	mov    %edx,%ebx
  8008b7:	c1 e3 08             	shl    $0x8,%ebx
  8008ba:	89 d6                	mov    %edx,%esi
  8008bc:	c1 e6 18             	shl    $0x18,%esi
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	c1 e0 10             	shl    $0x10,%eax
  8008c4:	09 f0                	or     %esi,%eax
  8008c6:	09 d0                	or     %edx,%eax
  8008c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008cd:	fc                   	cld    
  8008ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d0:	eb 03                	jmp    8008d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d2:	fc                   	cld    
  8008d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5f                   	pop    %edi
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ea:	39 c6                	cmp    %eax,%esi
  8008ec:	73 34                	jae    800922 <memmove+0x46>
  8008ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f1:	39 d0                	cmp    %edx,%eax
  8008f3:	73 2d                	jae    800922 <memmove+0x46>
		s += n;
		d += n;
  8008f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	f6 c2 03             	test   $0x3,%dl
  8008fb:	75 1b                	jne    800918 <memmove+0x3c>
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 13                	jne    800918 <memmove+0x3c>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 0e                	jne    800918 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80090a:	83 ef 04             	sub    $0x4,%edi
  80090d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800910:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800913:	fd                   	std    
  800914:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800916:	eb 07                	jmp    80091f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800918:	4f                   	dec    %edi
  800919:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091c:	fd                   	std    
  80091d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091f:	fc                   	cld    
  800920:	eb 20                	jmp    800942 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800928:	75 13                	jne    80093d <memmove+0x61>
  80092a:	a8 03                	test   $0x3,%al
  80092c:	75 0f                	jne    80093d <memmove+0x61>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 0a                	jne    80093d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800933:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093b:	eb 05                	jmp    800942 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093d:	89 c7                	mov    %eax,%edi
  80093f:	fc                   	cld    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80094c:	8b 45 10             	mov    0x10(%ebp),%eax
  80094f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 77 ff ff ff       	call   8008dc <memmove>
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	ba 00 00 00 00       	mov    $0x0,%edx
  80097b:	eb 16                	jmp    800993 <memcmp+0x2c>
		if (*s1 != *s2)
  80097d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800980:	42                   	inc    %edx
  800981:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800985:	38 c8                	cmp    %cl,%al
  800987:	74 0a                	je     800993 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800989:	0f b6 c0             	movzbl %al,%eax
  80098c:	0f b6 c9             	movzbl %cl,%ecx
  80098f:	29 c8                	sub    %ecx,%eax
  800991:	eb 09                	jmp    80099c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800993:	39 da                	cmp    %ebx,%edx
  800995:	75 e6                	jne    80097d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800997:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009af:	eb 05                	jmp    8009b6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	38 08                	cmp    %cl,(%eax)
  8009b3:	74 05                	je     8009ba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	40                   	inc    %eax
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	72 f7                	jb     8009b1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	53                   	push   %ebx
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c8:	eb 01                	jmp    8009cb <strtol+0xf>
		s++;
  8009ca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	8a 02                	mov    (%edx),%al
  8009cd:	3c 20                	cmp    $0x20,%al
  8009cf:	74 f9                	je     8009ca <strtol+0xe>
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	74 f5                	je     8009ca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d5:	3c 2b                	cmp    $0x2b,%al
  8009d7:	75 08                	jne    8009e1 <strtol+0x25>
		s++;
  8009d9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009da:	bf 00 00 00 00       	mov    $0x0,%edi
  8009df:	eb 13                	jmp    8009f4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e1:	3c 2d                	cmp    $0x2d,%al
  8009e3:	75 0a                	jne    8009ef <strtol+0x33>
		s++, neg = 1;
  8009e5:	8d 52 01             	lea    0x1(%edx),%edx
  8009e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ed:	eb 05                	jmp    8009f4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	85 db                	test   %ebx,%ebx
  8009f6:	74 05                	je     8009fd <strtol+0x41>
  8009f8:	83 fb 10             	cmp    $0x10,%ebx
  8009fb:	75 28                	jne    800a25 <strtol+0x69>
  8009fd:	8a 02                	mov    (%edx),%al
  8009ff:	3c 30                	cmp    $0x30,%al
  800a01:	75 10                	jne    800a13 <strtol+0x57>
  800a03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a07:	75 0a                	jne    800a13 <strtol+0x57>
		s += 2, base = 16;
  800a09:	83 c2 02             	add    $0x2,%edx
  800a0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a11:	eb 12                	jmp    800a25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a13:	85 db                	test   %ebx,%ebx
  800a15:	75 0e                	jne    800a25 <strtol+0x69>
  800a17:	3c 30                	cmp    $0x30,%al
  800a19:	75 05                	jne    800a20 <strtol+0x64>
		s++, base = 8;
  800a1b:	42                   	inc    %edx
  800a1c:	b3 08                	mov    $0x8,%bl
  800a1e:	eb 05                	jmp    800a25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2c:	8a 0a                	mov    (%edx),%cl
  800a2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a31:	80 fb 09             	cmp    $0x9,%bl
  800a34:	77 08                	ja     800a3e <strtol+0x82>
			dig = *s - '0';
  800a36:	0f be c9             	movsbl %cl,%ecx
  800a39:	83 e9 30             	sub    $0x30,%ecx
  800a3c:	eb 1e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a41:	80 fb 19             	cmp    $0x19,%bl
  800a44:	77 08                	ja     800a4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a46:	0f be c9             	movsbl %cl,%ecx
  800a49:	83 e9 57             	sub    $0x57,%ecx
  800a4c:	eb 0e                	jmp    800a5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 12                	ja     800a68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a56:	0f be c9             	movsbl %cl,%ecx
  800a59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5c:	39 f1                	cmp    %esi,%ecx
  800a5e:	7d 0c                	jge    800a6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a60:	42                   	inc    %edx
  800a61:	0f af c6             	imul   %esi,%eax
  800a64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a66:	eb c4                	jmp    800a2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a68:	89 c1                	mov    %eax,%ecx
  800a6a:	eb 02                	jmp    800a6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a72:	74 05                	je     800a79 <strtol+0xbd>
		*endptr = (char *) s;
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	74 04                	je     800a81 <strtol+0xc5>
  800a7d:	89 c8                	mov    %ecx,%eax
  800a7f:	f7 d8                	neg    %eax
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    
	...

00800a88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a96:	8b 55 08             	mov    0x8(%ebp),%edx
  800a99:	89 c3                	mov    %eax,%ebx
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	89 c6                	mov    %eax,%esi
  800a9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ab6:	89 d1                	mov    %edx,%ecx
  800ab8:	89 d3                	mov    %edx,%ebx
  800aba:	89 d7                	mov    %edx,%edi
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ace:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 cb                	mov    %ecx,%ebx
  800add:	89 cf                	mov    %ecx,%edi
  800adf:	89 ce                	mov    %ecx,%esi
  800ae1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	7e 28                	jle    800b0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aeb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800af2:	00 
  800af3:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800afa:	00 
  800afb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b02:	00 
  800b03:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800b0a:	e8 b9 06 00 00       	call   8011c8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0f:	83 c4 2c             	add    $0x2c,%esp
  800b12:	5b                   	pop    %ebx
  800b13:	5e                   	pop    %esi
  800b14:	5f                   	pop    %edi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 02 00 00 00       	mov    $0x2,%eax
  800b27:	89 d1                	mov    %edx,%ecx
  800b29:	89 d3                	mov    %edx,%ebx
  800b2b:	89 d7                	mov    %edx,%edi
  800b2d:	89 d6                	mov    %edx,%esi
  800b2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_yield>:

void
sys_yield(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	be 00 00 00 00       	mov    $0x0,%esi
  800b63:	b8 04 00 00 00       	mov    $0x4,%eax
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 f7                	mov    %esi,%edi
  800b73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 28                	jle    800ba1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b84:	00 
  800b85:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b94:	00 
  800b95:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800b9c:	e8 27 06 00 00       	call   8011c8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba1:	83 c4 2c             	add    $0x2c,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 28                	jle    800bf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800bdf:	00 
  800be0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be7:	00 
  800be8:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800bef:	e8 d4 05 00 00       	call   8011c8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	83 c4 2c             	add    $0x2c,%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 28                	jle    800c47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800c42:	e8 81 05 00 00       	call   8011c8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	83 c4 2c             	add    $0x2c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	89 df                	mov    %ebx,%edi
  800c6a:	89 de                	mov    %ebx,%esi
  800c6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	7e 28                	jle    800c9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c7d:	00 
  800c7e:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800c85:	00 
  800c86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8d:	00 
  800c8e:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800c95:	e8 2e 05 00 00       	call   8011c8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	83 c4 2c             	add    $0x2c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 28                	jle    800ced <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd0:	00 
  800cd1:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800cd8:	00 
  800cd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce0:	00 
  800ce1:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800ce8:	e8 db 04 00 00       	call   8011c8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ced:	83 c4 2c             	add    $0x2c,%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 df                	mov    %ebx,%edi
  800d10:	89 de                	mov    %ebx,%esi
  800d12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d14:	85 c0                	test   %eax,%eax
  800d16:	7e 28                	jle    800d40 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d23:	00 
  800d24:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800d2b:	00 
  800d2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d33:	00 
  800d34:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800d3b:	e8 88 04 00 00       	call   8011c8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	83 c4 2c             	add    $0x2c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 bf 18 80 	movl   $0x8018bf,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 dc 18 80 00 	movl   $0x8018dc,(%esp)
  800db0:	e8 13 04 00 00       	call   8011c8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	00 00                	add    %al,(%eax)
	...

00800dc0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 24             	sub    $0x24,%esp
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dca:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800dcc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dd0:	75 20                	jne    800df2 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800dd2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dd6:	c7 44 24 08 ec 18 80 	movl   $0x8018ec,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  800ded:	e8 d6 03 00 00       	call   8011c8 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800df2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800dfd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e04:	f6 c4 08             	test   $0x8,%ah
  800e07:	75 1c                	jne    800e25 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800e09:	c7 44 24 08 1c 19 80 	movl   $0x80191c,0x8(%esp)
  800e10:	00 
  800e11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e18:	00 
  800e19:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  800e20:	e8 a3 03 00 00       	call   8011c8 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800e25:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e2c:	00 
  800e2d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e34:	00 
  800e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3c:	e8 14 fd ff ff       	call   800b55 <sys_page_alloc>
  800e41:	85 c0                	test   %eax,%eax
  800e43:	79 20                	jns    800e65 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800e45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e49:	c7 44 24 08 77 19 80 	movl   $0x801977,0x8(%esp)
  800e50:	00 
  800e51:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800e58:	00 
  800e59:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  800e60:	e8 63 03 00 00       	call   8011c8 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800e65:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e6c:	00 
  800e6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e71:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e78:	e8 5f fa ff ff       	call   8008dc <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e7d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e84:	00 
  800e85:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e89:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea0:	e8 04 fd ff ff       	call   800ba9 <sys_page_map>
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	79 20                	jns    800ec9 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ead:	c7 44 24 08 8b 19 80 	movl   $0x80198b,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  800ec4:	e8 ff 02 00 00       	call   8011c8 <_panic>

}
  800ec9:	83 c4 24             	add    $0x24,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
  800ed5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800ed8:	c7 04 24 c0 0d 80 00 	movl   $0x800dc0,(%esp)
  800edf:	e8 3c 03 00 00       	call   801220 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ee4:	ba 07 00 00 00       	mov    $0x7,%edx
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	cd 30                	int    $0x30
  800eed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800ef0:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	79 20                	jns    800f17 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800ef7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efb:	c7 44 24 08 9d 19 80 	movl   $0x80199d,0x8(%esp)
  800f02:	00 
  800f03:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  800f0a:	00 
  800f0b:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  800f12:	e8 b1 02 00 00       	call   8011c8 <_panic>
	if (child_envid == 0) { // child
  800f17:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f1b:	75 25                	jne    800f42 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800f1d:	e8 f5 fb ff ff       	call   800b17 <sys_getenvid>
  800f22:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f2e:	c1 e0 07             	shl    $0x7,%eax
  800f31:	29 d0                	sub    %edx,%eax
  800f33:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f38:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f3d:	e9 58 02 00 00       	jmp    80119a <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800f42:	bf 00 00 00 00       	mov    $0x0,%edi
  800f47:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800f4c:	89 f0                	mov    %esi,%eax
  800f4e:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f51:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f58:	a8 01                	test   $0x1,%al
  800f5a:	0f 84 7a 01 00 00    	je     8010da <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800f60:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800f67:	a8 01                	test   $0x1,%al
  800f69:	0f 84 6b 01 00 00    	je     8010da <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  800f6f:	a1 04 20 80 00       	mov    0x802004,%eax
  800f74:	8b 40 48             	mov    0x48(%eax),%eax
  800f77:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  800f7a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f81:	f6 c4 04             	test   $0x4,%ah
  800f84:	74 52                	je     800fd8 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  800f86:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f8d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f92:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f96:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fa5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 f9 fb ff ff       	call   800ba9 <sys_page_map>
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	0f 89 22 01 00 00    	jns    8010da <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  800fb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fbc:	c7 44 24 08 8b 19 80 	movl   $0x80198b,0x8(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  800fcb:	00 
  800fcc:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  800fd3:	e8 f0 01 00 00       	call   8011c8 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  800fd8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fdf:	f6 c4 08             	test   $0x8,%ah
  800fe2:	75 0f                	jne    800ff3 <fork+0x124>
  800fe4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800feb:	a8 02                	test   $0x2,%al
  800fed:	0f 84 99 00 00 00    	je     80108c <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  800ff3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffa:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  800ffd:	83 f8 01             	cmp    $0x1,%eax
  801000:	19 db                	sbb    %ebx,%ebx
  801002:	83 e3 fc             	and    $0xfffffffc,%ebx
  801005:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80100b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80100f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801013:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801016:	89 44 24 08          	mov    %eax,0x8(%esp)
  80101a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80101e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 80 fb ff ff       	call   800ba9 <sys_page_map>
  801029:	85 c0                	test   %eax,%eax
  80102b:	79 20                	jns    80104d <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  80102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801031:	c7 44 24 08 8b 19 80 	movl   $0x80198b,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  801048:	e8 7b 01 00 00       	call   8011c8 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80104d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801051:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801058:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801060:	89 04 24             	mov    %eax,(%esp)
  801063:	e8 41 fb ff ff       	call   800ba9 <sys_page_map>
  801068:	85 c0                	test   %eax,%eax
  80106a:	79 6e                	jns    8010da <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80106c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801070:	c7 44 24 08 8b 19 80 	movl   $0x80198b,0x8(%esp)
  801077:	00 
  801078:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  801087:	e8 3c 01 00 00       	call   8011c8 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80108c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801093:	25 07 0e 00 00       	and    $0xe07,%eax
  801098:	89 44 24 10          	mov    %eax,0x10(%esp)
  80109c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ae:	89 04 24             	mov    %eax,(%esp)
  8010b1:	e8 f3 fa ff ff       	call   800ba9 <sys_page_map>
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 20                	jns    8010da <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010be:	c7 44 24 08 8b 19 80 	movl   $0x80198b,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  8010d5:	e8 ee 00 00 00       	call   8011c8 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8010da:	46                   	inc    %esi
  8010db:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010e1:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8010e7:	0f 85 5f fe ff ff    	jne    800f4c <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8010ed:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010f4:	00 
  8010f5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010fc:	ee 
  8010fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801100:	89 04 24             	mov    %eax,(%esp)
  801103:	e8 4d fa ff ff       	call   800b55 <sys_page_alloc>
  801108:	85 c0                	test   %eax,%eax
  80110a:	79 20                	jns    80112c <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  80110c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801110:	c7 44 24 08 77 19 80 	movl   $0x801977,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  801127:	e8 9c 00 00 00       	call   8011c8 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  80112c:	c7 44 24 04 94 12 80 	movl   $0x801294,0x4(%esp)
  801133:	00 
  801134:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	e8 b6 fb ff ff       	call   800cf5 <sys_env_set_pgfault_upcall>
  80113f:	85 c0                	test   %eax,%eax
  801141:	79 20                	jns    801163 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801143:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801147:	c7 44 24 08 4c 19 80 	movl   $0x80194c,0x8(%esp)
  80114e:	00 
  80114f:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801156:	00 
  801157:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  80115e:	e8 65 00 00 00       	call   8011c8 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801163:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80116a:	00 
  80116b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80116e:	89 04 24             	mov    %eax,(%esp)
  801171:	e8 d9 fa ff ff       	call   800c4f <sys_env_set_status>
  801176:	85 c0                	test   %eax,%eax
  801178:	79 20                	jns    80119a <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  80117a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117e:	c7 44 24 08 ae 19 80 	movl   $0x8019ae,0x8(%esp)
  801185:	00 
  801186:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80118d:	00 
  80118e:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  801195:	e8 2e 00 00 00       	call   8011c8 <_panic>

	return child_envid;
}
  80119a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80119d:	83 c4 3c             	add    $0x3c,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011ab:	c7 44 24 08 c6 19 80 	movl   $0x8019c6,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  8011c2:	e8 01 00 00 00       	call   8011c8 <_panic>
	...

008011c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011d0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011d3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8011d9:	e8 39 f9 ff ff       	call   800b17 <sys_getenvid>
  8011de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f4:	c7 04 24 dc 19 80 00 	movl   $0x8019dc,(%esp)
  8011fb:	e8 b8 ef ff ff       	call   8001b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801200:	89 74 24 04          	mov    %esi,0x4(%esp)
  801204:	8b 45 10             	mov    0x10(%ebp),%eax
  801207:	89 04 24             	mov    %eax,(%esp)
  80120a:	e8 48 ef ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  80120f:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  801216:	e8 9d ef ff ff       	call   8001b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80121b:	cc                   	int3   
  80121c:	eb fd                	jmp    80121b <_panic+0x53>
	...

00801220 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801226:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80122d:	75 58                	jne    801287 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80122f:	a1 04 20 80 00       	mov    0x802004,%eax
  801234:	8b 40 48             	mov    0x48(%eax),%eax
  801237:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801246:	ee 
  801247:	89 04 24             	mov    %eax,(%esp)
  80124a:	e8 06 f9 ff ff       	call   800b55 <sys_page_alloc>
  80124f:	85 c0                	test   %eax,%eax
  801251:	74 1c                	je     80126f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801253:	c7 44 24 08 00 1a 80 	movl   $0x801a00,0x8(%esp)
  80125a:	00 
  80125b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801262:	00 
  801263:	c7 04 24 15 1a 80 00 	movl   $0x801a15,(%esp)
  80126a:	e8 59 ff ff ff       	call   8011c8 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80126f:	a1 04 20 80 00       	mov    0x802004,%eax
  801274:	8b 40 48             	mov    0x48(%eax),%eax
  801277:	c7 44 24 04 94 12 80 	movl   $0x801294,0x4(%esp)
  80127e:	00 
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 6e fa ff ff       	call   800cf5 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801287:	8b 45 08             	mov    0x8(%ebp),%eax
  80128a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    
  801291:	00 00                	add    %al,(%eax)
	...

00801294 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801294:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801295:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80129a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80129c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80129f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8012a3:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8012a5:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8012a9:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8012aa:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8012ad:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8012af:	58                   	pop    %eax
	popl %eax
  8012b0:	58                   	pop    %eax

	// Pop all registers back
	popal
  8012b1:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8012b2:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8012b5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8012b6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8012b7:	c3                   	ret    

008012b8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8012b8:	55                   	push   %ebp
  8012b9:	57                   	push   %edi
  8012ba:	56                   	push   %esi
  8012bb:	83 ec 10             	sub    $0x10,%esp
  8012be:	8b 74 24 20          	mov    0x20(%esp),%esi
  8012c2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8012c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ca:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8012ce:	89 cd                	mov    %ecx,%ebp
  8012d0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	75 2c                	jne    801304 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8012d8:	39 f9                	cmp    %edi,%ecx
  8012da:	77 68                	ja     801344 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8012dc:	85 c9                	test   %ecx,%ecx
  8012de:	75 0b                	jne    8012eb <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8012e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8012e5:	31 d2                	xor    %edx,%edx
  8012e7:	f7 f1                	div    %ecx
  8012e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	89 f8                	mov    %edi,%eax
  8012ef:	f7 f1                	div    %ecx
  8012f1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8012f3:	89 f0                	mov    %esi,%eax
  8012f5:	f7 f1                	div    %ecx
  8012f7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8012f9:	89 f0                	mov    %esi,%eax
  8012fb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801304:	39 f8                	cmp    %edi,%eax
  801306:	77 2c                	ja     801334 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801308:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80130b:	83 f6 1f             	xor    $0x1f,%esi
  80130e:	75 4c                	jne    80135c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801310:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801312:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801317:	72 0a                	jb     801323 <__udivdi3+0x6b>
  801319:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80131d:	0f 87 ad 00 00 00    	ja     8013d0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801323:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801328:	89 f0                	mov    %esi,%eax
  80132a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801334:	31 ff                	xor    %edi,%edi
  801336:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801338:	89 f0                	mov    %esi,%eax
  80133a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    
  801343:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801344:	89 fa                	mov    %edi,%edx
  801346:	89 f0                	mov    %esi,%eax
  801348:	f7 f1                	div    %ecx
  80134a:	89 c6                	mov    %eax,%esi
  80134c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80134e:	89 f0                	mov    %esi,%eax
  801350:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    
  801359:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80135c:	89 f1                	mov    %esi,%ecx
  80135e:	d3 e0                	shl    %cl,%eax
  801360:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801364:	b8 20 00 00 00       	mov    $0x20,%eax
  801369:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80136b:	89 ea                	mov    %ebp,%edx
  80136d:	88 c1                	mov    %al,%cl
  80136f:	d3 ea                	shr    %cl,%edx
  801371:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801375:	09 ca                	or     %ecx,%edx
  801377:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80137b:	89 f1                	mov    %esi,%ecx
  80137d:	d3 e5                	shl    %cl,%ebp
  80137f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801383:	89 fd                	mov    %edi,%ebp
  801385:	88 c1                	mov    %al,%cl
  801387:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801389:	89 fa                	mov    %edi,%edx
  80138b:	89 f1                	mov    %esi,%ecx
  80138d:	d3 e2                	shl    %cl,%edx
  80138f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801393:	88 c1                	mov    %al,%cl
  801395:	d3 ef                	shr    %cl,%edi
  801397:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801399:	89 f8                	mov    %edi,%eax
  80139b:	89 ea                	mov    %ebp,%edx
  80139d:	f7 74 24 08          	divl   0x8(%esp)
  8013a1:	89 d1                	mov    %edx,%ecx
  8013a3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8013a5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013a9:	39 d1                	cmp    %edx,%ecx
  8013ab:	72 17                	jb     8013c4 <__udivdi3+0x10c>
  8013ad:	74 09                	je     8013b8 <__udivdi3+0x100>
  8013af:	89 fe                	mov    %edi,%esi
  8013b1:	31 ff                	xor    %edi,%edi
  8013b3:	e9 41 ff ff ff       	jmp    8012f9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8013b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013bc:	89 f1                	mov    %esi,%ecx
  8013be:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8013c0:	39 c2                	cmp    %eax,%edx
  8013c2:	73 eb                	jae    8013af <__udivdi3+0xf7>
		{
		  q0--;
  8013c4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8013c7:	31 ff                	xor    %edi,%edi
  8013c9:	e9 2b ff ff ff       	jmp    8012f9 <__udivdi3+0x41>
  8013ce:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8013d0:	31 f6                	xor    %esi,%esi
  8013d2:	e9 22 ff ff ff       	jmp    8012f9 <__udivdi3+0x41>
	...

008013d8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8013d8:	55                   	push   %ebp
  8013d9:	57                   	push   %edi
  8013da:	56                   	push   %esi
  8013db:	83 ec 20             	sub    $0x20,%esp
  8013de:	8b 44 24 30          	mov    0x30(%esp),%eax
  8013e2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8013e6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8013ea:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8013ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013f2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8013f6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8013f8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8013fa:	85 ed                	test   %ebp,%ebp
  8013fc:	75 16                	jne    801414 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8013fe:	39 f1                	cmp    %esi,%ecx
  801400:	0f 86 a6 00 00 00    	jbe    8014ac <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801406:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801408:	89 d0                	mov    %edx,%eax
  80140a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80140c:	83 c4 20             	add    $0x20,%esp
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801414:	39 f5                	cmp    %esi,%ebp
  801416:	0f 87 ac 00 00 00    	ja     8014c8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80141c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80141f:	83 f0 1f             	xor    $0x1f,%eax
  801422:	89 44 24 10          	mov    %eax,0x10(%esp)
  801426:	0f 84 a8 00 00 00    	je     8014d4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80142c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801430:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801432:	bf 20 00 00 00       	mov    $0x20,%edi
  801437:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80143b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80143f:	89 f9                	mov    %edi,%ecx
  801441:	d3 e8                	shr    %cl,%eax
  801443:	09 e8                	or     %ebp,%eax
  801445:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801449:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80144d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801451:	d3 e0                	shl    %cl,%eax
  801453:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801457:	89 f2                	mov    %esi,%edx
  801459:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80145b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80145f:	d3 e0                	shl    %cl,%eax
  801461:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801465:	8b 44 24 14          	mov    0x14(%esp),%eax
  801469:	89 f9                	mov    %edi,%ecx
  80146b:	d3 e8                	shr    %cl,%eax
  80146d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80146f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801471:	89 f2                	mov    %esi,%edx
  801473:	f7 74 24 18          	divl   0x18(%esp)
  801477:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801479:	f7 64 24 0c          	mull   0xc(%esp)
  80147d:	89 c5                	mov    %eax,%ebp
  80147f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801481:	39 d6                	cmp    %edx,%esi
  801483:	72 67                	jb     8014ec <__umoddi3+0x114>
  801485:	74 75                	je     8014fc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801487:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80148b:	29 e8                	sub    %ebp,%eax
  80148d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80148f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801493:	d3 e8                	shr    %cl,%eax
  801495:	89 f2                	mov    %esi,%edx
  801497:	89 f9                	mov    %edi,%ecx
  801499:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80149b:	09 d0                	or     %edx,%eax
  80149d:	89 f2                	mov    %esi,%edx
  80149f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8014a3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014a5:	83 c4 20             	add    $0x20,%esp
  8014a8:	5e                   	pop    %esi
  8014a9:	5f                   	pop    %edi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8014ac:	85 c9                	test   %ecx,%ecx
  8014ae:	75 0b                	jne    8014bb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8014b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b5:	31 d2                	xor    %edx,%edx
  8014b7:	f7 f1                	div    %ecx
  8014b9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8014bb:	89 f0                	mov    %esi,%eax
  8014bd:	31 d2                	xor    %edx,%edx
  8014bf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014c1:	89 f8                	mov    %edi,%eax
  8014c3:	e9 3e ff ff ff       	jmp    801406 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8014c8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014ca:	83 c4 20             	add    $0x20,%esp
  8014cd:	5e                   	pop    %esi
  8014ce:	5f                   	pop    %edi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    
  8014d1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8014d4:	39 f5                	cmp    %esi,%ebp
  8014d6:	72 04                	jb     8014dc <__umoddi3+0x104>
  8014d8:	39 f9                	cmp    %edi,%ecx
  8014da:	77 06                	ja     8014e2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8014dc:	89 f2                	mov    %esi,%edx
  8014de:	29 cf                	sub    %ecx,%edi
  8014e0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8014e2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8014e4:	83 c4 20             	add    $0x20,%esp
  8014e7:	5e                   	pop    %esi
  8014e8:	5f                   	pop    %edi
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    
  8014eb:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8014ec:	89 d1                	mov    %edx,%ecx
  8014ee:	89 c5                	mov    %eax,%ebp
  8014f0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8014f4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8014f8:	eb 8d                	jmp    801487 <__umoddi3+0xaf>
  8014fa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8014fc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801500:	72 ea                	jb     8014ec <__umoddi3+0x114>
  801502:	89 f1                	mov    %esi,%ecx
  801504:	eb 81                	jmp    801487 <__umoddi3+0xaf>
