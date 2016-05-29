
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 cc 12 00 00       	call   801324 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 20 17 80 00 	movl   $0x801720,(%esp)
  800071:	e8 26 02 00 00       	call   80029c <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 b8 0f 00 00       	call   801033 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 2c 17 80 	movl   $0x80172c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 35 17 80 00 	movl   $0x801735,(%esp)
  80009c:	e8 03 01 00 00       	call   8001a4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 64 12 00 00       	call   801324 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	99                   	cltd   
  8000c3:	f7 fb                	idiv   %ebx
  8000c5:	85 d2                	test   %edx,%edx
  8000c7:	74 df                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000d8:	00 
  8000d9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000dd:	89 3c 24             	mov    %edi,(%esp)
  8000e0:	e8 a8 12 00 00       	call   80138d <ipc_send>
  8000e5:	eb c1                	jmp    8000a8 <primeproc+0x74>

008000e7 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ef:	e8 3f 0f 00 00       	call   801033 <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 2c 17 80 	movl   $0x80172c,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 35 17 80 00 	movl   $0x801735,(%esp)
  800115:	e8 8a 00 00 00       	call   8001a4 <_panic>
	if (id == 0)
  80011a:	bb 02 00 00 00       	mov    $0x2,%ebx
  80011f:	85 c0                	test   %eax,%eax
  800121:	75 05                	jne    800128 <umain+0x41>
		primeproc();
  800123:	e8 0c ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  800128:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012f:	00 
  800130:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800137:	00 
  800138:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013c:	89 34 24             	mov    %esi,(%esp)
  80013f:	e8 49 12 00 00       	call   80138d <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800144:	43                   	inc    %ebx
  800145:	eb e1                	jmp    800128 <umain+0x41>
	...

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 75 08             	mov    0x8(%ebp),%esi
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 a0 0a 00 00       	call   800bfb <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	c1 e0 07             	shl    $0x7,%eax
  800163:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800168:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80016d:	85 f6                	test   %esi,%esi
  80016f:	7e 07                	jle    800178 <libmain+0x30>
		binaryname = argv[0];
  800171:	8b 03                	mov    (%ebx),%eax
  800173:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800178:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017c:	89 34 24             	mov    %esi,(%esp)
  80017f:	e8 63 ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  800184:	e8 07 00 00 00       	call   800190 <exit>
}
  800189:	83 c4 10             	add    $0x10,%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800196:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019d:	e8 07 0a 00 00       	call   800ba9 <sys_env_destroy>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001ac:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001af:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001b5:	e8 41 0a 00 00       	call   800bfb <sys_getenvid>
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d0:	c7 04 24 50 17 80 00 	movl   $0x801750,(%esp)
  8001d7:	e8 c0 00 00 00       	call   80029c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e3:	89 04 24             	mov    %eax,(%esp)
  8001e6:	e8 50 00 00 00       	call   80023b <vcprintf>
	cprintf("\n");
  8001eb:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  8001f2:	e8 a5 00 00 00       	call   80029c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f7:	cc                   	int3   
  8001f8:	eb fd                	jmp    8001f7 <_panic+0x53>
	...

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 14             	sub    $0x14,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 03                	mov    (%ebx),%eax
  800208:	8b 55 08             	mov    0x8(%ebp),%edx
  80020b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80020f:	40                   	inc    %eax
  800210:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800212:	3d ff 00 00 00       	cmp    $0xff,%eax
  800217:	75 19                	jne    800232 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800219:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800220:	00 
  800221:	8d 43 08             	lea    0x8(%ebx),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	e8 40 09 00 00       	call   800b6c <sys_cputs>
		b->idx = 0;
  80022c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800232:	ff 43 04             	incl   0x4(%ebx)
}
  800235:	83 c4 14             	add    $0x14,%esp
  800238:	5b                   	pop    %ebx
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	89 44 24 08          	mov    %eax,0x8(%esp)
  800266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	c7 04 24 fc 01 80 00 	movl   $0x8001fc,(%esp)
  800277:	e8 82 01 00 00       	call   8003fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800282:	89 44 24 04          	mov    %eax,0x4(%esp)
  800286:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	e8 d8 08 00 00       	call   800b6c <sys_cputs>

	return b.cnt;
}
  800294:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029a:	c9                   	leave  
  80029b:	c3                   	ret    

0080029c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	89 04 24             	mov    %eax,(%esp)
  8002af:	e8 87 ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    
	...

