
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
  800058:	e8 64 12 00 00       	call   8012c1 <write>
  80005d:	39 d8                	cmp    %ebx,%eax
  80005f:	74 24                	je     800085 <cat+0x51>
			panic("write error copying %s: %e", s, r);
  800061:	89 44 24 10          	mov    %eax,0x10(%esp)
  800065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800069:	c7 44 24 08 60 21 80 	movl   $0x802160,0x8(%esp)
  800070:	00 
  800071:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  800078:	00 
  800079:	c7 04 24 7b 21 80 00 	movl   $0x80217b,(%esp)
  800080:	e8 47 01 00 00       	call   8001cc <_panic>
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
  800098:	e8 49 11 00 00       	call   8011e6 <read>
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
  8000af:	c7 44 24 08 86 21 80 	movl   $0x802186,0x8(%esp)
  8000b6:	00 
  8000b7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 7b 21 80 00 	movl   $0x80217b,(%esp)
  8000c6:	e8 01 01 00 00       	call   8001cc <_panic>
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
  8000df:	c7 05 00 30 80 00 9b 	movl   $0x80219b,0x803000
  8000e6:	21 80 00 
	if (argc == 1)
  8000e9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ed:	75 62                	jne    800151 <umain+0x7e>
		cat(0, "<stdin>");
  8000ef:	c7 44 24 04 9f 21 80 	movl   $0x80219f,0x4(%esp)
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
  800113:	e8 a4 15 00 00       	call   8016bc <open>
  800118:	89 c7                	mov    %eax,%edi
			if (f < 0)
  80011a:	85 c0                	test   %eax,%eax
  80011c:	79 19                	jns    800137 <umain+0x64>
				printf("can't open %s: %e\n", argv[i], f);
  80011e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800122:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800125:	89 44 24 04          	mov    %eax,0x4(%esp)
  800129:	c7 04 24 a7 21 80 00 	movl   $0x8021a7,(%esp)
  800130:	e8 3c 17 00 00       	call   801871 <printf>
  800135:	eb 17                	jmp    80014e <umain+0x7b>
			else {
				cat(f, argv[i]);
  800137:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	89 3c 24             	mov    %edi,(%esp)
  800141:	e8 ee fe ff ff       	call   800034 <cat>
				close(f);
  800146:	89 3c 24             	mov    %edi,(%esp)
  800149:	e8 34 0f 00 00       	call   801082 <close>

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
  800172:	e8 ac 0a 00 00       	call   800c23 <sys_getenvid>
  800177:	25 ff 03 00 00       	and    $0x3ff,%eax
  80017c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800183:	c1 e0 07             	shl    $0x7,%eax
  800186:	29 d0                	sub    %edx,%eax
  800188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018d:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800192:	85 f6                	test   %esi,%esi
  800194:	7e 07                	jle    80019d <libmain+0x39>
		binaryname = argv[0];
  800196:	8b 03                	mov    (%ebx),%eax
  800198:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80019d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001a1:	89 34 24             	mov    %esi,(%esp)
  8001a4:	e8 2a ff ff ff       	call   8000d3 <umain>

	// exit gracefully
	exit();
  8001a9:	e8 0a 00 00 00       	call   8001b8 <exit>
}
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8001be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c5:	e8 07 0a 00 00       	call   800bd1 <sys_env_destroy>
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001dd:	e8 41 0a 00 00       	call   800c23 <sys_getenvid>
  8001e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f8:	c7 04 24 c4 21 80 00 	movl   $0x8021c4,(%esp)
  8001ff:	e8 c0 00 00 00       	call   8002c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800204:	89 74 24 04          	mov    %esi,0x4(%esp)
  800208:	8b 45 10             	mov    0x10(%ebp),%eax
  80020b:	89 04 24             	mov    %eax,(%esp)
  80020e:	e8 50 00 00 00       	call   800263 <vcprintf>
	cprintf("\n");
  800213:	c7 04 24 e3 25 80 00 	movl   $0x8025e3,(%esp)
  80021a:	e8 a5 00 00 00       	call   8002c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021f:	cc                   	int3   
  800220:	eb fd                	jmp    80021f <_panic+0x53>
	...

