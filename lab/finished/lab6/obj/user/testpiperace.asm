
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 db 01 00 00       	call   80020c <libmain>
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
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003c:	c7 04 24 e0 2a 80 00 	movl   $0x802ae0,(%esp)
  800043:	e8 18 03 00 00       	call   800360 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 4a 24 00 00       	call   80249d <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 f9 2a 80 	movl   $0x802af9,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  800072:	e8 f1 01 00 00       	call   800268 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800077:	e8 7b 10 00 00       	call   8010f7 <fork>
  80007c:	89 c6                	mov    %eax,%esi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 16 2b 80 	movl   $0x802b16,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  80009d:	e8 c6 01 00 00       	call   800268 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 54                	jne    8000fa <umain+0xc6>
		close(p[1]);
  8000a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 fd 15 00 00       	call   8016ae <close>
  8000b1:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 4c 25 00 00       	call   80260d <pipeisclosed>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	74 11                	je     8000d6 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000c5:	c7 04 24 1f 2b 80 00 	movl   $0x802b1f,(%esp)
  8000cc:	e8 8f 02 00 00       	call   800360 <cprintf>
				exit();
  8000d1:	e8 7e 01 00 00       	call   800254 <exit>
			}
			sys_yield();
  8000d6:	e8 03 0c 00 00       	call   800cde <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000db:	4b                   	dec    %ebx
  8000dc:	75 d8                	jne    8000b6 <umain+0x82>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f5:	e8 ee 12 00 00       	call   8013e8 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fe:	c7 04 24 3a 2b 80 00 	movl   $0x802b3a,(%esp)
  800105:	e8 56 02 00 00       	call   800360 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  80010a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800110:	c1 e6 07             	shl    $0x7,%esi
	cprintf("kid is %d\n", kid-envs);
  800113:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800119:	c1 ee 07             	shr    $0x7,%esi
  80011c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800120:	c7 04 24 45 2b 80 00 	movl   $0x802b45,(%esp)
  800127:	e8 34 02 00 00       	call   800360 <cprintf>
	dup(p[0], 10);
  80012c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800133:	00 
  800134:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 c0 15 00 00       	call   8016ff <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80013f:	eb 13                	jmp    800154 <umain+0x120>
		dup(p[0], 10);
  800141:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800148:	00 
  800149:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80014c:	89 04 24             	mov    %eax,(%esp)
  80014f:	e8 ab 15 00 00       	call   8016ff <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800154:	8b 43 54             	mov    0x54(%ebx),%eax
  800157:	83 f8 02             	cmp    $0x2,%eax
  80015a:	74 e5                	je     800141 <umain+0x10d>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  80015c:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  800163:	e8 f8 01 00 00       	call   800360 <cprintf>
	if (pipeisclosed(p[0]))
  800168:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 9a 24 00 00       	call   80260d <pipeisclosed>
  800173:	85 c0                	test   %eax,%eax
  800175:	74 1c                	je     800193 <umain+0x15f>
		panic("somehow the other end of p[0] got closed!");
  800177:	c7 44 24 08 ac 2b 80 	movl   $0x802bac,0x8(%esp)
  80017e:	00 
  80017f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800186:	00 
  800187:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  80018e:	e8 d5 00 00 00       	call   800268 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800193:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 d1 13 00 00       	call   801576 <fd_lookup>
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	79 20                	jns    8001c9 <umain+0x195>
		panic("cannot look up p[0]: %e", r);
  8001a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ad:	c7 44 24 08 66 2b 80 	movl   $0x802b66,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 02 2b 80 00 	movl   $0x802b02,(%esp)
  8001c4:	e8 9f 00 00 00       	call   800268 <_panic>
	va = fd2data(fd);
  8001c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001cc:	89 04 24             	mov    %eax,(%esp)
  8001cf:	e8 34 13 00 00       	call   801508 <fd2data>
	if (pageref(va) != 3+1)
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 ac 1b 00 00       	call   801d88 <pageref>
  8001dc:	83 f8 04             	cmp    $0x4,%eax
  8001df:	74 0e                	je     8001ef <umain+0x1bb>
		cprintf("\nchild detected race\n");
  8001e1:	c7 04 24 7e 2b 80 00 	movl   $0x802b7e,(%esp)
  8001e8:	e8 73 01 00 00       	call   800360 <cprintf>
  8001ed:	eb 14                	jmp    800203 <umain+0x1cf>
	else
		cprintf("\nrace didn't happen\n", max);
  8001ef:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  8001f6:	00 
  8001f7:	c7 04 24 94 2b 80 00 	movl   $0x802b94,(%esp)
  8001fe:	e8 5d 01 00 00       	call   800360 <cprintf>
}
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
	...

0080020c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 10             	sub    $0x10,%esp
  800214:	8b 75 08             	mov    0x8(%ebp),%esi
  800217:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80021a:	e8 a0 0a 00 00       	call   800cbf <sys_getenvid>
  80021f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800224:	c1 e0 07             	shl    $0x7,%eax
  800227:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80022c:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800231:	85 f6                	test   %esi,%esi
  800233:	7e 07                	jle    80023c <libmain+0x30>
		binaryname = argv[0];
  800235:	8b 03                	mov    (%ebx),%eax
  800237:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80023c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800240:	89 34 24             	mov    %esi,(%esp)
  800243:	e8 ec fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800248:	e8 07 00 00 00       	call   800254 <exit>
}
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80025a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800261:	e8 07 0a 00 00       	call   800c6d <sys_env_destroy>
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800270:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800273:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800279:	e8 41 0a 00 00       	call   800cbf <sys_getenvid>
  80027e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800281:	89 54 24 10          	mov    %edx,0x10(%esp)
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80028c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800290:	89 44 24 04          	mov    %eax,0x4(%esp)
  800294:	c7 04 24 e0 2b 80 00 	movl   $0x802be0,(%esp)
  80029b:	e8 c0 00 00 00       	call   800360 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a7:	89 04 24             	mov    %eax,(%esp)
  8002aa:	e8 50 00 00 00       	call   8002ff <vcprintf>
	cprintf("\n");
  8002af:	c7 04 24 f7 2a 80 00 	movl   $0x802af7,(%esp)
  8002b6:	e8 a5 00 00 00       	call   800360 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002bb:	cc                   	int3   
  8002bc:	eb fd                	jmp    8002bb <_panic+0x53>
	...

008002c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 14             	sub    $0x14,%esp
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002ca:	8b 03                	mov    (%ebx),%eax
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002d3:	40                   	inc    %eax
  8002d4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002db:	75 19                	jne    8002f6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8002dd:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002e4:	00 
  8002e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 40 09 00 00       	call   800c30 <sys_cputs>
		b->idx = 0;
  8002f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002f6:	ff 43 04             	incl   0x4(%ebx)
}
  8002f9:	83 c4 14             	add    $0x14,%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800308:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80030f:	00 00 00 
	b.cnt = 0;
  800312:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800319:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80031c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	89 44 24 08          	mov    %eax,0x8(%esp)
  80032a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800330:	89 44 24 04          	mov    %eax,0x4(%esp)
  800334:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  80033b:	e8 82 01 00 00       	call   8004c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800340:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800350:	89 04 24             	mov    %eax,(%esp)
  800353:	e8 d8 08 00 00       	call   800c30 <sys_cputs>

	return b.cnt;
}
  800358:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800366:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	89 04 24             	mov    %eax,(%esp)
  800373:	e8 87 ff ff ff       	call   8002ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800378:	c9                   	leave  
  800379:	c3                   	ret    
	...

