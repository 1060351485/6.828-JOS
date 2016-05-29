
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
  80002c:	e8 ff 01 00 00       	call   800230 <libmain>
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
  80003c:	c7 04 24 a0 25 80 00 	movl   $0x8025a0,(%esp)
  800043:	e8 48 03 00 00       	call   800390 <cprintf>
	if ((r = pipe(p)) < 0)
  800048:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004b:	89 04 24             	mov    %eax,(%esp)
  80004e:	e8 12 1f 00 00       	call   801f65 <pipe>
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", r);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 b9 25 80 	movl   $0x8025b9,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 c2 25 80 00 	movl   $0x8025c2,(%esp)
  800072:	e8 21 02 00 00       	call   800298 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800077:	e8 2b 10 00 00       	call   8010a7 <fork>
  80007c:	89 c6                	mov    %eax,%esi
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", r);
  800082:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800086:	c7 44 24 08 d6 25 80 	movl   $0x8025d6,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 c2 25 80 00 	movl   $0x8025c2,(%esp)
  80009d:	e8 f6 01 00 00       	call   800298 <_panic>
	if (r == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	75 54                	jne    8000fa <umain+0xc6>
		close(p[1]);
  8000a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a9:	89 04 24             	mov    %eax,(%esp)
  8000ac:	e8 c1 15 00 00       	call   801672 <close>
  8000b1:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  8000b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 14 20 00 00       	call   8020d5 <pipeisclosed>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	74 11                	je     8000d6 <umain+0xa2>
				cprintf("RACE: pipe appears closed\n");
  8000c5:	c7 04 24 df 25 80 00 	movl   $0x8025df,(%esp)
  8000cc:	e8 bf 02 00 00       	call   800390 <cprintf>
				exit();
  8000d1:	e8 ae 01 00 00       	call   800284 <exit>
			}
			sys_yield();
  8000d6:	e8 33 0c 00 00       	call   800d0e <sys_yield>
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
  8000f5:	e8 a6 12 00 00       	call   8013a0 <ipc_recv>
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fe:	c7 04 24 fa 25 80 00 	movl   $0x8025fa,(%esp)
  800105:	e8 86 02 00 00       	call   800390 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  80010a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800110:	8d 04 b5 00 00 00 00 	lea    0x0(,%esi,4),%eax
  800117:	c1 e6 07             	shl    $0x7,%esi
  80011a:	29 c6                	sub    %eax,%esi
	cprintf("kid is %d\n", kid-envs);
  80011c:	8d 9e 00 00 c0 ee    	lea    -0x11400000(%esi),%ebx
  800122:	c1 fe 02             	sar    $0x2,%esi
  800125:	89 f2                	mov    %esi,%edx
  800127:	c1 e2 05             	shl    $0x5,%edx
  80012a:	89 f0                	mov    %esi,%eax
  80012c:	c1 e0 0a             	shl    $0xa,%eax
  80012f:	01 d0                	add    %edx,%eax
  800131:	01 f0                	add    %esi,%eax
  800133:	89 c2                	mov    %eax,%edx
  800135:	c1 e2 0f             	shl    $0xf,%edx
  800138:	01 d0                	add    %edx,%eax
  80013a:	c1 e0 05             	shl    $0x5,%eax
  80013d:	01 c6                	add    %eax,%esi
  80013f:	f7 de                	neg    %esi
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	c7 04 24 05 26 80 00 	movl   $0x802605,(%esp)
  80014c:	e8 3f 02 00 00       	call   800390 <cprintf>
	dup(p[0], 10);
  800151:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800158:	00 
  800159:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 5f 15 00 00       	call   8016c3 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  800164:	eb 13                	jmp    800179 <umain+0x145>
		dup(p[0], 10);
  800166:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  80016d:	00 
  80016e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 4a 15 00 00       	call   8016c3 <dup>
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800179:	8b 43 54             	mov    0x54(%ebx),%eax
  80017c:	83 f8 02             	cmp    $0x2,%eax
  80017f:	74 e5                	je     800166 <umain+0x132>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800181:	c7 04 24 10 26 80 00 	movl   $0x802610,(%esp)
  800188:	e8 03 02 00 00       	call   800390 <cprintf>
	if (pipeisclosed(p[0]))
  80018d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 3d 1f 00 00       	call   8020d5 <pipeisclosed>
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 1c                	je     8001b8 <umain+0x184>
		panic("somehow the other end of p[0] got closed!");
  80019c:	c7 44 24 08 6c 26 80 	movl   $0x80266c,0x8(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8001ab:	00 
  8001ac:	c7 04 24 c2 25 80 00 	movl   $0x8025c2,(%esp)
  8001b3:	e8 e0 00 00 00       	call   800298 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  8001b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 70 13 00 00       	call   80153a <fd_lookup>
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	79 20                	jns    8001ee <umain+0x1ba>
		panic("cannot look up p[0]: %e", r);
  8001ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d2:	c7 44 24 08 26 26 80 	movl   $0x802626,0x8(%esp)
  8001d9:	00 
  8001da:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  8001e1:	00 
  8001e2:	c7 04 24 c2 25 80 00 	movl   $0x8025c2,(%esp)
  8001e9:	e8 aa 00 00 00       	call   800298 <_panic>
	va = fd2data(fd);
  8001ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 d3 12 00 00       	call   8014cc <fd2data>
	if (pageref(va) != 3+1)
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 4b 1b 00 00       	call   801d4c <pageref>
  800201:	83 f8 04             	cmp    $0x4,%eax
  800204:	74 0e                	je     800214 <umain+0x1e0>
		cprintf("\nchild detected race\n");
  800206:	c7 04 24 3e 26 80 00 	movl   $0x80263e,(%esp)
  80020d:	e8 7e 01 00 00       	call   800390 <cprintf>
  800212:	eb 14                	jmp    800228 <umain+0x1f4>
	else
		cprintf("\nrace didn't happen\n", max);
  800214:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 54 26 80 00 	movl   $0x802654,(%esp)
  800223:	e8 68 01 00 00       	call   800390 <cprintf>
}
  800228:	83 c4 20             	add    $0x20,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    
	...

00800230 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 10             	sub    $0x10,%esp
  800238:	8b 75 08             	mov    0x8(%ebp),%esi
  80023b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80023e:	e8 ac 0a 00 00       	call   800cef <sys_getenvid>
  800243:	25 ff 03 00 00       	and    $0x3ff,%eax
  800248:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80024f:	c1 e0 07             	shl    $0x7,%eax
  800252:	29 d0                	sub    %edx,%eax
  800254:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800259:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025e:	85 f6                	test   %esi,%esi
  800260:	7e 07                	jle    800269 <libmain+0x39>
		binaryname = argv[0];
  800262:	8b 03                	mov    (%ebx),%eax
  800264:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800269:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80026d:	89 34 24             	mov    %esi,(%esp)
  800270:	e8 bf fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800275:	e8 0a 00 00 00       	call   800284 <exit>
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	00 00                	add    %al,(%eax)
	...

00800284 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  80028a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800291:	e8 07 0a 00 00       	call   800c9d <sys_env_destroy>
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002a9:	e8 41 0a 00 00       	call   800cef <sys_getenvid>
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	c7 04 24 a0 26 80 00 	movl   $0x8026a0,(%esp)
  8002cb:	e8 c0 00 00 00       	call   800390 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d7:	89 04 24             	mov    %eax,(%esp)
  8002da:	e8 50 00 00 00       	call   80032f <vcprintf>
	cprintf("\n");
  8002df:	c7 04 24 b7 25 80 00 	movl   $0x8025b7,(%esp)
  8002e6:	e8 a5 00 00 00       	call   800390 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002eb:	cc                   	int3   
  8002ec:	eb fd                	jmp    8002eb <_panic+0x53>
	...

008002f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 14             	sub    $0x14,%esp
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800303:	40                   	inc    %eax
  800304:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800306:	3d ff 00 00 00       	cmp    $0xff,%eax
  80030b:	75 19                	jne    800326 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80030d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800314:	00 
  800315:	8d 43 08             	lea    0x8(%ebx),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	e8 40 09 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  800320:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800326:	ff 43 04             	incl   0x4(%ebx)
}
  800329:	83 c4 14             	add    $0x14,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800338:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80033f:	00 00 00 
	b.cnt = 0;
  800342:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800349:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800360:	89 44 24 04          	mov    %eax,0x4(%esp)
  800364:	c7 04 24 f0 02 80 00 	movl   $0x8002f0,(%esp)
  80036b:	e8 82 01 00 00       	call   8004f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800370:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	e8 d8 08 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  800388:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800396:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 87 ff ff ff       	call   80032f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    
	...

008003ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	57                   	push   %edi
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 3c             	sub    $0x3c,%esp
  8003b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b8:	89 d7                	mov    %edx,%edi
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003cc:	85 c0                	test   %eax,%eax
  8003ce:	75 08                	jne    8003d8 <printnum+0x2c>
  8003d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003d6:	77 57                	ja     80042f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003dc:	4b                   	dec    %ebx
  8003dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8003ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8003f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f7:	00 
  8003f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800401:	89 44 24 04          	mov    %eax,0x4(%esp)
  800405:	e8 36 1f 00 00       	call   802340 <__udivdi3>
  80040a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80040e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	89 54 24 04          	mov    %edx,0x4(%esp)
  800419:	89 fa                	mov    %edi,%edx
  80041b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041e:	e8 89 ff ff ff       	call   8003ac <printnum>
  800423:	eb 0f                	jmp    800434 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800425:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800429:	89 34 24             	mov    %esi,(%esp)
  80042c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042f:	4b                   	dec    %ebx
  800430:	85 db                	test   %ebx,%ebx
  800432:	7f f1                	jg     800425 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800434:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800438:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80043c:	8b 45 10             	mov    0x10(%ebp),%eax
  80043f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800443:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044a:	00 
  80044b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	e8 03 20 00 00       	call   802460 <__umoddi3>
  80045d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800461:	0f be 80 c3 26 80 00 	movsbl 0x8026c3(%eax),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80046e:	83 c4 3c             	add    $0x3c,%esp
  800471:	5b                   	pop    %ebx
  800472:	5e                   	pop    %esi
  800473:	5f                   	pop    %edi
  800474:	5d                   	pop    %ebp
  800475:	c3                   	ret    

00800476 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800479:	83 fa 01             	cmp    $0x1,%edx
  80047c:	7e 0e                	jle    80048c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80047e:	8b 10                	mov    (%eax),%edx
  800480:	8d 4a 08             	lea    0x8(%edx),%ecx
  800483:	89 08                	mov    %ecx,(%eax)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	8b 52 04             	mov    0x4(%edx),%edx
  80048a:	eb 22                	jmp    8004ae <getuint+0x38>
	else if (lflag)
  80048c:	85 d2                	test   %edx,%edx
  80048e:	74 10                	je     8004a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800490:	8b 10                	mov    (%eax),%edx
  800492:	8d 4a 04             	lea    0x4(%edx),%ecx
  800495:	89 08                	mov    %ecx,(%eax)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	eb 0e                	jmp    8004ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8004be:	73 08                	jae    8004c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8004c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c3:	88 0a                	mov    %cl,(%edx)
  8004c5:	42                   	inc    %edx
  8004c6:	89 10                	mov    %edx,(%eax)
}
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	e8 02 00 00 00       	call   8004f2 <vprintfmt>
	va_end(ap);
}
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    

