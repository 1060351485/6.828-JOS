
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
  80002c:	e8 ab 01 00 00       	call   8001dc <libmain>
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
  80003d:	c7 04 24 40 25 80 00 	movl   $0x802540,(%esp)
  800044:	e8 f3 02 00 00       	call   80033c <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 5d 1d 00 00       	call   801db1 <pipe>
  800054:	85 c0                	test   %eax,%eax
  800056:	79 20                	jns    800078 <umain+0x44>
		panic("pipe: %e", r);
  800058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005c:	c7 44 24 08 8e 25 80 	movl   $0x80258e,0x8(%esp)
  800063:	00 
  800064:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006b:	00 
  80006c:	c7 04 24 97 25 80 00 	movl   $0x802597,(%esp)
  800073:	e8 cc 01 00 00       	call   800244 <_panic>
	if ((r = fork()) < 0)
  800078:	e8 d6 0f 00 00       	call   801053 <fork>
  80007d:	89 c7                	mov    %eax,%edi
  80007f:	85 c0                	test   %eax,%eax
  800081:	79 20                	jns    8000a3 <umain+0x6f>
		panic("fork: %e", r);
  800083:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800087:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  80008e:	00 
  80008f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800096:	00 
  800097:	c7 04 24 97 25 80 00 	movl   $0x802597,(%esp)
  80009e:	e8 a1 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	75 5d                	jne    800104 <umain+0xd0>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  8000a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 50 14 00 00       	call   801502 <close>
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
  8000c9:	c7 04 24 b5 25 80 00 	movl   $0x8025b5,(%esp)
  8000d0:	e8 67 02 00 00       	call   80033c <cprintf>
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8000dc:	89 04 24             	mov    %eax,(%esp)
  8000df:	e8 6f 14 00 00       	call   801553 <dup>
			sys_yield();
  8000e4:	e8 d1 0b 00 00       	call   800cba <sys_yield>
			close(10);
  8000e9:	89 1c 24             	mov    %ebx,(%esp)
  8000ec:	e8 11 14 00 00       	call   801502 <close>
			sys_yield();
  8000f1:	e8 c4 0b 00 00       	call   800cba <sys_yield>
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
  8000ff:	e8 2c 01 00 00       	call   800230 <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800104:	89 f8                	mov    %edi,%eax
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800112:	c1 e0 07             	shl    $0x7,%eax
  800115:	29 d0                	sub    %edx,%eax
  800117:	8d 98 00 00 c0 ee    	lea    -0x11400000(%eax),%ebx
	while (kid->env_status == ENV_RUNNABLE)
  80011d:	eb 28                	jmp    800147 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  80011f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 f7 1d 00 00       	call   801f21 <pipeisclosed>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	74 19                	je     800147 <umain+0x113>
			cprintf("\nRACE: pipe appears closed\n");
  80012e:	c7 04 24 b9 25 80 00 	movl   $0x8025b9,(%esp)
  800135:	e8 02 02 00 00       	call   80033c <cprintf>
			sys_env_destroy(r);
  80013a:	89 3c 24             	mov    %edi,(%esp)
  80013d:	e8 07 0b 00 00       	call   800c49 <sys_env_destroy>
			exit();
  800142:	e8 e9 00 00 00       	call   800230 <exit>
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800147:	8b 43 54             	mov    0x54(%ebx),%eax
  80014a:	83 f8 02             	cmp    $0x2,%eax
  80014d:	74 d0                	je     80011f <umain+0xeb>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  80014f:	c7 04 24 d5 25 80 00 	movl   $0x8025d5,(%esp)
  800156:	e8 e1 01 00 00       	call   80033c <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 bb 1d 00 00       	call   801f21 <pipeisclosed>
  800166:	85 c0                	test   %eax,%eax
  800168:	74 1c                	je     800186 <umain+0x152>
		panic("somehow the other end of p[0] got closed!");
  80016a:	c7 44 24 08 64 25 80 	movl   $0x802564,0x8(%esp)
  800171:	00 
  800172:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  800179:	00 
  80017a:	c7 04 24 97 25 80 00 	movl   $0x802597,(%esp)
  800181:	e8 be 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800186:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 32 12 00 00       	call   8013ca <fd_lookup>
  800198:	85 c0                	test   %eax,%eax
  80019a:	79 20                	jns    8001bc <umain+0x188>
		panic("cannot look up p[0]: %e", r);
  80019c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a0:	c7 44 24 08 eb 25 80 	movl   $0x8025eb,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 97 25 80 00 	movl   $0x802597,(%esp)
  8001b7:	e8 88 00 00 00       	call   800244 <_panic>
	(void) fd2data(fd);
  8001bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 95 11 00 00       	call   80135c <fd2data>
	cprintf("race didn't happen\n");
  8001c7:	c7 04 24 03 26 80 00 	movl   $0x802603,(%esp)
  8001ce:	e8 69 01 00 00       	call   80033c <cprintf>
}
  8001d3:	83 c4 2c             	add    $0x2c,%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    
	...

008001dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 10             	sub    $0x10,%esp
  8001e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ea:	e8 ac 0a 00 00       	call   800c9b <sys_getenvid>
  8001ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001fb:	c1 e0 07             	shl    $0x7,%eax
  8001fe:	29 d0                	sub    %edx,%eax
  800200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800205:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020a:	85 f6                	test   %esi,%esi
  80020c:	7e 07                	jle    800215 <libmain+0x39>
		binaryname = argv[0];
  80020e:	8b 03                	mov    (%ebx),%eax
  800210:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800215:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800219:	89 34 24             	mov    %esi,(%esp)
  80021c:	e8 13 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800221:	e8 0a 00 00 00       	call   800230 <exit>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    
  80022d:	00 00                	add    %al,(%eax)
	...

00800230 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023d:	e8 07 0a 00 00       	call   800c49 <sys_env_destroy>
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80024c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800255:	e8 41 0a 00 00       	call   800c9b <sys_getenvid>
  80025a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800268:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80026c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800270:	c7 04 24 24 26 80 00 	movl   $0x802624,(%esp)
  800277:	e8 c0 00 00 00       	call   80033c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80027c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800280:	8b 45 10             	mov    0x10(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 50 00 00 00       	call   8002db <vcprintf>
	cprintf("\n");
  80028b:	c7 04 24 33 2b 80 00 	movl   $0x802b33,(%esp)
  800292:	e8 a5 00 00 00       	call   80033c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800297:	cc                   	int3   
  800298:	eb fd                	jmp    800297 <_panic+0x53>
	...

0080029c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 14             	sub    $0x14,%esp
  8002a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a6:	8b 03                	mov    (%ebx),%eax
  8002a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ab:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002af:	40                   	inc    %eax
  8002b0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b7:	75 19                	jne    8002d2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002b9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c0:	00 
  8002c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c4:	89 04 24             	mov    %eax,(%esp)
  8002c7:	e8 40 09 00 00       	call   800c0c <sys_cputs>
		b->idx = 0;
  8002cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d2:	ff 43 04             	incl   0x4(%ebx)
}
  8002d5:	83 c4 14             	add    $0x14,%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8002e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002eb:	00 00 00 
	b.cnt = 0;
  8002ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	89 44 24 08          	mov    %eax,0x8(%esp)
  800306:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	c7 04 24 9c 02 80 00 	movl   $0x80029c,(%esp)
  800317:	e8 82 01 00 00       	call   80049e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800322:	89 44 24 04          	mov    %eax,0x4(%esp)
  800326:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	e8 d8 08 00 00       	call   800c0c <sys_cputs>

	return b.cnt;
}
  800334:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800342:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800345:	89 44 24 04          	mov    %eax,0x4(%esp)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	89 04 24             	mov    %eax,(%esp)
  80034f:	e8 87 ff ff ff       	call   8002db <vcprintf>
	va_end(ap);

	return cnt;
}
  800354:	c9                   	leave  
  800355:	c3                   	ret    
	...

00800358 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
  80035e:	83 ec 3c             	sub    $0x3c,%esp
  800361:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800364:	89 d7                	mov    %edx,%edi
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800372:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800375:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800378:	85 c0                	test   %eax,%eax
  80037a:	75 08                	jne    800384 <printnum+0x2c>
  80037c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800382:	77 57                	ja     8003db <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800384:	89 74 24 10          	mov    %esi,0x10(%esp)
  800388:	4b                   	dec    %ebx
  800389:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80038d:	8b 45 10             	mov    0x10(%ebp),%eax
  800390:	89 44 24 08          	mov    %eax,0x8(%esp)
  800394:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800398:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80039c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a3:	00 
  8003a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a7:	89 04 24             	mov    %eax,(%esp)
  8003aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	e8 36 1f 00 00       	call   8022ec <__udivdi3>
  8003b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003ba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003be:	89 04 24             	mov    %eax,(%esp)
  8003c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003c5:	89 fa                	mov    %edi,%edx
  8003c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ca:	e8 89 ff ff ff       	call   800358 <printnum>
  8003cf:	eb 0f                	jmp    8003e0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d5:	89 34 24             	mov    %esi,(%esp)
  8003d8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003db:	4b                   	dec    %ebx
  8003dc:	85 db                	test   %ebx,%ebx
  8003de:	7f f1                	jg     8003d1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8003e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f6:	00 
  8003f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fa:	89 04 24             	mov    %eax,(%esp)
  8003fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800400:	89 44 24 04          	mov    %eax,0x4(%esp)
  800404:	e8 03 20 00 00       	call   80240c <__umoddi3>
  800409:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040d:	0f be 80 47 26 80 00 	movsbl 0x802647(%eax),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80041a:	83 c4 3c             	add    $0x3c,%esp
  80041d:	5b                   	pop    %ebx
  80041e:	5e                   	pop    %esi
  80041f:	5f                   	pop    %edi
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800425:	83 fa 01             	cmp    $0x1,%edx
  800428:	7e 0e                	jle    800438 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80042a:	8b 10                	mov    (%eax),%edx
  80042c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80042f:	89 08                	mov    %ecx,(%eax)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	8b 52 04             	mov    0x4(%edx),%edx
  800436:	eb 22                	jmp    80045a <getuint+0x38>
	else if (lflag)
  800438:	85 d2                	test   %edx,%edx
  80043a:	74 10                	je     80044c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800441:	89 08                	mov    %ecx,(%eax)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	ba 00 00 00 00       	mov    $0x0,%edx
  80044a:	eb 0e                	jmp    80045a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80044c:	8b 10                	mov    (%eax),%edx
  80044e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800451:	89 08                	mov    %ecx,(%eax)
  800453:	8b 02                	mov    (%edx),%eax
  800455:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800462:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800465:	8b 10                	mov    (%eax),%edx
  800467:	3b 50 04             	cmp    0x4(%eax),%edx
  80046a:	73 08                	jae    800474 <sprintputch+0x18>
		*b->buf++ = ch;
  80046c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046f:	88 0a                	mov    %cl,(%edx)
  800471:	42                   	inc    %edx
  800472:	89 10                	mov    %edx,(%eax)
}
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80047c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80047f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800483:	8b 45 10             	mov    0x10(%ebp),%eax
  800486:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 02 00 00 00       	call   80049e <vprintfmt>
	va_end(ap);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    