008002b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 3c             	sub    $0x3c,%esp
  8002c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c4:	89 d7                	mov    %edx,%edi
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	75 08                	jne    8002e4 <printnum+0x2c>
  8002dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e2:	77 57                	ja     80033b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002e8:	4b                   	dec    %ebx
  8002e9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002f8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800303:	00 
  800304:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800311:	e8 b6 11 00 00       	call   8014cc <__udivdi3>
  800316:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80031a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	89 54 24 04          	mov    %edx,0x4(%esp)
  800325:	89 fa                	mov    %edi,%edx
  800327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032a:	e8 89 ff ff ff       	call   8002b8 <printnum>
  80032f:	eb 0f                	jmp    800340 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	89 34 24             	mov    %esi,(%esp)
  800338:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033b:	4b                   	dec    %ebx
  80033c:	85 db                	test   %ebx,%ebx
  80033e:	7f f1                	jg     800331 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800340:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800344:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800348:	8b 45 10             	mov    0x10(%ebp),%eax
  80034b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800356:	00 
  800357:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	e8 83 12 00 00       	call   8015ec <__umoddi3>
  800369:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80036d:	0f be 80 73 17 80 00 	movsbl 0x801773(%eax),%eax
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80037a:	83 c4 3c             	add    $0x3c,%esp
  80037d:	5b                   	pop    %ebx
  80037e:	5e                   	pop    %esi
  80037f:	5f                   	pop    %edi
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800385:	83 fa 01             	cmp    $0x1,%edx
  800388:	7e 0e                	jle    800398 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 02                	mov    (%edx),%eax
  800393:	8b 52 04             	mov    0x4(%edx),%edx
  800396:	eb 22                	jmp    8003ba <getuint+0x38>
	else if (lflag)
  800398:	85 d2                	test   %edx,%edx
  80039a:	74 10                	je     8003ac <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039c:	8b 10                	mov    (%eax),%edx
  80039e:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a1:	89 08                	mov    %ecx,(%eax)
  8003a3:	8b 02                	mov    (%edx),%eax
  8003a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003aa:	eb 0e                	jmp    8003ba <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b1:	89 08                	mov    %ecx,(%eax)
  8003b3:	8b 02                	mov    (%edx),%eax
  8003b5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 08                	jae    8003d4 <sprintputch+0x18>
		*b->buf++ = ch;
  8003cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003cf:	88 0a                	mov    %cl,(%edx)
  8003d1:	42                   	inc    %edx
  8003d2:	89 10                	mov    %edx,(%eax)
}
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 02 00 00 00       	call   8003fe <vprintfmt>
	va_end(ap);
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 4c             	sub    $0x4c,%esp
  800407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040a:	8b 75 10             	mov    0x10(%ebp),%esi
  80040d:	eb 12                	jmp    800421 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80040f:	85 c0                	test   %eax,%eax
  800411:	0f 84 6b 03 00 00    	je     800782 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800417:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800421:	0f b6 06             	movzbl (%esi),%eax
  800424:	46                   	inc    %esi
  800425:	83 f8 25             	cmp    $0x25,%eax
  800428:	75 e5                	jne    80040f <vprintfmt+0x11>
  80042a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80042e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800435:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80043a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800441:	b9 00 00 00 00       	mov    $0x0,%ecx
  800446:	eb 26                	jmp    80046e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80044f:	eb 1d                	jmp    80046e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800454:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800458:	eb 14                	jmp    80046e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80045d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800464:	eb 08                	jmp    80046e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800466:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800469:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	0f b6 06             	movzbl (%esi),%eax
  800471:	8d 56 01             	lea    0x1(%esi),%edx
  800474:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800477:	8a 16                	mov    (%esi),%dl
  800479:	83 ea 23             	sub    $0x23,%edx
  80047c:	80 fa 55             	cmp    $0x55,%dl
  80047f:	0f 87 e1 02 00 00    	ja     800766 <vprintfmt+0x368>
  800485:	0f b6 d2             	movzbl %dl,%edx
  800488:	ff 24 95 c0 18 80 00 	jmp    *0x8018c0(,%edx,4)
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800492:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800497:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80049a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80049e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004a1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004a4:	83 fa 09             	cmp    $0x9,%edx
  8004a7:	77 2a                	ja     8004d3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004aa:	eb eb                	jmp    800497 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ba:	eb 17                	jmp    8004d3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c0:	78 98                	js     80045a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004c5:	eb a7                	jmp    80046e <vprintfmt+0x70>
  8004c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004ca:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004d1:	eb 9b                	jmp    80046e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d7:	79 95                	jns    80046e <vprintfmt+0x70>
  8004d9:	eb 8b                	jmp    800466 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004db:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004df:	eb 8d                	jmp    80046e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004f9:	e9 23 ff ff ff       	jmp    800421 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 50 04             	lea    0x4(%eax),%edx
  800504:	89 55 14             	mov    %edx,0x14(%ebp)
  800507:	8b 00                	mov    (%eax),%eax
  800509:	85 c0                	test   %eax,%eax
  80050b:	79 02                	jns    80050f <vprintfmt+0x111>
  80050d:	f7 d8                	neg    %eax
  80050f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800511:	83 f8 11             	cmp    $0x11,%eax
  800514:	7f 0b                	jg     800521 <vprintfmt+0x123>
  800516:	8b 04 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%eax
  80051d:	85 c0                	test   %eax,%eax
  80051f:	75 23                	jne    800544 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800521:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800525:	c7 44 24 08 8b 17 80 	movl   $0x80178b,0x8(%esp)
  80052c:	00 
  80052d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800531:	8b 45 08             	mov    0x8(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 9a fe ff ff       	call   8003d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053f:	e9 dd fe ff ff       	jmp    800421 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800544:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800548:	c7 44 24 08 94 17 80 	movl   $0x801794,0x8(%esp)
  80054f:	00 
  800550:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800554:	8b 55 08             	mov    0x8(%ebp),%edx
  800557:	89 14 24             	mov    %edx,(%esp)
  80055a:	e8 77 fe ff ff       	call   8003d6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800562:	e9 ba fe ff ff       	jmp    800421 <vprintfmt+0x23>
  800567:	89 f9                	mov    %edi,%ecx
  800569:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 30                	mov    (%eax),%esi
  80057a:	85 f6                	test   %esi,%esi
  80057c:	75 05                	jne    800583 <vprintfmt+0x185>
				p = "(null)";
  80057e:	be 84 17 80 00       	mov    $0x801784,%esi
			if (width > 0 && padc != '-')
  800583:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800587:	0f 8e 84 00 00 00    	jle    800611 <vprintfmt+0x213>
  80058d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800591:	74 7e                	je     800611 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800597:	89 34 24             	mov    %esi,(%esp)
  80059a:	e8 8b 02 00 00       	call   80082a <strnlen>
  80059f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005a2:	29 c2                	sub    %eax,%edx
  8005a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005a7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005ab:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ae:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005b1:	89 de                	mov    %ebx,%esi
  8005b3:	89 d3                	mov    %edx,%ebx
  8005b5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b7:	eb 0b                	jmp    8005c4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005bd:	89 3c 24             	mov    %edi,(%esp)
  8005c0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	4b                   	dec    %ebx
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f f1                	jg     8005b9 <vprintfmt+0x1bb>
  8005c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005cb:	89 f3                	mov    %esi,%ebx
  8005cd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	79 05                	jns    8005dc <vprintfmt+0x1de>
  8005d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005df:	29 c2                	sub    %eax,%edx
  8005e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005e4:	eb 2b                	jmp    800611 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ea:	74 18                	je     800604 <vprintfmt+0x206>
  8005ec:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ef:	83 fa 5e             	cmp    $0x5e,%edx
  8005f2:	76 10                	jbe    800604 <vprintfmt+0x206>
					putch('?', putdat);
  8005f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ff:	ff 55 08             	call   *0x8(%ebp)
  800602:	eb 0a                	jmp    80060e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800604:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800608:	89 04 24             	mov    %eax,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060e:	ff 4d e4             	decl   -0x1c(%ebp)
  800611:	0f be 06             	movsbl (%esi),%eax
  800614:	46                   	inc    %esi
  800615:	85 c0                	test   %eax,%eax
  800617:	74 21                	je     80063a <vprintfmt+0x23c>
  800619:	85 ff                	test   %edi,%edi
  80061b:	78 c9                	js     8005e6 <vprintfmt+0x1e8>
  80061d:	4f                   	dec    %edi
  80061e:	79 c6                	jns    8005e6 <vprintfmt+0x1e8>
  800620:	8b 7d 08             	mov    0x8(%ebp),%edi
  800623:	89 de                	mov    %ebx,%esi
  800625:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800628:	eb 18                	jmp    800642 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800635:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800637:	4b                   	dec    %ebx
  800638:	eb 08                	jmp    800642 <vprintfmt+0x244>
  80063a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800642:	85 db                	test   %ebx,%ebx
  800644:	7f e4                	jg     80062a <vprintfmt+0x22c>
  800646:	89 7d 08             	mov    %edi,0x8(%ebp)
  800649:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064e:	e9 ce fd ff ff       	jmp    800421 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800653:	83 f9 01             	cmp    $0x1,%ecx
  800656:	7e 10                	jle    800668 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 50 08             	lea    0x8(%eax),%edx
  80065e:	89 55 14             	mov    %edx,0x14(%ebp)
  800661:	8b 30                	mov    (%eax),%esi
  800663:	8b 78 04             	mov    0x4(%eax),%edi
  800666:	eb 26                	jmp    80068e <vprintfmt+0x290>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	74 12                	je     80067e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 30                	mov    (%eax),%esi
  800677:	89 f7                	mov    %esi,%edi
  800679:	c1 ff 1f             	sar    $0x1f,%edi
  80067c:	eb 10                	jmp    80068e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 30                	mov    (%eax),%esi
  800689:	89 f7                	mov    %esi,%edi
  80068b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80068e:	85 ff                	test   %edi,%edi
  800690:	78 0a                	js     80069c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800692:	b8 0a 00 00 00       	mov    $0xa,%eax
  800697:	e9 8c 00 00 00       	jmp    800728 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006aa:	f7 de                	neg    %esi
  8006ac:	83 d7 00             	adc    $0x0,%edi
  8006af:	f7 df                	neg    %edi
			}
			base = 10;
  8006b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b6:	eb 70                	jmp    800728 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b8:	89 ca                	mov    %ecx,%edx
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bd:	e8 c0 fc ff ff       	call   800382 <getuint>
  8006c2:	89 c6                	mov    %eax,%esi
  8006c4:	89 d7                	mov    %edx,%edi
			base = 10;
  8006c6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006cb:	eb 5b                	jmp    800728 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8006cd:	89 ca                	mov    %ecx,%edx
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d2:	e8 ab fc ff ff       	call   800382 <getuint>
  8006d7:	89 c6                	mov    %eax,%esi
  8006d9:	89 d7                	mov    %edx,%edi
			base = 8;
  8006db:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006e0:	eb 46                	jmp    800728 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ed:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 04             	lea    0x4(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800707:	8b 30                	mov    (%eax),%esi
  800709:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800713:	eb 13                	jmp    800728 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800715:	89 ca                	mov    %ecx,%edx
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
  80071a:	e8 63 fc ff ff       	call   800382 <getuint>
  80071f:	89 c6                	mov    %eax,%esi
  800721:	89 d7                	mov    %edx,%edi
			base = 16;
  800723:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800728:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80072c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800730:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800733:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073b:	89 34 24             	mov    %esi,(%esp)
  80073e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800742:	89 da                	mov    %ebx,%edx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	e8 6c fb ff ff       	call   8002b8 <printnum>
			break;
  80074c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074f:	e9 cd fc ff ff       	jmp    800421 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800761:	e9 bb fc ff ff       	jmp    800421 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800766:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80076a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800771:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800774:	eb 01                	jmp    800777 <vprintfmt+0x379>
  800776:	4e                   	dec    %esi
  800777:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80077b:	75 f9                	jne    800776 <vprintfmt+0x378>
  80077d:	e9 9f fc ff ff       	jmp    800421 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800782:	83 c4 4c             	add    $0x4c,%esp
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5f                   	pop    %edi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 28             	sub    $0x28,%esp
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800796:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800799:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	74 30                	je     8007db <vsnprintf+0x51>
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	7e 33                	jle    8007e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	c7 04 24 bc 03 80 00 	movl   $0x8003bc,(%esp)
  8007cb:	e8 2e fc ff ff       	call   8003fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d9:	eb 0c                	jmp    8007e7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e0:	eb 05                	jmp    8007e7 <vsnprintf+0x5d>
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800800:	89 44 24 04          	mov    %eax,0x4(%esp)
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	89 04 24             	mov    %eax,(%esp)
  80080a:	e8 7b ff ff ff       	call   80078a <vsnprintf>
	va_end(ap);

	return rc;
}
  80080f:	c9                   	leave  
  800810:	c3                   	ret    
  800811:	00 00                	add    %al,(%eax)
	...

