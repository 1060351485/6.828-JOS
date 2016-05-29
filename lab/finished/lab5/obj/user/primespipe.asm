
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 97 02 00 00       	call   8002c8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800040:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800043:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800046:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80004d:	00 
  80004e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800052:	89 1c 24             	mov    %ebx,(%esp)
  800055:	e8 88 17 00 00       	call   8017e2 <readn>
  80005a:	83 f8 04             	cmp    $0x4,%eax
  80005d:	74 30                	je     80008f <primeproc+0x5b>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80005f:	85 c0                	test   %eax,%eax
  800061:	0f 9e c2             	setle  %dl
  800064:	0f b6 d2             	movzbl %dl,%edx
  800067:	f7 da                	neg    %edx
  800069:	21 c2                	and    %eax,%edx
  80006b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80006f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800073:	c7 44 24 08 40 26 80 	movl   $0x802640,0x8(%esp)
  80007a:	00 
  80007b:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800082:	00 
  800083:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  80008a:	e8 a1 02 00 00       	call   800330 <_panic>

	cprintf("%d\n", p);
  80008f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	c7 04 24 81 26 80 00 	movl   $0x802681,(%esp)
  80009d:	e8 86 03 00 00       	call   800428 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a2:	89 3c 24             	mov    %edi,(%esp)
  8000a5:	e8 f3 1d 00 00       	call   801e9d <pipe>
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	79 20                	jns    8000d1 <primeproc+0x9d>
		panic("pipe: %e", i);
  8000b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b5:	c7 44 24 08 85 26 80 	movl   $0x802685,0x8(%esp)
  8000bc:	00 
  8000bd:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  8000cc:	e8 5f 02 00 00       	call   800330 <_panic>
	if ((id = fork()) < 0)
  8000d1:	e8 69 10 00 00       	call   80113f <fork>
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	79 20                	jns    8000fa <primeproc+0xc6>
		panic("fork: %e", id);
  8000da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000de:	c7 44 24 08 8e 26 80 	movl   $0x80268e,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  8000f5:	e8 36 02 00 00       	call   800330 <_panic>
	if (id == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1b                	jne    800119 <primeproc+0xe5>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 e8 14 00 00       	call   8015ee <close>
		close(pfd[1]);
  800106:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 dd 14 00 00       	call   8015ee <close>
		fd = pfd[0];
  800111:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800114:	e9 2d ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800119:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 ca 14 00 00       	call   8015ee <close>
	wfd = pfd[1];
  800124:	8b 7d dc             	mov    -0x24(%ebp),%edi

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  800127:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80012a:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800131:	00 
  800132:	89 74 24 04          	mov    %esi,0x4(%esp)
  800136:	89 1c 24             	mov    %ebx,(%esp)
  800139:	e8 a4 16 00 00       	call   8017e2 <readn>
  80013e:	83 f8 04             	cmp    $0x4,%eax
  800141:	74 3b                	je     80017e <primeproc+0x14a>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800143:	85 c0                	test   %eax,%eax
  800145:	0f 9e c2             	setle  %dl
  800148:	0f b6 d2             	movzbl %dl,%edx
  80014b:	f7 da                	neg    %edx
  80014d:	21 c2                	and    %eax,%edx
  80014f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800153:	89 44 24 14          	mov    %eax,0x14(%esp)
  800157:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80015b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 97 26 80 	movl   $0x802697,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  800179:	e8 b2 01 00 00       	call   800330 <_panic>
		if (i%p)
  80017e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800181:	99                   	cltd   
  800182:	f7 7d e0             	idivl  -0x20(%ebp)
  800185:	85 d2                	test   %edx,%edx
  800187:	74 a1                	je     80012a <primeproc+0xf6>
			if ((r=write(wfd, &i, 4)) != 4)
  800189:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800190:	00 
  800191:	89 74 24 04          	mov    %esi,0x4(%esp)
  800195:	89 3c 24             	mov    %edi,(%esp)
  800198:	e8 90 16 00 00       	call   80182d <write>
  80019d:	83 f8 04             	cmp    $0x4,%eax
  8001a0:	74 88                	je     80012a <primeproc+0xf6>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	0f 9e c2             	setle  %dl
  8001a7:	0f b6 d2             	movzbl %dl,%edx
  8001aa:	f7 da                	neg    %edx
  8001ac:	21 c2                	and    %eax,%edx
  8001ae:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001bd:	c7 44 24 08 b3 26 80 	movl   $0x8026b3,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  8001d4:	e8 57 01 00 00       	call   800330 <_panic>

008001d9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 34             	sub    $0x34,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  8001e0:	c7 05 00 30 80 00 cd 	movl   $0x8026cd,0x803000
  8001e7:	26 80 00 

	if ((i=pipe(p)) < 0)
  8001ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 a8 1c 00 00       	call   801e9d <pipe>
  8001f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	79 20                	jns    80021c <umain+0x43>
		panic("pipe: %e", i);
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	c7 44 24 08 85 26 80 	movl   $0x802685,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  800217:	e8 14 01 00 00       	call   800330 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021c:	e8 1e 0f 00 00       	call   80113f <fork>
  800221:	85 c0                	test   %eax,%eax
  800223:	79 20                	jns    800245 <umain+0x6c>
		panic("fork: %e", id);
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	c7 44 24 08 8e 26 80 	movl   $0x80268e,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  800240:	e8 eb 00 00 00       	call   800330 <_panic>

	if (id == 0) {
  800245:	85 c0                	test   %eax,%eax
  800247:	75 16                	jne    80025f <umain+0x86>
		close(p[1]);
  800249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 9a 13 00 00       	call   8015ee <close>
		primeproc(p[0]);
  800254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 d5 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 84 13 00 00       	call   8015ee <close>

	// feed all the integers through
	for (i=2;; i++)
  80026a:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800271:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  800274:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80027b:	00 
  80027c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800280:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 a2 15 00 00       	call   80182d <write>
  80028b:	83 f8 04             	cmp    $0x4,%eax
  80028e:	74 30                	je     8002c0 <umain+0xe7>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800290:	85 c0                	test   %eax,%eax
  800292:	0f 9e c2             	setle  %dl
  800295:	0f b6 d2             	movzbl %dl,%edx
  800298:	f7 da                	neg    %edx
  80029a:	21 c2                	and    %eax,%edx
  80029c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002a4:	c7 44 24 08 d8 26 80 	movl   $0x8026d8,0x8(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002b3:	00 
  8002b4:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  8002bb:	e8 70 00 00 00       	call   800330 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  8002c0:	ff 45 f4             	incl   -0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  8002c3:	eb af                	jmp    800274 <umain+0x9b>
  8002c5:	00 00                	add    %al,(%eax)
	...

008002c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	56                   	push   %esi
  8002cc:	53                   	push   %ebx
  8002cd:	83 ec 10             	sub    $0x10,%esp
  8002d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d6:	e8 ac 0a 00 00       	call   800d87 <sys_getenvid>
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002e7:	c1 e0 07             	shl    $0x7,%eax
  8002ea:	29 d0                	sub    %edx,%eax
  8002ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f6:	85 f6                	test   %esi,%esi
  8002f8:	7e 07                	jle    800301 <libmain+0x39>
		binaryname = argv[0];
  8002fa:	8b 03                	mov    (%ebx),%eax
  8002fc:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800301:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800305:	89 34 24             	mov    %esi,(%esp)
  800308:	e8 cc fe ff ff       	call   8001d9 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    
  800319:	00 00                	add    %al,(%eax)
	...

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800322:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800329:	e8 07 0a 00 00       	call   800d35 <sys_env_destroy>
}
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800338:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800341:	e8 41 0a 00 00       	call   800d87 <sys_getenvid>
  800346:	8b 55 0c             	mov    0xc(%ebp),%edx
  800349:	89 54 24 10          	mov    %edx,0x10(%esp)
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800354:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035c:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  800363:	e8 c0 00 00 00       	call   800428 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800368:	89 74 24 04          	mov    %esi,0x4(%esp)
  80036c:	8b 45 10             	mov    0x10(%ebp),%eax
  80036f:	89 04 24             	mov    %eax,(%esp)
  800372:	e8 50 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  800377:	c7 04 24 83 26 80 00 	movl   $0x802683,(%esp)
  80037e:	e8 a5 00 00 00       	call   800428 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800383:	cc                   	int3   
  800384:	eb fd                	jmp    800383 <_panic+0x53>
	...

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	83 ec 14             	sub    $0x14,%esp
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800392:	8b 03                	mov    (%ebx),%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039b:	40                   	inc    %eax
  80039c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	75 19                	jne    8003be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ac:	00 
  8003ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	e8 40 09 00 00       	call   800cf8 <sys_cputs>
		b->idx = 0;
  8003b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003be:	ff 43 04             	incl   0x4(%ebx)
}
  8003c1:	83 c4 14             	add    $0x14,%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d7:	00 00 00 
	b.cnt = 0;
  8003da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003fc:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800403:	e8 82 01 00 00       	call   80058a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800408:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80040e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800412:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 d8 08 00 00       	call   800cf8 <sys_cputs>

	return b.cnt;
}
  800420:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800431:	89 44 24 04          	mov    %eax,0x4(%esp)
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	89 04 24             	mov    %eax,(%esp)
  80043b:	e8 87 ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800440:	c9                   	leave  
  800441:	c3                   	ret    
	...

00800444 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	57                   	push   %edi
  800448:	56                   	push   %esi
  800449:	53                   	push   %ebx
  80044a:	83 ec 3c             	sub    $0x3c,%esp
  80044d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800450:	89 d7                	mov    %edx,%edi
  800452:	8b 45 08             	mov    0x8(%ebp),%eax
  800455:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800458:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800461:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800464:	85 c0                	test   %eax,%eax
  800466:	75 08                	jne    800470 <printnum+0x2c>
  800468:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046e:	77 57                	ja     8004c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800470:	89 74 24 10          	mov    %esi,0x10(%esp)
  800474:	4b                   	dec    %ebx
  800475:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800479:	8b 45 10             	mov    0x10(%ebp),%eax
  80047c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800480:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800484:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800488:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048f:	00 
  800490:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	e8 36 1f 00 00       	call   8023d8 <__udivdi3>
  8004a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b1:	89 fa                	mov    %edi,%edx
  8004b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b6:	e8 89 ff ff ff       	call   800444 <printnum>
  8004bb:	eb 0f                	jmp    8004cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c1:	89 34 24             	mov    %esi,(%esp)
  8004c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c7:	4b                   	dec    %ebx
  8004c8:	85 db                	test   %ebx,%ebx
  8004ca:	7f f1                	jg     8004bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004e2:	00 
  8004e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f0:	e8 03 20 00 00       	call   8024f8 <__umoddi3>
  8004f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f9:	0f be 80 1f 27 80 00 	movsbl 0x80271f(%eax),%eax
  800500:	89 04 24             	mov    %eax,(%esp)
  800503:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800506:	83 c4 3c             	add    $0x3c,%esp
  800509:	5b                   	pop    %ebx
  80050a:	5e                   	pop    %esi
  80050b:	5f                   	pop    %edi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800511:	83 fa 01             	cmp    $0x1,%edx
  800514:	7e 0e                	jle    800524 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800516:	8b 10                	mov    (%eax),%edx
  800518:	8d 4a 08             	lea    0x8(%edx),%ecx
  80051b:	89 08                	mov    %ecx,(%eax)
  80051d:	8b 02                	mov    (%edx),%eax
  80051f:	8b 52 04             	mov    0x4(%edx),%edx
  800522:	eb 22                	jmp    800546 <getuint+0x38>
	else if (lflag)
  800524:	85 d2                	test   %edx,%edx
  800526:	74 10                	je     800538 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052d:	89 08                	mov    %ecx,(%eax)
  80052f:	8b 02                	mov    (%edx),%eax
  800531:	ba 00 00 00 00       	mov    $0x0,%edx
  800536:	eb 0e                	jmp    800546 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800538:	8b 10                	mov    (%eax),%edx
  80053a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80053d:	89 08                	mov    %ecx,(%eax)
  80053f:	8b 02                	mov    (%edx),%eax
  800541:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800546:	5d                   	pop    %ebp
  800547:	c3                   	ret    

00800548 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800551:	8b 10                	mov    (%eax),%edx
  800553:	3b 50 04             	cmp    0x4(%eax),%edx
  800556:	73 08                	jae    800560 <sprintputch+0x18>
		*b->buf++ = ch;
  800558:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055b:	88 0a                	mov    %cl,(%edx)
  80055d:	42                   	inc    %edx
  80055e:	89 10                	mov    %edx,(%eax)
}
  800560:	5d                   	pop    %ebp
  800561:	c3                   	ret    

