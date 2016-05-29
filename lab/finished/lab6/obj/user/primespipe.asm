
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
  800055:	e8 f4 17 00 00       	call   80184e <readn>
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
  800073:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  80007a:	00 
  80007b:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800082:	00 
  800083:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  80008a:	e8 95 02 00 00       	call   800324 <_panic>

	cprintf("%d\n", p);
  80008f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	c7 04 24 e1 2b 80 00 	movl   $0x802be1,(%esp)
  80009d:	e8 7a 03 00 00       	call   80041c <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  8000a2:	89 3c 24             	mov    %edi,(%esp)
  8000a5:	e8 5b 23 00 00       	call   802405 <pipe>
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	79 20                	jns    8000d1 <primeproc+0x9d>
		panic("pipe: %e", i);
  8000b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b5:	c7 44 24 08 e5 2b 80 	movl   $0x802be5,0x8(%esp)
  8000bc:	00 
  8000bd:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  8000cc:	e8 53 02 00 00       	call   800324 <_panic>
	if ((id = fork()) < 0)
  8000d1:	e8 dd 10 00 00       	call   8011b3 <fork>
  8000d6:	85 c0                	test   %eax,%eax
  8000d8:	79 20                	jns    8000fa <primeproc+0xc6>
		panic("fork: %e", id);
  8000da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000de:	c7 44 24 08 ee 2b 80 	movl   $0x802bee,0x8(%esp)
  8000e5:	00 
  8000e6:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  8000ed:	00 
  8000ee:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  8000f5:	e8 2a 02 00 00       	call   800324 <_panic>
	if (id == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1b                	jne    800119 <primeproc+0xe5>
		close(fd);
  8000fe:	89 1c 24             	mov    %ebx,(%esp)
  800101:	e8 54 15 00 00       	call   80165a <close>
		close(pfd[1]);
  800106:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 49 15 00 00       	call   80165a <close>
		fd = pfd[0];
  800111:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  800114:	e9 2d ff ff ff       	jmp    800046 <primeproc+0x12>
	}

	close(pfd[0]);
  800119:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 36 15 00 00       	call   80165a <close>
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
  800139:	e8 10 17 00 00       	call   80184e <readn>
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
  800162:	c7 44 24 08 f7 2b 80 	movl   $0x802bf7,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  800179:	e8 a6 01 00 00       	call   800324 <_panic>
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
  800198:	e8 fc 16 00 00       	call   801899 <write>
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
  8001bd:	c7 44 24 08 13 2c 80 	movl   $0x802c13,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  8001d4:	e8 4b 01 00 00       	call   800324 <_panic>

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
  8001e0:	c7 05 00 40 80 00 2d 	movl   $0x802c2d,0x804000
  8001e7:	2c 80 00 

	if ((i=pipe(p)) < 0)
  8001ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	e8 10 22 00 00       	call   802405 <pipe>
  8001f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	79 20                	jns    80021c <umain+0x43>
		panic("pipe: %e", i);
  8001fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800200:	c7 44 24 08 e5 2b 80 	movl   $0x802be5,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  800217:	e8 08 01 00 00       	call   800324 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80021c:	e8 92 0f 00 00       	call   8011b3 <fork>
  800221:	85 c0                	test   %eax,%eax
  800223:	79 20                	jns    800245 <umain+0x6c>
		panic("fork: %e", id);
  800225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800229:	c7 44 24 08 ee 2b 80 	movl   $0x802bee,0x8(%esp)
  800230:	00 
  800231:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  800240:	e8 df 00 00 00       	call   800324 <_panic>

	if (id == 0) {
  800245:	85 c0                	test   %eax,%eax
  800247:	75 16                	jne    80025f <umain+0x86>
		close(p[1]);
  800249:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 06 14 00 00       	call   80165a <close>
		primeproc(p[0]);
  800254:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 d5 fd ff ff       	call   800034 <primeproc>
	}

	close(p[0]);
  80025f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 f0 13 00 00       	call   80165a <close>

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
  800286:	e8 0e 16 00 00       	call   801899 <write>
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
  8002a4:	c7 44 24 08 38 2c 80 	movl   $0x802c38,0x8(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8002b3:	00 
  8002b4:	c7 04 24 cf 2b 80 00 	movl   $0x802bcf,(%esp)
  8002bb:	e8 64 00 00 00       	call   800324 <_panic>
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
  8002d6:	e8 a0 0a 00 00       	call   800d7b <sys_getenvid>
  8002db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e0:	c1 e0 07             	shl    $0x7,%eax
  8002e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e8:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ed:	85 f6                	test   %esi,%esi
  8002ef:	7e 07                	jle    8002f8 <libmain+0x30>
		binaryname = argv[0];
  8002f1:	8b 03                	mov    (%ebx),%eax
  8002f3:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8002f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002fc:	89 34 24             	mov    %esi,(%esp)
  8002ff:	e8 d5 fe ff ff       	call   8001d9 <umain>

	// exit gracefully
	exit();
  800304:	e8 07 00 00 00       	call   800310 <exit>
}
  800309:	83 c4 10             	add    $0x10,%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5d                   	pop    %ebp
  80030f:	c3                   	ret    

00800310 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800316:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80031d:	e8 07 0a 00 00       	call   800d29 <sys_env_destroy>
}
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80032c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800335:	e8 41 0a 00 00       	call   800d7b <sys_getenvid>
  80033a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800341:	8b 55 08             	mov    0x8(%ebp),%edx
  800344:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800348:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80034c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800350:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  800357:	e8 c0 00 00 00       	call   80041c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	8b 45 10             	mov    0x10(%ebp),%eax
  800363:	89 04 24             	mov    %eax,(%esp)
  800366:	e8 50 00 00 00       	call   8003bb <vcprintf>
	cprintf("\n");
  80036b:	c7 04 24 e3 2b 80 00 	movl   $0x802be3,(%esp)
  800372:	e8 a5 00 00 00       	call   80041c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800377:	cc                   	int3   
  800378:	eb fd                	jmp    800377 <_panic+0x53>
	...

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 14             	sub    $0x14,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 03                	mov    (%ebx),%eax
  800388:	8b 55 08             	mov    0x8(%ebp),%edx
  80038b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80038f:	40                   	inc    %eax
  800390:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800392:	3d ff 00 00 00       	cmp    $0xff,%eax
  800397:	75 19                	jne    8003b2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800399:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003a0:	00 
  8003a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 40 09 00 00       	call   800cec <sys_cputs>
		b->idx = 0;
  8003ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003b2:	ff 43 04             	incl   0x4(%ebx)
}
  8003b5:	83 c4 14             	add    $0x14,%esp
  8003b8:	5b                   	pop    %ebx
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cb:	00 00 00 
	b.cnt = 0;
  8003ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	c7 04 24 7c 03 80 00 	movl   $0x80037c,(%esp)
  8003f7:	e8 82 01 00 00       	call   80057e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800402:	89 44 24 04          	mov    %eax,0x4(%esp)
  800406:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 d8 08 00 00       	call   800cec <sys_cputs>

	return b.cnt;
}
  800414:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041a:	c9                   	leave  
  80041b:	c3                   	ret    

0080041c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800422:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800425:	89 44 24 04          	mov    %eax,0x4(%esp)
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	89 04 24             	mov    %eax,(%esp)
  80042f:	e8 87 ff ff ff       	call   8003bb <vcprintf>
	va_end(ap);

	return cnt;
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    
	...

00800438 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	57                   	push   %edi
  80043c:	56                   	push   %esi
  80043d:	53                   	push   %ebx
  80043e:	83 ec 3c             	sub    $0x3c,%esp
  800441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800444:	89 d7                	mov    %edx,%edi
  800446:	8b 45 08             	mov    0x8(%ebp),%eax
  800449:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800452:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800455:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800458:	85 c0                	test   %eax,%eax
  80045a:	75 08                	jne    800464 <printnum+0x2c>
  80045c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80045f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800462:	77 57                	ja     8004bb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800464:	89 74 24 10          	mov    %esi,0x10(%esp)
  800468:	4b                   	dec    %ebx
  800469:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80046d:	8b 45 10             	mov    0x10(%ebp),%eax
  800470:	89 44 24 08          	mov    %eax,0x8(%esp)
  800474:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800478:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80047c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800483:	00 
  800484:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800487:	89 04 24             	mov    %eax,(%esp)
  80048a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	e8 9e 24 00 00       	call   802934 <__udivdi3>
  800496:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80049a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80049e:	89 04 24             	mov    %eax,(%esp)
  8004a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004a5:	89 fa                	mov    %edi,%edx
  8004a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004aa:	e8 89 ff ff ff       	call   800438 <printnum>
  8004af:	eb 0f                	jmp    8004c0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b5:	89 34 24             	mov    %esi,(%esp)
  8004b8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004bb:	4b                   	dec    %ebx
  8004bc:	85 db                	test   %ebx,%ebx
  8004be:	7f f1                	jg     8004b1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8004cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004d6:	00 
  8004d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e4:	e8 6b 25 00 00       	call   802a54 <__umoddi3>
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	0f be 80 7f 2c 80 00 	movsbl 0x802c7f(%eax),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004fa:	83 c4 3c             	add    $0x3c,%esp
  8004fd:	5b                   	pop    %ebx
  8004fe:	5e                   	pop    %esi
  8004ff:	5f                   	pop    %edi
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800505:	83 fa 01             	cmp    $0x1,%edx
  800508:	7e 0e                	jle    800518 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80050f:	89 08                	mov    %ecx,(%eax)
  800511:	8b 02                	mov    (%edx),%eax
  800513:	8b 52 04             	mov    0x4(%edx),%edx
  800516:	eb 22                	jmp    80053a <getuint+0x38>
	else if (lflag)
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 10                	je     80052c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80051c:	8b 10                	mov    (%eax),%edx
  80051e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800521:	89 08                	mov    %ecx,(%eax)
  800523:	8b 02                	mov    (%edx),%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	eb 0e                	jmp    80053a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80052c:	8b 10                	mov    (%eax),%edx
  80052e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800531:	89 08                	mov    %ecx,(%eax)
  800533:	8b 02                	mov    (%edx),%eax
  800535:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800542:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800545:	8b 10                	mov    (%eax),%edx
  800547:	3b 50 04             	cmp    0x4(%eax),%edx
  80054a:	73 08                	jae    800554 <sprintputch+0x18>
		*b->buf++ = ch;
  80054c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80054f:	88 0a                	mov    %cl,(%edx)
  800551:	42                   	inc    %edx
  800552:	89 10                	mov    %edx,(%eax)
}
  800554:	5d                   	pop    %ebp
  800555:	c3                   	ret    

