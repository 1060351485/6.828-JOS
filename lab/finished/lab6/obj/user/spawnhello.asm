
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
  80003a:	a1 08 50 80 00       	mov    0x805008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  80004d:	e8 96 01 00 00       	call   8001e8 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 5e 2b 80 	movl   $0x802b5e,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 5e 2b 80 00 	movl   $0x802b5e,(%esp)
  800069:	e8 04 14 00 00       	call   801472 <spawnl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("spawn(hello) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 64 2b 80 	movl   $0x802b64,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 7c 2b 80 00 	movl   $0x802b7c,(%esp)
  80008d:	e8 5e 00 00 00       	call   8000f0 <_panic>
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
  8000a2:	e8 a0 0a 00 00       	call   800b47 <sys_getenvid>
  8000a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ac:	c1 e0 07             	shl    $0x7,%eax
  8000af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b4:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	7e 07                	jle    8000c4 <libmain+0x30>
		binaryname = argv[0];
  8000bd:	8b 03                	mov    (%ebx),%eax
  8000bf:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c8:	89 34 24             	mov    %esi,(%esp)
  8000cb:	e8 64 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d0:	e8 07 00 00 00       	call   8000dc <exit>
}
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 07 0a 00 00       	call   800af5 <sys_env_destroy>
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
  8000f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8000f8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000fb:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800101:	e8 41 0a 00 00       	call   800b47 <sys_getenvid>
  800106:	8b 55 0c             	mov    0xc(%ebp),%edx
  800109:	89 54 24 10          	mov    %edx,0x10(%esp)
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800114:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800118:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011c:	c7 04 24 98 2b 80 00 	movl   $0x802b98,(%esp)
  800123:	e8 c0 00 00 00       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800128:	89 74 24 04          	mov    %esi,0x4(%esp)
  80012c:	8b 45 10             	mov    0x10(%ebp),%eax
  80012f:	89 04 24             	mov    %eax,(%esp)
  800132:	e8 50 00 00 00       	call   800187 <vcprintf>
	cprintf("\n");
  800137:	c7 04 24 e7 30 80 00 	movl   $0x8030e7,(%esp)
  80013e:	e8 a5 00 00 00       	call   8001e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800143:	cc                   	int3   
  800144:	eb fd                	jmp    800143 <_panic+0x53>
	...

