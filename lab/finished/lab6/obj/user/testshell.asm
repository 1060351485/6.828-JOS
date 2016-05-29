
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 03 05 00 00       	call   800534 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
  800046:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 3c 24             	mov    %edi,(%esp)
  800050:	e8 3b 1b 00 00       	call   801b90 <seek>
	seek(kfd, off);
  800055:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800059:	89 34 24             	mov    %esi,(%esp)
  80005c:	e8 2f 1b 00 00       	call   801b90 <seek>

	cprintf("shell produced incorrect output.\n");
  800061:	c7 04 24 20 33 80 00 	movl   $0x803320,(%esp)
  800068:	e8 1b 06 00 00       	call   800688 <cprintf>
	cprintf("expected:\n===\n");
  80006d:	c7 04 24 8b 33 80 00 	movl   $0x80338b,(%esp)
  800074:	e8 0f 06 00 00       	call   800688 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800079:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007c:	eb 0c                	jmp    80008a <wrong+0x56>
		sys_cputs(buf, n);
  80007e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800082:	89 1c 24             	mov    %ebx,(%esp)
  800085:	e8 ce 0e 00 00       	call   800f58 <sys_cputs>
	seek(rfd, off);
	seek(kfd, off);

	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  80008a:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 8c 19 00 00       	call   801a2a <read>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	7f dc                	jg     80007e <wrong+0x4a>
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
  8000a2:	c7 04 24 9a 33 80 00 	movl   $0x80339a,(%esp)
  8000a9:	e8 da 05 00 00       	call   800688 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ae:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b1:	eb 0c                	jmp    8000bf <wrong+0x8b>
		sys_cputs(buf, n);
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	89 1c 24             	mov    %ebx,(%esp)
  8000ba:	e8 99 0e 00 00       	call   800f58 <sys_cputs>
	cprintf("shell produced incorrect output.\n");
	cprintf("expected:\n===\n");
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
		sys_cputs(buf, n);
	cprintf("===\ngot:\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bf:	c7 44 24 08 63 00 00 	movl   $0x63,0x8(%esp)
  8000c6:	00 
  8000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cb:	89 3c 24             	mov    %edi,(%esp)
  8000ce:	e8 57 19 00 00       	call   801a2a <read>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f dc                	jg     8000b3 <wrong+0x7f>
		sys_cputs(buf, n);
	cprintf("===\n");
  8000d7:	c7 04 24 95 33 80 00 	movl   $0x803395,(%esp)
  8000de:	e8 a5 05 00 00       	call   800688 <cprintf>
	exit();
  8000e3:	e8 94 04 00 00       	call   80057c <exit>
}
  8000e8:	81 c4 8c 00 00 00    	add    $0x8c,%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <umain>:

void wrong(int, int, int);

void
umain(int argc, char **argv)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 3c             	sub    $0x3c,%esp
	char c1, c2;
	int r, rfd, wfd, kfd, n1, n2, off, nloff;
	int pfds[2];

	close(0);
  8000fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800103:	e8 be 17 00 00       	call   8018c6 <close>
	close(1);
  800108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010f:	e8 b2 17 00 00       	call   8018c6 <close>
	opencons();
  800114:	e8 c7 03 00 00       	call   8004e0 <opencons>
	opencons();
  800119:	e8 c2 03 00 00       	call   8004e0 <opencons>

	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 a8 33 80 00 	movl   $0x8033a8,(%esp)
  80012d:	e8 ce 1d 00 00       	call   801f00 <open>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	79 20                	jns    800158 <umain+0x65>
		panic("open testshell.sh: %e", rfd);
  800138:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013c:	c7 44 24 08 b5 33 80 	movl   $0x8033b5,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  800153:	e8 38 04 00 00       	call   800590 <_panic>
	if ((wfd = pipe(pfds)) < 0)
  800158:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80015b:	89 04 24             	mov    %eax,(%esp)
  80015e:	e8 7e 2b 00 00       	call   802ce1 <pipe>
  800163:	85 c0                	test   %eax,%eax
  800165:	79 20                	jns    800187 <umain+0x94>
		panic("pipe: %e", wfd);
  800167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80016b:	c7 44 24 08 dc 33 80 	movl   $0x8033dc,0x8(%esp)
  800172:	00 
  800173:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80017a:	00 
  80017b:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  800182:	e8 09 04 00 00       	call   800590 <_panic>
	wfd = pfds[1];
  800187:	8b 75 e0             	mov    -0x20(%ebp),%esi

	cprintf("running sh -x < testshell.sh | cat\n");
  80018a:	c7 04 24 44 33 80 00 	movl   $0x803344,(%esp)
  800191:	e8 f2 04 00 00       	call   800688 <cprintf>
	if ((r = fork()) < 0)
  800196:	e8 84 12 00 00       	call   80141f <fork>
  80019b:	85 c0                	test   %eax,%eax
  80019d:	79 20                	jns    8001bf <umain+0xcc>
		panic("fork: %e", r);
  80019f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001a3:	c7 44 24 08 e5 33 80 	movl   $0x8033e5,0x8(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8001b2:	00 
  8001b3:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  8001ba:	e8 d1 03 00 00       	call   800590 <_panic>
	if (r == 0) {
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	0f 85 9f 00 00 00    	jne    800266 <umain+0x173>
		dup(rfd, 0);
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	89 1c 24             	mov    %ebx,(%esp)
  8001d2:	e8 40 17 00 00       	call   801917 <dup>
		dup(wfd, 1);
  8001d7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001de:	00 
  8001df:	89 34 24             	mov    %esi,(%esp)
  8001e2:	e8 30 17 00 00       	call   801917 <dup>
		close(rfd);
  8001e7:	89 1c 24             	mov    %ebx,(%esp)
  8001ea:	e8 d7 16 00 00       	call   8018c6 <close>
		close(wfd);
  8001ef:	89 34 24             	mov    %esi,(%esp)
  8001f2:	e8 cf 16 00 00       	call   8018c6 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  8001f7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 08 ee 33 80 	movl   $0x8033ee,0x8(%esp)
  800206:	00 
  800207:	c7 44 24 04 b2 33 80 	movl   $0x8033b2,0x4(%esp)
  80020e:	00 
  80020f:	c7 04 24 f1 33 80 00 	movl   $0x8033f1,(%esp)
  800216:	e8 87 23 00 00       	call   8025a2 <spawnl>
  80021b:	89 c7                	mov    %eax,%edi
  80021d:	85 c0                	test   %eax,%eax
  80021f:	79 20                	jns    800241 <umain+0x14e>
			panic("spawn: %e", r);
  800221:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800225:	c7 44 24 08 f5 33 80 	movl   $0x8033f5,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  80023c:	e8 4f 03 00 00       	call   800590 <_panic>
		close(0);
  800241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800248:	e8 79 16 00 00       	call   8018c6 <close>
		close(1);
  80024d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800254:	e8 6d 16 00 00       	call   8018c6 <close>
		wait(r);
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	e8 23 2c 00 00       	call   802e84 <wait>
		exit();
  800261:	e8 16 03 00 00       	call   80057c <exit>
	}
	close(rfd);
  800266:	89 1c 24             	mov    %ebx,(%esp)
  800269:	e8 58 16 00 00       	call   8018c6 <close>
	close(wfd);
  80026e:	89 34 24             	mov    %esi,(%esp)
  800271:	e8 50 16 00 00       	call   8018c6 <close>

	rfd = pfds[0];
  800276:	8b 7d dc             	mov    -0x24(%ebp),%edi
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  800279:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 ff 33 80 00 	movl   $0x8033ff,(%esp)
  800288:	e8 73 1c 00 00       	call   801f00 <open>
  80028d:	89 c6                	mov    %eax,%esi
  80028f:	85 c0                	test   %eax,%eax
  800291:	79 20                	jns    8002b3 <umain+0x1c0>
		panic("open testshell.key for reading: %e", kfd);
  800293:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800297:	c7 44 24 08 68 33 80 	movl   $0x803368,0x8(%esp)
  80029e:	00 
  80029f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8002a6:	00 
  8002a7:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  8002ae:	e8 dd 02 00 00       	call   800590 <_panic>
	}
	close(rfd);
	close(wfd);

	rfd = pfds[0];
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8002b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  8002ba:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		panic("open testshell.key for reading: %e", kfd);

	nloff = 0;
	for (off=0;; off++) {
		n1 = read(rfd, &c1, 1);
  8002c1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002c8:	00 
  8002c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d0:	89 3c 24             	mov    %edi,(%esp)
  8002d3:	e8 52 17 00 00       	call   801a2a <read>
  8002d8:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8002e1:	00 
  8002e2:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e9:	89 34 24             	mov    %esi,(%esp)
  8002ec:	e8 39 17 00 00       	call   801a2a <read>
		if (n1 < 0)
  8002f1:	85 db                	test   %ebx,%ebx
  8002f3:	79 20                	jns    800315 <umain+0x222>
			panic("reading testshell.out: %e", n1);
  8002f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f9:	c7 44 24 08 0d 34 80 	movl   $0x80340d,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  800310:	e8 7b 02 00 00       	call   800590 <_panic>
		if (n2 < 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	79 20                	jns    800339 <umain+0x246>
			panic("reading testshell.key: %e", n2);
  800319:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031d:	c7 44 24 08 27 34 80 	movl   $0x803427,0x8(%esp)
  800324:	00 
  800325:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  80032c:	00 
  80032d:	c7 04 24 cb 33 80 00 	movl   $0x8033cb,(%esp)
  800334:	e8 57 02 00 00       	call   800590 <_panic>
		if (n1 == 0 && n2 == 0)
  800339:	85 db                	test   %ebx,%ebx
  80033b:	75 06                	jne    800343 <umain+0x250>
  80033d:	85 c0                	test   %eax,%eax
  80033f:	75 14                	jne    800355 <umain+0x262>
  800341:	eb 39                	jmp    80037c <umain+0x289>
			break;
		if (n1 != 1 || n2 != 1 || c1 != c2)
  800343:	83 fb 01             	cmp    $0x1,%ebx
  800346:	75 0d                	jne    800355 <umain+0x262>
  800348:	83 f8 01             	cmp    $0x1,%eax
  80034b:	75 08                	jne    800355 <umain+0x262>
  80034d:	8a 45 e6             	mov    -0x1a(%ebp),%al
  800350:	38 45 e7             	cmp    %al,-0x19(%ebp)
  800353:	74 13                	je     800368 <umain+0x275>
			wrong(rfd, kfd, nloff);
  800355:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800360:	89 3c 24             	mov    %edi,(%esp)
  800363:	e8 cc fc ff ff       	call   800034 <wrong>
		if (c1 == '\n')
  800368:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  80036c:	75 06                	jne    800374 <umain+0x281>
			nloff = off+1;
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800374:	ff 45 d4             	incl   -0x2c(%ebp)
	}
  800377:	e9 45 ff ff ff       	jmp    8002c1 <umain+0x1ce>
	cprintf("shell ran correctly\n");
  80037c:	c7 04 24 41 34 80 00 	movl   $0x803441,(%esp)
  800383:	e8 00 03 00 00       	call   800688 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  800388:	cc                   	int3   

	breakpoint();
}
  800389:	83 c4 3c             	add    $0x3c,%esp
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    
  800391:	00 00                	add    %al,(%eax)
	...

00800394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8003a4:	c7 44 24 04 56 34 80 	movl   $0x803456,0x4(%esp)
  8003ab:	00 
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	e8 7c 08 00 00       	call   800c33 <strcpy>
	return 0;
}
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8003cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8003d5:	eb 30                	jmp    800407 <devcons_write+0x49>
		m = n - tot;
  8003d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8003da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8003dc:	83 fe 7f             	cmp    $0x7f,%esi
  8003df:	76 05                	jbe    8003e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8003e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8003e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003ea:	03 45 0c             	add    0xc(%ebp),%eax
  8003ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f1:	89 3c 24             	mov    %edi,(%esp)
  8003f4:	e8 b3 09 00 00       	call   800dac <memmove>
		sys_cputs(buf, m);
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	89 3c 24             	mov    %edi,(%esp)
  800400:	e8 53 0b 00 00       	call   800f58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800405:	01 f3                	add    %esi,%ebx
  800407:	89 d8                	mov    %ebx,%eax
  800409:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80040c:	72 c9                	jb     8003d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80040e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800414:	5b                   	pop    %ebx
  800415:	5e                   	pop    %esi
  800416:	5f                   	pop    %edi
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80041f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800423:	75 07                	jne    80042c <devcons_read+0x13>
  800425:	eb 25                	jmp    80044c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800427:	e8 da 0b 00 00       	call   801006 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80042c:	e8 45 0b 00 00       	call   800f76 <sys_cgetc>
  800431:	85 c0                	test   %eax,%eax
  800433:	74 f2                	je     800427 <devcons_read+0xe>
  800435:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  800437:	85 c0                	test   %eax,%eax
  800439:	78 1d                	js     800458 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80043b:	83 f8 04             	cmp    $0x4,%eax
  80043e:	74 13                	je     800453 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	88 10                	mov    %dl,(%eax)
	return 1;
  800445:	b8 01 00 00 00       	mov    $0x1,%eax
  80044a:	eb 0c                	jmp    800458 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	eb 05                	jmp    800458 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800458:	c9                   	leave  
  800459:	c3                   	ret    

0080045a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800460:	8b 45 08             	mov    0x8(%ebp),%eax
  800463:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80046d:	00 
  80046e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 df 0a 00 00       	call   800f58 <sys_cputs>
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <getchar>:

int
getchar(void)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800488:	00 
  800489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800497:	e8 8e 15 00 00       	call   801a2a <read>
	if (r < 0)
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 0f                	js     8004af <getchar+0x34>
		return r;
	if (r < 1)
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	7e 06                	jle    8004aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8004a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8004a8:	eb 05                	jmp    8004af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8004aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8004af:	c9                   	leave  
  8004b0:	c3                   	ret    

008004b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 c5 12 00 00       	call   80178e <fd_lookup>
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	78 11                	js     8004de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8004cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8004d6:	39 10                	cmp    %edx,(%eax)
  8004d8:	0f 94 c0             	sete   %al
  8004db:	0f b6 c0             	movzbl %al,%eax
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <opencons>:

int
opencons(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8004e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 4a 12 00 00       	call   80173b <fd_alloc>
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 3c                	js     800531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8004f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8004fc:	00 
  8004fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800500:	89 44 24 04          	mov    %eax,0x4(%esp)
  800504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050b:	e8 15 0b 00 00       	call   801025 <sys_page_alloc>
  800510:	85 c0                	test   %eax,%eax
  800512:	78 1d                	js     800531 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800514:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80051a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80051d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80051f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 df 11 00 00       	call   801710 <fd2num>
}
  800531:	c9                   	leave  
  800532:	c3                   	ret    
	...

00800534 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 10             	sub    $0x10,%esp
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800542:	e8 a0 0a 00 00       	call   800fe7 <sys_getenvid>
  800547:	25 ff 03 00 00       	and    $0x3ff,%eax
  80054c:	c1 e0 07             	shl    $0x7,%eax
  80054f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800554:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800559:	85 f6                	test   %esi,%esi
  80055b:	7e 07                	jle    800564 <libmain+0x30>
		binaryname = argv[0];
  80055d:	8b 03                	mov    (%ebx),%eax
  80055f:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800564:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800568:	89 34 24             	mov    %esi,(%esp)
  80056b:	e8 83 fb ff ff       	call   8000f3 <umain>

	// exit gracefully
	exit();
  800570:	e8 07 00 00 00       	call   80057c <exit>
}
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	5b                   	pop    %ebx
  800579:	5e                   	pop    %esi
  80057a:	5d                   	pop    %ebp
  80057b:	c3                   	ret    

0080057c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800582:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800589:	e8 07 0a 00 00       	call   800f95 <sys_env_destroy>
}
  80058e:	c9                   	leave  
  80058f:	c3                   	ret    

00800590 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	56                   	push   %esi
  800594:	53                   	push   %ebx
  800595:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800598:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80059b:	8b 1d 1c 40 80 00    	mov    0x80401c,%ebx
  8005a1:	e8 41 0a 00 00       	call   800fe7 <sys_getenvid>
  8005a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bc:	c7 04 24 6c 34 80 00 	movl   $0x80346c,(%esp)
  8005c3:	e8 c0 00 00 00       	call   800688 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8005c8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 50 00 00 00       	call   800627 <vcprintf>
	cprintf("\n");
  8005d7:	c7 04 24 98 33 80 00 	movl   $0x803398,(%esp)
  8005de:	e8 a5 00 00 00       	call   800688 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8005e3:	cc                   	int3   
  8005e4:	eb fd                	jmp    8005e3 <_panic+0x53>
	...

008005e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	53                   	push   %ebx
  8005ec:	83 ec 14             	sub    $0x14,%esp
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005f2:	8b 03                	mov    (%ebx),%eax
  8005f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005fb:	40                   	inc    %eax
  8005fc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800603:	75 19                	jne    80061e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800605:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80060c:	00 
  80060d:	8d 43 08             	lea    0x8(%ebx),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	e8 40 09 00 00       	call   800f58 <sys_cputs>
		b->idx = 0;
  800618:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80061e:	ff 43 04             	incl   0x4(%ebx)
}
  800621:	83 c4 14             	add    $0x14,%esp
  800624:	5b                   	pop    %ebx
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800630:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800637:	00 00 00 
	b.cnt = 0;
  80063a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800641:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800644:	8b 45 0c             	mov    0xc(%ebp),%eax
  800647:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800652:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	c7 04 24 e8 05 80 00 	movl   $0x8005e8,(%esp)
  800663:	e8 82 01 00 00       	call   8007ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800668:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	e8 d8 08 00 00       	call   800f58 <sys_cputs>

	return b.cnt;
}
  800680:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80068e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800691:	89 44 24 04          	mov    %eax,0x4(%esp)
  800695:	8b 45 08             	mov    0x8(%ebp),%eax
  800698:	89 04 24             	mov    %eax,(%esp)
  80069b:	e8 87 ff ff ff       	call   800627 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006a0:	c9                   	leave  
  8006a1:	c3                   	ret    
	...