00800562 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80056b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056f:	8b 45 10             	mov    0x10(%ebp),%eax
  800572:	89 44 24 08          	mov    %eax,0x8(%esp)
  800576:	8b 45 0c             	mov    0xc(%ebp),%eax
  800579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 02 00 00 00       	call   80058a <vprintfmt>
	va_end(ap);
}
  800588:	c9                   	leave  
  800589:	c3                   	ret    

0080058a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	57                   	push   %edi
  80058e:	56                   	push   %esi
  80058f:	53                   	push   %ebx
  800590:	83 ec 4c             	sub    $0x4c,%esp
  800593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800596:	8b 75 10             	mov    0x10(%ebp),%esi
  800599:	eb 12                	jmp    8005ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80059b:	85 c0                	test   %eax,%eax
  80059d:	0f 84 6b 03 00 00    	je     80090e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8005a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005ad:	0f b6 06             	movzbl (%esi),%eax
  8005b0:	46                   	inc    %esi
  8005b1:	83 f8 25             	cmp    $0x25,%eax
  8005b4:	75 e5                	jne    80059b <vprintfmt+0x11>
  8005b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	eb 26                	jmp    8005fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005db:	eb 1d                	jmp    8005fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005e4:	eb 14                	jmp    8005fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f0:	eb 08                	jmp    8005fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	0f b6 06             	movzbl (%esi),%eax
  8005fd:	8d 56 01             	lea    0x1(%esi),%edx
  800600:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800603:	8a 16                	mov    (%esi),%dl
  800605:	83 ea 23             	sub    $0x23,%edx
  800608:	80 fa 55             	cmp    $0x55,%dl
  80060b:	0f 87 e1 02 00 00    	ja     8008f2 <vprintfmt+0x368>
  800611:	0f b6 d2             	movzbl %dl,%edx
  800614:	ff 24 95 60 28 80 00 	jmp    *0x802860(,%edx,4)
  80061b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800623:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800626:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80062a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80062d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800630:	83 fa 09             	cmp    $0x9,%edx
  800633:	77 2a                	ja     80065f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800635:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800636:	eb eb                	jmp    800623 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800646:	eb 17                	jmp    80065f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800648:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80064c:	78 98                	js     8005e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800651:	eb a7                	jmp    8005fa <vprintfmt+0x70>
  800653:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800656:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80065d:	eb 9b                	jmp    8005fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80065f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800663:	79 95                	jns    8005fa <vprintfmt+0x70>
  800665:	eb 8b                	jmp    8005f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800667:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80066b:	eb 8d                	jmp    8005fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800685:	e9 23 ff ff ff       	jmp    8005ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	79 02                	jns    80069b <vprintfmt+0x111>
  800699:	f7 d8                	neg    %eax
  80069b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80069d:	83 f8 0f             	cmp    $0xf,%eax
  8006a0:	7f 0b                	jg     8006ad <vprintfmt+0x123>
  8006a2:	8b 04 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%eax
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	75 23                	jne    8006d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b1:	c7 44 24 08 37 27 80 	movl   $0x802737,0x8(%esp)
  8006b8:	00 
  8006b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	e8 9a fe ff ff       	call   800562 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006cb:	e9 dd fe ff ff       	jmp    8005ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d4:	c7 44 24 08 e1 2b 80 	movl   $0x802be1,0x8(%esp)
  8006db:	00 
  8006dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	89 14 24             	mov    %edx,(%esp)
  8006e6:	e8 77 fe ff ff       	call   800562 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ee:	e9 ba fe ff ff       	jmp    8005ad <vprintfmt+0x23>
  8006f3:	89 f9                	mov    %edi,%ecx
  8006f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 50 04             	lea    0x4(%eax),%edx
  800701:	89 55 14             	mov    %edx,0x14(%ebp)
  800704:	8b 30                	mov    (%eax),%esi
  800706:	85 f6                	test   %esi,%esi
  800708:	75 05                	jne    80070f <vprintfmt+0x185>
				p = "(null)";
  80070a:	be 30 27 80 00       	mov    $0x802730,%esi
			if (width > 0 && padc != '-')
  80070f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800713:	0f 8e 84 00 00 00    	jle    80079d <vprintfmt+0x213>
  800719:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80071d:	74 7e                	je     80079d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800723:	89 34 24             	mov    %esi,(%esp)
  800726:	e8 8b 02 00 00       	call   8009b6 <strnlen>
  80072b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072e:	29 c2                	sub    %eax,%edx
  800730:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800733:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800737:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80073a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80073d:	89 de                	mov    %ebx,%esi
  80073f:	89 d3                	mov    %edx,%ebx
  800741:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800743:	eb 0b                	jmp    800750 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800745:	89 74 24 04          	mov    %esi,0x4(%esp)
  800749:	89 3c 24             	mov    %edi,(%esp)
  80074c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074f:	4b                   	dec    %ebx
  800750:	85 db                	test   %ebx,%ebx
  800752:	7f f1                	jg     800745 <vprintfmt+0x1bb>
  800754:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800757:	89 f3                	mov    %esi,%ebx
  800759:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80075c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075f:	85 c0                	test   %eax,%eax
  800761:	79 05                	jns    800768 <vprintfmt+0x1de>
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80076b:	29 c2                	sub    %eax,%edx
  80076d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800770:	eb 2b                	jmp    80079d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800772:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800776:	74 18                	je     800790 <vprintfmt+0x206>
  800778:	8d 50 e0             	lea    -0x20(%eax),%edx
  80077b:	83 fa 5e             	cmp    $0x5e,%edx
  80077e:	76 10                	jbe    800790 <vprintfmt+0x206>
					putch('?', putdat);
  800780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800784:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
  80078e:	eb 0a                	jmp    80079a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800790:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80079a:	ff 4d e4             	decl   -0x1c(%ebp)
  80079d:	0f be 06             	movsbl (%esi),%eax
  8007a0:	46                   	inc    %esi
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	74 21                	je     8007c6 <vprintfmt+0x23c>
  8007a5:	85 ff                	test   %edi,%edi
  8007a7:	78 c9                	js     800772 <vprintfmt+0x1e8>
  8007a9:	4f                   	dec    %edi
  8007aa:	79 c6                	jns    800772 <vprintfmt+0x1e8>
  8007ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007af:	89 de                	mov    %ebx,%esi
  8007b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007b4:	eb 18                	jmp    8007ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007c3:	4b                   	dec    %ebx
  8007c4:	eb 08                	jmp    8007ce <vprintfmt+0x244>
  8007c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c9:	89 de                	mov    %ebx,%esi
  8007cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ce:	85 db                	test   %ebx,%ebx
  8007d0:	7f e4                	jg     8007b6 <vprintfmt+0x22c>
  8007d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007da:	e9 ce fd ff ff       	jmp    8005ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007df:	83 f9 01             	cmp    $0x1,%ecx
  8007e2:	7e 10                	jle    8007f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 08             	lea    0x8(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ed:	8b 30                	mov    (%eax),%esi
  8007ef:	8b 78 04             	mov    0x4(%eax),%edi
  8007f2:	eb 26                	jmp    80081a <vprintfmt+0x290>
	else if (lflag)
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 12                	je     80080a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 30                	mov    (%eax),%esi
  800803:	89 f7                	mov    %esi,%edi
  800805:	c1 ff 1f             	sar    $0x1f,%edi
  800808:	eb 10                	jmp    80081a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8d 50 04             	lea    0x4(%eax),%edx
  800810:	89 55 14             	mov    %edx,0x14(%ebp)
  800813:	8b 30                	mov    (%eax),%esi
  800815:	89 f7                	mov    %esi,%edi
  800817:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081a:	85 ff                	test   %edi,%edi
  80081c:	78 0a                	js     800828 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 8c 00 00 00       	jmp    8008b4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800828:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80082c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800836:	f7 de                	neg    %esi
  800838:	83 d7 00             	adc    $0x0,%edi
  80083b:	f7 df                	neg    %edi
			}
			base = 10;
  80083d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800842:	eb 70                	jmp    8008b4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800844:	89 ca                	mov    %ecx,%edx
  800846:	8d 45 14             	lea    0x14(%ebp),%eax
  800849:	e8 c0 fc ff ff       	call   80050e <getuint>
  80084e:	89 c6                	mov    %eax,%esi
  800850:	89 d7                	mov    %edx,%edi
			base = 10;
  800852:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800857:	eb 5b                	jmp    8008b4 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800859:	89 ca                	mov    %ecx,%edx
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
  80085e:	e8 ab fc ff ff       	call   80050e <getuint>
  800863:	89 c6                	mov    %eax,%esi
  800865:	89 d7                	mov    %edx,%edi
			base = 8;
  800867:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80086c:	eb 46                	jmp    8008b4 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  80086e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800872:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800879:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80087c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800880:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800887:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8d 50 04             	lea    0x4(%eax),%edx
  800890:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800893:	8b 30                	mov    (%eax),%esi
  800895:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80089a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089f:	eb 13                	jmp    8008b4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a1:	89 ca                	mov    %ecx,%edx
  8008a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a6:	e8 63 fc ff ff       	call   80050e <getuint>
  8008ab:	89 c6                	mov    %eax,%esi
  8008ad:	89 d7                	mov    %edx,%edi
			base = 16;
  8008af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008b8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c7:	89 34 24             	mov    %esi,(%esp)
  8008ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ce:	89 da                	mov    %ebx,%edx
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	e8 6c fb ff ff       	call   800444 <printnum>
			break;
  8008d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008db:	e9 cd fc ff ff       	jmp    8005ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	89 04 24             	mov    %eax,(%esp)
  8008e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ed:	e9 bb fc ff ff       	jmp    8005ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008fd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800900:	eb 01                	jmp    800903 <vprintfmt+0x379>
  800902:	4e                   	dec    %esi
  800903:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800907:	75 f9                	jne    800902 <vprintfmt+0x378>
  800909:	e9 9f fc ff ff       	jmp    8005ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80090e:	83 c4 4c             	add    $0x4c,%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 28             	sub    $0x28,%esp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800922:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800925:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800929:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800933:	85 c0                	test   %eax,%eax
  800935:	74 30                	je     800967 <vsnprintf+0x51>
  800937:	85 d2                	test   %edx,%edx
  800939:	7e 33                	jle    80096e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800942:	8b 45 10             	mov    0x10(%ebp),%eax
  800945:	89 44 24 08          	mov    %eax,0x8(%esp)
  800949:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	c7 04 24 48 05 80 00 	movl   $0x800548,(%esp)
  800957:	e8 2e fc ff ff       	call   80058a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80095c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800965:	eb 0c                	jmp    800973 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800967:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096c:	eb 05                	jmp    800973 <vsnprintf+0x5d>
  80096e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800982:	8b 45 10             	mov    0x10(%ebp),%eax
  800985:	89 44 24 08          	mov    %eax,0x8(%esp)
  800989:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 7b ff ff ff       	call   800916 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    
  80099d:	00 00                	add    %al,(%eax)
	...

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	eb 01                	jmp    8009ae <strlen+0xe>
		n++;
  8009ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b2:	75 f9                	jne    8009ad <strlen+0xd>
		n++;
	return n;
}
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c4:	eb 01                	jmp    8009c7 <strnlen+0x11>
		n++;
  8009c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c7:	39 d0                	cmp    %edx,%eax
  8009c9:	74 06                	je     8009d1 <strnlen+0x1b>
  8009cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009cf:	75 f5                	jne    8009c6 <strnlen+0x10>
		n++;
	return n;
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	53                   	push   %ebx
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009e8:	42                   	inc    %edx
  8009e9:	84 c9                	test   %cl,%cl
  8009eb:	75 f5                	jne    8009e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009fa:	89 1c 24             	mov    %ebx,(%esp)
  8009fd:	e8 9e ff ff ff       	call   8009a0 <strlen>
	strcpy(dst + len, src);
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a05:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a09:	01 d8                	add    %ebx,%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 c0 ff ff ff       	call   8009d3 <strcpy>
	return dst;
}
  800a13:	89 d8                	mov    %ebx,%eax
  800a15:	83 c4 08             	add    $0x8,%esp
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a26:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2e:	eb 0c                	jmp    800a3c <strncpy+0x21>
		*dst++ = *src;
  800a30:	8a 1a                	mov    (%edx),%bl
  800a32:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a35:	80 3a 01             	cmpb   $0x1,(%edx)
  800a38:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a3b:	41                   	inc    %ecx
  800a3c:	39 f1                	cmp    %esi,%ecx
  800a3e:	75 f0                	jne    800a30 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a52:	85 d2                	test   %edx,%edx
  800a54:	75 0a                	jne    800a60 <strlcpy+0x1c>
  800a56:	89 f0                	mov    %esi,%eax
  800a58:	eb 1a                	jmp    800a74 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5a:	88 18                	mov    %bl,(%eax)
  800a5c:	40                   	inc    %eax
  800a5d:	41                   	inc    %ecx
  800a5e:	eb 02                	jmp    800a62 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a60:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a62:	4a                   	dec    %edx
  800a63:	74 0a                	je     800a6f <strlcpy+0x2b>
  800a65:	8a 19                	mov    (%ecx),%bl
  800a67:	84 db                	test   %bl,%bl
  800a69:	75 ef                	jne    800a5a <strlcpy+0x16>
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	eb 02                	jmp    800a71 <strlcpy+0x2d>
  800a6f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a71:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a74:	29 f0                	sub    %esi,%eax
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a83:	eb 02                	jmp    800a87 <strcmp+0xd>
		p++, q++;
  800a85:	41                   	inc    %ecx
  800a86:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a87:	8a 01                	mov    (%ecx),%al
  800a89:	84 c0                	test   %al,%al
  800a8b:	74 04                	je     800a91 <strcmp+0x17>
  800a8d:	3a 02                	cmp    (%edx),%al
  800a8f:	74 f4                	je     800a85 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a91:	0f b6 c0             	movzbl %al,%eax
  800a94:	0f b6 12             	movzbl (%edx),%edx
  800a97:	29 d0                	sub    %edx,%eax
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800aa8:	eb 03                	jmp    800aad <strncmp+0x12>
		n--, p++, q++;
  800aaa:	4a                   	dec    %edx
  800aab:	40                   	inc    %eax
  800aac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aad:	85 d2                	test   %edx,%edx
  800aaf:	74 14                	je     800ac5 <strncmp+0x2a>
  800ab1:	8a 18                	mov    (%eax),%bl
  800ab3:	84 db                	test   %bl,%bl
  800ab5:	74 04                	je     800abb <strncmp+0x20>
  800ab7:	3a 19                	cmp    (%ecx),%bl
  800ab9:	74 ef                	je     800aaa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abb:	0f b6 00             	movzbl (%eax),%eax
  800abe:	0f b6 11             	movzbl (%ecx),%edx
  800ac1:	29 d0                	sub    %edx,%eax
  800ac3:	eb 05                	jmp    800aca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aca:	5b                   	pop    %ebx
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ad6:	eb 05                	jmp    800add <strchr+0x10>
		if (*s == c)
  800ad8:	38 ca                	cmp    %cl,%dl
  800ada:	74 0c                	je     800ae8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800adc:	40                   	inc    %eax
  800add:	8a 10                	mov    (%eax),%dl
  800adf:	84 d2                	test   %dl,%dl
  800ae1:	75 f5                	jne    800ad8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800af3:	eb 05                	jmp    800afa <strfind+0x10>
		if (*s == c)
  800af5:	38 ca                	cmp    %cl,%dl
  800af7:	74 07                	je     800b00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800af9:	40                   	inc    %eax
  800afa:	8a 10                	mov    (%eax),%dl
  800afc:	84 d2                	test   %dl,%dl
  800afe:	75 f5                	jne    800af5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 30                	je     800b45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1b:	75 25                	jne    800b42 <memset+0x40>
  800b1d:	f6 c1 03             	test   $0x3,%cl
  800b20:	75 20                	jne    800b42 <memset+0x40>
		c &= 0xFF;
  800b22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b25:	89 d3                	mov    %edx,%ebx
  800b27:	c1 e3 08             	shl    $0x8,%ebx
  800b2a:	89 d6                	mov    %edx,%esi
  800b2c:	c1 e6 18             	shl    $0x18,%esi
  800b2f:	89 d0                	mov    %edx,%eax
  800b31:	c1 e0 10             	shl    $0x10,%eax
  800b34:	09 f0                	or     %esi,%eax
  800b36:	09 d0                	or     %edx,%eax
  800b38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b3d:	fc                   	cld    
  800b3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800b40:	eb 03                	jmp    800b45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b42:	fc                   	cld    
  800b43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b45:	89 f8                	mov    %edi,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5a:	39 c6                	cmp    %eax,%esi
  800b5c:	73 34                	jae    800b92 <memmove+0x46>
  800b5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b61:	39 d0                	cmp    %edx,%eax
  800b63:	73 2d                	jae    800b92 <memmove+0x46>
		s += n;
		d += n;
  800b65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b68:	f6 c2 03             	test   $0x3,%dl
  800b6b:	75 1b                	jne    800b88 <memmove+0x3c>
  800b6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b73:	75 13                	jne    800b88 <memmove+0x3c>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 0e                	jne    800b88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b7a:	83 ef 04             	sub    $0x4,%edi
  800b7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b83:	fd                   	std    
  800b84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b86:	eb 07                	jmp    800b8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b88:	4f                   	dec    %edi
  800b89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8c:	fd                   	std    
  800b8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8f:	fc                   	cld    
  800b90:	eb 20                	jmp    800bb2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b98:	75 13                	jne    800bad <memmove+0x61>
  800b9a:	a8 03                	test   $0x3,%al
  800b9c:	75 0f                	jne    800bad <memmove+0x61>
  800b9e:	f6 c1 03             	test   $0x3,%cl
  800ba1:	75 0a                	jne    800bad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bab:	eb 05                	jmp    800bb2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bad:	89 c7                	mov    %eax,%edi
  800baf:	fc                   	cld    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	89 04 24             	mov    %eax,(%esp)
  800bd0:	e8 77 ff ff ff       	call   800b4c <memmove>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	eb 16                	jmp    800c03 <memcmp+0x2c>
		if (*s1 != *s2)
  800bed:	8a 04 17             	mov    (%edi,%edx,1),%al
  800bf0:	42                   	inc    %edx
  800bf1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800bf5:	38 c8                	cmp    %cl,%al
  800bf7:	74 0a                	je     800c03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800bf9:	0f b6 c0             	movzbl %al,%eax
  800bfc:	0f b6 c9             	movzbl %cl,%ecx
  800bff:	29 c8                	sub    %ecx,%eax
  800c01:	eb 09                	jmp    800c0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c03:	39 da                	cmp    %ebx,%edx
  800c05:	75 e6                	jne    800bed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c1a:	89 c2                	mov    %eax,%edx
  800c1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c1f:	eb 05                	jmp    800c26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c21:	38 08                	cmp    %cl,(%eax)
  800c23:	74 05                	je     800c2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c25:	40                   	inc    %eax
  800c26:	39 d0                	cmp    %edx,%eax
  800c28:	72 f7                	jb     800c21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c38:	eb 01                	jmp    800c3b <strtol+0xf>
		s++;
  800c3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3b:	8a 02                	mov    (%edx),%al
  800c3d:	3c 20                	cmp    $0x20,%al
  800c3f:	74 f9                	je     800c3a <strtol+0xe>
  800c41:	3c 09                	cmp    $0x9,%al
  800c43:	74 f5                	je     800c3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c45:	3c 2b                	cmp    $0x2b,%al
  800c47:	75 08                	jne    800c51 <strtol+0x25>
		s++;
  800c49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	eb 13                	jmp    800c64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c51:	3c 2d                	cmp    $0x2d,%al
  800c53:	75 0a                	jne    800c5f <strtol+0x33>
		s++, neg = 1;
  800c55:	8d 52 01             	lea    0x1(%edx),%edx
  800c58:	bf 01 00 00 00       	mov    $0x1,%edi
  800c5d:	eb 05                	jmp    800c64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c64:	85 db                	test   %ebx,%ebx
  800c66:	74 05                	je     800c6d <strtol+0x41>
  800c68:	83 fb 10             	cmp    $0x10,%ebx
  800c6b:	75 28                	jne    800c95 <strtol+0x69>
  800c6d:	8a 02                	mov    (%edx),%al
  800c6f:	3c 30                	cmp    $0x30,%al
  800c71:	75 10                	jne    800c83 <strtol+0x57>
  800c73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c77:	75 0a                	jne    800c83 <strtol+0x57>
		s += 2, base = 16;
  800c79:	83 c2 02             	add    $0x2,%edx
  800c7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c81:	eb 12                	jmp    800c95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c83:	85 db                	test   %ebx,%ebx
  800c85:	75 0e                	jne    800c95 <strtol+0x69>
  800c87:	3c 30                	cmp    $0x30,%al
  800c89:	75 05                	jne    800c90 <strtol+0x64>
		s++, base = 8;
  800c8b:	42                   	inc    %edx
  800c8c:	b3 08                	mov    $0x8,%bl
  800c8e:	eb 05                	jmp    800c95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c9c:	8a 0a                	mov    (%edx),%cl
  800c9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ca1:	80 fb 09             	cmp    $0x9,%bl
  800ca4:	77 08                	ja     800cae <strtol+0x82>
			dig = *s - '0';
  800ca6:	0f be c9             	movsbl %cl,%ecx
  800ca9:	83 e9 30             	sub    $0x30,%ecx
  800cac:	eb 1e                	jmp    800ccc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800cae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800cb1:	80 fb 19             	cmp    $0x19,%bl
  800cb4:	77 08                	ja     800cbe <strtol+0x92>
			dig = *s - 'a' + 10;
  800cb6:	0f be c9             	movsbl %cl,%ecx
  800cb9:	83 e9 57             	sub    $0x57,%ecx
  800cbc:	eb 0e                	jmp    800ccc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cbe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cc1:	80 fb 19             	cmp    $0x19,%bl
  800cc4:	77 12                	ja     800cd8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800cc6:	0f be c9             	movsbl %cl,%ecx
  800cc9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ccc:	39 f1                	cmp    %esi,%ecx
  800cce:	7d 0c                	jge    800cdc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cd0:	42                   	inc    %edx
  800cd1:	0f af c6             	imul   %esi,%eax
  800cd4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cd6:	eb c4                	jmp    800c9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800cd8:	89 c1                	mov    %eax,%ecx
  800cda:	eb 02                	jmp    800cde <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cdc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce2:	74 05                	je     800ce9 <strtol+0xbd>
		*endptr = (char *) s;
  800ce4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ce9:	85 ff                	test   %edi,%edi
  800ceb:	74 04                	je     800cf1 <strtol+0xc5>
  800ced:	89 c8                	mov    %ecx,%eax
  800cef:	f7 d8                	neg    %eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
	...

