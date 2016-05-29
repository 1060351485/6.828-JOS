
obj/user/primes:     file format elf32-i386


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
  800053:	e8 0c 12 00 00       	call   801264 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 80 16 80 00 	movl   $0x801680,(%esp)
  800071:	e8 32 02 00 00       	call   8002a8 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 f0 0e 00 00       	call   800f6b <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 8c 16 80 	movl   $0x80168c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 95 16 80 00 	movl   $0x801695,(%esp)
  80009c:	e8 0f 01 00 00       	call   8001b0 <_panic>
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
  8000bb:	e8 a4 11 00 00       	call   801264 <ipc_recv>
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
  8000e0:	e8 e8 11 00 00       	call   8012cd <ipc_send>
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
  8000ef:	e8 77 0e 00 00       	call   800f6b <fork>
  8000f4:	89 c6                	mov    %eax,%esi
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	79 20                	jns    80011a <umain+0x33>
		panic("fork: %e", id);
  8000fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fe:	c7 44 24 08 8c 16 80 	movl   $0x80168c,0x8(%esp)
  800105:	00 
  800106:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80010d:	00 
  80010e:	c7 04 24 95 16 80 00 	movl   $0x801695,(%esp)
  800115:	e8 96 00 00 00       	call   8001b0 <_panic>
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
  80013f:	e8 89 11 00 00       	call   8012cd <ipc_send>
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
  800156:	e8 ac 0a 00 00       	call   800c07 <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800176:	85 f6                	test   %esi,%esi
  800178:	7e 07                	jle    800181 <libmain+0x39>
		binaryname = argv[0];
  80017a:	8b 03                	mov    (%ebx),%eax
  80017c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800181:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800185:	89 34 24             	mov    %esi,(%esp)
  800188:	e8 5a ff ff ff       	call   8000e7 <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    
  800199:	00 00                	add    %al,(%eax)
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 07 0a 00 00       	call   800bb5 <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001b8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bb:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c1:	e8 41 0a 00 00       	call   800c07 <sys_getenvid>
  8001c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dc:	c7 04 24 b0 16 80 00 	movl   $0x8016b0,(%esp)
  8001e3:	e8 c0 00 00 00       	call   8002a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ef:	89 04 24             	mov    %eax,(%esp)
  8001f2:	e8 50 00 00 00       	call   800247 <vcprintf>
	cprintf("\n");
  8001f7:	c7 04 24 f1 19 80 00 	movl   $0x8019f1,(%esp)
  8001fe:	e8 a5 00 00 00       	call   8002a8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800203:	cc                   	int3   
  800204:	eb fd                	jmp    800203 <_panic+0x53>
	...

00800208 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	53                   	push   %ebx
  80020c:	83 ec 14             	sub    $0x14,%esp
  80020f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021b:	40                   	inc    %eax
  80021c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80021e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800223:	75 19                	jne    80023e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800225:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80022c:	00 
  80022d:	8d 43 08             	lea    0x8(%ebx),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 40 09 00 00       	call   800b78 <sys_cputs>
		b->idx = 0;
  800238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80023e:	ff 43 04             	incl   0x4(%ebx)
}
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	5b                   	pop    %ebx
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800250:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800257:	00 00 00 
	b.cnt = 0;
  80025a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800261:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800272:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027c:	c7 04 24 08 02 80 00 	movl   $0x800208,(%esp)
  800283:	e8 82 01 00 00       	call   80040a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800288:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800292:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800298:	89 04 24             	mov    %eax,(%esp)
  80029b:	e8 d8 08 00 00       	call   800b78 <sys_cputs>

	return b.cnt;
}
  8002a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	e8 87 ff ff ff       	call   800247 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c0:	c9                   	leave  
  8002c1:	c3                   	ret    
	...

008002c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 3c             	sub    $0x3c,%esp
  8002cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d0:	89 d7                	mov    %edx,%edi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002de:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	75 08                	jne    8002f0 <printnum+0x2c>
  8002e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002eb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ee:	77 57                	ja     800347 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002f4:	4b                   	dec    %ebx
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800304:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800308:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030f:	00 
  800310:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800319:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031d:	e8 f6 10 00 00       	call   801418 <__udivdi3>
  800322:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800326:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032a:	89 04 24             	mov    %eax,(%esp)
  80032d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800331:	89 fa                	mov    %edi,%edx
  800333:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800336:	e8 89 ff ff ff       	call   8002c4 <printnum>
  80033b:	eb 0f                	jmp    80034c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800341:	89 34 24             	mov    %esi,(%esp)
  800344:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800347:	4b                   	dec    %ebx
  800348:	85 db                	test   %ebx,%ebx
  80034a:	7f f1                	jg     80033d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800350:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800354:	8b 45 10             	mov    0x10(%ebp),%eax
  800357:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800362:	00 
  800363:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800366:	89 04 24             	mov    %eax,(%esp)
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800370:	e8 c3 11 00 00       	call   801538 <__umoddi3>
  800375:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800379:	0f be 80 d3 16 80 00 	movsbl 0x8016d3(%eax),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800386:	83 c4 3c             	add    $0x3c,%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800391:	83 fa 01             	cmp    $0x1,%edx
  800394:	7e 0e                	jle    8003a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	8b 52 04             	mov    0x4(%edx),%edx
  8003a2:	eb 22                	jmp    8003c6 <getuint+0x38>
	else if (lflag)
  8003a4:	85 d2                	test   %edx,%edx
  8003a6:	74 10                	je     8003b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a8:	8b 10                	mov    (%eax),%edx
  8003aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ad:	89 08                	mov    %ecx,(%eax)
  8003af:	8b 02                	mov    (%edx),%eax
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	eb 0e                	jmp    8003c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 02                	mov    (%edx),%eax
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ce:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003d1:	8b 10                	mov    (%eax),%edx
  8003d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d6:	73 08                	jae    8003e0 <sprintputch+0x18>
		*b->buf++ = ch;
  8003d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003db:	88 0a                	mov    %cl,(%edx)
  8003dd:	42                   	inc    %edx
  8003de:	89 10                	mov    %edx,(%eax)
}
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 02 00 00 00       	call   80040a <vprintfmt>
	va_end(ap);
}
  800408:	c9                   	leave  
  800409:	c3                   	ret    

