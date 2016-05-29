
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003d:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  800044:	e8 df 02 00 00       	call   800328 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 bd 22 00 00       	call   802311 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 ee 2a 80 	movl   $0x802aee,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 f7 2a 80 00 	movl   $0x802af7,(%esp)
  800073:	e8 b8 01 00 00       	call   800230 <_panic>
	if ((r = fork()) < 0)
  800078:	e8 42 10 00 00       	call   8010bf <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 0c 2b 80 	movl   $0x802b0c,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 f7 2a 80 00 	movl   $0x802af7,(%esp)
  80009e:	e8 8d 01 00 00       	call   800230 <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 5d                	jne    800104 <umain+0xd0>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 b4 14 00 00       	call   801566 <close>
		for (i = 0; i < 200; i++) {
  8000b2:	be 00 00 00 00       	mov    $0x0,%esi
			if (i % 10 == 0)
  8000b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8000bc:	89 f0                	mov    %esi,%eax
  8000be:	99                   	cltd   
  8000bf:	f7 fb                	idiv   %ebx
  8000c1:	85 d2                	test   %edx,%edx
  8000c3:	75 10                	jne    8000d5 <umain+0xa1>
				cprintf("%d.", i);
  8000c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c9:	c7 04 24 15 2b 80 00 	movl   $0x802b15,(%esp)
  8000d0:	e8 53 02 00 00       	call   800328 <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 d3 14 00 00       	call   8015b7 <dup>
			sys_yield();
  8000e4:	e8 bd 0b 00 00       	call   800ca6 <sys_yield>
			close(10);
  8000e9:	89 1c 24             	mov    %ebx,(%esp)
  8000ec:	e8 75 14 00 00       	call   801566 <close>
			sys_yield();
  8000f1:	e8 b0 0b 00 00       	call   800ca6 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000f6:	46                   	inc    %esi
  8000f7:	81 fe c8 00 00 00    	cmp    $0xc8,%esi
  8000fd:	75 bd                	jne    8000bc <umain+0x88>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000ff:	e8 18 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800104:	89 fb                	mov    %edi,%ebx
  800106:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80010c:	c1 e3 07             	shl    $0x7,%ebx
  80010f:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (kid->env_status == ENV_RUNNABLE)
  800115:	eb 28                	jmp    80013f <umain+0x10b>
		if (pipeisclosed(p[0]) != 0) {
  800117:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80011a:	89 04 24             	mov    %eax,(%esp)
  80011d:	e8 5f 23 00 00       	call   802481 <pipeisclosed>
  800122:	85 c0                	test   %eax,%eax
  800124:	74 19                	je     80013f <umain+0x10b>
			cprintf("\nRACE: pipe appears closed\n");
  800126:	c7 04 24 19 2b 80 00 	movl   $0x802b19,(%esp)
  80012d:	e8 f6 01 00 00       	call   800328 <cprintf>
			sys_env_destroy(r);
  800132:	89 3c 24             	mov    %edi,(%esp)
  800135:	e8 fb 0a 00 00       	call   800c35 <sys_env_destroy>
			exit();
  80013a:	e8 dd 00 00 00       	call   80021c <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  80013f:	8b 43 54             	mov    0x54(%ebx),%eax
  800142:	83 f8 02             	cmp    $0x2,%eax
  800145:	74 d0                	je     800117 <umain+0xe3>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800147:	c7 04 24 35 2b 80 00 	movl   $0x802b35,(%esp)
  80014e:	e8 d5 01 00 00       	call   800328 <cprintf>
	if (pipeisclosed(p[0]))
  800153:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800156:	89 04 24             	mov    %eax,(%esp)
  800159:	e8 23 23 00 00       	call   802481 <pipeisclosed>
  80015e:	85 c0                	test   %eax,%eax
  800160:	74 1c                	je     80017e <umain+0x14a>
		panic("somehow the other end of p[0] got closed!");
  800162:	c7 44 24 08 c4 2a 80 	movl   $0x802ac4,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 f7 2a 80 00 	movl   $0x802af7,(%esp)
  800179:	e8 b2 00 00 00       	call   800230 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80017e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800188:	89 04 24             	mov    %eax,(%esp)
  80018b:	e8 9e 12 00 00       	call   80142e <fd_lookup>
  800190:	85 c0                	test   %eax,%eax
  800192:	79 20                	jns    8001b4 <umain+0x180>
		panic("cannot look up p[0]: %e", r);
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	c7 44 24 08 4b 2b 80 	movl   $0x802b4b,0x8(%esp)
  80019f:	00 
  8001a0:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001a7:	00 
  8001a8:	c7 04 24 f7 2a 80 00 	movl   $0x802af7,(%esp)
  8001af:	e8 7c 00 00 00       	call   800230 <_panic>
	(void) fd2data(fd);
  8001b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 01 12 00 00       	call   8013c0 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 63 2b 80 00 	movl   $0x802b63,(%esp)
  8001c6:	e8 5d 01 00 00       	call   800328 <cprintf>
}
  8001cb:	83 c4 2c             	add    $0x2c,%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    
	...

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 10             	sub    $0x10,%esp
  8001dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8001df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e2:	e8 a0 0a 00 00       	call   800c87 <sys_getenvid>
  8001e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ec:	c1 e0 07             	shl    $0x7,%eax
  8001ef:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f4:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f9:	85 f6                	test   %esi,%esi
  8001fb:	7e 07                	jle    800204 <libmain+0x30>
		binaryname = argv[0];
  8001fd:	8b 03                	mov    (%ebx),%eax
  8001ff:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800204:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800208:	89 34 24             	mov    %esi,(%esp)
  80020b:	e8 24 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800210:	e8 07 00 00 00       	call   80021c <exit>
}
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800229:	e8 07 0a 00 00       	call   800c35 <sys_env_destroy>
}
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800241:	e8 41 0a 00 00       	call   800c87 <sys_getenvid>
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 54 24 10          	mov    %edx,0x10(%esp)
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	c7 04 24 84 2b 80 00 	movl   $0x802b84,(%esp)
  800263:	e8 c0 00 00 00       	call   800328 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800268:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026c:	8b 45 10             	mov    0x10(%ebp),%eax
  80026f:	89 04 24             	mov    %eax,(%esp)
  800272:	e8 50 00 00 00       	call   8002c7 <vcprintf>
	cprintf("\n");
  800277:	c7 04 24 d8 30 80 00 	movl   $0x8030d8,(%esp)
  80027e:	e8 a5 00 00 00       	call   800328 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800283:	cc                   	int3   
  800284:	eb fd                	jmp    800283 <_panic+0x53>
	...

00800288 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	53                   	push   %ebx
  80028c:	83 ec 14             	sub    $0x14,%esp
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800292:	8b 03                	mov    (%ebx),%eax
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  800297:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029b:	40                   	inc    %eax
  80029c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a3:	75 19                	jne    8002be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ac:	00 
  8002ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b0:	89 04 24             	mov    %eax,(%esp)
  8002b3:	e8 40 09 00 00       	call   800bf8 <sys_cputs>
		b->idx = 0;
  8002b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002be:	ff 43 04             	incl   0x4(%ebx)
}
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d7:	00 00 00 
	b.cnt = 0;
  8002da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	c7 04 24 88 02 80 00 	movl   $0x800288,(%esp)
  800303:	e8 82 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800308:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80030e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800312:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 d8 08 00 00       	call   800bf8 <sys_cputs>

	return b.cnt;
}
  800320:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80032e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800331:	89 44 24 04          	mov    %eax,0x4(%esp)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 87 ff ff ff       	call   8002c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    
	...