00800cf8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	89 c3                	mov    %eax,%ebx
  800d0b:	89 c7                	mov    %eax,%edi
  800d0d:	89 c6                	mov    %eax,%esi
  800d0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d21:	b8 01 00 00 00       	mov    $0x1,%eax
  800d26:	89 d1                	mov    %edx,%ecx
  800d28:	89 d3                	mov    %edx,%ebx
  800d2a:	89 d7                	mov    %edx,%edi
  800d2c:	89 d6                	mov    %edx,%esi
  800d2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d43:	b8 03 00 00 00       	mov    $0x3,%eax
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	89 cb                	mov    %ecx,%ebx
  800d4d:	89 cf                	mov    %ecx,%edi
  800d4f:	89 ce                	mov    %ecx,%esi
  800d51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d53:	85 c0                	test   %eax,%eax
  800d55:	7e 28                	jle    800d7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800d7a:	e8 b1 f5 ff ff       	call   800330 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7f:	83 c4 2c             	add    $0x2c,%esp
  800d82:	5b                   	pop    %ebx
  800d83:	5e                   	pop    %esi
  800d84:	5f                   	pop    %edi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d92:	b8 02 00 00 00       	mov    $0x2,%eax
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 d3                	mov    %edx,%ebx
  800d9b:	89 d7                	mov    %edx,%edi
  800d9d:	89 d6                	mov    %edx,%esi
  800d9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_yield>:

void
sys_yield(void)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	ba 00 00 00 00       	mov    $0x0,%edx
  800db1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db6:	89 d1                	mov    %edx,%ecx
  800db8:	89 d3                	mov    %edx,%ebx
  800dba:	89 d7                	mov    %edx,%edi
  800dbc:	89 d6                	mov    %edx,%esi
  800dbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	be 00 00 00 00       	mov    $0x0,%esi
  800dd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 f7                	mov    %esi,%edi
  800de3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de5:	85 c0                	test   %eax,%eax
  800de7:	7e 28                	jle    800e11 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ded:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800df4:	00 
  800df5:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e04:	00 
  800e05:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800e0c:	e8 1f f5 ff ff       	call   800330 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e11:	83 c4 2c             	add    $0x2c,%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	b8 05 00 00 00       	mov    $0x5,%eax
  800e27:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	7e 28                	jle    800e64 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e40:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e47:	00 
  800e48:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800e4f:	00 
  800e50:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e57:	00 
  800e58:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800e5f:	e8 cc f4 ff ff       	call   800330 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e64:	83 c4 2c             	add    $0x2c,%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	89 df                	mov    %ebx,%edi
  800e87:	89 de                	mov    %ebx,%esi
  800e89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7e 28                	jle    800eb7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e93:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e9a:	00 
  800e9b:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eaa:	00 
  800eab:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800eb2:	e8 79 f4 ff ff       	call   800330 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb7:	83 c4 2c             	add    $0x2c,%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
  800ec5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ecd:	b8 08 00 00 00       	mov    $0x8,%eax
  800ed2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	89 df                	mov    %ebx,%edi
  800eda:	89 de                	mov    %ebx,%esi
  800edc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	7e 28                	jle    800f0a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eed:	00 
  800eee:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800ef5:	00 
  800ef6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800efd:	00 
  800efe:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800f05:	e8 26 f4 ff ff       	call   800330 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f0a:	83 c4 2c             	add    $0x2c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f20:	b8 09 00 00 00       	mov    $0x9,%eax
  800f25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2b:	89 df                	mov    %ebx,%edi
  800f2d:	89 de                	mov    %ebx,%esi
  800f2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7e 28                	jle    800f5d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f35:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f39:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f40:	00 
  800f41:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800f48:	00 
  800f49:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f50:	00 
  800f51:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800f58:	e8 d3 f3 ff ff       	call   800330 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f5d:	83 c4 2c             	add    $0x2c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	53                   	push   %ebx
  800f6b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f73:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	89 df                	mov    %ebx,%edi
  800f80:	89 de                	mov    %ebx,%esi
  800f82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f84:	85 c0                	test   %eax,%eax
  800f86:	7e 28                	jle    800fb0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f88:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f93:	00 
  800f94:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  800f9b:	00 
  800f9c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa3:	00 
  800fa4:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  800fab:	e8 80 f3 ff ff       	call   800330 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb0:	83 c4 2c             	add    $0x2c,%esp
  800fb3:	5b                   	pop    %ebx
  800fb4:	5e                   	pop    %esi
  800fb5:	5f                   	pop    %edi
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	57                   	push   %edi
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbe:	be 00 00 00 00       	mov    $0x0,%esi
  800fc3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5f                   	pop    %edi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 cb                	mov    %ecx,%ebx
  800ff3:	89 cf                	mov    %ecx,%edi
  800ff5:	89 ce                	mov    %ecx,%esi
  800ff7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	7e 28                	jle    801025 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801001:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801008:	00 
  801009:	c7 44 24 08 1f 2a 80 	movl   $0x802a1f,0x8(%esp)
  801010:	00 
  801011:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  801020:	e8 0b f3 ff ff       	call   800330 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801025:	83 c4 2c             	add    $0x2c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	00 00                	add    %al,(%eax)
	...

00801030 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	83 ec 24             	sub    $0x24,%esp
  801037:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80103a:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  80103c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801040:	75 20                	jne    801062 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801042:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801046:	c7 44 24 08 4c 2a 80 	movl   $0x802a4c,0x8(%esp)
  80104d:	00 
  80104e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801055:	00 
  801056:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  80105d:	e8 ce f2 ff ff       	call   800330 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801062:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  80106d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801074:	f6 c4 08             	test   $0x8,%ah
  801077:	75 1c                	jne    801095 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801079:	c7 44 24 08 7c 2a 80 	movl   $0x802a7c,0x8(%esp)
  801080:	00 
  801081:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801088:	00 
  801089:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801090:	e8 9b f2 ff ff       	call   800330 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801095:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80109c:	00 
  80109d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010a4:	00 
  8010a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ac:	e8 14 fd ff ff       	call   800dc5 <sys_page_alloc>
  8010b1:	85 c0                	test   %eax,%eax
  8010b3:	79 20                	jns    8010d5 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  8010b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b9:	c7 44 24 08 d7 2a 80 	movl   $0x802ad7,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  8010d0:	e8 5b f2 ff ff       	call   800330 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  8010d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010dc:	00 
  8010dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010e1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010e8:	e8 5f fa ff ff       	call   800b4c <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8010ed:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010f4:	00 
  8010f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801100:	00 
  801101:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801108:	00 
  801109:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801110:	e8 04 fd ff ff       	call   800e19 <sys_page_map>
  801115:	85 c0                	test   %eax,%eax
  801117:	79 20                	jns    801139 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  801119:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111d:	c7 44 24 08 eb 2a 80 	movl   $0x802aeb,0x8(%esp)
  801124:	00 
  801125:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80112c:	00 
  80112d:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801134:	e8 f7 f1 ff ff       	call   800330 <_panic>

}
  801139:	83 c4 24             	add    $0x24,%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    

0080113f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801148:	c7 04 24 30 10 80 00 	movl   $0x801030,(%esp)
  80114f:	e8 8c 10 00 00       	call   8021e0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801154:	ba 07 00 00 00       	mov    $0x7,%edx
  801159:	89 d0                	mov    %edx,%eax
  80115b:	cd 30                	int    $0x30
  80115d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801160:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801163:	85 c0                	test   %eax,%eax
  801165:	79 20                	jns    801187 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  801167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116b:	c7 44 24 08 fd 2a 80 	movl   $0x802afd,0x8(%esp)
  801172:	00 
  801173:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80117a:	00 
  80117b:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801182:	e8 a9 f1 ff ff       	call   800330 <_panic>
	if (child_envid == 0) { // child
  801187:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80118b:	75 25                	jne    8011b2 <fork+0x73>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  80118d:	e8 f5 fb ff ff       	call   800d87 <sys_getenvid>
  801192:	25 ff 03 00 00       	and    $0x3ff,%eax
  801197:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80119e:	c1 e0 07             	shl    $0x7,%eax
  8011a1:	29 d0                	sub    %edx,%eax
  8011a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011ad:	e9 58 02 00 00       	jmp    80140a <fork+0x2cb>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  8011b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8011b7:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8011bc:	89 f0                	mov    %esi,%eax
  8011be:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8011c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011c8:	a8 01                	test   $0x1,%al
  8011ca:	0f 84 7a 01 00 00    	je     80134a <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8011d0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8011d7:	a8 01                	test   $0x1,%al
  8011d9:	0f 84 6b 01 00 00    	je     80134a <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8011df:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e4:	8b 40 48             	mov    0x48(%eax),%eax
  8011e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8011ea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011f1:	f6 c4 04             	test   $0x4,%ah
  8011f4:	74 52                	je     801248 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011f6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011fd:	25 07 0e 00 00       	and    $0xe07,%eax
  801202:	89 44 24 10          	mov    %eax,0x10(%esp)
  801206:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80120a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80120d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801211:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801215:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801218:	89 04 24             	mov    %eax,(%esp)
  80121b:	e8 f9 fb ff ff       	call   800e19 <sys_page_map>
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 89 22 01 00 00    	jns    80134a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801228:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122c:	c7 44 24 08 eb 2a 80 	movl   $0x802aeb,0x8(%esp)
  801233:	00 
  801234:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  80123b:	00 
  80123c:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801243:	e8 e8 f0 ff ff       	call   800330 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801248:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80124f:	f6 c4 08             	test   $0x8,%ah
  801252:	75 0f                	jne    801263 <fork+0x124>
  801254:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80125b:	a8 02                	test   $0x2,%al
  80125d:	0f 84 99 00 00 00    	je     8012fc <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  801263:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80126a:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  80126d:	83 f8 01             	cmp    $0x1,%eax
  801270:	19 db                	sbb    %ebx,%ebx
  801272:	83 e3 fc             	and    $0xfffffffc,%ebx
  801275:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  80127b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80127f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801283:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801286:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80128e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 80 fb ff ff       	call   800e19 <sys_page_map>
  801299:	85 c0                	test   %eax,%eax
  80129b:	79 20                	jns    8012bd <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  80129d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a1:	c7 44 24 08 eb 2a 80 	movl   $0x802aeb,0x8(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  8012b8:	e8 73 f0 ff ff       	call   800330 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8012bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012c1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012d0:	89 04 24             	mov    %eax,(%esp)
  8012d3:	e8 41 fb ff ff       	call   800e19 <sys_page_map>
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	79 6e                	jns    80134a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8012dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e0:	c7 44 24 08 eb 2a 80 	movl   $0x802aeb,0x8(%esp)
  8012e7:	00 
  8012e8:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012ef:	00 
  8012f0:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  8012f7:	e8 34 f0 ff ff       	call   800330 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8012fc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801303:	25 07 0e 00 00       	and    $0xe07,%eax
  801308:	89 44 24 10          	mov    %eax,0x10(%esp)
  80130c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801310:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801313:	89 44 24 08          	mov    %eax,0x8(%esp)
  801317:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80131b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131e:	89 04 24             	mov    %eax,(%esp)
  801321:	e8 f3 fa ff ff       	call   800e19 <sys_page_map>
  801326:	85 c0                	test   %eax,%eax
  801328:	79 20                	jns    80134a <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  80132a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132e:	c7 44 24 08 eb 2a 80 	movl   $0x802aeb,0x8(%esp)
  801335:	00 
  801336:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  80133d:	00 
  80133e:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801345:	e8 e6 ef ff ff       	call   800330 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  80134a:	46                   	inc    %esi
  80134b:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801351:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801357:	0f 85 5f fe ff ff    	jne    8011bc <fork+0x7d>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80135d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801364:	00 
  801365:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80136c:	ee 
  80136d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801370:	89 04 24             	mov    %eax,(%esp)
  801373:	e8 4d fa ff ff       	call   800dc5 <sys_page_alloc>
  801378:	85 c0                	test   %eax,%eax
  80137a:	79 20                	jns    80139c <fork+0x25d>
		panic("sys_page_alloc: %e\n", r);
  80137c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801380:	c7 44 24 08 d7 2a 80 	movl   $0x802ad7,0x8(%esp)
  801387:	00 
  801388:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80138f:	00 
  801390:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801397:	e8 94 ef ff ff       	call   800330 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  80139c:	c7 44 24 04 54 22 80 	movl   $0x802254,0x4(%esp)
  8013a3:	00 
  8013a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013a7:	89 04 24             	mov    %eax,(%esp)
  8013aa:	e8 b6 fb ff ff       	call   800f65 <sys_env_set_pgfault_upcall>
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	79 20                	jns    8013d3 <fork+0x294>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  8013b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b7:	c7 44 24 08 ac 2a 80 	movl   $0x802aac,0x8(%esp)
  8013be:	00 
  8013bf:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  8013c6:	00 
  8013c7:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  8013ce:	e8 5d ef ff ff       	call   800330 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8013d3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013da:	00 
  8013db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013de:	89 04 24             	mov    %eax,(%esp)
  8013e1:	e8 d9 fa ff ff       	call   800ebf <sys_env_set_status>
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	79 20                	jns    80140a <fork+0x2cb>
		panic("sys_env_set_status: %e\n", r);
  8013ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ee:	c7 44 24 08 0e 2b 80 	movl   $0x802b0e,0x8(%esp)
  8013f5:	00 
  8013f6:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8013fd:	00 
  8013fe:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801405:	e8 26 ef ff ff       	call   800330 <_panic>

	return child_envid;
}
  80140a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80140d:	83 c4 3c             	add    $0x3c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <sfork>:

// Challenge!
int
sfork(void)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80141b:	c7 44 24 08 26 2b 80 	movl   $0x802b26,0x8(%esp)
  801422:	00 
  801423:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  80142a:	00 
  80142b:	c7 04 24 cc 2a 80 00 	movl   $0x802acc,(%esp)
  801432:	e8 f9 ee ff ff       	call   800330 <_panic>
	...

00801438 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	05 00 00 00 30       	add    $0x30000000,%eax
  801443:	c1 e8 0c             	shr    $0xc,%eax
}
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	89 04 24             	mov    %eax,(%esp)
  801454:	e8 df ff ff ff       	call   801438 <fd2num>
  801459:	05 20 00 0d 00       	add    $0xd0020,%eax
  80145e:	c1 e0 0c             	shl    $0xc,%eax
}
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	53                   	push   %ebx
  801467:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80146a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80146f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 16             	shr    $0x16,%edx
  801476:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	74 11                	je     801493 <fd_alloc+0x30>
  801482:	89 c2                	mov    %eax,%edx
  801484:	c1 ea 0c             	shr    $0xc,%edx
  801487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148e:	f6 c2 01             	test   $0x1,%dl
  801491:	75 09                	jne    80149c <fd_alloc+0x39>
			*fd_store = fd;
  801493:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	eb 17                	jmp    8014b3 <fd_alloc+0x50>
  80149c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a6:	75 c7                	jne    80146f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014b3:	5b                   	pop    %ebx
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014bc:	83 f8 1f             	cmp    $0x1f,%eax
  8014bf:	77 36                	ja     8014f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c1:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014c6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	c1 ea 16             	shr    $0x16,%edx
  8014ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	74 24                	je     8014fe <fd_lookup+0x48>
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	c1 ea 0c             	shr    $0xc,%edx
  8014df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 1a                	je     801505 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f5:	eb 13                	jmp    80150a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fc:	eb 0c                	jmp    80150a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801503:	eb 05                	jmp    80150a <fd_lookup+0x54>
  801505:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 14             	sub    $0x14,%esp
  801513:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	eb 0e                	jmp    80152e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801520:	39 08                	cmp    %ecx,(%eax)
  801522:	75 09                	jne    80152d <dev_lookup+0x21>
			*dev = devtab[i];
  801524:	89 03                	mov    %eax,(%ebx)
			return 0;
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	eb 33                	jmp    801560 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80152d:	42                   	inc    %edx
  80152e:	8b 04 95 b8 2b 80 00 	mov    0x802bb8(,%edx,4),%eax
  801535:	85 c0                	test   %eax,%eax
  801537:	75 e7                	jne    801520 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801539:	a1 04 40 80 00       	mov    0x804004,%eax
  80153e:	8b 40 48             	mov    0x48(%eax),%eax
  801541:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801545:	89 44 24 04          	mov    %eax,0x4(%esp)
  801549:	c7 04 24 3c 2b 80 00 	movl   $0x802b3c,(%esp)
  801550:	e8 d3 ee ff ff       	call   800428 <cprintf>
	*dev = 0;
  801555:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80155b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801560:	83 c4 14             	add    $0x14,%esp
  801563:	5b                   	pop    %ebx
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 30             	sub    $0x30,%esp
  80156e:	8b 75 08             	mov    0x8(%ebp),%esi
  801571:	8a 45 0c             	mov    0xc(%ebp),%al
  801574:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801577:	89 34 24             	mov    %esi,(%esp)
  80157a:	e8 b9 fe ff ff       	call   801438 <fd2num>
  80157f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801582:	89 54 24 04          	mov    %edx,0x4(%esp)
  801586:	89 04 24             	mov    %eax,(%esp)
  801589:	e8 28 ff ff ff       	call   8014b6 <fd_lookup>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	85 c0                	test   %eax,%eax
  801592:	78 05                	js     801599 <fd_close+0x33>
	    || fd != fd2)
  801594:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801597:	74 0d                	je     8015a6 <fd_close+0x40>
		return (must_exist ? r : 0);
  801599:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80159d:	75 46                	jne    8015e5 <fd_close+0x7f>
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 3f                	jmp    8015e5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ad:	8b 06                	mov    (%esi),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 55 ff ff ff       	call   80150c <dev_lookup>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 18                	js     8015d5 <fd_close+0x6f>
		if (dev->dev_close)
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	8b 40 10             	mov    0x10(%eax),%eax
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 09                	je     8015d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015c7:	89 34 24             	mov    %esi,(%esp)
  8015ca:	ff d0                	call   *%eax
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	eb 05                	jmp    8015d5 <fd_close+0x6f>
		else
			r = 0;
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e0:	e8 87 f8 ff ff       	call   800e6c <sys_page_unmap>
	return r;
}
  8015e5:	89 d8                	mov    %ebx,%eax
  8015e7:	83 c4 30             	add    $0x30,%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 b0 fe ff ff       	call   8014b6 <fd_lookup>
  801606:	85 c0                	test   %eax,%eax
  801608:	78 13                	js     80161d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80160a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801611:	00 
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 49 ff ff ff       	call   801566 <fd_close>
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <close_all>:

void
close_all(void)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80162b:	89 1c 24             	mov    %ebx,(%esp)
  80162e:	e8 bb ff ff ff       	call   8015ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801633:	43                   	inc    %ebx
  801634:	83 fb 20             	cmp    $0x20,%ebx
  801637:	75 f2                	jne    80162b <close_all+0xc>
		close(i);
}
  801639:	83 c4 14             	add    $0x14,%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	57                   	push   %edi
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
  801645:	83 ec 4c             	sub    $0x4c,%esp
  801648:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80164b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80164e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	89 04 24             	mov    %eax,(%esp)
  801658:	e8 59 fe ff ff       	call   8014b6 <fd_lookup>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	85 c0                	test   %eax,%eax
  801661:	0f 88 e1 00 00 00    	js     801748 <dup+0x109>
		return r;
	close(newfdnum);
  801667:	89 3c 24             	mov    %edi,(%esp)
  80166a:	e8 7f ff ff ff       	call   8015ee <close>

	newfd = INDEX2FD(newfdnum);
  80166f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801675:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 c5 fd ff ff       	call   801448 <fd2data>
  801683:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801685:	89 34 24             	mov    %esi,(%esp)
  801688:	e8 bb fd ff ff       	call   801448 <fd2data>
  80168d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801690:	89 d8                	mov    %ebx,%eax
  801692:	c1 e8 16             	shr    $0x16,%eax
  801695:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169c:	a8 01                	test   $0x1,%al
  80169e:	74 46                	je     8016e6 <dup+0xa7>
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	c1 e8 0c             	shr    $0xc,%eax
  8016a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ac:	f6 c2 01             	test   $0x1,%dl
  8016af:	74 35                	je     8016e6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016cf:	00 
  8016d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016db:	e8 39 f7 ff ff       	call   800e19 <sys_page_map>
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 3b                	js     801721 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	c1 ea 0c             	shr    $0xc,%edx
  8016ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016f5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801703:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170a:	00 
  80170b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801716:	e8 fe f6 ff ff       	call   800e19 <sys_page_map>
  80171b:	89 c3                	mov    %eax,%ebx
  80171d:	85 c0                	test   %eax,%eax
  80171f:	79 25                	jns    801746 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801721:	89 74 24 04          	mov    %esi,0x4(%esp)
  801725:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172c:	e8 3b f7 ff ff       	call   800e6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801731:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801734:	89 44 24 04          	mov    %eax,0x4(%esp)
  801738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173f:	e8 28 f7 ff ff       	call   800e6c <sys_page_unmap>
	return r;
  801744:	eb 02                	jmp    801748 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801746:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	83 c4 4c             	add    $0x4c,%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5f                   	pop    %edi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	53                   	push   %ebx
  801756:	83 ec 24             	sub    $0x24,%esp
  801759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	89 1c 24             	mov    %ebx,(%esp)
  801766:	e8 4b fd ff ff       	call   8014b6 <fd_lookup>
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 6d                	js     8017dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	8b 00                	mov    (%eax),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 89 fd ff ff       	call   80150c <dev_lookup>
  801783:	85 c0                	test   %eax,%eax
  801785:	78 55                	js     8017dc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	8b 50 08             	mov    0x8(%eax),%edx
  80178d:	83 e2 03             	and    $0x3,%edx
  801790:	83 fa 01             	cmp    $0x1,%edx
  801793:	75 23                	jne    8017b8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801795:	a1 04 40 80 00       	mov    0x804004,%eax
  80179a:	8b 40 48             	mov    0x48(%eax),%eax
  80179d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a5:	c7 04 24 7d 2b 80 00 	movl   $0x802b7d,(%esp)
  8017ac:	e8 77 ec ff ff       	call   800428 <cprintf>
		return -E_INVAL;
  8017b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b6:	eb 24                	jmp    8017dc <read+0x8a>
	}
	if (!dev->dev_read)
  8017b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bb:	8b 52 08             	mov    0x8(%edx),%edx
  8017be:	85 d2                	test   %edx,%edx
  8017c0:	74 15                	je     8017d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	ff d2                	call   *%edx
  8017d5:	eb 05                	jmp    8017dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017dc:	83 c4 24             	add    $0x24,%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	57                   	push   %edi
  8017e6:	56                   	push   %esi
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 1c             	sub    $0x1c,%esp
  8017eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f6:	eb 23                	jmp    80181b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f8:	89 f0                	mov    %esi,%eax
  8017fa:	29 d8                	sub    %ebx,%eax
  8017fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801800:	8b 45 0c             	mov    0xc(%ebp),%eax
  801803:	01 d8                	add    %ebx,%eax
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	89 3c 24             	mov    %edi,(%esp)
  80180c:	e8 41 ff ff ff       	call   801752 <read>
		if (m < 0)
  801811:	85 c0                	test   %eax,%eax
  801813:	78 10                	js     801825 <readn+0x43>
			return m;
		if (m == 0)
  801815:	85 c0                	test   %eax,%eax
  801817:	74 0a                	je     801823 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801819:	01 c3                	add    %eax,%ebx
  80181b:	39 f3                	cmp    %esi,%ebx
  80181d:	72 d9                	jb     8017f8 <readn+0x16>
  80181f:	89 d8                	mov    %ebx,%eax
  801821:	eb 02                	jmp    801825 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801823:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801825:	83 c4 1c             	add    $0x1c,%esp
  801828:	5b                   	pop    %ebx
  801829:	5e                   	pop    %esi
  80182a:	5f                   	pop    %edi
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	53                   	push   %ebx
  801831:	83 ec 24             	sub    $0x24,%esp
  801834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801837:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183e:	89 1c 24             	mov    %ebx,(%esp)
  801841:	e8 70 fc ff ff       	call   8014b6 <fd_lookup>
  801846:	85 c0                	test   %eax,%eax
  801848:	78 68                	js     8018b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801854:	8b 00                	mov    (%eax),%eax
  801856:	89 04 24             	mov    %eax,(%esp)
  801859:	e8 ae fc ff ff       	call   80150c <dev_lookup>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 50                	js     8018b2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801865:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801869:	75 23                	jne    80188e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80186b:	a1 04 40 80 00       	mov    0x804004,%eax
  801870:	8b 40 48             	mov    0x48(%eax),%eax
  801873:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187b:	c7 04 24 99 2b 80 00 	movl   $0x802b99,(%esp)
  801882:	e8 a1 eb ff ff       	call   800428 <cprintf>
		return -E_INVAL;
  801887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80188c:	eb 24                	jmp    8018b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80188e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801891:	8b 52 0c             	mov    0xc(%edx),%edx
  801894:	85 d2                	test   %edx,%edx
  801896:	74 15                	je     8018ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801898:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80189b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80189f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	ff d2                	call   *%edx
  8018ab:	eb 05                	jmp    8018b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018b2:	83 c4 24             	add    $0x24,%esp
  8018b5:	5b                   	pop    %ebx
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	e8 e6 fb ff ff       	call   8014b6 <fd_lookup>
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 0e                	js     8018e2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 24             	sub    $0x24,%esp
  8018eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	89 1c 24             	mov    %ebx,(%esp)
  8018f8:	e8 b9 fb ff ff       	call   8014b6 <fd_lookup>
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 61                	js     801962 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801904:	89 44 24 04          	mov    %eax,0x4(%esp)
  801908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190b:	8b 00                	mov    (%eax),%eax
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	e8 f7 fb ff ff       	call   80150c <dev_lookup>
  801915:	85 c0                	test   %eax,%eax
  801917:	78 49                	js     801962 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801920:	75 23                	jne    801945 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801922:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801927:	8b 40 48             	mov    0x48(%eax),%eax
  80192a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	c7 04 24 5c 2b 80 00 	movl   $0x802b5c,(%esp)
  801939:	e8 ea ea ff ff       	call   800428 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80193e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801943:	eb 1d                	jmp    801962 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801945:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801948:	8b 52 18             	mov    0x18(%edx),%edx
  80194b:	85 d2                	test   %edx,%edx
  80194d:	74 0e                	je     80195d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80194f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801952:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801956:	89 04 24             	mov    %eax,(%esp)
  801959:	ff d2                	call   *%edx
  80195b:	eb 05                	jmp    801962 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80195d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801962:	83 c4 24             	add    $0x24,%esp
  801965:	5b                   	pop    %ebx
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 24             	sub    $0x24,%esp
  80196f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801972:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 32 fb ff ff       	call   8014b6 <fd_lookup>
  801984:	85 c0                	test   %eax,%eax
  801986:	78 52                	js     8019da <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801988:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801992:	8b 00                	mov    (%eax),%eax
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	e8 70 fb ff ff       	call   80150c <dev_lookup>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 3a                	js     8019da <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a7:	74 2c                	je     8019d5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019b3:	00 00 00 
	stat->st_isdir = 0;
  8019b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bd:	00 00 00 
	stat->st_dev = dev;
  8019c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019cd:	89 14 24             	mov    %edx,(%esp)
  8019d0:	ff 50 14             	call   *0x14(%eax)
  8019d3:	eb 05                	jmp    8019da <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019da:	83 c4 24             	add    $0x24,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ef:	00 
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	89 04 24             	mov    %eax,(%esp)
  8019f6:	e8 2d 02 00 00       	call   801c28 <open>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 1b                	js     801a1c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 58 ff ff ff       	call   801968 <fstat>
  801a10:	89 c6                	mov    %eax,%esi
	close(fd);
  801a12:	89 1c 24             	mov    %ebx,(%esp)
  801a15:	e8 d4 fb ff ff       	call   8015ee <close>
	return r;
  801a1a:	89 f3                	mov    %esi,%ebx
}
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    
  801a25:	00 00                	add    %al,(%eax)
	...

