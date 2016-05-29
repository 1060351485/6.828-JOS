
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
  80003c:	c7 05 04 40 80 00 40 	movl   $0x802c40,0x804004
  800043:	2c 80 00 

	if ((i = pipe(p)) < 0)
  800046:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 04 24 00 00       	call   802455 <pipe>
  800051:	89 c6                	mov    %eax,%esi
  800053:	85 c0                	test   %eax,%eax
  800055:	79 20                	jns    800077 <umain+0x43>
		panic("pipe: %e", i);
  800057:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005b:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  800062:	00 
  800063:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  80006a:	00 
  80006b:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  800072:	e8 fd 02 00 00       	call   800374 <_panic>

	if ((pid = fork()) < 0)
  800077:	e8 87 11 00 00       	call   801203 <fork>
  80007c:	89 c3                	mov    %eax,%ebx
  80007e:	85 c0                	test   %eax,%eax
  800080:	79 20                	jns    8000a2 <umain+0x6e>
		panic("fork: %e", i);
  800082:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800086:	c7 44 24 08 65 2c 80 	movl   $0x802c65,0x8(%esp)
  80008d:	00 
  80008e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800095:	00 
  800096:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  80009d:	e8 d2 02 00 00       	call   800374 <_panic>

	if (pid == 0) {
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 85 d5 00 00 00    	jne    80017f <umain+0x14b>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  8000aa:	a1 08 50 80 00       	mov    0x805008,%eax
  8000af:	8b 40 48             	mov    0x48(%eax),%eax
  8000b2:	8b 55 90             	mov    -0x70(%ebp),%edx
  8000b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bd:	c7 04 24 6e 2c 80 00 	movl   $0x802c6e,(%esp)
  8000c4:	e8 a3 03 00 00       	call   80046c <cprintf>
		close(p[1]);
  8000c9:	8b 45 90             	mov    -0x70(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 d6 15 00 00       	call   8016aa <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000d4:	a1 08 50 80 00       	mov    0x805008,%eax
  8000d9:	8b 40 48             	mov    0x48(%eax),%eax
  8000dc:	8b 55 8c             	mov    -0x74(%ebp),%edx
  8000df:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e7:	c7 04 24 8b 2c 80 00 	movl   $0x802c8b,(%esp)
  8000ee:	e8 79 03 00 00       	call   80046c <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000f3:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000fa:	00 
  8000fb:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800102:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800105:	89 04 24             	mov    %eax,(%esp)
  800108:	e8 91 17 00 00       	call   80189e <readn>
  80010d:	89 c6                	mov    %eax,%esi
		if (i < 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0xff>
			panic("read: %e", i);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 a8 2c 80 	movl   $0x802ca8,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  80012e:	e8 41 02 00 00       	call   800374 <_panic>
		buf[i] = 0;
  800133:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  800138:	a1 00 40 80 00       	mov    0x804000,%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 72 09 00 00       	call   800abe <strcmp>
  80014c:	85 c0                	test   %eax,%eax
  80014e:	75 0e                	jne    80015e <umain+0x12a>
			cprintf("\npipe read closed properly\n");
  800150:	c7 04 24 b1 2c 80 00 	movl   $0x802cb1,(%esp)
  800157:	e8 10 03 00 00       	call   80046c <cprintf>
  80015c:	eb 17                	jmp    800175 <umain+0x141>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  80015e:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800161:	89 44 24 08          	mov    %eax,0x8(%esp)
  800165:	89 74 24 04          	mov    %esi,0x4(%esp)
  800169:	c7 04 24 cd 2c 80 00 	movl   $0x802ccd,(%esp)
  800170:	e8 f7 02 00 00       	call   80046c <cprintf>
		exit();
  800175:	e8 e6 01 00 00       	call   800360 <exit>
  80017a:	e9 ac 00 00 00       	jmp    80022b <umain+0x1f7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  80017f:	a1 08 50 80 00       	mov    0x805008,%eax
  800184:	8b 40 48             	mov    0x48(%eax),%eax
  800187:	8b 55 8c             	mov    -0x74(%ebp),%edx
  80018a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80018e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800192:	c7 04 24 6e 2c 80 00 	movl   $0x802c6e,(%esp)
  800199:	e8 ce 02 00 00       	call   80046c <cprintf>
		close(p[0]);
  80019e:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 01 15 00 00       	call   8016aa <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001a9:	a1 08 50 80 00       	mov    0x805008,%eax
  8001ae:	8b 40 48             	mov    0x48(%eax),%eax
  8001b1:	8b 55 90             	mov    -0x70(%ebp),%edx
  8001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bc:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  8001c3:	e8 a4 02 00 00       	call   80046c <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  8001c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 0f 08 00 00       	call   8009e4 <strlen>
  8001d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d9:	a1 00 40 80 00       	mov    0x804000,%eax
  8001de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e2:	8b 45 90             	mov    -0x70(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 fc 16 00 00       	call   8018e9 <write>
  8001ed:	89 c6                	mov    %eax,%esi
  8001ef:	a1 00 40 80 00       	mov    0x804000,%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 e8 07 00 00       	call   8009e4 <strlen>
  8001fc:	39 c6                	cmp    %eax,%esi
  8001fe:	74 20                	je     800220 <umain+0x1ec>
			panic("write: %e", i);
  800200:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800204:	c7 44 24 08 fd 2c 80 	movl   $0x802cfd,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  80021b:	e8 54 01 00 00       	call   800374 <_panic>
		close(p[1]);
  800220:	8b 45 90             	mov    -0x70(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	e8 7f 14 00 00       	call   8016aa <close>
	}
	wait(pid);
  80022b:	89 1c 24             	mov    %ebx,(%esp)
  80022e:	e8 c5 23 00 00       	call   8025f8 <wait>

	binaryname = "pipewriteeof";
  800233:	c7 05 04 40 80 00 07 	movl   $0x802d07,0x804004
  80023a:	2d 80 00 
	if ((i = pipe(p)) < 0)
  80023d:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 0d 22 00 00       	call   802455 <pipe>
  800248:	89 c6                	mov    %eax,%esi
  80024a:	85 c0                	test   %eax,%eax
  80024c:	79 20                	jns    80026e <umain+0x23a>
		panic("pipe: %e", i);
  80024e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800252:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  800259:	00 
  80025a:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800261:	00 
  800262:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  800269:	e8 06 01 00 00       	call   800374 <_panic>

	if ((pid = fork()) < 0)
  80026e:	e8 90 0f 00 00       	call   801203 <fork>
  800273:	89 c3                	mov    %eax,%ebx
  800275:	85 c0                	test   %eax,%eax
  800277:	79 20                	jns    800299 <umain+0x265>
		panic("fork: %e", i);
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	c7 44 24 08 65 2c 80 	movl   $0x802c65,0x8(%esp)
  800284:	00 
  800285:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  80028c:	00 
  80028d:	c7 04 24 55 2c 80 00 	movl   $0x802c55,(%esp)
  800294:	e8 db 00 00 00       	call   800374 <_panic>

	if (pid == 0) {
  800299:	85 c0                	test   %eax,%eax
  80029b:	75 48                	jne    8002e5 <umain+0x2b1>
		close(p[0]);
  80029d:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002a0:	89 04 24             	mov    %eax,(%esp)
  8002a3:	e8 02 14 00 00       	call   8016aa <close>
		while (1) {
			cprintf(".");
  8002a8:	c7 04 24 14 2d 80 00 	movl   $0x802d14,(%esp)
  8002af:	e8 b8 01 00 00       	call   80046c <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002bb:	00 
  8002bc:	c7 44 24 04 16 2d 80 	movl   $0x802d16,0x4(%esp)
  8002c3:	00 
  8002c4:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 1a 16 00 00       	call   8018e9 <write>
  8002cf:	83 f8 01             	cmp    $0x1,%eax
  8002d2:	74 d4                	je     8002a8 <umain+0x274>
				break;
		}
		cprintf("\npipe write closed properly\n");
  8002d4:	c7 04 24 18 2d 80 00 	movl   $0x802d18,(%esp)
  8002db:	e8 8c 01 00 00       	call   80046c <cprintf>
		exit();
  8002e0:	e8 7b 00 00 00       	call   800360 <exit>
	}
	close(p[0]);
  8002e5:	8b 45 8c             	mov    -0x74(%ebp),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	e8 ba 13 00 00       	call   8016aa <close>
	close(p[1]);
  8002f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	e8 af 13 00 00       	call   8016aa <close>
	wait(pid);
  8002fb:	89 1c 24             	mov    %ebx,(%esp)
  8002fe:	e8 f5 22 00 00       	call   8025f8 <wait>

	cprintf("pipe tests passed\n");
  800303:	c7 04 24 35 2d 80 00 	movl   $0x802d35,(%esp)
  80030a:	e8 5d 01 00 00       	call   80046c <cprintf>
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
  800326:	e8 a0 0a 00 00       	call   800dcb <sys_getenvid>
  80032b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800330:	c1 e0 07             	shl    $0x7,%eax
  800333:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800338:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80033d:	85 f6                	test   %esi,%esi
  80033f:	7e 07                	jle    800348 <libmain+0x30>
		binaryname = argv[0];
  800341:	8b 03                	mov    (%ebx),%eax
  800343:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  800348:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80034c:	89 34 24             	mov    %esi,(%esp)
  80034f:	e8 e0 fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800354:	e8 07 00 00 00       	call   800360 <exit>
}
  800359:	83 c4 10             	add    $0x10,%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800366:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80036d:	e8 07 0a 00 00       	call   800d79 <sys_env_destroy>
}
  800372:	c9                   	leave  
  800373:	c3                   	ret    

00800374 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80037c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80037f:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  800385:	e8 41 0a 00 00       	call   800dcb <sys_getenvid>
  80038a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800391:	8b 55 08             	mov    0x8(%ebp),%edx
  800394:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800398:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80039c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a0:	c7 04 24 98 2d 80 00 	movl   $0x802d98,(%esp)
  8003a7:	e8 c0 00 00 00       	call   80046c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	e8 50 00 00 00       	call   80040b <vcprintf>
	cprintf("\n");
  8003bb:	c7 04 24 89 2c 80 00 	movl   $0x802c89,(%esp)
  8003c2:	e8 a5 00 00 00       	call   80046c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c7:	cc                   	int3   
  8003c8:	eb fd                	jmp    8003c7 <_panic+0x53>
	...

008003cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	53                   	push   %ebx
  8003d0:	83 ec 14             	sub    $0x14,%esp
  8003d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d6:	8b 03                	mov    (%ebx),%eax
  8003d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8003db:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003df:	40                   	inc    %eax
  8003e0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e7:	75 19                	jne    800402 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003e9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003f0:	00 
  8003f1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	e8 40 09 00 00       	call   800d3c <sys_cputs>
		b->idx = 0;
  8003fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800402:	ff 43 04             	incl   0x4(%ebx)
}
  800405:	83 c4 14             	add    $0x14,%esp
  800408:	5b                   	pop    %ebx
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800414:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80041b:	00 00 00 
	b.cnt = 0;
  80041e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800425:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800428:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	8b 45 08             	mov    0x8(%ebp),%eax
  800432:	89 44 24 08          	mov    %eax,0x8(%esp)
  800436:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80043c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800440:	c7 04 24 cc 03 80 00 	movl   $0x8003cc,(%esp)
  800447:	e8 82 01 00 00       	call   8005ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80044c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800452:	89 44 24 04          	mov    %eax,0x4(%esp)
  800456:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	e8 d8 08 00 00       	call   800d3c <sys_cputs>

	return b.cnt;
}
  800464:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80046a:	c9                   	leave  
  80046b:	c3                   	ret    

0080046c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800472:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800475:	89 44 24 04          	mov    %eax,0x4(%esp)
  800479:	8b 45 08             	mov    0x8(%ebp),%eax
  80047c:	89 04 24             	mov    %eax,(%esp)
  80047f:	e8 87 ff ff ff       	call   80040b <vcprintf>
	va_end(ap);

	return cnt;
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    
	...

00800488 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	57                   	push   %edi
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 3c             	sub    $0x3c,%esp
  800491:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800494:	89 d7                	mov    %edx,%edi
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	75 08                	jne    8004b4 <printnum+0x2c>
  8004ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004b2:	77 57                	ja     80050b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004b8:	4b                   	dec    %ebx
  8004b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004c4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004d3:	00 
  8004d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d7:	89 04 24             	mov    %eax,(%esp)
  8004da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e1:	e8 fe 24 00 00       	call   8029e4 <__udivdi3>
  8004e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004ea:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004ee:	89 04 24             	mov    %eax,(%esp)
  8004f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004f5:	89 fa                	mov    %edi,%edx
  8004f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004fa:	e8 89 ff ff ff       	call   800488 <printnum>
  8004ff:	eb 0f                	jmp    800510 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800501:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800505:	89 34 24             	mov    %esi,(%esp)
  800508:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80050b:	4b                   	dec    %ebx
  80050c:	85 db                	test   %ebx,%ebx
  80050e:	7f f1                	jg     800501 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800510:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800514:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800518:	8b 45 10             	mov    0x10(%ebp),%eax
  80051b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800526:	00 
  800527:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	e8 cb 25 00 00       	call   802b04 <__umoddi3>
  800539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053d:	0f be 80 bb 2d 80 00 	movsbl 0x802dbb(%eax),%eax
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80054a:	83 c4 3c             	add    $0x3c,%esp
  80054d:	5b                   	pop    %ebx
  80054e:	5e                   	pop    %esi
  80054f:	5f                   	pop    %edi
  800550:	5d                   	pop    %ebp
  800551:	c3                   	ret    

00800552 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800555:	83 fa 01             	cmp    $0x1,%edx
  800558:	7e 0e                	jle    800568 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80055f:	89 08                	mov    %ecx,(%eax)
  800561:	8b 02                	mov    (%edx),%eax
  800563:	8b 52 04             	mov    0x4(%edx),%edx
  800566:	eb 22                	jmp    80058a <getuint+0x38>
	else if (lflag)
  800568:	85 d2                	test   %edx,%edx
  80056a:	74 10                	je     80057c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80056c:	8b 10                	mov    (%eax),%edx
  80056e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800571:	89 08                	mov    %ecx,(%eax)
  800573:	8b 02                	mov    (%edx),%eax
  800575:	ba 00 00 00 00       	mov    $0x0,%edx
  80057a:	eb 0e                	jmp    80058a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80057c:	8b 10                	mov    (%eax),%edx
  80057e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800581:	89 08                	mov    %ecx,(%eax)
  800583:	8b 02                	mov    (%edx),%eax
  800585:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80058a:	5d                   	pop    %ebp
  80058b:	c3                   	ret    

0080058c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800592:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800595:	8b 10                	mov    (%eax),%edx
  800597:	3b 50 04             	cmp    0x4(%eax),%edx
  80059a:	73 08                	jae    8005a4 <sprintputch+0x18>
		*b->buf++ = ch;
  80059c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80059f:	88 0a                	mov    %cl,(%edx)
  8005a1:	42                   	inc    %edx
  8005a2:	89 10                	mov    %edx,(%eax)
}
  8005a4:	5d                   	pop    %ebp
  8005a5:	c3                   	ret    

008005a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005a6:	55                   	push   %ebp
  8005a7:	89 e5                	mov    %esp,%ebp
  8005a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	e8 02 00 00 00       	call   8005ce <vprintfmt>
	va_end(ap);
}
  8005cc:	c9                   	leave  
  8005cd:	c3                   	ret    