00800814 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
  80081f:	eb 01                	jmp    800822 <strlen+0xe>
		n++;
  800821:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800822:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800826:	75 f9                	jne    800821 <strlen+0xd>
		n++;
	return n;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	eb 01                	jmp    80083b <strnlen+0x11>
		n++;
  80083a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	39 d0                	cmp    %edx,%eax
  80083d:	74 06                	je     800845 <strnlen+0x1b>
  80083f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800843:	75 f5                	jne    80083a <strnlen+0x10>
		n++;
	return n;
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
  800856:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800859:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80085c:	42                   	inc    %edx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	75 f5                	jne    800856 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	53                   	push   %ebx
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80086e:	89 1c 24             	mov    %ebx,(%esp)
  800871:	e8 9e ff ff ff       	call   800814 <strlen>
	strcpy(dst + len, src);
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087d:	01 d8                	add    %ebx,%eax
  80087f:	89 04 24             	mov    %eax,(%esp)
  800882:	e8 c0 ff ff ff       	call   800847 <strcpy>
	return dst;
}
  800887:	89 d8                	mov    %ebx,%eax
  800889:	83 c4 08             	add    $0x8,%esp
  80088c:	5b                   	pop    %ebx
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a2:	eb 0c                	jmp    8008b0 <strncpy+0x21>
		*dst++ = *src;
  8008a4:	8a 1a                	mov    (%edx),%bl
  8008a6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a9:	80 3a 01             	cmpb   $0x1,(%edx)
  8008ac:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008af:	41                   	inc    %ecx
  8008b0:	39 f1                	cmp    %esi,%ecx
  8008b2:	75 f0                	jne    8008a4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c6:	85 d2                	test   %edx,%edx
  8008c8:	75 0a                	jne    8008d4 <strlcpy+0x1c>
  8008ca:	89 f0                	mov    %esi,%eax
  8008cc:	eb 1a                	jmp    8008e8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ce:	88 18                	mov    %bl,(%eax)
  8008d0:	40                   	inc    %eax
  8008d1:	41                   	inc    %ecx
  8008d2:	eb 02                	jmp    8008d6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008d6:	4a                   	dec    %edx
  8008d7:	74 0a                	je     8008e3 <strlcpy+0x2b>
  8008d9:	8a 19                	mov    (%ecx),%bl
  8008db:	84 db                	test   %bl,%bl
  8008dd:	75 ef                	jne    8008ce <strlcpy+0x16>
  8008df:	89 c2                	mov    %eax,%edx
  8008e1:	eb 02                	jmp    8008e5 <strlcpy+0x2d>
  8008e3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008e5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008e8:	29 f0                	sub    %esi,%eax
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f7:	eb 02                	jmp    8008fb <strcmp+0xd>
		p++, q++;
  8008f9:	41                   	inc    %ecx
  8008fa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008fb:	8a 01                	mov    (%ecx),%al
  8008fd:	84 c0                	test   %al,%al
  8008ff:	74 04                	je     800905 <strcmp+0x17>
  800901:	3a 02                	cmp    (%edx),%al
  800903:	74 f4                	je     8008f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 c0             	movzbl %al,%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800919:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80091c:	eb 03                	jmp    800921 <strncmp+0x12>
		n--, p++, q++;
  80091e:	4a                   	dec    %edx
  80091f:	40                   	inc    %eax
  800920:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800921:	85 d2                	test   %edx,%edx
  800923:	74 14                	je     800939 <strncmp+0x2a>
  800925:	8a 18                	mov    (%eax),%bl
  800927:	84 db                	test   %bl,%bl
  800929:	74 04                	je     80092f <strncmp+0x20>
  80092b:	3a 19                	cmp    (%ecx),%bl
  80092d:	74 ef                	je     80091e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092f:	0f b6 00             	movzbl (%eax),%eax
  800932:	0f b6 11             	movzbl (%ecx),%edx
  800935:	29 d0                	sub    %edx,%eax
  800937:	eb 05                	jmp    80093e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093e:	5b                   	pop    %ebx
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80094a:	eb 05                	jmp    800951 <strchr+0x10>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 0c                	je     80095c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800950:	40                   	inc    %eax
  800951:	8a 10                	mov    (%eax),%dl
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f5                	jne    80094c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800967:	eb 05                	jmp    80096e <strfind+0x10>
		if (*s == c)
  800969:	38 ca                	cmp    %cl,%dl
  80096b:	74 07                	je     800974 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80096d:	40                   	inc    %eax
  80096e:	8a 10                	mov    (%eax),%dl
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f5                	jne    800969 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800985:	85 c9                	test   %ecx,%ecx
  800987:	74 30                	je     8009b9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 25                	jne    8009b6 <memset+0x40>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 20                	jne    8009b6 <memset+0x40>
		c &= 0xFF;
  800996:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800999:	89 d3                	mov    %edx,%ebx
  80099b:	c1 e3 08             	shl    $0x8,%ebx
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	c1 e6 18             	shl    $0x18,%esi
  8009a3:	89 d0                	mov    %edx,%eax
  8009a5:	c1 e0 10             	shl    $0x10,%eax
  8009a8:	09 f0                	or     %esi,%eax
  8009aa:	09 d0                	or     %edx,%eax
  8009ac:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009b1:	fc                   	cld    
  8009b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b4:	eb 03                	jmp    8009b9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b6:	fc                   	cld    
  8009b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b9:	89 f8                	mov    %edi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5f                   	pop    %edi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ce:	39 c6                	cmp    %eax,%esi
  8009d0:	73 34                	jae    800a06 <memmove+0x46>
  8009d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d5:	39 d0                	cmp    %edx,%eax
  8009d7:	73 2d                	jae    800a06 <memmove+0x46>
		s += n;
		d += n;
  8009d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dc:	f6 c2 03             	test   $0x3,%dl
  8009df:	75 1b                	jne    8009fc <memmove+0x3c>
  8009e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e7:	75 13                	jne    8009fc <memmove+0x3c>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0e                	jne    8009fc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ee:	83 ef 04             	sub    $0x4,%edi
  8009f1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009f7:	fd                   	std    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb 07                	jmp    800a03 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009fc:	4f                   	dec    %edi
  8009fd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a00:	fd                   	std    
  800a01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a03:	fc                   	cld    
  800a04:	eb 20                	jmp    800a26 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0c:	75 13                	jne    800a21 <memmove+0x61>
  800a0e:	a8 03                	test   $0x3,%al
  800a10:	75 0f                	jne    800a21 <memmove+0x61>
  800a12:	f6 c1 03             	test   $0x3,%cl
  800a15:	75 0a                	jne    800a21 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a17:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a1a:	89 c7                	mov    %eax,%edi
  800a1c:	fc                   	cld    
  800a1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1f:	eb 05                	jmp    800a26 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a21:	89 c7                	mov    %eax,%edi
  800a23:	fc                   	cld    
  800a24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a26:	5e                   	pop    %esi
  800a27:	5f                   	pop    %edi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a30:	8b 45 10             	mov    0x10(%ebp),%eax
  800a33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	89 04 24             	mov    %eax,(%esp)
  800a44:	e8 77 ff ff ff       	call   8009c0 <memmove>
}
  800a49:	c9                   	leave  
  800a4a:	c3                   	ret    

