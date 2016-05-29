
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 e7 02 00 00       	call   800318 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 c4 80             	add    $0xffffff80,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003c:	c7 05 04 30 80 00 00 	movl   $0x802700,0x803004
  800043:	27 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 9c 1e 00 00       	call   801eed <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 0c 27 80 	movl   $0x80270c,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  800072:	e8 09 03 00 00       	call   800380 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 13 11 00 00       	call   80118f <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 25 27 80 	movl   $0x802725,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  80009d:	e8 de 02 00 00       	call   800380 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d5 00 00 00    	jne    80017f <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 2e 27 80 00 	movl   $0x80272e,(%esp)
  8000c4:	e8 af 03 00 00       	call   800478 <cprintf>
		close(p[1]);
  8000c9:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 6a 15 00 00       	call   80163e <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d9:	8b 40 48             	mov    0x48(%eax),%eax
  8000dc:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e7:	c7 04 24 4b 27 80 00 	movl   $0x80274b,(%esp)
  8000ee:	e8 85 03 00 00       	call   800478 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f3:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fa:	00 
  8000fb:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 25 17 00 00       	call   801832 <readn>
  80010d:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0xff>
			panic("read: %e", i);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 68 27 80 	movl   $0x802768,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  80012e:	e8 4d 02 00 00       	call   800380 <_panic>
		buf[i] = 0;
  800133:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800138:	a1 00 30 80 00       	mov    0x803000,%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 7e 09 00 00       	call   800aca <strcmp>
  80014c:	85 c0                	test   %eax,%eax
  80014e:	75 0e                	jne    80015e <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  800150:	c7 04 24 71 27 80 00 	movl   $0x802771,(%esp)
  800157:	e8 1c 03 00 00       	call   800478 <cprintf>
  80015c:	eb 17                	jmp    800175 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015e:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	89 74 24 04          	mov    %esi,0x4(%esp)
  800169:	c7 04 24 8d 27 80 00 	movl   $0x80278d,(%esp)
  800170:	e8 03 03 00 00       	call   800478 <cprintf>
		exit();
  800175:	e8 f2 01 00 00       	call   80036c <exit>
  80017a:	e9 ac 00 00 00       	jmp    80022b <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017f:	a1 04 40 80 00       	mov    0x804004,%eax
  800184:	8b 40 48             	mov    0x48(%eax),%eax
  800187:	8b 55 8c             	mov    -0x74(%ebp),%edx
  80018a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 2e 27 80 00 	movl   $0x80272e,(%esp)
  800199:	e8 da 02 00 00       	call   800478 <cprintf>
		close(p[0]);
  80019e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 95 14 00 00       	call   80163e <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8001ae:	8b 40 48             	mov    0x48(%eax),%eax
  8001b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 a0 27 80 00 	movl   $0x8027a0,(%esp)
  8001c3:	e8 b0 02 00 00       	call   800478 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 1b 08 00 00       	call   8009f0 <strlen>
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 30 80 00       	mov    0x803000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 90 16 00 00       	call   80187d <write>
  8001ed:	89 c6                	mov    %eax,%esi
  8001ef:	a1 00 30 80 00       	mov    0x803000,%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 f4 07 00 00       	call   8009f0 <strlen>
  8001fc:	39 c6                	cmp    %eax,%esi
  8001fe:	74 20                	je     800220 <umain+0x1ec>
			panic("write: %e", i);
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	c7 44 24 08 bd 27 80 	movl   $0x8027bd,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  80021b:	e8 60 01 00 00       	call   800380 <_panic>
		close(p[1]);
  800220:	8b 45 90             	mov    -0x70(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 13 14 00 00       	call   80163e <close>
	}
	wait(pid);
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	e8 5d 1e 00 00       	call   802090 <wait>

	binaryname = "pipewriteeof";
  800233:	c7 05 04 30 80 00 c7 	movl   $0x8027c7,0x803004
  80023a:	27 80 00 
	if ((i = pipe(p)) < 0)
  80023d:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 a5 1c 00 00       	call   801eed <pipe>
  800248:	89 c6                	mov    %eax,%esi
  80024a:	85 c0                	test   %eax,%eax
  80024c:	79 20                	jns    80026e <umain+0x23a>
		panic("pipe: %e", i);
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	c7 44 24 08 0c 27 80 	movl   $0x80270c,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  800269:	e8 12 01 00 00       	call   800380 <_panic>

	if ((pid = fork()) < 0)
  80026e:	e8 1c 0f 00 00       	call   80118f <fork>
  800273:	89 c3                	mov    %eax,%ebx
  800275:	85 c0                	test   %eax,%eax
  800277:	79 20                	jns    800299 <umain+0x265>
		panic("fork: %e", i);
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	c7 44 24 08 25 27 80 	movl   $0x802725,0x8(%esp)
  800284:	00 
  800285:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028c:	00 
  80028d:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  800294:	e8 e7 00 00 00       	call   800380 <_panic>

	if (pid == 0) {
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 48                	jne    8002e5 <umain+0x2b1>
		close(p[0]);
  80029d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 96 13 00 00       	call   80163e <close>
		while (1) {
			cprintf(".");
  8002a8:	c7 04 24 d4 27 80 00 	movl   $0x8027d4,(%esp)
  8002af:	e8 c4 01 00 00       	call   800478 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002bb:	00 
  8002bc:	c7 44 24 04 d6 27 80 	movl   $0x8027d6,0x4(%esp)
  8002c3:	00 
  8002c4:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 ae 15 00 00       	call   80187d <write>
  8002cf:	83 f8 01             	cmp    $0x1,%eax
  8002d2:	74 d4                	je     8002a8 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d4:	c7 04 24 d8 27 80 00 	movl   $0x8027d8,(%esp)
  8002db:	e8 98 01 00 00       	call   800478 <cprintf>
		exit();
  8002e0:	e8 87 00 00 00       	call   80036c <exit>
	}
	close(p[0]);
  8002e5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 4e 13 00 00       	call   80163e <close>
	close(p[1]);
  8002f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 43 13 00 00       	call   80163e <close>
	wait(pid);
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	e8 8d 1d 00 00       	call   802090 <wait>

	cprintf("pipe tests passed\n");
  800303:	c7 04 24 f5 27 80 00 	movl   $0x8027f5,(%esp)
  80030a:	e8 69 01 00 00       	call   800478 <cprintf>
}
  80030f:	83 ec 80             	sub    $0xffffff80,%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    
	...

00800318 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
  80031d:	83 ec 10             	sub    $0x10,%esp
  800320:	8b 75 08             	mov    0x8(%ebp),%esi
  800323:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800326:	e8 ac 0a 00 00       	call   800dd7 <sys_getenvid>
  80032b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800330:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800337:	c1 e0 07             	shl    $0x7,%eax
  80033a:	29 d0                	sub    %edx,%eax
  80033c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800341:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800346:	85 f6                	test   %esi,%esi
  800348:	7e 07                	jle    800351 <libmain+0x39>
		binaryname = argv[0];
  80034a:	8b 03                	mov    (%ebx),%eax
  80034c:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800351:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800355:	89 34 24             	mov    %esi,(%esp)
  800358:	e8 d7 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80035d:	e8 0a 00 00 00       	call   80036c <exit>
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    
  800369:	00 00                	add    %al,(%eax)
	...

0080036c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800372:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800379:	e8 07 0a 00 00       	call   800d85 <sys_env_destroy>
}
  80037e:	c9                   	leave  
  80037f:	c3                   	ret    

00800380 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800388:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80038b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  800391:	e8 41 0a 00 00       	call   800dd7 <sys_getenvid>
  800396:	8b 55 0c             	mov    0xc(%ebp),%edx
  800399:	89 54 24 10          	mov    %edx,0x10(%esp)
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ac:	c7 04 24 58 28 80 00 	movl   $0x802858,(%esp)
  8003b3:	e8 c0 00 00 00       	call   800478 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003bf:	89 04 24             	mov    %eax,(%esp)
  8003c2:	e8 50 00 00 00       	call   800417 <vcprintf>
	cprintf("\n");
  8003c7:	c7 04 24 49 27 80 00 	movl   $0x802749,(%esp)
  8003ce:	e8 a5 00 00 00       	call   800478 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003d3:	cc                   	int3   
  8003d4:	eb fd                	jmp    8003d3 <_panic+0x53>
	...

008003d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	53                   	push   %ebx
  8003dc:	83 ec 14             	sub    $0x14,%esp
  8003df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e2:	8b 03                	mov    (%ebx),%eax
  8003e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003eb:	40                   	inc    %eax
  8003ec:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f3:	75 19                	jne    80040e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003f5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003fc:	00 
  8003fd:	8d 43 08             	lea    0x8(%ebx),%eax
  800400:	89 04 24             	mov    %eax,(%esp)
  800403:	e8 40 09 00 00       	call   800d48 <sys_cputs>
		b->idx = 0;
  800408:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80040e:	ff 43 04             	incl   0x4(%ebx)
}
  800411:	83 c4 14             	add    $0x14,%esp
  800414:	5b                   	pop    %ebx
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800420:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800427:	00 00 00 
	b.cnt = 0;
  80042a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800431:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800434:	8b 45 0c             	mov    0xc(%ebp),%eax
  800437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  80043e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800442:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044c:	c7 04 24 d8 03 80 00 	movl   $0x8003d8,(%esp)
  800453:	e8 82 01 00 00       	call   8005da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800458:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80045e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800462:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 d8 08 00 00       	call   800d48 <sys_cputs>

	return b.cnt;
}
  800470:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800476:	c9                   	leave  
  800477:	c3                   	ret    

00800478 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80047e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800481:	89 44 24 04          	mov    %eax,0x4(%esp)
  800485:	8b 45 08             	mov    0x8(%ebp),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	e8 87 ff ff ff       	call   800417 <vcprintf>
	va_end(ap);

	return cnt;
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    
	...

00800494 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 3c             	sub    $0x3c,%esp
  80049d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a0:	89 d7                	mov    %edx,%edi
  8004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004b1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	75 08                	jne    8004c0 <printnum+0x2c>
  8004b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004bb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004be:	77 57                	ja     800517 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004c0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004c4:	4b                   	dec    %ebx
  8004c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004d4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004df:	00 
  8004e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e3:	89 04 24             	mov    %eax,(%esp)
  8004e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	e8 a2 1f 00 00       	call   802494 <__udivdi3>
  8004f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004f6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004fa:	89 04 24             	mov    %eax,(%esp)
  8004fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800501:	89 fa                	mov    %edi,%edx
  800503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800506:	e8 89 ff ff ff       	call   800494 <printnum>
  80050b:	eb 0f                	jmp    80051c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80050d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800511:	89 34 24             	mov    %esi,(%esp)
  800514:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800517:	4b                   	dec    %ebx
  800518:	85 db                	test   %ebx,%ebx
  80051a:	7f f1                	jg     80050d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80051c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800520:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800524:	8b 45 10             	mov    0x10(%ebp),%eax
  800527:	89 44 24 08          	mov    %eax,0x8(%esp)
  80052b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800532:	00 
  800533:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800536:	89 04 24             	mov    %eax,(%esp)
  800539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800540:	e8 6f 20 00 00       	call   8025b4 <__umoddi3>
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	0f be 80 7b 28 80 00 	movsbl 0x80287b(%eax),%eax
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800556:	83 c4 3c             	add    $0x3c,%esp
  800559:	5b                   	pop    %ebx
  80055a:	5e                   	pop    %esi
  80055b:	5f                   	pop    %edi
  80055c:	5d                   	pop    %ebp
  80055d:	c3                   	ret    

0080055e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800561:	83 fa 01             	cmp    $0x1,%edx
  800564:	7e 0e                	jle    800574 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800566:	8b 10                	mov    (%eax),%edx
  800568:	8d 4a 08             	lea    0x8(%edx),%ecx
  80056b:	89 08                	mov    %ecx,(%eax)
  80056d:	8b 02                	mov    (%edx),%eax
  80056f:	8b 52 04             	mov    0x4(%edx),%edx
  800572:	eb 22                	jmp    800596 <getuint+0x38>
	else if (lflag)
  800574:	85 d2                	test   %edx,%edx
  800576:	74 10                	je     800588 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800578:	8b 10                	mov    (%eax),%edx
  80057a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80057d:	89 08                	mov    %ecx,(%eax)
  80057f:	8b 02                	mov    (%edx),%eax
  800581:	ba 00 00 00 00       	mov    $0x0,%edx
  800586:	eb 0e                	jmp    800596 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80058d:	89 08                	mov    %ecx,(%eax)
  80058f:	8b 02                	mov    (%edx),%eax
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800596:	5d                   	pop    %ebp
  800597:	c3                   	ret    

00800598 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80059e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005a1:	8b 10                	mov    (%eax),%edx
  8005a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005a6:	73 08                	jae    8005b0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005ab:	88 0a                	mov    %cl,(%edx)
  8005ad:	42                   	inc    %edx
  8005ae:	89 10                	mov    %edx,(%eax)
}
  8005b0:	5d                   	pop    %ebp
  8005b1:	c3                   	ret    