008006a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	57                   	push   %edi
  8006a8:	56                   	push   %esi
  8006a9:	53                   	push   %ebx
  8006aa:	83 ec 3c             	sub    $0x3c,%esp
  8006ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b0:	89 d7                	mov    %edx,%edi
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006be:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8006c1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	75 08                	jne    8006d0 <printnum+0x2c>
  8006c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8006ce:	77 57                	ja     800727 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006d0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006d4:	4b                   	dec    %ebx
  8006d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006e4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8006e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006ef:	00 
  8006f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006f3:	89 04 24             	mov    %eax,(%esp)
  8006f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fd:	e8 ce 29 00 00       	call   8030d0 <__udivdi3>
  800702:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800706:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800711:	89 fa                	mov    %edi,%edx
  800713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800716:	e8 89 ff ff ff       	call   8006a4 <printnum>
  80071b:	eb 0f                	jmp    80072c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80071d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800721:	89 34 24             	mov    %esi,(%esp)
  800724:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800727:	4b                   	dec    %ebx
  800728:	85 db                	test   %ebx,%ebx
  80072a:	7f f1                	jg     80071d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80072c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800730:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800734:	8b 45 10             	mov    0x10(%ebp),%eax
  800737:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800742:	00 
  800743:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800746:	89 04 24             	mov    %eax,(%esp)
  800749:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80074c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800750:	e8 9b 2a 00 00       	call   8031f0 <__umoddi3>
  800755:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800759:	0f be 80 8f 34 80 00 	movsbl 0x80348f(%eax),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800766:	83 c4 3c             	add    $0x3c,%esp
  800769:	5b                   	pop    %ebx
  80076a:	5e                   	pop    %esi
  80076b:	5f                   	pop    %edi
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800771:	83 fa 01             	cmp    $0x1,%edx
  800774:	7e 0e                	jle    800784 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800776:	8b 10                	mov    (%eax),%edx
  800778:	8d 4a 08             	lea    0x8(%edx),%ecx
  80077b:	89 08                	mov    %ecx,(%eax)
  80077d:	8b 02                	mov    (%edx),%eax
  80077f:	8b 52 04             	mov    0x4(%edx),%edx
  800782:	eb 22                	jmp    8007a6 <getuint+0x38>
	else if (lflag)
  800784:	85 d2                	test   %edx,%edx
  800786:	74 10                	je     800798 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80078d:	89 08                	mov    %ecx,(%eax)
  80078f:	8b 02                	mov    (%edx),%eax
  800791:	ba 00 00 00 00       	mov    $0x0,%edx
  800796:	eb 0e                	jmp    8007a6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800798:	8b 10                	mov    (%eax),%edx
  80079a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80079d:	89 08                	mov    %ecx,(%eax)
  80079f:	8b 02                	mov    (%edx),%eax
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007ae:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007b1:	8b 10                	mov    (%eax),%edx
  8007b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8007b6:	73 08                	jae    8007c0 <sprintputch+0x18>
		*b->buf++ = ch;
  8007b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bb:	88 0a                	mov    %cl,(%edx)
  8007bd:	42                   	inc    %edx
  8007be:	89 10                	mov    %edx,(%eax)
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8007c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cf:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	89 04 24             	mov    %eax,(%esp)
  8007e3:	e8 02 00 00 00       	call   8007ea <vprintfmt>
	va_end(ap);
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	57                   	push   %edi
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	83 ec 4c             	sub    $0x4c,%esp
  8007f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007f6:	8b 75 10             	mov    0x10(%ebp),%esi
  8007f9:	eb 12                	jmp    80080d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007fb:	85 c0                	test   %eax,%eax
  8007fd:	0f 84 6b 03 00 00    	je     800b6e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800803:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800807:	89 04 24             	mov    %eax,(%esp)
  80080a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80080d:	0f b6 06             	movzbl (%esi),%eax
  800810:	46                   	inc    %esi
  800811:	83 f8 25             	cmp    $0x25,%eax
  800814:	75 e5                	jne    8007fb <vprintfmt+0x11>
  800816:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80081a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800821:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800826:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800832:	eb 26                	jmp    80085a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800837:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80083b:	eb 1d                	jmp    80085a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800840:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800844:	eb 14                	jmp    80085a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800846:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800849:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800850:	eb 08                	jmp    80085a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800852:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800855:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	0f b6 06             	movzbl (%esi),%eax
  80085d:	8d 56 01             	lea    0x1(%esi),%edx
  800860:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800863:	8a 16                	mov    (%esi),%dl
  800865:	83 ea 23             	sub    $0x23,%edx
  800868:	80 fa 55             	cmp    $0x55,%dl
  80086b:	0f 87 e1 02 00 00    	ja     800b52 <vprintfmt+0x368>
  800871:	0f b6 d2             	movzbl %dl,%edx
  800874:	ff 24 95 e0 35 80 00 	jmp    *0x8035e0(,%edx,4)
  80087b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80087e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800883:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800886:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80088a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80088d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800890:	83 fa 09             	cmp    $0x9,%edx
  800893:	77 2a                	ja     8008bf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800895:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800896:	eb eb                	jmp    800883 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 04             	lea    0x4(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008a6:	eb 17                	jmp    8008bf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ac:	78 98                	js     800846 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008b1:	eb a7                	jmp    80085a <vprintfmt+0x70>
  8008b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008bd:	eb 9b                	jmp    80085a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8008bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c3:	79 95                	jns    80085a <vprintfmt+0x70>
  8008c5:	eb 8b                	jmp    800852 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008c7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008cb:	eb 8d                	jmp    80085a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 50 04             	lea    0x4(%eax),%edx
  8008d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008da:	8b 00                	mov    (%eax),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008e5:	e9 23 ff ff ff       	jmp    80080d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8d 50 04             	lea    0x4(%eax),%edx
  8008f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f3:	8b 00                	mov    (%eax),%eax
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	79 02                	jns    8008fb <vprintfmt+0x111>
  8008f9:	f7 d8                	neg    %eax
  8008fb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008fd:	83 f8 11             	cmp    $0x11,%eax
  800900:	7f 0b                	jg     80090d <vprintfmt+0x123>
  800902:	8b 04 85 40 37 80 00 	mov    0x803740(,%eax,4),%eax
  800909:	85 c0                	test   %eax,%eax
  80090b:	75 23                	jne    800930 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80090d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800911:	c7 44 24 08 a7 34 80 	movl   $0x8034a7,0x8(%esp)
  800918:	00 
  800919:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	89 04 24             	mov    %eax,(%esp)
  800923:	e8 9a fe ff ff       	call   8007c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800928:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80092b:	e9 dd fe ff ff       	jmp    80080d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800930:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800934:	c7 44 24 08 6d 39 80 	movl   $0x80396d,0x8(%esp)
  80093b:	00 
  80093c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800940:	8b 55 08             	mov    0x8(%ebp),%edx
  800943:	89 14 24             	mov    %edx,(%esp)
  800946:	e8 77 fe ff ff       	call   8007c2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80094e:	e9 ba fe ff ff       	jmp    80080d <vprintfmt+0x23>
  800953:	89 f9                	mov    %edi,%ecx
  800955:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800958:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80095b:	8b 45 14             	mov    0x14(%ebp),%eax
  80095e:	8d 50 04             	lea    0x4(%eax),%edx
  800961:	89 55 14             	mov    %edx,0x14(%ebp)
  800964:	8b 30                	mov    (%eax),%esi
  800966:	85 f6                	test   %esi,%esi
  800968:	75 05                	jne    80096f <vprintfmt+0x185>
				p = "(null)";
  80096a:	be a0 34 80 00       	mov    $0x8034a0,%esi
			if (width > 0 && padc != '-')
  80096f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800973:	0f 8e 84 00 00 00    	jle    8009fd <vprintfmt+0x213>
  800979:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80097d:	74 7e                	je     8009fd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80097f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800983:	89 34 24             	mov    %esi,(%esp)
  800986:	e8 8b 02 00 00       	call   800c16 <strnlen>
  80098b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80098e:	29 c2                	sub    %eax,%edx
  800990:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800993:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800997:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80099a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80099d:	89 de                	mov    %ebx,%esi
  80099f:	89 d3                	mov    %edx,%ebx
  8009a1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a3:	eb 0b                	jmp    8009b0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a9:	89 3c 24             	mov    %edi,(%esp)
  8009ac:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009af:	4b                   	dec    %ebx
  8009b0:	85 db                	test   %ebx,%ebx
  8009b2:	7f f1                	jg     8009a5 <vprintfmt+0x1bb>
  8009b4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009b7:	89 f3                	mov    %esi,%ebx
  8009b9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8009bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009bf:	85 c0                	test   %eax,%eax
  8009c1:	79 05                	jns    8009c8 <vprintfmt+0x1de>
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009cb:	29 c2                	sub    %eax,%edx
  8009cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8009d0:	eb 2b                	jmp    8009fd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009d6:	74 18                	je     8009f0 <vprintfmt+0x206>
  8009d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8009db:	83 fa 5e             	cmp    $0x5e,%edx
  8009de:	76 10                	jbe    8009f0 <vprintfmt+0x206>
					putch('?', putdat);
  8009e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009eb:	ff 55 08             	call   *0x8(%ebp)
  8009ee:	eb 0a                	jmp    8009fa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8009f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f4:	89 04 24             	mov    %eax,(%esp)
  8009f7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009fa:	ff 4d e4             	decl   -0x1c(%ebp)
  8009fd:	0f be 06             	movsbl (%esi),%eax
  800a00:	46                   	inc    %esi
  800a01:	85 c0                	test   %eax,%eax
  800a03:	74 21                	je     800a26 <vprintfmt+0x23c>
  800a05:	85 ff                	test   %edi,%edi
  800a07:	78 c9                	js     8009d2 <vprintfmt+0x1e8>
  800a09:	4f                   	dec    %edi
  800a0a:	79 c6                	jns    8009d2 <vprintfmt+0x1e8>
  800a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0f:	89 de                	mov    %ebx,%esi
  800a11:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a14:	eb 18                	jmp    800a2e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a1a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a21:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a23:	4b                   	dec    %ebx
  800a24:	eb 08                	jmp    800a2e <vprintfmt+0x244>
  800a26:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a29:	89 de                	mov    %ebx,%esi
  800a2b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a2e:	85 db                	test   %ebx,%ebx
  800a30:	7f e4                	jg     800a16 <vprintfmt+0x22c>
  800a32:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a35:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a37:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a3a:	e9 ce fd ff ff       	jmp    80080d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a3f:	83 f9 01             	cmp    $0x1,%ecx
  800a42:	7e 10                	jle    800a54 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a44:	8b 45 14             	mov    0x14(%ebp),%eax
  800a47:	8d 50 08             	lea    0x8(%eax),%edx
  800a4a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a4d:	8b 30                	mov    (%eax),%esi
  800a4f:	8b 78 04             	mov    0x4(%eax),%edi
  800a52:	eb 26                	jmp    800a7a <vprintfmt+0x290>
	else if (lflag)
  800a54:	85 c9                	test   %ecx,%ecx
  800a56:	74 12                	je     800a6a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a58:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5b:	8d 50 04             	lea    0x4(%eax),%edx
  800a5e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a61:	8b 30                	mov    (%eax),%esi
  800a63:	89 f7                	mov    %esi,%edi
  800a65:	c1 ff 1f             	sar    $0x1f,%edi
  800a68:	eb 10                	jmp    800a7a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6d:	8d 50 04             	lea    0x4(%eax),%edx
  800a70:	89 55 14             	mov    %edx,0x14(%ebp)
  800a73:	8b 30                	mov    (%eax),%esi
  800a75:	89 f7                	mov    %esi,%edi
  800a77:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	78 0a                	js     800a88 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a83:	e9 8c 00 00 00       	jmp    800b14 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a8c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a93:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a96:	f7 de                	neg    %esi
  800a98:	83 d7 00             	adc    $0x0,%edi
  800a9b:	f7 df                	neg    %edi
			}
			base = 10;
  800a9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa2:	eb 70                	jmp    800b14 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aa4:	89 ca                	mov    %ecx,%edx
  800aa6:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa9:	e8 c0 fc ff ff       	call   80076e <getuint>
  800aae:	89 c6                	mov    %eax,%esi
  800ab0:	89 d7                	mov    %edx,%edi
			base = 10;
  800ab2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800ab7:	eb 5b                	jmp    800b14 <vprintfmt+0x32a>
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('0', putdat);
			num = getuint(&ap, lflag);
  800ab9:	89 ca                	mov    %ecx,%edx
  800abb:	8d 45 14             	lea    0x14(%ebp),%eax
  800abe:	e8 ab fc ff ff       	call   80076e <getuint>
  800ac3:	89 c6                	mov    %eax,%esi
  800ac5:	89 d7                	mov    %edx,%edi
			base = 8;
  800ac7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800acc:	eb 46                	jmp    800b14 <vprintfmt+0x32a>
			//break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ace:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ad9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800adc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ae7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800aea:	8b 45 14             	mov    0x14(%ebp),%eax
  800aed:	8d 50 04             	lea    0x4(%eax),%edx
  800af0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800af3:	8b 30                	mov    (%eax),%esi
  800af5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800afa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800aff:	eb 13                	jmp    800b14 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b01:	89 ca                	mov    %ecx,%edx
  800b03:	8d 45 14             	lea    0x14(%ebp),%eax
  800b06:	e8 63 fc ff ff       	call   80076e <getuint>
  800b0b:	89 c6                	mov    %eax,%esi
  800b0d:	89 d7                	mov    %edx,%edi
			base = 16;
  800b0f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b14:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b18:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b1f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b27:	89 34 24             	mov    %esi,(%esp)
  800b2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b2e:	89 da                	mov    %ebx,%edx
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	e8 6c fb ff ff       	call   8006a4 <printnum>
			break;
  800b38:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b3b:	e9 cd fc ff ff       	jmp    80080d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b44:	89 04 24             	mov    %eax,(%esp)
  800b47:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b4a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b4d:	e9 bb fc ff ff       	jmp    80080d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b56:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b5d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b60:	eb 01                	jmp    800b63 <vprintfmt+0x379>
  800b62:	4e                   	dec    %esi
  800b63:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b67:	75 f9                	jne    800b62 <vprintfmt+0x378>
  800b69:	e9 9f fc ff ff       	jmp    80080d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b6e:	83 c4 4c             	add    $0x4c,%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 28             	sub    $0x28,%esp
  800b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b82:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b85:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b89:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	74 30                	je     800bc7 <vsnprintf+0x51>
  800b97:	85 d2                	test   %edx,%edx
  800b99:	7e 33                	jle    800bce <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb0:	c7 04 24 a8 07 80 00 	movl   $0x8007a8,(%esp)
  800bb7:	e8 2e fc ff ff       	call   8007ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc5:	eb 0c                	jmp    800bd3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bcc:	eb 05                	jmp    800bd3 <vsnprintf+0x5d>
  800bce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bdb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800bde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be2:	8b 45 10             	mov    0x10(%ebp),%eax
  800be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	89 04 24             	mov    %eax,(%esp)
  800bf6:	e8 7b ff ff ff       	call   800b76 <vsnprintf>
	va_end(ap);

	return rc;
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    
  800bfd:	00 00                	add    %al,(%eax)
	...