00800148 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	53                   	push   %ebx
  80014c:	83 ec 14             	sub    $0x14,%esp
  80014f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800152:	8b 03                	mov    (%ebx),%eax
  800154:	8b 55 08             	mov    0x8(%ebp),%edx
  800157:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015b:	40                   	inc    %eax
  80015c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80015e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800163:	75 19                	jne    80017e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800165:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80016c:	00 
  80016d:	8d 43 08             	lea    0x8(%ebx),%eax
  800170:	89 04 24             	mov    %eax,(%esp)
  800173:	e8 40 09 00 00       	call   800ab8 <sys_cputs>
		b->idx = 0;
  800178:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80017e:	ff 43 04             	incl   0x4(%ebx)
}
  800181:	83 c4 14             	add    $0x14,%esp
  800184:	5b                   	pop    %ebx
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 48 01 80 00 	movl   $0x800148,(%esp)
  8001c3:	e8 82 01 00 00       	call   80034a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 d8 08 00 00       	call   800ab8 <sys_cputs>

	return b.cnt;
}
  8001e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 87 ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    
	...

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 3c             	sub    $0x3c,%esp
  80020d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800210:	89 d7                	mov    %edx,%edi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800221:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800224:	85 c0                	test   %eax,%eax
  800226:	75 08                	jne    800230 <printnum+0x2c>
  800228:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022e:	77 57                	ja     800287 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800230:	89 74 24 10          	mov    %esi,0x10(%esp)
  800234:	4b                   	dec    %ebx
  800235:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800240:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800244:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800248:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024f:	00 
  800250:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800253:	89 04 24             	mov    %eax,(%esp)
  800256:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	e8 76 26 00 00       	call   8028d8 <__udivdi3>
  800262:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800266:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80026a:	89 04 24             	mov    %eax,(%esp)
  80026d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800271:	89 fa                	mov    %edi,%edx
  800273:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800276:	e8 89 ff ff ff       	call   800204 <printnum>
  80027b:	eb 0f                	jmp    80028c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800281:	89 34 24             	mov    %esi,(%esp)
  800284:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	4b                   	dec    %ebx
  800288:	85 db                	test   %ebx,%ebx
  80028a:	7f f1                	jg     80027d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800290:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800294:	8b 45 10             	mov    0x10(%ebp),%eax
  800297:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002a2:	00 
  8002a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a6:	89 04 24             	mov    %eax,(%esp)
  8002a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b0:	e8 43 27 00 00       	call   8029f8 <__umoddi3>
  8002b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002b9:	0f be 80 bb 2b 80 00 	movsbl 0x802bbb(%eax),%eax
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002c6:	83 c4 3c             	add    $0x3c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7e 0e                	jle    8002e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	eb 22                	jmp    800306 <getuint+0x38>
	else if (lflag)
  8002e4:	85 d2                	test   %edx,%edx
  8002e6:	74 10                	je     8002f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f6:	eb 0e                	jmp    800306 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800311:	8b 10                	mov    (%eax),%edx
  800313:	3b 50 04             	cmp    0x4(%eax),%edx
  800316:	73 08                	jae    800320 <sprintputch+0x18>
		*b->buf++ = ch;
  800318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031b:	88 0a                	mov    %cl,(%edx)
  80031d:	42                   	inc    %edx
  80031e:	89 10                	mov    %edx,(%eax)
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800328:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032f:	8b 45 10             	mov    0x10(%ebp),%eax
  800332:	89 44 24 08          	mov    %eax,0x8(%esp)
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	e8 02 00 00 00       	call   80034a <vprintfmt>
	va_end(ap);
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
  800350:	83 ec 4c             	sub    $0x4c,%esp
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800356:	8b 75 10             	mov    0x10(%ebp),%esi
  800359:	eb 12                	jmp    80036d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035b:	85 c0                	test   %eax,%eax
  80035d:	0f 84 6b 03 00 00    	je     8006ce <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800363:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800367:	89 04 24             	mov    %eax,(%esp)
  80036a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80036d:	0f b6 06             	movzbl (%esi),%eax
  800370:	46                   	inc    %esi
  800371:	83 f8 25             	cmp    $0x25,%eax
  800374:	75 e5                	jne    80035b <vprintfmt+0x11>
  800376:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80037a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800381:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800386:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80038d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800392:	eb 26                	jmp    8003ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800397:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80039b:	eb 1d                	jmp    8003ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003a4:	eb 14                	jmp    8003ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b0:	eb 08                	jmp    8003ba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	0f b6 06             	movzbl (%esi),%eax
  8003bd:	8d 56 01             	lea    0x1(%esi),%edx
  8003c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003c3:	8a 16                	mov    (%esi),%dl
  8003c5:	83 ea 23             	sub    $0x23,%edx
  8003c8:	80 fa 55             	cmp    $0x55,%dl
  8003cb:	0f 87 e1 02 00 00    	ja     8006b2 <vprintfmt+0x368>
  8003d1:	0f b6 d2             	movzbl %dl,%edx
  8003d4:	ff 24 95 00 2d 80 00 	jmp    *0x802d00(,%edx,4)
  8003db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003e6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003f0:	83 fa 09             	cmp    $0x9,%edx
  8003f3:	77 2a                	ja     80041f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f6:	eb eb                	jmp    8003e3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 50 04             	lea    0x4(%eax),%edx
  8003fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800401:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800406:	eb 17                	jmp    80041f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800408:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040c:	78 98                	js     8003a6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800411:	eb a7                	jmp    8003ba <vprintfmt+0x70>
  800413:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800416:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80041d:	eb 9b                	jmp    8003ba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80041f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800423:	79 95                	jns    8003ba <vprintfmt+0x70>
  800425:	eb 8b                	jmp    8003b2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800427:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042b:	eb 8d                	jmp    8003ba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	89 04 24             	mov    %eax,(%esp)
  80043f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 23 ff ff ff       	jmp    80036d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	79 02                	jns    80045b <vprintfmt+0x111>
  800459:	f7 d8                	neg    %eax
  80045b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045d:	83 f8 11             	cmp    $0x11,%eax
  800460:	7f 0b                	jg     80046d <vprintfmt+0x123>
  800462:	8b 04 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	75 23                	jne    800490 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80046d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800471:	c7 44 24 08 d3 2b 80 	movl   $0x802bd3,0x8(%esp)
  800478:	00 
  800479:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 9a fe ff ff       	call   800322 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048b:	e9 dd fe ff ff       	jmp    80036d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800490:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800494:	c7 44 24 08 1e 2f 80 	movl   $0x802f1e,0x8(%esp)
  80049b:	00 
  80049c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a3:	89 14 24             	mov    %edx,(%esp)
  8004a6:	e8 77 fe ff ff       	call   800322 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ae:	e9 ba fe ff ff       	jmp    80036d <vprintfmt+0x23>
  8004b3:	89 f9                	mov    %edi,%ecx
  8004b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 50 04             	lea    0x4(%eax),%edx
  8004c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c4:	8b 30                	mov    (%eax),%esi
  8004c6:	85 f6                	test   %esi,%esi
  8004c8:	75 05                	jne    8004cf <vprintfmt+0x185>
				p = "(null)";
  8004ca:	be cc 2b 80 00       	mov    $0x802bcc,%esi
			if (width > 0 && padc != '-')
  8004cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004d3:	0f 8e 84 00 00 00    	jle    80055d <vprintfmt+0x213>
  8004d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004dd:	74 7e                	je     80055d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004e3:	89 34 24             	mov    %esi,(%esp)
  8004e6:	e8 8b 02 00 00       	call   800776 <strnlen>
  8004eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004ee:	29 c2                	sub    %eax,%edx
  8004f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004f3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004f7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004fd:	89 de                	mov    %ebx,%esi
  8004ff:	89 d3                	mov    %edx,%ebx
  800501:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	eb 0b                	jmp    800510 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800505:	89 74 24 04          	mov    %esi,0x4(%esp)
  800509:	89 3c 24             	mov    %edi,(%esp)
  80050c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	4b                   	dec    %ebx
  800510:	85 db                	test   %ebx,%ebx
  800512:	7f f1                	jg     800505 <vprintfmt+0x1bb>
  800514:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800517:	89 f3                	mov    %esi,%ebx
  800519:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80051c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	79 05                	jns    800528 <vprintfmt+0x1de>
  800523:	b8 00 00 00 00       	mov    $0x0,%eax
  800528:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052b:	29 c2                	sub    %eax,%edx
  80052d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800530:	eb 2b                	jmp    80055d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800532:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800536:	74 18                	je     800550 <vprintfmt+0x206>
  800538:	8d 50 e0             	lea    -0x20(%eax),%edx
  80053b:	83 fa 5e             	cmp    $0x5e,%edx
  80053e:	76 10                	jbe    800550 <vprintfmt+0x206>
					putch('?', putdat);
  800540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800544:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80054b:	ff 55 08             	call   *0x8(%ebp)
  80054e:	eb 0a                	jmp    80055a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800554:	89 04 24             	mov    %eax,(%esp)
  800557:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	ff 4d e4             	decl   -0x1c(%ebp)
  80055d:	0f be 06             	movsbl (%esi),%eax
  800560:	46                   	inc    %esi
  800561:	85 c0                	test   %eax,%eax
  800563:	74 21                	je     800586 <vprintfmt+0x23c>
  800565:	85 ff                	test   %edi,%edi
  800567:	78 c9                	js     800532 <vprintfmt+0x1e8>
  800569:	4f                   	dec    %edi
  80056a:	79 c6                	jns    800532 <vprintfmt+0x1e8>
  80056c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056f:	89 de                	mov    %ebx,%esi
  800571:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800574:	eb 18                	jmp    80058e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800576:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800581:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800583:	4b                   	dec    %ebx
  800584:	eb 08                	jmp    80058e <vprintfmt+0x244>
  800586:	8b 7d 08             	mov    0x8(%ebp),%edi
  800589:	89 de                	mov    %ebx,%esi
  80058b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80058e:	85 db                	test   %ebx,%ebx
  800590:	7f e4                	jg     800576 <vprintfmt+0x22c>
  800592:	89 7d 08             	mov    %edi,0x8(%ebp)
  800595:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059a:	e9 ce fd ff ff       	jmp    80036d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059f:	83 f9 01             	cmp    $0x1,%ecx
  8005a2:	7e 10                	jle    8005b4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 08             	lea    0x8(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 30                	mov    (%eax),%esi
  8005af:	8b 78 04             	mov    0x4(%eax),%edi
  8005b2:	eb 26                	jmp    8005da <vprintfmt+0x290>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 12                	je     8005ca <vprintfmt+0x280>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 30                	mov    (%eax),%esi
  8005c3:	89 f7                	mov    %esi,%edi
  8005c5:	c1 ff 1f             	sar    $0x1f,%edi
  8005c8:	eb 10                	jmp    8005da <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 30                	mov    (%eax),%esi
  8005d5:	89 f7                	mov    %esi,%edi
  8005d7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005da:	85 ff                	test   %edi,%edi
  8005dc:	78 0a                	js     8005e8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 8c 00 00 00       	jmp    800674 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f6:	f7 de                	neg    %esi
  8005f8:	83 d7 00             	adc    $0x0,%edi
  8005fb:	f7 df                	neg    %edi
			}
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800602:	eb 70                	jmp    800674 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800604:	89 ca                	mov    %ecx,%edx
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 c0 fc ff ff       	call   8002ce <getuint>
  80060e:	89 c6                	mov    %eax,%esi
  800610:	89 d7                	mov    %edx,%edi
			base = 10;
  800612:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800617:	eb 5b                	jmp    800674 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800619:	89 ca                	mov    %ecx,%edx
  80061b:	8d 45 14             	lea    0x14(%ebp),%eax
  80061e:	e8 ab fc ff ff       	call   8002ce <getuint>
  800623:	89 c6                	mov    %eax,%esi
  800625:	89 d7                	mov    %edx,%edi
			base = 8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80062c:	eb 46                	jmp    800674 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80062e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800632:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80063c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800640:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800647:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 50 04             	lea    0x4(%eax),%edx
  800650:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800653:	8b 30                	mov    (%eax),%esi
  800655:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065f:	eb 13                	jmp    800674 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800661:	89 ca                	mov    %ecx,%edx
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 63 fc ff ff       	call   8002ce <getuint>
  80066b:	89 c6                	mov    %eax,%esi
  80066d:	89 d7                	mov    %edx,%edi
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800674:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800678:	89 54 24 10          	mov    %edx,0x10(%esp)
  80067c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800683:	89 44 24 08          	mov    %eax,0x8(%esp)
  800687:	89 34 24             	mov    %esi,(%esp)
  80068a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068e:	89 da                	mov    %ebx,%edx
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	e8 6c fb ff ff       	call   800204 <printnum>
			break;
  800698:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80069b:	e9 cd fc ff ff       	jmp    80036d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	89 04 24             	mov    %eax,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ad:	e9 bb fc ff ff       	jmp    80036d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006bd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c0:	eb 01                	jmp    8006c3 <vprintfmt+0x379>
  8006c2:	4e                   	dec    %esi
  8006c3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006c7:	75 f9                	jne    8006c2 <vprintfmt+0x378>
  8006c9:	e9 9f fc ff ff       	jmp    80036d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	83 c4 4c             	add    $0x4c,%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 28             	sub    $0x28,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 30                	je     800727 <vsnprintf+0x51>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 33                	jle    80072e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800702:	8b 45 10             	mov    0x10(%ebp),%eax
  800705:	89 44 24 08          	mov    %eax,0x8(%esp)
  800709:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800710:	c7 04 24 08 03 80 00 	movl   $0x800308,(%esp)
  800717:	e8 2e fc ff ff       	call   80034a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800725:	eb 0c                	jmp    800733 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072c:	eb 05                	jmp    800733 <vsnprintf+0x5d>
  80072e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	8b 45 0c             	mov    0xc(%ebp),%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 7b ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    
  80075d:	00 00                	add    %al,(%eax)
	...

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
  80076b:	eb 01                	jmp    80076e <strlen+0xe>
		n++;
  80076d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f9                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	b8 00 00 00 00       	mov    $0x0,%eax
  800784:	eb 01                	jmp    800787 <strnlen+0x11>
		n++;
  800786:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	39 d0                	cmp    %edx,%eax
  800789:	74 06                	je     800791 <strnlen+0x1b>
  80078b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80078f:	75 f5                	jne    800786 <strnlen+0x10>
		n++;
	return n;
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007a5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007a8:	42                   	inc    %edx
  8007a9:	84 c9                	test   %cl,%cl
  8007ab:	75 f5                	jne    8007a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ad:	5b                   	pop    %ebx
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ba:	89 1c 24             	mov    %ebx,(%esp)
  8007bd:	e8 9e ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c9:	01 d8                	add    %ebx,%eax
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	e8 c0 ff ff ff       	call   800793 <strcpy>
	return dst;
}
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	83 c4 08             	add    $0x8,%esp
  8007d8:	5b                   	pop    %ebx
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ee:	eb 0c                	jmp    8007fc <strncpy+0x21>
		*dst++ = *src;
  8007f0:	8a 1a                	mov    (%edx),%bl
  8007f2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 3a 01             	cmpb   $0x1,(%edx)
  8007f8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	41                   	inc    %ecx
  8007fc:	39 f1                	cmp    %esi,%ecx
  8007fe:	75 f0                	jne    8007f0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	8b 75 08             	mov    0x8(%ebp),%esi
  80080c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800812:	85 d2                	test   %edx,%edx
  800814:	75 0a                	jne    800820 <strlcpy+0x1c>
  800816:	89 f0                	mov    %esi,%eax
  800818:	eb 1a                	jmp    800834 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081a:	88 18                	mov    %bl,(%eax)
  80081c:	40                   	inc    %eax
  80081d:	41                   	inc    %ecx
  80081e:	eb 02                	jmp    800822 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800820:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800822:	4a                   	dec    %edx
  800823:	74 0a                	je     80082f <strlcpy+0x2b>
  800825:	8a 19                	mov    (%ecx),%bl
  800827:	84 db                	test   %bl,%bl
  800829:	75 ef                	jne    80081a <strlcpy+0x16>
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 02                	jmp    800831 <strlcpy+0x2d>
  80082f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800831:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800834:	29 f0                	sub    %esi,%eax
}
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800843:	eb 02                	jmp    800847 <strcmp+0xd>
		p++, q++;
  800845:	41                   	inc    %ecx
  800846:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800847:	8a 01                	mov    (%ecx),%al
  800849:	84 c0                	test   %al,%al
  80084b:	74 04                	je     800851 <strcmp+0x17>
  80084d:	3a 02                	cmp    (%edx),%al
  80084f:	74 f4                	je     800845 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800851:	0f b6 c0             	movzbl %al,%eax
  800854:	0f b6 12             	movzbl (%edx),%edx
  800857:	29 d0                	sub    %edx,%eax
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800865:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800868:	eb 03                	jmp    80086d <strncmp+0x12>
		n--, p++, q++;
  80086a:	4a                   	dec    %edx
  80086b:	40                   	inc    %eax
  80086c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086d:	85 d2                	test   %edx,%edx
  80086f:	74 14                	je     800885 <strncmp+0x2a>
  800871:	8a 18                	mov    (%eax),%bl
  800873:	84 db                	test   %bl,%bl
  800875:	74 04                	je     80087b <strncmp+0x20>
  800877:	3a 19                	cmp    (%ecx),%bl
  800879:	74 ef                	je     80086a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 00             	movzbl (%eax),%eax
  80087e:	0f b6 11             	movzbl (%ecx),%edx
  800881:	29 d0                	sub    %edx,%eax
  800883:	eb 05                	jmp    80088a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088a:	5b                   	pop    %ebx
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800896:	eb 05                	jmp    80089d <strchr+0x10>
		if (*s == c)
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	74 0c                	je     8008a8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089c:	40                   	inc    %eax
  80089d:	8a 10                	mov    (%eax),%dl
  80089f:	84 d2                	test   %dl,%dl
  8008a1:	75 f5                	jne    800898 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b3:	eb 05                	jmp    8008ba <strfind+0x10>
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 07                	je     8008c0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b9:	40                   	inc    %eax
  8008ba:	8a 10                	mov    (%eax),%dl
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f5                	jne    8008b5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 30                	je     800905 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 25                	jne    800902 <memset+0x40>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 20                	jne    800902 <memset+0x40>
		c &= 0xFF;
  8008e2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e5:	89 d3                	mov    %edx,%ebx
  8008e7:	c1 e3 08             	shl    $0x8,%ebx
  8008ea:	89 d6                	mov    %edx,%esi
  8008ec:	c1 e6 18             	shl    $0x18,%esi
  8008ef:	89 d0                	mov    %edx,%eax
  8008f1:	c1 e0 10             	shl    $0x10,%eax
  8008f4:	09 f0                	or     %esi,%eax
  8008f6:	09 d0                	or     %edx,%eax
  8008f8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008fd:	fc                   	cld    
  8008fe:	f3 ab                	rep stos %eax,%es:(%edi)
  800900:	eb 03                	jmp    800905 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800902:	fc                   	cld    
  800903:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800905:	89 f8                	mov    %edi,%eax
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	57                   	push   %edi
  800910:	56                   	push   %esi
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 75 0c             	mov    0xc(%ebp),%esi
  800917:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091a:	39 c6                	cmp    %eax,%esi
  80091c:	73 34                	jae    800952 <memmove+0x46>
  80091e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800921:	39 d0                	cmp    %edx,%eax
  800923:	73 2d                	jae    800952 <memmove+0x46>
		s += n;
		d += n;
  800925:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800928:	f6 c2 03             	test   $0x3,%dl
  80092b:	75 1b                	jne    800948 <memmove+0x3c>
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 13                	jne    800948 <memmove+0x3c>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 0e                	jne    800948 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093a:	83 ef 04             	sub    $0x4,%edi
  80093d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800940:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800943:	fd                   	std    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 07                	jmp    80094f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800948:	4f                   	dec    %edi
  800949:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094c:	fd                   	std    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094f:	fc                   	cld    
  800950:	eb 20                	jmp    800972 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800958:	75 13                	jne    80096d <memmove+0x61>
  80095a:	a8 03                	test   $0x3,%al
  80095c:	75 0f                	jne    80096d <memmove+0x61>
  80095e:	f6 c1 03             	test   $0x3,%cl
  800961:	75 0a                	jne    80096d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800963:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800966:	89 c7                	mov    %eax,%edi
  800968:	fc                   	cld    
  800969:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096b:	eb 05                	jmp    800972 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	fc                   	cld    
  800970:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80097c:	8b 45 10             	mov    0x10(%ebp),%eax
  80097f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
  800986:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	89 04 24             	mov    %eax,(%esp)
  800990:	e8 77 ff ff ff       	call   80090c <memmove>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	eb 16                	jmp    8009c3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ad:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009b0:	42                   	inc    %edx
  8009b1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009b5:	38 c8                	cmp    %cl,%al
  8009b7:	74 0a                	je     8009c3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009b9:	0f b6 c0             	movzbl %al,%eax
  8009bc:	0f b6 c9             	movzbl %cl,%ecx
  8009bf:	29 c8                	sub    %ecx,%eax
  8009c1:	eb 09                	jmp    8009cc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c3:	39 da                	cmp    %ebx,%edx
  8009c5:	75 e6                	jne    8009ad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009df:	eb 05                	jmp    8009e6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e1:	38 08                	cmp    %cl,(%eax)
  8009e3:	74 05                	je     8009ea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e5:	40                   	inc    %eax
  8009e6:	39 d0                	cmp    %edx,%eax
  8009e8:	72 f7                	jb     8009e1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f8:	eb 01                	jmp    8009fb <strtol+0xf>
		s++;
  8009fa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fb:	8a 02                	mov    (%edx),%al
  8009fd:	3c 20                	cmp    $0x20,%al
  8009ff:	74 f9                	je     8009fa <strtol+0xe>
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f5                	je     8009fa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a05:	3c 2b                	cmp    $0x2b,%al
  800a07:	75 08                	jne    800a11 <strtol+0x25>
		s++;
  800a09:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0f:	eb 13                	jmp    800a24 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a11:	3c 2d                	cmp    $0x2d,%al
  800a13:	75 0a                	jne    800a1f <strtol+0x33>
		s++, neg = 1;
  800a15:	8d 52 01             	lea    0x1(%edx),%edx
  800a18:	bf 01 00 00 00       	mov    $0x1,%edi
  800a1d:	eb 05                	jmp    800a24 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	85 db                	test   %ebx,%ebx
  800a26:	74 05                	je     800a2d <strtol+0x41>
  800a28:	83 fb 10             	cmp    $0x10,%ebx
  800a2b:	75 28                	jne    800a55 <strtol+0x69>
  800a2d:	8a 02                	mov    (%edx),%al
  800a2f:	3c 30                	cmp    $0x30,%al
  800a31:	75 10                	jne    800a43 <strtol+0x57>
  800a33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a37:	75 0a                	jne    800a43 <strtol+0x57>
		s += 2, base = 16;
  800a39:	83 c2 02             	add    $0x2,%edx
  800a3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a41:	eb 12                	jmp    800a55 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a43:	85 db                	test   %ebx,%ebx
  800a45:	75 0e                	jne    800a55 <strtol+0x69>
  800a47:	3c 30                	cmp    $0x30,%al
  800a49:	75 05                	jne    800a50 <strtol+0x64>
		s++, base = 8;
  800a4b:	42                   	inc    %edx
  800a4c:	b3 08                	mov    $0x8,%bl
  800a4e:	eb 05                	jmp    800a55 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a50:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5c:	8a 0a                	mov    (%edx),%cl
  800a5e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a61:	80 fb 09             	cmp    $0x9,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x82>
			dig = *s - '0';
  800a66:	0f be c9             	movsbl %cl,%ecx
  800a69:	83 e9 30             	sub    $0x30,%ecx
  800a6c:	eb 1e                	jmp    800a8c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a6e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 08                	ja     800a7e <strtol+0x92>
			dig = *s - 'a' + 10;
  800a76:	0f be c9             	movsbl %cl,%ecx
  800a79:	83 e9 57             	sub    $0x57,%ecx
  800a7c:	eb 0e                	jmp    800a8c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a7e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 12                	ja     800a98 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a86:	0f be c9             	movsbl %cl,%ecx
  800a89:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a8c:	39 f1                	cmp    %esi,%ecx
  800a8e:	7d 0c                	jge    800a9c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a90:	42                   	inc    %edx
  800a91:	0f af c6             	imul   %esi,%eax
  800a94:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a96:	eb c4                	jmp    800a5c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a98:	89 c1                	mov    %eax,%ecx
  800a9a:	eb 02                	jmp    800a9e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800a9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa2:	74 05                	je     800aa9 <strtol+0xbd>
		*endptr = (char *) s;
  800aa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aa9:	85 ff                	test   %edi,%edi
  800aab:	74 04                	je     800ab1 <strtol+0xc5>
  800aad:	89 c8                	mov    %ecx,%eax
  800aaf:	f7 d8                	neg    %eax
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    
	...

00800ab8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab8:	55                   	push   %ebp
  800ab9:	89 e5                	mov    %esp,%ebp
  800abb:	57                   	push   %edi
  800abc:	56                   	push   %esi
  800abd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	89 c7                	mov    %eax,%edi
  800acd:	89 c6                	mov    %eax,%esi
  800acf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae6:	89 d1                	mov    %edx,%ecx
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	89 d7                	mov    %edx,%edi
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b03:	b8 03 00 00 00       	mov    $0x3,%eax
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	89 cb                	mov    %ecx,%ebx
  800b0d:	89 cf                	mov    %ecx,%edi
  800b0f:	89 ce                	mov    %ecx,%esi
  800b11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b13:	85 c0                	test   %eax,%eax
  800b15:	7e 28                	jle    800b3f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b1b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b22:	00 
  800b23:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800b2a:	00 
  800b2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b32:	00 
  800b33:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800b3a:	e8 b1 f5 ff ff       	call   8000f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3f:	83 c4 2c             	add    $0x2c,%esp
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 02 00 00 00       	mov    $0x2,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_yield>:

void
sys_yield(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	be 00 00 00 00       	mov    $0x0,%esi
  800b93:	b8 04 00 00 00       	mov    $0x4,%eax
  800b98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 f7                	mov    %esi,%edi
  800ba3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7e 28                	jle    800bd1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bb4:	00 
  800bb5:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800bbc:	00 
  800bbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc4:	00 
  800bc5:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800bcc:	e8 1f f5 ff ff       	call   8000f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd1:	83 c4 2c             	add    $0x2c,%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	b8 05 00 00 00       	mov    $0x5,%eax
  800be7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bea:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7e 28                	jle    800c24 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c00:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c07:	00 
  800c08:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800c0f:	00 
  800c10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c17:	00 
  800c18:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800c1f:	e8 cc f4 ff ff       	call   8000f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c24:	83 c4 2c             	add    $0x2c,%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 28                	jle    800c77 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c53:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800c62:	00 
  800c63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6a:	00 
  800c6b:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800c72:	e8 79 f4 ff ff       	call   8000f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c77:	83 c4 2c             	add    $0x2c,%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 28                	jle    800cca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cad:	00 
  800cae:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800cb5:	00 
  800cb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cbd:	00 
  800cbe:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800cc5:	e8 26 f4 ff ff       	call   8000f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cca:	83 c4 2c             	add    $0x2c,%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	89 df                	mov    %ebx,%edi
  800ced:	89 de                	mov    %ebx,%esi
  800cef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 28                	jle    800d1d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d00:	00 
  800d01:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800d08:	00 
  800d09:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d10:	00 
  800d11:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800d18:	e8 d3 f3 ff ff       	call   8000f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1d:	83 c4 2c             	add    $0x2c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 28                	jle    800d70 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d53:	00 
  800d54:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800d5b:	00 
  800d5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d63:	00 
  800d64:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800d6b:	e8 80 f3 ff ff       	call   8000f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d70:	83 c4 2c             	add    $0x2c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	be 00 00 00 00       	mov    $0x0,%esi
  800d83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	89 cb                	mov    %ecx,%ebx
  800db3:	89 cf                	mov    %ecx,%edi
  800db5:	89 ce                	mov    %ecx,%esi
  800db7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 c7 2e 80 	movl   $0x802ec7,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  800de0:	e8 0b f3 ff ff       	call   8000f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de5:	83 c4 2c             	add    $0x2c,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	ba 00 00 00 00       	mov    $0x0,%edx
  800df8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dfd:	89 d1                	mov    %edx,%ecx
  800dff:	89 d3                	mov    %edx,%ebx
  800e01:	89 d7                	mov    %edx,%edi
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e07:	5b                   	pop    %ebx
  800e08:	5e                   	pop    %esi
  800e09:	5f                   	pop    %edi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e17:	b8 10 00 00 00       	mov    $0x10,%eax
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	89 df                	mov    %ebx,%edi
  800e24:	89 de                	mov    %ebx,%esi
  800e26:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e38:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	89 df                	mov    %ebx,%edi
  800e45:	89 de                	mov    %ebx,%esi
  800e47:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e59:	b8 11 00 00 00       	mov    $0x11,%eax
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	89 cb                	mov    %ecx,%ebx
  800e63:	89 cf                	mov    %ecx,%edi
  800e65:	89 ce                	mov    %ecx,%esi
  800e67:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    
	...

00800e70 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  800e7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e83:	00 
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	89 04 24             	mov    %eax,(%esp)
  800e8a:	e8 41 0e 00 00       	call   801cd0 <open>
  800e8f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  800e95:	85 c0                	test   %eax,%eax
  800e97:	0f 88 86 05 00 00    	js     801423 <spawn+0x5b3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  800e9d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800ea4:	00 
  800ea5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800eab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eaf:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  800eb5:	89 04 24             	mov    %eax,(%esp)
  800eb8:	e8 cd 09 00 00       	call   80188a <readn>
  800ebd:	3d 00 02 00 00       	cmp    $0x200,%eax
  800ec2:	75 0c                	jne    800ed0 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  800ec4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  800ecb:	45 4c 46 
  800ece:	74 3b                	je     800f0b <spawn+0x9b>
		close(fd);
  800ed0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  800ed6:	89 04 24             	mov    %eax,(%esp)
  800ed9:	e8 b8 07 00 00       	call   801696 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  800ede:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  800ee5:	46 
  800ee6:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  800eec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef0:	c7 04 24 f2 2e 80 00 	movl   $0x802ef2,(%esp)
  800ef7:	e8 ec f2 ff ff       	call   8001e8 <cprintf>
		return -E_NOT_EXEC;
  800efc:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  800f03:	ff ff ff 
  800f06:	e9 24 05 00 00       	jmp    80142f <spawn+0x5bf>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f0b:	ba 07 00 00 00       	mov    $0x7,%edx
  800f10:	89 d0                	mov    %edx,%eax
  800f12:	cd 30                	int    $0x30
  800f14:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  800f1a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	0f 88 07 05 00 00    	js     80142f <spawn+0x5bf>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  800f28:	89 c6                	mov    %eax,%esi
  800f2a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800f30:	c1 e6 07             	shl    $0x7,%esi
  800f33:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800f39:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  800f3f:	b9 11 00 00 00       	mov    $0x11,%ecx
  800f44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  800f46:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  800f4c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800f52:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  800f57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f5f:	eb 0d                	jmp    800f6e <spawn+0xfe>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  800f61:	89 04 24             	mov    %eax,(%esp)
  800f64:	e8 f7 f7 ff ff       	call   800760 <strlen>
  800f69:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800f6d:	46                   	inc    %esi
  800f6e:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  800f70:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  800f77:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	75 e3                	jne    800f61 <spawn+0xf1>
  800f7e:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  800f84:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  800f8a:	bf 00 10 40 00       	mov    $0x401000,%edi
  800f8f:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  800f91:	89 f8                	mov    %edi,%eax
  800f93:	83 e0 fc             	and    $0xfffffffc,%eax
  800f96:	f7 d2                	not    %edx
  800f98:	8d 14 90             	lea    (%eax,%edx,4),%edx
  800f9b:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  800fa1:	89 d0                	mov    %edx,%eax
  800fa3:	83 e8 08             	sub    $0x8,%eax
  800fa6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  800fab:	0f 86 8f 04 00 00    	jbe    801440 <spawn+0x5d0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800fb1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc8:	e8 b8 fb ff ff       	call   800b85 <sys_page_alloc>
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	0f 88 70 04 00 00    	js     801445 <spawn+0x5d5>
  800fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fda:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  800fe0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe3:	eb 2e                	jmp    801013 <spawn+0x1a3>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  800fe5:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  800feb:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  800ff1:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  800ff4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffb:	89 3c 24             	mov    %edi,(%esp)
  800ffe:	e8 90 f7 ff ff       	call   800793 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801003:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801006:	89 04 24             	mov    %eax,(%esp)
  801009:	e8 52 f7 ff ff       	call   800760 <strlen>
  80100e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801012:	43                   	inc    %ebx
  801013:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801019:	7c ca                	jl     800fe5 <spawn+0x175>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80101b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801021:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801027:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80102e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801034:	74 24                	je     80105a <spawn+0x1ea>
  801036:	c7 44 24 0c 94 2f 80 	movl   $0x802f94,0xc(%esp)
  80103d:	00 
  80103e:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 21 2f 80 00 	movl   $0x802f21,(%esp)
  801055:	e8 96 f0 ff ff       	call   8000f0 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80105a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801060:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801065:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80106b:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80106e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801074:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801077:	89 d0                	mov    %edx,%eax
  801079:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80107e:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801084:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80108b:	00 
  80108c:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801093:	ee 
  801094:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80109a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80109e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8010a5:	00 
  8010a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ad:	e8 27 fb ff ff       	call   800bd9 <sys_page_map>
  8010b2:	89 c3                	mov    %eax,%ebx
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 1a                	js     8010d2 <spawn+0x262>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8010b8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8010bf:	00 
  8010c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c7:	e8 60 fb ff ff       	call   800c2c <sys_page_unmap>
  8010cc:	89 c3                	mov    %eax,%ebx
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	79 1f                	jns    8010f1 <spawn+0x281>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8010d2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8010d9:	00 
  8010da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e1:	e8 46 fb ff ff       	call   800c2c <sys_page_unmap>
	return r;
  8010e6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8010ec:	e9 3e 03 00 00       	jmp    80142f <spawn+0x5bf>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8010f1:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8010f7:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8010fd:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801103:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80110a:	00 00 00 
  80110d:	e9 bb 01 00 00       	jmp    8012cd <spawn+0x45d>
		if (ph->p_type != ELF_PROG_LOAD)
  801112:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801118:	83 38 01             	cmpl   $0x1,(%eax)
  80111b:	0f 85 9f 01 00 00    	jne    8012c0 <spawn+0x450>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801121:	89 c2                	mov    %eax,%edx
  801123:	8b 40 18             	mov    0x18(%eax),%eax
  801126:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801129:	83 f8 01             	cmp    $0x1,%eax
  80112c:	19 c0                	sbb    %eax,%eax
  80112e:	83 e0 fe             	and    $0xfffffffe,%eax
  801131:	83 c0 07             	add    $0x7,%eax
  801134:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80113a:	8b 52 04             	mov    0x4(%edx),%edx
  80113d:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801143:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801149:	8b 40 10             	mov    0x10(%eax),%eax
  80114c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801152:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801158:	8b 52 14             	mov    0x14(%edx),%edx
  80115b:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801161:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801167:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80116a:	89 f8                	mov    %edi,%eax
  80116c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801171:	74 16                	je     801189 <spawn+0x319>
		va -= i;
  801173:	29 c7                	sub    %eax,%edi
		memsz += i;
  801175:	01 c2                	add    %eax,%edx
  801177:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  80117d:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  801183:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	e9 1f 01 00 00       	jmp    8012b2 <spawn+0x442>
		if (i >= filesz) {
  801193:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801199:	77 2b                	ja     8011c6 <spawn+0x356>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80119b:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8011a1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011a9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8011af:	89 04 24             	mov    %eax,(%esp)
  8011b2:	e8 ce f9 ff ff       	call   800b85 <sys_page_alloc>
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	0f 89 e7 00 00 00    	jns    8012a6 <spawn+0x436>
  8011bf:	89 c6                	mov    %eax,%esi
  8011c1:	e9 39 02 00 00       	jmp    8013ff <spawn+0x58f>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8011c6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dd:	e8 a3 f9 ff ff       	call   800b85 <sys_page_alloc>
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	0f 88 0b 02 00 00    	js     8013f5 <spawn+0x585>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8011ea:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  8011f0:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8011f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f6:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8011fc:	89 04 24             	mov    %eax,(%esp)
  8011ff:	e8 5c 07 00 00       	call   801960 <seek>
  801204:	85 c0                	test   %eax,%eax
  801206:	0f 88 ed 01 00 00    	js     8013f9 <spawn+0x589>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80120c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801212:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801214:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801219:	76 05                	jbe    801220 <spawn+0x3b0>
  80121b:	b8 00 10 00 00       	mov    $0x1000,%eax
  801220:	89 44 24 08          	mov    %eax,0x8(%esp)
  801224:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80122b:	00 
  80122c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801232:	89 04 24             	mov    %eax,(%esp)
  801235:	e8 50 06 00 00       	call   80188a <readn>
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 88 bb 01 00 00    	js     8013fd <spawn+0x58d>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801242:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801248:	89 54 24 10          	mov    %edx,0x10(%esp)
  80124c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801250:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801256:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801261:	00 
  801262:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801269:	e8 6b f9 ff ff       	call   800bd9 <sys_page_map>
  80126e:	85 c0                	test   %eax,%eax
  801270:	79 20                	jns    801292 <spawn+0x422>
				panic("spawn: sys_page_map data: %e", r);
  801272:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801276:	c7 44 24 08 2d 2f 80 	movl   $0x802f2d,0x8(%esp)
  80127d:	00 
  80127e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  801285:	00 
  801286:	c7 04 24 21 2f 80 00 	movl   $0x802f21,(%esp)
  80128d:	e8 5e ee ff ff       	call   8000f0 <_panic>
			sys_page_unmap(0, UTEMP);
  801292:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801299:	00 
  80129a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a1:	e8 86 f9 ff ff       	call   800c2c <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8012a6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012ac:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012b2:	89 de                	mov    %ebx,%esi
  8012b4:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8012ba:	0f 82 d3 fe ff ff    	jb     801193 <spawn+0x323>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8012c0:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8012c6:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8012cd:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8012d4:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  8012da:	0f 8c 32 fe ff ff    	jl     801112 <spawn+0x2a2>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8012e0:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 a8 03 00 00       	call   801696 <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  8012ee:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  8012f3:	89 f0                	mov    %esi,%eax
  8012f5:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  8012f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012ff:	a8 01                	test   $0x1,%al
  801301:	0f 84 82 00 00 00    	je     801389 <spawn+0x519>
  801307:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80130e:	a8 01                	test   $0x1,%al
  801310:	74 77                	je     801389 <spawn+0x519>
  801312:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801319:	f6 c4 04             	test   $0x4,%ah
  80131c:	74 6b                	je     801389 <spawn+0x519>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  80131e:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801325:	89 f3                	mov    %esi,%ebx
  801327:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  80132a:	e8 18 f8 ff ff       	call   800b47 <sys_getenvid>
  80132f:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  801335:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801339:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80133d:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801343:	89 54 24 08          	mov    %edx,0x8(%esp)
  801347:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80134b:	89 04 24             	mov    %eax,(%esp)
  80134e:	e8 86 f8 ff ff       	call   800bd9 <sys_page_map>
  801353:	85 c0                	test   %eax,%eax
  801355:	79 32                	jns    801389 <spawn+0x519>
  801357:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  801359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135d:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  801364:	e8 7f ee ff ff       	call   8001e8 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801369:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80136d:	c7 44 24 08 4a 2f 80 	movl   $0x802f4a,0x8(%esp)
  801374:	00 
  801375:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80137c:	00 
  80137d:	c7 04 24 21 2f 80 00 	movl   $0x802f21,(%esp)
  801384:	e8 67 ed ff ff       	call   8000f0 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  801389:	46                   	inc    %esi
  80138a:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  801390:	0f 85 5d ff ff ff    	jne    8012f3 <spawn+0x483>
  801396:	e9 b2 00 00 00       	jmp    80144d <spawn+0x5dd>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  80139b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139f:	c7 44 24 08 60 2f 80 	movl   $0x802f60,0x8(%esp)
  8013a6:	00 
  8013a7:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8013ae:	00 
  8013af:	c7 04 24 21 2f 80 00 	movl   $0x802f21,(%esp)
  8013b6:	e8 35 ed ff ff       	call   8000f0 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8013bb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013c2:	00 
  8013c3:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 ae f8 ff ff       	call   800c7f <sys_env_set_status>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	79 5a                	jns    80142f <spawn+0x5bf>
		panic("sys_env_set_status: %e", r);
  8013d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d9:	c7 44 24 08 7a 2f 80 	movl   $0x802f7a,0x8(%esp)
  8013e0:	00 
  8013e1:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  8013e8:	00 
  8013e9:	c7 04 24 21 2f 80 00 	movl   $0x802f21,(%esp)
  8013f0:	e8 fb ec ff ff       	call   8000f0 <_panic>
  8013f5:	89 c6                	mov    %eax,%esi
  8013f7:	eb 06                	jmp    8013ff <spawn+0x58f>
  8013f9:	89 c6                	mov    %eax,%esi
  8013fb:	eb 02                	jmp    8013ff <spawn+0x58f>
  8013fd:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  8013ff:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801405:	89 04 24             	mov    %eax,(%esp)
  801408:	e8 e8 f6 ff ff       	call   800af5 <sys_env_destroy>
	close(fd);
  80140d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 7b 02 00 00       	call   801696 <close>
	return r;
  80141b:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  801421:	eb 0c                	jmp    80142f <spawn+0x5bf>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801423:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801429:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80142f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801435:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801440:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801445:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80144b:	eb e2                	jmp    80142f <spawn+0x5bf>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80144d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801453:	89 44 24 04          	mov    %eax,0x4(%esp)
  801457:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80145d:	89 04 24             	mov    %eax,(%esp)
  801460:	e8 6d f8 ff ff       	call   800cd2 <sys_env_set_trapframe>
  801465:	85 c0                	test   %eax,%eax
  801467:	0f 89 4e ff ff ff    	jns    8013bb <spawn+0x54b>
  80146d:	e9 29 ff ff ff       	jmp    80139b <spawn+0x52b>

00801472 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	57                   	push   %edi
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  80147b:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  80147e:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801483:	eb 03                	jmp    801488 <spawnl+0x16>
		argc++;
  801485:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801486:	89 d0                	mov    %edx,%eax
  801488:	8d 50 04             	lea    0x4(%eax),%edx
  80148b:	83 38 00             	cmpl   $0x0,(%eax)
  80148e:	75 f5                	jne    801485 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801490:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801497:	83 e0 f0             	and    $0xfffffff0,%eax
  80149a:	29 c4                	sub    %eax,%esp
  80149c:	8d 7c 24 17          	lea    0x17(%esp),%edi
  8014a0:	83 e7 f0             	and    $0xfffffff0,%edi
  8014a3:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  8014a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a8:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  8014aa:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  8014b1:	00 

	va_start(vl, arg0);
  8014b2:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ba:	eb 09                	jmp    8014c5 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  8014bc:	40                   	inc    %eax
  8014bd:	8b 1a                	mov    (%edx),%ebx
  8014bf:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8014c2:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8014c5:	39 c8                	cmp    %ecx,%eax
  8014c7:	75 f3                	jne    8014bc <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8014c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d0:	89 04 24             	mov    %eax,(%esp)
  8014d3:	e8 98 f9 ff ff       	call   800e70 <spawn>
}
  8014d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5f                   	pop    %edi
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	89 04 24             	mov    %eax,(%esp)
  8014fc:	e8 df ff ff ff       	call   8014e0 <fd2num>
  801501:	05 20 00 0d 00       	add    $0xd0020,%eax
  801506:	c1 e0 0c             	shl    $0xc,%eax
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	53                   	push   %ebx
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801512:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801517:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801519:	89 c2                	mov    %eax,%edx
  80151b:	c1 ea 16             	shr    $0x16,%edx
  80151e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801525:	f6 c2 01             	test   $0x1,%dl
  801528:	74 11                	je     80153b <fd_alloc+0x30>
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 ea 0c             	shr    $0xc,%edx
  80152f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	75 09                	jne    801544 <fd_alloc+0x39>
			*fd_store = fd;
  80153b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
  801542:	eb 17                	jmp    80155b <fd_alloc+0x50>
  801544:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801549:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80154e:	75 c7                	jne    801517 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801550:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801556:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80155b:	5b                   	pop    %ebx
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801564:	83 f8 1f             	cmp    $0x1f,%eax
  801567:	77 36                	ja     80159f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801569:	05 00 00 0d 00       	add    $0xd0000,%eax
  80156e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801571:	89 c2                	mov    %eax,%edx
  801573:	c1 ea 16             	shr    $0x16,%edx
  801576:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157d:	f6 c2 01             	test   $0x1,%dl
  801580:	74 24                	je     8015a6 <fd_lookup+0x48>
  801582:	89 c2                	mov    %eax,%edx
  801584:	c1 ea 0c             	shr    $0xc,%edx
  801587:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158e:	f6 c2 01             	test   $0x1,%dl
  801591:	74 1a                	je     8015ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801593:	8b 55 0c             	mov    0xc(%ebp),%edx
  801596:	89 02                	mov    %eax,(%edx)
	return 0;
  801598:	b8 00 00 00 00       	mov    $0x0,%eax
  80159d:	eb 13                	jmp    8015b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80159f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a4:	eb 0c                	jmp    8015b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ab:	eb 05                	jmp    8015b2 <fd_lookup+0x54>
  8015ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c6:	eb 0e                	jmp    8015d6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015c8:	39 08                	cmp    %ecx,(%eax)
  8015ca:	75 09                	jne    8015d5 <dev_lookup+0x21>
			*dev = devtab[i];
  8015cc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d3:	eb 33                	jmp    801608 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015d5:	42                   	inc    %edx
  8015d6:	8b 04 95 64 30 80 00 	mov    0x803064(,%edx,4),%eax
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	75 e7                	jne    8015c8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015e1:	a1 08 50 80 00       	mov    0x805008,%eax
  8015e6:	8b 40 48             	mov    0x48(%eax),%eax
  8015e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f1:	c7 04 24 e8 2f 80 00 	movl   $0x802fe8,(%esp)
  8015f8:	e8 eb eb ff ff       	call   8001e8 <cprintf>
	*dev = 0;
  8015fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801603:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801608:	83 c4 14             	add    $0x14,%esp
  80160b:	5b                   	pop    %ebx
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	56                   	push   %esi
  801612:	53                   	push   %ebx
  801613:	83 ec 30             	sub    $0x30,%esp
  801616:	8b 75 08             	mov    0x8(%ebp),%esi
  801619:	8a 45 0c             	mov    0xc(%ebp),%al
  80161c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80161f:	89 34 24             	mov    %esi,(%esp)
  801622:	e8 b9 fe ff ff       	call   8014e0 <fd2num>
  801627:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80162a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80162e:	89 04 24             	mov    %eax,(%esp)
  801631:	e8 28 ff ff ff       	call   80155e <fd_lookup>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 05                	js     801641 <fd_close+0x33>
	    || fd != fd2)
  80163c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80163f:	74 0d                	je     80164e <fd_close+0x40>
		return (must_exist ? r : 0);
  801641:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801645:	75 46                	jne    80168d <fd_close+0x7f>
  801647:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164c:	eb 3f                	jmp    80168d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80164e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801651:	89 44 24 04          	mov    %eax,0x4(%esp)
  801655:	8b 06                	mov    (%esi),%eax
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 55 ff ff ff       	call   8015b4 <dev_lookup>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	85 c0                	test   %eax,%eax
  801663:	78 18                	js     80167d <fd_close+0x6f>
		if (dev->dev_close)
  801665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801668:	8b 40 10             	mov    0x10(%eax),%eax
  80166b:	85 c0                	test   %eax,%eax
  80166d:	74 09                	je     801678 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80166f:	89 34 24             	mov    %esi,(%esp)
  801672:	ff d0                	call   *%eax
  801674:	89 c3                	mov    %eax,%ebx
  801676:	eb 05                	jmp    80167d <fd_close+0x6f>
		else
			r = 0;
  801678:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80167d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801681:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801688:	e8 9f f5 ff ff       	call   800c2c <sys_page_unmap>
	return r;
}
  80168d:	89 d8                	mov    %ebx,%eax
  80168f:	83 c4 30             	add    $0x30,%esp
  801692:	5b                   	pop    %ebx
  801693:	5e                   	pop    %esi
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80169c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	89 04 24             	mov    %eax,(%esp)
  8016a9:	e8 b0 fe ff ff       	call   80155e <fd_lookup>
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 13                	js     8016c5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016b9:	00 
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 49 ff ff ff       	call   80160e <fd_close>
}
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <close_all>:

void
close_all(void)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ce:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016d3:	89 1c 24             	mov    %ebx,(%esp)
  8016d6:	e8 bb ff ff ff       	call   801696 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016db:	43                   	inc    %ebx
  8016dc:	83 fb 20             	cmp    $0x20,%ebx
  8016df:	75 f2                	jne    8016d3 <close_all+0xc>
		close(i);
}
  8016e1:	83 c4 14             	add    $0x14,%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	57                   	push   %edi
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 4c             	sub    $0x4c,%esp
  8016f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016f3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fd:	89 04 24             	mov    %eax,(%esp)
  801700:	e8 59 fe ff ff       	call   80155e <fd_lookup>
  801705:	89 c3                	mov    %eax,%ebx
  801707:	85 c0                	test   %eax,%eax
  801709:	0f 88 e1 00 00 00    	js     8017f0 <dup+0x109>
		return r;
	close(newfdnum);
  80170f:	89 3c 24             	mov    %edi,(%esp)
  801712:	e8 7f ff ff ff       	call   801696 <close>

	newfd = INDEX2FD(newfdnum);
  801717:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80171d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801720:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801723:	89 04 24             	mov    %eax,(%esp)
  801726:	e8 c5 fd ff ff       	call   8014f0 <fd2data>
  80172b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80172d:	89 34 24             	mov    %esi,(%esp)
  801730:	e8 bb fd ff ff       	call   8014f0 <fd2data>
  801735:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	c1 e8 16             	shr    $0x16,%eax
  80173d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801744:	a8 01                	test   $0x1,%al
  801746:	74 46                	je     80178e <dup+0xa7>
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	c1 e8 0c             	shr    $0xc,%eax
  80174d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801754:	f6 c2 01             	test   $0x1,%dl
  801757:	74 35                	je     80178e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801759:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801760:	25 07 0e 00 00       	and    $0xe07,%eax
  801765:	89 44 24 10          	mov    %eax,0x10(%esp)
  801769:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80176c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801770:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801777:	00 
  801778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80177c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801783:	e8 51 f4 ff ff       	call   800bd9 <sys_page_map>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 3b                	js     8017c9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80178e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801791:	89 c2                	mov    %eax,%edx
  801793:	c1 ea 0c             	shr    $0xc,%edx
  801796:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80179d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017a3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b2:	00 
  8017b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017be:	e8 16 f4 ff ff       	call   800bd9 <sys_page_map>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	79 25                	jns    8017ee <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d4:	e8 53 f4 ff ff       	call   800c2c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e7:	e8 40 f4 ff ff       	call   800c2c <sys_page_unmap>
	return r;
  8017ec:	eb 02                	jmp    8017f0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017ee:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017f0:	89 d8                	mov    %ebx,%eax
  8017f2:	83 c4 4c             	add    $0x4c,%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 24             	sub    $0x24,%esp
  801801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	89 1c 24             	mov    %ebx,(%esp)
  80180e:	e8 4b fd ff ff       	call   80155e <fd_lookup>
  801813:	85 c0                	test   %eax,%eax
  801815:	78 6d                	js     801884 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801817:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	8b 00                	mov    (%eax),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 89 fd ff ff       	call   8015b4 <dev_lookup>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 55                	js     801884 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80182f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801832:	8b 50 08             	mov    0x8(%eax),%edx
  801835:	83 e2 03             	and    $0x3,%edx
  801838:	83 fa 01             	cmp    $0x1,%edx
  80183b:	75 23                	jne    801860 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80183d:	a1 08 50 80 00       	mov    0x805008,%eax
  801842:	8b 40 48             	mov    0x48(%eax),%eax
  801845:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801849:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184d:	c7 04 24 29 30 80 00 	movl   $0x803029,(%esp)
  801854:	e8 8f e9 ff ff       	call   8001e8 <cprintf>
		return -E_INVAL;
  801859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185e:	eb 24                	jmp    801884 <read+0x8a>
	}
	if (!dev->dev_read)
  801860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801863:	8b 52 08             	mov    0x8(%edx),%edx
  801866:	85 d2                	test   %edx,%edx
  801868:	74 15                	je     80187f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80186a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80186d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801874:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801878:	89 04 24             	mov    %eax,(%esp)
  80187b:	ff d2                	call   *%edx
  80187d:	eb 05                	jmp    801884 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80187f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801884:	83 c4 24             	add    $0x24,%esp
  801887:	5b                   	pop    %ebx
  801888:	5d                   	pop    %ebp
  801889:	c3                   	ret    