008005b2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8005c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	e8 02 00 00 00       	call   8005da <vprintfmt>
	va_end(ap);
}
  8005d8:	c9                   	leave  
  8005d9:	c3                   	ret    

008005da <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	57                   	push   %edi
  8005de:	56                   	push   %esi
  8005df:	53                   	push   %ebx
  8005e0:	83 ec 4c             	sub    $0x4c,%esp
  8005e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e6:	8b 75 10             	mov    0x10(%ebp),%esi
  8005e9:	eb 12                	jmp    8005fd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	0f 84 6b 03 00 00    	je     80095e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005fd:	0f b6 06             	movzbl (%esi),%eax
  800600:	46                   	inc    %esi
  800601:	83 f8 25             	cmp    $0x25,%eax
  800604:	75 e5                	jne    8005eb <vprintfmt+0x11>
  800606:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80060a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800611:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800616:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80061d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800622:	eb 26                	jmp    80064a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800627:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80062b:	eb 1d                	jmp    80064a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800630:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800634:	eb 14                	jmp    80064a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800639:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800640:	eb 08                	jmp    80064a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800642:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800645:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	0f b6 06             	movzbl (%esi),%eax
  80064d:	8d 56 01             	lea    0x1(%esi),%edx
  800650:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800653:	8a 16                	mov    (%esi),%dl
  800655:	83 ea 23             	sub    $0x23,%edx
  800658:	80 fa 55             	cmp    $0x55,%dl
  80065b:	0f 87 e1 02 00 00    	ja     800942 <vprintfmt+0x368>
  800661:	0f b6 d2             	movzbl %dl,%edx
  800664:	ff 24 95 c0 29 80 00 	jmp    *0x8029c0(,%edx,4)
  80066b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80066e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800673:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800676:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80067a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80067d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800680:	83 fa 09             	cmp    $0x9,%edx
  800683:	77 2a                	ja     8006af <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800685:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800686:	eb eb                	jmp    800673 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800696:	eb 17                	jmp    8006af <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800698:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80069c:	78 98                	js     800636 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a1:	eb a7                	jmp    80064a <vprintfmt+0x70>
  8006a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006a6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006ad:	eb 9b                	jmp    80064a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b3:	79 95                	jns    80064a <vprintfmt+0x70>
  8006b5:	eb 8b                	jmp    800642 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006b7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006bb:	eb 8d                	jmp    80064a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	89 04 24             	mov    %eax,(%esp)
  8006cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006d5:	e9 23 ff ff ff       	jmp    8005fd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 50 04             	lea    0x4(%eax),%edx
  8006e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e3:	8b 00                	mov    (%eax),%eax
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	79 02                	jns    8006eb <vprintfmt+0x111>
  8006e9:	f7 d8                	neg    %eax
  8006eb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ed:	83 f8 0f             	cmp    $0xf,%eax
  8006f0:	7f 0b                	jg     8006fd <vprintfmt+0x123>
  8006f2:	8b 04 85 20 2b 80 00 	mov    0x802b20(,%eax,4),%eax
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	75 23                	jne    800720 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800701:	c7 44 24 08 93 28 80 	movl   $0x802893,0x8(%esp)
  800708:	00 
  800709:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 9a fe ff ff       	call   8005b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80071b:	e9 dd fe ff ff       	jmp    8005fd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800720:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800724:	c7 44 24 08 41 2d 80 	movl   $0x802d41,0x8(%esp)
  80072b:	00 
  80072c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800730:	8b 55 08             	mov    0x8(%ebp),%edx
  800733:	89 14 24             	mov    %edx,(%esp)
  800736:	e8 77 fe ff ff       	call   8005b2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80073e:	e9 ba fe ff ff       	jmp    8005fd <vprintfmt+0x23>
  800743:	89 f9                	mov    %edi,%ecx
  800745:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800748:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8d 50 04             	lea    0x4(%eax),%edx
  800751:	89 55 14             	mov    %edx,0x14(%ebp)
  800754:	8b 30                	mov    (%eax),%esi
  800756:	85 f6                	test   %esi,%esi
  800758:	75 05                	jne    80075f <vprintfmt+0x185>
				p = "(null)";
  80075a:	be 8c 28 80 00       	mov    $0x80288c,%esi
			if (width > 0 && padc != '-')
  80075f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800763:	0f 8e 84 00 00 00    	jle    8007ed <vprintfmt+0x213>
  800769:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80076d:	74 7e                	je     8007ed <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80076f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800773:	89 34 24             	mov    %esi,(%esp)
  800776:	e8 8b 02 00 00       	call   800a06 <strnlen>
  80077b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80077e:	29 c2                	sub    %eax,%edx
  800780:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800783:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800787:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80078a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80078d:	89 de                	mov    %ebx,%esi
  80078f:	89 d3                	mov    %edx,%ebx
  800791:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800793:	eb 0b                	jmp    8007a0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800795:	89 74 24 04          	mov    %esi,0x4(%esp)
  800799:	89 3c 24             	mov    %edi,(%esp)
  80079c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	4b                   	dec    %ebx
  8007a0:	85 db                	test   %ebx,%ebx
  8007a2:	7f f1                	jg     800795 <vprintfmt+0x1bb>
  8007a4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007a7:	89 f3                	mov    %esi,%ebx
  8007a9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	79 05                	jns    8007b8 <vprintfmt+0x1de>
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bb:	29 c2                	sub    %eax,%edx
  8007bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c0:	eb 2b                	jmp    8007ed <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c6:	74 18                	je     8007e0 <vprintfmt+0x206>
  8007c8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007cb:	83 fa 5e             	cmp    $0x5e,%edx
  8007ce:	76 10                	jbe    8007e0 <vprintfmt+0x206>
					putch('?', putdat);
  8007d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007db:	ff 55 08             	call   *0x8(%ebp)
  8007de:	eb 0a                	jmp    8007ea <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e4:	89 04 24             	mov    %eax,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007ea:	ff 4d e4             	decl   -0x1c(%ebp)
  8007ed:	0f be 06             	movsbl (%esi),%eax
  8007f0:	46                   	inc    %esi
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	74 21                	je     800816 <vprintfmt+0x23c>
  8007f5:	85 ff                	test   %edi,%edi
  8007f7:	78 c9                	js     8007c2 <vprintfmt+0x1e8>
  8007f9:	4f                   	dec    %edi
  8007fa:	79 c6                	jns    8007c2 <vprintfmt+0x1e8>
  8007fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ff:	89 de                	mov    %ebx,%esi
  800801:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800804:	eb 18                	jmp    80081e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800811:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800813:	4b                   	dec    %ebx
  800814:	eb 08                	jmp    80081e <vprintfmt+0x244>
  800816:	8b 7d 08             	mov    0x8(%ebp),%edi
  800819:	89 de                	mov    %ebx,%esi
  80081b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80081e:	85 db                	test   %ebx,%ebx
  800820:	7f e4                	jg     800806 <vprintfmt+0x22c>
  800822:	89 7d 08             	mov    %edi,0x8(%ebp)
  800825:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800827:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80082a:	e9 ce fd ff ff       	jmp    8005fd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80082f:	83 f9 01             	cmp    $0x1,%ecx
  800832:	7e 10                	jle    800844 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8d 50 08             	lea    0x8(%eax),%edx
  80083a:	89 55 14             	mov    %edx,0x14(%ebp)
  80083d:	8b 30                	mov    (%eax),%esi
  80083f:	8b 78 04             	mov    0x4(%eax),%edi
  800842:	eb 26                	jmp    80086a <vprintfmt+0x290>
	else if (lflag)
  800844:	85 c9                	test   %ecx,%ecx
  800846:	74 12                	je     80085a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8d 50 04             	lea    0x4(%eax),%edx
  80084e:	89 55 14             	mov    %edx,0x14(%ebp)
  800851:	8b 30                	mov    (%eax),%esi
  800853:	89 f7                	mov    %esi,%edi
  800855:	c1 ff 1f             	sar    $0x1f,%edi
  800858:	eb 10                	jmp    80086a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8d 50 04             	lea    0x4(%eax),%edx
  800860:	89 55 14             	mov    %edx,0x14(%ebp)
  800863:	8b 30                	mov    (%eax),%esi
  800865:	89 f7                	mov    %esi,%edi
  800867:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80086a:	85 ff                	test   %edi,%edi
  80086c:	78 0a                	js     800878 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80086e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800873:	e9 8c 00 00 00       	jmp    800904 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800886:	f7 de                	neg    %esi
  800888:	83 d7 00             	adc    $0x0,%edi
  80088b:	f7 df                	neg    %edi
			}
			base = 10;
  80088d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800892:	eb 70                	jmp    800904 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800894:	89 ca                	mov    %ecx,%edx
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
  800899:	e8 c0 fc ff ff       	call   80055e <getuint>
  80089e:	89 c6                	mov    %eax,%esi
  8008a0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008a7:	eb 5b                	jmp    800904 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  8008a9:	89 ca                	mov    %ecx,%edx
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 ab fc ff ff       	call   80055e <getuint>
  8008b3:	89 c6                	mov    %eax,%esi
  8008b5:	89 d7                	mov    %edx,%edi
			base = 8;
  8008b7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008bc:	eb 46                	jmp    800904 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008c9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008d7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8d 50 04             	lea    0x4(%eax),%edx
  8008e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008e3:	8b 30                	mov    (%eax),%esi
  8008e5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008ea:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ef:	eb 13                	jmp    800904 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f1:	89 ca                	mov    %ecx,%edx
  8008f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008f6:	e8 63 fc ff ff       	call   80055e <getuint>
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d7                	mov    %edx,%edi
			base = 16;
  8008ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800904:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800908:	89 54 24 10          	mov    %edx,0x10(%esp)
  80090c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80090f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800913:	89 44 24 08          	mov    %eax,0x8(%esp)
  800917:	89 34 24             	mov    %esi,(%esp)
  80091a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80091e:	89 da                	mov    %ebx,%edx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	e8 6c fb ff ff       	call   800494 <printnum>
			break;
  800928:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80092b:	e9 cd fc ff ff       	jmp    8005fd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800930:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80093d:	e9 bb fc ff ff       	jmp    8005fd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800942:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800946:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80094d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800950:	eb 01                	jmp    800953 <vprintfmt+0x379>
  800952:	4e                   	dec    %esi
  800953:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800957:	75 f9                	jne    800952 <vprintfmt+0x378>
  800959:	e9 9f fc ff ff       	jmp    8005fd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80095e:	83 c4 4c             	add    $0x4c,%esp
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5f                   	pop    %edi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 28             	sub    $0x28,%esp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800972:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800975:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800979:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80097c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800983:	85 c0                	test   %eax,%eax
  800985:	74 30                	je     8009b7 <vsnprintf+0x51>
  800987:	85 d2                	test   %edx,%edx
  800989:	7e 33                	jle    8009be <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098b:	8b 45 14             	mov    0x14(%ebp),%eax
  80098e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800992:	8b 45 10             	mov    0x10(%ebp),%eax
  800995:	89 44 24 08          	mov    %eax,0x8(%esp)
  800999:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	c7 04 24 98 05 80 00 	movl   $0x800598,(%esp)
  8009a7:	e8 2e fc ff ff       	call   8005da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	eb 0c                	jmp    8009c3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009bc:	eb 05                	jmp    8009c3 <vsnprintf+0x5d>
  8009be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 04 24             	mov    %eax,(%esp)
  8009e6:	e8 7b ff ff ff       	call   800966 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    
  8009ed:	00 00                	add    %al,(%eax)
	...

