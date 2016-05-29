
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 33 01 00 00       	call   800164 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 75 08             	mov    0x8(%ebp),%esi
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800043:	eb 40                	jmp    800085 <cat+0x51>
		if ((r = write(1, buf, n)) != n)
  800045:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800049:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800050:	00 
  800051:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800058:	e8 d8 12 00 00       	call   801335 <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 c0 26 80 	movl   $0x8026c0,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 db 26 80 00 	movl   $0x8026db,(%esp)
  800080:	e8 3b 01 00 00       	call   8001c0 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  800085:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 20 40 80 	movl   $0x804020,0x4(%esp)
  800094:	00 
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 bd 11 00 00       	call   80125a <read>
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	85 c0                	test   %eax,%eax
  8000a1:	7f a2                	jg     800045 <cat+0x11>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 24                	jns    8000cb <cat+0x97>
		panic("error reading %s: %e", s, n);
  8000a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000af:	c7 44 24 08 e6 26 80 	movl   $0x8026e6,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 db 26 80 00 	movl   $0x8026db,(%esp)
  8000c6:	e8 f5 00 00 00       	call   8001c0 <_panic>
}
  8000cb:	83 c4 2c             	add    $0x2c,%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <umain>:

void
umain(int argc, char **argv)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 1c             	sub    $0x1c,%esp
  8000dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int f, i;

	binaryname = "cat";
  8000df:	c7 05 00 30 80 00 fb 	movl   $0x8026fb,0x803000
  8000e6:	26 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	75 62                	jne    800151 <umain+0x7e>
		cat(0, "<stdin>");
  8000ef:	c7 44 24 04 ff 26 80 	movl   $0x8026ff,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fe:	e8 31 ff ff ff       	call   800034 <cat>
  800103:	eb 56                	jmp    80015b <umain+0x88>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80010c:	00 
  80010d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 18 16 00 00       	call   801730 <open>
  800118:	89 c7                	mov    %eax,%edi
			if (f < 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	79 19                	jns    800137 <umain+0x64>
				printf("can't open %s: %e\n", argv[i], f);
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  800130:	e8 b0 17 00 00       	call   8018e5 <printf>
  800135:	eb 17                	jmp    80014e <umain+0x7b>
			else {
				cat(f, argv[i]);
  800137:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 3c 24             	mov    %edi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <cat>
				close(f);
  800146:	89 3c 24             	mov    %edi,(%esp)
  800149:	e8 a8 0f 00 00       	call   8010f6 <close>

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80014e:	43                   	inc    %ebx
  80014f:	eb 05                	jmp    800156 <umain+0x83>
umain(int argc, char **argv)
{
	int f, i;

	binaryname = "cat";
	if (argc == 1)
  800151:	bb 01 00 00 00       	mov    $0x1,%ebx
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800156:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800159:	7c aa                	jl     800105 <umain+0x32>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80015b:	83 c4 1c             	add    $0x1c,%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    
	...

00800164 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 10             	sub    $0x10,%esp
  80016c:	8b 75 08             	mov    0x8(%ebp),%esi
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800172:	e8 a0 0a 00 00       	call   800c17 <sys_getenvid>
  800177:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017c:	c1 e0 07             	shl    $0x7,%eax
  80017f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800184:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800189:	85 f6                	test   %esi,%esi
  80018b:	7e 07                	jle    800194 <libmain+0x30>
		binaryname = argv[0];
  80018d:	8b 03                	mov    (%ebx),%eax
  80018f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800194:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800198:	89 34 24             	mov    %esi,(%esp)
  80019b:	e8 33 ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a0:	e8 07 00 00 00       	call   8001ac <exit>
}
  8001a5:	83 c4 10             	add    $0x10,%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5d                   	pop    %ebp
  8001ab:	c3                   	ret    

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b9:	e8 07 0a 00 00       	call   800bc5 <sys_env_destroy>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001cb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001d1:	e8 41 0a 00 00       	call   800c17 <sys_getenvid>
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 24 27 80 00 	movl   $0x802724,(%esp)
  8001f3:	e8 c0 00 00 00       	call   8002b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ff:	89 04 24             	mov    %eax,(%esp)
  800202:	e8 50 00 00 00       	call   800257 <vcprintf>
	cprintf("\n");
  800207:	c7 04 24 88 2b 80 00 	movl   $0x802b88,(%esp)
  80020e:	e8 a5 00 00 00       	call   8002b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800213:	cc                   	int3   
  800214:	eb fd                	jmp    800213 <_panic+0x53>
	...

00800218 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	53                   	push   %ebx
  80021c:	83 ec 14             	sub    $0x14,%esp
  80021f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800222:	8b 03                	mov    (%ebx),%eax
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022b:	40                   	inc    %eax
  80022c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80022e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800233:	75 19                	jne    80024e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800235:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80023c:	00 
  80023d:	8d 43 08             	lea    0x8(%ebx),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 40 09 00 00       	call   800b88 <sys_cputs>
		b->idx = 0;
  800248:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80024e:	ff 43 04             	incl   0x4(%ebx)
}
  800251:	83 c4 14             	add    $0x14,%esp
  800254:	5b                   	pop    %ebx
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800260:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800267:	00 00 00 
	b.cnt = 0;
  80026a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800271:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
  800277:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800282:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 18 02 80 00 	movl   $0x800218,(%esp)
  800293:	e8 82 01 00 00       	call   80041a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800298:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80029e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	e8 d8 08 00 00       	call   800b88 <sys_cputs>

	return b.cnt;
}
  8002b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b6:	c9                   	leave  
  8002b7:	c3                   	ret    

008002b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c8:	89 04 24             	mov    %eax,(%esp)
  8002cb:	e8 87 ff ff ff       	call   800257 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    
	...

008002d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
  8002da:	83 ec 3c             	sub    $0x3c,%esp
  8002dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e0:	89 d7                	mov    %edx,%edi
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	75 08                	jne    800300 <printnum+0x2c>
  8002f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002fe:	77 57                	ja     800357 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800300:	89 74 24 10          	mov    %esi,0x10(%esp)
  800304:	4b                   	dec    %ebx
  800305:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800309:	8b 45 10             	mov    0x10(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800314:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	e8 3e 21 00 00       	call   802470 <__udivdi3>
  800332:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800336:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800341:	89 fa                	mov    %edi,%edx
  800343:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800346:	e8 89 ff ff ff       	call   8002d4 <printnum>
  80034b:	eb 0f                	jmp    80035c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800351:	89 34 24             	mov    %esi,(%esp)
  800354:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800357:	4b                   	dec    %ebx
  800358:	85 db                	test   %ebx,%ebx
  80035a:	7f f1                	jg     80034d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800360:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800364:	8b 45 10             	mov    0x10(%ebp),%eax
  800367:	89 44 24 08          	mov    %eax,0x8(%esp)
  80036b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800372:	00 
  800373:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800376:	89 04 24             	mov    %eax,(%esp)
  800379:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800380:	e8 0b 22 00 00       	call   802590 <__umoddi3>
  800385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800389:	0f be 80 47 27 80 00 	movsbl 0x802747(%eax),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800396:	83 c4 3c             	add    $0x3c,%esp
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a1:	83 fa 01             	cmp    $0x1,%edx
  8003a4:	7e 0e                	jle    8003b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003a6:	8b 10                	mov    (%eax),%edx
  8003a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ab:	89 08                	mov    %ecx,(%eax)
  8003ad:	8b 02                	mov    (%edx),%eax
  8003af:	8b 52 04             	mov    0x4(%edx),%edx
  8003b2:	eb 22                	jmp    8003d6 <getuint+0x38>
	else if (lflag)
  8003b4:	85 d2                	test   %edx,%edx
  8003b6:	74 10                	je     8003c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 0e                	jmp    8003d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c8:	8b 10                	mov    (%eax),%edx
  8003ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003cd:	89 08                	mov    %ecx,(%eax)
  8003cf:	8b 02                	mov    (%edx),%eax
  8003d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003de:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e6:	73 08                	jae    8003f0 <sprintputch+0x18>
		*b->buf++ = ch;
  8003e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003eb:	88 0a                	mov    %cl,(%edx)
  8003ed:	42                   	inc    %edx
  8003ee:	89 10                	mov    %edx,(%eax)
}
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800402:	89 44 24 08          	mov    %eax,0x8(%esp)
  800406:	8b 45 0c             	mov    0xc(%ebp),%eax
  800409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	e8 02 00 00 00       	call   80041a <vprintfmt>
	va_end(ap);
}
  800418:	c9                   	leave  
  800419:	c3                   	ret    