0080049e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	57                   	push   %edi
  8004a2:	56                   	push   %esi
  8004a3:	53                   	push   %ebx
  8004a4:	83 ec 4c             	sub    $0x4c,%esp
  8004a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004aa:	8b 75 10             	mov    0x10(%ebp),%esi
  8004ad:	eb 12                	jmp    8004c1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	0f 84 6b 03 00 00    	je     800822 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004bb:	89 04 24             	mov    %eax,(%esp)
  8004be:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004c1:	0f b6 06             	movzbl (%esi),%eax
  8004c4:	46                   	inc    %esi
  8004c5:	83 f8 25             	cmp    $0x25,%eax
  8004c8:	75 e5                	jne    8004af <vprintfmt+0x11>
  8004ca:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004ce:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004da:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8004e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004e6:	eb 26                	jmp    80050e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004eb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004ef:	eb 1d                	jmp    80050e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004f4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004f8:	eb 14                	jmp    80050e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800504:	eb 08                	jmp    80050e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800506:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800509:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	0f b6 06             	movzbl (%esi),%eax
  800511:	8d 56 01             	lea    0x1(%esi),%edx
  800514:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800517:	8a 16                	mov    (%esi),%dl
  800519:	83 ea 23             	sub    $0x23,%edx
  80051c:	80 fa 55             	cmp    $0x55,%dl
  80051f:	0f 87 e1 02 00 00    	ja     800806 <vprintfmt+0x368>
  800525:	0f b6 d2             	movzbl %dl,%edx
  800528:	ff 24 95 80 27 80 00 	jmp    *0x802780(,%edx,4)
  80052f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800532:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800537:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80053a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80053e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800541:	8d 50 d0             	lea    -0x30(%eax),%edx
  800544:	83 fa 09             	cmp    $0x9,%edx
  800547:	77 2a                	ja     800573 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800549:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80054a:	eb eb                	jmp    800537 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80055a:	eb 17                	jmp    800573 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80055c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800560:	78 98                	js     8004fa <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800565:	eb a7                	jmp    80050e <vprintfmt+0x70>
  800567:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80056a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800571:	eb 9b                	jmp    80050e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800573:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800577:	79 95                	jns    80050e <vprintfmt+0x70>
  800579:	eb 8b                	jmp    800506 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80057b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80057f:	eb 8d                	jmp    80050e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 04 24             	mov    %eax,(%esp)
  800593:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800599:	e9 23 ff ff ff       	jmp    8004c1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 50 04             	lea    0x4(%eax),%edx
  8005a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	79 02                	jns    8005af <vprintfmt+0x111>
  8005ad:	f7 d8                	neg    %eax
  8005af:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b1:	83 f8 0f             	cmp    $0xf,%eax
  8005b4:	7f 0b                	jg     8005c1 <vprintfmt+0x123>
  8005b6:	8b 04 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%eax
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	75 23                	jne    8005e4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c5:	c7 44 24 08 5f 26 80 	movl   $0x80265f,0x8(%esp)
  8005cc:	00 
  8005cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	e8 9a fe ff ff       	call   800476 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005df:	e9 dd fe ff ff       	jmp    8004c1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8005e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e8:	c7 44 24 08 01 2b 80 	movl   $0x802b01,0x8(%esp)
  8005ef:	00 
  8005f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f7:	89 14 24             	mov    %edx,(%esp)
  8005fa:	e8 77 fe ff ff       	call   800476 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800602:	e9 ba fe ff ff       	jmp    8004c1 <vprintfmt+0x23>
  800607:	89 f9                	mov    %edi,%ecx
  800609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
  800618:	8b 30                	mov    (%eax),%esi
  80061a:	85 f6                	test   %esi,%esi
  80061c:	75 05                	jne    800623 <vprintfmt+0x185>
				p = "(null)";
  80061e:	be 58 26 80 00       	mov    $0x802658,%esi
			if (width > 0 && padc != '-')
  800623:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800627:	0f 8e 84 00 00 00    	jle    8006b1 <vprintfmt+0x213>
  80062d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800631:	74 7e                	je     8006b1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800633:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	e8 8b 02 00 00       	call   8008ca <strnlen>
  80063f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800642:	29 c2                	sub    %eax,%edx
  800644:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800647:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80064b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80064e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800651:	89 de                	mov    %ebx,%esi
  800653:	89 d3                	mov    %edx,%ebx
  800655:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800657:	eb 0b                	jmp    800664 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065d:	89 3c 24             	mov    %edi,(%esp)
  800660:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800663:	4b                   	dec    %ebx
  800664:	85 db                	test   %ebx,%ebx
  800666:	7f f1                	jg     800659 <vprintfmt+0x1bb>
  800668:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80066b:	89 f3                	mov    %esi,%ebx
  80066d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800673:	85 c0                	test   %eax,%eax
  800675:	79 05                	jns    80067c <vprintfmt+0x1de>
  800677:	b8 00 00 00 00       	mov    $0x0,%eax
  80067c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067f:	29 c2                	sub    %eax,%edx
  800681:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800684:	eb 2b                	jmp    8006b1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800686:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068a:	74 18                	je     8006a4 <vprintfmt+0x206>
  80068c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80068f:	83 fa 5e             	cmp    $0x5e,%edx
  800692:	76 10                	jbe    8006a4 <vprintfmt+0x206>
					putch('?', putdat);
  800694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800698:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
  8006a2:	eb 0a                	jmp    8006ae <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ae:	ff 4d e4             	decl   -0x1c(%ebp)
  8006b1:	0f be 06             	movsbl (%esi),%eax
  8006b4:	46                   	inc    %esi
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 21                	je     8006da <vprintfmt+0x23c>
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	78 c9                	js     800686 <vprintfmt+0x1e8>
  8006bd:	4f                   	dec    %edi
  8006be:	79 c6                	jns    800686 <vprintfmt+0x1e8>
  8006c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c3:	89 de                	mov    %ebx,%esi
  8006c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006c8:	eb 18                	jmp    8006e2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ce:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006d5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006d7:	4b                   	dec    %ebx
  8006d8:	eb 08                	jmp    8006e2 <vprintfmt+0x244>
  8006da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006dd:	89 de                	mov    %ebx,%esi
  8006df:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006e2:	85 db                	test   %ebx,%ebx
  8006e4:	7f e4                	jg     8006ca <vprintfmt+0x22c>
  8006e6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8006e9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ee:	e9 ce fd ff ff       	jmp    8004c1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7e 10                	jle    800708 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 50 08             	lea    0x8(%eax),%edx
  8006fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800701:	8b 30                	mov    (%eax),%esi
  800703:	8b 78 04             	mov    0x4(%eax),%edi
  800706:	eb 26                	jmp    80072e <vprintfmt+0x290>
	else if (lflag)
  800708:	85 c9                	test   %ecx,%ecx
  80070a:	74 12                	je     80071e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 50 04             	lea    0x4(%eax),%edx
  800712:	89 55 14             	mov    %edx,0x14(%ebp)
  800715:	8b 30                	mov    (%eax),%esi
  800717:	89 f7                	mov    %esi,%edi
  800719:	c1 ff 1f             	sar    $0x1f,%edi
  80071c:	eb 10                	jmp    80072e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 50 04             	lea    0x4(%eax),%edx
  800724:	89 55 14             	mov    %edx,0x14(%ebp)
  800727:	8b 30                	mov    (%eax),%esi
  800729:	89 f7                	mov    %esi,%edi
  80072b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80072e:	85 ff                	test   %edi,%edi
  800730:	78 0a                	js     80073c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800732:	b8 0a 00 00 00       	mov    $0xa,%eax
  800737:	e9 8c 00 00 00       	jmp    8007c8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800747:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80074a:	f7 de                	neg    %esi
  80074c:	83 d7 00             	adc    $0x0,%edi
  80074f:	f7 df                	neg    %edi
			}
			base = 10;
  800751:	b8 0a 00 00 00       	mov    $0xa,%eax
  800756:	eb 70                	jmp    8007c8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800758:	89 ca                	mov    %ecx,%edx
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 c0 fc ff ff       	call   800422 <getuint>
  800762:	89 c6                	mov    %eax,%esi
  800764:	89 d7                	mov    %edx,%edi
			base = 10;
  800766:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80076b:	eb 5b                	jmp    8007c8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80076d:	89 ca                	mov    %ecx,%edx
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 ab fc ff ff       	call   800422 <getuint>
  800777:	89 c6                	mov    %eax,%esi
  800779:	89 d7                	mov    %edx,%edi
			base = 8;
  80077b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800780:	eb 46                	jmp    8007c8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800782:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800786:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 04             	lea    0x4(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007a7:	8b 30                	mov    (%eax),%esi
  8007a9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007ae:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007b3:	eb 13                	jmp    8007c8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b5:	89 ca                	mov    %ecx,%edx
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ba:	e8 63 fc ff ff       	call   800422 <getuint>
  8007bf:	89 c6                	mov    %eax,%esi
  8007c1:	89 d7                	mov    %edx,%edi
			base = 16;
  8007c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007db:	89 34 24             	mov    %esi,(%esp)
  8007de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e2:	89 da                	mov    %ebx,%edx
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	e8 6c fb ff ff       	call   800358 <printnum>
			break;
  8007ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007ef:	e9 cd fc ff ff       	jmp    8004c1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f8:	89 04 24             	mov    %eax,(%esp)
  8007fb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800801:	e9 bb fc ff ff       	jmp    8004c1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800806:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80080a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800811:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800814:	eb 01                	jmp    800817 <vprintfmt+0x379>
  800816:	4e                   	dec    %esi
  800817:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80081b:	75 f9                	jne    800816 <vprintfmt+0x378>
  80081d:	e9 9f fc ff ff       	jmp    8004c1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800822:	83 c4 4c             	add    $0x4c,%esp
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5f                   	pop    %edi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 28             	sub    $0x28,%esp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800836:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800839:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80083d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800840:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800847:	85 c0                	test   %eax,%eax
  800849:	74 30                	je     80087b <vsnprintf+0x51>
  80084b:	85 d2                	test   %edx,%edx
  80084d:	7e 33                	jle    800882 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800856:	8b 45 10             	mov    0x10(%ebp),%eax
  800859:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	c7 04 24 5c 04 80 00 	movl   $0x80045c,(%esp)
  80086b:	e8 2e fc ff ff       	call   80049e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800870:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800873:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	eb 0c                	jmp    800887 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80087b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800880:	eb 05                	jmp    800887 <vsnprintf+0x5d>
  800882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800892:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800896:	8b 45 10             	mov    0x10(%ebp),%eax
  800899:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 7b ff ff ff       	call   80082a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    
  8008b1:	00 00                	add    %al,(%eax)
	...

008008b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bf:	eb 01                	jmp    8008c2 <strlen+0xe>
		n++;
  8008c1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c6:	75 f9                	jne    8008c1 <strlen+0xd>
		n++;
	return n;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb 01                	jmp    8008db <strnlen+0x11>
		n++;
  8008da:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008db:	39 d0                	cmp    %edx,%eax
  8008dd:	74 06                	je     8008e5 <strnlen+0x1b>
  8008df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e3:	75 f5                	jne    8008da <strnlen+0x10>
		n++;
	return n;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008f9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008fc:	42                   	inc    %edx
  8008fd:	84 c9                	test   %cl,%cl
  8008ff:	75 f5                	jne    8008f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090e:	89 1c 24             	mov    %ebx,(%esp)
  800911:	e8 9e ff ff ff       	call   8008b4 <strlen>
	strcpy(dst + len, src);
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
  800919:	89 54 24 04          	mov    %edx,0x4(%esp)
  80091d:	01 d8                	add    %ebx,%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	e8 c0 ff ff ff       	call   8008e7 <strcpy>
	return dst;
}
  800927:	89 d8                	mov    %ebx,%eax
  800929:	83 c4 08             	add    $0x8,%esp
  80092c:	5b                   	pop    %ebx
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800942:	eb 0c                	jmp    800950 <strncpy+0x21>
		*dst++ = *src;
  800944:	8a 1a                	mov    (%edx),%bl
  800946:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800949:	80 3a 01             	cmpb   $0x1,(%edx)
  80094c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094f:	41                   	inc    %ecx
  800950:	39 f1                	cmp    %esi,%ecx
  800952:	75 f0                	jne    800944 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 75 08             	mov    0x8(%ebp),%esi
  800960:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800963:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	85 d2                	test   %edx,%edx
  800968:	75 0a                	jne    800974 <strlcpy+0x1c>
  80096a:	89 f0                	mov    %esi,%eax
  80096c:	eb 1a                	jmp    800988 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096e:	88 18                	mov    %bl,(%eax)
  800970:	40                   	inc    %eax
  800971:	41                   	inc    %ecx
  800972:	eb 02                	jmp    800976 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800974:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800976:	4a                   	dec    %edx
  800977:	74 0a                	je     800983 <strlcpy+0x2b>
  800979:	8a 19                	mov    (%ecx),%bl
  80097b:	84 db                	test   %bl,%bl
  80097d:	75 ef                	jne    80096e <strlcpy+0x16>
  80097f:	89 c2                	mov    %eax,%edx
  800981:	eb 02                	jmp    800985 <strlcpy+0x2d>
  800983:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800985:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800988:	29 f0                	sub    %esi,%eax
}
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800997:	eb 02                	jmp    80099b <strcmp+0xd>
		p++, q++;
  800999:	41                   	inc    %ecx
  80099a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80099b:	8a 01                	mov    (%ecx),%al
  80099d:	84 c0                	test   %al,%al
  80099f:	74 04                	je     8009a5 <strcmp+0x17>
  8009a1:	3a 02                	cmp    (%edx),%al
  8009a3:	74 f4                	je     800999 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 c0             	movzbl %al,%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009bc:	eb 03                	jmp    8009c1 <strncmp+0x12>
		n--, p++, q++;
  8009be:	4a                   	dec    %edx
  8009bf:	40                   	inc    %eax
  8009c0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c1:	85 d2                	test   %edx,%edx
  8009c3:	74 14                	je     8009d9 <strncmp+0x2a>
  8009c5:	8a 18                	mov    (%eax),%bl
  8009c7:	84 db                	test   %bl,%bl
  8009c9:	74 04                	je     8009cf <strncmp+0x20>
  8009cb:	3a 19                	cmp    (%ecx),%bl
  8009cd:	74 ef                	je     8009be <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cf:	0f b6 00             	movzbl (%eax),%eax
  8009d2:	0f b6 11             	movzbl (%ecx),%edx
  8009d5:	29 d0                	sub    %edx,%eax
  8009d7:	eb 05                	jmp    8009de <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009de:	5b                   	pop    %ebx
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ea:	eb 05                	jmp    8009f1 <strchr+0x10>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	74 0c                	je     8009fc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f0:	40                   	inc    %eax
  8009f1:	8a 10                	mov    (%eax),%dl
  8009f3:	84 d2                	test   %dl,%dl
  8009f5:	75 f5                	jne    8009ec <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a07:	eb 05                	jmp    800a0e <strfind+0x10>
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	74 07                	je     800a14 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a0d:	40                   	inc    %eax
  800a0e:	8a 10                	mov    (%eax),%dl
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 f5                	jne    800a09 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a25:	85 c9                	test   %ecx,%ecx
  800a27:	74 30                	je     800a59 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2f:	75 25                	jne    800a56 <memset+0x40>
  800a31:	f6 c1 03             	test   $0x3,%cl
  800a34:	75 20                	jne    800a56 <memset+0x40>
		c &= 0xFF;
  800a36:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a39:	89 d3                	mov    %edx,%ebx
  800a3b:	c1 e3 08             	shl    $0x8,%ebx
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	c1 e6 18             	shl    $0x18,%esi
  800a43:	89 d0                	mov    %edx,%eax
  800a45:	c1 e0 10             	shl    $0x10,%eax
  800a48:	09 f0                	or     %esi,%eax
  800a4a:	09 d0                	or     %edx,%eax
  800a4c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a51:	fc                   	cld    
  800a52:	f3 ab                	rep stos %eax,%es:(%edi)
  800a54:	eb 03                	jmp    800a59 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a56:	fc                   	cld    
  800a57:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a59:	89 f8                	mov    %edi,%eax
  800a5b:	5b                   	pop    %ebx
  800a5c:	5e                   	pop    %esi
  800a5d:	5f                   	pop    %edi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6e:	39 c6                	cmp    %eax,%esi
  800a70:	73 34                	jae    800aa6 <memmove+0x46>
  800a72:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	73 2d                	jae    800aa6 <memmove+0x46>
		s += n;
		d += n;
  800a79:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	f6 c2 03             	test   $0x3,%dl
  800a7f:	75 1b                	jne    800a9c <memmove+0x3c>
  800a81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a87:	75 13                	jne    800a9c <memmove+0x3c>
  800a89:	f6 c1 03             	test   $0x3,%cl
  800a8c:	75 0e                	jne    800a9c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a8e:	83 ef 04             	sub    $0x4,%edi
  800a91:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a94:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a97:	fd                   	std    
  800a98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9a:	eb 07                	jmp    800aa3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9c:	4f                   	dec    %edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
  800aa4:	eb 20                	jmp    800ac6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aac:	75 13                	jne    800ac1 <memmove+0x61>
  800aae:	a8 03                	test   $0x3,%al
  800ab0:	75 0f                	jne    800ac1 <memmove+0x61>
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 0a                	jne    800ac1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800aba:	89 c7                	mov    %eax,%edi
  800abc:	fc                   	cld    
  800abd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abf:	eb 05                	jmp    800ac6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac1:	89 c7                	mov    %eax,%edi
  800ac3:	fc                   	cld    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	89 04 24             	mov    %eax,(%esp)
  800ae4:	e8 77 ff ff ff       	call   800a60 <memmove>
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	eb 16                	jmp    800b17 <memcmp+0x2c>
		if (*s1 != *s2)
  800b01:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b04:	42                   	inc    %edx
  800b05:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b09:	38 c8                	cmp    %cl,%al
  800b0b:	74 0a                	je     800b17 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b0d:	0f b6 c0             	movzbl %al,%eax
  800b10:	0f b6 c9             	movzbl %cl,%ecx
  800b13:	29 c8                	sub    %ecx,%eax
  800b15:	eb 09                	jmp    800b20 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b17:	39 da                	cmp    %ebx,%edx
  800b19:	75 e6                	jne    800b01 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b33:	eb 05                	jmp    800b3a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b35:	38 08                	cmp    %cl,(%eax)
  800b37:	74 05                	je     800b3e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b39:	40                   	inc    %eax
  800b3a:	39 d0                	cmp    %edx,%eax
  800b3c:	72 f7                	jb     800b35 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4c:	eb 01                	jmp    800b4f <strtol+0xf>
		s++;
  800b4e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4f:	8a 02                	mov    (%edx),%al
  800b51:	3c 20                	cmp    $0x20,%al
  800b53:	74 f9                	je     800b4e <strtol+0xe>
  800b55:	3c 09                	cmp    $0x9,%al
  800b57:	74 f5                	je     800b4e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b59:	3c 2b                	cmp    $0x2b,%al
  800b5b:	75 08                	jne    800b65 <strtol+0x25>
		s++;
  800b5d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b63:	eb 13                	jmp    800b78 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b65:	3c 2d                	cmp    $0x2d,%al
  800b67:	75 0a                	jne    800b73 <strtol+0x33>
		s++, neg = 1;
  800b69:	8d 52 01             	lea    0x1(%edx),%edx
  800b6c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b71:	eb 05                	jmp    800b78 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b73:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	85 db                	test   %ebx,%ebx
  800b7a:	74 05                	je     800b81 <strtol+0x41>
  800b7c:	83 fb 10             	cmp    $0x10,%ebx
  800b7f:	75 28                	jne    800ba9 <strtol+0x69>
  800b81:	8a 02                	mov    (%edx),%al
  800b83:	3c 30                	cmp    $0x30,%al
  800b85:	75 10                	jne    800b97 <strtol+0x57>
  800b87:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b8b:	75 0a                	jne    800b97 <strtol+0x57>
		s += 2, base = 16;
  800b8d:	83 c2 02             	add    $0x2,%edx
  800b90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b95:	eb 12                	jmp    800ba9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b97:	85 db                	test   %ebx,%ebx
  800b99:	75 0e                	jne    800ba9 <strtol+0x69>
  800b9b:	3c 30                	cmp    $0x30,%al
  800b9d:	75 05                	jne    800ba4 <strtol+0x64>
		s++, base = 8;
  800b9f:	42                   	inc    %edx
  800ba0:	b3 08                	mov    $0x8,%bl
  800ba2:	eb 05                	jmp    800ba9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ba4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bae:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb0:	8a 0a                	mov    (%edx),%cl
  800bb2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bb5:	80 fb 09             	cmp    $0x9,%bl
  800bb8:	77 08                	ja     800bc2 <strtol+0x82>
			dig = *s - '0';
  800bba:	0f be c9             	movsbl %cl,%ecx
  800bbd:	83 e9 30             	sub    $0x30,%ecx
  800bc0:	eb 1e                	jmp    800be0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800bc2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800bc5:	80 fb 19             	cmp    $0x19,%bl
  800bc8:	77 08                	ja     800bd2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bca:	0f be c9             	movsbl %cl,%ecx
  800bcd:	83 e9 57             	sub    $0x57,%ecx
  800bd0:	eb 0e                	jmp    800be0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bd2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bd5:	80 fb 19             	cmp    $0x19,%bl
  800bd8:	77 12                	ja     800bec <strtol+0xac>
			dig = *s - 'A' + 10;
  800bda:	0f be c9             	movsbl %cl,%ecx
  800bdd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800be0:	39 f1                	cmp    %esi,%ecx
  800be2:	7d 0c                	jge    800bf0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800be4:	42                   	inc    %edx
  800be5:	0f af c6             	imul   %esi,%eax
  800be8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bea:	eb c4                	jmp    800bb0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bec:	89 c1                	mov    %eax,%ecx
  800bee:	eb 02                	jmp    800bf2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf6:	74 05                	je     800bfd <strtol+0xbd>
		*endptr = (char *) s;
  800bf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	74 04                	je     800c05 <strtol+0xc5>
  800c01:	89 c8                	mov    %ecx,%eax
  800c03:	f7 d8                	neg    %eax
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    
	...