008009f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	eb 01                	jmp    8009fe <strlen+0xe>
		n++;
  8009fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a02:	75 f9                	jne    8009fd <strlen+0xd>
		n++;
	return n;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	eb 01                	jmp    800a17 <strnlen+0x11>
		n++;
  800a16:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	39 d0                	cmp    %edx,%eax
  800a19:	74 06                	je     800a21 <strnlen+0x1b>
  800a1b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a1f:	75 f5                	jne    800a16 <strnlen+0x10>
		n++;
	return n;
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a35:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a38:	42                   	inc    %edx
  800a39:	84 c9                	test   %cl,%cl
  800a3b:	75 f5                	jne    800a32 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a4a:	89 1c 24             	mov    %ebx,(%esp)
  800a4d:	e8 9e ff ff ff       	call   8009f0 <strlen>
	strcpy(dst + len, src);
  800a52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a55:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a59:	01 d8                	add    %ebx,%eax
  800a5b:	89 04 24             	mov    %eax,(%esp)
  800a5e:	e8 c0 ff ff ff       	call   800a23 <strcpy>
	return dst;
}
  800a63:	89 d8                	mov    %ebx,%eax
  800a65:	83 c4 08             	add    $0x8,%esp
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a76:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7e:	eb 0c                	jmp    800a8c <strncpy+0x21>
		*dst++ = *src;
  800a80:	8a 1a                	mov    (%edx),%bl
  800a82:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a85:	80 3a 01             	cmpb   $0x1,(%edx)
  800a88:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8b:	41                   	inc    %ecx
  800a8c:	39 f1                	cmp    %esi,%ecx
  800a8e:	75 f0                	jne    800a80 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa2:	85 d2                	test   %edx,%edx
  800aa4:	75 0a                	jne    800ab0 <strlcpy+0x1c>
  800aa6:	89 f0                	mov    %esi,%eax
  800aa8:	eb 1a                	jmp    800ac4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aaa:	88 18                	mov    %bl,(%eax)
  800aac:	40                   	inc    %eax
  800aad:	41                   	inc    %ecx
  800aae:	eb 02                	jmp    800ab2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ab2:	4a                   	dec    %edx
  800ab3:	74 0a                	je     800abf <strlcpy+0x2b>
  800ab5:	8a 19                	mov    (%ecx),%bl
  800ab7:	84 db                	test   %bl,%bl
  800ab9:	75 ef                	jne    800aaa <strlcpy+0x16>
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	eb 02                	jmp    800ac1 <strlcpy+0x2d>
  800abf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ac1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ac4:	29 f0                	sub    %esi,%eax
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad3:	eb 02                	jmp    800ad7 <strcmp+0xd>
		p++, q++;
  800ad5:	41                   	inc    %ecx
  800ad6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ad7:	8a 01                	mov    (%ecx),%al
  800ad9:	84 c0                	test   %al,%al
  800adb:	74 04                	je     800ae1 <strcmp+0x17>
  800add:	3a 02                	cmp    (%edx),%al
  800adf:	74 f4                	je     800ad5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae1:	0f b6 c0             	movzbl %al,%eax
  800ae4:	0f b6 12             	movzbl (%edx),%edx
  800ae7:	29 d0                	sub    %edx,%eax
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800af8:	eb 03                	jmp    800afd <strncmp+0x12>
		n--, p++, q++;
  800afa:	4a                   	dec    %edx
  800afb:	40                   	inc    %eax
  800afc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800afd:	85 d2                	test   %edx,%edx
  800aff:	74 14                	je     800b15 <strncmp+0x2a>
  800b01:	8a 18                	mov    (%eax),%bl
  800b03:	84 db                	test   %bl,%bl
  800b05:	74 04                	je     800b0b <strncmp+0x20>
  800b07:	3a 19                	cmp    (%ecx),%bl
  800b09:	74 ef                	je     800afa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0b:	0f b6 00             	movzbl (%eax),%eax
  800b0e:	0f b6 11             	movzbl (%ecx),%edx
  800b11:	29 d0                	sub    %edx,%eax
  800b13:	eb 05                	jmp    800b1a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b26:	eb 05                	jmp    800b2d <strchr+0x10>
		if (*s == c)
  800b28:	38 ca                	cmp    %cl,%dl
  800b2a:	74 0c                	je     800b38 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b2c:	40                   	inc    %eax
  800b2d:	8a 10                	mov    (%eax),%dl
  800b2f:	84 d2                	test   %dl,%dl
  800b31:	75 f5                	jne    800b28 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b43:	eb 05                	jmp    800b4a <strfind+0x10>
		if (*s == c)
  800b45:	38 ca                	cmp    %cl,%dl
  800b47:	74 07                	je     800b50 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b49:	40                   	inc    %eax
  800b4a:	8a 10                	mov    (%eax),%dl
  800b4c:	84 d2                	test   %dl,%dl
  800b4e:	75 f5                	jne    800b45 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b61:	85 c9                	test   %ecx,%ecx
  800b63:	74 30                	je     800b95 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b65:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6b:	75 25                	jne    800b92 <memset+0x40>
  800b6d:	f6 c1 03             	test   $0x3,%cl
  800b70:	75 20                	jne    800b92 <memset+0x40>
		c &= 0xFF;
  800b72:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	c1 e3 08             	shl    $0x8,%ebx
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	c1 e6 18             	shl    $0x18,%esi
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	c1 e0 10             	shl    $0x10,%eax
  800b84:	09 f0                	or     %esi,%eax
  800b86:	09 d0                	or     %edx,%eax
  800b88:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b8a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b8d:	fc                   	cld    
  800b8e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b90:	eb 03                	jmp    800b95 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b92:	fc                   	cld    
  800b93:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b95:	89 f8                	mov    %edi,%eax
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800baa:	39 c6                	cmp    %eax,%esi
  800bac:	73 34                	jae    800be2 <memmove+0x46>
  800bae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bb1:	39 d0                	cmp    %edx,%eax
  800bb3:	73 2d                	jae    800be2 <memmove+0x46>
		s += n;
		d += n;
  800bb5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	f6 c2 03             	test   $0x3,%dl
  800bbb:	75 1b                	jne    800bd8 <memmove+0x3c>
  800bbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc3:	75 13                	jne    800bd8 <memmove+0x3c>
  800bc5:	f6 c1 03             	test   $0x3,%cl
  800bc8:	75 0e                	jne    800bd8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bca:	83 ef 04             	sub    $0x4,%edi
  800bcd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bd3:	fd                   	std    
  800bd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd6:	eb 07                	jmp    800bdf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bd8:	4f                   	dec    %edi
  800bd9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bdc:	fd                   	std    
  800bdd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bdf:	fc                   	cld    
  800be0:	eb 20                	jmp    800c02 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be8:	75 13                	jne    800bfd <memmove+0x61>
  800bea:	a8 03                	test   $0x3,%al
  800bec:	75 0f                	jne    800bfd <memmove+0x61>
  800bee:	f6 c1 03             	test   $0x3,%cl
  800bf1:	75 0a                	jne    800bfd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	fc                   	cld    
  800bf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfb:	eb 05                	jmp    800c02 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bfd:	89 c7                	mov    %eax,%edi
  800bff:	fc                   	cld    
  800c00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	89 04 24             	mov    %eax,(%esp)
  800c20:	e8 77 ff ff ff       	call   800b9c <memmove>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	eb 16                	jmp    800c53 <memcmp+0x2c>
		if (*s1 != *s2)
  800c3d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c40:	42                   	inc    %edx
  800c41:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c45:	38 c8                	cmp    %cl,%al
  800c47:	74 0a                	je     800c53 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c49:	0f b6 c0             	movzbl %al,%eax
  800c4c:	0f b6 c9             	movzbl %cl,%ecx
  800c4f:	29 c8                	sub    %ecx,%eax
  800c51:	eb 09                	jmp    800c5c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c53:	39 da                	cmp    %ebx,%edx
  800c55:	75 e6                	jne    800c3d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c6a:	89 c2                	mov    %eax,%edx
  800c6c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c6f:	eb 05                	jmp    800c76 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c71:	38 08                	cmp    %cl,(%eax)
  800c73:	74 05                	je     800c7a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c75:	40                   	inc    %eax
  800c76:	39 d0                	cmp    %edx,%eax
  800c78:	72 f7                	jb     800c71 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	8b 55 08             	mov    0x8(%ebp),%edx
  800c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c88:	eb 01                	jmp    800c8b <strtol+0xf>
		s++;
  800c8a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8b:	8a 02                	mov    (%edx),%al
  800c8d:	3c 20                	cmp    $0x20,%al
  800c8f:	74 f9                	je     800c8a <strtol+0xe>
  800c91:	3c 09                	cmp    $0x9,%al
  800c93:	74 f5                	je     800c8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c95:	3c 2b                	cmp    $0x2b,%al
  800c97:	75 08                	jne    800ca1 <strtol+0x25>
		s++;
  800c99:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9f:	eb 13                	jmp    800cb4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ca1:	3c 2d                	cmp    $0x2d,%al
  800ca3:	75 0a                	jne    800caf <strtol+0x33>
		s++, neg = 1;
  800ca5:	8d 52 01             	lea    0x1(%edx),%edx
  800ca8:	bf 01 00 00 00       	mov    $0x1,%edi
  800cad:	eb 05                	jmp    800cb4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb4:	85 db                	test   %ebx,%ebx
  800cb6:	74 05                	je     800cbd <strtol+0x41>
  800cb8:	83 fb 10             	cmp    $0x10,%ebx
  800cbb:	75 28                	jne    800ce5 <strtol+0x69>
  800cbd:	8a 02                	mov    (%edx),%al
  800cbf:	3c 30                	cmp    $0x30,%al
  800cc1:	75 10                	jne    800cd3 <strtol+0x57>
  800cc3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cc7:	75 0a                	jne    800cd3 <strtol+0x57>
		s += 2, base = 16;
  800cc9:	83 c2 02             	add    $0x2,%edx
  800ccc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd1:	eb 12                	jmp    800ce5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cd3:	85 db                	test   %ebx,%ebx
  800cd5:	75 0e                	jne    800ce5 <strtol+0x69>
  800cd7:	3c 30                	cmp    $0x30,%al
  800cd9:	75 05                	jne    800ce0 <strtol+0x64>
		s++, base = 8;
  800cdb:	42                   	inc    %edx
  800cdc:	b3 08                	mov    $0x8,%bl
  800cde:	eb 05                	jmp    800ce5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ce0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cea:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cec:	8a 0a                	mov    (%edx),%cl
  800cee:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf1:	80 fb 09             	cmp    $0x9,%bl
  800cf4:	77 08                	ja     800cfe <strtol+0x82>
			dig = *s - '0';
  800cf6:	0f be c9             	movsbl %cl,%ecx
  800cf9:	83 e9 30             	sub    $0x30,%ecx
  800cfc:	eb 1e                	jmp    800d1c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cfe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d01:	80 fb 19             	cmp    $0x19,%bl
  800d04:	77 08                	ja     800d0e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d06:	0f be c9             	movsbl %cl,%ecx
  800d09:	83 e9 57             	sub    $0x57,%ecx
  800d0c:	eb 0e                	jmp    800d1c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d0e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d11:	80 fb 19             	cmp    $0x19,%bl
  800d14:	77 12                	ja     800d28 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d16:	0f be c9             	movsbl %cl,%ecx
  800d19:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d1c:	39 f1                	cmp    %esi,%ecx
  800d1e:	7d 0c                	jge    800d2c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d20:	42                   	inc    %edx
  800d21:	0f af c6             	imul   %esi,%eax
  800d24:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d26:	eb c4                	jmp    800cec <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d28:	89 c1                	mov    %eax,%ecx
  800d2a:	eb 02                	jmp    800d2e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d2c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d32:	74 05                	je     800d39 <strtol+0xbd>
		*endptr = (char *) s;
  800d34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d37:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d39:	85 ff                	test   %edi,%edi
  800d3b:	74 04                	je     800d41 <strtol+0xc5>
  800d3d:	89 c8                	mov    %ecx,%eax
  800d3f:	f7 d8                	neg    %eax
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
	...

00800d48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	89 c7                	mov    %eax,%edi
  800d5d:	89 c6                	mov    %eax,%esi
  800d5f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d93:	b8 03 00 00 00       	mov    $0x3,%eax
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	89 cb                	mov    %ecx,%ebx
  800d9d:	89 cf                	mov    %ecx,%edi
  800d9f:	89 ce                	mov    %ecx,%esi
  800da1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da3:	85 c0                	test   %eax,%eax
  800da5:	7e 28                	jle    800dcf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dab:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800db2:	00 
  800db3:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800dba:	00 
  800dbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc2:	00 
  800dc3:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800dca:	e8 b1 f5 ff ff       	call   800380 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dcf:	83 c4 2c             	add    $0x2c,%esp
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ddd:	ba 00 00 00 00       	mov    $0x0,%edx
  800de2:	b8 02 00 00 00       	mov    $0x2,%eax
  800de7:	89 d1                	mov    %edx,%ecx
  800de9:	89 d3                	mov    %edx,%ebx
  800deb:	89 d7                	mov    %edx,%edi
  800ded:	89 d6                	mov    %edx,%esi
  800def:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_yield>:

void
sys_yield(void)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	57                   	push   %edi
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800e01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	89 d3                	mov    %edx,%ebx
  800e0a:	89 d7                	mov    %edx,%edi
  800e0c:	89 d6                	mov    %edx,%esi
  800e0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	57                   	push   %edi
  800e19:	56                   	push   %esi
  800e1a:	53                   	push   %ebx
  800e1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1e:	be 00 00 00 00       	mov    $0x0,%esi
  800e23:	b8 04 00 00 00       	mov    $0x4,%eax
  800e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e31:	89 f7                	mov    %esi,%edi
  800e33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800e5c:	e8 1f f5 ff ff       	call   800380 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e61:	83 c4 2c             	add    $0x2c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	b8 05 00 00 00       	mov    $0x5,%eax
  800e77:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	8b 55 08             	mov    0x8(%ebp),%edx
  800e86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 28                	jle    800eb4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e90:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800eaf:	e8 cc f4 ff ff       	call   800380 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eb4:	83 c4 2c             	add    $0x2c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    

00800ebc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	57                   	push   %edi
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eca:	b8 06 00 00 00       	mov    $0x6,%eax
  800ecf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed5:	89 df                	mov    %ebx,%edi
  800ed7:	89 de                	mov    %ebx,%esi
  800ed9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800edb:	85 c0                	test   %eax,%eax
  800edd:	7e 28                	jle    800f07 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800eea:	00 
  800eeb:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800ef2:	00 
  800ef3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efa:	00 
  800efb:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f02:	e8 79 f4 ff ff       	call   800380 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f07:	83 c4 2c             	add    $0x2c,%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5f                   	pop    %edi
  800f0d:	5d                   	pop    %ebp
  800f0e:	c3                   	ret    