0080188a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
  801890:	83 ec 1c             	sub    $0x1c,%esp
  801893:	8b 7d 08             	mov    0x8(%ebp),%edi
  801896:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801899:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189e:	eb 23                	jmp    8018c3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018a0:	89 f0                	mov    %esi,%eax
  8018a2:	29 d8                	sub    %ebx,%eax
  8018a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ab:	01 d8                	add    %ebx,%eax
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	89 3c 24             	mov    %edi,(%esp)
  8018b4:	e8 41 ff ff ff       	call   8017fa <read>
		if (m < 0)
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 10                	js     8018cd <readn+0x43>
			return m;
		if (m == 0)
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	74 0a                	je     8018cb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018c1:	01 c3                	add    %eax,%ebx
  8018c3:	39 f3                	cmp    %esi,%ebx
  8018c5:	72 d9                	jb     8018a0 <readn+0x16>
  8018c7:	89 d8                	mov    %ebx,%eax
  8018c9:	eb 02                	jmp    8018cd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018cb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018cd:	83 c4 1c             	add    $0x1c,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	53                   	push   %ebx
  8018d9:	83 ec 24             	sub    $0x24,%esp
  8018dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	89 1c 24             	mov    %ebx,(%esp)
  8018e9:	e8 70 fc ff ff       	call   80155e <fd_lookup>
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 68                	js     80195a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fc:	8b 00                	mov    (%eax),%eax
  8018fe:	89 04 24             	mov    %eax,(%esp)
  801901:	e8 ae fc ff ff       	call   8015b4 <dev_lookup>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 50                	js     80195a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801911:	75 23                	jne    801936 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801913:	a1 08 50 80 00       	mov    0x805008,%eax
  801918:	8b 40 48             	mov    0x48(%eax),%eax
  80191b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801923:	c7 04 24 45 30 80 00 	movl   $0x803045,(%esp)
  80192a:	e8 b9 e8 ff ff       	call   8001e8 <cprintf>
		return -E_INVAL;
  80192f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801934:	eb 24                	jmp    80195a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801936:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801939:	8b 52 0c             	mov    0xc(%edx),%edx
  80193c:	85 d2                	test   %edx,%edx
  80193e:	74 15                	je     801955 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801940:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801943:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80194a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	ff d2                	call   *%edx
  801953:	eb 05                	jmp    80195a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801955:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80195a:	83 c4 24             	add    $0x24,%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <seek>:

int
seek(int fdnum, off_t offset)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801966:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196d:	8b 45 08             	mov    0x8(%ebp),%eax
  801970:	89 04 24             	mov    %eax,(%esp)
  801973:	e8 e6 fb ff ff       	call   80155e <fd_lookup>
  801978:	85 c0                	test   %eax,%eax
  80197a:	78 0e                	js     80198a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80197c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80197f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801982:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	53                   	push   %ebx
  801990:	83 ec 24             	sub    $0x24,%esp
  801993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801996:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199d:	89 1c 24             	mov    %ebx,(%esp)
  8019a0:	e8 b9 fb ff ff       	call   80155e <fd_lookup>
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	78 61                	js     801a0a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019b3:	8b 00                	mov    (%eax),%eax
  8019b5:	89 04 24             	mov    %eax,(%esp)
  8019b8:	e8 f7 fb ff ff       	call   8015b4 <dev_lookup>
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 49                	js     801a0a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019c8:	75 23                	jne    8019ed <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019ca:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019cf:	8b 40 48             	mov    0x48(%eax),%eax
  8019d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019da:	c7 04 24 08 30 80 00 	movl   $0x803008,(%esp)
  8019e1:	e8 02 e8 ff ff       	call   8001e8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019eb:	eb 1d                	jmp    801a0a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f0:	8b 52 18             	mov    0x18(%edx),%edx
  8019f3:	85 d2                	test   %edx,%edx
  8019f5:	74 0e                	je     801a05 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	ff d2                	call   *%edx
  801a03:	eb 05                	jmp    801a0a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a05:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a0a:	83 c4 24             	add    $0x24,%esp
  801a0d:	5b                   	pop    %ebx
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	83 ec 24             	sub    $0x24,%esp
  801a17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	89 04 24             	mov    %eax,(%esp)
  801a27:	e8 32 fb ff ff       	call   80155e <fd_lookup>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 52                	js     801a82 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a3a:	8b 00                	mov    (%eax),%eax
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	e8 70 fb ff ff       	call   8015b4 <dev_lookup>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	78 3a                	js     801a82 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a4f:	74 2c                	je     801a7d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a51:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a54:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a5b:	00 00 00 
	stat->st_isdir = 0;
  801a5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a65:	00 00 00 
	stat->st_dev = dev;
  801a68:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a72:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a75:	89 14 24             	mov    %edx,(%esp)
  801a78:	ff 50 14             	call   *0x14(%eax)
  801a7b:	eb 05                	jmp    801a82 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a82:	83 c4 24             	add    $0x24,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a97:	00 
  801a98:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9b:	89 04 24             	mov    %eax,(%esp)
  801a9e:	e8 2d 02 00 00       	call   801cd0 <open>
  801aa3:	89 c3                	mov    %eax,%ebx
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 1b                	js     801ac4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	89 1c 24             	mov    %ebx,(%esp)
  801ab3:	e8 58 ff ff ff       	call   801a10 <fstat>
  801ab8:	89 c6                	mov    %eax,%esi
	close(fd);
  801aba:	89 1c 24             	mov    %ebx,(%esp)
  801abd:	e8 d4 fb ff ff       	call   801696 <close>
	return r;
  801ac2:	89 f3                	mov    %esi,%ebx
}
  801ac4:	89 d8                	mov    %ebx,%eax
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    
  801acd:	00 00                	add    %al,(%eax)
	...

00801ad0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 10             	sub    $0x10,%esp
  801ad8:	89 c3                	mov    %eax,%ebx
  801ada:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801adc:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801ae3:	75 11                	jne    801af6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ae5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801aec:	e8 6a 0d 00 00       	call   80285b <ipc_find_env>
  801af1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801af6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801afd:	00 
  801afe:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b05:	00 
  801b06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b0a:	a1 00 50 80 00       	mov    0x805000,%eax
  801b0f:	89 04 24             	mov    %eax,(%esp)
  801b12:	e8 d6 0c 00 00       	call   8027ed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b1e:	00 
  801b1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b2a:	e8 55 0c 00 00       	call   802784 <ipc_recv>
}
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	5b                   	pop    %ebx
  801b33:	5e                   	pop    %esi
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b42:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b54:	b8 02 00 00 00       	mov    $0x2,%eax
  801b59:	e8 72 ff ff ff       	call   801ad0 <fsipc>
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 06 00 00 00       	mov    $0x6,%eax
  801b7b:	e8 50 ff ff ff       	call   801ad0 <fsipc>
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	53                   	push   %ebx
  801b86:	83 ec 14             	sub    $0x14,%esp
  801b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b92:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9c:	b8 05 00 00 00       	mov    $0x5,%eax
  801ba1:	e8 2a ff ff ff       	call   801ad0 <fsipc>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 2b                	js     801bd5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801baa:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bb1:	00 
  801bb2:	89 1c 24             	mov    %ebx,(%esp)
  801bb5:	e8 d9 eb ff ff       	call   800793 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bba:	a1 80 60 80 00       	mov    0x806080,%eax
  801bbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bc5:	a1 84 60 80 00       	mov    0x806084,%eax
  801bca:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd5:	83 c4 14             	add    $0x14,%esp
  801bd8:	5b                   	pop    %ebx
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 18             	sub    $0x18,%esp
  801be1:	8b 55 10             	mov    0x10(%ebp),%edx
  801be4:	89 d0                	mov    %edx,%eax
  801be6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801bec:	76 05                	jbe    801bf3 <devfile_write+0x18>
  801bee:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  801bf6:	8b 52 0c             	mov    0xc(%edx),%edx
  801bf9:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bff:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801c04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0f:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c16:	e8 f1 ec ff ff       	call   80090c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c20:	b8 04 00 00 00       	mov    $0x4,%eax
  801c25:	e8 a6 fe ff ff       	call   801ad0 <fsipc>
}
  801c2a:	c9                   	leave  
  801c2b:	c3                   	ret    

00801c2c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	56                   	push   %esi
  801c30:	53                   	push   %ebx
  801c31:	83 ec 10             	sub    $0x10,%esp
  801c34:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c42:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c48:	ba 00 00 00 00       	mov    $0x0,%edx
  801c4d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c52:	e8 79 fe ff ff       	call   801ad0 <fsipc>
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	78 6a                	js     801cc7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c5d:	39 c6                	cmp    %eax,%esi
  801c5f:	73 24                	jae    801c85 <devfile_read+0x59>
  801c61:	c7 44 24 0c 78 30 80 	movl   $0x803078,0xc(%esp)
  801c68:	00 
  801c69:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  801c70:	00 
  801c71:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c78:	00 
  801c79:	c7 04 24 7f 30 80 00 	movl   $0x80307f,(%esp)
  801c80:	e8 6b e4 ff ff       	call   8000f0 <_panic>
	assert(r <= PGSIZE);
  801c85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c8a:	7e 24                	jle    801cb0 <devfile_read+0x84>
  801c8c:	c7 44 24 0c 8a 30 80 	movl   $0x80308a,0xc(%esp)
  801c93:	00 
  801c94:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  801c9b:	00 
  801c9c:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ca3:	00 
  801ca4:	c7 04 24 7f 30 80 00 	movl   $0x80307f,(%esp)
  801cab:	e8 40 e4 ff ff       	call   8000f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cb0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cb4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cbb:	00 
  801cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 45 ec ff ff       	call   80090c <memmove>
	return r;
}
  801cc7:	89 d8                	mov    %ebx,%eax
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	5b                   	pop    %ebx
  801ccd:	5e                   	pop    %esi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	83 ec 20             	sub    $0x20,%esp
  801cd8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cdb:	89 34 24             	mov    %esi,(%esp)
  801cde:	e8 7d ea ff ff       	call   800760 <strlen>
  801ce3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ce8:	7f 60                	jg     801d4a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ced:	89 04 24             	mov    %eax,(%esp)
  801cf0:	e8 16 f8 ff ff       	call   80150b <fd_alloc>
  801cf5:	89 c3                	mov    %eax,%ebx
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 54                	js     801d4f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cfb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cff:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d06:	e8 88 ea ff ff       	call   800793 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	e8 b0 fd ff ff       	call   801ad0 <fsipc>
  801d20:	89 c3                	mov    %eax,%ebx
  801d22:	85 c0                	test   %eax,%eax
  801d24:	79 15                	jns    801d3b <open+0x6b>
		fd_close(fd, 0);
  801d26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d2d:	00 
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	89 04 24             	mov    %eax,(%esp)
  801d34:	e8 d5 f8 ff ff       	call   80160e <fd_close>
		return r;
  801d39:	eb 14                	jmp    801d4f <open+0x7f>
	}

	return fd2num(fd);
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	89 04 24             	mov    %eax,(%esp)
  801d41:	e8 9a f7 ff ff       	call   8014e0 <fd2num>
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	eb 05                	jmp    801d4f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d4a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	83 c4 20             	add    $0x20,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d63:	b8 08 00 00 00       	mov    $0x8,%eax
  801d68:	e8 63 fd ff ff       	call   801ad0 <fsipc>
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    
	...

00801d70 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d76:	c7 44 24 04 96 30 80 	movl   $0x803096,0x4(%esp)
  801d7d:	00 
  801d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d81:	89 04 24             	mov    %eax,(%esp)
  801d84:	e8 0a ea ff ff       	call   800793 <strcpy>
	return 0;
}
  801d89:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	83 ec 14             	sub    $0x14,%esp
  801d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d9a:	89 1c 24             	mov    %ebx,(%esp)
  801d9d:	e8 f2 0a 00 00       	call   802894 <pageref>
  801da2:	83 f8 01             	cmp    $0x1,%eax
  801da5:	75 0d                	jne    801db4 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801da7:	8b 43 0c             	mov    0xc(%ebx),%eax
  801daa:	89 04 24             	mov    %eax,(%esp)
  801dad:	e8 1f 03 00 00       	call   8020d1 <nsipc_close>
  801db2:	eb 05                	jmp    801db9 <devsock_close+0x29>
	else
		return 0;
  801db4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db9:	83 c4 14             	add    $0x14,%esp
  801dbc:	5b                   	pop    %ebx
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dc5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dcc:	00 
  801dcd:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	8b 40 0c             	mov    0xc(%eax),%eax
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 e3 03 00 00       	call   8021cc <nsipc_send>
}
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801df1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801df8:	00 
  801df9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e07:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e0d:	89 04 24             	mov    %eax,(%esp)
  801e10:	e8 37 03 00 00       	call   80214c <nsipc_recv>
}
  801e15:	c9                   	leave  
  801e16:	c3                   	ret    

00801e17 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	83 ec 20             	sub    $0x20,%esp
  801e1f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e24:	89 04 24             	mov    %eax,(%esp)
  801e27:	e8 df f6 ff ff       	call   80150b <fd_alloc>
  801e2c:	89 c3                	mov    %eax,%ebx
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 21                	js     801e53 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e32:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e39:	00 
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e48:	e8 38 ed ff ff       	call   800b85 <sys_page_alloc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	79 0a                	jns    801e5d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801e53:	89 34 24             	mov    %esi,(%esp)
  801e56:	e8 76 02 00 00       	call   8020d1 <nsipc_close>
		return r;
  801e5b:	eb 22                	jmp    801e7f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e5d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e66:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e72:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e75:	89 04 24             	mov    %eax,(%esp)
  801e78:	e8 63 f6 ff ff       	call   8014e0 <fd2num>
  801e7d:	89 c3                	mov    %eax,%ebx
}
  801e7f:	89 d8                	mov    %ebx,%eax
  801e81:	83 c4 20             	add    $0x20,%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e8e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e91:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e95:	89 04 24             	mov    %eax,(%esp)
  801e98:	e8 c1 f6 ff ff       	call   80155e <fd_lookup>
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 17                	js     801eb8 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea4:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801eaa:	39 10                	cmp    %edx,(%eax)
  801eac:	75 05                	jne    801eb3 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801eae:	8b 40 0c             	mov    0xc(%eax),%eax
  801eb1:	eb 05                	jmp    801eb8 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801eb3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    