00800c0c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 c3                	mov    %eax,%ebx
  800c1f:	89 c7                	mov    %eax,%edi
  800c21:	89 c6                	mov    %eax,%esi
  800c23:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	ba 00 00 00 00       	mov    $0x0,%edx
  800c35:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3a:	89 d1                	mov    %edx,%ecx
  800c3c:	89 d3                	mov    %edx,%ebx
  800c3e:	89 d7                	mov    %edx,%edi
  800c40:	89 d6                	mov    %edx,%esi
  800c42:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c57:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 cb                	mov    %ecx,%ebx
  800c61:	89 cf                	mov    %ecx,%edi
  800c63:	89 ce                	mov    %ecx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 28                	jle    800c93 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800c8e:	e8 b1 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c93:	83 c4 2c             	add    $0x2c,%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	89 d3                	mov    %edx,%ebx
  800caf:	89 d7                	mov    %edx,%edi
  800cb1:	89 d6                	mov    %edx,%esi
  800cb3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_yield>:

void
sys_yield(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	be 00 00 00 00       	mov    $0x0,%esi
  800ce7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 f7                	mov    %esi,%edi
  800cf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 28                	jle    800d25 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d01:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d08:	00 
  800d09:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800d10:	00 
  800d11:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d18:	00 
  800d19:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800d20:	e8 1f f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d25:	83 c4 2c             	add    $0x2c,%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	b8 05 00 00 00       	mov    $0x5,%eax
  800d3b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 28                	jle    800d78 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d54:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d5b:	00 
  800d5c:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800d63:	00 
  800d64:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6b:	00 
  800d6c:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800d73:	e8 cc f4 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d78:	83 c4 2c             	add    $0x2c,%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	57                   	push   %edi
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 df                	mov    %ebx,%edi
  800d9b:	89 de                	mov    %ebx,%esi
  800d9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	7e 28                	jle    800dcb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dae:	00 
  800daf:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800db6:	00 
  800db7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbe:	00 
  800dbf:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800dc6:	e8 79 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dcb:	83 c4 2c             	add    $0x2c,%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de1:	b8 08 00 00 00       	mov    $0x8,%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	89 df                	mov    %ebx,%edi
  800dee:	89 de                	mov    %ebx,%esi
  800df0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df2:	85 c0                	test   %eax,%eax
  800df4:	7e 28                	jle    800e1e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e01:	00 
  800e02:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800e09:	00 
  800e0a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e11:	00 
  800e12:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800e19:	e8 26 f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1e:	83 c4 2c             	add    $0x2c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e34:	b8 09 00 00 00       	mov    $0x9,%eax
  800e39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3f:	89 df                	mov    %ebx,%edi
  800e41:	89 de                	mov    %ebx,%esi
  800e43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7e 28                	jle    800e71 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800e6c:	e8 d3 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e71:	83 c4 2c             	add    $0x2c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
  800e7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e87:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	89 df                	mov    %ebx,%edi
  800e94:	89 de                	mov    %ebx,%esi
  800e96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	7e 28                	jle    800ec4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb7:	00 
  800eb8:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800ebf:	e8 80 f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec4:	83 c4 2c             	add    $0x2c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	57                   	push   %edi
  800ed0:	56                   	push   %esi
  800ed1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	be 00 00 00 00       	mov    $0x0,%esi
  800ed7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800edc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5f                   	pop    %edi
  800eed:	5d                   	pop    %ebp
  800eee:	c3                   	ret    

00800eef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	89 cb                	mov    %ecx,%ebx
  800f07:	89 cf                	mov    %ecx,%edi
  800f09:	89 ce                	mov    %ecx,%esi
  800f0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	7e 28                	jle    800f39 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f15:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f1c:	00 
  800f1d:	c7 44 24 08 3f 29 80 	movl   $0x80293f,0x8(%esp)
  800f24:	00 
  800f25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2c:	00 
  800f2d:	c7 04 24 5c 29 80 00 	movl   $0x80295c,(%esp)
  800f34:	e8 0b f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f39:	83 c4 2c             	add    $0x2c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
  800f41:	00 00                	add    %al,(%eax)
	...

00800f44 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	53                   	push   %ebx
  800f48:	83 ec 24             	sub    $0x24,%esp
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f4e:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800f50:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f54:	75 20                	jne    800f76 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f56:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f5a:	c7 44 24 08 6c 29 80 	movl   $0x80296c,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  800f71:	e8 ce f2 ff ff       	call   800244 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f76:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f88:	f6 c4 08             	test   $0x8,%ah
  800f8b:	75 1c                	jne    800fa9 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f8d:	c7 44 24 08 9c 29 80 	movl   $0x80299c,0x8(%esp)
  800f94:	00 
  800f95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  800fa4:	e8 9b f2 ff ff       	call   800244 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800fa9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800fb8:	00 
  800fb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc0:	e8 14 fd ff ff       	call   800cd9 <sys_page_alloc>
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	79 20                	jns    800fe9 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  800fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fcd:	c7 44 24 08 f7 29 80 	movl   $0x8029f7,0x8(%esp)
  800fd4:	00 
  800fd5:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  800fdc:	00 
  800fdd:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  800fe4:	e8 5b f2 ff ff       	call   800244 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  800fe9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ff0:	00 
  800ff1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ffc:	e8 5f fa ff ff       	call   800a60 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801001:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801008:	00 
  801009:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80100d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801014:	00 
  801015:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80101c:	00 
  80101d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801024:	e8 04 fd ff ff       	call   800d2d <sys_page_map>
  801029:	85 c0                	test   %eax,%eax
  80102b:	79 20                	jns    80104d <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80102d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801031:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801048:	e8 f7 f1 ff ff       	call   800244 <_panic>

}
  80104d:	83 c4 24             	add    $0x24,%esp
  801050:	5b                   	pop    %ebx
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80105c:	c7 04 24 44 0f 80 00 	movl   $0x800f44,(%esp)
  801063:	e8 8c 10 00 00       	call   8020f4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801068:	ba 07 00 00 00       	mov    $0x7,%edx
  80106d:	89 d0                	mov    %edx,%eax
  80106f:	cd 30                	int    $0x30
  801071:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801074:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801077:	85 c0                	test   %eax,%eax
  801079:	79 20                	jns    80109b <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80107b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80107f:	c7 44 24 08 1d 2a 80 	movl   $0x802a1d,0x8(%esp)
  801086:	00 
  801087:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80108e:	00 
  80108f:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801096:	e8 a9 f1 ff ff       	call   800244 <_panic>
	if (child_envid == 0) { // child
  80109b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80109f:	75 25                	jne    8010c6 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8010a1:	e8 f5 fb ff ff       	call   800c9b <sys_getenvid>
  8010a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010b2:	c1 e0 07             	shl    $0x7,%eax
  8010b5:	29 d0                	sub    %edx,%eax
  8010b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010bc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010c1:	e9 58 02 00 00       	jmp    80131e <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  8010c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8010cb:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010d0:	89 f0                	mov    %esi,%eax
  8010d2:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010dc:	a8 01                	test   $0x1,%al
  8010de:	0f 84 7a 01 00 00    	je     80125e <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8010e4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010eb:	a8 01                	test   $0x1,%al
  8010ed:	0f 84 6b 01 00 00    	je     80125e <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8010f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f8:	8b 40 48             	mov    0x48(%eax),%eax
  8010fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8010fe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801105:	f6 c4 04             	test   $0x4,%ah
  801108:	74 52                	je     80115c <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80110a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	89 44 24 10          	mov    %eax,0x10(%esp)
  80111a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80111e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801121:	89 44 24 08          	mov    %eax,0x8(%esp)
  801125:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80112c:	89 04 24             	mov    %eax,(%esp)
  80112f:	e8 f9 fb ff ff       	call   800d2d <sys_page_map>
  801134:	85 c0                	test   %eax,%eax
  801136:	0f 89 22 01 00 00    	jns    80125e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80113c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801140:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  801147:	00 
  801148:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80114f:	00 
  801150:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801157:	e8 e8 f0 ff ff       	call   800244 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80115c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801163:	f6 c4 08             	test   $0x8,%ah
  801166:	75 0f                	jne    801177 <fork+0x124>
  801168:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116f:	a8 02                	test   $0x2,%al
  801171:	0f 84 99 00 00 00    	je     801210 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801177:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80117e:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801181:	83 f8 01             	cmp    $0x1,%eax
  801184:	19 db                	sbb    %ebx,%ebx
  801186:	83 e3 fc             	and    $0xfffffffc,%ebx
  801189:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80118f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801193:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801197:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80119a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80119e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a5:	89 04 24             	mov    %eax,(%esp)
  8011a8:	e8 80 fb ff ff       	call   800d2d <sys_page_map>
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	79 20                	jns    8011d1 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8011b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b5:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  8011cc:	e8 73 f0 ff ff       	call   800244 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011d1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011e4:	89 04 24             	mov    %eax,(%esp)
  8011e7:	e8 41 fb ff ff       	call   800d2d <sys_page_map>
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	79 6e                	jns    80125e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f4:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801203:	00 
  801204:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  80120b:	e8 34 f0 ff ff       	call   800244 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801210:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801217:	25 07 0e 00 00       	and    $0xe07,%eax
  80121c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801220:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801224:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801227:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80122f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801232:	89 04 24             	mov    %eax,(%esp)
  801235:	e8 f3 fa ff ff       	call   800d2d <sys_page_map>
  80123a:	85 c0                	test   %eax,%eax
  80123c:	79 20                	jns    80125e <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80123e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801242:	c7 44 24 08 0b 2a 80 	movl   $0x802a0b,0x8(%esp)
  801249:	00 
  80124a:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801251:	00 
  801252:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801259:	e8 e6 ef ff ff       	call   800244 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80125e:	46                   	inc    %esi
  80125f:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801265:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80126b:	0f 85 5f fe ff ff    	jne    8010d0 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801271:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801278:	00 
  801279:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801280:	ee 
  801281:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801284:	89 04 24             	mov    %eax,(%esp)
  801287:	e8 4d fa ff ff       	call   800cd9 <sys_page_alloc>
  80128c:	85 c0                	test   %eax,%eax
  80128e:	79 20                	jns    8012b0 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  801290:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801294:	c7 44 24 08 f7 29 80 	movl   $0x8029f7,0x8(%esp)
  80129b:	00 
  80129c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012a3:	00 
  8012a4:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  8012ab:	e8 94 ef ff ff       	call   800244 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8012b0:	c7 44 24 04 68 21 80 	movl   $0x802168,0x4(%esp)
  8012b7:	00 
  8012b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012bb:	89 04 24             	mov    %eax,(%esp)
  8012be:	e8 b6 fb ff ff       	call   800e79 <sys_env_set_pgfault_upcall>
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	79 20                	jns    8012e7 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8012c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012cb:	c7 44 24 08 cc 29 80 	movl   $0x8029cc,0x8(%esp)
  8012d2:	00 
  8012d3:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8012da:	00 
  8012db:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  8012e2:	e8 5d ef ff ff       	call   800244 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8012e7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012ee:	00 
  8012ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f2:	89 04 24             	mov    %eax,(%esp)
  8012f5:	e8 d9 fa ff ff       	call   800dd3 <sys_env_set_status>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	79 20                	jns    80131e <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  8012fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801302:	c7 44 24 08 2e 2a 80 	movl   $0x802a2e,0x8(%esp)
  801309:	00 
  80130a:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801311:	00 
  801312:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801319:	e8 26 ef ff ff       	call   800244 <_panic>

	return child_envid;
}
  80131e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801321:	83 c4 3c             	add    $0x3c,%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <sfork>:

// Challenge!
int
sfork(void)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80132f:	c7 44 24 08 46 2a 80 	movl   $0x802a46,0x8(%esp)
  801336:	00 
  801337:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80133e:	00 
  80133f:	c7 04 24 ec 29 80 00 	movl   $0x8029ec,(%esp)
  801346:	e8 f9 ee ff ff       	call   800244 <_panic>
	...

0080134c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134f:	8b 45 08             	mov    0x8(%ebp),%eax
  801352:	05 00 00 00 30       	add    $0x30000000,%eax
  801357:	c1 e8 0c             	shr    $0xc,%eax
}
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    

0080135c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 df ff ff ff       	call   80134c <fd2num>
  80136d:	05 20 00 0d 00       	add    $0xd0020,%eax
  801372:	c1 e0 0c             	shl    $0xc,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80137e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801383:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801385:	89 c2                	mov    %eax,%edx
  801387:	c1 ea 16             	shr    $0x16,%edx
  80138a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801391:	f6 c2 01             	test   $0x1,%dl
  801394:	74 11                	je     8013a7 <fd_alloc+0x30>
  801396:	89 c2                	mov    %eax,%edx
  801398:	c1 ea 0c             	shr    $0xc,%edx
  80139b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a2:	f6 c2 01             	test   $0x1,%dl
  8013a5:	75 09                	jne    8013b0 <fd_alloc+0x39>
			*fd_store = fd;
  8013a7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ae:	eb 17                	jmp    8013c7 <fd_alloc+0x50>
  8013b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ba:	75 c7                	jne    801383 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8013c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013c7:	5b                   	pop    %ebx
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d0:	83 f8 1f             	cmp    $0x1f,%eax
  8013d3:	77 36                	ja     80140b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d5:	05 00 00 0d 00       	add    $0xd0000,%eax
  8013da:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	c1 ea 16             	shr    $0x16,%edx
  8013e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013e9:	f6 c2 01             	test   $0x1,%dl
  8013ec:	74 24                	je     801412 <fd_lookup+0x48>
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	c1 ea 0c             	shr    $0xc,%edx
  8013f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fa:	f6 c2 01             	test   $0x1,%dl
  8013fd:	74 1a                	je     801419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801402:	89 02                	mov    %eax,(%edx)
	return 0;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	eb 13                	jmp    80141e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801410:	eb 0c                	jmp    80141e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801417:	eb 05                	jmp    80141e <fd_lookup+0x54>
  801419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    