0080037c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
  800382:	83 ec 3c             	sub    $0x3c,%esp
  800385:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800388:	89 d7                	mov    %edx,%edi
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800390:	8b 45 0c             	mov    0xc(%ebp),%eax
  800393:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800396:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800399:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039c:	85 c0                	test   %eax,%eax
  80039e:	75 08                	jne    8003a8 <printnum+0x2c>
  8003a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003a6:	77 57                	ja     8003ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003ac:	4b                   	dec    %ebx
  8003ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003c7:	00 
  8003c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003d5:	e8 9e 24 00 00       	call   802878 <__udivdi3>
  8003da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003e2:	89 04 24             	mov    %eax,(%esp)
  8003e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003e9:	89 fa                	mov    %edi,%edx
  8003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ee:	e8 89 ff ff ff       	call   80037c <printnum>
  8003f3:	eb 0f                	jmp    800404 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	89 34 24             	mov    %esi,(%esp)
  8003fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003ff:	4b                   	dec    %ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f f1                	jg     8003f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800408:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
  80040f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800413:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041a:	00 
  80041b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800424:	89 44 24 04          	mov    %eax,0x4(%esp)
  800428:	e8 6b 25 00 00       	call   802998 <__umoddi3>
  80042d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800431:	0f be 80 03 2c 80 00 	movsbl 0x802c03(%eax),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80043e:	83 c4 3c             	add    $0x3c,%esp
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800449:	83 fa 01             	cmp    $0x1,%edx
  80044c:	7e 0e                	jle    80045c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 08             	lea    0x8(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	8b 52 04             	mov    0x4(%edx),%edx
  80045a:	eb 22                	jmp    80047e <getuint+0x38>
	else if (lflag)
  80045c:	85 d2                	test   %edx,%edx
  80045e:	74 10                	je     800470 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 04             	lea    0x4(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
  80046e:	eb 0e                	jmp    80047e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800470:	8b 10                	mov    (%eax),%edx
  800472:	8d 4a 04             	lea    0x4(%edx),%ecx
  800475:	89 08                	mov    %ecx,(%eax)
  800477:	8b 02                	mov    (%edx),%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80047e:	5d                   	pop    %ebp
  80047f:	c3                   	ret    

00800480 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800486:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800489:	8b 10                	mov    (%eax),%edx
  80048b:	3b 50 04             	cmp    0x4(%eax),%edx
  80048e:	73 08                	jae    800498 <sprintputch+0x18>
		*b->buf++ = ch;
  800490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800493:	88 0a                	mov    %cl,(%edx)
  800495:	42                   	inc    %edx
  800496:	89 10                	mov    %edx,(%eax)
}
  800498:	5d                   	pop    %ebp
  800499:	c3                   	ret    

0080049a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	e8 02 00 00 00       	call   8004c2 <vprintfmt>
	va_end(ap);
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	57                   	push   %edi
  8004c6:	56                   	push   %esi
  8004c7:	53                   	push   %ebx
  8004c8:	83 ec 4c             	sub    $0x4c,%esp
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8004d1:	eb 12                	jmp    8004e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004d3:	85 c0                	test   %eax,%eax
  8004d5:	0f 84 6b 03 00 00    	je     800846 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8004db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e5:	0f b6 06             	movzbl (%esi),%eax
  8004e8:	46                   	inc    %esi
  8004e9:	83 f8 25             	cmp    $0x25,%eax
  8004ec:	75 e5                	jne    8004d3 <vprintfmt+0x11>
  8004ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8004f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8004f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8004fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800505:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050a:	eb 26                	jmp    800532 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80050f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800513:	eb 1d                	jmp    800532 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800518:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80051c:	eb 14                	jmp    800532 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800521:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800528:	eb 08                	jmp    800532 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80052a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80052d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	0f b6 06             	movzbl (%esi),%eax
  800535:	8d 56 01             	lea    0x1(%esi),%edx
  800538:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80053b:	8a 16                	mov    (%esi),%dl
  80053d:	83 ea 23             	sub    $0x23,%edx
  800540:	80 fa 55             	cmp    $0x55,%dl
  800543:	0f 87 e1 02 00 00    	ja     80082a <vprintfmt+0x368>
  800549:	0f b6 d2             	movzbl %dl,%edx
  80054c:	ff 24 95 40 2d 80 00 	jmp    *0x802d40(,%edx,4)
  800553:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800556:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80055b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80055e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800562:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800565:	8d 50 d0             	lea    -0x30(%eax),%edx
  800568:	83 fa 09             	cmp    $0x9,%edx
  80056b:	77 2a                	ja     800597 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80056d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80056e:	eb eb                	jmp    80055b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80057e:	eb 17                	jmp    800597 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800580:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800584:	78 98                	js     80051e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800589:	eb a7                	jmp    800532 <vprintfmt+0x70>
  80058b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80058e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800595:	eb 9b                	jmp    800532 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800597:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059b:	79 95                	jns    800532 <vprintfmt+0x70>
  80059d:	eb 8b                	jmp    80052a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80059f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005a3:	eb 8d                	jmp    800532 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005bd:	e9 23 ff ff ff       	jmp    8004e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 50 04             	lea    0x4(%eax),%edx
  8005c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	79 02                	jns    8005d3 <vprintfmt+0x111>
  8005d1:	f7 d8                	neg    %eax
  8005d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d5:	83 f8 11             	cmp    $0x11,%eax
  8005d8:	7f 0b                	jg     8005e5 <vprintfmt+0x123>
  8005da:	8b 04 85 a0 2e 80 00 	mov    0x802ea0(,%eax,4),%eax
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	75 23                	jne    800608 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8005e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e9:	c7 44 24 08 1b 2c 80 	movl   $0x802c1b,0x8(%esp)
  8005f0:	00 
  8005f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f8:	89 04 24             	mov    %eax,(%esp)
  8005fb:	e8 9a fe ff ff       	call   80049a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800603:	e9 dd fe ff ff       	jmp    8004e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800608:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060c:	c7 44 24 08 01 31 80 	movl   $0x803101,0x8(%esp)
  800613:	00 
  800614:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800618:	8b 55 08             	mov    0x8(%ebp),%edx
  80061b:	89 14 24             	mov    %edx,(%esp)
  80061e:	e8 77 fe ff ff       	call   80049a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800626:	e9 ba fe ff ff       	jmp    8004e5 <vprintfmt+0x23>
  80062b:	89 f9                	mov    %edi,%ecx
  80062d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800630:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 30                	mov    (%eax),%esi
  80063e:	85 f6                	test   %esi,%esi
  800640:	75 05                	jne    800647 <vprintfmt+0x185>
				p = "(null)";
  800642:	be 14 2c 80 00       	mov    $0x802c14,%esi
			if (width > 0 && padc != '-')
  800647:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80064b:	0f 8e 84 00 00 00    	jle    8006d5 <vprintfmt+0x213>
  800651:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800655:	74 7e                	je     8006d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800657:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065b:	89 34 24             	mov    %esi,(%esp)
  80065e:	e8 8b 02 00 00       	call   8008ee <strnlen>
  800663:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800666:	29 c2                	sub    %eax,%edx
  800668:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80066b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80066f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800672:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800675:	89 de                	mov    %ebx,%esi
  800677:	89 d3                	mov    %edx,%ebx
  800679:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067b:	eb 0b                	jmp    800688 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80067d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800681:	89 3c 24             	mov    %edi,(%esp)
  800684:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800687:	4b                   	dec    %ebx
  800688:	85 db                	test   %ebx,%ebx
  80068a:	7f f1                	jg     80067d <vprintfmt+0x1bb>
  80068c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80068f:	89 f3                	mov    %esi,%ebx
  800691:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800694:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800697:	85 c0                	test   %eax,%eax
  800699:	79 05                	jns    8006a0 <vprintfmt+0x1de>
  80069b:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006a3:	29 c2                	sub    %eax,%edx
  8006a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006a8:	eb 2b                	jmp    8006d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006ae:	74 18                	je     8006c8 <vprintfmt+0x206>
  8006b0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006b3:	83 fa 5e             	cmp    $0x5e,%edx
  8006b6:	76 10                	jbe    8006c8 <vprintfmt+0x206>
					putch('?', putdat);
  8006b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
  8006c6:	eb 0a                	jmp    8006d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d2:	ff 4d e4             	decl   -0x1c(%ebp)
  8006d5:	0f be 06             	movsbl (%esi),%eax
  8006d8:	46                   	inc    %esi
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 21                	je     8006fe <vprintfmt+0x23c>
  8006dd:	85 ff                	test   %edi,%edi
  8006df:	78 c9                	js     8006aa <vprintfmt+0x1e8>
  8006e1:	4f                   	dec    %edi
  8006e2:	79 c6                	jns    8006aa <vprintfmt+0x1e8>
  8006e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e7:	89 de                	mov    %ebx,%esi
  8006e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006ec:	eb 18                	jmp    800706 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fb:	4b                   	dec    %ebx
  8006fc:	eb 08                	jmp    800706 <vprintfmt+0x244>
  8006fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800701:	89 de                	mov    %ebx,%esi
  800703:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800706:	85 db                	test   %ebx,%ebx
  800708:	7f e4                	jg     8006ee <vprintfmt+0x22c>
  80070a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80070d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800712:	e9 ce fd ff ff       	jmp    8004e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800717:	83 f9 01             	cmp    $0x1,%ecx
  80071a:	7e 10                	jle    80072c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 08             	lea    0x8(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
  800725:	8b 30                	mov    (%eax),%esi
  800727:	8b 78 04             	mov    0x4(%eax),%edi
  80072a:	eb 26                	jmp    800752 <vprintfmt+0x290>
	else if (lflag)
  80072c:	85 c9                	test   %ecx,%ecx
  80072e:	74 12                	je     800742 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8d 50 04             	lea    0x4(%eax),%edx
  800736:	89 55 14             	mov    %edx,0x14(%ebp)
  800739:	8b 30                	mov    (%eax),%esi
  80073b:	89 f7                	mov    %esi,%edi
  80073d:	c1 ff 1f             	sar    $0x1f,%edi
  800740:	eb 10                	jmp    800752 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 04             	lea    0x4(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
  80074b:	8b 30                	mov    (%eax),%esi
  80074d:	89 f7                	mov    %esi,%edi
  80074f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800752:	85 ff                	test   %edi,%edi
  800754:	78 0a                	js     800760 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800756:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075b:	e9 8c 00 00 00       	jmp    8007ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800764:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80076b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80076e:	f7 de                	neg    %esi
  800770:	83 d7 00             	adc    $0x0,%edi
  800773:	f7 df                	neg    %edi
			}
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	eb 70                	jmp    8007ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077c:	89 ca                	mov    %ecx,%edx
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
  800781:	e8 c0 fc ff ff       	call   800446 <getuint>
  800786:	89 c6                	mov    %eax,%esi
  800788:	89 d7                	mov    %edx,%edi
			base = 10;
  80078a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80078f:	eb 5b                	jmp    8007ec <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800791:	89 ca                	mov    %ecx,%edx
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	e8 ab fc ff ff       	call   800446 <getuint>
  80079b:	89 c6                	mov    %eax,%esi
  80079d:	89 d7                	mov    %edx,%edi
			base = 8;
  80079f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007a4:	eb 46                	jmp    8007ec <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007cb:	8b 30                	mov    (%eax),%esi
  8007cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d7:	eb 13                	jmp    8007ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d9:	89 ca                	mov    %ecx,%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 63 fc ff ff       	call   800446 <getuint>
  8007e3:	89 c6                	mov    %eax,%esi
  8007e5:	89 d7                	mov    %edx,%edi
			base = 16;
  8007e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007f0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ff:	89 34 24             	mov    %esi,(%esp)
  800802:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800806:	89 da                	mov    %ebx,%edx
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	e8 6c fb ff ff       	call   80037c <printnum>
			break;
  800810:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800813:	e9 cd fc ff ff       	jmp    8004e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800818:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800822:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800825:	e9 bb fc ff ff       	jmp    8004e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800835:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800838:	eb 01                	jmp    80083b <vprintfmt+0x379>
  80083a:	4e                   	dec    %esi
  80083b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80083f:	75 f9                	jne    80083a <vprintfmt+0x378>
  800841:	e9 9f fc ff ff       	jmp    8004e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800846:	83 c4 4c             	add    $0x4c,%esp
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5f                   	pop    %edi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	83 ec 28             	sub    $0x28,%esp
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800861:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800864:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086b:	85 c0                	test   %eax,%eax
  80086d:	74 30                	je     80089f <vsnprintf+0x51>
  80086f:	85 d2                	test   %edx,%edx
  800871:	7e 33                	jle    8008a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087a:	8b 45 10             	mov    0x10(%ebp),%eax
  80087d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800881:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800884:	89 44 24 04          	mov    %eax,0x4(%esp)
  800888:	c7 04 24 80 04 80 00 	movl   $0x800480,(%esp)
  80088f:	e8 2e fc ff ff       	call   8004c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800894:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800897:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80089a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089d:	eb 0c                	jmp    8008ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a4:	eb 05                	jmp    8008ab <vsnprintf+0x5d>
  8008a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ab:	c9                   	leave  
  8008ac:	c3                   	ret    

008008ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8008bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	e8 7b ff ff ff       	call   80084e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    
  8008d5:	00 00                	add    %al,(%eax)
	...

008008d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e3:	eb 01                	jmp    8008e6 <strlen+0xe>
		n++;
  8008e5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ea:	75 f9                	jne    8008e5 <strlen+0xd>
		n++;
	return n;
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008f4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	eb 01                	jmp    8008ff <strnlen+0x11>
		n++;
  8008fe:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ff:	39 d0                	cmp    %edx,%eax
  800901:	74 06                	je     800909 <strnlen+0x1b>
  800903:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800907:	75 f5                	jne    8008fe <strnlen+0x10>
		n++;
	return n;
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800915:	ba 00 00 00 00       	mov    $0x0,%edx
  80091a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80091d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800920:	42                   	inc    %edx
  800921:	84 c9                	test   %cl,%cl
  800923:	75 f5                	jne    80091a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800925:	5b                   	pop    %ebx
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	53                   	push   %ebx
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800932:	89 1c 24             	mov    %ebx,(%esp)
  800935:	e8 9e ff ff ff       	call   8008d8 <strlen>
	strcpy(dst + len, src);
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800941:	01 d8                	add    %ebx,%eax
  800943:	89 04 24             	mov    %eax,(%esp)
  800946:	e8 c0 ff ff ff       	call   80090b <strcpy>
	return dst;
}
  80094b:	89 d8                	mov    %ebx,%eax
  80094d:	83 c4 08             	add    $0x8,%esp
  800950:	5b                   	pop    %ebx
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800961:	b9 00 00 00 00       	mov    $0x0,%ecx
  800966:	eb 0c                	jmp    800974 <strncpy+0x21>
		*dst++ = *src;
  800968:	8a 1a                	mov    (%edx),%bl
  80096a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80096d:	80 3a 01             	cmpb   $0x1,(%edx)
  800970:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800973:	41                   	inc    %ecx
  800974:	39 f1                	cmp    %esi,%ecx
  800976:	75 f0                	jne    800968 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 75 08             	mov    0x8(%ebp),%esi
  800984:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800987:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098a:	85 d2                	test   %edx,%edx
  80098c:	75 0a                	jne    800998 <strlcpy+0x1c>
  80098e:	89 f0                	mov    %esi,%eax
  800990:	eb 1a                	jmp    8009ac <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800992:	88 18                	mov    %bl,(%eax)
  800994:	40                   	inc    %eax
  800995:	41                   	inc    %ecx
  800996:	eb 02                	jmp    80099a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800998:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80099a:	4a                   	dec    %edx
  80099b:	74 0a                	je     8009a7 <strlcpy+0x2b>
  80099d:	8a 19                	mov    (%ecx),%bl
  80099f:	84 db                	test   %bl,%bl
  8009a1:	75 ef                	jne    800992 <strlcpy+0x16>
  8009a3:	89 c2                	mov    %eax,%edx
  8009a5:	eb 02                	jmp    8009a9 <strlcpy+0x2d>
  8009a7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009a9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009ac:	29 f0                	sub    %esi,%eax
}
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009bb:	eb 02                	jmp    8009bf <strcmp+0xd>
		p++, q++;
  8009bd:	41                   	inc    %ecx
  8009be:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bf:	8a 01                	mov    (%ecx),%al
  8009c1:	84 c0                	test   %al,%al
  8009c3:	74 04                	je     8009c9 <strcmp+0x17>
  8009c5:	3a 02                	cmp    (%edx),%al
  8009c7:	74 f4                	je     8009bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c9:	0f b6 c0             	movzbl %al,%eax
  8009cc:	0f b6 12             	movzbl (%edx),%edx
  8009cf:	29 d0                	sub    %edx,%eax
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dd:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009e0:	eb 03                	jmp    8009e5 <strncmp+0x12>
		n--, p++, q++;
  8009e2:	4a                   	dec    %edx
  8009e3:	40                   	inc    %eax
  8009e4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009e5:	85 d2                	test   %edx,%edx
  8009e7:	74 14                	je     8009fd <strncmp+0x2a>
  8009e9:	8a 18                	mov    (%eax),%bl
  8009eb:	84 db                	test   %bl,%bl
  8009ed:	74 04                	je     8009f3 <strncmp+0x20>
  8009ef:	3a 19                	cmp    (%ecx),%bl
  8009f1:	74 ef                	je     8009e2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f3:	0f b6 00             	movzbl (%eax),%eax
  8009f6:	0f b6 11             	movzbl (%ecx),%edx
  8009f9:	29 d0                	sub    %edx,%eax
  8009fb:	eb 05                	jmp    800a02 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a0e:	eb 05                	jmp    800a15 <strchr+0x10>
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	74 0c                	je     800a20 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a14:	40                   	inc    %eax
  800a15:	8a 10                	mov    (%eax),%dl
  800a17:	84 d2                	test   %dl,%dl
  800a19:	75 f5                	jne    800a10 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a2b:	eb 05                	jmp    800a32 <strfind+0x10>
		if (*s == c)
  800a2d:	38 ca                	cmp    %cl,%dl
  800a2f:	74 07                	je     800a38 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a31:	40                   	inc    %eax
  800a32:	8a 10                	mov    (%eax),%dl
  800a34:	84 d2                	test   %dl,%dl
  800a36:	75 f5                	jne    800a2d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 30                	je     800a7d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a53:	75 25                	jne    800a7a <memset+0x40>
  800a55:	f6 c1 03             	test   $0x3,%cl
  800a58:	75 20                	jne    800a7a <memset+0x40>
		c &= 0xFF;
  800a5a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5d:	89 d3                	mov    %edx,%ebx
  800a5f:	c1 e3 08             	shl    $0x8,%ebx
  800a62:	89 d6                	mov    %edx,%esi
  800a64:	c1 e6 18             	shl    $0x18,%esi
  800a67:	89 d0                	mov    %edx,%eax
  800a69:	c1 e0 10             	shl    $0x10,%eax
  800a6c:	09 f0                	or     %esi,%eax
  800a6e:	09 d0                	or     %edx,%eax
  800a70:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a72:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb 03                	jmp    800a7d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7a:	fc                   	cld    
  800a7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a7d:	89 f8                	mov    %edi,%eax
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a92:	39 c6                	cmp    %eax,%esi
  800a94:	73 34                	jae    800aca <memmove+0x46>
  800a96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a99:	39 d0                	cmp    %edx,%eax
  800a9b:	73 2d                	jae    800aca <memmove+0x46>
		s += n;
		d += n;
  800a9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa0:	f6 c2 03             	test   $0x3,%dl
  800aa3:	75 1b                	jne    800ac0 <memmove+0x3c>
  800aa5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aab:	75 13                	jne    800ac0 <memmove+0x3c>
  800aad:	f6 c1 03             	test   $0x3,%cl
  800ab0:	75 0e                	jne    800ac0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab2:	83 ef 04             	sub    $0x4,%edi
  800ab5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800abb:	fd                   	std    
  800abc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abe:	eb 07                	jmp    800ac7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac0:	4f                   	dec    %edi
  800ac1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac4:	fd                   	std    
  800ac5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac7:	fc                   	cld    
  800ac8:	eb 20                	jmp    800aea <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad0:	75 13                	jne    800ae5 <memmove+0x61>
  800ad2:	a8 03                	test   $0x3,%al
  800ad4:	75 0f                	jne    800ae5 <memmove+0x61>
  800ad6:	f6 c1 03             	test   $0x3,%cl
  800ad9:	75 0a                	jne    800ae5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ade:	89 c7                	mov    %eax,%edi
  800ae0:	fc                   	cld    
  800ae1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae3:	eb 05                	jmp    800aea <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	fc                   	cld    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af4:	8b 45 10             	mov    0x10(%ebp),%eax
  800af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	89 04 24             	mov    %eax,(%esp)
  800b08:	e8 77 ff ff ff       	call   800a84 <memmove>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	eb 16                	jmp    800b3b <memcmp+0x2c>
		if (*s1 != *s2)
  800b25:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b28:	42                   	inc    %edx
  800b29:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b2d:	38 c8                	cmp    %cl,%al
  800b2f:	74 0a                	je     800b3b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b31:	0f b6 c0             	movzbl %al,%eax
  800b34:	0f b6 c9             	movzbl %cl,%ecx
  800b37:	29 c8                	sub    %ecx,%eax
  800b39:	eb 09                	jmp    800b44 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3b:	39 da                	cmp    %ebx,%edx
  800b3d:	75 e6                	jne    800b25 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b57:	eb 05                	jmp    800b5e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b59:	38 08                	cmp    %cl,(%eax)
  800b5b:	74 05                	je     800b62 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5d:	40                   	inc    %eax
  800b5e:	39 d0                	cmp    %edx,%eax
  800b60:	72 f7                	jb     800b59 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b70:	eb 01                	jmp    800b73 <strtol+0xf>
		s++;
  800b72:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b73:	8a 02                	mov    (%edx),%al
  800b75:	3c 20                	cmp    $0x20,%al
  800b77:	74 f9                	je     800b72 <strtol+0xe>
  800b79:	3c 09                	cmp    $0x9,%al
  800b7b:	74 f5                	je     800b72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7d:	3c 2b                	cmp    $0x2b,%al
  800b7f:	75 08                	jne    800b89 <strtol+0x25>
		s++;
  800b81:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb 13                	jmp    800b9c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b89:	3c 2d                	cmp    $0x2d,%al
  800b8b:	75 0a                	jne    800b97 <strtol+0x33>
		s++, neg = 1;
  800b8d:	8d 52 01             	lea    0x1(%edx),%edx
  800b90:	bf 01 00 00 00       	mov    $0x1,%edi
  800b95:	eb 05                	jmp    800b9c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b97:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9c:	85 db                	test   %ebx,%ebx
  800b9e:	74 05                	je     800ba5 <strtol+0x41>
  800ba0:	83 fb 10             	cmp    $0x10,%ebx
  800ba3:	75 28                	jne    800bcd <strtol+0x69>
  800ba5:	8a 02                	mov    (%edx),%al
  800ba7:	3c 30                	cmp    $0x30,%al
  800ba9:	75 10                	jne    800bbb <strtol+0x57>
  800bab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800baf:	75 0a                	jne    800bbb <strtol+0x57>
		s += 2, base = 16;
  800bb1:	83 c2 02             	add    $0x2,%edx
  800bb4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb9:	eb 12                	jmp    800bcd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800bbb:	85 db                	test   %ebx,%ebx
  800bbd:	75 0e                	jne    800bcd <strtol+0x69>
  800bbf:	3c 30                	cmp    $0x30,%al
  800bc1:	75 05                	jne    800bc8 <strtol+0x64>
		s++, base = 8;
  800bc3:	42                   	inc    %edx
  800bc4:	b3 08                	mov    $0x8,%bl
  800bc6:	eb 05                	jmp    800bcd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bc8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd4:	8a 0a                	mov    (%edx),%cl
  800bd6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bd9:	80 fb 09             	cmp    $0x9,%bl
  800bdc:	77 08                	ja     800be6 <strtol+0x82>
			dig = *s - '0';
  800bde:	0f be c9             	movsbl %cl,%ecx
  800be1:	83 e9 30             	sub    $0x30,%ecx
  800be4:	eb 1e                	jmp    800c04 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800be9:	80 fb 19             	cmp    $0x19,%bl
  800bec:	77 08                	ja     800bf6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800bee:	0f be c9             	movsbl %cl,%ecx
  800bf1:	83 e9 57             	sub    $0x57,%ecx
  800bf4:	eb 0e                	jmp    800c04 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800bf6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800bf9:	80 fb 19             	cmp    $0x19,%bl
  800bfc:	77 12                	ja     800c10 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bfe:	0f be c9             	movsbl %cl,%ecx
  800c01:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c04:	39 f1                	cmp    %esi,%ecx
  800c06:	7d 0c                	jge    800c14 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c08:	42                   	inc    %edx
  800c09:	0f af c6             	imul   %esi,%eax
  800c0c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c0e:	eb c4                	jmp    800bd4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c10:	89 c1                	mov    %eax,%ecx
  800c12:	eb 02                	jmp    800c16 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c14:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1a:	74 05                	je     800c21 <strtol+0xbd>
		*endptr = (char *) s;
  800c1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c21:	85 ff                	test   %edi,%edi
  800c23:	74 04                	je     800c29 <strtol+0xc5>
  800c25:	89 c8                	mov    %ecx,%eax
  800c27:	f7 d8                	neg    %eax
}
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    
	...