00800c00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0b:	eb 01                	jmp    800c0e <strlen+0xe>
		n++;
  800c0d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c0e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c12:	75 f9                	jne    800c0d <strlen+0xd>
		n++;
	return n;
}
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	eb 01                	jmp    800c27 <strnlen+0x11>
		n++;
  800c26:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c27:	39 d0                	cmp    %edx,%eax
  800c29:	74 06                	je     800c31 <strnlen+0x1b>
  800c2b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c2f:	75 f5                	jne    800c26 <strnlen+0x10>
		n++;
	return n;
}
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	53                   	push   %ebx
  800c37:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c45:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c48:	42                   	inc    %edx
  800c49:	84 c9                	test   %cl,%cl
  800c4b:	75 f5                	jne    800c42 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c4d:	5b                   	pop    %ebx
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	53                   	push   %ebx
  800c54:	83 ec 08             	sub    $0x8,%esp
  800c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c5a:	89 1c 24             	mov    %ebx,(%esp)
  800c5d:	e8 9e ff ff ff       	call   800c00 <strlen>
	strcpy(dst + len, src);
  800c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c65:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c69:	01 d8                	add    %ebx,%eax
  800c6b:	89 04 24             	mov    %eax,(%esp)
  800c6e:	e8 c0 ff ff ff       	call   800c33 <strcpy>
	return dst;
}
  800c73:	89 d8                	mov    %ebx,%eax
  800c75:	83 c4 08             	add    $0x8,%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c86:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8e:	eb 0c                	jmp    800c9c <strncpy+0x21>
		*dst++ = *src;
  800c90:	8a 1a                	mov    (%edx),%bl
  800c92:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c95:	80 3a 01             	cmpb   $0x1,(%edx)
  800c98:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9b:	41                   	inc    %ecx
  800c9c:	39 f1                	cmp    %esi,%ecx
  800c9e:	75 f0                	jne    800c90 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	8b 75 08             	mov    0x8(%ebp),%esi
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cb2:	85 d2                	test   %edx,%edx
  800cb4:	75 0a                	jne    800cc0 <strlcpy+0x1c>
  800cb6:	89 f0                	mov    %esi,%eax
  800cb8:	eb 1a                	jmp    800cd4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cba:	88 18                	mov    %bl,(%eax)
  800cbc:	40                   	inc    %eax
  800cbd:	41                   	inc    %ecx
  800cbe:	eb 02                	jmp    800cc2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cc0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800cc2:	4a                   	dec    %edx
  800cc3:	74 0a                	je     800ccf <strlcpy+0x2b>
  800cc5:	8a 19                	mov    (%ecx),%bl
  800cc7:	84 db                	test   %bl,%bl
  800cc9:	75 ef                	jne    800cba <strlcpy+0x16>
  800ccb:	89 c2                	mov    %eax,%edx
  800ccd:	eb 02                	jmp    800cd1 <strlcpy+0x2d>
  800ccf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800cd1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800cd4:	29 f0                	sub    %esi,%eax
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ce3:	eb 02                	jmp    800ce7 <strcmp+0xd>
		p++, q++;
  800ce5:	41                   	inc    %ecx
  800ce6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ce7:	8a 01                	mov    (%ecx),%al
  800ce9:	84 c0                	test   %al,%al
  800ceb:	74 04                	je     800cf1 <strcmp+0x17>
  800ced:	3a 02                	cmp    (%edx),%al
  800cef:	74 f4                	je     800ce5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cf1:	0f b6 c0             	movzbl %al,%eax
  800cf4:	0f b6 12             	movzbl (%edx),%edx
  800cf7:	29 d0                	sub    %edx,%eax
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	53                   	push   %ebx
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d08:	eb 03                	jmp    800d0d <strncmp+0x12>
		n--, p++, q++;
  800d0a:	4a                   	dec    %edx
  800d0b:	40                   	inc    %eax
  800d0c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d0d:	85 d2                	test   %edx,%edx
  800d0f:	74 14                	je     800d25 <strncmp+0x2a>
  800d11:	8a 18                	mov    (%eax),%bl
  800d13:	84 db                	test   %bl,%bl
  800d15:	74 04                	je     800d1b <strncmp+0x20>
  800d17:	3a 19                	cmp    (%ecx),%bl
  800d19:	74 ef                	je     800d0a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d1b:	0f b6 00             	movzbl (%eax),%eax
  800d1e:	0f b6 11             	movzbl (%ecx),%edx
  800d21:	29 d0                	sub    %edx,%eax
  800d23:	eb 05                	jmp    800d2a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d2a:	5b                   	pop    %ebx
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d36:	eb 05                	jmp    800d3d <strchr+0x10>
		if (*s == c)
  800d38:	38 ca                	cmp    %cl,%dl
  800d3a:	74 0c                	je     800d48 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d3c:	40                   	inc    %eax
  800d3d:	8a 10                	mov    (%eax),%dl
  800d3f:	84 d2                	test   %dl,%dl
  800d41:	75 f5                	jne    800d38 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d53:	eb 05                	jmp    800d5a <strfind+0x10>
		if (*s == c)
  800d55:	38 ca                	cmp    %cl,%dl
  800d57:	74 07                	je     800d60 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d59:	40                   	inc    %eax
  800d5a:	8a 10                	mov    (%eax),%dl
  800d5c:	84 d2                	test   %dl,%dl
  800d5e:	75 f5                	jne    800d55 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d71:	85 c9                	test   %ecx,%ecx
  800d73:	74 30                	je     800da5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d7b:	75 25                	jne    800da2 <memset+0x40>
  800d7d:	f6 c1 03             	test   $0x3,%cl
  800d80:	75 20                	jne    800da2 <memset+0x40>
		c &= 0xFF;
  800d82:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d85:	89 d3                	mov    %edx,%ebx
  800d87:	c1 e3 08             	shl    $0x8,%ebx
  800d8a:	89 d6                	mov    %edx,%esi
  800d8c:	c1 e6 18             	shl    $0x18,%esi
  800d8f:	89 d0                	mov    %edx,%eax
  800d91:	c1 e0 10             	shl    $0x10,%eax
  800d94:	09 f0                	or     %esi,%eax
  800d96:	09 d0                	or     %edx,%eax
  800d98:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d9a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d9d:	fc                   	cld    
  800d9e:	f3 ab                	rep stos %eax,%es:(%edi)
  800da0:	eb 03                	jmp    800da5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800da2:	fc                   	cld    
  800da3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800da5:	89 f8                	mov    %edi,%eax
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800db7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dba:	39 c6                	cmp    %eax,%esi
  800dbc:	73 34                	jae    800df2 <memmove+0x46>
  800dbe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dc1:	39 d0                	cmp    %edx,%eax
  800dc3:	73 2d                	jae    800df2 <memmove+0x46>
		s += n;
		d += n;
  800dc5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc8:	f6 c2 03             	test   $0x3,%dl
  800dcb:	75 1b                	jne    800de8 <memmove+0x3c>
  800dcd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd3:	75 13                	jne    800de8 <memmove+0x3c>
  800dd5:	f6 c1 03             	test   $0x3,%cl
  800dd8:	75 0e                	jne    800de8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800dda:	83 ef 04             	sub    $0x4,%edi
  800ddd:	8d 72 fc             	lea    -0x4(%edx),%esi
  800de0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800de3:	fd                   	std    
  800de4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800de6:	eb 07                	jmp    800def <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800de8:	4f                   	dec    %edi
  800de9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dec:	fd                   	std    
  800ded:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800def:	fc                   	cld    
  800df0:	eb 20                	jmp    800e12 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800df8:	75 13                	jne    800e0d <memmove+0x61>
  800dfa:	a8 03                	test   $0x3,%al
  800dfc:	75 0f                	jne    800e0d <memmove+0x61>
  800dfe:	f6 c1 03             	test   $0x3,%cl
  800e01:	75 0a                	jne    800e0d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e03:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e06:	89 c7                	mov    %eax,%edi
  800e08:	fc                   	cld    
  800e09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e0b:	eb 05                	jmp    800e12 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e0d:	89 c7                	mov    %eax,%edi
  800e0f:	fc                   	cld    
  800e10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	89 04 24             	mov    %eax,(%esp)
  800e30:	e8 77 ff ff ff       	call   800dac <memmove>
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e46:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4b:	eb 16                	jmp    800e63 <memcmp+0x2c>
		if (*s1 != *s2)
  800e4d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e50:	42                   	inc    %edx
  800e51:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e55:	38 c8                	cmp    %cl,%al
  800e57:	74 0a                	je     800e63 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e59:	0f b6 c0             	movzbl %al,%eax
  800e5c:	0f b6 c9             	movzbl %cl,%ecx
  800e5f:	29 c8                	sub    %ecx,%eax
  800e61:	eb 09                	jmp    800e6c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e63:	39 da                	cmp    %ebx,%edx
  800e65:	75 e6                	jne    800e4d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e7a:	89 c2                	mov    %eax,%edx
  800e7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e7f:	eb 05                	jmp    800e86 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e81:	38 08                	cmp    %cl,(%eax)
  800e83:	74 05                	je     800e8a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e85:	40                   	inc    %eax
  800e86:	39 d0                	cmp    %edx,%eax
  800e88:	72 f7                	jb     800e81 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e98:	eb 01                	jmp    800e9b <strtol+0xf>
		s++;
  800e9a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e9b:	8a 02                	mov    (%edx),%al
  800e9d:	3c 20                	cmp    $0x20,%al
  800e9f:	74 f9                	je     800e9a <strtol+0xe>
  800ea1:	3c 09                	cmp    $0x9,%al
  800ea3:	74 f5                	je     800e9a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ea5:	3c 2b                	cmp    $0x2b,%al
  800ea7:	75 08                	jne    800eb1 <strtol+0x25>
		s++;
  800ea9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800eaa:	bf 00 00 00 00       	mov    $0x0,%edi
  800eaf:	eb 13                	jmp    800ec4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800eb1:	3c 2d                	cmp    $0x2d,%al
  800eb3:	75 0a                	jne    800ebf <strtol+0x33>
		s++, neg = 1;
  800eb5:	8d 52 01             	lea    0x1(%edx),%edx
  800eb8:	bf 01 00 00 00       	mov    $0x1,%edi
  800ebd:	eb 05                	jmp    800ec4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ebf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ec4:	85 db                	test   %ebx,%ebx
  800ec6:	74 05                	je     800ecd <strtol+0x41>
  800ec8:	83 fb 10             	cmp    $0x10,%ebx
  800ecb:	75 28                	jne    800ef5 <strtol+0x69>
  800ecd:	8a 02                	mov    (%edx),%al
  800ecf:	3c 30                	cmp    $0x30,%al
  800ed1:	75 10                	jne    800ee3 <strtol+0x57>
  800ed3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ed7:	75 0a                	jne    800ee3 <strtol+0x57>
		s += 2, base = 16;
  800ed9:	83 c2 02             	add    $0x2,%edx
  800edc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ee1:	eb 12                	jmp    800ef5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ee3:	85 db                	test   %ebx,%ebx
  800ee5:	75 0e                	jne    800ef5 <strtol+0x69>
  800ee7:	3c 30                	cmp    $0x30,%al
  800ee9:	75 05                	jne    800ef0 <strtol+0x64>
		s++, base = 8;
  800eeb:	42                   	inc    %edx
  800eec:	b3 08                	mov    $0x8,%bl
  800eee:	eb 05                	jmp    800ef5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ef0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800efc:	8a 0a                	mov    (%edx),%cl
  800efe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f01:	80 fb 09             	cmp    $0x9,%bl
  800f04:	77 08                	ja     800f0e <strtol+0x82>
			dig = *s - '0';
  800f06:	0f be c9             	movsbl %cl,%ecx
  800f09:	83 e9 30             	sub    $0x30,%ecx
  800f0c:	eb 1e                	jmp    800f2c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f0e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f11:	80 fb 19             	cmp    $0x19,%bl
  800f14:	77 08                	ja     800f1e <strtol+0x92>
			dig = *s - 'a' + 10;
  800f16:	0f be c9             	movsbl %cl,%ecx
  800f19:	83 e9 57             	sub    $0x57,%ecx
  800f1c:	eb 0e                	jmp    800f2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f1e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f21:	80 fb 19             	cmp    $0x19,%bl
  800f24:	77 12                	ja     800f38 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f26:	0f be c9             	movsbl %cl,%ecx
  800f29:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f2c:	39 f1                	cmp    %esi,%ecx
  800f2e:	7d 0c                	jge    800f3c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f30:	42                   	inc    %edx
  800f31:	0f af c6             	imul   %esi,%eax
  800f34:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f36:	eb c4                	jmp    800efc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f38:	89 c1                	mov    %eax,%ecx
  800f3a:	eb 02                	jmp    800f3e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f3c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f42:	74 05                	je     800f49 <strtol+0xbd>
		*endptr = (char *) s;
  800f44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f47:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f49:	85 ff                	test   %edi,%edi
  800f4b:	74 04                	je     800f51 <strtol+0xc5>
  800f4d:	89 c8                	mov    %ecx,%eax
  800f4f:	f7 d8                	neg    %eax
}
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
	...

00800f58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f66:	8b 55 08             	mov    0x8(%ebp),%edx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	89 c7                	mov    %eax,%edi
  800f6d:	89 c6                	mov    %eax,%esi
  800f6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	b8 01 00 00 00       	mov    $0x1,%eax
  800f86:	89 d1                	mov    %edx,%ecx
  800f88:	89 d3                	mov    %edx,%ebx
  800f8a:	89 d7                	mov    %edx,%edi
  800f8c:	89 d6                	mov    %edx,%esi
  800f8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa3:	b8 03 00 00 00       	mov    $0x3,%eax
  800fa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fab:	89 cb                	mov    %ecx,%ebx
  800fad:	89 cf                	mov    %ecx,%edi
  800faf:	89 ce                	mov    %ecx,%esi
  800fb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 28                	jle    800fdf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fc2:	00 
  800fc3:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  800fca:	00 
  800fcb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd2:	00 
  800fd3:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  800fda:	e8 b1 f5 ff ff       	call   800590 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fdf:	83 c4 2c             	add    $0x2c,%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	89 d3                	mov    %edx,%ebx
  800ffb:	89 d7                	mov    %edx,%edi
  800ffd:	89 d6                	mov    %edx,%esi
  800fff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <sys_yield>:

void
sys_yield(void)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100c:	ba 00 00 00 00       	mov    $0x0,%edx
  801011:	b8 0b 00 00 00       	mov    $0xb,%eax
  801016:	89 d1                	mov    %edx,%ecx
  801018:	89 d3                	mov    %edx,%ebx
  80101a:	89 d7                	mov    %edx,%edi
  80101c:	89 d6                	mov    %edx,%esi
  80101e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	57                   	push   %edi
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102e:	be 00 00 00 00       	mov    $0x0,%esi
  801033:	b8 04 00 00 00       	mov    $0x4,%eax
  801038:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
  801041:	89 f7                	mov    %esi,%edi
  801043:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801045:	85 c0                	test   %eax,%eax
  801047:	7e 28                	jle    801071 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801049:	89 44 24 10          	mov    %eax,0x10(%esp)
  80104d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801054:	00 
  801055:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  80105c:	00 
  80105d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801064:	00 
  801065:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  80106c:	e8 1f f5 ff ff       	call   800590 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801071:	83 c4 2c             	add    $0x2c,%esp
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801082:	b8 05 00 00 00       	mov    $0x5,%eax
  801087:	8b 75 18             	mov    0x18(%ebp),%esi
  80108a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80108d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801093:	8b 55 08             	mov    0x8(%ebp),%edx
  801096:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801098:	85 c0                	test   %eax,%eax
  80109a:	7e 28                	jle    8010c4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010a0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  8010af:	00 
  8010b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010b7:	00 
  8010b8:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  8010bf:	e8 cc f4 ff ff       	call   800590 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010c4:	83 c4 2c             	add    $0x2c,%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	57                   	push   %edi
  8010d0:	56                   	push   %esi
  8010d1:	53                   	push   %ebx
  8010d2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010da:	b8 06 00 00 00       	mov    $0x6,%eax
  8010df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e5:	89 df                	mov    %ebx,%edi
  8010e7:	89 de                	mov    %ebx,%esi
  8010e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	7e 28                	jle    801117 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010f3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  801102:	00 
  801103:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80110a:	00 
  80110b:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  801112:	e8 79 f4 ff ff       	call   800590 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801117:	83 c4 2c             	add    $0x2c,%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	b8 08 00 00 00       	mov    $0x8,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	89 de                	mov    %ebx,%esi
  80113c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 28                	jle    80116a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	89 44 24 10          	mov    %eax,0x10(%esp)
  801146:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80114d:	00 
  80114e:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  801155:	00 
  801156:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80115d:	00 
  80115e:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  801165:	e8 26 f4 ff ff       	call   800590 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80116a:	83 c4 2c             	add    $0x2c,%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801180:	b8 09 00 00 00       	mov    $0x9,%eax
  801185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801188:	8b 55 08             	mov    0x8(%ebp),%edx
  80118b:	89 df                	mov    %ebx,%edi
  80118d:	89 de                	mov    %ebx,%esi
  80118f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801191:	85 c0                	test   %eax,%eax
  801193:	7e 28                	jle    8011bd <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801195:	89 44 24 10          	mov    %eax,0x10(%esp)
  801199:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011a0:	00 
  8011a1:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011b0:	00 
  8011b1:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  8011b8:	e8 d3 f3 ff ff       	call   800590 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011bd:	83 c4 2c             	add    $0x2c,%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5f                   	pop    %edi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	57                   	push   %edi
  8011c9:	56                   	push   %esi
  8011ca:	53                   	push   %ebx
  8011cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011db:	8b 55 08             	mov    0x8(%ebp),%edx
  8011de:	89 df                	mov    %ebx,%edi
  8011e0:	89 de                	mov    %ebx,%esi
  8011e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	7e 28                	jle    801210 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011ec:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011f3:	00 
  8011f4:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  8011fb:	00 
  8011fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801203:	00 
  801204:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  80120b:	e8 80 f3 ff ff       	call   800590 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801210:	83 c4 2c             	add    $0x2c,%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	57                   	push   %edi
  80121c:	56                   	push   %esi
  80121d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80121e:	be 00 00 00 00       	mov    $0x0,%esi
  801223:	b8 0c 00 00 00       	mov    $0xc,%eax
  801228:	8b 7d 14             	mov    0x14(%ebp),%edi
  80122b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80122e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801231:	8b 55 08             	mov    0x8(%ebp),%edx
  801234:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	57                   	push   %edi
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801244:	b9 00 00 00 00       	mov    $0x0,%ecx
  801249:	b8 0d 00 00 00       	mov    $0xd,%eax
  80124e:	8b 55 08             	mov    0x8(%ebp),%edx
  801251:	89 cb                	mov    %ecx,%ebx
  801253:	89 cf                	mov    %ecx,%edi
  801255:	89 ce                	mov    %ecx,%esi
  801257:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801259:	85 c0                	test   %eax,%eax
  80125b:	7e 28                	jle    801285 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801261:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801268:	00 
  801269:	c7 44 24 08 a7 37 80 	movl   $0x8037a7,0x8(%esp)
  801270:	00 
  801271:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801278:	00 
  801279:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  801280:	e8 0b f3 ff ff       	call   800590 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801285:	83 c4 2c             	add    $0x2c,%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801293:	ba 00 00 00 00       	mov    $0x0,%edx
  801298:	b8 0e 00 00 00       	mov    $0xe,%eax
  80129d:	89 d1                	mov    %edx,%ecx
  80129f:	89 d3                	mov    %edx,%ebx
  8012a1:	89 d7                	mov    %edx,%edi
  8012a3:	89 d6                	mov    %edx,%esi
  8012a5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sys_e1000_transmit>:

int 
sys_e1000_transmit(char* pck, size_t length){
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012b7:	b8 10 00 00 00       	mov    $0x10,%eax
  8012bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c2:	89 df                	mov    %ebx,%edi
  8012c4:	89 de                	mov    %ebx,%esi
  8012c6:	cd 30                	int    $0x30
}

int 
sys_e1000_transmit(char* pck, size_t length){
	return syscall(SYS_e1000_transmit, 0, (uint32_t)pck, length, 0, 0, 0);
}
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <sys_e1000_receive>:

int 
sys_e1000_receive(char* pck, size_t* length){
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	57                   	push   %edi
  8012d1:	56                   	push   %esi
  8012d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d8:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e3:	89 df                	mov    %ebx,%edi
  8012e5:	89 de                	mov    %ebx,%esi
  8012e7:	cd 30                	int    $0x30
}

int 
sys_e1000_receive(char* pck, size_t* length){
	return syscall(SYS_e1000_receive, 0, (uint32_t)pck, (uint32_t)length, 0, 0, 0);
}
  8012e9:	5b                   	pop    %ebx
  8012ea:	5e                   	pop    %esi
  8012eb:	5f                   	pop    %edi
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <sys_e1000_get_mac>:

int 
sys_e1000_get_mac(uint8_t* mac_addr){
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f9:	b8 11 00 00 00       	mov    $0x11,%eax
  8012fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801301:	89 cb                	mov    %ecx,%ebx
  801303:	89 cf                	mov    %ecx,%edi
  801305:	89 ce                	mov    %ecx,%esi
  801307:	cd 30                	int    $0x30
}

int 
sys_e1000_get_mac(uint8_t* mac_addr){
	return syscall(SYS_e1000_get_mac, 0, (uint32_t)mac_addr, 0, 0, 0, 0);
}
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5f                   	pop    %edi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    
	...