00800556 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80055c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80055f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800563:	8b 45 10             	mov    0x10(%ebp),%eax
  800566:	89 44 24 08          	mov    %eax,0x8(%esp)
  80056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800571:	8b 45 08             	mov    0x8(%ebp),%eax
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	e8 02 00 00 00       	call   80057e <vprintfmt>
	va_end(ap);
}
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	57                   	push   %edi
  800582:	56                   	push   %esi
  800583:	53                   	push   %ebx
  800584:	83 ec 4c             	sub    $0x4c,%esp
  800587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058a:	8b 75 10             	mov    0x10(%ebp),%esi
  80058d:	eb 12                	jmp    8005a1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80058f:	85 c0                	test   %eax,%eax
  800591:	0f 84 6b 03 00 00    	je     800902 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800597:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059b:	89 04 24             	mov    %eax,(%esp)
  80059e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a1:	0f b6 06             	movzbl (%esi),%eax
  8005a4:	46                   	inc    %esi
  8005a5:	83 f8 25             	cmp    $0x25,%eax
  8005a8:	75 e5                	jne    80058f <vprintfmt+0x11>
  8005aa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005ba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c6:	eb 26                	jmp    8005ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005cb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005cf:	eb 1d                	jmp    8005ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005d4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005d8:	eb 14                	jmp    8005ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005e4:	eb 08                	jmp    8005ee <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	0f b6 06             	movzbl (%esi),%eax
  8005f1:	8d 56 01             	lea    0x1(%esi),%edx
  8005f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f7:	8a 16                	mov    (%esi),%dl
  8005f9:	83 ea 23             	sub    $0x23,%edx
  8005fc:	80 fa 55             	cmp    $0x55,%dl
  8005ff:	0f 87 e1 02 00 00    	ja     8008e6 <vprintfmt+0x368>
  800605:	0f b6 d2             	movzbl %dl,%edx
  800608:	ff 24 95 c0 2d 80 00 	jmp    *0x802dc0(,%edx,4)
  80060f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800612:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800617:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80061a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80061e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800621:	8d 50 d0             	lea    -0x30(%eax),%edx
  800624:	83 fa 09             	cmp    $0x9,%edx
  800627:	77 2a                	ja     800653 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800629:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80062a:	eb eb                	jmp    800617 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80063a:	eb 17                	jmp    800653 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80063c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800640:	78 98                	js     8005da <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800645:	eb a7                	jmp    8005ee <vprintfmt+0x70>
  800647:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80064a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800651:	eb 9b                	jmp    8005ee <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800653:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800657:	79 95                	jns    8005ee <vprintfmt+0x70>
  800659:	eb 8b                	jmp    8005e6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80065b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80065f:	eb 8d                	jmp    8005ee <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)
  80066a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	89 04 24             	mov    %eax,(%esp)
  800673:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800679:	e9 23 ff ff ff       	jmp    8005a1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	85 c0                	test   %eax,%eax
  80068b:	79 02                	jns    80068f <vprintfmt+0x111>
  80068d:	f7 d8                	neg    %eax
  80068f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800691:	83 f8 11             	cmp    $0x11,%eax
  800694:	7f 0b                	jg     8006a1 <vprintfmt+0x123>
  800696:	8b 04 85 20 2f 80 00 	mov    0x802f20(,%eax,4),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	75 23                	jne    8006c4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006a1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006a5:	c7 44 24 08 97 2c 80 	movl   $0x802c97,0x8(%esp)
  8006ac:	00 
  8006ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	89 04 24             	mov    %eax,(%esp)
  8006b7:	e8 9a fe ff ff       	call   800556 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006bf:	e9 dd fe ff ff       	jmp    8005a1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c8:	c7 44 24 08 4d 31 80 	movl   $0x80314d,0x8(%esp)
  8006cf:	00 
  8006d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d7:	89 14 24             	mov    %edx,(%esp)
  8006da:	e8 77 fe ff ff       	call   800556 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e2:	e9 ba fe ff ff       	jmp    8005a1 <vprintfmt+0x23>
  8006e7:	89 f9                	mov    %edi,%ecx
  8006e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 30                	mov    (%eax),%esi
  8006fa:	85 f6                	test   %esi,%esi
  8006fc:	75 05                	jne    800703 <vprintfmt+0x185>
				p = "(null)";
  8006fe:	be 90 2c 80 00       	mov    $0x802c90,%esi
			if (width > 0 && padc != '-')
  800703:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800707:	0f 8e 84 00 00 00    	jle    800791 <vprintfmt+0x213>
  80070d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800711:	74 7e                	je     800791 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800713:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800717:	89 34 24             	mov    %esi,(%esp)
  80071a:	e8 8b 02 00 00       	call   8009aa <strnlen>
  80071f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800722:	29 c2                	sub    %eax,%edx
  800724:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800727:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80072b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80072e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800731:	89 de                	mov    %ebx,%esi
  800733:	89 d3                	mov    %edx,%ebx
  800735:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800737:	eb 0b                	jmp    800744 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800739:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073d:	89 3c 24             	mov    %edi,(%esp)
  800740:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800743:	4b                   	dec    %ebx
  800744:	85 db                	test   %ebx,%ebx
  800746:	7f f1                	jg     800739 <vprintfmt+0x1bb>
  800748:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80074b:	89 f3                	mov    %esi,%ebx
  80074d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800750:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800753:	85 c0                	test   %eax,%eax
  800755:	79 05                	jns    80075c <vprintfmt+0x1de>
  800757:	b8 00 00 00 00       	mov    $0x0,%eax
  80075c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80075f:	29 c2                	sub    %eax,%edx
  800761:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800764:	eb 2b                	jmp    800791 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800766:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80076a:	74 18                	je     800784 <vprintfmt+0x206>
  80076c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80076f:	83 fa 5e             	cmp    $0x5e,%edx
  800772:	76 10                	jbe    800784 <vprintfmt+0x206>
					putch('?', putdat);
  800774:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800778:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80077f:	ff 55 08             	call   *0x8(%ebp)
  800782:	eb 0a                	jmp    80078e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800784:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80078e:	ff 4d e4             	decl   -0x1c(%ebp)
  800791:	0f be 06             	movsbl (%esi),%eax
  800794:	46                   	inc    %esi
  800795:	85 c0                	test   %eax,%eax
  800797:	74 21                	je     8007ba <vprintfmt+0x23c>
  800799:	85 ff                	test   %edi,%edi
  80079b:	78 c9                	js     800766 <vprintfmt+0x1e8>
  80079d:	4f                   	dec    %edi
  80079e:	79 c6                	jns    800766 <vprintfmt+0x1e8>
  8007a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a3:	89 de                	mov    %ebx,%esi
  8007a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007a8:	eb 18                	jmp    8007c2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007b5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b7:	4b                   	dec    %ebx
  8007b8:	eb 08                	jmp    8007c2 <vprintfmt+0x244>
  8007ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007bd:	89 de                	mov    %ebx,%esi
  8007bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007c2:	85 db                	test   %ebx,%ebx
  8007c4:	7f e4                	jg     8007aa <vprintfmt+0x22c>
  8007c6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007c9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007ce:	e9 ce fd ff ff       	jmp    8005a1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d3:	83 f9 01             	cmp    $0x1,%ecx
  8007d6:	7e 10                	jle    8007e8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 50 08             	lea    0x8(%eax),%edx
  8007de:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e1:	8b 30                	mov    (%eax),%esi
  8007e3:	8b 78 04             	mov    0x4(%eax),%edi
  8007e6:	eb 26                	jmp    80080e <vprintfmt+0x290>
	else if (lflag)
  8007e8:	85 c9                	test   %ecx,%ecx
  8007ea:	74 12                	je     8007fe <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 04             	lea    0x4(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	8b 30                	mov    (%eax),%esi
  8007f7:	89 f7                	mov    %esi,%edi
  8007f9:	c1 ff 1f             	sar    $0x1f,%edi
  8007fc:	eb 10                	jmp    80080e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 50 04             	lea    0x4(%eax),%edx
  800804:	89 55 14             	mov    %edx,0x14(%ebp)
  800807:	8b 30                	mov    (%eax),%esi
  800809:	89 f7                	mov    %esi,%edi
  80080b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080e:	85 ff                	test   %edi,%edi
  800810:	78 0a                	js     80081c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800812:	b8 0a 00 00 00       	mov    $0xa,%eax
  800817:	e9 8c 00 00 00       	jmp    8008a8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80081c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800820:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800827:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80082a:	f7 de                	neg    %esi
  80082c:	83 d7 00             	adc    $0x0,%edi
  80082f:	f7 df                	neg    %edi
			}
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
  800836:	eb 70                	jmp    8008a8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800838:	89 ca                	mov    %ecx,%edx
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 c0 fc ff ff       	call   800502 <getuint>
  800842:	89 c6                	mov    %eax,%esi
  800844:	89 d7                	mov    %edx,%edi
			base = 10;
  800846:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80084b:	eb 5b                	jmp    8008a8 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  80084d:	89 ca                	mov    %ecx,%edx
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
  800852:	e8 ab fc ff ff       	call   800502 <getuint>
  800857:	89 c6                	mov    %eax,%esi
  800859:	89 d7                	mov    %edx,%edi
			base = 8;
  80085b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800860:	eb 46                	jmp    8008a8 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800862:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800866:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80086d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800870:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800874:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80087b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 50 04             	lea    0x4(%eax),%edx
  800884:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800887:	8b 30                	mov    (%eax),%esi
  800889:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80088e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800893:	eb 13                	jmp    8008a8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800895:	89 ca                	mov    %ecx,%edx
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
  80089a:	e8 63 fc ff ff       	call   800502 <getuint>
  80089f:	89 c6                	mov    %eax,%esi
  8008a1:	89 d7                	mov    %edx,%edi
			base = 16;
  8008a3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bb:	89 34 24             	mov    %esi,(%esp)
  8008be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c2:	89 da                	mov    %ebx,%edx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	e8 6c fb ff ff       	call   800438 <printnum>
			break;
  8008cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008cf:	e9 cd fc ff ff       	jmp    8005a1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d8:	89 04 24             	mov    %eax,(%esp)
  8008db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e1:	e9 bb fc ff ff       	jmp    8005a1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f4:	eb 01                	jmp    8008f7 <vprintfmt+0x379>
  8008f6:	4e                   	dec    %esi
  8008f7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008fb:	75 f9                	jne    8008f6 <vprintfmt+0x378>
  8008fd:	e9 9f fc ff ff       	jmp    8005a1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800902:	83 c4 4c             	add    $0x4c,%esp
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 28             	sub    $0x28,%esp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800916:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800919:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800927:	85 c0                	test   %eax,%eax
  800929:	74 30                	je     80095b <vsnprintf+0x51>
  80092b:	85 d2                	test   %edx,%edx
  80092d:	7e 33                	jle    800962 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800936:	8b 45 10             	mov    0x10(%ebp),%eax
  800939:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800940:	89 44 24 04          	mov    %eax,0x4(%esp)
  800944:	c7 04 24 3c 05 80 00 	movl   $0x80053c,(%esp)
  80094b:	e8 2e fc ff ff       	call   80057e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800950:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800953:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800956:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800959:	eb 0c                	jmp    800967 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800960:	eb 05                	jmp    800967 <vsnprintf+0x5d>
  800962:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800972:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800976:	8b 45 10             	mov    0x10(%ebp),%eax
  800979:	89 44 24 08          	mov    %eax,0x8(%esp)
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	89 44 24 04          	mov    %eax,0x4(%esp)
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	89 04 24             	mov    %eax,(%esp)
  80098a:	e8 7b ff ff ff       	call   80090a <vsnprintf>
	va_end(ap);

	return rc;
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    
  800991:	00 00                	add    %al,(%eax)
	...

00800994 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
  80099f:	eb 01                	jmp    8009a2 <strlen+0xe>
		n++;
  8009a1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a6:	75 f9                	jne    8009a1 <strlen+0xd>
		n++;
	return n;
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b8:	eb 01                	jmp    8009bb <strnlen+0x11>
		n++;
  8009ba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bb:	39 d0                	cmp    %edx,%eax
  8009bd:	74 06                	je     8009c5 <strnlen+0x1b>
  8009bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009c3:	75 f5                	jne    8009ba <strnlen+0x10>
		n++;
	return n;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8009d9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009dc:	42                   	inc    %edx
  8009dd:	84 c9                	test   %cl,%cl
  8009df:	75 f5                	jne    8009d6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	53                   	push   %ebx
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ee:	89 1c 24             	mov    %ebx,(%esp)
  8009f1:	e8 9e ff ff ff       	call   800994 <strlen>
	strcpy(dst + len, src);
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009fd:	01 d8                	add    %ebx,%eax
  8009ff:	89 04 24             	mov    %eax,(%esp)
  800a02:	e8 c0 ff ff ff       	call   8009c7 <strcpy>
	return dst;
}
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	83 c4 08             	add    $0x8,%esp
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a22:	eb 0c                	jmp    800a30 <strncpy+0x21>
		*dst++ = *src;
  800a24:	8a 1a                	mov    (%edx),%bl
  800a26:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a29:	80 3a 01             	cmpb   $0x1,(%edx)
  800a2c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2f:	41                   	inc    %ecx
  800a30:	39 f1                	cmp    %esi,%ecx
  800a32:	75 f0                	jne    800a24 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a46:	85 d2                	test   %edx,%edx
  800a48:	75 0a                	jne    800a54 <strlcpy+0x1c>
  800a4a:	89 f0                	mov    %esi,%eax
  800a4c:	eb 1a                	jmp    800a68 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a4e:	88 18                	mov    %bl,(%eax)
  800a50:	40                   	inc    %eax
  800a51:	41                   	inc    %ecx
  800a52:	eb 02                	jmp    800a56 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a54:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a56:	4a                   	dec    %edx
  800a57:	74 0a                	je     800a63 <strlcpy+0x2b>
  800a59:	8a 19                	mov    (%ecx),%bl
  800a5b:	84 db                	test   %bl,%bl
  800a5d:	75 ef                	jne    800a4e <strlcpy+0x16>
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	eb 02                	jmp    800a65 <strlcpy+0x2d>
  800a63:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a65:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a68:	29 f0                	sub    %esi,%eax
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a77:	eb 02                	jmp    800a7b <strcmp+0xd>
		p++, q++;
  800a79:	41                   	inc    %ecx
  800a7a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a7b:	8a 01                	mov    (%ecx),%al
  800a7d:	84 c0                	test   %al,%al
  800a7f:	74 04                	je     800a85 <strcmp+0x17>
  800a81:	3a 02                	cmp    (%edx),%al
  800a83:	74 f4                	je     800a79 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a85:	0f b6 c0             	movzbl %al,%eax
  800a88:	0f b6 12             	movzbl (%edx),%edx
  800a8b:	29 d0                	sub    %edx,%eax
}
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a99:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a9c:	eb 03                	jmp    800aa1 <strncmp+0x12>
		n--, p++, q++;
  800a9e:	4a                   	dec    %edx
  800a9f:	40                   	inc    %eax
  800aa0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa1:	85 d2                	test   %edx,%edx
  800aa3:	74 14                	je     800ab9 <strncmp+0x2a>
  800aa5:	8a 18                	mov    (%eax),%bl
  800aa7:	84 db                	test   %bl,%bl
  800aa9:	74 04                	je     800aaf <strncmp+0x20>
  800aab:	3a 19                	cmp    (%ecx),%bl
  800aad:	74 ef                	je     800a9e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaf:	0f b6 00             	movzbl (%eax),%eax
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	29 d0                	sub    %edx,%eax
  800ab7:	eb 05                	jmp    800abe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abe:	5b                   	pop    %ebx
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800aca:	eb 05                	jmp    800ad1 <strchr+0x10>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	74 0c                	je     800adc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad0:	40                   	inc    %eax
  800ad1:	8a 10                	mov    (%eax),%dl
  800ad3:	84 d2                	test   %dl,%dl
  800ad5:	75 f5                	jne    800acc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800ae7:	eb 05                	jmp    800aee <strfind+0x10>
		if (*s == c)
  800ae9:	38 ca                	cmp    %cl,%dl
  800aeb:	74 07                	je     800af4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aed:	40                   	inc    %eax
  800aee:	8a 10                	mov    (%eax),%dl
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 f5                	jne    800ae9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b05:	85 c9                	test   %ecx,%ecx
  800b07:	74 30                	je     800b39 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0f:	75 25                	jne    800b36 <memset+0x40>
  800b11:	f6 c1 03             	test   $0x3,%cl
  800b14:	75 20                	jne    800b36 <memset+0x40>
		c &= 0xFF;
  800b16:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b19:	89 d3                	mov    %edx,%ebx
  800b1b:	c1 e3 08             	shl    $0x8,%ebx
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	c1 e6 18             	shl    $0x18,%esi
  800b23:	89 d0                	mov    %edx,%eax
  800b25:	c1 e0 10             	shl    $0x10,%eax
  800b28:	09 f0                	or     %esi,%eax
  800b2a:	09 d0                	or     %edx,%eax
  800b2c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b31:	fc                   	cld    
  800b32:	f3 ab                	rep stos %eax,%es:(%edi)
  800b34:	eb 03                	jmp    800b39 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b36:	fc                   	cld    
  800b37:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b39:	89 f8                	mov    %edi,%eax
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b4e:	39 c6                	cmp    %eax,%esi
  800b50:	73 34                	jae    800b86 <memmove+0x46>
  800b52:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b55:	39 d0                	cmp    %edx,%eax
  800b57:	73 2d                	jae    800b86 <memmove+0x46>
		s += n;
		d += n;
  800b59:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5c:	f6 c2 03             	test   $0x3,%dl
  800b5f:	75 1b                	jne    800b7c <memmove+0x3c>
  800b61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b67:	75 13                	jne    800b7c <memmove+0x3c>
  800b69:	f6 c1 03             	test   $0x3,%cl
  800b6c:	75 0e                	jne    800b7c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b6e:	83 ef 04             	sub    $0x4,%edi
  800b71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b74:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b77:	fd                   	std    
  800b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7a:	eb 07                	jmp    800b83 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7c:	4f                   	dec    %edi
  800b7d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b80:	fd                   	std    
  800b81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b83:	fc                   	cld    
  800b84:	eb 20                	jmp    800ba6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8c:	75 13                	jne    800ba1 <memmove+0x61>
  800b8e:	a8 03                	test   $0x3,%al
  800b90:	75 0f                	jne    800ba1 <memmove+0x61>
  800b92:	f6 c1 03             	test   $0x3,%cl
  800b95:	75 0a                	jne    800ba1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b97:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	fc                   	cld    
  800b9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9f:	eb 05                	jmp    800ba6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	89 04 24             	mov    %eax,(%esp)
  800bc4:	e8 77 ff ff ff       	call   800b40 <memmove>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bda:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdf:	eb 16                	jmp    800bf7 <memcmp+0x2c>
		if (*s1 != *s2)
  800be1:	8a 04 17             	mov    (%edi,%edx,1),%al
  800be4:	42                   	inc    %edx
  800be5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800be9:	38 c8                	cmp    %cl,%al
  800beb:	74 0a                	je     800bf7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800bed:	0f b6 c0             	movzbl %al,%eax
  800bf0:	0f b6 c9             	movzbl %cl,%ecx
  800bf3:	29 c8                	sub    %ecx,%eax
  800bf5:	eb 09                	jmp    800c00 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf7:	39 da                	cmp    %ebx,%edx
  800bf9:	75 e6                	jne    800be1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c0e:	89 c2                	mov    %eax,%edx
  800c10:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c13:	eb 05                	jmp    800c1a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c15:	38 08                	cmp    %cl,(%eax)
  800c17:	74 05                	je     800c1e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c19:	40                   	inc    %eax
  800c1a:	39 d0                	cmp    %edx,%eax
  800c1c:	72 f7                	jb     800c15 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2c:	eb 01                	jmp    800c2f <strtol+0xf>
		s++;
  800c2e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2f:	8a 02                	mov    (%edx),%al
  800c31:	3c 20                	cmp    $0x20,%al
  800c33:	74 f9                	je     800c2e <strtol+0xe>
  800c35:	3c 09                	cmp    $0x9,%al
  800c37:	74 f5                	je     800c2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c39:	3c 2b                	cmp    $0x2b,%al
  800c3b:	75 08                	jne    800c45 <strtol+0x25>
		s++;
  800c3d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c43:	eb 13                	jmp    800c58 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c45:	3c 2d                	cmp    $0x2d,%al
  800c47:	75 0a                	jne    800c53 <strtol+0x33>
		s++, neg = 1;
  800c49:	8d 52 01             	lea    0x1(%edx),%edx
  800c4c:	bf 01 00 00 00       	mov    $0x1,%edi
  800c51:	eb 05                	jmp    800c58 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c58:	85 db                	test   %ebx,%ebx
  800c5a:	74 05                	je     800c61 <strtol+0x41>
  800c5c:	83 fb 10             	cmp    $0x10,%ebx
  800c5f:	75 28                	jne    800c89 <strtol+0x69>
  800c61:	8a 02                	mov    (%edx),%al
  800c63:	3c 30                	cmp    $0x30,%al
  800c65:	75 10                	jne    800c77 <strtol+0x57>
  800c67:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c6b:	75 0a                	jne    800c77 <strtol+0x57>
		s += 2, base = 16;
  800c6d:	83 c2 02             	add    $0x2,%edx
  800c70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c75:	eb 12                	jmp    800c89 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c77:	85 db                	test   %ebx,%ebx
  800c79:	75 0e                	jne    800c89 <strtol+0x69>
  800c7b:	3c 30                	cmp    $0x30,%al
  800c7d:	75 05                	jne    800c84 <strtol+0x64>
		s++, base = 8;
  800c7f:	42                   	inc    %edx
  800c80:	b3 08                	mov    $0x8,%bl
  800c82:	eb 05                	jmp    800c89 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c84:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c90:	8a 0a                	mov    (%edx),%cl
  800c92:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c95:	80 fb 09             	cmp    $0x9,%bl
  800c98:	77 08                	ja     800ca2 <strtol+0x82>
			dig = *s - '0';
  800c9a:	0f be c9             	movsbl %cl,%ecx
  800c9d:	83 e9 30             	sub    $0x30,%ecx
  800ca0:	eb 1e                	jmp    800cc0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ca2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ca5:	80 fb 19             	cmp    $0x19,%bl
  800ca8:	77 08                	ja     800cb2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800caa:	0f be c9             	movsbl %cl,%ecx
  800cad:	83 e9 57             	sub    $0x57,%ecx
  800cb0:	eb 0e                	jmp    800cc0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800cb2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800cb5:	80 fb 19             	cmp    $0x19,%bl
  800cb8:	77 12                	ja     800ccc <strtol+0xac>
			dig = *s - 'A' + 10;
  800cba:	0f be c9             	movsbl %cl,%ecx
  800cbd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cc0:	39 f1                	cmp    %esi,%ecx
  800cc2:	7d 0c                	jge    800cd0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800cc4:	42                   	inc    %edx
  800cc5:	0f af c6             	imul   %esi,%eax
  800cc8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800cca:	eb c4                	jmp    800c90 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ccc:	89 c1                	mov    %eax,%ecx
  800cce:	eb 02                	jmp    800cd2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd6:	74 05                	je     800cdd <strtol+0xbd>
		*endptr = (char *) s;
  800cd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cdb:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cdd:	85 ff                	test   %edi,%edi
  800cdf:	74 04                	je     800ce5 <strtol+0xc5>
  800ce1:	89 c8                	mov    %ecx,%eax
  800ce3:	f7 d8                	neg    %eax
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    
	...