00800c30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 c3                	mov    %eax,%ebx
  800c43:	89 c7                	mov    %eax,%edi
  800c45:	89 c6                	mov    %eax,%esi
  800c47:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	ba 00 00 00 00       	mov    $0x0,%edx
  800c59:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5e:	89 d1                	mov    %edx,%ecx
  800c60:	89 d3                	mov    %edx,%ebx
  800c62:	89 d7                	mov    %edx,%edi
  800c64:	89 d6                	mov    %edx,%esi
  800c66:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 cb                	mov    %ecx,%ebx
  800c85:	89 cf                	mov    %ecx,%edi
  800c87:	89 ce                	mov    %ecx,%esi
  800c89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 28                	jle    800cb7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c93:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c9a:	00 
  800c9b:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800ca2:	00 
  800ca3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800caa:	00 
  800cab:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800cb2:	e8 b1 f5 ff ff       	call   800268 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb7:	83 c4 2c             	add    $0x2c,%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccf:	89 d1                	mov    %edx,%ecx
  800cd1:	89 d3                	mov    %edx,%ebx
  800cd3:	89 d7                	mov    %edx,%edi
  800cd5:	89 d6                	mov    %edx,%esi
  800cd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_yield>:

void
sys_yield(void)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cee:	89 d1                	mov    %edx,%ecx
  800cf0:	89 d3                	mov    %edx,%ebx
  800cf2:	89 d7                	mov    %edx,%edi
  800cf4:	89 d6                	mov    %edx,%esi
  800cf6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d06:	be 00 00 00 00       	mov    $0x0,%esi
  800d0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 f7                	mov    %esi,%edi
  800d1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 28                	jle    800d49 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d25:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d2c:	00 
  800d2d:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800d34:	00 
  800d35:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3c:	00 
  800d3d:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800d44:	e8 1f f5 ff ff       	call   800268 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d49:	83 c4 2c             	add    $0x2c,%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
  800d57:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d70:	85 c0                	test   %eax,%eax
  800d72:	7e 28                	jle    800d9c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d78:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d7f:	00 
  800d80:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800d87:	00 
  800d88:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8f:	00 
  800d90:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800d97:	e8 cc f4 ff ff       	call   800268 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9c:	83 c4 2c             	add    $0x2c,%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	b8 06 00 00 00       	mov    $0x6,%eax
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 28                	jle    800def <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dcb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800dda:	00 
  800ddb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de2:	00 
  800de3:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800dea:	e8 79 f4 ff ff       	call   800268 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800def:	83 c4 2c             	add    $0x2c,%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	b8 08 00 00 00       	mov    $0x8,%eax
  800e0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7e 28                	jle    800e42 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e25:	00 
  800e26:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800e2d:	00 
  800e2e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e35:	00 
  800e36:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800e3d:	e8 26 f4 ff ff       	call   800268 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e42:	83 c4 2c             	add    $0x2c,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e58:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	89 df                	mov    %ebx,%edi
  800e65:	89 de                	mov    %ebx,%esi
  800e67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	7e 28                	jle    800e95 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e71:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e78:	00 
  800e79:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800e80:	00 
  800e81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e88:	00 
  800e89:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800e90:	e8 d3 f3 ff ff       	call   800268 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e95:	83 c4 2c             	add    $0x2c,%esp
  800e98:	5b                   	pop    %ebx
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eab:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb6:	89 df                	mov    %ebx,%edi
  800eb8:	89 de                	mov    %ebx,%esi
  800eba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	7e 28                	jle    800ee8 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ecb:	00 
  800ecc:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800ed3:	00 
  800ed4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edb:	00 
  800edc:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800ee3:	e8 80 f3 ff ff       	call   800268 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ee8:	83 c4 2c             	add    $0x2c,%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	be 00 00 00 00       	mov    $0x0,%esi
  800efb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f09:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f21:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f26:	8b 55 08             	mov    0x8(%ebp),%edx
  800f29:	89 cb                	mov    %ecx,%ebx
  800f2b:	89 cf                	mov    %ecx,%edi
  800f2d:	89 ce                	mov    %ecx,%esi
  800f2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 07 2f 80 	movl   $0x802f07,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  800f58:	e8 0b f3 ff ff       	call   800268 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5d:	83 c4 2c             	add    $0x2c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f75:	89 d1                	mov    %edx,%ecx
  800f77:	89 d3                	mov    %edx,%ebx
  800f79:	89 d7                	mov    %edx,%edi
  800f7b:	89 d6                	mov    %edx,%esi
  800f7d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8f:	b8 10 00 00 00       	mov    $0x10,%eax
  800f94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9a:	89 df                	mov    %ebx,%edi
  800f9c:	89 de                	mov    %ebx,%esi
  800f9e:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb0:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	89 df                	mov    %ebx,%edi
  800fbd:	89 de                	mov    %ebx,%esi
  800fbf:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd1:	b8 11 00 00 00       	mov    $0x11,%eax
  800fd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd9:	89 cb                	mov    %ecx,%ebx
  800fdb:	89 cf                	mov    %ecx,%edi
  800fdd:	89 ce                	mov    %ecx,%esi
  800fdf:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
	...