00801420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	53                   	push   %ebx
  801424:	83 ec 14             	sub    $0x14,%esp
  801427:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80142d:	ba 00 00 00 00       	mov    $0x0,%edx
  801432:	eb 0e                	jmp    801442 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801434:	39 08                	cmp    %ecx,(%eax)
  801436:	75 09                	jne    801441 <dev_lookup+0x21>
			*dev = devtab[i];
  801438:	89 03                	mov    %eax,(%ebx)
			return 0;
  80143a:	b8 00 00 00 00       	mov    $0x0,%eax
  80143f:	eb 33                	jmp    801474 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801441:	42                   	inc    %edx
  801442:	8b 04 95 d8 2a 80 00 	mov    0x802ad8(,%edx,4),%eax
  801449:	85 c0                	test   %eax,%eax
  80144b:	75 e7                	jne    801434 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80144d:	a1 04 40 80 00       	mov    0x804004,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145d:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  801464:	e8 d3 ee ff ff       	call   80033c <cprintf>
	*dev = 0;
  801469:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80146f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801474:	83 c4 14             	add    $0x14,%esp
  801477:	5b                   	pop    %ebx
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 30             	sub    $0x30,%esp
  801482:	8b 75 08             	mov    0x8(%ebp),%esi
  801485:	8a 45 0c             	mov    0xc(%ebp),%al
  801488:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148b:	89 34 24             	mov    %esi,(%esp)
  80148e:	e8 b9 fe ff ff       	call   80134c <fd2num>
  801493:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801496:	89 54 24 04          	mov    %edx,0x4(%esp)
  80149a:	89 04 24             	mov    %eax,(%esp)
  80149d:	e8 28 ff ff ff       	call   8013ca <fd_lookup>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 05                	js     8014ad <fd_close+0x33>
	    || fd != fd2)
  8014a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014ab:	74 0d                	je     8014ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8014ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8014b1:	75 46                	jne    8014f9 <fd_close+0x7f>
  8014b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b8:	eb 3f                	jmp    8014f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c1:	8b 06                	mov    (%esi),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 55 ff ff ff       	call   801420 <dev_lookup>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 18                	js     8014e9 <fd_close+0x6f>
		if (dev->dev_close)
  8014d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d4:	8b 40 10             	mov    0x10(%eax),%eax
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	74 09                	je     8014e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014db:	89 34 24             	mov    %esi,(%esp)
  8014de:	ff d0                	call   *%eax
  8014e0:	89 c3                	mov    %eax,%ebx
  8014e2:	eb 05                	jmp    8014e9 <fd_close+0x6f>
		else
			r = 0;
  8014e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f4:	e8 87 f8 ff ff       	call   800d80 <sys_page_unmap>
	return r;
}
  8014f9:	89 d8                	mov    %ebx,%eax
  8014fb:	83 c4 30             	add    $0x30,%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5e                   	pop    %esi
  801500:	5d                   	pop    %ebp
  801501:	c3                   	ret    

00801502 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	89 04 24             	mov    %eax,(%esp)
  801515:	e8 b0 fe ff ff       	call   8013ca <fd_lookup>
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 13                	js     801531 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80151e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801525:	00 
  801526:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 49 ff ff ff       	call   80147a <fd_close>
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <close_all>:

void
close_all(void)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80153a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80153f:	89 1c 24             	mov    %ebx,(%esp)
  801542:	e8 bb ff ff ff       	call   801502 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801547:	43                   	inc    %ebx
  801548:	83 fb 20             	cmp    $0x20,%ebx
  80154b:	75 f2                	jne    80153f <close_all+0xc>
		close(i);
}
  80154d:	83 c4 14             	add    $0x14,%esp
  801550:	5b                   	pop    %ebx
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	57                   	push   %edi
  801557:	56                   	push   %esi
  801558:	53                   	push   %ebx
  801559:	83 ec 4c             	sub    $0x4c,%esp
  80155c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80155f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801562:	89 44 24 04          	mov    %eax,0x4(%esp)
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
  801569:	89 04 24             	mov    %eax,(%esp)
  80156c:	e8 59 fe ff ff       	call   8013ca <fd_lookup>
  801571:	89 c3                	mov    %eax,%ebx
  801573:	85 c0                	test   %eax,%eax
  801575:	0f 88 e1 00 00 00    	js     80165c <dup+0x109>
		return r;
	close(newfdnum);
  80157b:	89 3c 24             	mov    %edi,(%esp)
  80157e:	e8 7f ff ff ff       	call   801502 <close>

	newfd = INDEX2FD(newfdnum);
  801583:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801589:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80158c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 c5 fd ff ff       	call   80135c <fd2data>
  801597:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801599:	89 34 24             	mov    %esi,(%esp)
  80159c:	e8 bb fd ff ff       	call   80135c <fd2data>
  8015a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015a4:	89 d8                	mov    %ebx,%eax
  8015a6:	c1 e8 16             	shr    $0x16,%eax
  8015a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015b0:	a8 01                	test   $0x1,%al
  8015b2:	74 46                	je     8015fa <dup+0xa7>
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	c1 e8 0c             	shr    $0xc,%eax
  8015b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015c0:	f6 c2 01             	test   $0x1,%dl
  8015c3:	74 35                	je     8015fa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015e3:	00 
  8015e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ef:	e8 39 f7 ff ff       	call   800d2d <sys_page_map>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	78 3b                	js     801635 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	c1 ea 0c             	shr    $0xc,%edx
  801602:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801609:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80160f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801613:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801617:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80161e:	00 
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80162a:	e8 fe f6 ff ff       	call   800d2d <sys_page_map>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	85 c0                	test   %eax,%eax
  801633:	79 25                	jns    80165a <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801635:	89 74 24 04          	mov    %esi,0x4(%esp)
  801639:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801640:	e8 3b f7 ff ff       	call   800d80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801645:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801653:	e8 28 f7 ff ff       	call   800d80 <sys_page_unmap>
	return r;
  801658:	eb 02                	jmp    80165c <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80165a:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80165c:	89 d8                	mov    %ebx,%eax
  80165e:	83 c4 4c             	add    $0x4c,%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5f                   	pop    %edi
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 24             	sub    $0x24,%esp
  80166d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801670:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801673:	89 44 24 04          	mov    %eax,0x4(%esp)
  801677:	89 1c 24             	mov    %ebx,(%esp)
  80167a:	e8 4b fd ff ff       	call   8013ca <fd_lookup>
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 6d                	js     8016f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168d:	8b 00                	mov    (%eax),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 89 fd ff ff       	call   801420 <dev_lookup>
  801697:	85 c0                	test   %eax,%eax
  801699:	78 55                	js     8016f0 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80169b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169e:	8b 50 08             	mov    0x8(%eax),%edx
  8016a1:	83 e2 03             	and    $0x3,%edx
  8016a4:	83 fa 01             	cmp    $0x1,%edx
  8016a7:	75 23                	jne    8016cc <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8016ae:	8b 40 48             	mov    0x48(%eax),%eax
  8016b1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	c7 04 24 9d 2a 80 00 	movl   $0x802a9d,(%esp)
  8016c0:	e8 77 ec ff ff       	call   80033c <cprintf>
		return -E_INVAL;
  8016c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ca:	eb 24                	jmp    8016f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8016cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cf:	8b 52 08             	mov    0x8(%edx),%edx
  8016d2:	85 d2                	test   %edx,%edx
  8016d4:	74 15                	je     8016eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016e4:	89 04 24             	mov    %eax,(%esp)
  8016e7:	ff d2                	call   *%edx
  8016e9:	eb 05                	jmp    8016f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8016f0:	83 c4 24             	add    $0x24,%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	57                   	push   %edi
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 1c             	sub    $0x1c,%esp
  8016ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801702:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170a:	eb 23                	jmp    80172f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80170c:	89 f0                	mov    %esi,%eax
  80170e:	29 d8                	sub    %ebx,%eax
  801710:	89 44 24 08          	mov    %eax,0x8(%esp)
  801714:	8b 45 0c             	mov    0xc(%ebp),%eax
  801717:	01 d8                	add    %ebx,%eax
  801719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171d:	89 3c 24             	mov    %edi,(%esp)
  801720:	e8 41 ff ff ff       	call   801666 <read>
		if (m < 0)
  801725:	85 c0                	test   %eax,%eax
  801727:	78 10                	js     801739 <readn+0x43>
			return m;
		if (m == 0)
  801729:	85 c0                	test   %eax,%eax
  80172b:	74 0a                	je     801737 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172d:	01 c3                	add    %eax,%ebx
  80172f:	39 f3                	cmp    %esi,%ebx
  801731:	72 d9                	jb     80170c <readn+0x16>
  801733:	89 d8                	mov    %ebx,%eax
  801735:	eb 02                	jmp    801739 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801737:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801739:	83 c4 1c             	add    $0x1c,%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5f                   	pop    %edi
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	53                   	push   %ebx
  801745:	83 ec 24             	sub    $0x24,%esp
  801748:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801752:	89 1c 24             	mov    %ebx,(%esp)
  801755:	e8 70 fc ff ff       	call   8013ca <fd_lookup>
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 68                	js     8017c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	89 44 24 04          	mov    %eax,0x4(%esp)
  801765:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801768:	8b 00                	mov    (%eax),%eax
  80176a:	89 04 24             	mov    %eax,(%esp)
  80176d:	e8 ae fc ff ff       	call   801420 <dev_lookup>
  801772:	85 c0                	test   %eax,%eax
  801774:	78 50                	js     8017c6 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177d:	75 23                	jne    8017a2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80177f:	a1 04 40 80 00       	mov    0x804004,%eax
  801784:	8b 40 48             	mov    0x48(%eax),%eax
  801787:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	c7 04 24 b9 2a 80 00 	movl   $0x802ab9,(%esp)
  801796:	e8 a1 eb ff ff       	call   80033c <cprintf>
		return -E_INVAL;
  80179b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a0:	eb 24                	jmp    8017c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a8:	85 d2                	test   %edx,%edx
  8017aa:	74 15                	je     8017c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017ba:	89 04 24             	mov    %eax,(%esp)
  8017bd:	ff d2                	call   *%edx
  8017bf:	eb 05                	jmp    8017c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8017c6:	83 c4 24             	add    $0x24,%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dc:	89 04 24             	mov    %eax,(%esp)
  8017df:	e8 e6 fb ff ff       	call   8013ca <fd_lookup>
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 0e                	js     8017f6 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 24             	sub    $0x24,%esp
  8017ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801802:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	89 1c 24             	mov    %ebx,(%esp)
  80180c:	e8 b9 fb ff ff       	call   8013ca <fd_lookup>
  801811:	85 c0                	test   %eax,%eax
  801813:	78 61                	js     801876 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181f:	8b 00                	mov    (%eax),%eax
  801821:	89 04 24             	mov    %eax,(%esp)
  801824:	e8 f7 fb ff ff       	call   801420 <dev_lookup>
  801829:	85 c0                	test   %eax,%eax
  80182b:	78 49                	js     801876 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801830:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801834:	75 23                	jne    801859 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801836:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80183b:	8b 40 48             	mov    0x48(%eax),%eax
  80183e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	c7 04 24 7c 2a 80 00 	movl   $0x802a7c,(%esp)
  80184d:	e8 ea ea ff ff       	call   80033c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801857:	eb 1d                	jmp    801876 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801859:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185c:	8b 52 18             	mov    0x18(%edx),%edx
  80185f:	85 d2                	test   %edx,%edx
  801861:	74 0e                	je     801871 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801866:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80186a:	89 04 24             	mov    %eax,(%esp)
  80186d:	ff d2                	call   *%edx
  80186f:	eb 05                	jmp    801876 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801876:	83 c4 24             	add    $0x24,%esp
  801879:	5b                   	pop    %ebx
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	53                   	push   %ebx
  801880:	83 ec 24             	sub    $0x24,%esp
  801883:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801886:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	e8 32 fb ff ff       	call   8013ca <fd_lookup>
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 52                	js     8018ee <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a6:	8b 00                	mov    (%eax),%eax
  8018a8:	89 04 24             	mov    %eax,(%esp)
  8018ab:	e8 70 fb ff ff       	call   801420 <dev_lookup>
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 3a                	js     8018ee <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8018b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018bb:	74 2c                	je     8018e9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018c7:	00 00 00 
	stat->st_isdir = 0;
  8018ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d1:	00 00 00 
	stat->st_dev = dev;
  8018d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e1:	89 14 24             	mov    %edx,(%esp)
  8018e4:	ff 50 14             	call   *0x14(%eax)
  8018e7:	eb 05                	jmp    8018ee <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018ee:	83 c4 24             	add    $0x24,%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801903:	00 
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	89 04 24             	mov    %eax,(%esp)
  80190a:	e8 2d 02 00 00       	call   801b3c <open>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	85 c0                	test   %eax,%eax
  801913:	78 1b                	js     801930 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801915:	8b 45 0c             	mov    0xc(%ebp),%eax
  801918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191c:	89 1c 24             	mov    %ebx,(%esp)
  80191f:	e8 58 ff ff ff       	call   80187c <fstat>
  801924:	89 c6                	mov    %eax,%esi
	close(fd);
  801926:	89 1c 24             	mov    %ebx,(%esp)
  801929:	e8 d4 fb ff ff       	call   801502 <close>
	return r;
  80192e:	89 f3                	mov    %esi,%ebx
}
  801930:	89 d8                	mov    %ebx,%eax
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    
  801939:	00 00                	add    %al,(%eax)
	...