00801310 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	53                   	push   %ebx
  801314:	83 ec 24             	sub    $0x24,%esp
  801317:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80131a:	8b 18                	mov    (%eax),%ebx
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	if ((err & FEC_WR) == 0)
  80131c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801320:	75 20                	jne    801342 <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  801322:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801326:	c7 44 24 08 d4 37 80 	movl   $0x8037d4,0x8(%esp)
  80132d:	00 
  80132e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801335:	00 
  801336:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  80133d:	e8 4e f2 ff ff       	call   800590 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801342:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  801348:	89 d8                	mov    %ebx,%eax
  80134a:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  80134d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801354:	f6 c4 08             	test   $0x8,%ah
  801357:	75 1c                	jne    801375 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  801359:	c7 44 24 08 04 38 80 	movl   $0x803804,0x8(%esp)
  801360:	00 
  801361:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801368:	00 
  801369:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  801370:	e8 1b f2 ff ff       	call   800590 <_panic>
	//   You should make three system calls.

	// LAB 4: Your code here.

	// Allocate
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801375:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80137c:	00 
  80137d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801384:	00 
  801385:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138c:	e8 94 fc ff ff       	call   801025 <sys_page_alloc>
  801391:	85 c0                	test   %eax,%eax
  801393:	79 20                	jns    8013b5 <pgfault+0xa5>
		panic("sys_page_alloc: %e\n", r);
  801395:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801399:	c7 44 24 08 5f 38 80 	movl   $0x80385f,0x8(%esp)
  8013a0:	00 
  8013a1:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8013a8:	00 
  8013a9:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  8013b0:	e8 db f1 ff ff       	call   800590 <_panic>

	// Copy over
	void *src_addr = (void *) ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, src_addr, PGSIZE);
  8013b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013bc:	00 
  8013bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c1:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8013c8:	e8 df f9 ff ff       	call   800dac <memmove>

	// Remap
	if ((r = sys_page_map(0, PFTEMP, 0, src_addr, PTE_P | PTE_U | PTE_W)) < 0)
  8013cd:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8013d4:	00 
  8013d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013e0:	00 
  8013e1:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013e8:	00 
  8013e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f0:	e8 84 fc ff ff       	call   801079 <sys_page_map>
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	79 20                	jns    801419 <pgfault+0x109>
		panic("sys_page_map: %e\n", r);
  8013f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013fd:	c7 44 24 08 73 38 80 	movl   $0x803873,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  801414:	e8 77 f1 ff ff       	call   800590 <_panic>

}
  801419:	83 c4 24             	add    $0x24,%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	57                   	push   %edi
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t child_envid;

	set_pgfault_handler(pgfault);
  801428:	c7 04 24 10 13 80 00 	movl   $0x801310,(%esp)
  80142f:	e8 b0 1a 00 00       	call   802ee4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801434:	ba 07 00 00 00       	mov    $0x7,%edx
  801439:	89 d0                	mov    %edx,%eax
  80143b:	cd 30                	int    $0x30
  80143d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801440:	89 45 e0             	mov    %eax,-0x20(%ebp)

	child_envid = sys_exofork();
	if (child_envid < 0)
  801443:	85 c0                	test   %eax,%eax
  801445:	79 20                	jns    801467 <fork+0x48>
		panic("sys_exofork: %e\n", child_envid);
  801447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144b:	c7 44 24 08 85 38 80 	movl   $0x803885,0x8(%esp)
  801452:	00 
  801453:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80145a:	00 
  80145b:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  801462:	e8 29 f1 ff ff       	call   800590 <_panic>
	if (child_envid == 0) { // child
  801467:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80146b:	75 1c                	jne    801489 <fork+0x6a>
		// Fix thisenv like dumbfork does and return 0
		thisenv = &envs[ENVX(sys_getenvid())];
  80146d:	e8 75 fb ff ff       	call   800fe7 <sys_getenvid>
  801472:	25 ff 03 00 00       	and    $0x3ff,%eax
  801477:	c1 e0 07             	shl    $0x7,%eax
  80147a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80147f:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  801484:	e9 58 02 00 00       	jmp    8016e1 <fork+0x2c2>
	set_pgfault_handler(pgfault);

	child_envid = sys_exofork();
	if (child_envid < 0)
		panic("sys_exofork: %e\n", child_envid);
	if (child_envid == 0) { // child
  801489:	bf 00 00 00 00       	mov    $0x0,%edi
  80148e:	be 00 00 00 00       	mov    $0x0,%esi
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801493:	89 f0                	mov    %esi,%eax
  801495:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801498:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149f:	a8 01                	test   $0x1,%al
  8014a1:	0f 84 7a 01 00 00    	je     801621 <fork+0x202>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8014a7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8014ae:	a8 01                	test   $0x1,%al
  8014b0:	0f 84 6b 01 00 00    	je     801621 <fork+0x202>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8014b6:	a1 08 50 80 00       	mov    0x805008,%eax
  8014bb:	8b 40 48             	mov    0x48(%eax),%eax
  8014be:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if (uvpt[pn] & PTE_SHARE) {
  8014c1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014c8:	f6 c4 04             	test   $0x4,%ah
  8014cb:	74 52                	je     80151f <fork+0x100>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8014cd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8014d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8014ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ef:	89 04 24             	mov    %eax,(%esp)
  8014f2:	e8 82 fb ff ff       	call   801079 <sys_page_map>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	0f 89 22 01 00 00    	jns    801621 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8014ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801503:	c7 44 24 08 73 38 80 	movl   $0x803873,0x8(%esp)
  80150a:	00 
  80150b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801512:	00 
  801513:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  80151a:	e8 71 f0 ff ff       	call   800590 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  80151f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801526:	f6 c4 08             	test   $0x8,%ah
  801529:	75 0f                	jne    80153a <fork+0x11b>
  80152b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801532:	a8 02                	test   $0x2,%al
  801534:	0f 84 99 00 00 00    	je     8015d3 <fork+0x1b4>
		if (uvpt[pn] & PTE_U)
  80153a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801541:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801544:	83 f8 01             	cmp    $0x1,%eax
  801547:	19 db                	sbb    %ebx,%ebx
  801549:	83 e3 fc             	and    $0xfffffffc,%ebx
  80154c:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801552:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801556:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80155a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80155d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801561:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801565:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801568:	89 04 24             	mov    %eax,(%esp)
  80156b:	e8 09 fb ff ff       	call   801079 <sys_page_map>
  801570:	85 c0                	test   %eax,%eax
  801572:	79 20                	jns    801594 <fork+0x175>
			panic("sys_page_map: %e\n", r);
  801574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801578:	c7 44 24 08 73 38 80 	movl   $0x803873,0x8(%esp)
  80157f:	00 
  801580:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801587:	00 
  801588:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  80158f:	e8 fc ef ff ff       	call   800590 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801594:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801598:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80159c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015a7:	89 04 24             	mov    %eax,(%esp)
  8015aa:	e8 ca fa ff ff       	call   801079 <sys_page_map>
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	79 6e                	jns    801621 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  8015b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b7:	c7 44 24 08 73 38 80 	movl   $0x803873,0x8(%esp)
  8015be:	00 
  8015bf:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8015c6:	00 
  8015c7:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  8015ce:	e8 bd ef ff ff       	call   800590 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8015d3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8015da:	25 07 0e 00 00       	and    $0xe07,%eax
  8015df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f5:	89 04 24             	mov    %eax,(%esp)
  8015f8:	e8 7c fa ff ff       	call   801079 <sys_page_map>
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	79 20                	jns    801621 <fork+0x202>
			panic("sys_page_map: %e\n", r);
  801601:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801605:	c7 44 24 08 73 38 80 	movl   $0x803873,0x8(%esp)
  80160c:	00 
  80160d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801614:	00 
  801615:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  80161c:	e8 6f ef ff ff       	call   800590 <_panic>
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	pte_t *pte;
	for (page_num = 0; page_num < PGNUM(UTOP - PGSIZE); page_num++) {
  801621:	46                   	inc    %esi
  801622:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801628:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  80162e:	0f 85 5f fe ff ff    	jne    801493 <fork+0x74>
	}

	// Allocate exception stack space for child. The child can't do this themselves
	// because the mechanism by which it would is to run the pgfault handler, which
	// needs to run on the exception stack (catch 22).
	if ((r = sys_page_alloc(child_envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801634:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80163b:	00 
  80163c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801643:	ee 
  801644:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801647:	89 04 24             	mov    %eax,(%esp)
  80164a:	e8 d6 f9 ff ff       	call   801025 <sys_page_alloc>
  80164f:	85 c0                	test   %eax,%eax
  801651:	79 20                	jns    801673 <fork+0x254>
		panic("sys_page_alloc: %e\n", r);
  801653:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801657:	c7 44 24 08 5f 38 80 	movl   $0x80385f,0x8(%esp)
  80165e:	00 
  80165f:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801666:	00 
  801667:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  80166e:	e8 1d ef ff ff       	call   800590 <_panic>

	// Set page fault handler for the child
	if ((r = sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall)) < 0)
  801673:	c7 44 24 04 58 2f 80 	movl   $0x802f58,0x4(%esp)
  80167a:	00 
  80167b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80167e:	89 04 24             	mov    %eax,(%esp)
  801681:	e8 3f fb ff ff       	call   8011c5 <sys_env_set_pgfault_upcall>
  801686:	85 c0                	test   %eax,%eax
  801688:	79 20                	jns    8016aa <fork+0x28b>
		panic("sys_env_set_pgfault_upcall: %e\n", r);
  80168a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80168e:	c7 44 24 08 34 38 80 	movl   $0x803834,0x8(%esp)
  801695:	00 
  801696:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
  80169d:	00 
  80169e:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  8016a5:	e8 e6 ee ff ff       	call   800590 <_panic>

	// Mark child environment as runnable
	if ((r = sys_env_set_status(child_envid, ENV_RUNNABLE)) < 0)
  8016aa:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8016b1:	00 
  8016b2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 62 fa ff ff       	call   80111f <sys_env_set_status>
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	79 20                	jns    8016e1 <fork+0x2c2>
		panic("sys_env_set_status: %e\n", r);
  8016c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c5:	c7 44 24 08 96 38 80 	movl   $0x803896,0x8(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
  8016d4:	00 
  8016d5:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  8016dc:	e8 af ee ff ff       	call   800590 <_panic>

	return child_envid;
}
  8016e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016e4:	83 c4 3c             	add    $0x3c,%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5f                   	pop    %edi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    

008016ec <sfork>:

// Challenge!
int
sfork(void)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8016f2:	c7 44 24 08 ae 38 80 	movl   $0x8038ae,0x8(%esp)
  8016f9:	00 
  8016fa:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
  801701:	00 
  801702:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  801709:	e8 82 ee ff ff       	call   800590 <_panic>
	...

00801710 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	05 00 00 00 30       	add    $0x30000000,%eax
  80171b:	c1 e8 0c             	shr    $0xc,%eax
}
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	89 04 24             	mov    %eax,(%esp)
  80172c:	e8 df ff ff ff       	call   801710 <fd2num>
  801731:	05 20 00 0d 00       	add    $0xd0020,%eax
  801736:	c1 e0 0c             	shl    $0xc,%eax
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801742:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801747:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801749:	89 c2                	mov    %eax,%edx
  80174b:	c1 ea 16             	shr    $0x16,%edx
  80174e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801755:	f6 c2 01             	test   $0x1,%dl
  801758:	74 11                	je     80176b <fd_alloc+0x30>
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	c1 ea 0c             	shr    $0xc,%edx
  80175f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801766:	f6 c2 01             	test   $0x1,%dl
  801769:	75 09                	jne    801774 <fd_alloc+0x39>
			*fd_store = fd;
  80176b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80176d:	b8 00 00 00 00       	mov    $0x0,%eax
  801772:	eb 17                	jmp    80178b <fd_alloc+0x50>
  801774:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801779:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80177e:	75 c7                	jne    801747 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801780:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801786:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80178b:	5b                   	pop    %ebx
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801794:	83 f8 1f             	cmp    $0x1f,%eax
  801797:	77 36                	ja     8017cf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801799:	05 00 00 0d 00       	add    $0xd0000,%eax
  80179e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	c1 ea 16             	shr    $0x16,%edx
  8017a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017ad:	f6 c2 01             	test   $0x1,%dl
  8017b0:	74 24                	je     8017d6 <fd_lookup+0x48>
  8017b2:	89 c2                	mov    %eax,%edx
  8017b4:	c1 ea 0c             	shr    $0xc,%edx
  8017b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017be:	f6 c2 01             	test   $0x1,%dl
  8017c1:	74 1a                	je     8017dd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cd:	eb 13                	jmp    8017e2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d4:	eb 0c                	jmp    8017e2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8017d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017db:	eb 05                	jmp    8017e2 <fd_lookup+0x54>
  8017dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8017e2:	5d                   	pop    %ebp
  8017e3:	c3                   	ret    

008017e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 14             	sub    $0x14,%esp
  8017eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	eb 0e                	jmp    801806 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8017f8:	39 08                	cmp    %ecx,(%eax)
  8017fa:	75 09                	jne    801805 <dev_lookup+0x21>
			*dev = devtab[i];
  8017fc:	89 03                	mov    %eax,(%ebx)
			return 0;
  8017fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801803:	eb 33                	jmp    801838 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801805:	42                   	inc    %edx
  801806:	8b 04 95 40 39 80 00 	mov    0x803940(,%edx,4),%eax
  80180d:	85 c0                	test   %eax,%eax
  80180f:	75 e7                	jne    8017f8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801811:	a1 08 50 80 00       	mov    0x805008,%eax
  801816:	8b 40 48             	mov    0x48(%eax),%eax
  801819:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80181d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801821:	c7 04 24 c4 38 80 00 	movl   $0x8038c4,(%esp)
  801828:	e8 5b ee ff ff       	call   800688 <cprintf>
	*dev = 0;
  80182d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801838:	83 c4 14             	add    $0x14,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	83 ec 30             	sub    $0x30,%esp
  801846:	8b 75 08             	mov    0x8(%ebp),%esi
  801849:	8a 45 0c             	mov    0xc(%ebp),%al
  80184c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80184f:	89 34 24             	mov    %esi,(%esp)
  801852:	e8 b9 fe ff ff       	call   801710 <fd2num>
  801857:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80185a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80185e:	89 04 24             	mov    %eax,(%esp)
  801861:	e8 28 ff ff ff       	call   80178e <fd_lookup>
  801866:	89 c3                	mov    %eax,%ebx
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 05                	js     801871 <fd_close+0x33>
	    || fd != fd2)
  80186c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80186f:	74 0d                	je     80187e <fd_close+0x40>
		return (must_exist ? r : 0);
  801871:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801875:	75 46                	jne    8018bd <fd_close+0x7f>
  801877:	bb 00 00 00 00       	mov    $0x0,%ebx
  80187c:	eb 3f                	jmp    8018bd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80187e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	8b 06                	mov    (%esi),%eax
  801887:	89 04 24             	mov    %eax,(%esp)
  80188a:	e8 55 ff ff ff       	call   8017e4 <dev_lookup>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	85 c0                	test   %eax,%eax
  801893:	78 18                	js     8018ad <fd_close+0x6f>
		if (dev->dev_close)
  801895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801898:	8b 40 10             	mov    0x10(%eax),%eax
  80189b:	85 c0                	test   %eax,%eax
  80189d:	74 09                	je     8018a8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80189f:	89 34 24             	mov    %esi,(%esp)
  8018a2:	ff d0                	call   *%eax
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	eb 05                	jmp    8018ad <fd_close+0x6f>
		else
			r = 0;
  8018a8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b8:	e8 0f f8 ff ff       	call   8010cc <sys_page_unmap>
	return r;
}
  8018bd:	89 d8                	mov    %ebx,%eax
  8018bf:	83 c4 30             	add    $0x30,%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	89 04 24             	mov    %eax,(%esp)
  8018d9:	e8 b0 fe ff ff       	call   80178e <fd_lookup>
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 13                	js     8018f5 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8018e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8018e9:	00 
  8018ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ed:	89 04 24             	mov    %eax,(%esp)
  8018f0:	e8 49 ff ff ff       	call   80183e <fd_close>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <close_all>:

void
close_all(void)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8018fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801903:	89 1c 24             	mov    %ebx,(%esp)
  801906:	e8 bb ff ff ff       	call   8018c6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80190b:	43                   	inc    %ebx
  80190c:	83 fb 20             	cmp    $0x20,%ebx
  80190f:	75 f2                	jne    801903 <close_all+0xc>
		close(i);
}
  801911:	83 c4 14             	add    $0x14,%esp
  801914:	5b                   	pop    %ebx
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	57                   	push   %edi
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	83 ec 4c             	sub    $0x4c,%esp
  801920:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801923:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192a:	8b 45 08             	mov    0x8(%ebp),%eax
  80192d:	89 04 24             	mov    %eax,(%esp)
  801930:	e8 59 fe ff ff       	call   80178e <fd_lookup>
  801935:	89 c3                	mov    %eax,%ebx
  801937:	85 c0                	test   %eax,%eax
  801939:	0f 88 e1 00 00 00    	js     801a20 <dup+0x109>
		return r;
	close(newfdnum);
  80193f:	89 3c 24             	mov    %edi,(%esp)
  801942:	e8 7f ff ff ff       	call   8018c6 <close>

	newfd = INDEX2FD(newfdnum);
  801947:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80194d:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801950:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801953:	89 04 24             	mov    %eax,(%esp)
  801956:	e8 c5 fd ff ff       	call   801720 <fd2data>
  80195b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80195d:	89 34 24             	mov    %esi,(%esp)
  801960:	e8 bb fd ff ff       	call   801720 <fd2data>
  801965:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801968:	89 d8                	mov    %ebx,%eax
  80196a:	c1 e8 16             	shr    $0x16,%eax
  80196d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801974:	a8 01                	test   $0x1,%al
  801976:	74 46                	je     8019be <dup+0xa7>
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	c1 e8 0c             	shr    $0xc,%eax
  80197d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801984:	f6 c2 01             	test   $0x1,%dl
  801987:	74 35                	je     8019be <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801989:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801990:	25 07 0e 00 00       	and    $0xe07,%eax
  801995:	89 44 24 10          	mov    %eax,0x10(%esp)
  801999:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80199c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019a7:	00 
  8019a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b3:	e8 c1 f6 ff ff       	call   801079 <sys_page_map>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 3b                	js     8019f9 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8019be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019c1:	89 c2                	mov    %eax,%edx
  8019c3:	c1 ea 0c             	shr    $0xc,%edx
  8019c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019cd:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8019d3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019d7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8019db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019e2:	00 
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019ee:	e8 86 f6 ff ff       	call   801079 <sys_page_map>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	79 25                	jns    801a1e <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a04:	e8 c3 f6 ff ff       	call   8010cc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a17:	e8 b0 f6 ff ff       	call   8010cc <sys_page_unmap>
	return r;
  801a1c:	eb 02                	jmp    801a20 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801a1e:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801a20:	89 d8                	mov    %ebx,%eax
  801a22:	83 c4 4c             	add    $0x4c,%esp
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5f                   	pop    %edi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	53                   	push   %ebx
  801a2e:	83 ec 24             	sub    $0x24,%esp
  801a31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	89 1c 24             	mov    %ebx,(%esp)
  801a3e:	e8 4b fd ff ff       	call   80178e <fd_lookup>
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 6d                	js     801ab4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a51:	8b 00                	mov    (%eax),%eax
  801a53:	89 04 24             	mov    %eax,(%esp)
  801a56:	e8 89 fd ff ff       	call   8017e4 <dev_lookup>
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 55                	js     801ab4 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a62:	8b 50 08             	mov    0x8(%eax),%edx
  801a65:	83 e2 03             	and    $0x3,%edx
  801a68:	83 fa 01             	cmp    $0x1,%edx
  801a6b:	75 23                	jne    801a90 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a6d:	a1 08 50 80 00       	mov    0x805008,%eax
  801a72:	8b 40 48             	mov    0x48(%eax),%eax
  801a75:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7d:	c7 04 24 05 39 80 00 	movl   $0x803905,(%esp)
  801a84:	e8 ff eb ff ff       	call   800688 <cprintf>
		return -E_INVAL;
  801a89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a8e:	eb 24                	jmp    801ab4 <read+0x8a>
	}
	if (!dev->dev_read)
  801a90:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a93:	8b 52 08             	mov    0x8(%edx),%edx
  801a96:	85 d2                	test   %edx,%edx
  801a98:	74 15                	je     801aaf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aa8:	89 04 24             	mov    %eax,(%esp)
  801aab:	ff d2                	call   *%edx
  801aad:	eb 05                	jmp    801ab4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801aaf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801ab4:	83 c4 24             	add    $0x24,%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	57                   	push   %edi
  801abe:	56                   	push   %esi
  801abf:	53                   	push   %ebx
  801ac0:	83 ec 1c             	sub    $0x1c,%esp
  801ac3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ac9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ace:	eb 23                	jmp    801af3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ad0:	89 f0                	mov    %esi,%eax
  801ad2:	29 d8                	sub    %ebx,%eax
  801ad4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adb:	01 d8                	add    %ebx,%eax
  801add:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae1:	89 3c 24             	mov    %edi,(%esp)
  801ae4:	e8 41 ff ff ff       	call   801a2a <read>
		if (m < 0)
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 10                	js     801afd <readn+0x43>
			return m;
		if (m == 0)
  801aed:	85 c0                	test   %eax,%eax
  801aef:	74 0a                	je     801afb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801af1:	01 c3                	add    %eax,%ebx
  801af3:	39 f3                	cmp    %esi,%ebx
  801af5:	72 d9                	jb     801ad0 <readn+0x16>
  801af7:	89 d8                	mov    %ebx,%eax
  801af9:	eb 02                	jmp    801afd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801afb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801afd:	83 c4 1c             	add    $0x1c,%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	53                   	push   %ebx
  801b09:	83 ec 24             	sub    $0x24,%esp
  801b0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b16:	89 1c 24             	mov    %ebx,(%esp)
  801b19:	e8 70 fc ff ff       	call   80178e <fd_lookup>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 68                	js     801b8a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2c:	8b 00                	mov    (%eax),%eax
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 ae fc ff ff       	call   8017e4 <dev_lookup>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 50                	js     801b8a <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b41:	75 23                	jne    801b66 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b43:	a1 08 50 80 00       	mov    0x805008,%eax
  801b48:	8b 40 48             	mov    0x48(%eax),%eax
  801b4b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b53:	c7 04 24 21 39 80 00 	movl   $0x803921,(%esp)
  801b5a:	e8 29 eb ff ff       	call   800688 <cprintf>
		return -E_INVAL;
  801b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b64:	eb 24                	jmp    801b8a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b69:	8b 52 0c             	mov    0xc(%edx),%edx
  801b6c:	85 d2                	test   %edx,%edx
  801b6e:	74 15                	je     801b85 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b70:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b7a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b7e:	89 04 24             	mov    %eax,(%esp)
  801b81:	ff d2                	call   *%edx
  801b83:	eb 05                	jmp    801b8a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801b85:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801b8a:	83 c4 24             	add    $0x24,%esp
  801b8d:	5b                   	pop    %ebx
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <seek>:

int
seek(int fdnum, off_t offset)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b96:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba0:	89 04 24             	mov    %eax,(%esp)
  801ba3:	e8 e6 fb ff ff       	call   80178e <fd_lookup>
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 0e                	js     801bba <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801bac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bb2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bba:	c9                   	leave  
  801bbb:	c3                   	ret    