00800224 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 14             	sub    $0x14,%esp
  80022b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022e:	8b 03                	mov    (%ebx),%eax
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800237:	40                   	inc    %eax
  800238:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80023a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023f:	75 19                	jne    80025a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800241:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800248:	00 
  800249:	8d 43 08             	lea    0x8(%ebx),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 40 09 00 00       	call   800b94 <sys_cputs>
		b->idx = 0;
  800254:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80025a:	ff 43 04             	incl   0x4(%ebx)
}
  80025d:	83 c4 14             	add    $0x14,%esp
  800260:	5b                   	pop    %ebx
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80026c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800273:	00 00 00 
	b.cnt = 0;
  800276:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800294:	89 44 24 04          	mov    %eax,0x4(%esp)
  800298:	c7 04 24 24 02 80 00 	movl   $0x800224,(%esp)
  80029f:	e8 82 01 00 00       	call   800426 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 d8 08 00 00       	call   800b94 <sys_cputs>

	return b.cnt;
}
  8002bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	e8 87 ff ff ff       	call   800263 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002dc:	c9                   	leave  
  8002dd:	c3                   	ret    
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 3c             	sub    $0x3c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d7                	mov    %edx,%edi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800300:	85 c0                	test   %eax,%eax
  800302:	75 08                	jne    80030c <printnum+0x2c>
  800304:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800307:	39 45 10             	cmp    %eax,0x10(%ebp)
  80030a:	77 57                	ja     800363 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80030c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800310:	4b                   	dec    %ebx
  800311:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800315:	8b 45 10             	mov    0x10(%ebp),%eax
  800318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800320:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032b:	00 
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 04 24             	mov    %eax,(%esp)
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	89 44 24 04          	mov    %eax,0x4(%esp)
  800339:	e8 ce 1b 00 00       	call   801f0c <__udivdi3>
  80033e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800342:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800346:	89 04 24             	mov    %eax,(%esp)
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	89 fa                	mov    %edi,%edx
  80034f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800352:	e8 89 ff ff ff       	call   8002e0 <printnum>
  800357:	eb 0f                	jmp    800368 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800359:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035d:	89 34 24             	mov    %esi,(%esp)
  800360:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800363:	4b                   	dec    %ebx
  800364:	85 db                	test   %ebx,%ebx
  800366:	7f f1                	jg     800359 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800368:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800370:	8b 45 10             	mov    0x10(%ebp),%eax
  800373:	89 44 24 08          	mov    %eax,0x8(%esp)
  800377:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037e:	00 
  80037f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800382:	89 04 24             	mov    %eax,(%esp)
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038c:	e8 9b 1c 00 00       	call   80202c <__umoddi3>
  800391:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800395:	0f be 80 e7 21 80 00 	movsbl 0x8021e7(%eax),%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003a2:	83 c4 3c             	add    $0x3c,%esp
  8003a5:	5b                   	pop    %ebx
  8003a6:	5e                   	pop    %esi
  8003a7:	5f                   	pop    %edi
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003ad:	83 fa 01             	cmp    $0x1,%edx
  8003b0:	7e 0e                	jle    8003c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	8b 52 04             	mov    0x4(%edx),%edx
  8003be:	eb 22                	jmp    8003e2 <getuint+0x38>
	else if (lflag)
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	74 10                	je     8003d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c4:	8b 10                	mov    (%eax),%edx
  8003c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c9:	89 08                	mov    %ecx,(%eax)
  8003cb:	8b 02                	mov    (%edx),%eax
  8003cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d2:	eb 0e                	jmp    8003e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d4:	8b 10                	mov    (%eax),%edx
  8003d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d9:	89 08                	mov    %ecx,(%eax)
  8003db:	8b 02                	mov    (%edx),%eax
  8003dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ea:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f2:	73 08                	jae    8003fc <sprintputch+0x18>
		*b->buf++ = ch;
  8003f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f7:	88 0a                	mov    %cl,(%edx)
  8003f9:	42                   	inc    %edx
  8003fa:	89 10                	mov    %edx,(%eax)
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800404:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800407:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040b:	8b 45 10             	mov    0x10(%ebp),%eax
  80040e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800412:	8b 45 0c             	mov    0xc(%ebp),%eax
  800415:	89 44 24 04          	mov    %eax,0x4(%esp)
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 02 00 00 00       	call   800426 <vprintfmt>
	va_end(ap);
}
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	57                   	push   %edi
  80042a:	56                   	push   %esi
  80042b:	53                   	push   %ebx
  80042c:	83 ec 4c             	sub    $0x4c,%esp
  80042f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800432:	8b 75 10             	mov    0x10(%ebp),%esi
  800435:	eb 12                	jmp    800449 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800437:	85 c0                	test   %eax,%eax
  800439:	0f 84 6b 03 00 00    	je     8007aa <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80043f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 06             	movzbl (%esi),%eax
  80044c:	46                   	inc    %esi
  80044d:	83 f8 25             	cmp    $0x25,%eax
  800450:	75 e5                	jne    800437 <vprintfmt+0x11>
  800452:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800456:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80045d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800462:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800469:	b9 00 00 00 00       	mov    $0x0,%ecx
  80046e:	eb 26                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800473:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800477:	eb 1d                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80047c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800480:	eb 14                	jmp    800496 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800485:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80048c:	eb 08                	jmp    800496 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80048e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800491:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	0f b6 06             	movzbl (%esi),%eax
  800499:	8d 56 01             	lea    0x1(%esi),%edx
  80049c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049f:	8a 16                	mov    (%esi),%dl
  8004a1:	83 ea 23             	sub    $0x23,%edx
  8004a4:	80 fa 55             	cmp    $0x55,%dl
  8004a7:	0f 87 e1 02 00 00    	ja     80078e <vprintfmt+0x368>
  8004ad:	0f b6 d2             	movzbl %dl,%edx
  8004b0:	ff 24 95 20 23 80 00 	jmp    *0x802320(,%edx,4)
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ba:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004bf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004c2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004c6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004c9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004cc:	83 fa 09             	cmp    $0x9,%edx
  8004cf:	77 2a                	ja     8004fb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004d2:	eb eb                	jmp    8004bf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004e2:	eb 17                	jmp    8004fb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e8:	78 98                	js     800482 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004ed:	eb a7                	jmp    800496 <vprintfmt+0x70>
  8004ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004f9:	eb 9b                	jmp    800496 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ff:	79 95                	jns    800496 <vprintfmt+0x70>
  800501:	eb 8b                	jmp    80048e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800503:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800507:	eb 8d                	jmp    800496 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 04             	lea    0x4(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 04 24             	mov    %eax,(%esp)
  80051b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800521:	e9 23 ff ff ff       	jmp    800449 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800526:	8b 45 14             	mov    0x14(%ebp),%eax
  800529:	8d 50 04             	lea    0x4(%eax),%edx
  80052c:	89 55 14             	mov    %edx,0x14(%ebp)
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	85 c0                	test   %eax,%eax
  800533:	79 02                	jns    800537 <vprintfmt+0x111>
  800535:	f7 d8                	neg    %eax
  800537:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800539:	83 f8 0f             	cmp    $0xf,%eax
  80053c:	7f 0b                	jg     800549 <vprintfmt+0x123>
  80053e:	8b 04 85 80 24 80 00 	mov    0x802480(,%eax,4),%eax
  800545:	85 c0                	test   %eax,%eax
  800547:	75 23                	jne    80056c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800549:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054d:	c7 44 24 08 ff 21 80 	movl   $0x8021ff,0x8(%esp)
  800554:	00 
  800555:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	e8 9a fe ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 dd fe ff ff       	jmp    800449 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800570:	c7 44 24 08 b1 25 80 	movl   $0x8025b1,0x8(%esp)
  800577:	00 
  800578:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057c:	8b 55 08             	mov    0x8(%ebp),%edx
  80057f:	89 14 24             	mov    %edx,(%esp)
  800582:	e8 77 fe ff ff       	call   8003fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058a:	e9 ba fe ff ff       	jmp    800449 <vprintfmt+0x23>
  80058f:	89 f9                	mov    %edi,%ecx
  800591:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	8b 30                	mov    (%eax),%esi
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	75 05                	jne    8005ab <vprintfmt+0x185>
				p = "(null)";
  8005a6:	be f8 21 80 00       	mov    $0x8021f8,%esi
			if (width > 0 && padc != '-')
  8005ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005af:	0f 8e 84 00 00 00    	jle    800639 <vprintfmt+0x213>
  8005b5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005b9:	74 7e                	je     800639 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005bf:	89 34 24             	mov    %esi,(%esp)
  8005c2:	e8 8b 02 00 00       	call   800852 <strnlen>
  8005c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ca:	29 c2                	sub    %eax,%edx
  8005cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005cf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005d3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005d6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005d9:	89 de                	mov    %ebx,%esi
  8005db:	89 d3                	mov    %edx,%ebx
  8005dd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	eb 0b                	jmp    8005ec <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	89 3c 24             	mov    %edi,(%esp)
  8005e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	85 db                	test   %ebx,%ebx
  8005ee:	7f f1                	jg     8005e1 <vprintfmt+0x1bb>
  8005f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f3:	89 f3                	mov    %esi,%ebx
  8005f5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	79 05                	jns    800604 <vprintfmt+0x1de>
  8005ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	29 c2                	sub    %eax,%edx
  800609:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80060c:	eb 2b                	jmp    800639 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800612:	74 18                	je     80062c <vprintfmt+0x206>
  800614:	8d 50 e0             	lea    -0x20(%eax),%edx
  800617:	83 fa 5e             	cmp    $0x5e,%edx
  80061a:	76 10                	jbe    80062c <vprintfmt+0x206>
					putch('?', putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
  80062a:	eb 0a                	jmp    800636 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80062c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800630:	89 04 24             	mov    %eax,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800636:	ff 4d e4             	decl   -0x1c(%ebp)
  800639:	0f be 06             	movsbl (%esi),%eax
  80063c:	46                   	inc    %esi
  80063d:	85 c0                	test   %eax,%eax
  80063f:	74 21                	je     800662 <vprintfmt+0x23c>
  800641:	85 ff                	test   %edi,%edi
  800643:	78 c9                	js     80060e <vprintfmt+0x1e8>
  800645:	4f                   	dec    %edi
  800646:	79 c6                	jns    80060e <vprintfmt+0x1e8>
  800648:	8b 7d 08             	mov    0x8(%ebp),%edi
  80064b:	89 de                	mov    %ebx,%esi
  80064d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800650:	eb 18                	jmp    80066a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800652:	89 74 24 04          	mov    %esi,0x4(%esp)
  800656:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065f:	4b                   	dec    %ebx
  800660:	eb 08                	jmp    80066a <vprintfmt+0x244>
  800662:	8b 7d 08             	mov    0x8(%ebp),%edi
  800665:	89 de                	mov    %ebx,%esi
  800667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80066a:	85 db                	test   %ebx,%ebx
  80066c:	7f e4                	jg     800652 <vprintfmt+0x22c>
  80066e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800671:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 ce fd ff ff       	jmp    800449 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067b:	83 f9 01             	cmp    $0x1,%ecx
  80067e:	7e 10                	jle    800690 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 08             	lea    0x8(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 30                	mov    (%eax),%esi
  80068b:	8b 78 04             	mov    0x4(%eax),%edi
  80068e:	eb 26                	jmp    8006b6 <vprintfmt+0x290>
	else if (lflag)
  800690:	85 c9                	test   %ecx,%ecx
  800692:	74 12                	je     8006a6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 30                	mov    (%eax),%esi
  80069f:	89 f7                	mov    %esi,%edi
  8006a1:	c1 ff 1f             	sar    $0x1f,%edi
  8006a4:	eb 10                	jmp    8006b6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 30                	mov    (%eax),%esi
  8006b1:	89 f7                	mov    %esi,%edi
  8006b3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b6:	85 ff                	test   %edi,%edi
  8006b8:	78 0a                	js     8006c4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bf:	e9 8c 00 00 00       	jmp    800750 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d2:	f7 de                	neg    %esi
  8006d4:	83 d7 00             	adc    $0x0,%edi
  8006d7:	f7 df                	neg    %edi
			}
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	eb 70                	jmp    800750 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e0:	89 ca                	mov    %ecx,%edx
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 c0 fc ff ff       	call   8003aa <getuint>
  8006ea:	89 c6                	mov    %eax,%esi
  8006ec:	89 d7                	mov    %edx,%edi
			base = 10;
  8006ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006f3:	eb 5b                	jmp    800750 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8006f5:	89 ca                	mov    %ecx,%edx
  8006f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fa:	e8 ab fc ff ff       	call   8003aa <getuint>
  8006ff:	89 c6                	mov    %eax,%esi
  800701:	89 d7                	mov    %edx,%edi
			base = 8;
  800703:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800708:	eb 46                	jmp    800750 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80070a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800715:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800723:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072f:	8b 30                	mov    (%eax),%esi
  800731:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80073b:	eb 13                	jmp    800750 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073d:	89 ca                	mov    %ecx,%edx
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
  800742:	e8 63 fc ff ff       	call   8003aa <getuint>
  800747:	89 c6                	mov    %eax,%esi
  800749:	89 d7                	mov    %edx,%edi
			base = 16;
  80074b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800750:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800754:	89 54 24 10          	mov    %edx,0x10(%esp)
  800758:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80075f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800763:	89 34 24             	mov    %esi,(%esp)
  800766:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076a:	89 da                	mov    %ebx,%edx
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	e8 6c fb ff ff       	call   8002e0 <printnum>
			break;
  800774:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800777:	e9 cd fc ff ff       	jmp    800449 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800786:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800789:	e9 bb fc ff ff       	jmp    800449 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800792:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800799:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079c:	eb 01                	jmp    80079f <vprintfmt+0x379>
  80079e:	4e                   	dec    %esi
  80079f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007a3:	75 f9                	jne    80079e <vprintfmt+0x378>
  8007a5:	e9 9f fc ff ff       	jmp    800449 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007aa:	83 c4 4c             	add    $0x4c,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 28             	sub    $0x28,%esp
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	74 30                	je     800803 <vsnprintf+0x51>
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	7e 33                	jle    80080a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007de:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ec:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  8007f3:	e8 2e fc ff ff       	call   800426 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800801:	eb 0c                	jmp    80080f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800808:	eb 05                	jmp    80080f <vsnprintf+0x5d>
  80080a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800817:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081e:	8b 45 10             	mov    0x10(%ebp),%eax
  800821:	89 44 24 08          	mov    %eax,0x8(%esp)
  800825:	8b 45 0c             	mov    0xc(%ebp),%eax
  800828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 7b ff ff ff       	call   8007b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800837:	c9                   	leave  
  800838:	c3                   	ret    
  800839:	00 00                	add    %al,(%eax)
	...

0080083c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
  800847:	eb 01                	jmp    80084a <strlen+0xe>
		n++;
  800849:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80084a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80084e:	75 f9                	jne    800849 <strlen+0xd>
		n++;
	return n;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
  800860:	eb 01                	jmp    800863 <strnlen+0x11>
		n++;
  800862:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800863:	39 d0                	cmp    %edx,%eax
  800865:	74 06                	je     80086d <strnlen+0x1b>
  800867:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80086b:	75 f5                	jne    800862 <strnlen+0x10>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	53                   	push   %ebx
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
  80087e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800881:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800884:	42                   	inc    %edx
  800885:	84 c9                	test   %cl,%cl
  800887:	75 f5                	jne    80087e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800889:	5b                   	pop    %ebx
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800896:	89 1c 24             	mov    %ebx,(%esp)
  800899:	e8 9e ff ff ff       	call   80083c <strlen>
	strcpy(dst + len, src);
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a5:	01 d8                	add    %ebx,%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 c0 ff ff ff       	call   80086f <strcpy>
	return dst;
}
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	56                   	push   %esi
  8008bb:	53                   	push   %ebx
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ca:	eb 0c                	jmp    8008d8 <strncpy+0x21>
		*dst++ = *src;
  8008cc:	8a 1a                	mov    (%edx),%bl
  8008ce:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d1:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d7:	41                   	inc    %ecx
  8008d8:	39 f1                	cmp    %esi,%ecx
  8008da:	75 f0                	jne    8008cc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008eb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ee:	85 d2                	test   %edx,%edx
  8008f0:	75 0a                	jne    8008fc <strlcpy+0x1c>
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	eb 1a                	jmp    800910 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f6:	88 18                	mov    %bl,(%eax)
  8008f8:	40                   	inc    %eax
  8008f9:	41                   	inc    %ecx
  8008fa:	eb 02                	jmp    8008fe <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008fc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008fe:	4a                   	dec    %edx
  8008ff:	74 0a                	je     80090b <strlcpy+0x2b>
  800901:	8a 19                	mov    (%ecx),%bl
  800903:	84 db                	test   %bl,%bl
  800905:	75 ef                	jne    8008f6 <strlcpy+0x16>
  800907:	89 c2                	mov    %eax,%edx
  800909:	eb 02                	jmp    80090d <strlcpy+0x2d>
  80090b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80090d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800910:	29 f0                	sub    %esi,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091f:	eb 02                	jmp    800923 <strcmp+0xd>
		p++, q++;
  800921:	41                   	inc    %ecx
  800922:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800923:	8a 01                	mov    (%ecx),%al
  800925:	84 c0                	test   %al,%al
  800927:	74 04                	je     80092d <strcmp+0x17>
  800929:	3a 02                	cmp    (%edx),%al
  80092b:	74 f4                	je     800921 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092d:	0f b6 c0             	movzbl %al,%eax
  800930:	0f b6 12             	movzbl (%edx),%edx
  800933:	29 d0                	sub    %edx,%eax
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800941:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800944:	eb 03                	jmp    800949 <strncmp+0x12>
		n--, p++, q++;
  800946:	4a                   	dec    %edx
  800947:	40                   	inc    %eax
  800948:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800949:	85 d2                	test   %edx,%edx
  80094b:	74 14                	je     800961 <strncmp+0x2a>
  80094d:	8a 18                	mov    (%eax),%bl
  80094f:	84 db                	test   %bl,%bl
  800951:	74 04                	je     800957 <strncmp+0x20>
  800953:	3a 19                	cmp    (%ecx),%bl
  800955:	74 ef                	je     800946 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 00             	movzbl (%eax),%eax
  80095a:	0f b6 11             	movzbl (%ecx),%edx
  80095d:	29 d0                	sub    %edx,%eax
  80095f:	eb 05                	jmp    800966 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800961:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800966:	5b                   	pop    %ebx
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800972:	eb 05                	jmp    800979 <strchr+0x10>
		if (*s == c)
  800974:	38 ca                	cmp    %cl,%dl
  800976:	74 0c                	je     800984 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800978:	40                   	inc    %eax
  800979:	8a 10                	mov    (%eax),%dl
  80097b:	84 d2                	test   %dl,%dl
  80097d:	75 f5                	jne    800974 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80098f:	eb 05                	jmp    800996 <strfind+0x10>
		if (*s == c)
  800991:	38 ca                	cmp    %cl,%dl
  800993:	74 07                	je     80099c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800995:	40                   	inc    %eax
  800996:	8a 10                	mov    (%eax),%dl
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f5                	jne    800991 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ad:	85 c9                	test   %ecx,%ecx
  8009af:	74 30                	je     8009e1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b7:	75 25                	jne    8009de <memset+0x40>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 20                	jne    8009de <memset+0x40>
		c &= 0xFF;
  8009be:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d6                	mov    %edx,%esi
  8009c8:	c1 e6 18             	shl    $0x18,%esi
  8009cb:	89 d0                	mov    %edx,%eax
  8009cd:	c1 e0 10             	shl    $0x10,%eax
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 d0                	or     %edx,%eax
  8009d4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 03                	jmp    8009e1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	fc                   	cld    
  8009df:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e1:	89 f8                	mov    %edi,%eax
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5f                   	pop    %edi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f6:	39 c6                	cmp    %eax,%esi
  8009f8:	73 34                	jae    800a2e <memmove+0x46>
  8009fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 2d                	jae    800a2e <memmove+0x46>
		s += n;
		d += n;
  800a01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	f6 c2 03             	test   $0x3,%dl
  800a07:	75 1b                	jne    800a24 <memmove+0x3c>
  800a09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0f:	75 13                	jne    800a24 <memmove+0x3c>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 0e                	jne    800a24 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a16:	83 ef 04             	sub    $0x4,%edi
  800a19:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1f:	fd                   	std    
  800a20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a22:	eb 07                	jmp    800a2b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a24:	4f                   	dec    %edi
  800a25:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a28:	fd                   	std    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2b:	fc                   	cld    
  800a2c:	eb 20                	jmp    800a4e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a34:	75 13                	jne    800a49 <memmove+0x61>
  800a36:	a8 03                	test   $0x3,%al
  800a38:	75 0f                	jne    800a49 <memmove+0x61>
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 0a                	jne    800a49 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a42:	89 c7                	mov    %eax,%edi
  800a44:	fc                   	cld    
  800a45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a47:	eb 05                	jmp    800a4e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a49:	89 c7                	mov    %eax,%edi
  800a4b:	fc                   	cld    
  800a4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a58:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	89 04 24             	mov    %eax,(%esp)
  800a6c:	e8 77 ff ff ff       	call   8009e8 <memmove>
}
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	eb 16                	jmp    800a9f <memcmp+0x2c>
		if (*s1 != *s2)
  800a89:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a8c:	42                   	inc    %edx
  800a8d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a91:	38 c8                	cmp    %cl,%al
  800a93:	74 0a                	je     800a9f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a95:	0f b6 c0             	movzbl %al,%eax
  800a98:	0f b6 c9             	movzbl %cl,%ecx
  800a9b:	29 c8                	sub    %ecx,%eax
  800a9d:	eb 09                	jmp    800aa8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	39 da                	cmp    %ebx,%edx
  800aa1:	75 e6                	jne    800a89 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abb:	eb 05                	jmp    800ac2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	74 05                	je     800ac6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac1:	40                   	inc    %eax
  800ac2:	39 d0                	cmp    %edx,%eax
  800ac4:	72 f7                	jb     800abd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad4:	eb 01                	jmp    800ad7 <strtol+0xf>
		s++;
  800ad6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad7:	8a 02                	mov    (%edx),%al
  800ad9:	3c 20                	cmp    $0x20,%al
  800adb:	74 f9                	je     800ad6 <strtol+0xe>
  800add:	3c 09                	cmp    $0x9,%al
  800adf:	74 f5                	je     800ad6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae1:	3c 2b                	cmp    $0x2b,%al
  800ae3:	75 08                	jne    800aed <strtol+0x25>
		s++;
  800ae5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
  800aeb:	eb 13                	jmp    800b00 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aed:	3c 2d                	cmp    $0x2d,%al
  800aef:	75 0a                	jne    800afb <strtol+0x33>
		s++, neg = 1;
  800af1:	8d 52 01             	lea    0x1(%edx),%edx
  800af4:	bf 01 00 00 00       	mov    $0x1,%edi
  800af9:	eb 05                	jmp    800b00 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800afb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b00:	85 db                	test   %ebx,%ebx
  800b02:	74 05                	je     800b09 <strtol+0x41>
  800b04:	83 fb 10             	cmp    $0x10,%ebx
  800b07:	75 28                	jne    800b31 <strtol+0x69>
  800b09:	8a 02                	mov    (%edx),%al
  800b0b:	3c 30                	cmp    $0x30,%al
  800b0d:	75 10                	jne    800b1f <strtol+0x57>
  800b0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b13:	75 0a                	jne    800b1f <strtol+0x57>
		s += 2, base = 16;
  800b15:	83 c2 02             	add    $0x2,%edx
  800b18:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b1d:	eb 12                	jmp    800b31 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b1f:	85 db                	test   %ebx,%ebx
  800b21:	75 0e                	jne    800b31 <strtol+0x69>
  800b23:	3c 30                	cmp    $0x30,%al
  800b25:	75 05                	jne    800b2c <strtol+0x64>
		s++, base = 8;
  800b27:	42                   	inc    %edx
  800b28:	b3 08                	mov    $0x8,%bl
  800b2a:	eb 05                	jmp    800b31 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b2c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b38:	8a 0a                	mov    (%edx),%cl
  800b3a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b3d:	80 fb 09             	cmp    $0x9,%bl
  800b40:	77 08                	ja     800b4a <strtol+0x82>
			dig = *s - '0';
  800b42:	0f be c9             	movsbl %cl,%ecx
  800b45:	83 e9 30             	sub    $0x30,%ecx
  800b48:	eb 1e                	jmp    800b68 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b4a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b4d:	80 fb 19             	cmp    $0x19,%bl
  800b50:	77 08                	ja     800b5a <strtol+0x92>
			dig = *s - 'a' + 10;
  800b52:	0f be c9             	movsbl %cl,%ecx
  800b55:	83 e9 57             	sub    $0x57,%ecx
  800b58:	eb 0e                	jmp    800b68 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b5a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 12                	ja     800b74 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b62:	0f be c9             	movsbl %cl,%ecx
  800b65:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b68:	39 f1                	cmp    %esi,%ecx
  800b6a:	7d 0c                	jge    800b78 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b6c:	42                   	inc    %edx
  800b6d:	0f af c6             	imul   %esi,%eax
  800b70:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b72:	eb c4                	jmp    800b38 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b74:	89 c1                	mov    %eax,%ecx
  800b76:	eb 02                	jmp    800b7a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b78:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7e:	74 05                	je     800b85 <strtol+0xbd>
		*endptr = (char *) s;
  800b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b83:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b85:	85 ff                	test   %edi,%edi
  800b87:	74 04                	je     800b8d <strtol+0xc5>
  800b89:	89 c8                	mov    %ecx,%eax
  800b8b:	f7 d8                	neg    %eax
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    
	...