00800f0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	57                   	push   %edi
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	89 df                	mov    %ebx,%edi
  800f2a:	89 de                	mov    %ebx,%esi
  800f2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	7e 28                	jle    800f5a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f36:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f3d:	00 
  800f3e:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f45:	00 
  800f46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4d:	00 
  800f4e:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800f55:	e8 26 f4 ff ff       	call   800380 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f5a:	83 c4 2c             	add    $0x2c,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    

00800f62 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f70:	b8 09 00 00 00       	mov    $0x9,%eax
  800f75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	89 df                	mov    %ebx,%edi
  800f7d:	89 de                	mov    %ebx,%esi
  800f7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	7e 28                	jle    800fad <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f89:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f90:	00 
  800f91:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800fa8:	e8 d3 f3 ff ff       	call   800380 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fad:	83 c4 2c             	add    $0x2c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	89 df                	mov    %ebx,%edi
  800fd0:	89 de                	mov    %ebx,%esi
  800fd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	7e 28                	jle    801000 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fdc:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fe3:	00 
  800fe4:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  800feb:	00 
  800fec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ff3:	00 
  800ff4:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  800ffb:	e8 80 f3 ff ff       	call   800380 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801000:	83 c4 2c             	add    $0x2c,%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	be 00 00 00 00       	mov    $0x0,%esi
  801013:	b8 0c 00 00 00       	mov    $0xc,%eax
  801018:	8b 7d 14             	mov    0x14(%ebp),%edi
  80101b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80101e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801021:	8b 55 08             	mov    0x8(%ebp),%edx
  801024:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
  801031:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801034:	b9 00 00 00 00       	mov    $0x0,%ecx
  801039:	b8 0d 00 00 00       	mov    $0xd,%eax
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 cb                	mov    %ecx,%ebx
  801043:	89 cf                	mov    %ecx,%edi
  801045:	89 ce                	mov    %ecx,%esi
  801047:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801049:	85 c0                	test   %eax,%eax
  80104b:	7e 28                	jle    801075 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801051:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801058:	00 
  801059:	c7 44 24 08 7f 2b 80 	movl   $0x802b7f,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 9c 2b 80 00 	movl   $0x802b9c,(%esp)
  801070:	e8 0b f3 ff ff       	call   800380 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801075:	83 c4 2c             	add    $0x2c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
  80107d:	00 00                	add    %al,(%eax)
	...

00801080 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	53                   	push   %ebx
  801084:	83 ec 24             	sub    $0x24,%esp
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80108a:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  80108c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801090:	75 20                	jne    8010b2 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801092:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801096:	c7 44 24 08 ac 2b 80 	movl   $0x802bac,0x8(%esp)
  80109d:	00 
  80109e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8010a5:	00 
  8010a6:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  8010ad:	e8 ce f2 ff ff       	call   800380 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8010b2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  8010bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c4:	f6 c4 08             	test   $0x8,%ah
  8010c7:	75 1c                	jne    8010e5 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8010c9:	c7 44 24 08 dc 2b 80 	movl   $0x802bdc,0x8(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010d8:	00 
  8010d9:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  8010e0:	e8 9b f2 ff ff       	call   800380 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8010e5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010fc:	e8 14 fd ff ff       	call   800e15 <sys_page_alloc>
  801101:	85 c0                	test   %eax,%eax
  801103:	79 20                	jns    801125 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801105:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801109:	c7 44 24 08 37 2c 80 	movl   $0x802c37,0x8(%esp)
  801110:	00 
  801111:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801118:	00 
  801119:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801120:	e8 5b f2 ff ff       	call   800380 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801125:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80112c:	00 
  80112d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801131:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801138:	e8 5f fa ff ff       	call   800b9c <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  80113d:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801144:	00 
  801145:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801149:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801160:	e8 04 fd ff ff       	call   800e69 <sys_page_map>
  801165:	85 c0                	test   %eax,%eax
  801167:	79 20                	jns    801189 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116d:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  801174:	00 
  801175:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80117c:	00 
  80117d:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801184:	e8 f7 f1 ff ff       	call   800380 <_panic>

}
  801189:	83 c4 24             	add    $0x24,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    

0080118f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	57                   	push   %edi
  801193:	56                   	push   %esi
  801194:	53                   	push   %ebx
  801195:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801198:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  80119f:	e8 f8 10 00 00       	call   80229c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011a4:	ba 07 00 00 00       	mov    $0x7,%edx
  8011a9:	89 d0                	mov    %edx,%eax
  8011ab:	cd 30                	int    $0x30
  8011ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011b0:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	79 20                	jns    8011d7 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8011b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bb:	c7 44 24 08 5d 2c 80 	movl   $0x802c5d,0x8(%esp)
  8011c2:	00 
  8011c3:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011ca:	00 
  8011cb:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  8011d2:	e8 a9 f1 ff ff       	call   800380 <_panic>
	if (child_envid == 0) { // child
  8011d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011db:	75 25                	jne    801202 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  8011dd:	e8 f5 fb ff ff       	call   800dd7 <sys_getenvid>
  8011e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011e7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8011ee:	c1 e0 07             	shl    $0x7,%eax
  8011f1:	29 d0                	sub    %edx,%eax
  8011f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011f8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011fd:	e9 58 02 00 00       	jmp    80145a <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801202:	bf 00 00 00 00       	mov    $0x0,%edi
  801207:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  80120c:	89 f0                	mov    %esi,%eax
  80120e:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801211:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801218:	a8 01                	test   $0x1,%al
  80121a:	0f 84 7a 01 00 00    	je     80139a <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  801220:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801227:	a8 01                	test   $0x1,%al
  801229:	0f 84 6b 01 00 00    	je     80139a <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80122f:	a1 04 40 80 00       	mov    0x804004,%eax
  801234:	8b 40 48             	mov    0x48(%eax),%eax
  801237:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  80123a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801241:	f6 c4 04             	test   $0x4,%ah
  801244:	74 52                	je     801298 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801246:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80124d:	25 07 0e 00 00       	and    $0xe07,%eax
  801252:	89 44 24 10          	mov    %eax,0x10(%esp)
  801256:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80125a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80125d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801261:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801268:	89 04 24             	mov    %eax,(%esp)
  80126b:	e8 f9 fb ff ff       	call   800e69 <sys_page_map>
  801270:	85 c0                	test   %eax,%eax
  801272:	0f 89 22 01 00 00    	jns    80139a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801278:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127c:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801293:	e8 e8 f0 ff ff       	call   800380 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801298:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80129f:	f6 c4 08             	test   $0x8,%ah
  8012a2:	75 0f                	jne    8012b3 <fork+0x124>
  8012a4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012ab:	a8 02                	test   $0x2,%al
  8012ad:	0f 84 99 00 00 00    	je     80134c <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8012b3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012ba:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8012bd:	83 f8 01             	cmp    $0x1,%eax
  8012c0:	19 db                	sbb    %ebx,%ebx
  8012c2:	83 e3 fc             	and    $0xfffffffc,%ebx
  8012c5:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8012cb:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012cf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e1:	89 04 24             	mov    %eax,(%esp)
  8012e4:	e8 80 fb ff ff       	call   800e69 <sys_page_map>
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	79 20                	jns    80130d <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  8012ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f1:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  8012f8:	00 
  8012f9:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801300:	00 
  801301:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801308:	e8 73 f0 ff ff       	call   800380 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  80130d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801311:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801315:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801320:	89 04 24             	mov    %eax,(%esp)
  801323:	e8 41 fb ff ff       	call   800e69 <sys_page_map>
  801328:	85 c0                	test   %eax,%eax
  80132a:	79 6e                	jns    80139a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80132c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801330:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  801337:	00 
  801338:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80133f:	00 
  801340:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801347:	e8 34 f0 ff ff       	call   800380 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  80134c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801353:	25 07 0e 00 00       	and    $0xe07,%eax
  801358:	89 44 24 10          	mov    %eax,0x10(%esp)
  80135c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801363:	89 44 24 08          	mov    %eax,0x8(%esp)
  801367:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80136b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80136e:	89 04 24             	mov    %eax,(%esp)
  801371:	e8 f3 fa ff ff       	call   800e69 <sys_page_map>
  801376:	85 c0                	test   %eax,%eax
  801378:	79 20                	jns    80139a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80137a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137e:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  801385:	00 
  801386:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  80138d:	00 
  80138e:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801395:	e8 e6 ef ff ff       	call   800380 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80139a:	46                   	inc    %esi
  80139b:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8013a1:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8013a7:	0f 85 5f fe ff ff    	jne    80120c <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8013ad:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013b4:	00 
  8013b5:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013bc:	ee 
  8013bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013c0:	89 04 24             	mov    %eax,(%esp)
  8013c3:	e8 4d fa ff ff       	call   800e15 <sys_page_alloc>
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	79 20                	jns    8013ec <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  8013cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d0:	c7 44 24 08 37 2c 80 	movl   $0x802c37,0x8(%esp)
  8013d7:	00 
  8013d8:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8013df:	00 
  8013e0:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  8013e7:	e8 94 ef ff ff       	call   800380 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  8013ec:	c7 44 24 04 10 23 80 	movl   $0x802310,0x4(%esp)
  8013f3:	00 
  8013f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013f7:	89 04 24             	mov    %eax,(%esp)
  8013fa:	e8 b6 fb ff ff       	call   800fb5 <sys_env_set_pgfault_upcall>
  8013ff:	85 c0                	test   %eax,%eax
  801401:	79 20                	jns    801423 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  801403:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801407:	c7 44 24 08 0c 2c 80 	movl   $0x802c0c,0x8(%esp)
  80140e:	00 
  80140f:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801416:	00 
  801417:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  80141e:	e8 5d ef ff ff       	call   800380 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  801423:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80142a:	00 
  80142b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80142e:	89 04 24             	mov    %eax,(%esp)
  801431:	e8 d9 fa ff ff       	call   800f0f <sys_env_set_status>
  801436:	85 c0                	test   %eax,%eax
  801438:	79 20                	jns    80145a <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  80143a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143e:	c7 44 24 08 6e 2c 80 	movl   $0x802c6e,0x8(%esp)
  801445:	00 
  801446:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  80144d:	00 
  80144e:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801455:	e8 26 ef ff ff       	call   800380 <_panic>

	return child_envid;
}
  80145a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80145d:	83 c4 3c             	add    $0x3c,%esp
  801460:	5b                   	pop    %ebx
  801461:	5e                   	pop    %esi
  801462:	5f                   	pop    %edi
  801463:	5d                   	pop    %ebp
  801464:	c3                   	ret    

00801465 <sfork>:

// Challenge!
int
sfork(void)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80146b:	c7 44 24 08 86 2c 80 	movl   $0x802c86,0x8(%esp)
  801472:	00 
  801473:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80147a:	00 
  80147b:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801482:	e8 f9 ee ff ff       	call   800380 <_panic>
	...

00801488 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	05 00 00 00 30       	add    $0x30000000,%eax
  801493:	c1 e8 0c             	shr    $0xc,%eax
}
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	89 04 24             	mov    %eax,(%esp)
  8014a4:	e8 df ff ff ff       	call   801488 <fd2num>
  8014a9:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014ae:	c1 e0 0c             	shl    $0xc,%eax
}
  8014b1:	c9                   	leave  
  8014b2:	c3                   	ret    