00801a28 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 10             	sub    $0x10,%esp
  801a30:	89 c3                	mov    %eax,%ebx
  801a32:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a34:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a3b:	75 11                	jne    801a4e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a44:	e8 06 09 00 00       	call   80234f <ipc_find_env>
  801a49:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a4e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a55:	00 
  801a56:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a5d:	00 
  801a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a62:	a1 00 40 80 00       	mov    0x804000,%eax
  801a67:	89 04 24             	mov    %eax,(%esp)
  801a6a:	e8 72 08 00 00       	call   8022e1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a76:	00 
  801a77:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a82:	e8 f1 07 00 00       	call   802278 <ipc_recv>
}
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aac:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab1:	e8 72 ff ff ff       	call   801a28 <fsipc>
}
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ace:	b8 06 00 00 00       	mov    $0x6,%eax
  801ad3:	e8 50 ff ff ff       	call   801a28 <fsipc>
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 14             	sub    $0x14,%esp
  801ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 05 00 00 00       	mov    $0x5,%eax
  801af9:	e8 2a ff ff ff       	call   801a28 <fsipc>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 2b                	js     801b2d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b02:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b09:	00 
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 c1 ee ff ff       	call   8009d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b12:	a1 80 50 80 00       	mov    0x805080,%eax
  801b17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b1d:	a1 84 50 80 00       	mov    0x805084,%eax
  801b22:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2d:	83 c4 14             	add    $0x14,%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 18             	sub    $0x18,%esp
  801b39:	8b 55 10             	mov    0x10(%ebp),%edx
  801b3c:	89 d0                	mov    %edx,%eax
  801b3e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801b44:	76 05                	jbe    801b4b <devfile_write+0x18>
  801b46:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b4e:	8b 52 0c             	mov    0xc(%edx),%edx
  801b51:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b57:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b67:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801b6e:	e8 d9 ef ff ff       	call   800b4c <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801b73:	ba 00 00 00 00       	mov    $0x0,%edx
  801b78:	b8 04 00 00 00       	mov    $0x4,%eax
  801b7d:	e8 a6 fe ff ff       	call   801a28 <fsipc>
}
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	56                   	push   %esi
  801b88:	53                   	push   %ebx
  801b89:	83 ec 10             	sub    $0x10,%esp
  801b8c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	8b 40 0c             	mov    0xc(%eax),%eax
  801b95:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b9a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba5:	b8 03 00 00 00       	mov    $0x3,%eax
  801baa:	e8 79 fe ff ff       	call   801a28 <fsipc>
  801baf:	89 c3                	mov    %eax,%ebx
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 6a                	js     801c1f <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801bb5:	39 c6                	cmp    %eax,%esi
  801bb7:	73 24                	jae    801bdd <devfile_read+0x59>
  801bb9:	c7 44 24 0c c8 2b 80 	movl   $0x802bc8,0xc(%esp)
  801bc0:	00 
  801bc1:	c7 44 24 08 cf 2b 80 	movl   $0x802bcf,0x8(%esp)
  801bc8:	00 
  801bc9:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801bd0:	00 
  801bd1:	c7 04 24 e4 2b 80 00 	movl   $0x802be4,(%esp)
  801bd8:	e8 53 e7 ff ff       	call   800330 <_panic>
	assert(r <= PGSIZE);
  801bdd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801be2:	7e 24                	jle    801c08 <devfile_read+0x84>
  801be4:	c7 44 24 0c ef 2b 80 	movl   $0x802bef,0xc(%esp)
  801beb:	00 
  801bec:	c7 44 24 08 cf 2b 80 	movl   $0x802bcf,0x8(%esp)
  801bf3:	00 
  801bf4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bfb:	00 
  801bfc:	c7 04 24 e4 2b 80 00 	movl   $0x802be4,(%esp)
  801c03:	e8 28 e7 ff ff       	call   800330 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0c:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c13:	00 
  801c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c17:	89 04 24             	mov    %eax,(%esp)
  801c1a:	e8 2d ef ff ff       	call   800b4c <memmove>
	return r;
}
  801c1f:	89 d8                	mov    %ebx,%eax
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 20             	sub    $0x20,%esp
  801c30:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c33:	89 34 24             	mov    %esi,(%esp)
  801c36:	e8 65 ed ff ff       	call   8009a0 <strlen>
  801c3b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c40:	7f 60                	jg     801ca2 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 16 f8 ff ff       	call   801463 <fd_alloc>
  801c4d:	89 c3                	mov    %eax,%ebx
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 54                	js     801ca7 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c57:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c5e:	e8 70 ed ff ff       	call   8009d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c66:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c73:	e8 b0 fd ff ff       	call   801a28 <fsipc>
  801c78:	89 c3                	mov    %eax,%ebx
  801c7a:	85 c0                	test   %eax,%eax
  801c7c:	79 15                	jns    801c93 <open+0x6b>
		fd_close(fd, 0);
  801c7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c85:	00 
  801c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c89:	89 04 24             	mov    %eax,(%esp)
  801c8c:	e8 d5 f8 ff ff       	call   801566 <fd_close>
		return r;
  801c91:	eb 14                	jmp    801ca7 <open+0x7f>
	}

	return fd2num(fd);
  801c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 9a f7 ff ff       	call   801438 <fd2num>
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	eb 05                	jmp    801ca7 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ca2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ca7:	89 d8                	mov    %ebx,%eax
  801ca9:	83 c4 20             	add    $0x20,%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    

00801cb0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbb:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc0:	e8 63 fd ff ff       	call   801a28 <fsipc>
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    
	...

00801cc8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	83 ec 10             	sub    $0x10,%esp
  801cd0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd6:	89 04 24             	mov    %eax,(%esp)
  801cd9:	e8 6a f7 ff ff       	call   801448 <fd2data>
  801cde:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801ce0:	c7 44 24 04 fb 2b 80 	movl   $0x802bfb,0x4(%esp)
  801ce7:	00 
  801ce8:	89 34 24             	mov    %esi,(%esp)
  801ceb:	e8 e3 ec ff ff       	call   8009d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cf0:	8b 43 04             	mov    0x4(%ebx),%eax
  801cf3:	2b 03                	sub    (%ebx),%eax
  801cf5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801cfb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801d02:	00 00 00 
	stat->st_dev = &devpipe;
  801d05:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801d0c:	30 80 00 
	return 0;
}
  801d0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	53                   	push   %ebx
  801d1f:	83 ec 14             	sub    $0x14,%esp
  801d22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d25:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d30:	e8 37 f1 ff ff       	call   800e6c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d35:	89 1c 24             	mov    %ebx,(%esp)
  801d38:	e8 0b f7 ff ff       	call   801448 <fd2data>
  801d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d48:	e8 1f f1 ff ff       	call   800e6c <sys_page_unmap>
}
  801d4d:	83 c4 14             	add    $0x14,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	57                   	push   %edi
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	83 ec 2c             	sub    $0x2c,%esp
  801d5c:	89 c7                	mov    %eax,%edi
  801d5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d61:	a1 04 40 80 00       	mov    0x804004,%eax
  801d66:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d69:	89 3c 24             	mov    %edi,(%esp)
  801d6c:	e8 23 06 00 00       	call   802394 <pageref>
  801d71:	89 c6                	mov    %eax,%esi
  801d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d76:	89 04 24             	mov    %eax,(%esp)
  801d79:	e8 16 06 00 00       	call   802394 <pageref>
  801d7e:	39 c6                	cmp    %eax,%esi
  801d80:	0f 94 c0             	sete   %al
  801d83:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d86:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d8c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d8f:	39 cb                	cmp    %ecx,%ebx
  801d91:	75 08                	jne    801d9b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d93:	83 c4 2c             	add    $0x2c,%esp
  801d96:	5b                   	pop    %ebx
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d9b:	83 f8 01             	cmp    $0x1,%eax
  801d9e:	75 c1                	jne    801d61 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801da0:	8b 42 58             	mov    0x58(%edx),%eax
  801da3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801daa:	00 
  801dab:	89 44 24 08          	mov    %eax,0x8(%esp)
  801daf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801db3:	c7 04 24 02 2c 80 00 	movl   $0x802c02,(%esp)
  801dba:	e8 69 e6 ff ff       	call   800428 <cprintf>
  801dbf:	eb a0                	jmp    801d61 <_pipeisclosed+0xe>

00801dc1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	57                   	push   %edi
  801dc5:	56                   	push   %esi
  801dc6:	53                   	push   %ebx
  801dc7:	83 ec 1c             	sub    $0x1c,%esp
  801dca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801dcd:	89 34 24             	mov    %esi,(%esp)
  801dd0:	e8 73 f6 ff ff       	call   801448 <fd2data>
  801dd5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dd7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddc:	eb 3c                	jmp    801e1a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dde:	89 da                	mov    %ebx,%edx
  801de0:	89 f0                	mov    %esi,%eax
  801de2:	e8 6c ff ff ff       	call   801d53 <_pipeisclosed>
  801de7:	85 c0                	test   %eax,%eax
  801de9:	75 38                	jne    801e23 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801deb:	e8 b6 ef ff ff       	call   800da6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801df0:	8b 43 04             	mov    0x4(%ebx),%eax
  801df3:	8b 13                	mov    (%ebx),%edx
  801df5:	83 c2 20             	add    $0x20,%edx
  801df8:	39 d0                	cmp    %edx,%eax
  801dfa:	73 e2                	jae    801dde <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dff:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801e02:	89 c2                	mov    %eax,%edx
  801e04:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801e0a:	79 05                	jns    801e11 <devpipe_write+0x50>
  801e0c:	4a                   	dec    %edx
  801e0d:	83 ca e0             	or     $0xffffffe0,%edx
  801e10:	42                   	inc    %edx
  801e11:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e15:	40                   	inc    %eax
  801e16:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e19:	47                   	inc    %edi
  801e1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e1d:	75 d1                	jne    801df0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e1f:	89 f8                	mov    %edi,%eax
  801e21:	eb 05                	jmp    801e28 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e23:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e28:	83 c4 1c             	add    $0x1c,%esp
  801e2b:	5b                   	pop    %ebx
  801e2c:	5e                   	pop    %esi
  801e2d:	5f                   	pop    %edi
  801e2e:	5d                   	pop    %ebp
  801e2f:	c3                   	ret    