00800a4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5f:	eb 16                	jmp    800a77 <memcmp+0x2c>
		if (*s1 != *s2)
  800a61:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a64:	42                   	inc    %edx
  800a65:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a69:	38 c8                	cmp    %cl,%al
  800a6b:	74 0a                	je     800a77 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a6d:	0f b6 c0             	movzbl %al,%eax
  800a70:	0f b6 c9             	movzbl %cl,%ecx
  800a73:	29 c8                	sub    %ecx,%eax
  800a75:	eb 09                	jmp    800a80 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a77:	39 da                	cmp    %ebx,%edx
  800a79:	75 e6                	jne    800a61 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a8e:	89 c2                	mov    %eax,%edx
  800a90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a93:	eb 05                	jmp    800a9a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a95:	38 08                	cmp    %cl,(%eax)
  800a97:	74 05                	je     800a9e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a99:	40                   	inc    %eax
  800a9a:	39 d0                	cmp    %edx,%eax
  800a9c:	72 f7                	jb     800a95 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aac:	eb 01                	jmp    800aaf <strtol+0xf>
		s++;
  800aae:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	8a 02                	mov    (%edx),%al
  800ab1:	3c 20                	cmp    $0x20,%al
  800ab3:	74 f9                	je     800aae <strtol+0xe>
  800ab5:	3c 09                	cmp    $0x9,%al
  800ab7:	74 f5                	je     800aae <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab9:	3c 2b                	cmp    $0x2b,%al
  800abb:	75 08                	jne    800ac5 <strtol+0x25>
		s++;
  800abd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abe:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac3:	eb 13                	jmp    800ad8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac5:	3c 2d                	cmp    $0x2d,%al
  800ac7:	75 0a                	jne    800ad3 <strtol+0x33>
		s++, neg = 1;
  800ac9:	8d 52 01             	lea    0x1(%edx),%edx
  800acc:	bf 01 00 00 00       	mov    $0x1,%edi
  800ad1:	eb 05                	jmp    800ad8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ad3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	85 db                	test   %ebx,%ebx
  800ada:	74 05                	je     800ae1 <strtol+0x41>
  800adc:	83 fb 10             	cmp    $0x10,%ebx
  800adf:	75 28                	jne    800b09 <strtol+0x69>
  800ae1:	8a 02                	mov    (%edx),%al
  800ae3:	3c 30                	cmp    $0x30,%al
  800ae5:	75 10                	jne    800af7 <strtol+0x57>
  800ae7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aeb:	75 0a                	jne    800af7 <strtol+0x57>
		s += 2, base = 16;
  800aed:	83 c2 02             	add    $0x2,%edx
  800af0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af5:	eb 12                	jmp    800b09 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	75 0e                	jne    800b09 <strtol+0x69>
  800afb:	3c 30                	cmp    $0x30,%al
  800afd:	75 05                	jne    800b04 <strtol+0x64>
		s++, base = 8;
  800aff:	42                   	inc    %edx
  800b00:	b3 08                	mov    $0x8,%bl
  800b02:	eb 05                	jmp    800b09 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b04:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b10:	8a 0a                	mov    (%edx),%cl
  800b12:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b15:	80 fb 09             	cmp    $0x9,%bl
  800b18:	77 08                	ja     800b22 <strtol+0x82>
			dig = *s - '0';
  800b1a:	0f be c9             	movsbl %cl,%ecx
  800b1d:	83 e9 30             	sub    $0x30,%ecx
  800b20:	eb 1e                	jmp    800b40 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b22:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b25:	80 fb 19             	cmp    $0x19,%bl
  800b28:	77 08                	ja     800b32 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b2a:	0f be c9             	movsbl %cl,%ecx
  800b2d:	83 e9 57             	sub    $0x57,%ecx
  800b30:	eb 0e                	jmp    800b40 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b32:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b35:	80 fb 19             	cmp    $0x19,%bl
  800b38:	77 12                	ja     800b4c <strtol+0xac>
			dig = *s - 'A' + 10;
  800b3a:	0f be c9             	movsbl %cl,%ecx
  800b3d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b40:	39 f1                	cmp    %esi,%ecx
  800b42:	7d 0c                	jge    800b50 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b44:	42                   	inc    %edx
  800b45:	0f af c6             	imul   %esi,%eax
  800b48:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b4a:	eb c4                	jmp    800b10 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b4c:	89 c1                	mov    %eax,%ecx
  800b4e:	eb 02                	jmp    800b52 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b50:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b56:	74 05                	je     800b5d <strtol+0xbd>
		*endptr = (char *) s;
  800b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b5b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b5d:	85 ff                	test   %edi,%edi
  800b5f:	74 04                	je     800b65 <strtol+0xc5>
  800b61:	89 c8                	mov    %ecx,%eax
  800b63:	f7 d8                	neg    %eax
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    
	...