00800cec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 c3                	mov    %eax,%ebx
  800cff:	89 c7                	mov    %eax,%edi
  800d01:	89 c6                	mov    %eax,%esi
  800d03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1a:	89 d1                	mov    %edx,%ecx
  800d1c:	89 d3                	mov    %edx,%ebx
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 d6                	mov    %edx,%esi
  800d22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 03 00 00 00       	mov    $0x3,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 28                	jle    800d73 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d4f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d56:	00 
  800d57:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d66:	00 
  800d67:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800d6e:	e8 b1 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d73:	83 c4 2c             	add    $0x2c,%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	ba 00 00 00 00       	mov    $0x0,%edx
  800d86:	b8 02 00 00 00       	mov    $0x2,%eax
  800d8b:	89 d1                	mov    %edx,%ecx
  800d8d:	89 d3                	mov    %edx,%ebx
  800d8f:	89 d7                	mov    %edx,%edi
  800d91:	89 d6                	mov    %edx,%esi
  800d93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_yield>:

void
sys_yield(void)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800daa:	89 d1                	mov    %edx,%ecx
  800dac:	89 d3                	mov    %edx,%ebx
  800dae:	89 d7                	mov    %edx,%edi
  800db0:	89 d6                	mov    %edx,%esi
  800db2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	57                   	push   %edi
  800dbd:	56                   	push   %esi
  800dbe:	53                   	push   %ebx
  800dbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc2:	be 00 00 00 00       	mov    $0x0,%esi
  800dc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd5:	89 f7                	mov    %esi,%edi
  800dd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7e 28                	jle    800e05 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de8:	00 
  800de9:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800df0:	00 
  800df1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df8:	00 
  800df9:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800e00:	e8 1f f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e05:	83 c4 2c             	add    $0x2c,%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	b8 05 00 00 00       	mov    $0x5,%eax
  800e1b:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7e 28                	jle    800e58 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e34:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e3b:	00 
  800e3c:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800e43:	00 
  800e44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4b:	00 
  800e4c:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800e53:	e8 cc f4 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e58:	83 c4 2c             	add    $0x2c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	89 df                	mov    %ebx,%edi
  800e7b:	89 de                	mov    %ebx,%esi
  800e7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	7e 28                	jle    800eab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e87:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800ea6:	e8 79 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eab:	83 c4 2c             	add    $0x2c,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	89 df                	mov    %ebx,%edi
  800ece:	89 de                	mov    %ebx,%esi
  800ed0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	7e 28                	jle    800efe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eda:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef1:	00 
  800ef2:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800ef9:	e8 26 f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800efe:	83 c4 2c             	add    $0x2c,%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f14:	b8 09 00 00 00       	mov    $0x9,%eax
  800f19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	89 df                	mov    %ebx,%edi
  800f21:	89 de                	mov    %ebx,%esi
  800f23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f25:	85 c0                	test   %eax,%eax
  800f27:	7e 28                	jle    800f51 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f34:	00 
  800f35:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f44:	00 
  800f45:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800f4c:	e8 d3 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f51:	83 c4 2c             	add    $0x2c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f72:	89 df                	mov    %ebx,%edi
  800f74:	89 de                	mov    %ebx,%esi
  800f76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	7e 28                	jle    800fa4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f80:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f87:	00 
  800f88:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  800f8f:	00 
  800f90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f97:	00 
  800f98:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  800f9f:	e8 80 f3 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fa4:	83 c4 2c             	add    $0x2c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb2:	be 00 00 00 00       	mov    $0x0,%esi
  800fb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fca:	5b                   	pop    %ebx
  800fcb:	5e                   	pop    %esi
  800fcc:	5f                   	pop    %edi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	57                   	push   %edi
  800fd3:	56                   	push   %esi
  800fd4:	53                   	push   %ebx
  800fd5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fe2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe5:	89 cb                	mov    %ecx,%ebx
  800fe7:	89 cf                	mov    %ecx,%edi
  800fe9:	89 ce                	mov    %ecx,%esi
  800feb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	7e 28                	jle    801019 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 08 87 2f 80 	movl   $0x802f87,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  801014:	e8 0b f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801019:	83 c4 2c             	add    $0x2c,%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801027:	ba 00 00 00 00       	mov    $0x0,%edx
  80102c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801031:	89 d1                	mov    %edx,%ecx
  801033:	89 d3                	mov    %edx,%ebx
  801035:	89 d7                	mov    %edx,%edi
  801037:	89 d6                	mov    %edx,%esi
  801039:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5f                   	pop    %edi
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104b:	b8 10 00 00 00       	mov    $0x10,%eax
  801050:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801053:	8b 55 08             	mov    0x8(%ebp),%edx
  801056:	89 df                	mov    %ebx,%edi
  801058:	89 de                	mov    %ebx,%esi
  80105a:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	57                   	push   %edi
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801067:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106c:	b8 0f 00 00 00       	mov    $0xf,%eax
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	8b 55 08             	mov    0x8(%ebp),%edx
  801077:	89 df                	mov    %ebx,%edi
  801079:	89 de                	mov    %ebx,%esi
  80107b:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801088:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108d:	b8 11 00 00 00       	mov    $0x11,%eax
  801092:	8b 55 08             	mov    0x8(%ebp),%edx
  801095:	89 cb                	mov    %ecx,%ebx
  801097:	89 cf                	mov    %ecx,%edi
  801099:	89 ce                	mov    %ecx,%esi
  80109b:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    
	...

008010a4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 24             	sub    $0x24,%esp
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8010ae:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  8010b0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8010b4:	75 20                	jne    8010d6 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  8010b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010ba:	c7 44 24 08 b4 2f 80 	movl   $0x802fb4,0x8(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8010c9:	00 
  8010ca:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  8010d1:	e8 4e f2 ff ff       	call   800324 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8010d6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  8010dc:	89 d8                	mov    %ebx,%eax
  8010de:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  8010e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e8:	f6 c4 08             	test   $0x8,%ah
  8010eb:	75 1c                	jne    801109 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  8010ed:	c7 44 24 08 e4 2f 80 	movl   $0x802fe4,0x8(%esp)
  8010f4:	00 
  8010f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010fc:	00 
  8010fd:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801104:	e8 1b f2 ff ff       	call   800324 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801109:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801110:	00 
  801111:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801118:	00 
  801119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801120:	e8 94 fc ff ff       	call   800db9 <sys_page_alloc>
  801125:	85 c0                	test   %eax,%eax
  801127:	79 20                	jns    801149 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112d:	c7 44 24 08 3f 30 80 	movl   $0x80303f,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801144:	e8 db f1 ff ff       	call   800324 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  801149:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801150:	00 
  801151:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801155:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80115c:	e8 df f9 ff ff       	call   800b40 <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  801161:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801168:	00 
  801169:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80116d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801174:	00 
  801175:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80117c:	00 
  80117d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801184:	e8 84 fc ff ff       	call   800e0d <sys_page_map>
  801189:	85 c0                	test   %eax,%eax
  80118b:	79 20                	jns    8011ad <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  80118d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801191:	c7 44 24 08 53 30 80 	movl   $0x803053,0x8(%esp)
  801198:	00 
  801199:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8011a0:	00 
  8011a1:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  8011a8:	e8 77 f1 ff ff       	call   800324 <_panic>

}
  8011ad:	83 c4 24             	add    $0x24,%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	57                   	push   %edi
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  8011bc:	c7 04 24 a4 10 80 00 	movl   $0x8010a4,(%esp)
  8011c3:	e8 80 15 00 00       	call   802748 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011c8:	ba 07 00 00 00       	mov    $0x7,%edx
  8011cd:	89 d0                	mov    %edx,%eax
  8011cf:	cd 30                	int    $0x30
  8011d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8011d4:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	79 20                	jns    8011fb <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  8011db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011df:	c7 44 24 08 65 30 80 	movl   $0x803065,0x8(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  8011f6:	e8 29 f1 ff ff       	call   800324 <_panic>
	if (child_envid == 0) { // child
  8011fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8011ff:	75 1c                	jne    80121d <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  801201:	e8 75 fb ff ff       	call   800d7b <sys_getenvid>
  801206:	25 ff 03 00 00       	and    $0x3ff,%eax
  80120b:	c1 e0 07             	shl    $0x7,%eax
  80120e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801213:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801218:	e9 58 02 00 00       	jmp    801475 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  80121d:	bf 00 00 00 00       	mov    $0x0,%edi
  801222:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801227:	89 f0                	mov    %esi,%eax
  801229:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80122c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801233:	a8 01                	test   $0x1,%al
  801235:	0f 84 7a 01 00 00    	je     8013b5 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80123b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801242:	a8 01                	test   $0x1,%al
  801244:	0f 84 6b 01 00 00    	je     8013b5 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80124a:	a1 08 50 80 00       	mov    0x805008,%eax
  80124f:	8b 40 48             	mov    0x48(%eax),%eax
  801252:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  801255:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80125c:	f6 c4 04             	test   $0x4,%ah
  80125f:	74 52                	je     8012b3 <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801261:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801268:	25 07 0e 00 00       	and    $0xe07,%eax
  80126d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801271:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801275:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801283:	89 04 24             	mov    %eax,(%esp)
  801286:	e8 82 fb ff ff       	call   800e0d <sys_page_map>
  80128b:	85 c0                	test   %eax,%eax
  80128d:	0f 89 22 01 00 00    	jns    8013b5 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801297:	c7 44 24 08 53 30 80 	movl   $0x803053,0x8(%esp)
  80129e:	00 
  80129f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8012a6:	00 
  8012a7:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  8012ae:	e8 71 f0 ff ff       	call   800324 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8012b3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012ba:	f6 c4 08             	test   $0x8,%ah
  8012bd:	75 0f                	jne    8012ce <fork+0x11b>
  8012bf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012c6:	a8 02                	test   $0x2,%al
  8012c8:	0f 84 99 00 00 00    	je     801367 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  8012ce:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8012d5:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8012d8:	83 f8 01             	cmp    $0x1,%eax
  8012db:	19 db                	sbb    %ebx,%ebx
  8012dd:	83 e3 fc             	and    $0xfffffffc,%ebx
  8012e0:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  8012e6:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8012ea:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012fc:	89 04 24             	mov    %eax,(%esp)
  8012ff:	e8 09 fb ff ff       	call   800e0d <sys_page_map>
  801304:	85 c0                	test   %eax,%eax
  801306:	79 20                	jns    801328 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801308:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130c:	c7 44 24 08 53 30 80 	movl   $0x803053,0x8(%esp)
  801313:	00 
  801314:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80131b:	00 
  80131c:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801323:	e8 fc ef ff ff       	call   800324 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801328:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80132c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801333:	89 44 24 08          	mov    %eax,0x8(%esp)
  801337:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133b:	89 04 24             	mov    %eax,(%esp)
  80133e:	e8 ca fa ff ff       	call   800e0d <sys_page_map>
  801343:	85 c0                	test   %eax,%eax
  801345:	79 6e                	jns    8013b5 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134b:	c7 44 24 08 53 30 80 	movl   $0x803053,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801362:	e8 bd ef ff ff       	call   800324 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801367:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80136e:	25 07 0e 00 00       	and    $0xe07,%eax
  801373:	89 44 24 10          	mov    %eax,0x10(%esp)
  801377:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80137b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801382:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801386:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801389:	89 04 24             	mov    %eax,(%esp)
  80138c:	e8 7c fa ff ff       	call   800e0d <sys_page_map>
  801391:	85 c0                	test   %eax,%eax
  801393:	79 20                	jns    8013b5 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801399:	c7 44 24 08 53 30 80 	movl   $0x803053,0x8(%esp)
  8013a0:	00 
  8013a1:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8013a8:	00 
  8013a9:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  8013b0:	e8 6f ef ff ff       	call   800324 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  8013b5:	46                   	inc    %esi
  8013b6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8013bc:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8013c2:	0f 85 5f fe ff ff    	jne    801227 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8013c8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013cf:	00 
  8013d0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013d7:	ee 
  8013d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 d6 f9 ff ff       	call   800db9 <sys_page_alloc>
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	79 20                	jns    801407 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  8013e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013eb:	c7 44 24 08 3f 30 80 	movl   $0x80303f,0x8(%esp)
  8013f2:	00 
  8013f3:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  8013fa:	00 
  8013fb:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801402:	e8 1d ef ff ff       	call   800324 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801407:	c7 44 24 04 bc 27 80 	movl   $0x8027bc,0x4(%esp)
  80140e:	00 
  80140f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	e8 3f fb ff ff       	call   800f59 <sys_env_set_pgfault_upcall>
  80141a:	85 c0                	test   %eax,%eax
  80141c:	79 20                	jns    80143e <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80141e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801422:	c7 44 24 08 14 30 80 	movl   $0x803014,0x8(%esp)
  801429:	00 
  80142a:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  801431:	00 
  801432:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801439:	e8 e6 ee ff ff       	call   800324 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  80143e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801445:	00 
  801446:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801449:	89 04 24             	mov    %eax,(%esp)
  80144c:	e8 62 fa ff ff       	call   800eb3 <sys_env_set_status>
  801451:	85 c0                	test   %eax,%eax
  801453:	79 20                	jns    801475 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  801455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801459:	c7 44 24 08 76 30 80 	movl   $0x803076,0x8(%esp)
  801460:	00 
  801461:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  801468:	00 
  801469:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  801470:	e8 af ee ff ff       	call   800324 <_panic>

	return child_envid;
}
  801475:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801478:	83 c4 3c             	add    $0x3c,%esp
  80147b:	5b                   	pop    %ebx
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <sfork>:

// Challenge!
int
sfork(void)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801486:	c7 44 24 08 8e 30 80 	movl   $0x80308e,0x8(%esp)
  80148d:	00 
  80148e:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801495:	00 
  801496:	c7 04 24 34 30 80 00 	movl   $0x803034,(%esp)
  80149d:	e8 82 ee ff ff       	call   800324 <_panic>
	...

008014a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8014af:	c1 e8 0c             	shr    $0xc,%eax
}
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    