00800344 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 3c             	sub    $0x3c,%esp
  80034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800350:	89 d7                	mov    %edx,%edi
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800361:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800364:	85 c0                	test   %eax,%eax
  800366:	75 08                	jne    800370 <printnum+0x2c>
  800368:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036e:	77 57                	ja     8003c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800370:	89 74 24 10          	mov    %esi,0x10(%esp)
  800374:	4b                   	dec    %ebx
  800375:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800379:	8b 45 10             	mov    0x10(%ebp),%eax
  80037c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800380:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800384:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	e8 9e 24 00 00       	call   802840 <__udivdi3>
  8003a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b1:	89 fa                	mov    %edi,%edx
  8003b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003b6:	e8 89 ff ff ff       	call   800344 <printnum>
  8003bb:	eb 0f                	jmp    8003cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	89 34 24             	mov    %esi,(%esp)
  8003c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	4b                   	dec    %ebx
  8003c8:	85 db                	test   %ebx,%ebx
  8003ca:	7f f1                	jg     8003bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e2:	00 
  8003e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	e8 6b 25 00 00       	call   802960 <__umoddi3>
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	0f be 80 a7 2b 80 00 	movsbl 0x802ba7(%eax),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800406:	83 c4 3c             	add    $0x3c,%esp
  800409:	5b                   	pop    %ebx
  80040a:	5e                   	pop    %esi
  80040b:	5f                   	pop    %edi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800411:	83 fa 01             	cmp    $0x1,%edx
  800414:	7e 0e                	jle    800424 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800416:	8b 10                	mov    (%eax),%edx
  800418:	8d 4a 08             	lea    0x8(%edx),%ecx
  80041b:	89 08                	mov    %ecx,(%eax)
  80041d:	8b 02                	mov    (%edx),%eax
  80041f:	8b 52 04             	mov    0x4(%edx),%edx
  800422:	eb 22                	jmp    800446 <getuint+0x38>
	else if (lflag)
  800424:	85 d2                	test   %edx,%edx
  800426:	74 10                	je     800438 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
  800436:	eb 0e                	jmp    800446 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800438:	8b 10                	mov    (%eax),%edx
  80043a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80043d:	89 08                	mov    %ecx,(%eax)
  80043f:	8b 02                	mov    (%edx),%eax
  800441:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80044e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800451:	8b 10                	mov    (%eax),%edx
  800453:	3b 50 04             	cmp    0x4(%eax),%edx
  800456:	73 08                	jae    800460 <sprintputch+0x18>
		*b->buf++ = ch;
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	88 0a                	mov    %cl,(%edx)
  80045d:	42                   	inc    %edx
  80045e:	89 10                	mov    %edx,(%eax)
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800468:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80046b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046f:	8b 45 10             	mov    0x10(%ebp),%eax
  800472:	89 44 24 08          	mov    %eax,0x8(%esp)
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 02 00 00 00       	call   80048a <vprintfmt>
	va_end(ap);
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 4c             	sub    $0x4c,%esp
  800493:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800496:	8b 75 10             	mov    0x10(%ebp),%esi
  800499:	eb 12                	jmp    8004ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80049b:	85 c0                	test   %eax,%eax
  80049d:	0f 84 6b 03 00 00    	je     80080e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ad:	0f b6 06             	movzbl (%esi),%eax
  8004b0:	46                   	inc    %esi
  8004b1:	83 f8 25             	cmp    $0x25,%eax
  8004b4:	75 e5                	jne    80049b <vprintfmt+0x11>
  8004b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	eb 26                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004db:	eb 1d                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004e4:	eb 14                	jmp    8004fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	0f b6 06             	movzbl (%esi),%eax
  8004fd:	8d 56 01             	lea    0x1(%esi),%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	8a 16                	mov    (%esi),%dl
  800505:	83 ea 23             	sub    $0x23,%edx
  800508:	80 fa 55             	cmp    $0x55,%dl
  80050b:	0f 87 e1 02 00 00    	ja     8007f2 <vprintfmt+0x368>
  800511:	0f b6 d2             	movzbl %dl,%edx
  800514:	ff 24 95 e0 2c 80 00 	jmp    *0x802ce0(,%edx,4)
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80051e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800523:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800526:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80052a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80052d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800530:	83 fa 09             	cmp    $0x9,%edx
  800533:	77 2a                	ja     80055f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800535:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800536:	eb eb                	jmp    800523 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800546:	eb 17                	jmp    80055f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800548:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054c:	78 98                	js     8004e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800551:	eb a7                	jmp    8004fa <vprintfmt+0x70>
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800556:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80055d:	eb 9b                	jmp    8004fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80055f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800563:	79 95                	jns    8004fa <vprintfmt+0x70>
  800565:	eb 8b                	jmp    8004f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800567:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80056b:	eb 8d                	jmp    8004fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800585:	e9 23 ff ff ff       	jmp    8004ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 50 04             	lea    0x4(%eax),%edx
  800590:	89 55 14             	mov    %edx,0x14(%ebp)
  800593:	8b 00                	mov    (%eax),%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	79 02                	jns    80059b <vprintfmt+0x111>
  800599:	f7 d8                	neg    %eax
  80059b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059d:	83 f8 11             	cmp    $0x11,%eax
  8005a0:	7f 0b                	jg     8005ad <vprintfmt+0x123>
  8005a2:	8b 04 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	75 23                	jne    8005d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b1:	c7 44 24 08 bf 2b 80 	movl   $0x802bbf,0x8(%esp)
  8005b8:	00 
  8005b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	89 04 24             	mov    %eax,(%esp)
  8005c3:	e8 9a fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005cb:	e9 dd fe ff ff       	jmp    8004ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d4:	c7 44 24 08 6d 30 80 	movl   $0x80306d,0x8(%esp)
  8005db:	00 
  8005dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005e3:	89 14 24             	mov    %edx,(%esp)
  8005e6:	e8 77 fe ff ff       	call   800462 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ee:	e9 ba fe ff ff       	jmp    8004ad <vprintfmt+0x23>
  8005f3:	89 f9                	mov    %edi,%ecx
  8005f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 30                	mov    (%eax),%esi
  800606:	85 f6                	test   %esi,%esi
  800608:	75 05                	jne    80060f <vprintfmt+0x185>
				p = "(null)";
  80060a:	be b8 2b 80 00       	mov    $0x802bb8,%esi
			if (width > 0 && padc != '-')
  80060f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800613:	0f 8e 84 00 00 00    	jle    80069d <vprintfmt+0x213>
  800619:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80061d:	74 7e                	je     80069d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 8b 02 00 00       	call   8008b6 <strnlen>
  80062b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80062e:	29 c2                	sub    %eax,%edx
  800630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800633:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800637:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80063a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80063d:	89 de                	mov    %ebx,%esi
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	eb 0b                	jmp    800650 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064f:	4b                   	dec    %ebx
  800650:	85 db                	test   %ebx,%ebx
  800652:	7f f1                	jg     800645 <vprintfmt+0x1bb>
  800654:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800657:	89 f3                	mov    %esi,%ebx
  800659:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80065c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	79 05                	jns    800668 <vprintfmt+0x1de>
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066b:	29 c2                	sub    %eax,%edx
  80066d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800670:	eb 2b                	jmp    80069d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800672:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800676:	74 18                	je     800690 <vprintfmt+0x206>
  800678:	8d 50 e0             	lea    -0x20(%eax),%edx
  80067b:	83 fa 5e             	cmp    $0x5e,%edx
  80067e:	76 10                	jbe    800690 <vprintfmt+0x206>
					putch('?', putdat);
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80068b:	ff 55 08             	call   *0x8(%ebp)
  80068e:	eb 0a                	jmp    80069a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800690:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800694:	89 04 24             	mov    %eax,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	ff 4d e4             	decl   -0x1c(%ebp)
  80069d:	0f be 06             	movsbl (%esi),%eax
  8006a0:	46                   	inc    %esi
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 21                	je     8006c6 <vprintfmt+0x23c>
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	78 c9                	js     800672 <vprintfmt+0x1e8>
  8006a9:	4f                   	dec    %edi
  8006aa:	79 c6                	jns    800672 <vprintfmt+0x1e8>
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	89 de                	mov    %ebx,%esi
  8006b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006b4:	eb 18                	jmp    8006ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006c3:	4b                   	dec    %ebx
  8006c4:	eb 08                	jmp    8006ce <vprintfmt+0x244>
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	89 de                	mov    %ebx,%esi
  8006cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f e4                	jg     8006b6 <vprintfmt+0x22c>
  8006d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006da:	e9 ce fd ff ff       	jmp    8004ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7e 10                	jle    8006f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 08             	lea    0x8(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 30                	mov    (%eax),%esi
  8006ef:	8b 78 04             	mov    0x4(%eax),%edi
  8006f2:	eb 26                	jmp    80071a <vprintfmt+0x290>
	else if (lflag)
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	74 12                	je     80070a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 04             	lea    0x4(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	89 f7                	mov    %esi,%edi
  800705:	c1 ff 1f             	sar    $0x1f,%edi
  800708:	eb 10                	jmp    80071a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 30                	mov    (%eax),%esi
  800715:	89 f7                	mov    %esi,%edi
  800717:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	85 ff                	test   %edi,%edi
  80071c:	78 0a                	js     800728 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800723:	e9 8c 00 00 00       	jmp    8007b4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800728:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800733:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800736:	f7 de                	neg    %esi
  800738:	83 d7 00             	adc    $0x0,%edi
  80073b:	f7 df                	neg    %edi
			}
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	eb 70                	jmp    8007b4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 c0 fc ff ff       	call   80040e <getuint>
  80074e:	89 c6                	mov    %eax,%esi
  800750:	89 d7                	mov    %edx,%edi
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800757:	eb 5b                	jmp    8007b4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800759:	89 ca                	mov    %ecx,%edx
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
  80075e:	e8 ab fc ff ff       	call   80040e <getuint>
  800763:	89 c6                	mov    %eax,%esi
  800765:	89 d7                	mov    %edx,%edi
			base = 8;
  800767:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80076c:	eb 46                	jmp    8007b4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80076e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800772:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800779:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 50 04             	lea    0x4(%eax),%edx
  800790:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800793:	8b 30                	mov    (%eax),%esi
  800795:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80079a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80079f:	eb 13                	jmp    8007b4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a1:	89 ca                	mov    %ecx,%edx
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a6:	e8 63 fc ff ff       	call   80040e <getuint>
  8007ab:	89 c6                	mov    %eax,%esi
  8007ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8007af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c7:	89 34 24             	mov    %esi,(%esp)
  8007ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ce:	89 da                	mov    %ebx,%edx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	e8 6c fb ff ff       	call   800344 <printnum>
			break;
  8007d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007db:	e9 cd fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ed:	e9 bb fc ff ff       	jmp    8004ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800800:	eb 01                	jmp    800803 <vprintfmt+0x379>
  800802:	4e                   	dec    %esi
  800803:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800807:	75 f9                	jne    800802 <vprintfmt+0x378>
  800809:	e9 9f fc ff ff       	jmp    8004ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80080e:	83 c4 4c             	add    $0x4c,%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 28             	sub    $0x28,%esp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800822:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800825:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800829:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 30                	je     800867 <vsnprintf+0x51>
  800837:	85 d2                	test   %edx,%edx
  800839:	7e 33                	jle    80086e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800842:	8b 45 10             	mov    0x10(%ebp),%eax
  800845:	89 44 24 08          	mov    %eax,0x8(%esp)
  800849:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	c7 04 24 48 04 80 00 	movl   $0x800448,(%esp)
  800857:	e8 2e fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800865:	eb 0c                	jmp    800873 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800867:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086c:	eb 05                	jmp    800873 <vsnprintf+0x5d>
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800882:	8b 45 10             	mov    0x10(%ebp),%eax
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	89 04 24             	mov    %eax,(%esp)
  800896:	e8 7b ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
  80089d:	00 00                	add    %al,(%eax)
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	eb 01                	jmp    8008ae <strlen+0xe>
		n++;
  8008ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b2:	75 f9                	jne    8008ad <strlen+0xd>
		n++;
	return n;
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 01                	jmp    8008c7 <strnlen+0x11>
		n++;
  8008c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c7:	39 d0                	cmp    %edx,%eax
  8008c9:	74 06                	je     8008d1 <strnlen+0x1b>
  8008cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008cf:	75 f5                	jne    8008c6 <strnlen+0x10>
		n++;
	return n;
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e8:	42                   	inc    %edx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	75 f5                	jne    8008e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fa:	89 1c 24             	mov    %ebx,(%esp)
  8008fd:	e8 9e ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 54 24 04          	mov    %edx,0x4(%esp)
  800909:	01 d8                	add    %ebx,%eax
  80090b:	89 04 24             	mov    %eax,(%esp)
  80090e:	e8 c0 ff ff ff       	call   8008d3 <strcpy>
	return dst;
}
  800913:	89 d8                	mov    %ebx,%eax
  800915:	83 c4 08             	add    $0x8,%esp
  800918:	5b                   	pop    %ebx
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	eb 0c                	jmp    80093c <strncpy+0x21>
		*dst++ = *src;
  800930:	8a 1a                	mov    (%edx),%bl
  800932:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 3a 01             	cmpb   $0x1,(%edx)
  800938:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	41                   	inc    %ecx
  80093c:	39 f1                	cmp    %esi,%ecx
  80093e:	75 f0                	jne    800930 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800952:	85 d2                	test   %edx,%edx
  800954:	75 0a                	jne    800960 <strlcpy+0x1c>
  800956:	89 f0                	mov    %esi,%eax
  800958:	eb 1a                	jmp    800974 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095a:	88 18                	mov    %bl,(%eax)
  80095c:	40                   	inc    %eax
  80095d:	41                   	inc    %ecx
  80095e:	eb 02                	jmp    800962 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800960:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800962:	4a                   	dec    %edx
  800963:	74 0a                	je     80096f <strlcpy+0x2b>
  800965:	8a 19                	mov    (%ecx),%bl
  800967:	84 db                	test   %bl,%bl
  800969:	75 ef                	jne    80095a <strlcpy+0x16>
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	eb 02                	jmp    800971 <strlcpy+0x2d>
  80096f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800971:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800974:	29 f0                	sub    %esi,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800983:	eb 02                	jmp    800987 <strcmp+0xd>
		p++, q++;
  800985:	41                   	inc    %ecx
  800986:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800987:	8a 01                	mov    (%ecx),%al
  800989:	84 c0                	test   %al,%al
  80098b:	74 04                	je     800991 <strcmp+0x17>
  80098d:	3a 02                	cmp    (%edx),%al
  80098f:	74 f4                	je     800985 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009a8:	eb 03                	jmp    8009ad <strncmp+0x12>
		n--, p++, q++;
  8009aa:	4a                   	dec    %edx
  8009ab:	40                   	inc    %eax
  8009ac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	74 14                	je     8009c5 <strncmp+0x2a>
  8009b1:	8a 18                	mov    (%eax),%bl
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	74 04                	je     8009bb <strncmp+0x20>
  8009b7:	3a 19                	cmp    (%ecx),%bl
  8009b9:	74 ef                	je     8009aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 00             	movzbl (%eax),%eax
  8009be:	0f b6 11             	movzbl (%ecx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
  8009c3:	eb 05                	jmp    8009ca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d6:	eb 05                	jmp    8009dd <strchr+0x10>
		if (*s == c)
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	74 0c                	je     8009e8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009dc:	40                   	inc    %eax
  8009dd:	8a 10                	mov    (%eax),%dl
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	75 f5                	jne    8009d8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009f3:	eb 05                	jmp    8009fa <strfind+0x10>
		if (*s == c)
  8009f5:	38 ca                	cmp    %cl,%dl
  8009f7:	74 07                	je     800a00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f9:	40                   	inc    %eax
  8009fa:	8a 10                	mov    (%eax),%dl
  8009fc:	84 d2                	test   %dl,%dl
  8009fe:	75 f5                	jne    8009f5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	57                   	push   %edi
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 30                	je     800a45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 25                	jne    800a42 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 20                	jne    800a42 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a25:	89 d3                	mov    %edx,%ebx
  800a27:	c1 e3 08             	shl    $0x8,%ebx
  800a2a:	89 d6                	mov    %edx,%esi
  800a2c:	c1 e6 18             	shl    $0x18,%esi
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	c1 e0 10             	shl    $0x10,%eax
  800a34:	09 f0                	or     %esi,%eax
  800a36:	09 d0                	or     %edx,%eax
  800a38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a3d:	fc                   	cld    
  800a3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a40:	eb 03                	jmp    800a45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a42:	fc                   	cld    
  800a43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 34                	jae    800a92 <memmove+0x46>
  800a5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a61:	39 d0                	cmp    %edx,%eax
  800a63:	73 2d                	jae    800a92 <memmove+0x46>
		s += n;
		d += n;
  800a65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	f6 c2 03             	test   $0x3,%dl
  800a6b:	75 1b                	jne    800a88 <memmove+0x3c>
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 13                	jne    800a88 <memmove+0x3c>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 0e                	jne    800a88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 07                	jmp    800a8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a88:	4f                   	dec    %edi
  800a89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8c:	fd                   	std    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8f:	fc                   	cld    
  800a90:	eb 20                	jmp    800ab2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a98:	75 13                	jne    800aad <memmove+0x61>
  800a9a:	a8 03                	test   $0x3,%al
  800a9c:	75 0f                	jne    800aad <memmove+0x61>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 0a                	jne    800aad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aa3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aab:	eb 05                	jmp    800ab2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aad:	89 c7                	mov    %eax,%edi
  800aaf:	fc                   	cld    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800abc:	8b 45 10             	mov    0x10(%ebp),%eax
  800abf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	89 04 24             	mov    %eax,(%esp)
  800ad0:	e8 77 ff ff ff       	call   800a4c <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	57                   	push   %edi
  800adb:	56                   	push   %esi
  800adc:	53                   	push   %ebx
  800add:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  800aeb:	eb 16                	jmp    800b03 <memcmp+0x2c>
		if (*s1 != *s2)
  800aed:	8a 04 17             	mov    (%edi,%edx,1),%al
  800af0:	42                   	inc    %edx
  800af1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800af5:	38 c8                	cmp    %cl,%al
  800af7:	74 0a                	je     800b03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 c9             	movzbl %cl,%ecx
  800aff:	29 c8                	sub    %ecx,%eax
  800b01:	eb 09                	jmp    800b0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b03:	39 da                	cmp    %ebx,%edx
  800b05:	75 e6                	jne    800aed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1f:	eb 05                	jmp    800b26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b21:	38 08                	cmp    %cl,(%eax)
  800b23:	74 05                	je     800b2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b25:	40                   	inc    %eax
  800b26:	39 d0                	cmp    %edx,%eax
  800b28:	72 f7                	jb     800b21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	eb 01                	jmp    800b3b <strtol+0xf>
		s++;
  800b3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3b:	8a 02                	mov    (%edx),%al
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f9                	je     800b3a <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f5                	je     800b3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 08                	jne    800b51 <strtol+0x25>
		s++;
  800b49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4f:	eb 13                	jmp    800b64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b51:	3c 2d                	cmp    $0x2d,%al
  800b53:	75 0a                	jne    800b5f <strtol+0x33>
		s++, neg = 1;
  800b55:	8d 52 01             	lea    0x1(%edx),%edx
  800b58:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5d:	eb 05                	jmp    800b64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	74 05                	je     800b6d <strtol+0x41>
  800b68:	83 fb 10             	cmp    $0x10,%ebx
  800b6b:	75 28                	jne    800b95 <strtol+0x69>
  800b6d:	8a 02                	mov    (%edx),%al
  800b6f:	3c 30                	cmp    $0x30,%al
  800b71:	75 10                	jne    800b83 <strtol+0x57>
  800b73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b77:	75 0a                	jne    800b83 <strtol+0x57>
		s += 2, base = 16;
  800b79:	83 c2 02             	add    $0x2,%edx
  800b7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b81:	eb 12                	jmp    800b95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	75 0e                	jne    800b95 <strtol+0x69>
  800b87:	3c 30                	cmp    $0x30,%al
  800b89:	75 05                	jne    800b90 <strtol+0x64>
		s++, base = 8;
  800b8b:	42                   	inc    %edx
  800b8c:	b3 08                	mov    $0x8,%bl
  800b8e:	eb 05                	jmp    800b95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9c:	8a 0a                	mov    (%edx),%cl
  800b9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba1:	80 fb 09             	cmp    $0x9,%bl
  800ba4:	77 08                	ja     800bae <strtol+0x82>
			dig = *s - '0';
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 30             	sub    $0x30,%ecx
  800bac:	eb 1e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bb1:	80 fb 19             	cmp    $0x19,%bl
  800bb4:	77 08                	ja     800bbe <strtol+0x92>
			dig = *s - 'a' + 10;
  800bb6:	0f be c9             	movsbl %cl,%ecx
  800bb9:	83 e9 57             	sub    $0x57,%ecx
  800bbc:	eb 0e                	jmp    800bcc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bc1:	80 fb 19             	cmp    $0x19,%bl
  800bc4:	77 12                	ja     800bd8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bc6:	0f be c9             	movsbl %cl,%ecx
  800bc9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcc:	39 f1                	cmp    %esi,%ecx
  800bce:	7d 0c                	jge    800bdc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bd0:	42                   	inc    %edx
  800bd1:	0f af c6             	imul   %esi,%eax
  800bd4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bd6:	eb c4                	jmp    800b9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bd8:	89 c1                	mov    %eax,%ecx
  800bda:	eb 02                	jmp    800bde <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be2:	74 05                	je     800be9 <strtol+0xbd>
		*endptr = (char *) s;
  800be4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be9:	85 ff                	test   %edi,%edi
  800beb:	74 04                	je     800bf1 <strtol+0xc5>
  800bed:	89 c8                	mov    %ecx,%eax
  800bef:	f7 d8                	neg    %eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
	...

00800bf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	89 c6                	mov    %eax,%esi
  800c0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c21:	b8 01 00 00 00       	mov    $0x1,%eax
  800c26:	89 d1                	mov    %edx,%ecx
  800c28:	89 d3                	mov    %edx,%ebx
  800c2a:	89 d7                	mov    %edx,%edi
  800c2c:	89 d6                	mov    %edx,%esi
  800c2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c43:	b8 03 00 00 00       	mov    $0x3,%eax
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	89 cb                	mov    %ecx,%ebx
  800c4d:	89 cf                	mov    %ecx,%edi
  800c4f:	89 ce                	mov    %ecx,%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 28                	jle    800c7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c62:	00 
  800c63:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800c6a:	00 
  800c6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c72:	00 
  800c73:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800c7a:	e8 b1 f5 ff ff       	call   800230 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	83 c4 2c             	add    $0x2c,%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 02 00 00 00       	mov    $0x2,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_yield>:

void
sys_yield(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 f7                	mov    %esi,%edi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 28                	jle    800d11 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ced:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d04:	00 
  800d05:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800d0c:	e8 1f f5 ff ff       	call   800230 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d11:	83 c4 2c             	add    $0x2c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	b8 05 00 00 00       	mov    $0x5,%eax
  800d27:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 28                	jle    800d64 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d40:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d47:	00 
  800d48:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800d4f:	00 
  800d50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d57:	00 
  800d58:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800d5f:	e8 cc f4 ff ff       	call   800230 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d64:	83 c4 2c             	add    $0x2c,%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 28                	jle    800db7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800da2:	00 
  800da3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800daa:	00 
  800dab:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800db2:	e8 79 f4 ff ff       	call   800230 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	83 c4 2c             	add    $0x2c,%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 28                	jle    800e0a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ded:	00 
  800dee:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800df5:	00 
  800df6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfd:	00 
  800dfe:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800e05:	e8 26 f4 ff ff       	call   800230 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0a:	83 c4 2c             	add    $0x2c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 09 00 00 00       	mov    $0x9,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 28                	jle    800e5d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e39:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e40:	00 
  800e41:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800e48:	00 
  800e49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e50:	00 
  800e51:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800e58:	e8 d3 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5d:	83 c4 2c             	add    $0x2c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	57                   	push   %edi
  800e69:	56                   	push   %esi
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 df                	mov    %ebx,%edi
  800e80:	89 de                	mov    %ebx,%esi
  800e82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e84:	85 c0                	test   %eax,%eax
  800e86:	7e 28                	jle    800eb0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e93:	00 
  800e94:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea3:	00 
  800ea4:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800eab:	e8 80 f3 ff ff       	call   800230 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb0:	83 c4 2c             	add    $0x2c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	be 00 00 00 00       	mov    $0x0,%esi
  800ec3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed6:	5b                   	pop    %ebx
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 cb                	mov    %ecx,%ebx
  800ef3:	89 cf                	mov    %ecx,%edi
  800ef5:	89 ce                	mov    %ecx,%esi
  800ef7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7e 28                	jle    800f25 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f01:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f08:	00 
  800f09:	c7 44 24 08 a7 2e 80 	movl   $0x802ea7,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  800f20:	e8 0b f3 ff ff       	call   800230 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f25:	83 c4 2c             	add    $0x2c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f3d:	89 d1                	mov    %edx,%ecx
  800f3f:	89 d3                	mov    %edx,%ebx
  800f41:	89 d7                	mov    %edx,%edi
  800f43:	89 d6                	mov    %edx,%esi
  800f45:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f57:	b8 10 00 00 00       	mov    $0x10,%eax
  800f5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f62:	89 df                	mov    %ebx,%edi
  800f64:	89 de                	mov    %ebx,%esi
  800f66:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f78:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	89 df                	mov    %ebx,%edi
  800f85:	89 de                	mov    %ebx,%esi
  800f87:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f99:	b8 11 00 00 00       	mov    $0x11,%eax
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	89 cb                	mov    %ecx,%ebx
  800fa3:	89 cf                	mov    %ecx,%edi
  800fa5:	89 ce                	mov    %ecx,%esi
  800fa7:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800fa9:	5b                   	pop    %ebx
  800faa:	5e                   	pop    %esi
  800fab:	5f                   	pop    %edi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    
	...

00800fb0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 24             	sub    $0x24,%esp
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fba:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800fbc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fc0:	75 20                	jne    800fe2 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800fc2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fc6:	c7 44 24 08 d4 2e 80 	movl   $0x802ed4,0x8(%esp)
  800fcd:	00 
  800fce:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800fd5:	00 
  800fd6:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  800fdd:	e8 4e f2 ff ff       	call   800230 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fe2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800fe8:	89 d8                	mov    %ebx,%eax
  800fea:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff4:	f6 c4 08             	test   $0x8,%ah
  800ff7:	75 1c                	jne    801015 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800ff9:	c7 44 24 08 04 2f 80 	movl   $0x802f04,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  801010:	e8 1b f2 ff ff       	call   800230 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801015:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80101c:	00 
  80101d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801024:	00 
  801025:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102c:	e8 94 fc ff ff       	call   800cc5 <sys_page_alloc>
  801031:	85 c0                	test   %eax,%eax
  801033:	79 20                	jns    801055 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801035:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801039:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  801040:	00 
  801041:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801048:	00 
  801049:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  801050:	e8 db f1 ff ff       	call   800230 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801055:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80105c:	00 
  80105d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801061:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801068:	e8 df f9 ff ff       	call   800a4c <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  80106d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801074:	00 
  801075:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801079:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801090:	e8 84 fc ff ff       	call   800d19 <sys_page_map>
  801095:	85 c0                	test   %eax,%eax
  801097:	79 20                	jns    8010b9 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801099:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80109d:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  8010b4:	e8 77 f1 ff ff       	call   800230 <_panic>

}
  8010b9:	83 c4 24             	add    $0x24,%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	57                   	push   %edi
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  8010c8:	c7 04 24 b0 0f 80 00 	movl   $0x800fb0,(%esp)
  8010cf:	e8 80 15 00 00       	call   802654 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010d4:	ba 07 00 00 00       	mov    $0x7,%edx
  8010d9:	89 d0                	mov    %edx,%eax
  8010db:	cd 30                	int    $0x30
  8010dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010e0:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 20                	jns    801107 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8010e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010eb:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  801102:	e8 29 f1 ff ff       	call   800230 <_panic>
	if (child_envid == 0) { // child
  801107:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80110b:	75 1c                	jne    801129 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  80110d:	e8 75 fb ff ff       	call   800c87 <sys_getenvid>
  801112:	25 ff 03 00 00       	and    $0x3ff,%eax
  801117:	c1 e0 07             	shl    $0x7,%eax
  80111a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80111f:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801124:	e9 58 02 00 00       	jmp    801381 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801129:	bf 00 00 00 00       	mov    $0x0,%edi
  80112e:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801133:	89 f0                	mov    %esi,%eax
  801135:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801138:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113f:	a8 01                	test   $0x1,%al
  801141:	0f 84 7a 01 00 00    	je     8012c1 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801147:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80114e:	a8 01                	test   $0x1,%al
  801150:	0f 84 6b 01 00 00    	je     8012c1 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801156:	a1 08 50 80 00       	mov    0x805008,%eax
  80115b:	8b 40 48             	mov    0x48(%eax),%eax
  80115e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801161:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801168:	f6 c4 04             	test   $0x4,%ah
  80116b:	74 52                	je     8011bf <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80116d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801174:	25 07 0e 00 00       	and    $0xe07,%eax
  801179:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801181:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801184:	89 44 24 08          	mov    %eax,0x8(%esp)
  801188:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80118c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 82 fb ff ff       	call   800d19 <sys_page_map>
  801197:	85 c0                	test   %eax,%eax
  801199:	0f 89 22 01 00 00    	jns    8012c1 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80119f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a3:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  8011aa:	00 
  8011ab:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011b2:	00 
  8011b3:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  8011ba:	e8 71 f0 ff ff       	call   800230 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8011bf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c6:	f6 c4 08             	test   $0x8,%ah
  8011c9:	75 0f                	jne    8011da <fork+0x11b>
  8011cb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d2:	a8 02                	test   $0x2,%al
  8011d4:	0f 84 99 00 00 00    	je     801273 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  8011da:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011e1:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011e4:	83 f8 01             	cmp    $0x1,%eax
  8011e7:	19 db                	sbb    %ebx,%ebx
  8011e9:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011ec:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011f2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011f6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801201:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801205:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801208:	89 04 24             	mov    %eax,(%esp)
  80120b:	e8 09 fb ff ff       	call   800d19 <sys_page_map>
  801210:	85 c0                	test   %eax,%eax
  801212:	79 20                	jns    801234 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801214:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801218:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  80121f:	00 
  801220:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801227:	00 
  801228:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  80122f:	e8 fc ef ff ff       	call   800230 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801234:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801238:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80123c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801243:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801247:	89 04 24             	mov    %eax,(%esp)
  80124a:	e8 ca fa ff ff       	call   800d19 <sys_page_map>
  80124f:	85 c0                	test   %eax,%eax
  801251:	79 6e                	jns    8012c1 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801253:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801257:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  80125e:	00 
  80125f:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801266:	00 
  801267:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  80126e:	e8 bd ef ff ff       	call   800230 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801273:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80127a:	25 07 0e 00 00       	and    $0xe07,%eax
  80127f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801283:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801287:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	e8 7c fa ff ff       	call   800d19 <sys_page_map>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	79 20                	jns    8012c1 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8012a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a5:	c7 44 24 08 73 2f 80 	movl   $0x802f73,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  8012bc:	e8 6f ef ff ff       	call   800230 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8012c1:	46                   	inc    %esi
  8012c2:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012c8:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8012ce:	0f 85 5f fe ff ff    	jne    801133 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8012d4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012db:	00 
  8012dc:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012e3:	ee 
  8012e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 d6 f9 ff ff       	call   800cc5 <sys_page_alloc>
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	79 20                	jns    801313 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  8012f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f7:	c7 44 24 08 5f 2f 80 	movl   $0x802f5f,0x8(%esp)
  8012fe:	00 
  8012ff:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801306:	00 
  801307:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  80130e:	e8 1d ef ff ff       	call   800230 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801313:	c7 44 24 04 c8 26 80 	movl   $0x8026c8,0x4(%esp)
  80131a:	00 
  80131b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80131e:	89 04 24             	mov    %eax,(%esp)
  801321:	e8 3f fb ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
  801326:	85 c0                	test   %eax,%eax
  801328:	79 20                	jns    80134a <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80132a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132e:	c7 44 24 08 34 2f 80 	movl   $0x802f34,0x8(%esp)
  801335:	00 
  801336:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  80133d:	00 
  80133e:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  801345:	e8 e6 ee ff ff       	call   800230 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  80134a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801351:	00 
  801352:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 62 fa ff ff       	call   800dbf <sys_env_set_status>
  80135d:	85 c0                	test   %eax,%eax
  80135f:	79 20                	jns    801381 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801361:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801365:	c7 44 24 08 96 2f 80 	movl   $0x802f96,0x8(%esp)
  80136c:	00 
  80136d:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801374:	00 
  801375:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  80137c:	e8 af ee ff ff       	call   800230 <_panic>

	return child_envid;
}
  801381:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801384:	83 c4 3c             	add    $0x3c,%esp
  801387:	5b                   	pop    %ebx
  801388:	5e                   	pop    %esi
  801389:	5f                   	pop    %edi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <sfork>:

// Challenge!
int
sfork(void)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801392:	c7 44 24 08 ae 2f 80 	movl   $0x802fae,0x8(%esp)
  801399:	00 
  80139a:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8013a1:	00 
  8013a2:	c7 04 24 54 2f 80 00 	movl   $0x802f54,(%esp)
  8013a9:	e8 82 ee ff ff       	call   800230 <_panic>
	...

008013b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 df ff ff ff       	call   8013b0 <fd2num>
  8013d1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013d6:	c1 e0 0c             	shl    $0xc,%eax
}
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	53                   	push   %ebx
  8013df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013e7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	c1 ea 16             	shr    $0x16,%edx
  8013ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	74 11                	je     80140b <fd_alloc+0x30>
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	c1 ea 0c             	shr    $0xc,%edx
  8013ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801406:	f6 c2 01             	test   $0x1,%dl
  801409:	75 09                	jne    801414 <fd_alloc+0x39>
			*fd_store = fd;
  80140b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80140d:	b8 00 00 00 00       	mov    $0x0,%eax
  801412:	eb 17                	jmp    80142b <fd_alloc+0x50>
  801414:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801419:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80141e:	75 c7                	jne    8013e7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801426:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80142b:	5b                   	pop    %ebx
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801434:	83 f8 1f             	cmp    $0x1f,%eax
  801437:	77 36                	ja     80146f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801439:	05 00 00 0d 00       	add    $0xd0000,%eax
  80143e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801441:	89 c2                	mov    %eax,%edx
  801443:	c1 ea 16             	shr    $0x16,%edx
  801446:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80144d:	f6 c2 01             	test   $0x1,%dl
  801450:	74 24                	je     801476 <fd_lookup+0x48>
  801452:	89 c2                	mov    %eax,%edx
  801454:	c1 ea 0c             	shr    $0xc,%edx
  801457:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145e:	f6 c2 01             	test   $0x1,%dl
  801461:	74 1a                	je     80147d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801463:	8b 55 0c             	mov    0xc(%ebp),%edx
  801466:	89 02                	mov    %eax,(%edx)
	return 0;
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
  80146d:	eb 13                	jmp    801482 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801474:	eb 0c                	jmp    801482 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147b:	eb 05                	jmp    801482 <fd_lookup+0x54>
  80147d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	53                   	push   %ebx
  801488:	83 ec 14             	sub    $0x14,%esp
  80148b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80148e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801491:	ba 00 00 00 00       	mov    $0x0,%edx
  801496:	eb 0e                	jmp    8014a6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801498:	39 08                	cmp    %ecx,(%eax)
  80149a:	75 09                	jne    8014a5 <dev_lookup+0x21>
			*dev = devtab[i];
  80149c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a3:	eb 33                	jmp    8014d8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a5:	42                   	inc    %edx
  8014a6:	8b 04 95 40 30 80 00 	mov    0x803040(,%edx,4),%eax
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	75 e7                	jne    801498 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b1:	a1 08 50 80 00       	mov    0x805008,%eax
  8014b6:	8b 40 48             	mov    0x48(%eax),%eax
  8014b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	c7 04 24 c4 2f 80 00 	movl   $0x802fc4,(%esp)
  8014c8:	e8 5b ee ff ff       	call   800328 <cprintf>
	*dev = 0;
  8014cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014d8:	83 c4 14             	add    $0x14,%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5d                   	pop    %ebp
  8014dd:	c3                   	ret    