008004f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 4c             	sub    $0x4c,%esp
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800501:	eb 12                	jmp    800515 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800503:	85 c0                	test   %eax,%eax
  800505:	0f 84 6b 03 00 00    	je     800876 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80050b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800515:	0f b6 06             	movzbl (%esi),%eax
  800518:	46                   	inc    %esi
  800519:	83 f8 25             	cmp    $0x25,%eax
  80051c:	75 e5                	jne    800503 <vprintfmt+0x11>
  80051e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800522:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800529:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80052e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800535:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053a:	eb 26                	jmp    800562 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800543:	eb 1d                	jmp    800562 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800548:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80054c:	eb 14                	jmp    800562 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800551:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800558:	eb 08                	jmp    800562 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80055a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80055d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800562:	0f b6 06             	movzbl (%esi),%eax
  800565:	8d 56 01             	lea    0x1(%esi),%edx
  800568:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80056b:	8a 16                	mov    (%esi),%dl
  80056d:	83 ea 23             	sub    $0x23,%edx
  800570:	80 fa 55             	cmp    $0x55,%dl
  800573:	0f 87 e1 02 00 00    	ja     80085a <vprintfmt+0x368>
  800579:	0f b6 d2             	movzbl %dl,%edx
  80057c:	ff 24 95 00 28 80 00 	jmp    *0x802800(,%edx,4)
  800583:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800586:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80058b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80058e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800592:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800595:	8d 50 d0             	lea    -0x30(%eax),%edx
  800598:	83 fa 09             	cmp    $0x9,%edx
  80059b:	77 2a                	ja     8005c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80059d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80059e:	eb eb                	jmp    80058b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ae:	eb 17                	jmp    8005c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b4:	78 98                	js     80054e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b9:	eb a7                	jmp    800562 <vprintfmt+0x70>
  8005bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005c5:	eb 9b                	jmp    800562 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005cb:	79 95                	jns    800562 <vprintfmt+0x70>
  8005cd:	eb 8b                	jmp    80055a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d3:	eb 8d                	jmp    800562 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 04 24             	mov    %eax,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005ed:	e9 23 ff ff ff       	jmp    800515 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	79 02                	jns    800603 <vprintfmt+0x111>
  800601:	f7 d8                	neg    %eax
  800603:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800605:	83 f8 0f             	cmp    $0xf,%eax
  800608:	7f 0b                	jg     800615 <vprintfmt+0x123>
  80060a:	8b 04 85 60 29 80 00 	mov    0x802960(,%eax,4),%eax
  800611:	85 c0                	test   %eax,%eax
  800613:	75 23                	jne    800638 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800615:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800619:	c7 44 24 08 db 26 80 	movl   $0x8026db,0x8(%esp)
  800620:	00 
  800621:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800625:	8b 45 08             	mov    0x8(%ebp),%eax
  800628:	89 04 24             	mov    %eax,(%esp)
  80062b:	e8 9a fe ff ff       	call   8004ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800633:	e9 dd fe ff ff       	jmp    800515 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800638:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063c:	c7 44 24 08 b5 2b 80 	movl   $0x802bb5,0x8(%esp)
  800643:	00 
  800644:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800648:	8b 55 08             	mov    0x8(%ebp),%edx
  80064b:	89 14 24             	mov    %edx,(%esp)
  80064e:	e8 77 fe ff ff       	call   8004ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800656:	e9 ba fe ff ff       	jmp    800515 <vprintfmt+0x23>
  80065b:	89 f9                	mov    %edi,%ecx
  80065d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800660:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 04             	lea    0x4(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)
  80066c:	8b 30                	mov    (%eax),%esi
  80066e:	85 f6                	test   %esi,%esi
  800670:	75 05                	jne    800677 <vprintfmt+0x185>
				p = "(null)";
  800672:	be d4 26 80 00       	mov    $0x8026d4,%esi
			if (width > 0 && padc != '-')
  800677:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80067b:	0f 8e 84 00 00 00    	jle    800705 <vprintfmt+0x213>
  800681:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800685:	74 7e                	je     800705 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800687:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80068b:	89 34 24             	mov    %esi,(%esp)
  80068e:	e8 8b 02 00 00       	call   80091e <strnlen>
  800693:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800696:	29 c2                	sub    %eax,%edx
  800698:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80069b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80069f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006a5:	89 de                	mov    %ebx,%esi
  8006a7:	89 d3                	mov    %edx,%ebx
  8006a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ab:	eb 0b                	jmp    8006b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b1:	89 3c 24             	mov    %edi,(%esp)
  8006b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	4b                   	dec    %ebx
  8006b8:	85 db                	test   %ebx,%ebx
  8006ba:	7f f1                	jg     8006ad <vprintfmt+0x1bb>
  8006bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006bf:	89 f3                	mov    %esi,%ebx
  8006c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	79 05                	jns    8006d0 <vprintfmt+0x1de>
  8006cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d3:	29 c2                	sub    %eax,%edx
  8006d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006d8:	eb 2b                	jmp    800705 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006de:	74 18                	je     8006f8 <vprintfmt+0x206>
  8006e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006e3:	83 fa 5e             	cmp    $0x5e,%edx
  8006e6:	76 10                	jbe    8006f8 <vprintfmt+0x206>
					putch('?', putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
  8006f6:	eb 0a                	jmp    800702 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8006f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fc:	89 04 24             	mov    %eax,(%esp)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800702:	ff 4d e4             	decl   -0x1c(%ebp)
  800705:	0f be 06             	movsbl (%esi),%eax
  800708:	46                   	inc    %esi
  800709:	85 c0                	test   %eax,%eax
  80070b:	74 21                	je     80072e <vprintfmt+0x23c>
  80070d:	85 ff                	test   %edi,%edi
  80070f:	78 c9                	js     8006da <vprintfmt+0x1e8>
  800711:	4f                   	dec    %edi
  800712:	79 c6                	jns    8006da <vprintfmt+0x1e8>
  800714:	8b 7d 08             	mov    0x8(%ebp),%edi
  800717:	89 de                	mov    %ebx,%esi
  800719:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80071c:	eb 18                	jmp    800736 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800722:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800729:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072b:	4b                   	dec    %ebx
  80072c:	eb 08                	jmp    800736 <vprintfmt+0x244>
  80072e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800731:	89 de                	mov    %ebx,%esi
  800733:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800736:	85 db                	test   %ebx,%ebx
  800738:	7f e4                	jg     80071e <vprintfmt+0x22c>
  80073a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80073d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800742:	e9 ce fd ff ff       	jmp    800515 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800747:	83 f9 01             	cmp    $0x1,%ecx
  80074a:	7e 10                	jle    80075c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 50 08             	lea    0x8(%eax),%edx
  800752:	89 55 14             	mov    %edx,0x14(%ebp)
  800755:	8b 30                	mov    (%eax),%esi
  800757:	8b 78 04             	mov    0x4(%eax),%edi
  80075a:	eb 26                	jmp    800782 <vprintfmt+0x290>
	else if (lflag)
  80075c:	85 c9                	test   %ecx,%ecx
  80075e:	74 12                	je     800772 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 50 04             	lea    0x4(%eax),%edx
  800766:	89 55 14             	mov    %edx,0x14(%ebp)
  800769:	8b 30                	mov    (%eax),%esi
  80076b:	89 f7                	mov    %esi,%edi
  80076d:	c1 ff 1f             	sar    $0x1f,%edi
  800770:	eb 10                	jmp    800782 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 30                	mov    (%eax),%esi
  80077d:	89 f7                	mov    %esi,%edi
  80077f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800782:	85 ff                	test   %edi,%edi
  800784:	78 0a                	js     800790 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800786:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078b:	e9 8c 00 00 00       	jmp    80081c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80079e:	f7 de                	neg    %esi
  8007a0:	83 d7 00             	adc    $0x0,%edi
  8007a3:	f7 df                	neg    %edi
			}
			base = 10;
  8007a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007aa:	eb 70                	jmp    80081c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007ac:	89 ca                	mov    %ecx,%edx
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	e8 c0 fc ff ff       	call   800476 <getuint>
  8007b6:	89 c6                	mov    %eax,%esi
  8007b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8007ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007bf:	eb 5b                	jmp    80081c <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8007c1:	89 ca                	mov    %ecx,%edx
  8007c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c6:	e8 ab fc ff ff       	call   800476 <getuint>
  8007cb:	89 c6                	mov    %eax,%esi
  8007cd:	89 d7                	mov    %edx,%edi
			base = 8;
  8007cf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007d4:	eb 46                	jmp    80081c <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8007d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007fb:	8b 30                	mov    (%eax),%esi
  8007fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800802:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800807:	eb 13                	jmp    80081c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800809:	89 ca                	mov    %ecx,%edx
  80080b:	8d 45 14             	lea    0x14(%ebp),%eax
  80080e:	e8 63 fc ff ff       	call   800476 <getuint>
  800813:	89 c6                	mov    %eax,%esi
  800815:	89 d7                	mov    %edx,%edi
			base = 16;
  800817:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800820:	89 54 24 10          	mov    %edx,0x10(%esp)
  800824:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800827:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80082b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082f:	89 34 24             	mov    %esi,(%esp)
  800832:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800836:	89 da                	mov    %ebx,%edx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	e8 6c fb ff ff       	call   8003ac <printnum>
			break;
  800840:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800843:	e9 cd fc ff ff       	jmp    800515 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800848:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084c:	89 04 24             	mov    %eax,(%esp)
  80084f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800852:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800855:	e9 bb fc ff ff       	jmp    800515 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80085e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800865:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800868:	eb 01                	jmp    80086b <vprintfmt+0x379>
  80086a:	4e                   	dec    %esi
  80086b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80086f:	75 f9                	jne    80086a <vprintfmt+0x378>
  800871:	e9 9f fc ff ff       	jmp    800515 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800876:	83 c4 4c             	add    $0x4c,%esp
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5f                   	pop    %edi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	83 ec 28             	sub    $0x28,%esp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800891:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800894:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089b:	85 c0                	test   %eax,%eax
  80089d:	74 30                	je     8008cf <vsnprintf+0x51>
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	7e 33                	jle    8008d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	c7 04 24 b0 04 80 00 	movl   $0x8004b0,(%esp)
  8008bf:	e8 2e fc ff ff       	call   8004f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	eb 0c                	jmp    8008db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d4:	eb 05                	jmp    8008db <vsnprintf+0x5d>
  8008d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	89 04 24             	mov    %eax,(%esp)
  8008fe:	e8 7b ff ff ff       	call   80087e <vsnprintf>
	va_end(ap);

	return rc;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    
  800905:	00 00                	add    %al,(%eax)
	...

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
  800913:	eb 01                	jmp    800916 <strlen+0xe>
		n++;
  800915:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091a:	75 f9                	jne    800915 <strlen+0xd>
		n++;
	return n;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	eb 01                	jmp    80092f <strnlen+0x11>
		n++;
  80092e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092f:	39 d0                	cmp    %edx,%eax
  800931:	74 06                	je     800939 <strnlen+0x1b>
  800933:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800937:	75 f5                	jne    80092e <strnlen+0x10>
		n++;
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80094d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800950:	42                   	inc    %edx
  800951:	84 c9                	test   %cl,%cl
  800953:	75 f5                	jne    80094a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800955:	5b                   	pop    %ebx
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	83 ec 08             	sub    $0x8,%esp
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800962:	89 1c 24             	mov    %ebx,(%esp)
  800965:	e8 9e ff ff ff       	call   800908 <strlen>
	strcpy(dst + len, src);
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800971:	01 d8                	add    %ebx,%eax
  800973:	89 04 24             	mov    %eax,(%esp)
  800976:	e8 c0 ff ff ff       	call   80093b <strcpy>
	return dst;
}
  80097b:	89 d8                	mov    %ebx,%eax
  80097d:	83 c4 08             	add    $0x8,%esp
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800991:	b9 00 00 00 00       	mov    $0x0,%ecx
  800996:	eb 0c                	jmp    8009a4 <strncpy+0x21>
		*dst++ = *src;
  800998:	8a 1a                	mov    (%edx),%bl
  80099a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099d:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a3:	41                   	inc    %ecx
  8009a4:	39 f1                	cmp    %esi,%ecx
  8009a6:	75 f0                	jne    800998 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ba:	85 d2                	test   %edx,%edx
  8009bc:	75 0a                	jne    8009c8 <strlcpy+0x1c>
  8009be:	89 f0                	mov    %esi,%eax
  8009c0:	eb 1a                	jmp    8009dc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c2:	88 18                	mov    %bl,(%eax)
  8009c4:	40                   	inc    %eax
  8009c5:	41                   	inc    %ecx
  8009c6:	eb 02                	jmp    8009ca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009ca:	4a                   	dec    %edx
  8009cb:	74 0a                	je     8009d7 <strlcpy+0x2b>
  8009cd:	8a 19                	mov    (%ecx),%bl
  8009cf:	84 db                	test   %bl,%bl
  8009d1:	75 ef                	jne    8009c2 <strlcpy+0x16>
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	eb 02                	jmp    8009d9 <strlcpy+0x2d>
  8009d7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009d9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009dc:	29 f0                	sub    %esi,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009eb:	eb 02                	jmp    8009ef <strcmp+0xd>
		p++, q++;
  8009ed:	41                   	inc    %ecx
  8009ee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ef:	8a 01                	mov    (%ecx),%al
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 04                	je     8009f9 <strcmp+0x17>
  8009f5:	3a 02                	cmp    (%edx),%al
  8009f7:	74 f4                	je     8009ed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f9:	0f b6 c0             	movzbl %al,%eax
  8009fc:	0f b6 12             	movzbl (%edx),%edx
  8009ff:	29 d0                	sub    %edx,%eax
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a10:	eb 03                	jmp    800a15 <strncmp+0x12>
		n--, p++, q++;
  800a12:	4a                   	dec    %edx
  800a13:	40                   	inc    %eax
  800a14:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a15:	85 d2                	test   %edx,%edx
  800a17:	74 14                	je     800a2d <strncmp+0x2a>
  800a19:	8a 18                	mov    (%eax),%bl
  800a1b:	84 db                	test   %bl,%bl
  800a1d:	74 04                	je     800a23 <strncmp+0x20>
  800a1f:	3a 19                	cmp    (%ecx),%bl
  800a21:	74 ef                	je     800a12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a23:	0f b6 00             	movzbl (%eax),%eax
  800a26:	0f b6 11             	movzbl (%ecx),%edx
  800a29:	29 d0                	sub    %edx,%eax
  800a2b:	eb 05                	jmp    800a32 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a32:	5b                   	pop    %ebx
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a3e:	eb 05                	jmp    800a45 <strchr+0x10>
		if (*s == c)
  800a40:	38 ca                	cmp    %cl,%dl
  800a42:	74 0c                	je     800a50 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a44:	40                   	inc    %eax
  800a45:	8a 10                	mov    (%eax),%dl
  800a47:	84 d2                	test   %dl,%dl
  800a49:	75 f5                	jne    800a40 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a5b:	eb 05                	jmp    800a62 <strfind+0x10>
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 07                	je     800a68 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a61:	40                   	inc    %eax
  800a62:	8a 10                	mov    (%eax),%dl
  800a64:	84 d2                	test   %dl,%dl
  800a66:	75 f5                	jne    800a5d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 30                	je     800aad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a83:	75 25                	jne    800aaa <memset+0x40>
  800a85:	f6 c1 03             	test   $0x3,%cl
  800a88:	75 20                	jne    800aaa <memset+0x40>
		c &= 0xFF;
  800a8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	c1 e3 08             	shl    $0x8,%ebx
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	c1 e6 18             	shl    $0x18,%esi
  800a97:	89 d0                	mov    %edx,%eax
  800a99:	c1 e0 10             	shl    $0x10,%eax
  800a9c:	09 f0                	or     %esi,%eax
  800a9e:	09 d0                	or     %edx,%eax
  800aa0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aa5:	fc                   	cld    
  800aa6:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa8:	eb 03                	jmp    800aad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aaa:	fc                   	cld    
  800aab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aad:	89 f8                	mov    %edi,%eax
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 34                	jae    800afa <memmove+0x46>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 d0                	cmp    %edx,%eax
  800acb:	73 2d                	jae    800afa <memmove+0x46>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	f6 c2 03             	test   $0x3,%dl
  800ad3:	75 1b                	jne    800af0 <memmove+0x3c>
  800ad5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800adb:	75 13                	jne    800af0 <memmove+0x3c>
  800add:	f6 c1 03             	test   $0x3,%cl
  800ae0:	75 0e                	jne    800af0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae2:	83 ef 04             	sub    $0x4,%edi
  800ae5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800aeb:	fd                   	std    
  800aec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aee:	eb 07                	jmp    800af7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af0:	4f                   	dec    %edi
  800af1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800af4:	fd                   	std    
  800af5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af7:	fc                   	cld    
  800af8:	eb 20                	jmp    800b1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b00:	75 13                	jne    800b15 <memmove+0x61>
  800b02:	a8 03                	test   $0x3,%al
  800b04:	75 0f                	jne    800b15 <memmove+0x61>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 0a                	jne    800b15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b0e:	89 c7                	mov    %eax,%edi
  800b10:	fc                   	cld    
  800b11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b13:	eb 05                	jmp    800b1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	fc                   	cld    
  800b18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b24:	8b 45 10             	mov    0x10(%ebp),%eax
  800b27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	89 04 24             	mov    %eax,(%esp)
  800b38:	e8 77 ff ff ff       	call   800ab4 <memmove>
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	eb 16                	jmp    800b6b <memcmp+0x2c>
		if (*s1 != *s2)
  800b55:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b58:	42                   	inc    %edx
  800b59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b5d:	38 c8                	cmp    %cl,%al
  800b5f:	74 0a                	je     800b6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b61:	0f b6 c0             	movzbl %al,%eax
  800b64:	0f b6 c9             	movzbl %cl,%ecx
  800b67:	29 c8                	sub    %ecx,%eax
  800b69:	eb 09                	jmp    800b74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6b:	39 da                	cmp    %ebx,%edx
  800b6d:	75 e6                	jne    800b55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b87:	eb 05                	jmp    800b8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b89:	38 08                	cmp    %cl,(%eax)
  800b8b:	74 05                	je     800b92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b8d:	40                   	inc    %eax
  800b8e:	39 d0                	cmp    %edx,%eax
  800b90:	72 f7                	jb     800b89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba0:	eb 01                	jmp    800ba3 <strtol+0xf>
		s++;
  800ba2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba3:	8a 02                	mov    (%edx),%al
  800ba5:	3c 20                	cmp    $0x20,%al
  800ba7:	74 f9                	je     800ba2 <strtol+0xe>
  800ba9:	3c 09                	cmp    $0x9,%al
  800bab:	74 f5                	je     800ba2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bad:	3c 2b                	cmp    $0x2b,%al
  800baf:	75 08                	jne    800bb9 <strtol+0x25>
		s++;
  800bb1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb7:	eb 13                	jmp    800bcc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	75 0a                	jne    800bc7 <strtol+0x33>
		s++, neg = 1;
  800bbd:	8d 52 01             	lea    0x1(%edx),%edx
  800bc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800bc5:	eb 05                	jmp    800bcc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcc:	85 db                	test   %ebx,%ebx
  800bce:	74 05                	je     800bd5 <strtol+0x41>
  800bd0:	83 fb 10             	cmp    $0x10,%ebx
  800bd3:	75 28                	jne    800bfd <strtol+0x69>
  800bd5:	8a 02                	mov    (%edx),%al
  800bd7:	3c 30                	cmp    $0x30,%al
  800bd9:	75 10                	jne    800beb <strtol+0x57>
  800bdb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdf:	75 0a                	jne    800beb <strtol+0x57>
		s += 2, base = 16;
  800be1:	83 c2 02             	add    $0x2,%edx
  800be4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800be9:	eb 12                	jmp    800bfd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800beb:	85 db                	test   %ebx,%ebx
  800bed:	75 0e                	jne    800bfd <strtol+0x69>
  800bef:	3c 30                	cmp    $0x30,%al
  800bf1:	75 05                	jne    800bf8 <strtol+0x64>
		s++, base = 8;
  800bf3:	42                   	inc    %edx
  800bf4:	b3 08                	mov    $0x8,%bl
  800bf6:	eb 05                	jmp    800bfd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800bf8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800c02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c04:	8a 0a                	mov    (%edx),%cl
  800c06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c09:	80 fb 09             	cmp    $0x9,%bl
  800c0c:	77 08                	ja     800c16 <strtol+0x82>
			dig = *s - '0';
  800c0e:	0f be c9             	movsbl %cl,%ecx
  800c11:	83 e9 30             	sub    $0x30,%ecx
  800c14:	eb 1e                	jmp    800c34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c19:	80 fb 19             	cmp    $0x19,%bl
  800c1c:	77 08                	ja     800c26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c1e:	0f be c9             	movsbl %cl,%ecx
  800c21:	83 e9 57             	sub    $0x57,%ecx
  800c24:	eb 0e                	jmp    800c34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c29:	80 fb 19             	cmp    $0x19,%bl
  800c2c:	77 12                	ja     800c40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c2e:	0f be c9             	movsbl %cl,%ecx
  800c31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c34:	39 f1                	cmp    %esi,%ecx
  800c36:	7d 0c                	jge    800c44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c38:	42                   	inc    %edx
  800c39:	0f af c6             	imul   %esi,%eax
  800c3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c3e:	eb c4                	jmp    800c04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c40:	89 c1                	mov    %eax,%ecx
  800c42:	eb 02                	jmp    800c46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4a:	74 05                	je     800c51 <strtol+0xbd>
		*endptr = (char *) s;
  800c4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c51:	85 ff                	test   %edi,%edi
  800c53:	74 04                	je     800c59 <strtol+0xc5>
  800c55:	89 c8                	mov    %ecx,%eax
  800c57:	f7 d8                	neg    %eax
}
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
	...

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	89 c7                	mov    %eax,%edi
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	ba 00 00 00 00       	mov    $0x0,%edx
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	89 d3                	mov    %edx,%ebx
  800c92:	89 d7                	mov    %edx,%edi
  800c94:	89 d6                	mov    %edx,%esi
  800c96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cab:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 cb                	mov    %ecx,%ebx
  800cb5:	89 cf                	mov    %ecx,%edi
  800cb7:	89 ce                	mov    %ecx,%esi
  800cb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 28                	jle    800ce7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cca:	00 
  800ccb:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800cd2:	00 
  800cd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cda:	00 
  800cdb:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800ce2:	e8 b1 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce7:	83 c4 2c             	add    $0x2c,%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    