008005ce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
  8005d1:	57                   	push   %edi
  8005d2:	56                   	push   %esi
  8005d3:	53                   	push   %ebx
  8005d4:	83 ec 4c             	sub    $0x4c,%esp
  8005d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005da:	8b 75 10             	mov    0x10(%ebp),%esi
  8005dd:	eb 12                	jmp    8005f1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	0f 84 6b 03 00 00    	je     800952 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005f1:	0f b6 06             	movzbl (%esi),%eax
  8005f4:	46                   	inc    %esi
  8005f5:	83 f8 25             	cmp    $0x25,%eax
  8005f8:	75 e5                	jne    8005df <vprintfmt+0x11>
  8005fa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005fe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800605:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80060a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	eb 26                	jmp    80063e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80061b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80061f:	eb 1d                	jmp    80063e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800624:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800628:	eb 14                	jmp    80063e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80062d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800634:	eb 08                	jmp    80063e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800636:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800639:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	0f b6 06             	movzbl (%esi),%eax
  800641:	8d 56 01             	lea    0x1(%esi),%edx
  800644:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800647:	8a 16                	mov    (%esi),%dl
  800649:	83 ea 23             	sub    $0x23,%edx
  80064c:	80 fa 55             	cmp    $0x55,%dl
  80064f:	0f 87 e1 02 00 00    	ja     800936 <vprintfmt+0x368>
  800655:	0f b6 d2             	movzbl %dl,%edx
  800658:	ff 24 95 00 2f 80 00 	jmp    *0x802f00(,%edx,4)
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800667:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80066a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80066e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800671:	8d 50 d0             	lea    -0x30(%eax),%edx
  800674:	83 fa 09             	cmp    $0x9,%edx
  800677:	77 2a                	ja     8006a3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800679:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80067a:	eb eb                	jmp    800667 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)
  800685:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80068a:	eb 17                	jmp    8006a3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80068c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800690:	78 98                	js     80062a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800692:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800695:	eb a7                	jmp    80063e <vprintfmt+0x70>
  800697:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80069a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006a1:	eb 9b                	jmp    80063e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a7:	79 95                	jns    80063e <vprintfmt+0x70>
  8006a9:	eb 8b                	jmp    800636 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006af:	eb 8d                	jmp    80063e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 04             	lea    0x4(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006c9:	e9 23 ff ff ff       	jmp    8005f1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	79 02                	jns    8006df <vprintfmt+0x111>
  8006dd:	f7 d8                	neg    %eax
  8006df:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e1:	83 f8 11             	cmp    $0x11,%eax
  8006e4:	7f 0b                	jg     8006f1 <vprintfmt+0x123>
  8006e6:	8b 04 85 60 30 80 00 	mov    0x803060(,%eax,4),%eax
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	75 23                	jne    800714 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f5:	c7 44 24 08 d3 2d 80 	movl   $0x802dd3,0x8(%esp)
  8006fc:	00 
  8006fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	e8 9a fe ff ff       	call   8005a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80070f:	e9 dd fe ff ff       	jmp    8005f1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800714:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800718:	c7 44 24 08 8d 32 80 	movl   $0x80328d,0x8(%esp)
  80071f:	00 
  800720:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
  800727:	89 14 24             	mov    %edx,(%esp)
  80072a:	e8 77 fe ff ff       	call   8005a6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800732:	e9 ba fe ff ff       	jmp    8005f1 <vprintfmt+0x23>
  800737:	89 f9                	mov    %edi,%ecx
  800739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80073c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8d 50 04             	lea    0x4(%eax),%edx
  800745:	89 55 14             	mov    %edx,0x14(%ebp)
  800748:	8b 30                	mov    (%eax),%esi
  80074a:	85 f6                	test   %esi,%esi
  80074c:	75 05                	jne    800753 <vprintfmt+0x185>
				p = "(null)";
  80074e:	be cc 2d 80 00       	mov    $0x802dcc,%esi
			if (width > 0 && padc != '-')
  800753:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800757:	0f 8e 84 00 00 00    	jle    8007e1 <vprintfmt+0x213>
  80075d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800761:	74 7e                	je     8007e1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800763:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800767:	89 34 24             	mov    %esi,(%esp)
  80076a:	e8 8b 02 00 00       	call   8009fa <strnlen>
  80076f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800772:	29 c2                	sub    %eax,%edx
  800774:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800777:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80077b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80077e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800781:	89 de                	mov    %ebx,%esi
  800783:	89 d3                	mov    %edx,%ebx
  800785:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800787:	eb 0b                	jmp    800794 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800789:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078d:	89 3c 24             	mov    %edi,(%esp)
  800790:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800793:	4b                   	dec    %ebx
  800794:	85 db                	test   %ebx,%ebx
  800796:	7f f1                	jg     800789 <vprintfmt+0x1bb>
  800798:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80079b:	89 f3                	mov    %esi,%ebx
  80079d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	79 05                	jns    8007ac <vprintfmt+0x1de>
  8007a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007af:	29 c2                	sub    %eax,%edx
  8007b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007b4:	eb 2b                	jmp    8007e1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ba:	74 18                	je     8007d4 <vprintfmt+0x206>
  8007bc:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007bf:	83 fa 5e             	cmp    $0x5e,%edx
  8007c2:	76 10                	jbe    8007d4 <vprintfmt+0x206>
					putch('?', putdat);
  8007c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007cf:	ff 55 08             	call   *0x8(%ebp)
  8007d2:	eb 0a                	jmp    8007de <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d8:	89 04 24             	mov    %eax,(%esp)
  8007db:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007de:	ff 4d e4             	decl   -0x1c(%ebp)
  8007e1:	0f be 06             	movsbl (%esi),%eax
  8007e4:	46                   	inc    %esi
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	74 21                	je     80080a <vprintfmt+0x23c>
  8007e9:	85 ff                	test   %edi,%edi
  8007eb:	78 c9                	js     8007b6 <vprintfmt+0x1e8>
  8007ed:	4f                   	dec    %edi
  8007ee:	79 c6                	jns    8007b6 <vprintfmt+0x1e8>
  8007f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007f3:	89 de                	mov    %ebx,%esi
  8007f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007f8:	eb 18                	jmp    800812 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800805:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800807:	4b                   	dec    %ebx
  800808:	eb 08                	jmp    800812 <vprintfmt+0x244>
  80080a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080d:	89 de                	mov    %ebx,%esi
  80080f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800812:	85 db                	test   %ebx,%ebx
  800814:	7f e4                	jg     8007fa <vprintfmt+0x22c>
  800816:	89 7d 08             	mov    %edi,0x8(%ebp)
  800819:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80081e:	e9 ce fd ff ff       	jmp    8005f1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800823:	83 f9 01             	cmp    $0x1,%ecx
  800826:	7e 10                	jle    800838 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8d 50 08             	lea    0x8(%eax),%edx
  80082e:	89 55 14             	mov    %edx,0x14(%ebp)
  800831:	8b 30                	mov    (%eax),%esi
  800833:	8b 78 04             	mov    0x4(%eax),%edi
  800836:	eb 26                	jmp    80085e <vprintfmt+0x290>
	else if (lflag)
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	74 12                	je     80084e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 30                	mov    (%eax),%esi
  800847:	89 f7                	mov    %esi,%edi
  800849:	c1 ff 1f             	sar    $0x1f,%edi
  80084c:	eb 10                	jmp    80085e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8d 50 04             	lea    0x4(%eax),%edx
  800854:	89 55 14             	mov    %edx,0x14(%ebp)
  800857:	8b 30                	mov    (%eax),%esi
  800859:	89 f7                	mov    %esi,%edi
  80085b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80085e:	85 ff                	test   %edi,%edi
  800860:	78 0a                	js     80086c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
  800867:	e9 8c 00 00 00       	jmp    8008f8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80086c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800870:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800877:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80087a:	f7 de                	neg    %esi
  80087c:	83 d7 00             	adc    $0x0,%edi
  80087f:	f7 df                	neg    %edi
			}
			base = 10;
  800881:	b8 0a 00 00 00       	mov    $0xa,%eax
  800886:	eb 70                	jmp    8008f8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800888:	89 ca                	mov    %ecx,%edx
  80088a:	8d 45 14             	lea    0x14(%ebp),%eax
  80088d:	e8 c0 fc ff ff       	call   800552 <getuint>
  800892:	89 c6                	mov    %eax,%esi
  800894:	89 d7                	mov    %edx,%edi
			base = 10;
  800896:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80089b:	eb 5b                	jmp    8008f8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80089d:	89 ca                	mov    %ecx,%edx
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a2:	e8 ab fc ff ff       	call   800552 <getuint>
  8008a7:	89 c6                	mov    %eax,%esi
  8008a9:	89 d7                	mov    %edx,%edi
			base = 8;
  8008ab:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008b0:	eb 46                	jmp    8008f8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  8008b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8d 50 04             	lea    0x4(%eax),%edx
  8008d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008d7:	8b 30                	mov    (%eax),%esi
  8008d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008e3:	eb 13                	jmp    8008f8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008e5:	89 ca                	mov    %ecx,%edx
  8008e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ea:	e8 63 fc ff ff       	call   800552 <getuint>
  8008ef:	89 c6                	mov    %eax,%esi
  8008f1:	89 d7                	mov    %edx,%edi
			base = 16;
  8008f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800900:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800903:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800907:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090b:	89 34 24             	mov    %esi,(%esp)
  80090e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800912:	89 da                	mov    %ebx,%edx
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	e8 6c fb ff ff       	call   800488 <printnum>
			break;
  80091c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80091f:	e9 cd fc ff ff       	jmp    8005f1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800924:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800928:	89 04 24             	mov    %eax,(%esp)
  80092b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800931:	e9 bb fc ff ff       	jmp    8005f1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800936:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800941:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800944:	eb 01                	jmp    800947 <vprintfmt+0x379>
  800946:	4e                   	dec    %esi
  800947:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80094b:	75 f9                	jne    800946 <vprintfmt+0x378>
  80094d:	e9 9f fc ff ff       	jmp    8005f1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800952:	83 c4 4c             	add    $0x4c,%esp
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 28             	sub    $0x28,%esp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800966:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800969:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800970:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800977:	85 c0                	test   %eax,%eax
  800979:	74 30                	je     8009ab <vsnprintf+0x51>
  80097b:	85 d2                	test   %edx,%edx
  80097d:	7e 33                	jle    8009b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80097f:	8b 45 14             	mov    0x14(%ebp),%eax
  800982:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800986:	8b 45 10             	mov    0x10(%ebp),%eax
  800989:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800990:	89 44 24 04          	mov    %eax,0x4(%esp)
  800994:	c7 04 24 8c 05 80 00 	movl   $0x80058c,(%esp)
  80099b:	e8 2e fc ff ff       	call   8005ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a9:	eb 0c                	jmp    8009b7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b0:	eb 05                	jmp    8009b7 <vsnprintf+0x5d>
  8009b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 7b ff ff ff       	call   80095a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    
  8009e1:	00 00                	add    %al,(%eax)
	...