0080040a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	57                   	push   %edi
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	83 ec 4c             	sub    $0x4c,%esp
  800413:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800416:	8b 75 10             	mov    0x10(%ebp),%esi
  800419:	eb 12                	jmp    80042d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80041b:	85 c0                	test   %eax,%eax
  80041d:	0f 84 6b 03 00 00    	je     80078e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800423:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800427:	89 04 24             	mov    %eax,(%esp)
  80042a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80042d:	0f b6 06             	movzbl (%esi),%eax
  800430:	46                   	inc    %esi
  800431:	83 f8 25             	cmp    $0x25,%eax
  800434:	75 e5                	jne    80041b <vprintfmt+0x11>
  800436:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80043a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800441:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800446:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80044d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800452:	eb 26                	jmp    80047a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800457:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80045b:	eb 1d                	jmp    80047a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800460:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800464:	eb 14                	jmp    80047a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800469:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800470:	eb 08                	jmp    80047a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800472:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800475:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	0f b6 06             	movzbl (%esi),%eax
  80047d:	8d 56 01             	lea    0x1(%esi),%edx
  800480:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800483:	8a 16                	mov    (%esi),%dl
  800485:	83 ea 23             	sub    $0x23,%edx
  800488:	80 fa 55             	cmp    $0x55,%dl
  80048b:	0f 87 e1 02 00 00    	ja     800772 <vprintfmt+0x368>
  800491:	0f b6 d2             	movzbl %dl,%edx
  800494:	ff 24 95 a0 17 80 00 	jmp    *0x8017a0(,%edx,4)
  80049b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80049e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004a6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004aa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ad:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004b0:	83 fa 09             	cmp    $0x9,%edx
  8004b3:	77 2a                	ja     8004df <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b6:	eb eb                	jmp    8004a3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c6:	eb 17                	jmp    8004df <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8004c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cc:	78 98                	js     800466 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004d1:	eb a7                	jmp    80047a <vprintfmt+0x70>
  8004d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004d6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8004dd:	eb 9b                	jmp    80047a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8004df:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e3:	79 95                	jns    80047a <vprintfmt+0x70>
  8004e5:	eb 8b                	jmp    800472 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004eb:	eb 8d                	jmp    80047a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8d 50 04             	lea    0x4(%eax),%edx
  8004f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 23 ff ff ff       	jmp    80042d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	85 c0                	test   %eax,%eax
  800517:	79 02                	jns    80051b <vprintfmt+0x111>
  800519:	f7 d8                	neg    %eax
  80051b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051d:	83 f8 09             	cmp    $0x9,%eax
  800520:	7f 0b                	jg     80052d <vprintfmt+0x123>
  800522:	8b 04 85 00 19 80 00 	mov    0x801900(,%eax,4),%eax
  800529:	85 c0                	test   %eax,%eax
  80052b:	75 23                	jne    800550 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80052d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800531:	c7 44 24 08 eb 16 80 	movl   $0x8016eb,0x8(%esp)
  800538:	00 
  800539:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053d:	8b 45 08             	mov    0x8(%ebp),%eax
  800540:	89 04 24             	mov    %eax,(%esp)
  800543:	e8 9a fe ff ff       	call   8003e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054b:	e9 dd fe ff ff       	jmp    80042d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800550:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800554:	c7 44 24 08 f4 16 80 	movl   $0x8016f4,0x8(%esp)
  80055b:	00 
  80055c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800560:	8b 55 08             	mov    0x8(%ebp),%edx
  800563:	89 14 24             	mov    %edx,(%esp)
  800566:	e8 77 fe ff ff       	call   8003e2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80056e:	e9 ba fe ff ff       	jmp    80042d <vprintfmt+0x23>
  800573:	89 f9                	mov    %edi,%ecx
  800575:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800578:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 50 04             	lea    0x4(%eax),%edx
  800581:	89 55 14             	mov    %edx,0x14(%ebp)
  800584:	8b 30                	mov    (%eax),%esi
  800586:	85 f6                	test   %esi,%esi
  800588:	75 05                	jne    80058f <vprintfmt+0x185>
				p = "(null)";
  80058a:	be e4 16 80 00       	mov    $0x8016e4,%esi
			if (width > 0 && padc != '-')
  80058f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800593:	0f 8e 84 00 00 00    	jle    80061d <vprintfmt+0x213>
  800599:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80059d:	74 7e                	je     80061d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a3:	89 34 24             	mov    %esi,(%esp)
  8005a6:	e8 8b 02 00 00       	call   800836 <strnlen>
  8005ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ae:	29 c2                	sub    %eax,%edx
  8005b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005b3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005b7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ba:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005bd:	89 de                	mov    %ebx,%esi
  8005bf:	89 d3                	mov    %edx,%ebx
  8005c1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	eb 0b                	jmp    8005d0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8005c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c9:	89 3c 24             	mov    %edi,(%esp)
  8005cc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	4b                   	dec    %ebx
  8005d0:	85 db                	test   %ebx,%ebx
  8005d2:	7f f1                	jg     8005c5 <vprintfmt+0x1bb>
  8005d4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005d7:	89 f3                	mov    %esi,%ebx
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8005dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	79 05                	jns    8005e8 <vprintfmt+0x1de>
  8005e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005eb:	29 c2                	sub    %eax,%edx
  8005ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f0:	eb 2b                	jmp    80061d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f6:	74 18                	je     800610 <vprintfmt+0x206>
  8005f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fb:	83 fa 5e             	cmp    $0x5e,%edx
  8005fe:	76 10                	jbe    800610 <vprintfmt+0x206>
					putch('?', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
  80060e:	eb 0a                	jmp    80061a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800610:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	ff 4d e4             	decl   -0x1c(%ebp)
  80061d:	0f be 06             	movsbl (%esi),%eax
  800620:	46                   	inc    %esi
  800621:	85 c0                	test   %eax,%eax
  800623:	74 21                	je     800646 <vprintfmt+0x23c>
  800625:	85 ff                	test   %edi,%edi
  800627:	78 c9                	js     8005f2 <vprintfmt+0x1e8>
  800629:	4f                   	dec    %edi
  80062a:	79 c6                	jns    8005f2 <vprintfmt+0x1e8>
  80062c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80062f:	89 de                	mov    %ebx,%esi
  800631:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800634:	eb 18                	jmp    80064e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800636:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800641:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800643:	4b                   	dec    %ebx
  800644:	eb 08                	jmp    80064e <vprintfmt+0x244>
  800646:	8b 7d 08             	mov    0x8(%ebp),%edi
  800649:	89 de                	mov    %ebx,%esi
  80064b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80064e:	85 db                	test   %ebx,%ebx
  800650:	7f e4                	jg     800636 <vprintfmt+0x22c>
  800652:	89 7d 08             	mov    %edi,0x8(%ebp)
  800655:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800657:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065a:	e9 ce fd ff ff       	jmp    80042d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065f:	83 f9 01             	cmp    $0x1,%ecx
  800662:	7e 10                	jle    800674 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 08             	lea    0x8(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 30                	mov    (%eax),%esi
  80066f:	8b 78 04             	mov    0x4(%eax),%edi
  800672:	eb 26                	jmp    80069a <vprintfmt+0x290>
	else if (lflag)
  800674:	85 c9                	test   %ecx,%ecx
  800676:	74 12                	je     80068a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 50 04             	lea    0x4(%eax),%edx
  80067e:	89 55 14             	mov    %edx,0x14(%ebp)
  800681:	8b 30                	mov    (%eax),%esi
  800683:	89 f7                	mov    %esi,%edi
  800685:	c1 ff 1f             	sar    $0x1f,%edi
  800688:	eb 10                	jmp    80069a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 30                	mov    (%eax),%esi
  800695:	89 f7                	mov    %esi,%edi
  800697:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069a:	85 ff                	test   %edi,%edi
  80069c:	78 0a                	js     8006a8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a3:	e9 8c 00 00 00       	jmp    800734 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ac:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b6:	f7 de                	neg    %esi
  8006b8:	83 d7 00             	adc    $0x0,%edi
  8006bb:	f7 df                	neg    %edi
			}
			base = 10;
  8006bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c2:	eb 70                	jmp    800734 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c4:	89 ca                	mov    %ecx,%edx
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 c0 fc ff ff       	call   80038e <getuint>
  8006ce:	89 c6                	mov    %eax,%esi
  8006d0:	89 d7                	mov    %edx,%edi
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006d7:	eb 5b                	jmp    800734 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 ab fc ff ff       	call   80038e <getuint>
  8006e3:	89 c6                	mov    %eax,%esi
  8006e5:	89 d7                	mov    %edx,%edi
			base = 8;
  8006e7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006ec:	eb 46                	jmp    800734 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800700:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80071f:	eb 13                	jmp    800734 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800721:	89 ca                	mov    %ecx,%edx
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 63 fc ff ff       	call   80038e <getuint>
  80072b:	89 c6                	mov    %eax,%esi
  80072d:	89 d7                	mov    %edx,%edi
			base = 16;
  80072f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800734:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800738:	89 54 24 10          	mov    %edx,0x10(%esp)
  80073c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80073f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800743:	89 44 24 08          	mov    %eax,0x8(%esp)
  800747:	89 34 24             	mov    %esi,(%esp)
  80074a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074e:	89 da                	mov    %ebx,%edx
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	e8 6c fb ff ff       	call   8002c4 <printnum>
			break;
  800758:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075b:	e9 cd fc ff ff       	jmp    80042d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800764:	89 04 24             	mov    %eax,(%esp)
  800767:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076d:	e9 bb fc ff ff       	jmp    80042d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800776:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80077d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800780:	eb 01                	jmp    800783 <vprintfmt+0x379>
  800782:	4e                   	dec    %esi
  800783:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800787:	75 f9                	jne    800782 <vprintfmt+0x378>
  800789:	e9 9f fc ff ff       	jmp    80042d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80078e:	83 c4 4c             	add    $0x4c,%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 28             	sub    $0x28,%esp
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	74 30                	je     8007e7 <vsnprintf+0x51>
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	7e 33                	jle    8007ee <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d0:	c7 04 24 c8 03 80 00 	movl   $0x8003c8,(%esp)
  8007d7:	e8 2e fc ff ff       	call   80040a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e5:	eb 0c                	jmp    8007f3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ec:	eb 05                	jmp    8007f3 <vsnprintf+0x5d>
  8007ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    

008007f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
  800805:	89 44 24 08          	mov    %eax,0x8(%esp)
  800809:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	e8 7b ff ff ff       	call   800796 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    
  80081d:	00 00                	add    %al,(%eax)
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 01                	jmp    80082e <strlen+0xe>
		n++;
  80082d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800832:	75 f9                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
  800844:	eb 01                	jmp    800847 <strnlen+0x11>
		n++;
  800846:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	39 d0                	cmp    %edx,%eax
  800849:	74 06                	je     800851 <strnlen+0x1b>
  80084b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084f:	75 f5                	jne    800846 <strnlen+0x10>
		n++;
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	ba 00 00 00 00       	mov    $0x0,%edx
  800862:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800865:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800868:	42                   	inc    %edx
  800869:	84 c9                	test   %cl,%cl
  80086b:	75 f5                	jne    800862 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80086d:	5b                   	pop    %ebx
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087a:	89 1c 24             	mov    %ebx,(%esp)
  80087d:	e8 9e ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 54 24 04          	mov    %edx,0x4(%esp)
  800889:	01 d8                	add    %ebx,%eax
  80088b:	89 04 24             	mov    %eax,(%esp)
  80088e:	e8 c0 ff ff ff       	call   800853 <strcpy>
	return dst;
}
  800893:	89 d8                	mov    %ebx,%eax
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ae:	eb 0c                	jmp    8008bc <strncpy+0x21>
		*dst++ = *src;
  8008b0:	8a 1a                	mov    (%edx),%bl
  8008b2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b5:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bb:	41                   	inc    %ecx
  8008bc:	39 f1                	cmp    %esi,%ecx
  8008be:	75 f0                	jne    8008b0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	75 0a                	jne    8008e0 <strlcpy+0x1c>
  8008d6:	89 f0                	mov    %esi,%eax
  8008d8:	eb 1a                	jmp    8008f4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008da:	88 18                	mov    %bl,(%eax)
  8008dc:	40                   	inc    %eax
  8008dd:	41                   	inc    %ecx
  8008de:	eb 02                	jmp    8008e2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8008e2:	4a                   	dec    %edx
  8008e3:	74 0a                	je     8008ef <strlcpy+0x2b>
  8008e5:	8a 19                	mov    (%ecx),%bl
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	75 ef                	jne    8008da <strlcpy+0x16>
  8008eb:	89 c2                	mov    %eax,%edx
  8008ed:	eb 02                	jmp    8008f1 <strlcpy+0x2d>
  8008ef:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008f4:	29 f0                	sub    %esi,%eax
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800900:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800903:	eb 02                	jmp    800907 <strcmp+0xd>
		p++, q++;
  800905:	41                   	inc    %ecx
  800906:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800907:	8a 01                	mov    (%ecx),%al
  800909:	84 c0                	test   %al,%al
  80090b:	74 04                	je     800911 <strcmp+0x17>
  80090d:	3a 02                	cmp    (%edx),%al
  80090f:	74 f4                	je     800905 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800911:	0f b6 c0             	movzbl %al,%eax
  800914:	0f b6 12             	movzbl (%edx),%edx
  800917:	29 d0                	sub    %edx,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800925:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800928:	eb 03                	jmp    80092d <strncmp+0x12>
		n--, p++, q++;
  80092a:	4a                   	dec    %edx
  80092b:	40                   	inc    %eax
  80092c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092d:	85 d2                	test   %edx,%edx
  80092f:	74 14                	je     800945 <strncmp+0x2a>
  800931:	8a 18                	mov    (%eax),%bl
  800933:	84 db                	test   %bl,%bl
  800935:	74 04                	je     80093b <strncmp+0x20>
  800937:	3a 19                	cmp    (%ecx),%bl
  800939:	74 ef                	je     80092a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093b:	0f b6 00             	movzbl (%eax),%eax
  80093e:	0f b6 11             	movzbl (%ecx),%edx
  800941:	29 d0                	sub    %edx,%eax
  800943:	eb 05                	jmp    80094a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80094a:	5b                   	pop    %ebx
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800956:	eb 05                	jmp    80095d <strchr+0x10>
		if (*s == c)
  800958:	38 ca                	cmp    %cl,%dl
  80095a:	74 0c                	je     800968 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095c:	40                   	inc    %eax
  80095d:	8a 10                	mov    (%eax),%dl
  80095f:	84 d2                	test   %dl,%dl
  800961:	75 f5                	jne    800958 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800973:	eb 05                	jmp    80097a <strfind+0x10>
		if (*s == c)
  800975:	38 ca                	cmp    %cl,%dl
  800977:	74 07                	je     800980 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800979:	40                   	inc    %eax
  80097a:	8a 10                	mov    (%eax),%dl
  80097c:	84 d2                	test   %dl,%dl
  80097e:	75 f5                	jne    800975 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 7d 08             	mov    0x8(%ebp),%edi
  80098b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800991:	85 c9                	test   %ecx,%ecx
  800993:	74 30                	je     8009c5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800995:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099b:	75 25                	jne    8009c2 <memset+0x40>
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 20                	jne    8009c2 <memset+0x40>
		c &= 0xFF;
  8009a2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a5:	89 d3                	mov    %edx,%ebx
  8009a7:	c1 e3 08             	shl    $0x8,%ebx
  8009aa:	89 d6                	mov    %edx,%esi
  8009ac:	c1 e6 18             	shl    $0x18,%esi
  8009af:	89 d0                	mov    %edx,%eax
  8009b1:	c1 e0 10             	shl    $0x10,%eax
  8009b4:	09 f0                	or     %esi,%eax
  8009b6:	09 d0                	or     %edx,%eax
  8009b8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009bd:	fc                   	cld    
  8009be:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c0:	eb 03                	jmp    8009c5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c2:	fc                   	cld    
  8009c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c5:	89 f8                	mov    %edi,%eax
  8009c7:	5b                   	pop    %ebx
  8009c8:	5e                   	pop    %esi
  8009c9:	5f                   	pop    %edi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009da:	39 c6                	cmp    %eax,%esi
  8009dc:	73 34                	jae    800a12 <memmove+0x46>
  8009de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	73 2d                	jae    800a12 <memmove+0x46>
		s += n;
		d += n;
  8009e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e8:	f6 c2 03             	test   $0x3,%dl
  8009eb:	75 1b                	jne    800a08 <memmove+0x3c>
  8009ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f3:	75 13                	jne    800a08 <memmove+0x3c>
  8009f5:	f6 c1 03             	test   $0x3,%cl
  8009f8:	75 0e                	jne    800a08 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009fa:	83 ef 04             	sub    $0x4,%edi
  8009fd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a03:	fd                   	std    
  800a04:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a06:	eb 07                	jmp    800a0f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a08:	4f                   	dec    %edi
  800a09:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0f:	fc                   	cld    
  800a10:	eb 20                	jmp    800a32 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a12:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a18:	75 13                	jne    800a2d <memmove+0x61>
  800a1a:	a8 03                	test   $0x3,%al
  800a1c:	75 0f                	jne    800a2d <memmove+0x61>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	75 0a                	jne    800a2d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a23:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2b:	eb 05                	jmp    800a32 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2d:	89 c7                	mov    %eax,%edi
  800a2f:	fc                   	cld    
  800a30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	e8 77 ff ff ff       	call   8009cc <memmove>
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a66:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6b:	eb 16                	jmp    800a83 <memcmp+0x2c>
		if (*s1 != *s2)
  800a6d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a70:	42                   	inc    %edx
  800a71:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a75:	38 c8                	cmp    %cl,%al
  800a77:	74 0a                	je     800a83 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a79:	0f b6 c0             	movzbl %al,%eax
  800a7c:	0f b6 c9             	movzbl %cl,%ecx
  800a7f:	29 c8                	sub    %ecx,%eax
  800a81:	eb 09                	jmp    800a8c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a83:	39 da                	cmp    %ebx,%edx
  800a85:	75 e6                	jne    800a6d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9a:	89 c2                	mov    %eax,%edx
  800a9c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a9f:	eb 05                	jmp    800aa6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa1:	38 08                	cmp    %cl,(%eax)
  800aa3:	74 05                	je     800aaa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aa5:	40                   	inc    %eax
  800aa6:	39 d0                	cmp    %edx,%eax
  800aa8:	72 f7                	jb     800aa1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab8:	eb 01                	jmp    800abb <strtol+0xf>
		s++;
  800aba:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abb:	8a 02                	mov    (%edx),%al
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f9                	je     800aba <strtol+0xe>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	74 f5                	je     800aba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ac5:	3c 2b                	cmp    $0x2b,%al
  800ac7:	75 08                	jne    800ad1 <strtol+0x25>
		s++;
  800ac9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aca:	bf 00 00 00 00       	mov    $0x0,%edi
  800acf:	eb 13                	jmp    800ae4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ad1:	3c 2d                	cmp    $0x2d,%al
  800ad3:	75 0a                	jne    800adf <strtol+0x33>
		s++, neg = 1;
  800ad5:	8d 52 01             	lea    0x1(%edx),%edx
  800ad8:	bf 01 00 00 00       	mov    $0x1,%edi
  800add:	eb 05                	jmp    800ae4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800adf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	74 05                	je     800aed <strtol+0x41>
  800ae8:	83 fb 10             	cmp    $0x10,%ebx
  800aeb:	75 28                	jne    800b15 <strtol+0x69>
  800aed:	8a 02                	mov    (%edx),%al
  800aef:	3c 30                	cmp    $0x30,%al
  800af1:	75 10                	jne    800b03 <strtol+0x57>
  800af3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af7:	75 0a                	jne    800b03 <strtol+0x57>
		s += 2, base = 16;
  800af9:	83 c2 02             	add    $0x2,%edx
  800afc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b01:	eb 12                	jmp    800b15 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	75 0e                	jne    800b15 <strtol+0x69>
  800b07:	3c 30                	cmp    $0x30,%al
  800b09:	75 05                	jne    800b10 <strtol+0x64>
		s++, base = 8;
  800b0b:	42                   	inc    %edx
  800b0c:	b3 08                	mov    $0x8,%bl
  800b0e:	eb 05                	jmp    800b15 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b10:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1c:	8a 0a                	mov    (%edx),%cl
  800b1e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b21:	80 fb 09             	cmp    $0x9,%bl
  800b24:	77 08                	ja     800b2e <strtol+0x82>
			dig = *s - '0';
  800b26:	0f be c9             	movsbl %cl,%ecx
  800b29:	83 e9 30             	sub    $0x30,%ecx
  800b2c:	eb 1e                	jmp    800b4c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b2e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b31:	80 fb 19             	cmp    $0x19,%bl
  800b34:	77 08                	ja     800b3e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b36:	0f be c9             	movsbl %cl,%ecx
  800b39:	83 e9 57             	sub    $0x57,%ecx
  800b3c:	eb 0e                	jmp    800b4c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b3e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800b41:	80 fb 19             	cmp    $0x19,%bl
  800b44:	77 12                	ja     800b58 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b46:	0f be c9             	movsbl %cl,%ecx
  800b49:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b4c:	39 f1                	cmp    %esi,%ecx
  800b4e:	7d 0c                	jge    800b5c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b50:	42                   	inc    %edx
  800b51:	0f af c6             	imul   %esi,%eax
  800b54:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b56:	eb c4                	jmp    800b1c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	89 c1                	mov    %eax,%ecx
  800b5a:	eb 02                	jmp    800b5e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b5c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b62:	74 05                	je     800b69 <strtol+0xbd>
		*endptr = (char *) s;
  800b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b67:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b69:	85 ff                	test   %edi,%edi
  800b6b:	74 04                	je     800b71 <strtol+0xc5>
  800b6d:	89 c8                	mov    %ecx,%eax
  800b6f:	f7 d8                	neg    %eax
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
	...

