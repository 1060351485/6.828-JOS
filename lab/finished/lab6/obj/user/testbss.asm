
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  800041:	e8 0a 02 00 00       	call   800250 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 bb 11 80 	movl   $0x8011bb,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  800070:	e8 e3 00 00 00       	call   800158 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 60 11 80 	movl   $0x801160,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  8000ba:	e8 99 00 00 00       	call   800158 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 88 11 80 00 	movl   $0x801188,(%esp)
  8000ce:	e8 7d 01 00 00       	call   800250 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 e7 11 80 	movl   $0x8011e7,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 d8 11 80 00 	movl   $0x8011d8,(%esp)
  8000f4:	e8 5f 00 00 00       	call   800158 <_panic>
  8000f9:	00 00                	add    %al,(%eax)
	...

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010a:	e8 a0 0a 00 00       	call   800baf <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x30>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 07 00 00 00       	call   800144 <exit>
}
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80014a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800151:	e8 07 0a 00 00       	call   800b5d <sys_env_destroy>
}
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800160:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800163:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800169:	e8 41 0a 00 00       	call   800baf <sys_getenvid>
  80016e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800171:	89 54 24 10          	mov    %edx,0x10(%esp)
  800175:	8b 55 08             	mov    0x8(%ebp),%edx
  800178:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80017c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	c7 04 24 08 12 80 00 	movl   $0x801208,(%esp)
  80018b:	e8 c0 00 00 00       	call   800250 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800190:	89 74 24 04          	mov    %esi,0x4(%esp)
  800194:	8b 45 10             	mov    0x10(%ebp),%eax
  800197:	89 04 24             	mov    %eax,(%esp)
  80019a:	e8 50 00 00 00       	call   8001ef <vcprintf>
	cprintf("\n");
  80019f:	c7 04 24 d6 11 80 00 	movl   $0x8011d6,(%esp)
  8001a6:	e8 a5 00 00 00       	call   800250 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ab:	cc                   	int3   
  8001ac:	eb fd                	jmp    8001ab <_panic+0x53>
	...

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 14             	sub    $0x14,%esp
  8001b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ba:	8b 03                	mov    (%ebx),%eax
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c3:	40                   	inc    %eax
  8001c4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cb:	75 19                	jne    8001e6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001cd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d4:	00 
  8001d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d8:	89 04 24             	mov    %eax,(%esp)
  8001db:	e8 40 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  8001e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e6:	ff 43 04             	incl   0x4(%ebx)
}
  8001e9:	83 c4 14             	add    $0x14,%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ff:	00 00 00 
	b.cnt = 0;
  800202:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800209:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800213:	8b 45 08             	mov    0x8(%ebp),%eax
  800216:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	89 44 24 04          	mov    %eax,0x4(%esp)
  800224:	c7 04 24 b0 01 80 00 	movl   $0x8001b0,(%esp)
  80022b:	e8 82 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800230:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 d8 08 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  800248:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800256:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 87 ff ff ff       	call   8001ef <vcprintf>
	va_end(ap);

	return cnt;
}
  800268:	c9                   	leave  
  800269:	c3                   	ret    
	...