00800b6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	89 c3                	mov    %eax,%ebx
  800b7f:	89 c7                	mov    %eax,%edi
  800b81:	89 c6                	mov    %eax,%esi
  800b83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9a:	89 d1                	mov    %edx,%ecx
  800b9c:	89 d3                	mov    %edx,%ebx
  800b9e:	89 d7                	mov    %edx,%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800bb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	89 cb                	mov    %ecx,%ebx
  800bc1:	89 cf                	mov    %ecx,%edi
  800bc3:	89 ce                	mov    %ecx,%esi
  800bc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 28                	jle    800bf3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bcf:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800bde:	00 
  800bdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be6:	00 
  800be7:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800bee:	e8 b1 f5 ff ff       	call   8001a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf3:	83 c4 2c             	add    $0x2c,%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_yield>:

void
sys_yield(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	be 00 00 00 00       	mov    $0x0,%esi
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	89 f7                	mov    %esi,%edi
  800c57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 28                	jle    800c85 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c61:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c68:	00 
  800c69:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800c70:	00 
  800c71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c78:	00 
  800c79:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800c80:	e8 1f f5 ff ff       	call   8001a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c85:	83 c4 2c             	add    $0x2c,%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 28                	jle    800cd8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cbb:	00 
  800cbc:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800cc3:	00 
  800cc4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccb:	00 
  800ccc:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800cd3:	e8 cc f4 ff ff       	call   8001a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd8:	83 c4 2c             	add    $0x2c,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cee:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	89 df                	mov    %ebx,%edi
  800cfb:	89 de                	mov    %ebx,%esi
  800cfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cff:	85 c0                	test   %eax,%eax
  800d01:	7e 28                	jle    800d2b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d07:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800d16:	00 
  800d17:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1e:	00 
  800d1f:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800d26:	e8 79 f4 ff ff       	call   8001a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2b:	83 c4 2c             	add    $0x2c,%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d41:	b8 08 00 00 00       	mov    $0x8,%eax
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 df                	mov    %ebx,%edi
  800d4e:	89 de                	mov    %ebx,%esi
  800d50:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7e 28                	jle    800d7e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d61:	00 
  800d62:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800d69:	00 
  800d6a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d71:	00 
  800d72:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800d79:	e8 26 f4 ff ff       	call   8001a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7e:	83 c4 2c             	add    $0x2c,%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d94:	b8 09 00 00 00       	mov    $0x9,%eax
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 df                	mov    %ebx,%edi
  800da1:	89 de                	mov    %ebx,%esi
  800da3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 28                	jle    800dd1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dad:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800db4:	00 
  800db5:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc4:	00 
  800dc5:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800dcc:	e8 d3 f3 ff ff       	call   8001a4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd1:	83 c4 2c             	add    $0x2c,%esp
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	8b 55 08             	mov    0x8(%ebp),%edx
  800df2:	89 df                	mov    %ebx,%edi
  800df4:	89 de                	mov    %ebx,%esi
  800df6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7e 28                	jle    800e24 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e00:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e07:	00 
  800e08:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800e0f:	00 
  800e10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e17:	00 
  800e18:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800e1f:	e8 80 f3 ff ff       	call   8001a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e24:	83 c4 2c             	add    $0x2c,%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5f                   	pop    %edi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 cb                	mov    %ecx,%ebx
  800e67:	89 cf                	mov    %ecx,%edi
  800e69:	89 ce                	mov    %ecx,%esi
  800e6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7e 28                	jle    800e99 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e75:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800e7c:	00 
  800e7d:	c7 44 24 08 87 1a 80 	movl   $0x801a87,0x8(%esp)
  800e84:	00 
  800e85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8c:	00 
  800e8d:	c7 04 24 a4 1a 80 00 	movl   $0x801aa4,(%esp)
  800e94:	e8 0b f3 ff ff       	call   8001a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e99:	83 c4 2c             	add    $0x2c,%esp
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb1:	89 d1                	mov    %edx,%ecx
  800eb3:	89 d3                	mov    %edx,%ebx
  800eb5:	89 d7                	mov    %edx,%edi
  800eb7:	89 d6                	mov    %edx,%esi
  800eb9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5f                   	pop    %edi
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	57                   	push   %edi
  800ec4:	56                   	push   %esi
  800ec5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecb:	b8 10 00 00 00       	mov    $0x10,%eax
  800ed0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed6:	89 df                	mov    %ebx,%edi
  800ed8:	89 de                	mov    %ebx,%esi
  800eda:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eec:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	89 de                	mov    %ebx,%esi
  800efb:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f08:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0d:	b8 11 00 00 00       	mov    $0x11,%eax
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	89 cb                	mov    %ecx,%ebx
  800f17:	89 cf                	mov    %ecx,%edi
  800f19:	89 ce                	mov    %ecx,%esi
  800f1b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
	...

00800f24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	53                   	push   %ebx
  800f28:	83 ec 24             	sub    $0x24,%esp
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f2e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800f30:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f34:	75 20                	jne    800f56 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f36:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f3a:	c7 44 24 08 b4 1a 80 	movl   $0x801ab4,0x8(%esp)
  800f41:	00 
  800f42:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f49:	00 
  800f4a:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800f51:	e8 4e f2 ff ff       	call   8001a4 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f56:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f5c:	89 d8                	mov    %ebx,%eax
  800f5e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f61:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f68:	f6 c4 08             	test   $0x8,%ah
  800f6b:	75 1c                	jne    800f89 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f6d:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  800f74:	00 
  800f75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f7c:	00 
  800f7d:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800f84:	e8 1b f2 ff ff       	call   8001a4 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800f89:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa0:	e8 94 fc ff ff       	call   800c39 <sys_page_alloc>
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 20                	jns    800fc9 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fad:	c7 44 24 08 3f 1b 80 	movl   $0x801b3f,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  800fc4:	e8 db f1 ff ff       	call   8001a4 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800fc9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fd0:	00 
  800fd1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fd5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fdc:	e8 df f9 ff ff       	call   8009c0 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800fe1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fe8:	00 
  800fe9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801004:	e8 84 fc ff ff       	call   800c8d <sys_page_map>
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 20                	jns    80102d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80100d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801011:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  801028:	e8 77 f1 ff ff       	call   8001a4 <_panic>

}
  80102d:	83 c4 24             	add    $0x24,%esp
  801030:	5b                   	pop    %ebx
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
  801039:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80103c:	c7 04 24 24 0f 80 00 	movl   $0x800f24,(%esp)
  801043:	e8 ec 03 00 00       	call   801434 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801048:	ba 07 00 00 00       	mov    $0x7,%edx
  80104d:	89 d0                	mov    %edx,%eax
  80104f:	cd 30                	int    $0x30
  801051:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801054:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801057:	85 c0                	test   %eax,%eax
  801059:	79 20                	jns    80107b <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80105b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80105f:	c7 44 24 08 65 1b 80 	movl   $0x801b65,0x8(%esp)
  801066:	00 
  801067:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80106e:	00 
  80106f:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  801076:	e8 29 f1 ff ff       	call   8001a4 <_panic>
	if (child_envid == 0) { // child
  80107b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80107f:	75 1c                	jne    80109d <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801081:	e8 75 fb ff ff       	call   800bfb <sys_getenvid>
  801086:	25 ff 03 00 00       	and    $0x3ff,%eax
  80108b:	c1 e0 07             	shl    $0x7,%eax
  80108e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801093:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  801098:	e9 58 02 00 00       	jmp    8012f5 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  80109d:	bf 00 00 00 00       	mov    $0x0,%edi
  8010a2:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010a7:	89 f0                	mov    %esi,%eax
  8010a9:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b3:	a8 01                	test   $0x1,%al
  8010b5:	0f 84 7a 01 00 00    	je     801235 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8010bb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010c2:	a8 01                	test   $0x1,%al
  8010c4:	0f 84 6b 01 00 00    	je     801235 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8010ca:	a1 04 20 80 00       	mov    0x802004,%eax
  8010cf:	8b 40 48             	mov    0x48(%eax),%eax
  8010d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8010d5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010dc:	f6 c4 04             	test   $0x4,%ah
  8010df:	74 52                	je     801133 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010e1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801100:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	e8 82 fb ff ff       	call   800c8d <sys_page_map>
  80110b:	85 c0                	test   %eax,%eax
  80110d:	0f 89 22 01 00 00    	jns    801235 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801117:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  80111e:	00 
  80111f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801126:	00 
  801127:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80112e:	e8 71 f0 ff ff       	call   8001a4 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801133:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80113a:	f6 c4 08             	test   $0x8,%ah
  80113d:	75 0f                	jne    80114e <fork+0x11b>
  80113f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801146:	a8 02                	test   $0x2,%al
  801148:	0f 84 99 00 00 00    	je     8011e7 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80114e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801155:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801158:	83 f8 01             	cmp    $0x1,%eax
  80115b:	19 db                	sbb    %ebx,%ebx
  80115d:	83 e3 fc             	and    $0xfffffffc,%ebx
  801160:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801166:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80116a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801171:	89 44 24 08          	mov    %eax,0x8(%esp)
  801175:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801179:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80117c:	89 04 24             	mov    %eax,(%esp)
  80117f:	e8 09 fb ff ff       	call   800c8d <sys_page_map>
  801184:	85 c0                	test   %eax,%eax
  801186:	79 20                	jns    8011a8 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118c:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  801193:	00 
  801194:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80119b:	00 
  80119c:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8011a3:	e8 fc ef ff ff       	call   8001a4 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011a8:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011ac:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011bb:	89 04 24             	mov    %eax,(%esp)
  8011be:	e8 ca fa ff ff       	call   800c8d <sys_page_map>
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	79 6e                	jns    801235 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8011c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011cb:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  8011d2:	00 
  8011d3:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8011da:	00 
  8011db:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8011e2:	e8 bd ef ff ff       	call   8001a4 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011e7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801202:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 7c fa ff ff       	call   800c8d <sys_page_map>
  801211:	85 c0                	test   %eax,%eax
  801213:	79 20                	jns    801235 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801215:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801219:	c7 44 24 08 53 1b 80 	movl   $0x801b53,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  801230:	e8 6f ef ff ff       	call   8001a4 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801235:	46                   	inc    %esi
  801236:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80123c:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801242:	0f 85 5f fe ff ff    	jne    8010a7 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801248:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80124f:	00 
  801250:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801257:	ee 
  801258:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80125b:	89 04 24             	mov    %eax,(%esp)
  80125e:	e8 d6 f9 ff ff       	call   800c39 <sys_page_alloc>
  801263:	85 c0                	test   %eax,%eax
  801265:	79 20                	jns    801287 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126b:	c7 44 24 08 3f 1b 80 	movl   $0x801b3f,0x8(%esp)
  801272:	00 
  801273:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80127a:	00 
  80127b:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  801282:	e8 1d ef ff ff       	call   8001a4 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801287:	c7 44 24 04 a8 14 80 	movl   $0x8014a8,0x4(%esp)
  80128e:	00 
  80128f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801292:	89 04 24             	mov    %eax,(%esp)
  801295:	e8 3f fb ff ff       	call   800dd9 <sys_env_set_pgfault_upcall>
  80129a:	85 c0                	test   %eax,%eax
  80129c:	79 20                	jns    8012be <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80129e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a2:	c7 44 24 08 14 1b 80 	movl   $0x801b14,0x8(%esp)
  8012a9:	00 
  8012aa:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8012b1:	00 
  8012b2:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8012b9:	e8 e6 ee ff ff       	call   8001a4 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8012be:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012c5:	00 
  8012c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c9:	89 04 24             	mov    %eax,(%esp)
  8012cc:	e8 62 fa ff ff       	call   800d33 <sys_env_set_status>
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	79 20                	jns    8012f5 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  8012d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d9:	c7 44 24 08 76 1b 80 	movl   $0x801b76,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  8012f0:	e8 af ee ff ff       	call   8001a4 <_panic>

	return child_envid;
}
  8012f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f8:	83 c4 3c             	add    $0x3c,%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5f                   	pop    %edi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <sfork>:

// Challenge!
int
sfork(void)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801306:	c7 44 24 08 8e 1b 80 	movl   $0x801b8e,0x8(%esp)
  80130d:	00 
  80130e:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801315:	00 
  801316:	c7 04 24 34 1b 80 00 	movl   $0x801b34,(%esp)
  80131d:	e8 82 ee ff ff       	call   8001a4 <_panic>
	...

00801324 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 10             	sub    $0x10,%esp
  80132c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80132f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801332:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801335:	85 c0                	test   %eax,%eax
  801337:	75 05                	jne    80133e <ipc_recv+0x1a>
  801339:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80133e:	89 04 24             	mov    %eax,(%esp)
  801341:	e8 09 fb ff ff       	call   800e4f <sys_ipc_recv>
	if (from_env_store != NULL)
  801346:	85 db                	test   %ebx,%ebx
  801348:	74 0b                	je     801355 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80134a:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801350:	8b 52 74             	mov    0x74(%edx),%edx
  801353:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801355:	85 f6                	test   %esi,%esi
  801357:	74 0b                	je     801364 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801359:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80135f:	8b 52 78             	mov    0x78(%edx),%edx
  801362:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801364:	85 c0                	test   %eax,%eax
  801366:	79 16                	jns    80137e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  801368:	85 db                	test   %ebx,%ebx
  80136a:	74 06                	je     801372 <ipc_recv+0x4e>
			*from_env_store = 0;
  80136c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801372:	85 f6                	test   %esi,%esi
  801374:	74 10                	je     801386 <ipc_recv+0x62>
			*perm_store = 0;
  801376:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80137c:	eb 08                	jmp    801386 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80137e:	a1 04 20 80 00       	mov    0x802004,%eax
  801383:	8b 40 70             	mov    0x70(%eax),%eax
}
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 1c             	sub    $0x1c,%esp
  801396:	8b 75 08             	mov    0x8(%ebp),%esi
  801399:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80139c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80139f:	eb 2a                	jmp    8013cb <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8013a1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013a4:	74 20                	je     8013c6 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8013a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013aa:	c7 44 24 08 a4 1b 80 	movl   $0x801ba4,0x8(%esp)
  8013b1:	00 
  8013b2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8013b9:	00 
  8013ba:	c7 04 24 cc 1b 80 00 	movl   $0x801bcc,(%esp)
  8013c1:	e8 de ed ff ff       	call   8001a4 <_panic>
		sys_yield();
  8013c6:	e8 4f f8 ff ff       	call   800c1a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8013cb:	85 db                	test   %ebx,%ebx
  8013cd:	75 07                	jne    8013d6 <ipc_send+0x49>
  8013cf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013d4:	eb 02                	jmp    8013d8 <ipc_send+0x4b>
  8013d6:	89 d8                	mov    %ebx,%eax
  8013d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8013db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013e7:	89 34 24             	mov    %esi,(%esp)
  8013ea:	e8 3d fa ff ff       	call   800e2c <sys_ipc_try_send>
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 ae                	js     8013a1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8013f3:	83 c4 1c             	add    $0x1c,%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5e                   	pop    %esi
  8013f8:	5f                   	pop    %edi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801401:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801406:	89 c2                	mov    %eax,%edx
  801408:	c1 e2 07             	shl    $0x7,%edx
  80140b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801411:	8b 52 50             	mov    0x50(%edx),%edx
  801414:	39 ca                	cmp    %ecx,%edx
  801416:	75 0d                	jne    801425 <ipc_find_env+0x2a>
			return envs[i].env_id;
  801418:	c1 e0 07             	shl    $0x7,%eax
  80141b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801420:	8b 40 40             	mov    0x40(%eax),%eax
  801423:	eb 0c                	jmp    801431 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801425:	40                   	inc    %eax
  801426:	3d 00 04 00 00       	cmp    $0x400,%eax
  80142b:	75 d9                	jne    801406 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80142d:	66 b8 00 00          	mov    $0x0,%ax
}
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    
	...