00800cef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	89 d3                	mov    %edx,%ebx
  800d03:	89 d7                	mov    %edx,%edi
  800d05:	89 d6                	mov    %edx,%esi
  800d07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_yield>:

void
sys_yield(void)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	ba 00 00 00 00       	mov    $0x0,%edx
  800d19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1e:	89 d1                	mov    %edx,%ecx
  800d20:	89 d3                	mov    %edx,%ebx
  800d22:	89 d7                	mov    %edx,%edi
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800d36:	be 00 00 00 00       	mov    $0x0,%esi
  800d3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 f7                	mov    %esi,%edi
  800d4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800d74:	e8 1f f5 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d79:	83 c4 2c             	add    $0x2c,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da0:	85 c0                	test   %eax,%eax
  800da2:	7e 28                	jle    800dcc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800daf:	00 
  800db0:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800db7:	00 
  800db8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dbf:	00 
  800dc0:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800dc7:	e8 cc f4 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dcc:	83 c4 2c             	add    $0x2c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	57                   	push   %edi
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de2:	b8 06 00 00 00       	mov    $0x6,%eax
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	89 df                	mov    %ebx,%edi
  800def:	89 de                	mov    %ebx,%esi
  800df1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df3:	85 c0                	test   %eax,%eax
  800df5:	7e 28                	jle    800e1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e02:	00 
  800e03:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e12:	00 
  800e13:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800e1a:	e8 79 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e1f:	83 c4 2c             	add    $0x2c,%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e35:	b8 08 00 00 00       	mov    $0x8,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	89 de                	mov    %ebx,%esi
  800e44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7e 28                	jle    800e72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e55:	00 
  800e56:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800e5d:	00 
  800e5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e65:	00 
  800e66:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800e6d:	e8 26 f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e72:	83 c4 2c             	add    $0x2c,%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	57                   	push   %edi
  800e7e:	56                   	push   %esi
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	b8 09 00 00 00       	mov    $0x9,%eax
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	89 df                	mov    %ebx,%edi
  800e95:	89 de                	mov    %ebx,%esi
  800e97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	7e 28                	jle    800ec5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800ec0:	e8 d3 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec5:	83 c4 2c             	add    $0x2c,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800edb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee6:	89 df                	mov    %ebx,%edi
  800ee8:	89 de                	mov    %ebx,%esi
  800eea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eec:	85 c0                	test   %eax,%eax
  800eee:	7e 28                	jle    800f18 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800efb:	00 
  800efc:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800f03:	00 
  800f04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0b:	00 
  800f0c:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800f13:	e8 80 f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f18:	83 c4 2c             	add    $0x2c,%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	57                   	push   %edi
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f56:	8b 55 08             	mov    0x8(%ebp),%edx
  800f59:	89 cb                	mov    %ecx,%ebx
  800f5b:	89 cf                	mov    %ecx,%edi
  800f5d:	89 ce                	mov    %ecx,%esi
  800f5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	7e 28                	jle    800f8d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f65:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f69:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f70:	00 
  800f71:	c7 44 24 08 bf 29 80 	movl   $0x8029bf,0x8(%esp)
  800f78:	00 
  800f79:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f80:	00 
  800f81:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  800f88:	e8 0b f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f8d:	83 c4 2c             	add    $0x2c,%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	00 00                	add    %al,(%eax)
	...