00800b94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 c3                	mov    %eax,%ebx
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 c6                	mov    %eax,%esi
  800bab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 cb                	mov    %ecx,%ebx
  800be9:	89 cf                	mov    %ecx,%edi
  800beb:	89 ce                	mov    %ecx,%esi
  800bed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 28                	jle    800c1b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800c16:	e8 b1 f5 ff ff       	call   8001cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	83 c4 2c             	add    $0x2c,%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_yield>:

void
sys_yield(void)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	be 00 00 00 00       	mov    $0x0,%esi
  800c6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 f7                	mov    %esi,%edi
  800c7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 28                	jle    800cad <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800ca8:	e8 1f f5 ff ff       	call   8001cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 28                	jle    800d00 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800ceb:	00 
  800cec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf3:	00 
  800cf4:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800cfb:	e8 cc f4 ff ff       	call   8001cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d00:	83 c4 2c             	add    $0x2c,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 28                	jle    800d53 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d36:	00 
  800d37:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d46:	00 
  800d47:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800d4e:	e8 79 f4 ff ff       	call   8001cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d53:	83 c4 2c             	add    $0x2c,%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 28                	jle    800da6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d82:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d89:	00 
  800d8a:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800d91:	00 
  800d92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d99:	00 
  800d9a:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800da1:	e8 26 f4 ff ff       	call   8001cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	83 c4 2c             	add    $0x2c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 28                	jle    800df9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800de4:	00 
  800de5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dec:	00 
  800ded:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800df4:	e8 d3 f3 ff ff       	call   8001cc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800df9:	83 c4 2c             	add    $0x2c,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 28                	jle    800e4c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e28:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e2f:	00 
  800e30:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800e37:	00 
  800e38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3f:	00 
  800e40:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800e47:	e8 80 f3 ff ff       	call   8001cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4c:	83 c4 2c             	add    $0x2c,%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	be 00 00 00 00       	mov    $0x0,%esi
  800e5f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 cb                	mov    %ecx,%ebx
  800e8f:	89 cf                	mov    %ecx,%edi
  800e91:	89 ce                	mov    %ecx,%esi
  800e93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e95:	85 c0                	test   %eax,%eax
  800e97:	7e 28                	jle    800ec1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 08 df 24 80 	movl   $0x8024df,0x8(%esp)
  800eac:	00 
  800ead:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb4:	00 
  800eb5:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800ebc:	e8 0b f3 ff ff       	call   8001cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec1:	83 c4 2c             	add    $0x2c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	00 00                	add    %al,(%eax)
	...