008009e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb 01                	jmp    8009f2 <strlen+0xe>
		n++;
  8009f1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f6:	75 f9                	jne    8009f1 <strlen+0xd>
		n++;
	return n;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	eb 01                	jmp    800a0b <strnlen+0x11>
		n++;
  800a0a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0b:	39 d0                	cmp    %edx,%eax
  800a0d:	74 06                	je     800a15 <strnlen+0x1b>
  800a0f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a13:	75 f5                	jne    800a0a <strnlen+0x10>
		n++;
	return n;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a29:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a2c:	42                   	inc    %edx
  800a2d:	84 c9                	test   %cl,%cl
  800a2f:	75 f5                	jne    800a26 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a31:	5b                   	pop    %ebx
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a3e:	89 1c 24             	mov    %ebx,(%esp)
  800a41:	e8 9e ff ff ff       	call   8009e4 <strlen>
	strcpy(dst + len, src);
  800a46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a49:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a4d:	01 d8                	add    %ebx,%eax
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	e8 c0 ff ff ff       	call   800a17 <strcpy>
	return dst;
}
  800a57:	89 d8                	mov    %ebx,%eax
  800a59:	83 c4 08             	add    $0x8,%esp
  800a5c:	5b                   	pop    %ebx
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a72:	eb 0c                	jmp    800a80 <strncpy+0x21>
		*dst++ = *src;
  800a74:	8a 1a                	mov    (%edx),%bl
  800a76:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a79:	80 3a 01             	cmpb   $0x1,(%edx)
  800a7c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7f:	41                   	inc    %ecx
  800a80:	39 f1                	cmp    %esi,%ecx
  800a82:	75 f0                	jne    800a74 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a93:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a96:	85 d2                	test   %edx,%edx
  800a98:	75 0a                	jne    800aa4 <strlcpy+0x1c>
  800a9a:	89 f0                	mov    %esi,%eax
  800a9c:	eb 1a                	jmp    800ab8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a9e:	88 18                	mov    %bl,(%eax)
  800aa0:	40                   	inc    %eax
  800aa1:	41                   	inc    %ecx
  800aa2:	eb 02                	jmp    800aa6 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa4:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aa6:	4a                   	dec    %edx
  800aa7:	74 0a                	je     800ab3 <strlcpy+0x2b>
  800aa9:	8a 19                	mov    (%ecx),%bl
  800aab:	84 db                	test   %bl,%bl
  800aad:	75 ef                	jne    800a9e <strlcpy+0x16>
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	eb 02                	jmp    800ab5 <strlcpy+0x2d>
  800ab3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ab5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ab8:	29 f0                	sub    %esi,%eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ac7:	eb 02                	jmp    800acb <strcmp+0xd>
		p++, q++;
  800ac9:	41                   	inc    %ecx
  800aca:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800acb:	8a 01                	mov    (%ecx),%al
  800acd:	84 c0                	test   %al,%al
  800acf:	74 04                	je     800ad5 <strcmp+0x17>
  800ad1:	3a 02                	cmp    (%edx),%al
  800ad3:	74 f4                	je     800ac9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad5:	0f b6 c0             	movzbl %al,%eax
  800ad8:	0f b6 12             	movzbl (%edx),%edx
  800adb:	29 d0                	sub    %edx,%eax
}
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	53                   	push   %ebx
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800aec:	eb 03                	jmp    800af1 <strncmp+0x12>
		n--, p++, q++;
  800aee:	4a                   	dec    %edx
  800aef:	40                   	inc    %eax
  800af0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800af1:	85 d2                	test   %edx,%edx
  800af3:	74 14                	je     800b09 <strncmp+0x2a>
  800af5:	8a 18                	mov    (%eax),%bl
  800af7:	84 db                	test   %bl,%bl
  800af9:	74 04                	je     800aff <strncmp+0x20>
  800afb:	3a 19                	cmp    (%ecx),%bl
  800afd:	74 ef                	je     800aee <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aff:	0f b6 00             	movzbl (%eax),%eax
  800b02:	0f b6 11             	movzbl (%ecx),%edx
  800b05:	29 d0                	sub    %edx,%eax
  800b07:	eb 05                	jmp    800b0e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b1a:	eb 05                	jmp    800b21 <strchr+0x10>
		if (*s == c)
  800b1c:	38 ca                	cmp    %cl,%dl
  800b1e:	74 0c                	je     800b2c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b20:	40                   	inc    %eax
  800b21:	8a 10                	mov    (%eax),%dl
  800b23:	84 d2                	test   %dl,%dl
  800b25:	75 f5                	jne    800b1c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b37:	eb 05                	jmp    800b3e <strfind+0x10>
		if (*s == c)
  800b39:	38 ca                	cmp    %cl,%dl
  800b3b:	74 07                	je     800b44 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b3d:	40                   	inc    %eax
  800b3e:	8a 10                	mov    (%eax),%dl
  800b40:	84 d2                	test   %dl,%dl
  800b42:	75 f5                	jne    800b39 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b55:	85 c9                	test   %ecx,%ecx
  800b57:	74 30                	je     800b89 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b59:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5f:	75 25                	jne    800b86 <memset+0x40>
  800b61:	f6 c1 03             	test   $0x3,%cl
  800b64:	75 20                	jne    800b86 <memset+0x40>
		c &= 0xFF;
  800b66:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	c1 e3 08             	shl    $0x8,%ebx
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	c1 e6 18             	shl    $0x18,%esi
  800b73:	89 d0                	mov    %edx,%eax
  800b75:	c1 e0 10             	shl    $0x10,%eax
  800b78:	09 f0                	or     %esi,%eax
  800b7a:	09 d0                	or     %edx,%eax
  800b7c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b7e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b81:	fc                   	cld    
  800b82:	f3 ab                	rep stos %eax,%es:(%edi)
  800b84:	eb 03                	jmp    800b89 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b86:	fc                   	cld    
  800b87:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b89:	89 f8                	mov    %edi,%eax
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b9e:	39 c6                	cmp    %eax,%esi
  800ba0:	73 34                	jae    800bd6 <memmove+0x46>
  800ba2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba5:	39 d0                	cmp    %edx,%eax
  800ba7:	73 2d                	jae    800bd6 <memmove+0x46>
		s += n;
		d += n;
  800ba9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bac:	f6 c2 03             	test   $0x3,%dl
  800baf:	75 1b                	jne    800bcc <memmove+0x3c>
  800bb1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb7:	75 13                	jne    800bcc <memmove+0x3c>
  800bb9:	f6 c1 03             	test   $0x3,%cl
  800bbc:	75 0e                	jne    800bcc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bbe:	83 ef 04             	sub    $0x4,%edi
  800bc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bc7:	fd                   	std    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb 07                	jmp    800bd3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bcc:	4f                   	dec    %edi
  800bcd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd0:	fd                   	std    
  800bd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd3:	fc                   	cld    
  800bd4:	eb 20                	jmp    800bf6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdc:	75 13                	jne    800bf1 <memmove+0x61>
  800bde:	a8 03                	test   $0x3,%al
  800be0:	75 0f                	jne    800bf1 <memmove+0x61>
  800be2:	f6 c1 03             	test   $0x3,%cl
  800be5:	75 0a                	jne    800bf1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	fc                   	cld    
  800bed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bef:	eb 05                	jmp    800bf6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf1:	89 c7                	mov    %eax,%edi
  800bf3:	fc                   	cld    
  800bf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c00:	8b 45 10             	mov    0x10(%ebp),%eax
  800c03:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	89 04 24             	mov    %eax,(%esp)
  800c14:	e8 77 ff ff ff       	call   800b90 <memmove>
}
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2f:	eb 16                	jmp    800c47 <memcmp+0x2c>
		if (*s1 != *s2)
  800c31:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c34:	42                   	inc    %edx
  800c35:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c39:	38 c8                	cmp    %cl,%al
  800c3b:	74 0a                	je     800c47 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c3d:	0f b6 c0             	movzbl %al,%eax
  800c40:	0f b6 c9             	movzbl %cl,%ecx
  800c43:	29 c8                	sub    %ecx,%eax
  800c45:	eb 09                	jmp    800c50 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c47:	39 da                	cmp    %ebx,%edx
  800c49:	75 e6                	jne    800c31 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c63:	eb 05                	jmp    800c6a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c65:	38 08                	cmp    %cl,(%eax)
  800c67:	74 05                	je     800c6e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c69:	40                   	inc    %eax
  800c6a:	39 d0                	cmp    %edx,%eax
  800c6c:	72 f7                	jb     800c65 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7c:	eb 01                	jmp    800c7f <strtol+0xf>
		s++;
  800c7e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7f:	8a 02                	mov    (%edx),%al
  800c81:	3c 20                	cmp    $0x20,%al
  800c83:	74 f9                	je     800c7e <strtol+0xe>
  800c85:	3c 09                	cmp    $0x9,%al
  800c87:	74 f5                	je     800c7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c89:	3c 2b                	cmp    $0x2b,%al
  800c8b:	75 08                	jne    800c95 <strtol+0x25>
		s++;
  800c8d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c93:	eb 13                	jmp    800ca8 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c95:	3c 2d                	cmp    $0x2d,%al
  800c97:	75 0a                	jne    800ca3 <strtol+0x33>
		s++, neg = 1;
  800c99:	8d 52 01             	lea    0x1(%edx),%edx
  800c9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800ca1:	eb 05                	jmp    800ca8 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	74 05                	je     800cb1 <strtol+0x41>
  800cac:	83 fb 10             	cmp    $0x10,%ebx
  800caf:	75 28                	jne    800cd9 <strtol+0x69>
  800cb1:	8a 02                	mov    (%edx),%al
  800cb3:	3c 30                	cmp    $0x30,%al
  800cb5:	75 10                	jne    800cc7 <strtol+0x57>
  800cb7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cbb:	75 0a                	jne    800cc7 <strtol+0x57>
		s += 2, base = 16;
  800cbd:	83 c2 02             	add    $0x2,%edx
  800cc0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc5:	eb 12                	jmp    800cd9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cc7:	85 db                	test   %ebx,%ebx
  800cc9:	75 0e                	jne    800cd9 <strtol+0x69>
  800ccb:	3c 30                	cmp    $0x30,%al
  800ccd:	75 05                	jne    800cd4 <strtol+0x64>
		s++, base = 8;
  800ccf:	42                   	inc    %edx
  800cd0:	b3 08                	mov    $0x8,%bl
  800cd2:	eb 05                	jmp    800cd9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cd4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cde:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce0:	8a 0a                	mov    (%edx),%cl
  800ce2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ce5:	80 fb 09             	cmp    $0x9,%bl
  800ce8:	77 08                	ja     800cf2 <strtol+0x82>
			dig = *s - '0';
  800cea:	0f be c9             	movsbl %cl,%ecx
  800ced:	83 e9 30             	sub    $0x30,%ecx
  800cf0:	eb 1e                	jmp    800d10 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cf2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cf5:	80 fb 19             	cmp    $0x19,%bl
  800cf8:	77 08                	ja     800d02 <strtol+0x92>
			dig = *s - 'a' + 10;
  800cfa:	0f be c9             	movsbl %cl,%ecx
  800cfd:	83 e9 57             	sub    $0x57,%ecx
  800d00:	eb 0e                	jmp    800d10 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d02:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d05:	80 fb 19             	cmp    $0x19,%bl
  800d08:	77 12                	ja     800d1c <strtol+0xac>
			dig = *s - 'A' + 10;
  800d0a:	0f be c9             	movsbl %cl,%ecx
  800d0d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d10:	39 f1                	cmp    %esi,%ecx
  800d12:	7d 0c                	jge    800d20 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d14:	42                   	inc    %edx
  800d15:	0f af c6             	imul   %esi,%eax
  800d18:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d1a:	eb c4                	jmp    800ce0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d1c:	89 c1                	mov    %eax,%ecx
  800d1e:	eb 02                	jmp    800d22 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d20:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d26:	74 05                	je     800d2d <strtol+0xbd>
		*endptr = (char *) s;
  800d28:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d2b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d2d:	85 ff                	test   %edi,%edi
  800d2f:	74 04                	je     800d35 <strtol+0xc5>
  800d31:	89 c8                	mov    %ecx,%eax
  800d33:	f7 d8                	neg    %eax
}
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
	...

00800d3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 c3                	mov    %eax,%ebx
  800d4f:	89 c7                	mov    %eax,%edi
  800d51:	89 c6                	mov    %eax,%esi
  800d53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d60:	ba 00 00 00 00       	mov    $0x0,%edx
  800d65:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6a:	89 d1                	mov    %edx,%ecx
  800d6c:	89 d3                	mov    %edx,%ebx
  800d6e:	89 d7                	mov    %edx,%edi
  800d70:	89 d6                	mov    %edx,%esi
  800d72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    

00800d79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	57                   	push   %edi
  800d7d:	56                   	push   %esi
  800d7e:	53                   	push   %ebx
  800d7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d87:	b8 03 00 00 00       	mov    $0x3,%eax
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	89 cb                	mov    %ecx,%ebx
  800d91:	89 cf                	mov    %ecx,%edi
  800d93:	89 ce                	mov    %ecx,%esi
  800d95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 28                	jle    800dc3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d9f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800da6:	00 
  800da7:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800dae:	00 
  800daf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db6:	00 
  800db7:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800dbe:	e8 b1 f5 ff ff       	call   800374 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dc3:	83 c4 2c             	add    $0x2c,%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ddb:	89 d1                	mov    %edx,%ecx
  800ddd:	89 d3                	mov    %edx,%ebx
  800ddf:	89 d7                	mov    %edx,%edi
  800de1:	89 d6                	mov    %edx,%esi
  800de3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <sys_yield>:

void
sys_yield(void)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	57                   	push   %edi
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df0:	ba 00 00 00 00       	mov    $0x0,%edx
  800df5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dfa:	89 d1                	mov    %edx,%ecx
  800dfc:	89 d3                	mov    %edx,%ebx
  800dfe:	89 d7                	mov    %edx,%edi
  800e00:	89 d6                	mov    %edx,%esi
  800e02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	be 00 00 00 00       	mov    $0x0,%esi
  800e17:	b8 04 00 00 00       	mov    $0x4,%eax
  800e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e22:	8b 55 08             	mov    0x8(%ebp),%edx
  800e25:	89 f7                	mov    %esi,%edi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800e50:	e8 1f f5 ff ff       	call   800374 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e66:	b8 05 00 00 00       	mov    $0x5,%eax
  800e6b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	7e 28                	jle    800ea8 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e80:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e84:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800e93:	00 
  800e94:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9b:	00 
  800e9c:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800ea3:	e8 cc f4 ff ff       	call   800374 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea8:	83 c4 2c             	add    $0x2c,%esp
  800eab:	5b                   	pop    %ebx
  800eac:	5e                   	pop    %esi
  800ead:	5f                   	pop    %edi
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebe:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	89 df                	mov    %ebx,%edi
  800ecb:	89 de                	mov    %ebx,%esi
  800ecd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	7e 28                	jle    800efb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ede:	00 
  800edf:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eee:	00 
  800eef:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800ef6:	e8 79 f4 ff ff       	call   800374 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800efb:	83 c4 2c             	add    $0x2c,%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	57                   	push   %edi
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f11:	b8 08 00 00 00       	mov    $0x8,%eax
  800f16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f19:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1c:	89 df                	mov    %ebx,%edi
  800f1e:	89 de                	mov    %ebx,%esi
  800f20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f22:	85 c0                	test   %eax,%eax
  800f24:	7e 28                	jle    800f4e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f26:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f31:	00 
  800f32:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800f39:	00 
  800f3a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f41:	00 
  800f42:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800f49:	e8 26 f4 ff ff       	call   800374 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f4e:	83 c4 2c             	add    $0x2c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	57                   	push   %edi
  800f5a:	56                   	push   %esi
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f64:	b8 09 00 00 00       	mov    $0x9,%eax
  800f69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	89 df                	mov    %ebx,%edi
  800f71:	89 de                	mov    %ebx,%esi
  800f73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f75:	85 c0                	test   %eax,%eax
  800f77:	7e 28                	jle    800fa1 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800f9c:	e8 d3 f3 ff ff       	call   800374 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fa1:	83 c4 2c             	add    $0x2c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 df                	mov    %ebx,%edi
  800fc4:	89 de                	mov    %ebx,%esi
  800fc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 28                	jle    800ff4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  800fef:	e8 80 f3 ff ff       	call   800374 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ff4:	83 c4 2c             	add    $0x2c,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801002:	be 00 00 00 00       	mov    $0x0,%esi
  801007:	b8 0c 00 00 00       	mov    $0xc,%eax
  80100c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80100f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801012:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801015:	8b 55 08             	mov    0x8(%ebp),%edx
  801018:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	57                   	push   %edi
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
  801025:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801028:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801032:	8b 55 08             	mov    0x8(%ebp),%edx
  801035:	89 cb                	mov    %ecx,%ebx
  801037:	89 cf                	mov    %ecx,%edi
  801039:	89 ce                	mov    %ecx,%esi
  80103b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	7e 28                	jle    801069 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801041:	89 44 24 10          	mov    %eax,0x10(%esp)
  801045:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80104c:	00 
  80104d:	c7 44 24 08 c7 30 80 	movl   $0x8030c7,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  801064:	e8 0b f3 ff ff       	call   800374 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801069:	83 c4 2c             	add    $0x2c,%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801077:	ba 00 00 00 00       	mov    $0x0,%edx
  80107c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801081:	89 d1                	mov    %edx,%ecx
  801083:	89 d3                	mov    %edx,%ebx
  801085:	89 d7                	mov    %edx,%edi
  801087:	89 d6                	mov    %edx,%esi
  801089:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109b:	b8 10 00 00 00       	mov    $0x10,%eax
  8010a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a6:	89 df                	mov    %ebx,%edi
  8010a8:	89 de                	mov    %ebx,%esi
  8010aa:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    

008010b1 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bc:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	89 df                	mov    %ebx,%edi
  8010c9:	89 de                	mov    %ebx,%esi
  8010cb:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  8010cd:	5b                   	pop    %ebx
  8010ce:	5e                   	pop    %esi
  8010cf:	5f                   	pop    %edi
  8010d0:	5d                   	pop    %ebp
  8010d1:	c3                   	ret    

008010d2 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010dd:	b8 11 00 00 00       	mov    $0x11,%eax
  8010e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e5:	89 cb                	mov    %ecx,%ebx
  8010e7:	89 cf                	mov    %ecx,%edi
  8010e9:	89 ce                	mov    %ecx,%esi
  8010eb:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    
	...