00800f98 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 24             	sub    $0x24,%esp
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fa2:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  800fa4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa8:	75 20                	jne    800fca <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800faa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fae:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  800fb5:	00 
  800fb6:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800fbd:	00 
  800fbe:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  800fc5:	e8 ce f2 ff ff       	call   800298 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800fd5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdc:	f6 c4 08             	test   $0x8,%ah
  800fdf:	75 1c                	jne    800ffd <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800fe1:	c7 44 24 08 1c 2a 80 	movl   $0x802a1c,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  800ff8:	e8 9b f2 ff ff       	call   800298 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  800ffd:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801014:	e8 14 fd ff ff       	call   800d2d <sys_page_alloc>
  801019:	85 c0                	test   %eax,%eax
  80101b:	79 20                	jns    80103d <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  80101d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801021:	c7 44 24 08 77 2a 80 	movl   $0x802a77,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801030:	00 
  801031:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  801038:	e8 5b f2 ff ff       	call   800298 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  80103d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801044:	00 
  801045:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801049:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801050:	e8 5f fa ff ff       	call   800ab4 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801055:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80105c:	00 
  80105d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801061:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801070:	00 
  801071:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801078:	e8 04 fd ff ff       	call   800d81 <sys_page_map>
  80107d:	85 c0                	test   %eax,%eax
  80107f:	79 20                	jns    8010a1 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801085:	c7 44 24 08 8b 2a 80 	movl   $0x802a8b,0x8(%esp)
  80108c:	00 
  80108d:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801094:	00 
  801095:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  80109c:	e8 f7 f1 ff ff       	call   800298 <_panic>

}
  8010a1:	83 c4 24             	add    $0x24,%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  8010b0:	c7 04 24 98 0f 80 00 	movl   $0x800f98,(%esp)
  8010b7:	e8 ec 11 00 00       	call   8022a8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010bc:	ba 07 00 00 00       	mov    $0x7,%edx
  8010c1:	89 d0                	mov    %edx,%eax
  8010c3:	cd 30                	int    $0x30
  8010c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8010c8:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	79 20                	jns    8010ef <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8010cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d3:	c7 44 24 08 9d 2a 80 	movl   $0x802a9d,0x8(%esp)
  8010da:	00 
  8010db:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8010e2:	00 
  8010e3:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  8010ea:	e8 a9 f1 ff ff       	call   800298 <_panic>
	if (child_envid == 0) { // child
  8010ef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010f3:	75 25                	jne    80111a <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8010f5:	e8 f5 fb ff ff       	call   800cef <sys_getenvid>
  8010fa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801106:	c1 e0 07             	shl    $0x7,%eax
  801109:	29 d0                	sub    %edx,%eax
  80110b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801115:	e9 58 02 00 00       	jmp    801372 <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  80111a:	bf 00 00 00 00       	mov    $0x0,%edi
  80111f:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801124:	89 f0                	mov    %esi,%eax
  801126:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801129:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801130:	a8 01                	test   $0x1,%al
  801132:	0f 84 7a 01 00 00    	je     8012b2 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801138:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80113f:	a8 01                	test   $0x1,%al
  801141:	0f 84 6b 01 00 00    	je     8012b2 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  801147:	a1 04 40 80 00       	mov    0x804004,%eax
  80114c:	8b 40 48             	mov    0x48(%eax),%eax
  80114f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801152:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801159:	f6 c4 04             	test   $0x4,%ah
  80115c:	74 52                	je     8011b0 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80115e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801165:	25 07 0e 00 00       	and    $0xe07,%eax
  80116a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801172:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801175:	89 44 24 08          	mov    %eax,0x8(%esp)
  801179:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80117d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801180:	89 04 24             	mov    %eax,(%esp)
  801183:	e8 f9 fb ff ff       	call   800d81 <sys_page_map>
  801188:	85 c0                	test   %eax,%eax
  80118a:	0f 89 22 01 00 00    	jns    8012b2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801190:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801194:	c7 44 24 08 8b 2a 80 	movl   $0x802a8b,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8011a3:	00 
  8011a4:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  8011ab:	e8 e8 f0 ff ff       	call   800298 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8011b0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011b7:	f6 c4 08             	test   $0x8,%ah
  8011ba:	75 0f                	jne    8011cb <fork+0x124>
  8011bc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011c3:	a8 02                	test   $0x2,%al
  8011c5:	0f 84 99 00 00 00    	je     801264 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8011cb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011d2:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8011d5:	83 f8 01             	cmp    $0x1,%eax
  8011d8:	19 db                	sbb    %ebx,%ebx
  8011da:	83 e3 fc             	and    $0xfffffffc,%ebx
  8011dd:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011e3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011f9:	89 04 24             	mov    %eax,(%esp)
  8011fc:	e8 80 fb ff ff       	call   800d81 <sys_page_map>
  801201:	85 c0                	test   %eax,%eax
  801203:	79 20                	jns    801225 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801209:	c7 44 24 08 8b 2a 80 	movl   $0x802a8b,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  801220:	e8 73 f0 ff ff       	call   800298 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801225:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801229:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801230:	89 44 24 08          	mov    %eax,0x8(%esp)
  801234:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801238:	89 04 24             	mov    %eax,(%esp)
  80123b:	e8 41 fb ff ff       	call   800d81 <sys_page_map>
  801240:	85 c0                	test   %eax,%eax
  801242:	79 6e                	jns    8012b2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801244:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801248:	c7 44 24 08 8b 2a 80 	movl   $0x802a8b,0x8(%esp)
  80124f:	00 
  801250:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801257:	00 
  801258:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  80125f:	e8 34 f0 ff ff       	call   800298 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801264:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80126b:	25 07 0e 00 00       	and    $0xe07,%eax
  801270:	89 44 24 10          	mov    %eax,0x10(%esp)
  801274:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801278:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80127b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801286:	89 04 24             	mov    %eax,(%esp)
  801289:	e8 f3 fa ff ff       	call   800d81 <sys_page_map>
  80128e:	85 c0                	test   %eax,%eax
  801290:	79 20                	jns    8012b2 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801292:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801296:	c7 44 24 08 8b 2a 80 	movl   $0x802a8b,0x8(%esp)
  80129d:	00 
  80129e:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8012a5:	00 
  8012a6:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  8012ad:	e8 e6 ef ff ff       	call   800298 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8012b2:	46                   	inc    %esi
  8012b3:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8012b9:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8012bf:	0f 85 5f fe ff ff    	jne    801124 <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8012c5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012cc:	00 
  8012cd:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012d4:	ee 
  8012d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	e8 4d fa ff ff       	call   800d2d <sys_page_alloc>
  8012e0:	85 c0                	test   %eax,%eax
  8012e2:	79 20                	jns    801304 <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  8012e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e8:	c7 44 24 08 77 2a 80 	movl   $0x802a77,0x8(%esp)
  8012ef:	00 
  8012f0:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8012f7:	00 
  8012f8:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  8012ff:	e8 94 ef ff ff       	call   800298 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801304:	c7 44 24 04 1c 23 80 	movl   $0x80231c,0x4(%esp)
  80130b:	00 
  80130c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80130f:	89 04 24             	mov    %eax,(%esp)
  801312:	e8 b6 fb ff ff       	call   800ecd <sys_env_set_pgfault_upcall>
  801317:	85 c0                	test   %eax,%eax
  801319:	79 20                	jns    80133b <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80131b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80131f:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  801326:	00 
  801327:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  80132e:	00 
  80132f:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  801336:	e8 5d ef ff ff       	call   800298 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  80133b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801342:	00 
  801343:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801346:	89 04 24             	mov    %eax,(%esp)
  801349:	e8 d9 fa ff ff       	call   800e27 <sys_env_set_status>
  80134e:	85 c0                	test   %eax,%eax
  801350:	79 20                	jns    801372 <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  801352:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801356:	c7 44 24 08 ae 2a 80 	movl   $0x802aae,0x8(%esp)
  80135d:	00 
  80135e:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801365:	00 
  801366:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  80136d:	e8 26 ef ff ff       	call   800298 <_panic>

	return child_envid;
}
  801372:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801375:	83 c4 3c             	add    $0x3c,%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <sfork>:

// Challenge!
int
sfork(void)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801383:	c7 44 24 08 c6 2a 80 	movl   $0x802ac6,0x8(%esp)
  80138a:	00 
  80138b:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801392:	00 
  801393:	c7 04 24 6c 2a 80 00 	movl   $0x802a6c,(%esp)
  80139a:	e8 f9 ee ff ff       	call   800298 <_panic>
	...

008013a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 10             	sub    $0x10,%esp
  8013a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	75 05                	jne    8013ba <ipc_recv+0x1a>
  8013b5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013ba:	89 04 24             	mov    %eax,(%esp)
  8013bd:	e8 81 fb ff ff       	call   800f43 <sys_ipc_recv>
	if (from_env_store != NULL)
  8013c2:	85 db                	test   %ebx,%ebx
  8013c4:	74 0b                	je     8013d1 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8013c6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013cc:	8b 52 74             	mov    0x74(%edx),%edx
  8013cf:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8013d1:	85 f6                	test   %esi,%esi
  8013d3:	74 0b                	je     8013e0 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8013d5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8013db:	8b 52 78             	mov    0x78(%edx),%edx
  8013de:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	79 16                	jns    8013fa <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8013e4:	85 db                	test   %ebx,%ebx
  8013e6:	74 06                	je     8013ee <ipc_recv+0x4e>
			*from_env_store = 0;
  8013e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8013ee:	85 f6                	test   %esi,%esi
  8013f0:	74 10                	je     801402 <ipc_recv+0x62>
			*perm_store = 0;
  8013f2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8013f8:	eb 08                	jmp    801402 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8013fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8013ff:	8b 40 70             	mov    0x70(%eax),%eax
}
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    