00800ecc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	89 04 24             	mov    %eax,(%esp)
  800ee8:	e8 df ff ff ff       	call   800ecc <fd2num>
  800eed:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ef2:	c1 e0 0c             	shl    $0xc,%eax
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800efe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800f03:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f05:	89 c2                	mov    %eax,%edx
  800f07:	c1 ea 16             	shr    $0x16,%edx
  800f0a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f11:	f6 c2 01             	test   $0x1,%dl
  800f14:	74 11                	je     800f27 <fd_alloc+0x30>
  800f16:	89 c2                	mov    %eax,%edx
  800f18:	c1 ea 0c             	shr    $0xc,%edx
  800f1b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f22:	f6 c2 01             	test   $0x1,%dl
  800f25:	75 09                	jne    800f30 <fd_alloc+0x39>
			*fd_store = fd;
  800f27:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	eb 17                	jmp    800f47 <fd_alloc+0x50>
  800f30:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f35:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f3a:	75 c7                	jne    800f03 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800f42:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f47:	5b                   	pop    %ebx
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    

00800f4a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f50:	83 f8 1f             	cmp    $0x1f,%eax
  800f53:	77 36                	ja     800f8b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f55:	05 00 00 0d 00       	add    $0xd0000,%eax
  800f5a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 16             	shr    $0x16,%edx
  800f62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 24                	je     800f92 <fd_lookup+0x48>
  800f6e:	89 c2                	mov    %eax,%edx
  800f70:	c1 ea 0c             	shr    $0xc,%edx
  800f73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7a:	f6 c2 01             	test   $0x1,%dl
  800f7d:	74 1a                	je     800f99 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f82:	89 02                	mov    %eax,(%edx)
	return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
  800f89:	eb 13                	jmp    800f9e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f90:	eb 0c                	jmp    800f9e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f97:	eb 05                	jmp    800f9e <fd_lookup+0x54>
  800f99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 14             	sub    $0x14,%esp
  800fa7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800faa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800fad:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb2:	eb 0e                	jmp    800fc2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800fb4:	39 08                	cmp    %ecx,(%eax)
  800fb6:	75 09                	jne    800fc1 <dev_lookup+0x21>
			*dev = devtab[i];
  800fb8:	89 03                	mov    %eax,(%ebx)
			return 0;
  800fba:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbf:	eb 33                	jmp    800ff4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fc1:	42                   	inc    %edx
  800fc2:	8b 04 95 88 25 80 00 	mov    0x802588(,%edx,4),%eax
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	75 e7                	jne    800fb4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fcd:	a1 20 60 80 00       	mov    0x806020,%eax
  800fd2:	8b 40 48             	mov    0x48(%eax),%eax
  800fd5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdd:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  800fe4:	e8 db f2 ff ff       	call   8002c4 <cprintf>
	*dev = 0;
  800fe9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800fef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ff4:	83 c4 14             	add    $0x14,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	56                   	push   %esi
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 30             	sub    $0x30,%esp
  801002:	8b 75 08             	mov    0x8(%ebp),%esi
  801005:	8a 45 0c             	mov    0xc(%ebp),%al
  801008:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80100b:	89 34 24             	mov    %esi,(%esp)
  80100e:	e8 b9 fe ff ff       	call   800ecc <fd2num>
  801013:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801016:	89 54 24 04          	mov    %edx,0x4(%esp)
  80101a:	89 04 24             	mov    %eax,(%esp)
  80101d:	e8 28 ff ff ff       	call   800f4a <fd_lookup>
  801022:	89 c3                	mov    %eax,%ebx
  801024:	85 c0                	test   %eax,%eax
  801026:	78 05                	js     80102d <fd_close+0x33>
	    || fd != fd2)
  801028:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80102b:	74 0d                	je     80103a <fd_close+0x40>
		return (must_exist ? r : 0);
  80102d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801031:	75 46                	jne    801079 <fd_close+0x7f>
  801033:	bb 00 00 00 00       	mov    $0x0,%ebx
  801038:	eb 3f                	jmp    801079 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80103a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80103d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801041:	8b 06                	mov    (%esi),%eax
  801043:	89 04 24             	mov    %eax,(%esp)
  801046:	e8 55 ff ff ff       	call   800fa0 <dev_lookup>
  80104b:	89 c3                	mov    %eax,%ebx
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 18                	js     801069 <fd_close+0x6f>
		if (dev->dev_close)
  801051:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801054:	8b 40 10             	mov    0x10(%eax),%eax
  801057:	85 c0                	test   %eax,%eax
  801059:	74 09                	je     801064 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80105b:	89 34 24             	mov    %esi,(%esp)
  80105e:	ff d0                	call   *%eax
  801060:	89 c3                	mov    %eax,%ebx
  801062:	eb 05                	jmp    801069 <fd_close+0x6f>
		else
			r = 0;
  801064:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80106d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801074:	e8 8f fc ff ff       	call   800d08 <sys_page_unmap>
	return r;
}
  801079:	89 d8                	mov    %ebx,%eax
  80107b:	83 c4 30             	add    $0x30,%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801088:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	89 04 24             	mov    %eax,(%esp)
  801095:	e8 b0 fe ff ff       	call   800f4a <fd_lookup>
  80109a:	85 c0                	test   %eax,%eax
  80109c:	78 13                	js     8010b1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80109e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a5:	00 
  8010a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 49 ff ff ff       	call   800ffa <fd_close>
}
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    

008010b3 <close_all>:

void
close_all(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010bf:	89 1c 24             	mov    %ebx,(%esp)
  8010c2:	e8 bb ff ff ff       	call   801082 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010c7:	43                   	inc    %ebx
  8010c8:	83 fb 20             	cmp    $0x20,%ebx
  8010cb:	75 f2                	jne    8010bf <close_all+0xc>
		close(i);
}
  8010cd:	83 c4 14             	add    $0x14,%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 4c             	sub    $0x4c,%esp
  8010dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	89 04 24             	mov    %eax,(%esp)
  8010ec:	e8 59 fe ff ff       	call   800f4a <fd_lookup>
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	0f 88 e1 00 00 00    	js     8011dc <dup+0x109>
		return r;
	close(newfdnum);
  8010fb:	89 3c 24             	mov    %edi,(%esp)
  8010fe:	e8 7f ff ff ff       	call   801082 <close>

	newfd = INDEX2FD(newfdnum);
  801103:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801109:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80110c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110f:	89 04 24             	mov    %eax,(%esp)
  801112:	e8 c5 fd ff ff       	call   800edc <fd2data>
  801117:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801119:	89 34 24             	mov    %esi,(%esp)
  80111c:	e8 bb fd ff ff       	call   800edc <fd2data>
  801121:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801124:	89 d8                	mov    %ebx,%eax
  801126:	c1 e8 16             	shr    $0x16,%eax
  801129:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801130:	a8 01                	test   $0x1,%al
  801132:	74 46                	je     80117a <dup+0xa7>
  801134:	89 d8                	mov    %ebx,%eax
  801136:	c1 e8 0c             	shr    $0xc,%eax
  801139:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	74 35                	je     80117a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801145:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80114c:	25 07 0e 00 00       	and    $0xe07,%eax
  801151:	89 44 24 10          	mov    %eax,0x10(%esp)
  801155:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801158:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801163:	00 
  801164:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116f:	e8 41 fb ff ff       	call   800cb5 <sys_page_map>
  801174:	89 c3                	mov    %eax,%ebx
  801176:	85 c0                	test   %eax,%eax
  801178:	78 3b                	js     8011b5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	c1 ea 0c             	shr    $0xc,%edx
  801182:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801189:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80118f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801193:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801197:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80119e:	00 
  80119f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011aa:	e8 06 fb ff ff       	call   800cb5 <sys_page_map>
  8011af:	89 c3                	mov    %eax,%ebx
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	79 25                	jns    8011da <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c0:	e8 43 fb ff ff       	call   800d08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8011c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d3:	e8 30 fb ff ff       	call   800d08 <sys_page_unmap>
	return r;
  8011d8:	eb 02                	jmp    8011dc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8011da:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	83 c4 4c             	add    $0x4c,%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 24             	sub    $0x24,%esp
  8011ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f7:	89 1c 24             	mov    %ebx,(%esp)
  8011fa:	e8 4b fd ff ff       	call   800f4a <fd_lookup>
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 6d                	js     801270 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120d:	8b 00                	mov    (%eax),%eax
  80120f:	89 04 24             	mov    %eax,(%esp)
  801212:	e8 89 fd ff ff       	call   800fa0 <dev_lookup>
  801217:	85 c0                	test   %eax,%eax
  801219:	78 55                	js     801270 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80121b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121e:	8b 50 08             	mov    0x8(%eax),%edx
  801221:	83 e2 03             	and    $0x3,%edx
  801224:	83 fa 01             	cmp    $0x1,%edx
  801227:	75 23                	jne    80124c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801229:	a1 20 60 80 00       	mov    0x806020,%eax
  80122e:	8b 40 48             	mov    0x48(%eax),%eax
  801231:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801235:	89 44 24 04          	mov    %eax,0x4(%esp)
  801239:	c7 04 24 4d 25 80 00 	movl   $0x80254d,(%esp)
  801240:	e8 7f f0 ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  801245:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124a:	eb 24                	jmp    801270 <read+0x8a>
	}
	if (!dev->dev_read)
  80124c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80124f:	8b 52 08             	mov    0x8(%edx),%edx
  801252:	85 d2                	test   %edx,%edx
  801254:	74 15                	je     80126b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801256:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801259:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80125d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801260:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	ff d2                	call   *%edx
  801269:	eb 05                	jmp    801270 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80126b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801270:	83 c4 24             	add    $0x24,%esp
  801273:	5b                   	pop    %ebx
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	57                   	push   %edi
  80127a:	56                   	push   %esi
  80127b:	53                   	push   %ebx
  80127c:	83 ec 1c             	sub    $0x1c,%esp
  80127f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801282:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128a:	eb 23                	jmp    8012af <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128c:	89 f0                	mov    %esi,%eax
  80128e:	29 d8                	sub    %ebx,%eax
  801290:	89 44 24 08          	mov    %eax,0x8(%esp)
  801294:	8b 45 0c             	mov    0xc(%ebp),%eax
  801297:	01 d8                	add    %ebx,%eax
  801299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129d:	89 3c 24             	mov    %edi,(%esp)
  8012a0:	e8 41 ff ff ff       	call   8011e6 <read>
		if (m < 0)
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 10                	js     8012b9 <readn+0x43>
			return m;
		if (m == 0)
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	74 0a                	je     8012b7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ad:	01 c3                	add    %eax,%ebx
  8012af:	39 f3                	cmp    %esi,%ebx
  8012b1:	72 d9                	jb     80128c <readn+0x16>
  8012b3:	89 d8                	mov    %ebx,%eax
  8012b5:	eb 02                	jmp    8012b9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8012b7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8012b9:	83 c4 1c             	add    $0x1c,%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5f                   	pop    %edi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 24             	sub    $0x24,%esp
  8012c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d2:	89 1c 24             	mov    %ebx,(%esp)
  8012d5:	e8 70 fc ff ff       	call   800f4a <fd_lookup>
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 68                	js     801346 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	8b 00                	mov    (%eax),%eax
  8012ea:	89 04 24             	mov    %eax,(%esp)
  8012ed:	e8 ae fc ff ff       	call   800fa0 <dev_lookup>
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 50                	js     801346 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fd:	75 23                	jne    801322 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012ff:	a1 20 60 80 00       	mov    0x806020,%eax
  801304:	8b 40 48             	mov    0x48(%eax),%eax
  801307:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130f:	c7 04 24 69 25 80 00 	movl   $0x802569,(%esp)
  801316:	e8 a9 ef ff ff       	call   8002c4 <cprintf>
		return -E_INVAL;
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801320:	eb 24                	jmp    801346 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801322:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801325:	8b 52 0c             	mov    0xc(%edx),%edx
  801328:	85 d2                	test   %edx,%edx
  80132a:	74 15                	je     801341 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80132f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801333:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801336:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80133a:	89 04 24             	mov    %eax,(%esp)
  80133d:	ff d2                	call   *%edx
  80133f:	eb 05                	jmp    801346 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801341:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801346:	83 c4 24             	add    $0x24,%esp
  801349:	5b                   	pop    %ebx
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <seek>:

int
seek(int fdnum, off_t offset)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801352:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801355:	89 44 24 04          	mov    %eax,0x4(%esp)
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	89 04 24             	mov    %eax,(%esp)
  80135f:	e8 e6 fb ff ff       	call   800f4a <fd_lookup>
  801364:	85 c0                	test   %eax,%eax
  801366:	78 0e                	js     801376 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801368:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 24             	sub    $0x24,%esp
  80137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801382:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801385:	89 44 24 04          	mov    %eax,0x4(%esp)
  801389:	89 1c 24             	mov    %ebx,(%esp)
  80138c:	e8 b9 fb ff ff       	call   800f4a <fd_lookup>
  801391:	85 c0                	test   %eax,%eax
  801393:	78 61                	js     8013f6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139f:	8b 00                	mov    (%eax),%eax
  8013a1:	89 04 24             	mov    %eax,(%esp)
  8013a4:	e8 f7 fb ff ff       	call   800fa0 <dev_lookup>
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 49                	js     8013f6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b4:	75 23                	jne    8013d9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b6:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013bb:	8b 40 48             	mov    0x48(%eax),%eax
  8013be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c6:	c7 04 24 2c 25 80 00 	movl   $0x80252c,(%esp)
  8013cd:	e8 f2 ee ff ff       	call   8002c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d7:	eb 1d                	jmp    8013f6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8013d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013dc:	8b 52 18             	mov    0x18(%edx),%edx
  8013df:	85 d2                	test   %edx,%edx
  8013e1:	74 0e                	je     8013f1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013ea:	89 04 24             	mov    %eax,(%esp)
  8013ed:	ff d2                	call   *%edx
  8013ef:	eb 05                	jmp    8013f6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f6:	83 c4 24             	add    $0x24,%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	53                   	push   %ebx
  801400:	83 ec 24             	sub    $0x24,%esp
  801403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801406:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	89 04 24             	mov    %eax,(%esp)
  801413:	e8 32 fb ff ff       	call   800f4a <fd_lookup>
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 52                	js     80146e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801423:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801426:	8b 00                	mov    (%eax),%eax
  801428:	89 04 24             	mov    %eax,(%esp)
  80142b:	e8 70 fb ff ff       	call   800fa0 <dev_lookup>
  801430:	85 c0                	test   %eax,%eax
  801432:	78 3a                	js     80146e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801437:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143b:	74 2c                	je     801469 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80143d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801440:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801447:	00 00 00 
	stat->st_isdir = 0;
  80144a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801451:	00 00 00 
	stat->st_dev = dev;
  801454:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80145e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801461:	89 14 24             	mov    %edx,(%esp)
  801464:	ff 50 14             	call   *0x14(%eax)
  801467:	eb 05                	jmp    80146e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801469:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80146e:	83 c4 24             	add    $0x24,%esp
  801471:	5b                   	pop    %ebx
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80147c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801483:	00 
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 2d 02 00 00       	call   8016bc <open>
  80148f:	89 c3                	mov    %eax,%ebx
  801491:	85 c0                	test   %eax,%eax
  801493:	78 1b                	js     8014b0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801495:	8b 45 0c             	mov    0xc(%ebp),%eax
  801498:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149c:	89 1c 24             	mov    %ebx,(%esp)
  80149f:	e8 58 ff ff ff       	call   8013fc <fstat>
  8014a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a6:	89 1c 24             	mov    %ebx,(%esp)
  8014a9:	e8 d4 fb ff ff       	call   801082 <close>
	return r;
  8014ae:	89 f3                	mov    %esi,%ebx
}
  8014b0:	89 d8                	mov    %ebx,%eax
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	5b                   	pop    %ebx
  8014b6:	5e                   	pop    %esi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    
  8014b9:	00 00                	add    %al,(%eax)
	...

008014bc <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 10             	sub    $0x10,%esp
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8014c8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014cf:	75 11                	jne    8014e2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8014d8:	e8 a6 09 00 00       	call   801e83 <ipc_find_env>
  8014dd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014e2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8014e9:	00 
  8014ea:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8014f1:	00 
  8014f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8014fb:	89 04 24             	mov    %eax,(%esp)
  8014fe:	e8 12 09 00 00       	call   801e15 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801503:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80150a:	00 
  80150b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801516:	e8 91 08 00 00       	call   801dac <ipc_recv>
}
  80151b:	83 c4 10             	add    $0x10,%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801528:	8b 45 08             	mov    0x8(%ebp),%eax
  80152b:	8b 40 0c             	mov    0xc(%eax),%eax
  80152e:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801533:	8b 45 0c             	mov    0xc(%ebp),%eax
  801536:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80153b:	ba 00 00 00 00       	mov    $0x0,%edx
  801540:	b8 02 00 00 00       	mov    $0x2,%eax
  801545:	e8 72 ff ff ff       	call   8014bc <fsipc>
}
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801552:	8b 45 08             	mov    0x8(%ebp),%eax
  801555:	8b 40 0c             	mov    0xc(%eax),%eax
  801558:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	b8 06 00 00 00       	mov    $0x6,%eax
  801567:	e8 50 ff ff ff       	call   8014bc <fsipc>
}
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	53                   	push   %ebx
  801572:	83 ec 14             	sub    $0x14,%esp
  801575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 40 0c             	mov    0xc(%eax),%eax
  80157e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801583:	ba 00 00 00 00       	mov    $0x0,%edx
  801588:	b8 05 00 00 00       	mov    $0x5,%eax
  80158d:	e8 2a ff ff ff       	call   8014bc <fsipc>
  801592:	85 c0                	test   %eax,%eax
  801594:	78 2b                	js     8015c1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801596:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80159d:	00 
  80159e:	89 1c 24             	mov    %ebx,(%esp)
  8015a1:	e8 c9 f2 ff ff       	call   80086f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015a6:	a1 80 70 80 00       	mov    0x807080,%eax
  8015ab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015b1:	a1 84 70 80 00       	mov    0x807084,%eax
  8015b6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c1:	83 c4 14             	add    $0x14,%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 18             	sub    $0x18,%esp
  8015cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8015d0:	89 d0                	mov    %edx,%eax
  8015d2:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  8015d8:	76 05                	jbe    8015df <devfile_write+0x18>
  8015da:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015df:	8b 55 08             	mov    0x8(%ebp),%edx
  8015e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015e5:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8015eb:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  801602:	e8 e1 f3 ff ff       	call   8009e8 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801607:	ba 00 00 00 00       	mov    $0x0,%edx
  80160c:	b8 04 00 00 00       	mov    $0x4,%eax
  801611:	e8 a6 fe ff ff       	call   8014bc <fsipc>
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	56                   	push   %esi
  80161c:	53                   	push   %ebx
  80161d:	83 ec 10             	sub    $0x10,%esp
  801620:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	8b 40 0c             	mov    0xc(%eax),%eax
  801629:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  80162e:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	b8 03 00 00 00       	mov    $0x3,%eax
  80163e:	e8 79 fe ff ff       	call   8014bc <fsipc>
  801643:	89 c3                	mov    %eax,%ebx
  801645:	85 c0                	test   %eax,%eax
  801647:	78 6a                	js     8016b3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801649:	39 c6                	cmp    %eax,%esi
  80164b:	73 24                	jae    801671 <devfile_read+0x59>
  80164d:	c7 44 24 0c 98 25 80 	movl   $0x802598,0xc(%esp)
  801654:	00 
  801655:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  80165c:	00 
  80165d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801664:	00 
  801665:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  80166c:	e8 5b eb ff ff       	call   8001cc <_panic>
	assert(r <= PGSIZE);
  801671:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801676:	7e 24                	jle    80169c <devfile_read+0x84>
  801678:	c7 44 24 0c bf 25 80 	movl   $0x8025bf,0xc(%esp)
  80167f:	00 
  801680:	c7 44 24 08 9f 25 80 	movl   $0x80259f,0x8(%esp)
  801687:	00 
  801688:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80168f:	00 
  801690:	c7 04 24 b4 25 80 00 	movl   $0x8025b4,(%esp)
  801697:	e8 30 eb ff ff       	call   8001cc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80169c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8016a7:	00 
  8016a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ab:	89 04 24             	mov    %eax,(%esp)
  8016ae:	e8 35 f3 ff ff       	call   8009e8 <memmove>
	return r;
}
  8016b3:	89 d8                	mov    %ebx,%eax
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5e                   	pop    %esi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 20             	sub    $0x20,%esp
  8016c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8016c7:	89 34 24             	mov    %esi,(%esp)
  8016ca:	e8 6d f1 ff ff       	call   80083c <strlen>
  8016cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d4:	7f 60                	jg     801736 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 16 f8 ff ff       	call   800ef7 <fd_alloc>
  8016e1:	89 c3                	mov    %eax,%ebx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 54                	js     80173b <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016eb:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8016f2:	e8 78 f1 ff ff       	call   80086f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fa:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801702:	b8 01 00 00 00       	mov    $0x1,%eax
  801707:	e8 b0 fd ff ff       	call   8014bc <fsipc>
  80170c:	89 c3                	mov    %eax,%ebx
  80170e:	85 c0                	test   %eax,%eax
  801710:	79 15                	jns    801727 <open+0x6b>
		fd_close(fd, 0);
  801712:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801719:	00 
  80171a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171d:	89 04 24             	mov    %eax,(%esp)
  801720:	e8 d5 f8 ff ff       	call   800ffa <fd_close>
		return r;
  801725:	eb 14                	jmp    80173b <open+0x7f>
	}

	return fd2num(fd);
  801727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172a:	89 04 24             	mov    %eax,(%esp)
  80172d:	e8 9a f7 ff ff       	call   800ecc <fd2num>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	eb 05                	jmp    80173b <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801736:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80173b:	89 d8                	mov    %ebx,%eax
  80173d:	83 c4 20             	add    $0x20,%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80174a:	ba 00 00 00 00       	mov    $0x0,%edx
  80174f:	b8 08 00 00 00       	mov    $0x8,%eax
  801754:	e8 63 fd ff ff       	call   8014bc <fsipc>
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    
	...