0080041a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	57                   	push   %edi
  80041e:	56                   	push   %esi
  80041f:	53                   	push   %ebx
  800420:	83 ec 4c             	sub    $0x4c,%esp
  800423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800426:	8b 75 10             	mov    0x10(%ebp),%esi
  800429:	eb 12                	jmp    80043d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042b:	85 c0                	test   %eax,%eax
  80042d:	0f 84 6b 03 00 00    	je     80079e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800433:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043d:	0f b6 06             	movzbl (%esi),%eax
  800440:	46                   	inc    %esi
  800441:	83 f8 25             	cmp    $0x25,%eax
  800444:	75 e5                	jne    80042b <vprintfmt+0x11>
  800446:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80044a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800451:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800456:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80045d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800462:	eb 26                	jmp    80048a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800467:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80046b:	eb 1d                	jmp    80048a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800470:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800474:	eb 14                	jmp    80048a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800479:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800480:	eb 08                	jmp    80048a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800482:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800485:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	0f b6 06             	movzbl (%esi),%eax
  80048d:	8d 56 01             	lea    0x1(%esi),%edx
  800490:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800493:	8a 16                	mov    (%esi),%dl
  800495:	83 ea 23             	sub    $0x23,%edx
  800498:	80 fa 55             	cmp    $0x55,%dl
  80049b:	0f 87 e1 02 00 00    	ja     800782 <vprintfmt+0x368>
  8004a1:	0f b6 d2             	movzbl %dl,%edx
  8004a4:	ff 24 95 80 28 80 00 	jmp    *0x802880(,%edx,4)
  8004ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ae:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004b6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004bd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004c0:	83 fa 09             	cmp    $0x9,%edx
  8004c3:	77 2a                	ja     8004ef <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004c6:	eb eb                	jmp    8004b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004d6:	eb 17                	jmp    8004ef <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004dc:	78 98                	js     800476 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e1:	eb a7                	jmp    80048a <vprintfmt+0x70>
  8004e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004ed:	eb 9b                	jmp    80048a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f3:	79 95                	jns    80048a <vprintfmt+0x70>
  8004f5:	eb 8b                	jmp    800482 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004fb:	eb 8d                	jmp    80048a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 50 04             	lea    0x4(%eax),%edx
  800503:	89 55 14             	mov    %edx,0x14(%ebp)
  800506:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800515:	e9 23 ff ff ff       	jmp    80043d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 50 04             	lea    0x4(%eax),%edx
  800520:	89 55 14             	mov    %edx,0x14(%ebp)
  800523:	8b 00                	mov    (%eax),%eax
  800525:	85 c0                	test   %eax,%eax
  800527:	79 02                	jns    80052b <vprintfmt+0x111>
  800529:	f7 d8                	neg    %eax
  80052b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052d:	83 f8 11             	cmp    $0x11,%eax
  800530:	7f 0b                	jg     80053d <vprintfmt+0x123>
  800532:	8b 04 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%eax
  800539:	85 c0                	test   %eax,%eax
  80053b:	75 23                	jne    800560 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80053d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800541:	c7 44 24 08 5f 27 80 	movl   $0x80275f,0x8(%esp)
  800548:	00 
  800549:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80054d:	8b 45 08             	mov    0x8(%ebp),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 9a fe ff ff       	call   8003f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80055b:	e9 dd fe ff ff       	jmp    80043d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800560:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800564:	c7 44 24 08 1d 2b 80 	movl   $0x802b1d,0x8(%esp)
  80056b:	00 
  80056c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800570:	8b 55 08             	mov    0x8(%ebp),%edx
  800573:	89 14 24             	mov    %edx,(%esp)
  800576:	e8 77 fe ff ff       	call   8003f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057e:	e9 ba fe ff ff       	jmp    80043d <vprintfmt+0x23>
  800583:	89 f9                	mov    %edi,%ecx
  800585:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800588:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 30                	mov    (%eax),%esi
  800596:	85 f6                	test   %esi,%esi
  800598:	75 05                	jne    80059f <vprintfmt+0x185>
				p = "(null)";
  80059a:	be 58 27 80 00       	mov    $0x802758,%esi
			if (width > 0 && padc != '-')
  80059f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005a3:	0f 8e 84 00 00 00    	jle    80062d <vprintfmt+0x213>
  8005a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005ad:	74 7e                	je     80062d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b3:	89 34 24             	mov    %esi,(%esp)
  8005b6:	e8 8b 02 00 00       	call   800846 <strnlen>
  8005bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005cd:	89 de                	mov    %ebx,%esi
  8005cf:	89 d3                	mov    %edx,%ebx
  8005d1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d3:	eb 0b                	jmp    8005e0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d9:	89 3c 24             	mov    %edi,(%esp)
  8005dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	4b                   	dec    %ebx
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	7f f1                	jg     8005d5 <vprintfmt+0x1bb>
  8005e4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005e7:	89 f3                	mov    %esi,%ebx
  8005e9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	79 05                	jns    8005f8 <vprintfmt+0x1de>
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fb:	29 c2                	sub    %eax,%edx
  8005fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800600:	eb 2b                	jmp    80062d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800602:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800606:	74 18                	je     800620 <vprintfmt+0x206>
  800608:	8d 50 e0             	lea    -0x20(%eax),%edx
  80060b:	83 fa 5e             	cmp    $0x5e,%edx
  80060e:	76 10                	jbe    800620 <vprintfmt+0x206>
					putch('?', putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80061b:	ff 55 08             	call   *0x8(%ebp)
  80061e:	eb 0a                	jmp    80062a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800620:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800624:	89 04 24             	mov    %eax,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062a:	ff 4d e4             	decl   -0x1c(%ebp)
  80062d:	0f be 06             	movsbl (%esi),%eax
  800630:	46                   	inc    %esi
  800631:	85 c0                	test   %eax,%eax
  800633:	74 21                	je     800656 <vprintfmt+0x23c>
  800635:	85 ff                	test   %edi,%edi
  800637:	78 c9                	js     800602 <vprintfmt+0x1e8>
  800639:	4f                   	dec    %edi
  80063a:	79 c6                	jns    800602 <vprintfmt+0x1e8>
  80063c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80063f:	89 de                	mov    %ebx,%esi
  800641:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800644:	eb 18                	jmp    80065e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800651:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800653:	4b                   	dec    %ebx
  800654:	eb 08                	jmp    80065e <vprintfmt+0x244>
  800656:	8b 7d 08             	mov    0x8(%ebp),%edi
  800659:	89 de                	mov    %ebx,%esi
  80065b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80065e:	85 db                	test   %ebx,%ebx
  800660:	7f e4                	jg     800646 <vprintfmt+0x22c>
  800662:	89 7d 08             	mov    %edi,0x8(%ebp)
  800665:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066a:	e9 ce fd ff ff       	jmp    80043d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066f:	83 f9 01             	cmp    $0x1,%ecx
  800672:	7e 10                	jle    800684 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 08             	lea    0x8(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 30                	mov    (%eax),%esi
  80067f:	8b 78 04             	mov    0x4(%eax),%edi
  800682:	eb 26                	jmp    8006aa <vprintfmt+0x290>
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 12                	je     80069a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 30                	mov    (%eax),%esi
  800693:	89 f7                	mov    %esi,%edi
  800695:	c1 ff 1f             	sar    $0x1f,%edi
  800698:	eb 10                	jmp    8006aa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a3:	8b 30                	mov    (%eax),%esi
  8006a5:	89 f7                	mov    %esi,%edi
  8006a7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006aa:	85 ff                	test   %edi,%edi
  8006ac:	78 0a                	js     8006b8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b3:	e9 8c 00 00 00       	jmp    800744 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c6:	f7 de                	neg    %esi
  8006c8:	83 d7 00             	adc    $0x0,%edi
  8006cb:	f7 df                	neg    %edi
			}
			base = 10;
  8006cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d2:	eb 70                	jmp    800744 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d4:	89 ca                	mov    %ecx,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 c0 fc ff ff       	call   80039e <getuint>
  8006de:	89 c6                	mov    %eax,%esi
  8006e0:	89 d7                	mov    %edx,%edi
			base = 10;
  8006e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006e7:	eb 5b                	jmp    800744 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 ab fc ff ff       	call   80039e <getuint>
  8006f3:	89 c6                	mov    %eax,%esi
  8006f5:	89 d7                	mov    %edx,%edi
			base = 8;
  8006f7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006fc:	eb 46                	jmp    800744 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800702:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800709:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800710:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800717:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800723:	8b 30                	mov    (%eax),%esi
  800725:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80072f:	eb 13                	jmp    800744 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800731:	89 ca                	mov    %ecx,%edx
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 63 fc ff ff       	call   80039e <getuint>
  80073b:	89 c6                	mov    %eax,%esi
  80073d:	89 d7                	mov    %edx,%edi
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800744:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800748:	89 54 24 10          	mov    %edx,0x10(%esp)
  80074c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80074f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800753:	89 44 24 08          	mov    %eax,0x8(%esp)
  800757:	89 34 24             	mov    %esi,(%esp)
  80075a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075e:	89 da                	mov    %ebx,%edx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	e8 6c fb ff ff       	call   8002d4 <printnum>
			break;
  800768:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80076b:	e9 cd fc ff ff       	jmp    80043d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800770:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80077d:	e9 bb fc ff ff       	jmp    80043d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800782:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800786:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80078d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800790:	eb 01                	jmp    800793 <vprintfmt+0x379>
  800792:	4e                   	dec    %esi
  800793:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800797:	75 f9                	jne    800792 <vprintfmt+0x378>
  800799:	e9 9f fc ff ff       	jmp    80043d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80079e:	83 c4 4c             	add    $0x4c,%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 28             	sub    $0x28,%esp
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	74 30                	je     8007f7 <vsnprintf+0x51>
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	7e 33                	jle    8007fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	c7 04 24 d8 03 80 00 	movl   $0x8003d8,(%esp)
  8007e7:	e8 2e fc ff ff       	call   80041a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	eb 0c                	jmp    800803 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb 05                	jmp    800803 <vsnprintf+0x5d>
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800812:	8b 45 10             	mov    0x10(%ebp),%eax
  800815:	89 44 24 08          	mov    %eax,0x8(%esp)
  800819:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	89 04 24             	mov    %eax,(%esp)
  800826:	e8 7b ff ff ff       	call   8007a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    
  80082d:	00 00                	add    %al,(%eax)
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 01                	jmp    80083e <strlen+0xe>
		n++;
  80083d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800842:	75 f9                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	b8 00 00 00 00       	mov    $0x0,%eax
  800854:	eb 01                	jmp    800857 <strnlen+0x11>
		n++;
  800856:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800857:	39 d0                	cmp    %edx,%eax
  800859:	74 06                	je     800861 <strnlen+0x1b>
  80085b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80085f:	75 f5                	jne    800856 <strnlen+0x10>
		n++;
	return n;
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086d:	ba 00 00 00 00       	mov    $0x0,%edx
  800872:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800875:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800878:	42                   	inc    %edx
  800879:	84 c9                	test   %cl,%cl
  80087b:	75 f5                	jne    800872 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	53                   	push   %ebx
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088a:	89 1c 24             	mov    %ebx,(%esp)
  80088d:	e8 9e ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
  800895:	89 54 24 04          	mov    %edx,0x4(%esp)
  800899:	01 d8                	add    %ebx,%eax
  80089b:	89 04 24             	mov    %eax,(%esp)
  80089e:	e8 c0 ff ff ff       	call   800863 <strcpy>
	return dst;
}
  8008a3:	89 d8                	mov    %ebx,%eax
  8008a5:	83 c4 08             	add    $0x8,%esp
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008be:	eb 0c                	jmp    8008cc <strncpy+0x21>
		*dst++ = *src;
  8008c0:	8a 1a                	mov    (%edx),%bl
  8008c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008cb:	41                   	inc    %ecx
  8008cc:	39 f1                	cmp    %esi,%ecx
  8008ce:	75 f0                	jne    8008c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	75 0a                	jne    8008f0 <strlcpy+0x1c>
  8008e6:	89 f0                	mov    %esi,%eax
  8008e8:	eb 1a                	jmp    800904 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ea:	88 18                	mov    %bl,(%eax)
  8008ec:	40                   	inc    %eax
  8008ed:	41                   	inc    %ecx
  8008ee:	eb 02                	jmp    8008f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008f2:	4a                   	dec    %edx
  8008f3:	74 0a                	je     8008ff <strlcpy+0x2b>
  8008f5:	8a 19                	mov    (%ecx),%bl
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	75 ef                	jne    8008ea <strlcpy+0x16>
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	eb 02                	jmp    800901 <strlcpy+0x2d>
  8008ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800901:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800904:	29 f0                	sub    %esi,%eax
}
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800910:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800913:	eb 02                	jmp    800917 <strcmp+0xd>
		p++, q++;
  800915:	41                   	inc    %ecx
  800916:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800917:	8a 01                	mov    (%ecx),%al
  800919:	84 c0                	test   %al,%al
  80091b:	74 04                	je     800921 <strcmp+0x17>
  80091d:	3a 02                	cmp    (%edx),%al
  80091f:	74 f4                	je     800915 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800921:	0f b6 c0             	movzbl %al,%eax
  800924:	0f b6 12             	movzbl (%edx),%edx
  800927:	29 d0                	sub    %edx,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800935:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800938:	eb 03                	jmp    80093d <strncmp+0x12>
		n--, p++, q++;
  80093a:	4a                   	dec    %edx
  80093b:	40                   	inc    %eax
  80093c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093d:	85 d2                	test   %edx,%edx
  80093f:	74 14                	je     800955 <strncmp+0x2a>
  800941:	8a 18                	mov    (%eax),%bl
  800943:	84 db                	test   %bl,%bl
  800945:	74 04                	je     80094b <strncmp+0x20>
  800947:	3a 19                	cmp    (%ecx),%bl
  800949:	74 ef                	je     80093a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094b:	0f b6 00             	movzbl (%eax),%eax
  80094e:	0f b6 11             	movzbl (%ecx),%edx
  800951:	29 d0                	sub    %edx,%eax
  800953:	eb 05                	jmp    80095a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800966:	eb 05                	jmp    80096d <strchr+0x10>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 0c                	je     800978 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096c:	40                   	inc    %eax
  80096d:	8a 10                	mov    (%eax),%dl
  80096f:	84 d2                	test   %dl,%dl
  800971:	75 f5                	jne    800968 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800983:	eb 05                	jmp    80098a <strfind+0x10>
		if (*s == c)
  800985:	38 ca                	cmp    %cl,%dl
  800987:	74 07                	je     800990 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800989:	40                   	inc    %eax
  80098a:	8a 10                	mov    (%eax),%dl
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f5                	jne    800985 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 30                	je     8009d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ab:	75 25                	jne    8009d2 <memset+0x40>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 20                	jne    8009d2 <memset+0x40>
		c &= 0xFF;
  8009b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b5:	89 d3                	mov    %edx,%ebx
  8009b7:	c1 e3 08             	shl    $0x8,%ebx
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	c1 e6 18             	shl    $0x18,%esi
  8009bf:	89 d0                	mov    %edx,%eax
  8009c1:	c1 e0 10             	shl    $0x10,%eax
  8009c4:	09 f0                	or     %esi,%eax
  8009c6:	09 d0                	or     %edx,%eax
  8009c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009cd:	fc                   	cld    
  8009ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d0:	eb 03                	jmp    8009d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d2:	fc                   	cld    
  8009d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d5:	89 f8                	mov    %edi,%eax
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	57                   	push   %edi
  8009e0:	56                   	push   %esi
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ea:	39 c6                	cmp    %eax,%esi
  8009ec:	73 34                	jae    800a22 <memmove+0x46>
  8009ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f1:	39 d0                	cmp    %edx,%eax
  8009f3:	73 2d                	jae    800a22 <memmove+0x46>
		s += n;
		d += n;
  8009f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f8:	f6 c2 03             	test   $0x3,%dl
  8009fb:	75 1b                	jne    800a18 <memmove+0x3c>
  8009fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a03:	75 13                	jne    800a18 <memmove+0x3c>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 0e                	jne    800a18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0a:	83 ef 04             	sub    $0x4,%edi
  800a0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a13:	fd                   	std    
  800a14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a16:	eb 07                	jmp    800a1f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a18:	4f                   	dec    %edi
  800a19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a1c:	fd                   	std    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1f:	fc                   	cld    
  800a20:	eb 20                	jmp    800a42 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a28:	75 13                	jne    800a3d <memmove+0x61>
  800a2a:	a8 03                	test   $0x3,%al
  800a2c:	75 0f                	jne    800a3d <memmove+0x61>
  800a2e:	f6 c1 03             	test   $0x3,%cl
  800a31:	75 0a                	jne    800a3d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a36:	89 c7                	mov    %eax,%edi
  800a38:	fc                   	cld    
  800a39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3b:	eb 05                	jmp    800a42 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3d:	89 c7                	mov    %eax,%edi
  800a3f:	fc                   	cld    
  800a40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	89 04 24             	mov    %eax,(%esp)
  800a60:	e8 77 ff ff ff       	call   8009dc <memmove>
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a76:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7b:	eb 16                	jmp    800a93 <memcmp+0x2c>
		if (*s1 != *s2)
  800a7d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a80:	42                   	inc    %edx
  800a81:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a85:	38 c8                	cmp    %cl,%al
  800a87:	74 0a                	je     800a93 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a89:	0f b6 c0             	movzbl %al,%eax
  800a8c:	0f b6 c9             	movzbl %cl,%ecx
  800a8f:	29 c8                	sub    %ecx,%eax
  800a91:	eb 09                	jmp    800a9c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a93:	39 da                	cmp    %ebx,%edx
  800a95:	75 e6                	jne    800a7d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aaa:	89 c2                	mov    %eax,%edx
  800aac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aaf:	eb 05                	jmp    800ab6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab1:	38 08                	cmp    %cl,(%eax)
  800ab3:	74 05                	je     800aba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab5:	40                   	inc    %eax
  800ab6:	39 d0                	cmp    %edx,%eax
  800ab8:	72 f7                	jb     800ab1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac8:	eb 01                	jmp    800acb <strtol+0xf>
		s++;
  800aca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acb:	8a 02                	mov    (%edx),%al
  800acd:	3c 20                	cmp    $0x20,%al
  800acf:	74 f9                	je     800aca <strtol+0xe>
  800ad1:	3c 09                	cmp    $0x9,%al
  800ad3:	74 f5                	je     800aca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad5:	3c 2b                	cmp    $0x2b,%al
  800ad7:	75 08                	jne    800ae1 <strtol+0x25>
		s++;
  800ad9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ada:	bf 00 00 00 00       	mov    $0x0,%edi
  800adf:	eb 13                	jmp    800af4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae1:	3c 2d                	cmp    $0x2d,%al
  800ae3:	75 0a                	jne    800aef <strtol+0x33>
		s++, neg = 1;
  800ae5:	8d 52 01             	lea    0x1(%edx),%edx
  800ae8:	bf 01 00 00 00       	mov    $0x1,%edi
  800aed:	eb 05                	jmp    800af4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af4:	85 db                	test   %ebx,%ebx
  800af6:	74 05                	je     800afd <strtol+0x41>
  800af8:	83 fb 10             	cmp    $0x10,%ebx
  800afb:	75 28                	jne    800b25 <strtol+0x69>
  800afd:	8a 02                	mov    (%edx),%al
  800aff:	3c 30                	cmp    $0x30,%al
  800b01:	75 10                	jne    800b13 <strtol+0x57>
  800b03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b07:	75 0a                	jne    800b13 <strtol+0x57>
		s += 2, base = 16;
  800b09:	83 c2 02             	add    $0x2,%edx
  800b0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b11:	eb 12                	jmp    800b25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	75 0e                	jne    800b25 <strtol+0x69>
  800b17:	3c 30                	cmp    $0x30,%al
  800b19:	75 05                	jne    800b20 <strtol+0x64>
		s++, base = 8;
  800b1b:	42                   	inc    %edx
  800b1c:	b3 08                	mov    $0x8,%bl
  800b1e:	eb 05                	jmp    800b25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2c:	8a 0a                	mov    (%edx),%cl
  800b2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b31:	80 fb 09             	cmp    $0x9,%bl
  800b34:	77 08                	ja     800b3e <strtol+0x82>
			dig = *s - '0';
  800b36:	0f be c9             	movsbl %cl,%ecx
  800b39:	83 e9 30             	sub    $0x30,%ecx
  800b3c:	eb 1e                	jmp    800b5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 08                	ja     800b4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 57             	sub    $0x57,%ecx
  800b4c:	eb 0e                	jmp    800b5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 12                	ja     800b68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b56:	0f be c9             	movsbl %cl,%ecx
  800b59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b5c:	39 f1                	cmp    %esi,%ecx
  800b5e:	7d 0c                	jge    800b6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b60:	42                   	inc    %edx
  800b61:	0f af c6             	imul   %esi,%eax
  800b64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b66:	eb c4                	jmp    800b2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b68:	89 c1                	mov    %eax,%ecx
  800b6a:	eb 02                	jmp    800b6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b72:	74 05                	je     800b79 <strtol+0xbd>
		*endptr = (char *) s;
  800b74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	74 04                	je     800b81 <strtol+0xc5>
  800b7d:	89 c8                	mov    %ecx,%eax
  800b7f:	f7 d8                	neg    %eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    
	...