00801409 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	57                   	push   %edi
  80140d:	56                   	push   %esi
  80140e:	53                   	push   %ebx
  80140f:	83 ec 1c             	sub    $0x1c,%esp
  801412:	8b 75 08             	mov    0x8(%ebp),%esi
  801415:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801418:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80141b:	eb 2a                	jmp    801447 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  80141d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801420:	74 20                	je     801442 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  801422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801426:	c7 44 24 08 dc 2a 80 	movl   $0x802adc,0x8(%esp)
  80142d:	00 
  80142e:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801435:	00 
  801436:	c7 04 24 01 2b 80 00 	movl   $0x802b01,(%esp)
  80143d:	e8 56 ee ff ff       	call   800298 <_panic>
		sys_yield();
  801442:	e8 c7 f8 ff ff       	call   800d0e <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  801447:	85 db                	test   %ebx,%ebx
  801449:	75 07                	jne    801452 <ipc_send+0x49>
  80144b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801450:	eb 02                	jmp    801454 <ipc_send+0x4b>
  801452:	89 d8                	mov    %ebx,%eax
  801454:	8b 55 14             	mov    0x14(%ebp),%edx
  801457:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80145b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80145f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801463:	89 34 24             	mov    %esi,(%esp)
  801466:	e8 b5 fa ff ff       	call   800f20 <sys_ipc_try_send>
  80146b:	85 c0                	test   %eax,%eax
  80146d:	78 ae                	js     80141d <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80146f:	83 c4 1c             	add    $0x1c,%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5f                   	pop    %edi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80147e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801483:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80148a:	89 c2                	mov    %eax,%edx
  80148c:	c1 e2 07             	shl    $0x7,%edx
  80148f:	29 ca                	sub    %ecx,%edx
  801491:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801497:	8b 52 50             	mov    0x50(%edx),%edx
  80149a:	39 da                	cmp    %ebx,%edx
  80149c:	75 0f                	jne    8014ad <ipc_find_env+0x36>
			return envs[i].env_id;
  80149e:	c1 e0 07             	shl    $0x7,%eax
  8014a1:	29 c8                	sub    %ecx,%eax
  8014a3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8014a8:	8b 40 40             	mov    0x40(%eax),%eax
  8014ab:	eb 0c                	jmp    8014b9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8014ad:	40                   	inc    %eax
  8014ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014b3:	75 ce                	jne    801483 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8014b5:	66 b8 00 00          	mov    $0x0,%ax
}
  8014b9:	5b                   	pop    %ebx
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8014c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	e8 df ff ff ff       	call   8014bc <fd2num>
  8014dd:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014e2:	c1 e0 0c             	shl    $0xc,%eax
}
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	53                   	push   %ebx
  8014eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014ee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014f3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014f5:	89 c2                	mov    %eax,%edx
  8014f7:	c1 ea 16             	shr    $0x16,%edx
  8014fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801501:	f6 c2 01             	test   $0x1,%dl
  801504:	74 11                	je     801517 <fd_alloc+0x30>
  801506:	89 c2                	mov    %eax,%edx
  801508:	c1 ea 0c             	shr    $0xc,%edx
  80150b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801512:	f6 c2 01             	test   $0x1,%dl
  801515:	75 09                	jne    801520 <fd_alloc+0x39>
			*fd_store = fd;
  801517:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
  80151e:	eb 17                	jmp    801537 <fd_alloc+0x50>
  801520:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801525:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80152a:	75 c7                	jne    8014f3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80152c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801532:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801537:	5b                   	pop    %ebx
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801540:	83 f8 1f             	cmp    $0x1f,%eax
  801543:	77 36                	ja     80157b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801545:	05 00 00 0d 00       	add    $0xd0000,%eax
  80154a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80154d:	89 c2                	mov    %eax,%edx
  80154f:	c1 ea 16             	shr    $0x16,%edx
  801552:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801559:	f6 c2 01             	test   $0x1,%dl
  80155c:	74 24                	je     801582 <fd_lookup+0x48>
  80155e:	89 c2                	mov    %eax,%edx
  801560:	c1 ea 0c             	shr    $0xc,%edx
  801563:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80156a:	f6 c2 01             	test   $0x1,%dl
  80156d:	74 1a                	je     801589 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80156f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801572:	89 02                	mov    %eax,(%edx)
	return 0;
  801574:	b8 00 00 00 00       	mov    $0x0,%eax
  801579:	eb 13                	jmp    80158e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80157b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801580:	eb 0c                	jmp    80158e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801582:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801587:	eb 05                	jmp    80158e <fd_lookup+0x54>
  801589:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80158e:	5d                   	pop    %ebp
  80158f:	c3                   	ret    

00801590 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	53                   	push   %ebx
  801594:	83 ec 14             	sub    $0x14,%esp
  801597:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80159d:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a2:	eb 0e                	jmp    8015b2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015a4:	39 08                	cmp    %ecx,(%eax)
  8015a6:	75 09                	jne    8015b1 <dev_lookup+0x21>
			*dev = devtab[i];
  8015a8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8015af:	eb 33                	jmp    8015e4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015b1:	42                   	inc    %edx
  8015b2:	8b 04 95 8c 2b 80 00 	mov    0x802b8c(,%edx,4),%eax
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	75 e7                	jne    8015a4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8015c2:	8b 40 48             	mov    0x48(%eax),%eax
  8015c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cd:	c7 04 24 0c 2b 80 00 	movl   $0x802b0c,(%esp)
  8015d4:	e8 b7 ed ff ff       	call   800390 <cprintf>
	*dev = 0;
  8015d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015e4:	83 c4 14             	add    $0x14,%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 30             	sub    $0x30,%esp
  8015f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f5:	8a 45 0c             	mov    0xc(%ebp),%al
  8015f8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fb:	89 34 24             	mov    %esi,(%esp)
  8015fe:	e8 b9 fe ff ff       	call   8014bc <fd2num>
  801603:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801606:	89 54 24 04          	mov    %edx,0x4(%esp)
  80160a:	89 04 24             	mov    %eax,(%esp)
  80160d:	e8 28 ff ff ff       	call   80153a <fd_lookup>
  801612:	89 c3                	mov    %eax,%ebx
  801614:	85 c0                	test   %eax,%eax
  801616:	78 05                	js     80161d <fd_close+0x33>
	    || fd != fd2)
  801618:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80161b:	74 0d                	je     80162a <fd_close+0x40>
		return (must_exist ? r : 0);
  80161d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801621:	75 46                	jne    801669 <fd_close+0x7f>
  801623:	bb 00 00 00 00       	mov    $0x0,%ebx
  801628:	eb 3f                	jmp    801669 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801631:	8b 06                	mov    (%esi),%eax
  801633:	89 04 24             	mov    %eax,(%esp)
  801636:	e8 55 ff ff ff       	call   801590 <dev_lookup>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 18                	js     801659 <fd_close+0x6f>
		if (dev->dev_close)
  801641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801644:	8b 40 10             	mov    0x10(%eax),%eax
  801647:	85 c0                	test   %eax,%eax
  801649:	74 09                	je     801654 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80164b:	89 34 24             	mov    %esi,(%esp)
  80164e:	ff d0                	call   *%eax
  801650:	89 c3                	mov    %eax,%ebx
  801652:	eb 05                	jmp    801659 <fd_close+0x6f>
		else
			r = 0;
  801654:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801659:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 6b f7 ff ff       	call   800dd4 <sys_page_unmap>
	return r;
}
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	83 c4 30             	add    $0x30,%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801678:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167f:	8b 45 08             	mov    0x8(%ebp),%eax
  801682:	89 04 24             	mov    %eax,(%esp)
  801685:	e8 b0 fe ff ff       	call   80153a <fd_lookup>
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 13                	js     8016a1 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80168e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801695:	00 
  801696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801699:	89 04 24             	mov    %eax,(%esp)
  80169c:	e8 49 ff ff ff       	call   8015ea <fd_close>
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <close_all>:

void
close_all(void)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016af:	89 1c 24             	mov    %ebx,(%esp)
  8016b2:	e8 bb ff ff ff       	call   801672 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016b7:	43                   	inc    %ebx
  8016b8:	83 fb 20             	cmp    $0x20,%ebx
  8016bb:	75 f2                	jne    8016af <close_all+0xc>
		close(i);
}
  8016bd:	83 c4 14             	add    $0x14,%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	57                   	push   %edi
  8016c7:	56                   	push   %esi
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 4c             	sub    $0x4c,%esp
  8016cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 59 fe ff ff       	call   80153a <fd_lookup>
  8016e1:	89 c3                	mov    %eax,%ebx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	0f 88 e1 00 00 00    	js     8017cc <dup+0x109>
		return r;
	close(newfdnum);
  8016eb:	89 3c 24             	mov    %edi,(%esp)
  8016ee:	e8 7f ff ff ff       	call   801672 <close>

	newfd = INDEX2FD(newfdnum);
  8016f3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016f9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ff:	89 04 24             	mov    %eax,(%esp)
  801702:	e8 c5 fd ff ff       	call   8014cc <fd2data>
  801707:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801709:	89 34 24             	mov    %esi,(%esp)
  80170c:	e8 bb fd ff ff       	call   8014cc <fd2data>
  801711:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801714:	89 d8                	mov    %ebx,%eax
  801716:	c1 e8 16             	shr    $0x16,%eax
  801719:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801720:	a8 01                	test   $0x1,%al
  801722:	74 46                	je     80176a <dup+0xa7>
  801724:	89 d8                	mov    %ebx,%eax
  801726:	c1 e8 0c             	shr    $0xc,%eax
  801729:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801730:	f6 c2 01             	test   $0x1,%dl
  801733:	74 35                	je     80176a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801735:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173c:	25 07 0e 00 00       	and    $0xe07,%eax
  801741:	89 44 24 10          	mov    %eax,0x10(%esp)
  801745:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801748:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80174c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801753:	00 
  801754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801758:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175f:	e8 1d f6 ff ff       	call   800d81 <sys_page_map>
  801764:	89 c3                	mov    %eax,%ebx
  801766:	85 c0                	test   %eax,%eax
  801768:	78 3b                	js     8017a5 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80176a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176d:	89 c2                	mov    %eax,%edx
  80176f:	c1 ea 0c             	shr    $0xc,%edx
  801772:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801779:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80177f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801783:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801787:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178e:	00 
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179a:	e8 e2 f5 ff ff       	call   800d81 <sys_page_map>
  80179f:	89 c3                	mov    %eax,%ebx
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	79 25                	jns    8017ca <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b0:	e8 1f f6 ff ff       	call   800dd4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c3:	e8 0c f6 ff ff       	call   800dd4 <sys_page_unmap>
	return r;
  8017c8:	eb 02                	jmp    8017cc <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017ca:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017cc:	89 d8                	mov    %ebx,%eax
  8017ce:	83 c4 4c             	add    $0x4c,%esp
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5f                   	pop    %edi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 24             	sub    $0x24,%esp
  8017dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e7:	89 1c 24             	mov    %ebx,(%esp)
  8017ea:	e8 4b fd ff ff       	call   80153a <fd_lookup>
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 6d                	js     801860 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fd:	8b 00                	mov    (%eax),%eax
  8017ff:	89 04 24             	mov    %eax,(%esp)
  801802:	e8 89 fd ff ff       	call   801590 <dev_lookup>
  801807:	85 c0                	test   %eax,%eax
  801809:	78 55                	js     801860 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80180b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180e:	8b 50 08             	mov    0x8(%eax),%edx
  801811:	83 e2 03             	and    $0x3,%edx
  801814:	83 fa 01             	cmp    $0x1,%edx
  801817:	75 23                	jne    80183c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801819:	a1 04 40 80 00       	mov    0x804004,%eax
  80181e:	8b 40 48             	mov    0x48(%eax),%eax
  801821:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801830:	e8 5b eb ff ff       	call   800390 <cprintf>
		return -E_INVAL;
  801835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80183a:	eb 24                	jmp    801860 <read+0x8a>
	}
	if (!dev->dev_read)
  80183c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80183f:	8b 52 08             	mov    0x8(%edx),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	74 15                	je     80185b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801846:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801849:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80184d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801850:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801854:	89 04 24             	mov    %eax,(%esp)
  801857:	ff d2                	call   *%edx
  801859:	eb 05                	jmp    801860 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80185b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801860:	83 c4 24             	add    $0x24,%esp
  801863:	5b                   	pop    %ebx
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	57                   	push   %edi
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	83 ec 1c             	sub    $0x1c,%esp
  80186f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801872:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801875:	bb 00 00 00 00       	mov    $0x0,%ebx
  80187a:	eb 23                	jmp    80189f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80187c:	89 f0                	mov    %esi,%eax
  80187e:	29 d8                	sub    %ebx,%eax
  801880:	89 44 24 08          	mov    %eax,0x8(%esp)
  801884:	8b 45 0c             	mov    0xc(%ebp),%eax
  801887:	01 d8                	add    %ebx,%eax
  801889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188d:	89 3c 24             	mov    %edi,(%esp)
  801890:	e8 41 ff ff ff       	call   8017d6 <read>
		if (m < 0)
  801895:	85 c0                	test   %eax,%eax
  801897:	78 10                	js     8018a9 <readn+0x43>
			return m;
		if (m == 0)
  801899:	85 c0                	test   %eax,%eax
  80189b:	74 0a                	je     8018a7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80189d:	01 c3                	add    %eax,%ebx
  80189f:	39 f3                	cmp    %esi,%ebx
  8018a1:	72 d9                	jb     80187c <readn+0x16>
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	eb 02                	jmp    8018a9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018a7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018a9:	83 c4 1c             	add    $0x1c,%esp
  8018ac:	5b                   	pop    %ebx
  8018ad:	5e                   	pop    %esi
  8018ae:	5f                   	pop    %edi
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 24             	sub    $0x24,%esp
  8018b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c2:	89 1c 24             	mov    %ebx,(%esp)
  8018c5:	e8 70 fc ff ff       	call   80153a <fd_lookup>
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 68                	js     801936 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d8:	8b 00                	mov    (%eax),%eax
  8018da:	89 04 24             	mov    %eax,(%esp)
  8018dd:	e8 ae fc ff ff       	call   801590 <dev_lookup>
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 50                	js     801936 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ed:	75 23                	jne    801912 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8018f4:	8b 40 48             	mov    0x48(%eax),%eax
  8018f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ff:	c7 04 24 6c 2b 80 00 	movl   $0x802b6c,(%esp)
  801906:	e8 85 ea ff ff       	call   800390 <cprintf>
		return -E_INVAL;
  80190b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801910:	eb 24                	jmp    801936 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801912:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801915:	8b 52 0c             	mov    0xc(%edx),%edx
  801918:	85 d2                	test   %edx,%edx
  80191a:	74 15                	je     801931 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80191c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80191f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801923:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801926:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80192a:	89 04 24             	mov    %eax,(%esp)
  80192d:	ff d2                	call   *%edx
  80192f:	eb 05                	jmp    801936 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801931:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801936:	83 c4 24             	add    $0x24,%esp
  801939:	5b                   	pop    %ebx
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <seek>:

int
seek(int fdnum, off_t offset)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801942:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801945:	89 44 24 04          	mov    %eax,0x4(%esp)
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 e6 fb ff ff       	call   80153a <fd_lookup>
  801954:	85 c0                	test   %eax,%eax
  801956:	78 0e                	js     801966 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801958:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80195b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 24             	sub    $0x24,%esp
  80196f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801972:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	89 1c 24             	mov    %ebx,(%esp)
  80197c:	e8 b9 fb ff ff       	call   80153a <fd_lookup>
  801981:	85 c0                	test   %eax,%eax
  801983:	78 61                	js     8019e6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801985:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198f:	8b 00                	mov    (%eax),%eax
  801991:	89 04 24             	mov    %eax,(%esp)
  801994:	e8 f7 fb ff ff       	call   801590 <dev_lookup>
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 49                	js     8019e6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80199d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019a4:	75 23                	jne    8019c9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019a6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019ab:	8b 40 48             	mov    0x48(%eax),%eax
  8019ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b6:	c7 04 24 2c 2b 80 00 	movl   $0x802b2c,(%esp)
  8019bd:	e8 ce e9 ff ff       	call   800390 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c7:	eb 1d                	jmp    8019e6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019cc:	8b 52 18             	mov    0x18(%edx),%edx
  8019cf:	85 d2                	test   %edx,%edx
  8019d1:	74 0e                	je     8019e1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019da:	89 04 24             	mov    %eax,(%esp)
  8019dd:	ff d2                	call   *%edx
  8019df:	eb 05                	jmp    8019e6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019e6:	83 c4 24             	add    $0x24,%esp
  8019e9:	5b                   	pop    %ebx
  8019ea:	5d                   	pop    %ebp
  8019eb:	c3                   	ret    

008019ec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	53                   	push   %ebx
  8019f0:	83 ec 24             	sub    $0x24,%esp
  8019f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	89 04 24             	mov    %eax,(%esp)
  801a03:	e8 32 fb ff ff       	call   80153a <fd_lookup>
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 52                	js     801a5e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a16:	8b 00                	mov    (%eax),%eax
  801a18:	89 04 24             	mov    %eax,(%esp)
  801a1b:	e8 70 fb ff ff       	call   801590 <dev_lookup>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 3a                	js     801a5e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a27:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a2b:	74 2c                	je     801a59 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a2d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a30:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a37:	00 00 00 
	stat->st_isdir = 0;
  801a3a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a41:	00 00 00 
	stat->st_dev = dev;
  801a44:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a51:	89 14 24             	mov    %edx,(%esp)
  801a54:	ff 50 14             	call   *0x14(%eax)
  801a57:	eb 05                	jmp    801a5e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a59:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a5e:	83 c4 24             	add    $0x24,%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	56                   	push   %esi
  801a68:	53                   	push   %ebx
  801a69:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a73:	00 
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	89 04 24             	mov    %eax,(%esp)
  801a7a:	e8 2d 02 00 00       	call   801cac <open>
  801a7f:	89 c3                	mov    %eax,%ebx
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 1b                	js     801aa0 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	89 1c 24             	mov    %ebx,(%esp)
  801a8f:	e8 58 ff ff ff       	call   8019ec <fstat>
  801a94:	89 c6                	mov    %eax,%esi
	close(fd);
  801a96:	89 1c 24             	mov    %ebx,(%esp)
  801a99:	e8 d4 fb ff ff       	call   801672 <close>
	return r;
  801a9e:	89 f3                	mov    %esi,%ebx
}
  801aa0:	89 d8                	mov    %ebx,%eax
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5d                   	pop    %ebp
  801aa8:	c3                   	ret    
  801aa9:	00 00                	add    %al,(%eax)
	...

00801aac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	56                   	push   %esi
  801ab0:	53                   	push   %ebx
  801ab1:	83 ec 10             	sub    $0x10,%esp
  801ab4:	89 c3                	mov    %eax,%ebx
  801ab6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ab8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801abf:	75 11                	jne    801ad2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ac1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ac8:	e8 aa f9 ff ff       	call   801477 <ipc_find_env>
  801acd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ad2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ad9:	00 
  801ada:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801ae1:	00 
  801ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae6:	a1 00 40 80 00       	mov    0x804000,%eax
  801aeb:	89 04 24             	mov    %eax,(%esp)
  801aee:	e8 16 f9 ff ff       	call   801409 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801af3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801afa:	00 
  801afb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b06:	e8 95 f8 ff ff       	call   8013a0 <ipc_recv>
}
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b26:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b30:	b8 02 00 00 00       	mov    $0x2,%eax
  801b35:	e8 72 ff ff ff       	call   801aac <fsipc>
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	8b 40 0c             	mov    0xc(%eax),%eax
  801b48:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b52:	b8 06 00 00 00       	mov    $0x6,%eax
  801b57:	e8 50 ff ff ff       	call   801aac <fsipc>
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	83 ec 14             	sub    $0x14,%esp
  801b65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b68:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6b:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	b8 05 00 00 00       	mov    $0x5,%eax
  801b7d:	e8 2a ff ff ff       	call   801aac <fsipc>
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 2b                	js     801bb1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b86:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b8d:	00 
  801b8e:	89 1c 24             	mov    %ebx,(%esp)
  801b91:	e8 a5 ed ff ff       	call   80093b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b96:	a1 80 50 80 00       	mov    0x805080,%eax
  801b9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ba1:	a1 84 50 80 00       	mov    0x805084,%eax
  801ba6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bb1:	83 c4 14             	add    $0x14,%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    

00801bb7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	83 ec 18             	sub    $0x18,%esp
  801bbd:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc0:	89 d0                	mov    %edx,%eax
  801bc2:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801bc8:	76 05                	jbe    801bcf <devfile_write+0x18>
  801bca:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  801bd2:	8b 52 0c             	mov    0xc(%edx),%edx
  801bd5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801bdb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801be0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801beb:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bf2:	e8 bd ee ff ff       	call   800ab4 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfc:	b8 04 00 00 00       	mov    $0x4,%eax
  801c01:	e8 a6 fe ff ff       	call   801aac <fsipc>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 10             	sub    $0x10,%esp
  801c10:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	8b 40 0c             	mov    0xc(%eax),%eax
  801c19:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801c1e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c24:	ba 00 00 00 00       	mov    $0x0,%edx
  801c29:	b8 03 00 00 00       	mov    $0x3,%eax
  801c2e:	e8 79 fe ff ff       	call   801aac <fsipc>
  801c33:	89 c3                	mov    %eax,%ebx
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 6a                	js     801ca3 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 24                	jae    801c61 <devfile_read+0x59>
  801c3d:	c7 44 24 0c 9c 2b 80 	movl   $0x802b9c,0xc(%esp)
  801c44:	00 
  801c45:	c7 44 24 08 a3 2b 80 	movl   $0x802ba3,0x8(%esp)
  801c4c:	00 
  801c4d:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c54:	00 
  801c55:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  801c5c:	e8 37 e6 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  801c61:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c66:	7e 24                	jle    801c8c <devfile_read+0x84>
  801c68:	c7 44 24 0c c3 2b 80 	movl   $0x802bc3,0xc(%esp)
  801c6f:	00 
  801c70:	c7 44 24 08 a3 2b 80 	movl   $0x802ba3,0x8(%esp)
  801c77:	00 
  801c78:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c7f:	00 
  801c80:	c7 04 24 b8 2b 80 00 	movl   $0x802bb8,(%esp)
  801c87:	e8 0c e6 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c90:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c97:	00 
  801c98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 11 ee ff ff       	call   800ab4 <memmove>
	return r;
}
  801ca3:	89 d8                	mov    %ebx,%eax
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	5b                   	pop    %ebx
  801ca9:	5e                   	pop    %esi
  801caa:	5d                   	pop    %ebp
  801cab:	c3                   	ret    

00801cac <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	56                   	push   %esi
  801cb0:	53                   	push   %ebx
  801cb1:	83 ec 20             	sub    $0x20,%esp
  801cb4:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cb7:	89 34 24             	mov    %esi,(%esp)
  801cba:	e8 49 ec ff ff       	call   800908 <strlen>
  801cbf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cc4:	7f 60                	jg     801d26 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc9:	89 04 24             	mov    %eax,(%esp)
  801ccc:	e8 16 f8 ff ff       	call   8014e7 <fd_alloc>
  801cd1:	89 c3                	mov    %eax,%ebx
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 54                	js     801d2b <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cd7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cdb:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ce2:	e8 54 ec ff ff       	call   80093b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cea:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf7:	e8 b0 fd ff ff       	call   801aac <fsipc>
  801cfc:	89 c3                	mov    %eax,%ebx
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	79 15                	jns    801d17 <open+0x6b>
		fd_close(fd, 0);
  801d02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d09:	00 
  801d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0d:	89 04 24             	mov    %eax,(%esp)
  801d10:	e8 d5 f8 ff ff       	call   8015ea <fd_close>
		return r;
  801d15:	eb 14                	jmp    801d2b <open+0x7f>
	}

	return fd2num(fd);
  801d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1a:	89 04 24             	mov    %eax,(%esp)
  801d1d:	e8 9a f7 ff ff       	call   8014bc <fd2num>
  801d22:	89 c3                	mov    %eax,%ebx
  801d24:	eb 05                	jmp    801d2b <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d26:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	83 c4 20             	add    $0x20,%esp
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3f:	b8 08 00 00 00       	mov    $0x8,%eax
  801d44:	e8 63 fd ff ff       	call   801aac <fsipc>
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    
	...

00801d4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d52:	89 c2                	mov    %eax,%edx
  801d54:	c1 ea 16             	shr    $0x16,%edx
  801d57:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d5e:	f6 c2 01             	test   $0x1,%dl
  801d61:	74 1e                	je     801d81 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d63:	c1 e8 0c             	shr    $0xc,%eax
  801d66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d6d:	a8 01                	test   $0x1,%al
  801d6f:	74 17                	je     801d88 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d71:	c1 e8 0c             	shr    $0xc,%eax
  801d74:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d7b:	ef 
  801d7c:	0f b7 c0             	movzwl %ax,%eax
  801d7f:	eb 0c                	jmp    801d8d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d81:	b8 00 00 00 00       	mov    $0x0,%eax
  801d86:	eb 05                	jmp    801d8d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    
	...