00801bbc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	83 ec 24             	sub    $0x24,%esp
  801bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcd:	89 1c 24             	mov    %ebx,(%esp)
  801bd0:	e8 b9 fb ff ff       	call   80178e <fd_lookup>
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 61                	js     801c3a <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be3:	8b 00                	mov    (%eax),%eax
  801be5:	89 04 24             	mov    %eax,(%esp)
  801be8:	e8 f7 fb ff ff       	call   8017e4 <dev_lookup>
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 49                	js     801c3a <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bf4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801bf8:	75 23                	jne    801c1d <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801bfa:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801bff:	8b 40 48             	mov    0x48(%eax),%eax
  801c02:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0a:	c7 04 24 e4 38 80 00 	movl   $0x8038e4,(%esp)
  801c11:	e8 72 ea ff ff       	call   800688 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c1b:	eb 1d                	jmp    801c3a <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801c1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c20:	8b 52 18             	mov    0x18(%edx),%edx
  801c23:	85 d2                	test   %edx,%edx
  801c25:	74 0e                	je     801c35 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c2e:	89 04 24             	mov    %eax,(%esp)
  801c31:	ff d2                	call   *%edx
  801c33:	eb 05                	jmp    801c3a <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c35:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c3a:	83 c4 24             	add    $0x24,%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	53                   	push   %ebx
  801c44:	83 ec 24             	sub    $0x24,%esp
  801c47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c51:	8b 45 08             	mov    0x8(%ebp),%eax
  801c54:	89 04 24             	mov    %eax,(%esp)
  801c57:	e8 32 fb ff ff       	call   80178e <fd_lookup>
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	78 52                	js     801cb2 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c6a:	8b 00                	mov    (%eax),%eax
  801c6c:	89 04 24             	mov    %eax,(%esp)
  801c6f:	e8 70 fb ff ff       	call   8017e4 <dev_lookup>
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 3a                	js     801cb2 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801c7f:	74 2c                	je     801cad <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801c81:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801c84:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801c8b:	00 00 00 
	stat->st_isdir = 0;
  801c8e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c95:	00 00 00 
	stat->st_dev = dev;
  801c98:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ca5:	89 14 24             	mov    %edx,(%esp)
  801ca8:	ff 50 14             	call   *0x14(%eax)
  801cab:	eb 05                	jmp    801cb2 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801cad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801cb2:	83 c4 24             	add    $0x24,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    

00801cb8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801cc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cc7:	00 
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 2d 02 00 00       	call   801f00 <open>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 1b                	js     801cf4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce0:	89 1c 24             	mov    %ebx,(%esp)
  801ce3:	e8 58 ff ff ff       	call   801c40 <fstat>
  801ce8:	89 c6                	mov    %eax,%esi
	close(fd);
  801cea:	89 1c 24             	mov    %ebx,(%esp)
  801ced:	e8 d4 fb ff ff       	call   8018c6 <close>
	return r;
  801cf2:	89 f3                	mov    %esi,%ebx
}
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
  801cfd:	00 00                	add    %al,(%eax)
	...

00801d00 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	83 ec 10             	sub    $0x10,%esp
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d0c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d13:	75 11                	jne    801d26 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d1c:	e8 32 13 00 00       	call   803053 <ipc_find_env>
  801d21:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d2d:	00 
  801d2e:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d35:	00 
  801d36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d3a:	a1 00 50 80 00       	mov    0x805000,%eax
  801d3f:	89 04 24             	mov    %eax,(%esp)
  801d42:	e8 9e 12 00 00       	call   802fe5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d4e:	00 
  801d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d5a:	e8 1d 12 00 00       	call   802f7c <ipc_recv>
}
  801d5f:	83 c4 10             	add    $0x10,%esp
  801d62:	5b                   	pop    %ebx
  801d63:	5e                   	pop    %esi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7a:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d84:	b8 02 00 00 00       	mov    $0x2,%eax
  801d89:	e8 72 ff ff ff       	call   801d00 <fsipc>
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d96:	8b 45 08             	mov    0x8(%ebp),%eax
  801d99:	8b 40 0c             	mov    0xc(%eax),%eax
  801d9c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801da1:	ba 00 00 00 00       	mov    $0x0,%edx
  801da6:	b8 06 00 00 00       	mov    $0x6,%eax
  801dab:	e8 50 ff ff ff       	call   801d00 <fsipc>
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    

00801db2 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	53                   	push   %ebx
  801db6:	83 ec 14             	sub    $0x14,%esp
  801db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	8b 40 0c             	mov    0xc(%eax),%eax
  801dc2:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcc:	b8 05 00 00 00       	mov    $0x5,%eax
  801dd1:	e8 2a ff ff ff       	call   801d00 <fsipc>
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	78 2b                	js     801e05 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801dda:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801de1:	00 
  801de2:	89 1c 24             	mov    %ebx,(%esp)
  801de5:	e8 49 ee ff ff       	call   800c33 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801dea:	a1 80 60 80 00       	mov    0x806080,%eax
  801def:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801df5:	a1 84 60 80 00       	mov    0x806084,%eax
  801dfa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e05:	83 c4 14             	add    $0x14,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    

00801e0b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	83 ec 18             	sub    $0x18,%esp
  801e11:	8b 55 10             	mov    0x10(%ebp),%edx
  801e14:	89 d0                	mov    %edx,%eax
  801e16:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801e1c:	76 05                	jbe    801e23 <devfile_write+0x18>
  801e1e:	b8 00 10 00 00       	mov    $0x1000,%eax
	//panic("devfile_write not implemented");
	int r;
	//uint32_t maxsize = BLKSIZE - sizeof(int) - sizeof(size_t);	
	if (n > BLKSIZE)
		n = BLKSIZE;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e23:	8b 55 08             	mov    0x8(%ebp),%edx
  801e26:	8b 52 0c             	mov    0xc(%edx),%edx
  801e29:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801e2f:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801e34:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3f:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801e46:	e8 61 ef ff ff       	call   800dac <memmove>
	 
	return fsipc(FSREQ_WRITE, NULL);
  801e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e50:	b8 04 00 00 00       	mov    $0x4,%eax
  801e55:	e8 a6 fe ff ff       	call   801d00 <fsipc>
}
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	83 ec 10             	sub    $0x10,%esp
  801e64:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e6d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e72:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e78:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7d:	b8 03 00 00 00       	mov    $0x3,%eax
  801e82:	e8 79 fe ff ff       	call   801d00 <fsipc>
  801e87:	89 c3                	mov    %eax,%ebx
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	78 6a                	js     801ef7 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801e8d:	39 c6                	cmp    %eax,%esi
  801e8f:	73 24                	jae    801eb5 <devfile_read+0x59>
  801e91:	c7 44 24 0c 54 39 80 	movl   $0x803954,0xc(%esp)
  801e98:	00 
  801e99:	c7 44 24 08 5b 39 80 	movl   $0x80395b,0x8(%esp)
  801ea0:	00 
  801ea1:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ea8:	00 
  801ea9:	c7 04 24 70 39 80 00 	movl   $0x803970,(%esp)
  801eb0:	e8 db e6 ff ff       	call   800590 <_panic>
	assert(r <= PGSIZE);
  801eb5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801eba:	7e 24                	jle    801ee0 <devfile_read+0x84>
  801ebc:	c7 44 24 0c 7b 39 80 	movl   $0x80397b,0xc(%esp)
  801ec3:	00 
  801ec4:	c7 44 24 08 5b 39 80 	movl   $0x80395b,0x8(%esp)
  801ecb:	00 
  801ecc:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ed3:	00 
  801ed4:	c7 04 24 70 39 80 00 	movl   $0x803970,(%esp)
  801edb:	e8 b0 e6 ff ff       	call   800590 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ee0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee4:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801eeb:	00 
  801eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eef:	89 04 24             	mov    %eax,(%esp)
  801ef2:	e8 b5 ee ff ff       	call   800dac <memmove>
	return r;
}
  801ef7:	89 d8                	mov    %ebx,%eax
  801ef9:	83 c4 10             	add    $0x10,%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	56                   	push   %esi
  801f04:	53                   	push   %ebx
  801f05:	83 ec 20             	sub    $0x20,%esp
  801f08:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f0b:	89 34 24             	mov    %esi,(%esp)
  801f0e:	e8 ed ec ff ff       	call   800c00 <strlen>
  801f13:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f18:	7f 60                	jg     801f7a <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1d:	89 04 24             	mov    %eax,(%esp)
  801f20:	e8 16 f8 ff ff       	call   80173b <fd_alloc>
  801f25:	89 c3                	mov    %eax,%ebx
  801f27:	85 c0                	test   %eax,%eax
  801f29:	78 54                	js     801f7f <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f2f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f36:	e8 f8 ec ff ff       	call   800c33 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	e8 b0 fd ff ff       	call   801d00 <fsipc>
  801f50:	89 c3                	mov    %eax,%ebx
  801f52:	85 c0                	test   %eax,%eax
  801f54:	79 15                	jns    801f6b <open+0x6b>
		fd_close(fd, 0);
  801f56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f5d:	00 
  801f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f61:	89 04 24             	mov    %eax,(%esp)
  801f64:	e8 d5 f8 ff ff       	call   80183e <fd_close>
		return r;
  801f69:	eb 14                	jmp    801f7f <open+0x7f>
	}

	return fd2num(fd);
  801f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 9a f7 ff ff       	call   801710 <fd2num>
  801f76:	89 c3                	mov    %eax,%ebx
  801f78:	eb 05                	jmp    801f7f <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f7a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f7f:	89 d8                	mov    %ebx,%eax
  801f81:	83 c4 20             	add    $0x20,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f93:	b8 08 00 00 00       	mov    $0x8,%eax
  801f98:	e8 63 fd ff ff       	call   801d00 <fsipc>
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    
	...

00801fa0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	57                   	push   %edi
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fb3:	00 
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb7:	89 04 24             	mov    %eax,(%esp)
  801fba:	e8 41 ff ff ff       	call   801f00 <open>
  801fbf:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	0f 88 86 05 00 00    	js     802553 <spawn+0x5b3>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801fcd:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801fd4:	00 
  801fd5:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fdf:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fe5:	89 04 24             	mov    %eax,(%esp)
  801fe8:	e8 cd fa ff ff       	call   801aba <readn>
  801fed:	3d 00 02 00 00       	cmp    $0x200,%eax
  801ff2:	75 0c                	jne    802000 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  801ff4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ffb:	45 4c 46 
  801ffe:	74 3b                	je     80203b <spawn+0x9b>
		close(fd);
  802000:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802006:	89 04 24             	mov    %eax,(%esp)
  802009:	e8 b8 f8 ff ff       	call   8018c6 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80200e:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  802015:	46 
  802016:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  80201c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802020:	c7 04 24 87 39 80 00 	movl   $0x803987,(%esp)
  802027:	e8 5c e6 ff ff       	call   800688 <cprintf>
		return -E_NOT_EXEC;
  80202c:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  802033:	ff ff ff 
  802036:	e9 24 05 00 00       	jmp    80255f <spawn+0x5bf>
  80203b:	ba 07 00 00 00       	mov    $0x7,%edx
  802040:	89 d0                	mov    %edx,%eax
  802042:	cd 30                	int    $0x30
  802044:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80204a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802050:	85 c0                	test   %eax,%eax
  802052:	0f 88 07 05 00 00    	js     80255f <spawn+0x5bf>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802058:	89 c6                	mov    %eax,%esi
  80205a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802060:	c1 e6 07             	shl    $0x7,%esi
  802063:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802069:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80206f:	b9 11 00 00 00       	mov    $0x11,%ecx
  802074:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802076:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80207c:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802082:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802087:	bb 00 00 00 00       	mov    $0x0,%ebx
  80208c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80208f:	eb 0d                	jmp    80209e <spawn+0xfe>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802091:	89 04 24             	mov    %eax,(%esp)
  802094:	e8 67 eb ff ff       	call   800c00 <strlen>
  802099:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80209d:	46                   	inc    %esi
  80209e:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  8020a0:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8020a7:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	75 e3                	jne    802091 <spawn+0xf1>
  8020ae:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  8020b4:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8020ba:	bf 00 10 40 00       	mov    $0x401000,%edi
  8020bf:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8020c1:	89 f8                	mov    %edi,%eax
  8020c3:	83 e0 fc             	and    $0xfffffffc,%eax
  8020c6:	f7 d2                	not    %edx
  8020c8:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8020cb:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8020d1:	89 d0                	mov    %edx,%eax
  8020d3:	83 e8 08             	sub    $0x8,%eax
  8020d6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8020db:	0f 86 8f 04 00 00    	jbe    802570 <spawn+0x5d0>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8020e1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8020e8:	00 
  8020e9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8020f0:	00 
  8020f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020f8:	e8 28 ef ff ff       	call   801025 <sys_page_alloc>
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	0f 88 70 04 00 00    	js     802575 <spawn+0x5d5>
  802105:	bb 00 00 00 00       	mov    $0x0,%ebx
  80210a:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  802110:	8b 75 0c             	mov    0xc(%ebp),%esi
  802113:	eb 2e                	jmp    802143 <spawn+0x1a3>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802115:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80211b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802121:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  802124:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212b:	89 3c 24             	mov    %edi,(%esp)
  80212e:	e8 00 eb ff ff       	call   800c33 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802133:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  802136:	89 04 24             	mov    %eax,(%esp)
  802139:	e8 c2 ea ff ff       	call   800c00 <strlen>
  80213e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802142:	43                   	inc    %ebx
  802143:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  802149:	7c ca                	jl     802115 <spawn+0x175>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80214b:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802151:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802157:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80215e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802164:	74 24                	je     80218a <spawn+0x1ea>
  802166:	c7 44 24 0c 14 3a 80 	movl   $0x803a14,0xc(%esp)
  80216d:	00 
  80216e:	c7 44 24 08 5b 39 80 	movl   $0x80395b,0x8(%esp)
  802175:	00 
  802176:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  80217d:	00 
  80217e:	c7 04 24 a1 39 80 00 	movl   $0x8039a1,(%esp)
  802185:	e8 06 e4 ff ff       	call   800590 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80218a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802190:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802195:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80219b:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80219e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8021a4:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8021a7:	89 d0                	mov    %edx,%eax
  8021a9:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8021ae:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8021b4:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8021bb:	00 
  8021bc:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8021c3:	ee 
  8021c4:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ce:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021d5:	00 
  8021d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021dd:	e8 97 ee ff ff       	call   801079 <sys_page_map>
  8021e2:	89 c3                	mov    %eax,%ebx
  8021e4:	85 c0                	test   %eax,%eax
  8021e6:	78 1a                	js     802202 <spawn+0x262>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8021e8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8021ef:	00 
  8021f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021f7:	e8 d0 ee ff ff       	call   8010cc <sys_page_unmap>
  8021fc:	89 c3                	mov    %eax,%ebx
  8021fe:	85 c0                	test   %eax,%eax
  802200:	79 1f                	jns    802221 <spawn+0x281>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802202:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802209:	00 
  80220a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802211:	e8 b6 ee ff ff       	call   8010cc <sys_page_unmap>
	return r;
  802216:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80221c:	e9 3e 03 00 00       	jmp    80255f <spawn+0x5bf>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802221:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  802227:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  80222d:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802233:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  80223a:	00 00 00 
  80223d:	e9 bb 01 00 00       	jmp    8023fd <spawn+0x45d>
		if (ph->p_type != ELF_PROG_LOAD)
  802242:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802248:	83 38 01             	cmpl   $0x1,(%eax)
  80224b:	0f 85 9f 01 00 00    	jne    8023f0 <spawn+0x450>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802251:	89 c2                	mov    %eax,%edx
  802253:	8b 40 18             	mov    0x18(%eax),%eax
  802256:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802259:	83 f8 01             	cmp    $0x1,%eax
  80225c:	19 c0                	sbb    %eax,%eax
  80225e:	83 e0 fe             	and    $0xfffffffe,%eax
  802261:	83 c0 07             	add    $0x7,%eax
  802264:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80226a:	8b 52 04             	mov    0x4(%edx),%edx
  80226d:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802273:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802279:	8b 40 10             	mov    0x10(%eax),%eax
  80227c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802282:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802288:	8b 52 14             	mov    0x14(%edx),%edx
  80228b:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802291:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802297:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80229a:	89 f8                	mov    %edi,%eax
  80229c:	25 ff 0f 00 00       	and    $0xfff,%eax
  8022a1:	74 16                	je     8022b9 <spawn+0x319>
		va -= i;
  8022a3:	29 c7                	sub    %eax,%edi
		memsz += i;
  8022a5:	01 c2                	add    %eax,%edx
  8022a7:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  8022ad:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  8022b3:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8022b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022be:	e9 1f 01 00 00       	jmp    8023e2 <spawn+0x442>
		if (i >= filesz) {
  8022c3:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8022c9:	77 2b                	ja     8022f6 <spawn+0x356>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8022cb:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8022d1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8022d9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8022df:	89 04 24             	mov    %eax,(%esp)
  8022e2:	e8 3e ed ff ff       	call   801025 <sys_page_alloc>
  8022e7:	85 c0                	test   %eax,%eax
  8022e9:	0f 89 e7 00 00 00    	jns    8023d6 <spawn+0x436>
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	e9 39 02 00 00       	jmp    80252f <spawn+0x58f>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8022f6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022fd:	00 
  8022fe:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802305:	00 
  802306:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80230d:	e8 13 ed ff ff       	call   801025 <sys_page_alloc>
  802312:	85 c0                	test   %eax,%eax
  802314:	0f 88 0b 02 00 00    	js     802525 <spawn+0x585>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80231a:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802320:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802322:	89 44 24 04          	mov    %eax,0x4(%esp)
  802326:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  80232c:	89 04 24             	mov    %eax,(%esp)
  80232f:	e8 5c f8 ff ff       	call   801b90 <seek>
  802334:	85 c0                	test   %eax,%eax
  802336:	0f 88 ed 01 00 00    	js     802529 <spawn+0x589>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80233c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802342:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802344:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802349:	76 05                	jbe    802350 <spawn+0x3b0>
  80234b:	b8 00 10 00 00       	mov    $0x1000,%eax
  802350:	89 44 24 08          	mov    %eax,0x8(%esp)
  802354:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80235b:	00 
  80235c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802362:	89 04 24             	mov    %eax,(%esp)
  802365:	e8 50 f7 ff ff       	call   801aba <readn>
  80236a:	85 c0                	test   %eax,%eax
  80236c:	0f 88 bb 01 00 00    	js     80252d <spawn+0x58d>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802372:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802378:	89 54 24 10          	mov    %edx,0x10(%esp)
  80237c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802380:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802386:	89 44 24 08          	mov    %eax,0x8(%esp)
  80238a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802391:	00 
  802392:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802399:	e8 db ec ff ff       	call   801079 <sys_page_map>
  80239e:	85 c0                	test   %eax,%eax
  8023a0:	79 20                	jns    8023c2 <spawn+0x422>
				panic("spawn: sys_page_map data: %e", r);
  8023a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023a6:	c7 44 24 08 ad 39 80 	movl   $0x8039ad,0x8(%esp)
  8023ad:	00 
  8023ae:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  8023b5:	00 
  8023b6:	c7 04 24 a1 39 80 00 	movl   $0x8039a1,(%esp)
  8023bd:	e8 ce e1 ff ff       	call   800590 <_panic>
			sys_page_unmap(0, UTEMP);
  8023c2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8023c9:	00 
  8023ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023d1:	e8 f6 ec ff ff       	call   8010cc <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8023d6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8023dc:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8023e2:	89 de                	mov    %ebx,%esi
  8023e4:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  8023ea:	0f 82 d3 fe ff ff    	jb     8022c3 <spawn+0x323>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8023f0:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  8023f6:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  8023fd:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802404:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  80240a:	0f 8c 32 fe ff ff    	jl     802242 <spawn+0x2a2>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802410:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802416:	89 04 24             	mov    %eax,(%esp)
  802419:	e8 a8 f4 ff ff       	call   8018c6 <close>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  80241e:	be 00 00 00 00       	mov    $0x0,%esi
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
  802423:	89 f0                	mov    %esi,%eax
  802425:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
  802428:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80242f:	a8 01                	test   $0x1,%al
  802431:	0f 84 82 00 00 00    	je     8024b9 <spawn+0x519>
  802437:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80243e:	a8 01                	test   $0x1,%al
  802440:	74 77                	je     8024b9 <spawn+0x519>
  802442:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  802449:	f6 c4 04             	test   $0x4,%ah
  80244c:	74 6b                	je     8024b9 <spawn+0x519>
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  80244e:	8b 3c b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edi
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802455:	89 f3                	mov    %esi,%ebx
  802457:	c1 e3 0c             	shl    $0xc,%ebx
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES)/NPDENTRIES;
		if ((uvpd[pdx]&PTE_P) && (uvpt[page_num]&PTE_P) && (uvpt[page_num]&PTE_SHARE)){
			if ((r = sys_page_map(sys_getenvid(), (void*)(page_num*PGSIZE), child, (void*)(page_num*PGSIZE), uvpt[page_num]&PTE_SYSCALL)) < 0){
  80245a:	e8 88 eb ff ff       	call   800fe7 <sys_getenvid>
  80245f:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  802465:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802469:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80246d:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  802473:	89 54 24 08          	mov    %edx,0x8(%esp)
  802477:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80247b:	89 04 24             	mov    %eax,(%esp)
  80247e:	e8 f6 eb ff ff       	call   801079 <sys_page_map>
  802483:	85 c0                	test   %eax,%eax
  802485:	79 32                	jns    8024b9 <spawn+0x519>
  802487:	89 c3                	mov    %eax,%ebx
				cprintf("copy_shared_pages: sys_page_map failed, %e", r);
  802489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248d:	c7 04 24 3c 3a 80 00 	movl   $0x803a3c,(%esp)
  802494:	e8 ef e1 ff ff       	call   800688 <cprintf>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  802499:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80249d:	c7 44 24 08 ca 39 80 	movl   $0x8039ca,0x8(%esp)
  8024a4:	00 
  8024a5:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8024ac:	00 
  8024ad:	c7 04 24 a1 39 80 00 	movl   $0x8039a1,(%esp)
  8024b4:	e8 d7 e0 ff ff       	call   800590 <_panic>
{
	// LAB 5: Your code here.
	int r;
	uint32_t page_num;
	
	for (page_num = 0; page_num < PGNUM(UTOP); page_num++) {
  8024b9:	46                   	inc    %esi
  8024ba:	81 fe 00 ec 0e 00    	cmp    $0xeec00,%esi
  8024c0:	0f 85 5d ff ff ff    	jne    802423 <spawn+0x483>
  8024c6:	e9 b2 00 00 00       	jmp    80257d <spawn+0x5dd>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8024cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cf:	c7 44 24 08 e0 39 80 	movl   $0x8039e0,0x8(%esp)
  8024d6:	00 
  8024d7:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  8024de:	00 
  8024df:	c7 04 24 a1 39 80 00 	movl   $0x8039a1,(%esp)
  8024e6:	e8 a5 e0 ff ff       	call   800590 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8024eb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8024f2:	00 
  8024f3:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8024f9:	89 04 24             	mov    %eax,(%esp)
  8024fc:	e8 1e ec ff ff       	call   80111f <sys_env_set_status>
  802501:	85 c0                	test   %eax,%eax
  802503:	79 5a                	jns    80255f <spawn+0x5bf>
		panic("sys_env_set_status: %e", r);
  802505:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802509:	c7 44 24 08 fa 39 80 	movl   $0x8039fa,0x8(%esp)
  802510:	00 
  802511:	c7 44 24 04 88 00 00 	movl   $0x88,0x4(%esp)
  802518:	00 
  802519:	c7 04 24 a1 39 80 00 	movl   $0x8039a1,(%esp)
  802520:	e8 6b e0 ff ff       	call   800590 <_panic>
  802525:	89 c6                	mov    %eax,%esi
  802527:	eb 06                	jmp    80252f <spawn+0x58f>
  802529:	89 c6                	mov    %eax,%esi
  80252b:	eb 02                	jmp    80252f <spawn+0x58f>
  80252d:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  80252f:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802535:	89 04 24             	mov    %eax,(%esp)
  802538:	e8 58 ea ff ff       	call   800f95 <sys_env_destroy>
	close(fd);
  80253d:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802543:	89 04 24             	mov    %eax,(%esp)
  802546:	e8 7b f3 ff ff       	call   8018c6 <close>
	return r;
  80254b:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802551:	eb 0c                	jmp    80255f <spawn+0x5bf>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802553:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802559:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  80255f:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802565:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  80256b:	5b                   	pop    %ebx
  80256c:	5e                   	pop    %esi
  80256d:	5f                   	pop    %edi
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802570:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802575:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  80257b:	eb e2                	jmp    80255f <spawn+0x5bf>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80257d:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802583:	89 44 24 04          	mov    %eax,0x4(%esp)
  802587:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80258d:	89 04 24             	mov    %eax,(%esp)
  802590:	e8 dd eb ff ff       	call   801172 <sys_env_set_trapframe>
  802595:	85 c0                	test   %eax,%eax
  802597:	0f 89 4e ff ff ff    	jns    8024eb <spawn+0x54b>
  80259d:	e9 29 ff ff ff       	jmp    8024cb <spawn+0x52b>

008025a2 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8025a2:	55                   	push   %ebp
  8025a3:	89 e5                	mov    %esp,%ebp
  8025a5:	57                   	push   %edi
  8025a6:	56                   	push   %esi
  8025a7:	53                   	push   %ebx
  8025a8:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  8025ab:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8025ae:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8025b3:	eb 03                	jmp    8025b8 <spawnl+0x16>
		argc++;
  8025b5:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	8d 50 04             	lea    0x4(%eax),%edx
  8025bb:	83 38 00             	cmpl   $0x0,(%eax)
  8025be:	75 f5                	jne    8025b5 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8025c0:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  8025c7:	83 e0 f0             	and    $0xfffffff0,%eax
  8025ca:	29 c4                	sub    %eax,%esp
  8025cc:	8d 7c 24 17          	lea    0x17(%esp),%edi
  8025d0:	83 e7 f0             	and    $0xfffffff0,%edi
  8025d3:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  8025d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d8:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  8025da:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  8025e1:	00 

	va_start(vl, arg0);
  8025e2:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  8025e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8025ea:	eb 09                	jmp    8025f5 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  8025ec:	40                   	inc    %eax
  8025ed:	8b 1a                	mov    (%edx),%ebx
  8025ef:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  8025f2:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  8025f5:	39 c8                	cmp    %ecx,%eax
  8025f7:	75 f3                	jne    8025ec <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  8025f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8025fd:	8b 45 08             	mov    0x8(%ebp),%eax
  802600:	89 04 24             	mov    %eax,(%esp)
  802603:	e8 98 f9 ff ff       	call   801fa0 <spawn>
}
  802608:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260b:	5b                   	pop    %ebx
  80260c:	5e                   	pop    %esi
  80260d:	5f                   	pop    %edi
  80260e:	5d                   	pop    %ebp
  80260f:	c3                   	ret    

00802610 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802616:	c7 44 24 04 67 3a 80 	movl   $0x803a67,0x4(%esp)
  80261d:	00 
  80261e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802621:	89 04 24             	mov    %eax,(%esp)
  802624:	e8 0a e6 ff ff       	call   800c33 <strcpy>
	return 0;
}
  802629:	b8 00 00 00 00       	mov    $0x0,%eax
  80262e:	c9                   	leave  
  80262f:	c3                   	ret    

00802630 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	53                   	push   %ebx
  802634:	83 ec 14             	sub    $0x14,%esp
  802637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80263a:	89 1c 24             	mov    %ebx,(%esp)
  80263d:	e8 4a 0a 00 00       	call   80308c <pageref>
  802642:	83 f8 01             	cmp    $0x1,%eax
  802645:	75 0d                	jne    802654 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  802647:	8b 43 0c             	mov    0xc(%ebx),%eax
  80264a:	89 04 24             	mov    %eax,(%esp)
  80264d:	e8 1f 03 00 00       	call   802971 <nsipc_close>
  802652:	eb 05                	jmp    802659 <devsock_close+0x29>
	else
		return 0;
  802654:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802659:	83 c4 14             	add    $0x14,%esp
  80265c:	5b                   	pop    %ebx
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    

0080265f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80265f:	55                   	push   %ebp
  802660:	89 e5                	mov    %esp,%ebp
  802662:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802665:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80266c:	00 
  80266d:	8b 45 10             	mov    0x10(%ebp),%eax
  802670:	89 44 24 08          	mov    %eax,0x8(%esp)
  802674:	8b 45 0c             	mov    0xc(%ebp),%eax
  802677:	89 44 24 04          	mov    %eax,0x4(%esp)
  80267b:	8b 45 08             	mov    0x8(%ebp),%eax
  80267e:	8b 40 0c             	mov    0xc(%eax),%eax
  802681:	89 04 24             	mov    %eax,(%esp)
  802684:	e8 e3 03 00 00       	call   802a6c <nsipc_send>
}
  802689:	c9                   	leave  
  80268a:	c3                   	ret    

0080268b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80268b:	55                   	push   %ebp
  80268c:	89 e5                	mov    %esp,%ebp
  80268e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802691:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802698:	00 
  802699:	8b 45 10             	mov    0x10(%ebp),%eax
  80269c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8026ad:	89 04 24             	mov    %eax,(%esp)
  8026b0:	e8 37 03 00 00       	call   8029ec <nsipc_recv>
}
  8026b5:	c9                   	leave  
  8026b6:	c3                   	ret    