00800fe8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	53                   	push   %ebx
  800fec:	83 ec 24             	sub    $0x24,%esp
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ff2:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800ff4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ff8:	75 20                	jne    80101a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800ffa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ffe:	c7 44 24 08 34 2f 80 	movl   $0x802f34,0x8(%esp)
  801005:	00 
  801006:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80100d:	00 
  80100e:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  801015:	e8 4e f2 ff ff       	call   800268 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80101a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801020:	89 d8                	mov    %ebx,%eax
  801022:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801025:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102c:	f6 c4 08             	test   $0x8,%ah
  80102f:	75 1c                	jne    80104d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801031:	c7 44 24 08 64 2f 80 	movl   $0x802f64,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801040:	00 
  801041:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  801048:	e8 1b f2 ff ff       	call   800268 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80104d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801064:	e8 94 fc ff ff       	call   800cfd <sys_page_alloc>
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 20                	jns    80108d <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  80106d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801071:	c7 44 24 08 bf 2f 80 	movl   $0x802fbf,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  801088:	e8 db f1 ff ff       	call   800268 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  80108d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801094:	00 
  801095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801099:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010a0:	e8 df f9 ff ff       	call   800a84 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8010a5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010ac:	00 
  8010ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010c0:	00 
  8010c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c8:	e8 84 fc ff ff       	call   800d51 <sys_page_map>
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	79 20                	jns    8010f1 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  8010d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d5:	c7 44 24 08 d3 2f 80 	movl   $0x802fd3,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8010ec:	e8 77 f1 ff ff       	call   800268 <_panic>

}
  8010f1:	83 c4 24             	add    $0x24,%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801100:	c7 04 24 e8 0f 80 00 	movl   $0x800fe8,(%esp)
  801107:	e8 d4 16 00 00       	call   8027e0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80110c:	ba 07 00 00 00       	mov    $0x7,%edx
  801111:	89 d0                	mov    %edx,%eax
  801113:	cd 30                	int    $0x30
  801115:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801118:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  80111b:	85 c0                	test   %eax,%eax
  80111d:	79 20                	jns    80113f <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80111f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801123:	c7 44 24 08 e5 2f 80 	movl   $0x802fe5,0x8(%esp)
  80112a:	00 
  80112b:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801132:	00 
  801133:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  80113a:	e8 29 f1 ff ff       	call   800268 <_panic>
	if (child_envid == 0) { // child
  80113f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801143:	75 1c                	jne    801161 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801145:	e8 75 fb ff ff       	call   800cbf <sys_getenvid>
  80114a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80114f:	c1 e0 07             	shl    $0x7,%eax
  801152:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801157:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80115c:	e9 58 02 00 00       	jmp    8013b9 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801161:	bf 00 00 00 00       	mov    $0x0,%edi
  801166:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80116b:	89 f0                	mov    %esi,%eax
  80116d:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801170:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801177:	a8 01                	test   $0x1,%al
  801179:	0f 84 7a 01 00 00    	je     8012f9 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80117f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801186:	a8 01                	test   $0x1,%al
  801188:	0f 84 6b 01 00 00    	je     8012f9 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80118e:	a1 08 50 80 00       	mov    0x805008,%eax
  801193:	8b 40 48             	mov    0x48(%eax),%eax
  801196:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801199:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011a0:	f6 c4 04             	test   $0x4,%ah
  8011a3:	74 52                	je     8011f7 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011a5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8011b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	e8 82 fb ff ff       	call   800d51 <sys_page_map>
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	0f 89 22 01 00 00    	jns    8012f9 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8011d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011db:	c7 44 24 08 d3 2f 80 	movl   $0x802fd3,0x8(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8011f2:	e8 71 f0 ff ff       	call   800268 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8011f7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011fe:	f6 c4 08             	test   $0x8,%ah
  801201:	75 0f                	jne    801212 <fork+0x11b>
  801203:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80120a:	a8 02                	test   $0x2,%al
  80120c:	0f 84 99 00 00 00    	je     8012ab <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  801212:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801219:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  80121c:	83 f8 01             	cmp    $0x1,%eax
  80121f:	19 db                	sbb    %ebx,%ebx
  801221:	83 e3 fc             	and    $0xfffffffc,%ebx
  801224:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80122a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80122e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801235:	89 44 24 08          	mov    %eax,0x8(%esp)
  801239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80123d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801240:	89 04 24             	mov    %eax,(%esp)
  801243:	e8 09 fb ff ff       	call   800d51 <sys_page_map>
  801248:	85 c0                	test   %eax,%eax
  80124a:	79 20                	jns    80126c <fork+0x175>
			panic("sys_page_map: %e\n", r);
  80124c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801250:	c7 44 24 08 d3 2f 80 	movl   $0x802fd3,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  801267:	e8 fc ef ff ff       	call   800268 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80126c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801270:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801277:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80127f:	89 04 24             	mov    %eax,(%esp)
  801282:	e8 ca fa ff ff       	call   800d51 <sys_page_map>
  801287:	85 c0                	test   %eax,%eax
  801289:	79 6e                	jns    8012f9 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  80128b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128f:	c7 44 24 08 d3 2f 80 	movl   $0x802fd3,0x8(%esp)
  801296:	00 
  801297:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80129e:	00 
  80129f:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8012a6:	e8 bd ef ff ff       	call   800268 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8012ab:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012b2:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	e8 7c fa ff ff       	call   800d51 <sys_page_map>
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	79 20                	jns    8012f9 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8012d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012dd:	c7 44 24 08 d3 2f 80 	movl   $0x802fd3,0x8(%esp)
  8012e4:	00 
  8012e5:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8012ec:	00 
  8012ed:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8012f4:	e8 6f ef ff ff       	call   800268 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8012f9:	46                   	inc    %esi
  8012fa:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801300:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801306:	0f 85 5f fe ff ff    	jne    80116b <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80130c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80131b:	ee 
  80131c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	e8 d6 f9 ff ff       	call   800cfd <sys_page_alloc>
  801327:	85 c0                	test   %eax,%eax
  801329:	79 20                	jns    80134b <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  80132b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132f:	c7 44 24 08 bf 2f 80 	movl   $0x802fbf,0x8(%esp)
  801336:	00 
  801337:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80133e:	00 
  80133f:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  801346:	e8 1d ef ff ff       	call   800268 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  80134b:	c7 44 24 04 54 28 80 	movl   $0x802854,0x4(%esp)
  801352:	00 
  801353:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801356:	89 04 24             	mov    %eax,(%esp)
  801359:	e8 3f fb ff ff       	call   800e9d <sys_env_set_pgfault_upcall>
  80135e:	85 c0                	test   %eax,%eax
  801360:	79 20                	jns    801382 <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801362:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801366:	c7 44 24 08 94 2f 80 	movl   $0x802f94,0x8(%esp)
  80136d:	00 
  80136e:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801375:	00 
  801376:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  80137d:	e8 e6 ee ff ff       	call   800268 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801382:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801389:	00 
  80138a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 62 fa ff ff       	call   800df7 <sys_env_set_status>
  801395:	85 c0                	test   %eax,%eax
  801397:	79 20                	jns    8013b9 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801399:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139d:	c7 44 24 08 f6 2f 80 	movl   $0x802ff6,0x8(%esp)
  8013a4:	00 
  8013a5:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8013ac:	00 
  8013ad:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8013b4:	e8 af ee ff ff       	call   800268 <_panic>

	return child_envid;
}
  8013b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013bc:	83 c4 3c             	add    $0x3c,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <sfork>:

// Challenge!
int
sfork(void)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8013ca:	c7 44 24 08 0e 30 80 	movl   $0x80300e,0x8(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8013d9:	00 
  8013da:	c7 04 24 b4 2f 80 00 	movl   $0x802fb4,(%esp)
  8013e1:	e8 82 ee ff ff       	call   800268 <_panic>
	...

008013e8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 10             	sub    $0x10,%esp
  8013f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8013f9:	85 c0                	test   %eax,%eax
  8013fb:	75 05                	jne    801402 <ipc_recv+0x1a>
  8013fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801402:	89 04 24             	mov    %eax,(%esp)
  801405:	e8 09 fb ff ff       	call   800f13 <sys_ipc_recv>
	if (from_env_store != NULL)
  80140a:	85 db                	test   %ebx,%ebx
  80140c:	74 0b                	je     801419 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80140e:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801414:	8b 52 74             	mov    0x74(%edx),%edx
  801417:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  801419:	85 f6                	test   %esi,%esi
  80141b:	74 0b                	je     801428 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  80141d:	8b 15 08 50 80 00    	mov    0x805008,%edx
  801423:	8b 52 78             	mov    0x78(%edx),%edx
  801426:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  801428:	85 c0                	test   %eax,%eax
  80142a:	79 16                	jns    801442 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  80142c:	85 db                	test   %ebx,%ebx
  80142e:	74 06                	je     801436 <ipc_recv+0x4e>
			*from_env_store = 0;
  801430:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  801436:	85 f6                	test   %esi,%esi
  801438:	74 10                	je     80144a <ipc_recv+0x62>
			*perm_store = 0;
  80143a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801440:	eb 08                	jmp    80144a <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  801442:	a1 08 50 80 00       	mov    0x805008,%eax
  801447:	8b 40 70             	mov    0x70(%eax),%eax
}
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	83 ec 1c             	sub    $0x1c,%esp
  80145a:	8b 75 08             	mov    0x8(%ebp),%esi
  80145d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801460:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801463:	eb 2a                	jmp    80148f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  801465:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801468:	74 20                	je     80148a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  80146a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146e:	c7 44 24 08 24 30 80 	movl   $0x803024,0x8(%esp)
  801475:	00 
  801476:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80147d:	00 
  80147e:	c7 04 24 49 30 80 00 	movl   $0x803049,(%esp)
  801485:	e8 de ed ff ff       	call   800268 <_panic>
		sys_yield();
  80148a:	e8 4f f8 ff ff       	call   800cde <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80148f:	85 db                	test   %ebx,%ebx
  801491:	75 07                	jne    80149a <ipc_send+0x49>
  801493:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801498:	eb 02                	jmp    80149c <ipc_send+0x4b>
  80149a:	89 d8                	mov    %ebx,%eax
  80149c:	8b 55 14             	mov    0x14(%ebp),%edx
  80149f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ab:	89 34 24             	mov    %esi,(%esp)
  8014ae:	e8 3d fa ff ff       	call   800ef0 <sys_ipc_try_send>
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 ae                	js     801465 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8014b7:	83 c4 1c             	add    $0x1c,%esp
  8014ba:	5b                   	pop    %ebx
  8014bb:	5e                   	pop    %esi
  8014bc:	5f                   	pop    %edi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8014c5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	c1 e2 07             	shl    $0x7,%edx
  8014cf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8014d5:	8b 52 50             	mov    0x50(%edx),%edx
  8014d8:	39 ca                	cmp    %ecx,%edx
  8014da:	75 0d                	jne    8014e9 <ipc_find_env+0x2a>
			return envs[i].env_id;
  8014dc:	c1 e0 07             	shl    $0x7,%eax
  8014df:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014e4:	8b 40 40             	mov    0x40(%eax),%eax
  8014e7:	eb 0c                	jmp    8014f5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014e9:	40                   	inc    %eax
  8014ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014ef:	75 d9                	jne    8014ca <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014f1:	66 b8 00 00          	mov    $0x0,%ax
}
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    
	...

008014f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	05 00 00 00 30       	add    $0x30000000,%eax
  801503:	c1 e8 0c             	shr    $0xc,%eax
}
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80150e:	8b 45 08             	mov    0x8(%ebp),%eax
  801511:	89 04 24             	mov    %eax,(%esp)
  801514:	e8 df ff ff ff       	call   8014f8 <fd2num>
  801519:	05 20 00 0d 00       	add    $0xd0020,%eax
  80151e:	c1 e0 0c             	shl    $0xc,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80152a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80152f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801531:	89 c2                	mov    %eax,%edx
  801533:	c1 ea 16             	shr    $0x16,%edx
  801536:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80153d:	f6 c2 01             	test   $0x1,%dl
  801540:	74 11                	je     801553 <fd_alloc+0x30>
  801542:	89 c2                	mov    %eax,%edx
  801544:	c1 ea 0c             	shr    $0xc,%edx
  801547:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154e:	f6 c2 01             	test   $0x1,%dl
  801551:	75 09                	jne    80155c <fd_alloc+0x39>
			*fd_store = fd;
  801553:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801555:	b8 00 00 00 00       	mov    $0x0,%eax
  80155a:	eb 17                	jmp    801573 <fd_alloc+0x50>
  80155c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801561:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801566:	75 c7                	jne    80152f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801568:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80156e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801573:	5b                   	pop    %ebx
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80157c:	83 f8 1f             	cmp    $0x1f,%eax
  80157f:	77 36                	ja     8015b7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801581:	05 00 00 0d 00       	add    $0xd0000,%eax
  801586:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801589:	89 c2                	mov    %eax,%edx
  80158b:	c1 ea 16             	shr    $0x16,%edx
  80158e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801595:	f6 c2 01             	test   $0x1,%dl
  801598:	74 24                	je     8015be <fd_lookup+0x48>
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	c1 ea 0c             	shr    $0xc,%edx
  80159f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a6:	f6 c2 01             	test   $0x1,%dl
  8015a9:	74 1a                	je     8015c5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8015b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b5:	eb 13                	jmp    8015ca <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bc:	eb 0c                	jmp    8015ca <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c3:	eb 05                	jmp    8015ca <fd_lookup+0x54>
  8015c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015ca:	5d                   	pop    %ebp
  8015cb:	c3                   	ret    

008015cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	53                   	push   %ebx
  8015d0:	83 ec 14             	sub    $0x14,%esp
  8015d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015de:	eb 0e                	jmp    8015ee <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015e0:	39 08                	cmp    %ecx,(%eax)
  8015e2:	75 09                	jne    8015ed <dev_lookup+0x21>
			*dev = devtab[i];
  8015e4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015eb:	eb 33                	jmp    801620 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015ed:	42                   	inc    %edx
  8015ee:	8b 04 95 d4 30 80 00 	mov    0x8030d4(,%edx,4),%eax
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	75 e7                	jne    8015e0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015f9:	a1 08 50 80 00       	mov    0x805008,%eax
  8015fe:	8b 40 48             	mov    0x48(%eax),%eax
  801601:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801605:	89 44 24 04          	mov    %eax,0x4(%esp)
  801609:	c7 04 24 54 30 80 00 	movl   $0x803054,(%esp)
  801610:	e8 4b ed ff ff       	call   800360 <cprintf>
	*dev = 0;
  801615:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80161b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801620:	83 c4 14             	add    $0x14,%esp
  801623:	5b                   	pop    %ebx
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
  80162b:	83 ec 30             	sub    $0x30,%esp
  80162e:	8b 75 08             	mov    0x8(%ebp),%esi
  801631:	8a 45 0c             	mov    0xc(%ebp),%al
  801634:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801637:	89 34 24             	mov    %esi,(%esp)
  80163a:	e8 b9 fe ff ff       	call   8014f8 <fd2num>
  80163f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801642:	89 54 24 04          	mov    %edx,0x4(%esp)
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 28 ff ff ff       	call   801576 <fd_lookup>
  80164e:	89 c3                	mov    %eax,%ebx
  801650:	85 c0                	test   %eax,%eax
  801652:	78 05                	js     801659 <fd_close+0x33>
	    || fd != fd2)
  801654:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801657:	74 0d                	je     801666 <fd_close+0x40>
		return (must_exist ? r : 0);
  801659:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80165d:	75 46                	jne    8016a5 <fd_close+0x7f>
  80165f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801664:	eb 3f                	jmp    8016a5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801666:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166d:	8b 06                	mov    (%esi),%eax
  80166f:	89 04 24             	mov    %eax,(%esp)
  801672:	e8 55 ff ff ff       	call   8015cc <dev_lookup>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 18                	js     801695 <fd_close+0x6f>
		if (dev->dev_close)
  80167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801680:	8b 40 10             	mov    0x10(%eax),%eax
  801683:	85 c0                	test   %eax,%eax
  801685:	74 09                	je     801690 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801687:	89 34 24             	mov    %esi,(%esp)
  80168a:	ff d0                	call   *%eax
  80168c:	89 c3                	mov    %eax,%ebx
  80168e:	eb 05                	jmp    801695 <fd_close+0x6f>
		else
			r = 0;
  801690:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801695:	89 74 24 04          	mov    %esi,0x4(%esp)
  801699:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a0:	e8 ff f6 ff ff       	call   800da4 <sys_page_unmap>
	return r;
}
  8016a5:	89 d8                	mov    %ebx,%eax
  8016a7:	83 c4 30             	add    $0x30,%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016be:	89 04 24             	mov    %eax,(%esp)
  8016c1:	e8 b0 fe ff ff       	call   801576 <fd_lookup>
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	78 13                	js     8016dd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016d1:	00 
  8016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	e8 49 ff ff ff       	call   801626 <fd_close>
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <close_all>:

void
close_all(void)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016eb:	89 1c 24             	mov    %ebx,(%esp)
  8016ee:	e8 bb ff ff ff       	call   8016ae <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016f3:	43                   	inc    %ebx
  8016f4:	83 fb 20             	cmp    $0x20,%ebx
  8016f7:	75 f2                	jne    8016eb <close_all+0xc>
		close(i);
}
  8016f9:	83 c4 14             	add    $0x14,%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	57                   	push   %edi
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 4c             	sub    $0x4c,%esp
  801708:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80170b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80170e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	89 04 24             	mov    %eax,(%esp)
  801718:	e8 59 fe ff ff       	call   801576 <fd_lookup>
  80171d:	89 c3                	mov    %eax,%ebx
  80171f:	85 c0                	test   %eax,%eax
  801721:	0f 88 e1 00 00 00    	js     801808 <dup+0x109>
		return r;
	close(newfdnum);
  801727:	89 3c 24             	mov    %edi,(%esp)
  80172a:	e8 7f ff ff ff       	call   8016ae <close>

	newfd = INDEX2FD(newfdnum);
  80172f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801735:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801738:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 c5 fd ff ff       	call   801508 <fd2data>
  801743:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801745:	89 34 24             	mov    %esi,(%esp)
  801748:	e8 bb fd ff ff       	call   801508 <fd2data>
  80174d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801750:	89 d8                	mov    %ebx,%eax
  801752:	c1 e8 16             	shr    $0x16,%eax
  801755:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80175c:	a8 01                	test   $0x1,%al
  80175e:	74 46                	je     8017a6 <dup+0xa7>
  801760:	89 d8                	mov    %ebx,%eax
  801762:	c1 e8 0c             	shr    $0xc,%eax
  801765:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80176c:	f6 c2 01             	test   $0x1,%dl
  80176f:	74 35                	je     8017a6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801771:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801778:	25 07 0e 00 00       	and    $0xe07,%eax
  80177d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801781:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801784:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801788:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178f:	00 
  801790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179b:	e8 b1 f5 ff ff       	call   800d51 <sys_page_map>
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 3b                	js     8017e1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a9:	89 c2                	mov    %eax,%edx
  8017ab:	c1 ea 0c             	shr    $0xc,%edx
  8017ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017b5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ca:	00 
  8017cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d6:	e8 76 f5 ff ff       	call   800d51 <sys_page_map>
  8017db:	89 c3                	mov    %eax,%ebx
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	79 25                	jns    801806 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ec:	e8 b3 f5 ff ff       	call   800da4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ff:	e8 a0 f5 ff ff       	call   800da4 <sys_page_unmap>
	return r;
  801804:	eb 02                	jmp    801808 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801806:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801808:	89 d8                	mov    %ebx,%eax
  80180a:	83 c4 4c             	add    $0x4c,%esp
  80180d:	5b                   	pop    %ebx
  80180e:	5e                   	pop    %esi
  80180f:	5f                   	pop    %edi
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	53                   	push   %ebx
  801816:	83 ec 24             	sub    $0x24,%esp
  801819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	89 1c 24             	mov    %ebx,(%esp)
  801826:	e8 4b fd ff ff       	call   801576 <fd_lookup>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 6d                	js     80189c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	8b 00                	mov    (%eax),%eax
  80183b:	89 04 24             	mov    %eax,(%esp)
  80183e:	e8 89 fd ff ff       	call   8015cc <dev_lookup>
  801843:	85 c0                	test   %eax,%eax
  801845:	78 55                	js     80189c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	8b 50 08             	mov    0x8(%eax),%edx
  80184d:	83 e2 03             	and    $0x3,%edx
  801850:	83 fa 01             	cmp    $0x1,%edx
  801853:	75 23                	jne    801878 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801855:	a1 08 50 80 00       	mov    0x805008,%eax
  80185a:	8b 40 48             	mov    0x48(%eax),%eax
  80185d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801861:	89 44 24 04          	mov    %eax,0x4(%esp)
  801865:	c7 04 24 98 30 80 00 	movl   $0x803098,(%esp)
  80186c:	e8 ef ea ff ff       	call   800360 <cprintf>
		return -E_INVAL;
  801871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801876:	eb 24                	jmp    80189c <read+0x8a>
	}
	if (!dev->dev_read)
  801878:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187b:	8b 52 08             	mov    0x8(%edx),%edx
  80187e:	85 d2                	test   %edx,%edx
  801880:	74 15                	je     801897 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801882:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801885:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801889:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80188c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801890:	89 04 24             	mov    %eax,(%esp)
  801893:	ff d2                	call   *%edx
  801895:	eb 05                	jmp    80189c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801897:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80189c:	83 c4 24             	add    $0x24,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	57                   	push   %edi
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 1c             	sub    $0x1c,%esp
  8018ab:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b6:	eb 23                	jmp    8018db <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b8:	89 f0                	mov    %esi,%eax
  8018ba:	29 d8                	sub    %ebx,%eax
  8018bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c3:	01 d8                	add    %ebx,%eax
  8018c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c9:	89 3c 24             	mov    %edi,(%esp)
  8018cc:	e8 41 ff ff ff       	call   801812 <read>
		if (m < 0)
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 10                	js     8018e5 <readn+0x43>
			return m;
		if (m == 0)
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	74 0a                	je     8018e3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d9:	01 c3                	add    %eax,%ebx
  8018db:	39 f3                	cmp    %esi,%ebx
  8018dd:	72 d9                	jb     8018b8 <readn+0x16>
  8018df:	89 d8                	mov    %ebx,%eax
  8018e1:	eb 02                	jmp    8018e5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018e3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018e5:	83 c4 1c             	add    $0x1c,%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5f                   	pop    %edi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	53                   	push   %ebx
  8018f1:	83 ec 24             	sub    $0x24,%esp
  8018f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fe:	89 1c 24             	mov    %ebx,(%esp)
  801901:	e8 70 fc ff ff       	call   801576 <fd_lookup>
  801906:	85 c0                	test   %eax,%eax
  801908:	78 68                	js     801972 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80190a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801911:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801914:	8b 00                	mov    (%eax),%eax
  801916:	89 04 24             	mov    %eax,(%esp)
  801919:	e8 ae fc ff ff       	call   8015cc <dev_lookup>
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 50                	js     801972 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801922:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801925:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801929:	75 23                	jne    80194e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80192b:	a1 08 50 80 00       	mov    0x805008,%eax
  801930:	8b 40 48             	mov    0x48(%eax),%eax
  801933:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193b:	c7 04 24 b4 30 80 00 	movl   $0x8030b4,(%esp)
  801942:	e8 19 ea ff ff       	call   800360 <cprintf>
		return -E_INVAL;
  801947:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80194c:	eb 24                	jmp    801972 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80194e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801951:	8b 52 0c             	mov    0xc(%edx),%edx
  801954:	85 d2                	test   %edx,%edx
  801956:	74 15                	je     80196d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801958:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80195b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80195f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801962:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801966:	89 04 24             	mov    %eax,(%esp)
  801969:	ff d2                	call   *%edx
  80196b:	eb 05                	jmp    801972 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80196d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801972:	83 c4 24             	add    $0x24,%esp
  801975:	5b                   	pop    %ebx
  801976:	5d                   	pop    %ebp
  801977:	c3                   	ret    

00801978 <seek>:

int
seek(int fdnum, off_t offset)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801981:	89 44 24 04          	mov    %eax,0x4(%esp)
  801985:	8b 45 08             	mov    0x8(%ebp),%eax
  801988:	89 04 24             	mov    %eax,(%esp)
  80198b:	e8 e6 fb ff ff       	call   801576 <fd_lookup>
  801990:	85 c0                	test   %eax,%eax
  801992:	78 0e                	js     8019a2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801994:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80199a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80199d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	53                   	push   %ebx
  8019a8:	83 ec 24             	sub    $0x24,%esp
  8019ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b5:	89 1c 24             	mov    %ebx,(%esp)
  8019b8:	e8 b9 fb ff ff       	call   801576 <fd_lookup>
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 61                	js     801a22 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cb:	8b 00                	mov    (%eax),%eax
  8019cd:	89 04 24             	mov    %eax,(%esp)
  8019d0:	e8 f7 fb ff ff       	call   8015cc <dev_lookup>
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 49                	js     801a22 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019e0:	75 23                	jne    801a05 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019e2:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019e7:	8b 40 48             	mov    0x48(%eax),%eax
  8019ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f2:	c7 04 24 74 30 80 00 	movl   $0x803074,(%esp)
  8019f9:	e8 62 e9 ff ff       	call   800360 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a03:	eb 1d                	jmp    801a22 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a08:	8b 52 18             	mov    0x18(%edx),%edx
  801a0b:	85 d2                	test   %edx,%edx
  801a0d:	74 0e                	je     801a1d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a16:	89 04 24             	mov    %eax,(%esp)
  801a19:	ff d2                	call   *%edx
  801a1b:	eb 05                	jmp    801a22 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a1d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a22:	83 c4 24             	add    $0x24,%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	53                   	push   %ebx
  801a2c:	83 ec 24             	sub    $0x24,%esp
  801a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a39:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	e8 32 fb ff ff       	call   801576 <fd_lookup>
  801a44:	85 c0                	test   %eax,%eax
  801a46:	78 52                	js     801a9a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a52:	8b 00                	mov    (%eax),%eax
  801a54:	89 04 24             	mov    %eax,(%esp)
  801a57:	e8 70 fb ff ff       	call   8015cc <dev_lookup>
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 3a                	js     801a9a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a63:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a67:	74 2c                	je     801a95 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a69:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a6c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a73:	00 00 00 
	stat->st_isdir = 0;
  801a76:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a7d:	00 00 00 
	stat->st_dev = dev;
  801a80:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a8d:	89 14 24             	mov    %edx,(%esp)
  801a90:	ff 50 14             	call   *0x14(%eax)
  801a93:	eb 05                	jmp    801a9a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a9a:	83 c4 24             	add    $0x24,%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801aa8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aaf:	00 
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	89 04 24             	mov    %eax,(%esp)
  801ab6:	e8 2d 02 00 00       	call   801ce8 <open>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 1b                	js     801adc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801ac1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac8:	89 1c 24             	mov    %ebx,(%esp)
  801acb:	e8 58 ff ff ff       	call   801a28 <fstat>
  801ad0:	89 c6                	mov    %eax,%esi
	close(fd);
  801ad2:	89 1c 24             	mov    %ebx,(%esp)
  801ad5:	e8 d4 fb ff ff       	call   8016ae <close>
	return r;
  801ada:	89 f3                	mov    %esi,%ebx
}
  801adc:	89 d8                	mov    %ebx,%eax
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    
  801ae5:	00 00                	add    %al,(%eax)
	...

00801ae8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	83 ec 10             	sub    $0x10,%esp
  801af0:	89 c3                	mov    %eax,%ebx
  801af2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801af4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801afb:	75 11                	jne    801b0e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801afd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b04:	e8 b6 f9 ff ff       	call   8014bf <ipc_find_env>
  801b09:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b0e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b15:	00 
  801b16:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b1d:	00 
  801b1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b22:	a1 00 50 80 00       	mov    0x805000,%eax
  801b27:	89 04 24             	mov    %eax,(%esp)
  801b2a:	e8 22 f9 ff ff       	call   801451 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b36:	00 
  801b37:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b42:	e8 a1 f8 ff ff       	call   8013e8 <ipc_recv>
}
  801b47:	83 c4 10             	add    $0x10,%esp
  801b4a:	5b                   	pop    %ebx
  801b4b:	5e                   	pop    %esi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b62:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b67:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6c:	b8 02 00 00 00       	mov    $0x2,%eax
  801b71:	e8 72 ff ff ff       	call   801ae8 <fsipc>
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	8b 40 0c             	mov    0xc(%eax),%eax
  801b84:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b89:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  801b93:	e8 50 ff ff ff       	call   801ae8 <fsipc>
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 14             	sub    $0x14,%esp
  801ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	8b 40 0c             	mov    0xc(%eax),%eax
  801baa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801baf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb4:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb9:	e8 2a ff ff ff       	call   801ae8 <fsipc>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 2b                	js     801bed <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bc2:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bc9:	00 
  801bca:	89 1c 24             	mov    %ebx,(%esp)
  801bcd:	e8 39 ed ff ff       	call   80090b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bd2:	a1 80 60 80 00       	mov    0x806080,%eax
  801bd7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bdd:	a1 84 60 80 00       	mov    0x806084,%eax
  801be2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bed:	83 c4 14             	add    $0x14,%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 18             	sub    $0x18,%esp
  801bf9:	8b 55 10             	mov    0x10(%ebp),%edx
  801bfc:	89 d0                	mov    %edx,%eax
  801bfe:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801c04:	76 05                	jbe    801c0b <devfile_write+0x18>
  801c06:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  801c0e:	8b 52 0c             	mov    0xc(%edx),%edx
  801c11:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801c17:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801c1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c27:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c2e:	e8 51 ee ff ff       	call   800a84 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801c33:	ba 00 00 00 00       	mov    $0x0,%edx
  801c38:	b8 04 00 00 00       	mov    $0x4,%eax
  801c3d:	e8 a6 fe ff ff       	call   801ae8 <fsipc>
}
  801c42:	c9                   	leave  
  801c43:	c3                   	ret    

00801c44 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	56                   	push   %esi
  801c48:	53                   	push   %ebx
  801c49:	83 ec 10             	sub    $0x10,%esp
  801c4c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c52:	8b 40 0c             	mov    0xc(%eax),%eax
  801c55:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c5a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c60:	ba 00 00 00 00       	mov    $0x0,%edx
  801c65:	b8 03 00 00 00       	mov    $0x3,%eax
  801c6a:	e8 79 fe ff ff       	call   801ae8 <fsipc>
  801c6f:	89 c3                	mov    %eax,%ebx
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 6a                	js     801cdf <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c75:	39 c6                	cmp    %eax,%esi
  801c77:	73 24                	jae    801c9d <devfile_read+0x59>
  801c79:	c7 44 24 0c e8 30 80 	movl   $0x8030e8,0xc(%esp)
  801c80:	00 
  801c81:	c7 44 24 08 ef 30 80 	movl   $0x8030ef,0x8(%esp)
  801c88:	00 
  801c89:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c90:	00 
  801c91:	c7 04 24 04 31 80 00 	movl   $0x803104,(%esp)
  801c98:	e8 cb e5 ff ff       	call   800268 <_panic>
	assert(r <= PGSIZE);
  801c9d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ca2:	7e 24                	jle    801cc8 <devfile_read+0x84>
  801ca4:	c7 44 24 0c 0f 31 80 	movl   $0x80310f,0xc(%esp)
  801cab:	00 
  801cac:	c7 44 24 08 ef 30 80 	movl   $0x8030ef,0x8(%esp)
  801cb3:	00 
  801cb4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801cbb:	00 
  801cbc:	c7 04 24 04 31 80 00 	movl   $0x803104,(%esp)
  801cc3:	e8 a0 e5 ff ff       	call   800268 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ccc:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cd3:	00 
  801cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd7:	89 04 24             	mov    %eax,(%esp)
  801cda:	e8 a5 ed ff ff       	call   800a84 <memmove>
	return r;
}
  801cdf:	89 d8                	mov    %ebx,%eax
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	56                   	push   %esi
  801cec:	53                   	push   %ebx
  801ced:	83 ec 20             	sub    $0x20,%esp
  801cf0:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cf3:	89 34 24             	mov    %esi,(%esp)
  801cf6:	e8 dd eb ff ff       	call   8008d8 <strlen>
  801cfb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d00:	7f 60                	jg     801d62 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 16 f8 ff ff       	call   801523 <fd_alloc>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 54                	js     801d67 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d13:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d17:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d1e:	e8 e8 eb ff ff       	call   80090b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d26:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d2e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d33:	e8 b0 fd ff ff       	call   801ae8 <fsipc>
  801d38:	89 c3                	mov    %eax,%ebx
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	79 15                	jns    801d53 <open+0x6b>
		fd_close(fd, 0);
  801d3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d45:	00 
  801d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d49:	89 04 24             	mov    %eax,(%esp)
  801d4c:	e8 d5 f8 ff ff       	call   801626 <fd_close>
		return r;
  801d51:	eb 14                	jmp    801d67 <open+0x7f>
	}

	return fd2num(fd);
  801d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d56:	89 04 24             	mov    %eax,(%esp)
  801d59:	e8 9a f7 ff ff       	call   8014f8 <fd2num>
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	eb 05                	jmp    801d67 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d62:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d67:	89 d8                	mov    %ebx,%eax
  801d69:	83 c4 20             	add    $0x20,%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d76:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  801d80:	e8 63 fd ff ff       	call   801ae8 <fsipc>
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    
	...