00801d90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	56                   	push   %esi
  801d94:	53                   	push   %ebx
  801d95:	83 ec 10             	sub    $0x10,%esp
  801d98:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	89 04 24             	mov    %eax,(%esp)
  801da1:	e8 26 f7 ff ff       	call   8014cc <fd2data>
  801da6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801da8:	c7 44 24 04 cf 2b 80 	movl   $0x802bcf,0x4(%esp)
  801daf:	00 
  801db0:	89 34 24             	mov    %esi,(%esp)
  801db3:	e8 83 eb ff ff       	call   80093b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801db8:	8b 43 04             	mov    0x4(%ebx),%eax
  801dbb:	2b 03                	sub    (%ebx),%eax
  801dbd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801dc3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801dca:	00 00 00 
	stat->st_dev = &devpipe;
  801dcd:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801dd4:	30 80 00 
	return 0;
}
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	5b                   	pop    %ebx
  801de0:	5e                   	pop    %esi
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	53                   	push   %ebx
  801de7:	83 ec 14             	sub    $0x14,%esp
  801dea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ded:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801df1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801df8:	e8 d7 ef ff ff       	call   800dd4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dfd:	89 1c 24             	mov    %ebx,(%esp)
  801e00:	e8 c7 f6 ff ff       	call   8014cc <fd2data>
  801e05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e10:	e8 bf ef ff ff       	call   800dd4 <sys_page_unmap>
}
  801e15:	83 c4 14             	add    $0x14,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	57                   	push   %edi
  801e1f:	56                   	push   %esi
  801e20:	53                   	push   %ebx
  801e21:	83 ec 2c             	sub    $0x2c,%esp
  801e24:	89 c7                	mov    %eax,%edi
  801e26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e29:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e31:	89 3c 24             	mov    %edi,(%esp)
  801e34:	e8 13 ff ff ff       	call   801d4c <pageref>
  801e39:	89 c6                	mov    %eax,%esi
  801e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e3e:	89 04 24             	mov    %eax,(%esp)
  801e41:	e8 06 ff ff ff       	call   801d4c <pageref>
  801e46:	39 c6                	cmp    %eax,%esi
  801e48:	0f 94 c0             	sete   %al
  801e4b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e4e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e54:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e57:	39 cb                	cmp    %ecx,%ebx
  801e59:	75 08                	jne    801e63 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e5b:	83 c4 2c             	add    $0x2c,%esp
  801e5e:	5b                   	pop    %ebx
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e63:	83 f8 01             	cmp    $0x1,%eax
  801e66:	75 c1                	jne    801e29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e68:	8b 42 58             	mov    0x58(%edx),%eax
  801e6b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801e72:	00 
  801e73:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e7b:	c7 04 24 d6 2b 80 00 	movl   $0x802bd6,(%esp)
  801e82:	e8 09 e5 ff ff       	call   800390 <cprintf>
  801e87:	eb a0                	jmp    801e29 <_pipeisclosed+0xe>

00801e89 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	57                   	push   %edi
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	83 ec 1c             	sub    $0x1c,%esp
  801e92:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e95:	89 34 24             	mov    %esi,(%esp)
  801e98:	e8 2f f6 ff ff       	call   8014cc <fd2data>
  801e9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e9f:	bf 00 00 00 00       	mov    $0x0,%edi
  801ea4:	eb 3c                	jmp    801ee2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ea6:	89 da                	mov    %ebx,%edx
  801ea8:	89 f0                	mov    %esi,%eax
  801eaa:	e8 6c ff ff ff       	call   801e1b <_pipeisclosed>
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	75 38                	jne    801eeb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801eb3:	e8 56 ee ff ff       	call   800d0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801eb8:	8b 43 04             	mov    0x4(%ebx),%eax
  801ebb:	8b 13                	mov    (%ebx),%edx
  801ebd:	83 c2 20             	add    $0x20,%edx
  801ec0:	39 d0                	cmp    %edx,%eax
  801ec2:	73 e2                	jae    801ea6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ec4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801eca:	89 c2                	mov    %eax,%edx
  801ecc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ed2:	79 05                	jns    801ed9 <devpipe_write+0x50>
  801ed4:	4a                   	dec    %edx
  801ed5:	83 ca e0             	or     $0xffffffe0,%edx
  801ed8:	42                   	inc    %edx
  801ed9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801edd:	40                   	inc    %eax
  801ede:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee1:	47                   	inc    %edi
  801ee2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ee5:	75 d1                	jne    801eb8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ee7:	89 f8                	mov    %edi,%eax
  801ee9:	eb 05                	jmp    801ef0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ef0:	83 c4 1c             	add    $0x1c,%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	57                   	push   %edi
  801efc:	56                   	push   %esi
  801efd:	53                   	push   %ebx
  801efe:	83 ec 1c             	sub    $0x1c,%esp
  801f01:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f04:	89 3c 24             	mov    %edi,(%esp)
  801f07:	e8 c0 f5 ff ff       	call   8014cc <fd2data>
  801f0c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f0e:	be 00 00 00 00       	mov    $0x0,%esi
  801f13:	eb 3a                	jmp    801f4f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f15:	85 f6                	test   %esi,%esi
  801f17:	74 04                	je     801f1d <devpipe_read+0x25>
				return i;
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	eb 40                	jmp    801f5d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f1d:	89 da                	mov    %ebx,%edx
  801f1f:	89 f8                	mov    %edi,%eax
  801f21:	e8 f5 fe ff ff       	call   801e1b <_pipeisclosed>
  801f26:	85 c0                	test   %eax,%eax
  801f28:	75 2e                	jne    801f58 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f2a:	e8 df ed ff ff       	call   800d0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f2f:	8b 03                	mov    (%ebx),%eax
  801f31:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f34:	74 df                	je     801f15 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f36:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f3b:	79 05                	jns    801f42 <devpipe_read+0x4a>
  801f3d:	48                   	dec    %eax
  801f3e:	83 c8 e0             	or     $0xffffffe0,%eax
  801f41:	40                   	inc    %eax
  801f42:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f46:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f49:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f4c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f4e:	46                   	inc    %esi
  801f4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f52:	75 db                	jne    801f2f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f54:	89 f0                	mov    %esi,%eax
  801f56:	eb 05                	jmp    801f5d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f5d:	83 c4 1c             	add    $0x1c,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5f                   	pop    %edi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    

00801f65 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	57                   	push   %edi
  801f69:	56                   	push   %esi
  801f6a:	53                   	push   %ebx
  801f6b:	83 ec 3c             	sub    $0x3c,%esp
  801f6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	e8 6b f5 ff ff       	call   8014e7 <fd_alloc>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	0f 88 45 01 00 00    	js     8020cb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f86:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f8d:	00 
  801f8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f91:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f9c:	e8 8c ed ff ff       	call   800d2d <sys_page_alloc>
  801fa1:	89 c3                	mov    %eax,%ebx
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	0f 88 20 01 00 00    	js     8020cb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fab:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 31 f5 ff ff       	call   8014e7 <fd_alloc>
  801fb6:	89 c3                	mov    %eax,%ebx
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	0f 88 f8 00 00 00    	js     8020b8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fc0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fc7:	00 
  801fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd6:	e8 52 ed ff ff       	call   800d2d <sys_page_alloc>
  801fdb:	89 c3                	mov    %eax,%ebx
  801fdd:	85 c0                	test   %eax,%eax
  801fdf:	0f 88 d3 00 00 00    	js     8020b8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801fe5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fe8:	89 04 24             	mov    %eax,(%esp)
  801feb:	e8 dc f4 ff ff       	call   8014cc <fd2data>
  801ff0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ff2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ff9:	00 
  801ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802005:	e8 23 ed ff ff       	call   800d2d <sys_page_alloc>
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	85 c0                	test   %eax,%eax
  80200e:	0f 88 91 00 00 00    	js     8020a5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802014:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802017:	89 04 24             	mov    %eax,(%esp)
  80201a:	e8 ad f4 ff ff       	call   8014cc <fd2data>
  80201f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802026:	00 
  802027:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802032:	00 
  802033:	89 74 24 04          	mov    %esi,0x4(%esp)
  802037:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203e:	e8 3e ed ff ff       	call   800d81 <sys_page_map>
  802043:	89 c3                	mov    %eax,%ebx
  802045:	85 c0                	test   %eax,%eax
  802047:	78 4c                	js     802095 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802049:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80204f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802052:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802054:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802057:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80205e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802064:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802067:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802069:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80206c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802076:	89 04 24             	mov    %eax,(%esp)
  802079:	e8 3e f4 ff ff       	call   8014bc <fd2num>
  80207e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802080:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802083:	89 04 24             	mov    %eax,(%esp)
  802086:	e8 31 f4 ff ff       	call   8014bc <fd2num>
  80208b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80208e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802093:	eb 36                	jmp    8020cb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802095:	89 74 24 04          	mov    %esi,0x4(%esp)
  802099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a0:	e8 2f ed ff ff       	call   800dd4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b3:	e8 1c ed ff ff       	call   800dd4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c6:	e8 09 ed ff ff       	call   800dd4 <sys_page_unmap>
    err:
	return r;
}
  8020cb:	89 d8                	mov    %ebx,%eax
  8020cd:	83 c4 3c             	add    $0x3c,%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    

008020d5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 4d f4 ff ff       	call   80153a <fd_lookup>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 15                	js     802106 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8020f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f4:	89 04 24             	mov    %eax,(%esp)
  8020f7:	e8 d0 f3 ff ff       	call   8014cc <fd2data>
	return _pipeisclosed(fd, p);
  8020fc:	89 c2                	mov    %eax,%edx
  8020fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802101:	e8 15 fd ff ff       	call   801e1b <_pipeisclosed>
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80210b:	b8 00 00 00 00       	mov    $0x0,%eax
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    

00802112 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802118:	c7 44 24 04 ee 2b 80 	movl   $0x802bee,0x4(%esp)
  80211f:	00 
  802120:	8b 45 0c             	mov    0xc(%ebp),%eax
  802123:	89 04 24             	mov    %eax,(%esp)
  802126:	e8 10 e8 ff ff       	call   80093b <strcpy>
	return 0;
}
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802143:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802149:	eb 30                	jmp    80217b <devcons_write+0x49>
		m = n - tot;
  80214b:	8b 75 10             	mov    0x10(%ebp),%esi
  80214e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802150:	83 fe 7f             	cmp    $0x7f,%esi
  802153:	76 05                	jbe    80215a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802155:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80215a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80215e:	03 45 0c             	add    0xc(%ebp),%eax
  802161:	89 44 24 04          	mov    %eax,0x4(%esp)
  802165:	89 3c 24             	mov    %edi,(%esp)
  802168:	e8 47 e9 ff ff       	call   800ab4 <memmove>
		sys_cputs(buf, m);
  80216d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802171:	89 3c 24             	mov    %edi,(%esp)
  802174:	e8 e7 ea ff ff       	call   800c60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802179:	01 f3                	add    %esi,%ebx
  80217b:	89 d8                	mov    %ebx,%eax
  80217d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802180:	72 c9                	jb     80214b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802182:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    

0080218d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802193:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802197:	75 07                	jne    8021a0 <devcons_read+0x13>
  802199:	eb 25                	jmp    8021c0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80219b:	e8 6e eb ff ff       	call   800d0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021a0:	e8 d9 ea ff ff       	call   800c7e <sys_cgetc>
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	74 f2                	je     80219b <devcons_read+0xe>
  8021a9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	78 1d                	js     8021cc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021af:	83 f8 04             	cmp    $0x4,%eax
  8021b2:	74 13                	je     8021c7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b7:	88 10                	mov    %dl,(%eax)
	return 1;
  8021b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021be:	eb 0c                	jmp    8021cc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c5:	eb 05                	jmp    8021cc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021cc:	c9                   	leave  
  8021cd:	c3                   	ret    

008021ce <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021e1:	00 
  8021e2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021e5:	89 04 24             	mov    %eax,(%esp)
  8021e8:	e8 73 ea ff ff       	call   800c60 <sys_cputs>
}
  8021ed:	c9                   	leave  
  8021ee:	c3                   	ret    

008021ef <getchar>:

int
getchar(void)
{
  8021ef:	55                   	push   %ebp
  8021f0:	89 e5                	mov    %esp,%ebp
  8021f2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021f5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021fc:	00 
  8021fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802200:	89 44 24 04          	mov    %eax,0x4(%esp)
  802204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80220b:	e8 c6 f5 ff ff       	call   8017d6 <read>
	if (r < 0)
  802210:	85 c0                	test   %eax,%eax
  802212:	78 0f                	js     802223 <getchar+0x34>
		return r;
	if (r < 1)
  802214:	85 c0                	test   %eax,%eax
  802216:	7e 06                	jle    80221e <getchar+0x2f>
		return -E_EOF;
	return c;
  802218:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80221c:	eb 05                	jmp    802223 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80221e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80222b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802232:	8b 45 08             	mov    0x8(%ebp),%eax
  802235:	89 04 24             	mov    %eax,(%esp)
  802238:	e8 fd f2 ff ff       	call   80153a <fd_lookup>
  80223d:	85 c0                	test   %eax,%eax
  80223f:	78 11                	js     802252 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802244:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80224a:	39 10                	cmp    %edx,(%eax)
  80224c:	0f 94 c0             	sete   %al
  80224f:	0f b6 c0             	movzbl %al,%eax
}
  802252:	c9                   	leave  
  802253:	c3                   	ret    