008026b7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8026b7:	55                   	push   %ebp
  8026b8:	89 e5                	mov    %esp,%ebp
  8026ba:	56                   	push   %esi
  8026bb:	53                   	push   %ebx
  8026bc:	83 ec 20             	sub    $0x20,%esp
  8026bf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8026c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026c4:	89 04 24             	mov    %eax,(%esp)
  8026c7:	e8 6f f0 ff ff       	call   80173b <fd_alloc>
  8026cc:	89 c3                	mov    %eax,%ebx
  8026ce:	85 c0                	test   %eax,%eax
  8026d0:	78 21                	js     8026f3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8026d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8026d9:	00 
  8026da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026e8:	e8 38 e9 ff ff       	call   801025 <sys_page_alloc>
  8026ed:	89 c3                	mov    %eax,%ebx
  8026ef:	85 c0                	test   %eax,%eax
  8026f1:	79 0a                	jns    8026fd <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8026f3:	89 34 24             	mov    %esi,(%esp)
  8026f6:	e8 76 02 00 00       	call   802971 <nsipc_close>
		return r;
  8026fb:	eb 22                	jmp    80271f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8026fd:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802703:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802706:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802712:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802715:	89 04 24             	mov    %eax,(%esp)
  802718:	e8 f3 ef ff ff       	call   801710 <fd2num>
  80271d:	89 c3                	mov    %eax,%ebx
}
  80271f:	89 d8                	mov    %ebx,%eax
  802721:	83 c4 20             	add    $0x20,%esp
  802724:	5b                   	pop    %ebx
  802725:	5e                   	pop    %esi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    

00802728 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802728:	55                   	push   %ebp
  802729:	89 e5                	mov    %esp,%ebp
  80272b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80272e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802731:	89 54 24 04          	mov    %edx,0x4(%esp)
  802735:	89 04 24             	mov    %eax,(%esp)
  802738:	e8 51 f0 ff ff       	call   80178e <fd_lookup>
  80273d:	85 c0                	test   %eax,%eax
  80273f:	78 17                	js     802758 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802744:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80274a:	39 10                	cmp    %edx,(%eax)
  80274c:	75 05                	jne    802753 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80274e:	8b 40 0c             	mov    0xc(%eax),%eax
  802751:	eb 05                	jmp    802758 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802753:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802758:	c9                   	leave  
  802759:	c3                   	ret    

0080275a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80275a:	55                   	push   %ebp
  80275b:	89 e5                	mov    %esp,%ebp
  80275d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802760:	8b 45 08             	mov    0x8(%ebp),%eax
  802763:	e8 c0 ff ff ff       	call   802728 <fd2sockid>
  802768:	85 c0                	test   %eax,%eax
  80276a:	78 1f                	js     80278b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80276c:	8b 55 10             	mov    0x10(%ebp),%edx
  80276f:	89 54 24 08          	mov    %edx,0x8(%esp)
  802773:	8b 55 0c             	mov    0xc(%ebp),%edx
  802776:	89 54 24 04          	mov    %edx,0x4(%esp)
  80277a:	89 04 24             	mov    %eax,(%esp)
  80277d:	e8 38 01 00 00       	call   8028ba <nsipc_accept>
  802782:	85 c0                	test   %eax,%eax
  802784:	78 05                	js     80278b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802786:	e8 2c ff ff ff       	call   8026b7 <alloc_sockfd>
}
  80278b:	c9                   	leave  
  80278c:	c3                   	ret    

0080278d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80278d:	55                   	push   %ebp
  80278e:	89 e5                	mov    %esp,%ebp
  802790:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802793:	8b 45 08             	mov    0x8(%ebp),%eax
  802796:	e8 8d ff ff ff       	call   802728 <fd2sockid>
  80279b:	85 c0                	test   %eax,%eax
  80279d:	78 16                	js     8027b5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80279f:	8b 55 10             	mov    0x10(%ebp),%edx
  8027a2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027ad:	89 04 24             	mov    %eax,(%esp)
  8027b0:	e8 5b 01 00 00       	call   802910 <nsipc_bind>
}
  8027b5:	c9                   	leave  
  8027b6:	c3                   	ret    

008027b7 <shutdown>:

int
shutdown(int s, int how)
{
  8027b7:	55                   	push   %ebp
  8027b8:	89 e5                	mov    %esp,%ebp
  8027ba:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8027c0:	e8 63 ff ff ff       	call   802728 <fd2sockid>
  8027c5:	85 c0                	test   %eax,%eax
  8027c7:	78 0f                	js     8027d8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8027c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027d0:	89 04 24             	mov    %eax,(%esp)
  8027d3:	e8 77 01 00 00       	call   80294f <nsipc_shutdown>
}
  8027d8:	c9                   	leave  
  8027d9:	c3                   	ret    

008027da <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8027da:	55                   	push   %ebp
  8027db:	89 e5                	mov    %esp,%ebp
  8027dd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8027e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8027e3:	e8 40 ff ff ff       	call   802728 <fd2sockid>
  8027e8:	85 c0                	test   %eax,%eax
  8027ea:	78 16                	js     802802 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8027ec:	8b 55 10             	mov    0x10(%ebp),%edx
  8027ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  8027f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8027f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027fa:	89 04 24             	mov    %eax,(%esp)
  8027fd:	e8 89 01 00 00       	call   80298b <nsipc_connect>
}
  802802:	c9                   	leave  
  802803:	c3                   	ret    

00802804 <listen>:

int
listen(int s, int backlog)
{
  802804:	55                   	push   %ebp
  802805:	89 e5                	mov    %esp,%ebp
  802807:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80280a:	8b 45 08             	mov    0x8(%ebp),%eax
  80280d:	e8 16 ff ff ff       	call   802728 <fd2sockid>
  802812:	85 c0                	test   %eax,%eax
  802814:	78 0f                	js     802825 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802816:	8b 55 0c             	mov    0xc(%ebp),%edx
  802819:	89 54 24 04          	mov    %edx,0x4(%esp)
  80281d:	89 04 24             	mov    %eax,(%esp)
  802820:	e8 a5 01 00 00       	call   8029ca <nsipc_listen>
}
  802825:	c9                   	leave  
  802826:	c3                   	ret    

00802827 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802827:	55                   	push   %ebp
  802828:	89 e5                	mov    %esp,%ebp
  80282a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80282d:	8b 45 10             	mov    0x10(%ebp),%eax
  802830:	89 44 24 08          	mov    %eax,0x8(%esp)
  802834:	8b 45 0c             	mov    0xc(%ebp),%eax
  802837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80283b:	8b 45 08             	mov    0x8(%ebp),%eax
  80283e:	89 04 24             	mov    %eax,(%esp)
  802841:	e8 99 02 00 00       	call   802adf <nsipc_socket>
  802846:	85 c0                	test   %eax,%eax
  802848:	78 05                	js     80284f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  80284a:	e8 68 fe ff ff       	call   8026b7 <alloc_sockfd>
}
  80284f:	c9                   	leave  
  802850:	c3                   	ret    
  802851:	00 00                	add    %al,(%eax)
	...

00802854 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802854:	55                   	push   %ebp
  802855:	89 e5                	mov    %esp,%ebp
  802857:	53                   	push   %ebx
  802858:	83 ec 14             	sub    $0x14,%esp
  80285b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80285d:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802864:	75 11                	jne    802877 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802866:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80286d:	e8 e1 07 00 00       	call   803053 <ipc_find_env>
  802872:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802877:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80287e:	00 
  80287f:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802886:	00 
  802887:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80288b:	a1 04 50 80 00       	mov    0x805004,%eax
  802890:	89 04 24             	mov    %eax,(%esp)
  802893:	e8 4d 07 00 00       	call   802fe5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802898:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80289f:	00 
  8028a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8028a7:	00 
  8028a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028af:	e8 c8 06 00 00       	call   802f7c <ipc_recv>
}
  8028b4:	83 c4 14             	add    $0x14,%esp
  8028b7:	5b                   	pop    %ebx
  8028b8:	5d                   	pop    %ebp
  8028b9:	c3                   	ret    

008028ba <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8028ba:	55                   	push   %ebp
  8028bb:	89 e5                	mov    %esp,%ebp
  8028bd:	56                   	push   %esi
  8028be:	53                   	push   %ebx
  8028bf:	83 ec 10             	sub    $0x10,%esp
  8028c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8028c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8028c8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8028cd:	8b 06                	mov    (%esi),%eax
  8028cf:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8028d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028d9:	e8 76 ff ff ff       	call   802854 <nsipc>
  8028de:	89 c3                	mov    %eax,%ebx
  8028e0:	85 c0                	test   %eax,%eax
  8028e2:	78 23                	js     802907 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8028e4:	a1 10 70 80 00       	mov    0x807010,%eax
  8028e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8028ed:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8028f4:	00 
  8028f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028f8:	89 04 24             	mov    %eax,(%esp)
  8028fb:	e8 ac e4 ff ff       	call   800dac <memmove>
		*addrlen = ret->ret_addrlen;
  802900:	a1 10 70 80 00       	mov    0x807010,%eax
  802905:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  802907:	89 d8                	mov    %ebx,%eax
  802909:	83 c4 10             	add    $0x10,%esp
  80290c:	5b                   	pop    %ebx
  80290d:	5e                   	pop    %esi
  80290e:	5d                   	pop    %ebp
  80290f:	c3                   	ret    

00802910 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802910:	55                   	push   %ebp
  802911:	89 e5                	mov    %esp,%ebp
  802913:	53                   	push   %ebx
  802914:	83 ec 14             	sub    $0x14,%esp
  802917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80291a:	8b 45 08             	mov    0x8(%ebp),%eax
  80291d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802922:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802926:	8b 45 0c             	mov    0xc(%ebp),%eax
  802929:	89 44 24 04          	mov    %eax,0x4(%esp)
  80292d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802934:	e8 73 e4 ff ff       	call   800dac <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802939:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80293f:	b8 02 00 00 00       	mov    $0x2,%eax
  802944:	e8 0b ff ff ff       	call   802854 <nsipc>
}
  802949:	83 c4 14             	add    $0x14,%esp
  80294c:	5b                   	pop    %ebx
  80294d:	5d                   	pop    %ebp
  80294e:	c3                   	ret    

0080294f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80294f:	55                   	push   %ebp
  802950:	89 e5                	mov    %esp,%ebp
  802952:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802955:	8b 45 08             	mov    0x8(%ebp),%eax
  802958:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80295d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802960:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802965:	b8 03 00 00 00       	mov    $0x3,%eax
  80296a:	e8 e5 fe ff ff       	call   802854 <nsipc>
}
  80296f:	c9                   	leave  
  802970:	c3                   	ret    

00802971 <nsipc_close>:

int
nsipc_close(int s)
{
  802971:	55                   	push   %ebp
  802972:	89 e5                	mov    %esp,%ebp
  802974:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802977:	8b 45 08             	mov    0x8(%ebp),%eax
  80297a:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  80297f:	b8 04 00 00 00       	mov    $0x4,%eax
  802984:	e8 cb fe ff ff       	call   802854 <nsipc>
}
  802989:	c9                   	leave  
  80298a:	c3                   	ret    