0080193c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	83 ec 10             	sub    $0x10,%esp
  801944:	89 c3                	mov    %eax,%ebx
  801946:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801948:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80194f:	75 11                	jne    801962 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801951:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801958:	e8 06 09 00 00       	call   802263 <ipc_find_env>
  80195d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801962:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801969:	00 
  80196a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801971:	00 
  801972:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801976:	a1 00 40 80 00       	mov    0x804000,%eax
  80197b:	89 04 24             	mov    %eax,(%esp)
  80197e:	e8 72 08 00 00       	call   8021f5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801983:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80198a:	00 
  80198b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801996:	e8 f1 07 00 00       	call   80218c <ipc_recv>
}
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c0:	b8 02 00 00 00       	mov    $0x2,%eax
  8019c5:	e8 72 ff ff ff       	call   80193c <fsipc>
}
  8019ca:	c9                   	leave  
  8019cb:	c3                   	ret    

008019cc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8019e7:	e8 50 ff ff ff       	call   80193c <fsipc>
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	83 ec 14             	sub    $0x14,%esp
  8019f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a03:	ba 00 00 00 00       	mov    $0x0,%edx
  801a08:	b8 05 00 00 00       	mov    $0x5,%eax
  801a0d:	e8 2a ff ff ff       	call   80193c <fsipc>
  801a12:	85 c0                	test   %eax,%eax
  801a14:	78 2b                	js     801a41 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a16:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a1d:	00 
  801a1e:	89 1c 24             	mov    %ebx,(%esp)
  801a21:	e8 c1 ee ff ff       	call   8008e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a26:	a1 80 50 80 00       	mov    0x805080,%eax
  801a2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a31:	a1 84 50 80 00       	mov    0x805084,%eax
  801a36:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a41:	83 c4 14             	add    $0x14,%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5d                   	pop    %ebp
  801a46:	c3                   	ret    

00801a47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	83 ec 18             	sub    $0x18,%esp
  801a4d:	8b 55 10             	mov    0x10(%ebp),%edx
  801a50:	89 d0                	mov    %edx,%eax
  801a52:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801a58:	76 05                	jbe    801a5f <devfile_write+0x18>
  801a5a:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  801a62:	8b 52 0c             	mov    0xc(%edx),%edx
  801a65:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a6b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7b:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801a82:	e8 d9 ef ff ff       	call   800a60 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801a87:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8c:	b8 04 00 00 00       	mov    $0x4,%eax
  801a91:	e8 a6 fe ff ff       	call   80193c <fsipc>
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 10             	sub    $0x10,%esp
  801aa0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801aae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ab4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab9:	b8 03 00 00 00       	mov    $0x3,%eax
  801abe:	e8 79 fe ff ff       	call   80193c <fsipc>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 6a                	js     801b33 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801ac9:	39 c6                	cmp    %eax,%esi
  801acb:	73 24                	jae    801af1 <devfile_read+0x59>
  801acd:	c7 44 24 0c e8 2a 80 	movl   $0x802ae8,0xc(%esp)
  801ad4:	00 
  801ad5:	c7 44 24 08 ef 2a 80 	movl   $0x802aef,0x8(%esp)
  801adc:	00 
  801add:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ae4:	00 
  801ae5:	c7 04 24 04 2b 80 00 	movl   $0x802b04,(%esp)
  801aec:	e8 53 e7 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801af1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af6:	7e 24                	jle    801b1c <devfile_read+0x84>
  801af8:	c7 44 24 0c 0f 2b 80 	movl   $0x802b0f,0xc(%esp)
  801aff:	00 
  801b00:	c7 44 24 08 ef 2a 80 	movl   $0x802aef,0x8(%esp)
  801b07:	00 
  801b08:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b0f:	00 
  801b10:	c7 04 24 04 2b 80 00 	movl   $0x802b04,(%esp)
  801b17:	e8 28 e7 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b20:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b27:	00 
  801b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 2d ef ff ff       	call   800a60 <memmove>
	return r;
}
  801b33:	89 d8                	mov    %ebx,%eax
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	83 ec 20             	sub    $0x20,%esp
  801b44:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b47:	89 34 24             	mov    %esi,(%esp)
  801b4a:	e8 65 ed ff ff       	call   8008b4 <strlen>
  801b4f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b54:	7f 60                	jg     801bb6 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b59:	89 04 24             	mov    %eax,(%esp)
  801b5c:	e8 16 f8 ff ff       	call   801377 <fd_alloc>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 54                	js     801bbb <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b67:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6b:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b72:	e8 70 ed ff ff       	call   8008e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b82:	b8 01 00 00 00       	mov    $0x1,%eax
  801b87:	e8 b0 fd ff ff       	call   80193c <fsipc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	79 15                	jns    801ba7 <open+0x6b>
		fd_close(fd, 0);
  801b92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b99:	00 
  801b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9d:	89 04 24             	mov    %eax,(%esp)
  801ba0:	e8 d5 f8 ff ff       	call   80147a <fd_close>
		return r;
  801ba5:	eb 14                	jmp    801bbb <open+0x7f>
	}

	return fd2num(fd);
  801ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baa:	89 04 24             	mov    %eax,(%esp)
  801bad:	e8 9a f7 ff ff       	call   80134c <fd2num>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	eb 05                	jmp    801bbb <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bb6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bbb:	89 d8                	mov    %ebx,%eax
  801bbd:	83 c4 20             	add    $0x20,%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bca:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcf:	b8 08 00 00 00       	mov    $0x8,%eax
  801bd4:	e8 63 fd ff ff       	call   80193c <fsipc>
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    
	...

00801bdc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	83 ec 10             	sub    $0x10,%esp
  801be4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801be7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bea:	89 04 24             	mov    %eax,(%esp)
  801bed:	e8 6a f7 ff ff       	call   80135c <fd2data>
  801bf2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801bf4:	c7 44 24 04 1b 2b 80 	movl   $0x802b1b,0x4(%esp)
  801bfb:	00 
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	e8 e3 ec ff ff       	call   8008e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c04:	8b 43 04             	mov    0x4(%ebx),%eax
  801c07:	2b 03                	sub    (%ebx),%eax
  801c09:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c0f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c16:	00 00 00 
	stat->st_dev = &devpipe;
  801c19:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c20:	30 80 00 
	return 0;
}
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	53                   	push   %ebx
  801c33:	83 ec 14             	sub    $0x14,%esp
  801c36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c44:	e8 37 f1 ff ff       	call   800d80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c49:	89 1c 24             	mov    %ebx,(%esp)
  801c4c:	e8 0b f7 ff ff       	call   80135c <fd2data>
  801c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5c:	e8 1f f1 ff ff       	call   800d80 <sys_page_unmap>
}
  801c61:	83 c4 14             	add    $0x14,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	57                   	push   %edi
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 2c             	sub    $0x2c,%esp
  801c70:	89 c7                	mov    %eax,%edi
  801c72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c75:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c7d:	89 3c 24             	mov    %edi,(%esp)
  801c80:	e8 23 06 00 00       	call   8022a8 <pageref>
  801c85:	89 c6                	mov    %eax,%esi
  801c87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8a:	89 04 24             	mov    %eax,(%esp)
  801c8d:	e8 16 06 00 00       	call   8022a8 <pageref>
  801c92:	39 c6                	cmp    %eax,%esi
  801c94:	0f 94 c0             	sete   %al
  801c97:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801c9a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ca0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ca3:	39 cb                	cmp    %ecx,%ebx
  801ca5:	75 08                	jne    801caf <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801ca7:	83 c4 2c             	add    $0x2c,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5f                   	pop    %edi
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801caf:	83 f8 01             	cmp    $0x1,%eax
  801cb2:	75 c1                	jne    801c75 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cb4:	8b 42 58             	mov    0x58(%edx),%eax
  801cb7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801cbe:	00 
  801cbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc7:	c7 04 24 22 2b 80 00 	movl   $0x802b22,(%esp)
  801cce:	e8 69 e6 ff ff       	call   80033c <cprintf>
  801cd3:	eb a0                	jmp    801c75 <_pipeisclosed+0xe>