00801e30 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	57                   	push   %edi
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	83 ec 1c             	sub    $0x1c,%esp
  801e39:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e3c:	89 3c 24             	mov    %edi,(%esp)
  801e3f:	e8 04 f6 ff ff       	call   801448 <fd2data>
  801e44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e46:	be 00 00 00 00       	mov    $0x0,%esi
  801e4b:	eb 3a                	jmp    801e87 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e4d:	85 f6                	test   %esi,%esi
  801e4f:	74 04                	je     801e55 <devpipe_read+0x25>
				return i;
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	eb 40                	jmp    801e95 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e55:	89 da                	mov    %ebx,%edx
  801e57:	89 f8                	mov    %edi,%eax
  801e59:	e8 f5 fe ff ff       	call   801d53 <_pipeisclosed>
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	75 2e                	jne    801e90 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e62:	e8 3f ef ff ff       	call   800da6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e67:	8b 03                	mov    (%ebx),%eax
  801e69:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e6c:	74 df                	je     801e4d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e6e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e73:	79 05                	jns    801e7a <devpipe_read+0x4a>
  801e75:	48                   	dec    %eax
  801e76:	83 c8 e0             	or     $0xffffffe0,%eax
  801e79:	40                   	inc    %eax
  801e7a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e81:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e84:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e86:	46                   	inc    %esi
  801e87:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e8a:	75 db                	jne    801e67 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e8c:	89 f0                	mov    %esi,%eax
  801e8e:	eb 05                	jmp    801e95 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e90:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	57                   	push   %edi
  801ea1:	56                   	push   %esi
  801ea2:	53                   	push   %ebx
  801ea3:	83 ec 3c             	sub    $0x3c,%esp
  801ea6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ea9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801eac:	89 04 24             	mov    %eax,(%esp)
  801eaf:	e8 af f5 ff ff       	call   801463 <fd_alloc>
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	0f 88 45 01 00 00    	js     802003 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec5:	00 
  801ec6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed4:	e8 ec ee ff ff       	call   800dc5 <sys_page_alloc>
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	85 c0                	test   %eax,%eax
  801edd:	0f 88 20 01 00 00    	js     802003 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ee3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 75 f5 ff ff       	call   801463 <fd_alloc>
  801eee:	89 c3                	mov    %eax,%ebx
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	0f 88 f8 00 00 00    	js     801ff0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eff:	00 
  801f00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0e:	e8 b2 ee ff ff       	call   800dc5 <sys_page_alloc>
  801f13:	89 c3                	mov    %eax,%ebx
  801f15:	85 c0                	test   %eax,%eax
  801f17:	0f 88 d3 00 00 00    	js     801ff0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	e8 20 f5 ff ff       	call   801448 <fd2data>
  801f28:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f31:	00 
  801f32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3d:	e8 83 ee ff ff       	call   800dc5 <sys_page_alloc>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	85 c0                	test   %eax,%eax
  801f46:	0f 88 91 00 00 00    	js     801fdd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f4f:	89 04 24             	mov    %eax,(%esp)
  801f52:	e8 f1 f4 ff ff       	call   801448 <fd2data>
  801f57:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f5e:	00 
  801f5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f6a:	00 
  801f6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f76:	e8 9e ee ff ff       	call   800e19 <sys_page_map>
  801f7b:	89 c3                	mov    %eax,%ebx
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 4c                	js     801fcd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f81:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f8a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f8f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f96:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f9f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fa4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 82 f4 ff ff       	call   801438 <fd2num>
  801fb6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 75 f4 ff ff       	call   801438 <fd2num>
  801fc3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fcb:	eb 36                	jmp    802003 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801fcd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd8:	e8 8f ee ff ff       	call   800e6c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801feb:	e8 7c ee ff ff       	call   800e6c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ffe:	e8 69 ee ff ff       	call   800e6c <sys_page_unmap>
    err:
	return r;
}
  802003:	89 d8                	mov    %ebx,%eax
  802005:	83 c4 3c             	add    $0x3c,%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802013:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201a:	8b 45 08             	mov    0x8(%ebp),%eax
  80201d:	89 04 24             	mov    %eax,(%esp)
  802020:	e8 91 f4 ff ff       	call   8014b6 <fd_lookup>
  802025:	85 c0                	test   %eax,%eax
  802027:	78 15                	js     80203e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202c:	89 04 24             	mov    %eax,(%esp)
  80202f:	e8 14 f4 ff ff       	call   801448 <fd2data>
	return _pipeisclosed(fd, p);
  802034:	89 c2                	mov    %eax,%edx
  802036:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802039:	e8 15 fd ff ff       	call   801d53 <_pipeisclosed>
}
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802050:	c7 44 24 04 15 2c 80 	movl   $0x802c15,0x4(%esp)
  802057:	00 
  802058:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205b:	89 04 24             	mov    %eax,(%esp)
  80205e:	e8 70 e9 ff ff       	call   8009d3 <strcpy>
	return 0;
}
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
  802068:	c9                   	leave  
  802069:	c3                   	ret    

0080206a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	57                   	push   %edi
  80206e:	56                   	push   %esi
  80206f:	53                   	push   %ebx
  802070:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802076:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80207b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802081:	eb 30                	jmp    8020b3 <devcons_write+0x49>
		m = n - tot;
  802083:	8b 75 10             	mov    0x10(%ebp),%esi
  802086:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802088:	83 fe 7f             	cmp    $0x7f,%esi
  80208b:	76 05                	jbe    802092 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80208d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802092:	89 74 24 08          	mov    %esi,0x8(%esp)
  802096:	03 45 0c             	add    0xc(%ebp),%eax
  802099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209d:	89 3c 24             	mov    %edi,(%esp)
  8020a0:	e8 a7 ea ff ff       	call   800b4c <memmove>
		sys_cputs(buf, m);
  8020a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020a9:	89 3c 24             	mov    %edi,(%esp)
  8020ac:	e8 47 ec ff ff       	call   800cf8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b1:	01 f3                	add    %esi,%ebx
  8020b3:	89 d8                	mov    %ebx,%eax
  8020b5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020b8:	72 c9                	jb     802083 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020ba:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8020cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020cf:	75 07                	jne    8020d8 <devcons_read+0x13>
  8020d1:	eb 25                	jmp    8020f8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020d3:	e8 ce ec ff ff       	call   800da6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020d8:	e8 39 ec ff ff       	call   800d16 <sys_cgetc>
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	74 f2                	je     8020d3 <devcons_read+0xe>
  8020e1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 1d                	js     802104 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020e7:	83 f8 04             	cmp    $0x4,%eax
  8020ea:	74 13                	je     8020ff <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ef:	88 10                	mov    %dl,(%eax)
	return 1;
  8020f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f6:	eb 0c                	jmp    802104 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020fd:	eb 05                	jmp    802104 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020ff:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802104:	c9                   	leave  
  802105:	c3                   	ret    

00802106 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80210c:	8b 45 08             	mov    0x8(%ebp),%eax
  80210f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802112:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802119:	00 
  80211a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80211d:	89 04 24             	mov    %eax,(%esp)
  802120:	e8 d3 eb ff ff       	call   800cf8 <sys_cputs>
}
  802125:	c9                   	leave  
  802126:	c3                   	ret    

00802127 <getchar>:

int
getchar(void)
{
  802127:	55                   	push   %ebp
  802128:	89 e5                	mov    %esp,%ebp
  80212a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80212d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802134:	00 
  802135:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802143:	e8 0a f6 ff ff       	call   801752 <read>
	if (r < 0)
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 0f                	js     80215b <getchar+0x34>
		return r;
	if (r < 1)
  80214c:	85 c0                	test   %eax,%eax
  80214e:	7e 06                	jle    802156 <getchar+0x2f>
		return -E_EOF;
	return c;
  802150:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802154:	eb 05                	jmp    80215b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802156:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    

0080215d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80215d:	55                   	push   %ebp
  80215e:	89 e5                	mov    %esp,%ebp
  802160:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802163:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802166:	89 44 24 04          	mov    %eax,0x4(%esp)
  80216a:	8b 45 08             	mov    0x8(%ebp),%eax
  80216d:	89 04 24             	mov    %eax,(%esp)
  802170:	e8 41 f3 ff ff       	call   8014b6 <fd_lookup>
  802175:	85 c0                	test   %eax,%eax
  802177:	78 11                	js     80218a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802182:	39 10                	cmp    %edx,(%eax)
  802184:	0f 94 c0             	sete   %al
  802187:	0f b6 c0             	movzbl %al,%eax
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <opencons>:

int
opencons(void)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802195:	89 04 24             	mov    %eax,(%esp)
  802198:	e8 c6 f2 ff ff       	call   801463 <fd_alloc>
  80219d:	85 c0                	test   %eax,%eax
  80219f:	78 3c                	js     8021dd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021a8:	00 
  8021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b7:	e8 09 ec ff ff       	call   800dc5 <sys_page_alloc>
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	78 1d                	js     8021dd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021d5:	89 04 24             	mov    %eax,(%esp)
  8021d8:	e8 5b f2 ff ff       	call   801438 <fd2num>
}
  8021dd:	c9                   	leave  
  8021de:	c3                   	ret    
	...

008021e0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021e6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021ed:	75 58                	jne    802247 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  8021ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8021f4:	8b 40 48             	mov    0x48(%eax),%eax
  8021f7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8021fe:	00 
  8021ff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802206:	ee 
  802207:	89 04 24             	mov    %eax,(%esp)
  80220a:	e8 b6 eb ff ff       	call   800dc5 <sys_page_alloc>
  80220f:	85 c0                	test   %eax,%eax
  802211:	74 1c                	je     80222f <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  802213:	c7 44 24 08 21 2c 80 	movl   $0x802c21,0x8(%esp)
  80221a:	00 
  80221b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802222:	00 
  802223:	c7 04 24 36 2c 80 00 	movl   $0x802c36,(%esp)
  80222a:	e8 01 e1 ff ff       	call   800330 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80222f:	a1 04 40 80 00       	mov    0x804004,%eax
  802234:	8b 40 48             	mov    0x48(%eax),%eax
  802237:	c7 44 24 04 54 22 80 	movl   $0x802254,0x4(%esp)
  80223e:	00 
  80223f:	89 04 24             	mov    %eax,(%esp)
  802242:	e8 1e ed ff ff       	call   800f65 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802247:	8b 45 08             	mov    0x8(%ebp),%eax
  80224a:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80224f:	c9                   	leave  
  802250:	c3                   	ret    
  802251:	00 00                	add    %al,(%eax)
	...

00802254 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802254:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802255:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80225a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80225c:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  80225f:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802263:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802265:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802269:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  80226a:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  80226d:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  80226f:	58                   	pop    %eax
	popl %eax
  802270:	58                   	pop    %eax

	// Pop all registers back
	popal
  802271:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802272:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802275:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802276:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802277:	c3                   	ret    

00802278 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	56                   	push   %esi
  80227c:	53                   	push   %ebx
  80227d:	83 ec 10             	sub    $0x10,%esp
  802280:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802283:	8b 45 0c             	mov    0xc(%ebp),%eax
  802286:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802289:	85 c0                	test   %eax,%eax
  80228b:	75 05                	jne    802292 <ipc_recv+0x1a>
  80228d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802292:	89 04 24             	mov    %eax,(%esp)
  802295:	e8 41 ed ff ff       	call   800fdb <sys_ipc_recv>
	if (from_env_store != NULL)
  80229a:	85 db                	test   %ebx,%ebx
  80229c:	74 0b                	je     8022a9 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  80229e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022a4:	8b 52 74             	mov    0x74(%edx),%edx
  8022a7:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  8022a9:	85 f6                	test   %esi,%esi
  8022ab:	74 0b                	je     8022b8 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  8022ad:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022b3:	8b 52 78             	mov    0x78(%edx),%edx
  8022b6:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	79 16                	jns    8022d2 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  8022bc:	85 db                	test   %ebx,%ebx
  8022be:	74 06                	je     8022c6 <ipc_recv+0x4e>
			*from_env_store = 0;
  8022c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  8022c6:	85 f6                	test   %esi,%esi
  8022c8:	74 10                	je     8022da <ipc_recv+0x62>
			*perm_store = 0;
  8022ca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8022d0:	eb 08                	jmp    8022da <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  8022d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8022d7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    