0080298b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80298b:	55                   	push   %ebp
  80298c:	89 e5                	mov    %esp,%ebp
  80298e:	53                   	push   %ebx
  80298f:	83 ec 14             	sub    $0x14,%esp
  802992:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802995:	8b 45 08             	mov    0x8(%ebp),%eax
  802998:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80299d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029a8:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8029af:	e8 f8 e3 ff ff       	call   800dac <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8029b4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8029ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8029bf:	e8 90 fe ff ff       	call   802854 <nsipc>
}
  8029c4:	83 c4 14             	add    $0x14,%esp
  8029c7:	5b                   	pop    %ebx
  8029c8:	5d                   	pop    %ebp
  8029c9:	c3                   	ret    

008029ca <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8029ca:	55                   	push   %ebp
  8029cb:	89 e5                	mov    %esp,%ebp
  8029cd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8029d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8029d3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8029d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029db:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8029e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8029e5:	e8 6a fe ff ff       	call   802854 <nsipc>
}
  8029ea:	c9                   	leave  
  8029eb:	c3                   	ret    

008029ec <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8029ec:	55                   	push   %ebp
  8029ed:	89 e5                	mov    %esp,%ebp
  8029ef:	56                   	push   %esi
  8029f0:	53                   	push   %ebx
  8029f1:	83 ec 10             	sub    $0x10,%esp
  8029f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8029f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8029fa:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8029ff:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802a05:	8b 45 14             	mov    0x14(%ebp),%eax
  802a08:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802a0d:	b8 07 00 00 00       	mov    $0x7,%eax
  802a12:	e8 3d fe ff ff       	call   802854 <nsipc>
  802a17:	89 c3                	mov    %eax,%ebx
  802a19:	85 c0                	test   %eax,%eax
  802a1b:	78 46                	js     802a63 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802a1d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802a22:	7f 04                	jg     802a28 <nsipc_recv+0x3c>
  802a24:	39 c6                	cmp    %eax,%esi
  802a26:	7d 24                	jge    802a4c <nsipc_recv+0x60>
  802a28:	c7 44 24 0c 73 3a 80 	movl   $0x803a73,0xc(%esp)
  802a2f:	00 
  802a30:	c7 44 24 08 5b 39 80 	movl   $0x80395b,0x8(%esp)
  802a37:	00 
  802a38:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802a3f:	00 
  802a40:	c7 04 24 88 3a 80 00 	movl   $0x803a88,(%esp)
  802a47:	e8 44 db ff ff       	call   800590 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802a4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a50:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802a57:	00 
  802a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a5b:	89 04 24             	mov    %eax,(%esp)
  802a5e:	e8 49 e3 ff ff       	call   800dac <memmove>
	}

	return r;
}
  802a63:	89 d8                	mov    %ebx,%eax
  802a65:	83 c4 10             	add    $0x10,%esp
  802a68:	5b                   	pop    %ebx
  802a69:	5e                   	pop    %esi
  802a6a:	5d                   	pop    %ebp
  802a6b:	c3                   	ret    

00802a6c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802a6c:	55                   	push   %ebp
  802a6d:	89 e5                	mov    %esp,%ebp
  802a6f:	53                   	push   %ebx
  802a70:	83 ec 14             	sub    $0x14,%esp
  802a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802a76:	8b 45 08             	mov    0x8(%ebp),%eax
  802a79:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802a7e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802a84:	7e 24                	jle    802aaa <nsipc_send+0x3e>
  802a86:	c7 44 24 0c 94 3a 80 	movl   $0x803a94,0xc(%esp)
  802a8d:	00 
  802a8e:	c7 44 24 08 5b 39 80 	movl   $0x80395b,0x8(%esp)
  802a95:	00 
  802a96:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802a9d:	00 
  802a9e:	c7 04 24 88 3a 80 00 	movl   $0x803a88,(%esp)
  802aa5:	e8 e6 da ff ff       	call   800590 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802aaa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ab5:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802abc:	e8 eb e2 ff ff       	call   800dac <memmove>
	nsipcbuf.send.req_size = size;
  802ac1:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  802aca:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802acf:	b8 08 00 00 00       	mov    $0x8,%eax
  802ad4:	e8 7b fd ff ff       	call   802854 <nsipc>
}
  802ad9:	83 c4 14             	add    $0x14,%esp
  802adc:	5b                   	pop    %ebx
  802add:	5d                   	pop    %ebp
  802ade:	c3                   	ret    

00802adf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802adf:	55                   	push   %ebp
  802ae0:	89 e5                	mov    %esp,%ebp
  802ae2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ae8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  802af0:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802af5:	8b 45 10             	mov    0x10(%ebp),%eax
  802af8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802afd:	b8 09 00 00 00       	mov    $0x9,%eax
  802b02:	e8 4d fd ff ff       	call   802854 <nsipc>
}
  802b07:	c9                   	leave  
  802b08:	c3                   	ret    
  802b09:	00 00                	add    %al,(%eax)
	...

00802b0c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b0c:	55                   	push   %ebp
  802b0d:	89 e5                	mov    %esp,%ebp
  802b0f:	56                   	push   %esi
  802b10:	53                   	push   %ebx
  802b11:	83 ec 10             	sub    $0x10,%esp
  802b14:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b17:	8b 45 08             	mov    0x8(%ebp),%eax
  802b1a:	89 04 24             	mov    %eax,(%esp)
  802b1d:	e8 fe eb ff ff       	call   801720 <fd2data>
  802b22:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802b24:	c7 44 24 04 a0 3a 80 	movl   $0x803aa0,0x4(%esp)
  802b2b:	00 
  802b2c:	89 34 24             	mov    %esi,(%esp)
  802b2f:	e8 ff e0 ff ff       	call   800c33 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b34:	8b 43 04             	mov    0x4(%ebx),%eax
  802b37:	2b 03                	sub    (%ebx),%eax
  802b39:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802b3f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802b46:	00 00 00 
	stat->st_dev = &devpipe;
  802b49:	c7 86 88 00 00 00 58 	movl   $0x804058,0x88(%esi)
  802b50:	40 80 00 
	return 0;
}
  802b53:	b8 00 00 00 00       	mov    $0x0,%eax
  802b58:	83 c4 10             	add    $0x10,%esp
  802b5b:	5b                   	pop    %ebx
  802b5c:	5e                   	pop    %esi
  802b5d:	5d                   	pop    %ebp
  802b5e:	c3                   	ret    

00802b5f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802b5f:	55                   	push   %ebp
  802b60:	89 e5                	mov    %esp,%ebp
  802b62:	53                   	push   %ebx
  802b63:	83 ec 14             	sub    $0x14,%esp
  802b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802b69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b74:	e8 53 e5 ff ff       	call   8010cc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b79:	89 1c 24             	mov    %ebx,(%esp)
  802b7c:	e8 9f eb ff ff       	call   801720 <fd2data>
  802b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b8c:	e8 3b e5 ff ff       	call   8010cc <sys_page_unmap>
}
  802b91:	83 c4 14             	add    $0x14,%esp
  802b94:	5b                   	pop    %ebx
  802b95:	5d                   	pop    %ebp
  802b96:	c3                   	ret    

00802b97 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b97:	55                   	push   %ebp
  802b98:	89 e5                	mov    %esp,%ebp
  802b9a:	57                   	push   %edi
  802b9b:	56                   	push   %esi
  802b9c:	53                   	push   %ebx
  802b9d:	83 ec 2c             	sub    $0x2c,%esp
  802ba0:	89 c7                	mov    %eax,%edi
  802ba2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802ba5:	a1 08 50 80 00       	mov    0x805008,%eax
  802baa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802bad:	89 3c 24             	mov    %edi,(%esp)
  802bb0:	e8 d7 04 00 00       	call   80308c <pageref>
  802bb5:	89 c6                	mov    %eax,%esi
  802bb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bba:	89 04 24             	mov    %eax,(%esp)
  802bbd:	e8 ca 04 00 00       	call   80308c <pageref>
  802bc2:	39 c6                	cmp    %eax,%esi
  802bc4:	0f 94 c0             	sete   %al
  802bc7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802bca:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802bd0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802bd3:	39 cb                	cmp    %ecx,%ebx
  802bd5:	75 08                	jne    802bdf <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802bd7:	83 c4 2c             	add    $0x2c,%esp
  802bda:	5b                   	pop    %ebx
  802bdb:	5e                   	pop    %esi
  802bdc:	5f                   	pop    %edi
  802bdd:	5d                   	pop    %ebp
  802bde:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802bdf:	83 f8 01             	cmp    $0x1,%eax
  802be2:	75 c1                	jne    802ba5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802be4:	8b 42 58             	mov    0x58(%edx),%eax
  802be7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802bee:	00 
  802bef:	89 44 24 08          	mov    %eax,0x8(%esp)
  802bf3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802bf7:	c7 04 24 a7 3a 80 00 	movl   $0x803aa7,(%esp)
  802bfe:	e8 85 da ff ff       	call   800688 <cprintf>
  802c03:	eb a0                	jmp    802ba5 <_pipeisclosed+0xe>

00802c05 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802c05:	55                   	push   %ebp
  802c06:	89 e5                	mov    %esp,%ebp
  802c08:	57                   	push   %edi
  802c09:	56                   	push   %esi
  802c0a:	53                   	push   %ebx
  802c0b:	83 ec 1c             	sub    $0x1c,%esp
  802c0e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802c11:	89 34 24             	mov    %esi,(%esp)
  802c14:	e8 07 eb ff ff       	call   801720 <fd2data>
  802c19:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c1b:	bf 00 00 00 00       	mov    $0x0,%edi
  802c20:	eb 3c                	jmp    802c5e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802c22:	89 da                	mov    %ebx,%edx
  802c24:	89 f0                	mov    %esi,%eax
  802c26:	e8 6c ff ff ff       	call   802b97 <_pipeisclosed>
  802c2b:	85 c0                	test   %eax,%eax
  802c2d:	75 38                	jne    802c67 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802c2f:	e8 d2 e3 ff ff       	call   801006 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c34:	8b 43 04             	mov    0x4(%ebx),%eax
  802c37:	8b 13                	mov    (%ebx),%edx
  802c39:	83 c2 20             	add    $0x20,%edx
  802c3c:	39 d0                	cmp    %edx,%eax
  802c3e:	73 e2                	jae    802c22 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c40:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c43:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802c46:	89 c2                	mov    %eax,%edx
  802c48:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802c4e:	79 05                	jns    802c55 <devpipe_write+0x50>
  802c50:	4a                   	dec    %edx
  802c51:	83 ca e0             	or     $0xffffffe0,%edx
  802c54:	42                   	inc    %edx
  802c55:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802c59:	40                   	inc    %eax
  802c5a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c5d:	47                   	inc    %edi
  802c5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c61:	75 d1                	jne    802c34 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802c63:	89 f8                	mov    %edi,%eax
  802c65:	eb 05                	jmp    802c6c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c67:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802c6c:	83 c4 1c             	add    $0x1c,%esp
  802c6f:	5b                   	pop    %ebx
  802c70:	5e                   	pop    %esi
  802c71:	5f                   	pop    %edi
  802c72:	5d                   	pop    %ebp
  802c73:	c3                   	ret    

00802c74 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802c74:	55                   	push   %ebp
  802c75:	89 e5                	mov    %esp,%ebp
  802c77:	57                   	push   %edi
  802c78:	56                   	push   %esi
  802c79:	53                   	push   %ebx
  802c7a:	83 ec 1c             	sub    $0x1c,%esp
  802c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c80:	89 3c 24             	mov    %edi,(%esp)
  802c83:	e8 98 ea ff ff       	call   801720 <fd2data>
  802c88:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c8a:	be 00 00 00 00       	mov    $0x0,%esi
  802c8f:	eb 3a                	jmp    802ccb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c91:	85 f6                	test   %esi,%esi
  802c93:	74 04                	je     802c99 <devpipe_read+0x25>
				return i;
  802c95:	89 f0                	mov    %esi,%eax
  802c97:	eb 40                	jmp    802cd9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c99:	89 da                	mov    %ebx,%edx
  802c9b:	89 f8                	mov    %edi,%eax
  802c9d:	e8 f5 fe ff ff       	call   802b97 <_pipeisclosed>
  802ca2:	85 c0                	test   %eax,%eax
  802ca4:	75 2e                	jne    802cd4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802ca6:	e8 5b e3 ff ff       	call   801006 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802cab:	8b 03                	mov    (%ebx),%eax
  802cad:	3b 43 04             	cmp    0x4(%ebx),%eax
  802cb0:	74 df                	je     802c91 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802cb2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802cb7:	79 05                	jns    802cbe <devpipe_read+0x4a>
  802cb9:	48                   	dec    %eax
  802cba:	83 c8 e0             	or     $0xffffffe0,%eax
  802cbd:	40                   	inc    %eax
  802cbe:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802cc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802cc5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802cc8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802cca:	46                   	inc    %esi
  802ccb:	3b 75 10             	cmp    0x10(%ebp),%esi
  802cce:	75 db                	jne    802cab <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802cd0:	89 f0                	mov    %esi,%eax
  802cd2:	eb 05                	jmp    802cd9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802cd9:	83 c4 1c             	add    $0x1c,%esp
  802cdc:	5b                   	pop    %ebx
  802cdd:	5e                   	pop    %esi
  802cde:	5f                   	pop    %edi
  802cdf:	5d                   	pop    %ebp
  802ce0:	c3                   	ret    

00802ce1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802ce1:	55                   	push   %ebp
  802ce2:	89 e5                	mov    %esp,%ebp
  802ce4:	57                   	push   %edi
  802ce5:	56                   	push   %esi
  802ce6:	53                   	push   %ebx
  802ce7:	83 ec 3c             	sub    $0x3c,%esp
  802cea:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802ced:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802cf0:	89 04 24             	mov    %eax,(%esp)
  802cf3:	e8 43 ea ff ff       	call   80173b <fd_alloc>
  802cf8:	89 c3                	mov    %eax,%ebx
  802cfa:	85 c0                	test   %eax,%eax
  802cfc:	0f 88 45 01 00 00    	js     802e47 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d09:	00 
  802d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d18:	e8 08 e3 ff ff       	call   801025 <sys_page_alloc>
  802d1d:	89 c3                	mov    %eax,%ebx
  802d1f:	85 c0                	test   %eax,%eax
  802d21:	0f 88 20 01 00 00    	js     802e47 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802d27:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802d2a:	89 04 24             	mov    %eax,(%esp)
  802d2d:	e8 09 ea ff ff       	call   80173b <fd_alloc>
  802d32:	89 c3                	mov    %eax,%ebx
  802d34:	85 c0                	test   %eax,%eax
  802d36:	0f 88 f8 00 00 00    	js     802e34 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d3c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d43:	00 
  802d44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d52:	e8 ce e2 ff ff       	call   801025 <sys_page_alloc>
  802d57:	89 c3                	mov    %eax,%ebx
  802d59:	85 c0                	test   %eax,%eax
  802d5b:	0f 88 d3 00 00 00    	js     802e34 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802d61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802d64:	89 04 24             	mov    %eax,(%esp)
  802d67:	e8 b4 e9 ff ff       	call   801720 <fd2data>
  802d6c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d6e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802d75:	00 
  802d76:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d81:	e8 9f e2 ff ff       	call   801025 <sys_page_alloc>
  802d86:	89 c3                	mov    %eax,%ebx
  802d88:	85 c0                	test   %eax,%eax
  802d8a:	0f 88 91 00 00 00    	js     802e21 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802d93:	89 04 24             	mov    %eax,(%esp)
  802d96:	e8 85 e9 ff ff       	call   801720 <fd2data>
  802d9b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802da2:	00 
  802da3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802da7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802dae:	00 
  802daf:	89 74 24 04          	mov    %esi,0x4(%esp)
  802db3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dba:	e8 ba e2 ff ff       	call   801079 <sys_page_map>
  802dbf:	89 c3                	mov    %eax,%ebx
  802dc1:	85 c0                	test   %eax,%eax
  802dc3:	78 4c                	js     802e11 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802dc5:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802dce:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802dd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802dd3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802dda:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802de0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802de3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802de5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802de8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802def:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802df2:	89 04 24             	mov    %eax,(%esp)
  802df5:	e8 16 e9 ff ff       	call   801710 <fd2num>
  802dfa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802dfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802dff:	89 04 24             	mov    %eax,(%esp)
  802e02:	e8 09 e9 ff ff       	call   801710 <fd2num>
  802e07:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e0f:	eb 36                	jmp    802e47 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802e11:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e1c:	e8 ab e2 ff ff       	call   8010cc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802e21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802e24:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e2f:	e8 98 e2 ff ff       	call   8010cc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802e34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e37:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e42:	e8 85 e2 ff ff       	call   8010cc <sys_page_unmap>
    err:
	return r;
}
  802e47:	89 d8                	mov    %ebx,%eax
  802e49:	83 c4 3c             	add    $0x3c,%esp
  802e4c:	5b                   	pop    %ebx
  802e4d:	5e                   	pop    %esi
  802e4e:	5f                   	pop    %edi
  802e4f:	5d                   	pop    %ebp
  802e50:	c3                   	ret    

00802e51 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802e51:	55                   	push   %ebp
  802e52:	89 e5                	mov    %esp,%ebp
  802e54:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  802e61:	89 04 24             	mov    %eax,(%esp)
  802e64:	e8 25 e9 ff ff       	call   80178e <fd_lookup>
  802e69:	85 c0                	test   %eax,%eax
  802e6b:	78 15                	js     802e82 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e70:	89 04 24             	mov    %eax,(%esp)
  802e73:	e8 a8 e8 ff ff       	call   801720 <fd2data>
	return _pipeisclosed(fd, p);
  802e78:	89 c2                	mov    %eax,%edx
  802e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e7d:	e8 15 fd ff ff       	call   802b97 <_pipeisclosed>
}
  802e82:	c9                   	leave  
  802e83:	c3                   	ret    

00802e84 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802e84:	55                   	push   %ebp
  802e85:	89 e5                	mov    %esp,%ebp
  802e87:	56                   	push   %esi
  802e88:	53                   	push   %ebx
  802e89:	83 ec 10             	sub    $0x10,%esp
  802e8c:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e8f:	85 f6                	test   %esi,%esi
  802e91:	75 24                	jne    802eb7 <wait+0x33>
  802e93:	c7 44 24 0c bf 3a 80 	movl   $0x803abf,0xc(%esp)
  802e9a:	00 
  802e9b:	c7 44 24 08 5b 39 80 	movl   $0x80395b,0x8(%esp)
  802ea2:	00 
  802ea3:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  802eaa:	00 
  802eab:	c7 04 24 ca 3a 80 00 	movl   $0x803aca,(%esp)
  802eb2:	e8 d9 d6 ff ff       	call   800590 <_panic>
	e = &envs[ENVX(envid)];
  802eb7:	89 f3                	mov    %esi,%ebx
  802eb9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  802ebf:	c1 e3 07             	shl    $0x7,%ebx
  802ec2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ec8:	eb 05                	jmp    802ecf <wait+0x4b>
		sys_yield();
  802eca:	e8 37 e1 ff ff       	call   801006 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ecf:	8b 43 48             	mov    0x48(%ebx),%eax
  802ed2:	39 f0                	cmp    %esi,%eax
  802ed4:	75 07                	jne    802edd <wait+0x59>
  802ed6:	8b 43 54             	mov    0x54(%ebx),%eax
  802ed9:	85 c0                	test   %eax,%eax
  802edb:	75 ed                	jne    802eca <wait+0x46>
		sys_yield();
}
  802edd:	83 c4 10             	add    $0x10,%esp
  802ee0:	5b                   	pop    %ebx
  802ee1:	5e                   	pop    %esi
  802ee2:	5d                   	pop    %ebp
  802ee3:	c3                   	ret    