00801d88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d8e:	89 c2                	mov    %eax,%edx
  801d90:	c1 ea 16             	shr    $0x16,%edx
  801d93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d9a:	f6 c2 01             	test   $0x1,%dl
  801d9d:	74 1e                	je     801dbd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d9f:	c1 e8 0c             	shr    $0xc,%eax
  801da2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801da9:	a8 01                	test   $0x1,%al
  801dab:	74 17                	je     801dc4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dad:	c1 e8 0c             	shr    $0xc,%eax
  801db0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801db7:	ef 
  801db8:	0f b7 c0             	movzwl %ax,%eax
  801dbb:	eb 0c                	jmp    801dc9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc2:	eb 05                	jmp    801dc9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
	...

00801dcc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801dd2:	c7 44 24 04 1b 31 80 	movl   $0x80311b,0x4(%esp)
  801dd9:	00 
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	89 04 24             	mov    %eax,(%esp)
  801de0:	e8 26 eb ff ff       	call   80090b <strcpy>
	return 0;
}
  801de5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	53                   	push   %ebx
  801df0:	83 ec 14             	sub    $0x14,%esp
  801df3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801df6:	89 1c 24             	mov    %ebx,(%esp)
  801df9:	e8 8a ff ff ff       	call   801d88 <pageref>
  801dfe:	83 f8 01             	cmp    $0x1,%eax
  801e01:	75 0d                	jne    801e10 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801e03:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e06:	89 04 24             	mov    %eax,(%esp)
  801e09:	e8 1f 03 00 00       	call   80212d <nsipc_close>
  801e0e:	eb 05                	jmp    801e15 <devsock_close+0x29>
	else
		return 0;
  801e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e15:	83 c4 14             	add    $0x14,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e28:	00 
  801e29:	8b 45 10             	mov    0x10(%ebp),%eax
  801e2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e3d:	89 04 24             	mov    %eax,(%esp)
  801e40:	e8 e3 03 00 00       	call   802228 <nsipc_send>
}
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e4d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e54:	00 
  801e55:	8b 45 10             	mov    0x10(%ebp),%eax
  801e58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	8b 40 0c             	mov    0xc(%eax),%eax
  801e69:	89 04 24             	mov    %eax,(%esp)
  801e6c:	e8 37 03 00 00       	call   8021a8 <nsipc_recv>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	83 ec 20             	sub    $0x20,%esp
  801e7b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e80:	89 04 24             	mov    %eax,(%esp)
  801e83:	e8 9b f6 ff ff       	call   801523 <fd_alloc>
  801e88:	89 c3                	mov    %eax,%ebx
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	78 21                	js     801eaf <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e8e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e95:	00 
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea4:	e8 54 ee ff ff       	call   800cfd <sys_page_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	85 c0                	test   %eax,%eax
  801ead:	79 0a                	jns    801eb9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801eaf:	89 34 24             	mov    %esi,(%esp)
  801eb2:	e8 76 02 00 00       	call   80212d <nsipc_close>
		return r;
  801eb7:	eb 22                	jmp    801edb <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eb9:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ece:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 1f f6 ff ff       	call   8014f8 <fd2num>
  801ed9:	89 c3                	mov    %eax,%ebx
}
  801edb:	89 d8                	mov    %ebx,%eax
  801edd:	83 c4 20             	add    $0x20,%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801eea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801eed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef1:	89 04 24             	mov    %eax,(%esp)
  801ef4:	e8 7d f6 ff ff       	call   801576 <fd_lookup>
  801ef9:	85 c0                	test   %eax,%eax
  801efb:	78 17                	js     801f14 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f00:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f06:	39 10                	cmp    %edx,(%eax)
  801f08:	75 05                	jne    801f0f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f0d:	eb 05                	jmp    801f14 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f0f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1f:	e8 c0 ff ff ff       	call   801ee4 <fd2sockid>
  801f24:	85 c0                	test   %eax,%eax
  801f26:	78 1f                	js     801f47 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f28:	8b 55 10             	mov    0x10(%ebp),%edx
  801f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f32:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f36:	89 04 24             	mov    %eax,(%esp)
  801f39:	e8 38 01 00 00       	call   802076 <nsipc_accept>
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 05                	js     801f47 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801f42:	e8 2c ff ff ff       	call   801e73 <alloc_sockfd>
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f52:	e8 8d ff ff ff       	call   801ee4 <fd2sockid>
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 16                	js     801f71 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801f5b:	8b 55 10             	mov    0x10(%ebp),%edx
  801f5e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f69:	89 04 24             	mov    %eax,(%esp)
  801f6c:	e8 5b 01 00 00       	call   8020cc <nsipc_bind>
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <shutdown>:

int
shutdown(int s, int how)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f79:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7c:	e8 63 ff ff ff       	call   801ee4 <fd2sockid>
  801f81:	85 c0                	test   %eax,%eax
  801f83:	78 0f                	js     801f94 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f88:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f8c:	89 04 24             	mov    %eax,(%esp)
  801f8f:	e8 77 01 00 00       	call   80210b <nsipc_shutdown>
}
  801f94:	c9                   	leave  
  801f95:	c3                   	ret    

00801f96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f96:	55                   	push   %ebp
  801f97:	89 e5                	mov    %esp,%ebp
  801f99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9f:	e8 40 ff ff ff       	call   801ee4 <fd2sockid>
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	78 16                	js     801fbe <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801fa8:	8b 55 10             	mov    0x10(%ebp),%edx
  801fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  801faf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb6:	89 04 24             	mov    %eax,(%esp)
  801fb9:	e8 89 01 00 00       	call   802147 <nsipc_connect>
}
  801fbe:	c9                   	leave  
  801fbf:	c3                   	ret    

00801fc0 <listen>:

int
listen(int s, int backlog)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc9:	e8 16 ff ff ff       	call   801ee4 <fd2sockid>
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 0f                	js     801fe1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fd9:	89 04 24             	mov    %eax,(%esp)
  801fdc:	e8 a5 01 00 00       	call   802186 <nsipc_listen>
}
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fe9:	8b 45 10             	mov    0x10(%ebp),%eax
  801fec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffa:	89 04 24             	mov    %eax,(%esp)
  801ffd:	e8 99 02 00 00       	call   80229b <nsipc_socket>
  802002:	85 c0                	test   %eax,%eax
  802004:	78 05                	js     80200b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802006:	e8 68 fe ff ff       	call   801e73 <alloc_sockfd>
}
  80200b:	c9                   	leave  
  80200c:	c3                   	ret    
  80200d:	00 00                	add    %al,(%eax)
	...

00802010 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	53                   	push   %ebx
  802014:	83 ec 14             	sub    $0x14,%esp
  802017:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802019:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802020:	75 11                	jne    802033 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802022:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802029:	e8 91 f4 ff ff       	call   8014bf <ipc_find_env>
  80202e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802033:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80203a:	00 
  80203b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802042:	00 
  802043:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802047:	a1 04 50 80 00       	mov    0x805004,%eax
  80204c:	89 04 24             	mov    %eax,(%esp)
  80204f:	e8 fd f3 ff ff       	call   801451 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802054:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80205b:	00 
  80205c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802063:	00 
  802064:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80206b:	e8 78 f3 ff ff       	call   8013e8 <ipc_recv>
}
  802070:	83 c4 14             	add    $0x14,%esp
  802073:	5b                   	pop    %ebx
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    

00802076 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
  80207b:	83 ec 10             	sub    $0x10,%esp
  80207e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802081:	8b 45 08             	mov    0x8(%ebp),%eax
  802084:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802089:	8b 06                	mov    (%esi),%eax
  80208b:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802090:	b8 01 00 00 00       	mov    $0x1,%eax
  802095:	e8 76 ff ff ff       	call   802010 <nsipc>
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 23                	js     8020c3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8020a0:	a1 10 70 80 00       	mov    0x807010,%eax
  8020a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020a9:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8020b0:	00 
  8020b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b4:	89 04 24             	mov    %eax,(%esp)
  8020b7:	e8 c8 e9 ff ff       	call   800a84 <memmove>
		*addrlen = ret->ret_addrlen;
  8020bc:	a1 10 70 80 00       	mov    0x807010,%eax
  8020c1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8020c3:	89 d8                	mov    %ebx,%eax
  8020c5:	83 c4 10             	add    $0x10,%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5e                   	pop    %esi
  8020ca:	5d                   	pop    %ebp
  8020cb:	c3                   	ret    

008020cc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	53                   	push   %ebx
  8020d0:	83 ec 14             	sub    $0x14,%esp
  8020d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8020d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8020de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e9:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020f0:	e8 8f e9 ff ff       	call   800a84 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8020f5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8020fb:	b8 02 00 00 00       	mov    $0x2,%eax
  802100:	e8 0b ff ff ff       	call   802010 <nsipc>
}
  802105:	83 c4 14             	add    $0x14,%esp
  802108:	5b                   	pop    %ebx
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    

0080210b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802111:	8b 45 08             	mov    0x8(%ebp),%eax
  802114:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802121:	b8 03 00 00 00       	mov    $0x3,%eax
  802126:	e8 e5 fe ff ff       	call   802010 <nsipc>
}
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    

0080212d <nsipc_close>:

int
nsipc_close(int s)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802133:	8b 45 08             	mov    0x8(%ebp),%eax
  802136:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80213b:	b8 04 00 00 00       	mov    $0x4,%eax
  802140:	e8 cb fe ff ff       	call   802010 <nsipc>
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	53                   	push   %ebx
  80214b:	83 ec 14             	sub    $0x14,%esp
  80214e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802151:	8b 45 08             	mov    0x8(%ebp),%eax
  802154:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80215d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802160:	89 44 24 04          	mov    %eax,0x4(%esp)
  802164:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80216b:	e8 14 e9 ff ff       	call   800a84 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802170:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802176:	b8 05 00 00 00       	mov    $0x5,%eax
  80217b:	e8 90 fe ff ff       	call   802010 <nsipc>
}
  802180:	83 c4 14             	add    $0x14,%esp
  802183:	5b                   	pop    %ebx
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80218c:	8b 45 08             	mov    0x8(%ebp),%eax
  80218f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802194:	8b 45 0c             	mov    0xc(%ebp),%eax
  802197:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80219c:	b8 06 00 00 00       	mov    $0x6,%eax
  8021a1:	e8 6a fe ff ff       	call   802010 <nsipc>
}
  8021a6:	c9                   	leave  
  8021a7:	c3                   	ret    

008021a8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	56                   	push   %esi
  8021ac:	53                   	push   %ebx
  8021ad:	83 ec 10             	sub    $0x10,%esp
  8021b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8021bb:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8021c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c4:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021c9:	b8 07 00 00 00       	mov    $0x7,%eax
  8021ce:	e8 3d fe ff ff       	call   802010 <nsipc>
  8021d3:	89 c3                	mov    %eax,%ebx
  8021d5:	85 c0                	test   %eax,%eax
  8021d7:	78 46                	js     80221f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8021d9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021de:	7f 04                	jg     8021e4 <nsipc_recv+0x3c>
  8021e0:	39 c6                	cmp    %eax,%esi
  8021e2:	7d 24                	jge    802208 <nsipc_recv+0x60>
  8021e4:	c7 44 24 0c 27 31 80 	movl   $0x803127,0xc(%esp)
  8021eb:	00 
  8021ec:	c7 44 24 08 ef 30 80 	movl   $0x8030ef,0x8(%esp)
  8021f3:	00 
  8021f4:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8021fb:	00 
  8021fc:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  802203:	e8 60 e0 ff ff       	call   800268 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802208:	89 44 24 08          	mov    %eax,0x8(%esp)
  80220c:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802213:	00 
  802214:	8b 45 0c             	mov    0xc(%ebp),%eax
  802217:	89 04 24             	mov    %eax,(%esp)
  80221a:	e8 65 e8 ff ff       	call   800a84 <memmove>
	}

	return r;
}
  80221f:	89 d8                	mov    %ebx,%eax
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    

00802228 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	53                   	push   %ebx
  80222c:	83 ec 14             	sub    $0x14,%esp
  80222f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802232:	8b 45 08             	mov    0x8(%ebp),%eax
  802235:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80223a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802240:	7e 24                	jle    802266 <nsipc_send+0x3e>
  802242:	c7 44 24 0c 48 31 80 	movl   $0x803148,0xc(%esp)
  802249:	00 
  80224a:	c7 44 24 08 ef 30 80 	movl   $0x8030ef,0x8(%esp)
  802251:	00 
  802252:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802259:	00 
  80225a:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  802261:	e8 02 e0 ff ff       	call   800268 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802266:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80226a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802271:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802278:	e8 07 e8 ff ff       	call   800a84 <memmove>
	nsipcbuf.send.req_size = size;
  80227d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802283:	8b 45 14             	mov    0x14(%ebp),%eax
  802286:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80228b:	b8 08 00 00 00       	mov    $0x8,%eax
  802290:	e8 7b fd ff ff       	call   802010 <nsipc>
}
  802295:	83 c4 14             	add    $0x14,%esp
  802298:	5b                   	pop    %ebx
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    

0080229b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8022a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ac:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8022b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8022b4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8022b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8022be:	e8 4d fd ff ff       	call   802010 <nsipc>
}
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    
  8022c5:	00 00                	add    %al,(%eax)
	...

008022c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	56                   	push   %esi
  8022cc:	53                   	push   %ebx
  8022cd:	83 ec 10             	sub    $0x10,%esp
  8022d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8022d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8022d6:	89 04 24             	mov    %eax,(%esp)
  8022d9:	e8 2a f2 ff ff       	call   801508 <fd2data>
  8022de:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8022e0:	c7 44 24 04 54 31 80 	movl   $0x803154,0x4(%esp)
  8022e7:	00 
  8022e8:	89 34 24             	mov    %esi,(%esp)
  8022eb:	e8 1b e6 ff ff       	call   80090b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8022f3:	2b 03                	sub    (%ebx),%eax
  8022f5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8022fb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802302:	00 00 00 
	stat->st_dev = &devpipe;
  802305:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  80230c:	40 80 00 
	return 0;
}
  80230f:	b8 00 00 00 00       	mov    $0x0,%eax
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	5b                   	pop    %ebx
  802318:	5e                   	pop    %esi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    