00801eba <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec3:	e8 c0 ff ff ff       	call   801e88 <fd2sockid>
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 1f                	js     801eeb <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ecc:	8b 55 10             	mov    0x10(%ebp),%edx
  801ecf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed6:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eda:	89 04 24             	mov    %eax,(%esp)
  801edd:	e8 38 01 00 00       	call   80201a <nsipc_accept>
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	78 05                	js     801eeb <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801ee6:	e8 2c ff ff ff       	call   801e17 <alloc_sockfd>
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef6:	e8 8d ff ff ff       	call   801e88 <fd2sockid>
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 16                	js     801f15 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801eff:	8b 55 10             	mov    0x10(%ebp),%edx
  801f02:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f09:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f0d:	89 04 24             	mov    %eax,(%esp)
  801f10:	e8 5b 01 00 00       	call   802070 <nsipc_bind>
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <shutdown>:

int
shutdown(int s, int how)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	e8 63 ff ff ff       	call   801e88 <fd2sockid>
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 0f                	js     801f38 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f30:	89 04 24             	mov    %eax,(%esp)
  801f33:	e8 77 01 00 00       	call   8020af <nsipc_shutdown>
}
  801f38:	c9                   	leave  
  801f39:	c3                   	ret    

00801f3a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f3a:	55                   	push   %ebp
  801f3b:	89 e5                	mov    %esp,%ebp
  801f3d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	e8 40 ff ff ff       	call   801e88 <fd2sockid>
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	78 16                	js     801f62 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801f4c:	8b 55 10             	mov    0x10(%ebp),%edx
  801f4f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f53:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f56:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f5a:	89 04 24             	mov    %eax,(%esp)
  801f5d:	e8 89 01 00 00       	call   8020eb <nsipc_connect>
}
  801f62:	c9                   	leave  
  801f63:	c3                   	ret    

00801f64 <listen>:

int
listen(int s, int backlog)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6d:	e8 16 ff ff ff       	call   801e88 <fd2sockid>
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 0f                	js     801f85 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f79:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f7d:	89 04 24             	mov    %eax,(%esp)
  801f80:	e8 a5 01 00 00       	call   80212a <nsipc_listen>
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f90:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9e:	89 04 24             	mov    %eax,(%esp)
  801fa1:	e8 99 02 00 00       	call   80223f <nsipc_socket>
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 05                	js     801faf <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801faa:	e8 68 fe ff ff       	call   801e17 <alloc_sockfd>
}
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    
  801fb1:	00 00                	add    %al,(%eax)
	...

00801fb4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	53                   	push   %ebx
  801fb8:	83 ec 14             	sub    $0x14,%esp
  801fbb:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fbd:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801fc4:	75 11                	jne    801fd7 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fc6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801fcd:	e8 89 08 00 00       	call   80285b <ipc_find_env>
  801fd2:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fd7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fde:	00 
  801fdf:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801fe6:	00 
  801fe7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801feb:	a1 04 50 80 00       	mov    0x805004,%eax
  801ff0:	89 04 24             	mov    %eax,(%esp)
  801ff3:	e8 f5 07 00 00       	call   8027ed <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ff8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fff:	00 
  802000:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802007:	00 
  802008:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200f:	e8 70 07 00 00       	call   802784 <ipc_recv>
}
  802014:	83 c4 14             	add    $0x14,%esp
  802017:	5b                   	pop    %ebx
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    

0080201a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	56                   	push   %esi
  80201e:	53                   	push   %ebx
  80201f:	83 ec 10             	sub    $0x10,%esp
  802022:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802025:	8b 45 08             	mov    0x8(%ebp),%eax
  802028:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80202d:	8b 06                	mov    (%esi),%eax
  80202f:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802034:	b8 01 00 00 00       	mov    $0x1,%eax
  802039:	e8 76 ff ff ff       	call   801fb4 <nsipc>
  80203e:	89 c3                	mov    %eax,%ebx
  802040:	85 c0                	test   %eax,%eax
  802042:	78 23                	js     802067 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802044:	a1 10 70 80 00       	mov    0x807010,%eax
  802049:	89 44 24 08          	mov    %eax,0x8(%esp)
  80204d:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802054:	00 
  802055:	8b 45 0c             	mov    0xc(%ebp),%eax
  802058:	89 04 24             	mov    %eax,(%esp)
  80205b:	e8 ac e8 ff ff       	call   80090c <memmove>
		*addrlen = ret->ret_addrlen;
  802060:	a1 10 70 80 00       	mov    0x807010,%eax
  802065:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802067:	89 d8                	mov    %ebx,%eax
  802069:	83 c4 10             	add    $0x10,%esp
  80206c:	5b                   	pop    %ebx
  80206d:	5e                   	pop    %esi
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	53                   	push   %ebx
  802074:	83 ec 14             	sub    $0x14,%esp
  802077:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80207a:	8b 45 08             	mov    0x8(%ebp),%eax
  80207d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802082:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802086:	8b 45 0c             	mov    0xc(%ebp),%eax
  802089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80208d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802094:	e8 73 e8 ff ff       	call   80090c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802099:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80209f:	b8 02 00 00 00       	mov    $0x2,%eax
  8020a4:	e8 0b ff ff ff       	call   801fb4 <nsipc>
}
  8020a9:	83 c4 14             	add    $0x14,%esp
  8020ac:	5b                   	pop    %ebx
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    

008020af <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c0:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8020ca:	e8 e5 fe ff ff       	call   801fb4 <nsipc>
}
  8020cf:	c9                   	leave  
  8020d0:	c3                   	ret    

008020d1 <nsipc_close>:

int
nsipc_close(int s)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020da:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020df:	b8 04 00 00 00       	mov    $0x4,%eax
  8020e4:	e8 cb fe ff ff       	call   801fb4 <nsipc>
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	53                   	push   %ebx
  8020ef:	83 ec 14             	sub    $0x14,%esp
  8020f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020fd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802101:	8b 45 0c             	mov    0xc(%ebp),%eax
  802104:	89 44 24 04          	mov    %eax,0x4(%esp)
  802108:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80210f:	e8 f8 e7 ff ff       	call   80090c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802114:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80211a:	b8 05 00 00 00       	mov    $0x5,%eax
  80211f:	e8 90 fe ff ff       	call   801fb4 <nsipc>
}
  802124:	83 c4 14             	add    $0x14,%esp
  802127:	5b                   	pop    %ebx
  802128:	5d                   	pop    %ebp
  802129:	c3                   	ret    

0080212a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802130:	8b 45 08             	mov    0x8(%ebp),%eax
  802133:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802140:	b8 06 00 00 00       	mov    $0x6,%eax
  802145:	e8 6a fe ff ff       	call   801fb4 <nsipc>
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	56                   	push   %esi
  802150:	53                   	push   %ebx
  802151:	83 ec 10             	sub    $0x10,%esp
  802154:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802157:	8b 45 08             	mov    0x8(%ebp),%eax
  80215a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80215f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802165:	8b 45 14             	mov    0x14(%ebp),%eax
  802168:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80216d:	b8 07 00 00 00       	mov    $0x7,%eax
  802172:	e8 3d fe ff ff       	call   801fb4 <nsipc>
  802177:	89 c3                	mov    %eax,%ebx
  802179:	85 c0                	test   %eax,%eax
  80217b:	78 46                	js     8021c3 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80217d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802182:	7f 04                	jg     802188 <nsipc_recv+0x3c>
  802184:	39 c6                	cmp    %eax,%esi
  802186:	7d 24                	jge    8021ac <nsipc_recv+0x60>
  802188:	c7 44 24 0c a2 30 80 	movl   $0x8030a2,0xc(%esp)
  80218f:	00 
  802190:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  802197:	00 
  802198:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80219f:	00 
  8021a0:	c7 04 24 b7 30 80 00 	movl   $0x8030b7,(%esp)
  8021a7:	e8 44 df ff ff       	call   8000f0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021b7:	00 
  8021b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021bb:	89 04 24             	mov    %eax,(%esp)
  8021be:	e8 49 e7 ff ff       	call   80090c <memmove>
	}

	return r;
}
  8021c3:	89 d8                	mov    %ebx,%eax
  8021c5:	83 c4 10             	add    $0x10,%esp
  8021c8:	5b                   	pop    %ebx
  8021c9:	5e                   	pop    %esi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    

008021cc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021cc:	55                   	push   %ebp
  8021cd:	89 e5                	mov    %esp,%ebp
  8021cf:	53                   	push   %ebx
  8021d0:	83 ec 14             	sub    $0x14,%esp
  8021d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d9:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021de:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021e4:	7e 24                	jle    80220a <nsipc_send+0x3e>
  8021e6:	c7 44 24 0c c3 30 80 	movl   $0x8030c3,0xc(%esp)
  8021ed:	00 
  8021ee:	c7 44 24 08 0c 2f 80 	movl   $0x802f0c,0x8(%esp)
  8021f5:	00 
  8021f6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021fd:	00 
  8021fe:	c7 04 24 b7 30 80 00 	movl   $0x8030b7,(%esp)
  802205:	e8 e6 de ff ff       	call   8000f0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80220a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802211:	89 44 24 04          	mov    %eax,0x4(%esp)
  802215:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80221c:	e8 eb e6 ff ff       	call   80090c <memmove>
	nsipcbuf.send.req_size = size;
  802221:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802227:	8b 45 14             	mov    0x14(%ebp),%eax
  80222a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80222f:	b8 08 00 00 00       	mov    $0x8,%eax
  802234:	e8 7b fd ff ff       	call   801fb4 <nsipc>
}
  802239:	83 c4 14             	add    $0x14,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    

0080223f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802245:	8b 45 08             	mov    0x8(%ebp),%eax
  802248:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80224d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802250:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802255:	8b 45 10             	mov    0x10(%ebp),%eax
  802258:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80225d:	b8 09 00 00 00       	mov    $0x9,%eax
  802262:	e8 4d fd ff ff       	call   801fb4 <nsipc>
}
  802267:	c9                   	leave  
  802268:	c3                   	ret    
  802269:	00 00                	add    %al,(%eax)
	...

0080226c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	56                   	push   %esi
  802270:	53                   	push   %ebx
  802271:	83 ec 10             	sub    $0x10,%esp
  802274:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802277:	8b 45 08             	mov    0x8(%ebp),%eax
  80227a:	89 04 24             	mov    %eax,(%esp)
  80227d:	e8 6e f2 ff ff       	call   8014f0 <fd2data>
  802282:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802284:	c7 44 24 04 cf 30 80 	movl   $0x8030cf,0x4(%esp)
  80228b:	00 
  80228c:	89 34 24             	mov    %esi,(%esp)
  80228f:	e8 ff e4 ff ff       	call   800793 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802294:	8b 43 04             	mov    0x4(%ebx),%eax
  802297:	2b 03                	sub    (%ebx),%eax
  802299:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80229f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8022a6:	00 00 00 
	stat->st_dev = &devpipe;
  8022a9:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8022b0:	40 80 00 
	return 0;
}
  8022b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b8:	83 c4 10             	add    $0x10,%esp
  8022bb:	5b                   	pop    %ebx
  8022bc:	5e                   	pop    %esi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	53                   	push   %ebx
  8022c3:	83 ec 14             	sub    $0x14,%esp
  8022c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d4:	e8 53 e9 ff ff       	call   800c2c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022d9:	89 1c 24             	mov    %ebx,(%esp)
  8022dc:	e8 0f f2 ff ff       	call   8014f0 <fd2data>
  8022e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ec:	e8 3b e9 ff ff       	call   800c2c <sys_page_unmap>
}
  8022f1:	83 c4 14             	add    $0x14,%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5d                   	pop    %ebp
  8022f6:	c3                   	ret    

008022f7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022f7:	55                   	push   %ebp
  8022f8:	89 e5                	mov    %esp,%ebp
  8022fa:	57                   	push   %edi
  8022fb:	56                   	push   %esi
  8022fc:	53                   	push   %ebx
  8022fd:	83 ec 2c             	sub    $0x2c,%esp
  802300:	89 c7                	mov    %eax,%edi
  802302:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802305:	a1 08 50 80 00       	mov    0x805008,%eax
  80230a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80230d:	89 3c 24             	mov    %edi,(%esp)
  802310:	e8 7f 05 00 00       	call   802894 <pageref>
  802315:	89 c6                	mov    %eax,%esi
  802317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80231a:	89 04 24             	mov    %eax,(%esp)
  80231d:	e8 72 05 00 00       	call   802894 <pageref>
  802322:	39 c6                	cmp    %eax,%esi
  802324:	0f 94 c0             	sete   %al
  802327:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80232a:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802330:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802333:	39 cb                	cmp    %ecx,%ebx
  802335:	75 08                	jne    80233f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802337:	83 c4 2c             	add    $0x2c,%esp
  80233a:	5b                   	pop    %ebx
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80233f:	83 f8 01             	cmp    $0x1,%eax
  802342:	75 c1                	jne    802305 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802344:	8b 42 58             	mov    0x58(%edx),%eax
  802347:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80234e:	00 
  80234f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802353:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802357:	c7 04 24 d6 30 80 00 	movl   $0x8030d6,(%esp)
  80235e:	e8 85 de ff ff       	call   8001e8 <cprintf>
  802363:	eb a0                	jmp    802305 <_pipeisclosed+0xe>