00800b88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 c3                	mov    %eax,%ebx
  800b9b:	89 c7                	mov    %eax,%edi
  800b9d:	89 c6                	mov    %eax,%esi
  800b9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 cb                	mov    %ecx,%ebx
  800bdd:	89 cf                	mov    %ecx,%edi
  800bdf:	89 ce                	mov    %ecx,%esi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 28                	jle    800c0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800beb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c02:	00 
  800c03:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800c0a:	e8 b1 f5 ff ff       	call   8001c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c0f:	83 c4 2c             	add    $0x2c,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c22:	b8 02 00 00 00       	mov    $0x2,%eax
  800c27:	89 d1                	mov    %edx,%ecx
  800c29:	89 d3                	mov    %edx,%ebx
  800c2b:	89 d7                	mov    %edx,%edi
  800c2d:	89 d6                	mov    %edx,%esi
  800c2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_yield>:

void
sys_yield(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 04 00 00 00       	mov    $0x4,%eax
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 f7                	mov    %esi,%edi
  800c73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7e 28                	jle    800ca1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c84:	00 
  800c85:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c94:	00 
  800c95:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800c9c:	e8 1f f5 ff ff       	call   8001c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca1:	83 c4 2c             	add    $0x2c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 28                	jle    800cf4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce7:	00 
  800ce8:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800cef:	e8 cc f4 ff ff       	call   8001c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cf4:	83 c4 2c             	add    $0x2c,%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	7e 28                	jle    800d47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800d32:	00 
  800d33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3a:	00 
  800d3b:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800d42:	e8 79 f4 ff ff       	call   8001c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d47:	83 c4 2c             	add    $0x2c,%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800d58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	89 df                	mov    %ebx,%edi
  800d6a:	89 de                	mov    %ebx,%esi
  800d6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	7e 28                	jle    800d9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d7d:	00 
  800d7e:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800d85:	00 
  800d86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8d:	00 
  800d8e:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800d95:	e8 26 f4 ff ff       	call   8001c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9a:	83 c4 2c             	add    $0x2c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 09 00 00 00       	mov    $0x9,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 28                	jle    800ded <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de0:	00 
  800de1:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800de8:	e8 d3 f3 ff ff       	call   8001c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ded:	83 c4 2c             	add    $0x2c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	89 df                	mov    %ebx,%edi
  800e10:	89 de                	mov    %ebx,%esi
  800e12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7e 28                	jle    800e40 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e23:	00 
  800e24:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800e2b:	00 
  800e2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e33:	00 
  800e34:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800e3b:	e8 80 f3 ff ff       	call   8001c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e40:	83 c4 2c             	add    $0x2c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	be 00 00 00 00       	mov    $0x0,%esi
  800e53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e58:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 cb                	mov    %ecx,%ebx
  800e83:	89 cf                	mov    %ecx,%edi
  800e85:	89 ce                	mov    %ecx,%esi
  800e87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 28                	jle    800eb5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e91:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e98:	00 
  800e99:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
  800ea0:	00 
  800ea1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea8:	00 
  800ea9:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  800eb0:	e8 0b f3 ff ff       	call   8001c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb5:	83 c4 2c             	add    $0x2c,%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ecd:	89 d1                	mov    %edx,%ecx
  800ecf:	89 d3                	mov    %edx,%ebx
  800ed1:	89 d7                	mov    %edx,%edi
  800ed3:	89 d6                	mov    %edx,%esi
  800ed5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee7:	b8 10 00 00 00       	mov    $0x10,%eax
  800eec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef2:	89 df                	mov    %ebx,%edi
  800ef4:	89 de                	mov    %ebx,%esi
  800ef6:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f08:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	89 df                	mov    %ebx,%edi
  800f15:	89 de                	mov    %ebx,%esi
  800f17:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f29:	b8 11 00 00 00       	mov    $0x11,%eax
  800f2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f31:	89 cb                	mov    %ecx,%ebx
  800f33:	89 cf                	mov    %ecx,%edi
  800f35:	89 ce                	mov    %ecx,%esi
  800f37:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    
	...

00800f40 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	05 00 00 00 30       	add    $0x30000000,%eax
  800f4b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
  800f59:	89 04 24             	mov    %eax,(%esp)
  800f5c:	e8 df ff ff ff       	call   800f40 <fd2num>
  800f61:	05 20 00 0d 00       	add    $0xd0020,%eax
  800f66:	c1 e0 0c             	shl    $0xc,%eax
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	53                   	push   %ebx
  800f6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800f72:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f77:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f79:	89 c2                	mov    %eax,%edx
  800f7b:	c1 ea 16             	shr    $0x16,%edx
  800f7e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f85:	f6 c2 01             	test   $0x1,%dl
  800f88:	74 11                	je     800f9b <fd_alloc+0x30>
  800f8a:	89 c2                	mov    %eax,%edx
  800f8c:	c1 ea 0c             	shr    $0xc,%edx
  800f8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f96:	f6 c2 01             	test   $0x1,%dl
  800f99:	75 09                	jne    800fa4 <fd_alloc+0x39>
			*fd_store = fd;
  800f9b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa2:	eb 17                	jmp    800fbb <fd_alloc+0x50>
  800fa4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800fa9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fae:	75 c7                	jne    800f77 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fb0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800fb6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800fbb:	5b                   	pop    %ebx
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fc4:	83 f8 1f             	cmp    $0x1f,%eax
  800fc7:	77 36                	ja     800fff <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fc9:	05 00 00 0d 00       	add    $0xd0000,%eax
  800fce:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	c1 ea 16             	shr    $0x16,%edx
  800fd6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fdd:	f6 c2 01             	test   $0x1,%dl
  800fe0:	74 24                	je     801006 <fd_lookup+0x48>
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	c1 ea 0c             	shr    $0xc,%edx
  800fe7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fee:	f6 c2 01             	test   $0x1,%dl
  800ff1:	74 1a                	je     80100d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ff3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff6:	89 02                	mov    %eax,(%edx)
	return 0;
  800ff8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ffd:	eb 13                	jmp    801012 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801004:	eb 0c                	jmp    801012 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801006:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80100b:	eb 05                	jmp    801012 <fd_lookup+0x54>
  80100d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	53                   	push   %ebx
  801018:	83 ec 14             	sub    $0x14,%esp
  80101b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801021:	ba 00 00 00 00       	mov    $0x0,%edx
  801026:	eb 0e                	jmp    801036 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801028:	39 08                	cmp    %ecx,(%eax)
  80102a:	75 09                	jne    801035 <dev_lookup+0x21>
			*dev = devtab[i];
  80102c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80102e:	b8 00 00 00 00       	mov    $0x0,%eax
  801033:	eb 33                	jmp    801068 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801035:	42                   	inc    %edx
  801036:	8b 04 95 f0 2a 80 00 	mov    0x802af0(,%edx,4),%eax
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 e7                	jne    801028 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801041:	a1 20 60 80 00       	mov    0x806020,%eax
  801046:	8b 40 48             	mov    0x48(%eax),%eax
  801049:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801051:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  801058:	e8 5b f2 ff ff       	call   8002b8 <cprintf>
	*dev = 0;
  80105d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801063:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801068:	83 c4 14             	add    $0x14,%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 30             	sub    $0x30,%esp
  801076:	8b 75 08             	mov    0x8(%ebp),%esi
  801079:	8a 45 0c             	mov    0xc(%ebp),%al
  80107c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80107f:	89 34 24             	mov    %esi,(%esp)
  801082:	e8 b9 fe ff ff       	call   800f40 <fd2num>
  801087:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80108a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80108e:	89 04 24             	mov    %eax,(%esp)
  801091:	e8 28 ff ff ff       	call   800fbe <fd_lookup>
  801096:	89 c3                	mov    %eax,%ebx
  801098:	85 c0                	test   %eax,%eax
  80109a:	78 05                	js     8010a1 <fd_close+0x33>
	    || fd != fd2)
  80109c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80109f:	74 0d                	je     8010ae <fd_close+0x40>
		return (must_exist ? r : 0);
  8010a1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8010a5:	75 46                	jne    8010ed <fd_close+0x7f>
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ac:	eb 3f                	jmp    8010ed <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b5:	8b 06                	mov    (%esi),%eax
  8010b7:	89 04 24             	mov    %eax,(%esp)
  8010ba:	e8 55 ff ff ff       	call   801014 <dev_lookup>
  8010bf:	89 c3                	mov    %eax,%ebx
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 18                	js     8010dd <fd_close+0x6f>
		if (dev->dev_close)
  8010c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c8:	8b 40 10             	mov    0x10(%eax),%eax
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	74 09                	je     8010d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8010cf:	89 34 24             	mov    %esi,(%esp)
  8010d2:	ff d0                	call   *%eax
  8010d4:	89 c3                	mov    %eax,%ebx
  8010d6:	eb 05                	jmp    8010dd <fd_close+0x6f>
		else
			r = 0;
  8010d8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8010dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e8:	e8 0f fc ff ff       	call   800cfc <sys_page_unmap>
	return r;
}
  8010ed:	89 d8                	mov    %ebx,%eax
  8010ef:	83 c4 30             	add    $0x30,%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	89 04 24             	mov    %eax,(%esp)
  801109:	e8 b0 fe ff ff       	call   800fbe <fd_lookup>
  80110e:	85 c0                	test   %eax,%eax
  801110:	78 13                	js     801125 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801112:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801119:	00 
  80111a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 49 ff ff ff       	call   80106e <fd_close>
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <close_all>:

void
close_all(void)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	53                   	push   %ebx
  80112b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80112e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801133:	89 1c 24             	mov    %ebx,(%esp)
  801136:	e8 bb ff ff ff       	call   8010f6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80113b:	43                   	inc    %ebx
  80113c:	83 fb 20             	cmp    $0x20,%ebx
  80113f:	75 f2                	jne    801133 <close_all+0xc>
		close(i);
}
  801141:	83 c4 14             	add    $0x14,%esp
  801144:	5b                   	pop    %ebx
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 4c             	sub    $0x4c,%esp
  801150:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801153:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80115a:	8b 45 08             	mov    0x8(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	e8 59 fe ff ff       	call   800fbe <fd_lookup>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	85 c0                	test   %eax,%eax
  801169:	0f 88 e1 00 00 00    	js     801250 <dup+0x109>
		return r;
	close(newfdnum);
  80116f:	89 3c 24             	mov    %edi,(%esp)
  801172:	e8 7f ff ff ff       	call   8010f6 <close>

	newfd = INDEX2FD(newfdnum);
  801177:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80117d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801180:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801183:	89 04 24             	mov    %eax,(%esp)
  801186:	e8 c5 fd ff ff       	call   800f50 <fd2data>
  80118b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80118d:	89 34 24             	mov    %esi,(%esp)
  801190:	e8 bb fd ff ff       	call   800f50 <fd2data>
  801195:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801198:	89 d8                	mov    %ebx,%eax
  80119a:	c1 e8 16             	shr    $0x16,%eax
  80119d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011a4:	a8 01                	test   $0x1,%al
  8011a6:	74 46                	je     8011ee <dup+0xa7>
  8011a8:	89 d8                	mov    %ebx,%eax
  8011aa:	c1 e8 0c             	shr    $0xc,%eax
  8011ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011b4:	f6 c2 01             	test   $0x1,%dl
  8011b7:	74 35                	je     8011ee <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8011c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d7:	00 
  8011d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e3:	e8 c1 fa ff ff       	call   800ca9 <sys_page_map>
  8011e8:	89 c3                	mov    %eax,%ebx
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 3b                	js     801229 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 0c             	shr    $0xc,%edx
  8011f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801203:	89 54 24 10          	mov    %edx,0x10(%esp)
  801207:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80120b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801212:	00 
  801213:	89 44 24 04          	mov    %eax,0x4(%esp)
  801217:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121e:	e8 86 fa ff ff       	call   800ca9 <sys_page_map>
  801223:	89 c3                	mov    %eax,%ebx
  801225:	85 c0                	test   %eax,%eax
  801227:	79 25                	jns    80124e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801229:	89 74 24 04          	mov    %esi,0x4(%esp)
  80122d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801234:	e8 c3 fa ff ff       	call   800cfc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801239:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80123c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801247:	e8 b0 fa ff ff       	call   800cfc <sys_page_unmap>
	return r;
  80124c:	eb 02                	jmp    801250 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80124e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801250:	89 d8                	mov    %ebx,%eax
  801252:	83 c4 4c             	add    $0x4c,%esp
  801255:	5b                   	pop    %ebx
  801256:	5e                   	pop    %esi
  801257:	5f                   	pop    %edi
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 24             	sub    $0x24,%esp
  801261:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126b:	89 1c 24             	mov    %ebx,(%esp)
  80126e:	e8 4b fd ff ff       	call   800fbe <fd_lookup>
  801273:	85 c0                	test   %eax,%eax
  801275:	78 6d                	js     8012e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	8b 00                	mov    (%eax),%eax
  801283:	89 04 24             	mov    %eax,(%esp)
  801286:	e8 89 fd ff ff       	call   801014 <dev_lookup>
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 55                	js     8012e4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80128f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801292:	8b 50 08             	mov    0x8(%eax),%edx
  801295:	83 e2 03             	and    $0x3,%edx
  801298:	83 fa 01             	cmp    $0x1,%edx
  80129b:	75 23                	jne    8012c0 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80129d:	a1 20 60 80 00       	mov    0x806020,%eax
  8012a2:	8b 40 48             	mov    0x48(%eax),%eax
  8012a5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ad:	c7 04 24 b5 2a 80 00 	movl   $0x802ab5,(%esp)
  8012b4:	e8 ff ef ff ff       	call   8002b8 <cprintf>
		return -E_INVAL;
  8012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012be:	eb 24                	jmp    8012e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8012c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c3:	8b 52 08             	mov    0x8(%edx),%edx
  8012c6:	85 d2                	test   %edx,%edx
  8012c8:	74 15                	je     8012df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	ff d2                	call   *%edx
  8012dd:	eb 05                	jmp    8012e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8012df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8012e4:	83 c4 24             	add    $0x24,%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	57                   	push   %edi
  8012ee:	56                   	push   %esi
  8012ef:	53                   	push   %ebx
  8012f0:	83 ec 1c             	sub    $0x1c,%esp
  8012f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fe:	eb 23                	jmp    801323 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801300:	89 f0                	mov    %esi,%eax
  801302:	29 d8                	sub    %ebx,%eax
  801304:	89 44 24 08          	mov    %eax,0x8(%esp)
  801308:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130b:	01 d8                	add    %ebx,%eax
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	89 3c 24             	mov    %edi,(%esp)
  801314:	e8 41 ff ff ff       	call   80125a <read>
		if (m < 0)
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 10                	js     80132d <readn+0x43>
			return m;
		if (m == 0)
  80131d:	85 c0                	test   %eax,%eax
  80131f:	74 0a                	je     80132b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801321:	01 c3                	add    %eax,%ebx
  801323:	39 f3                	cmp    %esi,%ebx
  801325:	72 d9                	jb     801300 <readn+0x16>
  801327:	89 d8                	mov    %ebx,%eax
  801329:	eb 02                	jmp    80132d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80132b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80132d:	83 c4 1c             	add    $0x1c,%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	53                   	push   %ebx
  801339:	83 ec 24             	sub    $0x24,%esp
  80133c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	89 1c 24             	mov    %ebx,(%esp)
  801349:	e8 70 fc ff ff       	call   800fbe <fd_lookup>
  80134e:	85 c0                	test   %eax,%eax
  801350:	78 68                	js     8013ba <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135c:	8b 00                	mov    (%eax),%eax
  80135e:	89 04 24             	mov    %eax,(%esp)
  801361:	e8 ae fc ff ff       	call   801014 <dev_lookup>
  801366:	85 c0                	test   %eax,%eax
  801368:	78 50                	js     8013ba <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801371:	75 23                	jne    801396 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801373:	a1 20 60 80 00       	mov    0x806020,%eax
  801378:	8b 40 48             	mov    0x48(%eax),%eax
  80137b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80137f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801383:	c7 04 24 d1 2a 80 00 	movl   $0x802ad1,(%esp)
  80138a:	e8 29 ef ff ff       	call   8002b8 <cprintf>
		return -E_INVAL;
  80138f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801394:	eb 24                	jmp    8013ba <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801396:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801399:	8b 52 0c             	mov    0xc(%edx),%edx
  80139c:	85 d2                	test   %edx,%edx
  80139e:	74 15                	je     8013b5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013aa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	ff d2                	call   *%edx
  8013b3:	eb 05                	jmp    8013ba <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8013b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8013ba:	83 c4 24             	add    $0x24,%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 e6 fb ff ff       	call   800fbe <fd_lookup>
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	78 0e                	js     8013ea <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 24             	sub    $0x24,%esp
  8013f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fd:	89 1c 24             	mov    %ebx,(%esp)
  801400:	e8 b9 fb ff ff       	call   800fbe <fd_lookup>
  801405:	85 c0                	test   %eax,%eax
  801407:	78 61                	js     80146a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801409:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801410:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801413:	8b 00                	mov    (%eax),%eax
  801415:	89 04 24             	mov    %eax,(%esp)
  801418:	e8 f7 fb ff ff       	call   801014 <dev_lookup>
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 49                	js     80146a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801424:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801428:	75 23                	jne    80144d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80142a:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80142f:	8b 40 48             	mov    0x48(%eax),%eax
  801432:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801436:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143a:	c7 04 24 94 2a 80 00 	movl   $0x802a94,(%esp)
  801441:	e8 72 ee ff ff       	call   8002b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801446:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144b:	eb 1d                	jmp    80146a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80144d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801450:	8b 52 18             	mov    0x18(%edx),%edx
  801453:	85 d2                	test   %edx,%edx
  801455:	74 0e                	je     801465 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801457:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80145e:	89 04 24             	mov    %eax,(%esp)
  801461:	ff d2                	call   *%edx
  801463:	eb 05                	jmp    80146a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801465:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80146a:	83 c4 24             	add    $0x24,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	53                   	push   %ebx
  801474:	83 ec 24             	sub    $0x24,%esp
  801477:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	89 04 24             	mov    %eax,(%esp)
  801487:	e8 32 fb ff ff       	call   800fbe <fd_lookup>
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 52                	js     8014e2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801490:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149a:	8b 00                	mov    (%eax),%eax
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	e8 70 fb ff ff       	call   801014 <dev_lookup>
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 3a                	js     8014e2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8014af:	74 2c                	je     8014dd <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8014b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8014b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014bb:	00 00 00 
	stat->st_isdir = 0;
  8014be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014c5:	00 00 00 
	stat->st_dev = dev;
  8014c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d5:	89 14 24             	mov    %edx,(%esp)
  8014d8:	ff 50 14             	call   *0x14(%eax)
  8014db:	eb 05                	jmp    8014e2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8014dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8014e2:	83 c4 24             	add    $0x24,%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014f7:	00 
  8014f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	e8 2d 02 00 00       	call   801730 <open>
  801503:	89 c3                	mov    %eax,%ebx
  801505:	85 c0                	test   %eax,%eax
  801507:	78 1b                	js     801524 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801510:	89 1c 24             	mov    %ebx,(%esp)
  801513:	e8 58 ff ff ff       	call   801470 <fstat>
  801518:	89 c6                	mov    %eax,%esi
	close(fd);
  80151a:	89 1c 24             	mov    %ebx,(%esp)
  80151d:	e8 d4 fb ff ff       	call   8010f6 <close>
	return r;
  801522:	89 f3                	mov    %esi,%ebx
}
  801524:	89 d8                	mov    %ebx,%eax
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	5b                   	pop    %ebx
  80152a:	5e                   	pop    %esi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    
  80152d:	00 00                	add    %al,(%eax)
	...