00801cd5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	57                   	push   %edi
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	83 ec 1c             	sub    $0x1c,%esp
  801cde:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ce1:	89 34 24             	mov    %esi,(%esp)
  801ce4:	e8 73 f6 ff ff       	call   80135c <fd2data>
  801ce9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ceb:	bf 00 00 00 00       	mov    $0x0,%edi
  801cf0:	eb 3c                	jmp    801d2e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cf2:	89 da                	mov    %ebx,%edx
  801cf4:	89 f0                	mov    %esi,%eax
  801cf6:	e8 6c ff ff ff       	call   801c67 <_pipeisclosed>
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	75 38                	jne    801d37 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cff:	e8 b6 ef ff ff       	call   800cba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d04:	8b 43 04             	mov    0x4(%ebx),%eax
  801d07:	8b 13                	mov    (%ebx),%edx
  801d09:	83 c2 20             	add    $0x20,%edx
  801d0c:	39 d0                	cmp    %edx,%eax
  801d0e:	73 e2                	jae    801cf2 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d13:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d16:	89 c2                	mov    %eax,%edx
  801d18:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d1e:	79 05                	jns    801d25 <devpipe_write+0x50>
  801d20:	4a                   	dec    %edx
  801d21:	83 ca e0             	or     $0xffffffe0,%edx
  801d24:	42                   	inc    %edx
  801d25:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d29:	40                   	inc    %eax
  801d2a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d2d:	47                   	inc    %edi
  801d2e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d31:	75 d1                	jne    801d04 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d33:	89 f8                	mov    %edi,%eax
  801d35:	eb 05                	jmp    801d3c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d37:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d3c:	83 c4 1c             	add    $0x1c,%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	57                   	push   %edi
  801d48:	56                   	push   %esi
  801d49:	53                   	push   %ebx
  801d4a:	83 ec 1c             	sub    $0x1c,%esp
  801d4d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d50:	89 3c 24             	mov    %edi,(%esp)
  801d53:	e8 04 f6 ff ff       	call   80135c <fd2data>
  801d58:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5a:	be 00 00 00 00       	mov    $0x0,%esi
  801d5f:	eb 3a                	jmp    801d9b <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d61:	85 f6                	test   %esi,%esi
  801d63:	74 04                	je     801d69 <devpipe_read+0x25>
				return i;
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	eb 40                	jmp    801da9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d69:	89 da                	mov    %ebx,%edx
  801d6b:	89 f8                	mov    %edi,%eax
  801d6d:	e8 f5 fe ff ff       	call   801c67 <_pipeisclosed>
  801d72:	85 c0                	test   %eax,%eax
  801d74:	75 2e                	jne    801da4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d76:	e8 3f ef ff ff       	call   800cba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d7b:	8b 03                	mov    (%ebx),%eax
  801d7d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d80:	74 df                	je     801d61 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d82:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801d87:	79 05                	jns    801d8e <devpipe_read+0x4a>
  801d89:	48                   	dec    %eax
  801d8a:	83 c8 e0             	or     $0xffffffe0,%eax
  801d8d:	40                   	inc    %eax
  801d8e:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801d92:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d95:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801d98:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d9a:	46                   	inc    %esi
  801d9b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9e:	75 db                	jne    801d7b <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801da0:	89 f0                	mov    %esi,%eax
  801da2:	eb 05                	jmp    801da9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801da4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801da9:	83 c4 1c             	add    $0x1c,%esp
  801dac:	5b                   	pop    %ebx
  801dad:	5e                   	pop    %esi
  801dae:	5f                   	pop    %edi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	57                   	push   %edi
  801db5:	56                   	push   %esi
  801db6:	53                   	push   %ebx
  801db7:	83 ec 3c             	sub    $0x3c,%esp
  801dba:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dc0:	89 04 24             	mov    %eax,(%esp)
  801dc3:	e8 af f5 ff ff       	call   801377 <fd_alloc>
  801dc8:	89 c3                	mov    %eax,%ebx
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	0f 88 45 01 00 00    	js     801f17 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dd9:	00 
  801dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de8:	e8 ec ee ff ff       	call   800cd9 <sys_page_alloc>
  801ded:	89 c3                	mov    %eax,%ebx
  801def:	85 c0                	test   %eax,%eax
  801df1:	0f 88 20 01 00 00    	js     801f17 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801df7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801dfa:	89 04 24             	mov    %eax,(%esp)
  801dfd:	e8 75 f5 ff ff       	call   801377 <fd_alloc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	85 c0                	test   %eax,%eax
  801e06:	0f 88 f8 00 00 00    	js     801f04 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e0c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e13:	00 
  801e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e22:	e8 b2 ee ff ff       	call   800cd9 <sys_page_alloc>
  801e27:	89 c3                	mov    %eax,%ebx
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	0f 88 d3 00 00 00    	js     801f04 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e34:	89 04 24             	mov    %eax,(%esp)
  801e37:	e8 20 f5 ff ff       	call   80135c <fd2data>
  801e3c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e45:	00 
  801e46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e51:	e8 83 ee ff ff       	call   800cd9 <sys_page_alloc>
  801e56:	89 c3                	mov    %eax,%ebx
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	0f 88 91 00 00 00    	js     801ef1 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e60:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e63:	89 04 24             	mov    %eax,(%esp)
  801e66:	e8 f1 f4 ff ff       	call   80135c <fd2data>
  801e6b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801e72:	00 
  801e73:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e7e:	00 
  801e7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8a:	e8 9e ee ff ff       	call   800d2d <sys_page_map>
  801e8f:	89 c3                	mov    %eax,%ebx
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 4c                	js     801ee1 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e95:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e9e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ea0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eaa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801eb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801eb8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ebf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec2:	89 04 24             	mov    %eax,(%esp)
  801ec5:	e8 82 f4 ff ff       	call   80134c <fd2num>
  801eca:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ecf:	89 04 24             	mov    %eax,(%esp)
  801ed2:	e8 75 f4 ff ff       	call   80134c <fd2num>
  801ed7:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801eda:	bb 00 00 00 00       	mov    $0x0,%ebx
  801edf:	eb 36                	jmp    801f17 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801ee1:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eec:	e8 8f ee ff ff       	call   800d80 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801ef1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eff:	e8 7c ee ff ff       	call   800d80 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f12:	e8 69 ee ff ff       	call   800d80 <sys_page_unmap>
    err:
	return r;
}
  801f17:	89 d8                	mov    %ebx,%eax
  801f19:	83 c4 3c             	add    $0x3c,%esp
  801f1c:	5b                   	pop    %ebx
  801f1d:	5e                   	pop    %esi
  801f1e:	5f                   	pop    %edi
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    

00801f21 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	89 04 24             	mov    %eax,(%esp)
  801f34:	e8 91 f4 ff ff       	call   8013ca <fd_lookup>
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 15                	js     801f52 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f40:	89 04 24             	mov    %eax,(%esp)
  801f43:	e8 14 f4 ff ff       	call   80135c <fd2data>
	return _pipeisclosed(fd, p);
  801f48:	89 c2                	mov    %eax,%edx
  801f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4d:	e8 15 fd ff ff       	call   801c67 <_pipeisclosed>
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f57:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801f64:	c7 44 24 04 3a 2b 80 	movl   $0x802b3a,0x4(%esp)
  801f6b:	00 
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	89 04 24             	mov    %eax,(%esp)
  801f72:	e8 70 e9 ff ff       	call   8008e7 <strcpy>
	return 0;
}
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    

00801f7e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f8f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f95:	eb 30                	jmp    801fc7 <devcons_write+0x49>
		m = n - tot;
  801f97:	8b 75 10             	mov    0x10(%ebp),%esi
  801f9a:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801f9c:	83 fe 7f             	cmp    $0x7f,%esi
  801f9f:	76 05                	jbe    801fa6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801fa1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fa6:	89 74 24 08          	mov    %esi,0x8(%esp)
  801faa:	03 45 0c             	add    0xc(%ebp),%eax
  801fad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb1:	89 3c 24             	mov    %edi,(%esp)
  801fb4:	e8 a7 ea ff ff       	call   800a60 <memmove>
		sys_cputs(buf, m);
  801fb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fbd:	89 3c 24             	mov    %edi,(%esp)
  801fc0:	e8 47 ec ff ff       	call   800c0c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc5:	01 f3                	add    %esi,%ebx
  801fc7:	89 d8                	mov    %ebx,%eax
  801fc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fcc:	72 c9                	jb     801f97 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fce:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801fdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe3:	75 07                	jne    801fec <devcons_read+0x13>
  801fe5:	eb 25                	jmp    80200c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fe7:	e8 ce ec ff ff       	call   800cba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fec:	e8 39 ec ff ff       	call   800c2a <sys_cgetc>
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	74 f2                	je     801fe7 <devcons_read+0xe>
  801ff5:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 1d                	js     802018 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ffb:	83 f8 04             	cmp    $0x4,%eax
  801ffe:	74 13                	je     802013 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802000:	8b 45 0c             	mov    0xc(%ebp),%eax
  802003:	88 10                	mov    %dl,(%eax)
	return 1;
  802005:	b8 01 00 00 00       	mov    $0x1,%eax
  80200a:	eb 0c                	jmp    802018 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
  802011:	eb 05                	jmp    802018 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802020:	8b 45 08             	mov    0x8(%ebp),%eax
  802023:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802026:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80202d:	00 
  80202e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802031:	89 04 24             	mov    %eax,(%esp)
  802034:	e8 d3 eb ff ff       	call   800c0c <sys_cputs>
}
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <getchar>:

int
getchar(void)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
  80203e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802041:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802048:	00 
  802049:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802050:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802057:	e8 0a f6 ff ff       	call   801666 <read>
	if (r < 0)
  80205c:	85 c0                	test   %eax,%eax
  80205e:	78 0f                	js     80206f <getchar+0x34>
		return r;
	if (r < 1)
  802060:	85 c0                	test   %eax,%eax
  802062:	7e 06                	jle    80206a <getchar+0x2f>
		return -E_EOF;
	return c;
  802064:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802068:	eb 05                	jmp    80206f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80206a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80206f:	c9                   	leave  
  802070:	c3                   	ret    

00802071 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802077:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80207a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	89 04 24             	mov    %eax,(%esp)
  802084:	e8 41 f3 ff ff       	call   8013ca <fd_lookup>
  802089:	85 c0                	test   %eax,%eax
  80208b:	78 11                	js     80209e <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802090:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802096:	39 10                	cmp    %edx,(%eax)
  802098:	0f 94 c0             	sete   %al
  80209b:	0f b6 c0             	movzbl %al,%eax
}
  80209e:	c9                   	leave  
  80209f:	c3                   	ret    

008020a0 <opencons>:

int
opencons(void)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8020a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a9:	89 04 24             	mov    %eax,(%esp)
  8020ac:	e8 c6 f2 ff ff       	call   801377 <fd_alloc>
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	78 3c                	js     8020f1 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020bc:	00 
  8020bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cb:	e8 09 ec ff ff       	call   800cd9 <sys_page_alloc>
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 1d                	js     8020f1 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020d4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e9:	89 04 24             	mov    %eax,(%esp)
  8020ec:	e8 5b f2 ff ff       	call   80134c <fd2num>
}
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    
	...

008020f4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020fa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802101:	75 58                	jne    80215b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  802103:	a1 04 40 80 00       	mov    0x804004,%eax
  802108:	8b 40 48             	mov    0x48(%eax),%eax
  80210b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802112:	00 
  802113:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80211a:	ee 
  80211b:	89 04 24             	mov    %eax,(%esp)
  80211e:	e8 b6 eb ff ff       	call   800cd9 <sys_page_alloc>
  802123:	85 c0                	test   %eax,%eax
  802125:	74 1c                	je     802143 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  802127:	c7 44 24 08 46 2b 80 	movl   $0x802b46,0x8(%esp)
  80212e:	00 
  80212f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802136:	00 
  802137:	c7 04 24 5b 2b 80 00 	movl   $0x802b5b,(%esp)
  80213e:	e8 01 e1 ff ff       	call   800244 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802143:	a1 04 40 80 00       	mov    0x804004,%eax
  802148:	8b 40 48             	mov    0x48(%eax),%eax
  80214b:	c7 44 24 04 68 21 80 	movl   $0x802168,0x4(%esp)
  802152:	00 
  802153:	89 04 24             	mov    %eax,(%esp)
  802156:	e8 1e ed ff ff       	call   800e79 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80215b:	8b 45 08             	mov    0x8(%ebp),%eax
  80215e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802163:	c9                   	leave  
  802164:	c3                   	ret    
  802165:	00 00                	add    %al,(%eax)
	...

00802168 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802168:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802169:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80216e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802170:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  802173:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802177:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802179:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  80217d:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80217e:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802181:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  802183:	58                   	pop    %eax
	popl %eax
  802184:	58                   	pop    %eax

	// Pop all registers back
	popal
  802185:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802186:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802189:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80218a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80218b:	c3                   	ret    

0080218c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	56                   	push   %esi
  802190:	53                   	push   %ebx
  802191:	83 ec 10             	sub    $0x10,%esp
  802194:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  80219d:	85 c0                	test   %eax,%eax
  80219f:	75 05                	jne    8021a6 <ipc_recv+0x1a>
  8021a1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8021a6:	89 04 24             	mov    %eax,(%esp)
  8021a9:	e8 41 ed ff ff       	call   800eef <sys_ipc_recv>
	if (from_env_store != NULL)
  8021ae:	85 db                	test   %ebx,%ebx
  8021b0:	74 0b                	je     8021bd <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8021b2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8021b8:	8b 52 74             	mov    0x74(%edx),%edx
  8021bb:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8021bd:	85 f6                	test   %esi,%esi
  8021bf:	74 0b                	je     8021cc <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8021c1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8021c7:	8b 52 78             	mov    0x78(%edx),%edx
  8021ca:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8021cc:	85 c0                	test   %eax,%eax
  8021ce:	79 16                	jns    8021e6 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8021d0:	85 db                	test   %ebx,%ebx
  8021d2:	74 06                	je     8021da <ipc_recv+0x4e>
			*from_env_store = 0;
  8021d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8021da:	85 f6                	test   %esi,%esi
  8021dc:	74 10                	je     8021ee <ipc_recv+0x62>
			*perm_store = 0;
  8021de:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021e4:	eb 08                	jmp    8021ee <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8021e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8021eb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	57                   	push   %edi
  8021f9:	56                   	push   %esi
  8021fa:	53                   	push   %ebx
  8021fb:	83 ec 1c             	sub    $0x1c,%esp
  8021fe:	8b 75 08             	mov    0x8(%ebp),%esi
  802201:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802204:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802207:	eb 2a                	jmp    802233 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802209:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80220c:	74 20                	je     80222e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80220e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802212:	c7 44 24 08 6c 2b 80 	movl   $0x802b6c,0x8(%esp)
  802219:	00 
  80221a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802221:	00 
  802222:	c7 04 24 94 2b 80 00 	movl   $0x802b94,(%esp)
  802229:	e8 16 e0 ff ff       	call   800244 <_panic>
		sys_yield();
  80222e:	e8 87 ea ff ff       	call   800cba <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802233:	85 db                	test   %ebx,%ebx
  802235:	75 07                	jne    80223e <ipc_send+0x49>
  802237:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80223c:	eb 02                	jmp    802240 <ipc_send+0x4b>
  80223e:	89 d8                	mov    %ebx,%eax
  802240:	8b 55 14             	mov    0x14(%ebp),%edx
  802243:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80224b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80224f:	89 34 24             	mov    %esi,(%esp)
  802252:	e8 75 ec ff ff       	call   800ecc <sys_ipc_try_send>
  802257:	85 c0                	test   %eax,%eax
  802259:	78 ae                	js     802209 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80225b:	83 c4 1c             	add    $0x1c,%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5f                   	pop    %edi
  802261:	5d                   	pop    %ebp
  802262:	c3                   	ret    