008014de <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014de:	55                   	push   %ebp
  8014df:	89 e5                	mov    %esp,%ebp
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 30             	sub    $0x30,%esp
  8014e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e9:	8a 45 0c             	mov    0xc(%ebp),%al
  8014ec:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014ef:	89 34 24             	mov    %esi,(%esp)
  8014f2:	e8 b9 fe ff ff       	call   8013b0 <fd2num>
  8014f7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014fe:	89 04 24             	mov    %eax,(%esp)
  801501:	e8 28 ff ff ff       	call   80142e <fd_lookup>
  801506:	89 c3                	mov    %eax,%ebx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 05                	js     801511 <fd_close+0x33>
	    || fd != fd2)
  80150c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80150f:	74 0d                	je     80151e <fd_close+0x40>
		return (must_exist ? r : 0);
  801511:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801515:	75 46                	jne    80155d <fd_close+0x7f>
  801517:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151c:	eb 3f                	jmp    80155d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80151e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801521:	89 44 24 04          	mov    %eax,0x4(%esp)
  801525:	8b 06                	mov    (%esi),%eax
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	e8 55 ff ff ff       	call   801484 <dev_lookup>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	85 c0                	test   %eax,%eax
  801533:	78 18                	js     80154d <fd_close+0x6f>
		if (dev->dev_close)
  801535:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801538:	8b 40 10             	mov    0x10(%eax),%eax
  80153b:	85 c0                	test   %eax,%eax
  80153d:	74 09                	je     801548 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80153f:	89 34 24             	mov    %esi,(%esp)
  801542:	ff d0                	call   *%eax
  801544:	89 c3                	mov    %eax,%ebx
  801546:	eb 05                	jmp    80154d <fd_close+0x6f>
		else
			r = 0;
  801548:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80154d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801558:	e8 0f f8 ff ff       	call   800d6c <sys_page_unmap>
	return r;
}
  80155d:	89 d8                	mov    %ebx,%eax
  80155f:	83 c4 30             	add    $0x30,%esp
  801562:	5b                   	pop    %ebx
  801563:	5e                   	pop    %esi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 b0 fe ff ff       	call   80142e <fd_lookup>
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 13                	js     801595 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801582:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801589:	00 
  80158a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	e8 49 ff ff ff       	call   8014de <fd_close>
}
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <close_all>:

void
close_all(void)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80159e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015a3:	89 1c 24             	mov    %ebx,(%esp)
  8015a6:	e8 bb ff ff ff       	call   801566 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ab:	43                   	inc    %ebx
  8015ac:	83 fb 20             	cmp    $0x20,%ebx
  8015af:	75 f2                	jne    8015a3 <close_all+0xc>
		close(i);
}
  8015b1:	83 c4 14             	add    $0x14,%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	57                   	push   %edi
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 4c             	sub    $0x4c,%esp
  8015c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cd:	89 04 24             	mov    %eax,(%esp)
  8015d0:	e8 59 fe ff ff       	call   80142e <fd_lookup>
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	0f 88 e1 00 00 00    	js     8016c0 <dup+0x109>
		return r;
	close(newfdnum);
  8015df:	89 3c 24             	mov    %edi,(%esp)
  8015e2:	e8 7f ff ff ff       	call   801566 <close>

	newfd = INDEX2FD(newfdnum);
  8015e7:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015ed:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f3:	89 04 24             	mov    %eax,(%esp)
  8015f6:	e8 c5 fd ff ff       	call   8013c0 <fd2data>
  8015fb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015fd:	89 34 24             	mov    %esi,(%esp)
  801600:	e8 bb fd ff ff       	call   8013c0 <fd2data>
  801605:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801608:	89 d8                	mov    %ebx,%eax
  80160a:	c1 e8 16             	shr    $0x16,%eax
  80160d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801614:	a8 01                	test   $0x1,%al
  801616:	74 46                	je     80165e <dup+0xa7>
  801618:	89 d8                	mov    %ebx,%eax
  80161a:	c1 e8 0c             	shr    $0xc,%eax
  80161d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801624:	f6 c2 01             	test   $0x1,%dl
  801627:	74 35                	je     80165e <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801629:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801630:	25 07 0e 00 00       	and    $0xe07,%eax
  801635:	89 44 24 10          	mov    %eax,0x10(%esp)
  801639:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80163c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801640:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801647:	00 
  801648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80164c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801653:	e8 c1 f6 ff ff       	call   800d19 <sys_page_map>
  801658:	89 c3                	mov    %eax,%ebx
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 3b                	js     801699 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801661:	89 c2                	mov    %eax,%edx
  801663:	c1 ea 0c             	shr    $0xc,%edx
  801666:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80166d:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801673:	89 54 24 10          	mov    %edx,0x10(%esp)
  801677:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80167b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801682:	00 
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
  801687:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168e:	e8 86 f6 ff ff       	call   800d19 <sys_page_map>
  801693:	89 c3                	mov    %eax,%ebx
  801695:	85 c0                	test   %eax,%eax
  801697:	79 25                	jns    8016be <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801699:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a4:	e8 c3 f6 ff ff       	call   800d6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b7:	e8 b0 f6 ff ff       	call   800d6c <sys_page_unmap>
	return r;
  8016bc:	eb 02                	jmp    8016c0 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016be:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	83 c4 4c             	add    $0x4c,%esp
  8016c5:	5b                   	pop    %ebx
  8016c6:	5e                   	pop    %esi
  8016c7:	5f                   	pop    %edi
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 24             	sub    $0x24,%esp
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016db:	89 1c 24             	mov    %ebx,(%esp)
  8016de:	e8 4b fd ff ff       	call   80142e <fd_lookup>
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 6d                	js     801754 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	8b 00                	mov    (%eax),%eax
  8016f3:	89 04 24             	mov    %eax,(%esp)
  8016f6:	e8 89 fd ff ff       	call   801484 <dev_lookup>
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 55                	js     801754 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801702:	8b 50 08             	mov    0x8(%eax),%edx
  801705:	83 e2 03             	and    $0x3,%edx
  801708:	83 fa 01             	cmp    $0x1,%edx
  80170b:	75 23                	jne    801730 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80170d:	a1 08 50 80 00       	mov    0x805008,%eax
  801712:	8b 40 48             	mov    0x48(%eax),%eax
  801715:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171d:	c7 04 24 05 30 80 00 	movl   $0x803005,(%esp)
  801724:	e8 ff eb ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  801729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172e:	eb 24                	jmp    801754 <read+0x8a>
	}
	if (!dev->dev_read)
  801730:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801733:	8b 52 08             	mov    0x8(%edx),%edx
  801736:	85 d2                	test   %edx,%edx
  801738:	74 15                	je     80174f <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80173a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80173d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801748:	89 04 24             	mov    %eax,(%esp)
  80174b:	ff d2                	call   *%edx
  80174d:	eb 05                	jmp    801754 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80174f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801754:	83 c4 24             	add    $0x24,%esp
  801757:	5b                   	pop    %ebx
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	57                   	push   %edi
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	83 ec 1c             	sub    $0x1c,%esp
  801763:	8b 7d 08             	mov    0x8(%ebp),%edi
  801766:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176e:	eb 23                	jmp    801793 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801770:	89 f0                	mov    %esi,%eax
  801772:	29 d8                	sub    %ebx,%eax
  801774:	89 44 24 08          	mov    %eax,0x8(%esp)
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	01 d8                	add    %ebx,%eax
  80177d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801781:	89 3c 24             	mov    %edi,(%esp)
  801784:	e8 41 ff ff ff       	call   8016ca <read>
		if (m < 0)
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 10                	js     80179d <readn+0x43>
			return m;
		if (m == 0)
  80178d:	85 c0                	test   %eax,%eax
  80178f:	74 0a                	je     80179b <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801791:	01 c3                	add    %eax,%ebx
  801793:	39 f3                	cmp    %esi,%ebx
  801795:	72 d9                	jb     801770 <readn+0x16>
  801797:	89 d8                	mov    %ebx,%eax
  801799:	eb 02                	jmp    80179d <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80179b:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80179d:	83 c4 1c             	add    $0x1c,%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5f                   	pop    %edi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 24             	sub    $0x24,%esp
  8017ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	89 1c 24             	mov    %ebx,(%esp)
  8017b9:	e8 70 fc ff ff       	call   80142e <fd_lookup>
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 68                	js     80182a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cc:	8b 00                	mov    (%eax),%eax
  8017ce:	89 04 24             	mov    %eax,(%esp)
  8017d1:	e8 ae fc ff ff       	call   801484 <dev_lookup>
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 50                	js     80182a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017e1:	75 23                	jne    801806 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e3:	a1 08 50 80 00       	mov    0x805008,%eax
  8017e8:	8b 40 48             	mov    0x48(%eax),%eax
  8017eb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f3:	c7 04 24 21 30 80 00 	movl   $0x803021,(%esp)
  8017fa:	e8 29 eb ff ff       	call   800328 <cprintf>
		return -E_INVAL;
  8017ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801804:	eb 24                	jmp    80182a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801806:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801809:	8b 52 0c             	mov    0xc(%edx),%edx
  80180c:	85 d2                	test   %edx,%edx
  80180e:	74 15                	je     801825 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801810:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801813:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801817:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80181e:	89 04 24             	mov    %eax,(%esp)
  801821:	ff d2                	call   *%edx
  801823:	eb 05                	jmp    80182a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801825:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80182a:	83 c4 24             	add    $0x24,%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <seek>:

int
seek(int fdnum, off_t offset)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801836:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	89 04 24             	mov    %eax,(%esp)
  801843:	e8 e6 fb ff ff       	call   80142e <fd_lookup>
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 0e                	js     80185a <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80184c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801852:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801855:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	53                   	push   %ebx
  801860:	83 ec 24             	sub    $0x24,%esp
  801863:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801866:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	89 1c 24             	mov    %ebx,(%esp)
  801870:	e8 b9 fb ff ff       	call   80142e <fd_lookup>
  801875:	85 c0                	test   %eax,%eax
  801877:	78 61                	js     8018da <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801883:	8b 00                	mov    (%eax),%eax
  801885:	89 04 24             	mov    %eax,(%esp)
  801888:	e8 f7 fb ff ff       	call   801484 <dev_lookup>
  80188d:	85 c0                	test   %eax,%eax
  80188f:	78 49                	js     8018da <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801891:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801894:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801898:	75 23                	jne    8018bd <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80189a:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189f:	8b 40 48             	mov    0x48(%eax),%eax
  8018a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018aa:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  8018b1:	e8 72 ea ff ff       	call   800328 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018bb:	eb 1d                	jmp    8018da <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c0:	8b 52 18             	mov    0x18(%edx),%edx
  8018c3:	85 d2                	test   %edx,%edx
  8018c5:	74 0e                	je     8018d5 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ca:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018ce:	89 04 24             	mov    %eax,(%esp)
  8018d1:	ff d2                	call   *%edx
  8018d3:	eb 05                	jmp    8018da <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018da:	83 c4 24             	add    $0x24,%esp
  8018dd:	5b                   	pop    %ebx
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 24             	sub    $0x24,%esp
  8018e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	89 04 24             	mov    %eax,(%esp)
  8018f7:	e8 32 fb ff ff       	call   80142e <fd_lookup>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 52                	js     801952 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801900:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801903:	89 44 24 04          	mov    %eax,0x4(%esp)
  801907:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190a:	8b 00                	mov    (%eax),%eax
  80190c:	89 04 24             	mov    %eax,(%esp)
  80190f:	e8 70 fb ff ff       	call   801484 <dev_lookup>
  801914:	85 c0                	test   %eax,%eax
  801916:	78 3a                	js     801952 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801918:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80191f:	74 2c                	je     80194d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801921:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801924:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80192b:	00 00 00 
	stat->st_isdir = 0;
  80192e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801935:	00 00 00 
	stat->st_dev = dev;
  801938:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80193e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801942:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801945:	89 14 24             	mov    %edx,(%esp)
  801948:	ff 50 14             	call   *0x14(%eax)
  80194b:	eb 05                	jmp    801952 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80194d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801952:	83 c4 24             	add    $0x24,%esp
  801955:	5b                   	pop    %ebx
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	56                   	push   %esi
  80195c:	53                   	push   %ebx
  80195d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801960:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801967:	00 
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	89 04 24             	mov    %eax,(%esp)
  80196e:	e8 2d 02 00 00       	call   801ba0 <open>
  801973:	89 c3                	mov    %eax,%ebx
  801975:	85 c0                	test   %eax,%eax
  801977:	78 1b                	js     801994 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801980:	89 1c 24             	mov    %ebx,(%esp)
  801983:	e8 58 ff ff ff       	call   8018e0 <fstat>
  801988:	89 c6                	mov    %eax,%esi
	close(fd);
  80198a:	89 1c 24             	mov    %ebx,(%esp)
  80198d:	e8 d4 fb ff ff       	call   801566 <close>
	return r;
  801992:	89 f3                	mov    %esi,%ebx
}
  801994:	89 d8                	mov    %ebx,%eax
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    
  80199d:	00 00                	add    %al,(%eax)
	...

008019a0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 10             	sub    $0x10,%esp
  8019a8:	89 c3                	mov    %eax,%ebx
  8019aa:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019ac:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019b3:	75 11                	jne    8019c6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019bc:	e8 02 0e 00 00       	call   8027c3 <ipc_find_env>
  8019c1:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019cd:	00 
  8019ce:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8019d5:	00 
  8019d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019da:	a1 00 50 80 00       	mov    0x805000,%eax
  8019df:	89 04 24             	mov    %eax,(%esp)
  8019e2:	e8 6e 0d 00 00       	call   802755 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ee:	00 
  8019ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019fa:	e8 ed 0c 00 00       	call   8026ec <ipc_recv>
}
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a12:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a24:	b8 02 00 00 00       	mov    $0x2,%eax
  801a29:	e8 72 ff ff ff       	call   8019a0 <fsipc>
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a36:	8b 45 08             	mov    0x8(%ebp),%eax
  801a39:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a41:	ba 00 00 00 00       	mov    $0x0,%edx
  801a46:	b8 06 00 00 00       	mov    $0x6,%eax
  801a4b:	e8 50 ff ff ff       	call   8019a0 <fsipc>
}
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	53                   	push   %ebx
  801a56:	83 ec 14             	sub    $0x14,%esp
  801a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a62:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a71:	e8 2a ff ff ff       	call   8019a0 <fsipc>
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 2b                	js     801aa5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a7a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801a81:	00 
  801a82:	89 1c 24             	mov    %ebx,(%esp)
  801a85:	e8 49 ee ff ff       	call   8008d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a8a:	a1 80 60 80 00       	mov    0x806080,%eax
  801a8f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a95:	a1 84 60 80 00       	mov    0x806084,%eax
  801a9a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa5:	83 c4 14             	add    $0x14,%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 18             	sub    $0x18,%esp
  801ab1:	8b 55 10             	mov    0x10(%ebp),%edx
  801ab4:	89 d0                	mov    %edx,%eax
  801ab6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801abc:	76 05                	jbe    801ac3 <devfile_write+0x18>
  801abe:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ac3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ac6:	8b 52 0c             	mov    0xc(%edx),%edx
  801ac9:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801acf:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adf:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801ae6:	e8 61 ef ff ff       	call   800a4c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  801af0:	b8 04 00 00 00       	mov    $0x4,%eax
  801af5:	e8 a6 fe ff ff       	call   8019a0 <fsipc>
}
  801afa:	c9                   	leave  
  801afb:	c3                   	ret    

00801afc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 10             	sub    $0x10,%esp
  801b04:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b12:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b18:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1d:	b8 03 00 00 00       	mov    $0x3,%eax
  801b22:	e8 79 fe ff ff       	call   8019a0 <fsipc>
  801b27:	89 c3                	mov    %eax,%ebx
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 6a                	js     801b97 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b2d:	39 c6                	cmp    %eax,%esi
  801b2f:	73 24                	jae    801b55 <devfile_read+0x59>
  801b31:	c7 44 24 0c 54 30 80 	movl   $0x803054,0xc(%esp)
  801b38:	00 
  801b39:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  801b40:	00 
  801b41:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b48:	00 
  801b49:	c7 04 24 70 30 80 00 	movl   $0x803070,(%esp)
  801b50:	e8 db e6 ff ff       	call   800230 <_panic>
	assert(r <= PGSIZE);
  801b55:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b5a:	7e 24                	jle    801b80 <devfile_read+0x84>
  801b5c:	c7 44 24 0c 7b 30 80 	movl   $0x80307b,0xc(%esp)
  801b63:	00 
  801b64:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  801b6b:	00 
  801b6c:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b73:	00 
  801b74:	c7 04 24 70 30 80 00 	movl   $0x803070,(%esp)
  801b7b:	e8 b0 e6 ff ff       	call   800230 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b84:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b8b:	00 
  801b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8f:	89 04 24             	mov    %eax,(%esp)
  801b92:	e8 b5 ee ff ff       	call   800a4c <memmove>
	return r;
}
  801b97:	89 d8                	mov    %ebx,%eax
  801b99:	83 c4 10             	add    $0x10,%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	56                   	push   %esi
  801ba4:	53                   	push   %ebx
  801ba5:	83 ec 20             	sub    $0x20,%esp
  801ba8:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bab:	89 34 24             	mov    %esi,(%esp)
  801bae:	e8 ed ec ff ff       	call   8008a0 <strlen>
  801bb3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bb8:	7f 60                	jg     801c1a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bbd:	89 04 24             	mov    %eax,(%esp)
  801bc0:	e8 16 f8 ff ff       	call   8013db <fd_alloc>
  801bc5:	89 c3                	mov    %eax,%ebx
  801bc7:	85 c0                	test   %eax,%eax
  801bc9:	78 54                	js     801c1f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bcb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bcf:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801bd6:	e8 f8 ec ff ff       	call   8008d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	e8 b0 fd ff ff       	call   8019a0 <fsipc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	79 15                	jns    801c0b <open+0x6b>
		fd_close(fd, 0);
  801bf6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bfd:	00 
  801bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c01:	89 04 24             	mov    %eax,(%esp)
  801c04:	e8 d5 f8 ff ff       	call   8014de <fd_close>
		return r;
  801c09:	eb 14                	jmp    801c1f <open+0x7f>
	}

	return fd2num(fd);
  801c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	e8 9a f7 ff ff       	call   8013b0 <fd2num>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	eb 05                	jmp    801c1f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c1a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c1f:	89 d8                	mov    %ebx,%eax
  801c21:	83 c4 20             	add    $0x20,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c33:	b8 08 00 00 00       	mov    $0x8,%eax
  801c38:	e8 63 fd ff ff       	call   8019a0 <fsipc>
}
  801c3d:	c9                   	leave  
  801c3e:	c3                   	ret    
	...

00801c40 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c46:	c7 44 24 04 87 30 80 	movl   $0x803087,0x4(%esp)
  801c4d:	00 
  801c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 7a ec ff ff       	call   8008d3 <strcpy>
	return 0;
}
  801c59:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	83 ec 14             	sub    $0x14,%esp
  801c67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c6a:	89 1c 24             	mov    %ebx,(%esp)
  801c6d:	e8 8a 0b 00 00       	call   8027fc <pageref>
  801c72:	83 f8 01             	cmp    $0x1,%eax
  801c75:	75 0d                	jne    801c84 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c77:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c7a:	89 04 24             	mov    %eax,(%esp)
  801c7d:	e8 1f 03 00 00       	call   801fa1 <nsipc_close>
  801c82:	eb 05                	jmp    801c89 <devsock_close+0x29>
	else
		return 0;
  801c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c89:	83 c4 14             	add    $0x14,%esp
  801c8c:	5b                   	pop    %ebx
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c9c:	00 
  801c9d:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 e3 03 00 00       	call   80209c <nsipc_send>
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cc1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cc8:	00 
  801cc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cda:	8b 40 0c             	mov    0xc(%eax),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 37 03 00 00       	call   80201c <nsipc_recv>
}
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 20             	sub    $0x20,%esp
  801cef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cf1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf4:	89 04 24             	mov    %eax,(%esp)
  801cf7:	e8 df f6 ff ff       	call   8013db <fd_alloc>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 21                	js     801d23 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d09:	00 
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d18:	e8 a8 ef ff ff       	call   800cc5 <sys_page_alloc>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	79 0a                	jns    801d2d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d23:	89 34 24             	mov    %esi,(%esp)
  801d26:	e8 76 02 00 00       	call   801fa1 <nsipc_close>
		return r;
  801d2b:	eb 22                	jmp    801d4f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d2d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d36:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d42:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d45:	89 04 24             	mov    %eax,(%esp)
  801d48:	e8 63 f6 ff ff       	call   8013b0 <fd2num>
  801d4d:	89 c3                	mov    %eax,%ebx
}
  801d4f:	89 d8                	mov    %ebx,%eax
  801d51:	83 c4 20             	add    $0x20,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d5e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d65:	89 04 24             	mov    %eax,(%esp)
  801d68:	e8 c1 f6 ff ff       	call   80142e <fd_lookup>
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 17                	js     801d88 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d74:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801d7a:	39 10                	cmp    %edx,(%eax)
  801d7c:	75 05                	jne    801d83 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d81:	eb 05                	jmp    801d88 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d83:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	e8 c0 ff ff ff       	call   801d58 <fd2sockid>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 1f                	js     801dbb <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d9c:	8b 55 10             	mov    0x10(%ebp),%edx
  801d9f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801da3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da6:	89 54 24 04          	mov    %edx,0x4(%esp)
  801daa:	89 04 24             	mov    %eax,(%esp)
  801dad:	e8 38 01 00 00       	call   801eea <nsipc_accept>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	78 05                	js     801dbb <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801db6:	e8 2c ff ff ff       	call   801ce7 <alloc_sockfd>
}
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc6:	e8 8d ff ff ff       	call   801d58 <fd2sockid>
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 16                	js     801de5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801dcf:	8b 55 10             	mov    0x10(%ebp),%edx
  801dd2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ddd:	89 04 24             	mov    %eax,(%esp)
  801de0:	e8 5b 01 00 00       	call   801f40 <nsipc_bind>
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <shutdown>:

int
shutdown(int s, int how)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	e8 63 ff ff ff       	call   801d58 <fd2sockid>
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 0f                	js     801e08 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e00:	89 04 24             	mov    %eax,(%esp)
  801e03:	e8 77 01 00 00       	call   801f7f <nsipc_shutdown>
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e10:	8b 45 08             	mov    0x8(%ebp),%eax
  801e13:	e8 40 ff ff ff       	call   801d58 <fd2sockid>
  801e18:	85 c0                	test   %eax,%eax
  801e1a:	78 16                	js     801e32 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e1c:	8b 55 10             	mov    0x10(%ebp),%edx
  801e1f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e26:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e2a:	89 04 24             	mov    %eax,(%esp)
  801e2d:	e8 89 01 00 00       	call   801fbb <nsipc_connect>
}
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <listen>:

int
listen(int s, int backlog)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	e8 16 ff ff ff       	call   801d58 <fd2sockid>
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 0f                	js     801e55 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e49:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e4d:	89 04 24             	mov    %eax,(%esp)
  801e50:	e8 a5 01 00 00       	call   801ffa <nsipc_listen>
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 99 02 00 00       	call   80210f <nsipc_socket>
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 05                	js     801e7f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e7a:	e8 68 fe ff ff       	call   801ce7 <alloc_sockfd>
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    
  801e81:	00 00                	add    %al,(%eax)
	...