00801530 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	56                   	push   %esi
  801534:	53                   	push   %ebx
  801535:	83 ec 10             	sub    $0x10,%esp
  801538:	89 c3                	mov    %eax,%ebx
  80153a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80153c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801543:	75 11                	jne    801556 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801545:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80154c:	e8 a2 0e 00 00       	call   8023f3 <ipc_find_env>
  801551:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801556:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80155d:	00 
  80155e:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801565:	00 
  801566:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80156a:	a1 00 40 80 00       	mov    0x804000,%eax
  80156f:	89 04 24             	mov    %eax,(%esp)
  801572:	e8 0e 0e 00 00       	call   802385 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801577:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80157e:	00 
  80157f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801583:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158a:	e8 8d 0d 00 00       	call   80231c <ipc_recv>
}
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80159c:	8b 45 08             	mov    0x8(%ebp),%eax
  80159f:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a2:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015aa:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8015af:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8015b9:	e8 72 ff ff ff       	call   801530 <fsipc>
}
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8015cc:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8015d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8015db:	e8 50 ff ff ff       	call   801530 <fsipc>
}
  8015e0:	c9                   	leave  
  8015e1:	c3                   	ret    

008015e2 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 14             	sub    $0x14,%esp
  8015e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8015f2:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fc:	b8 05 00 00 00       	mov    $0x5,%eax
  801601:	e8 2a ff ff ff       	call   801530 <fsipc>
  801606:	85 c0                	test   %eax,%eax
  801608:	78 2b                	js     801635 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80160a:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801611:	00 
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 49 f2 ff ff       	call   800863 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80161a:	a1 80 70 80 00       	mov    0x807080,%eax
  80161f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801625:	a1 84 70 80 00       	mov    0x807084,%eax
  80162a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801630:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801635:	83 c4 14             	add    $0x14,%esp
  801638:	5b                   	pop    %ebx
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	83 ec 18             	sub    $0x18,%esp
  801641:	8b 55 10             	mov    0x10(%ebp),%edx
  801644:	89 d0                	mov    %edx,%eax
  801646:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80164c:	76 05                	jbe    801653 <devfile_write+0x18>
  80164e:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801653:	8b 55 08             	mov    0x8(%ebp),%edx
  801656:	8b 52 0c             	mov    0xc(%edx),%edx
  801659:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80165f:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801664:	89 44 24 08          	mov    %eax,0x8(%esp)
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166f:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801676:	e8 61 f3 ff ff       	call   8009dc <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  80167b:	ba 00 00 00 00       	mov    $0x0,%edx
  801680:	b8 04 00 00 00       	mov    $0x4,%eax
  801685:	e8 a6 fe ff ff       	call   801530 <fsipc>
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 10             	sub    $0x10,%esp
  801694:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801697:	8b 45 08             	mov    0x8(%ebp),%eax
  80169a:	8b 40 0c             	mov    0xc(%eax),%eax
  80169d:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8016a2:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ad:	b8 03 00 00 00       	mov    $0x3,%eax
  8016b2:	e8 79 fe ff ff       	call   801530 <fsipc>
  8016b7:	89 c3                	mov    %eax,%ebx
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 6a                	js     801727 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8016bd:	39 c6                	cmp    %eax,%esi
  8016bf:	73 24                	jae    8016e5 <devfile_read+0x59>
  8016c1:	c7 44 24 0c 04 2b 80 	movl   $0x802b04,0xc(%esp)
  8016c8:	00 
  8016c9:	c7 44 24 08 0b 2b 80 	movl   $0x802b0b,0x8(%esp)
  8016d0:	00 
  8016d1:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8016d8:	00 
  8016d9:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  8016e0:	e8 db ea ff ff       	call   8001c0 <_panic>
	assert(r <= PGSIZE);
  8016e5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8016ea:	7e 24                	jle    801710 <devfile_read+0x84>
  8016ec:	c7 44 24 0c 2b 2b 80 	movl   $0x802b2b,0xc(%esp)
  8016f3:	00 
  8016f4:	c7 44 24 08 0b 2b 80 	movl   $0x802b0b,0x8(%esp)
  8016fb:	00 
  8016fc:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801703:	00 
  801704:	c7 04 24 20 2b 80 00 	movl   $0x802b20,(%esp)
  80170b:	e8 b0 ea ff ff       	call   8001c0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801710:	89 44 24 08          	mov    %eax,0x8(%esp)
  801714:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80171b:	00 
  80171c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80171f:	89 04 24             	mov    %eax,(%esp)
  801722:	e8 b5 f2 ff ff       	call   8009dc <memmove>
	return r;
}
  801727:	89 d8                	mov    %ebx,%eax
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	83 ec 20             	sub    $0x20,%esp
  801738:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80173b:	89 34 24             	mov    %esi,(%esp)
  80173e:	e8 ed f0 ff ff       	call   800830 <strlen>
  801743:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801748:	7f 60                	jg     8017aa <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80174a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174d:	89 04 24             	mov    %eax,(%esp)
  801750:	e8 16 f8 ff ff       	call   800f6b <fd_alloc>
  801755:	89 c3                	mov    %eax,%ebx
  801757:	85 c0                	test   %eax,%eax
  801759:	78 54                	js     8017af <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80175b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80175f:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801766:	e8 f8 f0 ff ff       	call   800863 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801773:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801776:	b8 01 00 00 00       	mov    $0x1,%eax
  80177b:	e8 b0 fd ff ff       	call   801530 <fsipc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	85 c0                	test   %eax,%eax
  801784:	79 15                	jns    80179b <open+0x6b>
		fd_close(fd, 0);
  801786:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80178d:	00 
  80178e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 d5 f8 ff ff       	call   80106e <fd_close>
		return r;
  801799:	eb 14                	jmp    8017af <open+0x7f>
	}

	return fd2num(fd);
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	89 04 24             	mov    %eax,(%esp)
  8017a1:	e8 9a f7 ff ff       	call   800f40 <fd2num>
  8017a6:	89 c3                	mov    %eax,%ebx
  8017a8:	eb 05                	jmp    8017af <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017aa:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017af:	89 d8                	mov    %ebx,%eax
  8017b1:	83 c4 20             	add    $0x20,%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8017c8:	e8 63 fd ff ff       	call   801530 <fsipc>
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    
	...

008017d0 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 14             	sub    $0x14,%esp
  8017d7:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  8017d9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8017dd:	7e 32                	jle    801811 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  8017df:	8b 40 04             	mov    0x4(%eax),%eax
  8017e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e6:	8d 43 10             	lea    0x10(%ebx),%eax
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	8b 03                	mov    (%ebx),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 3e fb ff ff       	call   801335 <write>
		if (result > 0)
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	7e 03                	jle    8017fe <writebuf+0x2e>
			b->result += result;
  8017fb:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8017fe:	39 43 04             	cmp    %eax,0x4(%ebx)
  801801:	74 0e                	je     801811 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801803:	89 c2                	mov    %eax,%edx
  801805:	85 c0                	test   %eax,%eax
  801807:	7e 05                	jle    80180e <writebuf+0x3e>
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801811:	83 c4 14             	add    $0x14,%esp
  801814:	5b                   	pop    %ebx
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    

00801817 <putch>:

static void
putch(int ch, void *thunk)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	53                   	push   %ebx
  80181b:	83 ec 04             	sub    $0x4,%esp
  80181e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801821:	8b 43 04             	mov    0x4(%ebx),%eax
  801824:	8b 55 08             	mov    0x8(%ebp),%edx
  801827:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80182b:	40                   	inc    %eax
  80182c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  80182f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801834:	75 0e                	jne    801844 <putch+0x2d>
		writebuf(b);
  801836:	89 d8                	mov    %ebx,%eax
  801838:	e8 93 ff ff ff       	call   8017d0 <writebuf>
		b->idx = 0;
  80183d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801844:	83 c4 04             	add    $0x4,%esp
  801847:	5b                   	pop    %ebx
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80185c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801863:	00 00 00 
	b.result = 0;
  801866:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80186d:	00 00 00 
	b.error = 1;
  801870:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801877:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80187a:	8b 45 10             	mov    0x10(%ebp),%eax
  80187d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801881:	8b 45 0c             	mov    0xc(%ebp),%eax
  801884:	89 44 24 08          	mov    %eax,0x8(%esp)
  801888:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80188e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801892:	c7 04 24 17 18 80 00 	movl   $0x801817,(%esp)
  801899:	e8 7c eb ff ff       	call   80041a <vprintfmt>
	if (b.idx > 0)
  80189e:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8018a5:	7e 0b                	jle    8018b2 <vfprintf+0x68>
		writebuf(&b);
  8018a7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018ad:	e8 1e ff ff ff       	call   8017d0 <writebuf>

	return (b.result ? b.result : b.error);
  8018b2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	75 06                	jne    8018c2 <vfprintf+0x78>
  8018bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018ca:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8018cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018db:	89 04 24             	mov    %eax,(%esp)
  8018de:	e8 67 ff ff ff       	call   80184a <vfprintf>
	va_end(ap);

	return cnt;
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <printf>:

int
printf(const char *fmt, ...)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8018eb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8018ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801900:	e8 45 ff ff ff       	call   80184a <vfprintf>
	va_end(ap);

	return cnt;
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    
	...

00801908 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  80190e:	c7 44 24 04 37 2b 80 	movl   $0x802b37,0x4(%esp)
  801915:	00 
  801916:	8b 45 0c             	mov    0xc(%ebp),%eax
  801919:	89 04 24             	mov    %eax,(%esp)
  80191c:	e8 42 ef ff ff       	call   800863 <strcpy>
	return 0;
}
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	83 ec 14             	sub    $0x14,%esp
  80192f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801932:	89 1c 24             	mov    %ebx,(%esp)
  801935:	e8 f2 0a 00 00       	call   80242c <pageref>
  80193a:	83 f8 01             	cmp    $0x1,%eax
  80193d:	75 0d                	jne    80194c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80193f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	e8 1f 03 00 00       	call   801c69 <nsipc_close>
  80194a:	eb 05                	jmp    801951 <devsock_close+0x29>
	else
		return 0;
  80194c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801951:	83 c4 14             	add    $0x14,%esp
  801954:	5b                   	pop    %ebx
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80195d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801964:	00 
  801965:	8b 45 10             	mov    0x10(%ebp),%eax
  801968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801973:	8b 45 08             	mov    0x8(%ebp),%eax
  801976:	8b 40 0c             	mov    0xc(%eax),%eax
  801979:	89 04 24             	mov    %eax,(%esp)
  80197c:	e8 e3 03 00 00       	call   801d64 <nsipc_send>
}
  801981:	c9                   	leave  
  801982:	c3                   	ret    

00801983 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801989:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801990:	00 
  801991:	8b 45 10             	mov    0x10(%ebp),%eax
  801994:	89 44 24 08          	mov    %eax,0x8(%esp)
  801998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199f:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a5:	89 04 24             	mov    %eax,(%esp)
  8019a8:	e8 37 03 00 00       	call   801ce4 <nsipc_recv>
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 20             	sub    $0x20,%esp
  8019b7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 a7 f5 ff ff       	call   800f6b <fd_alloc>
  8019c4:	89 c3                	mov    %eax,%ebx
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 21                	js     8019eb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019ca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8019d1:	00 
  8019d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e0:	e8 70 f2 ff ff       	call   800c55 <sys_page_alloc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	79 0a                	jns    8019f5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8019eb:	89 34 24             	mov    %esi,(%esp)
  8019ee:	e8 76 02 00 00       	call   801c69 <nsipc_close>
		return r;
  8019f3:	eb 22                	jmp    801a17 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019f5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fe:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a03:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a0a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 2b f5 ff ff       	call   800f40 <fd2num>
  801a15:	89 c3                	mov    %eax,%ebx
}
  801a17:	89 d8                	mov    %ebx,%eax
  801a19:	83 c4 20             	add    $0x20,%esp
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a26:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a2d:	89 04 24             	mov    %eax,(%esp)
  801a30:	e8 89 f5 ff ff       	call   800fbe <fd_lookup>
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 17                	js     801a50 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a42:	39 10                	cmp    %edx,(%eax)
  801a44:	75 05                	jne    801a4b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a46:	8b 40 0c             	mov    0xc(%eax),%eax
  801a49:	eb 05                	jmp    801a50 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a4b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	e8 c0 ff ff ff       	call   801a20 <fd2sockid>
  801a60:	85 c0                	test   %eax,%eax
  801a62:	78 1f                	js     801a83 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a64:	8b 55 10             	mov    0x10(%ebp),%edx
  801a67:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a72:	89 04 24             	mov    %eax,(%esp)
  801a75:	e8 38 01 00 00       	call   801bb2 <nsipc_accept>
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 05                	js     801a83 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801a7e:	e8 2c ff ff ff       	call   8019af <alloc_sockfd>
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	e8 8d ff ff ff       	call   801a20 <fd2sockid>
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 16                	js     801aad <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801a97:	8b 55 10             	mov    0x10(%ebp),%edx
  801a9a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aa5:	89 04 24             	mov    %eax,(%esp)
  801aa8:	e8 5b 01 00 00       	call   801c08 <nsipc_bind>
}
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    