008010f4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 24             	sub    $0x24,%esp
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010fe:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  801100:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801104:	75 20                	jne    801126 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801106:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80110a:	c7 44 24 08 f4 30 80 	movl   $0x8030f4,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801121:	e8 4e f2 ff ff       	call   800374 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801126:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  801131:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801138:	f6 c4 08             	test   $0x8,%ah
  80113b:	75 1c                	jne    801159 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  80113d:	c7 44 24 08 24 31 80 	movl   $0x803124,0x8(%esp)
  801144:	00 
  801145:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80114c:	00 
  80114d:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801154:	e8 1b f2 ff ff       	call   800374 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801159:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801160:	00 
  801161:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801168:	00 
  801169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801170:	e8 94 fc ff ff       	call   800e09 <sys_page_alloc>
  801175:	85 c0                	test   %eax,%eax
  801177:	79 20                	jns    801199 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117d:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801184:	00 
  801185:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80118c:	00 
  80118d:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801194:	e8 db f1 ff ff       	call   800374 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801199:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011a0:	00 
  8011a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a5:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011ac:	e8 df f9 ff ff       	call   800b90 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8011b1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011b8:	00 
  8011b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d4:	e8 84 fc ff ff       	call   800e5d <sys_page_map>
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	79 20                	jns    8011fd <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  8011dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011e1:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  8011e8:	00 
  8011e9:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8011f0:	00 
  8011f1:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  8011f8:	e8 77 f1 ff ff       	call   800374 <_panic>

}
  8011fd:	83 c4 24             	add    $0x24,%esp
  801200:	5b                   	pop    %ebx
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	57                   	push   %edi
  801207:	56                   	push   %esi
  801208:	53                   	push   %ebx
  801209:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  80120c:	c7 04 24 f4 10 80 00 	movl   $0x8010f4,(%esp)
  801213:	e8 e0 15 00 00       	call   8027f8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801218:	ba 07 00 00 00       	mov    $0x7,%edx
  80121d:	89 d0                	mov    %edx,%eax
  80121f:	cd 30                	int    $0x30
  801221:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801224:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801227:	85 c0                	test   %eax,%eax
  801229:	79 20                	jns    80124b <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  80122b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122f:	c7 44 24 08 a5 31 80 	movl   $0x8031a5,0x8(%esp)
  801236:	00 
  801237:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80123e:	00 
  80123f:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801246:	e8 29 f1 ff ff       	call   800374 <_panic>
	if (child_envid == 0) { // child
  80124b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80124f:	75 1c                	jne    80126d <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801251:	e8 75 fb ff ff       	call   800dcb <sys_getenvid>
  801256:	25 ff 03 00 00       	and    $0x3ff,%eax
  80125b:	c1 e0 07             	shl    $0x7,%eax
  80125e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801263:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801268:	e9 58 02 00 00       	jmp    8014c5 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  80126d:	bf 00 00 00 00       	mov    $0x0,%edi
  801272:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801277:	89 f0                	mov    %esi,%eax
  801279:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80127c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801283:	a8 01                	test   $0x1,%al
  801285:	0f 84 7a 01 00 00    	je     801405 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80128b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801292:	a8 01                	test   $0x1,%al
  801294:	0f 84 6b 01 00 00    	je     801405 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80129a:	a1 08 50 80 00       	mov    0x805008,%eax
  80129f:	8b 40 48             	mov    0x48(%eax),%eax
  8012a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8012a5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012ac:	f6 c4 04             	test   $0x4,%ah
  8012af:	74 52                	je     801303 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8012b1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	e8 82 fb ff ff       	call   800e5d <sys_page_map>
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 89 22 01 00 00    	jns    801405 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8012e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e7:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  8012ee:	00 
  8012ef:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8012f6:	00 
  8012f7:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  8012fe:	e8 71 f0 ff ff       	call   800374 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801303:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80130a:	f6 c4 08             	test   $0x8,%ah
  80130d:	75 0f                	jne    80131e <fork+0x11b>
  80130f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801316:	a8 02                	test   $0x2,%al
  801318:	0f 84 99 00 00 00    	je     8013b7 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80131e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801325:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801328:	83 f8 01             	cmp    $0x1,%eax
  80132b:	19 db                	sbb    %ebx,%ebx
  80132d:	83 e3 fc             	and    $0xfffffffc,%ebx
  801330:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801336:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80133a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80133e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801341:	89 44 24 08          	mov    %eax,0x8(%esp)
  801345:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134c:	89 04 24             	mov    %eax,(%esp)
  80134f:	e8 09 fb ff ff       	call   800e5d <sys_page_map>
  801354:	85 c0                	test   %eax,%eax
  801356:	79 20                	jns    801378 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801358:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80135c:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  801363:	00 
  801364:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80136b:	00 
  80136c:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801373:	e8 fc ef ff ff       	call   800374 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801378:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80137c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801380:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801383:	89 44 24 08          	mov    %eax,0x8(%esp)
  801387:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80138b:	89 04 24             	mov    %eax,(%esp)
  80138e:	e8 ca fa ff ff       	call   800e5d <sys_page_map>
  801393:	85 c0                	test   %eax,%eax
  801395:	79 6e                	jns    801405 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801397:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139b:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8013aa:	00 
  8013ab:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  8013b2:	e8 bd ef ff ff       	call   800374 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8013b7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013be:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013c7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d9:	89 04 24             	mov    %eax,(%esp)
  8013dc:	e8 7c fa ff ff       	call   800e5d <sys_page_map>
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	79 20                	jns    801405 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8013e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e9:	c7 44 24 08 93 31 80 	movl   $0x803193,0x8(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8013f8:	00 
  8013f9:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801400:	e8 6f ef ff ff       	call   800374 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801405:	46                   	inc    %esi
  801406:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80140c:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801412:	0f 85 5f fe ff ff    	jne    801277 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801418:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80141f:	00 
  801420:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801427:	ee 
  801428:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 d6 f9 ff ff       	call   800e09 <sys_page_alloc>
  801433:	85 c0                	test   %eax,%eax
  801435:	79 20                	jns    801457 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143b:	c7 44 24 08 7f 31 80 	movl   $0x80317f,0x8(%esp)
  801442:	00 
  801443:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80144a:	00 
  80144b:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801452:	e8 1d ef ff ff       	call   800374 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801457:	c7 44 24 04 6c 28 80 	movl   $0x80286c,0x4(%esp)
  80145e:	00 
  80145f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 3f fb ff ff       	call   800fa9 <sys_env_set_pgfault_upcall>
  80146a:	85 c0                	test   %eax,%eax
  80146c:	79 20                	jns    80148e <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80146e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801472:	c7 44 24 08 54 31 80 	movl   $0x803154,0x8(%esp)
  801479:	00 
  80147a:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801481:	00 
  801482:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  801489:	e8 e6 ee ff ff       	call   800374 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  80148e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801495:	00 
  801496:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801499:	89 04 24             	mov    %eax,(%esp)
  80149c:	e8 62 fa ff ff       	call   800f03 <sys_env_set_status>
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	79 20                	jns    8014c5 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  8014a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a9:	c7 44 24 08 b6 31 80 	movl   $0x8031b6,0x8(%esp)
  8014b0:	00 
  8014b1:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8014b8:	00 
  8014b9:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  8014c0:	e8 af ee ff ff       	call   800374 <_panic>

	return child_envid;
}
  8014c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014c8:	83 c4 3c             	add    $0x3c,%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <sfork>:

// Challenge!
int
sfork(void)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014d6:	c7 44 24 08 ce 31 80 	movl   $0x8031ce,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 74 31 80 00 	movl   $0x803174,(%esp)
  8014ed:	e8 82 ee ff ff       	call   800374 <_panic>
	...

008014f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8014ff:	c1 e8 0c             	shr    $0xc,%eax
}
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80150a:	8b 45 08             	mov    0x8(%ebp),%eax
  80150d:	89 04 24             	mov    %eax,(%esp)
  801510:	e8 df ff ff ff       	call   8014f4 <fd2num>
  801515:	05 20 00 0d 00       	add    $0xd0020,%eax
  80151a:	c1 e0 0c             	shl    $0xc,%eax
}
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	53                   	push   %ebx
  801523:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801526:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80152b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	c1 ea 16             	shr    $0x16,%edx
  801532:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801539:	f6 c2 01             	test   $0x1,%dl
  80153c:	74 11                	je     80154f <fd_alloc+0x30>
  80153e:	89 c2                	mov    %eax,%edx
  801540:	c1 ea 0c             	shr    $0xc,%edx
  801543:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154a:	f6 c2 01             	test   $0x1,%dl
  80154d:	75 09                	jne    801558 <fd_alloc+0x39>
			*fd_store = fd;
  80154f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	eb 17                	jmp    80156f <fd_alloc+0x50>
  801558:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80155d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801562:	75 c7                	jne    80152b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801564:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80156a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80156f:	5b                   	pop    %ebx
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801578:	83 f8 1f             	cmp    $0x1f,%eax
  80157b:	77 36                	ja     8015b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80157d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801582:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801585:	89 c2                	mov    %eax,%edx
  801587:	c1 ea 16             	shr    $0x16,%edx
  80158a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801591:	f6 c2 01             	test   $0x1,%dl
  801594:	74 24                	je     8015ba <fd_lookup+0x48>
  801596:	89 c2                	mov    %eax,%edx
  801598:	c1 ea 0c             	shr    $0xc,%edx
  80159b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a2:	f6 c2 01             	test   $0x1,%dl
  8015a5:	74 1a                	je     8015c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8015ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b1:	eb 13                	jmp    8015c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b8:	eb 0c                	jmp    8015c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bf:	eb 05                	jmp    8015c6 <fd_lookup+0x54>
  8015c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8015c6:	5d                   	pop    %ebp
  8015c7:	c3                   	ret    

008015c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 14             	sub    $0x14,%esp
  8015cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8015d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015da:	eb 0e                	jmp    8015ea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8015dc:	39 08                	cmp    %ecx,(%eax)
  8015de:	75 09                	jne    8015e9 <dev_lookup+0x21>
			*dev = devtab[i];
  8015e0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e7:	eb 33                	jmp    80161c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8015e9:	42                   	inc    %edx
  8015ea:	8b 04 95 60 32 80 00 	mov    0x803260(,%edx,4),%eax
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	75 e7                	jne    8015dc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015f5:	a1 08 50 80 00       	mov    0x805008,%eax
  8015fa:	8b 40 48             	mov    0x48(%eax),%eax
  8015fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801601:	89 44 24 04          	mov    %eax,0x4(%esp)
  801605:	c7 04 24 e4 31 80 00 	movl   $0x8031e4,(%esp)
  80160c:	e8 5b ee ff ff       	call   80046c <cprintf>
	*dev = 0;
  801611:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801617:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80161c:	83 c4 14             	add    $0x14,%esp
  80161f:	5b                   	pop    %ebx
  801620:	5d                   	pop    %ebp
  801621:	c3                   	ret    

00801622 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	56                   	push   %esi
  801626:	53                   	push   %ebx
  801627:	83 ec 30             	sub    $0x30,%esp
  80162a:	8b 75 08             	mov    0x8(%ebp),%esi
  80162d:	8a 45 0c             	mov    0xc(%ebp),%al
  801630:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801633:	89 34 24             	mov    %esi,(%esp)
  801636:	e8 b9 fe ff ff       	call   8014f4 <fd2num>
  80163b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80163e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801642:	89 04 24             	mov    %eax,(%esp)
  801645:	e8 28 ff ff ff       	call   801572 <fd_lookup>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 05                	js     801655 <fd_close+0x33>
	    || fd != fd2)
  801650:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801653:	74 0d                	je     801662 <fd_close+0x40>
		return (must_exist ? r : 0);
  801655:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801659:	75 46                	jne    8016a1 <fd_close+0x7f>
  80165b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801660:	eb 3f                	jmp    8016a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801662:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	8b 06                	mov    (%esi),%eax
  80166b:	89 04 24             	mov    %eax,(%esp)
  80166e:	e8 55 ff ff ff       	call   8015c8 <dev_lookup>
  801673:	89 c3                	mov    %eax,%ebx
  801675:	85 c0                	test   %eax,%eax
  801677:	78 18                	js     801691 <fd_close+0x6f>
		if (dev->dev_close)
  801679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167c:	8b 40 10             	mov    0x10(%eax),%eax
  80167f:	85 c0                	test   %eax,%eax
  801681:	74 09                	je     80168c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801683:	89 34 24             	mov    %esi,(%esp)
  801686:	ff d0                	call   *%eax
  801688:	89 c3                	mov    %eax,%ebx
  80168a:	eb 05                	jmp    801691 <fd_close+0x6f>
		else
			r = 0;
  80168c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801691:	89 74 24 04          	mov    %esi,0x4(%esp)
  801695:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80169c:	e8 0f f8 ff ff       	call   800eb0 <sys_page_unmap>
	return r;
}
  8016a1:	89 d8                	mov    %ebx,%eax
  8016a3:	83 c4 30             	add    $0x30,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ba:	89 04 24             	mov    %eax,(%esp)
  8016bd:	e8 b0 fe ff ff       	call   801572 <fd_lookup>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 13                	js     8016d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016cd:	00 
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 49 ff ff ff       	call   801622 <fd_close>
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <close_all>:

void
close_all(void)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016e7:	89 1c 24             	mov    %ebx,(%esp)
  8016ea:	e8 bb ff ff ff       	call   8016aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ef:	43                   	inc    %ebx
  8016f0:	83 fb 20             	cmp    $0x20,%ebx
  8016f3:	75 f2                	jne    8016e7 <close_all+0xc>
		close(i);
}
  8016f5:	83 c4 14             	add    $0x14,%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	57                   	push   %edi
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 4c             	sub    $0x4c,%esp
  801704:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801707:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80170a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170e:	8b 45 08             	mov    0x8(%ebp),%eax
  801711:	89 04 24             	mov    %eax,(%esp)
  801714:	e8 59 fe ff ff       	call   801572 <fd_lookup>
  801719:	89 c3                	mov    %eax,%ebx
  80171b:	85 c0                	test   %eax,%eax
  80171d:	0f 88 e1 00 00 00    	js     801804 <dup+0x109>
		return r;
	close(newfdnum);
  801723:	89 3c 24             	mov    %edi,(%esp)
  801726:	e8 7f ff ff ff       	call   8016aa <close>

	newfd = INDEX2FD(newfdnum);
  80172b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801731:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 c5 fd ff ff       	call   801504 <fd2data>
  80173f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801741:	89 34 24             	mov    %esi,(%esp)
  801744:	e8 bb fd ff ff       	call   801504 <fd2data>
  801749:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80174c:	89 d8                	mov    %ebx,%eax
  80174e:	c1 e8 16             	shr    $0x16,%eax
  801751:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801758:	a8 01                	test   $0x1,%al
  80175a:	74 46                	je     8017a2 <dup+0xa7>
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	c1 e8 0c             	shr    $0xc,%eax
  801761:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801768:	f6 c2 01             	test   $0x1,%dl
  80176b:	74 35                	je     8017a2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80176d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801774:	25 07 0e 00 00       	and    $0xe07,%eax
  801779:	89 44 24 10          	mov    %eax,0x10(%esp)
  80177d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801780:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801784:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178b:	00 
  80178c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801790:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801797:	e8 c1 f6 ff ff       	call   800e5d <sys_page_map>
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 3b                	js     8017dd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a5:	89 c2                	mov    %eax,%edx
  8017a7:	c1 ea 0c             	shr    $0xc,%edx
  8017aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017c6:	00 
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d2:	e8 86 f6 ff ff       	call   800e5d <sys_page_map>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	79 25                	jns    801802 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e8:	e8 c3 f6 ff ff       	call   800eb0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fb:	e8 b0 f6 ff ff       	call   800eb0 <sys_page_unmap>
	return r;
  801800:	eb 02                	jmp    801804 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801802:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801804:	89 d8                	mov    %ebx,%eax
  801806:	83 c4 4c             	add    $0x4c,%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5f                   	pop    %edi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 24             	sub    $0x24,%esp
  801815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801818:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181f:	89 1c 24             	mov    %ebx,(%esp)
  801822:	e8 4b fd ff ff       	call   801572 <fd_lookup>
  801827:	85 c0                	test   %eax,%eax
  801829:	78 6d                	js     801898 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801835:	8b 00                	mov    (%eax),%eax
  801837:	89 04 24             	mov    %eax,(%esp)
  80183a:	e8 89 fd ff ff       	call   8015c8 <dev_lookup>
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 55                	js     801898 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801846:	8b 50 08             	mov    0x8(%eax),%edx
  801849:	83 e2 03             	and    $0x3,%edx
  80184c:	83 fa 01             	cmp    $0x1,%edx
  80184f:	75 23                	jne    801874 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801851:	a1 08 50 80 00       	mov    0x805008,%eax
  801856:	8b 40 48             	mov    0x48(%eax),%eax
  801859:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80185d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801861:	c7 04 24 25 32 80 00 	movl   $0x803225,(%esp)
  801868:	e8 ff eb ff ff       	call   80046c <cprintf>
		return -E_INVAL;
  80186d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801872:	eb 24                	jmp    801898 <read+0x8a>
	}
	if (!dev->dev_read)
  801874:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801877:	8b 52 08             	mov    0x8(%edx),%edx
  80187a:	85 d2                	test   %edx,%edx
  80187c:	74 15                	je     801893 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80187e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801881:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801885:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801888:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80188c:	89 04 24             	mov    %eax,(%esp)
  80188f:	ff d2                	call   *%edx
  801891:	eb 05                	jmp    801898 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801893:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801898:	83 c4 24             	add    $0x24,%esp
  80189b:	5b                   	pop    %ebx
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	57                   	push   %edi
  8018a2:	56                   	push   %esi
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 1c             	sub    $0x1c,%esp
  8018a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b2:	eb 23                	jmp    8018d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018b4:	89 f0                	mov    %esi,%eax
  8018b6:	29 d8                	sub    %ebx,%eax
  8018b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	01 d8                	add    %ebx,%eax
  8018c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c5:	89 3c 24             	mov    %edi,(%esp)
  8018c8:	e8 41 ff ff ff       	call   80180e <read>
		if (m < 0)
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 10                	js     8018e1 <readn+0x43>
			return m;
		if (m == 0)
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	74 0a                	je     8018df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018d5:	01 c3                	add    %eax,%ebx
  8018d7:	39 f3                	cmp    %esi,%ebx
  8018d9:	72 d9                	jb     8018b4 <readn+0x16>
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	eb 02                	jmp    8018e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8018df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8018e1:	83 c4 1c             	add    $0x1c,%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5f                   	pop    %edi
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	53                   	push   %ebx
  8018ed:	83 ec 24             	sub    $0x24,%esp
  8018f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fa:	89 1c 24             	mov    %ebx,(%esp)
  8018fd:	e8 70 fc ff ff       	call   801572 <fd_lookup>
  801902:	85 c0                	test   %eax,%eax
  801904:	78 68                	js     80196e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801906:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801910:	8b 00                	mov    (%eax),%eax
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	e8 ae fc ff ff       	call   8015c8 <dev_lookup>
  80191a:	85 c0                	test   %eax,%eax
  80191c:	78 50                	js     80196e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801921:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801925:	75 23                	jne    80194a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801927:	a1 08 50 80 00       	mov    0x805008,%eax
  80192c:	8b 40 48             	mov    0x48(%eax),%eax
  80192f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801933:	89 44 24 04          	mov    %eax,0x4(%esp)
  801937:	c7 04 24 41 32 80 00 	movl   $0x803241,(%esp)
  80193e:	e8 29 eb ff ff       	call   80046c <cprintf>
		return -E_INVAL;
  801943:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801948:	eb 24                	jmp    80196e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80194a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194d:	8b 52 0c             	mov    0xc(%edx),%edx
  801950:	85 d2                	test   %edx,%edx
  801952:	74 15                	je     801969 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801954:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801957:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80195b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80195e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801962:	89 04 24             	mov    %eax,(%esp)
  801965:	ff d2                	call   *%edx
  801967:	eb 05                	jmp    80196e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801969:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80196e:	83 c4 24             	add    $0x24,%esp
  801971:	5b                   	pop    %ebx
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <seek>:

int
seek(int fdnum, off_t offset)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80197d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801981:	8b 45 08             	mov    0x8(%ebp),%eax
  801984:	89 04 24             	mov    %eax,(%esp)
  801987:	e8 e6 fb ff ff       	call   801572 <fd_lookup>
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 0e                	js     80199e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801990:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801993:	8b 55 0c             	mov    0xc(%ebp),%edx
  801996:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801999:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	53                   	push   %ebx
  8019a4:	83 ec 24             	sub    $0x24,%esp
  8019a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b1:	89 1c 24             	mov    %ebx,(%esp)
  8019b4:	e8 b9 fb ff ff       	call   801572 <fd_lookup>
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	78 61                	js     801a1e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c7:	8b 00                	mov    (%eax),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 f7 fb ff ff       	call   8015c8 <dev_lookup>
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 49                	js     801a1e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8019dc:	75 23                	jne    801a01 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8019de:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8019e3:	8b 40 48             	mov    0x48(%eax),%eax
  8019e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ee:	c7 04 24 04 32 80 00 	movl   $0x803204,(%esp)
  8019f5:	e8 72 ea ff ff       	call   80046c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019ff:	eb 1d                	jmp    801a1e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a04:	8b 52 18             	mov    0x18(%edx),%edx
  801a07:	85 d2                	test   %edx,%edx
  801a09:	74 0e                	je     801a19 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	ff d2                	call   *%edx
  801a17:	eb 05                	jmp    801a1e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801a19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801a1e:	83 c4 24             	add    $0x24,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	53                   	push   %ebx
  801a28:	83 ec 24             	sub    $0x24,%esp
  801a2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	89 04 24             	mov    %eax,(%esp)
  801a3b:	e8 32 fb ff ff       	call   801572 <fd_lookup>
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 52                	js     801a96 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4e:	8b 00                	mov    (%eax),%eax
  801a50:	89 04 24             	mov    %eax,(%esp)
  801a53:	e8 70 fb ff ff       	call   8015c8 <dev_lookup>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 3a                	js     801a96 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a63:	74 2c                	je     801a91 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a65:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a68:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a6f:	00 00 00 
	stat->st_isdir = 0;
  801a72:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a79:	00 00 00 
	stat->st_dev = dev;
  801a7c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a86:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a89:	89 14 24             	mov    %edx,(%esp)
  801a8c:	ff 50 14             	call   *0x14(%eax)
  801a8f:	eb 05                	jmp    801a96 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a91:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a96:	83 c4 24             	add    $0x24,%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801aa4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801aab:	00 
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	89 04 24             	mov    %eax,(%esp)
  801ab2:	e8 2d 02 00 00       	call   801ce4 <open>
  801ab7:	89 c3                	mov    %eax,%ebx
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 1b                	js     801ad8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac4:	89 1c 24             	mov    %ebx,(%esp)
  801ac7:	e8 58 ff ff ff       	call   801a24 <fstat>
  801acc:	89 c6                	mov    %eax,%esi
	close(fd);
  801ace:	89 1c 24             	mov    %ebx,(%esp)
  801ad1:	e8 d4 fb ff ff       	call   8016aa <close>
	return r;
  801ad6:	89 f3                	mov    %esi,%ebx
}
  801ad8:	89 d8                	mov    %ebx,%eax
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    
  801ae1:	00 00                	add    %al,(%eax)
	...

00801ae4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	83 ec 10             	sub    $0x10,%esp
  801aec:	89 c3                	mov    %eax,%ebx
  801aee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801af0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801af7:	75 11                	jne    801b0a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801af9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b00:	e8 62 0e 00 00       	call   802967 <ipc_find_env>
  801b05:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b0a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b11:	00 
  801b12:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b19:	00 
  801b1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1e:	a1 00 50 80 00       	mov    0x805000,%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 ce 0d 00 00       	call   8028f9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b32:	00 
  801b33:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3e:	e8 4d 0d 00 00       	call   802890 <ipc_recv>
}
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5d                   	pop    %ebp
  801b49:	c3                   	ret    

00801b4a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 40 0c             	mov    0xc(%eax),%eax
  801b56:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b63:	ba 00 00 00 00       	mov    $0x0,%edx
  801b68:	b8 02 00 00 00       	mov    $0x2,%eax
  801b6d:	e8 72 ff ff ff       	call   801ae4 <fsipc>
}
  801b72:	c9                   	leave  
  801b73:	c3                   	ret    

00801b74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b80:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b85:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b8f:	e8 50 ff ff ff       	call   801ae4 <fsipc>
}
  801b94:	c9                   	leave  
  801b95:	c3                   	ret    

00801b96 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 14             	sub    $0x14,%esp
  801b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba3:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba6:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bab:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb0:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb5:	e8 2a ff ff ff       	call   801ae4 <fsipc>
  801bba:	85 c0                	test   %eax,%eax
  801bbc:	78 2b                	js     801be9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801bbe:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801bc5:	00 
  801bc6:	89 1c 24             	mov    %ebx,(%esp)
  801bc9:	e8 49 ee ff ff       	call   800a17 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bce:	a1 80 60 80 00       	mov    0x806080,%eax
  801bd3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bd9:	a1 84 60 80 00       	mov    0x806084,%eax
  801bde:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801be9:	83 c4 14             	add    $0x14,%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	83 ec 18             	sub    $0x18,%esp
  801bf5:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf8:	89 d0                	mov    %edx,%eax
  801bfa:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801c00:	76 05                	jbe    801c07 <devfile_write+0x18>
  801c02:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c07:	8b 55 08             	mov    0x8(%ebp),%edx
  801c0a:	8b 52 0c             	mov    0xc(%edx),%edx
  801c0d:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801c13:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801c18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c23:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c2a:	e8 61 ef ff ff       	call   800b90 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c34:	b8 04 00 00 00       	mov    $0x4,%eax
  801c39:	e8 a6 fe ff ff       	call   801ae4 <fsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 10             	sub    $0x10,%esp
  801c48:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c51:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c56:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c5c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c61:	b8 03 00 00 00       	mov    $0x3,%eax
  801c66:	e8 79 fe ff ff       	call   801ae4 <fsipc>
  801c6b:	89 c3                	mov    %eax,%ebx
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 6a                	js     801cdb <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c71:	39 c6                	cmp    %eax,%esi
  801c73:	73 24                	jae    801c99 <devfile_read+0x59>
  801c75:	c7 44 24 0c 74 32 80 	movl   $0x803274,0xc(%esp)
  801c7c:	00 
  801c7d:	c7 44 24 08 7b 32 80 	movl   $0x80327b,0x8(%esp)
  801c84:	00 
  801c85:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c8c:	00 
  801c8d:	c7 04 24 90 32 80 00 	movl   $0x803290,(%esp)
  801c94:	e8 db e6 ff ff       	call   800374 <_panic>
	assert(r <= PGSIZE);
  801c99:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c9e:	7e 24                	jle    801cc4 <devfile_read+0x84>
  801ca0:	c7 44 24 0c 9b 32 80 	movl   $0x80329b,0xc(%esp)
  801ca7:	00 
  801ca8:	c7 44 24 08 7b 32 80 	movl   $0x80327b,0x8(%esp)
  801caf:	00 
  801cb0:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801cb7:	00 
  801cb8:	c7 04 24 90 32 80 00 	movl   $0x803290,(%esp)
  801cbf:	e8 b0 e6 ff ff       	call   800374 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ccf:	00 
  801cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd3:	89 04 24             	mov    %eax,(%esp)
  801cd6:	e8 b5 ee ff ff       	call   800b90 <memmove>
	return r;
}
  801cdb:	89 d8                	mov    %ebx,%eax
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 20             	sub    $0x20,%esp
  801cec:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801cef:	89 34 24             	mov    %esi,(%esp)
  801cf2:	e8 ed ec ff ff       	call   8009e4 <strlen>
  801cf7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cfc:	7f 60                	jg     801d5e <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d01:	89 04 24             	mov    %eax,(%esp)
  801d04:	e8 16 f8 ff ff       	call   80151f <fd_alloc>
  801d09:	89 c3                	mov    %eax,%ebx
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 54                	js     801d63 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801d0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d13:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d1a:	e8 f8 ec ff ff       	call   800a17 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d22:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801d27:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2f:	e8 b0 fd ff ff       	call   801ae4 <fsipc>
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	85 c0                	test   %eax,%eax
  801d38:	79 15                	jns    801d4f <open+0x6b>
		fd_close(fd, 0);
  801d3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d41:	00 
  801d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d45:	89 04 24             	mov    %eax,(%esp)
  801d48:	e8 d5 f8 ff ff       	call   801622 <fd_close>
		return r;
  801d4d:	eb 14                	jmp    801d63 <open+0x7f>
	}

	return fd2num(fd);
  801d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d52:	89 04 24             	mov    %eax,(%esp)
  801d55:	e8 9a f7 ff ff       	call   8014f4 <fd2num>
  801d5a:	89 c3                	mov    %eax,%ebx
  801d5c:	eb 05                	jmp    801d63 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d5e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d63:	89 d8                	mov    %ebx,%eax
  801d65:	83 c4 20             	add    $0x20,%esp
  801d68:	5b                   	pop    %ebx
  801d69:	5e                   	pop    %esi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    

00801d6c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d72:	ba 00 00 00 00       	mov    $0x0,%edx
  801d77:	b8 08 00 00 00       	mov    $0x8,%eax
  801d7c:	e8 63 fd ff ff       	call   801ae4 <fsipc>
}
  801d81:	c9                   	leave  
  801d82:	c3                   	ret    
	...

00801d84 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d8a:	c7 44 24 04 a7 32 80 	movl   $0x8032a7,0x4(%esp)
  801d91:	00 
  801d92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d95:	89 04 24             	mov    %eax,(%esp)
  801d98:	e8 7a ec ff ff       	call   800a17 <strcpy>
	return 0;
}
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	53                   	push   %ebx
  801da8:	83 ec 14             	sub    $0x14,%esp
  801dab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801dae:	89 1c 24             	mov    %ebx,(%esp)
  801db1:	e8 ea 0b 00 00       	call   8029a0 <pageref>
  801db6:	83 f8 01             	cmp    $0x1,%eax
  801db9:	75 0d                	jne    801dc8 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801dbb:	8b 43 0c             	mov    0xc(%ebx),%eax
  801dbe:	89 04 24             	mov    %eax,(%esp)
  801dc1:	e8 1f 03 00 00       	call   8020e5 <nsipc_close>
  801dc6:	eb 05                	jmp    801dcd <devsock_close+0x29>
	else
		return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dcd:	83 c4 14             	add    $0x14,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dd9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801de0:	00 
  801de1:	8b 45 10             	mov    0x10(%ebp),%eax
  801de4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801deb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801def:	8b 45 08             	mov    0x8(%ebp),%eax
  801df2:	8b 40 0c             	mov    0xc(%eax),%eax
  801df5:	89 04 24             	mov    %eax,(%esp)
  801df8:	e8 e3 03 00 00       	call   8021e0 <nsipc_send>
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e05:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e0c:	00 
  801e0d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e10:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e21:	89 04 24             	mov    %eax,(%esp)
  801e24:	e8 37 03 00 00       	call   802160 <nsipc_recv>
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 20             	sub    $0x20,%esp
  801e33:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e38:	89 04 24             	mov    %eax,(%esp)
  801e3b:	e8 df f6 ff ff       	call   80151f <fd_alloc>
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 21                	js     801e67 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e4d:	00 
  801e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5c:	e8 a8 ef ff ff       	call   800e09 <sys_page_alloc>
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	85 c0                	test   %eax,%eax
  801e65:	79 0a                	jns    801e71 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801e67:	89 34 24             	mov    %esi,(%esp)
  801e6a:	e8 76 02 00 00       	call   8020e5 <nsipc_close>
		return r;
  801e6f:	eb 22                	jmp    801e93 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e71:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e86:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e89:	89 04 24             	mov    %eax,(%esp)
  801e8c:	e8 63 f6 ff ff       	call   8014f4 <fd2num>
  801e91:	89 c3                	mov    %eax,%ebx
}
  801e93:	89 d8                	mov    %ebx,%eax
  801e95:	83 c4 20             	add    $0x20,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ea2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ea5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea9:	89 04 24             	mov    %eax,(%esp)
  801eac:	e8 c1 f6 ff ff       	call   801572 <fd_lookup>
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 17                	js     801ecc <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb8:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801ebe:	39 10                	cmp    %edx,(%eax)
  801ec0:	75 05                	jne    801ec7 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ec2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ec5:	eb 05                	jmp    801ecc <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ec7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed7:	e8 c0 ff ff ff       	call   801e9c <fd2sockid>
  801edc:	85 c0                	test   %eax,%eax
  801ede:	78 1f                	js     801eff <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ee0:	8b 55 10             	mov    0x10(%ebp),%edx
  801ee3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ee7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eea:	89 54 24 04          	mov    %edx,0x4(%esp)
  801eee:	89 04 24             	mov    %eax,(%esp)
  801ef1:	e8 38 01 00 00       	call   80202e <nsipc_accept>
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 05                	js     801eff <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801efa:	e8 2c ff ff ff       	call   801e2b <alloc_sockfd>
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	e8 8d ff ff ff       	call   801e9c <fd2sockid>
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	78 16                	js     801f29 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801f13:	8b 55 10             	mov    0x10(%ebp),%edx
  801f16:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f21:	89 04 24             	mov    %eax,(%esp)
  801f24:	e8 5b 01 00 00       	call   802084 <nsipc_bind>
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <shutdown>:

int
shutdown(int s, int how)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f31:	8b 45 08             	mov    0x8(%ebp),%eax
  801f34:	e8 63 ff ff ff       	call   801e9c <fd2sockid>
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 0f                	js     801f4c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f40:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f44:	89 04 24             	mov    %eax,(%esp)
  801f47:	e8 77 01 00 00       	call   8020c3 <nsipc_shutdown>
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
  801f51:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f54:	8b 45 08             	mov    0x8(%ebp),%eax
  801f57:	e8 40 ff ff ff       	call   801e9c <fd2sockid>
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 16                	js     801f76 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801f60:	8b 55 10             	mov    0x10(%ebp),%edx
  801f63:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 89 01 00 00       	call   8020ff <nsipc_connect>
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <listen>:

int
listen(int s, int backlog)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f81:	e8 16 ff ff ff       	call   801e9c <fd2sockid>
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 0f                	js     801f99 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 a5 01 00 00       	call   80213e <nsipc_listen>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fa1:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801faf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb2:	89 04 24             	mov    %eax,(%esp)
  801fb5:	e8 99 02 00 00       	call   802253 <nsipc_socket>
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	78 05                	js     801fc3 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801fbe:	e8 68 fe ff ff       	call   801e2b <alloc_sockfd>
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    
  801fc5:	00 00                	add    %al,(%eax)
	...

00801fc8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	53                   	push   %ebx
  801fcc:	83 ec 14             	sub    $0x14,%esp
  801fcf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fd1:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801fd8:	75 11                	jne    801feb <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fda:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801fe1:	e8 81 09 00 00       	call   802967 <ipc_find_env>
  801fe6:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801feb:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ff2:	00 
  801ff3:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801ffa:	00 
  801ffb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fff:	a1 04 50 80 00       	mov    0x805004,%eax
  802004:	89 04 24             	mov    %eax,(%esp)
  802007:	e8 ed 08 00 00       	call   8028f9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80200c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802013:	00 
  802014:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80201b:	00 
  80201c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802023:	e8 68 08 00 00       	call   802890 <ipc_recv>
}
  802028:	83 c4 14             	add    $0x14,%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5d                   	pop    %ebp
  80202d:	c3                   	ret    

0080202e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80202e:	55                   	push   %ebp
  80202f:	89 e5                	mov    %esp,%ebp
  802031:	56                   	push   %esi
  802032:	53                   	push   %ebx
  802033:	83 ec 10             	sub    $0x10,%esp
  802036:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802039:	8b 45 08             	mov    0x8(%ebp),%eax
  80203c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802041:	8b 06                	mov    (%esi),%eax
  802043:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802048:	b8 01 00 00 00       	mov    $0x1,%eax
  80204d:	e8 76 ff ff ff       	call   801fc8 <nsipc>
  802052:	89 c3                	mov    %eax,%ebx
  802054:	85 c0                	test   %eax,%eax
  802056:	78 23                	js     80207b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802058:	a1 10 70 80 00       	mov    0x807010,%eax
  80205d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802061:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802068:	00 
  802069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206c:	89 04 24             	mov    %eax,(%esp)
  80206f:	e8 1c eb ff ff       	call   800b90 <memmove>
		*addrlen = ret->ret_addrlen;
  802074:	a1 10 70 80 00       	mov    0x807010,%eax
  802079:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80207b:	89 d8                	mov    %ebx,%eax
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    

00802084 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	53                   	push   %ebx
  802088:	83 ec 14             	sub    $0x14,%esp
  80208b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802096:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a1:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020a8:	e8 e3 ea ff ff       	call   800b90 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8020ad:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8020b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8020b8:	e8 0b ff ff ff       	call   801fc8 <nsipc>
}
  8020bd:	83 c4 14             	add    $0x14,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5d                   	pop    %ebp
  8020c2:	c3                   	ret    

008020c3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020c3:	55                   	push   %ebp
  8020c4:	89 e5                	mov    %esp,%ebp
  8020c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020cc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8020d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8020d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8020de:	e8 e5 fe ff ff       	call   801fc8 <nsipc>
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <nsipc_close>:

int
nsipc_close(int s)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ee:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8020f8:	e8 cb fe ff ff       	call   801fc8 <nsipc>
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	53                   	push   %ebx
  802103:	83 ec 14             	sub    $0x14,%esp
  802106:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802109:	8b 45 08             	mov    0x8(%ebp),%eax
  80210c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802111:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802115:	8b 45 0c             	mov    0xc(%ebp),%eax
  802118:	89 44 24 04          	mov    %eax,0x4(%esp)
  80211c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802123:	e8 68 ea ff ff       	call   800b90 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802128:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80212e:	b8 05 00 00 00       	mov    $0x5,%eax
  802133:	e8 90 fe ff ff       	call   801fc8 <nsipc>
}
  802138:	83 c4 14             	add    $0x14,%esp
  80213b:	5b                   	pop    %ebx
  80213c:	5d                   	pop    %ebp
  80213d:	c3                   	ret    

0080213e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802144:	8b 45 08             	mov    0x8(%ebp),%eax
  802147:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80214c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80214f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802154:	b8 06 00 00 00       	mov    $0x6,%eax
  802159:	e8 6a fe ff ff       	call   801fc8 <nsipc>
}
  80215e:	c9                   	leave  
  80215f:	c3                   	ret    

00802160 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	56                   	push   %esi
  802164:	53                   	push   %ebx
  802165:	83 ec 10             	sub    $0x10,%esp
  802168:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
  80216e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802173:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802179:	8b 45 14             	mov    0x14(%ebp),%eax
  80217c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802181:	b8 07 00 00 00       	mov    $0x7,%eax
  802186:	e8 3d fe ff ff       	call   801fc8 <nsipc>
  80218b:	89 c3                	mov    %eax,%ebx
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 46                	js     8021d7 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802191:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802196:	7f 04                	jg     80219c <nsipc_recv+0x3c>
  802198:	39 c6                	cmp    %eax,%esi
  80219a:	7d 24                	jge    8021c0 <nsipc_recv+0x60>
  80219c:	c7 44 24 0c b3 32 80 	movl   $0x8032b3,0xc(%esp)
  8021a3:	00 
  8021a4:	c7 44 24 08 7b 32 80 	movl   $0x80327b,0x8(%esp)
  8021ab:	00 
  8021ac:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8021b3:	00 
  8021b4:	c7 04 24 c8 32 80 00 	movl   $0x8032c8,(%esp)
  8021bb:	e8 b4 e1 ff ff       	call   800374 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021c4:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021cb:	00 
  8021cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cf:	89 04 24             	mov    %eax,(%esp)
  8021d2:	e8 b9 e9 ff ff       	call   800b90 <memmove>
	}

	return r;
}
  8021d7:	89 d8                	mov    %ebx,%eax
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	5b                   	pop    %ebx
  8021dd:	5e                   	pop    %esi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    

008021e0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 14             	sub    $0x14,%esp
  8021e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ed:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021f2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021f8:	7e 24                	jle    80221e <nsipc_send+0x3e>
  8021fa:	c7 44 24 0c d4 32 80 	movl   $0x8032d4,0xc(%esp)
  802201:	00 
  802202:	c7 44 24 08 7b 32 80 	movl   $0x80327b,0x8(%esp)
  802209:	00 
  80220a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802211:	00 
  802212:	c7 04 24 c8 32 80 00 	movl   $0x8032c8,(%esp)
  802219:	e8 56 e1 ff ff       	call   800374 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	8b 45 0c             	mov    0xc(%ebp),%eax
  802225:	89 44 24 04          	mov    %eax,0x4(%esp)
  802229:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802230:	e8 5b e9 ff ff       	call   800b90 <memmove>
	nsipcbuf.send.req_size = size;
  802235:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80223b:	8b 45 14             	mov    0x14(%ebp),%eax
  80223e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802243:	b8 08 00 00 00       	mov    $0x8,%eax
  802248:	e8 7b fd ff ff       	call   801fc8 <nsipc>
}
  80224d:	83 c4 14             	add    $0x14,%esp
  802250:	5b                   	pop    %ebx
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802259:	8b 45 08             	mov    0x8(%ebp),%eax
  80225c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802261:	8b 45 0c             	mov    0xc(%ebp),%eax
  802264:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802269:	8b 45 10             	mov    0x10(%ebp),%eax
  80226c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802271:	b8 09 00 00 00       	mov    $0x9,%eax
  802276:	e8 4d fd ff ff       	call   801fc8 <nsipc>
}
  80227b:	c9                   	leave  
  80227c:	c3                   	ret    
  80227d:	00 00                	add    %al,(%eax)
	...

00802280 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	83 ec 10             	sub    $0x10,%esp
  802288:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80228b:	8b 45 08             	mov    0x8(%ebp),%eax
  80228e:	89 04 24             	mov    %eax,(%esp)
  802291:	e8 6e f2 ff ff       	call   801504 <fd2data>
  802296:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802298:	c7 44 24 04 e0 32 80 	movl   $0x8032e0,0x4(%esp)
  80229f:	00 
  8022a0:	89 34 24             	mov    %esi,(%esp)
  8022a3:	e8 6f e7 ff ff       	call   800a17 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8022ab:	2b 03                	sub    (%ebx),%eax
  8022ad:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8022b3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8022ba:	00 00 00 
	stat->st_dev = &devpipe;
  8022bd:	c7 86 88 00 00 00 40 	movl   $0x804040,0x88(%esi)
  8022c4:	40 80 00 
	return 0;
}
  8022c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8022cc:	83 c4 10             	add    $0x10,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5d                   	pop    %ebp
  8022d2:	c3                   	ret    

008022d3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022d3:	55                   	push   %ebp
  8022d4:	89 e5                	mov    %esp,%ebp
  8022d6:	53                   	push   %ebx
  8022d7:	83 ec 14             	sub    $0x14,%esp
  8022da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e8:	e8 c3 eb ff ff       	call   800eb0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022ed:	89 1c 24             	mov    %ebx,(%esp)
  8022f0:	e8 0f f2 ff ff       	call   801504 <fd2data>
  8022f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802300:	e8 ab eb ff ff       	call   800eb0 <sys_page_unmap>
}
  802305:	83 c4 14             	add    $0x14,%esp
  802308:	5b                   	pop    %ebx
  802309:	5d                   	pop    %ebp
  80230a:	c3                   	ret    

0080230b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80230b:	55                   	push   %ebp
  80230c:	89 e5                	mov    %esp,%ebp
  80230e:	57                   	push   %edi
  80230f:	56                   	push   %esi
  802310:	53                   	push   %ebx
  802311:	83 ec 2c             	sub    $0x2c,%esp
  802314:	89 c7                	mov    %eax,%edi
  802316:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802319:	a1 08 50 80 00       	mov    0x805008,%eax
  80231e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802321:	89 3c 24             	mov    %edi,(%esp)
  802324:	e8 77 06 00 00       	call   8029a0 <pageref>
  802329:	89 c6                	mov    %eax,%esi
  80232b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80232e:	89 04 24             	mov    %eax,(%esp)
  802331:	e8 6a 06 00 00       	call   8029a0 <pageref>
  802336:	39 c6                	cmp    %eax,%esi
  802338:	0f 94 c0             	sete   %al
  80233b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80233e:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802344:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802347:	39 cb                	cmp    %ecx,%ebx
  802349:	75 08                	jne    802353 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80234b:	83 c4 2c             	add    $0x2c,%esp
  80234e:	5b                   	pop    %ebx
  80234f:	5e                   	pop    %esi
  802350:	5f                   	pop    %edi
  802351:	5d                   	pop    %ebp
  802352:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802353:	83 f8 01             	cmp    $0x1,%eax
  802356:	75 c1                	jne    802319 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802358:	8b 42 58             	mov    0x58(%edx),%eax
  80235b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802362:	00 
  802363:	89 44 24 08          	mov    %eax,0x8(%esp)
  802367:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80236b:	c7 04 24 e7 32 80 00 	movl   $0x8032e7,(%esp)
  802372:	e8 f5 e0 ff ff       	call   80046c <cprintf>
  802377:	eb a0                	jmp    802319 <_pipeisclosed+0xe>

00802379 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802379:	55                   	push   %ebp
  80237a:	89 e5                	mov    %esp,%ebp
  80237c:	57                   	push   %edi
  80237d:	56                   	push   %esi
  80237e:	53                   	push   %ebx
  80237f:	83 ec 1c             	sub    $0x1c,%esp
  802382:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802385:	89 34 24             	mov    %esi,(%esp)
  802388:	e8 77 f1 ff ff       	call   801504 <fd2data>
  80238d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80238f:	bf 00 00 00 00       	mov    $0x0,%edi
  802394:	eb 3c                	jmp    8023d2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802396:	89 da                	mov    %ebx,%edx
  802398:	89 f0                	mov    %esi,%eax
  80239a:	e8 6c ff ff ff       	call   80230b <_pipeisclosed>
  80239f:	85 c0                	test   %eax,%eax
  8023a1:	75 38                	jne    8023db <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8023a3:	e8 42 ea ff ff       	call   800dea <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8023a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8023ab:	8b 13                	mov    (%ebx),%edx
  8023ad:	83 c2 20             	add    $0x20,%edx
  8023b0:	39 d0                	cmp    %edx,%eax
  8023b2:	73 e2                	jae    802396 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023b7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8023ba:	89 c2                	mov    %eax,%edx
  8023bc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8023c2:	79 05                	jns    8023c9 <devpipe_write+0x50>
  8023c4:	4a                   	dec    %edx
  8023c5:	83 ca e0             	or     $0xffffffe0,%edx
  8023c8:	42                   	inc    %edx
  8023c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023cd:	40                   	inc    %eax
  8023ce:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023d1:	47                   	inc    %edi
  8023d2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8023d5:	75 d1                	jne    8023a8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8023d7:	89 f8                	mov    %edi,%eax
  8023d9:	eb 05                	jmp    8023e0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    

008023e8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	57                   	push   %edi
  8023ec:	56                   	push   %esi
  8023ed:	53                   	push   %ebx
  8023ee:	83 ec 1c             	sub    $0x1c,%esp
  8023f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023f4:	89 3c 24             	mov    %edi,(%esp)
  8023f7:	e8 08 f1 ff ff       	call   801504 <fd2data>
  8023fc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023fe:	be 00 00 00 00       	mov    $0x0,%esi
  802403:	eb 3a                	jmp    80243f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802405:	85 f6                	test   %esi,%esi
  802407:	74 04                	je     80240d <devpipe_read+0x25>
				return i;
  802409:	89 f0                	mov    %esi,%eax
  80240b:	eb 40                	jmp    80244d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80240d:	89 da                	mov    %ebx,%edx
  80240f:	89 f8                	mov    %edi,%eax
  802411:	e8 f5 fe ff ff       	call   80230b <_pipeisclosed>
  802416:	85 c0                	test   %eax,%eax
  802418:	75 2e                	jne    802448 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80241a:	e8 cb e9 ff ff       	call   800dea <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80241f:	8b 03                	mov    (%ebx),%eax
  802421:	3b 43 04             	cmp    0x4(%ebx),%eax
  802424:	74 df                	je     802405 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802426:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80242b:	79 05                	jns    802432 <devpipe_read+0x4a>
  80242d:	48                   	dec    %eax
  80242e:	83 c8 e0             	or     $0xffffffe0,%eax
  802431:	40                   	inc    %eax
  802432:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802436:	8b 55 0c             	mov    0xc(%ebp),%edx
  802439:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80243c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80243e:	46                   	inc    %esi
  80243f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802442:	75 db                	jne    80241f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802444:	89 f0                	mov    %esi,%eax
  802446:	eb 05                	jmp    80244d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802448:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80244d:	83 c4 1c             	add    $0x1c,%esp
  802450:	5b                   	pop    %ebx
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    