00801434 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80143a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801441:	75 58                	jne    80149b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  801443:	a1 04 20 80 00       	mov    0x802004,%eax
  801448:	8b 40 48             	mov    0x48(%eax),%eax
  80144b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801452:	00 
  801453:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80145a:	ee 
  80145b:	89 04 24             	mov    %eax,(%esp)
  80145e:	e8 d6 f7 ff ff       	call   800c39 <sys_page_alloc>
  801463:	85 c0                	test   %eax,%eax
  801465:	74 1c                	je     801483 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  801467:	c7 44 24 08 d6 1b 80 	movl   $0x801bd6,0x8(%esp)
  80146e:	00 
  80146f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801476:	00 
  801477:	c7 04 24 eb 1b 80 00 	movl   $0x801beb,(%esp)
  80147e:	e8 21 ed ff ff       	call   8001a4 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801483:	a1 04 20 80 00       	mov    0x802004,%eax
  801488:	8b 40 48             	mov    0x48(%eax),%eax
  80148b:	c7 44 24 04 a8 14 80 	movl   $0x8014a8,0x4(%esp)
  801492:	00 
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 3e f9 ff ff       	call   800dd9 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    
  8014a5:	00 00                	add    %al,(%eax)
	...

008014a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014a9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8014ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014b0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8014b3:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8014b7:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8014b9:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8014bd:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8014be:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8014c1:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8014c3:	58                   	pop    %eax
	popl %eax
  8014c4:	58                   	pop    %eax

	// Pop all registers back
	popal
  8014c5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8014c6:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8014c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8014ca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8014cb:	c3                   	ret    