00801aaf <shutdown>:

int
shutdown(int s, int how)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab8:	e8 63 ff ff ff       	call   801a20 <fd2sockid>
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 0f                	js     801ad0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ac8:	89 04 24             	mov    %eax,(%esp)
  801acb:	e8 77 01 00 00       	call   801c47 <nsipc_shutdown>
}
  801ad0:	c9                   	leave  
  801ad1:	c3                   	ret    

00801ad2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  801adb:	e8 40 ff ff ff       	call   801a20 <fd2sockid>
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 16                	js     801afa <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801ae4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ae7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801aeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aee:	89 54 24 04          	mov    %edx,0x4(%esp)
  801af2:	89 04 24             	mov    %eax,(%esp)
  801af5:	e8 89 01 00 00       	call   801c83 <nsipc_connect>
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <listen>:

int
listen(int s, int backlog)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	e8 16 ff ff ff       	call   801a20 <fd2sockid>
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 0f                	js     801b1d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b11:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b15:	89 04 24             	mov    %eax,(%esp)
  801b18:	e8 a5 01 00 00       	call   801cc2 <nsipc_listen>
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b25:	8b 45 10             	mov    0x10(%ebp),%eax
  801b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	89 04 24             	mov    %eax,(%esp)
  801b39:	e8 99 02 00 00       	call   801dd7 <nsipc_socket>
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 05                	js     801b47 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b42:	e8 68 fe ff ff       	call   8019af <alloc_sockfd>
}
  801b47:	c9                   	leave  
  801b48:	c3                   	ret    
  801b49:	00 00                	add    %al,(%eax)
	...

00801b4c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 14             	sub    $0x14,%esp
  801b53:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b55:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b5c:	75 11                	jne    801b6f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b5e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b65:	e8 89 08 00 00       	call   8023f3 <ipc_find_env>
  801b6a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b6f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b76:	00 
  801b77:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  801b7e:	00 
  801b7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b83:	a1 04 40 80 00       	mov    0x804004,%eax
  801b88:	89 04 24             	mov    %eax,(%esp)
  801b8b:	e8 f5 07 00 00       	call   802385 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b97:	00 
  801b98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b9f:	00 
  801ba0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba7:	e8 70 07 00 00       	call   80231c <ipc_recv>
}
  801bac:	83 c4 14             	add    $0x14,%esp
  801baf:	5b                   	pop    %ebx
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    

00801bb2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 10             	sub    $0x10,%esp
  801bba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc0:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bc5:	8b 06                	mov    (%esi),%eax
  801bc7:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bcc:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd1:	e8 76 ff ff ff       	call   801b4c <nsipc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 23                	js     801bff <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bdc:	a1 10 80 80 00       	mov    0x808010,%eax
  801be1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be5:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801bec:	00 
  801bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf0:	89 04 24             	mov    %eax,(%esp)
  801bf3:	e8 e4 ed ff ff       	call   8009dc <memmove>
		*addrlen = ret->ret_addrlen;
  801bf8:	a1 10 80 80 00       	mov    0x808010,%eax
  801bfd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801bff:	89 d8                	mov    %ebx,%eax
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 14             	sub    $0x14,%esp
  801c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c25:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801c2c:	e8 ab ed ff ff       	call   8009dc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c31:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801c37:	b8 02 00 00 00       	mov    $0x2,%eax
  801c3c:	e8 0b ff ff ff       	call   801b4c <nsipc>
}
  801c41:	83 c4 14             	add    $0x14,%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801c55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c58:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801c5d:	b8 03 00 00 00       	mov    $0x3,%eax
  801c62:	e8 e5 fe ff ff       	call   801b4c <nsipc>
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <nsipc_close>:

int
nsipc_close(int s)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801c77:	b8 04 00 00 00       	mov    $0x4,%eax
  801c7c:	e8 cb fe ff ff       	call   801b4c <nsipc>
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	83 ec 14             	sub    $0x14,%esp
  801c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c90:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c95:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca0:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801ca7:	e8 30 ed ff ff       	call   8009dc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cac:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  801cb7:	e8 90 fe ff ff       	call   801b4c <nsipc>
}
  801cbc:	83 c4 14             	add    $0x14,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd3:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801cd8:	b8 06 00 00 00       	mov    $0x6,%eax
  801cdd:	e8 6a fe ff ff       	call   801b4c <nsipc>
}
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 10             	sub    $0x10,%esp
  801cec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf2:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801cf7:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801cfd:	8b 45 14             	mov    0x14(%ebp),%eax
  801d00:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d05:	b8 07 00 00 00       	mov    $0x7,%eax
  801d0a:	e8 3d fe ff ff       	call   801b4c <nsipc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	85 c0                	test   %eax,%eax
  801d13:	78 46                	js     801d5b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d15:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d1a:	7f 04                	jg     801d20 <nsipc_recv+0x3c>
  801d1c:	39 c6                	cmp    %eax,%esi
  801d1e:	7d 24                	jge    801d44 <nsipc_recv+0x60>
  801d20:	c7 44 24 0c 43 2b 80 	movl   $0x802b43,0xc(%esp)
  801d27:	00 
  801d28:	c7 44 24 08 0b 2b 80 	movl   $0x802b0b,0x8(%esp)
  801d2f:	00 
  801d30:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801d37:	00 
  801d38:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  801d3f:	e8 7c e4 ff ff       	call   8001c0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d44:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d48:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801d4f:	00 
  801d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 81 ec ff ff       	call   8009dc <memmove>
	}

	return r;
}
  801d5b:	89 d8                	mov    %ebx,%eax
  801d5d:	83 c4 10             	add    $0x10,%esp
  801d60:	5b                   	pop    %ebx
  801d61:	5e                   	pop    %esi
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    

00801d64 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	53                   	push   %ebx
  801d68:	83 ec 14             	sub    $0x14,%esp
  801d6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801d76:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d7c:	7e 24                	jle    801da2 <nsipc_send+0x3e>
  801d7e:	c7 44 24 0c 64 2b 80 	movl   $0x802b64,0xc(%esp)
  801d85:	00 
  801d86:	c7 44 24 08 0b 2b 80 	movl   $0x802b0b,0x8(%esp)
  801d8d:	00 
  801d8e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801d95:	00 
  801d96:	c7 04 24 58 2b 80 00 	movl   $0x802b58,(%esp)
  801d9d:	e8 1e e4 ff ff       	call   8001c0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801da2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dad:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  801db4:	e8 23 ec ff ff       	call   8009dc <memmove>
	nsipcbuf.send.req_size = size;
  801db9:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801dbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801dc2:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801dc7:	b8 08 00 00 00       	mov    $0x8,%eax
  801dcc:	e8 7b fd ff ff       	call   801b4c <nsipc>
}
  801dd1:	83 c4 14             	add    $0x14,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de8:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801ded:	8b 45 10             	mov    0x10(%ebp),%eax
  801df0:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801df5:	b8 09 00 00 00       	mov    $0x9,%eax
  801dfa:	e8 4d fd ff ff       	call   801b4c <nsipc>
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    
  801e01:	00 00                	add    %al,(%eax)
	...

00801e04 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
  801e09:	83 ec 10             	sub    $0x10,%esp
  801e0c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e12:	89 04 24             	mov    %eax,(%esp)
  801e15:	e8 36 f1 ff ff       	call   800f50 <fd2data>
  801e1a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801e1c:	c7 44 24 04 70 2b 80 	movl   $0x802b70,0x4(%esp)
  801e23:	00 
  801e24:	89 34 24             	mov    %esi,(%esp)
  801e27:	e8 37 ea ff ff       	call   800863 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801e2f:	2b 03                	sub    (%ebx),%eax
  801e31:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801e37:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801e3e:	00 00 00 
	stat->st_dev = &devpipe;
  801e41:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801e48:	30 80 00 
	return 0;
}
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	5b                   	pop    %ebx
  801e54:	5e                   	pop    %esi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	53                   	push   %ebx
  801e5b:	83 ec 14             	sub    $0x14,%esp
  801e5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6c:	e8 8b ee ff ff       	call   800cfc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e71:	89 1c 24             	mov    %ebx,(%esp)
  801e74:	e8 d7 f0 ff ff       	call   800f50 <fd2data>
  801e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e84:	e8 73 ee ff ff       	call   800cfc <sys_page_unmap>
}
  801e89:	83 c4 14             	add    $0x14,%esp
  801e8c:	5b                   	pop    %ebx
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	57                   	push   %edi
  801e93:	56                   	push   %esi
  801e94:	53                   	push   %ebx
  801e95:	83 ec 2c             	sub    $0x2c,%esp
  801e98:	89 c7                	mov    %eax,%edi
  801e9a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e9d:	a1 20 60 80 00       	mov    0x806020,%eax
  801ea2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ea5:	89 3c 24             	mov    %edi,(%esp)
  801ea8:	e8 7f 05 00 00       	call   80242c <pageref>
  801ead:	89 c6                	mov    %eax,%esi
  801eaf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eb2:	89 04 24             	mov    %eax,(%esp)
  801eb5:	e8 72 05 00 00       	call   80242c <pageref>
  801eba:	39 c6                	cmp    %eax,%esi
  801ebc:	0f 94 c0             	sete   %al
  801ebf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801ec2:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801ec8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ecb:	39 cb                	cmp    %ecx,%ebx
  801ecd:	75 08                	jne    801ed7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ecf:	83 c4 2c             	add    $0x2c,%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5f                   	pop    %edi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801ed7:	83 f8 01             	cmp    $0x1,%eax
  801eda:	75 c1                	jne    801e9d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801edc:	8b 42 58             	mov    0x58(%edx),%eax
  801edf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801ee6:	00 
  801ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eef:	c7 04 24 77 2b 80 00 	movl   $0x802b77,(%esp)
  801ef6:	e8 bd e3 ff ff       	call   8002b8 <cprintf>
  801efb:	eb a0                	jmp    801e9d <_pipeisclosed+0xe>