008014b3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014ba:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014bf:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	c1 ea 16             	shr    $0x16,%edx
  8014c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cd:	f6 c2 01             	test   $0x1,%dl
  8014d0:	74 11                	je     8014e3 <fd_alloc+0x30>
  8014d2:	89 c2                	mov    %eax,%edx
  8014d4:	c1 ea 0c             	shr    $0xc,%edx
  8014d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014de:	f6 c2 01             	test   $0x1,%dl
  8014e1:	75 09                	jne    8014ec <fd_alloc+0x39>
			*fd_store = fd;
  8014e3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ea:	eb 17                	jmp    801503 <fd_alloc+0x50>
  8014ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014f6:	75 c7                	jne    8014bf <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014f8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801503:	5b                   	pop    %ebx
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80150c:	83 f8 1f             	cmp    $0x1f,%eax
  80150f:	77 36                	ja     801547 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801511:	05 00 00 0d 00       	add    $0xd0000,%eax
  801516:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801519:	89 c2                	mov    %eax,%edx
  80151b:	c1 ea 16             	shr    $0x16,%edx
  80151e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801525:	f6 c2 01             	test   $0x1,%dl
  801528:	74 24                	je     80154e <fd_lookup+0x48>
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	c1 ea 0c             	shr    $0xc,%edx
  80152f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	74 1a                	je     801555 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80153b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153e:	89 02                	mov    %eax,(%edx)
	return 0;
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
  801545:	eb 13                	jmp    80155a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801547:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154c:	eb 0c                	jmp    80155a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80154e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801553:	eb 05                	jmp    80155a <fd_lookup+0x54>
  801555:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	53                   	push   %ebx
  801560:	83 ec 14             	sub    $0x14,%esp
  801563:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801569:	ba 00 00 00 00       	mov    $0x0,%edx
  80156e:	eb 0e                	jmp    80157e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801570:	39 08                	cmp    %ecx,(%eax)
  801572:	75 09                	jne    80157d <dev_lookup+0x21>
			*dev = devtab[i];
  801574:	89 03                	mov    %eax,(%ebx)
			return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
  80157b:	eb 33                	jmp    8015b0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80157d:	42                   	inc    %edx
  80157e:	8b 04 95 18 2d 80 00 	mov    0x802d18(,%edx,4),%eax
  801585:	85 c0                	test   %eax,%eax
  801587:	75 e7                	jne    801570 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801589:	a1 04 40 80 00       	mov    0x804004,%eax
  80158e:	8b 40 48             	mov    0x48(%eax),%eax
  801591:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801595:	89 44 24 04          	mov    %eax,0x4(%esp)
  801599:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  8015a0:	e8 d3 ee ff ff       	call   800478 <cprintf>
	*dev = 0;
  8015a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015b0:	83 c4 14             	add    $0x14,%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 30             	sub    $0x30,%esp
  8015be:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c1:	8a 45 0c             	mov    0xc(%ebp),%al
  8015c4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015c7:	89 34 24             	mov    %esi,(%esp)
  8015ca:	e8 b9 fe ff ff       	call   801488 <fd2num>
  8015cf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015d6:	89 04 24             	mov    %eax,(%esp)
  8015d9:	e8 28 ff ff ff       	call   801506 <fd_lookup>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	78 05                	js     8015e9 <fd_close+0x33>
	    || fd != fd2)
  8015e4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015e7:	74 0d                	je     8015f6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8015e9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8015ed:	75 46                	jne    801635 <fd_close+0x7f>
  8015ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f4:	eb 3f                	jmp    801635 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fd:	8b 06                	mov    (%esi),%eax
  8015ff:	89 04 24             	mov    %eax,(%esp)
  801602:	e8 55 ff ff ff       	call   80155c <dev_lookup>
  801607:	89 c3                	mov    %eax,%ebx
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 18                	js     801625 <fd_close+0x6f>
		if (dev->dev_close)
  80160d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801610:	8b 40 10             	mov    0x10(%eax),%eax
  801613:	85 c0                	test   %eax,%eax
  801615:	74 09                	je     801620 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801617:	89 34 24             	mov    %esi,(%esp)
  80161a:	ff d0                	call   *%eax
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	eb 05                	jmp    801625 <fd_close+0x6f>
		else
			r = 0;
  801620:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801625:	89 74 24 04          	mov    %esi,0x4(%esp)
  801629:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801630:	e8 87 f8 ff ff       	call   800ebc <sys_page_unmap>
	return r;
}
  801635:	89 d8                	mov    %ebx,%eax
  801637:	83 c4 30             	add    $0x30,%esp
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164b:	8b 45 08             	mov    0x8(%ebp),%eax
  80164e:	89 04 24             	mov    %eax,(%esp)
  801651:	e8 b0 fe ff ff       	call   801506 <fd_lookup>
  801656:	85 c0                	test   %eax,%eax
  801658:	78 13                	js     80166d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80165a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801661:	00 
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 49 ff ff ff       	call   8015b6 <fd_close>
}
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <close_all>:

void
close_all(void)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	53                   	push   %ebx
  801673:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801676:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80167b:	89 1c 24             	mov    %ebx,(%esp)
  80167e:	e8 bb ff ff ff       	call   80163e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801683:	43                   	inc    %ebx
  801684:	83 fb 20             	cmp    $0x20,%ebx
  801687:	75 f2                	jne    80167b <close_all+0xc>
		close(i);
}
  801689:	83 c4 14             	add    $0x14,%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	57                   	push   %edi
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	83 ec 4c             	sub    $0x4c,%esp
  801698:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80169b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80169e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	89 04 24             	mov    %eax,(%esp)
  8016a8:	e8 59 fe ff ff       	call   801506 <fd_lookup>
  8016ad:	89 c3                	mov    %eax,%ebx
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	0f 88 e1 00 00 00    	js     801798 <dup+0x109>
		return r;
	close(newfdnum);
  8016b7:	89 3c 24             	mov    %edi,(%esp)
  8016ba:	e8 7f ff ff ff       	call   80163e <close>

	newfd = INDEX2FD(newfdnum);
  8016bf:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016c5:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016cb:	89 04 24             	mov    %eax,(%esp)
  8016ce:	e8 c5 fd ff ff       	call   801498 <fd2data>
  8016d3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016d5:	89 34 24             	mov    %esi,(%esp)
  8016d8:	e8 bb fd ff ff       	call   801498 <fd2data>
  8016dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016e0:	89 d8                	mov    %ebx,%eax
  8016e2:	c1 e8 16             	shr    $0x16,%eax
  8016e5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016ec:	a8 01                	test   $0x1,%al
  8016ee:	74 46                	je     801736 <dup+0xa7>
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	c1 e8 0c             	shr    $0xc,%eax
  8016f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016fc:	f6 c2 01             	test   $0x1,%dl
  8016ff:	74 35                	je     801736 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801701:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801708:	25 07 0e 00 00       	and    $0xe07,%eax
  80170d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801711:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801714:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801718:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80171f:	00 
  801720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801724:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172b:	e8 39 f7 ff ff       	call   800e69 <sys_page_map>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	85 c0                	test   %eax,%eax
  801734:	78 3b                	js     801771 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801736:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801739:	89 c2                	mov    %eax,%edx
  80173b:	c1 ea 0c             	shr    $0xc,%edx
  80173e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801745:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80174b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80174f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801753:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80175a:	00 
  80175b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801766:	e8 fe f6 ff ff       	call   800e69 <sys_page_map>
  80176b:	89 c3                	mov    %eax,%ebx
  80176d:	85 c0                	test   %eax,%eax
  80176f:	79 25                	jns    801796 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801771:	89 74 24 04          	mov    %esi,0x4(%esp)
  801775:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80177c:	e8 3b f7 ff ff       	call   800ebc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801781:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801784:	89 44 24 04          	mov    %eax,0x4(%esp)
  801788:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178f:	e8 28 f7 ff ff       	call   800ebc <sys_page_unmap>
	return r;
  801794:	eb 02                	jmp    801798 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801796:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801798:	89 d8                	mov    %ebx,%eax
  80179a:	83 c4 4c             	add    $0x4c,%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5f                   	pop    %edi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 24             	sub    $0x24,%esp
  8017a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	89 1c 24             	mov    %ebx,(%esp)
  8017b6:	e8 4b fd ff ff       	call   801506 <fd_lookup>
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 6d                	js     80182c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	8b 00                	mov    (%eax),%eax
  8017cb:	89 04 24             	mov    %eax,(%esp)
  8017ce:	e8 89 fd ff ff       	call   80155c <dev_lookup>
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 55                	js     80182c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017da:	8b 50 08             	mov    0x8(%eax),%edx
  8017dd:	83 e2 03             	and    $0x3,%edx
  8017e0:	83 fa 01             	cmp    $0x1,%edx
  8017e3:	75 23                	jne    801808 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e5:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ea:	8b 40 48             	mov    0x48(%eax),%eax
  8017ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	c7 04 24 dd 2c 80 00 	movl   $0x802cdd,(%esp)
  8017fc:	e8 77 ec ff ff       	call   800478 <cprintf>
		return -E_INVAL;
  801801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801806:	eb 24                	jmp    80182c <read+0x8a>
	}
	if (!dev->dev_read)
  801808:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180b:	8b 52 08             	mov    0x8(%edx),%edx
  80180e:	85 d2                	test   %edx,%edx
  801810:	74 15                	je     801827 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801812:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801815:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801820:	89 04 24             	mov    %eax,(%esp)
  801823:	ff d2                	call   *%edx
  801825:	eb 05                	jmp    80182c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801827:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80182c:	83 c4 24             	add    $0x24,%esp
  80182f:	5b                   	pop    %ebx
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	57                   	push   %edi
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	83 ec 1c             	sub    $0x1c,%esp
  80183b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801841:	bb 00 00 00 00       	mov    $0x0,%ebx
  801846:	eb 23                	jmp    80186b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801848:	89 f0                	mov    %esi,%eax
  80184a:	29 d8                	sub    %ebx,%eax
  80184c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801850:	8b 45 0c             	mov    0xc(%ebp),%eax
  801853:	01 d8                	add    %ebx,%eax
  801855:	89 44 24 04          	mov    %eax,0x4(%esp)
  801859:	89 3c 24             	mov    %edi,(%esp)
  80185c:	e8 41 ff ff ff       	call   8017a2 <read>
		if (m < 0)
  801861:	85 c0                	test   %eax,%eax
  801863:	78 10                	js     801875 <readn+0x43>
			return m;
		if (m == 0)
  801865:	85 c0                	test   %eax,%eax
  801867:	74 0a                	je     801873 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801869:	01 c3                	add    %eax,%ebx
  80186b:	39 f3                	cmp    %esi,%ebx
  80186d:	72 d9                	jb     801848 <readn+0x16>
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	eb 02                	jmp    801875 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801873:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801875:	83 c4 1c             	add    $0x1c,%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5f                   	pop    %edi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	53                   	push   %ebx
  801881:	83 ec 24             	sub    $0x24,%esp
  801884:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801887:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80188e:	89 1c 24             	mov    %ebx,(%esp)
  801891:	e8 70 fc ff ff       	call   801506 <fd_lookup>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 68                	js     801902 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a4:	8b 00                	mov    (%eax),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	e8 ae fc ff ff       	call   80155c <dev_lookup>
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 50                	js     801902 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b9:	75 23                	jne    8018de <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8018c0:	8b 40 48             	mov    0x48(%eax),%eax
  8018c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018cb:	c7 04 24 f9 2c 80 00 	movl   $0x802cf9,(%esp)
  8018d2:	e8 a1 eb ff ff       	call   800478 <cprintf>
		return -E_INVAL;
  8018d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018dc:	eb 24                	jmp    801902 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e4:	85 d2                	test   %edx,%edx
  8018e6:	74 15                	je     8018fd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018f6:	89 04 24             	mov    %eax,(%esp)
  8018f9:	ff d2                	call   *%edx
  8018fb:	eb 05                	jmp    801902 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801902:	83 c4 24             	add    $0x24,%esp
  801905:	5b                   	pop    %ebx
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <seek>:

int
seek(int fdnum, off_t offset)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80190e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801911:	89 44 24 04          	mov    %eax,0x4(%esp)
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	89 04 24             	mov    %eax,(%esp)
  80191b:	e8 e6 fb ff ff       	call   801506 <fd_lookup>
  801920:	85 c0                	test   %eax,%eax
  801922:	78 0e                	js     801932 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801924:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	53                   	push   %ebx
  801938:	83 ec 24             	sub    $0x24,%esp
  80193b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801941:	89 44 24 04          	mov    %eax,0x4(%esp)
  801945:	89 1c 24             	mov    %ebx,(%esp)
  801948:	e8 b9 fb ff ff       	call   801506 <fd_lookup>
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 61                	js     8019b2 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801951:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195b:	8b 00                	mov    (%eax),%eax
  80195d:	89 04 24             	mov    %eax,(%esp)
  801960:	e8 f7 fb ff ff       	call   80155c <dev_lookup>
  801965:	85 c0                	test   %eax,%eax
  801967:	78 49                	js     8019b2 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801969:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801970:	75 23                	jne    801995 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801972:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801977:	8b 40 48             	mov    0x48(%eax),%eax
  80197a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801989:	e8 ea ea ff ff       	call   800478 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80198e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801993:	eb 1d                	jmp    8019b2 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801995:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801998:	8b 52 18             	mov    0x18(%edx),%edx
  80199b:	85 d2                	test   %edx,%edx
  80199d:	74 0e                	je     8019ad <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80199f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019a6:	89 04 24             	mov    %eax,(%esp)
  8019a9:	ff d2                	call   *%edx
  8019ab:	eb 05                	jmp    8019b2 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019b2:	83 c4 24             	add    $0x24,%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5d                   	pop    %ebp
  8019b7:	c3                   	ret    

008019b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	53                   	push   %ebx
  8019bc:	83 ec 24             	sub    $0x24,%esp
  8019bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	e8 32 fb ff ff       	call   801506 <fd_lookup>
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 52                	js     801a2a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e2:	8b 00                	mov    (%eax),%eax
  8019e4:	89 04 24             	mov    %eax,(%esp)
  8019e7:	e8 70 fb ff ff       	call   80155c <dev_lookup>
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 3a                	js     801a2a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019f7:	74 2c                	je     801a25 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019fc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a03:	00 00 00 
	stat->st_isdir = 0;
  801a06:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a0d:	00 00 00 
	stat->st_dev = dev;
  801a10:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a1d:	89 14 24             	mov    %edx,(%esp)
  801a20:	ff 50 14             	call   *0x14(%eax)
  801a23:	eb 05                	jmp    801a2a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a25:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a2a:	83 c4 24             	add    $0x24,%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a3f:	00 
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	89 04 24             	mov    %eax,(%esp)
  801a46:	e8 2d 02 00 00       	call   801c78 <open>
  801a4b:	89 c3                	mov    %eax,%ebx
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 1b                	js     801a6c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a58:	89 1c 24             	mov    %ebx,(%esp)
  801a5b:	e8 58 ff ff ff       	call   8019b8 <fstat>
  801a60:	89 c6                	mov    %eax,%esi
	close(fd);
  801a62:	89 1c 24             	mov    %ebx,(%esp)
  801a65:	e8 d4 fb ff ff       	call   80163e <close>
	return r;
  801a6a:	89 f3                	mov    %esi,%ebx
}
  801a6c:	89 d8                	mov    %ebx,%eax
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    
  801a75:	00 00                	add    %al,(%eax)
	...