00800b78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 c3                	mov    %eax,%ebx
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	89 c6                	mov    %eax,%esi
  800b8f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba6:	89 d1                	mov    %edx,%ecx
  800ba8:	89 d3                	mov    %edx,%ebx
  800baa:	89 d7                	mov    %edx,%edi
  800bac:	89 d6                	mov    %edx,%esi
  800bae:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	89 cb                	mov    %ecx,%ebx
  800bcd:	89 cf                	mov    %ecx,%edi
  800bcf:	89 ce                	mov    %ecx,%esi
  800bd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 28                	jle    800bff <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800be2:	00 
  800be3:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800bea:	00 
  800beb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf2:	00 
  800bf3:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800bfa:	e8 b1 f5 ff ff       	call   8001b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bff:	83 c4 2c             	add    $0x2c,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 02 00 00 00       	mov    $0x2,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_yield>:

void
sys_yield(void)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	be 00 00 00 00       	mov    $0x0,%esi
  800c53:	b8 04 00 00 00       	mov    $0x4,%eax
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 f7                	mov    %esi,%edi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 28                	jle    800c91 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c74:	00 
  800c75:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c84:	00 
  800c85:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800c8c:	e8 1f f5 ff ff       	call   8001b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c91:	83 c4 2c             	add    $0x2c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	8b 75 18             	mov    0x18(%ebp),%esi
  800caa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 28                	jle    800ce4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800cc7:	00 
  800cc8:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd7:	00 
  800cd8:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800cdf:	e8 cc f4 ff ff       	call   8001b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce4:	83 c4 2c             	add    $0x2c,%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 28                	jle    800d37 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d13:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800d22:	00 
  800d23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2a:	00 
  800d2b:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800d32:	e8 79 f4 ff ff       	call   8001b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d37:	83 c4 2c             	add    $0x2c,%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7e 28                	jle    800d8a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d66:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d6d:	00 
  800d6e:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800d75:	00 
  800d76:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7d:	00 
  800d7e:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800d85:	e8 26 f4 ff ff       	call   8001b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8a:	83 c4 2c             	add    $0x2c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da0:	b8 09 00 00 00       	mov    $0x9,%eax
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 df                	mov    %ebx,%edi
  800dad:	89 de                	mov    %ebx,%esi
  800daf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db1:	85 c0                	test   %eax,%eax
  800db3:	7e 28                	jle    800ddd <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc0:	00 
  800dc1:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd0:	00 
  800dd1:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800dd8:	e8 d3 f3 ff ff       	call   8001b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ddd:	83 c4 2c             	add    $0x2c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	be 00 00 00 00       	mov    $0x0,%esi
  800df0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	89 cb                	mov    %ecx,%ebx
  800e20:	89 cf                	mov    %ecx,%edi
  800e22:	89 ce                	mov    %ecx,%esi
  800e24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	7e 28                	jle    800e52 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e35:	00 
  800e36:	c7 44 24 08 28 19 80 	movl   $0x801928,0x8(%esp)
  800e3d:	00 
  800e3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e45:	00 
  800e46:	c7 04 24 45 19 80 00 	movl   $0x801945,(%esp)
  800e4d:	e8 5e f3 ff ff       	call   8001b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e52:	83 c4 2c             	add    $0x2c,%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5f                   	pop    %edi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
	...