00802455 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802455:	55                   	push   %ebp
  802456:	89 e5                	mov    %esp,%ebp
  802458:	57                   	push   %edi
  802459:	56                   	push   %esi
  80245a:	53                   	push   %ebx
  80245b:	83 ec 3c             	sub    $0x3c,%esp
  80245e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802461:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802464:	89 04 24             	mov    %eax,(%esp)
  802467:	e8 b3 f0 ff ff       	call   80151f <fd_alloc>
  80246c:	89 c3                	mov    %eax,%ebx
  80246e:	85 c0                	test   %eax,%eax
  802470:	0f 88 45 01 00 00    	js     8025bb <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802476:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80247d:	00 
  80247e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802481:	89 44 24 04          	mov    %eax,0x4(%esp)
  802485:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80248c:	e8 78 e9 ff ff       	call   800e09 <sys_page_alloc>
  802491:	89 c3                	mov    %eax,%ebx
  802493:	85 c0                	test   %eax,%eax
  802495:	0f 88 20 01 00 00    	js     8025bb <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80249b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80249e:	89 04 24             	mov    %eax,(%esp)
  8024a1:	e8 79 f0 ff ff       	call   80151f <fd_alloc>
  8024a6:	89 c3                	mov    %eax,%ebx
  8024a8:	85 c0                	test   %eax,%eax
  8024aa:	0f 88 f8 00 00 00    	js     8025a8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024b7:	00 
  8024b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024c6:	e8 3e e9 ff ff       	call   800e09 <sys_page_alloc>
  8024cb:	89 c3                	mov    %eax,%ebx
  8024cd:	85 c0                	test   %eax,%eax
  8024cf:	0f 88 d3 00 00 00    	js     8025a8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8024d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024d8:	89 04 24             	mov    %eax,(%esp)
  8024db:	e8 24 f0 ff ff       	call   801504 <fd2data>
  8024e0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024e2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024e9:	00 
  8024ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024f5:	e8 0f e9 ff ff       	call   800e09 <sys_page_alloc>
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	85 c0                	test   %eax,%eax
  8024fe:	0f 88 91 00 00 00    	js     802595 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802504:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802507:	89 04 24             	mov    %eax,(%esp)
  80250a:	e8 f5 ef ff ff       	call   801504 <fd2data>
  80250f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802516:	00 
  802517:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80251b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802522:	00 
  802523:	89 74 24 04          	mov    %esi,0x4(%esp)
  802527:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80252e:	e8 2a e9 ff ff       	call   800e5d <sys_page_map>
  802533:	89 c3                	mov    %eax,%ebx
  802535:	85 c0                	test   %eax,%eax
  802537:	78 4c                	js     802585 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802539:	8b 15 40 40 80 00    	mov    0x804040,%edx
  80253f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802542:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802544:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802547:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80254e:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802554:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802557:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802559:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80255c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802566:	89 04 24             	mov    %eax,(%esp)
  802569:	e8 86 ef ff ff       	call   8014f4 <fd2num>
  80256e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802570:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802573:	89 04 24             	mov    %eax,(%esp)
  802576:	e8 79 ef ff ff       	call   8014f4 <fd2num>
  80257b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80257e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802583:	eb 36                	jmp    8025bb <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802585:	89 74 24 04          	mov    %esi,0x4(%esp)
  802589:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802590:	e8 1b e9 ff ff       	call   800eb0 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802595:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802598:	89 44 24 04          	mov    %eax,0x4(%esp)
  80259c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a3:	e8 08 e9 ff ff       	call   800eb0 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8025a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b6:	e8 f5 e8 ff ff       	call   800eb0 <sys_page_unmap>
    err:
	return r;
}
  8025bb:	89 d8                	mov    %ebx,%eax
  8025bd:	83 c4 3c             	add    $0x3c,%esp
  8025c0:	5b                   	pop    %ebx
  8025c1:	5e                   	pop    %esi
  8025c2:	5f                   	pop    %edi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    

008025c5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8025c5:	55                   	push   %ebp
  8025c6:	89 e5                	mov    %esp,%ebp
  8025c8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d5:	89 04 24             	mov    %eax,(%esp)
  8025d8:	e8 95 ef ff ff       	call   801572 <fd_lookup>
  8025dd:	85 c0                	test   %eax,%eax
  8025df:	78 15                	js     8025f6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8025e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e4:	89 04 24             	mov    %eax,(%esp)
  8025e7:	e8 18 ef ff ff       	call   801504 <fd2data>
	return _pipeisclosed(fd, p);
  8025ec:	89 c2                	mov    %eax,%edx
  8025ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f1:	e8 15 fd ff ff       	call   80230b <_pipeisclosed>
}
  8025f6:	c9                   	leave  
  8025f7:	c3                   	ret    

008025f8 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	56                   	push   %esi
  8025fc:	53                   	push   %ebx
  8025fd:	83 ec 10             	sub    $0x10,%esp
  802600:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802603:	85 f6                	test   %esi,%esi
  802605:	75 24                	jne    80262b <wait+0x33>
  802607:	c7 44 24 0c ff 32 80 	movl   $0x8032ff,0xc(%esp)
  80260e:	00 
  80260f:	c7 44 24 08 7b 32 80 	movl   $0x80327b,0x8(%esp)
  802616:	00 
  802617:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80261e:	00 
  80261f:	c7 04 24 0a 33 80 00 	movl   $0x80330a,(%esp)
  802626:	e8 49 dd ff ff       	call   800374 <_panic>
	e = &envs[ENVX(envid)];
  80262b:	89 f3                	mov    %esi,%ebx
  80262d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802633:	c1 e3 07             	shl    $0x7,%ebx
  802636:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80263c:	eb 05                	jmp    802643 <wait+0x4b>
		sys_yield();
  80263e:	e8 a7 e7 ff ff       	call   800dea <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802643:	8b 43 48             	mov    0x48(%ebx),%eax
  802646:	39 f0                	cmp    %esi,%eax
  802648:	75 07                	jne    802651 <wait+0x59>
  80264a:	8b 43 54             	mov    0x54(%ebx),%eax
  80264d:	85 c0                	test   %eax,%eax
  80264f:	75 ed                	jne    80263e <wait+0x46>
		sys_yield();
}
  802651:	83 c4 10             	add    $0x10,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5d                   	pop    %ebp
  802657:	c3                   	ret    

00802658 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802658:	55                   	push   %ebp
  802659:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80265b:	b8 00 00 00 00       	mov    $0x0,%eax
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    

00802662 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802662:	55                   	push   %ebp
  802663:	89 e5                	mov    %esp,%ebp
  802665:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802668:	c7 44 24 04 15 33 80 	movl   $0x803315,0x4(%esp)
  80266f:	00 
  802670:	8b 45 0c             	mov    0xc(%ebp),%eax
  802673:	89 04 24             	mov    %eax,(%esp)
  802676:	e8 9c e3 ff ff       	call   800a17 <strcpy>
	return 0;
}
  80267b:	b8 00 00 00 00       	mov    $0x0,%eax
  802680:	c9                   	leave  
  802681:	c3                   	ret    

00802682 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802682:	55                   	push   %ebp
  802683:	89 e5                	mov    %esp,%ebp
  802685:	57                   	push   %edi
  802686:	56                   	push   %esi
  802687:	53                   	push   %ebx
  802688:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80268e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802693:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802699:	eb 30                	jmp    8026cb <devcons_write+0x49>
		m = n - tot;
  80269b:	8b 75 10             	mov    0x10(%ebp),%esi
  80269e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8026a0:	83 fe 7f             	cmp    $0x7f,%esi
  8026a3:	76 05                	jbe    8026aa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8026a5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8026aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8026ae:	03 45 0c             	add    0xc(%ebp),%eax
  8026b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026b5:	89 3c 24             	mov    %edi,(%esp)
  8026b8:	e8 d3 e4 ff ff       	call   800b90 <memmove>
		sys_cputs(buf, m);
  8026bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c1:	89 3c 24             	mov    %edi,(%esp)
  8026c4:	e8 73 e6 ff ff       	call   800d3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8026c9:	01 f3                	add    %esi,%ebx
  8026cb:	89 d8                	mov    %ebx,%eax
  8026cd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8026d0:	72 c9                	jb     80269b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8026d2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    

008026dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8026dd:	55                   	push   %ebp
  8026de:	89 e5                	mov    %esp,%ebp
  8026e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8026e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8026e7:	75 07                	jne    8026f0 <devcons_read+0x13>
  8026e9:	eb 25                	jmp    802710 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8026eb:	e8 fa e6 ff ff       	call   800dea <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8026f0:	e8 65 e6 ff ff       	call   800d5a <sys_cgetc>
  8026f5:	85 c0                	test   %eax,%eax
  8026f7:	74 f2                	je     8026eb <devcons_read+0xe>
  8026f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8026fb:	85 c0                	test   %eax,%eax
  8026fd:	78 1d                	js     80271c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8026ff:	83 f8 04             	cmp    $0x4,%eax
  802702:	74 13                	je     802717 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802704:	8b 45 0c             	mov    0xc(%ebp),%eax
  802707:	88 10                	mov    %dl,(%eax)
	return 1;
  802709:	b8 01 00 00 00       	mov    $0x1,%eax
  80270e:	eb 0c                	jmp    80271c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802710:	b8 00 00 00 00       	mov    $0x0,%eax
  802715:	eb 05                	jmp    80271c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802717:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80271c:	c9                   	leave  
  80271d:	c3                   	ret    

0080271e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80271e:	55                   	push   %ebp
  80271f:	89 e5                	mov    %esp,%ebp
  802721:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802724:	8b 45 08             	mov    0x8(%ebp),%eax
  802727:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80272a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802731:	00 
  802732:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802735:	89 04 24             	mov    %eax,(%esp)
  802738:	e8 ff e5 ff ff       	call   800d3c <sys_cputs>
}
  80273d:	c9                   	leave  
  80273e:	c3                   	ret    

0080273f <getchar>:

int
getchar(void)
{
  80273f:	55                   	push   %ebp
  802740:	89 e5                	mov    %esp,%ebp
  802742:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802745:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80274c:	00 
  80274d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802750:	89 44 24 04          	mov    %eax,0x4(%esp)
  802754:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80275b:	e8 ae f0 ff ff       	call   80180e <read>
	if (r < 0)
  802760:	85 c0                	test   %eax,%eax
  802762:	78 0f                	js     802773 <getchar+0x34>
		return r;
	if (r < 1)
  802764:	85 c0                	test   %eax,%eax
  802766:	7e 06                	jle    80276e <getchar+0x2f>
		return -E_EOF;
	return c;
  802768:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80276c:	eb 05                	jmp    802773 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80276e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802773:	c9                   	leave  
  802774:	c3                   	ret    

00802775 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802775:	55                   	push   %ebp
  802776:	89 e5                	mov    %esp,%ebp
  802778:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80277b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80277e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802782:	8b 45 08             	mov    0x8(%ebp),%eax
  802785:	89 04 24             	mov    %eax,(%esp)
  802788:	e8 e5 ed ff ff       	call   801572 <fd_lookup>
  80278d:	85 c0                	test   %eax,%eax
  80278f:	78 11                	js     8027a2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802794:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80279a:	39 10                	cmp    %edx,(%eax)
  80279c:	0f 94 c0             	sete   %al
  80279f:	0f b6 c0             	movzbl %al,%eax
}
  8027a2:	c9                   	leave  
  8027a3:	c3                   	ret    

008027a4 <opencons>:

int
opencons(void)
{
  8027a4:	55                   	push   %ebp
  8027a5:	89 e5                	mov    %esp,%ebp
  8027a7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8027aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ad:	89 04 24             	mov    %eax,(%esp)
  8027b0:	e8 6a ed ff ff       	call   80151f <fd_alloc>
  8027b5:	85 c0                	test   %eax,%eax
  8027b7:	78 3c                	js     8027f5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8027b9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8027c0:	00 
  8027c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027cf:	e8 35 e6 ff ff       	call   800e09 <sys_page_alloc>
  8027d4:	85 c0                	test   %eax,%eax
  8027d6:	78 1d                	js     8027f5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8027d8:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8027de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027e1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8027e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027e6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8027ed:	89 04 24             	mov    %eax,(%esp)
  8027f0:	e8 ff ec ff ff       	call   8014f4 <fd2num>
}
  8027f5:	c9                   	leave  
  8027f6:	c3                   	ret    
	...

008027f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8027f8:	55                   	push   %ebp
  8027f9:	89 e5                	mov    %esp,%ebp
  8027fb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8027fe:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802805:	75 58                	jne    80285f <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  802807:	a1 08 50 80 00       	mov    0x805008,%eax
  80280c:	8b 40 48             	mov    0x48(%eax),%eax
  80280f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802816:	00 
  802817:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80281e:	ee 
  80281f:	89 04 24             	mov    %eax,(%esp)
  802822:	e8 e2 e5 ff ff       	call   800e09 <sys_page_alloc>
  802827:	85 c0                	test   %eax,%eax
  802829:	74 1c                	je     802847 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  80282b:	c7 44 24 08 21 33 80 	movl   $0x803321,0x8(%esp)
  802832:	00 
  802833:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80283a:	00 
  80283b:	c7 04 24 36 33 80 00 	movl   $0x803336,(%esp)
  802842:	e8 2d db ff ff       	call   800374 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802847:	a1 08 50 80 00       	mov    0x805008,%eax
  80284c:	8b 40 48             	mov    0x48(%eax),%eax
  80284f:	c7 44 24 04 6c 28 80 	movl   $0x80286c,0x4(%esp)
  802856:	00 
  802857:	89 04 24             	mov    %eax,(%esp)
  80285a:	e8 4a e7 ff ff       	call   800fa9 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80285f:	8b 45 08             	mov    0x8(%ebp),%eax
  802862:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802867:	c9                   	leave  
  802868:	c3                   	ret    
  802869:	00 00                	add    %al,(%eax)
	...

0080286c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80286c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80286d:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802872:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802874:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  802877:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  80287b:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  80287d:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802881:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802882:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802885:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  802887:	58                   	pop    %eax
	popl %eax
  802888:	58                   	pop    %eax

	// Pop all registers back
	popal
  802889:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  80288a:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  80288d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  80288e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  80288f:	c3                   	ret    