00802ee4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802ee4:	55                   	push   %ebp
  802ee5:	89 e5                	mov    %esp,%ebp
  802ee7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802eea:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802ef1:	75 58                	jne    802f4b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.	
		//panic("set_pgfault_handler not implemented");
		
		if (sys_page_alloc(thisenv->env_id,(void *) (UXSTACKTOP - PGSIZE),(PTE_W|PTE_U|PTE_P)) != 0){
  802ef3:	a1 08 50 80 00       	mov    0x805008,%eax
  802ef8:	8b 40 48             	mov    0x48(%eax),%eax
  802efb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802f02:	00 
  802f03:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802f0a:	ee 
  802f0b:	89 04 24             	mov    %eax,(%esp)
  802f0e:	e8 12 e1 ff ff       	call   801025 <sys_page_alloc>
  802f13:	85 c0                	test   %eax,%eax
  802f15:	74 1c                	je     802f33 <set_pgfault_handler+0x4f>
			panic("set_pg_fault_handler");
  802f17:	c7 44 24 08 d5 3a 80 	movl   $0x803ad5,0x8(%esp)
  802f1e:	00 
  802f1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802f26:	00 
  802f27:	c7 04 24 ea 3a 80 00 	movl   $0x803aea,(%esp)
  802f2e:	e8 5d d6 ff ff       	call   800590 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802f33:	a1 08 50 80 00       	mov    0x805008,%eax
  802f38:	8b 40 48             	mov    0x48(%eax),%eax
  802f3b:	c7 44 24 04 58 2f 80 	movl   $0x802f58,0x4(%esp)
  802f42:	00 
  802f43:	89 04 24             	mov    %eax,(%esp)
  802f46:	e8 7a e2 ff ff       	call   8011c5 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f4e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802f53:	c9                   	leave  
  802f54:	c3                   	ret    
  802f55:	00 00                	add    %al,(%eax)
	...

00802f58 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f58:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f59:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802f5e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f60:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	
	// Save trap-time eip in eax
	movl 0x28(%esp), %eax
  802f63:	8b 44 24 28          	mov    0x28(%esp),%eax

	// Save our current stack
	movl %esp, %ebp
  802f67:	89 e5                	mov    %esp,%ebp

	// Switch to trap-time stack
	movl 0x30(%esp), %esp
  802f69:	8b 64 24 30          	mov    0x30(%esp),%esp

	// Push trap-time eip to the trap-time stack
	pushl %eax
  802f6d:	50                   	push   %eax

	// We now have to update the trap-time esp with its new value
	movl %esp, 0x30(%ebp)
  802f6e:	89 65 30             	mov    %esp,0x30(%ebp)

	// Go back to our exception stack
	movl %ebp, %esp
  802f71:	89 ec                	mov    %ebp,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// Pop fault_va and err, both can be ignored
	popl %eax
  802f73:	58                   	pop    %eax
	popl %eax
  802f74:	58                   	pop    %eax

	// Pop all registers back
	popal
  802f75:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// Skip %eip
	addl $0x4, %esp
  802f76:	83 c4 04             	add    $0x4,%esp

	// Pop eflags back
	popfl
  802f79:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	
	popl %esp
  802f7a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802f7b:	c3                   	ret    

00802f7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802f7c:	55                   	push   %ebp
  802f7d:	89 e5                	mov    %esp,%ebp
  802f7f:	56                   	push   %esi
  802f80:	53                   	push   %ebx
  802f81:	83 ec 10             	sub    $0x10,%esp
  802f84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802f87:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f8a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	int r;
		
	r = sys_ipc_recv(pg?pg:(void*)UTOP);
  802f8d:	85 c0                	test   %eax,%eax
  802f8f:	75 05                	jne    802f96 <ipc_recv+0x1a>
  802f91:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802f96:	89 04 24             	mov    %eax,(%esp)
  802f99:	e8 9d e2 ff ff       	call   80123b <sys_ipc_recv>
	if (from_env_store != NULL)
  802f9e:	85 db                	test   %ebx,%ebx
  802fa0:	74 0b                	je     802fad <ipc_recv+0x31>
		*from_env_store = thisenv->env_ipc_from; 
  802fa2:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802fa8:	8b 52 74             	mov    0x74(%edx),%edx
  802fab:	89 13                	mov    %edx,(%ebx)
	if (perm_store != NULL)
  802fad:	85 f6                	test   %esi,%esi
  802faf:	74 0b                	je     802fbc <ipc_recv+0x40>
		*perm_store = thisenv->env_ipc_perm;
  802fb1:	8b 15 08 50 80 00    	mov    0x805008,%edx
  802fb7:	8b 52 78             	mov    0x78(%edx),%edx
  802fba:	89 16                	mov    %edx,(%esi)
	
	if (r < 0){
  802fbc:	85 c0                	test   %eax,%eax
  802fbe:	79 16                	jns    802fd6 <ipc_recv+0x5a>
		if(from_env_store != NULL)
  802fc0:	85 db                	test   %ebx,%ebx
  802fc2:	74 06                	je     802fca <ipc_recv+0x4e>
			*from_env_store = 0;
  802fc4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store != NULL)	
  802fca:	85 f6                	test   %esi,%esi
  802fcc:	74 10                	je     802fde <ipc_recv+0x62>
			*perm_store = 0;
  802fce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802fd4:	eb 08                	jmp    802fde <ipc_recv+0x62>
		return r;
	}
	
	return thisenv->env_ipc_value;
  802fd6:	a1 08 50 80 00       	mov    0x805008,%eax
  802fdb:	8b 40 70             	mov    0x70(%eax),%eax
}
  802fde:	83 c4 10             	add    $0x10,%esp
  802fe1:	5b                   	pop    %ebx
  802fe2:	5e                   	pop    %esi
  802fe3:	5d                   	pop    %ebp
  802fe4:	c3                   	ret    

00802fe5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802fe5:	55                   	push   %ebp
  802fe6:	89 e5                	mov    %esp,%ebp
  802fe8:	57                   	push   %edi
  802fe9:	56                   	push   %esi
  802fea:	53                   	push   %ebx
  802feb:	83 ec 1c             	sub    $0x1c,%esp
  802fee:	8b 75 08             	mov    0x8(%ebp),%esi
  802ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802ff4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  802ff7:	eb 2a                	jmp    803023 <ipc_send+0x3e>
		if (r != -E_IPC_NOT_RECV)
  802ff9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802ffc:	74 20                	je     80301e <ipc_send+0x39>
			panic("ipc_send: sys_ipc_try_send failed %e", r);
  802ffe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803002:	c7 44 24 08 f8 3a 80 	movl   $0x803af8,0x8(%esp)
  803009:	00 
  80300a:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  803011:	00 
  803012:	c7 04 24 20 3b 80 00 	movl   $0x803b20,(%esp)
  803019:	e8 72 d5 ff ff       	call   800590 <_panic>
		sys_yield();
  80301e:	e8 e3 df ff ff       	call   801006 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	while((r = sys_ipc_try_send(to_env, val, pg?pg:(void*)UTOP, perm)) < 0){
  803023:	85 db                	test   %ebx,%ebx
  803025:	75 07                	jne    80302e <ipc_send+0x49>
  803027:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80302c:	eb 02                	jmp    803030 <ipc_send+0x4b>
  80302e:	89 d8                	mov    %ebx,%eax
  803030:	8b 55 14             	mov    0x14(%ebp),%edx
  803033:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803037:	89 44 24 08          	mov    %eax,0x8(%esp)
  80303b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80303f:	89 34 24             	mov    %esi,(%esp)
  803042:	e8 d1 e1 ff ff       	call   801218 <sys_ipc_try_send>
  803047:	85 c0                	test   %eax,%eax
  803049:	78 ae                	js     802ff9 <ipc_send+0x14>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: sys_ipc_try_send failed %e", r);
		sys_yield();
	}
}
  80304b:	83 c4 1c             	add    $0x1c,%esp
  80304e:	5b                   	pop    %ebx
  80304f:	5e                   	pop    %esi
  803050:	5f                   	pop    %edi
  803051:	5d                   	pop    %ebp
  803052:	c3                   	ret    

00803053 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803053:	55                   	push   %ebp
  803054:	89 e5                	mov    %esp,%ebp
  803056:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803059:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80305e:	89 c2                	mov    %eax,%edx
  803060:	c1 e2 07             	shl    $0x7,%edx
  803063:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803069:	8b 52 50             	mov    0x50(%edx),%edx
  80306c:	39 ca                	cmp    %ecx,%edx
  80306e:	75 0d                	jne    80307d <ipc_find_env+0x2a>
			return envs[i].env_id;
  803070:	c1 e0 07             	shl    $0x7,%eax
  803073:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803078:	8b 40 40             	mov    0x40(%eax),%eax
  80307b:	eb 0c                	jmp    803089 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80307d:	40                   	inc    %eax
  80307e:	3d 00 04 00 00       	cmp    $0x400,%eax
  803083:	75 d9                	jne    80305e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803085:	66 b8 00 00          	mov    $0x0,%ax
}
  803089:	5d                   	pop    %ebp
  80308a:	c3                   	ret    
	...

0080308c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80308c:	55                   	push   %ebp
  80308d:	89 e5                	mov    %esp,%ebp
  80308f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803092:	89 c2                	mov    %eax,%edx
  803094:	c1 ea 16             	shr    $0x16,%edx
  803097:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80309e:	f6 c2 01             	test   $0x1,%dl
  8030a1:	74 1e                	je     8030c1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030a3:	c1 e8 0c             	shr    $0xc,%eax
  8030a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8030ad:	a8 01                	test   $0x1,%al
  8030af:	74 17                	je     8030c8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030b1:	c1 e8 0c             	shr    $0xc,%eax
  8030b4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8030bb:	ef 
  8030bc:	0f b7 c0             	movzwl %ax,%eax
  8030bf:	eb 0c                	jmp    8030cd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8030c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8030c6:	eb 05                	jmp    8030cd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8030c8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8030cd:	5d                   	pop    %ebp
  8030ce:	c3                   	ret    
	...

008030d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8030d0:	55                   	push   %ebp
  8030d1:	57                   	push   %edi
  8030d2:	56                   	push   %esi
  8030d3:	83 ec 10             	sub    $0x10,%esp
  8030d6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8030da:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8030de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8030e2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8030e6:	89 cd                	mov    %ecx,%ebp
  8030e8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030ec:	85 c0                	test   %eax,%eax
  8030ee:	75 2c                	jne    80311c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8030f0:	39 f9                	cmp    %edi,%ecx
  8030f2:	77 68                	ja     80315c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8030f4:	85 c9                	test   %ecx,%ecx
  8030f6:	75 0b                	jne    803103 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8030f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8030fd:	31 d2                	xor    %edx,%edx
  8030ff:	f7 f1                	div    %ecx
  803101:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803103:	31 d2                	xor    %edx,%edx
  803105:	89 f8                	mov    %edi,%eax
  803107:	f7 f1                	div    %ecx
  803109:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80310b:	89 f0                	mov    %esi,%eax
  80310d:	f7 f1                	div    %ecx
  80310f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803111:	89 f0                	mov    %esi,%eax
  803113:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803115:	83 c4 10             	add    $0x10,%esp
  803118:	5e                   	pop    %esi
  803119:	5f                   	pop    %edi
  80311a:	5d                   	pop    %ebp
  80311b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80311c:	39 f8                	cmp    %edi,%eax
  80311e:	77 2c                	ja     80314c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803120:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  803123:	83 f6 1f             	xor    $0x1f,%esi
  803126:	75 4c                	jne    803174 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803128:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80312a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80312f:	72 0a                	jb     80313b <__udivdi3+0x6b>
  803131:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803135:	0f 87 ad 00 00 00    	ja     8031e8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80313b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803140:	89 f0                	mov    %esi,%eax
  803142:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803144:	83 c4 10             	add    $0x10,%esp
  803147:	5e                   	pop    %esi
  803148:	5f                   	pop    %edi
  803149:	5d                   	pop    %ebp
  80314a:	c3                   	ret    
  80314b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80314c:	31 ff                	xor    %edi,%edi
  80314e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803150:	89 f0                	mov    %esi,%eax
  803152:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803154:	83 c4 10             	add    $0x10,%esp
  803157:	5e                   	pop    %esi
  803158:	5f                   	pop    %edi
  803159:	5d                   	pop    %ebp
  80315a:	c3                   	ret    
  80315b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80315c:	89 fa                	mov    %edi,%edx
  80315e:	89 f0                	mov    %esi,%eax
  803160:	f7 f1                	div    %ecx
  803162:	89 c6                	mov    %eax,%esi
  803164:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803166:	89 f0                	mov    %esi,%eax
  803168:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80316a:	83 c4 10             	add    $0x10,%esp
  80316d:	5e                   	pop    %esi
  80316e:	5f                   	pop    %edi
  80316f:	5d                   	pop    %ebp
  803170:	c3                   	ret    
  803171:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803174:	89 f1                	mov    %esi,%ecx
  803176:	d3 e0                	shl    %cl,%eax
  803178:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80317c:	b8 20 00 00 00       	mov    $0x20,%eax
  803181:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  803183:	89 ea                	mov    %ebp,%edx
  803185:	88 c1                	mov    %al,%cl
  803187:	d3 ea                	shr    %cl,%edx
  803189:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80318d:	09 ca                	or     %ecx,%edx
  80318f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  803193:	89 f1                	mov    %esi,%ecx
  803195:	d3 e5                	shl    %cl,%ebp
  803197:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80319b:	89 fd                	mov    %edi,%ebp
  80319d:	88 c1                	mov    %al,%cl
  80319f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8031a1:	89 fa                	mov    %edi,%edx
  8031a3:	89 f1                	mov    %esi,%ecx
  8031a5:	d3 e2                	shl    %cl,%edx
  8031a7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8031ab:	88 c1                	mov    %al,%cl
  8031ad:	d3 ef                	shr    %cl,%edi
  8031af:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8031b1:	89 f8                	mov    %edi,%eax
  8031b3:	89 ea                	mov    %ebp,%edx
  8031b5:	f7 74 24 08          	divl   0x8(%esp)
  8031b9:	89 d1                	mov    %edx,%ecx
  8031bb:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8031bd:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031c1:	39 d1                	cmp    %edx,%ecx
  8031c3:	72 17                	jb     8031dc <__udivdi3+0x10c>
  8031c5:	74 09                	je     8031d0 <__udivdi3+0x100>
  8031c7:	89 fe                	mov    %edi,%esi
  8031c9:	31 ff                	xor    %edi,%edi
  8031cb:	e9 41 ff ff ff       	jmp    803111 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8031d0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8031d4:	89 f1                	mov    %esi,%ecx
  8031d6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031d8:	39 c2                	cmp    %eax,%edx
  8031da:	73 eb                	jae    8031c7 <__udivdi3+0xf7>
		{
		  q0--;
  8031dc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8031df:	31 ff                	xor    %edi,%edi
  8031e1:	e9 2b ff ff ff       	jmp    803111 <__udivdi3+0x41>
  8031e6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8031e8:	31 f6                	xor    %esi,%esi
  8031ea:	e9 22 ff ff ff       	jmp    803111 <__udivdi3+0x41>
	...

008031f0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8031f0:	55                   	push   %ebp
  8031f1:	57                   	push   %edi
  8031f2:	56                   	push   %esi
  8031f3:	83 ec 20             	sub    $0x20,%esp
  8031f6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8031fa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8031fe:	89 44 24 14          	mov    %eax,0x14(%esp)
  803202:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  803206:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80320a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80320e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  803210:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803212:	85 ed                	test   %ebp,%ebp
  803214:	75 16                	jne    80322c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  803216:	39 f1                	cmp    %esi,%ecx
  803218:	0f 86 a6 00 00 00    	jbe    8032c4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80321e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  803220:	89 d0                	mov    %edx,%eax
  803222:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803224:	83 c4 20             	add    $0x20,%esp
  803227:	5e                   	pop    %esi
  803228:	5f                   	pop    %edi
  803229:	5d                   	pop    %ebp
  80322a:	c3                   	ret    
  80322b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80322c:	39 f5                	cmp    %esi,%ebp
  80322e:	0f 87 ac 00 00 00    	ja     8032e0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803234:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  803237:	83 f0 1f             	xor    $0x1f,%eax
  80323a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80323e:	0f 84 a8 00 00 00    	je     8032ec <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803244:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803248:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80324a:	bf 20 00 00 00       	mov    $0x20,%edi
  80324f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803253:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803257:	89 f9                	mov    %edi,%ecx
  803259:	d3 e8                	shr    %cl,%eax
  80325b:	09 e8                	or     %ebp,%eax
  80325d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803261:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803265:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803269:	d3 e0                	shl    %cl,%eax
  80326b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80326f:	89 f2                	mov    %esi,%edx
  803271:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803273:	8b 44 24 14          	mov    0x14(%esp),%eax
  803277:	d3 e0                	shl    %cl,%eax
  803279:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80327d:	8b 44 24 14          	mov    0x14(%esp),%eax
  803281:	89 f9                	mov    %edi,%ecx
  803283:	d3 e8                	shr    %cl,%eax
  803285:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  803287:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803289:	89 f2                	mov    %esi,%edx
  80328b:	f7 74 24 18          	divl   0x18(%esp)
  80328f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803291:	f7 64 24 0c          	mull   0xc(%esp)
  803295:	89 c5                	mov    %eax,%ebp
  803297:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803299:	39 d6                	cmp    %edx,%esi
  80329b:	72 67                	jb     803304 <__umoddi3+0x114>
  80329d:	74 75                	je     803314 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80329f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8032a3:	29 e8                	sub    %ebp,%eax
  8032a5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8032a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8032ab:	d3 e8                	shr    %cl,%eax
  8032ad:	89 f2                	mov    %esi,%edx
  8032af:	89 f9                	mov    %edi,%ecx
  8032b1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8032b3:	09 d0                	or     %edx,%eax
  8032b5:	89 f2                	mov    %esi,%edx
  8032b7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8032bb:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032bd:	83 c4 20             	add    $0x20,%esp
  8032c0:	5e                   	pop    %esi
  8032c1:	5f                   	pop    %edi
  8032c2:	5d                   	pop    %ebp
  8032c3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8032c4:	85 c9                	test   %ecx,%ecx
  8032c6:	75 0b                	jne    8032d3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8032c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8032cd:	31 d2                	xor    %edx,%edx
  8032cf:	f7 f1                	div    %ecx
  8032d1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8032d3:	89 f0                	mov    %esi,%eax
  8032d5:	31 d2                	xor    %edx,%edx
  8032d7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8032d9:	89 f8                	mov    %edi,%eax
  8032db:	e9 3e ff ff ff       	jmp    80321e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8032e0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032e2:	83 c4 20             	add    $0x20,%esp
  8032e5:	5e                   	pop    %esi
  8032e6:	5f                   	pop    %edi
  8032e7:	5d                   	pop    %ebp
  8032e8:	c3                   	ret    
  8032e9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8032ec:	39 f5                	cmp    %esi,%ebp
  8032ee:	72 04                	jb     8032f4 <__umoddi3+0x104>
  8032f0:	39 f9                	cmp    %edi,%ecx
  8032f2:	77 06                	ja     8032fa <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8032f4:	89 f2                	mov    %esi,%edx
  8032f6:	29 cf                	sub    %ecx,%edi
  8032f8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8032fa:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8032fc:	83 c4 20             	add    $0x20,%esp
  8032ff:	5e                   	pop    %esi
  803300:	5f                   	pop    %edi
  803301:	5d                   	pop    %ebp
  803302:	c3                   	ret    
  803303:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803304:	89 d1                	mov    %edx,%ecx
  803306:	89 c5                	mov    %eax,%ebp
  803308:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80330c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803310:	eb 8d                	jmp    80329f <__umoddi3+0xaf>
  803312:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803314:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803318:	72 ea                	jb     803304 <__umoddi3+0x114>
  80331a:	89 f1                	mov    %esi,%ecx
  80331c:	eb 81                	jmp    80329f <__umoddi3+0xaf>