0080175c <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	53                   	push   %ebx
  801760:	83 ec 14             	sub    $0x14,%esp
  801763:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801765:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801769:	7e 32                	jle    80179d <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  80176b:	8b 40 04             	mov    0x4(%eax),%eax
  80176e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801772:	8d 43 10             	lea    0x10(%ebx),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	8b 03                	mov    (%ebx),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 3e fb ff ff       	call   8012c1 <write>
		if (result > 0)
  801783:	85 c0                	test   %eax,%eax
  801785:	7e 03                	jle    80178a <writebuf+0x2e>
			b->result += result;
  801787:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80178a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80178d:	74 0e                	je     80179d <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  80178f:	89 c2                	mov    %eax,%edx
  801791:	85 c0                	test   %eax,%eax
  801793:	7e 05                	jle    80179a <writebuf+0x3e>
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  80179d:	83 c4 14             	add    $0x14,%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <putch>:

static void
putch(int ch, void *thunk)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 04             	sub    $0x4,%esp
  8017aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017ad:	8b 43 04             	mov    0x4(%ebx),%eax
  8017b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b3:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  8017b7:	40                   	inc    %eax
  8017b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  8017bb:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017c0:	75 0e                	jne    8017d0 <putch+0x2d>
		writebuf(b);
  8017c2:	89 d8                	mov    %ebx,%eax
  8017c4:	e8 93 ff ff ff       	call   80175c <writebuf>
		b->idx = 0;
  8017c9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8017d0:	83 c4 04             	add    $0x4,%esp
  8017d3:	5b                   	pop    %ebx
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017e8:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017ef:	00 00 00 
	b.result = 0;
  8017f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017f9:	00 00 00 
	b.error = 1;
  8017fc:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801803:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801806:	8b 45 10             	mov    0x10(%ebp),%eax
  801809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80180d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801810:	89 44 24 08          	mov    %eax,0x8(%esp)
  801814:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80181a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181e:	c7 04 24 a3 17 80 00 	movl   $0x8017a3,(%esp)
  801825:	e8 fc eb ff ff       	call   800426 <vprintfmt>
	if (b.idx > 0)
  80182a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801831:	7e 0b                	jle    80183e <vfprintf+0x68>
		writebuf(&b);
  801833:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801839:	e8 1e ff ff ff       	call   80175c <writebuf>

	return (b.result ? b.result : b.error);
  80183e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801844:	85 c0                	test   %eax,%eax
  801846:	75 06                	jne    80184e <vfprintf+0x78>
  801848:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801856:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	89 44 24 04          	mov    %eax,0x4(%esp)
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	89 04 24             	mov    %eax,(%esp)
  80186a:	e8 67 ff ff ff       	call   8017d6 <vfprintf>
	va_end(ap);

	return cnt;
}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <printf>:

int
printf(const char *fmt, ...)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801877:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80187a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80188c:	e8 45 ff ff ff       	call   8017d6 <vfprintf>
	va_end(ap);

	return cnt;
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    
	...

00801894 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	83 ec 10             	sub    $0x10,%esp
  80189c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	89 04 24             	mov    %eax,(%esp)
  8018a5:	e8 32 f6 ff ff       	call   800edc <fd2data>
  8018aa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8018ac:	c7 44 24 04 cb 25 80 	movl   $0x8025cb,0x4(%esp)
  8018b3:	00 
  8018b4:	89 34 24             	mov    %esi,(%esp)
  8018b7:	e8 b3 ef ff ff       	call   80086f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8018bf:	2b 03                	sub    (%ebx),%eax
  8018c1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8018c7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8018ce:	00 00 00 
	stat->st_dev = &devpipe;
  8018d1:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  8018d8:	30 80 00 
	return 0;
}
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 14             	sub    $0x14,%esp
  8018ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fc:	e8 07 f4 ff ff       	call   800d08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801901:	89 1c 24             	mov    %ebx,(%esp)
  801904:	e8 d3 f5 ff ff       	call   800edc <fd2data>
  801909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801914:	e8 ef f3 ff ff       	call   800d08 <sys_page_unmap>
}
  801919:	83 c4 14             	add    $0x14,%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	57                   	push   %edi
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 2c             	sub    $0x2c,%esp
  801928:	89 c7                	mov    %eax,%edi
  80192a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80192d:	a1 20 60 80 00       	mov    0x806020,%eax
  801932:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801935:	89 3c 24             	mov    %edi,(%esp)
  801938:	e8 8b 05 00 00       	call   801ec8 <pageref>
  80193d:	89 c6                	mov    %eax,%esi
  80193f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801942:	89 04 24             	mov    %eax,(%esp)
  801945:	e8 7e 05 00 00       	call   801ec8 <pageref>
  80194a:	39 c6                	cmp    %eax,%esi
  80194c:	0f 94 c0             	sete   %al
  80194f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801952:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801958:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80195b:	39 cb                	cmp    %ecx,%ebx
  80195d:	75 08                	jne    801967 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80195f:	83 c4 2c             	add    $0x2c,%esp
  801962:	5b                   	pop    %ebx
  801963:	5e                   	pop    %esi
  801964:	5f                   	pop    %edi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801967:	83 f8 01             	cmp    $0x1,%eax
  80196a:	75 c1                	jne    80192d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196c:	8b 42 58             	mov    0x58(%edx),%eax
  80196f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801976:	00 
  801977:	89 44 24 08          	mov    %eax,0x8(%esp)
  80197b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80197f:	c7 04 24 d2 25 80 00 	movl   $0x8025d2,(%esp)
  801986:	e8 39 e9 ff ff       	call   8002c4 <cprintf>
  80198b:	eb a0                	jmp    80192d <_pipeisclosed+0xe>