00801a78 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 10             	sub    $0x10,%esp
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a84:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a8b:	75 11                	jne    801a9e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a94:	e8 72 09 00 00       	call   80240b <ipc_find_env>
  801a99:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a9e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801aa5:	00 
  801aa6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801aad:	00 
  801aae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab2:	a1 00 40 80 00       	mov    0x804000,%eax
  801ab7:	89 04 24             	mov    %eax,(%esp)
  801aba:	e8 de 08 00 00       	call   80239d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801abf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ac6:	00 
  801ac7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801acb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad2:	e8 5d 08 00 00       	call   802334 <ipc_recv>
}
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801af7:	ba 00 00 00 00       	mov    $0x0,%edx
  801afc:	b8 02 00 00 00       	mov    $0x2,%eax
  801b01:	e8 72 ff ff ff       	call   801a78 <fsipc>
}
  801b06:	c9                   	leave  
  801b07:	c3                   	ret    

00801b08 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	8b 40 0c             	mov    0xc(%eax),%eax
  801b14:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	b8 06 00 00 00       	mov    $0x6,%eax
  801b23:	e8 50 ff ff ff       	call   801a78 <fsipc>
}
  801b28:	c9                   	leave  
  801b29:	c3                   	ret    

00801b2a <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	53                   	push   %ebx
  801b2e:	83 ec 14             	sub    $0x14,%esp
  801b31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b44:	b8 05 00 00 00       	mov    $0x5,%eax
  801b49:	e8 2a ff ff ff       	call   801a78 <fsipc>
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 2b                	js     801b7d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b52:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b59:	00 
  801b5a:	89 1c 24             	mov    %ebx,(%esp)
  801b5d:	e8 c1 ee ff ff       	call   800a23 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b62:	a1 80 50 80 00       	mov    0x805080,%eax
  801b67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b6d:	a1 84 50 80 00       	mov    0x805084,%eax
  801b72:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7d:	83 c4 14             	add    $0x14,%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 18             	sub    $0x18,%esp
  801b89:	8b 55 10             	mov    0x10(%ebp),%edx
  801b8c:	89 d0                	mov    %edx,%eax
  801b8e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801b94:	76 05                	jbe    801b9b <devfile_write+0x18>
  801b96:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b9e:	8b 52 0c             	mov    0xc(%edx),%edx
  801ba1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801ba7:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb7:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801bbe:	e8 d9 ef ff ff       	call   800b9c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc8:	b8 04 00 00 00       	mov    $0x4,%eax
  801bcd:	e8 a6 fe ff ff       	call   801a78 <fsipc>
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 10             	sub    $0x10,%esp
  801bdc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	8b 40 0c             	mov    0xc(%eax),%eax
  801be5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf5:	b8 03 00 00 00       	mov    $0x3,%eax
  801bfa:	e8 79 fe ff ff       	call   801a78 <fsipc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 6a                	js     801c6f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c05:	39 c6                	cmp    %eax,%esi
  801c07:	73 24                	jae    801c2d <devfile_read+0x59>
  801c09:	c7 44 24 0c 28 2d 80 	movl   $0x802d28,0xc(%esp)
  801c10:	00 
  801c11:	c7 44 24 08 2f 2d 80 	movl   $0x802d2f,0x8(%esp)
  801c18:	00 
  801c19:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c20:	00 
  801c21:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  801c28:	e8 53 e7 ff ff       	call   800380 <_panic>
	assert(r <= PGSIZE);
  801c2d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c32:	7e 24                	jle    801c58 <devfile_read+0x84>
  801c34:	c7 44 24 0c 4f 2d 80 	movl   $0x802d4f,0xc(%esp)
  801c3b:	00 
  801c3c:	c7 44 24 08 2f 2d 80 	movl   $0x802d2f,0x8(%esp)
  801c43:	00 
  801c44:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c4b:	00 
  801c4c:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  801c53:	e8 28 e7 ff ff       	call   800380 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c5c:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c63:	00 
  801c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	e8 2d ef ff ff       	call   800b9c <memmove>
	return r;
}
  801c6f:	89 d8                	mov    %ebx,%eax
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    

00801c78 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	56                   	push   %esi
  801c7c:	53                   	push   %ebx
  801c7d:	83 ec 20             	sub    $0x20,%esp
  801c80:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c83:	89 34 24             	mov    %esi,(%esp)
  801c86:	e8 65 ed ff ff       	call   8009f0 <strlen>
  801c8b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c90:	7f 60                	jg     801cf2 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c95:	89 04 24             	mov    %eax,(%esp)
  801c98:	e8 16 f8 ff ff       	call   8014b3 <fd_alloc>
  801c9d:	89 c3                	mov    %eax,%ebx
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 54                	js     801cf7 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ca3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ca7:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cae:	e8 70 ed ff ff       	call   800a23 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cbb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cbe:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc3:	e8 b0 fd ff ff       	call   801a78 <fsipc>
  801cc8:	89 c3                	mov    %eax,%ebx
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	79 15                	jns    801ce3 <open+0x6b>
		fd_close(fd, 0);
  801cce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cd5:	00 
  801cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd9:	89 04 24             	mov    %eax,(%esp)
  801cdc:	e8 d5 f8 ff ff       	call   8015b6 <fd_close>
		return r;
  801ce1:	eb 14                	jmp    801cf7 <open+0x7f>
	}

	return fd2num(fd);
  801ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce6:	89 04 24             	mov    %eax,(%esp)
  801ce9:	e8 9a f7 ff ff       	call   801488 <fd2num>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	eb 05                	jmp    801cf7 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801cf2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801cf7:	89 d8                	mov    %ebx,%eax
  801cf9:	83 c4 20             	add    $0x20,%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5d                   	pop    %ebp
  801cff:	c3                   	ret    

00801d00 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d06:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0b:	b8 08 00 00 00       	mov    $0x8,%eax
  801d10:	e8 63 fd ff ff       	call   801a78 <fsipc>
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    
	...

00801d18 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d18:	55                   	push   %ebp
  801d19:	89 e5                	mov    %esp,%ebp
  801d1b:	56                   	push   %esi
  801d1c:	53                   	push   %ebx
  801d1d:	83 ec 10             	sub    $0x10,%esp
  801d20:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d23:	8b 45 08             	mov    0x8(%ebp),%eax
  801d26:	89 04 24             	mov    %eax,(%esp)
  801d29:	e8 6a f7 ff ff       	call   801498 <fd2data>
  801d2e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801d30:	c7 44 24 04 5b 2d 80 	movl   $0x802d5b,0x4(%esp)
  801d37:	00 
  801d38:	89 34 24             	mov    %esi,(%esp)
  801d3b:	e8 e3 ec ff ff       	call   800a23 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d40:	8b 43 04             	mov    0x4(%ebx),%eax
  801d43:	2b 03                	sub    (%ebx),%eax
  801d45:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801d4b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d52:	00 00 00 
	stat->st_dev = &devpipe;
  801d55:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  801d5c:	30 80 00 
	return 0;
}
  801d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 14             	sub    $0x14,%esp
  801d72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d80:	e8 37 f1 ff ff       	call   800ebc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d85:	89 1c 24             	mov    %ebx,(%esp)
  801d88:	e8 0b f7 ff ff       	call   801498 <fd2data>
  801d8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d98:	e8 1f f1 ff ff       	call   800ebc <sys_page_unmap>
}
  801d9d:	83 c4 14             	add    $0x14,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	57                   	push   %edi
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 2c             	sub    $0x2c,%esp
  801dac:	89 c7                	mov    %eax,%edi
  801dae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801db1:	a1 04 40 80 00       	mov    0x804004,%eax
  801db6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801db9:	89 3c 24             	mov    %edi,(%esp)
  801dbc:	e8 8f 06 00 00       	call   802450 <pageref>
  801dc1:	89 c6                	mov    %eax,%esi
  801dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dc6:	89 04 24             	mov    %eax,(%esp)
  801dc9:	e8 82 06 00 00       	call   802450 <pageref>
  801dce:	39 c6                	cmp    %eax,%esi
  801dd0:	0f 94 c0             	sete   %al
  801dd3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801dd6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ddc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ddf:	39 cb                	cmp    %ecx,%ebx
  801de1:	75 08                	jne    801deb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801de3:	83 c4 2c             	add    $0x2c,%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801deb:	83 f8 01             	cmp    $0x1,%eax
  801dee:	75 c1                	jne    801db1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801df0:	8b 42 58             	mov    0x58(%edx),%eax
  801df3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801dfa:	00 
  801dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e03:	c7 04 24 62 2d 80 00 	movl   $0x802d62,(%esp)
  801e0a:	e8 69 e6 ff ff       	call   800478 <cprintf>
  801e0f:	eb a0                	jmp    801db1 <_pipeisclosed+0xe>

00801e11 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	57                   	push   %edi
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	83 ec 1c             	sub    $0x1c,%esp
  801e1a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801e1d:	89 34 24             	mov    %esi,(%esp)
  801e20:	e8 73 f6 ff ff       	call   801498 <fd2data>
  801e25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e27:	bf 00 00 00 00       	mov    $0x0,%edi
  801e2c:	eb 3c                	jmp    801e6a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801e2e:	89 da                	mov    %ebx,%edx
  801e30:	89 f0                	mov    %esi,%eax
  801e32:	e8 6c ff ff ff       	call   801da3 <_pipeisclosed>
  801e37:	85 c0                	test   %eax,%eax
  801e39:	75 38                	jne    801e73 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801e3b:	e8 b6 ef ff ff       	call   800df6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e40:	8b 43 04             	mov    0x4(%ebx),%eax
  801e43:	8b 13                	mov    (%ebx),%edx
  801e45:	83 c2 20             	add    $0x20,%edx
  801e48:	39 d0                	cmp    %edx,%eax
  801e4a:	73 e2                	jae    801e2e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e52:	89 c2                	mov    %eax,%edx
  801e54:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e5a:	79 05                	jns    801e61 <devpipe_write+0x50>
  801e5c:	4a                   	dec    %edx
  801e5d:	83 ca e0             	or     $0xffffffe0,%edx
  801e60:	42                   	inc    %edx
  801e61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e65:	40                   	inc    %eax
  801e66:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e69:	47                   	inc    %edi
  801e6a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6d:	75 d1                	jne    801e40 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e6f:	89 f8                	mov    %edi,%eax
  801e71:	eb 05                	jmp    801e78 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e78:	83 c4 1c             	add    $0x1c,%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5f                   	pop    %edi
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	57                   	push   %edi
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 1c             	sub    $0x1c,%esp
  801e89:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e8c:	89 3c 24             	mov    %edi,(%esp)
  801e8f:	e8 04 f6 ff ff       	call   801498 <fd2data>
  801e94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e96:	be 00 00 00 00       	mov    $0x0,%esi
  801e9b:	eb 3a                	jmp    801ed7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e9d:	85 f6                	test   %esi,%esi
  801e9f:	74 04                	je     801ea5 <devpipe_read+0x25>
				return i;
  801ea1:	89 f0                	mov    %esi,%eax
  801ea3:	eb 40                	jmp    801ee5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ea5:	89 da                	mov    %ebx,%edx
  801ea7:	89 f8                	mov    %edi,%eax
  801ea9:	e8 f5 fe ff ff       	call   801da3 <_pipeisclosed>
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	75 2e                	jne    801ee0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801eb2:	e8 3f ef ff ff       	call   800df6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801eb7:	8b 03                	mov    (%ebx),%eax
  801eb9:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ebc:	74 df                	je     801e9d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ebe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801ec3:	79 05                	jns    801eca <devpipe_read+0x4a>
  801ec5:	48                   	dec    %eax
  801ec6:	83 c8 e0             	or     $0xffffffe0,%eax
  801ec9:	40                   	inc    %eax
  801eca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801ed4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ed6:	46                   	inc    %esi
  801ed7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eda:	75 db                	jne    801eb7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801edc:	89 f0                	mov    %esi,%eax
  801ede:	eb 05                	jmp    801ee5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	57                   	push   %edi
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 3c             	sub    $0x3c,%esp
  801ef6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ef9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801efc:	89 04 24             	mov    %eax,(%esp)
  801eff:	e8 af f5 ff ff       	call   8014b3 <fd_alloc>
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	85 c0                	test   %eax,%eax
  801f08:	0f 88 45 01 00 00    	js     802053 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f0e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f15:	00 
  801f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f24:	e8 ec ee ff ff       	call   800e15 <sys_page_alloc>
  801f29:	89 c3                	mov    %eax,%ebx
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	0f 88 20 01 00 00    	js     802053 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f33:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f36:	89 04 24             	mov    %eax,(%esp)
  801f39:	e8 75 f5 ff ff       	call   8014b3 <fd_alloc>
  801f3e:	89 c3                	mov    %eax,%ebx
  801f40:	85 c0                	test   %eax,%eax
  801f42:	0f 88 f8 00 00 00    	js     802040 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f48:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f4f:	00 
  801f50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f5e:	e8 b2 ee ff ff       	call   800e15 <sys_page_alloc>
  801f63:	89 c3                	mov    %eax,%ebx
  801f65:	85 c0                	test   %eax,%eax
  801f67:	0f 88 d3 00 00 00    	js     802040 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	e8 20 f5 ff ff       	call   801498 <fd2data>
  801f78:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f7a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f81:	00 
  801f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f8d:	e8 83 ee ff ff       	call   800e15 <sys_page_alloc>
  801f92:	89 c3                	mov    %eax,%ebx
  801f94:	85 c0                	test   %eax,%eax
  801f96:	0f 88 91 00 00 00    	js     80202d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f9f:	89 04 24             	mov    %eax,(%esp)
  801fa2:	e8 f1 f4 ff ff       	call   801498 <fd2data>
  801fa7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801fae:	00 
  801faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fba:	00 
  801fbb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fc6:	e8 9e ee ff ff       	call   800e69 <sys_page_map>
  801fcb:	89 c3                	mov    %eax,%ebx
  801fcd:	85 c0                	test   %eax,%eax
  801fcf:	78 4c                	js     80201d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801fd1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fda:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fdf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fe6:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ff1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ff4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ffe:	89 04 24             	mov    %eax,(%esp)
  802001:	e8 82 f4 ff ff       	call   801488 <fd2num>
  802006:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802008:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80200b:	89 04 24             	mov    %eax,(%esp)
  80200e:	e8 75 f4 ff ff       	call   801488 <fd2num>
  802013:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802016:	bb 00 00 00 00       	mov    $0x0,%ebx
  80201b:	eb 36                	jmp    802053 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80201d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802021:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802028:	e8 8f ee ff ff       	call   800ebc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80202d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802030:	89 44 24 04          	mov    %eax,0x4(%esp)
  802034:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203b:	e8 7c ee ff ff       	call   800ebc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802040:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802043:	89 44 24 04          	mov    %eax,0x4(%esp)
  802047:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204e:	e8 69 ee ff ff       	call   800ebc <sys_page_unmap>
    err:
	return r;
}
  802053:	89 d8                	mov    %ebx,%eax
  802055:	83 c4 3c             	add    $0x3c,%esp
  802058:	5b                   	pop    %ebx
  802059:	5e                   	pop    %esi
  80205a:	5f                   	pop    %edi
  80205b:	5d                   	pop    %ebp
  80205c:	c3                   	ret    