00801e84 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	53                   	push   %ebx
  801e88:	83 ec 14             	sub    $0x14,%esp
  801e8b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e8d:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801e94:	75 11                	jne    801ea7 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e96:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e9d:	e8 21 09 00 00       	call   8027c3 <ipc_find_env>
  801ea2:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ea7:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801eae:	00 
  801eaf:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801eb6:	00 
  801eb7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ebb:	a1 04 50 80 00       	mov    0x805004,%eax
  801ec0:	89 04 24             	mov    %eax,(%esp)
  801ec3:	e8 8d 08 00 00       	call   802755 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ec8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ecf:	00 
  801ed0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ed7:	00 
  801ed8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edf:	e8 08 08 00 00       	call   8026ec <ipc_recv>
}
  801ee4:	83 c4 14             	add    $0x14,%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 10             	sub    $0x10,%esp
  801ef2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801efd:	8b 06                	mov    (%esi),%eax
  801eff:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f04:	b8 01 00 00 00       	mov    $0x1,%eax
  801f09:	e8 76 ff ff ff       	call   801e84 <nsipc>
  801f0e:	89 c3                	mov    %eax,%ebx
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 23                	js     801f37 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f14:	a1 10 70 80 00       	mov    0x807010,%eax
  801f19:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f1d:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801f24:	00 
  801f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f28:	89 04 24             	mov    %eax,(%esp)
  801f2b:	e8 1c eb ff ff       	call   800a4c <memmove>
		*addrlen = ret->ret_addrlen;
  801f30:	a1 10 70 80 00       	mov    0x807010,%eax
  801f35:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f37:	89 d8                	mov    %ebx,%eax
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	5b                   	pop    %ebx
  801f3d:	5e                   	pop    %esi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	53                   	push   %ebx
  801f44:	83 ec 14             	sub    $0x14,%esp
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801f64:	e8 e3 ea ff ff       	call   800a4c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f69:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f6f:	b8 02 00 00 00       	mov    $0x2,%eax
  801f74:	e8 0b ff ff ff       	call   801e84 <nsipc>
}
  801f79:	83 c4 14             	add    $0x14,%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f85:	8b 45 08             	mov    0x8(%ebp),%eax
  801f88:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f90:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f95:	b8 03 00 00 00       	mov    $0x3,%eax
  801f9a:	e8 e5 fe ff ff       	call   801e84 <nsipc>
}
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <nsipc_close>:

int
nsipc_close(int s)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801faa:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801faf:	b8 04 00 00 00       	mov    $0x4,%eax
  801fb4:	e8 cb fe ff ff       	call   801e84 <nsipc>
}
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 14             	sub    $0x14,%esp
  801fc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fcd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd8:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  801fdf:	e8 68 ea ff ff       	call   800a4c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fe4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fea:	b8 05 00 00 00       	mov    $0x5,%eax
  801fef:	e8 90 fe ff ff       	call   801e84 <nsipc>
}
  801ff4:	83 c4 14             	add    $0x14,%esp
  801ff7:	5b                   	pop    %ebx
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802000:	8b 45 08             	mov    0x8(%ebp),%eax
  802003:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802008:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802010:	b8 06 00 00 00       	mov    $0x6,%eax
  802015:	e8 6a fe ff ff       	call   801e84 <nsipc>
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	83 ec 10             	sub    $0x10,%esp
  802024:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80202f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802035:	8b 45 14             	mov    0x14(%ebp),%eax
  802038:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80203d:	b8 07 00 00 00       	mov    $0x7,%eax
  802042:	e8 3d fe ff ff       	call   801e84 <nsipc>
  802047:	89 c3                	mov    %eax,%ebx
  802049:	85 c0                	test   %eax,%eax
  80204b:	78 46                	js     802093 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80204d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802052:	7f 04                	jg     802058 <nsipc_recv+0x3c>
  802054:	39 c6                	cmp    %eax,%esi
  802056:	7d 24                	jge    80207c <nsipc_recv+0x60>
  802058:	c7 44 24 0c 93 30 80 	movl   $0x803093,0xc(%esp)
  80205f:	00 
  802060:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  802067:	00 
  802068:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80206f:	00 
  802070:	c7 04 24 a8 30 80 00 	movl   $0x8030a8,(%esp)
  802077:	e8 b4 e1 ff ff       	call   800230 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80207c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802080:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802087:	00 
  802088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 b9 e9 ff ff       	call   800a4c <memmove>
	}

	return r;
}
  802093:	89 d8                	mov    %ebx,%eax
  802095:	83 c4 10             	add    $0x10,%esp
  802098:	5b                   	pop    %ebx
  802099:	5e                   	pop    %esi
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    

0080209c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	53                   	push   %ebx
  8020a0:	83 ec 14             	sub    $0x14,%esp
  8020a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a9:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8020ae:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020b4:	7e 24                	jle    8020da <nsipc_send+0x3e>
  8020b6:	c7 44 24 0c b4 30 80 	movl   $0x8030b4,0xc(%esp)
  8020bd:	00 
  8020be:	c7 44 24 08 5b 30 80 	movl   $0x80305b,0x8(%esp)
  8020c5:	00 
  8020c6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020cd:	00 
  8020ce:	c7 04 24 a8 30 80 00 	movl   $0x8030a8,(%esp)
  8020d5:	e8 56 e1 ff ff       	call   800230 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e5:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8020ec:	e8 5b e9 ff ff       	call   800a4c <memmove>
	nsipcbuf.send.req_size = size;
  8020f1:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8020fa:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020ff:	b8 08 00 00 00       	mov    $0x8,%eax
  802104:	e8 7b fd ff ff       	call   801e84 <nsipc>
}
  802109:	83 c4 14             	add    $0x14,%esp
  80210c:	5b                   	pop    %ebx
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    

0080210f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802115:	8b 45 08             	mov    0x8(%ebp),%eax
  802118:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80211d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802120:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802125:	8b 45 10             	mov    0x10(%ebp),%eax
  802128:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80212d:	b8 09 00 00 00       	mov    $0x9,%eax
  802132:	e8 4d fd ff ff       	call   801e84 <nsipc>
}
  802137:	c9                   	leave  
  802138:	c3                   	ret    
  802139:	00 00                	add    %al,(%eax)
	...

0080213c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	56                   	push   %esi
  802140:	53                   	push   %ebx
  802141:	83 ec 10             	sub    $0x10,%esp
  802144:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802147:	8b 45 08             	mov    0x8(%ebp),%eax
  80214a:	89 04 24             	mov    %eax,(%esp)
  80214d:	e8 6e f2 ff ff       	call   8013c0 <fd2data>
  802152:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802154:	c7 44 24 04 c0 30 80 	movl   $0x8030c0,0x4(%esp)
  80215b:	00 
  80215c:	89 34 24             	mov    %esi,(%esp)
  80215f:	e8 6f e7 ff ff       	call   8008d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802164:	8b 43 04             	mov    0x4(%ebx),%eax
  802167:	2b 03                	sub    (%ebx),%eax
  802169:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80216f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802176:	00 00 00 
	stat->st_dev = &devpipe;
  802179:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802180:	40 80 00 
	return 0;
}
  802183:	b8 00 00 00 00       	mov    $0x0,%eax
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	5b                   	pop    %ebx
  80218c:	5e                   	pop    %esi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    

0080218f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	53                   	push   %ebx
  802193:	83 ec 14             	sub    $0x14,%esp
  802196:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802199:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80219d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a4:	e8 c3 eb ff ff       	call   800d6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021a9:	89 1c 24             	mov    %ebx,(%esp)
  8021ac:	e8 0f f2 ff ff       	call   8013c0 <fd2data>
  8021b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021bc:	e8 ab eb ff ff       	call   800d6c <sys_page_unmap>
}
  8021c1:	83 c4 14             	add    $0x14,%esp
  8021c4:	5b                   	pop    %ebx
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	57                   	push   %edi
  8021cb:	56                   	push   %esi
  8021cc:	53                   	push   %ebx
  8021cd:	83 ec 2c             	sub    $0x2c,%esp
  8021d0:	89 c7                	mov    %eax,%edi
  8021d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021d5:	a1 08 50 80 00       	mov    0x805008,%eax
  8021da:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021dd:	89 3c 24             	mov    %edi,(%esp)
  8021e0:	e8 17 06 00 00       	call   8027fc <pageref>
  8021e5:	89 c6                	mov    %eax,%esi
  8021e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021ea:	89 04 24             	mov    %eax,(%esp)
  8021ed:	e8 0a 06 00 00       	call   8027fc <pageref>
  8021f2:	39 c6                	cmp    %eax,%esi
  8021f4:	0f 94 c0             	sete   %al
  8021f7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021fa:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802200:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802203:	39 cb                	cmp    %ecx,%ebx
  802205:	75 08                	jne    80220f <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802207:	83 c4 2c             	add    $0x2c,%esp
  80220a:	5b                   	pop    %ebx
  80220b:	5e                   	pop    %esi
  80220c:	5f                   	pop    %edi
  80220d:	5d                   	pop    %ebp
  80220e:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80220f:	83 f8 01             	cmp    $0x1,%eax
  802212:	75 c1                	jne    8021d5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802214:	8b 42 58             	mov    0x58(%edx),%eax
  802217:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80221e:	00 
  80221f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802223:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802227:	c7 04 24 c7 30 80 00 	movl   $0x8030c7,(%esp)
  80222e:	e8 f5 e0 ff ff       	call   800328 <cprintf>
  802233:	eb a0                	jmp    8021d5 <_pipeisclosed+0xe>

00802235 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	57                   	push   %edi
  802239:	56                   	push   %esi
  80223a:	53                   	push   %ebx
  80223b:	83 ec 1c             	sub    $0x1c,%esp
  80223e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802241:	89 34 24             	mov    %esi,(%esp)
  802244:	e8 77 f1 ff ff       	call   8013c0 <fd2data>
  802249:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80224b:	bf 00 00 00 00       	mov    $0x0,%edi
  802250:	eb 3c                	jmp    80228e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802252:	89 da                	mov    %ebx,%edx
  802254:	89 f0                	mov    %esi,%eax
  802256:	e8 6c ff ff ff       	call   8021c7 <_pipeisclosed>
  80225b:	85 c0                	test   %eax,%eax
  80225d:	75 38                	jne    802297 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80225f:	e8 42 ea ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802264:	8b 43 04             	mov    0x4(%ebx),%eax
  802267:	8b 13                	mov    (%ebx),%edx
  802269:	83 c2 20             	add    $0x20,%edx
  80226c:	39 d0                	cmp    %edx,%eax
  80226e:	73 e2                	jae    802252 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802270:	8b 55 0c             	mov    0xc(%ebp),%edx
  802273:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802276:	89 c2                	mov    %eax,%edx
  802278:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80227e:	79 05                	jns    802285 <devpipe_write+0x50>
  802280:	4a                   	dec    %edx
  802281:	83 ca e0             	or     $0xffffffe0,%edx
  802284:	42                   	inc    %edx
  802285:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802289:	40                   	inc    %eax
  80228a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80228d:	47                   	inc    %edi
  80228e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802291:	75 d1                	jne    802264 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802293:	89 f8                	mov    %edi,%eax
  802295:	eb 05                	jmp    80229c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802297:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80229c:	83 c4 1c             	add    $0x1c,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5f                   	pop    %edi
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    

008022a4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	57                   	push   %edi
  8022a8:	56                   	push   %esi
  8022a9:	53                   	push   %ebx
  8022aa:	83 ec 1c             	sub    $0x1c,%esp
  8022ad:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022b0:	89 3c 24             	mov    %edi,(%esp)
  8022b3:	e8 08 f1 ff ff       	call   8013c0 <fd2data>
  8022b8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022ba:	be 00 00 00 00       	mov    $0x0,%esi
  8022bf:	eb 3a                	jmp    8022fb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022c1:	85 f6                	test   %esi,%esi
  8022c3:	74 04                	je     8022c9 <devpipe_read+0x25>
				return i;
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	eb 40                	jmp    802309 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022c9:	89 da                	mov    %ebx,%edx
  8022cb:	89 f8                	mov    %edi,%eax
  8022cd:	e8 f5 fe ff ff       	call   8021c7 <_pipeisclosed>
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	75 2e                	jne    802304 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022d6:	e8 cb e9 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022db:	8b 03                	mov    (%ebx),%eax
  8022dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022e0:	74 df                	je     8022c1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022e2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022e7:	79 05                	jns    8022ee <devpipe_read+0x4a>
  8022e9:	48                   	dec    %eax
  8022ea:	83 c8 e0             	or     $0xffffffe0,%eax
  8022ed:	40                   	inc    %eax
  8022ee:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022f8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022fa:	46                   	inc    %esi
  8022fb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022fe:	75 db                	jne    8022db <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802300:	89 f0                	mov    %esi,%eax
  802302:	eb 05                	jmp    802309 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802304:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802309:	83 c4 1c             	add    $0x1c,%esp
  80230c:	5b                   	pop    %ebx
  80230d:	5e                   	pop    %esi
  80230e:	5f                   	pop    %edi
  80230f:	5d                   	pop    %ebp
  802310:	c3                   	ret    