00800e5c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 24             	sub    $0x24,%esp
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e66:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800e68:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e6c:	75 20                	jne    800e8e <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800e6e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e72:	c7 44 24 08 54 19 80 	movl   $0x801954,0x8(%esp)
  800e79:	00 
  800e7a:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e81:	00 
  800e82:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800e89:	e8 22 f3 ff ff       	call   8001b0 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800e8e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800e99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea0:	f6 c4 08             	test   $0x8,%ah
  800ea3:	75 1c                	jne    800ec1 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ea5:	c7 44 24 08 84 19 80 	movl   $0x801984,0x8(%esp)
  800eac:	00 
  800ead:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb4:	00 
  800eb5:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800ebc:	e8 ef f2 ff ff       	call   8001b0 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ec1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ed0:	00 
  800ed1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ed8:	e8 68 fd ff ff       	call   800c45 <sys_page_alloc>
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 20                	jns    800f01 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800ee1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee5:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  800eec:	00 
  800eed:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800ef4:	00 
  800ef5:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800efc:	e8 af f2 ff ff       	call   8001b0 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800f01:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f08:	00 
  800f09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f0d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f14:	e8 b3 fa ff ff       	call   8009cc <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  800f19:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f20:	00 
  800f21:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f3c:	e8 58 fd ff ff       	call   800c99 <sys_page_map>
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 20                	jns    800f65 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  800f45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f49:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  800f50:	00 
  800f51:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  800f58:	00 
  800f59:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800f60:	e8 4b f2 ff ff       	call   8001b0 <_panic>

}
  800f65:	83 c4 24             	add    $0x24,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  800f74:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  800f7b:	e8 00 04 00 00       	call   801380 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f80:	ba 07 00 00 00       	mov    $0x7,%edx
  800f85:	89 d0                	mov    %edx,%eax
  800f87:	cd 30                	int    $0x30
  800f89:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f8c:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 20                	jns    800fb3 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  800f93:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f97:	c7 44 24 08 05 1a 80 	movl   $0x801a05,0x8(%esp)
  800f9e:	00 
  800f9f:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  800fa6:	00 
  800fa7:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  800fae:	e8 fd f1 ff ff       	call   8001b0 <_panic>
	if (child_envid == 0) { // child
  800fb3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fb7:	75 25                	jne    800fde <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb9:	e8 49 fc ff ff       	call   800c07 <sys_getenvid>
  800fbe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fca:	c1 e0 07             	shl    $0x7,%eax
  800fcd:	29 d0                	sub    %edx,%eax
  800fcf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd4:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800fd9:	e9 58 02 00 00       	jmp    801236 <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  800fde:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe3:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  800fe8:	89 f0                	mov    %esi,%eax
  800fea:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  800fed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff4:	a8 01                	test   $0x1,%al
  800ff6:	0f 84 7a 01 00 00    	je     801176 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  800ffc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801003:	a8 01                	test   $0x1,%al
  801005:	0f 84 6b 01 00 00    	je     801176 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80100b:	a1 04 20 80 00       	mov    0x802004,%eax
  801010:	8b 40 48             	mov    0x48(%eax),%eax
  801013:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801016:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80101d:	f6 c4 04             	test   $0x4,%ah
  801020:	74 52                	je     801074 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801022:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801029:	25 07 0e 00 00       	and    $0xe07,%eax
  80102e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801032:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801036:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801039:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801041:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801044:	89 04 24             	mov    %eax,(%esp)
  801047:	e8 4d fc ff ff       	call   800c99 <sys_page_map>
  80104c:	85 c0                	test   %eax,%eax
  80104e:	0f 89 22 01 00 00    	jns    801176 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801054:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801058:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  80105f:	00 
  801060:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801067:	00 
  801068:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  80106f:	e8 3c f1 ff ff       	call   8001b0 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801074:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107b:	f6 c4 08             	test   $0x8,%ah
  80107e:	75 0f                	jne    80108f <fork+0x124>
  801080:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801087:	a8 02                	test   $0x2,%al
  801089:	0f 84 99 00 00 00    	je     801128 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80108f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801096:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801099:	83 f8 01             	cmp    $0x1,%eax
  80109c:	19 db                	sbb    %ebx,%ebx
  80109e:	83 e3 fc             	and    $0xfffffffc,%ebx
  8010a1:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010a7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010bd:	89 04 24             	mov    %eax,(%esp)
  8010c0:	e8 d4 fb ff ff       	call   800c99 <sys_page_map>
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 20                	jns    8010e9 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8010c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010cd:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010dc:	00 
  8010dd:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8010e4:	e8 c7 f0 ff ff       	call   8001b0 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8010e9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8010ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010fc:	89 04 24             	mov    %eax,(%esp)
  8010ff:	e8 95 fb ff ff       	call   800c99 <sys_page_map>
  801104:	85 c0                	test   %eax,%eax
  801106:	79 6e                	jns    801176 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801108:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110c:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  801113:	00 
  801114:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80111b:	00 
  80111c:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801123:	e8 88 f0 ff ff       	call   8001b0 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801128:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80112f:	25 07 0e 00 00       	and    $0xe07,%eax
  801134:	89 44 24 10          	mov    %eax,0x10(%esp)
  801138:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80113c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80113f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801143:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801147:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80114a:	89 04 24             	mov    %eax,(%esp)
  80114d:	e8 47 fb ff ff       	call   800c99 <sys_page_map>
  801152:	85 c0                	test   %eax,%eax
  801154:	79 20                	jns    801176 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801156:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115a:	c7 44 24 08 f3 19 80 	movl   $0x8019f3,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801171:	e8 3a f0 ff ff       	call   8001b0 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801176:	46                   	inc    %esi
  801177:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80117d:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801183:	0f 85 5f fe ff ff    	jne    800fe8 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801189:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801198:	ee 
  801199:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80119c:	89 04 24             	mov    %eax,(%esp)
  80119f:	e8 a1 fa ff ff       	call   800c45 <sys_page_alloc>
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	79 20                	jns    8011c8 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  8011a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ac:	c7 44 24 08 df 19 80 	movl   $0x8019df,0x8(%esp)
  8011b3:	00 
  8011b4:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  8011bb:	00 
  8011bc:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8011c3:	e8 e8 ef ff ff       	call   8001b0 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8011c8:	c7 44 24 04 f4 13 80 	movl   $0x8013f4,0x4(%esp)
  8011cf:	00 
  8011d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011d3:	89 04 24             	mov    %eax,(%esp)
  8011d6:	e8 b7 fb ff ff       	call   800d92 <sys_env_set_pgfault_upcall>
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	79 20                	jns    8011ff <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8011df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e3:	c7 44 24 08 b4 19 80 	movl   $0x8019b4,0x8(%esp)
  8011ea:	00 
  8011eb:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8011f2:	00 
  8011f3:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  8011fa:	e8 b1 ef ff ff       	call   8001b0 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8011ff:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801206:	00 
  801207:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80120a:	89 04 24             	mov    %eax,(%esp)
  80120d:	e8 2d fb ff ff       	call   800d3f <sys_env_set_status>
  801212:	85 c0                	test   %eax,%eax
  801214:	79 20                	jns    801236 <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  801216:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121a:	c7 44 24 08 16 1a 80 	movl   $0x801a16,0x8(%esp)
  801221:	00 
  801222:	c7 44 24 04 a6 00 00 	movl   $0xa6,0x4(%esp)
  801229:	00 
  80122a:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  801231:	e8 7a ef ff ff       	call   8001b0 <_panic>

	return child_envid;
}
  801236:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801239:	83 c4 3c             	add    $0x3c,%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <sfork>:

// Challenge!
int
sfork(void)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801247:	c7 44 24 08 2e 1a 80 	movl   $0x801a2e,0x8(%esp)
  80124e:	00 
  80124f:	c7 44 24 04 af 00 00 	movl   $0xaf,0x4(%esp)
  801256:	00 
  801257:	c7 04 24 d4 19 80 00 	movl   $0x8019d4,(%esp)
  80125e:	e8 4d ef ff ff       	call   8001b0 <_panic>
	...

00801264 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 10             	sub    $0x10,%esp
  80126c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80126f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801272:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  801275:	85 c0                	test   %eax,%eax
  801277:	75 05                	jne    80127e <ipc_recv+0x1a>
  801279:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 82 fb ff ff       	call   800e08 <sys_ipc_recv>
	if (from_env_store != NULL)
  801286:	85 db                	test   %ebx,%ebx
  801288:	74 0b                	je     801295 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80128a:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801290:	8b 52 74             	mov    0x74(%edx),%edx
  801293:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801295:	85 f6                	test   %esi,%esi
  801297:	74 0b                	je     8012a4 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  801299:	8b 15 04 20 80 00    	mov    0x802004,%edx
  80129f:	8b 52 78             	mov    0x78(%edx),%edx
  8012a2:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	79 16                	jns    8012be <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8012a8:	85 db                	test   %ebx,%ebx
  8012aa:	74 06                	je     8012b2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8012ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8012b2:	85 f6                	test   %esi,%esi
  8012b4:	74 10                	je     8012c6 <ipc_recv+0x62>
			*perm_store = 0;
  8012b6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8012bc:	eb 08                	jmp    8012c6 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8012be:	a1 04 20 80 00       	mov    0x802004,%eax
  8012c3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	57                   	push   %edi
  8012d1:	56                   	push   %esi
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 1c             	sub    $0x1c,%esp
  8012d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8012dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8012df:	eb 2a                	jmp    80130b <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8012e1:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8012e4:	74 20                	je     801306 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8012e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ea:	c7 44 24 08 44 1a 80 	movl   $0x801a44,0x8(%esp)
  8012f1:	00 
  8012f2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8012f9:	00 
  8012fa:	c7 04 24 6c 1a 80 00 	movl   $0x801a6c,(%esp)
  801301:	e8 aa ee ff ff       	call   8001b0 <_panic>
		sys_yield();
  801306:	e8 1b f9 ff ff       	call   800c26 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80130b:	85 db                	test   %ebx,%ebx
  80130d:	75 07                	jne    801316 <ipc_send+0x49>
  80130f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801314:	eb 02                	jmp    801318 <ipc_send+0x4b>
  801316:	89 d8                	mov    %ebx,%eax
  801318:	8b 55 14             	mov    0x14(%ebp),%edx
  80131b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80131f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801323:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801327:	89 34 24             	mov    %esi,(%esp)
  80132a:	e8 b6 fa ff ff       	call   800de5 <sys_ipc_try_send>
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 ae                	js     8012e1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  801333:	83 c4 1c             	add    $0x1c,%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801342:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801347:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80134e:	89 c2                	mov    %eax,%edx
  801350:	c1 e2 07             	shl    $0x7,%edx
  801353:	29 ca                	sub    %ecx,%edx
  801355:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80135b:	8b 52 50             	mov    0x50(%edx),%edx
  80135e:	39 da                	cmp    %ebx,%edx
  801360:	75 0f                	jne    801371 <ipc_find_env+0x36>
			return envs[i].env_id;
  801362:	c1 e0 07             	shl    $0x7,%eax
  801365:	29 c8                	sub    %ecx,%eax
  801367:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80136c:	8b 40 40             	mov    0x40(%eax),%eax
  80136f:	eb 0c                	jmp    80137d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801371:	40                   	inc    %eax
  801372:	3d 00 04 00 00       	cmp    $0x400,%eax
  801377:	75 ce                	jne    801347 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801379:	66 b8 00 00          	mov    $0x0,%ax
}
  80137d:	5b                   	pop    %ebx
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801386:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80138d:	75 58                	jne    8013e7 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  80138f:	a1 04 20 80 00       	mov    0x802004,%eax
  801394:	8b 40 48             	mov    0x48(%eax),%eax
  801397:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80139e:	00 
  80139f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013a6:	ee 
  8013a7:	89 04 24             	mov    %eax,(%esp)
  8013aa:	e8 96 f8 ff ff       	call   800c45 <sys_page_alloc>
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	74 1c                	je     8013cf <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8013b3:	c7 44 24 08 76 1a 80 	movl   $0x801a76,0x8(%esp)
  8013ba:	00 
  8013bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013c2:	00 
  8013c3:	c7 04 24 8b 1a 80 00 	movl   $0x801a8b,(%esp)
  8013ca:	e8 e1 ed ff ff       	call   8001b0 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8013cf:	a1 04 20 80 00       	mov    0x802004,%eax
  8013d4:	8b 40 48             	mov    0x48(%eax),%eax
  8013d7:	c7 44 24 04 f4 13 80 	movl   $0x8013f4,0x4(%esp)
  8013de:	00 
  8013df:	89 04 24             	mov    %eax,(%esp)
  8013e2:	e8 ab f9 ff ff       	call   800d92 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    
  8013f1:	00 00                	add    %al,(%eax)
	...