0080231b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	53                   	push   %ebx
  80231f:	83 ec 14             	sub    $0x14,%esp
  802322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802325:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802329:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802330:	e8 6f ea ff ff       	call   800da4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802335:	89 1c 24             	mov    %ebx,(%esp)
  802338:	e8 cb f1 ff ff       	call   801508 <fd2data>
  80233d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802341:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802348:	e8 57 ea ff ff       	call   800da4 <sys_page_unmap>
}
  80234d:	83 c4 14             	add    $0x14,%esp
  802350:	5b                   	pop    %ebx
  802351:	5d                   	pop    %ebp
  802352:	c3                   	ret    

00802353 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802353:	55                   	push   %ebp
  802354:	89 e5                	mov    %esp,%ebp
  802356:	57                   	push   %edi
  802357:	56                   	push   %esi
  802358:	53                   	push   %ebx
  802359:	83 ec 2c             	sub    $0x2c,%esp
  80235c:	89 c7                	mov    %eax,%edi
  80235e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802361:	a1 08 50 80 00       	mov    0x805008,%eax
  802366:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802369:	89 3c 24             	mov    %edi,(%esp)
  80236c:	e8 17 fa ff ff       	call   801d88 <pageref>
  802371:	89 c6                	mov    %eax,%esi
  802373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802376:	89 04 24             	mov    %eax,(%esp)
  802379:	e8 0a fa ff ff       	call   801d88 <pageref>
  80237e:	39 c6                	cmp    %eax,%esi
  802380:	0f 94 c0             	sete   %al
  802383:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802386:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80238c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80238f:	39 cb                	cmp    %ecx,%ebx
  802391:	75 08                	jne    80239b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802393:	83 c4 2c             	add    $0x2c,%esp
  802396:	5b                   	pop    %ebx
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80239b:	83 f8 01             	cmp    $0x1,%eax
  80239e:	75 c1                	jne    802361 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8023a0:	8b 42 58             	mov    0x58(%edx),%eax
  8023a3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8023aa:	00 
  8023ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023b3:	c7 04 24 5b 31 80 00 	movl   $0x80315b,(%esp)
  8023ba:	e8 a1 df ff ff       	call   800360 <cprintf>
  8023bf:	eb a0                	jmp    802361 <_pipeisclosed+0xe>

008023c1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	57                   	push   %edi
  8023c5:	56                   	push   %esi
  8023c6:	53                   	push   %ebx
  8023c7:	83 ec 1c             	sub    $0x1c,%esp
  8023ca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8023cd:	89 34 24             	mov    %esi,(%esp)
  8023d0:	e8 33 f1 ff ff       	call   801508 <fd2data>
  8023d5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8023dc:	eb 3c                	jmp    80241a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8023de:	89 da                	mov    %ebx,%edx
  8023e0:	89 f0                	mov    %esi,%eax
  8023e2:	e8 6c ff ff ff       	call   802353 <_pipeisclosed>
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	75 38                	jne    802423 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023eb:	e8 ee e8 ff ff       	call   800cde <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8023f3:	8b 13                	mov    (%ebx),%edx
  8023f5:	83 c2 20             	add    $0x20,%edx
  8023f8:	39 d0                	cmp    %edx,%eax
  8023fa:	73 e2                	jae    8023de <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ff:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802402:	89 c2                	mov    %eax,%edx
  802404:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80240a:	79 05                	jns    802411 <devpipe_write+0x50>
  80240c:	4a                   	dec    %edx
  80240d:	83 ca e0             	or     $0xffffffe0,%edx
  802410:	42                   	inc    %edx
  802411:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802415:	40                   	inc    %eax
  802416:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802419:	47                   	inc    %edi
  80241a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80241d:	75 d1                	jne    8023f0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80241f:	89 f8                	mov    %edi,%eax
  802421:	eb 05                	jmp    802428 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802423:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802428:	83 c4 1c             	add    $0x1c,%esp
  80242b:	5b                   	pop    %ebx
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	57                   	push   %edi
  802434:	56                   	push   %esi
  802435:	53                   	push   %ebx
  802436:	83 ec 1c             	sub    $0x1c,%esp
  802439:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80243c:	89 3c 24             	mov    %edi,(%esp)
  80243f:	e8 c4 f0 ff ff       	call   801508 <fd2data>
  802444:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802446:	be 00 00 00 00       	mov    $0x0,%esi
  80244b:	eb 3a                	jmp    802487 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80244d:	85 f6                	test   %esi,%esi
  80244f:	74 04                	je     802455 <devpipe_read+0x25>
				return i;
  802451:	89 f0                	mov    %esi,%eax
  802453:	eb 40                	jmp    802495 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802455:	89 da                	mov    %ebx,%edx
  802457:	89 f8                	mov    %edi,%eax
  802459:	e8 f5 fe ff ff       	call   802353 <_pipeisclosed>
  80245e:	85 c0                	test   %eax,%eax
  802460:	75 2e                	jne    802490 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802462:	e8 77 e8 ff ff       	call   800cde <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802467:	8b 03                	mov    (%ebx),%eax
  802469:	3b 43 04             	cmp    0x4(%ebx),%eax
  80246c:	74 df                	je     80244d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80246e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802473:	79 05                	jns    80247a <devpipe_read+0x4a>
  802475:	48                   	dec    %eax
  802476:	83 c8 e0             	or     $0xffffffe0,%eax
  802479:	40                   	inc    %eax
  80247a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80247e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802481:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802484:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802486:	46                   	inc    %esi
  802487:	3b 75 10             	cmp    0x10(%ebp),%esi
  80248a:	75 db                	jne    802467 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80248c:	89 f0                	mov    %esi,%eax
  80248e:	eb 05                	jmp    802495 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802490:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802495:	83 c4 1c             	add    $0x1c,%esp
  802498:	5b                   	pop    %ebx
  802499:	5e                   	pop    %esi
  80249a:	5f                   	pop    %edi
  80249b:	5d                   	pop    %ebp
  80249c:	c3                   	ret    

0080249d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80249d:	55                   	push   %ebp
  80249e:	89 e5                	mov    %esp,%ebp
  8024a0:	57                   	push   %edi
  8024a1:	56                   	push   %esi
  8024a2:	53                   	push   %ebx
  8024a3:	83 ec 3c             	sub    $0x3c,%esp
  8024a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8024a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8024ac:	89 04 24             	mov    %eax,(%esp)
  8024af:	e8 6f f0 ff ff       	call   801523 <fd_alloc>
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	85 c0                	test   %eax,%eax
  8024b8:	0f 88 45 01 00 00    	js     802603 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024be:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024c5:	00 
  8024c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024d4:	e8 24 e8 ff ff       	call   800cfd <sys_page_alloc>
  8024d9:	89 c3                	mov    %eax,%ebx
  8024db:	85 c0                	test   %eax,%eax
  8024dd:	0f 88 20 01 00 00    	js     802603 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8024e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8024e6:	89 04 24             	mov    %eax,(%esp)
  8024e9:	e8 35 f0 ff ff       	call   801523 <fd_alloc>
  8024ee:	89 c3                	mov    %eax,%ebx
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	0f 88 f8 00 00 00    	js     8025f0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024f8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024ff:	00 
  802500:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802503:	89 44 24 04          	mov    %eax,0x4(%esp)
  802507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250e:	e8 ea e7 ff ff       	call   800cfd <sys_page_alloc>
  802513:	89 c3                	mov    %eax,%ebx
  802515:	85 c0                	test   %eax,%eax
  802517:	0f 88 d3 00 00 00    	js     8025f0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80251d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802520:	89 04 24             	mov    %eax,(%esp)
  802523:	e8 e0 ef ff ff       	call   801508 <fd2data>
  802528:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80252a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802531:	00 
  802532:	89 44 24 04          	mov    %eax,0x4(%esp)
  802536:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80253d:	e8 bb e7 ff ff       	call   800cfd <sys_page_alloc>
  802542:	89 c3                	mov    %eax,%ebx
  802544:	85 c0                	test   %eax,%eax
  802546:	0f 88 91 00 00 00    	js     8025dd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80254c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80254f:	89 04 24             	mov    %eax,(%esp)
  802552:	e8 b1 ef ff ff       	call   801508 <fd2data>
  802557:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80255e:	00 
  80255f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802563:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80256a:	00 
  80256b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802576:	e8 d6 e7 ff ff       	call   800d51 <sys_page_map>
  80257b:	89 c3                	mov    %eax,%ebx
  80257d:	85 c0                	test   %eax,%eax
  80257f:	78 4c                	js     8025cd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802581:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80258a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80258c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80258f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802596:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80259c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80259f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8025a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025a4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8025ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ae:	89 04 24             	mov    %eax,(%esp)
  8025b1:	e8 42 ef ff ff       	call   8014f8 <fd2num>
  8025b6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8025b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025bb:	89 04 24             	mov    %eax,(%esp)
  8025be:	e8 35 ef ff ff       	call   8014f8 <fd2num>
  8025c3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8025c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025cb:	eb 36                	jmp    802603 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8025cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025d8:	e8 c7 e7 ff ff       	call   800da4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8025dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025eb:	e8 b4 e7 ff ff       	call   800da4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8025f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025fe:	e8 a1 e7 ff ff       	call   800da4 <sys_page_unmap>
    err:
	return r;
}
  802603:	89 d8                	mov    %ebx,%eax
  802605:	83 c4 3c             	add    $0x3c,%esp
  802608:	5b                   	pop    %ebx
  802609:	5e                   	pop    %esi
  80260a:	5f                   	pop    %edi
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    

0080260d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80260d:	55                   	push   %ebp
  80260e:	89 e5                	mov    %esp,%ebp
  802610:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80261a:	8b 45 08             	mov    0x8(%ebp),%eax
  80261d:	89 04 24             	mov    %eax,(%esp)
  802620:	e8 51 ef ff ff       	call   801576 <fd_lookup>
  802625:	85 c0                	test   %eax,%eax
  802627:	78 15                	js     80263e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80262c:	89 04 24             	mov    %eax,(%esp)
  80262f:	e8 d4 ee ff ff       	call   801508 <fd2data>
	return _pipeisclosed(fd, p);
  802634:	89 c2                	mov    %eax,%edx
  802636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802639:	e8 15 fd ff ff       	call   802353 <_pipeisclosed>
}
  80263e:	c9                   	leave  
  80263f:	c3                   	ret    

00802640 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802643:	b8 00 00 00 00       	mov    $0x0,%eax
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    

0080264a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80264a:	55                   	push   %ebp
  80264b:	89 e5                	mov    %esp,%ebp
  80264d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802650:	c7 44 24 04 73 31 80 	movl   $0x803173,0x4(%esp)
  802657:	00 
  802658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80265b:	89 04 24             	mov    %eax,(%esp)
  80265e:	e8 a8 e2 ff ff       	call   80090b <strcpy>
	return 0;
}
  802663:	b8 00 00 00 00       	mov    $0x0,%eax
  802668:	c9                   	leave  
  802669:	c3                   	ret    

0080266a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	57                   	push   %edi
  80266e:	56                   	push   %esi
  80266f:	53                   	push   %ebx
  802670:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802676:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80267b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802681:	eb 30                	jmp    8026b3 <devcons_write+0x49>
		m = n - tot;
  802683:	8b 75 10             	mov    0x10(%ebp),%esi
  802686:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802688:	83 fe 7f             	cmp    $0x7f,%esi
  80268b:	76 05                	jbe    802692 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80268d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802692:	89 74 24 08          	mov    %esi,0x8(%esp)
  802696:	03 45 0c             	add    0xc(%ebp),%eax
  802699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80269d:	89 3c 24             	mov    %edi,(%esp)
  8026a0:	e8 df e3 ff ff       	call   800a84 <memmove>
		sys_cputs(buf, m);
  8026a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a9:	89 3c 24             	mov    %edi,(%esp)
  8026ac:	e8 7f e5 ff ff       	call   800c30 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026b1:	01 f3                	add    %esi,%ebx
  8026b3:	89 d8                	mov    %ebx,%eax
  8026b5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8026b8:	72 c9                	jb     802683 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8026ba:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8026c0:	5b                   	pop    %ebx
  8026c1:	5e                   	pop    %esi
  8026c2:	5f                   	pop    %edi
  8026c3:	5d                   	pop    %ebp
  8026c4:	c3                   	ret    

008026c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026c5:	55                   	push   %ebp
  8026c6:	89 e5                	mov    %esp,%ebp
  8026c8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8026cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8026cf:	75 07                	jne    8026d8 <devcons_read+0x13>
  8026d1:	eb 25                	jmp    8026f8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8026d3:	e8 06 e6 ff ff       	call   800cde <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8026d8:	e8 71 e5 ff ff       	call   800c4e <sys_cgetc>
  8026dd:	85 c0                	test   %eax,%eax
  8026df:	74 f2                	je     8026d3 <devcons_read+0xe>
  8026e1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8026e3:	85 c0                	test   %eax,%eax
  8026e5:	78 1d                	js     802704 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8026e7:	83 f8 04             	cmp    $0x4,%eax
  8026ea:	74 13                	je     8026ff <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8026ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ef:	88 10                	mov    %dl,(%eax)
	return 1;
  8026f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026f6:	eb 0c                	jmp    802704 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8026f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8026fd:	eb 05                	jmp    802704 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8026ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802704:	c9                   	leave  
  802705:	c3                   	ret    

00802706 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802706:	55                   	push   %ebp
  802707:	89 e5                	mov    %esp,%ebp
  802709:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80270c:	8b 45 08             	mov    0x8(%ebp),%eax
  80270f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802712:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802719:	00 
  80271a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80271d:	89 04 24             	mov    %eax,(%esp)
  802720:	e8 0b e5 ff ff       	call   800c30 <sys_cputs>
}
  802725:	c9                   	leave  
  802726:	c3                   	ret    

00802727 <getchar>:

int
getchar(void)
{
  802727:	55                   	push   %ebp
  802728:	89 e5                	mov    %esp,%ebp
  80272a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80272d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802734:	00 
  802735:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80273c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802743:	e8 ca f0 ff ff       	call   801812 <read>
	if (r < 0)
  802748:	85 c0                	test   %eax,%eax
  80274a:	78 0f                	js     80275b <getchar+0x34>
		return r;
	if (r < 1)
  80274c:	85 c0                	test   %eax,%eax
  80274e:	7e 06                	jle    802756 <getchar+0x2f>
		return -E_EOF;
	return c;
  802750:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802754:	eb 05                	jmp    80275b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802756:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80275b:	c9                   	leave  
  80275c:	c3                   	ret    

0080275d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80275d:	55                   	push   %ebp
  80275e:	89 e5                	mov    %esp,%ebp
  802760:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802763:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802766:	89 44 24 04          	mov    %eax,0x4(%esp)
  80276a:	8b 45 08             	mov    0x8(%ebp),%eax
  80276d:	89 04 24             	mov    %eax,(%esp)
  802770:	e8 01 ee ff ff       	call   801576 <fd_lookup>
  802775:	85 c0                	test   %eax,%eax
  802777:	78 11                	js     80278a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80277c:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802782:	39 10                	cmp    %edx,(%eax)
  802784:	0f 94 c0             	sete   %al
  802787:	0f b6 c0             	movzbl %al,%eax
}
  80278a:	c9                   	leave  
  80278b:	c3                   	ret    

0080278c <opencons>:

int
opencons(void)
{
  80278c:	55                   	push   %ebp
  80278d:	89 e5                	mov    %esp,%ebp
  80278f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802792:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802795:	89 04 24             	mov    %eax,(%esp)
  802798:	e8 86 ed ff ff       	call   801523 <fd_alloc>
  80279d:	85 c0                	test   %eax,%eax
  80279f:	78 3c                	js     8027dd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027a1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027a8:	00 
  8027a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027b7:	e8 41 e5 ff ff       	call   800cfd <sys_page_alloc>
  8027bc:	85 c0                	test   %eax,%eax
  8027be:	78 1d                	js     8027dd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8027c0:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8027c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8027cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8027d5:	89 04 24             	mov    %eax,(%esp)
  8027d8:	e8 1b ed ff ff       	call   8014f8 <fd2num>
}
  8027dd:	c9                   	leave  
  8027de:	c3                   	ret    
	...

008027e0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027e0:	55                   	push   %ebp
  8027e1:	89 e5                	mov    %esp,%ebp
  8027e3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027e6:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8027ed:	75 58                	jne    802847 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8027ef:	a1 08 50 80 00       	mov    0x805008,%eax
  8027f4:	8b 40 48             	mov    0x48(%eax),%eax
  8027f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8027fe:	00 
  8027ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802806:	ee 
  802807:	89 04 24             	mov    %eax,(%esp)
  80280a:	e8 ee e4 ff ff       	call   800cfd <sys_page_alloc>
  80280f:	85 c0                	test   %eax,%eax
  802811:	74 1c                	je     80282f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  802813:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  80281a:	00 
  80281b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802822:	00 
  802823:	c7 04 24 94 31 80 00 	movl   $0x803194,(%esp)
  80282a:	e8 39 da ff ff       	call   800268 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80282f:	a1 08 50 80 00       	mov    0x805008,%eax
  802834:	8b 40 48             	mov    0x48(%eax),%eax
  802837:	c7 44 24 04 54 28 80 	movl   $0x802854,0x4(%esp)
  80283e:	00 
  80283f:	89 04 24             	mov    %eax,(%esp)
  802842:	e8 56 e6 ff ff       	call   800e9d <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802847:	8b 45 08             	mov    0x8(%ebp),%eax
  80284a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80284f:	c9                   	leave  
  802850:	c3                   	ret    
  802851:	00 00                	add    %al,(%eax)
	...

00802854 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802854:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802855:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80285a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80285c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80285f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802863:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802865:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802869:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80286a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  80286d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80286f:	58                   	pop    %eax
	popl %eax
  802870:	58                   	pop    %eax

	// Pop all registers back
	popal
  802871:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802872:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802875:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802876:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802877:	c3                   	ret    

00802878 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802878:	55                   	push   %ebp
  802879:	57                   	push   %edi
  80287a:	56                   	push   %esi
  80287b:	83 ec 10             	sub    $0x10,%esp
  80287e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802882:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802886:	89 74 24 04          	mov    %esi,0x4(%esp)
  80288a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80288e:	89 cd                	mov    %ecx,%ebp
  802890:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802894:	85 c0                	test   %eax,%eax
  802896:	75 2c                	jne    8028c4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802898:	39 f9                	cmp    %edi,%ecx
  80289a:	77 68                	ja     802904 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80289c:	85 c9                	test   %ecx,%ecx
  80289e:	75 0b                	jne    8028ab <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8028a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8028a5:	31 d2                	xor    %edx,%edx
  8028a7:	f7 f1                	div    %ecx
  8028a9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8028ab:	31 d2                	xor    %edx,%edx
  8028ad:	89 f8                	mov    %edi,%eax
  8028af:	f7 f1                	div    %ecx
  8028b1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028b3:	89 f0                	mov    %esi,%eax
  8028b5:	f7 f1                	div    %ecx
  8028b7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028b9:	89 f0                	mov    %esi,%eax
  8028bb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028bd:	83 c4 10             	add    $0x10,%esp
  8028c0:	5e                   	pop    %esi
  8028c1:	5f                   	pop    %edi
  8028c2:	5d                   	pop    %ebp
  8028c3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028c4:	39 f8                	cmp    %edi,%eax
  8028c6:	77 2c                	ja     8028f4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8028c8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8028cb:	83 f6 1f             	xor    $0x1f,%esi
  8028ce:	75 4c                	jne    80291c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028d0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028d2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028d7:	72 0a                	jb     8028e3 <__udivdi3+0x6b>
  8028d9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8028dd:	0f 87 ad 00 00 00    	ja     802990 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8028e3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028e8:	89 f0                	mov    %esi,%eax
  8028ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028ec:	83 c4 10             	add    $0x10,%esp
  8028ef:	5e                   	pop    %esi
  8028f0:	5f                   	pop    %edi
  8028f1:	5d                   	pop    %ebp
  8028f2:	c3                   	ret    
  8028f3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8028f4:	31 ff                	xor    %edi,%edi
  8028f6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8028f8:	89 f0                	mov    %esi,%eax
  8028fa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8028fc:	83 c4 10             	add    $0x10,%esp
  8028ff:	5e                   	pop    %esi
  802900:	5f                   	pop    %edi
  802901:	5d                   	pop    %ebp
  802902:	c3                   	ret    
  802903:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802904:	89 fa                	mov    %edi,%edx
  802906:	89 f0                	mov    %esi,%eax
  802908:	f7 f1                	div    %ecx
  80290a:	89 c6                	mov    %eax,%esi
  80290c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80290e:	89 f0                	mov    %esi,%eax
  802910:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802912:	83 c4 10             	add    $0x10,%esp
  802915:	5e                   	pop    %esi
  802916:	5f                   	pop    %edi
  802917:	5d                   	pop    %ebp
  802918:	c3                   	ret    
  802919:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80291c:	89 f1                	mov    %esi,%ecx
  80291e:	d3 e0                	shl    %cl,%eax
  802920:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802924:	b8 20 00 00 00       	mov    $0x20,%eax
  802929:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80292b:	89 ea                	mov    %ebp,%edx
  80292d:	88 c1                	mov    %al,%cl
  80292f:	d3 ea                	shr    %cl,%edx
  802931:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802935:	09 ca                	or     %ecx,%edx
  802937:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80293b:	89 f1                	mov    %esi,%ecx
  80293d:	d3 e5                	shl    %cl,%ebp
  80293f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802943:	89 fd                	mov    %edi,%ebp
  802945:	88 c1                	mov    %al,%cl
  802947:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802949:	89 fa                	mov    %edi,%edx
  80294b:	89 f1                	mov    %esi,%ecx
  80294d:	d3 e2                	shl    %cl,%edx
  80294f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802953:	88 c1                	mov    %al,%cl
  802955:	d3 ef                	shr    %cl,%edi
  802957:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802959:	89 f8                	mov    %edi,%eax
  80295b:	89 ea                	mov    %ebp,%edx
  80295d:	f7 74 24 08          	divl   0x8(%esp)
  802961:	89 d1                	mov    %edx,%ecx
  802963:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802965:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802969:	39 d1                	cmp    %edx,%ecx
  80296b:	72 17                	jb     802984 <__udivdi3+0x10c>
  80296d:	74 09                	je     802978 <__udivdi3+0x100>
  80296f:	89 fe                	mov    %edi,%esi
  802971:	31 ff                	xor    %edi,%edi
  802973:	e9 41 ff ff ff       	jmp    8028b9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802978:	8b 54 24 04          	mov    0x4(%esp),%edx
  80297c:	89 f1                	mov    %esi,%ecx
  80297e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802980:	39 c2                	cmp    %eax,%edx
  802982:	73 eb                	jae    80296f <__udivdi3+0xf7>
		{
		  q0--;
  802984:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802987:	31 ff                	xor    %edi,%edi
  802989:	e9 2b ff ff ff       	jmp    8028b9 <__udivdi3+0x41>
  80298e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802990:	31 f6                	xor    %esi,%esi
  802992:	e9 22 ff ff ff       	jmp    8028b9 <__udivdi3+0x41>
	...

00802998 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802998:	55                   	push   %ebp
  802999:	57                   	push   %edi
  80299a:	56                   	push   %esi
  80299b:	83 ec 20             	sub    $0x20,%esp
  80299e:	8b 44 24 30          	mov    0x30(%esp),%eax
  8029a2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029a6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8029aa:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8029ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8029b2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8029b6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8029b8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8029ba:	85 ed                	test   %ebp,%ebp
  8029bc:	75 16                	jne    8029d4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8029be:	39 f1                	cmp    %esi,%ecx
  8029c0:	0f 86 a6 00 00 00    	jbe    802a6c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029c6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8029c8:	89 d0                	mov    %edx,%eax
  8029ca:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029cc:	83 c4 20             	add    $0x20,%esp
  8029cf:	5e                   	pop    %esi
  8029d0:	5f                   	pop    %edi
  8029d1:	5d                   	pop    %ebp
  8029d2:	c3                   	ret    
  8029d3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029d4:	39 f5                	cmp    %esi,%ebp
  8029d6:	0f 87 ac 00 00 00    	ja     802a88 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029dc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8029df:	83 f0 1f             	xor    $0x1f,%eax
  8029e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029e6:	0f 84 a8 00 00 00    	je     802a94 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029ec:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029f0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029f2:	bf 20 00 00 00       	mov    $0x20,%edi
  8029f7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8029fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8029ff:	89 f9                	mov    %edi,%ecx
  802a01:	d3 e8                	shr    %cl,%eax
  802a03:	09 e8                	or     %ebp,%eax
  802a05:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802a09:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802a0d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a11:	d3 e0                	shl    %cl,%eax
  802a13:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a17:	89 f2                	mov    %esi,%edx
  802a19:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802a1b:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a1f:	d3 e0                	shl    %cl,%eax
  802a21:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802a25:	8b 44 24 14          	mov    0x14(%esp),%eax
  802a29:	89 f9                	mov    %edi,%ecx
  802a2b:	d3 e8                	shr    %cl,%eax
  802a2d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802a2f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a31:	89 f2                	mov    %esi,%edx
  802a33:	f7 74 24 18          	divl   0x18(%esp)
  802a37:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802a39:	f7 64 24 0c          	mull   0xc(%esp)
  802a3d:	89 c5                	mov    %eax,%ebp
  802a3f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a41:	39 d6                	cmp    %edx,%esi
  802a43:	72 67                	jb     802aac <__umoddi3+0x114>
  802a45:	74 75                	je     802abc <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802a47:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802a4b:	29 e8                	sub    %ebp,%eax
  802a4d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802a4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a53:	d3 e8                	shr    %cl,%eax
  802a55:	89 f2                	mov    %esi,%edx
  802a57:	89 f9                	mov    %edi,%ecx
  802a59:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802a5b:	09 d0                	or     %edx,%eax
  802a5d:	89 f2                	mov    %esi,%edx
  802a5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802a63:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a65:	83 c4 20             	add    $0x20,%esp
  802a68:	5e                   	pop    %esi
  802a69:	5f                   	pop    %edi
  802a6a:	5d                   	pop    %ebp
  802a6b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a6c:	85 c9                	test   %ecx,%ecx
  802a6e:	75 0b                	jne    802a7b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802a70:	b8 01 00 00 00       	mov    $0x1,%eax
  802a75:	31 d2                	xor    %edx,%edx
  802a77:	f7 f1                	div    %ecx
  802a79:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a7b:	89 f0                	mov    %esi,%eax
  802a7d:	31 d2                	xor    %edx,%edx
  802a7f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a81:	89 f8                	mov    %edi,%eax
  802a83:	e9 3e ff ff ff       	jmp    8029c6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802a88:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a8a:	83 c4 20             	add    $0x20,%esp
  802a8d:	5e                   	pop    %esi
  802a8e:	5f                   	pop    %edi
  802a8f:	5d                   	pop    %ebp
  802a90:	c3                   	ret    
  802a91:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a94:	39 f5                	cmp    %esi,%ebp
  802a96:	72 04                	jb     802a9c <__umoddi3+0x104>
  802a98:	39 f9                	cmp    %edi,%ecx
  802a9a:	77 06                	ja     802aa2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a9c:	89 f2                	mov    %esi,%edx
  802a9e:	29 cf                	sub    %ecx,%edi
  802aa0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802aa2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802aa4:	83 c4 20             	add    $0x20,%esp
  802aa7:	5e                   	pop    %esi
  802aa8:	5f                   	pop    %edi
  802aa9:	5d                   	pop    %ebp
  802aaa:	c3                   	ret    
  802aab:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802aac:	89 d1                	mov    %edx,%ecx
  802aae:	89 c5                	mov    %eax,%ebp
  802ab0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802ab4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802ab8:	eb 8d                	jmp    802a47 <__umoddi3+0xaf>
  802aba:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802abc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802ac0:	72 ea                	jb     802aac <__umoddi3+0x114>
  802ac2:	89 f1                	mov    %esi,%ecx
  802ac4:	eb 81                	jmp    802a47 <__umoddi3+0xaf>