00802365 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	57                   	push   %edi
  802369:	56                   	push   %esi
  80236a:	53                   	push   %ebx
  80236b:	83 ec 1c             	sub    $0x1c,%esp
  80236e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802371:	89 34 24             	mov    %esi,(%esp)
  802374:	e8 77 f1 ff ff       	call   8014f0 <fd2data>
  802379:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80237b:	bf 00 00 00 00       	mov    $0x0,%edi
  802380:	eb 3c                	jmp    8023be <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802382:	89 da                	mov    %ebx,%edx
  802384:	89 f0                	mov    %esi,%eax
  802386:	e8 6c ff ff ff       	call   8022f7 <_pipeisclosed>
  80238b:	85 c0                	test   %eax,%eax
  80238d:	75 38                	jne    8023c7 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80238f:	e8 d2 e7 ff ff       	call   800b66 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802394:	8b 43 04             	mov    0x4(%ebx),%eax
  802397:	8b 13                	mov    (%ebx),%edx
  802399:	83 c2 20             	add    $0x20,%edx
  80239c:	39 d0                	cmp    %edx,%eax
  80239e:	73 e2                	jae    802382 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023a3:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8023a6:	89 c2                	mov    %eax,%edx
  8023a8:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8023ae:	79 05                	jns    8023b5 <devpipe_write+0x50>
  8023b0:	4a                   	dec    %edx
  8023b1:	83 ca e0             	or     $0xffffffe0,%edx
  8023b4:	42                   	inc    %edx
  8023b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023b9:	40                   	inc    %eax
  8023ba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023bd:	47                   	inc    %edi
  8023be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023c1:	75 d1                	jne    802394 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023c3:	89 f8                	mov    %edi,%eax
  8023c5:	eb 05                	jmp    8023cc <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023c7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023cc:	83 c4 1c             	add    $0x1c,%esp
  8023cf:	5b                   	pop    %ebx
  8023d0:	5e                   	pop    %esi
  8023d1:	5f                   	pop    %edi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	57                   	push   %edi
  8023d8:	56                   	push   %esi
  8023d9:	53                   	push   %ebx
  8023da:	83 ec 1c             	sub    $0x1c,%esp
  8023dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023e0:	89 3c 24             	mov    %edi,(%esp)
  8023e3:	e8 08 f1 ff ff       	call   8014f0 <fd2data>
  8023e8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ea:	be 00 00 00 00       	mov    $0x0,%esi
  8023ef:	eb 3a                	jmp    80242b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023f1:	85 f6                	test   %esi,%esi
  8023f3:	74 04                	je     8023f9 <devpipe_read+0x25>
				return i;
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	eb 40                	jmp    802439 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023f9:	89 da                	mov    %ebx,%edx
  8023fb:	89 f8                	mov    %edi,%eax
  8023fd:	e8 f5 fe ff ff       	call   8022f7 <_pipeisclosed>
  802402:	85 c0                	test   %eax,%eax
  802404:	75 2e                	jne    802434 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802406:	e8 5b e7 ff ff       	call   800b66 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80240b:	8b 03                	mov    (%ebx),%eax
  80240d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802410:	74 df                	je     8023f1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802412:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802417:	79 05                	jns    80241e <devpipe_read+0x4a>
  802419:	48                   	dec    %eax
  80241a:	83 c8 e0             	or     $0xffffffe0,%eax
  80241d:	40                   	inc    %eax
  80241e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802422:	8b 55 0c             	mov    0xc(%ebp),%edx
  802425:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802428:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80242a:	46                   	inc    %esi
  80242b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80242e:	75 db                	jne    80240b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802430:	89 f0                	mov    %esi,%eax
  802432:	eb 05                	jmp    802439 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802434:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802439:	83 c4 1c             	add    $0x1c,%esp
  80243c:	5b                   	pop    %ebx
  80243d:	5e                   	pop    %esi
  80243e:	5f                   	pop    %edi
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    

00802441 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	57                   	push   %edi
  802445:	56                   	push   %esi
  802446:	53                   	push   %ebx
  802447:	83 ec 3c             	sub    $0x3c,%esp
  80244a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80244d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802450:	89 04 24             	mov    %eax,(%esp)
  802453:	e8 b3 f0 ff ff       	call   80150b <fd_alloc>
  802458:	89 c3                	mov    %eax,%ebx
  80245a:	85 c0                	test   %eax,%eax
  80245c:	0f 88 45 01 00 00    	js     8025a7 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802462:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802469:	00 
  80246a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80246d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802471:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802478:	e8 08 e7 ff ff       	call   800b85 <sys_page_alloc>
  80247d:	89 c3                	mov    %eax,%ebx
  80247f:	85 c0                	test   %eax,%eax
  802481:	0f 88 20 01 00 00    	js     8025a7 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802487:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80248a:	89 04 24             	mov    %eax,(%esp)
  80248d:	e8 79 f0 ff ff       	call   80150b <fd_alloc>
  802492:	89 c3                	mov    %eax,%ebx
  802494:	85 c0                	test   %eax,%eax
  802496:	0f 88 f8 00 00 00    	js     802594 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80249c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024a3:	00 
  8024a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b2:	e8 ce e6 ff ff       	call   800b85 <sys_page_alloc>
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	85 c0                	test   %eax,%eax
  8024bb:	0f 88 d3 00 00 00    	js     802594 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024c4:	89 04 24             	mov    %eax,(%esp)
  8024c7:	e8 24 f0 ff ff       	call   8014f0 <fd2data>
  8024cc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024d5:	00 
  8024d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024e1:	e8 9f e6 ff ff       	call   800b85 <sys_page_alloc>
  8024e6:	89 c3                	mov    %eax,%ebx
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	0f 88 91 00 00 00    	js     802581 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024f3:	89 04 24             	mov    %eax,(%esp)
  8024f6:	e8 f5 ef ff ff       	call   8014f0 <fd2data>
  8024fb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802502:	00 
  802503:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802507:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80250e:	00 
  80250f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80251a:	e8 ba e6 ff ff       	call   800bd9 <sys_page_map>
  80251f:	89 c3                	mov    %eax,%ebx
  802521:	85 c0                	test   %eax,%eax
  802523:	78 4c                	js     802571 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802525:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80252b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80252e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802530:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802533:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80253a:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802540:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802543:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802548:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80254f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802552:	89 04 24             	mov    %eax,(%esp)
  802555:	e8 86 ef ff ff       	call   8014e0 <fd2num>
  80255a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80255c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80255f:	89 04 24             	mov    %eax,(%esp)
  802562:	e8 79 ef ff ff       	call   8014e0 <fd2num>
  802567:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80256a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80256f:	eb 36                	jmp    8025a7 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802571:	89 74 24 04          	mov    %esi,0x4(%esp)
  802575:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80257c:	e8 ab e6 ff ff       	call   800c2c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802581:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802584:	89 44 24 04          	mov    %eax,0x4(%esp)
  802588:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80258f:	e8 98 e6 ff ff       	call   800c2c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802597:	89 44 24 04          	mov    %eax,0x4(%esp)
  80259b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a2:	e8 85 e6 ff ff       	call   800c2c <sys_page_unmap>
    err:
	return r;
}
  8025a7:	89 d8                	mov    %ebx,%eax
  8025a9:	83 c4 3c             	add    $0x3c,%esp
  8025ac:	5b                   	pop    %ebx
  8025ad:	5e                   	pop    %esi
  8025ae:	5f                   	pop    %edi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025be:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c1:	89 04 24             	mov    %eax,(%esp)
  8025c4:	e8 95 ef ff ff       	call   80155e <fd_lookup>
  8025c9:	85 c0                	test   %eax,%eax
  8025cb:	78 15                	js     8025e2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d0:	89 04 24             	mov    %eax,(%esp)
  8025d3:	e8 18 ef ff ff       	call   8014f0 <fd2data>
	return _pipeisclosed(fd, p);
  8025d8:	89 c2                	mov    %eax,%edx
  8025da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025dd:	e8 15 fd ff ff       	call   8022f7 <_pipeisclosed>
}
  8025e2:	c9                   	leave  
  8025e3:	c3                   	ret    

008025e4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025e4:	55                   	push   %ebp
  8025e5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ec:	5d                   	pop    %ebp
  8025ed:	c3                   	ret    

008025ee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025ee:	55                   	push   %ebp
  8025ef:	89 e5                	mov    %esp,%ebp
  8025f1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8025f4:	c7 44 24 04 ee 30 80 	movl   $0x8030ee,0x4(%esp)
  8025fb:	00 
  8025fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ff:	89 04 24             	mov    %eax,(%esp)
  802602:	e8 8c e1 ff ff       	call   800793 <strcpy>
	return 0;
}
  802607:	b8 00 00 00 00       	mov    $0x0,%eax
  80260c:	c9                   	leave  
  80260d:	c3                   	ret    

0080260e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80260e:	55                   	push   %ebp
  80260f:	89 e5                	mov    %esp,%ebp
  802611:	57                   	push   %edi
  802612:	56                   	push   %esi
  802613:	53                   	push   %ebx
  802614:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80261a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80261f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802625:	eb 30                	jmp    802657 <devcons_write+0x49>
		m = n - tot;
  802627:	8b 75 10             	mov    0x10(%ebp),%esi
  80262a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  80262c:	83 fe 7f             	cmp    $0x7f,%esi
  80262f:	76 05                	jbe    802636 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802631:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802636:	89 74 24 08          	mov    %esi,0x8(%esp)
  80263a:	03 45 0c             	add    0xc(%ebp),%eax
  80263d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802641:	89 3c 24             	mov    %edi,(%esp)
  802644:	e8 c3 e2 ff ff       	call   80090c <memmove>
		sys_cputs(buf, m);
  802649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80264d:	89 3c 24             	mov    %edi,(%esp)
  802650:	e8 63 e4 ff ff       	call   800ab8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802655:	01 f3                	add    %esi,%ebx
  802657:	89 d8                	mov    %ebx,%eax
  802659:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80265c:	72 c9                	jb     802627 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80265e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802664:	5b                   	pop    %ebx
  802665:	5e                   	pop    %esi
  802666:	5f                   	pop    %edi
  802667:	5d                   	pop    %ebp
  802668:	c3                   	ret    

00802669 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802669:	55                   	push   %ebp
  80266a:	89 e5                	mov    %esp,%ebp
  80266c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80266f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802673:	75 07                	jne    80267c <devcons_read+0x13>
  802675:	eb 25                	jmp    80269c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802677:	e8 ea e4 ff ff       	call   800b66 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80267c:	e8 55 e4 ff ff       	call   800ad6 <sys_cgetc>
  802681:	85 c0                	test   %eax,%eax
  802683:	74 f2                	je     802677 <devcons_read+0xe>
  802685:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802687:	85 c0                	test   %eax,%eax
  802689:	78 1d                	js     8026a8 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80268b:	83 f8 04             	cmp    $0x4,%eax
  80268e:	74 13                	je     8026a3 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802690:	8b 45 0c             	mov    0xc(%ebp),%eax
  802693:	88 10                	mov    %dl,(%eax)
	return 1;
  802695:	b8 01 00 00 00       	mov    $0x1,%eax
  80269a:	eb 0c                	jmp    8026a8 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80269c:	b8 00 00 00 00       	mov    $0x0,%eax
  8026a1:	eb 05                	jmp    8026a8 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8026a3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8026a8:	c9                   	leave  
  8026a9:	c3                   	ret    

008026aa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8026aa:	55                   	push   %ebp
  8026ab:	89 e5                	mov    %esp,%ebp
  8026ad:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8026b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8026b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8026bd:	00 
  8026be:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026c1:	89 04 24             	mov    %eax,(%esp)
  8026c4:	e8 ef e3 ff ff       	call   800ab8 <sys_cputs>
}
  8026c9:	c9                   	leave  
  8026ca:	c3                   	ret    

008026cb <getchar>:

int
getchar(void)
{
  8026cb:	55                   	push   %ebp
  8026cc:	89 e5                	mov    %esp,%ebp
  8026ce:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8026d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8026d8:	00 
  8026d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026e7:	e8 0e f1 ff ff       	call   8017fa <read>
	if (r < 0)
  8026ec:	85 c0                	test   %eax,%eax
  8026ee:	78 0f                	js     8026ff <getchar+0x34>
		return r;
	if (r < 1)
  8026f0:	85 c0                	test   %eax,%eax
  8026f2:	7e 06                	jle    8026fa <getchar+0x2f>
		return -E_EOF;
	return c;
  8026f4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026f8:	eb 05                	jmp    8026ff <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026fa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026ff:	c9                   	leave  
  802700:	c3                   	ret    

00802701 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802701:	55                   	push   %ebp
  802702:	89 e5                	mov    %esp,%ebp
  802704:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802707:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80270a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80270e:	8b 45 08             	mov    0x8(%ebp),%eax
  802711:	89 04 24             	mov    %eax,(%esp)
  802714:	e8 45 ee ff ff       	call   80155e <fd_lookup>
  802719:	85 c0                	test   %eax,%eax
  80271b:	78 11                	js     80272e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80271d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802720:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802726:	39 10                	cmp    %edx,(%eax)
  802728:	0f 94 c0             	sete   %al
  80272b:	0f b6 c0             	movzbl %al,%eax
}
  80272e:	c9                   	leave  
  80272f:	c3                   	ret    

00802730 <opencons>:

int
opencons(void)
{
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802736:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802739:	89 04 24             	mov    %eax,(%esp)
  80273c:	e8 ca ed ff ff       	call   80150b <fd_alloc>
  802741:	85 c0                	test   %eax,%eax
  802743:	78 3c                	js     802781 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802745:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80274c:	00 
  80274d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802750:	89 44 24 04          	mov    %eax,0x4(%esp)
  802754:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80275b:	e8 25 e4 ff ff       	call   800b85 <sys_page_alloc>
  802760:	85 c0                	test   %eax,%eax
  802762:	78 1d                	js     802781 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802764:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80276a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80276d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80276f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802772:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802779:	89 04 24             	mov    %eax,(%esp)
  80277c:	e8 5f ed ff ff       	call   8014e0 <fd2num>
}
  802781:	c9                   	leave  
  802782:	c3                   	ret    
	...

00802784 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802784:	55                   	push   %ebp
  802785:	89 e5                	mov    %esp,%ebp
  802787:	56                   	push   %esi
  802788:	53                   	push   %ebx
  802789:	83 ec 10             	sub    $0x10,%esp
  80278c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80278f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802792:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802795:	85 c0                	test   %eax,%eax
  802797:	75 05                	jne    80279e <ipc_recv+0x1a>
  802799:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80279e:	89 04 24             	mov    %eax,(%esp)
  8027a1:	e8 f5 e5 ff ff       	call   800d9b <sys_ipc_recv>
	if (from_env_store != NULL)
  8027a6:	85 db                	test   %ebx,%ebx
  8027a8:	74 0b                	je     8027b5 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8027aa:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8027b0:	8b 52 74             	mov    0x74(%edx),%edx
  8027b3:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8027b5:	85 f6                	test   %esi,%esi
  8027b7:	74 0b                	je     8027c4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8027b9:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8027bf:	8b 52 78             	mov    0x78(%edx),%edx
  8027c2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8027c4:	85 c0                	test   %eax,%eax
  8027c6:	79 16                	jns    8027de <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8027c8:	85 db                	test   %ebx,%ebx
  8027ca:	74 06                	je     8027d2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8027cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8027d2:	85 f6                	test   %esi,%esi
  8027d4:	74 10                	je     8027e6 <ipc_recv+0x62>
			*perm_store = 0;
  8027d6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8027dc:	eb 08                	jmp    8027e6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8027de:	a1 08 50 80 00       	mov    0x805008,%eax
  8027e3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8027e6:	83 c4 10             	add    $0x10,%esp
  8027e9:	5b                   	pop    %ebx
  8027ea:	5e                   	pop    %esi
  8027eb:	5d                   	pop    %ebp
  8027ec:	c3                   	ret    