008014b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	89 04 24             	mov    %eax,(%esp)
  8014c0:	e8 df ff ff ff       	call   8014a4 <fd2num>
  8014c5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014ca:	c1 e0 0c             	shl    $0xc,%eax
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014d6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8014db:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	c1 ea 16             	shr    $0x16,%edx
  8014e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e9:	f6 c2 01             	test   $0x1,%dl
  8014ec:	74 11                	je     8014ff <fd_alloc+0x30>
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	c1 ea 0c             	shr    $0xc,%edx
  8014f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014fa:	f6 c2 01             	test   $0x1,%dl
  8014fd:	75 09                	jne    801508 <fd_alloc+0x39>
			*fd_store = fd;
  8014ff:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
  801506:	eb 17                	jmp    80151f <fd_alloc+0x50>
  801508:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80150d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801512:	75 c7                	jne    8014db <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801514:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80151a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80151f:	5b                   	pop    %ebx
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801528:	83 f8 1f             	cmp    $0x1f,%eax
  80152b:	77 36                	ja     801563 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80152d:	05 00 00 0d 00       	add    $0xd0000,%eax
  801532:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801535:	89 c2                	mov    %eax,%edx
  801537:	c1 ea 16             	shr    $0x16,%edx
  80153a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801541:	f6 c2 01             	test   $0x1,%dl
  801544:	74 24                	je     80156a <fd_lookup+0x48>
  801546:	89 c2                	mov    %eax,%edx
  801548:	c1 ea 0c             	shr    $0xc,%edx
  80154b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801552:	f6 c2 01             	test   $0x1,%dl
  801555:	74 1a                	je     801571 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801557:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155a:	89 02                	mov    %eax,(%edx)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
  801561:	eb 13                	jmp    801576 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801568:	eb 0c                	jmp    801576 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80156a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156f:	eb 05                	jmp    801576 <fd_lookup+0x54>
  801571:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801576:	5d                   	pop    %ebp
  801577:	c3                   	ret    

00801578 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801585:	ba 00 00 00 00       	mov    $0x0,%edx
  80158a:	eb 0e                	jmp    80159a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80158c:	39 08                	cmp    %ecx,(%eax)
  80158e:	75 09                	jne    801599 <dev_lookup+0x21>
			*dev = devtab[i];
  801590:	89 03                	mov    %eax,(%ebx)
			return 0;
  801592:	b8 00 00 00 00       	mov    $0x0,%eax
  801597:	eb 33                	jmp    8015cc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801599:	42                   	inc    %edx
  80159a:	8b 04 95 20 31 80 00 	mov    0x803120(,%edx,4),%eax
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	75 e7                	jne    80158c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a5:	a1 08 50 80 00       	mov    0x805008,%eax
  8015aa:	8b 40 48             	mov    0x48(%eax),%eax
  8015ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b5:	c7 04 24 a4 30 80 00 	movl   $0x8030a4,(%esp)
  8015bc:	e8 5b ee ff ff       	call   80041c <cprintf>
	*dev = 0;
  8015c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8015c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015cc:	83 c4 14             	add    $0x14,%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5d                   	pop    %ebp
  8015d1:	c3                   	ret    

008015d2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 30             	sub    $0x30,%esp
  8015da:	8b 75 08             	mov    0x8(%ebp),%esi
  8015dd:	8a 45 0c             	mov    0xc(%ebp),%al
  8015e0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e3:	89 34 24             	mov    %esi,(%esp)
  8015e6:	e8 b9 fe ff ff       	call   8014a4 <fd2num>
  8015eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 28 ff ff ff       	call   801522 <fd_lookup>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 05                	js     801605 <fd_close+0x33>
	    || fd != fd2)
  801600:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801603:	74 0d                	je     801612 <fd_close+0x40>
		return (must_exist ? r : 0);
  801605:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801609:	75 46                	jne    801651 <fd_close+0x7f>
  80160b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801610:	eb 3f                	jmp    801651 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801612:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801615:	89 44 24 04          	mov    %eax,0x4(%esp)
  801619:	8b 06                	mov    (%esi),%eax
  80161b:	89 04 24             	mov    %eax,(%esp)
  80161e:	e8 55 ff ff ff       	call   801578 <dev_lookup>
  801623:	89 c3                	mov    %eax,%ebx
  801625:	85 c0                	test   %eax,%eax
  801627:	78 18                	js     801641 <fd_close+0x6f>
		if (dev->dev_close)
  801629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162c:	8b 40 10             	mov    0x10(%eax),%eax
  80162f:	85 c0                	test   %eax,%eax
  801631:	74 09                	je     80163c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801633:	89 34 24             	mov    %esi,(%esp)
  801636:	ff d0                	call   *%eax
  801638:	89 c3                	mov    %eax,%ebx
  80163a:	eb 05                	jmp    801641 <fd_close+0x6f>
		else
			r = 0;
  80163c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801641:	89 74 24 04          	mov    %esi,0x4(%esp)
  801645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164c:	e8 0f f8 ff ff       	call   800e60 <sys_page_unmap>
	return r;
}
  801651:	89 d8                	mov    %ebx,%eax
  801653:	83 c4 30             	add    $0x30,%esp
  801656:	5b                   	pop    %ebx
  801657:	5e                   	pop    %esi
  801658:	5d                   	pop    %ebp
  801659:	c3                   	ret    

0080165a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	89 44 24 04          	mov    %eax,0x4(%esp)
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	89 04 24             	mov    %eax,(%esp)
  80166d:	e8 b0 fe ff ff       	call   801522 <fd_lookup>
  801672:	85 c0                	test   %eax,%eax
  801674:	78 13                	js     801689 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801676:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80167d:	00 
  80167e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801681:	89 04 24             	mov    %eax,(%esp)
  801684:	e8 49 ff ff ff       	call   8015d2 <fd_close>
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <close_all>:

void
close_all(void)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801692:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801697:	89 1c 24             	mov    %ebx,(%esp)
  80169a:	e8 bb ff ff ff       	call   80165a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80169f:	43                   	inc    %ebx
  8016a0:	83 fb 20             	cmp    $0x20,%ebx
  8016a3:	75 f2                	jne    801697 <close_all+0xc>
		close(i);
}
  8016a5:	83 c4 14             	add    $0x14,%esp
  8016a8:	5b                   	pop    %ebx
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	57                   	push   %edi
  8016af:	56                   	push   %esi
  8016b0:	53                   	push   %ebx
  8016b1:	83 ec 4c             	sub    $0x4c,%esp
  8016b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016be:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c1:	89 04 24             	mov    %eax,(%esp)
  8016c4:	e8 59 fe ff ff       	call   801522 <fd_lookup>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	0f 88 e1 00 00 00    	js     8017b4 <dup+0x109>
		return r;
	close(newfdnum);
  8016d3:	89 3c 24             	mov    %edi,(%esp)
  8016d6:	e8 7f ff ff ff       	call   80165a <close>

	newfd = INDEX2FD(newfdnum);
  8016db:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016e1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e7:	89 04 24             	mov    %eax,(%esp)
  8016ea:	e8 c5 fd ff ff       	call   8014b4 <fd2data>
  8016ef:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016f1:	89 34 24             	mov    %esi,(%esp)
  8016f4:	e8 bb fd ff ff       	call   8014b4 <fd2data>
  8016f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016fc:	89 d8                	mov    %ebx,%eax
  8016fe:	c1 e8 16             	shr    $0x16,%eax
  801701:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801708:	a8 01                	test   $0x1,%al
  80170a:	74 46                	je     801752 <dup+0xa7>
  80170c:	89 d8                	mov    %ebx,%eax
  80170e:	c1 e8 0c             	shr    $0xc,%eax
  801711:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801718:	f6 c2 01             	test   $0x1,%dl
  80171b:	74 35                	je     801752 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80171d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801724:	25 07 0e 00 00       	and    $0xe07,%eax
  801729:	89 44 24 10          	mov    %eax,0x10(%esp)
  80172d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801730:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801734:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80173b:	00 
  80173c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801747:	e8 c1 f6 ff ff       	call   800e0d <sys_page_map>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 3b                	js     80178d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801752:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801755:	89 c2                	mov    %eax,%edx
  801757:	c1 ea 0c             	shr    $0xc,%edx
  80175a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801761:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801767:	89 54 24 10          	mov    %edx,0x10(%esp)
  80176b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80176f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801776:	00 
  801777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801782:	e8 86 f6 ff ff       	call   800e0d <sys_page_map>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	85 c0                	test   %eax,%eax
  80178b:	79 25                	jns    8017b2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80178d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801791:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801798:	e8 c3 f6 ff ff       	call   800e60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80179d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017ab:	e8 b0 f6 ff ff       	call   800e60 <sys_page_unmap>
	return r;
  8017b0:	eb 02                	jmp    8017b4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8017b2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8017b4:	89 d8                	mov    %ebx,%eax
  8017b6:	83 c4 4c             	add    $0x4c,%esp
  8017b9:	5b                   	pop    %ebx
  8017ba:	5e                   	pop    %esi
  8017bb:	5f                   	pop    %edi
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	53                   	push   %ebx
  8017c2:	83 ec 24             	sub    $0x24,%esp
  8017c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cf:	89 1c 24             	mov    %ebx,(%esp)
  8017d2:	e8 4b fd ff ff       	call   801522 <fd_lookup>
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	78 6d                	js     801848 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e5:	8b 00                	mov    (%eax),%eax
  8017e7:	89 04 24             	mov    %eax,(%esp)
  8017ea:	e8 89 fd ff ff       	call   801578 <dev_lookup>
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	78 55                	js     801848 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f6:	8b 50 08             	mov    0x8(%eax),%edx
  8017f9:	83 e2 03             	and    $0x3,%edx
  8017fc:	83 fa 01             	cmp    $0x1,%edx
  8017ff:	75 23                	jne    801824 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801801:	a1 08 50 80 00       	mov    0x805008,%eax
  801806:	8b 40 48             	mov    0x48(%eax),%eax
  801809:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80180d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801811:	c7 04 24 e5 30 80 00 	movl   $0x8030e5,(%esp)
  801818:	e8 ff eb ff ff       	call   80041c <cprintf>
		return -E_INVAL;
  80181d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801822:	eb 24                	jmp    801848 <read+0x8a>
	}
	if (!dev->dev_read)
  801824:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801827:	8b 52 08             	mov    0x8(%edx),%edx
  80182a:	85 d2                	test   %edx,%edx
  80182c:	74 15                	je     801843 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80182e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801831:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801838:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183c:	89 04 24             	mov    %eax,(%esp)
  80183f:	ff d2                	call   *%edx
  801841:	eb 05                	jmp    801848 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801843:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801848:	83 c4 24             	add    $0x24,%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	53                   	push   %ebx
  801854:	83 ec 1c             	sub    $0x1c,%esp
  801857:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80185d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801862:	eb 23                	jmp    801887 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801864:	89 f0                	mov    %esi,%eax
  801866:	29 d8                	sub    %ebx,%eax
  801868:	89 44 24 08          	mov    %eax,0x8(%esp)
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	01 d8                	add    %ebx,%eax
  801871:	89 44 24 04          	mov    %eax,0x4(%esp)
  801875:	89 3c 24             	mov    %edi,(%esp)
  801878:	e8 41 ff ff ff       	call   8017be <read>
		if (m < 0)
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 10                	js     801891 <readn+0x43>
			return m;
		if (m == 0)
  801881:	85 c0                	test   %eax,%eax
  801883:	74 0a                	je     80188f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801885:	01 c3                	add    %eax,%ebx
  801887:	39 f3                	cmp    %esi,%ebx
  801889:	72 d9                	jb     801864 <readn+0x16>
  80188b:	89 d8                	mov    %ebx,%eax
  80188d:	eb 02                	jmp    801891 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80188f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801891:	83 c4 1c             	add    $0x1c,%esp
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	5f                   	pop    %edi
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	53                   	push   %ebx
  80189d:	83 ec 24             	sub    $0x24,%esp
  8018a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018aa:	89 1c 24             	mov    %ebx,(%esp)
  8018ad:	e8 70 fc ff ff       	call   801522 <fd_lookup>
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 68                	js     80191e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c0:	8b 00                	mov    (%eax),%eax
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 ae fc ff ff       	call   801578 <dev_lookup>
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 50                	js     80191e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d5:	75 23                	jne    8018fa <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d7:	a1 08 50 80 00       	mov    0x805008,%eax
  8018dc:	8b 40 48             	mov    0x48(%eax),%eax
  8018df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e7:	c7 04 24 01 31 80 00 	movl   $0x803101,(%esp)
  8018ee:	e8 29 eb ff ff       	call   80041c <cprintf>
		return -E_INVAL;
  8018f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f8:	eb 24                	jmp    80191e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801900:	85 d2                	test   %edx,%edx
  801902:	74 15                	je     801919 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801904:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801907:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80190b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80190e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	ff d2                	call   *%edx
  801917:	eb 05                	jmp    80191e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80191e:	83 c4 24             	add    $0x24,%esp
  801921:	5b                   	pop    %ebx
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <seek>:

int
seek(int fdnum, off_t offset)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80192d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	89 04 24             	mov    %eax,(%esp)
  801937:	e8 e6 fb ff ff       	call   801522 <fd_lookup>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 0e                	js     80194e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801940:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801943:	8b 55 0c             	mov    0xc(%ebp),%edx
  801946:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801949:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	83 ec 24             	sub    $0x24,%esp
  801957:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80195d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801961:	89 1c 24             	mov    %ebx,(%esp)
  801964:	e8 b9 fb ff ff       	call   801522 <fd_lookup>
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 61                	js     8019ce <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80196d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801970:	89 44 24 04          	mov    %eax,0x4(%esp)
  801974:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801977:	8b 00                	mov    (%eax),%eax
  801979:	89 04 24             	mov    %eax,(%esp)
  80197c:	e8 f7 fb ff ff       	call   801578 <dev_lookup>
  801981:	85 c0                	test   %eax,%eax
  801983:	78 49                	js     8019ce <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801985:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801988:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80198c:	75 23                	jne    8019b1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80198e:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801993:	8b 40 48             	mov    0x48(%eax),%eax
  801996:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80199a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199e:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  8019a5:	e8 72 ea ff ff       	call   80041c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019af:	eb 1d                	jmp    8019ce <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8019b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b4:	8b 52 18             	mov    0x18(%edx),%edx
  8019b7:	85 d2                	test   %edx,%edx
  8019b9:	74 0e                	je     8019c9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019c2:	89 04 24             	mov    %eax,(%esp)
  8019c5:	ff d2                	call   *%edx
  8019c7:	eb 05                	jmp    8019ce <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8019c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8019ce:	83 c4 24             	add    $0x24,%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5d                   	pop    %ebp
  8019d3:	c3                   	ret    

008019d4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 24             	sub    $0x24,%esp
  8019db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e8:	89 04 24             	mov    %eax,(%esp)
  8019eb:	e8 32 fb ff ff       	call   801522 <fd_lookup>
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	78 52                	js     801a46 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019fe:	8b 00                	mov    (%eax),%eax
  801a00:	89 04 24             	mov    %eax,(%esp)
  801a03:	e8 70 fb ff ff       	call   801578 <dev_lookup>
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 3a                	js     801a46 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801a13:	74 2c                	je     801a41 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a15:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a18:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a1f:	00 00 00 
	stat->st_isdir = 0;
  801a22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a29:	00 00 00 
	stat->st_dev = dev;
  801a2c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a39:	89 14 24             	mov    %edx,(%esp)
  801a3c:	ff 50 14             	call   *0x14(%eax)
  801a3f:	eb 05                	jmp    801a46 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801a41:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801a46:	83 c4 24             	add    $0x24,%esp
  801a49:	5b                   	pop    %ebx
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a54:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5b:	00 
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	89 04 24             	mov    %eax,(%esp)
  801a62:	e8 2d 02 00 00       	call   801c94 <open>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 1b                	js     801a88 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a74:	89 1c 24             	mov    %ebx,(%esp)
  801a77:	e8 58 ff ff ff       	call   8019d4 <fstat>
  801a7c:	89 c6                	mov    %eax,%esi
	close(fd);
  801a7e:	89 1c 24             	mov    %ebx,(%esp)
  801a81:	e8 d4 fb ff ff       	call   80165a <close>
	return r;
  801a86:	89 f3                	mov    %esi,%ebx
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    
  801a91:	00 00                	add    %al,(%eax)
	...

00801a94 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 10             	sub    $0x10,%esp
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801aa0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801aa7:	75 11                	jne    801aba <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801ab0:	e8 02 0e 00 00       	call   8028b7 <ipc_find_env>
  801ab5:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801aba:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ac1:	00 
  801ac2:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ac9:	00 
  801aca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ace:	a1 00 50 80 00       	mov    0x805000,%eax
  801ad3:	89 04 24             	mov    %eax,(%esp)
  801ad6:	e8 6e 0d 00 00       	call   802849 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801adb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ae2:	00 
  801ae3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aee:	e8 ed 0c 00 00       	call   8027e0 <ipc_recv>
}
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	8b 40 0c             	mov    0xc(%eax),%eax
  801b06:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b13:	ba 00 00 00 00       	mov    $0x0,%edx
  801b18:	b8 02 00 00 00       	mov    $0x2,%eax
  801b1d:	e8 72 ff ff ff       	call   801a94 <fsipc>
}
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2d:	8b 40 0c             	mov    0xc(%eax),%eax
  801b30:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801b35:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3a:	b8 06 00 00 00       	mov    $0x6,%eax
  801b3f:	e8 50 ff ff ff       	call   801a94 <fsipc>
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 14             	sub    $0x14,%esp
  801b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	8b 40 0c             	mov    0xc(%eax),%eax
  801b56:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b60:	b8 05 00 00 00       	mov    $0x5,%eax
  801b65:	e8 2a ff ff ff       	call   801a94 <fsipc>
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	78 2b                	js     801b99 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b6e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b75:	00 
  801b76:	89 1c 24             	mov    %ebx,(%esp)
  801b79:	e8 49 ee ff ff       	call   8009c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b7e:	a1 80 60 80 00       	mov    0x806080,%eax
  801b83:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b89:	a1 84 60 80 00       	mov    0x806084,%eax
  801b8e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b99:	83 c4 14             	add    $0x14,%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 18             	sub    $0x18,%esp
  801ba5:	8b 55 10             	mov    0x10(%ebp),%edx
  801ba8:	89 d0                	mov    %edx,%eax
  801baa:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801bb0:	76 05                	jbe    801bb7 <devfile_write+0x18>
  801bb2:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  801bba:	8b 52 0c             	mov    0xc(%edx),%edx
  801bbd:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801bc3:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd3:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801bda:	e8 61 ef ff ff       	call   800b40 <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  801be4:	b8 04 00 00 00       	mov    $0x4,%eax
  801be9:	e8 a6 fe ff ff       	call   801a94 <fsipc>
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	56                   	push   %esi
  801bf4:	53                   	push   %ebx
  801bf5:	83 ec 10             	sub    $0x10,%esp
  801bf8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfe:	8b 40 0c             	mov    0xc(%eax),%eax
  801c01:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801c06:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c11:	b8 03 00 00 00       	mov    $0x3,%eax
  801c16:	e8 79 fe ff ff       	call   801a94 <fsipc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 6a                	js     801c8b <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801c21:	39 c6                	cmp    %eax,%esi
  801c23:	73 24                	jae    801c49 <devfile_read+0x59>
  801c25:	c7 44 24 0c 34 31 80 	movl   $0x803134,0xc(%esp)
  801c2c:	00 
  801c2d:	c7 44 24 08 3b 31 80 	movl   $0x80313b,0x8(%esp)
  801c34:	00 
  801c35:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801c3c:	00 
  801c3d:	c7 04 24 50 31 80 00 	movl   $0x803150,(%esp)
  801c44:	e8 db e6 ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  801c49:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c4e:	7e 24                	jle    801c74 <devfile_read+0x84>
  801c50:	c7 44 24 0c 5b 31 80 	movl   $0x80315b,0xc(%esp)
  801c57:	00 
  801c58:	c7 44 24 08 3b 31 80 	movl   $0x80313b,0x8(%esp)
  801c5f:	00 
  801c60:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801c67:	00 
  801c68:	c7 04 24 50 31 80 00 	movl   $0x803150,(%esp)
  801c6f:	e8 b0 e6 ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c74:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c78:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c7f:	00 
  801c80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c83:	89 04 24             	mov    %eax,(%esp)
  801c86:	e8 b5 ee ff ff       	call   800b40 <memmove>
	return r;
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 20             	sub    $0x20,%esp
  801c9c:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c9f:	89 34 24             	mov    %esi,(%esp)
  801ca2:	e8 ed ec ff ff       	call   800994 <strlen>
  801ca7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801cac:	7f 60                	jg     801d0e <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801cae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 16 f8 ff ff       	call   8014cf <fd_alloc>
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	78 54                	js     801d13 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801cbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801cca:	e8 f8 ec ff ff       	call   8009c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd2:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801cd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cda:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdf:	e8 b0 fd ff ff       	call   801a94 <fsipc>
  801ce4:	89 c3                	mov    %eax,%ebx
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	79 15                	jns    801cff <open+0x6b>
		fd_close(fd, 0);
  801cea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cf1:	00 
  801cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf5:	89 04 24             	mov    %eax,(%esp)
  801cf8:	e8 d5 f8 ff ff       	call   8015d2 <fd_close>
		return r;
  801cfd:	eb 14                	jmp    801d13 <open+0x7f>
	}

	return fd2num(fd);
  801cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d02:	89 04 24             	mov    %eax,(%esp)
  801d05:	e8 9a f7 ff ff       	call   8014a4 <fd2num>
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	eb 05                	jmp    801d13 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801d0e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801d13:	89 d8                	mov    %ebx,%eax
  801d15:	83 c4 20             	add    $0x20,%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    

00801d1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d22:	ba 00 00 00 00       	mov    $0x0,%edx
  801d27:	b8 08 00 00 00       	mov    $0x8,%eax
  801d2c:	e8 63 fd ff ff       	call   801a94 <fsipc>
}
  801d31:	c9                   	leave  
  801d32:	c3                   	ret    
	...

00801d34 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801d3a:	c7 44 24 04 67 31 80 	movl   $0x803167,0x4(%esp)
  801d41:	00 
  801d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d45:	89 04 24             	mov    %eax,(%esp)
  801d48:	e8 7a ec ff ff       	call   8009c7 <strcpy>
	return 0;
}
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	53                   	push   %ebx
  801d58:	83 ec 14             	sub    $0x14,%esp
  801d5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d5e:	89 1c 24             	mov    %ebx,(%esp)
  801d61:	e8 8a 0b 00 00       	call   8028f0 <pageref>
  801d66:	83 f8 01             	cmp    $0x1,%eax
  801d69:	75 0d                	jne    801d78 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801d6b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 1f 03 00 00       	call   802095 <nsipc_close>
  801d76:	eb 05                	jmp    801d7d <devsock_close+0x29>
	else
		return 0;
  801d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d7d:	83 c4 14             	add    $0x14,%esp
  801d80:	5b                   	pop    %ebx
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d90:	00 
  801d91:	8b 45 10             	mov    0x10(%ebp),%eax
  801d94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	8b 40 0c             	mov    0xc(%eax),%eax
  801da5:	89 04 24             	mov    %eax,(%esp)
  801da8:	e8 e3 03 00 00       	call   802190 <nsipc_send>
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801db5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dbc:	00 
  801dbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd1:	89 04 24             	mov    %eax,(%esp)
  801dd4:	e8 37 03 00 00       	call   802110 <nsipc_recv>
}
  801dd9:	c9                   	leave  
  801dda:	c3                   	ret    

00801ddb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 20             	sub    $0x20,%esp
  801de3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de8:	89 04 24             	mov    %eax,(%esp)
  801deb:	e8 df f6 ff ff       	call   8014cf <fd_alloc>
  801df0:	89 c3                	mov    %eax,%ebx
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 21                	js     801e17 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801df6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801dfd:	00 
  801dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 a8 ef ff ff       	call   800db9 <sys_page_alloc>
  801e11:	89 c3                	mov    %eax,%ebx
  801e13:	85 c0                	test   %eax,%eax
  801e15:	79 0a                	jns    801e21 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801e17:	89 34 24             	mov    %esi,(%esp)
  801e1a:	e8 76 02 00 00       	call   802095 <nsipc_close>
		return r;
  801e1f:	eb 22                	jmp    801e43 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e21:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e36:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e39:	89 04 24             	mov    %eax,(%esp)
  801e3c:	e8 63 f6 ff ff       	call   8014a4 <fd2num>
  801e41:	89 c3                	mov    %eax,%ebx
}
  801e43:	89 d8                	mov    %ebx,%eax
  801e45:	83 c4 20             	add    $0x20,%esp
  801e48:	5b                   	pop    %ebx
  801e49:	5e                   	pop    %esi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e59:	89 04 24             	mov    %eax,(%esp)
  801e5c:	e8 c1 f6 ff ff       	call   801522 <fd_lookup>
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 17                	js     801e7c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e68:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801e6e:	39 10                	cmp    %edx,(%eax)
  801e70:	75 05                	jne    801e77 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e72:	8b 40 0c             	mov    0xc(%eax),%eax
  801e75:	eb 05                	jmp    801e7c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e77:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e7c:	c9                   	leave  
  801e7d:	c3                   	ret    