00802311 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802311:	55                   	push   %ebp
  802312:	89 e5                	mov    %esp,%ebp
  802314:	57                   	push   %edi
  802315:	56                   	push   %esi
  802316:	53                   	push   %ebx
  802317:	83 ec 3c             	sub    $0x3c,%esp
  80231a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80231d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802320:	89 04 24             	mov    %eax,(%esp)
  802323:	e8 b3 f0 ff ff       	call   8013db <fd_alloc>
  802328:	89 c3                	mov    %eax,%ebx
  80232a:	85 c0                	test   %eax,%eax
  80232c:	0f 88 45 01 00 00    	js     802477 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802332:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802339:	00 
  80233a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80233d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802341:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802348:	e8 78 e9 ff ff       	call   800cc5 <sys_page_alloc>
  80234d:	89 c3                	mov    %eax,%ebx
  80234f:	85 c0                	test   %eax,%eax
  802351:	0f 88 20 01 00 00    	js     802477 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802357:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80235a:	89 04 24             	mov    %eax,(%esp)
  80235d:	e8 79 f0 ff ff       	call   8013db <fd_alloc>
  802362:	89 c3                	mov    %eax,%ebx
  802364:	85 c0                	test   %eax,%eax
  802366:	0f 88 f8 00 00 00    	js     802464 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802373:	00 
  802374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802382:	e8 3e e9 ff ff       	call   800cc5 <sys_page_alloc>
  802387:	89 c3                	mov    %eax,%ebx
  802389:	85 c0                	test   %eax,%eax
  80238b:	0f 88 d3 00 00 00    	js     802464 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802394:	89 04 24             	mov    %eax,(%esp)
  802397:	e8 24 f0 ff ff       	call   8013c0 <fd2data>
  80239c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80239e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023a5:	00 
  8023a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023b1:	e8 0f e9 ff ff       	call   800cc5 <sys_page_alloc>
  8023b6:	89 c3                	mov    %eax,%ebx
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	0f 88 91 00 00 00    	js     802451 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023c3:	89 04 24             	mov    %eax,(%esp)
  8023c6:	e8 f5 ef ff ff       	call   8013c0 <fd2data>
  8023cb:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023d2:	00 
  8023d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023de:	00 
  8023df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ea:	e8 2a e9 ff ff       	call   800d19 <sys_page_map>
  8023ef:	89 c3                	mov    %eax,%ebx
  8023f1:	85 c0                	test   %eax,%eax
  8023f3:	78 4c                	js     802441 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023f5:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8023fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023fe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802400:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802403:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80240a:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802413:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802415:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802418:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80241f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802422:	89 04 24             	mov    %eax,(%esp)
  802425:	e8 86 ef ff ff       	call   8013b0 <fd2num>
  80242a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80242c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80242f:	89 04 24             	mov    %eax,(%esp)
  802432:	e8 79 ef ff ff       	call   8013b0 <fd2num>
  802437:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80243a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80243f:	eb 36                	jmp    802477 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802441:	89 74 24 04          	mov    %esi,0x4(%esp)
  802445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80244c:	e8 1b e9 ff ff       	call   800d6c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802451:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802454:	89 44 24 04          	mov    %eax,0x4(%esp)
  802458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80245f:	e8 08 e9 ff ff       	call   800d6c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802464:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802472:	e8 f5 e8 ff ff       	call   800d6c <sys_page_unmap>
    err:
	return r;
}
  802477:	89 d8                	mov    %ebx,%eax
  802479:	83 c4 3c             	add    $0x3c,%esp
  80247c:	5b                   	pop    %ebx
  80247d:	5e                   	pop    %esi
  80247e:	5f                   	pop    %edi
  80247f:	5d                   	pop    %ebp
  802480:	c3                   	ret    

00802481 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80248a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248e:	8b 45 08             	mov    0x8(%ebp),%eax
  802491:	89 04 24             	mov    %eax,(%esp)
  802494:	e8 95 ef ff ff       	call   80142e <fd_lookup>
  802499:	85 c0                	test   %eax,%eax
  80249b:	78 15                	js     8024b2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80249d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a0:	89 04 24             	mov    %eax,(%esp)
  8024a3:	e8 18 ef ff ff       	call   8013c0 <fd2data>
	return _pipeisclosed(fd, p);
  8024a8:	89 c2                	mov    %eax,%edx
  8024aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ad:	e8 15 fd ff ff       	call   8021c7 <_pipeisclosed>
}
  8024b2:	c9                   	leave  
  8024b3:	c3                   	ret    

008024b4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8024bc:	5d                   	pop    %ebp
  8024bd:	c3                   	ret    

008024be <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024c4:	c7 44 24 04 df 30 80 	movl   $0x8030df,0x4(%esp)
  8024cb:	00 
  8024cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024cf:	89 04 24             	mov    %eax,(%esp)
  8024d2:	e8 fc e3 ff ff       	call   8008d3 <strcpy>
	return 0;
}
  8024d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8024dc:	c9                   	leave  
  8024dd:	c3                   	ret    

008024de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024de:	55                   	push   %ebp
  8024df:	89 e5                	mov    %esp,%ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024f5:	eb 30                	jmp    802527 <devcons_write+0x49>
		m = n - tot;
  8024f7:	8b 75 10             	mov    0x10(%ebp),%esi
  8024fa:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024fc:	83 fe 7f             	cmp    $0x7f,%esi
  8024ff:	76 05                	jbe    802506 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802501:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802506:	89 74 24 08          	mov    %esi,0x8(%esp)
  80250a:	03 45 0c             	add    0xc(%ebp),%eax
  80250d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802511:	89 3c 24             	mov    %edi,(%esp)
  802514:	e8 33 e5 ff ff       	call   800a4c <memmove>
		sys_cputs(buf, m);
  802519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80251d:	89 3c 24             	mov    %edi,(%esp)
  802520:	e8 d3 e6 ff ff       	call   800bf8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802525:	01 f3                	add    %esi,%ebx
  802527:	89 d8                	mov    %ebx,%eax
  802529:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80252c:	72 c9                	jb     8024f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80252e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802534:	5b                   	pop    %ebx
  802535:	5e                   	pop    %esi
  802536:	5f                   	pop    %edi
  802537:	5d                   	pop    %ebp
  802538:	c3                   	ret    

00802539 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802539:	55                   	push   %ebp
  80253a:	89 e5                	mov    %esp,%ebp
  80253c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80253f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802543:	75 07                	jne    80254c <devcons_read+0x13>
  802545:	eb 25                	jmp    80256c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802547:	e8 5a e7 ff ff       	call   800ca6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80254c:	e8 c5 e6 ff ff       	call   800c16 <sys_cgetc>
  802551:	85 c0                	test   %eax,%eax
  802553:	74 f2                	je     802547 <devcons_read+0xe>
  802555:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802557:	85 c0                	test   %eax,%eax
  802559:	78 1d                	js     802578 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80255b:	83 f8 04             	cmp    $0x4,%eax
  80255e:	74 13                	je     802573 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802560:	8b 45 0c             	mov    0xc(%ebp),%eax
  802563:	88 10                	mov    %dl,(%eax)
	return 1;
  802565:	b8 01 00 00 00       	mov    $0x1,%eax
  80256a:	eb 0c                	jmp    802578 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80256c:	b8 00 00 00 00       	mov    $0x0,%eax
  802571:	eb 05                	jmp    802578 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802573:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802578:	c9                   	leave  
  802579:	c3                   	ret    

0080257a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802580:	8b 45 08             	mov    0x8(%ebp),%eax
  802583:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802586:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80258d:	00 
  80258e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802591:	89 04 24             	mov    %eax,(%esp)
  802594:	e8 5f e6 ff ff       	call   800bf8 <sys_cputs>
}
  802599:	c9                   	leave  
  80259a:	c3                   	ret    

0080259b <getchar>:

int
getchar(void)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8025a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025a8:	00 
  8025a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b7:	e8 0e f1 ff ff       	call   8016ca <read>
	if (r < 0)
  8025bc:	85 c0                	test   %eax,%eax
  8025be:	78 0f                	js     8025cf <getchar+0x34>
		return r;
	if (r < 1)
  8025c0:	85 c0                	test   %eax,%eax
  8025c2:	7e 06                	jle    8025ca <getchar+0x2f>
		return -E_EOF;
	return c;
  8025c4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025c8:	eb 05                	jmp    8025cf <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025ca:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025cf:	c9                   	leave  
  8025d0:	c3                   	ret    

008025d1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025d1:	55                   	push   %ebp
  8025d2:	89 e5                	mov    %esp,%ebp
  8025d4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025de:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e1:	89 04 24             	mov    %eax,(%esp)
  8025e4:	e8 45 ee ff ff       	call   80142e <fd_lookup>
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	78 11                	js     8025fe <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8025f6:	39 10                	cmp    %edx,(%eax)
  8025f8:	0f 94 c0             	sete   %al
  8025fb:	0f b6 c0             	movzbl %al,%eax
}
  8025fe:	c9                   	leave  
  8025ff:	c3                   	ret    

00802600 <opencons>:

int
opencons(void)
{
  802600:	55                   	push   %ebp
  802601:	89 e5                	mov    %esp,%ebp
  802603:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802606:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802609:	89 04 24             	mov    %eax,(%esp)
  80260c:	e8 ca ed ff ff       	call   8013db <fd_alloc>
  802611:	85 c0                	test   %eax,%eax
  802613:	78 3c                	js     802651 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802615:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80261c:	00 
  80261d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802620:	89 44 24 04          	mov    %eax,0x4(%esp)
  802624:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80262b:	e8 95 e6 ff ff       	call   800cc5 <sys_page_alloc>
  802630:	85 c0                	test   %eax,%eax
  802632:	78 1d                	js     802651 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802634:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80263a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80263f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802642:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802649:	89 04 24             	mov    %eax,(%esp)
  80264c:	e8 5f ed ff ff       	call   8013b0 <fd2num>
}
  802651:	c9                   	leave  
  802652:	c3                   	ret    
	...

00802654 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802654:	55                   	push   %ebp
  802655:	89 e5                	mov    %esp,%ebp
  802657:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80265a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802661:	75 58                	jne    8026bb <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  802663:	a1 08 50 80 00       	mov    0x805008,%eax
  802668:	8b 40 48             	mov    0x48(%eax),%eax
  80266b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802672:	00 
  802673:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80267a:	ee 
  80267b:	89 04 24             	mov    %eax,(%esp)
  80267e:	e8 42 e6 ff ff       	call   800cc5 <sys_page_alloc>
  802683:	85 c0                	test   %eax,%eax
  802685:	74 1c                	je     8026a3 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  802687:	c7 44 24 08 eb 30 80 	movl   $0x8030eb,0x8(%esp)
  80268e:	00 
  80268f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802696:	00 
  802697:	c7 04 24 00 31 80 00 	movl   $0x803100,(%esp)
  80269e:	e8 8d db ff ff       	call   800230 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8026a3:	a1 08 50 80 00       	mov    0x805008,%eax
  8026a8:	8b 40 48             	mov    0x48(%eax),%eax
  8026ab:	c7 44 24 04 c8 26 80 	movl   $0x8026c8,0x4(%esp)
  8026b2:	00 
  8026b3:	89 04 24             	mov    %eax,(%esp)
  8026b6:	e8 aa e7 ff ff       	call   800e65 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026be:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    
  8026c5:	00 00                	add    %al,(%eax)
	...

008026c8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026c8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026c9:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8026ce:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026d0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8026d3:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8026d7:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8026d9:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8026dd:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8026de:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8026e1:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8026e3:	58                   	pop    %eax
	popl %eax
  8026e4:	58                   	pop    %eax

	// Pop all registers back
	popal
  8026e5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8026e6:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8026e9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8026ea:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8026eb:	c3                   	ret    

008026ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
  8026ef:	56                   	push   %esi
  8026f0:	53                   	push   %ebx
  8026f1:	83 ec 10             	sub    $0x10,%esp
  8026f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8026f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8026fd:	85 c0                	test   %eax,%eax
  8026ff:	75 05                	jne    802706 <ipc_recv+0x1a>
  802701:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802706:	89 04 24             	mov    %eax,(%esp)
  802709:	e8 cd e7 ff ff       	call   800edb <sys_ipc_recv>
	if (from_env_store != NULL)
  80270e:	85 db                	test   %ebx,%ebx
  802710:	74 0b                	je     80271d <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802712:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802718:	8b 52 74             	mov    0x74(%edx),%edx
  80271b:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  80271d:	85 f6                	test   %esi,%esi
  80271f:	74 0b                	je     80272c <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802721:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802727:	8b 52 78             	mov    0x78(%edx),%edx
  80272a:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  80272c:	85 c0                	test   %eax,%eax
  80272e:	79 16                	jns    802746 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802730:	85 db                	test   %ebx,%ebx
  802732:	74 06                	je     80273a <ipc_recv+0x4e>
			*from_env_store = 0;
  802734:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80273a:	85 f6                	test   %esi,%esi
  80273c:	74 10                	je     80274e <ipc_recv+0x62>
			*perm_store = 0;
  80273e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802744:	eb 08                	jmp    80274e <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802746:	a1 08 50 80 00       	mov    0x805008,%eax
  80274b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80274e:	83 c4 10             	add    $0x10,%esp
  802751:	5b                   	pop    %ebx
  802752:	5e                   	pop    %esi
  802753:	5d                   	pop    %ebp
  802754:	c3                   	ret    