0080198d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	83 ec 1c             	sub    $0x1c,%esp
  801996:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801999:	89 34 24             	mov    %esi,(%esp)
  80199c:	e8 3b f5 ff ff       	call   800edc <fd2data>
  8019a1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a8:	eb 3c                	jmp    8019e6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019aa:	89 da                	mov    %ebx,%edx
  8019ac:	89 f0                	mov    %esi,%eax
  8019ae:	e8 6c ff ff ff       	call   80191f <_pipeisclosed>
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	75 38                	jne    8019ef <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019b7:	e8 86 f2 ff ff       	call   800c42 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8019bf:	8b 13                	mov    (%ebx),%edx
  8019c1:	83 c2 20             	add    $0x20,%edx
  8019c4:	39 d0                	cmp    %edx,%eax
  8019c6:	73 e2                	jae    8019aa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019cb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8019ce:	89 c2                	mov    %eax,%edx
  8019d0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8019d6:	79 05                	jns    8019dd <devpipe_write+0x50>
  8019d8:	4a                   	dec    %edx
  8019d9:	83 ca e0             	or     $0xffffffe0,%edx
  8019dc:	42                   	inc    %edx
  8019dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019e1:	40                   	inc    %eax
  8019e2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019e5:	47                   	inc    %edi
  8019e6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019e9:	75 d1                	jne    8019bc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019eb:	89 f8                	mov    %edi,%eax
  8019ed:	eb 05                	jmp    8019f4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ef:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019f4:	83 c4 1c             	add    $0x1c,%esp
  8019f7:	5b                   	pop    %ebx
  8019f8:	5e                   	pop    %esi
  8019f9:	5f                   	pop    %edi
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	57                   	push   %edi
  801a00:	56                   	push   %esi
  801a01:	53                   	push   %ebx
  801a02:	83 ec 1c             	sub    $0x1c,%esp
  801a05:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a08:	89 3c 24             	mov    %edi,(%esp)
  801a0b:	e8 cc f4 ff ff       	call   800edc <fd2data>
  801a10:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a12:	be 00 00 00 00       	mov    $0x0,%esi
  801a17:	eb 3a                	jmp    801a53 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a19:	85 f6                	test   %esi,%esi
  801a1b:	74 04                	je     801a21 <devpipe_read+0x25>
				return i;
  801a1d:	89 f0                	mov    %esi,%eax
  801a1f:	eb 40                	jmp    801a61 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a21:	89 da                	mov    %ebx,%edx
  801a23:	89 f8                	mov    %edi,%eax
  801a25:	e8 f5 fe ff ff       	call   80191f <_pipeisclosed>
  801a2a:	85 c0                	test   %eax,%eax
  801a2c:	75 2e                	jne    801a5c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a2e:	e8 0f f2 ff ff       	call   800c42 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a33:	8b 03                	mov    (%ebx),%eax
  801a35:	3b 43 04             	cmp    0x4(%ebx),%eax
  801a38:	74 df                	je     801a19 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a3a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801a3f:	79 05                	jns    801a46 <devpipe_read+0x4a>
  801a41:	48                   	dec    %eax
  801a42:	83 c8 e0             	or     $0xffffffe0,%eax
  801a45:	40                   	inc    %eax
  801a46:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801a50:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a52:	46                   	inc    %esi
  801a53:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a56:	75 db                	jne    801a33 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a58:	89 f0                	mov    %esi,%eax
  801a5a:	eb 05                	jmp    801a61 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a5c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a61:	83 c4 1c             	add    $0x1c,%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	57                   	push   %edi
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 3c             	sub    $0x3c,%esp
  801a72:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a75:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 77 f4 ff ff       	call   800ef7 <fd_alloc>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	85 c0                	test   %eax,%eax
  801a84:	0f 88 45 01 00 00    	js     801bcf <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a91:	00 
  801a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa0:	e8 bc f1 ff ff       	call   800c61 <sys_page_alloc>
  801aa5:	89 c3                	mov    %eax,%ebx
  801aa7:	85 c0                	test   %eax,%eax
  801aa9:	0f 88 20 01 00 00    	js     801bcf <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801aaf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ab2:	89 04 24             	mov    %eax,(%esp)
  801ab5:	e8 3d f4 ff ff       	call   800ef7 <fd_alloc>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	85 c0                	test   %eax,%eax
  801abe:	0f 88 f8 00 00 00    	js     801bbc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801acb:	00 
  801acc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ada:	e8 82 f1 ff ff       	call   800c61 <sys_page_alloc>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	0f 88 d3 00 00 00    	js     801bbc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aec:	89 04 24             	mov    %eax,(%esp)
  801aef:	e8 e8 f3 ff ff       	call   800edc <fd2data>
  801af4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801afd:	00 
  801afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b09:	e8 53 f1 ff ff       	call   800c61 <sys_page_alloc>
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 91 00 00 00    	js     801ba9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b1b:	89 04 24             	mov    %eax,(%esp)
  801b1e:	e8 b9 f3 ff ff       	call   800edc <fd2data>
  801b23:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801b2a:	00 
  801b2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b36:	00 
  801b37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b42:	e8 6e f1 ff ff       	call   800cb5 <sys_page_map>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 4c                	js     801b99 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b56:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b5b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b62:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b6b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b70:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7a:	89 04 24             	mov    %eax,(%esp)
  801b7d:	e8 4a f3 ff ff       	call   800ecc <fd2num>
  801b82:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b84:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b87:	89 04 24             	mov    %eax,(%esp)
  801b8a:	e8 3d f3 ff ff       	call   800ecc <fd2num>
  801b8f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b92:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b97:	eb 36                	jmp    801bcf <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b99:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba4:	e8 5f f1 ff ff       	call   800d08 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ba9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb7:	e8 4c f1 ff ff       	call   800d08 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801bbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bca:	e8 39 f1 ff ff       	call   800d08 <sys_page_unmap>
    err:
	return r;
}
  801bcf:	89 d8                	mov    %ebx,%eax
  801bd1:	83 c4 3c             	add    $0x3c,%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be6:	8b 45 08             	mov    0x8(%ebp),%eax
  801be9:	89 04 24             	mov    %eax,(%esp)
  801bec:	e8 59 f3 ff ff       	call   800f4a <fd_lookup>
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	78 15                	js     801c0a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 dc f2 ff ff       	call   800edc <fd2data>
	return _pipeisclosed(fd, p);
  801c00:	89 c2                	mov    %eax,%edx
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	e8 15 fd ff ff       	call   80191f <_pipeisclosed>
}
  801c0a:	c9                   	leave  
  801c0b:	c3                   	ret    

00801c0c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801c1c:	c7 44 24 04 ea 25 80 	movl   $0x8025ea,0x4(%esp)
  801c23:	00 
  801c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c27:	89 04 24             	mov    %eax,(%esp)
  801c2a:	e8 40 ec ff ff       	call   80086f <strcpy>
	return 0;
}
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	57                   	push   %edi
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c42:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4d:	eb 30                	jmp    801c7f <devcons_write+0x49>
		m = n - tot;
  801c4f:	8b 75 10             	mov    0x10(%ebp),%esi
  801c52:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801c54:	83 fe 7f             	cmp    $0x7f,%esi
  801c57:	76 05                	jbe    801c5e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801c59:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c5e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c62:	03 45 0c             	add    0xc(%ebp),%eax
  801c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c69:	89 3c 24             	mov    %edi,(%esp)
  801c6c:	e8 77 ed ff ff       	call   8009e8 <memmove>
		sys_cputs(buf, m);
  801c71:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c75:	89 3c 24             	mov    %edi,(%esp)
  801c78:	e8 17 ef ff ff       	call   800b94 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c7d:	01 f3                	add    %esi,%ebx
  801c7f:	89 d8                	mov    %ebx,%eax
  801c81:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c84:	72 c9                	jb     801c4f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c86:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5f                   	pop    %edi
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c9b:	75 07                	jne    801ca4 <devcons_read+0x13>
  801c9d:	eb 25                	jmp    801cc4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c9f:	e8 9e ef ff ff       	call   800c42 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ca4:	e8 09 ef ff ff       	call   800bb2 <sys_cgetc>
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	74 f2                	je     801c9f <devcons_read+0xe>
  801cad:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 1d                	js     801cd0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cb3:	83 f8 04             	cmp    $0x4,%eax
  801cb6:	74 13                	je     801ccb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbb:	88 10                	mov    %dl,(%eax)
	return 1;
  801cbd:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc2:	eb 0c                	jmp    801cd0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc9:	eb 05                	jmp    801cd0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cd0:	c9                   	leave  
  801cd1:	c3                   	ret    

00801cd2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cde:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801ce5:	00 
  801ce6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce9:	89 04 24             	mov    %eax,(%esp)
  801cec:	e8 a3 ee ff ff       	call   800b94 <sys_cputs>
}
  801cf1:	c9                   	leave  
  801cf2:	c3                   	ret    

00801cf3 <getchar>:

int
getchar(void)
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cf9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801d00:	00 
  801d01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0f:	e8 d2 f4 ff ff       	call   8011e6 <read>
	if (r < 0)
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 0f                	js     801d27 <getchar+0x34>
		return r;
	if (r < 1)
  801d18:	85 c0                	test   %eax,%eax
  801d1a:	7e 06                	jle    801d22 <getchar+0x2f>
		return -E_EOF;
	return c;
  801d1c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d20:	eb 05                	jmp    801d27 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d22:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	89 04 24             	mov    %eax,(%esp)
  801d3c:	e8 09 f2 ff ff       	call   800f4a <fd_lookup>
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 11                	js     801d56 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d48:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d4e:	39 10                	cmp    %edx,(%eax)
  801d50:	0f 94 c0             	sete   %al
  801d53:	0f b6 c0             	movzbl %al,%eax
}
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <opencons>:

int
opencons(void)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d61:	89 04 24             	mov    %eax,(%esp)
  801d64:	e8 8e f1 ff ff       	call   800ef7 <fd_alloc>
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 3c                	js     801da9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d6d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d74:	00 
  801d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d83:	e8 d9 ee ff ff       	call   800c61 <sys_page_alloc>
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	78 1d                	js     801da9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d8c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801da1:	89 04 24             	mov    %eax,(%esp)
  801da4:	e8 23 f1 ff ff       	call   800ecc <fd2num>
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    
	...

00801dac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 10             	sub    $0x10,%esp
  801db4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dba:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801dbd:	85 c0                	test   %eax,%eax
  801dbf:	75 05                	jne    801dc6 <ipc_recv+0x1a>
  801dc1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 a9 f0 ff ff       	call   800e77 <sys_ipc_recv>
	if (from_env_store != NULL)
  801dce:	85 db                	test   %ebx,%ebx
  801dd0:	74 0b                	je     801ddd <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  801dd2:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801dd8:	8b 52 74             	mov    0x74(%edx),%edx
  801ddb:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801ddd:	85 f6                	test   %esi,%esi
  801ddf:	74 0b                	je     801dec <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801de1:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801de7:	8b 52 78             	mov    0x78(%edx),%edx
  801dea:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801dec:	85 c0                	test   %eax,%eax
  801dee:	79 16                	jns    801e06 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801df0:	85 db                	test   %ebx,%ebx
  801df2:	74 06                	je     801dfa <ipc_recv+0x4e>
			*from_env_store = 0;
  801df4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801dfa:	85 f6                	test   %esi,%esi
  801dfc:	74 10                	je     801e0e <ipc_recv+0x62>
			*perm_store = 0;
  801dfe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801e04:	eb 08                	jmp    801e0e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801e06:	a1 20 60 80 00       	mov    0x806020,%eax
  801e0b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	57                   	push   %edi
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	83 ec 1c             	sub    $0x1c,%esp
  801e1e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801e27:	eb 2a                	jmp    801e53 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801e29:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e2c:	74 20                	je     801e4e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801e2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e32:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  801e39:	00 
  801e3a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801e41:	00 
  801e42:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  801e49:	e8 7e e3 ff ff       	call   8001cc <_panic>
		sys_yield();
  801e4e:	e8 ef ed ff ff       	call   800c42 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801e53:	85 db                	test   %ebx,%ebx
  801e55:	75 07                	jne    801e5e <ipc_send+0x49>
  801e57:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e5c:	eb 02                	jmp    801e60 <ipc_send+0x4b>
  801e5e:	89 d8                	mov    %ebx,%eax
  801e60:	8b 55 14             	mov    0x14(%ebp),%edx
  801e63:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e6b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e6f:	89 34 24             	mov    %esi,(%esp)
  801e72:	e8 dd ef ff ff       	call   800e54 <sys_ipc_try_send>
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 ae                	js     801e29 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801e7b:	83 c4 1c             	add    $0x1c,%esp
  801e7e:	5b                   	pop    %ebx
  801e7f:	5e                   	pop    %esi
  801e80:	5f                   	pop    %edi
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	53                   	push   %ebx
  801e87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801e8a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e8f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e96:	89 c2                	mov    %eax,%edx
  801e98:	c1 e2 07             	shl    $0x7,%edx
  801e9b:	29 ca                	sub    %ecx,%edx
  801e9d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ea3:	8b 52 50             	mov    0x50(%edx),%edx
  801ea6:	39 da                	cmp    %ebx,%edx
  801ea8:	75 0f                	jne    801eb9 <ipc_find_env+0x36>
			return envs[i].env_id;
  801eaa:	c1 e0 07             	shl    $0x7,%eax
  801ead:	29 c8                	sub    %ecx,%eax
  801eaf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801eb4:	8b 40 40             	mov    0x40(%eax),%eax
  801eb7:	eb 0c                	jmp    801ec5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eb9:	40                   	inc    %eax
  801eba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ebf:	75 ce                	jne    801e8f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ec1:	66 b8 00 00          	mov    $0x0,%ax
}
  801ec5:	5b                   	pop    %ebx
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ece:	89 c2                	mov    %eax,%edx
  801ed0:	c1 ea 16             	shr    $0x16,%edx
  801ed3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801eda:	f6 c2 01             	test   $0x1,%dl
  801edd:	74 1e                	je     801efd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801edf:	c1 e8 0c             	shr    $0xc,%eax
  801ee2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ee9:	a8 01                	test   $0x1,%al
  801eeb:	74 17                	je     801f04 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801eed:	c1 e8 0c             	shr    $0xc,%eax
  801ef0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801ef7:	ef 
  801ef8:	0f b7 c0             	movzwl %ax,%eax
  801efb:	eb 0c                	jmp    801f09 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801efd:	b8 00 00 00 00       	mov    $0x0,%eax
  801f02:	eb 05                	jmp    801f09 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    
	...