00802254 <opencons>:

int
opencons(void)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
  802257:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80225a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80225d:	89 04 24             	mov    %eax,(%esp)
  802260:	e8 82 f2 ff ff       	call   8014e7 <fd_alloc>
  802265:	85 c0                	test   %eax,%eax
  802267:	78 3c                	js     8022a5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802269:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802270:	00 
  802271:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802274:	89 44 24 04          	mov    %eax,0x4(%esp)
  802278:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227f:	e8 a9 ea ff ff       	call   800d2d <sys_page_alloc>
  802284:	85 c0                	test   %eax,%eax
  802286:	78 1d                	js     8022a5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802288:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80228e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802291:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802293:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802296:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80229d:	89 04 24             	mov    %eax,(%esp)
  8022a0:	e8 17 f2 ff ff       	call   8014bc <fd2num>
}
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    
	...

008022a8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022a8:	55                   	push   %ebp
  8022a9:	89 e5                	mov    %esp,%ebp
  8022ab:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022ae:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022b5:	75 58                	jne    80230f <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8022b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022bc:	8b 40 48             	mov    0x48(%eax),%eax
  8022bf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022c6:	00 
  8022c7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8022ce:	ee 
  8022cf:	89 04 24             	mov    %eax,(%esp)
  8022d2:	e8 56 ea ff ff       	call   800d2d <sys_page_alloc>
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	74 1c                	je     8022f7 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8022db:	c7 44 24 08 fa 2b 80 	movl   $0x802bfa,0x8(%esp)
  8022e2:	00 
  8022e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8022ea:	00 
  8022eb:	c7 04 24 0f 2c 80 00 	movl   $0x802c0f,(%esp)
  8022f2:	e8 a1 df ff ff       	call   800298 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8022f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8022fc:	8b 40 48             	mov    0x48(%eax),%eax
  8022ff:	c7 44 24 04 1c 23 80 	movl   $0x80231c,0x4(%esp)
  802306:	00 
  802307:	89 04 24             	mov    %eax,(%esp)
  80230a:	e8 be eb ff ff       	call   800ecd <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80230f:	8b 45 08             	mov    0x8(%ebp),%eax
  802312:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802317:	c9                   	leave  
  802318:	c3                   	ret    
  802319:	00 00                	add    %al,(%eax)
	...

0080231c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80231c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80231d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802322:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802324:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  802327:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80232b:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  80232d:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802331:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802332:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802335:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  802337:	58                   	pop    %eax
	popl %eax
  802338:	58                   	pop    %eax

	// Pop all registers back
	popal
  802339:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80233a:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  80233d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80233e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80233f:	c3                   	ret    

00802340 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	83 ec 10             	sub    $0x10,%esp
  802346:	8b 74 24 20          	mov    0x20(%esp),%esi
  80234a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80234e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802352:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802356:	89 cd                	mov    %ecx,%ebp
  802358:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80235c:	85 c0                	test   %eax,%eax
  80235e:	75 2c                	jne    80238c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802360:	39 f9                	cmp    %edi,%ecx
  802362:	77 68                	ja     8023cc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802364:	85 c9                	test   %ecx,%ecx
  802366:	75 0b                	jne    802373 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802368:	b8 01 00 00 00       	mov    $0x1,%eax
  80236d:	31 d2                	xor    %edx,%edx
  80236f:	f7 f1                	div    %ecx
  802371:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802373:	31 d2                	xor    %edx,%edx
  802375:	89 f8                	mov    %edi,%eax
  802377:	f7 f1                	div    %ecx
  802379:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80237b:	89 f0                	mov    %esi,%eax
  80237d:	f7 f1                	div    %ecx
  80237f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802381:	89 f0                	mov    %esi,%eax
  802383:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802385:	83 c4 10             	add    $0x10,%esp
  802388:	5e                   	pop    %esi
  802389:	5f                   	pop    %edi
  80238a:	5d                   	pop    %ebp
  80238b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80238c:	39 f8                	cmp    %edi,%eax
  80238e:	77 2c                	ja     8023bc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802390:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802393:	83 f6 1f             	xor    $0x1f,%esi
  802396:	75 4c                	jne    8023e4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802398:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80239a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80239f:	72 0a                	jb     8023ab <__udivdi3+0x6b>
  8023a1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8023a5:	0f 87 ad 00 00 00    	ja     802458 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8023ab:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023b0:	89 f0                	mov    %esi,%eax
  8023b2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023b4:	83 c4 10             	add    $0x10,%esp
  8023b7:	5e                   	pop    %esi
  8023b8:	5f                   	pop    %edi
  8023b9:	5d                   	pop    %ebp
  8023ba:	c3                   	ret    
  8023bb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023bc:	31 ff                	xor    %edi,%edi
  8023be:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023c0:	89 f0                	mov    %esi,%eax
  8023c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023c4:	83 c4 10             	add    $0x10,%esp
  8023c7:	5e                   	pop    %esi
  8023c8:	5f                   	pop    %edi
  8023c9:	5d                   	pop    %ebp
  8023ca:	c3                   	ret    
  8023cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023cc:	89 fa                	mov    %edi,%edx
  8023ce:	89 f0                	mov    %esi,%eax
  8023d0:	f7 f1                	div    %ecx
  8023d2:	89 c6                	mov    %eax,%esi
  8023d4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8023d6:	89 f0                	mov    %esi,%eax
  8023d8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8023da:	83 c4 10             	add    $0x10,%esp
  8023dd:	5e                   	pop    %esi
  8023de:	5f                   	pop    %edi
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    
  8023e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023e4:	89 f1                	mov    %esi,%ecx
  8023e6:	d3 e0                	shl    %cl,%eax
  8023e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8023f1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8023f3:	89 ea                	mov    %ebp,%edx
  8023f5:	88 c1                	mov    %al,%cl
  8023f7:	d3 ea                	shr    %cl,%edx
  8023f9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023fd:	09 ca                	or     %ecx,%edx
  8023ff:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802403:	89 f1                	mov    %esi,%ecx
  802405:	d3 e5                	shl    %cl,%ebp
  802407:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80240b:	89 fd                	mov    %edi,%ebp
  80240d:	88 c1                	mov    %al,%cl
  80240f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802411:	89 fa                	mov    %edi,%edx
  802413:	89 f1                	mov    %esi,%ecx
  802415:	d3 e2                	shl    %cl,%edx
  802417:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80241b:	88 c1                	mov    %al,%cl
  80241d:	d3 ef                	shr    %cl,%edi
  80241f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802421:	89 f8                	mov    %edi,%eax
  802423:	89 ea                	mov    %ebp,%edx
  802425:	f7 74 24 08          	divl   0x8(%esp)
  802429:	89 d1                	mov    %edx,%ecx
  80242b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80242d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802431:	39 d1                	cmp    %edx,%ecx
  802433:	72 17                	jb     80244c <__udivdi3+0x10c>
  802435:	74 09                	je     802440 <__udivdi3+0x100>
  802437:	89 fe                	mov    %edi,%esi
  802439:	31 ff                	xor    %edi,%edi
  80243b:	e9 41 ff ff ff       	jmp    802381 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802440:	8b 54 24 04          	mov    0x4(%esp),%edx
  802444:	89 f1                	mov    %esi,%ecx
  802446:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802448:	39 c2                	cmp    %eax,%edx
  80244a:	73 eb                	jae    802437 <__udivdi3+0xf7>
		{
		  q0--;
  80244c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80244f:	31 ff                	xor    %edi,%edi
  802451:	e9 2b ff ff ff       	jmp    802381 <__udivdi3+0x41>
  802456:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802458:	31 f6                	xor    %esi,%esi
  80245a:	e9 22 ff ff ff       	jmp    802381 <__udivdi3+0x41>
	...

00802460 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 20             	sub    $0x20,%esp
  802466:	8b 44 24 30          	mov    0x30(%esp),%eax
  80246a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80246e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802472:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802476:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80247a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80247e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802480:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802482:	85 ed                	test   %ebp,%ebp
  802484:	75 16                	jne    80249c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802486:	39 f1                	cmp    %esi,%ecx
  802488:	0f 86 a6 00 00 00    	jbe    802534 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80248e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802490:	89 d0                	mov    %edx,%eax
  802492:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802494:	83 c4 20             	add    $0x20,%esp
  802497:	5e                   	pop    %esi
  802498:	5f                   	pop    %edi
  802499:	5d                   	pop    %ebp
  80249a:	c3                   	ret    
  80249b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80249c:	39 f5                	cmp    %esi,%ebp
  80249e:	0f 87 ac 00 00 00    	ja     802550 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024a4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8024a7:	83 f0 1f             	xor    $0x1f,%eax
  8024aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8024ae:	0f 84 a8 00 00 00    	je     80255c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024b4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024b8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024ba:	bf 20 00 00 00       	mov    $0x20,%edi
  8024bf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8024c3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024c7:	89 f9                	mov    %edi,%ecx
  8024c9:	d3 e8                	shr    %cl,%eax
  8024cb:	09 e8                	or     %ebp,%eax
  8024cd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8024d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024d5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d9:	d3 e0                	shl    %cl,%eax
  8024db:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8024df:	89 f2                	mov    %esi,%edx
  8024e1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8024e3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024e7:	d3 e0                	shl    %cl,%eax
  8024e9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8024ed:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e8                	shr    %cl,%eax
  8024f5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8024f7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024f9:	89 f2                	mov    %esi,%edx
  8024fb:	f7 74 24 18          	divl   0x18(%esp)
  8024ff:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802501:	f7 64 24 0c          	mull   0xc(%esp)
  802505:	89 c5                	mov    %eax,%ebp
  802507:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802509:	39 d6                	cmp    %edx,%esi
  80250b:	72 67                	jb     802574 <__umoddi3+0x114>
  80250d:	74 75                	je     802584 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80250f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802513:	29 e8                	sub    %ebp,%eax
  802515:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802517:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	89 f2                	mov    %esi,%edx
  80251f:	89 f9                	mov    %edi,%ecx
  802521:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802523:	09 d0                	or     %edx,%eax
  802525:	89 f2                	mov    %esi,%edx
  802527:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80252b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80252d:	83 c4 20             	add    $0x20,%esp
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802534:	85 c9                	test   %ecx,%ecx
  802536:	75 0b                	jne    802543 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802538:	b8 01 00 00 00       	mov    $0x1,%eax
  80253d:	31 d2                	xor    %edx,%edx
  80253f:	f7 f1                	div    %ecx
  802541:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802543:	89 f0                	mov    %esi,%eax
  802545:	31 d2                	xor    %edx,%edx
  802547:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802549:	89 f8                	mov    %edi,%eax
  80254b:	e9 3e ff ff ff       	jmp    80248e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802550:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802552:	83 c4 20             	add    $0x20,%esp
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    
  802559:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80255c:	39 f5                	cmp    %esi,%ebp
  80255e:	72 04                	jb     802564 <__umoddi3+0x104>
  802560:	39 f9                	cmp    %edi,%ecx
  802562:	77 06                	ja     80256a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802564:	89 f2                	mov    %esi,%edx
  802566:	29 cf                	sub    %ecx,%edi
  802568:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80256a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80256c:	83 c4 20             	add    $0x20,%esp
  80256f:	5e                   	pop    %esi
  802570:	5f                   	pop    %edi
  802571:	5d                   	pop    %ebp
  802572:	c3                   	ret    
  802573:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802574:	89 d1                	mov    %edx,%ecx
  802576:	89 c5                	mov    %eax,%ebp
  802578:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80257c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802580:	eb 8d                	jmp    80250f <__umoddi3+0xaf>
  802582:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802584:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802588:	72 ea                	jb     802574 <__umoddi3+0x114>
  80258a:	89 f1                	mov    %esi,%ecx
  80258c:	eb 81                	jmp    80250f <__umoddi3+0xaf>