00802755 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802755:	55                   	push   %ebp
  802756:	89 e5                	mov    %esp,%ebp
  802758:	57                   	push   %edi
  802759:	56                   	push   %esi
  80275a:	53                   	push   %ebx
  80275b:	83 ec 1c             	sub    $0x1c,%esp
  80275e:	8b 75 08             	mov    0x8(%ebp),%esi
  802761:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802764:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802767:	eb 2a                	jmp    802793 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802769:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80276c:	74 20                	je     80278e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80276e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802772:	c7 44 24 08 10 31 80 	movl   $0x803110,0x8(%esp)
  802779:	00 
  80277a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802781:	00 
  802782:	c7 04 24 38 31 80 00 	movl   $0x803138,(%esp)
  802789:	e8 a2 da ff ff       	call   800230 <_panic>
		sys_yield();
  80278e:	e8 13 e5 ff ff       	call   800ca6 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802793:	85 db                	test   %ebx,%ebx
  802795:	75 07                	jne    80279e <ipc_send+0x49>
  802797:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80279c:	eb 02                	jmp    8027a0 <ipc_send+0x4b>
  80279e:	89 d8                	mov    %ebx,%eax
  8027a0:	8b 55 14             	mov    0x14(%ebp),%edx
  8027a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027af:	89 34 24             	mov    %esi,(%esp)
  8027b2:	e8 01 e7 ff ff       	call   800eb8 <sys_ipc_try_send>
  8027b7:	85 c0                	test   %eax,%eax
  8027b9:	78 ae                	js     802769 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8027bb:	83 c4 1c             	add    $0x1c,%esp
  8027be:	5b                   	pop    %ebx
  8027bf:	5e                   	pop    %esi
  8027c0:	5f                   	pop    %edi
  8027c1:	5d                   	pop    %ebp
  8027c2:	c3                   	ret    

008027c3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027c3:	55                   	push   %ebp
  8027c4:	89 e5                	mov    %esp,%ebp
  8027c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027c9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027ce:	89 c2                	mov    %eax,%edx
  8027d0:	c1 e2 07             	shl    $0x7,%edx
  8027d3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027d9:	8b 52 50             	mov    0x50(%edx),%edx
  8027dc:	39 ca                	cmp    %ecx,%edx
  8027de:	75 0d                	jne    8027ed <ipc_find_env+0x2a>
			return envs[i].env_id;
  8027e0:	c1 e0 07             	shl    $0x7,%eax
  8027e3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8027e8:	8b 40 40             	mov    0x40(%eax),%eax
  8027eb:	eb 0c                	jmp    8027f9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027ed:	40                   	inc    %eax
  8027ee:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027f3:	75 d9                	jne    8027ce <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027f5:	66 b8 00 00          	mov    $0x0,%ax
}
  8027f9:	5d                   	pop    %ebp
  8027fa:	c3                   	ret    
	...

008027fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027fc:	55                   	push   %ebp
  8027fd:	89 e5                	mov    %esp,%ebp
  8027ff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802802:	89 c2                	mov    %eax,%edx
  802804:	c1 ea 16             	shr    $0x16,%edx
  802807:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80280e:	f6 c2 01             	test   $0x1,%dl
  802811:	74 1e                	je     802831 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802813:	c1 e8 0c             	shr    $0xc,%eax
  802816:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80281d:	a8 01                	test   $0x1,%al
  80281f:	74 17                	je     802838 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802821:	c1 e8 0c             	shr    $0xc,%eax
  802824:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80282b:	ef 
  80282c:	0f b7 c0             	movzwl %ax,%eax
  80282f:	eb 0c                	jmp    80283d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802831:	b8 00 00 00 00       	mov    $0x0,%eax
  802836:	eb 05                	jmp    80283d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802838:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80283d:	5d                   	pop    %ebp
  80283e:	c3                   	ret    
	...

00802840 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802840:	55                   	push   %ebp
  802841:	57                   	push   %edi
  802842:	56                   	push   %esi
  802843:	83 ec 10             	sub    $0x10,%esp
  802846:	8b 74 24 20          	mov    0x20(%esp),%esi
  80284a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80284e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802852:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802856:	89 cd                	mov    %ecx,%ebp
  802858:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80285c:	85 c0                	test   %eax,%eax
  80285e:	75 2c                	jne    80288c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802860:	39 f9                	cmp    %edi,%ecx
  802862:	77 68                	ja     8028cc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802864:	85 c9                	test   %ecx,%ecx
  802866:	75 0b                	jne    802873 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802868:	b8 01 00 00 00       	mov    $0x1,%eax
  80286d:	31 d2                	xor    %edx,%edx
  80286f:	f7 f1                	div    %ecx
  802871:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802873:	31 d2                	xor    %edx,%edx
  802875:	89 f8                	mov    %edi,%eax
  802877:	f7 f1                	div    %ecx
  802879:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80287b:	89 f0                	mov    %esi,%eax
  80287d:	f7 f1                	div    %ecx
  80287f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802881:	89 f0                	mov    %esi,%eax
  802883:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802885:	83 c4 10             	add    $0x10,%esp
  802888:	5e                   	pop    %esi
  802889:	5f                   	pop    %edi
  80288a:	5d                   	pop    %ebp
  80288b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80288c:	39 f8                	cmp    %edi,%eax
  80288e:	77 2c                	ja     8028bc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802890:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802893:	83 f6 1f             	xor    $0x1f,%esi
  802896:	75 4c                	jne    8028e4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802898:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80289a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80289f:	72 0a                	jb     8028ab <__udivdi3+0x6b>
  8028a1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8028a5:	0f 87 ad 00 00 00    	ja     802958 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028ab:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028b0:	89 f0                	mov    %esi,%eax
  8028b2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028b4:	83 c4 10             	add    $0x10,%esp
  8028b7:	5e                   	pop    %esi
  8028b8:	5f                   	pop    %edi
  8028b9:	5d                   	pop    %ebp
  8028ba:	c3                   	ret    
  8028bb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028bc:	31 ff                	xor    %edi,%edi
  8028be:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028c0:	89 f0                	mov    %esi,%eax
  8028c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028c4:	83 c4 10             	add    $0x10,%esp
  8028c7:	5e                   	pop    %esi
  8028c8:	5f                   	pop    %edi
  8028c9:	5d                   	pop    %ebp
  8028ca:	c3                   	ret    
  8028cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028cc:	89 fa                	mov    %edi,%edx
  8028ce:	89 f0                	mov    %esi,%eax
  8028d0:	f7 f1                	div    %ecx
  8028d2:	89 c6                	mov    %eax,%esi
  8028d4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028d6:	89 f0                	mov    %esi,%eax
  8028d8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028da:	83 c4 10             	add    $0x10,%esp
  8028dd:	5e                   	pop    %esi
  8028de:	5f                   	pop    %edi
  8028df:	5d                   	pop    %ebp
  8028e0:	c3                   	ret    
  8028e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028e4:	89 f1                	mov    %esi,%ecx
  8028e6:	d3 e0                	shl    %cl,%eax
  8028e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8028f1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8028f3:	89 ea                	mov    %ebp,%edx
  8028f5:	88 c1                	mov    %al,%cl
  8028f7:	d3 ea                	shr    %cl,%edx
  8028f9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8028fd:	09 ca                	or     %ecx,%edx
  8028ff:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802903:	89 f1                	mov    %esi,%ecx
  802905:	d3 e5                	shl    %cl,%ebp
  802907:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80290b:	89 fd                	mov    %edi,%ebp
  80290d:	88 c1                	mov    %al,%cl
  80290f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802911:	89 fa                	mov    %edi,%edx
  802913:	89 f1                	mov    %esi,%ecx
  802915:	d3 e2                	shl    %cl,%edx
  802917:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80291b:	88 c1                	mov    %al,%cl
  80291d:	d3 ef                	shr    %cl,%edi
  80291f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802921:	89 f8                	mov    %edi,%eax
  802923:	89 ea                	mov    %ebp,%edx
  802925:	f7 74 24 08          	divl   0x8(%esp)
  802929:	89 d1                	mov    %edx,%ecx
  80292b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80292d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802931:	39 d1                	cmp    %edx,%ecx
  802933:	72 17                	jb     80294c <__udivdi3+0x10c>
  802935:	74 09                	je     802940 <__udivdi3+0x100>
  802937:	89 fe                	mov    %edi,%esi
  802939:	31 ff                	xor    %edi,%edi
  80293b:	e9 41 ff ff ff       	jmp    802881 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802940:	8b 54 24 04          	mov    0x4(%esp),%edx
  802944:	89 f1                	mov    %esi,%ecx
  802946:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802948:	39 c2                	cmp    %eax,%edx
  80294a:	73 eb                	jae    802937 <__udivdi3+0xf7>
		{
		  q0--;
  80294c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80294f:	31 ff                	xor    %edi,%edi
  802951:	e9 2b ff ff ff       	jmp    802881 <__udivdi3+0x41>
  802956:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802958:	31 f6                	xor    %esi,%esi
  80295a:	e9 22 ff ff ff       	jmp    802881 <__udivdi3+0x41>
	...

00802960 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802960:	55                   	push   %ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	83 ec 20             	sub    $0x20,%esp
  802966:	8b 44 24 30          	mov    0x30(%esp),%eax
  80296a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80296e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802972:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802976:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80297a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80297e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802980:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802982:	85 ed                	test   %ebp,%ebp
  802984:	75 16                	jne    80299c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802986:	39 f1                	cmp    %esi,%ecx
  802988:	0f 86 a6 00 00 00    	jbe    802a34 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80298e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802990:	89 d0                	mov    %edx,%eax
  802992:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802994:	83 c4 20             	add    $0x20,%esp
  802997:	5e                   	pop    %esi
  802998:	5f                   	pop    %edi
  802999:	5d                   	pop    %ebp
  80299a:	c3                   	ret    
  80299b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80299c:	39 f5                	cmp    %esi,%ebp
  80299e:	0f 87 ac 00 00 00    	ja     802a50 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029a4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8029a7:	83 f0 1f             	xor    $0x1f,%eax
  8029aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029ae:	0f 84 a8 00 00 00    	je     802a5c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029b4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029b8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029ba:	bf 20 00 00 00       	mov    $0x20,%edi
  8029bf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8029c3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029c7:	89 f9                	mov    %edi,%ecx
  8029c9:	d3 e8                	shr    %cl,%eax
  8029cb:	09 e8                	or     %ebp,%eax
  8029cd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8029d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029d5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029d9:	d3 e0                	shl    %cl,%eax
  8029db:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029df:	89 f2                	mov    %esi,%edx
  8029e1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8029e3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029e7:	d3 e0                	shl    %cl,%eax
  8029e9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8029ed:	8b 44 24 14          	mov    0x14(%esp),%eax
  8029f1:	89 f9                	mov    %edi,%ecx
  8029f3:	d3 e8                	shr    %cl,%eax
  8029f5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8029f7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8029f9:	89 f2                	mov    %esi,%edx
  8029fb:	f7 74 24 18          	divl   0x18(%esp)
  8029ff:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a01:	f7 64 24 0c          	mull   0xc(%esp)
  802a05:	89 c5                	mov    %eax,%ebp
  802a07:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a09:	39 d6                	cmp    %edx,%esi
  802a0b:	72 67                	jb     802a74 <__umoddi3+0x114>
  802a0d:	74 75                	je     802a84 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802a0f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802a13:	29 e8                	sub    %ebp,%eax
  802a15:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802a17:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a1b:	d3 e8                	shr    %cl,%eax
  802a1d:	89 f2                	mov    %esi,%edx
  802a1f:	89 f9                	mov    %edi,%ecx
  802a21:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802a23:	09 d0                	or     %edx,%eax
  802a25:	89 f2                	mov    %esi,%edx
  802a27:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a2b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a2d:	83 c4 20             	add    $0x20,%esp
  802a30:	5e                   	pop    %esi
  802a31:	5f                   	pop    %edi
  802a32:	5d                   	pop    %ebp
  802a33:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a34:	85 c9                	test   %ecx,%ecx
  802a36:	75 0b                	jne    802a43 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802a38:	b8 01 00 00 00       	mov    $0x1,%eax
  802a3d:	31 d2                	xor    %edx,%edx
  802a3f:	f7 f1                	div    %ecx
  802a41:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a43:	89 f0                	mov    %esi,%eax
  802a45:	31 d2                	xor    %edx,%edx
  802a47:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a49:	89 f8                	mov    %edi,%eax
  802a4b:	e9 3e ff ff ff       	jmp    80298e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a50:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a52:	83 c4 20             	add    $0x20,%esp
  802a55:	5e                   	pop    %esi
  802a56:	5f                   	pop    %edi
  802a57:	5d                   	pop    %ebp
  802a58:	c3                   	ret    
  802a59:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a5c:	39 f5                	cmp    %esi,%ebp
  802a5e:	72 04                	jb     802a64 <__umoddi3+0x104>
  802a60:	39 f9                	cmp    %edi,%ecx
  802a62:	77 06                	ja     802a6a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a64:	89 f2                	mov    %esi,%edx
  802a66:	29 cf                	sub    %ecx,%edi
  802a68:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802a6a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a6c:	83 c4 20             	add    $0x20,%esp
  802a6f:	5e                   	pop    %esi
  802a70:	5f                   	pop    %edi
  802a71:	5d                   	pop    %ebp
  802a72:	c3                   	ret    
  802a73:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a74:	89 d1                	mov    %edx,%ecx
  802a76:	89 c5                	mov    %eax,%ebp
  802a78:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802a7c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802a80:	eb 8d                	jmp    802a0f <__umoddi3+0xaf>
  802a82:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a84:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802a88:	72 ea                	jb     802a74 <__umoddi3+0x114>
  802a8a:	89 f1                	mov    %esi,%ecx
  802a8c:	eb 81                	jmp    802a0f <__umoddi3+0xaf>