00801f0c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801f0c:	55                   	push   %ebp
  801f0d:	57                   	push   %edi
  801f0e:	56                   	push   %esi
  801f0f:	83 ec 10             	sub    $0x10,%esp
  801f12:	8b 74 24 20          	mov    0x20(%esp),%esi
  801f16:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801f22:	89 cd                	mov    %ecx,%ebp
  801f24:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	75 2c                	jne    801f58 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801f2c:	39 f9                	cmp    %edi,%ecx
  801f2e:	77 68                	ja     801f98 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f30:	85 c9                	test   %ecx,%ecx
  801f32:	75 0b                	jne    801f3f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f34:	b8 01 00 00 00       	mov    $0x1,%eax
  801f39:	31 d2                	xor    %edx,%edx
  801f3b:	f7 f1                	div    %ecx
  801f3d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f3f:	31 d2                	xor    %edx,%edx
  801f41:	89 f8                	mov    %edi,%eax
  801f43:	f7 f1                	div    %ecx
  801f45:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f47:	89 f0                	mov    %esi,%eax
  801f49:	f7 f1                	div    %ecx
  801f4b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f4d:	89 f0                	mov    %esi,%eax
  801f4f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f58:	39 f8                	cmp    %edi,%eax
  801f5a:	77 2c                	ja     801f88 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f5c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801f5f:	83 f6 1f             	xor    $0x1f,%esi
  801f62:	75 4c                	jne    801fb0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f64:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f66:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f6b:	72 0a                	jb     801f77 <__udivdi3+0x6b>
  801f6d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f71:	0f 87 ad 00 00 00    	ja     802024 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f77:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f7c:	89 f0                	mov    %esi,%eax
  801f7e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	5e                   	pop    %esi
  801f84:	5f                   	pop    %edi
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    
  801f87:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f88:	31 ff                	xor    %edi,%edi
  801f8a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801f8c:	89 f0                	mov    %esi,%eax
  801f8e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    
  801f97:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f98:	89 fa                	mov    %edi,%edx
  801f9a:	89 f0                	mov    %esi,%eax
  801f9c:	f7 f1                	div    %ecx
  801f9e:	89 c6                	mov    %eax,%esi
  801fa0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801fa2:	89 f0                	mov    %esi,%eax
  801fa4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	5e                   	pop    %esi
  801faa:	5f                   	pop    %edi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    
  801fad:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801fb0:	89 f1                	mov    %esi,%ecx
  801fb2:	d3 e0                	shl    %cl,%eax
  801fb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801fb8:	b8 20 00 00 00       	mov    $0x20,%eax
  801fbd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801fbf:	89 ea                	mov    %ebp,%edx
  801fc1:	88 c1                	mov    %al,%cl
  801fc3:	d3 ea                	shr    %cl,%edx
  801fc5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801fc9:	09 ca                	or     %ecx,%edx
  801fcb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801fcf:	89 f1                	mov    %esi,%ecx
  801fd1:	d3 e5                	shl    %cl,%ebp
  801fd3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801fd7:	89 fd                	mov    %edi,%ebp
  801fd9:	88 c1                	mov    %al,%cl
  801fdb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801fdd:	89 fa                	mov    %edi,%edx
  801fdf:	89 f1                	mov    %esi,%ecx
  801fe1:	d3 e2                	shl    %cl,%edx
  801fe3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801fe7:	88 c1                	mov    %al,%cl
  801fe9:	d3 ef                	shr    %cl,%edi
  801feb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801fed:	89 f8                	mov    %edi,%eax
  801fef:	89 ea                	mov    %ebp,%edx
  801ff1:	f7 74 24 08          	divl   0x8(%esp)
  801ff5:	89 d1                	mov    %edx,%ecx
  801ff7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801ff9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ffd:	39 d1                	cmp    %edx,%ecx
  801fff:	72 17                	jb     802018 <__udivdi3+0x10c>
  802001:	74 09                	je     80200c <__udivdi3+0x100>
  802003:	89 fe                	mov    %edi,%esi
  802005:	31 ff                	xor    %edi,%edi
  802007:	e9 41 ff ff ff       	jmp    801f4d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80200c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802010:	89 f1                	mov    %esi,%ecx
  802012:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802014:	39 c2                	cmp    %eax,%edx
  802016:	73 eb                	jae    802003 <__udivdi3+0xf7>
		{
		  q0--;
  802018:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80201b:	31 ff                	xor    %edi,%edi
  80201d:	e9 2b ff ff ff       	jmp    801f4d <__udivdi3+0x41>
  802022:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802024:	31 f6                	xor    %esi,%esi
  802026:	e9 22 ff ff ff       	jmp    801f4d <__udivdi3+0x41>
	...

0080202c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80202c:	55                   	push   %ebp
  80202d:	57                   	push   %edi
  80202e:	56                   	push   %esi
  80202f:	83 ec 20             	sub    $0x20,%esp
  802032:	8b 44 24 30          	mov    0x30(%esp),%eax
  802036:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80203a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80203e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802042:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802046:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80204a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80204c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80204e:	85 ed                	test   %ebp,%ebp
  802050:	75 16                	jne    802068 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802052:	39 f1                	cmp    %esi,%ecx
  802054:	0f 86 a6 00 00 00    	jbe    802100 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80205a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80205c:	89 d0                	mov    %edx,%eax
  80205e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802060:	83 c4 20             	add    $0x20,%esp
  802063:	5e                   	pop    %esi
  802064:	5f                   	pop    %edi
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    
  802067:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802068:	39 f5                	cmp    %esi,%ebp
  80206a:	0f 87 ac 00 00 00    	ja     80211c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802070:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802073:	83 f0 1f             	xor    $0x1f,%eax
  802076:	89 44 24 10          	mov    %eax,0x10(%esp)
  80207a:	0f 84 a8 00 00 00    	je     802128 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802080:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802084:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802086:	bf 20 00 00 00       	mov    $0x20,%edi
  80208b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80208f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802093:	89 f9                	mov    %edi,%ecx
  802095:	d3 e8                	shr    %cl,%eax
  802097:	09 e8                	or     %ebp,%eax
  802099:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80209d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020a1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020a5:	d3 e0                	shl    %cl,%eax
  8020a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020ab:	89 f2                	mov    %esi,%edx
  8020ad:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8020af:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8020b9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020bd:	89 f9                	mov    %edi,%ecx
  8020bf:	d3 e8                	shr    %cl,%eax
  8020c1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8020c3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8020c5:	89 f2                	mov    %esi,%edx
  8020c7:	f7 74 24 18          	divl   0x18(%esp)
  8020cb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8020cd:	f7 64 24 0c          	mull   0xc(%esp)
  8020d1:	89 c5                	mov    %eax,%ebp
  8020d3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8020d5:	39 d6                	cmp    %edx,%esi
  8020d7:	72 67                	jb     802140 <__umoddi3+0x114>
  8020d9:	74 75                	je     802150 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8020db:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8020df:	29 e8                	sub    %ebp,%eax
  8020e1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8020e3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	89 f2                	mov    %esi,%edx
  8020eb:	89 f9                	mov    %edi,%ecx
  8020ed:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8020ef:	09 d0                	or     %edx,%eax
  8020f1:	89 f2                	mov    %esi,%edx
  8020f3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8020f7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8020f9:	83 c4 20             	add    $0x20,%esp
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802100:	85 c9                	test   %ecx,%ecx
  802102:	75 0b                	jne    80210f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802104:	b8 01 00 00 00       	mov    $0x1,%eax
  802109:	31 d2                	xor    %edx,%edx
  80210b:	f7 f1                	div    %ecx
  80210d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80210f:	89 f0                	mov    %esi,%eax
  802111:	31 d2                	xor    %edx,%edx
  802113:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802115:	89 f8                	mov    %edi,%eax
  802117:	e9 3e ff ff ff       	jmp    80205a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80211c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80211e:	83 c4 20             	add    $0x20,%esp
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    
  802125:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802128:	39 f5                	cmp    %esi,%ebp
  80212a:	72 04                	jb     802130 <__umoddi3+0x104>
  80212c:	39 f9                	cmp    %edi,%ecx
  80212e:	77 06                	ja     802136 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802130:	89 f2                	mov    %esi,%edx
  802132:	29 cf                	sub    %ecx,%edi
  802134:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802136:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802138:	83 c4 20             	add    $0x20,%esp
  80213b:	5e                   	pop    %esi
  80213c:	5f                   	pop    %edi
  80213d:	5d                   	pop    %ebp
  80213e:	c3                   	ret    
  80213f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802140:	89 d1                	mov    %edx,%ecx
  802142:	89 c5                	mov    %eax,%ebp
  802144:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802148:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80214c:	eb 8d                	jmp    8020db <__umoddi3+0xaf>
  80214e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802150:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802154:	72 ea                	jb     802140 <__umoddi3+0x114>
  802156:	89 f1                	mov    %esi,%ecx
  802158:	eb 81                	jmp    8020db <__umoddi3+0xaf>