008013f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013f5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8013fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013fc:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8013ff:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  801403:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  801405:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  801409:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80140a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  80140d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80140f:	58                   	pop    %eax
	popl %eax
  801410:	58                   	pop    %eax

	// Pop all registers back
	popal
  801411:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  801412:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  801415:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  801416:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801417:	c3                   	ret    

00801418 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801418:	55                   	push   %ebp
  801419:	57                   	push   %edi
  80141a:	56                   	push   %esi
  80141b:	83 ec 10             	sub    $0x10,%esp
  80141e:	8b 74 24 20          	mov    0x20(%esp),%esi
  801422:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801426:	89 74 24 04          	mov    %esi,0x4(%esp)
  80142a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80142e:	89 cd                	mov    %ecx,%ebp
  801430:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801434:	85 c0                	test   %eax,%eax
  801436:	75 2c                	jne    801464 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801438:	39 f9                	cmp    %edi,%ecx
  80143a:	77 68                	ja     8014a4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80143c:	85 c9                	test   %ecx,%ecx
  80143e:	75 0b                	jne    80144b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801440:	b8 01 00 00 00       	mov    $0x1,%eax
  801445:	31 d2                	xor    %edx,%edx
  801447:	f7 f1                	div    %ecx
  801449:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	89 f8                	mov    %edi,%eax
  80144f:	f7 f1                	div    %ecx
  801451:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801453:	89 f0                	mov    %esi,%eax
  801455:	f7 f1                	div    %ecx
  801457:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801459:	89 f0                	mov    %esi,%eax
  80145b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	5e                   	pop    %esi
  801461:	5f                   	pop    %edi
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801464:	39 f8                	cmp    %edi,%eax
  801466:	77 2c                	ja     801494 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801468:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80146b:	83 f6 1f             	xor    $0x1f,%esi
  80146e:	75 4c                	jne    8014bc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801470:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801472:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801477:	72 0a                	jb     801483 <__udivdi3+0x6b>
  801479:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80147d:	0f 87 ad 00 00 00    	ja     801530 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801483:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801488:	89 f0                	mov    %esi,%eax
  80148a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    
  801493:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801494:	31 ff                	xor    %edi,%edi
  801496:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801498:	89 f0                	mov    %esi,%eax
  80149a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    
  8014a3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8014a4:	89 fa                	mov    %edi,%edx
  8014a6:	89 f0                	mov    %esi,%eax
  8014a8:	f7 f1                	div    %ecx
  8014aa:	89 c6                	mov    %eax,%esi
  8014ac:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8014ae:	89 f0                	mov    %esi,%eax
  8014b0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    
  8014b9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8014bc:	89 f1                	mov    %esi,%ecx
  8014be:	d3 e0                	shl    %cl,%eax
  8014c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8014c4:	b8 20 00 00 00       	mov    $0x20,%eax
  8014c9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8014cb:	89 ea                	mov    %ebp,%edx
  8014cd:	88 c1                	mov    %al,%cl
  8014cf:	d3 ea                	shr    %cl,%edx
  8014d1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8014d5:	09 ca                	or     %ecx,%edx
  8014d7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8014db:	89 f1                	mov    %esi,%ecx
  8014dd:	d3 e5                	shl    %cl,%ebp
  8014df:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8014e3:	89 fd                	mov    %edi,%ebp
  8014e5:	88 c1                	mov    %al,%cl
  8014e7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8014e9:	89 fa                	mov    %edi,%edx
  8014eb:	89 f1                	mov    %esi,%ecx
  8014ed:	d3 e2                	shl    %cl,%edx
  8014ef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014f3:	88 c1                	mov    %al,%cl
  8014f5:	d3 ef                	shr    %cl,%edi
  8014f7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8014f9:	89 f8                	mov    %edi,%eax
  8014fb:	89 ea                	mov    %ebp,%edx
  8014fd:	f7 74 24 08          	divl   0x8(%esp)
  801501:	89 d1                	mov    %edx,%ecx
  801503:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801505:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801509:	39 d1                	cmp    %edx,%ecx
  80150b:	72 17                	jb     801524 <__udivdi3+0x10c>
  80150d:	74 09                	je     801518 <__udivdi3+0x100>
  80150f:	89 fe                	mov    %edi,%esi
  801511:	31 ff                	xor    %edi,%edi
  801513:	e9 41 ff ff ff       	jmp    801459 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801518:	8b 54 24 04          	mov    0x4(%esp),%edx
  80151c:	89 f1                	mov    %esi,%ecx
  80151e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801520:	39 c2                	cmp    %eax,%edx
  801522:	73 eb                	jae    80150f <__udivdi3+0xf7>
		{
		  q0--;
  801524:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801527:	31 ff                	xor    %edi,%edi
  801529:	e9 2b ff ff ff       	jmp    801459 <__udivdi3+0x41>
  80152e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801530:	31 f6                	xor    %esi,%esi
  801532:	e9 22 ff ff ff       	jmp    801459 <__udivdi3+0x41>
	...

00801538 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801538:	55                   	push   %ebp
  801539:	57                   	push   %edi
  80153a:	56                   	push   %esi
  80153b:	83 ec 20             	sub    $0x20,%esp
  80153e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801542:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801546:	89 44 24 14          	mov    %eax,0x14(%esp)
  80154a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80154e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801552:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801556:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801558:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80155a:	85 ed                	test   %ebp,%ebp
  80155c:	75 16                	jne    801574 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80155e:	39 f1                	cmp    %esi,%ecx
  801560:	0f 86 a6 00 00 00    	jbe    80160c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801566:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801568:	89 d0                	mov    %edx,%eax
  80156a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80156c:	83 c4 20             	add    $0x20,%esp
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    
  801573:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801574:	39 f5                	cmp    %esi,%ebp
  801576:	0f 87 ac 00 00 00    	ja     801628 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80157c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80157f:	83 f0 1f             	xor    $0x1f,%eax
  801582:	89 44 24 10          	mov    %eax,0x10(%esp)
  801586:	0f 84 a8 00 00 00    	je     801634 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80158c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801590:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801592:	bf 20 00 00 00       	mov    $0x20,%edi
  801597:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80159b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80159f:	89 f9                	mov    %edi,%ecx
  8015a1:	d3 e8                	shr    %cl,%eax
  8015a3:	09 e8                	or     %ebp,%eax
  8015a5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8015a9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015ad:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015b1:	d3 e0                	shl    %cl,%eax
  8015b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8015b7:	89 f2                	mov    %esi,%edx
  8015b9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8015bb:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015bf:	d3 e0                	shl    %cl,%eax
  8015c1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8015c5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8015c9:	89 f9                	mov    %edi,%ecx
  8015cb:	d3 e8                	shr    %cl,%eax
  8015cd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8015cf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8015d1:	89 f2                	mov    %esi,%edx
  8015d3:	f7 74 24 18          	divl   0x18(%esp)
  8015d7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8015d9:	f7 64 24 0c          	mull   0xc(%esp)
  8015dd:	89 c5                	mov    %eax,%ebp
  8015df:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8015e1:	39 d6                	cmp    %edx,%esi
  8015e3:	72 67                	jb     80164c <__umoddi3+0x114>
  8015e5:	74 75                	je     80165c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8015e7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8015eb:	29 e8                	sub    %ebp,%eax
  8015ed:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8015ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8015f3:	d3 e8                	shr    %cl,%eax
  8015f5:	89 f2                	mov    %esi,%edx
  8015f7:	89 f9                	mov    %edi,%ecx
  8015f9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8015fb:	09 d0                	or     %edx,%eax
  8015fd:	89 f2                	mov    %esi,%edx
  8015ff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801603:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801605:	83 c4 20             	add    $0x20,%esp
  801608:	5e                   	pop    %esi
  801609:	5f                   	pop    %edi
  80160a:	5d                   	pop    %ebp
  80160b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80160c:	85 c9                	test   %ecx,%ecx
  80160e:	75 0b                	jne    80161b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801610:	b8 01 00 00 00       	mov    $0x1,%eax
  801615:	31 d2                	xor    %edx,%edx
  801617:	f7 f1                	div    %ecx
  801619:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80161b:	89 f0                	mov    %esi,%eax
  80161d:	31 d2                	xor    %edx,%edx
  80161f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801621:	89 f8                	mov    %edi,%eax
  801623:	e9 3e ff ff ff       	jmp    801566 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801628:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80162a:	83 c4 20             	add    $0x20,%esp
  80162d:	5e                   	pop    %esi
  80162e:	5f                   	pop    %edi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    
  801631:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801634:	39 f5                	cmp    %esi,%ebp
  801636:	72 04                	jb     80163c <__umoddi3+0x104>
  801638:	39 f9                	cmp    %edi,%ecx
  80163a:	77 06                	ja     801642 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80163c:	89 f2                	mov    %esi,%edx
  80163e:	29 cf                	sub    %ecx,%edi
  801640:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801642:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801644:	83 c4 20             	add    $0x20,%esp
  801647:	5e                   	pop    %esi
  801648:	5f                   	pop    %edi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    
  80164b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80164c:	89 d1                	mov    %edx,%ecx
  80164e:	89 c5                	mov    %eax,%ebp
  801650:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801654:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801658:	eb 8d                	jmp    8015e7 <__umoddi3+0xaf>
  80165a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80165c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801660:	72 ea                	jb     80164c <__umoddi3+0x114>
  801662:	89 f1                	mov    %esi,%ecx
  801664:	eb 81                	jmp    8015e7 <__umoddi3+0xaf>