00801e7e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e84:	8b 45 08             	mov    0x8(%ebp),%eax
  801e87:	e8 c0 ff ff ff       	call   801e4c <fd2sockid>
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 1f                	js     801eaf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e90:	8b 55 10             	mov    0x10(%ebp),%edx
  801e93:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e9e:	89 04 24             	mov    %eax,(%esp)
  801ea1:	e8 38 01 00 00       	call   801fde <nsipc_accept>
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	78 05                	js     801eaf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801eaa:	e8 2c ff ff ff       	call   801ddb <alloc_sockfd>
}
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	e8 8d ff ff ff       	call   801e4c <fd2sockid>
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 16                	js     801ed9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ec3:	8b 55 10             	mov    0x10(%ebp),%edx
  801ec6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ecd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 5b 01 00 00       	call   802034 <nsipc_bind>
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <shutdown>:

int
shutdown(int s, int how)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	e8 63 ff ff ff       	call   801e4c <fd2sockid>
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	78 0f                	js     801efc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801eed:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ef4:	89 04 24             	mov    %eax,(%esp)
  801ef7:	e8 77 01 00 00       	call   802073 <nsipc_shutdown>
}
  801efc:	c9                   	leave  
  801efd:	c3                   	ret    

00801efe <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	e8 40 ff ff ff       	call   801e4c <fd2sockid>
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 16                	js     801f26 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801f10:	8b 55 10             	mov    0x10(%ebp),%edx
  801f13:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 89 01 00 00       	call   8020af <nsipc_connect>
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <listen>:

int
listen(int s, int backlog)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f31:	e8 16 ff ff ff       	call   801e4c <fd2sockid>
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 0f                	js     801f49 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 a5 01 00 00       	call   8020ee <nsipc_listen>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f51:	8b 45 10             	mov    0x10(%ebp),%eax
  801f54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f62:	89 04 24             	mov    %eax,(%esp)
  801f65:	e8 99 02 00 00       	call   802203 <nsipc_socket>
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	78 05                	js     801f73 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f6e:	e8 68 fe ff ff       	call   801ddb <alloc_sockfd>
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    
  801f75:	00 00                	add    %al,(%eax)
	...

00801f78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	53                   	push   %ebx
  801f7c:	83 ec 14             	sub    $0x14,%esp
  801f7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f81:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f88:	75 11                	jne    801f9b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f8a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f91:	e8 21 09 00 00       	call   8028b7 <ipc_find_env>
  801f96:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f9b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801fa2:	00 
  801fa3:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801faa:	00 
  801fab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801faf:	a1 04 50 80 00       	mov    0x805004,%eax
  801fb4:	89 04 24             	mov    %eax,(%esp)
  801fb7:	e8 8d 08 00 00       	call   802849 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fbc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801fc3:	00 
  801fc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fcb:	00 
  801fcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fd3:	e8 08 08 00 00       	call   8027e0 <ipc_recv>
}
  801fd8:	83 c4 14             	add    $0x14,%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 10             	sub    $0x10,%esp
  801fe6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fec:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ff1:	8b 06                	mov    (%esi),%eax
  801ff3:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ff8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffd:	e8 76 ff ff ff       	call   801f78 <nsipc>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	85 c0                	test   %eax,%eax
  802006:	78 23                	js     80202b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802008:	a1 10 70 80 00       	mov    0x807010,%eax
  80200d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802011:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802018:	00 
  802019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201c:	89 04 24             	mov    %eax,(%esp)
  80201f:	e8 1c eb ff ff       	call   800b40 <memmove>
		*addrlen = ret->ret_addrlen;
  802024:	a1 10 70 80 00       	mov    0x807010,%eax
  802029:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80202b:	89 d8                	mov    %ebx,%eax
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	53                   	push   %ebx
  802038:	83 ec 14             	sub    $0x14,%esp
  80203b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80203e:	8b 45 08             	mov    0x8(%ebp),%eax
  802041:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802046:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802051:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802058:	e8 e3 ea ff ff       	call   800b40 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80205d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802063:	b8 02 00 00 00       	mov    $0x2,%eax
  802068:	e8 0b ff ff ff       	call   801f78 <nsipc>
}
  80206d:	83 c4 14             	add    $0x14,%esp
  802070:	5b                   	pop    %ebx
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802079:	8b 45 08             	mov    0x8(%ebp),%eax
  80207c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802081:	8b 45 0c             	mov    0xc(%ebp),%eax
  802084:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802089:	b8 03 00 00 00       	mov    $0x3,%eax
  80208e:	e8 e5 fe ff ff       	call   801f78 <nsipc>
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <nsipc_close>:

int
nsipc_close(int s)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8020a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8020a8:	e8 cb fe ff ff       	call   801f78 <nsipc>
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	53                   	push   %ebx
  8020b3:	83 ec 14             	sub    $0x14,%esp
  8020b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cc:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020d3:	e8 68 ea ff ff       	call   800b40 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020d8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8020de:	b8 05 00 00 00       	mov    $0x5,%eax
  8020e3:	e8 90 fe ff ff       	call   801f78 <nsipc>
}
  8020e8:	83 c4 14             	add    $0x14,%esp
  8020eb:	5b                   	pop    %ebx
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ff:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802104:	b8 06 00 00 00       	mov    $0x6,%eax
  802109:	e8 6a fe ff ff       	call   801f78 <nsipc>
}
  80210e:	c9                   	leave  
  80210f:	c3                   	ret    

00802110 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	56                   	push   %esi
  802114:	53                   	push   %ebx
  802115:	83 ec 10             	sub    $0x10,%esp
  802118:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80211b:	8b 45 08             	mov    0x8(%ebp),%eax
  80211e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802123:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802129:	8b 45 14             	mov    0x14(%ebp),%eax
  80212c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802131:	b8 07 00 00 00       	mov    $0x7,%eax
  802136:	e8 3d fe ff ff       	call   801f78 <nsipc>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 46                	js     802187 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802141:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802146:	7f 04                	jg     80214c <nsipc_recv+0x3c>
  802148:	39 c6                	cmp    %eax,%esi
  80214a:	7d 24                	jge    802170 <nsipc_recv+0x60>
  80214c:	c7 44 24 0c 73 31 80 	movl   $0x803173,0xc(%esp)
  802153:	00 
  802154:	c7 44 24 08 3b 31 80 	movl   $0x80313b,0x8(%esp)
  80215b:	00 
  80215c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802163:	00 
  802164:	c7 04 24 88 31 80 00 	movl   $0x803188,(%esp)
  80216b:	e8 b4 e1 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802170:	89 44 24 08          	mov    %eax,0x8(%esp)
  802174:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80217b:	00 
  80217c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217f:	89 04 24             	mov    %eax,(%esp)
  802182:	e8 b9 e9 ff ff       	call   800b40 <memmove>
	}

	return r;
}
  802187:	89 d8                	mov    %ebx,%eax
  802189:	83 c4 10             	add    $0x10,%esp
  80218c:	5b                   	pop    %ebx
  80218d:	5e                   	pop    %esi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    

00802190 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	53                   	push   %ebx
  802194:	83 ec 14             	sub    $0x14,%esp
  802197:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80219a:	8b 45 08             	mov    0x8(%ebp),%eax
  80219d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8021a2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021a8:	7e 24                	jle    8021ce <nsipc_send+0x3e>
  8021aa:	c7 44 24 0c 94 31 80 	movl   $0x803194,0xc(%esp)
  8021b1:	00 
  8021b2:	c7 44 24 08 3b 31 80 	movl   $0x80313b,0x8(%esp)
  8021b9:	00 
  8021ba:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8021c1:	00 
  8021c2:	c7 04 24 88 31 80 00 	movl   $0x803188,(%esp)
  8021c9:	e8 56 e1 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d9:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8021e0:	e8 5b e9 ff ff       	call   800b40 <memmove>
	nsipcbuf.send.req_size = size;
  8021e5:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8021eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8021ee:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8021f8:	e8 7b fd ff ff       	call   801f78 <nsipc>
}
  8021fd:	83 c4 14             	add    $0x14,%esp
  802200:	5b                   	pop    %ebx
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    

00802203 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802209:	8b 45 08             	mov    0x8(%ebp),%eax
  80220c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802211:	8b 45 0c             	mov    0xc(%ebp),%eax
  802214:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802219:	8b 45 10             	mov    0x10(%ebp),%eax
  80221c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802221:	b8 09 00 00 00       	mov    $0x9,%eax
  802226:	e8 4d fd ff ff       	call   801f78 <nsipc>
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    
  80222d:	00 00                	add    %al,(%eax)
	...

00802230 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	56                   	push   %esi
  802234:	53                   	push   %ebx
  802235:	83 ec 10             	sub    $0x10,%esp
  802238:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80223b:	8b 45 08             	mov    0x8(%ebp),%eax
  80223e:	89 04 24             	mov    %eax,(%esp)
  802241:	e8 6e f2 ff ff       	call   8014b4 <fd2data>
  802246:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802248:	c7 44 24 04 a0 31 80 	movl   $0x8031a0,0x4(%esp)
  80224f:	00 
  802250:	89 34 24             	mov    %esi,(%esp)
  802253:	e8 6f e7 ff ff       	call   8009c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802258:	8b 43 04             	mov    0x4(%ebx),%eax
  80225b:	2b 03                	sub    (%ebx),%eax
  80225d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802263:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80226a:	00 00 00 
	stat->st_dev = &devpipe;
  80226d:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802274:	40 80 00 
	return 0;
}
  802277:	b8 00 00 00 00       	mov    $0x0,%eax
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	53                   	push   %ebx
  802287:	83 ec 14             	sub    $0x14,%esp
  80228a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80228d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802298:	e8 c3 eb ff ff       	call   800e60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80229d:	89 1c 24             	mov    %ebx,(%esp)
  8022a0:	e8 0f f2 ff ff       	call   8014b4 <fd2data>
  8022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b0:	e8 ab eb ff ff       	call   800e60 <sys_page_unmap>
}
  8022b5:	83 c4 14             	add    $0x14,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    

008022bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8022bb:	55                   	push   %ebp
  8022bc:	89 e5                	mov    %esp,%ebp
  8022be:	57                   	push   %edi
  8022bf:	56                   	push   %esi
  8022c0:	53                   	push   %ebx
  8022c1:	83 ec 2c             	sub    $0x2c,%esp
  8022c4:	89 c7                	mov    %eax,%edi
  8022c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8022c9:	a1 08 50 80 00       	mov    0x805008,%eax
  8022ce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8022d1:	89 3c 24             	mov    %edi,(%esp)
  8022d4:	e8 17 06 00 00       	call   8028f0 <pageref>
  8022d9:	89 c6                	mov    %eax,%esi
  8022db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022de:	89 04 24             	mov    %eax,(%esp)
  8022e1:	e8 0a 06 00 00       	call   8028f0 <pageref>
  8022e6:	39 c6                	cmp    %eax,%esi
  8022e8:	0f 94 c0             	sete   %al
  8022eb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8022ee:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8022f4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8022f7:	39 cb                	cmp    %ecx,%ebx
  8022f9:	75 08                	jne    802303 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8022fb:	83 c4 2c             	add    $0x2c,%esp
  8022fe:	5b                   	pop    %ebx
  8022ff:	5e                   	pop    %esi
  802300:	5f                   	pop    %edi
  802301:	5d                   	pop    %ebp
  802302:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802303:	83 f8 01             	cmp    $0x1,%eax
  802306:	75 c1                	jne    8022c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802308:	8b 42 58             	mov    0x58(%edx),%eax
  80230b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802312:	00 
  802313:	89 44 24 08          	mov    %eax,0x8(%esp)
  802317:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80231b:	c7 04 24 a7 31 80 00 	movl   $0x8031a7,(%esp)
  802322:	e8 f5 e0 ff ff       	call   80041c <cprintf>
  802327:	eb a0                	jmp    8022c9 <_pipeisclosed+0xe>

00802329 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	57                   	push   %edi
  80232d:	56                   	push   %esi
  80232e:	53                   	push   %ebx
  80232f:	83 ec 1c             	sub    $0x1c,%esp
  802332:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802335:	89 34 24             	mov    %esi,(%esp)
  802338:	e8 77 f1 ff ff       	call   8014b4 <fd2data>
  80233d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80233f:	bf 00 00 00 00       	mov    $0x0,%edi
  802344:	eb 3c                	jmp    802382 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802346:	89 da                	mov    %ebx,%edx
  802348:	89 f0                	mov    %esi,%eax
  80234a:	e8 6c ff ff ff       	call   8022bb <_pipeisclosed>
  80234f:	85 c0                	test   %eax,%eax
  802351:	75 38                	jne    80238b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802353:	e8 42 ea ff ff       	call   800d9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802358:	8b 43 04             	mov    0x4(%ebx),%eax
  80235b:	8b 13                	mov    (%ebx),%edx
  80235d:	83 c2 20             	add    $0x20,%edx
  802360:	39 d0                	cmp    %edx,%eax
  802362:	73 e2                	jae    802346 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802364:	8b 55 0c             	mov    0xc(%ebp),%edx
  802367:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80236a:	89 c2                	mov    %eax,%edx
  80236c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802372:	79 05                	jns    802379 <devpipe_write+0x50>
  802374:	4a                   	dec    %edx
  802375:	83 ca e0             	or     $0xffffffe0,%edx
  802378:	42                   	inc    %edx
  802379:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80237d:	40                   	inc    %eax
  80237e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802381:	47                   	inc    %edi
  802382:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802385:	75 d1                	jne    802358 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802387:	89 f8                	mov    %edi,%eax
  802389:	eb 05                	jmp    802390 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80238b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802390:	83 c4 1c             	add    $0x1c,%esp
  802393:	5b                   	pop    %ebx
  802394:	5e                   	pop    %esi
  802395:	5f                   	pop    %edi
  802396:	5d                   	pop    %ebp
  802397:	c3                   	ret    