008014cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8014cc:	55                   	push   %ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	83 ec 10             	sub    $0x10,%esp
  8014d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8014d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8014da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8014e2:	89 cd                	mov    %ecx,%ebp
  8014e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	75 2c                	jne    801518 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8014ec:	39 f9                	cmp    %edi,%ecx
  8014ee:	77 68                	ja     801558 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8014f0:	85 c9                	test   %ecx,%ecx
  8014f2:	75 0b                	jne    8014ff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	31 d2                	xor    %edx,%edx
  8014fb:	f7 f1                	div    %ecx
  8014fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8014ff:	31 d2                	xor    %edx,%edx
  801501:	89 f8                	mov    %edi,%eax
  801503:	f7 f1                	div    %ecx
  801505:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801507:	89 f0                	mov    %esi,%eax
  801509:	f7 f1                	div    %ecx
  80150b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80150d:	89 f0                	mov    %esi,%eax
  80150f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801518:	39 f8                	cmp    %edi,%eax
  80151a:	77 2c                	ja     801548 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80151c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80151f:	83 f6 1f             	xor    $0x1f,%esi
  801522:	75 4c                	jne    801570 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801524:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801526:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80152b:	72 0a                	jb     801537 <__udivdi3+0x6b>
  80152d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801531:	0f 87 ad 00 00 00    	ja     8015e4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801537:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80153c:	89 f0                	mov    %esi,%eax
  80153e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	5e                   	pop    %esi
  801544:	5f                   	pop    %edi
  801545:	5d                   	pop    %ebp
  801546:	c3                   	ret    
  801547:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801548:	31 ff                	xor    %edi,%edi
  80154a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80154c:	89 f0                	mov    %esi,%eax
  80154e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    
  801557:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801558:	89 fa                	mov    %edi,%edx
  80155a:	89 f0                	mov    %esi,%eax
  80155c:	f7 f1                	div    %ecx
  80155e:	89 c6                	mov    %eax,%esi
  801560:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801562:	89 f0                	mov    %esi,%eax
  801564:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    
  80156d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801570:	89 f1                	mov    %esi,%ecx
  801572:	d3 e0                	shl    %cl,%eax
  801574:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801578:	b8 20 00 00 00       	mov    $0x20,%eax
  80157d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80157f:	89 ea                	mov    %ebp,%edx
  801581:	88 c1                	mov    %al,%cl
  801583:	d3 ea                	shr    %cl,%edx
  801585:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801589:	09 ca                	or     %ecx,%edx
  80158b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80158f:	89 f1                	mov    %esi,%ecx
  801591:	d3 e5                	shl    %cl,%ebp
  801593:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801597:	89 fd                	mov    %edi,%ebp
  801599:	88 c1                	mov    %al,%cl
  80159b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80159d:	89 fa                	mov    %edi,%edx
  80159f:	89 f1                	mov    %esi,%ecx
  8015a1:	d3 e2                	shl    %cl,%edx
  8015a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015a7:	88 c1                	mov    %al,%cl
  8015a9:	d3 ef                	shr    %cl,%edi
  8015ab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015ad:	89 f8                	mov    %edi,%eax
  8015af:	89 ea                	mov    %ebp,%edx
  8015b1:	f7 74 24 08          	divl   0x8(%esp)
  8015b5:	89 d1                	mov    %edx,%ecx
  8015b7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8015b9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015bd:	39 d1                	cmp    %edx,%ecx
  8015bf:	72 17                	jb     8015d8 <__udivdi3+0x10c>
  8015c1:	74 09                	je     8015cc <__udivdi3+0x100>
  8015c3:	89 fe                	mov    %edi,%esi
  8015c5:	31 ff                	xor    %edi,%edi
  8015c7:	e9 41 ff ff ff       	jmp    80150d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8015cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015d0:	89 f1                	mov    %esi,%ecx
  8015d2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015d4:	39 c2                	cmp    %eax,%edx
  8015d6:	73 eb                	jae    8015c3 <__udivdi3+0xf7>
		{
		  q0--;
  8015d8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8015db:	31 ff                	xor    %edi,%edi
  8015dd:	e9 2b ff ff ff       	jmp    80150d <__udivdi3+0x41>
  8015e2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8015e4:	31 f6                	xor    %esi,%esi
  8015e6:	e9 22 ff ff ff       	jmp    80150d <__udivdi3+0x41>
	...

008015ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8015ec:	55                   	push   %ebp
  8015ed:	57                   	push   %edi
  8015ee:	56                   	push   %esi
  8015ef:	83 ec 20             	sub    $0x20,%esp
  8015f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8015f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8015fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8015fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801602:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801606:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80160a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80160c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80160e:	85 ed                	test   %ebp,%ebp
  801610:	75 16                	jne    801628 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801612:	39 f1                	cmp    %esi,%ecx
  801614:	0f 86 a6 00 00 00    	jbe    8016c0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80161a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801620:	83 c4 20             	add    $0x20,%esp
  801623:	5e                   	pop    %esi
  801624:	5f                   	pop    %edi
  801625:	5d                   	pop    %ebp
  801626:	c3                   	ret    
  801627:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801628:	39 f5                	cmp    %esi,%ebp
  80162a:	0f 87 ac 00 00 00    	ja     8016dc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801630:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801633:	83 f0 1f             	xor    $0x1f,%eax
  801636:	89 44 24 10          	mov    %eax,0x10(%esp)
  80163a:	0f 84 a8 00 00 00    	je     8016e8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801640:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801644:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801646:	bf 20 00 00 00       	mov    $0x20,%edi
  80164b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80164f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801653:	89 f9                	mov    %edi,%ecx
  801655:	d3 e8                	shr    %cl,%eax
  801657:	09 e8                	or     %ebp,%eax
  801659:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80165d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801661:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801665:	d3 e0                	shl    %cl,%eax
  801667:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80166b:	89 f2                	mov    %esi,%edx
  80166d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80166f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801673:	d3 e0                	shl    %cl,%eax
  801675:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801679:	8b 44 24 14          	mov    0x14(%esp),%eax
  80167d:	89 f9                	mov    %edi,%ecx
  80167f:	d3 e8                	shr    %cl,%eax
  801681:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801683:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801685:	89 f2                	mov    %esi,%edx
  801687:	f7 74 24 18          	divl   0x18(%esp)
  80168b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80168d:	f7 64 24 0c          	mull   0xc(%esp)
  801691:	89 c5                	mov    %eax,%ebp
  801693:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801695:	39 d6                	cmp    %edx,%esi
  801697:	72 67                	jb     801700 <__umoddi3+0x114>
  801699:	74 75                	je     801710 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80169b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80169f:	29 e8                	sub    %ebp,%eax
  8016a1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8016a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016a7:	d3 e8                	shr    %cl,%eax
  8016a9:	89 f2                	mov    %esi,%edx
  8016ab:	89 f9                	mov    %edi,%ecx
  8016ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8016af:	09 d0                	or     %edx,%eax
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016b7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016b9:	83 c4 20             	add    $0x20,%esp
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8016c0:	85 c9                	test   %ecx,%ecx
  8016c2:	75 0b                	jne    8016cf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8016c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c9:	31 d2                	xor    %edx,%edx
  8016cb:	f7 f1                	div    %ecx
  8016cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8016cf:	89 f0                	mov    %esi,%eax
  8016d1:	31 d2                	xor    %edx,%edx
  8016d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8016d5:	89 f8                	mov    %edi,%eax
  8016d7:	e9 3e ff ff ff       	jmp    80161a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8016dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016de:	83 c4 20             	add    $0x20,%esp
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    
  8016e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8016e8:	39 f5                	cmp    %esi,%ebp
  8016ea:	72 04                	jb     8016f0 <__umoddi3+0x104>
  8016ec:	39 f9                	cmp    %edi,%ecx
  8016ee:	77 06                	ja     8016f6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8016f0:	89 f2                	mov    %esi,%edx
  8016f2:	29 cf                	sub    %ecx,%edi
  8016f4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8016f6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	5e                   	pop    %esi
  8016fc:	5f                   	pop    %edi
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    
  8016ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801700:	89 d1                	mov    %edx,%ecx
  801702:	89 c5                	mov    %eax,%ebp
  801704:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801708:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80170c:	eb 8d                	jmp    80169b <__umoddi3+0xaf>
  80170e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801710:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801714:	72 ea                	jb     801700 <__umoddi3+0x114>
  801716:	89 f1                	mov    %esi,%ecx
  801718:	eb 81                	jmp    80169b <__umoddi3+0xaf>