0080205d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
  80206d:	89 04 24             	mov    %eax,(%esp)
  802070:	e8 91 f4 ff ff       	call   801506 <fd_lookup>
  802075:	85 c0                	test   %eax,%eax
  802077:	78 15                	js     80208e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207c:	89 04 24             	mov    %eax,(%esp)
  80207f:	e8 14 f4 ff ff       	call   801498 <fd2data>
	return _pipeisclosed(fd, p);
  802084:	89 c2                	mov    %eax,%edx
  802086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802089:	e8 15 fd ff ff       	call   801da3 <_pipeisclosed>
}
  80208e:	c9                   	leave  
  80208f:	c3                   	ret    

00802090 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	56                   	push   %esi
  802094:	53                   	push   %ebx
  802095:	83 ec 10             	sub    $0x10,%esp
  802098:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80209b:	85 f6                	test   %esi,%esi
  80209d:	75 24                	jne    8020c3 <wait+0x33>
  80209f:	c7 44 24 0c 7a 2d 80 	movl   $0x802d7a,0xc(%esp)
  8020a6:	00 
  8020a7:	c7 44 24 08 2f 2d 80 	movl   $0x802d2f,0x8(%esp)
  8020ae:	00 
  8020af:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8020b6:	00 
  8020b7:	c7 04 24 85 2d 80 00 	movl   $0x802d85,(%esp)
  8020be:	e8 bd e2 ff ff       	call   800380 <_panic>
	e = &envs[ENVX(envid)];
  8020c3:	89 f3                	mov    %esi,%ebx
  8020c5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8020cb:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  8020d2:	c1 e3 07             	shl    $0x7,%ebx
  8020d5:	29 c3                	sub    %eax,%ebx
  8020d7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8020dd:	eb 05                	jmp    8020e4 <wait+0x54>
		sys_yield();
  8020df:	e8 12 ed ff ff       	call   800df6 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8020e4:	8b 43 48             	mov    0x48(%ebx),%eax
  8020e7:	39 f0                	cmp    %esi,%eax
  8020e9:	75 07                	jne    8020f2 <wait+0x62>
  8020eb:	8b 43 54             	mov    0x54(%ebx),%eax
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	75 ed                	jne    8020df <wait+0x4f>
		sys_yield();
}
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	00 00                	add    %al,(%eax)
	...

008020fc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    

00802106 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80210c:	c7 44 24 04 90 2d 80 	movl   $0x802d90,0x4(%esp)
  802113:	00 
  802114:	8b 45 0c             	mov    0xc(%ebp),%eax
  802117:	89 04 24             	mov    %eax,(%esp)
  80211a:	e8 04 e9 ff ff       	call   800a23 <strcpy>
	return 0;
}
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
  802124:	c9                   	leave  
  802125:	c3                   	ret    

00802126 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	57                   	push   %edi
  80212a:	56                   	push   %esi
  80212b:	53                   	push   %ebx
  80212c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802132:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802137:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80213d:	eb 30                	jmp    80216f <devcons_write+0x49>
		m = n - tot;
  80213f:	8b 75 10             	mov    0x10(%ebp),%esi
  802142:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802144:	83 fe 7f             	cmp    $0x7f,%esi
  802147:	76 05                	jbe    80214e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802149:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80214e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802152:	03 45 0c             	add    0xc(%ebp),%eax
  802155:	89 44 24 04          	mov    %eax,0x4(%esp)
  802159:	89 3c 24             	mov    %edi,(%esp)
  80215c:	e8 3b ea ff ff       	call   800b9c <memmove>
		sys_cputs(buf, m);
  802161:	89 74 24 04          	mov    %esi,0x4(%esp)
  802165:	89 3c 24             	mov    %edi,(%esp)
  802168:	e8 db eb ff ff       	call   800d48 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80216d:	01 f3                	add    %esi,%ebx
  80216f:	89 d8                	mov    %ebx,%eax
  802171:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802174:	72 c9                	jb     80213f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802176:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    

00802181 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802187:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80218b:	75 07                	jne    802194 <devcons_read+0x13>
  80218d:	eb 25                	jmp    8021b4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80218f:	e8 62 ec ff ff       	call   800df6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802194:	e8 cd eb ff ff       	call   800d66 <sys_cgetc>
  802199:	85 c0                	test   %eax,%eax
  80219b:	74 f2                	je     80218f <devcons_read+0xe>
  80219d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80219f:	85 c0                	test   %eax,%eax
  8021a1:	78 1d                	js     8021c0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021a3:	83 f8 04             	cmp    $0x4,%eax
  8021a6:	74 13                	je     8021bb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ab:	88 10                	mov    %dl,(%eax)
	return 1;
  8021ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b2:	eb 0c                	jmp    8021c0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b9:	eb 05                	jmp    8021c0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021bb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021d5:	00 
  8021d6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021d9:	89 04 24             	mov    %eax,(%esp)
  8021dc:	e8 67 eb ff ff       	call   800d48 <sys_cputs>
}
  8021e1:	c9                   	leave  
  8021e2:	c3                   	ret    

008021e3 <getchar>:

int
getchar(void)
{
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8021e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8021f0:	00 
  8021f1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021ff:	e8 9e f5 ff ff       	call   8017a2 <read>
	if (r < 0)
  802204:	85 c0                	test   %eax,%eax
  802206:	78 0f                	js     802217 <getchar+0x34>
		return r;
	if (r < 1)
  802208:	85 c0                	test   %eax,%eax
  80220a:	7e 06                	jle    802212 <getchar+0x2f>
		return -E_EOF;
	return c;
  80220c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802210:	eb 05                	jmp    802217 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802212:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802217:	c9                   	leave  
  802218:	c3                   	ret    

00802219 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802219:	55                   	push   %ebp
  80221a:	89 e5                	mov    %esp,%ebp
  80221c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80221f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802222:	89 44 24 04          	mov    %eax,0x4(%esp)
  802226:	8b 45 08             	mov    0x8(%ebp),%eax
  802229:	89 04 24             	mov    %eax,(%esp)
  80222c:	e8 d5 f2 ff ff       	call   801506 <fd_lookup>
  802231:	85 c0                	test   %eax,%eax
  802233:	78 11                	js     802246 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80223e:	39 10                	cmp    %edx,(%eax)
  802240:	0f 94 c0             	sete   %al
  802243:	0f b6 c0             	movzbl %al,%eax
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <opencons>:

int
opencons(void)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80224e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802251:	89 04 24             	mov    %eax,(%esp)
  802254:	e8 5a f2 ff ff       	call   8014b3 <fd_alloc>
  802259:	85 c0                	test   %eax,%eax
  80225b:	78 3c                	js     802299 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80225d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802264:	00 
  802265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802273:	e8 9d eb ff ff       	call   800e15 <sys_page_alloc>
  802278:	85 c0                	test   %eax,%eax
  80227a:	78 1d                	js     802299 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80227c:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802285:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802287:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802291:	89 04 24             	mov    %eax,(%esp)
  802294:	e8 ef f1 ff ff       	call   801488 <fd2num>
}
  802299:	c9                   	leave  
  80229a:	c3                   	ret    
	...

0080229c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022a2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8022a9:	75 58                	jne    802303 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8022ab:	a1 04 40 80 00       	mov    0x804004,%eax
  8022b0:	8b 40 48             	mov    0x48(%eax),%eax
  8022b3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022ba:	00 
  8022bb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8022c2:	ee 
  8022c3:	89 04 24             	mov    %eax,(%esp)
  8022c6:	e8 4a eb ff ff       	call   800e15 <sys_page_alloc>
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	74 1c                	je     8022eb <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  8022cf:	c7 44 24 08 9c 2d 80 	movl   $0x802d9c,0x8(%esp)
  8022d6:	00 
  8022d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8022de:	00 
  8022df:	c7 04 24 b1 2d 80 00 	movl   $0x802db1,(%esp)
  8022e6:	e8 95 e0 ff ff       	call   800380 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8022eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8022f0:	8b 40 48             	mov    0x48(%eax),%eax
  8022f3:	c7 44 24 04 10 23 80 	movl   $0x802310,0x4(%esp)
  8022fa:	00 
  8022fb:	89 04 24             	mov    %eax,(%esp)
  8022fe:	e8 b2 ec ff ff       	call   800fb5 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802303:	8b 45 08             	mov    0x8(%ebp),%eax
  802306:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80230b:	c9                   	leave  
  80230c:	c3                   	ret    
  80230d:	00 00                	add    %al,(%eax)
	...

00802310 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802310:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802311:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802316:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802318:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80231b:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80231f:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802321:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802325:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802326:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802329:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80232b:	58                   	pop    %eax
	popl %eax
  80232c:	58                   	pop    %eax

	// Pop all registers back
	popal
  80232d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80232e:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802331:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802332:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802333:	c3                   	ret    

00802334 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	56                   	push   %esi
  802338:	53                   	push   %ebx
  802339:	83 ec 10             	sub    $0x10,%esp
  80233c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80233f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802342:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802345:	85 c0                	test   %eax,%eax
  802347:	75 05                	jne    80234e <ipc_recv+0x1a>
  802349:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80234e:	89 04 24             	mov    %eax,(%esp)
  802351:	e8 d5 ec ff ff       	call   80102b <sys_ipc_recv>
	if (from_env_store != NULL)
  802356:	85 db                	test   %ebx,%ebx
  802358:	74 0b                	je     802365 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80235a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802360:	8b 52 74             	mov    0x74(%edx),%edx
  802363:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802365:	85 f6                	test   %esi,%esi
  802367:	74 0b                	je     802374 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802369:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80236f:	8b 52 78             	mov    0x78(%edx),%edx
  802372:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802374:	85 c0                	test   %eax,%eax
  802376:	79 16                	jns    80238e <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802378:	85 db                	test   %ebx,%ebx
  80237a:	74 06                	je     802382 <ipc_recv+0x4e>
			*from_env_store = 0;
  80237c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802382:	85 f6                	test   %esi,%esi
  802384:	74 10                	je     802396 <ipc_recv+0x62>
			*perm_store = 0;
  802386:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80238c:	eb 08                	jmp    802396 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80238e:	a1 04 40 80 00       	mov    0x804004,%eax
  802393:	8b 40 70             	mov    0x70(%eax),%eax
}
  802396:	83 c4 10             	add    $0x10,%esp
  802399:	5b                   	pop    %ebx
  80239a:	5e                   	pop    %esi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    