00802398 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802398:	55                   	push   %ebp
  802399:	89 e5                	mov    %esp,%ebp
  80239b:	57                   	push   %edi
  80239c:	56                   	push   %esi
  80239d:	53                   	push   %ebx
  80239e:	83 ec 1c             	sub    $0x1c,%esp
  8023a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8023a4:	89 3c 24             	mov    %edi,(%esp)
  8023a7:	e8 08 f1 ff ff       	call   8014b4 <fd2data>
  8023ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ae:	be 00 00 00 00       	mov    $0x0,%esi
  8023b3:	eb 3a                	jmp    8023ef <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8023b5:	85 f6                	test   %esi,%esi
  8023b7:	74 04                	je     8023bd <devpipe_read+0x25>
				return i;
  8023b9:	89 f0                	mov    %esi,%eax
  8023bb:	eb 40                	jmp    8023fd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8023bd:	89 da                	mov    %ebx,%edx
  8023bf:	89 f8                	mov    %edi,%eax
  8023c1:	e8 f5 fe ff ff       	call   8022bb <_pipeisclosed>
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	75 2e                	jne    8023f8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8023ca:	e8 cb e9 ff ff       	call   800d9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8023cf:	8b 03                	mov    (%ebx),%eax
  8023d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023d4:	74 df                	je     8023b5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8023d6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8023db:	79 05                	jns    8023e2 <devpipe_read+0x4a>
  8023dd:	48                   	dec    %eax
  8023de:	83 c8 e0             	or     $0xffffffe0,%eax
  8023e1:	40                   	inc    %eax
  8023e2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8023e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023e9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8023ec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8023ee:	46                   	inc    %esi
  8023ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023f2:	75 db                	jne    8023cf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8023f4:	89 f0                	mov    %esi,%eax
  8023f6:	eb 05                	jmp    8023fd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8023f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8023fd:	83 c4 1c             	add    $0x1c,%esp
  802400:	5b                   	pop    %ebx
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    

00802405 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	57                   	push   %edi
  802409:	56                   	push   %esi
  80240a:	53                   	push   %ebx
  80240b:	83 ec 3c             	sub    $0x3c,%esp
  80240e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802411:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802414:	89 04 24             	mov    %eax,(%esp)
  802417:	e8 b3 f0 ff ff       	call   8014cf <fd_alloc>
  80241c:	89 c3                	mov    %eax,%ebx
  80241e:	85 c0                	test   %eax,%eax
  802420:	0f 88 45 01 00 00    	js     80256b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802426:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80242d:	00 
  80242e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802431:	89 44 24 04          	mov    %eax,0x4(%esp)
  802435:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80243c:	e8 78 e9 ff ff       	call   800db9 <sys_page_alloc>
  802441:	89 c3                	mov    %eax,%ebx
  802443:	85 c0                	test   %eax,%eax
  802445:	0f 88 20 01 00 00    	js     80256b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80244b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 79 f0 ff ff       	call   8014cf <fd_alloc>
  802456:	89 c3                	mov    %eax,%ebx
  802458:	85 c0                	test   %eax,%eax
  80245a:	0f 88 f8 00 00 00    	js     802558 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802460:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802467:	00 
  802468:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80246b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80246f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802476:	e8 3e e9 ff ff       	call   800db9 <sys_page_alloc>
  80247b:	89 c3                	mov    %eax,%ebx
  80247d:	85 c0                	test   %eax,%eax
  80247f:	0f 88 d3 00 00 00    	js     802558 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802488:	89 04 24             	mov    %eax,(%esp)
  80248b:	e8 24 f0 ff ff       	call   8014b4 <fd2data>
  802490:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802492:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802499:	00 
  80249a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80249e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024a5:	e8 0f e9 ff ff       	call   800db9 <sys_page_alloc>
  8024aa:	89 c3                	mov    %eax,%ebx
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	0f 88 91 00 00 00    	js     802545 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8024b7:	89 04 24             	mov    %eax,(%esp)
  8024ba:	e8 f5 ef ff ff       	call   8014b4 <fd2data>
  8024bf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8024c6:	00 
  8024c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024d2:	00 
  8024d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024de:	e8 2a e9 ff ff       	call   800e0d <sys_page_map>
  8024e3:	89 c3                	mov    %eax,%ebx
  8024e5:	85 c0                	test   %eax,%eax
  8024e7:	78 4c                	js     802535 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8024e9:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8024ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024f2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8024f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8024fe:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802504:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802507:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802509:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80250c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802516:	89 04 24             	mov    %eax,(%esp)
  802519:	e8 86 ef ff ff       	call   8014a4 <fd2num>
  80251e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802523:	89 04 24             	mov    %eax,(%esp)
  802526:	e8 79 ef ff ff       	call   8014a4 <fd2num>
  80252b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80252e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802533:	eb 36                	jmp    80256b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802535:	89 74 24 04          	mov    %esi,0x4(%esp)
  802539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802540:	e8 1b e9 ff ff       	call   800e60 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80254c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802553:	e8 08 e9 ff ff       	call   800e60 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802558:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80255b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802566:	e8 f5 e8 ff ff       	call   800e60 <sys_page_unmap>
    err:
	return r;
}
  80256b:	89 d8                	mov    %ebx,%eax
  80256d:	83 c4 3c             	add    $0x3c,%esp
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80257b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802582:	8b 45 08             	mov    0x8(%ebp),%eax
  802585:	89 04 24             	mov    %eax,(%esp)
  802588:	e8 95 ef ff ff       	call   801522 <fd_lookup>
  80258d:	85 c0                	test   %eax,%eax
  80258f:	78 15                	js     8025a6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802591:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802594:	89 04 24             	mov    %eax,(%esp)
  802597:	e8 18 ef ff ff       	call   8014b4 <fd2data>
	return _pipeisclosed(fd, p);
  80259c:	89 c2                	mov    %eax,%edx
  80259e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025a1:	e8 15 fd ff ff       	call   8022bb <_pipeisclosed>
}
  8025a6:	c9                   	leave  
  8025a7:	c3                   	ret    

008025a8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8025a8:	55                   	push   %ebp
  8025a9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8025ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    

008025b2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8025b2:	55                   	push   %ebp
  8025b3:	89 e5                	mov    %esp,%ebp
  8025b5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8025b8:	c7 44 24 04 ba 31 80 	movl   $0x8031ba,0x4(%esp)
  8025bf:	00 
  8025c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c3:	89 04 24             	mov    %eax,(%esp)
  8025c6:	e8 fc e3 ff ff       	call   8009c7 <strcpy>
	return 0;
}
  8025cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8025d0:	c9                   	leave  
  8025d1:	c3                   	ret    

008025d2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8025d2:	55                   	push   %ebp
  8025d3:	89 e5                	mov    %esp,%ebp
  8025d5:	57                   	push   %edi
  8025d6:	56                   	push   %esi
  8025d7:	53                   	push   %ebx
  8025d8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025de:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8025e3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8025e9:	eb 30                	jmp    80261b <devcons_write+0x49>
		m = n - tot;
  8025eb:	8b 75 10             	mov    0x10(%ebp),%esi
  8025ee:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8025f0:	83 fe 7f             	cmp    $0x7f,%esi
  8025f3:	76 05                	jbe    8025fa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8025f5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8025fa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8025fe:	03 45 0c             	add    0xc(%ebp),%eax
  802601:	89 44 24 04          	mov    %eax,0x4(%esp)
  802605:	89 3c 24             	mov    %edi,(%esp)
  802608:	e8 33 e5 ff ff       	call   800b40 <memmove>
		sys_cputs(buf, m);
  80260d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802611:	89 3c 24             	mov    %edi,(%esp)
  802614:	e8 d3 e6 ff ff       	call   800cec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802619:	01 f3                	add    %esi,%ebx
  80261b:	89 d8                	mov    %ebx,%eax
  80261d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802620:	72 c9                	jb     8025eb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802622:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802628:	5b                   	pop    %ebx
  802629:	5e                   	pop    %esi
  80262a:	5f                   	pop    %edi
  80262b:	5d                   	pop    %ebp
  80262c:	c3                   	ret    

0080262d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80262d:	55                   	push   %ebp
  80262e:	89 e5                	mov    %esp,%ebp
  802630:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802633:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802637:	75 07                	jne    802640 <devcons_read+0x13>
  802639:	eb 25                	jmp    802660 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80263b:	e8 5a e7 ff ff       	call   800d9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802640:	e8 c5 e6 ff ff       	call   800d0a <sys_cgetc>
  802645:	85 c0                	test   %eax,%eax
  802647:	74 f2                	je     80263b <devcons_read+0xe>
  802649:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80264b:	85 c0                	test   %eax,%eax
  80264d:	78 1d                	js     80266c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80264f:	83 f8 04             	cmp    $0x4,%eax
  802652:	74 13                	je     802667 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802654:	8b 45 0c             	mov    0xc(%ebp),%eax
  802657:	88 10                	mov    %dl,(%eax)
	return 1;
  802659:	b8 01 00 00 00       	mov    $0x1,%eax
  80265e:	eb 0c                	jmp    80266c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802660:	b8 00 00 00 00       	mov    $0x0,%eax
  802665:	eb 05                	jmp    80266c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802667:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80266c:	c9                   	leave  
  80266d:	c3                   	ret    

0080266e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80266e:	55                   	push   %ebp
  80266f:	89 e5                	mov    %esp,%ebp
  802671:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802674:	8b 45 08             	mov    0x8(%ebp),%eax
  802677:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80267a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802681:	00 
  802682:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802685:	89 04 24             	mov    %eax,(%esp)
  802688:	e8 5f e6 ff ff       	call   800cec <sys_cputs>
}
  80268d:	c9                   	leave  
  80268e:	c3                   	ret    

0080268f <getchar>:

int
getchar(void)
{
  80268f:	55                   	push   %ebp
  802690:	89 e5                	mov    %esp,%ebp
  802692:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802695:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80269c:	00 
  80269d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8026a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026ab:	e8 0e f1 ff ff       	call   8017be <read>
	if (r < 0)
  8026b0:	85 c0                	test   %eax,%eax
  8026b2:	78 0f                	js     8026c3 <getchar+0x34>
		return r;
	if (r < 1)
  8026b4:	85 c0                	test   %eax,%eax
  8026b6:	7e 06                	jle    8026be <getchar+0x2f>
		return -E_EOF;
	return c;
  8026b8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8026bc:	eb 05                	jmp    8026c3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8026be:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    

008026c5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8026c5:	55                   	push   %ebp
  8026c6:	89 e5                	mov    %esp,%ebp
  8026c8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026d5:	89 04 24             	mov    %eax,(%esp)
  8026d8:	e8 45 ee ff ff       	call   801522 <fd_lookup>
  8026dd:	85 c0                	test   %eax,%eax
  8026df:	78 11                	js     8026f2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8026e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e4:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8026ea:	39 10                	cmp    %edx,(%eax)
  8026ec:	0f 94 c0             	sete   %al
  8026ef:	0f b6 c0             	movzbl %al,%eax
}
  8026f2:	c9                   	leave  
  8026f3:	c3                   	ret    

008026f4 <opencons>:

int
opencons(void)
{
  8026f4:	55                   	push   %ebp
  8026f5:	89 e5                	mov    %esp,%ebp
  8026f7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8026fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026fd:	89 04 24             	mov    %eax,(%esp)
  802700:	e8 ca ed ff ff       	call   8014cf <fd_alloc>
  802705:	85 c0                	test   %eax,%eax
  802707:	78 3c                	js     802745 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802709:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802710:	00 
  802711:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802714:	89 44 24 04          	mov    %eax,0x4(%esp)
  802718:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80271f:	e8 95 e6 ff ff       	call   800db9 <sys_page_alloc>
  802724:	85 c0                	test   %eax,%eax
  802726:	78 1d                	js     802745 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802728:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802731:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802736:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80273d:	89 04 24             	mov    %eax,(%esp)
  802740:	e8 5f ed ff ff       	call   8014a4 <fd2num>
}
  802745:	c9                   	leave  
  802746:	c3                   	ret    
	...

00802748 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802748:	55                   	push   %ebp
  802749:	89 e5                	mov    %esp,%ebp
  80274b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80274e:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802755:	75 58                	jne    8027af <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  802757:	a1 08 50 80 00       	mov    0x805008,%eax
  80275c:	8b 40 48             	mov    0x48(%eax),%eax
  80275f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802766:	00 
  802767:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80276e:	ee 
  80276f:	89 04 24             	mov    %eax,(%esp)
  802772:	e8 42 e6 ff ff       	call   800db9 <sys_page_alloc>
  802777:	85 c0                	test   %eax,%eax
  802779:	74 1c                	je     802797 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  80277b:	c7 44 24 08 c6 31 80 	movl   $0x8031c6,0x8(%esp)
  802782:	00 
  802783:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80278a:	00 
  80278b:	c7 04 24 db 31 80 00 	movl   $0x8031db,(%esp)
  802792:	e8 8d db ff ff       	call   800324 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802797:	a1 08 50 80 00       	mov    0x805008,%eax
  80279c:	8b 40 48             	mov    0x48(%eax),%eax
  80279f:	c7 44 24 04 bc 27 80 	movl   $0x8027bc,0x4(%esp)
  8027a6:	00 
  8027a7:	89 04 24             	mov    %eax,(%esp)
  8027aa:	e8 aa e7 ff ff       	call   800f59 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027af:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b2:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8027b7:	c9                   	leave  
  8027b8:	c3                   	ret    
  8027b9:	00 00                	add    %al,(%eax)
	...

008027bc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027bc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027bd:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8027c2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8027c4:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  8027c7:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  8027cb:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  8027cd:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  8027d1:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  8027d2:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  8027d5:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  8027d7:	58                   	pop    %eax
	popl %eax
  8027d8:	58                   	pop    %eax

	// Pop all registers back
	popal
  8027d9:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  8027da:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  8027dd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  8027de:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8027df:	c3                   	ret    

008027e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027e0:	55                   	push   %ebp
  8027e1:	89 e5                	mov    %esp,%ebp
  8027e3:	56                   	push   %esi
  8027e4:	53                   	push   %ebx
  8027e5:	83 ec 10             	sub    $0x10,%esp
  8027e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8027eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  8027f1:	85 c0                	test   %eax,%eax
  8027f3:	75 05                	jne    8027fa <ipc_recv+0x1a>
  8027f5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8027fa:	89 04 24             	mov    %eax,(%esp)
  8027fd:	e8 cd e7 ff ff       	call   800fcf <sys_ipc_recv>
	if (from_env_store != NULL)
  802802:	85 db                	test   %ebx,%ebx
  802804:	74 0b                	je     802811 <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802806:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80280c:	8b 52 74             	mov    0x74(%edx),%edx
  80280f:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802811:	85 f6                	test   %esi,%esi
  802813:	74 0b                	je     802820 <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802815:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80281b:	8b 52 78             	mov    0x78(%edx),%edx
  80281e:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802820:	85 c0                	test   %eax,%eax
  802822:	79 16                	jns    80283a <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802824:	85 db                	test   %ebx,%ebx
  802826:	74 06                	je     80282e <ipc_recv+0x4e>
			*from_env_store = 0;
  802828:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  80282e:	85 f6                	test   %esi,%esi
  802830:	74 10                	je     802842 <ipc_recv+0x62>
			*perm_store = 0;
  802832:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802838:	eb 08                	jmp    802842 <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  80283a:	a1 08 50 80 00       	mov    0x805008,%eax
  80283f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802842:	83 c4 10             	add    $0x10,%esp
  802845:	5b                   	pop    %ebx
  802846:	5e                   	pop    %esi
  802847:	5d                   	pop    %ebp
  802848:	c3                   	ret    