0080026c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800278:	89 d7                	mov    %edx,%edi
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800280:	8b 45 0c             	mov    0xc(%ebp),%eax
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800289:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	85 c0                	test   %eax,%eax
  80028e:	75 08                	jne    800298 <printnum+0x2c>
  800290:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800293:	39 45 10             	cmp    %eax,0x10(%ebp)
  800296:	77 57                	ja     8002ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800298:	89 74 24 10          	mov    %esi,0x10(%esp)
  80029c:	4b                   	dec    %ebx
  80029d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b7:	00 
  8002b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	e8 0e 0c 00 00       	call   800ed8 <__udivdi3>
  8002ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d2:	89 04 24             	mov    %eax,(%esp)
  8002d5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d9:	89 fa                	mov    %edi,%edx
  8002db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002de:	e8 89 ff ff ff       	call   80026c <printnum>
  8002e3:	eb 0f                	jmp    8002f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ef:	4b                   	dec    %ebx
  8002f0:	85 db                	test   %ebx,%ebx
  8002f2:	7f f1                	jg     8002e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030a:	00 
  80030b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800314:	89 44 24 04          	mov    %eax,0x4(%esp)
  800318:	e8 db 0c 00 00       	call   800ff8 <__umoddi3>
  80031d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800321:	0f be 80 2b 12 80 00 	movsbl 0x80122b(%eax),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032e:	83 c4 3c             	add    $0x3c,%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800339:	83 fa 01             	cmp    $0x1,%edx
  80033c:	7e 0e                	jle    80034c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	8d 4a 08             	lea    0x8(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 02                	mov    (%edx),%eax
  800347:	8b 52 04             	mov    0x4(%edx),%edx
  80034a:	eb 22                	jmp    80036e <getuint+0x38>
	else if (lflag)
  80034c:	85 d2                	test   %edx,%edx
  80034e:	74 10                	je     800360 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 0e                	jmp    80036e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800376:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	3b 50 04             	cmp    0x4(%eax),%edx
  80037e:	73 08                	jae    800388 <sprintputch+0x18>
		*b->buf++ = ch;
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 0a                	mov    %cl,(%edx)
  800385:	42                   	inc    %edx
  800386:	89 10                	mov    %edx,(%eax)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800390:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800397:	8b 45 10             	mov    0x10(%ebp),%eax
  80039a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	e8 02 00 00 00       	call   8003b2 <vprintfmt>
	va_end(ap);
}
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 4c             	sub    $0x4c,%esp
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003be:	8b 75 10             	mov    0x10(%ebp),%esi
  8003c1:	eb 12                	jmp    8003d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c3:	85 c0                	test   %eax,%eax
  8003c5:	0f 84 6b 03 00 00    	je     800736 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cf:	89 04 24             	mov    %eax,(%esp)
  8003d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d5:	0f b6 06             	movzbl (%esi),%eax
  8003d8:	46                   	inc    %esi
  8003d9:	83 f8 25             	cmp    $0x25,%eax
  8003dc:	75 e5                	jne    8003c3 <vprintfmt+0x11>
  8003de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	eb 26                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800403:	eb 1d                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800408:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80040c:	eb 14                	jmp    800422 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800411:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800418:	eb 08                	jmp    800422 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80041a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80041d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	0f b6 06             	movzbl (%esi),%eax
  800425:	8d 56 01             	lea    0x1(%esi),%edx
  800428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042b:	8a 16                	mov    (%esi),%dl
  80042d:	83 ea 23             	sub    $0x23,%edx
  800430:	80 fa 55             	cmp    $0x55,%dl
  800433:	0f 87 e1 02 00 00    	ja     80071a <vprintfmt+0x368>
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	ff 24 95 80 13 80 00 	jmp    *0x801380(,%edx,4)
  800443:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800446:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80044b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800452:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800455:	8d 50 d0             	lea    -0x30(%eax),%edx
  800458:	83 fa 09             	cmp    $0x9,%edx
  80045b:	77 2a                	ja     800487 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045e:	eb eb                	jmp    80044b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046e:	eb 17                	jmp    800487 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	78 98                	js     80040e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800479:	eb a7                	jmp    800422 <vprintfmt+0x70>
  80047b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800485:	eb 9b                	jmp    800422 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800487:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80048b:	79 95                	jns    800422 <vprintfmt+0x70>
  80048d:	eb 8b                	jmp    80041a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800493:	eb 8d                	jmp    800422 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 50 04             	lea    0x4(%eax),%edx
  80049b:	89 55 14             	mov    %edx,0x14(%ebp)
  80049e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a2:	8b 00                	mov    (%eax),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ad:	e9 23 ff ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	79 02                	jns    8004c3 <vprintfmt+0x111>
  8004c1:	f7 d8                	neg    %eax
  8004c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c5:	83 f8 11             	cmp    $0x11,%eax
  8004c8:	7f 0b                	jg     8004d5 <vprintfmt+0x123>
  8004ca:	8b 04 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%eax
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	75 23                	jne    8004f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d9:	c7 44 24 08 43 12 80 	movl   $0x801243,0x8(%esp)
  8004e0:	00 
  8004e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 9a fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f3:	e9 dd fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fc:	c7 44 24 08 4c 12 80 	movl   $0x80124c,0x8(%esp)
  800503:	00 
  800504:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800508:	8b 55 08             	mov    0x8(%ebp),%edx
  80050b:	89 14 24             	mov    %edx,(%esp)
  80050e:	e8 77 fe ff ff       	call   80038a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800516:	e9 ba fe ff ff       	jmp    8003d5 <vprintfmt+0x23>
  80051b:	89 f9                	mov    %edi,%ecx
  80051d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800520:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 30                	mov    (%eax),%esi
  80052e:	85 f6                	test   %esi,%esi
  800530:	75 05                	jne    800537 <vprintfmt+0x185>
				p = "(null)";
  800532:	be 3c 12 80 00       	mov    $0x80123c,%esi
			if (width > 0 && padc != '-')
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	0f 8e 84 00 00 00    	jle    8005c5 <vprintfmt+0x213>
  800541:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800545:	74 7e                	je     8005c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054b:	89 34 24             	mov    %esi,(%esp)
  80054e:	e8 8b 02 00 00       	call   8007de <strnlen>
  800553:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800556:	29 c2                	sub    %eax,%edx
  800558:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80055b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800562:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800565:	89 de                	mov    %ebx,%esi
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056b:	eb 0b                	jmp    800578 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80056d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800571:	89 3c 24             	mov    %edi,(%esp)
  800574:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f f1                	jg     80056d <vprintfmt+0x1bb>
  80057c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057f:	89 f3                	mov    %esi,%ebx
  800581:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800584:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800587:	85 c0                	test   %eax,%eax
  800589:	79 05                	jns    800590 <vprintfmt+0x1de>
  80058b:	b8 00 00 00 00       	mov    $0x0,%eax
  800590:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800593:	29 c2                	sub    %eax,%edx
  800595:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800598:	eb 2b                	jmp    8005c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059e:	74 18                	je     8005b8 <vprintfmt+0x206>
  8005a0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005a3:	83 fa 5e             	cmp    $0x5e,%edx
  8005a6:	76 10                	jbe    8005b8 <vprintfmt+0x206>
					putch('?', putdat);
  8005a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	eb 0a                	jmp    8005c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bc:	89 04 24             	mov    %eax,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c5:	0f be 06             	movsbl (%esi),%eax
  8005c8:	46                   	inc    %esi
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	74 21                	je     8005ee <vprintfmt+0x23c>
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	78 c9                	js     80059a <vprintfmt+0x1e8>
  8005d1:	4f                   	dec    %edi
  8005d2:	79 c6                	jns    80059a <vprintfmt+0x1e8>
  8005d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d7:	89 de                	mov    %ebx,%esi
  8005d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005dc:	eb 18                	jmp    8005f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	4b                   	dec    %ebx
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x244>
  8005ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005f1:	89 de                	mov    %ebx,%esi
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f6:	85 db                	test   %ebx,%ebx
  8005f8:	7f e4                	jg     8005de <vprintfmt+0x22c>
  8005fa:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800602:	e9 ce fd ff ff       	jmp    8003d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800607:	83 f9 01             	cmp    $0x1,%ecx
  80060a:	7e 10                	jle    80061c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 08             	lea    0x8(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 30                	mov    (%eax),%esi
  800617:	8b 78 04             	mov    0x4(%eax),%edi
  80061a:	eb 26                	jmp    800642 <vprintfmt+0x290>
	else if (lflag)
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	74 12                	je     800632 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 30                	mov    (%eax),%esi
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	c1 ff 1f             	sar    $0x1f,%edi
  800630:	eb 10                	jmp    800642 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 04             	lea    0x4(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 30                	mov    (%eax),%esi
  80063d:	89 f7                	mov    %esi,%edi
  80063f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	85 ff                	test   %edi,%edi
  800644:	78 0a                	js     800650 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 8c 00 00 00       	jmp    8006dc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065e:	f7 de                	neg    %esi
  800660:	83 d7 00             	adc    $0x0,%edi
  800663:	f7 df                	neg    %edi
			}
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	eb 70                	jmp    8006dc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	89 ca                	mov    %ecx,%edx
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 c0 fc ff ff       	call   800336 <getuint>
  800676:	89 c6                	mov    %eax,%esi
  800678:	89 d7                	mov    %edx,%edi
			base = 10;
  80067a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067f:	eb 5b                	jmp    8006dc <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 ab fc ff ff       	call   800336 <getuint>
  80068b:	89 c6                	mov    %eax,%esi
  80068d:	89 d7                	mov    %edx,%edi
			base = 8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800694:	eb 46                	jmp    8006dc <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006af:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 30                	mov    (%eax),%esi
  8006bd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c7:	eb 13                	jmp    8006dc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 63 fc ff ff       	call   800336 <getuint>
  8006d3:	89 c6                	mov    %eax,%esi
  8006d5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006e0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ef:	89 34 24             	mov    %esi,(%esp)
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	89 da                	mov    %ebx,%edx
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	e8 6c fb ff ff       	call   80026c <printnum>
			break;
  800700:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800703:	e9 cd fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800715:	e9 bb fc ff ff       	jmp    8003d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800725:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	eb 01                	jmp    80072b <vprintfmt+0x379>
  80072a:	4e                   	dec    %esi
  80072b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072f:	75 f9                	jne    80072a <vprintfmt+0x378>
  800731:	e9 9f fc ff ff       	jmp    8003d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800736:	83 c4 4c             	add    $0x4c,%esp
  800739:	5b                   	pop    %ebx
  80073a:	5e                   	pop    %esi
  80073b:	5f                   	pop    %edi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 28             	sub    $0x28,%esp
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800751:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800754:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075b:	85 c0                	test   %eax,%eax
  80075d:	74 30                	je     80078f <vsnprintf+0x51>
  80075f:	85 d2                	test   %edx,%edx
  800761:	7e 33                	jle    800796 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	c7 04 24 70 03 80 00 	movl   $0x800370,(%esp)
  80077f:	e8 2e fc ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800784:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800787:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	eb 0c                	jmp    80079b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800794:	eb 05                	jmp    80079b <vsnprintf+0x5d>
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	e8 7b ff ff ff       	call   80073e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    
  8007c5:	00 00                	add    %al,(%eax)
	...

008007c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d3:	eb 01                	jmp    8007d6 <strlen+0xe>
		n++;
  8007d5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f9                	jne    8007d5 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 01                	jmp    8007ef <strnlen+0x11>
		n++;
  8007ee:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 d0                	cmp    %edx,%eax
  8007f1:	74 06                	je     8007f9 <strnlen+0x1b>
  8007f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f7:	75 f5                	jne    8007ee <strnlen+0x10>
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	ba 00 00 00 00       	mov    $0x0,%edx
  80080a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80080d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800810:	42                   	inc    %edx
  800811:	84 c9                	test   %cl,%cl
  800813:	75 f5                	jne    80080a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	89 1c 24             	mov    %ebx,(%esp)
  800825:	e8 9e ff ff ff       	call   8007c8 <strlen>
	strcpy(dst + len, src);
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800831:	01 d8                	add    %ebx,%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 c0 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  80083b:	89 d8                	mov    %ebx,%eax
  80083d:	83 c4 08             	add    $0x8,%esp
  800840:	5b                   	pop    %ebx
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	56                   	push   %esi
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	eb 0c                	jmp    800864 <strncpy+0x21>
		*dst++ = *src;
  800858:	8a 1a                	mov    (%edx),%bl
  80085a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085d:	80 3a 01             	cmpb   $0x1,(%edx)
  800860:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	41                   	inc    %ecx
  800864:	39 f1                	cmp    %esi,%ecx
  800866:	75 f0                	jne    800858 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	75 0a                	jne    800888 <strlcpy+0x1c>
  80087e:	89 f0                	mov    %esi,%eax
  800880:	eb 1a                	jmp    80089c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800882:	88 18                	mov    %bl,(%eax)
  800884:	40                   	inc    %eax
  800885:	41                   	inc    %ecx
  800886:	eb 02                	jmp    80088a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800888:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80088a:	4a                   	dec    %edx
  80088b:	74 0a                	je     800897 <strlcpy+0x2b>
  80088d:	8a 19                	mov    (%ecx),%bl
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ef                	jne    800882 <strlcpy+0x16>
  800893:	89 c2                	mov    %eax,%edx
  800895:	eb 02                	jmp    800899 <strlcpy+0x2d>
  800897:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 02                	jmp    8008af <strcmp+0xd>
		p++, q++;
  8008ad:	41                   	inc    %ecx
  8008ae:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	8a 01                	mov    (%ecx),%al
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x17>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 f4                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d0:	eb 03                	jmp    8008d5 <strncmp+0x12>
		n--, p++, q++;
  8008d2:	4a                   	dec    %edx
  8008d3:	40                   	inc    %eax
  8008d4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 14                	je     8008ed <strncmp+0x2a>
  8008d9:	8a 18                	mov    (%eax),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	74 04                	je     8008e3 <strncmp+0x20>
  8008df:	3a 19                	cmp    (%ecx),%bl
  8008e1:	74 ef                	je     8008d2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e3:	0f b6 00             	movzbl (%eax),%eax
  8008e6:	0f b6 11             	movzbl (%ecx),%edx
  8008e9:	29 d0                	sub    %edx,%eax
  8008eb:	eb 05                	jmp    8008f2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fe:	eb 05                	jmp    800905 <strchr+0x10>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0c                	je     800910 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800904:	40                   	inc    %eax
  800905:	8a 10                	mov    (%eax),%dl
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f5                	jne    800900 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091b:	eb 05                	jmp    800922 <strfind+0x10>
		if (*s == c)
  80091d:	38 ca                	cmp    %cl,%dl
  80091f:	74 07                	je     800928 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800921:	40                   	inc    %eax
  800922:	8a 10                	mov    (%eax),%dl
  800924:	84 d2                	test   %dl,%dl
  800926:	75 f5                	jne    80091d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 7d 08             	mov    0x8(%ebp),%edi
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800939:	85 c9                	test   %ecx,%ecx
  80093b:	74 30                	je     80096d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800943:	75 25                	jne    80096a <memset+0x40>
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 20                	jne    80096a <memset+0x40>
		c &= 0xFF;
  80094a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	c1 e6 18             	shl    $0x18,%esi
  800957:	89 d0                	mov    %edx,%eax
  800959:	c1 e0 10             	shl    $0x10,%eax
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 d0                	or     %edx,%eax
  800960:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800965:	fc                   	cld    
  800966:	f3 ab                	rep stos %eax,%es:(%edi)
  800968:	eb 03                	jmp    80096d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096a:	fc                   	cld    
  80096b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	57                   	push   %edi
  800978:	56                   	push   %esi
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800982:	39 c6                	cmp    %eax,%esi
  800984:	73 34                	jae    8009ba <memmove+0x46>
  800986:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800989:	39 d0                	cmp    %edx,%eax
  80098b:	73 2d                	jae    8009ba <memmove+0x46>
		s += n;
		d += n;
  80098d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 1b                	jne    8009b0 <memmove+0x3c>
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 13                	jne    8009b0 <memmove+0x3c>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 0e                	jne    8009b0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb 07                	jmp    8009b7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b0:	4f                   	dec    %edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 20                	jmp    8009da <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c0:	75 13                	jne    8009d5 <memmove+0x61>
  8009c2:	a8 03                	test   $0x3,%al
  8009c4:	75 0f                	jne    8009d5 <memmove+0x61>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	e8 77 ff ff ff       	call   800974 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a13:	eb 16                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a15:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a18:	42                   	inc    %edx
  800a19:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a1d:	38 c8                	cmp    %cl,%al
  800a1f:	74 0a                	je     800a2b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 c9             	movzbl %cl,%ecx
  800a27:	29 c8                	sub    %ecx,%eax
  800a29:	eb 09                	jmp    800a34 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 da                	cmp    %ebx,%edx
  800a2d:	75 e6                	jne    800a15 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a42:	89 c2                	mov    %eax,%edx
  800a44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a47:	eb 05                	jmp    800a4e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a49:	38 08                	cmp    %cl,(%eax)
  800a4b:	74 05                	je     800a52 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4d:	40                   	inc    %eax
  800a4e:	39 d0                	cmp    %edx,%eax
  800a50:	72 f7                	jb     800a49 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 01                	jmp    800a63 <strtol+0xf>
		s++;
  800a62:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	8a 02                	mov    (%edx),%al
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f9                	je     800a62 <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f5                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	75 08                	jne    800a79 <strtol+0x25>
		s++;
  800a71:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a72:	bf 00 00 00 00       	mov    $0x0,%edi
  800a77:	eb 13                	jmp    800a8c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	75 0a                	jne    800a87 <strtol+0x33>
		s++, neg = 1;
  800a7d:	8d 52 01             	lea    0x1(%edx),%edx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb 05                	jmp    800a8c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 05                	je     800a95 <strtol+0x41>
  800a90:	83 fb 10             	cmp    $0x10,%ebx
  800a93:	75 28                	jne    800abd <strtol+0x69>
  800a95:	8a 02                	mov    (%edx),%al
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 10                	jne    800aab <strtol+0x57>
  800a9b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9f:	75 0a                	jne    800aab <strtol+0x57>
		s += 2, base = 16;
  800aa1:	83 c2 02             	add    $0x2,%edx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 12                	jmp    800abd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 0e                	jne    800abd <strtol+0x69>
  800aaf:	3c 30                	cmp    $0x30,%al
  800ab1:	75 05                	jne    800ab8 <strtol+0x64>
		s++, base = 8;
  800ab3:	42                   	inc    %edx
  800ab4:	b3 08                	mov    $0x8,%bl
  800ab6:	eb 05                	jmp    800abd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800abd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac4:	8a 0a                	mov    (%edx),%cl
  800ac6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac9:	80 fb 09             	cmp    $0x9,%bl
  800acc:	77 08                	ja     800ad6 <strtol+0x82>
			dig = *s - '0';
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 30             	sub    $0x30,%ecx
  800ad4:	eb 1e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ade:	0f be c9             	movsbl %cl,%ecx
  800ae1:	83 e9 57             	sub    $0x57,%ecx
  800ae4:	eb 0e                	jmp    800af4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 12                	ja     800b00 <strtol+0xac>
			dig = *s - 'A' + 10;
  800aee:	0f be c9             	movsbl %cl,%ecx
  800af1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af4:	39 f1                	cmp    %esi,%ecx
  800af6:	7d 0c                	jge    800b04 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af8:	42                   	inc    %edx
  800af9:	0f af c6             	imul   %esi,%eax
  800afc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afe:	eb c4                	jmp    800ac4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	89 c1                	mov    %eax,%ecx
  800b02:	eb 02                	jmp    800b06 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b04:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 05                	je     800b11 <strtol+0xbd>
		*endptr = (char *) s;
  800b0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b11:	85 ff                	test   %edi,%edi
  800b13:	74 04                	je     800b19 <strtol+0xc5>
  800b15:	89 c8                	mov    %ecx,%eax
  800b17:	f7 d8                	neg    %eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
	...

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
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
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	89 cb                	mov    %ecx,%ebx
  800b75:	89 cf                	mov    %ecx,%edi
  800b77:	89 ce                	mov    %ecx,%esi
  800b79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 28                	jle    800ba7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b83:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b8a:	00 
  800b8b:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800b92:	00 
  800b93:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b9a:	00 
  800b9b:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800ba2:	e8 b1 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba7:	83 c4 2c             	add    $0x2c,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	be 00 00 00 00       	mov    $0x0,%esi
  800bfb:	b8 04 00 00 00       	mov    $0x4,%eax
  800c00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 f7                	mov    %esi,%edi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 28                	jle    800c39 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800c24:	00 
  800c25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c2c:	00 
  800c2d:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800c34:	e8 1f f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	83 c4 2c             	add    $0x2c,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 28                	jle    800c8c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c68:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c6f:	00 
  800c70:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800c77:	00 
  800c78:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c7f:	00 
  800c80:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800c87:	e8 cc f4 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8c:	83 c4 2c             	add    $0x2c,%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 df                	mov    %ebx,%edi
  800caf:	89 de                	mov    %ebx,%esi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 28                	jle    800cdf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cc2:	00 
  800cc3:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800cca:	00 
  800ccb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd2:	00 
  800cd3:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800cda:	e8 79 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdf:	83 c4 2c             	add    $0x2c,%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7e 28                	jle    800d32 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d0e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d15:	00 
  800d16:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800d1d:	00 
  800d1e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d25:	00 
  800d26:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800d2d:	e8 26 f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d32:	83 c4 2c             	add    $0x2c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d48:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 df                	mov    %ebx,%edi
  800d55:	89 de                	mov    %ebx,%esi
  800d57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	7e 28                	jle    800d85 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d61:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d68:	00 
  800d69:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800d70:	00 
  800d71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d78:	00 
  800d79:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800d80:	e8 d3 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d85:	83 c4 2c             	add    $0x2c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    

00800d8d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7e 28                	jle    800dd8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800dc3:	00 
  800dc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dcb:	00 
  800dcc:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800dd3:	e8 80 f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd8:	83 c4 2c             	add    $0x2c,%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	be 00 00 00 00       	mov    $0x0,%esi
  800deb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e11:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	89 cb                	mov    %ecx,%ebx
  800e1b:	89 cf                	mov    %ecx,%edi
  800e1d:	89 ce                	mov    %ecx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 28                	jle    800e4d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e29:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e30:	00 
  800e31:	c7 44 24 08 48 15 80 	movl   $0x801548,0x8(%esp)
  800e38:	00 
  800e39:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e40:	00 
  800e41:	c7 04 24 65 15 80 00 	movl   $0x801565,(%esp)
  800e48:	e8 0b f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4d:	83 c4 2c             	add    $0x2c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 d3                	mov    %edx,%ebx
  800e69:	89 d7                	mov    %edx,%edi
  800e6b:	89 d6                	mov    %edx,%esi
  800e6d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	57                   	push   %edi
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7f:	b8 10 00 00 00       	mov    $0x10,%eax
  800e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	89 df                	mov    %ebx,%edi
  800e8c:	89 de                	mov    %ebx,%esi
  800e8e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	57                   	push   %edi
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	89 df                	mov    %ebx,%edi
  800ead:	89 de                	mov    %ebx,%esi
  800eaf:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec1:	b8 11 00 00 00       	mov    $0x11,%eax
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	89 cb                	mov    %ecx,%ebx
  800ecb:	89 cf                	mov    %ecx,%edi
  800ecd:	89 ce                	mov    %ecx,%esi
  800ecf:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    
	...

00800ed8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800ed8:	55                   	push   %ebp
  800ed9:	57                   	push   %edi
  800eda:	56                   	push   %esi
  800edb:	83 ec 10             	sub    $0x10,%esp
  800ede:	8b 74 24 20          	mov    0x20(%esp),%esi
  800ee2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800eee:	89 cd                	mov    %ecx,%ebp
  800ef0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	75 2c                	jne    800f24 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800ef8:	39 f9                	cmp    %edi,%ecx
  800efa:	77 68                	ja     800f64 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800efc:	85 c9                	test   %ecx,%ecx
  800efe:	75 0b                	jne    800f0b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f00:	b8 01 00 00 00       	mov    $0x1,%eax
  800f05:	31 d2                	xor    %edx,%edx
  800f07:	f7 f1                	div    %ecx
  800f09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	89 f8                	mov    %edi,%eax
  800f0f:	f7 f1                	div    %ecx
  800f11:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	f7 f1                	div    %ecx
  800f17:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f24:	39 f8                	cmp    %edi,%eax
  800f26:	77 2c                	ja     800f54 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800f28:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800f2b:	83 f6 1f             	xor    $0x1f,%esi
  800f2e:	75 4c                	jne    800f7c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f30:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f32:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f37:	72 0a                	jb     800f43 <__udivdi3+0x6b>
  800f39:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f3d:	0f 87 ad 00 00 00    	ja     800ff0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f43:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f48:	89 f0                	mov    %esi,%eax
  800f4a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
  800f53:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800f54:	31 ff                	xor    %edi,%edi
  800f56:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f58:	89 f0                	mov    %esi,%eax
  800f5a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f64:	89 fa                	mov    %edi,%edx
  800f66:	89 f0                	mov    %esi,%eax
  800f68:	f7 f1                	div    %ecx
  800f6a:	89 c6                	mov    %eax,%esi
  800f6c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800f7c:	89 f1                	mov    %esi,%ecx
  800f7e:	d3 e0                	shl    %cl,%eax
  800f80:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800f84:	b8 20 00 00 00       	mov    $0x20,%eax
  800f89:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800f8b:	89 ea                	mov    %ebp,%edx
  800f8d:	88 c1                	mov    %al,%cl
  800f8f:	d3 ea                	shr    %cl,%edx
  800f91:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f95:	09 ca                	or     %ecx,%edx
  800f97:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800f9b:	89 f1                	mov    %esi,%ecx
  800f9d:	d3 e5                	shl    %cl,%ebp
  800f9f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800fa3:	89 fd                	mov    %edi,%ebp
  800fa5:	88 c1                	mov    %al,%cl
  800fa7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800fa9:	89 fa                	mov    %edi,%edx
  800fab:	89 f1                	mov    %esi,%ecx
  800fad:	d3 e2                	shl    %cl,%edx
  800faf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fb3:	88 c1                	mov    %al,%cl
  800fb5:	d3 ef                	shr    %cl,%edi
  800fb7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	89 ea                	mov    %ebp,%edx
  800fbd:	f7 74 24 08          	divl   0x8(%esp)
  800fc1:	89 d1                	mov    %edx,%ecx
  800fc3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800fc5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fc9:	39 d1                	cmp    %edx,%ecx
  800fcb:	72 17                	jb     800fe4 <__udivdi3+0x10c>
  800fcd:	74 09                	je     800fd8 <__udivdi3+0x100>
  800fcf:	89 fe                	mov    %edi,%esi
  800fd1:	31 ff                	xor    %edi,%edi
  800fd3:	e9 41 ff ff ff       	jmp    800f19 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800fd8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fdc:	89 f1                	mov    %esi,%ecx
  800fde:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fe0:	39 c2                	cmp    %eax,%edx
  800fe2:	73 eb                	jae    800fcf <__udivdi3+0xf7>
		{
		  q0--;
  800fe4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800fe7:	31 ff                	xor    %edi,%edi
  800fe9:	e9 2b ff ff ff       	jmp    800f19 <__udivdi3+0x41>
  800fee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800ff0:	31 f6                	xor    %esi,%esi
  800ff2:	e9 22 ff ff ff       	jmp    800f19 <__udivdi3+0x41>
	...

00800ff8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800ff8:	55                   	push   %ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	83 ec 20             	sub    $0x20,%esp
  800ffe:	8b 44 24 30          	mov    0x30(%esp),%eax
  801002:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801006:	89 44 24 14          	mov    %eax,0x14(%esp)
  80100a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80100e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801012:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801016:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801018:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80101a:	85 ed                	test   %ebp,%ebp
  80101c:	75 16                	jne    801034 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80101e:	39 f1                	cmp    %esi,%ecx
  801020:	0f 86 a6 00 00 00    	jbe    8010cc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801026:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801028:	89 d0                	mov    %edx,%eax
  80102a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    
  801033:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801034:	39 f5                	cmp    %esi,%ebp
  801036:	0f 87 ac 00 00 00    	ja     8010e8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80103c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80103f:	83 f0 1f             	xor    $0x1f,%eax
  801042:	89 44 24 10          	mov    %eax,0x10(%esp)
  801046:	0f 84 a8 00 00 00    	je     8010f4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80104c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801050:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801052:	bf 20 00 00 00       	mov    $0x20,%edi
  801057:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80105b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80105f:	89 f9                	mov    %edi,%ecx
  801061:	d3 e8                	shr    %cl,%eax
  801063:	09 e8                	or     %ebp,%eax
  801065:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801069:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80106d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801071:	d3 e0                	shl    %cl,%eax
  801073:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801077:	89 f2                	mov    %esi,%edx
  801079:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80107b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80107f:	d3 e0                	shl    %cl,%eax
  801081:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801085:	8b 44 24 14          	mov    0x14(%esp),%eax
  801089:	89 f9                	mov    %edi,%ecx
  80108b:	d3 e8                	shr    %cl,%eax
  80108d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80108f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801091:	89 f2                	mov    %esi,%edx
  801093:	f7 74 24 18          	divl   0x18(%esp)
  801097:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801099:	f7 64 24 0c          	mull   0xc(%esp)
  80109d:	89 c5                	mov    %eax,%ebp
  80109f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	72 67                	jb     80110c <__umoddi3+0x114>
  8010a5:	74 75                	je     80111c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8010a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010ab:	29 e8                	sub    %ebp,%eax
  8010ad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8010af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010b3:	d3 e8                	shr    %cl,%eax
  8010b5:	89 f2                	mov    %esi,%edx
  8010b7:	89 f9                	mov    %edi,%ecx
  8010b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8010bb:	09 d0                	or     %edx,%eax
  8010bd:	89 f2                	mov    %esi,%edx
  8010bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010c3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010c5:	83 c4 20             	add    $0x20,%esp
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8010cc:	85 c9                	test   %ecx,%ecx
  8010ce:	75 0b                	jne    8010db <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8010d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d5:	31 d2                	xor    %edx,%edx
  8010d7:	f7 f1                	div    %ecx
  8010d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8010db:	89 f0                	mov    %esi,%eax
  8010dd:	31 d2                	xor    %edx,%edx
  8010df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8010e1:	89 f8                	mov    %edi,%eax
  8010e3:	e9 3e ff ff ff       	jmp    801026 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8010e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8010ea:	83 c4 20             	add    $0x20,%esp
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    
  8010f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8010f4:	39 f5                	cmp    %esi,%ebp
  8010f6:	72 04                	jb     8010fc <__umoddi3+0x104>
  8010f8:	39 f9                	cmp    %edi,%ecx
  8010fa:	77 06                	ja     801102 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8010fc:	89 f2                	mov    %esi,%edx
  8010fe:	29 cf                	sub    %ecx,%edi
  801100:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801102:	89 f8                	mov    %edi,%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80110c:	89 d1                	mov    %edx,%ecx
  80110e:	89 c5                	mov    %eax,%ebp
  801110:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801114:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801118:	eb 8d                	jmp    8010a7 <__umoddi3+0xaf>
  80111a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80111c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801120:	72 ea                	jb     80110c <__umoddi3+0x114>
  801122:	89 f1                	mov    %esi,%ecx
  801124:	eb 81                	jmp    8010a7 <__umoddi3+0xaf>