0080239d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	57                   	push   %edi
  8023a1:	56                   	push   %esi
  8023a2:	53                   	push   %ebx
  8023a3:	83 ec 1c             	sub    $0x1c,%esp
  8023a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8023ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8023af:	eb 2a                	jmp    8023db <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8023b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023b4:	74 20                	je     8023d6 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8023b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ba:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8023c1:	00 
  8023c2:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8023c9:	00 
  8023ca:	c7 04 24 e8 2d 80 00 	movl   $0x802de8,(%esp)
  8023d1:	e8 aa df ff ff       	call   800380 <_panic>
		sys_yield();
  8023d6:	e8 1b ea ff ff       	call   800df6 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8023db:	85 db                	test   %ebx,%ebx
  8023dd:	75 07                	jne    8023e6 <ipc_send+0x49>
  8023df:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023e4:	eb 02                	jmp    8023e8 <ipc_send+0x4b>
  8023e6:	89 d8                	mov    %ebx,%eax
  8023e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8023eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8023ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8023f7:	89 34 24             	mov    %esi,(%esp)
  8023fa:	e8 09 ec ff ff       	call   801008 <sys_ipc_try_send>
  8023ff:	85 c0                	test   %eax,%eax
  802401:	78 ae                	js     8023b1 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802403:	83 c4 1c             	add    $0x1c,%esp
  802406:	5b                   	pop    %ebx
  802407:	5e                   	pop    %esi
  802408:	5f                   	pop    %edi
  802409:	5d                   	pop    %ebp
  80240a:	c3                   	ret    

0080240b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80240b:	55                   	push   %ebp
  80240c:	89 e5                	mov    %esp,%ebp
  80240e:	53                   	push   %ebx
  80240f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802412:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802417:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80241e:	89 c2                	mov    %eax,%edx
  802420:	c1 e2 07             	shl    $0x7,%edx
  802423:	29 ca                	sub    %ecx,%edx
  802425:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80242b:	8b 52 50             	mov    0x50(%edx),%edx
  80242e:	39 da                	cmp    %ebx,%edx
  802430:	75 0f                	jne    802441 <ipc_find_env+0x36>
			return envs[i].env_id;
  802432:	c1 e0 07             	shl    $0x7,%eax
  802435:	29 c8                	sub    %ecx,%eax
  802437:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80243c:	8b 40 40             	mov    0x40(%eax),%eax
  80243f:	eb 0c                	jmp    80244d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802441:	40                   	inc    %eax
  802442:	3d 00 04 00 00       	cmp    $0x400,%eax
  802447:	75 ce                	jne    802417 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802449:	66 b8 00 00          	mov    $0x0,%ax
}
  80244d:	5b                   	pop    %ebx
  80244e:	5d                   	pop    %ebp
  80244f:	c3                   	ret    

00802450 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802456:	89 c2                	mov    %eax,%edx
  802458:	c1 ea 16             	shr    $0x16,%edx
  80245b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802462:	f6 c2 01             	test   $0x1,%dl
  802465:	74 1e                	je     802485 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802467:	c1 e8 0c             	shr    $0xc,%eax
  80246a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802471:	a8 01                	test   $0x1,%al
  802473:	74 17                	je     80248c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802475:	c1 e8 0c             	shr    $0xc,%eax
  802478:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80247f:	ef 
  802480:	0f b7 c0             	movzwl %ax,%eax
  802483:	eb 0c                	jmp    802491 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802485:	b8 00 00 00 00       	mov    $0x0,%eax
  80248a:	eb 05                	jmp    802491 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80248c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802491:	5d                   	pop    %ebp
  802492:	c3                   	ret    
	...

00802494 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802494:	55                   	push   %ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	83 ec 10             	sub    $0x10,%esp
  80249a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80249e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8024a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024a6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8024aa:	89 cd                	mov    %ecx,%ebp
  8024ac:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8024b0:	85 c0                	test   %eax,%eax
  8024b2:	75 2c                	jne    8024e0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8024b4:	39 f9                	cmp    %edi,%ecx
  8024b6:	77 68                	ja     802520 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024b8:	85 c9                	test   %ecx,%ecx
  8024ba:	75 0b                	jne    8024c7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c1:	31 d2                	xor    %edx,%edx
  8024c3:	f7 f1                	div    %ecx
  8024c5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024c7:	31 d2                	xor    %edx,%edx
  8024c9:	89 f8                	mov    %edi,%eax
  8024cb:	f7 f1                	div    %ecx
  8024cd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024cf:	89 f0                	mov    %esi,%eax
  8024d1:	f7 f1                	div    %ecx
  8024d3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024d5:	89 f0                	mov    %esi,%eax
  8024d7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024d9:	83 c4 10             	add    $0x10,%esp
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024e0:	39 f8                	cmp    %edi,%eax
  8024e2:	77 2c                	ja     802510 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8024e4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8024e7:	83 f6 1f             	xor    $0x1f,%esi
  8024ea:	75 4c                	jne    802538 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024ec:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024ee:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024f3:	72 0a                	jb     8024ff <__udivdi3+0x6b>
  8024f5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8024f9:	0f 87 ad 00 00 00    	ja     8025ac <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024ff:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802504:	89 f0                	mov    %esi,%eax
  802506:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802508:	83 c4 10             	add    $0x10,%esp
  80250b:	5e                   	pop    %esi
  80250c:	5f                   	pop    %edi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    
  80250f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802510:	31 ff                	xor    %edi,%edi
  802512:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802514:	89 f0                	mov    %esi,%eax
  802516:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802518:	83 c4 10             	add    $0x10,%esp
  80251b:	5e                   	pop    %esi
  80251c:	5f                   	pop    %edi
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    
  80251f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802520:	89 fa                	mov    %edi,%edx
  802522:	89 f0                	mov    %esi,%eax
  802524:	f7 f1                	div    %ecx
  802526:	89 c6                	mov    %eax,%esi
  802528:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80252a:	89 f0                	mov    %esi,%eax
  80252c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80252e:	83 c4 10             	add    $0x10,%esp
  802531:	5e                   	pop    %esi
  802532:	5f                   	pop    %edi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    
  802535:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802538:	89 f1                	mov    %esi,%ecx
  80253a:	d3 e0                	shl    %cl,%eax
  80253c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802540:	b8 20 00 00 00       	mov    $0x20,%eax
  802545:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802547:	89 ea                	mov    %ebp,%edx
  802549:	88 c1                	mov    %al,%cl
  80254b:	d3 ea                	shr    %cl,%edx
  80254d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802551:	09 ca                	or     %ecx,%edx
  802553:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802557:	89 f1                	mov    %esi,%ecx
  802559:	d3 e5                	shl    %cl,%ebp
  80255b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80255f:	89 fd                	mov    %edi,%ebp
  802561:	88 c1                	mov    %al,%cl
  802563:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802565:	89 fa                	mov    %edi,%edx
  802567:	89 f1                	mov    %esi,%ecx
  802569:	d3 e2                	shl    %cl,%edx
  80256b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80256f:	88 c1                	mov    %al,%cl
  802571:	d3 ef                	shr    %cl,%edi
  802573:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802575:	89 f8                	mov    %edi,%eax
  802577:	89 ea                	mov    %ebp,%edx
  802579:	f7 74 24 08          	divl   0x8(%esp)
  80257d:	89 d1                	mov    %edx,%ecx
  80257f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802581:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802585:	39 d1                	cmp    %edx,%ecx
  802587:	72 17                	jb     8025a0 <__udivdi3+0x10c>
  802589:	74 09                	je     802594 <__udivdi3+0x100>
  80258b:	89 fe                	mov    %edi,%esi
  80258d:	31 ff                	xor    %edi,%edi
  80258f:	e9 41 ff ff ff       	jmp    8024d5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802594:	8b 54 24 04          	mov    0x4(%esp),%edx
  802598:	89 f1                	mov    %esi,%ecx
  80259a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80259c:	39 c2                	cmp    %eax,%edx
  80259e:	73 eb                	jae    80258b <__udivdi3+0xf7>
		{
		  q0--;
  8025a0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8025a3:	31 ff                	xor    %edi,%edi
  8025a5:	e9 2b ff ff ff       	jmp    8024d5 <__udivdi3+0x41>
  8025aa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025ac:	31 f6                	xor    %esi,%esi
  8025ae:	e9 22 ff ff ff       	jmp    8024d5 <__udivdi3+0x41>
	...

008025b4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8025b4:	55                   	push   %ebp
  8025b5:	57                   	push   %edi
  8025b6:	56                   	push   %esi
  8025b7:	83 ec 20             	sub    $0x20,%esp
  8025ba:	8b 44 24 30          	mov    0x30(%esp),%eax
  8025be:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8025c2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8025c6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8025ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ce:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8025d2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8025d4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8025d6:	85 ed                	test   %ebp,%ebp
  8025d8:	75 16                	jne    8025f0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8025da:	39 f1                	cmp    %esi,%ecx
  8025dc:	0f 86 a6 00 00 00    	jbe    802688 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8025e4:	89 d0                	mov    %edx,%eax
  8025e6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025e8:	83 c4 20             	add    $0x20,%esp
  8025eb:	5e                   	pop    %esi
  8025ec:	5f                   	pop    %edi
  8025ed:	5d                   	pop    %ebp
  8025ee:	c3                   	ret    
  8025ef:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025f0:	39 f5                	cmp    %esi,%ebp
  8025f2:	0f 87 ac 00 00 00    	ja     8026a4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8025f8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8025fb:	83 f0 1f             	xor    $0x1f,%eax
  8025fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  802602:	0f 84 a8 00 00 00    	je     8026b0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802608:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80260c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80260e:	bf 20 00 00 00       	mov    $0x20,%edi
  802613:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802617:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80261b:	89 f9                	mov    %edi,%ecx
  80261d:	d3 e8                	shr    %cl,%eax
  80261f:	09 e8                	or     %ebp,%eax
  802621:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802625:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802629:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80262d:	d3 e0                	shl    %cl,%eax
  80262f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802633:	89 f2                	mov    %esi,%edx
  802635:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802637:	8b 44 24 14          	mov    0x14(%esp),%eax
  80263b:	d3 e0                	shl    %cl,%eax
  80263d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802641:	8b 44 24 14          	mov    0x14(%esp),%eax
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e8                	shr    %cl,%eax
  802649:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80264b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	f7 74 24 18          	divl   0x18(%esp)
  802653:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802655:	f7 64 24 0c          	mull   0xc(%esp)
  802659:	89 c5                	mov    %eax,%ebp
  80265b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80265d:	39 d6                	cmp    %edx,%esi
  80265f:	72 67                	jb     8026c8 <__umoddi3+0x114>
  802661:	74 75                	je     8026d8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802663:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802667:	29 e8                	sub    %ebp,%eax
  802669:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80266b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80266f:	d3 e8                	shr    %cl,%eax
  802671:	89 f2                	mov    %esi,%edx
  802673:	89 f9                	mov    %edi,%ecx
  802675:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802677:	09 d0                	or     %edx,%eax
  802679:	89 f2                	mov    %esi,%edx
  80267b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80267f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802681:	83 c4 20             	add    $0x20,%esp
  802684:	5e                   	pop    %esi
  802685:	5f                   	pop    %edi
  802686:	5d                   	pop    %ebp
  802687:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802688:	85 c9                	test   %ecx,%ecx
  80268a:	75 0b                	jne    802697 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80268c:	b8 01 00 00 00       	mov    $0x1,%eax
  802691:	31 d2                	xor    %edx,%edx
  802693:	f7 f1                	div    %ecx
  802695:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802697:	89 f0                	mov    %esi,%eax
  802699:	31 d2                	xor    %edx,%edx
  80269b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80269d:	89 f8                	mov    %edi,%eax
  80269f:	e9 3e ff ff ff       	jmp    8025e2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8026a4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026a6:	83 c4 20             	add    $0x20,%esp
  8026a9:	5e                   	pop    %esi
  8026aa:	5f                   	pop    %edi
  8026ab:	5d                   	pop    %ebp
  8026ac:	c3                   	ret    
  8026ad:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8026b0:	39 f5                	cmp    %esi,%ebp
  8026b2:	72 04                	jb     8026b8 <__umoddi3+0x104>
  8026b4:	39 f9                	cmp    %edi,%ecx
  8026b6:	77 06                	ja     8026be <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8026b8:	89 f2                	mov    %esi,%edx
  8026ba:	29 cf                	sub    %ecx,%edi
  8026bc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8026be:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8026c0:	83 c4 20             	add    $0x20,%esp
  8026c3:	5e                   	pop    %esi
  8026c4:	5f                   	pop    %edi
  8026c5:	5d                   	pop    %ebp
  8026c6:	c3                   	ret    
  8026c7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8026c8:	89 d1                	mov    %edx,%ecx
  8026ca:	89 c5                	mov    %eax,%ebp
  8026cc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8026d0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8026d4:	eb 8d                	jmp    802663 <__umoddi3+0xaf>
  8026d6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026d8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8026dc:	72 ea                	jb     8026c8 <__umoddi3+0x114>
  8026de:	89 f1                	mov    %esi,%ecx
  8026e0:	eb 81                	jmp    802663 <__umoddi3+0xaf>