00802263 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	53                   	push   %ebx
  802267:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80226a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80226f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802276:	89 c2                	mov    %eax,%edx
  802278:	c1 e2 07             	shl    $0x7,%edx
  80227b:	29 ca                	sub    %ecx,%edx
  80227d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802283:	8b 52 50             	mov    0x50(%edx),%edx
  802286:	39 da                	cmp    %ebx,%edx
  802288:	75 0f                	jne    802299 <ipc_find_env+0x36>
			return envs[i].env_id;
  80228a:	c1 e0 07             	shl    $0x7,%eax
  80228d:	29 c8                	sub    %ecx,%eax
  80228f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802294:	8b 40 40             	mov    0x40(%eax),%eax
  802297:	eb 0c                	jmp    8022a5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802299:	40                   	inc    %eax
  80229a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80229f:	75 ce                	jne    80226f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022a1:	66 b8 00 00          	mov    $0x0,%ax
}
  8022a5:	5b                   	pop    %ebx
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    

008022a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022ae:	89 c2                	mov    %eax,%edx
  8022b0:	c1 ea 16             	shr    $0x16,%edx
  8022b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022ba:	f6 c2 01             	test   $0x1,%dl
  8022bd:	74 1e                	je     8022dd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022bf:	c1 e8 0c             	shr    $0xc,%eax
  8022c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022c9:	a8 01                	test   $0x1,%al
  8022cb:	74 17                	je     8022e4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022cd:	c1 e8 0c             	shr    $0xc,%eax
  8022d0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022d7:	ef 
  8022d8:	0f b7 c0             	movzwl %ax,%eax
  8022db:	eb 0c                	jmp    8022e9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e2:	eb 05                	jmp    8022e9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    
	...

008022ec <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022ec:	55                   	push   %ebp
  8022ed:	57                   	push   %edi
  8022ee:	56                   	push   %esi
  8022ef:	83 ec 10             	sub    $0x10,%esp
  8022f2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022f6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802302:	89 cd                	mov    %ecx,%ebp
  802304:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802308:	85 c0                	test   %eax,%eax
  80230a:	75 2c                	jne    802338 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80230c:	39 f9                	cmp    %edi,%ecx
  80230e:	77 68                	ja     802378 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802310:	85 c9                	test   %ecx,%ecx
  802312:	75 0b                	jne    80231f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802314:	b8 01 00 00 00       	mov    $0x1,%eax
  802319:	31 d2                	xor    %edx,%edx
  80231b:	f7 f1                	div    %ecx
  80231d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80231f:	31 d2                	xor    %edx,%edx
  802321:	89 f8                	mov    %edi,%eax
  802323:	f7 f1                	div    %ecx
  802325:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802327:	89 f0                	mov    %esi,%eax
  802329:	f7 f1                	div    %ecx
  80232b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80232d:	89 f0                	mov    %esi,%eax
  80232f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	5e                   	pop    %esi
  802335:	5f                   	pop    %edi
  802336:	5d                   	pop    %ebp
  802337:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802338:	39 f8                	cmp    %edi,%eax
  80233a:	77 2c                	ja     802368 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80233c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80233f:	83 f6 1f             	xor    $0x1f,%esi
  802342:	75 4c                	jne    802390 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802344:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802346:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80234b:	72 0a                	jb     802357 <__udivdi3+0x6b>
  80234d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802351:	0f 87 ad 00 00 00    	ja     802404 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802357:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80235c:	89 f0                	mov    %esi,%eax
  80235e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802360:	83 c4 10             	add    $0x10,%esp
  802363:	5e                   	pop    %esi
  802364:	5f                   	pop    %edi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    
  802367:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802368:	31 ff                	xor    %edi,%edi
  80236a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80236c:	89 f0                	mov    %esi,%eax
  80236e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	5e                   	pop    %esi
  802374:	5f                   	pop    %edi
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    
  802377:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802378:	89 fa                	mov    %edi,%edx
  80237a:	89 f0                	mov    %esi,%eax
  80237c:	f7 f1                	div    %ecx
  80237e:	89 c6                	mov    %eax,%esi
  802380:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802382:	89 f0                	mov    %esi,%eax
  802384:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802390:	89 f1                	mov    %esi,%ecx
  802392:	d3 e0                	shl    %cl,%eax
  802394:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802398:	b8 20 00 00 00       	mov    $0x20,%eax
  80239d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80239f:	89 ea                	mov    %ebp,%edx
  8023a1:	88 c1                	mov    %al,%cl
  8023a3:	d3 ea                	shr    %cl,%edx
  8023a5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023a9:	09 ca                	or     %ecx,%edx
  8023ab:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8023af:	89 f1                	mov    %esi,%ecx
  8023b1:	d3 e5                	shl    %cl,%ebp
  8023b3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8023b7:	89 fd                	mov    %edi,%ebp
  8023b9:	88 c1                	mov    %al,%cl
  8023bb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8023bd:	89 fa                	mov    %edi,%edx
  8023bf:	89 f1                	mov    %esi,%ecx
  8023c1:	d3 e2                	shl    %cl,%edx
  8023c3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023c7:	88 c1                	mov    %al,%cl
  8023c9:	d3 ef                	shr    %cl,%edi
  8023cb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023cd:	89 f8                	mov    %edi,%eax
  8023cf:	89 ea                	mov    %ebp,%edx
  8023d1:	f7 74 24 08          	divl   0x8(%esp)
  8023d5:	89 d1                	mov    %edx,%ecx
  8023d7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023d9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023dd:	39 d1                	cmp    %edx,%ecx
  8023df:	72 17                	jb     8023f8 <__udivdi3+0x10c>
  8023e1:	74 09                	je     8023ec <__udivdi3+0x100>
  8023e3:	89 fe                	mov    %edi,%esi
  8023e5:	31 ff                	xor    %edi,%edi
  8023e7:	e9 41 ff ff ff       	jmp    80232d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023ec:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023f0:	89 f1                	mov    %esi,%ecx
  8023f2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f4:	39 c2                	cmp    %eax,%edx
  8023f6:	73 eb                	jae    8023e3 <__udivdi3+0xf7>
		{
		  q0--;
  8023f8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023fb:	31 ff                	xor    %edi,%edi
  8023fd:	e9 2b ff ff ff       	jmp    80232d <__udivdi3+0x41>
  802402:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802404:	31 f6                	xor    %esi,%esi
  802406:	e9 22 ff ff ff       	jmp    80232d <__udivdi3+0x41>
	...

0080240c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80240c:	55                   	push   %ebp
  80240d:	57                   	push   %edi
  80240e:	56                   	push   %esi
  80240f:	83 ec 20             	sub    $0x20,%esp
  802412:	8b 44 24 30          	mov    0x30(%esp),%eax
  802416:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80241a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80241e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802422:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802426:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80242a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80242c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80242e:	85 ed                	test   %ebp,%ebp
  802430:	75 16                	jne    802448 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802432:	39 f1                	cmp    %esi,%ecx
  802434:	0f 86 a6 00 00 00    	jbe    8024e0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80243a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80243c:	89 d0                	mov    %edx,%eax
  80243e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802440:	83 c4 20             	add    $0x20,%esp
  802443:	5e                   	pop    %esi
  802444:	5f                   	pop    %edi
  802445:	5d                   	pop    %ebp
  802446:	c3                   	ret    
  802447:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802448:	39 f5                	cmp    %esi,%ebp
  80244a:	0f 87 ac 00 00 00    	ja     8024fc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802450:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802453:	83 f0 1f             	xor    $0x1f,%eax
  802456:	89 44 24 10          	mov    %eax,0x10(%esp)
  80245a:	0f 84 a8 00 00 00    	je     802508 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802460:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802464:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802466:	bf 20 00 00 00       	mov    $0x20,%edi
  80246b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80246f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802473:	89 f9                	mov    %edi,%ecx
  802475:	d3 e8                	shr    %cl,%eax
  802477:	09 e8                	or     %ebp,%eax
  802479:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80247d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802481:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802485:	d3 e0                	shl    %cl,%eax
  802487:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80248b:	89 f2                	mov    %esi,%edx
  80248d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80248f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802493:	d3 e0                	shl    %cl,%eax
  802495:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802499:	8b 44 24 14          	mov    0x14(%esp),%eax
  80249d:	89 f9                	mov    %edi,%ecx
  80249f:	d3 e8                	shr    %cl,%eax
  8024a1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8024a3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024a5:	89 f2                	mov    %esi,%edx
  8024a7:	f7 74 24 18          	divl   0x18(%esp)
  8024ab:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024ad:	f7 64 24 0c          	mull   0xc(%esp)
  8024b1:	89 c5                	mov    %eax,%ebp
  8024b3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024b5:	39 d6                	cmp    %edx,%esi
  8024b7:	72 67                	jb     802520 <__umoddi3+0x114>
  8024b9:	74 75                	je     802530 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8024bb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024bf:	29 e8                	sub    %ebp,%eax
  8024c1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024c3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024c7:	d3 e8                	shr    %cl,%eax
  8024c9:	89 f2                	mov    %esi,%edx
  8024cb:	89 f9                	mov    %edi,%ecx
  8024cd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024cf:	09 d0                	or     %edx,%eax
  8024d1:	89 f2                	mov    %esi,%edx
  8024d3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024d9:	83 c4 20             	add    $0x20,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024e0:	85 c9                	test   %ecx,%ecx
  8024e2:	75 0b                	jne    8024ef <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e9:	31 d2                	xor    %edx,%edx
  8024eb:	f7 f1                	div    %ecx
  8024ed:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024ef:	89 f0                	mov    %esi,%eax
  8024f1:	31 d2                	xor    %edx,%edx
  8024f3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024f5:	89 f8                	mov    %edi,%eax
  8024f7:	e9 3e ff ff ff       	jmp    80243a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024fc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024fe:	83 c4 20             	add    $0x20,%esp
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802508:	39 f5                	cmp    %esi,%ebp
  80250a:	72 04                	jb     802510 <__umoddi3+0x104>
  80250c:	39 f9                	cmp    %edi,%ecx
  80250e:	77 06                	ja     802516 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802510:	89 f2                	mov    %esi,%edx
  802512:	29 cf                	sub    %ecx,%edi
  802514:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802516:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802518:	83 c4 20             	add    $0x20,%esp
  80251b:	5e                   	pop    %esi
  80251c:	5f                   	pop    %edi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    
  80251f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802520:	89 d1                	mov    %edx,%ecx
  802522:	89 c5                	mov    %eax,%ebp
  802524:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802528:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80252c:	eb 8d                	jmp    8024bb <__umoddi3+0xaf>
  80252e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802530:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802534:	72 ea                	jb     802520 <__umoddi3+0x114>
  802536:	89 f1                	mov    %esi,%ecx
  802538:	eb 81                	jmp    8024bb <__umoddi3+0xaf>