008027ed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027ed:	55                   	push   %ebp
  8027ee:	89 e5                	mov    %esp,%ebp
  8027f0:	57                   	push   %edi
  8027f1:	56                   	push   %esi
  8027f2:	53                   	push   %ebx
  8027f3:	83 ec 1c             	sub    $0x1c,%esp
  8027f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8027f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8027fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8027ff:	eb 2a                	jmp    80282b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802801:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802804:	74 20                	je     802826 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80280a:	c7 44 24 08 fc 30 80 	movl   $0x8030fc,0x8(%esp)
  802811:	00 
  802812:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802819:	00 
  80281a:	c7 04 24 24 31 80 00 	movl   $0x803124,(%esp)
  802821:	e8 ca d8 ff ff       	call   8000f0 <_panic>
		sys_yield();
  802826:	e8 3b e3 ff ff       	call   800b66 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80282b:	85 db                	test   %ebx,%ebx
  80282d:	75 07                	jne    802836 <ipc_send+0x49>
  80282f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802834:	eb 02                	jmp    802838 <ipc_send+0x4b>
  802836:	89 d8                	mov    %ebx,%eax
  802838:	8b 55 14             	mov    0x14(%ebp),%edx
  80283b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80283f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802843:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802847:	89 34 24             	mov    %esi,(%esp)
  80284a:	e8 29 e5 ff ff       	call   800d78 <sys_ipc_try_send>
  80284f:	85 c0                	test   %eax,%eax
  802851:	78 ae                	js     802801 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802853:	83 c4 1c             	add    $0x1c,%esp
  802856:	5b                   	pop    %ebx
  802857:	5e                   	pop    %esi
  802858:	5f                   	pop    %edi
  802859:	5d                   	pop    %ebp
  80285a:	c3                   	ret    

0080285b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80285b:	55                   	push   %ebp
  80285c:	89 e5                	mov    %esp,%ebp
  80285e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802861:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802866:	89 c2                	mov    %eax,%edx
  802868:	c1 e2 07             	shl    $0x7,%edx
  80286b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802871:	8b 52 50             	mov    0x50(%edx),%edx
  802874:	39 ca                	cmp    %ecx,%edx
  802876:	75 0d                	jne    802885 <ipc_find_env+0x2a>
			return envs[i].env_id;
  802878:	c1 e0 07             	shl    $0x7,%eax
  80287b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802880:	8b 40 40             	mov    0x40(%eax),%eax
  802883:	eb 0c                	jmp    802891 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802885:	40                   	inc    %eax
  802886:	3d 00 04 00 00       	cmp    $0x400,%eax
  80288b:	75 d9                	jne    802866 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80288d:	66 b8 00 00          	mov    $0x0,%ax
}
  802891:	5d                   	pop    %ebp
  802892:	c3                   	ret    
	...

00802894 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802894:	55                   	push   %ebp
  802895:	89 e5                	mov    %esp,%ebp
  802897:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80289a:	89 c2                	mov    %eax,%edx
  80289c:	c1 ea 16             	shr    $0x16,%edx
  80289f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028a6:	f6 c2 01             	test   $0x1,%dl
  8028a9:	74 1e                	je     8028c9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8028ab:	c1 e8 0c             	shr    $0xc,%eax
  8028ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8028b5:	a8 01                	test   $0x1,%al
  8028b7:	74 17                	je     8028d0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8028b9:	c1 e8 0c             	shr    $0xc,%eax
  8028bc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8028c3:	ef 
  8028c4:	0f b7 c0             	movzwl %ax,%eax
  8028c7:	eb 0c                	jmp    8028d5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8028c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ce:	eb 05                	jmp    8028d5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8028d0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8028d5:	5d                   	pop    %ebp
  8028d6:	c3                   	ret    
	...

008028d8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8028d8:	55                   	push   %ebp
  8028d9:	57                   	push   %edi
  8028da:	56                   	push   %esi
  8028db:	83 ec 10             	sub    $0x10,%esp
  8028de:	8b 74 24 20          	mov    0x20(%esp),%esi
  8028e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028ea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8028ee:	89 cd                	mov    %ecx,%ebp
  8028f0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8028f4:	85 c0                	test   %eax,%eax
  8028f6:	75 2c                	jne    802924 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8028f8:	39 f9                	cmp    %edi,%ecx
  8028fa:	77 68                	ja     802964 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028fc:	85 c9                	test   %ecx,%ecx
  8028fe:	75 0b                	jne    80290b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802900:	b8 01 00 00 00       	mov    $0x1,%eax
  802905:	31 d2                	xor    %edx,%edx
  802907:	f7 f1                	div    %ecx
  802909:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80290b:	31 d2                	xor    %edx,%edx
  80290d:	89 f8                	mov    %edi,%eax
  80290f:	f7 f1                	div    %ecx
  802911:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802913:	89 f0                	mov    %esi,%eax
  802915:	f7 f1                	div    %ecx
  802917:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802919:	89 f0                	mov    %esi,%eax
  80291b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80291d:	83 c4 10             	add    $0x10,%esp
  802920:	5e                   	pop    %esi
  802921:	5f                   	pop    %edi
  802922:	5d                   	pop    %ebp
  802923:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802924:	39 f8                	cmp    %edi,%eax
  802926:	77 2c                	ja     802954 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802928:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80292b:	83 f6 1f             	xor    $0x1f,%esi
  80292e:	75 4c                	jne    80297c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802930:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802932:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802937:	72 0a                	jb     802943 <__udivdi3+0x6b>
  802939:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80293d:	0f 87 ad 00 00 00    	ja     8029f0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802943:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802948:	89 f0                	mov    %esi,%eax
  80294a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80294c:	83 c4 10             	add    $0x10,%esp
  80294f:	5e                   	pop    %esi
  802950:	5f                   	pop    %edi
  802951:	5d                   	pop    %ebp
  802952:	c3                   	ret    
  802953:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802954:	31 ff                	xor    %edi,%edi
  802956:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802958:	89 f0                	mov    %esi,%eax
  80295a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80295c:	83 c4 10             	add    $0x10,%esp
  80295f:	5e                   	pop    %esi
  802960:	5f                   	pop    %edi
  802961:	5d                   	pop    %ebp
  802962:	c3                   	ret    
  802963:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802964:	89 fa                	mov    %edi,%edx
  802966:	89 f0                	mov    %esi,%eax
  802968:	f7 f1                	div    %ecx
  80296a:	89 c6                	mov    %eax,%esi
  80296c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80296e:	89 f0                	mov    %esi,%eax
  802970:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802972:	83 c4 10             	add    $0x10,%esp
  802975:	5e                   	pop    %esi
  802976:	5f                   	pop    %edi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    
  802979:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80297c:	89 f1                	mov    %esi,%ecx
  80297e:	d3 e0                	shl    %cl,%eax
  802980:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802984:	b8 20 00 00 00       	mov    $0x20,%eax
  802989:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80298b:	89 ea                	mov    %ebp,%edx
  80298d:	88 c1                	mov    %al,%cl
  80298f:	d3 ea                	shr    %cl,%edx
  802991:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802995:	09 ca                	or     %ecx,%edx
  802997:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80299b:	89 f1                	mov    %esi,%ecx
  80299d:	d3 e5                	shl    %cl,%ebp
  80299f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8029a3:	89 fd                	mov    %edi,%ebp
  8029a5:	88 c1                	mov    %al,%cl
  8029a7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8029a9:	89 fa                	mov    %edi,%edx
  8029ab:	89 f1                	mov    %esi,%ecx
  8029ad:	d3 e2                	shl    %cl,%edx
  8029af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8029b3:	88 c1                	mov    %al,%cl
  8029b5:	d3 ef                	shr    %cl,%edi
  8029b7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029b9:	89 f8                	mov    %edi,%eax
  8029bb:	89 ea                	mov    %ebp,%edx
  8029bd:	f7 74 24 08          	divl   0x8(%esp)
  8029c1:	89 d1                	mov    %edx,%ecx
  8029c3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8029c5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029c9:	39 d1                	cmp    %edx,%ecx
  8029cb:	72 17                	jb     8029e4 <__udivdi3+0x10c>
  8029cd:	74 09                	je     8029d8 <__udivdi3+0x100>
  8029cf:	89 fe                	mov    %edi,%esi
  8029d1:	31 ff                	xor    %edi,%edi
  8029d3:	e9 41 ff ff ff       	jmp    802919 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8029d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8029dc:	89 f1                	mov    %esi,%ecx
  8029de:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029e0:	39 c2                	cmp    %eax,%edx
  8029e2:	73 eb                	jae    8029cf <__udivdi3+0xf7>
		{
		  q0--;
  8029e4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8029e7:	31 ff                	xor    %edi,%edi
  8029e9:	e9 2b ff ff ff       	jmp    802919 <__udivdi3+0x41>
  8029ee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029f0:	31 f6                	xor    %esi,%esi
  8029f2:	e9 22 ff ff ff       	jmp    802919 <__udivdi3+0x41>
	...

008029f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8029f8:	55                   	push   %ebp
  8029f9:	57                   	push   %edi
  8029fa:	56                   	push   %esi
  8029fb:	83 ec 20             	sub    $0x20,%esp
  8029fe:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a02:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a06:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a0a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a12:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a16:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802a18:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a1a:	85 ed                	test   %ebp,%ebp
  802a1c:	75 16                	jne    802a34 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802a1e:	39 f1                	cmp    %esi,%ecx
  802a20:	0f 86 a6 00 00 00    	jbe    802acc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a26:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a28:	89 d0                	mov    %edx,%eax
  802a2a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a2c:	83 c4 20             	add    $0x20,%esp
  802a2f:	5e                   	pop    %esi
  802a30:	5f                   	pop    %edi
  802a31:	5d                   	pop    %ebp
  802a32:	c3                   	ret    
  802a33:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a34:	39 f5                	cmp    %esi,%ebp
  802a36:	0f 87 ac 00 00 00    	ja     802ae8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a3c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802a3f:	83 f0 1f             	xor    $0x1f,%eax
  802a42:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a46:	0f 84 a8 00 00 00    	je     802af4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a4c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a50:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a52:	bf 20 00 00 00       	mov    $0x20,%edi
  802a57:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802a5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a5f:	89 f9                	mov    %edi,%ecx
  802a61:	d3 e8                	shr    %cl,%eax
  802a63:	09 e8                	or     %ebp,%eax
  802a65:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802a69:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a6d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a71:	d3 e0                	shl    %cl,%eax
  802a73:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a77:	89 f2                	mov    %esi,%edx
  802a79:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802a7b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a7f:	d3 e0                	shl    %cl,%eax
  802a81:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a85:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a89:	89 f9                	mov    %edi,%ecx
  802a8b:	d3 e8                	shr    %cl,%eax
  802a8d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802a8f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a91:	89 f2                	mov    %esi,%edx
  802a93:	f7 74 24 18          	divl   0x18(%esp)
  802a97:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a99:	f7 64 24 0c          	mull   0xc(%esp)
  802a9d:	89 c5                	mov    %eax,%ebp
  802a9f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aa1:	39 d6                	cmp    %edx,%esi
  802aa3:	72 67                	jb     802b0c <__umoddi3+0x114>
  802aa5:	74 75                	je     802b1c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802aa7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802aab:	29 e8                	sub    %ebp,%eax
  802aad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802aaf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ab3:	d3 e8                	shr    %cl,%eax
  802ab5:	89 f2                	mov    %esi,%edx
  802ab7:	89 f9                	mov    %edi,%ecx
  802ab9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802abb:	09 d0                	or     %edx,%eax
  802abd:	89 f2                	mov    %esi,%edx
  802abf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ac3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ac5:	83 c4 20             	add    $0x20,%esp
  802ac8:	5e                   	pop    %esi
  802ac9:	5f                   	pop    %edi
  802aca:	5d                   	pop    %ebp
  802acb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802acc:	85 c9                	test   %ecx,%ecx
  802ace:	75 0b                	jne    802adb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802ad0:	b8 01 00 00 00       	mov    $0x1,%eax
  802ad5:	31 d2                	xor    %edx,%edx
  802ad7:	f7 f1                	div    %ecx
  802ad9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802adb:	89 f0                	mov    %esi,%eax
  802add:	31 d2                	xor    %edx,%edx
  802adf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802ae1:	89 f8                	mov    %edi,%eax
  802ae3:	e9 3e ff ff ff       	jmp    802a26 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802ae8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802aea:	83 c4 20             	add    $0x20,%esp
  802aed:	5e                   	pop    %esi
  802aee:	5f                   	pop    %edi
  802aef:	5d                   	pop    %ebp
  802af0:	c3                   	ret    
  802af1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802af4:	39 f5                	cmp    %esi,%ebp
  802af6:	72 04                	jb     802afc <__umoddi3+0x104>
  802af8:	39 f9                	cmp    %edi,%ecx
  802afa:	77 06                	ja     802b02 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802afc:	89 f2                	mov    %esi,%edx
  802afe:	29 cf                	sub    %ecx,%edi
  802b00:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b02:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b04:	83 c4 20             	add    $0x20,%esp
  802b07:	5e                   	pop    %esi
  802b08:	5f                   	pop    %edi
  802b09:	5d                   	pop    %ebp
  802b0a:	c3                   	ret    
  802b0b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b0c:	89 d1                	mov    %edx,%ecx
  802b0e:	89 c5                	mov    %eax,%ebp
  802b10:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b14:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b18:	eb 8d                	jmp    802aa7 <__umoddi3+0xaf>
  802b1a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b1c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b20:	72 ea                	jb     802b0c <__umoddi3+0x114>
  802b22:	89 f1                	mov    %esi,%ecx
  802b24:	eb 81                	jmp    802aa7 <__umoddi3+0xaf>