00802849 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802849:	55                   	push   %ebp
  80284a:	89 e5                	mov    %esp,%ebp
  80284c:	57                   	push   %edi
  80284d:	56                   	push   %esi
  80284e:	53                   	push   %ebx
  80284f:	83 ec 1c             	sub    $0x1c,%esp
  802852:	8b 75 08             	mov    0x8(%ebp),%esi
  802855:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802858:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  80285b:	eb 2a                	jmp    802887 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  80285d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802860:	74 20                	je     802882 <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802862:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802866:	c7 44 24 08 ec 31 80 	movl   $0x8031ec,0x8(%esp)
  80286d:	00 
  80286e:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  802875:	00 
  802876:	c7 04 24 14 32 80 00 	movl   $0x803214,(%esp)
  80287d:	e8 a2 da ff ff       	call   800324 <_panic>
		sys_yield();
  802882:	e8 13 e5 ff ff       	call   800d9a <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802887:	85 db                	test   %ebx,%ebx
  802889:	75 07                	jne    802892 <ipc_send+0x49>
  80288b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802890:	eb 02                	jmp    802894 <ipc_send+0x4b>
  802892:	89 d8                	mov    %ebx,%eax
  802894:	8b 55 14             	mov    0x14(%ebp),%edx
  802897:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80289b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80289f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8028a3:	89 34 24             	mov    %esi,(%esp)
  8028a6:	e8 01 e7 ff ff       	call   800fac <sys_ipc_try_send>
  8028ab:	85 c0                	test   %eax,%eax
  8028ad:	78 ae                	js     80285d <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  8028af:	83 c4 1c             	add    $0x1c,%esp
  8028b2:	5b                   	pop    %ebx
  8028b3:	5e                   	pop    %esi
  8028b4:	5f                   	pop    %edi
  8028b5:	5d                   	pop    %ebp
  8028b6:	c3                   	ret    

008028b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8028b7:	55                   	push   %ebp
  8028b8:	89 e5                	mov    %esp,%ebp
  8028ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8028bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028c2:	89 c2                	mov    %eax,%edx
  8028c4:	c1 e2 07             	shl    $0x7,%edx
  8028c7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028cd:	8b 52 50             	mov    0x50(%edx),%edx
  8028d0:	39 ca                	cmp    %ecx,%edx
  8028d2:	75 0d                	jne    8028e1 <ipc_find_env+0x2a>
			return envs[i].env_id;
  8028d4:	c1 e0 07             	shl    $0x7,%eax
  8028d7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8028dc:	8b 40 40             	mov    0x40(%eax),%eax
  8028df:	eb 0c                	jmp    8028ed <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028e1:	40                   	inc    %eax
  8028e2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028e7:	75 d9                	jne    8028c2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028e9:	66 b8 00 00          	mov    $0x0,%ax
}
  8028ed:	5d                   	pop    %ebp
  8028ee:	c3                   	ret    
	...

008028f0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8028f0:	55                   	push   %ebp
  8028f1:	89 e5                	mov    %esp,%ebp
  8028f3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8028f6:	89 c2                	mov    %eax,%edx
  8028f8:	c1 ea 16             	shr    $0x16,%edx
  8028fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802902:	f6 c2 01             	test   $0x1,%dl
  802905:	74 1e                	je     802925 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802907:	c1 e8 0c             	shr    $0xc,%eax
  80290a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802911:	a8 01                	test   $0x1,%al
  802913:	74 17                	je     80292c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802915:	c1 e8 0c             	shr    $0xc,%eax
  802918:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80291f:	ef 
  802920:	0f b7 c0             	movzwl %ax,%eax
  802923:	eb 0c                	jmp    802931 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802925:	b8 00 00 00 00       	mov    $0x0,%eax
  80292a:	eb 05                	jmp    802931 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80292c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802931:	5d                   	pop    %ebp
  802932:	c3                   	ret    
	...

00802934 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802934:	55                   	push   %ebp
  802935:	57                   	push   %edi
  802936:	56                   	push   %esi
  802937:	83 ec 10             	sub    $0x10,%esp
  80293a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80293e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802942:	89 74 24 04          	mov    %esi,0x4(%esp)
  802946:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80294a:	89 cd                	mov    %ecx,%ebp
  80294c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802950:	85 c0                	test   %eax,%eax
  802952:	75 2c                	jne    802980 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802954:	39 f9                	cmp    %edi,%ecx
  802956:	77 68                	ja     8029c0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802958:	85 c9                	test   %ecx,%ecx
  80295a:	75 0b                	jne    802967 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80295c:	b8 01 00 00 00       	mov    $0x1,%eax
  802961:	31 d2                	xor    %edx,%edx
  802963:	f7 f1                	div    %ecx
  802965:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802967:	31 d2                	xor    %edx,%edx
  802969:	89 f8                	mov    %edi,%eax
  80296b:	f7 f1                	div    %ecx
  80296d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80296f:	89 f0                	mov    %esi,%eax
  802971:	f7 f1                	div    %ecx
  802973:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802975:	89 f0                	mov    %esi,%eax
  802977:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802979:	83 c4 10             	add    $0x10,%esp
  80297c:	5e                   	pop    %esi
  80297d:	5f                   	pop    %edi
  80297e:	5d                   	pop    %ebp
  80297f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802980:	39 f8                	cmp    %edi,%eax
  802982:	77 2c                	ja     8029b0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802984:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802987:	83 f6 1f             	xor    $0x1f,%esi
  80298a:	75 4c                	jne    8029d8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80298c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80298e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802993:	72 0a                	jb     80299f <__udivdi3+0x6b>
  802995:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802999:	0f 87 ad 00 00 00    	ja     802a4c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80299f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029a4:	89 f0                	mov    %esi,%eax
  8029a6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029a8:	83 c4 10             	add    $0x10,%esp
  8029ab:	5e                   	pop    %esi
  8029ac:	5f                   	pop    %edi
  8029ad:	5d                   	pop    %ebp
  8029ae:	c3                   	ret    
  8029af:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029b0:	31 ff                	xor    %edi,%edi
  8029b2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029b4:	89 f0                	mov    %esi,%eax
  8029b6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029b8:	83 c4 10             	add    $0x10,%esp
  8029bb:	5e                   	pop    %esi
  8029bc:	5f                   	pop    %edi
  8029bd:	5d                   	pop    %ebp
  8029be:	c3                   	ret    
  8029bf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029c0:	89 fa                	mov    %edi,%edx
  8029c2:	89 f0                	mov    %esi,%eax
  8029c4:	f7 f1                	div    %ecx
  8029c6:	89 c6                	mov    %eax,%esi
  8029c8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029ca:	89 f0                	mov    %esi,%eax
  8029cc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029ce:	83 c4 10             	add    $0x10,%esp
  8029d1:	5e                   	pop    %esi
  8029d2:	5f                   	pop    %edi
  8029d3:	5d                   	pop    %ebp
  8029d4:	c3                   	ret    
  8029d5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8029d8:	89 f1                	mov    %esi,%ecx
  8029da:	d3 e0                	shl    %cl,%eax
  8029dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8029e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8029e5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8029e7:	89 ea                	mov    %ebp,%edx
  8029e9:	88 c1                	mov    %al,%cl
  8029eb:	d3 ea                	shr    %cl,%edx
  8029ed:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8029f1:	09 ca                	or     %ecx,%edx
  8029f3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8029f7:	89 f1                	mov    %esi,%ecx
  8029f9:	d3 e5                	shl    %cl,%ebp
  8029fb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8029ff:	89 fd                	mov    %edi,%ebp
  802a01:	88 c1                	mov    %al,%cl
  802a03:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a05:	89 fa                	mov    %edi,%edx
  802a07:	89 f1                	mov    %esi,%ecx
  802a09:	d3 e2                	shl    %cl,%edx
  802a0b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a0f:	88 c1                	mov    %al,%cl
  802a11:	d3 ef                	shr    %cl,%edi
  802a13:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a15:	89 f8                	mov    %edi,%eax
  802a17:	89 ea                	mov    %ebp,%edx
  802a19:	f7 74 24 08          	divl   0x8(%esp)
  802a1d:	89 d1                	mov    %edx,%ecx
  802a1f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a21:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a25:	39 d1                	cmp    %edx,%ecx
  802a27:	72 17                	jb     802a40 <__udivdi3+0x10c>
  802a29:	74 09                	je     802a34 <__udivdi3+0x100>
  802a2b:	89 fe                	mov    %edi,%esi
  802a2d:	31 ff                	xor    %edi,%edi
  802a2f:	e9 41 ff ff ff       	jmp    802975 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802a34:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a38:	89 f1                	mov    %esi,%ecx
  802a3a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a3c:	39 c2                	cmp    %eax,%edx
  802a3e:	73 eb                	jae    802a2b <__udivdi3+0xf7>
		{
		  q0--;
  802a40:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a43:	31 ff                	xor    %edi,%edi
  802a45:	e9 2b ff ff ff       	jmp    802975 <__udivdi3+0x41>
  802a4a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a4c:	31 f6                	xor    %esi,%esi
  802a4e:	e9 22 ff ff ff       	jmp    802975 <__udivdi3+0x41>
	...

00802a54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a54:	55                   	push   %ebp
  802a55:	57                   	push   %edi
  802a56:	56                   	push   %esi
  802a57:	83 ec 20             	sub    $0x20,%esp
  802a5a:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a5e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a62:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a66:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a6a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a6e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a72:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802a74:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802a76:	85 ed                	test   %ebp,%ebp
  802a78:	75 16                	jne    802a90 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802a7a:	39 f1                	cmp    %esi,%ecx
  802a7c:	0f 86 a6 00 00 00    	jbe    802b28 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802a82:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802a84:	89 d0                	mov    %edx,%eax
  802a86:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802a88:	83 c4 20             	add    $0x20,%esp
  802a8b:	5e                   	pop    %esi
  802a8c:	5f                   	pop    %edi
  802a8d:	5d                   	pop    %ebp
  802a8e:	c3                   	ret    
  802a8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802a90:	39 f5                	cmp    %esi,%ebp
  802a92:	0f 87 ac 00 00 00    	ja     802b44 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802a98:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802a9b:	83 f0 1f             	xor    $0x1f,%eax
  802a9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802aa2:	0f 84 a8 00 00 00    	je     802b50 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802aa8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802aac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802aae:	bf 20 00 00 00       	mov    $0x20,%edi
  802ab3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802ab7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802abb:	89 f9                	mov    %edi,%ecx
  802abd:	d3 e8                	shr    %cl,%eax
  802abf:	09 e8                	or     %ebp,%eax
  802ac1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802ac5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ac9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802acd:	d3 e0                	shl    %cl,%eax
  802acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ad3:	89 f2                	mov    %esi,%edx
  802ad5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802ad7:	8b 44 24 14          	mov    0x14(%esp),%eax
  802adb:	d3 e0                	shl    %cl,%eax
  802add:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802ae1:	8b 44 24 14          	mov    0x14(%esp),%eax
  802ae5:	89 f9                	mov    %edi,%ecx
  802ae7:	d3 e8                	shr    %cl,%eax
  802ae9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802aeb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802aed:	89 f2                	mov    %esi,%edx
  802aef:	f7 74 24 18          	divl   0x18(%esp)
  802af3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802af5:	f7 64 24 0c          	mull   0xc(%esp)
  802af9:	89 c5                	mov    %eax,%ebp
  802afb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802afd:	39 d6                	cmp    %edx,%esi
  802aff:	72 67                	jb     802b68 <__umoddi3+0x114>
  802b01:	74 75                	je     802b78 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b03:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b07:	29 e8                	sub    %ebp,%eax
  802b09:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b0f:	d3 e8                	shr    %cl,%eax
  802b11:	89 f2                	mov    %esi,%edx
  802b13:	89 f9                	mov    %edi,%ecx
  802b15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b17:	09 d0                	or     %edx,%eax
  802b19:	89 f2                	mov    %esi,%edx
  802b1b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b1f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b21:	83 c4 20             	add    $0x20,%esp
  802b24:	5e                   	pop    %esi
  802b25:	5f                   	pop    %edi
  802b26:	5d                   	pop    %ebp
  802b27:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b28:	85 c9                	test   %ecx,%ecx
  802b2a:	75 0b                	jne    802b37 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  802b31:	31 d2                	xor    %edx,%edx
  802b33:	f7 f1                	div    %ecx
  802b35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b37:	89 f0                	mov    %esi,%eax
  802b39:	31 d2                	xor    %edx,%edx
  802b3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b3d:	89 f8                	mov    %edi,%eax
  802b3f:	e9 3e ff ff ff       	jmp    802a82 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b46:	83 c4 20             	add    $0x20,%esp
  802b49:	5e                   	pop    %esi
  802b4a:	5f                   	pop    %edi
  802b4b:	5d                   	pop    %ebp
  802b4c:	c3                   	ret    
  802b4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b50:	39 f5                	cmp    %esi,%ebp
  802b52:	72 04                	jb     802b58 <__umoddi3+0x104>
  802b54:	39 f9                	cmp    %edi,%ecx
  802b56:	77 06                	ja     802b5e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b58:	89 f2                	mov    %esi,%edx
  802b5a:	29 cf                	sub    %ecx,%edi
  802b5c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b5e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b60:	83 c4 20             	add    $0x20,%esp
  802b63:	5e                   	pop    %esi
  802b64:	5f                   	pop    %edi
  802b65:	5d                   	pop    %ebp
  802b66:	c3                   	ret    
  802b67:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b68:	89 d1                	mov    %edx,%ecx
  802b6a:	89 c5                	mov    %eax,%ebp
  802b6c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b70:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802b74:	eb 8d                	jmp    802b03 <__umoddi3+0xaf>
  802b76:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b78:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802b7c:	72 ea                	jb     802b68 <__umoddi3+0x114>
  802b7e:	89 f1                	mov    %esi,%ecx
  802b80:	eb 81                	jmp    802b03 <__umoddi3+0xaf>