00801efd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	57                   	push   %edi
  801f01:	56                   	push   %esi
  801f02:	53                   	push   %ebx
  801f03:	83 ec 1c             	sub    $0x1c,%esp
  801f06:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f09:	89 34 24             	mov    %esi,(%esp)
  801f0c:	e8 3f f0 ff ff       	call   800f50 <fd2data>
  801f11:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f13:	bf 00 00 00 00       	mov    $0x0,%edi
  801f18:	eb 3c                	jmp    801f56 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f1a:	89 da                	mov    %ebx,%edx
  801f1c:	89 f0                	mov    %esi,%eax
  801f1e:	e8 6c ff ff ff       	call   801e8f <_pipeisclosed>
  801f23:	85 c0                	test   %eax,%eax
  801f25:	75 38                	jne    801f5f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f27:	e8 0a ed ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f2c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f2f:	8b 13                	mov    (%ebx),%edx
  801f31:	83 c2 20             	add    $0x20,%edx
  801f34:	39 d0                	cmp    %edx,%eax
  801f36:	73 e2                	jae    801f1a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f38:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801f46:	79 05                	jns    801f4d <devpipe_write+0x50>
  801f48:	4a                   	dec    %edx
  801f49:	83 ca e0             	or     $0xffffffe0,%edx
  801f4c:	42                   	inc    %edx
  801f4d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f51:	40                   	inc    %eax
  801f52:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f55:	47                   	inc    %edi
  801f56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f59:	75 d1                	jne    801f2c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f5b:	89 f8                	mov    %edi,%eax
  801f5d:	eb 05                	jmp    801f64 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f64:	83 c4 1c             	add    $0x1c,%esp
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	57                   	push   %edi
  801f70:	56                   	push   %esi
  801f71:	53                   	push   %ebx
  801f72:	83 ec 1c             	sub    $0x1c,%esp
  801f75:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f78:	89 3c 24             	mov    %edi,(%esp)
  801f7b:	e8 d0 ef ff ff       	call   800f50 <fd2data>
  801f80:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f82:	be 00 00 00 00       	mov    $0x0,%esi
  801f87:	eb 3a                	jmp    801fc3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f89:	85 f6                	test   %esi,%esi
  801f8b:	74 04                	je     801f91 <devpipe_read+0x25>
				return i;
  801f8d:	89 f0                	mov    %esi,%eax
  801f8f:	eb 40                	jmp    801fd1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f91:	89 da                	mov    %ebx,%edx
  801f93:	89 f8                	mov    %edi,%eax
  801f95:	e8 f5 fe ff ff       	call   801e8f <_pipeisclosed>
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	75 2e                	jne    801fcc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f9e:	e8 93 ec ff ff       	call   800c36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fa3:	8b 03                	mov    (%ebx),%eax
  801fa5:	3b 43 04             	cmp    0x4(%ebx),%eax
  801fa8:	74 df                	je     801f89 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801faa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801faf:	79 05                	jns    801fb6 <devpipe_read+0x4a>
  801fb1:	48                   	dec    %eax
  801fb2:	83 c8 e0             	or     $0xffffffe0,%eax
  801fb5:	40                   	inc    %eax
  801fb6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801fba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fbd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801fc0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fc2:	46                   	inc    %esi
  801fc3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fc6:	75 db                	jne    801fa3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fc8:	89 f0                	mov    %esi,%eax
  801fca:	eb 05                	jmp    801fd1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fd1:	83 c4 1c             	add    $0x1c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	57                   	push   %edi
  801fdd:	56                   	push   %esi
  801fde:	53                   	push   %ebx
  801fdf:	83 ec 3c             	sub    $0x3c,%esp
  801fe2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fe5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801fe8:	89 04 24             	mov    %eax,(%esp)
  801feb:	e8 7b ef ff ff       	call   800f6b <fd_alloc>
  801ff0:	89 c3                	mov    %eax,%ebx
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	0f 88 45 01 00 00    	js     80213f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ffa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802001:	00 
  802002:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802005:	89 44 24 04          	mov    %eax,0x4(%esp)
  802009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802010:	e8 40 ec ff ff       	call   800c55 <sys_page_alloc>
  802015:	89 c3                	mov    %eax,%ebx
  802017:	85 c0                	test   %eax,%eax
  802019:	0f 88 20 01 00 00    	js     80213f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80201f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802022:	89 04 24             	mov    %eax,(%esp)
  802025:	e8 41 ef ff ff       	call   800f6b <fd_alloc>
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	85 c0                	test   %eax,%eax
  80202e:	0f 88 f8 00 00 00    	js     80212c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802034:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80203b:	00 
  80203c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80203f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802043:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204a:	e8 06 ec ff ff       	call   800c55 <sys_page_alloc>
  80204f:	89 c3                	mov    %eax,%ebx
  802051:	85 c0                	test   %eax,%eax
  802053:	0f 88 d3 00 00 00    	js     80212c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80205c:	89 04 24             	mov    %eax,(%esp)
  80205f:	e8 ec ee ff ff       	call   800f50 <fd2data>
  802064:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802066:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80206d:	00 
  80206e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802079:	e8 d7 eb ff ff       	call   800c55 <sys_page_alloc>
  80207e:	89 c3                	mov    %eax,%ebx
  802080:	85 c0                	test   %eax,%eax
  802082:	0f 88 91 00 00 00    	js     802119 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802088:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 bd ee ff ff       	call   800f50 <fd2data>
  802093:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80209a:	00 
  80209b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020a6:	00 
  8020a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b2:	e8 f2 eb ff ff       	call   800ca9 <sys_page_map>
  8020b7:	89 c3                	mov    %eax,%ebx
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	78 4c                	js     802109 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020bd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020d2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ea:	89 04 24             	mov    %eax,(%esp)
  8020ed:	e8 4e ee ff ff       	call   800f40 <fd2num>
  8020f2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8020f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020f7:	89 04 24             	mov    %eax,(%esp)
  8020fa:	e8 41 ee ff ff       	call   800f40 <fd2num>
  8020ff:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802102:	bb 00 00 00 00       	mov    $0x0,%ebx
  802107:	eb 36                	jmp    80213f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802109:	89 74 24 04          	mov    %esi,0x4(%esp)
  80210d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802114:	e8 e3 eb ff ff       	call   800cfc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802119:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80211c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802120:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802127:	e8 d0 eb ff ff       	call   800cfc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80212c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80212f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213a:	e8 bd eb ff ff       	call   800cfc <sys_page_unmap>
    err:
	return r;
}
  80213f:	89 d8                	mov    %ebx,%eax
  802141:	83 c4 3c             	add    $0x3c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	89 44 24 04          	mov    %eax,0x4(%esp)
  802156:	8b 45 08             	mov    0x8(%ebp),%eax
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 5d ee ff ff       	call   800fbe <fd_lookup>
  802161:	85 c0                	test   %eax,%eax
  802163:	78 15                	js     80217a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802168:	89 04 24             	mov    %eax,(%esp)
  80216b:	e8 e0 ed ff ff       	call   800f50 <fd2data>
	return _pipeisclosed(fd, p);
  802170:	89 c2                	mov    %eax,%edx
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	e8 15 fd ff ff       	call   801e8f <_pipeisclosed>
}
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80218c:	c7 44 24 04 8f 2b 80 	movl   $0x802b8f,0x4(%esp)
  802193:	00 
  802194:	8b 45 0c             	mov    0xc(%ebp),%eax
  802197:	89 04 24             	mov    %eax,(%esp)
  80219a:	e8 c4 e6 ff ff       	call   800863 <strcpy>
	return 0;
}
  80219f:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a4:	c9                   	leave  
  8021a5:	c3                   	ret    

008021a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021a6:	55                   	push   %ebp
  8021a7:	89 e5                	mov    %esp,%ebp
  8021a9:	57                   	push   %edi
  8021aa:	56                   	push   %esi
  8021ab:	53                   	push   %ebx
  8021ac:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021bd:	eb 30                	jmp    8021ef <devcons_write+0x49>
		m = n - tot;
  8021bf:	8b 75 10             	mov    0x10(%ebp),%esi
  8021c2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8021c4:	83 fe 7f             	cmp    $0x7f,%esi
  8021c7:	76 05                	jbe    8021ce <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8021c9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021d2:	03 45 0c             	add    0xc(%ebp),%eax
  8021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d9:	89 3c 24             	mov    %edi,(%esp)
  8021dc:	e8 fb e7 ff ff       	call   8009dc <memmove>
		sys_cputs(buf, m);
  8021e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e5:	89 3c 24             	mov    %edi,(%esp)
  8021e8:	e8 9b e9 ff ff       	call   800b88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ed:	01 f3                	add    %esi,%ebx
  8021ef:	89 d8                	mov    %ebx,%eax
  8021f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021f4:	72 c9                	jb     8021bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8021fc:	5b                   	pop    %ebx
  8021fd:	5e                   	pop    %esi
  8021fe:	5f                   	pop    %edi
  8021ff:	5d                   	pop    %ebp
  802200:	c3                   	ret    

00802201 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802207:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80220b:	75 07                	jne    802214 <devcons_read+0x13>
  80220d:	eb 25                	jmp    802234 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80220f:	e8 22 ea ff ff       	call   800c36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802214:	e8 8d e9 ff ff       	call   800ba6 <sys_cgetc>
  802219:	85 c0                	test   %eax,%eax
  80221b:	74 f2                	je     80220f <devcons_read+0xe>
  80221d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80221f:	85 c0                	test   %eax,%eax
  802221:	78 1d                	js     802240 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802223:	83 f8 04             	cmp    $0x4,%eax
  802226:	74 13                	je     80223b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222b:	88 10                	mov    %dl,(%eax)
	return 1;
  80222d:	b8 01 00 00 00       	mov    $0x1,%eax
  802232:	eb 0c                	jmp    802240 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802234:	b8 00 00 00 00       	mov    $0x0,%eax
  802239:	eb 05                	jmp    802240 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80223b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802240:	c9                   	leave  
  802241:	c3                   	ret    

00802242 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802248:	8b 45 08             	mov    0x8(%ebp),%eax
  80224b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80224e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802255:	00 
  802256:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802259:	89 04 24             	mov    %eax,(%esp)
  80225c:	e8 27 e9 ff ff       	call   800b88 <sys_cputs>
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <getchar>:

int
getchar(void)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802269:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802270:	00 
  802271:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802274:	89 44 24 04          	mov    %eax,0x4(%esp)
  802278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227f:	e8 d6 ef ff ff       	call   80125a <read>
	if (r < 0)
  802284:	85 c0                	test   %eax,%eax
  802286:	78 0f                	js     802297 <getchar+0x34>
		return r;
	if (r < 1)
  802288:	85 c0                	test   %eax,%eax
  80228a:	7e 06                	jle    802292 <getchar+0x2f>
		return -E_EOF;
	return c;
  80228c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802290:	eb 05                	jmp    802297 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802292:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802297:	c9                   	leave  
  802298:	c3                   	ret    

00802299 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802299:	55                   	push   %ebp
  80229a:	89 e5                	mov    %esp,%ebp
  80229c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80229f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a9:	89 04 24             	mov    %eax,(%esp)
  8022ac:	e8 0d ed ff ff       	call   800fbe <fd_lookup>
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	78 11                	js     8022c6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022be:	39 10                	cmp    %edx,(%eax)
  8022c0:	0f 94 c0             	sete   %al
  8022c3:	0f b6 c0             	movzbl %al,%eax
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <opencons>:

int
opencons(void)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d1:	89 04 24             	mov    %eax,(%esp)
  8022d4:	e8 92 ec ff ff       	call   800f6b <fd_alloc>
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 3c                	js     802319 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022e4:	00 
  8022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022f3:	e8 5d e9 ff ff       	call   800c55 <sys_page_alloc>
  8022f8:	85 c0                	test   %eax,%eax
  8022fa:	78 1d                	js     802319 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022fc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802302:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802305:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802307:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802311:	89 04 24             	mov    %eax,(%esp)
  802314:	e8 27 ec ff ff       	call   800f40 <fd2num>
}
  802319:	c9                   	leave  
  80231a:	c3                   	ret    
	...

0080231c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80231c:	55                   	push   %ebp
  80231d:	89 e5                	mov    %esp,%ebp
  80231f:	56                   	push   %esi
  802320:	53                   	push   %ebx
  802321:	83 ec 10             	sub    $0x10,%esp
  802324:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  80232d:	85 c0                	test   %eax,%eax
  80232f:	75 05                	jne    802336 <ipc_recv+0x1a>
  802331:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802336:	89 04 24             	mov    %eax,(%esp)
  802339:	e8 2d eb ff ff       	call   800e6b <sys_ipc_recv>
	if (from_env_store != NULL)
  80233e:	85 db                	test   %ebx,%ebx
  802340:	74 0b                	je     80234d <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802342:	8b 15 20 60 80 00    	mov    0x806020,%edx
  802348:	8b 52 74             	mov    0x74(%edx),%edx
  80234b:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  80234d:	85 f6                	test   %esi,%esi
  80234f:	74 0b                	je     80235c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802351:	8b 15 20 60 80 00    	mov    0x806020,%edx
  802357:	8b 52 78             	mov    0x78(%edx),%edx
  80235a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  80235c:	85 c0                	test   %eax,%eax
  80235e:	79 16                	jns    802376 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802360:	85 db                	test   %ebx,%ebx
  802362:	74 06                	je     80236a <ipc_recv+0x4e>
			*from_env_store = 0;
  802364:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80236a:	85 f6                	test   %esi,%esi
  80236c:	74 10                	je     80237e <ipc_recv+0x62>
			*perm_store = 0;
  80236e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802374:	eb 08                	jmp    80237e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802376:	a1 20 60 80 00       	mov    0x806020,%eax
  80237b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	5b                   	pop    %ebx
  802382:	5e                   	pop    %esi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    