00802890 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802890:	55                   	push   %ebp
  802891:	89 e5                	mov    %esp,%ebp
  802893:	56                   	push   %esi
  802894:	53                   	push   %ebx
  802895:	83 ec 10             	sub    $0x10,%esp
  802898:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80289b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80289e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8028a1:	85 c0                	test   %eax,%eax
  8028a3:	75 05                	jne    8028aa <ipc_recv+0x1a>
  8028a5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8028aa:	89 04 24             	mov    %eax,(%esp)
  8028ad:	e8 6d e7 ff ff       	call   80101f <sys_ipc_recv>
	if (from_env_store != NULL)
  8028b2:	85 db                	test   %ebx,%ebx
  8028b4:	74 0b                	je     8028c1 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  8028b6:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8028bc:	8b 52 74             	mov    0x74(%edx),%edx
  8028bf:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8028c1:	85 f6                	test   %esi,%esi
  8028c3:	74 0b                	je     8028d0 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8028c5:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8028cb:	8b 52 78             	mov    0x78(%edx),%edx
  8028ce:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8028d0:	85 c0                	test   %eax,%eax
  8028d2:	79 16                	jns    8028ea <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8028d4:	85 db                	test   %ebx,%ebx
  8028d6:	74 06                	je     8028de <ipc_recv+0x4e>
			*from_env_store = 0;
  8028d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8028de:	85 f6                	test   %esi,%esi
  8028e0:	74 10                	je     8028f2 <ipc_recv+0x62>
			*perm_store = 0;
  8028e2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8028e8:	eb 08                	jmp    8028f2 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8028ea:	a1 08 50 80 00       	mov    0x805008,%eax
  8028ef:	8b 40 70             	mov    0x70(%eax),%eax
}
  8028f2:	83 c4 10             	add    $0x10,%esp
  8028f5:	5b                   	pop    %ebx
  8028f6:	5e                   	pop    %esi
  8028f7:	5d                   	pop    %ebp
  8028f8:	c3                   	ret    

008028f9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8028f9:	55                   	push   %ebp
  8028fa:	89 e5                	mov    %esp,%ebp
  8028fc:	57                   	push   %edi
  8028fd:	56                   	push   %esi
  8028fe:	53                   	push   %ebx
  8028ff:	83 ec 1c             	sub    $0x1c,%esp
  802902:	8b 75 08             	mov    0x8(%ebp),%esi
  802905:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802908:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80290b:	eb 2a                	jmp    802937 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  80290d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802910:	74 20                	je     802932 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802912:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802916:	c7 44 24 08 44 33 80 	movl   $0x803344,0x8(%esp)
  80291d:	00 
  80291e:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802925:	00 
  802926:	c7 04 24 6c 33 80 00 	movl   $0x80336c,(%esp)
  80292d:	e8 42 da ff ff       	call   800374 <_panic>
		sys_yield();
  802932:	e8 b3 e4 ff ff       	call   800dea <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802937:	85 db                	test   %ebx,%ebx
  802939:	75 07                	jne    802942 <ipc_send+0x49>
  80293b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802940:	eb 02                	jmp    802944 <ipc_send+0x4b>
  802942:	89 d8                	mov    %ebx,%eax
  802944:	8b 55 14             	mov    0x14(%ebp),%edx
  802947:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80294b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80294f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802953:	89 34 24             	mov    %esi,(%esp)
  802956:	e8 a1 e6 ff ff       	call   800ffc <sys_ipc_try_send>
  80295b:	85 c0                	test   %eax,%eax
  80295d:	78 ae                	js     80290d <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80295f:	83 c4 1c             	add    $0x1c,%esp
  802962:	5b                   	pop    %ebx
  802963:	5e                   	pop    %esi
  802964:	5f                   	pop    %edi
  802965:	5d                   	pop    %ebp
  802966:	c3                   	ret    

00802967 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802967:	55                   	push   %ebp
  802968:	89 e5                	mov    %esp,%ebp
  80296a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80296d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802972:	89 c2                	mov    %eax,%edx
  802974:	c1 e2 07             	shl    $0x7,%edx
  802977:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80297d:	8b 52 50             	mov    0x50(%edx),%edx
  802980:	39 ca                	cmp    %ecx,%edx
  802982:	75 0d                	jne    802991 <ipc_find_env+0x2a>
			return envs[i].env_id;
  802984:	c1 e0 07             	shl    $0x7,%eax
  802987:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80298c:	8b 40 40             	mov    0x40(%eax),%eax
  80298f:	eb 0c                	jmp    80299d <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802991:	40                   	inc    %eax
  802992:	3d 00 04 00 00       	cmp    $0x400,%eax
  802997:	75 d9                	jne    802972 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802999:	66 b8 00 00          	mov    $0x0,%ax
}
  80299d:	5d                   	pop    %ebp
  80299e:	c3                   	ret    
	...

008029a0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029a0:	55                   	push   %ebp
  8029a1:	89 e5                	mov    %esp,%ebp
  8029a3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029a6:	89 c2                	mov    %eax,%edx
  8029a8:	c1 ea 16             	shr    $0x16,%edx
  8029ab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8029b2:	f6 c2 01             	test   $0x1,%dl
  8029b5:	74 1e                	je     8029d5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029b7:	c1 e8 0c             	shr    $0xc,%eax
  8029ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029c1:	a8 01                	test   $0x1,%al
  8029c3:	74 17                	je     8029dc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029c5:	c1 e8 0c             	shr    $0xc,%eax
  8029c8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8029cf:	ef 
  8029d0:	0f b7 c0             	movzwl %ax,%eax
  8029d3:	eb 0c                	jmp    8029e1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8029d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8029da:	eb 05                	jmp    8029e1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8029dc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8029e1:	5d                   	pop    %ebp
  8029e2:	c3                   	ret    
	...

008029e4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8029e4:	55                   	push   %ebp
  8029e5:	57                   	push   %edi
  8029e6:	56                   	push   %esi
  8029e7:	83 ec 10             	sub    $0x10,%esp
  8029ea:	8b 74 24 20          	mov    0x20(%esp),%esi
  8029ee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8029f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029f6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8029fa:	89 cd                	mov    %ecx,%ebp
  8029fc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a00:	85 c0                	test   %eax,%eax
  802a02:	75 2c                	jne    802a30 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802a04:	39 f9                	cmp    %edi,%ecx
  802a06:	77 68                	ja     802a70 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802a08:	85 c9                	test   %ecx,%ecx
  802a0a:	75 0b                	jne    802a17 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802a0c:	b8 01 00 00 00       	mov    $0x1,%eax
  802a11:	31 d2                	xor    %edx,%edx
  802a13:	f7 f1                	div    %ecx
  802a15:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802a17:	31 d2                	xor    %edx,%edx
  802a19:	89 f8                	mov    %edi,%eax
  802a1b:	f7 f1                	div    %ecx
  802a1d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a1f:	89 f0                	mov    %esi,%eax
  802a21:	f7 f1                	div    %ecx
  802a23:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a25:	89 f0                	mov    %esi,%eax
  802a27:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a29:	83 c4 10             	add    $0x10,%esp
  802a2c:	5e                   	pop    %esi
  802a2d:	5f                   	pop    %edi
  802a2e:	5d                   	pop    %ebp
  802a2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a30:	39 f8                	cmp    %edi,%eax
  802a32:	77 2c                	ja     802a60 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a34:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802a37:	83 f6 1f             	xor    $0x1f,%esi
  802a3a:	75 4c                	jne    802a88 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a3c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a3e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a43:	72 0a                	jb     802a4f <__udivdi3+0x6b>
  802a45:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802a49:	0f 87 ad 00 00 00    	ja     802afc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802a4f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a54:	89 f0                	mov    %esi,%eax
  802a56:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a58:	83 c4 10             	add    $0x10,%esp
  802a5b:	5e                   	pop    %esi
  802a5c:	5f                   	pop    %edi
  802a5d:	5d                   	pop    %ebp
  802a5e:	c3                   	ret    
  802a5f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a60:	31 ff                	xor    %edi,%edi
  802a62:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a64:	89 f0                	mov    %esi,%eax
  802a66:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a68:	83 c4 10             	add    $0x10,%esp
  802a6b:	5e                   	pop    %esi
  802a6c:	5f                   	pop    %edi
  802a6d:	5d                   	pop    %ebp
  802a6e:	c3                   	ret    
  802a6f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a70:	89 fa                	mov    %edi,%edx
  802a72:	89 f0                	mov    %esi,%eax
  802a74:	f7 f1                	div    %ecx
  802a76:	89 c6                	mov    %eax,%esi
  802a78:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a7a:	89 f0                	mov    %esi,%eax
  802a7c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a7e:	83 c4 10             	add    $0x10,%esp
  802a81:	5e                   	pop    %esi
  802a82:	5f                   	pop    %edi
  802a83:	5d                   	pop    %ebp
  802a84:	c3                   	ret    
  802a85:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a88:	89 f1                	mov    %esi,%ecx
  802a8a:	d3 e0                	shl    %cl,%eax
  802a8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a90:	b8 20 00 00 00       	mov    $0x20,%eax
  802a95:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a97:	89 ea                	mov    %ebp,%edx
  802a99:	88 c1                	mov    %al,%cl
  802a9b:	d3 ea                	shr    %cl,%edx
  802a9d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802aa1:	09 ca                	or     %ecx,%edx
  802aa3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802aa7:	89 f1                	mov    %esi,%ecx
  802aa9:	d3 e5                	shl    %cl,%ebp
  802aab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802aaf:	89 fd                	mov    %edi,%ebp
  802ab1:	88 c1                	mov    %al,%cl
  802ab3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802ab5:	89 fa                	mov    %edi,%edx
  802ab7:	89 f1                	mov    %esi,%ecx
  802ab9:	d3 e2                	shl    %cl,%edx
  802abb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802abf:	88 c1                	mov    %al,%cl
  802ac1:	d3 ef                	shr    %cl,%edi
  802ac3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802ac5:	89 f8                	mov    %edi,%eax
  802ac7:	89 ea                	mov    %ebp,%edx
  802ac9:	f7 74 24 08          	divl   0x8(%esp)
  802acd:	89 d1                	mov    %edx,%ecx
  802acf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802ad1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ad5:	39 d1                	cmp    %edx,%ecx
  802ad7:	72 17                	jb     802af0 <__udivdi3+0x10c>
  802ad9:	74 09                	je     802ae4 <__udivdi3+0x100>
  802adb:	89 fe                	mov    %edi,%esi
  802add:	31 ff                	xor    %edi,%edi
  802adf:	e9 41 ff ff ff       	jmp    802a25 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802ae4:	8b 54 24 04          	mov    0x4(%esp),%edx
  802ae8:	89 f1                	mov    %esi,%ecx
  802aea:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802aec:	39 c2                	cmp    %eax,%edx
  802aee:	73 eb                	jae    802adb <__udivdi3+0xf7>
		{
		  q0--;
  802af0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802af3:	31 ff                	xor    %edi,%edi
  802af5:	e9 2b ff ff ff       	jmp    802a25 <__udivdi3+0x41>
  802afa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802afc:	31 f6                	xor    %esi,%esi
  802afe:	e9 22 ff ff ff       	jmp    802a25 <__udivdi3+0x41>
	...

00802b04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802b04:	55                   	push   %ebp
  802b05:	57                   	push   %edi
  802b06:	56                   	push   %esi
  802b07:	83 ec 20             	sub    $0x20,%esp
  802b0a:	8b 44 24 30          	mov    0x30(%esp),%eax
  802b0e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802b12:	89 44 24 14          	mov    %eax,0x14(%esp)
  802b16:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802b1a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b1e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802b22:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802b24:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802b26:	85 ed                	test   %ebp,%ebp
  802b28:	75 16                	jne    802b40 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802b2a:	39 f1                	cmp    %esi,%ecx
  802b2c:	0f 86 a6 00 00 00    	jbe    802bd8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b32:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802b34:	89 d0                	mov    %edx,%eax
  802b36:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b38:	83 c4 20             	add    $0x20,%esp
  802b3b:	5e                   	pop    %esi
  802b3c:	5f                   	pop    %edi
  802b3d:	5d                   	pop    %ebp
  802b3e:	c3                   	ret    
  802b3f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802b40:	39 f5                	cmp    %esi,%ebp
  802b42:	0f 87 ac 00 00 00    	ja     802bf4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802b48:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802b4b:	83 f0 1f             	xor    $0x1f,%eax
  802b4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b52:	0f 84 a8 00 00 00    	je     802c00 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802b58:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b5c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802b5e:	bf 20 00 00 00       	mov    $0x20,%edi
  802b63:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802b67:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b6b:	89 f9                	mov    %edi,%ecx
  802b6d:	d3 e8                	shr    %cl,%eax
  802b6f:	09 e8                	or     %ebp,%eax
  802b71:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802b75:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b79:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b7d:	d3 e0                	shl    %cl,%eax
  802b7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b83:	89 f2                	mov    %esi,%edx
  802b85:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b87:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b8b:	d3 e0                	shl    %cl,%eax
  802b8d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b91:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b95:	89 f9                	mov    %edi,%ecx
  802b97:	d3 e8                	shr    %cl,%eax
  802b99:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b9b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b9d:	89 f2                	mov    %esi,%edx
  802b9f:	f7 74 24 18          	divl   0x18(%esp)
  802ba3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ba5:	f7 64 24 0c          	mull   0xc(%esp)
  802ba9:	89 c5                	mov    %eax,%ebp
  802bab:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802bad:	39 d6                	cmp    %edx,%esi
  802baf:	72 67                	jb     802c18 <__umoddi3+0x114>
  802bb1:	74 75                	je     802c28 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802bb3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802bb7:	29 e8                	sub    %ebp,%eax
  802bb9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802bbb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802bbf:	d3 e8                	shr    %cl,%eax
  802bc1:	89 f2                	mov    %esi,%edx
  802bc3:	89 f9                	mov    %edi,%ecx
  802bc5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802bc7:	09 d0                	or     %edx,%eax
  802bc9:	89 f2                	mov    %esi,%edx
  802bcb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802bcf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bd1:	83 c4 20             	add    $0x20,%esp
  802bd4:	5e                   	pop    %esi
  802bd5:	5f                   	pop    %edi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802bd8:	85 c9                	test   %ecx,%ecx
  802bda:	75 0b                	jne    802be7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802bdc:	b8 01 00 00 00       	mov    $0x1,%eax
  802be1:	31 d2                	xor    %edx,%edx
  802be3:	f7 f1                	div    %ecx
  802be5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802be7:	89 f0                	mov    %esi,%eax
  802be9:	31 d2                	xor    %edx,%edx
  802beb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802bed:	89 f8                	mov    %edi,%eax
  802bef:	e9 3e ff ff ff       	jmp    802b32 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802bf4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802bf6:	83 c4 20             	add    $0x20,%esp
  802bf9:	5e                   	pop    %esi
  802bfa:	5f                   	pop    %edi
  802bfb:	5d                   	pop    %ebp
  802bfc:	c3                   	ret    
  802bfd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802c00:	39 f5                	cmp    %esi,%ebp
  802c02:	72 04                	jb     802c08 <__umoddi3+0x104>
  802c04:	39 f9                	cmp    %edi,%ecx
  802c06:	77 06                	ja     802c0e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802c08:	89 f2                	mov    %esi,%edx
  802c0a:	29 cf                	sub    %ecx,%edi
  802c0c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802c0e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802c10:	83 c4 20             	add    $0x20,%esp
  802c13:	5e                   	pop    %esi
  802c14:	5f                   	pop    %edi
  802c15:	5d                   	pop    %ebp
  802c16:	c3                   	ret    
  802c17:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802c18:	89 d1                	mov    %edx,%ecx
  802c1a:	89 c5                	mov    %eax,%ebp
  802c1c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802c20:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802c24:	eb 8d                	jmp    802bb3 <__umoddi3+0xaf>
  802c26:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802c28:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802c2c:	72 ea                	jb     802c18 <__umoddi3+0x114>
  802c2e:	89 f1                	mov    %esi,%ecx
  802c30:	eb 81                	jmp    802bb3 <__umoddi3+0xaf>