008022e1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	57                   	push   %edi
  8022e5:	56                   	push   %esi
  8022e6:	53                   	push   %ebx
  8022e7:	83 ec 1c             	sub    $0x1c,%esp
  8022ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8022ed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8022f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  8022f3:	eb 2a                	jmp    80231f <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  8022f5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022f8:	74 20                	je     80231a <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  8022fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022fe:	c7 44 24 08 44 2c 80 	movl   $0x802c44,0x8(%esp)
  802305:	00 
  802306:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  80230d:	00 
  80230e:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
  802315:	e8 16 e0 ff ff       	call   800330 <_panic>
		sys_yield();
  80231a:	e8 87 ea ff ff       	call   800da6 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80231f:	85 db                	test   %ebx,%ebx
  802321:	75 07                	jne    80232a <ipc_send+0x49>
  802323:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802328:	eb 02                	jmp    80232c <ipc_send+0x4b>
  80232a:	89 d8                	mov    %ebx,%eax
  80232c:	8b 55 14             	mov    0x14(%ebp),%edx
  80232f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802333:	89 44 24 08          	mov    %eax,0x8(%esp)
  802337:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80233b:	89 34 24             	mov    %esi,(%esp)
  80233e:	e8 75 ec ff ff       	call   800fb8 <sys_ipc_try_send>
  802343:	85 c0                	test   %eax,%eax
  802345:	78 ae                	js     8022f5 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  802347:	83 c4 1c             	add    $0x1c,%esp
  80234a:	5b                   	pop    %ebx
  80234b:	5e                   	pop    %esi
  80234c:	5f                   	pop    %edi
  80234d:	5d                   	pop    %ebp
  80234e:	c3                   	ret    

0080234f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80234f:	55                   	push   %ebp
  802350:	89 e5                	mov    %esp,%ebp
  802352:	53                   	push   %ebx
  802353:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802356:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80235b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802362:	89 c2                	mov    %eax,%edx
  802364:	c1 e2 07             	shl    $0x7,%edx
  802367:	29 ca                	sub    %ecx,%edx
  802369:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80236f:	8b 52 50             	mov    0x50(%edx),%edx
  802372:	39 da                	cmp    %ebx,%edx
  802374:	75 0f                	jne    802385 <ipc_find_env+0x36>
			return envs[i].env_id;
  802376:	c1 e0 07             	shl    $0x7,%eax
  802379:	29 c8                	sub    %ecx,%eax
  80237b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802380:	8b 40 40             	mov    0x40(%eax),%eax
  802383:	eb 0c                	jmp    802391 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802385:	40                   	inc    %eax
  802386:	3d 00 04 00 00       	cmp    $0x400,%eax
  80238b:	75 ce                	jne    80235b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80238d:	66 b8 00 00          	mov    $0x0,%ax
}
  802391:	5b                   	pop    %ebx
  802392:	5d                   	pop    %ebp
  802393:	c3                   	ret    

00802394 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80239a:	89 c2                	mov    %eax,%edx
  80239c:	c1 ea 16             	shr    $0x16,%edx
  80239f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8023a6:	f6 c2 01             	test   $0x1,%dl
  8023a9:	74 1e                	je     8023c9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ab:	c1 e8 0c             	shr    $0xc,%eax
  8023ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023b5:	a8 01                	test   $0x1,%al
  8023b7:	74 17                	je     8023d0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023b9:	c1 e8 0c             	shr    $0xc,%eax
  8023bc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8023c3:	ef 
  8023c4:	0f b7 c0             	movzwl %ax,%eax
  8023c7:	eb 0c                	jmp    8023d5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8023c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ce:	eb 05                	jmp    8023d5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8023d0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    
	...

008023d8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8023d8:	55                   	push   %ebp
  8023d9:	57                   	push   %edi
  8023da:	56                   	push   %esi
  8023db:	83 ec 10             	sub    $0x10,%esp
  8023de:	8b 74 24 20          	mov    0x20(%esp),%esi
  8023e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023ea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8023ee:	89 cd                	mov    %ecx,%ebp
  8023f0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	75 2c                	jne    802424 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8023f8:	39 f9                	cmp    %edi,%ecx
  8023fa:	77 68                	ja     802464 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8023fc:	85 c9                	test   %ecx,%ecx
  8023fe:	75 0b                	jne    80240b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802400:	b8 01 00 00 00       	mov    $0x1,%eax
  802405:	31 d2                	xor    %edx,%edx
  802407:	f7 f1                	div    %ecx
  802409:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	89 f8                	mov    %edi,%eax
  80240f:	f7 f1                	div    %ecx
  802411:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802413:	89 f0                	mov    %esi,%eax
  802415:	f7 f1                	div    %ecx
  802417:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802419:	89 f0                	mov    %esi,%eax
  80241b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80241d:	83 c4 10             	add    $0x10,%esp
  802420:	5e                   	pop    %esi
  802421:	5f                   	pop    %edi
  802422:	5d                   	pop    %ebp
  802423:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802424:	39 f8                	cmp    %edi,%eax
  802426:	77 2c                	ja     802454 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802428:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80242b:	83 f6 1f             	xor    $0x1f,%esi
  80242e:	75 4c                	jne    80247c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802430:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802432:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802437:	72 0a                	jb     802443 <__udivdi3+0x6b>
  802439:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80243d:	0f 87 ad 00 00 00    	ja     8024f0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802443:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802448:	89 f0                	mov    %esi,%eax
  80244a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80244c:	83 c4 10             	add    $0x10,%esp
  80244f:	5e                   	pop    %esi
  802450:	5f                   	pop    %edi
  802451:	5d                   	pop    %ebp
  802452:	c3                   	ret    
  802453:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802454:	31 ff                	xor    %edi,%edi
  802456:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802458:	89 f0                	mov    %esi,%eax
  80245a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80245c:	83 c4 10             	add    $0x10,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802464:	89 fa                	mov    %edi,%edx
  802466:	89 f0                	mov    %esi,%eax
  802468:	f7 f1                	div    %ecx
  80246a:	89 c6                	mov    %eax,%esi
  80246c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80246e:	89 f0                	mov    %esi,%eax
  802470:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    
  802479:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80247c:	89 f1                	mov    %esi,%ecx
  80247e:	d3 e0                	shl    %cl,%eax
  802480:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802484:	b8 20 00 00 00       	mov    $0x20,%eax
  802489:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80248b:	89 ea                	mov    %ebp,%edx
  80248d:	88 c1                	mov    %al,%cl
  80248f:	d3 ea                	shr    %cl,%edx
  802491:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802495:	09 ca                	or     %ecx,%edx
  802497:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80249b:	89 f1                	mov    %esi,%ecx
  80249d:	d3 e5                	shl    %cl,%ebp
  80249f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8024a3:	89 fd                	mov    %edi,%ebp
  8024a5:	88 c1                	mov    %al,%cl
  8024a7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8024a9:	89 fa                	mov    %edi,%edx
  8024ab:	89 f1                	mov    %esi,%ecx
  8024ad:	d3 e2                	shl    %cl,%edx
  8024af:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8024b3:	88 c1                	mov    %al,%cl
  8024b5:	d3 ef                	shr    %cl,%edi
  8024b7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024b9:	89 f8                	mov    %edi,%eax
  8024bb:	89 ea                	mov    %ebp,%edx
  8024bd:	f7 74 24 08          	divl   0x8(%esp)
  8024c1:	89 d1                	mov    %edx,%ecx
  8024c3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8024c5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024c9:	39 d1                	cmp    %edx,%ecx
  8024cb:	72 17                	jb     8024e4 <__udivdi3+0x10c>
  8024cd:	74 09                	je     8024d8 <__udivdi3+0x100>
  8024cf:	89 fe                	mov    %edi,%esi
  8024d1:	31 ff                	xor    %edi,%edi
  8024d3:	e9 41 ff ff ff       	jmp    802419 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8024d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024dc:	89 f1                	mov    %esi,%ecx
  8024de:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024e0:	39 c2                	cmp    %eax,%edx
  8024e2:	73 eb                	jae    8024cf <__udivdi3+0xf7>
		{
		  q0--;
  8024e4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024e7:	31 ff                	xor    %edi,%edi
  8024e9:	e9 2b ff ff ff       	jmp    802419 <__udivdi3+0x41>
  8024ee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024f0:	31 f6                	xor    %esi,%esi
  8024f2:	e9 22 ff ff ff       	jmp    802419 <__udivdi3+0x41>
	...

008024f8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8024f8:	55                   	push   %ebp
  8024f9:	57                   	push   %edi
  8024fa:	56                   	push   %esi
  8024fb:	83 ec 20             	sub    $0x20,%esp
  8024fe:	8b 44 24 30          	mov    0x30(%esp),%eax
  802502:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802506:	89 44 24 14          	mov    %eax,0x14(%esp)
  80250a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80250e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802512:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802516:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802518:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80251a:	85 ed                	test   %ebp,%ebp
  80251c:	75 16                	jne    802534 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80251e:	39 f1                	cmp    %esi,%ecx
  802520:	0f 86 a6 00 00 00    	jbe    8025cc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802526:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802528:	89 d0                	mov    %edx,%eax
  80252a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80252c:	83 c4 20             	add    $0x20,%esp
  80252f:	5e                   	pop    %esi
  802530:	5f                   	pop    %edi
  802531:	5d                   	pop    %ebp
  802532:	c3                   	ret    
  802533:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802534:	39 f5                	cmp    %esi,%ebp
  802536:	0f 87 ac 00 00 00    	ja     8025e8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80253c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80253f:	83 f0 1f             	xor    $0x1f,%eax
  802542:	89 44 24 10          	mov    %eax,0x10(%esp)
  802546:	0f 84 a8 00 00 00    	je     8025f4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80254c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802550:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802552:	bf 20 00 00 00       	mov    $0x20,%edi
  802557:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80255b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80255f:	89 f9                	mov    %edi,%ecx
  802561:	d3 e8                	shr    %cl,%eax
  802563:	09 e8                	or     %ebp,%eax
  802565:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802569:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80256d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802571:	d3 e0                	shl    %cl,%eax
  802573:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802577:	89 f2                	mov    %esi,%edx
  802579:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80257b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80257f:	d3 e0                	shl    %cl,%eax
  802581:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802585:	8b 44 24 14          	mov    0x14(%esp),%eax
  802589:	89 f9                	mov    %edi,%ecx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80258f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802591:	89 f2                	mov    %esi,%edx
  802593:	f7 74 24 18          	divl   0x18(%esp)
  802597:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802599:	f7 64 24 0c          	mull   0xc(%esp)
  80259d:	89 c5                	mov    %eax,%ebp
  80259f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8025a1:	39 d6                	cmp    %edx,%esi
  8025a3:	72 67                	jb     80260c <__umoddi3+0x114>
  8025a5:	74 75                	je     80261c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8025a7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8025ab:	29 e8                	sub    %ebp,%eax
  8025ad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8025af:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025b3:	d3 e8                	shr    %cl,%eax
  8025b5:	89 f2                	mov    %esi,%edx
  8025b7:	89 f9                	mov    %edi,%ecx
  8025b9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8025bb:	09 d0                	or     %edx,%eax
  8025bd:	89 f2                	mov    %esi,%edx
  8025bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025c3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025c5:	83 c4 20             	add    $0x20,%esp
  8025c8:	5e                   	pop    %esi
  8025c9:	5f                   	pop    %edi
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8025cc:	85 c9                	test   %ecx,%ecx
  8025ce:	75 0b                	jne    8025db <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8025d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8025d5:	31 d2                	xor    %edx,%edx
  8025d7:	f7 f1                	div    %ecx
  8025d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8025db:	89 f0                	mov    %esi,%eax
  8025dd:	31 d2                	xor    %edx,%edx
  8025df:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025e1:	89 f8                	mov    %edi,%eax
  8025e3:	e9 3e ff ff ff       	jmp    802526 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8025e8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8025ea:	83 c4 20             	add    $0x20,%esp
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    
  8025f1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8025f4:	39 f5                	cmp    %esi,%ebp
  8025f6:	72 04                	jb     8025fc <__umoddi3+0x104>
  8025f8:	39 f9                	cmp    %edi,%ecx
  8025fa:	77 06                	ja     802602 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8025fc:	89 f2                	mov    %esi,%edx
  8025fe:	29 cf                	sub    %ecx,%edi
  802600:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802602:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802604:	83 c4 20             	add    $0x20,%esp
  802607:	5e                   	pop    %esi
  802608:	5f                   	pop    %edi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    
  80260b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80260c:	89 d1                	mov    %edx,%ecx
  80260e:	89 c5                	mov    %eax,%ebp
  802610:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802614:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802618:	eb 8d                	jmp    8025a7 <__umoddi3+0xaf>
  80261a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80261c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802620:	72 ea                	jb     80260c <__umoddi3+0x114>
  802622:	89 f1                	mov    %esi,%ecx
  802624:	eb 81                	jmp    8025a7 <__umoddi3+0xaf>