00802385 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	57                   	push   %edi
  802389:	56                   	push   %esi
  80238a:	53                   	push   %ebx
  80238b:	83 ec 1c             	sub    $0x1c,%esp
  80238e:	8b 75 08             	mov    0x8(%ebp),%esi
  802391:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802394:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802397:	eb 2a                	jmp    8023c3 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802399:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80239c:	74 20                	je     8023be <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80239e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023a2:	c7 44 24 08 9c 2b 80 	movl   $0x802b9c,0x8(%esp)
  8023a9:	00 
  8023aa:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8023b1:	00 
  8023b2:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  8023b9:	e8 02 de ff ff       	call   8001c0 <_panic>
		sys_yield();
  8023be:	e8 73 e8 ff ff       	call   800c36 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8023c3:	85 db                	test   %ebx,%ebx
  8023c5:	75 07                	jne    8023ce <ipc_send+0x49>
  8023c7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023cc:	eb 02                	jmp    8023d0 <ipc_send+0x4b>
  8023ce:	89 d8                	mov    %ebx,%eax
  8023d0:	8b 55 14             	mov    0x14(%ebp),%edx
  8023d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023df:	89 34 24             	mov    %esi,(%esp)
  8023e2:	e8 61 ea ff ff       	call   800e48 <sys_ipc_try_send>
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	78 ae                	js     802399 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8023eb:	83 c4 1c             	add    $0x1c,%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    

008023f3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023f9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023fe:	89 c2                	mov    %eax,%edx
  802400:	c1 e2 07             	shl    $0x7,%edx
  802403:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802409:	8b 52 50             	mov    0x50(%edx),%edx
  80240c:	39 ca                	cmp    %ecx,%edx
  80240e:	75 0d                	jne    80241d <ipc_find_env+0x2a>
			return envs[i].env_id;
  802410:	c1 e0 07             	shl    $0x7,%eax
  802413:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802418:	8b 40 40             	mov    0x40(%eax),%eax
  80241b:	eb 0c                	jmp    802429 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80241d:	40                   	inc    %eax
  80241e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802423:	75 d9                	jne    8023fe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802425:	66 b8 00 00          	mov    $0x0,%ax
}
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    
	...

0080242c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80242c:	55                   	push   %ebp
  80242d:	89 e5                	mov    %esp,%ebp
  80242f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802432:	89 c2                	mov    %eax,%edx
  802434:	c1 ea 16             	shr    $0x16,%edx
  802437:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80243e:	f6 c2 01             	test   $0x1,%dl
  802441:	74 1e                	je     802461 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802443:	c1 e8 0c             	shr    $0xc,%eax
  802446:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80244d:	a8 01                	test   $0x1,%al
  80244f:	74 17                	je     802468 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802451:	c1 e8 0c             	shr    $0xc,%eax
  802454:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80245b:	ef 
  80245c:	0f b7 c0             	movzwl %ax,%eax
  80245f:	eb 0c                	jmp    80246d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802461:	b8 00 00 00 00       	mov    $0x0,%eax
  802466:	eb 05                	jmp    80246d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802468:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80246d:	5d                   	pop    %ebp
  80246e:	c3                   	ret    
	...

00802470 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	83 ec 10             	sub    $0x10,%esp
  802476:	8b 74 24 20          	mov    0x20(%esp),%esi
  80247a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80247e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802482:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802486:	89 cd                	mov    %ecx,%ebp
  802488:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80248c:	85 c0                	test   %eax,%eax
  80248e:	75 2c                	jne    8024bc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802490:	39 f9                	cmp    %edi,%ecx
  802492:	77 68                	ja     8024fc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802494:	85 c9                	test   %ecx,%ecx
  802496:	75 0b                	jne    8024a3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802498:	b8 01 00 00 00       	mov    $0x1,%eax
  80249d:	31 d2                	xor    %edx,%edx
  80249f:	f7 f1                	div    %ecx
  8024a1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024a3:	31 d2                	xor    %edx,%edx
  8024a5:	89 f8                	mov    %edi,%eax
  8024a7:	f7 f1                	div    %ecx
  8024a9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024ab:	89 f0                	mov    %esi,%eax
  8024ad:	f7 f1                	div    %ecx
  8024af:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024b1:	89 f0                	mov    %esi,%eax
  8024b3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024b5:	83 c4 10             	add    $0x10,%esp
  8024b8:	5e                   	pop    %esi
  8024b9:	5f                   	pop    %edi
  8024ba:	5d                   	pop    %ebp
  8024bb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024bc:	39 f8                	cmp    %edi,%eax
  8024be:	77 2c                	ja     8024ec <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024c0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8024c3:	83 f6 1f             	xor    $0x1f,%esi
  8024c6:	75 4c                	jne    802514 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024c8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024ca:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024cf:	72 0a                	jb     8024db <__udivdi3+0x6b>
  8024d1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8024d5:	0f 87 ad 00 00 00    	ja     802588 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024db:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024e0:	89 f0                	mov    %esi,%eax
  8024e2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024e4:	83 c4 10             	add    $0x10,%esp
  8024e7:	5e                   	pop    %esi
  8024e8:	5f                   	pop    %edi
  8024e9:	5d                   	pop    %ebp
  8024ea:	c3                   	ret    
  8024eb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024ec:	31 ff                	xor    %edi,%edi
  8024ee:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024f0:	89 f0                	mov    %esi,%eax
  8024f2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024f4:	83 c4 10             	add    $0x10,%esp
  8024f7:	5e                   	pop    %esi
  8024f8:	5f                   	pop    %edi
  8024f9:	5d                   	pop    %ebp
  8024fa:	c3                   	ret    
  8024fb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024fc:	89 fa                	mov    %edi,%edx
  8024fe:	89 f0                	mov    %esi,%eax
  802500:	f7 f1                	div    %ecx
  802502:	89 c6                	mov    %eax,%esi
  802504:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802506:	89 f0                	mov    %esi,%eax
  802508:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80250a:	83 c4 10             	add    $0x10,%esp
  80250d:	5e                   	pop    %esi
  80250e:	5f                   	pop    %edi
  80250f:	5d                   	pop    %ebp
  802510:	c3                   	ret    
  802511:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802514:	89 f1                	mov    %esi,%ecx
  802516:	d3 e0                	shl    %cl,%eax
  802518:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80251c:	b8 20 00 00 00       	mov    $0x20,%eax
  802521:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802523:	89 ea                	mov    %ebp,%edx
  802525:	88 c1                	mov    %al,%cl
  802527:	d3 ea                	shr    %cl,%edx
  802529:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80252d:	09 ca                	or     %ecx,%edx
  80252f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802533:	89 f1                	mov    %esi,%ecx
  802535:	d3 e5                	shl    %cl,%ebp
  802537:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80253b:	89 fd                	mov    %edi,%ebp
  80253d:	88 c1                	mov    %al,%cl
  80253f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802541:	89 fa                	mov    %edi,%edx
  802543:	89 f1                	mov    %esi,%ecx
  802545:	d3 e2                	shl    %cl,%edx
  802547:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80254b:	88 c1                	mov    %al,%cl
  80254d:	d3 ef                	shr    %cl,%edi
  80254f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802551:	89 f8                	mov    %edi,%eax
  802553:	89 ea                	mov    %ebp,%edx
  802555:	f7 74 24 08          	divl   0x8(%esp)
  802559:	89 d1                	mov    %edx,%ecx
  80255b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80255d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802561:	39 d1                	cmp    %edx,%ecx
  802563:	72 17                	jb     80257c <__udivdi3+0x10c>
  802565:	74 09                	je     802570 <__udivdi3+0x100>
  802567:	89 fe                	mov    %edi,%esi
  802569:	31 ff                	xor    %edi,%edi
  80256b:	e9 41 ff ff ff       	jmp    8024b1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802570:	8b 54 24 04          	mov    0x4(%esp),%edx
  802574:	89 f1                	mov    %esi,%ecx
  802576:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802578:	39 c2                	cmp    %eax,%edx
  80257a:	73 eb                	jae    802567 <__udivdi3+0xf7>
		{
		  q0--;
  80257c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80257f:	31 ff                	xor    %edi,%edi
  802581:	e9 2b ff ff ff       	jmp    8024b1 <__udivdi3+0x41>
  802586:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802588:	31 f6                	xor    %esi,%esi
  80258a:	e9 22 ff ff ff       	jmp    8024b1 <__udivdi3+0x41>
	...

00802590 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	83 ec 20             	sub    $0x20,%esp
  802596:	8b 44 24 30          	mov    0x30(%esp),%eax
  80259a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80259e:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025a2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8025a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025aa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025ae:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8025b0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025b2:	85 ed                	test   %ebp,%ebp
  8025b4:	75 16                	jne    8025cc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8025b6:	39 f1                	cmp    %esi,%ecx
  8025b8:	0f 86 a6 00 00 00    	jbe    802664 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025be:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8025c0:	89 d0                	mov    %edx,%eax
  8025c2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c4:	83 c4 20             	add    $0x20,%esp
  8025c7:	5e                   	pop    %esi
  8025c8:	5f                   	pop    %edi
  8025c9:	5d                   	pop    %ebp
  8025ca:	c3                   	ret    
  8025cb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025cc:	39 f5                	cmp    %esi,%ebp
  8025ce:	0f 87 ac 00 00 00    	ja     802680 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025d4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8025d7:	83 f0 1f             	xor    $0x1f,%eax
  8025da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025de:	0f 84 a8 00 00 00    	je     80268c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025e4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025e8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025ea:	bf 20 00 00 00       	mov    $0x20,%edi
  8025ef:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025f3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025f7:	89 f9                	mov    %edi,%ecx
  8025f9:	d3 e8                	shr    %cl,%eax
  8025fb:	09 e8                	or     %ebp,%eax
  8025fd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802601:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802605:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802609:	d3 e0                	shl    %cl,%eax
  80260b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80260f:	89 f2                	mov    %esi,%edx
  802611:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802613:	8b 44 24 14          	mov    0x14(%esp),%eax
  802617:	d3 e0                	shl    %cl,%eax
  802619:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80261d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802621:	89 f9                	mov    %edi,%ecx
  802623:	d3 e8                	shr    %cl,%eax
  802625:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802627:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802629:	89 f2                	mov    %esi,%edx
  80262b:	f7 74 24 18          	divl   0x18(%esp)
  80262f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802631:	f7 64 24 0c          	mull   0xc(%esp)
  802635:	89 c5                	mov    %eax,%ebp
  802637:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802639:	39 d6                	cmp    %edx,%esi
  80263b:	72 67                	jb     8026a4 <__umoddi3+0x114>
  80263d:	74 75                	je     8026b4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80263f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802643:	29 e8                	sub    %ebp,%eax
  802645:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802647:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80264b:	d3 e8                	shr    %cl,%eax
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	89 f9                	mov    %edi,%ecx
  802651:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802653:	09 d0                	or     %edx,%eax
  802655:	89 f2                	mov    %esi,%edx
  802657:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80265b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80265d:	83 c4 20             	add    $0x20,%esp
  802660:	5e                   	pop    %esi
  802661:	5f                   	pop    %edi
  802662:	5d                   	pop    %ebp
  802663:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802664:	85 c9                	test   %ecx,%ecx
  802666:	75 0b                	jne    802673 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802668:	b8 01 00 00 00       	mov    $0x1,%eax
  80266d:	31 d2                	xor    %edx,%edx
  80266f:	f7 f1                	div    %ecx
  802671:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802673:	89 f0                	mov    %esi,%eax
  802675:	31 d2                	xor    %edx,%edx
  802677:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802679:	89 f8                	mov    %edi,%eax
  80267b:	e9 3e ff ff ff       	jmp    8025be <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802680:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802682:	83 c4 20             	add    $0x20,%esp
  802685:	5e                   	pop    %esi
  802686:	5f                   	pop    %edi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80268c:	39 f5                	cmp    %esi,%ebp
  80268e:	72 04                	jb     802694 <__umoddi3+0x104>
  802690:	39 f9                	cmp    %edi,%ecx
  802692:	77 06                	ja     80269a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802694:	89 f2                	mov    %esi,%edx
  802696:	29 cf                	sub    %ecx,%edi
  802698:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80269a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80269c:	83 c4 20             	add    $0x20,%esp
  80269f:	5e                   	pop    %esi
  8026a0:	5f                   	pop    %edi
  8026a1:	5d                   	pop    %ebp
  8026a2:	c3                   	ret    
  8026a3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026a4:	89 d1                	mov    %edx,%ecx
  8026a6:	89 c5                	mov    %eax,%ebp
  8026a8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026ac:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8026b0:	eb 8d                	jmp    80263f <__umoddi3+0xaf>
  8026b2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026b4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8026b8:	72 ea                	jb     8026a4 <__umoddi3+0x114>
  8026ba:	89 f1                	mov    %esi,%ecx
  8026bc:	eb 81                	jmp    80263f <__umoddi3+0xaf>
